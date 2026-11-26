import LibcMath.Kernels.Ldexpf.Statement

/-!
# `ldexpf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ldexpf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Ldexpf.Generated

/-- **Open.** Prove `ldexpf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem ldexpfAvx2Fma_defined : LdexpfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Ldexpf.Proof.Avx2Fma.ldexpfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ldexpfAvx2Fma_defined

end LibcMath.Kernels.Ldexpf.Proof.Avx2Fma
