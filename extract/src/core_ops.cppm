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
  case FloatFmt::Binary16:
    return 16;
  case FloatFmt::Binary32:
    return 32;
  case FloatFmt::Binary64:
    return 64;
  case FloatFmt::Binary128:
    return 128;
  }
  return 64;
}

constexpr auto floatFmtLean(FloatFmt fmt) -> std::string_view {
  switch (fmt) {
  case FloatFmt::Binary16:
    return ".binary16";
  case FloatFmt::Binary32:
    return ".binary32";
  case FloatFmt::Binary64:
    return ".binary64";
  case FloatFmt::Binary128:
    return ".binary128";
  }
  return ".binary64";
}

constexpr auto floatFmtShort(FloatFmt fmt) -> std::string_view {
  switch (fmt) {
  case FloatFmt::Binary16:
    return "f16";
  case FloatFmt::Binary32:
    return "f32";
  case FloatFmt::Binary64:
    return "f64";
  case FloatFmt::Binary128:
    return "f128";
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
      if (angle_depth > 0)
        --angle_depth;
    } else if (angle_depth == 0) {
      stripped.push_back(c);
    }
  }

  std::string_view sv = stripped;
  while (sv.starts_with("::"))
    sv.remove_prefix(2);

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
constexpr auto matchesQualifiedSuffix(std::string_view normalized, std::string_view suffix)
    -> bool {
  if (normalized == suffix)
    return true;
  if (normalized.size() <= suffix.size() + 2)
    return false;
  if (!normalized.ends_with(suffix))
    return false;
  auto sep_pos = normalized.size() - suffix.size() - 2;
  return normalized.substr(sep_pos, 2) == "::";
}

