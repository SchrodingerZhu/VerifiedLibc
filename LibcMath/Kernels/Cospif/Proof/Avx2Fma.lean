import LibcMath.Kernels.Cospif.Statement

/-!
# `cospif` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Cospif.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cospif.Generated

/-- **Open.** Prove `cospif` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem cospifAvx2Fma_correctlyRounded : CospifAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Cospif.Proof.Avx2Fma.cospifAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms cospifAvx2Fma_correctlyRounded

end LibcMath.Kernels.Cospif.Proof.Avx2Fma
