# Design Document

<!--
Diagnosis and repair for the defects in requirements.md. research.md holds the reproduction and the
measurements; this file holds the cause, the change and the guard. Kind rules: docs/settings/rules/spec-kinds.md.
-->

## Overview
{{OVERVIEW}}
<!-- Two or three sentences: the defects, the components touched, and the shape of the repair. -->

### Assumptions
Omit when every claim this design rests on is measured.

- `<claim>` (`C<n>`) — 影響: `<what fails if it is wrong>` / signpost: `<the observable sign that it has broken>`

## Design Decisions

Omit when research.md §Recommendation was empty before the move and no choice arose.

### D1: [title]
- Decision: [what was chosen] — based on `C<n>`
- Rejected: [option] — [one-phrase reason] (one line per option)
- Consequences: [what this costs or forecloses, the negative included]

## Repairs

<!-- One block per root cause. Defects sharing a cause share a block; list their requirement IDs. -->

### Root Cause 1: {{CAUSE_TITLE}}
**Defects:** {{REQUIREMENT_IDS}}

**Root Cause**
- {{CAUSE_STATEMENT}} — `C<n>`, confidence: high | medium | low

**Fix**
- Touches: {{COMPONENT_OR_CONTRACT}}
- Contract after the fix: {{CONTRACT}} <!-- the only seat of the changed contract; everything else names it; omit the line when the contract does not change -->

**Regression Guard**
- {{TEST_NAME}} — fails before the fix, passes after; covers {{CRITERION_IDS}}

**Deviations from Diagnosis**
Omit when the repair matched the diagnosis. Otherwise: what differed and the evidence. Work beyond the ledger is recorded here and left to a new spec, never silently added.

- {{DEVIATION}} — evidence: {{PROBE_OR_TEST}}

<!-- Additional root causes follow the same pattern -->

## Verification Plan

The regression suites that must stay green, and the re-run of each reproduction from the Defect Ledger after the fix. A fix whose original reproduction was not re-run is not complete. Test names live in §Repairs, not here.

- Suites: {{SUITES}}
- Reproductions re-run: {{LEDGER_IDS}} — result recorded in `probe/`
