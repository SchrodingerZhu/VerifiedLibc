import LibcMath.Kernels.Exp10f.Statement

/-!
# `exp10f` (`double_eval_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp10f.Proof.DoubleEvalSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp10f.Generated

/-- **Open.** Prove `exp10f` (`double_eval_sse2`) is correctly rounded across all four C modes. -/
theorem exp10fDoubleEvalSse2_correctlyRounded : Exp10fDoubleEvalSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp10f.Proof.DoubleEvalSse2.exp10fDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10fDoubleEvalSse2_correctlyRounded

end LibcMath.Kernels.Exp10f.Proof.DoubleEvalSse2
