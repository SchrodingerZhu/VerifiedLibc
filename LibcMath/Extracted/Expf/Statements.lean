import LibcMath.Extracted.Expf.Plans
import LibcMath.Functions

/-!
# What is claimed about `expf`

One statement, about one evaluation plan: `math::double_eval::expf`, the default of LLVM libc on
x86-64, is correctly rounded in the four rounding directions of C. By the definition of
`CorrectlyRounded` this includes that the function reaches no operation that C++ leaves undefined.

The other extracted plans (`DoubleEvalFma`, `IntegerEval`, `StaticRounding`, `FloatEval`,
`FloatEvalCrRn`) have no statement here. They are extracted and compared with one another and
with the compiled code (`Examples.lean`, `scripts/difftest-expf.sh`), and nothing is proved about
them.
-/

namespace LibcMath.Extracted

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- `math::double_eval::expf` is correctly rounded in the four rounding directions of C. -/
def ExpfDoubleEvalCorrectlyRounded : Prop :=
  CorrectlyRounded (Spec.exp .binary32) cModes Expf.DoubleEval.expf

/-- The statement about `expf`: that of its default plan. -/
abbrev ExpfCorrectlyRounded : Prop :=
  ExpfDoubleEvalCorrectlyRounded

end LibcMath.Extracted
