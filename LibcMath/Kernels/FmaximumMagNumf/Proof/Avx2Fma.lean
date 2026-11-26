import LibcMath.Kernels.FmaximumMagNumf.Statement

/-!
# `fmaximum_mag_numf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FmaximumMagNumf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumMagNumf.Generated

/-- **Open.** Prove `fmaximum_mag_numf` (`avx2_fma`) is correctly rounded in all four C modes.
-/
theorem fmaximum_mag_numfAvx2Fma_correctlyRounded :
    FmaximumMagNumfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FmaximumMagNumf.Proof.Avx2Fma.fmaximum_mag_numfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximum_mag_numfAvx2Fma_correctlyRounded

end LibcMath.Kernels.FmaximumMagNumf.Proof.Avx2Fma
