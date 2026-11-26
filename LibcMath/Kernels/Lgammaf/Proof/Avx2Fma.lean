import LibcMath.Kernels.Lgammaf.Statement

/-!
# `lgammaf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Lgammaf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Lgammaf.Generated

/-- **Open.** Prove `lgammaf` (`avx2_fma`) is correctly rounded in all four C modes. -/
theorem lgammafAvx2Fma_correctlyRounded : LgammafAvx2FmaCorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Lgammaf.Proof.Avx2Fma.lgammafAvx2Fma_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms lgammafAvx2Fma_correctlyRounded

end LibcMath.Kernels.Lgammaf.Proof.Avx2Fma
