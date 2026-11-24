import LibcMath.Fn.Generated.Default

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
  [ Default.kernel ]

end LibcMath.Fn
