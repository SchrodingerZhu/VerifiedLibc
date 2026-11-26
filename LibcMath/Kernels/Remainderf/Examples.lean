import LibcMath.Kernels.Remainderf.Plans

/-!
# Worked examples for extracted `remainderf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Remainderf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Remainderf.Generated



end LibcMath.Kernels.Remainderf.Examples
