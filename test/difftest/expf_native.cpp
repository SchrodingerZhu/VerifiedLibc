// The compiled expf of LLVM libc, run from the command line.
//
//   expf-native <mode> (<first> <step> <count>)...
//
// The arguments and the output are those of the Lean model in ExpfModel.lean,
// so that the two outputs can be compared line by line.
//
// Compile with -frounding-math: the calls must not be folded or moved across
// the change of rounding mode.

#include <cfenv>
#include <cinttypes>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>

namespace __llvm_libc {
float expf(float);
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

int main(int argc, char **argv) {
  int mode;
  if (argc < 2 || argc % 3 != 2 || !parseMode(argv[1], mode)) {
    std::fputs("usage: expf-native nearest|up|down|zero "
               "(<first> <step> <count>)...\n",
               stderr);
    return 2;
  }
  // The compiler cannot see through a volatile pointer, so every call is made
  // at run time, after the rounding mode has been set.
  float (*volatile expf)(float) = __llvm_libc::expf;
  if (std::fesetround(mode) != 0)
    return 1;
  for (int arg = 2; arg < argc; arg += 3) {
    uint32_t first = std::strtoul(argv[arg], nullptr, 16);
    uint32_t step = std::strtoul(argv[arg + 1], nullptr, 10);
    uint64_t count = std::strtoull(argv[arg + 2], nullptr, 10);
    for (uint64_t i = 0; i < count; ++i) {
      uint32_t input = first + static_cast<uint32_t>(i) * step;
      float x;
      std::memcpy(&x, &input, sizeof x);
      float y = expf(x);
      uint32_t output;
      std::memcpy(&output, &y, sizeof output);
      std::printf("%08" PRIx32 " %08" PRIx32 "\n", input, output);
    }
  }
  return 0;
}
