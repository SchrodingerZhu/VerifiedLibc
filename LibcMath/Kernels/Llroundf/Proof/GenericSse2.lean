import LibcMath.Kernels.Llroundf.Statement

/-!
# `llroundf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Llroundf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llroundf.Generated

/-- **Open.** Prove `llroundf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem llroundfGenericSse2_defined : LlroundfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Llroundf.Proof.GenericSse2.llroundfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms llroundfGenericSse2_defined

end LibcMath.Kernels.Llroundf.Proof.GenericSse2
