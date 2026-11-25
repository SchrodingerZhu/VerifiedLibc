import LibcMath.Framework.Correctness
import LibcMath.Fn.ShortPaths.Exec
import LibcMath.Analysis.RoundingRanges

/-!
# Short-path correctness ranges for `<fn>`

Join the symbolic evaluations from `ShortPaths/Exec.lean` with closed-form specification theorems
under `LibcMath/Analysis/` into `HoldsOnBits` ranges.
-/

namespace LibcMath.Fn.ShortPaths

open FloatLib.Floats.Formats.BinaryInterchange Model
open LibcMath.Libc.DSL

-- Add `holdsOnBits_short_paths_<plan>` here (see `LibcMath/Expf/ShortPaths/Ranges.lean`).

end LibcMath.Fn.ShortPaths
