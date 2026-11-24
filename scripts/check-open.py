#!/usr/bin/env python3
"""Check or regenerate OPEN.md from every `sorry` in LibcMath/.

Usage:
    python3 scripts/check-open.py          # fail if OPEN.md differs or docstring lacks **Open.**
    python3 scripts/check-open.py --update # write OPEN.md
"""

from __future__ import annotations

import difflib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LIB_DIR = ROOT / "LibcMath"
OPEN_MD = ROOT / "OPEN.md"

DECL_RE = re.compile(
    r"^(?:(?:private|protected|noncomputable|unsafe|partial)\s+)*"
    r"(?:theorem|lemma|def|abbrev|instance|example)\s+([^\s:({\[<]+)"
)
SORRY_WORD_RE = re.compile(r"\bsorry\b")


def strip_comments_and_strings(text: str) -> str:
    """Replace comments and string literals with spaces while preserving line breaks."""
    out: list[str] = []
    i = 0
    n = len(text)
    block_depth = 0
    in_string = False
    while i < n:
        ch = text[i]
        nxt = text[i + 1] if i + 1 < n else ""
        if block_depth > 0:
            if ch == "/" and nxt == "-":
                block_depth += 1
                out.append("  ")
                i += 2
            elif ch == "-" and nxt == "/":
                block_depth -= 1
                out.append("  ")
                i += 2
            elif ch == "\n":
                out.append("\n")
                i += 1
            else:
                out.append(" ")
                i += 1
        elif in_string:
            if ch == "\\" and i + 1 < n:
                out.append("  " if nxt != "\n" else " \n")
                i += 2
            elif ch == '"':
                in_string = False
                out.append(" ")
                i += 1
            elif ch == "\n":
                out.append("\n")
                i += 1
            else:
                out.append(" ")
                i += 1
        else:
            if ch == "-" and nxt == "-":
                while i < n and text[i] != "\n":
                    out.append(" ")
                    i += 1
            elif ch == "/" and nxt == "-":
                block_depth = 1
                out.append("  ")
                i += 2
            elif ch == '"':
                in_string = True
                out.append(" ")
                i += 1
            else:
                out.append(ch)
                i += 1
    return "".join(out)


def extract_docstrings(raw_lines: list[str]) -> dict[int, str]:
    """Map the 0-based line index of a declaration to its `/-- ... -/` docstring."""
    docs: dict[int, str] = {}
    i = 0
    n = len(raw_lines)
    while i < n:
        stripped = raw_lines[i].lstrip()
        if stripped.startswith("/--"):
            buf = [stripped[3:]]
            j = i
            while "-/" not in buf[-1] and j + 1 < n:
                j += 1
                buf.append(raw_lines[j])
            joined = "\n".join(buf)
            doc_body = joined.split("-/", 1)[0].strip()
            k = j + 1
            while k < n and (
                raw_lines[k].strip() == "" or raw_lines[k].lstrip().startswith("@[")
            ):
                k += 1
            docs[k] = doc_body
            i = j + 1
        else:
            i += 1
    return docs


def summarize_doc(doc: str) -> str:
    """Return the first paragraph of a docstring, joined onto a single line."""
    para_lines: list[str] = []
    for line in doc.splitlines():
        s = line.strip()
        if not s:
            if para_lines:
                break
            continue
        para_lines.append(s)
    return " ".join(para_lines)


def scan_file(path: Path) -> tuple[list[tuple[str, str, str]], list[str]]:
    """Return (entries, errors) where entries are (rel_path, decl_name, summary)."""
    raw_text = path.read_text(encoding="utf-8")
    if "sorry" not in raw_text:
        return [], []
    raw_lines = raw_text.splitlines()
    code_lines = strip_comments_and_strings(raw_text).splitlines()
    docs = extract_docstrings(raw_lines)

    rel = path.relative_to(ROOT).as_posix()
    entries: list[tuple[str, str, str]] = []
    errors: list[str] = []

    current_decl: str | None = None
    current_decl_line: int = -1
    recorded_for_decl = False

    for idx, code_line in enumerate(code_lines):
        m = DECL_RE.match(code_line.lstrip())
        if m and not code_line.startswith(" "):
            current_decl = m.group(1)
            current_decl_line = idx
            recorded_for_decl = False

        if SORRY_WORD_RE.search(code_line):
            if current_decl is None:
                errors.append(f"{rel}:{idx + 1}: `sorry` outside any top-level declaration")
                continue
            if recorded_for_decl:
                continue
            recorded_for_decl = True
            doc = docs.get(current_decl_line, "")
            summary = summarize_doc(doc)
            if not summary.startswith("**Open.**"):
                errors.append(
                    f"{rel}:{current_decl_line + 1}: open declaration `{current_decl}` "
                    f"must have a `/-- **Open.** ... -/` docstring"
                )
            entries.append((rel, current_decl, summary))

    return entries, errors


def render_open_md(entries: list[tuple[str, str, str]]) -> str:
    lines = [
        "# Open proof obligations",
        "",
        "Generated from every `sorry` under `LibcMath/` by `scripts/check-open.py`.",
        "Do not edit by hand; run `python3 scripts/check-open.py --update` after changing",
        "the open lemmas.",
        "",
    ]
    if not entries:
        lines.append("There are currently no open `sorry` obligations under `LibcMath/`.")
        lines.append("")
    else:
        lines.append(f"Total open obligations: **{len(entries)}**.")
        lines.append("")
        lines.append("| File | Lemma | Summary |")
        lines.append("|---|---|---|")
        for rel, decl, summary in entries:
            safe_doc = summary.replace("|", "\\|")
            lines.append(f"| `{rel}` | `{decl}` | {safe_doc} |")
        lines.append("")
    return "\n".join(lines)


def main(argv: list[str]) -> int:
    update = "--update" in argv
    all_entries: list[tuple[str, str, str]] = []
    all_errors: list[str] = []

    for path in sorted(LIB_DIR.rglob("*.lean")):
        entries, errors = scan_file(path)
        all_entries.extend(entries)
        all_errors.extend(errors)

    if all_errors:
        for err in all_errors:
            print(f"error: {err}", file=sys.stderr)
        return 1

    expected = render_open_md(all_entries)
    if update:
        OPEN_MD.write_text(expected, encoding="utf-8")
        print(f"Updated {OPEN_MD.relative_to(ROOT)} ({len(all_entries)} open obligations).")
        return 0

    if not OPEN_MD.exists():
        print(
            f"error: {OPEN_MD.relative_to(ROOT)} does not exist; run with --update",
            file=sys.stderr,
        )
        return 1

    actual = OPEN_MD.read_text(encoding="utf-8")
    if actual != expected:
        diff = difflib.unified_diff(
            actual.splitlines(keepends=True),
            expected.splitlines(keepends=True),
            fromfile="OPEN.md (checked in)",
            tofile="OPEN.md (expected)",
        )
        sys.stderr.writelines(diff)
        print(
            "error: OPEN.md is out of date; run `python3 scripts/check-open.py --update`",
            file=sys.stderr,
        )
        return 1

    print(f"OPEN.md is up to date ({len(all_entries)} open obligations).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
