import FloatLib.Numerics.Enclosure.Constants.Proof
import FloatLib.Numerics.Enclosure.Interval.BinaryGridProof
import Mathlib.Analysis.Complex.Exponential

/-!
# Enclosures of the exponential by reduction with `log 2`

`ExpOracle.reducedEnclosure? r q` encloses `exp q` as `exp x * 2 ^ k` with `x = q - k * log 2` in
`[0, 1]`: `x` is enclosed from FloatLib's enclosure of `log 2`, and `exp x` by its Taylor
polynomial in Horner form, evaluated downward at the lower end of `x` and upward at its upper end
in fixed point. The parameters `r` fix the precision and the degree.

With the parameters `wordReduction`, 31 fractional bits, every intermediate value of the Horner
evaluation fits a machine word for arguments of moderate size. That is the purpose of this
enclosure: it is some six binary digits finer than a quarter of the spacing of binary32 and
settles most roundings at a fraction of the cost of a multiple-precision enclosure. The parameters
`wideReduction`, 48 fractional bits, settle nearly all the others. Soundness does not depend on
the sizes.
-/

namespace LibcMath.ExpOracle

open FloatLib.Numerics
open Interval.BinaryGrid (value scale scale_eq_pow containsReal_iff)
open Finset (range)

/-! ## The Taylor polynomial in Horner form -/

/-- `1 + x / (i + 1) * (1 + x / (i + 2) * (… * (1 + x / (i + j) * a)))`. -/
noncomputable def horner (x a : ℝ) : ℕ → ℕ → ℝ
  | _, 0 => a
  | i, j + 1 => 1 + x / ((i : ℝ) + 1) * horner x a (i + 1) j

