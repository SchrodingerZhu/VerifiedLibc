# An executable of a Lake package that has no dependencies, built with the Lean of the flake.
#
# The package's `lean-toolchain` is ignored: the tool must accept the `.olean` files and the
# environment of this repository, so it is built with the same Lean.
{
  lib,
  stdenv,
  autoPatchelfHook,
  git,
  lean,
  pname,
  src,
  exe,
  description,
  homepage,
}:
stdenv.mkDerivation {
  inherit pname src;
  version = "0-unstable-${builtins.substring 0 8 (src.rev or "dirty")}";

  nativeBuildInputs = [lean git autoPatchelfHook];
  buildInputs = [stdenv.cc.cc.lib];

  dontConfigure = true;
  dontStrip = true;

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    lake build ${exe}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 .lake/build/bin/${exe} $out/bin/${exe}
    runHook postInstall
  '';

  meta = {
    inherit description homepage;
    mainProgram = exe;
  };
}
