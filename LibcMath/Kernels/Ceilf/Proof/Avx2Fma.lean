import LibcMath.Kernels.Ceilf.Statement

/-!
# `ceilf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Ceilf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Ceilf.Generated

/-- **Open.** Prove `ceilf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem ceilfAvx2Fma_correctlyRounded : CeilfAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Ceilf.Proof.Avx2Fma.ceilfAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms ceilfAvx2Fma_correctlyRounded

end LibcMath.Kernels.Ceilf.Proof.Avx2Fma
