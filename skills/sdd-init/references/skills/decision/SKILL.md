---
name: sdd-decision
description: >-
  Land a product decision or registry change in the decision records outside a spec phase — a
  decision reached in conversation, a correction, a refactor of decision files. Runs the
  same protocol the phase skills follow, `decision-records.md §Change Control`.
---

# Decision Update

<background_information>

- **Mission**: Land one decision change (product decision, registry row, README index/open question) by `docs/settings/rules/decision-records.md §Change Control` — read that file first; this file adds only the ad-hoc entry point.
- **When to use**: the decision did not arise inside `/sdd-plan`, `/sdd-spec-requirements`, `/sdd-spec-design`, `/sdd-spec-done`, or `/sdd-grill` (those land their own decision changes).

</background_information>

<instructions>

## Input

1. **Change description** (positional): what should change and why — may cite a spec, a session, or a code finding.
2. **`--from=<spec-or-session>`** (optional): source pointer, written into the decision's Background sentence.

No input → list the decisions README's Open Questions and ask which one to land.

## Steps

1. **Resolve the decisions root** (`decision-records.md §Structure`).
2. **Locate what the change touches** — grep `keywords` lines and registry IDs (`decision-records.md §Loading`). Name the affected decision items and IDs with paths.
3. **Land it by `decision-records.md §Change Control`**, drafting under its §Drafting Discipline. Before the commit, run `bash docs/settings/scripts/check_decisions.sh check` and report its findings; they never block. The commit is `docs(decisions): <slug>`.

</instructions>

## Output Description

Resolve the language from `docs/settings/templates/specs/init.json` `language`. Report: the `decision-records.md §Change Control` report and the check findings. Concise Markdown.

## Safety & Fallback

- **No SDD setup** (`docs/settings/` missing): point to `/sdd-init` and stop.
- **Change is not a decision record**: say so and name the right seat — steering when it passes `steering-principles.md §Admission` (`/sdd-steering`), otherwise the spec artifact, code, or configuration that owns it.
