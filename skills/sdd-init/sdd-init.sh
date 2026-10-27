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
#   --skills-src=<path>   Absolute path to references/skills/ directory
#
# Options:
#   --lang=<code>         ISO 639-1 language code (default: ja)
#   --target=<target>     claude|agents|all (default: all) — where skills go;
#                         the SDD section always goes to AGENTS.md
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

case "$TARGET" in
    claude) DESTS=".claude" ;;
    agents) DESTS=".agents" ;;
    all) DESTS=".claude .agents" ;;
    *) echo "ERROR: --target must be claude, agents, or all" >&2; exit 1 ;;
esac

if [ ! -d "$SRC/rules" ] || [ ! -d "$SRC/templates" ]; then
    echo "ERROR: Source directory invalid — $SRC/rules/ or $SRC/templates/ not found" >&2
    exit 1
fi

# === Language Name Derivation ===
case "$LANG_CODE" in
    ja) LANG_NAME="Japanese" ;;
    en) LANG_NAME="English" ;;
    ko) LANG_NAME="Korean" ;;
    zh) LANG_NAME="Chinese" ;;
    fr) LANG_NAME="French" ;;
    de) LANG_NAME="German" ;;
    es) LANG_NAME="Spanish" ;;
    pt) LANG_NAME="Portuguese" ;;
    it) LANG_NAME="Italian" ;;
    ru) LANG_NAME="Russian" ;;
    *) LANG_NAME="$LANG_CODE" ;;
esac

# === Report Values ===
STEERING_CREATED=""
STEERING_SKIPPED=""
DECISIONS_CREATED=""
DECISIONS_SKIPPED=""
AGENTS_MD_STATUS="skipped"
WARNINGS=""
ERRORS=""

append_csv() { printf -v "$1" '%s' "${!1:+${!1},}$2"; }

# === Marker-based Injection ===
inject_sdd_section() {
    local target_file="$1"
    local content_file="$2"
    local begin="<!-- SDD:BEGIN -->"
    local end="<!-- SDD:END -->"

    # File doesn't exist: create new
    if [ ! -f "$target_file" ]; then
        { printf '%s\n' "$begin"; cat "$content_file"; printf '%s\n' "$end"; } > "$target_file" || { echo "write_failed"; return; }
        echo "created"
        return
    fi

    # Replace each block from a whole-line BEGIN to the next whole-line END;
    # lines of an unclosed BEGIN pass through unchanged. Exit: 0 replaced, 10 no markers, 11 stray markers
    local tmp rc=0 status
    tmp=$(mktemp) || { echo "write_failed"; return; }
    awk -v bm="$begin" -v em="$end" -v cf="$content_file" '
        function flush(  i) { for (i = 1; i <= n; i++) print buf[i]; n = 0 }
        { l = $0; sub(/\r$/, "", l) }
        l == bm { seen = 1; flush(); buf[n = 1] = $0; next }
        l == em { seen = 1 }
        l == em && n {
            print bm
            while ((getline line < cf) > 0) print line
            close(cf)
            print em
            n = 0; done = 1; next
        }
        n { buf[++n] = $0; next }
        { print }
        END { flush(); exit done ? 0 : seen ? 11 : 10 }
    ' "$target_file" > "$tmp" || rc=$?
    case "$rc" in
        0) cat "$tmp" > "$target_file" && status="updated" ;;
        10) status="appended" ;;
        11) status="appended:marker_warning" ;;
    esac
    rm -f "$tmp"
    # No closed block: append (stray markers also warn)
    case "$status" in
        appended*) { printf '\n%s\n' "$begin"; cat "$content_file"; printf '%s\n' "$end"; } >> "$target_file" || status="" ;;
    esac
    echo "${status:-write_failed}"
}

# === Step 1: Directory Structure ===
mkdir -p docs/settings/rules \
         docs/settings/scripts \
         docs/steering \
         docs/plans \
         docs/decisions \
         docs/specs/done \
         docs/specs/todo
# git does not track an empty directory; mark the ones still empty
for d in docs/plans docs/specs/done docs/specs/todo; do [ -n "$(ls -A "$d")" ] || : > "$d/.gitkeep"; done

