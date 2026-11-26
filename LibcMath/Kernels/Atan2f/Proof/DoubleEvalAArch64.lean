import LibcMath.Kernels.Atan2f.Statement

/-!
# `atan2f` (`double_eval_aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Atan2f.Proof.DoubleEvalAArch64

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atan2f.Generated

/-- **Open.** Prove `atan2f` (`double_eval_aarch64`) is correctly rounded in all four C modes. -/
theorem atan2fDoubleEvalAArch64_correctlyRounded : Atan2fDoubleEvalAArch64CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Atan2f.Proof.DoubleEvalAArch64.atan2fDoubleEvalAArch64_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms atan2fDoubleEvalAArch64_correctlyRounded

end LibcMath.Kernels.Atan2f.Proof.DoubleEvalAArch64
