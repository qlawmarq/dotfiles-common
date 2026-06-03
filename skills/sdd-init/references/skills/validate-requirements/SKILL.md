---
name: sdd-validate-requirements
description: >-
  Interactive requirements quality review and validation.
  Detects gold-plating (unrequested features), ambiguity, and scope creep before they propagate.
argument-hint: "<feature-name> [--batch]"
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

When `--batch` flag is provided, the skill runs in non-interactive batch mode:
- **Skip** the interactive discussion of suspicious requirements (Step 4)
- Perform a bulk review of the requirements against the original input and steering context
- Output the complete review result — including the unsourced-requirements list and GO/NO-GO — directly
- Do not engage in back-and-forth dialogue with the user

When `--batch` is NOT provided, maintain the default interactive behavior (engage in dialogue, especially to confirm whether suspicious requirements were actually wanted).

## Core Task

Interactive requirements quality review for the specified feature, focused on detecting requirements that do not trace back to the user's input.

## Execution Steps

1. **Resolve Spec Path**: Look for the feature directory in `docs/tasks/todo/<feature-name>/` first, then `docs/tasks/done/<feature-name>/`. Use whichever exists. If neither exists, report an error.

2. **Load Context**:
   - Read `{spec_path}/spec.json` for language and metadata
   - Read `{spec_path}/requirements.md` — including the **Project Description (Input)** section, every requirement's **Source** line, the **Out of Scope** section, and the **Assumptions & Open Questions** section
   - **Load ALL steering context**: Read entire `docs/steering/` directory including:
     - Default files: `structure.md`, `tech.md`, `product.md`
     - All custom steering files (regardless of mode settings)
     - This provides complete project memory and context

3. **Read Review Guidelines**:
   - Read `docs/settings/rules/requirements-review.md` for review criteria and process
   - Read `docs/settings/rules/ears-format.md` to check acceptance-criteria conformance

4. **Execute Requirements Review** (skip interactive dialogue in `--batch` mode):
   - Follow requirements-review.md process: Build trace map → identify Critical Issues → recognize Strengths → GO/NO-GO
   - **Run the traceability sweep on every requirement**, even when you cap critical issues at three: cross-check each requirement's Source against the Project Description (Input) and steering. List every requirement that does not trace to a legitimate source.
   - In batch mode: perform bulk review and output complete results without user dialogue
   - In interactive mode (default): for each suspicious requirement, ask the user whether they actually wanted it — this distinguishes "the agent invented it" from "the user wanted it but didn't spell it out"
   - Use language specified in spec.json for output

5. **Provide Decision and Next Steps**:
   - Clear GO/NO-GO decision with rationale
   - Guide the user on proceeding based on decision

## Important Constraints

- **Detect, don't redesign**: surface problems; do not rewrite the requirements or invent the missing ones yourself
- **Source-first**: the primary question for every requirement is "where did this come from?"
- **Invented features are NO-GO by default**: an unsourced requirement must be confirmed by the user or removed before proceeding
- **Interactive approach**: engage in dialogue, not one-way evaluation
- **Balanced assessment**: recognize both strengths and weaknesses

</instructions>

## Tool Guidance

- **Read first**: Load all context (spec, steering, rules) before review
- **Grep if needed**: Search the original input/steering to confirm or refute a requirement's claimed source
- **Interactive**: Engage with the user to resolve whether suspicious requirements were wanted

## Output Description

Provide output in the language specified in spec.json with:

1. **Review Summary**: Brief overview (2-3 sentences) of how well-grounded the requirements are and their readiness
2. **Unrequested / Unsourced Requirements**: The headline list — every requirement that does not trace to user input, with its ID and what the user actually said (or "none found")
3. **Critical Issues**: Maximum 3, following requirements-review.md format (Concern, Type, Impact, Suggestion, Evidence)
4. **Strengths**: 1-2 positive aspects
5. **Final Assessment**: GO/NO-GO decision with rationale and next steps

**Format Requirements**:

- Use Markdown headings for clarity
- Follow requirements-review.md output format
- Keep summary concise

## Safety & Fallback

### Error Scenarios

- **Missing Requirements**: If requirements.md doesn't exist, stop with message: "Run `/sdd-spec-requirements <feature-name>` first to generate requirements"
- **Requirements Not Generated**: If requirements phase not marked as generated in spec.json, warn but proceed with review
- **Missing Source Lines**: If requirements lack Source/provenance lines, treat that as a finding — the requirements were likely generated without traceability; flag it and recommend re-running `/sdd-spec-requirements`
- **Missing Out of Scope / Assumptions sections**: Treat absence as a finding (unbounded scope / hidden assumptions), not a blocker
- **Empty Steering Directory**: Warn user that project context is missing and may affect review quality
- **Language Undefined**: Default to English (`en`) if spec.json doesn't specify language

### Next Phase: Research & Design

**If Requirements Pass Validation (GO Decision)**:

- Apply any agreed changes, then proceed
- **Optional Gap Analysis** (for existing codebases): run `/sdd-validate-gap <feature-name>`
- Run `/sdd-spec-research <feature-name>` to execute research & discovery
- Then `/sdd-spec-design <feature-name>` to proceed to design

**If Requirements Need Revision (NO-GO Decision)**:

- Remove or confirm the unsourced requirements, clarify ambiguous ones, and bound the scope
- Re-run `/sdd-spec-requirements <feature-name>` with the corrections
- Re-validate with `/sdd-validate-requirements <feature-name>`

**Note**: Requirements validation is recommended but optional. Catching an invented feature here is far cheaper than unwinding it after design and implementation depend on it.
