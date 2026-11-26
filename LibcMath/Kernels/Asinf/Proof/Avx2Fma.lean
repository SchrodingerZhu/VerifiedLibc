import LibcMath.Kernels.Asinf.Statement

/-!
# `asinf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Asinf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinf.Generated

/-- **Open.** Prove `asinf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem asinfAvx2Fma_correctlyRounded : AsinfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinf.Proof.Avx2Fma.asinfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Asinf.Proof.Avx2Fma
