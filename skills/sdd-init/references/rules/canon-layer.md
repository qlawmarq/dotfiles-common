# Canon Layer

## Objective

Define the standard structure and change control for a project's **canon layer** — the durable decision documents that record what the product *is*: its concept, philosophy, and the normative decisions that every spec must respect. The layer is optional; a small project whose whole philosophy fits in `docs/steering/product.md` does not need it. When it exists, this rule governs it.

Why a defined structure matters: it makes *what the human has actually ratified* a structural, grep-able property of the documents rather than a memory. The failure this prevents is stated once, in `ratification.md §Objective`.

## Location and Declaration

- Default root: `docs/canon/`. Any name is allowed — the root is **declared** in `docs/steering/product.md §Canon References`, and every SDD skill resolves it from there. Never hardcode the path.
- Scaffolding: `/sdd-canon-propose` creates the structure from `docs/settings/templates/canon/` on first use, with user confirmation.

## Structure

```
<canon-root>/
  README.md        # index: decision log (current-view table), ID scheme, open questions
  decisions/       # prose layer — one file per decision topic (template: canon/decision.md)
  registry.md      # normative registry — sole seat of enumerable norms (rules: normative-registry.md)
  proposals/       # delta proposals awaiting ratification (template: canon/proposal.md)
    archive/       # resolved proposals, date-prefixed — the permanent audit trail
```

## Two Layers: Prose and Registry

- **Prose** (`decisions/`) holds the *why*: background, rationale, trade-offs, the reasoning behind guards. It is the reference layer.
- **Registry** (`registry.md`) holds the *what*: every enumerable norm — catalogs, entity lists, type enumerations, guard lists — one entry each.
- **Structural rule**: enumerable normative content lives **only** in the registry. Prose refers to entries by registry ID and never copies the list. A list is one place in the world; a copy is a future contradiction.

## Authority

- **Only `ratified` content binds specs.** `draft` content has no canonical force, no matter how polished it reads — polish is what AI drafts are best at, which is exactly why status, not prose quality, is the test.
- For enumerable norms, the registry is authoritative. If prose and registry disagree, the registry wins; flag the disagreement itself as a finding.
- Status vocabulary: `docs/settings/rules/ratification.md`.

## Immutability and Supersession

Ratified content is immutable. A change is never an edit in place:

- A new proposal supersedes the old item; both carry the cross-reference (`superseded-by:` on the old, the ratified date on the new). Git history is not a substitute — the current view must show its own lineage.
- Documents keep the **current-view discipline**: each file states what is in force now; the archive of proposals holds how it got that way.

## Change Control — the Only Write Path

- **Agents never edit canon-root content directly.** Not in spec sessions, not in dialogue sessions, not in steering sync. This includes "harmless" edits — wording, formatting, reordering — because edit access is how unratified content leaks into ratified files.
- Every change enters as a **delta proposal**: `proposals/YYYY-MM-DD-<slug>.md`, drafted freely by agent or human (`/sdd-canon-propose`). A proposal states `ADDED / MODIFIED / REMOVED` items against the current ratified state; a MODIFIED item restates the entire item with its previous value noted.
- A proposal gains force **only** through a ratification session (`/sdd-ratify`, protocol in `ratification.md`). On ratification: deltas merge into `decisions/` and `registry.md`, statuses update, and the proposal — with its verdict stream and Q&A preserved verbatim — moves to `proposals/archive/`.
- Rejected and withdrawn proposals archive too. What was declined, and why, is part of the audit trail.
- A gap discovered mid-spec (missing decision, canon-vs-implementation divergence) is **filed as an open question in the canon README, or drafted as a proposal — never resolved inline**. The spec works around it or waits.

## Relation to Steering

- `docs/steering/product.md` remains the always-loaded baseline. It summarizes the product and **points** to the canon; it never duplicates normative lists.
- Steering itself is outside the ratification path (`ratification.md §Scope`) — it changes by ordinary present-diff-and-confirm. Normative *force* lives in the canon layer; steering points at it.
