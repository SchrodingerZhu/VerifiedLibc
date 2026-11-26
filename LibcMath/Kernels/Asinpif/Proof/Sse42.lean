import LibcMath.Kernels.Asinpif.Statement

/-!
# `asinpif` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Asinpif.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinpif.Generated

/-- **Open.** Prove `asinpif` (`sse42`) is correctly rounded in all four C modes. -/
theorem asinpifSse42_correctlyRounded : AsinpifSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinpif.Proof.Sse42.asinpifSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinpifSse42_correctlyRounded

end LibcMath.Kernels.Asinpif.Proof.Sse42
