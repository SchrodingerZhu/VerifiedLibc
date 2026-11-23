#!/usr/bin/env python3
"""Split the exhaustive check of a binary32 function into blocks and certify them in Lean.

A manifest is a tab-separated file with one row per block of consecutive bit patterns:

    mode    first    count    status    millis

`mode` is nearest, towardZero, up or down; `first` and `count` are decimal; `status` is
`pending`, `ok` or `fail`; `millis` is the time the compiled check of the block took, or `-`.
The `checkrange` executable prints rows in the same format, so a result file is a manifest of
finished blocks.

    plan      write a manifest of pending blocks covering a range
    run       run `checkrange` on pending blocks and append its output to a result file
    record    copy the statuses in result files into a manifest
    generate  write Lean certificate files for the blocks with status `ok`

A block marked `ok` has only been accepted by compiled code. It is proved by building the Lean
files `generate` writes, which re-check every block inside Lean.
"""

import argparse
import itertools
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
MODES = ["nearest", "towardZero", "up", "down"]
HEADER = ["mode", "first", "count", "status", "millis"]

# How a block is proved, by certificate directory. `Native` trusts the Lean compiler.
METHODS = {
    "Kernel": {
        "proof": " by\n  decide +kernel",
        "trust": "Each block is checked by evaluation in Lean's kernel (`decide +kernel`), which "
                 "adds nothing to\nthe trusted base.",
    },
    "Native": {
        "proof": "\n  checkRange_of_checkBlock (by native_decide)",
        "trust": "Each block is checked by `native_decide`: the theorems here trust the Lean "
                 "compiler and the\ncompiled code of every definition the check runs, in "
                 "addition to the kernel.",
    },
}


def read_rows(path):
    """The rows of a manifest or result file as (mode, first, count, status, millis)."""
    rows = []
    with open(path) as file:
        for line in file:
            fields = line.rstrip("\n").split("\t")
            # A worker killed while writing leaves a partial last line; its block stays pending.
            if fields == HEADER or len(fields) != len(HEADER) or not line.endswith("\n"):
                continue
            mode, first, count, status, millis = fields
            rows.append((mode, int(first), int(count), status, millis))
    return rows


def write_rows(file, rows):
    file.write("\t".join(HEADER) + "\n")
    for row in rows:
        file.write("\t".join(str(field) for field in row) + "\n")


def consecutive_runs(rows):
    """Split rows into maximal runs in which each block starts where the previous one ends."""
    run = []
    for row in rows:
        if run and (run[-1][0], run[-1][1] + run[-1][2]) != (row[0], row[1]):
            yield run
            run = []
        run.append(row)
    if run:
        yield run


def plan(args):
    rows = []
    for first in range(args.first, args.first + args.count, args.block):
        count = min(args.block, args.first + args.count - first)
        rows.append((args.mode, first, count, "pending", "-"))
    write_rows(sys.stdout, rows)


def run(args):
    done = set()
    if args.results.exists():
        done = {row[:3] for row in read_rows(args.results)}
    index, shards = (int(part) for part in args.shard.split("/"))
    todo = [row for position, row in enumerate(read_rows(args.manifest))
            if row[3] == "pending" and position % shards == index and row[:3] not in done]
    with open(args.results, "a") as results:
        for blocks in consecutive_runs(todo):
            # One process per stretch of equal-sized blocks; it prints a row as each finishes.
            for count, group in itertools.groupby(blocks, key=lambda row: row[2]):
                group = list(group)
                mode, first = group[0][0], group[0][1]
                command = [str(args.checkrange), mode, str(first), str(count * len(group)),
                           str(count)]
                subprocess.run(command, stdout=results, check=False)


def record(args):
    status = {}
    for path in args.results:
        for mode, first, count, state, millis in read_rows(path):
            status[mode, first, count] = (state, millis)
    rows = [row[:3] + status.get(row[:3], row[3:]) for row in read_rows(args.manifest)]
    with open(args.manifest, "w") as file:
        write_rows(file, rows)
    for state in ["pending", "ok", "fail"]:
        print(f"{state}\t{sum(row[3] == state for row in rows)}", file=sys.stderr)


def balanced(terms, depth=2):
    """`HoldsOnBits.append` over adjacent ranges, as a tree of logarithmic depth."""
    if len(terms) == 1:
        return terms[0]
    middle, pad = len(terms) // 2, "  " * depth
    return (f"HoldsOnBits.append\n{pad}({balanced(terms[:middle], depth + 1)})"
            f"\n{pad}({balanced(terms[middle:], depth + 1)})")


def range_name(mode, lo, hi):
    return f"checked_{mode}_{lo:#010x}_{hi:#010x}"


def range_theorem(mode, lo, hi, proof):
    return (f"theorem {range_name(mode, lo, hi)} :\n"
            f"    CheckedOn .{mode} {lo:#010x} {hi:#010x} :=\n  {proof}\n")


