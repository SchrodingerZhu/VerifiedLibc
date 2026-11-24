import LibcMath.Fn.Plans
import LibcMath.Framework.Specs

/-!
# Correctness statements for extracted `<fn>` kernels
-/

namespace LibcMath.Fn

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- Correct rounding of the default extracted `<fn>` plan in the four rounding directions of C. -/
def FnCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.fn .binary32) cModes Generated.Default.fn

end LibcMath.Fn
