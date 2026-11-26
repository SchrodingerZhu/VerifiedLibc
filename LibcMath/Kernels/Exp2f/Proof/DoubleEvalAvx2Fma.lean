import LibcMath.Kernels.Exp2f.Statement

/-!
# `exp2f` (`double_eval_avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp2f.Proof.DoubleEvalAvx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp2f.Generated

/-- **Open.** Prove `exp2f` (`double_eval_avx2_fma`) is correctly rounded across all four modes. -/
theorem exp2fDoubleEvalAvx2Fma_correctlyRounded : Exp2fDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp2f.Proof.DoubleEvalAvx2Fma.exp2fDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2fDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Exp2f.Proof.DoubleEvalAvx2Fma
