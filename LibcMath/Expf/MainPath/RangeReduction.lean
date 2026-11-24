import LibcMath.Analysis.Binary32Bits
import LibcMath.Analysis.RangeReduction
import LibcMath.Expf.Generated.DoubleEval

/-!
# Exact range reduction for `Generated.DoubleEval.expf`

Instantiates `LibcMath.Analysis.RangeReduction` for `Generated.DoubleEval.expf` on its main
polynomial ranges (`[0x32800001, 0x42B17218)` excluding `0x3B7FFFFF` and `[0xB2800001, 0xC2CFF1B5)`
excluding `0xC236BD8C` and `0xBB7FFFFF`):

1. enters the main continuation `cont ()`;
2. scales `x` exactly by `128`;
3. computes `kf = Libc.genericNearestInt false mode (128 * x)` as an exact integer `k` with
   `-13312 ≤ k ≤ 11392` and `|128 * x - k| ≤ 1 / 2`;
4. computes `r = submul(x, kf, 1/128)` without rounding error, with `|r| ≤ 1 / 256`;
5. widens `r` exactly to binary64 `xd`;
6. converts `kf` to `int32_t`, adds `104 * 128 = 13312` without signed overflow, and reads
   `EXP_M1[hiIdx]` and `EXP_M2[midIdx]` in bounds, satisfying
   `(hiIdx - 104) + midIdx / 128 + xd = x`.

When `|x| < 2⁻²⁴` (`[0x32800001, 0x33800000)` or `[0xB2800001, 0xB3000000)`), `k = 0`, so
`hiIdx = 104`, `midIdx = 0`, and `xd = x`.
-/

namespace LibcMath.Expf.MainPath.RangeReduction

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Libc.DSL

