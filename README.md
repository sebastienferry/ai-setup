# AI Setup & Agent Blueprint

A standardized, multi-provider configuration blueprint for autonomous AI coding agents (Google Antigravity, Anthropic Claude Code, OpenAI / Codex, Cursor, GitHub Copilot).

## Repository Overview

```text
ai-setup/
├── AGENTS.md                  # Universal agent role, protocol, and operational guardrails
├── .agents/
│   └── MEMORY.md              # Starter template for cross-session project memory
├── skills/
│   ├── create-pr/             # Concise PR generation without testing narratives
│   ├── add-decision/          # ADR management with indexed progressive disclosure (Local & Global)
│   └── add-knowledge/         # Knowledge ingestion from URL/file with triggers (Local & Global)
├── sync-agents.sh             # Single-entrypoint distribution and bootstrapping script
└── README.md
```

---

## What is Inside

### 1. `AGENTS.md` (Core Persona & Guardrails)
- **Role**: Senior Software Engineer with deep expertise in frontend, backend, on-premise and cloud architecture, high-QPS systems, and distributed computing.
- **Communication Protocol**:
  - Mandatory pre-action concise plan before non-trivial steps.
  - Standardized post-action status updates (`Done`, `Remaining (Agent)`, `Pending (User)`).
- **Language Policy**: Strictly **English-only** for all code, comments, docstrings, commits, and documentation.
- **Open Source & Licensing**: Proactive consultation on open source intent and licensing models (MIT, Apache 2.0, etc.) for new projects.
- **Git & Worktree Strategy**: Worktree-first workflow for parallel tasks and strict branch/worktree naming conventions (`<type>/<description>`).
- **Documentation Lifecycle**: Continuous maintenance of `README.md`, `CHANGELOG.md`, and `/docs`, with ADR recommendations whenever `/docs/adrs` exists.
- **Memory & Continuous Learning**: Active inspection and enrichment of `.agents/MEMORY.md`.

### 2. Custom Skills (`skills/`)
- **`create-pr`**: Generates sober, concise pull requests explaining strictly *what* changed and *why*, with zero test narrative overhead.
- **`add-decision`**: Records architectural decisions in `docs/decisions/` (Local) or `~/.gemini/config/decisions/` (Global) using a lightweight index table (`INDEX.md`) to prevent context flooding.
- **`add-knowledge`**: Ingests reference materials from URLs or local files into `docs/knowledge/` (Local) or `~/.gemini/config/knowledge/` (Global), keyed by an activation trigger for on-demand loading.

---

## Quick Start & Usage

The repository uses [sync-agents.sh](file:///Users/sferry/Sources/ai-setup/sync-agents.sh) as its single entry point.

### 1. Sync Globally to All AI Providers
Copy rules and skills to your machine's global configuration paths:
```bash
./sync-agents.sh --copy
```
Or create **symbolic links** so edits in this repository immediately reflect globally:
```bash
./sync-agents.sh --link
```

### 2. Check Installed Status
Verify which provider configurations and global skills are active:
```bash
./sync-agents.sh status
```

### 3. Bootstrap a New Project
Initialize any target repository with `AGENTS.md`, `.agents/MEMORY.md`, all skills, and local decision/knowledge indexes in one command:
```bash
./sync-agents.sh -p /path/to/my-new-project
```

### 4. Sync to a Specific Provider
```bash
./sync-agents.sh antigravity   # Google Antigravity (~/.gemini/config/)
./sync-agents.sh anthropic     # Anthropic Claude Code (~/.claude/)
./sync-agents.sh openai        # OpenAI / Codex (~/.codex/, ~/.openai/)
./sync-agents.sh cursor        # Cursor (~/.cursorrules)
./sync-agents.sh copilot       # GitHub Copilot (~/.config/github-copilot/)
```

### 5. Uninstall Rules & Skills
Remove installed files and skills from all providers:
```bash
./sync-agents.sh --uninstall
```
Or selectively uninstall from a single provider:
```bash
./sync-agents.sh --uninstall antigravity
```
Preview removals safely with dry-run:
```bash
./sync-agents.sh --uninstall --dry-run
```

---

## License

This project is licensed under the [MIT License](LICENSE).
