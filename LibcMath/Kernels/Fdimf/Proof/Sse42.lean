import LibcMath.Kernels.Fdimf.Statement

/-!
# `fdimf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fdimf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fdimf.Generated

/-- **Open.** Prove `fdimf` (`sse42`) is correctly rounded in all four C modes. -/
theorem fdimfSse42_correctlyRounded : FdimfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fdimf.Proof.Sse42.fdimfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fdimfSse42_correctlyRounded

end LibcMath.Kernels.Fdimf.Proof.Sse42
