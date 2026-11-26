import LibcMath.Kernels.Cbrtf.Plans

/-!
# Worked examples for extracted `cbrtf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Cbrtf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Cbrtf.Generated

#guard (Sse2.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (Sse42.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (AArch64.kernel.eval .nearest f32(0x3FC00000#32)).isSome

#guard (Diag.firstDiffBits Sse2.kernel.eval Sse42.kernel.eval
    .nearest 0x3F800000 32).isNone

#guard (Diag.firstDiffBits Sse2.kernel.eval Avx2Fma.kernel.eval
    .nearest 0x3F800000 32).isNone

#guard (Diag.firstDiffBits Sse2.kernel.eval AArch64.kernel.eval
    .nearest 0x3F800000 32).isNone

end LibcMath.Kernels.Cbrtf.Examples
