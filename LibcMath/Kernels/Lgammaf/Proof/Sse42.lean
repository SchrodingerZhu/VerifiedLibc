import LibcMath.Kernels.Lgammaf.Statement

/-!
# `lgammaf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Lgammaf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Lgammaf.Generated

/-- **Open.** Prove `lgammaf` (`sse42`) is correctly rounded in all four C modes. -/
theorem lgammafSse42_correctlyRounded : LgammafSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Lgammaf.Proof.Sse42.lgammafSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms lgammafSse42_correctlyRounded

end LibcMath.Kernels.Lgammaf.Proof.Sse42
