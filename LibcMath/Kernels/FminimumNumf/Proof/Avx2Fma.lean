import LibcMath.Kernels.FminimumNumf.Statement

/-!
# `fminimum_numf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FminimumNumf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumNumf.Generated

/-- **Open.** Prove `fminimum_numf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem fminimum_numfAvx2Fma_correctlyRounded : FminimumNumfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumNumf.Proof.Avx2Fma.fminimum_numfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_numfAvx2Fma_correctlyRounded

end LibcMath.Kernels.FminimumNumf.Proof.Avx2Fma
