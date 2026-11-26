import LibcMath.Kernels.Exp10f.Statement

/-!
# `exp10f` (`double_eval_aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp10f.Proof.DoubleEvalAArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp10f.Generated

/-- **Open.** Prove `exp10f` (`double_eval_aarch64`) is correctly rounded across all modes. -/
theorem exp10fDoubleEvalAArch64_correctlyRounded : Exp10fDoubleEvalAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Exp10f.Proof.DoubleEvalAArch64.exp10fDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp10fDoubleEvalAArch64_correctlyRounded

end LibcMath.Kernels.Exp10f.Proof.DoubleEvalAArch64
