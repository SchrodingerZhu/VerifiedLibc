import LibcMath.Extracted.ExpfStructured

/-!
# From block 15 on, the interpreter computes `expfMain`

`execFrom_block15` states that the interpreter, started at block 15 of the extracted `expf` with
the argument in register 0, returns `expfMain` of the argument, for every argument and rounding
direction. Its proof executes the blocks one instruction at a time (`execBody_cons`): an
arithmetic result is stored as `AbsVal.ofFloat z`, the first instruction that reads it yields
`nonNaN z >>= …`, and `nonNaN_bind_congr` continues on both sides under `z.isNaN = false`.

Status: every tactic step below elaborates, but Lean's kernel did not finish checking the proof
term of `execFrom_block20` (the 22 instructions of block 20) within twenty-five minutes, while the
first eight of its steps are checked within seconds. Until that is resolved this file is not
imported by any other, and `ExpfStructuredOpen.lean` states `execFrom_block15` as an open theorem.
-/

namespace LibcMath.Extracted

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)
open IR

/-- The binary32 value with bit pattern `b`. -/
local notation "f32(" b ")" => (Model.ofBits b : Model FloatFormat.binary32)

private theorem table0 : expf.tables[0]? = some ⟨64, expM1⟩ := rfl

private theorem table1 : expf.tables[1]? = some ⟨64, expM2⟩ := rfl

attribute [local irreducible] expM1 expM2

private theorem block15 : expf.blocks[15]? = some
    ⟨[], [(26, .fBin .binary32 .fmul (.reg 0) (.const 32 0x43000000)),
      (27, .fabs .binary32 (.reg 26)),
      (28, .fcmp .binary32 .olt (.reg 27) (.const 32 0x4B800000))],
      .condBr (.reg 28) 16 20⟩ := rfl

private theorem block16 : expf.blocks[16]? = some
    ⟨[], [(29, .fcmp .binary32 .olt (.reg 26) (.const 32 0x0)),
      (30, .fBin .binary32 .fadd (.reg 26) (.const 32 0xCB000000)),
      (31, .fBin .binary32 .fadd (.reg 30) (.const 32 0x4B000000)),
      (32, .fBin .binary32 .fadd (.reg 26) (.const 32 0x4B000000)),
      (33, .fBin .binary32 .fadd (.reg 32) (.const 32 0xCB000000)),
      (34, .select (.reg 29) (.reg 31) (.reg 33)),
      (35, .fBin .binary32 .fsub (.reg 26) (.reg 34)),
      (36, .fcmp .binary32 .ogt (.reg 35) (.const 32 0x3F000000))],
      .condBr (.reg 36) 17 18⟩ := rfl

private theorem block17 : expf.blocks[17]? = some
    ⟨[], [(37, .fBin .binary32 .fadd (.reg 34) (.const 32 0x3F800000))], .br 20⟩ := rfl

private theorem block18 : expf.blocks[18]? = some
    ⟨[], [(38, .fcmp .binary32 .olt (.reg 35) (.const 32 0xBF000000))],
      .condBr (.reg 38) 19 20⟩ := rfl

private theorem block19 : expf.blocks[19]? = some
    ⟨[], [(39, .fBin .binary32 .fadd (.reg 34) (.const 32 0xBF800000))], .br 20⟩ := rfl

/-- The instructions of block 20: the reduced argument, the table entries, the polynomial and
the product. -/
private def body20 : List (Reg × Instr) :=
  [(41, .fBin .binary32 .fmul (.reg 40) (.const 32 0x3C000000)),
    (42, .fBin .binary32 .fsub (.reg 0) (.reg 41)),
    (43, .fpConvert .binary32 .binary64 (.reg 42)),
    (44, .fptosi .binary32 32 (.reg 40)),
    (45, .intBin .add (.reg 44) (.const 32 0x3400)),
    (46, .intBin .ashr (.reg 45) (.const 32 0x7)),
    (47, .sext 64 (.reg 46)),
    (48, .load 0 (.reg 47)),
    (49, .intBin .and (.reg 44) (.const 32 0x7F)),
    (50, .zext 64 (.reg 49) { nneg := true }),
    (51, .load 1 (.reg 50)),
    (52, .fBin .binary64 .fmul (.reg 43) (.const 64 0x3FA55555555EF243)),
    (53, .fBin .binary64 .fadd (.reg 52) (.const 64 0x3FC555566668E5E7)),
    (54, .fBin .binary64 .fmul (.reg 53) (.reg 43)),
    (55, .fBin .binary64 .fadd (.reg 54) (.const 64 0x3FE000000000071C)),
    (56, .fBin .binary64 .fmul (.reg 55) (.reg 43)),
    (57, .fBin .binary64 .fadd (.reg 56) (.const 64 0x3FEFFFFFFFFFF777)),
    (58, .fBin .binary64 .fmul (.reg 57) (.reg 43)),
    (59, .fBin .binary64 .fadd (.reg 58) (.const 64 0x3FF0000000000000)),
    (60, .fBin .binary64 .fmul (.reg 48) (.reg 51)),
    (61, .fBin .binary64 .fmul (.reg 60) (.reg 59)),
    (62, .fpConvert .binary64 .binary32 (.reg 61))]

