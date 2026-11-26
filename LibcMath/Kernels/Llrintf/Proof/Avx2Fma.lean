import LibcMath.Kernels.Llrintf.Statement

/-!
# `llrintf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Llrintf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Llrintf.Generated

/-- **Open.** Prove `llrintf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem llrintfAvx2Fma_defined : LlrintfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Llrintf.Proof.Avx2Fma.llrintfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms llrintfAvx2Fma_defined

end LibcMath.Kernels.Llrintf.Proof.Avx2Fma
