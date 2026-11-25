module;

#include <algorithm>
#include <cstdint>
#include <format>
#include <optional>
#include <ranges>
#include <span>
#include <string>
#include <string_view>
#include <unordered_set>
#include <utility>
#include <variant>
#include <vector>

export module libc_extract.emit_lean;

import libc_extract.core_ops;
import libc_extract.ir;

export namespace libc_extract {

struct EmitOptions {
  std::string lean_namespace = "LibcMath";
  std::string core_import = "LibcMath.Libc";
  bool emit_float_comments = false; // Append /- 0.5 -/ next to hex float literals.
  bool emit_kernel_bundle = true;   // Emit `config`, `kernelMeta`, and `kernel : Libc.UnaryKernel`.
};

/// Emit clean, statically-typed Lean 4 code referencing `LibcMath.Libc` and `LibcMath.Libc.DSL`.
auto emitLean(const ir::Module &mod, const EmitOptions &opts) -> std::string;

/// Emit a compact human-readable dump of the lifted High-Level Math IR (`--emit-ir`).
auto emitHighLevelIR(const ir::Module &mod) -> std::string;

/// Format a MathConfig summary for `--dump-config`.
auto formatMathConfig(const ir::MathConfig &cfg) -> std::string;

} // namespace libc_extract

module : private;

namespace libc_extract {
namespace {

using namespace ir;

auto joinWith(const std::vector<std::string> &items, std::string_view sep) -> std::string {
  std::string out;
  for (auto [idx, item] : std::views::enumerate(items)) {
    if (idx > 0)
      out.append(sep);
    out.append(item);
  }
  return out;
}

/// Lines of generated Lean are kept within this many columns where a break is possible.
constexpr std::size_t kMaxColumns = 100;

auto indentStr(int level) -> std::string {
  return std::string(static_cast<std::size_t>(level) * 2, ' ');
}

auto leanIdent(std::string_view name) -> std::string {
  constexpr std::string_view kKeywords[] = {
      "in",      "do",        "let",      "if",      "then",      "else",      "match",
      "with",    "where",     "def",      "fun",     "by",        "have",      "from",
      "import",  "end",       "open",     "type",    "meta",      "of",        "to",
      "at",      "for",       "return",   "break",   "continue",  "mut",       "try",
      "catch",   "finally",   "unless",   "class",   "structure", "inductive", "theorem",
      "axiom",   "example",   "namespace", "section", "variable",  "universe",  "deriving",
      "extends", "private",   "protected", "partial", "noncomputable", "show",  "suffices",
      "nomatch", "calc",
  };
  if (std::ranges::contains(kKeywords, name)) {
    return std::format("{}'", name);
  }
  return std::string(name);
}

auto leanBool(bool v) -> std::string_view { return v ? "true" : "false"; }

auto emitType(const TypePtr &ty) -> std::string;

auto emitTypeArg(const TypePtr &ty) -> std::string {
  auto s = emitType(ty);
  if (s.find(' ') != std::string::npos)
    return std::format("({})", s);
  return s;
}

auto emitType(const TypePtr &ty) -> std::string {
  if (!ty)
    return "_";
  return std::visit(
      Overloaded{
          [](const VoidType &) { return std::string("Unit"); },
          [](const BoolType &) { return std::string("Bool"); },
          [](const IntType &i) { return std::format("BitVec {}", i.width); },
          [](const FloatType &f) { return std::format("Model {}", floatFmtLean(f.fmt)); },
          [](const FPBitsType &f) { return std::format("Libc.FPBits {}", floatFmtLean(f.fmt)); },
          [](const NormalFloatType &n) {
            return std::format("Libc.NormalFloat {}", floatFmtLean(n.fmt));
          },
          [](const DyadicFloatType &d) { return std::format("Libc.DyadicFloat {}", d.bits); },
          [](const NumberPairType &np) {
            if (np.fmt == FloatFmt::Binary32)
              return std::string("Libc.FloatFloat");
            if (np.fmt == FloatFmt::Binary64)
              return std::string("Libc.DoubleDouble");
            return std::format("Libc.NumberPair (Model {})", floatFmtLean(np.fmt));
          },
          [](const TripleDoubleType &) { return std::string("Libc.TripleDouble"); },
          [](const Frac64Type &) { return std::string("Libc.Frac64"); },
          [](const ExceptValuesType &e) {
            return std::format("Libc.ExceptValues {}", floatFmtLean(e.fmt));
          },
          [](const SignType &) { return std::string("Libc.Sign"); },
          [](const OptionalType &o) { return std::format("Option {}", emitTypeArg(o.elem)); },
          [](const ArrayType &a) { return std::format("Array {}", emitTypeArg(a.elem)); },
          [](const StructType &s) { return s.name; },
          [](const PtrType &p) { return emitType(p.pointee); },
          [](const TupleType &t) {
            std::vector<std::string> parts;
            parts.reserve(t.elems.size());
            for (const auto &el : t.elems)
              parts.push_back(emitTypeArg(el));
            return joinWith(parts, " × ");
          },
          [](const OpaqueType &o) { return std::format("Libc.Opaque /- {} -/", o.cpp_name); },
      },
      ty->v);
}

auto emitConst(const ConstVal &cv, bool float_comments, int ind = 0) -> std::string {
  return std::visit(
      Overloaded{
          [](const BoolConst &b) { return std::string(b.value ? "true" : "false"); },
          [](const SignConst &s) {
            return std::string(s.is_neg ? "Libc.Sign.neg" : "Libc.Sign.pos");
          },
          [](const IntConst &i) { return std::format("0x{}#{}", i.hex_bits, i.width); },
          [float_comments](const FloatConst &f) {
            auto bits = floatFmtBits(f.fmt);
            auto hex_w = bits / 4;
            auto core =
                std::format("{}(0x{:0{}X}#{})", floatFmtShort(f.fmt), f.raw_bits, hex_w, bits);
            if (float_comments && !f.repr.empty()) {
              return std::format("{} /- {} -/", core, f.repr);
            }
            return core;
          },
          [](const Frac64Const &fc) { return std::format("frac64(0x{}#64)", fc.hex_bits); },
          [](const DyadicConst &d) {
            return std::format("{{ sign := {}, exponent := {}, mantissa := 0x{}#{} }}",
                               d.sign_neg ? "Libc.Sign.neg" : "Libc.Sign.pos", d.exponent,
                               d.mantissa_hex, d.bits);
          },
          [](const NumberPairConst &np) {
            auto bits = floatFmtBits(np.fmt);
            auto hex_w = bits / 4;
            auto tag = floatFmtShort(np.fmt);
            auto ty = (np.fmt == FloatFmt::Binary32) ? "Libc.FloatFloat" : "Libc.DoubleDouble";
            return std::format("({{ lo := {}(0x{:0{}X}#{}), hi := {}(0x{:0{}X}#{}) }} : {})", tag,
                               np.lo_bits, hex_w, bits, tag, np.hi_bits, hex_w, bits, ty);
          },
          [float_comments, ind](const ArrayConst &arr) {
            if (arr.elems.empty())
              return std::string("#[]");
            bool nested = std::ranges::any_of(arr.elems, [](const ConstVal &el) {
              return std::holds_alternative<ArrayConst>(el.v) ||
                     std::holds_alternative<StructConst>(el.v) ||
                     std::holds_alternative<DyadicConst>(el.v) ||
                     std::holds_alternative<NumberPairConst>(el.v);
            });
            // Pack as many elements on a line as fit in `kMaxColumns`; an element that spans
            // several lines, or a nested constant, gets a line of its own.
            std::string out = "#[\n";
            auto pad = indentStr(ind + 1);
            std::string line;
            auto flush = [&](bool more) {
              if (line.empty())
                return;
              out += pad + line + (more ? "," : "") + "\n";
              line.clear();
            };
            for (std::size_t j = 0; j < arr.elems.size(); ++j) {
              std::string el = emitConst(arr.elems[j], float_comments, ind + 1);
              bool alone = nested || el.contains('\n');
              bool last = j + 1 == arr.elems.size();
              if (alone) {
                flush(true);
                line = el;
                flush(!last);
                continue;
              }
              // The line also holds the indentation and a trailing comma.
              if (!line.empty() && pad.size() + line.size() + 2 + el.size() + 1 > kMaxColumns)
                flush(true);
              line += (line.empty() ? "" : ", ") + el;
              if (last)
                flush(false);
            }
            out += indentStr(ind) + "]";
            return out;
          },
          [float_comments, ind](const StructConst &sc) {
            std::vector<std::string> parts;
            parts.reserve(sc.fields.size());
            for (const auto &[fname, fval] : sc.fields) {
              parts.push_back(std::format("{} := {}", leanIdent(fname),
                                          emitConst(fval, float_comments, ind + 1)));
            }
            return std::format("{{ {} }}", joinWith(parts, ", "));
          },
      },
      cv.v);
}

auto isAtomicExpr(const ExprPtr &e) -> bool {
  if (!e)
    return true;
  if (const auto *c = std::get_if<CastExpr>(&e->v)) {
    if (c->kind == CastKind::NoOp)
      return isAtomicExpr(c->operand);
    if (c->kind == CastKind::IntToInt && e->type && c->operand && c->operand->type) {
      const auto *dst = std::get_if<IntType>(&e->type->v);
      const auto *src = std::get_if<IntType>(&c->operand->type->v);
      if (dst && src && dst->width == src->width)
        return isAtomicExpr(c->operand);
    }
  }
  return std::holds_alternative<ConstExpr>(e->v) || std::holds_alternative<VarExpr>(e->v) ||
         std::holds_alternative<TableRefExpr>(e->v) || std::holds_alternative<IndexExpr>(e->v) ||
         std::holds_alternative<FieldExpr>(e->v) || std::holds_alternative<TupleExpr>(e->v) ||
         std::holds_alternative<StructLitExpr>(e->v) ||
         std::holds_alternative<StructUpdateExpr>(e->v) ||
         std::holds_alternative<ArrayLitExpr>(e->v);
}

class LeanEmitter {
public:
  explicit LeanEmitter(const EmitOptions &opts) : opts_(opts) {}

