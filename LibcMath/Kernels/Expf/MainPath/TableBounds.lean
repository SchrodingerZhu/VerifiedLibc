import LibcMath.Kernels.Expf.Generated.DoubleEval
import LibcMath.Testing.Oracle.ExpReduced

/-!
# Relative error bounds for the lookup tables of `expf`

`Generated.DoubleEval.EXP_M1` stores 195 binary64 approximations to `exp (i - 104)` (`0 ≤ i < 195`),
and `Generated.DoubleEval.EXP_M2` stores 128 binary64 approximations to `exp (j / 128)` for
`0 ≤ j < 128`.

This file proves that every entry of both tables is finite, strictly positive, and within a
relative error of `2⁻⁵³` of the true exponential:

* `expM1_bounds`: for `i < 195`,
  `|EXP_M1[i].toReal - Real.exp ((i : ℤ) - 104)| ≤ (1 / 2 ^ 53) * Real.exp ((i : ℤ) - 104)`.
* `expM2_bounds`: for `j < 128`,
  `|EXP_M2[j].toReal - Real.exp (j / 128)| ≤ (1 / 2 ^ 53) * Real.exp (j / 128)`.

## How the bounds are proved

Each table entry `v` is decoded into an exact dyadic `d` via `Model.toDyadic?` (establishing
finiteness and positivity), and `ExpOracle.reducedEnclosure?` encloses `Real.exp q` on a binary
grid `[I.lo, I.hi] * 2 ^ (m - 64)` using a pre-checked 80-bit enclosure of `log 2` and a
degree-22 fixed-point Horner evaluation. Scaling `d` to the same exponent `m - 64` reduces the
relative error bound to two pure integer inequalities checked across all 195 + 128 entries by
`decide +kernel`.
-/

namespace LibcMath.Kernels.Expf.MainPath.TableBounds

open FloatLib.Floats.Formats.BinaryInterchange
open FloatLib.Numerics
open Interval.BinaryGrid (value scale scale_eq_pow)

/-- `EXP_M1` has 195 entries. -/
@[simp] theorem expM1_size : Generated.DoubleEval.EXP_M1.size = 195 := by decide +kernel

/-- `EXP_M2` has 128 entries. -/
@[simp] theorem expM2_size : Generated.DoubleEval.EXP_M2.size = 128 := by decide +kernel

/-- Entry 104 of `EXP_M1` is exact `1.0` (`exp 0`). -/
theorem expM1_104 :
    Generated.DoubleEval.EXP_M1[104]'(by rw [expM1_size]; decide) = Model.posOne .binary64 := by
  decide +kernel

/-- Entry 0 of `EXP_M2` is exact `1.0` (`exp 0`). -/
theorem expM2_0 :
    Generated.DoubleEval.EXP_M2[0]'(by rw [expM2_size]; decide) = Model.posOne .binary64 := by
  decide +kernel

/-- Lookup at index 104 of `EXP_M1` returns `some 1.0`. -/
theorem expM1_104_getElem? :
    Generated.DoubleEval.EXP_M1[104]? = some (Model.posOne .binary64) := by
  rw [Array.getElem?_eq_getElem (by rw [expM1_size]; decide), expM1_104]

/-- Lookup at index 0 of `EXP_M2` returns `some 1.0`. -/
theorem expM2_0_getElem? :
    Generated.DoubleEval.EXP_M2[0]? = some (Model.posOne .binary64) := by
  rw [Array.getElem?_eq_getElem (by rw [expM2_size]; decide), expM2_0]

/-! ## Kernel-checked table verification -/

/-- Fixed-point reduction parameters for certifying the 64-bit table entries: 64 fractional bits,
16 guard bits, degree 22, with the 80-bit `log 2` enclosure pre-evaluated once. -/
private def tableReduction : ExpOracle.Reduction where
  precision := 64
  guard := 16
  degree := 22
  scale := 18446744073709551616
  logTwo := ⟨837963523372001241319907, 837963523372001241319908⟩
  degree_pos := by decide
  scale_eq := by decide
  logTwo_eq := by decide +kernel

