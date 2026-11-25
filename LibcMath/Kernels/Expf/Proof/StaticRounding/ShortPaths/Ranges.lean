import LibcMath.Kernels.Expf.Proof.StaticRounding.ShortPaths.SymbolicExecution
import LibcMath.Analysis.AddRounding
import LibcMath.Analysis.AddSpecial
import LibcMath.Analysis.ExpRanges

/-!
# `Generated.StaticRounding.kernel` on its short paths

For each rounding direction, `CorrectAt` on the ranges of bit patterns where the function returns
before its tables and its polynomial. Each range is proved at once: the result of the function
comes from `SymbolicExecution.lean`, and the prescribed result from the closed forms of
`LibcMath/Analysis/ExpRanges.lean`.

`0x00000000`–`0x32FFFFFF` and `0x80000000`–`0xB2FFFFFF` (`|x| < 2⁻²⁵`, wider than `DoubleEval`),
`0x42B17218`–`0x7FFFFFFF` and `0xC2CFF1B5`–`0xFFFFFFFF`: 3 766 393 907 of the `2³²` bit patterns
(87.69 %), leaving `[0x33000000, 0x42B17218)` and `[0xB3000000, 0xC2CFF1B5)`.
-/

namespace LibcMath.Kernels.Expf.Proof.StaticRounding.ShortPaths

open FloatLib.Floats.Formats.BinaryInterchange Model
open LibcMath.Libc.DSL

variable {mode : IEEERoundingMode}

private theorem isNaN_or_quiet (b : BitVec 32)
    (hb : (0x7F800001 ≤ b.toNat ∧ b.toNat ≤ 0x7FFFFFFF) ∨ 0xFF800001 ≤ b.toNat) :
    f32(b ||| 0x400000#32).isNaN = true := by
  have hlo : b.toNat ≤ (b ||| 0x400000#32).toNat := by
    rw [BitVec.toNat_or]
    exact Nat.left_le_or
  apply Binary32.isNaN_iff.mpr
  rw [toNatBits_ofBits]
  rcases hb with ⟨h1, h2⟩ | h1
  · left
    have hlt : (b ||| 0x400000#32).toNat < 2 ^ 31 := by
      rw [BitVec.toNat_or]
      exact Nat.or_lt_two_pow (by omega) (by norm_num)
    exact ⟨by omega, by omega⟩
  · right; omega

/-- All short-path ranges of the integer-only 4-mode kernel `Generated.StaticRounding.kernel`,
covering 3 766 393 907 of 2³² bit patterns (87.69 %) in every C rounding mode. -/
theorem holdsOnBits_short_paths_staticRounding (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
        0x00000000 0x33000000 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
        0x42B17218 0xB3000000 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
        0xC2CFF1B5 0x100000000 := by
  have hsmall_pos :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
          0x00000000 0x33000000 :=
    holdsOnBits_of_forall_bitVec fun b _ hhi => by
      by_cases hzero : b.toNat = 0
      · refine .of_eq_some (staticRounding_of_zero b (.inl hzero)) (.inl ?_)
        exact (ExpRanges.eval_of_zero_bits (x := f32(b)) (.inl hzero)).symm
      · refine .of_eq_some (staticRounding_of_tiny_pos b hmode (by omega) (by omega)) (.inl ?_)
        exact (ExpRanges.eval_of_tiny_pos_bits (x := f32(b)) hmode
          ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩).symm
  have hsmall_neg :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
          0x80000000 0xB3000000 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      by_cases hzero : b.toNat = 0x80000000
      · refine .of_eq_some (staticRounding_of_zero b (.inr hzero)) (.inl ?_)
        exact (ExpRanges.eval_of_zero_bits (x := f32(b)) (.inr hzero)).symm
      · refine .of_eq_some (staticRounding_of_tiny_neg b hmode (by omega) (by omega)) (.inl ?_)
        exact (ExpRanges.eval_of_tiny_neg_bits (x := f32(b)) hmode
          ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩).symm
  have hoverflow :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
          0x42B17218 0x7F800000 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      refine .of_eq_some (staticRounding_of_overflow b hmode hlo (by omega)) (.inl ?_)
      exact (ExpRanges.eval_of_overflow_bits (x := f32(b)) hmode
        ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩).symm
  have hposInf :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
          0x7F800000 0x7F800001 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      obtain rfl : b = 0x7F800000#32 := BitVec.eq_of_toNat_eq (show b.toNat = 0x7F800000 by omega)
      refine .of_eq_some (y := Model.posInf .binary32) staticRounding_of_posInf (.inl ?_)
      exact (ExpRanges.eval_of_posInf_bits (x := Model.posInf .binary32) rfl).symm
  have hposNan :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
          0x7F800001 0x80000000 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      have hnan : f32(b).isNaN = true :=
        Binary32.isNaN_iff.mpr (.inl (by rw [toNatBits_ofBits]; omega))
      refine .of_eq_some (staticRounding_of_nan b (.inl ⟨by omega, by omega⟩)) (.inr ⟨?_, ?_⟩)
      · exact isNaN_or_quiet b (.inl ⟨by omega, by omega⟩)
      · rw [ExpRanges.eval_of_isNaN hnan]; decide +kernel
  have hunderflow :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
          0xC2CFF1B5 0xFF800000 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      refine .of_eq_some (staticRounding_of_underflow b hmode hlo (by omega)) (.inl ?_)
      exact (ExpRanges.eval_of_underflow_bits (x := f32(b)) hmode
        ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩).symm
  have hnegInf :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
          0xFF800000 0xFF800001 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      obtain rfl : b = 0xFF800000#32 := BitVec.eq_of_toNat_eq (show b.toNat = 0xFF800000 by omega)
      refine .of_eq_some (y := Model.posZero .binary32) staticRounding_of_negInf (.inl ?_)
      exact (ExpRanges.eval_of_negInf_bits (x := Model.negInf .binary32) rfl).symm
  have hnegNan :
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel mode)
          0xFF800001 0x100000000 :=
    holdsOnBits_of_forall_bitVec fun b hlo hhi => by
      have hnan : f32(b).isNaN = true :=
        Binary32.isNaN_iff.mpr (.inr (by rw [toNatBits_ofBits]; omega))
      refine .of_eq_some (staticRounding_of_nan b (.inr (by omega))) (.inr ⟨?_, ?_⟩)
      · exact isNaN_or_quiet b (.inr (by omega))
      · rw [ExpRanges.eval_of_isNaN hnan]; decide +kernel
  exact ⟨hsmall_pos, (((hoverflow.append hposInf).append hposNan).append hsmall_neg),
    ((hunderflow.append hnegInf).append hnegNan)⟩

end LibcMath.Kernels.Expf.Proof.StaticRounding.ShortPaths
