#!/bin/bash

# ====================
# Sync skills from upstream repositories
# ====================
#
# Usage:
#   bash scripts/sync-upstream-skills.sh                      # Sync all upstream skills
#   bash scripts/sync-upstream-skills.sh skill-creator        # Sync a specific skill
#   bash scripts/sync-upstream-skills.sh --dry-run             # Preview changes only
#   bash scripts/sync-upstream-skills.sh --dry-run skill-creator

set -euo pipefail

# ---------------------
# Constants
# ---------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
CONFIG_FILE="$REPO_ROOT/upstream-skills.conf"
LOCK_FILE="$REPO_ROOT/upstream-skills.lock"
MIN_GIT_VERSION="2.25.0"

# ---------------------
# Output helpers
# ---------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
print_header()  { echo -e "\n${BOLD}=== $1 ===${NC}"; }

# ---------------------
# Argument parsing
# ---------------------
DRY_RUN=false
TARGET_SKILL=""

for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        --help|-h)
            echo "Usage: $(basename "$0") [--dry-run] [skill-name]"
            echo ""
            echo "Sync skills from upstream repositories defined in upstream-skills.conf."
            echo ""
            echo "Options:"
            echo "  --dry-run    Preview changes without applying"
            echo "  --help       Show this help message"
            echo ""
            echo "Arguments:"
            echo "  skill-name   Sync only the specified skill (syncs all if omitted)"
            exit 0
            ;;
        -*)
            print_error "Unknown option: $arg"
            exit 1
            ;;
        *)
            if [ -n "$TARGET_SKILL" ]; then
                print_error "Only one skill name can be specified"
                exit 1
            fi
            TARGET_SKILL="$arg"
            ;;
    esac
done

# ---------------------
# Precondition checks
# ---------------------

# Check git version (need 2.25+ for sparse-checkout)
check_git_version() {
    local git_version
    git_version="$(git --version | sed 's/[^0-9.]//g' | cut -d. -f1-3)"

    local IFS='.'
    local -a current=($git_version)
    local -a required=($MIN_GIT_VERSION)

    for i in 0 1 2; do
        local cur="${current[$i]:-0}"
        local req="${required[$i]:-0}"
        if [ "$cur" -gt "$req" ]; then
            return 0
        elif [ "$cur" -lt "$req" ]; then
            return 1
        fi
    done
    return 0
}

if ! check_git_version; then
    print_error "git $MIN_GIT_VERSION+ is required for sparse checkout (found: $(git --version))"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    print_error "Config file not found: $CONFIG_FILE"
    exit 1
fi

# ---------------------
# Config parser
# ---------------------

# Arrays to hold parsed config entries
SKILL_NAMES=()
SKILL_REPOS=()
SKILL_PATHS=()
SKILL_BRANCHES=()

parse_config() {
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        line="$(echo "$line" | sed 's/#.*//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')"
        [ -z "$line" ] && continue

        # Parse space-separated fields
        local name repo path branch
        name="$(echo "$line" | awk '{print $1}')"
        repo="$(echo "$line" | awk '{print $2}')"
        path="$(echo "$line" | awk '{print $3}')"
        branch="$(echo "$line" | awk '{print $4}')"
        branch="${branch:-main}"

        if [ -z "$name" ] || [ -z "$repo" ] || [ -z "$path" ]; then
            print_warning "Skipping malformed line: $line"
            continue
        fi

        SKILL_NAMES+=("$name")
        SKILL_REPOS+=("$repo")
        SKILL_PATHS+=("$path")
        SKILL_BRANCHES+=("$branch")
    done < "$CONFIG_FILE"
}

# ---------------------
# Sparse checkout
# ---------------------
# Sets UPSTREAM_SHA to the commit that was checked out.
UPSTREAM_SHA=""

sparse_checkout() {
    local repo="$1"
    local path="$2"
    local ref="$3"
    local dest="$4"

    UPSTREAM_SHA=""
    if [[ "$ref" =~ ^[0-9a-f]{40}$ ]]; then
        # A pinned commit: --branch only takes branches and tags, so fetch
        # the SHA explicitly (GitHub serves any reachable commit by SHA).
        git clone --depth 1 --filter=blob:none --sparse --no-checkout "$repo" "$dest" 2>/dev/null || return 1
        (cd "$dest" \
            && git sparse-checkout set "$path" 2>/dev/null \
            && git fetch --depth 1 origin "$ref" 2>/dev/null \
            && git checkout -q "$ref" 2>/dev/null) || return 1
    else
        git clone --depth 1 --filter=blob:none --sparse --branch "$ref" "$repo" "$dest" 2>/dev/null || return 1
        (cd "$dest" && git sparse-checkout set "$path" 2>/dev/null) || return 1
    fi

    # Verify the path was actually checked out
    if [ ! -d "$dest/$path" ]; then
        return 1
    fi
    UPSTREAM_SHA="$(git -C "$dest" rev-parse HEAD 2>/dev/null)"
    return 0
}

