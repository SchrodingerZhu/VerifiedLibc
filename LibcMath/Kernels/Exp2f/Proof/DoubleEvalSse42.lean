import LibcMath.Kernels.Exp2f.Statement

/-!
# `exp2f` (`double_eval_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp2f.Proof.DoubleEvalSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp2f.Generated

/-- **Open.** Prove `exp2f` (`double_eval_sse42`) is correctly rounded across all four C modes. -/
theorem exp2fDoubleEvalSse42_correctlyRounded : Exp2fDoubleEvalSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp2f.Proof.DoubleEvalSse42.exp2fDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2fDoubleEvalSse42_correctlyRounded

end LibcMath.Kernels.Exp2f.Proof.DoubleEvalSse42
