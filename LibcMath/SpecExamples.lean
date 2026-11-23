import LibcMath.Spec

/-!
# Checks of the rounding and decoding definitions on concrete binary32 values
-/

namespace LibcMath

open Format

private theorem log_two_eq {x : ℝ} {e : ℤ} (hlo : (2 : ℝ) ^ e ≤ x) (hhi : x < 2 ^ (e + 1)) :
    Int.log 2 x = e := by
  have hx : 0 < x := lt_of_lt_of_le (by positivity) hlo
  have h₁ := (Int.zpow_le_iff_le_log one_lt_two hx).mp (by exact_mod_cast hlo)
  have h₂ := (Int.lt_zpow_iff_log_lt one_lt_two hx).mp (by exact_mod_cast hhi)
  omega

/-- `0x3FC00000` is `1.5`. -/
example : binary32.decode 0x3FC00000#32 = .num 1.5 := by
  have : (0x3FC00000#32).msb = false := by decide
  norm_num [decode, binary32, emax, emin, width]
  exact this

/-- `0x80000001` is the negative number of least magnitude, `-2 ^ (-149)`. -/
example : binary32.decode 0x80000001#32 = .num (-2 ^ (-149 : ℤ)) := by
  have : (0x80000001#32).msb = true := by decide
  norm_num [decode, binary32, emax, emin, width]
  exact this

example : binary32.decode 0x7F800000#32 = .inf false := by
  have : (0x7F800000#32).msb = false := by decide
  norm_num [decode, binary32, emax, emin, width]
  exact this

private theorem ulpExp_one_add : binary32.ulpExp (1 + 2 ^ (-24 : ℤ)) = -23 := by
  have : Int.log 2 |(1 + 2 ^ (-24 : ℤ) : ℝ)| = 0 := by
    rw [abs_of_pos (by positivity)]
    exact log_two_eq (by norm_num) (by norm_num)
  rw [ulpExp, this]
  norm_num [binary32, emin, emax]

/-- `1 + 2 ^ (-24)` lies halfway between `1` and its successor `1 + 2 ^ (-23)`. To nearest it
rounds to `1`, whose significand is even; upward it rounds to the successor. -/
example : binary32.round .nearestEven (1 + 2 ^ (-24 : ℤ)) = .num 1 := by
  have hq : ((1 + 2 ^ (-24 : ℤ)) / 2 ^ (-23 : ℤ) : ℝ) = 8388608 + 1 / 2 := by norm_num
  have hfloor : ⌊(8388608 + 1 / 2 : ℝ)⌋ = 8388608 := by
    rw [Int.floor_eq_iff]; norm_num
  have hr : binary32.roundUnbounded .nearestEven (1 + 2 ^ (-24 : ℤ)) = 1 := by
    rw [roundUnbounded, ulpExp_one_add, hq, Mode.roundInt, hfloor]
    norm_num [show Even (8388608 : ℤ) from ⟨4194304, by norm_num⟩]
  simp only [Format.round, hr]
  norm_num [maxFinite, binary32, emax]

example : binary32.round .upward (1 + 2 ^ (-24 : ℤ)) = .num (1 + 2 ^ (-23 : ℤ)) := by
  have hq : ((1 + 2 ^ (-24 : ℤ)) / 2 ^ (-23 : ℤ) : ℝ) = 8388608 + 1 / 2 := by norm_num
  have hceil : ⌈(8388608 + 1 / 2 : ℝ)⌉ = 8388609 := by
    rw [Int.ceil_eq_iff]; norm_num
  have hr : binary32.roundUnbounded .upward (1 + 2 ^ (-24 : ℤ)) = 1 + 2 ^ (-23 : ℤ) := by
    rw [roundUnbounded, ulpExp_one_add, hq, Mode.roundInt, hceil]
    norm_num
  simp only [Format.round, hr]
  norm_num [maxFinite, binary32, emax]

end LibcMath
