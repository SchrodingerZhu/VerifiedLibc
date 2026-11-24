import LibcMath.Fn.Plans
import LibcMath.Analysis.Binary32Bits

/-!
# Symbolic short-path evaluation of `<fn>`

Evaluate the extracted kernel symbolically on `f32(b)` (`b : BitVec 32`) for zeros, infinities,
NaNs, tiny inputs, overflow, and underflow, showing each short path returns `some …` without
hitting undefined behaviour.
-/

namespace LibcMath.Fn.ShortPaths

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Libc.DSL

-- Add symbolic short-path lemmas here (see `LibcMath/Expf/ShortPaths/Exec.lean`).

end LibcMath.Fn.ShortPaths
