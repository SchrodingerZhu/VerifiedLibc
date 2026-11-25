import LibcMath.Kernels.Expf.Plans
import LibcMath.Framework.Specs

/-!
# Correctness statements for extracted `expf` kernels

Each extracted evaluation plan is a Lean function returning `Option (Model .binary32)` checked
against `LibcMath.Spec`. By the definition of `CorrectlyRounded`, a proof includes that the
function reaches no operation that C++ leaves undefined.
-/

namespace LibcMath.Kernels.Expf

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- `math::double_eval::expf` (x86-64, non-FMA, `LIBC_MATH=0`) is correctly rounded in the four
rounding directions of C. -/
def ExpfDoubleEvalCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) cModes Generated.DoubleEval.expf

/-- `math::double_eval::expf` compiled with `-mavx2 -mfma` is correctly rounded in the four
rounding directions of C. -/
def ExpfDoubleEvalFmaCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) cModes Generated.DoubleEvalFma.expf

/-- `math::static_rounding::expf` (integer-only `Frac64`) is correctly rounded in the four
rounding directions of C. -/
def ExpfStaticRoundingCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) cModes Generated.StaticRounding.kernel

/-- `math::integer_eval::expf` (integer-only `Frac64`, RN-only) is correctly rounded in
round-to-nearest-even mode. -/
def ExpfIntegerEvalCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) {.nearest} Generated.IntegerEval.kernel

/-- `math::float_eval_cr_rn::expf` (GPU `FloatFloat` FMA, RN-only) is correctly rounded in
round-to-nearest-even mode. -/
def ExpfFloatEvalCrRnCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) {.nearest} Generated.FloatEvalCrRn.expf

/-- `math::float_eval::expf` (fast single precision, `LIBC_MATH=0x3F`, RN-only) reaches no
operation that C++ leaves undefined. The plan is not correctly rounded, so this is its statement. -/
def ExpfFloatEvalDefined : Prop :=
  ∀ x : Model .binary32, (Generated.FloatEval.expf .nearest x).isSome

/-- `math::double_eval::expf` compiled with `-msse4.2 -mno-fma` is correctly rounded in all four
rounding modes of C. -/
def ExpfDoubleEvalSse42CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) cModes Generated.DoubleEvalSse42.expf

/-- `math::double_eval::expf` compiled for AArch64 is correctly rounded in all four rounding modes
of C. -/
def ExpfDoubleEvalAArch64CorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) cModes Generated.DoubleEvalAArch64.expf

end LibcMath.Kernels.Expf
