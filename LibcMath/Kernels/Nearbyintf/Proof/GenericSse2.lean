import LibcMath.Kernels.Nearbyintf.Statement

/-!
# `nearbyintf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Nearbyintf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Nearbyintf.Generated

/-- **Open.** Prove `nearbyintf` (`generic_sse2`) is correctly rounded in all four C modes. -/
theorem nearbyintfGenericSse2_correctlyRounded : NearbyintfGenericSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Nearbyintf.Proof.GenericSse2.nearbyintfGenericSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nearbyintfGenericSse2_correctlyRounded

end LibcMath.Kernels.Nearbyintf.Proof.GenericSse2
