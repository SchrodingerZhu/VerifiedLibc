import LibcMath.Kernels.Expf.Proof.Common
import LibcMath.Kernels.Expf.Proof.StaticRounding.ShortPaths.SymbolicExecution

/-!
# The short paths of `Generated.IntegerEval.kernel`, evaluated symbolically

Evaluates `Generated.IntegerEval.kernel` (integer `Frac64`, round to nearest) on a symbolic
`Model.ofBits b` (`b : BitVec 32`) for every input that returns before the tables and the
polynomial. Each theorem says that the function has a result there, `some …`, and what it is: none
of the operations that C++ leaves undefined is reached on these paths, so no side condition has to
be proved.
-/

namespace LibcMath.Kernels.Expf.Proof.IntegerEval.ShortPaths

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open LibcMath.Libc
open LibcMath.Libc.DSL

variable {mode : IEEERoundingMode} (b : BitVec 32)

/-- `Generated.IntegerEval.kernel .nearest` is identical to
`Generated.StaticRounding.kernel .nearest` on every binary32 input (the
`#ifndef LIBC_MATH_HAS_ASSUME_ROUND_NEAREST_ONLY` branches are dead when
`rounding = FE_TONEAREST = 0`). -/
theorem integerEval_eq_staticRounding_nearest (x : Model .binary32) :
    Generated.IntegerEval.kernel .nearest x = Generated.StaticRounding.kernel .nearest x := by
  have hq : Libc.quickGetRound .nearest = 0x0#32 := rfl
  simp only [Generated.IntegerEval.kernel, Generated.StaticRounding.kernel,
    Generated.IntegerEval.expf, Generated.IntegerEval.math_static_rounding_expf,
    Generated.StaticRounding.expf, hq]
  have hbits : ∀ b : BitVec 32,
      Generated.IntegerEval.expf_bits b 0x0#32 = Generated.StaticRounding.expf_bits b 0x0#32 := by
    intro b
    unfold Generated.IntegerEval.expf_bits Generated.StaticRounding.expf_bits
    have heval : ∀ u_bits is_neg,
        Generated.IntegerEval.exp2f_eval_bits u_bits is_neg 0x0#32 =
          Generated.StaticRounding.exp2f_eval_bits u_bits is_neg 0x0#32 := by
      intro u_bits is_neg
      unfold Generated.IntegerEval.exp2f_eval_bits Generated.StaticRounding.exp2f_eval_bits
      have hc : ∀ a c, Libc.Frac64.mul Generated.IntegerEval.config a c =
          Libc.Frac64.mul Generated.StaticRounding.config a c := fun _ _ => rfl
      have he : Generated.IntegerEval.EXP2F_COEFFS = Generated.StaticRounding.EXP2F_COEFFS := rfl
      have hm : ∀ u2 (cs : List Libc.Frac64),
          Libc.polyevalList Generated.IntegerEval.config .nearest u2 cs =
            Libc.polyevalList Generated.StaticRounding.config .nearest u2 cs := by
        intro u2 cs
        induction cs with
        | nil => rfl
        | cons c cs ih =>
          cases cs with
          | nil => rfl
          | cons c' cs' =>
            simp only [Libc.polyevalList, Libc.PolyElem.madd, Libc.Frac64.mul]
            rw [ih]
            rfl
      have hma : ∀ (a c d : Libc.Frac64),
          Libc.PolyElem.madd Generated.IntegerEval.config .nearest a c d =
            Libc.PolyElem.madd Generated.StaticRounding.config .nearest a c d := fun _ _ _ => rfl
      simp only [hc, he, hm, hma, bne_self_eq_false, ↓reduceIte, Bool.false_eq_true]
    have hsc : ∀ x_u x_e,
        Generated.IntegerEval.exp_b_scale x_u x_e Generated.IntegerEval.LOG2_E 0x85#32 =
          Generated.StaticRounding.exp_b_scale x_u x_e Generated.StaticRounding.LOG2_E 0x85#32 :=
      fun _ _ => rfl
    simp [heval, hsc]
  rw [hbits]

end LibcMath.Kernels.Expf.Proof.IntegerEval.ShortPaths
