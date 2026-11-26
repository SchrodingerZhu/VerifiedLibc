import LibcMath.Kernels.Tanf.Statement

/-!
# `tanf` (`float_eval`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Tanf.Proof.FloatEval

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanf.Generated

/-- **Open.** Prove `tanf` (`float_eval`) executes without C++ undefined behavior. -/
theorem tanfFloatEval_defined : TanfFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Tanf.Proof.FloatEval.tanfFloatEval_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanfFloatEval_defined

end LibcMath.Kernels.Tanf.Proof.FloatEval
