import LibcMath.Kernels.Llroundf.Statement

/-!
# `llroundf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Llroundf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llroundf.Generated

/-- **Open.** Prove `llroundf` (`aarch64`) executes without C++ undefined behavior. -/
theorem llroundfAArch64_defined : LlroundfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Llroundf.Proof.AArch64.llroundfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms llroundfAArch64_defined

end LibcMath.Kernels.Llroundf.Proof.AArch64
