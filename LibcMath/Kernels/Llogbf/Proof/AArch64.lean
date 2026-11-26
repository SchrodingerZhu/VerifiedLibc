import LibcMath.Kernels.Llogbf.Statement

/-!
# `llogbf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Llogbf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llogbf.Generated

/-- **Open.** Prove `llogbf` (`aarch64`) executes without C++ undefined behavior. -/
theorem llogbfAArch64_defined : LlogbfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Llogbf.Proof.AArch64.llogbfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms llogbfAArch64_defined

end LibcMath.Kernels.Llogbf.Proof.AArch64
