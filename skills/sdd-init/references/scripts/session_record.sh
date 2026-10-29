#!/bin/bash
# Session record for the change review (docs/settings/rules/decision-records.md §Change Control). The kit's only harness-specific
# file: reads Claude Code (~/.claude/projects/<path, non-alphanumerics as ->/*.jsonl), Gemini CLI
# (~/.gemini/tmp/<sha256 of path>/chats/*.json) and Codex (${CODEX_HOME:-~/.codex}/*sessions/**/rollout-*.jsonl, by its
# session_meta cwd) transcripts of the git top and the current directory. Generic — do not edit.
#
#   session_record.sh dump                      # USER and AGENT turns in time order, each under `===== USER|AGENT <timestamp> <session>`;
#                                               #   no record → stderr `no session record: <reason>`, exit 3
#   session_record.sh verify <record> <quotes>  # quotes: report B of docs/settings/templates/decisions/change-review.md (DOC: as
#                                               #   committed); prints each quote not found; exit code = their count (at most 255)
set -u
case "${1:-}" in dump|verify) ;; -h|--help) sed -n 2,10p "$0"; exit 0 ;; *) sed -n 2,10p "$0" >&2; exit 1 ;; esac
command -v python3 >/dev/null 2>&1 || { echo "no session record: python3 not found" >&2; exit 3; }
exec python3 -I - "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" "$PWD" "$@" <<'PY'
import glob, hashlib, json, os, re, subprocess, sys
from datetime import datetime, timezone

top, cwd, cmd, args = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:]
SKIP = ("<task-notification", "<local-command", "[Request interrupted", "This session is being continued")
CMD_ARGS = re.compile(r"<command-args>(.*?)</command-args>", re.S)

def ts(s):
    d = datetime.fromisoformat(s.strip().replace("Z", "+00:00"))
    return (d if d.tzinfo else d.replace(tzinfo=timezone.utc)).astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

def text(content):
    if isinstance(content, str): return content
    if isinstance(content, list):  # Claude Code keeps only `text` blocks (tool results are not turns)
        return "\n".join(b["text"] for b in content if isinstance(b, dict) and isinstance(b.get("text"), str) and b.get("type", "text") == "text")
    return ""

def load(line):
    try: e = json.loads(line)
    except ValueError: return {}
    return e if isinstance(e, dict) else {}

def claude(project):
    d = os.path.expanduser("~/.claude/projects/" + re.sub(r"[^A-Za-z0-9]", "-", project))
    for path in sorted(glob.glob(os.path.join(d, "*.jsonl")), key=os.path.getmtime):  # a resumed copy, written later, names the session
        for e in map(load, open(path, encoding="utf-8", errors="replace")):
            if e.get("type") not in ("user", "assistant") or e.get("isSidechain") or e.get("isMeta"): continue
            t = text((e.get("message") or {}).get("content"))
            if t.lstrip().startswith(("<command-name>", "<command-message>")): t = "\n".join(a.strip() for a in CMD_ARGS.findall(t))
            if e.get("timestamp") and t.strip() and not t.lstrip().startswith(SKIP):
                yield ts(e["timestamp"]), "USER" if e["type"] == "user" else "AGENT", t, e.get("uuid"), path

def gemini(project):
    d = os.path.expanduser("~/.gemini/tmp/" + hashlib.sha256(project.encode()).hexdigest() + "/chats")
    for path in glob.glob(os.path.join(d, "*.json")):
        try: messages = json.load(open(path, encoding="utf-8")).get("messages") or []
        except (OSError, ValueError, AttributeError): continue
        for m in messages:
            if not isinstance(m, dict) or m.get("type") not in ("user", "gemini") or not m.get("timestamp"): continue
            # an @file reference inlines the file into `content`; `displayContent` is what the user typed
            t = text(m.get("displayContent") or m.get("content")) if m["type"] == "user" else text(m.get("content"))
            if t.strip(): yield ts(m["timestamp"]), "USER" if m["type"] == "user" else "AGENT", t, m.get("id"), path

def codex(project):
    for path in glob.glob(os.path.join(os.environ.get("CODEX_HOME") or os.path.expanduser("~/.codex"), "*sessions", "**", "rollout-*.jsonl"), recursive=True):
        rows = [e for e in map(load, open(path, encoding="utf-8", errors="replace")) if isinstance(e.get("payload"), dict)]
        meta = next((e["payload"] for e in rows if e.get("type") == "session_meta"), {})
        if os.path.abspath(str(meta.get("cwd"))) != project or "subagent" in (meta.get("source") or ""): continue
        for e in rows:  # default (legacy) history: what was typed and said is in event_msg user_message / agent_message
            p = e["payload"]
            if e.get("type") == "event_msg" and p.get("type") in ("user_message", "agent_message") and e.get("timestamp") and text(p.get("message")).strip():
                yield ts(e["timestamp"]), "USER" if p["type"] == "user_message" else "AGENT", text(p["message"]), None, path

PROJECTS = list(dict.fromkeys(os.path.abspath(p) for p in (top, cwd)))

def turns():
    out = {}
    for project in PROJECTS:
        for reader in (claude, gemini, codex):
            for t, who, body, key, path in reader(project):
                k = key or (t, who, body)
                out[k] = t, who, body, os.path.splitext(os.path.basename(path))[0]
    return sorted(out.values(), key=lambda x: x[0])

def norm(s): return re.sub(r"[\s*`]+", "", s)

if cmd == "dump":
    rows = turns()
    for var in ("CLAUDE_CODE_SESSION_ID", "CODEX_SESSION_ID"):  # the running session's id is in its transcript's name
        if os.environ.get(var) and not any(os.environ[var] in r[3] for r in rows): print(f"no session record: no turn of the running session ({var}) — started elsewhere, or the transcripts moved or changed format", file=sys.stderr); sys.exit(3)
    if not rows: print(f"no session record: no Claude Code, Gemini CLI or Codex transcript for {' or '.join(PROJECTS)}", file=sys.stderr); sys.exit(3)
    for t, who, body, sess in rows: sys.stdout.write(f"\n===== {who} {t} {sess}\n{body}\n")
    sys.exit(0)

if len(args) != 2: print("verify needs <record> <quotes>", file=sys.stderr); sys.exit(1)
bodies, cur = {}, None
for line in open(args[0], encoding="utf-8"):
    m = re.match(r"^===== (USER|AGENT) (\S+)(?: \S+)?$", line.rstrip("\n"))
    if m: cur = (m.group(1), m.group(2)); bodies.setdefault(cur, "")
    elif cur: bodies[cur] += line
missing = 0
for raw in open(args[1], encoding="utf-8"):
    f = raw.rstrip("\n").split("\t", 3)
    if not raw.strip(): continue
    if len(f) != 4: hay = None
    elif f[1] == "DOC": hay = subprocess.run(["git", "-C", top, "show", f"HEAD:{f[2]}"], capture_output=True, text=True).stdout or None
    else:
        try: hay = bodies.get((f[1], ts(f[2])))
        except ValueError: hay = None
    pieces = [norm(p) for p in f[3].split("…")] if len(f) == 4 else []
    pos, ok = 0, hay is not None and any(pieces)
    for piece in pieces:
        j = norm(hay).find(piece, pos) if ok and piece else (pos if ok else -1)
        ok = j >= 0; pos = j + len(piece) if ok else pos
    if not ok: missing += 1; print(f"not found: {raw.rstrip()}")
sys.exit(min(missing, 255))
PY
