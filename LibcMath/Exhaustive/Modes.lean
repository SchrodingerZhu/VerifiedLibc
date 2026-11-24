import LibcMath.Exhaustive.Reduction
import LibcMath.Functions
import LibcMath.Functions.RoundingRanges

/-!
# Reusing a checked range for a related rounding direction or input

Checking an input against an oracle is much more expensive than running the implementation on it.
When the prescribed results under two rounding directions, or at two inputs, are related by a
known map, a range already established for one side gives the other side from a comparison of two
runs of the implementation, without the oracle.

* `CorrectAt.of_map` is the general statement for one input: the result under `(mode, x)` is the
  image under `g` of the result under `(mode', x')`.
* `holdsOnBits_of_checkModesAgree` is the case of one block and two rounding directions with the
  same prescribed results.
* A function with positive values, such as `exp`, has the same prescribed results when rounding
  toward zero and when rounding down (`Spec.exp_eval_towardZero`), so the oracle only needs to run
  for three of the four rounding directions of C.
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {fmt : FloatFormat} {S : Spec fmt}
  {impl : IEEERoundingMode → Model fmt → Model fmt}
  {mode mode' : IEEERoundingMode} {first count : ℕ}

/-- On each of the `count` bit patterns starting at `first`, `impl` produces the exact same
output under `mode` and `mode'`. -/
def checkModesAgree (impl : IEEERoundingMode → Model fmt → Model fmt)
    (mode mode' : IEEERoundingMode) (first count : ℕ) : Bool :=
  checkBits (first := first) (count := count) fun input =>
    decide (impl mode input = impl mode' input)

@[grind =]
theorem checkModesAgree_eq_true_iff :
    checkModesAgree impl mode mode' first count = true ↔
      ∀ i < count, impl mode (.ofNatBits (first + i)) = impl mode' (.ofNatBits (first + i)) := by
  simp [checkModesAgree, checkBits_eq_true_iff]

/-- Correctness at one input and rounding direction from correctness at another, when both the
implementation outputs and the prescribed results are related by `g`. -/
theorem CorrectAt.of_map {x x' : Model fmt} {g : Model fmt → Model fmt}
    (hg : ∀ a b, SameValue a b → SameValue (g a) (g b))
    (h' : CorrectAt S impl mode' x')
    (himpl : impl mode x = g (impl mode' x'))
    (hS : SameValue (g (S.eval mode' x')) (S.eval mode x)) :
    CorrectAt S impl mode x := by
  change SameValue (impl mode x) (S.eval mode x)
  rw [himpl]
  exact (hg _ _ h').trans hS

/-- A block established under `mode'` holds under `mode` if the prescribed results are the same
and `impl` produces identical results under both modes. -/
theorem holdsOnBits_of_checkModesAgree
    (hS : ∀ x, SameValue (S.eval mode' x) (S.eval mode x))
    (h' : HoldsOnBits (CorrectAt S impl mode') first (first + count))
    (h : checkModesAgree impl mode mode' first count = true) :
    HoldsOnBits (CorrectAt S impl mode) first (first + count) :=
  HoldsOnBits.iff_forall_lt.2 fun i hi =>
    CorrectAt.of_map (g := id) (fun _ _ => id) (HoldsOnBits.iff_forall_lt.1 h' i hi)
      (checkModesAgree_eq_true_iff.1 h i hi) (hS _)

/-- Rounding a positive real toward zero is rounding it down. -/
theorem roundReal_towardZero_of_pos (fmt : FloatFormat) {r : ℝ} (hr : 0 < r) :
    Model.roundReal fmt .towardZero r = Model.roundReal fmt .down r := by
  rw [roundReal_of_pos _ hr, roundReal_of_pos _ hr]
  rfl

/-- `exp` is positive, so rounding it toward zero and rounding it down prescribe the same
results. -/
theorem Spec.exp_eval_towardZero (fmt : FloatFormat) (x : Model fmt) :
    (Spec.exp fmt).eval .towardZero x = (Spec.exp fmt).eval .down x := by
  simp only [Spec.eval, Spec.exp, Option.getD_none,
    roundReal_towardZero_of_pos fmt (Real.exp_pos _)]

end LibcMath
