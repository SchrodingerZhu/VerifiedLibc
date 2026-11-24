import LibcMath.Extracted.Expf.Plans
import LibcMath.Functions

/-!
# Correctness statements for extracted math kernels

Each extracted evaluation plan is a direct total Lean function (`Core.UnaryKernel .binary32`)
checked against `LibcMath.Spec`. No IR interpreter or relational bridge sits between the extracted
code and `CorrectlyRounded`.
-/

namespace LibcMath.Extracted

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- Correct rounding of upstream `math::double_eval::expf` (default x86-64, non-FMA) across all
four IEEE rounding directions of C. -/
def ExpfDoubleEvalCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) cModes Expf.DoubleEval.expf

/-- Correct rounding of upstream `math::double_eval::expf` compiled with `-mavx2 -mfma` across all
four IEEE rounding directions of C. -/
def ExpfDoubleEvalFmaCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) cModes Expf.DoubleEvalFma.expf

/-- Correct rounding of upstream `math::static_rounding::expf` (integer-only `Frac64`) across all
four IEEE rounding directions of C. -/
def ExpfStaticRoundingCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) cModes Expf.StaticRounding.kernel

/-- Correct rounding of upstream `math::integer_eval::expf` (integer-only `Frac64`, RN-only) in
round-to-nearest-even mode. -/
def ExpfIntegerEvalCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) {.nearest} Expf.IntegerEval.kernel

/-- Correct rounding of upstream `math::float_eval_cr_rn::expf` (GPU `FloatFloat` FMA, RN-only) in
round-to-nearest-even mode. -/
def ExpfFloatEvalCrRnCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) {.nearest} Expf.FloatEvalCrRn.expf

/-- Default top-level correctness statement for `expf` (`double_eval`, all four C rounding modes). -/
abbrev ExpfCorrectlyRounded : Prop :=
  ExpfDoubleEvalCorrectlyRounded

end LibcMath.Extracted
