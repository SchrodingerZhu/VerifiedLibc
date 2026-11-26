import LibcMath.Kernels.Log2f.Statement

/-!
# `log2f` (`double_eval_aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Log2f.Proof.DoubleEvalAArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Log2f.Generated

/-- **Open.** Prove `log2f` (`double_eval_aarch64`) is correctly rounded in all four C modes. -/
theorem log2fDoubleEvalAArch64_correctlyRounded : Log2fDoubleEvalAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Log2f.Proof.DoubleEvalAArch64.log2fDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms log2fDoubleEvalAArch64_correctlyRounded

end LibcMath.Kernels.Log2f.Proof.DoubleEvalAArch64
