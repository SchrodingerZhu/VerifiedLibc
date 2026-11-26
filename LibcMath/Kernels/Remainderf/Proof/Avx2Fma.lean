import LibcMath.Kernels.Remainderf.Statement

/-!
# `remainderf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Remainderf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Remainderf.Generated

/-- **Open.** Prove `remainderf` (`avx2_fma`) matches IEEE remainder in all C modes. -/
theorem remainderfAvx2Fma_correctlyRounded : RemainderfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Remainderf.Proof.Avx2Fma.remainderfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms remainderfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Remainderf.Proof.Avx2Fma
