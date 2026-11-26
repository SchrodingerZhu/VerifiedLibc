import LibcMath.Kernels.Logbf.Statement

/-!
# `logbf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Logbf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Logbf.Generated

/-- **Open.** Prove `logbf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem logbfAvx2Fma_defined : LogbfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Logbf.Proof.Avx2Fma.logbfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms logbfAvx2Fma_defined

end LibcMath.Kernels.Logbf.Proof.Avx2Fma