def batch_file(namespace, method, mode, blocks):
    lo, hi = blocks[0][1], blocks[-1][1] + blocks[-1][2]
    lines = [
        "import LibcMath.Exhaustive.Run.Block",
        "import LibcMath.Exhaustive.Run.Target",
        "",
        "/-!",
        f"# Blocks `{mode}` {lo:#010x} to {hi:#010x}",
        "",
        "Generated by `scripts/exhaustive.py generate`; do not edit.",
        "",
        METHODS[method]["trust"],
        "-/",
        "",
        f"namespace {namespace}",
        "",
        "open LibcMath",
        "",
    ]
    leaves = []
    for _, first, count, _, _ in blocks:
        name = f"block_{mode}_{first:#010x}_{count}"
        lines += [f"theorem {name} :",
                  f"    checkRange oracle run .{mode} {first:#010x} {count} = true :="
                  + METHODS[method]["proof"],
                  ""]
        leaves.append(f"holdsOnBits_of_checkRange {name}")
    lines += [range_theorem(mode, lo, hi, balanced(leaves)), f"end {namespace}", ""]
    return "\n".join(lines)


def index_file(namespace, method, name, batches):
    """`batches` is a list of (module, mode, lo, hi), in manifest order."""
    lines = [f"import {module}" for module, _, _, _ in batches]
    lines += [
        "",
        "/-!",
        f"# Certificate set `{name}`",
        "",
        "Generated by `scripts/exhaustive.py generate`; do not edit. One theorem for each stretch",
        "of consecutive batches of the set.",
        "",
        METHODS[method]["trust"],
        "-/",
        "",
        f"namespace {namespace}",
        "",
    ]
    for stretch in consecutive_runs([(mode, lo, hi - lo) for _, mode, lo, hi in batches]):
        if len(stretch) > 1:
            mode, lo, hi = stretch[0][0], stretch[0][1], stretch[-1][1] + stretch[-1][2]
            parts = [range_name(mode, first, first + count) for _, first, count in stretch]
            lines.append(range_theorem(mode, lo, hi, balanced(parts)))
    lines += [f"end {namespace}", ""]
    return "\n".join(lines)


def generate(args):
    rows = [row for row in read_rows(args.manifest) if row[3] == "ok"]
    module = f"LibcMath.Exhaustive.Run.{args.method}.{args.name}"
    directory = REPO.joinpath(*module.split("."))
    directory.mkdir(parents=True, exist_ok=True)
    batches = []
    for stretch in consecutive_runs(rows):
        for start in range(0, len(stretch), args.batch):
            blocks = stretch[start:start + args.batch]
            mode, lo, hi = blocks[0][0], blocks[0][1], blocks[-1][1] + blocks[-1][2]
            file_name = f"{mode[0].upper()}{mode[1:]}{lo:08X}"
            (directory / f"{file_name}.lean").write_text(
                batch_file(module, args.method, mode, blocks))
            batches.append((f"{module}.{file_name}", mode, lo, hi))
    directory.with_suffix(".lean").write_text(index_file(module, args.method, args.name, batches))
    print(f"{len(rows)} blocks in {len(batches)} files; check them with `lake build {module}`",
          file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    commands = parser.add_subparsers(dest="command", required=True)

    command = commands.add_parser("plan", help="print a manifest of pending blocks")
    command.add_argument("mode", choices=MODES)
    command.add_argument("first", type=lambda text: int(text, 0), help="first bit pattern")
    command.add_argument("count", type=lambda text: int(text, 0), help="number of bit patterns")
    command.add_argument("block", type=lambda text: int(text, 0), help="bit patterns per block")
    command.set_defaults(action=plan)

    command = commands.add_parser("run", help="run checkrange on pending blocks")
    command.add_argument("manifest", type=Path)
    command.add_argument("results", type=Path, help="result file to append to")
    command.add_argument("--shard", default="0/1", metavar="I/N",
                         help="take only the rows whose position is I modulo N")
    command.add_argument("--checkrange", type=Path,
                         default=REPO / ".lake" / "build" / "bin" / "checkrange")
    command.set_defaults(action=run)

    command = commands.add_parser("record", help="copy statuses from result files to a manifest")
    command.add_argument("manifest", type=Path)
    command.add_argument("results", type=Path, nargs="+")
    command.set_defaults(action=record)

    command = commands.add_parser("generate", help="write Lean certificates for the ok blocks")
    command.add_argument("manifest", type=Path)
    command.add_argument("method", choices=METHODS)
    command.add_argument("name", help="name of the certificate set, a Lean identifier")
    command.add_argument("--batch", type=int, default=16, help="blocks per Lean file")
    command.set_defaults(action=generate)

    args = parser.parse_args()
    args.action(args)


if __name__ == "__main__":
    main()