  auto emitModule(const ir::Module &mod) -> std::string {
    std::string out;
    out += std::format("import {}\n\n", opts_.core_import);
    out += std::format("/-! Generated by `{}`.\n", mod.origin);
    out += "High-level lifted Lean model referencing `LibcMath.Libc`. Do not edit. -/\n\n";
    out += std::format("namespace {}\n\n", opts_.lean_namespace);
    out += "open FloatLib.Floats.Formats.BinaryInterchange\n";
    out += "open Model (IEEERoundingMode)\n";
    out += "open LibcMath\n";
    out += "open LibcMath.Libc.DSL\n\n";

    // Emit active LLVM libc MathConfig snapshot captured from Clang's preprocessor.
    out += emitMathConfigDef(mod.config);

    // Extracted C++ structs.
    for (const auto &sd : mod.structs) {
      out += std::format("/-- Extracted struct `{}`. -/\n", sd.cpp_name);
      out += std::format("structure {} where\n", sd.lean_name);
      for (const auto &f : sd.fields) {
        out += std::format("  {} : {}\n", leanIdent(f.name), emitType(f.type));
      }
      out += "  deriving DecidableEq, Inhabited\n\n";
    }

    // Constant tables.
    for (const auto &tbl : mod.tables) {
      out += std::format("/-- Constant table `{}`. -/\n", tbl.cpp_name);
      out += std::format("def {} : {} :=\n  {}\n\n", tbl.lean_name, emitType(tbl.type),
                         emitConst(tbl.value, opts_.emit_float_comments, 1));
    }

    // Extracted functions.
    for (const auto &fn : mod.functions) {
      out += emitFunction(fn);
      out += "\n";
    }

    // Emit common KernelMeta + UnaryKernel bundle for the main (last) function.
    if (opts_.emit_kernel_bundle && !mod.functions.empty()) {
      out += emitKernelBundle(mod, mod.functions.back());
    }

    out += std::format("end {}\n", opts_.lean_namespace);
    return out;
  }

private:
  auto emitMathConfigDef(const MathConfig &cfg) -> std::string {
    return std::format(
        R"(/-- Active LLVM libc `LIBC_MATH_*` and target CPU configuration captured by `ast2lean`. -/
def config : Libc.MathConfig :=
  {{ arch := .{}
    armArchVersion := {}
    isBigEndian := {}
    skipAccuratePass := {}
    smallTables := {}
    noErrno := {}
    noExcept := {}
    intermediateCompInFloat := {}
    assumeRoundNearestOnly := {}
    hasSse2 := {}
    hasSsse3 := {}
    hasSse42 := {}
    hasAvx := {}
    hasAvx2 := {}
    hasAvx512f := {}
    hasFmaGlobal := {}
    hasFmaHalf := {}
    hasFmaFloat := {}
    hasFmaDouble := {}
    hasNearestInt := {}
    hasFpuFloat := {}
    hasFpuDouble := {}
    hasArmFpuFloat := {}
    hasArmFpuDouble := {}
    hasArmNeon := {}
    hasRiscVFpuFloat := {}
    hasRiscVFpuDouble := {}
    hasFastFloat16 := {}
    hasInt128 := {}
    fpLogbNanMin := {}
    targetTriple := "{}"
    implVariant := "{}" }}

)",
        cfg.arch, cfg.arm_arch_version, leanBool(cfg.is_big_endian),
        leanBool(cfg.skip_accurate_pass), leanBool(cfg.small_tables), leanBool(cfg.no_errno),
        leanBool(cfg.no_except), leanBool(cfg.intermediate_comp_in_float),
        leanBool(cfg.assume_round_nearest_only), leanBool(cfg.has_sse2), leanBool(cfg.has_ssse3),
        leanBool(cfg.has_sse42), leanBool(cfg.has_avx), leanBool(cfg.has_avx2),
        leanBool(cfg.has_avx512f), leanBool(cfg.has_fma_global), leanBool(cfg.has_fma_half),
        leanBool(cfg.has_fma_float), leanBool(cfg.has_fma_double), leanBool(cfg.has_nearest_int),
        leanBool(cfg.has_fpu_float), leanBool(cfg.has_fpu_double), leanBool(cfg.has_arm_fpu_float),
        leanBool(cfg.has_arm_fpu_double), leanBool(cfg.has_arm_neon),
        leanBool(cfg.has_riscv_fpu_float), leanBool(cfg.has_riscv_fpu_double),
        leanBool(cfg.has_fast_float16), leanBool(cfg.has_int128), leanBool(cfg.fp_logb_nan_min),
        cfg.target_triple, cfg.impl_variant);
  }

  auto emitKernelBundle(const ir::Module &mod, const Function &main_fn) -> std::string {
    std::vector<std::string> tbl_names;
    tbl_names.reserve(mod.tables.size());
    for (const auto &t : mod.tables) {
      tbl_names.push_back(std::format("\"{}\"", t.lean_name));
    }

    std::string out = std::format(
        R"(/-- Machine-readable provenance and configuration metadata for `{}`. -/
def kernelMeta : Libc.KernelMeta :=
  {{ name := "{}"
    cppFunction := "{}"
    mangledName := "{}"
    sourceFile := "{}"
    sourceCommit := "{}"
    clangVersion := "{}"
    config := config
    tables := [{}] }}

)",
        main_fn.lean_name, main_fn.lean_name, main_fn.cpp_name, main_fn.mangled_name,
        mod.source_file, mod.source_commit, mod.clang_version, joinWith(tbl_names, ", "));

