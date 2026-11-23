import LibcMath.Spec
import LibcMath.IR.Semantics

/-!
# Basic facts about `SameValue` and `Val.Encodes`

`SameValue` is an equivalence relation, and a runtime value encodes at most one result up to it.
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {fmt : FloatFormat} {a b c : Model fmt}

instance : Decidable (SameValue a b) :=
  inferInstanceAs (Decidable (_ ∨ _))

namespace SameValue

@[refl]
protected theorem refl (a : Model fmt) : SameValue a a :=
  .inl rfl

protected theorem of_eq (h : a = b) : SameValue a b :=
  .inl h

@[symm]
protected theorem symm (h : SameValue a b) : SameValue b a :=
  h.elim (fun h => .inl h.symm) fun h => .inr ⟨h.2, h.1⟩

@[trans]
protected theorem trans (hab : SameValue a b) (hbc : SameValue b c) : SameValue a c := by
  rcases hab with rfl | ⟨ha, hb⟩
  · exact hbc
  · rcases hbc with rfl | ⟨_, hc⟩
    · exact .inr ⟨ha, hb⟩
    · exact .inr ⟨ha, hc⟩

instance : Trans (SameValue (fmt := fmt)) SameValue SameValue :=
  ⟨SameValue.trans⟩

theorem isNaN_eq (h : SameValue a b) : a.isNaN = b.isNaN := by
  rcases h with rfl | ⟨ha, hb⟩
  · rfl
  · rw [ha, hb]

/-- Results that are not NaN have the same value only if they are equal. -/
theorem eq_of_isNaN_eq_false (h : SameValue a b) (hb : b.isNaN = false) : a = b := by
  rcases h with h | ⟨_, hb'⟩
  · exact h
  · simp [hb] at hb'

end SameValue

theorem sameValue_comm : SameValue a b ↔ SameValue b a :=
  ⟨.symm, .symm⟩

theorem sameValue_equivalence : Equivalence (SameValue (fmt := fmt)) :=
  ⟨.refl, .symm, .trans⟩

/-- Correct rounding is a statement about each rounding direction separately. -/
theorem CorrectlyRounded.mono {S : Spec fmt} {modes modes' : Set IEEERoundingMode}
    {impl : IEEERoundingMode → Model fmt → Model fmt} (h : CorrectlyRounded S modes impl)
    (hmodes : modes' ⊆ modes) : CorrectlyRounded S modes' impl :=
  fun mode hmode => h mode (hmodes hmode)

namespace IR.Val

variable {v : Val}

@[simp]
theorem toModel?_ofModel (x : Model fmt) : (ofModel x).toModel? fmt = some x := by
  unfold toModel? ofModel
  rw [dite_eq_left_of_eq_true (eq_self _)]
  exact congrArg some (Model.ofBits_toBits x)

@[simp]
theorem encodes_ofModel : (ofModel a).Encodes b ↔ SameValue a b := by
  simp [Encodes]

/-- A value that encodes a result encodes every result with the same value. -/
theorem Encodes.of_sameValue (h : v.Encodes a) (hab : SameValue a b) : v.Encodes b :=
  let ⟨y, hy, hya⟩ := h
  ⟨y, hy, hya.trans hab⟩

/-- A value encodes at most one result. -/
theorem Encodes.sameValue (ha : v.Encodes a) (hb : v.Encodes b) : SameValue a b := by
  obtain ⟨y, hy, hya⟩ := ha
  obtain ⟨z, hz, hzb⟩ := hb
  obtain rfl : y = z := Option.some.inj (hy.symm.trans hz)
  exact hya.symm.trans hzb

end IR.Val

end LibcMath
