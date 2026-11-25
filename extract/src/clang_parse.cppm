module;

#include <clang/AST/APValue.h>
#include <clang/AST/ASTConsumer.h>
#include <clang/AST/ASTContext.h>
#include <clang/AST/Decl.h>
#include <clang/AST/DeclCXX.h>
#include <clang/AST/DeclTemplate.h>
#include <clang/AST/Expr.h>
#include <clang/AST/ExprCXX.h>
#include <clang/AST/GlobalDecl.h>
#include <clang/AST/Mangle.h>
#include <clang/AST/RecursiveASTVisitor.h>
#include <clang/AST/Stmt.h>
#include <clang/AST/Type.h>
#include <clang/Basic/Builtins.h>
#include <clang/Basic/TargetInfo.h>
#include <clang/Frontend/CompilerInstance.h>
#include <clang/Frontend/FrontendAction.h>
#include <clang/Lex/Preprocessor.h>
#include <clang/Tooling/CompilationDatabase.h>
#include <clang/Tooling/Tooling.h>
#include <llvm/ADT/APFloat.h>
#include <llvm/ADT/APInt.h>
#include <llvm/ADT/SmallString.h>
#include <llvm/ADT/StringExtras.h>
#include <llvm/Support/raw_ostream.h>

#include <algorithm>
#include <cctype>
#include <cstdint>
#include <expected>
#include <format>
#include <functional>
#include <memory>
#include <optional>
#include <ranges>
#include <string>
#include <string_view>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>

export module libc_extract.clang_parse;

import libc_extract.core_ops;
import libc_extract.ir;

export namespace libc_extract {

struct ParseOptions {
  std::string source_file;
  std::string source_label;            // Optional display path for KernelMeta.sourceFile.
  std::string source_commit;           // Optional upstream commit hash for KernelMeta.
  std::string target_function;         // Qualified name, suffix, or mangled name.
  std::string lean_name;               // Optional override for Lean def name.
  std::string impl_variant;            // Optional override for MathConfig.implVariant.
  std::string resource_dir;            // Empty => auto-detected compile-time Clang resource dir.
  std::vector<std::string> clang_args; // Extra Clang flags (-I, -D, -std=..., etc.).
  bool follow_helpers = false;         // Recursively extract non-CoreOp callees in same TU.
  bool unwrap_forwarding = true;       // Follow 1-line `return f(args...);` entrypoint wrappers.
  bool strict = false;                 // Fail on unsupported AST constructs.
};

struct FunctionListing {
  std::string qualified_name;
  std::string mangled_name;
  std::string signature;
  bool is_template_instantiation = false;
};

/// Parse a C++ source file with Clang LibTooling and extract the target function
/// (plus any referenced constexpr tables, captured MathConfig, and optionally called helpers).
auto parseTranslationUnit(const ParseOptions &opts) -> std::expected<ir::Module, std::string>;

/// List all defined functions (including instantiated templates) in a translation unit.
auto listFunctions(const ParseOptions &opts)
    -> std::expected<std::vector<FunctionListing>, std::string>;

/// Parse the translation unit only far enough to snapshot the resolved LLVM libc MathConfig.
auto inspectMathConfig(const ParseOptions &opts) -> std::expected<ir::MathConfig, std::string>;

} // namespace libc_extract

module : private;

namespace libc_extract {
namespace {

using namespace clang;

auto apIntToUpperHex(const llvm::APInt &val) -> std::string {
  llvm::SmallString<64> buf;
  val.toStringUnsigned(buf, 16);
  std::string out(buf.str());
  std::ranges::transform(out, out.begin(),
                         [](unsigned char c) { return static_cast<char>(std::toupper(c)); });
  return out.empty() ? "0" : out;
}

auto apFloatRepr(const llvm::APFloat &val) -> std::string {
  llvm::SmallString<64> buf;
  val.toString(buf, 0, 0);
  return std::string(buf.str());
}

auto mangleDecl(ASTContext &ctx, const NamedDecl *decl) -> std::string {
  std::unique_ptr<MangleContext> mc(ctx.createMangleContext());
  if (!mc || !mc->shouldMangleDeclName(decl)) {
    return decl->getNameAsString();
  }
  std::string out;
  llvm::raw_string_ostream os(out);
  if (const auto *ctor = dyn_cast<CXXConstructorDecl>(decl)) {
    mc->mangleName(GlobalDecl(ctor, Ctor_Complete), os);
  } else if (const auto *dtor = dyn_cast<CXXDestructorDecl>(decl)) {
    mc->mangleName(GlobalDecl(dtor, Dtor_Complete), os);
  } else {
    mc->mangleName(GlobalDecl(decl), os);
  }
  return out;
}

auto sanitizeLeanIdent(std::string_view raw) -> std::string {
  std::string out;
  out.reserve(raw.size());
  for (char c : raw) {
    if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_') {
      out.push_back(c);
    } else if (c == ':' && (out.empty() || out.back() != '_')) {
      out.push_back('_');
    }
  }
  if (out.empty())
    out = "unnamed";
  if (out.front() >= '0' && out.front() <= '9')
    out.insert(out.begin(), '_');
  return out;
}

auto shortLeanName(std::string_view normalized) -> std::string {
  if (auto pos = normalized.rfind("::"); pos != std::string_view::npos) {
    return sanitizeLeanIdent(normalized.substr(pos + 2));
  }
  return sanitizeLeanIdent(normalized);
}

auto inferImplVariant(std::string_view cpp_name) -> std::string {
  constexpr std::array<std::string_view, 5> kKnown = {
      "double_eval", "float_eval_cr_rn", "float_eval", "integer_eval", "static_rounding"};
  for (auto v : kKnown) {
    if (cpp_name.find(v) != std::string_view::npos) {
      return std::string(v);
    }
  }
  return "default";
}

auto captureMathConfig(CompilerInstance &ci) -> ir::MathConfig {
  Preprocessor &pp = ci.getPreprocessor();
  auto hasMacro = [&](llvm::StringRef name) -> bool { return pp.isMacroDefined(name); };
  auto macroInt = [&](llvm::StringRef name) -> std::optional<std::uint32_t> {
    if (!pp.isMacroDefined(name))
      return std::nullopt;
    const MacroInfo *mi = pp.getMacroInfo(pp.getIdentifierInfo(name));
    if (!mi || mi->getNumTokens() == 0)
      return std::nullopt;
    std::string sp = pp.getSpelling(mi->getReplacementToken(0));
    try {
      return static_cast<std::uint32_t>(std::stoul(sp, nullptr, 0));
    } catch (...) {
      return std::nullopt;
    }
  };

  ir::MathConfig cfg;
  const auto &triple = ci.getTarget().getTriple();
  if (hasMacro("LIBC_TARGET_ARCH_IS_X86_64") || triple.isX86_64()) {
    cfg.arch = "x86_64";
  } else if (hasMacro("LIBC_TARGET_ARCH_IS_X86_32") || triple.isX86_32()) {
    cfg.arch = "x86_32";
  } else if (hasMacro("LIBC_TARGET_ARCH_IS_AARCH64") || triple.isAArch64()) {
    cfg.arch = "aarch64";
  } else if (hasMacro("LIBC_TARGET_ARCH_IS_ARM") || triple.isARM() || triple.isThumb()) {
    cfg.arch = "arm";
  } else if (hasMacro("LIBC_TARGET_ARCH_IS_RISCV64") || triple.isRISCV64()) {
    cfg.arch = "riscv64";
  } else if (hasMacro("LIBC_TARGET_ARCH_IS_RISCV32") || triple.isRISCV32()) {
    cfg.arch = "riscv32";
  } else if (hasMacro("LIBC_TARGET_ARCH_IS_GPU") || triple.isNVPTX() || triple.isAMDGPU() ||
             triple.isSPIRV()) {
    cfg.arch = "gpu";
  } else if (hasMacro("LIBC_TARGET_ARCH_IS_WASM") || triple.isWasm()) {
    cfg.arch = "wasm";
  } else {
    cfg.arch = "other";
  }
  cfg.arm_arch_version = macroInt("__ARM_ARCH").value_or(0);
  cfg.is_big_endian = hasMacro("LIBC_TARGET_IS_BIG_ENDIAN") || ci.getTarget().isBigEndian();
  cfg.skip_accurate_pass = hasMacro("LIBC_MATH_HAS_SKIP_ACCURATE_PASS");
  cfg.small_tables = hasMacro("LIBC_MATH_HAS_SMALL_TABLES");
  cfg.no_errno = hasMacro("LIBC_MATH_HAS_NO_ERRNO");
  cfg.no_except = hasMacro("LIBC_MATH_HAS_NO_EXCEPT");
  cfg.intermediate_comp_in_float = hasMacro("LIBC_MATH_HAS_INTERMEDIATE_COMP_IN_FLOAT");
  cfg.assume_round_nearest_only = hasMacro("LIBC_MATH_HAS_ASSUME_ROUND_NEAREST_ONLY");
  cfg.has_sse2 = hasMacro("LIBC_TARGET_CPU_HAS_SSE2") || hasMacro("__SSE2__");
  cfg.has_ssse3 = hasMacro("__SSSE3__");
  cfg.has_sse42 = hasMacro("LIBC_TARGET_CPU_HAS_SSE4_2") || hasMacro("__SSE4_2__");
  cfg.has_avx = hasMacro("LIBC_TARGET_CPU_HAS_AVX") || hasMacro("__AVX__");
  cfg.has_avx2 = hasMacro("LIBC_TARGET_CPU_HAS_AVX2") || hasMacro("__AVX2__");
  cfg.has_avx512f = hasMacro("LIBC_TARGET_CPU_HAS_AVX512F") || hasMacro("__AVX512F__");
  cfg.has_fma_global = hasMacro("LIBC_TARGET_CPU_HAS_FMA");
  cfg.has_fma_half = hasMacro("LIBC_TARGET_CPU_HAS_FMA_HALF");
  cfg.has_fma_float = hasMacro("LIBC_TARGET_CPU_HAS_FMA_FLOAT");
  cfg.has_fma_double = hasMacro("LIBC_TARGET_CPU_HAS_FMA_DOUBLE");
  cfg.has_nearest_int = hasMacro("LIBC_TARGET_CPU_HAS_NEAREST_INT");
  cfg.has_fpu_float = hasMacro("LIBC_TARGET_CPU_HAS_FPU_FLOAT");
  cfg.has_fpu_double = hasMacro("LIBC_TARGET_CPU_HAS_FPU_DOUBLE");
  cfg.has_arm_fpu_float = hasMacro("LIBC_TARGET_CPU_HAS_ARM_FPU_FLOAT");
  cfg.has_arm_fpu_double = hasMacro("LIBC_TARGET_CPU_HAS_ARM_FPU_DOUBLE");
  cfg.has_arm_neon = hasMacro("LIBC_TARGET_CPU_HAS_ARM_NEON");
  cfg.has_riscv_fpu_float = hasMacro("LIBC_TARGET_CPU_HAS_RISCV_FPU_FLOAT");
  cfg.has_riscv_fpu_double = hasMacro("LIBC_TARGET_CPU_HAS_RISCV_FPU_DOUBLE");
  cfg.has_fast_float16 = hasMacro("LIBC_TARGET_CPU_HAS_FAST_FLOAT16_OPS");
  cfg.has_int128 = hasMacro("LIBC_TYPES_HAS_INT128");
  cfg.fp_logb_nan_min = !hasMacro("FP_ILOGBNAN") || hasMacro("__FP_LOGBNAN_MIN") ||
                        triple.isOSLinux();
  cfg.target_triple = triple.str();
  return cfg;
}

auto floatFmtFromQualType(QualType qt, ASTContext &ctx) -> std::optional<FloatFmt> {
  qt = qt.getNonReferenceType().getCanonicalType().getUnqualifiedType();
  if (const auto *bt = qt->getAs<BuiltinType>()) {
    switch (bt->getKind()) {
    case BuiltinType::Half:
    case BuiltinType::Float16:
      return FloatFmt::Binary16;
    case BuiltinType::Float:
      return FloatFmt::Binary32;
    case BuiltinType::Double:
      return FloatFmt::Binary64;
    case BuiltinType::Float128:
      return FloatFmt::Binary128;
    default:
      break;
    }
  }
  if (qt->isFloatingType()) {
    switch (ctx.getTypeSize(qt)) {
    case 16:
      return FloatFmt::Binary16;
    case 32:
      return FloatFmt::Binary32;
    case 64:
      return FloatFmt::Binary64;
    case 128:
      return FloatFmt::Binary128;
    default:
      break;
    }
  }
  return std::nullopt;
}

auto getTemplateFirstFloatArg(const ClassTemplateSpecializationDecl *spec, ASTContext &ctx)
    -> FloatFmt {
  if (!spec)
    return FloatFmt::Binary32;
  const auto &args = spec->getTemplateArgs();
  for (unsigned i = 0; i < args.size(); ++i) {
    if (args[i].getKind() == TemplateArgument::Type) {
      if (auto fmt = floatFmtFromQualType(args[i].getAsType(), ctx)) {
        return *fmt;
      }
    }
  }
  return FloatFmt::Binary32;
}

auto getTemplateFirstIntegralArg(const ClassTemplateSpecializationDecl *spec,
                                 std::uint64_t fallback) -> std::uint64_t {
  if (!spec)
    return fallback;
  const auto &args = spec->getTemplateArgs();
  for (unsigned i = 0; i < args.size(); ++i) {
    if (args[i].getKind() == TemplateArgument::Integral) {
      return args[i].getAsIntegral().getZExtValue();
    }
  }
  return fallback;
}

auto getFuncTemplateFirstIntegralOpt(const FunctionDecl *fd) -> std::optional<std::uint64_t> {
  if (!fd)
    return std::nullopt;
  const TemplateArgumentList *targs = fd->getTemplateSpecializationArgs();
  if (!targs)
    return std::nullopt;
  for (unsigned i = 0; i < targs->size(); ++i) {
    if ((*targs)[i].getKind() == TemplateArgument::Integral) {
      return (*targs)[i].getAsIntegral().getZExtValue();
    }
  }
  return std::nullopt;
}

auto getFuncTemplateFirstIntegralArg(const FunctionDecl *fd, std::uint64_t fallback)
    -> std::uint64_t {
  return getFuncTemplateFirstIntegralOpt(fd).value_or(fallback);
}

auto unwrapExprSugar(const Expr *e) -> const Expr * {
  while (e) {
    if (const auto *p = dyn_cast<ParenExpr>(e)) {
      e = p->getSubExpr();
    } else if (const auto *c = dyn_cast<ExprWithCleanups>(e)) {
      e = c->getSubExpr();
    } else if (const auto *m = dyn_cast<MaterializeTemporaryExpr>(e)) {
      e = m->getSubExpr();
    } else if (const auto *b = dyn_cast<CXXBindTemporaryExpr>(e)) {
      e = b->getSubExpr();
    } else if (const auto *ce = dyn_cast<ConstantExpr>(e)) {
      e = ce->getSubExpr();
    } else if (const auto *dae = dyn_cast<CXXDefaultArgExpr>(e)) {
      e = dae->getExpr();
    } else if (const auto *ic = dyn_cast<ImplicitCastExpr>(e)) {
      auto ck = ic->getCastKind();
      if (ck == CK_LValueToRValue || ck == CK_NoOp || ck == CK_FunctionToPointerDecay ||
          ck == CK_ArrayToPointerDecay || ck == CK_DerivedToBase ||
          ck == CK_UncheckedDerivedToBase) {
        e = ic->getSubExpr();
      } else {
        break;
      }
    } else {
      break;
    }
  }
  return e;
}

class AstExtractor {
public:
  AstExtractor(ASTContext &ctx, const ParseOptions &opts) : ctx_(ctx), opts_(opts) {}

