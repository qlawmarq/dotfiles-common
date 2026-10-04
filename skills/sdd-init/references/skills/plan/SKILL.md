---
name: sdd-plan
description: >-
  Plan and decompose a LARGE-SCALE software effort into multiple right-sized SDD specs.
  This is the AI-DLC Inception layer that sits ABOVE individual specs: it turns a whole product,
  a 0->1 greenfield build, or the scale-up of an existing prototype into an ordered roadmap of
  independently-shippable Units of Work, then scaffolds one SDD spec per unit.
  Make sure to use this skill whenever the user wants to plan a new app or product from scratch,
  break a big/ambiguous project into pieces, build an MVP roadmap, figure out "where do I even
  start", turn a prototype into a real product, or do anything too large to fit comfortably in a
  single feature spec. Prefer this over /sdd-spec-init when the scope is a whole product or several
  features rather than one focused feature.
---

# SDD Inception & Planning Orchestrator

<background_information>

- **Mission**: Decompose a large development goal into an ordered roadmap of independently-shippable **Units of Work**, then scaffold one SDD spec per unit so each can be developed through the normal `/sdd-spec-*` flow with small, bounded context.
- **Why this exists**: The per-feature SDD flow is excellent for one feature, but a whole product crammed into one spec produces an overwhelming requirements/design/tasks set. This skill is the planning layer above specs — it defines *what the units are, where their boundaries lie, and in what order to build them*, and deliberately defers each unit's detailed requirements/design to that unit's own spec.
- **Success Criteria**:
  - The plan's goal and non-goals are confirmed with the user.
  - The product is decomposed into vertical-slice Units of Work, each passing INVEST and each with an independent-test statement.
  - A dependency matrix and an ordered build sequence (walking-skeleton first) are produced.
  - One SDD spec stub is scaffolded per unit under `docs/tasks/todo/`, linked back to the plan.
  - Plan artifacts are written to `docs/inception/<plan-id>/`.

</background_information>

<instructions>

## Input

This skill expects:
1. **Goal** (optional positional): a description of the product / project / prototype to plan. If omitted, ask the user for it.
2. **`--lang=<code>`** (optional): ISO 639-1 language for all generated documents. Default: read from `docs/settings/templates/specs/init.json` `language`, else `ja`.

## Methodology

The decomposition method — where to cut boundaries, how to size and split units, how to order them — lives in `docs/settings/rules/inception-decomposition.md`. **Read it before Stage 2.** This SKILL.md governs the workflow and gates; that file governs the technique. Write the artifacts per `docs/settings/rules/document-hygiene.md`.

## Operating principle: bounded context

This skill is itself prone to the context bloat it's meant to cure. Keep plan artifacts at the level of *boundaries, scope, and dependencies* — NOT full per-unit requirements or design. Write patterns and one-liners, not exhaustive detail. The detail belongs in each child spec, generated later in its own fresh context. If you find yourself writing EARS acceptance criteria or interface signatures during planning, stop — that work is `/sdd-spec-requirements` and `/sdd-spec-design`, run per unit.

## Workflow

Stages 0–4 each end in a human **approval gate** (GO / revise / stop). At each gate, present the stage's result concisely and ask the user to approve or request changes before proceeding. The gates exist because planning mistakes are expensive to unwind once specs are scaffolded — it is far cheaper to correct a boundary now than after ten specs depend on it.

### Stage 0 — Intake & mode detection

1. Confirm prerequisites: `docs/settings/` and `docs/steering/` should exist (SDD is initialized). If not, tell the user to run `/sdd-init` first and stop.
2. Detect the mode:
   - **Greenfield (0→1)**: little or no application code yet.
   - **Brownfield (scaling a prototype)**: existing code/steering present.
   Decide by a quick check (presence of source beyond config, and whether steering files have real content).
3. Load shared context: read the entire `docs/steering/` directory (product/tech/structure + custom). For brownfield, also do a **lightweight** survey of the codebase (entry points, top-level structure, existing capabilities) — just enough to ground boundaries; do not exhaustively read the repo.
4. Capture the goal (from the argument or by asking).

**Gate 0**: Confirm the mode and a one-paragraph restatement of the goal with the user.

### Stage 1 — Elaboration

Ask a focused set of high-leverage clarifying questions — not an interrogation. Cover only what changes the decomposition: the core problem, target users, the few outcomes that define success, hard constraints (tech, compliance, timeline), expected scale, and **explicit non-goals**. Propose answers where the steering or codebase already implies them, and let the user correct — this respects their time.

**Gate 1**: Confirm the answers and this plan's non-goals with the user.

### Stage 2 — Boundary discovery

Read `docs/settings/rules/inception-decomposition.md` (§2). Then:

1. List the product's significant **domain events** (past tense) along its timeline.
2. Identify **bounded contexts** using the linguistic-shift and pivotal-event heuristics. Tag each emerging area's subdomain as **Core / Supporting / Generic**.
3. List the user-visible capabilities grouped by candidate boundary.

**Gate 2 (highest-leverage gate)**: Confirm the boundaries with the user before committing to units. Boundaries are the most expensive thing to get wrong — surface them explicitly and invite disagreement.

### Stage 3 — Unit decomposition

Read `inception-decomposition.md` (§3, §4). Group capabilities into **Units of Work**, each an independently-shippable vertical slice. For every unit, record:

- `id` (e.g., `U1`), short **name** (kebab-case, becomes the spec slug)
- **purpose** (one sentence), **responsibilities** (bullets of capabilities it owns)
- **in-scope / out-of-scope** boundaries
- **independent-test statement**: "Can be fully verified by [action] and delivers [value]."
- **priority** P1 / P2 / P3 + one-line "why"
- **subdomain class** (Core / Supporting / Generic), rough **size** (S / M / L)
- **kind** (per `docs/settings/rules/spec-kinds.md`)

