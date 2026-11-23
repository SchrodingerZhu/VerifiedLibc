#!/usr/bin/env python3
"""Split the exhaustive check of a binary32 function into blocks and certify them in Lean.

A manifest is a tab-separated file with one row per block of consecutive bit patterns:

    check    first    count    status    millis

`check` is nearest, towardZero, up or down for a check of the implementation against the oracle
under that rounding direction, or `towardZero=down` for a check that the implementation returns
the same results rounding toward zero as rounding down; `first` and `count` are decimal; `status` is
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
AGREE = "towardZero=down"
CHECKS = ["nearest", "towardZero", "up", "down", AGREE]
HEADER = ["check", "first", "count", "status", "millis"]

# How a block is proved, by certificate directory. `Native` trusts the Lean compiler.
METHODS = {
    "Kernel": {
        "trust": "Each block is checked by evaluation in Lean's kernel (`decide +kernel`), which "
                 "adds nothing to\nthe trusted base.",
    },
    "Native": {
        "trust": "Each block is checked by `native_decide`: the theorems here trust the Lean "
                 "compiler and the\ncompiled code of every definition the check runs, in "
                 "addition to the kernel.",
    },
}


def lean_forms(check):
    """How certificate files state the block check named `check` and what they conclude from it:
    a label for names, the Boolean term applied to `first count`, the conversion used inside
    `native_decide` proofs, the lemma turning a block into a range, and the range statement."""
    if check == AGREE:
        return ("towardZeroDown", "checkModesAgree run .towardZero .down", "",
                "agreeOn_of_checkModesAgree", "AgreeOn")
    return (check, f"checkRange oracle run .{check}", "checkRange_of_checkBlock ",
            "holdsOnBits_of_checkRange", f"CheckedOn .{check}")


def read_rows(path):
    """The rows of a manifest or result file as (check, first, count, status, millis)."""
    rows = []
    with open(path) as file:
        for line in file:
            fields = line.rstrip("\n").split("\t")
            # A worker killed while writing leaves a partial last line; its block stays pending.
            if fields == HEADER or len(fields) != len(HEADER) or not line.endswith("\n"):
                continue
            check, first, count, status, millis = fields
            rows.append((check, int(first), int(count), status, millis))
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
        rows.append((args.check, first, count, "pending", "-"))
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
                check, first = group[0][0], group[0][1]
                command = [str(args.checkrange), check, str(first), str(count * len(group)),
                           str(count)]
                subprocess.run(command, stdout=results, check=False)


def record(args):
    status = {}
    for path in args.results:
        for check, first, count, state, millis in read_rows(path):
            status[check, first, count] = (state, millis)
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


def range_name(check, lo, hi):
    return f"checked_{lean_forms(check)[0]}_{lo:#010x}_{hi:#010x}"


def range_theorem(check, lo, hi, proof):
    return (f"theorem {range_name(check, lo, hi)} :\n"
            f"    {lean_forms(check)[4]} {lo:#010x} {hi:#010x} :=\n  {proof}\n")


def batch_file(namespace, method, check, blocks):
    label, term, conversion, to_range, _ = lean_forms(check)
    if method == "Kernel":
        proof = " by\n  decide +kernel"
    elif conversion:
        proof = f"\n  {conversion}(by native_decide)"
    else:
        proof = " by\n  native_decide"
    lo, hi = blocks[0][1], blocks[-1][1] + blocks[-1][2]
    lines = [
        "import LibcMath.Exhaustive.Run.Block",
        "import LibcMath.Exhaustive.Run.TowardZero",
        "",
        "/-!",
        f"# Blocks `{check}` {lo:#010x} to {hi:#010x}",
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
        name = f"block_{label}_{first:#010x}_{count}"
        lines += [f"theorem {name} :", f"    {term} {first:#010x} {count} = true :={proof}", ""]
        leaves.append(f"{to_range} {name}")
    lines += [range_theorem(check, lo, hi, balanced(leaves)), f"end {namespace}", ""]
    return "\n".join(lines)


def index_file(namespace, method, name, batches):
    """`batches` is a list of (module, check, lo, hi), in manifest order."""
    lines = [f"import {module}" for module, _, _, _ in batches]
    lines += [
        "",
        "/-!",
        f"# Certificate set `{name}`",
        "",
        "Generated by `scripts/exhaustive.py generate`; do not edit. One theorem for each stretch",
        "of consecutive batches of the set, and rounding toward zero wherever the set has both",
        "rounding down and the agreement of the two directions on the same range.",
        "",
        METHODS[method]["trust"],
        "-/",
        "",
        f"namespace {namespace}",
        "",
    ]
    ranges = set()
    for stretch in consecutive_runs([(check, lo, hi - lo) for _, check, lo, hi in batches]):
        if len(stretch) > 1:
            check, lo, hi = stretch[0][0], stretch[0][1], stretch[-1][1] + stretch[-1][2]
            parts = [range_name(check, first, first + count) for _, first, count in stretch]
            lines.append(range_theorem(check, lo, hi, balanced(parts)))
        ranges.add((stretch[0][0], stretch[0][1], stretch[-1][1] + stretch[-1][2]))
    for check, lo, hi in sorted(ranges):
        if check == AGREE and ("down", lo, hi) in ranges and ("towardZero", lo, hi) not in ranges:
            proof = (f"CheckedOn.towardZero {range_name('down', lo, hi)}\n"
                     f"    {range_name(AGREE, lo, hi)}")
            lines.append(range_theorem("towardZero", lo, hi, proof))
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
            check, lo, hi = blocks[0][0], blocks[0][1], blocks[-1][1] + blocks[-1][2]
            label = lean_forms(check)[0]
            file_name = f"{label[0].upper()}{label[1:]}{lo:08X}"
            (directory / f"{file_name}.lean").write_text(
                batch_file(module, args.method, check, blocks))
            batches.append((f"{module}.{file_name}", check, lo, hi))
    directory.with_suffix(".lean").write_text(index_file(module, args.method, args.name, batches))
    print(f"{len(rows)} blocks in {len(batches)} files; check them with `lake build {module}`",
          file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    commands = parser.add_subparsers(dest="command", required=True)

    command = commands.add_parser("plan", help="print a manifest of pending blocks")
    command.add_argument("check", choices=CHECKS)
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
