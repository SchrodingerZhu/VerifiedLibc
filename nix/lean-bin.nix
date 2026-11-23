# The official Lean release, made runnable from the Nix store.
#
# The release bundles its own clang, lld and C library stubs, and `lean.h` relies on that
# clang, so the bundle is kept intact instead of being rewired to the nixpkgs compiler.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zstd,
  version,
  hashes,
}: let
  system = stdenv.hostPlatform.system;
  suffix =
    {
      x86_64-linux = "linux";
      aarch64-linux = "linux_aarch64";
    }.${
      system
    };
in
  stdenv.mkDerivation {
    pname = "lean4-bin";
    inherit version;

    src = fetchurl {
      url = "https://github.com/leanprover/lean4/releases/download/v${version}/lean-${version}-${suffix}.tar.zst";
      hash = hashes.${system};
    };

    nativeBuildInputs = [autoPatchelfHook zstd];
    buildInputs = [stdenv.cc.cc.lib];

    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      mkdir -p $out
      cp -r . $out

      # Executables linked by `leanc` (for example Mathlib's `cache`) must name a dynamic
      # loader that exists on NixOS.
      # lld selects its flavour from the name it is invoked under, so the real binary keeps it.
      mkdir $out/libexec
      mv $out/bin/ld.lld $out/libexec/ld.lld
      cat > $out/bin/ld.lld <<WRAPPER
      #!${stdenv.shell}
      exec $out/libexec/ld.lld --dynamic-linker=$(cat ${stdenv.cc}/nix-support/dynamic-linker) "\$@"
      WRAPPER
      chmod +x $out/bin/ld.lld
    '';

    meta = {
      description = "Lean 4 theorem prover (official binary release)";
      homepage = "https://lean-lang.org";
      license = lib.licenses.asl20;
      platforms = builtins.attrNames hashes;
      mainProgram = "lean";
    };
  }