# ---------------------
# Lock file: "<name> <sha> <date>" per line
# ---------------------
lock_get() {
    local name="$1"
    [ -f "$LOCK_FILE" ] || return 0
    awk -v n="$name" '$1 == n { print $2; exit }' "$LOCK_FILE"
}

lock_set() {
    local name="$1"
    local sha="$2"
    local today
    today="$(date +%Y-%m-%d)"
    local tmp
    tmp="$(mktemp)"
    if [ -f "$LOCK_FILE" ]; then
        grep -v -E "^${name}[[:space:]]" "$LOCK_FILE" > "$tmp" || true
    fi
    printf '%s %s %s\n' "$name" "$sha" "$today" >> "$tmp"
    sort "$tmp" > "$LOCK_FILE"
    rm -f "$tmp"
}

# ---------------------
# Diff display
# ---------------------

# Files to compare, sorted. Python bytecode left behind by running a
# skill's scripts is git-ignored and must not count as a local change.
list_files() {
    find "$1" -type f -not -path '*/__pycache__/*' -not -name '*.pyc' | sort
}

show_diff() {
    local local_dir="$1"
    local upstream_dir="$2"
    local has_changes=false

    # Files only in upstream (new)
    local added=()
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        added+=("$f")
        has_changes=true
    done < <(diff -rq "$upstream_dir" "$local_dir" 2>/dev/null | grep "^Only in ${upstream_dir}" | sed "s|^Only in ${upstream_dir}[/]*: *||" || true)

    # For better output, use a find-based approach
    added=()
    if [ -d "$upstream_dir" ]; then
        while IFS= read -r f; do
            local rel="${f#$upstream_dir/}"
            if [ ! -e "$local_dir/$rel" ]; then
                added+=("$rel")
                has_changes=true
            fi
        done < <(list_files "$upstream_dir")
    fi

    # Files only in local (will be removed)
    local removed=()
    if [ -d "$local_dir" ]; then
        while IFS= read -r f; do
            local rel="${f#$local_dir/}"
            if [ ! -e "$upstream_dir/$rel" ]; then
                removed+=("$rel")
                has_changes=true
            fi
        done < <(list_files "$local_dir")
    fi

    # Files that differ
    local modified=()
    if [ -d "$upstream_dir" ] && [ -d "$local_dir" ]; then
        while IFS= read -r f; do
            local rel="${f#$upstream_dir/}"
            if [ -f "$local_dir/$rel" ] && ! diff -q "$f" "$local_dir/$rel" >/dev/null 2>&1; then
                modified+=("$rel")
                has_changes=true
            fi
        done < <(list_files "$upstream_dir")
    fi

    # Display
    if [ "$has_changes" = false ]; then
        if [ ! -d "$local_dir" ]; then
            echo "  (new skill - all files will be added)"
            return 0
        fi
        echo "  Already up to date."
        return 1
    fi

    if [ ${#added[@]} -gt 0 ]; then
        echo -e "  ${GREEN}New files from upstream:${NC}"
        for f in "${added[@]}"; do
            echo -e "    ${GREEN}+ $f${NC}"
        done
    fi

    if [ ${#removed[@]} -gt 0 ]; then
        echo -e "  ${RED}Local-only files (will be removed):${NC}"
        for f in "${removed[@]}"; do
            echo -e "    ${RED}- $f${NC}"
        done
    fi

    if [ ${#modified[@]} -gt 0 ]; then
        echo -e "  ${YELLOW}Modified files:${NC}"
        for f in "${modified[@]}"; do
            echo -e "    ${YELLOW}~ $f${NC}"
        done
    fi

    return 0
}

# ---------------------
# Replace skill directory
# ---------------------
replace_skill() {
    local local_dir="$1"
    local upstream_dir="$2"

    # Remove existing
    if [ -d "$local_dir" ]; then
        rm -rf "$local_dir"
    fi

    # Copy upstream
    cp -r "$upstream_dir" "$local_dir"
}

# ---------------------
# Sync one skill
# ---------------------
sync_skill() {
    local name="$1"
    local repo="$2"
    local path="$3"
    local branch="$4"

    local local_dir="$SKILLS_DIR/$name"

    print_header "$name"
    print_info "Source: $repo @ $path ($branch)"
    # $branch is the conf ref: a branch, a tag, or a full commit SHA (pinned).

    # Sparse checkout to temp dir
    local tmpdir
    tmpdir="$(mktemp -d)"
    trap "rm -rf '$tmpdir'" RETURN

    print_info "Fetching from upstream..."
    if ! sparse_checkout "$repo" "$path" "$branch" "$tmpdir"; then
        print_error "Failed to fetch '$path' from $repo ($branch)"
        print_error "Check that the repository URL and path are correct."
        rm -rf "$tmpdir"
        trap - RETURN
        return 1
    fi

    local upstream_dir="$tmpdir/$path"

    local locked_sha
    locked_sha="$(lock_get "$name")"
    if [ -n "$locked_sha" ]; then
        print_info "Locked: ${locked_sha:0:12}  Upstream: ${UPSTREAM_SHA:0:12}"
    else
        print_info "Locked: (none)  Upstream: ${UPSTREAM_SHA:0:12}"
    fi

    # Show diff
    echo ""
    if ! show_diff "$local_dir" "$upstream_dir"; then
        # Vendored files already equal this upstream commit, so the lock
        # can be brought up to date without touching the skill.
        if [ "$DRY_RUN" = false ] && [ "$locked_sha" != "$UPSTREAM_SHA" ]; then
            lock_set "$name" "$UPSTREAM_SHA"
            print_info "Lock updated to ${UPSTREAM_SHA:0:12}."
        fi
        rm -rf "$tmpdir"
        trap - RETURN
        return 0
    fi
    echo ""

    # Dry-run: stop here
    if [ "$DRY_RUN" = true ]; then
        print_info "(dry-run) No changes applied."
        rm -rf "$tmpdir"
        trap - RETURN
        return 0
    fi

    # Confirm
    # `set -e` is active: a bare `read` returning 1 at EOF (piped stdin,
    # </dev/null, CI) would abort the whole sync with no message.
    if ! read -p "Apply changes to $name? [y/N] " -r answer; then
        answer="n"
        echo ""
    fi
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        print_warning "Skipped."
        rm -rf "$tmpdir"
        trap - RETURN
        return 0
    fi

    # Replace
    replace_skill "$local_dir" "$upstream_dir"
    lock_set "$name" "$UPSTREAM_SHA"
    print_success "$name synced successfully (upstream ${UPSTREAM_SHA:0:12})."

    rm -rf "$tmpdir"
    trap - RETURN
    return 0
}

# ---------------------
# Main
# ---------------------
main() {
    if [ "$DRY_RUN" = true ]; then
        print_info "Dry-run mode: no changes will be applied."
    fi

    parse_config

    if [ ${#SKILL_NAMES[@]} -eq 0 ]; then
        print_error "No skills defined in $CONFIG_FILE"
        exit 1
    fi

    # Validate target skill exists in config
    if [ -n "$TARGET_SKILL" ]; then
        local found=false
        for name in "${SKILL_NAMES[@]}"; do
            if [ "$name" = "$TARGET_SKILL" ]; then
                found=true
                break
            fi
        done
        if [ "$found" = false ]; then
            print_error "Skill '$TARGET_SKILL' not found in $CONFIG_FILE"
            print_info "Available skills: ${SKILL_NAMES[*]}"
            exit 1
        fi
    fi

    # Sync
    local synced=0
    local failed=0
    local total=${#SKILL_NAMES[@]}

    for i in "${!SKILL_NAMES[@]}"; do
        local name="${SKILL_NAMES[$i]}"

        # Filter by target
        if [ -n "$TARGET_SKILL" ] && [ "$name" != "$TARGET_SKILL" ]; then
            continue
        fi

        if sync_skill "$name" "${SKILL_REPOS[$i]}" "${SKILL_PATHS[$i]}" "${SKILL_BRANCHES[$i]}"; then
            synced=$((synced + 1))
        else
            failed=$((failed + 1))
        fi
    done

    # Summary
    echo ""
    echo -e "${BOLD}--- Summary ---${NC}"
    if [ -n "$TARGET_SKILL" ]; then
        total=1
    fi
    print_info "Total: $total, Processed: $synced, Failed: $failed"
}

main
