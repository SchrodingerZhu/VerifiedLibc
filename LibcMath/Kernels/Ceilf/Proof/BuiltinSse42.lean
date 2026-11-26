import LibcMath.Kernels.Ceilf.Statement

/-!
# `ceilf` (`builtin_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ceilf.Proof.BuiltinSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Ceilf.Generated

/-- **Open.** Prove `ceilf` (`builtin_sse42`) is correctly rounded in all four C modes. -/
theorem ceilfBuiltinSse42_correctlyRounded : CeilfBuiltinSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Ceilf.Proof.BuiltinSse42.ceilfBuiltinSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ceilfBuiltinSse42_correctlyRounded

end LibcMath.Kernels.Ceilf.Proof.BuiltinSse42
