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
  NormalFloat,
  DyadicFloat,
  NumberPair,
  TripleDouble,
  Frac64,
  ExceptValues,
  Optional,
  Array,
  Sign,
  BigInt,
};

enum class CoreOpKind : std::uint8_t {
  // Rounding mode and FP environment queries or side effects.
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

  // Elementary FP, rounding, IEEE manipulation, and extrema helpers.
  NearestInt,
  RoundCurrentMode,
  RoundSpecificMode,
  Floor,
  Ceil,
  Trunc,
  Round,
  RoundEven,
  IsInteger,
  IsOddInteger,
  Ldexp,
  Logb,
  IntLogb,
  Remainder,
  NextUp,
  NextDown,
  NextAfter,
  Fmax,
  Fmin,
  Fmaximum,
  Fminimum,
  FmaximumNum,
  FminimumNum,
  FmaximumMag,
  FminimumMag,
  FmaximumMagNum,
  FminimumMagNum,
  GetPayload,
  SetPayload,
  SetPayloadSig,
  TotalOrder,
  TotalOrderMag,
  FpAnd,
  FpOr,
  FpXor,
  FpAndNot,
  Sqrt,
  Abs,
  CopySign,
  IsNanBuiltin,
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

  // BigInt / UInt operations.
  BigIntIsZero,
  BigIntQuickMulHi,
  BigIntGetBit,
  BigIntSetBit,
  BigIntAddOverflow,
  BigIntOfLimbs64,

  // DyadicFloat<N> operations.
  DyadicZero,
  DyadicMkNorm,
  DyadicFromFloat,
  DyadicQuickAdd,
  DyadicQuickSub,
  DyadicQuickMul,
  DyadicRoundedMul,
  DyadicApproxReciprocal,
  DyadicMulPow2,
  DyadicRound,
  DyadicAdd,
  DyadicSub,
  DyadicMul,
  DyadicNeg,
  DyadicPowN,
  DyadicShiftLeft,
  DyadicShiftRight,
  DyadicNormalize,
  DyadicGetUnbiasedExp,
  DyadicFastAs,
  DyadicGenericAs,
  DyadicAs,

  // NumberPair (DoubleDouble / FloatFloat) operations.
  DDExactAdd,
  DDExactSub,
  DDAdd,
  DDSub,
  DDSplit,
  DDExactMult,
  DDExactMultPresplit,
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
  FPBitsNeg,
  FPBitsCopySign,
  FPBitsIsNeg,
  FPBitsIsPos,
  FPBitsIsZero,
  FPBitsIsInf,
  FPBitsIsNan,
  FPBitsIsQuietNan,
  FPBitsIsSignalingNan,
  FPBitsIsFinite,
  FPBitsIsNormal,
  FPBitsIsInfOrNan,
  FPBitsIsSubnormal,
  FPBitsIsSubnormalOrZero,
  FPBitsBiasedExp,
  FPBitsExp,
  FPBitsExplicitExp,
  FPBitsMantissa,
  FPBitsExplicitMantissa,
  FPBitsSign,
  FPBitsSetSign,
  FPBitsSetBiasedExp,
  FPBitsSetMantissa,
  FPBitsSetUintval,
  FPBitsQuietNan,
  FPBitsSignalingNan,
  FPBitsInf,
  FPBitsZero,
  FPBitsMaxNormal,
  FPBitsMinSubnormal,
  FPBitsMaxSubnormal,
  FPBitsMinNormal,
  FPBitsOne,
  FPBitsCreateValue,

  // NormalFloat<T> operations.
  NormalFloatOfVal,
  NormalFloatOfBits,
  NormalFloatMkNorm,
  NormalFloatToVal,
  NormalFloatMul2,
  NormalFloatCmp,

  // Integer bit-manipulation intrinsics.
  Clz,
  Ctz,
  Popcount,
  HasSingleBit,
  BitWidth,
  Min,
  Max,
  AbsInt,

  // Optional, Sign, and branch-prediction wrappers.
  OptionalHasValue,
  OptionalValue,
  OptionalNone,
  OptionalSome,
  SignIsPos,
  SignIsNeg,
  SignNegate,
  TransparentHint,
};

