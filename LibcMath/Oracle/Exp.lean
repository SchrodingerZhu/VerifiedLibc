import LibcMath.Functions
import LibcMath.Check.Oracle
import LibcMath.Oracle.ExpReduced
import FloatLib.Floats.Formats.BinaryInterchange.Algebraic.Rounding.DirectedEnclosureProof
import FloatLib.Floats.Formats.BinaryInterchange.Algebraic.Rounding.DirectedRange
import FloatLib.Numerics.Exact.Elementary.Proof
import Mathlib.Analysis.Complex.ExponentialBounds

/-!
# An oracle for the exponential

`expOracle fmt` decides whether a bit pattern is the correctly rounded exponential of an input, in
every rounding direction and for every format descriptor. It never gives up: for a finite nonzero
input with exact value `q` it computes the correctly rounded result `ExpOracle.round fmt mode q`,
which `ExpOracle.round_eq` proves equal to `Model.roundReal fmt mode (Real.exp q)`, and compares
bit patterns.

`ExpOracle.round` takes the first of the following that applies.

* `q` at or above `upperExponent fmt`, or below `lowerExponent fmt`: the exponential is at least
  `2 ^ upperExponent fmt`, or below half the least positive number, and its rounding is the
  overflow or underflow result of the direction.
* For an IEEE format, an enclosure of `exp q` between two integers on a binary grid that have the
  same integer part in units of a quarter of the spacing of the format, which locates `exp q`
  among the rounding boundaries of every direction (`ExpOracle.roundGrid?`). The enclosures
  tried are `[1 + q, 1 + q + q ^ 2]` next to zero, and elsewhere `ExpOracle.reducedEnclosure?`
  with 31 and with 48 fractional bits, followed by FloatLib's fixed-point enclosure
  `Enclosure.BinaryGrid.exp` at two precisions.
* Otherwise, rounding by exact comparisons of `exp q` with rational boundaries
  (`ElementaryComparison.compareExp`), which terminates for every boundary.

The rounding theorems, the last two enclosures and the comparisons are FloatLib's.
-/

namespace LibcMath

open FloatLib.Floats.Formats FloatLib.Floats.Formats.BinaryInterchange FloatLib.Numerics
open Model (IEEERoundingMode)
open Model.AlgebraicRounding (roundSigned roundLocated roundLocated_roundsTo lowerExponent
  upperExponent certificateExponent Located located_of_truncated)
open Interval.BinaryGrid (value scale scale_eq_pow containsReal_iff)

variable {fmt : FloatFormat}

namespace ExpOracle

/-- Whether two values have the same bit pattern. -/
def sameBits (a b : Model fmt) : Bool :=
  a.toNatBits == b.toNatBits

theorem eq_of_sameBits {a b : Model fmt} (h : sameBits a b = true) : a = b := by
  rw [← Model.ofNatBits_toNatBits a, ← Model.ofNatBits_toNatBits b, beq_iff_eq.mp h]

/-! ## Rounding a real enclosed on a binary grid -/

/-- In an IEEE format, the contract `RoundsTo` determines the result. -/
theorem eq_of_roundsTo (hfmt : fmt.isIEEE = true) {mode : IEEERoundingMode} {x : ℝ} {sign : Bool}
    {a b : Model fmt} (ha : Model.RoundsTo fmt mode x sign a)
    (hb : Model.RoundsTo fmt mode x sign b) : a = b := by
  have hsigned := FloatFormat.supportsSignedZero_eq_true_of_isIEEE fmt hfmt
  by_cases hrange : |Model.roundAt fmt x mode| ≤ Model.toReal (Model.posMaxFinite fmt)
  · obtain ⟨hfa, hva⟩ := ha.finite hrange
    obtain ⟨hfb, hvb⟩ := hb.finite hrange
    exact Model.eq_of_toReal_eq hfa hfb (hva.trans hvb.symm) fun _ =>
      (ha.signBit hsigned).trans (hb.signBit hsigned).symm
  · rw [ha.overflow (not_le.mp hrange), hb.overflow (not_le.mp hrange)]

