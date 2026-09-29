---
name: sdd-spec-behavior
description: >-
  Formulate concrete behavior scenarios (BDD) for an SDD specification.
  Grounds every scenario in the product's purpose and philosophy, catching concept drift before design.
argument-hint: "<feature-name> [-y]"
---

# Behavior Formulation

<background_information>

- **Mission**: Turn approved requirements into concrete, product-grounded behavior scenarios (BDD Discovery → Formulation), so that what gets designed and built demonstrably serves the product's purpose — not just the spec's internal logic
- **Why this exists**: Requirements trace *backward* to what the user asked for; nothing in that guarantees the resulting behavior serves what the product *is*. This phase adds the forward link: every scenario cites the product purpose it embodies, and contradictions with the product canon surface here — before design and implementation harden them
- **Success Criteria**:
  - Scenarios formulated as concrete examples (named actors, real values), each with `Grounds:` and `Verification:` lines
  - Requirements that contradict the product canon reported as Critical findings, not silently accommodated
  - Open questions logged; scope-affecting ones resolved with the user before design
  - `behaviors.md` written; spec.json updated

</background_information>

<instructions>

## Input

This skill expects:
1. **Feature name** (required): The feature directory name in `docs/tasks/`
2. **Auto-approve flag** (optional): `-y` to auto-approve requirements

If inputs were provided with this skill invocation, use them directly.
Otherwise, ask the user for the feature name.

## Core Task

Formulate behavior scenarios for the specified feature from its approved requirements, grounded in the product canon, through a short example-driven dialogue with the user.

## Execution Steps

### Step 0: Resolve Spec Path

Look for the feature directory in `docs/tasks/todo/<feature-name>/` first, then `docs/tasks/done/<feature-name>/`. Use whichever exists. If neither exists, report an error.

**Kind gate**: read `kind` from `{spec_path}/spec.json`. If the kind does not produce behaviors (`docs/settings/rules/spec-kinds.md` §4), say "`<kind>` specs do not formulate behaviors (see `docs/settings/rules/spec-kinds.md`); next: `/sdd-spec-research <feature-name>`" and stop without changing spec.json.

### Step 1: Load Context

- `{spec_path}/spec.json`, `requirements.md`, `behaviors.md` (if exists, for merge mode)
- **Entire `docs/steering/` directory** — `product.md` and `behaviors.md` (invariant ledger) are the anchors here
- `docs/settings/rules/behavior-formulation.md` — **governs this phase**
- `docs/settings/rules/concept-alignment.md` — canon resolution and severity rules
- `docs/settings/templates/specs/behaviors.md` for document structure

**Validate requirements approval**: with `-y`, set `approvals.requirements.approved: true`; otherwise verify it is `true` (stop if not, see Safety & Fallback).

### Step 2: Ground in the Canon

Following `concept-alignment.md`: identify the product purposes, themes, and Out of Scope items that this feature touches in `product.md`; if a `## Canon References` section is declared, grep the canon for the relevant topics (JIT — only what the feature touches). Collect established invariants from `docs/steering/behaviors.md` that apply.

### Step 3: Formulate Scenarios (Discovery dialogue)

1. Draft scenarios per `behavior-formulation.md` — at most one per acceptance criterion, only where the example adds a boundary value, an interaction, or a reading easy to get wrong; concrete values, one behavior each, one-citation `Grounds:` and `Verification:` on every scenario.
2. While drafting, collect what the examples expose: edge cases requirements never settled, thresholds with no value, behaviors that *cannot* be grounded, behaviors that conflict with canon or invariants.
3. **Conflicts are findings, not editing problems**: a requirement or scenario contradicting the canon is reported in `concept-alignment.md` format. If the canon itself should change, file it as an Open Question in the canon README or hand it to `/sdd-canon-update` — never adjust canon from this phase or quietly reword the scenario to fit.
4. Present the draft with your questions and iterate briefly with the user — concrete examples are easy to react to. Resolve scope-affecting questions; log the rest under Open Questions. Do not invent behaviors beyond the requirements (same discipline as `requirements-elicitation.md`).

### Step 4: Finalize

- Write `{spec_path}/behaviors.md` following the template (merge if one existed); use the language from spec.json
- List Promotion Candidates only if this feature establishes invariants that qualify per `steering-principles.md §File focus` ("none" is the common outcome)
- Update spec.json: set `phase: "behaviors-generated"`, `approvals.behaviors: {generated: true, approved: false}` (add the key if the spec predates it), `approvals.requirements.approved: true`, update `updated_at`

## Important Constraints

- **Scenarios illustrate requirements; they do not extend them.** New capability ideas surfaced by examples go to Open Questions as proposals, default answer *no*.
- **Every scenario grounded and verifiable** — no `Grounds:`, no scenario; no `Verification:`, not finished.
- **Canon conflicts stop at reporting** — resolution belongs to the user (`/sdd-canon-update`, or the phase that owns the decision).
- WHAT-level only: scenarios describe observable behavior, never design or implementation.

</instructions>

## Tool Guidance

- **Read first**: spec, steering, rules, template — before drafting
- **Grep** the canon (per Canon References) and codebase JIT; never bulk-load
- **Write last**: `behaviors.md` after the dialogue settles

## Output Description

Provide output in the language specified in spec.json:

1. **Scenario Summary**: scenario titles with the purpose each serves (one line each). End with one line `Scenarios: n / acceptance criteria: m` — a ratio at or above 1 is a sign the requirements are being restated, not exemplified.
2. **Concept Findings**: canon conflicts found (in `concept-alignment.md` format) or "none — all scenarios grounded"
3. **Open Questions**: what remains logged, and what was resolved in dialogue
4. **Document Status**: behaviors.md written, spec.json updated
5. **Next Steps**: `/sdd-spec-research <feature-name>` (or `/sdd-spec-design <feature-name> -y` for simple features)

**Format**: Concise Markdown, under 300 words

## Safety & Fallback

- **Requirements Not Approved**: Stop. Suggest `/sdd-spec-behavior <feature-name> -y` to auto-approve and proceed
- **Missing requirements.md**: Stop. Suggest `/sdd-spec-requirements <feature-name>` first
- **product.md missing or stub-only**: Warn that grounding will be weak; suggest `/sdd-steering` first. Proceed only if the user confirms, marking ungroundable scenarios explicitly
- **Canon Reference lookup fails** (declared path missing): report the broken declaration as a finding; fall back to product.md alone
- **Old spec.json without `approvals.behaviors`**: add the key when updating — never fail on its absence
- **Template Missing**: use inline structure with warning, keeping Grounds/Verification lines mandatory
- **Language Undefined**: fall back to `docs/settings/templates/specs/init.json` `language`, then `ja`
