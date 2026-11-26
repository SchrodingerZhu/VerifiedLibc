import LibcMath.Kernels.Ufromfpxf.Statement

/-!
# `ufromfpxf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ufromfpxf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ufromfpxf.Generated

/-- **Open.** Prove `ufromfpxf` (`aarch64`) executes without C++ undefined behavior. -/
theorem ufromfpxfAArch64_defined : UfromfpxfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Ufromfpxf.Proof.AArch64.ufromfpxfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ufromfpxfAArch64_defined

end LibcMath.Kernels.Ufromfpxf.Proof.AArch64