/// Returns true if a member core operation mutates its receiver in C++.
constexpr auto isMutatingCoreOp(CoreOpKind kind) -> bool {
  switch (kind) {
  case CoreOpKind::FPBitsSetSign:
  case CoreOpKind::FPBitsSetBiasedExp:
  case CoreOpKind::FPBitsSetMantissa:
  case CoreOpKind::FPBitsSetUintval:
  case CoreOpKind::DyadicNormalize:
  case CoreOpKind::DyadicShiftLeft:
  case CoreOpKind::DyadicShiftRight:
  case CoreOpKind::BigIntSetBit:
    return true;
  default:
    return false;
  }
}

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
    // Rounding mode and FP environment queries or side effects.
    {CoreOpKind::QuickGetRound, "fputil::generic::quick_get_round", "Libc.quickGetRound", true,
     false, false, false},
    {CoreOpKind::QuickGetRound, "fputil::quick_get_round", "Libc.quickGetRound", true, false, false,
     false},
    {CoreOpKind::QuickGetRound, "fputil::get_round", "Libc.quickGetRound", true, false, false,
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

    // Elementary FP, rounding, IEEE manipulation, and extrema helpers.
    {CoreOpKind::NearestInt, "fputil::nearest_integer", "Libc.nearestInt", true, true, false,
     false},
    {CoreOpKind::RoundCurrentMode, "fputil::round_using_current_rounding_mode", "Libc.roundToInt",
     true, true, false, false},
    {CoreOpKind::RoundSpecificMode, "fputil::round_using_specific_rounding_mode",
     "Libc.roundToIntMode", false, false, false, false},
    {CoreOpKind::Floor, "fputil::floor", "Libc.floor", false, false, false, false},
    {CoreOpKind::Ceil, "fputil::ceil", "Libc.ceil", false, false, false, false},
    {CoreOpKind::Trunc, "fputil::trunc", "Libc.trunc", false, false, false, false},
    {CoreOpKind::Round, "fputil::round", "Libc.round", false, false, false, false},
    {CoreOpKind::RoundEven, "fputil::roundeven", "Libc.roundEven", false, false, false, false},
    {CoreOpKind::IsInteger, "fputil::is_integer", "Libc.isInteger", false, false, false, false},
    {CoreOpKind::IsOddInteger, "fputil::is_odd_integer", "Libc.isOddInteger", false, false, false,
     false},
    {CoreOpKind::Ldexp, "fputil::ldexp", "Libc.ldexp", true, true, false, false},
    {CoreOpKind::Ldexp, "fputil::scale_exp2", "Libc.ldexp", true, true, false, false},
    {CoreOpKind::Logb, "fputil::logb", "Libc.logb", false, false, false, false},
    {CoreOpKind::IntLogb, "fputil::intlogb", "Libc.intlogb", false, true, false, false},
    {CoreOpKind::Remainder, "fputil::remainder", "Libc.remainder", false, false, false, false},
    {CoreOpKind::NextUp, "fputil::nextupdown", "Libc.nextUp", false, false, false, false},
    {CoreOpKind::NextAfter, "fputil::nextafter", "Libc.nextAfter", false, false, false, false},
    {CoreOpKind::Fmax, "fputil::fmax", "Libc.fmax", false, false, false, false},
    {CoreOpKind::Fmin, "fputil::fmin", "Libc.fmin", false, false, false, false},
    {CoreOpKind::Fmaximum, "fputil::fmaximum", "Libc.fmaximum", false, false, false, false},
    {CoreOpKind::Fminimum, "fputil::fminimum", "Libc.fminimum", false, false, false, false},
    {CoreOpKind::FmaximumNum, "fputil::fmaximum_num", "Libc.fmaximumNum", false, false, false,
     false},
    {CoreOpKind::FminimumNum, "fputil::fminimum_num", "Libc.fminimumNum", false, false, false,
     false},
    {CoreOpKind::FmaximumMag, "fputil::fmaximum_mag", "Libc.fmaximumMag", false, false, false,
     false},
    {CoreOpKind::FminimumMag, "fputil::fminimum_mag", "Libc.fminimumMag", false, false, false,
     false},
    {CoreOpKind::FmaximumMagNum, "fputil::fmaximum_mag_num", "Libc.fmaximumMagNum", false, false,
     false, false},
    {CoreOpKind::FminimumMagNum, "fputil::fminimum_mag_num", "Libc.fminimumMagNum", false, false,
     false, false},
    {CoreOpKind::GetPayload, "fputil::getpayload", "Libc.getPayload", false, false, false, false},
    {CoreOpKind::TotalOrder, "fputil::totalorder", "Libc.totalOrder", false, false, false, false},
    {CoreOpKind::TotalOrderMag, "fputil::totalordermag", "Libc.totalOrderMag", false, false, false,
     false},
    {CoreOpKind::FpAnd, "fputil::fp_and", "Libc.fpAnd", false, false, false, false},
    {CoreOpKind::FpOr, "fputil::fp_or", "Libc.fpOr", false, false, false, false},
    {CoreOpKind::FpXor, "fputil::fp_xor", "Libc.fpXor", false, false, false, false},
    {CoreOpKind::FpAndNot, "fputil::fp_andnot", "Libc.fpAndNot", false, false, false, false},
    {CoreOpKind::Abs, "fputil::abs", "Libc.fabs", false, false, false, false},
    {CoreOpKind::CopySign, "fputil::copysign", "Libc.copysign", false, false, false, false},
    {CoreOpKind::Sqrt, "fputil::sqrt", "Libc.fsqrt", true, false, false, false},
    {CoreOpKind::MultiplyAdd, "fputil::multiply_add", "Libc.PolyElem.madd", true, true, false,
     false},
    {CoreOpKind::MultiplySub, "fputil::multiply_sub", "Libc.PolyElem.msub", true, true, false,
     false},
    {CoreOpKind::SubMultiply, "fputil::sub_multiply", "Libc.PolyElem.subMul", true, true, false,
     false},
    {CoreOpKind::Fma, "fputil::fma", "Libc.fma", true, false, false, false},
    {CoreOpKind::Cast, "fputil::cast", "Libc.fpCast", true, false, false, false},
    {CoreOpKind::BitCast, "cpp::bit_cast", "Libc.bitCast", false, false, false, false},

    // Polynomial evaluation.
    {CoreOpKind::Polyeval, "fputil::polyeval", "Libc.polyevalList", true, true, false, false},
    {CoreOpKind::Polyeval, "fputil::loop_polyeval", "Libc.polyevalList", true, true, false, false},
    {CoreOpKind::AltPolyeval, "fputil::altpolyeval", "Libc.altpolyevalList", true, true, false,
     false},
    {CoreOpKind::AltPolyeval, "fputil::loop_altpolyeval", "Libc.altpolyevalList", true, true, false,
     false},
    {CoreOpKind::Estrin, "fputil::estrin", "Libc.estrin", true, true, false, false},
    {CoreOpKind::Estrin, "fputil::estrin_polyeval", "Libc.estrin", true, true, false, false},
    {CoreOpKind::Estrin, "estrin_polyeval", "Libc.estrin", true, true, false, false},

    // Free DyadicFloat and NumberPair helpers.
    {CoreOpKind::DyadicQuickAdd, "fputil::quick_add", "Libc.DyadicFloat.quickAdd", false, false,
     false, false},
    {CoreOpKind::DyadicQuickSub, "fputil::quick_sub", "Libc.DyadicFloat.quickSub", false, false,
     false, false},
    {CoreOpKind::DyadicQuickMul, "fputil::quick_mul", "Libc.DyadicFloat.quickMul", false, true,
     false, false},
    {CoreOpKind::DyadicRoundedMul, "fputil::rounded_mul", "Libc.DyadicFloat.roundedMul", true, true,
     false, false},
    {CoreOpKind::DyadicApproxReciprocal, "fputil::approx_reciprocal",
     "Libc.DyadicFloat.approxReciprocal", false, true, false, false},
    {CoreOpKind::DyadicMulPow2, "fputil::mul_pow_2", "Libc.DyadicFloat.mulPow2", false, false,
     false, false},
    {CoreOpKind::DyadicPowN, "fputil::pow_n", "Libc.DyadicFloat.powN", false, true, false, false},
    {CoreOpKind::DDExactAdd, "fputil::exact_add", "Libc.NumberPair.exactAdd", true, false, false,
     false},
    {CoreOpKind::DDExactSub, "fputil::exact_sub", "Libc.NumberPair.exactSub", true, false, false,
     false},
    {CoreOpKind::DDAdd, "fputil::add", "Libc.NumberPair.add", true, false, false, false},
    {CoreOpKind::DDSub, "fputil::sub", "Libc.NumberPair.sub", true, false, false, false},
    {CoreOpKind::DDSplit, "fputil::split", "Libc.NumberPair.split", true, false, false, false},
    {CoreOpKind::DDExactMult, "fputil::exact_mult", "Libc.NumberPair.exactMult", true, true, false,
     false},
    {CoreOpKind::DDQuickMult, "fputil::quick_mult", "Libc.NumberPair.quickMult", true, true, false,
     false},
    {CoreOpKind::DDExactDiv, "fputil::exact_div", "Libc.NumberPair.div", true, true, false, false},
    {CoreOpKind::DDExactDiv, "fputil::div", "Libc.NumberPair.div", true, true, false, false},

    // C++ and Clang compiler builtins.
    {CoreOpKind::Abs, "__builtin_fabsf16", "Libc.fabs", false, false, false, false},
    {CoreOpKind::Abs, "__builtin_fabsf", "Libc.fabs", false, false, false, false},
    {CoreOpKind::Abs, "__builtin_fabs", "Libc.fabs", false, false, false, false},
    {CoreOpKind::Abs, "__builtin_fabsl", "Libc.fabs", false, false, false, false},
    {CoreOpKind::Sqrt, "__builtin_sqrtf", "Libc.fsqrt", true, false, false, false},
    {CoreOpKind::Sqrt, "__builtin_sqrt", "Libc.fsqrt", true, false, false, false},
    {CoreOpKind::Sqrt, "__builtin_elementwise_sqrt", "Libc.fsqrt", true, false, false, false},
    {CoreOpKind::Fma, "__builtin_fmaf", "Libc.fma", true, false, false, false},
    {CoreOpKind::Fma, "__builtin_fma", "Libc.fma", true, false, false, false},
    {CoreOpKind::Fma, "__builtin_elementwise_fma", "Libc.fma", true, false, false, false},
    {CoreOpKind::CopySign, "__builtin_copysignf16", "Libc.copysign", false, false, false, false},
    {CoreOpKind::CopySign, "__builtin_copysignf", "Libc.copysign", false, false, false, false},
    {CoreOpKind::CopySign, "__builtin_copysign", "Libc.copysign", false, false, false, false},
    {CoreOpKind::Floor, "__builtin_floorf", "Libc.floor", false, false, false, false},
    {CoreOpKind::Floor, "__builtin_floor", "Libc.floor", false, false, false, false},
    {CoreOpKind::Ceil, "__builtin_ceilf", "Libc.ceil", false, false, false, false},
    {CoreOpKind::Ceil, "__builtin_ceil", "Libc.ceil", false, false, false, false},
    {CoreOpKind::Trunc, "__builtin_truncf", "Libc.trunc", false, false, false, false},
    {CoreOpKind::Trunc, "__builtin_trunc", "Libc.trunc", false, false, false, false},
    {CoreOpKind::Round, "__builtin_roundf", "Libc.round", false, false, false, false},
    {CoreOpKind::Round, "__builtin_round", "Libc.round", false, false, false, false},
    {CoreOpKind::RoundEven, "__builtin_roundevenf", "Libc.roundEven", false, false, false, false},
    {CoreOpKind::RoundEven, "__builtin_roundeven", "Libc.roundEven", false, false, false, false},
    {CoreOpKind::RoundCurrentMode, "__builtin_rintf", "Libc.roundToInt", true, true, false, false},
    {CoreOpKind::RoundCurrentMode, "__builtin_rint", "Libc.roundToInt", true, true, false, false},
    {CoreOpKind::RoundCurrentMode, "__builtin_nearbyintf", "Libc.roundToInt", true, true, false,
     false},
    {CoreOpKind::RoundCurrentMode, "__builtin_nearbyint", "Libc.roundToInt", true, true, false,
     false},
    {CoreOpKind::Fmax, "__builtin_fmaxf", "Libc.fmax", false, false, false, false},
    {CoreOpKind::Fmax, "__builtin_fmax", "Libc.fmax", false, false, false, false},
    {CoreOpKind::Fmin, "__builtin_fminf", "Libc.fmin", false, false, false, false},
    {CoreOpKind::Fmin, "__builtin_fmin", "Libc.fmin", false, false, false, false},
    {CoreOpKind::IsNanBuiltin, "__builtin_isnan", "Libc.FPBits.isNaN", false, false, false, false},
    {CoreOpKind::Clz, "__builtin_clz", "Libc.countlZero", false, false, false, false},
    {CoreOpKind::Clz, "__builtin_clzl", "Libc.countlZero", false, false, false, false},
    {CoreOpKind::Clz, "__builtin_clzll", "Libc.countlZero", false, false, false, false},
    {CoreOpKind::Clz, "__builtin_clzg", "Libc.countlZero", false, false, false, false},
    {CoreOpKind::Clz, "cpp::countl_zero", "Libc.countlZero", false, false, false, false},
    {CoreOpKind::Ctz, "__builtin_ctz", "Libc.countrZero", false, false, false, false},
    {CoreOpKind::Ctz, "__builtin_ctzl", "Libc.countrZero", false, false, false, false},
    {CoreOpKind::Ctz, "__builtin_ctzll", "Libc.countrZero", false, false, false, false},
    {CoreOpKind::Ctz, "__builtin_ctzg", "Libc.countrZero", false, false, false, false},
    {CoreOpKind::Ctz, "cpp::countr_zero", "Libc.countrZero", false, false, false, false},
    {CoreOpKind::Popcount, "__builtin_popcount", "Libc.popcount", false, false, false, false},
    {CoreOpKind::Popcount, "__builtin_popcountl", "Libc.popcount", false, false, false, false},
    {CoreOpKind::Popcount, "__builtin_popcountll", "Libc.popcount", false, false, false, false},
    {CoreOpKind::Popcount, "__builtin_popcountg", "Libc.popcount", false, false, false, false},
    {CoreOpKind::Popcount, "cpp::popcount", "Libc.popcount", false, false, false, false},
    {CoreOpKind::HasSingleBit, "cpp::has_single_bit", "Libc.hasSingleBit", false, false, false,
     false},
    {CoreOpKind::BitWidth, "cpp::bit_width", "Libc.bitWidth", false, false, false, false},
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
    {CoreOpKind::FPBitsNeg, "neg", "Libc.FPBits.neg", false, false, false, false},
    {CoreOpKind::FPBitsCopySign, "copy_sign", "Libc.FPBits.copySign", false, false, false, false},
    {CoreOpKind::FPBitsIsNeg, "is_neg", "Libc.FPBits.isNeg", false, false, false, false},
    {CoreOpKind::FPBitsIsPos, "is_pos", "Libc.FPBits.isPos", false, false, false, false},
    {CoreOpKind::FPBitsIsZero, "is_zero", "Libc.FPBits.isZero", false, false, false, false},
    {CoreOpKind::FPBitsIsInf, "is_inf", "Libc.FPBits.isInf", false, false, false, false},
    {CoreOpKind::FPBitsIsNan, "is_nan", "Libc.FPBits.isNaN", false, false, false, false},
    {CoreOpKind::FPBitsIsQuietNan, "is_quiet_nan", "Libc.FPBits.isQuietNaN", false, false, false,
     false},
    {CoreOpKind::FPBitsIsSignalingNan, "is_signaling_nan", "Libc.FPBits.isSignalingNaN", false,
     false, false, false},
    {CoreOpKind::FPBitsIsFinite, "is_finite", "Libc.FPBits.isFinite", false, false, false, false},
    {CoreOpKind::FPBitsIsNormal, "is_normal", "Libc.FPBits.isNormal", false, false, false, false},
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
    {CoreOpKind::FPBitsExp, "get_exponent", "Libc.FPBits.exponent", false, false, false, false},
    {CoreOpKind::FPBitsMantissa, "get_mantissa", "Libc.FPBits.mantissa", false, false, false,
     false},
    {CoreOpKind::FPBitsExplicitMantissa, "get_explicit_mantissa", "Libc.FPBits.explicitMantissa",
     false, false, false, false},
    {CoreOpKind::FPBitsSign, "sign", "Libc.FPBits.sign", false, false, false, false},
    {CoreOpKind::FPBitsSetSign, "set_sign", "Libc.FPBits.setSign", false, false, false, false},
    {CoreOpKind::FPBitsSetBiasedExp, "set_biased_exponent", "Libc.FPBits.setBiasedExp", false,
     false, false, false},
    {CoreOpKind::FPBitsSetMantissa, "set_mantissa", "Libc.FPBits.setMantissa", false, false, false,
     false},
    {CoreOpKind::FPBitsSetMantissa, "set_significand", "Libc.FPBits.setMantissa", false, false,
     false, false},
    {CoreOpKind::FPBitsSetUintval, "set_uintval", "Libc.FPBits.setUintval", false, false, false,
     false},
    {CoreOpKind::FPBitsQuietNan, "quiet_nan", "Libc.FPBits.quietNaN", false, false, false, false},
    {CoreOpKind::FPBitsSignalingNan, "signaling_nan", "Libc.FPBits.signalingNaN", false, false,
     false, false},
    {CoreOpKind::FPBitsInf, "inf", "Libc.FPBits.inf", false, false, false, false},
    {CoreOpKind::FPBitsZero, "zero", "Libc.FPBits.zero", false, false, false, false},
    {CoreOpKind::FPBitsMaxNormal, "max_normal", "Libc.FPBits.maxNormal", false, false, false,
     false},
    {CoreOpKind::FPBitsMinSubnormal, "min_subnormal", "Libc.FPBits.minSubnormal", false, false,
     false, false},
    {CoreOpKind::FPBitsMaxSubnormal, "max_subnormal", "Libc.FPBits.maxSubnormal", false, false,
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
    {CoreOpKind::SignNegate, "negate", "Libc.Sign.negate", false, false, false, false},
});

