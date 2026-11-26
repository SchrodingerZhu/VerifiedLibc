import LibcMath.Kernels.Cospif.Statement

/-!
# `cospif` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Cospif.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cospif.Generated

/-- **Open.** Prove `cospif` (`sse42`) is correctly rounded in all four C modes. -/
theorem cospifSse42_correctlyRounded : CospifSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Cospif.Proof.Sse42.cospifSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cospifSse42_correctlyRounded

end LibcMath.Kernels.Cospif.Proof.Sse42
