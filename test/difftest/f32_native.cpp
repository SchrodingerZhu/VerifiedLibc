// Generic compiled LLVM libc binary32 driver for differential testing.
//
// Compile with `-DFN_NAME=<name> -DFN_SIG=<sig> -frounding-math` and link with
// `<llvm-libc>/src/math/generic/<name>.cpp` and `libc_errno.cpp`.
//
// Usage:
//   f32-native <mode> (<first_hex> <step_dec> <count_dec>)...
//   f32-native <mode> --stdin
//
// Output lines use hex bit patterns matching `test/difftest/F32Model.lean`.

#include <cfenv>
#include <cinttypes>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>

#define SIG_U_F32 1
#define SIG_B_F32 2
#define SIG_T_F32 3
#define SIG_U_F32_I32 4
#define SIG_U_F32_LONG 5
#define SIG_U_F32_LLONG 6
#define SIG_U_F32_OUT_I32 7
#define SIG_U_F32_OUT_F32 8
#define SIG_U_F32_OUT_F32_F32 9
#define SIG_B_F32_OUT_I32 10
#define SIG_U_F32_IN_I32 11
#define SIG_U_F32_IN_LONG 12
#define SIG_U_F32_FROMFP 13
#define SIG_B_PTR_I32 14
#define SIG_U_PTR_F32 15
#define SIG_U_OUT_PTR_I32 16
#define SIG_U_OUT_F32_I32 17

namespace __llvm_libc {
#if FN_SIG == SIG_U_F32
float FN_NAME(float);
#elif FN_SIG == SIG_B_F32
float FN_NAME(float, float);
#elif FN_SIG == SIG_T_F32
float FN_NAME(float, float, float);
#elif FN_SIG == SIG_U_F32_I32
int FN_NAME(float);
#elif FN_SIG == SIG_U_F32_LONG
long FN_NAME(float);
#elif FN_SIG == SIG_U_F32_LLONG
long long FN_NAME(float);
#elif FN_SIG == SIG_U_F32_OUT_I32
float FN_NAME(float, int *);
#elif FN_SIG == SIG_U_F32_OUT_F32
float FN_NAME(float, float *);
#elif FN_SIG == SIG_U_F32_OUT_F32_F32
void FN_NAME(float, float *, float *);
#elif FN_SIG == SIG_B_F32_OUT_I32
float FN_NAME(float, float, int *);
#elif FN_SIG == SIG_U_F32_IN_I32
float FN_NAME(float, int);
#elif FN_SIG == SIG_U_F32_IN_LONG
float FN_NAME(float, long);
#elif FN_SIG == SIG_U_F32_FROMFP
float FN_NAME(float, int, unsigned int);
#elif FN_SIG == SIG_B_PTR_I32
int FN_NAME(const float *, const float *);
#elif FN_SIG == SIG_U_PTR_F32
float FN_NAME(const float *);
#elif FN_SIG == SIG_U_OUT_PTR_I32
int FN_NAME(float *, const float *);
#elif FN_SIG == SIG_U_OUT_F32_I32
int FN_NAME(float *, float);
#else
#error "Unsupported FN_SIG"
#endif
} // namespace __llvm_libc

static float u32ToF32(uint32_t bits) {
  float x;
  std::memcpy(&x, &bits, sizeof x);
  return x;
}

static uint32_t f32ToU32(float x) {
  uint32_t bits;
  std::memcpy(&bits, &x, sizeof bits);
  return bits;
}

static bool parseMode(const char *name, int &mode) {
  static const struct {
    const char *name;
    int mode;
  } modes[] = {{"nearest", FE_TONEAREST},
               {"up", FE_UPWARD},
               {"down", FE_DOWNWARD},
               {"zero", FE_TOWARDZERO}};
  for (const auto &m : modes) {
    if (std::strcmp(name, m.name) == 0) {
      mode = m.mode;
      return true;
    }
  }
  return false;
}

