import LibcMath.Kernels.Setpayloadf.Statement

/-!
# `setpayloadf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Setpayloadf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Setpayloadf.Generated

/-- **Open.** Prove `setpayloadf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem setpayloadfAvx2Fma_defined : SetpayloadfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Setpayloadf.Proof.Avx2Fma.setpayloadfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms setpayloadfAvx2Fma_defined

end LibcMath.Kernels.Setpayloadf.Proof.Avx2Fma
