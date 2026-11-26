import LibcMath.Kernels.Isnanf.Statement

/-!
# `isnanf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Isnanf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Isnanf.Generated

/-- **Open.** Prove `isnanf` (`sse42`) matches IEEE NaN classification. -/
theorem isnanfSse42_correct : IsnanfSse42Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Isnanf.Proof.Sse42.isnanfSse42_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms isnanfSse42_correct

end LibcMath.Kernels.Isnanf.Proof.Sse42
