import LibcMath.Kernels.Lroundf.Statement

/-!
# `lroundf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Lroundf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Lroundf.Generated

/-- **Open.** Prove `lroundf` (`sse42`) executes without C++ undefined behavior. -/
theorem lroundfSse42_defined : LroundfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Lroundf.Proof.Sse42.lroundfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms lroundfSse42_defined

end LibcMath.Kernels.Lroundf.Proof.Sse42
