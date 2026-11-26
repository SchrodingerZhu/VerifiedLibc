import LibcMath.Kernels.Exp10f.Statement

/-!
# `exp10f` (`double_eval_avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp10f.Proof.DoubleEvalAvx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp10f.Generated

/-- **Open.** Prove `exp10f` (`double_eval_avx2_fma`) is correctly rounded across all modes. -/
theorem exp10fDoubleEvalAvx2Fma_correctlyRounded : Exp10fDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp10f.Proof.DoubleEvalAvx2Fma.exp10fDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10fDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Exp10f.Proof.DoubleEvalAvx2Fma
