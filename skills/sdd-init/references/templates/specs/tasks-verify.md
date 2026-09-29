# Implementation Plan

<!--
Tasks for a verify spec are preparation, runs with their records, and judgment — per design.md §Protocol.
A helper script lives in `probe/`. `_Requirements:` lists the question's criterion IDs.
-->

## Task Format Template

<!-- Preparation -->
- [ ] 1. {{PREPARATION}}
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

> **Parallel marker**: Put ` (P)` right after the task number (`- [ ] 2.1 (P) …`) only on runs that share no environment or input. Omit the marker when running in `--sequential` mode.