inline constexpr std::array kFreeCoreOps = std::to_array<CoreOpSpec>({
    // Rounding mode & FP environment queries / side effects.
    {CoreOpKind::QuickGetRound, "fputil::generic::quick_get_round", "Libc.quickGetRound", true,
     false, false, false},
    {CoreOpKind::QuickGetRound, "fputil::quick_get_round", "Libc.quickGetRound", true, false, false,
     false},
    {CoreOpKind::IsRoundUp, "fputil::generic::fenv_is_round_up", "Libc.isRoundUp", true, false,
     false, false},
    {CoreOpKind::IsRoundUp, "fputil::fenv_is_round_up", "Libc.isRoundUp", true, false, false,
     false},
    {CoreOpKind::IsRoundDown, "fputil::generic::fenv_is_round_down", "Libc.isRoundDown", true,
     false, false, false},
    {CoreOpKind::IsRoundDown, "fputil::fenv_is_round_down", "Libc.isRoundDown", true, false, false,
     false},
    {CoreOpKind::IsRoundToNearest, "fputil::generic::fenv_is_round_to_nearest",
     "Libc.isRoundToNearest", true, false, false, false},
    {CoreOpKind::IsRoundToNearest, "fputil::fenv_is_round_to_nearest", "Libc.isRoundToNearest",
     true, false, false, false},
    {CoreOpKind::IsRoundToZero, "fputil::generic::fenv_is_round_to_zero", "Libc.isRoundToZero",
     true, false, false, false},
    {CoreOpKind::IsRoundToZero, "fputil::fenv_is_round_to_zero", "Libc.isRoundToZero", true, false,
     false, false},
    {CoreOpKind::SetErrno, "fputil::set_errno_if_required", "Libc.setErrno", false, false, true,
     false},
    {CoreOpKind::RaiseExcept, "fputil::raise_except_if_required", "Libc.raiseExcept", false, false,
     true, false},
    {CoreOpKind::RaiseExcept, "fputil::raise_overflow_except_if_required", "Libc.raiseOverflow",
     false, false, true, false},
    {CoreOpKind::RaiseExcept, "fputil::raise_underflow_except_if_required", "Libc.raiseUnderflow",
     false, false, true, false},
    {CoreOpKind::ClearExcept, "fputil::clear_except_if_required", "Libc.clearExcept", false, false,
     true, false},
    {CoreOpKind::DoNotOptimize, "details::do_not_optimize", "", false, false, true, false},
    {CoreOpKind::DoNotOptimize, "details::do_not_optimize_impl", "", false, false, true, false},
    {CoreOpKind::SetOverflow, "fputil::set_overflow", "Libc.setOverflow", true, true, false, false},
    {CoreOpKind::SetUnderflow, "fputil::set_underflow", "Libc.setUnderflow", true, true, false,
     false},
    {CoreOpKind::RoundSlightlyUp, "fputil::round_result_slightly_up", "Libc.roundResultSlightlyUp",
     true, true, false, false},
    {CoreOpKind::RoundSlightlyDown, "fputil::round_result_slightly_down",
     "Libc.roundResultSlightlyDown", true, true, false, false},
    {CoreOpKind::IsConstantEvaluated, "cpp::is_constant_evaluated", "", false, false, false, false},
    {CoreOpKind::IsConstantEvaluated, "__builtin_is_constant_evaluated", "", false, false, false,
     false},

    // Elementary FP & rounding helpers.
    {CoreOpKind::NearestInt, "fputil::nearest_integer", "Libc.nearestInt", true, true, false,
     false},
    {CoreOpKind::RoundCurrentMode, "fputil::round_using_current_rounding_mode", "Libc.roundToInt",
     true, false, false, false},
    {CoreOpKind::RoundSpecificMode, "fputil::round_using_specific_rounding_mode",
     "Libc.roundToIntMode", false, false, false, false},
    {CoreOpKind::Floor, "fputil::floor", "Libc.floor", false, false, false, false},
    {CoreOpKind::Ceil, "fputil::ceil", "Libc.ceil", false, false, false, false},
    {CoreOpKind::Trunc, "fputil::trunc", "Libc.trunc", false, false, false, false},
    {CoreOpKind::Sqrt, "fputil::sqrt", "Libc.fsqrt", true, false, false, false},
    {CoreOpKind::MultiplyAdd, "fputil::multiply_add", "Libc.PolyElem.madd", true, true, false,
     false},
    {CoreOpKind::MultiplySub, "fputil::multiply_sub", "Libc.multiplySub", true, true, false, false},
    {CoreOpKind::SubMultiply, "fputil::sub_multiply", "Libc.PolyElem.subMul", true, true, false,
     false},
    {CoreOpKind::Fma, "fputil::fma", "Libc.fma", true, false, false, false},
    {CoreOpKind::Cast, "fputil::cast", "Libc.fpCast", true, false, false, false},
    {CoreOpKind::BitCast, "cpp::bit_cast", "Libc.bitCast", false, false, false, false},

    // Polynomial evaluation.
    {CoreOpKind::Polyeval, "fputil::polyeval", "Libc.polyevalList", true, true, false, false},
    {CoreOpKind::AltPolyeval, "fputil::altpolyeval", "Libc.altpolyevalList", true, true, false,
     false},
    {CoreOpKind::Estrin, "fputil::estrin", "Libc.estrin", true, true, false, false},
    {CoreOpKind::Estrin, "fputil::estrin_polyeval", "Libc.estrin", true, true, false, false},
    {CoreOpKind::Estrin, "estrin_polyeval", "Libc.estrin", true, true, false, false},

    // Free DyadicFloat / NumberPair helpers.
    {CoreOpKind::DyadicQuickAdd, "fputil::quick_add", "Libc.DyadicFloat.quickAdd", false, false,
     false, false},
    {CoreOpKind::DyadicQuickMul, "fputil::quick_mul", "Libc.DyadicFloat.quickMul", false, false,
     false, false},
    {CoreOpKind::DyadicPowN, "fputil::pow_n", "Libc.DyadicFloat.powN", false, false, false, false},
    {CoreOpKind::DDExactAdd, "fputil::exact_add", "Libc.NumberPair.exactAdd", true, false, false,
     false},
    {CoreOpKind::DDExactSub, "fputil::exact_sub", "Libc.NumberPair.exactSub", true, false, false,
     false},
    {CoreOpKind::DDAdd, "fputil::add", "Libc.NumberPair.add", true, false, false, false},
    {CoreOpKind::DDSub, "fputil::sub", "Libc.NumberPair.sub", true, false, false, false},
    {CoreOpKind::DDExactMult, "fputil::exact_mult", "Libc.NumberPair.exactMult", true, true, false,
     false},
    {CoreOpKind::DDQuickMult, "fputil::quick_mult", "Libc.NumberPair.quickMult", true, true, false,
     false},
    {CoreOpKind::DDExactDiv, "fputil::exact_div", "Libc.NumberPair.div", true, true, false, false},
    {CoreOpKind::DDExactDiv, "fputil::div", "Libc.NumberPair.div", true, true, false, false},

    // C++ / Clang compiler builtins.
    {CoreOpKind::Abs, "__builtin_fabsf", "Libc.fabs", false, false, false, false},
    {CoreOpKind::Abs, "__builtin_fabs", "Libc.fabs", false, false, false, false},
    {CoreOpKind::Abs, "__builtin_fabsl", "Libc.fabs", false, false, false, false},
    {CoreOpKind::Sqrt, "__builtin_sqrtf", "Libc.fsqrt", true, false, false, false},
    {CoreOpKind::Sqrt, "__builtin_sqrt", "Libc.fsqrt", true, false, false, false},
    {CoreOpKind::Fma, "__builtin_fmaf", "Libc.fma", true, false, false, false},
    {CoreOpKind::Fma, "__builtin_fma", "Libc.fma", true, false, false, false},
    {CoreOpKind::CopySign, "__builtin_copysignf", "Libc.copysign", false, false, false, false},
    {CoreOpKind::CopySign, "__builtin_copysign", "Libc.copysign", false, false, false, false},
    {CoreOpKind::Clz, "__builtin_clz", "BitVec.clz", false, false, false, false},
    {CoreOpKind::Clz, "__builtin_clzl", "BitVec.clz", false, false, false, false},
    {CoreOpKind::Clz, "__builtin_clzll", "BitVec.clz", false, false, false, false},
    {CoreOpKind::Ctz, "__builtin_ctz", "BitVec.ctz", false, false, false, false},
    {CoreOpKind::Ctz, "__builtin_ctzl", "BitVec.ctz", false, false, false, false},
    {CoreOpKind::Ctz, "__builtin_ctzll", "BitVec.ctz", false, false, false, false},
    {CoreOpKind::Popcount, "__builtin_popcount", "BitVec.cpop", false, false, false, false},
    {CoreOpKind::Popcount, "__builtin_popcountl", "BitVec.cpop", false, false, false, false},
    {CoreOpKind::Popcount, "__builtin_popcountll", "BitVec.cpop", false, false, false, false},
    {CoreOpKind::Min, "cpp::min", "min", false, false, false, false},
    {CoreOpKind::Max, "cpp::max", "max", false, false, false, false},
    {CoreOpKind::TransparentHint, "__builtin_expect", "", false, false, false, true},
    {CoreOpKind::TransparentHint, "__builtin_expect_with_probability", "", false, false, false,
     true},
    {CoreOpKind::TransparentHint, "details::expects_bool_condition", "", false, false, false, true},
    {CoreOpKind::TransparentHint, "internal::expects_bool_condition", "", false, false, false,
     true},
    {CoreOpKind::TransparentHint, "expects_bool_condition", "", false, false, false, true},
});

