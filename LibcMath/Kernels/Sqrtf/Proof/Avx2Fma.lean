import LibcMath.Kernels.Sqrtf.Statement

/-!
# `sqrtf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sqrtf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sqrtf.Generated

/-- **Open.** Prove `sqrtf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem sqrtfAvx2Fma_correctlyRounded : SqrtfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sqrtf.Proof.Avx2Fma.sqrtfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sqrtfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Sqrtf.Proof.Avx2Fma
