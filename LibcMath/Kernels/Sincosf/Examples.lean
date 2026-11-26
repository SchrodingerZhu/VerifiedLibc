import LibcMath.Kernels.Sincosf.Plans

/-!
# Worked examples for extracted `sincosf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Sincosf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Sincosf.Generated



end LibcMath.Kernels.Sincosf.Examples
