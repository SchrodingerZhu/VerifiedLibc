import LibcMath.Kernels.Sincosf.Statement

/-!
# `sincosf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sincosf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Kernels.Sincosf.Generated

/-- **Open.** Prove `sincosf` (`sse42`) is correctly rounded in all four C modes. -/
theorem sincosfSse42_correctlyRounded : SincosfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sincosf.Proof.Sse42.sincosfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sincosfSse42_correctlyRounded

end LibcMath.Kernels.Sincosf.Proof.Sse42
