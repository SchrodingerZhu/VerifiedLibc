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

- Check one file without building the rest: `lake env lean LibcMath/Path/To/File.lean`.
- Build executables: `lake build checkrange difftest-expf-model`.
- Build and smoke-test the C++23 Clang-AST extractor: `bash extract/test/run_tests.sh`.
- Warnings about files "designed for use with the module system" come from Mathlib imports and
  are expected.
- To work on a pull request beside the main checkout, use `git worktree add` and link
  `.lake/packages` of the main checkout into it, so that Mathlib is not downloaded again.

## What must stay true

- **What is open is a `sorry`, in plain sight.** A statement that is not proved yet is a named
  lemma that ends in `sorry`, with a docstring that starts with **Open.** and says what a proof
  has to show. Do not turn it into a hypothesis of the theorem that needs it: a theorem with an
  unproved hypothesis passes every check of its axioms and hides what is missing. The open lemmas
  of `expf` are in `LibcMath/Extracted/Expf/Main.lean`; `rg -n 'sorry' LibcMath` lists all of them,
  and there should be no other.
- A top-level theorem carries a `#guard_msgs in #print axioms …` check. It lists `sorryAx` while
  an open lemma is used, so the check changes when the lemma is proved.
- No new `axiom`, except the one that states the trust in an external library used by an oracle
  (`MpfrOracle.mpfrExpf_sameValue`). `native_decide` only in tests of tools, such as
  `LibcMath/Check/MpfrExamples.lean`, never in a proof about a function.
- **Proofs about a function are by analysis.** Ranges of inputs are closed by symbolic evaluation
  and by bounds on errors. Do not prove, or plan to prove, a range by running the function on
  each of its inputs. `checkrange` and the oracles under `LibcMath/Check/` and `LibcMath/Oracle/`
  are tests.
- Files named `…Examples.lean` are part of the build. They are the tests: put a small worked case
  there for every new definition that is meant to be evaluated.
- Files under `LibcMath/Extracted/Expf/` whose first line says they are generated are not edited;
  change `extract/` and run `extract/extract-expf-plans.sh <llvm-project>/libc` in the flake
  shell, at the commit of LLVM that the files record.
- Lean, C++ and Nix sources stay within 100 columns. The exceptions are expected messages under
  `#guard_msgs`, string literals, and long expressions in generated files.
- **Keep a strictly linear history on `main`.** Do not create merge commits on `main`: rebase
  feature branches (`git rebase`) or squash-merge pull requests so `git log --merges main` remains
  empty and every commit on `main` builds cleanly.
- When a status is reported, say first whether the main theorem is complete, and name what is
  open. "No errors" and "standard axioms" are not a status.

## Testing a kernel

```bash
lake build checkrange
.lake/build/bin/checkrange --oracle=mpfr --plan=double_eval nearest 1065353216 65536
```

`--oracle=mpfr` compares with MPFR (`c/mpfr_oracle.c`), `--oracle=lean`, the default, with the
oracle proved in Lean. Build in the flake shell: the C file needs the headers of MPFR and GMP,
which `cc` finds there. `scripts/difftest-expf.sh` compares a kernel with the compiled C++; run
it after any change to `extract/` or to `LibcMath/Core/`.

## Where things go

- `LibcMath/Extracted/<Function>/` holds everything about one function: its generated evaluation
  plans, `Plans.lean`, `Examples.lean`, `Statements.lean`, the short paths under `Paths/`, the
  error analysis of its main path, and `Main.lean` with the theorem and what is open.
  `LibcMath/Extracted/<Function>.lean` imports them all; `LibcMath/Extracted/Expf.lean` is the model.
- Proofs are kept for one evaluation plan of a function. Other plans may be extracted and tested.
- What does not depend on the function stays outside: `LibcMath/Core/` (the operations of libc),
  `LibcMath/Functions/` (facts about real functions and rounding), `LibcMath/BitRange.lean` and
  `LibcMath/Correctness.lean` (statements about ranges of inputs), `LibcMath/Check/` and
  `LibcMath/Oracle/` (tests).

## What the theorems do not say

- **Undefined behaviour is tracked for a fixed list of operations**, given at the head of the
  section on them in `LibcMath/Core/Ops.lean`. A left shift of a signed value that overflows, and
  the library types of `LibcMath/Core/Extended.lean`, are not on it.
- **Effects are dropped.** `ast2lean --drop-effects` removes `errno` and the floating-point
  exception flags, so nothing is proved about them.
- **The translation is trusted.** `ast2lean` and the definitions in `LibcMath/Core/` are not
  verified against Clang; `scripts/difftest-expf.sh` tests them.

## Proof style

