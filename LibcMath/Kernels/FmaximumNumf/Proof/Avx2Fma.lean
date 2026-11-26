import LibcMath.Kernels.FmaximumNumf.Statement

/-!
# `fmaximum_numf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FmaximumNumf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumNumf.Generated

/-- **Open.** Prove `fmaximum_numf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem fmaximum_numfAvx2Fma_correctlyRounded : FmaximumNumfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FmaximumNumf.Proof.Avx2Fma.fmaximum_numfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximum_numfAvx2Fma_correctlyRounded

end LibcMath.Kernels.FmaximumNumf.Proof.Avx2Fma
