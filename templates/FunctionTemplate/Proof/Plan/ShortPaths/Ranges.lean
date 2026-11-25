import LibcMath.Framework.Correctness
import LibcMath.Kernels.Fn.Proof.Plan.ShortPaths.SymbolicExecution
import LibcMath.Analysis.RoundingRanges

/-!
# Short-path correctness ranges for `<fn>`

Join the symbolic evaluations from `SymbolicExecution.lean` with closed-form specification
theorems under `LibcMath/Analysis/` into `HoldsOnBits` ranges.
-/

namespace LibcMath.Kernels.Fn.Proof.Plan.ShortPaths

open FloatLib.Floats.Formats.BinaryInterchange Model
open LibcMath.Libc.DSL

-- Add `holdsOnBits_short_paths_<plan>` here; the model is
-- `LibcMath/Kernels/Expf/Proof/DoubleEval/ShortPaths/Ranges.lean`.

end LibcMath.Kernels.Fn.Proof.Plan.ShortPaths
