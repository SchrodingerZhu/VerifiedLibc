import FloatLib.Floats.Formats.BinaryInterchange.Analysis.MixedError.Attribute
import LibcMath.Correctness
import LibcMath.Extracted.Expf.HornerError
import LibcMath.Extracted.Expf.Paths.Ranges
import LibcMath.Extracted.Expf.RangeReduction
import LibcMath.Extracted.Expf.RoundingTransfer
import LibcMath.Extracted.Expf.TableBounds
import LibcMath.Functions.ExpRanges
import Mathlib.Analysis.Complex.ExponentialBounds

/-!
# Combined value error on the main path of `Expf.DoubleEval.expf`

Combines `RangeReduction`, `TableBounds`, `HornerError`, and `RoundingTransfer` into a single
relative error bound `|v - Real.exp x| ≤ (2 / 10 ^ 15) * Real.exp x` for every main-range input
outside the three isolated exceptions `{0x3B7FFFFF, 0xBB7FFFFF, 0xC236BD8C}` across all four C
rounding modes (`cModes`).

From this error bound and the tiny-argument Horner enclosures, this file immediately proves
`CorrectAt` analytically on three whole subranges inside the main intervals:
* `[0x32800001, 0x33800000)` (`2⁻²⁶ < x < 2⁻²⁴`, `16 777 215` inputs),
* `[0xB2800001, 0xB3000000)` (`-2⁻²⁵ < x < -2⁻²⁶`, `8 388 607` inputs),
* `[0xC2CE8ED0, 0xC2CFF1B5)` (near underflow, `90 853` inputs),

and reduces every remaining input to `RoundingTransfer.GridFor` and `RoundingTransfer.AwayFromGrid`.
-/

namespace LibcMath.Extracted.Expf.ProductError

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Core
open LibcMath.Core.DSL

variable {mode : IEEERoundingMode}

/-! ### Binary64 multiplication and range helpers -/

private theorem unitRoundoffIn_binary64_le (mode : IEEERoundingMode) :
    Model.unitRoundoffIn .binary64 mode ≤ (1 / 2 ^ 52 : ℝ) := by
  rw [Model.unitRoundoffIn, Model.unitRoundoffAt_eq]
  have hhalf : (mode.halfUlps : ℝ) ≤ 2 := by
    cases mode <;> norm_num [Model.IEEERoundingMode.halfUlps]
  have hfrac : (FloatFormat.binary64.fracWidth : ℤ) = 52 := by decide
  rw [hfrac]
  have hpos : (0 : ℝ) ≤ (2 : ℝ) ^ (-(52 + 1 : ℤ)) := by positivity
  calc (mode.halfUlps : ℝ) * (2 : ℝ) ^ (-(52 + 1 : ℤ))
      ≤ 2 * (2 : ℝ) ^ (-(52 + 1 : ℤ)) := mul_le_mul_of_nonneg_right hhalf hpos
    _ = (1 / 2 ^ 52 : ℝ) := by norm_num

private theorem minNormalAt_binary64_le (e : ℤ) (he : -1022 ≤ e) :
    Model.minNormalAt .binary64 ≤ (2 : ℝ) ^ e := by
  change FloatLib.Floats.Formats.Flocq.bpow FloatLib.Numerics.binaryRadix
    (FloatFormat.minNormalExponent .binary64) ≤ (2 : ℝ) ^ e
  simp only [FloatLib.Floats.Formats.Flocq.bpow, FloatLib.Numerics.binaryRadix,
    FloatLib.Numerics.Radix.toReal]
  have hexp : FloatFormat.minNormalExponent .binary64 = -1022 := by decide
  rw [hexp, Nat.cast_ofNat]
  exact zpow_le_zpow_right₀ (by norm_num) he

