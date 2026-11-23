#!/usr/bin/env python3
"""Survey how much of LLVM libc's math library `ir2lean` can export.

    nix develop -c scripts/survey-extraction.py <llvm-project>/libc [entrypoint ...]

Each entrypoint src/math/generic/<entrypoint>.cpp is compiled exactly as extract/extract.sh
compiles it. The function holding the body is exported with `ir2lean`, and the optimized IR of
that function and of the functions it calls is read to list every construct outside the exported
fragment, not only the first one `ir2lean` reports. The result is printed as Markdown tables; the
compiled IR stays in extract/build/survey.

Without entrypoints, the survey covers every `float` and `_Float16` entrypoint and the
double-precision functions in DOUBLE.
"""

import re
import subprocess
import sys
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "extract" / "build"
OUT = BUILD / "survey"
JOBS = 8

DOUBLE = ["exp", "log", "sin", "cos", "pow", "exp2", "log2", "sqrt", "hypot"]

# Mirrors of the lists in extract/CoreOps.cpp and extract/FunctionTranslator.cpp.
CORE_OPS = {
    "fputil::generic::quick_get_round", "fputil::generic::fenv_is_round_up",
    "fputil::generic::fenv_is_round_down", "fputil::generic::fenv_is_round_to_nearest",
    "fputil::generic::fenv_is_round_to_zero", "fputil::set_errno_if_required",
    "fputil::raise_except_if_required", "fputil::raise_overflow_except_if_required",
    "fputil::raise_underflow_except_if_required",
}
OPERATIONS = {
    "add", "sub", "mul", "and", "or", "xor", "shl", "lshr", "ashr", "fadd", "fsub", "fmul",
    "zext", "sext", "trunc", "bitcast", "fpext", "fptrunc", "fptosi",
    "icmp", "fcmp", "select", "fneg", "phi",
}
CASTS = {"fptoui", "uitofp", "sitofp", "ptrtoint", "inttoptr", "addrspacecast"}
INTRINSICS = {"fabs", "fmuladd"}
FAST_MATH = {"nnan", "ninf", "nsz", "arcp", "contract", "afn", "reassoc", "fast"}

# The unit of future work that would make each kind of construct exportable.
GROUPS = [
    (r"type half", "binary16 type"),
    (r"type (x86_fp80|fp128|bfloat)", "other floating-point types"),
    (r"volatile local", "volatile local variables"),
    (r"load from a constant", "tables of other shapes"),
    (r"instruction (alloca|extractvalue|insertvalue)|(load|store) |type (ptr|aggregate)"
     r"|intrinsic llvm\.(lifetime|mem|experimental\.noalias)|ret void"
     r"|operand (null|zeroinitializer|global)", "local memory and aggregates"),
    (r"call ", "calls of other functions"),
    (r"loop", "loops"),
    (r"terminator switch", "switch"),
    (r"terminator unreachable|intrinsic llvm\.assume|operand (undef|poison)|instruction freeze",
     "unreachable, llvm.assume, freeze, poison"),
    (r"instruction (fdiv|frem)", "fdiv"),
    (r"instruction [us](div|rem)", "integer division"),
    (r"cast (sitofp|uitofp|fptoui)", "sitofp, uitofp, fptoui"),
    (r"intrinsic llvm\.(fma|sqrt)\b", "llvm.sqrt"),
    (r"intrinsic llvm\.(rint|nearbyint|floor|ceil|trunc|round|roundeven|lrint|llrint|lround"
     r"|llround)\b", "rounding to an integer"),
    (r"intrinsic llvm\.(copysign|is\.fpclass)\b", "llvm.copysign, llvm.is.fpclass"),
    (r"intrinsic llvm\.(minnum|maxnum|minimum|maximum|minimumnum|maximumnum"
     r"|fptosi\.sat|fptoui\.sat)\b", "other floating-point intrinsics"),
    (r"intrinsic llvm\.(ctlz|cttz|ctpop|umin|umax|smin|smax|abs|bswap|fshl|fshr|usub\.sat"
     r"|uadd\.sat|ssub\.sat|sadd\.sat|[us](add|sub|mul)\.with\.overflow)\b",
     "integer intrinsics"),
    (r"inline assembly|intrinsic llvm\.x86\.sse\.(ld|st)mxcsr",
     "floating-point environment access"),
    (r"type vector|instruction (extractelement|insertelement|shufflevector)|intrinsic llvm\.x86",
     "vectors"),
]


def run(*command):
    return subprocess.run([str(c) for c in command], capture_output=True, text=True)


