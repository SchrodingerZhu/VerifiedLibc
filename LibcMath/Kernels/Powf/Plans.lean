import LibcMath.Kernels.Powf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Powf.Generated.DoubleEvalSse42
import LibcMath.Kernels.Powf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Powf.Generated.DoubleEvalAArch64
import LibcMath.Kernels.Powf.Generated.FloatEval

/-!
# Extracted `powf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `DoubleEvalSse2`: `double_eval_sse2`.
* `DoubleEvalSse42`: `double_eval_sse42`.
* `DoubleEvalAvx2Fma`: `double_eval_avx2_fma`.
* `DoubleEvalAArch64`: `double_eval_aarch64`.
* `FloatEval`: `float_eval`.
-/

namespace LibcMath.Kernels.Powf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Powf.Generated

/-- All 5 extracted `powf` plans. -/
def allPlans : List (BinaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalSse42.kernel
  , DoubleEvalAvx2Fma.kernel
  , DoubleEvalAArch64.kernel
  , FloatEval.kernel ]

end LibcMath.Kernels.Powf
