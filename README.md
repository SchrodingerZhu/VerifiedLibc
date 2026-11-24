# VerifiedLibc

Lean 4 proofs that LLVM libc math functions are correctly rounded.

## Setup

The development environment is a Nix flake. It provides Lean 4.36.0 (the official release,
including its bundled C compiler) and the numerical tools used alongside the proofs: Sollya,
Gappa, MPFR, MPFI, and the CaDiCaL, Z3, cvc5 and Bitwuzla solvers.

```bash
nix develop          # or `direnv allow`
lake exe cache get   # prebuilt Mathlib
lake build
```

Lean dependencies are pinned in `lake-manifest.json`:

- [Mathlib](https://github.com/leanprover-community/mathlib4) v4.36.0, for real analysis.
- [FloatLib](https://github.com/lean-dojo/FloatLib) v4.1.0, for IEEE 754 formats, rounding
  theorems and numerical proof automation.

## Changing the Lean version

The Lean version appears in `lean-toolchain` and in `flake.nix` (`leanVersion` and
`leanHashes`); the two must agree. Obtain the hash of a new release with

```bash
nix store prefetch-file https://github.com/leanprover/lean4/releases/download/v<version>/lean-<version>-linux.tar.zst
```

Mathlib and FloatLib each target one Lean release, so move all three together.

## Extracting functions from LLVM libc

Proofs are about the actual LLVM libc implementations, extracted directly from the C++ Clang AST
into high-level functional Lean models targeting `LibcMath.Core` (no low-level LLVM-IR CFG
interpreter or relational bridge):

- `extract/` contains **`ast2lean`**, a C++23 module-first (`.cppm`) Clang LibTooling extractor.
- `ast2lean` snapshots active preprocessor flags (`LIBC_MATH_HAS_*`, `LIBC_TARGET_CPU_HAS_*`,
  `LIBC_TYPES_HAS_INT128`, target triple, implementation variant) into a `Core.MathConfig` and
  `Core.KernelMeta` record alongside a `Core.UnaryKernel` bundle.
- `LibcMath/Core/` defines the shared LLVM libc kernel vocabulary backed by FloatLib: `FPBits`,
  config-aware `multiplyAdd`/`multiplySub`/`subMultiply`, `nearestInt`, `setOverflow`/
  `setUnderflow`, `Frac64`, `NumberPair` (`FloatFloat`/`DoubleDouble`), `TripleDouble`,
  `DyadicFloat`, `ExceptValues`, polymorphic `horner`/`althorner`/`estrin` polynomial DSL
  (`LibcMath.Core.DSL`), and agent-friendly diagnostics (`LibcMath.Core.Diag`).

```bash
# Extract a single function
extract/extract.sh <llvm-project>/libc expf math::double_eval::expf expf \
  --namespace=LibcMath.Extracted.Expf.DoubleEval \
  --out=LibcMath/Extracted/Expf/DoubleEval.lean

# Inspect active LIBC_MATH / target CPU macros without emitting Lean
./extract/build/ast2lean <llvm-project>/libc/src/math/generic/expf.cpp \
  --function=math::double_eval::expf --dump-config \
  -- -std=gnu++17 -mavx2 -mfma -I <llvm-project>/libc -DLIBC_NAMESPACE=__llvm_libc

# Regenerate all six extracted `expf` evaluation plans under LibcMath/Extracted/Expf/
extract/extract-expf-plans.sh <llvm-project>/libc
```

The six extracted `expf` evaluation plans under `LibcMath/Extracted/Expf/` are:

- `DoubleEval`: default x86-64 double-precision table+Horner (`LIBC_MATH=0`, 4 modes, CR)
- `DoubleEvalFma`: `double_eval` with `-mavx2 -mfma` (hardware FMA + `nearest_integer`, 4 modes, CR)
- `IntegerEval`: pure integer `Frac64` (`LIBC_MATH_EXPF_IMPL=integer_eval`, `LIBC_MATH=0x2C`, RN, CR)
- `StaticRounding`: 4-mode pure integer `Frac64` (`math::static_rounding::expf`, `LIBC_MATH=0x0C`, 4 modes, CR)
- `FloatEval`: fast single-precision Estrin+Horner (`LIBC_MATH=0x3F`, RN, ~1 ULP)
- `FloatEvalCrRn`: GPU `FloatFloat` FMA (`LIBC_MATH=0x3E`, RN, CR)

## Exhaustive checking

binary32 has `2^32` bit patterns, few enough to examine each one under each rounding direction.
`LibcMath/Extracted/ExpfMain.lean` analytically discharges 87.30% of all inputs for `DoubleEval` /
`DoubleEvalFma` (leaving `545,350,603` inputs per mode) and 87.69% for `StaticRounding` /
`IntegerEval` (leaving `528,573,389` inputs per mode), with zero open bridge hypotheses.

`checkRange O impl mode first count` (`LibcMath/Exhaustive/Interface.lean`) runs any total
implementation `impl` and a sound oracle `O` on `count` consecutive bit patterns via `checkBits`,
and `LibcMath/Exhaustive/Reduction.lean` turns `checkRange … = true` directly into
`CorrectlyRounded`. The files under `LibcMath/Exhaustive/Run/` and `scripts/exhaustive.py` scale
this across blocks.

```bash
lake build checkrange

# Optional: inspect any extracted expf plan directly (stderr prints detailed failure diagnostics)
.lake/build/bin/checkrange --plan=double_eval nearest 1065353216 1024 512
.lake/build/bin/checkrange --plan=integer_eval nearest 1065353216 1024 512

# 1. Split a range into blocks.
scripts/exhaustive.py plan nearest 0x3f800000 0x10000 0x1000 > manifest.tsv

# 2. Evaluate pending blocks with compiled code across shards.
scripts/exhaustive.py run manifest.tsv results-0.tsv --shard 0/8 &
scripts/exhaustive.py run manifest.tsv results-1.tsv --shard 1/8 &
…

# 3. Collect the results into the manifest.
scripts/exhaustive.py record manifest.tsv results-*.tsv

# 4. Write Lean certificates for `ok` blocks and verify them in Lean.
scripts/exhaustive.py generate manifest.tsv Native Main --batch 16
lake build LibcMath.Exhaustive.Run.Native.Main
```

Certificate methods:

- `Kernel`: each block is checked inside Lean's kernel (`decide +kernel`). Nothing is trusted
  beyond the kernel. With direct AST-extracted kernels (no CFG interpreter), `Kernel/Demo`
  checks 32 inputs in ~4.6 s wall time (~3.6 s user, including Lean startup), >70× faster than
  the legacy IR interpreter.
- `Native`: each block is proved by `native_decide`, trusting the Lean compiler and compiled code.

Compiled `checkrange` checks 512 inputs in 4–8 ms per thread (~64,000–128,000 inputs/s). Only the
`Demo` certificate sets are kept in git.

## Testing extracted models against compiled machine code

Differential testing checks that each AST-extracted Lean kernel agrees bit-for-bit (up to NaN)
with `expf.cpp` compiled by Clang with the matching `LIBC_MATH` and CPU flags:

```bash
scripts/difftest-expf.sh <llvm-project>/libc quick
scripts/difftest-expf.sh --plan=double_eval_fma <llvm-project>/libc quick
scripts/difftest-expf.sh --plan=integer_eval <llvm-project>/libc quick
scripts/difftest-expf.sh --plan=float_eval <llvm-project>/libc quick
scripts/difftest-expf.sh --plan=float_eval_cr_rn <llvm-project>/libc quick
scripts/difftest-expf.sh <llvm-project>/libc dense 51
scripts/difftest-expf.sh <llvm-project>/libc range 3F800000 3FFFFFFF
```

`double_eval` and `double_eval_fma` test all four IEEE rounding modes (`nearest`, `up`, `down`,
`zero`); RN-only plans test `nearest`.

## Conventions and journal

`CLAUDE.md` has the conventions for changing proofs and running diagnostics. `journal/` is a
[Forester](https://www.forester-notes.org/) forest of dated changes, lessons, open problems,
decisions, and sessions; build and browse it with `journal-serve` from the flake shell.
