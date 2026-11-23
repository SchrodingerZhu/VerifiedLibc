{
  description = "Lean 4 proofs of correct rounding for LLVM libc math functions";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
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
  in {
    packages = forAllSystems (pkgs: {lean = leanFor pkgs;});

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          (leanFor pkgs)

          # Needed by `lake` to fetch dependencies and the Mathlib build cache.
          git
          curl

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
        ];
      };
    });

    formatter = forAllSystems (pkgs: pkgs.alejandra);
  };
}
