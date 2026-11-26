import LibcMath.Kernels.Issignalingf.Statement

/-!
# `issignalingf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Issignalingf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Issignalingf.Generated

/-- **Open.** Prove `issignalingf` (`sse42`) matches IEEE sNaN test. -/
theorem issignalingfSse42_correct : IssignalingfSse42Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Issignalingf.Proof.Sse42.issignalingfSse42_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms issignalingfSse42_correct

end LibcMath.Kernels.Issignalingf.Proof.Sse42
