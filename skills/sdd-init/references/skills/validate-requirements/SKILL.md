---
name: sdd-validate-requirements
description: >-
  Interactive requirements quality review and validation.
  Detects gold-plating (unrequested features), ambiguity, and scope creep before they propagate.
---

# Requirements Validation

<background_information>

- **Mission**: Verify that `requirements.md` reflects what the user actually asked for — nothing invented, nothing ambiguous, nothing untestable — before it propagates into research, design, and implementation
- **Success Criteria**:
  - Every requirement traced to a legitimate source; unrequested ("gold-plated") requirements surfaced explicitly
  - Scope boundaries verified (explicit Out of Scope, no contradictions)
  - Ambiguity and testability issues flagged
  - Clear GO/NO-GO decision with rationale

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
- The Interactive Discussion of `requirements-review.md` §Output Format is omitted; the complete review with its GO/NO-GO decision is output directly, without back-and-forth with the user

Without `--batch`, maintain the default interactive behavior (engage in dialogue, especially to confirm whether suspicious requirements were actually wanted).

## Core Task

Interactive requirements quality review for the specified feature, focused on detecting requirements that do not trace back to the user's input.

## Execution Steps

1. **Resolve Spec Path**: Look for the feature directory in `docs/tasks/todo/<feature-name>/` first, then `docs/tasks/done/<feature-name>/`. Use whichever exists. If neither exists, report an error.

2. **Load Context**:
   - Read `{spec_path}/spec.json` for language and metadata
   - Read `{spec_path}/requirements.md` — including the **Project Description (Input)** section, the **Out of Scope** section, and the **Assumptions & Open Questions** section
   - Read the entire `docs/steering/` directory

3. **Read Review Guidelines**:
   - Read `docs/settings/rules/requirements-review.md` for review criteria and process
   - Read `docs/settings/rules/concept-alignment.md` §Resolving the Canon, §The Check, and, under §Findings, §Severity and §Finding Format for the forward-traceability (concept) check
   - Read `docs/settings/rules/ears-format.md` to check acceptance-criteria conformance
   - Read the kind's requirements template as the structure reference (`docs/settings/rules/spec-kinds.md` §4)

4. **Execute Requirements Review** per `requirements-review.md` §Review Process.

5. **Provide Decision and Next Steps**:
   - Clear GO/NO-GO decision with rationale
   - Guide the user on proceeding based on decision

## Important Constraints

- **Confirm before filing**: check each finding against the source itself — quote the `file:line` (spec, steering, canon, code) it rests on, or for an absence what you searched, and run the test, probe or command for any claim about how code behaves. Report what you could not confirm as unconfirmed, not as a Critical Issue.

</instructions>

## Output Description

Write the review in spec.json `language`, following `requirements-review.md` §Output Format.

## Safety & Fallback

### Error Scenarios

- **Missing Requirements**: If requirements.md doesn't exist, stop with message: "Run `/sdd-spec-requirements <feature-name>` first to generate requirements"
- **Requirements Not Generated**: If requirements phase not marked as generated in spec.json, warn but proceed with review
- **Missing Out of Scope / Assumptions sections**: Treat absence as a finding (unbounded scope / hidden assumptions), not a blocker, unless the kind's template marks the section "Omit when …" and its condition holds
- **Empty Steering Directory**: Warn user that project context is missing and may affect review quality

### Next Phase: Research & Design

**If Requirements Pass Validation (GO Decision)**:

- Apply any agreed changes, then proceed
- **Recommended** (when the kind produces behaviors): run `/sdd-spec-behavior <feature-name>` to formulate product-grounded behavior scenarios
- **Optional Gap Analysis** (for existing codebases): run `/sdd-validate-gap <feature-name>`
- Run `/sdd-spec-research <feature-name>` to execute research & discovery
- Then `/sdd-spec-design <feature-name>` to proceed to design

**If Requirements Need Revision (NO-GO Decision)**:

- Remove or confirm the unsourced requirements, clarify ambiguous ones, and bound the scope
- Re-run `/sdd-spec-requirements <feature-name>` with the corrections
- Re-validate with `/sdd-validate-requirements <feature-name>`

**Note**: Requirements validation is recommended but optional. Catching an invented feature here is far cheaper than unwinding it after design and implementation depend on it.
