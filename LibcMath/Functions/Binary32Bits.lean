import LibcMath.Spec
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Adjacent.Proof.Order

/-!
# Bit patterns of binary32 and the values they denote

A block of consecutive binary32 bit patterns of one sign is an interval of real values. This file
states the classification of a binary32 value (`isNaN`, `isInfinite`, `isZero`, `isFinite`) as a
condition on its bit pattern `x.toNatBits`, and compares the real values of two finite values of
the same sign through their bit patterns: patterns below `0x80000000` denote nonnegative values
that increase with the pattern, and patterns from `0x80000000` denote nonpositive values that
decrease with it.
-/

namespace LibcMath.Binary32

open FloatLib.Floats.Formats.BinaryInterchange Model

variable (x y : Model FloatFormat.binary32)

/-- The bit pattern is the sign bit above the exponent and fraction fields. -/
private theorem toNatBits_eq :
    x.toNatBits = (if signBit x then 0x80000000 else 0) + magnitudeBits x ∧
      magnitudeBits x < 0x80000000 :=
  ⟨toNatBits_eq_magnitude x, magnitude_lt x⟩

private theorem magnitudeBits_eq :
    expField x < 256 ∧ fracField x < 0x800000 ∧
      magnitudeBits x = expField x * 0x800000 + fracField x :=
  ⟨expField_lt_pow2 x, fracField_lt_pow2 x, rfl⟩

/-- The sign bit is clear exactly on the patterns below `0x80000000`. -/
theorem signBit_eq_false_iff : signBit x = false ↔ x.toNatBits < 0x80000000 :=
  signBit_eq_false_iff_toNatBits_lt_signMaskNat x

/-- The sign bit is set exactly on the patterns from `0x80000000`. -/
theorem signBit_eq_true_iff : signBit x = true ↔ 0x80000000 ≤ x.toNatBits :=
  signBit_eq_true_iff_signMaskNat_le x

variable {x y}

/-- The NaNs are the patterns `0x7F800001`–`0x7FFFFFFF` and `0xFF800001`–`0xFFFFFFFF`. -/
theorem isNaN_iff :
    x.isNaN = true ↔
      (0x7F800001 ≤ x.toNatBits ∧ x.toNatBits ≤ 0x7FFFFFFF) ∨ 0xFF800001 ≤ x.toNatBits := by
  obtain ⟨hbits, -⟩ := toNatBits_eq x
  obtain ⟨he, hf, hm⟩ := magnitudeBits_eq x
  have hdef : x.isNaN = (expField x == 255 && fracField x != 0) := rfl
  rw [hdef]
  split at hbits <;> simp only [Bool.and_eq_true, beq_iff_eq, bne_iff_ne] <;> omega

/-- The finite values are the patterns up to `0x7F7FFFFF` and `0x80000000`–`0xFF7FFFFF`. -/
theorem isFinite_iff :
    x.isFinite = true ↔
      x.toNatBits ≤ 0x7F7FFFFF ∨ (0x80000000 ≤ x.toNatBits ∧ x.toNatBits ≤ 0xFF7FFFFF) := by
  obtain ⟨hbits, -⟩ := toNatBits_eq x
  obtain ⟨he, hf, hm⟩ := magnitudeBits_eq x
  have hdef : x.isFinite = (expField x != 255) := rfl
  rw [hdef]
  split at hbits <;> simp only [bne_iff_ne] <;> omega

/-- The infinities are the patterns `0x7F800000` and `0xFF800000`. -/
theorem isInfinite_iff :
    x.isInfinite = true ↔ x.toNatBits = 0x7F800000 ∨ x.toNatBits = 0xFF800000 := by
  obtain ⟨hbits, -⟩ := toNatBits_eq x
  obtain ⟨he, hf, hm⟩ := magnitudeBits_eq x
  have hdef : x.isInfinite = (expField x == 255 && fracField x == 0) := rfl
  rw [hdef]
  split at hbits <;> simp only [Bool.and_eq_true, beq_iff_eq] <;> omega

/-- The zeros are the patterns `0x00000000` and `0x80000000`. -/
theorem isZero_iff : x.isZero = true ↔ x.toNatBits = 0 ∨ x.toNatBits = 0x80000000 := by
  obtain ⟨hbits, -⟩ := toNatBits_eq x
  obtain ⟨he, hf, hm⟩ := magnitudeBits_eq x
  have hdef : x.isZero = (expField x == 0 && fracField x == 0) := rfl
  rw [hdef]
  split at hbits <;> simp only [Bool.and_eq_true, beq_iff_eq] <;> omega

