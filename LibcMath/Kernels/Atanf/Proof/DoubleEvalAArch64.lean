import LibcMath.Kernels.Atanf.Statement

/-!
# `atanf` (`double_eval_aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Atanf.Proof.DoubleEvalAArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atanf.Generated

/-- **Open.** Prove `atanf` (`double_eval_aarch64`) is correctly rounded in all four C modes. -/
theorem atanfDoubleEvalAArch64_correctlyRounded : AtanfDoubleEvalAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Atanf.Proof.DoubleEvalAArch64.atanfDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atanfDoubleEvalAArch64_correctlyRounded

end LibcMath.Kernels.Atanf.Proof.DoubleEvalAArch64
