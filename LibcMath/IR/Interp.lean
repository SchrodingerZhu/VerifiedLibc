import LibcMath.IR.Semantics
import LibcMath.SpecLemmas

/-!
# An interpreter for extracted code

`Func.run` executes a `Func` on given arguments, and `Func.runUnary` does so for a unary
floating-point function. Both are computable and are meant to be run on every input of a format.

`Func.Returns` does not determine the result of a function: an arithmetic instruction may return
any NaN where FloatLib returns one, and `raiseExcept` returns an unspecified integer. The
interpreter therefore computes with an `AbsVal` per register, which is either the exact value of
the register or a description of the values it may hold. Instructions that copy a value (`phi`,
`select`, `bitcast`, `ret`) accept any `AbsVal`; every other instruction needs exact operands, and
the interpreter gives up (`none`) otherwise. In particular it gives up when a NaN produced by
arithmetic is the operand of further arithmetic.

The soundness theorems are `Func.exec_sound`, `Func.run_sound`, `Func.runFloat_sound` and
`Func.runUnary_sound`: when the interpreter answers, the function can return the answer, and
every result it can return is described by the answer.
-/

namespace LibcMath.IR

open FloatLib.Floats.Formats.BinaryInterchange
open FloatLib.Floats.ExecFloat (ConversionOutcome)
open Model (IEEERoundingMode)

namespace Val