static void evalUnary(uint32_t bx) {
  float x = u32ToF32(bx);
#if FN_SIG == SIG_U_F32
  float (*volatile fn)(float) = __llvm_libc::FN_NAME;
  std::printf("%08" PRIx32 " %08" PRIx32 "\n", bx, f32ToU32(fn(x)));
#elif FN_SIG == SIG_U_F32_I32
  int (*volatile fn)(float) = __llvm_libc::FN_NAME;
  std::printf("%08" PRIx32 " %08" PRIx32 "\n", bx, static_cast<uint32_t>(fn(x)));
#elif FN_SIG == SIG_U_F32_LONG
  long (*volatile fn)(float) = __llvm_libc::FN_NAME;
  std::printf("%08" PRIx32 " %016" PRIx64 "\n", bx, static_cast<uint64_t>(fn(x)));
#elif FN_SIG == SIG_U_F32_LLONG
  long long (*volatile fn)(float) = __llvm_libc::FN_NAME;
  std::printf("%08" PRIx32 " %016" PRIx64 "\n", bx, static_cast<uint64_t>(fn(x)));
#elif FN_SIG == SIG_U_F32_OUT_I32
  float (*volatile fn)(float, int *) = __llvm_libc::FN_NAME;
  int out = 0;
  float y = fn(x, &out);
  std::printf("%08" PRIx32 " %08" PRIx32 " %08" PRIx32 "\n", bx, f32ToU32(y),
              static_cast<uint32_t>(out));
#elif FN_SIG == SIG_U_F32_OUT_F32
  float (*volatile fn)(float, float *) = __llvm_libc::FN_NAME;
  float out = 0.0f;
  float y = fn(x, &out);
  std::printf("%08" PRIx32 " %08" PRIx32 " %08" PRIx32 "\n", bx, f32ToU32(y), f32ToU32(out));
#elif FN_SIG == SIG_U_F32_OUT_F32_F32
  void (*volatile fn)(float, float *, float *) = __llvm_libc::FN_NAME;
  float s = 0.0f, c = 0.0f;
  fn(x, &s, &c);
  std::printf("%08" PRIx32 " %08" PRIx32 " %08" PRIx32 "\n", bx, f32ToU32(s), f32ToU32(c));
#elif FN_SIG == SIG_U_PTR_F32
  float (*volatile fn)(const float *) = __llvm_libc::FN_NAME;
  std::printf("%08" PRIx32 " %08" PRIx32 "\n", bx, f32ToU32(fn(&x)));
#elif FN_SIG == SIG_U_OUT_PTR_I32
  int (*volatile fn)(float *, const float *) = __llvm_libc::FN_NAME;
  float out = 0.0f;
  int r = fn(&out, &x);
  std::printf("%08" PRIx32 " %08" PRIx32 " %08" PRIx32 "\n", bx, static_cast<uint32_t>(r),
              f32ToU32(out));
#elif FN_SIG == SIG_U_OUT_F32_I32
  int (*volatile fn)(float *, float) = __llvm_libc::FN_NAME;
  float out = 0.0f;
  int r = fn(&out, x);
  std::printf("%08" PRIx32 " %08" PRIx32 " %08" PRIx32 "\n", bx, static_cast<uint32_t>(r),
              f32ToU32(out));
#else
  (void)x;
#endif
}

