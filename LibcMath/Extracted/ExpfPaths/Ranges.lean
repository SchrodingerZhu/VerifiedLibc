import LibcMath.Exhaustive.Reduction
import LibcMath.Extracted.ExpfPaths.Exec
import LibcMath.Functions.AddSpecial
import LibcMath.Functions.ExpRanges

/-!
# `expf` on the arguments that take a short path

For each rounding direction of C, the interpreter's result on the extracted `expf` is the
correctly rounded exponential on the following ranges of bit patterns, by a proof that treats
each range at once (the paths are those of `ExpfPaths/Exec.lean`, and the correctly rounded
results are those of `Functions/ExpRanges.lean`):

* `holdsOnBits_overflow`: `0x42B20000`–`0x7F7FFFFF`, where the result overflows;
* `holdsOnBits_posInf` and `holdsOnBits_pos_nan`: `0x7F800000` and `0x7F800001`–`0x7FFFFFFF`;
* `holdsOnBits_underflow`: `0xC2CFF1B5`–`0xFF7FFFFF`, where the result is below half the least
  positive value;
* `holdsOnBits_negInf` and `holdsOnBits_neg_nan`: `0xFF800000` and `0xFF800001`–`0xFFFFFFFF`.

The statements have the form `HoldsOnBits (RunsCorrectlyAt …) lo hi` with `hi` excluded, ready
for `HoldsOnBits.append`.
-/

namespace LibcMath.Extracted.ExpfPaths

open FloatLib.Floats.Formats.BinaryInterchange Model
open IR

variable {mode : IEEERoundingMode}

/-- The binary32 value with bit pattern `b`. -/
local notation "f32(" b ")" => (Model.ofBits b : Model FloatFormat.binary32)

/-- A statement about the bit patterns in a range, from one about 32-bit vectors. -/
theorem holdsOnBits_of_forall_bitVec {P : Model .binary32 → Prop} {lo hi : ℕ}
    (h : ∀ b : BitVec 32, lo ≤ b.toNat → b.toNat < hi → P f32(b))
    (hrange : hi ≤ 2 ^ 32 := by norm_num) : HoldsOnBits P lo hi := by
  intro n hlo hhi
  have hmod : (BitVec.ofNat 32 n).toNat = n := by
    rw [BitVec.toNat_ofNat]
    omega
  exact h (BitVec.ofNat 32 n) (by omega) (by omega)

private theorem toNatBits_ofBits (b : BitVec 32) : f32(b).toNatBits = b.toNat := rfl

/-- Overflow: the 1 020 133 376 patterns `0x42B20000`–`0x7F7FFFFF`. -/
theorem holdsOnBits_overflow (hmode : mode ∈ cModes) :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0x42B20000 0x7F800000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hexec := exec_of_large_pos (mode := mode) b hmode (by bv_omega) (by bv_omega)
    have hspec := ExpRanges.eval_of_overflow_bits (x := f32(b)) hmode
      ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩
    have hfinite : f32(b).isFinite = true :=
      Binary32.isFinite_iff.mpr (.inl (by rw [toNatBits_ofBits]; omega))
    by_cases hdown : mode = .towardZero ∨ mode = .down
    · rw [ite_eq_left hdown] at hexec hspec
      exact ⟨_, Func.runUnary_of_exec_exact hexec, .inl hspec.symm⟩
    · rw [ite_eq_right hdown] at hexec hspec
      refine ⟨_, Func.runUnary_of_exec_ofFloat hexec, .inl ?_⟩
      rw [add_posInf_of_isFinite rfl mode hfinite, hspec]

/-- `+∞`: the pattern `0x7F800000`. -/
theorem holdsOnBits_posInf (hmode : mode ∈ cModes) :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0x7F800000 0x7F800001 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hexec := exec_of_posInf_or_pos_nan (mode := mode) b (by bv_omega) (by bv_omega)
    have hspec := ExpRanges.eval_of_posInf_bits (mode := mode) (x := f32(b))
      (by rw [toNatBits_ofBits]; omega)
    obtain rfl : b = 0x7F800000#32 := by bv_omega
    refine ⟨_, Func.runUnary_of_exec_ofFloat hexec, .inl ?_⟩
    rw [hspec]
    rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

/-- Positive NaNs: the 8 388 607 patterns `0x7F800001`–`0x7FFFFFFF`. -/
theorem holdsOnBits_pos_nan :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0x7F800001 0x80000000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hexec := exec_of_posInf_or_pos_nan (mode := mode) b (by bv_omega) (by bv_omega)
    have hnan : f32(b).isNaN = true :=
      Binary32.isNaN_iff.mpr (.inl (by rw [toNatBits_ofBits]; omega))
    refine ⟨_, Func.runUnary_of_exec_ofFloat hexec, .inr ⟨isNaN_add_of_isNaN_left mode hnan, ?_⟩⟩
    rw [ExpRanges.eval_of_isNaN hnan]
    decide +kernel

/-- Underflow: the 1 018 170 955 patterns `0xC2CFF1B5`–`0xFF7FFFFF`. -/
theorem holdsOnBits_underflow (hmode : mode ∈ cModes) :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0xC2CFF1B5 0xFF800000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hexec := exec_of_large_neg (mode := mode) b hmode (by bv_omega) (by bv_omega)
    have hspec := ExpRanges.eval_of_underflow_bits (x := f32(b)) hmode
      ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩
    exact ⟨_, Func.runUnary_of_exec_exact hexec, .inl hspec.symm⟩

/-- `-∞`: the pattern `0xFF800000`. -/
theorem holdsOnBits_negInf :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0xFF800000 0xFF800001 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    obtain rfl : b = 0xFF800000#32 := by bv_omega
    exact ⟨_, Func.runUnary_of_exec_exact (exec_of_negInf (mode := mode)),
      .inl (ExpRanges.eval_of_negInf_bits (x := f32(0xFF800000#32)) rfl).symm⟩

/-- Negative NaNs: the 8 388 607 patterns `0xFF800001`–`0xFFFFFFFF`. -/
theorem holdsOnBits_neg_nan :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode)
      0xFF800001 0x100000000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hexec := exec_of_neg_nan (mode := mode) b (by bv_omega)
    have hnan : f32(b).isNaN = true :=
      Binary32.isNaN_iff.mpr (.inr (by rw [toNatBits_ofBits]; omega))
    refine ⟨_, Func.runUnary_of_exec_exact hexec, .inr ⟨hnan, ?_⟩⟩
    rw [ExpRanges.eval_of_isNaN hnan]
    decide +kernel

end LibcMath.Extracted.ExpfPaths
