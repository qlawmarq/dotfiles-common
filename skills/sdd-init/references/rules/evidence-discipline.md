# Evidence Discipline

## Objective

A wrong research finding becomes an unchallengeable design premise: `/sdd-spec-design` is forbidden to re-investigate (`research.md` is its sole discovery context), and `/sdd-validate-design` only checks that findings are *reflected*, never that they are *true*. Correctness has to be established in the research phase or not at all.

The failure mode is not sloppiness — it is **answering an empirical question by reasoning instead of measuring**. A research document full of citations and `file:line` references reads as authoritative whether or not anything was ever run.

This file is the single seat for the claim format, the measurement rule, the `probe/` convention, and the assumption register. `/sdd-spec-research` and `/sdd-validate-research` read it; the research template and those skills name its sections (one fact, one seat: `document-hygiene.md`).

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
- Verification: <probe/<file> | test name | command + its output | URL + retrieval date | none>
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
- When a measurement is later invalidated, **do not delete it** — move it to a clearly separated section stating that no value may be drawn from it, and where the current answer is.

## 4. Assumption register

A `Load-bearing` claim that could not be verified does not disappear. When the user decides to proceed without measuring it, it is carried into `design.md` (Assumptions / Risks) as:

```
- <claim> (C<n>) — impact: <what fails if it is wrong> / signpost: <the observable sign that it has broken>
```

The signpost is the point: an unverified premise that is written down with a way to notice it failing is a managed risk, while the same premise left implicit is the accident this discipline exists to prevent.
