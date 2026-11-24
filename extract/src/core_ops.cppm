module;

#include <algorithm>
#include <array>
#include <cstdint>
#include <optional>
#include <ranges>
#include <string>
#include <string_view>

export module libc_extract.core_ops;

export namespace libc_extract {

enum class FloatFmt : std::uint8_t {
  Binary16,
  Binary32,
  Binary64,
  Binary128,
};

constexpr auto floatFmtBits(FloatFmt fmt) -> std::uint32_t {
  switch (fmt) {
  case FloatFmt::Binary16:  return 16;
  case FloatFmt::Binary32:  return 32;
  case FloatFmt::Binary64:  return 64;
  case FloatFmt::Binary128: return 128;
  }
  return 64;
}

constexpr auto floatFmtLean(FloatFmt fmt) -> std::string_view {
  switch (fmt) {
  case FloatFmt::Binary16:  return ".binary16";
  case FloatFmt::Binary32:  return ".binary32";
  case FloatFmt::Binary64:  return ".binary64";
  case FloatFmt::Binary128: return ".binary128";
  }
  return ".binary64";
}

constexpr auto floatFmtShort(FloatFmt fmt) -> std::string_view {
  switch (fmt) {
  case FloatFmt::Binary16:  return "f16";
  case FloatFmt::Binary32:  return "f32";
  case FloatFmt::Binary64:  return "f64";
  case FloatFmt::Binary128: return "f128";
  }
  return "f64";
}

enum class CoreTypeKind : std::uint8_t {
  FPBits,
  DyadicFloat,
  NumberPair,
  TripleDouble,
  Frac64,
  ExceptValues,
  Optional,
  Array,
  Sign,
};

enum class CoreOpKind : std::uint8_t {
  // Rounding mode & FP environment queries / side effects.
  QuickGetRound,
  IsRoundUp,
  IsRoundDown,
  IsRoundToNearest,
  IsRoundToZero,
  SetErrno,
  RaiseExcept,
  ClearExcept,
  SetOverflow,
  SetUnderflow,
  RoundSlightlyUp,
  RoundSlightlyDown,
  IsConstantEvaluated,
  DoNotOptimize,

  // Elementary FP & rounding helpers.
  NearestInt,
  RoundCurrentMode,
  RoundSpecificMode,
  Floor,
  Ceil,
  Trunc,
  Sqrt,
  Abs,
  CopySign,
  Fma,
  MultiplyAdd,
  MultiplySub,
  SubMultiply,
  Cast,
  BitCast,

  // Polynomial evaluation.
  Polyeval,
  AltPolyeval,
  Estrin,

  // Frac64 operations.
  Frac64OfBits,
  Frac64Mul,

  // DyadicFloat<N> operations.
  DyadicFromFloat,
  DyadicQuickAdd,
  DyadicQuickMul,
  DyadicAdd,
  DyadicSub,
  DyadicMul,
  DyadicNeg,
  DyadicPowN,
  DyadicShiftLeft,
  DyadicShiftRight,
  DyadicNormalize,
  DyadicFastAs,
  DyadicGenericAs,
  DyadicAs,

  // NumberPair (DoubleDouble / FloatFloat) operations.
  DDExactAdd,
  DDExactSub,
  DDAdd,
  DDSub,
  DDExactMult,
  DDQuickMult,
  DDQuickMultScalar,
  DDExactDiv,
  DDMake,

  // Exceptional value tables.
  ExceptLookup,
  ExceptLookupOdd,

  // FPBits<T> operations.
  FPBitsOfVal,
  FPBitsOfBits,
  FPBitsUintval,
  FPBitsGetVal,
  FPBitsAbs,
  FPBitsIsNeg,
  FPBitsIsPos,
  FPBitsIsZero,
  FPBitsIsInf,
  FPBitsIsNan,
  FPBitsIsQuietNan,
  FPBitsIsSignalingNan,
  FPBitsIsInfOrNan,
  FPBitsIsSubnormal,
  FPBitsIsSubnormalOrZero,
  FPBitsBiasedExp,
  FPBitsExplicitExp,
  FPBitsMantissa,
  FPBitsSign,
  FPBitsSetSign,
  FPBitsQuietNan,
  FPBitsInf,
  FPBitsZero,
  FPBitsMaxNormal,
  FPBitsMinSubnormal,
  FPBitsMinNormal,
  FPBitsOne,
  FPBitsCreateValue,

