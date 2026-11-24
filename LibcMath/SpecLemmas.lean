import LibcMath.Spec

/-!
# Basic facts about `SameValue` and `CorrectlyRounded`

`SameValue` is an equivalence relation, and it is unfolded by `grind` so symmetry, transitivity,
and NaN propagation close automatically without naming a lemma.
-/

namespace LibcMath

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

variable {fmt : FloatFormat} {a b c : Model fmt}

attribute [grind] SameValue

instance : Decidable (SameValue a b) :=
  inferInstanceAs (Decidable (_ ∨ _))

namespace SameValue

@[refl]
protected theorem refl (a : Model fmt) : SameValue a a :=
  .inl rfl

protected theorem of_eq (h : a = b) : SameValue a b :=
  .inl h

@[symm]
protected theorem symm (h : SameValue a b) : SameValue b a := by
  grind

@[trans]
protected theorem trans (hab : SameValue a b) (hbc : SameValue b c) : SameValue a c := by
  grind

instance : Trans (SameValue (fmt := fmt)) SameValue SameValue :=
  ⟨SameValue.trans⟩

theorem isNaN_eq (h : SameValue a b) : a.isNaN = b.isNaN := by
  grind

/-- Results that are not NaN have the same value only if they are equal. -/
theorem eq_of_isNaN_eq_false (h : SameValue a b) (hb : b.isNaN = false) : a = b := by
  grind

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

end LibcMath
