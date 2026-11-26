import LibcMath.Kernels.Cosf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Cosf.Generated.DoubleEvalSse42
import LibcMath.Kernels.Cosf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Cosf.Generated.DoubleEvalAArch64
import LibcMath.Kernels.Cosf.Generated.FloatEval

/-!
# Extracted `cosf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `DoubleEvalSse2`: `double_eval_sse2`.
* `DoubleEvalSse42`: `double_eval_sse42`.
* `DoubleEvalAvx2Fma`: `double_eval_avx2_fma`.
* `DoubleEvalAArch64`: `double_eval_aarch64`.
* `FloatEval`: `float_eval`.
-/

namespace LibcMath.Kernels.Cosf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Cosf.Generated

/-- All 5 extracted `cosf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalSse42.kernel
  , DoubleEvalAvx2Fma.kernel
  , DoubleEvalAArch64.kernel
  , FloatEval.kernel ]

end LibcMath.Kernels.Cosf
