import LibcMath.Kernels.Expf.Proof.Common

/-!
# The short paths of `Generated.StaticRounding.kernel`, evaluated symbolically

Evaluates `Generated.StaticRounding.kernel` (integer `Frac64`, the four rounding directions of C)
on a symbolic `Model.ofBits b` (`b : BitVec 32`) for every input that returns before the tables and
the polynomial. Each theorem says that the function has a result there, `some …`, and what it is:
none of the operations that C++ leaves undefined is reached on these paths, so no side condition
has to be proved.

Pure integer `BitVec 32` evaluation: every short-path branch reduces directly without floating-point
arithmetic, covering the wider small-argument range `|x| < 2⁻²⁵` (`x_e ≤ 0x65`, i.e., up to
`0x32FFFFFF` and `0xB2FFFFFF`).
-/

namespace LibcMath.Kernels.Expf.Proof.StaticRounding.ShortPaths

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Libc.DSL

variable {mode : IEEERoundingMode} (b : BitVec 32)

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

end LibcMath.Kernels.Expf.Proof.StaticRounding.ShortPaths
