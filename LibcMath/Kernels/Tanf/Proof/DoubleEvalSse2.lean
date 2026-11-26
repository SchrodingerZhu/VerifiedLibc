import LibcMath.Kernels.Tanf.Statement

/-!
# `tanf` (`double_eval_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Tanf.Proof.DoubleEvalSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanf.Generated

/-- **Open.** Prove `tanf` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem tanfDoubleEvalSse2_correctlyRounded : TanfDoubleEvalSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Tanf.Proof.DoubleEvalSse2.tanfDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanfDoubleEvalSse2_correctlyRounded

end LibcMath.Kernels.Tanf.Proof.DoubleEvalSse2
