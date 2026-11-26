import LibcMath.Kernels.Acoshf.Statement

/-!
# `acoshf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Acoshf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acoshf.Generated

/-- **Open.** Prove `acoshf` (`sse42`) is correctly rounded in all four C modes. -/
theorem acoshfSse42_correctlyRounded : AcoshfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acoshf.Proof.Sse42.acoshfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acoshfSse42_correctlyRounded

end LibcMath.Kernels.Acoshf.Proof.Sse42
