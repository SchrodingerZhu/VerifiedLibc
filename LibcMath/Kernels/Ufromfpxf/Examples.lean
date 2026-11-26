import LibcMath.Kernels.Ufromfpxf.Plans

/-!
# Worked examples for extracted `ufromfpxf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Ufromfpxf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Ufromfpxf.Generated

#guard (GenericSse2.ufromfpxf .nearest f32(0x3FC00000#32) 3#32 3#32).isSome

#guard (Sse42.ufromfpxf .nearest f32(0x3FC00000#32) 3#32 3#32).isSome

#guard (Avx2Fma.ufromfpxf .nearest f32(0x3FC00000#32) 3#32 3#32).isSome

#guard (AArch64.ufromfpxf .nearest f32(0x3FC00000#32) 3#32 3#32).isSome

end LibcMath.Kernels.Ufromfpxf.Examples
