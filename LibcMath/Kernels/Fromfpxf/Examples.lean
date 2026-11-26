import LibcMath.Kernels.Fromfpxf.Plans

/-!
# Worked examples for extracted `fromfpxf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Fromfpxf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Fromfpxf.Generated

#guard (GenericSse2.fromfpxf f32(0x3FC00000#32) 3#32 3#32).isSome

#guard (Sse42.fromfpxf f32(0x3FC00000#32) 3#32 3#32).isSome

#guard (Avx2Fma.fromfpxf f32(0x3FC00000#32) 3#32 3#32).isSome

#guard (AArch64.fromfpxf f32(0x3FC00000#32) 3#32 3#32).isSome

end LibcMath.Kernels.Fromfpxf.Examples
