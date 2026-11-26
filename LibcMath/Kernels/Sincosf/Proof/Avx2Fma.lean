import LibcMath.Kernels.Sincosf.Statement

/-!
# `sincosf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sincosf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Kernels.Sincosf.Generated

/-- **Open.** Prove `sincosf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem sincosfAvx2Fma_correctlyRounded : SincosfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sincosf.Proof.Avx2Fma.sincosfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sincosfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Sincosf.Proof.Avx2Fma
