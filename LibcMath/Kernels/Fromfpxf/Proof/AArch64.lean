import LibcMath.Kernels.Fromfpxf.Statement

/-!
# `fromfpxf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fromfpxf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fromfpxf.Generated

/-- **Open.** Prove `fromfpxf` (`aarch64`) executes without C++ undefined behavior. -/
theorem fromfpxfAArch64_defined : FromfpxfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Fromfpxf.Proof.AArch64.fromfpxfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fromfpxfAArch64_defined

end LibcMath.Kernels.Fromfpxf.Proof.AArch64
