#!/bin/bash
# Canon layer machine checks (rules: docs/settings/rules/canon-layer.md §Checks). Report-only:
# the exit code is the finding count, not a stop signal. Generic — configure by arguments, do not edit.
#
#   check_canon.sh [--root <canon-root>] check              # (a) registry-ID resolution (b) link liveness (c) keywords line (d) enumerations outside registry
#   check_canon.sh [--root <canon-root>] used-by [--write]  # verify `Used by` entries, classify IDs, suggest doc-side refs (--write appends spec:/plan: only)
#   check_canon.sh commit-scope                              # pre-commit helper: exit 2 when staged canon files are bundled with other files
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || exit 1

ROOT=""; CMD=""; WRITE=0
while [ $# -gt 0 ]; do case "$1" in
    --root) ROOT="$2"; shift 2 ;; --write) WRITE=1; shift ;;
    check|used-by|commit-scope) CMD="$1"; shift ;; -h|--help) sed -n 2,8p "$0"; exit 0 ;; *) echo "unknown arg: $1" >&2; exit 1 ;;
esac; done
[ -z "$CMD" ] && { sed -n 2,8p "$0"; exit 1; }
if [ -z "$ROOT" ]; then
    ROOT=$(grep -m1 -oE 'Canon root:[[:space:]]*`?[^` ]+' docs/steering/product.md 2>/dev/null | sed -E 's/Canon root:[[:space:]]*`?//; s#/$##')
    [ -z "$ROOT" ] && ROOT="docs/canon"
fi
REG="$ROOT/registry.md"; DEC="$ROOT/decisions"; FINDINGS=0
report() { FINDINGS=$((FINDINGS + 1)); echo "$1"; }
# grep over the repo excluding seats where an ID is a citation, not a usage
EXCL=(--exclude-dir=.git --exclude-dir=.claude --exclude-dir=.agents --exclude-dir=node_modules --exclude-dir=probe --exclude-dir=settings --exclude-dir=archive)
registry_ids() { grep -oE '^\| *[A-Z][A-Z0-9]+-[0-9]+ *\|' "$REG" 2>/dev/null | tr -d '| '; }
domains() { registry_ids | sed -E 's/-[0-9]+$//' | sort -u | tr '\n' '|' | sed 's/|$//'; }

# ---------- commit-scope ----------
if [ "$CMD" = "commit-scope" ]; then
    staged=$(git diff --cached --name-only)
    canon=$(echo "$staged" | grep -E "^$ROOT/" || true); other=$(echo "$staged" | grep -vE "^$ROOT/" || true)
    if [ -n "$canon" ] && [ -n "$other" ]; then echo "canon files are staged together with non-canon files — commit canon as its own docs(canon): commit"; echo "$other" | sed 's/^/  /'; exit 2; fi
    exit 0
fi
[ -f "$REG" ] || { echo "no registry at $REG (canon root: $ROOT)"; exit 0; }