    // Emit `UnaryKernel` bundle when main_fn is unary `Model fmt -> Model fmt`
    // or a static-rounding kernel `(x : Model fmt) (rounding : BitVec 32) -> Model fmt`.
    if (main_fn.params.size() == 1 && main_fn.params[0].type && main_fn.params[0].type->isFloat() &&
        main_fn.return_type && main_fn.return_type->isFloat()) {
      auto in_fmt = std::get<FloatType>(main_fn.params[0].type->v).fmt;
      auto out_fmt = std::get<FloatType>(main_fn.return_type->v).fmt;
      if (in_fmt == out_fmt) {
        std::string eval_expr = main_fn.uses_rounding_mode
                                    ? main_fn.lean_name
                                    : std::format("fun _ x => {} x", main_fn.lean_name);
        out += std::format(
            R"(/-- Extracted unary kernel bundle carrying metadata and executable implementation. -/
def kernel : Libc.UnaryKernel {} :=
  {{ info := kernelMeta
    eval := {} }}

)",
            floatFmtLean(in_fmt), eval_expr);
      }
    } else if (main_fn.params.size() == 2 && main_fn.params[0].type &&
               main_fn.params[0].type->isFloat() && main_fn.params[1].name == "rounding" &&
               main_fn.params[1].type && main_fn.params[1].type->isInt() && main_fn.return_type &&
               main_fn.return_type->isFloat()) {
      auto in_fmt = std::get<FloatType>(main_fn.params[0].type->v).fmt;
      auto out_fmt = std::get<FloatType>(main_fn.return_type->v).fmt;
      if (in_fmt == out_fmt) {
        std::string eval_expr =
            main_fn.uses_rounding_mode
                ? std::format("fun mode x => {} mode x (Libc.quickGetRound mode)",
                              main_fn.lean_name)
                : std::format("fun mode x => {} x (Libc.quickGetRound mode)", main_fn.lean_name);
        out += std::format(
            R"(/-- Extracted unary kernel bundle adapting static `FE_*` rounding to `IEEERoundingMode`. -/
def kernel : Libc.UnaryKernel {} :=
  {{ info := kernelMeta
    eval := {} }}

)",
            floatFmtLean(in_fmt), eval_expr);
      }
    } else if (main_fn.params.size() == 2 && main_fn.params[0].type &&
               main_fn.params[0].type->isFloat() && main_fn.params[1].type &&
               main_fn.params[1].type->isFloat() && main_fn.return_type &&
               main_fn.return_type->isFloat()) {
      auto fmt0 = std::get<FloatType>(main_fn.params[0].type->v).fmt;
      auto fmt1 = std::get<FloatType>(main_fn.params[1].type->v).fmt;
      auto out_fmt = std::get<FloatType>(main_fn.return_type->v).fmt;
      if (fmt0 == fmt1 && fmt0 == out_fmt) {
        std::string eval_expr = main_fn.uses_rounding_mode
                                    ? main_fn.lean_name
                                    : std::format("fun _ x y => {} x y", main_fn.lean_name);
        out += std::format(
            R"(/-- Extracted binary kernel bundle carrying metadata and executable implementation. -/
def kernel : Libc.BinaryKernel {} :=
  {{ info := kernelMeta
    eval := {} }}

)",
            floatFmtLean(fmt0), eval_expr);
      }
    } else if (main_fn.params.size() == 3 && main_fn.params[0].type &&
               main_fn.params[0].type->isFloat() && main_fn.params[1].type &&
               main_fn.params[1].type->isFloat() && main_fn.params[2].type &&
               main_fn.params[2].type->isFloat() && main_fn.return_type &&
               main_fn.return_type->isFloat()) {
      auto fmt0 = std::get<FloatType>(main_fn.params[0].type->v).fmt;
      auto fmt1 = std::get<FloatType>(main_fn.params[1].type->v).fmt;
      auto fmt2 = std::get<FloatType>(main_fn.params[2].type->v).fmt;
      auto out_fmt = std::get<FloatType>(main_fn.return_type->v).fmt;
      if (fmt0 == fmt1 && fmt0 == fmt2 && fmt0 == out_fmt) {
        std::string eval_expr = main_fn.uses_rounding_mode
                                    ? main_fn.lean_name
                                    : std::format("fun _ x y z => {} x y z", main_fn.lean_name);
        out += std::format(
            R"(/-- Extracted ternary kernel bundle carrying metadata and executable implementation. -/
def kernel : Libc.TernaryKernel {} :=
  {{ info := kernelMeta
    eval := {} }}

)",
            floatFmtLean(fmt0), eval_expr);
      }
    }
    return out;
  }

  auto currentModeArg() const -> std::string_view {
    return current_fn_uses_mode_ ? "mode" : ".nearest";
  }

  auto emitFunction(const Function &fn) -> std::string {
    current_fn_uses_mode_ = fn.uses_rounding_mode;
    std::string out;
    out += std::format("/-- Extracted from `{}` (`{}`). -/\n", fn.cpp_name, fn.mangled_name);
    if (!fn.diagnostics.empty()) {
      out += "/- Extractor diagnostics:\n";
      for (const auto &d : fn.diagnostics) {
        out += std::format("  * {}\n", d);
      }
      out += "-/\n";
    }

    std::vector<std::string> sig_params;
    if (fn.uses_rounding_mode) {
      sig_params.emplace_back("(mode : IEEERoundingMode)");
    }
    for (const auto &p : fn.params) {
      sig_params.push_back(std::format("({} : {})", leanIdent(p.name), emitType(p.type)));
    }

    out += std::format("def {} {} : {} := do\n", fn.lean_name, joinWith(sig_params, " "),
                       optionType(fn.return_type));
    if (fn.lifted_expr) {
      out += emitExprBlock(*fn.lifted_expr, 1);
      out += "\n";
    } else {
      // Unlifted loop body runs directly in Option with bounded iteration so UB is tracked.
      declared_muts_.clear();
      do_tmp_counter_ = 0;
      std::unordered_set<std::string> assigned;
      collectAssignedVars(fn.body_stmts, assigned);
      for (const auto &p : fn.params) {
        if (assigned.contains(p.name)) {
          auto id = leanIdent(p.name);
          out += std::format("  let mut {} := {}\n", id, id);
          declared_muts_.insert(p.name);
        }
      }
      for (const auto &st : fn.body_stmts) {
        out += emitDoStmt(st, 1);
      }
      if (fn.body_stmts.empty() || !std::holds_alternative<ReturnStmt>(fn.body_stmts.back().v)) {
        out += "  none\n";
      }
    }
    return out;
  }

  static void collectAssignedVars(const std::vector<Stmt> &stmts,
                                  std::unordered_set<std::string> &assigned) {
    for (const auto &st : stmts) {
      std::visit(Overloaded{
                     [&](const AssignStmt &a) { assigned.insert(a.target); },
                     [&](const AssignTupleStmt &at) {
                       for (const auto &t : at.targets) {
                         if (t != "_")
                           assigned.insert(t);
                       }
                     },
                     [&](const FieldAssignStmt &fa) {
                       if (fa.base) {
                         if (const auto *v = std::get_if<VarExpr>(&fa.base->v))
                           assigned.insert(v->name);
                       }
                     },
                     [&](const IfStmt &i) {
                       collectAssignedVars(i.then_body, assigned);
                       collectAssignedVars(i.else_body, assigned);
                     },
                     [&](const SwitchStmt &sw) {
                       for (const auto &c : sw.cases)
                         collectAssignedVars(c.body, assigned);
                       collectAssignedVars(sw.default_body, assigned);
                     },
                     [&](const WhileStmt &w) { collectAssignedVars(w.body, assigned); },
                     [&](const DoWhileStmt &dw) { collectAssignedVars(dw.body, assigned); },
                     [&](const ForStmt &f) {
                       if (f.step && *f.step)
                         collectAssignedVars({**f.step}, assigned);
                       collectAssignedVars(f.body, assigned);
                     },
                     [&](const BlockStmt &b) { collectAssignedVars(b.stmts, assigned); },
                     [](const auto &) {},
                 },
                 st.v);
    }
  }

  /// The type of a function or join point that returns `t`: `none` stands for an execution that
  /// reaches an operation C++ gives no meaning to.
  auto optionType(const TypePtr &t) -> std::string {
    return std::format("Option ({})", emitType(t));
  }

  static auto isSignedInt(const TypePtr &t) -> bool {
    if (!t)
      return false;
    const auto *it = std::get_if<IntType>(&t->v);
    return it && it->is_signed;
  }

  static auto isIntType(const TypePtr &t) -> bool {
    return t && std::holds_alternative<IntType>(t->v);
  }

  static auto isIntConst(const ExprPtr &e) -> bool {
    if (!e)
      return false;
    const auto *ce = std::get_if<ConstExpr>(&e->v);
    return ce && std::holds_alternative<IntConst>(ce->value.v);
  }

  /// Whether a binary operation can be undefined in C++, in which case it is emitted as a
  /// checked operation of `LibcMath.Libc` that returns `Option`.
  static auto isPartialBinary(const BinaryExpr &b, const TypePtr &res_ty) -> bool {
    bool is_float = (b.lhs && b.lhs->type && b.lhs->type->isFloat()) ||
                    (b.rhs && b.rhs->type && b.rhs->type->isFloat());
    if (is_float)
      return false;
    switch (b.op) {
    case BinaryOp::Shl:
    case BinaryOp::Shr:
      return !isIntConst(b.rhs);
    case BinaryOp::Add:
    case BinaryOp::Sub:
    case BinaryOp::Mul:
      return isSignedInt(res_ty) && !(isIntConst(b.lhs) && isIntConst(b.rhs));
    case BinaryOp::Div:
    case BinaryOp::Rem:
      return isIntType(res_ty);
    default:
      return false;
    }
  }

  /// Whether evaluating `e` can reach an operation that C++ leaves undefined. Used to decide
  /// whether an operand that C++ evaluates only under a condition (the branches of `?:`, the
  /// right operand of `&&` and `||`) needs a `do` block of its own.
  auto hasPartial(const ExprPtr &e) -> bool {
    if (!e)
      return false;
    auto any = [&](const std::vector<ExprPtr> &es) {
      return std::ranges::any_of(es, [&](const ExprPtr &x) { return hasPartial(x); });
    };
    return std::visit(
        Overloaded{
            [](const ConstExpr &) { return false; },
            [](const VarExpr &) { return false; },
            [](const TableRefExpr &) { return false; },
            [](const CallJoinExpr &) { return false; },
            [](const UnsupportedExpr &) { return false; },
            [&](const UnaryExpr &u) {
              return (u.op == UnaryOp::Neg && isSignedInt(e->type)) || hasPartial(u.operand);
            },
            [&](const BinaryExpr &b) {
              return isPartialBinary(b, e->type) || hasPartial(b.lhs) || hasPartial(b.rhs);
            },
            [&](const CastExpr &c) {
              return c.kind == CastKind::FloatToInt || hasPartial(c.operand);
            },
            [&](const SelectExpr &sl) {
              return hasPartial(sl.cond) || hasPartial(sl.then_e) || hasPartial(sl.else_e);
            },
            [](const IndexExpr &) { return true; },
            [&](const FieldExpr &f) { return hasPartial(f.base); },
            [&](const StructLitExpr &sl) {
              return std::ranges::any_of(sl.fields,
                                         [&](const auto &f) { return hasPartial(f.second); });
            },
            [&](const StructUpdateExpr &su) { return hasPartial(su.base) || hasPartial(su.value); },
            [&](const ArrayLitExpr &al) { return any(al.elems); },
            [&](const CoreCallExpr &cc) { return any(cc.args); },
            [&](const PolyevalExpr &pe) { return hasPartial(pe.var) || any(pe.coeffs); },
            [](const FuncCallExpr &) { return true; },
            [&](const TupleExpr &te) { return any(te.elems); },
            // A nested block is emitted as a `do` block of its own.
            [](const auto &) { return true; },
        },
        e->v);
  }

  /// `e` as a `do` block of its own, so that the checked operations inside it run only when the
  /// block does.
  auto emitLazy(const ExprPtr &e) -> std::string {
    return hasPartial(e) ? std::format("(do pure ({}))", emitInlineExpr(e))
                         : std::format("pure ({})", emitInlineExpr(e));
  }

  /// If `text` is exactly one nested action `(← action)`, the action.
  static auto soleAction(std::string_view text) -> std::optional<std::string> {
    constexpr std::string_view open = "(← ";
    if (!text.starts_with(open) || !text.ends_with(')'))
      return std::nullopt;
    int depth = 0;
    for (std::size_t k = 0; k < text.size(); ++k) {
      if (text[k] == '(')
        ++depth;
      else if (text[k] == ')' && --depth == 0 && k + 1 != text.size())
        return std::nullopt;
    }
    return std::string(text.substr(open.size(), text.size() - open.size() - 1));
  }

  auto emitArg(const ExprPtr &e) -> std::string {
    auto s = emitInlineExpr(e);
    return isAtomicExpr(e) ? s : std::format("({})", s);
  }

  auto emitShiftAmountNat(const ExprPtr &rhs) -> std::string {
    if (rhs) {
      const Expr *inner = rhs.get();
      while (const auto *ce = std::get_if<CastExpr>(&inner->v)) {
        if ((ce->kind == CastKind::NoOp || ce->kind == CastKind::IntToInt) && ce->operand) {
          inner = ce->operand.get();
        } else {
          break;
        }
      }
      if (const auto *ce = std::get_if<ConstExpr>(&inner->v)) {
        if (const auto *ic = std::get_if<IntConst>(&ce->value.v);
            ic && ic->fits_i64 && ic->signed_val >= 0) {
          return std::to_string(ic->signed_val);
        }
      }
      if (const auto *ve = std::get_if<VarExpr>(&rhs->v)) {
        return std::format("{}.toNat", leanIdent(ve->name));
      }
    }
    return std::format("({}).toNat", emitInlineExpr(rhs));
  }

  auto emitInlineExpr(const ExprPtr &e) -> std::string {
    if (!e)
      return "()";
    return std::visit(
        Overloaded{
            [&](const ConstExpr &c) {
              if (e->type && e->type->isVoid())
                return std::string("()");
              return emitConst(c.value, opts_.emit_float_comments);
            },
            [](const VarExpr &v) { return leanIdent(v.name); },
            [](const TableRefExpr &t) { return t.table_name; },
            [&](const UnaryExpr &u) {
              switch (u.op) {
              case UnaryOp::Neg:
                if (e->type && e->type->isFloat()) {
                  return std::format("Libc.fneg {}", emitArg(u.operand));
                }
                if (isSignedInt(e->type))
                  return std::format("(← Libc.sneg? {})", emitArg(u.operand));
                return std::format("-{}", emitArg(u.operand));
              case UnaryOp::BitNot:
                return std::format("~~~{}", emitArg(u.operand));
              case UnaryOp::LogNot:
                return std::format("!{}", emitArg(u.operand));
              }
              return emitArg(u.operand);
            },
            [&](const BinaryExpr &b) { return emitBinary(b, e->type); },
            [&](const CastExpr &c) { return emitCast(c, e->type); },
            [&](const SelectExpr &s) {
              if (hasPartial(s.then_e) || hasPartial(s.else_e)) {
                return std::format("(← if {} then {} else {})", emitInlineExpr(s.cond),
                                   emitLazy(s.then_e), emitLazy(s.else_e));
              }
              return std::format("if {} then {} else {}", emitInlineExpr(s.cond),
                                 emitInlineExpr(s.then_e), emitInlineExpr(s.else_e));
            },
            [&](const IndexExpr &ix) {
              if (const auto *ce = std::get_if<ConstExpr>(&ix.index->v)) {
                if (const auto *ic = std::get_if<IntConst>(&ce->value.v);
                    ic && ic->fits_i64 && ic->signed_val >= 0) {
                  return std::format("(← {}[{}]?)", emitArg(ix.base), ic->signed_val);
                }
              }
              return std::format("(← {}[{}.toNat]?)", emitArg(ix.base), emitArg(ix.index));
            },
            [&](const FieldExpr &f) {
              return std::format("{}.{}", emitArg(f.base), leanIdent(f.field));
            },
            [&](const StructLitExpr &sl) {
              std::vector<std::string> parts;
              parts.reserve(sl.fields.size());
              for (const auto &[fname, fe] : sl.fields) {
                parts.push_back(std::format("{} := {}", leanIdent(fname), emitInlineExpr(fe)));
              }
              if (sl.type_name.empty()) {
                return std::format("{{ {} }}", joinWith(parts, ", "));
              }
              return std::format("({{ {} }} : {})", joinWith(parts, ", "), sl.type_name);
            },
            [&](const StructUpdateExpr &su) {
              return std::format("{{ {} with {} := {} }}", emitInlineExpr(su.base),
                                 leanIdent(su.field), emitInlineExpr(su.value));
            },
            [&](const ArrayLitExpr &al) {
              std::vector<std::string> parts;
              parts.reserve(al.elems.size());
              for (const auto &el : al.elems)
                parts.push_back(emitInlineExpr(el));
              return std::format("#[{}]", joinWith(parts, ", "));
            },
            [&](const CoreCallExpr &cc) {
              // Use clean Libc.DSL syntax for multiply_add / multiply_sub / sub_multiply.
              if (cc.op == CoreOpKind::MultiplyAdd && cc.args.size() == 3) {
                return std::format("madd[config, {}]({}, {}, {})", currentModeArg(),
                                   emitInlineExpr(cc.args[0]), emitInlineExpr(cc.args[1]),
                                   emitInlineExpr(cc.args[2]));
              }
              if (cc.op == CoreOpKind::MultiplySub && cc.args.size() == 3) {
                return std::format("msub[config, {}]({}, {}, {})", currentModeArg(),
                                   emitInlineExpr(cc.args[0]), emitInlineExpr(cc.args[1]),
                                   emitInlineExpr(cc.args[2]));
              }
              if (cc.op == CoreOpKind::SubMultiply && cc.args.size() == 3) {
                return std::format("submul[config, {}]({}, {}, {})", currentModeArg(),
                                   emitInlineExpr(cc.args[0]), emitInlineExpr(cc.args[1]),
                                   emitInlineExpr(cc.args[2]));
              }
              if (cc.op == CoreOpKind::BitCast && cc.args.size() == 1) {
                return std::format("(Libc.bitCast {} : {})", emitArg(cc.args[0]),
                                   emitType(e->type));
              }
              if (cc.op == CoreOpKind::Unreachable) {
                return std::string("(← (none : Option Unit))");
              }
              if (cc.op == CoreOpKind::FPBitsOfBits && cc.args.size() == 1) {
                if (e->type) {
                  if (const auto *ft = std::get_if<FPBitsType>(&e->type->v)) {
                    return std::format("Libc.FPBits.ofBits (fmt := {}) {}", floatFmtLean(ft->fmt),
                                       emitArg(cc.args[0]));
                  }
                }
              }
              if ((cc.op == CoreOpKind::DyadicFastAs || cc.op == CoreOpKind::DyadicGenericAs ||
                   cc.op == CoreOpKind::DyadicAs) &&
                  cc.args.size() == 1 && cc.type_args.size() == 1) {
                return std::format("{} config {} {} {}", cc.lean_name, cc.type_args[0],
                                   currentModeArg(), emitArg(cc.args[0]));
              }
              if (cc.op == CoreOpKind::IntLogb && cc.args.size() == 1 &&
                  cc.type_args.size() == 1) {
                return std::format("Libc.intlogb config {} {}", cc.type_args[0],
                                   emitArg(cc.args[0]));
              }
              if ((cc.op == CoreOpKind::DyadicShiftLeft || cc.op == CoreOpKind::DyadicShiftRight ||
                   cc.op == CoreOpKind::BigIntGetBit || cc.op == CoreOpKind::BigIntSetBit) &&
                  cc.args.size() == 2) {
                return std::format("{} {} {}", cc.lean_name, emitArg(cc.args[0]),
                                   emitShiftAmountNat(cc.args[1]));
              }
              if (cc.op == CoreOpKind::FPBitsCreateValue && cc.args.size() == 3 &&
                  cc.type_args.size() == 1) {
                return std::format("Libc.FPBits.createValue {} {} {} {}", cc.type_args[0],
                                   emitArg(cc.args[0]), emitShiftAmountNat(cc.args[1]),
                                   emitShiftAmountNat(cc.args[2]));
              }
              if (cc.op == CoreOpKind::DyadicRound && cc.args.size() == 4 &&
                  cc.type_args.size() == 1) {
                return std::format("Libc.DyadicFloat.round {} config {} {} {} {} {}",
                                   cc.type_args[0], currentModeArg(), emitArg(cc.args[0]),
                                   emitArg(cc.args[1]), emitArg(cc.args[2]),
                                   emitShiftAmountNat(cc.args[3]));
              }

              std::vector<std::string> parts;
              parts.push_back(cc.lean_name);
              for (const auto &ta : cc.type_args)
                parts.push_back(ta);
              if (cc.needs_config)
                parts.emplace_back("config");
              if (cc.needs_mode)
                parts.emplace_back(currentModeArg());
              for (const auto &a : cc.args)
                parts.push_back(emitArg(a));
              for (const auto &tr : cc.trailing_args)
                parts.push_back(tr);
              return joinWith(parts, " ");
            },
            [&](const PolyevalExpr &pe) {
              auto m = currentModeArg();
              if (pe.scheme == PolyScheme::Estrin) {
                if (pe.array_arg && pe.coeffs.size() == 1) {
                  if (pe.offset > 0) {
                    return std::format("estrin[config, {}, {}] {} {}", m, pe.offset,
                                       emitArg(pe.var), emitArg(pe.coeffs[0]));
                  }
                  return std::format("estrin[config, {}] {} {}", m, emitArg(pe.var),
                                     emitArg(pe.coeffs[0]));
                }
                std::vector<std::string> cs;
                for (const auto &c : pe.coeffs)
                  cs.push_back(emitInlineExpr(c));
                return std::format("Libc.estrinList config {} {} [{}]", m, emitArg(pe.var),
                                   joinWith(cs, ", "));
              }
              if (pe.array_arg && pe.coeffs.size() == 1) {
                auto fn_name =
                    (pe.scheme == PolyScheme::AltHorner) ? "Libc.altpolyeval" : "Libc.polyeval";
                return std::format("{} config {} {} {} {}", fn_name, m, emitArg(pe.var),
                                   emitArg(pe.coeffs[0]), pe.offset);
              }
              auto kw = (pe.scheme == PolyScheme::AltHorner) ? "althorner" : "horner";
              std::vector<std::string> cs;
              cs.reserve(pe.coeffs.size());
              for (const auto &c : pe.coeffs)
                cs.push_back(emitInlineExpr(c));
              return std::format("{}[config, {}] {} [{}]", kw, m, emitArg(pe.var),
                                 joinWith(cs, ", "));
            },
            [&](const FuncCallExpr &fc) {
              std::vector<std::string> parts;
              parts.push_back(leanIdent(fc.callee));
              if (fc.needs_mode && !fc.is_local_lambda)
                parts.emplace_back(currentModeArg());
              if (fc.is_local_lambda && fc.args.empty()) {
                parts.emplace_back("()");
              } else {
                for (const auto &a : fc.args)
                  parts.push_back(emitArg(a));
              }
              return std::format("(← {})", joinWith(parts, " "));
            },
            [&](const TupleExpr &te) {
              std::vector<std::string> parts;
              parts.reserve(te.elems.size());
              for (const auto &el : te.elems)
                parts.push_back(emitInlineExpr(el));
              return std::format("({})", joinWith(parts, ", "));
            },
            [&](const CallJoinExpr &cj) { return std::format("{} ()", leanIdent(cj.name)); },
            [&](const UnsupportedExpr &u) {
              return std::format("(Libc.unsupported \"{}\")", u.reason);
            },
            [&](const auto &) { return std::format("(← do\n{})", emitExprBlock(e, 2)); },
        },
        e->v);
  }

  auto emitBinary(const BinaryExpr &b, const TypePtr &res_ty) -> std::string {
    bool is_float_operands = (b.lhs && b.lhs->type && b.lhs->type->isFloat()) ||
                             (b.rhs && b.rhs->type && b.rhs->type->isFloat());
    if (is_float_operands) {
      auto m = currentModeArg();
      switch (b.op) {
      case BinaryOp::Add:
        return std::format("Libc.fadd {} {} {}", m, emitArg(b.lhs), emitArg(b.rhs));
      case BinaryOp::Sub:
        return std::format("Libc.fsub {} {} {}", m, emitArg(b.lhs), emitArg(b.rhs));
      case BinaryOp::Mul:
        return std::format("Libc.fmul {} {} {}", m, emitArg(b.lhs), emitArg(b.rhs));
      case BinaryOp::Div:
        return std::format("Libc.fdiv {} {} {}", m, emitArg(b.lhs), emitArg(b.rhs));
      case BinaryOp::Eq:
        return std::format("Libc.feq {} {}", emitArg(b.lhs), emitArg(b.rhs));
      case BinaryOp::Ne:
        return std::format("Libc.fne {} {}", emitArg(b.lhs), emitArg(b.rhs));
      case BinaryOp::Lt:
        return std::format("Libc.flt {} {}", emitArg(b.lhs), emitArg(b.rhs));
      case BinaryOp::Le:
        return std::format("Libc.fle {} {}", emitArg(b.lhs), emitArg(b.rhs));
      case BinaryOp::Gt:
        return std::format("Libc.fgt {} {}", emitArg(b.lhs), emitArg(b.rhs));
      case BinaryOp::Ge:
        return std::format("Libc.fge {} {}", emitArg(b.lhs), emitArg(b.rhs));
      default:
        break;
      }
    }

    // Shifts in Lean take `Nat` cleanly regardless of RHS BitVec width!
    // A shift by a variable amount is undefined from the width of the left operand on.
    auto shift_amount = [&]() -> std::string {
      auto amount = emitShiftAmountNat(b.rhs);
      if (isIntConst(b.rhs))
        return amount;
      std::uint32_t width = 32;
      if (b.lhs && b.lhs->type) {
        if (const auto *it = std::get_if<IntType>(&b.lhs->type->v))
          width = it->width;
      }
      return std::format("(← Libc.shiftAmount? {} {})", width, amount);
    };
    if (b.op == BinaryOp::Shl) {
      return std::format("{} <<< {}", emitArg(b.lhs), shift_amount());
    }
    if (b.op == BinaryOp::Shr) {
      bool signed_lhs = b.lhs && b.lhs->type && std::holds_alternative<IntType>(b.lhs->type->v) &&
                        std::get<IntType>(b.lhs->type->v).is_signed;
      if (signed_lhs) {
        return std::format("BitVec.sshiftRight {} {}", emitArg(b.lhs), shift_amount());
      }
      return std::format("{} >>> {}", emitArg(b.lhs), shift_amount());
    }

    if (b.lhs && b.lhs->type) {
      if (const auto *it = std::get_if<IntType>(&b.lhs->type->v)) {
        if (it->is_signed) {
          switch (b.op) {
          case BinaryOp::Lt:
            return std::format("BitVec.slt {} {}", emitArg(b.lhs), emitArg(b.rhs));
          case BinaryOp::Le:
            return std::format("BitVec.sle {} {}", emitArg(b.lhs), emitArg(b.rhs));
          case BinaryOp::Gt:
            return std::format("BitVec.slt {} {}", emitArg(b.rhs), emitArg(b.lhs));
          case BinaryOp::Ge:
            return std::format("BitVec.sle {} {}", emitArg(b.rhs), emitArg(b.lhs));
          case BinaryOp::Div:
            return std::format("(← Libc.sdiv? {} {})", emitArg(b.lhs), emitArg(b.rhs));
          case BinaryOp::Rem:
            return std::format("(← Libc.srem? {} {})", emitArg(b.lhs), emitArg(b.rhs));
          default:
            break;
          }
        } else {
          switch (b.op) {
          case BinaryOp::Lt:
            return std::format("BitVec.ult {} {}", emitArg(b.lhs), emitArg(b.rhs));
          case BinaryOp::Le:
            return std::format("BitVec.ule {} {}", emitArg(b.lhs), emitArg(b.rhs));
          case BinaryOp::Gt:
            return std::format("BitVec.ult {} {}", emitArg(b.rhs), emitArg(b.lhs));
          case BinaryOp::Ge:
            return std::format("BitVec.ule {} {}", emitArg(b.rhs), emitArg(b.lhs));
          default:
            break;
          }
        }
      }
    }

    if (isPartialBinary(b, res_ty)) {
      bool is_signed = isSignedInt(res_ty);
      std::string_view checked;
      switch (b.op) {
      case BinaryOp::Add:
        checked = "Libc.sadd?";
        break;
      case BinaryOp::Sub:
        checked = "Libc.ssub?";
        break;
      case BinaryOp::Mul:
        checked = "Libc.smul?";
        break;
      case BinaryOp::Div:
        checked = is_signed ? "Libc.sdiv?" : "Libc.udiv?";
        break;
      case BinaryOp::Rem:
        checked = is_signed ? "Libc.srem?" : "Libc.urem?";
        break;
      default:
        break;
      }
      if (!checked.empty())
        return std::format("(← {} {} {})", checked, emitArg(b.lhs), emitArg(b.rhs));
    }

    // C++ evaluates the right operand of `&&` and `||` only when the left one does not decide.
    if ((b.op == BinaryOp::LogAnd || b.op == BinaryOp::LogOr) && hasPartial(b.rhs)) {
      bool is_and = b.op == BinaryOp::LogAnd;
      return std::format("(← if {} then {} else {})", emitInlineExpr(b.lhs),
                         is_and ? emitLazy(b.rhs) : std::string("pure true"),
                         is_and ? std::string("pure false") : emitLazy(b.rhs));
    }

    std::string_view sym = "+";
    switch (b.op) {
    case BinaryOp::Add:
      sym = "+";
      break;
    case BinaryOp::Sub:
      sym = "-";
      break;
    case BinaryOp::Mul:
      sym = "*";
      break;
    case BinaryOp::Div:
      sym = "/";
      break;
    case BinaryOp::Rem:
      sym = "%";
      break;
    case BinaryOp::BitAnd:
      sym = "&&&";
      break;
    case BinaryOp::BitOr:
      sym = "|||";
      break;
    case BinaryOp::BitXor:
      sym = "^^^";
      break;
    case BinaryOp::Shl:
      sym = "<<<";
      break;
    case BinaryOp::Shr:
      sym = ">>>";
      break;
    case BinaryOp::Eq:
      sym = "==";
      break;
    case BinaryOp::Ne:
      sym = "!=";
      break;
    case BinaryOp::Lt:
      sym = "<";
      break;
    case BinaryOp::Le:
      sym = "≤";
      break;
    case BinaryOp::Gt:
      sym = ">";
      break;
    case BinaryOp::Ge:
      sym = "≥";
      break;
    case BinaryOp::LogAnd:
      sym = "&&";
      break;
    case BinaryOp::LogOr:
      sym = "||";
      break;
    }
    (void)res_ty;
    return std::format("{} {} {}", emitArg(b.lhs), sym, emitArg(b.rhs));
  }

  auto emitCast(const CastExpr &c, const TypePtr &dst_ty) -> std::string {
    switch (c.kind) {
    case CastKind::NoOp:
      return emitInlineExpr(c.operand);
    case CastKind::FloatToFloat:
      if (const auto *ft = std::get_if<FloatType>(&dst_ty->v)) {
        return std::format("Libc.fpCast {} {} {}", floatFmtLean(ft->fmt), currentModeArg(),
                           emitArg(c.operand));
      }
      break;
    case CastKind::FloatToInt:
      if (const auto *it = std::get_if<IntType>(&dst_ty->v)) {
        return std::format("(← {} {} {})", it->is_signed ? "Libc.fptosi?" : "Libc.fptoui?",
                           it->width, emitArg(c.operand));
      }
      break;
    case CastKind::IntToFloat:
      if (const auto *ft = std::get_if<FloatType>(&dst_ty->v)) {
        bool src_signed = c.operand && c.operand->type &&
                          std::holds_alternative<IntType>(c.operand->type->v) &&
                          std::get<IntType>(c.operand->type->v).is_signed;
        return std::format("{} {} {} {}", src_signed ? "Libc.sitofp" : "Libc.uitofp",
                           floatFmtLean(ft->fmt), currentModeArg(), emitArg(c.operand));
      }
      break;
    case CastKind::IntToInt:
      if (const auto *dst_i = std::get_if<IntType>(&dst_ty->v)) {
        bool src_signed = false;
        std::uint32_t src_w = dst_i->width;
        if (c.operand && c.operand->type) {
          if (const auto *src_i = std::get_if<IntType>(&c.operand->type->v)) {
            src_signed = src_i->is_signed;
            src_w = src_i->width;
          }
        }
        if (src_w == dst_i->width)
          return emitInlineExpr(c.operand);
        if (dst_i->width > src_w && src_signed) {
          return std::format("BitVec.signExtend {} {}", dst_i->width, emitArg(c.operand));
        }
        return std::format("BitVec.setWidth {} {}", dst_i->width, emitArg(c.operand));
      }
      break;
    case CastKind::BitCast:
      return std::format("(Libc.bitCast {} : {})", emitArg(c.operand), emitType(dst_ty));
    case CastKind::ToBool:
      return std::format("({} != 0)", emitInlineExpr(c.operand));
    case CastKind::BoolToInt:
      if (const auto *dst_i = std::get_if<IntType>(&dst_ty->v)) {
        return std::format("(if {} then 0x1#{} else 0x0#{})", emitInlineExpr(c.operand),
                           dst_i->width, dst_i->width);
      }
      break;
    }
    return std::format("({} : {})", emitInlineExpr(c.operand), emitType(dst_ty));
  }

  auto emitExprBlock(const ExprPtr &e, int ind) -> std::string {
    if (!e)
      return indentStr(ind) + "()";
    auto pad = indentStr(ind);

    if (const auto *le = std::get_if<LetExpr>(&e->v)) {
      std::string out;
      if (std::holds_alternative<IfExpr>(le->value->v) ||
          std::holds_alternative<MatchExpr>(le->value->v) ||
          std::holds_alternative<LetExpr>(le->value->v)) {
        out += std::format("{}let {} ← do\n{}\n", pad, leanIdent(le->name),
                           emitExprBlock(le->value, ind + 1));
      } else {
        // A value that is one checked operation is bound with `←`.
        auto value = emitInlineExpr(le->value);
        if (auto action = soleAction(value)) {
          out += std::format("{}let {} ← {}\n", pad, leanIdent(le->name), *action);
        } else {
          out += std::format("{}let {} := {}\n", pad, leanIdent(le->name), value);
        }
      }
      out += emitExprBlock(le->body, ind);
      return out;
    }

    if (const auto *lj = std::get_if<LetJoinExpr>(&e->v)) {
      std::string out =
          std::format("{}let {} (_ : Unit) : {} := do\n{}\n", pad, leanIdent(lj->name),
                      optionType(lj->result_type), emitExprBlock(lj->join_body, ind + 1));
      out += emitExprBlock(lj->body, ind);
      return out;
    }

    if (const auto *lf = std::get_if<LetFuncExpr>(&e->v)) {
      std::vector<std::string> sig;
      if (lf->params.empty()) {
        sig.emplace_back("(_ : Unit)");
      } else {
        for (const auto &[pn, pt] : lf->params)
          sig.push_back(std::format("({} : {})", leanIdent(pn), emitType(pt)));
      }
      std::string out =
          std::format("{}let {} {} : {} := do\n{}\n", pad, leanIdent(lf->name), joinWith(sig, " "),
                      optionType(lf->result_type), emitExprBlock(lf->func_body, ind + 1));
      out += emitExprBlock(lf->body, ind);
      return out;
    }

    if (const auto *lt = std::get_if<LetTupleExpr>(&e->v)) {
      std::vector<std::string> names;
      for (const auto &[n, _] : lt->bindings)
        names.push_back(n == "_" ? std::string("_") : leanIdent(n));
      std::string out;
      if (std::holds_alternative<IfExpr>(lt->value->v) ||
          std::holds_alternative<MatchExpr>(lt->value->v) ||
          std::holds_alternative<LetExpr>(lt->value->v)) {
        out += std::format("{}let ({}) ← do\n{}\n", pad, joinWith(names, ", "),
                           emitExprBlock(lt->value, ind + 1));
      } else {
        auto val = emitInlineExpr(lt->value);
        if (auto action = soleAction(val)) {
          out += std::format("{}let ({}) ← {}\n", pad, joinWith(names, ", "), *action);
        } else {
          out += std::format("{}let ({}) := {}\n", pad, joinWith(names, ", "), val);
        }
      }
      out += emitExprBlock(lt->body, ind);
      return out;
    }

    if (const auto *ie = std::get_if<IfExpr>(&e->v)) {
      std::string out = std::format("{}if {} then\n{}\n", pad, emitInlineExpr(ie->cond),
                                    emitExprBlock(ie->then_e, ind + 1));
      const ExprPtr *cur_else = &ie->else_e;
      while (*cur_else && std::holds_alternative<IfExpr>((*cur_else)->v)) {
        const auto &nested = std::get<IfExpr>((*cur_else)->v);
        out += std::format("{}else if {} then\n{}\n", pad, emitInlineExpr(nested.cond),
                           emitExprBlock(nested.then_e, ind + 1));
        cur_else = &nested.else_e;
      }
      out += std::format("{}else\n{}", pad, emitExprBlock(*cur_else, ind + 1));
      return out;
    }

    if (const auto *me = std::get_if<MatchExpr>(&e->v)) {
      std::string out = std::format("{}match {} with\n", pad, emitInlineExpr(me->scrutinee));
      for (const auto &arm : me->arms) {
        std::vector<std::string> pats;
        for (const auto &p : arm.patterns)
          pats.push_back(emitConst(p, opts_.emit_float_comments));
        out += std::format("{}| {} =>\n{}\n", pad, joinWith(pats, " | "),
                           emitExprBlock(arm.body, ind + 1));
      }
      out += std::format("{}| _ =>\n{}", pad, emitExprBlock(me->default_arm, ind + 1));
      return out;
    }

    // The end of a block: a join point is called as it is, and a value is returned.
    if (std::holds_alternative<CallJoinExpr>(e->v))
      return pad + emitInlineExpr(e);
    return std::format("{}pure ({})", pad, emitInlineExpr(e));
  }

  static auto hasContinueStmt(const std::vector<Stmt> &stmts) -> bool {
    return std::ranges::any_of(stmts, [](const Stmt &s) {
      return std::visit(Overloaded{
                            [](const ContinueStmt &) { return true; },
                            [](const IfStmt &i) {
                              return hasContinueStmt(i.then_body) || hasContinueStmt(i.else_body);
                            },
                            [](const BlockStmt &b) { return hasContinueStmt(b.stmts); },
                            [](const auto &) { return false; },
                        },
                        s.v);
    });
  }

  auto emitDoStmt(const Stmt &st, int ind) -> std::string {
    auto pad = indentStr(ind);
    return std::visit(
        Overloaded{
            [&](const VarDeclStmt &v) {
              if (!v.is_const && declared_muts_.contains(v.name)) {
                if (v.init) {
                  auto val = emitInlineExpr(*v.init);
                  if (auto action = soleAction(val)) {
                    return std::format("{}{} ← {}\n", pad, leanIdent(v.name), *action);
                  }
                  return std::format("{}{} := {}\n", pad, leanIdent(v.name), val);
                }
                return std::format("{}{} := default\n", pad, leanIdent(v.name));
              }
              std::string kw = v.is_const ? "let" : "let mut";
              if (!v.is_const)
                declared_muts_.insert(v.name);
              if (v.init) {
                auto val = emitInlineExpr(*v.init);
                if (auto action = soleAction(val)) {
                  return std::format("{}{} {} : {} ← {}\n", pad, kw, leanIdent(v.name),
                                     emitType(v.type), *action);
                }
                return std::format("{}{} {} : {} := {}\n", pad, kw, leanIdent(v.name),
                                   emitType(v.type), val);
              }
              return std::format("{}{} {} : {} := default\n", pad, kw, leanIdent(v.name),
                                 emitType(v.type));
            },
            [&](const TupleDeclStmt &td) {
              std::vector<std::string> tmps;
              tmps.reserve(td.bindings.size());
              for (std::size_t k = 0; k < td.bindings.size(); ++k)
                tmps.push_back(std::format("__t{}", do_tmp_counter_++));
              auto val = emitInlineExpr(td.init);
              std::string out;
              if (auto action = soleAction(val)) {
                out += std::format("{}let ({}) ← {}\n", pad, joinWith(tmps, ", "), *action);
              } else {
                out += std::format("{}let ({}) := {}\n", pad, joinWith(tmps, ", "), val);
              }
              for (std::size_t k = 0; k < td.bindings.size(); ++k) {
                const auto &[n, ty] = td.bindings[k];
                if (n == "_")
                  continue;
                if (declared_muts_.contains(n)) {
                  out += std::format("{}{} := {}\n", pad, leanIdent(n), tmps[k]);
                } else {
                  declared_muts_.insert(n);
                  out += std::format("{}let mut {} : {} := {}\n", pad, leanIdent(n), emitType(ty),
                                     tmps[k]);
                }
              }
              return out;
            },
            [&](const AssignStmt &a) {
              if (a.compound_op) {
                auto lhs = Expr::make(VarExpr{a.target}, a.value->type);
                auto combined = Expr::make(BinaryExpr{*a.compound_op, lhs, a.value}, a.value->type);
                return std::format("{}{} := {}\n", pad, leanIdent(a.target),
                                   emitInlineExpr(combined));
              }
              auto val = emitInlineExpr(a.value);
              if (auto action = soleAction(val)) {
                return std::format("{}{} ← {}\n", pad, leanIdent(a.target), *action);
              }
              return std::format("{}{} := {}\n", pad, leanIdent(a.target), val);
            },
            [&](const AssignTupleStmt &at) {
              std::vector<std::string> tmps;
              tmps.reserve(at.targets.size());
              for (std::size_t k = 0; k < at.targets.size(); ++k)
                tmps.push_back(std::format("__t{}", do_tmp_counter_++));
              auto val = emitInlineExpr(at.value);
              std::string out;
              if (auto action = soleAction(val)) {
                out += std::format("{}let ({}) ← {}\n", pad, joinWith(tmps, ", "), *action);
              } else {
                out += std::format("{}let ({}) := {}\n", pad, joinWith(tmps, ", "), val);
              }
              for (std::size_t k = 0; k < at.targets.size(); ++k) {
                if (at.targets[k] == "_")
                  continue;
                out += std::format("{}{} := {}\n", pad, leanIdent(at.targets[k]), tmps[k]);
              }
              return out;
            },
            [&](const LocalFuncStmt &lf) {
              std::vector<std::string> sig;
              if (lf.params.empty()) {
                sig.emplace_back("(_ : Unit)");
              } else {
                for (const auto &[pn, pt] : lf.params)
                  sig.push_back(std::format("({} : {})", leanIdent(pn), emitType(pt)));
              }
              std::string out = std::format("{}let {} {} : {} := do\n", pad, leanIdent(lf.name),
                                            joinWith(sig, " "), optionType(lf.return_type));
              if (lf.lifted_body) {
                out += emitExprBlock(*lf.lifted_body, ind + 1) + "\n";
              } else {
                for (const auto &s : lf.body_stmts)
                  out += emitDoStmt(s, ind + 1);
                if (lf.return_type && lf.return_type->isVoid()) {
                  out += std::format("{}pure ()\n", indentStr(ind + 1));
                } else if (lf.body_stmts.empty() ||
                           !std::holds_alternative<ReturnStmt>(lf.body_stmts.back().v)) {
                  out += std::format("{}none\n", indentStr(ind + 1));
                }
              }
              return out;
            },
            [&](const FieldAssignStmt &fa) {
              ExprPtr rhs = fa.value;
              if (fa.compound_op) {
                auto cur = Expr::make(FieldExpr{fa.base, fa.field}, fa.value->type);
                rhs = Expr::make(BinaryExpr{*fa.compound_op, std::move(cur), rhs}, fa.value->type);
              }
              auto base_s = emitInlineExpr(fa.base);
              return std::format("{}{} := {{ {} with {} := {} }}\n", pad, base_s, base_s,
                                 leanIdent(fa.field), emitInlineExpr(rhs));
            },
            [&](const ExprStmt &es) {
              auto val = emitInlineExpr(es.expr);
              if (auto action = soleAction(val)) {
                return std::format("{}let _ ← {}\n", pad, *action);
              }
              return std::format("{}let _ := {}\n", pad, val);
            },
            [&](const IfStmt &ifs) {
              std::string out = std::format("{}if {} then\n", pad, emitInlineExpr(ifs.cond));
              auto saved_muts = declared_muts_;
              if (ifs.then_body.empty()) {
                out += std::format("{}pure ()\n", indentStr(ind + 1));
              } else {
                for (const auto &s : ifs.then_body)
                  out += emitDoStmt(s, ind + 1);
              }
              declared_muts_ = saved_muts;
              if (!ifs.else_body.empty()) {
                out += std::format("{}else\n", pad);
                for (const auto &s : ifs.else_body)
                  out += emitDoStmt(s, ind + 1);
                declared_muts_ = saved_muts;
              }
              return out;
            },
            [&](const SwitchStmt &sw) {
              std::string out = std::format("{}match {} with\n", pad, emitInlineExpr(sw.scrutinee));
              for (const auto &c : sw.cases) {
                std::vector<std::string> pats;
                for (const auto &v : c.values)
                  pats.push_back(emitConst(v, opts_.emit_float_comments));
                out += std::format("{}| {} =>\n", pad, joinWith(pats, " | "));
                if (c.body.empty()) {
                  out += std::format("{}pure ()\n", indentStr(ind + 1));
                } else {
                  for (const auto &s : c.body)
                    out += emitDoStmt(s, ind + 1);
                }
              }
              out += std::format("{}| _ =>\n", pad);
              if (sw.default_body.empty()) {
                out += std::format("{}pure ()\n", indentStr(ind + 1));
              } else {
                for (const auto &s : sw.default_body)
                  out += emitDoStmt(s, ind + 1);
              }
              return out;
            },
            [&](const WhileStmt &w) {
              std::string out = std::format("{}for _ in [:65536] do\n", pad);
              out += std::format("{}if !({}) then break\n", indentStr(ind + 1),
                                 emitInlineExpr(w.cond));
              auto saved_muts = declared_muts_;
              for (const auto &s : w.body)
                out += emitDoStmt(s, ind + 1);
              declared_muts_ = saved_muts;
              return out;
            },
            [&](const DoWhileStmt &dw) {
              std::string out = std::format("{}for _ in [:65536] do\n", pad);
              auto saved_muts = declared_muts_;
              for (const auto &s : dw.body)
                out += emitDoStmt(s, ind + 1);
              declared_muts_ = saved_muts;
              out += std::format("{}if !({}) then break\n", indentStr(ind + 1),
                                 emitInlineExpr(dw.cond));
              return out;
            },
            [&](const ForStmt &f) {
              std::string out;
              if (f.init && *f.init)
                out += emitDoStmt(**f.init, ind);
              bool has_cont = (f.step && *f.step) && hasContinueStmt(f.body);
              std::string first_var;
              if (has_cont) {
                first_var = std::format("__first{}", do_tmp_counter_++);
                out += std::format("{}let mut {} := true\n", pad, first_var);
              }
              out += std::format("{}for _ in [:65536] do\n", pad);
              if (has_cont) {
                out += std::format("{}if !{} then\n", indentStr(ind + 1), first_var);
                out += emitDoStmt(**f.step, ind + 2);
                out += std::format("{}{} := false\n", indentStr(ind + 1), first_var);
              }
              if (f.cond) {
                out += std::format("{}if !({}) then break\n", indentStr(ind + 1),
                                   emitInlineExpr(*f.cond));
              }
              auto saved_muts = declared_muts_;
              for (const auto &s : f.body)
                out += emitDoStmt(s, ind + 1);
              declared_muts_ = saved_muts;
              if (!has_cont && f.step && *f.step)
                out += emitDoStmt(**f.step, ind + 1);
              return out;
            },
            [&](const ReturnStmt &r) {
              if (r.value)
                return std::format("{}return {}\n", pad, emitInlineExpr(*r.value));
              return std::format("{}return ()\n", pad);
            },
            [&](const BlockStmt &b) {
              std::string out;
              for (const auto &s : b.stmts)
                out += emitDoStmt(s, ind);
              return out;
            },
            [&](const BreakStmt &) { return std::format("{}break\n", pad); },
            [&](const ContinueStmt &) { return std::format("{}continue\n", pad); },
            [&](const UnsupportedStmt &u) {
              return std::format("{}-- unsupported: {}\n", pad, u.reason);
            },
        },
        st.v);
  }

  EmitOptions opts_;
  bool current_fn_uses_mode_ = false;
  std::unordered_set<std::string> declared_muts_;
  int do_tmp_counter_ = 0;
};

