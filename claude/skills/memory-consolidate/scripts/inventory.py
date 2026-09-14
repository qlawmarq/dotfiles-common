#!/usr/bin/env python3
"""Read-only inventory of a Claude Code auto-memory directory.

Usage:
  python3 inventory.py                      # resolve the memory dir of the current project
  python3 inventory.py --dir <memory-dir>   # inspect an explicit directory
  python3 inventory.py --project-root <dir> # resolve relative paths in memories against <dir>
  python3 inventory.py --json               # machine-readable output

Never writes anything. Findings are mechanical hints (sizes, broken links,
missing paths, index drift, textual overlap); semantic judgement is left to
the agent reading the files.
"""

import argparse
import difflib
import itertools
import json
import os
import re
import subprocess
import sys
from pathlib import Path

INDEX_NAME = "MEMORY.md"
INDEX_MAX_LINES = 200
INDEX_MAX_BYTES = 25 * 1024
LOCK_NAME = ".consolidate-lock"

WIKI_LINK = re.compile(r"\[\[([^\]|#]+)(?:[#|][^\]]*)?\]\]")
MD_LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")
BACKTICK = re.compile(r"`([^`\n]+)`")
DATE = re.compile(r"\b20\d\d-\d\d-\d\d\b")
INDEX_LINE = re.compile(r"^\s*[-*]\s*\[([^\]]*)\]\(([^)]+)\)\s*(?:[—–:-]+\s*(.*))?$")
EXT = r"\.(?!(?:com|org|net|io|dev|ai|app|co|jp)$)[A-Za-z][A-Za-z0-9]{0,4}"
# A path needs an anchor (~/, ./, or an absolute path of two or more segments),
# a trailing slash, or a file extension, so that repository slugs, API routes,
# slash commands and domains (`org/repo`, `/pulls`, `/init`, `example.com`) are
# not reported.
PATH_LIKE = re.compile(
    rf"^(?:~/|\.{{1,2}}/)[\w.@+/-]+$|^/[\w.@+-]+(?:/[\w.@+-]+)+/?$"
    rf"|^[\w.@+-]+(?:/[\w.@+-]+)*/$"
    rf"|^(?:[\w.@+-]+/)*[\w@+-][\w.@+-]*{EXT}$"
)


def git(*args, cwd):
    try:
        out = subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True, check=True)
        return out.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def project_root(cwd):
    """Main worktree root: auto memory is shared across worktrees of one repository."""
    common = git("rev-parse", "--path-format=absolute", "--git-common-dir", cwd=cwd)
    if common and Path(common).name == ".git":
        return Path(common).parent
    top = git("rev-parse", "--show-toplevel", cwd=cwd)
    return Path(top) if top else Path(cwd)


def config_dir():
    return Path(os.environ.get("CLAUDE_CONFIG_DIR", Path.home() / ".claude")).expanduser()


def setting_memory_dir(root):
    candidates = [
        root / ".claude" / "settings.local.json",
        root / ".claude" / "settings.json",
        config_dir() / "settings.json",
    ]
    for f in candidates:
        try:
            value = json.loads(f.read_text()).get("autoMemoryDirectory")
        except (OSError, ValueError, AttributeError):
            continue
        if value:
            return Path(value).expanduser(), f"autoMemoryDirectory in {f}"
    return None, None


def resolve_memory_dir(cwd):
    root = project_root(cwd)
    path, source = setting_memory_dir(root)
    if path:
        return path, source, root
    name = os.environ.get("CLAUDE_CODE_PROJECT_DIR_NAME") or re.sub(r"[^A-Za-z0-9]", "-", str(root))
    return config_dir() / "projects" / name / "memory", f"derived from project root {root}", root


def split_frontmatter(text):
    if not text.startswith("---\n"):
        return {}, text
    end = text.find("\n---", 4)
    if end < 0:
        return {}, text
    meta = {}
    for line in text[4:end].splitlines():
        m = re.match(r"^\s*([A-Za-z_]+):\s*(.*)$", line)
        if m and m.group(2):
            meta.setdefault(m.group(1), m.group(2).strip().strip('"').strip("'"))
    body = text[end + 4:].lstrip("\n")
    return meta, body


def tracked_files(root):
    out = git("ls-files", "--recurse-submodules", cwd=root) or git("ls-files", cwd=root)
    return out.splitlines() if out else []


def path_exists(token, root, memdir, tracked):
    token = token.split("#")[0].split(":")[0]
    p = Path(token).expanduser()
    if p.is_absolute():
        return p.exists()
    if (root / p).exists() or (memdir / p).exists():
        return True
    # Memories often cite a file by a suffix of its path (`rules/x.md`, `x.md`).
    suffix = token.rstrip("/")
    return any(f == suffix or f.endswith("/" + suffix) or ("/" + suffix + "/") in ("/" + f) for f in tracked)


def trigrams(text):
    text = re.sub(r"\s+", "", text)
    return {text[i:i + 3] for i in range(len(text) - 2)}


