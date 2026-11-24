# Template for adding a math function

Copy `FunctionTemplate.lean` to `LibcMath/<Function>.lean` and `FunctionTemplate/` to
`LibcMath/<Function>/`, then replace `Fn` / `fn` with your function's CamelCase / lowercase name
(for example `Exp2f` / `exp2f`). See `journal/trees/note/note-adding-a-function.tree` for the full
walkthrough and `LibcMath/Expf.lean` + `LibcMath/Expf/` for the worked example.

Checklist:
1. Ensure `Spec.<fn>` exists in `LibcMath/Framework/Specs.lean`.
2. Extract the LLVM libc evaluation plans into `LibcMath/<Function>/Generated/` with `ast2lean`
   (keeping generated files isolated from hand-written ones) and list them in `Plans.lean`.
3. Define the `CorrectlyRounded` statement(s) in `Statement.lean`.
4. Prove the short-path ranges in `ShortPaths/Exec.lean` and `ShortPaths/Ranges.lean`.
5. Split the main path into one file per numerical-analysis step under `MainPath/`, reusing
   `LibcMath/Analysis/RangeReduction.lean`, `LibcMath/Analysis/Horner.lean`,
   `LibcMath/Analysis/RoundingTransfer.lean`, and `LibcMath/Analysis/ChebTmd.lean`. Any step not
   yet proved must stay a named `sorry` lemma with a `/-- **Open.** ... -/` docstring.
6. Add worked evaluations in `Examples.lean`, import `LibcMath.<Function>` in `LibcMath.lean`,
   run `python3 scripts/check-open.py --update`, and verify `lake build` and differential tests.
