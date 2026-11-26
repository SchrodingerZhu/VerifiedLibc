import LibcMath.Kernels.Isnanf.Statement

/-!
# `isnanf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Isnanf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Isnanf.Generated

/-- **Open.** Prove `isnanf` (`generic_sse2`) matches IEEE NaN classification. -/
theorem isnanfGenericSse2_correct : IsnanfGenericSse2Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Isnanf.Proof.GenericSse2.isnanfGenericSse2_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms isnanfGenericSse2_correct

end LibcMath.Kernels.Isnanf.Proof.GenericSse2
