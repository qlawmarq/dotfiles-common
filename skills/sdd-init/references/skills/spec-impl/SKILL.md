---
name: sdd-spec-impl
description: >-
  Execute SDD spec tasks using TDD methodology.
  Implements approved tasks following Red-Green-Refactor cycle.
argument-hint: "<feature-name> [task-numbers]"
---

# Implementation Task Executor

<background_information>

- **Mission**: Execute implementation tasks using Test-Driven Development methodology based on approved specifications
- **Success Criteria**:
  - All tests written before implementation code
  - Code passes all tests with no regressions
  - Tasks marked as completed in tasks.md
  - Implementation aligns with design and requirements

</background_information>

<instructions>

## Input

This skill expects:
1. **Feature name** (required): The feature directory name in `docs/tasks/`
2. **Task numbers** (optional): Specific task numbers to execute (e.g., "1.1" or "1,2,3")

If inputs were provided with this skill invocation, use them directly.
Otherwise, ask the user for the feature name.
If task numbers are not provided, all pending tasks will be executed.

## Core Task

Execute implementation tasks for the specified feature using Test-Driven Development.

## Execution Steps

### Step 0: Resolve Spec Path

**Resolve Spec Path**: Look for the feature directory in `docs/tasks/todo/<feature-name>/` first, then `docs/tasks/done/<feature-name>/`. Use whichever exists. If neither exists, report an error.

### Step 1: Load Context

**Read all necessary context**:

- `{spec_path}/spec.json`, `requirements.md`, `design.md`, `tasks.md`
- **Entire `docs/steering/` directory** for complete project memory

**Validate approvals**:

- Verify tasks are approved in spec.json (stop if not, see Safety & Fallback)

### Step 2: Select Tasks

**Determine which tasks to execute**:

- If task numbers were provided: Execute specified task numbers (e.g., "1.1" or "1,2,3")
- Otherwise: Execute all pending tasks (unchecked `- [ ]` in tasks.md)

### Step 3: Execute with TDD

For each selected task, follow Kent Beck's TDD cycle:

1. **RED - Write Failing Test**:
   - Write test for the next small piece of functionality
   - Test should fail (code doesn't exist yet)
   - Use descriptive test names

2. **GREEN - Write Minimal Code**:
   - Implement simplest solution to make test pass
   - Focus only on making THIS test pass
   - Avoid over-engineering

3. **REFACTOR - Clean Up**:
   - Improve code structure and readability
   - Remove duplication
   - Apply design patterns where appropriate
   - Ensure all tests still pass after refactoring

4. **VERIFY - Validate Quality**:
   - All tests pass (new and existing)
   - No regressions in existing functionality
   - Code coverage maintained or improved

5. **MARK COMPLETE**:
   - Update checkbox from `- [ ]` to `- [x]` in tasks.md

## Critical Constraints

- **TDD Mandatory**: Tests MUST be written before implementation code
- **Task Scope**: Implement only what the specific task requires
- **Test Coverage**: All new code must have tests
- **No Regressions**: Existing tests must continue to pass
- **Design Alignment**: Implementation must follow design.md specifications

</instructions>

## Tool Guidance

- **Read first**: Load all context before implementation
- **Test first**: Write tests before code
- Use **WebSearch/WebFetch** for library documentation when needed

## Output Description

Provide brief summary in the language specified in spec.json:

1. **Tasks Executed**: Task numbers and test results
2. **Status**: Completed tasks marked in tasks.md, remaining tasks count

**Format**: Concise (under 150 words)

## Safety & Fallback

### Error Scenarios

**Tasks Not Approved or Missing Spec Files**:

- **Stop Execution**: All spec files must exist and tasks must be approved
- **Suggested Action**: "Complete previous phases: `/sdd-spec-requirements`, `/sdd-spec-design`, `/sdd-spec-tasks`"

**Test Failures**:

- **Stop Implementation**: Fix failing tests before continuing
- **Action**: Debug and fix, then re-run

### Task Execution

**Execute specific task(s)**:

- `/sdd-spec-impl <feature-name> 1.1` - Single task
- `/sdd-spec-impl <feature-name> 1,2,3` - Multiple tasks

**Execute all pending**:

- `/sdd-spec-impl <feature-name>` - All unchecked tasks

### After All Tasks Completed

- Optional validation: `/sdd-validate-impl <feature-name>` for mid-implementation quality check
- **Finalize feature**: `/sdd-spec-done <feature-name>` to verify quality, move spec to done, and commit