# === Step 2: Deploy Rules and Templates ===
cp "$SRC"/rules/*.md docs/settings/rules/ 2>/dev/null || append_csv ERRORS "rules_copy_failed"
for tpl in "$SRC"/templates/*/; do
    [ -d "$tpl" ] || continue
    tpl=$(basename "$tpl")
    mkdir -p "docs/settings/templates/$tpl"
    cp "$SRC/templates/$tpl"/* "docs/settings/templates/$tpl/" 2>/dev/null || append_csv ERRORS "templates_copy_failed:$tpl"
done
if [ -d "$SRC/scripts" ]; then
    cp "$SRC"/scripts/* docs/settings/scripts/ 2>/dev/null || append_csv ERRORS "scripts_copy_failed"
    chmod +x docs/settings/scripts/*.sh 2>/dev/null || :
fi

# Rules/templates/scripts retired upstream. Explicit list only — cp never removes, so a stale
# rule would keep being loaded by skills that no longer reference it.
RETIRED="rules/ratification.md rules/normative-registry.md rules/change-propagation.md rules/canon-layer.md rules/inception-decomposition.md
    templates/canon/proposal.md templates/inception/vision.md templates/inception/story-map.md templates/inception/inception.json
    templates/canon/README.md templates/canon/decision.md templates/canon/registry.md templates/inception/units.md
    templates/inception/dependencies.md templates/steering/behaviors.md scripts/check_canon.sh"
RETIRED_RULES_REMOVED=""
for name in $RETIRED; do
    if [ -f "docs/settings/$name" ]; then
        rm -f "docs/settings/$name"; append_csv RETIRED_RULES_REMOVED "$name"
        # remove a template directory the retirement left empty
        case "$name" in templates/*) rmdir "$(dirname "docs/settings/$name")" 2>/dev/null || : ;; esac
    fi
done

SCRIPTS_COUNT=$(find docs/settings/scripts -type f 2>/dev/null | wc -l | tr -d ' ')
RULES_COUNT=$(find docs/settings/rules -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
TEMPLATES_COUNT=$(find docs/settings/templates -type f 2>/dev/null | wc -l | tr -d ' ')

# Update init.json language field
if [ -f "docs/settings/templates/specs/init.json" ]; then
    sed "s|\"language\": \"[^\"]*\"|\"language\": \"${LANG_CODE}\"|" docs/settings/templates/specs/init.json > docs/settings/templates/specs/init.json.tmp
    mv docs/settings/templates/specs/init.json.tmp docs/settings/templates/specs/init.json
fi

# === Step 3: Steering Stubs ===
stub() {
    [ -f "$1" ] || return 0
    local name
    name=$(basename "$1")
    if [ "$4" = "yes" ] || [ ! -f "$2/$name" ]; then
        cp "$1" "$2/$name"
        append_csv "$3_CREATED" "$name"
    else
        append_csv "$3_SKIPPED" "$name"
    fi
}

OVERWRITE="no"; [ "$MODE" = "full" ] && OVERWRITE="yes"
for f in docs/settings/templates/steering/*.md; do stub "$f" docs/steering STEERING "$OVERWRITE"; done

# Decision stubs: the index and the registry. Never overwritten — they index decision
# files that are not templates.
for name in README.md registry.md; do stub "docs/settings/templates/decisions/$name" docs/decisions DECISIONS no; done

# === Step 4: Deploy SDD Skills ===
[ -d "$SKILLS_SRC/spec-init" ] || { append_csv ERRORS "skills_source_invalid"; SKILLS_SRC=""; }

# Skills renamed/retired upstream. Explicit list only — never "delete anything
# not in source", which would destroy user-authored skills in the same dir.
RETIRED_SKILLS="sdd-ratify sdd-canon-propose sdd-canon-ratify sdd-canon-update"
RETIRED_REMOVED=""

for d in $DESTS; do
    SKILLS_COUNT=0
    for skill_dir in ${SKILLS_SRC:+"$SKILLS_SRC"/*/}; do
        [ -f "$skill_dir/SKILL.md" ] || continue
        dest="$d/skills/sdd-$(basename "$skill_dir")"
        mkdir -p "$dest"
        cp "$skill_dir/SKILL.md" "$dest/SKILL.md"
        SKILLS_COUNT=$((SKILLS_COUNT + 1))
    done
    for name in $RETIRED_SKILLS; do
        if [ -d "$d/skills/$name" ]; then
            rm -rf "$d/skills/$name"
            append_csv RETIRED_REMOVED "$d/skills/$name"
        fi
    done
    git check-ignore -q "$d/" 2>/dev/null && append_csv WARNINGS "${d#.}_gitignored"
done

# === Step 5: Update Config Files ===
TEMPLATE_FILE="$SRC/templates/AGENTS.md"
if [ -f "$TEMPLATE_FILE" ]; then
    CONFIG_TMP=$(mktemp)
    sed "s|{{DEFAULT_LANGUAGE_NAME}}|${LANG_NAME}|g" "$TEMPLATE_FILE" > "$CONFIG_TMP"

    AGENTS_MD_STATUS=$(inject_sdd_section "AGENTS.md" "$CONFIG_TMP")
    [ "$AGENTS_MD_STATUS" = "write_failed" ] && append_csv ERRORS "agents_md_write_failed"

    rm -f "$CONFIG_TMP"
else
    append_csv ERRORS "agents_md_template_not_found"
fi

# === Warnings ===
# project directories and declarations from before the current layout
for d in docs/tasks docs/inception docs/canon; do [ -d "$d" ] && append_csv WARNINGS "legacy_dir:$d"; done
grep -qE '^## Canon References|Canon root:' docs/steering/product.md 2>/dev/null && append_csv WARNINGS "legacy_product_md"

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
scripts_count=${SCRIPTS_COUNT}
steering_created=${STEERING_CREATED:-none}
steering_skipped=${STEERING_SKIPPED:-none}
decisions_created=${DECISIONS_CREATED:-none}
decisions_skipped=${DECISIONS_SKIPPED:-none}
retired_removed=${RETIRED_REMOVED:-none}
retired_rules_removed=${RETIRED_RULES_REMOVED:-none}
agents_md=${AGENTS_MD_STATUS}
warnings=${WARNINGS:-none}
errors=${ERRORS:-none}
===END_REPORT===
EOF
