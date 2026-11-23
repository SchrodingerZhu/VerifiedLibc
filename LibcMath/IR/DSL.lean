import LibcMath.IR.Syntax

/-!
# Notation for extracted code

The `llvm_func` command defines a `Func` from text that follows LLVM's assembly language:

```
llvm_func f(float %0) {
  @T : double := [0x3FF0000000000000, 0x4000000000000000]
  ^bb0:
    %1 = bitcast %0 : float -> i32
    %2 = add nsw %1, 0x1 : i32
    %3 = icmp samesign ult %2, 0x10 : i32
    br %3, ^bb1, ^bb2
  …
}
```

Registers are numbered: parameters first, then instructions in program order. Blocks are labeled
`^bb0, ^bb1, …` in order. Every instruction states the type of its operands, so constants are
written as bare bit patterns, including floating-point ones. Types are `iN`, `half`, `float` and
`double`. The instructions are those of `Instr`, under their LLVM names; `call` names a `CoreOp`.
The flags of `Flags` and `FastMathFlags` follow the opcode, as in LLVM, on the instructions that
carry them there.
-/

namespace LibcMath.IR.DSL

open Lean

declare_syntax_cat llvm_operand
syntax "%" noWs num : llvm_operand
syntax num : llvm_operand

declare_syntax_cat llvm_label
syntax "^" noWs ident : llvm_label

/-- An operand preceded by its type. -/
declare_syntax_cat llvm_arg
syntax ident llvm_operand : llvm_arg

declare_syntax_cat llvm_incoming
syntax "[" llvm_label ": " llvm_operand "]" : llvm_incoming

declare_syntax_cat llvm_flag (behavior := both)
syntax &"nuw" : llvm_flag
syntax &"nsw" : llvm_flag
syntax &"exact" : llvm_flag
syntax &"disjoint" : llvm_flag
syntax &"samesign" : llvm_flag
syntax &"nneg" : llvm_flag
syntax &"nnan" : llvm_flag
syntax &"ninf" : llvm_flag

declare_syntax_cat llvm_instr
/-- `%3 = add nsw %1, %2 : i32`, and likewise every instruction whose operands share one type. -/
syntax "%" noWs num " = " ident llvm_flag* llvm_operand,+ " : " ident : llvm_instr
/-- `%3 = icmp samesign ult %1, %2 : i32` and `%3 = fcmp olt %1, %2 : float`. -/
syntax "%" noWs num " = " ident llvm_flag* ident llvm_operand ", " llvm_operand " : " ident :
  llvm_instr
/-- `%2 = zext nneg %1 : i32 -> i64` and `%2 = fpext %1 : float -> double`. -/
syntax "%" noWs num " = " ident llvm_flag* llvm_operand " : " ident " -> " ident : llvm_instr
/-- `%5 = phi [^bb1: %3], [^bb2: %4] : float`. -/
syntax "%" noWs num " = " &"phi" llvm_incoming,+ " : " ident : llvm_instr
/-- `%4 = load @T[i64 %3] : double`. -/
syntax "%" noWs num " = " &"load" "@" noWs ident "[" llvm_arg "]" " : " ident : llvm_instr
/-- `%2 = call quickGetRound()`. -/
syntax "%" noWs num " = " &"call" ident "(" llvm_arg,* ")" : llvm_instr

declare_syntax_cat llvm_term (behavior := both)
/-- `ret float %1`. -/
syntax &"ret" llvm_arg : llvm_term
/-- `br ^bb1`. -/
syntax &"br" llvm_label : llvm_term
/-- `br %1, ^bb1, ^bb2`. -/
syntax &"br" llvm_operand ", " llvm_label ", " llvm_label : llvm_term

declare_syntax_cat llvm_block
syntax llvm_label ":" llvm_instr* llvm_term : llvm_block

declare_syntax_cat llvm_table
syntax "@" noWs ident " : " ident " := " "[" num,* "]" : llvm_table

syntax "llvm_func " ident "(" llvm_arg,* ")" " {" llvm_table* llvm_block* "}" : command

/-- The width of a type. -/
def typeWidth (ty : Ident) : MacroM Nat :=
  match ty.getId.toString with
  | "half" => pure 16
  | "float" => pure 32
  | "double" => pure 64
  | s =>
    match (s.dropPrefix? "i").bind (·.toString.toNat?) with
    | some w => pure w
    | none => Macro.throwErrorAt ty s!"unknown type {s}"

