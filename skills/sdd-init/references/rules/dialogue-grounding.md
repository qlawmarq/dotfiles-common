# Dialogue Grounding Rules

## Objective

Make conversation about an SDD project *grounded* — every claim traceable to a document, every question aimed at a real gap. These rules govern the read-and-discuss skills (`/sdd-brief`, `/sdd-grill`), which differ from the rest of the SDD suite: the other skills advance a spec through its phases, while these two answer questions and settle open decisions across the whole project.

The problem they exist to solve is scale. A mature SDD project accumulates steering, an inception plan, and dozens of specs — tens of thousands of lines across hundreds of files. Nobody, human or agent, can hold that in view at once. Answering "what did we decide about X?" by reading everything is impossible; answering it by guessing is worse. These rules define the third option: targeted retrieval through indexes, with citations.

## The document map

Build the map at runtime from what actually exists. Do not assume any layer is present, and do not assume the list is complete — a project may keep additional documentation directories of its own. Check, then work with what you find.

| Layer | Path | What it holds | How to read it |
| --- | --- | --- | --- |
| Steering | `docs/steering/` | Project-wide rules and context: `product.md` (why/what), `tech.md`, `structure.md`, plus custom files | Small enough to read fully when the topic is project-wide; otherwise read the file that owns the topic |
| Canon (optional) | declared in `product.md §Canon References` (default `docs/canon/`) | Product decisions: `decisions/` (the why), `registry.md` (enumerable norms); `proposals/archive/`, if present, is history only | `README.md` decision log and `registry.md` are the indexes; JIT-grep decisions by their `keywords` line. Committed text is in force; uncommitted edits bind nothing (`canon-layer.md`) |
| Inception | `docs/inception/<plan-id>/` | `vision.md`, `units.md`, `dependencies.md`, `story-map.md`, `inception.json` — unit boundaries and build order | Read `inception.json` for the unit→spec map first; `units.md` is often large, so target the relevant unit |
| Specs | `docs/tasks/todo/<feature>/`, `docs/tasks/done/<feature>/` | `spec.json`, `requirements.md`, `research.md`, `design.md`, `tasks.md` | `spec.json` is small — read all of them freely. The Markdown files are large; open only the ones the question touches |
| Settings | `docs/settings/rules/`, `docs/settings/templates/` | The methodology itself | Read a rule only when you need the technique it defines |

If the project has documentation outside these paths, discover it (its root `README.md` or `CLAUDE.md` / `AGENTS.md` usually names it), note whether it is authoritative or historical, and respect any stated read-only or change-control conventions. Never edit a directory the project describes as archival.

## Index-first retrieval

Reading is cheap only if you read the right thing. Follow this order and stop as soon as you can answer:

1. **Indexes before bodies.** Read the index that names things before the documents themselves: `inception.json` for the unit→spec map, `spec.json` for a spec's phase and approvals, a directory's `README.md` when it exists. These are small and tell you where to go.
2. **Structure before prose.** Grep for headings, or read a long file's table of contents, before reading its body. A 600-line `design.md` usually answers the question in one section.
3. **Keywords, not sweeps.** Search for the domain term the user actually used. Follow the terms the documents use for each other — cross-references are the fastest path between layers.
4. **Whole files only when small or central.** Reading `docs/steering/product.md` end-to-end is reasonable. Reading every `design.md` in the project is not.

**Never bulk-load the corpus.** Do not read all specs, all design documents, or an entire large directory to "have context." If you find yourself opening files without a specific question each one is meant to answer, stop and go back to the index.

When a question needs several independent lookups, dispatch sub-agents to run them in parallel and report back with citations. This keeps large files out of the main context.

## Citations

Every factual claim carries its source, as a repo-relative path plus the narrowest locator you have:

- `docs/steering/product.md` — the section heading, when the file has sections
- `docs/tasks/done/<feature-name>/design.md §Data Model`
- `docs/tasks/todo/<feature-name>/spec.json` — `phase`, `approvals.requirements.approved`
- `<canon-root>/registry.md #FAC-01` — a registry entry, by its immutable ID

Distinguish three kinds of statement and label them when the difference matters:

- **Documented** — it says this, here. Cite it.
- **Inferred** — you concluded it by combining documented facts. Say which ones, so the reader can check the reasoning.
- **Unknown** — the documents do not settle it. Say so plainly. An honest "this is not written down anywhere" is a useful finding; a plausible-sounding invention is a defect that propagates.

Never present an inference as documented. In a project where specs are the contract, a fabricated citation is worse than no answer.

## Facts are yours, decisions are the user's

Finding facts is your job, never the user's. If a question can be answered by reading the repository, running a search, or checking a tool, do that — do not ask the user for something you could look up. Asking a user to recall what their own documents say wastes their time and invites a wrong answer.

Decisions are the opposite. Where the project genuinely has not chosen — a boundary, a trade-off, an acceptance threshold — that choice belongs to the user. Put it to them and wait.

A recommendation is not a decision. When you suggest an answer, it is a **proposal**, and the default answer to an unconfirmed proposal is *no*. This is the same discipline `requirements-elicitation.md` applies to requirements, and for the same reason: an agent's instinct to be helpful is what silently converts "I suggested this" into "we decided this." Nothing becomes settled without an explicit user confirmation.

## Where dialogue output lands

A conversation that evaporates when the session ends has produced nothing. Whatever gets settled must reach a document — but through the project's own change-control, not around it.

- **Read-only dialogue** (`/sdd-brief`) writes nothing. It answers and cites.
- **Settled decisions** (`/sdd-grill`) route to the artifact that owns them: an open question in `requirements.md` gets resolved there; a design choice belongs in `design.md`; a project-wide rule belongs in steering; a unit boundary belongs in the inception plan — all subject to the normative-content rule below.
- **Normative content lands under its protocol, never quietly.** A decision that belongs to the canon layer or the registry lands through the "Canon changes" protocol (`canon-layer.md §Change Control`: full text of changed sections shown first, one confirmation for anything overturned, a standalone `docs(canon):` commit after the user's yes). Steering's normative content (product policies and scope, `behaviors.md` invariants) lands by present-diff-and-confirm, one item at a time.
- **Approved artifacts are not edited silently.** If a spec's `spec.json` shows a phase approved, changing what it says is a re-approval, not an edit. Surface the change and get explicit confirmation before writing.
- **Change control wins.** If the project documents a process for changing a class of decision — a required separate session, a review gate, an issue-first convention — follow it, even when you have the answer in hand. Record the outcome in whatever intake the process defines and stop there. Check the project's root `CLAUDE.md` / `AGENTS.md` for such conventions before writing to any layer.
- **Always leave a record.** Even when nothing can be written to a canonical document, end the session with a summary of what was settled and what remains open, so the reasoning survives the session.

## Scope discipline

These skills read broadly, so they are prone to sprawl. Two boundaries keep them useful:

- **Answer the question asked.** A request to check one spec's status is not an invitation to audit the project. Offer the adjacent finding in a sentence; do not pursue it uninvited.
- **Do not do other phases' work.** These skills do not author requirements, produce designs, or generate tasks. When a conversation reaches the point where a spec artifact should be written, name the skill that owns that phase and hand off.
