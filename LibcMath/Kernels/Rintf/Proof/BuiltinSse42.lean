import LibcMath.Kernels.Rintf.Statement

/-!
# `rintf` (`builtin_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Rintf.Proof.BuiltinSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Rintf.Generated

/-- **Open.** Prove `rintf` (`builtin_sse42`) is correctly rounded in all four C modes. -/
theorem rintfBuiltinSse42_correctlyRounded : RintfBuiltinSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Rintf.Proof.BuiltinSse42.rintfBuiltinSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms rintfBuiltinSse42_correctlyRounded

end LibcMath.Kernels.Rintf.Proof.BuiltinSse42
