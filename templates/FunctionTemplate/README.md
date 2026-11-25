# Template for adding a math function

Copy `FunctionTemplate.lean` to `LibcMath/Kernels/<Function>.lean` and `FunctionTemplate/` to
`LibcMath/Kernels/<Function>/`, then replace `Fn` / `fn` with your function's CamelCase / lowercase name
(for example `Exp2f` / `exp2f`) and `Plan` / `plan` with the explicit evaluation plan name (for
example `DoubleEval` / `doubleEval`). Always name the implementation plan in every statement and
theorem; never add a "default" alias. See `journal/trees/note/note-adding-a-function.tree` for the
full walkthrough and `LibcMath/Kernels/Expf.lean` + `LibcMath/Kernels/Expf/` for the worked example.

Checklist:
1. Ensure `Spec.<fn>` exists in `LibcMath/Framework/Specs.lean`.
2. Extract the LLVM libc evaluation plans into `LibcMath/Kernels/<Function>/Generated/` with `ast2lean`
   (keeping generated files isolated from hand-written ones) and list them in `Plans.lean`.
3. Define the `CorrectlyRounded` statement(s) in `Statement.lean`.
4. For each plan, rename `Proof/Plan.lean` and `Proof/Plan/` to the name of the plan, and prove the
   short-path ranges in `Proof/<Plan>/ShortPaths/SymbolicExecution.lean` and `Ranges.lean`. Facts
   that several plans share go to `Proof/Common.lean`.
5. Split the main path into one file per numerical-analysis step under `Proof/<Plan>/MainPath/`,
   reusing
   `LibcMath/Analysis/RangeReduction.lean`, `LibcMath/Analysis/Horner.lean`,
   `LibcMath/Analysis/RoundingTransfer.lean`, and `LibcMath/Analysis/ChebTmd.lean`. Any step not
   yet proved must stay a named `sorry` lemma with a `/-- **Open.** ... -/` docstring.
6. Add worked evaluations in `Examples.lean`, import `LibcMath.Kernels.<Function>` in `LibcMath.lean`,
   run `python3 scripts/check-open.py --update`, and verify `lake build` and differential tests.
