import LibcMath.Libc.DSL
import LibcMath.Testing.Oracle.FloatLib

/-!
# Worked checks for `LibcMath.FloatLibSpec`

Checks sample binary32 inputs on the FloatLib-backed evaluators across exponential,
logarithmic, trigonometric, hyperbolic, algebraic, and IEEE manipulation operations.
-/

namespace LibcMath.Testing.FloatLibOracleExamples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc.DSL
open LibcMath.FloatLibSpec

#guard exp2 .nearest f32(0x3F800000#32) == f32(0x40000000#32)
#guard exp10 .nearest f32(0x3F800000#32) == f32(0x41200000#32)
#guard expm1 .nearest f32(0x00000000#32) == f32(0x00000000#32)
#guard log2 .nearest f32(0x40000000#32) == f32(0x3F800000#32)
#guard log10 .nearest f32(0x41200000#32) == f32(0x3F800000#32)
#guard sinpi .nearest f32(0x3F000000#32) == f32(0x3F800000#32)
#guard cospi .nearest f32(0x3F800000#32) == f32(0xBF800000#32)
#guard cbrt .nearest f32(0x41000000#32) == f32(0x40000000#32)
#guard rsqrt .nearest f32(0x40800000#32) == f32(0x3F000000#32)
#guard hypot .nearest f32(0x40400000#32) f32(0x40800000#32) == f32(0x40A00000#32)
#guard pow .nearest f32(0x40000000#32) f32(0x40400000#32) == f32(0x41000000#32)
#guard atan2 .nearest f32(0x3F800000#32) f32(0x00000000#32) == f32(0x3FC90FDB#32)
#guard sinh .nearest f32(0x80000000#32) == f32(0x80000000#32)
#guard cosh .nearest f32(0x00000000#32) == f32(0x3F800000#32)
#guard tanh .nearest f32(0x80000000#32) == f32(0x80000000#32)
#guard fma .nearest f32(0x40000000#32) f32(0x40400000#32) f32(0x3F800000#32) == f32(0x40E00000#32)
#guard floor .nearest f32(0xBFC00000#32) == f32(0xC0000000#32)
#guard ceil .nearest f32(0x3FC00000#32) == f32(0x40000000#32)
#guard fmaximumNum .nearest f32(0x7FC00000#32) f32(0x3F800000#32) == f32(0x3F800000#32)

end LibcMath.Testing.FloatLibOracleExamples
