# Evidence Discipline

## Objective

A wrong research finding becomes an unchallengeable design premise: `/sdd-spec-design` is forbidden to re-investigate (`research.md` is its sole discovery context), and `/sdd-validate-design` only checks that findings are *reflected*, never that they are *true*. Correctness has to be established in the research phase or not at all.

The failure mode is not sloppiness — it is **answering an empirical question by reasoning instead of measuring**. A research document full of citations and `file:line` references reads as authoritative whether or not anything was ever run.

This file is the single seat for the claim format, the measurement rule, the `probe/` convention, the assumption register, and the reference material in `docs/reference/`. `/sdd-spec-research` and `/sdd-validate-research` read it; the research template and those skills name its sections (one fact, one seat: `document-hygiene.md`).

## 1. Questions that must be measured, not reasoned

Four kinds of claim may never be settled by reading alone:

| Kind | Not allowed | Required |
|---|---|---|
| **Size / count / duration** | A lower bound, a partial count, or a sample presented as the total | Count the whole set, or measure a sample and extrapolate **stating the method and a range**. A `grep -c` is a lower bound until you show it is exhaustive |
| **Behavior of existing code** | Asserting behavior from a `file:line` citation | "It says so" ≠ "it does so". Run a test, run a probe, or build a minimal repro |
| **External spec / compatibility** | Settling it from documentation alone | A minimal connectivity check at a pinned version |
| **Performance / cost / capacity** | Quoting someone else's benchmark as your number | Measure in this environment |

When you cannot measure, write `unverified` and say what it would take. **An honest "not measured" is a first-class result**; a fabricated certainty is a defect that propagates into the design and is expensive to unwind.

## 2. Claim format

Every finding in `research.md` is one claim with four tag lines. Keep the tag names and values in English (same policy as EARS and Gherkin keywords); write the claim itself in the spec's language.

```
#### C<n>: <the claim, one or two lines>
- Type: measured | sourced | inferred | unverified
- Verification: <probe/<file> | test name | command + its output | URL + retrieval date | docs/reference/<file> §C<n> | none>
- Confidence: high | medium | low
- Load-bearing: <what breaks in the design if this is wrong — blank if nothing does>
```

- **`measured` requires a reproducer.** A claim may only be typed `measured` when `Verification` names something a reader can re-run: a `probe/` artifact, a test, or a command whose output is recorded. Without one it is `inferred` at best.
- **No promotion in the summary.** A claim may appear in Summary / Key Findings only if it has a `C<n>` entry in the Research Log. Restating a lower bound as a total in the summary is the single most damaging failure this rule exists to stop.
- **Recommendations and design decisions cite their claims.** A recommendation in research.md and a decision in design.md each name the `C<n>` they rest on, so a claim later found wrong points directly at what falls with it.
- `Load-bearing` is left blank for claims the design does not depend on. Filling it in is what selects the small set worth spending measurement on.
- **A claim can be a finding.** A measured claim that disagrees with a document, or that shows what a person using the product meets in its default configuration, is not recorded as a parameter to plan around: `concept-alignment.md §The Check` and `§Findings` apply in the same turn.

## 3. The `probe/` directory

Verification artifacts live in `{spec_path}/probe/`. This is the physical seat for reproducers, and `/sdd-spec-design` may read it.

- **Evidence only.** Raw logs, scripts, results, patches. The interpretation belongs in `research.md` / `design.md` — never duplicate a conclusion here.
- **`probe/README.md` is the index**: file → configuration → what the result showed → which `C<n>` it supports.
- **No hardcoded paths.** A probe never writes the spec directory's or the repository's path. A script derives its own directory from its location and references other probe files relative to it; when it needs the repository root, it asks git at run time (`git rev-parse --show-toplevel`). It then runs from anywhere, so its opening comment states only what it runs and what it requires. File names in `probe/README.md` are relative to `probe/`. If a script needs a temporary patch to production code, say so, and **restore afterwards**.
- Keep measurements that support a claim. Discard exploratory runs that support nothing.

## 4. Assumption register

A `Load-bearing` claim that could not be verified does not disappear. When the user decides to proceed without measuring it, it is carried into `design.md` (Assumptions / Risks) as:

```
- <claim> (C<n>) — impact: <what fails if it is wrong> / signpost: <the observable sign that it has broken>
```

The signpost is the point: an unverified premise that is written down with a way to notice it failing is a managed risk, while the same premise left implicit is the accident this discipline exists to prevent.

## 5. Reference material

`docs/reference/` holds facts about the world outside the project — precedents, best practices, external methods and lenses, markets, literature, the behavior of external products. A fact goes here when decision records, steering, a plan, or more than one spec cite it; a fact only one spec uses stays in its `research.md`. A file stays while at least one document outside `docs/reference/` cites it, records included; one that `check_refs.sh unused --include-records` lists is deleted. An external method or lens is written as sourced questions.

- **Nothing about this product.** A sentence that names this product, its decisions or open questions, a plan unit, or a spec — a verdict, a severity, an adoption, a "should" about them — belongs in the citing document, which also writes the inference toward the product (a decision's Background, an `inferred` claim in `research.md`). A sourced external recommendation is an outside fact, and so is a comparison of external works against stated conditions ("N precedents meet conditions a–g"). Status and progress go to the decisions README Open Questions or the plans; the list of a file's citers is derived (`check_refs.sh refs`), and a per-file "non-normative" line restates this section (`document-hygiene.md §Scaffolding`).
- **Format.** One topic per file, `<topic-slug>.md`, without an ID, opening with a `keywords` line and the question it answers in one line. Claims take the §2 format without `Load-bearing` — that is the citer's to say. There is no expiry; the date is the retrieval date in `Verification`.
- **Reproducers** go in `docs/reference/probe/<topic-slug>/`; §3 applies.
- **Citing.** `docs/reference/<file> §C<n>` (or `§<heading>`), never an abbreviation — that is the form `check_refs.sh` resolves. A `research.md` claim that cites one is typed no higher than the cited claim; the section is not a reproducer, so `measured` still needs one in the claim's own `Verification` (§2).
- **Writing.** Grep the `keywords` lines before researching and extend a file that exists. Write it in the same turn as the document that cites it. It is a live layer (`document-hygiene.md §After a Change`). No approval gate; the citing document has one.
- **Loading.** Never always-loaded, no index file directly in `docs/reference/`: grep the `keywords` lines and open only the cited section.
