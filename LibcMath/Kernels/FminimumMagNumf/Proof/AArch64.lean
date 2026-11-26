import LibcMath.Kernels.FminimumMagNumf.Statement

/-!
# `fminimum_mag_numf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FminimumMagNumf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumMagNumf.Generated

/-- **Open.** Prove `fminimum_mag_numf` (`aarch64`) is correctly rounded in all four C modes.
-/
theorem fminimum_mag_numfAArch64_correctlyRounded :
    FminimumMagNumfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumMagNumf.Proof.AArch64.fminimum_mag_numfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_mag_numfAArch64_correctlyRounded

end LibcMath.Kernels.FminimumMagNumf.Proof.AArch64
