# Canon Index

[One paragraph: what this canon governs. This directory is the product's decision record — structure and change control per `docs/settings/rules/canon-layer.md`.]

- **Change control**: content here changes only via a delta proposal (`proposals/`) ratified in a `/sdd-canon-ratify` session. Agents never edit ratified content directly.
- **ID scheme**: decisions `D<NN>` (e.g. `D01`), registry entries `<DOMAIN>-<NN>` (e.g. `FAC-01`). IDs are immutable and never renumbered.
- **Audit**: the commands in `docs/settings/rules/ratification.md` §Grep Contract list everything the human has judged, with dates. Run them from this directory; they are not restated here by design.

## Decision Log (current view)

<!-- Derived index. Status is the bare word (draft | ratified | superseded | deprecated) — dated `ratified: … (item|batch)` markers live only in decisions/ and registry.md, so the stray sweep stays meaningful. Put the date in its own column if you want it here. -->

| ID | Decision | Status | File |
| --- | --- | --- | --- |
| D01 | [one-line title] | draft | [decisions/d01-slug.md](decisions/d01-slug.md) |

## Registry

Enumerable norms (catalogs, entity lists, guards) live in [registry.md](registry.md) — the only seat with normative force for lists. Prose decisions cite registry IDs; they never restate the lists.

## Open Questions

Gaps found mid-work are filed here (or drafted as proposals) — never resolved inline in a spec session.

| # | Question | Raised by | Date | Type |
| --- | --- | --- | --- | --- |
| Q1 | [question] | [spec/session] | YYYY-MM-DD | needs-verdict \| needs-research |

## Proposals

- In flight: see `proposals/*.md`
- Resolved (ratified, rejected, withdrawn): `proposals/archive/` — the permanent audit trail: verdict tables and final text.
