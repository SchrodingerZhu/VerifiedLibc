import LibcMath.Kernels.Exp2m1f.Statement

/-!
# `exp2m1f` (`sse2`)

**Not complete.** Each theorem below that ends in `sorry` is open; `OPEN.md` lists it.
-/

namespace LibcMath.Kernels.Exp2m1f.Proof.Sse2

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Exp2m1f.Generated

/-- Proves that `exp2m1f` (`sse2`) reaches C++ UB (`fptosi?` on NaN) at `-qNaN`. -/
theorem exp2m1fSse2_ub_at_negNaN :
    Sse2.kernel.eval .nearest f32(0xFFC00000#32) = none := by
  decide

/-- **Open.** Prove `exp2m1f` (`sse2`) is correctly rounded on all non-negative-NaN inputs. -/
theorem exp2m1fSse2_correctlyRounded_nonNegNaN : Exp2m1fSse2CorrectlyRoundedNonNegNaN := by
  sorry

/--
info: 'LibcMath.Kernels.Exp2m1f.Proof.Sse2.exp2m1fSse2_ub_at_negNaN' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2m1fSse2_ub_at_negNaN

/--
info: 'LibcMath.Kernels.Exp2m1f.Proof.Sse2.exp2m1fSse2_correctlyRounded_nonNegNaN' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2m1fSse2_correctlyRounded_nonNegNaN

end LibcMath.Kernels.Exp2m1f.Proof.Sse2
