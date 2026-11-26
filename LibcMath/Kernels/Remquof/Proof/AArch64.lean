import LibcMath.Kernels.Remquof.Statement

/-!
# `remquof` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Remquof.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Remquof.Generated

/-- **Open.** Prove `remquof` (`aarch64`) executes without C++ undefined behavior. -/
theorem remquofAArch64_defined : RemquofAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Remquof.Proof.AArch64.remquofAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms remquofAArch64_defined

end LibcMath.Kernels.Remquof.Proof.AArch64
