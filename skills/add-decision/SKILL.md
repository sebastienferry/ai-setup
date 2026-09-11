---
name: add-decision
description: >-
  Record or consult technical and architectural decisions at either Local (project: docs/decisions/)
  or Global (cross-project: ~/.gemini/config/decisions/) scope using lightweight indexes.
---

# Add & Consult Decisions (Local & Global)

This skill tracks architectural and technical decisions using progressive disclosure. Compact index files prevent context bloat while enabling rapid retrieval when facing doubts.

## Scopes & Storage Locations

| Scope | Location | Usage |
| :--- | :--- | :--- |
| **Local** (Default) | `<project_root>/docs/decisions/` | Project-specific architecture, tech stack choices, schema designs (versioned with git). |
| **Global** | `~/.gemini/config/decisions/` | Universal engineering preferences, cross-project standards, machine-wide architectural rules. |

Both directories use an identical layout:
```text
<scope_dir>/
├── INDEX.md                 # Lightweight summary table (always read first)
└── 001-use-postgresql.md    # Detail document per decision
```

---

## 1. Consulting Decisions (Resolving Doubts)

Whenever facing ambiguity, uncertainty about an architectural pattern, or library choice:

1. **Step 1: Check Local Decisions First**:
   - Read `docs/decisions/INDEX.md` (if present).
   - Look for matching topics in the summary table.
2. **Step 2: Check Global Decisions**:
   - If not found locally or if the choice is cross-project, read `~/.gemini/config/decisions/INDEX.md`.
3. **Step 3: Selective Loading**:
   - Only open the specific file (e.g. `docs/decisions/002-async-jobs.md`) if an entry matches. Abide by the recorded decision.

---

## 2. Adding a New Decision

When the user asks to record or formalize a decision:

1. **Clarify Scope**:
   - If specific to the current codebase -> **Local** (`docs/decisions/`).
   - If applicable across all projects on this machine -> **Global** (`~/.gemini/config/decisions/`).
   - Default to Local when inside a repository unless user specifies "globally" or "for all projects".

2. **Determine the Sequence Number**:
   - Count existing entries in `<target_dir>/` to determine `<NNN>` (e.g., `001`, `002`, `003`).

3. **Create the Decision File** (`<target_dir>/<NNN>-<slug>.md`):
   ```markdown
   # <NNN>. <Title>

   - **Scope**: Local | Global
   - **Date**: YYYY-MM-DD
   - **Status**: Proposed | Accepted | Superseded by [<NNN>](...) | Deprecated

   ## Context & Problem Statement
   <What problem are we solving? What are the constraints?>

   ## Decision
   <What are we doing and why? Outline the primary rationale.>

   ## Consequences
   - **Positive**: <Benefits gained>
   - **Negative / Trade-offs**: <Accepted drawbacks or operational costs>

   ## Rejected Alternatives
   - **<Alternative 1>**: <Why it was rejected>
   ```

4. **Update the Corresponding Index** (`<target_dir>/INDEX.md`):
   - If `INDEX.md` does not exist, initialize it with a table header:
     ```markdown
     # Architectural Decisions Index

     | ID | Date | Title | Status | Summary |
     | :--- | :--- | :--- | :--- | :--- |
     ```
   - Append the new entry:
     ```markdown
     | [<NNN>](file:///<abs_path>/<target_dir>/<NNN>-<slug>.md) | YYYY-MM-DD | <Title> | Accepted | <1-line summary> |
     ```
