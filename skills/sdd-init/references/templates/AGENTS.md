# AI-DLC and Spec-Driven Development

## Paths

- Steering: `docs/steering/` — project memory; load all of it. What it holds and how it changes: `docs/settings/rules/steering-principles.md`
- Inception (large-scale plans): `docs/inception/`
- Specs: `docs/tasks/`
- Canon (optional): declared under `## Canon References` in `docs/steering/product.md`

## Language

- Think in English. Respond and write documents in the language the invocation names (`--lang`); else, for work on a spec, in its `spec.json` `language`; else in {{DEFAULT_LANGUAGE_NAME}}.

## Workflow

Phases, their order, and which phases a spec's kind runs: `docs/settings/rules/spec-kinds.md` §4. Each skill's description says what it does; square brackets mark an optional step.

1. [`/sdd-plan`] — an effort too large for one spec; the specs it scaffolds start at 3
2. `/sdd-spec-init`
3. `/sdd-spec-requirements` → [`/sdd-validate-requirements`]
4. `/sdd-spec-behavior`, when the kind produces behaviors
5. [`/sdd-validate-gap`] → `/sdd-spec-research` → [`/sdd-validate-research`]
6. `/sdd-spec-design` → [`/sdd-validate-design`]
7. `/sdd-spec-tasks` → [`/sdd-validate-tasks`]
8. `/sdd-spec-impl` → [`/sdd-validate-impl`]
9. `/sdd-spec-done`

## Rules

- A phase starts only after the user approves the previous one; `-y` approves it on purpose.
- Stay within the scope the user asked for; gather the context you need yourself, and ask only when essential information is missing or the request is critically ambiguous.
- **Documents are the source of truth.** Carry every change to the documents that cite it, in the same turn, and state each fact in one seat (`docs/settings/rules/document-hygiene.md`).
- **A long wait is the user's call.** Before waiting on a run beyond the limit, tell the user how long it would take and ask what would shorten it (`docs/settings/rules/concept-alignment.md §Waiting on a Run`).
- For contradictions between layers (spec vs spec, steering vs inception) or a backlog of open decisions, suggest `/sdd-grill`.
