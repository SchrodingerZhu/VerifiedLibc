import LibcMath.Exhaustive.Interface
import LibcMath.Functions
import FloatLib.Floats.Formats.BinaryInterchange.Transcendentals.Directed.Runtime

/-!
# A stand-in for the oracle of `exp`

A placeholder with the type of the oracle `checkRange` takes, so that the machinery which runs
`checkRange` over blocks of inputs can be built and measured before the proved oracle exists.
`StandIn.oracle` accepts a result equal to the value of FloatLib's executable exponential
`Model.Transcendentals.Directed.exp`. Its soundness is not proved here, so a theorem obtained with
it is not yet a theorem about `exp`. `LibcMath.Exhaustive.Run.Target` selects the oracle in use.
-/

namespace LibcMath.Exhaustive.StandIn

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- Accepts the value of FloatLib's exponential in direction `mode`, and a NaN at a NaN. -/
def oracle : Oracle (Spec.exp .binary32) where
  check mode input result :=
    (input.isNaN && result.isNaN) ||
      decide (result = (Model.Transcendentals.Directed.exp input mode).value)
  sound := sorry

end LibcMath.Exhaustive.StandIn
