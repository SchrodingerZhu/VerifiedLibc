import LibcMath.Extracted.Expf.Plans
import LibcMath.Extracted.Expf.Examples
import LibcMath.Extracted.Expf.Statements
import LibcMath.Extracted.Expf.Paths.Exec
import LibcMath.Extracted.Expf.Paths.Ranges
import LibcMath.Extracted.Expf.Main
import LibcMath.Extracted.Expf.Polynomial

/-!
# `expf`

Everything about one function lives in one directory, here `LibcMath/Extracted/Expf/`:

* the generated evaluation plans (`DoubleEval`, `DoubleEvalFma`, `IntegerEval`, `StaticRounding`,
  `FloatEval`, `FloatEvalCrRn`), their catalogue `Plans` and their checks `Examples`;
* `Statements`: what is claimed about each plan;
* `Paths/`: the inputs that take a short path, proved for whole ranges;
* `Polynomial`: the error of the polynomial of the main path;
* `Exhaustive`: the reduction from blocks of bit patterns, instantiated for `expf`;
* `Main`: the plans are correctly rounded, given their main ranges.

A new function gets a directory of the same shape next to this one. What does not depend on the
function stays outside: `LibcMath/Core/`, `LibcMath/Exhaustive/`, `LibcMath/Functions/` (facts
about real functions and rounding) and `LibcMath/Oracle/`.
-/
