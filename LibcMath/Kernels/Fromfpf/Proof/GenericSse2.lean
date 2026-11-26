import LibcMath.Kernels.Fromfpf.Statement

/-!
# `fromfpf` (`generic_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fromfpf.Proof.GenericSse2

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fromfpf.Generated

/-- **Open.** Prove `fromfpf` (`generic_sse2`) executes without C++ undefined behavior. -/
theorem fromfpfGenericSse2_defined : FromfpfGenericSse2Defined := by
  sorry

/--
info: 'LibcMath.Kernels.Fromfpf.Proof.GenericSse2.fromfpfGenericSse2_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fromfpfGenericSse2_defined

end LibcMath.Kernels.Fromfpf.Proof.GenericSse2
