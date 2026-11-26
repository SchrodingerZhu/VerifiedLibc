import LibcMath.Kernels.Lroundf.Statement

/-!
# `lroundf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Lroundf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Lroundf.Generated

/-- **Open.** Prove `lroundf` (`aarch64`) executes without C++ undefined behavior. -/
theorem lroundfAArch64_defined : LroundfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Lroundf.Proof.AArch64.lroundfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms lroundfAArch64_defined

end LibcMath.Kernels.Lroundf.Proof.AArch64
