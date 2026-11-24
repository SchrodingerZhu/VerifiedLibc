import LibcMath.Extracted.Expf.Plans
import LibcMath.Functions.Binary32Bits

/-!
# The short paths of `Expf.DoubleEval.expf`, evaluated symbolically

Evaluates the extracted function on a symbolic `Model.ofBits b` (`b : BitVec 32`) for every input
that returns before the tables and the polynomial. Each theorem says that the function has a
result there, `some …`, and what it is: none of the operations that C++ leaves undefined is
reached on these paths, so no side condition has to be proved.

Only the plan `double_eval` is treated. The other extracted plans have no proofs.
-/

namespace LibcMath.Extracted.Expf.Paths

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Core
open LibcMath.Core.DSL

/-! ## `BitVec 32` and `binary32` field helpers -/

variable {mode : IEEERoundingMode} (b : BitVec 32)

private theorem toNatBits_f32 (b : BitVec 32) : f32(b).toNatBits = b.toNat := rfl

private theorem uintval_f32 (b : BitVec 32) :
    Core.FPBits.uintval f32(b) = b :=
  rfl

private theorem expField_f32 (b : BitVec 32) :
    f32(b).expField = (b.toNat % 2 ^ 31) / 2 ^ 23 := by
  have h1 : f32(b).toNatBits =
      (if f32(b).signBit then 0x80000000 else 0) + f32(b).magnitudeBits :=
    Model.toNatBits_eq_magnitude f32(b)
  have h2 : f32(b).expField < 256 := Model.expField_lt_pow2 f32(b)
  have h3 : f32(b).fracField < 0x800000 := Model.fracField_lt_pow2 f32(b)
  have hmag : f32(b).magnitudeBits = f32(b).expField * 0x800000 + f32(b).fracField := rfl
  have hbits : f32(b).toNatBits = b.toNat := rfl
  rw [hbits, hmag] at h1
  split at h1 <;> omega