Validate every unit against INVEST. Split any oversized unit using Lawrence's nine patterns (§4). Prefer roughly equal-sized units; carve off low-value functionality so it can be deprioritized.

`<plan-id>` = `<YYYY-MM-DD>-<project-slug>` using today's date and a short kebab-case slug of the goal.

Write `docs/inception/<plan-id>/units.md` from the `units.md` template, with the plan's non-goals at its head.

**Gate 3**: Review the unit list, sizes, and independent-test statements with the user.

### Stage 4 — Dependencies & build order

Read `inception-decomposition.md` (§5, §6). Then:

1. Build the **dependency matrix** (per unit: depends-on) and the **integration points** table.
2. Identify the **walking-skeleton** unit (`inception-decomposition.md` §6) and sequence it first.
3. Topologically sort the rest (dependencies first), breaking ties by priority then subdomain class. Mark genuinely independent units as parallel-capable.
4. Confirm the matrix is **acyclic** — a cycle means a boundary from Stage 2 is wrong; go back and re-cut.

Write `docs/inception/<plan-id>/dependencies.md` (matrix + integration points + the ordered build sequence).

**Gate 4**: Review the build order and dependency matrix with the user. Run the §7 quality checklist. When a canon layer is declared (`docs/steering/product.md §Canon References`), open the Gate 4 presentation with the canon changes, following `docs/settings/rules/canon-layer.md §Change Control`: product decisions and non-goals that the canon lacks (a non-goal that lands there leaves the head of `units.md`), and registry IDs the units adopt (`Used by` += `plan: <plan-id>/U<n>`). Their commit, on GO and before Stage 5, is `docs(canon): plan <plan-id>`.

### Stage 5 — Scaffold child specs

For each unit, in build order, create a stub SDD spec so it can enter the normal flow:

1. Generate the spec directory `docs/tasks/todo/<YYYY-MM-DD>-<unit-slug>/`, resolving name conflicts as `/sdd-spec-init` does.
2. Write `spec.json` from `docs/settings/templates/specs/init.json`, replacing `{{FEATURE_NAME}}` and `{{TIMESTAMP}}`, setting `language` and the unit's `kind` with its approvals per `docs/settings/rules/spec-kinds.md` §4, and filling the **`plan` linkage block**:
   ```json
   "plan": {
     "parent": "<plan-id>",
     "unit_id": "<U#>"
   }
   ```
   The unit's priority and dependencies stay in the plan; spec.json does not copy them. Leave `phase` as `initialized`.
3. Write `requirements.md` from `docs/settings/templates/specs/requirements-init.md`, replacing `{{PROJECT_DESCRIPTION}}` with the unit's **purpose in one sentence plus a pointer to its unit entry** (e.g. `docs/inception/<plan-id>/units.md §U7`). The unit entry is the single seat of the scope brief — do not copy responsibilities, scope lists, or test statements into the stub (`document-hygiene.md`), and do **not** pre-write EARS criteria. `/sdd-spec-requirements` reads the referenced entry at elicitation time.

## Important constraints

- Do NOT generate per-unit requirements (EARS), research, or design here. Inception stops at boundaries, scope briefs, and sequencing. Each child spec generates its own detail later.
- Do NOT modify anything under existing `docs/tasks/*/` specs; only create new spec directories — except deleting the `todo/` spec of a unit a re-cut drops (`inception-decomposition.md` §8).
- Keep all artifacts in the language resolved from `--lang` / init.json.
- If the goal is actually a single feature (one vertical slice, no meaningful sub-boundaries), say so and recommend `/sdd-spec-init` instead of forcing an over-decomposition.

</instructions>

## Tool Guidance

- **Read** `docs/settings/rules/inception-decomposition.md`, the `docs/settings/templates/inception/*` templates, `docs/settings/templates/specs/init.json` + `requirements-init.md`, and the entire `docs/steering/` directory.
- For brownfield surveys, search file names and contents for a lightweight structural scan — avoid reading large files end-to-end.
- **Write** plan artifacts under `docs/inception/<plan-id>/` and spec stubs under `docs/tasks/todo/`.
- **Search the web** only if external domain knowledge is needed to find boundaries; keep it minimal.

## Output Description

Provide output in the configured language:

1. **Plan summary**: mode (greenfield/brownfield), plan-id, number of units.
2. **Roadmap table**: unit | kind | priority | size | subdomain class | depends-on | spec directory. Mark the walking-skeleton unit.
3. **Build order**: the ordered sequence, noting parallel-capable groups.
4. **Scaffolded specs**: list of created `docs/tasks/todo/<...>/` directories.
5. **Next steps**: start the first (walking-skeleton) unit, e.g. ``/sdd-spec-requirements <first-unit>`` → behaviors (when the kind produces behaviors) → research → design → tasks → impl → done, then move to the next unit in build order. Mention `/sdd-spec-status <feature-name>` for progress.

**Format**: concise Markdown. Keep the summary readable at a glance.

## Safety & Fallback

- **SDD not initialized**: if `docs/settings/` is missing, stop and tell the user to run `/sdd-init` first.
- **Goal too small**: if it's really one feature, recommend `/sdd-spec-init` instead of decomposing.
- **Circular dependency detected**: stop at Gate 4, explain which boundary is implicated, and revise Stage 2/3 rather than scaffolding.
- **Template missing**: report the specific missing path and suggest re-running `/sdd-init` (Update mode) to redeploy templates.
- **User stops at a gate**: leave already-written plan artifacts in place (they're resumable) and do not scaffold specs until Gate 4 is approved.
