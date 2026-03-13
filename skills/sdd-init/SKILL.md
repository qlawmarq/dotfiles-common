---
name: sdd-init
description: >-
  Initialize SDD (Spec-Driven Development) in the current project.
  Deploys rules, templates, skills, and project configuration from user-level SDD resources.
argument-hint: "[--lang=ja] [--target=claude|agents|all] [--force]"
---

# SDD Project Initialization

<background_information>

- **Mission**: Set up Spec-Driven Development infrastructure in the current project by deploying rules, templates, skills, and project configuration from user-level SDD resources
- **Success Criteria**:
  - All SDD directory structures created (`docs/settings/`, `docs/steering/`, `docs/tasks/`)
  - Rules and templates deployed to `docs/settings/`
  - SDD skills deployed to selected target(s): `.claude/skills/sdd-*/` and/or `.agents/skills/sdd-*/`
  - Steering stubs initialized in `docs/steering/`
  - CLAUDE.md and/or AGENTS.md updated with SDD configuration section (based on target)
  - Language configuration applied throughout

</background_information>

<instructions>

## Input

This skill expects:
1. **Language flag** (optional): `--lang=<code>` — ISO 639-1 language code (default: `ja`)
2. **Target flag** (optional): `--target=claude|agents|all` — Target platform(s) for deployment
   - `claude`: Deploy to `.claude/skills/` and update CLAUDE.md
   - `agents`: Deploy to `.agents/skills/` and update AGENTS.md
   - `all`: Deploy to both platforms
   - If omitted: Ask the user interactively
3. **Force flag** (optional): `--force` — Skip confirmation prompt when SDD is already initialized (defaults to Update mode)

If inputs were provided with this skill invocation, use them directly.
Otherwise, use the default language (`ja`).

## Source Files Location

SDD resources are stored alongside this skill file. Resolve the skill directory (`SKILL_DIR`) using the first match:

1. `${CLAUDE_SKILL_DIR}` (Claude Code - auto-resolved)
2. `~/.claude/skills/sdd-init` (Claude Code fallback)
3. `~/.agents/skills/sdd-init` (Codex CLI / Gemini CLI)

Derive from `SKILL_DIR`:
- `SRC="${SKILL_DIR}/references"` — Rules, templates, and AGENTS.md template
- `SKILLS_SRC="${SRC}/skills"` — Bundled skill directories (spec-init/, spec-design/, etc.)

Validate: `${SRC}/rules/` and `${SRC}/templates/` must exist. `${SKILLS_SRC}/spec-init/SKILL.md` must exist.

## Helper Script

All mechanical file operations are handled by `sdd-init.sh` located alongside this SKILL.md at `${SKILL_DIR}/sdd-init.sh`. This script:
- Creates directory structures
- Copies rules, templates, and skills
- Updates `init.json` language field
- Initializes steering stubs
- Performs marker-based injection into CLAUDE.md / AGENTS.md
- Outputs a structured report

## Execution Steps

### Step 0: Pre-flight Checks

Run a single Bash command to gather all pre-flight information:

```bash
echo "git_root=$([ -d .git ] && echo yes || echo no) sdd_exists=$([ -d docs/settings ] && echo yes || echo no)"
```

Process results:
1. **`git_root=no`**: Stop with error — "SDD initialization must be run from the git repository root."
2. **`sdd_exists=yes` AND `--force` not set**: Ask the user how to proceed:
   - **Update** (default): Overwrite rules, templates, and skills. Preserve `docs/steering/` and `docs/tasks/`.
   - **Full Reinitialize**: Overwrite everything except `docs/tasks/`.
   - **Cancel**: Abort.
3. **`sdd_exists=yes` AND `--force` set**: Proceed with Update mode silently.
4. **`sdd_exists=no`**: Proceed with fresh initialization.

### Step 1: Target Selection

