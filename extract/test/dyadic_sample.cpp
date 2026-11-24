#include <stdint.h>

namespace __llvm_libc {

namespace cpp {
template <typename T> struct optional {
  T val;
  bool present;
  constexpr bool has_value() const { return present; }
  constexpr T value() const { return val; }
  constexpr T operator*() const { return val; }
  constexpr explicit operator bool() const { return present; }
};

template <int Bits> struct UInt {
  uint64_t val[Bits / 64];
};
} // namespace cpp

namespace fputil {

struct Sign {
  bool is_neg;
};

template <int Bits> struct DyadicFloat {
  Sign sign;
  int exponent;
  cpp::UInt<Bits> mantissa;

  constexpr DyadicFloat(Sign s, int e, cpp::UInt<Bits> m) : sign(s), exponent(e), mantissa(m) {}
  explicit DyadicFloat(double x);

  template <typename T> T fast_as() const;
  template <typename T> T generic_as() const;
};

template <int Bits>
DyadicFloat<Bits> quick_add(const DyadicFloat<Bits> &a, const DyadicFloat<Bits> &b);

template <int Bits>
DyadicFloat<Bits> quick_mul(const DyadicFloat<Bits> &a, const DyadicFloat<Bits> &b);

struct DoubleDouble {
  double lo;
  double hi;
};

DoubleDouble exact_add(double a, double b);
DoubleDouble exact_mult(double a, double b);
DoubleDouble quick_mult(const DoubleDouble &a, const DoubleDouble &b);

template <typename T, int N> struct ExceptValues {
  struct Entry {
    uint32_t input;
    uint32_t rnd_nearest;
    uint32_t rnd_up;
    uint32_t rnd_down;
    uint32_t rnd_zero;
  };
  Entry values[N];
  cpp::optional<T> lookup(uint32_t x_bits) const;
};

template <typename T, typename C> T polyeval(T, C c0);
template <typename T, typename C, typename... Cs> T polyeval(T x, C c0, Cs... cs);

int quick_get_round();

} // namespace fputil

namespace math {

using Float128 = fputil::DyadicFloat<128>;

constexpr Float128 COEFFS_128[3] = {
    Float128({false}, -127, {{0x0000000000000000ULL, 0x8000000000000000ULL}}),
    Float128({false}, -128, {{0x5555555555555555ULL, 0xAAAAAAAAAAAAAAAAULL}}),
    Float128({true}, -130, {{0x1111111111111111ULL, 0xCCCCCCCCCCCCCCCCULL}}),
};

constexpr fputil::DoubleDouble DD_TABLE[2] = {
    {0x1.0p-54, 0x1.0p+0},
    {-0x1.2p-55, 0x1.5p+0},
};

constexpr fputil::ExceptValues<float, 2> MY_EXCEPTS = {{
    {0x3F800000u, 0x402DF854u, 0x402DF855u, 0x402DF854u, 0x402DF854u},
    {0xBF800000u, 0x3EBC5AB2u, 0x3EBC5AB2u, 0x3EBC5AB1u, 0x3EBC5AB1u},
}};

// Demonstrates DyadicFloat<128>, DoubleDouble, ExceptValues, and switch lifting.
double accurate_kernel(double x, int idx) {
  uint32_t xbits = static_cast<uint32_t>(idx);
  if (auto r = MY_EXCEPTS.lookup(xbits); r.has_value()) {
    return static_cast<double>(r.value());
  }

  fputil::DoubleDouble prod = fputil::exact_mult(x, DD_TABLE[idx & 1].hi);
  fputil::DoubleDouble sum = fputil::exact_add(prod.hi, DD_TABLE[idx & 1].lo);

  Float128 dx(sum.hi);
  Float128 p = fputil::polyeval(dx, COEFFS_128[0], COEFFS_128[1], COEFFS_128[2]);
  Float128 scaled = fputil::quick_mul(dx, p);
  Float128 total = fputil::quick_add(scaled, COEFFS_128[0]);

  double bias = 0.0;
  switch (fputil::quick_get_round()) {
  case 0x400:
    bias = -0x1.0p-53;
    break;
  case 0x800:
    bias = 0x1.0p-53;
    break;
  default:
    bias = 0.0;
    break;
  }
  return total.fast_as<double>() + bias;
}

// Demonstrates automatic manual Horner chain recognition (without calling fputil::polyeval).
double manual_horner(double r) {
  return 0x1.0p+0 + r * (0x1.0p-1 + r * (0x1.5555555555555p-3 + r * 0x1.5555555555555p-5));
}

// Demonstrates structured loop emission (`Id.run do`) for iterative range reduction.
double loop_reduce(double x, int n) {
  double acc = x;
  for (int i = 0; i < n; ++i) {
    acc = acc * 0.5 + DD_TABLE[i & 1].hi;
  }
  return acc;
}

} // namespace math
} // namespace __llvm_libc
