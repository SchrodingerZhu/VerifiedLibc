import LibcMath.Kernels.Expf.Proof.IntegerEval.ShortPaths.SymbolicExecution
import LibcMath.Kernels.Expf.Proof.StaticRounding.ShortPaths.Ranges
import LibcMath.Analysis.AddRounding
import LibcMath.Analysis.AddSpecial
import LibcMath.Analysis.ExpRanges

/-!
# `Generated.IntegerEval.kernel` on its short paths

For each rounding direction, `CorrectAt` on the ranges of bit patterns where the function returns
before its tables and its polynomial. Each range is proved at once: the result of the function
comes from `SymbolicExecution.lean`, and the prescribed result from the closed forms of
`LibcMath/Analysis/ExpRanges.lean`.

The ranges are those of `StaticRounding`, taken over through
`integerEval_eq_staticRounding_nearest`.
-/

namespace LibcMath.Kernels.Expf.Proof.IntegerEval.ShortPaths

open FloatLib.Floats.Formats.BinaryInterchange Model
open LibcMath.Libc.DSL

variable {mode : IEEERoundingMode}

/-- Short-path ranges of `Generated.IntegerEval.kernel` in `.nearest` mode, inherited directly from
`Generated.StaticRounding.kernel` via `integerEval_eq_staticRounding_nearest`. -/
theorem holdsOnBits_short_paths_integerEval :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.IntegerEval.kernel .nearest)
        0x00000000 0x33000000 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.IntegerEval.kernel .nearest)
        0x42B17218 0xB3000000 ∧
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.IntegerEval.kernel .nearest)
        0xC2CFF1B5 0x100000000 := by
  obtain ⟨h1, h2, h3⟩ :=
    StaticRounding.ShortPaths.holdsOnBits_short_paths_staticRounding (mode := .nearest)
      (by simp [cModes])
  have tr : ∀ {lo hi},
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.StaticRounding.kernel .nearest) lo hi →
      HoldsOnBits (CorrectAt (Spec.exp .binary32) Generated.IntegerEval.kernel .nearest) lo hi :=
    fun h => h.imp fun x hx => by
      obtain ⟨y, hy, hsame⟩ := hx
      exact ⟨y, by rw [integerEval_eq_staticRounding_nearest]; exact hy, hsame⟩
  exact ⟨tr h1, tr h2, tr h3⟩

end LibcMath.Kernels.Expf.Proof.IntegerEval.ShortPaths
