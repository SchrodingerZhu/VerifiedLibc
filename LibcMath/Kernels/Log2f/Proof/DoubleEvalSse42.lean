import LibcMath.Kernels.Log2f.Statement

/-!
# `log2f` (`double_eval_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Log2f.Proof.DoubleEvalSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log2f.Generated

/-- **Open.** Prove `log2f` (`double_eval_sse42`) is correctly rounded in all four C modes. -/
theorem log2fDoubleEvalSse42_correctlyRounded : Log2fDoubleEvalSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Log2f.Proof.DoubleEvalSse42.log2fDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log2fDoubleEvalSse42_correctlyRounded

end LibcMath.Kernels.Log2f.Proof.DoubleEvalSse42
