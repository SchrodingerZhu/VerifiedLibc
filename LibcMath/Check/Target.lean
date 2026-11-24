import LibcMath.Oracle.Exp
import LibcMath.Check.Range
import LibcMath.Extracted.Expf.Plans

/-!
# What `checkrange` tests

The oracle and the extracted plans that the program `checkrange` (`LibcMath/Check/Main.lean`)
compares.
-/

namespace LibcMath.Check

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- The oracle that is proved sound in Lean. -/
abbrev oracle : Oracle (Spec.exp .binary32) := expOracle .binary32

/-- The default plan (`math::double_eval::expf`). -/
abbrev run : IEEERoundingMode → Model .binary32 → Option (Model .binary32) :=
  Extracted.Expf.DoubleEval.expf

/-- Look up any extracted `expf` evaluation plan by variant name (for `checkrange --plan=...`). -/
def planByName? : String → Option (Core.UnaryKernel .binary32)
  | "double_eval" => some Extracted.Expf.DoubleEval.kernel
  | "double_eval_fma" => some Extracted.Expf.DoubleEvalFma.kernel
  | "integer_eval" => some Extracted.Expf.IntegerEval.kernel
  | "static_rounding" => some Extracted.Expf.StaticRounding.kernel
  | "float_eval" => some Extracted.Expf.FloatEval.kernel
  | "float_eval_cr_rn" => some Extracted.Expf.FloatEvalCrRn.kernel
  | _ => none

end LibcMath.Check
