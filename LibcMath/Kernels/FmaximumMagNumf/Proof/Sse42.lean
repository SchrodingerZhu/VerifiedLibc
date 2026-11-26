import LibcMath.Kernels.FmaximumMagNumf.Statement

/-!
# `fmaximum_mag_numf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FmaximumMagNumf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FmaximumMagNumf.Generated

/-- **Open.** Prove `fmaximum_mag_numf` (`sse42`) is correctly rounded in all four C modes.
-/
theorem fmaximum_mag_numfSse42_correctlyRounded :
    FmaximumMagNumfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FmaximumMagNumf.Proof.Sse42.fmaximum_mag_numfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximum_mag_numfSse42_correctlyRounded

end LibcMath.Kernels.FmaximumMagNumf.Proof.Sse42
