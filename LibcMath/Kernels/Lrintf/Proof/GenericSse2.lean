import LibcMath.Kernels.Lrintf.Statement

/-!
# `lrintf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Lrintf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Lrintf.Generated

/-- **Open.** Prove `lrintf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem lrintfGenericSse2_defined : LrintfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Lrintf.Proof.GenericSse2.lrintfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms lrintfGenericSse2_defined

end LibcMath.Kernels.Lrintf.Proof.GenericSse2
