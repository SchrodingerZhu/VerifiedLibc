{
  description = "Lean 4 proofs of correct rounding for LLVM libc math functions";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  # Forester renders the journal under ./journal. It is not in nixpkgs; its flake builds it
  # against its own nixpkgs pin, which is kept so that the result comes from a binary cache.
  inputs.forester.url = "sourcehut:~jonsterling/ocaml-forester/6.0";

  # External kernels that check the proofs again, apart from Lean's own kernel (see AGENTS.md).
  # Each is pinned by flake.lock and built with the Lean of this flake.
  inputs.con-leche = {
    url = "github:leanprover/con-leche";
    flake = false;
  };
  inputs.lean4export = {
    url = "github:leanprover/lean4export";
    flake = false;
  };
  inputs.susz = {
    url = "github:jasisz/susz";
    flake = false;
  };
  inputs.gruszka = {
    url = "github:jasisz/gruszka";
    flake = false;
  };

  outputs = {
    nixpkgs,
    forester,
    con-leche,
    lean4export,
    susz,
    gruszka,
    ...
  }: let
    # Must agree with ./lean-toolchain.
    leanVersion = "4.36.0";
    leanHashes = {
      x86_64-linux = "sha256-K3qx7YuS0uar+vQTRII7UQBk28nAJgysc+tJarLepus=";
      aarch64-linux = "sha256-NUcZmBUhke+AlBjOW/Yfj8XyCeXjvgW0i9xJSf2z5yY=";
    };
    forAllSystems = f:
      nixpkgs.lib.genAttrs (builtins.attrNames leanHashes) (system: f nixpkgs.legacyPackages.${system});
    leanFor = pkgs:
      pkgs.callPackage ./nix/lean-bin.nix {
        version = leanVersion;
        hashes = leanHashes;
      };

    foresterFor = pkgs: forester.legacyPackages.${pkgs.stdenv.hostPlatform.system}.forester;

    kernelToolsFor = pkgs: let
      lakeExe = args: pkgs.callPackage ./nix/lake-exe.nix ({lean = leanFor pkgs;} // args);
      cargoTool = args: pkgs.callPackage ./nix/cargo-tool.nix args;
    in rec {
      con-leche-bin = lakeExe {
        pname = "con-leche";
        src = con-leche;
        exe = "con-leche";
        description = "External Lean checker with a proof of consistency";
        homepage = "https://github.com/leanprover/con-leche";
      };
      lean4export-bin = lakeExe {
        pname = "lean4export";
        src = lean4export;
        exe = "lean4export";
        description = "Plain-text declaration export for Lean 4";
        homepage = "https://github.com/leanprover/lean4export";
      };
      susz-bin = cargoTool {
        pname = "susz";
        src = susz;
        description = "Binary form of lean4export files";
        homepage = "https://github.com/jasisz/susz";
      };
      gruszka-bin = cargoTool {
        pname = "gruszka";
        src = gruszka;
        description = "Lean 4 kernel in Rust, normalization by evaluation";
        homepage = "https://github.com/jasisz/gruszka";
      };
      # kernel-check MODULE [CONSTANT...]: check the constants (by default, everything MODULE
      # imports) and all they depend on with both external kernels. Run it after `lake build`.
      kernel-check = pkgs.writeShellApplication {
        name = "kernel-check";
        runtimeInputs = [(leanFor pkgs) pkgs.git];
        # The Lean release ships an older `con-leche` of its own, first in PATH, that reads only
        # lean4export files; each tool is named by its store path.
        text = ''
          if [ $# -eq 0 ]; then
            echo "usage: kernel-check MODULE [CONSTANT...]" >&2
            exit 2
          fi
          module=$1
          shift
          cd "$(git rev-parse --show-toplevel)"
          search_path=$(lake env printenv LEAN_PATH)

          echo "== con-leche: $module $*"
          constant_flags=()
          for c in "$@"; do constant_flags+=("--constant=$c"); done
          # The default stack of 1 GB overflows on the proof of `expf`.
          export LEAN_STACK_SIZE_KB="''${LEAN_STACK_SIZE_KB:-16777216}"
          ${nixpkgs.lib.getExe con-leche-bin} --olean "''${constant_flags[@]}" \
            --search-path="$search_path" -- "$module"

          work=$(mktemp -d)
          trap 'rm -rf "$work"' EXIT
          echo "== gruszka: $module $*"
          if [ $# -gt 0 ]; then
            lake env ${nixpkgs.lib.getExe lean4export-bin} "$module" -- "$@" > "$work/export.ndjson"
          else
            lake env ${nixpkgs.lib.getExe lean4export-bin} "$module" > "$work/export.ndjson"
          fi
          ${nixpkgs.lib.getExe susz-bin} pack --no-index "$work/export.ndjson" "$work/export.susz"
          ${nixpkgs.lib.getExe gruszka-bin} "$work/export.susz"
        '';
      };
    };

    # The journal commands work from any directory of the checkout. Forester copies its theme
    # out of the Nix store with read-only permissions, so a previous output is made writable
    # before building again.
    enterJournal = ''
      cd "$(git rev-parse --show-toplevel)/journal"
      if [ -d output ]; then chmod -R u+w output; fi
    '';
    journalTools = pkgs: let
      foresterPkg = foresterFor pkgs;
    in {
      build = pkgs.writeShellApplication {
        name = "journal-build";
        runtimeInputs = [foresterPkg pkgs.git];
        text =
          enterJournal
          + ''
            forester build forest.toml "$@" 2>&1 | tee output.log
            if grep -qiE '(error|warning)' output.log; then
              echo "forester reported diagnostics" >&2
              rm output.log
              exit 1
            fi
            rm output.log
          '';
      };
      serve = pkgs.writeShellApplication {
        name = "journal-serve";
        runtimeInputs = [foresterPkg pkgs.git pkgs.python3];
        text =
          enterJournal
          + ''
            forester build forest.toml
            port="''${1:-1313}"
            echo "serving on http://localhost:$port/"
            exec python3 -m http.server "$port" -d output
          '';
      };
      # journal-new <kind>: allocate a random address and print the path of the new tree.
      new = pkgs.writeShellApplication {
        name = "journal-new";
        runtimeInputs = [foresterPkg pkgs.git];
        text =
          enterJournal
          + ''
            kind="''${1:-}"
            case "$kind" in
              log)      prefix="log"; dir="log" ;;
              insight)  prefix="ins"; dir="insight" ;;
              problem)  prefix="prob"; dir="problem" ;;
              decision) prefix="dec"; dir="decision" ;;
              session)  prefix="ses"; dir="session" ;;
              *)
                echo "usage: journal-new <log|insight|problem|decision|session>" >&2
                exit 2
                ;;
            esac
            mkdir -p "trees/$dir"
            exec forester new forest.toml --random --prefix "$prefix" --dest "trees/$dir"
          '';
      };
    };
  in {
    packages = forAllSystems (pkgs:
      {
        lean = leanFor pkgs;
        forester = foresterFor pkgs;
      }
      // kernelToolsFor pkgs);

    apps = forAllSystems (pkgs:
      builtins.mapAttrs (_: drv: {
        type = "app";
        program = nixpkgs.lib.getExe drv;
      }) (journalTools pkgs));

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          (leanFor pkgs)

          # Needed by `lake` to fetch dependencies and the Mathlib build cache.
          git
          curl

          # Extraction of libc functions from the Clang AST (see ./extract). `ast2lean` links
          # against the Clang and LLVM libraries, and `clang-scan-deps` orders its C++ modules.
          llvmPackages_23.clang
          llvmPackages_23.clang-tools
          llvmPackages_23.libclang.dev
          llvmPackages_23.llvm
          llvmPackages_23.llvm.dev
          cmake
          ninja

          # Polynomial and table generation, as used by the LLVM libc sources.
          sollya
          # Round-off error bounds for straight-line floating-point code.
          gappa
          # Reference results for testing a Lean model against the C++ code.
          mpfr
          mpfi
          gmp

          # SAT/SMT back ends for bit-level goals.
          cadical
          z3
          cvc5
          bitwuzla

          # The journal under ./journal (see AGENTS.md).
          (foresterFor pkgs)
          (journalTools pkgs).build
          (journalTools pkgs).serve
          (journalTools pkgs).new

          # Differential tests of the AArch64 plans: a cross compiler and user-mode emulation.
          qemu-user

          # External kernels and `kernel-check` (see AGENTS.md).
          (kernelToolsFor pkgs).con-leche-bin
          (kernelToolsFor pkgs).lean4export-bin
          (kernelToolsFor pkgs).susz-bin
          (kernelToolsFor pkgs).gruszka-bin
          (kernelToolsFor pkgs).kernel-check
        ];

        # The Lean release bundles a clang of its own, which comes first in PATH and cannot
        # build C++ against the system headers. The extraction scripts use these instead.
        AST2LEAN_CC = "${pkgs.llvmPackages_23.clang}/bin/clang";
        AST2LEAN_CXX = "${pkgs.llvmPackages_23.clang}/bin/clang++";
        # The unwrapped `clang-scan-deps` of `clang` comes first in PATH and does not find the C++
        # standard headers; the one of `clang-tools` is wrapped.
        AST2LEAN_CLANG_SCAN_DEPS = "${pkgs.llvmPackages_23.clang-tools}/bin/clang-scan-deps";
        # A C++ compiler for aarch64-linux-gnu, for the differential tests of the AArch64 plans.
        AARCH64_CXX = let
          cross = pkgs.pkgsCross.aarch64-multiplatform.buildPackages.llvmPackages_23.clang;
        in "${cross}/bin/aarch64-unknown-linux-gnu-clang++";
        LLVM_DIR = "${pkgs.llvmPackages_23.llvm.dev}/lib/cmake/llvm";
        Clang_DIR = "${pkgs.llvmPackages_23.libclang.dev}/lib/cmake/clang";
      };
    });

    formatter = forAllSystems (pkgs: pkgs.alejandra);
  };
}
