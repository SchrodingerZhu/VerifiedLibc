import LibcMath.Kernels.Totalorderf.Statement

/-!
# `totalorderf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Totalorderf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Totalorderf.Generated

/-- **Open.** Prove `totalorderf` (`aarch64`) matches `FloatLibSpec.totalorder`. -/
theorem totalorderfAArch64_correct : TotalorderfAArch64Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Totalorderf.Proof.AArch64.totalorderfAArch64_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms totalorderfAArch64_correct

end LibcMath.Kernels.Totalorderf.Proof.AArch64
