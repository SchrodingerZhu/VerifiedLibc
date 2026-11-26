import LibcMath.Kernels.Log2f.Statement

/-!
# `log2f` (`double_eval_avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Log2f.Proof.DoubleEvalAvx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log2f.Generated

/-- **Open.** Prove `log2f` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem log2fDoubleEvalAvx2Fma_correctlyRounded : Log2fDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Log2f.Proof.DoubleEvalAvx2Fma.log2fDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log2fDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Log2f.Proof.DoubleEvalAvx2Fma
