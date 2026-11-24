import LibcMath.Correctness
import LibcMath.Extracted.Expf.Paths.Exec
import LibcMath.Functions.AddRounding
import LibcMath.Functions.AddSpecial
import LibcMath.Functions.ExpRanges

/-!
# `Expf.DoubleEval.expf` is correct on the inputs that take a short path

For each rounding direction of C, `CorrectAt` on the ranges of bit patterns where the function
returns before its tables and its polynomial. Each range is proved at once: the result of the
function comes from `Paths/Exec.lean`, and the prescribed result from the closed forms of
`LibcMath/Functions/ExpRanges.lean`.

* `0x00000000`–`0x32800000`: `+0` and `0 < x ≤ 2⁻²⁶`, where the function returns `1 + x`;
* `0x42B17218`–`0x7F7FFFFF`: overflow; `0x7F800000`: `+∞`; `0x7F800001`–`0x7FFFFFFF`: NaNs;
* `0x80000000`–`0xB2800000`: `-0` and `-2⁻²⁶ ≤ x < 0`, where the function returns `1 + x`;
* `0xC2CFF1B5`–`0xFF7FFFFF`: underflow; `0xFF800000`: `-∞`; `0xFF800001`–`0xFFFFFFFF`: NaNs.

`holdsOnBits_short_paths` joins them into three ranges, 3 749 616 693 of the `2³²` bit patterns
(87.30 %). The two ranges between them, `[0x32800001, 0x42B17218)` and `[0xB2800001, 0xC2CFF1B5)`,
are the inputs for which the function evaluates its polynomial; `Main.lean` states what is open
about them.
-/

namespace LibcMath.Extracted.Expf.Paths

open FloatLib.Floats.Formats.BinaryInterchange Model
open LibcMath.Core.DSL

variable {mode : IEEERoundingMode}

/-- Lift a proof over 32-bit vectors to `HoldsOnBits` on `[lo, hi)`. -/
theorem holdsOnBits_of_forall_bitVec {P : Model .binary32 → Prop} {lo hi : ℕ}
    (h : ∀ b : BitVec 32, lo ≤ b.toNat → b.toNat < hi → P f32(b))
    (hrange : hi ≤ 2 ^ 32 := by norm_num) : HoldsOnBits P lo hi := by
  intro n hlo hhi
  have hmod : (BitVec.ofNat 32 n).toNat = n := by
    rw [BitVec.toNat_ofNat]
    omega
  exact h (BitVec.ofNat 32 n) (by omega) (by omega)

private theorem toNatBits_ofBits (b : BitVec 32) : f32(b).toNatBits = b.toNat := rfl

/-! ## `Expf.DoubleEval.expf` short-path ranges -/

theorem holdsOnBits_small_pos (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x00000000 0x32800001 :=
  holdsOnBits_of_forall_bitVec fun b _ hhi => by
    refine .of_eq_some (doubleEval_of_small b (by omega)) (.inl ?_)
    by_cases hzero : b.toNat = 0
    · rw [one_add_of_zero_bits (x := f32(b)) hmode (.inl hzero),
        ExpRanges.eval_of_zero_bits (x := f32(b)) (.inl hzero)]
    · have hbits : 0x00000001 ≤ f32(b).toNatBits ∧ f32(b).toNatBits ≤ 0x32800000 := by
        rw [toNatBits_ofBits]; omega
      rw [one_add_of_tiny_pos_bits hmode hbits,
        ExpRanges.eval_of_tiny_pos_bits hmode ⟨hbits.1, by omega⟩]

theorem holdsOnBits_small_neg (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x80000000 0xB2800001 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    refine .of_eq_some (doubleEval_of_small b (by omega)) (.inl ?_)
    by_cases hzero : b.toNat = 0x80000000
    · rw [one_add_of_zero_bits (x := f32(b)) hmode (.inr hzero),
        ExpRanges.eval_of_zero_bits (x := f32(b)) (.inr hzero)]
    · have hbits : 0x80000001 ≤ f32(b).toNatBits ∧ f32(b).toNatBits ≤ 0xB2800000 := by
        rw [toNatBits_ofBits]; omega
      rw [one_add_of_tiny_neg_bits hmode hbits,
        ExpRanges.eval_of_tiny_neg_bits hmode ⟨hbits.1, by omega⟩]

theorem holdsOnBits_overflow (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x42B17218 0x7F800000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    refine .of_eq_some (doubleEval_of_overflow b hmode hlo (by omega)) (.inl ?_)
    rw [ExpRanges.eval_of_overflow_bits (x := f32(b)) hmode
      ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩]

theorem holdsOnBits_posInf (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x7F800000 0x7F800001 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    obtain rfl : b = 0x7F800000#32 := BitVec.eq_of_toNat_eq (show b.toNat = 0x7F800000 by omega)
    refine .of_eq_some (doubleEval_of_posInf_or_pos_nan _ (by decide) (by decide)) (.inl ?_)
    rw [ExpRanges.eval_of_posInf_bits (x := f32(0x7F800000#32)) rfl]
    rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

theorem holdsOnBits_pos_nan :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x7F800001 0x80000000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hnan : f32(b).isNaN = true :=
      Binary32.isNaN_iff.mpr (.inl (by rw [toNatBits_ofBits]; omega))
    refine .of_eq_some (doubleEval_of_posInf_or_pos_nan b (by omega) (by omega)) (.inr ⟨?_, ?_⟩)
    · exact isNaN_add_of_isNaN_left mode hnan
    · rw [ExpRanges.eval_of_isNaN hnan]
      decide +kernel

theorem holdsOnBits_underflow (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0xC2CFF1B5 0xFF800000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    refine .of_eq_some (doubleEval_of_underflow b hmode hlo (by omega)) (.inl ?_)
    rw [ExpRanges.eval_of_underflow_bits (x := f32(b)) hmode
      ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩]

theorem holdsOnBits_negInf :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0xFF800000 0xFF800001 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    obtain rfl : b = 0xFF800000#32 := BitVec.eq_of_toNat_eq (show b.toNat = 0xFF800000 by omega)
    refine .of_eq_some (y := Model.posZero .binary32) doubleEval_of_negInf (.inl ?_)
    exact (ExpRanges.eval_of_negInf_bits (x := Model.negInf .binary32) rfl).symm

theorem holdsOnBits_neg_nan :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0xFF800001 0x100000000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hnan : f32(b).isNaN = true :=
      Binary32.isNaN_iff.mpr (.inr (by rw [toNatBits_ofBits]; omega))
    refine .of_eq_some (doubleEval_of_neg_nan b hlo) (.inr ⟨hnan, ?_⟩)
    rw [ExpRanges.eval_of_isNaN hnan]
    decide +kernel

/-- All short-path ranges of `Expf.DoubleEval.expf` joined into three intervals covering
3 749 616 693 of 2³² bit patterns (87.30 %) in every C rounding mode. -/
theorem holdsOnBits_short_paths (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x00000000 0x32800001 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x42B17218 0xB2800001 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0xC2CFF1B5 0x100000000 :=
  ⟨holdsOnBits_small_pos hmode,
    (((holdsOnBits_overflow hmode).append (holdsOnBits_posInf hmode)).append
      holdsOnBits_pos_nan).append (holdsOnBits_small_neg hmode),
    ((holdsOnBits_underflow hmode).append holdsOnBits_negInf).append holdsOnBits_neg_nan⟩

end LibcMath.Extracted.Expf.Paths
