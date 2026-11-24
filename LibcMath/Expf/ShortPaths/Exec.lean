import LibcMath.Expf.Plans
import LibcMath.Analysis.Binary32Bits

/-!
# The short paths of extracted `expf` kernels, evaluated symbolically

Evaluates the extracted `expf` functions on a symbolic `Model.ofBits b` (`b : BitVec 32`) for
every input that returns before the tables and the polynomial. Each theorem says that the function
has a result there, `some …`, and what it is: none of the operations that C++ leaves undefined is
reached on these paths, so no side condition has to be proved.

Covers four extracted plans:
* `Generated.DoubleEval.expf` (default x86-64, all 4 rounding modes)
* `Generated.DoubleEvalFma.expf` (`-mavx2 -mfma`, all 4 rounding modes)
* `Generated.StaticRounding.kernel` (pure integer `Frac64`, all 4 rounding modes)
* `Generated.IntegerEval.kernel` (pure integer `Frac64`, round-to-nearest-even, via
  `integerEval_eq_staticRounding_nearest`)
-/

namespace LibcMath.Expf.ShortPaths

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Libc.DSL

/-! ## `BitVec 32` and `binary32` field helpers -/

variable {mode : IEEERoundingMode} (b : BitVec 32)

private theorem toNatBits_f32 (b : BitVec 32) : f32(b).toNatBits = b.toNat := rfl

