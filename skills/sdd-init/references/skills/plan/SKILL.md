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
argument-hint: "[\"product or project goal\"] [--lang=ja] [--batch]"
---

# SDD Inception & Planning Orchestrator

<background_information>

- **Mission**: Decompose a large development goal into an ordered roadmap of independently-shippable **Units of Work**, then scaffold one SDD spec per unit so each can be developed through the normal `/sdd-spec-*` flow with small, bounded context.
- **Why this exists**: The per-feature SDD flow is excellent for one feature, but a whole product crammed into one spec produces an overwhelming requirements/design/tasks set. This skill is the planning layer above specs — it defines *what the units are, where their boundaries lie, and in what order to build them*, and deliberately defers each unit's detailed requirements/design to that unit's own spec.
- **Success Criteria**:
  - A vision is captured and confirmed with the user.
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
3. **`--batch`** (optional): run autonomously, skipping the interactive clarification dialogue and the per-stage approval gates. Use only when the user explicitly wants a fast first-pass draft they will review at the end.

## Methodology

The decomposition method — where to cut boundaries, how to size and split units, how to order them — lives in `docs/settings/rules/inception-decomposition.md`. **Read it before Stage 2.** This SKILL.md governs the workflow and gates; that file governs the technique.

## Operating principle: bounded context

This skill is itself prone to the context bloat it's meant to cure. Keep plan artifacts at the level of *boundaries, scope, and dependencies* — NOT full per-unit requirements or design. Write patterns and one-liners, not exhaustive detail. The detail belongs in each child spec, generated later in its own fresh context. If you find yourself writing EARS acceptance criteria or interface signatures during planning, stop — that work is `/sdd-spec-requirements` and `/sdd-spec-design`, run per unit.

## Workflow

Run as five staged stages, each ending in a human **approval gate** (GO / revise / stop). At each gate, present the artifact concisely and ask the user to approve or request changes before proceeding. In `--batch` mode, skip the gates and run straight through, then present everything for a single review at the end. The gates exist because planning mistakes are expensive to unwind once specs are scaffolded — it is far cheaper to correct a boundary now than after ten specs depend on it.

### Stage 0 — Intake & mode detection

1. Confirm prerequisites: `docs/settings/` and `docs/steering/` should exist (SDD is initialized). If not, tell the user to run `/sdd-init` first and stop.
2. Detect the mode:
   - **Greenfield (0→1)**: little or no application code yet.
   - **Brownfield (scaling a prototype)**: existing code/steering present.
   Decide by a quick check (presence of source beyond config, and whether steering files have real content).
3. Load shared context: read the entire `docs/steering/` directory (product/tech/structure + custom). For brownfield, also do a **lightweight** survey of the codebase (entry points, top-level structure, existing capabilities) — just enough to ground boundaries; do not exhaustively read the repo.
4. Capture the goal (from the argument or by asking).

**Gate 0**: Confirm the mode and a one-paragraph restatement of the goal with the user.

### Stage 1 — Vision & elaboration

Ask a focused set of high-leverage clarifying questions — not an interrogation. Cover only what changes the decomposition: the core problem, target users, the few outcomes that define success, hard constraints (tech, compliance, timeline), expected scale, and **explicit non-goals**. Propose answers where the steering or codebase already implies them, and let the user correct — this respects their time.

Write `docs/inception/<plan-id>/vision.md` from the `vision.md` template. Keep it tight (problem, users, outcomes, success signals, constraints, non-goals).

`<plan-id>` = `<YYYY-MM-DD>-<project-slug>` using today's date and a short kebab-case slug of the goal.

**Gate 1**: Review the vision with the user.

### Stage 2 — Capability map & boundary discovery

Read `docs/settings/rules/inception-decomposition.md` (§2). Then:

1. List the product's significant **domain events** (past tense) along its timeline.
2. Identify **bounded contexts** using the linguistic-shift and pivotal-event heuristics. Tag each emerging area's subdomain as **Core / Supporting / Generic**.
3. Produce a draft **capability/story map**: the user-visible capabilities grouped by candidate boundary.

**Gate 2 (highest-leverage gate)**: Confirm the boundaries with the user before committing to units. Boundaries are the most expensive thing to get wrong — surface them explicitly and invite disagreement.

### Stage 3 — Unit decomposition

Read `inception-decomposition.md` (§3, §4). Group capabilities into **Units of Work**, each an independently-shippable vertical slice. For every unit, record:

- `id` (e.g., `U1`), short **name** (kebab-case, becomes the spec slug)
- **purpose** (one sentence), **responsibilities** (bullets of capabilities it owns)
- **in-scope / out-of-scope** boundaries
- **independent-test statement**: "Can be fully verified by [action] and delivers [value]."
- **priority** P1 / P2 / P3 + one-line "why"
- **subdomain class** (Core / Supporting / Generic), rough **size** (S / M / L)

Validate every unit against INVEST. Split any oversized unit using Lawrence's nine patterns (§4). Prefer roughly equal-sized units; carve off low-value functionality so it can be deprioritized.

Write `docs/inception/<plan-id>/units.md` from the `units.md` template.