/-- The format of a floating-point type. -/
def typeFormat (ty : Ident) : MacroM Term :=
  match ty.getId.toString with
  | "half" => `(.binary16)
  | "float" => `(.binary32)
  | "double" => `(.binary64)
  | s => Macro.throwErrorAt ty s!"{s} is not a floating-point type"

def expandOperand (ty : Ident) : TSyntax `llvm_operand → MacroM Term
  | `(llvm_operand| %$r:num) => `(Operand.reg $r)
  | `(llvm_operand| $bits:num) => do `(Operand.const $(quote (← typeWidth ty)) $bits)
  | stx => Macro.throwErrorAt stx "unsupported operand"

def expandArg : TSyntax `llvm_arg → MacroM Term
  | `(llvm_arg| $ty:ident $a:llvm_operand) => expandOperand ty a
  | stx => Macro.throwErrorAt stx "unsupported operand"

/-- The index of a block, from its label `^bbN`. -/
def expandLabel : TSyntax `llvm_label → MacroM Nat
  | `(llvm_label| ^$l:ident) =>
    match (l.getId.toString.dropPrefix? "bb").bind (·.toString.toNat?) with
    | some n => pure n
    | none => Macro.throwErrorAt l "block labels have the form ^bbN"
  | stx => Macro.throwErrorAt stx "unsupported label"

/-- A constructor of the enumeration `type` named by `name`. -/
def enumCtor (type : Name) (name : Ident) : Term :=
  ⟨mkIdentFrom name (type ++ name.getId)⟩

/-- The flags an instruction may carry. -/
def allowedFlags : String → List String
  | "add" | "sub" | "mul" | "shl" | "trunc" => ["nuw", "nsw"]
  | "lshr" | "ashr" => ["exact"]
  | "or" => ["disjoint"]
  | "icmp" => ["samesign"]
  | "zext" => ["nneg"]
  | "fadd" | "fsub" | "fmul" | "fneg" | "fabs" | "fmuladd" | "fcmp" | "fpext" | "fptrunc" =>
    ["nnan", "ninf"]
  | _ => []

/-- The `Flags` and the `FastMathFlags` written after the opcode `op`. -/
def expandFlags (op : Ident) (flags : Array (TSyntax `llvm_flag)) : MacroM (Term × Term) := do
  let names ← flags.mapM fun (flag : TSyntax `llvm_flag) => do
    let name := flag.raw[0].getAtomVal
    unless (allowedFlags op.getId.toString).contains name do
      Macro.throwErrorAt flag s!"{op.getId} does not take the flag {name}"
    pure name
  let has (name : String) : Term := quote (names.contains name)
  let flags ← `({ nuw := $(has "nuw"), nsw := $(has "nsw"), exact := $(has "exact"),
                  disjoint := $(has "disjoint"), samesign := $(has "samesign"),
                  nneg := $(has "nneg") : Flags })
  let fmf ← `({ nnan := $(has "nnan"), ninf := $(has "ninf") : FastMathFlags })
  return (flags, fmf)

/-- An instruction, as its register and either its phi node or its `Instr`. -/
def expandInstr (tables : Array Name) :
    TSyntax `llvm_instr → MacroM (TSyntax `num × (Term ⊕ Term))
  | `(llvm_instr| %$r:num = $op:ident $flags:llvm_flag* $[$args],* : $ty) => do
    let (flags, fmf) ← expandFlags op flags
    let instr ← match op.getId.toString, ← args.mapM (expandOperand ty) with
      | "fneg", #[a] => do `(Instr.fneg $(← typeFormat ty) $a $fmf)
      | "fabs", #[a] => do `(Instr.fabs $(← typeFormat ty) $a $fmf)
      | "fmuladd", #[a, b, c] => do `(Instr.fmuladd $(← typeFormat ty) $a $b $c $fmf)
      | "fadd", #[a, b] | "fsub", #[a, b] | "fmul", #[a, b] => do
        `(Instr.fBin $(← typeFormat ty) $(enumCtor ``FBinOp op) $a $b $fmf)
      | "select", #[_, a, b] => do `(Instr.select $(← expandOperand (mkIdent `i1) args[0]!) $a $b)
      | _, #[a, b] => `(Instr.intBin $(enumCtor ``IntBinOp op) $a $b $flags)
      | _, _ => Macro.throwErrorAt op "unsupported instruction"
    return (r, .inr instr)
  | `(llvm_instr| %$r:num = $op:ident $flags:llvm_flag* $pred:ident $a:llvm_operand,
      $b:llvm_operand : $ty) => do
    let (flags, fmf) ← expandFlags op flags
    let a ← expandOperand ty a
    let b ← expandOperand ty b
    let instr ← match op.getId.toString with
      | "icmp" => `(Instr.icmp $(enumCtor ``ICmp pred) $a $b $flags)
      | "fcmp" => do `(Instr.fcmp $(← typeFormat ty) $(enumCtor ``FCmp pred) $a $b $fmf)
      | _ => Macro.throwErrorAt op "unsupported instruction"
    return (r, .inr instr)
  | `(llvm_instr| %$r:num = $op:ident $flags:llvm_flag* $a:llvm_operand : $src -> $dst) => do
    let (flags, fmf) ← expandFlags op flags
    let a ← expandOperand src a
    let instr ← match op.getId.toString with
      | "zext" => do `(Instr.zext $(quote (← typeWidth dst)) $a $flags)
      | "sext" => do `(Instr.sext $(quote (← typeWidth dst)) $a)
      | "trunc" => do `(Instr.trunc $(quote (← typeWidth dst)) $a $flags)
      | "bitcast" => `(Instr.bitcast $a)
      | "fpext" | "fptrunc" => do `(Instr.fpConvert $(← typeFormat src) $(← typeFormat dst) $a $fmf)
      | "fptosi" => do `(Instr.fptosi $(← typeFormat src) $(quote (← typeWidth dst)) $a)
      | _ => Macro.throwErrorAt op "unsupported cast"
    return (r, .inr instr)
  | `(llvm_instr| %$r:num = phi $incoming:llvm_incoming,* : $ty) => do
    let incoming ← incoming.getElems.mapM fun
      | `(llvm_incoming| [$l:llvm_label : $v]) => do `(($(quote (← expandLabel l)), $(← expandOperand ty v)))
      | stx => Macro.throwErrorAt stx "unsupported phi operand"
    return (r, .inl (← `([$incoming,*])))
  | `(llvm_instr| %$r:num = load @$table:ident[$index:llvm_arg] : $_) => do
    let some i := tables.idxOf? table.getId
      | Macro.throwErrorAt table "unknown table"
    return (r, .inr (← `(Instr.load $(quote i) $(← expandArg index))))
  | `(llvm_instr| %$r:num = call $op:ident ( $args,* )) => do
    let args ← args.getElems.mapM expandArg
    return (r, .inr (← `(Instr.call $(enumCtor ``CoreOp op) [$args,*])))
  | stx => Macro.throwErrorAt stx "unsupported instruction"

