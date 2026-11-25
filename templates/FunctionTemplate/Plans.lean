import LibcMath.Fn.Generated.Plan

/-!
# Extracted `<fn>` evaluation plans

Umbrella module collecting the plans emitted by `ast2lean` under `LibcMath/Fn/Generated/`.
-/

namespace LibcMath.Fn

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Fn.Generated

/-- All extracted `<fn>` evaluation plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ Plan.kernel ]

end LibcMath.Fn
