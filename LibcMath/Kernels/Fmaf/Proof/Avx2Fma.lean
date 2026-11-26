import LibcMath.Kernels.Fmaf.Statement

/-!
# `fmaf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Fmaf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fmaf.Generated

/-- **Open.** Prove `fmaf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem fmafAvx2Fma_correctlyRounded : FmafAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Fmaf.Proof.Avx2Fma.fmafAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms fmafAvx2Fma_correctlyRounded

end LibcMath.Kernels.Fmaf.Proof.Avx2Fma