inline constexpr std::array kFPBitsMethods = std::to_array<CoreOpSpec>({
    {CoreOpKind::FPBitsUintval, "uintval", "Libc.FPBits.uintval", false, false, false, false},
    {CoreOpKind::FPBitsGetVal, "get_val", "Libc.FPBits.getVal", false, false, false, false},
    {CoreOpKind::FPBitsAbs, "abs", "Libc.FPBits.abs", false, false, false, false},
    {CoreOpKind::FPBitsIsNeg, "is_neg", "Libc.FPBits.isNeg", false, false, false, false},
    {CoreOpKind::FPBitsIsPos, "is_pos", "Libc.FPBits.isPos", false, false, false, false},
    {CoreOpKind::FPBitsIsZero, "is_zero", "Libc.FPBits.isZero", false, false, false, false},
    {CoreOpKind::FPBitsIsInf, "is_inf", "Libc.FPBits.isInf", false, false, false, false},
    {CoreOpKind::FPBitsIsNan, "is_nan", "Libc.FPBits.isNaN", false, false, false, false},
    {CoreOpKind::FPBitsIsQuietNan, "is_quiet_nan", "Libc.FPBits.isQuietNaN", false, false, false,
     false},
    {CoreOpKind::FPBitsIsSignalingNan, "is_signaling_nan", "Libc.FPBits.isSignalingNaN", false,
     false, false, false},
    {CoreOpKind::FPBitsIsInfOrNan, "is_inf_or_nan", "Libc.FPBits.isInfOrNaN", false, false, false,
     false},
    {CoreOpKind::FPBitsIsSubnormal, "is_subnormal", "Libc.FPBits.isSubnormal", false, false, false,
     false},
    {CoreOpKind::FPBitsIsSubnormalOrZero, "is_subnormal_or_zero", "Libc.FPBits.isSubnormalOrZero",
     false, false, false, false},
    {CoreOpKind::FPBitsBiasedExp, "get_biased_exponent", "Libc.FPBits.biasedExp", false, false,
     false, false},
    {CoreOpKind::FPBitsExplicitExp, "get_explicit_exponent", "Libc.FPBits.explicitExponent", false,
     false, false, false},
    {CoreOpKind::FPBitsExplicitExp, "get_exponent", "Libc.FPBits.explicitExponent", false, false,
     false, false},
    {CoreOpKind::FPBitsMantissa, "get_mantissa", "Libc.FPBits.mantissa", false, false, false,
     false},
    {CoreOpKind::FPBitsSign, "sign", "Libc.FPBits.sign", false, false, false, false},
    {CoreOpKind::FPBitsSetSign, "set_sign", "Libc.FPBits.setSign", false, false, false, false},
    {CoreOpKind::FPBitsQuietNan, "quiet_nan", "Libc.FPBits.quietNaN", false, false, false, false},
    {CoreOpKind::FPBitsInf, "inf", "Libc.FPBits.inf", false, false, false, false},
    {CoreOpKind::FPBitsZero, "zero", "Libc.FPBits.zero", false, false, false, false},
    {CoreOpKind::FPBitsMaxNormal, "max_normal", "Libc.FPBits.maxNormal", false, false, false,
     false},
    {CoreOpKind::FPBitsMinSubnormal, "min_subnormal", "Libc.FPBits.minSubnormal", false, false,
     false, false},
    {CoreOpKind::FPBitsMinNormal, "min_normal", "Libc.FPBits.minNormal", false, false, false,
     false},
    {CoreOpKind::FPBitsOne, "one", "Libc.FPBits.one", false, false, false, false},
    {CoreOpKind::FPBitsCreateValue, "create_value", "Libc.FPBits.createValue", false, false, false,
     false},
});

