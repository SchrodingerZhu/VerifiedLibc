import LibcMath.Kernels.Sinf.Statement

/-!
# `sinf` (`double_eval_avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sinf.Proof.DoubleEvalAvx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinf.Generated

/-- **Open.** Prove `sinf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem sinfDoubleEvalAvx2Fma_correctlyRounded : SinfDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sinf.Proof.DoubleEvalAvx2Fma.sinfDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinfDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Sinf.Proof.DoubleEvalAvx2Fma
