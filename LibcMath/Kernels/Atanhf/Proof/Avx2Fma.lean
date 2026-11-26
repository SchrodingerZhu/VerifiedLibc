import LibcMath.Kernels.Atanhf.Statement

/-!
# `atanhf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Atanhf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atanhf.Generated

/-- **Open.** Prove `atanhf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem atanhfAvx2Fma_correctlyRounded : AtanhfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Atanhf.Proof.Avx2Fma.atanhfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atanhfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Atanhf.Proof.Avx2Fma