inline constexpr std::array kDyadicMethods = std::to_array<CoreOpSpec>({
    {CoreOpKind::DyadicFastAs, "fast_as", "Libc.DyadicFloat.fastAs", true, true, false, false},
    {CoreOpKind::DyadicGenericAs, "generic_as", "Libc.DyadicFloat.genericAs", true, true, false,
     false},
    {CoreOpKind::DyadicAs, "as", "Libc.DyadicFloat.asFloat", true, true, false, false},
    {CoreOpKind::DyadicNormalize, "normalize", "Libc.DyadicFloat.normalize", false, false, false,
     false},
    {CoreOpKind::DyadicShiftLeft, "shift_left", "Libc.DyadicFloat.shiftLeft", false, false, false,
     false},
    {CoreOpKind::DyadicShiftRight, "shift_right", "Libc.DyadicFloat.shiftRight", false, false,
     false, false},
    {CoreOpKind::DyadicGetUnbiasedExp, "get_unbiased_exponent",
     "Libc.DyadicFloat.getUnbiasedExponent", false, false, false, false},
    {CoreOpKind::DyadicRound, "round", "Libc.DyadicFloat.round", true, true, false, false},
    {CoreOpKind::DyadicQuickAdd, "quick_add", "Libc.DyadicFloat.quickAdd", false, false, false,
     false},
    {CoreOpKind::DyadicQuickSub, "quick_sub", "Libc.DyadicFloat.quickSub", false, false, false,
     false},
    {CoreOpKind::DyadicQuickMul, "quick_mul", "Libc.DyadicFloat.quickMul", false, true, false,
     false},
});

