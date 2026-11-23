import LibcMath.Exhaustive.Expf
import LibcMath.IR.Interp

/-!
# The interpreter computes the extracted `expf`
-/

namespace LibcMath.Extracted

open FloatLib.Floats.Formats.BinaryInterchange

/-- Results of the interpreter on `expf` are results of `expf`. -/
theorem expf_isComputedBy : expf.IsComputedBy (fmt := .binary32) expf.runUnary :=
  expf.runUnary_sound

end LibcMath.Extracted
