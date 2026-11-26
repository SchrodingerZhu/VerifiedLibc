import LibcMath.Kernels.FmaximumMagNumf.Statement

/-!
# `fmaximum_mag_numf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FmaximumMagNumf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumMagNumf.Generated

/-- **Open.** Prove `fmaximum_mag_numf` (`aarch64`) is correctly rounded in all four C modes.
-/
theorem fmaximum_mag_numfAArch64_correctlyRounded :
    FmaximumMagNumfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FmaximumMagNumf.Proof.AArch64.fmaximum_mag_numfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximum_mag_numfAArch64_correctlyRounded

end LibcMath.Kernels.FmaximumMagNumf.Proof.AArch64
