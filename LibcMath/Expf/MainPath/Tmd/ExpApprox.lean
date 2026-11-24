import LibcMath.Analysis.Binary32Bits
import LibcMath.Testing.Oracle.ExpReduced
import Mathlib.Analysis.Complex.ExponentialBounds

/-!
# Rigorous kernel-fast `Nat` exponential and Chebyshev polynomial approximation

This file provides a pure-`Nat`, kernel-fast (`decide +kernel`) rigorous approximation of
`Real.exp` over centered binary32 sub-intervals `[b_c - R, b_c + R]` inside a single input binade,
designed for verifying Table Maker's Dilemma (TMD) certificates for `expf`.

## Main definitions and theorems

* `uExp E`, `binadeLoExp E`, `inOutputBinade E y`: output binade bounds and half-ULP grid exponent
  `u = 2 ^ uExp E` (`E - 24` for normal binades `-126 ≤ E ≤ 127`, `-150` for subnormals `E = -127`).
* `EXP1_ENC` (195 entries for `exp(k)`, `k ∈ [-104, 90]`) and `EXP2_ENC` (128 entries for
  `exp(j / 128)`, `j ∈ [0, 127]`): 80-bit enclosures stored in bit-packed binary-dispatch lookup
  tables (`exp1Lookup`, `exp2Lookup`) and certified once at compile time against
  `LibcMath.ExpOracle.reducedEnclosure?`.
* `expCenterEnc b_c`: pure-`Nat` 80-bit enclosure `(eA, aLo, aHi)` of `Real.exp (f32(b_c).toReal)`
  (`expCenterEnc_sound`).
* `polyApproxD2 b_c R E` and `polyApproxD3 b_c R E`: pure-`Nat` Chebyshev-economized degree-2 and
  degree-3 polynomial approximations at scale `2^64` with rigorous error bound `M`, together with
  zero-side-condition soundness theorems `polyApproxD2_sound` and `polyApproxD3_sound`.
-/

namespace LibcMath.Expf.MainPath.Tmd

open FloatLib.Floats.Formats.BinaryInterchange Model
open FloatLib.Numerics.Interval.BinaryGrid (value scale scale_eq_pow)

/-! ## Output grid and fixed-point scales -/

/-- `2 ^ 64`, the fixed-point scale for polynomial fractional parts `c_k` and margin `M`. -/
def S64 : Nat := 0x10000000000000000

/-- `2 ^ 80`, the internal fixed-point scale for exponential enclosures and coefficients. -/
def S80 : Nat := 0x100000000000000000000

/-- Grid exponent `uExp E` so `u = 2 ^ uExp E` is half-ULP of binary32 on output binade `E`:
`E - 24` for normal binades `-126 ≤ E ≤ 127`, and `-150` for subnormals `E = -127`. -/
def uExp (E : Int) : Int :=
  if E == -127 then -150 else E - 24

/-- Lower exponent bound of binary32 output binade `E`: `-150` for subnormals (`E = -127`),
and `E` for normal binades `-126 ≤ E ≤ 127`. -/
def binadeLoExp (E : Int) : Int :=
  if E == -127 then -150 else E

/-- `y` lies in binary32 output binade `E` (`-127 ≤ E ≤ 127`, `2^(binadeLoExp E) ≤ y ≤ 2^(E+1)`). -/
def inOutputBinade (E : Int) (y : ℝ) : Prop :=
  (-127 : ℤ) ≤ E ∧ E ≤ 127 ∧ (2 : ℝ) ^ binadeLoExp E ≤ y ∧ y ≤ (2 : ℝ) ^ (E + 1)

/-! ## Precomputed 80-bit `Nat` tables for `exp(k)` and `exp(j / 128)`

To keep Lean 4 kernel reduction fast across hundreds of thousands of interval checks, the 195
entries of `EXP1_ENC` (`k ∈ [-104, 90]`) are bit-packed 3 per 276-bit word (92 bits per entry:
bits `[0..1]` = `hi - lo`, bits `[2..10]` = `exp2 + 160`, bits `[11..90]` = `lo`) and dispatched
via a depth-7 `Nat.ble` tree. The 128 entries of `EXP2_ENC` (`j ∈ [0, 127]`) are bit-packed 4 per
336-bit word (84 bits per entry: bits `[0..1]` = `hi - lo`, bits `[2..83]` = `lo`) via a depth-5
`Nat.ble` tree. -/

private def exp1Chunk (c : Nat) : Nat :=
  match Nat.ble 32 c with
  | true =>
    match Nat.ble 48 c with
    | true =>
      match Nat.ble 56 c with
      | true =>
        match Nat.ble 60 c with
        | true =>
          match Nat.ble 62 c with
          | true =>
            match Nat.ble 63 c with
            | true =>
              match Nat.ble 64 c with
              | true =>
                0x72C423FEFB058F25F0474895470B30D0CE00264BB3B4857C415B71EFC8B4F783B547D
              | false =>
                0x5B6C04611DC9150777824794343B6A5E5AE409EE78147562FB1D40F291DD6226BEC6D
            | false =>
              0x48D37A7831D3A27B7A654696B2A35AC045ADF3DF9FBC614ED8F6A3A44841011F7845D
          | false =>
            match Nat.ble 61 c with
            | true =>
              0x74068843112A8E78422B455555DE6E613CFACF22940C517D9E67AA710527024CC5C49
            | false =>
              0x5C6CD5032FE4825C7B43C454400AAD8862CDF33E412441641129CD51751F7DDF3DC39
        | false =>
          match Nat.ble 58 c with
          | true =>
            match Nat.ble 59 c with
            | true =>
              0x49A00E30B03800DCCF5E4356C573F96DB85EDC6F75A42D4FB674928B546D1B384FC29
            | false =>
              0x754C7629FB9E71A85A05C21564DB5138685170118FCC1D7EFF486710EC11CC1E5FC15
          | false =>
            match Nat.ble 57 c with
            | true =>
              0x5D707711A78EBD2CC11C41144BFB1D6561BF2A7476D40D652A436C35BF89FBDF36C05
            | false =>
              0x4A6EE0977F3E1AEAF8654016D879728E978C2CBC280BF9509660B3D65F3481738F3F5
      | false =>
        match Nat.ble 52 c with
        | true =>
          match Nat.ble 54 c with
          | true =>
            match Nat.ble 55 c with
            | true =>
              0x7695F7A3C41E9EE623723ED574024E531709DE9A5ABBE94032043519025C32A0DD3E5
            | false =>
              0x5E76F27714F19924CAF2BDD4580D172654F8B2DE7A3BD9664672AFBF2DA439A8C83D1
          | false =>
            match Nat.ble 53 c with
            | true =>
              0x4B3FF7FAF78684C6610DBCD6EBB45A9B8369CC1C5DFBC55178C1DB585A62D8DD513C1
            | false =>
              0x77E316BC5EE8EB70385CBB958353DBF6B1CC234F5EABB540E6594A381D2FAF3F5DBB1
        | false =>
          match Nat.ble 50 c with
          | true =>
            match Nat.ble 51 c with
            | true =>
              0x5F804F34451182D40984BA946440F90202D159935DD3A56765C0422109427E1D19B9D
            | false =>
              0x4C135ABB28952CEBD2F13996FF2547AE2EDD6253A49391525D9EF0120F8D72922338D
          | false =>
            match Nat.ble 49 c with
            | true =>
              0x7933DD9BF926F86D023A385592D071B4DE0C7F9E797381419CA8F27AE1C501797637D
            | false =>
              0x608C9560804564DD9427375470972237DA18929C803B71688834E5E5CBAA2D0D84369
    | false =>
      match Nat.ble 40 c with
      | true =>
        match Nat.ble 44 c with
        | true =>
          match Nat.ble 46 c with
          | true =>
            match Nat.ble 47 c with
            | true =>
              0x4CE90F4A0A9464BD07E5365712CCD185F319C386775B5D5344FEEC6800669E177CB59
            | false =>
              0x7A8856874835D9D120D7B515A278886F2356BA66B4534D4254F8BCE87BDC3473DC349
          | false =>
            match Nat.ble 45 c with
            | true =>
              0x619BCD29C95E08459BE6B4147D0FF312D98B1F611E233D69ADD976337DB36FC718B35
            | false =>
              0x4DC11C2BB0A3B27A1F10331726AB918C70158AC6363B29542EE8DE58DE693EDAB5B25
        | false =>
          match Nat.ble 42 c with
          | true =>
            match Nat.ble 43 c with
            | true =>
              0x7BE08BDFD9CC72249ABC31D5B24C9A5A9AD7282A77C319430F4E48258B222ABECAB15
            | false =>
              0x62ADFED51D7EDCCDE68EB0D489ABCCEC7F70295E1383096AD6B6E710D7FE06ECD1B01
          | false =>
            match Nat.ble 41 c with
            | true =>
              0x4E9B87F67BB3F55976A72FD73AC222DA3A01008625E2F5551B63E7B49B85CA058CAF1
            | false =>
              0x7D3C88246502F4C2B08D2E95C24D2303A93E339FA642E543CBAF42A000812488FC2E1
      | false =>
        match Nat.ble 36 c with
        | true =>
          match Nat.ble 38 c with
          | true =>
            match Nat.ble 39 c with
            | true =>
              0x63C332BEB4AA1BBC5CBFAD94966B122FC175BBE06E8AD56C02D645AB2554D531D32CD
            | false =>
              0x4F7859534DF268BA80172C974F11223B93DFCFBDC49AC1560A773E54157E7C1FAA2BD
          | false =>
            match Nat.ble 37 c with
            | true =>
              0x7E9C55F11C3E070D95782B55D27A9F51C31B7C2F803AB1448A216ABB76A9BC7E802AD
            | false =>
              0x64DB715A43023CDEA6B92A54A34E265C0CE3C7D9BEAAA16D3240B89CE9619E35B4A99
        | false =>
          match Nat.ble 34 c with
          | true =>
            match Nat.ble 35 c with
            | true =>
              0x505796FDBEC417CB52F7A95763992E35376B730CE8EA8D56FC2A2C515DA54D57EE289
            | false =>
              0x400000000000000000002845E2D58D8B3BCDF1ABADEA7D454AAA8EFE072E7F6DDBA79
          | false =>
            match Nat.ble 33 c with
            | true =>
              0x65F6C3333AC2BB2520982714B0556E084F3D1DFA2BC26D6E64FF80354DD8711709265
            | false =>
              0x513947C44F5357602E812617785AE7092A63AAE665DA5957F08410409EB2EFF351A55
  | false =>
    match Nat.ble 16 c with
    | true =>
      match Nat.ble 24 c with
      | true =>
        match Nat.ble 28 c with
        | true =>
          match Nat.ble 30 c with
          | true =>
            match Nat.ble 31 c with
            | true =>
              0x40B3C894995166455B6CA515F35E6D591F26A716C91A49460D508E3D9D900F27BF245
            | false =>
              0x671530ED0EF22BC643B023D4BD814EE607660D085492396F9B1BF6C05848437338231
          | false =>
            match Nat.ble 29 c with
            | true =>
              0x521D72889FB0E02FE38B22D78D56EEBBA172B6997DCA2558E78C5D69A272F6670EA21
            | false =>
              0x41698A31A67E832211C521D60415BFCB15DC69DFC3E21546D21957CDC99B9812D1211
        | false =>
          match Nat.ble 26 c with
          | true =>
            match Nat.ble 27 c with
            | true =>
              0x6836C34376CFB0822ADCA094CAD22FC45F6894F3BC120570D49F90CFEAC45FAD309FD
            | false =>
              0x53041E3FA48A28286D5B9F97A28DE917F0CB740C7271F159E14A9C01F9061E363D9ED
          | false =>
            match Nat.ble 25 c with
            | true =>
              0x42214A61D9FA688DE3BF1E9614FC075B54EE7F5B20C1E147990AEBAE128142BBC19DD
            | false =>
              0x695B830AB1FDD3543F539D54D84878934EEE625E3101D1721193DD8591A078A6681C9
      | false =>
        match Nat.ble 20 c with
        | true =>
          match Nat.ble 22 c with
          | true =>
            match Nat.ble 23 c with
            | true =>
              0x53ED51F1DD769E1BF08C9C57B8007BB58AA7F51E38F9BD5ADDC66967C380A9EE161B9
            | false =>
              0x42DB0EBF77818E01B4401B562611C7F298153F9DAB69AD48622B5AB8CC0C37603D9A9
          | false =>
            match Nat.ble 21 c with
            | true =>
              0x6A83792FCD6CDFA78F641A14E5E49266C6890A5528519D73520286DD207F75C752195
            | false =>
              0x54D914BB8BDD6FA010FC1917CDAF4DFD0BCF85F60999895BDD07785D23AFAFB61F185
        | false =>
          match Nat.ble 18 c with
          | true =>
            match Nat.ble 19 c with
            | true =>
              0x4396DCF47FD4F3EA0F951816375786EC275F9B24DD5979492D80C6D26F69C13018175
            | false =>
              0x6BAEAEB8E906D2F8FD5D96D4F3A6E779E3E142AF8B59697495F551F820FB5C76B2961
          | false =>
            match Nat.ble 17 c with
            | true =>
              0x55C76DCCEA7585A0359695D7E39B092D564B8D0877C9555CDF15914452D54B0189951
            | false =>
              0x4454BABADCF01F8F2F4C94D648CDCB19E81CEFF3F6114549FB11631978F121E214941
    | false =>
      match Nat.ble 8 c with
      | true =>
        match Nat.ble 12 c with
        | true =>
          match Nat.ble 14 c with
          | true =>
            match Nat.ble 15 c with
            | true =>
              0x6CDD2CC57E1F04B9888E1395018FE3322EE6190116693575DD761F6A153320233492D
            | false =>
              0x56B8646A656168D7076A9297F9C45860BA731C4E5169215DE3F8925C6130B72C2811D
          | false =>
            match Nat.ble 13 c with
            | true =>
              0x4514ADDC8EBB4888E4EB11965A751CC87932EAFCB4A1114ACAE37416CC61B4607510D
            | false =>
              0x6E0EFC8EA6A7AB3A9ABF90550F9FF222E015705433490177288EEB85909197FAA38F9
        | false =>
          match Nat.ble 10 c with
          | true =>
            match Nat.ble 11 c with
            | true =>
              0x57ABFFECD2E8C42465728F540815F449173ABD8A8840F15EEBB86FFEA02C7E579B0E9
            | false =>
              0x45D6BC33D83B149E39FD0E566C4E05C35AFF8BD24280DD4B9CFD4FEEA11116DC6C0D9
          | false =>
            match Nat.ble 9 c with
            | true =>
              0x6F442767652F6976B0530D251DD782102FF754E06068CD787749CEAA292761881C8C5
            | false =>
              0x58A247C1ACD13F834CF40C14136934514A46307B4F40BD5FF65D34DCB9121BDC8D0B5
      | false =>
        match Nat.ble 4 c with
        | true =>
          match Nat.ble 6 c with
          | true =>
            match Nat.ble 7 c with
            | true =>
              0x469AEBAB6D3F42C49B5A0B167E59115922E7BAC6F180A94C71655E91F78739A6DB0A5
            | false =>
              0x707CB6BCEDA917A20F7A09D52C3701F2AFE5FCBFDB109979C9B0FD9343F811E9CE891
          | false =>
            match Nat.ble 5 c with
            | true =>
              0x599B436B4A58733EFCBF08D41EDC44AF07FF8674F9C0896103EF023F7227B440DB081
            | false =>
              0x4761423EA091A9D12DCA87D69096CC5FBAB33CB4B418754D482219F09A0A60E0BE871
        | false =>
          match Nat.ble 2 c with
          | true =>
            match Nat.ble 3 c with
            | true =>
              0x71B8B416EEFFFE99C34686953ABEE1FAAC3C953D9B18657B1FCEC9A7BEA1C452CC05D
            | false =>
              0x5A96FA811AD0B7F005F785942A6F7EC0B48FEB819E785562147610462421D6075504D
          | false =>
            match Nat.ble 1 c with
            | true =>
              0x4829C5F992A6F35891E38496A307C538ABD72BCF7640414E213A0E2BA9A1638EE283D
            | false =>
              0x72F82917DD7AC482E1EF8355496F9393980745B6ED48317C79ADA14A78CCD4523A829

private def exp2ChunkLo (c : Nat) : Nat :=
  match Nat.ble 8 c with
  | true =>
    match Nat.ble 12 c with
    | true =>
      match Nat.ble 14 c with
      | true =>
        match Nat.ble 15 c with
        | true =>
          0x68B26F68E8F9DEAB76FA567E1DB63A3159941605F96712E6E655426C7FAADE966458EB52C77304DC63DD
        | false =>
          0x6579CF9AC6DD766E09D9D64AFA66826FBFEDCCDFF163E70FF4A6FABDACC3FD56320091DEC003F70936D1
      | false =>
        match Nat.ble 13 c with
        | true =>
          0x625A8EC7D9A839A73D75161969DDC859315057708560D4334C2B0E3FDA12AC960134C0D1ED5172EB2E6D
        | false =>
          0x5F53E51BC2EA35A8597CA5E95FB7A7A88F78CFED755DD98C319E2F03B4318DD5D1E944F6FBDA988D1E2D
    | false =>
      match Nat.ble 10 c with
      | true =>
        match Nat.ble 11 c with
        | true =>
          0x5C6510E80EB2E4A1516D15BACFF156C79D6D2759315AF65BF740D289FE7594D5A4124B2FE50CB3F6BE61
        | false =>
          0x598D5673C6F1F168782F958DAEE6A60C961349CC315829E9CD2AC3A1D5591F5577A45D8117FD4ED44C91
      | false =>
        match Nat.ble 9 c with
        | true =>
          0x56CBFFCC843F655C7B815561F14F169EBC09D8749D557382931631EEC99F0B554C946033EB3DDB28B661
        | false =>
          0x54205C98F04F33D74FAB55378C3B08479804ED488D52D278AB96B19D1945DED522D78F0FA06199D9EF0D
  | false =>
    match Nat.ble 4 c with
    | true =>
      match Nat.ble 6 c with
      | true =>
        match Nat.ble 7 c with
        | true =>
          0x5189C1ECAEB0836D00F6150E7510FD7C563B8E9345504623D0B0F8C83C2EC214FA637AA84772EA8DDEF5
        | false =>
          0x4F078A1DA0D2A9FE918054E6A18AF4F04197DD1A794DCDE0E9C880493D473954D32E05C2D60D4B538311
      | false =>
        match Nat.ble 5 c with
        | true =>
          0x4C99149A7AA0A3E4CA9B54C007B3D806BDC02F57214B6911E2D8831CFAD54754AD2D62CDCB1E5404DD9D
        | false =>
          0x4A3DC5C29D57F5D67B33D49A9DE4FD80590AD75CC149171D84EE2A6BC8569C548858116DBD733E73B5A1
    | false =>
      match Nat.ble 2 c with
      | true =>
        match Nat.ble 3 c with
        | true =>
          0x47F506BF2E9179BB492414765AC3BFC39E4F4563D146D76F4FDA0488C0FAE49464A4DC1D38335A24F461
        | false =>
          0x45BE455D61C1A4BC91DB9453353F26273591557A8544A977550F331376BF8714420AD5DF4D3B5F56C681
      | false =>
        match Nat.ble 1 c with
        | true =>
          0x4398F3E9EAC2745CC904D431248DA0A7A2F0A4B3F9428CAA13A707D6051730542081580449FB26382F41
        | false =>
          0x4184890D9043745395965410202AD5778E45EAE19140808055801116C30C98D400000000000000000000

private def exp2ChunkHi (c : Nat) : Nat :=
  match Nat.ble 24 c with
  | true =>
    match Nat.ble 28 c with
    | true =>
      match Nat.ble 30 c with
      | true =>
        match Nat.ble 31 c with
        | true =>
          0xAC9DBEB9182DDBF5C9C45AB45DB916EAC95AF15019A9F0A58217CE4D4F73C15A89E1736398EB461FD1D1
        | false =>
          0xA74E2B6398FAE946F4F85A600DCCA8508845AA0A29A4B62635C196CCCC10A19A36E027A7299C12896FF5
      | false =>
        match Nat.ble 29 c with
        | true =>
          0xA2286C78076EA047F0839A0E55F1826599FEB28FC19FA4D54E982C7F04F9B399E66CA193415A245D0191
        | false =>
          0x9D2B387FCB976A27D3DC19BF21B9416A7725829F659ABB6E719FF56AFA57C6599872C3DB1593CE110FF9
    | false =>
      match Nat.ble 26 c with
      | true =>
        match Nat.ble 27 c with
        | true =>
          0x9855502740682A74E73819725D566DB309F9D44CA995F8B73E951C639AD905994CDF0F9F3F8E05C238B5
        | false =>
          0x93A57DEDDD25336D22F49927F597882E5BD3A5153D915B7F0151DCE3F512C619039E9F8DEA8BFFC88E9D
      | false =>
        match Nat.ble 25 c with
        | true =>
          0x8F1A95D8D3A56841645ED8DFD7E23DED395ADCD8B98CE29E659FE3552BDA24D8BC9F232966280753FA05
        | false =>
          0x8AB37528100EB6660E109899F22EC174A8C1A3D1E5888CF72D61B5B0AAB8371877CEDA33EE7BDEA61AB5
  | false =>
    match Nat.ble 20 c with
    | true =>
      match Nat.ble 22 c with
      | true =>
        match Nat.ble 23 c with
        | true =>
          0x866F020D874D710E38ABD856330348B2806B56DED1845973E901AE764EC06618351C903F850495FF940D
        | false =>
          0x824C2B66C219CBBACDC8D814896FAE739522FD2071804707B214A555D480DDD7F4779860BE32274B0ED9
      | false =>
        match Nat.ble 21 c with
        | true =>
          0x7E49E87892EDD74A1A6A97D4E5093643D7995DB4717C54ADE81EEDD9382ECE57B5CFC90370507E1D5EC5
        | false =>
          0x7A6738ACE5D923F8F7F3979735E671A9538C892A15788169EF6ADCF60DE58057791577E038F0172A25ED
    | false =>
      match Nat.ble 18 c with
      | true =>
        match Nat.ble 19 c with
        | true =>
          0x76A3235299A5A4FD1472575B6C9B45B359DF8E3BFD74CC46F1E08AD0539C65573E397611D62A2DFB3639
        | false =>
          0x72FCB75F5243C967663DD7217A350FDF341EE8A309713457A1CF064AF72CA2D7052D0C495911910CAA95
      | false =>
        match Nat.ble 17 c with
        | true =>
          0x6F730B3334F2126CE2BBD6E95036E95B957A5BC04D6DB8B5FE97AC61557395D6CDE1F7203E57A8BB3385
        | false =>
          0x6C053C5E7F0EE09FE934D6B2E09607BB9514C6DF656A58831B2CCDD06CBDC596984A638781A6F25CB7F9

/-- Fast kernel lookup for `exp(i - 104)` (`i < 195`).
Returns `(eBiased, lo, hi)` with `exp2 = (eBiased : Int) - 160` and `2^79 ≤ lo ≤ hi < 2^80`. -/
def exp1Lookup (i : Nat) : Nat × Nat × Nat :=
  let w := exp1Chunk (Nat.div i 3)
  let e := Nat.mod (Nat.shiftRight w (Nat.mul (Nat.mod i 3) 92)) 0x100000000000000000000000
  let d := Nat.mod e 4
  let eB := Nat.mod (Nat.shiftRight e 2) 512
  let lo := Nat.shiftRight e 11
  (eB, lo, Nat.add lo d)

/-- Fast kernel lookup for `exp(j / 128)` (`j < 128`).
Returns `(lo, hi)` with `2^80 ≤ lo ≤ hi < 2^82`. -/
def exp2Lookup (j : Nat) : Nat × Nat :=
  let c := Nat.shiftRight j 2
  let w := match Nat.ble 16 c with
    | true => exp2ChunkHi c
    | false => exp2ChunkLo c
  let e := Nat.mod (Nat.shiftRight w (Nat.mul (Nat.mod j 4) 84)) 0x1000000000000000000000
  let lo := Nat.shiftRight e 2
  (lo, Nat.add lo (Nat.mod e 4))

/-- 195-entry table of normalized 80-bit enclosures `(exp2, lo, hi)` for `exp(i - 104)`,
`i ∈ [0, 194]`, with `2^79 ≤ lo ≤ hi < 2^80` and
`lo * 2^(exp2 - 80) ≤ Real.exp (i - 104) ≤ hi * 2^(exp2 - 80)`. -/
def EXP1_ENC : Array (Int × Nat × Nat) :=
  Array.ofFn (n := 195) fun i =>
    let (eB, lo, hi) := exp1Lookup i.val
    ((eB : Int) - 160, lo, hi)

/-- 128-entry table of 80-bit enclosures `(lo, hi)` for `exp(j / 128)`, `j ∈ [0, 127]`,
with `2^80 ≤ lo ≤ hi < 2^82` and `lo * 2^-80 ≤ Real.exp (j / 128) ≤ hi * 2^-80`. -/
def EXP2_ENC : Array (Nat × Nat) :=
  Array.ofFn (n := 128) fun j => exp2Lookup j.val

/-! ### Compile-time certification of `exp1Lookup` and `exp2Lookup` -/

private theorem ln2Grid_104_eq :
    FloatLib.Numerics.Enclosure.Constants.ln2Grid 104 =
      ⟨14058695031733113177892216608771, 14058695031733113177892216608772⟩ := by
  decide +kernel

private def r88Fast : LibcMath.ExpOracle.Reduction where
  precision := 88
  guard := 16
  degree := 26
  scale := 2 ^ 88
  logTwo := ⟨14058695031733113177892216608771, 14058695031733113177892216608772⟩
  degree_pos := by decide
  scale_eq := rfl
  logTwo_eq := ln2Grid_104_eq.symm

private def S79 : Nat := 0x80000000000000000000

private theorem S79_eq_pow : S79 = 2 ^ 79 := by decide

private def checkExp1Entry (i : Nat) : Bool :=
  let (eB, lo, hi) := exp1Lookup i
  let shapeOk := S79 ≤ lo && lo ≤ hi && hi < S80
  if i == 104 then
    shapeOk && eB == 161 && lo == S79 && hi == S79
  else
    match LibcMath.ExpOracle.reducedEnclosure? r88Fast (((i : Int) - 104 : Int) : Rat) with
    | none => false
    | some (m, iv) =>
      let eDiff := (eB : Int) - 152 - m
      shapeOk && decide (0 ≤ iv.lo) && decide (0 ≤ iv.hi) && decide (0 ≤ eDiff) &&
        (lo <<< eDiff.toNat) ≤ iv.lo.toNat && iv.hi.toNat ≤ (hi <<< eDiff.toNat)

private def S82 : Nat := 0x400000000000000000000

private theorem S82_eq_pow : S82 = 2 ^ 82 := by decide

private def checkExp2Entry (j : Nat) : Bool :=
  let (lo, hi) := exp2Lookup j
  let shapeOk := S80 ≤ lo && lo ≤ hi && hi < S82
  if j == 0 then
    shapeOk && lo == S80 && hi == S80
  else
    match LibcMath.ExpOracle.reducedEnclosure? r88Fast (Rat.divInt (j : Int) 128) with
    | none => false
    | some (m, iv) =>
      let shInt := (8 : Int) - m
      shapeOk && decide (0 ≤ iv.lo) && decide (0 ≤ iv.hi) && decide (0 ≤ shInt) &&
        (lo <<< shInt.toNat) ≤ iv.lo.toNat && iv.hi.toNat ≤ (hi <<< shInt.toNat)

private def checkAllExp1 : Nat → Bool
  | 0 => true
  | n + 1 => checkExp1Entry n && checkAllExp1 n

private def checkAllExp2 : Nat → Bool
  | 0 => true
  | n + 1 => checkExp2Entry n && checkAllExp2 n

private theorem checkAllExp1_true : checkAllExp1 195 = true := by decide +kernel

private theorem checkAllExp2_true : checkAllExp2 128 = true := by decide +kernel

private theorem checkExp1Entry_of_lt {n i : Nat} (h : checkAllExp1 n = true) (hi : i < n) :
    checkExp1Entry i = true := by
  induction n with
  | zero => omega
  | succ k ih =>
    simp only [checkAllExp1, Bool.and_eq_true] at h
    by_cases heq : i = k
    · subst heq; exact h.1
    · exact ih h.2 (by omega)

private theorem checkExp2Entry_of_lt {n j : Nat} (h : checkAllExp2 n = true) (hj : j < n) :
    checkExp2Entry j = true := by
  induction n with
  | zero => omega
  | succ k ih =>
    simp only [checkAllExp2, Bool.and_eq_true] at h
    by_cases heq : j = k
    · subst heq; exact h.1
    · exact ih h.2 (by omega)


/-! ### Scale constants and `Nat.ble` / `Nat.beq` helpers -/

private def S72 : Nat := 0x1000000000000000000
private def S88 : Nat := 0x10000000000000000000000

private theorem S64_eq_pow : S64 = 2 ^ 64 := by decide
private theorem S72_eq_pow : S72 = 2 ^ 72 := by decide
private theorem S80_eq_pow : S80 = 2 ^ 80 := by decide
private theorem S88_eq_pow : S88 = 2 ^ 88 := by decide

private theorem S64_pos : (0 : ℝ) < (S64 : ℝ) := by exact_mod_cast (by decide : 0 < S64)
private theorem S80_pos : (0 : ℝ) < (S80 : ℝ) := by exact_mod_cast (by decide : 0 < S80)
private theorem S88_pos : (0 : ℝ) < (S88 : ℝ) := by exact_mod_cast (by decide : 0 < S88)

private theorem S64_cast : (S64 : ℝ) = (2 : ℝ) ^ (64 : ℕ) := by rw [S64_eq_pow]; norm_cast
private theorem S80_cast : (S80 : ℝ) = (2 : ℝ) ^ (80 : ℕ) := by rw [S80_eq_pow]; norm_cast
private theorem S88_cast : (S88 : ℝ) = (2 : ℝ) ^ (88 : ℕ) := by rw [S88_eq_pow]; norm_cast

private theorem S64_zpow : (S64 : ℝ) = (2 : ℝ) ^ (64 : ℤ) := by rw [S64_cast, ← zpow_natCast]; rfl
private theorem S80_zpow : (S80 : ℝ) = (2 : ℝ) ^ (80 : ℤ) := by rw [S80_cast, ← zpow_natCast]; rfl
private theorem S88_zpow : (S88 : ℝ) = (2 : ℝ) ^ (88 : ℤ) := by rw [S88_cast, ← zpow_natCast]; rfl

private theorem two_zpow_neg80 : (2 : ℝ) ^ (-80 : ℤ) = 1 / (S80 : ℝ) := by
  rw [zpow_neg, ← S80_zpow, one_div]

private theorem S80_eq_S64_mul : (S80 : ℝ) = (65536 : ℝ) * (S64 : ℝ) := by
  have h : S80 = 65536 * S64 := by decide
  rw [h, Nat.cast_mul]; norm_num

private theorem S72_mul_256 : (256 : ℝ) * (S72 : ℝ) = (S80 : ℝ) := by
  have h : 256 * S72 = S80 := by decide
  rw [← h, Nat.cast_mul]; norm_num

private theorem pow72_mul_256 : (256 : ℝ) * ((2 ^ 72 : ℕ) : ℝ) = (S80 : ℝ) := by
  rw [← S72_eq_pow]; exact S72_mul_256

