import LibcMath.Kernels.Expf.Examples
import LibcMath.Kernels.Expf.Plans
import LibcMath.Kernels.Expf.Statement
import LibcMath.Kernels.Expf.Proof.DoubleEval
import LibcMath.Kernels.Expf.Proof.DoubleEvalFma
import LibcMath.Kernels.Expf.Proof.IntegerEval
import LibcMath.Kernels.Expf.Proof.StaticRounding
import LibcMath.Kernels.Expf.Proof.FloatEval
import LibcMath.Kernels.Expf.Proof.FloatEvalCrRn
import LibcMath.Kernels.Expf.Proof.DoubleEvalSse42
import LibcMath.Kernels.Expf.Proof.DoubleEvalAArch64

/-!
# `expf`: where everything is

Every statement and theorem names its evaluation plan; there is no default plan.

* `double_eval`: **complete**, `Proof.DoubleEval.expfDoubleEval_correctlyRounded`.
* `double_eval_fma`: `Proof.DoubleEvalFma.expfDoubleEvalFma_correctlyRounded`. The short paths
  are proved; the main ranges are open (`expfDoubleEvalFma_mainRangesChecked`).
* `static_rounding`: `Proof.StaticRounding.expfStaticRounding_correctlyRounded`. The short paths
  are proved; the main ranges are open (`expfStaticRounding_mainRangesChecked`).
* `integer_eval`: `Proof.IntegerEval.expfIntegerEval_correctlyRounded`, from `static_rounding`.
* `double_eval_sse42`: open, `Proof.DoubleEvalSse42.expfDoubleEvalSse42_correctlyRounded`.
* `double_eval_aarch64`: open, `Proof.DoubleEvalAArch64.expfDoubleEvalAArch64_correctlyRounded`.
* `float_eval_cr_rn`: open, `Proof.FloatEvalCrRn.expfFloatEvalCrRn_correctlyRounded`.
* `float_eval`: not correctly rounded; its definedness is open,
  `Proof.FloatEval.expfFloatEval_defined`.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan, with `Proof/<Plan>/ShortPaths/` (inputs that
  return before the tables and the polynomial) and `Proof/<Plan>/MainPath/` (the others).
* `Proof/Common.lean`: facts about bit patterns that the plans share.
* `Examples.lean`: worked evaluations.
-/
