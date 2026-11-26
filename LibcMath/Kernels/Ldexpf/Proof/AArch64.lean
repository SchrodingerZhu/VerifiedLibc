import LibcMath.Kernels.Ldexpf.Statement

/-!
# `ldexpf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ldexpf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ldexpf.Generated

/-- **Open.** Prove `ldexpf` (`aarch64`) executes without C++ undefined behavior. -/
theorem ldexpfAArch64_defined : LdexpfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Ldexpf.Proof.AArch64.ldexpfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ldexpfAArch64_defined

end LibcMath.Kernels.Ldexpf.Proof.AArch64
