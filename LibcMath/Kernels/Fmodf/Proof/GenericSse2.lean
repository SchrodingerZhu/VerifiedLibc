import LibcMath.Kernels.Fmodf.Statement

/-!
# `fmodf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fmodf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fmodf.Generated

/-- **Open.** Prove `fmodf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem fmodfGenericSse2_defined : FmodfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Fmodf.Proof.GenericSse2.fmodfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmodfGenericSse2_defined

end LibcMath.Kernels.Fmodf.Proof.GenericSse2
