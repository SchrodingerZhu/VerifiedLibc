import LibcMath.Fn.Plans
import LibcMath.Fn.Statement
import LibcMath.Fn.ShortPaths.Ranges
import LibcMath.Fn.MainPath.Step
import LibcMath.Fn.Examples

/-!
# Extracted `<fn>` implementations: correctness theorems

Entry point for the proof of `math::<plan>::<fn>`. Every statement and theorem explicitly names
its extracted evaluation plan (never a "default" alias). Short paths are proved in
`Fn/ShortPaths/`, numerical analysis of the main path lives in `Fn/MainPath/` (one file per step),
and `fnPlan_correctlyRounded` assembles them here.
-/

namespace LibcMath.Fn

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

end LibcMath.Fn
