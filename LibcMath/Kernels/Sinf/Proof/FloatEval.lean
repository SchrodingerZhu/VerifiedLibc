import LibcMath.Kernels.Sinf.Statement

/-!
# `sinf` (`float_eval`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sinf.Proof.FloatEval

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinf.Generated

/-- **Open.** Prove `sinf` (`float_eval`) executes without C++ undefined behavior. -/
theorem sinfFloatEval_defined : SinfFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Sinf.Proof.FloatEval.sinfFloatEval_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinfFloatEval_defined

end LibcMath.Kernels.Sinf.Proof.FloatEval
