# AI-DLC and Spec-Driven Development

Spec Driven Development implementation on AI-DLC (AI Development Life Cycle)

## Project Context

### Paths

- Steering: `docs/steering/`
- Inception (large-scale plans): `docs/inception/`
- Specs: `docs/tasks/`

### Steering vs Specification vs Inception

**Steering** (`docs/steering/`) - Guide AI with project-wide rules and context
**Specs** (`docs/tasks/`) - Formalize development process for individual features
**Inception** (`docs/inception/`) - Plan a large effort by decomposing it into many specs (see `/sdd-plan`)

### Active Specifications

- Check `docs/tasks/` for active specifications
- Use `/sdd-spec-status <feature-name>` to check progress

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
  - `/sdd-validate-gap <feature-name>` (optional: for existing codebase)
  - `/sdd-spec-research <feature-name>` (research & discovery)
  - `/sdd-spec-design <feature-name> [-y]`
  - `/sdd-validate-design <feature-name>` (optional: design review)
  - `/sdd-spec-tasks <feature-name> [-y]`
- Phase 2 (Implementation): `/sdd-spec-impl <feature-name> [tasks]`
  - `/sdd-validate-impl <feature-name>` (optional: mid-implementation validation)
- Phase 3 (Completion): `/sdd-spec-done <feature-name>`
  - Verifies quality, finalizes the spec, commits the feature, then runs a non-blocking steering drift check — if the feature introduced new patterns, it proposes additive steering updates and commits them separately (with your confirmation).
- Progress check: `/sdd-spec-status <feature-name>` (use anytime)

## Development Rules

- For large/greenfield efforts, run Inception first (`/sdd-plan`) to decompose into right-sized specs, then run each spec through the workflow below.
- Workflow: Requirements → Research → Design → Tasks → Implementation → Completion
- Human review required each phase; use `-y` only for intentional fast-track
- Steering is kept current incrementally: `/sdd-spec-done` auto-detects feature-scoped drift at completion. Use `/sdd-steering` for the initial bootstrap and for periodic full-codebase reviews (e.g. after several merges or a refactor).
- Follow the user's instructions precisely, and within that scope act autonomously: gather the necessary context and complete the requested work end-to-end in this run, asking questions only when essential information is missing or the instructions are critically ambiguous.
- **Exception — the requirements phase elicits, it does not autonomously author.** During `/sdd-spec-requirements`, do not fill gaps with assumptions or add capabilities the user did not request. Every requirement must trace to user input or an explicit confirmation; unclear or scope-affecting points must be resolved through interactive dialogue, and anything left unresolved is logged as an assumption/open question rather than baked into a requirement. Inventing unrequested features ("gold-plating") is the main source of rework — `/sdd-validate-requirements` exists to catch it.

## Steering Configuration

- Load entire `docs/steering/` as project memory
- Default files: `product.md`, `tech.md`, `structure.md`
- Custom files are supported (managed via `/sdd-steering-custom`)
