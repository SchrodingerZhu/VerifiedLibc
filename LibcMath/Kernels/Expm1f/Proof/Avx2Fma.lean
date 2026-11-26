import LibcMath.Kernels.Expm1f.Statement

/-!
# `expm1f` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Expm1f.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Expm1f.Generated

/-- **Open.** Prove `expm1f` (`avx2_fma`) is correctly rounded across all four C rounding modes. -/
theorem expm1fAvx2Fma_correctlyRounded : Expm1fAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Expm1f.Proof.Avx2Fma.expm1fAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expm1fAvx2Fma_correctlyRounded

end LibcMath.Kernels.Expm1f.Proof.Avx2Fma