/-- The value read as a boolean, if it has width one. -/
def toBool? (v : Val) : Option Bool :=
  if h : v.width = 1 then some (v.bits.cast h == 1#1) else none

theorem eq_ofBool_of_toBool? {v : Val} {c : Bool} (h : v.toBool? = some c) : v = .ofBool c := by
  obtain ⟨w, bits⟩ := v
  unfold toBool? at h
  split at h
  · rename_i hw
    change w = 1 at hw
    subst hw
    cases Option.some.inj h
    simp only [ofBool, BitVec.cast_eq]
    congr 1
    revert bits
    decide
  · cases h

@[simp]
theorem toBool?_ofBool (c : Bool) : (ofBool c).toBool? = some c := by
  cases c <;> rfl

theorem ofBool_injective : Function.Injective ofBool := fun a b h => by
  simpa using congrArg toBool? h

theorem eq_ofModel_of_toModel? {fmt : FloatFormat} {v : Val} {x : Model fmt}
    (h : v.toModel? fmt = some x) : v = .ofModel x := by
  obtain ⟨w, bits⟩ := v
  unfold toModel? at h
  split at h
  · rename_i hw
    change w = fmt.bitWidth at hw
    subst hw
    cases Option.some.inj h
    rfl
  · cases h

end Val

/-- What the interpreter knows about the value of a register. -/
inductive AbsVal where
  /-- The register holds `v`. -/
  | exact (v : Val)
  /-- The register holds some NaN of format `fmt`. `x` is the one FloatLib computes. -/
  | nan (fmt : FloatFormat) (x : Model fmt) (h : x.isNaN = true)
  /-- The register holds some value of the given width. -/
  | any (width : ℕ)

namespace AbsVal

/-- `v` is one of the values described by `a`. -/
@[grind]
def Admits : AbsVal → Val → Prop
  | exact v, r => r = v
  | nan fmt _ _, r => ∃ y : Model fmt, r = .ofModel y ∧ y.isNaN = true
  | any width, r => r.width = width

/-- A value described by `a`. -/
def toVal : AbsVal → Val
  | exact v => v
  | nan _ x _ => .ofModel x
  | any width => .ofNat width 0

theorem admits_toVal (a : AbsVal) : a.Admits a.toVal := by
  cases a with
  | exact v => rfl
  | nan fmt x h => exact ⟨x, rfl, h⟩
  | any width => rfl

/-- The result of an arithmetic instruction for which FloatLib computes `z`. -/
def ofFloat {fmt : FloatFormat} (z : Model fmt) : AbsVal :=
  if h : z.isNaN = true then nan fmt z h else exact (.ofModel z)

theorem ofFloat_admits_iff {fmt : FloatFormat} (z : Model fmt) (r : Val) :
    (ofFloat z).Admits r ↔ r.Encodes z := by
  unfold ofFloat Val.Encodes SameValue
  split
  · rename_i h
    constructor
    · rintro ⟨y, rfl, hy⟩
      exact ⟨y, Val.toModel?_ofModel y, .inr ⟨hy, h⟩⟩
    · rintro ⟨y, hy, hyz | ⟨hy', -⟩⟩
      · exact ⟨y, Val.eq_ofModel_of_toModel? hy, hyz ▸ h⟩
      · exact ⟨y, Val.eq_ofModel_of_toModel? hy, hy'⟩
  · rename_i h
    constructor
    · rintro rfl
      exact ⟨z, Val.toModel?_ofModel z, .inl rfl⟩
    · rintro ⟨y, hy, rfl | ⟨-, hz⟩⟩
      · exact Val.eq_ofModel_of_toModel? hy
      · exact absurd hz h

end AbsVal

/-- The registers assigned so far, indexed by register number. -/
abbrev Store := Array (Option AbsVal)

namespace Store

def ofArgs (args : List Val) : Store := args.toArray.map fun v => some (.exact v)

def get (s : Store) (r : Reg) : Option AbsVal := s[r]?.join

def set (s : Store) (r : Reg) (a : AbsVal) : Store :=
  if r < s.size then s.setIfInBounds r (some a)
  else (s ++ Array.replicate (r - s.size) none).push (some a)

@[grind =]
theorem get_set (s : Store) (r r' : Reg) (a : AbsVal) :
    (s.set r a).get r' = if r' = r then some a else s.get r' := by
  grind [set, get]

attribute [local grind] Env.set

/-- Every register assigned in `s` is assigned in `env`, to a value that `s` describes. -/
@[grind]
def Sim (s : Store) (env : Env) : Prop :=
  ∀ r a, s.get r = some a → ∃ v, env r = some v ∧ a.Admits v

theorem Sim.set {s : Store} {env : Env} (h : s.Sim env) (r : Reg) {a : AbsVal} {v : Val}
    (hv : a.Admits v) : (s.set r a).Sim (env.set r v) := by
  grind

/-- Every register assigned in `s` is assigned in `env`, to the value `AbsVal.toVal` selects. -/
@[grind]
def Tight (s : Store) (env : Env) : Prop :=
  ∀ r a, s.get r = some a → env r = some a.toVal

theorem Tight.sim {s : Store} {env : Env} (h : s.Tight env) : s.Sim env :=
  fun r a ha => ⟨a.toVal, h r a ha, a.admits_toVal⟩

theorem Tight.set {s : Store} {env : Env} (h : s.Tight env) (r : Reg) (a : AbsVal) :
    (s.set r a).Tight (env.set r a.toVal) := by
  grind

theorem tight_ofArgs (args : List Val) : (ofArgs args).Tight (Env.ofArgs args) := by
  grind [get, ofArgs, Env.ofArgs, AbsVal.toVal]

theorem sim_ofArgs (args : List Val) : (ofArgs args).Sim (Env.ofArgs args) :=
  (tight_ofArgs args).sim

end Store

namespace Operand

def exec (s : Store) : Operand → Option AbsVal
  | reg r => s.get r
  | const width bits => some (.exact (.ofNat width bits))

/-- The operand, if its value is known exactly. -/
def execExact (s : Store) (a : Operand) : Option Val :=
  match a.exec s with
  | some (.exact v) => some v
  | _ => none

def execBool (s : Store) (a : Operand) : Option Bool :=
  (a.execExact s).bind Val.toBool?

def execFloat (fmt : FloatFormat) (s : Store) (a : Operand) : Option (Model fmt) :=
  (a.execExact s).bind (·.toModel? fmt)

variable {s : Store} {env : Env}

theorem exec_sound (h : s.Sim env) {a : Operand} {x : AbsVal} (ha : a.exec s = some x) :
    ∃ v, a.eval env = some v ∧ x.Admits v := by
  cases a with
  | reg r => exact h r x ha
  | const width bits =>
    cases ha
    exact ⟨_, rfl, rfl⟩

theorem exec_tight (h : s.Tight env) {a : Operand} {x : AbsVal} (ha : a.exec s = some x) :
    a.eval env = some x.toVal := by
  cases a with
  | reg r => exact h r x ha
  | const width bits =>
    cases ha
    rfl

theorem eval_of_execExact (h : s.Sim env) {a : Operand} {v : Val} (ha : a.execExact s = some v) :
    a.eval env = some v := by
  unfold execExact at ha
  split at ha
  · rename_i heq
    obtain ⟨v', hv', rfl⟩ := exec_sound h heq
    cases ha
    exact hv'
  · cases ha

theorem eval_of_execBool (h : s.Sim env) {a : Operand} {c : Bool} (ha : a.execBool s = some c) :
    a.eval env = some (.ofBool c) := by
  obtain ⟨v, hv, hc⟩ := Option.bind_eq_some_iff.1 ha
  rw [eval_of_execExact h hv, Val.eq_ofBool_of_toBool? hc]

theorem eval_of_execFloat (h : s.Sim env) {fmt : FloatFormat} {a : Operand} {x : Model fmt}
    (ha : a.execFloat fmt s = some x) : (a.eval env).bind (·.toModel? fmt) = some x := by
  obtain ⟨v, hv, hx⟩ := Option.bind_eq_some_iff.1 ha
  rw [eval_of_execExact h hv]
  exact hx

end Operand

def CoreOp.exec (mode : IEEERoundingMode) : CoreOp → Option AbsVal
  | quickGetRound => (roundingConstant mode).map fun c => .exact (.ofNat 32 c)
  | isRoundUp => some (.exact (.ofBool (mode = .up)))
  | isRoundDown => some (.exact (.ofBool (mode = .down)))
  | isRoundToNearest => some (.exact (.ofBool (mode = .nearest)))
  | isRoundToZero => some (.exact (.ofBool (mode = .towardZero)))
  | setErrno => some (.any 0)
  | raiseExcept => some (.any 32)

def Instr.exec (mode : IEEERoundingMode) (f : Func) (s : Store) : Instr → Option AbsVal
  | intBin op a b => do
    let x ← a.execExact s
    let y ← b.execExact s
    if h : y.width = x.width then some (.exact ⟨x.width, op.eval x.bits (y.bits.cast h)⟩) else none
  | icmp pred a b => do
    let x ← a.execExact s
    let y ← b.execExact s
    if h : y.width = x.width then some (.exact (.ofBool (pred.eval x.bits (y.bits.cast h))))
    else none
  | zext width a => do
    let v ← a.execExact s
    some (.exact ⟨width, v.bits.setWidth width⟩)
  | sext width a => do
    let v ← a.execExact s
    some (.exact ⟨width, v.bits.signExtend width⟩)
  | trunc width a => do
    let v ← a.execExact s
    some (.exact ⟨width, v.bits.setWidth width⟩)
  | select cond a b => do
    let c ← cond.execBool s
    if c then a.exec s else b.exec s
  | fBin fmt op a b => do
    let x ← a.execFloat fmt s
    let y ← b.execFloat fmt s
    some (.ofFloat (op.eval mode x y))
  | fneg fmt a => do
    let x ← a.execFloat fmt s
    some (.exact (.ofModel x.neg))
  | fabs fmt a => do
    let x ← a.execFloat fmt s
    some (.exact (.ofModel x.abs))
  | fmuladd fmt a b c => do
    let x ← a.execFloat fmt s
    let y ← b.execFloat fmt s
    let z ← c.execFloat fmt s
    some (.ofFloat (Model.add (Model.mul x y mode) z mode))
  | fcmp fmt pred a b => do
    let x ← a.execFloat fmt s
    let y ← b.execFloat fmt s
    some (.exact (.ofBool (pred.eval (Model.compare x y))))
  | fpConvert src dst a => do
    let x ← a.execFloat src s
    some (.ofFloat (Model.cast src dst x mode))
  | fptosi src width a => do
    let x ← a.execFloat src s
    match ExecDType.convertToInteger (width := width) x .towardZero with
    | .success n _ => some (.exact ⟨width, n.bits⟩)
    | .failure _ => none
  | bitcast a => a.exec s
  | load table index => do
    let t ← f.tables[table]?
    let i ← index.execExact s
    let e ← t.elems[i.bits.toNat]?
    some (.exact (.ofNat t.width e))
  | call op _ => op.exec mode

theorem CoreOp.exec_sound {mode : IEEERoundingMode} {op : CoreOp} {x : AbsVal}
    (hx : op.exec mode = some x) : op.Eval mode x.toVal ∧ ∀ r, op.Eval mode r → x.Admits r := by
  cases op with
  | quickGetRound =>
    obtain ⟨c, hc, rfl⟩ := Option.map_eq_some_iff.1 hx
    refine ⟨⟨c, hc, rfl⟩, ?_⟩
    rintro r ⟨c', hc', rfl⟩
    rw [hc] at hc'
    cases hc'
    rfl
  | isRoundUp | isRoundDown | isRoundToNearest | isRoundToZero =>
    cases hx
    exact ⟨rfl, fun r hr => hr⟩
  | setErrno | raiseExcept =>
    cases hx
    exact ⟨rfl, fun r hr => hr⟩

/-- The interpreter's result for an instruction describes every result of the instruction, and
the value `AbsVal.toVal` selects is one when the operands are the selected values. -/
theorem Instr.exec_sound {mode : IEEERoundingMode} {f : Func} {s : Store} {env : Env}
    (h : s.Sim env) {i : Instr} {x : AbsVal} (hx : i.exec mode f s = some x) :
    (s.Tight env → i.Eval mode f env x.toVal) ∧ ∀ r, i.Eval mode f env r → x.Admits r := by
  cases i with
  | intBin op a b =>
    simp only [Instr.exec, Option.bind_eq_bind, Option.bind_eq_some_iff] at hx
    obtain ⟨⟨w, u⟩, hu, ⟨w', v⟩, hv, hx⟩ := hx
    split at hx <;> cases hx
    rename_i hw
    change w' = w at hw
    subst hw
    have ha := Operand.eval_of_execExact h hu
    have hb := Operand.eval_of_execExact h hv
    refine ⟨fun _ => ⟨_, u, v, ha, hb, rfl⟩, ?_⟩
    rintro r ⟨w₂, u₂, v₂, ha₂, hb₂, rfl⟩
    rw [ha] at ha₂
    cases ha₂
    rw [hb] at hb₂
    cases hb₂
    rfl
  | icmp pred a b =>
    simp only [Instr.exec, Option.bind_eq_bind, Option.bind_eq_some_iff] at hx
    obtain ⟨⟨w, u⟩, hu, ⟨w', v⟩, hv, hx⟩ := hx
    split at hx <;> cases hx
    rename_i hw
    change w' = w at hw
    subst hw
    have ha := Operand.eval_of_execExact h hu
    have hb := Operand.eval_of_execExact h hv
    refine ⟨fun _ => ⟨_, u, v, ha, hb, rfl⟩, ?_⟩
    rintro r ⟨w₂, u₂, v₂, ha₂, hb₂, rfl⟩
    rw [ha] at ha₂
    cases ha₂
    rw [hb] at hb₂
    cases hb₂
    rfl
  | zext width a | sext width a | trunc width a =>
    simp only [Instr.exec, Option.bind_eq_bind, Option.bind_eq_some_iff] at hx
    obtain ⟨v, hv, hx⟩ := hx
    cases hx
    have ha := Operand.eval_of_execExact h hv
    refine ⟨fun _ => ⟨v, ha, rfl⟩, ?_⟩
    rintro r ⟨v₂, ha₂, rfl⟩
    rw [ha] at ha₂
    cases ha₂
    rfl
  | select cond a b =>
    simp only [Instr.exec, Option.bind_eq_bind, Option.bind_eq_some_iff] at hx
    obtain ⟨c, hc, hx⟩ := hx
    have hcond := Operand.eval_of_execBool h hc
    have hx' : (if c then a else b).exec s = some x := by cases c <;> exact hx
    obtain ⟨v, hv, hadm⟩ := Operand.exec_sound h hx'
    have hsel (c' : Bool) : (if c' = true then a.eval env else b.eval env) =
        (if c' then a else b).eval env := by cases c' <;> rfl
    refine ⟨fun ht => ⟨c, hcond, (hsel c).trans (Operand.exec_tight ht hx')⟩, ?_⟩
    rintro r ⟨c', hc', hr⟩
    rw [hcond] at hc'
    cases Val.ofBool_injective (Option.some.inj hc')
    rw [hsel, hv] at hr
    cases hr
    exact hadm
  | fBin fmt op a b =>
    simp only [Instr.exec, Option.bind_eq_bind, Option.bind_eq_some_iff] at hx
    obtain ⟨u, hu, v, hv, hx⟩ := hx
    cases hx
    have ha := Operand.eval_of_execFloat h hu
    have hb := Operand.eval_of_execFloat h hv
    refine ⟨fun _ => ⟨u, v, ha, hb, (AbsVal.ofFloat_admits_iff _ _).1 (AbsVal.admits_toVal _)⟩, ?_⟩
    rintro r ⟨u₂, v₂, ha₂, hb₂, hr⟩
    rw [ha] at ha₂
    cases ha₂
    rw [hb] at hb₂
    cases hb₂
    exact (AbsVal.ofFloat_admits_iff _ _).2 hr
  | fneg fmt a | fabs fmt a =>
    simp only [Instr.exec, Option.bind_eq_bind, Option.bind_eq_some_iff] at hx
    obtain ⟨u, hu, hx⟩ := hx
    cases hx
    have ha := Operand.eval_of_execFloat h hu
    refine ⟨fun _ => ⟨u, ha, rfl⟩, ?_⟩
    rintro r ⟨u₂, ha₂, rfl⟩
    rw [ha] at ha₂
    cases ha₂
    rfl
  | fmuladd fmt a b c =>
    simp only [Instr.exec, Option.bind_eq_bind, Option.bind_eq_some_iff] at hx
    obtain ⟨u, hu, v, hv, w, hw, hx⟩ := hx
    cases hx
    have ha := Operand.eval_of_execFloat h hu
    have hb := Operand.eval_of_execFloat h hv
    have hc := Operand.eval_of_execFloat h hw
    refine ⟨fun _ => ⟨u, v, w, ha, hb, hc,
      (AbsVal.ofFloat_admits_iff _ _).1 (AbsVal.admits_toVal _)⟩, ?_⟩
    rintro r ⟨u₂, v₂, w₂, ha₂, hb₂, hc₂, hr⟩
    rw [ha] at ha₂
    cases ha₂
    rw [hb] at hb₂
    cases hb₂
    rw [hc] at hc₂
    cases hc₂
    exact (AbsVal.ofFloat_admits_iff _ _).2 hr
  | fcmp fmt pred a b =>
    simp only [Instr.exec, Option.bind_eq_bind, Option.bind_eq_some_iff] at hx
    obtain ⟨u, hu, v, hv, hx⟩ := hx
    cases hx
    have ha := Operand.eval_of_execFloat h hu
    have hb := Operand.eval_of_execFloat h hv
    refine ⟨fun _ => ⟨u, v, ha, hb, rfl⟩, ?_⟩
    rintro r ⟨u₂, v₂, ha₂, hb₂, rfl⟩
    rw [ha] at ha₂
    cases ha₂
    rw [hb] at hb₂
    cases hb₂
    rfl
  | fpConvert src dst a =>
    simp only [Instr.exec, Option.bind_eq_bind, Option.bind_eq_some_iff] at hx
    obtain ⟨u, hu, hx⟩ := hx
    cases hx
    have ha := Operand.eval_of_execFloat h hu
    refine ⟨fun _ => ⟨u, ha, (AbsVal.ofFloat_admits_iff _ _).1 (AbsVal.admits_toVal _)⟩, ?_⟩
    rintro r ⟨u₂, ha₂, hr⟩
    rw [ha] at ha₂
    cases ha₂
    exact (AbsVal.ofFloat_admits_iff _ _).2 hr
  | fptosi src width a =>
    simp only [Instr.exec, Option.bind_eq_bind, Option.bind_eq_some_iff] at hx
    obtain ⟨u, hu, hx⟩ := hx
    have ha := Operand.eval_of_execFloat h hu
    split at hx <;> cases hx
    rename_i n status hn
    refine ⟨fun _ => ⟨u, n, status, ha, hn, rfl⟩, ?_⟩
    rintro r ⟨u₂, n₂, status₂, ha₂, hn₂, rfl⟩
    rw [ha] at ha₂
    cases ha₂
    rw [hn] at hn₂
    cases hn₂
    rfl
  | bitcast a =>
    obtain ⟨v, hv, hadm⟩ := Operand.exec_sound h hx
    refine ⟨fun ht => Operand.exec_tight ht hx, fun r hr => ?_⟩
    rw [show a.eval env = some r from hr] at hv
    cases hv
    exact hadm
  | load table index =>
    simp only [Instr.exec, Option.bind_eq_bind, Option.bind_eq_some_iff] at hx
    obtain ⟨t, ht, i, hi, e, he, hx⟩ := hx
    cases hx
    have hindex := Operand.eval_of_execExact h hi
    refine ⟨fun _ => ⟨t, i, e, ht, hindex, he, rfl⟩, ?_⟩
    rintro r ⟨t₂, i₂, e₂, ht₂, hindex₂, he₂, rfl⟩
    rw [ht] at ht₂
    cases ht₂
    rw [hindex] at hindex₂
    cases hindex₂
    rw [he] at he₂
    cases he₂
    rfl
  | call op args => exact ⟨fun _ => (CoreOp.exec_sound hx).1, (CoreOp.exec_sound hx).2⟩

/-- Execute the instructions of a block in order. -/
def execBody (mode : IEEERoundingMode) (f : Func) : Store → List (Reg × Instr) → Option Store
  | s, [] => some s
  | s, (r, i) :: rest => do
    let a ← i.exec mode f s
    execBody mode f (s.set r a) rest

/-- Assign the phi nodes of a block entered from block `pred` with registers `old`. -/
def enterPhis (pred : ℕ) (old : Store) : Store → List (Reg × List (ℕ × Operand)) → Option Store
  | s, [] => some s
  | s, (r, incoming) :: rest => do
    let a ← incoming.lookup pred
    let v ← a.exec old
    enterPhis pred old (s.set r v) rest

/-- Execute at most `fuel` blocks, starting at block `cur` entered from block `pred`. -/
def Func.execFrom (mode : IEEERoundingMode) (f : Func) : (fuel pred cur : ℕ) → Store → Option AbsVal
  | 0, _, _, _ => none
  | fuel + 1, pred, cur, s => do
    let b ← f.blocks[cur]?
    let s₁ ← enterPhis pred s s b.phis
    let s₂ ← execBody mode f s₁ b.body
    match b.term with
    | .ret a => a.exec s₂
    | .br target => f.execFrom mode fuel cur target s₂
    | .condBr cond ifTrue ifFalse => do
      let c ← cond.execBool s₂
      f.execFrom mode fuel cur (if c then ifTrue else ifFalse) s₂

/-- Execute `f` on `args`. Each block is entered at most once, which is enough for the loop-free
code this development is about; `none` means that the interpreter gave up, not that `f` has no
result. -/
def Func.exec (mode : IEEERoundingMode) (f : Func) (args : List Val) : Option AbsVal :=
  f.execFrom mode f.blocks.size 0 0 (.ofArgs args)

theorem execBody_sound {mode : IEEERoundingMode} {f : Func} {body : List (Reg × Instr)}
    {s s' : Store} {env : Env} (h : s.Sim env) (hs' : execBody mode f s body = some s') :
    (s.Tight env → ∃ env', ExecBody mode f env body env' ∧ s'.Tight env') ∧
      ∀ env', ExecBody mode f env body env' → s'.Sim env' := by
  induction body generalizing s env with
  | nil =>
    cases hs'
    refine ⟨fun ht => ⟨env, .nil env, ht⟩, ?_⟩
    rintro env' ⟨⟩
    exact h
  | cons head rest ih =>
    obtain ⟨r, i⟩ := head
    simp only [execBody, Option.bind_eq_bind, Option.bind_eq_some_iff] at hs'
    obtain ⟨a, ha, hs'⟩ := hs'
    obtain ⟨hstep, hadm⟩ := Instr.exec_sound (env := env) h ha
    constructor
    · intro ht
      obtain ⟨env', henv', ht'⟩ := (ih (ht.set r a).sim hs').1 (ht.set r a)
      exact ⟨env', .cons (hstep ht) henv', ht'⟩
    · intro env' henv'
      cases henv' with
      | cons hv henv' => exact (ih (h.set r (hadm _ hv)) hs').2 _ henv'

theorem enterPhis_sound {pred : ℕ} {phis : List (Reg × List (ℕ × Operand))} {old s s' : Store}
    {oldEnv env : Env} (hold : old.Sim oldEnv) (h : s.Sim env)
    (hs' : enterPhis pred old s phis = some s') :
    (old.Tight oldEnv → s.Tight env → ∃ env', EnterPhis pred oldEnv env phis env' ∧ s'.Tight env') ∧
      ∀ env', EnterPhis pred oldEnv env phis env' → s'.Sim env' := by
  induction phis generalizing s env with
  | nil =>
    cases hs'
    refine ⟨fun _ ht => ⟨env, .nil env, ht⟩, ?_⟩
    rintro env' ⟨⟩
    exact h
  | cons head rest ih =>
    obtain ⟨r, incoming⟩ := head
    simp only [enterPhis, Option.bind_eq_bind, Option.bind_eq_some_iff] at hs'
    obtain ⟨a, ha, x, hx, hs'⟩ := hs'
    obtain ⟨v, hv, hadm⟩ := Operand.exec_sound hold hx
    constructor
    · intro htold ht
      obtain ⟨env', henv', ht'⟩ := (ih (ht.set r x).sim hs').1 htold (ht.set r x)
      exact ⟨env', .cons ha (Operand.exec_tight htold hx) henv', ht'⟩
    · intro env' henv'
      cases henv' with
      | cons ha' hv' henv' =>
        rw [ha] at ha'
        cases ha'
        rw [hv] at hv'
        cases hv'
        exact (ih (h.set r hadm) hs').2 _ henv'

theorem Func.execFrom_sound {mode : IEEERoundingMode} {f : Func} {fuel pred cur : ℕ} {s : Store}
    {env : Env} {a : AbsVal} (h : s.Sim env) (ha : f.execFrom mode fuel pred cur s = some a) :
    (s.Tight env → Run mode f pred cur env a.toVal) ∧
      ∀ r, Run mode f pred cur env r → a.Admits r := by
  induction fuel generalizing pred cur s env with
  | zero => cases ha
  | succ fuel ih =>
    simp only [execFrom, Option.bind_eq_bind, Option.bind_eq_some_iff] at ha
    obtain ⟨b, hb, s₁, hs₁, s₂, hs₂, ha⟩ := ha
    -- Any execution of the block ends with registers described by `s₂`.
    have hsim {env₁ env₂ : Env} (h₁ : EnterPhis pred env env b.phis env₁)
        (h₂ : ExecBody mode f env₁ b.body env₂) : s₂.Sim env₂ :=
      (execBody_sound ((enterPhis_sound h h hs₁).2 _ h₁) hs₂).2 _ h₂
    -- One execution ends with the values `AbsVal.toVal` selects.
    have htight (ht : s.Tight env) : ∃ env₁ env₂, EnterPhis pred env env b.phis env₁ ∧
        ExecBody mode f env₁ b.body env₂ ∧ s₂.Tight env₂ := by
      obtain ⟨env₁, h₁, ht₁⟩ := (enterPhis_sound h h hs₁).1 ht ht
      obtain ⟨env₂, h₂, ht₂⟩ := (execBody_sound ht₁.sim hs₂).1 ht₁
      exact ⟨env₁, env₂, h₁, h₂, ht₂⟩
    split at ha
    · rename_i operand hterm
      constructor
      · intro ht
        obtain ⟨env₁, env₂, h₁, h₂, ht₂⟩ := htight ht
        exact .ret hb h₁ h₂ hterm (Operand.exec_tight ht₂ ha)
      · intro r hr
        cases hr with
        | ret hb' h₁ h₂ hterm' hv' =>
          rw [hb] at hb'
          cases hb'
          rw [hterm] at hterm'
          cases hterm'
          obtain ⟨v', hv'', hadm'⟩ := Operand.exec_sound (hsim h₁ h₂) ha
          rw [hv'] at hv''
          cases hv''
          exact hadm'
        | br hb' _ _ hterm' | condBr hb' _ _ hterm' =>
          rw [hb] at hb'
          cases hb'
          rw [hterm] at hterm'
          cases hterm'
    · rename_i target hterm
      constructor
      · intro ht
        obtain ⟨env₁, env₂, h₁, h₂, ht₂⟩ := htight ht
        exact .br hb h₁ h₂ hterm ((ih ht₂.sim ha).1 ht₂)
      · intro r hr
        cases hr with
        | br hb' h₁ h₂ hterm' hrun =>
          rw [hb] at hb'
          cases hb'
          rw [hterm] at hterm'
          cases hterm'
          exact (ih (hsim h₁ h₂) ha).2 _ hrun
        | ret hb' _ _ hterm' | condBr hb' _ _ hterm' =>
          rw [hb] at hb'
          cases hb'
          rw [hterm] at hterm'
          cases hterm'
    · rename_i cond ifTrue ifFalse hterm
      simp only [Option.bind_eq_some_iff] at ha
      obtain ⟨c, hc, ha⟩ := ha
      constructor
      · intro ht
        obtain ⟨env₁, env₂, h₁, h₂, ht₂⟩ := htight ht
        exact .condBr hb h₁ h₂ hterm (Operand.eval_of_execBool ht₂.sim hc) ((ih ht₂.sim ha).1 ht₂)
      · intro r hr
        cases hr with
        | condBr hb' h₁ h₂ hterm' hcond' hrun =>
          rw [hb] at hb'
          cases hb'
          rw [hterm] at hterm'
          cases hterm'
          rw [Operand.eval_of_execBool (hsim h₁ h₂) hc] at hcond'
          cases Val.ofBool_injective (Option.some.inj hcond')
          exact (ih (hsim h₁ h₂) ha).2 _ hrun
        | ret hb' _ _ hterm' | br hb' _ _ hterm' =>
          rw [hb] at hb'
          cases hb'
          rw [hterm] at hterm'
          cases hterm'

/-- When the interpreter answers `a`, the function can return `a.toVal`, and `a` describes every
result it can return. -/
theorem Func.exec_sound {mode : IEEERoundingMode} {f : Func} {args : List Val} {a : AbsVal}
    (ha : f.exec mode args = some a) :
    f.Returns mode args a.toVal ∧ ∀ r, f.Returns mode args r → a.Admits r :=
  have h := f.execFrom_sound (Store.sim_ofArgs args) ha
  ⟨h.1 (Store.tight_ofArgs args), h.2⟩

/-- The result of `f` on `args`, if the interpreter determines it up to the choice of a NaN, in
which case this is the NaN FloatLib computes. -/
def Func.run (mode : IEEERoundingMode) (f : Func) (args : List Val) : Option Val :=
  match f.exec mode args with
  | some (.exact v) => some v
  | some (.nan _ x _) => some (.ofModel x)
  | _ => none

/-- When `f.run` answers `v`, the function can return `v`, and every result it can return is `v`
or, like `v`, a NaN of some format. -/
theorem Func.run_sound {mode : IEEERoundingMode} {f : Func} {args : List Val} {v : Val}
    (hv : f.run mode args = some v) :
    f.Returns mode args v ∧ ∀ r, f.Returns mode args r →
      r = v ∨ ∃ (fmt : FloatFormat) (x y : Model fmt),
        r = .ofModel x ∧ v = .ofModel y ∧ x.isNaN = true ∧ y.isNaN = true := by
  unfold run at hv
  split at hv
  · rename_i ha
    cases hv
    exact ⟨(exec_sound ha).1, fun r hr => .inl ((exec_sound ha).2 r hr)⟩
  · rename_i fmt y hy ha
    cases hv
    refine ⟨(exec_sound ha).1, fun r hr => ?_⟩
    obtain ⟨x, rfl, hx⟩ := (exec_sound ha).2 r hr
    exact .inr ⟨fmt, x, y, rfl, rfl, hx, hy⟩
  · cases hv

/-- The result of `f` on `args` as a bit pattern of format `fmt`. -/
def Func.runFloat (fmt : FloatFormat) (mode : IEEERoundingMode) (f : Func) (args : List Val) :
    Option (Model fmt) :=
  match f.exec mode args with
  | some (.exact v) => v.toModel? fmt
  | some (.nan fmt' x _) => if h : fmt' = fmt then some (h ▸ x) else none
  | _ => none

/-- The result of the unary floating-point function `f` at `x`. -/
def Func.runUnary {fmt : FloatFormat} (f : Func) (mode : IEEERoundingMode) (x : Model fmt) :
    Option (Model fmt) :=
  f.runFloat fmt mode [.ofModel x]

theorem Func.runFloat_sound {fmt : FloatFormat} {mode : IEEERoundingMode} {f : Func}
    {args : List Val} {y : Model fmt} (hy : f.runFloat fmt mode args = some y) :
    (∃ r, f.Returns mode args r) ∧ ∀ r, f.Returns mode args r → r.Encodes y := by
  unfold runFloat at hy
  split at hy
  · rename_i v ha
    refine ⟨⟨_, (exec_sound ha).1⟩, fun r hr => ?_⟩
    cases (exec_sound ha).2 r hr
    exact ⟨y, hy, .inl rfl⟩
  · rename_i fmt' x hx ha
    split at hy <;> cases hy
    rename_i hfmt
    subst hfmt
    refine ⟨⟨_, (exec_sound ha).1⟩, fun r hr => ?_⟩
    obtain ⟨x', rfl, hx'⟩ := (exec_sound ha).2 r hr
    exact ⟨x', Val.toModel?_ofModel x', .inr ⟨hx', hx⟩⟩
  · cases hy

/-- When the interpreter answers `y` at `x`, the function has a result at `x`, and every result
it can have there has the value `y`. -/
theorem Func.runUnary_sound {fmt : FloatFormat} (f : Func) :
    ∀ mode (x y : Model fmt), f.runUnary mode x = some y →
      (∃ r, f.Returns mode [.ofModel x] r) ∧ ∀ r, f.Returns mode [.ofModel x] r → r.Encodes y :=
  fun _ _ _ hy => runFloat_sound hy

end LibcMath.IR
