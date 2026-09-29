---
name: sdd-canon-update
description: >-
  Land a product decision or registry change in the canon outside a spec phase — a
  decision reached in conversation, a correction, a refactor of decision files. Runs the
  same "Canon changes" protocol the phase skills use; the phase skills embed it themselves.
argument-hint: "\"change description\" [--from=<spec-or-session>]"
---

# Canon Update

<background_information>

- **Mission**: Apply one canon change (concept decision, registry row, README index/open question) directly to the working tree, present it in full, and commit it as its own `docs(canon):` commit. Protocol and drafting discipline: `docs/settings/rules/canon-layer.md` — read it first; this file adds only the ad-hoc entry point.
- **When to use**: the decision did not arise inside `/sdd-plan`, `/sdd-spec-requirements`, `/sdd-spec-design`, `/sdd-spec-done`, or `/sdd-grill` (those land their own canon changes). Also the scaffolding path when no canon root exists yet.
- **Success Criteria**: changed sections shown in full before the yes; R2 items confirmed individually; standalone commit listing only the edited files; `check_canon.sh check` run and its findings reported.

</background_information>

<instructions>

## Input

1. **Change description** (positional): what should change and why — may cite a spec, a session, or a code finding.
2. **`--from=<spec-or-session>`** (optional): source pointer, written into the decision's Background sentence.

No input → list the canon README's Open Questions and ask which one to land.

## Steps

1. **Resolve the canon root** from `docs/steering/product.md §Canon References` (default `docs/canon/`). If none exists, propose scaffolding `README.md`, `decisions/`, `registry.md` from `docs/settings/templates/canon/` and the one-paragraph declaration in `product.md`; create only after the user confirms.
2. **Locate what the change touches** — grep `keywords` lines and registry IDs JIT; never bulk-load. Name the affected decision items and IDs with paths.
3. **Dirty check** each file you will edit (`git status -- <file>`); show any pre-existing uncommitted diff first.
4. **Edit the working tree** under the drafting discipline in `canon-layer.md` (merge before creating, grounds from measurement as relative links, no empty policy declarations, no exception notes when a cleaner form exists, one fact one seat, no renumbering). Update the README index for a new decision; add `Used by` entries with the fixed vocabulary.
5. **Present `## Canon changes`** at the top of the reply: per file, the full text of each changed section (modified items as *previous → new*) and a one-line reason. R2 items (overturn/delete a decision item, change/remove a registry Norm) come first as *previous → new* pairs, each with its own confirmation. Then ask once: commit?
6. **On yes**: run `bash docs/settings/scripts/check_canon.sh check` (report findings; they never block), then `git commit -m "docs(canon): <slug>" -- <edited files>`. On no: `git checkout -- <edited files>` and report what was not landed.

## Constraints

- Do NOT `git add <canon-root>` wholesale — commit only the files this session edited.
- Do NOT edit `proposals/archive/` or any directory the project marks archival.
- Do NOT invent scope: every change traces to the description, a cited gap, or a cited source.

</instructions>

## Output Description

Resolve the language from `docs/settings/templates/specs/init.json` `language` (default `ja`). Report: the Canon changes section, R2 confirmations taken, check findings, and the commit hash (or "not landed" with the reason). Concise Markdown.

## Safety & Fallback

- **No SDD setup** (`docs/settings/` missing): point to `/sdd-init` and stop.
- **Scaffold declined**: create nothing; say what was not created.
- **Change is not canon**: say so and name the right seat — steering when it passes `steering-principles.md §Admission` (`/sdd-steering`), otherwise the spec artifact, code, or configuration that owns it.
