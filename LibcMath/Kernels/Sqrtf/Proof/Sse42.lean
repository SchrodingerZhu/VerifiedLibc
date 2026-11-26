import LibcMath.Kernels.Sqrtf.Statement

/-!
# `sqrtf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sqrtf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sqrtf.Generated

/-- **Open.** Prove `sqrtf` (`sse42`) is correctly rounded in all four C modes. -/
theorem sqrtfSse42_correctlyRounded : SqrtfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sqrtf.Proof.Sse42.sqrtfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sqrtfSse42_correctlyRounded

end LibcMath.Kernels.Sqrtf.Proof.Sse42