  auto convertType(QualType qt) -> ir::TypePtr {
    qt = qt.getNonReferenceType().getCanonicalType().getUnqualifiedType();
    if (qt->isVoidType())
      return ir::Type::makeVoid();
    if (qt->isBooleanType())
      return ir::Type::makeBool();
    if (auto fmt = floatFmtFromQualType(qt, ctx_)) {
      return ir::Type::makeFloat(*fmt);
    }
    if (qt->isIntegerType()) {
      auto bits = static_cast<std::uint32_t>(ctx_.getTypeSize(qt));
      return ir::Type::makeInt(bits, qt->isSignedIntegerType());
    }
    if (const auto *cat = ctx_.getAsConstantArrayType(qt)) {
      return ir::Type::makeArray(convertType(cat->getElementType()), cat->getSize().getZExtValue());
    }
    if (const auto *pt = qt->getAs<PointerType>()) {
      return ir::Type::makePtr(convertType(pt->getPointeeType()));
    }
    if (const auto *rt = qt->getAs<RecordType>()) {
      const RecordDecl *rd = rt->getDecl();
      auto qname = rd->getQualifiedNameAsString();
      const auto *spec = dyn_cast<ClassTemplateSpecializationDecl>(rd);

      if (auto core = matchCoreType(qname)) {
        switch (*core) {
        case CoreTypeKind::FPBits:
          return ir::Type::makeFPBits(getTemplateFirstFloatArg(spec, ctx_));
        case CoreTypeKind::NormalFloat:
          return ir::Type::makeNormalFloat(getTemplateFirstFloatArg(spec, ctx_));
        case CoreTypeKind::DyadicFloat:
          return ir::Type::makeDyadic(
              static_cast<std::uint32_t>(getTemplateFirstIntegralArg(spec, 128)));
        case CoreTypeKind::NumberPair:
          return ir::Type::makeNumberPair(getTemplateFirstFloatArg(spec, ctx_));
        case CoreTypeKind::TripleDouble:
          return ir::Type::makeTripleDouble();
        case CoreTypeKind::Frac64:
          return ir::Type::makeFrac64();
        case CoreTypeKind::ExceptValues:
          return ir::Type::makeExceptValues(getTemplateFirstFloatArg(spec, ctx_),
                                            getTemplateFirstIntegralArg(spec, 0));
        case CoreTypeKind::Sign:
          return ir::Type::makeSign();
        case CoreTypeKind::Optional:
          if (spec && spec->getTemplateArgs().size() >= 1 &&
              spec->getTemplateArgs()[0].getKind() == TemplateArgument::Type) {
            return ir::Type::makeOptional(convertType(spec->getTemplateArgs()[0].getAsType()));
          }
          return ir::Type::makeOptional(ir::Type::makeOpaque("T"));
        case CoreTypeKind::Array:
          if (spec && spec->getTemplateArgs().size() >= 2 &&
              spec->getTemplateArgs()[0].getKind() == TemplateArgument::Type &&
              spec->getTemplateArgs()[1].getKind() == TemplateArgument::Integral) {
            return ir::Type::makeArray(convertType(spec->getTemplateArgs()[0].getAsType()),
                                       spec->getTemplateArgs()[1].getAsIntegral().getZExtValue());
          }
          break;
        case CoreTypeKind::BigInt: {
          auto bits = static_cast<std::uint32_t>(getTemplateFirstIntegralArg(spec, 128));
          auto norm = normalizeQualifiedName(qname);
          bool is_signed = matchesQualifiedSuffix(norm, "BigInt");
          return ir::Type::makeInt(bits, is_signed);
        }
        }
      }

      auto norm = normalizeQualifiedName(qname);
      std::string sname = registerStruct(rd);
      return ir::Type::makeStruct(std::move(sname));
    }
    return ir::Type::makeOpaque(qt.getAsString());
  }

  static auto isOutParam(const ParmVarDecl *p) -> bool {
    QualType qt = p->getType().getCanonicalType();
    if (const auto *lv = qt->getAs<LValueReferenceType>()) {
      return !lv->getPointeeType().isConstQualified();
    }
    if (const auto *pt = qt->getAs<PointerType>()) {
      return !pt->getPointeeType().isConstQualified() && !pt->getPointeeType()->isVoidType();
    }
    return false;
  }

  static auto isExceptValuesType(QualType qt) -> bool {
    qt = qt.getNonReferenceType().getCanonicalType().getUnqualifiedType();
    if (const auto *rt = qt->getAs<RecordType>()) {
      return matchCoreType(rt->getDecl()->getQualifiedNameAsString()) == CoreTypeKind::ExceptValues;
    }
    return false;
  }

  auto registerStruct(const RecordDecl *rd) -> std::string {
    rd = cast<RecordDecl>(rd->getCanonicalDecl());
    if (auto it = structs_seen_.find(rd); it != structs_seen_.end()) {
      return it->second;
    }
    auto cpp_name = normalizeQualifiedName(rd->getQualifiedNameAsString());
    auto base = shortLeanName(cpp_name);
    if (used_struct_names_.contains(base)) {
      base = sanitizeLeanIdent(cpp_name);
    }
    std::string lean_name = base;
    int suffix = 2;
    while (used_struct_names_.contains(lean_name)) {
      lean_name = std::format("{}_{}", base, suffix++);
    }
    used_struct_names_.insert(lean_name);
    structs_seen_[rd] = lean_name;

    if (const auto *cxx = dyn_cast<CXXRecordDecl>(rd); cxx && cxx->isLambda()) {
      return lean_name;
    }

    const RecordDecl *def = rd->getDefinition();
    if (!def) {
      return lean_name;
    }
    ir::StructDef sdef;
    sdef.lean_name = lean_name;
    sdef.cpp_name = cpp_name;
    if (const auto *cxx = dyn_cast<CXXRecordDecl>(def)) {
      for (const auto &bs : cxx->bases()) {
        if (const auto *brt = bs.getType()->getAs<RecordType>()) {
          if (const RecordDecl *bdef = brt->getDecl()->getDefinition()) {
            for (const FieldDecl *fd : bdef->fields()) {
              sdef.fields.push_back(ir::StructField{fd->getNameAsString(),
                                                    convertType(fd->getType())});
            }
          }
        }
      }
    }
    for (const FieldDecl *fd : def->fields()) {
      sdef.fields.push_back(ir::StructField{fd->getNameAsString(), convertType(fd->getType())});
    }
    if (!sdef.fields.empty()) {
      module_.structs.push_back(std::move(sdef));
    }
    return lean_name;
  }

  auto convertAPValue(const APValue &val, QualType qt) -> std::optional<ir::ConstVal> {
    qt = qt.getNonReferenceType().getCanonicalType().getUnqualifiedType();

    if (val.isInt()) {
      const llvm::APSInt &i = val.getInt();
      if (qt->isBooleanType()) {
        return ir::ConstVal{ir::BoolConst{i.getBoolValue()}};
      }
      auto w = static_cast<std::uint32_t>(i.getBitWidth());
      bool is_signed = i.isSigned();
      bool fits = i.getSignificantBits() <= 64;
      std::int64_t sval = fits ? i.getExtValue() : 0;
      return ir::ConstVal{ir::IntConst{w, is_signed, apIntToUpperHex(i), sval, fits}};
    }

    if (val.isFloat()) {
      auto fmt = floatFmtFromQualType(qt, ctx_).value_or(FloatFmt::Binary64);
      const llvm::APFloat &f = val.getFloat();
      llvm::APInt bits = f.bitcastToAPInt();
      std::uint64_t raw = bits.getBitWidth() <= 64 ? bits.getZExtValue() : 0;
      return ir::ConstVal{ir::FloatConst{fmt, raw, apFloatRepr(f)}};
    }

    if (val.isArray()) {
      const auto *cat = ctx_.getAsConstantArrayType(qt);
      QualType elem_qt = cat ? cat->getElementType() : QualType{};
      ir::ArrayConst arr;
      arr.elem_type = elem_qt.isNull() ? ir::Type::makeOpaque("elem") : convertType(elem_qt);
      unsigned n = val.getArraySize();
      arr.elems.reserve(n);
      for (unsigned i = 0; i < n; ++i) {
        const APValue &elem = i < val.getArrayInitializedElts() ? val.getArrayInitializedElt(i)
                                                                : val.getArrayFiller();
        if (auto c = convertAPValue(elem, elem_qt)) {
          arr.elems.push_back(std::move(*c));
        } else {
          return std::nullopt;
        }
      }
      return ir::ConstVal{std::move(arr)};
    }

    if (val.isStruct()) {
      const auto *rt = qt->getAs<RecordType>();
      if (!rt)
        return std::nullopt;
      const RecordDecl *rd = rt->getDecl();
      auto qname = rd->getQualifiedNameAsString();
      auto norm = normalizeQualifiedName(qname);
      auto core = matchCoreType(qname);

      if (core == CoreTypeKind::Array && val.getStructNumFields() == 1) {
        auto it = rd->field_begin();
        if (it != rd->field_end()) {
          return convertAPValue(val.getStructField(0), it->getType());
        }
      }

      if (core == CoreTypeKind::Frac64) {
        // Frac64 inherits publicly from UInt<64>.
        if (val.getStructNumBases() >= 1) {
          if (auto limbs = extractUIntLimbsHex(val.getStructBase(0))) {
            return ir::ConstVal{ir::Frac64Const{*limbs}};
          }
        }
        if (auto limbs = extractUIntLimbsHex(val)) {
          return ir::ConstVal{ir::Frac64Const{*limbs}};
        }
      }

      if (core == CoreTypeKind::ExceptValues && val.getStructNumFields() == 1) {
        auto it = rd->field_begin();
        if (it != rd->field_end()) {
          const APValue &arr_val = val.getStructField(0);
          if (arr_val.isArray()) {
            const auto *cat = ctx_.getAsConstantArrayType(it->getType().getCanonicalType());
            QualType elem_qt = cat ? cat->getElementType() : QualType{};
            ir::ArrayConst arr;
            arr.elem_type = ir::Type::makeOpaque("ExceptMapping");
            unsigned n = arr_val.getArraySize();
            arr.elems.reserve(n);
            constexpr std::array<std::string_view, 5> kMappingFields = {
                "input", "rndTowardZero", "rndUpwardOffset", "rndDownwardOffset",
                "rndToNearestOffset"};
            for (unsigned i = 0; i < n; ++i) {
              const APValue &elt = i < arr_val.getArrayInitializedElts()
                                       ? arr_val.getArrayInitializedElt(i)
                                       : arr_val.getArrayFiller();
              if (!elt.isStruct() || elt.getStructNumFields() < 5)
                return std::nullopt;
              const auto *mrt = elem_qt.isNull() ? nullptr : elem_qt->getAs<RecordType>();
              const RecordDecl *mrd = mrt ? mrt->getDecl() : nullptr;
              ir::StructConst sc;
              sc.type_name = "Libc.ExceptMapping";
              unsigned fi = 0;
              if (mrd) {
                for (const FieldDecl *mfd : mrd->fields()) {
                  if (fi >= 5)
                    break;
                  auto c = convertAPValue(elt.getStructField(fi), mfd->getType());
                  if (!c)
                    return std::nullopt;
                  sc.fields.emplace_back(std::string(kMappingFields[fi]), std::move(*c));
                  ++fi;
                }
              } else {
                for (; fi < 5; ++fi) {
                  auto c = convertAPValue(elt.getStructField(fi), QualType{});
                  if (!c)
                    return std::nullopt;
                  sc.fields.emplace_back(std::string(kMappingFields[fi]), std::move(*c));
                }
              }
              arr.elems.push_back(ir::ConstVal{std::move(sc)});
            }
            return ir::ConstVal{std::move(arr)};
          }
        }
      }

      if (core == CoreTypeKind::BigInt || matchesQualifiedSuffix(norm, "UInt") ||
          matchesQualifiedSuffix(norm, "BigInt")) {
        if (auto limbs = extractUIntLimbsHex(val)) {
          const auto *spec = dyn_cast<ClassTemplateSpecializationDecl>(rd);
          auto bits = static_cast<std::uint32_t>(getTemplateFirstIntegralArg(spec, 128));
          bool is_signed = matchesQualifiedSuffix(norm, "BigInt");
          return ir::ConstVal{ir::IntConst{bits, is_signed, *limbs, 0, false}};
        }
      }

      if (core == CoreTypeKind::Sign && val.getStructNumFields() >= 1) {
        const APValue &f0 = val.getStructField(0);
        if (f0.isInt()) {
          return ir::ConstVal{ir::SignConst{f0.getInt().getBoolValue()}};
        }
      }

      if (core == CoreTypeKind::DyadicFloat) {
        const auto *spec = dyn_cast<ClassTemplateSpecializationDecl>(rd);
        ir::DyadicConst dc;
        dc.bits = static_cast<std::uint32_t>(getTemplateFirstIntegralArg(spec, 128));
        unsigned idx = 0;
        for (const FieldDecl *fd : rd->fields()) {
          if (idx >= val.getStructNumFields())
            break;
          const APValue &fv = val.getStructField(idx++);
          auto fname = fd->getName();
          if (fname == "sign") {
            if (fv.isInt())
              dc.sign_neg = fv.getInt().getBoolValue();
            else if (fv.isStruct() && fv.getStructNumFields() >= 1 && fv.getStructField(0).isInt())
              dc.sign_neg = fv.getStructField(0).getInt().getBoolValue();
          } else if (fname == "exponent") {
            if (fv.isInt())
              dc.exponent = fv.getInt().getExtValue();
          } else if (fname == "mantissa") {
            if (fv.isInt()) {
              dc.mantissa_hex = apIntToUpperHex(fv.getInt());
            } else if (auto c = convertAPValue(fv, fd->getType())) {
              if (const auto *ic = std::get_if<ir::IntConst>(&c->v)) {
                dc.mantissa_hex = ic->hex_bits;
              }
            }
          }
        }
        if (dc.mantissa_hex.empty())
          dc.mantissa_hex = "0";
        return ir::ConstVal{std::move(dc)};
      }

      if (core == CoreTypeKind::NumberPair) {
        const auto *spec = dyn_cast<ClassTemplateSpecializationDecl>(rd);
        ir::NumberPairConst np;
        np.fmt = getTemplateFirstFloatArg(spec, ctx_);
        unsigned idx = 0;
        for (const FieldDecl *fd : rd->fields()) {
          if (idx >= val.getStructNumFields())
            break;
          const APValue &fv = val.getStructField(idx++);
          if (fv.isFloat()) {
            auto raw = fv.getFloat().bitcastToAPInt().getZExtValue();
            if (fd->getName() == "hi")
              np.hi_bits = raw;
            else if (fd->getName() == "lo")
              np.lo_bits = raw;
          }
        }
        return ir::ConstVal{np};
      }

      ir::StructConst sc;
      sc.type_name = shortLeanName(norm);
      unsigned idx = 0;
      for (const FieldDecl *fd : rd->fields()) {
        if (idx >= val.getStructNumFields())
          break;
        if (auto c = convertAPValue(val.getStructField(idx++), fd->getType())) {
          sc.fields.emplace_back(fd->getNameAsString(), std::move(*c));
        } else {
          return std::nullopt;
        }
      }
      return ir::ConstVal{std::move(sc)};
    }

    return std::nullopt;
  }

  auto registerTable(const VarDecl *vd) -> std::optional<std::string> {
    if (auto it = tables_seen_.find(vd); it != tables_seen_.end()) {
      return it->second;
    }
    auto cpp_name = normalizeQualifiedName(vd->getQualifiedNameAsString());
    if (matchesQualifiedSuffix(cpp_name, "nullopt")) {
      return std::nullopt;
    }
    if (const auto *rd = vd->getType().getCanonicalType()->getAsRecordDecl()) {
      if (const RecordDecl *def = rd->getDefinition()) {
        bool has_fields = !def->field_empty();
        if (!has_fields) {
          if (const auto *cxx = dyn_cast<CXXRecordDecl>(def)) {
            for (const auto &bs : cxx->bases()) {
              if (const auto *brt = bs.getType()->getAs<RecordType>()) {
                if (const RecordDecl *bdef = brt->getDecl()->getDefinition();
                    bdef && !bdef->field_empty()) {
                  has_fields = true;
                  break;
                }
              }
            }
          }
        }
        if (!has_fields && !matchCoreType(rd->getQualifiedNameAsString())) {
          return std::nullopt;
        }
      }
    }
    const APValue *apv = vd->evaluateValue();
    if (!apv)
      return std::nullopt;
    auto cval = convertAPValue(*apv, vd->getType());
    if (!cval)
      return std::nullopt;

    auto base_name = sanitizeLeanIdent(vd->getNameAsString());
    if (used_table_names_.contains(base_name)) {
      base_name = sanitizeLeanIdent(cpp_name);
    }
    std::string lean_name = base_name;
    int suffix = 2;
    while (used_table_names_.contains(lean_name)) {
      lean_name = std::format("{}_{}", base_name, suffix++);
    }
    used_table_names_.insert(lean_name);
    tables_seen_[vd] = lean_name;

    module_.tables.push_back(ir::Table{
        .lean_name = lean_name,
        .cpp_name = cpp_name,
        .type = convertType(vd->getType()),
        .value = std::move(*cval),
    });
    return lean_name;
  }