/-- A pattern in a block that avoids the zeros, the infinities and the NaNs is none of them. -/
theorem classify_of_toNatBits_mem {first last : ℕ}
    (hblock : (0 < first ∧ last ≤ 0x7F7FFFFF) ∨ (0x80000000 < first ∧ last ≤ 0xFF7FFFFF))
    (hx : first ≤ x.toNatBits ∧ x.toNatBits ≤ last) :
    x.isNaN = false ∧ x.isInfinite = false ∧ x.isZero = false := by
  refine ⟨?_, ?_, ?_⟩ <;> apply Bool.eq_false_iff.mpr
  · rw [ne_eq, isNaN_iff]
    omega
  · rw [ne_eq, isInfinite_iff]
    omega
  · rw [ne_eq, isZero_iff]
    omega

/-- The adjacency rank of FloatLib in terms of the bit pattern. -/
private theorem adjacencyRank_eq (x : Model FloatFormat.binary32) :
    adjacencyRank x =
      if signBit x then 0x100000000 - x.toNatBits else 0x80000000 + x.toNatBits :=
  rfl

private theorem adjacencyRank_le_iff (hx : x.isFinite = true) (hy : y.isFinite = true) :
    adjacencyRank x ≤ adjacencyRank y ↔ x.toReal ≤ y.toReal := by
  rw [adjacencyRank_le_adjacencyRank_iff (isNaN_eq_false_of_isFinite_eq_true x hx)
    (isNaN_eq_false_of_isFinite_eq_true y hy), toEReal_eq_coe_toReal_of_isFinite x hx,
    toEReal_eq_coe_toReal_of_isFinite y hy, EReal.coe_le_coe_iff]

/-- Among the finite patterns below `0x80000000`, a larger pattern denotes a larger value. -/
theorem toReal_le_toReal_iff_of_nonneg (hx : x.toNatBits ≤ 0x7F7FFFFF)
    (hy : y.toNatBits ≤ 0x7F7FFFFF) : x.toReal ≤ y.toReal ↔ x.toNatBits ≤ y.toNatBits := by
  rw [← adjacencyRank_le_iff (isFinite_iff.mpr (.inl hx)) (isFinite_iff.mpr (.inl hy)),
    adjacencyRank_eq, adjacencyRank_eq, (signBit_eq_false_iff x).mpr (by omega),
    (signBit_eq_false_iff y).mpr (by omega)]
  simp

/-- Among the finite patterns from `0x80000000`, a larger pattern denotes a smaller value. -/
theorem toReal_le_toReal_iff_of_nonpos (hx : 0x80000000 ≤ x.toNatBits ∧ x.toNatBits ≤ 0xFF7FFFFF)
    (hy : 0x80000000 ≤ y.toNatBits ∧ y.toNatBits ≤ 0xFF7FFFFF) :
    x.toReal ≤ y.toReal ↔ y.toNatBits ≤ x.toNatBits := by
  rw [← adjacencyRank_le_iff (isFinite_iff.mpr (.inr hx)) (isFinite_iff.mpr (.inr hy)),
    adjacencyRank_eq, adjacencyRank_eq, (signBit_eq_true_iff x).mpr hx.1,
    (signBit_eq_true_iff y).mpr hy.1]
  simp only [ite_true]
  omega

/-- The pattern `bits`, as a value whose pattern is known. -/
private theorem toNatBits_ofNatBits {bits : ℕ} (hbits : bits ≤ 0xFFFFFFFF) :
    (ofNatBits bits : Model FloatFormat.binary32).toNatBits = bits :=
  toNatBits_ofNatBits_of_lt bits (Nat.lt_succ_of_le hbits)

/-- Comparison of a finite value below `0x80000000` with a pattern from below. -/
theorem toReal_ofNatBits_le_iff_of_nonneg {bits : ℕ} (hbits : bits ≤ 0x7F7FFFFF)
    (hx : x.toNatBits ≤ 0x7F7FFFFF) :
    (ofNatBits bits : Model FloatFormat.binary32).toReal ≤ x.toReal ↔ bits ≤ x.toNatBits := by
  have h := toNatBits_ofNatBits (bits := bits) (by omega)
  rw [toReal_le_toReal_iff_of_nonneg (by omega) hx, h]

