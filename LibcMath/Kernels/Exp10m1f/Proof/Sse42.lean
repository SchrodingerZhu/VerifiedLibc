import LibcMath.Kernels.Exp10m1f.Statement

/-!
# `exp10m1f` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp10m1f.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp10m1f.Generated

/-- **Open.** Prove `exp10m1f` (`sse42`) is correctly rounded across all four C rounding modes. -/
theorem exp10m1fSse42_correctlyRounded : Exp10m1fSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp10m1f.Proof.Sse42.exp10m1fSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10m1fSse42_correctlyRounded

end LibcMath.Kernels.Exp10m1f.Proof.Sse42
