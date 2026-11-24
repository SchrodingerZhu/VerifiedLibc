/* Correctly rounded binary32 functions computed with MPFR.

   Each function takes a rounding direction and the bit pattern of a binary32 argument and
   returns the bit pattern of the result that IEEE 754 prescribes: the exact value rounded in
   that direction to binary32, with gradual underflow. MPFR computes at 24 bits of precision in
   the exponent range of binary32, and `mpfr_subnormalize` rounds a subnormal result to the
   spacing of the subnormal numbers, as the MPFR manual describes for emulating a format.

   Rounding directions: 0 to nearest (ties to even), 1 toward zero, 2 upward, 3 downward. */

#include <stdint.h>
#include <string.h>

#include <mpfr.h>

static mpfr_rnd_t direction(uint8_t mode) {
  switch (mode) {
  case 1:
    return MPFR_RNDZ;
  case 2:
    return MPFR_RNDU;
  case 3:
    return MPFR_RNDD;
  default:
    return MPFR_RNDN;
  }
}

uint32_t libcmath_mpfr_expf(uint8_t mode, uint32_t x_bits) {
  float x;
  memcpy(&x, &x_bits, sizeof x);
  mpfr_rnd_t rnd = direction(mode);

  /* The exponent range of binary32 in MPFR's convention, where a significand is in [1/2, 1):
     the least subnormal number is 2^-149 = 0.5 * 2^-148, and the largest number is below
     2^128. */
  mpfr_exp_t saved_emin = mpfr_get_emin();
  mpfr_exp_t saved_emax = mpfr_get_emax();
  mpfr_set_emin(-148);
  mpfr_set_emax(128);

  mpfr_t value;
  mpfr_init2(value, 24);
  mpfr_set_flt(value, x, MPFR_RNDN); /* exact: a binary32 number has at most 24 bits */
  int ternary = mpfr_exp(value, value, rnd);
  mpfr_subnormalize(value, ternary, rnd);
  float y = mpfr_get_flt(value, rnd);
  mpfr_clear(value);

  mpfr_set_emin(saved_emin);
  mpfr_set_emax(saved_emax);

  uint32_t y_bits;
  memcpy(&y_bits, &y, sizeof y_bits);
  return y_bits;
}
