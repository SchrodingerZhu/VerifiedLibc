import LibcMath.Oracle.Exp
import LibcMath.Extracted.Expf.Exhaustive

/-!
# The implementation and oracle being checked

The exhaustive check of `expf` runs `checkRange Run.oracle Run.run` directly on the AST-extracted
functional kernel `Extracted.Expf.DoubleEval.expf` (with no interpreter or relational bridge).
Certificate files, the `checkrange` executable, and `scripts/exhaustive.py` all target these
definitions.
-/

namespace LibcMath.Exhaustive.Run

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- The sound oracle certificates are stated for. -/
abbrev oracle : Oracle (Spec.exp .binary32) := expOracle .binary32

/-- The default extracted implementation certificates are stated for (`math::double_eval::expf`). -/
abbrev run : IEEERoundingMode → Model .binary32 → Model .binary32 :=
  Extracted.Expf.DoubleEval.expf

/-- Under `mode`, `run` produces the result `exp` prescribes on every bit pattern in `[lo, hi)`. -/
abbrev CheckedOn (mode : IEEERoundingMode) (lo hi : ℕ) : Prop :=
  HoldsOnBits (CorrectAt (Spec.exp .binary32) run mode) lo hi

/-- Look up any extracted `expf` evaluation plan by variant name (for `checkrange --plan=...`). -/
def planByName? : String → Option (Core.UnaryKernel .binary32)
  | "double_eval" => some Extracted.Expf.DoubleEval.kernel
  | "double_eval_fma" => some Extracted.Expf.DoubleEvalFma.kernel
  | "integer_eval" => some Extracted.Expf.IntegerEval.kernel
  | "static_rounding" => some Extracted.Expf.StaticRounding.kernel
  | "float_eval" => some Extracted.Expf.FloatEval.kernel
  | "float_eval_cr_rn" => some Extracted.Expf.FloatEvalCrRn.kernel
  | _ => none

end LibcMath.Exhaustive.Run
