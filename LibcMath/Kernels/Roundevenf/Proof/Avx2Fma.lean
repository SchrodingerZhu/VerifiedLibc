import LibcMath.Kernels.Roundevenf.Statement

/-!
# `roundevenf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Roundevenf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Roundevenf.Generated

/-- **Open.** Prove `roundevenf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem roundevenfAvx2Fma_correctlyRounded : RoundevenfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Roundevenf.Proof.Avx2Fma.roundevenfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms roundevenfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Roundevenf.Proof.Avx2Fma
