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
  assembly language and defines a `LibcMath.IR.Func`. The fragment has no `switch`; `ir2lean`
  first replaces each one by conditional branches with LLVM's `lower-switch` pass.

```bash
extract/extract.sh <llvm-project>/libc expf math::double_eval::expf expf
```

writes `LibcMath/Extracted/Expf.lean`. `LibcMath/IR/Semantics.lean` defines what extracted code
means and lists the assumptions that meaning rests on.

## Exhaustive checking

binary32 has `2^32` bit patterns, few enough to examine each one under each rounding direction.
`checkRange O run mode first count` (`LibcMath/Exhaustive/Interface.lean`) runs the implementation
`run` and the oracle `O` on `count` consecutive bit patterns, and the theorems of
`LibcMath/Exhaustive/Reduction.lean` turn `checkRange … = true` for blocks that cover a range into
correctness on that range. The files under `LibcMath/Exhaustive/Run/` and `scripts/exhaustive.py`
establish those equations at scale. `LibcMath/Exhaustive/Run/Target.lean` names the implementation
and the oracle everything else refers to.

A check proceeds in two passes. The first is fast and proves nothing: the compiled program
`checkrange` evaluates blocks and reports which ones pass. The second re-checks the blocks that
passed inside Lean, which is what produces theorems.

```bash
lake build checkrange

# 1. Split a range into blocks. The manifest has one row per block: mode, first, count, status,
#    milliseconds.
scripts/exhaustive.py plan nearest 0x3f800000 0x10000 0x1000 > manifest.tsv

# 2. Evaluate pending blocks with compiled code. Each worker takes one shard and appends to its
#    own result file; a worker that is interrupted and restarted skips the blocks it has finished.
scripts/exhaustive.py run manifest.tsv results-0.tsv --shard 0/8 &
scripts/exhaustive.py run manifest.tsv results-1.tsv --shard 1/8 &
…

# 3. Collect the results. Blocks stay `pending` until some result file reports them, so steps 2
#    and 3 can be repeated until none are left.
scripts/exhaustive.py record manifest.tsv results-*.tsv

# 4. Write Lean certificates for the blocks marked `ok`, and check them.
scripts/exhaustive.py generate manifest.tsv Native Main --batch 16
lake build LibcMath.Exhaustive.Run.Native.Main
```

Workers need no coordination beyond the manifest: shards are disjoint, result files are only
appended to, and `record` may be run at any time. A block marked `fail` is one where the
implementation and the oracle disagree, or where one of them gave up; it gets no certificate and
has to be examined by hand.

`generate` writes one Lean file per batch of consecutive blocks under
`LibcMath/Exhaustive/Run/<method>/<set>/`. Each contains a theorem
`checkRange Run.oracle Run.run mode first count = true` per block and one theorem
`Run.CheckedOn mode lo hi` for the range of the batch. The index
`LibcMath/Exhaustive/Run/<method>/<set>.lean` imports the batches and joins adjacent ones. The
batch files do not depend on one another, so `lake build` checks them in parallel and rebuilds
only what is missing, and several machines can each build part of a set. The method decides
what a certificate rests on:

- `Kernel`: each block is evaluated by Lean's kernel (`decide +kernel`). Nothing is trusted beyond
  the kernel, but evaluation takes about 0.4 s per input, so this suits small ranges only.
- `Native`: each block is proved by `native_decide`, which trusts the Lean compiler and the
  compiled code of the definitions involved. It takes about 0.45 ms per input.

For comparison, `checkrange` takes about 30 µs per input rounding to nearest and 80 µs in the
other directions where `expf` does real work, and under 10 µs elsewhere, on one thread of a 2025
desktop processor: about 70 CPU-hours for all `2^32` inputs in four directions.

Only the set `Demo` of each method is kept in the repository; other generated sets are ignored by
git.

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

Each suite runs in the four rounding modes. It reports the number of inputs compared and the
first inputs where the results differ other than by the choice of a NaN, or where the interpreter
gives no answer, and fails if there are any.

The test is evidence, not proof. It covers the inputs it ran, on the processor it ran on, with
the compiler it was built with; a different processor, compiler version or set of flags (FMA in
particular) needs its own run. It compares results only, so `errno` and the floating-point status
flags are not examined, and neither is the sign or payload of a NaN.

## Conventions and journal

`CLAUDE.md` has the conventions for changing proofs. `journal/` is a
[Forester](https://www.forester-notes.org/) forest of dated changes, lessons, open problems and
sessions; build and browse it with `journal-serve` from the flake shell.
