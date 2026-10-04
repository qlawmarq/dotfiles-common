# Requirements Document

## Introduction
{{INTRODUCTION}}
<!-- One or two sentences: which component misbehaves, how it was noticed, and why it matters now. -->

## Defect Ledger

<!--
One row per defect; a batch of fixes is the same table with more rows. Observed and Expected are one phrase each —
the full statement lives in the matching requirement below. Reproduction points to where it can be re-run
(`probe/<file>`, a failing test name, or the report it came from); research settles it by measurement.
-->

| ID | Observed | Expected | Reproduction |
|----|----------|----------|--------------|
| 1 | {{OBSERVED}} | {{EXPECTED}} | {{REPRODUCTION_LOCATION}} |

## Requirements

### 1: {{DEFECT_TITLE}}
<!-- One heading per ledger row, same numeric ID. -->
**Current behavior:** When {{CONDITION}}, the {{COMPONENT}} {{INCORRECT_BEHAVIOR}}
**Priority:** Must | Should | Could

#### Acceptance Criteria
<!-- Expected (the corrected behavior) uses `shall`; Unchanged (what the fix must not disturb) uses
`shall continue to` and names the test or probe that guards it. -->
1. When {{CONDITION}}, the {{COMPONENT}} shall {{CORRECT_BEHAVIOR}}
2. When {{NEIGHBORING_CONDITION}}, the {{COMPONENT}} shall continue to {{EXISTING_BEHAVIOR}} — guard: {{TEST_OR_PROBE}}

<!-- Additional defects follow the same pattern -->

## Out of Scope

Defects and improvements deliberately left out — especially ones found while diagnosing. Work outside this list is recorded in design.md §Deviations from Diagnosis.

- {{OUT_OF_SCOPE_ITEM}} — reason / where it was excluded

## Assumptions & Open Questions

Omit when nothing is open.

- **Assumption:** {{ASSUMPTION}} — impact if wrong / needs confirmation
- **Open question:** {{QUESTION}} — who/what is needed to resolve it
