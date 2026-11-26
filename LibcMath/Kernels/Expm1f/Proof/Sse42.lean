import LibcMath.Kernels.Expm1f.Statement

/-!
# `expm1f` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Expm1f.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Expm1f.Generated

/-- **Open.** Prove `expm1f` (`sse42`) is correctly rounded across all four C rounding modes. -/
theorem expm1fSse42_correctlyRounded : Expm1fSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Expm1f.Proof.Sse42.expm1fSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms expm1fSse42_correctlyRounded

end LibcMath.Kernels.Expm1f.Proof.Sse42
