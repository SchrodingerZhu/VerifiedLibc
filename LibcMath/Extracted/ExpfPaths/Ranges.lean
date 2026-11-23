import LibcMath.Exhaustive.Reduction
import LibcMath.Extracted.ExpfPaths.Exec
import LibcMath.Functions.AddRounding
import LibcMath.Functions.AddSpecial
import LibcMath.Functions.ExpRanges

/-!
# `expf` on the arguments that take a short path

For each rounding direction of C, the interpreter's result on the extracted `expf` is the
correctly rounded exponential on the following ranges of bit patterns, by a proof that treats
each range at once. The paths are those of `ExpfPaths/Exec.lean`, and the correctly rounded
results are those of `Functions/ExpRanges.lean`.

* `holdsOnBits_small_pos`: `0x00000000`–`0x32800000`, that is `+0` and `0 < x ≤ 2⁻²⁶`, where the
  code returns `x + 1`;
* `holdsOnBits_overflow`: `0x42B20000`–`0x7F7FFFFF`, where the result overflows;
* `holdsOnBits_posInf` and `holdsOnBits_pos_nan`: `0x7F800000` and `0x7F800001`–`0x7FFFFFFF`;
* `holdsOnBits_small_neg`: `0x80000000`–`0xB2800000`, that is `-0` and `-2⁻²⁶ ≤ x < 0`, where
  the code returns `x + 1`;
* `holdsOnBits_underflow`: `0xC2CFF1B5`–`0xFF7FFFFF`, where the result is at most half the least
  positive value;
* `holdsOnBits_negInf` and `holdsOnBits_neg_nan`: `0xFF800000` and `0xFF800001`–`0xFFFFFFFF`.

The statements have the form `HoldsOnBits (RunsCorrectlyAt …) lo hi` with `hi` excluded, ready
for `HoldsOnBits.append`. `holdsOnBits_short_paths` joins them into three ranges, which hold
3 749 580 365 of the 2³² bit patterns (87.3 %), and `holdsOnBits_short_paths_nearest`,
`…_towardZero`, `…_up` and `…_down` state it for each direction.

## What remains

The ranges are the same in the four directions, because no branch that selects a short path
depends on the direction. In each of them the following 545 386 931 bit patterns remain, all of
which the code sends to its polynomial evaluation (block 15), except `0xC236BD8C`, which it
treats in a block of its own (block 1):

* `0x32800001`–`0x42B1FFFF` (271 712 255 patterns), `2⁻²⁶ < x < 89`;
* `0xB2800001`–`0xC2CFF1B4` (273 674 676 patterns), `-103.98 < x < -2⁻²⁶`.

`Functions/ExpRanges.lean` has the correctly rounded result in closed form on part of them
(`0x32800001`–`0x337FFFFF`, `0x42B17218`–`0x42B1FFFF`, `0xB2800001`–`0xB3000000`,
`0xC2CE8ED0`–`0xC2CFF1B4`, and more when not rounding to nearest), but there the code computes
the result with its polynomial, so nothing here applies.
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

/-- The code returns `x + 1`, with `1` as the constant `0x3F800000`. -/
private theorem runUnary_of_small (b : BitVec 32) (hb : b.toNat % 2 ^ 31 ≤ 0x32800000) :
    expf.runUnary mode f32(b) = some (Model.add f32(b) (posOne .binary32) mode) :=
  Func.runUnary_of_exec_ofFloat (exec_of_small b hb)

/-- `+0` and `0 < x ≤ 2⁻²⁶`: the 847 249 409 patterns `0x00000000`–`0x32800000`. -/
theorem holdsOnBits_small_pos (hmode : mode ∈ cModes) :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0x00000000 0x32800001 :=
  holdsOnBits_of_forall_bitVec fun b _ hhi => by
    refine ⟨_, runUnary_of_small b (by omega), .inl ?_⟩
    by_cases hzero : b.toNat = 0
    · rw [add_one_of_zero_bits (x := f32(b)) hmode (.inl hzero),
        ExpRanges.eval_of_zero_bits (x := f32(b)) (.inl hzero)]
    · have hbits : 0x00000001 ≤ f32(b).toNatBits ∧ f32(b).toNatBits ≤ 0x32800000 := by
        rw [toNatBits_ofBits]
        omega
      rw [add_one_of_tiny_pos_bits hmode hbits,
        ExpRanges.eval_of_tiny_pos_bits hmode ⟨hbits.1, by omega⟩]

/-- `-0` and `-2⁻²⁶ ≤ x < 0`: the 847 249 409 patterns `0x80000000`–`0xB2800000`. -/
theorem holdsOnBits_small_neg (hmode : mode ∈ cModes) :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0x80000000 0xB2800001 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    refine ⟨_, runUnary_of_small b (by omega), .inl ?_⟩
    by_cases hzero : b.toNat = 0x80000000
    · rw [add_one_of_zero_bits (x := f32(b)) hmode (.inr hzero),
        ExpRanges.eval_of_zero_bits (x := f32(b)) (.inr hzero)]
    · have hbits : 0x80000001 ≤ f32(b).toNatBits ∧ f32(b).toNatBits ≤ 0xB2800000 := by
        rw [toNatBits_ofBits]
        omega
      rw [add_one_of_tiny_neg_bits hmode hbits,
        ExpRanges.eval_of_tiny_neg_bits hmode ⟨hbits.1, by omega⟩]

