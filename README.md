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
- `ir2lean` exports one function as a `LibcMath.IR.Func` and rejects anything outside the
  supported fragment.

```bash
extract/extract.sh <llvm-project>/libc expf math::double_eval::expf expf
```

writes `LibcMath/Extracted/Expf.lean`. `LibcMath/IR/Semantics.lean` defines what extracted code
means and lists the assumptions that meaning rests on.
