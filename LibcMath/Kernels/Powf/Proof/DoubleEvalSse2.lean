import LibcMath.Kernels.Powf.Statement

/-!
# `powf` (`double_eval_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Powf.Proof.DoubleEvalSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Powf.Generated

/-- **Open.** Prove `powf` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem powfDoubleEvalSse2_correctlyRounded : PowfDoubleEvalSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Powf.Proof.DoubleEvalSse2.powfDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms powfDoubleEvalSse2_correctlyRounded

end LibcMath.Kernels.Powf.Proof.DoubleEvalSse2
