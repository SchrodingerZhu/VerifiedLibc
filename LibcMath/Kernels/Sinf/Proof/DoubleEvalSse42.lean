import LibcMath.Kernels.Sinf.Statement

/-!
# `sinf` (`double_eval_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sinf.Proof.DoubleEvalSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinf.Generated

/-- **Open.** Prove `sinf` (`double_eval_sse42`) is correctly rounded in all four C modes. -/
theorem sinfDoubleEvalSse42_correctlyRounded : SinfDoubleEvalSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sinf.Proof.DoubleEvalSse42.sinfDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinfDoubleEvalSse42_correctlyRounded

end LibcMath.Kernels.Sinf.Proof.DoubleEvalSse42
