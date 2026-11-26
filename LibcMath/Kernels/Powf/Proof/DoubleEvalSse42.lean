import LibcMath.Kernels.Powf.Statement

/-!
# `powf` (`double_eval_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Powf.Proof.DoubleEvalSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Powf.Generated

/-- **Open.** Prove `powf` (`double_eval_sse42`) is correctly rounded in all four C modes. -/
theorem powfDoubleEvalSse42_correctlyRounded : PowfDoubleEvalSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Powf.Proof.DoubleEvalSse42.powfDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms powfDoubleEvalSse42_correctlyRounded

end LibcMath.Kernels.Powf.Proof.DoubleEvalSse42
