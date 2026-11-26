import LibcMath.Kernels.Ufromfpf.Statement

/-!
# `ufromfpf` (`aarch64`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ufromfpf.Proof.AArch64

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ufromfpf.Generated

/-- **Open.** Prove `ufromfpf` (`aarch64`) executes without C++ undefined behavior. -/
theorem ufromfpfAArch64_defined : UfromfpfAArch64Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Ufromfpf.Proof.AArch64.ufromfpfAArch64_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ufromfpfAArch64_defined

end LibcMath.Kernels.Ufromfpf.Proof.AArch64
