---
name: sdd-spec-design
description: >-
  Create comprehensive technical design for an SDD specification.
  Translates requirements (WHAT) into architectural design (HOW).
argument-hint: "<feature-name> [-y]"
---

# Technical Design

<background_information>

- **Mission**: Generate comprehensive technical design document that translates requirements (WHAT) into architectural design (HOW)
- **Success Criteria**:
  - All requirements mapped to technical components with clear interfaces
  - Research findings from `research.md` integrated into design decisions
  - Design aligns with steering context and existing patterns
  - Discuss design with users for clarity and approval
  - Visual diagrams included for complex architectures

</background_information>

<instructions>

## Input

This skill expects:
1. **Feature name** (required): The feature directory name in `docs/tasks/`
2. **Auto-approve flag** (optional): `-y` to auto-approve the previous phase

If inputs were provided with this skill invocation, use them directly.
Otherwise, ask the user for the feature name.
If the auto-approve flag is not provided, default to interactive approval mode.

## Core Task

Understand requirements and leverage existing research findings from `research.md`.
Concretize the design through dialogue with users.
Write technical design document for the specified feature based on approved requirements.

## Execution Steps

### Step 0: Resolve Spec Path

**Resolve Spec Path**: Look for the feature directory in `docs/tasks/todo/<feature-name>/` first, then `docs/tasks/done/<feature-name>/`. Use whichever exists. If neither exists, report an error.

### Step 1: Load Context

**Read all necessary context**:

- `{spec_path}/spec.json`, `requirements.md`, `behaviors.md` (if exists), `design.md` (if exists), `research.md` (if exists)
- `{spec_path}/probe/README.md` (if exists) — the index of verification artifacts behind the research claims. Reading recorded evidence is not independent discovery; open a specific probe result when a design decision turns on it
- **Entire `docs/steering/` directory** for complete project memory
- The kind's design template for document structure (`docs/settings/rules/spec-kinds.md` §4)
- `docs/settings/rules/design-principles.md` for design principles, and `docs/settings/rules/document-hygiene.md`

