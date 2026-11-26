import LibcMath.Kernels.Scalbnf.Statement

/-!
# `scalbnf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Scalbnf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Scalbnf.Generated

/-- **Open.** Prove `scalbnf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem scalbnfAvx2Fma_defined : ScalbnfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Scalbnf.Proof.Avx2Fma.scalbnfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms scalbnfAvx2Fma_defined

end LibcMath.Kernels.Scalbnf.Proof.Avx2Fma
