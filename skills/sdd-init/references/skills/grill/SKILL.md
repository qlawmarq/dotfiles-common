---
name: sdd-grill
description: >-
  Relentlessly interview the user to settle open decisions in an SDD project.
  Builds a design tree from real gaps found in steering, inception, and specs,
  then works it in rounds until nothing is left silently assumed.
argument-hint: "[\"topic\"] [--scope=steering|inception|spec:<feature-name>|cross]"
disable-model-invocation: true
---

# SDD Grilling Session

<background_information>

- **Mission**: Reach a shared understanding on the open decisions of an SDD project by interviewing the user, grounding every question in what the project's documents actually say, and landing what gets settled back into the right artifact.
- **Why this exists**: The SDD skills each advance one spec through one phase, and each validates within its own boundaries. Nothing in the suite interrogates the project *across* its layers — where steering, the inception plan, and the specs quietly disagree, or where a spec was approved with an assumption nobody ever resolved. Those gaps do not surface on their own; they surface as rework. This skill goes looking for them and puts them to the user as decisions.
- **Success Criteria**:
  - The design tree is seeded from real, cited gaps — not from generic curiosity.
  - Every round asks the whole current frontier, each question carrying a recommended answer marked as a proposal.
  - Facts were found by the agent; only decisions were asked of the user.
  - The session ends with a summary of what was settled, and settled items are routed to the artifacts that own them under the project's change control.

</background_information>

<instructions>

## Input

1. **Topic** (optional positional): what to grill about. If omitted, derive the topic from the seeded gaps and confirm it with the user before Round 1.
2. **`--scope=<area>`** (optional): where to root the tree.
   - `steering` — project-wide rules and product intent
   - `inception` — unit boundaries, sizing, build order
   - `spec:<feature-name>` — one specification
   - `cross` — contradictions *between* layers (the default when no scope is given and no topic narrows it)

## Methodology

Read `docs/settings/rules/dialogue-grounding.md` before Stage 0. It governs how to retrieve, how to cite, and where output lands. This file governs the interview itself.

## Stage 0 — Seed the tree

Do not open with questions. Open by finding out what is actually unsettled, then ask about that.

Confirm SDD is initialized (`docs/settings/` exists); if not, tell the user to run `/sdd-init` first and stop. Then sweep for gaps, using index-first retrieval and dispatching sub-agents for independent lookups:

- **Unapproved and stalled work** — every `docs/tasks/*/*/spec.json`: which have `approvals.*.approved: false`, which sit in an early `phase` while their dependents wait, which `plan.depends_on` chains are blocked.
- **Declared open questions** — the *Assumptions & Open Questions* sections of `requirements.md`, and any open points recorded in `design.md`. These are gaps the project already admitted; they are the highest-value seeds because someone deliberately deferred them.
- **Cross-layer contradictions** — where a spec's requirements or design conflict with `docs/steering/`, or with the unit boundary and scope recorded for it in the inception plan.
- **Theme alignment** — whether the behavior a spec describes actually serves the product intent in `docs/steering/product.md` and respects the invariants in `docs/steering/behaviors.md`. A spec can be perfectly consistent with itself and still be the wrong thing to build. The per-spec skills apply this check via the concept-alignment lens (`docs/settings/rules/concept-alignment.md`); here it runs *across* specs and layers, where the per-spec gates cannot see.
- **Silent assumptions** — decisions the documents depend on but never state: unstated acceptance thresholds, undefined edge cases, scope boundaries nobody drew.

Each seed becomes a node in the tree and must carry its citation. A gap you cannot cite is not a seed — it is a guess, and it does not belong in the tree.

If the sweep finds nothing unsettled in scope, say so and stop. Manufacturing questions to look thorough wastes the user's time.

## The design tree

Map the work as a **design tree**: every decision branches into the decisions that hang off it. Some questions cannot be asked yet because their answer depends on one still open.

The **frontier** is every decision whose prerequisites are already settled — the questions you can ask *now* without guessing at answers you have not heard yet. A question whose answer depends on another question open in this round belongs to a *later* round, not this one.

## Working in rounds

Ask the whole frontier in one round, then wait. Each round the user's answers reshape the tree — settled decisions push the frontier outward and unblock what depended on them. Recompute the frontier and ask the next round.

Format each question like this:

```
❓ **Q1** — **<short title>**

<why this matters: the concrete consequence of getting it wrong, and the citation for the gap>

- **A** — <option>
- **B** — <option>

➡️ **Proposal: <A/B/…>** — <your reasoning>
```

Give options when the decision has discernible alternatives; when it does not, state the question plainly and still give a proposal. Number questions continuously across rounds (Q1, Q2, … Q7) so the user and the closing summary can refer back to them.

Between rounds, keep the tree visible: say briefly what the last round settled and what it unblocked. The user should never have to reconstruct where the session is.

**Finding facts is your job, never the user's.** When a frontier question needs a fact from the repository or the environment, dispatch a sub-agent to find it — do not ask the user for anything you could look up. Do not block on it either: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report. Ask the rest of the frontier now.

