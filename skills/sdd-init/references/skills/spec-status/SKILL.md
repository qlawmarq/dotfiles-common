---
name: sdd-spec-status
description: >-
  Show specification status and progress for an SDD feature.
  Displays current phase, completion percentages, and next actions.
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
1. **Feature name**: The feature directory name in `docs/specs/`

Without one, point at `/sdd-brief`, the report across every spec, with dependencies, blockers, and the plan; do not ask the user which feature they meant. This skill stays focused on one spec's phase detail.

## Core Task

Generate status report for the specified feature showing progress across all phases.

## Execution Steps

### Step 0: Resolve Spec Path

**Resolve Spec Path**: `{spec_path}` is the feature directory `AGENTS.md §Paths` resolves.

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
- **Verdict** (kind `verify`): the verdict per question from the `**Verdict:**` line of each `verdict.md` question, or absent
- **Approvals**: Check approval status in spec.json; an absent approval key (such as `approvals.behaviors`) reads as `n/a`

### Step 3: Generate Report

Write the report per Output Description.

</instructions>

## Output Description

Write the report in that spec's `spec.json` `language`.

**Report Structure**:

1. **Feature Overview**: Name, kind, phase
2. **Phase Status**: Requirements, Behaviors (`n/a` when the kind does not produce behaviors), Research, Design, Tasks with completion %; for `verify`, also Verdict: the verdict per question, or absent
3. **Task Progress**: If tasks exist, show X/Y completed
4. **Next Action**: Specific command to run next
5. **Issues**: Any blockers or missing elements

**Format**: Clear, scannable format with emojis (✅/⏳/❌) for status

## Safety & Fallback

### Error Scenarios

**Spec Not Found**:

- **Message**: "No spec found for the specified feature. Check available specs in `docs/specs/todo/` and `docs/specs/done/`"
- **Action**: List available spec directories from both `docs/specs/todo/` and `docs/specs/done/`

**Incomplete Spec**:

- **Warning**: Identify which files are missing
- **Suggested Action**: Point to next phase command
