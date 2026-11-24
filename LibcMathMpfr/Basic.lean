/-!
# Functions computed by MPFR

Declarations of the functions that `c/mpfr_oracle.c` implements. This module imports nothing and
is compiled ahead of time (`precompileModules` in `lakefile.lean`), so that the C code is loaded
when a module that imports it is elaborated.

Lean knows nothing about these functions beyond their types. What they compute is stated as an
axiom where they are used (`LibcMath/Oracle/Mpfr.lean`).
-/

namespace LibcMathMpfr

/-- The bit pattern of the correctly rounded binary32 exponential of the argument with bit pattern
`x`, as MPFR computes it. `mode` is `0` to nearest, `1` toward zero, `2` upward, `3` downward. -/
@[extern "libcmath_mpfr_expf"]
opaque expfBits (mode : UInt8) (x : UInt32) : UInt32

end LibcMathMpfr
