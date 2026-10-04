#!/bin/bash
# The shape a spec must have before completion: the reports its kind's completion checks require (spec-kinds.md §4
# `Completion checks`), a closure line for every finding (concept-alignment.md §Findings), and finished Verification lines
# (behavior-formulation.md §Verification Mapping). Form only — whether a closure is right is not checked here.
# Generic — configure by arguments, do not edit.
#
#   check_completion.sh [--rules <dir>] <spec_path>   # FAIL: <file>: <what> per failure; NOT RUN: <scenario> per user scenario
#                                                     #   without its record (not a failure); exit 1 on any failure, else 0
#   check_completion.sh outstanding                   # user scenarios under docs/tasks/ whose record is missing, todo and done apart (exit 0)
#   the forms checked — a routing line, a closure on an earlier answer, the headings of probe/user-run-<x>.md — are those
#   /sdd-spec-done writes (its SKILL.md: Routing record, 2k Routing, Recording the answer)
#   --rules <dir>: where spec-kinds.md and behavior-formulation.md are read (default: docs/settings/rules)
#   exit 2: bad arguments, no spec.json, or a rule table that cannot be read
set -u

usage() { sed -n 2,13p "$0"; }
RULES=""; ARG=""
while [ $# -gt 0 ]; do case "$1" in
    --rules) [ $# -ge 2 ] || { usage >&2; exit 2; }; RULES="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "unknown arg: $1" >&2; exit 2 ;;
    *) [ -z "$ARG" ] || { usage >&2; exit 2; }; ARG="$1"; shift ;;
esac; done
[ -n "$ARG" ] || { usage >&2; exit 2; }
if [ -n "$RULES" ]; then RULES=$(cd "$RULES" 2>/dev/null && pwd -P) || { echo "no such directory: --rules" >&2; exit 2; }; fi

