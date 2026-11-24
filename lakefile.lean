import Lake
open Lake DSL System

/-!
# Build configuration

`LibcMath` is the library of definitions and proofs. `LibcMathMpfr` is a small library whose one
module declares a function implemented in C on top of MPFR (`c/mpfr_oracle.c`); its modules are
compiled ahead of time so that the function can run during elaboration, which `native_decide`
needs.

The linker bundled with Lean does not read the environment of a Nix shell, so the library
directories that shell provides (`NIX_LDFLAGS`) are passed on here, also as run paths. Outside such
a shell the variable is empty, and MPFR and GMP are taken from the system.
-/

/-- The words of an environment variable, or nothing when it is not set. -/
def envWords (name : String) : IO (Array String) := do
  return ((← IO.getEnv name).getD "").splitOn " " |>.filter (· ≠ "") |>.toArray

/-- The `-L` directories of the environment that hold MPFR or GMP, each also given as a run path.
The other directories are left out: one of them may hold a library that Lean bundles in another
version, such as CaDiCaL. -/
def envLinkArgs : IO (Array String) := do
  let words ← envWords "NIX_LDFLAGS"
  let dirs ← (words.filter (·.startsWith "-L")).filterM fun flag => do
    let dir : FilePath := (flag.drop 2).toString
    return (← (dir / "libmpfr.so").pathExists) || (← (dir / "libgmp.so").pathExists)
  let dirs := dirs.toList.eraseDups.toArray
  return dirs ++ dirs.map fun dir => s!"-Wl,-rpath,{dir.drop 2}"

package LibcMath where
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩,
    ⟨`relaxedAutoImplicit, false⟩,
    ⟨`maxSynthPendingDepth, .ofNat 3⟩]

require "leanprover-community" / "mathlib" @ git "v4.36.0"

require FloatLib from git "https://github.com/lean-dojo/FloatLib" @ "v4.1.0"

/-- The MPFR shim. It is plain C that does not use the Lean runtime, and it is compiled with the
C compiler of the environment (`cc`), which finds the headers of the C library, MPFR and GMP; the
compiler bundled with Lean has none of them. -/
target mpfrOracleObj pkg : FilePath := do
  let oFile := pkg.buildDir / "c" / "mpfr_oracle.o"
  let srcJob ← inputTextFile (pkg.dir / "c" / "mpfr_oracle.c")
  buildO oFile srcJob #[] #["-fPIC", "-O2"] "cc"

extern_lib libcmath_mpfr pkg := do
  buildStaticLib (pkg.staticLibDir / nameToStaticLib "libcmath_mpfr") #[← mpfrOracleObj.fetch]

@[default_target]
lean_lib LibcMath

lean_lib LibcMathMpfr where
  precompileModules := true
  moreLinkArgs := run_io do return (← envLinkArgs) ++ #["-lmpfr", "-lgmp"]

-- MPFR and GMP may be built against a newer C library than the one whose symbols the linker of
-- Lean knows, so their own undefined references are left to the loader.
lean_exe checkrange where
  root := `LibcMath.Check.Main
  moreLinkArgs := run_io do
    return (← envLinkArgs) ++ #["-lmpfr", "-lgmp", "-Wl,--allow-shlib-undefined"]

lean_exe «difftest-expf-model» where
  srcDir := "test/difftest"
  root := `ExpfModel