  // Integer bit-manipulation intrinsics.
  Clz,
  Ctz,
  Popcount,
  Min,
  Max,
  AbsInt,

  // Optional, Sign & branch-prediction wrappers.
  OptionalHasValue,
  OptionalValue,
  OptionalNone,
  OptionalSome,
  SignIsPos,
  SignIsNeg,
  TransparentHint,
};

struct CoreOpSpec {
  CoreOpKind kind;
  std::string_view cpp_suffix; // Normalized qualified name suffix.
  std::string_view lean_name;
  bool needs_mode = false;
  bool needs_config = false;
  bool is_effect = false;
  bool is_transparent = false;
};

/// Strip leading `::`, versioned `__llvm_libc...::` prefixes, `(anonymous namespace)::`,
/// and template argument lists `<...>` (handling nested angle brackets).
auto normalizeQualifiedName(std::string_view raw) -> std::string {
  std::string stripped;
  stripped.reserve(raw.size());
  int angle_depth = 0;
  for (char c : raw) {
    if (c == '<') {
      ++angle_depth;
    } else if (c == '>') {
      if (angle_depth > 0) --angle_depth;
    } else if (angle_depth == 0) {
      stripped.push_back(c);
    }
  }

  std::string_view sv = stripped;
  while (sv.starts_with("::")) sv.remove_prefix(2);

  // Drop leading __llvm_libc* namespace (e.g. __llvm_libc_20_0_0_git:: or __llvm_libc::).
  if (sv.starts_with("__llvm_libc")) {
    if (auto pos = sv.find("::"); pos != std::string_view::npos) {
      sv.remove_prefix(pos + 2);
    }
  }

  // Remove `(anonymous namespace)::` segments anywhere in the path.
  std::string out;
  constexpr std::string_view anon = "(anonymous namespace)::";
  while (!sv.empty()) {
    if (auto pos = sv.find(anon); pos != std::string_view::npos) {
      out.append(sv.substr(0, pos));
      sv.remove_prefix(pos + anon.size());
    } else {
      out.append(sv);
      break;
    }
  }
  return out;
}

/// Check whether `normalized` equals `suffix` or ends with `::` + `suffix`.
constexpr auto matchesQualifiedSuffix(std::string_view normalized,
                                      std::string_view suffix) -> bool {
  if (normalized == suffix) return true;
  if (normalized.size() <= suffix.size() + 2) return false;
  if (!normalized.ends_with(suffix)) return false;
  auto sep_pos = normalized.size() - suffix.size() - 2;
  return normalized.substr(sep_pos, 2) == "::";
}

inline constexpr std::array kFreeCoreOps = std::to_array<CoreOpSpec>({
  // Rounding mode & FP environment queries / side effects.
  {CoreOpKind::QuickGetRound,      "fputil::generic::quick_get_round",           "Core.quickGetRound",            true,  false, false, false},
  {CoreOpKind::QuickGetRound,      "fputil::quick_get_round",                    "Core.quickGetRound",            true,  false, false, false},
  {CoreOpKind::IsRoundUp,          "fputil::generic::fenv_is_round_up",          "Core.isRoundUp",                true,  false, false, false},
  {CoreOpKind::IsRoundUp,          "fputil::fenv_is_round_up",                   "Core.isRoundUp",                true,  false, false, false},
  {CoreOpKind::IsRoundDown,        "fputil::generic::fenv_is_round_down",        "Core.isRoundDown",              true,  false, false, false},
  {CoreOpKind::IsRoundDown,        "fputil::fenv_is_round_down",                 "Core.isRoundDown",              true,  false, false, false},
  {CoreOpKind::IsRoundToNearest,   "fputil::generic::fenv_is_round_to_nearest",  "Core.isRoundToNearest",         true,  false, false, false},
  {CoreOpKind::IsRoundToNearest,   "fputil::fenv_is_round_to_nearest",           "Core.isRoundToNearest",         true,  false, false, false},
  {CoreOpKind::IsRoundToZero,      "fputil::generic::fenv_is_round_to_zero",     "Core.isRoundToZero",            true,  false, false, false},
  {CoreOpKind::IsRoundToZero,      "fputil::fenv_is_round_to_zero",              "Core.isRoundToZero",            true,  false, false, false},
  {CoreOpKind::SetErrno,           "fputil::set_errno_if_required",              "Core.setErrno",                 false, false, true,  false},
  {CoreOpKind::RaiseExcept,        "fputil::raise_except_if_required",           "Core.raiseExcept",              false, false, true,  false},
  {CoreOpKind::RaiseExcept,        "fputil::raise_overflow_except_if_required",  "Core.raiseOverflow",            false, false, true,  false},
  {CoreOpKind::RaiseExcept,        "fputil::raise_underflow_except_if_required", "Core.raiseUnderflow",           false, false, true,  false},
  {CoreOpKind::ClearExcept,        "fputil::clear_except_if_required",           "Core.clearExcept",              false, false, true,  false},
  {CoreOpKind::DoNotOptimize,      "details::do_not_optimize",                   "",                              false, false, true,  false},
  {CoreOpKind::DoNotOptimize,      "details::do_not_optimize_impl",              "",                              false, false, true,  false},
  {CoreOpKind::SetOverflow,        "fputil::set_overflow",                       "Core.setOverflow",              true,  true,  false, false},
  {CoreOpKind::SetUnderflow,       "fputil::set_underflow",                      "Core.setUnderflow",             true,  true,  false, false},
  {CoreOpKind::RoundSlightlyUp,    "fputil::round_result_slightly_up",           "Core.roundResultSlightlyUp",    true,  true,  false, false},
  {CoreOpKind::RoundSlightlyDown,  "fputil::round_result_slightly_down",         "Core.roundResultSlightlyDown",  true,  true,  false, false},
  {CoreOpKind::IsConstantEvaluated,"cpp::is_constant_evaluated",                 "",                              false, false, false, false},
  {CoreOpKind::IsConstantEvaluated,"__builtin_is_constant_evaluated",            "",                              false, false, false, false},

  // Elementary FP & rounding helpers.
  {CoreOpKind::NearestInt,         "fputil::nearest_integer",                    "Core.nearestInt",               true,  true,  false, false},
  {CoreOpKind::RoundCurrentMode,   "fputil::round_using_current_rounding_mode",  "Core.roundToInt",               true,  false, false, false},
  {CoreOpKind::RoundSpecificMode,  "fputil::round_using_specific_rounding_mode", "Core.roundToIntMode",           false, false, false, false},
  {CoreOpKind::Floor,              "fputil::floor",                              "Core.floor",                    false, false, false, false},
  {CoreOpKind::Ceil,               "fputil::ceil",                               "Core.ceil",                     false, false, false, false},
  {CoreOpKind::Trunc,              "fputil::trunc",                              "Core.trunc",                    false, false, false, false},
  {CoreOpKind::Sqrt,               "fputil::sqrt",                               "Core.fsqrt",                    true,  false, false, false},
  {CoreOpKind::MultiplyAdd,        "fputil::multiply_add",                       "Core.PolyElem.madd",            true,  true,  false, false},
  {CoreOpKind::MultiplySub,        "fputil::multiply_sub",                       "Core.multiplySub",              true,  true,  false, false},
  {CoreOpKind::SubMultiply,        "fputil::sub_multiply",                       "Core.PolyElem.subMul",          true,  true,  false, false},
  {CoreOpKind::Fma,                "fputil::fma",                                "Core.fma",                      true,  false, false, false},
  {CoreOpKind::Cast,               "fputil::cast",                               "Core.fpCast",                   true,  false, false, false},
  {CoreOpKind::BitCast,            "cpp::bit_cast",                              "Core.bitCast",                  false, false, false, false},

  // Polynomial evaluation.
  {CoreOpKind::Polyeval,           "fputil::polyeval",                           "Core.polyevalList",             true,  true,  false, false},
  {CoreOpKind::AltPolyeval,        "fputil::altpolyeval",                        "Core.altpolyevalList",          true,  true,  false, false},
  {CoreOpKind::Estrin,             "fputil::estrin",                             "Core.estrin",                   true,  true,  false, false},
  {CoreOpKind::Estrin,             "fputil::estrin_polyeval",                    "Core.estrin",                   true,  true,  false, false},
  {CoreOpKind::Estrin,             "estrin_polyeval",                            "Core.estrin",                   true,  true,  false, false},

  // Free DyadicFloat / NumberPair helpers.
  {CoreOpKind::DyadicQuickAdd,     "fputil::quick_add",                          "Core.DyadicFloat.quickAdd",     false, false, false, false},
  {CoreOpKind::DyadicQuickMul,     "fputil::quick_mul",                          "Core.DyadicFloat.quickMul",     false, false, false, false},
  {CoreOpKind::DyadicPowN,         "fputil::pow_n",                              "Core.DyadicFloat.powN",         false, false, false, false},
  {CoreOpKind::DDExactAdd,         "fputil::exact_add",                          "Core.NumberPair.exactAdd",      true,  false, false, false},
  {CoreOpKind::DDExactSub,         "fputil::exact_sub",                          "Core.NumberPair.exactSub",      true,  false, false, false},
  {CoreOpKind::DDAdd,              "fputil::add",                                "Core.NumberPair.add",           true,  false, false, false},
  {CoreOpKind::DDSub,              "fputil::sub",                                "Core.NumberPair.sub",           true,  false, false, false},
  {CoreOpKind::DDExactMult,        "fputil::exact_mult",                         "Core.NumberPair.exactMult",     true,  true,  false, false},
  {CoreOpKind::DDQuickMult,        "fputil::quick_mult",                         "Core.NumberPair.quickMult",     true,  true,  false, false},
  {CoreOpKind::DDExactDiv,         "fputil::exact_div",                          "Core.NumberPair.div",           true,  true,  false, false},
  {CoreOpKind::DDExactDiv,         "fputil::div",                                "Core.NumberPair.div",           true,  true,  false, false},

  // C++ / Clang compiler builtins.
  {CoreOpKind::Abs,                "__builtin_fabsf",                            "Core.fabs",                     false, false, false, false},
  {CoreOpKind::Abs,                "__builtin_fabs",                             "Core.fabs",                     false, false, false, false},
  {CoreOpKind::Abs,                "__builtin_fabsl",                            "Core.fabs",                     false, false, false, false},
  {CoreOpKind::Sqrt,               "__builtin_sqrtf",                            "Core.fsqrt",                    true,  false, false, false},
  {CoreOpKind::Sqrt,               "__builtin_sqrt",                             "Core.fsqrt",                    true,  false, false, false},
  {CoreOpKind::Fma,                "__builtin_fmaf",                             "Core.fma",                      true,  false, false, false},
  {CoreOpKind::Fma,                "__builtin_fma",                              "Core.fma",                      true,  false, false, false},
  {CoreOpKind::CopySign,           "__builtin_copysignf",                        "Core.copysign",                 false, false, false, false},
  {CoreOpKind::CopySign,           "__builtin_copysign",                         "Core.copysign",                 false, false, false, false},
  {CoreOpKind::Clz,                "__builtin_clz",                              "BitVec.clz",                    false, false, false, false},
  {CoreOpKind::Clz,                "__builtin_clzl",                             "BitVec.clz",                    false, false, false, false},
  {CoreOpKind::Clz,                "__builtin_clzll",                            "BitVec.clz",                    false, false, false, false},
  {CoreOpKind::Ctz,                "__builtin_ctz",                              "BitVec.ctz",                    false, false, false, false},
  {CoreOpKind::Ctz,                "__builtin_ctzl",                             "BitVec.ctz",                    false, false, false, false},
  {CoreOpKind::Ctz,                "__builtin_ctzll",                            "BitVec.ctz",                    false, false, false, false},
  {CoreOpKind::Popcount,           "__builtin_popcount",                         "BitVec.cpop",                   false, false, false, false},
  {CoreOpKind::Popcount,           "__builtin_popcountl",                        "BitVec.cpop",                   false, false, false, false},
  {CoreOpKind::Popcount,           "__builtin_popcountll",                       "BitVec.cpop",                   false, false, false, false},
  {CoreOpKind::Min,                "cpp::min",                                   "min",                           false, false, false, false},
  {CoreOpKind::Max,                "cpp::max",                                   "max",                           false, false, false, false},
  {CoreOpKind::TransparentHint,    "__builtin_expect",                           "",                              false, false, false, true},
  {CoreOpKind::TransparentHint,    "__builtin_expect_with_probability",          "",                              false, false, false, true},
  {CoreOpKind::TransparentHint,    "details::expects_bool_condition",            "",                              false, false, false, true},
  {CoreOpKind::TransparentHint,    "internal::expects_bool_condition",           "",                              false, false, false, true},
  {CoreOpKind::TransparentHint,    "expects_bool_condition",                     "",                              false, false, false, true},
});

inline constexpr std::array kFPBitsMethods = std::to_array<CoreOpSpec>({
  {CoreOpKind::FPBitsUintval,          "uintval",               "Core.FPBits.uintval",          false, false, false, false},
  {CoreOpKind::FPBitsGetVal,           "get_val",               "Core.FPBits.getVal",           false, false, false, false},
  {CoreOpKind::FPBitsAbs,              "abs",                   "Core.FPBits.abs",              false, false, false, false},
  {CoreOpKind::FPBitsIsNeg,            "is_neg",                "Core.FPBits.isNeg",            false, false, false, false},
  {CoreOpKind::FPBitsIsPos,            "is_pos",                "Core.FPBits.isPos",            false, false, false, false},
  {CoreOpKind::FPBitsIsZero,           "is_zero",               "Core.FPBits.isZero",           false, false, false, false},
  {CoreOpKind::FPBitsIsInf,            "is_inf",                "Core.FPBits.isInf",            false, false, false, false},
  {CoreOpKind::FPBitsIsNan,            "is_nan",                "Core.FPBits.isNaN",            false, false, false, false},
  {CoreOpKind::FPBitsIsQuietNan,       "is_quiet_nan",          "Core.FPBits.isQuietNaN",       false, false, false, false},
  {CoreOpKind::FPBitsIsSignalingNan,   "is_signaling_nan",      "Core.FPBits.isSignalingNaN",   false, false, false, false},
  {CoreOpKind::FPBitsIsInfOrNan,       "is_inf_or_nan",         "Core.FPBits.isInfOrNaN",       false, false, false, false},
  {CoreOpKind::FPBitsIsSubnormal,      "is_subnormal",          "Core.FPBits.isSubnormal",      false, false, false, false},
  {CoreOpKind::FPBitsIsSubnormalOrZero,"is_subnormal_or_zero",  "Core.FPBits.isSubnormalOrZero",false, false, false, false},
  {CoreOpKind::FPBitsBiasedExp,        "get_biased_exponent",   "Core.FPBits.biasedExp",        false, false, false, false},
  {CoreOpKind::FPBitsExplicitExp,      "get_explicit_exponent", "Core.FPBits.explicitExponent", false, false, false, false},
  {CoreOpKind::FPBitsExplicitExp,      "get_exponent",          "Core.FPBits.explicitExponent", false, false, false, false},
  {CoreOpKind::FPBitsMantissa,         "get_mantissa",          "Core.FPBits.mantissa",         false, false, false, false},
  {CoreOpKind::FPBitsSign,             "sign",                  "Core.FPBits.sign",             false, false, false, false},
  {CoreOpKind::FPBitsSetSign,          "set_sign",              "Core.FPBits.setSign",          false, false, false, false},
  {CoreOpKind::FPBitsQuietNan,         "quiet_nan",             "Core.FPBits.quietNaN",         false, false, false, false},
  {CoreOpKind::FPBitsInf,              "inf",                   "Core.FPBits.inf",              false, false, false, false},
  {CoreOpKind::FPBitsZero,             "zero",                  "Core.FPBits.zero",             false, false, false, false},
  {CoreOpKind::FPBitsMaxNormal,        "max_normal",            "Core.FPBits.maxNormal",        false, false, false, false},
  {CoreOpKind::FPBitsMinSubnormal,     "min_subnormal",         "Core.FPBits.minSubnormal",     false, false, false, false},
  {CoreOpKind::FPBitsMinNormal,        "min_normal",            "Core.FPBits.minNormal",        false, false, false, false},
  {CoreOpKind::FPBitsOne,              "one",                   "Core.FPBits.one",              false, false, false, false},
  {CoreOpKind::FPBitsCreateValue,      "create_value",          "Core.FPBits.createValue",      false, false, false, false},
});

inline constexpr std::array kSignMethods = std::to_array<CoreOpSpec>({
  {CoreOpKind::SignIsPos, "is_pos", "Core.Sign.isPos", false, false, false, false},
  {CoreOpKind::SignIsNeg, "is_neg", "Core.Sign.isNeg", false, false, false, false},
});

inline constexpr std::array kDyadicMethods = std::to_array<CoreOpSpec>({
  {CoreOpKind::DyadicFastAs,     "fast_as",     "Core.DyadicFloat.asFloat",   true,  false, false, false},
  {CoreOpKind::DyadicGenericAs,  "generic_as",  "Core.DyadicFloat.asFloat",   true,  false, false, false},
  {CoreOpKind::DyadicAs,         "as",          "Core.DyadicFloat.asFloat",   true,  false, false, false},
  {CoreOpKind::DyadicNormalize,  "normalize",   "Core.DyadicFloat.normalize", false, false, false, false},
  {CoreOpKind::DyadicQuickAdd,   "quick_add",   "Core.DyadicFloat.quickAdd",  false, false, false, false},
  {CoreOpKind::DyadicQuickMul,   "quick_mul",   "Core.DyadicFloat.quickMul",  false, false, false, false},
});

inline constexpr std::array kExceptMethods = std::to_array<CoreOpSpec>({
  {CoreOpKind::ExceptLookup,    "lookup",     "Core.ExceptValues.lookup",    true, true, false, false},
  {CoreOpKind::ExceptLookupOdd, "lookup_odd", "Core.ExceptValues.lookupOdd", true, true, false, false},
});

inline constexpr std::array kOptionalMethods = std::to_array<CoreOpSpec>({
  {CoreOpKind::OptionalHasValue, "has_value", "Option.isSome", false, false, false, false},
  {CoreOpKind::OptionalValue,    "value",     "Option.get!",   false, false, false, false},
});

auto matchCoreType(std::string_view raw_qualified) -> std::optional<CoreTypeKind> {
  auto norm = normalizeQualifiedName(raw_qualified);
  constexpr std::array<std::pair<std::string_view, CoreTypeKind>, 17> kTypes = {{
    {"fputil::FPBits",              CoreTypeKind::FPBits},
    {"FPBits",                      CoreTypeKind::FPBits},
    {"fputil::internal::FPRepImpl", CoreTypeKind::FPBits},
    {"fputil::internal::FPRepSem",  CoreTypeKind::FPBits},
    {"fputil::internal::FPRepBase", CoreTypeKind::FPBits},
    {"fputil::internal::FPStorage", CoreTypeKind::FPBits},
    {"fputil::internal::FPBase",    CoreTypeKind::FPBits},
    {"fputil::DyadicFloat",         CoreTypeKind::DyadicFloat},
    {"DyadicFloat",                 CoreTypeKind::DyadicFloat},
    {"fputil::DoubleDouble",        CoreTypeKind::NumberPair},
    {"fputil::FloatFloat",          CoreTypeKind::NumberPair},
    {"NumberPair",                  CoreTypeKind::NumberPair},
    {"fputil::TripleDouble",        CoreTypeKind::TripleDouble},
    {"Frac64",                      CoreTypeKind::Frac64},
    {"fputil::ExceptValues",        CoreTypeKind::ExceptValues},
    {"cpp::optional",               CoreTypeKind::Optional},
    {"cpp::array",                  CoreTypeKind::Array},
  }};
  if (auto it = std::ranges::find_if(kTypes, [&](const auto &kv) {
        return matchesQualifiedSuffix(norm, kv.first);
      });
      it != kTypes.end()) {
    return it->second;
  }
  if (matchesQualifiedSuffix(norm, "Sign")) return CoreTypeKind::Sign;
  return std::nullopt;
}

auto matchFreeCoreOp(std::string_view raw_qualified) -> std::optional<CoreOpSpec> {
  auto norm = normalizeQualifiedName(raw_qualified);
  auto it = std::ranges::find_if(kFreeCoreOps, [&](const CoreOpSpec &spec) {
    return matchesQualifiedSuffix(norm, spec.cpp_suffix);
  });
  if (it != kFreeCoreOps.end()) return *it;
  return std::nullopt;
}

auto matchMethodCoreOp(CoreTypeKind owner, std::string_view method_name)
    -> std::optional<CoreOpSpec> {
  auto lookup = [method_name](const auto &table) -> std::optional<CoreOpSpec> {
    auto it = std::ranges::find_if(table, [method_name](const CoreOpSpec &spec) {
      return spec.cpp_suffix == method_name;
    });
    if (it != table.end()) return *it;
    return std::nullopt;
  };

  switch (owner) {
  case CoreTypeKind::FPBits:       return lookup(kFPBitsMethods);
  case CoreTypeKind::DyadicFloat:  return lookup(kDyadicMethods);
  case CoreTypeKind::ExceptValues: return lookup(kExceptMethods);
  case CoreTypeKind::Optional:     return lookup(kOptionalMethods);
  case CoreTypeKind::Sign:         return lookup(kSignMethods);
  default:                         return std::nullopt;
  }
}

} // namespace libc_extract
