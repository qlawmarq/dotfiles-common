# Implementation Plan

<!--
Tasks for a verify spec are preparation, runs with their records, and judgment — per design.md §Protocol.
When a session of the user's could settle a Must question, that session is the first task (`docs/settings/rules/spec-kinds.md` §6).
A helper script lives in `probe/`.
-->

## Task Format Template

<!-- The user's session, only when it could settle a Must question; Preparation and the rest follow it -->
- [ ] 1. {{USER_SESSION}}
  - what the user does with the running product, and the question; the user's record to `probe/{{RUN_ID}}/`
  - _Requirements: {{CRITERION_IDS}}_

<!-- Preparation -->
- [ ] {{MAJOR_NUMBER}}. {{PREPARATION}}
  - {{DETAIL_ITEM}} *(environment, inputs, the dry run of design §Verification Plan)*
  - _Requirements: {{CRITERION_IDS}}_

<!-- Runs and records -->
- [ ] {{MAJOR_NUMBER}}. Run set {{RUN_SET_ID}}
- [ ] {{MAJOR_NUMBER}}.{{SUB_NUMBER}}{{PARALLEL_MARK}} {{RUN_OR_BATCH_OF_RUNS}}
  - per design §Runs {{RUN_SET_ID}}; records to `probe/{{RUN_ID}}/`
  - _Requirements: {{CRITERION_IDS}}_

<!-- Judgment -->
- [ ] {{NUMBER}}. Judge each question and write verdict.md
  - per design §Judgment
  - _Requirements: {{CRITERION_IDS}}_

> **Parallel marker**: only on runs that share no environment or input; placement and `--sequential`: see `docs/settings/rules/tasks-parallel-analysis.md`.
