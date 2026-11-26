import LibcMath.Kernels.Ufromfpf.Statement

/-!
# `ufromfpf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ufromfpf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ufromfpf.Generated

/-- **Open.** Prove `ufromfpf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem ufromfpfAvx2Fma_defined : UfromfpfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Ufromfpf.Proof.Avx2Fma.ufromfpfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ufromfpfAvx2Fma_defined

end LibcMath.Kernels.Ufromfpf.Proof.Avx2Fma
