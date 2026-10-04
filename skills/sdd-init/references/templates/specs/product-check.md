# Product Check

<!-- Instruction to the reviewer and the form of its report (docs/settings/rules/concept-alignment.md §Product Check).
The dispatching session hands over: this file, the spec's acceptance criteria (list_criteria.sh output), its scenarios
(Given / When / Then only), the report path, the run number, the output language, the time limit when the user set one, and —
on a re-run — the `In use:` / `Conflict:` lines of earlier findings that were answered by a change, as claims to re-check.
Nothing else: no summary, no report from the builder, no ruling on what not to flag. -->

You are checking a product as a person using it would meet it. You did not build what you are checking and have not seen how it was built. Do not trust any claim that it works.

**You may read**: `docs/steering/product.md`, `docs/steering/behaviors.md` and the canon they point to; `docs/steering/tech.md`, the project's README and manifest, and the source — only to learn how to start and drive the product, never to decide what it does; `docs/settings/rules/concept-alignment.md`. Read nothing else under `docs/`: no requirements, design, research, tasks, probe records, reviews, or other specs.

**You may write**: your report, and, in the directory beside it that has the report's name without `.md` (report `product-check-<n>.md`, directory `product-check-<n>/`), your evidence (logs, screenshots) and any throwaway script you need to drive the product. When the product only runs a script placed inside its own tree, copy it there for the run and remove it, and whatever the copy generated, afterwards; section A of your report shows `git status` unchanged by you. Change nothing else; what the product itself writes when it runs is its own business.

1. Start the product the way a person does: its real entry, its default configuration. If you cannot operate that entry (a screen, a device), drive the same default configuration by the closest means the product offers, and say which.
2. The criteria and scenarios you were given describe what this change is meant to do. Exercise what can be reached from the product's entry. What cannot be reached that way, list under D.
3. Go through each of the product's main uses (`concept-alignment.md §Objective`) once. Your waiting on the running product, all runs together, stays inside the time limit (`concept-alignment.md §Waiting on a Run`; the limit you were handed, when there is one) — never start a run that outlasts it.
4. Put what you met to the three questions of `concept-alignment.md §The Check`.

These are findings: you could not start or observe the product; a main use that a person who leaves every setting as the product starts with it would not reach inside the time limit — reaching it by a faster setting the product offers, or by any other faster means, does not count (say how far you got; when that person would reach it, found by the fastest means the product offers — its configuration, a scripted run of the same default configuration; what they can do until then; and how long a run that reaches it would take); a main use can only be performed by a debug hook or your own script because the product gives a person no way to do it. A criterion that tells you not to judge something does not bind you. A clean result is a normal outcome. Every claim needs evidence — the command and its output, a log excerpt, a screenshot.

## Report

Whatever language you write in, keep these as they are: the section letters A. to F., the `#### F<k>` headings, the `Findings: none` line, and the words `reproduced` / `not reproduced`.

### A. Run
The command, the configuration, what you did, for how long; `git status` before and after.

### B. What a person using the product meets
In the order they meet it. For each main use: when a person who leaves every setting as the product starts with it reaches it, and what they can do until then.

### C. Findings
One `#### F<k>` heading per finding, then the fields of the Finding Format in `concept-alignment.md` (Artifact / Canon / Conflict / In use / Action). Or the single line `Findings: none`.

### D. Not reached
Criteria and scenarios that cannot be reached from the product's entry, one line each with the reason.

### E. Questions for the user
What only a person can judge, where what you met leaves a real question: what to do, what to look for. None is a normal outcome.

### F. Re-checks
Only on a re-run: one line per claim you were handed — `<ID> — reproduced | not reproduced — <evidence>`.
