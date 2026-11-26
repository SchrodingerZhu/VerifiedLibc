import LibcMath.Kernels.Acoshf.Statement

/-!
# `acoshf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Acoshf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acoshf.Generated

/-- **Open.** Prove `acoshf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem acoshfAvx2Fma_correctlyRounded : AcoshfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acoshf.Proof.Avx2Fma.acoshfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acoshfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Acoshf.Proof.Avx2Fma
