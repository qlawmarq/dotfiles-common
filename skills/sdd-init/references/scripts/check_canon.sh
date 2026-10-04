#!/bin/bash
# Canon layer machine checks (rules: docs/settings/rules/canon-layer.md §Checks). Report-only:
# the exit code is the finding count (at most 255), not a stop signal. Generic — configure by arguments, do not edit.
#
#   check_canon.sh [--root <canon-root>] check              # (a) registry-ID resolution (b) link liveness (c) keywords line (d) enumerations outside registry
#                                                            #   (e) banned terms from the TERM domain (f) canonical terms missing from every keywords line
#   check_canon.sh [--root <canon-root>] used-by            # verify `Used by` entries, classify IDs, suggest doc-side refs
#   check_canon.sh commit-scope                              # pre-commit helper: exit 2 when staged canon files are bundled with other files
#   check_canon.sh [--root <canon-root>] terms-prh           # emit the TERM vocabulary as a prh rule file (stdout) for optional textlint integration
set -u

ROOT=""; CMD=""
usage() { sed -n 2,9p "$0"; }
while [ $# -gt 0 ]; do case "$1" in
    --root) [ $# -ge 2 ] || { echo "--root needs a value" >&2; usage >&2; exit 1; }; ROOT="$2"; shift 2 ;;
    check|used-by|commit-scope|terms-prh) CMD="$1"; shift ;; -h|--help) usage; exit 0 ;; *) echo "unknown arg: $1" >&2; exit 1 ;;
esac; done
[ -z "$CMD" ] && { usage; exit 1; }
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || exit 1
if [ -z "$ROOT" ]; then
    ROOT=$(grep -m1 -oE 'Canon root:[[:space:]]*`?[^` ]+' docs/steering/product.md 2>/dev/null | sed -E 's/Canon root:[[:space:]]*`?//; /^\[/d; s#/$##')
    [ -z "$ROOT" ] && ROOT="docs/canon"
fi
REG="$ROOT/registry.md"; DEC="$ROOT/decisions"; FINDINGS=0
report() { FINDINGS=$((FINDINGS + 1)); echo "$1"; }
# grep over the repo excluding seats where an ID is a citation, not a usage
EXCL=(--exclude-dir=.git --exclude-dir=.claude --exclude-dir=.agents --exclude-dir=node_modules --exclude-dir=probe --exclude-dir=settings --exclude-dir=archive)
registry_ids() { grep -oE '^\| *[A-Z][A-Z0-9]+-[0-9]+ *\|' "$REG" 2>/dev/null | tr -d '| '; }
term_rows() { grep -E '^\| *TERM-[0-9]+ *\|' "$REG" 2>/dev/null; }
term_norm() { printf '%s' "$1" | awk -F'|' '{print $3}'; }
term_canonical() { printf '%s' "$1" | sed -nE 's/^[^*]*\*\*([^*]+)\*\*.*/\1/p'; }
term_banned() { printf '%s' "$1" | sed -nE 's/.*(禁止＝|banned=)//p' | tr '、，' ',,' | tr ',' '\n' | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | grep -v '^$'; }
domains() { registry_ids | sed -E 's/-[0-9]+$//' | sort -u | tr '\n' '|' | sed 's/|$//'; }

# ---------- commit-scope ----------
if [ "$CMD" = "commit-scope" ]; then
    staged=$(git diff --cached --name-only)
    canon=$(echo "$staged" | grep -E "^$ROOT/" || true); other=$(echo "$staged" | grep -vE "^$ROOT/" || true)
    if [ -n "$canon" ] && [ -n "$other" ]; then echo "canon files are staged together with non-canon files — commit canon as its own docs(canon): commit"; echo "$other" | sed 's/^/  /'; exit 2; fi
    exit 0
fi
[ -f "$REG" ] || { echo "no registry at $REG (canon root: $ROOT)"; exit 0; }

# ---------- terms-prh ----------
if [ "$CMD" = "terms-prh" ]; then
    echo "version: 1"; echo "rules:"
    term_rows | while IFS= read -r row; do
        norm=$(term_norm "$row"); cterm=$(term_canonical "$norm")
        [ -n "$cterm" ] || continue
        b=$(term_banned "$norm"); [ -n "$b" ] || continue
        echo "  - expected: $cterm"; echo "    patterns:"
        printf '%s\n' "$b" | while IFS= read -r t; do echo "      - $t"; done
    done
    exit 0
