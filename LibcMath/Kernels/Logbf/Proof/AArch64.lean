import LibcMath.Kernels.Logbf.Statement

/-!
# `logbf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Logbf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Logbf.Generated

/-- **Open.** Prove `logbf` (`aarch64`) executes without C++ undefined behavior. -/
theorem logbfAArch64_defined : LogbfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Logbf.Proof.AArch64.logbfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms logbfAArch64_defined

end LibcMath.Kernels.Logbf.Proof.AArch64
