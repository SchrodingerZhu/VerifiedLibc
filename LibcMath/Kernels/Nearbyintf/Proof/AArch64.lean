import LibcMath.Kernels.Nearbyintf.Statement

/-!
# `nearbyintf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Nearbyintf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Nearbyintf.Generated

/-- **Open.** Prove `nearbyintf` (`aarch64`) is correctly rounded in all four C modes. -/
theorem nearbyintfAArch64_correctlyRounded : NearbyintfAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Nearbyintf.Proof.AArch64.nearbyintfAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nearbyintfAArch64_correctlyRounded

end LibcMath.Kernels.Nearbyintf.Proof.AArch64
