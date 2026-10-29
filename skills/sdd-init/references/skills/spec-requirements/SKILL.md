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
1. **Feature name** (required): The feature directory name in `docs/specs/`

If inputs were provided with this skill invocation, use them directly.
Otherwise, ask the user for the feature name.

## Core Task

Elicit complete, traceable requirements for the specified feature based on the project description in requirements.md and a clarification dialogue with the user. **Do not invent requirements the user did not ask for or confirm.**

## Execution Steps

1. **Resolve Spec Path**: Look for the feature directory in `docs/specs/todo/<feature-name>/` first, then `docs/specs/done/<feature-name>/`. Use whichever exists. If neither exists, report an error.

2. **Load Context**:
   - Read `{spec_path}/spec.json` for language, `kind`, and metadata
   - Read `{spec_path}/requirements.md` for project description; when the description is a pointer to a plan unit (`units.md §U<N>`), read that unit's entry and the plan's non-goals at the head of `units.md` — together they are the scope brief
   - Read the entire `docs/steering/` directory

3. **Read Guidelines**:
   - Read `docs/settings/rules/requirements-elicitation.md` for the elicit-don't-invent rules, the ask-vs-assume gate, and traceability/scope discipline — **this governs how you run this phase**
   - Read `docs/settings/rules/ears-format.md` for EARS syntax rules and `docs/settings/rules/document-hygiene.md`
   - Read `docs/settings/rules/spec-kinds.md` §4–§5 for the kind's requirements template and what this kind elicits; read that template for document structure (note the Out of Scope and Assumptions & Open Questions sections)

4. **Draft** per `requirements-elicitation.md` §How to run the clarification dialogue (1–2). Check each candidate requirement against product intent (`concept-alignment.md §Resolving Product Intent`) — a conflict is a clarifying question for the user, never something to accommodate silently.

5. **Clarify** per the same section (3–4) and §No assumptions — the ask-vs-assume gate, ending with its confirmation summary. When decision records are declared, the summary also lists the decision changes of Step 8.

6. **Finalize Requirements** (write requirements.md now, after the Step 5 confirmation):
   - Keep the `## Project Description (Input)` section written at init above the template's sections (every kind).
   - Group related functionality into logical requirement areas
   - Trace, scope and prioritize per `requirements-elicitation.md` (§The core principle, §Scope discipline); acceptance criteria per `ears-format.md`

7. **Update Metadata**:
   - Set `phase: "requirements-generated"`
   - Set `approvals.requirements.generated: true`

8. **Decision records** (only when declared):
   - Draft time (Step 4): grep the decision records JIT for the decisions and registry IDs the feature touches. Product-level decisions the user settled in dialogue, new enumerable norms, and registry IDs this feature adopts (`Used by` += `spec: <feature-dir-name>`) land after the Step 5 yes by `docs/settings/rules/decision-records.md §Change Control`; requirements.md cites decision and registry IDs and never copies them
   - The commit is `docs(decisions): requirements <feature-name>`

## Important Constraints

- **Use the project's canonical terms.** When the registry declares a `TERM` vocabulary, write requirements in its canonical terms; if the dialogue coins a new recurring term, surface it in the confirmation summary so the user can register it (or map it to an existing term) instead of letting a synonym take root.

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
