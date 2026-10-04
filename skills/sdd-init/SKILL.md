---
name: sdd-init
description: >-
  Initialize SDD (Spec-Driven Development) in the current project.
  Deploys rules, templates, skills, and project configuration from user-level SDD resources.
---

# SDD Project Initialization

<background_information>

- **Mission**: Set up Spec-Driven Development infrastructure in the current project by deploying rules, templates, skills, and project configuration from user-level SDD resources
- **Success Criteria**:
  - All SDD directory structures created (`docs/settings/`, `docs/steering/`, `docs/tasks/`)
  - Rules, templates, and scripts deployed to `docs/settings/`
  - SDD skills deployed to selected target(s): `.claude/skills/sdd-*/` and/or `.agents/skills/sdd-*/`
  - Steering stubs initialized in `docs/steering/`
  - AGENTS.md updated with SDD configuration section
  - Language configuration applied throughout

</background_information>

<instructions>

## Input

This skill expects:
1. **Language flag** (optional): `--lang=<code>` — ISO 639-1 language code (default: `ja`)
2. **Target flag** (optional): `--target=claude|agents|all` — Where to deploy skills (the SDD section always goes to AGENTS.md)
   - `claude`: Deploy to `.claude/skills/`
   - `agents`: Deploy to `.agents/skills/`
   - `all`: Deploy to both
   - If omitted: Ask the user interactively
3. **Force flag** (optional): `--force` — see Step 0

If inputs were provided with this skill invocation, use them directly.

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

All mechanical file operations are done by `${SKILL_DIR}/sdd-init.sh`.

## Execution Steps

### Step 0: Pre-flight Checks

Run a single shell command to gather all pre-flight information:

```bash
echo "git_root=$([ -d .git ] && echo yes || echo no) sdd_exists=$([ -d docs/settings ] && echo yes || echo no)"
```

Process results:
1. **`git_root=no`**: Stop with error — "SDD initialization must be run from the git repository root."
2. **`sdd_exists=yes` AND `--force` not set**: Ask the user how to proceed:
   - **Update** (default): Overwrite rules, templates, and skills; create only missing steering stubs; leave `docs/tasks/` untouched.
   - **Full Reinitialize**: Overwrite everything except `docs/tasks/`.
   - **Cancel**: Abort.
3. **`sdd_exists=yes` AND `--force` set**: Proceed with Update mode silently.
4. **`sdd_exists=no`**: Proceed with fresh initialization.

### Step 1: Target Selection

If `--target` was not given:
- Ask the user which platform(s) to initialize:
  - **Claude Code** (`claude`): `.claude/skills/`
  - **Agents** (`agents`): `.agents/skills/` — for Codex CLI / Gemini CLI
  - **All** (`all`): Both platforms
- Use their selection as `TARGET`

### Step 2: Execute Initialization

Resolve paths and run the helper script in a single shell command:

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

Parse the structured report and generate a summary.

## Important Constraints

- Do not read, edit or write project files yourself; `sdd-init.sh` does every file operation and its report holds what the summary needs.
- Use absolute paths for source paths to ensure reliability

</instructions>

## Output Description

Provide output in the language derived from `--lang`:

1. **Initialization Summary**: Brief description of what was set up
2. **Deployed Components** (from report values):
   - Rules: `rules_count` files deployed
   - Templates: `templates_count` files deployed
   - Skills: `skills_count` skills deployed (to target platform(s))
   - Scripts: `scripts_count` files deployed to `docs/settings/scripts/`
   - Steering stubs: `steering_created` / `steering_skipped`
   - Retired skills removed: `retired_removed`; retired rules/templates removed: `retired_rules_removed` (mention only when not `none`)
   - AGENTS.md: `agents_md` status (created / updated / appended / appended:marker_warning / skipped / write_failed)
3. **Configuration**: Language set to `lang_name` (`lang_code`)
4. **Warnings** (if any):
   - `claude_gitignored`: "`.claude/` is excluded by .gitignore. Project-level SDD skills will not be version controlled."
   - `agents_gitignored`: "`.agents/` is excluded by .gitignore. Project-level SDD skills will not be version controlled."
   - `agents_md=appended:marker_warning`: "Inconsistent SDD markers detected. A new section was appended."
5. **Errors** (if any): Report from `errors` field
   - `agents_md_write_failed`: "AGENTS.md could not be written, so it has no SDD section. Make it writable and re-run `/sdd-init`."
6. **Next Steps** (numbered action items):
   - When `retired_removed` or `retired_rules_removed` is not `none`: "Retired skills and rules were removed. `bash docs/settings/scripts/check_refs.sh check` lists the references to them that remain in the project's documents."
   - Run `/sdd-steering` to generate project steering from codebase analysis
   - Run `/sdd-steering-custom` to add domain-specific steering (optional)
   - For a large/greenfield effort: run `/sdd-plan "product goal"` to decompose it into right-sized specs
   - For a single piece of work (a feature, fix, refactor, verification or chore): run `/sdd-spec-init "description"` — it classifies the kind and picks the templates
7. **Created Directory Structure**: Show the final tree

**Format**: Concise Markdown, under 300 words

## Safety & Fallback

### Error Scenarios

**Helper Script Failure**:
- If script exits with error, report the error message to the user
- Check `errors` field in the report for partial failures

**Source Files Not Found**:
- **Stop Execution**: Cannot proceed without SDD resources
- **User Message**: "SDD resources not found. Ensure the sdd-init skill is installed with its `references/` directory."
