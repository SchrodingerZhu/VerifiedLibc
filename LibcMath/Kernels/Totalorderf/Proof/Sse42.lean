import LibcMath.Kernels.Totalorderf.Statement

/-!
# `totalorderf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Totalorderf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Totalorderf.Generated

/-- **Open.** Prove `totalorderf` (`sse42`) matches `FloatLibSpec.totalorder`. -/
theorem totalorderfSse42_correct : TotalorderfSse42Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Totalorderf.Proof.Sse42.totalorderfSse42_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms totalorderfSse42_correct

end LibcMath.Kernels.Totalorderf.Proof.Sse42
