import LibcMath.Kernels.Log10f.Statement

/-!
# `log10f` (`double_eval_aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Log10f.Proof.DoubleEvalAArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log10f.Generated

/-- **Open.** Prove `log10f` (`double_eval_aarch64`) is correctly rounded in all four C modes. -/
theorem log10fDoubleEvalAArch64_correctlyRounded : Log10fDoubleEvalAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Log10f.Proof.DoubleEvalAArch64.log10fDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log10fDoubleEvalAArch64_correctlyRounded

end LibcMath.Kernels.Log10f.Proof.DoubleEvalAArch64
