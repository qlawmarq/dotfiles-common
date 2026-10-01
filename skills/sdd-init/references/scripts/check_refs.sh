#!/bin/bash
# Cross-document references in Markdown/JSON document sets (an SDD project, or the SDD distribution). Report-only:
# `check` exits with the finding count (capped at 255), not a stop signal. Generic — configure by arguments, do not edit.
#
#   check_refs.sh [opts] list                          # one reference per line: file:line<TAB>kind<TAB>raw<TAB>resolved<TAB>status
#                                                      #   status: ok | dangling | ambiguous (several same-named files) | external (outside the scan)
#   check_refs.sh [opts] check                         # dangling references as `file:line: kind: raw`, then `check: N finding(s)` per kind
#   check_refs.sh [opts] refs <target>                 # who cites <target>: a path, `path §section`, an ID, or /skill-name
#   check_refs.sh [opts] graph [--mermaid] [--by dir]  # file digraph (DOT, or Mermaid); edge label = reference count
#   check_refs.sh [opts] unused [--no-entry]           # scanned files no other file cites; entry files (AGENTS/README/SKILL.md, spec.json) listed apart
#   check_refs.sh [opts] stats                         # per file: cited-by count, cites count, dangling count (most cited first)
#   opts: --root <dir> (default: git top)   --scan <dir|file> (repeatable; default: the SDD project layout under root)
#         --map FROM=TO (repeatable; e.g. docs/settings=<dist>/references)   --include-records (also cite from done/ archive/ probe/ reviews/)
#         --skip-ids <FAM,...> (ID families `check` ignores, e.g. U; open-question tables of the canon README are always ignored)   -h
#   kinds: link, path, section (`file §heading`), skill (/sdd-*), json:<field> (spec.json plan.parent / plan.unit_id, inception.json units), id:<family>
set -u

ROOT=""; CMD=""; TARGET=""; RECORDS=0; MERMAID=0; BYDIR=0; NOENTRY=0; SKIPIDS=""; SCANS=""; MAPS=""
usage() { sed -n 2,15p "$0"; }
while [ $# -gt 0 ]; do case "$1" in
    --root|--scan|--map|--skip-ids) [ $# -ge 2 ] || { echo "$1 needs a value" >&2; usage >&2; exit 1; } ;; esac; case "$1" in
    --root) ROOT="$2"; shift 2 ;; --scan) SCANS="$SCANS$2
"; shift 2 ;; --map) MAPS="$MAPS$2
"; shift 2 ;;
    --include-records) RECORDS=1; shift ;; --mermaid) MERMAID=1; shift ;; --no-entry) NOENTRY=1; shift ;; --skip-ids) SKIPIDS="$2"; shift 2 ;;
    --by) [ "${2:-}" = dir ] || { echo "--by takes 'dir'" >&2; exit 1; }; BYDIR=1; shift 2 ;;
    list|check|refs|graph|unused|stats) CMD="$1"; shift; [ "$CMD" = refs ] && { TARGET="${1:-}"; shift; } ;;
    -h|--help) usage; exit 0 ;; *) echo "unknown arg: $1" >&2; exit 1 ;;
esac; done
[ -z "$CMD" ] && { usage; exit 1; }
[ "$CMD" = refs ] && [ -z "$TARGET" ] && { echo "refs needs a target" >&2; exit 1; }
[ -z "$ROOT" ] && ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT" || exit 1

# Canon root as in check_canon.sh: declared in product.md, else docs/canon
CANON=$(grep -m1 -oE 'Canon root:[[:space:]]*`?[^` ]+' docs/steering/product.md 2>/dev/null | sed -E 's/Canon root:[[:space:]]*`?//; s#/$##')
[ -z "$CANON" ] && CANON="docs/canon"
AUTO=0
if [ -z "$SCANS" ]; then                                  # default scan = the live SDD project layout
    [ -d docs/steering ] || [ -d docs/tasks ] || [ -d docs/inception ] || { echo "no SDD project layout under $ROOT — pass --scan" >&2; exit 1; }
    AUTO=1
    for p in AGENTS.md CLAUDE.md README.md docs/steering "$CANON" docs/inception docs/tasks; do [ -e "$p" ] && SCANS="$SCANS$p
