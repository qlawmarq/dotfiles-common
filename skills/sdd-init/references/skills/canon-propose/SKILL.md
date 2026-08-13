---
name: sdd-canon-propose
description: >-
  Draft a delta proposal against the canon (ADDED/MODIFIED/REMOVED) — the only
  write path into ratified concept decisions and registry norms. Scaffolds the
  canon layer on first use. Merging happens only via /sdd-canon-ratify.
argument-hint: "\"change description\" [--from=<spec-or-session>]"
---

# Canon Delta Proposal

<background_information>

- **Mission**: Turn a proposed change to canon content — concept decisions, registry entries — into a well-formed delta proposal awaiting ratification, instead of a direct edit. Drafting is free and fast here; force is granted only in `/sdd-canon-ratify` (`canon-layer.md §Change Control`).
- **The proposal is the review script.** `/sdd-canon-ratify` presents this file's sections verbatim, records verdicts into it, and archives it as the permanent audit trail — so organize it by target file/section, and write it for a reader who has not opened a canon file. A proposal only a canon insider can read produces a review only a canon insider can judge — the exact failure this layer exists to prevent.
- **Success Criteria**:
  - Deltas stated against the **current ratified state**.
  - Every item judgeable by someone who has not read the canon, and carrying grounds and a declared tier.
  - No canon or registry file was edited.

</background_information>

<instructions>

## Input

1. **Change description** (positional): what should change and why. May be a settled outcome handed off from `/sdd-grill`, an open question from the canon README, a divergence found during a spec, or a new decision the user wants drafted.
2. **`--from=<spec-or-session>`** (optional): source pointer recorded in the proposal header.

If no input is given, list the canon README's open questions and ask which to draft against.

## Methodology

Read `docs/settings/rules/canon-layer.md` (structure, change control), `docs/settings/rules/ratification.md` (status vocabulary, what makes an item contentious), and `docs/settings/rules/document-hygiene.md`. Read `normative-registry.md` **only if** the change touches enumerable norms. Follow `dialogue-grounding.md` for retrieval and citations.

## Step 1: Resolve or Scaffold the Canon Root

1. Resolve the canon root from `docs/steering/product.md §Canon References` (default `docs/canon/`).
2. **If it does not exist**: propose scaffolding it from `docs/settings/templates/canon/` — `README.md`, `decisions/`, `registry.md`, `proposals/`, `proposals/archive/` — and, with the user's confirmation, create it and add the Canon References declaration to `product.md` (steering changes by present-diff-and-confirm; the declaration is a pointer, not a norm).
3. **If it exists but is not structured** — a pre-existing document set moved into the canon root, with no `README.md`, `registry.md`, or `proposals/`: propose completing the scaffold *around* the existing files without rewriting their content. Everything already there is `draft` until ratified, however long it has been treated as settled — the material was never judged, which is exactly why it is being brought under this process. Adopting a corpus is **several proposals, one per topic cluster**, each sized to the reading budget (`ratification.md §Section Review`); an adoption proposal lists files as its sections, and ratification reviews at file granularity. Present the clusters you found and let the user pick the first.

## Step 2: Establish the Current Ratified State

- JIT-grep the decisions and registry for everything the change touches. Identify exactly which items (by ID) are affected and what their current status is.
- If the change collides with an in-flight proposal, say so — two proposals touching the same item must be merged or sequenced.

## Step 3: Draft the Proposal

Create `<canon-root>/proposals/YYYY-MM-DD-<slug>.md` from `docs/settings/templates/canon/proposal.md`. The template's shape is the contract: one `##` per target file/section (the review round presents one at a time), one `###` per item with a one-line summary, the final `Text` (MODIFIED restates the whole item with the previous text noted), compact `Grounds`, and an inline `[high-risk: …]` flag where one applies. **Do not also paste an assembled target** — the duplicate leaves the reviewer unable to tell which text is under judgment.

Three things the template cannot enforce:

- **Flag honestly.** Anything that conflicts with a ratified item, supersedes or removes one, is irreversible, or floats without ratified grounds carries a `[high-risk: …]` flag — never quietly unflagged. When floating holds for the whole proposal — normal for a first proposal or a brownfield adoption — say it once in `caveats` rather than per item. Grounds stay compact but never a bare citation code the reader must resolve across three files.
- **Size to the reading budget.** A proposal whose new/changed text exceeds ~1,000–2,500 words (`ratification.md §Section Review`) is pre-split into section clusters, each ratifiable in one session.
- **Where content goes.** Enumerable norms become registry entries (proposed IDs, declared scheme); their *why* becomes decision prose. A list drafted into prose violates the registry's single-seat rule from birth. Every delta is `draft` by definition.

## Step 4: Hand Off

- Report the proposal path and a per-item one-line summary — a listing, not the ratification presentation.
- State plainly: **nothing in this proposal has any force yet.** Next step: `/sdd-canon-ratify <proposal-file>`.
- Do not start the ratification dialogue here, even if the user seems ready — the judge should arrive with the deltas laid out, not mid-generation.

## Important Constraints

- Do NOT edit `decisions/`, `registry.md`, or the canon README's decision log. The only writes are the new proposal file, the confirmed bootstrap scaffold, and adding an open question to the README when the user defers instead of drafting.
- Do NOT invent scope: every item traces to the user's request, a cited gap, or a cited source.

</instructions>

## Tool Guidance

- **Read** the rules named in §Methodology and the proposal template; **Grep** decisions and registry for affected items and collision checks.
- **Write** the proposal file (and scaffold files on bootstrap, after confirmation).
- **Sub-agents** for consumer-impact lookups (which specs, plans, or code reference an item being modified) — their findings populate `affected:`.

## Output Description

Resolve the output language from `docs/settings/templates/specs/init.json` `language` (default `ja`) and write the proposal and the report in it. Status markers stay English (`ratification.md`).

1. **Current state**: affected items and their statuses, with citations.
2. **Proposal summary**: path, delta counts, contentious items declared.
3. **Next step**: the exact `/sdd-canon-ratify` invocation.

**Format**: concise Markdown, under 300 words excluding the proposal file.

## Safety & Fallback

- **No SDD setup** (`docs/settings/` missing): point to `/sdd-init` and stop.
- **Scaffold declined**: without a canon root there is nowhere to file. Record nothing, tell the user what was *not* created, and stop.
- **Change is not normative** (a mechanical tech/structure fact, a spec-internal detail): say it needs no proposal and name the right path (`/sdd-steering` sync, or the owning spec skill).
- **Collision with an in-flight proposal**: present both, recommend merge or sequencing, let the user choose before drafting.
- **An item resists a plain-language *what changes***: that is a signal the unit is too big or not yet understood — split it, or file it as an open question instead of drafting around the gap.
