# Decision Records

## Objective

Keep the product decisions in one place, drafted by the agent and approved by the human **as a diff inside the SDD phase that produced them** — never in a separate ceremony. Two accidents this prevents: an unread AI draft gaining canonical force, and the same enumerable norm living in several seats. A product decision is a rule the product follows, a scope boundary, a threshold, a non-goal, or a behavior invariant. Decision records are optional; a product whose philosophy fits in `docs/steering/product.md` does not need them. What product.md keeps once it declares the records: `steering-principles.md §File focus`.

## Structure

The records are declared when `docs/steering/product.md §Decision Records` names a decisions root (default `docs/decisions/`); the template's bracketed placeholder is not a declaration. Never hardcode the root. Templates: `docs/settings/templates/decisions/`.

- `README.md` — index only: decision log (`ID | Decision | Keywords | File`) and Open Questions. No normative text.
- `<id>-<slug>.md` (template `decision.md`) — one topic per file (a file beyond ~100 lines opens with a table of contents): `keywords` line (the JIT grep index), Background (why), Decision (numbered items), optional Consequences, Registry refs (IDs only).
- `registry.md` — the sole seat of enumerable norms (§Registry).
- `proposals/archive/` — history from earlier processes, if present. Read-only; never edit or extend it.

**Committed text is in force.** There are no status words or ratification markers; `git log -- <decisions-root>` is the record.

## Change Control — "Decision changes"

The decision records are updated by the phase skill that produced the decision, in the same session, under one protocol (each skill only points here):

1. **Dirty check first.** Before touching a decision file, `git status -- <file>`; if it already carries uncommitted changes from outside this session, show that diff before anything else — it is the only detection you get for parallel sessions in one working tree.
2. **Edit the working tree directly** — the decision files, `registry.md`, the README index and Open Questions.
3. **Present a `## Decision changes` section at the top of the reply**: per file, the **full text of every changed section** (readable text, not a diff; a modified item as *previous → new*) plus a one-line reason and the documents that follow the change (`document-hygiene.md §After a Change`). Nothing to change → `Decision changes: none`.
4. **R2 — the one pause.** If a change overturns or deletes an existing decision item, or changes/removes a registry `Norm`, put that item first as a *previous → new* pair — with the checked fact behind it when the change rests on an observation of the product (`concept-alignment.md §Findings` 1) — and take one explicit confirmation for it. Everything else is approved by the phase's own explicit yes in the same session: `/sdd-plan` Gate 4, `/sdd-spec-requirements` confirmation summary, `/sdd-grill` closing confirmation, `/sdd-spec-done` Step 3 message for its findings in the 'Decision records or steering' row of `concept-alignment.md §Findings`, and for `/sdd-spec-design`, `/sdd-spec-done` Step 6 and `/sdd-decision` a single "commit?" when the section is non-empty. The decision records follow the latest confirmed text; later phases re-sync them. This is independent of `spec.json` approvals.
5. **Commit right after the yes**, listing only the files this session edited — `git commit -m "docs(decisions): <phase> <spec-or-topic>" -- <files>` — as a standalone commit. Never `git add <decisions-root>` (it would silently commit unrelated untracked files as decisions). Uncommitted decision content binds nothing; a declined change is reverted with `git checkout -- <files>`.

Humans may edit the decision records directly at any time; the commit is the record. Outside a phase, `/sdd-decision` runs the same protocol.

## Registry

Line: **a set whose members downstream cites by name is registry; a classification whose *n* is itself the decision stays in prose.** One section per domain, one row per norm:

`| ID | Norm | Grounds | Used by |`

- **ID** `<DOMAIN>-<NN>` — immutable; never renumber; a retired ID is never reused.
- **Norm** — 1–2 lines; longer is prose (put it in a decision file and cite the ID).
- **Grounds** — a relative Markdown link to the decision item or spec it derives from (the link check verifies it resolves).
- **Used by** — fixed vocabulary, space-separated: `code: <path Symbol>` · `spec: <feature-dir-name>` (directory *name*, not path — specs move from `todo/` to `done/`) · `plan: <plan-id/Un>` · `—`. Written at the phase that adopts the ID (plan / requirements / spec-done). `check_decisions.sh used-by` verifies each entry resolves and classifies: `code:` present or `spec:` in `done/` = implemented; `spec:` in `todo/` or `plan:` = planned; `—` = unadopted.

Prose cites IDs and never restates a list; an enumeration outside the registry is a Warning (check d).

**Controlled vocabulary.** When the product controls its terminology, the vocabulary lives here as the `TERM` domain — one row per concept. The Norm cell uses the fixed form `**<canonical term>** — <one-line definition>. 禁止＝<synonym>, <synonym>` (label `禁止＝` or `banned=`; this is what the checks parse). Adding, renaming, or re-banning a term is a Norm change and takes the R2 confirmation. `check_decisions.sh check` greps the decisions root, steering, plans and `docs/specs/todo/` for banned terms (e) and verifies each canonical term is reachable through some decision's `keywords` line (f); `check_decisions.sh terms-prh` emits the vocabulary as a [prh](https://github.com/prh/prh) rule file for optional textlint integration.

**Behavior invariants.** The product's behavior invariants live here as the `INV` domain, one row per invariant. `Used by` names the spec that established it (`spec:`) and, when a test verifies it, that test (`code: <test file> <test name>`).

## Drafting Discipline

Five heuristics: (1) merge into an existing seat before creating a new one; (2) write grounds from measurement — grep the code and the documents that cite it, don't recall, and cite an outside fact from `docs/reference/` (`evidence-discipline.md §5`); (3) do not record a policy declaration that specifies nothing concrete; (4) when a draft needs an exception or exemption note, first look for a form that makes it unnecessary; (5) one fact, one seat (`document-hygiene.md`). Plus: never renumber items — a withdrawn item keeps its number with a one-line note — and never issue a number the source text did not have.

## Loading

Always-loaded: `product.md §Decision Records` and the README index. A product-intent check also reads the registry's `INV` section. Everything else is JIT — grep `keywords` lines, open only the files that hit.

## Checks

`docs/settings/scripts/check_decisions.sh check` (registry-ID resolution, link liveness, `keywords` presence, enumerations outside the registry, banned terms from the `TERM` domain, canonical-term keywords coverage) reports and never blocks; run it in `/sdd-spec-done` and `/sdd-decision`. `commit-scope` is an optional pre-commit hook that flags a decision change bundled with other files. Do not edit the script per project — configure by arguments; `/sdd-init` overwrites it.

## Adoption

Bringing an existing document set under the decision records: move it in **file by file** and fix files when you touch them. No item-level inventory or per-item review.
