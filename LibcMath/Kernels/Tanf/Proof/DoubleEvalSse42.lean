import LibcMath.Kernels.Tanf.Statement

/-!
# `tanf` (`double_eval_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Tanf.Proof.DoubleEvalSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanf.Generated

/-- **Open.** Prove `tanf` (`double_eval_sse42`) is correctly rounded in all four C modes. -/
theorem tanfDoubleEvalSse42_correctlyRounded : TanfDoubleEvalSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Tanf.Proof.DoubleEvalSse42.tanfDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanfDoubleEvalSse42_correctlyRounded

end LibcMath.Kernels.Tanf.Proof.DoubleEvalSse42
