import LibcMath.Kernels.Fabsf.Statement

/-!
# `fabsf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fabsf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fabsf.Generated

/-- **Open.** Prove `fabsf` (`sse42`) is correctly rounded in all four C modes. -/
theorem fabsfSse42_correctlyRounded : FabsfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fabsf.Proof.Sse42.fabsfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fabsfSse42_correctlyRounded

end LibcMath.Kernels.Fabsf.Proof.Sse42