/--
A real between `lower / 2 ^ precision` and `upper / 2 ^ precision` is located on the grid of `fmt`
when both bounds have the same leading bit and the same integer part `lower / 2 ^ shift` in units
of a quarter of the spacing of the grid, and `lower` is not a multiple of that unit.
-/
theorem located_of_grid (fmt : FloatFormat) {t : ℝ} {precision lower upper shift : ℕ}
    (hpos : 0 < lower) (hlower : (lower : ℝ) / 2 ^ precision ≤ t)
    (hupper : t ≤ (upper : ℝ) / 2 ^ precision) (hlog : upper.log2 = lower.log2)
    (hshift : (precision : ℤ) + certificateExponent fmt ((lower.log2 : ℤ) - precision) = shift)
    (hfloor : upper / 2 ^ shift = lower / 2 ^ shift)
    (hstrict : lower / 2 ^ shift * 2 ^ shift ≠ lower) :
    Located fmt t (lower / 2 ^ shift / 4)
      (certificateExponent fmt ((lower.log2 : ℤ) - precision) + 2)
      (decide (2 ≤ lower / 2 ^ shift % 4)) true := by
  have hscale : (0 : ℝ) < 2 ^ precision := by positivity
  have hstep : (0 : ℝ) < 2 ^ shift := by positivity
  have ht : 0 < t := lt_of_lt_of_le (by positivity) hlower
  have hexponent : certificateExponent fmt ((lower.log2 : ℤ) - precision) =
      (shift : ℤ) - precision := by omega
  have hbpow (n : ℕ) : Flocq.bpow binaryRadix ((n : ℤ) - precision) =
      (2 : ℝ) ^ n / 2 ^ precision := by
    rw [Flocq.bpow_binaryRadix, zpow_sub₀ (by norm_num), zpow_natCast, zpow_natCast]
  have hblo : Flocq.bpow binaryRadix ((lower.log2 : ℤ) - precision) ≤ t := by
    rw [hbpow]
    refine le_trans ?_ hlower
    gcongr
    exact_mod_cast Nat.log2_self_le hpos.ne'
  have hbhi : t < Flocq.bpow binaryRadix ((lower.log2 : ℤ) - precision + 1) := by
    rw [show (lower.log2 : ℤ) - precision + 1 = ((lower.log2 + 1 : ℕ) : ℤ) - precision by
      push_cast; ring, hbpow]
    refine lt_of_le_of_lt hupper ?_
    gcongr
    have hlt := Nat.lt_log2_self (n := upper)
    rw [hlog] at hlt
    exact_mod_cast hlt
  have hdiv : t / Flocq.bpow binaryRadix (certificateExponent fmt ((lower.log2 : ℤ) - precision)) =
      t * 2 ^ precision / 2 ^ shift := by
    rw [hexponent, hbpow]
    field_simp
  have hmul : lower / 2 ^ shift * 2 ^ shift < lower :=
    lt_of_le_of_ne (Nat.div_mul_le_self _ _) hstrict
  have hnext : upper < (lower / 2 ^ shift + 1) * 2 ^ shift := by
    rw [← hfloor]
    exact (Nat.div_lt_iff_lt_mul (Nat.two_pow_pos shift)).mp (Nat.lt_succ_self _)
  have hlowerReal : (lower : ℝ) ≤ t * 2 ^ precision := (div_le_iff₀ hscale).mp hlower
  have hupperReal : t * 2 ^ precision ≤ upper := (le_div_iff₀ hscale).mp hupper
  have hmulReal : ((lower / 2 ^ shift : ℕ) : ℝ) * 2 ^ shift < lower := by exact_mod_cast hmul
  have hnextReal : (upper : ℝ) < (((lower / 2 ^ shift : ℕ) : ℝ) + 1) * 2 ^ shift := by
    exact_mod_cast hnext
  have hfloorLo : ((lower / 2 ^ shift : ℕ) : ℝ) < t * 2 ^ precision / 2 ^ shift := by
    rw [lt_div_iff₀ hstep]
    linarith
  have hfloorHi : t * 2 ^ precision / 2 ^ shift < ((lower / 2 ^ shift : ℕ) : ℝ) + 1 := by
    rw [div_lt_iff₀ hstep]
    linarith
  have h := located_of_truncated fmt ht hblo hbhi (mantissa := lower / 2 ^ shift) (exact := false)
    (by rw [hdiv]; exact hfloorLo.le) (by rw [hdiv]; exact hfloorHi)
    (by rw [hdiv]; simpa using hfloorLo.ne')
  simpa using h

/--
The rounding in the direction `mode` of every real between `I.lo / 2 ^ precision` and
`I.hi / 2 ^ precision`, when these bounds are positive and decide it: they have the same leading
bit and the same integer part in units of a quarter of the spacing of the grid of `fmt`, and the
lower bound is not a multiple of that unit. All four directions use the same test.
-/
def roundGrid? (fmt : FloatFormat) (mode : IEEERoundingMode) (precision : ℕ) (I : Interval ℤ) :
    Option (Model fmt) :=
  let lower := I.lo.toNat
  let upper := I.hi.toNat
  let exponent := certificateExponent fmt ((lower.log2 : ℤ) - precision)
  let shift := (precision + exponent).toNat
  let mantissa := lower >>> shift
  if 0 < lower ∧ upper.log2 = lower.log2 ∧ 0 ≤ precision + exponent ∧
      upper >>> shift = mantissa ∧ mantissa <<< shift ≠ lower then
    some (roundLocated fmt mode false (mantissa / 4) (exponent + 2) (decide (2 ≤ mantissa % 4))
      true)
  else none

theorem roundReal_eq_of_roundGrid? (hfmt : fmt.isIEEE = true) {mode : IEEERoundingMode}
    {precision : ℕ} {I : Interval ℤ} {t : ℝ} {result : Model fmt}
    (hlower : value precision I.lo ≤ t) (hupper : t ≤ value precision I.hi)
    (h : roundGrid? fmt mode precision I = some result) :
    Model.roundReal fmt mode t = result := by
  unfold roundGrid? at h
  dsimp only at h
  split at h
  · rename_i hdecided
    obtain ⟨hpos, hlog, hshift, hfloor, hstrict⟩ := hdecided
    have hscale : (scale precision : ℝ) = 2 ^ precision := by
      rw [scale_eq_pow]
      push_cast
      rfl
    rw [value, hscale] at hlower hupper
    have hlo : (I.lo.toNat : ℝ) / 2 ^ precision ≤ t := by
      have hcast : ((I.lo.toNat : ℤ) : ℝ) = I.lo := by rw [Int.toNat_of_nonneg (by omega)]
      rw [Int.cast_natCast] at hcast
      rwa [hcast]
    have hhi : t ≤ (I.hi.toNat : ℝ) / 2 ^ precision := by
      refine hupper.trans ?_
      gcongr
      exact_mod_cast Int.self_le_toNat I.hi
    have hlocated := located_of_grid fmt hpos hlo hhi hlog (Int.toNat_of_nonneg hshift).symm
      (by simpa only [Nat.shiftRight_eq_div_pow] using hfloor)
      (by simpa only [Nat.shiftRight_eq_div_pow, Nat.shiftLeft_eq] using hstrict)
    have ht : 0 < t := lt_of_lt_of_le (by positivity) hlo
    have hreal := Model.roundReal_roundsTo (fmt := fmt) mode ht.ne'
    rw [decide_eq_false (not_lt.mpr ht.le)] at hreal
    rw [← Option.some.inj h]
    refine eq_of_roundsTo hfmt hreal ?_
    simpa only [Nat.shiftRight_eq_div_pow, Bool.false_eq_true, ↓reduceIte] using
      roundLocated_roundsTo hlocated mode false
  · simp at h

theorem value_sub_toNat {precision : ℕ} {multiple : ℤ} (h : multiple ≤ precision) (z : ℤ) :
    value (precision - multiple).toNat z = value precision z * 2 ^ multiple := by
  have hpow : (2 : ℝ) ^ (precision - multiple).toNat = 2 ^ (precision : ℤ) / 2 ^ multiple := by
    rw [← zpow_natCast, Int.toNat_of_nonneg (by omega), zpow_sub₀ (by norm_num)]
  have hmultiple : (0 : ℝ) < 2 ^ multiple := zpow_pos (by norm_num) multiple
  simp only [value, scale_eq_pow, Int.cast_pow, Int.cast_ofNat]
  rw [hpow, zpow_natCast]
  field_simp

theorem value_shiftLeft_toNat {precision : ℕ} {multiple : ℤ} (h : precision ≤ multiple) (z : ℤ) :
    value 0 (z <<< (multiple - precision).toNat) = value precision z * 2 ^ multiple := by
  have hpow : (2 : ℝ) ^ (multiple - precision).toNat = 2 ^ multiple / 2 ^ (precision : ℤ) := by
    rw [← zpow_natCast, Int.toNat_of_nonneg (by omega), zpow_sub₀ (by norm_num)]
  simp only [value, scale_eq_pow, Int.shiftLeft_eq, Int.cast_mul, Int.cast_pow, Int.cast_ofNat,
    pow_zero]
  rw [hpow, zpow_natCast]
  field_simp
  push_cast
  ring

/-- `roundGrid?` for the reals between `I.lo / 2 ^ precision * 2 ^ multiple` and
`I.hi / 2 ^ precision * 2 ^ multiple`. -/
def roundScaledGrid? (fmt : FloatFormat) (mode : IEEERoundingMode) (precision : ℕ) (multiple : ℤ)
    (I : Interval ℤ) : Option (Model fmt) :=
  if multiple ≤ precision then roundGrid? fmt mode (precision - multiple).toNat I
  else
    roundGrid? fmt mode 0
      ⟨I.lo <<< (multiple - precision).toNat, I.hi <<< (multiple - precision).toNat⟩

theorem roundReal_eq_of_roundScaledGrid? (hfmt : fmt.isIEEE = true) {mode : IEEERoundingMode}
    {precision : ℕ} {multiple : ℤ} {I : Interval ℤ} {t : ℝ} {result : Model fmt}
    (hlower : value precision I.lo * 2 ^ multiple ≤ t)
    (hupper : t ≤ value precision I.hi * 2 ^ multiple)
    (h : roundScaledGrid? fmt mode precision multiple I = some result) :
    Model.roundReal fmt mode t = result := by
  unfold roundScaledGrid? at h
  split at h
  · rename_i hle
    exact roundReal_eq_of_roundGrid? hfmt (by rwa [value_sub_toNat hle])
      (by rwa [value_sub_toNat hle]) h
  · rename_i hlt
    have hle : (precision : ℤ) ≤ multiple := by omega
    exact roundReal_eq_of_roundGrid? hfmt (by rwa [value_shiftLeft_toNat hle])
      (by rwa [value_shiftLeft_toNat hle]) h

/-! ## Enclosures of the exponential -/

/--
The enclosure `[1 + q, 1 + q + q ^ 2]` on the grid of `2 ^ (2 * j)` for an argument `q` with
denominator `2 ^ j`, as the grid precision and the interval. It contains `exp q` when `|q| ≤ 1`.
-/
def nearOne (q : ℚ) : ℕ × Interval ℤ :=
  (2 * q.den.log2,
    ⟨q.den * (q.den + q.num), q.den * (q.den + q.num) + q.num * q.num⟩)

theorem contains_nearOne {q : ℚ} (hden : q.den = 2 ^ q.den.log2) (hq : q.num.natAbs ≤ q.den) :
    value (nearOne q).1 (nearOne q).2.lo ≤ Real.exp q ∧
      Real.exp q ≤ value (nearOne q).1 (nearOne q).2.hi := by
  have hpos : (0 : ℝ) < q.den := by exact_mod_cast q.den_pos
  have hscale : (scale (2 * q.den.log2) : ℝ) = (q.den : ℝ) ^ 2 := by
    rw [scale_eq_pow, pow_mul']
    conv_rhs => rw [hden]
    push_cast
    rfl
  have hcast : (q : ℝ) = q.num / q.den := by exact_mod_cast (Rat.num_div_den q).symm
  have habs : |(q : ℝ)| ≤ 1 := by
    rw [hcast, abs_div, abs_of_pos hpos, div_le_one hpos]
    exact_mod_cast (Int.natCast_natAbs q.num ▸ Int.ofNat_le.mpr hq : |q.num| ≤ (q.den : ℤ))
  have hupper := (abs_le.mp (Real.abs_exp_sub_one_sub_id_le habs)).2
  have hlower := Real.add_one_le_exp (q : ℝ)
  simp only [nearOne, value, hscale]
  push_cast
  constructor
  · rw [div_le_iff₀ (by positivity)]
    rw [hcast] at hlower ⊢
    have : (q.num : ℝ) / q.den + 1 = (q.den * (q.den + q.num)) / (q.den : ℝ) ^ 2 := by
      field_simp
      ring
    rw [this, div_le_iff₀ (by positivity)] at hlower
    exact hlower
  · rw [le_div_iff₀ (by positivity)]
    rw [hcast] at hupper ⊢
    have : Real.exp ((q.num : ℝ) / q.den) ≤
        (q.den * (q.den + q.num) + q.num * q.num) / (q.den : ℝ) ^ 2 := by
      have hsum : (q.den * (q.den + q.num) + q.num * q.num) / (q.den : ℝ) ^ 2 =
          1 + (q.num : ℝ) / q.den + ((q.num : ℝ) / q.den) ^ 2 := by
        field_simp
      rw [hsum]
      linarith
    rwa [le_div_iff₀ (by positivity)] at this

/-- The Taylor degree of the fixed-point enclosure at a refinement level. -/
def degree (level : ℕ) : ℕ :=
  8 * (level + 1)

/--
FloatLib's fixed-point enclosure `Enclosure.BinaryGrid.exp` of `exp q` at a refinement level,
before its endpoints are converted to rationals: the grid precision and the interval. Level `0`
resolves the result to about sixteen bits beyond the precision of `fmt`, and each further level
adds twice the precision of `fmt`.
-/
def enclosure (fmt : FloatFormat) (q : ℚ) (level : ℕ) : ℕ × Interval ℤ :=
  let precision := Enclosure.BinaryGrid.expPrecision ((2 * level + 1) * (fmt.fracWidth + 1)) q
    (degree level)
  let extra := Enclosure.BinaryGrid.expExtraScale q (degree level) precision
  let reduction := Enclosure.expScale q + extra
  let working := precision + extra
  (working, Enclosure.BinaryGrid.squareRepeat working
    (Enclosure.BinaryGrid.expSmall (Kernel.Q.divPow2 q reduction) (degree level) working)
    reduction)

theorem contains_enclosure (fmt : FloatFormat) (q : ℚ) (level : ℕ) :
    value (enclosure fmt q level).1 (enclosure fmt q level).2.lo ≤ Real.exp q ∧
      Real.exp q ≤ value (enclosure fmt q level).1 (enclosure fmt q level).2.hi := by
  have h : (Enclosure.BinaryGrid.toRationalInterval (enclosure fmt q level).1
      (enclosure fmt q level).2).Contains (Real.exp q) :=
    Enclosure.BinaryGrid.contains_exp q (degree level)
      (Enclosure.BinaryGrid.expPrecision ((2 * level + 1) * (fmt.fracWidth + 1)) q (degree level))
  exact (containsReal_iff _ _ _).mp
    ((Enclosure.BinaryGrid.contains_toRationalInterval _ _ _).mp h)

/-- The rounding of `exp q` in the direction `mode`, when the enclosure at `level` decides it. -/
def roundEnclosedAt? (fmt : FloatFormat) (mode : IEEERoundingMode) (q : ℚ) (level : ℕ) :
    Option (Model fmt) :=
  let grid := enclosure fmt q level
  roundGrid? fmt mode grid.1 grid.2

/-- The rounding of `exp q` in the direction `mode`, when the enclosure `reducedEnclosure? r q`
decides it. -/
def roundReduced? (fmt : FloatFormat) (mode : IEEERoundingMode) (r : Reduction) (q : ℚ) :
    Option (Model fmt) :=
  match reducedEnclosure? r q with
  | some (multiple, I) => roundScaledGrid? fmt mode r.precision multiple I
  | none => none

theorem roundReal_eq_of_roundReduced? (hfmt : fmt.isIEEE = true) {mode : IEEERoundingMode}
    {r : Reduction} {q : ℚ} {result : Model fmt} (h : roundReduced? fmt mode r q = some result) :
    Model.roundReal fmt mode (Real.exp q) = result := by
  unfold roundReduced? at h
  split at h
  · rename_i multiple I hreduced
    exact roundReal_eq_of_roundScaledGrid? hfmt (contains_reducedEnclosure? hreduced).1
      (contains_reducedEnclosure? hreduced).2 h
  · simp at h

/-- The first result among the given attempts. -/
def firstSome {α : Type} : List (Unit → Option α) → Option α
  | [] => none
  | attempt :: attempts =>
      match attempt () with
      | some result => some result
      | none => firstSome attempts

theorem exists_of_firstSome {α : Type} {attempts : List (Unit → Option α)} {result : α}
    (h : firstSome attempts = some result) : ∃ attempt ∈ attempts, attempt () = some result := by
  induction attempts with
  | nil => simp [firstSome] at h
  | cons attempt attempts ih =>
      rw [firstSome] at h
      split at h
      · rename_i found hfound
        exact ⟨attempt, List.mem_cons_self, hfound.trans h⟩
      · obtain ⟨other, hmem, hother⟩ := ih h
        exact ⟨other, List.mem_cons_of_mem _ hmem, hother⟩

/--
The rounding of `exp q` in the direction `mode`, when an enclosure decides it: `nearOne` for a
dyadic `q` of magnitude at most `2 ^ (-(fmt.fracWidth + 4))`, and otherwise the first that
decides among the reduced enclosures with `wordReduction` and `wideReduction` and the fixed-point
enclosures at levels `0` and `1`.
-/
def roundEnclosed? (fmt : FloatFormat) (mode : IEEERoundingMode) (q : ℚ) : Option (Model fmt) :=
  if q.num.natAbs <<< (fmt.fracWidth + 4) ≤ q.den ∧ q.den = 1 <<< q.den.log2 then
    let grid := nearOne q
    roundGrid? fmt mode grid.1 grid.2
  else
    firstSome [fun _ => roundReduced? fmt mode wordReduction q,
      fun _ => roundReduced? fmt mode wideReduction q,
      fun _ => roundEnclosedAt? fmt mode q 0,
      fun _ => roundEnclosedAt? fmt mode q 1]

theorem roundReal_eq_of_roundEnclosed? (hfmt : fmt.isIEEE = true) {mode : IEEERoundingMode}
    {q : ℚ} {result : Model fmt} (h : roundEnclosed? fmt mode q = some result) :
    Model.roundReal fmt mode (Real.exp q) = result := by
  unfold roundEnclosed? at h
  split at h
  · rename_i hsmall
    have hden : q.den = 2 ^ q.den.log2 := hsmall.2.trans (Nat.one_shiftLeft _)
    have hq : q.num.natAbs ≤ q.den := by
      refine le_trans ?_ hsmall.1
      rw [Nat.shiftLeft_eq]
      exact Nat.le_mul_of_pos_right _ (Nat.two_pow_pos _)
    exact roundReal_eq_of_roundGrid? hfmt (contains_nearOne hden hq).1
      (contains_nearOne hden hq).2 h
  · obtain ⟨attempt, hmem, hattempt⟩ := exists_of_firstSome h
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
    obtain rfl | rfl | rfl | rfl := hmem
    · exact roundReal_eq_of_roundReduced? hfmt hattempt
    · exact roundReal_eq_of_roundReduced? hfmt hattempt
    · exact roundReal_eq_of_roundGrid? hfmt (contains_enclosure fmt q 0).1
        (contains_enclosure fmt q 0).2 hattempt
    · exact roundReal_eq_of_roundGrid? hfmt (contains_enclosure fmt q 1).1
        (contains_enclosure fmt q 1).2 hattempt

/-! ## Overflow and underflow by the size of the argument -/

theorem bpow_le_exp {exponent : ℤ} {q : ℚ} (hexponent : 0 ≤ exponent)
    (hq : (exponent : ℚ) ≤ q) : Flocq.bpow binaryRadix exponent ≤ Real.exp q := by
  have hreal : (exponent : ℝ) ≤ q := by exact_mod_cast hq
  have hnonneg : (0 : ℝ) ≤ exponent := by exact_mod_cast hexponent
  rw [Flocq.bpow_binaryRadix, ← Real.exp_log (zpow_pos (by norm_num : (0 : ℝ) < 2) exponent),
    Real.log_zpow, Real.exp_le_exp]
  nlinarith [Real.log_two_lt_d9]

theorem exp_lt_bpow {exponent : ℤ} {q : ℚ} (hexponent : exponent ≤ 0)
    (hq : q < (exponent : ℚ)) : Real.exp q < Flocq.bpow binaryRadix exponent := by
  have hreal : (q : ℝ) < exponent := by exact_mod_cast hq
  have hnonpos : (exponent : ℝ) ≤ 0 := by exact_mod_cast hexponent
  rw [Flocq.bpow_binaryRadix, ← Real.exp_log (zpow_pos (by norm_num : (0 : ℝ) < 2) exponent),
    Real.log_zpow, Real.exp_lt_exp]
  nlinarith [Real.log_two_lt_d9]

/-! ## The correctly rounded exponential -/

/-- The rounding of `exp q` in the direction `mode` by exact comparisons with rationals. -/
def roundCompared (fmt : FloatFormat) (mode : IEEERoundingMode) (q : ℚ) : Model fmt :=
  roundSigned fmt mode (ElementaryComparison.compareExp q)

theorem roundCompared_eq (fmt : FloatFormat) (mode : IEEERoundingMode) (q : ℚ) :
    roundCompared fmt mode q = Model.roundReal fmt mode (Real.exp q) :=
  Model.AlgebraicRounding.roundSigned_eq_roundReal fmt mode
    (ElementaryComparison.compareExp_eq_real q)

/-- The rounding of `exp q` in the direction `mode`, computed as the module documentation
describes. -/
def round (fmt : FloatFormat) (mode : IEEERoundingMode) (q : ℚ) : Model fmt :=
  if 0 ≤ upperExponent fmt ∧ (upperExponent fmt : ℚ) ≤ q then
    Model.directedOverflow fmt false (mode.overflowRoundsMagnitudeUp false)
  else if lowerExponent fmt ≤ 0 ∧ q < (lowerExponent fmt : ℚ) then
    roundLocated fmt mode false 0 fmt.minSubnormalExponent false true
  else
    match (if fmt.isIEEE then roundEnclosed? fmt mode q else none) with
    | some result => result
    | none => roundCompared fmt mode q

/-- `round` is the rounding of the exponential, for every format descriptor and direction. -/
theorem round_eq (fmt : FloatFormat) (mode : IEEERoundingMode) (q : ℚ) :
    round fmt mode q = Model.roundReal fmt mode (Real.exp q) := by
  have hpos := Real.exp_pos (q : ℝ)
  have hsign : decide (Real.exp (q : ℝ) < 0) = false := decide_eq_false (not_lt.mpr hpos.le)
  unfold round
  split
  · rename_i hlarge
    rw [Model.roundReal_of_upperExponent_le mode
      (by rw [abs_of_pos hpos]; exact bpow_le_exp hlarge.1 hlarge.2), hsign]
  · split
    · rename_i hsmall
      rw [Model.roundReal_of_lt_lowerExponent mode hpos.ne'
        (by rw [abs_of_pos hpos]; exact exp_lt_bpow hsmall.1 hsmall.2), hsign]
    · split
      · rename_i result hresult
        split at hresult
        · rename_i hfmt
          exact (roundReal_eq_of_roundEnclosed? hfmt hresult).symm
        · simp at hresult
      · exact roundCompared_eq fmt mode q

end ExpOracle

/-- The oracle for `exp`, for every format descriptor and rounding direction: `check` compares
the bit pattern of `result` with the result that `Spec.exp` prescribes, which for a finite nonzero
input is `ExpOracle.round`, and accepts every NaN for a NaN input. -/
def expOracle (fmt : FloatFormat) : Oracle (Spec.exp fmt) where
  check mode input result :=
    -- Decoding first leaves a single test of the encoding on the path of a finite input.
    match Model.toRat? input with
    | some q =>
        if q = 0 then ExpOracle.sameBits result (Model.posOne fmt)
        else ExpOracle.sameBits result (ExpOracle.round fmt mode q)
    | none =>
        if input.isNaN then result.isNaN && (Model.canonicalNaN fmt).isNaN
        else if input.isInfinite then
          ExpOracle.sameBits result (if input.signBit then Model.posZero fmt else Model.posInf fmt)
        else false
  sound mode input result h := by
    simp only [Spec.eval, Spec.exp, Option.getD_none]
    split at h
    · rename_i q hq
      have hfinite := Model.Algebraic.isFinite_of_toRat?_eq_some hq
      have hreal := Model.Algebraic.toReal_of_toRat?_eq_some hq
      simp only [Model.isNaN_eq_false_of_isFinite_eq_true input hfinite,
        Model.isInfinite_eq_false_of_isFinite_eq_true input hfinite, Bool.false_eq_true,
        ↓reduceIte]
      split at h
      · rename_i hzero
        have hisZero : input.isZero = true :=
          (Model.isZero_eq_true_iff_toReal_eq_zero input hfinite).mpr (by simp [hreal, hzero])
        simp only [hisZero, ↓reduceIte]
        exact .inl (ExpOracle.eq_of_sameBits h)
      · rename_i hzero
        have hisZero : input.isZero = false := by
          rw [← Bool.not_eq_true, Model.isZero_eq_true_iff_toReal_eq_zero input hfinite, hreal]
          exact_mod_cast hzero
        simp only [hisZero, hreal, Bool.false_eq_true, ↓reduceIte, ← ExpOracle.round_eq]
        exact .inl (ExpOracle.eq_of_sameBits h)
    · split at h
      · rename_i hnan
        simp only [hnan, ↓reduceIte]
        exact .inr (Bool.and_eq_true_iff.mp h)
      · rename_i hnan
        simp only [hnan]
        split at h
        · rename_i hinf
          simp only [hinf, ↓reduceIte]
          exact .inl (ExpOracle.eq_of_sameBits h)
        · exact absurd h Bool.false_ne_true

/-- On a finite nonzero input, with exact value `q`, the oracle accepts the correctly rounded
exponential and nothing else. -/
theorem expOracle_check_iff {mode : IEEERoundingMode} {input result : Model fmt} {q : ℚ}
    (hq : Model.toRat? input = some q) (hne : q ≠ 0) :
    (expOracle fmt).check mode input result = true ↔
      result = Model.roundReal fmt mode (Real.exp q) := by
  simp only [expOracle, hq, hne, ↓reduceIte, ExpOracle.round_eq]
  exact ⟨ExpOracle.eq_of_sameBits, fun h => by simp [h, ExpOracle.sameBits]⟩

end LibcMath
