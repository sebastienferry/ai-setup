---
name: create-pr
description: >-
  Create a concise, no-fluff Pull Request description using git diff and log.
  Focuses strictly on what changed and why, completely omitting testing narratives.
---

# Create Pull Request

Use this workflow to author or submit pull request descriptions via `gh pr create` or directly in markdown.

## Core Directives

1. **Be Extremely Concise & Direct**: No pleasantries, no conversational fillers, no lengthy background essays.
2. **Strictly Omit Testing Narratives**: Never write "How to test", "Steps to verify", "Tested with...", or screenshots unless explicitly mandated by the user.
3. **Explain Only Two Things**:
   - **Why**: The problem, bug, or feature driver (1-3 sentences).
   - **What Changed**: Bullet points of concrete code and architecture modifications.

## Procedure

1. **Inspect Git Changes**:
   - Check branch and diff:
     ```bash
     git status -s
     git diff --stat
     git log -n 5 --oneline
     ```
2. **Draft the PR**:
   - Format:
     ```markdown
     ## Summary
     <1-3 sentences stating the rationale and goal of this change.>

     ## Changes
     - <Key change 1>
     - <Key change 2>
     - <Key change 3>
     ```
3. **Submit via GitHub CLI** (if `gh` is authenticated):
   ```bash
   gh pr create --title "<type>: <short summary>" --body "<body content>"
   ```
   Or present the drafted markdown directly to the user if submitting manually.
