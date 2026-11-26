import LibcMath.Kernels.Issignalingf.Statement

/-!
# `issignalingf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Issignalingf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Issignalingf.Generated

/-- **Open.** Prove `issignalingf` (`aarch64`) matches IEEE sNaN test. -/
theorem issignalingfAArch64_correct : IssignalingfAArch64Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Issignalingf.Proof.AArch64.issignalingfAArch64_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms issignalingfAArch64_correct

end LibcMath.Kernels.Issignalingf.Proof.AArch64
