import LibcMath.Kernels.Truncf.Statement

/-!
# `truncf` (`builtin_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Truncf.Proof.BuiltinSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Truncf.Generated

/-- **Open.** Prove `truncf` (`builtin_sse42`) is correctly rounded in all four C modes. -/
theorem truncfBuiltinSse42_correctlyRounded : TruncfBuiltinSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Truncf.Proof.BuiltinSse42.truncfBuiltinSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms truncfBuiltinSse42_correctlyRounded

end LibcMath.Kernels.Truncf.Proof.BuiltinSse42