  auto assignFuncLeanName(const FunctionDecl *fd, std::string_view override_name = "")
      -> std::string {
    if (auto it = func_lean_names_.find(fd); it != func_lean_names_.end()) {
      return it->second;
    }
    auto cpp_name = normalizeQualifiedName(fd->getQualifiedNameAsString());
    std::string candidate =
        !override_name.empty() ? std::string(override_name) : shortLeanName(cpp_name);
    if (used_func_names_.contains(candidate)) {
      candidate = sanitizeLeanIdent(cpp_name);
    }
    int suffix = 2;
    std::string unique = candidate;
    while (used_func_names_.contains(unique)) {
      unique = std::format("{}_{}", candidate, suffix++);
    }
    used_func_names_.insert(unique);
    func_lean_names_[fd] = unique;
    return unique;
  }

  auto computeEffectiveReturnType(const FunctionDecl *fd) -> ir::TypePtr {
    auto orig = convertType(fd->getReturnType());
    std::vector<ir::TypePtr> elems;
    if (!orig->isVoid()) {
      elems.push_back(orig);
    }
    for (const ParmVarDecl *p : fd->parameters()) {
      if (isOutParam(p)) {
        QualType pqt = p->getType().getCanonicalType();
        if (const auto *pt = pqt->getAs<PointerType>())
          pqt = pt->getPointeeType();
        elems.push_back(convertType(pqt));
      }
    }
    if (elems.empty())
      return orig;
    if (elems.size() == 1)
      return elems[0];
    return ir::Type::makeTuple(std::move(elems));
  }

  static auto exprMentionsDecl(const Stmt *s, const ValueDecl *target) -> bool {
    if (!s)
      return false;
    if (const auto *dre = dyn_cast<DeclRefExpr>(s)) {
      return dre->getDecl() == target;
    }
    for (const Stmt *child : s->children()) {
      if (exprMentionsDecl(child, target))
        return true;
    }
    return false;
  }

  // Returns +1 if `p` is unconditionally written before any read, -1 if read before write,
  // and 0 if `p` is neither read nor definitely written on all paths.
  auto checkParamAccess(const Stmt *s, const ParmVarDecl *p,
                        std::unordered_set<const FunctionDecl *> &visiting) -> int {
    if (!s)
      return 0;
    if (const auto *cs = dyn_cast<CompoundStmt>(s)) {
      for (const Stmt *sub : cs->body()) {
        int r = checkParamAccess(sub, p, visiting);
        if (r != 0)
          return r;
      }
      return 0;
    }
    if (const auto *e = dyn_cast<Expr>(s)) {
      const Expr *u = unwrapExprSugar(e);
      if (const auto *bo = dyn_cast_or_null<BinaryOperator>(u);
          bo && bo->getOpcode() == BO_Assign) {
        const Expr *lhs = unwrapExprSugar(bo->getLHS());
        if (const auto *uo = dyn_cast_or_null<UnaryOperator>(lhs);
            uo && uo->getOpcode() == UO_Deref) {
          lhs = unwrapExprSugar(uo->getSubExpr());
        }
        if (const auto *dre = dyn_cast_or_null<DeclRefExpr>(lhs); dre && dre->getDecl() == p) {
          return exprMentionsDecl(bo->getRHS(), p) ? -1 : 1;
        }
      }
      if (const auto *oce = dyn_cast_or_null<CXXOperatorCallExpr>(u);
          oce && oce->getOperator() == OO_Equal && oce->getNumArgs() == 2) {
        const Expr *lhs = unwrapExprSugar(oce->getArg(0));
        if (const auto *uo = dyn_cast_or_null<UnaryOperator>(lhs);
            uo && uo->getOpcode() == UO_Deref) {
          lhs = unwrapExprSugar(uo->getSubExpr());
        }
        if (const auto *dre = dyn_cast_or_null<DeclRefExpr>(lhs); dre && dre->getDecl() == p) {
          return exprMentionsDecl(oce->getArg(1), p) ? -1 : 1;
        }
      }
      if (const auto *call = dyn_cast_or_null<CallExpr>(unwrapTransparentAndCasts(u));
          call && !isa<CXXMemberCallExpr>(call) && !isa<CXXOperatorCallExpr>(call)) {
        if (const FunctionDecl *callee = call->getDirectCallee();
            callee && !matchFreeCoreOp(callee->getQualifiedNameAsString())) {
          bool written = false;
          for (unsigned i = 0; i < call->getNumArgs() && i < callee->getNumParams(); ++i) {
            if (!exprMentionsDecl(call->getArg(i), p))
              continue;
            const ParmVarDecl *cp = callee->getParamDecl(i);
            auto tname = extractOutTargetName(call->getArg(i));
            if (isOutParam(cp) && tname && *tname == p->getNameAsString() &&
                !isInOutParamImpl(callee, cp, visiting)) {
              written = true;
            } else {
              return -1;
            }
          }
          return written ? 1 : 0;
        }
      }
      return exprMentionsDecl(e, p) ? -1 : 0;
    }
    if (const auto *rs = dyn_cast<ReturnStmt>(s)) {
      if (const Expr *re = rs->getRetValue())
        return checkParamAccess(re, p, visiting);
      return 0;
    }
    if (const auto *ifs = dyn_cast<clang::IfStmt>(s)) {
      if (ifs->isConstexpr()) {
        if (auto active = ifs->getNondiscardedCase(ctx_); active && *active)
          return checkParamAccess(*active, p, visiting);
        return 0;
      }
      if (exprMentionsDecl(ifs->getCond(), p))
        return -1;
      int rt = checkParamAccess(ifs->getThen(), p, visiting);
      int re = checkParamAccess(ifs->getElse(), p, visiting);
      if (rt == -1 || re == -1)
        return -1;
      if (rt == 1 && re == 1)
        return 1;
      return 0;
    }
    return exprMentionsDecl(s, p) ? -1 : 0;
  }

  auto isInOutParamImpl(const FunctionDecl *fd, const ParmVarDecl *p,
                        std::unordered_set<const FunctionDecl *> &visiting) -> bool {
    if (!fd || !isOutParam(p) || !fd->hasBody())
      return false;
    if (!visiting.insert(fd).second)
      return false;
    int acc = checkParamAccess(fd->getBody(), p, visiting);
    visiting.erase(fd);
    if (acc == -1)
      return true;
    // For internal helpers, an out-parameter that is only conditionally written must carry
    // the caller's initial value into the untouched branches.
    if (fd != root_target_ && acc == 0)
      return true;
    return false;
  }

  auto isInOutParam(const FunctionDecl *fd, const ParmVarDecl *p) -> bool {
    std::unordered_set<const FunctionDecl *> visiting;
    return isInOutParamImpl(fd, p, visiting);
  }

  auto extractFunction(const FunctionDecl *fd, std::string lean_name_override = "")
      -> std::expected<void, std::string> {
    if (!root_target_)
      root_target_ = fd;
    if (extracted_funcs_.contains(fd))
      return {};
    extracted_funcs_.insert(fd);

    if (!fd->hasBody()) {
      return std::unexpected(
          std::format("function '{}' has no definition body", fd->getQualifiedNameAsString()));
    }

    ir::Function fn;
    fn.cpp_name = normalizeQualifiedName(fd->getQualifiedNameAsString());
    fn.mangled_name = mangleDecl(ctx_, fd);
    fn.lean_name = assignFuncLeanName(fd, lean_name_override);
    fn.orig_return_type = convertType(fd->getReturnType());
    fn.return_type = computeEffectiveReturnType(fd);

    for (const ParmVarDecl *p : fd->parameters()) {
      std::string pname = p->getNameAsString();
      if (pname.empty())
        pname = std::format("arg{}", fn.params.size());
      bool is_out = isOutParam(p);
      bool is_in_out = is_out && isInOutParam(fd, p);
      QualType pqt = p->getType().getCanonicalType();
      if (const auto *pt = pqt->getAs<PointerType>(); pt && !pt->getPointeeType()->isVoidType()) {
        pqt = pt->getPointeeType();
      }
      fn.params.push_back(ir::Param{pname, convertType(pqt), is_out, is_in_out});
    }

    auto saved_lambdas = std::move(local_lambdas_);
    auto saved_lambda_specs = std::move(lambda_spec_names_);
    local_lambdas_.clear();
    lambda_spec_names_.clear();
    current_diags_.clear();
    if (const auto *cs = dyn_cast<CompoundStmt>(fd->getBody())) {
      fn.body_stmts = extractStmtList(cs);
    } else {
      extractStmtInto(fd->getBody(), fn.body_stmts);
    }
    fn.diagnostics = current_diags_;
    local_lambdas_ = std::move(saved_lambdas);
    lambda_spec_names_ = std::move(saved_lambda_specs);

    if (opts_.strict && !fn.diagnostics.empty()) {
      return std::unexpected(std::format("strict mode: {} unsupported construct(s) in '{}': {}",
                                         fn.diagnostics.size(), fn.cpp_name,
                                         fn.diagnostics.front()));
    }

    auto pending = std::move(pending_helpers_);
    pending_helpers_.clear();
    for (const FunctionDecl *helper : pending) {
      if (auto r = extractFunction(helper); !r)
        return r;
    }

    module_.functions.push_back(std::move(fn));
    return {};
  }

  auto takeModule() -> ir::Module { return std::move(module_); }

private:
  auto extractUIntLimbsHex(const APValue &val) -> std::optional<std::string> {
    const APValue *cur = &val;
    while (cur->isStruct() && cur->getStructNumFields() == 1) {
      cur = &cur->getStructField(0);
    }
    if (cur->isInt())
      return apIntToUpperHex(cur->getInt());
    if (cur->isArray() && cur->getArraySize() > 0) {
      llvm::APInt acc(64 * cur->getArraySize(), 0);
      for (unsigned i = 0; i < cur->getArraySize(); ++i) {
        const APValue &elt = i < cur->getArrayInitializedElts() ? cur->getArrayInitializedElt(i)
                                                                : cur->getArrayFiller();
        if (!elt.isInt())
          return std::nullopt;
        llvm::APInt word = elt.getInt().zextOrTrunc(acc.getBitWidth());
        acc |= (word << (i * 64));
      }
      return apIntToUpperHex(acc);
    }
    return std::nullopt;
  }

  auto recordUnsupportedExpr(std::string reason, QualType qt) -> ir::ExprPtr {
    current_diags_.push_back(reason);
    return ir::Expr::make(ir::UnsupportedExpr{std::move(reason)}, convertType(qt));
  }

  auto recordUnsupportedStmt(std::string reason) -> ir::Stmt {
    current_diags_.push_back(reason);
    return ir::Stmt{ir::UnsupportedStmt{std::move(reason)}};
  }

  auto extractStmtList(const CompoundStmt *cs) -> std::vector<ir::Stmt> {
    std::vector<ir::Stmt> out;
    for (const Stmt *s : cs->body()) {
      extractStmtInto(s, out);
    }
    return out;
  }

  static auto unwrapTransparentAndCasts(const Expr *e) -> const Expr * {
    while (e) {
      e = unwrapExprSugar(e);
      if (const auto *ce = dyn_cast_or_null<CastExpr>(e)) {
        e = ce->getSubExpr();
        continue;
      }
      if (const auto *call = dyn_cast_or_null<CallExpr>(e);
          call && !isa<CXXMemberCallExpr>(call) && !isa<CXXOperatorCallExpr>(call)) {
        if (const FunctionDecl *fd = call->getDirectCallee()) {
          if (auto spec = matchFreeCoreOp(fd->getQualifiedNameAsString());
              spec && spec->is_transparent && call->getNumArgs() >= 1) {
            e = call->getArg(0);
            continue;
          }
        }
      }
      break;
    }
    return e;
  }

  static auto unwrapLambdaExpr(const Expr *e) -> const LambdaExpr * {
    e = unwrapExprSugar(e);
    if (const auto *le = dyn_cast_or_null<LambdaExpr>(e))
      return le;
    if (const auto *cce = dyn_cast_or_null<CXXConstructExpr>(e); cce && cce->getNumArgs() == 1) {
      return dyn_cast_or_null<LambdaExpr>(unwrapExprSugar(cce->getArg(0)));
    }
    return nullptr;
  }

  static auto extractOutTargetName(const Expr *raw) -> std::optional<std::string> {
    const Expr *e = unwrapExprSugar(raw);
    while (e) {
      if (const auto *uo = dyn_cast<UnaryOperator>(e);
          uo && (uo->getOpcode() == UO_AddrOf || uo->getOpcode() == UO_Deref)) {
        e = unwrapExprSugar(uo->getSubExpr());
      } else {
        break;
      }
    }
    if (const auto *dre = dyn_cast_or_null<DeclRefExpr>(e)) {
      return dre->getDecl()->getNameAsString();
    }
    return std::nullopt;
  }

  auto tryExtractOutParamCall(const CallExpr *call,
                              std::vector<std::pair<std::string, ir::TypePtr>> &out_targets)
      -> std::optional<ir::ExprPtr> {
    if (!call || isa<CXXMemberCallExpr>(call) || isa<CXXOperatorCallExpr>(call))
      return std::nullopt;
    const FunctionDecl *callee = call->getDirectCallee();
    if (!callee)
      return std::nullopt;
    if (const auto *md = dyn_cast<CXXMethodDecl>(callee); md && md->isStatic()) {
      if (matchCoreType(md->getParent()->getQualifiedNameAsString()))
        return std::nullopt;
    }
    if (matchFreeCoreOp(callee->getQualifiedNameAsString()))
      return std::nullopt;

    bool any_out = false;
    for (const ParmVarDecl *p : callee->parameters()) {
      if (isOutParam(p)) {
        any_out = true;
        break;
      }
    }
    if (!any_out)
      return std::nullopt;

    if (opts_.follow_helpers && callee->hasBody()) {
      pending_helpers_.push_back(callee);
    }
    std::vector<ir::ExprPtr> in_args;
    out_targets.clear();
    for (unsigned i = 0; i < call->getNumArgs() && i < callee->getNumParams(); ++i) {
      const ParmVarDecl *p = callee->getParamDecl(i);
      if (isOutParam(p)) {
        auto tname = extractOutTargetName(call->getArg(i));
        if (!tname)
          return std::nullopt;
        QualType pqt = p->getType().getCanonicalType();
        if (const auto *pt = pqt->getAs<PointerType>())
          pqt = pt->getPointeeType();
        auto pty = convertType(pqt);
        if (isInOutParam(callee, p)) {
          in_args.push_back(ir::Expr::make(ir::VarExpr{*tname}, pty));
        }
        out_targets.emplace_back(std::move(*tname), std::move(pty));
      } else {
        in_args.push_back(extractExpr(call->getArg(i)));
      }
    }
    auto lean_callee = assignFuncLeanName(callee);
    auto eff_ret = computeEffectiveReturnType(callee);
    return ir::Expr::make(
        ir::FuncCallExpr{std::move(lean_callee), std::move(in_args), false, false},
        std::move(eff_ret));
  }

