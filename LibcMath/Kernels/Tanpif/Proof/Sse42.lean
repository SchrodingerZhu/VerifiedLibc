import LibcMath.Kernels.Tanpif.Statement

/-!
# `tanpif` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Tanpif.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanpif.Generated

/-- **Open.** Prove `tanpif` (`sse42`) is correctly rounded in all four C modes. -/
theorem tanpifSse42_correctlyRounded : TanpifSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Tanpif.Proof.Sse42.tanpifSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanpifSse42_correctlyRounded

end LibcMath.Kernels.Tanpif.Proof.Sse42