/-- Output of the exact range reduction on the main path of `Generated.DoubleEval.expf`. -/
structure MainReduction (mode : IEEERoundingMode) (b : BitVec 32) where
  hiIdx : ℕ
  midIdx : ℕ
  xd : Model .binary64
  hi_lt : hiIdx < Generated.DoubleEval.EXP_M1.size
  mid_lt : midIdx < Generated.DoubleEval.EXP_M2.size
  xd_finite : xd.isFinite = true
  xd_abs_le : |xd.toReal| ≤ 1 / 256
  decomp : ((hiIdx : ℤ) - 104 : ℝ) + (midIdx : ℝ) / 128 + xd.toReal = f32(b).toReal
  expf_eq : Generated.DoubleEval.expf mode f32(b) = some (
    Libc.fpCast .binary32 mode (
      Libc.fmul mode
        (Libc.fmul mode
          (Generated.DoubleEval.EXP_M1[hiIdx]'hi_lt)
          (Generated.DoubleEval.EXP_M2[midIdx]'mid_lt))
        (horner[Generated.DoubleEval.config, mode] xd
          [f64(0x3FF0000000000000#64), f64(0x3FEFFFFFFFFFF777#64),
           f64(0x3FE000000000071C#64), f64(0x3FC555566668E5E7#64),
           f64(0x3FA55555555EF243#64)])))

/-! ## Section 1: Control-flow routing into the main continuation -/

/-- The body of `cont ()` inside `Generated.DoubleEval.expf`. -/
private def mainBody (mode : IEEERoundingMode) (x : Model .binary32) :
    Option (Model .binary32) := do
  let kf := Libc.nearestInt Generated.DoubleEval.config mode (Libc.fmul mode x f32(0x43000000#32))
  let xd := Libc.fpCast .binary64 mode
    (submul[Generated.DoubleEval.config, mode](x, kf, f32(0x3C000000#32)))
  let x_hi ← Libc.fptosi? 32 kf
  let x_hi ← Libc.sadd? x_hi (0x68#32 <<< 7)
  let exp_hi ← Generated.DoubleEval.EXP_M1[(BitVec.sshiftRight x_hi 7).toNat]?
  let exp_mid ← Generated.DoubleEval.EXP_M2[(x_hi &&& 0x7F#32).toNat]?
  let exp_lo := horner[Generated.DoubleEval.config, mode] xd
    [f64(0x3FF0000000000000#64), f64(0x3FEFFFFFFFFFF777#64),
     f64(0x3FE000000000071C#64), f64(0x3FC555566668E5E7#64),
     f64(0x3FA55555555EF243#64)]
  pure (Libc.fpCast .binary32 mode (Libc.fmul mode (Libc.fmul mode exp_hi exp_mid) exp_lo))

private theorem toNatBits_f32 (b : BitVec 32) : f32(b).toNatBits = b.toNat := rfl

private theorem uintval_f32 (b : BitVec 32) : Libc.FPBits.uintval f32(b) = b := rfl

private theorem abs_toNat (b : BitVec 32) :
    (b &&& 0x7FFFFFFF#32).toNat = b.toNat % 2 ^ 31 := by
  rw [BitVec.toNat_and]
  exact Nat.and_two_pow_sub_one_eq_mod b.toNat 31

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

private theorem ne_except_of_toNat_ne (b : BitVec 32) (h : b.toNat ≠ 0xC236BD8C) :
    (b == 0xC236BD8C#32) = false := by
  rw [beq_eq_false_iff_ne]
  intro heq
  apply h
  rw [heq]
  rfl

private theorem expf_eq_mainBody_of_pos (mode : IEEERoundingMode) (b : BitVec 32)
    (hlo : 0x32800001 ≤ b.toNat) (hhi : b.toNat < 0x42B17218) :
    Generated.DoubleEval.expf mode f32(b) = mainBody mode f32(b) := by
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b (by omega)
  have hge : BitVec.ule 0x42B17218#32 (b &&& 0x7FFFFFFF#32) = false := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  have hle : BitVec.ule (b &&& 0x7FFFFFFF#32) 0x32800000#32 = false := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  unfold Generated.DoubleEval.expf
  dsimp only [Libc.FPBits.ofVal]
  simp only [uintval_f32, hne, hge, hle, Bool.or_self, Bool.false_eq_true, ↓reduceIte]
  rfl

private theorem expf_eq_mainBody_of_neg (mode : IEEERoundingMode) (b : BitVec 32)
    (hlo : 0xB2800001 ≤ b.toNat) (hhi : b.toNat < 0xC2CFF1B5)
    (hne1 : b.toNat ≠ 0xC236BD8C) :
    Generated.DoubleEval.expf mode f32(b) = mainBody mode f32(b) := by
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b hne1
  have hle : BitVec.ule (b &&& 0x7FFFFFFF#32) 0x32800000#32 = false := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  by_cases hmid : b.toNat < 0xC2B17218
  · have hge : BitVec.ule 0x42B17218#32 (b &&& 0x7FFFFFFF#32) = false := by
      rw [ule_iff_toNat, abs_toNat]; simp; omega
    unfold Generated.DoubleEval.expf
    dsimp only [Libc.FPBits.ofVal]
    simp only [uintval_f32, hne, hge, hle, Bool.or_self, Bool.false_eq_true, ↓reduceIte]
    rfl
  · have hge : BitVec.ule 0x42B17218#32 (b &&& 0x7FFFFFFF#32) = true := by
      rw [ule_iff_toNat, abs_toNat]; simp; omega
    have hsmall :
        BitVec.sle (BitVec.setWidth 32 (Libc.FPBits.biasedExp f32(b))) 0x65#32 = false := by
      rw [biasedExp_sle_0x65]; simp; omega
    have huf : BitVec.ule 0xC2CFF1B5#32 b = false := by
      rw [ule_iff_toNat]; simp; omega
    have hneg : f32(b).signBit = true :=
      (Binary32.signBit_eq_true_iff _).mpr (by rw [toNatBits_f32]; omega)
    unfold Generated.DoubleEval.expf
    dsimp only [Libc.FPBits.ofVal]
    simp only [uintval_f32, hne, hge, Bool.true_or, ↓reduceIte, hsmall, huf,
      Libc.FPBits.isPos, hneg, Bool.not_true, Bool.false_and, Bool.false_eq_true]
    rfl

/-! ## Section 2: Concrete binary32 constants for `expf` -/

private theorem isFinite_c128 : f32(0x43000000#32).isFinite = true := by decide +kernel
private theorem toReal_c128 : f32(0x43000000#32).toReal = 128 := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some (value := f32(0x43000000#32))
    (q := 128) (by decide +kernel)

private theorem isFinite_c128inv : f32(0x3C000000#32).isFinite = true := by decide +kernel
private theorem toReal_c128inv : f32(0x3C000000#32).toReal = 1 / 128 := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some (value := f32(0x3C000000#32))
    (q := 1 / 128) (by decide +kernel)

private theorem toReal_bound_pos89 :
    (Model.ofNatBits 0x42B20000 : Model .binary32).toReal = 89 := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some
    (value := (Model.ofNatBits 0x42B20000 : Model .binary32)) (q := 89) (by decide +kernel)

private theorem toReal_bound_neg104 :
    (Model.ofNatBits 0xC2D00000 : Model .binary32).toReal = -104 := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some
    (value := (Model.ofNatBits 0xC2D00000 : Model .binary32)) (q := -104) (by decide +kernel)

private theorem toReal_0x3B800000 :
    (Model.ofNatBits 0x3B800000 : Model .binary32).toReal = 1 / 256 := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some
    (value := (Model.ofNatBits 0x3B800000 : Model .binary32)) (q := 1 / 256) (by decide +kernel)

private theorem toReal_0x3B7FFFFE :
    (Model.ofNatBits 0x3B7FFFFE : Model .binary32).toReal = 1 / 256 - (2 : ℝ) ^ (-31 : ℤ) := by
  have h := Model.Algebraic.toReal_of_toRat?_eq_some
    (value := (Model.ofNatBits 0x3B7FFFFE : Model .binary32))
    (q := 8388607 / 2147483648) (by decide +kernel)
  rw [h]
  norm_num

private theorem toReal_0xBB800000 :
    (Model.ofNatBits 0xBB800000 : Model .binary32).toReal = -(1 / 256) := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some
    (value := (Model.ofNatBits 0xBB800000 : Model .binary32))
    (q := -(1 / 256)) (by decide +kernel)

private theorem toReal_0xBB7FFFFE :
    (Model.ofNatBits 0xBB7FFFFE : Model .binary32).toReal =
      -(1 / 256) + (2 : ℝ) ^ (-31 : ℤ) := by
  have h := Model.Algebraic.toReal_of_toRat?_eq_some
    (value := (Model.ofNatBits 0xBB7FFFFE : Model .binary32))
    (q := -(8388607 / 2147483648)) (by decide +kernel)
  rw [h]
  norm_num

private theorem toReal_0x33800000 :
    (Model.ofNatBits 0x33800000 : Model .binary32).toReal = 1 / 16777216 := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some
    (value := (Model.ofNatBits 0x33800000 : Model .binary32))
    (q := 1 / 16777216) (by decide +kernel)

private theorem toReal_0xB3000000 :
    (Model.ofNatBits 0xB3000000 : Model .binary32).toReal = -(1 / 33554432) := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some
    (value := (Model.ofNatBits 0xB3000000 : Model .binary32))
    (q := -(1 / 33554432)) (by decide +kernel)

/-! ## Section 3: Instantiation of `LibcMath.Analysis.RangeReduction` -/

private theorem fmul_128_exact (mode : IEEERoundingMode) (x : Model .binary32)
    (hx_fin : x.isFinite = true) (hx_abs : |x.toReal| ≤ 104) :
    (Libc.fmul mode x f32(0x43000000#32)).isFinite = true ∧
      (Libc.fmul mode x f32(0x43000000#32)).toReal = 128 * x.toReal := by
  have h := Analysis.RangeReduction.fmul_pow2_exact_binary32 mode x f32(0x43000000#32) 7
    hx_fin isFinite_c128 (by rw [toReal_c128]; norm_num) (by
      rw [abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < (2 : ℝ) ^ 7)]
      linarith [Analysis.RangeReduction.posMaxFinite_binary32_ge_2p24])
  simpa [show (2 : ℝ) ^ 7 = 128 by norm_num] using h

private theorem nearestInt_spec (mode : IEEERoundingMode) (y : Model .binary32)
    (hy_fin : y.isFinite = true) (hy_lo : -13312 ≤ y.toReal) (hy_hi : y.toReal ≤ 11392)
    (hgap : 1 / 2 ≤ |y.toReal| ∨ |y.toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ)) :
    ∃ k : ℤ, -13312 ≤ k ∧ k ≤ 11392 ∧
      (Libc.nearestInt Generated.DoubleEval.config mode y).isFinite = true ∧
      (Libc.nearestInt Generated.DoubleEval.config mode y).toReal = (k : ℝ) ∧
      |y.toReal - (k : ℝ)| ≤ 1 / 2 ∧
      (|y.toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ) → k = 0) := by
  have hcfg_ni : Generated.DoubleEval.config.hasNearestInt = false := rfl
  have hcfg_rn : Generated.DoubleEval.config.assumeRoundNearestOnly = false := rfl
  have heq : Libc.nearestInt Generated.DoubleEval.config mode y =
      Libc.genericNearestInt false mode y := by
    simp only [Libc.nearestInt, hcfg_ni, hcfg_rn, Bool.false_eq_true, ↓reduceIte]
  rw [heq]
  exact Analysis.RangeReduction.genericNearestInt_binary32_spec mode y (lo := -13312) (hi := 11392)
    (by omega) (by omega) (by omega) (by omega) hy_fin (by exact_mod_cast hy_lo)
    (by exact_mod_cast hy_hi) hgap

private theorem submul_exact (mode : IEEERoundingMode) (x kf : Model .binary32) {k : ℤ}
    (hx_fin : x.isFinite = true) (hkf_fin : kf.isFinite = true) (hkf_real : kf.toReal = (k : ℝ))
    (hk_lo : -13312 ≤ k) (hk_hi : k ≤ 11392) (hnear : |128 * x.toReal - (k : ℝ)| ≤ 1 / 2) :
    let rem := submul[Generated.DoubleEval.config, mode](x, kf, f32(0x3C000000#32))
    rem.isFinite = true ∧ rem.toReal = x.toReal - (k : ℝ) / 128 ∧ |rem.toReal| ≤ 1 / 256 := by
  have hk_abs : |(k : ℝ)| ≤ 8388608 := abs_le.mpr ⟨by
    linarith [show (-13312 : ℝ) ≤ k by exact_mod_cast hk_lo],
    by linarith [show (k : ℝ) ≤ 11392 by exact_mod_cast hk_hi]⟩
  have h := Analysis.RangeReduction.submul_invPow2_exact_binary32
    Generated.DoubleEval.config mode rfl rfl x kf f32(0x3C000000#32) 7 (by omega)
    hx_fin hkf_fin hkf_real isFinite_c128inv (by rw [toReal_c128inv]; norm_num) hk_abs
    (by simpa [show (2 : ℝ) ^ 7 = 128 by norm_num] using hnear)
  refine ⟨h.1, ?_, ?_⟩
  · rw [h.2.1]; norm_num; ring
  · refine h.2.2.trans (by norm_num)

private theorem fpCast_binary64_exact (mode : IEEERoundingMode) (rem : Model .binary32)
    (hrem_fin : rem.isFinite = true) (hrem_abs : |rem.toReal| ≤ 1 / 256) :
    (Libc.fpCast .binary64 mode rem).isFinite = true ∧
      (Libc.fpCast .binary64 mode rem).toReal = rem.toReal :=
  Analysis.RangeReduction.fpCast_binary32_to_binary64_exact mode rem hrem_fin
    (by linarith [Model.one_le_toReal_posMaxFinite .binary64])

/-! ## Section 4: Integer conversion, table indices, and `mainBody` evaluation -/

private theorem fptosi_int_eq (kf : Model .binary32) {k : ℤ}
    (hkf_fin : kf.isFinite = true) (hkf_real : kf.toReal = (k : ℝ))
    (hk_lo : -13312 ≤ k) (hk_hi : k ≤ 11392) :
    Libc.fptosi? 32 kf = some (BitVec.ofInt 32 k) :=
  Analysis.RangeReduction.fptosi_int_binary32_eq kf hkf_fin hkf_real (by omega) (by omega)

private theorem toInt_bitVec_ofNat {n : ℕ} (hn : n ≤ 24704) :
    (BitVec.ofNat 32 n).toInt = (n : ℤ) := by
  rw [BitVec.toInt_eq_toNat_cond, BitVec.toNat_ofNat]
  have hmod : n % 2 ^ 32 = n := Nat.mod_eq_of_lt (by omega)
  rw [hmod]
  split <;> omega

private theorem bitVec_ofInt_add_13312 {k : ℤ} (hk_lo : -13312 ≤ k) (hk_hi : k ≤ 11392) :
    BitVec.ofInt 32 k + (0x68#32 <<< 7) = BitVec.ofNat 32 (k + 13312).toNat := by
  have hshift : (0x68#32 <<< 7 : BitVec 32) = 13312#32 := by decide
  rw [hshift]
  have hk_toInt : (BitVec.ofInt 32 k).toInt = k := by
    rw [BitVec.toInt_ofInt, Int.bmod_eq_of_le] <;> omega
  have h13312_toInt : (13312#32 : BitVec 32).toInt = 13312 := by decide
  apply BitVec.eq_of_toInt_eq
  rw [BitVec.toInt_add, hk_toInt, h13312_toInt, toInt_bitVec_ofNat (by omega)]
  have hmod : (k + 13312).bmod (2 ^ 32) = k + 13312 := by
    rw [Int.bmod_eq_of_le] <;> omega
  rw [hmod, Int.toNat_of_nonneg (by omega)]

private theorem sadd_13312_eq {k : ℤ} (hk_lo : -13312 ≤ k) (hk_hi : k ≤ 11392) :
    Libc.sadd? (BitVec.ofInt 32 k) (0x68#32 <<< 7) =
      some (BitVec.ofNat 32 (k + 13312).toNat) := by
  have hsum := bitVec_ofInt_add_13312 hk_lo hk_hi
  have hshift : (0x68#32 <<< 7 : BitVec 32) = 13312#32 := by decide
  have hk_toInt : (BitVec.ofInt 32 k).toInt = k := by
    rw [BitVec.toInt_ofInt, Int.bmod_eq_of_le] <;> omega
  have h13312_msb : (13312#32 : BitVec 32).msb = false := by decide
  have hsum_msb : (BitVec.ofInt 32 k + 13312#32).msb = false := by
    rw [← hshift, hsum, BitVec.msb_eq_toInt, toInt_bitVec_ofNat (by omega)]
    simp
  have hov : BitVec.saddOverflow (BitVec.ofInt 32 k) (0x68#32 <<< 7) = false := by
    rw [hshift, BitVec.saddOverflow_eq, h13312_msb, hsum_msb]
    cases (BitVec.ofInt 32 k).msb <;> rfl
  simp only [Libc.sadd?, hov, Bool.false_eq_true, ↓reduceIte, hsum]

private theorem indices_of_sumBv {n : ℕ} (hn : n ≤ 24704) :
    (BitVec.sshiftRight (BitVec.ofNat 32 n) 7).toNat = n / 128 ∧
    (BitVec.ofNat 32 n &&& 0x7F#32).toNat = n % 128 ∧
    n / 128 < Generated.DoubleEval.EXP_M1.size ∧
    n % 128 < Generated.DoubleEval.EXP_M2.size := by
  have htoInt : (BitVec.ofNat 32 n).toInt = (n : ℤ) := toInt_bitVec_ofNat hn
  have hsr_toInt : (BitVec.sshiftRight (BitVec.ofNat 32 n) 7).toInt = (n / 128 : ℕ) := by
    rw [BitVec.toInt_sshiftRight, htoInt, Int.shiftRight_eq_div_pow]
    exact_mod_cast rfl
  have hsr : (BitVec.sshiftRight (BitVec.ofNat 32 n) 7).toNat = n / 128 := by
    rw [BitVec.toInt_eq_toNat_cond] at hsr_toInt
    have hlt := (BitVec.sshiftRight (BitVec.ofNat 32 n) 7).isLt
    split at hsr_toInt <;> omega
  have hmid : (BitVec.ofNat 32 n &&& 0x7F#32).toNat = n % 128 := by
    rw [BitVec.toNat_and, BitVec.toNat_ofNat, Nat.mod_eq_of_lt (by omega)]
    exact Nat.and_two_pow_sub_one_eq_mod n 7
  have hm1 : Generated.DoubleEval.EXP_M1.size = 195 := rfl
  have hm2 : Generated.DoubleEval.EXP_M2.size = 128 := rfl
  refine ⟨hsr, hmid, by omega, by omega⟩

private theorem option_bind_eq {α β : Type} {o : Option α} {a : α} {f : α → Option β}
    (h : o = some a) : (o >>= f) = f a := by
  rw [h]; rfl

private theorem mainBody_eval (mode : IEEERoundingMode) (x : Model .binary32)
    {kBv sumBv : BitVec 32} {hiIdx midIdx : ℕ}
    (hfptosi : Libc.fptosi? 32 (Libc.nearestInt Generated.DoubleEval.config mode
        (Libc.fmul mode x f32(0x43000000#32))) = some kBv)
    (hsadd : Libc.sadd? kBv (0x68#32 <<< 7) = some sumBv)
    (hhi_eq : (BitVec.sshiftRight sumBv 7).toNat = hiIdx)
    (hmid_eq : (sumBv &&& 0x7F#32).toNat = midIdx)
    (hi_lt : hiIdx < Generated.DoubleEval.EXP_M1.size)
    (mid_lt : midIdx < Generated.DoubleEval.EXP_M2.size) :
    mainBody mode x = some (
      Libc.fpCast .binary32 mode (
        Libc.fmul mode
          (Libc.fmul mode
            (Generated.DoubleEval.EXP_M1[hiIdx]'hi_lt)
            (Generated.DoubleEval.EXP_M2[midIdx]'mid_lt))
          (horner[Generated.DoubleEval.config, mode]
            (Libc.fpCast .binary64 mode
              (submul[Generated.DoubleEval.config, mode](x,
                Libc.nearestInt Generated.DoubleEval.config mode
                  (Libc.fmul mode x f32(0x43000000#32)),
                f32(0x3C000000#32))))
            [f64(0x3FF0000000000000#64), f64(0x3FEFFFFFFFFFF777#64),
             f64(0x3FE000000000071C#64), f64(0x3FC555566668E5E7#64),
             f64(0x3FA55555555EF243#64)]))) := by
  unfold mainBody
  rw [option_bind_eq hfptosi]
  rw [option_bind_eq hsadd]
  have h1 : Generated.DoubleEval.EXP_M1[(BitVec.sshiftRight sumBv 7).toNat]? =
      some (Generated.DoubleEval.EXP_M1[hiIdx]'hi_lt) := by
    rw [hhi_eq, Array.getElem?_eq_getElem hi_lt]
  have h2 : Generated.DoubleEval.EXP_M2[(sumBv &&& 0x7F#32).toNat]? =
      some (Generated.DoubleEval.EXP_M2[midIdx]'mid_lt) := by
    rw [hmid_eq, Array.getElem?_eq_getElem mid_lt]
  rw [option_bind_eq h1]
  rw [option_bind_eq h2]
  rfl

/-! ## Section 7: Assembly and public reduction definitions/theorems -/

private def redKf (mode : IEEERoundingMode) (b : BitVec 32) : Model .binary32 :=
  Libc.nearestInt Generated.DoubleEval.config mode (Libc.fmul mode f32(b) f32(0x43000000#32))

private def redXd (mode : IEEERoundingMode) (b : BitVec 32) : Model .binary64 :=
  Libc.fpCast .binary64 mode
    (submul[Generated.DoubleEval.config, mode](f32(b), redKf mode b, f32(0x3C000000#32)))

private def redSumBv (mode : IEEERoundingMode) (b : BitVec 32) : BitVec 32 :=
  (Libc.fptosi? 32 (redKf mode b)).getD 0#32 + (0x68#32 <<< 7)

private def redHiIdx (mode : IEEERoundingMode) (b : BitVec 32) : ℕ :=
  (BitVec.sshiftRight (redSumBv mode b) 7).toNat

private def redMidIdx (mode : IEEERoundingMode) (b : BitVec 32) : ℕ :=
  (redSumBv mode b &&& 0x7F#32).toNat

private theorem red_witness (mode : IEEERoundingMode) (b : BitVec 32)
    (hx_fin : f32(b).isFinite = true)
    (hx_lo : -104 ≤ f32(b).toReal) (hx_hi : f32(b).toReal ≤ 89)
    (hgap : 1 / 2 ≤ |128 * f32(b).toReal| ∨
      |128 * f32(b).toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ)) :
    ∃ k : ℤ, -13312 ≤ k ∧ k ≤ 11392 ∧
      Libc.fptosi? 32 (redKf mode b) = some (BitVec.ofInt 32 k) ∧
      redSumBv mode b = BitVec.ofNat 32 (k + 13312).toNat ∧
      redHiIdx mode b = (k + 13312).toNat / 128 ∧
      redMidIdx mode b = (k + 13312).toNat % 128 ∧
      redHiIdx mode b < Generated.DoubleEval.EXP_M1.size ∧
      redMidIdx mode b < Generated.DoubleEval.EXP_M2.size ∧
      (redXd mode b).isFinite = true ∧
      (redXd mode b).toReal = f32(b).toReal - (k : ℝ) / 128 ∧
      |(redXd mode b).toReal| ≤ 1 / 256 ∧
      (|128 * f32(b).toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ) → k = 0) := by
  have hx_abs : |f32(b).toReal| ≤ 104 := abs_le.mpr ⟨hx_lo, by linarith⟩
  obtain ⟨hy_fin, hy_real⟩ := fmul_128_exact mode f32(b) hx_fin hx_abs
  have hy_lo : -13312 ≤ (Libc.fmul mode f32(b) f32(0x43000000#32)).toReal := by
    rw [hy_real]; linarith
  have hy_hi : (Libc.fmul mode f32(b) f32(0x43000000#32)).toReal ≤ 11392 := by
    rw [hy_real]; linarith
  have hy_gap : 1 / 2 ≤ |(Libc.fmul mode f32(b) f32(0x43000000#32)).toReal| ∨
      |(Libc.fmul mode f32(b) f32(0x43000000#32)).toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ) := by
    rwa [hy_real]
  obtain ⟨k, hk_lo, hk_hi, hkf_fin, hkf_real, hnear, htiny_k⟩ :=
    nearestInt_spec mode _ hy_fin hy_lo hy_hi hy_gap
  rw [hy_real] at hnear htiny_k
  obtain ⟨hrem_fin, hrem_real, hrem_abs⟩ :=
    submul_exact mode f32(b) _ hx_fin hkf_fin hkf_real hk_lo hk_hi hnear
  obtain ⟨hxd_fin, hxd_real⟩ := fpCast_binary64_exact mode _ hrem_fin hrem_abs
  have hfptosi : Libc.fptosi? 32 (redKf mode b) = some (BitVec.ofInt 32 k) :=
    fptosi_int_eq _ hkf_fin hkf_real hk_lo hk_hi
  have hsum : redSumBv mode b = BitVec.ofNat 32 (k + 13312).toNat := by
    unfold redSumBv
    rw [hfptosi, Option.getD_some]
    exact bitVec_ofInt_add_13312 hk_lo hk_hi
  obtain ⟨hhi_eq, hmid_eq, hhi_lt, hmid_lt⟩ := indices_of_sumBv (n := (k + 13312).toNat) (by omega)
  have hhi : redHiIdx mode b = (k + 13312).toNat / 128 := by
    unfold redHiIdx; rw [hsum]; exact hhi_eq
  have hmid : redMidIdx mode b = (k + 13312).toNat % 128 := by
    unfold redMidIdx; rw [hsum]; exact hmid_eq
  refine ⟨k, hk_lo, hk_hi, hfptosi, hsum, hhi, hmid, by rw [hhi]; exact hhi_lt,
    by rw [hmid]; exact hmid_lt, hxd_fin, by rw [redXd, redKf, hxd_real, hrem_real],
    by rw [redXd, redKf, hxd_real]; exact hrem_abs, htiny_k⟩

private def mkMainReduction (mode : IEEERoundingMode) (b : BitVec 32)
    (hexpf : Generated.DoubleEval.expf mode f32(b) = mainBody mode f32(b))
    (hx_fin : f32(b).isFinite = true)
    (hx_lo : -104 ≤ f32(b).toReal) (hx_hi : f32(b).toReal ≤ 89)
    (hgap : 1 / 2 ≤ |128 * f32(b).toReal| ∨
      |128 * f32(b).toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ)) :
    MainReduction mode b where
  hiIdx := redHiIdx mode b
  midIdx := redMidIdx mode b
  xd := redXd mode b
  hi_lt := by
    obtain ⟨_, _, _, _, _, _, _, hhi_lt, _, _, _, _, _⟩ :=
      red_witness mode b hx_fin hx_lo hx_hi hgap
    exact hhi_lt
  mid_lt := by
    obtain ⟨_, _, _, _, _, _, _, _, hmid_lt, _, _, _, _⟩ :=
      red_witness mode b hx_fin hx_lo hx_hi hgap
    exact hmid_lt
  xd_finite := by
    obtain ⟨_, _, _, _, _, _, _, _, _, hxd_fin, _, _, _⟩ :=
      red_witness mode b hx_fin hx_lo hx_hi hgap
    exact hxd_fin
  xd_abs_le := by
    obtain ⟨_, _, _, _, _, _, _, _, _, _, _, hxd_abs, _⟩ :=
      red_witness mode b hx_fin hx_lo hx_hi hgap
    exact hxd_abs
  decomp := by
    obtain ⟨k, hk_lo, _, _, _, hhi, hmid, _, _, _, hxd_real, _, _⟩ :=
      red_witness mode b hx_fin hx_lo hx_hi hgap
    rw [hhi, hmid, hxd_real]
    set n : ℕ := (k + 13312).toNat
    have hn_cast : (n : ℤ) = k + 13312 := Int.toNat_of_nonneg (by omega)
    have hdiv : 128 * (n / 128) + n % 128 = n := Nat.div_add_mod n 128
    have hdiv_r : 128 * ((n / 128 : ℕ) : ℝ) + ((n % 128 : ℕ) : ℝ) = (k : ℝ) + 13312 := by
      have h2 : ((128 * (n / 128) + n % 128 : ℕ) : ℝ) = (n : ℝ) := by exact_mod_cast hdiv
      have h3 : (n : ℝ) = (k : ℝ) + 13312 := by exact_mod_cast hn_cast
      push_cast at h2
      linarith
    rw [Int.cast_natCast]
    linarith
  expf_eq := by
    obtain ⟨k, hk_lo, hk_hi, hfptosi, hsum, _, _, hhi_lt, hmid_lt, _, _, _, _⟩ :=
      red_witness mode b hx_fin hx_lo hx_hi hgap
    rw [hexpf]
    exact mainBody_eval mode f32(b) hfptosi (sadd_13312_eq hk_lo hk_hi)
      (by rw [← hsum]; rfl) (by rw [← hsum]; rfl) hhi_lt hmid_lt

variable {mode : IEEERoundingMode}

/-- Exact range reduction on the positive main polynomial range `[0x32800001, 0x42B17218)`
excluding `0x3B7FFFFF`. -/
def mainReduction_of_pos (_hmode : mode ∈ cModes) (b : BitVec 32)
    (hlo : 0x32800001 ≤ b.toNat) (hhi : b.toNat < 0x42B17218) (hne : b.toNat ≠ 0x3B7FFFFF) :
    MainReduction mode b := by
  have hx_fin : f32(b).isFinite = true :=
    Binary32.isFinite_iff.mpr (.inl (by rw [toNatBits_f32]; omega))
  have hx_pos : 0 < f32(b).toReal :=
    (Binary32.toReal_pos_iff hx_fin).mpr (by rw [toNatBits_f32]; omega)
  have hx_hi : f32(b).toReal ≤ 89 := by
    rw [← toReal_bound_pos89]
    exact (Binary32.toReal_le_ofNatBits_iff_of_nonneg (by omega)
      (by rw [toNatBits_f32]; omega)).mpr (by rw [toNatBits_f32]; omega)
  have hgap : 1 / 2 ≤ |128 * f32(b).toReal| ∨
      |128 * f32(b).toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ) := by
    rw [abs_of_pos (by linarith)]
    by_cases hge : 0x3B800000 ≤ b.toNat
    · left
      have hx_ge : 1 / 256 ≤ f32(b).toReal := by
        rw [← toReal_0x3B800000]
        exact (Binary32.toReal_ofNatBits_le_iff_of_nonneg (by omega)
          (by rw [toNatBits_f32]; omega)).mpr (by rw [toNatBits_f32]; omega)
      linarith
    · right
      have hle_fe : b.toNat ≤ 0x3B7FFFFE := by omega
      have hx_le : f32(b).toReal ≤ 1 / 256 - (2 : ℝ) ^ (-31 : ℤ) := by
        rw [← toReal_0x3B7FFFFE]
        exact (Binary32.toReal_le_ofNatBits_iff_of_nonneg (by omega)
          (by rw [toNatBits_f32]; omega)).mpr (by rw [toNatBits_f32]; omega)
      have hpow : 128 * (2 : ℝ) ^ (-31 : ℤ) = (2 : ℝ) ^ (-24 : ℤ) := by norm_num
      linarith
  exact mkMainReduction mode b (expf_eq_mainBody_of_pos mode b hlo hhi) hx_fin
    (by linarith) hx_hi hgap

/-- Exact range reduction on the negative main polynomial range `[0xB2800001, 0xC2CFF1B5)`
excluding `0xC236BD8C` and `0xBB7FFFFF`. -/
def mainReduction_of_neg (_hmode : mode ∈ cModes) (b : BitVec 32)
    (hlo : 0xB2800001 ≤ b.toNat) (hhi : b.toNat < 0xC2CFF1B5)
    (hne1 : b.toNat ≠ 0xC236BD8C) (hne2 : b.toNat ≠ 0xBB7FFFFF) :
    MainReduction mode b := by
  have hx_fin : f32(b).isFinite = true :=
    Binary32.isFinite_iff.mpr (.inr (by rw [toNatBits_f32]; omega))
  have hx_neg : f32(b).toReal < 0 :=
    (Binary32.toReal_neg_iff hx_fin).mpr (by rw [toNatBits_f32]; omega)
  have hx_lo : -104 ≤ f32(b).toReal := by
    rw [← toReal_bound_neg104]
    exact (Binary32.toReal_ofNatBits_le_iff_of_nonpos (by omega)
      (by rw [toNatBits_f32]; omega)).mpr (by rw [toNatBits_f32]; omega)
  have hgap : 1 / 2 ≤ |128 * f32(b).toReal| ∨
      |128 * f32(b).toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ) := by
    rw [abs_of_neg (by linarith)]
    by_cases hge : 0xBB800000 ≤ b.toNat
    · left
      have hx_le : f32(b).toReal ≤ -(1 / 256) := by
        rw [← toReal_0xBB800000]
        exact (Binary32.toReal_le_ofNatBits_iff_of_nonpos (by omega)
          (by rw [toNatBits_f32]; omega)).mpr (by rw [toNatBits_f32]; omega)
      linarith
    · right
      have hle_fe : b.toNat ≤ 0xBB7FFFFE := by omega
      have hx_ge : -(1 / 256) + (2 : ℝ) ^ (-31 : ℤ) ≤ f32(b).toReal := by
        rw [← toReal_0xBB7FFFFE]
        exact (Binary32.toReal_ofNatBits_le_iff_of_nonpos (by omega)
          (by rw [toNatBits_f32]; omega)).mpr (by rw [toNatBits_f32]; omega)
      have hpow : 128 * (2 : ℝ) ^ (-31 : ℤ) = (2 : ℝ) ^ (-24 : ℤ) := by norm_num
      linarith
  exact mkMainReduction mode b (expf_eq_mainBody_of_neg mode b hlo hhi hne1) hx_fin
    hx_lo (by linarith) hgap

/-- When `|x| < 2^-24` (covering `[0x32800001, 0x33800000)` and `[0xB2800001, 0xB3000000)`),
`kf = 0`, `hiIdx = 104`, `midIdx = 0`, `xd.toReal = f32(b).toReal`, and both table lookups
are `1.0` (`EXP_M1[104] = 1.0`, `EXP_M2[0] = 1.0`). -/
theorem mainReduction_of_tiny (_hmode : mode ∈ cModes) (b : BitVec 32)
    (hpos_or_neg : (0x32800001 ≤ b.toNat ∧ b.toNat < 0x33800000) ∨
                   (0xB2800001 ≤ b.toNat ∧ b.toNat < 0xB3000000)) :
    ∃ r : MainReduction mode b, r.hiIdx = 104 ∧ r.midIdx = 0 ∧ r.xd.toReal = f32(b).toReal := by
  have h24 : (2 : ℝ) ^ (-24 : ℤ) = 1 / 16777216 := by norm_num
  have hprops :
      Generated.DoubleEval.expf mode f32(b) = mainBody mode f32(b) ∧
      f32(b).isFinite = true ∧
      -104 ≤ f32(b).toReal ∧ f32(b).toReal ≤ 89 ∧
      |128 * f32(b).toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ) := by
    rcases hpos_or_neg with ⟨hlo, hhi⟩ | ⟨hlo, hhi⟩
    · have hx_fin : f32(b).isFinite = true :=
        Binary32.isFinite_iff.mpr (.inl (by rw [toNatBits_f32]; omega))
      have hx_pos : 0 < f32(b).toReal :=
        (Binary32.toReal_pos_iff hx_fin).mpr (by rw [toNatBits_f32]; omega)
      have hx_le : f32(b).toReal ≤ 1 / 16777216 := by
        rw [← toReal_0x33800000]
        exact (Binary32.toReal_le_ofNatBits_iff_of_nonneg (by omega)
          (by rw [toNatBits_f32]; omega)).mpr (by rw [toNatBits_f32]; omega)
      have htiny : |128 * f32(b).toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ) := by
        rw [abs_of_pos (by linarith), h24]
        linarith
      refine ⟨expf_eq_mainBody_of_pos mode b hlo (by omega), hx_fin, by linarith, by linarith,
        htiny⟩
    · have hx_fin : f32(b).isFinite = true :=
        Binary32.isFinite_iff.mpr (.inr (by rw [toNatBits_f32]; omega))
      have hx_neg : f32(b).toReal < 0 :=
        (Binary32.toReal_neg_iff hx_fin).mpr (by rw [toNatBits_f32]; omega)
      have hx_ge : -(1 / 33554432) ≤ f32(b).toReal := by
        rw [← toReal_0xB3000000]
        exact (Binary32.toReal_ofNatBits_le_iff_of_nonpos (by omega)
          (by rw [toNatBits_f32]; omega)).mpr (by rw [toNatBits_f32]; omega)
      have htiny : |128 * f32(b).toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ) := by
        rw [abs_of_neg (by linarith), h24]
        linarith
      refine ⟨expf_eq_mainBody_of_neg mode b hlo (by omega) (by omega), hx_fin, by linarith,
        by linarith, htiny⟩
  obtain ⟨hexpf, hx_fin, hx_lo, hx_hi, htiny⟩ := hprops
  refine ⟨mkMainReduction mode b hexpf hx_fin hx_lo hx_hi (Or.inr htiny), ?_⟩
  obtain ⟨k, _, _, _, _, hhi, hmid, _, _, _, hxd_real, _, htiny_k⟩ :=
    red_witness mode b hx_fin hx_lo hx_hi (Or.inr htiny)
  have hk0 : k = 0 := htiny_k htiny
  dsimp only [mkMainReduction]
  rw [hhi, hmid, hxd_real, hk0]
  norm_num

/--
info: 'LibcMath.Expf.MainPath.RangeReduction.mainReduction_of_pos' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms mainReduction_of_pos

/--
info: 'LibcMath.Expf.MainPath.RangeReduction.mainReduction_of_neg' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms mainReduction_of_neg

/--
info: 'LibcMath.Expf.MainPath.RangeReduction.mainReduction_of_tiny' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms mainReduction_of_tiny

end LibcMath.Expf.MainPath.RangeReduction
