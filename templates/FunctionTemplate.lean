import LibcMath.Fn.Plans
import LibcMath.Fn.Statement
import LibcMath.Fn.ShortPaths.Ranges
import LibcMath.Fn.MainPath.Step
import LibcMath.Fn.Examples

/-!
# `<fn>` is correctly rounded

Entry point for the proof of `math::<plan>::<fn>`. Short paths are proved in `Fn/ShortPaths/`,
numerical analysis of the main path lives in `Fn/MainPath/` (one file per step), and
`fn_correctlyRounded` assembles them here.
-/

namespace LibcMath.Fn

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- `math::<plan>::<fn>` is correctly rounded across the four rounding directions of C. -/
theorem fn_correctlyRounded : FnCorrectlyRounded := by
  refine correctlyRounded_of_holdsOnBits fun mode hmode => ?_
  -- Combine `ShortPaths.holdsOnBits_short_paths hmode` and `MainPath.correctAt_main hmode`
  -- with `HoldsOnBits.append`.
  sorry

#guard_msgs in
#print axioms fn_correctlyRounded

end LibcMath.Fn
