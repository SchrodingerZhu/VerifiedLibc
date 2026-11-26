import LibcMath.Kernels.Copysignf.Statement

/-!
# `copysignf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Copysignf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Copysignf.Generated

/-- **Open.** Prove `copysignf` (`sse42`) is correctly rounded in all four C modes. -/
theorem copysignfSse42_correctlyRounded : CopysignfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Copysignf.Proof.Sse42.copysignfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms copysignfSse42_correctlyRounded

end LibcMath.Kernels.Copysignf.Proof.Sse42
