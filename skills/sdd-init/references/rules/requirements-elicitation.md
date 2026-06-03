# Requirements Elicitation Rules

## Objective

Capture what the user actually needs — no more, no less. In spec-driven development the requirements document is the contract every later phase builds on, so a feature that slips in here propagates into research, design, tasks, and code before anyone notices. By then it is expensive to unwind. The cheapest place to catch an unwanted feature is before it is written down.

These rules govern how `/sdd-spec-requirements` turns a project description and a clarification dialogue into `requirements.md`.

## The core principle: elicit, don't invent

Your job in this phase is **discovery, not authorship**. Requirements are *elicited* from the user (and from explicit project context), never invented by you. This is the central practice of requirements engineering: the analyst draws out and confirms stakeholder needs; the analyst does not decide what the stakeholder "probably also wants."

This matters because an AI agent's instinct to be helpful is exactly what produces **gold-plating** — extra capabilities the user never asked for, added because they seemed like an improvement. Gold-plating is, by definition, a requirement whose source is *you* rather than the user. It is the single most common cause of rework in this phase, and it is preventable.

So the rule is simple to state: **every requirement must trace back to something the user actually said or explicitly confirmed.** If you cannot point to that source, the requirement does not belong in the document yet.

## No assumptions — the ask-vs-assume gate

When information is missing or ambiguous, you have three options, and only one of them is "guess." Guessing is not allowed. Instead:

1. **Ask** — if the gap affects *scope, behavior, or acceptance criteria*, stop and ask the user a clarifying question. These are the gaps that cause rework, so they are always worth a question. Do not write the affected requirement until the answer arrives.
2. **Log** — if the gap is genuinely trivial and reversible (a wording choice, a default that is easy to change later), you may proceed, but record the assumption explicitly in the **Assumptions & Open Questions** section and label the requirement as provisional. Never bury an assumption silently inside a requirement as if it were a confirmed need.
3. **Propose** — when you can see a reasonable option the user may not have considered, offer it as a *proposal* for them to accept or reject ("Did you also want X? I'll leave it out unless you confirm"). A proposal is a question, not a decision. The default answer to an unconfirmed proposal is **no** — leave it out.

The test for "ask vs. log": *if I guessed wrong here, would the user have to redo design or implementation work?* If yes, ask. When in doubt, ask — a clarifying question costs a sentence; a wrong scope assumption costs a phase.

## How to run the clarification dialogue

This phase is always interactive. Do not try to resolve everything in one upfront questionnaire, and do not silently produce a finished document and hope it's right. Instead:

1. **Draft from what you have.** Read the project description and all steering context. Produce an initial set of requirements covering only what is clearly grounded in that input.
2. **Surface the gaps.** As you draft, collect the points where you had to make a choice the input didn't settle — missing acceptance thresholds, unstated edge cases, ambiguous scope boundaries, conflicting hints. These become your questions and your open-questions log.
3. **Ask, then revise.** Present the draft together with your questions. Iterate with the user rather than firing a long list of questions before writing anything — a concrete draft is far easier for a user to react to than an abstract interview.
4. **Confirm before finishing.** Before marking the document generated, give the user a short confirmation summary: "Here is what I understood you to need, and here is what I deliberately left out of scope — is that right?" This catches both missing requirements and invented ones in a single pass. The user's confirmation is what turns provisional requirements into baselined ones.

## Traceability: give every requirement a source

Each requirement carries a **Source** line recording where it came from. Use these provenance labels:

- **User-stated** — the user asked for this directly (quote or paraphrase the relevant input).
- **User-confirmed** — you proposed it and the user explicitly said yes during the dialogue.
- **Derived** — a necessary consequence of a stated requirement (e.g., "store the data" implies "the data must be retrievable"). State which requirement it derives from. Derived requirements still need user confirmation if they expand observable scope.
- **Steering/constraint** — mandated by project steering, a standard, or a regulation. Cite the steering file.

If a requirement does not fit any of these, it has no legitimate source — that is the definition of gold-plating. Remove it, or convert it into a *proposal* you raise with the user.

## Scope discipline

- **Out of Scope is a feature of the document, not an omission.** Maintain an explicit "Out of Scope" section listing what you deliberately are *not* building, especially capabilities a reasonable reader (or a future you) might assume are included. Writing scope boundaries down converts silent assumptions into auditable decisions and gives the validation step something concrete to check against.
- **Prioritize with MoSCoW.** Tag requirements Must / Should / Could / Won't-have-this-time, traceable to user intent. The "Won't" list is itself a scope boundary. Anything you cannot justify as at least a "Could" backed by a user need does not belong in the document.
- **Respect what the user excluded.** If the user said "just X for now," then Y and Z are out of scope even if they seem natural — record them in Out of Scope or Open Questions, don't add them.

## Quality bar for each requirement

Before a requirement is accepted, it should be:

- **Necessary** — tied to a real, traceable need; removing it would leave a genuine deficiency. (This is the anti-gold-plating test.)
- **Singular** — one requirement per statement; watch for "and"/"or" hiding two needs.
- **Unambiguous** — one reasonable interpretation. Lint for vague terms — *fast, user-friendly, efficient, robust, flexible, adequate, as appropriate, etc.* — and replace them with a measurable, testable criterion, or flag the term as an open question if you can't.
- **Verifiable** — you can describe how you'd confirm it's met. If you can't write an acceptance test for it, it isn't a requirement yet.
- **In EARS format** — acceptance criteria follow the patterns in `ears-format.md`. EARS fixes structure and testability but does *not* catch vagueness or illegitimate scope, so apply it *after* the traceability and necessity checks above, not instead of them.

## What this phase does NOT do

- It does not choose technologies, architectures, or implementation approaches (that's research/design). Keep requirements at WHAT, not HOW.
- It does not pad coverage to look thorough. A short, fully-grounded requirements document is better than a long one half-filled with plausible inventions.
