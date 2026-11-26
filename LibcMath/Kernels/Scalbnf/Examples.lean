import LibcMath.Kernels.Scalbnf.Plans

/-!
# Worked examples for extracted `scalbnf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Scalbnf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Scalbnf.Generated

#guard (GenericSse2.scalbnf .nearest f32(0x3FC00000#32) 3#32).isSome

#guard (Sse42.scalbnf .nearest f32(0x3FC00000#32) 3#32).isSome

#guard (Avx2Fma.scalbnf .nearest f32(0x3FC00000#32) 3#32).isSome

#guard (AArch64.scalbnf .nearest f32(0x3FC00000#32) 3#32).isSome

end LibcMath.Kernels.Scalbnf.Examples
