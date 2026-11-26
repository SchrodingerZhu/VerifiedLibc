import LibcMath.Kernels.Fmaxf.Statement

/-!
# `fmaxf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fmaxf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaxf.Generated

/-- **Open.** Prove `fmaxf` (`sse42`) is correctly rounded in all four C modes. -/
theorem fmaxfSse42_correctlyRounded : FmaxfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaxf.Proof.Sse42.fmaxfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaxfSse42_correctlyRounded

end LibcMath.Kernels.Fmaxf.Proof.Sse42