If `--target` was NOT provided as an argument:
- Ask the user which platform(s) to initialize:
  - **Claude Code** (`claude`): `.claude/skills/` + CLAUDE.md
  - **Agents** (`agents`): `.agents/skills/` + AGENTS.md — for Codex CLI / Gemini CLI
  - **All** (`all`): Both platforms
- Use their selection as `TARGET`

### Step 2: Execute Initialization

Resolve paths and run the helper script in a single Bash call:

```bash
SKILL_DIR="<resolved_skill_dir>"
SRC="${SKILL_DIR}/references"
SKILLS_SRC="<resolved_skills_src>"

bash "${SKILL_DIR}/sdd-init.sh" \
  --lang=<code> \
  --target=<target> \
  --mode=<fresh|update|full> \
  --src="$SRC" \
  --skills-src="$SKILLS_SRC"
```

The script outputs a structured report between `===SDD_INIT_REPORT===` and `===END_REPORT===` markers.

### Step 3: Output Summary

Parse the structured report and generate a summary. Do NOT use Read or Edit tools — all information is in the script output.

## Important Constraints

- DO NOT modify any files inside `docs/tasks/` (preserves existing specifications)
- DO NOT use Read, Edit, or Write tools for file operations — the helper script handles everything
- Use absolute paths for source paths to ensure reliability

</instructions>

## Tool Guidance

- Use **Bash** (1 call) for pre-flight checks in Step 0
- Use **Bash** (1 call) to run `sdd-init.sh` in Step 2
- Do NOT use Read, Edit, Write, or Glob — the helper script handles all file operations

## Output Description

Provide output in the language derived from `--lang`:

1. **Initialization Summary**: Brief description of what was set up
2. **Deployed Components** (from report values):
   - Rules: `rules_count` files deployed
   - Templates: `templates_count` files deployed
   - Skills: `skills_count` skills deployed (to target platform(s))
   - Steering stubs: `steering_created` / `steering_skipped`
   - CLAUDE.md: `claude_md` status (created / updated / appended / skipped)
   - AGENTS.md: `agents_md` status (created / updated / appended / skipped)
3. **Configuration**: Language set to `lang_name` (`lang_code`)
4. **Warnings** (if any):
   - `claude_gitignored`: "`.claude/` is excluded by .gitignore. Project-level SDD skills will not be version controlled."
   - `agents_gitignored`: "`.agents/` is excluded by .gitignore. Project-level SDD skills will not be version controlled."
   - `marker_warning`: "Inconsistent SDD markers detected. A new section was appended."
5. **Errors** (if any): Report from `errors` field
6. **Next Steps** (numbered action items):
   - Run `/sdd-steering` to generate project steering from codebase analysis
   - Run `/sdd-steering-custom` to add domain-specific steering (optional)
   - Run `/sdd-spec-init "description"` to start your first specification
7. **Created Directory Structure**: Show the final tree

**Format**: Concise Markdown, under 300 words

## Safety & Fallback

### Error Scenarios

**Not in Git Repository Root**:
- **Stop Execution**: Cannot proceed without git repository
- **User Message**: "SDD initialization must be run from the git repository root. Current directory does not contain `.git/`."

**Existing SDD Setup Detected** (without `--force`):
- **Prompt User**: Ask to choose Update / Full Reinitialize / Cancel
- **Default Recommendation**: Update (safest, preserves user content)
- **Behavior by mode**:
  - `fresh`: All operations create new (default for new projects)
  - `update`: Overwrite rules, templates, skills. Create only missing steering stubs.
  - `full`: All operations overwrite (except `docs/tasks/`)

**Helper Script Failure**:
- If script exits with error, report the error message to the user
- Check `errors` field in the report for partial failures

**CLAUDE.md / AGENTS.md Marker Inconsistency**:
- Script handles automatically: appends new section and reports `marker_warning`
- Include warning in output summary

**Source Files Not Found**:
- **Stop Execution**: Cannot proceed without SDD resources
- **User Message**: "SDD resources not found. Ensure SDD skills are installed at user level (run dotfiles apply.sh with claude module)."
