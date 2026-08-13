---
name: sdd-spec-research
description: >-
  Execute independent research for an SDD specification.
  Investigates existing codebase and best practices, generating research.md.
argument-hint: "<feature-name> [-y]"
---

# Spec Research

<background_information>

- **Mission**: Generate comprehensive research document (research.md) that captures discovery findings, architectural investigations, and design recommendations
- **Success Criteria**:
  - Appropriate discovery process executed based on Feature Type classification
  - Current codebase analysis and best practice research completed
  - Research findings structured in research.md template format
  - Findings provide sufficient context for the subsequent design phase
  - spec.json is NOT updated (research.md existence is the sole completion indicator)

</background_information>

<instructions>

## Input

This skill expects:
1. **Feature name** (required): The feature directory name in `docs/tasks/`
2. **Auto-approve flag** (optional): `-y` to auto-approve the previous phase (requirements)

If inputs were provided with this skill invocation, use them directly.
Otherwise, ask the user for the feature name.
If the auto-approve flag is not provided, default to interactive approval mode.

## Core Task

Investigate the existing codebase and research best practices to generate a structured research document (research.md) for the specified feature.

## Execution Steps

### Step 0: Resolve Spec Path

**Resolve Spec Path**: Look for the feature directory in `docs/tasks/todo/<feature-name>/` first, then `docs/tasks/done/<feature-name>/`. Use whichever exists. If neither exists, report an error.

### Step 1: Load Context

**Read all necessary context**:

- `{spec_path}/spec.json` for language and metadata
- `{spec_path}/requirements.md` for project requirements
- `{spec_path}/behaviors.md` (if exists) for grounded behavior scenarios — research must serve these behaviors, and their Verification lines (probe/test needs) may require investigation
- `{spec_path}/gap-analysis.md` (if exists) for existing gap analysis results
- **Entire `docs/steering/` directory** for complete project memory:
  - Default files: `structure.md`, `tech.md`, `product.md`
  - All custom steering files
- `docs/settings/templates/specs/research.md` for research document structure
- `docs/settings/rules/evidence-discipline.md` — the claim format, what must be measured rather than reasoned, and the `probe/` convention

Do **not** load the discovery rules here — Step 2 classifies the Feature Type first and then reads only the one rule that applies.

**Validate requirements approval**:

- If auto-approve flag was provided: Auto-approve requirements in spec.json (set `approvals.requirements.approved: true`)
- Otherwise: Verify that `approvals.requirements.approved` is `true` in spec.json
- If requirements are not approved: Stop execution (see Safety & Fallback)

### Step 2: Discovery & Analysis

**Critical: This phase ensures research is based on complete, accurate information.**

1. **Classify Feature Type**:
   - **New Feature** (greenfield) → Full discovery required
   - **Extension** (existing system) → Integration-focused discovery
   - **Simple Addition** (CRUD/UI) → Minimal or no discovery
   - **Complex Integration** → Comprehensive analysis required

2. **Execute Appropriate Discovery Process** (in every path, write the findings per `docs/settings/rules/document-hygiene.md`):

   **For Complex/New Features (Full Discovery)**:
   - Read and execute `docs/settings/rules/design-discovery-full.md`
   - Conduct thorough research using WebSearch/WebFetch:
     - Latest architectural patterns and best practices
     - External dependency verification (APIs, libraries, versions, compatibility)
     - Official documentation, migration guides, known issues
     - Performance benchmarks and security considerations

   **For Extensions (Light Discovery)**:
   - Read and execute `docs/settings/rules/design-discovery-light.md`
   - Focus on integration points, existing patterns, compatibility
   - Use Grep to analyze existing codebase patterns

   **For Simple Additions (Minimal Discovery)**:
   - Skip formal discovery, quick pattern check only

3. **Incorporate Gap Analysis** (if available): use the `gap-analysis.md` findings as additional context and prioritize the gaps it identified. The discovery rule you read above governs *what* to investigate — do not restate its steps here.

4. **Measure what cannot be reasoned**: apply `evidence-discipline.md` §1 throughout. Size, count and duration; the behavior of existing code; external specs; performance — these are settled by running something, never by reading. Write the verification artifacts (scripts, raw logs, results) to `{spec_path}/probe/` with a `README.md` index, per §3 of that rule. Record what you ran so a reader can re-run it.

