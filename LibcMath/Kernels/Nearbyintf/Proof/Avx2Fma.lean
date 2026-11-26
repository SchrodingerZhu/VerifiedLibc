import LibcMath.Kernels.Nearbyintf.Statement

/-!
# `nearbyintf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Nearbyintf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Nearbyintf.Generated

/-- **Open.** Prove `nearbyintf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem nearbyintfAvx2Fma_correctlyRounded : NearbyintfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Nearbyintf.Proof.Avx2Fma.nearbyintfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nearbyintfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Nearbyintf.Proof.Avx2Fma
