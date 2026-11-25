import LibcMath.Framework.Correctness
import LibcMath.Kernels.Expf.Plans
import LibcMath.Analysis.Binary32Bits

/-!
# Facts about bit patterns that the proofs of every `expf` plan share

Fields of a binary32 value read from its `BitVec 32`, comparisons of bit vectors as comparisons of
naturals, and the step from a statement about all bit vectors to `HoldsOnBits`. Nothing here is
about one evaluation plan; what is goes under `Proof/<Plan>/`.
-/

namespace LibcMath.Kernels.Expf.Proof

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Libc.DSL

theorem toNatBits_f32 (b : BitVec 32) : f32(b).toNatBits = b.toNat := rfl

theorem uintval_f32 (b : BitVec 32) :
    Libc.FPBits.uintval f32(b) = b :=
  rfl

theorem expField_f32 (b : BitVec 32) :
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

theorem abs_toNat (b : BitVec 32) :
    (b &&& 0x7FFFFFFF#32).toNat = b.toNat % 2 ^ 31 := by
  rw [BitVec.toNat_and]
  exact Nat.and_two_pow_sub_one_eq_mod b.toNat 31

theorem biasedExp_sle_0x65 (b : BitVec 32) :
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

theorem ule_iff_toNat (a c : BitVec 32) :
    BitVec.ule a c = decide (a.toNat ≤ c.toNat) := by
  simp [BitVec.ule]

theorem ult_iff_toNat (a c : BitVec 32) :
    BitVec.ult a c = decide (a.toNat < c.toNat) := by
  simp [BitVec.ult]

theorem ne_except_of_toNat_ne (b : BitVec 32) (h : b.toNat ≠ 0xC236BD8C) :
    (b == 0xC236BD8C#32) = false := by
  rw [beq_eq_false_iff_ne]
  intro heq
  apply h
  rw [heq]
  rfl

/-- Lift a proof over 32-bit vectors to `HoldsOnBits` on `[lo, hi)`. -/
theorem holdsOnBits_of_forall_bitVec {P : Model .binary32 → Prop} {lo hi : ℕ}
    (h : ∀ b : BitVec 32, lo ≤ b.toNat → b.toNat < hi → P f32(b))
    (hrange : hi ≤ 2 ^ 32 := by norm_num) : HoldsOnBits P lo hi := by
  intro n hlo hhi
  have hmod : (BitVec.ofNat 32 n).toNat = n := by
    rw [BitVec.toNat_ofNat]
    omega
  exact h (BitVec.ofNat 32 n) (by omega) (by omega)

theorem toNatBits_ofBits (b : BitVec 32) : f32(b).toNatBits = b.toNat := rfl

end LibcMath.Kernels.Expf.Proof
