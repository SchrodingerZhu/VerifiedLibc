import LibcMath.Kernels.Fmaximumf.Statement

/-!
# `fmaximumf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fmaximumf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaximumf.Generated

/-- **Open.** Prove `fmaximumf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem fmaximumfAvx2Fma_correctlyRounded : FmaximumfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaximumf.Proof.Avx2Fma.fmaximumfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaximumfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Fmaximumf.Proof.Avx2Fma
