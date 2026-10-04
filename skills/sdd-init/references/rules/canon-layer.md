# Canon Layer

## Objective

Keep the product's concept decisions in one place, drafted by the agent and approved by the human **as a diff inside the SDD phase that produced them** — never in a separate ceremony. Two accidents this prevents: an unread AI draft gaining canonical force, and the same enumerable norm living in several seats. The layer is optional; a product whose philosophy fits in `docs/steering/product.md` does not need it.

## Structure

The root is declared in `docs/steering/product.md §Canon References` (default `docs/canon/`); never hardcode it. Templates: `docs/settings/templates/canon/`.

- `README.md` — index only: decision log (`ID | Decision | Keywords | File`) and Open Questions. No normative text.
- `decisions/<id>-<slug>.md` (template `decision.md`) — one topic per file (a file beyond ~100 lines opens with a table of contents): `keywords` line (the JIT grep index), Background (why), Decision (numbered items), optional Consequences, Registry refs (IDs only).
- `registry.md` — the sole seat of enumerable norms (§Registry).
- `proposals/archive/` — history from earlier processes, if present. Read-only; never edit or extend it.

**Committed text is in force.** There are no status words or ratification markers; `git log -- <canon-root>` is the record.

## Change Control — "Canon changes"

Canon is updated by the phase skill that produced the decision, in the same session, under one protocol (each skill only points here):

1. **Dirty check first.** Before touching a canon file, `git status -- <file>`; if it already carries uncommitted changes from outside this session, show that diff before anything else — it is the only detection you get for parallel sessions in one working tree.
2. **Edit the working tree directly** — `decisions/`, `registry.md`, the README index and Open Questions.
3. **Present a `## Canon changes` section at the top of the reply**: per file, the **full text of every changed section** (readable text, not a diff; a modified item as *previous → new*) plus a one-line reason and the documents that follow the change (`document-hygiene.md §After a Change`). Nothing to change → `Canon changes: none`.
4. **R2 — the one pause.** If a change overturns or deletes an existing decision item, or changes/removes a registry `Norm`, put that item first as a *previous → new* pair — with the checked fact behind it when the change rests on an observation of the product (`concept-alignment.md §Findings` 1) — and take one explicit confirmation for it. Everything else is approved by the phase's own explicit yes in the same session: `/sdd-plan` Gate 4, `/sdd-spec-requirements` confirmation summary, `/sdd-grill` closing confirmation, `/sdd-spec-done` Step 3 message for its D items, and for `/sdd-spec-design`, `/sdd-spec-done` Step 6 and `/sdd-canon-update` a single "commit?" when the section is non-empty. Canon follows the latest confirmed text; later phases re-sync it. This is independent of `spec.json` approvals.
5. **Commit right after the yes**, listing only the files this session edited — `git commit -m "docs(canon): <phase> <spec-or-topic>" -- <files>` — as a standalone commit. Never `git add <canon-root>` (it would silently canonize unrelated untracked files). Uncommitted canon binds nothing; a declined change is reverted with `git checkout -- <files>`.

Humans may edit canon directly at any time; the commit is the record. Outside a phase, `/sdd-canon-update` runs the same protocol.

## Registry

Line: **a set whose members downstream cites by name is registry; a classification whose *n* is itself the decision stays in prose.** One section per domain, one row per norm:

`| ID | Norm | Grounds | Used by |`

- **ID** `<DOMAIN>-<NN>` — immutable; never renumber; a retired ID is never reused.
- **Norm** — 1–2 lines; longer is prose (put it in `decisions/` and cite the ID).
- **Grounds** — a relative Markdown link to the decision item or spec it derives from (the link check verifies it resolves).
- **Used by** — fixed vocabulary, space-separated: `code: <path Symbol>` · `spec: <feature-dir-name>` (directory *name*, not path — specs move from `todo/` to `done/`) · `plan: <plan-id/Un>` · `—`. Written at the phase that adopts the ID (plan / requirements / spec-done). `check_canon.sh used-by` verifies each entry resolves and classifies: `code:` present or `spec:` in `done/` = implemented; `spec:` in `todo/` or `plan:` = planned; `—` = unadopted.

Prose cites IDs and never restates a list; an enumeration outside the registry is a Warning (check d).

**Controlled vocabulary.** When the product controls its terminology, the vocabulary lives here as the `TERM` domain — one row per concept. The Norm cell uses the fixed form `**<canonical term>** — <one-line definition>. 禁止＝<synonym>, <synonym>` (label `禁止＝` or `banned=`; this is what the checks parse). Adding, renaming, or re-banning a term is a Norm change and takes the R2 confirmation. `check_canon.sh check` greps the live layers (`document-hygiene.md §After a Change`) for banned terms (e) and verifies each canonical term is reachable through some decision's `keywords` line (f); `check_canon.sh terms-prh` emits the vocabulary as a [prh](https://github.com/prh/prh) rule file for optional textlint integration.

## Drafting Discipline

Five heuristics: (1) merge into an existing seat before creating a new one; (2) write grounds from measurement — grep the code and downstream references, don't recall; (3) do not record a policy declaration that specifies nothing concrete; (4) when a draft needs an exception or exemption note, first look for a form that makes it unnecessary; (5) one fact, one seat (`document-hygiene.md`). Plus: never renumber items — a withdrawn item keeps its number with a one-line note — and never issue a number the source text did not have.

## Loading

Always-loaded: `product.md §Canon References` and the README index. Everything else is JIT — grep `keywords` lines, open only the files that hit.

## Checks

`docs/settings/scripts/check_canon.sh check` (registry-ID resolution, link liveness, `keywords` presence, enumerations outside the registry, banned terms from the `TERM` domain, canonical-term keywords coverage) reports and never blocks; run it in `/sdd-spec-done` and `/sdd-canon-update`. `commit-scope` is an optional pre-commit hook that flags a canon change bundled with other files. Do not edit the script per project — configure by arguments; `/sdd-init` overwrites it.

## Adoption

Bringing an existing document set under the canon: move it in **file by file** and fix files when you touch them. No item-level inventory or per-item review.
