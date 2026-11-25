import LibcMath.Kernels.Expf.Proof.DoubleEval.ShortPaths.SymbolicExecution
import LibcMath.Analysis.AddRounding
import LibcMath.Analysis.AddSpecial
import LibcMath.Analysis.ExpRanges

/-!
# `Generated.DoubleEval.expf` on its short paths

For each rounding direction, `CorrectAt` on the ranges of bit patterns where the function returns
before its tables and its polynomial. Each range is proved at once: the result of the function
comes from `SymbolicExecution.lean`, and the prescribed result from the closed forms of
`LibcMath/Analysis/ExpRanges.lean`.

* `0x00000000`–`0x32800000`: `+0` and `0 < x ≤ 2⁻²⁶`, where the function returns `1 + x`;
* `0x42B17218`–`0x7F7FFFFF`: overflow; `0x7F800000`: `+∞`; `0x7F800001`–`0x7FFFFFFF`: NaNs;
* `0x80000000`–`0xB2800000`: `-0` and `-2⁻²⁶ ≤ x < 0`, where the function returns `1 + x`;
* `0xC2CFF1B5`–`0xFF7FFFFF`: underflow; `0xFF800000`: `-∞`; `0xFF800001`–`0xFFFFFFFF`: NaNs.

Together these cover 3 749 616 693 of the `2³²` bit patterns (87.30 %), leaving
`[0x32800001, 0x42B17218)` and `[0xB2800001, 0xC2CFF1B5)`.
-/

namespace LibcMath.Kernels.Expf.Proof.DoubleEval.ShortPaths

open FloatLib.Floats.Formats.BinaryInterchange Model
open LibcMath.Libc.DSL

variable {mode : IEEERoundingMode}

theorem holdsOnBits_doubleEval_small_pos (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0x00000000 0x32800001 :=
  holdsOnBits_of_forall_bitVec fun b _ hhi => by
    refine .of_eq_some (doubleEval_of_small b (by omega)) (.inl ?_)
    by_cases hzero : b.toNat = 0
    · rw [one_add_of_zero_bits (x := f32(b)) hmode (.inl hzero),
        ExpRanges.eval_of_zero_bits (x := f32(b)) (.inl hzero)]
    · have hbits : 0x00000001 ≤ f32(b).toNatBits ∧ f32(b).toNatBits ≤ 0x32800000 := by
        rw [toNatBits_ofBits]; omega
      rw [one_add_of_tiny_pos_bits hmode hbits,
        ExpRanges.eval_of_tiny_pos_bits hmode ⟨hbits.1, by omega⟩]

theorem holdsOnBits_doubleEval_small_neg (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0x80000000 0xB2800001 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    refine .of_eq_some (doubleEval_of_small b (by omega)) (.inl ?_)
    by_cases hzero : b.toNat = 0x80000000
    · rw [one_add_of_zero_bits (x := f32(b)) hmode (.inr hzero),
        ExpRanges.eval_of_zero_bits (x := f32(b)) (.inr hzero)]
    · have hbits : 0x80000001 ≤ f32(b).toNatBits ∧ f32(b).toNatBits ≤ 0xB2800000 := by
        rw [toNatBits_ofBits]; omega
      rw [one_add_of_tiny_neg_bits hmode hbits,
        ExpRanges.eval_of_tiny_neg_bits hmode ⟨hbits.1, by omega⟩]

theorem holdsOnBits_doubleEval_overflow (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0x42B17218 0x7F800000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    refine .of_eq_some (doubleEval_of_overflow b hmode hlo (by omega)) (.inl ?_)
    rw [ExpRanges.eval_of_overflow_bits (x := f32(b)) hmode
      ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩]

theorem holdsOnBits_doubleEval_posInf (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0x7F800000 0x7F800001 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    obtain rfl : b = 0x7F800000#32 := BitVec.eq_of_toNat_eq (show b.toNat = 0x7F800000 by omega)
    refine .of_eq_some (doubleEval_of_posInf_or_pos_nan _ (by decide) (by decide)) (.inl ?_)
    rw [ExpRanges.eval_of_posInf_bits (x := f32(0x7F800000#32)) rfl]
    rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

theorem holdsOnBits_doubleEval_pos_nan :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0x7F800001 0x80000000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hnan : f32(b).isNaN = true :=
      Binary32.isNaN_iff.mpr (.inl (by rw [toNatBits_ofBits]; omega))
    refine .of_eq_some (doubleEval_of_posInf_or_pos_nan b (by omega) (by omega)) (.inr ⟨?_, ?_⟩)
    · exact isNaN_add_of_isNaN_left mode hnan
    · rw [ExpRanges.eval_of_isNaN hnan]
      decide +kernel

theorem holdsOnBits_doubleEval_underflow (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0xC2CFF1B5 0xFF800000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    refine .of_eq_some (doubleEval_of_underflow b hmode hlo (by omega)) (.inl ?_)
    rw [ExpRanges.eval_of_underflow_bits (x := f32(b)) hmode
      ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩]

theorem holdsOnBits_doubleEval_negInf :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0xFF800000 0xFF800001 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    obtain rfl : b = 0xFF800000#32 := BitVec.eq_of_toNat_eq (show b.toNat = 0xFF800000 by omega)
    refine .of_eq_some (y := Model.posZero .binary32) doubleEval_of_negInf (.inl ?_)
    exact (ExpRanges.eval_of_negInf_bits (x := Model.negInf .binary32) rfl).symm

theorem holdsOnBits_doubleEval_neg_nan :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0xFF800001 0x100000000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hnan : f32(b).isNaN = true :=
      Binary32.isNaN_iff.mpr (.inr (by rw [toNatBits_ofBits]; omega))
    refine .of_eq_some (doubleEval_of_neg_nan b hlo) (.inr ⟨hnan, ?_⟩)
    rw [ExpRanges.eval_of_isNaN hnan]
    decide +kernel

/-- All short-path ranges of `Generated.DoubleEval.expf` joined into three intervals covering
3 749 616 693 of 2³² bit patterns (87.30 %) in every C rounding mode. -/
theorem holdsOnBits_short_paths_doubleEval (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0x00000000 0x32800001 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0x42B17218 0xB2800001 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.DoubleEval.expf mode)
      0xC2CFF1B5 0x100000000 :=
  ⟨holdsOnBits_doubleEval_small_pos hmode,
    (((holdsOnBits_doubleEval_overflow hmode).append
      (holdsOnBits_doubleEval_posInf hmode)).append
      holdsOnBits_doubleEval_pos_nan).append (holdsOnBits_doubleEval_small_neg hmode),
    ((holdsOnBits_doubleEval_underflow hmode).append holdsOnBits_doubleEval_negInf).append
      holdsOnBits_doubleEval_neg_nan⟩

end LibcMath.Kernels.Expf.Proof.DoubleEval.ShortPaths
