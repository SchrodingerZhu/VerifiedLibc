import LibcMath.Kernels.Asinhf.Statement

/-!
# `asinhf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Asinhf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Asinhf.Generated

/-- **Open.** Prove `asinhf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem asinhfAvx2Fma_correctlyRounded : AsinhfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Asinhf.Proof.Avx2Fma.asinhfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms asinhfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Asinhf.Proof.Avx2Fma
