# Normative Registry

## Objective

Give every **enumerable norm** — catalogs, entity lists, type enumerations, guard lists — exactly one seat: `registry.md` at the canon root. Two problems die here:

- **Multi-seat drift**: the same catalog living in canon prose, a downstream plan, and a code enum, with no mechanism keeping them equal. Three copies is three versions.
- **Audit cost**: "what are all the norms currently in force, and which did I actually ratify?" must be answerable by scanning one file in minutes, not by re-reading prose for a day.

## Authority

Enumerable normative force lives **only** in the registry:

- Prose decisions explain *why* and cite entries by ID — they never restate the list. When registering a norm out of prose, **move it, don't copy it**: replace the prose enumeration with a registry reference. Leaving the copy behind recreates the drift this rule exists to kill.
- Downstream plans (inception, greybox-type documents) reference IDs and appear in the entry's Consumers column — they hold no catalog of their own.
- Code identifiers (enums, const catalogs) conform to the registry; the entry's Verification column names what enforces that.
- An enumerable normative list found anywhere else is either a reference (fine) or a violation — flag it as a **Warning** finding with the registration path, non-blocking.

## Schema

One file, `<canon-root>/registry.md` (template: `docs/settings/templates/canon/registry.md`). One section per domain; one entry per table row:

```
| ID | Norm | Status | Grounds | Verification | Consumers |
```

- **ID** — immutable public identifier, `<DOMAIN>-<NN>` (e.g. `FAC-01`); scheme declared in the canon README. Never renumber; a retired ID stays retired.
- **Norm** — the normative statement, 1–2 lines. Longer means it is prose, not a registry entry — it belongs in `decisions/` with a registry entry pointing at it.
- **Status** — `draft` / `ratified: YYYY-MM-DD (item|batch)` / `superseded-by: <ID>` / `deprecated` (vocabulary: `ratification.md`). The granularity marker is part of the status, not decoration: it records whether the human judged this entry on its own (`item`) or within an approved section (`batch`).
- **Grounds** — the prose decision this norm derives from (decision ID). An entry with no grounds is a floating norm — it carries the `floating` high-risk flag at ratification by definition.
- **Verification** — what enforces conformance: a test path, a lint rule, or `manual`. A norm nothing enforces is a hope, not a norm — `manual` is honest and acceptable; blank is not.
- **Consumers** — who has adopted it: plan rows, spec names, code identifiers (e.g. `greybox-plan P1-24`, `game/sim/spot.gd Spot.Kind`). This column is what makes impact analysis and reverse-orphan detection possible.

## Change Control

- **Norm, Status, Grounds** columns change only via proposal + ratification (`canon-layer.md §Change Control`). Registry entries are canon.
- **Consumers and Verification** are bookkeeping — they record adoption facts, not judgment. Update them directly with an ordinary present-diff-and-confirm; do not route them through ratification.

## Staged Adoption

Registry-first applies to catalogs and entity-like enumerations. Philosophical decisions that function as prose stay in `decisions/` with status vocabulary only — registrifying all prose is over-engineering, and the registry's value depends on staying scannable. When a registry outgrows one file (hundreds of entries), split by domain under `<canon-root>/registry/` and keep `registry.md` as the index.

## Cross-Check (read-only, non-blocking)

Run at `/sdd-spec-done` (after completion, alongside steering sync) or on demand. Diff three seats in **both directions** — the reverse direction is the one that historically goes unwatched:

1. **Registry → downstream**: every Consumer listed still exists and still references the ID. Ratified entries with an empty Consumers column are unadopted norms — report them.
2. **Downstream → registry**: identifiers in plans and code catalogs (enums, const tables) that have **no registry seat** — an implementation entity the canon never seated is exactly how unratified content ships. Report as orphans.
3. **Registry ↔ registry**: entries whose Grounds decision is superseded or missing.

Findings route, never auto-fix:

- Stale Consumers/Verification cells → bookkeeping update, confirm-and-write.
- Orphans and contradictions → an open question in the canon README, or a delta proposal — **never** silently adopted, deleted, or "fixed" in place. Whether an orphan becomes canon or gets removed is a human verdict.
- The check never blocks completion. It reports; the human routes.
