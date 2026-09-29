# Design Document

<!--
Assessment, staged plan and exit condition for a change to the environment, dependencies, tooling, documents or data.
research.md holds the measurements; this file holds the decisions and the stages.
-->

## Overview
{{OVERVIEW}}
<!-- Two or three sentences: the target state, the reach of the change, and how completion is judged. -->

### Assumptions
Omit when every claim this design rests on is measured.

- `<claim>` (`C<n>`) — impact: `<what fails if it is wrong>` / signpost: `<the observable sign that it has broken>`

## Design Decisions

Omit when research.md §Recommendation was empty before the move and no choice arose.

### D1: [title]
- Decision: [what was chosen] — based on `C<n>`, confidence: high | medium | low
- Rejected: [option] — [one-phrase reason] (one line per option)
- Consequences: [what this costs or forecloses, the negative included]

## Assessment

<!-- The current state as measured in research.md; cite `C<n>`, do not restate the measurement. -->

| Subject | Current | Target | Breaking changes / incompatibilities | Reach (files, components, consumers) | Guards weakened (CI, tests, coverage) | Claim |
|---------|---------|--------|--------------------------------------|--------------------------------------|---------------------------------------|-------|
| {{SUBJECT}} | {{CURRENT}} | {{TARGET}} | {{BREAKING}} | {{REACH}} | {{GUARDS_WEAKENED}} | `C<n>` |

## Plan

<!-- Start with a few files or one component, then the rest. Each stage ends at its Verify checkpoint. -->

| Stage | Change | Verify | Rollback |
|-------|--------|--------|----------|
| 1 | {{TRIAL_ON_A_FEW}} | {{CHECK}} | {{ROLLBACK}} |
| 2 | {{REMAINDER}} | {{CHECK}} | {{ROLLBACK}} |

## Unchanged

Omit when every place the change could reach is edited. Otherwise: places the change could plausibly reach that were judged to need no edit, and the evidence.

- {{PLACE}} — {{REASON}} (`C<n>`)

## Verification Plan

The exit condition — the check that decides the chore is complete — defined before stage 1 runs:

- Exit condition: {{COMMAND_OR_CHECK}} — passes when {{CONDITION}}
- Suites that must stay green: {{SUITES}}
