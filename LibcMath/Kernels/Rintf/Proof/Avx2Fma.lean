import LibcMath.Kernels.Rintf.Statement

/-!
# `rintf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Rintf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Rintf.Generated

/-- **Open.** Prove `rintf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem rintfAvx2Fma_correctlyRounded : RintfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Rintf.Proof.Avx2Fma.rintfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms rintfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Rintf.Proof.Avx2Fma
