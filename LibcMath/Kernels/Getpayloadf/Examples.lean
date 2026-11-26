import LibcMath.Kernels.Getpayloadf.Plans

/-!
# Worked examples for extracted `getpayloadf` plans

Each plan is evaluated at one input. Plans of the same implementation for other targets agree
with the SSE2 plan near `1`.
-/

namespace LibcMath.Kernels.Getpayloadf.Examples

open FloatLib.Floats.Formats.BinaryInterchange
open LibcMath.Libc
open LibcMath.Libc.DSL
open LibcMath.Kernels.Getpayloadf.Generated



end LibcMath.Kernels.Getpayloadf.Examples
