import LibcMath.Kernels.Lroundf.Statement

/-!
# `lroundf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Lroundf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Lroundf.Generated

/-- **Open.** Prove `lroundf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem lroundfGenericSse2_defined : LroundfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Lroundf.Proof.GenericSse2.lroundfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms lroundfGenericSse2_defined

end LibcMath.Kernels.Lroundf.Proof.GenericSse2