5. **Retain findings for Step 3** in the claim form of `evidence-discipline.md` §2: each claim carries its type, its reproducer, its confidence, and what breaks in the design if it turns out to be wrong.

### Step 3: Generate research.md

**Using the template loaded in Step 1 (`docs/settings/templates/specs/research.md`) and the discovery findings from Step 2, generate research.md.**

1. **Language Compliance**: Write all content in the language specified by `spec.json.language` (e.g., `"ja"` means Japanese).

2. **Populate the template**. Two sections carry the discipline and must not be filled loosely:
   - **Research Log** — one `C<n>` claim per finding, each with its four tag lines. A claim is typed `measured` only when `Verification` names something re-runnable.
   - **Summary / Key Findings** — may contain nothing that lacks a `C<n>` entry below. Never restate a lower bound, a partial count, or a sample as a total.

   Fill the remaining sections (Unverified & Open, Architecture Pattern Evaluation, Design Decisions, Risks, References) as the template describes. Each Design Decision names the `C<n>` it rests on and states the actionable recommendation for the design phase.

3. **Write research.md**: Output the completed document to `{spec_path}/research.md` using the Write tool.

## Critical Constraints

- **No spec.json update**: Do NOT modify spec.json — no phase transition, no approval state change. The existence of research.md is the sole indicator of research completion.
- **Measure, don't reason**: the four kinds of claim in `evidence-discipline.md` §1 may not be settled by reading. If you cannot measure one, type it `unverified` and say what would settle it — an honest gap is a result, an invented certainty is a defect the design inherits.
- **Steering alignment**: Respect existing architecture patterns from steering context
- **Language compliance**: Use the language specified in `spec.json.language`

</instructions>

## Tool Guidance

- **Read first**: Load all context (spec, steering, template, rule, gap-analysis) before taking action; read the discovery rule only after classifying the Feature Type
- **Run things**: use Bash and the project's test/probe tooling to measure. Grep locates code; it does not establish behavior
- **Research when uncertain**: Use WebSearch/WebFetch for external dependencies, APIs, and latest best practices
- **Write last**: Generate research.md only after all research and analysis complete

## Output Description

Provide brief summary in the language specified in spec.json:

1. **Status**: Confirm research document generated at `{spec_path}/research.md` (and `probe/` if verification artifacts were produced)
2. **Discovery Type**: Which discovery process was executed (full/light/minimal)
3. **Key Findings**: 2-3 critical insights that will inform the design, each with its `C<n>`
4. **Unverified**: Any load-bearing claim that could not be measured — name it plainly
5. **Next Action**: Guidance for next step

**Format**: Concise Markdown (under 200 words)

## Safety & Fallback

### Error Scenarios

**Requirements Not Approved**:

- **Stop Execution**: Cannot proceed without approved requirements
- **User Message**: "Requirements not yet approved. Approval required before research execution."
- **Suggested Action**: "Run `/sdd-spec-research <feature-name> -y` to auto-approve requirements and proceed"

**Missing Requirements**:

- **Stop Execution**: Requirements document must exist
- **User Message**: "No requirements.md found at `{spec_path}/requirements.md`"
- **Suggested Action**: "Run `/sdd-spec-requirements <feature-name>` to generate requirements first"

**Spec Directory Not Found**:

- **Stop Execution**: Feature directory must exist
- **User Message**: "No spec directory found for `<feature-name>` in `docs/tasks/todo/` or `docs/tasks/done/`"
- **Suggested Action**: "Run `/sdd-spec-init <description>` to initialize a new specification"

**Template Missing**:

- **User Message**: "Template file missing at `docs/settings/templates/specs/research.md`"
- **Suggested Action**: "Check repository setup or restore template file"
- **Fallback**: Use inline basic structure with warning

**Steering Context Missing**:

- **Warning**: "Steering directory empty or missing - research may not align with project standards"
- **Proceed**: Continue with research but note limitation in output

### Next Phase: Research Validation

**After Research Completed**:

- Review generated research at `{spec_path}/research.md`
- **Recommended**: run `/sdd-validate-research <feature-name>` — it re-runs the recorded evidence independently and surfaces load-bearing claims that were never measured. Catching a wrong finding here is far cheaper than unwinding a design built on it
- Then `/sdd-spec-design <feature-name> -y` to proceed to design phase

**If Re-research Needed**:

- Delete `research.md` and re-run `/sdd-spec-research <feature-name> -y`
