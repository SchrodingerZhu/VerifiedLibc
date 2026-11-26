import LibcMath.Kernels.Fromfpf.Generated.GenericSse2
import LibcMath.Kernels.Fromfpf.Generated.Sse42
import LibcMath.Kernels.Fromfpf.Generated.Avx2Fma
import LibcMath.Kernels.Fromfpf.Generated.AArch64

/-!
# Extracted `fromfpf` plans

The plans that `ast2lean` writes under `Generated/`. Every name says the evaluation plan or the
target.

* `GenericSse2`: `generic_sse2`.
* `Sse42`: `sse42`.
* `Avx2Fma`: `avx2_fma`.
* `AArch64`: `aarch64`.
-/

namespace LibcMath.Kernels.Fromfpf

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Kernels.Fromfpf.Generated

end LibcMath.Kernels.Fromfpf
