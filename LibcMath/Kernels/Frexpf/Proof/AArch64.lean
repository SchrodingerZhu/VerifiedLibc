import LibcMath.Kernels.Frexpf.Statement

/-!
# `frexpf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Frexpf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Frexpf.Generated

/-- **Open.** Prove `frexpf` (`aarch64`) executes without C++ undefined behavior. -/
theorem frexpfAArch64_defined : FrexpfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Frexpf.Proof.AArch64.frexpfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms frexpfAArch64_defined

end LibcMath.Kernels.Frexpf.Proof.AArch64
