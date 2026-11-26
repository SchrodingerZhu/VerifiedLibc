import LibcMath.Kernels.Atanf.Statement

/-!
# `atanf` (`float_eval`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Atanf.Proof.FloatEval

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atanf.Generated

/-- **Open.** Prove `atanf` (`float_eval`) executes without C++ undefined behavior. -/
theorem atanfFloatEval_defined : AtanfFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Atanf.Proof.FloatEval.atanfFloatEval_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atanfFloatEval_defined

end LibcMath.Kernels.Atanf.Proof.FloatEval
