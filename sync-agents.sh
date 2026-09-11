#!/usr/bin/env bash
set -euo pipefail

# Script: sync-agents.sh
# Purpose: Single-entrypoint script to sync, inspect, or uninstall AGENTS.md, skills,
#          and global knowledge/decision indexes across AI provider configs.

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_AGENTS="$BASE_DIR/AGENTS.md"
SOURCE_MEMORY="$BASE_DIR/.agents/MEMORY.md"
SOURCE_SKILLS="$BASE_DIR/skills"

if [[ ! -f "$SOURCE_AGENTS" ]]; then
  echo "Error: Source file $SOURCE_AGENTS not found." >&2
  exit 1
fi

ACTION="sync"   # sync, uninstall, status
MODE="copy"     # copy, link
TARGET="all"
PROJECT_DIR=""
DRY_RUN=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [TARGET]

Actions / Targets:
  all            Sync AGENTS.md and skills to all supported providers (default)
  status         Check status of global AI configuration files and installed skills
  uninstall      Remove installed files and skills from providers
  antigravity    Google Antigravity (~/.gemini/config/AGENTS.md, skills/)
  anthropic      Anthropic / Claude Code (~/.claude/CLAUDE.md, AGENTS.md)
  openai         OpenAI / Codex (~/.codex/instructions.md, ~/.openai/AGENTS.md)
  cursor         Cursor IDE (~/.cursorrules)
  copilot        GitHub Copilot CLI/extensions (~/.config/github-copilot/copilot-instructions.md)

Project Initialization:
  -p, --project <dir>   Bootstrap AGENTS.md, .agents/MEMORY.md, skills, and doc indexes into target project

Options:
  -l, --link            Create symbolic links instead of copying (global targets only)
  -c, --copy            Copy files directly (default)
  -u, --uninstall       Uninstall installed files/skills instead of syncing
  -s, --status          Check status of installed global configuration files
  -n, --dry-run         Preview actions without making changes
  -h, --help            Show this help message

Examples:
  $(basename "$0") --copy                  # Copy AGENTS.md & skills to all providers
  $(basename "$0") --link                  # Symlink to all providers (live edits)
  $(basename "$0") status                  # Inspect installed files, skills & links
  $(basename "$0") --uninstall             # Uninstall from all providers
  $(basename "$0") --uninstall antigravity # Uninstall only from Google Antigravity
  $(basename "$0") -p ../my-new-service    # Bootstrap a new project with rules & skills
EOF
  exit 0
}

# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--project)
      PROJECT_DIR="$2"
      shift 2
      ;;
    -l|--link|--symlink)
      MODE="link"
      shift
      ;;
    -c|--copy)
      MODE="copy"
      shift
      ;;
    -u|--uninstall)
      ACTION="uninstall"
      shift
      ;;
    -s|--status)
      ACTION="status"
      shift
      ;;
    -n|--dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      ;;
    uninstall)
      ACTION="uninstall"
      shift
      ;;
    status)
      ACTION="status"
      shift
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      ;;
    *)
      TARGET="$1"
      shift
      ;;
  esac
done

sync_file() {
  local src="$1"
  local dest="$2"
  local dest_dir
  dest_dir="$(dirname "$dest")"

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] Would install ($MODE) $src -> $dest"
    return 0
  fi

  mkdir -p "$dest_dir"

  if [[ "$MODE" == "link" ]]; then
    ln -sf "$src" "$dest"
    echo "✔ Linked:   $dest -> $src"
  else
    cp "$src" "$dest"
    echo "✔ Copied:   $dest"
  fi
}