private theorem quarter_S64 : (4 : ℝ) * ((0x4000000000000000 : ℕ) : ℝ) = (S64 : ℝ) := by
  have h : 4 * 0x4000000000000000 = S64 := by decide
  rw [← h, Nat.cast_mul]; norm_num

private theorem inv_two_pow_mul (k s : Nat) :
    (1 / (2 : ℝ) ^ s) ^ k = 1 / (2 : ℝ) ^ (k * s) := by
  rw [one_div_pow, ← pow_mul, mul_comm]

private theorem ble_true {a b : Nat} (h : Nat.ble a b = true) : a ≤ b := by
  simpa [Nat.ble_eq] using h

private theorem ble_false {a b : Nat} (h : Nat.ble a b = false) : b < a := by
  have : ¬ (a ≤ b) := by simp [← Nat.ble_eq, h]
  omega

private theorem beq_true {a b : Nat} (h : Nat.beq a b = true) : a = b :=
  Nat.eq_of_beq_eq_true h

private theorem beq_false {a b : Nat} (h : Nat.beq a b = false) : a ≠ b := by
  intro heq; subst heq; simp at h

private theorem match_bool_eq_ite {α : Type*} {b c : Bool} (t f : α) :
    b = c → (match c with | true => t | false => f) = (if b then t else f) := by
  intro h; subst h; cases b <;> rfl

