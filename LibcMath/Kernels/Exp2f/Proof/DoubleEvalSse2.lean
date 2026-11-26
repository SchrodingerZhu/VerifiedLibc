import LibcMath.Kernels.Exp2f.Statement

/-!
# `exp2f` (`double_eval_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp2f.Proof.DoubleEvalSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp2f.Generated

/-- **Open.** Prove `exp2f` (`double_eval_sse2`) is correctly rounded across all four C modes. -/
theorem exp2fDoubleEvalSse2_correctlyRounded : Exp2fDoubleEvalSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp2f.Proof.DoubleEvalSse2.exp2fDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2fDoubleEvalSse2_correctlyRounded

end LibcMath.Kernels.Exp2f.Proof.DoubleEvalSse2
