import LibcMath.Kernels.Logf.Generated.DoubleEvalSse2
import LibcMath.Kernels.Logf.Generated.DoubleEvalSse42
import LibcMath.Kernels.Logf.Generated.DoubleEvalAvx2Fma
import LibcMath.Kernels.Logf.Generated.DoubleEvalAArch64

/-!
# Extracted `logf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `DoubleEvalSse2`: `double_eval_sse2`.
* `DoubleEvalSse42`: `double_eval_sse42`.
* `DoubleEvalAvx2Fma`: `double_eval_avx2_fma`.
* `DoubleEvalAArch64`: `double_eval_aarch64`.
-/

namespace LibcMath.Kernels.Logf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Logf.Generated

/-- All 4 extracted `logf` plans. -/
def allPlans : List (UnaryKernel .binary32) :=
  [ DoubleEvalSse2.kernel
  , DoubleEvalSse42.kernel
  , DoubleEvalAvx2Fma.kernel
  , DoubleEvalAArch64.kernel ]

end LibcMath.Kernels.Logf
