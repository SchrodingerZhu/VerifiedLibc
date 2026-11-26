import LibcMath.Kernels.Rsqrtf.Statement

/-!
# `rsqrtf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Rsqrtf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Rsqrtf.Generated

/-- **Open.** Prove `rsqrtf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem rsqrtfAvx2Fma_correctlyRounded : RsqrtfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Rsqrtf.Proof.Avx2Fma.rsqrtfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms rsqrtfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Rsqrtf.Proof.Avx2Fma