  void extractStmtInto(const Stmt *s, std::vector<ir::Stmt> &out) {
    if (!s || isa<NullStmt>(s))
      return;

    if (const auto *as = dyn_cast<clang::AttributedStmt>(s)) {
      extractStmtInto(as->getSubStmt(), out);
      return;
    }

    if (const auto *cs = dyn_cast<CompoundStmt>(s)) {
      for (const Stmt *sub : cs->body()) {
        extractStmtInto(sub, out);
      }
      return;
    }

    if (const auto *ds = dyn_cast<DeclStmt>(s)) {
      for (const Decl *d : ds->decls()) {
        if (const auto *dd = dyn_cast<DecompositionDecl>(d)) {
          ir::TupleDeclStmt tds;
          for (const BindingDecl *bd : dd->bindings()) {
            tds.bindings.emplace_back(bd->getNameAsString(), convertType(bd->getType()));
          }
          if (dd->hasInit()) {
            tds.init = extractExpr(dd->getInit());
          }
          out.push_back(ir::Stmt{std::move(tds)});
          continue;
        }
        if (const auto *vd = dyn_cast<VarDecl>(d)) {
          if (vd->hasInit()) {
            if (const LambdaExpr *le = unwrapLambdaExpr(vd->getInit())) {
              auto emitLambdaOp = [&](const CXXMethodDecl *call_op, std::string lname) {
                ir::LocalFuncStmt lfs;
                lfs.name = std::move(lname);
                lfs.return_type = convertType(call_op->getReturnType());
                for (const ParmVarDecl *p : call_op->parameters()) {
                  std::string pname = p->getNameAsString();
                  if (pname.empty())
                    pname = std::format("arg{}", lfs.params.size());
                  lfs.params.emplace_back(std::move(pname), convertType(p->getType()));
                }
                local_lambdas_.insert(lfs.name);
                if (const auto *body_cs = dyn_cast<CompoundStmt>(call_op->getBody())) {
                  lfs.body_stmts = extractStmtList(body_cs);
                } else {
                  extractStmtInto(call_op->getBody(), lfs.body_stmts);
                }
                out.push_back(ir::Stmt{std::move(lfs)});
              };
              if (le->isGenericLambda()) {
                std::vector<const CXXMethodDecl *> specs;
                if (const auto *ftd = le->getLambdaClass()->getDependentLambdaCallOperator()) {
                  for (const FunctionDecl *sp : ftd->specializations()) {
                    if (const auto *md = dyn_cast<CXXMethodDecl>(sp); md && md->hasBody()) {
                      specs.push_back(md);
                    }
                  }
                }
                if (specs.size() == 1) {
                  std::string lname = vd->getNameAsString();
                  lambda_spec_names_[specs[0]->getCanonicalDecl()] = lname;
                  emitLambdaOp(specs[0], std::move(lname));
                } else {
                  for (std::size_t idx = 0; idx < specs.size(); ++idx) {
                    std::string lname = std::format("{}_s{}", vd->getNameAsString(), idx);
                    lambda_spec_names_[specs[idx]->getCanonicalDecl()] = lname;
                    emitLambdaOp(specs[idx], std::move(lname));
                  }
                }
              } else {
                emitLambdaOp(le->getCallOperator(), vd->getNameAsString());
              }
              continue;
            }
          }
          bool is_const_table =
              (vd->isConstexpr() || vd->getType().isConstQualified()) &&
              (vd->getType()->isArrayType() || isExceptValuesType(vd->getType()) ||
               (vd->isStaticLocal() && vd->getType()->isRecordType()));
          if (is_const_table && registerTable(vd).has_value()) {
            continue;
          }
          if (vd->hasInit()) {
            if (const auto *call = dyn_cast_or_null<CallExpr>(unwrapExprSugar(vd->getInit()))) {
              std::vector<std::pair<std::string, ir::TypePtr>> out_targets;
              if (auto ocall = tryExtractOutParamCall(call, out_targets)) {
                ir::TupleDeclStmt tds;
                tds.bindings.emplace_back(vd->getNameAsString(), convertType(vd->getType()));
                for (auto &ot : out_targets)
                  tds.bindings.push_back(std::move(ot));
                tds.init = std::move(*ocall);
                out.push_back(ir::Stmt{std::move(tds)});
                continue;
              }
            }
          }
          ir::VarDeclStmt vds;
          vds.name = vd->getNameAsString();
          vds.type = convertType(vd->getType());
          vds.is_const = vd->getType().isConstQualified() || vd->isConstexpr();
          vds.is_volatile = vd->getType().isVolatileQualified();
          if (vd->hasInit()) {
            if (vd->isConstexpr()) {
              if (const APValue *apv = vd->evaluateValue()) {
                if (auto cv = convertAPValue(*apv, vd->getType())) {
                  vds.init = ir::Expr::make(ir::ConstExpr{std::move(*cv)}, vds.type);
                }
              }
            }
            if (!vds.init) {
              vds.init = extractExpr(vd->getInit());
            }
          }
          out.push_back(ir::Stmt{std::move(vds)});
        }
      }
      return;
    }

    if (const auto *rs = dyn_cast<ReturnStmt>(s)) {
      std::optional<ir::ExprPtr> val;
      if (const Expr *re = rs->getRetValue()) {
        const Expr *call_cand = unwrapTransparentAndCasts(re);
        if (const auto *call = dyn_cast_or_null<CallExpr>(call_cand)) {
          std::vector<std::pair<std::string, ir::TypePtr>> out_targets;
          if (auto ocall = tryExtractOutParamCall(call, out_targets)) {
            std::string tmp_ret = std::format("__ret_{}", tmp_counter_++);
            auto call_ret_ty = convertType(call->getType());
            ir::TupleDeclStmt tds;
            tds.bindings.emplace_back(tmp_ret, call_ret_ty);
            for (auto &ot : out_targets)
              tds.bindings.push_back(std::move(ot));
            tds.init = std::move(*ocall);
            out.push_back(ir::Stmt{std::move(tds)});
            ir::ExprPtr ret_expr = ir::Expr::make(ir::VarExpr{std::move(tmp_ret)}, call_ret_ty);
            auto dst_ty = convertType(re->getType());
            if (call_ret_ty->isBool() && dst_ty->isInt()) {
              ret_expr = ir::Expr::make(ir::CastExpr{ir::CastKind::BoolToInt, ret_expr}, dst_ty);
            } else if (call_ret_ty->isInt() && dst_ty->isInt()) {
              const auto &src_i = std::get<ir::IntType>(call_ret_ty->v);
              const auto &dst_i = std::get<ir::IntType>(dst_ty->v);
              if (src_i.width != dst_i.width) {
                ret_expr =
                    ir::Expr::make(ir::CastExpr{ir::CastKind::IntToInt, ret_expr}, dst_ty);
              }
            } else if (call_ret_ty->isInt() && dst_ty->isBool()) {
              ret_expr = ir::Expr::make(ir::CastExpr{ir::CastKind::ToBool, ret_expr}, dst_ty);
            }
            out.push_back(ir::Stmt{ir::ReturnStmt{std::move(ret_expr)}});
            return;
          }
        }
        val = extractExpr(re);
      }
      out.push_back(ir::Stmt{ir::ReturnStmt{std::move(val)}});
      return;
    }

    if (const auto *ifs = dyn_cast<clang::IfStmt>(s)) {
      if (ifs->isConstexpr()) {
        if (auto active = ifs->getNondiscardedCase(ctx_); active && *active) {
          extractStmtInto(*active, out);
        }
        return;
      }

      if (const Stmt *init = ifs->getInit()) {
        extractStmtInto(init, out);
      }
      if (const DeclStmt *cond_decl = ifs->getConditionVariableDeclStmt()) {
        extractStmtInto(cond_decl, out);
      }

      ir::IfStmt node;
      const Expr *cond_raw = unwrapTransparentAndCasts(ifs->getCond());
      bool cond_negated = false;
      if (const auto *uo = dyn_cast_or_null<UnaryOperator>(cond_raw);
          uo && uo->getOpcode() == UO_LNot) {
        cond_negated = true;
        cond_raw = unwrapTransparentAndCasts(uo->getSubExpr());
      }
      if (const auto *call = dyn_cast_or_null<CallExpr>(cond_raw)) {
        std::vector<std::pair<std::string, ir::TypePtr>> out_targets;
        if (auto ocall = tryExtractOutParamCall(call, out_targets)) {
          std::string tmp_cond = std::format("__cond_{}", tmp_counter_++);
          auto cond_ty = convertType(call->getType());
          ir::TupleDeclStmt tds;
          tds.bindings.emplace_back(tmp_cond, cond_ty);
          for (auto &ot : out_targets)
            tds.bindings.push_back(std::move(ot));
          tds.init = std::move(*ocall);
          out.push_back(ir::Stmt{std::move(tds)});
          ir::ExprPtr cexpr = ir::Expr::make(ir::VarExpr{std::move(tmp_cond)}, cond_ty);
          if (cond_negated) {
            cexpr = ir::Expr::make(ir::UnaryExpr{ir::UnaryOp::LogNot, std::move(cexpr)},
                                   ir::Type::makeBool());
          }
          node.cond = std::move(cexpr);
        }
      }
      if (!node.cond) {
        node.cond = extractExpr(ifs->getCond());
      }
      if (ifs->getThen())
        extractStmtInto(ifs->getThen(), node.then_body);
      if (ifs->getElse())
        extractStmtInto(ifs->getElse(), node.else_body);
      out.push_back(ir::Stmt{std::move(node)});
      return;
    }

    if (const auto *sw = dyn_cast<clang::SwitchStmt>(s)) {
      if (const Stmt *init = sw->getInit()) {
        extractStmtInto(init, out);
      }
      ir::SwitchStmt node;
      node.scrutinee = extractExpr(sw->getCond());
      extractSwitchBody(sw->getBody(), node);
      out.push_back(ir::Stmt{std::move(node)});
      return;
    }

    if (const auto *ws = dyn_cast<clang::WhileStmt>(s)) {
      ir::WhileStmt node;
      node.cond = extractExpr(ws->getCond());
      if (ws->getBody())
        extractStmtInto(ws->getBody(), node.body);
      out.push_back(ir::Stmt{std::move(node)});
      return;
    }

    if (const auto *dw = dyn_cast<clang::DoStmt>(s)) {
      ir::DoWhileStmt node;
      if (dw->getBody())
        extractStmtInto(dw->getBody(), node.body);
      node.cond = extractExpr(dw->getCond());
      out.push_back(ir::Stmt{std::move(node)});
      return;
    }

    if (const auto *fs = dyn_cast<clang::ForStmt>(s)) {
      ir::ForStmt node;
      if (fs->getInit()) {
        std::vector<ir::Stmt> inits;
        extractStmtInto(fs->getInit(), inits);
        if (inits.size() == 1) {
          node.init = std::make_shared<ir::Stmt>(std::move(inits[0]));
        } else if (!inits.empty()) {
          node.init = std::make_shared<ir::Stmt>(ir::Stmt{ir::BlockStmt{std::move(inits)}});
        }
      }
      if (fs->getCond())
        node.cond = extractExpr(fs->getCond());
      if (fs->getInc()) {
        std::vector<ir::Stmt> steps;
        extractStmtInto(fs->getInc(), steps);
        if (!steps.empty()) {
          node.step = std::make_shared<ir::Stmt>(std::move(steps[0]));
        }
      }
      if (fs->getBody())
        extractStmtInto(fs->getBody(), node.body);
      out.push_back(ir::Stmt{std::move(node)});
      return;
    }

    if (isa<clang::BreakStmt>(s)) {
      out.push_back(ir::Stmt{ir::BreakStmt{}});
      return;
    }
    if (isa<clang::ContinueStmt>(s)) {
      out.push_back(ir::Stmt{ir::ContinueStmt{}});
      return;
    }

    if (const auto *e = dyn_cast<Expr>(s)) {
      extractExprAsStmt(e, out);
      return;
    }

    out.push_back(
        recordUnsupportedStmt(std::format("unsupported stmt kind '{}'", s->getStmtClassName())));
  }

  void extractSwitchBody(const Stmt *body, ir::SwitchStmt &sw) {
    const auto *cs = dyn_cast_or_null<CompoundStmt>(body);
    if (!cs)
      return;

    std::vector<ir::ConstVal> pending_vals;
    bool in_default = false;
    std::vector<ir::Stmt> current_body;

    auto flush = [&]() {
      if (!pending_vals.empty()) {
        sw.cases.push_back(ir::SwitchCase{std::move(pending_vals), std::move(current_body)});
        pending_vals.clear();
        current_body.clear();
      } else if (in_default) {
        sw.default_body = std::move(current_body);
        in_default = false;
        current_body.clear();
      }
    };

    auto evalCaseVal = [&](const CaseStmt *c) -> ir::ConstVal {
      Expr::EvalResult res;
      if (c->getLHS() && c->getLHS()->EvaluateAsConstantExpr(res, ctx_)) {
        if (auto cv = convertAPValue(res.Val, c->getLHS()->getType())) {
          return *cv;
        }
      }
      return ir::ConstVal{ir::IntConst{32, true, "0", 0, true}};
    };

    std::function<void(const Stmt *)> visitSwitchItem = [&](const Stmt *item) {
      if (const auto *c = dyn_cast<CaseStmt>(item)) {
        if (!current_body.empty() || in_default)
          flush();
        pending_vals.push_back(evalCaseVal(c));
        visitSwitchItem(c->getSubStmt());
      } else if (const auto *d = dyn_cast<DefaultStmt>(item)) {
        if (!current_body.empty() || !pending_vals.empty())
          flush();
        in_default = true;
        visitSwitchItem(d->getSubStmt());
      } else if (isa<clang::BreakStmt>(item)) {
        flush();
      } else {
        extractStmtInto(item, current_body);
      }
    };

    for (const Stmt *item : cs->body()) {
      visitSwitchItem(item);
    }
    flush();
  }

