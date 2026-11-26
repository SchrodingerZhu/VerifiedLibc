import LibcMath.Kernels.Iscanonicalf.Statement

/-!
# `iscanonicalf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Iscanonicalf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Iscanonicalf.Generated

/-- **Open.** Prove `iscanonicalf` (`aarch64`) matches IEEE canonical encoding predicate. -/
theorem iscanonicalfAArch64_correct : IscanonicalfAArch64Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Iscanonicalf.Proof.AArch64.iscanonicalfAArch64_correct' depends on axioms: [sorryAx]
-/
#guard_msgs in
#print axioms iscanonicalfAArch64_correct

end LibcMath.Kernels.Iscanonicalf.Proof.AArch64
