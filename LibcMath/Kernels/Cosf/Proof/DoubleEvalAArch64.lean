import LibcMath.Kernels.Cosf.Statement

/-!
# `cosf` (`double_eval_aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Cosf.Proof.DoubleEvalAArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cosf.Generated

/-- **Open.** Prove `cosf` (`double_eval_aarch64`) is correctly rounded in all four C modes. -/
theorem cosfDoubleEvalAArch64_correctlyRounded : CosfDoubleEvalAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Cosf.Proof.DoubleEvalAArch64.cosfDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cosfDoubleEvalAArch64_correctlyRounded

end LibcMath.Kernels.Cosf.Proof.DoubleEvalAArch64
