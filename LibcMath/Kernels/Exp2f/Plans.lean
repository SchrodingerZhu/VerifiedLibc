import LibcMath.Kernels.Exp2f.Generated.DoubleEvalSse2
import LibcMath.Kernels.Exp2f.Generated.DoubleEvalSse42
import LibcMath.Kernels.Exp2f.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Exp2f.Generated.DoubleEvalAArch64
import LibcMath.Kernels.Exp2f.Generated.FloatEval
import LibcMath.Kernels.Exp2f.Generated.IntegerEval
import LibcMath.Kernels.Exp2f.Generated.StaticRounding

/-!
# Extracted `exp2f` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `DoubleEvalSse2`: `double_eval_sse2`.
* `DoubleEvalSse42`: `double_eval_sse42`.
* `DoubleEvalAvx2Fma`: `double_eval_avx2_fma`.
* `DoubleEvalAArch64`: `double_eval_aarch64`.
* `FloatEval`: `float_eval`.
* `IntegerEval`: `integer_eval`.
* `StaticRounding`: `static_rounding`.
-/

namespace LibcMath.Kernels.Exp2f

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Exp2f.Generated

/-- All 7 extracted `exp2f` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalSse42.kernel
  , DoubleEvalAvx2Fma.kernel
  , DoubleEvalAArch64.kernel
  , FloatEval.kernel
  , IntegerEval.kernel
  , StaticRounding.kernel ]

end LibcMath.Kernels.Exp2f
