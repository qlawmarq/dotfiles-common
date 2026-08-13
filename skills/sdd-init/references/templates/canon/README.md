# Canon Index

[One paragraph: what this canon governs. This directory is the product's decision record — structure and change control per `docs/settings/rules/canon-layer.md`.]

- **Change control**: content here changes only via a delta proposal (`proposals/`) ratified in a `/sdd-ratify` session. Agents never edit ratified content directly.
- **ID scheme**: decisions `D<NN>` (e.g. `D01`), registry entries `<DOMAIN>-<NN>` (e.g. `FAC-01`). IDs are immutable and never renumbered.
- **Audit**: the two anchored commands in `docs/settings/rules/ratification.md` §Grep Contract list everything the human has judged, with dates. Run them from this directory.

## Decision Log (current view)

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
- Resolved (ratified, rejected, withdrawn): `proposals/archive/` — the permanent audit trail, including verbatim session Q&A.