- Reuse Mathlib, FloatLib, and `LibcMath.Core` before writing a lemma. Search with `exact?`,
  `rw?`, or `grep` in `.lake/packages/FloatLib` and `.lake/packages/mathlib`. A general fact about
  rounding belongs in FloatLib; keep it here only until it is upstream, and say so in its
  docstring.
- Make definitions usable by `grind`. Thin predicates (`SameValue`, `CorrectAt`, `HoldsOnBits`,
  `Core.FPBits.*`, `Core.Sign.*`) are tagged `@[grind]`, and Boolean characterisations
  (`checkBits_eq_true_iff`, `checkRange_eq_true_iff`, `checkModesAgree_eq_true_iff`, …) are tagged
  `@[grind =]`. Follow the same pattern for new definitions, and try `grind` first on goals about
  ranges, `SameValue`, `CorrectAt`, and `MathConfig`.
- When `grind` fails, read the goal it prints; if it stalls on an equation between `fun`
  expressions, unfold the definitions with `simp only` first (`roundReal_towardZero_of_pos` in
  `LibcMath/Functions/RoundingRanges.lean` is such a case).
- Do **not** put `@[inline]` on multi-call wrappers over FloatLib's `@[macro_inline]` operations
  (`Model.add`, `Model.mul`, `Model.sub`); inlining cascades blow up the LCNF compiler.
- Keep a proof term where it is one line of composition. Search tactics are for finding it.

## Agent-friendly diagnostics

### Inspecting extracted kernels, configs, and cross-plan diffs (`LibcMath.Core.Diag`)

Every extracted kernel module defines `config : Core.MathConfig`, `kernelMeta : Core.KernelMeta`,
and `kernel : Core.UnaryKernel fmt`. Inspect provenance, active `LIBC_MATH_*` / CPU flags, or
compare evaluation plans directly in Lean:

```lean
#eval Core.Diag.inspectKernel Extracted.Expf.DoubleEval.kernel
#eval Core.Diag.describeFloat (Extracted.Expf.DoubleEval.expf .nearest f32(0x3F800000#32))
#eval Core.Diag.compareKernels Extracted.Expf.DoubleEval.kernel Extracted.Expf.FloatEval.kernel .nearest 0x3F800000 32
#eval Core.Diag.diagnosePlanMatrix Extracted.Expf.allPlans .nearest f32(0x3F800000#32)
```

From the shell, `ast2lean --dump-config` snapshots the exact preprocessor macros seen by Clang for
any flag combination without generating Lean.

### When a test of a block fails

A test of a block of bit patterns is `checkBits test first count` (`LibcMath/BitRange.lean`). Its
diagnostics are:

```lean
#eval checkRange.firstFailure O.check impl mode first count          -- `some n`: first failure
#eval Core.Diag.diagnoseKernelRange O.check kernel mode first count -- full report
```

The program `checkrange` (`LibcMath/Check/Main.lean`) prints `Core.Diag.diagnoseBlock` on stderr
when a block fails. A kernel that returns `none` is reported as undefined behaviour.

Pass the oracle's test `O.check`, not the oracle: a specification is noncomputable, so a
definition that takes an `Oracle S` as an argument cannot be compiled at a concrete `S`, and
`#eval` on it fails with "depends on 'Spec.exp', which is 'noncomputable'".

### Which closed form covers a bit pattern of `exp`

`LibcMath/Functions/ExpRanges.lean` proves the correctly rounded binary32 `exp` on whole blocks of
bit patterns. The blocks are also data:

```lean
#eval ExpRanges.blockOf? .nearest 0x33000000   -- the block and the theorem that covers it
#eval ExpRanges.uncovered .nearest             -- ranges with no closed form
#eval ExpRanges.covered .nearest               -- how many patterns have one
```

When a block is added or changed, change `closedForm?` and `blocks` together
(`closedForm?_isSome_iff` fails otherwise) and update the counts in
`LibcMath/Functions/ExpRangesExamples.lean`.

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
| Note | `note-<slug>` | `journal/trees/note/` | `Note` | a survey, a design or a description is longer than one idea |

- Every tree starts with `\title`, `\taxon`, `\date` (creation), `\author` (the identity tree of
  your exact model version in `journal/trees/people/`; create one and add it to `agents.tree` if
  it is missing), `\contributor` (who directed the session), `\tag`s and `\import{base-macros}`.
  Copy an existing tree of the same kind.
- A note is created by hand with a readable address, not with `journal-new`. Write documents
  there, not under `docs/`. A Markdown draft, or the Markdown a script prints, is converted with
  `python3 scripts/md2tree.py draft.md note-<slug>`; a long note is split into trees that the
  first one transcludes (`journal/trees/note/note-extraction-coverage.tree` is the model).
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
