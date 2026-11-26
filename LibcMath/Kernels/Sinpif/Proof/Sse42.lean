import LibcMath.Kernels.Sinpif.Statement

/-!
# `sinpif` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sinpif.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinpif.Generated

/-- **Open.** Prove `sinpif` (`sse42`) is correctly rounded in all four C modes. -/
theorem sinpifSse42_correctlyRounded : SinpifSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sinpif.Proof.Sse42.sinpifSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinpifSse42_correctlyRounded

end LibcMath.Kernels.Sinpif.Proof.Sse42
