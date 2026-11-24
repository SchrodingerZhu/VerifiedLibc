import LibcMath.Extracted.Expf.Tmd.Certs.Chunk00
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk01
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk02
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk03
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk04
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk05
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk06
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk07
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk08
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk09
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk10
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk11
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk12
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk13
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk14
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk15
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk16
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk17
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk18
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk19
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk20
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk21
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk22
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk23
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk24
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk25
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk26
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk27
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk28
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk29
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk30
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk31
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk32
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk33
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk34
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk35
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk36
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk37
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk38
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk39
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk40
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk41
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk42
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk43
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk44
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk45
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk46
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk47
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk48
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk49
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk50
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk51
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk52
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk53
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk54
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk55
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk56
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk57
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk58
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk59
import LibcMath.Extracted.Expf.Tmd.Certs.Chunk60

/-!
# Assembly of all 61 Chebyshev SLZ TMD certificate chunks for `expf`

Combines `Chunk00` .. `Chunk29` to cover `[0x33800000, 0x42B17218)` (`254 898 712` inputs) and
`Chunk30` .. `Chunk60` to cover `[0xB3000001, 0xC2CE8ED0)` (`265 195 215` inputs) across all four C
rounding modes using only the standard Lean axioms.
-/

namespace LibcMath.Extracted.Expf.Tmd.Main

open FloatLib.Floats.Formats.BinaryInterchange
open Model (IEEERoundingMode)

/-- `Expf.DoubleEval.expf` is correctly rounded on `[0x33800000, 0x42B17218)` in every C rounding
mode, certified by 30 Chebyshev SLZ TMD chunks (`Chunk00` .. `Chunk29`) and 51 pointwise exceptions.
-/
theorem holdsOnBits_tmd_pos {mode : IEEERoundingMode} (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode)
      0x33800000 0x42B17218 := by
  have acc := Certs.Chunk00.holdsOnBits hmode
  have acc := acc.append (Certs.Chunk01.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk02.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk03.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk04.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk05.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk06.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk07.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk08.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk09.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk10.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk11.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk12.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk13.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk14.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk15.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk16.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk17.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk18.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk19.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk20.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk21.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk22.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk23.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk24.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk25.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk26.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk27.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk28.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk29.holdsOnBits hmode)
  exact acc

/-- `Expf.DoubleEval.expf` is correctly rounded on `[0xB3000001, 0xC2CE8ED0)` in every C rounding
mode, certified by 31 Chebyshev SLZ TMD chunks (`Chunk30` .. `Chunk60`) and 51 pointwise exceptions.
-/
theorem holdsOnBits_tmd_neg {mode : IEEERoundingMode} (hmode : mode ∈ cModes) :
    HoldsOnBits (CorrectAt (Spec.exp .binary32) Expf.DoubleEval.expf mode)
      0xB3000001 0xC2CE8ED0 := by
  have acc := Certs.Chunk30.holdsOnBits hmode
  have acc := acc.append (Certs.Chunk31.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk32.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk33.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk34.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk35.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk36.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk37.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk38.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk39.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk40.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk41.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk42.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk43.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk44.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk45.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk46.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk47.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk48.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk49.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk50.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk51.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk52.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk53.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk54.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk55.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk56.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk57.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk58.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk59.holdsOnBits hmode)
  have acc := acc.append (Certs.Chunk60.holdsOnBits hmode)
  exact acc

/--
info: 'LibcMath.Extracted.Expf.Tmd.Main.holdsOnBits_tmd_pos' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms holdsOnBits_tmd_pos

/--
info: 'LibcMath.Extracted.Expf.Tmd.Main.holdsOnBits_tmd_neg' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms holdsOnBits_tmd_neg

end LibcMath.Extracted.Expf.Tmd.Main
