import LibcMath.Kernels.Fminf.Statement

/-!
# `fminf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fminf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fminf.Generated

/-- **Open.** Prove `fminf` (`sse42`) is correctly rounded in all four C modes. -/
theorem fminfSse42_correctlyRounded : FminfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fminf.Proof.Sse42.fminfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminfSse42_correctlyRounded

end LibcMath.Kernels.Fminf.Proof.Sse42
