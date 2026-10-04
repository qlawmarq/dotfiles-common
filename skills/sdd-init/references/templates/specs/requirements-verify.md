# Requirements Document

## Introduction
{{INTRODUCTION}}
<!-- One or two sentences: what decision waits on these answers, and who acts on the verdict.
The deliverable is verdict.md (`docs/settings/rules/spec-kinds.md`). -->

## Questions

<!-- One heading per question. The criteria are verdict rules (`docs/settings/rules/ears-format.md` §Subject Selection Guidelines; verdict words: `docs/settings/rules/spec-kinds.md` §6). -->

### 1: {{QUESTION}}
**Priority:** Must | Should | Could

#### Acceptance Criteria
1. When {{OBSERVATION_ACROSS_RUNS}}, the verdict for question 1 shall be holds
2. When {{OBSERVATION_ACROSS_RUNS}}, the verdict for question 1 shall be partial
3. When {{OBSERVATION_ACROSS_RUNS}}, the verdict for question 1 shall be fails
4. If {{RECORDED_ITEM}} could not be observed, then the verdict for question 1 shall be unmeasured

<!-- Additional questions follow the same pattern -->

## Recorded Items

<!-- What every run records, so each verdict rule above can be evaluated from the records alone. -->

| Item | Unit / form | Used by |
|------|-------------|---------|
| {{ITEM}} | {{UNIT}} | {{CRITERION_IDS}} |

## Budget

Upper bounds; the run plan inside them is decided in design.md §Protocol.

- Runs: at most {{N}}
- Wall-clock time: at most {{DURATION}}
- Cost: at most {{COST}}

## Out of Scope

Questions and product changes deliberately left out. A defect found during the runs goes to verdict.md §Deviations and Incidental Findings.

- {{OUT_OF_SCOPE_ITEM}} — reason / where it was excluded

## Assumptions & Open Questions

Omit when nothing is open.

- **Assumption:** {{ASSUMPTION}} — impact if wrong / needs confirmation
- **Open question:** {{QUESTION}} — who/what is needed to resolve it
