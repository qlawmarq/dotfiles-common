# Steering Principles

Steering (`docs/steering/`) is project memory: every file in it is loaded into every session. This file is the one definition of what steering holds and how it changes; skills and templates name the section they apply (one fact, one seat: `document-hygiene.md`).

---

## Admission

A line belongs in steering only when all four hold:

1. **It guides future work** — a cross-cutting pattern, convention, or decision that new work must follow. Golden rule: if new code follows existing patterns, steering shouldn't need updating.
2. **No other seat holds it.** Facts owned by code, configuration, a manifest (versions, dependencies), the canon, `AGENTS.md`/`CLAUDE.md`, the rules in `docs/settings/`, a spec, or another steering file are not copied here; when a reader needs one, name where it lives (`document-hygiene.md`).
3. **It is not a catalog** — no file or directory listings, per-component descriptions, dependency lists, or implementation details. State the pattern and show one example.
4. **It is not history** — no dates, change reasons, or "added after …" notes (`document-hygiene.md`, one fact, one seat).

Never admitted: secrets (API keys, passwords, credentials, database URLs, internal hosts), agent-tooling directories (`.claude/`, `.cursor/`, `.gemini/`, …), and documentation of `docs/settings/` (methodology, not project knowledge). Pointing to `docs/tasks/` or another steering file is fine.

**Bad** (catalog):

```markdown
- /components/Button.tsx - Primary button with variants
- /components/Input.tsx - Text input with validation
  ... (50+ files)
```

**Good** (pattern):

```markdown
## UI Components (`/components/ui/`)

- Named by function (Button, Input, Modal); export the component and its props type
- No business logic
```

---

## File focus

One domain per file. A decision carries its rationale.

- **product.md**: purpose, users, target use cases, core capabilities, value, scope, and Out of Scope when the product keeps one; where the canon lives, when one exists (its location, never its contents).
- **tech.md**: architecture, key frameworks, and the technical decisions that shape code — not versions or dependency lists.
- **structure.md**: organization patterns, directory roles, naming and import rules — not directory trees.
- **behaviors.md**: cross-spec behavior invariants, one line each: `statement — Grounds: <citation> / Verify: <test or probe>`. An invariant from a spec is promoted only when it is **product-level** (the product's purpose or philosophy, not an implementation detail), **cross-spec** (a future spec could plausibly violate it), and **verified** (its evidence exists). Scenario bodies stay in the spec and the test suite.
- **Custom files**: one specialized domain each (API, testing, security, …), under the same rules and budget as the core files.

---

## Updating

- A line whose fact changed is replaced; a line another seat now holds is deleted, or reduced to a pointer where a reader needs it (§Admission 2); any other line that fails §Admission is deleted. A line is added only when it passes §Admission. "No update needed" is the expected outcome for most changes.
- A proposal that adds lines states the current §Budget count; if it would exceed the budget, §Budget says what to do.
- Facts derived from code (`tech.md`, `structure.md`) are shown as one diff and confirmed together. Policy — everything in `product.md`, plus the `behaviors.md` invariants — is never derived from code, however obvious the change looks: present it one item at a time, each with its grounds, and get an answer for each.
- Nothing is written before the user confirms. Confirmed edits land in their own `docs(steering):` commit, never bundled with another commit.
- A section the user wrote is not removed or rewritten without asking.
- A confirmed change is carried down by `document-hygiene.md §After a Change`.

---

## Budget

100-200 lines per file, and 600 lines total across `docs/steering/` — every file is loaded into every session, so the set has a budget, not just each file. Over budget, propose cuts or moving a file out of always-loaded memory into JIT reference; report it, never block on it.
