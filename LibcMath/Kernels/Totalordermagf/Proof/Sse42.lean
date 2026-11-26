import LibcMath.Kernels.Totalordermagf.Statement

/-!
# `totalordermagf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Totalordermagf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Totalordermagf.Generated

/-- **Open.** Prove `totalordermagf` (`sse42`) matches `FloatLibSpec.totalordermag`. -/
theorem totalordermagfSse42_correct : TotalordermagfSse42Correct := by
  sorry

/--
info: 'LibcMath.Kernels.Totalordermagf.Proof.Sse42.totalordermagfSse42_correct' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms totalordermagfSse42_correct

end LibcMath.Kernels.Totalordermagf.Proof.Sse42
