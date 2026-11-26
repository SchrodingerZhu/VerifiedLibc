import LibcMath.Kernels.Totalordermagf.Statement

/-!
# `totalordermagf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Totalordermagf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Totalordermagf.Generated

/-- **Open.** Prove `totalordermagf` (`aarch64`) matches `FloatLibSpec.totalordermag`. -/
theorem totalordermagfAArch64_correct : TotalordermagfAArch64Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Totalordermagf.Proof.AArch64.totalordermagfAArch64_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms totalordermagfAArch64_correct

end LibcMath.Kernels.Totalordermagf.Proof.AArch64
