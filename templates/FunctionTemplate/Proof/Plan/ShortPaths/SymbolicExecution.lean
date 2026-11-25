import LibcMath.Kernels.Fn.Plans
import LibcMath.Analysis.Binary32Bits

/-!
# Symbolic short-path evaluation of `<fn>`

Evaluate the extracted kernel symbolically on `f32(b)` (`b : BitVec 32`) for zeros, infinities,
NaNs, tiny inputs, overflow, and underflow, showing each short path returns `some …` without
hitting undefined behaviour.
-/

namespace LibcMath.Kernels.Fn.Proof.Plan.ShortPaths

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Libc.DSL

-- Add symbolic short-path lemmas here; the model is
-- `LibcMath/Kernels/Expf/Proof/DoubleEval/ShortPaths/SymbolicExecution.lean`.

end LibcMath.Kernels.Fn.Proof.Plan.ShortPaths
