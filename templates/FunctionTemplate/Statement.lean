import LibcMath.Kernels.Fn.Plans
import LibcMath.Framework.Specs

/-!
# Correctness statements for extracted `<fn>` kernels
-/

namespace LibcMath.Kernels.Fn

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- Correct rounding of `math::<plan>::<fn>` in the four rounding directions of C. Always include
the implementation plan name in every statement; do not define a "default" alias. -/
def FnPlanCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.fn .binary32) cModes Generated.Plan.fn

end LibcMath.Kernels.Fn
