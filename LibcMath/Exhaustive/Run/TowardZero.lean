import LibcMath.Exhaustive.Run.Target
import LibcMath.Exhaustive.Modes

/-!
# Rounding toward zero from rounding down

`exp` is positive, so its rounding toward zero is its rounding down, and a range established for
rounding down holds for rounding toward zero once the implementation is seen to return the same
results in both directions. That comparison (`checkModesAgree`) runs the implementation twice and
the oracle not at all. Certificate files for it conclude `AgreeOn lo hi`, and
`CheckedOn.towardZero` combines such a range with the one for rounding down.
-/

namespace LibcMath.Exhaustive.Run

/-- On every bit pattern from `lo` up to but excluding `hi`, `run` produces a result rounding
toward zero, and the same one rounding down. -/
abbrev AgreeOn (lo hi : ℕ) : Prop :=
  HoldsOnBits (fun x => ∃ y, run .towardZero x = some y ∧ run .down x = some y) lo hi

theorem agreeOn_of_checkModesAgree {first count : ℕ}
    (h : checkModesAgree run .towardZero .down first count = true) :
    AgreeOn first (first + count) :=
  HoldsOnBits.iff_forall_lt.2 (checkModesAgree_eq_true_iff.1 h)

theorem CheckedOn.towardZero {lo hi : ℕ} (down : CheckedOn .down lo hi) (agree : AgreeOn lo hi) :
    CheckedOn .towardZero lo hi := fun n hlo hhi => by
  obtain ⟨y, hy, hy'⟩ := agree n hlo hhi
  obtain ⟨z, hz, hsame⟩ := down n hlo hhi
  obtain rfl : z = y := Option.some.inj (hz.symm.trans hy')
  exact ⟨z, hy, by rwa [Spec.exp_eval_towardZero]⟩

end LibcMath.Exhaustive.Run