"; done
fi
T=$(mktemp -d "${TMPDIR:-/tmp}/check_refs.XXXXXX") || exit 1
trap 'rm -rf "$T"' EXIT
printf '%s' "$SCANS" | sed -E 's#^\./##; s#/+$##' | grep -v '^$' > "$T/scans"
printf '%s' "$MAPS" | sed -E 's#/+=#=#; s#/+$##' | grep -v '^$' > "$T/maps"
# every file and directory under root, minus .git, node_modules and nested repositories (worktrees, clones) that hold no scan path
find . -path ./.git -prune -o -name node_modules -prune -o -name .git -print | sed -E 's#^\./##; s#/\.git$##' > "$T/nested"
nested() { LC_ALL=C awk -v N="$T/nested" -v S="$T/scans" 'BEGIN { while ((getline l < S) > 0) sc[++m] = l
        while ((getline l < N) > 0) { k = 1; for (i = 1; i <= m; i++) if (sc[i] == l || index(sc[i], l "/") == 1) k = 0; if (k) X[++n] = l } }
    { for (i = 1; i <= n; i++) if ($0 == X[i] || index($0, X[i] "/") == 1) next; print }'; }
find . \( -name .git -o -name node_modules \) -prune -o -type f -print | sed "s#^\./##" | nested | LC_ALL=C sort > "$T/files"
find . \( -name .git -o -name node_modules \) -prune -o -type d -print | sed 's#^\./##' | nested > "$T/dirs"

