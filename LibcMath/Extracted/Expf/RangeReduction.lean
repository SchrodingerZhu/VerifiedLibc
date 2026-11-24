import LibcMath.Extracted.Expf.DoubleEval
import LibcMath.Functions.Binary32Bits
import FloatLib.Floats.Formats.BinaryInterchange.Analysis.MixedPrecision
import FloatLib.Floats.Formats.BinaryInterchange.Analysis.StandardModel
import FloatLib.Floats.Formats.BinaryInterchange.DirectedSemantics.Exact
import FloatLib.Floats.Formats.BinaryInterchange.DirectedSemantics.Positive
import FloatLib.Floats.Formats.BinaryInterchange.DirectedSemantics.Rounded
import FloatLib.Floats.Formats.BinaryInterchange.DType.Semantics
import FloatLib.Floats.Formats.BinaryInterchange.KernelPath.Cast
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Compare.Finite
import FloatLib.Floats.Formats.Flocq.Theory.Analysis.SterbenzFLT
import FloatLib.Floats.Formats.Flocq.Theory.Rounding.Properties

/-!
# Exact range reduction for `Expf.DoubleEval.expf`

On the main polynomial ranges (`[0x32800001, 0x42B17218)` excluding `0x3B7FFFFF` and
`[0xB2800001, 0xC2CFF1B5)` excluding `0xC236BD8C` and `0xBB7FFFFF`), `Expf.DoubleEval.expf`:

1. enters the main continuation `cont ()`;
2. scales `x` exactly by `128`;
3. computes `kf = Core.genericNearestInt false mode (128 * x)` as an exact integer `k` with
   `-13312 ≤ k ≤ 11392` and `|128 * x - k| ≤ 1 / 2`;
4. computes `r = submul(x, kf, 1/128)` without rounding error, with `|r| ≤ 1 / 256`;
5. widens `r` exactly to binary64 `xd`;
6. converts `kf` to `int32_t`, adds `104 * 128 = 13312` without signed overflow, and reads
   `EXP_M1[hiIdx]` and `EXP_M2[midIdx]` in bounds, satisfying
   `(hiIdx - 104) + midIdx / 128 + xd = x`.

When `|x| < 2⁻²⁴` (`[0x32800001, 0x33800000)` or `[0xB2800001, 0xB3000000)`), `k = 0`, so
`hiIdx = 104`, `midIdx = 0`, and `xd = x`.
-/

namespace LibcMath.Extracted.Expf.RangeReduction

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Core
open LibcMath.Core.DSL