def relative_name(demangled):
    """The name `ir2lean --function` matches: no libc namespace, parameters or template
    arguments. Same algorithm as `relativeName` in extract/CoreOps.cpp."""
    name, depth = "", 0
    for c in demangled:
        if c == "(" and depth == 0:
            break
        if c == "<":
            depth += 1
        elif c == ">":
            depth -= 1
        elif depth == 0:
            name += c
    name = name.rsplit(" ", 1)[-1]
    return name.split("::", 1)[1] if name.startswith("__llvm_libc") else name


def short_name(demangled):
    """A function's qualified name for the report. Unlike `relative_name` it finds the name from
    the parameter list backwards, so return types such as `enable_if<(sizeof(T) > 8), T>::type`
    do not confuse it."""
    s, depth = demangled.removesuffix(" const"), 0
    for i in range(len(s) - 1, -1, -1):
        depth += (s[i] == ")") - (s[i] == "(")
        if depth == 0:
            break
    s = s[:i]
    for i in range(len(s) - 1, -1, -1):
        depth += (s[i] == ">") - (s[i] == "<")
        if depth == 0 and s[i] == " " and not s[:i].endswith("operator"):
            s = s[i + 1:]
            break
    while (stripped := re.sub(r"<[^<>]*>", "", s)) != s:
        s = stripped
    return s.removeprefix("__llvm_libc::")


class Function:
    def __init__(self, symbol, header):
        self.symbol, self.header = symbol, header
        self.blocks = [[]]  # instruction lines; a `switch` is joined into one line
        self.labels = ["entry"]
        self.demangled = self.relative = None


class Module:
    def __init__(self, path):
        self.functions, self.declared, self.globals = {}, set(), {}
        current = None
        for line in Path(path).read_text().splitlines():
            if current is None:
                if m := re.match(r"define .*?@([\w.$]+|\"[^\"]+\")\(", line):
                    current = Function(m[1].strip('"'), line)
                    self.functions[current.symbol] = current
                elif m := re.match(r"declare .*?@([\w.$]+)\(", line):
                    self.declared.add(m[1])
                elif m := re.match(r"@([\w.$]+) = .*?\b(constant|global) (\[\d+ x (\w+)\] [\[c])?",
                                   line):
                    # The element type of a constant array of numbers; None for other globals.
                    self.globals[m[1]] = m[4] if m[2] == "constant" else None
            elif line == "}":
                current = None
            elif m := re.match(r"([\w.$-]+):", line):
                if current.blocks[-1]:
                    current.blocks.append([])
                    current.labels.append(m[1])
                else:
                    current.labels[-1] = m[1]
            elif current.blocks[-1] and re.match(r"switch .*\[[^\]]*$", current.blocks[-1][-1]):
                current.blocks[-1][-1] += " " + line.strip()  # the cases of a `switch`
            elif line.strip() and not line.lstrip().startswith(";"):
                current.blocks[-1].append(line.strip())
        symbols = list(self.functions) + sorted(self.declared) + list(self.globals)
        demangled = run("llvm-cxxfilt", *symbols).stdout.splitlines()
        self.names = dict(zip(symbols, demangled))
        for f in self.functions.values():
            f.demangled = self.names[f.symbol]
            f.relative = relative_name(f.demangled)

    def callee(self, line):
        m = re.search(r"\bcall\b.*?@([\w.$]+|\"[^\"]+\")\(", line)
        return m[1].strip('"') if m else None


def opcode(line):
    words = re.sub(r"^%[\w.$-]+ = ", "", line).split()
    return words[1] if words[0] in ("tail", "musttail", "notail") else words[0]


def has_loop(f):
    successors = {
        label: re.findall(r"label %([\w.$-]+)", block[-1])
        for label, block in zip(f.labels, f.blocks)
    }
    state = {}

    def visit(label):
        state[label] = "open"
        for s in successors[label]:
            if state.get(s) == "open" or (s not in state and visit(s)):
                return True
        state[label] = "done"
        return False

    return visit(f.labels[0])


def size(type_name):
    """Size in bytes of a number type or an array of them, None for other types."""
    if m := re.fullmatch(r"\[(\d+) x (.+)\]", type_name):
        return int(m[1]) * size(m[2]) if size(m[2]) else None
    if m := re.fullmatch(r"i(\d+)", type_name):
        return (int(m[1]) + 7) // 8
    return {"half": 2, "float": 4, "double": 8}.get(type_name)


