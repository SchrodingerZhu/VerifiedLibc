import LibcMath.Kernels.Asinf.Statement

/-!
# `asinf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Asinf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinf.Generated

/-- **Open.** Prove `asinf` (`sse42`) is correctly rounded in all four C modes. -/
theorem asinfSse42_correctlyRounded : AsinfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinf.Proof.Sse42.asinfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinfSse42_correctlyRounded

end LibcMath.Kernels.Asinf.Proof.Sse42
