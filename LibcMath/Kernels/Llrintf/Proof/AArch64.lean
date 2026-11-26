import LibcMath.Kernels.Llrintf.Statement

/-!
# `llrintf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Llrintf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llrintf.Generated

/-- **Open.** Prove `llrintf` (`aarch64`) executes without C++ undefined behavior. -/
theorem llrintfAArch64_defined : LlrintfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Llrintf.Proof.AArch64.llrintfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms llrintfAArch64_defined

end LibcMath.Kernels.Llrintf.Proof.AArch64
