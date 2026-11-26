import LibcMath.Kernels.Tanf.Statement

/-!
# `tanf` (`double_eval_aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Tanf.Proof.DoubleEvalAArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanf.Generated

/-- **Open.** Prove `tanf` (`double_eval_aarch64`) is correctly rounded in all four C modes. -/
theorem tanfDoubleEvalAArch64_correctlyRounded : TanfDoubleEvalAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Tanf.Proof.DoubleEvalAArch64.tanfDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms tanfDoubleEvalAArch64_correctlyRounded

end LibcMath.Kernels.Tanf.Proof.DoubleEvalAArch64
