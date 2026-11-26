import LibcMath.Kernels.Atan2f.Statement

/-!
# `atan2f` (`float_eval`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Atan2f.Proof.FloatEval

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atan2f.Generated

/-- **Open.** Prove `atan2f` (`float_eval`) executes without C++ undefined behavior. -/
theorem atan2fFloatEval_defined : Atan2fFloatEvalDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Atan2f.Proof.FloatEval.atan2fFloatEval_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atan2fFloatEval_defined

end LibcMath.Kernels.Atan2f.Proof.FloatEval