# Markdown lines as `NR<TAB>text`, with HTML comments and fenced blocks blanked (template comments are not content);
# `content <file> fenced` keeps the lines inside a fenced block (a report may fence its lines)
content() { LC_ALL=C awk -v KF="${2:-}" '{ l = $0; out = ""
        if (!inc && l ~ /^[ \t]*(```|~~~)/) { inf = !inf; print NR "\t"; next }
        if (inf && KF != "fenced") { print NR "\t"; next }
        while (1) { if (inc) { i = index(l, "-->"); if (!i) break; l = substr(l, i + 3); inc = 0 }
            i = index(l, "<!--"); if (!i) { out = out l; break }
            out = out substr(l, 1, i - 1); l = substr(l, i + 4); inc = 1 }
        print NR "\t" out }' "$1"; }

US=$(printf '\037')                                        # field separator of the records below (fields may be empty)
# Verification lines of a behaviors.md as `NR US scenario number US tier US pointer`; both the rule's
# `Verification: <tier> — <pointer>` and the template's `- **Verification:** <tier> — <pointer>`
verification_lines() { content "$1" | LC_ALL=C awk -F'\t' '
    $2 ~ /^#+[ \t]/ { h = $2; sub(/^#+[ \t]+/, "", h); sc = ""
        if (match(h, /^Scenario[ \t]+[0-9]+/)) { sc = substr(h, 1, RLENGTH); sub(/^Scenario[ \t]+/, "", sc) } next }
    $2 ~ /^[ \t]*([-*][ \t]+)?(\*\*)?Verification(\*\*)?:/ { r = $2
        sub(/^[ \t]*([-*][ \t]+)?(\*\*)?Verification(\*\*)?:(\*\*)?[ \t]*/, "", r)
        t = r; sub(/[ \t].*$/, "", t); gsub(/`/, "", t); sub(/—.*$/, "", t)
        p = substr(r, index(r, t) + length(t)); sub(/^`?[ \t]*(—|-|:)?[ \t]*/, "", p)
        print $1 "\037" sc "\037" t "\037" p }'; }

# Backticked tokens of a string, one per line
ticks() { printf '%s\n' "$1" | grep -oE '`[^`]+`' | tr -d '`'; }
# A token names a file: it has a directory part, or ends in a short extension (a dotted test name like Suite.test_x does not)
is_path() { case "$1" in *" "*) return 1 ;; */*) return 0 ;; esac; printf '%s' "$1" | grep -qE '^[^.]+(\.[^.]+)*\.[A-Za-z][A-Za-z0-9]{0,4}$'; }
# A path token without its line / anchor / test-id suffix
bare_path() { printf '%s' "$1" | sed -E 's/::.*$//; s/#.*$//; s/:[0-9]+(-[0-9]+)?$//; s#^\./##'; }

# ---------- outstanding ----------
if [ "$ARG" = outstanding ]; then
    cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || exit 2
    total=0
    for state in todo done; do
        echo "$state:"; n=0
        for b in docs/tasks/$state/*/behaviors.md; do [ -f "$b" ] || continue
            d=${b%/behaviors.md}
            while IFS="$US" read -r ln sc tier ptr; do
                [ "$tier" = user ] || continue
                [ -n "$sc" ] && [ -f "$d/probe/user-S$sc.md" ] && continue
                echo "  $d S${sc:-?} — probe/user-S${sc:-?}.md ($b:$ln)"; n=$((n + 1))
            done < <(verification_lines "$b")
        done
        [ $n -eq 0 ] && echo "  (none)"; total=$((total + n))
    done
    echo "outstanding: $total user scenario(s) not run"
    exit 0
fi

# ---------- <spec_path> ----------
SPEC=$(cd "$ARG" 2>/dev/null && pwd -P) || { echo "no such directory: $ARG" >&2; exit 2; }
[ -f "$SPEC/spec.json" ] || { echo "no spec.json in $ARG" >&2; exit 2; }
ROOT=$(cd "$SPEC" && git rev-parse --show-toplevel 2>/dev/null) || ROOT=$(pwd -P)
ROOT=$(cd "$ROOT" && pwd -P); cd "$ROOT" || exit 2
case "$SPEC/" in "$ROOT"/*) SP=${SPEC#"$ROOT"/} ;; *) SP=$SPEC ;; esac
[ -n "$RULES" ] || RULES="$ROOT/docs/settings/rules"
KINDS="$RULES/spec-kinds.md"; BF="$RULES/behavior-formulation.md"
for f in "$KINDS" "$BF"; do [ -f "$f" ] || { echo "no rule file: $f (pass --rules)" >&2; exit 2; }; done

FAILS=0; NOTRUN=0
fail() { FAILS=$((FAILS + 1)); echo "FAIL: $*"; }

# 1. the kind and its completion checks (spec-kinds.md §4, column `Completion checks`)
KIND=$(grep -m1 -oE '"kind"[[:space:]]*:[[:space:]]*"[^"]*"' "$SPEC/spec.json" | sed -E 's/.*"([^"]*)"$/\1/')
[ -n "$KIND" ] || KIND=feature
CHK=$(LC_ALL=C awk -F'|' -v K="$KIND" '
    function tr(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    !/^\|/ { col = 0; next }
    col == 0 { for (i = 2; i < NF; i++) if (tr($i) == "Completion checks") { col = i; print "col" } next }
    { k = $2; gsub(/[ \t`]/, "", k); if (k != K) next
      print "row"; v = $col; while (match(v, /`[^`]+`/)) { print "chk " substr(v, RSTART + 1, RLENGTH - 2); v = substr(v, RSTART + RLENGTH) } exit }' "$KINDS")
echo "$CHK" | grep -qx col || { echo "no \`Completion checks\` column in $KINDS" >&2; exit 2; }
CHECKS=$(echo "$CHK" | sed -n 's/^chk //p' | tr '\n' ' ' | sed 's/ $//')
echo "$CHK" | grep -qx row || fail "$SP/spec.json: kind \`$KIND\` is not a row of spec-kinds.md §4"
for c in $CHECKS; do case "$c" in criteria-audit|product-check|verdict) ;; *) echo "unknown completion check \`$c\` in $KINDS" >&2; exit 2 ;; esac; done
has() { case " $CHECKS " in *" $1 "*) return 0 ;; esac; return 1; }

# run numbers present under reviews/
R="$SPEC/reviews"
RUNS=$(ls "$R" 2>/dev/null | sed -nE 's/^(criteria-audit|product-check|routing)-([0-9]+)\.md$/\2/p' | sort -un)
runs_of() { ls "$R" 2>/dev/null | sed -nE "s/^$1-([0-9]+)\\.md\$/\\1/p" | sort -n; }

# routing lines of routing-<n>.md as `NR US ID US closure US rest` (closure "" when the line has none)
routing() { [ -f "$R/routing-$1.md" ] || return 0; content "$R/routing-$1.md" | LC_ALL=C awk -F'\t' '
    { l = $2; sub(/^[ \t]*([-*][ \t]+)?/, "", l); gsub(/^\*\*|^`/, "", l)
      if (!match(l, /^(R[0-9]+-F[0-9]+|F[0-9]+|[0-9]+\.[0-9]+)/)) next
      id = substr(l, 1, RLENGTH); r = substr(l, RLENGTH + 1); sub(/^(\*\*|`)/, "", r)
      if (r != "" && r !~ /^[ \t]*—/) next
      c = ""; rest = ""; if (sub(/^[ \t]*—[ \t]*/, "", r)) { c = r; i = index(c, "—"); if (i) { rest = substr(c, i + 3); c = substr(c, 1, i - 1) } }
      gsub(/[ \t`*]/, "", c); print $1 "\037" id "\037" tolower(c) "\037" rest }'; }
has_route() { routing "$1" | cut -d"$US" -f2 | grep -qxF "$2"; }

# the latest re-check of <ID> in section F of a product check later than run <n>: "reproduced" | "not reproduced" | ""
recheck() { local m st
    for m in $(runs_of product-check | sort -rn); do [ "$m" -gt "$2" ] || continue
        st=$(content "$R/product-check-$m.md" | LC_ALL=C awk -F'\t' -v ID="$1" '
            $2 ~ /^#+[ \t]/ { lv = $2; sub(/[ \t].*/, "", lv); lv = length(lv)
                if (inf && lv <= fl) inf = 0
                h = $2; sub(/^#+[ \t]+/, "", h); if (h ~ /^F[.:)]/) { inf = 1; fl = lv } next }
            inf { l = $2; sub(/^[ \t]*([-*][ \t]+)?/, "", l); gsub(/`/, "", l)
                if (index(l, ID) != 1 || substr(l, length(ID) + 1) !~ /^[ \t]*—/) next
                s = substr(l, length(ID) + 1); sub(/^[ \t]*—[ \t]*/, "", s); i = index(s, "—"); if (i) s = substr(s, 1, i - 1)
                s = tolower(s); gsub(/^[ \t]+|[ \t]+$/, "", s); print s; exit }')
        [ -n "$st" ] && { echo "$st"; return; }
    done; }

# 2. criteria audit: every non-HOLDS ID of a coverage line has a routing line of the same run
if has criteria-audit; then
    [ -n "$(runs_of criteria-audit)" ] || fail "$SP/reviews/: no criteria-audit-<n>.md (kind \`$KIND\` requires criteria-audit)"
    for n in $(runs_of criteria-audit); do
        # coverage line: `ID | seat | verdict`, fenced or not (first such line per ID; the verdict is the leading word of the last |-field)
        cov=$(content "$R/criteria-audit-$n.md" fenced | LC_ALL=C awk -F'\t' '
            { l = $2; sub(/^[ \t]*([-*][ \t]+)?/, "", l); sub(/^\|/, "", l); sub(/\|[ \t]*$/, "", l)
              k = split(l, c, "|"); if (k < 3) next; id = c[1]; gsub(/[ \t`*]/, "", id)
              if (id !~ /^[0-9]+\.[0-9]+$/ || (id in seen)) next; seen[id] = 1
              v = c[k]; sub(/^[ \t`*]+/, "", v); v = match(v, /^[A-Za-z-]+/) ? substr(v, 1, RLENGTH) : v; print id "\t" toupper(v) }')
        [ -n "$cov" ] || fail "$SP/reviews/criteria-audit-$n.md: no coverage line (\`ID | seat | verdict\`)"
        for id in $(echo "$cov" | awk -F'\t' '$2 != "HOLDS" { print $1 }'); do
            has_route "$n" "$id" || fail "$SP/reviews/routing-$n.md: no line for audit ID $id ($(echo "$cov" | awk -F'\t' -v I="$id" '$1 == I { print $2 }'))"
        done
    done
fi

# 3. product check: a finding heading or `Findings: none`, and a routing line per finding
if has product-check; then
    [ -n "$(runs_of product-check)" ] || fail "$SP/reviews/: no product-check-<n>.md (kind \`$KIND\` requires product-check)"
    for n in $(runs_of product-check); do
        ids=$(content "$R/product-check-$n.md" | LC_ALL=C awk -F'\t' '
            match($2, /^#+[ \t]+F[0-9]+/) && substr($2, RLENGTH + 1, 1) !~ /[0-9]/ { h = substr($2, 1, RLENGTH); sub(/^#+[ \t]+/, "", h); print h }')
        none=$(content "$R/product-check-$n.md" | LC_ALL=C awk -F'\t' '{ l = tolower($2); gsub(/[`*]/, "", l); if (l ~ /^[ \t]*(- )?findings:[ \t]*none[ \t.]*$/) { print 1; exit } }')
        if [ -z "$ids" ] && [ -z "$none" ]; then fail "$SP/reviews/product-check-$n.md: neither a \`#### F<k>\` heading nor \`Findings: none\`"; continue; fi
        [ -n "$ids" ] && [ -n "$none" ] && fail "$SP/reviews/product-check-$n.md: both \`#### F<k>\` headings and \`Findings: none\`"
        for id in $ids; do has_route "$n" "$id" || fail "$SP/reviews/routing-$n.md: no line for product-check finding $id"; done
    done
fi

# 4. every routing line is closed; a product-check finding is closed by the user's answer, or changed and not reproduced later
for n in $(runs_of routing); do
    rf="$SP/reviews/routing-$n.md"
    while IFS="$US" read -r ln id c rest; do
        case "$c" in
            "") fail "$rf:$ln: $id has no closure (\`<ID> — open|changed|rejected|stands|filed — …\`)"; continue ;;
            open) fail "$rf:$ln: $id is still open"; continue ;;
            changed|rejected|stands|filed) ;;
            *) fail "$rf:$ln: $id: '$c' is not a closure (changed | rejected | stands | filed)"; continue ;;
        esac
        case "$id" in F*|R*) ;; *) continue ;; esac                                 # the rest applies to product-check findings
        if [ "$c" = changed ]; then
            case "$id" in R*) rid=$id ;; *) rid="R$n-$id" ;; esac
            st=$(recheck "$rid" "$n")
            if [ -z "$st" ]; then
                if [ -z "$(runs_of product-check | awk -v N="$n" '$1 > N')" ]; then fail "$rf:$ln: $id is changed in the last run — it needs a later product check's re-check, or the user's answer"
                else fail "$rf:$ln: $id is changed, but no later product check re-checks $rid (section F)"; fi
            elif [ "$st" != "not reproduced" ]; then fail "$rf:$ln: $id is changed, but the latest re-check of $rid says '$st'"; fi
        else
            uq=$(printf '%s' "$rest" | grep -oE '([A-Za-z0-9._-]+/)?probe/user-run-[0-9]+\.md' | head -1)
            ua=${uq:+probe/${uq##*probe/}}; os=${uq%probe/*}; os=${os%/}             # os: another spec's directory name, when the answer lies there
            ub=$SPEC; up=$SP
            case "$os" in ""|.|..|"${SPEC##*/}") os="" ;; *)
                ub=""; for st in todo done; do [ -d "${SPEC%/*/*}/$st/$os" ] && ub="${SPEC%/*/*}/$st/$os"; done
                up=${ub#"$ROOT"/} ;;
            esac
            # the finding answered: the bracketed `(R<m>-F<k>)` after the answer file when there is one (a finding raised again), else this line's
            ea=$(printf '%s' "$rest" | grep -oE 'probe/user-run-[0-9]+\.md[^(]*\([[:space:]]*R[0-9]+-F[0-9]+[[:space:]]*\)' | head -1 | grep -oE 'R[0-9]+-F[0-9]+')
            case "${ea:-$id}" in R*) fr=${ea:-$id}; fr=${fr%%-*}; fr=${fr#R}; fk=${ea:-$id}; fk=${fk#*-} ;; *) fr=$n; fk=$id ;; esac
            x=${ua#probe/user-run-}; x=${x%.md}
            if [ "$x" = "$fr" ]; then want=$fk; else want="R$fr-$fk"; fi              # run x heads its own findings F<k>, another run's R<m>-F<k>
            if [ -z "$ua" ]; then fail "$rf:$ln: $id is $c without pointing at the user's answer (probe/user-run-<n>.md)"
            elif [ -n "$os" ] && [ -z "$ub" ]; then fail "$rf:$ln: $id points at spec $os, which is not under docs/tasks/todo or done"
            elif [ -n "$os" ] && [ -z "$ea" ]; then fail "$rf:$ln: $id points at another spec's answer without the finding it answered there (\`$os/$ua (R<m>-F<k>)\`)"
            elif [ ! -f "$ub/$ua" ]; then fail "$rf:$ln: $id points at $up/$ua, which does not exist"
            elif ! LC_ALL=C grep -qE "^#+[[:space:]]+\`?$want\`?([^0-9A-Za-z-]|\$)" "$ub/$ua"; then fail "$rf:$ln: $up/$ua has no heading $want"; fi
        fi
    done < <(routing "$n")
done

# 5. verdict: every `### N` question of requirements.md has a verdict word (spec-kinds.md §6) on the `**Verdict:**` line of its `## Question N` in verdict.md
if has verdict; then
    words=$(LC_ALL=C awk '/^## / { s = ($0 ~ /^## 6[. ]/); next } s && match($0, /^- `[^`]+`/) { print substr($0, 4, RLENGTH - 4) }' "$KINDS")
    [ -n "$words" ] || { echo "no verdict vocabulary in $KINDS §6" >&2; exit 2; }
    if [ ! -f "$SPEC/verdict.md" ]; then fail "$SP/verdict.md does not exist (kind \`$KIND\` requires verdict)"
    elif [ ! -f "$SPEC/requirements.md" ]; then fail "$SP/requirements.md does not exist"
    else
        qs=$(content "$SPEC/requirements.md" | LC_ALL=C awk -F'\t' '
            $2 ~ /^## / { if (seen) exit; next }
            $2 ~ /^### / { h = $2; sub(/^###[ \t]+/, "", h); sub(/^(Requirement|Question)[ \t]+/, "", h)
                if (match(h, /^[0-9]+/) && substr(h, RLENGTH + 1, 1) !~ /[0-9]/) { print substr(h, 1, RLENGTH); seen = 1 } }')
        [ -n "$qs" ] || fail "$SP/requirements.md: no \`### N\` question"
        for q in $qs; do
            v=$(content "$SPEC/verdict.md" | LC_ALL=C awk -F'\t' -v Q="$q" '
                $2 ~ /^## / { h = $2; sub(/^##[ \t]+/, "", h); s = (match(h, /^Question[ \t]+[0-9]+/) && substr(h, RLENGTH + 1, 1) !~ /[0-9]/ && substr(h, 1, RLENGTH) ~ ("[ \t]" Q "$")); next }
                s && match($2, /\*\*Verdict:?\*\*:?/) { v = substr($2, RSTART + RLENGTH); gsub(/`/, "", v); gsub(/^[ \t]+|[ \t]+$/, "", v); print (v == "" ? "-" : v); exit }')
            if [ -z "$v" ]; then fail "$SP/verdict.md: §Question $q has no **Verdict:** line"
            elif ! echo "$words" | grep -qxF "$v"; then fail "$SP/verdict.md: §Question $q verdict '$v' is not one of: $(echo $words)"; fi
        done
    fi
fi

# 6. behaviors.md: tiers from the rule's table, no planned pointer, probe files under the spec, auto-test names found
if [ -f "$SPEC/behaviors.md" ]; then
    tiers=$(LC_ALL=C awk '/^## / { s = ($0 ~ /^## Verification Mapping/); r = 0; next }
        s && /^\|/ { if (r++ == 0 || $0 ~ /^\|[ \t:|-]+$/) next; split($0, c, "|"); t = c[2]; gsub(/[ \t`]/, "", t); if (t != "") print t }' "$BF")
    [ -n "$tiers" ] || { echo "no tier table in $BF §Verification Mapping" >&2; exit 2; }
    bf="$SP/behaviors.md"
    # a dotted test name (Suite.case) is looked up by its last element
    testkey() { case "$1" in *" "*) echo "$1" ;; *.*) echo "${1##*.}" ;; *) echo "$1" ;; esac; }
    # auto-test pointers are looked up among the repository's files outside docs/ (git: tracked and not ignored), names in one pass
    TMP=$(mktemp -d "${TMPDIR:-/tmp}/check_completion.XXXXXX") || exit 2; trap 'rm -rf "$TMP"' EXIT
    verification_lines "$SPEC/behaviors.md" | awk -F"$US" '$3 == "auto-test" { print $4 }' > "$TMP/ptrs"
    if [ -s "$TMP/ptrs" ]; then
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then git ls-files -co --exclude-standard
        else find . \( -path ./.git -o -path ./docs -o -name node_modules \) -prune -o -type f -print | sed 's#^\./##'; fi \
            | grep -v '^docs/' > "$TMP/files"
        tr '\n' '\0' < "$TMP/files" > "$TMP/files0"; sed -nE 's#.*/##; s#^[^.]+##; s#.*(\.[^.]+)$#\1#p' "$TMP/files" | sort -u > "$TMP/exts"
        while IFS= read -r p; do ticks "$p" | while IFS= read -r t; do is_path "$t" || [ "${t#*::}" != "$t" ] || testkey "$t"; done; done < "$TMP/ptrs" | sort -u > "$TMP/names"
        [ -s "$TMP/names" ] && xargs -0 grep -hoFw -f "$TMP/names" -- < "$TMP/files0" 2>/dev/null | sort -u > "$TMP/found"
    fi
    found() { grep -qxF -- "$1" "$TMP/found" 2>/dev/null || xargs -0 grep -lwF -- "$1" < "$TMP/files0" 2>/dev/null | grep -q .; }
    # a test file: from the repository root, from the spec, or from the root of a sub-project (a unique path suffix)
    testfile() { [ -e "$ROOT/$1" ] && { echo "$ROOT/$1"; return; }; [ -e "$SPEC/$1" ] && { echo "$SPEC/$1"; return; }
        local m; m=$(grep -F -- "/$1" "$TMP/files" | awk -v P="/$1" 'substr($0, length($0) - length(P) + 1) == P'); [ "$(printf '%s\n' "$m" | grep -c .)" = 1 ] && echo "$ROOT/$m"; }
    while IFS="$US" read -r ln sc tier ptr; do
        echo "$tiers" | grep -qxF -- "$tier" || { fail "$bf:$ln: tier '$tier' is not in behavior-formulation.md §Verification Mapping"; continue; }
        case "$ptr" in *planned:*) fail "$bf:$ln: pointer is still planned: $ptr"; continue ;; esac
        case "$tier" in
            probe)
                np=0
                while IFS= read -r t; do is_path "$t" || continue; np=$((np + 1)); p=$(bare_path "$t"); p=${p#"$SP"/}
                    case "/$p/" in */../*) fail "$bf:$ln: probe path $t leaves the spec"; continue ;; esac
                    [ -e "$SPEC/$p" ] || fail "$bf:$ln: probe path $t does not exist under $SP"
                done < <(ticks "$ptr")
                [ $np -gt 0 ] || fail "$bf:$ln: probe pointer names no backticked file" ;;
            auto-test)
                # every file-shaped word exists; of the name-shaped words (other words, e.g. a commit, may sit among them) at least one is found
                nf=0; nn=0; hit=0; names=""
                while IFS= read -r t; do
                    if is_path "$t" || [ "${t#*::}" != "$t" ]; then p=$(bare_path "$t"); fp=$(testfile "$p")
                        # a dotted word that is no file and ends in no file extension of the repository (Suite.case) is a name
                        [ -n "$fp" ] || [ "$p" != "$t" ] || [ "${t#*/}" != "$t" ] || grep -qxF -- ".${t##*.}" "$TMP/exts" || ! found "$t" || { nn=$((nn + 1)); hit=1; continue; }
                        nf=$((nf + 1)); [ -n "$fp" ] || { fail "$bf:$ln: test file $p does not exist"; continue; }
                        nm=${t#*::}; [ "$nm" != "$t" ] && { grep -qwF -- "$nm" "$fp" || fail "$bf:$ln: test $nm not found in $p"; }
                    else nn=$((nn + 1)); names="$names $t"; [ $hit -eq 1 ] || { found "$(testkey "$t")" && hit=1; }
                    fi
                done < <(ticks "$ptr")
                if [ $((nf + nn)) -eq 0 ]; then fail "$bf:$ln: auto-test pointer names no backticked test"
                elif [ $nn -gt 0 ] && [ $hit -eq 0 ]; then fail "$bf:$ln: none of the test names${names} is found outside docs/"; fi ;;
            user)
                if [ -z "$sc" ]; then fail "$bf:$ln: user line outside a \`### Scenario N\` heading"
                elif [ ! -f "$SPEC/probe/user-S$sc.md" ]; then NOTRUN=$((NOTRUN + 1)); echo "NOT RUN: S$sc — $SP/probe/user-S$sc.md ($bf:$ln)"; fi ;;
        esac
    done < <(verification_lines "$SPEC/behaviors.md")
fi

echo "check_completion: $SP — kind $KIND, checks: ${CHECKS:-none}; $FAILS failure(s), $NOTRUN user scenario(s) not run"
[ $FAILS -eq 0 ] || exit 1
exit 0
