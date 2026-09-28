# AI-DLC and Spec-Driven Development

Spec Driven Development implementation on AI-DLC (AI Development Life Cycle)

## Project Context

### Paths

- Steering: `docs/steering/`
- Inception (large-scale plans): `docs/inception/`
- Specs: `docs/tasks/`
- Canon (optional): declared in `docs/steering/product.md §Canon References` (default `docs/canon/`)

### Steering vs Specification vs Inception

**Steering** (`docs/steering/`) - Guide AI with project-wide rules and context
**Specs** (`docs/tasks/`) - Formalize development process for individual features
**Inception** (`docs/inception/`) - Plan a large effort by decomposing it into many specs (see `/sdd-plan`)

### Active Specifications

- Check `docs/tasks/` for active specifications
- Use `/sdd-spec-status [feature-name]` to check progress (no argument lists every spec)

## Development Guidelines

- Think in English, generate responses in {{DEFAULT_LANGUAGE_NAME}}. All Markdown content written to project files (e.g., requirements.md, design.md, tasks.md, research.md, validation reports) MUST be written in the target language configured for this specification (see spec.json.language).

## Minimal Workflow

- Phase 0 (optional): `/sdd-steering`, `/sdd-steering-custom`
- Phase P (Inception — large-scale only): `/sdd-plan "product or project goal"`
  - Use for 0->1 greenfield builds, scaling a prototype, or any effort too large for one spec.
  - Decomposes the goal into ordered Units of Work and scaffolds one spec per unit under `docs/tasks/todo/`.
  - For a single focused feature, skip this and start at Phase 1 with `/sdd-spec-init`.
- Phase 1 (Specification):
  - `/sdd-spec-init "description"`
  - `/sdd-spec-requirements <feature-name>` (always interactive — elicit, don't invent)
  - `/sdd-validate-requirements <feature-name>` (recommended: catch gold-plating / untraceable requirements before they propagate)
  - `/sdd-spec-behavior <feature-name>` (recommended: formulate concrete behavior scenarios grounded in the product's purpose — catches concept drift before design)
  - `/sdd-validate-gap <feature-name>` (optional: for existing codebase)
  - `/sdd-spec-research <feature-name>` (research & discovery)
  - `/sdd-validate-research <feature-name>` (recommended: re-runs the evidence independently — a wrong finding here becomes a design premise nothing downstream may question)
  - `/sdd-spec-design <feature-name> [-y]`
  - `/sdd-validate-design <feature-name>` (optional: design review)
  - `/sdd-spec-tasks <feature-name> [-y]`
  - `/sdd-validate-tasks <feature-name>` (optional: task review)
- Phase 2 (Implementation): `/sdd-spec-impl <feature-name> [tasks]`
  - `/sdd-validate-impl <feature-name>` (optional: mid-implementation validation)
- Phase 3 (Completion): `/sdd-spec-done <feature-name>`
  - Verifies quality, finalizes the spec, commits the feature, then runs a non-blocking steering drift check — if the feature introduced new patterns, it proposes additive steering updates and commits them separately (with your confirmation).
  - At completion, an independent auditor checks every acceptance criterion clause by clause against the code; stale criterion wording is fixed, and disputed items are asked once in a single batched question.
- Progress check: `/sdd-spec-status [feature-name]` (use anytime; no argument lists every spec)
- Orientation & dialogue (anytime, belongs to no phase):
  - `/sdd-brief ["question"]` — read-only. Answers what was decided about a topic, where the project stands across every spec, or what needs deciding next, with citations. Use it instead of opening documents one by one.
  - `/sdd-grill ["topic"]` — a relentless interview that works the project's open decisions in rounds until nothing is left silently assumed. Use it before committing to a spec, when steering / inception / specs may have drifted apart, or to clear a backlog of open questions.
  - `/sdd-director [feature-name]` — holds the product's direction during implementation: rules on inquiries against the documents, fixes the design, and takes changes to requirements, canon, inception, or steering to you.
- Canon (when the product keeps a canon layer — concept decisions, normative registry):
  - Phase skills land canon changes themselves: `/sdd-plan` (Gate 4), `/sdd-spec-requirements` (confirmation summary), `/sdd-spec-design` (only when non-empty), `/sdd-spec-done` (after GO), `/sdd-grill` (landing) — each shows a `## Canon changes` section with the full text of every changed section, then commits it as its own `docs(canon):` commit after your yes.
  - `/sdd-canon-update "change"` — the same protocol for a decision reached outside a phase; scaffolds the canon layer on first use.

## Development Rules

- For large/greenfield efforts, run Inception first (`/sdd-plan`) to decompose into right-sized specs, then run each spec through the workflow below.
- Workflow: Requirements → Behaviors → Research → Design → Tasks → Implementation → Completion
- Human review required each phase; use `-y` only for intentional fast-track
- **Research measures, it does not reason.** Size/count/duration, the behavior of existing code, external specs, and performance are settled by running something — never by reading (`docs/settings/rules/evidence-discipline.md`). Evidence lives in `<spec>/probe/`. What cannot be measured is written as `unverified` and, if the design depends on it, carried into `design.md` Assumptions with a signpost.
- A spec that is internally consistent is not thereby correct — it must also serve the product intent in `docs/steering/product.md`. `/sdd-spec-behavior` grounds each behavior there; `/sdd-validate-requirements` and `/sdd-validate-design` check it, and a contradiction is NO-GO. For contradictions *between* layers (spec vs spec, steering vs inception) or a backlog of open decisions, use `/sdd-grill`.
- Steering is kept current incrementally: `/sdd-spec-done` auto-detects feature-scoped drift at completion. Use `/sdd-steering` for the initial bootstrap and for periodic full-codebase reviews (e.g. after several merges or a refactor).
- **Canon changes ride inside the phase that produced them** (`docs/settings/rules/canon-layer.md §Change Control`): the agent edits the canon working tree, shows every changed section in full at the top of the reply, pauses only for an overturned decision or a changed registry Norm (*previous → new*, one confirmation), and commits only the edited files as a standalone `docs(canon):` commit after your yes. Committed text is in force; uncommitted edits bind nothing. Steering changes by ordinary present-diff-and-confirm.
- **Documents are the source of truth.** Whatever you change, carry it through the documents listed in `docs/settings/rules/change-propagation.md` in the same turn.
- **One fact, one seat** — approvals, statuses, and dates are recorded in their designated seat and never restated in body prose; template comments and unrequested meta-sections never ship (`docs/settings/rules/document-hygiene.md`).
- Stay within the scope the user asked for; gather the context you need yourself, and ask only when essential information is missing or the request is critically ambiguous.
- **The requirements phase elicits, it does not author.** During `/sdd-spec-requirements`, do not fill gaps with assumptions or add capabilities the user did not request. Every requirement must trace to user input or an explicit confirmation; unclear or scope-affecting points must be resolved through interactive dialogue, and anything left unresolved is logged as an assumption/open question rather than baked into a requirement. Inventing unrequested features ("gold-plating") is the main source of rework — `/sdd-validate-requirements` exists to catch it.

## Steering Configuration

- Load entire `docs/steering/` as project memory
- Default files: `product.md`, `tech.md`, `structure.md`, `behaviors.md` (cross-spec behavior invariants, grown mainly by `/sdd-spec-done` promotion)
- Custom files are supported (managed via `/sdd-steering-custom`)
