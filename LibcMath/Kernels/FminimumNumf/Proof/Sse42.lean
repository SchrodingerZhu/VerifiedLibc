import LibcMath.Kernels.FminimumNumf.Statement

/-!
# `fminimum_numf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.FminimumNumf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.FminimumNumf.Generated

/-- **Open.** Prove `fminimum_numf` (`sse42`) is correctly rounded in all four C modes. -/
theorem fminimum_numfSse42_correctlyRounded : FminimumNumfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.FminimumNumf.Proof.Sse42.fminimum_numfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimum_numfSse42_correctlyRounded

end LibcMath.Kernels.FminimumNumf.Proof.Sse42
