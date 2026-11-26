import LibcMath.Kernels.Exp10f.Statement

/-!
# `exp10f` (`double_eval_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp10f.Proof.DoubleEvalSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp10f.Generated

/-- **Open.** Prove `exp10f` (`double_eval_sse42`) is correctly rounded across all four modes. -/
theorem exp10fDoubleEvalSse42_correctlyRounded : Exp10fDoubleEvalSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp10f.Proof.DoubleEvalSse42.exp10fDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10fDoubleEvalSse42_correctlyRounded

end LibcMath.Kernels.Exp10f.Proof.DoubleEvalSse42
