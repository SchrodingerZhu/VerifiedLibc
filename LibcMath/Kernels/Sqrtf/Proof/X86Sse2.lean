import LibcMath.Kernels.Sqrtf.Statement

/-!
# `sqrtf` (`x86_sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Sqrtf.Proof.X86Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Sqrtf.Generated

/-- **Open.** Prove `sqrtf` (`x86_sse2`) is correctly rounded in all four C modes. -/
theorem sqrtfX86Sse2_correctlyRounded : SqrtfX86Sse2CorrectlyRounded := by
  sorry

/--
info: 'LibcMath.Kernels.Sqrtf.Proof.X86Sse2.sqrtfX86Sse2_correctlyRounded' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms sqrtfX86Sse2_correctlyRounded

end LibcMath.Kernels.Sqrtf.Proof.X86Sse2
