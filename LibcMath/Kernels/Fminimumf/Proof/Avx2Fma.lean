import LibcMath.Kernels.Fminimumf.Statement

/-!
# `fminimumf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fminimumf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fminimumf.Generated

/-- **Open.** Prove `fminimumf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem fminimumfAvx2Fma_correctlyRounded : FminimumfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fminimumf.Proof.Avx2Fma.fminimumfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fminimumfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Fminimumf.Proof.Avx2Fma
