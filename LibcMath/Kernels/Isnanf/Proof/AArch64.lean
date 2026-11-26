import LibcMath.Kernels.Isnanf.Statement

/-!
# `isnanf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Isnanf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Isnanf.Generated

/-- **Open.** Prove `isnanf` (`aarch64`) matches IEEE NaN classification. -/
theorem isnanfAArch64_correct : IsnanfAArch64Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Isnanf.Proof.AArch64.isnanfAArch64_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms isnanfAArch64_correct

end LibcMath.Kernels.Isnanf.Proof.AArch64
