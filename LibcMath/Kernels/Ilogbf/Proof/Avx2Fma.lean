import LibcMath.Kernels.Ilogbf.Statement

/-!
# `ilogbf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ilogbf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ilogbf.Generated

/-- **Open.** Prove `ilogbf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem ilogbfAvx2Fma_defined : IlogbfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Ilogbf.Proof.Avx2Fma.ilogbfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ilogbfAvx2Fma_defined

end LibcMath.Kernels.Ilogbf.Proof.Avx2Fma
