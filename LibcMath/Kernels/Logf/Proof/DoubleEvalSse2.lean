import LibcMath.Kernels.Logf.Statement

/-!
# `logf` (`double_eval_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Logf.Proof.DoubleEvalSse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Logf.Generated

/-- **Open.** Prove `logf` (`double_eval_sse2`) is correctly rounded in all four C modes. -/
theorem logfDoubleEvalSse2_correctlyRounded : LogfDoubleEvalSse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Logf.Proof.DoubleEvalSse2.logfDoubleEvalSse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms logfDoubleEvalSse2_correctlyRounded

end LibcMath.Kernels.Logf.Proof.DoubleEvalSse2
