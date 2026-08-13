# Normative Registry

<!--
The only seat of enumerable normative force (rules: docs/settings/rules/normative-registry.md).
- One domain per section, one norm per row. IDs are immutable.
- Norm / Status / Grounds change only via proposal + ratification.
- Consumers / Verification are bookkeeping — update with ordinary confirm-and-write.
-->

- **status**: active <!-- the registry file itself; entries carry their own status -->
- **ID scheme**: `<DOMAIN>-<NN>` — domains declared per section below. Never renumber.

## [Domain, e.g. Facilities] (`FAC`)

[One line: which decision(s) ground this domain, e.g. "Grounded in D12, D18."]

| ID | Norm | Status | Grounds | Verification | Consumers |
| --- | --- | --- | --- | --- | --- |
| FAC-01 | [normative statement, 1–2 lines] | draft | D12 #3 | manual | — |
| FAC-02 | [normative statement] | ratified: YYYY-MM-DD (item) | D12 #3 | [test path] | [plan row / spec / code identifier] |

## [Next Domain] (`XXX`)

| ID | Norm | Status | Grounds | Verification | Consumers |
| --- | --- | --- | --- | --- | --- |
