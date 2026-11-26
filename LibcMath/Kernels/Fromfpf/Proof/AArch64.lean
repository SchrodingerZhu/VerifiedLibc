import LibcMath.Kernels.Fromfpf.Statement

/-!
# `fromfpf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fromfpf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fromfpf.Generated

/-- **Open.** Prove `fromfpf` (`aarch64`) executes without C++ undefined behavior. -/
theorem fromfpfAArch64_defined : FromfpfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Fromfpf.Proof.AArch64.fromfpfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fromfpfAArch64_defined

end LibcMath.Kernels.Fromfpf.Proof.AArch64
