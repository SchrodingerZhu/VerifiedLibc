import LibcMath.Kernels.Exp2f.Statement

/-!
# `exp2f` (`float_eval`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp2f.Proof.FloatEval

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp2f.Generated

/-- **Open.** Prove fast `exp2f` (`float_eval`) executes without C++ undefined behavior. -/
theorem exp2fFloatEval_defined : Exp2fFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Exp2f.Proof.FloatEval.exp2fFloatEval_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2fFloatEval_defined

end LibcMath.Kernels.Exp2f.Proof.FloatEval