def types_in(text):
    found = set()
    for pattern, name in [
        (r"\bhalf\b", "half"), (r"\bbfloat\b", "bfloat"), (r"\bx86_fp80\b", "x86_fp80"),
        (r"\bfp128\b", "fp128"), (r"<\d+ x ", "vector"), (r"\bptr\b", "ptr"),
        (r"%\"?(struct|class|union)|(^| )\{ |\[\d+ x ", "aggregate"),
    ]:
        if re.search(pattern, text):
            found.add("type " + name)
    return found


def analyse(module, f):
    """Constructs of `f` that ir2lean rejects, fast-math flags, constants read and callees."""
    unsupported, flags, tables, callees = Counter(), set(), set(), []
    definitions = {
        m[1]: line for block in f.blocks for line in block
        if (m := re.match(r"(%[\w.$-]+) = ", line))
    }

    def table_address(pointer):
        """The table and element type a GEP addresses, if it has the form ir2lean accepts: one
        index into a constant array of numbers, counted in units of the size of an element."""
        m = re.match(r"%[\w.$-]+ = getelementptr (?:inbounds |nuw |nusw )*(.+?), ptr @([\w.$]+), "
                     r"i\d+ %?[\w.$-]+$", definitions.get(pointer, ""))
        element = m and module.globals.get(m[2])
        return (m[2], element) if element and size(m[1]) == size(element) else (None, None)

    def origin(pointer):
        """What a pointer points into, looking through GEPs."""
        while m := re.match(r"%[\w.$-]+ = getelementptr [^@%]*, ptr ([@%][\w.$-]+)",
                            definitions.get(pointer, "")):
            pointer = m[1]
        if pointer.startswith("@"):
            tables.add(pointer[1:] + " (not in table form)")
            return "a constant not in table form"
        if " = alloca " in definitions.get(pointer, ""):
            return "a local variable"
        return "a pointer parameter" if pointer not in definitions else "a computed pointer"

    def uses(name):
        return [line for block in f.blocks for line in block
                if re.search(re.escape(name) + r"\b", line.split(" = ", 1)[-1])]

    # Locals that are only read and written with volatile accesses; libc uses them to force an
    # operation to happen at run time, as in `fputil::round_result_slightly_up`.
    volatile = {
        name for name, line in definitions.items() if " = alloca " in line
        and all(re.search(r"(load|store) volatile|@llvm\.lifetime", use) for use in uses(name))
    }

    parameters = f.header[f.header.index("("):f.header.rindex(")")]
    unsupported.update(types_in(parameters))
    if has_loop(f):
        unsupported["loop"] += 1
    for block in f.blocks:
        for line in block:
            op = opcode(line)
            body = re.sub(r", ![\w.]+ !\d+", "", line)
            if any(re.search(re.escape(name) + r"\b", body) for name in volatile):
                unsupported["volatile local variable"] += op == "alloca"
                continue
            if op in ("load", "store"):
                m = re.search(r"(load|store) (volatile )?(.+?), ptr ([@%][\w.$-]+)", body)
                table, element = table_address(m[4])
                if op == "load" and table and not m[2] and element == m[3]:
                    tables.add(table)
                else:
                    unsupported[f"{op} {'from' if op == 'load' else 'to'} {origin(m[4])}"] += 1
                    if op == "load":
                        unsupported.update(types_in(m[3]) - {"type ptr"})
                continue
            if op == "getelementptr":
                continue  # reported with the instructions that use the address
            if op in ("alloca", "extractvalue", "insertvalue"):
                unsupported["instruction " + op] += 1
                continue
            if op == "call":
                symbol = module.callee(body)
                if symbol is None:
                    unsupported["inline assembly" if " asm " in body else "indirect call"] += 1
                    continue
                elif symbol.startswith("llvm."):
                    name = re.sub(r"\.(f\d+|i\d+|p0|v\d+\w+)+$", "", symbol)
                    if name.removeprefix("llvm.") not in INTRINSICS:
                        unsupported["intrinsic " + name] += 1
                        continue
                else:
                    if relative_name(module.names[symbol]) not in CORE_OPS:
                        unsupported["call " + short_name(module.names[symbol])] += 1
                        callees.append(symbol)
                        continue
                unsupported.update(types_in(re.sub(r"\(.*", "", body)))  # the result type
            elif op in ("ret", "br"):
                if body == "ret void":
                    unsupported["ret void"] += 1
            elif op in ("switch", "unreachable", "invoke", "indirectbr", "resume"):
                unsupported["terminator " + op] += 1
            elif op in CASTS:
                unsupported["cast " + op] += 1
            elif op not in OPERATIONS:
                unsupported["instruction " + op] += 1
            unsupported.update(types_in(body))
            if m := re.search(r"\b(undef|poison|null|zeroinitializer)\b", body):
                unsupported["operand " + m[1]] += 1
            elif op != "call" and re.search(r"[ (]@", body):
                unsupported["operand global"] += 1
            flags.update(w for w in body.split() if w in FAST_MATH)
    names = {short_name(module.names.get(t.split()[0], t) + "()") + t[len(t.split()[0]):]
             for t in tables}
    return unsupported, flags, names, callees


