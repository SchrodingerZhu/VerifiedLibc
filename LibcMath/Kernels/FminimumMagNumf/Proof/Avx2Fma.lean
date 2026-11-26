import LibcMath.Kernels.FminimumMagNumf.Statement

/-!
# `fminimum_mag_numf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FminimumMagNumf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumMagNumf.Generated

/-- **Open.** Prove `fminimum_mag_numf` (`avx2_fma`) is correctly rounded in all four C modes.
-/
theorem fminimum_mag_numfAvx2Fma_correctlyRounded :
    FminimumMagNumfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumMagNumf.Proof.Avx2Fma.fminimum_mag_numfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_mag_numfAvx2Fma_correctlyRounded

end LibcMath.Kernels.FminimumMagNumf.Proof.Avx2Fma
