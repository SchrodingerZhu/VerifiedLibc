import LibcMath.Kernels.Acospif.Statement

/-!
# `acospif` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Acospif.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Acospif.Generated

/-- **Open.** Prove `acospif` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem acospifAvx2Fma_correctlyRounded : AcospifAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Acospif.Proof.Avx2Fma.acospifAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms acospifAvx2Fma_correctlyRounded

end LibcMath.Kernels.Acospif.Proof.Avx2Fma
