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

Proofs are about the actual LLVM libc implementations, extracted from the Clang AST of the C++
sources into Lean functions over `LibcMath.Core`. An extracted function returns `Option`: `none`
stands for an execution that reaches an operation C++ leaves undefined (a conversion to an integer
out of range, a table index out of bounds, a shift by the width or more, signed overflow, a
division by zero).

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

## What is proved, and what is open

`expf_correctlyRounded` (`LibcMath/Extracted/Expf/Main.lean`) states that
`math::double_eval::expf` is correctly rounded in the four rounding directions of C and reaches no
operation that C++ leaves undefined. **Its proof is not complete**: it uses two lemmas that end in
`sorry`, and `#print axioms` lists `sorryAx`.

| Inputs | Share | State |
|---|---|---|
| Zeros, infinities, NaNs, `\|x\| ≤ 2⁻²⁶`, overflow, underflow | 87.30 % | proved, by ranges (`Paths/`) |
| `2⁻²⁶ < x < 88.72…` | 6.33 % | open: `Expf.correctAt_main_pos` |
| `-103.97… < x < -2⁻²⁶` | 6.37 % | open: `Expf.correctAt_main_neg` |

The two open lemmas are about the inputs for which the function reads its tables and evaluates
its polynomial. They are to be proved by numerical analysis of that computation; the docstring of
`Main.lean` lists the steps, of which one is done: the polynomial is within `10⁻¹⁵` of the
exponential (`Expf.Poly.abs_poly_sub_exp_le`, in `Polynomial.lean`).

Proofs exist for the plan `double_eval` only. The other five plans are extracted and tested, and
nothing is stated or proved about them.

## Testing a kernel

Tests show whether a statement is true before effort goes into proving it. They are not how a
function is proved correct.

```bash
lake build checkrange
.lake/build/bin/checkrange --plan=double_eval nearest 1065353216 1024 512
.lake/build/bin/checkrange --oracle=mpfr --plan=float_eval nearest 1065353216 64
```

`checkrange` runs a kernel on consecutive bit patterns and asks an oracle whether each result is
the correctly rounded one. A failure is reported on stderr with the input, the result and how the
kernel was configured. `--oracle=lean`, the default, is `expOracle`, which is proved sound in
Lean; `--oracle=mpfr` asks MPFR (`c/mpfr_oracle.c`) and is trusted, with that trust stated as the
axiom `MpfrOracle.mpfrExpf_sameValue` in `LibcMath/Oracle/Mpfr.lean`.

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

`AGENTS.md` has the conventions for changing proofs and running diagnostics. `journal/` is a
[Forester](https://www.forester-notes.org/) forest of dated changes, lessons, open problems,
decisions, and sessions; build and browse it with `journal-serve` from the flake shell.
