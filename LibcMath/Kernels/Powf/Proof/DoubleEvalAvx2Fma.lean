import LibcMath.Kernels.Powf.Statement

/-!
# `powf` (`double_eval_avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Powf.Proof.DoubleEvalAvx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Powf.Generated

/-- **Open.** Prove `powf` (`double_eval_avx2_fma`) is correctly rounded in all four C modes. -/
theorem powfDoubleEvalAvx2Fma_correctlyRounded : PowfDoubleEvalAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Powf.Proof.DoubleEvalAvx2Fma.powfDoubleEvalAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms powfDoubleEvalAvx2Fma_correctlyRounded

end LibcMath.Kernels.Powf.Proof.DoubleEvalAvx2Fma
