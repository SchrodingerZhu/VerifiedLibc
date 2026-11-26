import LibcMath.Kernels.Asinhf.Statement

/-!
# `asinhf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Asinhf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinhf.Generated

/-- **Open.** Prove `asinhf` (`sse42`) is correctly rounded in all four C modes. -/
theorem asinhfSse42_correctlyRounded : AsinhfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinhf.Proof.Sse42.asinhfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinhfSse42_correctlyRounded

end LibcMath.Kernels.Asinhf.Proof.Sse42
