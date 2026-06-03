# Inception & Decomposition Rules

How to decompose a large product goal into independently-shippable **Units of Work**, where each unit becomes one SDD spec. These rules exist because forcing a whole product into a single spec produces an unreadable requirements/design/tasks set — the context becomes too large to reason about well. Decomposition keeps each downstream spec small and self-contained, so its own context stays bounded.

This file is the reference for `/sdd-plan`. Read it when running the Inception workflow.

## Table of Contents

1. Principles
2. Finding boundaries (where to cut)
3. Sizing a unit (how big is one unit)
4. Splitting a unit that is too big
5. Dependencies and build order
6. Priority and sequencing
7. Quality gate before scaffolding

---

## 1. Principles

- **A unit is a vertical slice, not a layer.** A good unit cuts through the whole stack (UI → logic → data) so it is observably valuable to a user on its own. Slicing by architectural layer ("the database", "the API", "the frontend") is the anti-pattern — those pieces can't be demonstrated or shipped independently.
- **Each unit must stand alone.** If you implemented only one unit and nothing else, it should still produce something testable and demonstrable — ideally a viable (if minimal) product. This is the single most important property; it is what lets each unit become its own spec without entangling the others.
- **Patterns over exhaustiveness.** Inception defines *what the units are, where their boundaries lie, and how they depend on each other* — not the full requirements or design of each. Per-unit requirements (EARS), research, and design are deliberately deferred to each child spec's own flow. Resist the urge to fully specify a unit here; that re-creates the context-bloat problem you are trying to solve.
- **The plan is external memory.** The Inception artifacts (`vision.md`, `units.md`, `dependencies.md`, `story-map.md`) are written to disk so each downstream spec — running in its own fresh context — can read only the slice it needs.

## 2. Finding boundaries (where to cut)

Use these heuristics, drawn from Domain-Driven Design and event storming, to decide where one unit ends and the next begins:

- **Walk the timeline of events.** List the significant things that happen in the product as past-tense domain events ("order placed", "payment captured", "invitation accepted"). Boundaries tend to fall at **pivotal events** — points where the business process meaningfully shifts phase.
- **Listen for the language changing.** If the vocabulary (the nouns, the meaning of a word, the people who care) changes between one event and the next, you have likely crossed into a different bounded context. A "user" in the auth context and a "user" in the billing context are usually different units. This linguistic-shift test is the most reliable single signal.
- **Follow the money / value exchange.** Boundaries often sit where value is created or exchanged.
- **One team's mental model.** A unit should be small enough to fit in one mind (or one team) at a time. If understanding it requires holding two unrelated mental models, it is probably two units.
- **Classify each unit's subdomain** as **Core** (the differentiating heart of the product — invest most here), **Supporting** (necessary but not differentiating), or **Generic** (commodity; could be bought/reused). This classification feeds prioritization in §6.

Do not over-split. A bounded context is the *maximum* meaningful boundary; you may split further for delivery, but never merge across a linguistic boundary.

## 3. Sizing a unit (how big is one unit)

Target: each unit is an **independently shippable vertical slice**. Validate every candidate unit against **INVEST**:

- **I**ndependent — can be built and shipped without waiting on a sibling (soft dependencies are fine if sequenced; circular dependencies mean the boundary is wrong).
- **N**egotiable — describes an outcome, leaving room for the design phase to decide how.
- **V**aluable — delivers observable value to a user or the business on its own.
- **E**stimable — the team can roughly size it (S / M / L). If it's unestimable, it needs more discovery, not more detail.
- **S**mall — implementable as one focused spec. A useful gut check: if its eventual requirements would exceed ~7–10 distinct requirement areas, it's probably two units.
- **T**estable — has a concrete **independent-test statement**: "Can be fully verified by [action] and delivers [value]." If you can't write this sentence, the boundary is wrong.

Prefer **roughly equal-sized units** — this gives whoever sequences the roadmap maximum freedom. When sizes are lopsided, look for a split (§4) that carves the large one down or that peels low-value functionality out of it so it can be deprioritized.

## 4. Splitting a unit that is too big

When a candidate unit fails the **Small** test, split it using one of Richard Lawrence's nine patterns (pick the first that yields independently-valuable slices):

1. **Workflow steps** — ship the simplest end-to-end happy path first; add the middle steps and special cases as later units.
2. **Operations (CRUD)** — split "manage X" into create / read / update / delete.
3. **Business-rule variations** — one rule set per slice.
4. **Variations in data** — handle the simple data domain first, richer/edge data later.
5. **Data-entry methods** — simplest input first, fancy UI later.
6. **Major effort** — do the first hard instance ("support one payment provider"), then "the rest, given one exists."
7. **Simple/complex** — extract the simplest core; defer the variations.
8. **Defer performance** — "make it work" before "make it fast"; the optimization is a later unit.
9. **Break out a spike** — when the approach is genuinely unknown, carve a timeboxed investigation unit so the uncertainty doesn't block delivery.

Two tie-breakers: prefer the split that **exposes low-value functionality you can then deprioritize** (the 80/20 cut), and prefer splits that leave **roughly equal-sized** pieces.

## 5. Dependencies and build order

Produce a **dependency matrix** — for each unit: what it depends on, and how it integrates (shared data, synchronous call, event, shared library). Then derive the build order:

- **Topological sort**: units with no dependencies build first; dependents build after their prerequisites.
- **Independent units run in parallel** — units with no shared dependency are candidates for concurrent development tracks. But be honest: real software has fewer truly-parallel pieces than it first appears. Only call two units parallel when neither needs the other's interfaces or data.
- **Circular dependency = wrong boundary.** If A needs B and B needs A, the boundary in §2 is misplaced. Re-cut, or extract the shared piece into a third unit both depend on.
- Record integration points explicitly (initiator → target, method, rough frequency) so each child spec knows its contract surface without reading its siblings' designs.

## 6. Priority and sequencing

Order the roadmap by combining four signals, in this order:

1. **Walking skeleton first.** The very first unit should be the thinnest possible slice that exercises every architectural seam end-to-end — a tiny implementation that links the main components together and runs. It need not use the final architecture, but it is real (not a throwaway prototype) and it de-risks integration before any feature depth is built. Identify and sequence this unit first.
2. **Dependencies** (§5) — never schedule a unit before what it depends on.
3. **Value / priority** — assign each unit **P1 / P2 / P3** (P1 = most critical to a usable product) with a one-line "why this priority." Among dependency-eligible units, build higher priority first.
4. **Subdomain class** — when otherwise tied, Core before Supporting before Generic.

The result is an ordered, incremental delivery plan: each unit shipped makes the product observably more capable, rather than a big-bang where nothing works until everything is done.

## 7. Quality gate before scaffolding

Before turning units into specs, confirm:

- [ ] Every unit has an independent-test statement and passes INVEST.
- [ ] No unit is a horizontal layer; each is a vertical slice.
- [ ] The dependency graph is acyclic and has a clear build order.
- [ ] A walking-skeleton unit is identified and sequenced first.
- [ ] Units are roughly equal-sized, or the lopsided ones have a justified reason.
- [ ] Every capability/story from the vision maps to exactly one unit (nothing dropped, nothing duplicated).

If any check fails, revise the decomposition rather than scaffolding specs you'll have to untangle later.
