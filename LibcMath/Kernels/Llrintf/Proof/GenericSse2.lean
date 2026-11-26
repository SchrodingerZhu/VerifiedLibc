import LibcMath.Kernels.Llrintf.Statement

/-!
# `llrintf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Llrintf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llrintf.Generated

/-- **Open.** Prove `llrintf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem llrintfGenericSse2_defined : LlrintfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Llrintf.Proof.GenericSse2.llrintfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms llrintfGenericSse2_defined

end LibcMath.Kernels.Llrintf.Proof.GenericSse2