private theorem block20 : expf.blocks[20]? = some
    ⟨[(40, [(18, .reg 34), (17, .reg 37), (19, .reg 39), (15, .reg 26)])], body20,
      .br 21⟩ := rfl

private theorem block21 : expf.blocks[21]? = some
    ⟨[(63, [(1, .reg 4), (4, .reg 11), (20, .reg 62), (6, .const 32 0x0), (7, .reg 0),
      (9, .const 32 0x0), (14, .reg 25), (8, .const 32 0x1), (12, .const 32 0x7F7FFFFF)])], [],
      .ret (.reg 63)⟩ := rfl

variable {mode : IEEERoundingMode}

private theorem ashr_defined (a : BitVec 32) : IntBinOp.ashr.defined { } a 0x7#32 = true :=
  IntBinOp.defined_ashr a _ (by decide)

private theorem zext_defined (a : BitVec 32) :
    Flags.zextDefined { nneg := true } (a &&& 0x7F#32) = true :=
  Flags.zextDefined_nneg _
    (by rw [BitVec.msb_and, show (0x7F#32).msb = false from rfl, Bool.and_false])

/-- Evaluate the instruction at the head of the goal. -/
local macro "eval_instr" : tactic =>
  `(tactic| simp only [Instr.exec, FBinOp.eval, FCmp.eval_olt, FCmp.eval_ogt, IntBinOp.eval,
    IntBinOp.defined_add, IntBinOp.defined_and, ashr_defined, zext_defined, table0, table1,
    Operand.execFloat_eq, Operand.exec, Operand.execExact, Operand.execBool,
    AbsVal.toModel?_exact, AbsVal.toModel?_ofFloat, Store.get_set, Val.toModel?_binary32,
    Val.toModel?_binary64, Val.toModel?_ofModel, Val.ofNat, Val.toBool?_ofBool,
    FastMathFlags.admits_default, bind_eq_optionBind, Option.bind_some, BitVec.cast_eq,
    ↓reduceDIte, ↓reduceIte, Nat.reduceEqDiff, Bool.and_self, *])

/-- Execute the first remaining instruction of a block. -/
local macro "instr" : tactic => `(tactic| (rw [execBody_cons]; eval_instr))

/-- Continue on both sides past an arithmetic result that is not a NaN. -/
local macro "nan_step" : tactic =>
  `(tactic| (subst_vars
             rw [Option.bind_assoc, Option.bind_assoc]
             refine nonNaN_bind_congr fun hz _ _ => ?_
             have := nonNaN_of_isNaN_eq_false hz
             simp only [Option.bind_some]))

/-- Continue on both sides past an integer or a table entry that exists. -/
local macro "bind_step" : tactic =>
  `(tactic| (subst_vars
             rw [Option.bind_assoc, Option.bind_assoc]
             refine bind_congr_of_forall fun _ _ _ => ?_
             simp only [Option.bind_some]))

set_option maxHeartbeats 0 in
/-- Blocks 20 and 21, entered with `k` in register 40. -/
private theorem execFrom_block20 (fuel pred : ℕ) (s : Store) (x k : Model .binary32)
    (hx : s.get 0 = some (.exact (.ofModel x)))
    (hk : enterPhis pred s s [(40, [(18, .reg 34), (17, .reg 37), (19, .reg 39), (15, .reg 26)])] =
      some (s.set 40 (.ofFloat k))) :
    (expf.execFrom mode (fuel + 2) pred 20 s).bind (AbsVal.result? .binary32) =
      (nonNaN k).bind fun k => expfOfNearestInt mode x k := by
  rw [Func.execFrom_of_block block20, hk]
  generalize hR : ((nonNaN k).bind fun k => expfOfNearestInt mode x k) = R
  simp only [↓expfOfNearestInt, ↓expfReduce, ↓expfPoly, ↓Option.bind_eq_bind,
    ↓Option.bind_assoc] at hR
  simp only [Option.bind_some, Option.bind_assoc, body20]
  instr
  nan_step
  instr
  nan_step
  instr
  nan_step
  rw [execBody_cons, Instr.exec_fptosi]
  eval_instr
  bind_step
  instr
  instr
  instr
  instr
  bind_step
  instr
  instr
  instr
  bind_step
  instr
  nan_step
  instr
  nan_step
  instr
  nan_step
  instr
  nan_step
  instr
  nan_step
  instr
  nan_step
  instr
  nan_step
  instr
  nan_step
  instr
  instr
  -- The product reads the table entries before the polynomial; `expfOfNearestInt` binds them
  -- in the other order.
  subst_vars
  rw [Option.bind_assoc, Option.bind_assoc]
  conv_rhs => rw [Option.bind_comm]
  refine nonNaN_bind_congr fun hz _ _ => ?_
  have := nonNaN_of_isNaN_eq_false hz
  subst_vars
  rw [Option.bind_assoc]
  refine nonNaN_bind_congr fun hz _ _ => ?_
  have := nonNaN_of_isNaN_eq_false hz
  simp only [Option.bind_some]
  instr
  nan_step
  rw [execBody_nil, Option.bind_some, Func.execFrom_of_block block21]
  simp only [enterPhis, execBody_nil, List.lookup, Nat.reduceBEq, Operand.exec, Store.get_set,
    Nat.reduceEqDiff, ↓reduceIte, Option.bind_some, AbsVal.result?_ofFloat]
  assumption

private theorem ite_some {α : Type} (c : Prop) [Decidable c] (a b : α) :
    (if c then some a else some b) = some (if c then a else b) := by
  split <;> rfl

private theorem ite_ofFloat (c : Prop) [Decidable c] (p q : Model .binary32) :
    (if c then AbsVal.ofFloat p else AbsVal.ofFloat q) = AbsVal.ofFloat (if c then p else q) := by
  split <;> rfl

/-- Enter a block without phi nodes. -/
local macro "enter" : tactic =>
  `(tactic| simp only [enterPhis, Option.bind_some, Option.bind_assoc])

/-- Leave a block whose instructions have been executed. -/
local macro "leave" : tactic =>
  `(tactic| (rw [execBody_nil]; eval_instr))

/-- Discharge the hypotheses of `execFrom_block20`. -/
local macro "block20_hyp" : tactic =>
  `(tactic| simp only [enterPhis, List.lookup, Nat.reduceBEq, Operand.exec, Store.get_set,
    Nat.reduceEqDiff, ↓reduceIte, Option.bind_some, bind_eq_optionBind, *])

set_option maxHeartbeats 0 in
/-- Blocks 15 to 21: from block 15 on, the interpreter computes `expfMain`. -/
theorem execFrom_block15 (fuel pred : ℕ) (s : Store) (x : Model .binary32)
    (hx : s.get 0 = some (.exact (.ofModel x))) :
    (expf.execFrom mode (fuel + 6) pred 15 s).bind (AbsVal.result? .binary32) =
      expfMain mode x := by
  rw [Func.execFrom_of_block block15]
  generalize hR : expfMain mode x = R
  simp only [↓expfMain, ↓expfNearestInt, ↓Option.bind_eq_bind, ↓Option.bind_assoc] at hR
  enter
  instr
  instr
  nan_step
  instr
  leave
  subst_vars
  generalize (Model.compare _ f32(0x4B800000#32) == some Ordering.lt) = c
  cases c <;> simp only [↓reduceIte, Bool.false_eq_true]
  · exact execFrom_block20 _ 15 _ x _ (by block20_hyp) (by block20_hyp)
  rw [Func.execFrom_of_block block16]
  enter
  instr
  instr
  instr
  nan_step
  instr
  instr
  nan_step
  instr
  simp only [ite_some, ite_ofFloat, Option.bind_some]
  instr
  subst_vars
  rw [Option.bind_assoc, Option.bind_assoc]
  refine nonNaN_bind_congr fun hk₀ _ _ => ?_
  have ek₀ := nonNaN_of_isNaN_eq_false hk₀
  simp only [Option.bind_some]
  instr
  nan_step
  leave
  subst_vars
  generalize (Model.compare _ f32(0x3F000000#32) == some Ordering.gt) = c
  cases c <;> simp only [↓reduceIte, Bool.false_eq_true]
  · rw [Func.execFrom_of_block block18]
    enter
    instr
    leave
    generalize (Model.compare _ f32(0xBF000000#32) == some Ordering.lt) = c
    cases c <;> simp only [↓reduceIte, Bool.false_eq_true]
    · rw [← ek₀]
      exact execFrom_block20 _ 18 _ x _ (by block20_hyp) (by block20_hyp)
    · rw [Func.execFrom_of_block block19]
      enter
      instr
      leave
      exact execFrom_block20 _ 19 _ x _ (by block20_hyp) (by block20_hyp)
  · rw [Func.execFrom_of_block block17]
    enter
    instr
    leave
    exact execFrom_block20 _ 17 _ x _ (by block20_hyp) (by block20_hyp)

end LibcMath.Extracted
