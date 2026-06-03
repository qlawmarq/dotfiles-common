---
name: sdd-spec-requirements
description: >-
  Elicit testable requirements for an SDD specification through dialogue with the user.
  Creates traceable, scoped requirements in EARS format — never inventing features the user did not ask for.
argument-hint: "<feature-name>"
---

# Requirements Generation

<background_information>

- **Mission**: Elicit comprehensive, testable, and **traceable** requirements in EARS format, grounded strictly in the user's input and confirmed through dialogue — not invented
- **Success Criteria**:
  - Every requirement traces back to a legitimate source (user-stated, user-confirmed, derived, or steering/constraint); no gold-plating
  - Scope is explicitly bounded (Out of Scope section) and assumptions/open questions are logged rather than baked silently into requirements
  - Acceptance criteria follow the project's EARS patterns and are testable
  - Focus on core functionality without implementation details
  - Update metadata to track generation status

</background_information>

<instructions>

## Input

This skill expects:
1. **Feature name** (required): The feature directory name in `docs/tasks/`

If inputs were provided with this skill invocation, use them directly.
Otherwise, ask the user for the feature name.

### This phase is always interactive

Requirements generation runs interactively by design — there is no non-interactive/batch mode. The whole point of this phase is to elicit and confirm what the user wants, and the most common failure mode is an agent silently inventing features to "complete" the picture. That silent invention is exactly what an interactive clarification dialogue prevents. If you find yourself about to fill a gap with a guess, stop and ask instead (see `requirements-elicitation.md`).

## Core Task

Elicit complete, traceable requirements for the specified feature based on the project description in requirements.md and a clarification dialogue with the user. **Do not invent requirements the user did not ask for or confirm.**

## Execution Steps

1. **Resolve Spec Path**: Look for the feature directory in `docs/tasks/todo/<feature-name>/` first, then `docs/tasks/done/<feature-name>/`. Use whichever exists. If neither exists, report an error.

2. **Load Context**:
   - Read `{spec_path}/spec.json` for language and metadata
   - Read `{spec_path}/requirements.md` for project description
   - **Load ALL steering context**: Read entire `docs/steering/` directory including:
     - Default files: `structure.md`, `tech.md`, `product.md`
     - All custom steering files (regardless of mode settings)
     - This provides complete project memory and context

3. **Read Guidelines**:
   - Read `docs/settings/rules/requirements-elicitation.md` for the elicit-don't-invent rules, the ask-vs-assume gate, and traceability/scope discipline — **this governs how you run this phase**
   - Read `docs/settings/rules/ears-format.md` for EARS syntax rules
   - Read `docs/settings/templates/specs/requirements.md` for document structure (note the Source lines, Out of Scope, and Assumptions & Open Questions sections)

4. **Draft from grounded input only**:
   - Read the project description and all steering context, and draft requirements covering **only** what is clearly grounded in that input
   - Focus on WHAT the system must do, not HOW
   - As you draft, collect every point where the input did not settle a choice (missing thresholds, unstated edge cases, ambiguous scope, conflicting hints) — these become your clarifying questions and your Open Questions log
   - Do **not** fill these gaps with guesses or "reasonable" additions; an unconfirmed addition is gold-plating and is the main cause of rework this phase exists to prevent

5. **Clarify through dialogue**:
   - Present the draft together with your questions, and iterate with the user — a concrete draft is easier to react to than a long upfront questionnaire
   - When a gap affects scope, behavior, or acceptance criteria, **ask** before writing the affected requirement; only proceed on trivial/reversible gaps, and only by logging them as assumptions
   - Offer additions you think might be wanted as *proposals* ("Did you also want X? I'll leave it out unless you confirm"), defaulting to leaving them out
   - Before finishing, give a short confirmation summary covering both what you included and **what you deliberately left out of scope**, and get the user's confirmation

6. **Finalize Requirements**:
   - Group related functionality into logical requirement areas
   - Give every requirement a **Source** line (user-stated / user-confirmed / derived / steering-constraint) — if a requirement has no legitimate source, remove it or raise it as a proposal
   - Fill the **Out of Scope** section with what you deliberately excluded, and the **Assumptions & Open Questions** section with anything still unresolved
   - Tag requirements with MoSCoW priority traceable to user intent
   - Apply EARS format to all acceptance criteria; replace vague terms (fast, user-friendly, robust, …) with measurable criteria or log them as open questions
   - Use language specified in spec.json

