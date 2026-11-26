import LibcMath.Kernels.Acosf.Statement

/-!
# `acosf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Acosf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acosf.Generated

/-- **Open.** Prove `acosf` (`sse42`) is correctly rounded in all four C modes. -/
theorem acosfSse42_correctlyRounded : AcosfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acosf.Proof.Sse42.acosfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acosfSse42_correctlyRounded

end LibcMath.Kernels.Acosf.Proof.Sse42