// ============================================================================
// High-Level Math IR Dumper (--emit-ir)
// ============================================================================

auto dumpExprIR(const ExprPtr &e, int ind) -> std::string {
  if (!e)
    return indentStr(ind) + "<null>\n";
  auto pad = indentStr(ind);
  return std::visit(
      Overloaded{
          [&](const ConstExpr &c) {
            return std::format("{}Const({} : {})\n", pad, emitConst(c.value, true),
                               emitType(e->type));
          },
          [&](const VarExpr &v) {
            return std::format("{}Var({} : {})\n", pad, v.name, emitType(e->type));
          },
          [&](const TableRefExpr &t) {
            return std::format("{}TableRef({} : {})\n", pad, t.table_name, emitType(e->type));
          },
          [&](const UnaryExpr &u) {
            return std::format("{}Unary({})\n{}", pad, static_cast<int>(u.op),
                               dumpExprIR(u.operand, ind + 1));
          },
          [&](const BinaryExpr &b) {
            return std::format("{}Binary({} : {})\n{}{}", pad, static_cast<int>(b.op),
                               emitType(e->type), dumpExprIR(b.lhs, ind + 1),
                               dumpExprIR(b.rhs, ind + 1));
          },
          [&](const CastExpr &c) {
            return std::format("{}Cast({} -> {})\n{}", pad, static_cast<int>(c.kind),
                               emitType(e->type), dumpExprIR(c.operand, ind + 1));
          },
          [&](const SelectExpr &s) {
            return std::format("{}Select\n{}{}{}", pad, dumpExprIR(s.cond, ind + 1),
                               dumpExprIR(s.then_e, ind + 1), dumpExprIR(s.else_e, ind + 1));
          },
          [&](const IndexExpr &ix) {
            return std::format("{}Index\n{}{}", pad, dumpExprIR(ix.base, ind + 1),
                               dumpExprIR(ix.index, ind + 1));
          },
          [&](const FieldExpr &f) {
            return std::format("{}Field(.{})\n{}", pad, f.field, dumpExprIR(f.base, ind + 1));
          },
          [&](const StructLitExpr &sl) {
            std::string out = std::format("{}StructLit({})\n", pad, sl.type_name);
            for (const auto &[fn, fe] : sl.fields) {
              out += std::format("{}  .{} =\n{}", pad, fn, dumpExprIR(fe, ind + 2));
            }
            return out;
          },
          [&](const StructUpdateExpr &su) {
            return std::format("{}StructUpdate(.{})\n{}{}", pad, su.field,
                               dumpExprIR(su.base, ind + 1), dumpExprIR(su.value, ind + 1));
          },
          [&](const ArrayLitExpr &al) {
            std::string out = std::format("{}ArrayLit\n", pad);
            for (const auto &el : al.elems)
              out += dumpExprIR(el, ind + 1);
            return out;
          },
          [&](const CoreCallExpr &cc) {
            std::string out =
                std::format("{}CoreCall({} : {}, mode={}, cfg={})\n", pad, cc.lean_name,
                            emitType(e->type), cc.needs_mode, cc.needs_config);
            for (const auto &a : cc.args)
              out += dumpExprIR(a, ind + 1);
            return out;
          },
          [&](const PolyevalExpr &pe) {
            auto scheme = pe.scheme == PolyScheme::Estrin
                              ? "Estrin"
                              : (pe.scheme == PolyScheme::AltHorner ? "AltHorner" : "Horner");
            std::string out =
                std::format("{}Polyeval({}, offset={}, array={}, deg={})\n", pad, scheme, pe.offset,
                            pe.array_arg, pe.coeffs.empty() ? 0 : pe.coeffs.size() - 1);
            out += std::format("{}  var:\n{}", pad, dumpExprIR(pe.var, ind + 2));
            for (auto [idx, c] : std::views::enumerate(pe.coeffs)) {
              out += std::format("{}  c[{}]:\n{}", pad, idx, dumpExprIR(c, ind + 2));
            }
            return out;
          },
          [&](const FuncCallExpr &fc) {
            std::string out = std::format("{}FuncCall({} : {}, mode={})\n", pad, fc.callee,
                                          emitType(e->type), fc.needs_mode);
            for (const auto &a : fc.args)
              out += dumpExprIR(a, ind + 1);
            return out;
          },
          [&](const LetExpr &le) {
            return std::format("{}Let({} : {})\n{}{}", pad, le.name, emitType(le.bind_type),
                               dumpExprIR(le.value, ind + 1), dumpExprIR(le.body, ind));
          },
          [&](const LetFuncExpr &lf) {
            return std::format("{}LetFunc({} -> {})\n{}{}", pad, lf.name, emitType(lf.result_type),
                               dumpExprIR(lf.func_body, ind + 1), dumpExprIR(lf.body, ind));
          },
          [&](const LetJoinExpr &lj) {
            return std::format("{}LetJoin({} : {})\n{}{}", pad, lj.name, emitType(lj.result_type),
                               dumpExprIR(lj.join_body, ind + 1), dumpExprIR(lj.body, ind));
          },
          [&](const CallJoinExpr &cj) { return std::format("{}CallJoin({})\n", pad, cj.name); },
          [&](const LetTupleExpr &lt) {
            std::string out = std::format("{}LetTuple\n", pad);
            out += dumpExprIR(lt.value, ind + 1);
            out += dumpExprIR(lt.body, ind);
            return out;
          },
          [&](const TupleExpr &te) {
            std::string out = std::format("{}Tuple\n", pad);
            for (const auto &el : te.elems)
              out += dumpExprIR(el, ind + 1);
            return out;
          },
          [&](const IfExpr &ie) {
            return std::format("{}If\n{}  cond:\n{}{}  then:\n{}{}  else:\n{}", pad, pad,
                               dumpExprIR(ie.cond, ind + 2), pad, dumpExprIR(ie.then_e, ind + 2),
                               pad, dumpExprIR(ie.else_e, ind + 2));
          },
          [&](const MatchExpr &me) {
            std::string out = std::format("{}Match\n{}", pad, dumpExprIR(me.scrutinee, ind + 1));
            for (const auto &arm : me.arms) {
              out += std::format("{}  arm:\n{}", pad, dumpExprIR(arm.body, ind + 2));
            }
            out += std::format("{}  default:\n{}", pad, dumpExprIR(me.default_arm, ind + 2));
            return out;
          },
          [&](const UnsupportedExpr &u) {
            return std::format("{}Unsupported(\"{}\")\n", pad, u.reason);
          },
      },
      e->v);
}

} // namespace