inline constexpr std::array kSignMethods = std::to_array<CoreOpSpec>({
    {CoreOpKind::SignIsPos, "is_pos", "Libc.Sign.isPos", false, false, false, false},
    {CoreOpKind::SignIsNeg, "is_neg", "Libc.Sign.isNeg", false, false, false, false},
});

inline constexpr std::array kDyadicMethods = std::to_array<CoreOpSpec>({
    {CoreOpKind::DyadicFastAs, "fast_as", "Libc.DyadicFloat.asFloat", true, false, false, false},
    {CoreOpKind::DyadicGenericAs, "generic_as", "Libc.DyadicFloat.asFloat", true, false, false,
     false},
    {CoreOpKind::DyadicAs, "as", "Libc.DyadicFloat.asFloat", true, false, false, false},
    {CoreOpKind::DyadicNormalize, "normalize", "Libc.DyadicFloat.normalize", false, false, false,
     false},
    {CoreOpKind::DyadicQuickAdd, "quick_add", "Libc.DyadicFloat.quickAdd", false, false, false,
     false},
    {CoreOpKind::DyadicQuickMul, "quick_mul", "Libc.DyadicFloat.quickMul", false, false, false,
     false},
});

inline constexpr std::array kExceptMethods = std::to_array<CoreOpSpec>({
    {CoreOpKind::ExceptLookup, "lookup", "Libc.ExceptValues.lookup", true, true, false, false},
    {CoreOpKind::ExceptLookupOdd, "lookup_odd", "Libc.ExceptValues.lookupOdd", true, true, false,
     false},
});