/-- Certified enclosure for `exp1Lookup i` (`i < 195`). -/
theorem exp1Lookup_sound {i : Nat} (hi : i < 195) :
    let (eB, lo, hiVal) := exp1Lookup i
    2 ^ 79 ≤ lo ∧ lo ≤ hiVal ∧ hiVal < 2 ^ 80 ∧
    (lo : ℝ) * (2 : ℝ) ^ (((eB : ℤ) - 160) - 80) ≤ Real.exp ((i : ℝ) - 104) ∧
    Real.exp ((i : ℝ) - 104) ≤ (hiVal : ℝ) * (2 : ℝ) ^ (((eB : ℤ) - 160) - 80) := by
  have hc := checkExp1Entry_of_lt checkAllExp1_true hi
  unfold checkExp1Entry at hc
  generalize exp1Lookup i = res at hc ⊢
  rcases res with ⟨eB, lo, hiVal⟩
  dsimp only at hc ⊢
  by_cases h104 : i = 104
  · subst h104
    simp only [BEq.rfl, ↓reduceIte, Bool.and_eq_true, decide_eq_true_eq, beq_iff_eq] at hc
    rcases hc with ⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, heB⟩, hlo⟩, hhi⟩
    rw [heB, hlo, hhi]
    have hpow : (S79 : ℝ) * (2 : ℝ) ^ (((161 : ℤ) - 160) - 80) = 1 := by
      rw [S79_eq_pow, Nat.cast_pow, Nat.cast_ofNat, ← zpow_natCast (2 : ℝ) 79,
        ← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
      norm_num
    refine ⟨S79_eq_pow ▸ le_rfl, le_rfl,
      S79_eq_pow ▸ Nat.pow_lt_pow_right (by omega) (by omega), ?_, ?_⟩
    · simp only [Nat.cast_ofNat, sub_self, Real.exp_zero]; linarith
    · simp only [Nat.cast_ofNat, sub_self, Real.exp_zero]; linarith
  · have hne : (i == 104) = false := beq_false_of_ne h104
    simp only [hne, Bool.false_eq_true, ↓reduceIte] at hc
    have hqRat : (((i : Int) - 104 : Int) : Rat) = (i : Rat) - 104 := by push_cast; rfl
    rw [hqRat] at hc
    cases hred : LibcMath.ExpOracle.reducedEnclosure? r88Fast ((i : Rat) - 104) with
    | none => simp [hred] at hc
    | some p =>
      rcases p with ⟨m, iv⟩
      simp only [hred, Bool.and_eq_true, decide_eq_true_eq] at hc
      rcases hc with ⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, hivLo⟩, hivHi⟩, heDiff⟩, hloLe⟩, hhiLe⟩
      have h2ne : (2 : ℝ) ≠ 0 := by norm_num
      have horacle := LibcMath.ExpOracle.contains_reducedEnclosure? hred
      have hq : (((i : Rat) - 104 : Rat) : ℝ) = (i : ℝ) - 104 := by push_cast; ring
      rw [hq] at horacle
      have hscale88 : (scale r88Fast.precision : ℝ) = (S88 : ℝ) := by
        rw [scale_eq_pow]; exact_mod_cast S88_eq_pow.symm
      have hvalLo : value r88Fast.precision iv.lo = (iv.lo.toNat : ℝ) / (S88 : ℝ) := by
        rw [value, hscale88]
        have : (iv.lo : ℝ) = (iv.lo.toNat : ℝ) := by
          exact_mod_cast (Int.toNat_of_nonneg hivLo).symm
        rw [this]
      have hvalHi : value r88Fast.precision iv.hi = (iv.hi.toNat : ℝ) / (S88 : ℝ) := by
        rw [value, hscale88]
        have : (iv.hi : ℝ) = (iv.hi.toNat : ℝ) := by
          exact_mod_cast (Int.toNat_of_nonneg hivHi).symm
        rw [this]
      set sh := ((eB : ℤ) - 152 - m).toNat
      have hshInt : (sh : ℤ) = (eB : ℤ) - 152 - m := Int.toNat_of_nonneg heDiff
      have hexpEq : (2 : ℝ) ^ (((eB : ℤ) - 160) - 80) =
          (2 : ℝ) ^ sh / (S88 : ℝ) * (2 : ℝ) ^ m := by
        rw [S88_zpow, div_eq_mul_inv, ← zpow_natCast (2 : ℝ) sh,
          ← zpow_neg, mul_assoc, ← zpow_add₀ h2ne, ← zpow_add₀ h2ne]
        congr 1; omega
      have hloR : (lo : ℝ) * (2 : ℝ) ^ sh ≤ (iv.lo.toNat : ℝ) := by
        rw [Nat.shiftLeft_eq] at hloLe; exact_mod_cast hloLe
      have hhiR : (iv.hi.toNat : ℝ) ≤ (hiVal : ℝ) * (2 : ℝ) ^ sh := by
        rw [Nat.shiftLeft_eq] at hhiLe; exact_mod_cast hhiLe
      have hpos : (0 : ℝ) ≤ (2 : ℝ) ^ m / (S88 : ℝ) := div_nonneg (by positivity) S88_pos.le
      refine ⟨S79_eq_pow ▸ h1, h2, S80_eq_pow ▸ h3, ?_, ?_⟩
      · refine le_trans ?_ horacle.1
        rw [hvalLo, hexpEq]
        calc (lo : ℝ) * ((2 : ℝ) ^ sh / (S88 : ℝ) * (2 : ℝ) ^ m)
            = ((lo : ℝ) * (2 : ℝ) ^ sh) * ((2 : ℝ) ^ m / (S88 : ℝ)) := by ring
          _ ≤ (iv.lo.toNat : ℝ) * ((2 : ℝ) ^ m / (S88 : ℝ)) :=
              mul_le_mul_of_nonneg_right hloR hpos
          _ = (iv.lo.toNat : ℝ) / (S88 : ℝ) * (2 : ℝ) ^ m := by ring
      · refine le_trans horacle.2 ?_
        rw [hvalHi, hexpEq]
        calc (iv.hi.toNat : ℝ) / (S88 : ℝ) * (2 : ℝ) ^ m
            = (iv.hi.toNat : ℝ) * ((2 : ℝ) ^ m / (S88 : ℝ)) := by ring
          _ ≤ ((hiVal : ℝ) * (2 : ℝ) ^ sh) * ((2 : ℝ) ^ m / (S88 : ℝ)) :=
              mul_le_mul_of_nonneg_right hhiR hpos
          _ = (hiVal : ℝ) * ((2 : ℝ) ^ sh / (S88 : ℝ) * (2 : ℝ) ^ m) := by ring

/-- Certified enclosure for `exp2Lookup j` (`j < 128`). -/
theorem exp2Lookup_sound {j : Nat} (hj : j < 128) :
    let (lo, hiVal) := exp2Lookup j
    2 ^ 80 ≤ lo ∧ lo ≤ hiVal ∧ hiVal < 2 ^ 82 ∧
    (lo : ℝ) * (2 : ℝ) ^ (-80 : ℤ) ≤ Real.exp ((j : ℝ) / 128) ∧
    Real.exp ((j : ℝ) / 128) ≤ (hiVal : ℝ) * (2 : ℝ) ^ (-80 : ℤ) := by
  have hc := checkExp2Entry_of_lt checkAllExp2_true hj
  unfold checkExp2Entry at hc
  generalize exp2Lookup j = res at hc ⊢
  rcases res with ⟨lo, hiVal⟩
  dsimp only at hc ⊢
  by_cases h0 : j = 0
  · subst h0
    simp only [BEq.rfl, ↓reduceIte, Bool.and_eq_true, decide_eq_true_eq, beq_iff_eq] at hc
    rcases hc with ⟨⟨⟨⟨h1, h2⟩, h3⟩, hlo⟩, hhi⟩
    rw [hlo, hhi]
    have hpow : (S80 : ℝ) * (2 : ℝ) ^ (-80 : ℤ) = 1 := by
      rw [two_zpow_neg80, mul_one_div, div_self S80_pos.ne']
    refine ⟨S80_eq_pow ▸ le_rfl, le_rfl,
      S80_eq_pow ▸ Nat.pow_lt_pow_right (by omega) (by omega), ?_, ?_⟩
    · simp only [Nat.cast_zero, zero_div, Real.exp_zero]; linarith
    · simp only [Nat.cast_zero, zero_div, Real.exp_zero]; linarith
  · have hne : (j == 0) = false := beq_false_of_ne h0
    simp only [hne, Bool.false_eq_true, ↓reduceIte] at hc
    cases hred : LibcMath.ExpOracle.reducedEnclosure? r88Fast (Rat.divInt (j : Int) 128) with
    | none => simp [hred] at hc
    | some p =>
      rcases p with ⟨m, iv⟩
      simp only [hred, Bool.and_eq_true, decide_eq_true_eq] at hc
      rcases hc with ⟨⟨⟨⟨⟨⟨⟨h1, h2⟩, h3⟩, hivLo⟩, hivHi⟩, hshNN⟩, hloLe⟩, hhiLe⟩
      have h2ne : (2 : ℝ) ≠ 0 := by norm_num
      have horacle := LibcMath.ExpOracle.contains_reducedEnclosure? hred
      have hq : ((Rat.divInt (j : Int) 128 : Rat) : ℝ) = (j : ℝ) / 128 := by
        rw [Rat.divInt_eq_div]; push_cast; rfl
      rw [hq] at horacle
      have hscale88 : (scale r88Fast.precision : ℝ) = (S88 : ℝ) := by
        rw [scale_eq_pow]; exact_mod_cast S88_eq_pow.symm
      have hvalLo : value r88Fast.precision iv.lo = (iv.lo.toNat : ℝ) / (S88 : ℝ) := by
        rw [value, hscale88]
        have : (iv.lo : ℝ) = (iv.lo.toNat : ℝ) := by
          exact_mod_cast (Int.toNat_of_nonneg hivLo).symm
        rw [this]
      have hvalHi : value r88Fast.precision iv.hi = (iv.hi.toNat : ℝ) / (S88 : ℝ) := by
        rw [value, hscale88]
        have : (iv.hi : ℝ) = (iv.hi.toNat : ℝ) := by
          exact_mod_cast (Int.toNat_of_nonneg hivHi).symm
        rw [this]
      set sh := ((8 : ℤ) - m).toNat
      have hshInt : (sh : ℤ) = (8 : ℤ) - m := Int.toNat_of_nonneg hshNN
      have hexpEq : (2 : ℝ) ^ (-80 : ℤ) = (2 : ℝ) ^ sh / (S88 : ℝ) * (2 : ℝ) ^ m := by
        rw [S88_zpow, div_eq_mul_inv, ← zpow_natCast (2 : ℝ) sh,
          ← zpow_neg, mul_assoc, ← zpow_add₀ h2ne, ← zpow_add₀ h2ne]
        congr 1; omega
      have hloR : (lo : ℝ) * (2 : ℝ) ^ sh ≤ (iv.lo.toNat : ℝ) := by
        rw [Nat.shiftLeft_eq] at hloLe; exact_mod_cast hloLe
      have hhiR : (iv.hi.toNat : ℝ) ≤ (hiVal : ℝ) * (2 : ℝ) ^ sh := by
        rw [Nat.shiftLeft_eq] at hhiLe; exact_mod_cast hhiLe
      have hpos : (0 : ℝ) ≤ (2 : ℝ) ^ m / (S88 : ℝ) := div_nonneg (by positivity) S88_pos.le
      refine ⟨S80_eq_pow ▸ h1, h2, S82_eq_pow ▸ h3, ?_, ?_⟩
      · refine le_trans ?_ horacle.1
        rw [hvalLo, hexpEq]
        calc (lo : ℝ) * ((2 : ℝ) ^ sh / (S88 : ℝ) * (2 : ℝ) ^ m)
            = ((lo : ℝ) * (2 : ℝ) ^ sh) * ((2 : ℝ) ^ m / (S88 : ℝ)) := by ring
          _ ≤ (iv.lo.toNat : ℝ) * ((2 : ℝ) ^ m / (S88 : ℝ)) :=
              mul_le_mul_of_nonneg_right hloR hpos
          _ = (iv.lo.toNat : ℝ) / (S88 : ℝ) * (2 : ℝ) ^ m := by ring
      · refine le_trans horacle.2 ?_
        rw [hvalHi, hexpEq]
        calc (iv.hi.toNat : ℝ) / (S88 : ℝ) * (2 : ℝ) ^ m
            = (iv.hi.toNat : ℝ) * ((2 : ℝ) ^ m / (S88 : ℝ)) := by ring
          _ ≤ ((hiVal : ℝ) * (2 : ℝ) ^ sh) * ((2 : ℝ) ^ m / (S88 : ℝ)) :=
              mul_le_mul_of_nonneg_right hhiR hpos
          _ = (hiVal : ℝ) * ((2 : ℝ) ^ sh / (S88 : ℝ) * (2 : ℝ) ^ m) := by ring

/-- Certified enclosure for every entry of `EXP1_ENC`. -/
theorem EXP1_ENC_sound {i : Nat} (hi : i < EXP1_ENC.size) :
    let (exp2, lo, hiVal) := EXP1_ENC[i]
    2 ^ 79 ≤ lo ∧ lo ≤ hiVal ∧ hiVal < 2 ^ 80 ∧
    (lo : ℝ) * (2 : ℝ) ^ (exp2 - 80) ≤ Real.exp ((i : ℝ) - 104) ∧
    Real.exp ((i : ℝ) - 104) ≤ (hiVal : ℝ) * (2 : ℝ) ^ (exp2 - 80) := by
  have hi' : i < 195 := by simpa [EXP1_ENC] using hi
  simpa [EXP1_ENC] using exp1Lookup_sound hi'

/-- Certified enclosure for every entry of `EXP2_ENC`. -/
theorem EXP2_ENC_sound {j : Nat} (hj : j < EXP2_ENC.size) :
    let (lo, hiVal) := EXP2_ENC[j]
    2 ^ 80 ≤ lo ∧ lo ≤ hiVal ∧ hiVal < 2 ^ 82 ∧
    (lo : ℝ) * (2 : ℝ) ^ (-80 : ℤ) ≤ Real.exp ((j : ℝ) / 128) ∧
    Real.exp ((j : ℝ) / 128) ≤ (hiVal : ℝ) * (2 : ℝ) ^ (-80 : ℤ) := by
  have hj' : j < 128 := by simpa [EXP2_ENC] using hj
  simpa [EXP2_ENC] using exp2Lookup_sound hj'

/-! ## Real-analytic, binary32, and pure-`Nat` lemmas -/

private theorem complex_norm_exp_sub_sum_le (x : ℂ) (n : ℕ) :
    ‖Complex.exp x - ∑ m ∈ Finset.range n, x ^ m / (m.factorial : ℂ)‖ ≤
      ‖x‖ ^ n / (n.factorial : ℝ) * Real.exp ‖x‖ := by
  rw [← CauSeq.lim_const (abv := norm) (∑ m ∈ Finset.range n, _), Complex.exp, sub_eq_add_neg,
    ← CauSeq.lim_neg, CauSeq.lim_add, ← Complex.lim_norm]
  refine CauSeq.lim_le (CauSeq.le_of_exists ⟨n, fun j hj => ?_⟩)
  change ‖(∑ m ∈ Finset.range j, x ^ m / (m.factorial : ℂ)) -
    ∑ m ∈ Finset.range n, x ^ m / (m.factorial : ℂ)‖ ≤ _
  rw [← Finset.sum_Ico_eq_sub _ hj]
  calc
    ‖∑ m ∈ Finset.Ico n j, (x ^ m / (m.factorial : ℂ))‖
      = ‖∑ m ∈ Finset.Ico n j, (x ^ n * (x ^ (m - n) / (m.factorial : ℂ)))‖ := by
        congrm norm $(Finset.sum_congr rfl fun m hm => ?_)
        rw [Finset.mem_Ico] at hm
        rw [← mul_div_assoc, ← pow_add, add_tsub_cancel_of_le hm.1]
    _ ≤ ∑ m ∈ Finset.Ico n j, ‖x ^ n * (x ^ (m - n) / (m.factorial : ℂ))‖ :=
        IsAbsoluteValue.abv_sum norm ..
    _ ≤ ∑ m ∈ Finset.Ico n j,
          ‖x‖ ^ n / (n.factorial : ℝ) * (‖x‖ ^ (m - n) / ((m - n).factorial : ℝ)) := by
        refine Finset.sum_le_sum fun m hm => ?_
        rw [Finset.mem_Ico] at hm
        simp only [Complex.norm_mul, Complex.norm_pow, Complex.norm_div, Complex.norm_natCast]
        have hfac : n.factorial * (m - n).factorial ≤ m.factorial := by
          have h := Nat.factorial_mul_factorial_dvd_factorial_add n (m - n)
          rw [add_tsub_cancel_of_le hm.1] at h
          exact Nat.le_of_dvd (Nat.factorial_pos _) h
        have hfacR : (n.factorial : ℝ) * ((m - n).factorial : ℝ) ≤ (m.factorial : ℝ) := by
          exact_mod_cast hfac
        rw [← mul_div_assoc, div_mul_div_comm]
        exact div_le_div_of_nonneg_left (by positivity) (by positivity) hfacR
    _ = ‖x‖ ^ n / (n.factorial : ℝ) *
          ∑ m ∈ Finset.range (j - n), (‖x‖ ^ m / (m.factorial : ℝ)) := by
        simp [← Finset.mul_sum, Finset.sum_Ico_eq_sum_range]
    _ ≤ ‖x‖ ^ n / (n.factorial : ℝ) * Real.exp ‖x‖ := by
        gcongr
        exact Real.sum_le_exp_of_nonneg (norm_nonneg _) _

/-- Exact power-series remainder bound for `Real.exp` at any order `n` and any real `t`:
`|exp t - ∑_{m < n} t^m / m!| ≤ |t|^n / n! * exp |t|`. -/
private theorem abs_exp_sub_sum_le (t : ℝ) (n : ℕ) :
    |Real.exp t - ∑ m ∈ Finset.range n, t ^ m / (m.factorial : ℝ)| ≤
      |t| ^ n / (n.factorial : ℝ) * Real.exp |t| := by
  have h := complex_norm_exp_sub_sum_le (t : ℂ) n
  convert h using 1 <;> norm_cast

private theorem one_sub_le_exp_neg (δ : ℝ) : 1 - δ ≤ Real.exp (-δ) := by
  linarith [Real.add_one_le_exp (-δ)]

private theorem exp_le_one_add_add_sq {δ : ℝ} (h0 : 0 ≤ δ) (h1 : δ ≤ 1 / 2) :
    Real.exp δ ≤ 1 + δ + δ ^ 2 := by
  have hb := Real.exp_bound (x := δ) (by rw [abs_of_nonneg h0]; linarith) (n := 3) (by norm_num)
  simp only [Finset.sum_range_succ, Finset.sum_range_zero, Nat.factorial, abs_of_nonneg h0] at hb
  have hle := (abs_le.mp hb).2
  norm_num at hle
  nlinarith [sq_nonneg δ]

private theorem abs_exp_sub_exp_le_two_mul {a b : ℝ}
    (ha : |a| ≤ 1 / 256) (hb : |b| ≤ 1 / 256) :
    |Real.exp a - Real.exp b| ≤ 2 * |a - b| := by
  have helper : ∀ x y : ℝ, x ≤ y → |x| ≤ 1 / 256 → |y| ≤ 1 / 256 →
      Real.exp y - Real.exp x ≤ 2 * (y - x) := by
    intro x y hxy hx hy
    have hdiff0 : 0 ≤ y - x := sub_nonneg.mpr hxy
    have hdiff1 : y - x ≤ 1 / 2 := by
      have := abs_le.mp hx; have := abs_le.mp hy; linarith
    have hexpDiff := exp_le_one_add_add_sq hdiff0 hdiff1
    have hexpX : Real.exp x ≤ 1 + (1 / 256 : ℝ) + (1 / 256 : ℝ) ^ 2 := by
      have h1 : x ≤ 1 / 256 := (abs_le.mp hx).2
      exact (Real.exp_le_exp.mpr h1).trans (exp_le_one_add_add_sq (by norm_num) (by norm_num))
    have hfactor : Real.exp y - Real.exp x = Real.exp x * (Real.exp (y - x) - 1) := by
      rw [mul_sub, mul_one, ← Real.exp_add, add_sub_cancel]
    rw [hfactor]
    have hposX : 0 < Real.exp x := Real.exp_pos x
    have h1 : Real.exp (y - x) - 1 ≤ (y - x) + (y - x) ^ 2 := by linarith
    have h2 : (y - x) + (y - x) ^ 2 ≤ (3 / 2 : ℝ) * (y - x) := by nlinarith
    have h3 : Real.exp x * (Real.exp (y - x) - 1) ≤ Real.exp x * ((3 / 2 : ℝ) * (y - x)) :=
      mul_le_mul_of_nonneg_left (h1.trans h2) hposX.le
    nlinarith
  rcases le_total a b with hab | hba
  · rw [abs_of_nonpos (sub_nonpos.mpr (Real.exp_le_exp.mpr hab)),
      abs_of_nonpos (sub_nonpos.mpr hab), neg_sub, neg_sub]
    exact helper a b hab ha hb
  · rw [abs_of_nonneg (sub_nonneg.mpr (Real.exp_le_exp.mpr hba)),
      abs_of_nonneg (sub_nonneg.mpr hba)]
    exact helper b a hba hb ha

private theorem cheb3_bound {i R : ℝ} (hR : |i| ≤ R) :
    |4 * i ^ 3 - 3 * R ^ 2 * i| ≤ R ^ 3 := by
  have ⟨h1, h2⟩ := abs_le.mp hR
  rw [abs_le]
  constructor
  · nlinarith [mul_nonneg (by linarith : 0 ≤ R + i) (sq_nonneg (2 * i - R))]
  · nlinarith [mul_nonneg (by linarith : 0 ≤ R - i) (sq_nonneg (2 * i + R))]

private theorem cheb4_bound {i R : ℝ} (hR : |i| ≤ R) :
    |8 * i ^ 4 - 8 * R ^ 2 * i ^ 2 + R ^ 4| ≤ R ^ 4 := by
  have ⟨h1, h2⟩ := abs_le.mp hR
  rw [abs_le]
  constructor
  · nlinarith [sq_nonneg (2 * i ^ 2 - R ^ 2)]
  · nlinarith [mul_nonneg (sq_nonneg i)
      (mul_nonneg (by linarith : 0 ≤ R - i) (by linarith : 0 ≤ R + i))]

/-- Exact real decoding of a normal binary32 bit pattern `b`. -/
private theorem toReal_ofNatBits_normal {b : Nat} (hb : b < 0x100000000)
    (heb1 : 1 ≤ ((if Nat.ble 0x80000000 b then b - 0x80000000 else b) >>> 23))
    (heb2 : ((if Nat.ble 0x80000000 b then b - 0x80000000 else b) >>> 23) ≤ 254) :
    let neg := Nat.ble 0x80000000 b
    let mag := if neg then b - 0x80000000 else b
    let eb := mag >>> 23
    let frac := mag - (eb <<< 23)
    (Model.ofNatBits b : Model FloatFormat.binary32).toReal =
      (if neg then (-1 : ℝ) else 1) * ((2 ^ 23 + frac : ℕ) : ℝ) *
        (2 : ℝ) ^ ((eb : ℤ) - 150) := by
  intro neg mag eb frac
  set x : Model FloatFormat.binary32 := Model.ofNatBits b
  have hbits : x.toNatBits = b := Model.toNatBits_ofNatBits_of_lt b hb
  have hneg : x.signBit = neg := by
    cases h : neg
    · exact (Binary32.signBit_eq_false_iff x).mpr (hbits ▸ ble_false h)
    · exact (Binary32.signBit_eq_true_iff x).mpr (hbits ▸ ble_true h)
  have hmag_eq : x.toNatBits = (if x.signBit then 0x80000000 else 0) + x.magnitudeBits :=
    Model.toNatBits_eq_magnitude x
  have hmag : x.magnitudeBits = mag := by
    rw [hbits, hneg] at hmag_eq
    cases h : neg
    · have hm : mag = b := by simp [mag, h]
      rw [hm]; simp only [h, Bool.false_eq_true, ↓reduceIte, zero_add] at hmag_eq
      exact hmag_eq.symm
    · have hle : 0x80000000 ≤ b := ble_true h
      have hm : mag = b - 0x80000000 := by simp [mag, h]
      rw [hm]; simp only [h, ↓reduceIte] at hmag_eq
      omega
  have hmdecomp : x.magnitudeBits = x.expField * 0x800000 + x.fracField := rfl
  have hfracLt : x.fracField < 0x800000 := Model.fracField_lt_pow2 x
  have heb_eq : x.expField = eb := by
    have : eb = mag / 2 ^ 23 := by simp [eb, Nat.shiftRight_eq_div_pow]
    rw [this, ← hmag, hmdecomp]; omega
  have hfrac_eq : x.fracField = frac := by
    have h2 : eb <<< 23 = eb * 2 ^ 23 := by simp [Nat.shiftLeft_eq]
    have : frac = mag - eb * 2 ^ 23 := by simp [frac, h2]
    rw [this, ← heb_eq, ← hmag, hmdecomp]; omega
  have hfin : x.isFinite = true := by
    have hdef : x.isFinite = (x.expField != 255) := rfl
    have heb2' : eb ≤ 254 := heb2
    rw [hdef, heb_eq]
    exact bne_iff_ne.mpr (by omega)
  have hdyadSome := (Model.toDyadic?_isSome_eq_isFinite x).trans hfin
  obtain ⟨d, hd⟩ := Option.isSome_iff_exists.mp hdyadSome
  have hie : Model.ieeeToDyadic? x = some d := by simpa [Model.toDyadic?] using hd
  have hcases := Model.ieeeToDyadic?_eq_some_cases hie
  have heb1' : 1 ≤ eb := heb1
  have hne0 : x.expField ≠ 0 := by omega
  rcases hcases with ⟨he0, _, _⟩ | ⟨he0, _, _⟩ | ⟨_, rfl⟩
  · exact absurd he0 hne0
  · exact absurd he0 hne0
  · rw [Model.toReal_eq, hd]
    dsimp only
    rw [Model.Dyadic.toReal_mk, hneg, heb_eq, hfrac_eq]
    have hbpow : FloatLib.Floats.Formats.Flocq.bpow FloatLib.Numerics.binaryRadix
        (Int.ofNat eb - Int.ofNat (FloatFormat.ieeeNormalMantissaExpOffset FloatFormat.binary32)) =
        (2 : ℝ) ^ ((eb : ℤ) - 150) := rfl
    have hpow2 : Model.pow2 FloatFormat.binary32.fracWidth = 2 ^ 23 := by decide
    rw [hbpow, hpow2]

/-- Every bit pattern `b` in `[b_c - R, b_c + R]` inside a single normal binade equals
`f32(b_c).toReal + i * 2^(eb - 150)` for `|i| ≤ R`. -/
private theorem toReal_ofNatBits_binade_step {b_c R b : Nat}
    (hbc : b_c < 0x100000000)
    (heb1 : 1 ≤ ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) >>> 23))
    (heb2 : ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) >>> 23) ≤ 254)
    (hRlo : R ≤ ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) -
      (((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) >>> 23) <<< 23)))
    (hRhi : ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) -
      (((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) >>> 23) <<< 23)) + R < 0x800000)
    (hlo : b_c - R ≤ b) (hhi : b ≤ b_c + R) :
    let neg := Nat.ble 0x80000000 b_c
    let eb := (if neg then b_c - 0x80000000 else b_c) >>> 23
    let i : ℤ := if neg then (b_c : ℤ) - (b : ℤ) else (b : ℤ) - (b_c : ℤ)
    |i| ≤ (R : ℤ) ∧
    (Model.ofNatBits b : Model FloatFormat.binary32).toReal =
      (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal +
        (i : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150) := by
  intro neg eb i
  set mag := if neg then b_c - 0x80000000 else b_c
  set frac := mag - (eb <<< 23)
  have heb1' : 1 ≤ eb := heb1
  have heb2' : eb ≤ 254 := heb2
  have hRlo' : R ≤ frac := hRlo
  have hRhi' : frac + R < 0x800000 := hRhi
  have hebDiv : eb = mag / 2 ^ 23 := Nat.shiftRight_eq_div_pow mag 23
  have hshL : eb <<< 23 = eb * 2 ^ 23 := Nat.shiftLeft_eq eb 23
  have hmagDecomp : mag = eb * 2 ^ 23 + frac := by
    have : eb * 2 ^ 23 ≤ mag := by rw [hebDiv]; exact Nat.div_mul_le_self mag (2 ^ 23)
    have hf : frac = mag - eb * 2 ^ 23 := by rw [← hshL]
    omega
  have hbcDecomp : b_c = (if neg then 0x80000000 else 0) + mag := by
    cases h : neg
    · simp [mag, h]
    · have hge : 0x80000000 ≤ b_c := ble_true h
      simp only [mag, h, ↓reduceIte]; omega
  have hRleBc : R ≤ b_c := by omega
  have hnegB : Nat.ble 0x80000000 b = neg := by
    cases h : neg
    · have hlt : b_c < 0x80000000 := ble_false h
      have hmagEq : mag = b_c := by simp [mag, h]
      have hbLt : b < 0x80000000 := by omega
      cases hb' : Nat.ble 0x80000000 b
      · rfl
      · have := ble_true hb'; omega
    · have hge : 0x80000000 ≤ b_c := ble_true h
      have hmagEq : mag = b_c - 0x80000000 := by simp [mag, h]
      have hbGe : 0x80000000 ≤ b := by omega
      exact (Nat.ble_eq ..).mpr hbGe
  have hbLt : b < 0x100000000 := by
    cases h : neg <;> simp only [h, ↓reduceIte, Bool.false_eq_true, zero_add] at hbcDecomp <;> omega
  set magB := if Nat.ble 0x80000000 b then b - 0x80000000 else b
  have hmagB_eq : magB = eb * 2 ^ 23 + (frac + b - b_c) := by
    have hmB : magB = if neg then b - 0x80000000 else b := by simp [magB, hnegB]
    rw [hmB]
    cases h : neg <;>
      simp only [h, ↓reduceIte, Bool.false_eq_true, zero_add] at hbcDecomp ⊢ <;> omega
  have hfracB_lt : frac + b - b_c < 2 ^ 23 := by omega
  have hebB_eq : magB >>> 23 = eb := by
    rw [Nat.shiftRight_eq_div_pow, hmagB_eq]; omega
  have hfracB_eq : magB - ((magB >>> 23) <<< 23) = frac + b - b_c := by
    rw [hebB_eq, Nat.shiftLeft_eq, hmagB_eq]; omega
  have hbcReal := toReal_ofNatBits_normal hbc heb1 heb2
  have hbReal := toReal_ofNatBits_normal hbLt (hebB_eq ▸ heb1') (hebB_eq ▸ heb2')
  dsimp only at hbcReal hbReal
  change (Model.ofNatBits b : Model FloatFormat.binary32).toReal =
    (if Nat.ble 0x80000000 b then (-1 : ℝ) else 1) *
      ((2 ^ 23 + (magB - (magB >>> 23) <<< 23) : ℕ) : ℝ) *
      (2 : ℝ) ^ (((magB >>> 23 : ℕ) : ℤ) - 150) at hbReal
  rw [hnegB, hfracB_eq, hebB_eq] at hbReal
  change (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal =
    (if neg then (-1 : ℝ) else 1) * ((2 ^ 23 + frac : ℕ) : ℝ) *
      (2 : ℝ) ^ ((eb : ℤ) - 150) at hbcReal
  refine ⟨by rw [abs_le]; cases neg <;> dsimp only [i] <;> omega, ?_⟩
  rw [hbReal, hbcReal]
  have hdiff : ((2 ^ 23 + (frac + b - b_c) : ℕ) : ℝ) =
      ((2 ^ 23 + frac : ℕ) : ℝ) + ((b : ℝ) - (b_c : ℝ)) := by
    have h1 : b_c ≤ frac + b := by omega
    rw [Nat.cast_add, Nat.cast_add, Nat.cast_sub h1, Nat.cast_add]
    ring
  rw [hdiff]
  cases h : neg
  · simp only [h, Bool.false_eq_true, ↓reduceIte, i, Int.cast_sub, Int.cast_natCast]; ring
  · simp only [h, ↓reduceIte, i, Int.cast_sub, Int.cast_natCast]; ring

/-- Pure-`Nat` test for `(2 : ℝ) ^ ((a : ℤ) - (b : ℤ)) ≤ (v : ℝ)`. -/
def gePow2Diff (v a b : Nat) : Bool :=
  match Nat.ble a b with
  | true => Nat.ble 1 v
  | false => Nat.ble 1 (v >>> (a - b))

/-- Pure-`Nat` test for `(v : ℝ) ≤ (2 : ℝ) ^ ((a : ℤ) - (b : ℤ))`. -/
def lePow2Diff (v a b : Nat) : Bool :=
  match Nat.ble b a with
  | false => Nat.beq v 0
  | true =>
    match Nat.beq v 0 with
    | true => true
    | false => Nat.beq ((v - 1) >>> (a - b)) 0

private theorem gePow2Diff_sound {v a b : Nat} (h : gePow2Diff v a b = true) :
    (2 : ℝ) ^ ((a : ℤ) - (b : ℤ)) ≤ (v : ℝ) := by
  unfold gePow2Diff at h
  cases hab : Nat.ble a b with
  | true =>
    rw [hab] at h
    have hle : a ≤ b := ble_true hab
    have hv : 1 ≤ v := ble_true h
    calc (2 : ℝ) ^ ((a : ℤ) - (b : ℤ))
        ≤ (2 : ℝ) ^ (0 : ℤ) := zpow_le_zpow_right₀ (by norm_num) (by omega)
      _ = 1 := zpow_zero 2
      _ ≤ (v : ℝ) := by exact_mod_cast hv
  | false =>
    rw [hab] at h
    have hgt : b < a := ble_false hab
    have hsh : 1 ≤ v / 2 ^ (a - b) := by
      have := ble_true h; rwa [Nat.shiftRight_eq_div_pow] at this
    have hv : 2 ^ (a - b) ≤ v := by
      calc 2 ^ (a - b) = 1 * 2 ^ (a - b) := (one_mul _).symm
        _ ≤ (v / 2 ^ (a - b)) * 2 ^ (a - b) := Nat.mul_le_mul_right _ hsh
        _ ≤ v := Nat.div_mul_le_self v _
    have hexp : ((a : ℤ) - (b : ℤ)) = ((a - b : ℕ) : ℤ) := by omega
    rw [hexp, zpow_natCast]
    exact_mod_cast hv

private theorem lePow2Diff_sound {v a b : Nat} (h : lePow2Diff v a b = true) :
    (v : ℝ) ≤ (2 : ℝ) ^ ((a : ℤ) - (b : ℤ)) := by
  unfold lePow2Diff at h
  cases hba : Nat.ble b a with
  | false =>
    rw [hba] at h
    have hv0 : v = 0 := beq_true h
    rw [hv0, Nat.cast_zero]; positivity
  | true =>
    rw [hba] at h
    have hle : b ≤ a := ble_true hba
    have hexp : ((a : ℤ) - (b : ℤ)) = ((a - b : ℕ) : ℤ) := by omega
    rw [hexp, zpow_natCast]
    cases hv0 : Nat.beq v 0 with
    | true =>
      rw [beq_true hv0, Nat.cast_zero]; positivity
    | false =>
      rw [hv0] at h
      have hvNe : v ≠ 0 := beq_false hv0
      have hdiv0 : (v - 1) / 2 ^ (a - b) = 0 := by
        have := beq_true h; rwa [Nat.shiftRight_eq_div_pow] at this
      have hlt : v - 1 < 2 ^ (a - b) := by
        rcases Nat.div_eq_zero_iff.mp hdiv0 with h0 | hlt
        · exact absurd h0 (Nat.two_pow_pos _).ne'
        · exact hlt
      exact_mod_cast (by omega : v ≤ 2 ^ (a - b))

/-- Round a fixed-point number `P` at scale `2^80` (with upper slack `err`) to nearest `2^-64`.
Returns `(c, d)` where `c = ((P + 32768) >>> 16) % 2^64` and `d` bounds `|p * 2^80 - q * 2^16|`. -/
def round80to64 (P err : Nat) : Nat × Nat :=
  let r := P % 65536
  let q := (P + 32768) >>> 16
  let d := match Nat.ble 32768 r with
    | true => (65536 - r) + err
    | false => r + err
  (q % S64, d)

private theorem round80to64_sound {p : ℝ} {P err : Nat}
    (hlo : (P : ℝ) / (S80 : ℝ) ≤ p)
    (hhi : p ≤ ((P + err : ℕ) : ℝ) / (S80 : ℝ)) :
    let q := (P + 32768) >>> 16
    (round80to64 P err).1 < S64 ∧
    |p - (((q / S64 : ℕ) : ℝ) + ((round80to64 P err).1 : ℝ) / (S64 : ℝ))| ≤
      ((round80to64 P err).2 : ℝ) / (S80 : ℝ) := by
  intro q
  set c := (round80to64 P err).1
  set d := (round80to64 P err).2
  have hcEq : c = q % S64 := rfl
  have hcLt : c < S64 := hcEq ▸ Nat.mod_lt q (by decide)
  refine ⟨hcLt, ?_⟩
  have hqDecomp : q = (q / S64) * S64 + c := hcEq ▸ (Nat.div_add_mod' q S64).symm
  have hqReal : (((q / S64 : ℕ) : ℝ) + (c : ℝ) / (S64 : ℝ)) =
      (q : ℝ) * (65536 : ℝ) / (S80 : ℝ) := by
    have hqR : (q : ℝ) = ((q / S64 : ℕ) : ℝ) * (S64 : ℝ) + (c : ℝ) := by exact_mod_cast hqDecomp
    rw [hqR, S80_eq_S64_mul]
    have h64ne : (S64 : ℝ) ≠ 0 := S64_pos.ne'
    field_simp
  rw [hqReal, abs_le]
  set r := P % 65536
  have hrLt : r < 65536 := Nat.mod_lt P (by norm_num)
  have hPeq : P = (P / 65536) * 65536 + r := (Nat.div_add_mod' P 65536).symm
  have hqEq : q = (P + 32768) / 65536 := by
    simp only [q, Nat.shiftRight_eq_div_pow]
  have hlo' : (P : ℝ) ≤ p * (S80 : ℝ) := (div_le_iff₀ S80_pos).mp hlo
  have hhi' : p * (S80 : ℝ) ≤ (P : ℝ) + (err : ℝ) := by
    have := (le_div_iff₀ S80_pos).mp hhi; push_cast at this; linarith
  cases hr : Nat.ble 32768 r with
  | true =>
    have hge : 32768 ≤ r := ble_true hr
    have hqVal : q = P / 65536 + 1 := by rw [hqEq]; omega
    have hdVal : d = (65536 - r) + err := by simp [d, round80to64, r, hr]
    have hqMul : (q : ℝ) * 65536 = (P : ℝ) + ((65536 - r : ℕ) : ℝ) := by
      have hN : q * 65536 = P + (65536 - r) := by rw [hqVal]; omega
      exact_mod_cast hN
    have hdR : (d : ℝ) = ((65536 - r : ℕ) : ℝ) + (err : ℝ) := by rw [hdVal]; push_cast; rfl
    constructor
    · rw [le_sub_iff_add_le, ← neg_div, ← add_div, div_le_iff₀ S80_pos]; linarith
    · rw [sub_le_iff_le_add, ← add_div, le_div_iff₀ S80_pos]; linarith
  | false =>
    have hlt : r < 32768 := ble_false hr
    have hqVal : q = P / 65536 := by rw [hqEq]; omega
    have hdVal : d = r + err := by simp [d, round80to64, r, hr]
    have hqMul : (q : ℝ) * 65536 + (r : ℝ) = (P : ℝ) := by
      have hN : q * 65536 + r = P := by rw [hqVal]; omega
      exact_mod_cast hN
    have hdR : (d : ℝ) = (r : ℝ) + (err : ℝ) := by rw [hdVal]; push_cast; rfl
    constructor
    · rw [le_sub_iff_add_le, ← neg_div, ← add_div, div_le_iff₀ S80_pos]; linarith
    · rw [sub_le_iff_le_add, ← add_div, le_div_iff₀ S80_pos]; linarith

/-! ## Kernel-fast center enclosure `expSmallEnc` and `expCenterEnc` -/

/-- Pure-`Nat` degree-7 Taylor enclosure of `exp(±u)` at scale `2^80` for `u ≈ uN / 2^80 ≤ 2^-8`
with argument error `≤ errR / 2^80` (`errR ≤ 1`). -/
def expSmallEnc (rNeg : Bool) (uN errR : Nat) : Nat × Nat :=
  let t2 := (uN * uN) >>> 81
  let t3 := ((t2 * uN) >>> 80) / 3
  let t4 := (t3 * uN) >>> 82
  let t5 := ((t4 * uN) >>> 80) / 5
  let t6 := ((t5 * uN) >>> 81) / 3
  let t7 := ((t6 * uN) >>> 80) / 7
  let pad := 2 * errR
  match rNeg with
  | false =>
    let s := S80 + (uN + (t2 + (t3 + (t4 + (t5 + (t6 + t7))))))
    (s - (2 + pad), s + (14 + pad))
  | true =>
    let even := S80 + (t2 + (t4 + t6))
    let odd := uN + (t3 + (t5 + t7))
    let s := even - odd
    (s - (8 + pad), s + (8 + pad))

private theorem u0_le_inv256 {uN : Nat} (hu : uN ≤ 2 ^ 72) :
    (uN : ℝ) / (S80 : ℝ) ≤ 1 / 256 := by
  have h1 : (uN : ℝ) ≤ ((2 ^ 72 : ℕ) : ℝ) := by exact_mod_cast hu
  rw [div_le_iff₀ S80_pos]
  linarith [pow72_mul_256]

private theorem taylorStep_bounds {tPrev k uN : Nat} {exactPrev : ℝ}
    (hk : 2 ≤ k) (hu : uN ≤ 2 ^ 72)
    (hlo : (tPrev : ℝ) ≤ exactPrev) (hhi : exactPrev ≤ (tPrev : ℝ) + 2) :
    ((((tPrev * uN) >>> 80) / k : ℕ) : ℝ) ≤ exactPrev * ((uN : ℝ) / (S80 : ℝ)) / (k : ℝ) ∧
    exactPrev * ((uN : ℝ) / (S80 : ℝ)) / (k : ℝ) ≤
      ((((tPrev * uN) >>> 80) / k : ℕ) : ℝ) + 2 := by
  set u0 : ℝ := (uN : ℝ) / (S80 : ℝ)
  set tNext := ((tPrev * uN) >>> 80) / k
  have hkPos : (0 : ℝ) < (k : ℝ) := by exact_mod_cast (by omega : 0 < k)
  have hk2 : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hu0Le : u0 ≤ 1 / 256 := u0_le_inv256 hu
  have hu0NN : 0 ≤ u0 := div_nonneg (Nat.cast_nonneg uN) S80_pos.le
  have hdivEq : tNext = (tPrev * uN) / (S80 * k) := by
    simp only [tNext, Nat.shiftRight_eq_div_pow, Nat.div_div_eq_div_mul, S80_eq_pow]
  have hdenPos : 0 < S80 * k := Nat.mul_pos (by decide) (by omega)
  constructor
  · have h1 : (tNext : ℝ) ≤ ((tPrev * uN : ℕ) : ℝ) / ((S80 * k : ℕ) : ℝ) := by
      rw [hdivEq]; exact Nat.cast_div_le
    have h2 : ((tPrev * uN : ℕ) : ℝ) / ((S80 * k : ℕ) : ℝ) = (tPrev : ℝ) * u0 / (k : ℝ) := by
      push_cast; simp only [u0]; ring
    rw [h2] at h1
    exact h1.trans (div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_right hlo hu0NN) hkPos.le)
  · have hlt : tPrev * uN < (S80 * k) * (tNext + 1) := by
      rw [hdivEq]; exact Nat.lt_mul_div_succ (tPrev * uN) hdenPos
    have hltR : (tPrev : ℝ) * (uN : ℝ) < (S80 : ℝ) * (k : ℝ) * ((tNext : ℝ) + 1) := by
      have : ((tPrev * uN : ℕ) : ℝ) < (((S80 * k) * (tNext + 1) : ℕ) : ℝ) := by
        exact_mod_cast hlt
      push_cast at this; linarith
    have hstep : (tPrev : ℝ) * u0 / (k : ℝ) < (tNext : ℝ) + 1 := by
      rw [div_lt_iff₀ hkPos]
      have : (tPrev : ℝ) * u0 = (tPrev : ℝ) * (uN : ℝ) / (S80 : ℝ) := by simp only [u0]; ring
      rw [this, div_lt_iff₀ S80_pos]; linarith
    have hgap : (exactPrev - (tPrev : ℝ)) * u0 / (k : ℝ) ≤ 1 := by
      have hmul : (exactPrev - (tPrev : ℝ)) * u0 ≤ 2 * (1 / 256 : ℝ) := by nlinarith
      rw [div_le_one hkPos]; linarith
    have : exactPrev * u0 / (k : ℝ) =
        (tPrev : ℝ) * u0 / (k : ℝ) + (exactPrev - (tPrev : ℝ)) * u0 / (k : ℝ) := by ring
    linarith

private theorem expSmallEnc_sound {r : ℝ} {rNeg : Bool} {uN errR : Nat}
    (hu : uN ≤ 2 ^ 72) (herr : errR ≤ 1) (hr : |r| ≤ 1 / 256)
    (happrox : |r - (if rNeg then -((uN : ℝ) / (S80 : ℝ))
      else (uN : ℝ) / (S80 : ℝ))| ≤ (errR : ℝ) / (S80 : ℝ)) :
    (expSmallEnc rNeg uN errR).1 ≤ (expSmallEnc rNeg uN errR).2 ∧
    ((expSmallEnc rNeg uN errR).1 : ℝ) * (2 : ℝ) ^ (-80 : ℤ) ≤ Real.exp r ∧
    Real.exp r ≤ ((expSmallEnc rNeg uN errR).2 : ℝ) * (2 : ℝ) ^ (-80 : ℤ) := by
  set u0 : ℝ := (uN : ℝ) / (S80 : ℝ)
  set r0 : ℝ := if rNeg then -u0 else u0
  have hu0Le : u0 ≤ 1 / 256 := u0_le_inv256 hu
  have hu0NN : 0 ≤ u0 := div_nonneg (Nat.cast_nonneg uN) S80_pos.le
  have hr0Abs : |r0| ≤ 1 / 256 := by
    cases rNeg <;> simp only [r0, ↓reduceIte, Bool.false_eq_true, abs_neg, abs_of_nonneg hu0NN] <;>
      exact hu0Le
  set t2 := (uN * uN) >>> 81
  set t3 := ((t2 * uN) >>> 80) / 3
  set t4 := (t3 * uN) >>> 82
  set t5 := ((t4 * uN) >>> 80) / 5
  set t6 := ((t5 * uN) >>> 81) / 3
  set t7 := ((t6 * uN) >>> 80) / 7
  have ht2Eq : t2 = ((uN * uN) >>> 80) / 2 := by
    simp only [t2, Nat.shiftRight_eq_div_pow, Nat.div_div_eq_div_mul]
  have ht4Eq : t4 = ((t3 * uN) >>> 80) / 4 := by
    simp only [t4, Nat.shiftRight_eq_div_pow, Nat.div_div_eq_div_mul]
  have ht6Eq : t6 = ((t5 * uN) >>> 80) / 6 := by
    simp only [t6, Nat.shiftRight_eq_div_pow, Nat.div_div_eq_div_mul]
  have huN : (uN : ℝ) = u0 * (S80 : ℝ) := (div_mul_cancel₀ _ S80_pos.ne').symm
  have h1b : (uN : ℝ) ≤ u0 * (S80 : ℝ) ∧ u0 * (S80 : ℝ) ≤ (uN : ℝ) + 2 := by
    constructor <;> linarith
  have h2b : (t2 : ℝ) ≤ u0 ^ 2 / 2 * (S80 : ℝ) ∧ u0 ^ 2 / 2 * (S80 : ℝ) ≤ (t2 : ℝ) + 2 := by
    have h := taylorStep_bounds (k := 2) (by omega) hu h1b.1 h1b.2
    rw [← ht2Eq] at h
    convert h using 2 <;> norm_num <;> ring
  have h3b : (t3 : ℝ) ≤ u0 ^ 3 / 6 * (S80 : ℝ) ∧ u0 ^ 3 / 6 * (S80 : ℝ) ≤ (t3 : ℝ) + 2 := by
    have h := taylorStep_bounds (k := 3) (by omega) hu h2b.1 h2b.2
    convert h using 2 <;> norm_num <;> ring
  have h4b : (t4 : ℝ) ≤ u0 ^ 4 / 24 * (S80 : ℝ) ∧ u0 ^ 4 / 24 * (S80 : ℝ) ≤ (t4 : ℝ) + 2 := by
    have h := taylorStep_bounds (k := 4) (by omega) hu h3b.1 h3b.2
    rw [← ht4Eq] at h
    convert h using 2 <;> norm_num <;> ring
  have h5b : (t5 : ℝ) ≤ u0 ^ 5 / 120 * (S80 : ℝ) ∧ u0 ^ 5 / 120 * (S80 : ℝ) ≤ (t5 : ℝ) + 2 := by
    have h := taylorStep_bounds (k := 5) (by omega) hu h4b.1 h4b.2
    convert h using 2 <;> norm_num <;> ring
  have h6b : (t6 : ℝ) ≤ u0 ^ 6 / 720 * (S80 : ℝ) ∧ u0 ^ 6 / 720 * (S80 : ℝ) ≤ (t6 : ℝ) + 2 := by
    have h := taylorStep_bounds (k := 6) (by omega) hu h5b.1 h5b.2
    rw [← ht6Eq] at h
    convert h using 2 <;> norm_num <;> ring
  have h7b : (t7 : ℝ) ≤ u0 ^ 7 / 5040 * (S80 : ℝ) ∧ u0 ^ 7 / 5040 * (S80 : ℝ) ≤ (t7 : ℝ) + 2 := by
    have h := taylorStep_bounds (k := 7) (by omega) hu h6b.1 h6b.2
    convert h using 2 <;> norm_num <;> ring
  have htay : |Real.exp r0 - ∑ m ∈ Finset.range 8, r0 ^ m / (m.factorial : ℝ)| ≤
      2 / (S80 : ℝ) := by
    have h := abs_exp_sub_sum_le r0 8
    have hexpR0 : Real.exp |r0| ≤ 11 / 10 := by
      have := (Real.exp_le_exp.mpr hr0Abs).trans
        (exp_le_one_add_add_sq (by norm_num) (by norm_num))
      linarith
    have hpow : |r0| ^ 8 ≤ (1 / 256 : ℝ) ^ 8 := pow_le_pow_left₀ (abs_nonneg r0) hr0Abs 8
    have hnum : (1 / 256 : ℝ) ^ 8 / ((Nat.factorial 8 : ℕ) : ℝ) *
        (11 / 10 : ℝ) * (S80 : ℝ) ≤ 2 := by
      have hS : 256 ^ 8 * 65536 = S80 := by decide
      have hSR : (S80 : ℝ) = (256 : ℝ) ^ (8 : ℕ) * (65536 : ℝ) := by
        rw [← hS, Nat.cast_mul, Nat.cast_pow]; norm_num
      rw [hSR]; norm_num [Nat.factorial]
    refine h.trans ?_
    rw [le_div_iff₀ S80_pos]
    calc |r0| ^ 8 / ((Nat.factorial 8 : ℕ) : ℝ) * Real.exp |r0| * (S80 : ℝ)
        ≤ (1 / 256 : ℝ) ^ 8 / ((Nat.factorial 8 : ℕ) : ℝ) * (11 / 10 : ℝ) * (S80 : ℝ) := by
          gcongr
      _ ≤ 2 := hnum
  have harg : |Real.exp r - Real.exp r0| ≤ (2 * (errR : ℝ)) / (S80 : ℝ) := by
    have h := abs_exp_sub_exp_le_two_mul hr hr0Abs
    calc |Real.exp r - Real.exp r0| ≤ 2 * |r - r0| := h
      _ ≤ 2 * ((errR : ℝ) / (S80 : ℝ)) := by gcongr
      _ = (2 * (errR : ℝ)) / (S80 : ℝ) := by ring
  have hcomb : |Real.exp r - ∑ m ∈ Finset.range 8, r0 ^ m / (m.factorial : ℝ)| ≤
      (2 + 2 * (errR : ℝ)) / (S80 : ℝ) := by
    have htri : |Real.exp r - ∑ m ∈ Finset.range 8, r0 ^ m / (m.factorial : ℝ)| ≤
        |Real.exp r - Real.exp r0| +
          |Real.exp r0 - ∑ m ∈ Finset.range 8, r0 ^ m / (m.factorial : ℝ)| := by
      rw [show Real.exp r - ∑ m ∈ Finset.range 8, r0 ^ m / (m.factorial : ℝ) =
        (Real.exp r - Real.exp r0) +
          (Real.exp r0 - ∑ m ∈ Finset.range 8, r0 ^ m / (m.factorial : ℝ)) by ring]
      exact abs_add_le _ _
    linarith [htri, harg, htay, add_div (2 : ℝ) (2 * (errR : ℝ)) (S80 : ℝ)]
  have hsumExpand : ∑ m ∈ Finset.range 8, r0 ^ m / (m.factorial : ℝ) =
      1 + r0 + r0 ^ 2 / 2 + r0 ^ 3 / 6 + r0 ^ 4 / 24 +
        r0 ^ 5 / 120 + r0 ^ 6 / 720 + r0 ^ 7 / 5040 := by
    simp only [Finset.sum_range_succ, Finset.sum_range_zero, Nat.factorial]
    norm_num
  rw [hsumExpand] at hcomb
  have ⟨hcombLo, hcombHi⟩ := abs_le.mp hcomb
  cases rNeg with
  | false =>
    simp only [expSmallEnc]
    set s := S80 + (uN + (t2 + (t3 + (t4 + (t5 + (t6 + t7))))))
    set pad := 2 * errR
    have hsGe : 2 + pad ≤ s := by
      have : S80 ≤ s := Nat.le_add_right S80 _
      have : 2 + pad ≤ S80 := by unfold S80 pad; omega
      omega
    have hr0Eq : r0 = u0 := rfl
    rw [hr0Eq] at hcombLo hcombHi
    have hpolyDist : (1 + u0 + u0 ^ 2 / 2 + u0 ^ 3 / 6 + u0 ^ 4 / 24 +
        u0 ^ 5 / 120 + u0 ^ 6 / 720 + u0 ^ 7 / 5040) * (S80 : ℝ) =
        (S80 : ℝ) + u0 * (S80 : ℝ) + u0 ^ 2 / 2 * (S80 : ℝ) + u0 ^ 3 / 6 * (S80 : ℝ) +
        u0 ^ 4 / 24 * (S80 : ℝ) + u0 ^ 5 / 120 * (S80 : ℝ) +
        u0 ^ 6 / 720 * (S80 : ℝ) + u0 ^ 7 / 5040 * (S80 : ℝ) := by ring
    refine ⟨by omega, ?_, ?_⟩
    · rw [two_zpow_neg80, mul_one_div, div_le_iff₀ S80_pos]
      have hcast : ((s - (2 + pad) : ℕ) : ℝ) = (s : ℝ) - (2 + 2 * (errR : ℝ)) := by
        rw [Nat.cast_sub hsGe]; push_cast [pad]; ring
      rw [hcast]
      have hcombLo' : -(2 + 2 * (errR : ℝ)) ≤
          Real.exp r * (S80 : ℝ) - (1 + u0 + u0 ^ 2 / 2 + u0 ^ 3 / 6 + u0 ^ 4 / 24 +
            u0 ^ 5 / 120 + u0 ^ 6 / 720 + u0 ^ 7 / 5040) * (S80 : ℝ) := by
        have := mul_le_mul_of_nonneg_right hcombLo S80_pos.le
        rw [neg_mul, div_mul_cancel₀ _ S80_pos.ne', sub_mul] at this; linarith
      have hsR : (s : ℝ) = (S80 : ℝ) + (uN : ℝ) + (t2 : ℝ) + (t3 : ℝ) +
          (t4 : ℝ) + (t5 : ℝ) + (t6 : ℝ) + (t7 : ℝ) := by simp only [s]; push_cast; ring
      linarith [hpolyDist, hcombLo', hsR, huN, h2b.1, h3b.1, h4b.1, h5b.1, h6b.1, h7b.1]
    · rw [two_zpow_neg80, mul_one_div, le_div_iff₀ S80_pos]
      have hcombHi' : Real.exp r * (S80 : ℝ) - (1 + u0 + u0 ^ 2 / 2 + u0 ^ 3 / 6 + u0 ^ 4 / 24 +
            u0 ^ 5 / 120 + u0 ^ 6 / 720 + u0 ^ 7 / 5040) * (S80 : ℝ) ≤
          2 + 2 * (errR : ℝ) := by
        have := mul_le_mul_of_nonneg_right hcombHi S80_pos.le
        rw [div_mul_cancel₀ _ S80_pos.ne', sub_mul] at this; linarith
      have hsR : ((s + (14 + pad) : ℕ) : ℝ) = (S80 : ℝ) + (uN : ℝ) + (t2 : ℝ) +
          (t3 : ℝ) + (t4 : ℝ) + (t5 : ℝ) + (t6 : ℝ) + (t7 : ℝ) + 14 + 2 * (errR : ℝ) := by
        simp only [s, pad]; push_cast; ring
      linarith [hpolyDist, hcombHi', hsR, huN, h2b.2, h3b.2, h4b.2, h5b.2, h6b.2, h7b.2]
  | true =>
    simp only [expSmallEnc]
    set even := S80 + (t2 + (t4 + t6))
    set odd := uN + (t3 + (t5 + t7))
    set s := even - odd
    set pad := 2 * errR
    have hpow72 : (S72 : ℝ) = (1 / 256 : ℝ) * (S80 : ℝ) := by
      rw [← S72_mul_256]; ring
    have ht3N : t3 ≤ S72 := by
      have h : (t3 : ℝ) ≤ (S72 : ℝ) := by
        rw [hpow72]
        have hu3 : u0 ^ 3 / 6 ≤ 1 / 256 := by
          have h1 : u0 ^ 3 ≤ (1 / 256 : ℝ) ^ 3 := pow_le_pow_left₀ hu0NN hu0Le 3
          linarith [show (1 / 256 : ℝ) ^ 3 / 6 ≤ 1 / 256 by norm_num]
        exact h3b.1.trans (mul_le_mul_of_nonneg_right hu3 S80_pos.le)
      exact Nat.cast_le.mp h
    have ht5N : t5 ≤ S72 := by
      have h : (t5 : ℝ) ≤ (S72 : ℝ) := by
        rw [hpow72]
        have hu5 : u0 ^ 5 / 120 ≤ 1 / 256 := by
          have h1 : u0 ^ 5 ≤ (1 / 256 : ℝ) ^ 5 := pow_le_pow_left₀ hu0NN hu0Le 5
          linarith [show (1 / 256 : ℝ) ^ 5 / 120 ≤ 1 / 256 by norm_num]
        exact h5b.1.trans (mul_le_mul_of_nonneg_right hu5 S80_pos.le)
      exact Nat.cast_le.mp h
    have ht7N : t7 ≤ S72 := by
      have h : (t7 : ℝ) ≤ (S72 : ℝ) := by
        rw [hpow72]
        have hu7 : u0 ^ 7 / 5040 ≤ 1 / 256 := by
          have h1 : u0 ^ 7 ≤ (1 / 256 : ℝ) ^ 7 := pow_le_pow_left₀ hu0NN hu0Le 7
          linarith [show (1 / 256 : ℝ) ^ 7 / 5040 ≤ 1 / 256 by norm_num]
        exact h7b.1.trans (mul_le_mul_of_nonneg_right hu7 S80_pos.le)
      exact Nat.cast_le.mp h
    have hoddBound : odd + 8 + pad ≤ S80 := by
      have huS72 : uN ≤ S72 := S72_eq_pow ▸ hu
      have h4 : 4 * S72 + 10 ≤ S80 := by decide
      unfold odd pad; omega
    have hoddLeEven : odd ≤ even := by
      have : S80 ≤ even := Nat.le_add_right S80 _; omega
    have hsGe : 8 + pad ≤ s := by
      have : S80 ≤ even := Nat.le_add_right S80 _; omega
    have hr0Eq : r0 = -u0 := rfl
    rw [hr0Eq] at hcombLo hcombHi
    have hpolyDist : (1 + -u0 + (-u0) ^ 2 / 2 + (-u0) ^ 3 / 6 + (-u0) ^ 4 / 24 +
        (-u0) ^ 5 / 120 + (-u0) ^ 6 / 720 + (-u0) ^ 7 / 5040) * (S80 : ℝ) =
        ((S80 : ℝ) + u0 ^ 2 / 2 * (S80 : ℝ) + u0 ^ 4 / 24 * (S80 : ℝ) +
          u0 ^ 6 / 720 * (S80 : ℝ)) -
        (u0 * (S80 : ℝ) + u0 ^ 3 / 6 * (S80 : ℝ) + u0 ^ 5 / 120 * (S80 : ℝ) +
          u0 ^ 7 / 5040 * (S80 : ℝ)) := by ring
    have hsReal : (s : ℝ) = ((S80 : ℝ) + (t2 : ℝ) + (t4 : ℝ) + (t6 : ℝ)) -
        ((uN : ℝ) + (t3 : ℝ) + (t5 : ℝ) + (t7 : ℝ)) := by
      rw [show (s : ℝ) = (even : ℝ) - (odd : ℝ) by exact Nat.cast_sub hoddLeEven]
      simp only [even, odd]; push_cast; ring
    refine ⟨by omega, ?_, ?_⟩
    · rw [two_zpow_neg80, mul_one_div, div_le_iff₀ S80_pos]
      have hcast : ((s - (8 + pad) : ℕ) : ℝ) = (s : ℝ) - (8 + 2 * (errR : ℝ)) := by
        rw [Nat.cast_sub hsGe]; push_cast [pad]; ring
      rw [hcast]
      have hcombLo' : -(2 + 2 * (errR : ℝ)) ≤
          Real.exp r * (S80 : ℝ) - (1 + -u0 + (-u0) ^ 2 / 2 + (-u0) ^ 3 / 6 + (-u0) ^ 4 / 24 +
            (-u0) ^ 5 / 120 + (-u0) ^ 6 / 720 + (-u0) ^ 7 / 5040) * (S80 : ℝ) := by
        have := mul_le_mul_of_nonneg_right hcombLo S80_pos.le
        rw [neg_mul, div_mul_cancel₀ _ S80_pos.ne', sub_mul] at this; linarith
      linarith [hpolyDist, hcombLo', hsReal, huN, h2b.1, h3b.2, h4b.1, h5b.2, h6b.1, h7b.2]
    · rw [two_zpow_neg80, mul_one_div, le_div_iff₀ S80_pos]
      have hcast : ((s + (8 + pad) : ℕ) : ℝ) = (s : ℝ) + (8 + 2 * (errR : ℝ)) := by
        push_cast [pad]; ring
      rw [hcast]
      have hcombHi' :
          Real.exp r * (S80 : ℝ) - (1 + -u0 + (-u0) ^ 2 / 2 + (-u0) ^ 3 / 6 + (-u0) ^ 4 / 24 +
            (-u0) ^ 5 / 120 + (-u0) ^ 6 / 720 + (-u0) ^ 7 / 5040) * (S80 : ℝ) ≤
          2 + 2 * (errR : ℝ) := by
        have := mul_le_mul_of_nonneg_right hcombHi S80_pos.le
        rw [div_mul_cancel₀ _ S80_pos.ne', sub_mul] at this; linarith
      linarith [hpolyDist, hcombHi', hsReal, huN, h2b.2, h3b.1, h4b.2, h5b.1, h6b.2, h7b.1]

/-- Helper for `expCenterEncNat` when `119 ≤ eb ≤ 133` (`|x_c| ≥ 2^-8`). -/
private def expCenterLarge (neg : Bool) (eb sig : Nat) : Option (Nat × Nat × Nat) :=
  let s := 143 - eb
  let half := 1 <<< (s - 1)
  let q := (sig + half) >>> s
  let qs := q <<< s
  let (remMag, remSameSign) :=
    match Nat.ble qs sig with
    | true => (sig - qs, true)
    | false => (qs - sig, false)
  let rNeg := match neg with
    | true => remSameSign
    | false => !remSameSign
  let kShiftOpt := match neg with
    | false =>
      let ks := 13312 + q
      match Nat.ble 24960 ks with | true => none | false => some ks
    | true =>
      match Nat.ble q 13312 with | false => none | true => some (13312 - q)
  match kShiftOpt with
  | none => none
  | some kShift =>
    let hi := kShift >>> 7
    let mid := kShift - (hi <<< 7)
    let uN := remMag <<< (eb - 70)
    let (e1B, lo1, hi1) := exp1Lookup hi
    let (lo2, hi2) := exp2Lookup mid
    let (lo3, hi3) := expSmallEnc rNeg uN 0
    let p12Lo := (lo1 * lo2) >>> 80
    let p12Hi := ((hi1 * hi2) >>> 80) + 1
    let pLo := (p12Lo * lo3) >>> 80
    let pHi := ((p12Hi * hi3) >>> 80) + 1
    some (e1B, pLo, pHi)

/-- Helper for `expCenterEncNat` when `1 ≤ eb ≤ 118` (`|x_c| < 2^-8`). -/
private def expCenterSmall (neg : Bool) (eb sig : Nat) : Nat × Nat × Nat :=
  let (uN, errR) :=
    match Nat.ble 70 eb with
    | true => (sig <<< (eb - 70), 0)
    | false => (sig >>> (70 - eb), 1)
  let (lo3, hi3) := expSmallEnc neg uN errR
  (160, lo3, hi3)

private def expCenterCore (b_c : Nat) (neg : Bool) : Option (Nat × Nat × Nat) :=
  let mag := match neg with | true => b_c - 0x80000000 | false => b_c
  let eb := mag >>> 23
  match Nat.ble 1 eb with
  | false => none
  | true =>
    match Nat.ble eb 133 with
    | false => none
    | true =>
      let frac := mag - (eb <<< 23)
      let sig := 0x800000 + frac
      match Nat.ble 119 eb with
      | true => expCenterLarge neg eb sig
      | false => some (expCenterSmall neg eb sig)

/-- Pure-`Nat` center enclosure returning `(eBiased, aLo, aHi)` where `eA = (eBiased : Int) - 160`
and `aLo * 2^(eA - 80) ≤ Real.exp (f32(b_c).toReal) ≤ aHi * 2^(eA - 80)`. -/
def expCenterEncNat (b_c : Nat) : Option (Nat × Nat × Nat) :=
  match Nat.ble 0x100000000 b_c with
  | true => none
  | false => expCenterCore b_c (Nat.ble 0x80000000 b_c)

private theorem expCenterSmall_sound {neg : Bool} {eb sig : Nat}
    (heb1 : 1 ≤ eb) (heb118 : eb ≤ 118) (hsig : sig < 2 ^ 24) :
    let res := expCenterSmall neg eb sig
    let xc : ℝ := (if neg then (-1 : ℝ) else 1) * (sig : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150)
    res.2.1 ≤ res.2.2 ∧
    (res.2.1 : ℝ) * (2 : ℝ) ^ (((res.1 : ℤ) - 160) - 80) ≤ Real.exp xc ∧
    Real.exp xc ≤ (res.2.2 : ℝ) * (2 : ℝ) ^ (((res.1 : ℤ) - 160) - 80) := by
  intro res xc
  have h2ne : (2 : ℝ) ≠ 0 := by norm_num
  have hxcAbs : |xc| ≤ 1 / 256 := by
    simp only [xc, abs_mul]
    have hsign1 : |if neg then (-1 : ℝ) else 1| = 1 := by cases neg <;> simp
    have hpowPos : (0 : ℝ) < (2 : ℝ) ^ ((eb : ℤ) - 150) := by positivity
    rw [hsign1, one_mul, abs_of_nonneg (Nat.cast_nonneg sig), abs_of_pos hpowPos]
    have hsigR : (sig : ℝ) ≤ ((2 ^ 24 : ℕ) : ℝ) := by exact_mod_cast (by omega : sig ≤ 2 ^ 24)
    have hexpLe : (2 : ℝ) ^ ((eb : ℤ) - 150) ≤ (2 : ℝ) ^ (-32 : ℤ) :=
      zpow_le_zpow_right₀ (by norm_num) (by omega)
    calc (sig : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150)
        ≤ ((2 ^ 24 : ℕ) : ℝ) * (2 : ℝ) ^ (-32 : ℤ) := by gcongr
      _ = 1 / 256 := by norm_num
  cases heb70 : Nat.ble 70 eb with
  | true =>
    have h70 : 70 ≤ eb := ble_true heb70
    set uN := sig <<< (eb - 70)
    have huNLe : uN ≤ 2 ^ 72 := by
      have : uN = sig * 2 ^ (eb - 70) := Nat.shiftLeft_eq _ _
      rw [this]
      calc sig * 2 ^ (eb - 70) ≤ 2 ^ 24 * 2 ^ 48 :=
            Nat.mul_le_mul (by omega) (Nat.pow_le_pow_right (by norm_num) (by omega))
        _ = 2 ^ 72 := by decide
    have huNReal : (uN : ℝ) / (S80 : ℝ) = (sig : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150) := by
      have h1 : (uN : ℝ) = (sig : ℝ) * (2 : ℝ) ^ (eb - 70 : ℕ) := by
        have : uN = sig * 2 ^ (eb - 70) := Nat.shiftLeft_eq _ _
        exact_mod_cast this
      rw [h1, S80_zpow, mul_div_assoc, div_eq_mul_inv, ← zpow_natCast (2 : ℝ) (eb - 70),
        ← zpow_neg, ← zpow_add₀ h2ne]
      congr 2; omega
    have happrox : |xc - (if neg then -((uN : ℝ) / (S80 : ℝ))
        else (uN : ℝ) / (S80 : ℝ))| ≤ ((0 : ℕ) : ℝ) / (S80 : ℝ) := by
      simp only [xc]; rw [huNReal]
      cases neg <;> simp only [↓reduceIte, Bool.false_eq_true, one_mul, neg_mul, sub_self,
        abs_zero, Nat.cast_zero, zero_div, le_rfl]
    have hsmall := expSmallEnc_sound huNLe (by omega) hxcAbs happrox
    simpa [res, expCenterSmall, heb70, uN] using hsmall
  | false =>
    have hlt70 : eb < 70 := ble_false heb70
    set uN := sig >>> (70 - eb)
    have huNLe : uN ≤ 2 ^ 72 := by
      have : uN = sig / 2 ^ (70 - eb) := Nat.shiftRight_eq_div_pow _ _
      rw [this]; exact (Nat.div_le_self _ _).trans (by omega)
    have hmagBounds : (uN : ℝ) / (S80 : ℝ) ≤ (sig : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150) ∧
        (sig : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150) ≤ ((uN : ℝ) + 1) / (S80 : ℝ) := by
      have hexpEq : (2 : ℝ) ^ ((eb : ℤ) - 150) =
          1 / ((2 : ℝ) ^ (70 - eb : ℕ) * (S80 : ℝ)) := by
        rw [S80_zpow, one_div, mul_inv, ← zpow_natCast (2 : ℝ) (70 - eb),
          ← zpow_neg, ← zpow_neg, ← zpow_add₀ h2ne]
        congr 1; omega
      rw [hexpEq, mul_one_div, ← div_div]
      have huNDef : uN = sig / 2 ^ (70 - eb) := Nat.shiftRight_eq_div_pow _ _
      have hdivLo : (uN : ℝ) ≤ (sig : ℝ) / (2 : ℝ) ^ (70 - eb : ℕ) := by
        rw [huNDef]; exact_mod_cast (Nat.cast_div_le (α := ℝ) (m := sig) (n := 2 ^ (70 - eb)))
      have hdivHi : (sig : ℝ) / (2 : ℝ) ^ (70 - eb : ℕ) ≤ (uN : ℝ) + 1 := by
        rw [div_le_iff₀ (by positivity)]
        have hltN := (Nat.lt_mul_div_succ sig (Nat.two_pow_pos (70 - eb))).le
        rw [← huNDef] at hltN
        have : (sig : ℝ) ≤ ((2 ^ (70 - eb) * (uN + 1) : ℕ) : ℝ) := by exact_mod_cast hltN
        push_cast at this; linarith
      exact ⟨div_le_div_of_nonneg_right hdivLo S80_pos.le,
        div_le_div_of_nonneg_right hdivHi S80_pos.le⟩
    have happrox : |xc - (if neg then -((uN : ℝ) / (S80 : ℝ))
        else (uN : ℝ) / (S80 : ℝ))| ≤ ((1 : ℕ) : ℝ) / (S80 : ℝ) := by
      simp only [xc]
      cases neg <;> simp only [↓reduceIte, Bool.false_eq_true, one_mul, neg_mul, abs_le]
      · constructor <;> linarith [hmagBounds.1, hmagBounds.2, add_div (uN : ℝ) 1 (S80 : ℝ)]
      · constructor <;> linarith [hmagBounds.1, hmagBounds.2, add_div (uN : ℝ) 1 (S80 : ℝ)]
    have hsmall := expSmallEnc_sound huNLe (by omega) hxcAbs happrox
    simpa [res, expCenterSmall, heb70, uN] using hsmall

private theorem expCenterLarge_sound {neg : Bool} {eb sig eB aLo aHi : Nat}
    (h119 : 119 ≤ eb) (h133 : eb ≤ 133) (_hsig : sig < 2 ^ 24)
    (h : expCenterLarge neg eb sig = some (eB, aLo, aHi)) :
    let xc : ℝ := (if neg then (-1 : ℝ) else 1) * (sig : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150)
    aLo ≤ aHi ∧
    (aLo : ℝ) * (2 : ℝ) ^ (((eB : ℤ) - 160) - 80) ≤ Real.exp xc ∧
    Real.exp xc ≤ (aHi : ℝ) * (2 : ℝ) ^ (((eB : ℤ) - 160) - 80) := by
  intro xc
  unfold expCenterLarge at h
  dsimp only at h
  have h2ne : (2 : ℝ) ≠ 0 := by norm_num
  set s := 143 - eb
  set half := 1 <<< (s - 1)
  set q := (sig + half) >>> s
  set qs := q <<< s
  have hhalfEq : half = 2 ^ (s - 1) := by simp [half, Nat.shiftLeft_eq]
  have hqEq : q = (sig + 2 ^ (s - 1)) / 2 ^ s := by
    simp [q, hhalfEq, Nat.shiftRight_eq_div_pow]
  have hqsEq : qs = q * 2 ^ s := Nat.shiftLeft_eq q s
  have hpow2s : 2 ^ s = 2 * 2 ^ (s - 1) := by
    have : s = (s - 1) + 1 := by omega
    conv_lhs => rw [this, pow_succ]
    ring
  set remPair := match Nat.ble qs sig with | true => (sig - qs, true) | false => (qs - sig, false)
  set remMag := remPair.1
  set remSameSign := remPair.2
  set rNeg := match neg with | true => remSameSign | false => !remSameSign
  have hremLe : remMag ≤ 2 ^ (s - 1) := by
    have hdiv1 : qs ≤ sig + 2 ^ (s - 1) := by rw [hqsEq, hqEq]; exact Nat.div_mul_le_self _ _
    have hdiv2 : sig + 2 ^ (s - 1) < qs + 2 ^ s := by
      have := Nat.lt_mul_div_succ (sig + 2 ^ (s - 1)) (Nat.two_pow_pos s)
      rw [← hqEq, mul_comm, Nat.add_mul, one_mul, ← hqsEq] at this; exact this
    cases hqs : Nat.ble qs sig with
    | true =>
      have : qs ≤ sig := ble_true hqs
      simp only [remMag, remPair, hqs]; omega
    | false =>
      have : sig < qs := ble_false hqs
      simp only [remMag, remPair, hqs]; omega
  set kShiftOpt := match neg with
    | false =>
      let ks := 13312 + q
      match Nat.ble 24960 ks with | true => none | false => some ks
    | true =>
      match Nat.ble q 13312 with | false => none | true => some (13312 - q)
  cases hkOpt : kShiftOpt with
  | none => simp [hkOpt] at h
  | some kShift =>
    rw [hkOpt] at h; dsimp only at h
    have hkShiftLt : kShift < 24960 := by
      cases hneg : neg
      · simp only [kShiftOpt, hneg] at hkOpt
        cases hge : Nat.ble 24960 (13312 + q) with
        | true => simp [hge] at hkOpt
        | false =>
          simp only [hge, Option.some.injEq] at hkOpt
          have := ble_false hge; omega
      · simp only [kShiftOpt, hneg] at hkOpt
        cases hle : Nat.ble q 13312 with
        | false => simp [hle] at hkOpt
        | true =>
          simp only [hle, Option.some.injEq] at hkOpt
          subst hkOpt; exact Nat.lt_of_le_of_lt (Nat.sub_le 13312 q) (by decide)
    have hk128Real : ((kShift : ℝ) - 13312) / 128 =
        (if neg then (-1 : ℝ) else 1) * (qs : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150) := by
      have hqsExp : (qs : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150) = (q : ℝ) / 128 := by
        rw [hqsEq, Nat.cast_mul, Nat.cast_pow, Nat.cast_ofNat, mul_assoc,
          ← zpow_natCast (2 : ℝ) s, ← zpow_add₀ h2ne]
        rw [show (s : ℤ) + ((eb : ℤ) - 150) = (-7 : ℤ) by omega]
        norm_num; ring
      rw [mul_assoc, hqsExp]
      cases hneg : neg
      · simp only [kShiftOpt, hneg] at hkOpt
        cases hge : Nat.ble 24960 (13312 + q) with
        | true => simp [hge] at hkOpt
        | false =>
          simp only [hge, Option.some.injEq] at hkOpt
          rw [← hkOpt]; push_cast; simp
      · simp only [kShiftOpt, hneg] at hkOpt
        cases hle : Nat.ble q 13312 with
        | false => simp [hle] at hkOpt
        | true =>
          simp only [hle, Option.some.injEq] at hkOpt
          have hqLe : q ≤ 13312 := ble_true hle
          rw [← hkOpt, Nat.cast_sub hqLe]; push_cast; simp; ring
    set hi := kShift >>> 7
    set mid := kShift - (hi <<< 7)
    have hhiLt : hi < 195 := by
      have : hi = kShift / 128 := Nat.shiftRight_eq_div_pow kShift 7; omega
    have hmidLt : mid < 128 := by
      have h1 : hi = kShift / 128 := Nat.shiftRight_eq_div_pow kShift 7
      have h2 : hi <<< 7 = hi * 128 := Nat.shiftLeft_eq hi 7
      have : mid = kShift - hi * 128 := by simp [mid, h2]
      omega
    have hkSplit : ((hi : ℝ) - 104) + (mid : ℝ) / 128 = ((kShift : ℝ) - 13312) / 128 := by
      have h1 : hi = kShift / 128 := Nat.shiftRight_eq_div_pow kShift 7
      have h2 : hi <<< 7 = hi * 128 := Nat.shiftLeft_eq hi 7
      have hN : hi * 128 + mid = kShift := by
        have : mid = kShift - hi * 128 := by simp [mid, h2]
        omega
      have hR : (hi : ℝ) * 128 + (mid : ℝ) = (kShift : ℝ) := by exact_mod_cast hN
      linarith
    set uN := remMag <<< (eb - 70)
    have huNLe : uN ≤ 2 ^ 72 := by
      have : uN = remMag * 2 ^ (eb - 70) := Nat.shiftLeft_eq _ _
      rw [this]
      calc remMag * 2 ^ (eb - 70)
          ≤ 2 ^ (s - 1) * 2 ^ (eb - 70) := Nat.mul_le_mul_right _ hremLe
        _ = 2 ^ ((s - 1) + (eb - 70)) := (pow_add 2 _ _).symm
        _ = 2 ^ 72 := by congr 1; omega
    set r : ℝ := xc - ((kShift : ℝ) - 13312) / 128
    have hrEq : r = if rNeg then -((uN : ℝ) / (S80 : ℝ)) else (uN : ℝ) / (S80 : ℝ) := by
      have huNReal : (uN : ℝ) / (S80 : ℝ) = (remMag : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150) := by
        have h1 : (uN : ℝ) = (remMag : ℝ) * (2 : ℝ) ^ (eb - 70 : ℕ) := by
          have : uN = remMag * 2 ^ (eb - 70) := Nat.shiftLeft_eq _ _
          exact_mod_cast this
        rw [h1, S80_zpow, mul_div_assoc, div_eq_mul_inv, ← zpow_natCast (2 : ℝ) (eb - 70),
          ← zpow_neg, ← zpow_add₀ h2ne]
        congr 2; omega
      simp only [r, xc]; rw [hk128Real, huNReal]
      cases hqs : Nat.ble qs sig with
      | true =>
        have hle : qs ≤ sig := ble_true hqs
        have hrem : (remMag : ℝ) = (sig : ℝ) - (qs : ℝ) := by
          simp only [remMag, remPair, hqs]; exact Nat.cast_sub hle
        have hrNegEq : rNeg = neg := by
          simp only [rNeg, remSameSign, remPair, hqs]; cases neg <;> rfl
        rw [hrem, hrNegEq]; cases neg <;> simp only [↓reduceIte, Bool.false_eq_true] <;> ring
      | false =>
        have hlt : sig ≤ qs := (ble_false hqs).le
        have hrem : (remMag : ℝ) = (qs : ℝ) - (sig : ℝ) := by
          simp only [remMag, remPair, hqs]; exact Nat.cast_sub hlt
        have hrNegEq : rNeg = !neg := by
          simp only [rNeg, remSameSign, remPair, hqs]; cases neg <;> rfl
        rw [hrem, hrNegEq]; cases neg <;> simp only [Bool.not_true, Bool.not_false, ↓reduceIte,
          Bool.false_eq_true] <;> ring
    have hrAbs : |r| ≤ 1 / 256 := by
      rw [hrEq]
      have huR : (uN : ℝ) / (S80 : ℝ) ≤ 1 / 256 := u0_le_inv256 huNLe
      have huNN : (0 : ℝ) ≤ (uN : ℝ) / (S80 : ℝ) := div_nonneg (Nat.cast_nonneg uN) S80_pos.le
      cases rNeg <;> simp only [↓reduceIte, Bool.false_eq_true, abs_neg, abs_of_nonneg huNN] <;>
        exact huR
    have happrox : |r - (if rNeg then -((uN : ℝ) / (S80 : ℝ)) else (uN : ℝ) / (S80 : ℝ))| ≤
        ((0 : ℕ) : ℝ) / (S80 : ℝ) := by
      rw [hrEq, sub_self, abs_zero]; norm_num
    have h1 := exp1Lookup_sound hhiLt
    have h2 := exp2Lookup_sound hmidLt
    have h3 := expSmallEnc_sound huNLe (by omega) hrAbs happrox
    generalize exp1Lookup hi = res1 at h h1
    generalize exp2Lookup mid = res2 at h h2
    generalize expSmallEnc rNeg uN 0 = res3 at h h3
    rcases res1 with ⟨e1B, lo1, hi1⟩
    rcases res2 with ⟨lo2, hi2⟩
    rcases res3 with ⟨lo3, hi3⟩
    dsimp only at h h1 h2 h3
    obtain ⟨rfl, rfl, rfl⟩ := Prod.mk.inj (Option.some.inj h)
    set p12Lo := (lo1 * lo2) >>> 80
    set p12Hi := ((hi1 * hi2) >>> 80) + 1
    have hp12Le : p12Lo ≤ p12Hi := by
      have : lo1 * lo2 ≤ hi1 * hi2 := Nat.mul_le_mul h1.2.1 h2.2.1
      have : (lo1 * lo2) / 2 ^ 80 ≤ (hi1 * hi2) / 2 ^ 80 := Nat.div_le_div_right this
      simp only [p12Lo, p12Hi, Nat.shiftRight_eq_div_pow]; omega
    have hpLe : (p12Lo * lo3) >>> 80 ≤ ((p12Hi * hi3) >>> 80) + 1 := by
      have : p12Lo * lo3 ≤ p12Hi * hi3 := Nat.mul_le_mul hp12Le h3.1
      have : (p12Lo * lo3) / 2 ^ 80 ≤ (p12Hi * hi3) / 2 ^ 80 := Nat.div_le_div_right this
      simp only [Nat.shiftRight_eq_div_pow]; omega
    have hexpProd : Real.exp xc =
        Real.exp ((hi : ℝ) - 104) * Real.exp ((mid : ℝ) / 128) * Real.exp r := by
      rw [← Real.exp_add, ← Real.exp_add, hkSplit]; congr 1; simp only [r]; ring
    have hpowE : (0 : ℝ) < (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) := by positivity
    have hshiftLo : ∀ a b : Nat,
        (((a * b) >>> 80 : ℕ) : ℝ) ≤ (a : ℝ) * (b : ℝ) * (2 : ℝ) ^ (-80 : ℤ) := by
      intro a b
      rw [Nat.shiftRight_eq_div_pow, two_zpow_neg80, mul_one_div, ← S80_eq_pow]
      exact_mod_cast (Nat.cast_div_le (α := ℝ) (m := a * b) (n := S80))
    have hshiftHi : ∀ a b : Nat,
        (a : ℝ) * (b : ℝ) * (2 : ℝ) ^ (-80 : ℤ) ≤ ((((a * b) >>> 80) + 1 : ℕ) : ℝ) := by
      intro a b
      rw [Nat.shiftRight_eq_div_pow, two_zpow_neg80, mul_one_div, ← S80_eq_pow, div_le_iff₀ S80_pos]
      have hltN := (Nat.lt_mul_div_succ (a * b) (by decide : 0 < S80)).le
      have : ((a * b : ℕ) : ℝ) ≤ ((S80 * (a * b / S80 + 1) : ℕ) : ℝ) := by exact_mod_cast hltN
      push_cast at this ⊢; linarith
    refine ⟨hpLe, ?_, ?_⟩
    · rw [hexpProd]
      have hp12 : (p12Lo : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) ≤
          Real.exp ((hi : ℝ) - 104) * Real.exp ((mid : ℝ) / 128) := by
        calc (p12Lo : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80)
            ≤ ((lo1 : ℝ) * (lo2 : ℝ) * (2 : ℝ) ^ (-80 : ℤ)) *
                (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) :=
              mul_le_mul_of_nonneg_right (hshiftLo lo1 lo2) hpowE.le
          _ = ((lo1 : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80)) *
                ((lo2 : ℝ) * (2 : ℝ) ^ (-80 : ℤ)) := by ring
          _ ≤ Real.exp ((hi : ℝ) - 104) * Real.exp ((mid : ℝ) / 128) :=
              mul_le_mul h1.2.2.2.1 h2.2.2.2.1 (by positivity) (Real.exp_pos _).le
      calc (((p12Lo * lo3) >>> 80 : ℕ) : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80)
          ≤ ((p12Lo : ℝ) * (lo3 : ℝ) * (2 : ℝ) ^ (-80 : ℤ)) *
              (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) :=
            mul_le_mul_of_nonneg_right (hshiftLo p12Lo lo3) hpowE.le
        _ = ((p12Lo : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80)) *
              ((lo3 : ℝ) * (2 : ℝ) ^ (-80 : ℤ)) := by ring
        _ ≤ Real.exp ((hi : ℝ) - 104) * Real.exp ((mid : ℝ) / 128) * Real.exp r :=
            mul_le_mul hp12 h3.2.1 (by positivity)
              (mul_nonneg (Real.exp_pos _).le (Real.exp_pos _).le)
    · rw [hexpProd]
      have hp12 : Real.exp ((hi : ℝ) - 104) * Real.exp ((mid : ℝ) / 128) ≤
          (p12Hi : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) := by
        calc Real.exp ((hi : ℝ) - 104) * Real.exp ((mid : ℝ) / 128)
            ≤ ((hi1 : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80)) *
                ((hi2 : ℝ) * (2 : ℝ) ^ (-80 : ℤ)) :=
              mul_le_mul h1.2.2.2.2 h2.2.2.2.2 (Real.exp_pos _).le (by positivity)
          _ = ((hi1 : ℝ) * (hi2 : ℝ) * (2 : ℝ) ^ (-80 : ℤ)) *
                (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) := by ring
          _ ≤ (p12Hi : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) :=
              mul_le_mul_of_nonneg_right (hshiftHi hi1 hi2) hpowE.le
      calc Real.exp ((hi : ℝ) - 104) * Real.exp ((mid : ℝ) / 128) * Real.exp r
          ≤ ((p12Hi : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80)) *
              ((hi3 : ℝ) * (2 : ℝ) ^ (-80 : ℤ)) :=
            mul_le_mul hp12 h3.2.2 (Real.exp_pos _).le (by positivity)
        _ = ((p12Hi : ℝ) * (hi3 : ℝ) * (2 : ℝ) ^ (-80 : ℤ)) *
              (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) := by ring
        _ ≤ ((((p12Hi * hi3) >>> 80) + 1 : ℕ) : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) :=
            mul_le_mul_of_nonneg_right (hshiftHi p12Hi hi3) hpowE.le

private theorem expCenterCore_sound {b_c eB aLo aHi : Nat} {neg : Bool}
    (hbc : b_c < 0x100000000) (hneg : Nat.ble 0x80000000 b_c = neg)
    (h : expCenterCore b_c neg = some (eB, aLo, aHi)) :
    b_c < 0x100000000 ∧ aLo ≤ aHi ∧
    (aLo : ℝ) * (2 : ℝ) ^ (((eB : ℤ) - 160) - 80) ≤
      Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal ∧
    Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal ≤
      (aHi : ℝ) * (2 : ℝ) ^ (((eB : ℤ) - 160) - 80) := by
  unfold expCenterCore at h
  dsimp only at h
  set mag := match neg with | true => b_c - 0x80000000 | false => b_c
  set eb := mag >>> 23
  have hmagEq : mag = if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c :=
    match_bool_eq_ite _ _ hneg
  cases heb1B : Nat.ble 1 eb with
  | false => simp [heb1B] at h
  | true =>
    simp only [heb1B] at h
    have heb1 : 1 ≤ eb := ble_true heb1B
    cases heb2B : Nat.ble eb 133 with
    | false => simp [heb2B] at h
    | true =>
      simp only [heb2B] at h
      have heb2 : eb ≤ 133 := ble_true heb2B
      have heb1' : 1 ≤ ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) >>> 23) := by
        rw [← hmagEq]; exact heb1
      have heb2' : ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) >>> 23) ≤ 254 := by
        rw [← hmagEq]; change eb ≤ 254; omega
      have hxc := toReal_ofNatBits_normal hbc heb1' heb2'
      dsimp only at hxc
      rw [← hmagEq, hneg] at hxc
      set frac := mag - (eb <<< 23)
      set sig := 0x800000 + frac
      have hfracLt : frac < 2 ^ 23 := by
        have h1 : eb = mag / 2 ^ 23 := Nat.shiftRight_eq_div_pow mag 23
        have h2 : eb <<< 23 = eb * 2 ^ 23 := Nat.shiftLeft_eq eb 23
        have : frac = mag - eb * 2 ^ 23 := by simp [frac, h2]
        omega
      have hsigLt : sig < 2 ^ 24 := by unfold sig; omega
      have hxcSig : (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal =
          (if neg then (-1 : ℝ) else 1) * (sig : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150) := hxc
      cases heb119 : Nat.ble 119 eb with
      | true =>
        simp only [heb119] at h
        have hl := expCenterLarge_sound (ble_true heb119) heb2 hsigLt h
        rw [← hxcSig] at hl
        exact ⟨hbc, hl⟩
      | false =>
        simp only [heb119, Option.some.injEq] at h
        have hs := expCenterSmall_sound (neg := neg) heb1
          (by have := ble_false heb119; omega) hsigLt
        rw [h, ← hxcSig] at hs
        exact ⟨hbc, hs⟩

private theorem expCenterEncNat_sound {b_c eB aLo aHi : Nat}
    (h : expCenterEncNat b_c = some (eB, aLo, aHi)) :
    b_c < 0x100000000 ∧ aLo ≤ aHi ∧
    (aLo : ℝ) * (2 : ℝ) ^ (((eB : ℤ) - 160) - 80) ≤
      Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal ∧
    Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal ≤
      (aHi : ℝ) * (2 : ℝ) ^ (((eB : ℤ) - 160) - 80) := by
  unfold expCenterEncNat at h
  cases hlt : Nat.ble 0x100000000 b_c with
  | true => simp [hlt] at h
  | false =>
    simp only [hlt] at h
    exact expCenterCore_sound (ble_false hlt) rfl h

/-- Kernel-fast center enclosure `expCenterEnc b_c = some (eA, aLo, aHi)` satisfying
`aLo * 2^(eA - 80) ≤ Real.exp (f32(b_c).toReal) ≤ aHi * 2^(eA - 80)`. -/
def expCenterEnc (b_c : Nat) : Option (Int × Nat × Nat) :=
  match expCenterEncNat b_c with
  | none => none
  | some (eB, aLo, aHi) => some ((eB : Int) - 160, aLo, aHi)

/-- Soundness of `expCenterEnc`. -/
theorem expCenterEnc_sound {b_c : Nat} {eA : Int} {aLo aHi : Nat}
    (h : expCenterEnc b_c = some (eA, aLo, aHi)) :
    b_c < 0x100000000 ∧ aLo ≤ aHi ∧
    (aLo : ℝ) * (2 : ℝ) ^ (eA - 80) ≤
      Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal ∧
    Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal ≤
      (aHi : ℝ) * (2 : ℝ) ^ (eA - 80) := by
  unfold expCenterEnc at h
  cases hnat : expCenterEncNat b_c with
  | none => simp [hnat] at h
  | some p =>
    rcases p with ⟨eB, lo, hi⟩
    simp only [hnat, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl, rfl⟩ := h
    exact expCenterEncNat_sound hnat

/-! ## Chebyshev-economized polynomial builders `polyApproxD2` and `polyApproxD3` -/

/-- Convert `E ∈ [-127, 127]` to biased `eOff = (E + 127).toNat ∈ [0, 254]` without `Int` ops. -/
def intToEOff? (E : Int) : Option Nat :=
  match E with
  | .ofNat n => match Nat.ble n 127 with | true => some (n + 127) | false => none
  | .negSucc n => match Nat.ble n 126 with | true => some (126 - n) | false => none

private theorem intToEOff?_sound {E : Int} {eOff : Nat} (h : intToEOff? E = some eOff) :
    (-127 : ℤ) ≤ E ∧ E ≤ 127 ∧ eOff ≤ 254 ∧ (eOff : ℤ) - 127 = E := by
  cases E with
  | ofNat n =>
    simp only [intToEOff?] at h
    cases hb : Nat.ble n 127 with
    | false => simp [hb] at h
    | true =>
      simp only [hb, Option.some.injEq] at h
      have hn : n ≤ 127 := ble_true hb
      have hInt : Int.ofNat n = (n : ℤ) := rfl
      rw [hInt]; omega
  | negSucc n =>
    simp only [intToEOff?] at h
    cases hb : Nat.ble n 126 with
    | false => simp [hb] at h
    | true =>
      simp only [hb, Option.some.injEq] at h
      have hn : n ≤ 126 := ble_true hb
      have hInt : Int.negSucc n = -((n : ℤ) + 1) := rfl
      rw [hInt]; omega

private def checkBinadeLo (neg : Bool) (b_c R e1B aLo expNegLo64 loBiased : Nat) : Bool :=
  match gePow2Diff (aLo * expNegLo64) (loBiased + 144) e1B with
  | true => true
  | false =>
    let bLo := match neg with | true => b_c + R | false => b_c - R
    match expCenterEncNat bLo with
    | none => false
    | some (eLoB, loEnd, _) => gePow2Diff loEnd (loBiased + 80) eLoB

private def checkBinadeHi (neg : Bool) (b_c R e1B aHi expPosHi64 hiBiased : Nat) : Bool :=
  match lePow2Diff (aHi * expPosHi64) (hiBiased + 144) e1B with
  | true => true
  | false =>
    let bHi := match neg with | true => b_c - R | false => b_c + R
    match expCenterEncNat bHi with
    | none => false
    | some (eHiB, _, hiEnd) => lePow2Diff hiEnd (hiBiased + 80) eHiB

/-- Check output-binade containment for all `b ∈ [b_c - R, b_c + R]` using the fast 1-mul bound
first, falling back to exact endpoint `expCenterEncNat` only near binade boundaries. -/
private def checkBinade (neg : Bool) (b_c R e1B aLo aHi expNegLo64 expPosHi64
    loBiased hiBiased : Nat) : Bool :=
  match checkBinadeLo neg b_c R e1B aLo expNegLo64 loBiased with
  | false => false
  | true => checkBinadeHi neg b_c R e1B aHi expPosHi64 hiBiased

private theorem checkBinade_sound {b_c R e1B aLo aHi expNegLo64 expPosHi64 eOff : Nat}
    {E : ℤ} {b : Nat}
    (hE : (-127 : ℤ) ≤ E ∧ E ≤ 127 ∧ eOff ≤ 254 ∧ (eOff : ℤ) - 127 = E)
    (hbc : b_c < 0x100000000)
    (heb1 : 1 ≤ ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) >>> 23))
    (heb2 : ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) >>> 23) ≤ 133)
    (hRlo : R ≤ ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) -
      (((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) >>> 23) <<< 23)))
    (hRhi : ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) -
      (((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) >>> 23) <<< 23)) + R < 0x800000)
    (hlo : b_c - R ≤ b) (hhi : b ≤ b_c + R)
    (hcLo : (aLo : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) ≤
      Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal)
    (hcHi : Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal ≤
      (aHi : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80))
    (hneg64 : (expNegLo64 : ℝ) / (S64 : ℝ) ≤
      Real.exp (-((R : ℝ) * (2 : ℝ) ^
        ((((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) >>> 23 : ℕ) : ℤ) - 150))))
    (hpos64 : Real.exp ((R : ℝ) * (2 : ℝ) ^
        ((((if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c) >>> 23 : ℕ) : ℤ) - 150)) ≤
      (expPosHi64 : ℝ) / (S64 : ℝ))
    (hchk : checkBinade (Nat.ble 0x80000000 b_c) b_c R e1B aLo aHi expNegLo64 expPosHi64
      (if Nat.beq eOff 0 then 10 else eOff + 33) (eOff + 34) = true) :
    inOutputBinade E (Real.exp (Model.ofNatBits b : Model FloatFormat.binary32).toReal) := by
  set neg := Nat.ble 0x80000000 b_c
  set mag := if neg then b_c - 0x80000000 else b_c
  set eb := mag >>> 23
  set loBiased := if Nat.beq eOff 0 then 10 else eOff + 33
  set hiBiased := eOff + 34
  have hloBiasedEq : (loBiased : ℤ) - 160 = binadeLoExp E := by
    simp only [loBiased, binadeLoExp]
    cases h0 : Nat.beq eOff 0 with
    | true =>
      have he0 : eOff = 0 := beq_true h0
      have hEm : E = -127 := by omega
      simp [hEm]
    | false =>
      have hne0 : eOff ≠ 0 := beq_false h0
      have hEne : (E == -127) = false := beq_false_of_ne (by omega)
      simp only [hEne, Bool.false_eq_true, ↓reduceIte]; omega
  have hhiBiasedEq : (hiBiased : ℤ) - 160 = E + 1 := by simp only [hiBiased]; omega
  have h2ne : (2 : ℝ) ≠ 0 := by norm_num
  have heb2' : eb ≤ 254 := by have : eb ≤ 133 := heb2; omega
  have hstep := toReal_ofNatBits_binade_step hbc heb1 heb2' hRlo hRhi hlo hhi
  dsimp only at hstep
  set hRreal : ℝ := (R : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150)
  have hbRange : (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal - hRreal ≤
      (Model.ofNatBits b : Model FloatFormat.binary32).toReal ∧
      (Model.ofNatBits b : Model FloatFormat.binary32).toReal ≤
      (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal + hRreal := by
    have ⟨hiLo, hiHi⟩ := abs_le.mp hstep.1
    have hpowPos : (0 : ℝ) < (2 : ℝ) ^ ((eb : ℤ) - 150) := by positivity
    set idx : ℤ := if neg then (b_c : ℤ) - (b : ℤ) else (b : ℤ) - (b_c : ℤ)
    have hiLoR : -(R : ℝ) ≤ (idx : ℝ) := by exact_mod_cast hiLo
    have hiHiR : (idx : ℝ) ≤ (R : ℝ) := by exact_mod_cast hiHi
    have hstep2 : (Model.ofNatBits b : Model FloatFormat.binary32).toReal =
        (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal +
          (idx : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150) := hstep.2
    rw [hstep2]
    constructor
    · have := mul_le_mul_of_nonneg_right hiLoR hpowPos.le
      simp only [neg_mul] at this; linarith
    · have := mul_le_mul_of_nonneg_right hiHiR hpowPos.le; linarith
  have hRleBc : R ≤ b_c := by
    have hmagLe : mag ≤ b_c := by simp only [mag]; split_ifs <;> omega
    exact (hRlo.trans (Nat.sub_le _ _)).trans hmagLe
  unfold checkBinade at hchk
  have hloOk : checkBinadeLo neg b_c R e1B aLo expNegLo64 loBiased = true := by
    cases h : checkBinadeLo neg b_c R e1B aLo expNegLo64 loBiased
    · simp [h] at hchk
    · rfl
  have hhiOk : checkBinadeHi neg b_c R e1B aHi expPosHi64 hiBiased = true := by
    simpa [hloOk] using hchk
  unfold checkBinadeLo at hloOk
  unfold checkBinadeHi at hhiOk
  refine ⟨hE.1, hE.2.1, ?_, ?_⟩
  · cases hfLo : gePow2Diff (aLo * expNegLo64) (loBiased + 144) e1B with
    | true =>
      have hg := gePow2Diff_sound hfLo
      have hmul : (2 : ℝ) ^ binadeLoExp E ≤
          ((aLo : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80)) * ((expNegLo64 : ℝ) / (S64 : ℝ)) := by
        have h1 : (2 : ℝ) ^ binadeLoExp E =
            (2 : ℝ) ^ (((loBiased + 144 : ℕ) : ℤ) - (e1B : ℤ)) *
              (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) / (S64 : ℝ) := by
          rw [S64_zpow, div_eq_mul_inv, ← zpow_neg, mul_assoc, ← zpow_add₀ h2ne,
            ← zpow_add₀ h2ne, ← hloBiasedEq]
          congr 1; push_cast; omega
        rw [h1]
        have hpos : (0 : ℝ) < (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) / (S64 : ℝ) :=
          div_pos (by positivity) S64_pos
        have hg' : (2 : ℝ) ^ (((loBiased + 144 : ℕ) : ℤ) - (e1B : ℤ)) ≤
            (aLo : ℝ) * (expNegLo64 : ℝ) := by simpa [Nat.cast_mul] using hg
        calc (2 : ℝ) ^ (((loBiased + 144 : ℕ) : ℤ) - (e1B : ℤ)) *
              (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) / (S64 : ℝ)
            = (2 : ℝ) ^ (((loBiased + 144 : ℕ) : ℤ) - (e1B : ℤ)) *
              ((2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) / (S64 : ℝ)) := by ring
          _ ≤ ((aLo : ℝ) * (expNegLo64 : ℝ)) *
              ((2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) / (S64 : ℝ)) :=
              mul_le_mul_of_nonneg_right hg' hpos.le
          _ = ((aLo : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80)) *
              ((expNegLo64 : ℝ) / (S64 : ℝ)) := by ring
      calc (2 : ℝ) ^ binadeLoExp E
          ≤ ((aLo : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80)) *
              ((expNegLo64 : ℝ) / (S64 : ℝ)) := hmul
        _ ≤ Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal *
              Real.exp (-hRreal) :=
            mul_le_mul hcLo hneg64 (div_nonneg (Nat.cast_nonneg _) S64_pos.le) (Real.exp_pos _).le
        _ = Real.exp ((Model.ofNatBits b_c : Model FloatFormat.binary32).toReal - hRreal) := by
            rw [← Real.exp_add, sub_eq_add_neg]
        _ ≤ Real.exp (Model.ofNatBits b : Model FloatFormat.binary32).toReal :=
            Real.exp_le_exp.mpr hbRange.1
    | false =>
      simp only [hfLo] at hloOk
      set bLo := match neg with | true => b_c + R | false => b_c - R
      cases hend : expCenterEncNat bLo with
      | none => simp [hend] at hloOk
      | some p =>
        rcases p with ⟨eLoB, loEnd, hiEnd⟩
        simp only [hend] at hloOk
        have hg := gePow2Diff_sound hloOk
        have hsnd := expCenterEncNat_sound hend
        have hstepLo := toReal_ofNatBits_binade_step hbc heb1 heb2' hRlo hRhi (b := bLo)
          (by cases h : neg <;> simp only [bLo, h] <;> omega)
          (by cases h : neg <;> simp only [bLo, h] <;> omega)
        dsimp only at hstepLo
        have hbLoReal : (Model.ofNatBits bLo : Model FloatFormat.binary32).toReal =
            (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal - hRreal := by
          rw [hstepLo.2]
          cases h : neg
          · have hnb : Nat.ble 0x80000000 b_c = false := h
            have hbLoEq : bLo = b_c - R := by simp [bLo, h]
            simp only [h, hnb, hbLoEq, Bool.false_eq_true, ↓reduceIte, hRreal, eb, mag]
            have : ((b_c - R : ℕ) : ℤ) - (b_c : ℤ) = -(R : ℤ) := by omega
            rw [this]; push_cast; ring
          · have hnb : Nat.ble 0x80000000 b_c = true := h
            have hbLoEq : bLo = b_c + R := by simp [bLo, h]
            simp only [h, hnb, hbLoEq, ↓reduceIte, hRreal, eb, mag]
            have : (b_c : ℤ) - ((b_c + R : ℕ) : ℤ) = -(R : ℤ) := by omega
            rw [this]; push_cast; ring
        have h1 : (2 : ℝ) ^ binadeLoExp E ≤
            (loEnd : ℝ) * (2 : ℝ) ^ (((eLoB : ℤ) - 160) - 80) := by
          have heq : (2 : ℝ) ^ binadeLoExp E =
              (2 : ℝ) ^ (((loBiased + 80 : ℕ) : ℤ) - (eLoB : ℤ)) *
                (2 : ℝ) ^ (((eLoB : ℤ) - 160) - 80) := by
            rw [← zpow_add₀ h2ne, ← hloBiasedEq]; congr 1; push_cast; omega
          rw [heq]; exact mul_le_mul_of_nonneg_right hg (by positivity)
        calc (2 : ℝ) ^ binadeLoExp E
            ≤ (loEnd : ℝ) * (2 : ℝ) ^ (((eLoB : ℤ) - 160) - 80) := h1
          _ ≤ Real.exp (Model.ofNatBits bLo : Model FloatFormat.binary32).toReal := hsnd.2.2.1
          _ = Real.exp ((Model.ofNatBits b_c : Model FloatFormat.binary32).toReal - hRreal) := by
              rw [hbLoReal]
          _ ≤ Real.exp (Model.ofNatBits b : Model FloatFormat.binary32).toReal :=
              Real.exp_le_exp.mpr hbRange.1
  · cases hfHi : lePow2Diff (aHi * expPosHi64) (hiBiased + 144) e1B with
    | true =>
      have hl := lePow2Diff_sound hfHi
      have hmul : ((aHi : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80)) *
            ((expPosHi64 : ℝ) / (S64 : ℝ)) ≤ (2 : ℝ) ^ (E + 1) := by
        have h1 : (2 : ℝ) ^ (E + 1) =
            (2 : ℝ) ^ (((hiBiased + 144 : ℕ) : ℤ) - (e1B : ℤ)) *
              (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) / (S64 : ℝ) := by
          rw [S64_zpow, div_eq_mul_inv, ← zpow_neg, mul_assoc, ← zpow_add₀ h2ne,
            ← zpow_add₀ h2ne, ← hhiBiasedEq]
          congr 1; push_cast; omega
        rw [h1]
        have hpos : (0 : ℝ) < (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) / (S64 : ℝ) :=
          div_pos (by positivity) S64_pos
        have hl' : (aHi : ℝ) * (expPosHi64 : ℝ) ≤
            (2 : ℝ) ^ (((hiBiased + 144 : ℕ) : ℤ) - (e1B : ℤ)) := by
          simpa [Nat.cast_mul] using hl
        calc ((aHi : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80)) * ((expPosHi64 : ℝ) / (S64 : ℝ))
            = ((aHi : ℝ) * (expPosHi64 : ℝ)) *
              ((2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) / (S64 : ℝ)) := by ring
          _ ≤ (2 : ℝ) ^ (((hiBiased + 144 : ℕ) : ℤ) - (e1B : ℤ)) *
              ((2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) / (S64 : ℝ)) :=
              mul_le_mul_of_nonneg_right hl' hpos.le
          _ = (2 : ℝ) ^ (((hiBiased + 144 : ℕ) : ℤ) - (e1B : ℤ)) *
              (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) / (S64 : ℝ) := by ring
      calc Real.exp (Model.ofNatBits b : Model FloatFormat.binary32).toReal
          ≤ Real.exp ((Model.ofNatBits b_c : Model FloatFormat.binary32).toReal + hRreal) :=
            Real.exp_le_exp.mpr hbRange.2
        _ = Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal *
              Real.exp hRreal := Real.exp_add _ _
        _ ≤ ((aHi : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80)) *
              ((expPosHi64 : ℝ) / (S64 : ℝ)) :=
            mul_le_mul hcHi hpos64 (Real.exp_pos _).le (by positivity)
        _ ≤ (2 : ℝ) ^ (E + 1) := hmul
    | false =>
      simp only [hfHi] at hhiOk
      set bHi := match neg with | true => b_c - R | false => b_c + R
      have hhiOk' : (match expCenterEncNat bHi with
        | none => false
        | some (eHiB, _, hiEnd) => lePow2Diff hiEnd (hiBiased + 80) eHiB) = true := hhiOk
      cases hend : expCenterEncNat bHi with
      | none => simp [hend] at hhiOk'
      | some p =>
        rcases p with ⟨eHiB, loEnd, hiEnd⟩
        simp only [hend] at hhiOk'
        have hl := lePow2Diff_sound hhiOk'
        have hsnd := expCenterEncNat_sound hend
        have hstepHi := toReal_ofNatBits_binade_step hbc heb1 heb2' hRlo hRhi (b := bHi)
          (by cases h : neg <;> simp only [bHi, h] <;> omega)
          (by cases h : neg <;> simp only [bHi, h] <;> omega)
        dsimp only at hstepHi
        have hbHiReal : (Model.ofNatBits bHi : Model FloatFormat.binary32).toReal =
            (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal + hRreal := by
          rw [hstepHi.2]
          cases h : neg
          · have hnb : Nat.ble 0x80000000 b_c = false := h
            have hbHiEq : bHi = b_c + R := by simp [bHi, h]
            simp only [h, hnb, hbHiEq, Bool.false_eq_true, ↓reduceIte, hRreal, eb, mag]
            have : ((b_c + R : ℕ) : ℤ) - (b_c : ℤ) = (R : ℤ) := by omega
            rw [this]; push_cast; ring
          · have hnb : Nat.ble 0x80000000 b_c = true := h
            have hbHiEq : bHi = b_c - R := by simp [bHi, h]
            simp only [h, hnb, hbHiEq, ↓reduceIte, hRreal, eb, mag]
            have : (b_c : ℤ) - ((b_c - R : ℕ) : ℤ) = (R : ℤ) := by omega
            rw [this]; push_cast; ring
        have h1 : (hiEnd : ℝ) * (2 : ℝ) ^ (((eHiB : ℤ) - 160) - 80) ≤ (2 : ℝ) ^ (E + 1) := by
          have heq : (2 : ℝ) ^ (E + 1) =
              (2 : ℝ) ^ (((hiBiased + 80 : ℕ) : ℤ) - (eHiB : ℤ)) *
                (2 : ℝ) ^ (((eHiB : ℤ) - 160) - 80) := by
            rw [← zpow_add₀ h2ne, ← hhiBiasedEq]; congr 1; push_cast; omega
          rw [heq]; exact mul_le_mul_of_nonneg_right hl (by positivity)
        calc Real.exp (Model.ofNatBits b : Model FloatFormat.binary32).toReal
            ≤ Real.exp ((Model.ofNatBits b_c : Model FloatFormat.binary32).toReal + hRreal) :=
              Real.exp_le_exp.mpr hbRange.2
          _ = Real.exp (Model.ofNatBits bHi : Model FloatFormat.binary32).toReal := by rw [hbHiReal]
          _ ≤ (hiEnd : ℝ) * (2 : ℝ) ^ (((eHiB : ℤ) - 160) - 80) := hsnd.2.2.2
          _ ≤ (2 : ℝ) ^ (E + 1) := h1

/-! ### Shared polynomial setup -/

private structure PolySetup where
  neg : Bool
  eb : Nat
  hShift : Nat
  aHi80 : Nat
  aMid80 : Nat
  aRad80 : Nat
  expPosHi64 : Nat

private def polySetupCore (b_c R eOff : Nat) (neg : Bool) : Option PolySetup :=
  let mag := match neg with | true => b_c - 0x80000000 | false => b_c
  let eb := mag >>> 23
  match Nat.ble 1 eb with
  | false => none
  | true =>
    match Nat.ble eb 133 with
    | false => none
    | true =>
      let frac := mag - (eb <<< 23)
      match Nat.ble R frac with
      | false => none
      | true =>
        match Nat.ble 0x800000 (frac + R) with
        | true => none
        | false =>
          let hShift := 150 - eb
          let dHi := match Nat.ble hShift 64 with
            | true => R <<< (64 - hShift)
            | false => (R >>> (hShift - 64)) + 1
          match Nat.ble dHi 0x4000000000000000 with
          | false => none
          | true =>
            match expCenterEncNat b_c with
            | none => none
            | some (e1B, aLo, aHi) =>
              let expNegLo64 := S64 - dHi
              let expPosHi64 := (S64 + dHi) + (((dHi * dHi) >>> 64) + 1)
              let loBiased := if Nat.beq eOff 0 then 10 else eOff + 33
              let hiBiased := eOff + 34
              match checkBinade neg b_c R e1B aLo aHi expNegLo64 expPosHi64
                  loBiased hiBiased with
              | false => none
              | true =>
                let uBiased := if Nat.beq eOff 0 then 10 else eOff + 9
                let (aLo80, aHi80) := match Nat.ble uBiased e1B with
                  | true =>
                    let sh := e1B - uBiased
                    (aLo <<< sh, aHi <<< sh)
                  | false =>
                    let sh := uBiased - e1B
                    (aLo >>> sh, (aHi >>> sh) + 1)
                let aMid80 := (aLo80 + aHi80) >>> 1
                let aRad80 := ((aHi80 - aLo80) + 1) >>> 1
                some ⟨neg, eb, hShift, aHi80, aMid80, aRad80, expPosHi64⟩

private def polySetup (b_c R eOff : Nat) : Option PolySetup :=
  match Nat.ble 0x100000000 b_c with
  | true => none
  | false =>
    match Nat.ble eOff 254 with
    | false => none
    | true => polySetupCore b_c R eOff (Nat.ble 0x80000000 b_c)

/-- Pure-`Nat` degree-2 Chebyshev-economized polynomial builder with `eOff = (E + 127).toNat`.
Returns `some (M, c0, c1, c2)` at scale `2^64`. -/
def polyApproxD2Biased (b_c R eOff : Nat) : Option (Nat × Nat × Nat × Nat) :=
  match polySetup b_c R eOff with
  | none => none
  | some st =>
    let r2 := R * R
    let r3 := r2 * R
    let r4 := r2 * r2
    let p0_80 := st.aMid80
    let p1_80 := (st.aMid80 >>> st.hShift) + ((st.aMid80 * r2) >>> (3 * st.hShift + 3))
    let p2_80 := st.aMid80 >>> (2 * st.hShift + 1)
    let (c0, d0) := round80to64 p0_80 0
    let (c1, d1) := round80to64 p1_80 2
    let (c2, d2) := round80to64 p2_80 1
    let aMax64 := ((st.aHi80 * st.expPosHi64) >>> 80) + 1
    let tmdErr64 := (2 * aMax64) / 1000000000000000 + 1
    let centerErr64 := ((st.aRad80 * st.expPosHi64) >>> 80) + 1
    let econErr64 := (((st.aMid80 * r3) >>> (3 * st.hShift + 19)) / 3) + 1
    let taylorErr64 := (((aMax64 * r4) >>> (4 * st.hShift + 3)) / 3) + 1
    let truncErr64 := ((d0 + (d1 * R + d2 * r2)) >>> 16) + 1
    let M := tmdErr64 + (centerErr64 + (econErr64 + (taylorErr64 + truncErr64)))
    some (M, c0, c1, c2)

/-- Pure-`Nat` degree-3 Chebyshev-economized polynomial builder with `eOff = (E + 127).toNat`.
Returns `some (M, c0, c1, c2, c3)` at scale `2^64`. -/
def polyApproxD3Biased (b_c R eOff : Nat) : Option (Nat × Nat × Nat × Nat × Nat) :=
  match polySetup b_c R eOff with
  | none => none
  | some st =>
    let r2 := R * R
    let r3 := r2 * R
    let r4 := r2 * r2
    let r5 := r4 * R
    let t0Sub := ((st.aMid80 * r4) >>> (4 * st.hShift + 6)) / 3
    match Nat.ble (t0Sub + 1) st.aMid80 with
    | false => none
    | true =>
      let p0_80 := st.aMid80 - (t0Sub + 1)
      let p1_80 := st.aMid80 >>> st.hShift
      let p2_80 := (st.aMid80 >>> (2 * st.hShift + 1)) +
        (((st.aMid80 * r2) >>> (4 * st.hShift + 3)) / 3)
      let p3_80 := (st.aMid80 >>> (3 * st.hShift + 1)) / 3
      let (c0, d0) := round80to64 p0_80 1
      let (c1, d1) := round80to64 p1_80 1
      let (c2, d2) := round80to64 p2_80 2
      let (c3, d3) := round80to64 p3_80 1
      let aMax64 := ((st.aHi80 * st.expPosHi64) >>> 80) + 1
      let tmdErr64 := (2 * aMax64) / 1000000000000000 + 1
      let centerErr64 := ((st.aRad80 * st.expPosHi64) >>> 80) + 1
      let econErr64 := (t0Sub >>> 16) + 1
      let taylorErr64 := (((aMax64 * r5) >>> (5 * st.hShift + 3)) / 15) + 1
      let truncErr64 := ((d0 + (d1 * R + (d2 * r2 + d3 * r3))) >>> 16) + 1
      let M := tmdErr64 + (centerErr64 + (econErr64 + (taylorErr64 + truncErr64)))
      some (M, c0, c1, c2, c3)

/-- Degree-2 Chebyshev-economized polynomial approximation of `exp(x) / 2^(uExp E)` on
`[b_c - R, b_c + R]` at fixed-point scale `2^64`. Returns `some (M, c0, c1, c2)`. -/
def polyApproxD2 (b_c R : Nat) (E : Int) : Option (Nat × Nat × Nat × Nat) :=
  match intToEOff? E with
  | none => none
  | some eOff => polyApproxD2Biased b_c R eOff

/-- Degree-3 Chebyshev-economized polynomial approximation of `exp(x) / 2^(uExp E)` on
`[b_c - R, b_c + R]` at fixed-point scale `2^64`. Returns `some (M, c0, c1, c2, c3)`. -/
def polyApproxD3 (b_c R : Nat) (E : Int) : Option (Nat × Nat × Nat × Nat × Nat) :=
  match intToEOff? E with
  | none => none
  | some eOff => polyApproxD3Biased b_c R eOff

/-! ### Shared helper lemmas for polynomial soundness proofs -/

private theorem div_shift_ceil_le {X k s : Nat} (hk : 0 < k) :
    (X : ℝ) / ((k : ℝ) * (2 : ℝ) ^ s) ≤ ((((X >>> s) / k) + 1 : ℕ) : ℝ) := by
  have hden : 0 < 2 ^ s * k := Nat.mul_pos (Nat.two_pow_pos s) hk
  have hdiv : (X >>> s) / k = X / (2 ^ s * k) := by
    rw [Nat.shiftRight_eq_div_pow, Nat.div_div_eq_div_mul]
  rw [hdiv, div_le_iff₀ (by positivity)]
  have hlt := (Nat.lt_mul_div_succ X hden).le
  have hR : (X : ℝ) ≤ (((2 ^ s * k) * (X / (2 ^ s * k) + 1) : ℕ) : ℝ) := by exact_mod_cast hlt
  push_cast at hR ⊢
  linarith

private theorem div_shift_floor_bounds {X k s : Nat} (hk : 0 < k) :
    (((X >>> s) / k : ℕ) : ℝ) ≤ (X : ℝ) / ((k : ℝ) * (2 : ℝ) ^ s) ∧
    (X : ℝ) / ((k : ℝ) * (2 : ℝ) ^ s) ≤ (((X >>> s) / k : ℕ) : ℝ) + 1 := by
  have hden : 0 < 2 ^ s * k := Nat.mul_pos (Nat.two_pow_pos s) hk
  have hdiv : (X >>> s) / k = X / (2 ^ s * k) := by
    rw [Nat.shiftRight_eq_div_pow, Nat.div_div_eq_div_mul]
  rw [hdiv]
  constructor
  · have h := Nat.cast_div_le (α := ℝ) (m := X) (n := 2 ^ s * k)
    push_cast at h; simpa [mul_comm] using h
  · rw [div_le_iff₀ (by positivity)]
    have hlt := (Nat.lt_mul_div_succ X hden).le
    have hR : (X : ℝ) ≤ (((2 ^ s * k) * (X / (2 ^ s * k) + 1) : ℕ) : ℝ) := by exact_mod_cast hlt
    push_cast at hR; linarith

private theorem shift_floor_bounds (X s : Nat) :
    ((X >>> s : ℕ) : ℝ) ≤ (X : ℝ) / (2 : ℝ) ^ s ∧
    (X : ℝ) / (2 : ℝ) ^ s ≤ ((X >>> s : ℕ) : ℝ) + 1 := by
  simpa using div_shift_floor_bounds (X := X) (k := 1) (s := s) (by omega)

private theorem shift_ceil_le (X s : Nat) :
    (X : ℝ) / (2 : ℝ) ^ s ≤ (((X >>> s) + 1 : ℕ) : ℝ) := by
  simpa using div_shift_ceil_le (X := X) (k := 1) (s := s) (by omega)

private theorem shift80_ceil_le (X : Nat) :
    (X : ℝ) / (S80 : ℝ) ≤ (((X >>> 80) + 1 : ℕ) : ℝ) := by
  rw [S80_cast]; exact shift_ceil_le X 80

private theorem shift64_ceil_le (X : Nat) :
    (X : ℝ) / (S64 : ℝ) ≤ (((X >>> 64) + 1 : ℕ) : ℝ) := by
  rw [S64_cast]; exact shift_ceil_le X 64

private theorem dHi_exp_bounds {R hShift : Nat}
    (hdLe : (match Nat.ble hShift 64 with
      | true => R <<< (64 - hShift)
      | false => (R >>> (hShift - 64)) + 1) ≤ 0x4000000000000000) :
    let dHi := match Nat.ble hShift 64 with
      | true => R <<< (64 - hShift)
      | false => (R >>> (hShift - 64)) + 1
    let δ : ℝ := (R : ℝ) / (2 : ℝ) ^ hShift
    let expNegLo64 := S64 - dHi
    let expPosHi64 := (S64 + dHi) + (((dHi * dHi) >>> 64) + 1)
    δ ≤ (dHi : ℝ) / (S64 : ℝ) ∧
    (dHi : ℝ) / (S64 : ℝ) ≤ 1 / 4 ∧
    (expNegLo64 : ℝ) / (S64 : ℝ) ≤ Real.exp (-δ) ∧
    Real.exp δ ≤ (expPosHi64 : ℝ) / (S64 : ℝ) := by
  intro dHi δ expNegLo64 expPosHi64
  have hδLe : δ ≤ (dHi : ℝ) / (S64 : ℝ) := by
    cases h64 : Nat.ble hShift 64 with
    | true =>
      have hle : hShift ≤ 64 := ble_true h64
      have hdEq : dHi = R * 2 ^ (64 - hShift) := by simp [dHi, h64, Nat.shiftLeft_eq]
      rw [hdEq, Nat.cast_mul, Nat.cast_pow, Nat.cast_ofNat]
      have hS : S64 = 2 ^ hShift * 2 ^ (64 - hShift) := by
        rw [S64_eq_pow, ← pow_add]; congr 1; omega
      have hSR : (S64 : ℝ) = (2 : ℝ) ^ hShift * (2 : ℝ) ^ (64 - hShift : ℕ) := by
        have : (S64 : ℝ) = ((2 ^ hShift * 2 ^ (64 - hShift) : ℕ) : ℝ) := by exact_mod_cast hS
        push_cast at this; exact this
      rw [hSR, mul_div_mul_right _ _ (by positivity)]
    | false =>
      have hgt : 64 < hShift := ble_false h64
      have hdEq : dHi = (R >>> (hShift - 64)) + 1 := by simp [dHi, h64]
      have hceil := shift_ceil_le R (hShift - 64)
      rw [← hdEq] at hceil
      have hpow : (2 : ℝ) ^ hShift = (2 : ℝ) ^ (hShift - 64 : ℕ) * (S64 : ℝ) := by
        have hN : 2 ^ hShift = 2 ^ (hShift - 64) * S64 := by
          rw [S64_eq_pow, ← pow_add]; congr 1; omega
        have : ((2 ^ hShift : ℕ) : ℝ) = ((2 ^ (hShift - 64) * S64 : ℕ) : ℝ) := by
          exact_mod_cast hN
        push_cast at this; exact this
      rw [show δ = (R : ℝ) / (2 : ℝ) ^ hShift from rfl, hpow, ← div_div]
      exact div_le_div_of_nonneg_right hceil S64_pos.le
  have hdQuarter : (dHi : ℝ) / (S64 : ℝ) ≤ 1 / 4 := by
    have hdR : (dHi : ℝ) ≤ ((0x4000000000000000 : ℕ) : ℝ) := by exact_mod_cast hdLe
    rw [div_le_iff₀ S64_pos]
    linarith [quarter_S64]
  have hdLeS64 : dHi ≤ S64 := by unfold S64; omega
  have hneg : (expNegLo64 : ℝ) / (S64 : ℝ) ≤ Real.exp (-δ) := by
    have hsub : (expNegLo64 : ℝ) = (S64 : ℝ) - (dHi : ℝ) := Nat.cast_sub hdLeS64
    rw [hsub, sub_div, div_self S64_pos.ne']
    linarith [one_sub_le_exp_neg δ, hδLe]
  have hpos : Real.exp δ ≤ (expPosHi64 : ℝ) / (S64 : ℝ) := by
    have hδ0 : 0 ≤ δ := by positivity
    have h1 := exp_le_one_add_add_sq hδ0 (hδLe.trans (by linarith))
    have hsq : δ ^ 2 ≤ ((dHi : ℝ) / (S64 : ℝ)) ^ 2 := pow_le_pow_left₀ hδ0 hδLe 2
    have hceil := shift64_ceil_le (dHi * dHi)
    have hsq2 : ((dHi : ℝ) / (S64 : ℝ)) ^ 2 ≤
        ((((dHi * dHi) >>> 64) + 1 : ℕ) : ℝ) / (S64 : ℝ) := by
      rw [div_pow, sq (S64 : ℝ), ← div_div, div_le_div_iff_of_pos_right S64_pos]
      simpa [Nat.cast_mul, sq] using hceil
    have hcast : (expPosHi64 : ℝ) / (S64 : ℝ) =
        1 + (dHi : ℝ) / (S64 : ℝ) +
          ((((dHi * dHi) >>> 64) + 1 : ℕ) : ℝ) / (S64 : ℝ) := by
      have hne : (S64 : ℝ) ≠ 0 := S64_pos.ne'
      simp only [expPosHi64]; push_cast; field_simp
    linarith
  exact ⟨hδLe, hdQuarter, hneg, hpos⟩

private theorem scaleA80_bounds {A : ℝ} {e1B aLo aHi uBiased : Nat} {E : ℤ} {eOff : Nat}
    (hE : (-127 : ℤ) ≤ E ∧ E ≤ 127 ∧ eOff ≤ 254 ∧ (eOff : ℤ) - 127 = E)
    (huB : uBiased = if Nat.beq eOff 0 then 10 else eOff + 9)
    (hloLe : aLo ≤ aHi)
    (hcLo : (aLo : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) ≤ A * (2 : ℝ) ^ uExp E)
    (hcHi : A * (2 : ℝ) ^ uExp E ≤ (aHi : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80)) :
    let aPair := match Nat.ble uBiased e1B with
      | true => (aLo <<< (e1B - uBiased), aHi <<< (e1B - uBiased))
      | false => (aLo >>> (uBiased - e1B), (aHi >>> (uBiased - e1B)) + 1)
    let aMid80 := (aPair.1 + aPair.2) >>> 1
    let aRad80 := ((aPair.2 - aPair.1) + 1) >>> 1
    aPair.1 ≤ aPair.2 ∧
    (aPair.1 : ℝ) / (S80 : ℝ) ≤ A ∧
    A ≤ (aPair.2 : ℝ) / (S80 : ℝ) ∧
    (aMid80 : ℝ) ≤ (aPair.2 : ℝ) ∧
    |A - (aMid80 : ℝ) / (S80 : ℝ)| ≤ (aRad80 : ℝ) / (S80 : ℝ) := by
  have huEq : (uBiased : ℤ) - 160 = uExp E := by
    rw [huB]; unfold uExp
    cases h0 : Nat.beq eOff 0 with
    | true =>
      have : eOff = 0 := beq_true h0
      have hEm : E = -127 := by omega
      simp [hEm]
    | false =>
      have hne0 : eOff ≠ 0 := beq_false h0
      have hEne : (E == -127) = false := beq_false_of_ne (by omega)
      simp only [hEne, Bool.false_eq_true, ↓reduceIte]; omega
  have h2ne : (2 : ℝ) ≠ 0 := by norm_num
  have huPos : (0 : ℝ) < (2 : ℝ) ^ uExp E := by positivity
  have hALo : (aLo : ℝ) * (2 : ℝ) ^ ((e1B : ℤ) - (uBiased : ℤ)) / (S80 : ℝ) ≤ A := by
    rw [← mul_le_mul_iff_left₀ huPos]
    have hexp : (2 : ℝ) ^ ((e1B : ℤ) - (uBiased : ℤ)) / (S80 : ℝ) * (2 : ℝ) ^ uExp E =
        (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) := by
      rw [S80_zpow, div_eq_mul_inv, ← zpow_neg, mul_assoc, ← zpow_add₀ h2ne,
        ← zpow_add₀ h2ne, ← huEq]
      congr 1; omega
    calc (aLo : ℝ) * (2 : ℝ) ^ ((e1B : ℤ) - (uBiased : ℤ)) / (S80 : ℝ) * (2 : ℝ) ^ uExp E
        = (aLo : ℝ) * ((2 : ℝ) ^ ((e1B : ℤ) - (uBiased : ℤ)) / (S80 : ℝ) * (2 : ℝ) ^ uExp E) := by
          ring
      _ = (aLo : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) := by rw [hexp]
      _ ≤ A * (2 : ℝ) ^ uExp E := hcLo
  have hAHi : A ≤ (aHi : ℝ) * (2 : ℝ) ^ ((e1B : ℤ) - (uBiased : ℤ)) / (S80 : ℝ) := by
    rw [← mul_le_mul_iff_left₀ huPos]
    have hexp : (2 : ℝ) ^ ((e1B : ℤ) - (uBiased : ℤ)) / (S80 : ℝ) * (2 : ℝ) ^ uExp E =
        (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) := by
      rw [S80_zpow, div_eq_mul_inv, ← zpow_neg, mul_assoc, ← zpow_add₀ h2ne,
        ← zpow_add₀ h2ne, ← huEq]
      congr 1; omega
    calc A * (2 : ℝ) ^ uExp E
        ≤ (aHi : ℝ) * (2 : ℝ) ^ (((e1B : ℤ) - 160) - 80) := hcHi
      _ = (aHi : ℝ) * ((2 : ℝ) ^ ((e1B : ℤ) - (uBiased : ℤ)) / (S80 : ℝ) * (2 : ℝ) ^ uExp E) := by
          rw [hexp]
      _ = (aHi : ℝ) * (2 : ℝ) ^ ((e1B : ℤ) - (uBiased : ℤ)) / (S80 : ℝ) * (2 : ℝ) ^ uExp E := by
          ring
  have hmain : ∀ aLo80 aHi80 : Nat, aLo80 ≤ aHi80 →
      (aLo80 : ℝ) / (S80 : ℝ) ≤ A → A ≤ (aHi80 : ℝ) / (S80 : ℝ) →
      let aMid80 := (aLo80 + aHi80) >>> 1
      let aRad80 := ((aHi80 - aLo80) + 1) >>> 1
      aLo80 ≤ aHi80 ∧ (aLo80 : ℝ) / (S80 : ℝ) ≤ A ∧ A ≤ (aHi80 : ℝ) / (S80 : ℝ) ∧
      (aMid80 : ℝ) ≤ (aHi80 : ℝ) ∧ |A - (aMid80 : ℝ) / (S80 : ℝ)| ≤ (aRad80 : ℝ) / (S80 : ℝ) := by
    intro aLo80 aHi80 hle h1 h2 aMid80 aRad80
    have hmidEq : aMid80 = (aLo80 + aHi80) / 2 := Nat.shiftRight_eq_div_pow _ 1
    have hradEq : aRad80 = (aHi80 - aLo80 + 1) / 2 := Nat.shiftRight_eq_div_pow _ 1
    have hmidLe : aMid80 ≤ aHi80 := by omega
    have hlowR : (aMid80 : ℝ) ≤ (aLo80 : ℝ) + (aRad80 : ℝ) := by
      exact_mod_cast (by omega : aMid80 ≤ aLo80 + aRad80)
    have hhiR : (aHi80 : ℝ) ≤ (aMid80 : ℝ) + (aRad80 : ℝ) := by
      exact_mod_cast (by omega : aHi80 ≤ aMid80 + aRad80)
    refine ⟨hle, h1, h2, by exact_mod_cast hmidLe, ?_⟩
    rw [abs_le]
    constructor
    · rw [← neg_div, le_sub_iff_add_le, ← add_div]
      refine le_trans ?_ h1
      rw [div_le_div_iff_of_pos_right S80_pos]; linarith
    · rw [sub_le_iff_le_add, ← add_div]
      refine h2.trans ?_
      rw [div_le_div_iff_of_pos_right S80_pos]; linarith
  cases hcmp : Nat.ble uBiased e1B with
  | true =>
    dsimp only
    have hle : uBiased ≤ e1B := ble_true hcmp
    have hexp : (2 : ℝ) ^ ((e1B : ℤ) - (uBiased : ℤ)) = (2 : ℝ) ^ (e1B - uBiased : ℕ) := by
      rw [← zpow_natCast]; congr 1; omega
    rw [hexp] at hALo hAHi
    have h1 : ((aLo <<< (e1B - uBiased) : ℕ) : ℝ) = (aLo : ℝ) * (2 : ℝ) ^ (e1B - uBiased : ℕ) := by
      rw [Nat.shiftLeft_eq]; push_cast; rfl
    have h2 : ((aHi <<< (e1B - uBiased) : ℕ) : ℝ) = (aHi : ℝ) * (2 : ℝ) ^ (e1B - uBiased : ℕ) := by
      rw [Nat.shiftLeft_eq]; push_cast; rfl
    exact hmain _ _ (by simp only [Nat.shiftLeft_eq]; exact Nat.mul_le_mul_right _ hloLe)
      (by rwa [h1]) (by rwa [h2])
  | false =>
    dsimp only
    have hgt : e1B < uBiased := ble_false hcmp
    have hexp : (2 : ℝ) ^ ((e1B : ℤ) - (uBiased : ℤ)) = 1 / (2 : ℝ) ^ (uBiased - e1B : ℕ) := by
      rw [one_div, ← zpow_natCast, ← zpow_neg]; congr 1; omega
    rw [hexp, mul_one_div] at hALo hAHi
    have h1 := (shift_floor_bounds aLo (uBiased - e1B)).1
    have h2 := shift_ceil_le aHi (uBiased - e1B)
    exact hmain _ _
      (by
        simp only [Nat.shiftRight_eq_div_pow]
        exact (Nat.div_le_div_right hloLe).trans (by omega))
      ((div_le_div_of_nonneg_right h1 S80_pos.le).trans hALo)
      (hAHi.trans (div_le_div_of_nonneg_right h2 S80_pos.le))

private theorem polySetupCore_sound {b_c R eOff : Nat} {neg : Bool} {E : ℤ} {st : PolySetup}
    (hbc : b_c < 0x100000000) (hneg : Nat.ble 0x80000000 b_c = neg)
    (hE : (-127 : ℤ) ≤ E ∧ E ≤ 127 ∧ eOff ≤ 254 ∧ (eOff : ℤ) - 127 = E)
    (h : polySetupCore b_c R eOff neg = some st) :
    let u : ℝ := (2 : ℝ) ^ uExp E
    let A : ℝ := Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal / u
    let hVal : ℝ := 1 / (2 : ℝ) ^ st.hShift
    let δ : ℝ := (R : ℝ) * hVal
    R ≤ b_c ∧ b_c + R < 0x100000000 ∧
    (st.aMid80 : ℝ) ≤ (st.aHi80 : ℝ) ∧
    A ≤ (st.aHi80 : ℝ) / (S80 : ℝ) ∧
    |A - (st.aMid80 : ℝ) / (S80 : ℝ)| ≤ (st.aRad80 : ℝ) / (S80 : ℝ) ∧
    Real.exp δ ≤ (st.expPosHi64 : ℝ) / (S64 : ℝ) ∧
    ∀ b : Nat, b_c - R ≤ b → b ≤ b_c + R →
      let y := Real.exp (Model.ofNatBits b : Model FloatFormat.binary32).toReal
      inOutputBinade E y ∧
      ∃ i : ℤ, |i| ≤ (R : ℤ) ∧ y / u = A * Real.exp ((i : ℝ) * hVal) := by
  intro u A hVal δ
  unfold polySetupCore at h
  dsimp only at h
  set mag := match neg with | true => b_c - 0x80000000 | false => b_c
  set eb := mag >>> 23
  have hmagEq : mag = if Nat.ble 0x80000000 b_c then b_c - 0x80000000 else b_c :=
    match_bool_eq_ite _ _ hneg
  cases heb1B : Nat.ble 1 eb with
  | false => simp [heb1B] at h
  | true =>
    simp only [heb1B] at h
    have heb1 : 1 ≤ eb := ble_true heb1B
    cases heb2B : Nat.ble eb 133 with
    | false => simp [heb2B] at h
    | true =>
      simp only [heb2B] at h
      have heb2 : eb ≤ 133 := ble_true heb2B
      set frac := mag - (eb <<< 23)
      cases hRloB : Nat.ble R frac with
      | false => simp [hRloB] at h
      | true =>
        simp only [hRloB] at h
        have hRlo : R ≤ frac := ble_true hRloB
        cases hRhiB : Nat.ble 0x800000 (frac + R) with
        | true => simp [hRhiB] at h
        | false =>
          simp only [hRhiB] at h
          have hRhi : frac + R < 0x800000 := ble_false hRhiB
          set hShift := 150 - eb
          set dHi := match Nat.ble hShift 64 with
            | true => R <<< (64 - hShift)
            | false => (R >>> (hShift - 64)) + 1
          cases hdHiB : Nat.ble dHi 0x4000000000000000 with
          | false => simp [hdHiB] at h
          | true =>
            simp only [hdHiB] at h
            have hdHiLe : dHi ≤ 0x4000000000000000 := ble_true hdHiB
            cases hcEnc : expCenterEncNat b_c with
            | none => simp [hcEnc] at h
            | some p =>
              rcases p with ⟨e1B, aLo, aHi⟩
              simp only [hcEnc] at h
              have hcSnd := expCenterEncNat_sound hcEnc
              set expNegLo64 := S64 - dHi
              set expPosHi64 := (S64 + dHi) + (((dHi * dHi) >>> 64) + 1)
              set loBiased := if Nat.beq eOff 0 then 10 else eOff + 33
              set hiBiased := eOff + 34
              cases hBin : checkBinade neg b_c R e1B aLo aHi expNegLo64 expPosHi64
                  loBiased hiBiased with
              | false => simp [hBin] at h
              | true =>
                simp only [hBin, Option.some.injEq] at h
                set uBiased := if Nat.beq eOff 0 then 10 else eOff + 9
                set aPair := match Nat.ble uBiased e1B with
                  | true => (aLo <<< (e1B - uBiased), aHi <<< (e1B - uBiased))
                  | false => (aLo >>> (uBiased - e1B), (aHi >>> (uBiased - e1B)) + 1)
                set aMid80 := (aPair.1 + aPair.2) >>> 1
                set aRad80 := ((aPair.2 - aPair.1) + 1) >>> 1
                have hstEq : st = ⟨neg, eb, hShift, aPair.2, aMid80, aRad80, expPosHi64⟩ := h.symm
                subst hstEq
                have hmagDecomp : mag = eb * 2 ^ 23 + frac := by
                  have h1 : eb = mag / 2 ^ 23 := Nat.shiftRight_eq_div_pow mag 23
                  have h2 : eb <<< 23 = eb * 2 ^ 23 := Nat.shiftLeft_eq eb 23
                  have : eb * 2 ^ 23 ≤ mag := by rw [h1]; exact Nat.div_mul_le_self _ _
                  have hf : frac = mag - eb * 2 ^ 23 := by simp [frac, h2]
                  omega
                have hmagLe : mag ≤ b_c := by rw [hmagEq]; split_ifs <;> omega
                have hmagHi : b_c ≤ mag + 0x80000000 := by rw [hmagEq]; split_ifs <;> omega
                have hRleBc : R ≤ b_c := by omega
                have hbcRlt : b_c + R < 0x100000000 := by omega
                have hstepPow : (2 : ℝ) ^ ((eb : ℤ) - 150) = 1 / (2 : ℝ) ^ hShift := by
                  rw [one_div, ← zpow_natCast (2 : ℝ) hShift, ← zpow_neg]
                  exact congrArg ((2 : ℝ) ^ ·) (by omega)
                have hdExp := dHi_exp_bounds (R := R) (hShift := hShift) hdHiLe
                dsimp only at hdExp
                have hδEq : (R : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150) =
                    (R : ℝ) / (2 : ℝ) ^ hShift := by rw [hstepPow, mul_one_div]
                have huPos : 0 < u := by positivity
                have hAu : A * u =
                    Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal :=
                  div_mul_cancel₀ _ huPos.ne'
                have hA80 := scaleA80_bounds (A := A) hE (uBiased := uBiased) rfl hcSnd.2.1
                  (by rw [hAu]; exact hcSnd.2.2.1) (by rw [hAu]; exact hcSnd.2.2.2)
                dsimp only at hA80
                have hExpPos' : Real.exp δ ≤ (expPosHi64 : ℝ) / (S64 : ℝ) := by
                  have : δ = (R : ℝ) / (2 : ℝ) ^ hShift := by simp [δ, hVal, mul_one_div]
                  rw [this]; exact hdExp.2.2.2
                refine ⟨hRleBc, hbcRlt, hA80.2.2.2.1, hA80.2.2.1, hA80.2.2.2.2, hExpPos', ?_⟩
                intro b hbLo hbHi
                have heb1C : 1 ≤ ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000
                    else b_c) >>> 23) := by rw [← hmagEq]; exact heb1
                have heb2C : ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000
                    else b_c) >>> 23) ≤ 133 := by rw [← hmagEq]; exact heb2
                have heb254C : ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000
                    else b_c) >>> 23) ≤ 254 := by rw [← hmagEq]; change eb ≤ 254; omega
                have hRloC : R ≤ ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000
                    else b_c) - (((if Nat.ble 0x80000000 b_c then b_c - 0x80000000
                    else b_c) >>> 23) <<< 23)) := by rw [← hmagEq]; exact hRlo
                have hRhiC : ((if Nat.ble 0x80000000 b_c then b_c - 0x80000000
                    else b_c) - (((if Nat.ble 0x80000000 b_c then b_c - 0x80000000
                    else b_c) >>> 23) <<< 23)) + R < 0x800000 := by rw [← hmagEq]; exact hRhi
                have hneg64C : (expNegLo64 : ℝ) / (S64 : ℝ) ≤
                    Real.exp (-((R : ℝ) * (2 : ℝ) ^
                      ((((if Nat.ble 0x80000000 b_c then b_c - 0x80000000
                      else b_c) >>> 23 : ℕ) : ℤ) - 150))) := by
                  rw [← hmagEq]; change (expNegLo64 : ℝ) / (S64 : ℝ) ≤
                    Real.exp (-((R : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150)))
                  rw [hδEq]; exact hdExp.2.2.1
                have hpos64C : Real.exp ((R : ℝ) * (2 : ℝ) ^
                      ((((if Nat.ble 0x80000000 b_c then b_c - 0x80000000
                      else b_c) >>> 23 : ℕ) : ℤ) - 150)) ≤
                    (expPosHi64 : ℝ) / (S64 : ℝ) := by
                  rw [← hmagEq]; change Real.exp ((R : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150)) ≤
                    (expPosHi64 : ℝ) / (S64 : ℝ)
                  rw [hδEq]; exact hdExp.2.2.2
                have hBinC : checkBinade (Nat.ble 0x80000000 b_c) b_c R e1B aLo aHi
                    expNegLo64 expPosHi64 (if Nat.beq eOff 0 then 10 else eOff + 33)
                    (eOff + 34) = true := by rw [hneg]; exact hBin
                have hbinOk := checkBinade_sound hE hbc heb1C heb2C hRloC hRhiC
                  hbLo hbHi hcSnd.2.2.1 hcSnd.2.2.2 hneg64C hpos64C hBinC
                have hstep := toReal_ofNatBits_binade_step hbc heb1C heb254C hRloC hRhiC
                  hbLo hbHi
                dsimp only at hstep
                rw [← hmagEq, hneg] at hstep
                set i : ℤ := if neg then (b_c : ℤ) - (b : ℤ) else (b : ℤ) - (b_c : ℤ)
                refine ⟨hbinOk, i, hstep.1, ?_⟩
                simp only [A, u]
                have hstep2 : (Model.ofNatBits b : Model FloatFormat.binary32).toReal =
                    (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal +
                      (i : ℝ) * (2 : ℝ) ^ ((eb : ℤ) - 150) := hstep.2
                rw [hstep2, hstepPow, Real.exp_add, mul_div_right_comm]

private theorem polySetup_sound {b_c R eOff : Nat} {E : ℤ} {st : PolySetup}
    (hE : (-127 : ℤ) ≤ E ∧ E ≤ 127 ∧ eOff ≤ 254 ∧ (eOff : ℤ) - 127 = E)
    (h : polySetup b_c R eOff = some st) :
    let u : ℝ := (2 : ℝ) ^ uExp E
    let A : ℝ := Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal / u
    let hVal : ℝ := 1 / (2 : ℝ) ^ st.hShift
    let δ : ℝ := (R : ℝ) * hVal
    R ≤ b_c ∧ b_c + R < 0x100000000 ∧
    (st.aMid80 : ℝ) ≤ (st.aHi80 : ℝ) ∧
    A ≤ (st.aHi80 : ℝ) / (S80 : ℝ) ∧
    |A - (st.aMid80 : ℝ) / (S80 : ℝ)| ≤ (st.aRad80 : ℝ) / (S80 : ℝ) ∧
    Real.exp δ ≤ (st.expPosHi64 : ℝ) / (S64 : ℝ) ∧
    ∀ b : Nat, b_c - R ≤ b → b ≤ b_c + R →
      let y := Real.exp (Model.ofNatBits b : Model FloatFormat.binary32).toReal
      inOutputBinade E y ∧
      ∃ i : ℤ, |i| ≤ (R : ℤ) ∧ y / u = A * Real.exp ((i : ℝ) * hVal) := by
  unfold polySetup at h
  cases hbcB : Nat.ble 0x100000000 b_c with
  | true => simp [hbcB] at h
  | false =>
    simp only [hbcB] at h
    cases heOffB : Nat.ble eOff 254 with
    | false => simp [heOffB] at h
    | true =>
      simp only [heOffB] at h
      exact polySetupCore_sound (ble_false hbcB) rfl hE h

/-! ### Main soundness theorems -/

/-- Soundness of `polyApproxD2`: when `polyApproxD2 b_c R E = some (M, c0, c1, c2)`,
for EVERY bit pattern `b` with `b_c - R ≤ b ≤ b_c + R`:
1. `exp(f32(b).toReal)` lies in output binade `E` (with grid `u = 2^(uExp E)`), and
2. `∃ i : ℤ, |i| ≤ R ∧ ∃ I : ℤ` with the degree-2 error + TMD margin bounded by `M / 2^64`. -/
theorem polyApproxD2_sound {b_c R : Nat} {E : Int} {M c0 c1 c2 : Nat}
    (h : polyApproxD2 b_c R E = some (M, c0, c1, c2)) :
    R ≤ b_c ∧ b_c + R < 0x100000000 ∧
    c0 < 2 ^ 64 ∧ c1 < 2 ^ 64 ∧ c2 < 2 ^ 64 ∧
    ∀ b : Nat, b_c - R ≤ b → b ≤ b_c + R →
      let y := Real.exp (Model.ofNatBits b : Model FloatFormat.binary32).toReal
      let u := (2 : ℝ) ^ uExp E
      inOutputBinade E y ∧
      ∃ i : ℤ, |i| ≤ (R : ℤ) ∧
        ∃ I : ℤ,
          |y / u - ((I : ℝ) + ((c0 : ℝ) + (c1 : ℝ) * (i : ℝ) +
            (c2 : ℝ) * (i : ℝ) ^ 2) / (2 : ℝ) ^ (64 : ℕ))| +
          (2 / 10 ^ 15 : ℝ) * (y / u) ≤ (M : ℝ) / (2 : ℝ) ^ (64 : ℕ) := by
  unfold polyApproxD2 at h
  cases heOff : intToEOff? E with
  | none => simp [heOff] at h
  | some eOff =>
    simp only [heOff] at h
    have hE := intToEOff?_sound heOff
    unfold polyApproxD2Biased at h
    cases hst : polySetup b_c R eOff with
    | none => simp [hst] at h
    | some st =>
      simp only [hst, Option.some.injEq, Prod.mk.injEq] at h
      have hs := polySetup_sound hE hst
      dsimp only at hs
      rcases hs with ⟨hRleBc, hbcRlt, hMidLeHi, hALeHi, hArad, hExpPos, hForall⟩
      set r2 := R * R
      set r3 := r2 * R
      set r4 := r2 * r2
      set p0_80 := st.aMid80
      set p1_80 := (st.aMid80 >>> st.hShift) + ((st.aMid80 * r2) >>> (3 * st.hShift + 3))
      set p2_80 := st.aMid80 >>> (2 * st.hShift + 1)
      set rd0 := round80to64 p0_80 0
      set rd1 := round80to64 p1_80 2
      set rd2 := round80to64 p2_80 1
      set aMax64 := ((st.aHi80 * st.expPosHi64) >>> 80) + 1
      set tmdErr64 := (2 * aMax64) / 1000000000000000 + 1
      set centerErr64 := ((st.aRad80 * st.expPosHi64) >>> 80) + 1
      set econErr64 := (((st.aMid80 * r3) >>> (3 * st.hShift + 19)) / 3) + 1
      set taylorErr64 := (((aMax64 * r4) >>> (4 * st.hShift + 3)) / 3) + 1
      set truncErr64 := ((rd0.2 + (rd1.2 * R + rd2.2 * r2)) >>> 16) + 1
      obtain ⟨rfl, rfl, rfl, rfl⟩ := h
      set hVal : ℝ := 1 / (2 : ℝ) ^ st.hShift
      set aMid : ℝ := (st.aMid80 : ℝ) / (S80 : ℝ)
      set p0 : ℝ := aMid
      set p1 : ℝ := aMid * hVal + 3 / 4 * (R : ℝ) ^ 2 * (aMid * hVal ^ 3 / 6)
      set p2 : ℝ := aMid * hVal ^ 2 / 2
      have hp0B : (p0_80 : ℝ) / (S80 : ℝ) ≤ p0 ∧ p0 ≤ ((p0_80 + 0 : ℕ) : ℝ) / (S80 : ℝ) := by
        simp [p0, p0_80, aMid]
      have hp1B : (p1_80 : ℝ) / (S80 : ℝ) ≤ p1 ∧ p1 ≤ ((p1_80 + 2 : ℕ) : ℝ) / (S80 : ℝ) := by
        have h1a := shift_floor_bounds st.aMid80 st.hShift
        have h1b := shift_floor_bounds (st.aMid80 * r2) (3 * st.hShift + 3)
        have heq1 : aMid * hVal = ((st.aMid80 : ℝ) / (2 : ℝ) ^ st.hShift) / (S80 : ℝ) := by
          simp only [aMid, hVal]; ring
        have heq2 : 3 / 4 * (R : ℝ) ^ 2 * (aMid * hVal ^ 3 / 6) =
            (((st.aMid80 * r2 : ℕ) : ℝ) / (2 : ℝ) ^ (3 * st.hShift + 3)) / (S80 : ℝ) := by
          simp only [aMid, hVal, r2]; push_cast
          rw [inv_two_pow_mul, pow_add]; ring
        have hp1Eq : p1 = (((st.aMid80 : ℝ) / (2 : ℝ) ^ st.hShift) +
            (((st.aMid80 * r2 : ℕ) : ℝ) / (2 : ℝ) ^ (3 * st.hShift + 3))) / (S80 : ℝ) := by
          simp only [p1]; rw [heq1, heq2, add_div]
        rw [hp1Eq]
        constructor
        · refine div_le_div_of_nonneg_right ?_ S80_pos.le
          simp only [p1_80]; push_cast at h1b ⊢; linarith [h1a.1, h1b.1]
        · refine div_le_div_of_nonneg_right ?_ S80_pos.le
          simp only [p1_80]; push_cast at h1b ⊢; linarith [h1a.2, h1b.2]
      have hp2B : (p2_80 : ℝ) / (S80 : ℝ) ≤ p2 ∧ p2 ≤ ((p2_80 + 1 : ℕ) : ℝ) / (S80 : ℝ) := by
        have h2a := shift_floor_bounds st.aMid80 (2 * st.hShift + 1)
        have hp2Eq : p2 = ((st.aMid80 : ℝ) / (2 : ℝ) ^ (2 * st.hShift + 1)) / (S80 : ℝ) := by
          simp only [p2, aMid, hVal]; rw [inv_two_pow_mul, pow_add]; ring
        rw [hp2Eq]
        constructor
        · exact div_le_div_of_nonneg_right h2a.1 S80_pos.le
        · refine div_le_div_of_nonneg_right ?_ S80_pos.le; push_cast; linarith [h2a.2]
      have hrd0 := round80to64_sound hp0B.1 hp0B.2
      have hrd1 := round80to64_sound hp1B.1 hp1B.2
      have hrd2 := round80to64_sound hp2B.1 hp2B.2
      dsimp only at hrd0 hrd1 hrd2
      refine ⟨hRleBc, hbcRlt, S64_eq_pow ▸ hrd0.1, S64_eq_pow ▸ hrd1.1, S64_eq_pow ▸ hrd2.1, ?_⟩
      intro b hbLo hbHi
      obtain ⟨hbinOk, i, hiAbs, hyDivU⟩ := hForall b hbLo hbHi
      refine ⟨hbinOk, i, hiAbs, ?_⟩
      set q0 := (p0_80 + 32768) >>> 16
      set q1 := (p1_80 + 32768) >>> 16
      set q2 := (p2_80 + 32768) >>> 16
      set I : ℤ := ((q0 / S64 : ℕ) : ℤ) + ((q1 / S64 : ℕ) : ℤ) * i + ((q2 / S64 : ℕ) : ℤ) * i ^ 2
      refine ⟨I, ?_⟩
      rw [← S64_cast]
      set u : ℝ := (2 : ℝ) ^ uExp E
      set y : ℝ := Real.exp (Model.ofNatBits b : Model FloatFormat.binary32).toReal
      set A : ℝ := Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal / u
      have hiAbsR : |(i : ℝ)| ≤ (R : ℝ) := by exact_mod_cast hiAbs
      set δ : ℝ := (R : ℝ) * hVal
      have hihAbs : |(i : ℝ) * hVal| ≤ δ := by
        rw [abs_mul, abs_of_nonneg (by positivity : 0 ≤ hVal)]
        exact mul_le_mul_of_nonneg_right hiAbsR (by positivity)
      have hexpIhLe : Real.exp ((i : ℝ) * hVal) ≤ Real.exp δ :=
        Real.exp_le_exp.mpr ((abs_le.mp hihAbs).2)
      have hexpAbsIhLe : Real.exp |(i : ℝ) * hVal| ≤ Real.exp δ := Real.exp_le_exp.mpr hihAbs
      have hAmax : A * Real.exp δ ≤ (aMax64 : ℝ) / (S64 : ℝ) := by
        have h1 : A * Real.exp δ ≤
            ((st.aHi80 : ℝ) / (S80 : ℝ)) * ((st.expPosHi64 : ℝ) / (S64 : ℝ)) :=
          mul_le_mul hALeHi hExpPos (Real.exp_pos _).le (div_nonneg (Nat.cast_nonneg _) S80_pos.le)
        have h2 : ((st.aHi80 : ℝ) * (st.expPosHi64 : ℝ)) / (S80 : ℝ) ≤ (aMax64 : ℝ) := by
          simpa [aMax64, Nat.cast_mul] using shift80_ceil_le (st.aHi80 * st.expPosHi64)
        calc A * Real.exp δ
            ≤ ((st.aHi80 : ℝ) / (S80 : ℝ)) * ((st.expPosHi64 : ℝ) / (S64 : ℝ)) := h1
          _ = (((st.aHi80 : ℝ) * (st.expPosHi64 : ℝ)) / (S80 : ℝ)) / (S64 : ℝ) := by ring
          _ ≤ (aMax64 : ℝ) / (S64 : ℝ) := div_le_div_of_nonneg_right h2 S64_pos.le
      have hAmidMax : aMid * Real.exp δ ≤ (aMax64 : ℝ) / (S64 : ℝ) := by
        have h1 : aMid * Real.exp δ ≤
            ((st.aHi80 : ℝ) / (S80 : ℝ)) * ((st.expPosHi64 : ℝ) / (S64 : ℝ)) :=
          mul_le_mul (div_le_div_of_nonneg_right hMidLeHi S80_pos.le) hExpPos
            (Real.exp_pos _).le (div_nonneg (Nat.cast_nonneg _) S80_pos.le)
        have h2 : ((st.aHi80 : ℝ) * (st.expPosHi64 : ℝ)) / (S80 : ℝ) ≤ (aMax64 : ℝ) := by
          simpa [aMax64, Nat.cast_mul] using shift80_ceil_le (st.aHi80 * st.expPosHi64)
        calc aMid * Real.exp δ
            ≤ ((st.aHi80 : ℝ) / (S80 : ℝ)) * ((st.expPosHi64 : ℝ) / (S64 : ℝ)) := h1
          _ = (((st.aHi80 : ℝ) * (st.expPosHi64 : ℝ)) / (S80 : ℝ)) / (S64 : ℝ) := by ring
          _ ≤ (aMax64 : ℝ) / (S64 : ℝ) := div_le_div_of_nonneg_right h2 S64_pos.le
      have hErrTmd : (2 / 10 ^ 15 : ℝ) * (y / u) ≤ (tmdErr64 : ℝ) / (S64 : ℝ) := by
        have hyLe : y / u ≤ (aMax64 : ℝ) / (S64 : ℝ) := by
          rw [hyDivU]
          exact (mul_le_mul_of_nonneg_left hexpIhLe (by positivity)).trans hAmax
        have hceil : (2 * (aMax64 : ℝ)) / (10 ^ 15 : ℝ) ≤ (tmdErr64 : ℝ) := by
          have hlt := (Nat.lt_mul_div_succ (2 * aMax64) (by norm_num : 0 < 1000000000000000)).le
          have hR : ((2 * aMax64 : ℕ) : ℝ) ≤
              ((1000000000000000 * (2 * aMax64 / 1000000000000000 + 1) : ℕ) : ℝ) := by
            exact_mod_cast hlt
          rw [div_le_iff₀ (by norm_num)]; push_cast [tmdErr64] at hR ⊢; linarith
        calc (2 / 10 ^ 15 : ℝ) * (y / u)
            ≤ (2 / 10 ^ 15 : ℝ) * ((aMax64 : ℝ) / (S64 : ℝ)) := by gcongr
          _ = ((2 * (aMax64 : ℝ)) / (10 ^ 15 : ℝ)) / (S64 : ℝ) := by ring
          _ ≤ (tmdErr64 : ℝ) / (S64 : ℝ) := div_le_div_of_nonneg_right hceil S64_pos.le
      have hErrCenter : |(A - aMid) * Real.exp ((i : ℝ) * hVal)| ≤
          (centerErr64 : ℝ) / (S64 : ℝ) := by
        rw [abs_mul, abs_of_pos (Real.exp_pos _)]
        have h1 : |A - aMid| * Real.exp ((i : ℝ) * hVal) ≤
            ((st.aRad80 : ℝ) / (S80 : ℝ)) * ((st.expPosHi64 : ℝ) / (S64 : ℝ)) :=
          mul_le_mul hArad (hexpIhLe.trans hExpPos) (Real.exp_pos _).le
            (div_nonneg (Nat.cast_nonneg _) S80_pos.le)
        have h2 : ((st.aRad80 : ℝ) * (st.expPosHi64 : ℝ)) / (S80 : ℝ) ≤ (centerErr64 : ℝ) := by
          simpa [centerErr64, Nat.cast_mul] using shift80_ceil_le (st.aRad80 * st.expPosHi64)
        calc |A - aMid| * Real.exp ((i : ℝ) * hVal)
            ≤ ((st.aRad80 : ℝ) / (S80 : ℝ)) * ((st.expPosHi64 : ℝ) / (S64 : ℝ)) := h1
          _ = (((st.aRad80 : ℝ) * (st.expPosHi64 : ℝ)) / (S80 : ℝ)) / (S64 : ℝ) := by ring
          _ ≤ (centerErr64 : ℝ) / (S64 : ℝ) := div_le_div_of_nonneg_right h2 S64_pos.le
      have hErrEcon : |aMid * hVal ^ 3 / 6 * ((i : ℝ) ^ 3 - 3 / 4 * (R : ℝ) ^ 2 * (i : ℝ))| ≤
          (econErr64 : ℝ) / (S64 : ℝ) := by
        have hcheb := cheb3_bound hiAbsR
        have h1 : |(i : ℝ) ^ 3 - 3 / 4 * (R : ℝ) ^ 2 * (i : ℝ)| ≤ (R : ℝ) ^ 3 / 4 := by
          have : (i : ℝ) ^ 3 - 3 / 4 * (R : ℝ) ^ 2 * (i : ℝ) =
              (4 * (i : ℝ) ^ 3 - 3 * (R : ℝ) ^ 2 * (i : ℝ)) / 4 := by ring
          rw [this, abs_div, abs_of_pos (by norm_num : (0 : ℝ) < 4)]
          exact div_le_div_of_nonneg_right hcheb (by norm_num)
        have h2 : aMid * hVal ^ 3 / 6 * ((R : ℝ) ^ 3 / 4) =
            (((st.aMid80 * r3 : ℕ) : ℝ) / (3 * (2 : ℝ) ^ (3 * st.hShift + 19))) / (S64 : ℝ) := by
          simp only [aMid, hVal, r3, r2]; rw [S80_eq_S64_mul]; push_cast
          rw [inv_two_pow_mul, pow_add]; ring
        have h3 := div_shift_ceil_le (X := st.aMid80 * r3) (k := 3) (s := 3 * st.hShift + 19)
          (by omega)
        rw [abs_mul, abs_of_nonneg (by positivity : 0 ≤ aMid * hVal ^ 3 / 6)]
        calc aMid * hVal ^ 3 / 6 * |(i : ℝ) ^ 3 - 3 / 4 * (R : ℝ) ^ 2 * (i : ℝ)|
            ≤ aMid * hVal ^ 3 / 6 * ((R : ℝ) ^ 3 / 4) :=
              mul_le_mul_of_nonneg_left h1 (by positivity)
          _ = (((st.aMid80 * r3 : ℕ) : ℝ) / (3 * (2 : ℝ) ^ (3 * st.hShift + 19))) / (S64 : ℝ) := h2
          _ ≤ (econErr64 : ℝ) / (S64 : ℝ) :=
              div_le_div_of_nonneg_right (by simpa [econErr64] using h3) S64_pos.le
      have hErrTaylor : |aMid * (Real.exp ((i : ℝ) * hVal) -
          (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 + ((i : ℝ) * hVal) ^ 3 / 6))| ≤
          (taylorErr64 : ℝ) / (S64 : ℝ) := by
        have ht := abs_exp_sub_sum_le ((i : ℝ) * hVal) 4
        simp only [Finset.sum_range_succ, Finset.sum_range_zero, Nat.factorial] at ht
        have hsumEq : (0 : ℝ) + ((i : ℝ) * hVal) ^ 0 / ((1 : ℕ) : ℝ) +
            ((i : ℝ) * hVal) ^ 1 / ((1 : ℕ) : ℝ) + ((i : ℝ) * hVal) ^ 2 / ((2 : ℕ) : ℝ) +
            ((i : ℝ) * hVal) ^ 3 / ((6 : ℕ) : ℝ) =
            1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 + ((i : ℝ) * hVal) ^ 3 / 6 := by
          norm_num
        rw [hsumEq] at ht
        have hpow4 : |(i : ℝ) * hVal| ^ 4 ≤ δ ^ 4 := pow_le_pow_left₀ (abs_nonneg _) hihAbs 4
        have h1 : |aMid * (Real.exp ((i : ℝ) * hVal) -
            (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 + ((i : ℝ) * hVal) ^ 3 / 6))| ≤
            (aMax64 : ℝ) / (S64 : ℝ) * (δ ^ 4 / 24) := by
          rw [abs_mul, abs_of_nonneg (by positivity : 0 ≤ aMid)]
          calc aMid * |Real.exp ((i : ℝ) * hVal) - _|
              ≤ aMid * (|(i : ℝ) * hVal| ^ 4 / ((24 : ℕ) : ℝ) * Real.exp |(i : ℝ) * hVal|) :=
                mul_le_mul_of_nonneg_left ht (by positivity)
            _ = (aMid * Real.exp |(i : ℝ) * hVal|) * (|(i : ℝ) * hVal| ^ 4 / 24) := by
                norm_num; ring
            _ ≤ (aMid * Real.exp δ) * (δ ^ 4 / 24) := by gcongr
            _ ≤ ((aMax64 : ℝ) / (S64 : ℝ)) * (δ ^ 4 / 24) :=
                mul_le_mul_of_nonneg_right hAmidMax (by positivity)
        have h2 : ((aMax64 : ℝ) / (S64 : ℝ)) * (δ ^ 4 / 24) =
            (((aMax64 * r4 : ℕ) : ℝ) / (3 * (2 : ℝ) ^ (4 * st.hShift + 3))) / (S64 : ℝ) := by
          simp only [δ, hVal, r4, r2]; push_cast
          rw [mul_pow, inv_two_pow_mul, pow_add]; ring
        have h3 := div_shift_ceil_le (X := aMax64 * r4) (k := 3) (s := 4 * st.hShift + 3) (by omega)
        calc |aMid * (Real.exp ((i : ℝ) * hVal) - _)|
            ≤ ((aMax64 : ℝ) / (S64 : ℝ)) * (δ ^ 4 / 24) := h1
          _ = (((aMax64 * r4 : ℕ) : ℝ) / (3 * (2 : ℝ) ^ (4 * st.hShift + 3))) / (S64 : ℝ) := h2
          _ ≤ (taylorErr64 : ℝ) / (S64 : ℝ) :=
              div_le_div_of_nonneg_right (by simpa [taylorErr64] using h3) S64_pos.le
      have hErrTrunc : |(p0 + p1 * (i : ℝ) + p2 * (i : ℝ) ^ 2) -
          ((I : ℝ) + ((rd0.1 : ℝ) + (rd1.1 : ℝ) * (i : ℝ) +
            (rd2.1 : ℝ) * (i : ℝ) ^ 2) / (S64 : ℝ))| ≤ (truncErr64 : ℝ) / (S64 : ℝ) := by
        set z0 : ℝ := ((q0 / S64 : ℕ) : ℝ) + (rd0.1 : ℝ) / (S64 : ℝ)
        set z1 : ℝ := ((q1 / S64 : ℕ) : ℝ) + (rd1.1 : ℝ) / (S64 : ℝ)
        set z2 : ℝ := ((q2 / S64 : ℕ) : ℝ) + (rd2.1 : ℝ) / (S64 : ℝ)
        have hIeq : (I : ℝ) + ((rd0.1 : ℝ) + (rd1.1 : ℝ) * (i : ℝ) +
            (rd2.1 : ℝ) * (i : ℝ) ^ 2) / (S64 : ℝ) = z0 + z1 * (i : ℝ) + z2 * (i : ℝ) ^ 2 := by
          simp only [I, z0, z1, z2, Int.cast_add, Int.cast_mul, Int.cast_pow, Int.cast_natCast]
          ring
        rw [hIeq]
        have hdiff : (p0 + p1 * (i : ℝ) + p2 * (i : ℝ) ^ 2) -
            (z0 + z1 * (i : ℝ) + z2 * (i : ℝ) ^ 2) =
            (p0 - z0) + (p1 - z1) * (i : ℝ) + (p2 - z2) * (i : ℝ) ^ 2 := by ring
        rw [hdiff]
        have hi2Le : |(i : ℝ) ^ 2| ≤ (R : ℝ) ^ 2 := by
          rw [abs_pow]; exact pow_le_pow_left₀ (abs_nonneg _) hiAbsR 2
        have hsum3 : |(p0 - z0) + (p1 - z1) * (i : ℝ) + (p2 - z2) * (i : ℝ) ^ 2| ≤
            ((rd0.2 + (rd1.2 * R + rd2.2 * r2) : ℕ) : ℝ) / (S80 : ℝ) := by
          have htri1 := abs_add_le ((p0 - z0) + (p1 - z1) * (i : ℝ)) ((p2 - z2) * (i : ℝ) ^ 2)
          have htri2 := abs_add_le (p0 - z0) ((p1 - z1) * (i : ℝ))
          have h1 : |(p1 - z1) * (i : ℝ)| ≤ (rd1.2 : ℝ) / (S80 : ℝ) * (R : ℝ) := by
            rw [abs_mul]; exact mul_le_mul hrd1.2 hiAbsR (abs_nonneg _)
              (div_nonneg (Nat.cast_nonneg _) S80_pos.le)
          have h2 : |(p2 - z2) * (i : ℝ) ^ 2| ≤ (rd2.2 : ℝ) / (S80 : ℝ) * (R : ℝ) ^ 2 := by
            rw [abs_mul]; exact mul_le_mul hrd2.2 hi2Le (abs_nonneg _)
              (div_nonneg (Nat.cast_nonneg _) S80_pos.le)
          have hcast : ((rd0.2 + (rd1.2 * R + rd2.2 * r2) : ℕ) : ℝ) / (S80 : ℝ) =
              (rd0.2 : ℝ) / (S80 : ℝ) + (rd1.2 : ℝ) / (S80 : ℝ) * (R : ℝ) +
              (rd2.2 : ℝ) / (S80 : ℝ) * (R : ℝ) ^ 2 := by simp only [r2]; push_cast; ring
          linarith [htri1, htri2, hrd0.2, h1, h2, hcast]
        have hceil := shift_ceil_le (rd0.2 + (rd1.2 * R + rd2.2 * r2)) 16
        have hcast2 : ((rd0.2 + (rd1.2 * R + rd2.2 * r2) : ℕ) : ℝ) / (S80 : ℝ) =
            (((rd0.2 + (rd1.2 * R + rd2.2 * r2) : ℕ) : ℝ) / (2 : ℝ) ^ (16 : ℕ)) / (S64 : ℝ) := by
          rw [S80_eq_S64_mul]; norm_num; ring
        calc |(p0 - z0) + (p1 - z1) * (i : ℝ) + (p2 - z2) * (i : ℝ) ^ 2|
            ≤ ((rd0.2 + (rd1.2 * R + rd2.2 * r2) : ℕ) : ℝ) / (S80 : ℝ) := hsum3
          _ = (((rd0.2 + (rd1.2 * R + rd2.2 * r2) : ℕ) : ℝ) / (2 : ℝ) ^ (16 : ℕ)) / (S64 : ℝ) :=
              hcast2
          _ ≤ (truncErr64 : ℝ) / (S64 : ℝ) :=
              div_le_div_of_nonneg_right (by simpa [truncErr64] using hceil) S64_pos.le
      have hdecomp : y / u - ((I : ℝ) + ((rd0.1 : ℝ) + (rd1.1 : ℝ) * (i : ℝ) +
          (rd2.1 : ℝ) * (i : ℝ) ^ 2) / (S64 : ℝ)) =
          (A - aMid) * Real.exp ((i : ℝ) * hVal) +
          aMid * (Real.exp ((i : ℝ) * hVal) -
            (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 + ((i : ℝ) * hVal) ^ 3 / 6)) +
          aMid * hVal ^ 3 / 6 * ((i : ℝ) ^ 3 - 3 / 4 * (R : ℝ) ^ 2 * (i : ℝ)) +
          ((p0 + p1 * (i : ℝ) + p2 * (i : ℝ) ^ 2) -
            ((I : ℝ) + ((rd0.1 : ℝ) + (rd1.1 : ℝ) * (i : ℝ) +
              (rd2.1 : ℝ) * (i : ℝ) ^ 2) / (S64 : ℝ))) := by
        rw [hyDivU]; simp only [p0, p1, p2]; ring
      have htri : |y / u - ((I : ℝ) + ((rd0.1 : ℝ) + (rd1.1 : ℝ) * (i : ℝ) +
          (rd2.1 : ℝ) * (i : ℝ) ^ 2) / (S64 : ℝ))| ≤
          |(A - aMid) * Real.exp ((i : ℝ) * hVal)| +
          |aMid * (Real.exp ((i : ℝ) * hVal) -
            (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 + ((i : ℝ) * hVal) ^ 3 / 6))| +
          |aMid * hVal ^ 3 / 6 * ((i : ℝ) ^ 3 - 3 / 4 * (R : ℝ) ^ 2 * (i : ℝ))| +
          |(p0 + p1 * (i : ℝ) + p2 * (i : ℝ) ^ 2) -
            ((I : ℝ) + ((rd0.1 : ℝ) + (rd1.1 : ℝ) * (i : ℝ) +
              (rd2.1 : ℝ) * (i : ℝ) ^ 2) / (S64 : ℝ))| := by
        rw [hdecomp]
        have t1 := abs_add_le
          ((A - aMid) * Real.exp ((i : ℝ) * hVal) +
            aMid * (Real.exp ((i : ℝ) * hVal) -
              (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 + ((i : ℝ) * hVal) ^ 3 / 6)) +
            aMid * hVal ^ 3 / 6 * ((i : ℝ) ^ 3 - 3 / 4 * (R : ℝ) ^ 2 * (i : ℝ)))
          ((p0 + p1 * (i : ℝ) + p2 * (i : ℝ) ^ 2) -
            ((I : ℝ) + ((rd0.1 : ℝ) + (rd1.1 : ℝ) * (i : ℝ) +
              (rd2.1 : ℝ) * (i : ℝ) ^ 2) / (S64 : ℝ)))
        have t2 := abs_add_le
          ((A - aMid) * Real.exp ((i : ℝ) * hVal) +
            aMid * (Real.exp ((i : ℝ) * hVal) -
              (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 + ((i : ℝ) * hVal) ^ 3 / 6)))
          (aMid * hVal ^ 3 / 6 * ((i : ℝ) ^ 3 - 3 / 4 * (R : ℝ) ^ 2 * (i : ℝ)))
        have t3 := abs_add_le
          ((A - aMid) * Real.exp ((i : ℝ) * hVal))
          (aMid * (Real.exp ((i : ℝ) * hVal) -
            (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 + ((i : ℝ) * hVal) ^ 3 / 6)))
        linarith
      have hMcast : ((tmdErr64 + (centerErr64 + (econErr64 +
          (taylorErr64 + truncErr64))) : ℕ) : ℝ) / (S64 : ℝ) =
          (tmdErr64 : ℝ) / (S64 : ℝ) + (centerErr64 : ℝ) / (S64 : ℝ) +
          (econErr64 : ℝ) / (S64 : ℝ) + (taylorErr64 : ℝ) / (S64 : ℝ) +
          (truncErr64 : ℝ) / (S64 : ℝ) := by push_cast; ring
      linarith

private theorem div_shift16_eq (X k s : Nat) :
    ((X >>> s) / k) >>> 16 = (X >>> (s + 16)) / k := by
  simp only [Nat.shiftRight_eq_div_pow]
  rw [Nat.div_div_eq_div_mul, Nat.div_div_eq_div_mul, Nat.div_div_eq_div_mul]
  congr 1; rw [pow_add]; ring

private theorem err_taylor_d3 {aMid hVal : ℝ} {i : ℤ} {aMax64 R hShift : Nat}
    (hMidNN : 0 ≤ aMid) (hhVal : hVal = 1 / (2 : ℝ) ^ hShift)
    (hiAbs : |(i : ℝ)| ≤ (R : ℝ))
    (hAmidMax : aMid * Real.exp ((R : ℝ) * hVal) ≤ (aMax64 : ℝ) / (S64 : ℝ)) :
    let r2 := R * R; let r4 := r2 * r2; let r5 := r4 * R
    |aMid * (Real.exp ((i : ℝ) * hVal) -
      (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 +
        ((i : ℝ) * hVal) ^ 3 / 6 + ((i : ℝ) * hVal) ^ 4 / 24))| ≤
    ((((aMax64 * r5) >>> (5 * hShift + 3)) / 15 + 1 : ℕ) : ℝ) / (S64 : ℝ) := by
  intro r2 r4 r5
  set δ : ℝ := (R : ℝ) * hVal
  have hhPos : 0 ≤ hVal := by rw [hhVal]; positivity
  have hihAbs : |(i : ℝ) * hVal| ≤ δ := by
    rw [abs_mul, abs_of_nonneg hhPos]
    exact mul_le_mul_of_nonneg_right hiAbs hhPos
  have ht := abs_exp_sub_sum_le ((i : ℝ) * hVal) 5
  simp only [Finset.sum_range_succ, Finset.sum_range_zero, Nat.factorial] at ht
  have hsumEq : (0 : ℝ) + ((i : ℝ) * hVal) ^ 0 / ((1 : ℕ) : ℝ) +
      ((i : ℝ) * hVal) ^ 1 / ((1 : ℕ) : ℝ) + ((i : ℝ) * hVal) ^ 2 / ((2 : ℕ) : ℝ) +
      ((i : ℝ) * hVal) ^ 3 / ((6 : ℕ) : ℝ) + ((i : ℝ) * hVal) ^ 4 / ((24 : ℕ) : ℝ) =
      1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 +
        ((i : ℝ) * hVal) ^ 3 / 6 + ((i : ℝ) * hVal) ^ 4 / 24 := by norm_num
  rw [hsumEq] at ht
  have hpow5 : |(i : ℝ) * hVal| ^ 5 ≤ δ ^ 5 := pow_le_pow_left₀ (abs_nonneg _) hihAbs 5
  have hexpAbsIhLe : Real.exp |(i : ℝ) * hVal| ≤ Real.exp δ := Real.exp_le_exp.mpr hihAbs
  have h1 : |aMid * (Real.exp ((i : ℝ) * hVal) -
      (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 +
        ((i : ℝ) * hVal) ^ 3 / 6 + ((i : ℝ) * hVal) ^ 4 / 24))| ≤
      (aMax64 : ℝ) / (S64 : ℝ) * (δ ^ 5 / 120) := by
    rw [abs_mul, abs_of_nonneg hMidNN]
    calc aMid * |Real.exp ((i : ℝ) * hVal) - _|
        ≤ aMid * (|(i : ℝ) * hVal| ^ 5 / ((120 : ℕ) : ℝ) * Real.exp |(i : ℝ) * hVal|) :=
          mul_le_mul_of_nonneg_left ht hMidNN
      _ = (aMid * Real.exp |(i : ℝ) * hVal|) * (|(i : ℝ) * hVal| ^ 5 / 120) := by norm_num; ring
      _ ≤ (aMid * Real.exp δ) * (δ ^ 5 / 120) := by gcongr
      _ ≤ ((aMax64 : ℝ) / (S64 : ℝ)) * (δ ^ 5 / 120) :=
          mul_le_mul_of_nonneg_right hAmidMax (by positivity)
  have h2 : ((aMax64 : ℝ) / (S64 : ℝ)) * (δ ^ 5 / 120) =
      (((aMax64 * r5 : ℕ) : ℝ) / (15 * (2 : ℝ) ^ (5 * hShift + 3))) / (S64 : ℝ) := by
    simp only [δ, r5, r4, r2]; rw [hhVal]; push_cast
    rw [mul_pow, inv_two_pow_mul, pow_add]; ring
  have h3 := div_shift_ceil_le (X := aMax64 * r5) (k := 15) (s := 5 * hShift + 3) (by omega)
  calc |aMid * (Real.exp ((i : ℝ) * hVal) - _)|
      ≤ ((aMax64 : ℝ) / (S64 : ℝ)) * (δ ^ 5 / 120) := h1
    _ = (((aMax64 * r5 : ℕ) : ℝ) / (15 * (2 : ℝ) ^ (5 * hShift + 3))) / (S64 : ℝ) := h2
    _ ≤ ((((aMax64 * r5) >>> (5 * hShift + 3)) / 15 + 1 : ℕ) : ℝ) / (S64 : ℝ) :=
        div_le_div_of_nonneg_right h3 S64_pos.le

private theorem err_trunc_d3 {p0 p1 p2 p3 : ℝ} {i : ℤ} {R : Nat}
    {q0 q1 q2 q3 c0 c1 c2 c3 d0 d1 d2 d3 : Nat}
    (hiAbs : |(i : ℝ)| ≤ (R : ℝ))
    (h0 : |p0 - (((q0 / S64 : ℕ) : ℝ) + (c0 : ℝ) / (S64 : ℝ))| ≤ (d0 : ℝ) / (S80 : ℝ))
    (h1 : |p1 - (((q1 / S64 : ℕ) : ℝ) + (c1 : ℝ) / (S64 : ℝ))| ≤ (d1 : ℝ) / (S80 : ℝ))
    (h2 : |p2 - (((q2 / S64 : ℕ) : ℝ) + (c2 : ℝ) / (S64 : ℝ))| ≤ (d2 : ℝ) / (S80 : ℝ))
    (h3 : |p3 - (((q3 / S64 : ℕ) : ℝ) + (c3 : ℝ) / (S64 : ℝ))| ≤ (d3 : ℝ) / (S80 : ℝ)) :
    let I : ℤ := ((q0 / S64 : ℕ) : ℤ) + ((q1 / S64 : ℕ) : ℤ) * i +
      ((q2 / S64 : ℕ) : ℤ) * i ^ 2 + ((q3 / S64 : ℕ) : ℤ) * i ^ 3
    let r2 := R * R; let r3 := r2 * R
    |(p0 + p1 * (i : ℝ) + p2 * (i : ℝ) ^ 2 + p3 * (i : ℝ) ^ 3) -
      ((I : ℝ) + ((c0 : ℝ) + (c1 : ℝ) * (i : ℝ) +
        (c2 : ℝ) * (i : ℝ) ^ 2 + (c3 : ℝ) * (i : ℝ) ^ 3) / (S64 : ℝ))| ≤
    ((((d0 + (d1 * R + (d2 * r2 + d3 * r3))) >>> 16) + 1 : ℕ) : ℝ) / (S64 : ℝ) := by
  intro I r2 r3
  set z0 : ℝ := ((q0 / S64 : ℕ) : ℝ) + (c0 : ℝ) / (S64 : ℝ)
  set z1 : ℝ := ((q1 / S64 : ℕ) : ℝ) + (c1 : ℝ) / (S64 : ℝ)
  set z2 : ℝ := ((q2 / S64 : ℕ) : ℝ) + (c2 : ℝ) / (S64 : ℝ)
  set z3 : ℝ := ((q3 / S64 : ℕ) : ℝ) + (c3 : ℝ) / (S64 : ℝ)
  have hIeq : (I : ℝ) + ((c0 : ℝ) + (c1 : ℝ) * (i : ℝ) +
      (c2 : ℝ) * (i : ℝ) ^ 2 + (c3 : ℝ) * (i : ℝ) ^ 3) / (S64 : ℝ) =
      z0 + z1 * (i : ℝ) + z2 * (i : ℝ) ^ 2 + z3 * (i : ℝ) ^ 3 := by
    simp only [I, z0, z1, z2, z3, Int.cast_add, Int.cast_mul, Int.cast_pow, Int.cast_natCast]
    ring
  rw [hIeq]
  have hdiff : (p0 + p1 * (i : ℝ) + p2 * (i : ℝ) ^ 2 + p3 * (i : ℝ) ^ 3) -
      (z0 + z1 * (i : ℝ) + z2 * (i : ℝ) ^ 2 + z3 * (i : ℝ) ^ 3) =
      (p0 - z0) + (p1 - z1) * (i : ℝ) + (p2 - z2) * (i : ℝ) ^ 2 +
        (p3 - z3) * (i : ℝ) ^ 3 := by ring
  rw [hdiff]
  have hi2Le : |(i : ℝ) ^ 2| ≤ (R : ℝ) ^ 2 := by
    rw [abs_pow]; exact pow_le_pow_left₀ (abs_nonneg _) hiAbs 2
  have hi3Le : |(i : ℝ) ^ 3| ≤ (R : ℝ) ^ 3 := by
    rw [abs_pow]; exact pow_le_pow_left₀ (abs_nonneg _) hiAbs 3
  have hsum4 : |(p0 - z0) + (p1 - z1) * (i : ℝ) +
      (p2 - z2) * (i : ℝ) ^ 2 + (p3 - z3) * (i : ℝ) ^ 3| ≤
      ((d0 + (d1 * R + (d2 * r2 + d3 * r3)) : ℕ) : ℝ) / (S80 : ℝ) := by
    have t1 := abs_add_le ((p0 - z0) + (p1 - z1) * (i : ℝ) + (p2 - z2) * (i : ℝ) ^ 2)
      ((p3 - z3) * (i : ℝ) ^ 3)
    have t2 := abs_add_le ((p0 - z0) + (p1 - z1) * (i : ℝ)) ((p2 - z2) * (i : ℝ) ^ 2)
    have t3 := abs_add_le (p0 - z0) ((p1 - z1) * (i : ℝ))
    have hm1 : |(p1 - z1) * (i : ℝ)| ≤ (d1 : ℝ) / (S80 : ℝ) * (R : ℝ) := by
      rw [abs_mul]; exact mul_le_mul h1 hiAbs (abs_nonneg _)
        (div_nonneg (Nat.cast_nonneg _) S80_pos.le)
    have hm2 : |(p2 - z2) * (i : ℝ) ^ 2| ≤ (d2 : ℝ) / (S80 : ℝ) * (R : ℝ) ^ 2 := by
      rw [abs_mul]; exact mul_le_mul h2 hi2Le (abs_nonneg _)
        (div_nonneg (Nat.cast_nonneg _) S80_pos.le)
    have hm3 : |(p3 - z3) * (i : ℝ) ^ 3| ≤ (d3 : ℝ) / (S80 : ℝ) * (R : ℝ) ^ 3 := by
      rw [abs_mul]; exact mul_le_mul h3 hi3Le (abs_nonneg _)
        (div_nonneg (Nat.cast_nonneg _) S80_pos.le)
    have hcast : ((d0 + (d1 * R + (d2 * r2 + d3 * r3)) : ℕ) : ℝ) / (S80 : ℝ) =
        (d0 : ℝ) / (S80 : ℝ) + (d1 : ℝ) / (S80 : ℝ) * (R : ℝ) +
        (d2 : ℝ) / (S80 : ℝ) * (R : ℝ) ^ 2 + (d3 : ℝ) / (S80 : ℝ) * (R : ℝ) ^ 3 := by
      simp only [r3, r2]; push_cast; ring
    linarith [t1, t2, t3, h0, hm1, hm2, hm3, hcast]
  have hceil := shift_ceil_le (d0 + (d1 * R + (d2 * r2 + d3 * r3))) 16
  have hcast2 : ((d0 + (d1 * R + (d2 * r2 + d3 * r3)) : ℕ) : ℝ) / (S80 : ℝ) =
      (((d0 + (d1 * R + (d2 * r2 + d3 * r3)) : ℕ) : ℝ) / (2 : ℝ) ^ (16 : ℕ)) / (S64 : ℝ) := by
    rw [S80_eq_S64_mul]; norm_num; ring
  calc |(p0 - z0) + (p1 - z1) * (i : ℝ) + (p2 - z2) * (i : ℝ) ^ 2 + (p3 - z3) * (i : ℝ) ^ 3|
      ≤ ((d0 + (d1 * R + (d2 * r2 + d3 * r3)) : ℕ) : ℝ) / (S80 : ℝ) := hsum4
    _ = (((d0 + (d1 * R + (d2 * r2 + d3 * r3)) : ℕ) : ℝ) / (2 : ℝ) ^ (16 : ℕ)) / (S64 : ℝ) :=
        hcast2
    _ ≤ ((((d0 + (d1 * R + (d2 * r2 + d3 * r3))) >>> 16) + 1 : ℕ) : ℝ) / (S64 : ℝ) :=
        div_le_div_of_nonneg_right hceil S64_pos.le

/-- Soundness of `polyApproxD3`: when `polyApproxD3 b_c R E = some (M, c0, c1, c2, c3)`,
for EVERY bit pattern `b` with `b_c - R ≤ b ≤ b_c + R`:
1. `exp(f32(b).toReal)` lies in output binade `E` (with grid `u = 2^(uExp E)`), and
2. `∃ i : ℤ, |i| ≤ R ∧ ∃ I : ℤ` with the degree-3 error + TMD margin bounded by `M / 2^64`. -/
theorem polyApproxD3_sound {b_c R : Nat} {E : Int} {M c0 c1 c2 c3 : Nat}
    (h : polyApproxD3 b_c R E = some (M, c0, c1, c2, c3)) :
    R ≤ b_c ∧ b_c + R < 0x100000000 ∧
    c0 < 2 ^ 64 ∧ c1 < 2 ^ 64 ∧ c2 < 2 ^ 64 ∧ c3 < 2 ^ 64 ∧
    ∀ b : Nat, b_c - R ≤ b → b ≤ b_c + R →
      let y := Real.exp (Model.ofNatBits b : Model FloatFormat.binary32).toReal
      let u := (2 : ℝ) ^ uExp E
      inOutputBinade E y ∧
      ∃ i : ℤ, |i| ≤ (R : ℤ) ∧
        ∃ I : ℤ,
          |y / u - ((I : ℝ) + ((c0 : ℝ) + (c1 : ℝ) * (i : ℝ) +
            (c2 : ℝ) * (i : ℝ) ^ 2 + (c3 : ℝ) * (i : ℝ) ^ 3) / (2 : ℝ) ^ (64 : ℕ))| +
          (2 / 10 ^ 15 : ℝ) * (y / u) ≤ (M : ℝ) / (2 : ℝ) ^ (64 : ℕ) := by
  unfold polyApproxD3 at h
  cases heOff : intToEOff? E with
  | none => simp [heOff] at h
  | some eOff =>
    simp only [heOff] at h
    have hE := intToEOff?_sound heOff
    unfold polyApproxD3Biased at h
    cases hst : polySetup b_c R eOff with
    | none => simp [hst] at h
    | some st =>
      simp only [hst] at h
      have hs := polySetup_sound hE hst
      dsimp only at hs
      rcases hs with ⟨hRleBc, hbcRlt, hMidLeHi, hALeHi, hArad, hExpPos, hForall⟩
      set r2 := R * R
      set r3 := r2 * R
      set r4 := r2 * r2
      set r5 := r4 * R
      set t0Sub := ((st.aMid80 * r4) >>> (4 * st.hShift + 6)) / 3
      cases ht0Ok : Nat.ble (t0Sub + 1) st.aMid80 with
      | false => simp [ht0Ok] at h
      | true =>
        simp only [ht0Ok, Option.some.injEq, Prod.mk.injEq] at h
        have ht0Le : t0Sub + 1 ≤ st.aMid80 := ble_true ht0Ok
        set p0_80 := st.aMid80 - (t0Sub + 1)
        set p1_80 := st.aMid80 >>> st.hShift
        set p2_80 := (st.aMid80 >>> (2 * st.hShift + 1)) +
          (((st.aMid80 * r2) >>> (4 * st.hShift + 3)) / 3)
        set p3_80 := (st.aMid80 >>> (3 * st.hShift + 1)) / 3
        set rd0 := round80to64 p0_80 1
        set rd1 := round80to64 p1_80 1
        set rd2 := round80to64 p2_80 2
        set rd3 := round80to64 p3_80 1
        set aMax64 := ((st.aHi80 * st.expPosHi64) >>> 80) + 1
        set tmdErr64 := (2 * aMax64) / 1000000000000000 + 1
        set centerErr64 := ((st.aRad80 * st.expPosHi64) >>> 80) + 1
        set econErr64 := (t0Sub >>> 16) + 1
        set taylorErr64 := (((aMax64 * r5) >>> (5 * st.hShift + 3)) / 15) + 1
        set truncErr64 := ((rd0.2 + (rd1.2 * R + (rd2.2 * r2 + rd3.2 * r3))) >>> 16) + 1
        obtain ⟨rfl, rfl, rfl, rfl, rfl⟩ := h
        set hVal : ℝ := 1 / (2 : ℝ) ^ st.hShift
        set aMid : ℝ := (st.aMid80 : ℝ) / (S80 : ℝ)
        set p0 : ℝ := aMid - (R : ℝ) ^ 4 * (aMid * hVal ^ 4 / 24) / 8
        set p1 : ℝ := aMid * hVal
        set p2 : ℝ := aMid * hVal ^ 2 / 2 + (R : ℝ) ^ 2 * (aMid * hVal ^ 4 / 24)
        set p3 : ℝ := aMid * hVal ^ 3 / 6
        have ht0B := div_shift_floor_bounds (X := st.aMid80 * r4) (k := 3)
          (s := 4 * st.hShift + 6) (by omega)
        have hp0B : (p0_80 : ℝ) / (S80 : ℝ) ≤ p0 ∧ p0 ≤ ((p0_80 + 1 : ℕ) : ℝ) / (S80 : ℝ) := by
          have hsubEq : (R : ℝ) ^ 4 * (aMid * hVal ^ 4 / 24) / 8 =
              (((st.aMid80 * r4 : ℕ) : ℝ) / (3 * (2 : ℝ) ^ (4 * st.hShift + 6))) / (S80 : ℝ) := by
            simp only [aMid, hVal, r4, r2]; push_cast
            rw [inv_two_pow_mul, pow_add]; ring
          have hp0Eq : p0 = ((st.aMid80 : ℝ) -
              ((st.aMid80 * r4 : ℕ) : ℝ) / (3 * (2 : ℝ) ^ (4 * st.hShift + 6))) / (S80 : ℝ) := by
            simp only [p0]; rw [hsubEq, ← sub_div]
          have hcast0 : (p0_80 : ℝ) = (st.aMid80 : ℝ) - ((t0Sub : ℝ) + 1) := by
            have := Nat.cast_sub (R := ℝ) ht0Le
            simp only [p0_80]; rw [this]; push_cast; ring
          rw [hp0Eq]
          constructor
          · refine div_le_div_of_nonneg_right ?_ S80_pos.le
            rw [hcast0]; push_cast at ht0B ⊢; linarith [ht0B.2]
          · refine div_le_div_of_nonneg_right ?_ S80_pos.le
            push_cast at ht0B ⊢; rw [hcast0]; linarith [ht0B.1]
        have hp1B : (p1_80 : ℝ) / (S80 : ℝ) ≤ p1 ∧ p1 ≤ ((p1_80 + 1 : ℕ) : ℝ) / (S80 : ℝ) := by
          have h1a := shift_floor_bounds st.aMid80 st.hShift
          have hp1Eq : p1 = ((st.aMid80 : ℝ) / (2 : ℝ) ^ st.hShift) / (S80 : ℝ) := by
            simp only [p1, aMid, hVal]; ring
          rw [hp1Eq]
          constructor
          · exact div_le_div_of_nonneg_right h1a.1 S80_pos.le
          · refine div_le_div_of_nonneg_right ?_ S80_pos.le; push_cast; linarith [h1a.2]
        have hp2B : (p2_80 : ℝ) / (S80 : ℝ) ≤ p2 ∧ p2 ≤ ((p2_80 + 2 : ℕ) : ℝ) / (S80 : ℝ) := by
          have h2a := shift_floor_bounds st.aMid80 (2 * st.hShift + 1)
          have h2b := div_shift_floor_bounds (X := st.aMid80 * r2) (k := 3)
            (s := 4 * st.hShift + 3) (by omega)
          have heq1 : aMid * hVal ^ 2 / 2 =
              ((st.aMid80 : ℝ) / (2 : ℝ) ^ (2 * st.hShift + 1)) / (S80 : ℝ) := by
            simp only [aMid, hVal]; rw [inv_two_pow_mul, pow_add]; ring
          have heq2 : (R : ℝ) ^ 2 * (aMid * hVal ^ 4 / 24) =
              (((st.aMid80 * r2 : ℕ) : ℝ) / (3 * (2 : ℝ) ^ (4 * st.hShift + 3))) / (S80 : ℝ) := by
            simp only [aMid, hVal, r2]; push_cast
            rw [inv_two_pow_mul, pow_add]; ring
          have hp2Eq : p2 = (((st.aMid80 : ℝ) / (2 : ℝ) ^ (2 * st.hShift + 1)) +
              (((st.aMid80 * r2 : ℕ) : ℝ) / (3 * (2 : ℝ) ^ (4 * st.hShift + 3)))) / (S80 : ℝ) := by
            simp only [p2]; rw [heq1, heq2, add_div]
          rw [hp2Eq]
          constructor
          · refine div_le_div_of_nonneg_right ?_ S80_pos.le
            simp only [p2_80]; push_cast at h2b ⊢; linarith [h2a.1, h2b.1]
          · refine div_le_div_of_nonneg_right ?_ S80_pos.le
            simp only [p2_80]; push_cast at h2b ⊢; linarith [h2a.2, h2b.2]
        have hp3B : (p3_80 : ℝ) / (S80 : ℝ) ≤ p3 ∧ p3 ≤ ((p3_80 + 1 : ℕ) : ℝ) / (S80 : ℝ) := by
          have h3a := div_shift_floor_bounds (X := st.aMid80) (k := 3)
            (s := 3 * st.hShift + 1) (by omega)
          have hp3Eq : p3 =
              ((st.aMid80 : ℝ) / (3 * (2 : ℝ) ^ (3 * st.hShift + 1))) / (S80 : ℝ) := by
            simp only [p3, aMid, hVal]; rw [inv_two_pow_mul, pow_add]; ring
          rw [hp3Eq]
          constructor
          · exact div_le_div_of_nonneg_right h3a.1 S80_pos.le
          · refine div_le_div_of_nonneg_right ?_ S80_pos.le; push_cast; linarith [h3a.2]
        have hrd0 := round80to64_sound hp0B.1 hp0B.2
        have hrd1 := round80to64_sound hp1B.1 hp1B.2
        have hrd2 := round80to64_sound hp2B.1 hp2B.2
        have hrd3 := round80to64_sound hp3B.1 hp3B.2
        dsimp only at hrd0 hrd1 hrd2 hrd3
        refine ⟨hRleBc, hbcRlt, S64_eq_pow ▸ hrd0.1, S64_eq_pow ▸ hrd1.1,
          S64_eq_pow ▸ hrd2.1, S64_eq_pow ▸ hrd3.1, ?_⟩
        intro b hbLo hbHi
        obtain ⟨hbinOk, i, hiAbs, hyDivU⟩ := hForall b hbLo hbHi
        refine ⟨hbinOk, i, hiAbs, ?_⟩
        set q0 := (p0_80 + 32768) >>> 16
        set q1 := (p1_80 + 32768) >>> 16
        set q2 := (p2_80 + 32768) >>> 16
        set q3 := (p3_80 + 32768) >>> 16
        set I : ℤ := ((q0 / S64 : ℕ) : ℤ) + ((q1 / S64 : ℕ) : ℤ) * i +
          ((q2 / S64 : ℕ) : ℤ) * i ^ 2 + ((q3 / S64 : ℕ) : ℤ) * i ^ 3
        refine ⟨I, ?_⟩
        rw [← S64_cast]
        set u : ℝ := (2 : ℝ) ^ uExp E
        set y : ℝ := Real.exp (Model.ofNatBits b : Model FloatFormat.binary32).toReal
        set A : ℝ := Real.exp (Model.ofNatBits b_c : Model FloatFormat.binary32).toReal / u
        have hiAbsR : |(i : ℝ)| ≤ (R : ℝ) := by exact_mod_cast hiAbs
        set δ : ℝ := (R : ℝ) * hVal
        have hihAbs : |(i : ℝ) * hVal| ≤ δ := by
          rw [abs_mul, abs_of_nonneg (by positivity : 0 ≤ hVal)]
          exact mul_le_mul_of_nonneg_right hiAbsR (by positivity)
        have hexpIhLe : Real.exp ((i : ℝ) * hVal) ≤ Real.exp δ :=
          Real.exp_le_exp.mpr ((abs_le.mp hihAbs).2)
        have hexpAbsIhLe : Real.exp |(i : ℝ) * hVal| ≤ Real.exp δ := Real.exp_le_exp.mpr hihAbs
        have hAmax : A * Real.exp δ ≤ (aMax64 : ℝ) / (S64 : ℝ) := by
          have h1 : A * Real.exp δ ≤
              ((st.aHi80 : ℝ) / (S80 : ℝ)) * ((st.expPosHi64 : ℝ) / (S64 : ℝ)) :=
            mul_le_mul hALeHi hExpPos (Real.exp_pos _).le
              (div_nonneg (Nat.cast_nonneg _) S80_pos.le)
          have h2 : ((st.aHi80 : ℝ) * (st.expPosHi64 : ℝ)) / (S80 : ℝ) ≤ (aMax64 : ℝ) := by
            simpa [aMax64, Nat.cast_mul] using shift80_ceil_le (st.aHi80 * st.expPosHi64)
          calc A * Real.exp δ
              ≤ ((st.aHi80 : ℝ) / (S80 : ℝ)) * ((st.expPosHi64 : ℝ) / (S64 : ℝ)) := h1
            _ = (((st.aHi80 : ℝ) * (st.expPosHi64 : ℝ)) / (S80 : ℝ)) / (S64 : ℝ) := by ring
            _ ≤ (aMax64 : ℝ) / (S64 : ℝ) := div_le_div_of_nonneg_right h2 S64_pos.le
        have hAmidMax : aMid * Real.exp δ ≤ (aMax64 : ℝ) / (S64 : ℝ) := by
          have h1 : aMid * Real.exp δ ≤
              ((st.aHi80 : ℝ) / (S80 : ℝ)) * ((st.expPosHi64 : ℝ) / (S64 : ℝ)) :=
            mul_le_mul (div_le_div_of_nonneg_right hMidLeHi S80_pos.le) hExpPos
              (Real.exp_pos _).le (div_nonneg (Nat.cast_nonneg _) S80_pos.le)
          have h2 : ((st.aHi80 : ℝ) * (st.expPosHi64 : ℝ)) / (S80 : ℝ) ≤ (aMax64 : ℝ) := by
            simpa [aMax64, Nat.cast_mul] using shift80_ceil_le (st.aHi80 * st.expPosHi64)
          calc aMid * Real.exp δ
              ≤ ((st.aHi80 : ℝ) / (S80 : ℝ)) * ((st.expPosHi64 : ℝ) / (S64 : ℝ)) := h1
            _ = (((st.aHi80 : ℝ) * (st.expPosHi64 : ℝ)) / (S80 : ℝ)) / (S64 : ℝ) := by ring
            _ ≤ (aMax64 : ℝ) / (S64 : ℝ) := div_le_div_of_nonneg_right h2 S64_pos.le
        have hErrTmd : (2 / 10 ^ 15 : ℝ) * (y / u) ≤ (tmdErr64 : ℝ) / (S64 : ℝ) := by
          have hyLe : y / u ≤ (aMax64 : ℝ) / (S64 : ℝ) := by
            rw [hyDivU]
            exact (mul_le_mul_of_nonneg_left hexpIhLe (by positivity)).trans hAmax
          have hceil : (2 * (aMax64 : ℝ)) / (10 ^ 15 : ℝ) ≤ (tmdErr64 : ℝ) := by
            have hlt := (Nat.lt_mul_div_succ (2 * aMax64) (by norm_num : 0 < 1000000000000000)).le
            have hR : ((2 * aMax64 : ℕ) : ℝ) ≤
                ((1000000000000000 * (2 * aMax64 / 1000000000000000 + 1) : ℕ) : ℝ) := by
              exact_mod_cast hlt
            rw [div_le_iff₀ (by norm_num)]; push_cast [tmdErr64] at hR ⊢; linarith
          calc (2 / 10 ^ 15 : ℝ) * (y / u)
              ≤ (2 / 10 ^ 15 : ℝ) * ((aMax64 : ℝ) / (S64 : ℝ)) := by gcongr
            _ = ((2 * (aMax64 : ℝ)) / (10 ^ 15 : ℝ)) / (S64 : ℝ) := by ring
            _ ≤ (tmdErr64 : ℝ) / (S64 : ℝ) := div_le_div_of_nonneg_right hceil S64_pos.le
        have hErrCenter : |(A - aMid) * Real.exp ((i : ℝ) * hVal)| ≤
            (centerErr64 : ℝ) / (S64 : ℝ) := by
          rw [abs_mul, abs_of_pos (Real.exp_pos _)]
          have h1 : |A - aMid| * Real.exp ((i : ℝ) * hVal) ≤
              ((st.aRad80 : ℝ) / (S80 : ℝ)) * ((st.expPosHi64 : ℝ) / (S64 : ℝ)) :=
            mul_le_mul hArad (hexpIhLe.trans hExpPos) (Real.exp_pos _).le
              (div_nonneg (Nat.cast_nonneg _) S80_pos.le)
          have h2 : ((st.aRad80 : ℝ) * (st.expPosHi64 : ℝ)) / (S80 : ℝ) ≤ (centerErr64 : ℝ) := by
            simpa [centerErr64, Nat.cast_mul] using shift80_ceil_le (st.aRad80 * st.expPosHi64)
          calc |A - aMid| * Real.exp ((i : ℝ) * hVal)
              ≤ ((st.aRad80 : ℝ) / (S80 : ℝ)) * ((st.expPosHi64 : ℝ) / (S64 : ℝ)) := h1
            _ = (((st.aRad80 : ℝ) * (st.expPosHi64 : ℝ)) / (S80 : ℝ)) / (S64 : ℝ) := by ring
            _ ≤ (centerErr64 : ℝ) / (S64 : ℝ) := div_le_div_of_nonneg_right h2 S64_pos.le
        have hErrEcon : |aMid * hVal ^ 4 / 24 *
            ((i : ℝ) ^ 4 - (R : ℝ) ^ 2 * (i : ℝ) ^ 2 + (R : ℝ) ^ 4 / 8)| ≤
            (econErr64 : ℝ) / (S64 : ℝ) := by
          have hcheb := cheb4_bound hiAbsR
          have h1 : |(i : ℝ) ^ 4 - (R : ℝ) ^ 2 * (i : ℝ) ^ 2 + (R : ℝ) ^ 4 / 8| ≤
              (R : ℝ) ^ 4 / 8 := by
            have : (i : ℝ) ^ 4 - (R : ℝ) ^ 2 * (i : ℝ) ^ 2 + (R : ℝ) ^ 4 / 8 =
                (8 * (i : ℝ) ^ 4 - 8 * (R : ℝ) ^ 2 * (i : ℝ) ^ 2 + (R : ℝ) ^ 4) / 8 := by ring
            rw [this, abs_div, abs_of_pos (by norm_num : (0 : ℝ) < 8)]
            exact div_le_div_of_nonneg_right hcheb (by norm_num)
          have h2 : aMid * hVal ^ 4 / 24 * ((R : ℝ) ^ 4 / 8) =
              (((st.aMid80 * r4 : ℕ) : ℝ) / (3 * (2 : ℝ) ^ (4 * st.hShift + 22))) / (S64 : ℝ) := by
            simp only [aMid, hVal, r4, r2]; rw [S80_eq_S64_mul]; push_cast
            rw [inv_two_pow_mul, pow_add]; ring
          have heconEq : t0Sub >>> 16 = ((st.aMid80 * r4) >>> (4 * st.hShift + 22)) / 3 :=
            div_shift16_eq (st.aMid80 * r4) 3 (4 * st.hShift + 6)
          have h3 := div_shift_ceil_le (X := st.aMid80 * r4) (k := 3) (s := 4 * st.hShift + 22)
            (by omega)
          rw [← heconEq] at h3
          rw [abs_mul, abs_of_nonneg (by positivity : 0 ≤ aMid * hVal ^ 4 / 24)]
          calc aMid * hVal ^ 4 / 24 *
                |(i : ℝ) ^ 4 - (R : ℝ) ^ 2 * (i : ℝ) ^ 2 + (R : ℝ) ^ 4 / 8|
              ≤ aMid * hVal ^ 4 / 24 * ((R : ℝ) ^ 4 / 8) :=
                mul_le_mul_of_nonneg_left h1 (by positivity)
            _ = (((st.aMid80 * r4 : ℕ) : ℝ) /
                  (3 * (2 : ℝ) ^ (4 * st.hShift + 22))) / (S64 : ℝ) := h2
            _ ≤ (econErr64 : ℝ) / (S64 : ℝ) :=
                div_le_div_of_nonneg_right (by simpa [econErr64] using h3) S64_pos.le
        have hErrTaylor : |aMid * (Real.exp ((i : ℝ) * hVal) -
            (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 +
              ((i : ℝ) * hVal) ^ 3 / 6 + ((i : ℝ) * hVal) ^ 4 / 24))| ≤
            (taylorErr64 : ℝ) / (S64 : ℝ) :=
          err_taylor_d3 (by positivity) rfl hiAbsR hAmidMax
        have hErrTrunc : |(p0 + p1 * (i : ℝ) + p2 * (i : ℝ) ^ 2 + p3 * (i : ℝ) ^ 3) -
            ((I : ℝ) + ((rd0.1 : ℝ) + (rd1.1 : ℝ) * (i : ℝ) +
              (rd2.1 : ℝ) * (i : ℝ) ^ 2 + (rd3.1 : ℝ) * (i : ℝ) ^ 3) / (S64 : ℝ))| ≤
            (truncErr64 : ℝ) / (S64 : ℝ) :=
          err_trunc_d3 hiAbsR hrd0.2 hrd1.2 hrd2.2 hrd3.2
        have hdecomp : y / u - ((I : ℝ) + ((rd0.1 : ℝ) + (rd1.1 : ℝ) * (i : ℝ) +
            (rd2.1 : ℝ) * (i : ℝ) ^ 2 + (rd3.1 : ℝ) * (i : ℝ) ^ 3) / (S64 : ℝ)) =
            (A - aMid) * Real.exp ((i : ℝ) * hVal) +
            aMid * (Real.exp ((i : ℝ) * hVal) -
              (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 +
                ((i : ℝ) * hVal) ^ 3 / 6 + ((i : ℝ) * hVal) ^ 4 / 24)) +
            aMid * hVal ^ 4 / 24 *
              ((i : ℝ) ^ 4 - (R : ℝ) ^ 2 * (i : ℝ) ^ 2 + (R : ℝ) ^ 4 / 8) +
            ((p0 + p1 * (i : ℝ) + p2 * (i : ℝ) ^ 2 + p3 * (i : ℝ) ^ 3) -
              ((I : ℝ) + ((rd0.1 : ℝ) + (rd1.1 : ℝ) * (i : ℝ) +
                (rd2.1 : ℝ) * (i : ℝ) ^ 2 + (rd3.1 : ℝ) * (i : ℝ) ^ 3) / (S64 : ℝ))) := by
          rw [hyDivU]; simp only [p0, p1, p2, p3]; ring
        have htri : |y / u - ((I : ℝ) + ((rd0.1 : ℝ) + (rd1.1 : ℝ) * (i : ℝ) +
            (rd2.1 : ℝ) * (i : ℝ) ^ 2 + (rd3.1 : ℝ) * (i : ℝ) ^ 3) / (S64 : ℝ))| ≤
            |(A - aMid) * Real.exp ((i : ℝ) * hVal)| +
            |aMid * (Real.exp ((i : ℝ) * hVal) -
              (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 +
                ((i : ℝ) * hVal) ^ 3 / 6 + ((i : ℝ) * hVal) ^ 4 / 24))| +
            |aMid * hVal ^ 4 / 24 *
              ((i : ℝ) ^ 4 - (R : ℝ) ^ 2 * (i : ℝ) ^ 2 + (R : ℝ) ^ 4 / 8)| +
            |(p0 + p1 * (i : ℝ) + p2 * (i : ℝ) ^ 2 + p3 * (i : ℝ) ^ 3) -
              ((I : ℝ) + ((rd0.1 : ℝ) + (rd1.1 : ℝ) * (i : ℝ) +
                (rd2.1 : ℝ) * (i : ℝ) ^ 2 + (rd3.1 : ℝ) * (i : ℝ) ^ 3) / (S64 : ℝ))| := by
          rw [hdecomp]
          have t1 := abs_add_le
            ((A - aMid) * Real.exp ((i : ℝ) * hVal) +
              aMid * (Real.exp ((i : ℝ) * hVal) -
                (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 +
                  ((i : ℝ) * hVal) ^ 3 / 6 + ((i : ℝ) * hVal) ^ 4 / 24)) +
              aMid * hVal ^ 4 / 24 *
                ((i : ℝ) ^ 4 - (R : ℝ) ^ 2 * (i : ℝ) ^ 2 + (R : ℝ) ^ 4 / 8))
            ((p0 + p1 * (i : ℝ) + p2 * (i : ℝ) ^ 2 + p3 * (i : ℝ) ^ 3) -
              ((I : ℝ) + ((rd0.1 : ℝ) + (rd1.1 : ℝ) * (i : ℝ) +
                (rd2.1 : ℝ) * (i : ℝ) ^ 2 + (rd3.1 : ℝ) * (i : ℝ) ^ 3) / (S64 : ℝ)))
          have t2 := abs_add_le
            ((A - aMid) * Real.exp ((i : ℝ) * hVal) +
              aMid * (Real.exp ((i : ℝ) * hVal) -
                (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 +
                  ((i : ℝ) * hVal) ^ 3 / 6 + ((i : ℝ) * hVal) ^ 4 / 24)))
            (aMid * hVal ^ 4 / 24 *
              ((i : ℝ) ^ 4 - (R : ℝ) ^ 2 * (i : ℝ) ^ 2 + (R : ℝ) ^ 4 / 8))
          have t3 := abs_add_le
            ((A - aMid) * Real.exp ((i : ℝ) * hVal))
            (aMid * (Real.exp ((i : ℝ) * hVal) -
              (1 + (i : ℝ) * hVal + ((i : ℝ) * hVal) ^ 2 / 2 +
                ((i : ℝ) * hVal) ^ 3 / 6 + ((i : ℝ) * hVal) ^ 4 / 24)))
          linarith
        have hMcast : ((tmdErr64 + (centerErr64 + (econErr64 +
            (taylorErr64 + truncErr64))) : ℕ) : ℝ) / (S64 : ℝ) =
            (tmdErr64 : ℝ) / (S64 : ℝ) + (centerErr64 : ℝ) / (S64 : ℝ) +
            (econErr64 : ℝ) / (S64 : ℝ) + (taylorErr64 : ℝ) / (S64 : ℝ) +
            (truncErr64 : ℝ) / (S64 : ℝ) := by push_cast; ring
        linarith

/-! ## Axiom checks -/

/--
info: 'LibcMath.Expf.MainPath.Tmd.expCenterEnc_sound' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms expCenterEnc_sound

/--
info: 'LibcMath.Expf.MainPath.Tmd.polyApproxD2_sound' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms polyApproxD2_sound

/--
info: 'LibcMath.Expf.MainPath.Tmd.polyApproxD3_sound' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms polyApproxD3_sound

end LibcMath.Expf.MainPath.Tmd
