import LibcMath.Kernels.Sinf.Statement

/-!
# `sinf` (`double_eval_aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sinf.Proof.DoubleEvalAArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinf.Generated

/-- **Open.** Prove `sinf` (`double_eval_aarch64`) is correctly rounded in all four C modes. -/
theorem sinfDoubleEvalAArch64_correctlyRounded : SinfDoubleEvalAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sinf.Proof.DoubleEvalAArch64.sinfDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinfDoubleEvalAArch64_correctlyRounded

end LibcMath.Kernels.Sinf.Proof.DoubleEvalAArch64