def expandTerminator : TSyntax `llvm_term → MacroM Term
  | `(llvm_term| ret $a:llvm_arg) => do `(Terminator.ret $(← expandArg a))
  | `(llvm_term| br $l:llvm_label) => do `(Terminator.br $(quote (← expandLabel l)))
  | `(llvm_term| br $c:llvm_operand, $t:llvm_label, $e:llvm_label) => do
    `(Terminator.condBr $(← expandOperand (mkIdent `i1) c)
      $(quote (← expandLabel t)) $(quote (← expandLabel e)))
  | stx => Macro.throwErrorAt stx "unsupported terminator"

def expandBlock (tables : Array Name) (index : Nat) : TSyntax `llvm_block → MacroM Term
  | `(llvm_block| $l:llvm_label : $instrs:llvm_instr* $term:llvm_term) => do
    unless (← expandLabel l) = index do
      Macro.throwErrorAt l s!"expected block ^bb{index}"
    let mut phis := #[]
    let mut body := #[]
    for instr in instrs do
      match ← expandInstr tables instr with
      | (r, .inl incoming) => phis := phis.push (← `(($r, $incoming)))
      | (r, .inr instr) => body := body.push (← `(($r, $instr)))
    `({ phis := [$phis,*], body := [$body,*], term := $(← expandTerminator term) : Block })
  | stx => Macro.throwErrorAt stx "unsupported block"

macro_rules
  | `(llvm_func $name:ident ( $params,* ) { $tables:llvm_table* $blocks:llvm_block* }) => do
    let widths : Array Term ← params.getElems.mapM fun
      | `(llvm_arg| $ty:ident $_) => return quote (← typeWidth ty)
      | stx => Macro.throwErrorAt stx "unsupported parameter"
    let mut tableNames := #[]
    let mut tableTerms := #[]
    for table in tables do
      match table with
      | `(llvm_table| @$t:ident : $ty := [$elems,*]) =>
        tableNames := tableNames.push t.getId
        tableTerms := tableTerms.push
          (← `({ width := $(quote (← typeWidth ty)), elems := #[$elems,*] : Table }))
      | stx => Macro.throwErrorAt stx "unsupported table"
    let mut blockTerms := #[]
    for block in blocks do
      blockTerms := blockTerms.push (← expandBlock tableNames blockTerms.size block)
    `(def $name : Func where
        params := [$widths,*]
        tables := #[$tableTerms,*]
        blocks := #[$blockTerms,*])

end LibcMath.IR.DSL
