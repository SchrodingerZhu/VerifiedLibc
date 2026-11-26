import LibcMath.Kernels.Roundf.Statement

/-!
# `roundf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Roundf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Roundf.Generated

/-- **Open.** Prove `roundf` (`sse42`) is correctly rounded in all four C modes. -/
theorem roundfSse42_correctlyRounded : RoundfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Roundf.Proof.Sse42.roundfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms roundfSse42_correctlyRounded

end LibcMath.Kernels.Roundf.Proof.Sse42
