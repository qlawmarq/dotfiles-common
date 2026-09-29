# Design Document

<!--
The protocol that answers the questions in requirements.md; the runs, records and verdicts are the work.
Verdict vocabulary and the over-claim rule: docs/settings/rules/spec-kinds.md.
-->

## Overview
{{OVERVIEW}}
<!-- Two or three sentences: the questions, the environment the runs use, and what is left untouched. -->

### Assumptions
Omit when every claim this design rests on is measured.

- `<claim>` (`C<n>`) — impact: `<what fails if it is wrong>` / signpost: `<the observable sign that it has broken>`

## Design Decisions

Omit when research.md §Recommendation was empty before the move and no choice arose.

### D1: [title]
- Decision: [what was chosen] — based on `C<n>`
- Rejected: [option] — [one-phrase reason] (one line per option)
- Consequences: [what this costs or forecloses, the negative included]

## Protocol

### Runs

| Run set | Configuration | Length | Input / random state | Trials | Aggregation | Questions |
|---------|---------------|--------|--------------|--------|-------------|-----------|
| R1 | {{CONFIG}} | {{LENGTH}} | {{INPUT_OR_RANDOM_STATE}} | {{K}} | pass@k \| pass^k | {{QUESTION_IDS}} |

<!-- Nondeterministic runs need several trials; state whether one success (pass@k) or every trial (pass^k) counts.
The total stays within requirements.md §Budget. -->

### Procedure
1. {{STEP}} <!-- one run, start to finish, executable by someone who has read only this section -->

### Record Template

```
run: {{RUN_ID}}   configuration: {{CONFIG}}   trial: {{N}}
{{RECORDED_ITEM}}: <value>
notes: <anything unexpected, verbatim>
```

<!-- Carries every item in requirements.md §Recorded Items. -->

### Judgment
1. Collect the records for each question.
2. Apply the verdict rules in requirements.md §Questions; the rule that matches decides.
3. {{TIE_BREAK_OR_BORDERLINE_HANDLING}}

A second reviewer given the same records reaches the same verdict; where they would not, the rule is sharpened before the runs start.

### Evidence Layout

- `probe/README.md` — index: file → run → what it shows → question
- `probe/{{RUN_ID}}/` — raw records and logs per run

## Verification Plan

One dry run of §Procedure before the run sets start: it confirms the procedure executes, the record template captures every item, and one run costs what research measured. The dry run's record goes to `probe/` and counts toward no verdict.