theorem horner_eq (x a : ℝ) (i j : ℕ) :
    horner x a i j =
      ∑ m ∈ range j, x ^ m * i.factorial / (i + m).factorial +
        x ^ j * i.factorial / (i + j).factorial * a := by
  induction j generalizing i with
  | zero =>
      have hfact : ((i.factorial : ℕ) : ℝ) ≠ 0 := by exact_mod_cast i.factorial_ne_zero
      simp [horner, hfact]
  | succ j ih =>
      have hfact : (((i + 1).factorial : ℕ) : ℝ) = ((i : ℝ) + 1) * i.factorial := by
        push_cast [Nat.factorial_succ]
        ring
      have hpos : (0 : ℝ) < (i : ℝ) + 1 := by positivity
      rw [horner, ih, Finset.sum_range_succ', mul_add, Finset.mul_sum]
      have hterm (m : ℕ) : x / ((i : ℝ) + 1) *
          (x ^ m * (i + 1).factorial / (i + 1 + m).factorial) =
          x ^ (m + 1) * i.factorial / (i + (m + 1)).factorial := by
        rw [show i + 1 + m = i + (m + 1) by omega, hfact]
        field_simp
        ring
      have hzero : x ^ 0 * (i.factorial : ℝ) / (i + 0).factorial = 1 := by
        rw [pow_zero, one_mul, add_zero]
        exact div_self (by exact_mod_cast i.factorial_ne_zero)
      rw [Finset.sum_congr rfl fun m _ => hterm m, ← mul_assoc, hterm j, hzero]
      ring

theorem horner_nonneg {x a : ℝ} (hx : 0 ≤ x) (ha : 0 ≤ a) (i j : ℕ) : 0 ≤ horner x a i j := by
  induction j generalizing i with
  | zero => exact ha
  | succ j ih =>
      rw [horner]
      have := ih (i + 1)
      positivity

theorem horner_one_le_exp {x : ℝ} (hx : 0 ≤ x) (n : ℕ) : horner x 1 0 n ≤ Real.exp x := by
  have h := Real.sum_le_exp_of_nonneg hx (n + 1)
  rw [Finset.sum_range_succ] at h
  simpa [horner_eq] using h

theorem exp_le_horner_two {x : ℝ} (hx : 0 ≤ x) (hone : x ≤ 1) {n : ℕ} (hn : 0 < n) :
    Real.exp x ≤ horner x 2 0 n := by
  have hcast : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have hfact : (0 : ℝ) < n.factorial := by exact_mod_cast n.factorial_pos
  refine (Real.exp_bound' hx hone hn).trans ?_
  have htail : x ^ n * (n + 1) / (n.factorial * n) ≤ x ^ n / n.factorial * 2 := by
    rw [div_le_iff₀ (by positivity)]
    have : x ^ n / n.factorial * 2 * (n.factorial * n) = x ^ n * (2 * n) := by
      field_simp
    rw [this]
    gcongr
    linarith
  simpa [horner_eq] using htail

/-! ## Horner evaluation in fixed point -/

/-- `horner x 1 i j` rounded down to a multiple of `1 / scale`, as its numerator, for `x` at least
`argument / scale`. -/
def hornerLower (scale argument : ℕ) : ℕ → ℕ → ℕ
  | _, 0 => scale
  | i, j + 1 => scale + argument * hornerLower scale argument (i + 1) j / ((i + 1) * scale)

/-- `horner x 2 i j` rounded up to a multiple of `1 / scale`, as its numerator, for `x` at most
`argument / scale`. -/
def hornerUpper (scale argument : ℕ) : ℕ → ℕ → ℕ
  | _, 0 => 2 * scale
  | i, j + 1 => scale + argument * hornerUpper scale argument (i + 1) j / ((i + 1) * scale) + 1

theorem hornerLower_le {x : ℝ} {scale argument : ℕ} (hscale : 0 < scale) (hx : 0 ≤ x)
    (hargument : (argument : ℝ) / scale ≤ x) (i j : ℕ) :
    (hornerLower scale argument i j : ℝ) / scale ≤ horner x 1 i j := by
  have hpos : (0 : ℝ) < scale := by exact_mod_cast hscale
  induction j generalizing i with
  | zero => simp [hornerLower, horner, hpos.ne']
  | succ j ih =>
      have hinner := ih (i + 1)
      have hnonneg := horner_nonneg hx zero_le_one (i + 1) j
      set inner := hornerLower scale argument (i + 1) j
      have hfloor : ((argument * inner / ((i + 1) * scale) : ℕ) : ℝ) ≤
          (argument : ℝ) * inner / (((i : ℝ) + 1) * scale) := by
        refine Nat.cast_div_le.trans_eq ?_
        push_cast
        rfl
      have hstep : ((argument * inner / ((i + 1) * scale) : ℕ) : ℝ) / scale ≤
          x / ((i : ℝ) + 1) * horner x 1 (i + 1) j := by
        calc ((argument * inner / ((i + 1) * scale) : ℕ) : ℝ) / scale
            ≤ (argument : ℝ) * inner / (((i : ℝ) + 1) * scale) / scale := by
              gcongr
          _ = (argument : ℝ) / scale * (inner / scale) / ((i : ℝ) + 1) := by
              field_simp
          _ ≤ x * horner x 1 (i + 1) j / ((i : ℝ) + 1) := by
              gcongr
          _ = x / ((i : ℝ) + 1) * horner x 1 (i + 1) j := by ring
      rw [hornerLower, horner]
      push_cast
      rw [add_div, div_self hpos.ne']
      linarith

theorem le_hornerUpper {x : ℝ} {scale argument : ℕ} (hscale : 0 < scale) (hx : 0 ≤ x)
    (hargument : x ≤ (argument : ℝ) / scale) (i j : ℕ) :
    horner x 2 i j ≤ (hornerUpper scale argument i j : ℝ) / scale := by
  have hpos : (0 : ℝ) < scale := by exact_mod_cast hscale
  induction j generalizing i with
  | zero =>
      simp only [hornerUpper, horner]
      push_cast
      rw [mul_div_assoc, div_self hpos.ne', mul_one]
  | succ j ih =>
      have hinner := ih (i + 1)
      have hnonneg := horner_nonneg hx zero_le_two (i + 1) j
      set inner := hornerUpper scale argument (i + 1) j
      have hdivisor : 0 < (i + 1) * scale := by positivity
      have hceil : (argument : ℝ) * inner / (((i : ℝ) + 1) * scale) ≤
          ((argument * inner / ((i + 1) * scale) : ℕ) : ℝ) + 1 := by
        rw [div_le_iff₀ (by positivity)]
        have h := (Nat.lt_mul_div_succ (argument * inner) hdivisor).le
        have hreal : ((argument * inner : ℕ) : ℝ) ≤
            (((i + 1) * scale * (argument * inner / ((i + 1) * scale) + 1) : ℕ) : ℝ) := by
          exact_mod_cast h
        push_cast at hreal
        linarith
      have hstep : x / ((i : ℝ) + 1) * horner x 2 (i + 1) j ≤
          (((argument * inner / ((i + 1) * scale) : ℕ) : ℝ) + 1) / scale := by
        calc x / ((i : ℝ) + 1) * horner x 2 (i + 1) j
            = x * horner x 2 (i + 1) j / ((i : ℝ) + 1) := by ring
          _ ≤ (argument : ℝ) / scale * (inner / scale) / ((i : ℝ) + 1) := by
              gcongr
          _ = (argument : ℝ) * inner / (((i : ℝ) + 1) * scale) / scale := by
              field_simp
          _ ≤ _ := by gcongr
      rw [hornerUpper, horner]
      push_cast
      rw [add_div, add_div, div_self hpos.ne']
      rw [add_div] at hstep
      linarith

/-- The fixed-point Horner values enclose `exp x` for `x` in `[0, 1]`. -/
theorem exp_mem_horner {x : ℝ} {scale lower upper degree : ℕ} (hscale : 0 < scale)
    (hdegree : 0 < degree) (hlower : (lower : ℝ) / scale ≤ x) (hupper : x ≤ (upper : ℝ) / scale)
    (hone : upper ≤ scale) :
    (hornerLower scale lower 0 degree : ℝ) / scale ≤ Real.exp x ∧
      Real.exp x ≤ (hornerUpper scale upper 0 degree : ℝ) / scale := by
  have hpos : (0 : ℝ) < scale := by exact_mod_cast hscale
  have hx : 0 ≤ x := le_trans (by positivity) hlower
  have hx1 : x ≤ 1 := by
    refine hupper.trans ?_
    rw [div_le_one hpos]
    exact_mod_cast hone
  exact ⟨(hornerLower_le hscale hx hlower 0 degree).trans (horner_one_le_exp hx degree),
    (exp_le_horner_two hx hx1 hdegree).trans (le_hornerUpper hscale hx hupper 0 degree)⟩

/-! ## Reduction by a multiple of `log 2` -/

/-- The parameters of `reducedEnclosure?`. -/
structure Reduction where
  /-- The fractional bits of the fixed-point Horner evaluation. -/
  precision : ℕ
  /-- The further fractional bits that `log 2` and the reduced argument carry. -/
  guard : ℕ
  /-- The degree of the Taylor polynomial. -/
  degree : ℕ
  /-- The denominator of the fixed-point values. -/
  scale : ℕ
  /-- An enclosure of `log 2` with `precision + guard` fractional bits. -/
  logTwo : Interval ℤ
  degree_pos : 0 < degree
  scale_eq : scale = 2 ^ precision
  logTwo_eq : logTwo = Enclosure.Constants.ln2Grid (precision + guard)

/-- The parameters with the given precisions and degree, and FloatLib's enclosure of `log 2`. -/
def Reduction.ofPrecision (precision guard degree : ℕ) (hdegree : 0 < degree) : Reduction where
  precision := precision
  guard := guard
  degree := degree
  scale := 2 ^ precision
  logTwo := Enclosure.Constants.ln2Grid (precision + guard)
  degree_pos := hdegree
  scale_eq := rfl
  logTwo_eq := rfl

/-- 31 fractional bits and degree 12, whose remainder at `log 2` is below `2 ^ -34`: the products
of the Horner evaluation are below `2 ^ 63`. -/
def wordReduction : Reduction :=
  .ofPrecision 31 23 12 (by decide)

/-- 48 fractional bits and degree 16, whose remainder at `log 2` is below `2 ^ -52`. -/
def wideReduction : Reduction :=
  .ofPrecision 48 16 16 (by decide)

/-- `q - k * log 2` lies between the two integers below, in units of `2 ^ (-precision)`, for an
enclosure `l` of `log 2` in the same units. -/
theorem reduced_bounds (q : ℚ) (k : ℤ) {precision : ℕ} {l : Interval ℤ}
    (hl : value precision l.lo ≤ Real.log 2 ∧ Real.log 2 ≤ value precision l.hi) :
    (((q.num <<< precision) / (q.den : ℤ) - max (k * l.lo) (k * l.hi) : ℤ) : ℝ) / 2 ^ precision ≤
        q - k * Real.log 2 ∧
      q - k * Real.log 2 ≤
        (((q.num <<< precision) / (q.den : ℤ) + 1 - min (k * l.lo) (k * l.hi) : ℤ) : ℝ) /
          2 ^ precision := by
  have hscale : (0 : ℝ) < 2 ^ precision := by positivity
  have hden : (0 : ℝ) < q.den := by exact_mod_cast q.den_pos
  have hdenInt : (0 : ℤ) < q.den := by exact_mod_cast q.den_pos
  have hq : (q : ℝ) = q.num / q.den := by exact_mod_cast (Rat.num_div_den q).symm
  have hcast : (scale precision : ℝ) = 2 ^ precision := by
    rw [scale_eq_pow]
    push_cast
    rfl
  rw [value, value, hcast] at hl
  set floor := (q.num <<< precision) / (q.den : ℤ) with hfloor
  have hfloorLe : (floor : ℝ) / 2 ^ precision ≤ q := by
    have h := Int.ediv_mul_le (q.num <<< precision) hdenInt.ne'
    rw [← hfloor, Int.shiftLeft_eq] at h
    have hreal : (floor : ℝ) * q.den ≤ q.num * 2 ^ precision := by exact_mod_cast h
    rw [hq, div_le_div_iff₀ hscale hden]
    exact hreal
  have hleFloor : (q : ℝ) ≤ ((floor : ℝ) + 1) / 2 ^ precision := by
    have h := (Int.lt_ediv_add_one_mul_self (q.num <<< precision) hdenInt).le
    rw [← hfloor, Int.shiftLeft_eq] at h
    have hreal : (q.num : ℝ) * 2 ^ precision ≤ ((floor : ℝ) + 1) * q.den := by exact_mod_cast h
    rw [hq, div_le_div_iff₀ hden hscale]
    exact hreal
  have hmax : (k : ℝ) * Real.log 2 ≤
      ((max (k * l.lo) (k * l.hi) : ℤ) : ℝ) / 2 ^ precision := by
    rw [Int.cast_max, le_div_iff₀ hscale]
    rcases le_total 0 k with hk | hk
    · have hk' : (0 : ℝ) ≤ k := by exact_mod_cast hk
      refine le_max_of_le_right ?_
      push_cast
      have := mul_le_mul_of_nonneg_left hl.2 hk'
      rw [← mul_div_assoc, le_div_iff₀ hscale] at this
      linarith
    · have hk' : (k : ℝ) ≤ 0 := by exact_mod_cast hk
      refine le_max_of_le_left ?_
      push_cast
      have := mul_le_mul_of_nonpos_left hl.1 hk'
      rw [← mul_div_assoc, le_div_iff₀ hscale] at this
      linarith
  have hmin : ((min (k * l.lo) (k * l.hi) : ℤ) : ℝ) / 2 ^ precision ≤
      (k : ℝ) * Real.log 2 := by
    rw [Int.cast_min, div_le_iff₀ hscale]
    rcases le_total 0 k with hk | hk
    · have hk' : (0 : ℝ) ≤ k := by exact_mod_cast hk
      refine min_le_of_left_le ?_
      push_cast
      have := mul_le_mul_of_nonneg_left hl.1 hk'
      rw [← mul_div_assoc, div_le_iff₀ hscale] at this
      linarith
    · have hk' : (k : ℝ) ≤ 0 := by exact_mod_cast hk
      refine min_le_of_right_le ?_
      push_cast
      have := mul_le_mul_of_nonpos_left hl.2 hk'
      rw [← mul_div_assoc, div_le_iff₀ hscale] at this
      linarith
  constructor
  · rw [Int.cast_sub, sub_div]
    linarith
  · rw [Int.cast_sub, Int.cast_add, Int.cast_one, sub_div]
    linarith

/--
An enclosure of `exp q` as a multiple `k` and an interval `I` on the grid of
`2 ^ (-r.precision)`: `exp q` lies between `I.lo * 2 ^ k` and `I.hi * 2 ^ k`. The multiple is
`⌊q / log 2⌋` computed from a 52-bit approximation of `1 / log 2`; the result is `none` if the
reduced argument `q - k * log 2` is not seen to lie in `[0, 1]`.
-/
def reducedEnclosure? (r : Reduction) (q : ℚ) : Option (ℤ × Interval ℤ) :=
  let multiple := q.num * 6497320848556798 / ((q.den : ℤ) <<< 52)
  let argument := (q.num <<< (r.precision + r.guard)) / (q.den : ℤ)
  let lower := argument - max (multiple * r.logTwo.lo) (multiple * r.logTwo.hi)
  let upper := argument + 1 - min (multiple * r.logTwo.lo) (multiple * r.logTwo.hi)
  let coarseLower := lower.toNat >>> r.guard
  let coarseUpper := upper.toNat >>> r.guard + 1
  if 0 ≤ lower ∧ coarseUpper ≤ r.scale then
    some (multiple, ⟨(hornerLower r.scale coarseLower 0 r.degree : ℕ),
      (hornerUpper r.scale coarseUpper 0 r.degree : ℕ)⟩)
  else none

theorem contains_reducedEnclosure? {r : Reduction} {q : ℚ} {multiple : ℤ} {I : Interval ℤ}
    (h : reducedEnclosure? r q = some (multiple, I)) :
    value r.precision I.lo * 2 ^ multiple ≤ Real.exp q ∧
      Real.exp q ≤ value r.precision I.hi * 2 ^ multiple := by
  unfold reducedEnclosure? at h
  dsimp only at h
  split at h
  · rename_i hreduced
    obtain ⟨hnonneg, hone⟩ := hreduced
    obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Option.some.inj h)
    set multiple := q.num * 6497320848556798 / ((q.den : ℤ) <<< 52)
    have hbounds := reduced_bounds q multiple (l := r.logTwo) (by
      rw [r.logTwo_eq]
      exact (containsReal_iff _ _ _).mp
        (Enclosure.Constants.containsReal_ln2Grid (r.precision + r.guard)))
    set lower := (q.num <<< (r.precision + r.guard)) / (q.den : ℤ) -
      max (multiple * r.logTwo.lo) (multiple * r.logTwo.hi)
    set upper := (q.num <<< (r.precision + r.guard)) / (q.den : ℤ) + 1 -
      min (multiple * r.logTwo.lo) (multiple * r.logTwo.hi)
    have hgrid : (0 : ℝ) < 2 ^ r.precision := by positivity
    have hguard : (0 : ℝ) < 2 ^ r.guard := by positivity
    have hlower : ((lower.toNat >>> r.guard : ℕ) : ℝ) / 2 ^ r.precision ≤
        q - multiple * Real.log 2 := by
      refine le_trans ?_ hbounds.1
      have hcast : ((lower.toNat : ℤ) : ℝ) = lower := by rw [Int.toNat_of_nonneg hnonneg]
      rw [Int.cast_natCast] at hcast
      rw [← hcast, pow_add, Nat.shiftRight_eq_div_pow, div_le_div_iff₀ hgrid (by positivity)]
      have h := Nat.div_mul_le_self lower.toNat (2 ^ r.guard)
      have hreal : ((lower.toNat / 2 ^ r.guard : ℕ) : ℝ) * 2 ^ r.guard ≤ lower.toNat := by
        exact_mod_cast h
      nlinarith
    have hupper : q - multiple * Real.log 2 ≤
        ((upper.toNat >>> r.guard + 1 : ℕ) : ℝ) / 2 ^ r.precision := by
      refine le_trans hbounds.2 ?_
      have hcast : (upper : ℝ) ≤ upper.toNat := by exact_mod_cast Int.self_le_toNat upper
      rw [pow_add, Nat.shiftRight_eq_div_pow, div_le_div_iff₀ (by positivity) hgrid]
      have h := (Nat.lt_mul_div_succ upper.toNat (Nat.two_pow_pos r.guard)).le
      have hreal : (upper.toNat : ℝ) ≤
          2 ^ r.guard * (((upper.toNat / 2 ^ r.guard : ℕ) : ℝ) + 1) := by exact_mod_cast h
      push_cast
      nlinarith
    have hr.scale : (r.scale : ℝ) = 2 ^ r.precision := by
      rw [r.scale_eq]
      push_cast
      rfl
    rw [← hr.scale] at hlower hupper
    obtain ⟨hlo, hhi⟩ := exp_mem_horner (degree := r.degree)
      (r.scale_eq ▸ Nat.two_pow_pos r.precision) r.degree_pos hlower hupper hone
    have hpow : (0 : ℝ) < 2 ^ multiple := zpow_pos (by norm_num) multiple
    have hexp : Real.exp q = Real.exp (q - multiple * Real.log 2) * 2 ^ multiple := by
      rw [← Real.exp_log hpow, Real.log_zpow, ← Real.exp_add, sub_add_cancel]
    have hcast : (scale r.precision : ℝ) = 2 ^ r.precision := by
      rw [scale_eq_pow]
      push_cast
      rfl
    rw [hexp, value, value, hcast, ← hr.scale]
    push_cast
    exact ⟨mul_le_mul_of_nonneg_right hlo hpow.le, mul_le_mul_of_nonneg_right hhi hpow.le⟩
  · simp at h

end LibcMath.ExpOracle