  void extractExprAsStmt(const Expr *raw, std::vector<ir::Stmt> &out) {
    const Expr *e = unwrapExprSugar(raw);
    if (!e)
      return;

    if (const auto *bo = dyn_cast<BinaryOperator>(e); bo && bo->getOpcode() == BO_Comma) {
      extractExprAsStmt(bo->getLHS(), out);
      extractExprAsStmt(bo->getRHS(), out);
      return;
    }

    if (const auto *bo = dyn_cast<BinaryOperator>(e); bo && bo->isAssignmentOp()) {
      auto compound = mapCompoundAssignOp(bo->getOpcode());
      const Expr *lhs = unwrapExprSugar(bo->getLHS());
      if (const auto *uo = dyn_cast<UnaryOperator>(lhs); uo && uo->getOpcode() == UO_Deref) {
        lhs = unwrapExprSugar(uo->getSubExpr());
      }
      if (!compound) {
        const Expr *rhs_raw = unwrapExprSugar(bo->getRHS());
        if (const auto *rhs_bo = dyn_cast<BinaryOperator>(rhs_raw);
            rhs_bo && rhs_bo->isAssignmentOp()) {
          extractExprAsStmt(rhs_bo, out);
          if (const auto *dre = dyn_cast<DeclRefExpr>(lhs)) {
            out.push_back(ir::Stmt{ir::AssignStmt{dre->getDecl()->getNameAsString(), std::nullopt,
                                                  extractExpr(rhs_bo->getLHS())}});
            return;
          }
        }
        if (const auto *call = dyn_cast<CallExpr>(rhs_raw)) {
          std::vector<std::pair<std::string, ir::TypePtr>> out_targets;
          if (auto ocall = tryExtractOutParamCall(call, out_targets)) {
            if (const auto *dre = dyn_cast<DeclRefExpr>(lhs)) {
              std::vector<std::string> targets;
              targets.push_back(dre->getDecl()->getNameAsString());
              for (auto &[tn, _] : out_targets)
                targets.push_back(std::move(tn));
              out.push_back(ir::Stmt{ir::AssignTupleStmt{std::move(targets), std::move(*ocall)}});
              return;
            }
          }
        }
      }
      ir::ExprPtr rhs = extractExpr(bo->getRHS());
      if (const auto *dre = dyn_cast<DeclRefExpr>(lhs)) {
        out.push_back(
            ir::Stmt{ir::AssignStmt{dre->getDecl()->getNameAsString(), compound, std::move(rhs)}});
        return;
      }
      if (const auto *me = dyn_cast<MemberExpr>(lhs)) {
        out.push_back(ir::Stmt{ir::FieldAssignStmt{extractExpr(me->getBase()),
                                                   me->getMemberDecl()->getNameAsString(), compound,
                                                   std::move(rhs)}});
        return;
      }
    }

    if (const auto *op = dyn_cast<CXXOperatorCallExpr>(e); op && op->getNumArgs() == 2) {
      auto kind = op->getOperator();
      const Expr *lhs = unwrapExprSugar(op->getArg(0));
      if (const auto *uo = dyn_cast<UnaryOperator>(lhs); uo && uo->getOpcode() == UO_Deref) {
        lhs = unwrapExprSugar(uo->getSubExpr());
      }
      ir::ExprPtr rhs = extractExpr(op->getArg(1));
      std::optional<ir::BinaryOp> compound;
      bool is_assign = false;
      if (kind == OO_Equal) {
        is_assign = true;
      } else if (kind == OO_PlusEqual) {
        is_assign = true;
        compound = ir::BinaryOp::Add;
      } else if (kind == OO_MinusEqual) {
        is_assign = true;
        compound = ir::BinaryOp::Sub;
      } else if (kind == OO_StarEqual) {
        is_assign = true;
        compound = ir::BinaryOp::Mul;
      } else if (kind == OO_PipeEqual) {
        is_assign = true;
        compound = ir::BinaryOp::BitOr;
      } else if (kind == OO_AmpEqual) {
        is_assign = true;
        compound = ir::BinaryOp::BitAnd;
      } else if (kind == OO_CaretEqual) {
        is_assign = true;
        compound = ir::BinaryOp::BitXor;
      } else if (kind == OO_LessLessEqual) {
        is_assign = true;
        compound = ir::BinaryOp::Shl;
      } else if (kind == OO_GreaterGreaterEqual) {
        is_assign = true;
        compound = ir::BinaryOp::Shr;
      }
      if (is_assign) {
        if (const auto *dre = dyn_cast<DeclRefExpr>(lhs)) {
          auto lhs_ty = convertType(dre->getType());
          if (lhs_ty->isFrac64() && compound == ir::BinaryOp::Mul) {
            auto mul = ir::Expr::make(ir::CoreCallExpr{CoreOpKind::Frac64Mul,
                                                       "Libc.Frac64.mul",
                                                       {extractExpr(lhs), std::move(rhs)},
                                                       {},
                                                       false,
                                                       true,
                                                       false,
                                                       {}},
                                      lhs_ty);
            out.push_back(ir::Stmt{
                ir::AssignStmt{dre->getDecl()->getNameAsString(), std::nullopt, std::move(mul)}});
            return;
          }
          if (lhs_ty->isDyadic() && compound) {
            if (*compound == ir::BinaryOp::Add || *compound == ir::BinaryOp::Sub ||
                *compound == ir::BinaryOp::Mul) {
              auto kind = *compound == ir::BinaryOp::Add
                              ? CoreOpKind::DyadicQuickAdd
                              : (*compound == ir::BinaryOp::Sub ? CoreOpKind::DyadicQuickSub
                                                                : CoreOpKind::DyadicQuickMul);
              std::string lname = *compound == ir::BinaryOp::Add
                                      ? "Libc.DyadicFloat.quickAdd"
                                      : (*compound == ir::BinaryOp::Sub
                                             ? "Libc.DyadicFloat.quickSub"
                                             : "Libc.DyadicFloat.quickMul");
              bool needs_cfg = (*compound == ir::BinaryOp::Mul);
              auto call = ir::Expr::make(ir::CoreCallExpr{kind,
                                                          std::move(lname),
                                                          {extractExpr(lhs), std::move(rhs)},
                                                          {},
                                                          false,
                                                          needs_cfg,
                                                          false,
                                                          {}},
                                         lhs_ty);
              out.push_back(ir::Stmt{ir::AssignStmt{dre->getDecl()->getNameAsString(), std::nullopt,
                                                    std::move(call)}});
              return;
            }
          }
          out.push_back(ir::Stmt{
              ir::AssignStmt{dre->getDecl()->getNameAsString(), compound, std::move(rhs)}});
          return;
        }
      }
    }

    if (const auto *mce = dyn_cast<CXXMemberCallExpr>(e)) {
      if (auto core_call = extractMemberCall(mce)) {
        if (const auto *cc = std::get_if<ir::CoreCallExpr>(&core_call->v);
            cc && isMutatingCoreOp(cc->op)) {
          const Expr *obj = unwrapExprSugar(mce->getImplicitObjectArgument());
          if (const auto *dre = dyn_cast_or_null<DeclRefExpr>(obj)) {
            out.push_back(ir::Stmt{ir::AssignStmt{dre->getDecl()->getNameAsString(), std::nullopt,
                                                  std::move(core_call)}});
            return;
          }
          if (const auto *me = dyn_cast_or_null<MemberExpr>(obj)) {
            out.push_back(ir::Stmt{ir::FieldAssignStmt{extractExpr(me->getBase()),
                                                       me->getMemberDecl()->getNameAsString(),
                                                       std::nullopt, std::move(core_call)}});
            return;
          }
        }
        out.push_back(ir::Stmt{ir::ExprStmt{std::move(core_call)}});
        return;
      }
    }

    if (const auto *uo = dyn_cast<UnaryOperator>(e); uo && uo->isIncrementDecrementOp()) {
      const Expr *sub = unwrapExprSugar(uo->getSubExpr());
      if (const auto *dre = dyn_cast<DeclRefExpr>(sub)) {
        auto ty = convertType(dre->getType());
        std::uint32_t w = 32;
        bool is_s = true;
        if (const auto *it = std::get_if<ir::IntType>(&ty->v)) {
          w = it->width;
          is_s = it->is_signed;
        }
        auto one =
            ir::Expr::make(ir::ConstExpr{ir::ConstVal{ir::IntConst{w, is_s, "1", 1, true}}}, ty);
        out.push_back(ir::Stmt{ir::AssignStmt{
            dre->getDecl()->getNameAsString(),
            uo->isIncrementOp() ? ir::BinaryOp::Add : ir::BinaryOp::Sub,
            std::move(one),
        }});
        return;
      }
    }

    if (const auto *call = dyn_cast<CallExpr>(e)) {
      std::vector<std::pair<std::string, ir::TypePtr>> out_targets;
      if (auto ocall = tryExtractOutParamCall(call, out_targets)) {
        bool has_ret = !convertType(call->getType())->isVoid();
        if (!has_ret && out_targets.size() == 1) {
          out.push_back(
              ir::Stmt{ir::AssignStmt{out_targets[0].first, std::nullopt, std::move(*ocall)}});
          return;
        }
        std::vector<std::string> targets;
        if (has_ret)
          targets.emplace_back("_");
        for (auto &[tn, _] : out_targets)
          targets.push_back(std::move(tn));
        out.push_back(ir::Stmt{ir::AssignTupleStmt{std::move(targets), std::move(*ocall)}});
        return;
      }
    }

    out.push_back(ir::Stmt{ir::ExprStmt{extractExpr(e)}});
  }

  auto extractExpr(const Expr *raw) -> ir::ExprPtr {
    const Expr *e = unwrapExprSugar(raw);
    if (!e)
      return ir::Expr::make(ir::UnsupportedExpr{"null expr"}, ir::Type::makeVoid());

    if (const auto *bl = dyn_cast<CXXBoolLiteralExpr>(e)) {
      return ir::Expr::make(ir::ConstExpr{ir::ConstVal{ir::BoolConst{bl->getValue()}}},
                            ir::Type::makeBool());
    }
    if (const auto *il = dyn_cast<IntegerLiteral>(e)) {
      auto ty = convertType(il->getType());
      bool is_s = il->getType()->isSignedIntegerType();
      llvm::APInt v = il->getValue();
      auto w = static_cast<std::uint32_t>(v.getBitWidth());
      bool fits = v.getSignificantBits() <= 64;
      std::int64_t sval =
          fits ? (is_s ? v.getSExtValue() : static_cast<std::int64_t>(v.getZExtValue())) : 0;
      return ir::Expr::make(
          ir::ConstExpr{ir::ConstVal{ir::IntConst{w, is_s, apIntToUpperHex(v), sval, fits}}},
          std::move(ty));
    }
    if (const auto *fl = dyn_cast<FloatingLiteral>(e)) {
      auto fmt = floatFmtFromQualType(fl->getType(), ctx_).value_or(FloatFmt::Binary64);
      const llvm::APFloat &val = fl->getValue();
      auto bits = val.bitcastToAPInt();
      std::uint64_t raw_bits = bits.getBitWidth() <= 64 ? bits.getZExtValue() : 0;
      return ir::Expr::make(
          ir::ConstExpr{ir::ConstVal{ir::FloatConst{fmt, raw_bits, apFloatRepr(val)}}},
          ir::Type::makeFloat(fmt));
    }

    if (const auto *dre = dyn_cast<DeclRefExpr>(e)) {
      const ValueDecl *vd = dre->getDecl();
      if (const auto *ecd = dyn_cast<EnumConstantDecl>(vd)) {
        const llvm::APSInt &v = ecd->getInitVal();
        auto w = static_cast<std::uint32_t>(v.getBitWidth());
        return ir::Expr::make(ir::ConstExpr{ir::ConstVal{ir::IntConst{
                                  w, v.isSigned(), apIntToUpperHex(v), v.getExtValue(), true}}},
                              convertType(dre->getType()));
      }
      if (const auto *var = dyn_cast<VarDecl>(vd)) {
        auto var_ty = convertType(var->getType());
        if (!var->isLocalVarDeclOrParm()) {
          // Small value constants like Sign::POS / Sign::NEG inline directly.
          if (var_ty->isSign()) {
            if (const APValue *apv = var->evaluateValue()) {
              if (auto cv = convertAPValue(*apv, var->getType())) {
                return ir::Expr::make(ir::ConstExpr{std::move(*cv)}, var_ty);
              }
            }
          }
          if (var->getType()->isArrayType() || var->getType()->isRecordType()) {
            if (auto tname = registerTable(var)) {
              return ir::Expr::make(ir::TableRefExpr{*tname}, var_ty);
            }
          }
          if (const APValue *apv = var->evaluateValue()) {
            if (auto cv = convertAPValue(*apv, var->getType())) {
              return ir::Expr::make(ir::ConstExpr{std::move(*cv)}, var_ty);
            }
          }
        } else if ((var->isConstexpr() || var->getType().isConstQualified()) &&
                   (var->getType()->isArrayType() || isExceptValuesType(var->getType()) ||
                    (var->isStaticLocal() && var->getType()->isRecordType()))) {
          if (auto tname = registerTable(var)) {
            return ir::Expr::make(ir::TableRefExpr{*tname}, var_ty);
          }
        }
      }
      return ir::Expr::make(ir::VarExpr{vd->getNameAsString()}, convertType(dre->getType()));
    }

    if (const auto *ue = dyn_cast<UnaryExprOrTypeTraitExpr>(e)) {
      Expr::EvalResult res;
      if (ue->EvaluateAsConstantExpr(res, ctx_)) {
        if (auto cv = convertAPValue(res.Val, ue->getType())) {
          return ir::Expr::make(ir::ConstExpr{std::move(*cv)}, convertType(ue->getType()));
        }
      }
    }

    if (const auto *uo = dyn_cast<UnaryOperator>(e)) {
      switch (uo->getOpcode()) {
      case UO_Plus:
        return extractExpr(uo->getSubExpr());
      case UO_Minus:
        if (const auto *fl = dyn_cast<FloatingLiteral>(unwrapExprSugar(uo->getSubExpr()))) {
          llvm::APFloat neg = fl->getValue();
          neg.changeSign();
          auto fmt = floatFmtFromQualType(fl->getType(), ctx_).value_or(FloatFmt::Binary64);
          auto bits = neg.bitcastToAPInt().getZExtValue();
          return ir::Expr::make(
              ir::ConstExpr{ir::ConstVal{ir::FloatConst{fmt, bits, apFloatRepr(neg)}}},
              ir::Type::makeFloat(fmt));
        }
        return ir::Expr::make(ir::UnaryExpr{ir::UnaryOp::Neg, extractExpr(uo->getSubExpr())},
                              convertType(uo->getType()));
      case UO_Not:
        return ir::Expr::make(ir::UnaryExpr{ir::UnaryOp::BitNot, extractExpr(uo->getSubExpr())},
                              convertType(uo->getType()));
      case UO_LNot:
        return ir::Expr::make(ir::UnaryExpr{ir::UnaryOp::LogNot, extractExpr(uo->getSubExpr())},
                              ir::Type::makeBool());
      case UO_AddrOf:
      case UO_Deref:
        return extractExpr(uo->getSubExpr());
      default:
        return recordUnsupportedExpr(
            std::format("unary operator '{}'", UnaryOperator::getOpcodeStr(uo->getOpcode()).str()),
            uo->getType());
      }
    }

    if (const auto *bo = dyn_cast<BinaryOperator>(e)) {
      if (bo->getOpcode() == BO_Comma) {
        auto lhs = extractExpr(bo->getLHS());
        auto rhs = extractExpr(bo->getRHS());
        auto rty = rhs->type;
        return ir::Expr::make(ir::LetExpr{"_", lhs->type, std::move(lhs), std::move(rhs)},
                              std::move(rty));
      }
      if (auto op = mapBinaryOp(bo->getOpcode())) {
        return ir::Expr::make(
            ir::BinaryExpr{*op, extractExpr(bo->getLHS()), extractExpr(bo->getRHS())},
            convertType(bo->getType()));
      }
      return recordUnsupportedExpr(std::format("binary operator '{}'", bo->getOpcodeStr().str()),
                                   bo->getType());
    }

    if (const auto *co = dyn_cast<ConditionalOperator>(e)) {
      return ir::Expr::make(ir::SelectExpr{extractExpr(co->getCond()),
                                           extractExpr(co->getTrueExpr()),
                                           extractExpr(co->getFalseExpr())},
                            convertType(co->getType()));
    }

    if (const auto *ase = dyn_cast<ArraySubscriptExpr>(e)) {
      auto base = extractExpr(ase->getBase());
      // Collapse `frac64.val[0]` directly to `frac64.val` (BitVec 64).
      if (const auto *fe = std::get_if<ir::FieldExpr>(&base->v)) {
        if (fe->field == "val" && fe->base && fe->base->type && fe->base->type->isFrac64()) {
          return ir::Expr::make(ir::FieldExpr{fe->base, "val"}, convertType(ase->getType()));
        }
      }
      return ir::Expr::make(ir::IndexExpr{std::move(base), extractExpr(ase->getIdx())},
                            convertType(ase->getType()));
    }

    if (const auto *me = dyn_cast<MemberExpr>(e)) {
      return ir::Expr::make(
          ir::FieldExpr{extractExpr(me->getBase()), me->getMemberDecl()->getNameAsString()},
          convertType(me->getType()));
    }

    if (const auto *bbc = dyn_cast<BuiltinBitCastExpr>(e)) {
      auto dst_ty = convertType(bbc->getType());
      return ir::Expr::make(ir::CastExpr{ir::CastKind::BitCast, extractExpr(bbc->getSubExpr())},
                            std::move(dst_ty));
    }

    if (const auto *ce = dyn_cast<CastExpr>(e)) {
      return extractCastExpr(ce);
    }

    if (const auto *oce = dyn_cast<CXXOperatorCallExpr>(e)) {
      return extractOperatorCall(oce);
    }

    if (const auto *mce = dyn_cast<CXXMemberCallExpr>(e)) {
      return extractMemberCall(mce);
    }

    if (const auto *cce = dyn_cast<CXXConstructExpr>(e)) {
      return extractConstructExpr(cce);
    }

    if (const auto *ile = dyn_cast<InitListExpr>(e)) {
      return extractInitList(ile);
    }

    if (const auto *call = dyn_cast<CallExpr>(e)) {
      return extractFreeCall(call);
    }

    Expr::EvalResult eval_res;
    if (e->EvaluateAsConstantExpr(eval_res, ctx_)) {
      if (auto cv = convertAPValue(eval_res.Val, e->getType())) {
        return ir::Expr::make(ir::ConstExpr{std::move(*cv)}, convertType(e->getType()));
      }
    }

    return recordUnsupportedExpr(std::format("expr kind '{}'", e->getStmtClassName()),
                                 e->getType());
  }

