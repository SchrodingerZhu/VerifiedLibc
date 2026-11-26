import LibcMath.Kernels.Setpayloadsigf.Statement

/-!
# `setpayloadsigf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Setpayloadsigf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Setpayloadsigf.Generated

/-- **Open.** Prove `setpayloadsigf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem setpayloadsigfAvx2Fma_defined : SetpayloadsigfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Setpayloadsigf.Proof.Avx2Fma.setpayloadsigfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms setpayloadsigfAvx2Fma_defined

end LibcMath.Kernels.Setpayloadsigf.Proof.Avx2Fma
