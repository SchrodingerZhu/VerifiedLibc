import LibcMath.Kernels.Cosf.Statement

/-!
# `cosf` (`float_eval`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Cosf.Proof.FloatEval

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cosf.Generated

/-- **Open.** Prove `cosf` (`float_eval`) executes without C++ undefined behavior. -/
theorem cosfFloatEval_defined : CosfFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Cosf.Proof.FloatEval.cosfFloatEval_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cosfFloatEval_defined

end LibcMath.Kernels.Cosf.Proof.FloatEval
