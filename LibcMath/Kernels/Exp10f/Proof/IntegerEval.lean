import LibcMath.Kernels.Exp10f.Statement

/-!
# `exp10f` (`integer_eval`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp10f.Proof.IntegerEval

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp10f.Generated

/-- **Open.** Prove `exp10f` (`integer_eval`) is correctly rounded in round-to-nearest-even. -/
theorem exp10fIntegerEval_correctlyRounded : Exp10fIntegerEvalCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp10f.Proof.IntegerEval.exp10fIntegerEval_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10fIntegerEval_correctlyRounded

end LibcMath.Kernels.Exp10f.Proof.IntegerEval
