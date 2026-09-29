# Design Document

<!--
The path from the current structure to the target while every behavior in requirements.md stays.
research.md holds the measured current structure and guard coverage; this file holds the target and the order.
-->

## Overview
{{OVERVIEW}}
<!-- Two or three sentences: what is restructured, why, and what stays fixed. -->

### Assumptions
Omit when every claim this design rests on is measured.

- `<claim>` (`C<n>`) — 影響: `<what fails if it is wrong>` / signpost: `<the observable sign that it has broken>`

## Design Decisions

Omit when research.md §Recommendation was empty before the move and no choice arose.

### D1: [title]
- Decision: [what was chosen] — based on `C<n>`
- Rejected: [option] — [one-phrase reason] (one line per option)
- Consequences: [what this costs or forecloses, the negative included]

## Current Structure

<!-- As measured in research.md (cite `C<n>`). Diagram with names and edges only. -->

Omit the diagrams when one module changes.

```mermaid
graph LR
  A[{{MODULE_A}}] --> B[{{MODULE_B}}]
```

## Target Structure

<!-- Same notation. Each moved or renamed contract is named here once; its content stays where the code puts it. -->

```mermaid
graph LR
  A[{{MODULE_A}}] --> C[{{MODULE_C}}]
```

## Migration Order

<!-- Add before removing: introduce the new seat, move callers, then delete the old one. Every step ends green. -->

| Step | Change | Green at the end of the step |
|------|--------|------------------------------|
| 1 | {{ADD_NEW}} | {{SUITES}} |
| 2 | {{MOVE_CALLERS}} | {{SUITES}} |
| 3 | {{REMOVE_OLD}} | {{SUITES}} |

## Guards

- Stay green unchanged: suites not already named in §Migration Order — {{SUITES_OR_TESTS}}
- Expected to change: {{TEST}} — {{REASON}} <!-- a test that pins structure, not behavior; drop the line when there is none -->

## Verification Plan

Suites too slow to run at every step of §Migration Order and the point at which they run, plus the final full run before done. Test names live in §Guards and on the requirement criteria.