7. **Update Metadata**:
   - Set `phase: "requirements-generated"`
   - Set `approvals.requirements.generated: true`
   - Update `updated_at` timestamp

## Important Constraints

- **No assumptions, no invention**: every requirement must trace to the user's input or an explicit confirmation. If unclear, ask — never guess (see the ask-vs-assume gate in `requirements-elicitation.md`).
- **Elicit, don't author**: your job is to discover and confirm needs, not to decide what the user "probably also wants". The default answer to any unconfirmed proposal is *no*.
- Focus on WHAT, not HOW (no implementation details)
- Requirements must be testable and verifiable
- Choose appropriate subject for EARS statements (system/service name for software)
- Generate an initial grounded draft first, then iterate with user feedback (no long sequential questionnaire upfront)
- Requirement headings in requirements.md MUST include a leading numeric ID only (for example: "Requirement 1", "1.", "2 Feature ..."); do not use alphabetic IDs like "Requirement A".

</instructions>

## Tool Guidance

- **Read first**: Load all context (spec, steering, rules, templates) before generation
- **Write last**: Update requirements.md only after complete generation
- Use **WebSearch/WebFetch** only if external domain knowledge needed

## Output Description

Provide output in the language specified in spec.json with:

1. **Generated Requirements Summary**: Brief overview of major requirement areas (3-5 bullets), each noting its source
2. **Out of Scope & Open Questions**: Briefly state what you deliberately left out and any assumptions/questions still open — this makes invented-feature risk visible to the user
3. **Document Status**: Confirm requirements.md updated and spec.json metadata updated
4. **Next Steps**: Guide user on how to proceed (validate, approve and continue, or modify)

**Format Requirements**:

- Use Markdown headings for clarity
- Include file paths in code blocks
- Include all URL references if WebSearch/WebFetch used
- Keep summary concise (under 300 words)

## Safety & Fallback

### Error Scenarios

- **Missing Project Description**: If requirements.md lacks project description, ask user for feature details
- **Ambiguous Requirements**: Resolve through the clarification dialogue — propose an initial draft and ask targeted questions; never resolve ambiguity by guessing. Log anything still unresolved in Assumptions & Open Questions.
- **Template Missing**: If template files don't exist, use inline fallback structure with warning, but still include Source lines, an Out of Scope section, and an Assumptions & Open Questions section
- **Language Undefined**: Default to English (`en`) if spec.json doesn't specify language
- **Incomplete Requirements**: After generation, explicitly ask the user if requirements cover all expected functionality. Resolve gaps by asking — do not fill them with invented requirements.
- **Steering Directory Empty**: Warn user that project context is missing and may affect requirement quality
- **Non-numeric Requirement Headings**: If existing headings do not include a leading numeric ID (for example, they use "Requirement A"), normalize them to numeric IDs and keep that mapping consistent (never mix numeric and alphabetic labels).

### Next Phase: Research & Design

**If Requirements Approved**:

- Review generated requirements at `docs/tasks/<feature-name>/requirements.md`
- **Recommended Validation**: Run `/sdd-validate-requirements <feature-name>` to verify every requirement traces to your input and catch any gold-plating before it propagates into design and implementation. Catching an invented feature here is far cheaper than unwinding it later.
- **Optional Gap Analysis** (for existing codebases):
  - Run `/sdd-validate-gap <feature-name>` to analyze implementation gap with current code
  - Identifies existing components, integration points, and implementation strategy
  - Recommended for brownfield projects; skip for greenfield
- Run `/sdd-spec-research <feature-name>` to execute research & discovery (generates research.md)
- Then `/sdd-spec-design <feature-name> -y` to proceed to design phase (uses research.md)

**If Modifications Needed**:

- Provide feedback and re-run `/sdd-spec-requirements <feature-name>`

**Note**: Approval is mandatory before proceeding to design phase.
