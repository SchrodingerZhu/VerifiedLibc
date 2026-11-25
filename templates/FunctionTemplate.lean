import LibcMath.Kernels.Fn.Plans
import LibcMath.Kernels.Fn.Statement
import LibcMath.Kernels.Fn.Proof.Plan
import LibcMath.Kernels.Fn.Examples

/-!
# `<fn>`: where everything is

List each extracted plan here with its state (complete, short paths only, extracted only) and the
name of its theorem. Every statement and theorem names its evaluation plan; there is no default.

* `Generated/`: the plans as `ast2lean` writes them. `Plans.lean` lists them.
* `Statement.lean`: what is to be proved about each plan.
* `Proof/<Plan>.lean`: the theorem for one plan, with `Proof/<Plan>/ShortPaths/` and
  `Proof/<Plan>/MainPath/`.
* `Proof/Common.lean`: facts that the plans share, if there are any.
-/