inline constexpr std::array kBigIntMethods = std::to_array<CoreOpSpec>({
    {CoreOpKind::BigIntIsZero, "is_zero", "Libc.BigInt.isZero", false, false, false, false},
    {CoreOpKind::BigIntQuickMulHi, "quick_mul_hi", "Libc.BigInt.quickMulHi", false, true, false,
     false},
    {CoreOpKind::BigIntGetBit, "get_bit", "Libc.BigInt.getBit", false, false, false, false},
    {CoreOpKind::BigIntSetBit, "set_bit", "Libc.BigInt.setBit", false, false, false, false},
    {CoreOpKind::BigIntAddOverflow, "add_overflow", "Libc.BigInt.addOverflow", false, false, false,
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

inline constexpr std::array kNormalFloatMethods = std::to_array<CoreOpSpec>({
    {CoreOpKind::NormalFloatMul2, "mul2", "Libc.NormalFloat.mul2", false, false, false, false},
    {CoreOpKind::NormalFloatCmp, "cmp", "Libc.NormalFloat.cmp", false, false, false, false},
});

auto matchCoreType(std::string_view raw_qualified) -> std::optional<CoreTypeKind> {
  auto norm = normalizeQualifiedName(raw_qualified);
  constexpr std::array<std::pair<std::string_view, CoreTypeKind>, 21> kTypes = {{
      {"fputil::FPBits", CoreTypeKind::FPBits},
      {"FPBits", CoreTypeKind::FPBits},
      {"fputil::internal::FPRepImpl", CoreTypeKind::FPBits},
      {"fputil::internal::FPRepSem", CoreTypeKind::FPBits},
      {"fputil::internal::FPRepBase", CoreTypeKind::FPBits},
      {"fputil::internal::FPStorage", CoreTypeKind::FPBits},
      {"fputil::internal::FPBase", CoreTypeKind::FPBits},
      {"fputil::NormalFloat", CoreTypeKind::NormalFloat},
      {"NormalFloat", CoreTypeKind::NormalFloat},
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
      {"UInt", CoreTypeKind::BigInt},
      {"BigInt", CoreTypeKind::BigInt},
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
  case CoreTypeKind::NormalFloat:
    return lookup(kNormalFloatMethods);
  case CoreTypeKind::DyadicFloat:
    return lookup(kDyadicMethods);
  case CoreTypeKind::BigInt:
    return lookup(kBigIntMethods);
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
