import LibcMath.Kernels.Fromfpf.Statement

/-!
# `fromfpf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fromfpf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Fromfpf.Generated

/-- **Open.** Prove `fromfpf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem fromfpfAvx2Fma_defined : FromfpfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Fromfpf.Proof.Avx2Fma.fromfpfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fromfpfAvx2Fma_defined

end LibcMath.Kernels.Fromfpf.Proof.Avx2Fma
