import LibcMath.Kernels.Fn.Statement
import LibcMath.Kernels.Fn.Proof.Plan.ShortPaths.Ranges
import LibcMath.Kernels.Fn.Proof.Plan.MainPath.Step

/-!
# `math::<plan>::<fn>` is correctly rounded

The theorem for one evaluation plan. Its short paths are proved in `Plan/ShortPaths/`, the
numerical analysis of its main path is in `Plan/MainPath/`, one file per step, and
`fnPlan_correctlyRounded` assembles them here. Say in this docstring whether the proof is complete.
-/

namespace LibcMath.Kernels.Fn.Proof.Plan

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- `math::<plan>::<fn>` is correctly rounded across the four rounding directions of C. -/
theorem fnPlan_correctlyRounded : FnPlanCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  -- Combine `ShortPaths.holdsOnBits_short_paths_plan hmode` and
  -- `MainPath.correctAt_plan_main hmode` with `HoldsOnBits.append`.
  sorry

#guard_msgs in
#print axioms fnPlan_correctlyRounded

end LibcMath.Kernels.Fn.Proof.Plan
