import LibcMath.Testing.Oracle.Exp

/-!
# Timing of `expOracle` on binary32

`bench-exp-oracle first count stride` evaluates the oracle on the `count` bit patterns
`first + i * stride` (modulo `2 ^ 32`) in the four C rounding directions. Half of the candidate
results are correct and half are off by one bit. It prints the time per call of `check` and how
many finite nonzero inputs each step of `ExpOracle.round` settles.

It is not a target of the package. To build it, add to `lakefile.lean`

```lean
lean_exe «bench-exp-oracle» where
  root := `Bench.ExpOracle
```
-/

open LibcMath FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open Model.AlgebraicRounding (lowerExponent upperExponent)

abbrev fmt := FloatFormat.binary32

def modes : List IEEERoundingMode := [.nearest, .towardZero, .up, .down]

def steps : Array String :=
  #["argument beyond the exponent range", "enclosure next to zero", "reduced enclosure, 31 bits",
    "reduced enclosure, 48 bits",
    "fixed-point enclosure, level 0", "fixed-point enclosure, level 1", "exact comparisons"]

/-- The index in `steps` of the step of `ExpOracle.round` that settles `exp q`. -/
def step (mode : IEEERoundingMode) (q : ℚ) : Nat :=
  if (upperExponent fmt : ℚ) ≤ q ∨ q < (lowerExponent fmt : ℚ) then 0
  else if q.num.natAbs <<< (fmt.fracWidth + 4) ≤ q.den ∧ q.den = 1 <<< q.den.log2 then
    let grid := ExpOracle.nearOne q
    if (ExpOracle.roundGrid? fmt mode grid.1 grid.2).isSome then 1 else 6
  else if (ExpOracle.roundReduced? fmt mode ExpOracle.wordReduction q).isSome then 2
  else if (ExpOracle.roundReduced? fmt mode ExpOracle.wideReduction q).isSome then 3
  else if (ExpOracle.roundEnclosedAt? fmt mode q 0).isSome then 4
  else if (ExpOracle.roundEnclosedAt? fmt mode q 1).isSome then 5
  else 6

def main (args : List String) : IO Unit := do
  let [first, count, stride] := args.map String.toNat! | throw <| .userError "first count stride"
  let input (i : Nat) : Model fmt := .ofNatBits ((first + i * stride) % 2 ^ 32)
  -- Candidates: the correctly rounded result, with its last bit flipped for odd `i`.
  let mut candidates : Array (Model fmt) := Array.mkEmpty (4 * count)
  for i in [0:count] do
    for mode in modes do
      let correct := ExpOracle.round fmt mode ((Model.toRat? (input i)).getD 0)
      candidates := candidates.push
        (if i % 2 = 0 then correct else .ofNatBits (correct.toNatBits ^^^ 1))
  let mut accepted := 0
  let start ← IO.monoNanosNow
  for i in [0:count] do
    for mode in modes, j in [0:4] do
      if (expOracle fmt).check mode (input i) candidates[4 * i + j]! then accepted := accepted + 1
  let stop ← IO.monoNanosNow
  IO.println s!"{4 * count} calls, {accepted} accepted, {(stop - start) / (4 * count)} ns per call"
  let mut settled := Array.replicate steps.size 0
  for i in [0:count] do
    if let some q := Model.toRat? (input i) then
      if q ≠ 0 then
        for mode in modes do
          settled := settled.modify (step mode q) (· + 1)
  for name in steps, n in settled do
    IO.println s!"  {name}: {n}"
