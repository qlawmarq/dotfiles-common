---
name: sdd-spec-status
description: >-
  Show specification status and progress for an SDD feature.
  Displays current phase, completion percentages, and next actions.
argument-hint: "[feature-name]"
---

# Specification Status

<background_information>

- **Mission**: Display comprehensive status and progress for a specification
- **Success Criteria**:
  - Show current phase and completion status
  - Identify next actions and blockers
  - Provide clear visibility into progress

</background_information>

<instructions>

## Input

This skill expects:
1. **Feature name** (optional): The feature directory name in `docs/tasks/`

- **With a feature name** → the detailed single-spec report described below.
- **Without one** → list every spec in `docs/tasks/todo/` and `docs/tasks/done/` with its phase and task progress. Do not ask the user which feature they meant; the list is the answer.

For a cross-spec view that also covers dependencies, blockers, and the inception plan, use `/sdd-brief` — this skill stays focused on one spec's phase detail.

## Core Task

Generate status report for the specified feature showing progress across all phases.

## Execution Steps

Steps 0–3 below produce the single-spec report. **If no feature name was given, skip all of them** and produce the list described under "List All Specs" in Safety & Fallback instead.

### Step 0: Resolve Spec Path

**Resolve Spec Path**: Look for the feature directory in `docs/tasks/todo/<feature-name>/` first, then `docs/tasks/done/<feature-name>/`. Use whichever exists. If neither exists, report an error.

### Step 1: Load Spec Context

- Read `{spec_path}/spec.json` for metadata, `kind`, and phase status
- Read existing files: `requirements.md`, `behaviors.md`, `design.md`, `tasks.md`, `verdict.md` (if they exist)
- Check `{spec_path}/` directory for available files

### Step 2: Analyze Status

**Parse each phase**:

- **Requirements**: Count requirements and acceptance criteria
- **Behaviors**: Check if `behaviors.md` exists (absent in legacy specs — not a defect); count scenarios, and how many `Verification:` pointers name evidence and how many are still `planned:` (`behavior-formulation.md §Verification Mapping`); the `user` scenarios this spec still lacks a record for are this spec's lines of `bash docs/settings/scripts/check_completion.sh outstanding`; `n/a` when the kind does not produce behaviors (`spec-kinds.md` §4)
- **Research**: Check if `research.md` exists (✅ completed / ⏳ pending)
- **Design**: Check that the sections of the kind's design template are present (`spec-kinds.md` §4)
- **Tasks**: Count completed vs total tasks (parse `- [x]` vs `- [ ]`). Implementation progress comes from these checkboxes, not from `phase`; when every task of a spec in `todo/` is `[x]`, the next action is `/sdd-spec-done <feature-name>`
- **Verdict** (kind `verify`): the verdict per question from `verdict.md` §Summary, or absent
- **Approvals**: Check approval status in spec.json; an absent approval key (such as `approvals.behaviors`) reads as `n/a`

### Step 3: Generate Report

Create report in the language specified in spec.json covering:

1. **Current Phase & Progress**: Where the spec is in the workflow
2. **Completion Status**: Percentage complete for each phase
3. **Task Breakdown**: If tasks exist, show completed/remaining counts
4. **Next Actions**: What needs to be done next
5. **Blockers**: Any issues preventing progress

## Critical Constraints

- Use language from spec.json
- Calculate accurate completion percentages
- Identify specific next action commands

</instructions>

## Tool Guidance

- **Read**: Load spec.json first, then other spec files as needed
- **Parse carefully**: Extract completion data from tasks.md checkboxes
- Use file search tools to check which spec files exist

## Output Description

Provide the report in the language specified in that spec's `spec.json`. In list mode there is no single spec.json — use `docs/settings/templates/specs/init.json` `language`, else `ja`.

**Report Structure**:

1. **Feature Overview**: Name, kind, phase, last updated
2. **Phase Status**: Requirements, Behaviors (`n/a` when the kind does not produce behaviors), Research, Design, Tasks with completion %; for `verify`, also Verdict: the verdict per question, or absent
3. **Task Progress**: If tasks exist, show X/Y completed
4. **Next Action**: Specific command to run next
5. **Issues**: Any blockers or missing elements

**Format**: Clear, scannable format with emojis (✅/⏳/❌) for status

## Safety & Fallback

### Error Scenarios

**Spec Not Found**:

- **Message**: "No spec found for the specified feature. Check available specs in `docs/tasks/todo/` and `docs/tasks/done/`"
- **Action**: List available spec directories from both `docs/tasks/todo/` and `docs/tasks/done/`

**Incomplete Spec**:

- **Warning**: Identify which files are missing
- **Suggested Action**: Point to next phase command

### List All Specs

When invoked with no feature name, read every `spec.json` under `docs/tasks/todo/` and `docs/tasks/done/` (they are small — read them all) and report one row per spec: feature name, kind, `phase`, approval state, and — where `tasks.md` exists — completed/total task counts. Sort `todo/` before `done/`. Then list the `user` scenarios whose record does not exist yet, from `bash docs/settings/scripts/check_completion.sh outstanding` — do not read the behaviors files for them.

If no specs exist at all, say so and point at `/sdd-plan` (large effort) or `/sdd-spec-init` (single feature).
