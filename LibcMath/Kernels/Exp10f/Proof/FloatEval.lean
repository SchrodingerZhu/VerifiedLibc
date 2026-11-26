import LibcMath.Kernels.Exp10f.Statement

/-!
# `exp10f` (`float_eval`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp10f.Proof.FloatEval

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp10f.Generated

/-- **Open.** Prove fast `exp10f` (`float_eval`) executes without C++ undefined behavior. -/
theorem exp10fFloatEval_defined : Exp10fFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Exp10f.Proof.FloatEval.exp10fFloatEval_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10fFloatEval_defined

end LibcMath.Kernels.Exp10f.Proof.FloatEval
