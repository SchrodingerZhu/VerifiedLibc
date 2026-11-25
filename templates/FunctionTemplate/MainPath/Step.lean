import LibcMath.Framework.Correctness
import LibcMath.Kernels.Fn.Plans
import LibcMath.Analysis.RoundingTransfer
import LibcMath.Analysis.RangeReduction
import LibcMath.Analysis.Horner
import LibcMath.Analysis.ChebTmd

/-!
# Main-path numerical analysis steps for `<fn>`

Split the main computation into one file per analytical step (see `LibcMath/Kernels/Expf/MainPath/`):
1. `RangeReduction.lean` — UB-freedom and exact range reduction.
2. `Polynomial.lean` — real approximation error `|poly r - f r|`.
3. `HornerError.lean` — floating-point evaluation error across `cModes`.
4. `TableBounds.lean` — lookup-table relative error certified via rational enclosures.
5. `ProductError.lean` — combined value bound `|v - f x| ≤ ε * |f x|`.
6. `PointwiseExceptions.lean` — isolated hard-to-round and edge-case inputs via oracle + kernel.
7. `Tmd/` — Chebyshev SLZ rounding-boundary clearance using `LibcMath.Analysis.ChebTmd`.

Keep any unproved step as a named `sorry` lemma whose docstring begins with `**Open.**`, and run
`python3 scripts/check-open.py --update`.
-/

namespace LibcMath.Kernels.Fn.MainPath

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- **Open.** Replace with the specific analytical step and a Sollya/Gappa-checked error bound. -/
theorem correctAt_plan_main {mode : IEEERoundingMode} (hmode : mode ∈ cModes)
    {lo hi : ℕ} :
    HoldsOnBits (CorrectAt (Spec.fn .binary32) Generated.Plan.fn mode) lo hi := by
  sorry

end LibcMath.Kernels.Fn.MainPath
