import LibcMath.Kernels.Lrintf.Statement

/-!
# `lrintf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Lrintf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Lrintf.Generated

/-- **Open.** Prove `lrintf` (`aarch64`) executes without C++ undefined behavior. -/
theorem lrintfAArch64_defined : LrintfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Lrintf.Proof.AArch64.lrintfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms lrintfAArch64_defined

end LibcMath.Kernels.Lrintf.Proof.AArch64
