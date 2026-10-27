# Completion Review

<!-- Instruction to the reviewer `/sdd-spec-done` Step 2d dispatches, and the form of its report; its findings close by docs/settings/rules/concept-alignment.md §Findings.
The dispatching session hands over: this file; the spec's diff outside `docs/` — the working-tree changes and the commits made during
implementation; the acceptance criteria (list_criteria.sh output); the scenarios (Given / When / Then only); the `_Evidence:`
lines of tasks.md; the latest `probe/product-check-<k>.md`, when the kind's completion checks list it; the report path `reviews/review-<n>.md`; the run number; the output
language; and — on a re-run — the earlier findings as `R<m>-F<k>` with their `Conflict:` lines, and the fix's diff.
Nothing else: no summary, no report from the builder, no ruling on what not to flag. -->

You are reviewing a change you did not make, and you have not seen how it was made. Do not trust any claim that it works.

**You may read**: the code, the tests, the spec's `probe/`, `docs/steering/product.md` and `docs/steering/behaviors.md` (the product's purpose); `docs/steering/tech.md`, the project's README and manifest — only to learn how to start and drive the product. Read nothing else under `docs/`: no requirements, design, research, tasks, other steering, or reviews.

**You may write**: your report, and your evidence in the directory beside it, `reviews/review-<n>/`. Change nothing else; section A shows `git status` otherwise unchanged by you.

1. Read the diff first. Read beyond it only where a line you quote justifies it.
2. Run the tests the `_Evidence:` lines name. When a product-check record was handed over, walk its paths once yourself: re-run the commands in its A. and, where the entry is a screen, operate it as its B. describes. A path you cannot reach is written as such.
3. Against the criteria and scenarios, flag only gaps and contradictions that affect correctness or what a criterion states. No coverage table, no restating of what holds. A clean result is a normal outcome. Every finding quotes file:line, or a command and its output.
4. Code quality goes under D., at most three items.

## Report

Whatever language you write in, keep these as they are: the section letters A. to D., the `#### F<k>` headings, the `Findings: none` line, and the words `reproduced` / `not reproduced`.

### A. Checked
The commands you ran and their output; the paths you walked; `git status` before and after.

### B. Findings
One `#### F<k>` heading per finding, then `Artifact:`, `Conflict:` and `Evidence:` (file:line quotes, or a command and its output). Or the single line `Findings: none`.

### C. Re-checks
Only on a re-run: one line per finding you were handed — `R<m>-F<k> — reproduced | not reproduced — <evidence>`.

### D. Warnings
Code-quality items, at most three. They are not findings.
