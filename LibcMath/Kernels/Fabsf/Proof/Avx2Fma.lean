import LibcMath.Kernels.Fabsf.Statement

/-!
# `fabsf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fabsf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fabsf.Generated

/-- **Open.** Prove `fabsf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem fabsfAvx2Fma_correctlyRounded : FabsfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fabsf.Proof.Avx2Fma.fabsfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fabsfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Fabsf.Proof.Avx2Fma
