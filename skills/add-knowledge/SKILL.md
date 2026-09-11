---
name: add-knowledge
description: >-
  Ingest and consult technical knowledge from a web URL or local file at either Local (docs/knowledge/)
  or Global (~/.gemini/config/knowledge/) scope, using indexed triggers for on-demand progressive loading.
---

# Add & Consult Knowledge (Local & Global)

This skill maintains modular knowledge bases that capture technical learnings, documentation summaries, and operational cheat-sheets without flooding context.

## Scopes & Storage Locations

| Scope | Location | Usage |
| :--- | :--- | :--- |
| **Local** (Default) | `<project_root>/docs/knowledge/` | Codebase-specific domain concepts, internal APIs, service contracts, local setup guides. |
| **Global** | `~/.gemini/config/knowledge/` | Universal tool guides (Docker, Kubernetes, AWS, Go, React), language quirks, reusable cheat-sheets. |

Both directories use an identical layout:
```text
<scope_dir>/
├── INDEX.md            # Lightweight index with triggers and 1-line summaries
└── <topic-slug>.md     # Distilled knowledge document
```

---

## 1. Consulting Knowledge (On-Demand Loading)

When addressing a domain problem, external library integration, or specific technology:

1. **Step 1: Consult Local Knowledge**:
   - Inspect `docs/knowledge/INDEX.md` (if present).
   - Check the **Activation Trigger** column for keywords relevant to your current prompt.
2. **Step 2: Consult Global Knowledge**:
   - If not found locally, inspect `~/.gemini/config/knowledge/INDEX.md`.
3. **Step 3: Selective Ingestion**:
   - Open and read `<scope_dir>/<topic-slug>.md` **only** if the trigger matches your active task. Do not load unrelated knowledge.

---

## 2. Ingesting New Knowledge (From Web URL or Local File)

When the user asks to save, ingest, or remember knowledge from a URL or local file:

1. **Clarify Scope**:
   - If specific to this codebase -> **Local** (`docs/knowledge/`).
   - If universally applicable across projects -> **Global** (`~/.gemini/config/knowledge/`).
   - Default to Local when inside a repository unless user specifies "globally" or "for all projects".

2. **Fetch the Source Content**:
   - If a **Web URL**: Use `read_url_content` to fetch the markdown/HTML.
   - If a **Local File**: Use `view_file` to read the file.

3. **Distill into a Dedicated File** (`<target_dir>/<topic-slug>.md`):
   - Format:
     ```markdown
     # <Topic Title>

     - **Scope**: Local | Global
     - **Source**: <URL or local file path>
     - **Date Added**: YYYY-MM-DD
     - **Activation Trigger**: <Explicit keywords/scenarios describing when to load this, e.g., "Configuring CORS on Fastify">

     ## Core Takeaways & Rules
     <Synthesized principles, constraints, and operational rules>

     ## Patterns & Snippets
     ```<language>
     <Actionable code or configuration>
     ```

     ## Pitfalls & Edge Cases
     <Known traps or warnings mentioned in the source>
     ```

4. **Register in the Index** (`<target_dir>/INDEX.md`):
   - If `INDEX.md` does not exist, initialize it:
     ```markdown
     # Knowledge Base Index

     | Topic | Activation Trigger | Summary | Source |
     | :--- | :--- | :--- | :--- |
     ```
   - Append the row:
     ```markdown
     | [<Topic Title>](file:///<abs_path>/<target_dir>/<topic-slug>.md) | `<Activation Trigger>` | <1-line summary> | [Link](<source>) |
     ```
   - Keep the summary strictly to 1 line to ensure the index remains token-efficient.