def survey(libc, entrypoint):
    ll = OUT / f"{entrypoint}.ll"
    compiled = run(
        "clang++", "-std=gnu++17", "-O3", "-fno-vectorize", "-fno-slp-vectorize",
        "-I", libc, "-DLIBC_NAMESPACE=__llvm_libc", f"-fpass-plugin={BUILD}/MarkCoreOps.so",
        "-S", "-emit-llvm", "-o", ll, f"{libc}/src/math/generic/{entrypoint}.cpp")
    if compiled.returncode != 0:
        return {"entrypoint": entrypoint, "error": compiled.stderr.strip().splitlines()[0]}
    module = Module(ll)
    entry = next((f for f in module.functions.values() if f.relative == entrypoint), None)
    if entry is None:
        return {"entrypoint": entrypoint, "error": "the module does not define the entrypoint"}

    # A wrapper is a single block that only forwards to one function defined in the module.
    body = entry
    while len(body.blocks) == 1 and len(body.blocks[0]) <= 3:
        calls = [module.callee(line) for line in body.blocks[0] if opcode(line) == "call"]
        if len(calls) != 1 or calls[0] not in module.functions:
            break
        if module.functions[calls[0]].relative in CORE_OPS:
            break
        body = module.functions[calls[0]]

    unsupported, flags, tables, callees = analyse(module, body)
    # Functions reachable through calls, and what they would need in turn.
    reached, pending, in_callees = [], list(callees), Counter()
    while pending:
        symbol = pending.pop()
        if symbol in reached or symbol == body.symbol or symbol not in module.functions:
            continue
        reached.append(symbol)
        more, callee_flags, callee_tables, callee_calls = analyse(module, module.functions[symbol])
        in_callees.update(more)
        flags |= callee_flags
        tables |= callee_tables
        pending += callee_calls

    exported = run(BUILD / "ir2lean", ll, f"--function={body.relative}", f"--name={entrypoint}")
    first = ""
    if exported.returncode != 0:
        first = exported.stderr.strip().splitlines()[0].removeprefix("ir2lean: unsupported ")
    if (exported.returncode == 0) != (not unsupported - Counter(["loop"])):
        print(f"warning: {entrypoint}: ir2lean and this script disagree", file=sys.stderr)
    same_name = [f for f in module.functions.values() if f.relative == body.relative]
    return {
        "entrypoint": entrypoint,
        "signature": entry.demangled.removeprefix("__llvm_libc::"),
        "body": short_name(body.demangled),
        "ambiguous": same_name[0] is not body,
        "extracts": exported.returncode == 0,
        "first": first,
        "blocks": len(body.blocks),
        "instructions": sum(map(len, body.blocks)),
        "callee_instructions": sum(
            len(b) for s in reached for b in module.functions[s].blocks),
        "unsupported": unsupported,
        "in_callees": in_callees,
        "flags": flags,
        "tables": tables,
    }


def groups(constructs):
    found = {next((g for pattern, g in GROUPS if re.match(pattern, c)), c) for c in constructs}
    order = [g for _, g in GROUPS]
    return sorted(found, key=lambda g: order.index(g) if g in order else len(order))


def cell(text):
    return str(text).replace("|", "\\|")


def counted(constructs):
    return ", ".join(f"{c} ({n})" for c, n in sorted(constructs.items()))


def print_table(title, rows):
    print(f"\n### {title}\n")
    print("| Entrypoint | Body function | Exports | Blocks / instructions | Loop | "
          "First construct `ir2lean` rejects | Missing groups |")
    print("|---|---|---|---|---|---|---|")
    for r in rows:
        if "error" in r:
            print(f"| `{r['entrypoint']}` | | not compiled | | | {cell(r['error'])} | |")
            continue
        size = f"{r['blocks']} / {r['instructions']}"
        if r["callee_instructions"]:
            size += f" (+{r['callee_instructions']})"
        body = f"`{r['body']}`" + (" (not selectable by name)" if r["ambiguous"] else "")
        first = f"`{cell(' '.join(r['first'].split())[:70])}`" if r["first"] else ""
        print(f"| `{cell(r['signature'])}` | {body} | {'yes' if r['extracts'] else 'no'} | {size} "
              f"| {'yes' if 'loop' in r['unsupported'] else 'no'} | {first} "
              f"| {cell(', '.join(groups(r['unsupported'] + r['in_callees'])))} |")


