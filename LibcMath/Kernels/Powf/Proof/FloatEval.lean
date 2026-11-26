import LibcMath.Kernels.Powf.Statement

/-!
# `powf` (`float_eval`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Powf.Proof.FloatEval

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Powf.Generated

/-- **Open.** Prove `powf` (`float_eval`) executes without C++ undefined behavior. -/
theorem powfFloatEval_defined : PowfFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Powf.Proof.FloatEval.powfFloatEval_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms powfFloatEval_defined

end LibcMath.Kernels.Powf.Proof.FloatEval
