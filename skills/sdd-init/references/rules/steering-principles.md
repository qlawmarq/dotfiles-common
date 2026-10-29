# Steering Principles

Steering (`docs/steering/`) is project memory: every file in it is loaded into every session. This file is the one definition of what steering holds; skills and templates name the section they apply (one fact, one seat: `document-hygiene.md`).

---

## Admission

A line belongs in steering only when all four hold:

1. **It guides future work** — a cross-cutting pattern, convention, or decision that new work must follow. Golden rule: if new code follows existing patterns, steering shouldn't need updating.
2. **No other seat holds it.** Facts owned by code, configuration, a manifest (versions, dependencies), the decision records, `docs/reference/`, `AGENTS.md`/`CLAUDE.md`, the rules in `docs/settings/`, a spec, or another steering file are not copied here; when a reader needs one, name where it lives (`document-hygiene.md`).
3. **It is not a catalog** — no file or directory listings, per-component descriptions, dependency lists, or implementation details. State the pattern and show one example.
4. **It is not history** — no dates, change reasons, or "added after …" notes (`document-hygiene.md`, one fact, one seat).

Never admitted: secrets (API keys, passwords, credentials, database URLs, internal hosts), agent-tooling directories (`.claude/`, `.cursor/`, `.gemini/`, …), and documentation of `docs/settings/` (methodology, not project knowledge). Pointing to `docs/specs/` or another steering file is fine.

**Bad** (catalog):

```markdown
- components/Button - Primary button with variants
- components/Input - Text input with validation
  ... (50+ files)
```

**Good** (pattern):

```markdown
## UI Components (`/components/ui/`)

- Named by function (Button, Input, Modal); each exposes its public interface
- No business logic
```

---

## File focus

One domain per file. A decision carries its rationale.

- **product.md**: the product's purpose, users, and main uses. Without declared decision records (`decision-records.md §Structure`), also its core capabilities, value, scope, and Out of Scope. With them, every product decision (`decision-records.md §Objective`) lives in the records; this file holds only their location, and a decision's ID where a reader needs it.
- **tech.md**: architecture, key frameworks, and the technical decisions that shape code — not versions or dependency lists.
- **structure.md**: organization patterns, directory roles, naming and import rules — not directory trees.
- **Custom files**: one specialized domain each (API, testing, security, …), under the same rules and budget as the core files.

---

## Updating

- A line whose fact changed is replaced; a line another seat now holds is deleted, or reduced to a pointer where a reader needs it (§Admission 2); any other line that fails §Admission is deleted. A line is added only when it passes §Admission. "No update needed" is the expected outcome for most changes.
- Once the decision records are declared, a product decision still written in `product.md` is moved into them under `decision-records.md §Change Control` and deleted here after that commit.
- A proposal that adds lines states the current §Budget count; if it would exceed the budget, §Budget says what to do.
- Policy — everything in `product.md` — is never derived from code, however obvious the change looks.
- A change lands by `decision-records.md §Change Control`.

---

## Budget

100-200 lines per file, and 600 lines total across `docs/steering/` — every file is loaded into every session, so the set has a budget, not just each file. Over budget, propose cuts or moving a file out of always-loaded memory; report it, never block on it.
