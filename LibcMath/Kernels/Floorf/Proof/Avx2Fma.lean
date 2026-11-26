import LibcMath.Kernels.Floorf.Statement

/-!
# `floorf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Floorf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Floorf.Generated

/-- **Open.** Prove `floorf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem floorfAvx2Fma_correctlyRounded : FloorfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Floorf.Proof.Avx2Fma.floorfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms floorfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Floorf.Proof.Avx2Fma
