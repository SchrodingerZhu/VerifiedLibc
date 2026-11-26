import LibcMath.Kernels.Powf.Statement

/-!
# `powf` (`double_eval_aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Powf.Proof.DoubleEvalAArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Powf.Generated

/-- **Open.** Prove `powf` (`double_eval_aarch64`) is correctly rounded in all four C modes. -/
theorem powfDoubleEvalAArch64_correctlyRounded : PowfDoubleEvalAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Powf.Proof.DoubleEvalAArch64.powfDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms powfDoubleEvalAArch64_correctlyRounded

end LibcMath.Kernels.Powf.Proof.DoubleEvalAArch64