  auto extractCastExpr(const CastExpr *ce) -> ir::ExprPtr {
    const Expr *sub = ce->getSubExpr();
    auto dst_ty = convertType(ce->getType());
    auto ck = ce->getCastKind();

    if (ck == CK_ConstructorConversion || ck == CK_UserDefinedConversion || ck == CK_NoOp ||
        ck == CK_LValueToRValue || ck == CK_DerivedToBase || ck == CK_UncheckedDerivedToBase ||
        ck == CK_FunctionToPointerDecay || ck == CK_ArrayToPointerDecay) {
      return extractExpr(sub);
    }
    if (ck == CK_BitCast) {
      return ir::Expr::make(ir::CastExpr{ir::CastKind::BitCast, extractExpr(sub)},
                            std::move(dst_ty));
    }
    if (ck == CK_IntegralCast) {
      auto inner = extractExpr(sub);
      if (inner->type && inner->type->isBool() && dst_ty && dst_ty->isInt()) {
        return ir::Expr::make(ir::CastExpr{ir::CastKind::BoolToInt, std::move(inner)},
                              std::move(dst_ty));
      }
      return ir::Expr::make(ir::CastExpr{ir::CastKind::IntToInt, std::move(inner)},
                            std::move(dst_ty));
    }
    if (ck == CK_FloatingCast) {
      return ir::Expr::make(ir::CastExpr{ir::CastKind::FloatToFloat, extractExpr(sub)},
                            std::move(dst_ty));
    }
    if (ck == CK_IntegralToFloating) {
      return ir::Expr::make(ir::CastExpr{ir::CastKind::IntToFloat, extractExpr(sub)},
                            std::move(dst_ty));
    }
    if (ck == CK_FloatingToIntegral) {
      return ir::Expr::make(ir::CastExpr{ir::CastKind::FloatToInt, extractExpr(sub)},
                            std::move(dst_ty));
    }
    if (ck == CK_IntegralToBoolean || ck == CK_FloatingToBoolean || ck == CK_PointerToBoolean) {
      return ir::Expr::make(ir::CastExpr{ir::CastKind::ToBool, extractExpr(sub)},
                            ir::Type::makeBool());
    }
    if (ck == CK_BooleanToSignedIntegral) {
      return ir::Expr::make(ir::CastExpr{ir::CastKind::BoolToInt, extractExpr(sub)},
                            std::move(dst_ty));
    }

    return ir::Expr::make(ir::CastExpr{ir::CastKind::NoOp, extractExpr(sub)}, std::move(dst_ty));
  }

  auto extractOperatorCall(const CXXOperatorCallExpr *oce) -> ir::ExprPtr {
    auto op = oce->getOperator();
    auto ret_ty = convertType(oce->getType());

    if (op == OO_Call && oce->getNumArgs() >= 1) {
      std::string resolved_name;
      if (const FunctionDecl *callee = oce->getDirectCallee()) {
        if (auto it = lambda_spec_names_.find(callee->getCanonicalDecl());
            it != lambda_spec_names_.end()) {
          resolved_name = it->second;
        }
      }
      if (resolved_name.empty()) {
        if (const auto *dre = dyn_cast_or_null<DeclRefExpr>(unwrapExprSugar(oce->getArg(0)))) {
          auto lname = dre->getDecl()->getNameAsString();
          if (local_lambdas_.contains(lname)) {
            resolved_name = std::move(lname);
          }
        }
      }
      if (!resolved_name.empty()) {
        std::vector<ir::ExprPtr> cargs;
        for (unsigned i = 1; i < oce->getNumArgs(); ++i) {
          cargs.push_back(extractExpr(oce->getArg(i)));
        }
        return ir::Expr::make(
            ir::FuncCallExpr{std::move(resolved_name), std::move(cargs), false, true},
            std::move(ret_ty));
      }
    }

    if (op == OO_Subscript && oce->getNumArgs() == 2) {
      auto base = extractExpr(oce->getArg(0));
      if (const auto *fe = std::get_if<ir::FieldExpr>(&base->v)) {
        if (fe->field == "val" && fe->base && fe->base->type && fe->base->type->isFrac64()) {
          return ir::Expr::make(ir::FieldExpr{fe->base, "val"}, std::move(ret_ty));
        }
      }
      return ir::Expr::make(ir::IndexExpr{std::move(base), extractExpr(oce->getArg(1))},
                            std::move(ret_ty));
    }

    if (op == OO_Star && oce->getNumArgs() == 1) {
      auto arg0 = extractExpr(oce->getArg(0));
      if (arg0->type && std::holds_alternative<ir::OptionalType>(arg0->type->v)) {
        return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::OptionalValue,
                                               "Option.get!",
                                               {std::move(arg0)},
                                               {},
                                               false,
                                               false,
                                               false},
                              std::move(ret_ty));
      }
    }

