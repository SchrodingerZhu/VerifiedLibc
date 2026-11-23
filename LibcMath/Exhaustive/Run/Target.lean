import LibcMath.Oracle.Exp
import LibcMath.Exhaustive.ExpfInterp

/-!
# The implementation and oracle being checked

The exhaustive check of `expf` runs `checkRange Run.oracle Run.run` over blocks of bit patterns.
Every certificate file, the `checkrange` executable and the generator in `scripts/` refer to the
definitions below and to nothing else.
-/

namespace LibcMath.Exhaustive.Run

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- The oracle certificates are stated for. -/
abbrev oracle : Oracle (Spec.exp .binary32) := expOracle .binary32

/-- The implementation certificates are stated for: the interpreter on the extracted `expf`. -/
abbrev run : IEEERoundingMode → Model .binary32 → Option (Model .binary32) :=
  Extracted.expf.runUnary

/-- Under `mode`, `run` produces the result `exp` prescribes on every bit pattern from `lo` up to
but excluding `hi`. This is what a certificate file concludes for the range it covers. -/
abbrev CheckedOn (mode : IEEERoundingMode) (lo hi : ℕ) : Prop :=
  HoldsOnBits (RunsCorrectlyAt (Spec.exp .binary32) run mode) lo hi

end LibcMath.Exhaustive.Run
