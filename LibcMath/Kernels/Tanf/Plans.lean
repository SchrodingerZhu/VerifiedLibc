import LibcMath.Kernels.Tanf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Tanf.Generated.DoubleEvalSse42
import LibcMath.Kernels.Tanf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Tanf.Generated.DoubleEvalAArch64
import LibcMath.Kernels.Tanf.Generated.FloatEval

/-!
# Extracted `tanf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `DoubleEvalSse2`: `double_eval_sse2`.
* `DoubleEvalSse42`: `double_eval_sse42`.
* `DoubleEvalAvx2Fma`: `double_eval_avx2_fma`.
* `DoubleEvalAArch64`: `double_eval_aarch64`.
* `FloatEval`: `float_eval`.
-/

namespace LibcMath.Kernels.Tanf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Tanf.Generated

/-- All 5 extracted `tanf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalSse42.kernel
  , DoubleEvalAvx2Fma.kernel
  , DoubleEvalAArch64.kernel
  , FloatEval.kernel ]

end LibcMath.Kernels.Tanf
