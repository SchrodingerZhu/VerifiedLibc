import LibcMath.Kernels.Exp2f.Statement

/-!
# `exp2f` (`integer_eval`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp2f.Proof.IntegerEval

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp2f.Generated

/-- **Open.** Prove `exp2f` (`integer_eval`) is correctly rounded in round-to-nearest-even. -/
theorem exp2fIntegerEval_correctlyRounded : Exp2fIntegerEvalCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp2f.Proof.IntegerEval.exp2fIntegerEval_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2fIntegerEval_correctlyRounded

end LibcMath.Kernels.Exp2f.Proof.IntegerEval
