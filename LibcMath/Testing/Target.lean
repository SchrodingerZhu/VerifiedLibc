import LibcMath.Testing.Oracle.Exp
import LibcMath.Testing.Range
import LibcMath.Kernels.Expf.Plans

/-!
# What `checkrange` tests

The oracle and the extracted plans that the program `checkrange` (`LibcMath/Testing/Main.lean`)
compares.
-/

namespace LibcMath.Testing

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- The oracle that is proved sound in Lean. -/
abbrev oracle : Oracle (Spec.exp .binary32) := expOracle .binary32

/-- Look up any extracted `expf` evaluation plan by variant name (for `checkrange --plan=...`). -/
def planByName? : String → Option (Libc.UnaryKernel .binary32)
  | "double_eval" => some Kernels.Expf.Generated.DoubleEval.kernel
  | "double_eval_fma" => some Kernels.Expf.Generated.DoubleEvalFma.kernel
  | "integer_eval" => some Kernels.Expf.Generated.IntegerEval.kernel
  | "static_rounding" => some Kernels.Expf.Generated.StaticRounding.kernel
  | "float_eval" => some Kernels.Expf.Generated.FloatEval.kernel
  | "float_eval_cr_rn" => some Kernels.Expf.Generated.FloatEvalCrRn.kernel
  | _ => none

end LibcMath.Testing