/-- Comparison of a finite value below `0x80000000` with a pattern from above. -/
theorem toReal_le_ofNatBits_iff_of_nonneg {bits : ℕ} (hbits : bits ≤ 0x7F7FFFFF)
    (hx : x.toNatBits ≤ 0x7F7FFFFF) :
    x.toReal ≤ (ofNatBits bits : Model FloatFormat.binary32).toReal ↔ x.toNatBits ≤ bits := by
  have h := toNatBits_ofNatBits (bits := bits) (by omega)
  rw [toReal_le_toReal_iff_of_nonneg hx (by omega), h]

/-- Comparison of a finite value from `0x80000000` with a pattern from below. -/
theorem toReal_ofNatBits_le_iff_of_nonpos {bits : ℕ}
    (hbits : 0x80000000 ≤ bits ∧ bits ≤ 0xFF7FFFFF)
    (hx : 0x80000000 ≤ x.toNatBits ∧ x.toNatBits ≤ 0xFF7FFFFF) :
    (ofNatBits bits : Model FloatFormat.binary32).toReal ≤ x.toReal ↔ x.toNatBits ≤ bits := by
  have h := toNatBits_ofNatBits (bits := bits) (by omega)
  rw [toReal_le_toReal_iff_of_nonpos (by omega) hx, h]

/-- Comparison of a finite value from `0x80000000` with a pattern from above. -/
theorem toReal_le_ofNatBits_iff_of_nonpos {bits : ℕ}
    (hbits : 0x80000000 ≤ bits ∧ bits ≤ 0xFF7FFFFF)
    (hx : 0x80000000 ≤ x.toNatBits ∧ x.toNatBits ≤ 0xFF7FFFFF) :
    x.toReal ≤ (ofNatBits bits : Model FloatFormat.binary32).toReal ↔ bits ≤ x.toNatBits := by
  have h := toNatBits_ofNatBits (bits := bits) (by omega)
  rw [toReal_le_toReal_iff_of_nonpos hx (by omega), h]

private theorem toReal_ofNatBits_zero :
    (ofNatBits 0 : Model FloatFormat.binary32).toReal = 0 :=
  toReal_eq_zero_of_isZero _ (by decide +kernel)

private theorem toReal_ofNatBits_negZero :
    (ofNatBits 0x80000000 : Model FloatFormat.binary32).toReal = 0 :=
  toReal_eq_zero_of_isZero _ (by decide +kernel)

/-- The finite values that denote positive reals are the patterns `0x00000001`–`0x7F7FFFFF`. -/
theorem toReal_pos_iff (hx : x.isFinite = true) :
    0 < x.toReal ↔ 0 < x.toNatBits ∧ x.toNatBits ≤ 0x7F7FFFFF := by
  constructor
  · intro hpos
    have hsign := (signBit_eq_false_iff x).mp (signBit_eq_false_of_toReal_pos hx hpos)
    have hfinite := isFinite_iff.mp hx
    refine ⟨Nat.pos_of_ne_zero fun hzero => ?_, by omega⟩
    rw [← ofNatBits_toNatBits x, hzero, toReal_ofNatBits_zero] at hpos
    exact lt_irrefl _ hpos
  · rintro ⟨hpos, hfinite⟩
    rw [← toReal_ofNatBits_zero, ← not_le, toReal_le_toReal_iff_of_nonneg hfinite
      (by rw [toNatBits_ofNatBits (by omega)]; omega), toNatBits_ofNatBits (by omega)]
    omega

/-- The finite values that denote negative reals are the patterns `0x80000001`–`0xFF7FFFFF`. -/
theorem toReal_neg_iff (hx : x.isFinite = true) :
    x.toReal < 0 ↔ 0x80000000 < x.toNatBits ∧ x.toNatBits ≤ 0xFF7FFFFF := by
  constructor
  · intro hneg
    have hsign := (signBit_eq_true_iff x).mp (signBit_eq_true_of_toReal_neg hneg)
    have hfinite := isFinite_iff.mp hx
    refine ⟨lt_of_le_of_ne hsign fun hzero => ?_, by omega⟩
    rw [← ofNatBits_toNatBits x, ← hzero, toReal_ofNatBits_negZero] at hneg
    exact lt_irrefl _ hneg
  · rintro ⟨hneg, hfinite⟩
    rw [← toReal_ofNatBits_negZero, ← not_le, toReal_le_toReal_iff_of_nonpos
      (by rw [toNatBits_ofNatBits (by omega)]; omega) ⟨hneg.le, hfinite⟩,
      toNatBits_ofNatBits (by omega)]
    omega

end LibcMath.Binary32
