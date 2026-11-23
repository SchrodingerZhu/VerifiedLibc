# Working in this repository

Lean 4 proofs that LLVM libc math functions are correctly rounded. `README.md` covers setup and
extraction; this file records what a contributor, human or agent, needs in order to change proofs
without rediscovering it.

## Build and check

```bash
nix develop            # or `direnv allow`; provides Lean and the numerical tools
lake exe cache get     # prebuilt Mathlib; without it Mathlib is compiled from source
lake build             # must end with "Build completed successfully"
```

- Check one file without building the rest: `lake lean LibcMath/Path/To/File.lean`.
- Warnings about files "designed for use with the module system" come from Mathlib imports and
  are expected.
- To work on a pull request beside the main checkout, use `git worktree add` and link
  `.lake/packages` of the main checkout into it, so that Mathlib is not downloaded again.

## What must stay true

- No `sorry`, no new `axiom`, and no `native_decide` outside files whose name or directory says
  so. Top-level theorems carry a `#guard_msgs in #print axioms …` check (see the end of
  `LibcMath/Exhaustive/Expf.lean`); add one for each new top-level result, so that a regression
  fails the build instead of relying on a claim in a pull request.
- Files named `…Examples.lean` are part of the build. They are the tests: put a small worked case
  there for every new definition that is meant to be evaluated.

## Proof style

- Reuse Mathlib and FloatLib before writing a lemma. Search with `exact?`, `rw?`, or `grep` in
  `.lake/packages/FloatLib` and `.lake/packages/mathlib`. A general fact about rounding belongs in
  FloatLib; keep it here only until it is upstream, and say so in its docstring.
- Make definitions usable by `grind`. Predicates that are thin wrappers (`SameValue`,
  `IR.Val.Encodes`, `HoldsOnBits`) are tagged `@[grind]`, so `grind` unfolds them; characterising
  lemmas of Boolean checks (`checkBits_eq_true_iff`, `checkRange_eq_true_iff`, …) are tagged
  `@[grind =]`. Follow the same pattern for new ones, and try `grind` first on goals about
  ranges, `SameValue` and `Encodes`.
- When `grind` fails, read the goal it prints; that it stalls on an equation between `fun`
  expressions means the definitions involved have to be unfolded by `simp only` first
  (`roundReal_towardZero_of_pos` in `LibcMath/Exhaustive/Modes.lean` is such a case).
- Keep a proof term where it is one line of composition. Search tactics are for finding it.

## When a block check is `false`

Every check of a block of bit patterns is `checkBits test first count`
(`LibcMath/Exhaustive/Range.lean`). Its diagnostic is `firstFailingBits test first count`, and for
`checkRange` there is the shorthand

```lean
#eval checkRange.firstFailure O.check run mode first count   -- `some n`: first failing pattern
```

Then evaluate `run mode (.ofNatBits n)` and `O.check mode (.ofNatBits n) _` to see which side is
at fault. `LibcMath/Exhaustive/ReductionExamples.lean` has a passing block, a failing block and
its diagnosis.

Pass the oracle's test `O.check`, not the oracle: a specification is noncomputable, so a
definition that takes an `Oracle S` as an argument cannot be compiled at a concrete `S`, and
`#eval` on it fails with "depends on 'Spec.exp', which is 'noncomputable'". Evaluation in the
kernel (`decide +kernel`) is not affected.

## Tools that were tried

Record here what was tried and how it went, with the version, so that it is not tried again
blindly. Add to this list; remove an entry when it no longer holds.

- `grind` (Lean 4.36.0): closes the lemmas about `SameValue`, `Encodes` and `HoldsOnBits`,
  including overlapping and out-of-order ranges with numeric ends. Does not close
  `roundReal_towardZero_of_pos`.
- Canonical (`chasenorman/CanonicalLean` v4.36.0, tried 2026-11-23 on x86_64 Linux with the Lean
  of this flake): not usable. Its native library aborts the Lean process ("failed to initiate
  panic, error 3") on every goal it solves, including a propositional one; preloading
  `libgcc_s.so.1` turns the abort into a segmentation fault. On goals that mention a concrete
  format or an extracted function it timed out before reaching that point. It is therefore not a
  dependency. Try again with a later release.