def main():
    libc = Path(sys.argv[1]).resolve()
    entrypoints = sys.argv[2:]
    if not entrypoints:
        sources = sorted(p.stem for p in (libc / "src/math/generic").glob("*.cpp"))
        # `modf` is the double-precision function; bfloat16 is not surveyed.
        entrypoints = [s for s in sources
                       if re.search(r"(f|f16)$", s) and "bf16" not in s and s != "modf"]
        entrypoints += DOUBLE
    subprocess.run(["cmake", "-S", ROOT / "extract", "-B", BUILD, "-G", "Ninja",
                    "-DCMAKE_BUILD_TYPE=Release"], check=True, stdout=subprocess.DEVNULL)
    subprocess.run(["ninja", "--quiet", "-C", BUILD], check=True)
    OUT.mkdir(exist_ok=True)
    with ThreadPoolExecutor(JOBS) as pool:
        rows = list(pool.map(lambda e: survey(libc, e), entrypoints))

    half = [r for r in rows if r["entrypoint"].endswith("f16")]
    double = [r for r in rows if r["entrypoint"] in DOUBLE]
    single = [r for r in rows if r not in half and r not in double]
    parts = (single, half, double)
    print_table("Single precision", single)
    print_table("Half precision", half)
    print_table("Double precision", double)

    def census(title, heading, keep):
        print(f"\n### {title}\n\n| {heading} | Single | Half | Double |\n|---|---|---|---|")
        seen = {}
        for column, part in enumerate(parts):
            for r in part:
                for c in set(r.get("unsupported", {})) | set(r.get("in_callees", {})):
                    if keep(c):
                        seen.setdefault(c, [0, 0, 0])[column] += 1
        for c, counts in sorted(seen.items(), key=lambda item: (-sum(item[1]), item[0])):
            print(f"| {cell(c.removeprefix('call '))} | {counts[0]} | {counts[1]} | {counts[2]} |")

    census("Entrypoints using each construct", "Construct", lambda c: not c.startswith("call "))
    census("Entrypoints calling each function", "Function", lambda c: c.startswith("call "))

    # Order the groups so that each step makes as many further entrypoints exportable as
    # possible, preferring the group that blocks more entrypoints when steps are equal.
    needs = {r["entrypoint"]: set(groups(r["unsupported"] + r["in_callees"]))
             for r in rows if "error" not in r}
    print("\n### Groups, in the order that makes entrypoints exportable soonest\n")
    print("| Group | Blocks: single | half | double | Becoming exportable at this step "
          "| Exportable so far |")
    print("|---|---|---|---|---|---|")
    done, remaining = set(), set().union(*needs.values())
    while remaining:
        def gain(group):
            return (sum(bool(n - done) and n <= done | {group} for n in needs.values()),
                    sum(group in n for n in needs.values()), group)
        group = max(remaining, key=gain)
        new = [e for e, n in needs.items() if group in n and n <= done | {group}]
        done.add(group)
        remaining.remove(group)
        blocked = [sum(group in needs.get(r["entrypoint"], ()) for r in part) for part in parts]
        print(f"| {group} | {blocked[0]} | {blocked[1]} | {blocked[2]} | {cell(', '.join(new))} "
              f"| {sum(n <= done for n in needs.values())} of {len(needs)} |")

    print("\n### Constructs outside the fragment, per entrypoint\n")
    print("Counts are numbers of instructions. Constructs after the semicolon are in functions "
          "the body calls.\n")
    for r in rows:
        if "error" in r or r["extracts"] and not r["tables"]:
            continue
        detail = counted(r["unsupported"])
        if r["in_callees"]:
            detail += "; " + counted(r["in_callees"])
        if r["flags"]:
            detail += ". Fast-math flags: " + " ".join(sorted(r["flags"]))
        if r["tables"]:
            detail += ". Constants read: " + ", ".join(sorted(r["tables"]))
        print(f"- `{r['entrypoint']}`: {detail.lstrip('. ')}")


if __name__ == "__main__":
    main()