/-- Output of the exact range reduction on the main polynomial path of `Expf.DoubleEval.expf`. -/
structure MainReduction (mode : IEEERoundingMode) (b : BitVec 32) where
  hiIdx : ℕ
  midIdx : ℕ
  xd : Model .binary64
  hi_lt : hiIdx < Expf.DoubleEval.EXP_M1.size
  mid_lt : midIdx < Expf.DoubleEval.EXP_M2.size
  xd_finite : xd.isFinite = true
  xd_abs_le : |xd.toReal| ≤ 1 / 256
  decomp : ((hiIdx : ℤ) - 104 : ℝ) + (midIdx : ℝ) / 128 + xd.toReal = f32(b).toReal
  expf_eq : Expf.DoubleEval.expf mode f32(b) = some (
    Core.fpCast .binary32 mode (
      Core.fmul mode
        (Core.fmul mode
          (Expf.DoubleEval.EXP_M1[hiIdx]'hi_lt)
          (Expf.DoubleEval.EXP_M2[midIdx]'mid_lt))
        (horner[Expf.DoubleEval.config, mode] xd
          [f64(0x3FF0000000000000#64), f64(0x3FEFFFFFFFFFF777#64),
           f64(0x3FE000000000071C#64), f64(0x3FC555566668E5E7#64),
           f64(0x3FA55555555EF243#64)])))

/-! ## Section 1: Control-flow routing into the main continuation -/

/-- The body of `cont ()` inside `Expf.DoubleEval.expf`. -/
private def mainBody (mode : IEEERoundingMode) (x : Model .binary32) :
    Option (Model .binary32) := do
  let kf := Core.nearestInt Expf.DoubleEval.config mode (Core.fmul mode x f32(0x43000000#32))
  let xd := Core.fpCast .binary64 mode
    (submul[Expf.DoubleEval.config, mode](x, kf, f32(0x3C000000#32)))
  let x_hi ← Core.fptosi? 32 kf
  let x_hi ← Core.sadd? x_hi (0x68#32 <<< 7)
  let exp_hi ← Expf.DoubleEval.EXP_M1[(BitVec.sshiftRight x_hi 7).toNat]?
  let exp_mid ← Expf.DoubleEval.EXP_M2[(x_hi &&& 0x7F#32).toNat]?
  let exp_lo := horner[Expf.DoubleEval.config, mode] xd
    [f64(0x3FF0000000000000#64), f64(0x3FEFFFFFFFFFF777#64),
     f64(0x3FE000000000071C#64), f64(0x3FC555566668E5E7#64),
     f64(0x3FA55555555EF243#64)]
  pure (Core.fpCast .binary32 mode (Core.fmul mode (Core.fmul mode exp_hi exp_mid) exp_lo))

private theorem toNatBits_f32 (b : BitVec 32) : f32(b).toNatBits = b.toNat := rfl

private theorem uintval_f32 (b : BitVec 32) : Core.FPBits.uintval f32(b) = b := rfl

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

private theorem ne_except_of_toNat_ne (b : BitVec 32) (h : b.toNat ≠ 0xC236BD8C) :
    (b == 0xC236BD8C#32) = false := by
  rw [beq_eq_false_iff_ne]
  intro heq
  apply h
  rw [heq]
  rfl

private theorem expf_eq_mainBody_of_pos (mode : IEEERoundingMode) (b : BitVec 32)
    (hlo : 0x32800001 ≤ b.toNat) (hhi : b.toNat < 0x42B17218) :
    Expf.DoubleEval.expf mode f32(b) = mainBody mode f32(b) := by
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b (by omega)
  have hge : BitVec.ule 0x42B17218#32 (b &&& 0x7FFFFFFF#32) = false := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  have hle : BitVec.ule (b &&& 0x7FFFFFFF#32) 0x32800000#32 = false := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  unfold Expf.DoubleEval.expf
  dsimp only [Core.FPBits.ofVal]
  simp only [uintval_f32, hne, hge, hle, Bool.or_self, Bool.false_eq_true, ↓reduceIte]
  rfl

private theorem expf_eq_mainBody_of_neg (mode : IEEERoundingMode) (b : BitVec 32)
    (hlo : 0xB2800001 ≤ b.toNat) (hhi : b.toNat < 0xC2CFF1B5)
    (hne1 : b.toNat ≠ 0xC236BD8C) :
    Expf.DoubleEval.expf mode f32(b) = mainBody mode f32(b) := by
  have hne : (b == 0xC236BD8C#32) = false := ne_except_of_toNat_ne b hne1
  have hle : BitVec.ule (b &&& 0x7FFFFFFF#32) 0x32800000#32 = false := by
    rw [ule_iff_toNat, abs_toNat]; simp; omega
  by_cases hmid : b.toNat < 0xC2B17218
  · have hge : BitVec.ule 0x42B17218#32 (b &&& 0x7FFFFFFF#32) = false := by
      rw [ule_iff_toNat, abs_toNat]; simp; omega
    unfold Expf.DoubleEval.expf
    dsimp only [Core.FPBits.ofVal]
    simp only [uintval_f32, hne, hge, hle, Bool.or_self, Bool.false_eq_true, ↓reduceIte]
    rfl
  · have hge : BitVec.ule 0x42B17218#32 (b &&& 0x7FFFFFFF#32) = true := by
      rw [ule_iff_toNat, abs_toNat]; simp; omega
    have hsmall :
        BitVec.sle (BitVec.setWidth 32 (Core.FPBits.biasedExp f32(b))) 0x65#32 = false := by
      rw [biasedExp_sle_0x65]; simp; omega
    have huf : BitVec.ule 0xC2CFF1B5#32 b = false := by
      rw [ule_iff_toNat]; simp; omega
    have hneg : f32(b).signBit = true :=
      (Binary32.signBit_eq_true_iff _).mpr (by rw [toNatBits_f32]; omega)
    unfold Expf.DoubleEval.expf
    dsimp only [Core.FPBits.ofVal]
    simp only [uintval_f32, hne, hge, Bool.true_or, ↓reduceIte, hsmall, huf,
      Core.FPBits.isPos, hneg, Bool.not_true, Bool.false_and, Bool.false_eq_true]
    rfl

/-! ## Section 2: Concrete binary32 and binary64 constant values -/

private abbrev limit32 : Model .binary32 :=
  Model.ofFields .binary32 false (FloatFormat.binary32.exponentBias +
    FloatFormat.binary32.fracWidth + 1) 0

private abbrev magic32 : Model .binary32 :=
  Model.ofFields .binary32 false (FloatFormat.binary32.exponentBias +
    FloatFormat.binary32.fracWidth) 0

private abbrev half32 : Model .binary32 :=
  Model.ofFields .binary32 false (FloatFormat.binary32.exponentBias - 1) 0

private theorem isFinite_c128 : f32(0x43000000#32).isFinite = true := by decide +kernel
private theorem toReal_c128 : f32(0x43000000#32).toReal = 128 := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some (value := f32(0x43000000#32))
    (q := 128) (by decide +kernel)

private theorem isFinite_c128inv : f32(0x3C000000#32).isFinite = true := by decide +kernel
private theorem toReal_c128inv : f32(0x3C000000#32).toReal = 1 / 128 := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some (value := f32(0x3C000000#32))
    (q := 1 / 128) (by decide +kernel)

private theorem isFinite_limit32 : limit32.isFinite = true := by decide +kernel
private theorem toReal_limit32 : limit32.toReal = 16777216 := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some (value := limit32)
    (q := 16777216) (by decide +kernel)

private theorem isFinite_magic32 : magic32.isFinite = true := by decide +kernel
private theorem toReal_magic32 : magic32.toReal = 8388608 := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some (value := magic32)
    (q := 8388608) (by decide +kernel)

private theorem isFinite_half32 : half32.isFinite = true := by decide +kernel
private theorem toReal_half32 : half32.toReal = 1 / 2 := by
  simpa using Model.Algebraic.toReal_of_toRat?_eq_some (value := half32)
    (q := 1 / 2) (by decide +kernel)

private theorem posMaxFinite_binary32_ge :
    (16777216 : ℝ) ≤ (Model.posMaxFinite .binary32).toReal := by
  have h := Model.abs_toReal_le_posMaxFinite_of_isFinite limit32 isFinite_limit32
  rw [toReal_limit32] at h
  norm_num at h
  exact h

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

private theorem isFinite_0x3F000001 :
    (Model.ofNatBits 0x3F000001 : Model .binary32).isFinite = true := by decide +kernel
private theorem toReal_0x3F000001 :
    (Model.ofNatBits 0x3F000001 : Model .binary32).toReal = 1 / 2 + (2 : ℝ) ^ (-24 : ℤ) := by
  have h := Model.Algebraic.toReal_of_toRat?_eq_some
    (value := (Model.ofNatBits 0x3F000001 : Model .binary32))
    (q := 8388609 / 16777216) (by decide +kernel)
  rw [h]
  norm_num

private theorem isFinite_0xBF000001 :
    (Model.ofNatBits 0xBF000001 : Model .binary32).isFinite = true := by decide +kernel
private theorem toReal_0xBF000001 :
    (Model.ofNatBits 0xBF000001 : Model .binary32).toReal = -(1 / 2) - (2 : ℝ) ^ (-24 : ℤ) := by
  have h := Model.Algebraic.toReal_of_toRat?_eq_some
    (value := (Model.ofNatBits 0xBF000001 : Model .binary32))
    (q := -(8388609 / 16777216)) (by decide +kernel)
  rw [h]
  norm_num

private theorem roundAt_intCast_binary32 (mode : IEEERoundingMode) {n : ℤ}
    (hn : -13313 ≤ n) (hn' : n ≤ 13313) :
    Model.roundAt .binary32 (n : ℝ) mode = (n : ℝ) := by
  apply Model.roundAt_intCast_of_abs_le .binary32 _ mode
  have h1 : |(n : ℝ)| ≤ 13313 := abs_le.mpr ⟨by exact_mod_cast hn, by exact_mod_cast hn'⟩
  have h2 : (13313 : ℝ) ≤ 2 ^ (FloatFormat.binary32.fracWidth + 1) := by
    norm_num [FloatFormat.binary32]
  linarith

/-! ## Section 3: Exact multiplication `128 * x` -/

private theorem fmul_128_exact (mode : IEEERoundingMode) (x : Model .binary32)
    (hx_fin : x.isFinite = true) (hx_abs : |x.toReal| ≤ 104) :
    (Core.fmul mode x f32(0x43000000#32)).isFinite = true ∧
      (Core.fmul mode x f32(0x43000000#32)).toReal = 128 * x.toReal := by
  have hbound : |x.toReal * f32(0x43000000#32).toReal| ≤ (Model.posMaxFinite .binary32).toReal := by
    rw [toReal_c128, abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 128)]
    linarith [posMaxFinite_binary32_ge]
  obtain ⟨hfin, hround⟩ := Model.mul_finite_roundAt (mode := mode) (by decide) hx_fin
    isFinite_c128 hbound
  refine ⟨hfin, ?_⟩
  rw [Core.fmul, hround, toReal_c128]
  have hgen : FloatLib.Floats.Formats.Flocq.GenericRepresentable FloatLib.Numerics.binaryRadix
      (Model.fexpOf .binary32) (x.toReal * FloatLib.Floats.Formats.Flocq.bpow
        FloatLib.Numerics.binaryRadix 7) :=
    Model.genericFormat_mul_bpow .binary32 (Model.toReal_genericFormat_of_isFinite x hx_fin) 7
      (Or.inl (by omega))
  have hbpow : FloatLib.Floats.Formats.Flocq.bpow FloatLib.Numerics.binaryRadix 7 = (128 : ℝ) := by
    rw [FloatLib.Floats.Formats.Flocq.bpow_binaryRadix]; norm_num
  rw [hbpow] at hgen
  rw [Model.roundAt_of_genericFormat .binary32 hgen mode]
  ring

/-! ## Section 4: Exact analysis of `Core.nearestInt` (`genericNearestInt false`) -/

/-- Any real `t` with `2²³ ≤ |t| < 2²⁴` lies in the unit-spacing binade of binary32, so
`roundAt .binary32 t mode` is an integer chosen from `{⌊t⌋, ⌈t⌉}`. -/
private theorem roundAt_eq_floor_or_ceil_of_binade (mode : IEEERoundingMode) {t : ℝ}
    (hlo : 8388608 ≤ |t|) (hhi : |t| < 16777216) :
    ∃ m : ℤ, Model.roundAt .binary32 t mode = (m : ℝ) ∧ (m = ⌊t⌋ ∨ m = ⌈t⌉) := by
  open FloatLib.Floats.Formats.Flocq in
  have hmag : magnitude FloatLib.Numerics.binaryRadix t = 24 := by
    apply magnitude_eq_of_bpow_bounds FloatLib.Numerics.binaryRadix t 24
    · rw [bpow_binaryRadix]; norm_num; exact hlo
    · rw [bpow_binaryRadix]; norm_num; exact hhi
  have hcexp : cexp FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32) t = 0 := by
    simp [cexp, Model.fexpOf, fltExp, hmag, FloatFormat.binary32,
      FloatFormat.minSubnormalExponent, FloatFormat.minNormalExponent]
  have hscaled : scaledMantissa FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32) t = t := by
    simp [scaledMantissa, hcexp, bpow_binaryRadix]
  have hround : Model.roundAt .binary32 t mode = (roundingFunction mode t : ℝ) := by
    rw [Model.roundAt_eq_round, FloatLib.Floats.Formats.Flocq.round, hcexp, hscaled]
    simp [FloatLib.Floats.Formats.Flocq.toReal, bpow_binaryRadix]
  refine ⟨roundingFunction mode t, hround, ?_⟩
  simpa [floorRound, ceilRound] using valid_round_eq_floor_or_ceil (roundingFunction mode) t

/-- When `y` is finite with `|y| ≥ 1/2` and `r0 ∈ {⌊y⌋, ⌈y⌉}`, `y - r0` is exact in binary32
(by Sterbenz's lemma when `r0 ≠ 0`, and trivially when `r0 = 0`). -/
private theorem genericRepresentable_sub_floor_or_ceil (y : Model .binary32)
    (hy_fin : y.isFinite = true) (hy_ge : 1 / 2 ≤ |y.toReal|) {r0 : ℤ}
    (hr0_lo : -13312 ≤ r0) (hr0_hi : r0 ≤ 13312) (hr0 : r0 = ⌊y.toReal⌋ ∨ r0 = ⌈y.toReal⌉) :
    FloatLib.Floats.Formats.Flocq.GenericRepresentable FloatLib.Numerics.binaryRadix
      (Model.fexpOf .binary32) (y.toReal - (r0 : ℝ)) := by
  open FloatLib.Floats.Formats.Flocq in
  have hy_gen := Model.toReal_genericFormat_of_isFinite y hy_fin
  by_cases hr0_zero : r0 = 0
  · subst hr0_zero; simpa using hy_gen
  have hr0_gen : GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32)
      (r0 : ℝ) := by
    rw [← roundAt_intCast_binary32 .nearest (by omega : -13313 ≤ r0) (by omega : r0 ≤ 13313)]
    exact Model.genericFormat_roundAt .binary32 (r0 : ℝ) .nearest
  have hprec : (0 : ℤ) < (FloatFormat.binary32.fracWidth : ℤ) + 1 := by decide
  have hpos_case : ∀ (a : ℝ) (m : ℤ), 1 / 2 ≤ a → m ≠ 0 → (m = ⌊a⌋ ∨ m = ⌈a⌉) →
      GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32) a →
      GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32) (m : ℝ) →
      GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32) (a - m) := by
    intro a m ha hm0 hm ha_gen hm_gen
    have hm_ge1 : (1 : ℤ) ≤ m := by
      rcases hm with rfl | rfl
      · have h0 : (0 : ℤ) ≤ ⌊a⌋ := Int.floor_nonneg.mpr (by linarith)
        omega
      · exact Int.le_ceil_iff.mpr (by norm_num; linarith)
    have hm_ge1_r : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm_ge1
    have ha_le : a ≤ 2 * (m : ℝ) := by
      rcases hm with rfl | rfl
      · linarith [Int.lt_floor_add_one a]
      · linarith [Int.le_ceil a]
    have hm_le : (m : ℝ) ≤ 2 * a := by
      rcases hm with rfl | rfl
      · linarith [Int.floor_le a]
      · by_cases ha1 : a ≤ 1
        · have hceil1 : ⌈a⌉ ≤ 1 := Int.ceil_le.mpr (by norm_cast)
          have hceil1_r : (⌈a⌉ : ℝ) ≤ 1 := by exact_mod_cast hceil1
          linarith
        · linarith [Int.ceil_lt_add_one a]
    exact genericRepresentable_flt_sterbenz FloatFormat.binary32.minSubnormalExponent
      ((FloatFormat.binary32.fracWidth : ℤ) + 1) hprec ha_le hm_le ha_gen hm_gen
  rcases le_or_gt 0 y.toReal with hy_nn | hy_neg
  · rw [abs_of_nonneg hy_nn] at hy_ge
    exact hpos_case y.toReal r0 hy_ge hr0_zero hr0 hy_gen hr0_gen
  · rw [abs_of_neg hy_neg] at hy_ge
    have hmir : -r0 = ⌊-y.toReal⌋ ∨ -r0 = ⌈-y.toReal⌉ := by
      rw [Int.floor_neg, Int.ceil_neg]
      rcases hr0 with rfl | rfl
      · exact Or.inr rfl
      · exact Or.inl rfl
    have hneg_sub := hpos_case (-y.toReal) (-r0) hy_ge (by omega) hmir
      (genericRepresentable_neg y.toReal hy_gen)
      (by simpa using genericRepresentable_neg (r0 : ℝ) hr0_gen)
    have hres := genericRepresentable_neg (-y.toReal - (-r0 : ℤ)) hneg_sub
    have heq : -(-y.toReal - ((-r0 : ℤ) : ℝ)) = y.toReal - (r0 : ℝ) := by push_cast; ring
    rwa [heq] at hres

private theorem flt_iff_toReal_lt {x y : Model .binary32}
    (hx : x.isFinite = true) (hy : y.isFinite = true) :
    Core.flt x y = true ↔ x.toReal < y.toReal := by
  simp only [Core.flt, beq_iff_eq]
  exact Model.compare_eq_some_lt_iff_toReal_lt_of_isFinite x y hx hy

private theorem fgt_iff_toReal_gt {x y : Model .binary32}
    (hx : x.isFinite = true) (hy : y.isFinite = true) :
    Core.fgt x y = true ↔ y.toReal < x.toReal := by
  simp only [Core.fgt, beq_iff_eq]
  exact Model.compare_eq_some_gt_iff_toReal_gt_of_isFinite x y hx hy

/-- Exact integer specification of `Core.nearestInt Expf.DoubleEval.config mode y` on the main
range (excluding the two boundary points with `1/2 - 2⁻²⁴ < |y| < 1/2`). -/
private theorem nearestInt_spec (mode : IEEERoundingMode) (y : Model .binary32)
    (hy_fin : y.isFinite = true) (hy_lo : -13312 ≤ y.toReal) (hy_hi : y.toReal ≤ 11392)
    (hgap : 1 / 2 ≤ |y.toReal| ∨ |y.toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ)) :
    ∃ k : ℤ, -13312 ≤ k ∧ k ≤ 11392 ∧
      (Core.nearestInt Expf.DoubleEval.config mode y).isFinite = true ∧
      (Core.nearestInt Expf.DoubleEval.config mode y).toReal = (k : ℝ) ∧
      |y.toReal - (k : ℝ)| ≤ 1 / 2 ∧
      (|y.toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ) → k = 0) := by
  have hcfg_ni : Expf.DoubleEval.config.hasNearestInt = false := rfl
  have hcfg_rn : Expf.DoubleEval.config.assumeRoundNearestOnly = false := rfl
  have hneg_limit_fin : (Model.neg limit32).isFinite = true := by
    simpa using isFinite_limit32
  have hneg_limit_real : (Model.neg limit32).toReal = -16777216 := by
    rw [Model.toReal_neg limit32 isFinite_limit32, toReal_limit32]
  have hflt_lim : Core.flt y limit32 = true :=
    (flt_iff_toReal_lt hy_fin isFinite_limit32).mpr (by rw [toReal_limit32]; linarith)
  have hfgt_nlim : Core.fgt y (Model.neg limit32) = true :=
    (fgt_iff_toReal_gt hy_fin hneg_limit_fin).mpr (by rw [hneg_limit_real]; linarith)
  -- Step 1: Analyze the shifted round `r`
  set r : Model .binary32 :=
    if Core.flt y (Model.posZero .binary32) then
      Model.add (Model.sub y magic32 mode) magic32 mode
    else
      Model.sub (Model.add y magic32 mode) magic32 mode with hr_def
  have hr_spec : ∃ r0 : ℤ, r.isFinite = true ∧ r.toReal = (r0 : ℝ) ∧
      (r0 = ⌊y.toReal⌋ ∨ r0 = ⌈y.toReal⌉) ∧ -13312 ≤ r0 ∧ r0 ≤ 11392 := by
    have hz_fin : (Model.posZero .binary32).isFinite = true := by decide +kernel
    have hz_real : (Model.posZero .binary32).toReal = 0 := by simp
    by_cases hneg : Core.flt y (Model.posZero .binary32) = true
    · have hy_lt0 : y.toReal < 0 := by
        have := (flt_iff_toReal_lt hy_fin hz_fin).mp hneg; rwa [hz_real] at this
      have hs_bound : |y.toReal - magic32.toReal| ≤ (Model.posMaxFinite .binary32).toReal := by
        rw [toReal_magic32, abs_of_neg (by linarith)]
        linarith [posMaxFinite_binary32_ge]
      obtain ⟨hs_fin, hs_round⟩ := Model.sub_finite_roundAt (mode := mode) (by decide) hy_fin
        isFinite_magic32 hs_bound
      have hs_abs_lo : 8388608 ≤ |y.toReal - magic32.toReal| := by
        rw [toReal_magic32, abs_of_neg (by linarith)]; linarith
      have hs_abs_hi : |y.toReal - magic32.toReal| < 16777216 := by
        rw [toReal_magic32, abs_of_neg (by linarith)]; linarith
      obtain ⟨m, hm_eq, hm_fc⟩ := roundAt_eq_floor_or_ceil_of_binade mode hs_abs_lo hs_abs_hi
      set r0 : ℤ := m + 8388608
      have hr0_fc : r0 = ⌊y.toReal⌋ ∨ r0 = ⌈y.toReal⌉ := by
        rw [toReal_magic32] at hm_fc
        have hfl : ⌊y.toReal - 8388608⌋ = ⌊y.toReal⌋ - 8388608 := by simp
        have hce : ⌈y.toReal - 8388608⌉ = ⌈y.toReal⌉ - 8388608 := by simp
        rcases hm_fc with h | h
        · left; omega
        · right; omega
      have hr0_lo : -13312 ≤ r0 := by
        rcases hr0_fc with h | h <;> rw [h]
        · exact Int.le_floor.mpr (by exact_mod_cast hy_lo)
        · exact (Int.le_floor.mpr (by exact_mod_cast hy_lo)).trans (Int.floor_le_ceil y.toReal)
      have hr0_hi : r0 ≤ 11392 := by
        rcases hr0_fc with h | h <;> rw [h]
        · exact (Int.floor_le_ceil y.toReal).trans (Int.ceil_le.mpr (by exact_mod_cast hy_hi))
        · exact Int.ceil_le.mpr (by exact_mod_cast hy_hi)
      have hadd_real : (Model.sub y magic32 mode).toReal + magic32.toReal = (r0 : ℝ) := by
        rw [hs_round, hm_eq, toReal_magic32]; push_cast [r0]; ring
      have hadd_bound : |(Model.sub y magic32 mode).toReal + magic32.toReal| ≤
          (Model.posMaxFinite .binary32).toReal := by
        rw [hadd_real]
        have hr0_abs : |(r0 : ℝ)| ≤ 13312 := abs_le.mpr ⟨by exact_mod_cast hr0_lo,
          by linarith [show (r0 : ℝ) ≤ 11392 by exact_mod_cast hr0_hi]⟩
        linarith [posMaxFinite_binary32_ge]
      obtain ⟨hfin, hround⟩ := Model.add_finite_roundAt (mode := mode) (by decide) hs_fin
        isFinite_magic32 hadd_bound
      have hexact := roundAt_intCast_binary32 mode (by omega : -13313 ≤ r0) (by omega : r0 ≤ 13313)
      have hr_eq : r = Model.add (Model.sub y magic32 mode) magic32 mode := by
        simp only [hr_def, hneg, ↓reduceIte]
      refine ⟨r0, ?_, ?_, hr0_fc, hr0_lo, hr0_hi⟩
      · rw [hr_eq]; exact hfin
      · rw [hr_eq, hround, hadd_real, hexact]
    · have hy_ge0 : 0 ≤ y.toReal := by
        by_contra hlt; push Not at hlt
        exact hneg ((flt_iff_toReal_lt hy_fin hz_fin).mpr (by rwa [hz_real]))
      have hs_bound : |y.toReal + magic32.toReal| ≤ (Model.posMaxFinite .binary32).toReal := by
        rw [toReal_magic32, abs_of_nonneg (by linarith)]
        linarith [posMaxFinite_binary32_ge]
      obtain ⟨hs_fin, hs_round⟩ := Model.add_finite_roundAt (mode := mode) (by decide) hy_fin
        isFinite_magic32 hs_bound
      have hs_abs_lo : 8388608 ≤ |y.toReal + magic32.toReal| := by
        rw [toReal_magic32, abs_of_nonneg (by linarith)]; linarith
      have hs_abs_hi : |y.toReal + magic32.toReal| < 16777216 := by
        rw [toReal_magic32, abs_of_nonneg (by linarith)]; linarith
      obtain ⟨m, hm_eq, hm_fc⟩ := roundAt_eq_floor_or_ceil_of_binade mode hs_abs_lo hs_abs_hi
      set r0 : ℤ := m - 8388608
      have hr0_fc : r0 = ⌊y.toReal⌋ ∨ r0 = ⌈y.toReal⌉ := by
        rw [toReal_magic32] at hm_fc
        have hfl : ⌊y.toReal + 8388608⌋ = ⌊y.toReal⌋ + 8388608 := by simp
        have hce : ⌈y.toReal + 8388608⌉ = ⌈y.toReal⌉ + 8388608 := by simp
        rcases hm_fc with h | h
        · left; omega
        · right; omega
      have hr0_lo : -13312 ≤ r0 := by
        rcases hr0_fc with h | h <;> rw [h]
        · exact Int.le_floor.mpr (by exact_mod_cast hy_lo)
        · exact (Int.le_floor.mpr (by exact_mod_cast hy_lo)).trans (Int.floor_le_ceil y.toReal)
      have hr0_hi : r0 ≤ 11392 := by
        rcases hr0_fc with h | h <;> rw [h]
        · exact (Int.floor_le_ceil y.toReal).trans (Int.ceil_le.mpr (by exact_mod_cast hy_hi))
        · exact Int.ceil_le.mpr (by exact_mod_cast hy_hi)
      have hsub_real : (Model.add y magic32 mode).toReal - magic32.toReal = (r0 : ℝ) := by
        rw [hs_round, hm_eq, toReal_magic32]; push_cast [r0]; ring
      have hsub_bound : |(Model.add y magic32 mode).toReal - magic32.toReal| ≤
          (Model.posMaxFinite .binary32).toReal := by
        rw [hsub_real]
        have hr0_abs : |(r0 : ℝ)| ≤ 13312 := abs_le.mpr ⟨by exact_mod_cast hr0_lo,
          by linarith [show (r0 : ℝ) ≤ 11392 by exact_mod_cast hr0_hi]⟩
        linarith [posMaxFinite_binary32_ge]
      obtain ⟨hfin, hround⟩ := Model.sub_finite_roundAt (mode := mode) (by decide) hs_fin
        isFinite_magic32 hsub_bound
      have hexact := roundAt_intCast_binary32 mode (by omega : -13313 ≤ r0) (by omega : r0 ≤ 13313)
      have hneg_f : Core.flt y (Model.posZero .binary32) = false := Bool.eq_false_iff.mpr hneg
      have hr_eq : r = Model.sub (Model.add y magic32 mode) magic32 mode := by
        simp only [hr_def, hneg_f, Bool.false_eq_true, ↓reduceIte]
      refine ⟨r0, ?_, ?_, hr0_fc, hr0_lo, hr0_hi⟩
      · rw [hr_eq]; exact hfin
      · rw [hr_eq, hround, hsub_real, hexact]
  obtain ⟨r0, hr_fin, hr_real, hr0_fc, hr0_lo, hr0_hi⟩ := hr_spec
  have hy_sub_r0_lt1 : |y.toReal - (r0 : ℝ)| < 1 := by
    rw [abs_lt]
    rcases hr0_fc with rfl | rfl
    · exact ⟨by linarith [Int.floor_le y.toReal], by linarith [Int.lt_floor_add_one y.toReal]⟩
    · exact ⟨by linarith [Int.ceil_lt_add_one y.toReal], by linarith [Int.le_ceil y.toReal]⟩
  -- Step 2: Analyze `diff = Model.sub y r mode` and the ±1 correction
  set diff : Model .binary32 := Model.sub y r mode with hdiff_def
  have hdiff_bound : |y.toReal - r.toReal| ≤ (Model.posMaxFinite .binary32).toReal := by
    rw [hr_real]; linarith [posMaxFinite_binary32_ge]
  obtain ⟨hdiff_fin, hdiff_round⟩ := Model.sub_finite_roundAt (mode := mode) (by decide) hy_fin
    hr_fin hdiff_bound
  have hone_fin : (Model.posOne .binary32).isFinite = true := Model.isFinite_posOne .binary32
  have hone_real : (Model.posOne .binary32).toReal = 1 := Model.toReal_posOne .binary32
  have hnhalf_fin : (Model.neg half32).isFinite = true := by simpa using isFinite_half32
  have hnhalf_real : (Model.neg half32).toReal = -(1 / 2) := by
    rw [Model.toReal_neg half32 isFinite_half32, toReal_half32]
  have hni_eq : Core.nearestInt Expf.DoubleEval.config mode y =
      if Core.fgt diff half32 then Model.add r (Model.posOne .binary32) mode
      else if Core.flt diff (Model.neg half32) then Model.sub r (Model.posOne .binary32) mode
      else r := by
    simp only [Core.nearestInt, hcfg_ni, Bool.false_eq_true, ↓reduceIte,
      Core.genericNearestInt, hcfg_rn, hflt_lim, hfgt_nlim, Bool.and_self]
    rfl
  -- Helper for `r + 1` and `r - 1` being exact integers
  have hr_add1 : (Model.add r (Model.posOne .binary32) mode).isFinite = true ∧
      (Model.add r (Model.posOne .binary32) mode).toReal = ((r0 + 1 : ℤ) : ℝ) := by
    have hb : |r.toReal + (Model.posOne .binary32).toReal| ≤
        (Model.posMaxFinite .binary32).toReal := by
      rw [hr_real, hone_real]
      have h1 : |(r0 : ℝ) + 1| ≤ 13313 := abs_le.mpr ⟨by
        linarith [show (-13312 : ℝ) ≤ r0 by exact_mod_cast hr0_lo],
        by linarith [show (r0 : ℝ) ≤ 11392 by exact_mod_cast hr0_hi]⟩
      linarith [posMaxFinite_binary32_ge]
    obtain ⟨hf, hr'⟩ := Model.add_finite_roundAt (mode := mode) (by decide) hr_fin hone_fin hb
    refine ⟨hf, ?_⟩
    rw [hr', hr_real, hone_real, show (r0 : ℝ) + 1 = ((r0 + 1 : ℤ) : ℝ) by push_cast; ring]
    exact roundAt_intCast_binary32 mode (by omega) (by omega)
  have hr_sub1 : (Model.sub r (Model.posOne .binary32) mode).isFinite = true ∧
      (Model.sub r (Model.posOne .binary32) mode).toReal = ((r0 - 1 : ℤ) : ℝ) := by
    have hb : |r.toReal - (Model.posOne .binary32).toReal| ≤
        (Model.posMaxFinite .binary32).toReal := by
      rw [hr_real, hone_real]
      have h1 : |(r0 : ℝ) - 1| ≤ 13313 := abs_le.mpr ⟨by
        linarith [show (-13312 : ℝ) ≤ r0 by exact_mod_cast hr0_lo],
        by linarith [show (r0 : ℝ) ≤ 11392 by exact_mod_cast hr0_hi]⟩
      linarith [posMaxFinite_binary32_ge]
    obtain ⟨hf, hr'⟩ := Model.sub_finite_roundAt (mode := mode) (by decide) hr_fin hone_fin hb
    refine ⟨hf, ?_⟩
    rw [hr', hr_real, hone_real, show (r0 : ℝ) - 1 = ((r0 - 1 : ℤ) : ℝ) by push_cast; ring]
    exact roundAt_intCast_binary32 mode (by omega) (by omega)
  -- Split on the gap hypothesis `1/2 ≤ |y| ∨ |y| ≤ 1/2 - 2^-24`
  rcases hgap with hy_ge | hy_tiny
  · -- Case 1: `|y| ≥ 1/2` ⇒ `diff = y - r0` is exact!
    have hdiff_exact : diff.toReal = y.toReal - (r0 : ℝ) := by
      rw [hdiff_def, hdiff_round, hr_real]
      exact Model.roundAt_of_genericFormat .binary32
        (genericRepresentable_sub_floor_or_ceil y hy_fin hy_ge hr0_lo (by omega) hr0_fc) mode
    have hnot_tiny : ¬(|y.toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ)) := by
      have : (0 : ℝ) < (2 : ℝ) ^ (-24 : ℤ) := by positivity
      linarith
    by_cases hgt : Core.fgt diff half32 = true
    · have hgt_r : 1 / 2 < y.toReal - (r0 : ℝ) := by
        have := (fgt_iff_toReal_gt hdiff_fin isFinite_half32).mp hgt
        rwa [toReal_half32, hdiff_exact] at this
      have hk_lo : -13312 ≤ r0 + 1 := by omega
      have hk_hi : r0 + 1 ≤ 11392 := by
        have : ((r0 + 1 : ℤ) : ℝ) < 11393 := by push_cast; linarith
        have : r0 + 1 < 11393 := by exact_mod_cast this
        omega
      have hni' : Core.nearestInt Expf.DoubleEval.config mode y =
          Model.add r (Model.posOne .binary32) mode := by
        simp only [hni_eq, hgt, ↓reduceIte]
      refine ⟨r0 + 1, hk_lo, hk_hi, ?_, ?_, ?_, fun ht => absurd ht hnot_tiny⟩
      · rw [hni']; exact hr_add1.1
      · rw [hni']; exact hr_add1.2
      · rw [abs_le]; push_cast
        have := (abs_lt.mp hy_sub_r0_lt1).2
        constructor <;> linarith
    · have hgt_f : Core.fgt diff half32 = false := Bool.eq_false_iff.mpr hgt
      by_cases hlt : Core.flt diff (Model.neg half32) = true
      · have hlt_r : y.toReal - (r0 : ℝ) < -(1 / 2) := by
          have := (flt_iff_toReal_lt hdiff_fin hnhalf_fin).mp hlt
          rwa [hnhalf_real, hdiff_exact] at this
        have hk_lo : -13312 ≤ r0 - 1 := by
          have : (-13313 : ℝ) < ((r0 - 1 : ℤ) : ℝ) := by push_cast; linarith
          have : -13313 < r0 - 1 := by exact_mod_cast this
          omega
        have hk_hi : r0 - 1 ≤ 11392 := by omega
        have hni' : Core.nearestInt Expf.DoubleEval.config mode y =
            Model.sub r (Model.posOne .binary32) mode := by
          simp only [hni_eq, hgt_f, Bool.false_eq_true, ↓reduceIte, hlt]
        refine ⟨r0 - 1, hk_lo, hk_hi, ?_, ?_, ?_, fun ht => absurd ht hnot_tiny⟩
        · rw [hni']; exact hr_sub1.1
        · rw [hni']; exact hr_sub1.2
        · rw [abs_le]; push_cast
          have := (abs_lt.mp hy_sub_r0_lt1).1
          constructor <;> linarith
      · have hlt_f : Core.flt diff (Model.neg half32) = false := Bool.eq_false_iff.mpr hlt
        have hle_half : y.toReal - (r0 : ℝ) ≤ 1 / 2 := by
          by_contra hc; push Not at hc
          exact hgt ((fgt_iff_toReal_gt hdiff_fin isFinite_half32).mpr
            (by rw [toReal_half32, hdiff_exact]; exact hc))
        have hge_nhalf : -(1 / 2) ≤ y.toReal - (r0 : ℝ) := by
          by_contra hc; push Not at hc
          exact hlt ((flt_iff_toReal_lt hdiff_fin hnhalf_fin).mpr
            (by rw [hnhalf_real, hdiff_exact]; exact hc))
        have hni' : Core.nearestInt Expf.DoubleEval.config mode y = r := by
          simp only [hni_eq, hgt_f, hlt_f, Bool.false_eq_true, ↓reduceIte]
        refine ⟨r0, hr0_lo, hr0_hi, ?_, ?_, abs_le.mpr ⟨hge_nhalf, hle_half⟩,
          fun ht => absurd ht hnot_tiny⟩
        · rw [hni']; exact hr_fin
        · rw [hni']; exact hr_real
  · -- Case 2: `|y| ≤ 1/2 - 2^-24` ⇒ `r0 ∈ {-1, 0, 1}` and `kf = 0`!
    have hy_lt_half : |y.toReal| < 1 / 2 := by
      have : (0 : ℝ) < (2 : ℝ) ^ (-24 : ℤ) := by positivity
      linarith
    have hy_bounds := abs_le.mp hy_tiny
    have hr0_cases : r0 = -1 ∨ r0 = 0 ∨ r0 = 1 := by
      rcases hr0_fc with rfl | rfl
      · have h1 : (-1 : ℤ) ≤ ⌊y.toReal⌋ :=
          Int.le_floor.mpr (by norm_num; linarith [abs_lt.mp hy_lt_half])
        have h2 : ⌊y.toReal⌋ ≤ 0 := by
          have := Int.floor_le y.toReal
          have : (⌊y.toReal⌋ : ℝ) < 1 := by linarith [(abs_lt.mp hy_lt_half).2]
          have : ⌊y.toReal⌋ < 1 := by exact_mod_cast this
          omega
        omega
      · have h1 : (0 : ℤ) ≤ ⌈y.toReal⌉ := by
          have := Int.le_ceil y.toReal
          have : (-1 : ℝ) < (⌈y.toReal⌉ : ℝ) := by linarith [(abs_lt.mp hy_lt_half).1]
          have : -1 < ⌈y.toReal⌉ := by exact_mod_cast this
          omega
        have h2 : ⌈y.toReal⌉ ≤ 1 :=
          Int.ceil_le.mpr (by norm_num; linarith [abs_lt.mp hy_lt_half])
        omega
    have hkf_zero : (Core.nearestInt Expf.DoubleEval.config mode y).isFinite = true ∧
        (Core.nearestInt Expf.DoubleEval.config mode y).toReal = (0 : ℝ) := by
      rcases hr0_cases with rfl | rfl | rfl
      · -- `r0 = -1`: `diff ≥ 1/2 + 2^-24 > 1/2`, so `kf = r + 1 = 0`
        have hdiff_ge : 1 / 2 + (2 : ℝ) ^ (-24 : ℤ) ≤ diff.toReal := by
          rw [hdiff_def, hdiff_round, hr_real]
          have hmono := Model.roundAt_mono .binary32
            (x := (Model.ofNatBits 0x3F000001 : Model .binary32).toReal)
            (y := y.toReal - ((-1 : ℤ) : ℝ))
            (by rw [toReal_0x3F000001]; push_cast; linarith) mode
          rw [Model.roundAt_of_genericFormat .binary32
            (Model.toReal_genericFormat_of_isFinite _ isFinite_0x3F000001) mode,
            toReal_0x3F000001] at hmono
          exact hmono
        have hgt : Core.fgt diff half32 = true :=
          (fgt_iff_toReal_gt hdiff_fin isFinite_half32).mpr (by
            rw [toReal_half32]
            have : (0 : ℝ) < (2 : ℝ) ^ (-24 : ℤ) := by positivity
            linarith)
        have hni' : Core.nearestInt Expf.DoubleEval.config mode y =
            Model.add r (Model.posOne .binary32) mode := by
          simp only [hni_eq, hgt, ↓reduceIte]
        rw [hni']
        exact ⟨hr_add1.1, by rw [hr_add1.2]; norm_num⟩
      · -- `r0 = 0`: `diff = y`, so `|diff| < 1/2`, so `kf = r = 0`
        have hdiff_eq : diff.toReal = y.toReal := by
          rw [hdiff_def, hdiff_round, hr_real]
          simpa using Model.roundAt_of_genericFormat .binary32
            (Model.toReal_genericFormat_of_isFinite y hy_fin) mode
        have hgt_f : Core.fgt diff half32 = false := Bool.eq_false_iff.mpr fun h => by
          have := (fgt_iff_toReal_gt hdiff_fin isFinite_half32).mp h
          rw [toReal_half32, hdiff_eq] at this
          linarith [(abs_lt.mp hy_lt_half).2]
        have hlt_f : Core.flt diff (Model.neg half32) = false := Bool.eq_false_iff.mpr fun h => by
          have := (flt_iff_toReal_lt hdiff_fin hnhalf_fin).mp h
          rw [hnhalf_real, hdiff_eq] at this
          linarith [(abs_lt.mp hy_lt_half).1]
        have hni' : Core.nearestInt Expf.DoubleEval.config mode y = r := by
          simp only [hni_eq, hgt_f, hlt_f, Bool.false_eq_true, ↓reduceIte]
        rw [hni']
        exact ⟨hr_fin, by simpa using hr_real⟩
      · -- `r0 = 1`: `diff ≤ -1/2 - 2^-24 < -1/2`, so `kf = r - 1 = 0`
        have hdiff_le : diff.toReal ≤ -(1 / 2) - (2 : ℝ) ^ (-24 : ℤ) := by
          rw [hdiff_def, hdiff_round, hr_real]
          have hmono := Model.roundAt_mono .binary32
            (x := y.toReal - ((1 : ℤ) : ℝ))
            (y := (Model.ofNatBits 0xBF000001 : Model .binary32).toReal)
            (by rw [toReal_0xBF000001]; push_cast; linarith) mode
          rw [Model.roundAt_of_genericFormat .binary32
            (Model.toReal_genericFormat_of_isFinite _ isFinite_0xBF000001) mode,
            toReal_0xBF000001] at hmono
          exact hmono
        have hpos24 : (0 : ℝ) < (2 : ℝ) ^ (-24 : ℤ) := by positivity
        have hgt_f : Core.fgt diff half32 = false := Bool.eq_false_iff.mpr fun h => by
          have := (fgt_iff_toReal_gt hdiff_fin isFinite_half32).mp h
          rw [toReal_half32] at this; linarith
        have hlt : Core.flt diff (Model.neg half32) = true :=
          (flt_iff_toReal_lt hdiff_fin hnhalf_fin).mpr (by rw [hnhalf_real]; linarith)
        have hni' : Core.nearestInt Expf.DoubleEval.config mode y =
            Model.sub r (Model.posOne .binary32) mode := by
          simp only [hni_eq, hgt_f, Bool.false_eq_true, ↓reduceIte, hlt]
        rw [hni']
        exact ⟨hr_sub1.1, by rw [hr_sub1.2]; norm_num⟩
    exact ⟨0, by omega, by omega, hkf_zero.1, by simpa using hkf_zero.2,
      by simpa using hy_lt_half.le, fun _ => rfl⟩

/-! ## Section 5: Exactness of `submul` and binary64 widening cast -/

private theorem submul_exact (mode : IEEERoundingMode) (x kf : Model .binary32) {k : ℤ}
    (hx_fin : x.isFinite = true) (hkf_fin : kf.isFinite = true) (hkf_real : kf.toReal = (k : ℝ))
    (hk_lo : -13312 ≤ k) (hk_hi : k ≤ 11392) (hnear : |128 * x.toReal - (k : ℝ)| ≤ 1 / 2) :
    let rem := submul[Expf.DoubleEval.config, mode](x, kf, f32(0x3C000000#32))
    rem.isFinite = true ∧ rem.toReal = x.toReal - (k : ℝ) / 128 ∧ |rem.toReal| ≤ 1 / 256 := by
  open FloatLib.Floats.Formats.Flocq in
  have hcfg_fma : Expf.DoubleEval.config.hasFma .binary32 = false := rfl
  have hcfg_rn : Expf.DoubleEval.config.assumeRoundNearestOnly = false := rfl
  have hsubmul_eq : submul[Expf.DoubleEval.config, mode](x, kf, f32(0x3C000000#32)) =
      Model.add x (Model.mul (Model.neg kf) f32(0x3C000000#32) mode) mode :=
    Core.subMultiply_of_noFma_directed hcfg_fma hcfg_rn mode x kf f32(0x3C000000#32)
  -- Step 1: `p = (-kf) * (1/128) = -k / 128` is exact
  have hnkf_fin : (Model.neg kf).isFinite = true := by simpa using hkf_fin
  have hnkf_real : (Model.neg kf).toReal = -(k : ℝ) := by
    rw [Model.toReal_neg kf hkf_fin, hkf_real]
  have hk_abs : |(k : ℝ)| ≤ 13312 := abs_le.mpr ⟨by exact_mod_cast hk_lo,
    by linarith [show (k : ℝ) ≤ 11392 by exact_mod_cast hk_hi]⟩
  have hp_bound : |(Model.neg kf).toReal * f32(0x3C000000#32).toReal| ≤
      (Model.posMaxFinite .binary32).toReal := by
    rw [hnkf_real, toReal_c128inv, abs_mul, abs_neg, abs_of_pos (by norm_num : (0 : ℝ) < 1 / 128)]
    linarith [posMaxFinite_binary32_ge]
  obtain ⟨hp_fin, hp_round⟩ := Model.mul_finite_roundAt (mode := mode) (by decide) hnkf_fin
    isFinite_c128inv hp_bound
  have hbpow_m7 : bpow FloatLib.Numerics.binaryRadix (-7) = (1 / 128 : ℝ) := by
    rw [bpow_binaryRadix]; norm_num
  have hp_gen : GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32)
      ((Model.neg kf).toReal * bpow FloatLib.Numerics.binaryRadix (-7)) := by
    apply Model.genericFormat_mul_bpow .binary32
      (Model.toReal_genericFormat_of_isFinite (Model.neg kf) hnkf_fin) (-7)
    by_cases hk0 : k = 0
    · right; left; rw [hnkf_real, hk0]; simp
    · right; right
      have hk1 : (1 : ℝ) ≤ |(k : ℝ)| := by
        have : (1 : ℤ) ≤ |k| := Int.one_le_abs hk0
        exact_mod_cast this
      rw [Model.minNormalAt, bpow_binaryRadix, hnkf_real, hbpow_m7, abs_mul, abs_neg,
        abs_of_pos (by norm_num : (0 : ℝ) < 1 / 128)]
      have hmin : (2 : ℝ) ^ FloatFormat.binary32.minNormalExponent ≤ 1 / 128 := by
        have : FloatFormat.binary32.minNormalExponent = -126 := rfl
        rw [this]; norm_num
      linarith
  have hp_real : (Model.mul (Model.neg kf) f32(0x3C000000#32) mode).toReal = -(k : ℝ) / 128 := by
    rw [hp_round, toReal_c128inv, ← hbpow_m7,
      Model.roundAt_of_genericFormat .binary32 hp_gen mode, hnkf_real, hbpow_m7]
    ring
  -- Step 2: `x + p = x - k / 128` is exact by Sterbenz (or trivial when `k = 0`)
  have hrem_abs : |x.toReal - (k : ℝ) / 128| ≤ 1 / 256 := by
    have h1 : x.toReal - (k : ℝ) / 128 = (128 * x.toReal - (k : ℝ)) / 128 := by ring
    rw [h1, abs_div, abs_of_pos (by norm_num : (0 : ℝ) < 128)]
    linarith
  have hadd_bound : |x.toReal + (Model.mul (Model.neg kf) f32(0x3C000000#32) mode).toReal| ≤
      (Model.posMaxFinite .binary32).toReal := by
    rw [hp_real, show x.toReal + -(k : ℝ) / 128 = x.toReal - (k : ℝ) / 128 by ring]
    linarith [posMaxFinite_binary32_ge]
  obtain ⟨hrem_fin, hrem_round⟩ := Model.add_finite_roundAt (mode := mode) (by decide) hx_fin
    hp_fin hadd_bound
  have hx_gen := Model.toReal_genericFormat_of_isFinite x hx_fin
  have hp_gen' : GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32)
      (-(k : ℝ) / 128) := by
    rw [← hp_real]; exact Model.toReal_genericFormat_of_isFinite _ hp_fin
  have hk128_gen : GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32)
      ((k : ℝ) / 128) := by
    have := genericRepresentable_neg (-(k : ℝ) / 128) hp_gen'
    simpa [neg_div] using this
  have hprec : (0 : ℤ) < (FloatFormat.binary32.fracWidth : ℤ) + 1 := by decide
  have hrem_gen : GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32)
      (x.toReal - (k : ℝ) / 128) := by
    have hnb := abs_le.mp hnear
    rcases lt_trichotomy k 0 with hk_neg | rfl | hk_pos
    · have hk1 : (k : ℝ) ≤ -1 := by exact_mod_cast Int.le_sub_one_of_lt hk_neg
      have h1 : -x.toReal ≤ 2 * (-(k : ℝ) / 128) := by linarith
      have h2 : -(k : ℝ) / 128 ≤ 2 * (-x.toReal) := by linarith
      have hnx_gen : GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32)
          (-x.toReal) := genericRepresentable_neg x.toReal hx_gen
      have hst : GenericRepresentable FloatLib.Numerics.binaryRadix (Model.fexpOf .binary32)
          (-x.toReal - -(k : ℝ) / 128) :=
        genericRepresentable_flt_sterbenz FloatFormat.binary32.minSubnormalExponent
          ((FloatFormat.binary32.fracWidth : ℤ) + 1) hprec h1 h2 hnx_gen hp_gen'
      have hneg := genericRepresentable_neg (-x.toReal - -(k : ℝ) / 128) hst
      have heq : -(-x.toReal - -(k : ℝ) / 128) = x.toReal - (k : ℝ) / 128 := by ring
      rwa [heq] at hneg
    · simpa using hx_gen
    · have hk1 : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk_pos
      have h1 : x.toReal ≤ 2 * ((k : ℝ) / 128) := by linarith
      have h2 : (k : ℝ) / 128 ≤ 2 * x.toReal := by linarith
      exact genericRepresentable_flt_sterbenz FloatFormat.binary32.minSubnormalExponent
        ((FloatFormat.binary32.fracWidth : ℤ) + 1) hprec h1 h2 hx_gen hk128_gen
  dsimp only
  rw [hsubmul_eq]
  refine ⟨hrem_fin, ?_, ?_⟩
  · rw [hrem_round, hp_real, show x.toReal + -(k : ℝ) / 128 = x.toReal - (k : ℝ) / 128 by ring]
    exact Model.roundAt_of_genericFormat .binary32 hrem_gen mode
  · rw [hrem_round, hp_real, show x.toReal + -(k : ℝ) / 128 = x.toReal - (k : ℝ) / 128 by ring,
      Model.roundAt_of_genericFormat .binary32 hrem_gen mode]
    exact hrem_abs

private theorem fpCast_binary64_exact (mode : IEEERoundingMode) (rem : Model .binary32)
    (hrem_fin : rem.isFinite = true) (hrem_abs : |rem.toReal| ≤ 1 / 256) :
    (Core.fpCast .binary64 mode rem).isFinite = true ∧
      (Core.fpCast .binary64 mode rem).toReal = rem.toReal := by
  obtain ⟨d, hd⟩ := Model.exists_toDyadic?_of_isFinite hrem_fin
  have hreal : rem.toReal = d.toReal := by rw [Model.toReal_eq, hd]
  have hcast : Core.fpCast .binary64 mode rem =
      Model.Internal.Directed.roundDyadic .binary64 mode d := by
    rw [Core.fpCast]
    exact KernelPath.cast_of_finite mode rem d hd (by decide)
  have hsig : d.significand < 2 ^ (FloatFormat.binary64.fracWidth + 1) := by
    have h32 := Model.toDyadic?_significand_lt rem hd
    exact lt_trans h32 (by decide)
  have hexp : FloatFormat.binary64.minSubnormalExponent ≤ d.exponent := by
    have h32 := Model.minSubnormalExponent_le_toDyadic? rem hd
    have hle : FloatFormat.binary64.minSubnormalExponent ≤
        FloatFormat.binary32.minSubnormalExponent := by decide
    omega
  have hbound : |d.toReal| ≤ (Model.posMaxFinite .binary64).toReal := by
    rw [← hreal]
    linarith [Model.one_le_toReal_posMaxFinite .binary64]
  rw [hcast, hreal]
  exact Model.Internal.Directed.roundDyadic_of_representable .binary64 (by decide) mode d
    hsig hexp hbound

/-! ## Section 6: Integer conversion, table indices, and `mainBody` evaluation -/

private theorem fptosi_int_eq (kf : Model .binary32) {k : ℤ}
    (hkf_fin : kf.isFinite = true) (hkf_real : kf.toReal = (k : ℝ))
    (hk_lo : -13312 ≤ k) (hk_hi : k ≤ 11392) :
    Core.fptosi? 32 kf = some (BitVec.ofInt 32 k) := by
  obtain ⟨d, hd⟩ := Model.exists_toDyadic?_of_isFinite hkf_fin
  have hexact : Model.exactValue kf = .finite d := Model.exactValue_eq_finite_iff.mpr hd
  have hd_real : d.toReal = (k : ℝ) := by rw [← hkf_real, Model.toReal_eq, hd]
  have htz : (if 0 ≤ d.toReal then ⌊d.toReal⌋ else ⌈d.toReal⌉) = k := by
    rw [hd_real, Int.floor_intCast, Int.ceil_intCast, ite_self]
  have hrange : FloatLib.Numerics.Representations.FixedInt.InRange 32
      (if 0 ≤ d.toReal then ⌊d.toReal⌋ else ⌈d.toReal⌉) := by
    rw [htz]
    change (BitVec.intMin 32).toInt ≤ k ∧ k ≤ (BitVec.intMax 32).toInt
    have hmin : (BitVec.intMin 32).toInt = -2147483648 := by decide
    have hmax : (BitVec.intMax 32).toInt = 2147483647 := by decide
    omega
  have hconvExact := ExecDType.convertToIntegerExact_towardZero_of_exactValue_eq_finite_of_inRange
    (width := 32) kf d hexact hrange
  have hconv := ExecDType.convertToInteger_of_convertToIntegerExact_eq_success hconvExact
  rw [htz] at hconv
  simp only [Core.fptosi?, hconv, FloatLib.Numerics.Representations.FixedInt.ofInt]

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
    Core.sadd? (BitVec.ofInt 32 k) (0x68#32 <<< 7) =
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
  simp only [Core.sadd?, hov, Bool.false_eq_true, ↓reduceIte, hsum]

private theorem indices_of_sumBv {n : ℕ} (hn : n ≤ 24704) :
    (BitVec.sshiftRight (BitVec.ofNat 32 n) 7).toNat = n / 128 ∧
    (BitVec.ofNat 32 n &&& 0x7F#32).toNat = n % 128 ∧
    n / 128 < Expf.DoubleEval.EXP_M1.size ∧
    n % 128 < Expf.DoubleEval.EXP_M2.size := by
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
  have hm1 : Expf.DoubleEval.EXP_M1.size = 195 := rfl
  have hm2 : Expf.DoubleEval.EXP_M2.size = 128 := rfl
  refine ⟨hsr, hmid, by omega, by omega⟩

private theorem option_bind_eq {α β : Type} {o : Option α} {a : α} {f : α → Option β}
    (h : o = some a) : (o >>= f) = f a := by
  rw [h]; rfl

private theorem mainBody_eval (mode : IEEERoundingMode) (x : Model .binary32)
    {kBv sumBv : BitVec 32} {hiIdx midIdx : ℕ}
    (hfptosi : Core.fptosi? 32 (Core.nearestInt Expf.DoubleEval.config mode
        (Core.fmul mode x f32(0x43000000#32))) = some kBv)
    (hsadd : Core.sadd? kBv (0x68#32 <<< 7) = some sumBv)
    (hhi_eq : (BitVec.sshiftRight sumBv 7).toNat = hiIdx)
    (hmid_eq : (sumBv &&& 0x7F#32).toNat = midIdx)
    (hi_lt : hiIdx < Expf.DoubleEval.EXP_M1.size)
    (mid_lt : midIdx < Expf.DoubleEval.EXP_M2.size) :
    mainBody mode x = some (
      Core.fpCast .binary32 mode (
        Core.fmul mode
          (Core.fmul mode
            (Expf.DoubleEval.EXP_M1[hiIdx]'hi_lt)
            (Expf.DoubleEval.EXP_M2[midIdx]'mid_lt))
          (horner[Expf.DoubleEval.config, mode]
            (Core.fpCast .binary64 mode
              (submul[Expf.DoubleEval.config, mode](x,
                Core.nearestInt Expf.DoubleEval.config mode
                  (Core.fmul mode x f32(0x43000000#32)),
                f32(0x3C000000#32))))
            [f64(0x3FF0000000000000#64), f64(0x3FEFFFFFFFFFF777#64),
             f64(0x3FE000000000071C#64), f64(0x3FC555566668E5E7#64),
             f64(0x3FA55555555EF243#64)]))) := by
  unfold mainBody
  rw [option_bind_eq hfptosi]
  rw [option_bind_eq hsadd]
  have h1 : Expf.DoubleEval.EXP_M1[(BitVec.sshiftRight sumBv 7).toNat]? =
      some (Expf.DoubleEval.EXP_M1[hiIdx]'hi_lt) := by
    rw [hhi_eq, Array.getElem?_eq_getElem hi_lt]
  have h2 : Expf.DoubleEval.EXP_M2[(sumBv &&& 0x7F#32).toNat]? =
      some (Expf.DoubleEval.EXP_M2[midIdx]'mid_lt) := by
    rw [hmid_eq, Array.getElem?_eq_getElem mid_lt]
  rw [option_bind_eq h1]
  rw [option_bind_eq h2]
  rfl

/-! ## Section 7: Assembly and public reduction definitions/theorems -/

private def redKf (mode : IEEERoundingMode) (b : BitVec 32) : Model .binary32 :=
  Core.nearestInt Expf.DoubleEval.config mode (Core.fmul mode f32(b) f32(0x43000000#32))

private def redXd (mode : IEEERoundingMode) (b : BitVec 32) : Model .binary64 :=
  Core.fpCast .binary64 mode
    (submul[Expf.DoubleEval.config, mode](f32(b), redKf mode b, f32(0x3C000000#32)))

private def redSumBv (mode : IEEERoundingMode) (b : BitVec 32) : BitVec 32 :=
  (Core.fptosi? 32 (redKf mode b)).getD 0#32 + (0x68#32 <<< 7)

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
      Core.fptosi? 32 (redKf mode b) = some (BitVec.ofInt 32 k) ∧
      redSumBv mode b = BitVec.ofNat 32 (k + 13312).toNat ∧
      redHiIdx mode b = (k + 13312).toNat / 128 ∧
      redMidIdx mode b = (k + 13312).toNat % 128 ∧
      redHiIdx mode b < Expf.DoubleEval.EXP_M1.size ∧
      redMidIdx mode b < Expf.DoubleEval.EXP_M2.size ∧
      (redXd mode b).isFinite = true ∧
      (redXd mode b).toReal = f32(b).toReal - (k : ℝ) / 128 ∧
      |(redXd mode b).toReal| ≤ 1 / 256 ∧
      (|128 * f32(b).toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ) → k = 0) := by
  have hx_abs : |f32(b).toReal| ≤ 104 := abs_le.mpr ⟨hx_lo, by linarith⟩
  obtain ⟨hy_fin, hy_real⟩ := fmul_128_exact mode f32(b) hx_fin hx_abs
  have hy_lo : -13312 ≤ (Core.fmul mode f32(b) f32(0x43000000#32)).toReal := by
    rw [hy_real]; linarith
  have hy_hi : (Core.fmul mode f32(b) f32(0x43000000#32)).toReal ≤ 11392 := by
    rw [hy_real]; linarith
  have hy_gap : 1 / 2 ≤ |(Core.fmul mode f32(b) f32(0x43000000#32)).toReal| ∨
      |(Core.fmul mode f32(b) f32(0x43000000#32)).toReal| ≤ 1 / 2 - (2 : ℝ) ^ (-24 : ℤ) := by
    rwa [hy_real]
  obtain ⟨k, hk_lo, hk_hi, hkf_fin, hkf_real, hnear, htiny_k⟩ :=
    nearestInt_spec mode _ hy_fin hy_lo hy_hi hy_gap
  rw [hy_real] at hnear htiny_k
  obtain ⟨hrem_fin, hrem_real, hrem_abs⟩ :=
    submul_exact mode f32(b) _ hx_fin hkf_fin hkf_real hk_lo hk_hi hnear
  obtain ⟨hxd_fin, hxd_real⟩ := fpCast_binary64_exact mode _ hrem_fin hrem_abs
  have hfptosi : Core.fptosi? 32 (redKf mode b) = some (BitVec.ofInt 32 k) :=
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
    (hexpf : Expf.DoubleEval.expf mode f32(b) = mainBody mode f32(b))
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
      Expf.DoubleEval.expf mode f32(b) = mainBody mode f32(b) ∧
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
info: 'LibcMath.Extracted.Expf.RangeReduction.mainReduction_of_pos' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms mainReduction_of_pos

/--
info: 'LibcMath.Extracted.Expf.RangeReduction.mainReduction_of_neg' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms mainReduction_of_neg

/--
info: 'LibcMath.Extracted.Expf.RangeReduction.mainReduction_of_tiny' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms mainReduction_of_tiny

end LibcMath.Extracted.Expf.RangeReduction
