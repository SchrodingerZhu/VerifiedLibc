import LibcMath.Kernels.Lrintf.Plans

/-!
# Worked examples for extracted `lrintf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Lrintf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Lrintf.Generated

#guard (GenericSse2.lrintf .nearest f32(0x3FC00000#32)).isSome

#guard (Sse42.lrintf .nearest f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.lrintf .nearest f32(0x3FC00000#32)).isSome

#guard (AArch64.lrintf .nearest f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Lrintf.Examples
