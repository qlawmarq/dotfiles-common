# Verdict

<!-- The deliverable of a verify spec. Vocabulary and the over-claim rule: docs/settings/rules/spec-kinds.md.
Raw records stay in probe/; this file cites them and never copies them. -->

## Summary

| Question | Verdict |
|----------|---------|
| 1 | holds \| partial \| fails \| unmeasured |

## Question 1: {{QUESTION}}

- **Verdict:** holds | partial | fails | unmeasured
- **Evidence:** `probe/{{PATH}}` — {{RUNS}} runs × {{K}} trials, {{AGGREGATION}}
- **Reasoning:** {{ONE_TO_THREE_SENTENCES}} <!-- which verdict rule matched, and on which records -->

### Residual Risks
Omit when the evidence leaves nothing open.

- {{RISK}}

### Unmeasured
Omit when every recorded item was observed.

- {{WHAT_WAS_NOT_MEASURED}} — would be measurable with {{WHAT_IT_WOULD_TAKE}}

<!-- Additional questions follow the same pattern -->

## Deviations and Incidental Findings

Omit when the runs followed design.md §Protocol exactly and nothing incidental was found. A defect found during the runs is listed here and goes to its own spec.

- {{DEVIATION}} — effect on the verdict for question {{N}}
