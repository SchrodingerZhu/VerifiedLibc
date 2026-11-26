import LibcMath.Kernels.Cosf.Statement

/-!
# `cosf` (`double_eval_avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Cosf.Proof.DoubleEvalAvx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cosf.Generated

/-- **Open.** Prove `cosf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem cosfDoubleEvalAvx2Fma_correctlyRounded : CosfDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Cosf.Proof.DoubleEvalAvx2Fma.cosfDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cosfDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Cosf.Proof.DoubleEvalAvx2Fma
