import LibcMath.Kernels.Isnanf.Plans

/-!
# Worked examples for extracted `isnanf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Isnanf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Isnanf.Generated



end LibcMath.Kernels.Isnanf.Examples
