import LibcMath.Kernels.Remainderf.Statement

/-!
# `remainderf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Remainderf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Remainderf.Generated

/-- **Open.** Prove `remainderf` (`aarch64`) matches IEEE remainder in all C modes. -/
theorem remainderfAArch64_correctlyRounded : RemainderfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Remainderf.Proof.AArch64.remainderfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms remainderfAArch64_correctlyRounded

end LibcMath.Kernels.Remainderf.Proof.AArch64
