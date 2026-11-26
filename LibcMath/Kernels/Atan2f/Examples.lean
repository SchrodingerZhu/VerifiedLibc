import LibcMath.Kernels.Atan2f.Plans

/-!
# Worked examples for extracted `atan2f` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Atan2f.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Atan2f.Generated

#guard (DoubleEvalSse2.kernel.eval .nearest f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (DoubleEvalSse42.kernel.eval .nearest f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (DoubleEvalAvx2Fma.kernel.eval .nearest f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (DoubleEvalAArch64.kernel.eval .nearest f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (FloatEval.kernel.eval .nearest f32(0x3FC00000#32) f32(0x3FC00000#32)).isSome

#guard (List.range 32).all fun i =>
  let x : Model .binary32 := .ofNatBits (0x3F800000 + i)
  Diag.sameResultBool (DoubleEvalSse2.kernel.eval .nearest x f32(0x3FC00000#32))
    (DoubleEvalSse42.kernel.eval .nearest x f32(0x3FC00000#32))

#guard (List.range 32).all fun i =>
  let x : Model .binary32 := .ofNatBits (0x3F800000 + i)
  Diag.sameResultBool (DoubleEvalSse2.kernel.eval .nearest x f32(0x3FC00000#32))
    (DoubleEvalAvx2Fma.kernel.eval .nearest x f32(0x3FC00000#32))

#guard (List.range 32).all fun i =>
  let x : Model .binary32 := .ofNatBits (0x3F800000 + i)
  Diag.sameResultBool (DoubleEvalSse2.kernel.eval .nearest x f32(0x3FC00000#32))
    (DoubleEvalAArch64.kernel.eval .nearest x f32(0x3FC00000#32))

end LibcMath.Kernels.Atan2f.Examples
