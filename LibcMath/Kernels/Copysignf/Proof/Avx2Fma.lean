import LibcMath.Kernels.Copysignf.Statement

/-!
# `copysignf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Copysignf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Copysignf.Generated

/-- **Open.** Prove `copysignf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem copysignfAvx2Fma_correctlyRounded : CopysignfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Copysignf.Proof.Avx2Fma.copysignfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms copysignfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Copysignf.Proof.Avx2Fma
