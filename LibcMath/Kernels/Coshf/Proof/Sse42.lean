import LibcMath.Kernels.Coshf.Statement

/-!
# `coshf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Coshf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Coshf.Generated

/-- **Open.** Prove `coshf` (`sse42`) is correctly rounded in all four C modes. -/
theorem coshfSse42_correctlyRounded : CoshfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Coshf.Proof.Sse42.coshfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms coshfSse42_correctlyRounded

end LibcMath.Kernels.Coshf.Proof.Sse42
