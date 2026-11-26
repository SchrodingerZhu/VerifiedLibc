import LibcMath.Kernels.Iscanonicalf.Statement

/-!
# `iscanonicalf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Iscanonicalf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Iscanonicalf.Generated

/-- **Open.** Prove `iscanonicalf` (`sse42`) matches IEEE canonical encoding predicate. -/
theorem iscanonicalfSse42_correct : IscanonicalfSse42Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Iscanonicalf.Proof.Sse42.iscanonicalfSse42_correct' depends on axioms: [sorryAx]
-/
#guard_msgs in
#print axioms iscanonicalfSse42_correct

end LibcMath.Kernels.Iscanonicalf.Proof.Sse42
