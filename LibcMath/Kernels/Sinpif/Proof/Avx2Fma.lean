import LibcMath.Kernels.Sinpif.Statement

/-!
# `sinpif` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sinpif.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sinpif.Generated

/-- **Open.** Prove `sinpif` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem sinpifAvx2Fma_correctlyRounded : SinpifAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sinpif.Proof.Avx2Fma.sinpifAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sinpifAvx2Fma_correctlyRounded

end LibcMath.Kernels.Sinpif.Proof.Avx2Fma
