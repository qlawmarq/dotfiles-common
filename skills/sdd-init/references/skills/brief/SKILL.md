---
name: sdd-brief
description: >-
  Answer questions about an SDD project by reading across steering, inception, and every spec.
  Use when the user asks what was decided about something, where the project currently stands,
  what is blocking progress, or what needs deciding next — anything that spans more than one spec.
argument-hint: "[\"question\"] [--scope=steering|inception|spec:<feature-name>|all]"
---

# SDD Project Briefing

<background_information>

- **Mission**: Answer a question about the project by retrieving what the documents actually say, across every SDD layer, with citations — without loading the corpus.
- **Why this exists**: `/sdd-spec-status` reports on one specification. Everything else in the SDD suite writes rather than reads. As a project accumulates steering, an inception plan, and dozens of specs, the question "what did we decide about X?" stops having a cheap answer: the material is spread across layers that cross-reference each other, and no single file holds the view. This skill is that view, assembled on demand.
- **Success Criteria**:
  - The question is answered from documented content, with a repo-relative citation for every claim.
  - Retrieval was targeted — indexes and keywords, not sweeps.
  - What the documents do *not* settle is stated as unknown rather than filled in.
  - Nothing is written.

</background_information>

<instructions>

## Input

1. **Question** (optional positional): what the user wants to know. If omitted, give the orientation briefing (Shape B below).
2. **`--scope=<area>`** (optional): narrow the search to `steering`, `inception`, `spec:<feature-name>`, or `all` (default).

## Methodology

Read `docs/settings/rules/dialogue-grounding.md` before answering. It defines the document map, the retrieval order, and the citation format this skill depends on.

## This skill is read-only

It answers; it does not write. Do not create, edit, or reorganize any file — not even to "fix" something you notice while reading. If the question turns out to need a change, say what change it needs and name the skill that owns it.

## Three shapes of question

Most requests are one of these. Identify which before retrieving — they need different entry points.

### Shape A — "What was decided about X?"

A topic lookup. The answer lives somewhere specific and the work is finding it.

1. Grep for the user's own domain term across `docs/steering/`, `docs/inception/`, and `docs/tasks/` — and across the canon root when `product.md §Canon References` declares one, since that is where product decisions actually live. Use the vocabulary they used; follow the terms the documents use for each other.
2. Follow cross-references between layers. A decision recorded in steering is usually applied in a spec, and a spec usually cites the steering or unit that constrains it — the fastest path between layers is the reference the documents already contain.
3. Report the decision, where it is recorded, and — when it matters — where it is *applied*. Note supersession: if a later spec or steering file changed an earlier decision, say which is current.
4. **Report what is in force, not what is drafted.** In the canon, committed text is the decision (`docs/settings/rules/canon-layer.md`); uncommitted working-tree edits and README Open Questions are not — check `git status -- <canon-root>` and say plainly when the honest answer is "edited, not yet committed" or "still an open question". `proposals/archive/`, where it exists, is history, not the current view.

### Shape B — "Where does the project stand?"

A cross-spec status report. This is the horizontal counterpart to `/sdd-spec-status`.

1. Read every `docs/tasks/todo/*/spec.json` and `docs/tasks/done/*/spec.json`. They are small — read them all.
2. For each: `kind`, `phase`, `approvals.*.approved`, and the `plan` block (`unit_id`, `priority`, `depends_on`); for a `verify` spec, read `verdict.md` when it exists.
3. For specs with a `tasks.md`, count `- [x]` against `- [ ]` for implementation progress.
4. Assemble: what is in flight, what is blocked and on what, what is done, and which unfinished specs nothing depends on.
5. If an inception plan exists, read its `inception.json` for the unit→spec map and report progress against the intended build order.

Flag anything that looks stalled — a spec sitting in an early phase while specs that declare it in `depends_on` are further along — but report it as an observation, not a verdict.

### Shape C — "What should I decide next?"

A backlog of unresolved decisions. Collect, do not resolve.

1. *Assumptions & Open Questions* sections across `requirements.md` files, and open points in `design.md` files.
2. Specs with `approvals.*.approved: false` — work waiting on human review.
3. When a canon layer exists: its README's Open Questions table, and any uncommitted canon edits (`git status -- <canon-root>`) — drafted content that binds nothing until committed.
4. Any decision intake the project maintains, if its root `AGENTS.md` documents one.

Order by what unblocks the most: a decision that several specs depend on outranks one confined to a single spec. Then hand off — `/sdd-grill` is the skill that actually works through them with the user.

## Answering

- **Lead with the answer.** The user asked a question; give the answer first, then the support.
- **Cite everything.** Repo-relative path plus the narrowest locator you have. See `dialogue-grounding.md` §Citations.
- **Separate documented from inferred.** When you combined facts to reach a conclusion, say which facts.
- **Say when it is not written down.** "The documents do not settle this" is a real answer and often the most useful one — it tells the user they have a gap. Never fill the gap with a plausible invention.
- **Match the question's size.** A one-fact lookup gets a couple of sentences, not a report with headings.

## Important constraints

- Do NOT write, edit, or create any file.
- Do NOT bulk-load. `spec.json` files can be read exhaustively; `design.md` and `research.md` files cannot. Use sub-agents for independent lookups so large files stay out of the main context.
- Do NOT audit beyond the question. Mention an adjacent finding in one line; do not pursue it uninvited.
- Do NOT do another phase's work. Point at the owning skill instead.

</instructions>

## Tool Guidance

- **Read** `docs/settings/rules/dialogue-grounding.md`, then the indexes: `spec.json` files, `inception.json`, `docs/steering/product.md`.
- **Grep/Glob** for topic lookups and for locating open-question sections — search headings before bodies.
- **Sub-agents**, via whatever delegation tool the host harness provides, to run independent lookups in parallel — instructed to report findings with citations rather than file contents. If the harness has no sub-agent tool, do the lookups inline but keep them index-first.
- **Never** Edit, Write, or NotebookEdit.

## Output Description

Provide output in the project's configured language, resolved in this order: if `--scope=spec:<feature-name>`, that spec's `spec.json` `language`; otherwise `docs/settings/templates/specs/init.json` `language`; failing both, `ja`.

- **Shape A**: the answer, its citation, where it is applied, and current-vs-superseded if relevant.
- **Shape B**: a compact table — spec | kind | phase | approvals | depends_on | progress — plus a short prose read of what is in flight, blocked, and stalled, and the recommended next action.
- **Shape C**: the open decisions ordered by how much each unblocks, each with its citation, ending with a pointer to `/sdd-grill`.

**Format**: Markdown, proportionate to the question. Tables only for enumerable facts; explanation in prose around them.

## Safety & Fallback

- **SDD not initialized**: `docs/settings/` missing → say so and suggest `/sdd-init`.
- **Nothing found for the topic**: report that plainly, list where you searched, and offer the nearest related material rather than guessing at an answer.
- **Ambiguous question**: if the topic could mean two different things in the project's vocabulary, answer the more likely reading and name the other in a sentence — do not stall on a clarifying question you can resolve by reading.
- **Conflicting sources**: report the conflict as the finding, cite both sides, and do not pick a winner. That is a decision, and `/sdd-grill` is where decisions get made.
- **No specs yet**: say the project has no specifications and point at `/sdd-plan` (large effort) or `/sdd-spec-init` (single feature).