def inspect(memdir, root):
    files = sorted(p for p in memdir.glob("*.md") if p.name != INDEX_NAME)
    names = {p.stem for p in files}
    tracked = tracked_files(root)
    memories = []
    for p in files:
        text = p.read_text(errors="replace")
        meta, body = split_frontmatter(text)
        wiki = WIKI_LINK.findall(body)
        md_links = [l for l in MD_LINK.findall(body) if not re.match(r"^[a-z]+://", l)]
        paths = [t for t in BACKTICK.findall(body) if PATH_LIKE.match(t.strip())]
        memories.append({
            "file": p.name,
            "name": meta.get("name"),
            "type": meta.get("type"),
            "description": meta.get("description"),
            "bytes": len(text.encode()),
            "dates": sorted(set(DATE.findall(body))),
            "broken_wiki_links": sorted({w for w in wiki if w.strip() not in names}),
            "broken_md_links": sorted({l for l in md_links if not path_exists(l, root, memdir, tracked)}),
            "missing_paths": sorted({t for t in paths if not path_exists(t.strip(), root, memdir, tracked)}),
            "_body": body,
        })

    index = {"exists": False}
    ipath = memdir / INDEX_NAME
    if ipath.exists():
        itext = ipath.read_text(errors="replace")
        lines = itext.splitlines()
        by_file = {m["file"]: m for m in memories}
        entries, dangling, echoing, long_lines = [], [], [], []
        for n, line in enumerate(lines, 1):
            m = INDEX_LINE.match(line)
            if not m:
                continue
            target, hook = m.group(2), (m.group(3) or "")
            entries.append(target)
            if not (memdir / target).exists():
                dangling.append(f"{n}: {target}")
            desc = (by_file.get(target) or {}).get("description") or ""
            if hook and desc and difflib.SequenceMatcher(None, hook, desc).ratio() >= 0.5:
                echoing.append(f"{n}: {target}")
            if len(line) > 150:
                long_lines.append(f"{n}: {len(line)} chars")
        index = {
            "exists": True,
            "lines": len(lines),
            "bytes": len(itext.encode()),
            "line_budget_used": f"{len(lines)}/{INDEX_MAX_LINES}",
            "byte_budget_used": f"{len(itext.encode())}/{INDEX_MAX_BYTES}",
            "dangling_entries": dangling,
            "unindexed_files": sorted(set(by_file) - set(entries)),
            "duplicate_entries": sorted({e for e in entries if entries.count(e) > 1}),
            "hooks_echoing_description": echoing,
            "lines_over_150_chars": long_lines,
        }

    grams = {m["file"]: trigrams((m["description"] or "") + m["_body"]) for m in memories}
    overlaps = []
    for a, b in itertools.combinations(grams, 2):
        union = grams[a] | grams[b]
        if union:
            score = len(grams[a] & grams[b]) / len(union)
            if score >= 0.12:
                overlaps.append((round(score, 2), a, b))
    overlaps.sort(reverse=True)

    for m in memories:
        del m["_body"]

    agent_dirs = [str(d) for d in [root / ".claude" / "agent-memory", root / ".claude" / "agent-memory-local",
                                   config_dir() / "agent-memory"] if d.is_dir()]
    other = sorted(p.name for p in memdir.iterdir() if p.name != INDEX_NAME and p.suffix != ".md")

    return {
        "memory_dir": str(memdir),
        "project_root": str(root),
        "consolidation_lock_present": (memdir / LOCK_NAME).exists(),
        "file_count": len(memories),
        "total_bytes": sum(m["bytes"] for m in memories) + index.get("bytes", 0),
        "index": index,
        "memories": memories,
        "textual_overlap_pairs": [{"score": s, "a": a, "b": b} for s, a, b in overlaps[:15]],
        "non_markdown_entries": other,
        "agent_memory_dirs": agent_dirs,
    }


def render(r, source):
    out = [f"# Memory inventory", "", f"- memory dir: `{r['memory_dir']}` ({source})",
           f"- project root: `{r['project_root']}`",
           f"- consolidation lock present: {r['consolidation_lock_present']}",
           f"- memories (excluding index): {r['file_count']}, total including index: {r['total_bytes']} bytes"]
    i = r["index"]
    if i["exists"]:
        out += [f"- index: {i['lines']} lines / {i['bytes']} bytes (budget {i['line_budget_used']} lines, {i['byte_budget_used']} bytes)"]
        for key in ["dangling_entries", "unindexed_files", "duplicate_entries", "hooks_echoing_description", "lines_over_150_chars"]:
            if i[key]:
                out.append(f"- index {key}: " + "; ".join(i[key]))
    else:
        out.append(f"- index: {INDEX_NAME} missing")
    if r["agent_memory_dirs"]:
        out.append("- subagent memory dirs (not inspected): " + ", ".join(r["agent_memory_dirs"]))
    if r["non_markdown_entries"]:
        out.append("- non-markdown entries: " + ", ".join(r["non_markdown_entries"]))

    out += ["", "## Files", "", "| file | type | bytes | dates | broken links / missing paths |", "| --- | --- | --- | --- | --- |"]
    for m in r["memories"]:
        problems = [f"[[{w}]]" for w in m["broken_wiki_links"]] + m["broken_md_links"] + [f"`{p}`" for p in m["missing_paths"]]
        out.append(f"| {m['file']} | {m['type'] or '?'} | {m['bytes']} | {len(m['dates'])} | {', '.join(problems)} |")

    if r["textual_overlap_pairs"]:
        out += ["", "## Textual overlap (trigram Jaccard; a hint, not a verdict)", ""]
        out += [f"- {p['score']}: {p['a']} ↔ {p['b']}" for p in r["textual_overlap_pairs"]]
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dir", help="memory directory (default: resolve from the current project)")
    ap.add_argument("--project-root", help="root used to check relative paths (default: git root of cwd)")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    cwd = os.getcwd()
    if args.dir:
        memdir, source, root = Path(args.dir).expanduser(), "given by --dir", project_root(cwd)
    else:
        memdir, source, root = resolve_memory_dir(cwd)
    if args.project_root:
        root = Path(args.project_root).expanduser()
    if not memdir.is_dir():
        print(f"memory dir not found: {memdir} ({source})", file=sys.stderr)
        sys.exit(1)

    report = inspect(memdir, root)
    print(json.dumps(report, ensure_ascii=False, indent=2) if args.json else render(report, source))


if __name__ == "__main__":
    main()