inline constexpr std::array kOptionalMethods = std::to_array<CoreOpSpec>({
    {CoreOpKind::OptionalHasValue, "has_value", "Option.isSome", false, false, false, false},
    {CoreOpKind::OptionalValue, "value", "Option.get!", false, false, false, false},
});

auto matchCoreType(std::string_view raw_qualified) -> std::optional<CoreTypeKind> {
  auto norm = normalizeQualifiedName(raw_qualified);
  constexpr std::array<std::pair<std::string_view, CoreTypeKind>, 17> kTypes = {{
      {"fputil::FPBits", CoreTypeKind::FPBits},
      {"FPBits", CoreTypeKind::FPBits},
      {"fputil::internal::FPRepImpl", CoreTypeKind::FPBits},
      {"fputil::internal::FPRepSem", CoreTypeKind::FPBits},
      {"fputil::internal::FPRepBase", CoreTypeKind::FPBits},
      {"fputil::internal::FPStorage", CoreTypeKind::FPBits},
      {"fputil::internal::FPBase", CoreTypeKind::FPBits},
      {"fputil::DyadicFloat", CoreTypeKind::DyadicFloat},
      {"DyadicFloat", CoreTypeKind::DyadicFloat},
      {"fputil::DoubleDouble", CoreTypeKind::NumberPair},
      {"fputil::FloatFloat", CoreTypeKind::NumberPair},
      {"NumberPair", CoreTypeKind::NumberPair},
      {"fputil::TripleDouble", CoreTypeKind::TripleDouble},
      {"Frac64", CoreTypeKind::Frac64},
      {"fputil::ExceptValues", CoreTypeKind::ExceptValues},
      {"cpp::optional", CoreTypeKind::Optional},
      {"cpp::array", CoreTypeKind::Array},
  }};
  if (auto it = std::ranges::find_if(
          kTypes, [&](const auto &kv) { return matchesQualifiedSuffix(norm, kv.first); });
      it != kTypes.end()) {
    return it->second;
  }
  if (matchesQualifiedSuffix(norm, "Sign"))
    return CoreTypeKind::Sign;
  return std::nullopt;
}

auto matchFreeCoreOp(std::string_view raw_qualified) -> std::optional<CoreOpSpec> {
  auto norm = normalizeQualifiedName(raw_qualified);
  auto it = std::ranges::find_if(kFreeCoreOps, [&](const CoreOpSpec &spec) {
    return matchesQualifiedSuffix(norm, spec.cpp_suffix);
  });
  if (it != kFreeCoreOps.end())
    return *it;
  return std::nullopt;
}

auto matchMethodCoreOp(CoreTypeKind owner, std::string_view method_name)
    -> std::optional<CoreOpSpec> {
  auto lookup = [method_name](const auto &table) -> std::optional<CoreOpSpec> {
    auto it = std::ranges::find_if(
        table, [method_name](const CoreOpSpec &spec) { return spec.cpp_suffix == method_name; });
    if (it != table.end())
      return *it;
    return std::nullopt;
  };

  switch (owner) {
  case CoreTypeKind::FPBits:
    return lookup(kFPBitsMethods);
  case CoreTypeKind::DyadicFloat:
    return lookup(kDyadicMethods);
  case CoreTypeKind::ExceptValues:
    return lookup(kExceptMethods);
  case CoreTypeKind::Optional:
    return lookup(kOptionalMethods);
  case CoreTypeKind::Sign:
    return lookup(kSignMethods);
  default:
    return std::nullopt;
  }
}

} // namespace libc_extract
