#!/bin/bash
# List the acceptance criteria of a requirements.md (templates/specs/requirements.md format) as `N.M<TAB>text`,
# or check that every criterion ID appears in an audit result. Generic — configure by arguments, do not edit.
#
#   list_criteria.sh <requirements.md>                          # print `N.M<TAB>text` per criterion (stdout)
#   list_criteria.sh --check <requirements.md> <audit.md>       # MISSING: <ID> (stderr, exit 1) / OK: <n> criteria covered (exit 0)
#                                                               #   UNKNOWN: <ID> for IDs in the audit but not in the requirements (warning only)
#   exit 2: bad arguments or missing file
set -u

usage() { sed -n 2,8p "$0" >&2; exit 2; }

# Requirement heading: `### Requirement N: ...`, `### N. ...`, `### N ...` (numeric IDs only; `Requirement A` is not picked).
# Criteria: `M. text` under `#### Acceptance Criteria`. Scanning stops at the first `## ` heading after a requirement heading.
list_criteria() {
    awk '
        /^## / { if (seen) exit; next }
        /^### / {
            n = ""; inac = 0; h = $0
            sub(/^###[[:space:]]+/, "", h); sub(/^Requirement[[:space:]]+/, "", h)
            if (match(h, /^[0-9]+/)) { id = substr(h, 1, RLENGTH); rest = substr(h, RLENGTH + 1)
                if (rest == "" || rest ~ /^[:.[:space:]]/) { n = id; seen = 1 } }
            next
        }
        /^#### / { inac = ($0 ~ /^####[[:space:]]+Acceptance Criteria[[:space:]]*$/); next }
        inac && n != "" && match($0, /^[0-9]+\.[[:space:]]+/) {
            l = RLENGTH; m = $0; sub(/\..*/, "", m)
            printf "%s.%s\t%s\n", n, m, substr($0, l + 1)
        }
    ' "$1"
}

# An ID counts as present when it starts a line or follows `| `, and is not followed by a digit or `.digit` (1.1 ≠ 1.10, 11.1).
id_pattern() { printf '(^|\\| )%s([^0-9.]|\\.[^0-9]|\\.$|$)' "$(printf '%s' "$1" | sed 's/\./\\./g')"; }

case "${1:-}" in
    -h|--help) sed -n 2,8p "$0"; exit 0 ;;
    --check)
        [ $# -eq 3 ] || usage
        REQ="$2"; AUDIT="$3"
        { [ -f "$REQ" ] && [ -f "$AUDIT" ]; } || { echo "no such file: $([ -f "$REQ" ] && echo "$AUDIT" || echo "$REQ")" >&2; usage; }
        IDS=$(list_criteria "$REQ" | cut -f1)
        [ -n "$IDS" ] || { echo "no acceptance criteria found in $REQ" >&2; exit 1; }
        MISSING=0; TOTAL=0
        for id in $IDS; do
            TOTAL=$((TOTAL + 1))
            grep -qE "$(id_pattern "$id")" "$AUDIT" || { echo "MISSING: $id" >&2; MISSING=$((MISSING + 1)); }
        done
        for id in $(grep -oE '(^|\| )[0-9]+\.[0-9]+' "$AUDIT" | sed -E 's/^\| //' | sort -u -t. -k1,1n -k2,2n); do
            echo "$IDS" | grep -qx "$id" || echo "UNKNOWN: $id" >&2
        done
        [ $MISSING -eq 0 ] || exit 1
        echo "OK: $TOTAL criteria covered"; exit 0 ;;
    *)
        [ $# -eq 1 ] || usage
        [ -f "$1" ] || { echo "no such file: $1" >&2; usage; }
        list_criteria "$1" ;;
esac
