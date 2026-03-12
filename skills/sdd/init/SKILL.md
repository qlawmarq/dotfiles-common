---
name: sdd-init
description: >-
  Initialize SDD (Spec-Driven Development) in the current project.
  Deploys rules, templates, skills, and project configuration from user-level SDD resources.
argument-hint: "[--lang=ja] [--force]"
---

# SDD Project Initialization

<background_information>

- **Mission**: Set up Spec-Driven Development infrastructure in the current project by deploying rules, templates, skills, and project configuration from user-level SDD resources
- **Success Criteria**:
  - All SDD directory structures created (`docs/settings/`, `docs/steering/`, `docs/tasks/`)
  - Rules and templates deployed to `docs/settings/`
  - SDD skills deployed to `.claude/skills/sdd-*/` and `.agents/skills/sdd-*/`
  - Steering stubs initialized in `docs/steering/`
  - CLAUDE.md and AGENTS.md updated with SDD configuration section
  - Language configuration applied throughout

</background_information>

<instructions>

## Input

This skill expects:
1. **Language flag** (optional): `--lang=<code>` — ISO 639-1 language code (default: `ja`)
2. **Force flag** (optional): `--force` — Skip confirmation prompt when SDD is already initialized (defaults to Update mode)

If inputs were provided with this skill invocation, use them directly.
Otherwise, use the default language (`ja`).

## Source Files Location

SDD resources are stored alongside this skill file. Resolve the source path (`SRC`) using the first match:

1. `${CLAUDE_SKILL_DIR}/references/` (Claude Code - auto-resolved)
2. `~/.claude/skills/sdd-init/references/` (Claude Code fallback)
3. `~/.agents/skills/sdd-init/references/` (Codex CLI / Gemini CLI)

Validate that `${SRC}/rules/` and `${SRC}/templates/` exist. If none found, report an error and stop.

Similarly, resolve the skills source path (`SKILLS_SRC`) — the parent directory containing `sdd-*` skill directories (excluding `sdd-init`):

1. Same parent as `${SRC}/../../` (sibling directories to `init/`)
2. `~/.claude/skills/` (fallback)
3. `~/.agents/skills/` (fallback)

Validate by checking that `sdd-spec-init/SKILL.md` exists under the resolved path.

## Argument Parsing

- `--lang=<code>`: ISO 639-1 language code (default: `ja`)
  - Determines the `language` field in `docs/settings/templates/specs/init.json`
  - Determines the language instruction appended to CLAUDE.md and AGENTS.md
  - Derive the full language name from the code (e.g., `ja` → `Japanese`, `en` → `English`, `ko` → `Korean`, `zh` → `Chinese`)
- `--force`: Skip the existing SDD confirmation prompt, proceed with Update mode

## Execution Steps

### Step 0: Pre-flight Checks

Run all checks in a single Bash call where possible:

1. **Verify Git Repository Root**: Check that `.git/` exists in the current working directory. If not, stop with error.

2. **Detect Existing SDD Setup + .gitignore check**:
   - Check if `docs/settings/` directory exists
   - Check if `.claude/` is matched by `.gitignore` (`git check-ignore -q .claude/ 2>/dev/null`)
   - **If `docs/settings/` exists AND `--force` not set**: Ask the user how to proceed:
     - **Update** (default): Overwrite rules, templates, and skills. Preserve `docs/steering/` and `docs/tasks/`.
     - **Full Reinitialize**: Overwrite everything except `docs/tasks/`.
     - **Cancel**: Abort.
   - **If `docs/settings/` exists AND `--force` set**: Proceed with Update mode silently.
   - **If not exists**: Proceed with fresh initialization (no prompt needed).
   - If `.claude/` is in `.gitignore`: Note the warning for the summary output (do not block).

### Step 1: Create Directory Structure

Create all required directories in a single `mkdir -p` call:

```bash
mkdir -p docs/settings/rules \
         docs/settings/templates/specs \
         docs/settings/templates/steering \
         docs/settings/templates/steering-custom \
         docs/steering \
         docs/tasks/done \
         docs/tasks/todo
```

### Step 2: Deploy Rules and Templates

Use `cp` for bulk file copying:

```bash
cp "${SRC}"/rules/*.md docs/settings/rules/
cp "${SRC}"/templates/specs/* docs/settings/templates/specs/
cp "${SRC}"/templates/steering/* docs/settings/templates/steering/
cp "${SRC}"/templates/steering-custom/* docs/settings/templates/steering-custom/
```

**Post-copy**: Read `docs/settings/templates/specs/init.json` and update the `"language"` field to the value specified by `--lang`. Use the Edit tool for this single targeted change.

### Step 3: Initialize Steering Stubs

For each `.md` file in `docs/settings/templates/steering/`:

- If `docs/steering/<filename>` does **NOT** exist: `cp` the template as an initial stub
- If `docs/steering/<filename>` **already exists**: Skip (preserve user content)

This can be done in a single Bash block:

