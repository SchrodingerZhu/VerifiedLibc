import LibcMath.Kernels.FminimumMagNumf.Statement

/-!
# `fminimum_mag_numf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FminimumMagNumf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumMagNumf.Generated

/-- **Open.** Prove `fminimum_mag_numf` (`sse42`) is correctly rounded in all four C modes.
-/
theorem fminimum_mag_numfSse42_correctlyRounded :
    FminimumMagNumfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumMagNumf.Proof.Sse42.fminimum_mag_numfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_mag_numfSse42_correctlyRounded

end LibcMath.Kernels.FminimumMagNumf.Proof.Sse42