    if (oce->getNumArgs() == 2) {
      auto lhs = extractExpr(oce->getArg(0));
      auto rhs = extractExpr(oce->getArg(1));

      if (lhs->type && lhs->type->isFrac64()) {
        if (op == OO_Star) {
          return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::Frac64Mul,
                                                 "Libc.Frac64.mul",
                                                 {std::move(lhs), std::move(rhs)},
                                                 {},
                                                 false,
                                                 true,
                                                 false},
                                std::move(ret_ty));
        }
        if (auto bop = mapOverloadedBinaryOp(op)) {
          return ir::Expr::make(ir::BinaryExpr{*bop, std::move(lhs), std::move(rhs)},
                                std::move(ret_ty));
        }
      }

      if (lhs->type && lhs->type->isDyadic()) {
        if (op == OO_Plus) {
          return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::DyadicAdd,
                                                 "Libc.DyadicFloat.quickAdd",
                                                 {std::move(lhs), std::move(rhs)},
                                                 {},
                                                 false,
                                                 false,
                                                 false,
                                                 {}},
                                std::move(ret_ty));
        }
        if (op == OO_Minus) {
          return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::DyadicSub,
                                                 "Libc.DyadicFloat.quickSub",
                                                 {std::move(lhs), std::move(rhs)},
                                                 {},
                                                 false,
                                                 false,
                                                 false,
                                                 {}},
                                std::move(ret_ty));
        }
        if (op == OO_Star) {
          return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::DyadicMul,
                                                 "Libc.DyadicFloat.quickMul",
                                                 {std::move(lhs), std::move(rhs)},
                                                 {},
                                                 false,
                                                 true,
                                                 false,
                                                 {}},
                                std::move(ret_ty));
        }
      }

      if (auto bop = mapOverloadedBinaryOp(op)) {
        return ir::Expr::make(ir::BinaryExpr{*bop, std::move(lhs), std::move(rhs)},
                              std::move(ret_ty));
      }
    }

    if (oce->getNumArgs() == 1) {
      auto arg = extractExpr(oce->getArg(0));
      if (op == OO_Tilde) {
        return ir::Expr::make(ir::UnaryExpr{ir::UnaryOp::BitNot, std::move(arg)},
                              std::move(ret_ty));
      }
      if (op == OO_Minus) {
        return ir::Expr::make(ir::UnaryExpr{ir::UnaryOp::Neg, std::move(arg)}, std::move(ret_ty));
      }
    }

    return extractFreeCall(oce);
  }

  auto extractMemberCall(const CXXMemberCallExpr *mce) -> ir::ExprPtr {
    const CXXRecordDecl *owner = mce->getRecordDecl();
    const CXXMethodDecl *method = mce->getMethodDecl();
    auto ret_ty = convertType(mce->getType());
    if (!owner || !method) {
      return recordUnsupportedExpr("unresolved member call", mce->getType());
    }

    auto owner_qname = owner->getQualifiedNameAsString();
    auto method_name = method->getNameAsString();

    if (isa<CXXConversionDecl>(method)) {
      auto core_owner = matchCoreType(owner_qname);
      auto recv = extractExpr(mce->getImplicitObjectArgument());
      if (core_owner == CoreTypeKind::FPBits && ret_ty->isFloat()) {
        return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::FPBitsGetVal,
                                               "Libc.FPBits.getVal",
                                               {std::move(recv)},
                                               {},
                                               false,
                                               false,
                                               false},
                              std::move(ret_ty));
      }
      if (core_owner == CoreTypeKind::Optional && ret_ty->isBool()) {
        return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::OptionalHasValue,
                                               "Option.isSome",
                                               {std::move(recv)},
                                               {},
                                               false,
                                               false,
                                               false},
                              ir::Type::makeBool());
      }
      if (core_owner == CoreTypeKind::NormalFloat && ret_ty->isFloat()) {
        return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::NormalFloatToVal,
                                               "Libc.NormalFloat.toVal",
                                               {std::move(recv)},
                                               {},
                                               false,
                                               false,
                                               false,
                                               {}},
                              std::move(ret_ty));
      }
      if (core_owner == CoreTypeKind::DyadicFloat && ret_ty->isFloat()) {
        auto fmt = std::get<ir::FloatType>(ret_ty->v).fmt;
        return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::DyadicAs,
                                               "Libc.DyadicFloat.asFloat",
                                               {std::move(recv)},
                                               {std::string(floatFmtLean(fmt))},
                                               true,
                                               true,
                                               false,
                                               {}},
                              std::move(ret_ty));
      }
      if (core_owner == CoreTypeKind::BigInt && ret_ty->isInt()) {
        return ir::Expr::make(ir::CastExpr{ir::CastKind::IntToInt, std::move(recv)},
                              std::move(ret_ty));
      }
    }

    auto core_owner = matchCoreType(owner_qname);
    if (!core_owner) {
      if (const Expr *obj = mce->getImplicitObjectArgument()) {
        QualType obj_qt = obj->getType().getCanonicalType().getUnqualifiedType();
        if (obj_qt->isPointerType())
          obj_qt = obj_qt->getPointeeType().getCanonicalType();
        if (const auto *rt = obj_qt->getAs<RecordType>()) {
          core_owner = matchCoreType(rt->getDecl()->getQualifiedNameAsString());
        }
      }
    }

    if (core_owner) {
      if (auto spec = matchMethodCoreOp(*core_owner, method_name)) {
        std::vector<ir::ExprPtr> args;
        args.push_back(extractExpr(mce->getImplicitObjectArgument()));
        for (const Expr *arg : mce->arguments()) {
          args.push_back(extractExpr(arg));
        }
        if (isMutatingCoreOp(spec->kind) && ret_ty->isVoid() && !args.empty()) {
          ret_ty = args[0]->type;
        }
        std::vector<std::string> type_args;
        if (spec->kind == CoreOpKind::DyadicFastAs || spec->kind == CoreOpKind::DyadicGenericAs ||
            spec->kind == CoreOpKind::DyadicAs) {
          if (const auto *ft = std::get_if<ir::FloatType>(&ret_ty->v)) {
            type_args.emplace_back(floatFmtLean(ft->fmt));
          }
        }
        return ir::Expr::make(ir::CoreCallExpr{spec->kind, std::string(spec->lean_name),
                                               std::move(args), std::move(type_args),
                                               spec->needs_mode, spec->needs_config,
                                               spec->is_effect, {}},
                              std::move(ret_ty));
      }
    }

    if (opts_.follow_helpers && method->hasBody()) {
      pending_helpers_.push_back(method);
    }
    std::vector<ir::ExprPtr> args;
    args.push_back(extractExpr(mce->getImplicitObjectArgument()));
    for (const Expr *arg : mce->arguments()) {
      args.push_back(extractExpr(arg));
    }
    auto cname = shortLeanName(normalizeQualifiedName(method->getQualifiedNameAsString()));
    return ir::Expr::make(ir::FuncCallExpr{std::move(cname), std::move(args), false},
                          std::move(ret_ty));
  }

  auto extractConstructExpr(const CXXConstructExpr *cce) -> ir::ExprPtr {
    const CXXConstructorDecl *ctor = cce->getConstructor();
    auto ret_ty = convertType(cce->getType());
    if (!ctor)
      return recordUnsupportedExpr("null constructor", cce->getType());

    if (ctor->isCopyOrMoveConstructor() && cce->getNumArgs() == 1) {
      return extractExpr(cce->getArg(0));
    }

    auto owner_qname = ctor->getParent()->getQualifiedNameAsString();
    if (auto core = matchCoreType(owner_qname)) {
      std::vector<ir::ExprPtr> args;
      for (const Expr *arg : cce->arguments()) {
        if (!isa<CXXDefaultArgExpr>(arg)) {
          args.push_back(extractExpr(arg));
        }
      }
      switch (*core) {
      case CoreTypeKind::FPBits:
        if (args.empty()) {
          auto fmt = std::get<ir::FPBitsType>(ret_ty->v).fmt;
          return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::FPBitsZero,
                                                 "Libc.FPBits.zero",
                                                 {},
                                                 {std::string(floatFmtLean(fmt))},
                                                 false,
                                                 false,
                                                 false},
                                std::move(ret_ty));
        }
        if (args[0]->type && args[0]->type->isFloat()) {
          return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::FPBitsOfVal,
                                                 "Libc.FPBits.ofVal",
                                                 std::move(args),
                                                 {},
                                                 false,
                                                 false,
                                                 false},
                                std::move(ret_ty));
        }
        return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::FPBitsOfBits,
                                               "Libc.FPBits.ofBits",
                                               std::move(args),
                                               {},
                                               false,
                                               false,
                                               false},
                              std::move(ret_ty));
      case CoreTypeKind::Frac64: {
        if (args.empty()) {
          return ir::Expr::make(ir::ConstExpr{ir::ConstVal{ir::Frac64Const{"0"}}},
                                std::move(ret_ty));
        }
        auto arg0 = std::move(args[0]);
        if (arg0->type && arg0->type->isInt()) {
          const auto &it = std::get<ir::IntType>(arg0->type->v);
          if (it.width != 64) {
            arg0 = ir::Expr::make(ir::CastExpr{ir::CastKind::IntToInt, std::move(arg0)},
                                  ir::Type::makeInt(64, false));
          }
        }
        return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::Frac64OfBits,
                                               "Libc.Frac64.ofBits",
                                               {std::move(arg0)},
                                               {},
                                               false,
                                               false,
                                               false},
                              std::move(ret_ty));
      }
      case CoreTypeKind::NormalFloat: {
        auto fmt = std::get<ir::NormalFloatType>(ret_ty->v).fmt;
        if (args.size() == 3) {
          return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::NormalFloatMkNorm,
                                                 "Libc.NormalFloat.mkNorm",
                                                 std::move(args),
                                                 {std::string(floatFmtLean(fmt))},
                                                 false,
                                                 false,
                                                 false,
                                                 {}},
                                std::move(ret_ty));
        }
        if (args.size() == 1 && args[0]->type &&
            std::holds_alternative<ir::FPBitsType>(args[0]->type->v)) {
          return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::NormalFloatOfBits,
                                                 "Libc.NormalFloat.ofBits",
                                                 std::move(args),
                                                 {},
                                                 false,
                                                 false,
                                                 false,
                                                 {}},
                                std::move(ret_ty));
        }
        if (args.size() == 1) {
          return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::NormalFloatOfVal,
                                                 "Libc.NormalFloat.ofVal",
                                                 std::move(args),
                                                 {},
                                                 false,
                                                 false,
                                                 false,
                                                 {}},
                                std::move(ret_ty));
        }
        break;
      }
      case CoreTypeKind::DyadicFloat: {
        auto bits = std::get<ir::DyadicFloatType>(ret_ty->v).bits;
        if (args.empty()) {
          return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::DyadicZero,
                                                 "Libc.DyadicFloat.zero",
                                                 {},
                                                 {std::to_string(bits)},
                                                 false,
                                                 false,
                                                 false,
                                                 {}},
                                std::move(ret_ty));
        }
        if (args.size() == 3) {
          if (args[1]->type && args[1]->type->isInt() &&
              std::get<ir::IntType>(args[1]->type->v).width != 32) {
            args[1] = ir::Expr::make(ir::CastExpr{ir::CastKind::IntToInt, std::move(args[1])},
                                     ir::Type::makeInt(32, true));
          }
          if (args[2]->type && args[2]->type->isInt() &&
              std::get<ir::IntType>(args[2]->type->v).width != bits) {
            args[2] = ir::Expr::make(ir::CastExpr{ir::CastKind::IntToInt, std::move(args[2])},
                                     ir::Type::makeInt(bits, false));
          }
          return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::DyadicMkNorm,
                                                 "Libc.DyadicFloat.mkNorm",
                                                 std::move(args),
                                                 {std::to_string(bits)},
                                                 false,
                                                 false,
                                                 false,
                                                 {}},
                                std::move(ret_ty));
        }
        return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::DyadicFromFloat,
                                               "Libc.DyadicFloat.ofFloat",
                                               std::move(args),
                                               {std::to_string(bits)},
                                               false,
                                               false,
                                               false,
                                               {}},
                              std::move(ret_ty));
      }
      case CoreTypeKind::BigInt: {
        Expr::EvalResult eval_res;
        if (cce->EvaluateAsConstantExpr(eval_res, ctx_)) {
          if (auto cv = convertAPValue(eval_res.Val, cce->getType())) {
            return ir::Expr::make(ir::ConstExpr{std::move(*cv)}, std::move(ret_ty));
          }
        }
        const auto &it = std::get<ir::IntType>(ret_ty->v);
        if (args.empty()) {
          return ir::Expr::make(
              ir::ConstExpr{ir::ConstVal{ir::IntConst{it.width, it.is_signed, "0", 0, true}}},
              std::move(ret_ty));
        }
        if (args.size() == 1 && args[0]->type && args[0]->type->isInt()) {
          return ir::Expr::make(ir::CastExpr{ir::CastKind::IntToInt, std::move(args[0])},
                                std::move(ret_ty));
        }
        if (args.size() == 1 &&
            (std::holds_alternative<ir::ArrayLitExpr>(args[0]->v) ||
             (args[0]->type && std::holds_alternative<ir::ArrayType>(args[0]->type->v)))) {
          return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::BigIntOfLimbs64,
                                                 "Libc.BigInt.ofLimbs64",
                                                 {std::move(args[0])},
                                                 {std::to_string(it.width)},
                                                 false,
                                                 false,
                                                 false,
                                                 {}},
                                std::move(ret_ty));
        }
        break;
      }
      case CoreTypeKind::NumberPair:
        if (args.size() == 2) {
          ir::StructLitExpr lit;
          lit.type_name = "Libc.NumberPair _";
          lit.fields.emplace_back("lo", std::move(args[0]));
          lit.fields.emplace_back("hi", std::move(args[1]));
          return ir::Expr::make(std::move(lit), std::move(ret_ty));
        }
        break;
      case CoreTypeKind::Optional: {
        bool is_nullopt = args.empty();
        if (!is_nullopt && cce->getNumArgs() >= 1) {
          QualType aqt = cce->getArg(0)->getType().getNonReferenceType().getCanonicalType();
          if (const auto *rd = aqt->getAsRecordDecl()) {
            if (matchesQualifiedSuffix(normalizeQualifiedName(rd->getQualifiedNameAsString()),
                                       "nullopt_t")) {
              is_nullopt = true;
            }
          }
        }
        if (is_nullopt) {
          return ir::Expr::make(
              ir::CoreCallExpr{CoreOpKind::OptionalNone, "none", {}, {}, false, false, false, {}},
              std::move(ret_ty));
        }
        return ir::Expr::make(
            ir::CoreCallExpr{
                CoreOpKind::OptionalSome, "some", std::move(args), {}, false, false, false, {}},
            std::move(ret_ty));
      }
      default:
        break;
      }
    }

    Expr::EvalResult eval_res;
    if (cce->EvaluateAsConstantExpr(eval_res, ctx_)) {
      if (auto cv = convertAPValue(eval_res.Val, cce->getType())) {
        return ir::Expr::make(ir::ConstExpr{std::move(*cv)}, std::move(ret_ty));
      }
    }

    std::vector<ir::ExprPtr> args;
    for (const Expr *arg : cce->arguments()) {
      args.push_back(extractExpr(arg));
    }
    auto name = shortLeanName(normalizeQualifiedName(owner_qname));
    return ir::Expr::make(ir::FuncCallExpr{name + ".mk", std::move(args), false},
                          std::move(ret_ty));
  }

  auto extractInitList(const InitListExpr *ile) -> ir::ExprPtr {
    auto ret_ty = convertType(ile->getType());
    Expr::EvalResult eval_res;
    if (ile->EvaluateAsConstantExpr(eval_res, ctx_)) {
      if (auto cv = convertAPValue(eval_res.Val, ile->getType())) {
        return ir::Expr::make(ir::ConstExpr{std::move(*cv)}, std::move(ret_ty));
      }
    }
    if (ile->getType()->isScalarType()) {
      if (ile->getNumInits() == 1) {
        return extractExpr(ile->getInit(0));
      }
      if (ile->getNumInits() == 0) {
        if (ret_ty->isBool()) {
          return ir::Expr::make(ir::ConstExpr{ir::ConstVal{ir::BoolConst{false}}},
                                std::move(ret_ty));
        }
        if (const auto *it = std::get_if<ir::IntType>(&ret_ty->v)) {
          return ir::Expr::make(
              ir::ConstExpr{ir::ConstVal{ir::IntConst{it->width, it->is_signed, "0", 0, true}}},
              std::move(ret_ty));
        }
        if (const auto *ft = std::get_if<ir::FloatType>(&ret_ty->v)) {
          return ir::Expr::make(ir::ConstExpr{ir::ConstVal{ir::FloatConst{ft->fmt, 0, "0.0"}}},
                                std::move(ret_ty));
        }
      }
    }
    if (ile->getType()->isConstantArrayType()) {
      ir::ArrayLitExpr lit;
      lit.elems.reserve(ile->getNumInits());
      for (unsigned i = 0; i < ile->getNumInits(); ++i) {
        lit.elems.push_back(extractExpr(ile->getInit(i)));
      }
      return ir::Expr::make(std::move(lit), std::move(ret_ty));
    }
    if (const auto *rt = ile->getType()->getAs<RecordType>()) {
      const RecordDecl *rd = rt->getDecl();
      auto core = matchCoreType(rd->getQualifiedNameAsString());
      if (core == CoreTypeKind::Array && ile->getNumInits() == 1) {
        return extractExpr(ile->getInit(0));
      }
      if (core == CoreTypeKind::DyadicFloat) {
        auto bits = std::get<ir::DyadicFloatType>(ret_ty->v).bits;
        if (ile->getNumInits() == 0) {
          return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::DyadicZero,
                                                 "Libc.DyadicFloat.zero",
                                                 {},
                                                 {std::to_string(bits)},
                                                 false,
                                                 false,
                                                 false,
                                                 {}},
                                std::move(ret_ty));
        }
        if (ile->getNumInits() == 3) {
          std::vector<ir::ExprPtr> args;
          args.push_back(extractExpr(ile->getInit(0)));
          args.push_back(extractExpr(ile->getInit(1)));
          args.push_back(extractExpr(ile->getInit(2)));
          return ir::Expr::make(ir::CoreCallExpr{CoreOpKind::DyadicMkNorm,
                                                 "Libc.DyadicFloat.mkNorm",
                                                 std::move(args),
                                                 {std::to_string(bits)},
                                                 false,
                                                 false,
                                                 false,
                                                 {}},
                                std::move(ret_ty));
        }
      }
      if (core == CoreTypeKind::NumberPair && ile->getNumInits() == 2) {
        ir::StructLitExpr lit;
        auto fmt = std::get<ir::NumberPairType>(ret_ty->v).fmt;
        lit.type_name =
            (fmt == FloatFmt::Binary32)
                ? "Libc.FloatFloat"
                : (fmt == FloatFmt::Binary64 ? "Libc.DoubleDouble" : "Libc.NumberPair _");
        lit.fields.emplace_back("lo", extractExpr(ile->getInit(0)));
        lit.fields.emplace_back("hi", extractExpr(ile->getInit(1)));
        return ir::Expr::make(std::move(lit), std::move(ret_ty));
      }
      ir::StructLitExpr lit;
      lit.type_name = shortLeanName(normalizeQualifiedName(rd->getQualifiedNameAsString()));
      unsigned i = 0;
      for (const FieldDecl *fd : rd->fields()) {
        if (i >= ile->getNumInits())
          break;
        lit.fields.emplace_back(fd->getNameAsString(), extractExpr(ile->getInit(i++)));
      }
      return ir::Expr::make(std::move(lit), std::move(ret_ty));
    }
    return recordUnsupportedExpr("non-record InitListExpr", ile->getType());
  }

  auto extractFreeCall(const CallExpr *call) -> ir::ExprPtr {
    auto ret_ty = convertType(call->getType());
    const FunctionDecl *callee = call->getDirectCallee();
    if (!callee) {
      return recordUnsupportedExpr("indirect call", call->getType());
    }

    auto qname = callee->getQualifiedNameAsString();

    if (const auto *md = dyn_cast<CXXMethodDecl>(callee); md && md->isStatic()) {
      if (auto core_owner = matchCoreType(md->getParent()->getQualifiedNameAsString())) {
        if (auto spec = matchMethodCoreOp(*core_owner, md->getNameAsString())) {
          std::vector<ir::ExprPtr> args;
          for (const Expr *arg : call->arguments()) {
            if (!isa<CXXDefaultArgExpr>(arg))
              args.push_back(extractExpr(arg));
          }
          std::vector<std::string> type_args;
          if (*core_owner == CoreTypeKind::FPBits) {
            if (const auto *fpb = std::get_if<ir::FPBitsType>(&ret_ty->v)) {
              type_args.emplace_back(floatFmtLean(fpb->fmt));
            } else {
              const auto *cspec = dyn_cast<ClassTemplateSpecializationDecl>(md->getParent());
              type_args.emplace_back(floatFmtLean(getTemplateFirstFloatArg(cspec, ctx_)));
            }
          } else if (*core_owner == CoreTypeKind::DyadicFloat &&
                     spec->kind == CoreOpKind::DyadicRound) {
            const auto *cspec = dyn_cast<ClassTemplateSpecializationDecl>(md->getParent());
            type_args.push_back(std::to_string(getTemplateFirstIntegralArg(cspec, 128)));
          }
          return ir::Expr::make(ir::CoreCallExpr{spec->kind, std::string(spec->lean_name),
                                                 std::move(args), std::move(type_args),
                                                 spec->needs_mode, spec->needs_config,
                                                 spec->is_effect, {}},
                                std::move(ret_ty));
        }
      }
    }

    if (auto spec = matchFreeCoreOp(qname)) {
      if (spec->kind == CoreOpKind::IsConstantEvaluated) {
        return ir::Expr::make(ir::ConstExpr{ir::ConstVal{ir::BoolConst{false}}},
                              ir::Type::makeBool());
      }
      if (spec->is_transparent && call->getNumArgs() >= 1) {
        return extractExpr(call->getArg(0));
      }

      if ((spec->kind == CoreOpKind::Polyeval || spec->kind == CoreOpKind::AltPolyeval ||
           spec->kind == CoreOpKind::Estrin) &&
          call->getNumArgs() >= 2) {
        ir::PolyevalExpr poly;
        poly.scheme = (spec->kind == CoreOpKind::Estrin)
                          ? ir::PolyScheme::Estrin
                          : (spec->kind == CoreOpKind::AltPolyeval ? ir::PolyScheme::AltHorner
                                                                   : ir::PolyScheme::Horner);
        poly.offset = static_cast<std::size_t>(getFuncTemplateFirstIntegralArg(callee, 0));
        poly.var = extractExpr(call->getArg(0));
        if (call->getNumArgs() == 2) {
          auto arg1 = extractExpr(call->getArg(1));
          if (arg1->type && std::holds_alternative<ir::ArrayType>(arg1->type->v)) {
            poly.array_arg = true;
            poly.coeffs.push_back(std::move(arg1));
            return ir::Expr::make(std::move(poly), std::move(ret_ty));
          }
          poly.coeffs.push_back(std::move(arg1));
        } else {
          for (unsigned i = 1; i < call->getNumArgs(); ++i) {
            poly.coeffs.push_back(extractExpr(call->getArg(i)));
          }
        }
        return ir::Expr::make(std::move(poly), std::move(ret_ty));
      }

      std::vector<ir::ExprPtr> args;
      for (const Expr *arg : call->arguments()) {
        // Keep explicit args; for setOverflow/setUnderflow default Sign::POS is handled in Lean.
        if (isa<CXXDefaultArgExpr>(arg)) {
          if (spec->kind != CoreOpKind::SetOverflow && spec->kind != CoreOpKind::SetUnderflow) {
            args.push_back(extractExpr(arg));
          }
        } else {
          args.push_back(extractExpr(arg));
        }
      }

      std::vector<std::string> type_args;
      std::vector<std::string> trailing_args;
      if (spec->kind == CoreOpKind::Cast) {
        if (const auto *ft = std::get_if<ir::FloatType>(&ret_ty->v)) {
          type_args.emplace_back(floatFmtLean(ft->fmt));
        }
      } else if (spec->kind == CoreOpKind::IntLogb) {
        if (const auto *it = std::get_if<ir::IntType>(&ret_ty->v)) {
          type_args.push_back(std::to_string(it->width));
        }
      }

      std::string lean_name(spec->lean_name);
      CoreOpKind kind = spec->kind;
      bool needs_mode = spec->needs_mode;
      bool needs_config = spec->needs_config;

      if (kind == CoreOpKind::NextUp) {
        if (auto is_down = getFuncTemplateFirstIntegralOpt(callee); is_down && *is_down != 0) {
          kind = CoreOpKind::NextDown;
          lean_name = "Libc.nextDown";
        }
      }

      // Disambiguate NumberPair vs DyadicFloat overloads of quick_mul / quick_add / add / sub.
      if ((kind == CoreOpKind::DyadicQuickAdd || kind == CoreOpKind::DyadicQuickMul) &&
          ret_ty->isNumberPair()) {
        if (kind == CoreOpKind::DyadicQuickMul) {
          bool scalar_lhs = args.size() == 2 && args[0]->type && args[0]->type->isFloat();
          kind = scalar_lhs ? CoreOpKind::DDQuickMultScalar : CoreOpKind::DDQuickMult;
          lean_name = scalar_lhs ? "Libc.NumberPair.quickMultScalar" : "Libc.NumberPair.quickMult";
          needs_mode = true;
          needs_config = true;
        }
      }
      if (kind == CoreOpKind::DDQuickMult && args.size() == 2 && args[0]->type &&
          args[0]->type->isFloat()) {
        kind = CoreOpKind::DDQuickMultScalar;
        lean_name = "Libc.NumberPair.quickMultScalar";
      }
      if (kind == CoreOpKind::DDAdd && args.size() == 2) {
        if (args[0]->type && args[0]->type->isNumberPair() && args[1]->type &&
            args[1]->type->isFloat()) {
          lean_name = "Libc.NumberPair.addScalar";
        } else if (args[0]->type && args[0]->type->isFloat() && args[1]->type &&
                   args[1]->type->isNumberPair()) {
          lean_name = "Libc.NumberPair.scalarAdd";
        }
      }
      if (kind == CoreOpKind::DDSub && args.size() == 2) {
        if (args[0]->type && args[0]->type->isNumberPair() && args[1]->type &&
            args[1]->type->isFloat()) {
          lean_name = "Libc.NumberPair.subScalar";
        } else if (args[0]->type && args[0]->type->isFloat() && args[1]->type &&
                   args[1]->type->isNumberPair()) {
          lean_name = "Libc.NumberPair.scalarSub";
        }
      }
      if (kind == CoreOpKind::DDExactAdd || kind == CoreOpKind::DDExactSub ||
          kind == CoreOpKind::DDAdd || kind == CoreOpKind::DDSub) {
        if (auto fast2sum = getFuncTemplateFirstIntegralOpt(callee); fast2sum && *fast2sum == 0) {
          trailing_args.emplace_back("false");
        }
      }
      if (kind == CoreOpKind::DDExactMult && args.size() == 3) {
        kind = CoreOpKind::DDExactMultPresplit;
        lean_name = "Libc.NumberPair.exactMultPresplit";
        needs_config = false;
        needs_mode = true;
      }
      if (kind == CoreOpKind::DDExactMult || kind == CoreOpKind::DDExactMultPresplit ||
          kind == CoreOpKind::DDQuickMult || kind == CoreOpKind::DDSplit) {
        if (auto split_b = getFuncTemplateFirstIntegralOpt(callee)) {
          std::uint64_t def_split = 27;
          if (const auto *np = std::get_if<ir::NumberPairType>(&ret_ty->v);
              np && np->fmt == FloatFmt::Binary32) {
            def_split = 12;
          }
          if (*split_b != def_split) {
            trailing_args.push_back(std::to_string(*split_b));
          }
        }
      }

      return ir::Expr::make(ir::CoreCallExpr{kind, std::move(lean_name), std::move(args),
                                             std::move(type_args), needs_mode, needs_config,
                                             spec->is_effect, std::move(trailing_args)},
                            std::move(ret_ty));
    }

    if (opts_.follow_helpers && callee->hasBody()) {
      pending_helpers_.push_back(callee);
    }
    std::vector<ir::ExprPtr> args;
    for (const Expr *arg : call->arguments()) {
      args.push_back(extractExpr(arg));
    }
    auto lean_callee = assignFuncLeanName(callee);
    return ir::Expr::make(ir::FuncCallExpr{std::move(lean_callee), std::move(args), false},
                          std::move(ret_ty));
  }

  static auto mapBinaryOp(BinaryOperatorKind op) -> std::optional<ir::BinaryOp> {
    switch (op) {
    case BO_Add:
      return ir::BinaryOp::Add;
    case BO_Sub:
      return ir::BinaryOp::Sub;
    case BO_Mul:
      return ir::BinaryOp::Mul;
    case BO_Div:
      return ir::BinaryOp::Div;
    case BO_Rem:
      return ir::BinaryOp::Rem;
    case BO_And:
      return ir::BinaryOp::BitAnd;
    case BO_Or:
      return ir::BinaryOp::BitOr;
    case BO_Xor:
      return ir::BinaryOp::BitXor;
    case BO_Shl:
      return ir::BinaryOp::Shl;
    case BO_Shr:
      return ir::BinaryOp::Shr;
    case BO_EQ:
      return ir::BinaryOp::Eq;
    case BO_NE:
      return ir::BinaryOp::Ne;
    case BO_LT:
      return ir::BinaryOp::Lt;
    case BO_LE:
      return ir::BinaryOp::Le;
    case BO_GT:
      return ir::BinaryOp::Gt;
    case BO_GE:
      return ir::BinaryOp::Ge;
    case BO_LAnd:
      return ir::BinaryOp::LogAnd;
    case BO_LOr:
      return ir::BinaryOp::LogOr;
    default:
      return std::nullopt;
    }
  }

  static auto mapCompoundAssignOp(BinaryOperatorKind op) -> std::optional<ir::BinaryOp> {
    switch (op) {
    case BO_Assign:
      return std::nullopt;
    case BO_AddAssign:
      return ir::BinaryOp::Add;
    case BO_SubAssign:
      return ir::BinaryOp::Sub;
    case BO_MulAssign:
      return ir::BinaryOp::Mul;
    case BO_DivAssign:
      return ir::BinaryOp::Div;
    case BO_RemAssign:
      return ir::BinaryOp::Rem;
    case BO_AndAssign:
      return ir::BinaryOp::BitAnd;
    case BO_OrAssign:
      return ir::BinaryOp::BitOr;
    case BO_XorAssign:
      return ir::BinaryOp::BitXor;
    case BO_ShlAssign:
      return ir::BinaryOp::Shl;
    case BO_ShrAssign:
      return ir::BinaryOp::Shr;
    default:
      return std::nullopt;
    }
  }

  static auto mapOverloadedBinaryOp(OverloadedOperatorKind op) -> std::optional<ir::BinaryOp> {
    switch (op) {
    case OO_Plus:
      return ir::BinaryOp::Add;
    case OO_Minus:
      return ir::BinaryOp::Sub;
    case OO_Star:
      return ir::BinaryOp::Mul;
    case OO_Slash:
      return ir::BinaryOp::Div;
    case OO_Percent:
      return ir::BinaryOp::Rem;
    case OO_Amp:
      return ir::BinaryOp::BitAnd;
    case OO_Pipe:
      return ir::BinaryOp::BitOr;
    case OO_Caret:
      return ir::BinaryOp::BitXor;
    case OO_LessLess:
      return ir::BinaryOp::Shl;
    case OO_GreaterGreater:
      return ir::BinaryOp::Shr;
    case OO_EqualEqual:
      return ir::BinaryOp::Eq;
    case OO_ExclaimEqual:
      return ir::BinaryOp::Ne;
    case OO_Less:
      return ir::BinaryOp::Lt;
    case OO_LessEqual:
      return ir::BinaryOp::Le;
    case OO_Greater:
      return ir::BinaryOp::Gt;
    case OO_GreaterEqual:
      return ir::BinaryOp::Ge;
    default:
      return std::nullopt;
    }
  }

  ASTContext &ctx_;
  const ParseOptions &opts_;
  ir::Module module_;
  std::unordered_map<const RecordDecl *, std::string> structs_seen_;
  std::unordered_set<std::string> used_struct_names_;
  std::unordered_map<const VarDecl *, std::string> tables_seen_;
  std::unordered_set<std::string> used_table_names_;
  std::unordered_map<const FunctionDecl *, std::string> func_lean_names_;
  std::unordered_set<std::string> used_func_names_;
  std::unordered_set<const FunctionDecl *> extracted_funcs_;
  std::vector<const FunctionDecl *> pending_helpers_;
  const FunctionDecl *root_target_ = nullptr;
  std::unordered_set<std::string> local_lambdas_;
  std::unordered_map<const FunctionDecl *, std::string> lambda_spec_names_;
  std::vector<std::string> current_diags_;
  int tmp_counter_ = 0;
};

