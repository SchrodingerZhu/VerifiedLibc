import LibcMath.Kernels.Floorf.Statement

/-!
# `floorf` (`builtin_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Floorf.Proof.BuiltinSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Floorf.Generated

/-- **Open.** Prove `floorf` (`builtin_sse42`) is correctly rounded in all four C modes. -/
theorem floorfBuiltinSse42_correctlyRounded : FloorfBuiltinSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Floorf.Proof.BuiltinSse42.floorfBuiltinSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms floorfBuiltinSse42_correctlyRounded

end LibcMath.Kernels.Floorf.Proof.BuiltinSse42