/// Break one generated line that is longer than `kMaxColumns` at a place where Lean does not
/// care about the line break. Three shapes are handled, and any other line is left as it is:
///
/// * a docstring `/-- Extracted from `f` (`mangled`). -/`, broken before the mangled name;
/// * a definition header `def f (a : A) (b : B) : R :=`, broken between binders;
/// * a line whose last bracketed list `[a, b, c]` runs past the limit, broken after commas.
auto wrapLine(std::string_view line) -> std::string {
  if (line.size() <= kMaxColumns)
    return std::string(line);
  std::size_t indent = line.find_first_not_of(' ');
  if (indent == std::string_view::npos)
    return std::string(line);
  std::string_view body = line.substr(indent);

  if (body.starts_with("/-- Extracted from ")) {
    if (auto at = line.find(" (`"); at != std::string_view::npos) {
      return std::string(line.substr(0, at)) + "\n" + std::string(indent, ' ') +
             std::string(line.substr(at + 1));
    }
    return std::string(line);
  }

  // Greedy packing of `pieces` joined by `sep`, continuation lines indented by `cont`.
  auto pack = [](std::string head, const std::vector<std::string> &pieces, std::string_view sep,
                 std::string_view tail, std::size_t cont) {
    std::string out;
    std::string cur = std::move(head);
    for (std::size_t k = 0; k < pieces.size(); ++k) {
      bool last = k + 1 == pieces.size();
      std::string piece = pieces[k] + (last ? std::string(tail) : std::string(sep));
      // A space that ends the piece is trimmed if the line is broken after it.
      std::size_t width = cur.size() + piece.size() - (piece.ends_with(' ') ? 1 : 0);
      if (cur.find_first_not_of(' ') != std::string::npos && width > kMaxColumns) {
        while (!cur.empty() && cur.back() == ' ')
          cur.pop_back();
        out += cur + "\n";
        cur = std::string(cont, ' ');
      }
      cur += piece;
    }
    return out + cur;
  };

  if (body.starts_with("def ")) {
    // Split at the spaces that precede a top-level binder or the result type.
    std::vector<std::string> pieces;
    std::size_t start = 0;
    int depth = 0;
    for (std::size_t k = 0; k < line.size(); ++k) {
      char ch = line[k];
      if (ch == '(' || ch == '[' || ch == '{') {
        if (depth == 0 && k > start && line[k - 1] == ' ') {
          pieces.emplace_back(line.substr(start, k - start));
          start = k;
        }
        ++depth;
      } else if (ch == ')' || ch == ']' || ch == '}') {
        --depth;
      } else if (depth == 0 && ch == ':' && k > start && line[k - 1] == ' ' &&
                 k + 1 < line.size() && line[k + 1] == ' ') {
        // Keep the colon at the end of the binders, as Lean sources are usually written.
        pieces.emplace_back(line.substr(start, k + 2 - start));
        start = k + 2;
      }
    }
    pieces.emplace_back(line.substr(start));
    return pack("", pieces, "", "", indent + 4);
  }

  // The last top-level `[...]` of the line.
  std::size_t close = line.rfind(']');
  if (close == std::string_view::npos)
    return std::string(line);
  int depth = 0;
  std::size_t open = std::string_view::npos;
  for (std::size_t k = close + 1; k-- > 0;) {
    if (line[k] == ']')
      ++depth;
    else if (line[k] == '[' && --depth == 0) {
      open = k;
      break;
    }
  }
  if (open == std::string_view::npos || line.substr(open, close - open).contains('"'))
    return std::string(line);
  std::vector<std::string> pieces;
  std::size_t start = open + 1;
  depth = 0;
  for (std::size_t k = open + 1; k < close; ++k) {
    char ch = line[k];
    if (ch == '(' || ch == '[' || ch == '{')
      ++depth;
    else if (ch == ')' || ch == ']' || ch == '}')
      --depth;
    else if (ch == ',' && depth == 0) {
      pieces.emplace_back(line.substr(start, k - start));
      start = k + 1;
      while (start < close && line[start] == ' ')
        ++start;
    }
  }
  pieces.emplace_back(line.substr(start, close - start));
  if (pieces.size() < 2)
    return std::string(line);
  return pack(std::string(line.substr(0, open + 1)), pieces, ", ", line.substr(close), indent + 4);
}

