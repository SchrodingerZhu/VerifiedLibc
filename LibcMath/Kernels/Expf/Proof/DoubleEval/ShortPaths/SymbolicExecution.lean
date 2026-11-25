import LibcMath.Kernels.Expf.Proof.Common

/-!
# The short paths of `Generated.DoubleEval.expf`, evaluated symbolically

Evaluates `Generated.DoubleEval.expf` (x86-64 without FMA, the four rounding directions of C) on a
symbolic `Model.ofBits b` (`b : BitVec 32`) for every input that returns before the tables and the
polynomial. Each theorem says that the function has a result there, `some …`, and what it is: none
of the operations that C++ leaves undefined is reached on these paths, so no side condition has to
be proved.
-/

namespace LibcMath.Kernels.Expf.Proof.DoubleEval.ShortPaths

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Libc.DSL

variable {mode : IEEERoundingMode} (b : BitVec 32)

/-- For `|x| ≤ 2⁻²⁶` (including `±0`), `DoubleEval.expf` returns `1 + x`. -/
theorem doubleEval_of_small (hb : b.toNat % 2 ^ 31 ≤ 0x32800000) :
    Generated.DoubleEval.expf mode f32(b) =
      some (Model.add (Model.posOne .binary32) f32(b) mode) := by
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b (by omega)
  have houter : BitVec.ule (b &&& 0x7FFFFFFF#32) 0x32800000#32 = true := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  have hsmall : BitVec.sle (BitVec.setWidth 32 (Libc.FPBits.biasedExp f32(b))) 0x65#32 = true := by
    rw [biasedExp_sle_0x65]; simp; omega
  unfold Generated.DoubleEval.expf
  dsimp only [Libc.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.or_true, ↓reduceIte, hsmall, Libc.fadd,
    Bool.false_eq_true]
  rfl

/-- At `-∞`, `DoubleEval.expf` returns `+0`. -/
theorem doubleEval_of_negInf :
    Generated.DoubleEval.expf mode (Model.negInf .binary32) = some (Model.posZero .binary32) := by
  cases mode <;> decide +kernel

/-- At a negative NaN (`0xFF800001`–`0xFFFFFFFF`), `DoubleEval.expf` returns `x` unchanged. -/
theorem doubleEval_of_neg_nan (hb : 0xFF800001 ≤ b.toNat) :
    Generated.DoubleEval.expf mode f32(b) = some f32(b) := by
  have hlt := b.isLt
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b (by omega)
  have houter : BitVec.ule 0x42B17218#32 (b &&& 0x7FFFFFFF#32) = true := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  have hsmall : BitVec.sle (BitVec.setWidth 32 (Libc.FPBits.biasedExp f32(b))) 0x65#32 = false := by
    rw [biasedExp_sle_0x65]; simp; omega
  have huf : BitVec.ule 0xC2CFF1B5#32 b = true := by
    rw [ule_iff_toNat]; simp; omega
  have hinf : f32(b).isInfinite = false :=
    Bool.eq_false_iff.mpr fun h => by
      have := Binary32.isInfinite_iff.mp h
      rw [toNatBits_f32] at this
      omega
  have hnan : f32(b).isNaN = true :=
    Binary32.isNaN_iff.mpr (.inr (by rw [toNatBits_f32]; omega))
  unfold Generated.DoubleEval.expf
  dsimp only [Libc.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.true_or, ↓reduceIte, hsmall, huf,
    Libc.FPBits.isInf, Libc.FPBits.isNaN, hinf, hnan, Bool.false_eq_true]
  rfl

/-- On finite underflow inputs `0xC2CFF1B5`–`0xFF7FFFFF`, `DoubleEval.expf` returns `2⁻¹⁴⁹` when
rounding up and `+0` otherwise. -/
theorem doubleEval_of_underflow (hmode : mode ∈ cModes) (hlo : 0xC2CFF1B5 ≤ b.toNat)
    (hhi : b.toNat ≤ 0xFF7FFFFF) :
    Generated.DoubleEval.expf mode f32(b) =
      some (if mode = .up then Model.posMinSubnormal .binary32 else Model.posZero .binary32) := by
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b (by omega)
  have houter : BitVec.ule 0x42B17218#32 (b &&& 0x7FFFFFFF#32) = true := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  have hsmall : BitVec.sle (BitVec.setWidth 32 (Libc.FPBits.biasedExp f32(b))) 0x65#32 = false := by
    rw [biasedExp_sle_0x65]; simp; omega
  have huf : BitVec.ule 0xC2CFF1B5#32 b = true := by
    rw [ule_iff_toNat]; simp; omega
  have hinf : f32(b).isInfinite = false :=
    Bool.eq_false_iff.mpr fun h => by
      have := Binary32.isInfinite_iff.mp h
      rw [toNatBits_f32] at this
      omega
  have hnan : f32(b).isNaN = false :=
    Bool.eq_false_iff.mpr fun h => by
      have := Binary32.isNaN_iff.mp h
      rw [toNatBits_f32] at this
      omega
  unfold Generated.DoubleEval.expf
  dsimp only [Libc.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.true_or, ↓reduceIte, hsmall, huf,
    Libc.FPBits.isInf, Libc.FPBits.isNaN, hinf, hnan, Bool.false_eq_true]
  rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

/-- On finite overflow inputs `0x42B17218`–`0x7F7FFFFF`, `DoubleEval.expf` returns `FLT_MAX` when
rounding toward zero or down, and `+∞` otherwise. -/
theorem doubleEval_of_overflow (hmode : mode ∈ cModes) (hlo : 0x42B17218 ≤ b.toNat)
    (hhi : b.toNat ≤ 0x7F7FFFFF) :
    Generated.DoubleEval.expf mode f32(b) =
      some (if mode = .towardZero ∨ mode = .down then Model.posMaxFinite .binary32
        else Model.posInf .binary32) := by
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b (by omega)
  have houter : BitVec.ule 0x42B17218#32 (b &&& 0x7FFFFFFF#32) = true := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  have hsmall : BitVec.sle (BitVec.setWidth 32 (Libc.FPBits.biasedExp f32(b))) 0x65#32 = false := by
    rw [biasedExp_sle_0x65]; simp; omega
  have huf : BitVec.ule 0xC2CFF1B5#32 b = false := by
    rw [ule_iff_toNat]; simp; omega
  have hpos : f32(b).signBit = false :=
    (Binary32.signBit_eq_false_iff _).mpr (by rw [toNatBits_f32]; omega)
  have hov : BitVec.ule 0x42B17218#32 b = true := by
    rw [ule_iff_toNat]; simp; omega
  have hfin : BitVec.ult b 0x7F800000#32 = true := by
    rw [ult_iff_toNat]; simp; omega
  unfold Generated.DoubleEval.expf
  dsimp only [Libc.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.true_or, ↓reduceIte, hsmall, huf,
    Libc.FPBits.isPos, hpos, Bool.not_false, hov, Bool.and_self, hfin, Bool.false_eq_true]
  rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

/-- At `+∞` and positive NaNs (`0x7F800000`–`0x7FFFFFFF`), `DoubleEval.expf` returns `x + ∞`. -/
theorem doubleEval_of_posInf_or_pos_nan (hlo : 0x7F800000 ≤ b.toNat) (hhi : b.toNat ≤ 0x7FFFFFFF) :
    Generated.DoubleEval.expf mode f32(b) =
      some (Model.add f32(b) (Model.posInf .binary32) mode) := by
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b (by omega)
  have houter : BitVec.ule 0x42B17218#32 (b &&& 0x7FFFFFFF#32) = true := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  have hsmall : BitVec.sle (BitVec.setWidth 32 (Libc.FPBits.biasedExp f32(b))) 0x65#32 = false := by
    rw [biasedExp_sle_0x65]; simp; omega
  have huf : BitVec.ule 0xC2CFF1B5#32 b = false := by
    rw [ule_iff_toNat]; simp; omega
  have hpos : f32(b).signBit = false :=
    (Binary32.signBit_eq_false_iff _).mpr (by rw [toNatBits_f32]; omega)
  have hov : BitVec.ule 0x42B17218#32 b = true := by
    rw [ule_iff_toNat]; simp; omega
  have hfin : BitVec.ult b 0x7F800000#32 = false := by
    rw [ult_iff_toNat]; simp; omega
  unfold Generated.DoubleEval.expf
  dsimp only [Libc.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.true_or, ↓reduceIte, hsmall, huf,
    Libc.FPBits.isPos, hpos, Bool.not_false, hov, Bool.and_self, hfin,
    Bool.false_eq_true, Libc.fadd, Libc.FPBits.getVal, Libc.FPBits.inf, Libc.Sign.isNeg]
  rfl

end LibcMath.Kernels.Expf.Proof.DoubleEval.ShortPaths
