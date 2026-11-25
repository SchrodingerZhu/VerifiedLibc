import LibcMath.Kernels.Expf.Examples
import LibcMath.Kernels.Expf.Plans
import LibcMath.Kernels.Expf.Statement
import LibcMath.Kernels.Expf.Proof.DoubleEval
import LibcMath.Kernels.Expf.Proof.DoubleEvalFma
import LibcMath.Kernels.Expf.Proof.IntegerEval
import LibcMath.Kernels.Expf.Proof.StaticRounding

/-!
# `expf`: where everything is

Every statement and theorem names its evaluation plan; there is no default plan.

* `double_eval`: **complete**, `Proof.DoubleEval.expfDoubleEval_correctlyRounded`.
* `double_eval_fma`: short paths only,
  `Proof.DoubleEvalFma.expfDoubleEvalFmaCorrectlyRounded_of_mainRanges`.
* `static_rounding`: short paths only,
  `Proof.StaticRounding.expfStaticRoundingCorrectlyRounded_of_mainRanges`.
* `integer_eval`: short paths only,
  `Proof.IntegerEval.expfIntegerEvalCorrectlyRounded_of_staticRounding`.
* `float_eval`, `float_eval_cr_rn`: extracted and tested; no statement is proved.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan, with `Proof/<Plan>/ShortPaths/` (inputs that
  return before the tables and the polynomial) and `Proof/<Plan>/MainPath/` (the others).
* `Proof/Common.lean`: facts about bit patterns that the plans share.
* `Examples.lean`: worked evaluations.
-/
