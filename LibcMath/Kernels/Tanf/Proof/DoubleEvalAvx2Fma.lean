import LibcMath.Kernels.Tanf.Statement

/-!
# `tanf` (`double_eval_avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Tanf.Proof.DoubleEvalAvx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanf.Generated

/-- **Open.** Prove `tanf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem tanfDoubleEvalAvx2Fma_correctlyRounded : TanfDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Tanf.Proof.DoubleEvalAvx2Fma.tanfDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanfDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Tanf.Proof.DoubleEvalAvx2Fma