remove_path() {
  local target="$1"
  if [[ -L "$target" || -f "$target" ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "[dry-run] Would remove file/link: $target"
    else
      rm -f "$target"
      echo "✔ Removed: $target"
    fi
  elif [[ -d "$target" ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "[dry-run] Would remove directory: $target"
    else
      rm -rf "$target"
      echo "✔ Removed: $target"
    fi
  fi
}

ensure_index_file() {
  local file="$1"
  local header="$2"
  local dir
  dir="$(dirname "$file")"

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "[dry-run] Would ensure index exists at: $file"
    return 0
  fi

  mkdir -p "$dir"
  if [[ ! -f "$file" ]]; then
    echo "$header" > "$file"
    echo "✔ Created index: $file"
  fi
}

sync_skills_to() {
  local target_skills_dir="$1"
  if [[ -d "$SOURCE_SKILLS" ]]; then
    for skill_dir in "$SOURCE_SKILLS"/*; do
      if [[ -d "$skill_dir" ]]; then
        local skill_name
        skill_name="$(basename "$skill_dir")"
        local skill_file="$skill_dir/SKILL.md"
        if [[ -f "$skill_file" ]]; then
          sync_file "$skill_file" "$target_skills_dir/$skill_name/SKILL.md"
        fi
      fi
    done
  fi
}

uninstall_skills_from() {
  local target_skills_dir="$1"
  if [[ -d "$SOURCE_SKILLS" ]]; then
    for skill_dir in "$SOURCE_SKILLS"/*; do
      if [[ -d "$skill_dir" ]]; then
        local skill_name
        skill_name="$(basename "$skill_dir")"
        remove_path "$target_skills_dir/$skill_name"
      fi
    done
  fi
}

init_project() {
  local target_dir="$1"
  echo "--- Initializing Project at: $target_dir ---"
  sync_file "$SOURCE_AGENTS" "$target_dir/AGENTS.md"
  if [[ -f "$SOURCE_MEMORY" ]]; then
    sync_file "$SOURCE_MEMORY" "$target_dir/.agents/MEMORY.md"
  fi
  sync_skills_to "$target_dir/.agents/skills"

  ensure_index_file "$target_dir/docs/decisions/INDEX.md" "$(cat <<'EOF'
# Architectural Decisions Index (Local)

| ID | Date | Title | Status | Summary |
| :--- | :--- | :--- | :--- | :--- |
EOF
)"

  ensure_index_file "$target_dir/docs/knowledge/INDEX.md" "$(cat <<'EOF'
# Knowledge Base Index (Local)

| Topic | Activation Trigger | Summary | Source |
| :--- | :--- | :--- | :--- |
EOF
)"

  echo "✔ Project successfully bootstrapped with AGENTS.md, .agents/MEMORY.md, skills, and doc indexes."
}

check_status() {
  local paths=(
    "$HOME/.gemini/config/AGENTS.md"
    "$HOME/.gemini/config/GEMINI.md"
    "$HOME/.claude/CLAUDE.md"
    "$HOME/.claude/AGENTS.md"
    "$HOME/.codex/instructions.md"
    "$HOME/.openai/AGENTS.md"
    "$HOME/.cursorrules"
    "$HOME/.config/github-copilot/copilot-instructions.md"
    "$HOME/.gemini/config/decisions/INDEX.md"
    "$HOME/.gemini/config/knowledge/INDEX.md"
  )

  echo "AI Global Configuration Status:"
  echo "--------------------------------"
  for path in "${paths[@]}"; do
    if [[ -L "$path" ]]; then
      echo "  [SYMLINK] $path -> $(readlink "$path")"
    elif [[ -f "$path" ]]; then
      echo "  [FILE]    $path"
    else
      echo "  [MISSING] $path"
    fi
  done

  echo ""
  echo "Google Antigravity Global Skills (~/.gemini/config/skills/):"
  echo "-------------------------------------------------------------"
  if [[ -d "$HOME/.gemini/config/skills" ]]; then
    for s in "$HOME/.gemini/config/skills"/*; do
      if [[ -d "$s" ]]; then
        local s_name
        s_name="$(basename "$s")"
        if [[ -L "$s/SKILL.md" ]]; then
          echo "  [SYMLINK SKILL] $s_name -> $(readlink "$s/SKILL.md")"
        elif [[ -f "$s/SKILL.md" ]]; then
          echo "  [FILE SKILL]    $s_name"
        fi
      fi
    done
  else
    echo "  (No global skills directory found)"
  fi
}

# If project bootstrap mode was selected
if [[ -n "$PROJECT_DIR" ]]; then
  init_project "$PROJECT_DIR"
  exit 0
fi

# Provider sync handlers
sync_antigravity() {
  echo "--- Google Antigravity ---"
  sync_file "$SOURCE_AGENTS" "$HOME/.gemini/config/AGENTS.md"
  sync_file "$SOURCE_AGENTS" "$HOME/.gemini/config/GEMINI.md"
  sync_skills_to "$HOME/.gemini/config/skills"

  ensure_index_file "$HOME/.gemini/config/decisions/INDEX.md" "$(cat <<'EOF'
# Global Architectural Decisions Index

| ID | Date | Title | Status | Summary |
| :--- | :--- | :--- | :--- | :--- |
EOF
)"

  ensure_index_file "$HOME/.gemini/config/knowledge/INDEX.md" "$(cat <<'EOF'
# Global Knowledge Base Index

| Topic | Activation Trigger | Summary | Source |
| :--- | :--- | :--- | :--- |
EOF
)"
}

sync_anthropic() {
  echo "--- Anthropic (Claude Code) ---"
  sync_file "$SOURCE_AGENTS" "$HOME/.claude/CLAUDE.md"
  sync_file "$SOURCE_AGENTS" "$HOME/.claude/AGENTS.md"
}

sync_openai() {
  echo "--- OpenAI / Codex ---"
  sync_file "$SOURCE_AGENTS" "$HOME/.codex/instructions.md"
  sync_file "$SOURCE_AGENTS" "$HOME/.codex/AGENTS.md"
  sync_file "$SOURCE_AGENTS" "$HOME/.openai/AGENTS.md"
}

sync_cursor() {
  echo "--- Cursor ---"
  sync_file "$SOURCE_AGENTS" "$HOME/.cursorrules"
}

sync_copilot() {
  echo "--- GitHub Copilot ---"
  sync_file "$SOURCE_AGENTS" "$HOME/.config/github-copilot/copilot-instructions.md"
}

# Provider uninstall handlers
uninstall_antigravity() {
  echo "--- Uninstalling from Google Antigravity ---"
  remove_path "$HOME/.gemini/config/AGENTS.md"
  remove_path "$HOME/.gemini/config/GEMINI.md"
  uninstall_skills_from "$HOME/.gemini/config/skills"
}

uninstall_anthropic() {
  echo "--- Uninstalling from Anthropic (Claude Code) ---"
  remove_path "$HOME/.claude/CLAUDE.md"
  remove_path "$HOME/.claude/AGENTS.md"
}

uninstall_openai() {
  echo "--- Uninstalling from OpenAI / Codex ---"
  remove_path "$HOME/.codex/instructions.md"
  remove_path "$HOME/.codex/AGENTS.md"
  remove_path "$HOME/.openai/AGENTS.md"
}

uninstall_cursor() {
  echo "--- Uninstalling from Cursor ---"
  remove_path "$HOME/.cursorrules"
}

uninstall_copilot() {
  echo "--- Uninstalling from GitHub Copilot ---"
  remove_path "$HOME/.config/github-copilot/copilot-instructions.md"
}

# Main Execution Switch
if [[ "$ACTION" == "status" ]]; then
  check_status
  exit 0
fi

if [[ "$ACTION" == "uninstall" ]]; then
  case "$TARGET" in
    all)
      uninstall_antigravity
      uninstall_anthropic
      uninstall_openai
      uninstall_cursor
      uninstall_copilot
      echo ""
      echo "Done! Configuration and skills uninstalled."
      ;;
    antigravity|gemini)
      uninstall_antigravity
      echo "Done! Uninstalled Google Antigravity."
      ;;
    anthropic|claude)
      uninstall_anthropic
      echo "Done! Uninstalled Anthropic / Claude."
      ;;
    openai|codex)
      uninstall_openai
      echo "Done! Uninstalled OpenAI / Codex."
      ;;
    cursor)
      uninstall_cursor
      echo "Done! Uninstalled Cursor."
      ;;
    copilot)
      uninstall_copilot
      echo "Done! Uninstalled GitHub Copilot."
      ;;
    *)
      echo "Error: Unknown target for uninstall: '$TARGET'." >&2
      usage
      ;;
  esac
  exit 0
fi

# Default: Sync
case "$TARGET" in
  all)
    sync_antigravity
    sync_anthropic
    sync_openai
    sync_cursor
    sync_copilot
    echo ""
    echo "Done! Configuration, skills, and memory indexes synced ($MODE mode)."
    ;;
  antigravity|gemini)
    sync_antigravity
    echo "Done! Synced Google Antigravity ($MODE mode)."
    ;;
  anthropic|claude)
    sync_anthropic
    echo "Done! Synced Anthropic / Claude ($MODE mode)."
    ;;
  openai|codex)
    sync_openai
    echo "Done! Synced OpenAI / Codex ($MODE mode)."
    ;;
  cursor)
    sync_cursor
    echo "Done! Synced Cursor ($MODE mode)."
    ;;
  copilot)
    sync_copilot
    echo "Done! Synced GitHub Copilot ($MODE mode)."
    ;;
  *)
    echo "Error: Unknown target '$TARGET'." >&2
    usage
    ;;
esac
