---
name: sdd-validate-tasks
description: >-
  Interactive task quality review and validation.
  Ensures consistency across documentation and readiness for implementation.
---

# Task Validation

<background_information>

- **Mission**: Conduct a review of the implementation plan to ensure consistency across documentation and readiness for implementation.
- **Success Criteria**:
  - Balanced assessment with strengths recognized
  - Clear GO/NO-GO decision with rationale
  - Actionable feedback for improvements if needed

</background_information>

<instructions>

## Input

This skill expects:
1. **Feature name** (required): The feature directory name in `docs/tasks/`
2. **--batch** (optional): Non-interactive batch mode flag

If inputs were provided with this skill invocation, use them directly.
Otherwise, ask the user for the feature name.

### Batch Mode (`--batch`)

With `--batch`, the skill runs without the user:
- Every check in Step 4 still runs
- The complete review with its GO/NO-GO decision is output directly, without back-and-forth with the user

Without `--batch`, maintain the default interactive behavior (engage in dialogue throughout the review process).

## Core Task

Interactive implementation task review for the specified feature based on approved requirements and design document.

## Execution Steps

1. **Resolve Spec Path**: Look for the feature directory in `docs/tasks/todo/<feature-name>/` first, then `docs/tasks/done/<feature-name>/`. Use whichever exists. If neither exists, report an error.

2. **Load Context**:
   - Read `{spec_path}/spec.json` for language, `kind`, and metadata
   - Read `{spec_path}/requirements.md` for requirements
   - Read `{spec_path}/behaviors.md` for behavior scenarios (if exists)
   - Read `{spec_path}/design.md` for design document
   - Read the entire `docs/steering/` directory

3. **Read Review Guidelines**:
   - Read `docs/settings/rules/tasks-generation.md` for the criteria the tasks must satisfy, and, if `behaviors.md` exists, `docs/settings/rules/behavior-formulation.md §Verification Mapping` for what covers each tier. The issue format and GO/NO-GO shape are defined in Output Description below.

4. **Execute Task Review**:
   - Review implementation tasks using tasks-generation.md process
   - Ensure there are no issues with consistency between documents, no overly burdensome tasks, and no ambiguous tasks or designs.
   - If `behaviors.md` exists: verify every scenario's `Verification:` is covered as its tier's Produced by column says — an uncovered scenario is a Critical issue, and so is a task for a `user` scenario.
   - Kind `verify` (structure: `docs/settings/templates/specs/tasks-verify.md`): verify every question in requirements.md has a run/record task and a judgment task — a question without both is a Critical issue.

5. **Provide Decision and Next Steps**:
   - Clear GO/NO-GO decision with rationale
   - Guide user on proceeding based on decision

## Important Constraints

- Accept an acceptable risk; this is quality assurance, not a search for perfection.
- **Confirm before filing**: check each finding against the source itself — quote the `file:line` (spec, steering, canon, code) it rests on, or for an absence what you searched, and run the test, probe or command for any claim about how code behaves. Report what you could not confirm as unconfirmed, not as a Critical Issue.

</instructions>

## Tool Guidance

- **Grep if needed**: Search codebase for pattern validation or integration checks

## Output Description

Provide output in the language specified in spec.json with:

1. **Review Summary**: Brief overview (2-3 sentences) of task quality and readiness
2. **Critical Issues**: Maximum 3. For each — **Concern** (the specific problem), **Impact** (why it matters), **Suggestion** (a concrete fix), **Traceability** (the requirement ID it affects), **Evidence** (the tasks.md task number or design.md section)
3. **Task Strengths**: 1-2 positive aspects
4. **Final Assessment**: GO/NO-GO decision with rationale and next steps

## Safety & Fallback

### Error Scenarios

- **Missing Tasks**: If tasks.md doesn't exist, stop with message: "Run `/sdd-spec-tasks <feature-name>` first to generate implementation tasks"
- **Missing Design**: If design.md doesn't exist, stop with message: "Run `/sdd-spec-design <feature-name>` first to generate design document"
- **Design Not Generated**: If design phase not marked as generated in spec.json, warn but proceed with review
- **Empty Steering Directory**: Warn user that project context is missing and may affect review quality

### Next Phase: Implementation

**If Task Passes Validation (GO Decision)**:

- Review feedback and apply changes if needed
- Run `/sdd-spec-impl <feature-name>` to execute implementation tasks

**If Task Needs Revision (NO-GO Decision)**:

- Address critical issues identified
- Re-run `/sdd-spec-tasks <feature-name>` with improvements
- Re-validate with `/sdd-validate-tasks <feature-name>`

**Note**: Task validation is recommended but optional. Quality review helps catch issues early.
