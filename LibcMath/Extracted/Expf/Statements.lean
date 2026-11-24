import LibcMath.Extracted.Expf.Plans
import LibcMath.Functions

/-!
# Correctness statements for extracted `expf` kernels

Each extracted evaluation plan is a Lean function returning `Option (Model .binary32)` checked
against `LibcMath.Spec`. By the definition of `CorrectlyRounded`, a proof includes that the
function reaches no operation that C++ leaves undefined.
-/

namespace LibcMath.Extracted

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- `math::double_eval::expf` (default x86-64, non-FMA) is correctly rounded in the four rounding
directions of C. -/
def ExpfDoubleEvalCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) cModes Expf.DoubleEval.expf

/-- `math::double_eval::expf` compiled with `-mavx2 -mfma` is correctly rounded in the four
rounding directions of C. -/
def ExpfDoubleEvalFmaCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) cModes Expf.DoubleEvalFma.expf

/-- `math::static_rounding::expf` (integer-only `Frac64`) is correctly rounded in the four
rounding directions of C. -/
def ExpfStaticRoundingCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) cModes Expf.StaticRounding.kernel

/-- `math::integer_eval::expf` (integer-only `Frac64`, RN-only) is correctly rounded in
round-to-nearest-even mode. -/
def ExpfIntegerEvalCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) {.nearest} Expf.IntegerEval.kernel

/-- `math::float_eval_cr_rn::expf` (GPU `FloatFloat` FMA, RN-only) is correctly rounded in
round-to-nearest-even mode. -/
def ExpfFloatEvalCrRnCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) {.nearest} Expf.FloatEvalCrRn.expf

/-- The default statement about `expf`: that of `double_eval`, across all four C rounding modes. -/
abbrev ExpfCorrectlyRounded : Prop :=
  ExpfDoubleEvalCorrectlyRounded

end LibcMath.Extracted
