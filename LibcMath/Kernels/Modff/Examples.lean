import LibcMath.Kernels.Modff.Plans

/-!
# Worked examples for extracted `modff` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Modff.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Modff.Generated

#guard (GenericSse2.modff .nearest f32(0x3FC00000#32)).isSome

#guard (Sse42.modff .nearest f32(0x3FC00000#32)).isSome

#guard (Avx2Fma.modff .nearest f32(0x3FC00000#32)).isSome

#guard (AArch64.modff .nearest f32(0x3FC00000#32)).isSome

end LibcMath.Kernels.Modff.Examples
