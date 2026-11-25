import LibcMath.Framework.Correctness
import LibcMath.Kernels.Fn.ShortPaths.SymbolicExecution
import LibcMath.Analysis.RoundingRanges

/-!
# Short-path correctness ranges for `<fn>`

Join the symbolic evaluations from `ShortPaths/SymbolicExecution.lean` with closed-form specification theorems
under `LibcMath/Analysis/` into `HoldsOnBits` ranges.
-/

namespace LibcMath.Kernels.Fn.ShortPaths

open FloatLib.Floats.Formats.BinaryInterchange Model
open LibcMath.Libc.DSL

-- Add `holdsOnBits_short_paths_<plan>` here (see `LibcMath/Kernels/Expf/ShortPaths/Ranges.lean`).

end LibcMath.Kernels.Fn.ShortPaths
