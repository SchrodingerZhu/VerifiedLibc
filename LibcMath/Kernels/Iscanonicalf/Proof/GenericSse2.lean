import LibcMath.Kernels.Iscanonicalf.Statement

/-!
# `iscanonicalf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Iscanonicalf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Iscanonicalf.Generated

/-- **Open.** Prove `iscanonicalf` (`generic_sse2`) matches IEEE canonical encoding predicate. -/
theorem iscanonicalfGenericSse2_correct : IscanonicalfGenericSse2Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Iscanonicalf.Proof.GenericSse2.iscanonicalfGenericSse2_correct' depends on axioms: [sorryAx]
-/
#guard_msgs in
#print axioms iscanonicalfGenericSse2_correct

end LibcMath.Kernels.Iscanonicalf.Proof.GenericSse2
