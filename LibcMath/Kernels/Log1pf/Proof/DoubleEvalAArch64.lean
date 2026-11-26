import LibcMath.Kernels.Log1pf.Statement

/-!
# `log1pf` (`double_eval_aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Log1pf.Proof.DoubleEvalAArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log1pf.Generated

/-- **Open.** Prove `log1pf` (`double_eval_aarch64`) is correctly rounded in all four C modes. -/
theorem log1pfDoubleEvalAArch64_correctlyRounded : Log1pfDoubleEvalAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Log1pf.Proof.DoubleEvalAArch64.log1pfDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log1pfDoubleEvalAArch64_correctlyRounded

end LibcMath.Kernels.Log1pf.Proof.DoubleEvalAArch64
