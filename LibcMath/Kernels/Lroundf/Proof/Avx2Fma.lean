import LibcMath.Kernels.Lroundf.Statement

/-!
# `lroundf` (`avx2_fma`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Lroundf.Proof.Avx2Fma

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Kernels.Lroundf.Generated

/-- **Open.** Prove `lroundf` (`avx2_fma`) executes without C++ undefined behavior. -/
theorem lroundfAvx2Fma_defined : LroundfAvx2FmaDefined := by
  sorry

/--
info: 'LibcMath.Kernels.Lroundf.Proof.Avx2Fma.lroundfAvx2Fma_defined' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms lroundfAvx2Fma_defined

end LibcMath.Kernels.Lroundf.Proof.Avx2Fma
