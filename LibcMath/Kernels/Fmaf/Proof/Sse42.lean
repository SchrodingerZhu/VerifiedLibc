import LibcMath.Kernels.Fmaf.Statement

/-!
# `fmaf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fmaf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaf.Generated

/-- **Open.** Prove `fmaf` (`sse42`) is correctly rounded in all four C modes. -/
theorem fmafSse42_correctlyRounded : FmafSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaf.Proof.Sse42.fmafSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmafSse42_correctlyRounded

end LibcMath.Kernels.Fmaf.Proof.Sse42