private theorem uintval_f32 (b : BitVec 32) :
    Libc.FPBits.uintval f32(b) = b :=
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
    BitVec.sle (BitVec.setWidth 32 (Libc.FPBits.biasedExp f32(b))) 0x65#32 =
      decide (b.toNat % 2 ^ 31 < 0x33000000) := by
  have hexp_lt : f32(b).expField < 256 := Model.expField_lt_pow2 f32(b)
  have hexp := expField_f32 b
  have h0x65 : (0x65#32).toInt = 101 := rfl
  simp only [Libc.FPBits.biasedExp, BitVec.sle_eq_decide, BitVec.toInt_setWidth,
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

/-! ## `Generated.DoubleEval.expf` short paths -/

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

/-! ## `Generated.DoubleEvalFma.expf` short paths

`DoubleEvalFma` shares identical short-path control flow and config flags (`noExcept = false`,
`assumeRoundNearestOnly = false`); hardware FMA and `nearest_integer` are used only on the main
polynomial path. -/

theorem doubleEvalFma_of_small (hb : b.toNat % 2 ^ 31 ≤ 0x32800000) :
    Generated.DoubleEvalFma.expf mode f32(b) =
      some (Model.add (Model.posOne .binary32) f32(b) mode) := by
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b (by omega)
  have houter : BitVec.ule (b &&& 0x7FFFFFFF#32) 0x32800000#32 = true := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  have hsmall : BitVec.sle (BitVec.setWidth 32 (Libc.FPBits.biasedExp f32(b))) 0x65#32 = true := by
    rw [biasedExp_sle_0x65]; simp; omega
  unfold Generated.DoubleEvalFma.expf
  dsimp only [Libc.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.or_true, ↓reduceIte, hsmall, Libc.fadd,
    Bool.false_eq_true]
  rfl

theorem doubleEvalFma_of_negInf :
    Generated.DoubleEvalFma.expf mode (Model.negInf .binary32) =
      some (Model.posZero .binary32) := by
  cases mode <;> decide +kernel

theorem doubleEvalFma_of_neg_nan (hb : 0xFF800001 ≤ b.toNat) :
    Generated.DoubleEvalFma.expf mode f32(b) = some f32(b) := by
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
  unfold Generated.DoubleEvalFma.expf
  dsimp only [Libc.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.true_or, ↓reduceIte, hsmall, huf,
    Libc.FPBits.isInf, Libc.FPBits.isNaN, hinf, hnan, Bool.false_eq_true]
  rfl

theorem doubleEvalFma_of_underflow (hmode : mode ∈ cModes) (hlo : 0xC2CFF1B5 ≤ b.toNat)
    (hhi : b.toNat ≤ 0xFF7FFFFF) :
    Generated.DoubleEvalFma.expf mode f32(b) =
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
  unfold Generated.DoubleEvalFma.expf
  dsimp only [Libc.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.true_or, ↓reduceIte, hsmall, huf,
    Libc.FPBits.isInf, Libc.FPBits.isNaN, hinf, hnan, Bool.false_eq_true]
  rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

theorem doubleEvalFma_of_overflow (hmode : mode ∈ cModes) (hlo : 0x42B17218 ≤ b.toNat)
    (hhi : b.toNat ≤ 0x7F7FFFFF) :
    Generated.DoubleEvalFma.expf mode f32(b) =
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
  unfold Generated.DoubleEvalFma.expf
  dsimp only [Libc.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.true_or, ↓reduceIte, hsmall, huf,
    Libc.FPBits.isPos, hpos, Bool.not_false, hov, Bool.and_self, hfin, Bool.false_eq_true]
  rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

theorem doubleEvalFma_of_posInf_or_pos_nan (hlo : 0x7F800000 ≤ b.toNat)
    (hhi : b.toNat ≤ 0x7FFFFFFF) :
    Generated.DoubleEvalFma.expf mode f32(b) =
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
  unfold Generated.DoubleEvalFma.expf
  dsimp only [Libc.FPBits.ofVal]
  simp only [uintval_f32, hne, houter, Bool.true_or, ↓reduceIte, hsmall, huf,
    Libc.FPBits.isPos, hpos, Bool.not_false, hov, Bool.and_self, hfin,
    Bool.false_eq_true, Libc.fadd, Libc.FPBits.getVal, Libc.FPBits.inf, Libc.Sign.isNeg]
  rfl

/-! ## `Generated.StaticRounding.kernel` & `Generated.IntegerEval.kernel` short paths

Pure integer `BitVec 32` evaluation: every short-path branch reduces directly without floating-point
arithmetic, covering the wider small-argument range `|x| < 2⁻²⁵` (`x_e ≤ 0x65`, i.e., up to
`0x32FFFFFF` and `0xB2FFFFFF`). -/

private theorem xe_toNat (b : BitVec 32) :
    ((b &&& 0x7FFFFFFF#32) >>> 23).toNat = (b.toNat % 2 ^ 31) / 2 ^ 23 := by
  rw [BitVec.toNat_ushiftRight, abs_toNat, Nat.shiftRight_eq_div_pow]

private theorem isNeg_iff (b : BitVec 32) :
    ((b >>> 31) != 0x0#32) = decide (0x80000000 ≤ b.toNat) := by
  have hlt := b.isLt
  have hr : (b >>> 31).toNat = b.toNat / 2 ^ 31 := by
    rw [BitVec.toNat_ushiftRight, Nat.shiftRight_eq_div_pow]
  cases h : decide (0x80000000 ≤ b.toNat)
  · simp only [decide_eq_false_iff_not] at h
    have : b >>> 31 = 0x0#32 := BitVec.eq_of_toNat_eq (by rw [hr]; simp; omega)
    simp [this]
  · simp only [decide_eq_true_eq] at h
    have : b >>> 31 ≠ 0x0#32 := fun heq => by
      have := congrArg BitVec.toNat heq; rw [hr] at this; simp at this; omega
    simp [bne_iff_ne, this]

private theorem xe_sub_ule_of_small (b : BitVec 32) (hb : b.toNat % 2 ^ 31 ≤ 0x32FFFFFF) :
    BitVec.ule 0x1F#32 (((b &&& 0x7FFFFFFF#32) >>> 23) - 0x66#32) = true ∧
    BitVec.ule ((b &&& 0x7FFFFFFF#32) >>> 23) 0x65#32 = true := by
  have hxe := xe_toNat b
  constructor
  · rw [ule_iff_toNat, BitVec.toNat_sub, hxe]
    simp only [BitVec.toNat_ofNat, Nat.reducePow, Nat.reduceMod]
    rw [decide_eq_true_eq]
    have : (b.toNat % 2147483648) / 8388608 ≤ 0x65 := by omega
    omega
  · rw [ule_iff_toNat, hxe]; simp; omega

private theorem xe_sub_ule_of_large (b : BitVec 32) (hb : 0x42B17218 ≤ b.toNat % 2 ^ 31) :
    BitVec.ule 0x1F#32 (((b &&& 0x7FFFFFFF#32) >>> 23) - 0x66#32) = true ∧
    BitVec.ule ((b &&& 0x7FFFFFFF#32) >>> 23) 0x65#32 = false := by
  have hxe := xe_toNat b
  have hlt : b.toNat % 2 ^ 31 < 2 ^ 31 := Nat.mod_lt _ (by norm_num)
  constructor
  · rw [ule_iff_toNat, BitVec.toNat_sub, hxe]
    simp only [BitVec.toNat_ofNat, Nat.reducePow, Nat.reduceMod]
    rw [decide_eq_true_eq]
    have h1 : 0x85 ≤ (b.toNat % 2147483648) / 8388608 := by omega
    have h2 : (b.toNat % 2147483648) / 8388608 ≤ 0xFF := by omega
    omega
  · rw [ule_iff_toNat, hxe]; simp; omega

private theorem staticRounding_kernel_f32 (mode : IEEERoundingMode) (b : BitVec 32) :
    Generated.StaticRounding.kernel mode f32(b) =
      (Generated.StaticRounding.expf_bits b (Libc.quickGetRound mode)).bind
        (fun r => some f32(r)) :=
  rfl

theorem staticRounding_of_zero (hb : b.toNat = 0 ∨ b.toNat = 0x80000000) :
    Generated.StaticRounding.kernel mode f32(b) = some (Model.posOne .binary32) := by
  rw [staticRounding_kernel_f32]
  have habs : b &&& 0x7FFFFFFF#32 = 0x0#32 :=
    BitVec.eq_of_toNat_eq (by rw [abs_toNat]; rcases hb with h | h <;> simp [h])
  unfold Generated.StaticRounding.expf_bits
  dsimp only
  simp only [habs, bne_self_eq_false, ↓reduceIte, Bool.false_eq_true]
  rfl

theorem staticRounding_of_tiny_pos (hmode : mode ∈ cModes)
    (hlo : 0x00000001 ≤ b.toNat) (hhi : b.toNat ≤ 0x32FFFFFF) :
    Generated.StaticRounding.kernel mode f32(b) =
      some (if mode = .up then Model.ofNatBits 0x3F800001 else Model.posOne .binary32) := by
  rw [staticRounding_kernel_f32]
  obtain ⟨h1, h2⟩ := xe_sub_ule_of_small b (by omega)
  have hneg : ((b >>> 31) != 0x0#32) = false := by rw [isNeg_iff]; simp; omega
  have hnz : ((b &&& 0x7FFFFFFF#32) != 0x0#32) = true := by
    rw [bne_iff_ne]
    intro heq
    have := congrArg BitVec.toNat heq
    rw [abs_toNat] at this
    simp at this
    omega
  unfold Generated.StaticRounding.expf_bits
  dsimp only
  simp only [h1, h2, hneg, hnz, Bool.not_false, Bool.and_true, Bool.and_false, ↓reduceIte,
    Bool.false_eq_true]
  rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

theorem staticRounding_of_tiny_neg (hmode : mode ∈ cModes)
    (hlo : 0x80000001 ≤ b.toNat) (hhi : b.toNat ≤ 0xB2FFFFFF) :
    Generated.StaticRounding.kernel mode f32(b) =
      some (if mode = .towardZero ∨ mode = .down then Model.ofNatBits 0x3F7FFFFF
        else Model.posOne .binary32) := by
  rw [staticRounding_kernel_f32]
  obtain ⟨h1, h2⟩ := xe_sub_ule_of_small b (by omega)
  have hneg : ((b >>> 31) != 0x0#32) = true := by rw [isNeg_iff]; simp; omega
  have hnz : ((b &&& 0x7FFFFFFF#32) != 0x0#32) = true := by
    rw [bne_iff_ne]
    intro heq
    have := congrArg BitVec.toNat heq
    rw [abs_toNat] at this
    simp at this
    omega
  unfold Generated.StaticRounding.expf_bits
  dsimp only
  simp only [h1, h2, hneg, hnz, Bool.not_true, Bool.and_true, Bool.and_false, ↓reduceIte,
    Bool.false_eq_true]
  rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

theorem staticRounding_of_nan
    (hb : (0x7F800001 ≤ b.toNat ∧ b.toNat ≤ 0x7FFFFFFF) ∨ 0xFF800001 ≤ b.toNat) :
    Generated.StaticRounding.kernel mode f32(b) = some f32(b ||| 0x400000#32) := by
  have hlt := b.isLt
  rw [staticRounding_kernel_f32]
  obtain ⟨h1, h2⟩ := xe_sub_ule_of_large b (by rcases hb with ⟨_, _⟩ | _ <;> omega)
  have hnan : BitVec.ult 0x7F800000#32 (b &&& 0x7FFFFFFF#32) = true := by
    rw [ult_iff_toNat, abs_toNat]; simp; rcases hb with ⟨_, _⟩ | _ <;> omega
  unfold Generated.StaticRounding.expf_bits
  dsimp only
  simp only [h1, h2, hnan, ↓reduceIte, Bool.false_eq_true]
  rfl

theorem staticRounding_of_overflow (hmode : mode ∈ cModes)
    (hlo : 0x42B17218 ≤ b.toNat) (hhi : b.toNat ≤ 0x7F7FFFFF) :
    Generated.StaticRounding.kernel mode f32(b) =
      some (if mode = .towardZero ∨ mode = .down then Model.posMaxFinite .binary32
        else Model.posInf .binary32) := by
  rw [staticRounding_kernel_f32]
  obtain ⟨h1, h2⟩ := xe_sub_ule_of_large b (by omega)
  have hneg : ((b >>> 31) != 0x0#32) = false := by rw [isNeg_iff]; simp; omega
  have hnan : BitVec.ult 0x7F800000#32 (b &&& 0x7FFFFFFF#32) = false := by
    rw [ult_iff_toNat, abs_toNat]; simp; omega
  have hov : BitVec.ule 0x42B17218#32 b = true := by rw [ule_iff_toNat]; simp; omega
  have hfin : BitVec.ult b 0x7F800000#32 = true := by rw [ult_iff_toNat]; simp; omega
  unfold Generated.StaticRounding.expf_bits
  dsimp only
  simp only [h1, h2, hneg, hnan, hov, hfin, Bool.not_false, Bool.and_true, ↓reduceIte,
    Bool.false_eq_true]
  rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

theorem staticRounding_of_posInf :
    Generated.StaticRounding.kernel mode (Model.posInf .binary32) =
      some (Model.posInf .binary32) := by
  cases mode <;> decide +kernel

theorem staticRounding_of_underflow (hmode : mode ∈ cModes)
    (hlo : 0xC2CFF1B5 ≤ b.toNat) (hhi : b.toNat ≤ 0xFF7FFFFF) :
    Generated.StaticRounding.kernel mode f32(b) =
      some (if mode = .up then Model.posMinSubnormal .binary32 else Model.posZero .binary32) := by
  rw [staticRounding_kernel_f32]
  obtain ⟨h1, h2⟩ := xe_sub_ule_of_large b (by omega)
  have hneg : ((b >>> 31) != 0x0#32) = true := by rw [isNeg_iff]; simp; omega
  have hnan : BitVec.ult 0x7F800000#32 (b &&& 0x7FFFFFFF#32) = false := by
    rw [ult_iff_toNat, abs_toNat]; simp; omega
  have huf : BitVec.ule 0xC2CFF1B5#32 b = true := by rw [ule_iff_toNat]; simp; omega
  have hfin : BitVec.ult b 0xFF800000#32 = true := by rw [ult_iff_toNat]; simp; omega
  unfold Generated.StaticRounding.expf_bits
  dsimp only
  simp only [h1, h2, hneg, hnan, huf, hfin, Bool.not_true, Bool.false_and, Bool.and_true,
    ↓reduceIte, Bool.false_eq_true]
  rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel

theorem staticRounding_of_negInf :
    Generated.StaticRounding.kernel mode (Model.negInf .binary32) =
      some (Model.posZero .binary32) := by
  cases mode <;> decide +kernel

/-- `Generated.IntegerEval.kernel .nearest` is identical to
`Generated.StaticRounding.kernel .nearest` on every binary32 input (the
`#ifndef LIBC_MATH_HAS_ASSUME_ROUND_NEAREST_ONLY` branches are dead when
`rounding = FE_TONEAREST = 0`). -/
theorem integerEval_eq_staticRounding_nearest (x : Model .binary32) :
    Generated.IntegerEval.kernel .nearest x = Generated.StaticRounding.kernel .nearest x := by
  have hq : Libc.quickGetRound .nearest = 0x0#32 := rfl
  simp only [Generated.IntegerEval.kernel, Generated.StaticRounding.kernel,
    Generated.IntegerEval.expf, Generated.IntegerEval.math_static_rounding_expf,
    Generated.StaticRounding.expf, hq]
  have hbits : ∀ b : BitVec 32,
      Generated.IntegerEval.expf_bits b 0x0#32 = Generated.StaticRounding.expf_bits b 0x0#32 := by
    intro b
    unfold Generated.IntegerEval.expf_bits Generated.StaticRounding.expf_bits
    have heval : ∀ u_bits is_neg,
        Generated.IntegerEval.exp2f_eval_bits u_bits is_neg 0x0#32 =
          Generated.StaticRounding.exp2f_eval_bits u_bits is_neg 0x0#32 := by
      intro u_bits is_neg
      unfold Generated.IntegerEval.exp2f_eval_bits Generated.StaticRounding.exp2f_eval_bits
      have hc : ∀ a c, Libc.Frac64.mul Generated.IntegerEval.config a c =
          Libc.Frac64.mul Generated.StaticRounding.config a c := fun _ _ => rfl
      have he : Generated.IntegerEval.EXP2F_COEFFS = Generated.StaticRounding.EXP2F_COEFFS := rfl
      have hm : ∀ u2 (cs : List Libc.Frac64),
          Libc.polyevalList Generated.IntegerEval.config .nearest u2 cs =
            Libc.polyevalList Generated.StaticRounding.config .nearest u2 cs := by
        intro u2 cs
        induction cs with
        | nil => rfl
        | cons c cs ih =>
          cases cs with
          | nil => rfl
          | cons c' cs' =>
            simp only [Libc.polyevalList, Libc.PolyElem.madd, Libc.Frac64.mul]
            rw [ih]
            rfl
      have hma : ∀ (a c d : Libc.Frac64),
          Libc.PolyElem.madd Generated.IntegerEval.config .nearest a c d =
            Libc.PolyElem.madd Generated.StaticRounding.config .nearest a c d := fun _ _ _ => rfl
      simp only [hc, he, hm, hma, bne_self_eq_false, ↓reduceIte, Bool.false_eq_true]
    have hsc : ∀ x_u x_e,
        Generated.IntegerEval.exp_b_scale x_u x_e Generated.IntegerEval.LOG2_E 0x85#32 =
          Generated.StaticRounding.exp_b_scale x_u x_e Generated.StaticRounding.LOG2_E 0x85#32 :=
      fun _ _ => rfl
    simp [heval, hsc]
  rw [hbits]

end LibcMath.Expf.ShortPaths
