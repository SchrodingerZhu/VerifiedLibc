import LibcMath.Kernels.Nextafterf.Statement

/-!
# `nextafterf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Nextafterf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Nextafterf.Generated

/-- **Open.** Prove `nextafterf` (`aarch64`) executes without C++ undefined behavior. -/
theorem nextafterfAArch64_defined : NextafterfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Nextafterf.Proof.AArch64.nextafterfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms nextafterfAArch64_defined

end LibcMath.Kernels.Nextafterf.Proof.AArch64
