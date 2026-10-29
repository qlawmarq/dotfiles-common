#!/bin/bash
# List the acceptance criteria of a requirements.md (templates/specs/requirements.md format) as `N.M<TAB>text`.
# Generic — configure by arguments, do not edit.
#
#   list_criteria.sh <requirements.md>                          # print `N.M<TAB>text` per criterion (stdout)
#   exit 2: bad arguments or missing file
set -u

usage() { sed -n 2,6p "$0" >&2; exit 2; }

# Forms read: docs/settings/rules/ears-format.md §Requirement IDs.
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

case "${1:-}" in
    -h|--help) sed -n 2,6p "$0"; exit 0 ;;
    *)
        [ $# -eq 1 ] || usage
        [ -f "$1" ] || { echo "no such file: $1" >&2; usage; }
        list_criteria "$1" ;;
esac
