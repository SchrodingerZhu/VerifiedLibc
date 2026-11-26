import LibcMath.Kernels.Cosf.Statement

/-!
# `cosf` (`double_eval_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Cosf.Proof.DoubleEvalSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cosf.Generated

/-- **Open.** Prove `cosf` (`double_eval_sse42`) is correctly rounded in all four C modes. -/
theorem cosfDoubleEvalSse42_correctlyRounded : CosfDoubleEvalSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Cosf.Proof.DoubleEvalSse42.cosfDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cosfDoubleEvalSse42_correctlyRounded

end LibcMath.Kernels.Cosf.Proof.DoubleEvalSse42
