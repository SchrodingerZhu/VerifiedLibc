import LibcMath.Kernels.Ufromfpf.Statement

/-!
# `ufromfpf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ufromfpf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ufromfpf.Generated

/-- **Open.** Prove `ufromfpf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem ufromfpfGenericSse2_defined : UfromfpfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Ufromfpf.Proof.GenericSse2.ufromfpfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ufromfpfGenericSse2_defined

end LibcMath.Kernels.Ufromfpf.Proof.GenericSse2