private theorem pow_150_le_posMaxFinite_binary64 :
    (2 : ℝ) ^ (150 : ℤ) ≤ (Model.posMaxFinite .binary64).toReal := by
  have hrat : Model.toRat? f64(0x4950000000000000#64) = some (2 ^ 150) := by decide +kernel
  have hfin := Model.Algebraic.isFinite_of_toRat?_eq_some hrat
  have hval := Model.Algebraic.toReal_of_toRat?_eq_some hrat
  have hle := Model.abs_toReal_le_posMaxFinite_of_isFinite f64(0x4950000000000000#64) hfin
  rw [hval] at hle
  have hpos : (0 : ℝ) ≤ ((2 ^ 150 : ℚ) : ℝ) := by positivity
  rw [abs_of_nonneg hpos] at hle
  simpa using hle

private theorem toReal_posMaxFinite_binary32 :
    (Model.posMaxFinite .binary32).toReal = ((2 ^ 24 - 1 : ℕ) : ℝ) * (2 : ℝ) ^ (104 : ℤ) := by
  have hrat : Model.toRat? (Model.posMaxFinite .binary32) = some ((2 ^ 24 - 1) * 2 ^ 104) := by
    decide +kernel
  rw [Model.Algebraic.toReal_of_toRat?_eq_some hrat]
  norm_num

private theorem exp_zpow_two (n : ℤ) : Real.exp ((n : ℝ) * Real.log 2) = (2 : ℝ) ^ n := by
  rw [mul_comm, Real.exp_mul, Real.exp_log (by norm_num), Real.rpow_intCast]

private theorem exp_neg_105_gt : (2 : ℝ) ^ (-160 : ℤ) ≤ Real.exp (-105 : ℝ) := by
  have hlog := Real.log_two_gt_d9
  rw [← exp_zpow_two (-160)]
  exact Real.exp_le_exp.mpr (by push_cast; linarith)

private theorem exp_92_lt : Real.exp (92 : ℝ) ≤ (2 : ℝ) ^ (140 : ℤ) := by
  have hlog := Real.log_two_gt_d9
  rw [← exp_zpow_two 140]
  exact Real.exp_le_exp.mpr (by push_cast; linarith)

private theorem exp_0x42B17217_le :
    (1 + (2 / 10 ^ 15 : ℝ)) * Real.exp (11629079 / 2 ^ 17 : ℝ) ≤
      (Model.posMaxFinite .binary32).toReal := by
  have hlog := Real.log_two_gt_d9
  have hdiff : (11629079 / 2 ^ 17 : ℝ) - (128 : ℝ) * Real.log 2 ≤ -(7 / 10 ^ 6 : ℝ) := by
    norm_num at hlog ⊢; linarith
  have hinv : Real.exp (-(7 / 10 ^ 6 : ℝ)) ≤ 1 / (1 + 7 / 10 ^ 6 : ℝ) := by
    rw [Real.exp_neg, inv_eq_one_div]
    exact one_div_le_one_div_of_le (by positivity)
      (by linarith [Real.add_one_le_exp (7 / 10 ^ 6 : ℝ)])
  have hexp : Real.exp (11629079 / 2 ^ 17 : ℝ) ≤
      (2 : ℝ) ^ (128 : ℤ) * (1 / (1 + 7 / 10 ^ 6 : ℝ)) := by
    have hsplit : Real.exp (11629079 / 2 ^ 17 : ℝ) =
        (2 : ℝ) ^ (128 : ℤ) * Real.exp ((11629079 / 2 ^ 17 : ℝ) - (128 : ℝ) * Real.log 2) := by
      rw [← exp_zpow_two 128, ← Real.exp_add]
      congr 1; push_cast; ring
    rw [hsplit]
    exact mul_le_mul_of_nonneg_left ((Real.exp_le_exp.mpr hdiff).trans hinv) (by positivity)
  rw [toReal_posMaxFinite_binary32]
  have hnum : (1 + (2 / 10 ^ 15 : ℝ)) * ((2 : ℝ) ^ (128 : ℤ) * (1 / (1 + 7 / 10 ^ 6 : ℝ))) ≤
      ((2 ^ 24 - 1 : ℕ) : ℝ) * (2 : ℝ) ^ (104 : ℤ) := by
    norm_num
  exact (mul_le_mul_of_nonneg_left hexp (by norm_num)).trans hnum

/-! ### Exact multiplication by `1.0` when `x.toReal > 0` -/

private theorem fmul_one_left_of_pos (mode : IEEERoundingMode) {x : Model .binary64}
    (hfin : x.isFinite = true) (hpos : 0 < x.toReal) :
    Core.fmul mode (Model.posOne .binary64) x = x := by
  have h1 : Model.toRat? (Model.posOne .binary64) = some 1 := by decide +kernel
  have h1fin := Model.Algebraic.isFinite_of_toRat?_eq_some h1
  have h1val : (Model.posOne .binary64).toReal = 1 := by
    rw [Model.Algebraic.toReal_of_toRat?_eq_some h1]; norm_num
  have hbound : |(Model.posOne .binary64).toReal * x.toReal| ≤
      (Model.posMaxFinite .binary64).toReal := by
    rw [h1val, one_mul]
    exact Model.abs_toReal_le_posMaxFinite_of_isFinite x hfin
  have ⟨hmfin, hmval⟩ := Model.mul_finite_roundAt (mode := mode) rfl h1fin hfin hbound
  rw [h1val, one_mul, Model.roundAt_of_genericFormat .binary64
    (Model.toReal_genericFormat_of_isFinite x hfin) mode] at hmval
  exact Model.eq_of_toReal_eq hmfin hfin hmval (fun h0 => by
    change (Model.mul (Model.posOne .binary64) x mode).toReal = 0 at h0
    linarith)

/-! ### Relative error propagation through the two binary64 multiplications -/

private theorem mul_rel_bounds {a b e1 e2 d1 d2 : ℝ}
    (ha_lo : (1 - d1) * e1 ≤ a) (ha_hi : a ≤ (1 + d1) * e1)
    (hb_lo : (1 - d2) * e2 ≤ b) (hb_hi : b ≤ (1 + d2) * e2)
    (he1 : 0 ≤ e1) (he2 : 0 ≤ e2) (hd1 : 0 ≤ d1) (hd2' : d2 ≤ 1)
    (ha0 : 0 ≤ a) (hb0 : 0 ≤ b) :
    ((1 - d1) * (1 - d2)) * (e1 * e2) ≤ a * b ∧
    a * b ≤ ((1 + d1) * (1 + d2)) * (e1 * e2) := by
  constructor
  · calc ((1 - d1) * (1 - d2)) * (e1 * e2)
        = ((1 - d1) * e1) * ((1 - d2) * e2) := by ring
      _ ≤ a * b := mul_le_mul ha_lo hb_lo (mul_nonneg (by linarith) he2) ha0
  · calc a * b
        ≤ ((1 + d1) * e1) * ((1 + d2) * e2) :=
          mul_le_mul ha_hi hb_hi hb0 (mul_nonneg (by linarith) he1)
      _ = ((1 + d1) * (1 + d2)) * (e1 * e2) := by ring

private theorem round_rel_bounds {v p e u c_lo c_hi : ℝ}
    (hp_lo : c_lo * e ≤ p) (hp_hi : p ≤ c_hi * e)
    (herr : |v - p| ≤ u * p) (hu0 : 0 ≤ u) (hu : u ≤ 1) :
    ((1 - u) * c_lo) * e ≤ v ∧ v ≤ ((1 + u) * c_hi) * e := by
  have h1 := (abs_le.mp herr).1
  have h2 := (abs_le.mp herr).2
  have hv_lo : (1 - u) * p ≤ v := by linarith
  have hv_hi : v ≤ (1 + u) * p := by linarith
  constructor
  · calc ((1 - u) * c_lo) * e
        = (1 - u) * (c_lo * e) := by ring
      _ ≤ (1 - u) * p := mul_le_mul_of_nonneg_left hp_lo (by linarith)
      _ ≤ v := hv_lo
  · calc v
        ≤ (1 + u) * p := hv_hi
      _ ≤ (1 + u) * (c_hi * e) := mul_le_mul_of_nonneg_left hp_hi (by linarith)
      _ = ((1 + u) * c_hi) * e := by ring

/-- Given a `MainReduction`, the final binary64 product `v = (exp_hi * exp_mid) * exp_lo` is
finite, positive, and within `(2 / 10 ^ 15) * Real.exp f32(b).toReal` of `Real.exp f32(b).toReal`.
-/
theorem product_value_error (hmode : mode ∈ cModes) {b : BitVec 32}
    (red : RangeReduction.MainReduction mode b)
    (hx_hi : f32(b).toReal ≤ (11629079 / 2 ^ 17 : ℝ)) :
    let exp_hi := Expf.DoubleEval.EXP_M1[red.hiIdx]'red.hi_lt
    let exp_mid := Expf.DoubleEval.EXP_M2[red.midIdx]'red.mid_lt
    let exp_lo := HornerError.hornerExpLo mode red.xd
    let v := Core.fmul mode (Core.fmul mode exp_hi exp_mid) exp_lo
    v.isFinite = true ∧
    0 < v.toReal ∧
    v.toReal ≤ (Model.posMaxFinite .binary32).toReal ∧
    |v.toReal - Real.exp f32(b).toReal| ≤ (2 / 10 ^ 15 : ℝ) * Real.exp f32(b).toReal := by
  intro exp_hi exp_mid exp_lo v
  have hhi_lt : red.hiIdx < 195 := by simpa [TableBounds.expM1_size] using red.hi_lt
  have hmid_lt : red.midIdx < 128 := by simpa [TableBounds.expM2_size] using red.mid_lt
  have ⟨h1fin, h1pos, h1err⟩ := TableBounds.expM1_bounds red.hiIdx hhi_lt
  have ⟨h2fin, h2pos, h2err⟩ := TableBounds.expM2_bounds red.midIdx hmid_lt
  have ⟨h3fin, h3err⟩ :=
    HornerError.hornerExpLo_finite_and_error hmode red.xd_finite red.xd_abs_le
  set e1 := Real.exp ((red.hiIdx : ℤ) - 104 : ℝ)
  set e2 := Real.exp ((red.midIdx : ℝ) / 128)
  set e3 := Real.exp red.xd.toReal
  set δt : ℝ := 1 / 2 ^ 53
  set δu : ℝ := 1 / 2 ^ 52
  set δp : ℝ := 126 / 10 ^ 17
  have he1_pos : 0 < e1 := Real.exp_pos _
  have he2_pos : 0 < e2 := Real.exp_pos _
  have he3_pos : 0 < e3 := Real.exp_pos _
  have hexp_eq : e1 * e2 * e3 = Real.exp f32(b).toReal := by
    rw [← Real.exp_add, ← Real.exp_add, red.decomp]
  -- Relative bounds on `exp_hi`, `exp_mid`, `exp_lo`
  have h1_lo : (1 - δt) * e1 ≤ exp_hi.toReal := by have := (abs_le.mp h1err).1; linarith
  have h1_hi : exp_hi.toReal ≤ (1 + δt) * e1 := by have := (abs_le.mp h1err).2; linarith
  have h2_lo : (1 - δt) * e2 ≤ exp_mid.toReal := by have := (abs_le.mp h2err).1; linarith
  have h2_hi : exp_mid.toReal ≤ (1 + δt) * e2 := by have := (abs_le.mp h2err).2; linarith
  have h3_lo : (1 - δp) * e3 ≤ exp_lo.toReal := by have := (abs_le.mp h3err).1; linarith
  have h3_hi : exp_lo.toReal ≤ (1 + δp) * e3 := by have := (abs_le.mp h3err).2; linarith
  have h3pos : 0 < exp_lo.toReal := by
    have hδp : 0 < 1 - δp := by norm_num [δp]
    exact lt_of_lt_of_le (mul_pos hδp he3_pos) h3_lo
  -- Magnitude bounds for `e1 * e2`
  have he12_lo : (2 : ℝ) ^ (-160 : ℤ) ≤ e1 * e2 := by
    rw [← Real.exp_add]
    refine exp_neg_105_gt.trans (Real.exp_le_exp.mpr ?_)
    have hhi0 : (-104 : ℝ) ≤ ((red.hiIdx : ℤ) - 104 : ℝ) := by
      exact_mod_cast (by omega : (-104 : ℤ) ≤ (red.hiIdx : ℤ) - 104)
    have hmid0 : (0 : ℝ) ≤ (red.midIdx : ℝ) / 128 := by positivity
    linarith
  have he12_hi : e1 * e2 ≤ (2 : ℝ) ^ (140 : ℤ) := by
    rw [← Real.exp_add]
    refine (Real.exp_le_exp.mpr ?_).trans exp_92_lt
    have hhi_le : ((red.hiIdx : ℤ) - 104 : ℝ) ≤ 90 := by
      exact_mod_cast (by omega : (red.hiIdx : ℤ) - 104 ≤ 90)
    have hmid_le : (red.midIdx : ℝ) / 128 ≤ 1 := by
      have : (red.midIdx : ℝ) ≤ 128 := by exact_mod_cast (by omega : red.midIdx ≤ 128)
      linarith
    linarith
  -- Step 1: `p1 := Core.fmul mode exp_hi exp_mid`
  set p1 := Core.fmul mode exp_hi exp_mid
  have hp1_prod_pos : 0 < exp_hi.toReal * exp_mid.toReal := mul_pos h1pos h2pos
  have ⟨hp1_prod_lo, hp1_prod_hi⟩ := mul_rel_bounds h1_lo h1_hi h2_lo h2_hi he1_pos.le he2_pos.le
    (by norm_num [δt]) (by norm_num [δt]) h1pos.le h2pos.le
  have hp1_bound : |exp_hi.toReal * exp_mid.toReal| ≤ (Model.posMaxFinite .binary64).toReal := by
    rw [abs_of_pos hp1_prod_pos]
    have hc : (1 + δt) * (1 + δt) ≤ (2 : ℝ) ^ (10 : ℤ) := by norm_num [δt]
    calc exp_hi.toReal * exp_mid.toReal
        ≤ ((1 + δt) * (1 + δt)) * (e1 * e2) := hp1_prod_hi
      _ ≤ (2 : ℝ) ^ (10 : ℤ) * (2 : ℝ) ^ (140 : ℤ) :=
          mul_le_mul hc he12_hi (mul_pos he1_pos he2_pos).le (by positivity)
      _ = (2 : ℝ) ^ (150 : ℤ) := by rw [← zpow_add₀ (by norm_num)]; congr 1
      _ ≤ (Model.posMaxFinite .binary64).toReal := pow_150_le_posMaxFinite_binary64
  have ⟨hp1_fin, hp1_round⟩ :=
    Model.mul_finite_roundAt (mode := mode) rfl h1fin h2fin hp1_bound
  have hp1_normal : Model.minNormalAt .binary64 ≤ |exp_hi.toReal * exp_mid.toReal| := by
    rw [abs_of_pos hp1_prod_pos]
    have hc : (1 / 2 : ℝ) ≤ (1 - δt) * (1 - δt) := by norm_num [δt]
    calc Model.minNormalAt .binary64
        ≤ (2 : ℝ) ^ (-161 : ℤ) := minNormalAt_binary64_le (-161) (by omega)
      _ = (1 / 2 : ℝ) * (2 : ℝ) ^ (-160 : ℤ) := by
          have h1 : (1 / 2 : ℝ) = (2 : ℝ) ^ (-1 : ℤ) := by norm_num
          rw [h1, ← zpow_add₀ (by norm_num)]; congr 1
      _ ≤ ((1 - δt) * (1 - δt)) * (e1 * e2) :=
          mul_le_mul hc he12_lo (by positivity) (by norm_num [δt])
      _ ≤ exp_hi.toReal * exp_mid.toReal := hp1_prod_lo
  have hp1_err : |p1.toReal - exp_hi.toReal * exp_mid.toReal| ≤
      δu * (exp_hi.toReal * exp_mid.toReal) := by
    have h := Model.abs_roundAt_sub_le_mode_of_normal .binary64 hp1_normal mode
    rw [← hp1_round, abs_of_pos hp1_prod_pos] at h
    exact h.trans (mul_le_mul_of_nonneg_right (unitRoundoffIn_binary64_le mode) hp1_prod_pos.le)
  have ⟨hp1_lo, hp1_hi⟩ :=
    round_rel_bounds hp1_prod_lo hp1_prod_hi hp1_err (by norm_num [δu]) (by norm_num [δu])
  have hp1_pos : 0 < p1.toReal := by
    have hc : 0 < (1 - δu) * ((1 - δt) * (1 - δt)) := by norm_num [δu, δt]
    exact lt_of_lt_of_le (mul_pos hc (mul_pos he1_pos he2_pos)) hp1_lo
  -- Step 2: `v := Core.fmul mode p1 exp_lo`
  have hv_prod_pos : 0 < p1.toReal * exp_lo.toReal := mul_pos hp1_pos h3pos
  have hv_prod_lo :
      (((1 - δu) * ((1 - δt) * (1 - δt))) * (1 - δp)) * (e1 * e2 * e3) ≤
        p1.toReal * exp_lo.toReal := by
    calc (((1 - δu) * ((1 - δt) * (1 - δt))) * (1 - δp)) * (e1 * e2 * e3)
        = (((1 - δu) * ((1 - δt) * (1 - δt))) * (e1 * e2)) * ((1 - δp) * e3) := by ring
      _ ≤ p1.toReal * exp_lo.toReal :=
          mul_le_mul hp1_lo h3_lo (mul_nonneg (by norm_num [δp]) he3_pos.le) hp1_pos.le
  have hv_prod_hi :
      p1.toReal * exp_lo.toReal ≤
        (((1 + δu) * ((1 + δt) * (1 + δt))) * (1 + δp)) * (e1 * e2 * e3) := by
    calc p1.toReal * exp_lo.toReal
        ≤ (((1 + δu) * ((1 + δt) * (1 + δt))) * (e1 * e2)) * ((1 + δp) * e3) :=
          mul_le_mul hp1_hi h3_hi h3pos.le
            (mul_nonneg (by norm_num [δu, δt]) (mul_pos he1_pos he2_pos).le)
      _ = (((1 + δu) * ((1 + δt) * (1 + δt))) * (1 + δp)) * (e1 * e2 * e3) := by ring
  have he3_lo : (1 / 2 : ℝ) ≤ e3 := by
    have hxd_lo : -(1 / 256 : ℝ) ≤ red.xd.toReal := (abs_le.mp red.xd_abs_le).1
    have hlin := Real.add_one_le_exp red.xd.toReal
    linarith
  have he3_hi : e3 ≤ 2 := by
    have hxd_hi : red.xd.toReal ≤ (1 / 256 : ℝ) := (abs_le.mp red.xd_abs_le).2
    have h := Real.exp_le_exp.mpr hxd_hi
    have hinv : Real.exp (1 / 256 : ℝ) ≤ 2 := by
      have hsub : (1 / 2 : ℝ) ≤ Real.exp (-(1 / 256 : ℝ)) := by
        have := Real.add_one_le_exp (-(1 / 256 : ℝ)); linarith
      have hmul : Real.exp (1 / 256 : ℝ) * Real.exp (-(1 / 256 : ℝ)) = 1 := by
        rw [← Real.exp_add]; simp
      have h1 : Real.exp (1 / 256 : ℝ) * (1 / 2 : ℝ) ≤ 1 := by
        calc Real.exp (1 / 256 : ℝ) * (1 / 2 : ℝ)
            ≤ Real.exp (1 / 256 : ℝ) * Real.exp (-(1 / 256 : ℝ)) :=
              mul_le_mul_of_nonneg_left hsub (Real.exp_pos _).le
          _ = 1 := hmul
      linarith
    linarith
  have hv_bound : |p1.toReal * exp_lo.toReal| ≤ (Model.posMaxFinite .binary64).toReal := by
    rw [abs_of_pos hv_prod_pos]
    have hc : ((1 + δu) * ((1 + δt) * (1 + δt))) * (1 + δp) ≤ (2 : ℝ) ^ (9 : ℤ) := by
      norm_num [δu, δt, δp]
    have he123_hi : e1 * e2 * e3 ≤ (2 : ℝ) ^ (141 : ℤ) := by
      calc e1 * e2 * e3
          ≤ (2 : ℝ) ^ (140 : ℤ) * 2 := mul_le_mul he12_hi he3_hi he3_pos.le (by positivity)
        _ = (2 : ℝ) ^ (141 : ℤ) := by rw [← zpow_add_one₀ (by norm_num)]; congr 1
    calc p1.toReal * exp_lo.toReal
        ≤ (((1 + δu) * ((1 + δt) * (1 + δt))) * (1 + δp)) * (e1 * e2 * e3) := hv_prod_hi
      _ ≤ (2 : ℝ) ^ (9 : ℤ) * (2 : ℝ) ^ (141 : ℤ) :=
          mul_le_mul hc he123_hi (mul_pos (mul_pos he1_pos he2_pos) he3_pos).le (by positivity)
      _ = (2 : ℝ) ^ (150 : ℤ) := by rw [← zpow_add₀ (by norm_num)]; congr 1
      _ ≤ (Model.posMaxFinite .binary64).toReal := pow_150_le_posMaxFinite_binary64
  have ⟨hv_fin, hv_round⟩ :=
    Model.mul_finite_roundAt (mode := mode) rfl hp1_fin h3fin hv_bound
  have hv_normal : Model.minNormalAt .binary64 ≤ |p1.toReal * exp_lo.toReal| := by
    rw [abs_of_pos hv_prod_pos]
    have hc : (1 / 2 : ℝ) ≤ ((1 - δu) * ((1 - δt) * (1 - δt))) * (1 - δp) := by
      norm_num [δu, δt, δp]
    have he123_lo : (2 : ℝ) ^ (-161 : ℤ) ≤ e1 * e2 * e3 := by
      calc (2 : ℝ) ^ (-161 : ℤ)
          = (2 : ℝ) ^ (-160 : ℤ) * (1 / 2) := by
            have h1 : (1 / 2 : ℝ) = (2 : ℝ) ^ (-1 : ℤ) := by norm_num
            rw [h1, ← zpow_add₀ (by norm_num)]; congr 1
        _ ≤ e1 * e2 * e3 := mul_le_mul he12_lo he3_lo (by norm_num) (mul_pos he1_pos he2_pos).le
    calc Model.minNormalAt .binary64
        ≤ (2 : ℝ) ^ (-162 : ℤ) := minNormalAt_binary64_le (-162) (by omega)
      _ = (1 / 2 : ℝ) * (2 : ℝ) ^ (-161 : ℤ) := by
          have h1 : (1 / 2 : ℝ) = (2 : ℝ) ^ (-1 : ℤ) := by norm_num
          rw [h1, ← zpow_add₀ (by norm_num)]; congr 1
      _ ≤ (((1 - δu) * ((1 - δt) * (1 - δt))) * (1 - δp)) * (e1 * e2 * e3) :=
          mul_le_mul hc he123_lo (by positivity) (by norm_num [δu, δt, δp])
      _ ≤ p1.toReal * exp_lo.toReal := hv_prod_lo
  have hv_err_mul : |v.toReal - p1.toReal * exp_lo.toReal| ≤
      δu * (p1.toReal * exp_lo.toReal) := by
    have h := Model.abs_roundAt_sub_le_mode_of_normal .binary64 hv_normal mode
    change |Model.roundAt .binary64 (p1.toReal * exp_lo.toReal) mode -
      p1.toReal * exp_lo.toReal| ≤ _ at h
    have hv_round' : v.toReal = Model.roundAt .binary64 (p1.toReal * exp_lo.toReal) mode :=
      hv_round
    rw [← hv_round', abs_of_pos hv_prod_pos] at h
    exact h.trans (mul_le_mul_of_nonneg_right (unitRoundoffIn_binary64_le mode) hv_prod_pos.le)
  have ⟨hv_lo_raw, hv_hi_raw⟩ :=
    round_rel_bounds hv_prod_lo hv_prod_hi hv_err_mul (by norm_num [δu]) (by norm_num [δu])
  rw [hexp_eq] at hv_lo_raw hv_hi_raw
  have hexp_pos : 0 < Real.exp f32(b).toReal := Real.exp_pos _
  have hcoef_lo : (1 - 2 / 10 ^ 15 : ℝ) ≤
      (1 - δu) * (((1 - δu) * ((1 - δt) * (1 - δt))) * (1 - δp)) := by
    norm_num [δu, δt, δp]
  have hcoef_hi :
      (1 + δu) * (((1 + δu) * ((1 + δt) * (1 + δt))) * (1 + δp)) ≤
      (1 + 2 / 10 ^ 15 : ℝ) := by
    norm_num [δu, δt, δp]
  have hv_lo : (1 - 2 / 10 ^ 15 : ℝ) * Real.exp f32(b).toReal ≤ v.toReal :=
    (mul_le_mul_of_nonneg_right hcoef_lo hexp_pos.le).trans hv_lo_raw
  have hv_hi : v.toReal ≤ (1 + 2 / 10 ^ 15 : ℝ) * Real.exp f32(b).toReal :=
    hv_hi_raw.trans (mul_le_mul_of_nonneg_right hcoef_hi hexp_pos.le)
  have hv_pos : 0 < v.toReal :=
    lt_of_lt_of_le (mul_pos (by norm_num) hexp_pos) hv_lo
  have hv_max : v.toReal ≤ (Model.posMaxFinite .binary32).toReal := by
    calc v.toReal
        ≤ (1 + 2 / 10 ^ 15 : ℝ) * Real.exp f32(b).toReal := hv_hi
      _ ≤ (1 + 2 / 10 ^ 15 : ℝ) * Real.exp (11629079 / 2 ^ 17 : ℝ) :=
          mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr hx_hi) (by norm_num)
      _ ≤ (Model.posMaxFinite .binary32).toReal := exp_0x42B17217_le
  refine ⟨hv_fin, hv_pos, hv_max, abs_le.mpr ⟨by linarith, by linarith⟩⟩

/-! ### Master error-bound theorems for positive and negative main ranges -/

private theorem toReal_le_0x42B17217 {b : BitVec 32} (hhi : b.toNat < 0x42B17218) :
    f32(b).toReal ≤ (11629079 / 2 ^ 17 : ℝ) := by
  have hbits : f32(b).toNatBits ≤ 0x42B17217 := by change b.toNat ≤ 0x42B17217; omega
  have hle := (Binary32.toReal_le_ofNatBits_iff_of_nonneg (x := f32(b))
    (by norm_num) (by change b.toNat ≤ 0x7F7FFFFF; omega)).mpr hbits
  have hrat : Model.toRat? (Model.ofNatBits (fmt := .binary32) 0x42B17217) =
      some (11629079 / 2 ^ 17) := by decide +kernel
  rw [Model.Algebraic.toReal_of_toRat?_eq_some hrat] at hle
  simpa using hle

private theorem toReal_neg_le_0x42B17217 {b : BitVec 32}
    (hlo : 0xB2800001 ≤ b.toNat) (hhi : b.toNat < 0xC2CFF1B5) :
    f32(b).toReal ≤ (11629079 / 2 ^ 17 : ℝ) := by
  have hle := (Binary32.toReal_le_ofNatBits_iff_of_nonpos (x := f32(b))
    (by norm_num) (by change 0x80000000 ≤ b.toNat ∧ b.toNat ≤ 0xFF7FFFFF; omega)).mpr
      (show 0x80000000 ≤ f32(b).toNatBits by change 0x80000000 ≤ b.toNat; omega)
  have h0 : Model.toRat? (Model.ofNatBits (fmt := .binary32) 0x80000000) = some 0 := by
    decide +kernel
  rw [Model.Algebraic.toReal_of_toRat?_eq_some h0] at hle
  norm_num at hle ⊢
  linarith

/-- On `[0x32800001, 0x42B17218) \ {0x3B7FFFFF}`, `Expf.DoubleEval.expf` returns
`some (roundReal .binary32 mode v)` for a real `v` within `(2 / 10 ^ 15) * Real.exp x` of
`Real.exp x`. -/
theorem doubleEval_main_error_pos (hmode : mode ∈ cModes) (b : BitVec 32)
    (hlo : 0x32800001 ≤ b.toNat) (hhi : b.toNat < 0x42B17218) (hne : b.toNat ≠ 0x3B7FFFFF) :
    ∃ v : ℝ,
      Expf.DoubleEval.expf mode f32(b) = some (Model.roundReal .binary32 mode v) ∧
      |v - Real.exp f32(b).toReal| ≤ (2 / 10 ^ 15 : ℝ) * Real.exp f32(b).toReal := by
  let red := RangeReduction.mainReduction_of_pos hmode b hlo hhi hne
  have ⟨hv_fin, hv_pos, hv_max, hv_err⟩ :=
    product_value_error hmode red (toReal_le_0x42B17217 hhi)
  refine ⟨_, ?_, hv_err⟩
  have hcast := RoundingTransfer.fpCast_binary32_eq_roundReal hmode hv_fin hv_pos hv_max
  exact red.expf_eq.trans (congrArg some hcast)

/-- On `[0xB2800001, 0xC2CFF1B5) \ {0xC236BD8C, 0xBB7FFFFF}`, `Expf.DoubleEval.expf` returns
`some (roundReal .binary32 mode v)` for a real `v` within `(2 / 10 ^ 15) * Real.exp x` of
`Real.exp x`. -/
theorem doubleEval_main_error_neg (hmode : mode ∈ cModes) (b : BitVec 32)
    (hlo : 0xB2800001 ≤ b.toNat) (hhi : b.toNat < 0xC2CFF1B5)
    (hne1 : b.toNat ≠ 0xC236BD8C) (hne2 : b.toNat ≠ 0xBB7FFFFF) :
    ∃ v : ℝ,
      Expf.DoubleEval.expf mode f32(b) = some (Model.roundReal .binary32 mode v) ∧
      |v - Real.exp f32(b).toReal| ≤ (2 / 10 ^ 15 : ℝ) * Real.exp f32(b).toReal := by
  let red := RangeReduction.mainReduction_of_neg hmode b hlo hhi hne1 hne2
  have ⟨hv_fin, hv_pos, hv_max, hv_err⟩ :=
    product_value_error hmode red (toReal_neg_le_0x42B17217 hlo hhi)
  refine ⟨_, ?_, hv_err⟩
  have hcast := RoundingTransfer.fpCast_binary32_eq_roundReal hmode hv_fin hv_pos hv_max
  exact red.expf_eq.trans (congrArg some hcast)

/-- Reduction of `CorrectAt` on positive main-range inputs to `GridFor` and `AwayFromGrid`. -/
theorem correctAt_of_awayFromGrid_pos (hmode : mode ∈ cModes) (b : BitVec 32)
    (hlo : 0x32800001 ≤ b.toNat) (hhi : b.toNat < 0x42B17218) (hne : b.toNat ≠ 0x3B7FFFFF)
    {u : ℝ} (hgrid : RoundingTransfer.GridFor (Real.exp f32(b).toReal) u)
    (haway : RoundingTransfer.AwayFromGrid u (2 / 10 ^ 15) (Real.exp f32(b).toReal)) :
    CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode f32(b) := by
  obtain ⟨v, hv_eq, hv_err⟩ := doubleEval_main_error_pos hmode b hlo hhi hne
  obtain ⟨hnan, hinf, hzero⟩ := Binary32.classify_of_toNatBits_mem (x := f32(b))
    (first := 0x32800001) (last := 0x42B17217)
    (.inl ⟨by norm_num, by norm_num⟩) ⟨by change 0x32800001 ≤ b.toNat; omega,
      by change b.toNat ≤ 0x42B17217; omega⟩
  refine .of_eq_some hv_eq (.inl ?_)
  rw [ExpRanges.eval_eq_roundReal hnan hinf hzero]
  exact RoundingTransfer.roundReal_eq_of_awayFromGrid hmode (Real.exp_pos _) (by norm_num)
    (by norm_num) hv_err hgrid haway

/-- Reduction of `CorrectAt` on negative main-range inputs to `GridFor` and `AwayFromGrid`. -/
theorem correctAt_of_awayFromGrid_neg (hmode : mode ∈ cModes) (b : BitVec 32)
    (hlo : 0xB2800001 ≤ b.toNat) (hhi : b.toNat < 0xC2CFF1B5)
    (hne1 : b.toNat ≠ 0xC236BD8C) (hne2 : b.toNat ≠ 0xBB7FFFFF)
    {u : ℝ} (hgrid : RoundingTransfer.GridFor (Real.exp f32(b).toReal) u)
    (haway : RoundingTransfer.AwayFromGrid u (2 / 10 ^ 15) (Real.exp f32(b).toReal)) :
    CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode f32(b) := by
  obtain ⟨v, hv_eq, hv_err⟩ := doubleEval_main_error_neg hmode b hlo hhi hne1 hne2
  obtain ⟨hnan, hinf, hzero⟩ := Binary32.classify_of_toNatBits_mem (x := f32(b))
    (first := 0xB2800001) (last := 0xC2CFF1B4)
    (.inr ⟨by norm_num, by norm_num⟩) ⟨by change 0xB2800001 ≤ b.toNat; omega,
      by change b.toNat ≤ 0xC2CFF1B4; omega⟩
  refine .of_eq_some hv_eq (.inl ?_)
  rw [ExpRanges.eval_eq_roundReal hnan hinf hzero]
  exact RoundingTransfer.roundReal_eq_of_awayFromGrid hmode (Real.exp_pos _) (by norm_num)
    (by norm_num) hv_err hgrid haway

/-! ### Analytic closure of tiny-argument and near-underflow subranges -/

private theorem two_le_posMaxFinite_binary32 :
    (2 : ℝ) ≤ (Model.posMaxFinite .binary32).toReal := by
  rw [toReal_posMaxFinite_binary32]
  norm_num

/-- `[0x32800001, 0x33800000)` (`2⁻²⁶ < x < 2⁻²⁴`): `16 777 215` inputs closed analytically. -/
theorem holdsOnBits_tiny_pos_main (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0x32800001 0x33800000 :=
  Expf.Paths.holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    obtain ⟨red, hhiIdx, hmidIdx, hxd_eq⟩ :=
      RangeReduction.mainReduction_of_tiny hmode b (.inl ⟨hlo, hhi⟩)
    have hlo_r : (1 / 2 ^ 26 : ℝ) ≤ red.xd.toReal := by
      rw [hxd_eq]
      have h := (Binary32.toReal_ofNatBits_le_iff_of_nonneg (x := f32(b))
        (by norm_num) (by change b.toNat ≤ 0x7F7FFFFF; omega)).mpr
          (show 0x32800000 ≤ f32(b).toNatBits by change 0x32800000 ≤ b.toNat; omega)
      have hrat : Model.toRat? (Model.ofNatBits (fmt := .binary32) 0x32800000) =
          some (1 / 2 ^ 26) := by decide +kernel
      rw [Model.Algebraic.toReal_of_toRat?_eq_some hrat] at h
      simpa using h
    have hhi_r : red.xd.toReal ≤ (1 / 2 ^ 24 - 1 / 2 ^ 48 : ℝ) := by
      rw [hxd_eq]
      have h := (Binary32.toReal_le_ofNatBits_iff_of_nonneg (x := f32(b))
        (by norm_num) (by change b.toNat ≤ 0x7F7FFFFF; omega)).mpr
          (show f32(b).toNatBits ≤ 0x337FFFFF by change b.toNat ≤ 0x337FFFFF; omega)
      have hrat : Model.toRat? (Model.ofNatBits (fmt := .binary32) 0x337FFFFF) =
          some (1 / 2 ^ 24 - 1 / 2 ^ 48) := by decide +kernel
      rw [Model.Algebraic.toReal_of_toRat?_eq_some hrat] at h
      simpa using h
    have ⟨hlofin, hlo1, hlo2⟩ := HornerError.hornerExpLo_tiny_pos hmode red.xd_finite hlo_r hhi_r
    have hexp_hi_eq : Expf.DoubleEval.EXP_M1[red.hiIdx]'red.hi_lt = Model.posOne .binary64 := by
      simpa [hhiIdx] using TableBounds.expM1_104
    have hexp_mid_eq : Expf.DoubleEval.EXP_M2[red.midIdx]'red.mid_lt = Model.posOne .binary64 := by
      simpa [hmidIdx] using TableBounds.expM2_0
    have h1mul1 : Core.fmul mode (Model.posOne .binary64) (Model.posOne .binary64) =
        Model.posOne .binary64 := by
      rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel
    have hv_eq : Expf.DoubleEval.expf mode f32(b) =
        some (Model.roundReal .binary32 mode (HornerError.hornerExpLo mode red.xd).toReal) := by
      have heq := red.expf_eq
      change Expf.DoubleEval.expf mode f32(b) = some (Core.fpCast .binary32 mode
        (Core.fmul mode (Core.fmul mode (Expf.DoubleEval.EXP_M1[red.hiIdx]'red.hi_lt)
          (Expf.DoubleEval.EXP_M2[red.midIdx]'red.mid_lt))
          (HornerError.hornerExpLo mode red.xd))) at heq
      rw [hexp_hi_eq, hexp_mid_eq, h1mul1,
        fmul_one_left_of_pos mode hlofin (by linarith),
        RoundingTransfer.fpCast_binary32_eq_roundReal hmode hlofin (by linarith)
          (by linarith [two_le_posMaxFinite_binary32])] at heq
      exact heq
    refine .of_eq_some hv_eq (.inl ?_)
    rw [ExpRanges.eval_of_tiny_pos_bits (x := f32(b)) hmode
      ⟨by change 0x00000001 ≤ b.toNat; omega, by change b.toNat ≤ 0x337FFFFF; omega⟩]
    rcases hmode with rfl | rfl | rfl | rfl <;>
      exact LibcMath.roundReal_eq_of_mem_Icc_rat rfl _ (lo := 1 + 1 / 2 ^ 149)
        (hi := 1 + 1 / 2 ^ 24) (by norm_num) (by push_cast; exact hlo1) (by push_cast; exact hlo2)
        (by decide +kernel) (by decide +kernel)

/-- `[0xB2800001, 0xB3000000)` (`-2⁻²⁵ < x < -2⁻²⁶`): `8 388 607` inputs closed analytically. -/
theorem holdsOnBits_tiny_neg_main (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0xB2800001 0xB3000000 :=
  Expf.Paths.holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    obtain ⟨red, hhiIdx, hmidIdx, hxd_eq⟩ :=
      RangeReduction.mainReduction_of_tiny hmode b (.inr ⟨hlo, hhi⟩)
    have hlo_r : (-(1 / 2 ^ 25) + 1 / 2 ^ 49 : ℝ) ≤ red.xd.toReal := by
      rw [hxd_eq]
      have h := (Binary32.toReal_ofNatBits_le_iff_of_nonpos (x := f32(b))
        (by norm_num) (by change 0x80000000 ≤ b.toNat ∧ b.toNat ≤ 0xFF7FFFFF; omega)).mpr
          (show f32(b).toNatBits ≤ 0xB2FFFFFF by change b.toNat ≤ 0xB2FFFFFF; omega)
      have hrat : Model.toRat? (Model.ofNatBits (fmt := .binary32) 0xB2FFFFFF) =
          some (-(1 / 2 ^ 25) + 1 / 2 ^ 49) := by decide +kernel
      rw [Model.Algebraic.toReal_of_toRat?_eq_some hrat] at h
      simpa using h
    have hhi_r : red.xd.toReal ≤ -(1 / 2 ^ 26 : ℝ) := by
      rw [hxd_eq]
      have h := (Binary32.toReal_le_ofNatBits_iff_of_nonpos (x := f32(b))
        (by norm_num) (by change 0x80000000 ≤ b.toNat ∧ b.toNat ≤ 0xFF7FFFFF; omega)).mpr
          (show 0xB2800000 ≤ f32(b).toNatBits by change 0xB2800000 ≤ b.toNat; omega)
      have hrat : Model.toRat? (Model.ofNatBits (fmt := .binary32) 0xB2800000) =
          some (-(1 / 2 ^ 26)) := by decide +kernel
      rw [Model.Algebraic.toReal_of_toRat?_eq_some hrat] at h
      simpa using h
    have ⟨hlofin, hlo1, hlo2⟩ := HornerError.hornerExpLo_tiny_neg hmode red.xd_finite hlo_r hhi_r
    have hexp_hi_eq : Expf.DoubleEval.EXP_M1[red.hiIdx]'red.hi_lt = Model.posOne .binary64 := by
      simpa [hhiIdx] using TableBounds.expM1_104
    have hexp_mid_eq : Expf.DoubleEval.EXP_M2[red.midIdx]'red.mid_lt = Model.posOne .binary64 := by
      simpa [hmidIdx] using TableBounds.expM2_0
    have h1mul1 : Core.fmul mode (Model.posOne .binary64) (Model.posOne .binary64) =
        Model.posOne .binary64 := by
      rcases hmode with rfl | rfl | rfl | rfl <;> decide +kernel
    have hv_eq : Expf.DoubleEval.expf mode f32(b) =
        some (Model.roundReal .binary32 mode (HornerError.hornerExpLo mode red.xd).toReal) := by
      have heq := red.expf_eq
      change Expf.DoubleEval.expf mode f32(b) = some (Core.fpCast .binary32 mode
        (Core.fmul mode (Core.fmul mode (Expf.DoubleEval.EXP_M1[red.hiIdx]'red.hi_lt)
          (Expf.DoubleEval.EXP_M2[red.midIdx]'red.mid_lt))
          (HornerError.hornerExpLo mode red.xd))) at heq
      rw [hexp_hi_eq, hexp_mid_eq, h1mul1,
        fmul_one_left_of_pos mode hlofin (by linarith),
        RoundingTransfer.fpCast_binary32_eq_roundReal hmode hlofin (by linarith)
          (by linarith [two_le_posMaxFinite_binary32])] at heq
      exact heq
    refine .of_eq_some hv_eq (.inl ?_)
    rw [ExpRanges.eval_of_tiny_neg_bits (x := f32(b)) hmode
      ⟨by change 0x80000001 ≤ b.toNat; omega, by change b.toNat ≤ 0xB3000000; omega⟩]
    rcases hmode with rfl | rfl | rfl | rfl <;>
      exact LibcMath.roundReal_eq_of_mem_Icc_rat rfl _ (lo := 1 - 1 / 2 ^ 25)
        (hi := 1 / (1 + 1 / 2 ^ 149)) (by norm_num) (by push_cast; exact hlo1)
        (by push_cast; exact hlo2) (by decide +kernel) (by decide +kernel)

/-- `[0xC2CE8ED0, 0xC2CFF1B5)` (near underflow): `90 853` inputs closed analytically. -/
theorem holdsOnBits_near_underflow_main (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode) 0xC2CE8ED0 0xC2CFF1B5 :=
  Expf.Paths.holdsOnBits_of_forall_bitVec fun b hlo hhi => by
    obtain ⟨v, hv_eq, hv_err⟩ :=
      doubleEval_main_error_neg hmode b (by omega) hhi (by omega) (by omega)
    obtain ⟨hnan, hinf, hzero⟩ := Binary32.classify_of_toNatBits_mem (x := f32(b))
      (first := 0xC2CE8ED0) (last := 0xC2CFF1B4)
      (.inr ⟨by norm_num, by norm_num⟩) ⟨by change 0xC2CE8ED0 ≤ b.toNat; omega,
        by change b.toNat ≤ 0xC2CFF1B4; omega⟩
    have hx_lo : -(3406957 / 2 ^ 15 : ℝ) ≤ f32(b).toReal := by
      have h := (Binary32.toReal_ofNatBits_le_iff_of_nonpos (x := f32(b))
        (by norm_num) (by change 0x80000000 ≤ b.toNat ∧ b.toNat ≤ 0xFF7FFFFF; omega)).mpr
          (show f32(b).toNatBits ≤ 0xC2CFF1B4 by change b.toNat ≤ 0xC2CFF1B4; omega)
      have hrat : Model.toRat? (Model.ofNatBits (fmt := .binary32) 0xC2CFF1B4) =
          some (-(3406957 / 2 ^ 15)) := by decide +kernel
      rw [Model.Algebraic.toReal_of_toRat?_eq_some hrat] at h
      simpa using h
    have hx_hi : f32(b).toReal ≤ -(846061 / 2 ^ 13 : ℝ) := by
      have h := (Binary32.toReal_le_ofNatBits_iff_of_nonpos (x := f32(b))
        (by norm_num) (by change 0x80000000 ≤ b.toNat ∧ b.toNat ≤ 0xFF7FFFFF; omega)).mpr
          (show 0xC2CE8ED0 ≤ f32(b).toNatBits by change 0xC2CE8ED0 ≤ b.toNat; omega)
      have hrat : Model.toRat? (Model.ofNatBits (fmt := .binary32) 0xC2CE8ED0) =
          some (-(846061 / 2 ^ 13)) := by decide +kernel
      rw [Model.Algebraic.toReal_of_toRat?_eq_some hrat] at h
      simpa using h
    have hexp_lo : 1 / 2 ^ 150 * (1 + 1 / 2 ^ 21 : ℝ) ≤ Real.exp f32(b).toReal := by
      have hlog := Real.log_two_gt_d9
      have hmul : Real.exp f32(b).toReal =
          (1 / 2 ^ 150 : ℝ) * Real.exp (f32(b).toReal + (150 : ℕ) * Real.log 2) := by
        rw [Real.exp_add, Real.exp_nat_mul, Real.exp_log (by norm_num)]
        field_simp
      rw [hmul]
      have hexp := Real.add_one_le_exp (f32(b).toReal + (150 : ℕ) * Real.log 2)
      refine mul_le_mul_of_nonneg_left ?_ (by positivity)
      norm_num at hlog hx_lo hexp ⊢
      linarith
    have hexp_hi : Real.exp f32(b).toReal ≤ 1 / 2 ^ 149 * (1 / (1 + 1 / 2 ^ 21 : ℝ)) := by
      have hlog := Real.log_two_lt_d9
      have hmul : Real.exp f32(b).toReal =
          (1 / 2 ^ 149 : ℝ) * Real.exp (f32(b).toReal + (149 : ℕ) * Real.log 2) := by
        rw [Real.exp_add, Real.exp_nat_mul, Real.exp_log (by norm_num)]
        field_simp
      rw [hmul]
      refine mul_le_mul_of_nonneg_left ?_ (by positivity)
      have hneg : f32(b).toReal + (149 : ℕ) * Real.log 2 ≤ -(1 / 2 ^ 21 : ℝ) := by
        norm_num at hlog hx_hi ⊢; linarith
      have hinv : Real.exp (-(1 / 2 ^ 21 : ℝ)) ≤ 1 / (1 + 1 / 2 ^ 21 : ℝ) := by
        rw [Real.exp_neg, inv_eq_one_div]
        exact one_div_le_one_div_of_le (by positivity)
          (by linarith [Real.add_one_le_exp (1 / 2 ^ 21 : ℝ)])
      exact (Real.exp_le_exp.mpr hneg).trans hinv
    refine .of_eq_some hv_eq (.inl ?_)
    rw [ExpRanges.eval_eq_roundReal hnan hinf hzero]
    exact RoundingTransfer.roundReal_near_underflow_of_err hmode hexp_lo hexp_hi hv_err

/-! ### Axiom guards -/

/--
info: 'LibcMath.Extracted.Expf.ProductError.doubleEval_main_error_pos' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms doubleEval_main_error_pos

/--
info: 'LibcMath.Extracted.Expf.ProductError.doubleEval_main_error_neg' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms doubleEval_main_error_neg

/--
info: 'LibcMath.Extracted.Expf.ProductError.holdsOnBits_tiny_pos_main' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms holdsOnBits_tiny_pos_main

/--
info: 'LibcMath.Extracted.Expf.ProductError.holdsOnBits_tiny_neg_main' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms holdsOnBits_tiny_neg_main

/--
info: 'LibcMath.Extracted.Expf.ProductError.holdsOnBits_near_underflow_main' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms holdsOnBits_near_underflow_main

end LibcMath.Extracted.Expf.ProductError
