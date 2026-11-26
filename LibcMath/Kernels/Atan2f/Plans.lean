import LibcMath.Kernels.Atan2f.Generated.DoubleEvalSse2
import LibcMath.Kernels.Atan2f.Generated.DoubleEvalSse42
import LibcMath.Kernels.Atan2f.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Atan2f.Generated.DoubleEvalAArch64
import LibcMath.Kernels.Atan2f.Generated.FloatEval

/-!
# Extracted `atan2f` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `DoubleEvalSse2`: `double_eval_sse2`.
* `DoubleEvalSse42`: `double_eval_sse42`.
* `DoubleEvalAvx2Fma`: `double_eval_avx2_fma`.
* `DoubleEvalAArch64`: `double_eval_aarch64`.
* `FloatEval`: `float_eval`.
-/

namespace LibcMath.Kernels.Atan2f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Atan2f.Generated

/-- All 5 extracted `atan2f` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalSse42.kernel
  , DoubleEvalAvx2Fma.kernel
  , DoubleEvalAArch64.kernel
  , FloatEval.kernel ]

end LibcMath.Kernels.Atan2f
