#!/bin/bash
# sdd-init.sh - SDD Project Initialization Helper
#
# Performs all mechanical file operations for SDD initialization.
# Called by SKILL.md to minimize AI tool calls and token consumption.
#
# Usage: sdd-init.sh --src=<path> --skills-src=<path> [options]
#
# Required:
#   --src=<path>          Absolute path to references/ directory
#   --skills-src=<path>   Absolute path to parent of sdd-* skill directories
#
# Options:
#   --lang=<code>         ISO 639-1 language code (default: ja)
#   --target=<target>     claude|agents|all (default: all)
#   --mode=<mode>         fresh|update|full (default: fresh)
#
# Output: Structured report between ===SDD_INIT_REPORT=== markers

set -eo pipefail

# === Argument Parsing ===
LANG_CODE="ja"
TARGET="all"
MODE="fresh"
SRC=""
SKILLS_SRC=""

for arg in "$@"; do
    case "$arg" in
        --lang=*) LANG_CODE="${arg#*=}" ;;
        --target=*) TARGET="${arg#*=}" ;;
        --mode=*) MODE="${arg#*=}" ;;
        --src=*) SRC="${arg#*=}" ;;
        --skills-src=*) SKILLS_SRC="${arg#*=}" ;;
    esac
done

if [ -z "$SRC" ] || [ -z "$SKILLS_SRC" ]; then
    echo "ERROR: --src and --skills-src are required" >&2
    exit 1
fi

if [ ! -d "$SRC/rules" ] || [ ! -d "$SRC/templates" ]; then
    echo "ERROR: Source directory invalid — $SRC/rules/ or $SRC/templates/ not found" >&2
    exit 1
fi

# === Language Name Derivation ===
get_language_name() {
    case "$1" in
        ja) echo "Japanese" ;;
        en) echo "English" ;;
        ko) echo "Korean" ;;
        zh) echo "Chinese" ;;
        fr) echo "French" ;;
        de) echo "German" ;;
        es) echo "Spanish" ;;
        pt) echo "Portuguese" ;;
        it) echo "Italian" ;;
        ru) echo "Russian" ;;
        *) echo "$1" ;;
    esac
}
LANG_NAME=$(get_language_name "$LANG_CODE")

# === Counters (string-based for bash 3.2 compat) ===
RULES_COUNT=0
TEMPLATES_COUNT=0
SKILLS_COUNT=0
STEERING_CREATED=""
STEERING_SKIPPED=""
CLAUDE_MD_STATUS="skipped"
AGENTS_MD_STATUS="skipped"
WARNINGS=""
ERRORS=""

append_csv() {
    local var_name="$1" value="$2"
    local current
    eval "current=\$$var_name"
    if [ -z "$current" ]; then
        eval "$var_name=\"$value\""
    else
        eval "$var_name=\"\${current},${value}\""
    fi
}

# === Marker-based Injection ===
inject_sdd_section() {
    local target_file="$1"
    local content_file="$2"
    local begin="<!-- SDD:BEGIN -->"
    local end="<!-- SDD:END -->"

    # File doesn't exist: create new
    if [ ! -f "$target_file" ]; then
        { printf '%s\n' "$begin"; cat "$content_file"; printf '%s\n' "$end"; } > "$target_file"
        echo "created"
        return
    fi

    local has_begin=0 has_end=0
    grep -qF "$begin" "$target_file" 2>/dev/null && has_begin=1
    grep -qF "$end" "$target_file" 2>/dev/null && has_end=1

    # Both markers present: replace content between them
    if [ "$has_begin" -eq 1 ] && [ "$has_end" -eq 1 ]; then
        local tmp
        tmp=$(mktemp)
        awk -v bm="$begin" -v em="$end" -v cf="$content_file" '
            $0 == bm {
                print bm
                while ((getline line < cf) > 0) print line
                close(cf)
                print em
                skip = 1
                next
            }
            $0 == em && skip { skip = 0; next }
            !skip { print }
        ' "$target_file" > "$tmp"
        mv "$tmp" "$target_file"
        echo "updated"
        return
    fi

    # Inconsistent markers: warn and append
    if [ "$has_begin" -eq 1 ] || [ "$has_end" -eq 1 ]; then
        { printf '\n%s\n' "$begin"; cat "$content_file"; printf '%s\n' "$end"; } >> "$target_file"
        echo "appended:marker_warning"
        return
    fi

    # No markers: append
    { printf '\n%s\n' "$begin"; cat "$content_file"; printf '%s\n' "$end"; } >> "$target_file"
    echo "appended"
}

# === Step 1: Directory Structure ===
mkdir -p docs/settings/rules \
         docs/settings/templates/specs \
         docs/settings/templates/steering \
         docs/settings/templates/steering-custom \
         docs/steering \
         docs/tasks/done \
         docs/tasks/todo

