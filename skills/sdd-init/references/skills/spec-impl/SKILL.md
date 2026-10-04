---
name: sdd-spec-impl
description: >-
  Execute SDD spec tasks using TDD methodology.
  Implements approved tasks following Red-Green-Refactor cycle.
---

# Implementation Task Executor

<background_information>

- **Mission**: Execute implementation tasks based on approved specifications
- **Success Criteria**:
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

- `{spec_path}/spec.json`, `requirements.md`, `design.md`, `tasks.md` (read `kind` from spec.json)
- `{spec_path}/behaviors.md` (if exists) for scenario verification obligations
- **Entire `docs/steering/` directory** for complete project memory

**Validate approvals**:

- Verify tasks are approved in spec.json (if not, stop and ask the user; see Safety & Fallback)

### Step 2: Select Tasks

**Determine which tasks to execute**:

- If task numbers were provided: Execute specified task numbers (e.g., "1.1" or "1,2,3")
- Otherwise: Execute all pending tasks (unchecked `- [ ]` in tasks.md)

### Step 3: Execute Tasks

#### Kind: verify

Execute the tasks per design.md §Protocol. Write evidence to `{spec_path}/probe/` and the judgments to `{spec_path}/verdict.md` (structure: `docs/settings/templates/specs/verdict.md`). No TDD; product code is not modified. Of the Always steps only MARK COMPLETE applies. The Pre-Code Gate and TDD sections below apply to the other kinds unchanged.

#### Kind: fix

Per root cause, write the Regression Guard first and save its failing run to `probe/` before changing code; after the fix, re-run every Defect Ledger reproduction into `probe/`. A repair that departs from design §Root Cause is written into §Deviations from Diagnosis in the same turn.

#### Pre-Code Gate (before writing any code)

Write the least code that satisfies the task. Stop at the first rung that holds:

1. **Does this need to exist?** Speculative need not in the task → skip it, note it in one line.
2. **Standard library covers it?** Use it.
3. **Native platform feature or already-installed dependency covers it?** Use it. Never add a new dependency for what a few lines do.
4. **One line?** One line. Otherwise the minimum that works.

The gate is a reflex, not a research project — take the highest rung that holds and move on. No abstraction with one implementation, no config for a value that never changes, no scaffolding "for later". Never gate away (build it fully): input validation at trust boundaries, error handling that prevents data loss, security, accessibility, or anything the task explicitly requires.

For each selected task, first judge whether the task involves **testable logic** (functions, classes, algorithms, data transformations) or **non-testable changes** (config values, text/prompt edits, file moves, simple field changes).

#### When testable logic exists → TDD (Red-Green-Refactor)

1. **RED - Write Failing Test**:
   - Write test for the next small piece of functionality
   - When a `behaviors.md` scenario marked `auto-test` covers this task, derive the test directly from its Given/When/Then (the scenario's concrete values are the test fixture) and record the test name as the scenario's pointer
   - Test should fail (the code does not exist yet, or — for `fix` — the defect is still present)
   - Use descriptive test names

2. **GREEN - Write Minimal Code**:
   - Implement simplest solution to make test pass (apply the Pre-Code Gate)
   - Focus only on making THIS test pass

3. **REFACTOR - Clean Up**:
   - Improve code structure and readability
   - Remove duplication
   - Ensure all tests still pass after refactoring

#### When no testable logic exists → Direct Implementation

- Apply the change directly
- Run existing tests to confirm no regressions

#### Always

1. **VERIFY**: All existing tests pass, no regressions
   - When a task fulfills a `behaviors.md` scenario's `Verification:`, replace its `planned:` pointer with the evidence, in the form `docs/settings/rules/behavior-formulation.md §Verification Mapping` gives for its tier
   - When what you meet disagrees with a document, with code outside this spec, or with the product's purpose, read `docs/settings/rules/concept-alignment.md §Findings` and route it there. Do not add a workaround and proceed
2. **POST-TASK REFACTORING REVIEW** (after all sub-tasks of a major task are complete):
   - **REVIEW**: Evaluate refactoring needs from the following perspectives:
     - Duplication: Are there similar patterns introduced across sub-tasks?
     - Naming: Do variable/function/module names accurately reflect intent?
     - Simplification: Is there unnecessary complexity or indirection?
     - Separation of concerns: Are responsibilities properly separated?
     - Comment conventions: Do comments follow the steering's comment rules, where steering defines them?
   - **EXECUTE** (if refactoring needed): Perform refactoring, then run all tests to confirm they pass
   - **SKIP** (if no refactoring needed): Mark review as complete and proceed to next major task
   - _Note: This is a bird's-eye review layer distinct from TDD's per-cycle Refactor step, which focuses on local improvements within individual test cycles_
3. **MARK COMPLETE**: Update checkbox from `- [ ]` to `- [x]` in tasks.md
   - Work that waits on the user's observation is not complete until the user's record exists (`docs/settings/rules/concept-alignment.md §User Check`)

## Critical Constraints

- **TDD when warranted**: Use TDD only when the task introduces testable logic. Do NOT write tests that merely assert config values, string literals, or file contents
- **Test the critical path, not every line**: Cover non-trivial logic with the smallest tests that fail if it breaks; do not add a separate test per trivial branch, getter, or wrapper
- **Task Scope**: Implement only what the specific task requires
- **No Regressions**: Existing tests must continue to pass
- **Design Alignment**: Implementation must follow design.md specifications

</instructions>

## Tool Guidance

- **Read first**: Load all context before implementation
- **Test first**: Write tests before code only when testable logic exists
- **Search the web** for library documentation when needed

## Output Description

Provide brief summary in the language specified in spec.json:

1. **Facts checked**: commands run and their output, file:line quotes, tests and their results — including the task numbers executed, the completed tasks marked in tasks.md, the remaining tasks count, and the findings routed (where each went)
2. **Readings**: interpretations and inferences, marked as such
3. **Unverified**: what was not checked

**Format**: Concise (under 150 words)

## Safety & Fallback

### Error Scenarios

**Tasks Not Approved or Missing Spec Files**:

- **Stop Execution**: All spec files must exist and tasks must be approved
- **Tasks Approval**: The approval is the user's decision. Ask for it, and write `approvals.tasks.approved: true` (with `updated_at`) only on their explicit yes — never on your own judgment
- **Suggested Action (tasks not approved)**: Ask the user to approve the tasks, per Tasks Approval
- **Suggested Action (missing spec files)**: "Complete previous phases: `/sdd-spec-requirements`, `/sdd-spec-design`, `/sdd-spec-tasks`"

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
