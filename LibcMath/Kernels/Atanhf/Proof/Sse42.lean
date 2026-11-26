import LibcMath.Kernels.Atanhf.Statement

/-!
# `atanhf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Atanhf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atanhf.Generated

/-- **Open.** Prove `atanhf` (`sse42`) is correctly rounded in all four C modes. -/
theorem atanhfSse42_correctlyRounded : AtanhfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Atanhf.Proof.Sse42.atanhfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atanhfSse42_correctlyRounded

end LibcMath.Kernels.Atanhf.Proof.Sse42
