import LibcMath.Kernels.Issignalingf.Statement

/-!
# `issignalingf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Issignalingf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Issignalingf.Generated

/-- **Open.** Prove `issignalingf` (`generic_sse2`) matches IEEE sNaN test. -/
theorem issignalingfGenericSse2_correct : IssignalingfGenericSse2Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Issignalingf.Proof.GenericSse2.issignalingfGenericSse2_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms issignalingfGenericSse2_correct

end LibcMath.Kernels.Issignalingf.Proof.GenericSse2
