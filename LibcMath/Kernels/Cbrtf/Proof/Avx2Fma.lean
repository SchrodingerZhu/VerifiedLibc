import LibcMath.Kernels.Cbrtf.Statement

/-!
# `cbrtf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Cbrtf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cbrtf.Generated

/-- **Open.** Prove `cbrtf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem cbrtfAvx2Fma_correctlyRounded : CbrtfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Cbrtf.Proof.Avx2Fma.cbrtfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cbrtfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Cbrtf.Proof.Avx2Fma