/-- Overflow: the 1 020 133 376 patterns `0x42B20000`–`0x7F7FFFFF`. -/
theorem holdsOnBits_overflow (hmode : mode ∈ cModes) :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0x42B20000 0x7F800000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hexec := exec_of_large_pos (mode := mode) b hmode hlo (by omega)
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
    have hexec := exec_of_posInf_or_pos_nan (mode := mode) b (by omega) (by omega)
    have hspec := ExpRanges.eval_of_posInf_bits (mode := mode) (x := f32(b))
      (by rw [toNatBits_ofBits]; omega)
    obtain rfl : b = 0x7F800000#32 := BitVec.eq_of_toNat_eq (show b.toNat = 0x7F800000 by omega)
    refine ⟨_, Func.runUnary_of_exec_ofFloat hexec, .inl ?_⟩
    rw [hspec]
    rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

/-- Positive NaNs: the 8 388 607 patterns `0x7F800001`–`0x7FFFFFFF`. -/
theorem holdsOnBits_pos_nan :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0x7F800001 0x80000000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hexec := exec_of_posInf_or_pos_nan (mode := mode) b (by omega) (by omega)
    have hnan : f32(b).isNaN = true :=
      Binary32.isNaN_iff.mpr (.inl (by rw [toNatBits_ofBits]; omega))
    refine ⟨_, Func.runUnary_of_exec_ofFloat hexec, .inr ⟨isNaN_add_of_isNaN_left mode hnan, ?_⟩⟩
    rw [ExpRanges.eval_of_isNaN hnan]
    decide +kernel

/-- Underflow: the 1 018 170 955 patterns `0xC2CFF1B5`–`0xFF7FFFFF`. -/
theorem holdsOnBits_underflow (hmode : mode ∈ cModes) :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0xC2CFF1B5 0xFF800000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hexec := exec_of_large_neg (mode := mode) b hmode hlo (by omega)
    have hspec := ExpRanges.eval_of_underflow_bits (x := f32(b)) hmode
      ⟨by rw [toNatBits_ofBits]; omega, by rw [toNatBits_ofBits]; omega⟩
    exact ⟨_, Func.runUnary_of_exec_exact hexec, .inl hspec.symm⟩

/-- `-∞`: the pattern `0xFF800000`. -/
theorem holdsOnBits_negInf :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0xFF800000 0xFF800001 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    obtain rfl : b = 0xFF800000#32 := BitVec.eq_of_toNat_eq (show b.toNat = 0xFF800000 by omega)
    exact ⟨_, Func.runUnary_of_exec_exact (exec_of_negInf (mode := mode)),
      .inl (ExpRanges.eval_of_negInf_bits (x := f32(0xFF800000#32)) rfl).symm⟩

/-- Negative NaNs: the 8 388 607 patterns `0xFF800001`–`0xFFFFFFFF`. -/
theorem holdsOnBits_neg_nan :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode)
      0xFF800001 0x100000000 :=
  holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    have hexec := exec_of_neg_nan (mode := mode) b hlo
    have hnan : f32(b).isNaN = true :=
      Binary32.isNaN_iff.mpr (.inr (by rw [toNatBits_ofBits]; omega))
    refine ⟨_, Func.runUnary_of_exec_exact hexec, .inr ⟨hnan, ?_⟩⟩
    rw [ExpRanges.eval_of_isNaN hnan]
    decide +kernel

/-! ## All short paths together -/

/-- In each rounding direction of C, the interpreter's result on `expf` is correctly rounded on
`0x00000000`–`0x32800000`, on `0x42B20000`–`0xB2800000` and on `0xC2CFF1B5`–`0xFFFFFFFF`. -/
theorem holdsOnBits_short_paths (hmode : mode ∈ cModes) :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0x00000000 0x32800001 ∧
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode) 0x42B20000 0xB2800001 ∧
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary mode)
      0xC2CFF1B5 0x100000000 :=
  ⟨holdsOnBits_small_pos hmode,
    (((holdsOnBits_overflow hmode).append (holdsOnBits_posInf hmode)).append
      holdsOnBits_pos_nan).append (holdsOnBits_small_neg hmode),
    ((holdsOnBits_underflow hmode).append holdsOnBits_negInf).append holdsOnBits_neg_nan⟩

/-- The ranges proved when rounding to nearest. -/
theorem holdsOnBits_short_paths_nearest :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary .nearest)
      0x00000000 0x32800001 ∧
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary .nearest)
      0x42B20000 0xB2800001 ∧
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary .nearest)
      0xC2CFF1B5 0x100000000 :=
  holdsOnBits_short_paths (by simp [cModes])

/-- The ranges proved when rounding toward zero. -/
theorem holdsOnBits_short_paths_towardZero :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary .towardZero)
      0x00000000 0x32800001 ∧
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary .towardZero)
      0x42B20000 0xB2800001 ∧
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary .towardZero)
      0xC2CFF1B5 0x100000000 :=
  holdsOnBits_short_paths (by simp [cModes])

/-- The ranges proved when rounding up. -/
theorem holdsOnBits_short_paths_up :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary .up) 0x00000000 0x32800001 ∧
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary .up) 0x42B20000 0xB2800001 ∧
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary .up)
      0xC2CFF1B5 0x100000000 :=
  holdsOnBits_short_paths (by simp [cModes])

/-- The ranges proved when rounding down. -/
theorem holdsOnBits_short_paths_down :
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary .down) 0x00000000 0x32800001 ∧
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary .down) 0x42B20000 0xB2800001 ∧
    HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) expf.runUnary .down)
      0xC2CFF1B5 0x100000000 :=
  holdsOnBits_short_paths (by simp [cModes])

end LibcMath.Extracted.ExpfPaths