# ---------- check ----------
if [ "$CMD" = "check" ]; then
    OUT=$(mktemp); DOM=$(domains)
    if [ -n "$DOM" ]; then                                                                   # (a) referenced IDs must exist in the registry
        known=$(registry_ids | sort -u)
        grep -rnowE "($DOM)-[0-9]+" . "${EXCL[@]}" 2>/dev/null | sed 's#^\./##' | while IFS=: read -r f l id; do
            echo "$known" | grep -qx "$id" || echo "$f:$l: (a) unknown registry ID $id"
        done >> "$OUT"
    fi
    grep -rnoE '\]\(([^)#: ]+)(#[^)]*)?\)' "$ROOT" --include='*.md' 2>/dev/null | grep -v '/archive/' | while IFS=: read -r f l m; do   # (b) relative links resolve
        t=$(echo "$m" | sed -E 's/^\]\(//; s/\)$//; s/#.*$//'); case "$t" in http*|mailto*|"") continue ;; esac
        [ -e "$(dirname "$f")/$t" ] || echo "$f:$l: (b) broken link $t"
    done >> "$OUT"
    for f in "$DEC"/*.md; do [ -f "$f" ] || continue                                        # (c) keywords line  (d) enumerations
        grep -qE '^- \*\*keywords\*\*:' "$f" || echo "$f:1: (c) missing keywords line" >> "$OUT"
        awk -v F="$f" '/^\|/{t++; if(t==7) print F":"NR": (d) table with 5+ rows — enumeration outside the registry?"} !/^\|/{t=0}
                        /^[0-9]+\. /{n++; if(n==5) print F":"NR": (d) list with 5+ items — enumeration outside the registry?"} !/^[0-9]+\. /{n=0}' "$f" >> "$OUT"
    done
    cat "$OUT"; FINDINGS=$(wc -l < "$OUT" | tr -d ' '); rm -f "$OUT"
    echo "check: $FINDINGS finding(s)"; exit "$FINDINGS"
fi

# ---------- used-by ----------
if [ "$CMD" = "used-by" ]; then
    DOM=$(domains); tmp=$(mktemp); PH=$(printf '\001'); printf 'ID | implemented | planned | unresolved\n'
    while IFS= read -r raw; do
        case "$raw" in \|*) ;; *) echo "$raw" >> "$tmp"; continue ;; esac
        line=$(printf '%s' "$raw" | sed "s/\\\\|/$PH/g")                                       # protect escaped pipes in Norm text
        id=$(echo "$line" | awk -F'|' '{gsub(/ /,"",$2); print $2}')
        nf=$(echo "$line" | awk -F'|' '{print NF}')
        if ! echo "$id" | grep -qE "^[A-Z][A-Z0-9]+-[0-9]+$"; then echo "$raw" >> "$tmp"; continue; fi
        if [ "$nf" -ne 6 ]; then report "$REG: $id: row has $((nf-2)) columns, expected 4 — skipped"; echo "$raw" >> "$tmp"; continue; fi
        cell=$(echo "$line" | awk -F'|' '{print $5}' | sed -E 's/^ +| +$//g'); impl=0; plan=0; unres=""
        for tok in $(echo "$cell" | grep -oE '(code|spec|plan): *[^ ]+' | sed 's/: */:/'); do
            v=${tok#*:}; case "$tok" in
              code:*) [ -e "${v%% *}" ] && impl=$((impl+1)) || unres="$unres $tok" ;;
              spec:*) if [ -d "docs/tasks/done/$v" ]; then impl=$((impl+1)); elif [ -d "docs/tasks/todo/$v" ]; then plan=$((plan+1)); else unres="$unres $tok"; fi ;;
              plan:*) [ -f "docs/inception/${v%%/*}/inception.json" ] && plan=$((plan+1)) || unres="$unres $tok" ;;
            esac
        done
        add=""                                                                                # doc-side references not yet in the cell
        # a spec binds itself to a norm in requirements/design/behaviors; probe, research and tasks are process records and do not make it a consumer
        for d in $({ grep -rlw --include=requirements.md --include=design.md --include=behaviors.md "$id" docs/tasks; grep -rlw "$id" docs/inception; } 2>/dev/null | sed -E 's#^docs/tasks/(todo|done)/([^/]+)/.*#spec:\2#; s#^docs/inception/([^/]+)/.*#plan:\1#' | sort -u); do
            echo "$cell" | grep -q "${d%%:*}: *${d#*:}" || add="$add $d"
        done
        [ -n "$add" ] && echo "$id: suggest adding$(echo "$add" | sed 's/:/: /g') to Used by"
        printf '%s | %s | %s |%s\n' "$id" "$impl" "$plan" "${unres:- —}"
        if [ $WRITE -eq 1 ] && [ -n "$add" ]; then
            new=$(echo "$cell $(echo "$add" | sed 's/:/: /g')" | sed -E 's/^— //; s/  +/ /g; s/^ +| +$//g')
            echo "$line" | awk -F'|' -v OFS='|' -v c=" $new " '{$5=c; print}' | sed "s/$PH/\\\\|/g" >> "$tmp"
        else echo "$raw" >> "$tmp"; fi
    done < "$REG"
    if [ $WRITE -eq 1 ]; then mv "$tmp" "$REG"; echo "used-by: registry updated"; else rm -f "$tmp"; fi
    exit $FINDINGS
fi
