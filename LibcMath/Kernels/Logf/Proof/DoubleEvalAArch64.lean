import LibcMath.Kernels.Logf.Statement

/-!
# `logf` (`double_eval_aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Logf.Proof.DoubleEvalAArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Logf.Generated

/-- **Open.** Prove `logf` (`double_eval_aarch64`) is correctly rounded in all four C modes. -/
theorem logfDoubleEvalAArch64_correctlyRounded : LogfDoubleEvalAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Logf.Proof.DoubleEvalAArch64.logfDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms logfDoubleEvalAArch64_correctlyRounded

end LibcMath.Kernels.Logf.Proof.DoubleEvalAArch64
