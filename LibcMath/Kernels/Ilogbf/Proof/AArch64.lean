import LibcMath.Kernels.Ilogbf.Statement

/-!
# `ilogbf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ilogbf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ilogbf.Generated

/-- **Open.** Prove `ilogbf` (`aarch64`) executes without C++ undefined behavior. -/
theorem ilogbfAArch64_defined : IlogbfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Ilogbf.Proof.AArch64.ilogbfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ilogbfAArch64_defined

end LibcMath.Kernels.Ilogbf.Proof.AArch64
