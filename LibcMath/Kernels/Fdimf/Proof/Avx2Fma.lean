import LibcMath.Kernels.Fdimf.Statement

/-!
# `fdimf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fdimf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fdimf.Generated

/-- **Open.** Prove `fdimf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem fdimfAvx2Fma_correctlyRounded : FdimfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fdimf.Proof.Avx2Fma.fdimfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fdimfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Fdimf.Proof.Avx2Fma