class FunctionFinder : public RecursiveASTVisitor<FunctionFinder> {
public:
  bool shouldVisitTemplateInstantiations() const { return true; }

  bool VisitFunctionDecl(FunctionDecl *fd) {
    if (!fd->isThisDeclarationADefinition() || fd->isImplicit() || fd->isDependentContext()) {
      return true;
    }
    if (isa<CXXConstructorDecl>(fd) || isa<CXXDestructorDecl>(fd)) {
      return true;
    }
    funcs.push_back(fd);
    return true;
  }

  std::vector<const FunctionDecl *> funcs;
};

auto unwrapForwardingWrapper(const FunctionDecl *fd) -> const FunctionDecl * {
  for (int depth = 0; depth < 4 && fd && fd->hasBody(); ++depth) {
    const auto *cs = dyn_cast<CompoundStmt>(fd->getBody());
    if (!cs || cs->size() != 1)
      break;
    const auto *rs = dyn_cast<ReturnStmt>(*cs->body_begin());
    if (!rs || !rs->getRetValue())
      break;
    const auto *call = dyn_cast<CallExpr>(unwrapExprSugar(rs->getRetValue()));
    if (!call)
      break;
    const FunctionDecl *callee = call->getDirectCallee();
    if (!callee || !callee->hasBody())
      break;
    if (matchFreeCoreOp(callee->getQualifiedNameAsString()))
      break;
    if (call->getNumArgs() != fd->getNumParams())
      break;
    bool all_direct_params = true;
    for (unsigned i = 0; i < call->getNumArgs(); ++i) {
      const auto *dre = dyn_cast<DeclRefExpr>(unwrapExprSugar(call->getArg(i)));
      if (!dre || dre->getDecl() != fd->getParamDecl(i)) {
        all_direct_params = false;
        break;
      }
    }
    if (!all_direct_params)
      break;
    fd = callee;
  }
  return fd;
}

auto buildClangArgs(const ParseOptions &opts) -> std::vector<std::string> {
  std::vector<std::string> args = opts.clang_args;
  bool has_resource_dir = std::ranges::any_of(args, [](std::string_view a) {
    return a == "-resource-dir" || a.starts_with("-resource-dir=");
  });
  if (!has_resource_dir) {
    std::string rdir =
        opts.resource_dir.empty() ? AST2LEAN_DEFAULT_RESOURCE_DIR : opts.resource_dir;
    if (!rdir.empty()) {
      args.emplace_back("-resource-dir");
      args.push_back(std::move(rdir));
    }
  }
  bool has_std =
      std::ranges::any_of(args, [](std::string_view a) { return a.starts_with("-std="); });
  if (!has_std) {
    args.emplace_back("-std=gnu++17");
  }
  return args;
}

enum class ToolMode : std::uint8_t {
  Extract,
  ListFunctions,
  InspectConfig,
};

struct ExtractActionResult {
  std::optional<std::expected<ir::Module, std::string>> module_result;
  std::vector<FunctionListing> listings;
  ir::MathConfig config;
};

class ExtractASTConsumer : public ASTConsumer {
public:
  ExtractASTConsumer(CompilerInstance &ci, const ParseOptions &opts, ToolMode mode,
                     ExtractActionResult &out)
      : ci_(ci), opts_(opts), mode_(mode), out_(out) {}

  void HandleTranslationUnit(ASTContext &ctx) override {
    if (ctx.getDiagnostics().hasErrorOccurred()) {
      out_.module_result = std::unexpected("Clang reported compilation errors in input file");
      return;
    }

    out_.config = captureMathConfig(ci_);

    if (mode_ == ToolMode::InspectConfig) {
      if (!opts_.impl_variant.empty()) {
        out_.config.impl_variant = opts_.impl_variant;
      }
      return;
    }

    FunctionFinder finder;
    finder.TraverseDecl(ctx.getTranslationUnitDecl());

    if (mode_ == ToolMode::ListFunctions) {
      for (const FunctionDecl *fd : finder.funcs) {
        out_.listings.push_back(FunctionListing{
            .qualified_name = normalizeQualifiedName(fd->getQualifiedNameAsString()),
            .mangled_name = mangleDecl(ctx, fd),
            .signature = fd->getType().getAsString(),
            .is_template_instantiation = fd->isTemplateInstantiation(),
        });
      }
      return;
    }

    std::string target_norm = normalizeQualifiedName(opts_.target_function);
    std::vector<const FunctionDecl *> exact_matches;
    std::vector<const FunctionDecl *> suffix_matches;

    for (const FunctionDecl *fd : finder.funcs) {
      auto qnorm = normalizeQualifiedName(fd->getQualifiedNameAsString());
      auto mangled = mangleDecl(ctx, fd);
      if (mangled == opts_.target_function || qnorm == target_norm) {
        exact_matches.push_back(fd);
      } else if (matchesQualifiedSuffix(qnorm, target_norm)) {
        suffix_matches.push_back(fd);
      }
    }

    const auto &matches = !exact_matches.empty() ? exact_matches : suffix_matches;
    if (matches.empty()) {
      out_.module_result = std::unexpected(
          std::format("no function matching '{}' found in '{}' (try --list-functions)",
                      opts_.target_function, opts_.source_file));
      return;
    }
    if (matches.size() > 1) {
      std::string msg = std::format(
          "multiple functions match '{}'; disambiguate with qualified or mangled name:\n",
          opts_.target_function);
      for (const FunctionDecl *fd : matches) {
        msg += std::format("  {}  [{}]\n", normalizeQualifiedName(fd->getQualifiedNameAsString()),
                           mangleDecl(ctx, fd));
      }
      out_.module_result = std::unexpected(std::move(msg));
      return;
    }

    const FunctionDecl *target = matches.front();
    if (opts_.unwrap_forwarding) {
      target = unwrapForwardingWrapper(target);
    }

    AstExtractor extractor(ctx, opts_);
    if (auto r = extractor.extractFunction(target, opts_.lean_name); !r) {
      out_.module_result = std::unexpected(r.error());
      return;
    }

    ir::Module mod = extractor.takeModule();
    mod.config = out_.config;
    mod.config.impl_variant =
        !opts_.impl_variant.empty()
            ? opts_.impl_variant
            : inferImplVariant(normalizeQualifiedName(target->getQualifiedNameAsString()));
    mod.source_file = opts_.source_label.empty() ? opts_.source_file : opts_.source_label;
    mod.source_commit = opts_.source_commit;
    mod.clang_version = AST2LEAN_CLANG_VERSION;
    mod.origin = std::format("ast2lean (Clang {}), {}", AST2LEAN_CLANG_VERSION, mod.source_file);
    out_.module_result = std::move(mod);
  }

private:
  CompilerInstance &ci_;
  const ParseOptions &opts_;
  ToolMode mode_;
  ExtractActionResult &out_;
};

class ExtractFrontendAction : public ASTFrontendAction {
public:
  ExtractFrontendAction(const ParseOptions &opts, ToolMode mode, ExtractActionResult &out)
      : opts_(opts), mode_(mode), out_(out) {}

  auto CreateASTConsumer(CompilerInstance &ci, llvm::StringRef)
      -> std::unique_ptr<ASTConsumer> override {
    return std::make_unique<ExtractASTConsumer>(ci, opts_, mode_, out_);
  }

private:
  const ParseOptions &opts_;
  ToolMode mode_;
  ExtractActionResult &out_;
};

class ExtractActionFactory : public tooling::FrontendActionFactory {
public:
  ExtractActionFactory(const ParseOptions &opts, ToolMode mode, ExtractActionResult &out)
      : opts_(opts), mode_(mode), out_(out) {}

  auto create() -> std::unique_ptr<FrontendAction> override {
    return std::make_unique<ExtractFrontendAction>(opts_, mode_, out_);
  }

private:
  const ParseOptions &opts_;
  ToolMode mode_;
  ExtractActionResult &out_;
};

auto runClangTool(const ParseOptions &opts, ToolMode mode)
    -> std::expected<ExtractActionResult, std::string> {
  auto clang_args = buildClangArgs(opts);
  tooling::FixedCompilationDatabase comp_db(".", clang_args);
  std::vector<std::string> sources = {opts.source_file};
  tooling::ClangTool tool(comp_db, sources);

  ExtractActionResult result;
  ExtractActionFactory factory(opts, mode, result);
  int rc = tool.run(&factory);
  if (result.module_result && !result.module_result->has_value()) {
    return std::unexpected(result.module_result->error());
  }
  if (rc != 0 && mode == ToolMode::Extract && !result.module_result) {
    return std::unexpected(
        std::format("Clang failed to parse '{}' (exit code {})", opts.source_file, rc));
  }
  return result;
}

} // namespace

auto parseTranslationUnit(const ParseOptions &opts) -> std::expected<ir::Module, std::string> {
  auto res = runClangTool(opts, ToolMode::Extract);
  if (!res)
    return std::unexpected(res.error());
  if (!res->module_result) {
    return std::unexpected("internal error: Clang action produced no result");
  }
  return std::move(*res->module_result);
}

auto listFunctions(const ParseOptions &opts)
    -> std::expected<std::vector<FunctionListing>, std::string> {
  auto res = runClangTool(opts, ToolMode::ListFunctions);
  if (!res)
    return std::unexpected(res.error());
  return std::move(res->listings);
}

auto inspectMathConfig(const ParseOptions &opts) -> std::expected<ir::MathConfig, std::string> {
  auto res = runClangTool(opts, ToolMode::InspectConfig);
  if (!res)
    return std::unexpected(res.error());
  if (!opts.impl_variant.empty()) {
    res->config.impl_variant = opts.impl_variant;
  } else if (!opts.target_function.empty()) {
    res->config.impl_variant = inferImplVariant(opts.target_function);
  }
  return res->config;
}

} // namespace libc_extract
