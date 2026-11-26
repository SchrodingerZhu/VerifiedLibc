import LibcMath.Kernels.Remainderf.Statement

/-!
# `remainderf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Remainderf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Remainderf.Generated

/-- **Open.** Prove `remainderf` (`sse42`) matches IEEE remainder in all C modes. -/
theorem remainderfSse42_correctlyRounded : RemainderfSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Remainderf.Proof.Sse42.remainderfSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms remainderfSse42_correctlyRounded

end LibcMath.Kernels.Remainderf.Proof.Sse42