# === Step 2: Deploy Rules and Templates ===
cp "$SRC"/rules/*.md docs/settings/rules/ 2>/dev/null || append_csv ERRORS "rules_copy_failed"
cp "$SRC"/templates/specs/* docs/settings/templates/specs/ 2>/dev/null || append_csv ERRORS "specs_copy_failed"
cp "$SRC"/templates/steering/* docs/settings/templates/steering/ 2>/dev/null || append_csv ERRORS "steering_tpl_copy_failed"
cp "$SRC"/templates/steering-custom/* docs/settings/templates/steering-custom/ 2>/dev/null || append_csv ERRORS "steering_custom_copy_failed"

RULES_COUNT=$(find docs/settings/rules -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
TEMPLATES_COUNT=$(find docs/settings/templates -type f 2>/dev/null | wc -l | tr -d ' ')

# Update init.json language field
if [ -f "docs/settings/templates/specs/init.json" ]; then
    sed -i '' "s|\"language\": \"[^\"]*\"|\"language\": \"${LANG_CODE}\"|" docs/settings/templates/specs/init.json
fi

# === Step 3: Steering Stubs ===
for f in docs/settings/templates/steering/*.md; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    if [ "$MODE" = "full" ] || [ ! -f "docs/steering/$name" ]; then
        cp "$f" "docs/steering/$name"
        append_csv STEERING_CREATED "$name"
    else
        append_csv STEERING_SKIPPED "$name"
    fi
done

# === Step 4: Deploy SDD Skills ===

# Detect skill directory naming pattern:
#   Deployed layout (~/.claude/skills/): sdd-spec-init/, sdd-spec-design/, ...
#   Source tree layout (modules/.../sdd/): spec-init/, spec-design/, ...
if [ -d "$SKILLS_SRC/sdd-spec-init" ]; then
    SKILL_GLOB="sdd-*"
    SKIP_NAMES="sdd-init"
    DEPLOY_PREFIX=""
elif [ -d "$SKILLS_SRC/spec-init" ]; then
    SKILL_GLOB="*"
    SKIP_NAMES="init"
    DEPLOY_PREFIX="sdd-"
else
    append_csv ERRORS "skills_source_invalid"
    SKILL_GLOB=""
fi

deploy_skill_set() {
    local dest_base="$1"
    [ -z "$SKILL_GLOB" ] && return
    for skill_dir in "$SKILLS_SRC"/$SKILL_GLOB/; do
        [ -d "$skill_dir" ] || continue
        local dir_name
        dir_name=$(basename "$skill_dir")
        [ "$dir_name" = "$SKIP_NAMES" ] && continue
        [ -f "$skill_dir/SKILL.md" ] || continue
        local deploy_name="${DEPLOY_PREFIX}${dir_name}"
        mkdir -p "$dest_base/$deploy_name"
        cp "$skill_dir/SKILL.md" "$dest_base/$deploy_name/SKILL.md"
    done
}

case "$TARGET" in
    claude) deploy_skill_set ".claude/skills" ;;
    agents) deploy_skill_set ".agents/skills" ;;
    all)
        deploy_skill_set ".claude/skills"
        deploy_skill_set ".agents/skills"
        ;;
esac

# Count deployed skills
if [ -n "$SKILL_GLOB" ]; then
    for d in "$SKILLS_SRC"/$SKILL_GLOB/; do
        [ -d "$d" ] || continue
        [ "$(basename "$d")" = "$SKIP_NAMES" ] && continue
        [ -f "$d/SKILL.md" ] || continue
        SKILLS_COUNT=$((SKILLS_COUNT + 1))
    done
fi

# === Step 5: Update Config Files ===
TEMPLATE_FILE="$SRC/templates/AGENTS.md"
if [ -f "$TEMPLATE_FILE" ]; then
    CONFIG_TMP=$(mktemp)
    sed "s|{{DEFAULT_LANGUAGE_NAME}}|${LANG_NAME}|g" "$TEMPLATE_FILE" > "$CONFIG_TMP"

    case "$TARGET" in
        claude)
            CLAUDE_MD_STATUS=$(inject_sdd_section "CLAUDE.md" "$CONFIG_TMP")
            ;;
        agents)
            AGENTS_MD_STATUS=$(inject_sdd_section "AGENTS.md" "$CONFIG_TMP")
            ;;
        all)
            CLAUDE_MD_STATUS=$(inject_sdd_section "CLAUDE.md" "$CONFIG_TMP")
            AGENTS_MD_STATUS=$(inject_sdd_section "AGENTS.md" "$CONFIG_TMP")
            ;;
    esac

    rm -f "$CONFIG_TMP"
else
    append_csv ERRORS "agents_md_template_not_found"
fi

# === Warnings ===
case "$TARGET" in
    claude)
        git check-ignore -q .claude/ 2>/dev/null && append_csv WARNINGS "claude_gitignored"
        ;;
    agents)
        git check-ignore -q .agents/ 2>/dev/null && append_csv WARNINGS "agents_gitignored"
        ;;
    all)
        git check-ignore -q .claude/ 2>/dev/null && append_csv WARNINGS "claude_gitignored"
        git check-ignore -q .agents/ 2>/dev/null && append_csv WARNINGS "agents_gitignored"
        ;;
esac

# === Structured Report ===
cat << EOF
===SDD_INIT_REPORT===
lang_code=${LANG_CODE}
lang_name=${LANG_NAME}
target=${TARGET}
mode=${MODE}
rules_count=${RULES_COUNT}
templates_count=${TEMPLATES_COUNT}
skills_count=${SKILLS_COUNT}
steering_created=${STEERING_CREATED:-none}
steering_skipped=${STEERING_SKIPPED:-none}
claude_md=${CLAUDE_MD_STATUS}
agents_md=${AGENTS_MD_STATUS}
warnings=${WARNINGS:-none}
errors=${ERRORS:-none}
===END_REPORT===
EOF
