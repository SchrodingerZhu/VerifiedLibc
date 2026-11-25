# A Rust command-line tool built from its pinned source and its own `Cargo.lock`.
{
  rustPlatform,
  pname,
  src,
  description,
  homepage,
  buildFeatures ? [],
}:
rustPlatform.buildRustPackage {
  inherit pname src buildFeatures;
  version = "0-unstable-${builtins.substring 0 8 (src.rev or "dirty")}";
  cargoLock.lockFile = "${src}/Cargo.lock";
  # The test suites need corpora that are not in the source.
  doCheck = false;
  meta = {
    inherit description homepage;
    mainProgram = pname;
  };
}
