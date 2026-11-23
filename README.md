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

Proofs are about the code the compiler produces, not about a transcription by hand. The tools in
`extract/` turn the optimized LLVM IR of a math function into a Lean value:

- `MarkCoreOps` is a clang plugin that keeps a fixed list of libc operations (`extract/CoreOps.cpp`)
  as calls. It changes no code.
- `ir2lean` exports one function and rejects anything outside the supported fragment. Its output
  is a Lean file in the `llvm_func` notation of `LibcMath/IR/DSL.lean`, which follows LLVM's
  assembly language and defines a `LibcMath.IR.Func`.

```bash
extract/extract.sh <llvm-project>/libc expf math::double_eval::expf expf
```

writes `LibcMath/Extracted/Expf.lean`. `LibcMath/IR/Semantics.lean` defines what extracted code
means and lists the assumptions that meaning rests on.

## Testing the model against the machine

The theorems are about the Lean meaning of the extracted IR. That meaning rests on assumptions
about the processor and the tools, listed in `LibcMath/IR/Semantics.lean`, which cannot be proved
in Lean: arithmetic instructions round in the dynamic rounding mode as FloatLib's operations do,
`llvm.fmuladd` is not fused, the rounding-mode queries report the mode set by `fesetround`, and
`ir2lean` and the `llvm_func` notation transcribe the IR faithfully. The differential test checks
their consequences for `expf` by running both sides on the same inputs:

- the Lean side is the interpreter (`Func.runUnary`) on `LibcMath/Extracted/Expf.lean`, built as
  the executable `difftest-expf-model`;
- the native side is `expf.cpp` compiled with the compiler and flags of `extract/extract.sh` and
  called after `fesetround`, once as compiled and once with the `MarkCoreOps` plugin.

```bash
scripts/difftest-expf.sh <llvm-project>/libc quick                      # special values, a minute
scripts/difftest-expf.sh <llvm-project>/libc dense 51                   # 10^7 inputs per mode
scripts/difftest-expf.sh <llvm-project>/libc range 3F800000 3FFFFFFF    # all of [1, 2)
```

Each suite runs in the four rounding modes and fails on the first inputs where the results differ
other than by the choice of a NaN, or where the interpreter gives no answer.

The test is evidence, not proof. It covers the inputs it ran, on the processor it ran on, with
the compiler it was built with; a different processor, compiler version or set of flags (FMA in
particular) needs its own run. It compares results only, so `errno` and the floating-point status
flags are not examined, and neither is the sign or payload of a NaN.
