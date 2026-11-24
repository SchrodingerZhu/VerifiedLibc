#include <stdint.h>

#ifndef LIBC_NAMESPACE
#define LIBC_NAMESPACE __llvm_libc
#endif

#define LIBC_UNLIKELY(x) __builtin_expect(static_cast<bool>(x), 0)
#define LIBC_LIKELY(x) __builtin_expect(static_cast<bool>(x), 1)

namespace LIBC_NAMESPACE {

namespace cpp {
template <typename T, unsigned long N> struct array {
  T elems[N];
  constexpr const T &operator[](unsigned long i) const { return elems[i]; }
};
} // namespace cpp

namespace fputil {

template <typename T> struct FPBits {
  uint32_t bits;
  constexpr explicit FPBits(T x) : bits(__builtin_bit_cast(uint32_t, x)) {}
  constexpr explicit FPBits(uint32_t b) : bits(b) {}
  constexpr uint32_t uintval() const { return bits; }
  constexpr FPBits abs() const { return FPBits(bits & 0x7FFFFFFFu); }
  constexpr bool is_neg() const { return (bits >> 31) != 0; }
  constexpr bool is_inf() const { return (bits & 0x7FFFFFFFu) == 0x7F800000u; }
  constexpr bool is_nan() const { return (bits & 0x7FFFFFFFu) > 0x7F800000u; }
  constexpr T get_val() const { return __builtin_bit_cast(T, bits); }
  constexpr static FPBits max_normal() { return FPBits(0x7F7FFFFFu); }
  constexpr static FPBits min_subnormal() { return FPBits(0x00000001u); }
  constexpr static FPBits zero() { return FPBits(0x00000000u); }
  constexpr static FPBits inf() { return FPBits(0x7F800000u); }
};

inline int quick_get_round();
inline bool fenv_is_round_up();
inline void set_errno_if_required(int);
inline int raise_except_if_required(int);
inline float nearest_integer(float);
inline float multiply_add(float, float, float);

template <typename T, typename C> inline T polyeval(T, C c0) { return c0; }
template <typename T, typename C, typename... Cs> inline T polyeval(T x, C c0, Cs... cs) {
  return x * polyeval(x, cs...) + c0;
}

} // namespace fputil

namespace math {

constexpr cpp::array<double, 8> EXP_M1 = {{
    0x1.0000000000000p+0,
    0x1.5bf0a8b145769p+1,
    0x1.d8e64b8d4ddaep+2,
    0x1.415e5bf6fb106p+4,
    0x1.b4c902e273a58p+5,
    0x1.28d389970338fp+7,
    0x1.936dc5690c08fp+8,
    0x1.122885aaeddaap+10,
}};

constexpr double EXP_M2[4] = {
    0x1.0000000000000p+0,
    0x1.0202015600446p+0,
    0x1.04080ab55de39p+0,
    0x1.06122436410ddp+0,
};

namespace double_eval {

inline float expf(float x) {
  using FPBits = fputil::FPBits<float>;
  FPBits xbits(x);
  uint32_t x_u = xbits.uintval();
  uint32_t x_abs = x_u & 0x7FFFFFFFu;

  // Exceptional value checked directly in source.
  if (LIBC_UNLIKELY(x_u == 0xC236BD8Cu)) {
    return fputil::multiply_add(-x, 0x1.0p-95f, 0x1.108a58p-66f);
  }

  // Compile-time configuration check (discarded branch stripped automatically).
  if constexpr (sizeof(float) == 8) {
    return 0.0f;
  }

  // Tiny, overflow, underflow, Inf, NaN.
  if (LIBC_UNLIKELY(x_abs <= 0x32800000u || x_abs >= 0x42B20000u)) {
    if (x_abs <= 0x32800000u) {
      return x + 1.0f;
    }
    if (x_u > 0xC2CFF1B4u) {
      if (xbits.is_inf())
        return 0.0f;
      if (xbits.is_nan())
        return x;
      if (fputil::fenv_is_round_up())
        return FPBits::min_subnormal().get_val();
      fputil::set_errno_if_required(34);
      fputil::raise_except_if_required(0x10);
      return 0.0f;
    }
    if (static_cast<int32_t>(x_u) > 0x42B1FFFF) {
      if (x_u < 0x7F800000u) {
        int rmode = fputil::quick_get_round();
        if (rmode == 0x400 || rmode == 0xC00) {
          return FPBits::max_normal().get_val();
        }
        fputil::set_errno_if_required(34);
        fputil::raise_except_if_required(0x8);
      }
      return x + FPBits::inf().get_val();
    }
  }

  // Main polynomial evaluation path.
  float kd = fputil::nearest_integer(x * 128.0f);
  double r = static_cast<double>(x - kd * 0x1.0p-7f);
  int32_t k = static_cast<int32_t>(kd);
  double m1 = EXP_M1[(k + 0x3400) >> 7];
  double m2 = EXP_M2[k & 0x7F];
  double p = fputil::polyeval(r, 0x1.0000000000000p+0, 0x1.fffffffffeeeep-1, 0x1.0000000000e38p-1,
                              0x1.555566668e5e7p-3, 0x1.55555555ef243p-5);
  return static_cast<float>((m1 * m2) * p);
}

} // namespace double_eval

// Forwarding entrypoint (auto-unwrapped to math::double_eval::expf).
float expf(float x) { return double_eval::expf(x); }

} // namespace math
} // namespace LIBC_NAMESPACE
