import LibcMath.Kernels.Fmaxf.Statement

/-!
# `fmaxf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fmaxf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaxf.Generated

/-- **Open.** Prove `fmaxf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem fmaxfAvx2Fma_correctlyRounded : FmaxfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaxf.Proof.Avx2Fma.fmaxfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmaxfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Fmaxf.Proof.Avx2Fma
