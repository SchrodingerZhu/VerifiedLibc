module;

#include <fstream>
#include <iostream>
#include <print>
#include <ranges>
#include <span>
#include <string>
#include <string_view>
#include <vector>

export module libc_extract.cli;

import libc_extract;

export namespace libc_extract {

auto runCli(int argc, char **argv) -> int;

} // namespace libc_extract

module :private;

namespace libc_extract {
namespace {

void printUsage(std::string_view prog) {
  std::println(std::cerr,
R"(usage: {0} <source.cpp> --function=<name> [options] [-- <clang-args...>]
       {0} <source.cpp> --list-functions [clang-args...]
       {0} <source.cpp> --dump-config [clang-args...]

High-level C++23 Clang-AST to Lean 4 math extractor referencing LibcMath.Core.

Options:
  --function=<name>      Target function (qualified name, suffix, or mangled name)
  --name=<lean_name>     Override Lean definition name
  --namespace=<ns>       Lean namespace (default: LibcMath.Extracted)
  --import=<mod>         Lean import module (default: LibcMath.Core)
  --source-label=<path>  Relative source path recorded in KernelMeta
  --source-commit=<sha>  Upstream llvm-project commit recorded in KernelMeta
  --variant=<name>       Override MathConfig.implVariant
  --follow-helpers       Recursively extract non-CoreOp helper functions in same TU
  --no-unwrap-wrapper    Do not unwrap 1-line entrypoint forwarding wrappers
  --drop-effects         Omit errno/fenv-flag/do_not_optimize calls (pure math mode)
  --no-fold-poly         Disable automatic Horner polynomial lifting
  --no-unroll-loops      Disable small constant-bound loop unrolling
  --no-lift-functional   Keep imperative `Id.run do` form instead of functional lifting
  --no-kernel-bundle     Omit `kernelMeta` and `kernel : Core.UnaryKernel` wrapper
  --float-comments       Annotate hex float literals with decimal comments
  --emit-ir              Print the lifted High-Level Math IR instead of Lean code
  --dump-config          Print captured LIBC_MATH_* and target CPU flags and exit
  --list-functions       List all defined functions in the translation unit
  --strict               Fail if any unsupported AST construct is encountered
  --resource-dir=<dir>   Override Clang resource directory (auto-detected by default)
  -o <file>              Write output to file (default: stdout)
  -h, --help             Show this message

Clang flags (e.g. -I..., -D..., -std=..., -mavx2, -mfma) may be passed either
directly or after `--`.)", prog);
}

auto consumePrefixed(std::string_view arg, std::string_view prefix, std::string &dst) -> bool {
  if (arg.starts_with(prefix)) {
    dst = std::string(arg.substr(prefix.size()));
    return true;
  }
  return false;
}

} // namespace

auto runCli(int argc, char **argv) -> int {
  std::span<char *> args(argv, static_cast<std::size_t>(argc));
  std::string_view prog = args.empty() ? "ast2lean" : args[0];

  ParseOptions parse_opts;
  LiftOptions lift_opts;
  EmitOptions emit_opts;
  std::string output_path;
  bool emit_ir = false;
  bool list_only = false;
  bool dump_config = false;
  bool after_dashdash = false;

  for (std::size_t i = 1; i < args.size(); ++i) {
    std::string_view a = args[i];
    if (after_dashdash) {
      parse_opts.clang_args.emplace_back(a);
      continue;
    }
    if (a == "--") {
      after_dashdash = true;
    } else if (a == "-h" || a == "--help") {
      printUsage(prog);
      return 0;
    } else if (consumePrefixed(a, "--function=", parse_opts.target_function)) {
    } else if (a == "--function" && i + 1 < args.size()) {
      parse_opts.target_function = args[++i];
    } else if (consumePrefixed(a, "--name=", parse_opts.lean_name)) {
    } else if (a == "--name" && i + 1 < args.size()) {
      parse_opts.lean_name = args[++i];
    } else if (consumePrefixed(a, "--namespace=", emit_opts.lean_namespace)) {
    } else if (consumePrefixed(a, "--import=", emit_opts.core_import)) {
    } else if (consumePrefixed(a, "--source-label=", parse_opts.source_label)) {
    } else if (consumePrefixed(a, "--source-commit=", parse_opts.source_commit)) {
    } else if (consumePrefixed(a, "--variant=", parse_opts.impl_variant)) {
    } else if (consumePrefixed(a, "--resource-dir=", parse_opts.resource_dir)) {
    } else if (a == "-o" && i + 1 < args.size()) {
      output_path = args[++i];
    } else if (consumePrefixed(a, "-o=", output_path)) {
    } else if (a == "--follow-helpers") {
      parse_opts.follow_helpers = true;
    } else if (a == "--no-unwrap-wrapper") {
      parse_opts.unwrap_forwarding = false;
    } else if (a == "--drop-effects") {
      lift_opts.drop_effects = true;
    } else if (a == "--no-fold-poly") {
      lift_opts.fold_polynomials = false;
    } else if (a == "--no-unroll-loops") {
      lift_opts.unroll_small_loops = false;
    } else if (a == "--no-lift-functional") {
      lift_opts.lift_functional = false;
    } else if (a == "--no-kernel-bundle") {
      emit_opts.emit_kernel_bundle = false;
    } else if (a == "--float-comments") {
      emit_opts.emit_float_comments = true;
    } else if (a == "--emit-ir") {
      emit_ir = true;
    } else if (a == "--dump-config") {
      dump_config = true;
    } else if (a == "--list-functions") {
      list_only = true;
    } else if (a == "--strict") {
      parse_opts.strict = true;
    } else if (a == "-I" || a == "-D" || a == "-U" || a == "-isystem" || a == "-include") {
      parse_opts.clang_args.emplace_back(a);
      if (i + 1 < args.size()) parse_opts.clang_args.emplace_back(args[++i]);
    } else if (a.starts_with("-I") || a.starts_with("-D") || a.starts_with("-U") ||
               a.starts_with("-std=") || a.starts_with("-f") || a.starts_with("-m") ||
               a.starts_with("-W") || a.starts_with("-O") || a.starts_with("--target=")) {
      parse_opts.clang_args.emplace_back(a);
    } else if (!a.starts_with("-") && parse_opts.source_file.empty()) {
      parse_opts.source_file = std::string(a);
    } else {
      std::println(std::cerr, "ast2lean: unrecognized option '{}' (put raw Clang flags after `--`)", a);
      return 2;
    }
  }

  if (parse_opts.source_file.empty()) {
    printUsage(prog);
    return 2;
  }

  if (dump_config) {
    auto cfg = inspectMathConfig(parse_opts);
    if (!cfg) {
      std::println(std::cerr, "ast2lean: {}", cfg.error());
      return 1;
    }
    std::print("{}", formatMathConfig(*cfg));
    return 0;
  }

  if (list_only) {
    auto listed = listFunctions(parse_opts);
    if (!listed) {
      std::println(std::cerr, "ast2lean: {}", listed.error());
      return 1;
    }
    for (const auto &f : *listed) {
      std::println("{:<48} {}  [{}]{}",
                   f.qualified_name, f.signature, f.mangled_name,
                   f.is_template_instantiation ? " (instantiation)" : "");
    }
    return 0;
  }

  if (parse_opts.target_function.empty()) {
    std::println(std::cerr, "ast2lean: missing --function=<name> (or use --list-functions)");
    return 2;
  }

  auto parsed = parseTranslationUnit(parse_opts);
  if (!parsed) {
    std::println(std::cerr, "ast2lean: {}", parsed.error());
    return 1;
  }

  ir::Module mod = std::move(*parsed);
  liftModule(mod, lift_opts);

  std::string result = emit_ir ? emitHighLevelIR(mod) : emitLean(mod, emit_opts);

  if (output_path.empty()) {
    std::print("{}", result);
  } else {
    std::ofstream ofs(output_path);
    if (!ofs) {
      std::println(std::cerr, "ast2lean: failed to open output file '{}'", output_path);
      return 1;
    }
    ofs << result;
  }
  return 0;
}

} // namespace libc_extract