private theorem abs_toNat (b : BitVec 32) :
    (b &&& 0x7FFFFFFF#32).toNat = b.toNat % 2 ^ 31 := by
  rw [BitVec.toNat_and]
  exact Nat.and_two_pow_sub_one_eq_mod b.toNat 31

private theorem biasedExp_sle_0x65 (b : BitVec 32) :
    BitVec.sle (BitVec.setWidth 32 (Core.FPBits.biasedExp f32(b))) 0x65#32 =
      decide (b.toNat % 2 ^ 31 < 0x33000000) := by
  have hexp_lt : f32(b).expField < 256 := Model.expField_lt_pow2 f32(b)
  have hexp := expField_f32 b
  have h0x65 : (0x65#32).toInt = 101 := rfl
  simp only [Core.FPBits.biasedExp, BitVec.sle_eq_decide, BitVec.toInt_setWidth,
    BitVec.toNat_ofNat, h0x65]
  have hmod1 : f32(b).expField % 2 ^ 16 = f32(b).expField := Nat.mod_eq_of_lt (by omega)
  rw [hmod1]
  have hbmod : ((f32(b).expField : Int).bmod (2 ^ 32)) = (f32(b).expField : Int) := by
    rw [Int.bmod_def]
    have h1 : (f32(b).expField : Int) % (2 ^ 32 : Nat) = (f32(b).expField : Int) :=
      Int.emod_eq_of_lt (by omega) (by omega)
    rw [h1]
    simp
    omega
  rw [hbmod]
  cases h : decide (b.toNat % 2 ^ 31 < 0x33000000) <;>
    simp only [decide_eq_true_eq, decide_eq_false_iff_not] at h ⊢ <;> omega

private theorem ule_iff_toNat (a c : BitVec 32) :
    BitVec.ule a c = decide (a.toNat ≤ c.toNat) := by
  simp [BitVec.ule]

private theorem ult_iff_toNat (a c : BitVec 32) :
    BitVec.ult a c = decide (a.toNat < c.toNat) := by
  simp [BitVec.ult]

private theorem ne_except_of_toNat_ne (b : BitVec 32) (h : b.toNat ≠ 0xC236BD8C) :
    (b == 0xC236BD8C#32) = false := by
  rw [beq_eq_false_iff_ne]
  intro heq
  apply h
  rw [heq]
  rfl

/-! ## `Expf.DoubleEval.expf` short paths -/

/-- For `|x| ≤ 2⁻²⁶` (including `±0`), `DoubleEval.expf` returns `1 + x`. -/
theorem doubleEval_of_small (hb : b.toNat % 2 ^ 31 ≤ 0x32800000) :
    Expf.DoubleEval.expf mode f32(b) =
      some (Model.add (Model.posOne .binary32) f32(b) mode) := by
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b (by omega)
  have houter : BitVec.ule (b &&& 0x7FFFFFFF#32) 0x32800000#32 = true := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  have hsmall : BitVec.sle (BitVec.setWidth 32 (Core.FPBits.biasedExp f32(b))) 0x65#32 = true := by
    rw [biasedExp_sle_0x65]; simp; omega
  unfold Expf.DoubleEval.expf
  dsimp only [Core.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.or_true, ↓reduceIte, hsmall, Core.fadd,
    Bool.false_eq_true]
  rfl

/-- At `-∞`, `DoubleEval.expf` returns `+0`. -/
theorem doubleEval_of_negInf :
    Expf.DoubleEval.expf mode (Model.negInf .binary32) = some (Model.posZero .binary32) := by
  cases mode <;> decide +kernel

/-- At a negative NaN (`0xFF800001`–`0xFFFFFFFF`), `DoubleEval.expf` returns `x` unchanged. -/
theorem doubleEval_of_neg_nan (hb : 0xFF800001 ≤ b.toNat) :
    Expf.DoubleEval.expf mode f32(b) = some f32(b) := by
  have hlt := b.isLt
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b (by omega)
  have houter : BitVec.ule 0x42B17218#32 (b &&& 0x7FFFFFFF#32) = true := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  have hsmall : BitVec.sle (BitVec.setWidth 32 (Core.FPBits.biasedExp f32(b))) 0x65#32 = false := by
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
  unfold Expf.DoubleEval.expf
  dsimp only [Core.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.true_or, ↓reduceIte, hsmall, huf,
    Core.FPBits.isInf, Core.FPBits.isNaN, hinf, hnan, Bool.false_eq_true]
  rfl

/-- On finite underflow inputs `0xC2CFF1B5`–`0xFF7FFFFF`, `DoubleEval.expf` returns `2⁻¹⁴⁹` when
rounding up and `+0` otherwise. -/
theorem doubleEval_of_underflow (hmode : mode ∈ cModes) (hlo : 0xC2CFF1B5 ≤ b.toNat)
    (hhi : b.toNat ≤ 0xFF7FFFFF) :
    Expf.DoubleEval.expf mode f32(b) =
      some (if mode = .up then Model.posMinSubnormal .binary32 else Model.posZero .binary32) := by
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b (by omega)
  have houter : BitVec.ule 0x42B17218#32 (b &&& 0x7FFFFFFF#32) = true := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  have hsmall : BitVec.sle (BitVec.setWidth 32 (Core.FPBits.biasedExp f32(b))) 0x65#32 = false := by
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
  unfold Expf.DoubleEval.expf
  dsimp only [Core.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.true_or, ↓reduceIte, hsmall, huf,
    Core.FPBits.isInf, Core.FPBits.isNaN, hinf, hnan, Bool.false_eq_true]
  rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

/-- On finite overflow inputs `0x42B17218`–`0x7F7FFFFF`, `DoubleEval.expf` returns `FLT_MAX` when
rounding toward zero or down, and `+∞` otherwise. -/
theorem doubleEval_of_overflow (hmode : mode ∈ cModes) (hlo : 0x42B17218 ≤ b.toNat)
    (hhi : b.toNat ≤ 0x7F7FFFFF) :
    Expf.DoubleEval.expf mode f32(b) =
      some (if mode = .towardZero ∨ mode = .down then Model.posMaxFinite .binary32
        else Model.posInf .binary32) := by
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b (by omega)
  have houter : BitVec.ule 0x42B17218#32 (b &&& 0x7FFFFFFF#32) = true := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  have hsmall : BitVec.sle (BitVec.setWidth 32 (Core.FPBits.biasedExp f32(b))) 0x65#32 = false := by
    rw [biasedExp_sle_0x65]; simp; omega
  have huf : BitVec.ule 0xC2CFF1B5#32 b = false := by
    rw [ule_iff_toNat]; simp; omega
  have hpos : f32(b).signBit = false :=
    (Binary32.signBit_eq_false_iff _).mpr (by rw [toNatBits_f32]; omega)
  have hov : BitVec.ule 0x42B17218#32 b = true := by
    rw [ule_iff_toNat]; simp; omega
  have hfin : BitVec.ult b 0x7F800000#32 = true := by
    rw [ult_iff_toNat]; simp; omega
  unfold Expf.DoubleEval.expf
  dsimp only [Core.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.true_or, ↓reduceIte, hsmall, huf,
    Core.FPBits.isPos, hpos, Bool.not_false, hov, Bool.and_self, hfin, Bool.false_eq_true]
  rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

/-- At `+∞` and positive NaNs (`0x7F800000`–`0x7FFFFFFF`), `DoubleEval.expf` returns `x + ∞`. -/
theorem doubleEval_of_posInf_or_pos_nan (hlo : 0x7F800000 ≤ b.toNat) (hhi : b.toNat ≤ 0x7FFFFFFF) :
    Expf.DoubleEval.expf mode f32(b) =
      some (Model.add f32(b) (Model.posInf .binary32) mode) := by
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b (by omega)
  have houter : BitVec.ule 0x42B17218#32 (b &&& 0x7FFFFFFF#32) = true := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  have hsmall : BitVec.sle (BitVec.setWidth 32 (Core.FPBits.biasedExp f32(b))) 0x65#32 = false := by
    rw [biasedExp_sle_0x65]; simp; omega
  have huf : BitVec.ule 0xC2CFF1B5#32 b = false := by
    rw [ule_iff_toNat]; simp; omega
  have hpos : f32(b).signBit = false :=
    (Binary32.signBit_eq_false_iff _).mpr (by rw [toNatBits_f32]; omega)
  have hov : BitVec.ule 0x42B17218#32 b = true := by
    rw [ule_iff_toNat]; simp; omega
  have hfin : BitVec.ult b 0x7F800000#32 = false := by
    rw [ult_iff_toNat]; simp; omega
  unfold Expf.DoubleEval.expf
  dsimp only [Core.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.true_or, ↓reduceIte, hsmall, huf,
    Core.FPBits.isPos, hpos, Bool.not_false, hov, Bool.and_self, hfin,
    Bool.false_eq_true, Core.fadd, Core.FPBits.getVal, Core.FPBits.inf, Core.Sign.isNeg]
  rfl

end LibcMath.Extracted.Expf.Paths
