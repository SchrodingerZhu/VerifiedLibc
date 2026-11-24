{
  description = "Lean 4 proofs of correct rounding for LLVM libc math functions";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  # Forester renders the journal under ./journal. It is not in nixpkgs; its flake builds it
  # against its own nixpkgs pin, which is kept so that the result comes from a binary cache.
  inputs.forester.url = "sourcehut:~jonsterling/ocaml-forester/6.0";

  outputs = {
    nixpkgs,
    forester,
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
    packages = forAllSystems (pkgs: {
      lean = leanFor pkgs;
      forester = foresterFor pkgs;
    });

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

          # The journal under ./journal (see CLAUDE.md).
          (foresterFor pkgs)
          (journalTools pkgs).build
          (journalTools pkgs).serve
          (journalTools pkgs).new
        ];

        # The Lean release bundles a clang of its own, which comes first in PATH and cannot
        # build C++ against the system headers. The extraction scripts use these instead.
        AST2LEAN_CC = "${pkgs.llvmPackages_23.clang}/bin/clang";
        AST2LEAN_CXX = "${pkgs.llvmPackages_23.clang}/bin/clang++";
        LLVM_DIR = "${pkgs.llvmPackages_23.llvm.dev}/lib/cmake/llvm";
        Clang_DIR = "${pkgs.llvmPackages_23.libclang.dev}/lib/cmake/clang";
      };
    });

    formatter = forAllSystems (pkgs: pkgs.alejandra);
  };
}
