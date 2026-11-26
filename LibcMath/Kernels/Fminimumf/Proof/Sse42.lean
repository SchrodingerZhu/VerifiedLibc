import LibcMath.Kernels.Fminimumf.Statement

/-!
# `fminimumf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fminimumf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fminimumf.Generated

/-- **Open.** Prove `fminimumf` (`sse42`) is correctly rounded in all four C modes. -/
theorem fminimumfSse42_correctlyRounded : FminimumfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fminimumf.Proof.Sse42.fminimumfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimumfSse42_correctlyRounded

end LibcMath.Kernels.Fminimumf.Proof.Sse42