static int runStdin() {
  char line[256];
  while (std::fgets(line, sizeof line, stdin)) {
#if FN_SIG == SIG_B_F32
    uint32_t bx = 0, by = 0;
    if (std::sscanf(line, "%" SCNx32 " %" SCNx32, &bx, &by) != 2)
      continue;
    float (*volatile fn)(float, float) = __llvm_libc::FN_NAME;
    float r = fn(u32ToF32(bx), u32ToF32(by));
    std::printf("%08" PRIx32 " %08" PRIx32 " %08" PRIx32 "\n", bx, by, f32ToU32(r));
#elif FN_SIG == SIG_T_F32
    uint32_t bx = 0, by = 0, bz = 0;
    if (std::sscanf(line, "%" SCNx32 " %" SCNx32 " %" SCNx32, &bx, &by, &bz) != 3)
      continue;
    float (*volatile fn)(float, float, float) = __llvm_libc::FN_NAME;
    float r = fn(u32ToF32(bx), u32ToF32(by), u32ToF32(bz));
    std::printf("%08" PRIx32 " %08" PRIx32 " %08" PRIx32 " %08" PRIx32 "\n", bx, by, bz,
                f32ToU32(r));
#elif FN_SIG == SIG_B_F32_OUT_I32
    uint32_t bx = 0, by = 0;
    if (std::sscanf(line, "%" SCNx32 " %" SCNx32, &bx, &by) != 2)
      continue;
    float (*volatile fn)(float, float, int *) = __llvm_libc::FN_NAME;
    int q = 0;
    float r = fn(u32ToF32(bx), u32ToF32(by), &q);
    std::printf("%08" PRIx32 " %08" PRIx32 " %08" PRIx32 " %08" PRIx32 "\n", bx, by, f32ToU32(r),
                static_cast<uint32_t>(q));
#elif FN_SIG == SIG_U_F32_IN_I32
    uint32_t bx = 0, bk = 0;
    if (std::sscanf(line, "%" SCNx32 " %" SCNx32, &bx, &bk) != 2)
      continue;
    float (*volatile fn)(float, int) = __llvm_libc::FN_NAME;
    float r = fn(u32ToF32(bx), static_cast<int>(bk));
    std::printf("%08" PRIx32 " %08" PRIx32 " %08" PRIx32 "\n", bx, bk, f32ToU32(r));
#elif FN_SIG == SIG_U_F32_IN_LONG
    uint32_t bx = 0;
    uint64_t bk = 0;
    if (std::sscanf(line, "%" SCNx32 " %" SCNx64, &bx, &bk) != 2)
      continue;
    float (*volatile fn)(float, long) = __llvm_libc::FN_NAME;
    float r = fn(u32ToF32(bx), static_cast<long>(bk));
    std::printf("%08" PRIx32 " %016" PRIx64 " %08" PRIx32 "\n", bx, bk, f32ToU32(r));
#elif FN_SIG == SIG_U_F32_FROMFP
    uint32_t bx = 0, br = 0, bw = 0;
    if (std::sscanf(line, "%" SCNx32 " %" SCNx32 " %" SCNx32, &bx, &br, &bw) != 3)
      continue;
    float (*volatile fn)(float, int, unsigned int) = __llvm_libc::FN_NAME;
    float r = fn(u32ToF32(bx), static_cast<int>(br), bw);
    std::printf("%08" PRIx32 " %08" PRIx32 " %08" PRIx32 " %08" PRIx32 "\n", bx, br, bw,
                f32ToU32(r));
#elif FN_SIG == SIG_B_PTR_I32
    uint32_t bx = 0, by = 0;
    if (std::sscanf(line, "%" SCNx32 " %" SCNx32, &bx, &by) != 2)
      continue;
    int (*volatile fn)(const float *, const float *) = __llvm_libc::FN_NAME;
    float x = u32ToF32(bx), y = u32ToF32(by);
    int r = fn(&x, &y);
    std::printf("%08" PRIx32 " %08" PRIx32 " %08" PRIx32 "\n", bx, by, static_cast<uint32_t>(r));
#else
    uint32_t bx = 0;
    if (std::sscanf(line, "%" SCNx32, &bx) != 1)
      continue;
    evalUnary(bx);
#endif
  }
  return 0;
}

int main(int argc, char **argv) {
  int mode;
  if (argc < 3 || !parseMode(argv[1], mode)) {
    std::fputs("usage: f32-native nearest|up|down|zero (--stdin | (<first> <step> <count>)...)\n",
               stderr);
    return 2;
  }
  if (std::fesetround(mode) != 0)
    return 1;
  if (argc == 3 && std::strcmp(argv[2], "--stdin") == 0) {
    return runStdin();
  }
  if ((argc - 2) % 3 != 0) {
    std::fputs("error: range arguments must be triples (<first> <step> <count>)\n", stderr);
    return 2;
  }
  for (int arg = 2; arg < argc; arg += 3) {
    uint32_t first = std::strtoul(argv[arg], nullptr, 16);
    uint32_t step = std::strtoul(argv[arg + 1], nullptr, 10);
    uint64_t count = std::strtoull(argv[arg + 2], nullptr, 10);
    for (uint64_t i = 0; i < count; ++i) {
      evalUnary(first + static_cast<uint32_t>(i) * step);
    }
  }
  return 0;
}