/-- Check that `v` is a finite positive binary64 value within `2⁻⁵³` relative error of every real
in the enclosure `ExpOracle.reducedEnclosure? r q`. -/
private def checkEntry (r : ExpOracle.Reduction) (q : ℚ) (v : Model .binary64) : Bool :=
  match ExpOracle.reducedEnclosure? r q, Model.toDyadic? v with
  | some (m, I), some d =>
      let expDiff : ℤ := d.exponent + (r.precision : ℤ) - m
      if !d.negative && 0 < d.significand && 0 < I.lo && 0 ≤ expDiff then
        let vScaled : ℤ := Int.ofNat (d.significand <<< expDiff.toNat)
        decide ((vScaled - I.lo) * 9007199254740992 ≤ I.lo) &&
          decide ((I.hi - vScaled) * 9007199254740992 ≤ I.lo)
      else
        false
  | _, _ => false

/-- Linearly check `checkEntry` along a list of table entries indexed from `start`. -/
private def checkList (r : ExpOracle.Reduction) (qOf : ℕ → ℚ) :
    ℕ → List (Model .binary64) → Bool
  | _, [] => true
  | i, v :: vs => checkEntry r (qOf i) v && checkList r qOf (i + 1) vs

private theorem checkList_eq_true {r : ExpOracle.Reduction} {qOf : ℕ → ℚ}
    {start : ℕ} {l : List (Model .binary64)}
    (h : checkList r qOf start l = true) {i : ℕ} (hi : i < l.length) :
    checkEntry r (qOf (start + i)) l[i] = true := by
  induction l generalizing start i with
  | nil => simp at hi
  | cons v vs ih =>
      simp only [checkList, Bool.and_eq_true] at h
      cases i with
      | zero => simpa using h.1
      | succ k =>
          have hk : k < vs.length := by simpa using hi
          simpa [Nat.add_assoc, Nat.add_comm 1 k] using ih h.2 hk

private theorem value_mul_zpow (p : ℕ) (m : ℤ) (z : ℤ) :
    value p z * (2 : ℝ) ^ m = (z : ℝ) * (2 : ℝ) ^ (m - (p : ℤ)) := by
  have hscale : (scale p : ℝ) = (2 : ℝ) ^ (p : ℤ) := by
    rw [scale_eq_pow]
    push_cast
    exact (zpow_natCast (2 : ℝ) p).symm
  rw [value, hscale, zpow_sub₀ (by norm_num : (2 : ℝ) ≠ 0)]
  ring