# ---------- extract + resolve (one awk pass; byte-wise, so multibyte text is matched as bytes) ----------
cat > "$T/refs.awk" <<'AWK'
function dirn(p,  i) { i = match(p, /\/[^\/]*$/); return i ? substr(p, 1, i - 1) : "." }
function basen(p,  n, a) { sub(/\/+$/, "", p); n = split(p, a, "/"); return a[n] }
function joinp(d, p) { return d == "." ? p : d "/" p }
function normp(p,  n, a, i, k, st, out) {              # collapse . and ..; "\001" when it climbs above the root
    n = split(p, a, "/"); k = 0
    for (i = 1; i <= n; i++) { if (a[i] == "" || a[i] == ".") continue
        if (a[i] == "..") { if (k == 0) return "\001"; k--; continue }
        st[++k] = a[i] }
    out = ""; for (i = 1; i <= k; i++) out = out (i > 1 ? "/" : "") st[i]
    return out == "" ? "." : out
}
function exists(p) { sub(/\/+$/, "", p); return p == "." || p == "" || (p in F) || (p in D) }
function under(p, i) { for (i = 1; i <= NSC; i++) if (SC[i] == "." || p == SC[i] || index(p, SC[i] "/") == 1) return 1; return 0 }
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
function placeholder(s) { return s ~ /[<>{}*$]|\.\.\./ || index(s, "…") }
function emit(f, l, k, raw, res, st) { gsub(/\t/, " ", raw); print f ":" l "\t" k "\t" raw "\t" res "\t" st }
function disp(s,  i, c, cut) {                         # a short, char-safe rendering of the text after §
    cut = length(s)
    for (i = 1; i <= ND; i++) { c = index(s, DL[i]); if (c > 1 && c - 1 < cut) cut = c - 1 }
    if (cut > 60) cut = 60
    while (cut > 0 && cut < length(s) && ORD[substr(s, cut + 1, 1)] >= 128 && ORD[substr(s, cut + 1, 1)] < 192) cut--
    return trim(substr(s, 1, cut))
}
function hnorm(s) { gsub(/\*\*|`|"/, "", s); gsub(/[ \t]+/, " ", s); sub(/[ #]+$/, "", s); return tolower(trim(s)) }
function slug(s,  i) {                                 # GitHub-style heading anchor, approximated byte-wise
    s = tolower(trim(s)); gsub(/[]!"#$%&'()*+,.\/:;<=>?@[\\^`{|}~]/, "", s)
    for (i = 1; i <= NPU; i++) gsub(PU[i], "", s)
    gsub(/ /, "-", s); return s
}
function pdecode(s,  o, h) {                           # %XX → byte
    o = ""; while (match(s, /%[0-9A-Fa-f][0-9A-Fa-f]/)) { h = toupper(substr(s, RSTART + 1, 2))
        o = o substr(s, 1, RSTART - 1) sprintf("%c", HX[substr(h, 1, 1)] * 16 + HX[substr(h, 2, 1)]); s = substr(s, RSTART + 3) }
    return o s
}
function label(s) {                                   # a leading section label (4, 4.9, A, L2, A-6), lowercased; "" when none
    if (match(s, /^([A-Za-z]+-?[0-9]+(\.[0-9]+)*|[0-9]+(\.[0-9]+)*|[A-Za-z])/) && substr(s, RLENGTH + 1, 1) !~ /[A-Za-z0-9]/) return tolower(substr(s, 1, RLENGTH))
    return ""
}
function addh(f, h,  i, c, p) {                         # a heading, plus its core (the part before a gloss: （ ( ＝ ： : —)
    h = hnorm(h); HN[f, ++HC[f]] = h; c = length(h)
    for (i = 1; i <= NGL; i++) { p = index(h, GL[i]); if (p > 1 && p - 1 < c) c = p - 1 }
    if (c < length(h)) HN[f, ++HC[f]] = trim(substr(h, 1, c))
    if (match(h, /（[^）]+）|\([^)]+\)/)) HN[f, ++HC[f]] = trim(substr(h, RSTART + (substr(h, RSTART, 1) == "(" ? 1 : 3), RLENGTH - (substr(h, RSTART, 1) == "(" ? 2 : 6)))   # the gloss itself, e.g. `<heading>（Out-of-Scope）` → Out-of-Scope
}
function loadheads(f,  l, h, cur, k, sl, inf) {        # headings, their labels (`## 4.`, `## A.`; list item 9 under `## 4.` = 4.9), anchors
    if (f in HL) return; HL[f] = 1; HC[f] = 0; cur = ""
    while ((getline l < f) > 0) {
        if (l ~ /^(```|~~~)/) inf = !inf
        if (l ~ /^#+[ \t]/ && !inf) {
            h = l; sub(/^#+[ \t]+/, "", h); addh(f, h)
            sl = slug(h); SL[f, sl (SLN[f, sl]++ ? "-" (SLN[f, sl] - 1) : "")] = 1
            sub(/^§/, "", h); k = label(h); cur = k ~ /^[0-9.]+$/ ? k : ""
            if (k != "") { NK[f, k] = 1; h = substr(h, length(k) + 1); sub(/^[.:)]?[ \t]*/, "", h); if (h != "") addh(f, h) }
        } else if (cur != "" && match(l, /^[0-9]+\.[ \t]/)) NK[f, cur "." substr(l, 1, RLENGTH - 2)] = 1
        else if (match(l, /^(- )?\*\*[^*]+\*\*/)) { h = substr(l, RSTART, RLENGTH); sub(/^- /, "", h); addh(f, h) }   # bold lead-in used as a heading
    }
    close(f)
}
function bnd(c) { return c == "" || c !~ /[a-z0-9_]/ }
function hasheading(f, s,  i, h, k) {                  # the text after § starts with a heading (or is the start of one)
    if (f !~ /\.md$/) return 1
    loadheads(f); s = hnorm(s); MH = ""
    k = label(s); if (k != "") { MH = "§" k; if ((f SUBSEP k) in NK) return 1; if (k ~ /^[0-9.]+$/) return 0; MH = "" }
    for (i = 1; i <= HC[f]; i++) { h = HN[f, i]; if (h == "") continue
        if ((index(s, h) == 1 && bnd(substr(s, length(h) + 1, 1))) || (length(s) >= 3 && index(h, s) == 1 && bnd(substr(h, length(s) + 1, 1)))) { MH = h; return 1 } }
    return 0
}
function variants(f,  k) { k = dirn(f) "/" basen(f); return (k in VR) ? VR[k] : "" }
function bare(p, from,  d, list, n, a, i) {            # a file name without a directory
    d = dirn(from); NC = 0
    list = (p in BS) ? BS[p] : ((AUTO && p in BA) ? BA[p] : "")   # an explicit --scan never reaches outside itself for a bare name
    if (list == "") return p ~ /\.(md|sh)$/ ? "dangling" : "external"   # an unknown code/config/data name is a project-side example
    n = split(substr(list, 2), a, "\n")
    for (i = 1; i <= n; i++) if (dirn(a[i]) == d) { R = a[i]; return "ok" }
    for (i = 1; i <= n; i++) CA[++NC] = a[i]
    if (n == 1) { R = a[1]; return "ok" }
    R = n " candidates"; return "ambiguous"
}
function resolve(p, from, islink,  d, c, c2, i, a0, n, k) {      # sets R; returns ok | dangling | external | ambiguous
    R = ""; NC = 0; sub(/^\.\//, "", p); gsub(/%20/, " ", p); d = dirn(from)
    if (p == "") { R = from; return "ok" }
    c = normp(joinp(d, p)); if (c != "\001" && exists(c)) { R = c; return "ok" }
    if (islink) { R = c; return c == "\001" ? "external" : "dangling" }
    c2 = normp(p); if (c2 != "\001" && (AUTO || p ~ /\//) && exists(c2)) { R = c2; return "ok" }
    for (i = 1; i <= NMP; i++) if (p == MF[i] || index(p, MF[i] "/") == 1) { R = normp(MT[i] substr(p, length(MF[i]) + 1)); return exists(R) ? "ok" : "dangling" }
    if (p !~ /\//) return bare(p, from)
    if (p ~ /^\.\.?\//) { R = c; return (c != "\001" && (AUTO || under(c))) ? "dangling" : "external" }
    n = 0; for (k in F) if ((AUTO || under(k)) && index(k, "/" p) && substr(k, length(k) - length(p)) == "/" p) { n++; R = k }   # written from some base dir
    if (n == 1) return "ok"; if (n > 1) { R = n " candidates"; return "ambiguous" }
    R = c2                                              # a bare-rooted path: in the project layout its first directory must exist
    if (AUTO) { split(p, a0, "/"); return (exists(a0[1]) || exists(joinp(d, a0[1]))) ? "dangling" : "external" }
    return under(c2) ? "dangling" : "external"
}
function section(f, l, fp, s, raw,  st, i, n, a) {
    if (placeholder(fp) || s == "" || placeholder(substr(s, 1, 2))) return
    raw = fp " §" disp(s); st = resolve(fp, f, 0)
    if (st == "external" || st == "dangling") { emit(f, l, "section", raw, R, st); return }
    if (st == "ok") { if (hasheading(R, s)) { emit(f, l, "section", raw, R (MH != "" ? "#" MH : ""), "ok"); return }
        n = split(substr(variants(R), 2), a, "\n")
        for (i = 1; i <= n; i++) if (hasheading(a[i], s)) { emit(f, l, "section", raw, a[i] "#" MH, "ok"); return }
        emit(f, l, "section", raw, R "#?", "dangling"); return }
    for (i = 1; i <= NC; i++) if (hasheading(CA[i], s)) { emit(f, l, "section", raw, CA[i] "#" MH " (+" NC - 1 ")", "ok"); return }
    emit(f, l, "section", raw, R, "ambiguous")
}
function pathlike(t) {
    if (t ~ /:\/\// || t ~ /^[\/~]/ || t ~ /^\.[a-z0-9]+$/ || index(t, "=") || placeholder(t)) return 0
    return match(t, /\.[a-z][a-z0-9]*$/) && (substr(t, RSTART + 1) in EXT)
}
function cleantok(t) { sub(/^[(\["']+/, "", t); sub(/[)\]"',.;:]+$/, "", t); sub(/:[0-9]+(-[0-9]+)?$/, "", t); sub(/#.*$/, "", t); return t }
function sectext(s,  i) { sub(/^[ \t]*/, "", s)
    if (substr(s, 1, 3) == "「") { s = substr(s, 4); i = index(s, "」"); if (i) s = substr(s, 1, i - 1) }
    else if (s ~ /^"/) { s = substr(s, 2); sub(/".*$/, "", s) } else sub(/[`|\002\003].*$/, "", s); sub(/[ \t]*-->.*$/, "", s); return trim(s) }
function scanline(f, l, L,  s, s2, lk, tgt, after, c, fp, i, n, tk, t, st, anc, p, pc, nc, nn, tok, fam, off, en, nm, u) {
    # 1. Markdown links (relative targets) — a link directly followed by §… is a section reference to the target
    s = L; s2 = ""
    while (match(s, /\[[^]]*\]\([^) ]+( "[^"]*")?\)/)) {
        lk = substr(s, RSTART, RLENGTH); after = substr(s, RSTART + RLENGTH); pc = RSTART > 1 ? substr(s, RSTART - 1, 1) : ""
        s2 = s2 substr(s, 1, RSTART - 1) "\002"; s = after
        if (pc ~ /[A-Za-z0-9_]/) continue                  # name[](x) is array notation, not a link
        tgt = lk; sub(/^\[[^]]*\]\(/, "", tgt); sub(/( "[^"]*")?\)$/, "", tgt); sub(/^</, "", tgt); sub(/>$/, "", tgt)
        if (tgt ~ /^[a-zA-Z][a-zA-Z0-9+.-]*:/ || placeholder(tgt)) continue
        anc = ""; if (index(tgt, "#")) { anc = substr(tgt, index(tgt, "#") + 1); tgt = substr(tgt, 1, index(tgt, "#") - 1) }
        if (after ~ /^ ?`?§/) { sub(/^ ?`?§/, "", after); section(f, l, tgt == "" ? basen(f) : tgt, sectext(after)); continue }
        st = resolve(tgt, f, 1)
        if (st == "ok" && anc != "" && R ~ /\.md$/) { loadheads(R); if (!((R SUBSEP pdecode(anc)) in SL)) { emit(f, l, "link", lk, R "#" anc, "dangling"); continue } }
        emit(f, l, "link", lk, R (anc != "" ? "#" anc : ""), st)
    }
    s = s2 s; s2 = ""
    # 2. code spans: `path`, `path §heading`, `path` §heading, or paths among the span's words
    while (match(s, /`[^`]+`/)) {
        c = substr(s, RSTART + 1, RLENGTH - 2); after = substr(s, RSTART + RLENGTH); s2 = s2 substr(s, 1, RSTART - 1) "\003"; s = after
        if (index(c, "§")) { fp = trim(substr(c, 1, index(c, "§") - 1)); if (pathlike(cleantok(fp))) section(f, l, cleantok(fp), sectext(substr(c, index(c, "§") + 2))); continue }
        if (after ~ /^ ?§/ && pathlike(cleantok(trim(c)))) { sub(/^ ?§/, "", after); section(f, l, cleantok(trim(c)), sectext(after)); continue }
        n = split(c, tk, /[ \t]+/)
        for (i = 1; i <= n; i++) { t = cleantok(tk[i]); if (!pathlike(t)) continue
            st = resolve(t, f, 0)
            if (st == "dangling" && t ~ /(^|\/)probe\/user-S[0-9]+\.md$/) st = "external"   # a user check's record exists only once the user has run it
            emit(f, l, "path", t, R, st) }
    }
    s = s2 s
    # 3. a bare file name followed by § in prose
    while (match(s, /[A-Za-z0-9_.\/-]+\.(md|json|sh) ?§/)) {
        fp = substr(s, RSTART, RLENGTH); sub(/ ?§$/, "", fp); after = substr(s, RSTART + RLENGTH); s = after
        section(f, l, fp, sectext(after))
    }
    # 4. skill names /<prefix>… not inside a path
    s = L; off = 0
    while (match(s, SKRE)) {
        en = off + RSTART + RLENGTH; pc = off + RSTART > 1 ? substr(L, off + RSTART - 1, 1) : ""; tok = substr(s, RSTART, RLENGTH)
        s = substr(s, RSTART + RLENGTH); off = en - 1; nc = substr(L, en, 1)
        if (pc ~ /[A-Za-z0-9_.\/~-]/ || nc ~ /[<{*\[]/) continue
        sub(/-+$/, "", tok); nm = substr(tok, 2)
        emit(f, l, "skill", tok, (nm in SK) ? SK[nm] : "", (nm in SK) ? "ok" : "dangling")
    }
    # 5. IDs: a defined family (prefix + number) not glued to other word characters
    if (NFAM) { s = L; off = 0
        while (match(s, /[A-Za-z]+-?[0-9]+/)) {
            tok = substr(s, RSTART, RLENGTH); p = off + RSTART; en = p + RLENGTH; s = substr(s, RSTART + RLENGTH); off = en - 1
            pc = p > 1 ? substr(L, p - 1, 1) : ""; nc = substr(L, en, 1); nn = substr(L, en + 1, 1)
            if (pc ~ /[A-Za-z0-9_\/.-]/ || nc ~ /[A-Za-z0-9_]/ || (nc ~ /[-.]/ && nn ~ /[A-Za-z0-9]/)) continue
            fam = tok; sub(/[0-9]+$/, "", fam); if (!(fam in FAM) || (f ":" l ":" tok) in DS) continue
            u = tok; if (!(u in DEF)) { nm = tok; sub(/^[A-Za-z]+-?/, "", nm); if ((fam SUBSEP nm + 0) in DN) u = DN[fam, nm + 0] }   # U07 = U7
            sub(/-$/, "", fam); emit(f, l, "id:" fam, tok, (u in DEF) ? u "@" DEF[u] : "", (u in DEF) ? "ok" : "dangling")
        } }
    if (NDATE) { s = L; off = 0                        # spec / plan directory names (YYYY-MM-DD-slug)
        while (match(s, /20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[a-z0-9][a-z0-9-]*/)) {
            tok = substr(s, RSTART, RLENGTH); p = off + RSTART; en = p + RLENGTH; s = substr(s, RSTART + RLENGTH); off = en - 1
            pc = p > 1 ? substr(L, p - 1, 1) : ""; nc = substr(L, en, 1); nn = substr(L, en + 1, 1)
            if (pc ~ /[A-Za-z0-9_.-]/ || (nc == "." && nn ~ /[a-z]/) || nc ~ /[<{*A-Z_]/) continue
            sub(/-+$/, "", tok); emit(f, l, "id:spec", tok, (tok in DD) ? tok "@" DD[tok] : "", (tok in DD) ? "ok" : "dangling")
        } }
}
function jsonfile(f,  l, n, key, s, v, t, dep, pd, inarr, isspec, plan, k, i, parent, sd) {
    isspec = basen(f) == "spec.json"; plan = basen(dirn(f)); n = 0; parent = ""
    dep = 0; pd = -1; key = ""                          # token walk: "key":, "string", [ ] { }, null; spec.json keys count only inside "plan"
    while ((getline l < f) > 0) { n++; s = l
        while (match(s, /"[^"]*"[ \t]*:|"[^"]*"|[][{}]|null/)) { t = substr(s, RSTART, RLENGTH); s = substr(s, RSTART + RLENGTH)
            if (t == "{") { if (key == "plan") pd = dep; dep++; key = ""; continue }
            if (t == "}") { dep--; if (dep == pd) pd = -1; key = ""; continue }
            if (t == "[") { if (key != "") inarr = 1; continue }
            if (t == "]") { inarr = 0; key = ""; continue }
            if (t ~ /:$/) { key = t; sub(/^"/, "", key); sub(/"[ \t]*:$/, "", key); continue }
            if (t == "null") { if (!inarr) key = ""; continue }
            v = substr(t, 2, length(t) - 2)
            if ((isspec ? pd >= 0 && key ~ /^(parent|unit_id)$/ : key ~ /^(unit_id|spec_dir|depends_on)$/) && !placeholder(v)) {
                JK[++k] = key; JV[k] = v; JL[k] = n; if (key == "parent") parent = v }
            if (!inarr) key = "" }
    }
    close(f)
    for (i = 1; i <= k; i++) { key = JK[i]; v = JV[i]
        if (key == "parent") emit(f, JL[i], "json:parent", v, (v in PL) ? PL[v] : "", (v in PL) ? "ok" : "dangling")
        else if (key == "unit_id" && isspec) emit(f, JL[i], "json:unit_id", v, ((parent, v) in DU) ? v "@" DU[parent, v] : "", ((parent, v) in DU) ? "ok" : "dangling")
        else if (key == "unit_id") continue
        else if (key == "spec_dir") { sd = v; sub(/\/+$/, "", sd)
            if (exists(sd)) emit(f, JL[i], "json:spec_dir", v, sd, "ok")
            else emit(f, JL[i], "json:spec_dir", v, (basen(sd) in SP) ? "moved: " dirn(SP[basen(sd)]) : "", "dangling") }
        else { if ((plan, v) in DU) emit(f, JL[i], "json:depends_on", v, v "@" DU[plan, v], "ok")
            else if (v in SP) emit(f, JL[i], "json:depends_on", v, SP[v], "ok")
            else emit(f, JL[i], "json:depends_on", v, "", "dangling") }
    }
}
BEGIN {
    FS = "\t"; for (i = 1; i < 256; i++) ORD[sprintf("%c", i)] = i
    for (i = 0; i < 16; i++) HX[substr("0123456789ABCDEF", i + 1, 1)] = i
    NGL = split("（|(|＝|：|:| —|—| - ", GL, "|")
    ND = split("`||(|（|、|。|,|;|—|)|）|・|「|」", DL, "|"); DL[2] = "|"
    NPU = split("（ ） 「 」 『 』 【 】 、 。 ・ ： ； ！ ？ ＝ ／ 〔 〕 … ― — – “ ” ‘ ’ ＋ ～ 〜 ＆ ＃ ％ ＊ ， ． ＜ ＞ ［ ］ ｛ ｝ ｜ → ← ↔ ↑ ↓ ⇒ × ＿", PU, " ")
    split("md json jsonl sh bash zsh txt yml yaml toml csv tsv gd tscn tres godot cfg ini py js mjs cjs ts tsx jsx rb go rs java kt swift c h cc cpp hpp cs html css scss sql xml svg png jpg example lock log", e, " ")
    for (i in e) EXT[e[i]] = 1
    SKRE = "/" SKP "[a-z0-9][a-z0-9-]*"
    while ((getline l < (T "/scans")) > 0) SC[++NSC] = l
    while ((getline l < (T "/maps")) > 0) { i = index(l, "="); if (i) { MF[++NMP] = substr(l, 1, i - 1); MT[NMP] = substr(l, i + 1) } }
    while ((getline l < (T "/dirs")) > 0) D[l] = 1
    while ((getline l < (T "/files")) > 0) { F[l] = 1; b = basen(l); BA[b] = BA[b] "\n" l
        if (under(l)) { BS[b] = BS[b] "\n" l
            if ((l ~ /\.(md|sh)$/ || b == "spec.json" || (b == "inception.json" && basen(dirn(dirn(l))) == "inception")) && (RECS || l !~ /(^|\/)(done|archive|probe|reviews)\//)) SRC[++NS] = l }
        if (match(b, /^[^.-]+-[^\/]*\./)) { k = dirn(l) "/" substr(b, 1, index(b, "-") - 1) substr(b, match(b, /\.[^.]*$/)); VR[k] = VR[k] "\n" l }
        if (b == "SKILL.md") { while ((getline x < l) > 0) { if (x ~ /^name:/) { sub(/^name:[ \t]*/, "", x); gsub(/["' ]/, "", x); SK[x] = l; break } if (x ~ /^#/) break } close(l) }
        if (b == "spec.json" && basen(dirn(l)) !~ /[{<]/) SP[basen(dirn(l))] = l
        if (b == "inception.json" && basen(dirn(dirn(l))) == "inception") { pn = basen(dirn(l)); PL[pn] = l   # plans: inception/<plan-id>/ only
            while ((getline x < l) > 0) if (match(x, /"unit_id"[ \t]*:[ \t]*"[^"]+"/)) { u = substr(x, RSTART, RLENGTH); sub(/.*:[ \t]*"/, "", u); sub(/"$/, "", u)
                if (placeholder(u)) continue; DU[pn, u] = l; DEF[u] = l; if (match(u, /^[A-Za-z]+[0-9]+$/)) { fm = u; sub(/[0-9]+$/, "", fm); FAM[fm] = 1 } }
            close(l) }
    }
    for (k in SP) if (k ~ /^20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-/) { DD[k] = SP[k]; NDATE++ }
    for (k in PL) if (k ~ /^20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-/) { DD[k] = PL[k]; NDATE++ }
    # canon README: the first table is the decision log (ID → its linked decision file); IDs of later tables (open questions)
    # are defined too, but a closed question leaves the table, so their families are not checked. Registry: DOMAIN-NN rows.
    rd = CANON "/README.md"; n = 0; tb = 0; pr = ""
    while ((getline x < rd) > 0) { n++; if (x !~ /^\|/) { pr = x; continue }; if (pr !~ /^\|/) tb++; pr = x; split(x, cc, "|"); u = trim(cc[2])
        if (u !~ /^[A-Za-z]+[0-9]+$/) continue; DS[rd ":" n ":" u] = 1; fm = u; sub(/[0-9]+$/, "", fm); FAM[fm] = 1; DEF[u] = rd
        if (tb > 1) { QF[fm] = 1; continue }
        if (match(x, /\]\([^)#]+/)) { t = normp(joinp(CANON, substr(x, RSTART + 2, RLENGTH - 2))); if (t in F) DEF[u] = t } }
    for (k in QF) printf "%s,", k > (T "/qfams")
    close(rd); rg = CANON "/registry.md"; n = 0
    while ((getline x < rg) > 0) { n++; if (x !~ /^\|/) continue; split(x, cc, "|"); u = trim(cc[2])
        if (u !~ /^[A-Z][A-Z0-9]*-[0-9]+$/) continue; DS[rg ":" n ":" u] = 1; DEF[u] = rg; fm = u; sub(/[0-9]+$/, "", fm); FAM[fm] = 1 }
    close(rg); for (k in FAM) NFAM++
    for (k in DEF) { fm = k; sub(/[0-9]+$/, "", fm); nm = substr(k, length(fm) + 1); DN[fm, nm + 0] = k }
    for (i = 1; i <= NS; i++) { f = SRC[i]; b = basen(f)
        if (b == "spec.json" || b == "inception.json") { jsonfile(f); continue }
        n = 0; while ((getline L < f) > 0) { n++; if (index(L, "`") || index(L, "](") || index(L, "§") || index(L, "/") || NFAM || NDATE) scanline(f, n, L) }
        close(f) }
    for (i = 1; i <= NS; i++) print SRC[i] > (T "/sources")
}
AWK
LC_ALL=C awk -v T="$T" -v AUTO="$AUTO" -v RECS="$RECORDS" -v CANON="$CANON" -v SKP="sdd-" -f "$T/refs.awk" < /dev/null > "$T/list"
touch "$T/sources" "$T/qfams"

# ---------- subcommands: all derive from the list ----------
tgt() { LC_ALL=C awk -F'\t' '{ t = $4; if ($2 ~ /^id:|^json:(unit_id|depends_on)/) sub(/^[^@]*@/, "", t); sub(/#.*$/, "", t); sub(/ \(\+[0-9]+\)$/, "", t); print t }'; }
case "$CMD" in
list) cat "$T/list" ;;
check)
    LC_ALL=C awk -F'\t' -v SKIP=",$SKIPIDS,$(cat "$T/qfams")," '$5 == "dangling" { f = $2; sub(/^id:/, "", f); if ($2 ~ /^id:/ && index(SKIP, "," f ",")) { sk++; next }
        n++; c[$2]++; print $1 ": " $2 ": " $3 ($4 ~ /^moved:/ ? " (" $4 ")" : "") }
        $5 == "ambiguous" { a++ } $5 == "external" { e++ }
        END { printf "check: %d finding(s)\n", n; for (k in c) print "  " k ": " c[k] | "sort"; close("sort")
              s = SKIP; gsub(/,+/, ",", s); gsub(/^,|,$/, "", s)
              printf "  (not counted: ambiguous %d, external %d, dangling in skipped ID families [%s] %d)\n", a, e, s, sk; exit (n > 255 ? 255 : n) }' "$T/list"
    exit $? ;;
refs)
    LC_ALL=C awk -F'\t' -v Q="$TARGET" '
        function hn(s) { gsub(/\*\*|`|"/, "", s); gsub(/[ \t]+/, " ", s); sub(/^ /, "", s); sub(/ $/, "", s); return tolower(s) }
        BEGIN { sec = ""; if (index(Q, "§")) { sec = hn(substr(Q, index(Q, "§") + 2)); Q = substr(Q, 1, index(Q, "§") - 1); sub(/[ `]+$/, "", Q); sub(/^`/, "", Q) }
                sub(/^\.\//, "", Q); sub(/\/+$/, "", Q) }
        { t = $4; if ($2 ~ /^id:|^json:(unit_id|depends_on)/) { id = t; sub(/@.*/, "", id); sub(/^[^@]*@/, "", t) } else id = ""
          h = ""; if (index(t, "#")) { h = substr(t, index(t, "#") + 1); t = substr(t, 1, index(t, "#") - 1) }; sub(/ \(\+[0-9]+\)$/, "", h)
          if (Q ~ /^\//) hit = ($2 == "skill" && $3 == Q)
          else if (sec != "") hit = (t == Q || (Q !~ /\// && t ~ ("(^|/)" Q "$"))) && $2 == "section" && h != "" && (index(sec, h) == 1 || index(h, sec) == 1)
          else hit = ($3 == Q || id == Q || t == Q || index(t, Q "/") == 1) && $5 == "ok"
          if (hit) { n++; print $1 "\t" $2 "\t" $3 } }
        END { printf "refs: %d citation(s) of %s\n", n, Q (sec != "" ? " §" sec : "") > "/dev/stderr" }' "$T/list" ;;
graph)
    paste "$T/list" <(tgt < "$T/list") | LC_ALL=C awk -F'\t' -v BY="$BYDIR" -v MM="$MERMAID" '
        function dn(p,  i) { i = match(p, /\/[^\/]*$/); return i ? substr(p, 1, i - 1) : "." }
        $5 == "ok" && $6 != "" { s = $1; sub(/:[0-9]+$/, "", s); t = $6; if (BY) { s = dn(s); t = dn(t) } if (s == t) next; E[s "\t" t]++
            if (!(s in ID)) ID[s] = ++n; if (!(t in ID)) ID[t] = ++n }
        END { print MM ? "graph LR" : "digraph refs {\n  rankdir=LR; node [shape=box];"
              for (k in ID) if (MM) printf "  n%d[\"%s\"]\n", ID[k], k | "sort -k1.4n"; close("sort -k1.4n")
              for (e in E) { split(e, a, "\t")
                  if (MM) printf "  n%d -->|%d| n%d\n", ID[a[1]], E[e], ID[a[2]] | "sort"; else printf "  \"%s\" -> \"%s\" [label=\"%d\"];\n", a[1], a[2], E[e] | "sort" }
              close("sort"); if (!MM) print "}" }' ;;
unused)
    paste "$T/list" <(tgt < "$T/list") | LC_ALL=C awk -F'\t' -v NOENTRY="$NOENTRY" -v SRCS="$T/sources" '
        $5 == "ok" { s = $1; sub(/:[0-9]+$/, "", s); if (s != $6) IN[$6] = 1 }
        END { while ((getline f < SRCS) > 0) { if (f in IN) continue; b = f; sub(/.*\//, "", b)
                  if (b ~ /^(AGENTS|CLAUDE|README|SKILL)\.md$|^spec\.json$/) ent[++ne] = f; else { print f; n++ } }
              if (!NOENTRY && ne) { print ""; print "entry files (not cited, expected):"; for (i = 1; i <= ne; i++) print "  " ent[i] }
              printf "unused: %d file(s)%s\n", n, NOENTRY ? "" : sprintf(", %d entry file(s)", ne) > "/dev/stderr" }' ;;
stats)
    paste "$T/list" <(tgt < "$T/list") | LC_ALL=C awk -F'\t' -v SRCS="$T/sources" '
        { s = $1; sub(/:[0-9]+$/, "", s); A[s] = 1; if ($5 == "dangling") DG[s]++; if ($5 != "ok" || $6 == "" || $6 == s) next; I[$6]++; O[s]++; A[$6] = 1 }
        END { while ((getline f < SRCS) > 0) A[f] = 1
              for (f in A) printf "%d\t%d\t%d\t%s\n", I[f], O[f], DG[f], f }' | sort -t"$(printf '\t')" -k1,1nr -k4,4 | { printf 'cited_by\tcites\tdangling\tfile\n'; cat; } ;;
esac
exit 0