**Gate 3**: Review the unit list, sizes, and independent-test statements with the user.

### Stage 4 — Dependencies & build order

Read `inception-decomposition.md` (§5, §6). Then:

1. Build the **dependency matrix** (per unit: depends-on + integration method) and the **integration points** table.
2. Identify the **walking-skeleton** unit — the thinnest end-to-end slice through every architectural seam — and sequence it first.
3. Topologically sort the rest (dependencies first), breaking ties by priority then subdomain class. Mark genuinely independent units as parallel-capable.
4. Confirm the graph is **acyclic** — a cycle means a boundary from Stage 2 is wrong; go back and re-cut.

Write `docs/inception/<plan-id>/dependencies.md` (matrix + a Mermaid graph + the ordered build sequence) and `docs/inception/<plan-id>/story-map.md` (every capability mapped to exactly one unit).

**Gate 4**: Review the build order and dependency graph with the user. Run the §7 quality checklist.

### Stage 5 — Scaffold child specs

For each unit, in build order, create a stub SDD spec so it can enter the normal flow:

1. Generate the spec directory `docs/tasks/todo/<YYYY-MM-DD>-<unit-slug>/`, resolving same-day name collisions with a numeric suffix (same convention as `/sdd-spec-init`). Check `docs/tasks/todo/` and `docs/tasks/done/` for conflicts.
2. Write `spec.json` from `docs/settings/templates/specs/init.json`, replacing `{{FEATURE_NAME}}` and `{{TIMESTAMP}}`, setting `language`, and filling the **`plan` linkage block**:
   ```json
   "plan": {
     "parent": "<plan-id>",
     "unit_id": "<U#>",
     "priority": "<P1|P2|P3>",
     "depends_on": ["<sibling-feature-name>", ...]
   }
   ```
   `depends_on` lists the **feature-names** (spec directory names) of prerequisite units, so downstream tooling can resolve order. Leave `phase` as `initialized`.
3. Write `requirements.md` from `docs/settings/templates/specs/requirements-init.md`, replacing `{{PROJECT_DESCRIPTION}}` with the unit's **scope brief**: its purpose, responsibilities, in/out-of-scope, independent-test statement, priority, and dependency notes. This seeds `/sdd-spec-requirements` with rich grounding while leaving the actual EARS requirements to that phase. Do **not** pre-write EARS criteria here.
4. Record the unit → spec-directory mapping.

Finally, write `docs/inception/<plan-id>/inception.json` (plan metadata + the unit→spec mapping + status).

## Important constraints

- Do NOT generate per-unit requirements (EARS), research, or design here. Inception stops at boundaries, scope briefs, and sequencing. Each child spec generates its own detail later.
- Do NOT modify anything under existing `docs/tasks/*/` specs; only create new spec directories.
- Keep all artifacts in the language resolved from `--lang` / init.json. EARS keywords (when they later appear in specs) stay English; everything else follows the configured language.
- If the goal is actually a single feature (one vertical slice, no meaningful sub-boundaries), say so and recommend `/sdd-spec-init` instead of forcing an over-decomposition.

</instructions>

## Tool Guidance

- **Read** `docs/settings/rules/inception-decomposition.md`, the `docs/settings/templates/inception/*` templates, `docs/settings/templates/specs/init.json` + `requirements-init.md`, and the entire `docs/steering/` directory.
- For brownfield surveys, use Glob/Grep for a lightweight structural scan — avoid reading large files end-to-end.
- **Write** plan artifacts under `docs/inception/<plan-id>/` and spec stubs under `docs/tasks/todo/`.
- Use **WebSearch/WebFetch** only if external domain knowledge is needed to find boundaries; keep it minimal.

## Output Description

Provide output in the configured language:

1. **Plan summary**: mode (greenfield/brownfield), plan-id, number of units.
2. **Roadmap table**: unit | priority | size | subdomain class | depends-on | spec directory. Mark the walking-skeleton unit.
3. **Build order**: the ordered sequence, noting parallel-capable groups.
4. **Scaffolded specs**: list of created `docs/tasks/todo/<...>/` directories.
5. **Next steps**: start the first (walking-skeleton) unit, e.g. ``/sdd-spec-requirements <first-unit>`` → research → design → tasks → impl → done, then move to the next unit in build order. Mention `/sdd-spec-status <feature-name>` for progress.

**Format**: concise Markdown. Keep the summary readable at a glance.

## Safety & Fallback

- **SDD not initialized**: if `docs/settings/` is missing, stop and tell the user to run `/sdd-init` first.
- **Goal too small**: if it's really one feature, recommend `/sdd-spec-init` instead of decomposing.
- **Circular dependency detected**: stop at Gate 4, explain which boundary is implicated, and revise Stage 2/3 rather than scaffolding.
- **Name collision**: append a numeric suffix to the unit slug (same as `/sdd-spec-init`) and note it.
- **Template missing**: report the specific missing path and suggest re-running `/sdd-init` (Update mode) to redeploy templates.
- **User stops at a gate**: leave already-written plan artifacts in place (they're resumable) and do not scaffold specs until Stage 5 is approved.