private theorem bounds_of_checkEntry {r : ExpOracle.Reduction} {q : ℚ} {v : Model .binary64}
    (h : checkEntry r q v = true) :
    v.isFinite = true ∧
    0 < v.toReal ∧
    |v.toReal - Real.exp (q : ℝ)| ≤ (1 / 2 ^ 53 : ℝ) * Real.exp (q : ℝ) := by
  unfold checkEntry at h
  cases hred : ExpOracle.reducedEnclosure? r q with
  | none => simp [hred] at h
  | some p =>
      rcases p with ⟨m, I⟩
      cases hd : Model.toDyadic? v with
      | none => simp [hred, hd] at h
      | some d =>
          simp only [hred, hd] at h
          split at h
          · rename_i hcond
            simp only [Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq] at hcond h
            obtain ⟨⟨⟨hneg, hsig⟩, hlo_pos⟩, hdiff⟩ := hcond
            obtain ⟨hupper, hlower⟩ := h
            have hfin : v.isFinite = true := Model.isFinite_eq_true_of_toDyadic?_some hd
            have hreal : v.toReal = d.toReal := by rw [Model.toReal_eq, hd]
            have hpos : 0 < v.toReal := by
              rw [hreal]
              exact Model.Dyadic.toReal_pos_of_negative_eq_false hneg hsig.ne'
            have hS_pos : (0 : ℝ) < (2 : ℝ) ^ (m - (r.precision : ℤ)) :=
              zpow_pos (by norm_num) _
            set k : ℕ := (d.exponent + (r.precision : ℤ) - m).toNat
            set vScaled : ℤ := Int.ofNat (d.significand <<< k)
            have hk : (k : ℤ) = d.exponent + (r.precision : ℤ) - m :=
              Int.toNat_of_nonneg hdiff
            have hexp_eq : d.exponent = (k : ℤ) + (m - (r.precision : ℤ)) := by omega
            have hv_scaled :
                v.toReal = (vScaled : ℝ) * (2 : ℝ) ^ (m - (r.precision : ℤ)) := by
              rw [hreal]
              have hd_real : d.toReal = (d.significand : ℝ) * (2 : ℝ) ^ d.exponent := by
                rw [Model.Dyadic.toReal_eq_signedSignificand,
                  FloatLib.Floats.Formats.Flocq.bpow_binaryRadix]
                simp [FloatLib.Numerics.Dyadic.signedSignificand, hneg]
              rw [hd_real, hexp_eq, zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0), zpow_natCast]
              have hcast : (vScaled : ℝ) = (d.significand : ℝ) * (2 : ℝ) ^ k := by
                simp only [vScaled, Int.ofNat_eq_natCast, Int.cast_natCast, Nat.shiftLeft_eq]
                push_cast
                rfl
              rw [hcast]
              ring
            obtain ⟨hlo_enc, hhi_enc⟩ := ExpOracle.contains_reducedEnclosure? hred
            rw [value_mul_zpow] at hlo_enc hhi_enc
            have hupperR :
                ((vScaled : ℝ) - (I.lo : ℝ)) * (2 : ℝ) ^ 53 ≤ (I.lo : ℝ) := by
              have hc : (((vScaled - I.lo) * 9007199254740992 : ℤ) : ℝ) ≤ (I.lo : ℝ) := by
                exact_mod_cast hupper
              push_cast at hc
              linarith
            have hlowerR :
                ((I.hi : ℝ) - (vScaled : ℝ)) * (2 : ℝ) ^ 53 ≤ (I.lo : ℝ) := by
              have hc : (((I.hi - vScaled) * 9007199254740992 : ℤ) : ℝ) ≤ (I.lo : ℝ) := by
                exact_mod_cast hlower
              push_cast at hc
              linarith
            have h2p53 : (0 : ℝ) < (2 : ℝ) ^ 53 := by positivity
            have hsub_le :
                v.toReal - Real.exp (q : ℝ) ≤ (1 / 2 ^ 53 : ℝ) * Real.exp (q : ℝ) := by
              have h1 : (vScaled : ℝ) - (I.lo : ℝ) ≤ (1 / 2 ^ 53 : ℝ) * (I.lo : ℝ) := by
                have := (le_div_iff₀ h2p53).mpr hupperR
                linarith
              have h2 := mul_le_mul_of_nonneg_right h1 hS_pos.le
              rw [sub_mul, ← hv_scaled, mul_assoc] at h2
              have h3 : (1 / 2 ^ 53 : ℝ) * ((I.lo : ℝ) * (2 : ℝ) ^ (m - (r.precision : ℤ))) ≤
                  (1 / 2 ^ 53 : ℝ) * Real.exp (q : ℝ) := by
                gcongr
              linarith
            have hneg_le :
                Real.exp (q : ℝ) - v.toReal ≤ (1 / 2 ^ 53 : ℝ) * Real.exp (q : ℝ) := by
              have h1 : (I.hi : ℝ) - (vScaled : ℝ) ≤ (1 / 2 ^ 53 : ℝ) * (I.lo : ℝ) := by
                have := (le_div_iff₀ h2p53).mpr hlowerR
                linarith
              have h2 := mul_le_mul_of_nonneg_right h1 hS_pos.le
              rw [sub_mul, ← hv_scaled, mul_assoc] at h2
              have h3 : (1 / 2 ^ 53 : ℝ) * ((I.lo : ℝ) * (2 : ℝ) ^ (m - (r.precision : ℤ))) ≤
                  (1 / 2 ^ 53 : ℝ) * Real.exp (q : ℝ) := by
                gcongr
              linarith
            refine ⟨hfin, hpos, abs_le.mpr ⟨by linarith, by linarith⟩⟩
          · simp at h

private def expM1Arg (i : ℕ) : ℚ :=
  Rat.ofInt ((i : ℤ) - 104)

private def expM2Arg (j : ℕ) : ℚ :=
  Rat.divInt (j : ℤ) 128

private theorem checkList_expM1 :
    checkList tableReduction expM1Arg 0 Generated.DoubleEval.EXP_M1.toList = true := by
  decide +kernel

private theorem checkList_expM2 :
    checkList tableReduction expM2Arg 0 Generated.DoubleEval.EXP_M2.toList = true := by
  decide +kernel

/-! ## Exported table bounds -/

