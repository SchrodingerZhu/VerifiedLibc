#!/usr/bin/env python3
"""Extract LLVM libc binary32 evaluation and microarch plans into Lean 4."""

from __future__ import annotations

import concurrent.futures
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BIN = ROOT / "extract" / "build" / "ast2lean"
COMMIT = "e1a5f92db023"

# Each entry: (family, kernel_dir, cpp_file, lean_fn, plan_mod, variant, flags_kind, target_override)
PLANS: list[tuple[str, str, str, str, str, str, str, str | None]] = [
    # Exponential family
    ("exp", "Expf", "expf", "expf", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("exp", "Expf", "expf", "expf", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("exp", "Exp2f", "exp2f", "exp2f", "DoubleEvalSse2", "double_eval_sse2", "sse2", None),
    ("exp", "Exp2f", "exp2f", "exp2f", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("exp", "Exp2f", "exp2f", "exp2f", "DoubleEvalAvx2Fma", "double_eval_avx2_fma", "avx2_fma", None),
    ("exp", "Exp2f", "exp2f", "exp2f", "FloatEval", "float_eval", "float_eval", None),
    ("exp", "Exp2f", "exp2f", "exp2f", "IntegerEval", "integer_eval", "integer_eval", None),
    ("exp", "Exp2f", "exp2f", "exp2f", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("exp", "Exp10f", "exp10f", "exp10f", "DoubleEvalSse2", "double_eval_sse2", "sse2", None),
    ("exp", "Exp10f", "exp10f", "exp10f", "DoubleEvalSse42", "double_eval_sse42", "sse42", None),
    ("exp", "Exp10f", "exp10f", "exp10f", "DoubleEvalAvx2Fma", "double_eval_avx2_fma", "avx2_fma", None),
    ("exp", "Exp10f", "exp10f", "exp10f", "FloatEval", "float_eval", "float_eval", None),
    ("exp", "Exp10f", "exp10f", "exp10f", "IntegerEval", "integer_eval", "integer_eval", None),
    ("exp", "Exp10f", "exp10f", "exp10f", "DoubleEvalAArch64", "double_eval_aarch64", "aarch64", None),
    ("exp", "Expm1f", "expm1f", "expm1f", "Sse2", "sse2", "sse2", None),
    ("exp", "Expm1f", "expm1f", "expm1f", "Sse42", "sse42", "sse42", None),
    ("exp", "Expm1f", "expm1f", "expm1f", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("exp", "Exp2m1f", "exp2m1f", "exp2m1f", "Sse2", "sse2", "sse2", None),
    ("exp", "Exp2m1f", "exp2m1f", "exp2m1f", "Sse42", "sse42", "sse42", None),
    ("exp", "Exp2m1f", "exp2m1f", "exp2m1f", "Avx2Fma", "avx2_fma", "avx2_fma", None),
    ("exp", "Exp10m1f", "exp10m1f", "exp10m1f", "Sse2", "sse2", "sse2", None),
    ("exp", "Exp10m1f", "exp10m1f", "exp10m1f", "Sse42", "sse42", "sse42", None),
    ("exp", "Exp10m1f", "exp10m1f", "exp10m1f", "Avx2Fma", "avx2_fma", "avx2_fma", None),
]


def flags_for(kind: str, cpp_file: str, rdir: str) -> list[str]:
    upper = cpp_file.upper()
    if kind == "sse2":
        return ["-mno-sse4.2", "-mno-fma"]
    if kind == "ssse3":
        return ["-mssse3", "-mno-sse4.2", "-mno-fma"]
    if kind == "sse42":
        return ["-msse4.2", "-mno-fma"]
    if kind == "avx2_fma":
        return ["-mavx2", "-mfma"]
    if kind == "float_eval":
        return ["-mavx2", "-mfma", f"-DLIBC_MATH_{upper}_IMPL=float_eval", "-DLIBC_MATH=0x3F"]
    if kind == "integer_eval":
        return ["-mno-sse4.2", "-mno-fma", f"-DLIBC_MATH_{upper}_IMPL=integer_eval", "-DLIBC_MATH=0x2C"]
    if kind == "aarch64":
        return ["--target=aarch64-none-elf", "-ffreestanding", "-nostdinc", "-isystem", f"{rdir}/include"]
    if kind == "riscv64":
        return ["--target=riscv64-none-elf", "-march=rv64gc", "-ffreestanding", "-nostdinc", "-isystem", f"{rdir}/include"]
    if kind == "softfloat":
        return ["--target=riscv32-none-elf", "-march=rv32i", "-ffreestanding", "-nostdinc", "-isystem", f"{rdir}/include"]
    raise ValueError(f"unknown flags kind: {kind}")


def run_one(libc: Path, rdir: str, entry: tuple[str, str, str, str, str, str, str, str | None]) -> str:
    _, kdir, cpp_file, lean_fn, plan_mod, variant, fkind, target_override = entry
    src = libc / "src" / "math" / "generic" / f"{cpp_file}.cpp"
    out_dir = ROOT / "LibcMath" / "Kernels" / kdir / "Generated"
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / f"{plan_mod}.lean"
    ns = f"LibcMath.Kernels.{kdir}.Generated.{plan_mod}"
    target = target_override or f"__llvm_libc::{cpp_file}"
    extra = flags_for(fkind, cpp_file, rdir)
    cmd = [
        str(BIN),
        str(src),
        f"--function={target}",
        f"--name={lean_fn}",
        f"--namespace={ns}",
        f"--source-label=src/math/generic/{cpp_file}.cpp",
        f"--source-commit={COMMIT}",
        f"--variant={variant}",
        "--follow-helpers",
        "--drop-effects",
        "--strict",
        "-o",
        str(out),
        "--",
        f"-I{libc}",
        "-std=gnu++17",
        "-DLIBC_NAMESPACE=__llvm_libc",
        "-DLIBC_FULL_BUILD",
        "-DNDEBUG",
        *extra,
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        raise RuntimeError(f"Failed {kdir}.{plan_mod}: {res.stderr.strip()}")
    return f"{kdir}.{plan_mod}"


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: extract_f32_plans.py <llvm-project>/libc [family|all]", file=sys.stderr)
        return 2
    libc = Path(sys.argv[1]).resolve()
    fam = sys.argv[2] if len(sys.argv) >= 3 else "all"
    rdir = subprocess.check_output(["clang++", "-print-resource-dir"], text=True).strip()
    selected = [p for p in PLANS if fam == "all" or p[0] == fam]
    if not selected:
        print(f"error: no plans for family '{fam}'", file=sys.stderr)
        return 2
    with concurrent.futures.ThreadPoolExecutor(max_workers=os.cpu_count() or 8) as ex:
        futs = [ex.submit(run_one, libc, rdir, e) for e in selected]
        done = [f.result() for f in futs]
    print(f"Extracted {len(done)} plans for family '{fam}'.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
