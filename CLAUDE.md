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

## When the interpreter answers `none`

`Func.exec`, `Func.run` and `Func.runUnary` (`LibcMath/IR/Interp.lean`) answer `none` when the
interpreter gives up, which does not mean that the function has no result. Ask why:

```lean
#eval IO.println (f.explain mode [.ofModel x])          -- first step without an answer
#eval IO.println (f.explainFloat fmt mode [.ofModel x]) -- also: answer of the wrong width
```

The report names the block, the register and the kind of instruction, and lists the registers
that are not known exactly (a NaN from arithmetic, or the result of `raiseExcept`).
`LibcMath/IR/InterpExamples.lean` has a case. `LibcMath/IR/InterpDiag.lean` follows
`Func.execFrom` step by step; when the interpreter changes, change it too, and the examples will
show whether the reports still hold.

## The journal

`journal/` is a [Forester](https://www.forester-notes.org/) forest: small notes ("trees") with
permanent addresses that link to each other. Changes, lessons, open problems, decisions and
sessions are recorded there, in the same branch as the change they describe. Write there as part
of the work, without asking first. Before starting, read `journal/trees/insights.tree` and
`journal/trees/open-problems.tree` and the trees they list (`rg -l 'taxon{Insight}' journal/trees`),
so that a tool or an approach that already failed is not tried again blindly.

```sh
journal-new <log|insight|problem|decision|session>   # allocate an address, create the file
journal-build                                        # must report no diagnostics
journal-serve                                        # browse at http://localhost:1313/
```

Outside the flake shell: `nix run .#new -- <kind>`, `nix run .#build`, `nix run .#serve`.

| Kind | Address | Directory | `\taxon` | Write one when |
|---|---|---|---|---|
| Change | `log-XXXX` | `journal/trees/log/` | `Change` | a change is made; one tree per change |
| Insight | `ins-XXXX` | `journal/trees/insight/` | `Insight` or `Hypothesis` | a lesson would spare a later session a dead end, including a tool that was tried |
| Problem | `prob-XXXX` | `journal/trees/problem/` | `Problem` | something is left out or unresolved |
| Decision | `dec-XXXX` | `journal/trees/decision/` | `Decision` | a maintainer chooses between alternatives |
| Session | `ses-XXXX` | `journal/trees/session/` | `Session` | once per working session |

- Every tree starts with `\title`, `\taxon`, `\date` (creation), `\author` (the identity tree of
  your exact model version in `journal/trees/people/`; create one and add it to `agents.tree` if
  it is missing), `\contributor` (who directed the session), `\tag`s and `\import{base-macros}`.
  Copy an existing tree of the same kind.
- Addresses are permanent; never rename one. Keep a tree to one idea and link the others.
- A change is also added by hand, newest first, to its month tree
  `journal/trees/log/log-YYYY-MM.tree` (new months go at the top of `changelog.tree`). The other
  hubs list trees by taxon and need no edit.
- Problems and decisions carry `\meta{status}{open}` (or `closed`, `superseded`) and repeat it as
  the first paragraph. Do not delete a closed problem or a decision; mark it and link what
  replaced it. Use `Hypothesis` for a lesson that was not verified.
- Write for a reader with no access to any conversation: cite pull requests (`\pr{1}`) and session
  trees, never a chat. Say what was verified and how.
- Markup: wrap every paragraph in `\p{...}`, one paragraph per line; `%` starts a comment, write
  `\%`; put code, and any of `{ } [ ] \ #`, in `\code{\verb~|...~}`; lists are
  `\ul{\li{...}}`; a link to a tree is `[text](address)`.
