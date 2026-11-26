import LibcMath.Kernels.Roundevenf.Statement

/-!
# `roundevenf` (`builtin_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Roundevenf.Proof.BuiltinSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Roundevenf.Generated

/-- **Open.** Prove `roundevenf` (`builtin_sse42`) is correctly rounded in all four C modes. -/
theorem roundevenfBuiltinSse42_correctlyRounded : RoundevenfBuiltinSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Roundevenf.Proof.BuiltinSse42.roundevenfBuiltinSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms roundevenfBuiltinSse42_correctlyRounded

end LibcMath.Kernels.Roundevenf.Proof.BuiltinSse42
