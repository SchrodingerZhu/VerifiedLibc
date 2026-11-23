import LibcMath.Exhaustive.Reduction
import LibcMath.Functions
import LibcMath.Functions.RoundingRanges

/-!
# Reusing a checked range for a related rounding direction or input

Checking an input against an oracle is much more expensive than running the implementation on it.
When the prescribed results under two rounding directions, or at two inputs, are related by a
known map, a range already established for one side gives the other side from a comparison of two
runs of the implementation, without the oracle.

* `IR.Func.IsComputedBy.correctAt_of_map` is the general statement for one input: the result under
  `(mode, x)` is the image under `g` of the result under `(mode', x')`. With `g = Model.neg` and
  `x' = x.neg` it expresses the symmetry of an odd function, for which
  `Model.roundReal_neg` relates the prescribed results under `mode` and `mode.negate`.
* `IR.Func.IsComputedBy.holdsOnBits_of_checkModesAgree` is the case of one block and two rounding
  directions with the same prescribed results.
* A function with positive values, such as `exp`, has the same prescribed results when rounding
  toward zero and when rounding down (`Spec.exp_eval_towardZero`), so the oracle has to run for
  three of the four rounding directions of C only.
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {fmt : FloatFormat} {S : Spec fmt}
  {run : IEEERoundingMode → Model fmt → Option (Model fmt)}
  {mode mode' : IEEERoundingMode} {first count : ℕ}

/-- On each of the `count` bit patterns starting at `first`, the implementation `run` produces a
result under `mode`, and the same one under `mode'`. -/
def checkModesAgree (run : IEEERoundingMode → Model fmt → Option (Model fmt))
    (mode mode' : IEEERoundingMode) (first count : ℕ) : Bool :=
  checkBits (first := first) (count := count) fun input =>
    (run mode input).isSome && decide (run mode input = run mode' input)

@[grind =]
theorem checkModesAgree_eq_true_iff :
    checkModesAgree run mode mode' first count = true ↔
      ∀ i < count, ∃ y, run mode (.ofNatBits (first + i)) = some y ∧
        run mode' (.ofNatBits (first + i)) = some y := by
  rw [checkModesAgree, checkBits_eq_true_iff]
  refine forall₂_congr fun i _ => ?_
  cases run mode (.ofNatBits (first + i)) <;> simp [eq_comm]

namespace IR.Func.IsComputedBy

variable {f : Func} {x x' y' : Model fmt}

/-- Correctness at one input and rounding direction from correctness at another, when both the
results of the implementation and the prescribed results are related by the map `g`. -/
theorem correctAt_of_map (hrun : f.IsComputedBy run) {g : Model fmt → Model fmt}
    (hg : ∀ a b, SameValue a b → SameValue (g a) (g b)) (h' : f.CorrectAt S mode' x')
    (hy' : run mode' x' = some y') (hy : run mode x = some (g y'))
    (hS : SameValue (g (S.eval mode' x')) (S.eval mode x)) : f.CorrectAt S mode x :=
  hrun.correctAt_of_sameValue hy ((hg _ _ (hrun.sameValue_of_correctAt h' hy')).trans hS)

/-- A block established under `mode'` holds under `mode` if the prescribed results are the same
and the implementation produces the same results. -/
theorem holdsOnBits_of_checkModesAgree (hrun : f.IsComputedBy run)
    (hS : ∀ x, SameValue (S.eval mode' x) (S.eval mode x))
    (h' : HoldsOnBits (f.CorrectAt S mode') first (first + count))
    (h : checkModesAgree run mode mode' first count = true) :
    HoldsOnBits (f.CorrectAt S mode) first (first + count) :=
  HoldsOnBits.iff_forall_lt.2 fun i hi =>
    let ⟨_, hy, hy'⟩ := checkModesAgree_eq_true_iff.1 h i hi
    hrun.correctAt_of_map (g := id) (fun _ _ => id) (HoldsOnBits.iff_forall_lt.1 h' i hi) hy' hy
      (hS _)

end IR.Func.IsComputedBy

/-- Rounding a positive real toward zero is rounding it down. -/
theorem roundReal_towardZero_of_pos (fmt : FloatFormat) {r : ℝ} (hr : 0 < r) :
    Model.roundReal fmt .towardZero r = Model.roundReal fmt .down r := by
  rw [roundReal_of_pos _ hr, roundReal_of_pos _ hr]
  rfl

/-- `exp` is positive, so rounding it toward zero and rounding it down prescribe the same
results. -/
theorem Spec.exp_eval_towardZero (fmt : FloatFormat) (x : Model fmt) :
    (Spec.exp fmt).eval .towardZero x = (Spec.exp fmt).eval .down x := by
  simp only [Spec.eval, Spec.exp, Option.getD_none, roundReal_towardZero_of_pos fmt (Real.exp_pos _)]

end LibcMath
