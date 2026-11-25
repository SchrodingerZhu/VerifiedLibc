import LibcMath.Kernels.Expf.Generated.DoubleEval
import LibcMath.Kernels.Expf.Generated.DoubleEvalFma
import LibcMath.Kernels.Expf.Generated.IntegerEval
import LibcMath.Kernels.Expf.Generated.StaticRounding
import LibcMath.Kernels.Expf.Generated.FloatEval
import LibcMath.Kernels.Expf.Generated.FloatEvalCrRn

/-!
# Extracted `expf` evaluation plans

Umbrella module collecting all six upstream LLVM libc `expf` evaluation plans extracted by
`ast2lean` (`extract/extract-expf-plans.sh`):

* `DoubleEval`: x86-64 non-FMA double-precision table+Horner plan (`LIBC_MATH=0`, all 4 IEEE
  rounding modes, correctly rounded).
* `DoubleEvalFma`: same `double_eval` plan compiled with `-mavx2 -mfma` (hardware FMA and
  `nearest_integer`).
* `IntegerEval`: integer-only `Frac64` plan (`LIBC_MATH_EXPF_IMPL=integer_eval`, `LIBC_MATH=0x2C`,
  RN-only, correctly rounded).
* `StaticRounding`: 4-mode integer-only `Frac64` plan (`math::static_rounding::expf`,
  `LIBC_MATH=0x0C`, correctly rounded across all 4 IEEE rounding modes).
* `FloatEval`: fast single-precision Estrin+Horner plan (`LIBC_MATH_EXPF_IMPL=float_eval`,
  `LIBC_MATH=0x3F`, RN-only, ~1 ULP).
* `FloatEvalCrRn`: GPU-oriented `FloatFloat` FMA plan (`LIBC_MATH_EXPF_IMPL=float_eval_cr_rn`,
  `LIBC_MATH=0x3E`, RN-only, correctly rounded).
-/

namespace LibcMath.Kernels.Expf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Expf.Generated

/-- All six extracted `expf` evaluation plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEval.kernel
  , DoubleEvalFma.kernel
  , IntegerEval.kernel
  , StaticRounding.kernel
  , FloatEval.kernel
  , FloatEvalCrRn.kernel ]

/-- Plans targeting correct rounding across all four standard IEEE 754 rounding modes. -/
def crAllModePlans : List (UnaryKernel .binary32) :=
  [ DoubleEval.kernel
  , DoubleEvalFma.kernel
  , StaticRounding.kernel ]

/-- Plans targeting correct rounding in round-to-nearest-even (`.nearest`). -/
def crNearestPlans : List (UnaryKernel .binary32) :=
  [ DoubleEval.kernel
  , DoubleEvalFma.kernel
  , IntegerEval.kernel
  , StaticRounding.kernel
  , FloatEvalCrRn.kernel ]

end LibcMath.Kernels.Expf