```bash
for f in docs/settings/templates/steering/*.md; do
  name=$(basename "$f")
  [ ! -f "docs/steering/$name" ] && cp "$f" "docs/steering/$name"
done
```

### Step 4: Deploy SDD Skills to Project

Deploy SDD skill files to project for team access using bulk copy.

Dynamically discover skills: find all `sdd-*` directories (excluding `sdd-init`) under `${SKILLS_SRC}` that contain `SKILL.md`.

Deploy to BOTH targets for cross-agent compatibility:

```bash
for skill_dir in "${SKILLS_SRC}"/sdd-*/; do
  skill_name=$(basename "$skill_dir")
  [ "$skill_name" = "sdd-init" ] && continue
  [ ! -f "$skill_dir/SKILL.md" ] && continue
  mkdir -p ".claude/skills/$skill_name" ".agents/skills/$skill_name"
  cp "$skill_dir/SKILL.md" ".claude/skills/$skill_name/SKILL.md"
  cp "$skill_dir/SKILL.md" ".agents/skills/$skill_name/SKILL.md"
done
```

### Step 5: Update Agent Configuration Files

1. **Read template**: Load `${SRC}/templates/AGENTS.md`

2. **Replace placeholder**: Replace `{{DEFAULT_LANGUAGE_NAME}}` with the full language name derived from `--lang`

3. **Deploy to CLAUDE.md**:
   - Wrap with `<!-- SDD:BEGIN -->` / `<!-- SDD:END -->` markers
   - CLAUDE.md exists + markers found: Replace content between markers (inclusive)
   - CLAUDE.md exists + no markers: Append wrapped content
   - CLAUDE.md does not exist: Create new file with wrapped content

4. **Deploy to AGENTS.md** (project root, for Codex CLI):
   - Same marker-based injection approach as CLAUDE.md
   - Create file if it doesn't exist

## Important Constraints

- DO NOT modify any files inside `docs/tasks/` (preserves existing specifications)
- DO NOT overwrite `docs/steering/*.md` files that already contain user content (Step 3 skip logic)
- Preserve all existing CLAUDE.md content outside `<!-- SDD:BEGIN -->` / `<!-- SDD:END -->` markers
- Preserve all existing AGENTS.md content outside `<!-- SDD:BEGIN -->` / `<!-- SDD:END -->` markers
- Use absolute paths for source paths to ensure reliability

</instructions>

## Tool Guidance

- Use **Bash** for directory creation, file copying (`cp`), and pre-flight checks — these are the primary operations
- Use **Read** to load the AGENTS.md template and `init.json` for editing
- Use **Edit** for targeted modifications (CLAUDE.md/AGENTS.md marker injection, init.json language field)
- Use **Glob** only if dynamic skill discovery needs verification

## Output Description

Provide output in the language derived from `--lang`:

1. **Initialization Summary**: Brief description of what was set up
2. **Deployed Components**:
   - Rules: X files deployed
   - Templates: X files deployed
   - Skills: X skills deployed (to both `.claude/skills/` and `.agents/skills/`)
   - Steering stubs: created / skipped (per file)
   - CLAUDE.md: created / updated / appended
   - AGENTS.md: created / updated / appended
3. **Configuration**: Language set to `<language name>` (`<code>`)
4. **Next Steps** (numbered action items):
   - Run `/sdd-steering` to generate project steering from codebase analysis
   - Run `/sdd-steering-custom` to add domain-specific steering (optional)
   - Run `/sdd-spec-init "description"` to start your first specification
5. **Created Directory Structure**: Show the final tree

**Format**: Concise Markdown, under 300 words

## Safety & Fallback

### Error Scenarios

**Not in Git Repository Root**:
- **Stop Execution**: Cannot proceed without git repository
- **User Message**: "SDD initialization must be run from the git repository root. Current directory does not contain `.git/`."

**Existing SDD Setup Detected** (without `--force`):
- **Prompt User**: Ask to choose Update / Full Reinitialize / Cancel
- **Default Recommendation**: Update (safest, preserves user content)
- **Behavior by choice**:
  - Update: Steps 2, 4, 5 execute (overwrite). Steps 1, 3 create only missing items.
  - Full Reinitialize: All steps execute. Step 3 overwrites steering stubs.
  - Cancel: Exit with no changes.

**Copy Failure**:
- **Continue**: Report the specific error, continue with remaining steps
- **Summary**: List all failures at the end of output

**CLAUDE.md / AGENTS.md Marker Inconsistency**:
- **Detection**: `<!-- SDD:BEGIN -->` found without matching `<!-- SDD:END -->`, or vice versa
- **Action**: Warn user, append new complete marked section to end of file

**.claude/ in .gitignore**:
- **Warning only** (in summary output): "`.claude/` is excluded by .gitignore. Project-level SDD skills will not be version controlled."
- **Do not modify .gitignore**: Leave the decision to the user

**Source Files Not Found**:
- **Stop Execution**: Cannot proceed without SDD resources
- **User Message**: "SDD resources not found. Ensure SDD skills are installed at user level (run dotfiles apply.sh with claude module)."
