import LibcMath.Framework.Spec
import LibcMath.Libc.DSL
import LibcMath.Testing.Oracle.FloatLib
import LibcMath.Kernels.Exp2m1f.Generated.Sse2
import LibcMath.Kernels.Exp2m1f.Generated.Sse42
import LibcMath.Kernels.Exp2m1f.Generated.Avx2Fma

/-!
# Extracted `exp2m1f` microarch plans

Collects three extracted LLVM libc `exp2m1f` microarch plans (SSE2, SSE4.2, AVX2+FMA).
SSE4.2 and AVX2+FMA take the upstream `LIBC_TARGET_CPU_HAS_NEAREST_INT` branch.

Upstream `src/__support/math/exp2m1f.h` at commit `e1a5f92db023` contains a C++ undefined-behavior
bug on negative NaNs: `if (xbits.is_pos())` skips negative NaNs and `if (x <= -25.0f)` evaluates
to `false` on NaN, so execution falls into `static_cast<int>(NaN)`. This module proves the UB
witness for all three plans and states open obligations on all non-negative-NaN inputs.
-/

namespace LibcMath.Kernels.Exp2m1f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Exp2m1f.Generated

/-- Lists all three extracted `exp2m1f` microarch plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Sse2.kernel, Sse42.kernel, Avx2Fma.kernel ]

/-- Proves that `exp2m1f` (`sse2`) reaches C++ UB (`fptosi?` on NaN) at `-qNaN`. -/
theorem exp2m1fSse2_ub_at_negNaN :
    Sse2.kernel.eval .nearest f32(0xFFC00000#32) = none := by
  decide

/-- Proves that `exp2m1f` (`sse42`) reaches C++ UB (`fptosi?` on NaN) at `-qNaN`. -/
theorem exp2m1fSse42_ub_at_negNaN :
    Sse42.kernel.eval .nearest f32(0xFFC00000#32) = none := by
  decide

/-- Proves that `exp2m1f` (`avx2_fma`) reaches C++ UB (`fptosi?` on NaN) at `-qNaN`. -/
theorem exp2m1fAvx2Fma_ub_at_negNaN :
    Avx2Fma.kernel.eval .nearest f32(0xFFC00000#32) = none := by
  decide

/-- Correct rounding of `exp2m1f` (`sse2`) on all inputs except negative NaNs. -/
def Exp2m1fSse2CorrectlyRoundedNonNegNaN : Prop :=
  ∀ mode ∈ cModes, ∀ x : Model .binary32, !(x.isNaN && x.signBit) →
    ∃ y, Sse2.kernel.eval mode x = some y ∧ SameValue y (FloatLibSpec.exp2m1 mode x)

/-- Correct rounding of `exp2m1f` (`sse42`) on all inputs except negative NaNs. -/
def Exp2m1fSse42CorrectlyRoundedNonNegNaN : Prop :=
  ∀ mode ∈ cModes, ∀ x : Model .binary32, !(x.isNaN && x.signBit) →
    ∃ y, Sse42.kernel.eval mode x = some y ∧ SameValue y (FloatLibSpec.exp2m1 mode x)

/-- Correct rounding of `exp2m1f` (`avx2_fma`) on all inputs except negative NaNs. -/
def Exp2m1fAvx2FmaCorrectlyRoundedNonNegNaN : Prop :=
  ∀ mode ∈ cModes, ∀ x : Model .binary32, !(x.isNaN && x.signBit) →
    ∃ y, Avx2Fma.kernel.eval mode x = some y ∧ SameValue y (FloatLibSpec.exp2m1 mode x)

/-- **Open.** Prove `exp2m1f` (`sse2`) is correctly rounded on all non-negative-NaN inputs. -/
theorem exp2m1fSse2_correctlyRounded_nonNegNaN : Exp2m1fSse2CorrectlyRoundedNonNegNaN := by
  sorry

/-- **Open.** Prove `exp2m1f` (`sse42`) is correctly rounded on all non-negative-NaN inputs. -/
theorem exp2m1fSse42_correctlyRounded_nonNegNaN : Exp2m1fSse42CorrectlyRoundedNonNegNaN := by
  sorry

/-- **Open.** Prove `exp2m1f` (`avx2_fma`) is correctly rounded on all non-negative-NaN inputs. -/
theorem exp2m1fAvx2Fma_correctlyRounded_nonNegNaN : Exp2m1fAvx2FmaCorrectlyRoundedNonNegNaN := by
  sorry

/--
info: 'LibcMath.Kernels.Exp2m1f.exp2m1fSse2_ub_at_negNaN' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms exp2m1fSse2_ub_at_negNaN

/--
info: 'LibcMath.Kernels.Exp2m1f.exp2m1fSse2_correctlyRounded_nonNegNaN' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2m1fSse2_correctlyRounded_nonNegNaN

/--
info: 'LibcMath.Kernels.Exp2m1f.exp2m1fSse42_correctlyRounded_nonNegNaN' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2m1fSse42_correctlyRounded_nonNegNaN

/--
info: 'LibcMath.Kernels.Exp2m1f.exp2m1fAvx2Fma_correctlyRounded_nonNegNaN' depends on axioms: [propext,
 sorryAx,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms exp2m1fAvx2Fma_correctlyRounded_nonNegNaN

end LibcMath.Kernels.Exp2m1f
