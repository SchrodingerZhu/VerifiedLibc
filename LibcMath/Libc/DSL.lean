import LibcMath.Libc.Poly

/-!
# Domain-specific notation for extracted LLVM libc math kernels

Provides concise, human- and agent-readable notation that elaborates directly to `LibcMath.Libc`
functions with zero runtime overhead:

* Exact IEEE bit-pattern float literals:
  - `f16(0x3C00#16)`
  - `f32(0x3F800000#32)`
  - `f64(0x3FF0000000000000#64)`
* Fixed-point fractional literals:
  - `frac64(0xB8AA3B295C17F0BC#64)`
* Polynomial evaluation:
  - `horner[cfg, mode] x [c0, c1, c2, ...]`
  - `althorner[cfg, mode] x [c0, c1, c2, ...]`
  - `estrin[cfg, mode] x coeffs`
  - `estrin[cfg, mode, offset] x coeffs`
* Config-aware fused/unfused multiply-add primitives:
  - `madd[cfg, mode](x, y, z)`
  - `msub[cfg, mode](x, y, z)`
  - `submul[cfg, mode](x, y, z)`
-/

namespace LibcMath.Libc.DSL

open FloatLib.Floats.Formats.BinaryInterchange

/-- Exact `binary16` value from a 16-bit pattern. -/
scoped notation "f16(" b ")" => (Model.ofBits b : Model FloatFormat.binary16)

/-- Exact `binary32` value from a 32-bit pattern. -/
scoped notation "f32(" b ")" => (Model.ofBits b : Model FloatFormat.binary32)

/-- Exact `binary64` value from a 64-bit pattern. -/
scoped notation "f64(" b ")" => (Model.ofBits b : Model FloatFormat.binary64)

/-- Exact 64-bit unsigned fractional constant (`Frac64`). -/
scoped notation "frac64(" b ")" => (LibcMath.Libc.Frac64.ofBits b)

/-- Horner polynomial evaluation `a₀ + x * (a₁ + … + x * aₙ)` on an inline coefficient list. -/
scoped syntax "horner[" term "," term "] " term:arg " [" term,* "]" : term
scoped macro_rules
  | `(horner[$cfg, $mode] $x [$cs,*]) =>
      `(LibcMath.Libc.polyevalList $cfg $mode $x [$cs,*])

/-- Alternating Horner polynomial evaluation on an inline coefficient list. -/
scoped syntax "althorner[" term "," term "] " term:arg " [" term,* "]" : term
scoped macro_rules
  | `(althorner[$cfg, $mode] $x [$cs,*]) =>
      `(LibcMath.Libc.altpolyevalList $cfg $mode $x [$cs,*])

/-- Right-heavy Estrin polynomial evaluation on a coefficient array (optional slice offset). -/
scoped syntax "estrin[" term "," term "] " term:arg term:arg : term
scoped syntax "estrin[" term "," term "," term "] " term:arg term:arg : term
scoped macro_rules
  | `(estrin[$cfg, $mode] $x $coeffs) =>
      `(LibcMath.Libc.estrin $cfg $mode $x $coeffs 0)
  | `(estrin[$cfg, $mode, $off] $x $coeffs) =>
      `(LibcMath.Libc.estrin $cfg $mode $x $coeffs $off)

/-- Config-aware `multiply_add(x, y, z) = x * y + z`. -/
scoped syntax "madd[" term "," term "](" term "," term "," term ")" : term
scoped macro_rules
  | `(madd[$cfg, $mode]($x, $y, $z)) =>
      `(LibcMath.Libc.PolyElem.madd $cfg $mode $x $y $z)

/-- Config-aware `multiply_sub(x, y, z) = x * y - z`. -/
scoped syntax "msub[" term "," term "](" term "," term "," term ")" : term
scoped macro_rules
  | `(msub[$cfg, $mode]($x, $y, $z)) =>
      `(LibcMath.Libc.PolyElem.msub $cfg $mode $x $y $z)

/-- Config-aware `sub_multiply(x, y, z) = x - y * z`. -/
scoped syntax "submul[" term "," term "](" term "," term "," term ")" : term
scoped macro_rules
  | `(submul[$cfg, $mode]($x, $y, $z)) =>
      `(LibcMath.Libc.PolyElem.subMul $cfg $mode $x $y $z)

end LibcMath.Libc.DSL