/// Apply `wrapLine` to every line of the generated module.
auto wrapLongLines(std::string_view text) -> std::string {
  std::string out;
  out.reserve(text.size() + text.size() / 16);
  std::size_t pos = 0;
  while (pos <= text.size()) {
    std::size_t end = text.find('\n', pos);
    bool last = end == std::string_view::npos;
    out += wrapLine(text.substr(pos, last ? std::string_view::npos : end - pos));
    if (last)
      break;
    out += '\n';
    pos = end + 1;
  }
  return out;
}

auto emitLean(const ir::Module &mod, const EmitOptions &opts) -> std::string {
  LeanEmitter emitter(opts);
  return wrapLongLines(emitter.emitModule(mod));
}

auto emitHighLevelIR(const ir::Module &mod) -> std::string {
  std::string out = std::format("Module: {}\n", mod.origin);
  out += formatMathConfig(mod.config);
  for (const auto &t : mod.tables) {
    out += std::format("  Table {} ({}) : {}\n", t.lean_name, t.cpp_name, emitType(t.type));
  }
  for (const auto &fn : mod.functions) {
    out += std::format("  Func {} ({}) -> {} [mode={}]\n", fn.lean_name, fn.cpp_name,
                       emitType(fn.return_type), fn.uses_rounding_mode);
    if (fn.lifted_expr) {
      out += dumpExprIR(*fn.lifted_expr, 2);
    } else {
      out += std::format("    <imperative body: {} top-level stmts>\n", fn.body_stmts.size());
    }
  }
  return out;
}

