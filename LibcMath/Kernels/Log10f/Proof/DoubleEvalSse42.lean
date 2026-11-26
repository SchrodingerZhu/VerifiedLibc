import LibcMath.Kernels.Log10f.Statement

/-!
# `log10f` (`double_eval_sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Log10f.Proof.DoubleEvalSse42

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log10f.Generated

/-- **Open.** Prove `log10f` (`double_eval_sse42`) is correctly rounded in all four C modes. -/
theorem log10fDoubleEvalSse42_correctlyRounded : Log10fDoubleEvalSse42CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Log10f.Proof.DoubleEvalSse42.log10fDoubleEvalSse42_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log10fDoubleEvalSse42_correctlyRounded

end LibcMath.Kernels.Log10f.Proof.DoubleEvalSse42