**The decisions are the user's.** Put each to them and wait.

## The proposal rule

Every `➡️` is a **proposal, not a decision**. The default answer to an unconfirmed proposal is *no*. Nothing enters the settled set because you suggested it and the user did not object — only because they said yes.

This matters more here than in ordinary conversation. `requirements-elicitation.md` forbids inventing capabilities the user did not ask for, because gold-plating is the main source of rework in an SDD project. A grilling session generates proposals fast, which makes it an efficient way to smuggle unrequested scope into a spec. Do not let a proposal graduate to a decision without an explicit answer, and when the user's answer is ambiguous, ask again rather than resolving it in your own favor.

## Ending the session

The session is done when the **frontier is empty**: every branch of the tree visited, nothing left silently assumed. When you believe you have reached that point, say so and propose ending — if the user wants to keep going, keep going.

Then produce the closing summary, with these two sections in this order:

```
## Summary

### Settled
- **<title>** (Q1) — <the decision> → destination: <path>

### Still open
- **<title>** — <what remains unresolved, and why it was not settled>
```

Render the headings and body in the project's configured language (see §Language below) — the structure above is the contract, not the wording.

## Language

Resolve the output language once, at the start of the session:

1. If `--scope=spec:<feature-name>`, use that spec's `spec.json` `language`.
2. Otherwise use `docs/settings/templates/specs/init.json` `language`.
3. If neither specifies one, default to `ja`.

## Landing the outcome

Do not act on the session until the user confirms you have reached a shared understanding.

Once confirmed, route each settled decision to the artifact that owns it, following `dialogue-grounding.md` §"Where dialogue output lands":

- An open question declared in `requirements.md` or `design.md` is resolved in that file.
- A project-wide rule belongs in `docs/steering/` — propose it, and hand off to `/sdd-steering-custom` if it warrants its own file.
- **Canon content lands here directly** (a canon-level decision or a registry norm, when `product.md §Canon References` declares a canon layer): follow `canon-layer.md §Change Control` — dirty-check, edit the canon working tree, open the landing plan with `## Canon changes` (full text of changed sections; an overturned decision or changed Norm first as *previous → new* with its own confirmation), and after the user's yes commit only those files as `docs(canon): grill <topic>`. A steering change (product policy, scope, a `behaviors.md` invariant) lands by present-diff-and-confirm, presented one item at a time.
- A unit boundary or ordering change belongs in the inception plan.
- A decision governed by any additional change-control process the project documents is **filed into that process, not written directly**. Check the root `AGENTS.md` before writing to any layer.

Present the intended edits and get confirmation before writing. Editing content that `spec.json` records as approved is a re-approval — surface it as such rather than amending quietly.

## Important constraints

- Do NOT author requirements, designs, or tasks here. When the conversation reaches the point where a spec artifact should be produced, name the owning skill (`/sdd-spec-requirements`, `/sdd-spec-design`, `/sdd-spec-tasks`) and hand off.
- Do NOT ask the user anything the repository can answer.
- Do NOT bulk-load the corpus. Index-first retrieval, sub-agents for parallel lookups.
- Do NOT let the tree drift outside `--scope`. Note an out-of-scope finding in one line and move on.

</instructions>

## Tool Guidance

- **Read** `docs/settings/rules/dialogue-grounding.md` first, then `docs/steering/product.md` and the indexes (`spec.json`, `inception.json`) during the Stage 0 sweep.
- **Glob/Grep** to locate open-question sections and cross-layer contradictions — do not open large `design.md` / `research.md` files whole.
- **Sub-agents**, via whatever delegation tool the host harness provides, for independent fact-finding — dispatched in parallel and instructed to report findings with citations rather than file contents. If the harness has no sub-agent tool, do the lookups inline but keep them index-first.
- **Edit/Write** only after the user confirms the closing summary, and only on the artifacts identified in the landing step.

## Output Description

Provide all output in the language resolved in §Language:

1. **Stage 0 report**: the seeded gaps with citations, and the scope the session will cover.
2. **Each round**: what the previous round settled, then the numbered frontier questions in the format above.
3. **Closing summary**: the Settled / Still open sections defined in §"Ending the session", with a destination for each settled item.
4. **Landing plan**: the edits you intend to make, presented for confirmation.

**Format**: Markdown. One round per message — never ask a question and answer it yourself in the same breath.

## Safety & Fallback

- **SDD not initialized**: `docs/settings/` missing → tell the user to run `/sdd-init` first and stop.
- **No gaps found in scope**: report that the scope looks settled, cite what you checked, and offer a wider scope rather than inventing questions.
- **Scope too large to sweep**: if the project has many specs, sweep `spec.json` files for all of them (they are small) but limit the deep gap-reading to the specs the topic touches, and say which ones you covered.
- **User answers ambiguously**: treat the question as still open. Re-ask it in the next round rather than resolving it yourself.
- **User stops mid-session**: produce the closing summary for what was settled so far and list the unvisited branches, so the session is resumable.
- **Change control blocks a write**: record the outcome in the intake the process defines, tell the user which decisions are waiting on that process, and do not edit the governed files.