**If `behaviors.md` does NOT exist and the kind produces behaviors (`spec-kinds.md` §4)**: warn the user — in the language from spec.json — that behavior scenarios were not formulated, that `/sdd-spec-behavior <feature-name>` is recommended (it grounds the design in the product's purpose), and continue without them.

**Validate requirements approval**:

- If auto-approve flag was provided: Auto-approve requirements in spec.json
- Otherwise: Verify approval status (stop if unapproved, see Safety & Fallback)

### Step 2: Apply Research Context

**Use the research results from `research.md` as design input. Do NOT conduct independent discovery or external research (no discovery depth classification, no Discovery process, no WebSearch/WebFetch) — that work belongs to `/sdd-spec-research`.**

1. **If `research.md` was loaded in Step 1**:
   - Extract key findings: architecture patterns, technology decisions, integration points, risks, and design recommendations
   - Note which claims are typed `unverified` or carry no reproducer. Any of these the design ends up depending on goes in the design's Assumptions section, with what fails if it is wrong and the signpost that would reveal it — a premise carried silently is the failure this exists to prevent
   - Retain these findings for Step 3

2. **If `research.md` does NOT exist**:
   - Warn the user — in the language from spec.json — that `research.md` was not generated, that `/sdd-spec-research <feature-name>` is recommended, and that design will continue without research findings
   - Continue with design generation without discovery findings

### Step 3: Generate Design Document

Using the template and principles loaded in Step 1 and the research findings from Step 2:

- **Follow the kind's design template structure and generation instructions strictly**
- **Move, don't copy**: for each line of research.md §Recommendation, write a `D<n>` entry in design.md §Design Decisions (adopted or overturned, with the rejected options and consequences), then delete that line from research.md; delete the section when it is empty. `C<n>` claims stay where they are.
- **Satisfy the behavior scenarios**: if `behaviors.md` exists, every scenario must be realizable by the design — walk each scenario through the designed components and report, in the command output, any scenario no component realizes — do not add a mapping table to design.md. A scenario the design cannot produce is a design gap; a design behavior that contradicts a scenario's `Grounds:` is concept drift — stop and report, don't design around it
- **Integrate all discovery findings**: Use researched information (APIs, patterns, technologies) throughout component definitions, architecture decisions, and integration points
- **Stop on contradiction**: if a research claim conflicts with what the code or the environment actually shows, do not design around the discrepancy — stop and report it. The claim, not the design, is what needs fixing. Re-investigation belongs to `/sdd-spec-research`
- If existing design.md found in Step 1, use it as reference context (merge mode)
- Apply design rules: Type Safety, Visual Communication, Formal Tone
- Use language specified in spec.json
- Ensure the sections carrying research-derived content reflect it, and reference supporting details from `research.md`

### Step 4: Update Metadata

In spec.json:

- Set `phase: "design-generated"`
- Set `approvals.design.generated: true, approved: false`
- Set `approvals.requirements.approved: true`
- If `behaviors.md` exists: set `approvals.behaviors.approved: true` (add the key if missing)
- Update `updated_at` timestamp

## Canon changes (only when a canon layer is declared)

Design rarely produces canon-level content — architecture belongs in steering (`steering-principles.md §Admission`) or in design.md. But a product-level threshold or boundary the design had to settle is one: edit it into the canon working tree per `docs/settings/rules/canon-layer.md §Change Control`, put the `## Canon changes` section (full text of changed sections; R2 items first as *previous → new*) at the top of the output, and ask once whether to commit; on yes commit only those files as `docs(canon): design <feature-name>`. When there is nothing, write nothing — do not print an empty section.

## Critical Constraints

- **Type Safety**:
  - Enforce strong typing aligned with the project's technology stack.
  - For statically typed languages, define explicit types/interfaces and avoid unsafe casts.
  - For TypeScript, never use `any`; prefer precise types and generics.
  - For dynamically typed languages, provide type hints/annotations where available (e.g., Python type hints) and validate inputs at boundaries.
  - Document public interfaces and contracts clearly to ensure cross-component type safety.
- **Steering Alignment**: Respect existing architecture patterns from steering context
- **Design Focus**: Architecture and interfaces ONLY, no implementation code
- **Requirement IDs**: Use numeric requirement IDs only (e.g. "1.1", "1.2", "3.1", "3.3") exactly as defined in requirements.md. Do not invent new IDs or use alphabetic labels.

</instructions>

## Tool Guidance

- **Read first**: Load all context before taking action (specs, `research.md`, steering, templates, rules)
- **No WebSearch/WebFetch**: `research.md` is the sole source of discovery context here
- **Analyze existing code**: Use Grep to find patterns and integration points in codebase
- **Write last**: Generate design.md only after loading all context including research findings

## Output Description

**Command execution output** (separate from design.md content):

Provide brief summary in the language specified in spec.json:

1. **Status**: Confirm design document generated at `{spec_path}/design.md`
2. **Research Context**: Whether `research.md` was available and used
3. **Key Findings**: 2-3 critical insights from `research.md` that shaped the design (if available)
4. **Scenario coverage**: scenarios no component realizes (or "all realized")
5. **Decisions**: `D<n>` entries written, and the Recommendation lines moved out of research.md (count)
6. **Next Action**: Approval workflow guidance (see Safety & Fallback)

**Format**: Concise Markdown (under 200 words) - this is the command output, NOT the design document itself

**Note**: The actual design document follows the kind's design template structure.

## Safety & Fallback

### Error Scenarios

**Requirements Not Approved**:

- **Stop Execution**: Cannot proceed without approved requirements
- **User Message**: "Requirements not yet approved. Approval required before design generation."
- **Suggested Action**: "Run `/sdd-spec-design <feature-name> -y` to auto-approve requirements and proceed"

**Missing Requirements**:

- **Stop Execution**: Requirements document must exist
- **User Message**: "No requirements.md found at `{spec_path}/requirements.md`"
- **Suggested Action**: "Run `/sdd-spec-requirements <feature-name>` to generate requirements first"

**Template Missing**:

- **User Message**: "Template file missing at `docs/settings/templates/specs/<design template>`"
- **Suggested Action**: "Check repository setup or restore template file"
- **Fallback**: Use inline basic structure with warning

**Steering Context Missing**:

- **Warning**: "Steering directory empty or missing - design may not align with project standards"
- **Proceed**: Continue with generation but note limitation in output

**Invalid Requirement IDs**:
  - **Stop Execution**: If requirements.md is missing numeric IDs or uses non-numeric headings (for example, "Requirement A"), stop and instruct the user to fix requirements.md before continuing.

### Next Phase: Task Generation

**If Design Approved**:

- Review generated design at `{spec_path}/design.md`
- **Optional**: Run `/sdd-validate-design <feature-name>` for interactive quality review
- Then `/sdd-spec-tasks <feature-name> -y` to generate implementation tasks

**If Modifications Needed**:

- Provide feedback and re-run `/sdd-spec-design <feature-name>`
- Existing design used as reference (merge mode)

**Note**: Design approval is mandatory before proceeding to task generation.
