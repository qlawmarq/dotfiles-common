---
name: sdd-spec-tasks
description: >-
  Generate implementation tasks for an SDD specification.
  Translates technical design into executable, properly-sized work items.
---

# Implementation Tasks Generator

<background_information>

- **Mission**: Generate detailed, actionable implementation tasks that translate technical design into executable work items
- **Success Criteria**:
  - All requirements mapped to specific tasks
  - Tasks properly sized
  - Clear task progression with proper hierarchy
  - Natural language descriptions focused on capabilities

</background_information>

<instructions>

## Input

This skill expects:
1. **Feature name** (required): The feature directory name in `docs/tasks/`
2. **Auto-approve flag** (optional): `-y` to auto-approve the previous phases
3. **Sequential flag** (optional): `--sequential` to disable parallel task markers

If inputs were provided with this skill invocation, use them directly.
Otherwise, ask the user for the feature name.
If the auto-approve flag is not provided, default to interactive approval mode.
If the sequential flag is not provided, default to parallel-aware mode.

## Core Task

Generate implementation tasks for the specified feature based on approved requirements and design.

## Execution Steps

### Step 0: Resolve Spec Path

**Resolve Spec Path**: Look for the feature directory in `docs/tasks/todo/<feature-name>/` first, then `docs/tasks/done/<feature-name>/`. Use whichever exists. If neither exists, report an error.

### Step 1: Load Context

**Read all necessary context**:

- `{spec_path}/spec.json`, `requirements.md`, `design.md` (read `kind` from spec.json)
- `{spec_path}/behaviors.md` (if exists) for scenario verification needs
- `{spec_path}/tasks.md` (if exists, for merge mode)
- The entire `docs/steering/` directory

**Validate approvals**:

- If auto-approve flag was provided: Auto-approve requirements and design in spec.json
- Otherwise: Verify both approved (stop if not, see Safety & Fallback)
- Requirement IDs: `docs/settings/rules/ears-format.md` §Requirement IDs; stop if requirements.md does not have them.
- Determine sequential mode based on presence of `--sequential`

### Step 2: Generate Implementation Tasks

**Load generation rules and template**:

- Read `docs/settings/rules/tasks-generation.md` for principles and `docs/settings/rules/document-hygiene.md`
- If `sequential` is **false**: Read `docs/settings/rules/tasks-parallel-analysis.md` for parallel judgement criteria
- Read the kind's tasks template (`docs/settings/rules/spec-kinds.md` §4) as a format reference only; copy none of its content into the output — no `{{PLACEHOLDER}}` macros (e.g. `{{NUMBER}}`, `{{TASK_DESCRIPTION}}`), no `## Task Format Template` heading, no blockquote annotations.

**Output structure**: The generated `tasks.md` must start with `# Implementation Plan`, followed by `## Tasks` containing only the generated task list. No template sections, placeholders, or formatting examples.

**Generate task list following all rules**:

- `fix`: the first task per root cause is its Regression Guard, with a detail bullet that its failing run is recorded in `probe/` before the code changes (an exception to TDD test deduplication); tasks are grouped by root cause, not by ledger row
- If `behaviors.md` exists: cover every scenario's `Verification:` as its tier's Produced by column in `docs/settings/rules/behavior-formulation.md §Verification Mapping` says; a `user` scenario gets no task. Do not leave any scenario unverified
- Ensure all design components included
- If existing tasks.md found, merge with new content

### Step 3: Finalize

**Write and update**:

- Create/update `{spec_path}/tasks.md`
- Update spec.json metadata:
  - Set `phase: "tasks-generated"`
  - Set `approvals.tasks.generated: true, approved: false`
  - Set `approvals.requirements.approved: true`
  - Set `approvals.design.approved: true`

</instructions>

## Output Description

Write tasks.md and this summary in spec.json `language`:

1. **Status**: Confirm tasks generated at `{spec_path}/tasks.md`
2. **Task Summary**:
   - Total: X major tasks, Y sub-tasks
   - All Z requirements covered
3. **Quality Validation**:
   - All requirements mapped to tasks
   - Task dependencies verified
   - Testing tasks included
4. **Next Action**: Review tasks and proceed when ready

**Format**: Concise (under 200 words)

## Safety & Fallback

### Error Scenarios

**Requirements or Design Not Approved**:

- **Stop Execution**: Cannot proceed without approved requirements and design
- **User Message**: "Requirements and design must be approved before task generation"
- **Suggested Action**: "Run `/sdd-spec-tasks <feature-name> -y` to auto-approve both and proceed"

**Missing Requirements or Design**:

- **Stop Execution**: Both documents must exist
- **User Message**: "Missing requirements.md or design.md at `{spec_path}/`"
- **Suggested Action**: "Complete requirements and design phases first"

**Incomplete Requirements Coverage**:

- **Warning**: "Not all requirements mapped to tasks. Review coverage."
- **User Action Required**: Confirm intentional gaps or regenerate tasks

**Template/Rules Missing**:

- **User Message**: "Template or rules files missing in `docs/settings/`"
- **Fallback**: Use inline basic structure with warning
- **Suggested Action**: "Check repository setup or restore template files"

### Next Phase: Implementation

**Before Starting Implementation**:

- Start `/sdd-spec-impl` in a cleared context — for the first task and each time you switch tasks — so each task starts from a clean state.

**If Tasks Approved**:

- Execute specific task: `/sdd-spec-impl <feature-name> 1.1`
- Execute multiple tasks: `/sdd-spec-impl <feature-name> 1.1,1.2`
- Without arguments: `/sdd-spec-impl <feature-name>` (runs every pending task; not recommended, the context grows with each)

**If Modifications Needed**:

- Provide feedback and re-run `/sdd-spec-tasks <feature-name>`
- Existing tasks used as reference (merge mode)

**Note**: The implementation phase will guide you through executing tasks with appropriate context and validation.
