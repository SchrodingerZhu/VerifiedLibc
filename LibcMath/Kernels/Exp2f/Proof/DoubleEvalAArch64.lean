import LibcMath.Kernels.Exp2f.Statement

/-!
# `exp2f` (`double_eval_aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp2f.Proof.DoubleEvalAArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp2f.Generated

/-- **Open.** Prove `exp2f` (`double_eval_aarch64`) is correctly rounded across all four modes. -/
theorem exp2fDoubleEvalAArch64_correctlyRounded : Exp2fDoubleEvalAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp2f.Proof.DoubleEvalAArch64.exp2fDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2fDoubleEvalAArch64_correctlyRounded

end LibcMath.Kernels.Exp2f.Proof.DoubleEvalAArch64
