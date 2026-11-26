import LibcMath.Kernels.Llrintf.Statement

/-!
# `llrintf` (`sse42`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Llrintf.Proof.Sse42

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llrintf.Generated

/-- **Open.** Prove `llrintf` (`sse42`) executes without C++ undefined behavior. -/
theorem llrintfSse42_defined : LlrintfSse42Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Llrintf.Proof.Sse42.llrintfSse42_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms llrintfSse42_defined

end LibcMath.Kernels.Llrintf.Proof.Sse42
