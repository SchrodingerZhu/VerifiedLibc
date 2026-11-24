import LibcMath.Framework.Spec
import FloatLib.Floats.Formats.BinaryInterchange.Arithmetic.Proof
import FloatLib.Floats.Formats.BinaryInterchange.Arithmetic.Semantics

/-!
# Additions with an exceptional operand

The sum of a NaN and any value is a NaN, and the sum of a finite value and `+∞` is `+∞`, in every
rounding direction.
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange Model

variable {fmt : FloatFormat} {x y : Model fmt}

/-- Addition returns the NaN selected among its operands, if there is one. -/
private theorem add_eq_of_chooseNaN2 (mode : IEEERoundingMode) {nan : Model fmt}
    (hnan : chooseNaN2 x y = some nan) : Model.add x y mode = nan := by
  have hnone : ¬(isNaN x = false ∧ isNaN y = false) := fun h => by
    rw [(chooseNaN2_eq_none_iff x y).2 h] at hnan
    cases hnan
  cases mode
  case nearest =>
    change Model.add x y = nan
    have hdyadic : ¬∃ dx dy, toDyadic? x = some dx ∧ toDyadic? y = some dy := by
      rintro ⟨dx, dy, hdx, hdy⟩
      exact hnone ⟨isNaN_eq_false_of_isFinite_eq_true x (isFinite_eq_true_of_toDyadic?_some hdx),
        isNaN_eq_false_of_isFinite_eq_true y (isFinite_eq_true_of_toDyadic?_some hdy)⟩
    rw [Proof.add_eq_spec, Spec.add]
    split
    · rename_i dx dy hdx hdy
      exact absurd ⟨dx, dy, hdx, hdy⟩ hdyadic
    · simp only [hnan]
  all_goals
    rw [← Internal.Directed.add_eq]
    exact withNaNSelection_of_some _ _ nan hnan

/-- The sum of a NaN and any value is a NaN. -/
theorem isNaN_add_of_isNaN_left (mode : IEEERoundingMode) (hx : x.isNaN = true) :
    (Model.add x y mode).isNaN = true := by
  cases hsel : chooseNaN2 x y with
  | none => rw [((chooseNaN2_eq_none_iff x y).1 hsel).1] at hx; cases hx
  | some nan => rw [add_eq_of_chooseNaN2 mode hsel]; exact isNaN_of_chooseNaN2_eq_some hsel

/-- The sum of a finite value and `+∞` is `+∞`. -/
theorem add_posInf_of_isFinite (hfmt : fmt.supportsInfinity = true) (mode : IEEERoundingMode)
    (hx : x.isFinite = true) : Model.add x (posInf fmt) mode = posInf fmt := by
  have hxnan := isNaN_eq_false_of_isFinite_eq_true x hx
  have hxinf := isInfinite_eq_false_of_isFinite_eq_true x hx
  have hinf := isInfinite_posInf fmt hfmt
  have hsel : chooseNaN2 x (posInf fmt) = none :=
    (chooseNaN2_eq_none_iff _ _).2 ⟨hxnan, isNaN_posInf fmt⟩
  cases mode
  case nearest =>
    change Model.add x (posInf fmt) = posInf fmt
    rw [Proof.add_eq_spec, Spec.add, toDyadic?_eq_none_of_isInfinite_eq_true hinf]
    simp only [hsel, hxinf, hinf, Bool.false_eq_true, ↓reduceIte]
    split
    · rename_i hdy
      cases hdy
    · rfl
  all_goals
    rw [← Internal.Directed.add_eq]
    simp only [Internal.Directed.add, withNaNSelection, hsel, hxinf, hinf, Bool.false_eq_true,
      ↓reduceDIte]

end LibcMath
