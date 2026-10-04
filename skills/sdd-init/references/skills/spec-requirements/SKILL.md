---
name: sdd-spec-requirements
description: >-
  Elicit testable requirements for an SDD specification through dialogue with the user.
  Creates traceable, scoped requirements in EARS format — never inventing features the user did not ask for.
---

# Requirements Generation

<background_information>

- **Mission**: Elicit comprehensive, testable, and **traceable** requirements in EARS format, grounded strictly in the user's input and confirmed through dialogue — not invented
- **Success Criteria**:
  - Every requirement traces back to user input or steering; no gold-plating
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

## Core Task

Elicit complete, traceable requirements for the specified feature based on the project description in requirements.md and a clarification dialogue with the user. **Do not invent requirements the user did not ask for or confirm.**

## Execution Steps

1. **Resolve Spec Path**: Look for the feature directory in `docs/tasks/todo/<feature-name>/` first, then `docs/tasks/done/<feature-name>/`. Use whichever exists. If neither exists, report an error.

2. **Load Context**:
   - Read `{spec_path}/spec.json` for language, `kind`, and metadata
   - Read `{spec_path}/requirements.md` for project description; when the description is a pointer to an inception unit (`units.md §U<N>`), read that unit's entry and the plan's non-goals at the head of `units.md` — together they are the scope brief
   - Read the entire `docs/steering/` directory

3. **Read Guidelines**:
   - Read `docs/settings/rules/requirements-elicitation.md` for the elicit-don't-invent rules, the ask-vs-assume gate, and traceability/scope discipline — **this governs how you run this phase**
   - Read `docs/settings/rules/ears-format.md` for EARS syntax rules and `docs/settings/rules/document-hygiene.md`
   - Read `docs/settings/rules/spec-kinds.md` §4–§5 for the kind's requirements template and what this kind elicits; read that template for document structure (note the Out of Scope and Assumptions & Open Questions sections)

4. **Draft from grounded input only**:
   - Read the project description and all steering context, and draft requirements covering **only** what is clearly grounded in that input
   - Focus on WHAT the system must do, not HOW
   - As you draft, collect every point where the input did not settle a choice (missing thresholds, unstated edge cases, ambiguous scope, conflicting hints) — these become your clarifying questions and your Open Questions log
   - Check each candidate requirement against `docs/steering/product.md` (purpose, themes, Out of Scope) and `docs/steering/behaviors.md` invariants if present — a conflict is a clarifying question for the user, never something to accommodate silently
   - Do **not** fill these gaps with guesses or "reasonable" additions; an unconfirmed addition is gold-plating and is the main cause of rework this phase exists to prevent

5. **Clarify through dialogue**:
   - Present the draft together with your questions, and iterate with the user — a concrete draft is easier to react to than a long upfront questionnaire
   - When a gap affects scope, behavior, or acceptance criteria, **ask** before writing the affected requirement; only proceed on trivial/reversible gaps, and only by logging them as assumptions
   - Offer additions you think might be wanted as *proposals* ("Did you also want X? I'll leave it out unless you confirm"), defaulting to leaving them out
   - Before finishing, give a short confirmation summary covering both what you included and **what you deliberately left out of scope**, and get the user's confirmation. When a canon layer is declared (`docs/steering/product.md §Canon References`), open that summary with the `## Canon changes` section from Step 8 — the same yes covers both

6. **Finalize Requirements** (write requirements.md now, after the Step 5 confirmation):
   - Keep the `## Project Description (Input)` section written at init above the template's sections (every kind).
   - Group related functionality into logical requirement areas
   - Check that every requirement traces to user input or steering — if a requirement has no legitimate source, remove it or raise it as a proposal
   - Fill the **Out of Scope** section with what you deliberately excluded, and the **Assumptions & Open Questions** section with anything still unresolved
   - Tag requirements with MoSCoW priority traceable to user intent
   - Apply EARS format to all acceptance criteria

7. **Update Metadata**:
   - Set `phase: "requirements-generated"`
   - Set `approvals.requirements.generated: true`

8. **Canon changes** (only when a canon layer is declared; follow `docs/settings/rules/canon-layer.md §Change Control`):
   - Draft time (Step 4): grep the canon JIT for the decisions and registry IDs the feature touches. Product-level decisions the user settled in dialogue, new enumerable norms, and registry IDs this feature adopts (`Used by` += `spec: <feature-dir-name>`) are edited into the canon working tree; requirements.md cites decisions/IDs and never copies them
   - The canon changes open the Step 5 confirmation summary; after the user's yes the commit is `docs(canon): requirements <feature-name>`

## Important Constraints

- **Use the project's canonical terms.** When the canon registry declares a `TERM` vocabulary, write requirements in its canonical terms; if the dialogue coins a new recurring term, surface it in the confirmation summary so the user can register it (or map it to an existing term) instead of letting a synonym take root.

</instructions>

## Tool Guidance

- **Search the web** only if external domain knowledge needed

## Output Description

Write requirements.md and this summary in spec.json `language`:

1. **Generated Requirements Summary**: Brief overview of major requirement areas (3-5 bullets), each noting its source
2. **Out of Scope & Open Questions**: Briefly state what you deliberately left out and any assumptions/questions still open — this makes invented-feature risk visible to the user
3. **Document Status**: Confirm requirements.md updated and spec.json metadata updated
4. **Next Steps**: Guide user on how to proceed (validate, approve and continue, or modify)

**Format Requirements**:

- Include file paths in code blocks
- Include all URL references if the web was searched
- Keep summary concise (under 300 words)

## Safety & Fallback

### Error Scenarios

- **Missing Project Description**: If requirements.md lacks a project description and no unit pointer resolves, ask user for feature details
- **Template Missing**: If template files don't exist, use inline fallback structure with warning, but still include an Out of Scope section and an Assumptions & Open Questions section
- **Steering Directory Empty**: Warn user that project context is missing and may affect requirement quality
- **Non-numeric Requirement Headings**: If existing headings do not have the form of `docs/settings/rules/ears-format.md` §Requirement IDs, normalize them to it and keep that mapping consistent.

### Next Phase: Research & Design

**If Requirements Approved**:

- Review generated requirements at `{spec_path}/requirements.md`
- **Recommended Validation**: Run `/sdd-validate-requirements <feature-name>` to verify every requirement traces to your input and catch any gold-plating before it propagates into design and implementation. Catching an invented feature here is far cheaper than unwinding it later.
- **Recommended Behavior Formulation** (when the kind produces behaviors): Run `/sdd-spec-behavior <feature-name>` to formulate concrete scenarios grounded in the product's purpose (generates behaviors.md) — this is where concept drift is caught before design
- **Optional Gap Analysis** (for existing codebases):
  - Run `/sdd-validate-gap <feature-name>` to analyze implementation gap with current code
  - Identifies existing components, integration points, and implementation strategy
  - Recommended for brownfield projects; skip for greenfield
- Run `/sdd-spec-research <feature-name>` to execute research & discovery (generates research.md)
- Then `/sdd-spec-design <feature-name> -y` to proceed to design phase (uses research.md)

**If Modifications Needed**:

- Provide feedback and re-run `/sdd-spec-requirements <feature-name>`

**Note**: Approval is mandatory before proceeding to design phase.