auto formatMathConfig(const ir::MathConfig &cfg) -> std::string {
  return std::format(
      R"(MathConfig:
  implVariant             = {}
  arch                    = {} (arm_arch={}, big_endian={})
  targetTriple            = {}
  LIBC_MATH_SKIP_ACCURATE = {}
  LIBC_MATH_SMALL_TABLES  = {}
  LIBC_MATH_NO_ERRNO      = {}
  LIBC_MATH_NO_EXCEPT     = {}
  LIBC_MATH_INTERM_FLOAT  = {}
  LIBC_MATH_RN_ONLY       = {}
  CPU_X86_ISA             = sse2={} ssse3={} sse42={} avx={} avx2={} avx512f={}
  CPU_HAS_FMA             = global={} half={} float={} double={}
  CPU_HAS_NEAREST_INT     = {}
  CPU_HAS_FPU             = float={} double={}
  CPU_HAS_ARM_FPU         = float={} double={} neon={}
  CPU_HAS_RISCV_FPU       = float={} double={}
  CPU_HAS_FAST_FLOAT16    = {}
  TYPES_HAS_INT128        = {}
  FP_LOGB_NAN_MIN         = {}
)",
      cfg.impl_variant, cfg.arch, cfg.arm_arch_version, leanBool(cfg.is_big_endian),
      cfg.target_triple, leanBool(cfg.skip_accurate_pass), leanBool(cfg.small_tables),
      leanBool(cfg.no_errno), leanBool(cfg.no_except), leanBool(cfg.intermediate_comp_in_float),
      leanBool(cfg.assume_round_nearest_only), leanBool(cfg.has_sse2), leanBool(cfg.has_ssse3),
      leanBool(cfg.has_sse42), leanBool(cfg.has_avx), leanBool(cfg.has_avx2),
      leanBool(cfg.has_avx512f), leanBool(cfg.has_fma_global), leanBool(cfg.has_fma_half),
      leanBool(cfg.has_fma_float), leanBool(cfg.has_fma_double), leanBool(cfg.has_nearest_int),
      leanBool(cfg.has_fpu_float), leanBool(cfg.has_fpu_double), leanBool(cfg.has_arm_fpu_float),
      leanBool(cfg.has_arm_fpu_double), leanBool(cfg.has_arm_neon),
      leanBool(cfg.has_riscv_fpu_float), leanBool(cfg.has_riscv_fpu_double),
      leanBool(cfg.has_fast_float16), leanBool(cfg.has_int128), leanBool(cfg.fp_logb_nan_min));
}

} // namespace libc_extract
