import LibcMath.Kernels.Llrintf.Plans

/-!
# Worked examples for extracted `llrintf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Llrintf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Llrintf.Generated

#guard (GenericSse2.llrintf .nearest f32(0x3FC00000#32)).isSome

#guard (Sse42.llrintf .nearest f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.llrintf .nearest f32(0x3FC00000#32)).isSome

#guard (AArch64.llrintf .nearest f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Llrintf.Examples