fi

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
    term_rows | while IFS= read -r row; do                                                  # (e) banned terms  (f) keywords coverage of canonical terms
        norm=$(term_norm "$row"); cterm=$(term_canonical "$norm")
        term_banned "$norm" | while IFS= read -r t; do
            for d in "$ROOT" docs/steering docs/inception docs/tasks/todo; do
                [ -d "$d" ] || continue
                grep -rnF --include='*.md' -- "$t" "$d" 2>/dev/null
            done | grep -v '/archive/' | grep -vF "$REG:" | cut -d: -f1,2 | sed -E "s|$|: (e) banned term '$t' → use '$cterm'|"
        done
        if [ -n "$cterm" ]; then
            grep -hE '^- \*\*keywords\*\*:' "$DEC"/*.md 2>/dev/null | grep -qF -- "$cterm" \
                || echo "$REG:1: (f) canonical term '$cterm' appears in no decision keywords line"
        fi
    done >> "$OUT"
    cat "$OUT"; FINDINGS=$(wc -l < "$OUT" | tr -d ' '); rm -f "$OUT"
    echo "check: $FINDINGS finding(s)"; [ "$FINDINGS" -gt 255 ] && exit 255; exit "$FINDINGS"
fi

# ---------- used-by ----------
if [ "$CMD" = "used-by" ]; then
    PH=$(printf '\001'); printf 'ID | implemented | planned | unresolved\n'
    while IFS= read -r raw; do
        case "$raw" in \|*) ;; *) continue ;; esac
        line=$(printf '%s' "$raw" | sed "s/\\\\|/$PH/g")                                       # protect escaped pipes in Norm text
        id=$(echo "$line" | awk -F'|' '{gsub(/ /,"",$2); print $2}')
        nf=$(echo "$line" | awk -F'|' '{print NF}')
        echo "$id" | grep -qE "^[A-Z][A-Z0-9]+-[0-9]+$" || continue
        if [ "$nf" -ne 6 ]; then report "$REG: $id: row has $((nf-2)) columns, expected 4 — skipped"; continue; fi
        cell=$(echo "$line" | awk -F'|' '{print $5}' | sed -E 's/^ +| +$//g'); impl=0; plan=0; unres=""
        for tok in $(echo "$cell" | grep -oE '(code|spec|plan): *[^ ]+' | sed 's/: */:/'); do
            v=${tok#*:}; case "$tok" in
              code:*) [ -e "${v%% *}" ] && impl=$((impl+1)) || unres="$unres $tok" ;;
              spec:*) if [ -d "docs/tasks/done/$v" ]; then impl=$((impl+1)); elif [ -d "docs/tasks/todo/$v" ]; then plan=$((plan+1)); else unres="$unres $tok"; fi ;;
              plan:*) [ -f "docs/inception/${v%%/*}/units.md" ] && plan=$((plan+1)) || unres="$unres $tok" ;;
            esac
        done
        add=""                                                                                # doc-side references not yet in the cell
        # a spec binds itself to a norm in requirements/design/behaviors; probe, research and tasks are process records and do not make it a consumer
        for d in $({ grep -rlw --include=requirements.md --include=design.md --include=behaviors.md "$id" docs/tasks; grep -rlw "$id" docs/inception; } 2>/dev/null | sed -E 's#^docs/tasks/(todo|done)/([^/]+)/.*#spec:\2#; s#^docs/inception/([^/]+)/.*#plan:\1#' | sort -u); do
            echo "$cell" | grep -q "${d%%:*}: *${d#*:}" || add="$add $d"
        done
        [ -n "$add" ] && echo "$id: suggest adding$(echo "$add" | sed 's/:/: /g') to Used by"
        printf '%s | %s | %s |%s\n' "$id" "$impl" "$plan" "${unres:- —}"
    done < "$REG"
    [ "$FINDINGS" -gt 255 ] && exit 255; exit "$FINDINGS"
fi
