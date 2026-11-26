import LibcMath.Kernels.Scalblnf.Plans

/-!
# Worked examples for extracted `scalblnf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Scalblnf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Scalblnf.Generated

#guard (GenericSse2.scalblnf .nearest f32(0x3FC00000#32) 3#64).isSome

#guard (Sse42.scalblnf .nearest f32(0x3FC00000#32) 3#64).isSome

#guard (Avx2Fma.scalblnf .nearest f32(0x3FC00000#32) 3#64).isSome

#guard (AArch64.scalblnf .nearest f32(0x3FC00000#32) 3#64).isSome

end LibcMath.Kernels.Scalblnf.Examples