/-- Every entry `EXP_M1[i]` (`i < 195`) is finite, positive, and within relative error `2⁻⁵³` of
`exp (i - 104)`. -/
theorem expM1_bounds (i : ℕ) (hi : i < 195) :
    let v := Generated.DoubleEval.EXP_M1[i]'(by rw [expM1_size]; exact hi)
    v.isFinite = true ∧
    0 < v.toReal ∧
    |v.toReal - Real.exp ((i : ℤ) - 104 : ℝ)| ≤
      (1 / 2 ^ 53 : ℝ) * Real.exp ((i : ℤ) - 104 : ℝ) := by
  have hi' : i < Generated.DoubleEval.EXP_M1.toList.length := by
    simpa [expM1_size] using hi
  have hcheck := checkList_eq_true checkList_expM1 hi'
  simp only [Nat.zero_add] at hcheck
  have hbounds := bounds_of_checkEntry hcheck
  have harg : (expM1Arg i : ℝ) = ((i : ℤ) - 104 : ℝ) := by
    simp [expM1Arg]
  simpa [harg] using hbounds

/-- Every entry `EXP_M2[j]` (`j < 128`) is finite, positive, and within relative error `2⁻⁵³` of
`exp (j / 128)`. -/
theorem expM2_bounds (j : ℕ) (hj : j < 128) :
    let v := Generated.DoubleEval.EXP_M2[j]'(by rw [expM2_size]; exact hj)
    v.isFinite = true ∧
    0 < v.toReal ∧
    |v.toReal - Real.exp ((j : ℝ) / 128)| ≤
      (1 / 2 ^ 53 : ℝ) * Real.exp ((j : ℝ) / 128) := by
  have hj' : j < Generated.DoubleEval.EXP_M2.toList.length := by
    simpa [expM2_size] using hj
  have hcheck := checkList_eq_true checkList_expM2 hj'
  simp only [Nat.zero_add] at hcheck
  have hbounds := bounds_of_checkEntry hcheck
  have harg : (expM2Arg j : ℝ) = (j : ℝ) / 128 := by
    simp [expM2Arg, Rat.divInt_eq_div]
  simpa [harg] using hbounds

/-- An in-bounds index `i < 195` succeeds in `EXP_M1[i]?`. -/
theorem expM1_getElem?_eq_some {i : ℕ} (hi : i < 195) :
    Generated.DoubleEval.EXP_M1[i]? =
      some (Generated.DoubleEval.EXP_M1[i]'(by rw [expM1_size]; exact hi)) :=
  Array.getElem?_eq_getElem (by rw [expM1_size]; exact hi)

/-- An in-bounds index `j < 128` succeeds in `EXP_M2[j]?`. -/
theorem expM2_getElem?_eq_some {j : ℕ} (hj : j < 128) :
    Generated.DoubleEval.EXP_M2[j]? =
      some (Generated.DoubleEval.EXP_M2[j]'(by rw [expM2_size]; exact hj)) :=
  Array.getElem?_eq_getElem (by rw [expM2_size]; exact hj)

/-- Bounds for a lookup `EXP_M1[i]? = some v`. -/
theorem expM1_getElem?_bounds {i : ℕ} {v : Model .binary64}
    (hv : Generated.DoubleEval.EXP_M1[i]? = some v) :
    v.isFinite = true ∧
    0 < v.toReal ∧
    |v.toReal - Real.exp ((i : ℤ) - 104 : ℝ)| ≤
      (1 / 2 ^ 53 : ℝ) * Real.exp ((i : ℤ) - 104 : ℝ) := by
  rw [Array.getElem?_eq_some_iff] at hv
  obtain ⟨hi, rfl⟩ := hv
  exact expM1_bounds i (by simpa [expM1_size] using hi)

/-- Bounds for a lookup `EXP_M2[j]? = some v`. -/
theorem expM2_getElem?_bounds {j : ℕ} {v : Model .binary64}
    (hv : Generated.DoubleEval.EXP_M2[j]? = some v) :
    v.isFinite = true ∧
    0 < v.toReal ∧
    |v.toReal - Real.exp ((j : ℝ) / 128)| ≤
      (1 / 2 ^ 53 : ℝ) * Real.exp ((j : ℝ) / 128) := by
  rw [Array.getElem?_eq_some_iff] at hv
  obtain ⟨hj, rfl⟩ := hv
  exact expM2_bounds j (by simpa [expM2_size] using hj)

/--
info: 'LibcMath.Kernels.Expf.MainPath.TableBounds.expM1_bounds' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms expM1_bounds

/--
info: 'LibcMath.Kernels.Expf.MainPath.TableBounds.expM2_bounds' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms expM2_bounds

end LibcMath.Kernels.Expf.MainPath.TableBounds
