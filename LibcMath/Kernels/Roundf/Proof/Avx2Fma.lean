import LibcMath.Kernels.Roundf.Statement

/-!
# `roundf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Roundf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Roundf.Generated

/-- **Open.** Prove `roundf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem roundfAvx2Fma_correctlyRounded : RoundfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Roundf.Proof.Avx2Fma.roundfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms roundfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Roundf.Proof.Avx2Fma
