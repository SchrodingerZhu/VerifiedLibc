import LibcMath.Kernels.Atanf.Statement

/-!
# `atanf` (`double_eval_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Atanf.Proof.DoubleEvalSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atanf.Generated

/-- **Open.** Prove `atanf` (`double_eval_sse42`) is correctly rounded in all four C modes. -/
theorem atanfDoubleEvalSse42_correctlyRounded : AtanfDoubleEvalSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Atanf.Proof.DoubleEvalSse42.atanfDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atanfDoubleEvalSse42_correctlyRounded

end LibcMath.Kernels.Atanf.Proof.DoubleEvalSse42
