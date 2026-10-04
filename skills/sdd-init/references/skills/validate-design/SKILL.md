---
name: sdd-validate-design
description: >-
  Interactive technical design quality review and validation.
  Conducts GO/NO-GO assessment with balanced feedback.
---

# Technical Design Validation

<background_information>

- **Mission**: Conduct interactive quality review of technical design to ensure readiness for implementation
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
- The Interactive Discussion of `design-review.md` §Output Format is omitted; the complete review with its GO/NO-GO decision is output directly, without back-and-forth with the user

Without `--batch`, maintain the default interactive behavior (engage in dialogue throughout the review process).

## Core Task

Interactive design quality review for the specified feature based on approved requirements and design document.

## Execution Steps

1. **Resolve Spec Path**: Look for the feature directory in `docs/tasks/todo/<feature-name>/` first, then `docs/tasks/done/<feature-name>/`. Use whichever exists. If neither exists, report an error.

2. **Load Context**:
   - Read `{spec_path}/spec.json` for language, `kind`, and metadata
   - Read `{spec_path}/requirements.md` for requirements
   - Read `{spec_path}/behaviors.md` for behavior scenarios (if exists)
   - Read `{spec_path}/research.md` for research findings (if exists)
   - Read `{spec_path}/design.md` for design document
   - Read the entire `docs/steering/` directory

3. **Read Review Guidelines**:
   - Read `docs/settings/rules/design-review.md` for review criteria and process
   - Read `docs/settings/rules/concept-alignment.md` §Resolving the Canon, §The Check, and, under §Findings, §Severity and §Finding Format for the concept & behavior alignment check (design-review criterion 0)
   - Read the kind's design template as the structure reference (`docs/settings/rules/spec-kinds.md` §4)

4. **Execute Design Review** per `design-review.md` §Review Process:
   - If `research.md` exists, verify that its key findings are reflected in the design — and, per design-review criterion 5, that no major design decision silently rests on a claim typed `unverified` or lacking a reproducer
   - **Recompute** per `design-review.md` criterion 6, in batch mode too
   - **Non-functional coverage** per design-review criterion 7

5. **Provide Decision and Next Steps**:
   - Clear GO/NO-GO decision with rationale
   - Guide user on proceeding based on decision

</instructions>

## Output Description

Write the review in spec.json `language`, following `design-review.md` §Output Format.

## Safety & Fallback

### Error Scenarios

- **Missing Design**: If design.md doesn't exist, stop with message: "Run `/sdd-spec-design <feature-name>` first to generate design document"
- **Design Not Generated**: If design phase not marked as generated in spec.json, warn but proceed with review
- **Empty Steering Directory**: Warn user that project context is missing and may affect review quality

### Next Phase: Task Generation

**If Design Passes Validation (GO Decision)**:

- Review feedback and apply changes if needed
- Run `/sdd-spec-tasks <feature-name>` to generate implementation tasks
- Or `/sdd-spec-tasks <feature-name> -y` to auto-approve and proceed directly

**If Design Needs Revision (NO-GO Decision)**:

- Address critical issues identified
- Re-run `/sdd-spec-design <feature-name>` with improvements
- Re-validate with `/sdd-validate-design <feature-name>`

**Note**: Design validation is recommended but optional. Quality review helps catch issues early.
