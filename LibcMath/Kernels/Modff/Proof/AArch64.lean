import LibcMath.Kernels.Modff.Statement

/-!
# `modff` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Modff.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Modff.Generated

/-- **Open.** Prove `modff` (`aarch64`) executes without C++ undefined behavior. -/
theorem modffAArch64_defined : ModffAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Modff.Proof.AArch64.modffAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms modffAArch64_defined

end LibcMath.Kernels.Modff.Proof.AArch64
