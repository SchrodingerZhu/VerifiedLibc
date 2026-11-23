; ModuleID = '/home/schrodingerzy/Documents/llvm-project/libc/src/math/generic/sin.cpp'
source_filename = "/home/schrodingerzy/Documents/llvm-project/libc/src/math/generic/sin.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"struct.__llvm_libc::NumberPair" = type { double, double }
%"struct.__llvm_libc::fputil::DyadicFloat" = type { %"struct.__llvm_libc::Sign", i32, %"struct.__llvm_libc::BigInt" }
%"struct.__llvm_libc::Sign" = type { i8 }
%"struct.__llvm_libc::BigInt" = type { %"struct.__llvm_libc::cpp::array" }
%"struct.__llvm_libc::cpp::array" = type { [2 x i64] }
%"struct.__llvm_libc::Errno" = type { i8 }
%"struct.__llvm_libc::math::range_reduction_double_internal::LargeRangeReduction" = type { i32, double, double, double, %"struct.__llvm_libc::NumberPair" }

$_ZN11__llvm_libc4math3sinEd = comdat any

$_ZN11__llvm_libc4math31range_reduction_double_internal21range_reduction_smallEdRNS_10NumberPairIdEE = comdat any

$_ZN11__llvm_libc4math12sin_accurateEdtjRKNS0_31range_reduction_double_internal19LargeRangeReductionE = comdat any

$_ZN11__llvm_libc6fputil24raise_except_if_requiredEi = comdat any

$_ZN11__llvm_libc6fputil21set_errno_if_requiredEi = comdat any

$_ZN11__llvm_libc4math31range_reduction_double_internal19LargeRangeReduction4fastEdRNS_10NumberPairIdEE = comdat any

$_ZN11__llvm_libc6fputil7generic15quick_get_roundEv = comdat any

$_ZN11__llvm_libc4math31range_reduction_double_internal26range_reduction_small_f128Ed = comdat any

$_ZNK11__llvm_libc4math31range_reduction_double_internal19LargeRangeReduction8accurateEv = comdat any

$_ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_ = comdat any

$_ZN11__llvm_libc6fputil9quick_addILm128EEENS0_11DyadicFloatIXT_EEES3_S3_ = comdat any

$_ZNK11__llvm_libc6fputil11DyadicFloatILm128EE7fast_asIdLb1EvEET_v = comdat any

$_ZN11__llvm_libc6fputil34raise_underflow_except_if_requiredIdEEvv = comdat any

$_ZN11__llvm_libc4math31range_reduction_double_internal17SIN_K_PI_OVER_128E = comdat any

$_ZZN11__llvm_libc6fputil7generic15quick_get_roundEvE1x = comdat any

$_ZN11__llvm_libc4math31range_reduction_double_internal24ONE_TWENTY_EIGHT_OVER_PIE = comdat any

$_ZN11__llvm_libc4math31range_reduction_double_internal22SIN_K_PI_OVER_128_F128E = comdat any

@_ZN11__llvm_libc4math31range_reduction_double_internal17SIN_K_PI_OVER_128E = linkonce_odr hidden local_unnamed_addr constant [256 x %"struct.__llvm_libc::NumberPair"] [%"struct.__llvm_libc::NumberPair" zeroinitializer, %"struct.__llvm_libc::NumberPair" { double f0x3C5F938A73DB97FB, double f0x3F992155F7A3667C }, %"struct.__llvm_libc::NumberPair" { double f0xBC2912BD0D569A90, double f0x3FA91F65F10DD814 }, %"struct.__llvm_libc::NumberPair" { double f0x3C7CCBEEEAE8129A, double f0x3FB2D52092CE19F4 }, %"struct.__llvm_libc::NumberPair" { double f0xBC3E2718D26ED688, double f0x3FB917A6BC29B42C }, %"struct.__llvm_libc::NumberPair" { double f0xBC7CBB1F71ACA352, double f0x3FBF564E56A97310 }, %"struct.__llvm_libc::NumberPair" { double f0xBC8DD9FFEAECBDC4, double f0x3FC2C8106E8E613C }, %"struct.__llvm_libc::NumberPair" { double f0xBC8AB3802218894F, double f0x3FC5E214448B3FC8 }, %"struct.__llvm_libc::NumberPair" { double f0xBC849B466E7FE360, double f0x3FC8F8B83C69A60C }, %"struct.__llvm_libc::NumberPair" { double f0xBC8035E2873CA432, double f0x3FCC0B826A7E4F64 }, %"struct.__llvm_libc::NumberPair" { double f0xBC850B7BBC4768B1, double f0x3FCF19F97B215F1C }, %"struct.__llvm_libc::NumberPair" { double f0xBC83ED9EFAA42AB3, double f0x3FD111D262B1F678 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9A8B5C974EE7B5, double f0x3FD294062ED59F04 }, %"struct.__llvm_libc::NumberPair" { double f0x3C94325F12BE8946, double f0x3FD4135C94176600 }, %"struct.__llvm_libc::NumberPair" { double f0x3C8FC2047E54E614, double f0x3FD58F9A75AB1FDC }, %"struct.__llvm_libc::NumberPair" { double f0xBC9512C678219317, double f0x3FD7088530FA45A0 }, %"struct.__llvm_libc::NumberPair" { double f0xBC92E59DBA7AB4C2, double f0x3FD87DE2A6AEA964 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9D24AFDADE848B, double f0x3FD9EF7943A8ED8C }, %"struct.__llvm_libc::NumberPair" { double f0x3C65B362CB974183, double f0x3FDB5D1009E15CC0 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9E97AF1A63C807, double f0x3FDCC66E9931C460 }, %"struct.__llvm_libc::NumberPair" { double f0xBC8C3E4EDC5872F8, double f0x3FDE2B5D3806F63C }, %"struct.__llvm_libc::NumberPair" { double f0x3C9FB44F80F92225, double f0x3FDF8BA4DBF89AB8 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA9697FAF2E2FE5, double f0x3FE073879922FFEC }, %"struct.__llvm_libc::NumberPair" { double f0xBCA7BC8EDA6AF93C, double f0x3FE11EB3541B4B24 }, %"struct.__llvm_libc::NumberPair" { double f0x3C8B25DD267F6600, double f0x3FE1C73B39AE68C8 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA5769D0FBCDDC3, double f0x3FE26D054CDD12E0 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9C20673B2116B2, double f0x3FE30FF7FCE17034 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA3C7C4BC72A92C, double f0x3FE3AFFA292050B8 }, %"struct.__llvm_libc::NumberPair" { double f0xBCAE7F895D302395, double f0x3FE44CF325091DD8 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA13C293EDCEB32, double f0x3FE4E6CABBE3E5E8 }, %"struct.__llvm_libc::NumberPair" { double f0xBC875720992BFBB2, double f0x3FE57D69348CECA0 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA24A366A5FE547, double f0x3FE610B7551D2CE0 }, %"struct.__llvm_libc::NumberPair" { double f0x3C921165F626CDD5, double f0x3FE6A09E667F3BCC }, %"struct.__llvm_libc::NumberPair" { double f0xBCABCAC43C389BA9, double f0x3FE72D0837EFFF98 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA21EA6F59BE15B, double f0x3FE7B5DF226AAFB0 }, %"struct.__llvm_libc::NumberPair" { double f0x3CAD217BE0E2B971, double f0x3FE83B0E0BFF976C }, %"struct.__llvm_libc::NumberPair" { double f0x3C969D0F6897664A, double f0x3FE8BC806B151740 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9615F32B6F907A, double f0x3FE93A22499263FC }, %"struct.__llvm_libc::NumberPair" { double f0x3C96788EBCC76DC6, double f0x3FE9B3E047F38740 }, %"struct.__llvm_libc::NumberPair" { double f0x3CADDAE89FD441D1, double f0x3FEA29A7A0462780 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9F98273C5D2495, double f0x3FEA9B66290EA1A4 }, %"struct.__llvm_libc::NumberPair" { double f0xBC8926DA300FFCCE, double f0x3FEB090A58150200 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA90E58336C64A8, double f0x3FEB728345196E3C }, %"struct.__llvm_libc::NumberPair" { double f0x3CA9F6963354E3FE, double f0x3FEBD7C0AC6F9528 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9A47D3A2A0DCBE, double f0x3FEC38B2F180BDB0 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9ED0489E16B9A0, double f0x3FEC954B213411F4 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA0F3DB5DAD5AC5, double f0x3FECED7AF43CC774 }, %"struct.__llvm_libc::NumberPair" { double f0x3CAAC42B5A8B6943, double f0x3FED4134D14DC938 }, %"struct.__llvm_libc::NumberPair" { double f0xBCAD75033DFB9CA8, double f0x3FED906BCF328D48 }, %"struct.__llvm_libc::NumberPair" { double f0x3C883C37C6107DB3, double f0x3FEDDB13B6CCC23C }, %"struct.__llvm_libc::NumberPair" { double f0x3C97F59C49F6CD6D, double f0x3FEE212104F686E4 }, %"struct.__llvm_libc::NumberPair" { double f0x3CAEE94A90D7B88B, double f0x3FEE6288EC48E110 }, %"struct.__llvm_libc::NumberPair" { double f0xBCAA27D3874701F9, double f0x3FEE9F4156C62DDC }, %"struct.__llvm_libc::NumberPair" { double f0xBC985F4E1B8298D0, double f0x3FEED740E7684964 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9AB4E148E52D9E, double f0x3FEF0A7EFB9230D8 }, %"struct.__llvm_libc::NumberPair" { double f0x3C98A11412B82346, double f0x3FEF38F3AC64E588 }, %"struct.__llvm_libc::NumberPair" { double f0x3C7562172A361FD3, double f0x3FEF6297CFF75CB0 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA3564ACEF1FF97, double f0x3FEF8764FA714BA8 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA5E82A3284D5C8, double f0x3FEFA7557F08A518 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9709BCCB89A989, double f0x3FEFC26470E19FD4 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA9E082721DFB8E, double f0x3FEFD88DA3D12524 }, %"struct.__llvm_libc::NumberPair" { double f0xBCAEADE132F3981D, double f0x3FEFE9CDAD01883C }, %"struct.__llvm_libc::NumberPair" { double f0x3CAE3A843D1DB55F, double f0x3FEFF621E3796D7C }, %"struct.__llvm_libc::NumberPair" { double f0x3C9765595D548D9A, double f0x3FEFFD886084CD0C }, %"struct.__llvm_libc::NumberPair" { double 0.000000e+00, double 1.000000e+00 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9765595D548D9A, double f0x3FEFFD886084CD0C }, %"struct.__llvm_libc::NumberPair" { double f0x3CAE3A843D1DB55F, double f0x3FEFF621E3796D7C }, %"struct.__llvm_libc::NumberPair" { double f0xBCAEADE132F3981D, double f0x3FEFE9CDAD01883C }, %"struct.__llvm_libc::NumberPair" { double f0x3CA9E082721DFB8E, double f0x3FEFD88DA3D12524 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9709BCCB89A989, double f0x3FEFC26470E19FD4 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA5E82A3284D5C8, double f0x3FEFA7557F08A518 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA3564ACEF1FF97, double f0x3FEF8764FA714BA8 }, %"struct.__llvm_libc::NumberPair" { double f0x3C7562172A361FD3, double f0x3FEF6297CFF75CB0 }, %"struct.__llvm_libc::NumberPair" { double f0x3C98A11412B82346, double f0x3FEF38F3AC64E588 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9AB4E148E52D9E, double f0x3FEF0A7EFB9230D8 }, %"struct.__llvm_libc::NumberPair" { double f0xBC985F4E1B8298D0, double f0x3FEED740E7684964 }, %"struct.__llvm_libc::NumberPair" { double f0xBCAA27D3874701F9, double f0x3FEE9F4156C62DDC }, %"struct.__llvm_libc::NumberPair" { double f0x3CAEE94A90D7B88B, double f0x3FEE6288EC48E110 }, %"struct.__llvm_libc::NumberPair" { double f0x3C97F59C49F6CD6D, double f0x3FEE212104F686E4 }, %"struct.__llvm_libc::NumberPair" { double f0x3C883C37C6107DB3, double f0x3FEDDB13B6CCC23C }, %"struct.__llvm_libc::NumberPair" { double f0xBCAD75033DFB9CA8, double f0x3FED906BCF328D48 }, %"struct.__llvm_libc::NumberPair" { double f0x3CAAC42B5A8B6943, double f0x3FED4134D14DC938 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA0F3DB5DAD5AC5, double f0x3FECED7AF43CC774 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9ED0489E16B9A0, double f0x3FEC954B213411F4 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9A47D3A2A0DCBE, double f0x3FEC38B2F180BDB0 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA9F6963354E3FE, double f0x3FEBD7C0AC6F9528 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA90E58336C64A8, double f0x3FEB728345196E3C }, %"struct.__llvm_libc::NumberPair" { double f0xBC8926DA300FFCCE, double f0x3FEB090A58150200 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9F98273C5D2495, double f0x3FEA9B66290EA1A4 }, %"struct.__llvm_libc::NumberPair" { double f0x3CADDAE89FD441D1, double f0x3FEA29A7A0462780 }, %"struct.__llvm_libc::NumberPair" { double f0x3C96788EBCC76DC6, double f0x3FE9B3E047F38740 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9615F32B6F907A, double f0x3FE93A22499263FC }, %"struct.__llvm_libc::NumberPair" { double f0x3C969D0F6897664A, double f0x3FE8BC806B151740 }, %"struct.__llvm_libc::NumberPair" { double f0x3CAD217BE0E2B971, double f0x3FE83B0E0BFF976C }, %"struct.__llvm_libc::NumberPair" { double f0xBCA21EA6F59BE15B, double f0x3FE7B5DF226AAFB0 }, %"struct.__llvm_libc::NumberPair" { double f0xBCABCAC43C389BA9, double f0x3FE72D0837EFFF98 }, %"struct.__llvm_libc::NumberPair" { double f0x3C921165F626CDD5, double f0x3FE6A09E667F3BCC }, %"struct.__llvm_libc::NumberPair" { double f0xBCA24A366A5FE547, double f0x3FE610B7551D2CE0 }, %"struct.__llvm_libc::NumberPair" { double f0xBC875720992BFBB2, double f0x3FE57D69348CECA0 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA13C293EDCEB32, double f0x3FE4E6CABBE3E5E8 }, %"struct.__llvm_libc::NumberPair" { double f0xBCAE7F895D302395, double f0x3FE44CF325091DD8 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA3C7C4BC72A92C, double f0x3FE3AFFA292050B8 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9C20673B2116B2, double f0x3FE30FF7FCE17034 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA5769D0FBCDDC3, double f0x3FE26D054CDD12E0 }, %"struct.__llvm_libc::NumberPair" { double f0x3C8B25DD267F6600, double f0x3FE1C73B39AE68C8 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA7BC8EDA6AF93C, double f0x3FE11EB3541B4B24 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA9697FAF2E2FE5, double f0x3FE073879922FFEC }, %"struct.__llvm_libc::NumberPair" { double f0x3C9FB44F80F92225, double f0x3FDF8BA4DBF89AB8 }, %"struct.__llvm_libc::NumberPair" { double f0xBC8C3E4EDC5872F8, double f0x3FDE2B5D3806F63C }, %"struct.__llvm_libc::NumberPair" { double f0xBC9E97AF1A63C807, double f0x3FDCC66E9931C460 }, %"struct.__llvm_libc::NumberPair" { double f0x3C65B362CB974183, double f0x3FDB5D1009E15CC0 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9D24AFDADE848B, double f0x3FD9EF7943A8ED8C }, %"struct.__llvm_libc::NumberPair" { double f0xBC92E59DBA7AB4C2, double f0x3FD87DE2A6AEA964 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9512C678219317, double f0x3FD7088530FA45A0 }, %"struct.__llvm_libc::NumberPair" { double f0x3C8FC2047E54E614, double f0x3FD58F9A75AB1FDC }, %"struct.__llvm_libc::NumberPair" { double f0x3C94325F12BE8946, double f0x3FD4135C94176600 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9A8B5C974EE7B5, double f0x3FD294062ED59F04 }, %"struct.__llvm_libc::NumberPair" { double f0xBC83ED9EFAA42AB3, double f0x3FD111D262B1F678 }, %"struct.__llvm_libc::NumberPair" { double f0xBC850B7BBC4768B1, double f0x3FCF19F97B215F1C }, %"struct.__llvm_libc::NumberPair" { double f0xBC8035E2873CA432, double f0x3FCC0B826A7E4F64 }, %"struct.__llvm_libc::NumberPair" { double f0xBC849B466E7FE360, double f0x3FC8F8B83C69A60C }, %"struct.__llvm_libc::NumberPair" { double f0xBC8AB3802218894F, double f0x3FC5E214448B3FC8 }, %"struct.__llvm_libc::NumberPair" { double f0xBC8DD9FFEAECBDC4, double f0x3FC2C8106E8E613C }, %"struct.__llvm_libc::NumberPair" { double f0xBC7CBB1F71ACA352, double f0x3FBF564E56A97310 }, %"struct.__llvm_libc::NumberPair" { double f0xBC3E2718D26ED688, double f0x3FB917A6BC29B42C }, %"struct.__llvm_libc::NumberPair" { double f0x3C7CCBEEEAE8129A, double f0x3FB2D52092CE19F4 }, %"struct.__llvm_libc::NumberPair" { double f0xBC2912BD0D569A90, double f0x3FA91F65F10DD814 }, %"struct.__llvm_libc::NumberPair" { double f0x3C5F938A73DB97FB, double f0x3F992155F7A3667C }, %"struct.__llvm_libc::NumberPair" zeroinitializer, %"struct.__llvm_libc::NumberPair" { double f0xBC5F938A73DB97FB, double f0xBF992155F7A3667C }, %"struct.__llvm_libc::NumberPair" { double f0x3C2912BD0D569A90, double f0xBFA91F65F10DD814 }, %"struct.__llvm_libc::NumberPair" { double f0xBC7CCBEEEAE8129A, double f0xBFB2D52092CE19F4 }, %"struct.__llvm_libc::NumberPair" { double f0x3C3E2718D26ED688, double f0xBFB917A6BC29B42C }, %"struct.__llvm_libc::NumberPair" { double f0x3C7CBB1F71ACA352, double f0xBFBF564E56A97310 }, %"struct.__llvm_libc::NumberPair" { double f0x3C8DD9FFEAECBDC4, double f0xBFC2C8106E8E613C }, %"struct.__llvm_libc::NumberPair" { double f0x3C8AB3802218894F, double f0xBFC5E214448B3FC8 }, %"struct.__llvm_libc::NumberPair" { double f0x3C849B466E7FE360, double f0xBFC8F8B83C69A60C }, %"struct.__llvm_libc::NumberPair" { double f0x3C8035E2873CA432, double f0xBFCC0B826A7E4F64 }, %"struct.__llvm_libc::NumberPair" { double f0x3C850B7BBC4768B1, double f0xBFCF19F97B215F1C }, %"struct.__llvm_libc::NumberPair" { double f0x3C83ED9EFAA42AB3, double f0xBFD111D262B1F678 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9A8B5C974EE7B5, double f0xBFD294062ED59F04 }, %"struct.__llvm_libc::NumberPair" { double f0xBC94325F12BE8946, double f0xBFD4135C94176600 }, %"struct.__llvm_libc::NumberPair" { double f0xBC8FC2047E54E614, double f0xBFD58F9A75AB1FDC }, %"struct.__llvm_libc::NumberPair" { double f0x3C9512C678219317, double f0xBFD7088530FA45A0 }, %"struct.__llvm_libc::NumberPair" { double f0x3C92E59DBA7AB4C2, double f0xBFD87DE2A6AEA964 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9D24AFDADE848B, double f0xBFD9EF7943A8ED8C }, %"struct.__llvm_libc::NumberPair" { double f0xBC65B362CB974183, double f0xBFDB5D1009E15CC0 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9E97AF1A63C807, double f0xBFDCC66E9931C460 }, %"struct.__llvm_libc::NumberPair" { double f0x3C8C3E4EDC5872F8, double f0xBFDE2B5D3806F63C }, %"struct.__llvm_libc::NumberPair" { double f0xBC9FB44F80F92225, double f0xBFDF8BA4DBF89AB8 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA9697FAF2E2FE5, double f0xBFE073879922FFEC }, %"struct.__llvm_libc::NumberPair" { double f0x3CA7BC8EDA6AF93C, double f0xBFE11EB3541B4B24 }, %"struct.__llvm_libc::NumberPair" { double f0xBC8B25DD267F6600, double f0xBFE1C73B39AE68C8 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA5769D0FBCDDC3, double f0xBFE26D054CDD12E0 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9C20673B2116B2, double f0xBFE30FF7FCE17034 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA3C7C4BC72A92C, double f0xBFE3AFFA292050B8 }, %"struct.__llvm_libc::NumberPair" { double f0x3CAE7F895D302395, double f0xBFE44CF325091DD8 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA13C293EDCEB32, double f0xBFE4E6CABBE3E5E8 }, %"struct.__llvm_libc::NumberPair" { double f0x3C875720992BFBB2, double f0xBFE57D69348CECA0 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA24A366A5FE547, double f0xBFE610B7551D2CE0 }, %"struct.__llvm_libc::NumberPair" { double f0xBC921165F626CDD5, double f0xBFE6A09E667F3BCC }, %"struct.__llvm_libc::NumberPair" { double f0x3CABCAC43C389BA9, double f0xBFE72D0837EFFF98 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA21EA6F59BE15B, double f0xBFE7B5DF226AAFB0 }, %"struct.__llvm_libc::NumberPair" { double f0xBCAD217BE0E2B971, double f0xBFE83B0E0BFF976C }, %"struct.__llvm_libc::NumberPair" { double f0xBC969D0F6897664A, double f0xBFE8BC806B151740 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9615F32B6F907A, double f0xBFE93A22499263FC }, %"struct.__llvm_libc::NumberPair" { double f0xBC96788EBCC76DC6, double f0xBFE9B3E047F38740 }, %"struct.__llvm_libc::NumberPair" { double f0xBCADDAE89FD441D1, double f0xBFEA29A7A0462780 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9F98273C5D2495, double f0xBFEA9B66290EA1A4 }, %"struct.__llvm_libc::NumberPair" { double f0x3C8926DA300FFCCE, double f0xBFEB090A58150200 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA90E58336C64A8, double f0xBFEB728345196E3C }, %"struct.__llvm_libc::NumberPair" { double f0xBCA9F6963354E3FE, double f0xBFEBD7C0AC6F9528 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9A47D3A2A0DCBE, double f0xBFEC38B2F180BDB0 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9ED0489E16B9A0, double f0xBFEC954B213411F4 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA0F3DB5DAD5AC5, double f0xBFECED7AF43CC774 }, %"struct.__llvm_libc::NumberPair" { double f0xBCAAC42B5A8B6943, double f0xBFED4134D14DC938 }, %"struct.__llvm_libc::NumberPair" { double f0x3CAD75033DFB9CA8, double f0xBFED906BCF328D48 }, %"struct.__llvm_libc::NumberPair" { double f0xBC883C37C6107DB3, double f0xBFEDDB13B6CCC23C }, %"struct.__llvm_libc::NumberPair" { double f0xBC97F59C49F6CD6D, double f0xBFEE212104F686E4 }, %"struct.__llvm_libc::NumberPair" { double f0xBCAEE94A90D7B88B, double f0xBFEE6288EC48E110 }, %"struct.__llvm_libc::NumberPair" { double f0x3CAA27D3874701F9, double f0xBFEE9F4156C62DDC }, %"struct.__llvm_libc::NumberPair" { double f0x3C985F4E1B8298D0, double f0xBFEED740E7684964 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9AB4E148E52D9E, double f0xBFEF0A7EFB9230D8 }, %"struct.__llvm_libc::NumberPair" { double f0xBC98A11412B82346, double f0xBFEF38F3AC64E588 }, %"struct.__llvm_libc::NumberPair" { double f0xBC7562172A361FD3, double f0xBFEF6297CFF75CB0 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA3564ACEF1FF97, double f0xBFEF8764FA714BA8 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA5E82A3284D5C8, double f0xBFEFA7557F08A518 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9709BCCB89A989, double f0xBFEFC26470E19FD4 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA9E082721DFB8E, double f0xBFEFD88DA3D12524 }, %"struct.__llvm_libc::NumberPair" { double f0x3CAEADE132F3981D, double f0xBFEFE9CDAD01883C }, %"struct.__llvm_libc::NumberPair" { double f0xBCAE3A843D1DB55F, double f0xBFEFF621E3796D7C }, %"struct.__llvm_libc::NumberPair" { double f0xBC9765595D548D9A, double f0xBFEFFD886084CD0C }, %"struct.__llvm_libc::NumberPair" { double 0.000000e+00, double -1.000000e+00 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9765595D548D9A, double f0xBFEFFD886084CD0C }, %"struct.__llvm_libc::NumberPair" { double f0xBCAE3A843D1DB55F, double f0xBFEFF621E3796D7C }, %"struct.__llvm_libc::NumberPair" { double f0x3CAEADE132F3981D, double f0xBFEFE9CDAD01883C }, %"struct.__llvm_libc::NumberPair" { double f0xBCA9E082721DFB8E, double f0xBFEFD88DA3D12524 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9709BCCB89A989, double f0xBFEFC26470E19FD4 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA5E82A3284D5C8, double f0xBFEFA7557F08A518 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA3564ACEF1FF97, double f0xBFEF8764FA714BA8 }, %"struct.__llvm_libc::NumberPair" { double f0xBC7562172A361FD3, double f0xBFEF6297CFF75CB0 }, %"struct.__llvm_libc::NumberPair" { double f0xBC98A11412B82346, double f0xBFEF38F3AC64E588 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9AB4E148E52D9E, double f0xBFEF0A7EFB9230D8 }, %"struct.__llvm_libc::NumberPair" { double f0x3C985F4E1B8298D0, double f0xBFEED740E7684964 }, %"struct.__llvm_libc::NumberPair" { double f0x3CAA27D3874701F9, double f0xBFEE9F4156C62DDC }, %"struct.__llvm_libc::NumberPair" { double f0xBCAEE94A90D7B88B, double f0xBFEE6288EC48E110 }, %"struct.__llvm_libc::NumberPair" { double f0xBC97F59C49F6CD6D, double f0xBFEE212104F686E4 }, %"struct.__llvm_libc::NumberPair" { double f0xBC883C37C6107DB3, double f0xBFEDDB13B6CCC23C }, %"struct.__llvm_libc::NumberPair" { double f0x3CAD75033DFB9CA8, double f0xBFED906BCF328D48 }, %"struct.__llvm_libc::NumberPair" { double f0xBCAAC42B5A8B6943, double f0xBFED4134D14DC938 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA0F3DB5DAD5AC5, double f0xBFECED7AF43CC774 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9ED0489E16B9A0, double f0xBFEC954B213411F4 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9A47D3A2A0DCBE, double f0xBFEC38B2F180BDB0 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA9F6963354E3FE, double f0xBFEBD7C0AC6F9528 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA90E58336C64A8, double f0xBFEB728345196E3C }, %"struct.__llvm_libc::NumberPair" { double f0x3C8926DA300FFCCE, double f0xBFEB090A58150200 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9F98273C5D2495, double f0xBFEA9B66290EA1A4 }, %"struct.__llvm_libc::NumberPair" { double f0xBCADDAE89FD441D1, double f0xBFEA29A7A0462780 }, %"struct.__llvm_libc::NumberPair" { double f0xBC96788EBCC76DC6, double f0xBFE9B3E047F38740 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9615F32B6F907A, double f0xBFE93A22499263FC }, %"struct.__llvm_libc::NumberPair" { double f0xBC969D0F6897664A, double f0xBFE8BC806B151740 }, %"struct.__llvm_libc::NumberPair" { double f0xBCAD217BE0E2B971, double f0xBFE83B0E0BFF976C }, %"struct.__llvm_libc::NumberPair" { double f0x3CA21EA6F59BE15B, double f0xBFE7B5DF226AAFB0 }, %"struct.__llvm_libc::NumberPair" { double f0x3CABCAC43C389BA9, double f0xBFE72D0837EFFF98 }, %"struct.__llvm_libc::NumberPair" { double f0xBC921165F626CDD5, double f0xBFE6A09E667F3BCC }, %"struct.__llvm_libc::NumberPair" { double f0x3CA24A366A5FE547, double f0xBFE610B7551D2CE0 }, %"struct.__llvm_libc::NumberPair" { double f0x3C875720992BFBB2, double f0xBFE57D69348CECA0 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA13C293EDCEB32, double f0xBFE4E6CABBE3E5E8 }, %"struct.__llvm_libc::NumberPair" { double f0x3CAE7F895D302395, double f0xBFE44CF325091DD8 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA3C7C4BC72A92C, double f0xBFE3AFFA292050B8 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9C20673B2116B2, double f0xBFE30FF7FCE17034 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA5769D0FBCDDC3, double f0xBFE26D054CDD12E0 }, %"struct.__llvm_libc::NumberPair" { double f0xBC8B25DD267F6600, double f0xBFE1C73B39AE68C8 }, %"struct.__llvm_libc::NumberPair" { double f0x3CA7BC8EDA6AF93C, double f0xBFE11EB3541B4B24 }, %"struct.__llvm_libc::NumberPair" { double f0xBCA9697FAF2E2FE5, double f0xBFE073879922FFEC }, %"struct.__llvm_libc::NumberPair" { double f0xBC9FB44F80F92225, double f0xBFDF8BA4DBF89AB8 }, %"struct.__llvm_libc::NumberPair" { double f0x3C8C3E4EDC5872F8, double f0xBFDE2B5D3806F63C }, %"struct.__llvm_libc::NumberPair" { double f0x3C9E97AF1A63C807, double f0xBFDCC66E9931C460 }, %"struct.__llvm_libc::NumberPair" { double f0xBC65B362CB974183, double f0xBFDB5D1009E15CC0 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9D24AFDADE848B, double f0xBFD9EF7943A8ED8C }, %"struct.__llvm_libc::NumberPair" { double f0x3C92E59DBA7AB4C2, double f0xBFD87DE2A6AEA964 }, %"struct.__llvm_libc::NumberPair" { double f0x3C9512C678219317, double f0xBFD7088530FA45A0 }, %"struct.__llvm_libc::NumberPair" { double f0xBC8FC2047E54E614, double f0xBFD58F9A75AB1FDC }, %"struct.__llvm_libc::NumberPair" { double f0xBC94325F12BE8946, double f0xBFD4135C94176600 }, %"struct.__llvm_libc::NumberPair" { double f0xBC9A8B5C974EE7B5, double f0xBFD294062ED59F04 }, %"struct.__llvm_libc::NumberPair" { double f0x3C83ED9EFAA42AB3, double f0xBFD111D262B1F678 }, %"struct.__llvm_libc::NumberPair" { double f0x3C850B7BBC4768B1, double f0xBFCF19F97B215F1C }, %"struct.__llvm_libc::NumberPair" { double f0x3C8035E2873CA432, double f0xBFCC0B826A7E4F64 }, %"struct.__llvm_libc::NumberPair" { double f0x3C849B466E7FE360, double f0xBFC8F8B83C69A60C }, %"struct.__llvm_libc::NumberPair" { double f0x3C8AB3802218894F, double f0xBFC5E214448B3FC8 }, %"struct.__llvm_libc::NumberPair" { double f0x3C8DD9FFEAECBDC4, double f0xBFC2C8106E8E613C }, %"struct.__llvm_libc::NumberPair" { double f0x3C7CBB1F71ACA352, double f0xBFBF564E56A97310 }, %"struct.__llvm_libc::NumberPair" { double f0x3C3E2718D26ED688, double f0xBFB917A6BC29B42C }, %"struct.__llvm_libc::NumberPair" { double f0xBC7CCBEEEAE8129A, double f0xBFB2D52092CE19F4 }, %"struct.__llvm_libc::NumberPair" { double f0x3C2912BD0D569A90, double f0xBFA91F65F10DD814 }, %"struct.__llvm_libc::NumberPair" { double f0xBC5F938A73DB97FB, double f0xBF992155F7A3667C }], comdat, align 16
@_ZZN11__llvm_libc6fputil7generic15quick_get_roundEvE1x = linkonce_odr hidden global float f0x33800000, comdat, align 4
@_ZN11__llvm_libc4math31range_reduction_double_internal24ONE_TWENTY_EIGHT_OVER_PIE = linkonce_odr hidden local_unnamed_addr constant [64 x [4 x double]] [[4 x double] [double f0x4040000000000014, double f0x3CE7CC1B727220A8, double f0x39A4FE13ABE8FA9C, double f0xB66911F924EB5336], [4 x double] [double f0x4040000000145F30, double f0x3CEB727220A94FE0, double f0x39A3ABE8FA9A6EE0, double f0x364B6C52B3278872], [4 x double] [double f0x404000145F306DC8, double f0x3D0C882A53F84EB0, double f0xB9A70565911F9250, double f0x3664ACC9E21C8210], [4 x double] [double f0x40445F306DC9C884, double f0xBD05AC07B1505C14, double f0xB9C96447E493AD4C, double f0xB67B0EF1BEF806BA], [4 x double] [double f0xC03F246C6EFAB580, double f0xBCEEC54170565910, double f0xB9AF924EB53361E0, double f0x366C820FF28B1D5F], [4 x double] [double f0x403391054A7F09D4, double f0x3CFF47D4D377036C, double f0x39B8A5664F10E410, double f0x365FE5163ABDEBBC], [4 x double] [double f0x401529FC2757D1F4, double f0x3CD34DDC0DB62958, double f0x39993C439041FE50, double f0x36563ABDEBBC561B], [4 x double] [double f0xBFEEC54170565910, double f0xBCAF924EB53361E0, double f0x396C820FF28B1D60, double f0xB620A21D4F246DC9], [4 x double] [double f0xC04505C1596447E4, double f0xBCF275A99B0EF1C0, double f0x39B07F9458EAF7B0, double f0xB670EA79236E4717], [4 x double] [double f0xC00596447E493AD4, double f0xBCB9B0EF1BEF806C, double f0x39563ABDEBBC561C, double f0xB601B7238B7B645A], [4 x double] [double f0x404BB81B6C52B328, double f0xBCEDE37DF00D74E4, double f0x39A5EF5DE2B0DB94, double f0xB66C8E2DED916900], [4 x double] [double f0x404B6C52B3278874, double f0xBD0F7C035D38A844, double f0x39C778AC36E48DC8, double f0xB676F6C8B47FE6DB], [4 x double] [double f0x4042B32788720840, double f0xBCDAE9C5421443A8, double f0xB99E48DB91C5BDB4, double f0x365D2E006492EEA1], [4 x double] [double f0xC048778DF7C035D4, double f0x3CED5EF5DE2B0DB8, double f0x39A2371D2126E970, double f0x35F924BBA8274648], [4 x double] [double f0xC03BEF806BA71508, double f0xBCD443A9E48DB91C, double f0xB976F6C8B47FE6DC, double f0x36277504E8C90E7F], [4 x double] [double f0xBFDAE9C5421443A8, double f0xBC9E48DB91C5BDB4, double f0x395D2E006492EEA0, double f0x3603A32439FC3BD6], [4 x double] [double f0xC0438A84288753C8, double f0xBD01B7238B7B645C, double f0x39CC00C925DD413C, double f0xB68CDBC603C429C7], [4 x double] [double f0xC020A21D4F246DC8, double f0xBCDC5BDB22D1FF9C, double f0x39825DD413A32438, double f0x364FC3BD63962535], [4 x double] [double f0xC02D4F246DC8E2E0, double f0x3CE26E9700324978, double f0xB995F62E6DE301E4, double f0x365EB1CB129A73EF], [4 x double] [double f0xC03236E4716F6C8C, double f0x3CE7003249775050, double f0xB9A736F180F10A70, double f0xB66A76B2C608BBEE], [4 x double] [double f0x403B8E909374B800, double f0x3CF924BBA8274648, double f0x399CFE1DEB1CB128, double f0x365A73EE88235F53], [4 x double] [double f0x40309374B801924C, double f0xBCD15F62E6DE3020, double f0x399DEB1CB129A740, double f0xB65177DCA0AD144C], [4 x double] [double f0xC0268FFCDB688AFC, double f0x3CDD1921CFE1DEB0, double f0x399CB129A73EE884, double f0xB65CA0AD144BB7B1], [4 x double] [double f0x3FF924BBA8274648, double f0x3C9CFE1DEB1CB128, double f0x395A73EE88235F54, double f0xB61144BB7B166390], [4 x double] [double f0xC04A22BEC5CDBC60, double f0xBCDE214E34ED658C, double f0xB95177DCA0AD144C, double f0x35F213A671C09AD1], [4 x double] [double f0x4003A32439FC3BD8, double f0xBCCC69DACB1822F0, double f0x3961AFA975DA2428, double f0xB616638FD94BA082], [4 x double] [double f0xC03B78C0788538D4, double f0x3CD29A73EE882360, double f0xB985A28976F62CC8, double f0x363C09AD17DF904E], [4 x double] [double f0x404FC3BD63962534, double f0x3CFCFBA208D7D4BC, double f0xB9B12EDEC598E3F8, double f0x367AD17DF904E647], [4 x double] [double f0xC014E34ED658C118, double f0x3CC046BEA5D76890, double f0x3973A671C09AD17C, double f0x363F904E64758E61], [4 x double] [double f0x40462534E7DD1048, double f0xBD0415A28976F62C, double f0xB9B8E3F652E82070, double f0x3653991D63983534], [4 x double] [double f0xC0363045DF7282B4, double f0xBCD44BB7B16638FC, double f0xB9994BA081BEC670, double f0x365D639835339F4A], [4 x double] [double f0x404D1046BEA5D768, double f0x3CF213A671C09AD0, double f0x39B7DF904E647590, double f0xB679F2B3182D8DEF], [4 x double] [double f0x402AFA975DA24274, double f0x3CD9C7026B45F7E4, double f0x3953991D63983534, double f0xB5F82D8DEE81D108], [4 x double] [double f0xC04A28976F62CC70, double f0xBD0FB29741037D8C, double f0xB9BB8A719F2B3184, double f0x367272117E2EF7E5], [4 x double] [double f0xC0476F62CC71FB28, double f0xBD0741037D8CDC54, double f0x39ACC1A99CFA4E44, double f0xB66D03A21036BE27], [4 x double] [double f0x404D338E04D68BF0, double f0xBCDBEC66E29C67CC, double f0x399339F49C845F8C, double f0xB63081B5F13801DA], [4 x double] [double f0x403C09AD17DF9050, double f0xBCF9B8A719F2B318, double f0xB986C6F740E8840C, double f0xB64AF89C00ED0004], [4 x double] [double f0x40468BEFC827323C, double f0xBD038CF9598C16C8, double f0x39C08BF177BF2508, double f0xB673801DA00087EA], [4 x double] [double f0xC04037D8CDC538D0, double f0x3CEA99CFA4E422FC, double f0x39877BF250763FF0, double f0x3642FFFBC0B301FE], [4 x double] [double f0xC048CDC538CF9598, double f0xBCF82D8DEE81D108, double f0xB97B5F13801DA000, double f0xB620FD33F8086877], [4 x double] [double f0xC024E33E566305B0, double f0xBCEBDD03A21036C0, double f0x39AD8FFC4BFFEF04, double f0xB6633F80868773A5], [4 x double] [double f0xC03F2B3182D8DEE8, double f0xBCBD1081B5F13800, double f0xB97DA00087E99FC0, double f0xB610D0EE74A5F593], [4 x double] [double f0xC048C16C6F740E88, double f0xBCE036BE27003B40, double f0xB920FD33F8086878, double f0x35D8B5A0A6D1F6D3], [4 x double] [double f0x4043908BF177BF24, double f0x3D00763FF12FFFBC, double f0x3976603FBCBC462C, double f0x3636829B47DB4DA0], [4 x double] [double f0x4037E2EF7E4A0EC8, double f0xBC7DA00087E99FC0, double f0xB910D0EE74A5F594, double f0x35D1F6D367ECF27D], [4 x double] [double f0xC03081B5F13801DC, double f0x3CFFFF7816603FBC, double f0x39A788C5AD053690, double f0xB6425930261B069F], [4 x double] [double f0xC04AF89C00ED0004, double f0xBCDFA67F010D0EE8, double f0x3986B414DA3EDA6C, double f0x363FB3C9F2C26DD4], [4 x double] [double f0xC04C00ED00043F4C, double f0xBCFFC04343B9D298, double f0x3984DA3EDA6CFDA0, double f0xB64B069EC9161738], [4 x double] [double f0x4042FFFBC0B301FC, double f0x3D0E5E2316B414DC, double f0xB9CC125930261B08, double f0x3686136E9E8C7ECD], [4 x double] [double f0xC020FD33F8086878, double f0x3CD8B5A0A6D1F6D4, double f0xB9830261B069EC90, double f0xB6461738132C3403], [4 x double] [double f0xC039FC04343B9D28, double f0xBCF7D64B824B2604, double f0xB9A86C1A7B24585C, double f0xB65C09961A015D29], [4 x double] [double f0xC010D0EE74A5F594, double f0x3CD1F6D367ECF27C, double f0x3986136E9E8C7ECC, double f0x3643CBFD45AEA4F7], [4 x double] [double f0xC04DCE94BEB25C14, double f0x3D0A6CFD9E4F9614, double f0xB9B22C2E70265868, double f0xB615D28AD8453814], [4 x double] [double f0xC044BEB25C125930, double f0xBCD30D834F648B0C, double f0x3978FD9A797FA8B4, double f0x363D49EEB1FAF97C], [4 x double] [double f0x403B47DB4D9FB3C8, double f0x3CFF2C26DD3D18FC, double f0x39B9A797FA8B5D48, double f0x367EEB1FAF97C5ED], [4 x double] [double f0xC0425930261B06A0, double f0x3D036E9E8C7ECD3C, double f0x39B7FA8B5D49EEB0, double f0x367FAF97C5ECF41D], [4 x double] [double f0x403FB3C9F2C26DD4, double f0xBCC738132C3402BC, double f0x398AEA4F758FD7CC, double f0xB60D0985F18C10EB], [4 x double] [double f0xC04B069EC9161738, double f0xBCC32C3402BA515C, double f0x397EEB1FAF97C5EC, double f0x362E839CFBC52949], [4 x double] [double f0xC04EC9161738132C, double f0xBCDA015D28AD8454, double f0x397FAF97C5ECF41C, double f0x362CFBC529497536], [4 x double] [double f0xC0461738132C3404, double f0x3D045AEA4F758FD8, double f0xB99A0E84C2F8C608, double f0xB63D6B5B45650128], [4 x double] [double f0x402FB34F2FF516BC, double f0xBCE6C229C0A0D074, double f0xB9730BE31821D6B4, double f0xB63B4565012813B8], [4 x double] [double f0x4043CBFD45AEA4F8, double f0xBCF4E050683A130C, double f0x397CE7DE294A4BA8, double f0x363AFED7EC47E357], [4 x double] [double f0xC015D28AD8453814, double f0xBC9A0E84C2F8C608, double f0xB93D6B5B45650128, double f0xB5B3B81CA8BDEA7F], [4 x double] [double f0xC0415B08A7028340, double f0xBD0D0985F18C10EC, double f0x39B4A4BA9AFED7EC, double f0x3651F8D5D0856033]], comdat, align 16
@__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.SIN_COEFFS = private unnamed_addr constant [7 x %"struct.__llvm_libc::fputil::DyadicFloat"] [%"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -127, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 0, i64 -9223372036854775808] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" { i8 1 }, i32 -130, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -6148914691236517205, i64 -6148914691236517206] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -134, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -8608480567731124087, i64 -8608480567731124088] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" { i8 1 }, i32 -140, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 58561092297490640, i64 -3455104445551947763] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -146, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 6200968995500953330, i64 -5120842182013903747] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" { i8 1 }, i32 -153, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 4197114891794091792, i64 -2940240054281888641] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -160, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 2024806264520058526, i64 -5723458724435571739] } } }], align 16
@__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.COS_COEFFS = private unnamed_addr constant [7 x %"struct.__llvm_libc::fputil::DyadicFloat"] [%"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -127, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 0, i64 -9223372036854775808] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" { i8 1 }, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 0, i64 -9223372036854775808] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -132, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -6148914691236517205, i64 -6148914691236517206] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" { i8 1 }, i32 -137, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 6968769983401386166, i64 -5329059399071648245] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -143, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 58561092297490640, i64 -3455104445551947763] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" { i8 1 }, i32 -149, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 8650124011142672987, i64 -7786022560353033321] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -156, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 2798076594529394528, i64 -8109074727424442966] } } }], align 16
@_ZN11__llvm_libc4math31range_reduction_double_internal22SIN_K_PI_OVER_128_F128E = linkonce_odr hidden local_unnamed_addr constant [65 x %"struct.__llvm_libc::fputil::DyadicFloat"] [%"struct.__llvm_libc::fputil::DyadicFloat" zeroinitializer, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -133, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -4235092514175922388, i64 -3960159695578861623] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -132, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 7644743042569359729, i64 -3964522783949414601] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -131, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -615458190766885436, i64 -7590530652771996059] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -131, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -4091119449552227447, i64 -3981967253739315442] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -131, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 8090481084352399927, i64 -382116895390142046] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -130, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 2966074853671422, i64 -7619946033341411053] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -130, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 4606887454819086605, i64 -5831983240432438618] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -130, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 6685804814532401232, i64 -4051619107753142862] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -130, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 1061831011681862605, i64 -2279926060084946971] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -130, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 4765332098224642445, i64 -517971299071896198] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -129, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -7475598294795402490, i64 -8606780117043922172] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -129, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -5887427971829205164, i64 -7737129774044664507] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -129, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 3425373739989322763, i64 -6873930502241252839] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -129, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -9142424644262823874, i64 -6017702260597921808] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -129, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -7150608766173584456, i64 -5168960808991001226] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -129, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 3540606273659460663, i64 -4328217397534452083] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -129, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -6335842581201722652, i64 -3495978458621914771] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -129, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 3903698885296402480, i64 -2672745301870771877] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -129, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 2914618528457478605, i64 -1859013812151979852] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -129, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 7802743516694253342, i64 -1055274150887565072] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -129, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 2864426325531211985, i64 -262010460795711526] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -4623060363363480897, i64 -8963222323985421132] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -5146828758499932084, i64 -8577779899608525791] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -4925583476696725401, i64 -8198282170225769628] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -5658736024626282130, i64 -7824957731078998716] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 1859643897723463110, i64 -7458031458850855160] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -2135206137866703256, i64 -7097724376207472157] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 4274311794150482766, i64 -6744253518662684480] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 1486027853416130723, i64 -6397831803843950434] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 2012223379129608524, i64 -6058667903238734571] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -1960525931960025902, i64 -5726966116498606374] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 6448461645324402335, i64 -5402926248376769404] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -7070119585620691749, i64 -5086743488373149158] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -6015346685892530851, i64 -4778608293159536912] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -4760180163081008169, i64 -4478706271855612272] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 4889261961858462315, i64 -4187218074224949849] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -8992241378810842587, i64 -3904319281858356614] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 2571328730823238826, i64 -3630180302410087010] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 8381174858623217554, i64 -3364966266950643987] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -706809269444919703, i64 -3108836930497996775] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 2646425533725111460, i64 -2861946575787131685] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 3177771339358028796, i64 -2624443920335901561] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 5411543833844625005, i64 -2396472026863153925] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -799203978883868656, i64 -2178168217113098607] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 1308161200889352541, i64 -1969663989137823820] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 1319881600599107887, i64 -1771084938087786618] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 1561981287876913187, i64 -1582550680557990558] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 9106562333884113281, i64 -1404174782535421627] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -8721007305662615525, i64 -1236064690991144185] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 7427136944769364758, i64 -1078321669158263299] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -6536856265327552862, i64 -931040735534739596] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 1602257268029987013, i64 -794310606647799060] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 3204627080388017187, i64 -668213643614414360] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -4058369210235448901, i64 -552825802530047662] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 4973291241423448448, i64 -448216588715538904] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 2410168391851209263, i64 -354449014849699498] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 2695255942028334953, i64 -271579563012830805] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -1520319376071480386, i64 -199658150664030965] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 -8012715633588931345, i64 -138728100572784067] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 4699804169268554223, i64 -88826114722943760] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 1109721915849409930, i64 -49982252204830551] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 4764402525700441406, i64 -22219911108759779] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -128, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 6221535020768958258, i64 -5555814430906919] } } }, %"struct.__llvm_libc::fputil::DyadicFloat" { %"struct.__llvm_libc::Sign" zeroinitializer, i32 -127, %"struct.__llvm_libc::BigInt" { %"struct.__llvm_libc::cpp::array" { [2 x i64] [i64 0, i64 -9223372036854775808] } } }], comdat, align 16
@_ZN11__llvm_libc10libc_errnoE = external hidden global %"struct.__llvm_libc::Errno", align 1

; Function Attrs: mustprogress sspstrong uwtable
define hidden noundef double @_ZN11__llvm_libc3sinEd(double noundef %0) local_unnamed_addr #0 {
  %2 = tail call noundef double @_ZN11__llvm_libc4math3sinEd(double noundef %0)
  ret double %2
}

; Function Attrs: inlinehint mustprogress sspstrong uwtable
define linkonce_odr hidden noundef double @_ZN11__llvm_libc4math3sinEd(double noundef %0) local_unnamed_addr #1 comdat {
  %2 = alloca %"struct.__llvm_libc::NumberPair", align 8
  %3 = alloca %"struct.__llvm_libc::math::range_reduction_double_internal::LargeRangeReduction", align 8
  %4 = bitcast double %0 to i64
  %5 = lshr i64 %4, 52
  %6 = trunc nuw nsw i64 %5 to i16
  %7 = and i16 %6, 2047
  call void @llvm.lifetime.start.p0(ptr nonnull %2) #9
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %2, i8 0, i64 16, i1 false)
  call void @llvm.lifetime.start.p0(ptr nonnull %3) #9
  %8 = icmp samesign ult i16 %7, 1039
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(48) %3, i8 0, i64 48, i1 false)
  br i1 %8, label %9, label %90, !prof !10

9:                                                ; preds = %1
  %10 = icmp samesign ult i16 %7, 1019
  br i1 %10, label %11, label %58, !prof !11

11:                                               ; preds = %9
  %12 = icmp samesign ult i16 %7, 997
  br i1 %12, label %13, label %36, !prof !11

13:                                               ; preds = %11
  %14 = fcmp oeq double %0, 0.000000e+00
  br i1 %14, label %15, label %17, !prof !11

15:                                               ; preds = %13
  %16 = fadd double %0, %0
  br label %229

17:                                               ; preds = %13
  %18 = icmp samesign ult i16 %7, 4
  br i1 %18, label %19, label %33, !prof !11

19:                                               ; preds = %17
  %20 = tail call noundef i32 @_ZN11__llvm_libc6fputil7generic15quick_get_roundEv()
  %21 = icmp eq i32 %20, 3072
  br i1 %21, label %30, label %22

22:                                               ; preds = %19
  %23 = icmp sgt i64 %4, -1
  %24 = icmp eq i32 %20, 1024
  %25 = and i1 %23, %24
  br i1 %25, label %30, label %26

26:                                               ; preds = %22
  %27 = icmp slt i64 %4, 0
  %28 = icmp eq i32 %20, 2048
  %29 = and i1 %27, %28
  br i1 %29, label %30, label %33

30:                                               ; preds = %19, %22, %26
  %31 = add i64 %4, -1
  %32 = bitcast i64 %31 to double
  br label %229

33:                                               ; preds = %26, %17
  %34 = fmul double %0, f0x3C90000000000000
  %35 = fsub double %0, %34
  br label %229

36:                                               ; preds = %11
  %37 = fmul double %0, %0
  %38 = fmul double %37, f0x3F8111111110F491
  %39 = fadd double %38, f0xBFC5555555555555
  %40 = fmul double %37, f0x3EC71C24233F1BAF
  %41 = fadd double %40, f0xBF2A01A00E16AF3E
  %42 = fmul double %37, %37
  %43 = fmul double %0, %37
  %44 = fmul double %42, %41
  %45 = fadd double %39, %44
  %46 = fmul double %43, %45
  %47 = fmul double %37, f0x3CB0000000000000
  %48 = fadd double %47, f0x3BB0000000000000
  %49 = fmul double %0, %48
  %50 = fadd double %49, %46
  %51 = fsub double %46, %49
  %52 = fadd double %0, %50
  %53 = fadd double %0, %51
  %54 = fcmp oeq double %52, %53
  br i1 %54, label %229, label %55, !prof !10

55:                                               ; preds = %36
  %56 = call noundef i32 @_ZN11__llvm_libc4math31range_reduction_double_internal21range_reduction_smallEdRNS_10NumberPairIdEE(double noundef %0, ptr noundef nonnull align 8 dereferenceable(16) %2)
  %57 = call noundef double @_ZN11__llvm_libc4math12sin_accurateEdtjRKNS0_31range_reduction_double_internal19LargeRangeReductionE(double noundef %0, i16 noundef zeroext %7, i32 noundef %56, ptr noundef nonnull align 8 dereferenceable(48) %3)
  br label %229

58:                                               ; preds = %9
  %59 = fmul double %0, f0x40445F306DC9C883
  %60 = tail call double @llvm.fabs.f64(double %59)
  %61 = fcmp olt double %60, f0x4340000000000000
  br i1 %61, label %62, label %77

62:                                               ; preds = %58
  %63 = fcmp olt double %59, 0.000000e+00
  %64 = fadd double %59, f0xC330000000000000
  %65 = fadd double %64, f0x4330000000000000
  %66 = fadd double %59, f0x4330000000000000
  %67 = fadd double %66, f0xC330000000000000
  %68 = select i1 %63, double %65, double %67
  %69 = fsub double %59, %68
  %70 = fcmp ogt double %69, 5.000000e-01
  br i1 %70, label %71, label %73, !prof !11

71:                                               ; preds = %62
  %72 = fadd double %68, 1.000000e+00
  br label %77

73:                                               ; preds = %62
  %74 = fcmp olt double %69, -5.000000e-01
  br i1 %74, label %75, label %77, !prof !11

75:                                               ; preds = %73
  %76 = fadd double %68, -1.000000e+00
  br label %77

77:                                               ; preds = %58, %71, %73, %75
  %78 = phi double [ %68, %73 ], [ %72, %71 ], [ %76, %75 ], [ %59, %58 ]
  %79 = fmul double %78, f0x3F9921FB54400000
  %80 = fsub double %0, %79
  %81 = fmul double %78, f0xBD70B4611A600000
  %82 = fadd double %81, %80
  %83 = getelementptr inbounds nuw i8, ptr %2, i64 8
  store double %82, ptr %83, align 8, !tbaa !12
  %84 = fsub double %80, %82
  %85 = fadd double %81, %84
  %86 = fmul double %78, f0x3B43198A2E037073
  %87 = fsub double %85, %86
  store double %87, ptr %2, align 8, !tbaa !15
  %88 = fptosi double %78 to i64
  %89 = trunc i64 %88 to i32
  br label %111

90:                                               ; preds = %1
  %91 = icmp eq i16 %7, 2047
  br i1 %91, label %92, label %106, !prof !11

92:                                               ; preds = %90
  %93 = tail call double @llvm.fabs.f64(double %0)
  %94 = bitcast double %93 to i64
  %95 = icmp samesign ugt i64 %94, 9218868437227405312
  %96 = and i64 %4, 9221120237041090560
  %97 = icmp ne i64 %96, 9221120237041090560
  %98 = and i1 %95, %97
  br i1 %98, label %99, label %101

99:                                               ; preds = %92
  %100 = tail call noundef i32 @_ZN11__llvm_libc6fputil24raise_except_if_requiredEi(i32 noundef 1)
  br label %229

101:                                              ; preds = %92
  %102 = and i64 %4, 4503599627370495
  %103 = icmp eq i64 %102, 0
  br i1 %103, label %104, label %229

104:                                              ; preds = %101
  tail call void @_ZN11__llvm_libc6fputil21set_errno_if_requiredEi(i32 noundef 33)
  %105 = tail call noundef i32 @_ZN11__llvm_libc6fputil24raise_except_if_requiredEi(i32 noundef 1)
  br label %229

106:                                              ; preds = %90
  %107 = call noundef i32 @_ZN11__llvm_libc4math31range_reduction_double_internal19LargeRangeReduction4fastEdRNS_10NumberPairIdEE(ptr noundef nonnull align 8 dereferenceable(48) %3, double noundef %0, ptr noundef nonnull align 8 dereferenceable(16) %2)
  %108 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %109 = load double, ptr %108, align 8, !tbaa !12
  %110 = load double, ptr %2, align 8, !tbaa !15
  br label %111

111:                                              ; preds = %106, %77
  %112 = phi double [ %87, %77 ], [ %110, %106 ]
  %113 = phi double [ %82, %77 ], [ %109, %106 ]
  %114 = phi i32 [ %89, %77 ], [ %107, %106 ]
  %115 = fmul double %113, %113
  %116 = fmul double %115, f0x3F2A01A01A01A01A
  %117 = fsub double f0x3F81111111111111, %116
  %118 = fmul double %115, f0x3FA5555555555555
  %119 = fadd double %118, -5.000000e-01
  %120 = fmul double %113, %115
  %121 = fmul double %115, %117
  %122 = fadd double %121, f0xBFC5555555555555
  %123 = fmul double %115, %119
  %124 = fadd double %123, 1.000000e+00
  %125 = fmul double %112, %124
  %126 = fmul double %120, %122
  %127 = fadd double %126, %125
  %128 = fmul double %113, -5.000000e-01
  %129 = fmul double %113, f0x41A0000002000000
  %130 = fsub double %113, %129
  %131 = fadd double %129, %130
  %132 = fsub double %113, %131
  %133 = fmul double %128, f0x41A0000002000000
  %134 = fsub double %128, %133
  %135 = fadd double %133, %134
  %136 = fsub double %128, %135
  %137 = fmul double %113, %128
  %138 = fneg double %137
  %139 = call double @llvm.fmuladd.f64(double %131, double %135, double %138)
  %140 = call double @llvm.fmuladd.f64(double %131, double %136, double %139)
  %141 = call double @llvm.fmuladd.f64(double %132, double %135, double %140)
  %142 = call double @llvm.fmuladd.f64(double %132, double %136, double %141)
  %143 = fadd double %137, 1.000000e+00
  %144 = fadd double %143, -1.000000e+00
  %145 = fsub double %137, %144
  %146 = fadd double %145, %142
  %147 = fmul double %115, f0x3EFA01A01A01A01A
  %148 = fadd double %147, f0xBF56C16C16C16C17
  %149 = fmul double %115, f0x3FC5555555555555
  %150 = fadd double %149, -1.000000e+00
  %151 = fmul double %115, %115
  %152 = fmul double %113, %112
  %153 = fmul double %115, %148
  %154 = fadd double %153, f0x3FA5555555555555
  %155 = fmul double %152, %150
  %156 = fadd double %155, %146
  %157 = fmul double %151, %154
  %158 = fadd double %157, %156
  %159 = fadd double %113, %127
  %160 = fsub double %159, %113
  %161 = fsub double %127, %160
  %162 = fadd double %143, %158
  %163 = fsub double %162, %143
  %164 = fsub double %158, %163
  %165 = call double @llvm.fabs.f64(double %120)
  %166 = fmul double %165, f0x3CC0000000000000
  %167 = fadd double %166, f0x3960000000000000
  %168 = and i32 %114, 255
  %169 = zext nneg i32 %168 to i64
  %170 = getelementptr inbounds nuw [16 x i8], ptr @_ZN11__llvm_libc4math31range_reduction_double_internal17SIN_K_PI_OVER_128E, i64 %169
  %171 = load double, ptr %170, align 16, !tbaa !16
  %172 = getelementptr inbounds nuw i8, ptr %170, i64 8
  %173 = load double, ptr %172, align 8, !tbaa !16
  %174 = add i32 %114, 64
  %175 = and i32 %174, 255
  %176 = zext nneg i32 %175 to i64
  %177 = getelementptr inbounds nuw [16 x i8], ptr @_ZN11__llvm_libc4math31range_reduction_double_internal17SIN_K_PI_OVER_128E, i64 %176
  %178 = load double, ptr %177, align 16, !tbaa !16
  %179 = getelementptr inbounds nuw i8, ptr %177, i64 8
  %180 = load double, ptr %179, align 8, !tbaa !16
  %181 = fmul double %162, f0x41A0000002000000
  %182 = fsub double %162, %181
  %183 = fadd double %181, %182
  %184 = fsub double %162, %183
  %185 = fmul double %173, f0x41A0000002000000
  %186 = fsub double %173, %185
  %187 = fadd double %185, %186
  %188 = fsub double %173, %187
  %189 = fmul double %173, %162
  %190 = fneg double %189
  %191 = call double @llvm.fmuladd.f64(double %183, double %187, double %190)
  %192 = call double @llvm.fmuladd.f64(double %183, double %188, double %191)
  %193 = call double @llvm.fmuladd.f64(double %184, double %187, double %192)
  %194 = call double @llvm.fmuladd.f64(double %184, double %188, double %193)
  %195 = fmul double %171, %162
  %196 = fadd double %195, %194
  %197 = fmul double %173, %164
  %198 = fadd double %197, %196
  %199 = fmul double %159, f0x41A0000002000000
  %200 = fsub double %159, %199
  %201 = fadd double %199, %200
  %202 = fsub double %159, %201
  %203 = fmul double %180, f0x41A0000002000000
  %204 = fsub double %180, %203
  %205 = fadd double %203, %204
  %206 = fsub double %180, %205
  %207 = fmul double %180, %159
  %208 = fneg double %207
  %209 = call double @llvm.fmuladd.f64(double %201, double %205, double %208)
  %210 = call double @llvm.fmuladd.f64(double %201, double %206, double %209)
  %211 = call double @llvm.fmuladd.f64(double %202, double %205, double %210)
  %212 = call double @llvm.fmuladd.f64(double %202, double %206, double %211)
  %213 = fmul double %178, %159
  %214 = fadd double %213, %212
  %215 = fmul double %180, %161
  %216 = fadd double %215, %214
  %217 = fadd double %207, %189
  %218 = fsub double %217, %189
  %219 = fsub double %207, %218
  %220 = fadd double %216, %198
  %221 = fadd double %219, %220
  %222 = fadd double %167, %221
  %223 = fsub double %221, %167
  %224 = fadd double %217, %222
  %225 = fadd double %217, %223
  %226 = fcmp oeq double %224, %225
  br i1 %226, label %229, label %227, !prof !10

227:                                              ; preds = %111
  %228 = call noundef double @_ZN11__llvm_libc4math12sin_accurateEdtjRKNS0_31range_reduction_double_internal19LargeRangeReductionE(double noundef %0, i16 noundef zeroext %7, i32 noundef %114, ptr noundef nonnull align 8 dereferenceable(48) %3)
  br label %229

229:                                              ; preds = %227, %111, %101, %104, %30, %55, %36, %99, %33, %15
  %230 = phi double [ %16, %15 ], [ %35, %33 ], [ %32, %30 ], [ %52, %36 ], [ +qnan, %101 ], [ +qnan, %99 ], [ %57, %55 ], [ +qnan, %104 ], [ %228, %227 ], [ %224, %111 ]
  call void @llvm.lifetime.end.p0(ptr nonnull %3) #9
  call void @llvm.lifetime.end.p0(ptr nonnull %2) #9
  ret double %230
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #2

; Function Attrs: inlinehint mustprogress sspstrong uwtable
define linkonce_odr hidden noundef i32 @_ZN11__llvm_libc4math31range_reduction_double_internal21range_reduction_smallEdRNS_10NumberPairIdEE(double noundef %0, ptr noundef nonnull align 8 dereferenceable(16) %1) local_unnamed_addr #1 comdat {
  %3 = fmul double %0, f0x40445F306DC9C883
  %4 = tail call double @llvm.fabs.f64(double %3)
  %5 = fcmp olt double %4, f0x4340000000000000
  br i1 %5, label %6, label %21

6:                                                ; preds = %2
  %7 = fcmp olt double %3, 0.000000e+00
  %8 = fadd double %3, f0xC330000000000000
  %9 = fadd double %8, f0x4330000000000000
  %10 = fadd double %3, f0x4330000000000000
  %11 = fadd double %10, f0xC330000000000000
  %12 = select i1 %7, double %9, double %11
  %13 = fsub double %3, %12
  %14 = fcmp ogt double %13, 5.000000e-01
  br i1 %14, label %15, label %17, !prof !11

15:                                               ; preds = %6
  %16 = fadd double %12, 1.000000e+00
  br label %21

17:                                               ; preds = %6
  %18 = fcmp olt double %13, -5.000000e-01
  br i1 %18, label %19, label %21, !prof !11

19:                                               ; preds = %17
  %20 = fadd double %12, -1.000000e+00
  br label %21

21:                                               ; preds = %2, %15, %17, %19
  %22 = phi double [ %12, %17 ], [ %16, %15 ], [ %20, %19 ], [ %3, %2 ]
  %23 = fmul double %22, f0x3F9921FB54400000
  %24 = fsub double %0, %23
  %25 = fmul double %22, f0xBD70B4611A600000
  %26 = fadd double %25, %24
  %27 = getelementptr inbounds nuw i8, ptr %1, i64 8
  store double %26, ptr %27, align 8, !tbaa !12
  %28 = fsub double %24, %26
  %29 = fadd double %25, %28
  %30 = fmul double %22, f0x3B43198A2E037073
  %31 = fsub double %29, %30
  store double %31, ptr %1, align 8, !tbaa !15
  %32 = fptosi double %22 to i64
  %33 = trunc i64 %32 to i32
  ret i32 %33
}

; Function Attrs: inlinehint mustprogress sspstrong uwtable
define linkonce_odr hidden noundef double @_ZN11__llvm_libc4math12sin_accurateEdtjRKNS0_31range_reduction_double_internal19LargeRangeReductionE(double noundef %0, i16 noundef zeroext %1, i32 noundef %2, ptr noundef nonnull align 8 dereferenceable(48) %3) local_unnamed_addr #1 comdat {
  %5 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", align 8
  %6 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", align 8
  %7 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", align 8
  %8 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", align 8
  %9 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", align 8
  call void @llvm.lifetime.start.p0(ptr nonnull %5) #9
  store i8 0, ptr %5, align 8, !tbaa !17
  %10 = getelementptr inbounds nuw i8, ptr %5, i64 4
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(20) %10, i8 0, i64 20, i1 false)
  call void @llvm.lifetime.start.p0(ptr nonnull %6) #9
  store i8 0, ptr %6, align 8, !tbaa !17
  %11 = getelementptr inbounds nuw i8, ptr %6, i64 4
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(20) %11, i8 0, i64 20, i1 false)
  call void @llvm.lifetime.start.p0(ptr nonnull %7) #9
  store i8 0, ptr %7, align 8, !tbaa !17
  %12 = getelementptr inbounds nuw i8, ptr %7, i64 4
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 4 dereferenceable(20) %12, i8 0, i64 20, i1 false)
  %13 = icmp ult i16 %1, 1039
  br i1 %13, label %14, label %15, !prof !10

14:                                               ; preds = %4
  call void @_ZN11__llvm_libc4math31range_reduction_double_internal26range_reduction_small_f128Ed(ptr dead_on_unwind nonnull writable sret(%"struct.__llvm_libc::fputil::DyadicFloat") align 8 %5, double noundef %0)
  br label %16

15:                                               ; preds = %4
  call void @llvm.lifetime.start.p0(ptr nonnull %8) #9
  call void @_ZNK11__llvm_libc4math31range_reduction_double_internal19LargeRangeReduction8accurateEv(ptr dead_on_unwind nonnull writable sret(%"struct.__llvm_libc::fputil::DyadicFloat") align 8 %8, ptr noundef nonnull align 8 dereferenceable(48) %3)
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %5, ptr noundef nonnull align 8 dereferenceable(24) %8, i64 24, i1 false), !tbaa.struct !19
  call void @llvm.lifetime.end.p0(ptr nonnull %8) #9
  br label %16

16:                                               ; preds = %15, %14
  call void @_ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_(ptr noundef nonnull align 8 dereferenceable(24) %5, ptr noundef nonnull align 8 dereferenceable(24) %6, ptr noundef nonnull align 8 dereferenceable(24) %7)
  %17 = and i32 %2, 64
  %18 = icmp eq i32 %17, 0
  %19 = and i32 %2, 63
  %20 = sub nuw nsw i32 64, %19
  %21 = select i1 %18, i32 %19, i32 %20
  %22 = zext nneg i32 %21 to i64
  %23 = getelementptr inbounds nuw [24 x i8], ptr @_ZN11__llvm_libc4math31range_reduction_double_internal22SIN_K_PI_OVER_128_F128E, i64 %22
  %24 = getelementptr inbounds nuw i8, ptr %23, i64 4
  %25 = load i32, ptr %24, align 4, !tbaa !20
  %26 = getelementptr inbounds nuw i8, ptr %23, i64 8
  %27 = load i64, ptr %26, align 8
  %28 = getelementptr inbounds nuw i8, ptr %23, i64 16
  %29 = load i64, ptr %28, align 8, !tbaa !21
  %30 = and i32 %2, 128
  %31 = icmp ne i32 %30, 0
  %32 = add i32 %2, 64
  %33 = select i1 %18, i32 %20, i32 %19
  %34 = zext nneg i32 %33 to i64
  %35 = getelementptr inbounds nuw [24 x i8], ptr @_ZN11__llvm_libc4math31range_reduction_double_internal22SIN_K_PI_OVER_128_F128E, i64 %34
  %36 = getelementptr inbounds nuw i8, ptr %35, i64 4
  %37 = load i32, ptr %36, align 4, !tbaa !20
  %38 = getelementptr inbounds nuw i8, ptr %35, i64 8
  %39 = load i64, ptr %38, align 8
  %40 = getelementptr inbounds nuw i8, ptr %35, i64 16
  %41 = load i64, ptr %40, align 8, !tbaa !21
  %42 = and i32 %32, 128
  %43 = icmp ne i32 %42, 0
  call void @llvm.lifetime.start.p0(ptr nonnull %9) #9
  %44 = load i8, ptr %7, align 8, !tbaa !17, !noalias !22
  %45 = trunc i8 %44 to i1
  %46 = xor i1 %31, %45
  %47 = zext i1 %46 to i8
  %48 = load i32, ptr %12, align 4, !tbaa !25, !noalias !22
  %49 = add i32 %48, %25
  %50 = add i32 %49, 128
  %51 = icmp eq i32 %21, 0
  br i1 %51, label %105, label %52

52:                                               ; preds = %16
  %53 = getelementptr inbounds nuw i8, ptr %7, i64 8
  %54 = load i64, ptr %53, align 8, !tbaa !30, !noalias !22
  %55 = icmp eq i64 %54, 0
  %56 = getelementptr inbounds nuw i8, ptr %7, i64 16
  %57 = load i64, ptr %56, align 8, !noalias !22
  %58 = icmp eq i64 %57, 0
  %59 = select i1 %55, i1 %58, i1 false
  br i1 %59, label %105, label %60

60:                                               ; preds = %52
  %61 = zext i64 %27 to i128
  %62 = zext i64 %57 to i128
  %63 = mul nuw i128 %62, %61
  %64 = trunc i128 %63 to i64
  %65 = lshr i128 %63, 64
  %66 = trunc nuw i128 %65 to i64
  %67 = zext i64 %29 to i128
  %68 = zext i64 %54 to i128
  %69 = mul nuw i128 %68, %67
  %70 = trunc i128 %69 to i64
  %71 = lshr i128 %69, 64
  %72 = trunc nuw i128 %71 to i64
  %73 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %64, i64 %70)
  %74 = extractvalue { i64, i1 } %73, 1
  %75 = zext i1 %74 to i64
  %76 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %66, i64 %72)
  %77 = extractvalue { i64, i1 } %76, 1
  %78 = extractvalue { i64, i1 } %76, 0
  %79 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %78, i64 %75)
  %80 = extractvalue { i64, i1 } %79, 1
  %81 = extractvalue { i64, i1 } %79, 0
  %82 = or i1 %77, %80
  %83 = zext i1 %82 to i64
  %84 = mul nuw i128 %62, %67
  %85 = trunc i128 %84 to i64
  %86 = lshr i128 %84, 64
  %87 = trunc nuw i128 %86 to i64
  %88 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %81, i64 %85)
  %89 = extractvalue { i64, i1 } %88, 1
  %90 = extractvalue { i64, i1 } %88, 0
  %91 = zext i1 %89 to i64
  %92 = add nuw i64 %83, %87
  %93 = add i64 %92, %91
  %94 = icmp sgt i64 %93, -1
  br i1 %94, label %95, label %105

95:                                               ; preds = %60
  %96 = add i32 %49, 127
  %97 = zext nneg i64 %93 to i128
  %98 = zext i64 %90 to i128
  %99 = shl nuw i128 %97, 65
  %100 = shl nuw nsw i128 %98, 1
  %101 = or disjoint i128 %99, %100
  %102 = trunc i128 %100 to i64
  %103 = lshr i128 %101, 64
  %104 = trunc nuw i128 %103 to i64
  br label %105

105:                                              ; preds = %16, %52, %60, %95
  %106 = phi i64 [ %90, %60 ], [ %102, %95 ], [ 0, %52 ], [ 0, %16 ]
  %107 = phi i64 [ %93, %60 ], [ %104, %95 ], [ 0, %52 ], [ 0, %16 ]
  %108 = phi i32 [ %50, %60 ], [ %96, %95 ], [ %50, %52 ], [ %50, %16 ]
  %109 = load i8, ptr %6, align 8, !tbaa !17, !noalias !32
  %110 = trunc i8 %109 to i1
  %111 = xor i1 %43, %110
  %112 = zext i1 %111 to i8
  %113 = load i32, ptr %11, align 4, !tbaa !25, !noalias !32
  %114 = add i32 %113, %37
  %115 = add i32 %114, 128
  %116 = icmp eq i32 %33, 0
  br i1 %116, label %170, label %117

117:                                              ; preds = %105
  %118 = getelementptr inbounds nuw i8, ptr %6, i64 8
  %119 = load i64, ptr %118, align 8, !tbaa !30, !noalias !32
  %120 = icmp eq i64 %119, 0
  %121 = getelementptr inbounds nuw i8, ptr %6, i64 16
  %122 = load i64, ptr %121, align 8, !noalias !32
  %123 = icmp eq i64 %122, 0
  %124 = select i1 %120, i1 %123, i1 false
  br i1 %124, label %170, label %125

125:                                              ; preds = %117
  %126 = zext i64 %39 to i128
  %127 = zext i64 %122 to i128
  %128 = mul nuw i128 %127, %126
  %129 = trunc i128 %128 to i64
  %130 = lshr i128 %128, 64
  %131 = trunc nuw i128 %130 to i64
  %132 = zext i64 %41 to i128
  %133 = zext i64 %119 to i128
  %134 = mul nuw i128 %133, %132
  %135 = trunc i128 %134 to i64
  %136 = lshr i128 %134, 64
  %137 = trunc nuw i128 %136 to i64
  %138 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %129, i64 %135)
  %139 = extractvalue { i64, i1 } %138, 1
  %140 = zext i1 %139 to i64
  %141 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %131, i64 %137)
  %142 = extractvalue { i64, i1 } %141, 1
  %143 = extractvalue { i64, i1 } %141, 0
  %144 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %143, i64 %140)
  %145 = extractvalue { i64, i1 } %144, 1
  %146 = extractvalue { i64, i1 } %144, 0
  %147 = or i1 %142, %145
  %148 = zext i1 %147 to i64
  %149 = mul nuw i128 %127, %132
  %150 = trunc i128 %149 to i64
  %151 = lshr i128 %149, 64
  %152 = trunc nuw i128 %151 to i64
  %153 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %146, i64 %150)
  %154 = extractvalue { i64, i1 } %153, 1
  %155 = extractvalue { i64, i1 } %153, 0
  %156 = zext i1 %154 to i64
  %157 = add nuw i64 %148, %152
  %158 = add i64 %157, %156
  %159 = icmp sgt i64 %158, -1
  br i1 %159, label %160, label %170

160:                                              ; preds = %125
  %161 = add i32 %114, 127
  %162 = zext nneg i64 %158 to i128
  %163 = zext i64 %155 to i128
  %164 = shl nuw i128 %162, 65
  %165 = shl nuw nsw i128 %163, 1
  %166 = or disjoint i128 %164, %165
  %167 = trunc i128 %165 to i64
  %168 = lshr i128 %166, 64
  %169 = trunc nuw i128 %168 to i64
  br label %170

170:                                              ; preds = %105, %117, %125, %160
  %171 = phi i64 [ %155, %125 ], [ %167, %160 ], [ 0, %117 ], [ 0, %105 ]
  %172 = phi i64 [ %158, %125 ], [ %169, %160 ], [ 0, %117 ], [ 0, %105 ]
  %173 = phi i32 [ %115, %125 ], [ %161, %160 ], [ %115, %117 ], [ %115, %105 ]
  %174 = icmp eq i64 %106, 0
  %175 = icmp eq i64 %107, 0
  %176 = select i1 %174, i1 %175, i1 false
  br i1 %176, label %287, label %177, !prof !11

177:                                              ; preds = %170
  %178 = icmp eq i64 %171, 0
  %179 = icmp eq i64 %172, 0
  %180 = select i1 %178, i1 %179, i1 false
  br i1 %180, label %287, label %181, !prof !11

181:                                              ; preds = %177
  %182 = icmp sgt i32 %108, %173
  br i1 %182, label %183, label %196

183:                                              ; preds = %181
  %184 = sub i32 %108, %173
  %185 = icmp ult i32 %184, 128
  br i1 %185, label %186, label %211

186:                                              ; preds = %183
  %187 = zext i64 %172 to i128
  %188 = shl nuw i128 %187, 64
  %189 = zext i64 %171 to i128
  %190 = or disjoint i128 %188, %189
  %191 = zext nneg i32 %184 to i128
  %192 = lshr i128 %190, %191
  %193 = trunc i128 %192 to i64
  %194 = lshr i128 %192, 64
  %195 = trunc nuw i128 %194 to i64
  br label %211

196:                                              ; preds = %181
  %197 = icmp sgt i32 %173, %108
  br i1 %197, label %198, label %211

198:                                              ; preds = %196
  %199 = sub i32 %173, %108
  %200 = icmp ult i32 %199, 128
  br i1 %200, label %201, label %211

201:                                              ; preds = %198
  %202 = zext i64 %107 to i128
  %203 = shl nuw i128 %202, 64
  %204 = zext i64 %106 to i128
  %205 = or disjoint i128 %203, %204
  %206 = zext nneg i32 %199 to i128
  %207 = lshr i128 %205, %206
  %208 = trunc i128 %207 to i64
  %209 = lshr i128 %207, 64
  %210 = trunc nuw i128 %209 to i64
  br label %211

211:                                              ; preds = %201, %198, %196, %186, %183
  %212 = phi i32 [ %108, %183 ], [ %173, %201 ], [ %108, %196 ], [ %108, %186 ], [ %173, %198 ]
  %213 = phi i32 [ %108, %183 ], [ %173, %201 ], [ %173, %196 ], [ %108, %186 ], [ %173, %198 ]
  %214 = phi i64 [ 0, %183 ], [ %171, %201 ], [ %171, %196 ], [ %193, %186 ], [ %171, %198 ]
  %215 = phi i64 [ %106, %183 ], [ %208, %201 ], [ %106, %196 ], [ %106, %186 ], [ 0, %198 ]
  %216 = phi i64 [ 0, %183 ], [ %172, %201 ], [ %172, %196 ], [ %195, %186 ], [ %172, %198 ]
  %217 = phi i64 [ %107, %183 ], [ %210, %201 ], [ %107, %196 ], [ %107, %186 ], [ 0, %198 ]
  %218 = xor i1 %111, %46
  br i1 %218, label %241, label %219

219:                                              ; preds = %211
  %220 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %215, i64 %214)
  %221 = extractvalue { i64, i1 } %220, 1
  %222 = extractvalue { i64, i1 } %220, 0
  %223 = zext i1 %221 to i64
  %224 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %217, i64 %216)
  %225 = extractvalue { i64, i1 } %224, 1
  %226 = extractvalue { i64, i1 } %224, 0
  %227 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %226, i64 %223)
  %228 = extractvalue { i64, i1 } %227, 1
  %229 = extractvalue { i64, i1 } %227, 0
  %230 = or i1 %225, %228
  br i1 %230, label %231, label %287

231:                                              ; preds = %219
  %232 = add i32 %212, 1
  %233 = zext i64 %229 to i128
  %234 = shl nuw i128 %233, 64
  %235 = zext i64 %222 to i128
  %236 = or disjoint i128 %234, %235
  %237 = lshr i128 %236, 1
  %238 = trunc i128 %237 to i64
  %239 = lshr i64 %229, 1
  %240 = or disjoint i64 %239, -9223372036854775808
  br label %287

241:                                              ; preds = %211
  %242 = icmp eq i64 %217, %216
  br i1 %242, label %243, label %245

243:                                              ; preds = %241
  %244 = icmp eq i64 %215, %214
  br i1 %244, label %249, label %245

245:                                              ; preds = %243, %241
  %246 = phi i64 [ %217, %241 ], [ %215, %243 ]
  %247 = phi i64 [ %216, %241 ], [ %214, %243 ]
  %248 = icmp ult i64 %246, %247
  br i1 %248, label %255, label %249

249:                                              ; preds = %245, %243
  %250 = call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %215, i64 %214)
  %251 = extractvalue { i64, i1 } %250, 1
  %252 = sext i1 %251 to i64
  %253 = sub i64 %217, %216
  %254 = add i64 %253, %252
  br label %261

255:                                              ; preds = %245
  %256 = call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %214, i64 %215)
  %257 = extractvalue { i64, i1 } %256, 1
  %258 = sext i1 %257 to i64
  %259 = sub i64 %216, %217
  %260 = add i64 %259, %258
  br label %261

261:                                              ; preds = %255, %249
  %262 = phi i32 [ %212, %249 ], [ %213, %255 ]
  %263 = phi { i64, i1 } [ %250, %249 ], [ %256, %255 ]
  %264 = phi i64 [ %254, %249 ], [ %260, %255 ]
  %265 = phi i8 [ %47, %249 ], [ %112, %255 ]
  %266 = extractvalue { i64, i1 } %263, 0
  %267 = icmp eq i64 %266, 0
  %268 = icmp eq i64 %264, 0
  %269 = select i1 %267, i1 %268, i1 false
  br i1 %269, label %287, label %270

270:                                              ; preds = %261
  %271 = call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %264, i1 false)
  %272 = trunc nuw nsw i64 %271 to i32
  %273 = call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %266, i1 false)
  %274 = trunc nuw nsw i64 %273 to i32
  %275 = select i1 %268, i32 %274, i32 0
  %276 = add nuw nsw i32 %275, %272
  %277 = sub i32 %262, %276
  %278 = zext i64 %264 to i128
  %279 = shl nuw i128 %278, 64
  %280 = zext i64 %266 to i128
  %281 = or disjoint i128 %279, %280
  %282 = zext nneg i32 %276 to i128
  %283 = shl i128 %281, %282
  %284 = trunc i128 %283 to i64
  %285 = lshr i128 %283, 64
  %286 = trunc nuw i128 %285 to i64
  br label %287

287:                                              ; preds = %261, %270, %219, %231, %177, %170
  %288 = phi i8 [ %47, %219 ], [ %112, %170 ], [ %47, %177 ], [ %47, %231 ], [ %265, %270 ], [ %265, %261 ]
  %289 = phi i32 [ %212, %219 ], [ %173, %170 ], [ %108, %177 ], [ %232, %231 ], [ %277, %270 ], [ %262, %261 ]
  %290 = phi i64 [ %222, %219 ], [ %171, %170 ], [ %106, %177 ], [ %238, %231 ], [ %284, %270 ], [ 0, %261 ]
  %291 = phi i64 [ %229, %219 ], [ %172, %170 ], [ %107, %177 ], [ %240, %231 ], [ %286, %270 ], [ 0, %261 ]
  store i8 %288, ptr %9, align 8, !tbaa !17
  %292 = getelementptr inbounds nuw i8, ptr %9, i64 4
  store i32 %289, ptr %292, align 4, !tbaa !20
  %293 = getelementptr inbounds nuw i8, ptr %9, i64 8
  store i64 %290, ptr %293, align 8
  %294 = getelementptr inbounds nuw i8, ptr %9, i64 16
  store i64 %291, ptr %294, align 8, !tbaa !21
  %295 = call noundef double @_ZNK11__llvm_libc6fputil11DyadicFloatILm128EE7fast_asIdLb1EvEET_v(ptr noundef nonnull align 8 dereferenceable(24) %9)
  call void @llvm.lifetime.end.p0(ptr nonnull %9) #9
  call void @llvm.lifetime.end.p0(ptr nonnull %7) #9
  call void @llvm.lifetime.end.p0(ptr nonnull %6) #9
  call void @llvm.lifetime.end.p0(ptr nonnull %5) #9
  ret double %295
}

; Function Attrs: inlinehint mustprogress noinline sspstrong uwtable
define linkonce_odr hidden noundef i32 @_ZN11__llvm_libc6fputil24raise_except_if_requiredEi(i32 noundef %0) local_unnamed_addr #4 comdat {
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = and i32 %0, 63
  call void @llvm.lifetime.start.p0(ptr nonnull %3)
  call void @llvm.x86.sse.stmxcsr(ptr nonnull %3)
  %5 = load i32, ptr %3, align 4
  call void @llvm.lifetime.end.p0(ptr nonnull %3)
  %6 = or i32 %5, %4
  call void @llvm.lifetime.start.p0(ptr nonnull %2)
  store i32 %6, ptr %2, align 4
  call void @llvm.x86.sse.ldmxcsr(ptr nonnull %2)
  call void @llvm.lifetime.end.p0(ptr nonnull %2)
  ret i32 0
}

; Function Attrs: inlinehint mustprogress noinline sspstrong uwtable
define linkonce_odr hidden void @_ZN11__llvm_libc6fputil21set_errno_if_requiredEi(i32 noundef %0) local_unnamed_addr #4 comdat {
  tail call void @_ZN11__llvm_libc5ErrnoaSEi(ptr noundef nonnull align 1 dereferenceable(1) @_ZN11__llvm_libc10libc_errnoE, i32 noundef %0)
  ret void
}

; Function Attrs: inlinehint mustprogress sspstrong uwtable
define linkonce_odr hidden noundef i32 @_ZN11__llvm_libc4math31range_reduction_double_internal19LargeRangeReduction4fastEdRNS_10NumberPairIdEE(ptr noundef nonnull align 8 dereferenceable(48) %0, double noundef %1, ptr noundef nonnull align 8 dereferenceable(16) %2) local_unnamed_addr #1 comdat align 2 {
  %4 = bitcast double %1 to i64
  %5 = lshr i64 %4, 52
  %6 = trunc nuw nsw i64 %5 to i32
  %7 = and i32 %6, 2047
  %8 = add nsw i32 %7, -1085
  %9 = ashr i32 %8, 4
  %10 = add nsw i32 %9, 3
  store i32 %10, ptr %0, align 8, !tbaa !35
  %11 = and i32 %8, 15
  %12 = add nuw nsw i32 %11, 1085
  %13 = zext nneg i32 %12 to i64
  %14 = shl nuw nsw i64 %13, 52
  %15 = and i64 %4, -9218868437227405313
  %16 = or disjoint i64 %14, %15
  %17 = bitcast i64 %16 to double
  %18 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %16, ptr %18, align 8, !tbaa !37
  %19 = fmul double %17, f0x41A0000002000000
  %20 = fsub double %17, %19
  %21 = fadd double %19, %20
  %22 = fsub double %17, %21
  %23 = zext i32 %10 to i64
  %24 = getelementptr inbounds nuw [32 x i8], ptr @_ZN11__llvm_libc4math31range_reduction_double_internal24ONE_TWENTY_EIGHT_OVER_PIE, i64 %23
  %25 = load double, ptr %24, align 16, !tbaa !16
  %26 = fmul double %25, f0x41B0000001000000
  %27 = fsub double %25, %26
  %28 = fadd double %26, %27
  %29 = fsub double %25, %28
  %30 = fneg double %17
  %31 = fmul double %25, %30
  %32 = tail call double @llvm.fmuladd.f64(double %21, double %28, double %31)
  %33 = tail call double @llvm.fmuladd.f64(double %21, double %29, double %32)
  %34 = tail call double @llvm.fmuladd.f64(double %22, double %28, double %33)
  %35 = tail call double @llvm.fmuladd.f64(double %22, double %29, double %34)
  %36 = getelementptr inbounds nuw i8, ptr %24, i64 8
  %37 = load double, ptr %36, align 8, !tbaa !16
  %38 = fmul double %37, %17
  %39 = getelementptr inbounds nuw i8, ptr %24, i64 16
  %40 = load double, ptr %39, align 16, !tbaa !16
  %41 = fadd double %38, %35
  %42 = tail call double @llvm.fabs.f64(double %41)
  %43 = fcmp olt double %42, f0x4340000000000000
  br i1 %43, label %44, label %59

44:                                               ; preds = %3
  %45 = fcmp olt double %41, 0.000000e+00
  %46 = fadd double %41, f0xC330000000000000
  %47 = fadd double %46, f0x4330000000000000
  %48 = fadd double %41, f0x4330000000000000
  %49 = fadd double %48, f0xC330000000000000
  %50 = select i1 %45, double %47, double %49
  %51 = fsub double %41, %50
  %52 = fcmp ogt double %51, 5.000000e-01
  br i1 %52, label %53, label %55, !prof !11

53:                                               ; preds = %44
  %54 = fadd double %50, 1.000000e+00
  br label %59

55:                                               ; preds = %44
  %56 = fcmp olt double %51, -5.000000e-01
  br i1 %56, label %57, label %59, !prof !11

57:                                               ; preds = %55
  %58 = fadd double %50, -1.000000e+00
  br label %59

59:                                               ; preds = %3, %53, %55, %57
  %60 = phi double [ %50, %55 ], [ %54, %53 ], [ %58, %57 ], [ %41, %3 ]
  %61 = fmul double %40, f0x41B0000001000000
  %62 = fsub double %40, %61
  %63 = fadd double %61, %62
  %64 = fsub double %40, %63
  %65 = fmul double %40, %17
  %66 = fneg double %65
  %67 = tail call double @llvm.fmuladd.f64(double %21, double %63, double %66)
  %68 = tail call double @llvm.fmuladd.f64(double %21, double %64, double %67)
  %69 = tail call double @llvm.fmuladd.f64(double %22, double %63, double %68)
  %70 = tail call double @llvm.fmuladd.f64(double %22, double %64, double %69)
  %71 = fmul double %37, f0x41B0000001000000
  %72 = fsub double %37, %71
  %73 = fadd double %71, %72
  %74 = fsub double %37, %73
  %75 = fneg double %38
  %76 = tail call double @llvm.fmuladd.f64(double %21, double %73, double %75)
  %77 = tail call double @llvm.fmuladd.f64(double %21, double %74, double %76)
  %78 = tail call double @llvm.fmuladd.f64(double %22, double %73, double %77)
  %79 = tail call double @llvm.fmuladd.f64(double %22, double %74, double %78)
  %80 = fsub double %35, %60
  %81 = fadd double %38, %80
  %82 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store double %81, ptr %82, align 8, !tbaa !38
  %83 = fadd double %65, %79
  %84 = fsub double %83, %79
  %85 = fsub double %65, %84
  %86 = getelementptr inbounds nuw i8, ptr %0, i64 32
  store double %85, ptr %86, align 8, !tbaa !16
  %87 = getelementptr inbounds nuw i8, ptr %0, i64 40
  store double %83, ptr %87, align 8, !tbaa !16
  %88 = getelementptr inbounds nuw i8, ptr %0, i64 24
  store double %70, ptr %88, align 8, !tbaa !39
  %89 = getelementptr inbounds nuw i8, ptr %24, i64 24
  %90 = load double, ptr %89, align 8, !tbaa !16
  %91 = fmul double %90, %17
  %92 = fadd double %70, %91
  %93 = fadd double %83, %81
  %94 = fsub double %93, %81
  %95 = fsub double %83, %94
  %96 = fadd double %85, %92
  %97 = fadd double %95, %96
  %98 = fmul double %93, f0x41A0000002000000
  %99 = fsub double %93, %98
  %100 = fadd double %98, %99
  %101 = fsub double %93, %100
  %102 = fmul double %93, f0x3F9921FB54442D18
  %103 = fneg double %102
  %104 = tail call double @llvm.fmuladd.f64(double %100, double f0x3F9921FB50000000, double %103)
  %105 = tail call double @llvm.fmuladd.f64(double %100, double f0x3DF110B460000000, double %104)
  %106 = tail call double @llvm.fmuladd.f64(double %101, double f0x3F9921FB50000000, double %105)
  %107 = tail call double @llvm.fmuladd.f64(double %101, double f0x3DF110B460000000, double %106)
  %108 = fmul double %93, f0x3C31A62633145C07
  %109 = fadd double %108, %107
  %110 = fmul double %97, f0x3F9921FB54442D18
  %111 = fadd double %110, %109
  store double %111, ptr %2, align 8, !tbaa !16
  %112 = getelementptr inbounds nuw i8, ptr %2, i64 8
  store double %102, ptr %112, align 8, !tbaa !16
  %113 = fptosi double %60 to i64
  %114 = trunc i64 %113 to i32
  ret i32 %114
}

; Function Attrs: inlinehint mustprogress noinline nounwind sspstrong uwtable
define linkonce_odr hidden noundef i32 @_ZN11__llvm_libc6fputil7generic15quick_get_roundEv() local_unnamed_addr #5 comdat {
  %1 = load volatile float, ptr @_ZZN11__llvm_libc6fputil7generic15quick_get_roundEvE1x, align 4, !tbaa !40
  %2 = fadd float %1, f0x3F800001
  %3 = fsub float -1.000000e+00, %1
  %4 = fadd float %2, %3
  %5 = fcmp oeq float %4, 0.000000e+00
  br i1 %5, label %12, label %6

6:                                                ; preds = %0
  %7 = fcmp oeq float %4, f0x34000000
  br i1 %7, label %12, label %8

8:                                                ; preds = %6
  %9 = fadd float %1, 2.000000e+00
  %10 = fcmp oeq float %9, 2.000000e+00
  %11 = select i1 %10, i32 0, i32 2048
  br label %12

12:                                               ; preds = %6, %0, %8
  %13 = phi i32 [ %11, %8 ], [ 1024, %0 ], [ 3072, %6 ]
  ret i32 %13
}

; Function Attrs: inlinehint mustprogress sspstrong uwtable
define linkonce_odr hidden void @_ZN11__llvm_libc4math31range_reduction_double_internal26range_reduction_small_f128Ed(ptr dead_on_unwind noalias writable sret(%"struct.__llvm_libc::fputil::DyadicFloat") align 8 %0, double noundef %1) local_unnamed_addr #1 comdat {
  %3 = fmul double %1, f0x40445F306DC9C883
  %4 = tail call double @llvm.fabs.f64(double %3)
  %5 = fcmp olt double %4, f0x4340000000000000
  br i1 %5, label %6, label %21

6:                                                ; preds = %2
  %7 = fcmp olt double %3, 0.000000e+00
  %8 = fadd double %3, f0xC330000000000000
  %9 = fadd double %8, f0x4330000000000000
  %10 = fadd double %3, f0x4330000000000000
  %11 = fadd double %10, f0xC330000000000000
  %12 = select i1 %7, double %9, double %11
  %13 = fsub double %3, %12
  %14 = fcmp ogt double %13, 5.000000e-01
  br i1 %14, label %15, label %17, !prof !11

15:                                               ; preds = %6
  %16 = fadd double %12, 1.000000e+00
  br label %21

17:                                               ; preds = %6
  %18 = fcmp olt double %13, -5.000000e-01
  br i1 %18, label %19, label %21, !prof !11

19:                                               ; preds = %17
  %20 = fadd double %12, -1.000000e+00
  br label %21

21:                                               ; preds = %2, %15, %17, %19
  %22 = phi double [ %12, %17 ], [ %16, %15 ], [ %20, %19 ], [ %3, %2 ]
  %23 = fneg double %22
  %24 = bitcast double %23 to i64
  %25 = lshr i64 %24, 63
  %26 = trunc nuw nsw i64 %25 to i8
  %27 = lshr i64 %24, 52
  %28 = trunc nuw nsw i64 %27 to i32
  %29 = and i32 %28, 2047
  %30 = fcmp oeq double %22, 0.000000e+00
  %31 = icmp eq i32 %29, 0
  %32 = add nsw i32 %29, -1075
  %33 = select i1 %31, i32 -1074, i32 %32
  %34 = select i1 %30, i32 -52, i32 %33
  %35 = and i64 %24, 9218868437227405312
  %36 = icmp eq i64 %35, 0
  %37 = and i64 %24, 4503599627370495
  %38 = or disjoint i64 %37, 4503599627370496
  %39 = select i1 %36, i64 %37, i64 %38
  %40 = icmp eq i64 %39, 0
  br i1 %40, label %51, label %41

41:                                               ; preds = %21
  %42 = tail call range(i64 11, 65) i64 @llvm.ctlz.i64(i64 %39, i1 true)
  %43 = trunc nuw nsw i64 %42 to i32
  %44 = or disjoint i32 %43, 64
  %45 = sub nsw i32 %34, %44
  %46 = zext nneg i64 %39 to i128
  %47 = zext nneg i32 %44 to i128
  %48 = shl i128 %46, %47
  %49 = lshr exact i128 %48, 64
  %50 = trunc nuw i128 %49 to i64
  br label %51

51:                                               ; preds = %21, %41
  %52 = phi i32 [ %34, %21 ], [ %45, %41 ]
  %53 = phi i64 [ 0, %21 ], [ %50, %41 ]
  %54 = bitcast double %1 to i64
  %55 = lshr i64 %54, 63
  %56 = trunc nuw nsw i64 %55 to i8
  %57 = lshr i64 %54, 52
  %58 = trunc nuw nsw i64 %57 to i32
  %59 = and i32 %58, 2047
  %60 = fcmp oeq double %1, 0.000000e+00
  %61 = icmp eq i32 %59, 0
  %62 = add nsw i32 %59, -1075
  %63 = select i1 %61, i32 -1074, i32 %62
  %64 = select i1 %60, i32 -52, i32 %63
  %65 = and i64 %54, 9218868437227405312
  %66 = icmp eq i64 %65, 0
  %67 = and i64 %54, 4503599627370495
  %68 = or disjoint i64 %67, 4503599627370496
  %69 = select i1 %66, i64 %67, i64 %68
  %70 = icmp eq i64 %69, 0
  br i1 %70, label %71, label %73

71:                                               ; preds = %51
  %72 = add nsw i32 %64, 6
  br label %137

73:                                               ; preds = %51
  %74 = tail call range(i64 11, 65) i64 @llvm.ctlz.i64(i64 %69, i1 true)
  %75 = trunc nuw nsw i64 %74 to i32
  %76 = or disjoint i32 %75, 64
  %77 = sub nsw i32 %64, %76
  %78 = zext nneg i64 %69 to i128
  %79 = zext nneg i32 %76 to i128
  %80 = shl i128 %78, %79
  %81 = lshr exact i128 %80, 64
  %82 = add nsw i32 %77, 6
  %83 = icmp eq i128 %80, 0
  br i1 %83, label %137, label %84

84:                                               ; preds = %73
  %85 = mul nuw i128 %81, 11743562013128007680
  %86 = trunc i128 %85 to i64
  %87 = lshr i128 %85, 64
  %88 = trunc nuw i128 %87 to i64
  %89 = icmp sgt i128 %85, -1
  br i1 %89, label %90, label %99

90:                                               ; preds = %84
  %91 = add nsw i32 %77, 5
  %92 = shl nuw i128 %87, 65
  %93 = mul i128 %81, 23487124026256015360
  %94 = and i128 %93, 18446744073709551616
  %95 = or disjoint i128 %92, %94
  %96 = trunc i128 %93 to i64
  %97 = lshr exact i128 %95, 64
  %98 = trunc nuw i128 %97 to i64
  br label %99

99:                                               ; preds = %84, %90
  %100 = phi i32 [ %82, %84 ], [ %91, %90 ]
  %101 = phi i64 [ %88, %84 ], [ %98, %90 ]
  %102 = phi i64 [ %86, %84 ], [ %96, %90 ]
  %103 = add nsw i32 %77, -46
  %104 = mul nuw i128 %81, 12493053031436296192
  %105 = trunc i128 %104 to i64
  %106 = lshr i128 %104, 64
  %107 = trunc nuw i128 %106 to i64
  %108 = icmp sgt i128 %104, -1
  br i1 %108, label %109, label %118

109:                                              ; preds = %99
  %110 = add nsw i32 %77, -47
  %111 = shl nuw i128 %106, 65
  %112 = mul i128 %81, 24986106062872592384
  %113 = and i128 %112, 18446744073709551616
  %114 = or disjoint i128 %111, %113
  %115 = trunc i128 %112 to i64
  %116 = lshr exact i128 %114, 64
  %117 = trunc nuw i128 %116 to i64
  br label %118

118:                                              ; preds = %99, %109
  %119 = phi i32 [ %103, %99 ], [ %110, %109 ]
  %120 = phi i64 [ %107, %99 ], [ %117, %109 ]
  %121 = phi i64 [ %105, %99 ], [ %115, %109 ]
  %122 = add nsw i32 %77, -98
  %123 = mul nuw i128 %81, 14637331165399900160
  %124 = trunc i128 %123 to i64
  %125 = lshr i128 %123, 64
  %126 = trunc nuw i128 %125 to i64
  %127 = icmp sgt i128 %123, -1
  br i1 %127, label %128, label %142

128:                                              ; preds = %118
  %129 = add nsw i32 %77, -99
  %130 = shl nuw i128 %125, 65
  %131 = mul i128 %81, 29274662330799800320
  %132 = and i128 %131, 18446744073709551616
  %133 = or disjoint i128 %130, %132
  %134 = trunc i128 %131 to i64
  %135 = lshr exact i128 %133, 64
  %136 = trunc nuw i128 %135 to i64
  br label %142

137:                                              ; preds = %71, %73
  %138 = phi i32 [ %77, %73 ], [ %64, %71 ]
  %139 = phi i32 [ %82, %73 ], [ %72, %71 ]
  %140 = add nsw i32 %138, -46
  %141 = add nsw i32 %138, -98
  br label %142

142:                                              ; preds = %118, %128, %137
  %143 = phi i64 [ 0, %137 ], [ %121, %128 ], [ %121, %118 ]
  %144 = phi i64 [ 0, %137 ], [ %120, %128 ], [ %120, %118 ]
  %145 = phi i32 [ %140, %137 ], [ %119, %128 ], [ %119, %118 ]
  %146 = phi i32 [ %139, %137 ], [ %100, %128 ], [ %100, %118 ]
  %147 = phi i64 [ 0, %137 ], [ %101, %128 ], [ %101, %118 ]
  %148 = phi i64 [ 0, %137 ], [ %102, %128 ], [ %102, %118 ]
  %149 = phi i32 [ %141, %137 ], [ %129, %128 ], [ %122, %118 ]
  %150 = phi i64 [ 0, %137 ], [ %136, %128 ], [ %126, %118 ]
  %151 = phi i64 [ 0, %137 ], [ %134, %128 ], [ %124, %118 ]
  %152 = xor i8 %56, 1
  %153 = icmp eq i64 %148, 0
  %154 = icmp eq i64 %147, 0
  %155 = select i1 %153, i1 %154, i1 false
  br i1 %155, label %262, label %156, !prof !11

156:                                              ; preds = %142
  %157 = icmp eq i64 %53, 0
  br i1 %157, label %262, label %158, !prof !11

158:                                              ; preds = %156
  %159 = icmp sgt i32 %146, %52
  br i1 %159, label %160, label %171

160:                                              ; preds = %158
  %161 = sub nsw i32 %146, %52
  %162 = icmp ult i32 %161, 128
  br i1 %162, label %163, label %186

163:                                              ; preds = %160
  %164 = zext i64 %53 to i128
  %165 = shl nuw i128 %164, 64
  %166 = zext nneg i32 %161 to i128
  %167 = lshr i128 %165, %166
  %168 = trunc i128 %167 to i64
  %169 = lshr i128 %167, 64
  %170 = trunc nuw i128 %169 to i64
  br label %186

171:                                              ; preds = %158
  %172 = icmp sgt i32 %52, %146
  br i1 %172, label %173, label %186

173:                                              ; preds = %171
  %174 = sub nsw i32 %52, %146
  %175 = icmp ult i32 %174, 128
  br i1 %175, label %176, label %186

176:                                              ; preds = %173
  %177 = zext i64 %147 to i128
  %178 = shl nuw i128 %177, 64
  %179 = zext i64 %148 to i128
  %180 = or disjoint i128 %178, %179
  %181 = zext nneg i32 %174 to i128
  %182 = lshr i128 %180, %181
  %183 = trunc i128 %182 to i64
  %184 = lshr i128 %182, 64
  %185 = trunc nuw i128 %184 to i64
  br label %186

186:                                              ; preds = %176, %173, %171, %163, %160
  %187 = phi i32 [ %146, %160 ], [ %52, %176 ], [ %146, %171 ], [ %146, %163 ], [ %52, %173 ]
  %188 = phi i32 [ %146, %160 ], [ %52, %176 ], [ %52, %171 ], [ %146, %163 ], [ %52, %173 ]
  %189 = phi i64 [ 0, %160 ], [ 0, %176 ], [ 0, %171 ], [ %168, %163 ], [ 0, %173 ]
  %190 = phi i64 [ %148, %160 ], [ %183, %176 ], [ %148, %171 ], [ %148, %163 ], [ 0, %173 ]
  %191 = phi i64 [ 0, %160 ], [ %53, %176 ], [ %53, %171 ], [ %170, %163 ], [ %53, %173 ]
  %192 = phi i64 [ %147, %160 ], [ %185, %176 ], [ %147, %171 ], [ %147, %163 ], [ 0, %173 ]
  %193 = icmp eq i64 %25, %55
  br i1 %193, label %194, label %216

194:                                              ; preds = %186
  %195 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %190, i64 %189)
  %196 = extractvalue { i64, i1 } %195, 1
  %197 = extractvalue { i64, i1 } %195, 0
  %198 = zext i1 %196 to i64
  %199 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %192, i64 %191)
  %200 = extractvalue { i64, i1 } %199, 1
  %201 = extractvalue { i64, i1 } %199, 0
  %202 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %201, i64 %198)
  %203 = extractvalue { i64, i1 } %202, 1
  %204 = extractvalue { i64, i1 } %202, 0
  %205 = or i1 %200, %203
  br i1 %205, label %206, label %262

206:                                              ; preds = %194
  %207 = add nsw i32 %187, 1
  %208 = zext i64 %204 to i128
  %209 = shl nuw i128 %208, 64
  %210 = zext i64 %197 to i128
  %211 = or disjoint i128 %209, %210
  %212 = lshr i128 %211, 1
  %213 = trunc i128 %212 to i64
  %214 = lshr i64 %204, 1
  %215 = or disjoint i64 %214, -9223372036854775808
  br label %262

216:                                              ; preds = %186
  %217 = icmp eq i64 %192, %191
  br i1 %217, label %218, label %220

218:                                              ; preds = %216
  %219 = icmp eq i64 %190, %189
  br i1 %219, label %224, label %220

220:                                              ; preds = %218, %216
  %221 = phi i64 [ %192, %216 ], [ %190, %218 ]
  %222 = phi i64 [ %191, %216 ], [ %189, %218 ]
  %223 = icmp ult i64 %221, %222
  br i1 %223, label %230, label %224

224:                                              ; preds = %220, %218
  %225 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %190, i64 %189)
  %226 = extractvalue { i64, i1 } %225, 1
  %227 = sext i1 %226 to i64
  %228 = sub i64 %192, %191
  %229 = add i64 %228, %227
  br label %236

230:                                              ; preds = %220
  %231 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %189, i64 %190)
  %232 = extractvalue { i64, i1 } %231, 1
  %233 = sext i1 %232 to i64
  %234 = sub i64 %191, %192
  %235 = add i64 %234, %233
  br label %236

236:                                              ; preds = %230, %224
  %237 = phi i32 [ %187, %224 ], [ %188, %230 ]
  %238 = phi { i64, i1 } [ %225, %224 ], [ %231, %230 ]
  %239 = phi i64 [ %229, %224 ], [ %235, %230 ]
  %240 = phi i8 [ %56, %224 ], [ %26, %230 ]
  %241 = extractvalue { i64, i1 } %238, 0
  %242 = icmp eq i64 %241, 0
  %243 = icmp eq i64 %239, 0
  %244 = select i1 %242, i1 %243, i1 false
  br i1 %244, label %262, label %245

245:                                              ; preds = %236
  %246 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %239, i1 false)
  %247 = trunc nuw nsw i64 %246 to i32
  %248 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %241, i1 false)
  %249 = trunc nuw nsw i64 %248 to i32
  %250 = select i1 %243, i32 %249, i32 0
  %251 = add nuw nsw i32 %250, %247
  %252 = sub nsw i32 %237, %251
  %253 = zext i64 %239 to i128
  %254 = shl nuw i128 %253, 64
  %255 = zext i64 %241 to i128
  %256 = or disjoint i128 %254, %255
  %257 = zext nneg i32 %251 to i128
  %258 = shl i128 %256, %257
  %259 = trunc i128 %258 to i64
  %260 = lshr i128 %258, 64
  %261 = trunc nuw i128 %260 to i64
  br label %262

262:                                              ; preds = %156, %142, %236, %245, %194, %206
  %263 = phi i64 [ %261, %245 ], [ %53, %142 ], [ %215, %206 ], [ %204, %194 ], [ 0, %236 ], [ %147, %156 ]
  %264 = phi i64 [ %259, %245 ], [ 0, %142 ], [ %213, %206 ], [ %197, %194 ], [ 0, %236 ], [ %148, %156 ]
  %265 = phi i32 [ %252, %245 ], [ %52, %142 ], [ %207, %206 ], [ %187, %194 ], [ %237, %236 ], [ %146, %156 ]
  %266 = phi i8 [ %240, %245 ], [ %26, %142 ], [ %56, %206 ], [ %56, %194 ], [ %240, %236 ], [ %56, %156 ]
  %267 = icmp eq i64 %143, 0
  %268 = icmp eq i64 %144, 0
  %269 = select i1 %267, i1 %268, i1 false
  br i1 %269, label %331, label %270, !prof !11

270:                                              ; preds = %262
  %271 = icmp eq i64 %151, 0
  %272 = icmp eq i64 %150, 0
  %273 = select i1 %271, i1 %272, i1 false
  br i1 %273, label %331, label %274, !prof !11

274:                                              ; preds = %270
  %275 = icmp sgt i32 %145, %149
  br i1 %275, label %276, label %289

276:                                              ; preds = %274
  %277 = sub nsw i32 %145, %149
  %278 = icmp ult i32 %277, 128
  br i1 %278, label %279, label %304

279:                                              ; preds = %276
  %280 = zext i64 %150 to i128
  %281 = shl nuw i128 %280, 64
  %282 = zext i64 %151 to i128
  %283 = or disjoint i128 %281, %282
  %284 = zext nneg i32 %277 to i128
  %285 = lshr i128 %283, %284
  %286 = trunc i128 %285 to i64
  %287 = lshr i128 %285, 64
  %288 = trunc nuw i128 %287 to i64
  br label %304

289:                                              ; preds = %274
  %290 = icmp sgt i32 %149, %145
  br i1 %290, label %291, label %304

291:                                              ; preds = %289
  %292 = sub nsw i32 %149, %145
  %293 = icmp ult i32 %292, 128
  br i1 %293, label %294, label %304

294:                                              ; preds = %291
  %295 = zext i64 %144 to i128
  %296 = shl nuw i128 %295, 64
  %297 = zext i64 %143 to i128
  %298 = or disjoint i128 %296, %297
  %299 = zext nneg i32 %292 to i128
  %300 = lshr i128 %298, %299
  %301 = trunc i128 %300 to i64
  %302 = lshr i128 %300, 64
  %303 = trunc nuw i128 %302 to i64
  br label %304

304:                                              ; preds = %276, %279, %289, %291, %294
  %305 = phi i32 [ %145, %276 ], [ %149, %294 ], [ %145, %289 ], [ %145, %279 ], [ %149, %291 ]
  %306 = phi i64 [ 0, %276 ], [ %151, %294 ], [ %151, %289 ], [ %286, %279 ], [ %151, %291 ]
  %307 = phi i64 [ %143, %276 ], [ %301, %294 ], [ %143, %289 ], [ %143, %279 ], [ 0, %291 ]
  %308 = phi i64 [ 0, %276 ], [ %150, %294 ], [ %150, %289 ], [ %288, %279 ], [ %150, %291 ]
  %309 = phi i64 [ %144, %276 ], [ %303, %294 ], [ %144, %289 ], [ %144, %279 ], [ 0, %291 ]
  %310 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %307, i64 %306)
  %311 = extractvalue { i64, i1 } %310, 1
  %312 = extractvalue { i64, i1 } %310, 0
  %313 = zext i1 %311 to i64
  %314 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %309, i64 %308)
  %315 = extractvalue { i64, i1 } %314, 1
  %316 = extractvalue { i64, i1 } %314, 0
  %317 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %316, i64 %313)
  %318 = extractvalue { i64, i1 } %317, 1
  %319 = extractvalue { i64, i1 } %317, 0
  %320 = or i1 %315, %318
  br i1 %320, label %321, label %331

321:                                              ; preds = %304
  %322 = add nsw i32 %305, 1
  %323 = zext i64 %319 to i128
  %324 = shl nuw i128 %323, 64
  %325 = zext i64 %312 to i128
  %326 = or disjoint i128 %324, %325
  %327 = lshr i128 %326, 1
  %328 = trunc i128 %327 to i64
  %329 = lshr i64 %319, 1
  %330 = or disjoint i64 %329, -9223372036854775808
  br label %331

331:                                              ; preds = %270, %262, %304, %321
  %332 = phi i64 [ %319, %304 ], [ %150, %262 ], [ %330, %321 ], [ %144, %270 ]
  %333 = phi i64 [ %312, %304 ], [ %151, %262 ], [ %328, %321 ], [ %143, %270 ]
  %334 = phi i32 [ %305, %304 ], [ %149, %262 ], [ %322, %321 ], [ %145, %270 ]
  %335 = icmp eq i64 %264, 0
  %336 = icmp eq i64 %263, 0
  %337 = select i1 %335, i1 %336, i1 false
  br i1 %337, label %448, label %338, !prof !11

338:                                              ; preds = %331
  %339 = icmp eq i64 %333, 0
  %340 = icmp eq i64 %332, 0
  %341 = select i1 %339, i1 %340, i1 false
  br i1 %341, label %448, label %342, !prof !11

342:                                              ; preds = %338
  %343 = icmp sgt i32 %265, %334
  br i1 %343, label %344, label %357

344:                                              ; preds = %342
  %345 = sub nsw i32 %265, %334
  %346 = icmp ult i32 %345, 128
  br i1 %346, label %347, label %372

347:                                              ; preds = %344
  %348 = zext i64 %332 to i128
  %349 = shl nuw i128 %348, 64
  %350 = zext i64 %333 to i128
  %351 = or disjoint i128 %349, %350
  %352 = zext nneg i32 %345 to i128
  %353 = lshr i128 %351, %352
  %354 = trunc i128 %353 to i64
  %355 = lshr i128 %353, 64
  %356 = trunc nuw i128 %355 to i64
  br label %372

357:                                              ; preds = %342
  %358 = icmp sgt i32 %334, %265
  br i1 %358, label %359, label %372

359:                                              ; preds = %357
  %360 = sub nsw i32 %334, %265
  %361 = icmp ult i32 %360, 128
  br i1 %361, label %362, label %372

362:                                              ; preds = %359
  %363 = zext i64 %263 to i128
  %364 = shl nuw i128 %363, 64
  %365 = zext i64 %264 to i128
  %366 = or disjoint i128 %364, %365
  %367 = zext nneg i32 %360 to i128
  %368 = lshr i128 %366, %367
  %369 = trunc i128 %368 to i64
  %370 = lshr i128 %368, 64
  %371 = trunc nuw i128 %370 to i64
  br label %372

372:                                              ; preds = %362, %359, %357, %347, %344
  %373 = phi i32 [ %265, %344 ], [ %334, %362 ], [ %265, %357 ], [ %265, %347 ], [ %334, %359 ]
  %374 = phi i32 [ %265, %344 ], [ %334, %362 ], [ %334, %357 ], [ %265, %347 ], [ %334, %359 ]
  %375 = phi i64 [ 0, %344 ], [ %333, %362 ], [ %333, %357 ], [ %354, %347 ], [ %333, %359 ]
  %376 = phi i64 [ %264, %344 ], [ %369, %362 ], [ %264, %357 ], [ %264, %347 ], [ 0, %359 ]
  %377 = phi i64 [ 0, %344 ], [ %332, %362 ], [ %332, %357 ], [ %356, %347 ], [ %332, %359 ]
  %378 = phi i64 [ %263, %344 ], [ %371, %362 ], [ %263, %357 ], [ %263, %347 ], [ 0, %359 ]
  %379 = icmp eq i8 %152, %266
  br i1 %379, label %380, label %402

380:                                              ; preds = %372
  %381 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %376, i64 %375)
  %382 = extractvalue { i64, i1 } %381, 1
  %383 = extractvalue { i64, i1 } %381, 0
  %384 = zext i1 %382 to i64
  %385 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %378, i64 %377)
  %386 = extractvalue { i64, i1 } %385, 1
  %387 = extractvalue { i64, i1 } %385, 0
  %388 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %387, i64 %384)
  %389 = extractvalue { i64, i1 } %388, 1
  %390 = extractvalue { i64, i1 } %388, 0
  %391 = or i1 %386, %389
  br i1 %391, label %392, label %448

392:                                              ; preds = %380
  %393 = add nsw i32 %373, 1
  %394 = zext i64 %390 to i128
  %395 = shl nuw i128 %394, 64
  %396 = zext i64 %383 to i128
  %397 = or disjoint i128 %395, %396
  %398 = lshr i128 %397, 1
  %399 = trunc i128 %398 to i64
  %400 = lshr i64 %390, 1
  %401 = or disjoint i64 %400, -9223372036854775808
  br label %448

402:                                              ; preds = %372
  %403 = icmp eq i64 %378, %377
  br i1 %403, label %404, label %406

404:                                              ; preds = %402
  %405 = icmp eq i64 %376, %375
  br i1 %405, label %410, label %406

406:                                              ; preds = %404, %402
  %407 = phi i64 [ %378, %402 ], [ %376, %404 ]
  %408 = phi i64 [ %377, %402 ], [ %375, %404 ]
  %409 = icmp ult i64 %407, %408
  br i1 %409, label %416, label %410

410:                                              ; preds = %406, %404
  %411 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %376, i64 %375)
  %412 = extractvalue { i64, i1 } %411, 1
  %413 = sext i1 %412 to i64
  %414 = sub i64 %378, %377
  %415 = add i64 %414, %413
  br label %422

416:                                              ; preds = %406
  %417 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %375, i64 %376)
  %418 = extractvalue { i64, i1 } %417, 1
  %419 = sext i1 %418 to i64
  %420 = sub i64 %377, %378
  %421 = add i64 %420, %419
  br label %422

422:                                              ; preds = %416, %410
  %423 = phi i32 [ %373, %410 ], [ %374, %416 ]
  %424 = phi { i64, i1 } [ %411, %410 ], [ %417, %416 ]
  %425 = phi i64 [ %415, %410 ], [ %421, %416 ]
  %426 = phi i8 [ %266, %410 ], [ %152, %416 ]
  %427 = extractvalue { i64, i1 } %424, 0
  %428 = icmp eq i64 %427, 0
  %429 = icmp eq i64 %425, 0
  %430 = select i1 %428, i1 %429, i1 false
  br i1 %430, label %448, label %431

431:                                              ; preds = %422
  %432 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %425, i1 false)
  %433 = trunc nuw nsw i64 %432 to i32
  %434 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %427, i1 false)
  %435 = trunc nuw nsw i64 %434 to i32
  %436 = select i1 %429, i32 %435, i32 0
  %437 = add nuw nsw i32 %436, %433
  %438 = sub nsw i32 %423, %437
  %439 = zext i64 %425 to i128
  %440 = shl nuw i128 %439, 64
  %441 = zext i64 %427 to i128
  %442 = or disjoint i128 %440, %441
  %443 = zext nneg i32 %437 to i128
  %444 = shl i128 %442, %443
  %445 = trunc i128 %444 to i64
  %446 = lshr i128 %444, 64
  %447 = trunc nuw i128 %446 to i64
  br label %448

448:                                              ; preds = %338, %331, %422, %431, %380, %392
  %449 = phi i64 [ %447, %431 ], [ %332, %331 ], [ %401, %392 ], [ %390, %380 ], [ 0, %422 ], [ %263, %338 ]
  %450 = phi i64 [ %445, %431 ], [ %333, %331 ], [ %399, %392 ], [ %383, %380 ], [ 0, %422 ], [ %264, %338 ]
  %451 = phi i32 [ %438, %431 ], [ %334, %331 ], [ %393, %392 ], [ %373, %380 ], [ %423, %422 ], [ %265, %338 ]
  %452 = phi i8 [ %426, %431 ], [ %152, %331 ], [ %152, %392 ], [ %152, %380 ], [ %426, %422 ], [ %266, %338 ]
  %453 = getelementptr inbounds nuw i8, ptr %0, i64 4
  %454 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i8 %452, ptr %0, align 8, !tbaa !17, !alias.scope !42
  %455 = add nsw i32 %451, -5
  store i32 %455, ptr %453, align 4, !tbaa !25, !alias.scope !42
  %456 = icmp eq i64 %450, 0
  %457 = icmp eq i64 %449, 0
  %458 = select i1 %456, i1 %457, i1 false
  br i1 %458, label %503, label %459

459:                                              ; preds = %448
  %460 = zext i64 %450 to i128
  %461 = mul nuw i128 %460, 14488038916154245684
  %462 = trunc i128 %461 to i64
  %463 = lshr i128 %461, 64
  %464 = trunc nuw i128 %463 to i64
  %465 = zext i64 %449 to i128
  %466 = mul nuw i128 %465, 14179128828124470481
  %467 = trunc i128 %466 to i64
  %468 = lshr i128 %466, 64
  %469 = trunc nuw i128 %468 to i64
  %470 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %462, i64 %467)
  %471 = extractvalue { i64, i1 } %470, 1
  %472 = zext i1 %471 to i64
  %473 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %464, i64 %469)
  %474 = extractvalue { i64, i1 } %473, 1
  %475 = extractvalue { i64, i1 } %473, 0
  %476 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %475, i64 %472)
  %477 = extractvalue { i64, i1 } %476, 1
  %478 = extractvalue { i64, i1 } %476, 0
  %479 = or i1 %474, %477
  %480 = zext i1 %479 to i64
  %481 = mul nuw i128 %465, 14488038916154245684
  %482 = trunc i128 %481 to i64
  %483 = lshr i128 %481, 64
  %484 = trunc nuw i128 %483 to i64
  %485 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %478, i64 %482)
  %486 = extractvalue { i64, i1 } %485, 1
  %487 = extractvalue { i64, i1 } %485, 0
  %488 = zext i1 %486 to i64
  %489 = add nuw i64 %480, %484
  %490 = add nuw i64 %489, %488
  store i64 %487, ptr %454, align 8, !alias.scope !42
  %491 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %490, ptr %491, align 8, !tbaa !21, !alias.scope !42
  %492 = icmp sgt i64 %490, -1
  br i1 %492, label %493, label %504

493:                                              ; preds = %459
  %494 = add nsw i32 %451, -6
  store i32 %494, ptr %453, align 4, !tbaa !25, !alias.scope !42
  %495 = zext nneg i64 %490 to i128
  %496 = zext i64 %487 to i128
  %497 = shl nuw i128 %495, 65
  %498 = shl nuw nsw i128 %496, 1
  %499 = or disjoint i128 %497, %498
  %500 = trunc i128 %498 to i64
  %501 = lshr i128 %499, 64
  %502 = trunc nuw i128 %501 to i64
  store i64 %500, ptr %454, align 8, !alias.scope !42
  store i64 %502, ptr %491, align 8, !tbaa !21, !alias.scope !42
  br label %504

503:                                              ; preds = %448
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %454, i8 0, i64 16, i1 false), !alias.scope !42
  br label %504

504:                                              ; preds = %459, %493, %503
  ret void
}

; Function Attrs: inlinehint mustprogress sspstrong uwtable
define linkonce_odr hidden void @_ZNK11__llvm_libc4math31range_reduction_double_internal19LargeRangeReduction8accurateEv(ptr dead_on_unwind noalias writable sret(%"struct.__llvm_libc::fputil::DyadicFloat") align 8 %0, ptr noundef nonnull align 8 dereferenceable(48) %1) local_unnamed_addr #1 comdat align 2 {
  %3 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %4 = load double, ptr %3, align 8, !tbaa !37
  %5 = load i32, ptr %1, align 8, !tbaa !35
  %6 = zext i32 %5 to i64
  %7 = getelementptr inbounds nuw [32 x i8], ptr @_ZN11__llvm_libc4math31range_reduction_double_internal24ONE_TWENTY_EIGHT_OVER_PIE, i64 %6
  %8 = getelementptr inbounds nuw i8, ptr %7, i64 24
  %9 = load double, ptr %8, align 8, !tbaa !16
  %10 = fmul double %4, %9
  %11 = bitcast double %10 to i64
  %12 = lshr i64 %11, 63
  %13 = trunc nuw nsw i64 %12 to i8
  %14 = lshr i64 %11, 52
  %15 = trunc nuw nsw i64 %14 to i32
  %16 = and i32 %15, 2047
  %17 = fcmp oeq double %10, 0.000000e+00
  %18 = icmp eq i32 %16, 0
  %19 = add nsw i32 %16, -1075
  %20 = select i1 %18, i32 -1074, i32 %19
  %21 = select i1 %17, i32 -52, i32 %20
  %22 = and i64 %11, 9218868437227405312
  %23 = icmp eq i64 %22, 0
  %24 = and i64 %11, 4503599627370495
  %25 = or disjoint i64 %24, 4503599627370496
  %26 = select i1 %23, i64 %24, i64 %25
  %27 = icmp eq i64 %26, 0
  br i1 %27, label %38, label %28

28:                                               ; preds = %2
  %29 = tail call range(i64 11, 65) i64 @llvm.ctlz.i64(i64 %26, i1 true)
  %30 = trunc nuw nsw i64 %29 to i32
  %31 = or disjoint i32 %30, 64
  %32 = sub nsw i32 %21, %31
  %33 = zext nneg i64 %26 to i128
  %34 = zext nneg i32 %31 to i128
  %35 = shl i128 %33, %34
  %36 = lshr exact i128 %35, 64
  %37 = trunc nuw i128 %36 to i64
  br label %38

38:                                               ; preds = %2, %28
  %39 = phi i32 [ %21, %2 ], [ %32, %28 ]
  %40 = phi i64 [ 0, %2 ], [ %37, %28 ]
  %41 = getelementptr inbounds nuw i8, ptr %1, i64 24
  %42 = load double, ptr %41, align 8, !tbaa !39
  %43 = bitcast double %42 to i64
  %44 = lshr i64 %43, 63
  %45 = trunc nuw nsw i64 %44 to i8
  %46 = and i64 %43, 9218868437227405312
  %47 = icmp eq i64 %46, 0
  %48 = and i64 %43, 4503599627370495
  %49 = or disjoint i64 %48, 4503599627370496
  %50 = select i1 %47, i64 %48, i64 %49
  %51 = icmp eq i64 %50, 0
  br i1 %51, label %173, label %52

52:                                               ; preds = %38
  %53 = fcmp oeq double %42, 0.000000e+00
  %54 = lshr i64 %43, 52
  %55 = trunc nuw nsw i64 %54 to i32
  %56 = and i32 %55, 2047
  %57 = icmp eq i32 %56, 0
  %58 = add nsw i32 %56, -1075
  %59 = select i1 %57, i32 -1074, i32 %58
  %60 = select i1 %53, i32 -52, i32 %59
  %61 = tail call range(i64 11, 65) i64 @llvm.ctlz.i64(i64 %50, i1 true)
  %62 = trunc nuw nsw i64 %61 to i32
  %63 = or disjoint i32 %62, 64
  %64 = sub nsw i32 %60, %63
  %65 = zext nneg i64 %50 to i128
  %66 = zext nneg i32 %63 to i128
  %67 = shl i128 %65, %66
  %68 = lshr exact i128 %67, 64
  %69 = trunc nuw i128 %68 to i64
  %70 = icmp eq i128 %67, 0
  br i1 %70, label %173, label %71, !prof !45

71:                                               ; preds = %52
  %72 = icmp eq i64 %40, 0
  br i1 %72, label %173, label %73, !prof !11

73:                                               ; preds = %71
  %74 = icmp sgt i32 %64, %39
  br i1 %74, label %75, label %86

75:                                               ; preds = %73
  %76 = sub nsw i32 %64, %39
  %77 = icmp ult i32 %76, 128
  br i1 %77, label %78, label %97

78:                                               ; preds = %75
  %79 = zext i64 %40 to i128
  %80 = shl nuw i128 %79, 64
  %81 = zext nneg i32 %76 to i128
  %82 = lshr i128 %80, %81
  %83 = trunc i128 %82 to i64
  %84 = lshr i128 %82, 64
  %85 = trunc nuw i128 %84 to i64
  br label %97

86:                                               ; preds = %73
  %87 = icmp sgt i32 %39, %64
  br i1 %87, label %88, label %97

88:                                               ; preds = %86
  %89 = sub nsw i32 %39, %64
  %90 = icmp ult i32 %89, 128
  br i1 %90, label %91, label %97

91:                                               ; preds = %88
  %92 = zext nneg i32 %89 to i128
  %93 = lshr i128 %67, %92
  %94 = trunc i128 %93 to i64
  %95 = lshr i128 %93, 64
  %96 = trunc nuw i128 %95 to i64
  br label %97

97:                                               ; preds = %91, %88, %86, %78, %75
  %98 = phi i32 [ %64, %75 ], [ %39, %91 ], [ %64, %86 ], [ %64, %78 ], [ %39, %88 ]
  %99 = phi i32 [ %64, %75 ], [ %39, %91 ], [ %39, %86 ], [ %64, %78 ], [ %39, %88 ]
  %100 = phi i64 [ 0, %75 ], [ 0, %91 ], [ 0, %86 ], [ %83, %78 ], [ 0, %88 ]
  %101 = phi i64 [ 0, %75 ], [ %94, %91 ], [ 0, %86 ], [ 0, %78 ], [ 0, %88 ]
  %102 = phi i64 [ 0, %75 ], [ %40, %91 ], [ %40, %86 ], [ %85, %78 ], [ %40, %88 ]
  %103 = phi i64 [ %69, %75 ], [ %96, %91 ], [ %69, %86 ], [ %69, %78 ], [ 0, %88 ]
  %104 = icmp eq i64 %12, %44
  br i1 %104, label %105, label %127

105:                                              ; preds = %97
  %106 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %101, i64 %100)
  %107 = extractvalue { i64, i1 } %106, 1
  %108 = extractvalue { i64, i1 } %106, 0
  %109 = zext i1 %107 to i64
  %110 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %103, i64 %102)
  %111 = extractvalue { i64, i1 } %110, 1
  %112 = extractvalue { i64, i1 } %110, 0
  %113 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %112, i64 %109)
  %114 = extractvalue { i64, i1 } %113, 1
  %115 = extractvalue { i64, i1 } %113, 0
  %116 = or i1 %111, %114
  br i1 %116, label %117, label %173

117:                                              ; preds = %105
  %118 = add nsw i32 %98, 1
  %119 = zext i64 %115 to i128
  %120 = shl nuw i128 %119, 64
  %121 = zext i64 %108 to i128
  %122 = or disjoint i128 %120, %121
  %123 = lshr i128 %122, 1
  %124 = trunc i128 %123 to i64
  %125 = lshr i64 %115, 1
  %126 = or disjoint i64 %125, -9223372036854775808
  br label %173

127:                                              ; preds = %97
  %128 = icmp eq i64 %103, %102
  br i1 %128, label %129, label %131

129:                                              ; preds = %127
  %130 = icmp eq i64 %101, %100
  br i1 %130, label %135, label %131

131:                                              ; preds = %129, %127
  %132 = phi i64 [ %103, %127 ], [ %101, %129 ]
  %133 = phi i64 [ %102, %127 ], [ %100, %129 ]
  %134 = icmp ult i64 %132, %133
  br i1 %134, label %141, label %135

135:                                              ; preds = %131, %129
  %136 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %101, i64 %100)
  %137 = extractvalue { i64, i1 } %136, 1
  %138 = sext i1 %137 to i64
  %139 = sub i64 %103, %102
  %140 = add i64 %139, %138
  br label %147

141:                                              ; preds = %131
  %142 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %100, i64 %101)
  %143 = extractvalue { i64, i1 } %142, 1
  %144 = sext i1 %143 to i64
  %145 = sub i64 %102, %103
  %146 = add i64 %145, %144
  br label %147

147:                                              ; preds = %141, %135
  %148 = phi i32 [ %98, %135 ], [ %99, %141 ]
  %149 = phi { i64, i1 } [ %136, %135 ], [ %142, %141 ]
  %150 = phi i64 [ %140, %135 ], [ %146, %141 ]
  %151 = phi i8 [ %45, %135 ], [ %13, %141 ]
  %152 = extractvalue { i64, i1 } %149, 0
  %153 = icmp eq i64 %152, 0
  %154 = icmp eq i64 %150, 0
  %155 = select i1 %153, i1 %154, i1 false
  br i1 %155, label %173, label %156

156:                                              ; preds = %147
  %157 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %150, i1 false)
  %158 = trunc nuw nsw i64 %157 to i32
  %159 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %152, i1 false)
  %160 = trunc nuw nsw i64 %159 to i32
  %161 = select i1 %154, i32 %160, i32 0
  %162 = add nuw nsw i32 %161, %158
  %163 = sub nsw i32 %148, %162
  %164 = zext i64 %150 to i128
  %165 = shl nuw i128 %164, 64
  %166 = zext i64 %152 to i128
  %167 = or disjoint i128 %165, %166
  %168 = zext nneg i32 %162 to i128
  %169 = shl i128 %167, %168
  %170 = trunc i128 %169 to i64
  %171 = lshr i128 %169, 64
  %172 = trunc nuw i128 %171 to i64
  br label %173

173:                                              ; preds = %38, %71, %52, %147, %156, %105, %117
  %174 = phi i8 [ %151, %147 ], [ %13, %52 ], [ %45, %105 ], [ %45, %117 ], [ %151, %156 ], [ %45, %71 ], [ %13, %38 ]
  %175 = phi i32 [ %148, %147 ], [ %39, %52 ], [ %98, %105 ], [ %118, %117 ], [ %163, %156 ], [ %64, %71 ], [ %39, %38 ]
  %176 = phi i64 [ 0, %147 ], [ 0, %52 ], [ %108, %105 ], [ %124, %117 ], [ %170, %156 ], [ 0, %71 ], [ 0, %38 ]
  %177 = phi i64 [ 0, %147 ], [ %40, %52 ], [ %115, %105 ], [ %126, %117 ], [ %172, %156 ], [ %69, %71 ], [ %40, %38 ]
  %178 = getelementptr inbounds nuw i8, ptr %1, i64 32
  %179 = load double, ptr %178, align 8, !tbaa !46
  %180 = bitcast double %179 to i64
  %181 = lshr i64 %180, 63
  %182 = trunc nuw nsw i64 %181 to i8
  %183 = and i64 %180, 9218868437227405312
  %184 = icmp eq i64 %183, 0
  %185 = and i64 %180, 4503599627370495
  %186 = or disjoint i64 %185, 4503599627370496
  %187 = select i1 %184, i64 %185, i64 %186
  %188 = icmp eq i64 %187, 0
  br i1 %188, label %314, label %189

189:                                              ; preds = %173
  %190 = fcmp oeq double %179, 0.000000e+00
  %191 = lshr i64 %180, 52
  %192 = trunc nuw nsw i64 %191 to i32
  %193 = and i32 %192, 2047
  %194 = icmp eq i32 %193, 0
  %195 = add nsw i32 %193, -1075
  %196 = select i1 %194, i32 -1074, i32 %195
  %197 = select i1 %190, i32 -52, i32 %196
  %198 = tail call range(i64 11, 65) i64 @llvm.ctlz.i64(i64 %187, i1 true)
  %199 = trunc nuw nsw i64 %198 to i32
  %200 = or disjoint i32 %199, 64
  %201 = sub nsw i32 %197, %200
  %202 = zext nneg i64 %187 to i128
  %203 = zext nneg i32 %200 to i128
  %204 = shl i128 %202, %203
  %205 = lshr exact i128 %204, 64
  %206 = trunc nuw i128 %205 to i64
  %207 = icmp eq i128 %204, 0
  br i1 %207, label %314, label %208, !prof !45

208:                                              ; preds = %189
  %209 = icmp eq i64 %176, 0
  %210 = icmp eq i64 %177, 0
  %211 = select i1 %209, i1 %210, i1 false
  br i1 %211, label %314, label %212, !prof !11

212:                                              ; preds = %208
  %213 = icmp sgt i32 %201, %175
  br i1 %213, label %214, label %227

214:                                              ; preds = %212
  %215 = sub nsw i32 %201, %175
  %216 = icmp ult i32 %215, 128
  br i1 %216, label %217, label %238

217:                                              ; preds = %214
  %218 = zext i64 %177 to i128
  %219 = shl nuw i128 %218, 64
  %220 = zext i64 %176 to i128
  %221 = or disjoint i128 %219, %220
  %222 = zext nneg i32 %215 to i128
  %223 = lshr i128 %221, %222
  %224 = trunc i128 %223 to i64
  %225 = lshr i128 %223, 64
  %226 = trunc nuw i128 %225 to i64
  br label %238

227:                                              ; preds = %212
  %228 = icmp sgt i32 %175, %201
  br i1 %228, label %229, label %238

229:                                              ; preds = %227
  %230 = sub nsw i32 %175, %201
  %231 = icmp ult i32 %230, 128
  br i1 %231, label %232, label %238

232:                                              ; preds = %229
  %233 = zext nneg i32 %230 to i128
  %234 = lshr i128 %204, %233
  %235 = trunc i128 %234 to i64
  %236 = lshr i128 %234, 64
  %237 = trunc nuw i128 %236 to i64
  br label %238

238:                                              ; preds = %232, %229, %227, %217, %214
  %239 = phi i32 [ %201, %214 ], [ %175, %232 ], [ %201, %227 ], [ %201, %217 ], [ %175, %229 ]
  %240 = phi i32 [ %201, %214 ], [ %175, %232 ], [ %175, %227 ], [ %201, %217 ], [ %175, %229 ]
  %241 = phi i64 [ 0, %214 ], [ %176, %232 ], [ %176, %227 ], [ %224, %217 ], [ %176, %229 ]
  %242 = phi i64 [ 0, %214 ], [ %235, %232 ], [ 0, %227 ], [ 0, %217 ], [ 0, %229 ]
  %243 = phi i64 [ 0, %214 ], [ %177, %232 ], [ %177, %227 ], [ %226, %217 ], [ %177, %229 ]
  %244 = phi i64 [ %206, %214 ], [ %237, %232 ], [ %206, %227 ], [ %206, %217 ], [ 0, %229 ]
  %245 = icmp eq i8 %174, %182
  br i1 %245, label %246, label %268

246:                                              ; preds = %238
  %247 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %242, i64 %241)
  %248 = extractvalue { i64, i1 } %247, 1
  %249 = extractvalue { i64, i1 } %247, 0
  %250 = zext i1 %248 to i64
  %251 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %244, i64 %243)
  %252 = extractvalue { i64, i1 } %251, 1
  %253 = extractvalue { i64, i1 } %251, 0
  %254 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %253, i64 %250)
  %255 = extractvalue { i64, i1 } %254, 1
  %256 = extractvalue { i64, i1 } %254, 0
  %257 = or i1 %252, %255
  br i1 %257, label %258, label %314

258:                                              ; preds = %246
  %259 = add nsw i32 %239, 1
  %260 = zext i64 %256 to i128
  %261 = shl nuw i128 %260, 64
  %262 = zext i64 %249 to i128
  %263 = or disjoint i128 %261, %262
  %264 = lshr i128 %263, 1
  %265 = trunc i128 %264 to i64
  %266 = lshr i64 %256, 1
  %267 = or disjoint i64 %266, -9223372036854775808
  br label %314

268:                                              ; preds = %238
  %269 = icmp eq i64 %244, %243
  br i1 %269, label %270, label %272

270:                                              ; preds = %268
  %271 = icmp eq i64 %242, %241
  br i1 %271, label %276, label %272

272:                                              ; preds = %270, %268
  %273 = phi i64 [ %244, %268 ], [ %242, %270 ]
  %274 = phi i64 [ %243, %268 ], [ %241, %270 ]
  %275 = icmp ult i64 %273, %274
  br i1 %275, label %282, label %276

276:                                              ; preds = %272, %270
  %277 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %242, i64 %241)
  %278 = extractvalue { i64, i1 } %277, 1
  %279 = sext i1 %278 to i64
  %280 = sub i64 %244, %243
  %281 = add i64 %280, %279
  br label %288

282:                                              ; preds = %272
  %283 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %241, i64 %242)
  %284 = extractvalue { i64, i1 } %283, 1
  %285 = sext i1 %284 to i64
  %286 = sub i64 %243, %244
  %287 = add i64 %286, %285
  br label %288

288:                                              ; preds = %282, %276
  %289 = phi i32 [ %239, %276 ], [ %240, %282 ]
  %290 = phi { i64, i1 } [ %277, %276 ], [ %283, %282 ]
  %291 = phi i64 [ %281, %276 ], [ %287, %282 ]
  %292 = phi i8 [ %182, %276 ], [ %174, %282 ]
  %293 = extractvalue { i64, i1 } %290, 0
  %294 = icmp eq i64 %293, 0
  %295 = icmp eq i64 %291, 0
  %296 = select i1 %294, i1 %295, i1 false
  br i1 %296, label %314, label %297

297:                                              ; preds = %288
  %298 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %291, i1 false)
  %299 = trunc nuw nsw i64 %298 to i32
  %300 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %293, i1 false)
  %301 = trunc nuw nsw i64 %300 to i32
  %302 = select i1 %295, i32 %301, i32 0
  %303 = add nuw nsw i32 %302, %299
  %304 = sub nsw i32 %289, %303
  %305 = zext i64 %291 to i128
  %306 = shl nuw i128 %305, 64
  %307 = zext i64 %293 to i128
  %308 = or disjoint i128 %306, %307
  %309 = zext nneg i32 %303 to i128
  %310 = shl i128 %308, %309
  %311 = trunc i128 %310 to i64
  %312 = lshr i128 %310, 64
  %313 = trunc nuw i128 %312 to i64
  br label %314

314:                                              ; preds = %173, %208, %189, %288, %297, %246, %258
  %315 = phi i8 [ %292, %288 ], [ %174, %189 ], [ %174, %246 ], [ %174, %258 ], [ %292, %297 ], [ %182, %208 ], [ %174, %173 ]
  %316 = phi i32 [ %289, %288 ], [ %175, %189 ], [ %239, %246 ], [ %259, %258 ], [ %304, %297 ], [ %201, %208 ], [ %175, %173 ]
  %317 = phi i64 [ 0, %288 ], [ %176, %189 ], [ %249, %246 ], [ %265, %258 ], [ %311, %297 ], [ 0, %208 ], [ %176, %173 ]
  %318 = phi i64 [ 0, %288 ], [ %177, %189 ], [ %256, %246 ], [ %267, %258 ], [ %313, %297 ], [ %206, %208 ], [ %177, %173 ]
  %319 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %320 = load double, ptr %319, align 8, !tbaa !38
  %321 = bitcast double %320 to i64
  %322 = lshr i64 %321, 63
  %323 = trunc nuw nsw i64 %322 to i8
  %324 = lshr i64 %321, 52
  %325 = trunc nuw nsw i64 %324 to i32
  %326 = and i32 %325, 2047
  %327 = fcmp oeq double %320, 0.000000e+00
  %328 = icmp eq i32 %326, 0
  %329 = add nsw i32 %326, -1075
  %330 = select i1 %328, i32 -1074, i32 %329
  %331 = select i1 %327, i32 -52, i32 %330
  %332 = and i64 %321, 9218868437227405312
  %333 = icmp eq i64 %332, 0
  %334 = and i64 %321, 4503599627370495
  %335 = or disjoint i64 %334, 4503599627370496
  %336 = select i1 %333, i64 %334, i64 %335
  %337 = icmp eq i64 %336, 0
  br i1 %337, label %348, label %338

338:                                              ; preds = %314
  %339 = tail call range(i64 11, 65) i64 @llvm.ctlz.i64(i64 %336, i1 true)
  %340 = trunc nuw nsw i64 %339 to i32
  %341 = or disjoint i32 %340, 64
  %342 = sub nsw i32 %331, %341
  %343 = zext nneg i64 %336 to i128
  %344 = zext nneg i32 %341 to i128
  %345 = shl i128 %343, %344
  %346 = lshr exact i128 %345, 64
  %347 = trunc nuw i128 %346 to i64
  br label %348

348:                                              ; preds = %314, %338
  %349 = phi i32 [ %331, %314 ], [ %342, %338 ]
  %350 = phi i64 [ 0, %314 ], [ %347, %338 ]
  %351 = getelementptr inbounds nuw i8, ptr %1, i64 40
  %352 = load double, ptr %351, align 8, !tbaa !47
  %353 = bitcast double %352 to i64
  %354 = lshr i64 %353, 63
  %355 = trunc nuw nsw i64 %354 to i8
  %356 = lshr i64 %353, 52
  %357 = trunc nuw nsw i64 %356 to i32
  %358 = and i32 %357, 2047
  %359 = fcmp oeq double %352, 0.000000e+00
  %360 = icmp eq i32 %358, 0
  %361 = add nsw i32 %358, -1075
  %362 = select i1 %360, i32 -1074, i32 %361
  %363 = select i1 %359, i32 -52, i32 %362
  %364 = and i64 %353, 9218868437227405312
  %365 = icmp eq i64 %364, 0
  %366 = and i64 %353, 4503599627370495
  %367 = or disjoint i64 %366, 4503599627370496
  %368 = select i1 %365, i64 %366, i64 %367
  %369 = icmp eq i64 %368, 0
  br i1 %369, label %381, label %370

370:                                              ; preds = %348
  %371 = tail call range(i64 11, 65) i64 @llvm.ctlz.i64(i64 %368, i1 true)
  %372 = trunc nuw nsw i64 %371 to i32
  %373 = or disjoint i32 %372, 64
  %374 = sub nsw i32 %363, %373
  %375 = zext nneg i64 %368 to i128
  %376 = zext nneg i32 %373 to i128
  %377 = shl i128 %375, %376
  %378 = lshr exact i128 %377, 64
  %379 = trunc nuw i128 %378 to i64
  %380 = icmp eq i64 %350, 0
  br i1 %380, label %485, label %383, !prof !11

381:                                              ; preds = %348
  %382 = icmp eq i64 %350, 0
  br i1 %382, label %485, label %493, !prof !11

383:                                              ; preds = %370
  %384 = icmp eq i128 %377, 0
  br i1 %384, label %493, label %385, !prof !45

385:                                              ; preds = %383
  %386 = icmp sgt i32 %349, %374
  br i1 %386, label %387, label %396

387:                                              ; preds = %385
  %388 = sub nsw i32 %349, %374
  %389 = icmp ult i32 %388, 128
  br i1 %389, label %390, label %409

390:                                              ; preds = %387
  %391 = zext nneg i32 %388 to i128
  %392 = lshr i128 %377, %391
  %393 = trunc i128 %392 to i64
  %394 = lshr i128 %392, 64
  %395 = trunc nuw i128 %394 to i64
  br label %409

396:                                              ; preds = %385
  %397 = icmp sgt i32 %374, %349
  br i1 %397, label %398, label %409

398:                                              ; preds = %396
  %399 = sub nsw i32 %374, %349
  %400 = icmp ult i32 %399, 128
  br i1 %400, label %401, label %409

401:                                              ; preds = %398
  %402 = zext i64 %350 to i128
  %403 = shl nuw i128 %402, 64
  %404 = zext nneg i32 %399 to i128
  %405 = lshr i128 %403, %404
  %406 = trunc i128 %405 to i64
  %407 = lshr i128 %405, 64
  %408 = trunc nuw i128 %407 to i64
  br label %409

409:                                              ; preds = %401, %398, %396, %390, %387
  %410 = phi i32 [ %349, %387 ], [ %374, %401 ], [ %349, %396 ], [ %349, %390 ], [ %374, %398 ]
  %411 = phi i32 [ %349, %387 ], [ %374, %401 ], [ %374, %396 ], [ %349, %390 ], [ %374, %398 ]
  %412 = phi i64 [ 0, %387 ], [ 0, %401 ], [ 0, %396 ], [ %393, %390 ], [ 0, %398 ]
  %413 = phi i64 [ 0, %387 ], [ %406, %401 ], [ 0, %396 ], [ 0, %390 ], [ 0, %398 ]
  %414 = phi i64 [ 0, %387 ], [ %379, %401 ], [ %379, %396 ], [ %395, %390 ], [ %379, %398 ]
  %415 = phi i64 [ %350, %387 ], [ %408, %401 ], [ %350, %396 ], [ %350, %390 ], [ 0, %398 ]
  %416 = icmp eq i64 %354, %322
  br i1 %416, label %417, label %439

417:                                              ; preds = %409
  %418 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %413, i64 %412)
  %419 = extractvalue { i64, i1 } %418, 1
  %420 = extractvalue { i64, i1 } %418, 0
  %421 = zext i1 %419 to i64
  %422 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %415, i64 %414)
  %423 = extractvalue { i64, i1 } %422, 1
  %424 = extractvalue { i64, i1 } %422, 0
  %425 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %424, i64 %421)
  %426 = extractvalue { i64, i1 } %425, 1
  %427 = extractvalue { i64, i1 } %425, 0
  %428 = or i1 %423, %426
  br i1 %428, label %429, label %485

429:                                              ; preds = %417
  %430 = add nsw i32 %410, 1
  %431 = zext i64 %427 to i128
  %432 = shl nuw i128 %431, 64
  %433 = zext i64 %420 to i128
  %434 = or disjoint i128 %432, %433
  %435 = lshr i128 %434, 1
  %436 = trunc i128 %435 to i64
  %437 = lshr i64 %427, 1
  %438 = or disjoint i64 %437, -9223372036854775808
  br label %493

439:                                              ; preds = %409
  %440 = icmp eq i64 %415, %414
  br i1 %440, label %441, label %443

441:                                              ; preds = %439
  %442 = icmp eq i64 %413, %412
  br i1 %442, label %447, label %443

443:                                              ; preds = %441, %439
  %444 = phi i64 [ %415, %439 ], [ %413, %441 ]
  %445 = phi i64 [ %414, %439 ], [ %412, %441 ]
  %446 = icmp ult i64 %444, %445
  br i1 %446, label %453, label %447

447:                                              ; preds = %443, %441
  %448 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %413, i64 %412)
  %449 = extractvalue { i64, i1 } %448, 1
  %450 = sext i1 %449 to i64
  %451 = sub i64 %415, %414
  %452 = add i64 %451, %450
  br label %459

453:                                              ; preds = %443
  %454 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %412, i64 %413)
  %455 = extractvalue { i64, i1 } %454, 1
  %456 = sext i1 %455 to i64
  %457 = sub i64 %414, %415
  %458 = add i64 %457, %456
  br label %459

459:                                              ; preds = %453, %447
  %460 = phi i32 [ %410, %447 ], [ %411, %453 ]
  %461 = phi { i64, i1 } [ %448, %447 ], [ %454, %453 ]
  %462 = phi i64 [ %452, %447 ], [ %458, %453 ]
  %463 = phi i8 [ %323, %447 ], [ %355, %453 ]
  %464 = extractvalue { i64, i1 } %461, 0
  %465 = icmp eq i64 %464, 0
  %466 = icmp eq i64 %462, 0
  %467 = select i1 %465, i1 %466, i1 false
  br i1 %467, label %485, label %468

468:                                              ; preds = %459
  %469 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %462, i1 false)
  %470 = trunc nuw nsw i64 %469 to i32
  %471 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %464, i1 false)
  %472 = trunc nuw nsw i64 %471 to i32
  %473 = select i1 %466, i32 %472, i32 0
  %474 = add nuw nsw i32 %473, %470
  %475 = sub nsw i32 %460, %474
  %476 = zext i64 %462 to i128
  %477 = shl nuw i128 %476, 64
  %478 = zext i64 %464 to i128
  %479 = or disjoint i128 %477, %478
  %480 = zext nneg i32 %474 to i128
  %481 = shl i128 %479, %480
  %482 = trunc i128 %481 to i64
  %483 = lshr i128 %481, 64
  %484 = trunc nuw i128 %483 to i64
  br label %485

485:                                              ; preds = %370, %381, %459, %468, %417
  %486 = phi i64 [ %484, %468 ], [ 0, %381 ], [ %379, %370 ], [ %427, %417 ], [ 0, %459 ]
  %487 = phi i64 [ %482, %468 ], [ 0, %381 ], [ 0, %370 ], [ %420, %417 ], [ 0, %459 ]
  %488 = phi i32 [ %475, %468 ], [ %363, %381 ], [ %374, %370 ], [ %410, %417 ], [ %460, %459 ]
  %489 = phi i8 [ %463, %468 ], [ %355, %381 ], [ %355, %370 ], [ %323, %417 ], [ %463, %459 ]
  %490 = icmp eq i64 %487, 0
  %491 = icmp eq i64 %486, 0
  %492 = select i1 %490, i1 %491, i1 false
  br i1 %492, label %607, label %493, !prof !48

493:                                              ; preds = %383, %381, %429, %485
  %494 = phi i8 [ %489, %485 ], [ %323, %429 ], [ %323, %381 ], [ %323, %383 ]
  %495 = phi i32 [ %488, %485 ], [ %430, %429 ], [ %349, %381 ], [ %349, %383 ]
  %496 = phi i64 [ %487, %485 ], [ %436, %429 ], [ 0, %381 ], [ 0, %383 ]
  %497 = phi i64 [ %486, %485 ], [ %438, %429 ], [ %350, %381 ], [ %350, %383 ]
  %498 = icmp eq i64 %317, 0
  %499 = icmp eq i64 %318, 0
  %500 = select i1 %498, i1 %499, i1 false
  br i1 %500, label %607, label %501, !prof !11

501:                                              ; preds = %493
  %502 = icmp sgt i32 %495, %316
  br i1 %502, label %503, label %516

503:                                              ; preds = %501
  %504 = sub nsw i32 %495, %316
  %505 = icmp ult i32 %504, 128
  br i1 %505, label %506, label %531

506:                                              ; preds = %503
  %507 = zext i64 %318 to i128
  %508 = shl nuw i128 %507, 64
  %509 = zext i64 %317 to i128
  %510 = or disjoint i128 %508, %509
  %511 = zext nneg i32 %504 to i128
  %512 = lshr i128 %510, %511
  %513 = trunc i128 %512 to i64
  %514 = lshr i128 %512, 64
  %515 = trunc nuw i128 %514 to i64
  br label %531

516:                                              ; preds = %501
  %517 = icmp sgt i32 %316, %495
  br i1 %517, label %518, label %531

518:                                              ; preds = %516
  %519 = sub nsw i32 %316, %495
  %520 = icmp ult i32 %519, 128
  br i1 %520, label %521, label %531

521:                                              ; preds = %518
  %522 = zext i64 %497 to i128
  %523 = shl nuw i128 %522, 64
  %524 = zext i64 %496 to i128
  %525 = or disjoint i128 %523, %524
  %526 = zext nneg i32 %519 to i128
  %527 = lshr i128 %525, %526
  %528 = trunc i128 %527 to i64
  %529 = lshr i128 %527, 64
  %530 = trunc nuw i128 %529 to i64
  br label %531

531:                                              ; preds = %521, %518, %516, %506, %503
  %532 = phi i32 [ %495, %503 ], [ %316, %521 ], [ %495, %516 ], [ %495, %506 ], [ %316, %518 ]
  %533 = phi i32 [ %495, %503 ], [ %316, %521 ], [ %316, %516 ], [ %495, %506 ], [ %316, %518 ]
  %534 = phi i64 [ 0, %503 ], [ %317, %521 ], [ %317, %516 ], [ %513, %506 ], [ %317, %518 ]
  %535 = phi i64 [ %496, %503 ], [ %528, %521 ], [ %496, %516 ], [ %496, %506 ], [ 0, %518 ]
  %536 = phi i64 [ 0, %503 ], [ %318, %521 ], [ %318, %516 ], [ %515, %506 ], [ %318, %518 ]
  %537 = phi i64 [ %497, %503 ], [ %530, %521 ], [ %497, %516 ], [ %497, %506 ], [ 0, %518 ]
  %538 = icmp eq i8 %315, %494
  br i1 %538, label %539, label %561

539:                                              ; preds = %531
  %540 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %535, i64 %534)
  %541 = extractvalue { i64, i1 } %540, 1
  %542 = extractvalue { i64, i1 } %540, 0
  %543 = zext i1 %541 to i64
  %544 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %537, i64 %536)
  %545 = extractvalue { i64, i1 } %544, 1
  %546 = extractvalue { i64, i1 } %544, 0
  %547 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %546, i64 %543)
  %548 = extractvalue { i64, i1 } %547, 1
  %549 = extractvalue { i64, i1 } %547, 0
  %550 = or i1 %545, %548
  br i1 %550, label %551, label %607

551:                                              ; preds = %539
  %552 = add nsw i32 %532, 1
  %553 = zext i64 %549 to i128
  %554 = shl nuw i128 %553, 64
  %555 = zext i64 %542 to i128
  %556 = or disjoint i128 %554, %555
  %557 = lshr i128 %556, 1
  %558 = trunc i128 %557 to i64
  %559 = lshr i64 %549, 1
  %560 = or disjoint i64 %559, -9223372036854775808
  br label %607

561:                                              ; preds = %531
  %562 = icmp eq i64 %537, %536
  br i1 %562, label %563, label %565

563:                                              ; preds = %561
  %564 = icmp eq i64 %535, %534
  br i1 %564, label %569, label %565

565:                                              ; preds = %563, %561
  %566 = phi i64 [ %537, %561 ], [ %535, %563 ]
  %567 = phi i64 [ %536, %561 ], [ %534, %563 ]
  %568 = icmp ult i64 %566, %567
  br i1 %568, label %575, label %569

569:                                              ; preds = %565, %563
  %570 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %535, i64 %534)
  %571 = extractvalue { i64, i1 } %570, 1
  %572 = sext i1 %571 to i64
  %573 = sub i64 %537, %536
  %574 = add i64 %573, %572
  br label %581

575:                                              ; preds = %565
  %576 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %534, i64 %535)
  %577 = extractvalue { i64, i1 } %576, 1
  %578 = sext i1 %577 to i64
  %579 = sub i64 %536, %537
  %580 = add i64 %579, %578
  br label %581

581:                                              ; preds = %575, %569
  %582 = phi i32 [ %532, %569 ], [ %533, %575 ]
  %583 = phi { i64, i1 } [ %570, %569 ], [ %576, %575 ]
  %584 = phi i64 [ %574, %569 ], [ %580, %575 ]
  %585 = phi i8 [ %494, %569 ], [ %315, %575 ]
  %586 = extractvalue { i64, i1 } %583, 0
  %587 = icmp eq i64 %586, 0
  %588 = icmp eq i64 %584, 0
  %589 = select i1 %587, i1 %588, i1 false
  br i1 %589, label %607, label %590

590:                                              ; preds = %581
  %591 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %584, i1 false)
  %592 = trunc nuw nsw i64 %591 to i32
  %593 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %586, i1 false)
  %594 = trunc nuw nsw i64 %593 to i32
  %595 = select i1 %588, i32 %594, i32 0
  %596 = add nuw nsw i32 %595, %592
  %597 = sub nsw i32 %582, %596
  %598 = zext i64 %584 to i128
  %599 = shl nuw i128 %598, 64
  %600 = zext i64 %586 to i128
  %601 = or disjoint i128 %599, %600
  %602 = zext nneg i32 %596 to i128
  %603 = shl i128 %601, %602
  %604 = trunc i128 %603 to i64
  %605 = lshr i128 %603, 64
  %606 = trunc nuw i128 %605 to i64
  br label %607

607:                                              ; preds = %493, %485, %581, %590, %539, %551
  %608 = phi i64 [ %606, %590 ], [ %318, %485 ], [ %560, %551 ], [ %549, %539 ], [ 0, %581 ], [ %497, %493 ]
  %609 = phi i64 [ %604, %590 ], [ %317, %485 ], [ %558, %551 ], [ %542, %539 ], [ 0, %581 ], [ %496, %493 ]
  %610 = phi i32 [ %597, %590 ], [ %316, %485 ], [ %552, %551 ], [ %532, %539 ], [ %582, %581 ], [ %495, %493 ]
  %611 = phi i8 [ %585, %590 ], [ %315, %485 ], [ %315, %551 ], [ %315, %539 ], [ %585, %581 ], [ %494, %493 ]
  %612 = getelementptr inbounds nuw i8, ptr %0, i64 4
  %613 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i8 %611, ptr %0, align 8, !tbaa !17, !alias.scope !49
  %614 = add nsw i32 %610, -5
  store i32 %614, ptr %612, align 4, !tbaa !25, !alias.scope !49
  %615 = icmp eq i64 %609, 0
  %616 = icmp eq i64 %608, 0
  %617 = select i1 %615, i1 %616, i1 false
  br i1 %617, label %662, label %618

618:                                              ; preds = %607
  %619 = zext i64 %609 to i128
  %620 = mul nuw i128 %619, 14488038916154245684
  %621 = trunc i128 %620 to i64
  %622 = lshr i128 %620, 64
  %623 = trunc nuw i128 %622 to i64
  %624 = zext i64 %608 to i128
  %625 = mul nuw i128 %624, 14179128828124470481
  %626 = trunc i128 %625 to i64
  %627 = lshr i128 %625, 64
  %628 = trunc nuw i128 %627 to i64
  %629 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %621, i64 %626)
  %630 = extractvalue { i64, i1 } %629, 1
  %631 = zext i1 %630 to i64
  %632 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %623, i64 %628)
  %633 = extractvalue { i64, i1 } %632, 1
  %634 = extractvalue { i64, i1 } %632, 0
  %635 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %634, i64 %631)
  %636 = extractvalue { i64, i1 } %635, 1
  %637 = extractvalue { i64, i1 } %635, 0
  %638 = or i1 %633, %636
  %639 = zext i1 %638 to i64
  %640 = mul nuw i128 %624, 14488038916154245684
  %641 = trunc i128 %640 to i64
  %642 = lshr i128 %640, 64
  %643 = trunc nuw i128 %642 to i64
  %644 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %637, i64 %641)
  %645 = extractvalue { i64, i1 } %644, 1
  %646 = extractvalue { i64, i1 } %644, 0
  %647 = zext i1 %645 to i64
  %648 = add nuw i64 %639, %643
  %649 = add nuw i64 %648, %647
  store i64 %646, ptr %613, align 8, !alias.scope !49
  %650 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %649, ptr %650, align 8, !tbaa !21, !alias.scope !49
  %651 = icmp sgt i64 %649, -1
  br i1 %651, label %652, label %663

652:                                              ; preds = %618
  %653 = add nsw i32 %610, -6
  store i32 %653, ptr %612, align 4, !tbaa !25, !alias.scope !49
  %654 = zext nneg i64 %649 to i128
  %655 = zext i64 %646 to i128
  %656 = shl nuw i128 %654, 65
  %657 = shl nuw nsw i128 %655, 1
  %658 = or disjoint i128 %656, %657
  %659 = trunc i128 %657 to i64
  %660 = lshr i128 %658, 64
  %661 = trunc nuw i128 %660 to i64
  store i64 %659, ptr %613, align 8, !alias.scope !49
  store i64 %661, ptr %650, align 8, !tbaa !21, !alias.scope !49
  br label %663

662:                                              ; preds = %607
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %613, i8 0, i64 16, i1 false), !alias.scope !49
  br label %663

663:                                              ; preds = %618, %652, %662
  ret void
}

; Function Attrs: inlinehint mustprogress sspstrong uwtable
define linkonce_odr hidden void @_ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_(ptr noundef nonnull align 8 dereferenceable(24) %0, ptr noundef nonnull align 8 dereferenceable(24) %1, ptr noundef nonnull align 8 dereferenceable(24) %2) local_unnamed_addr #1 comdat {
  %4 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", align 8
  %5 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", align 8
  %6 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", align 8
  call void @llvm.lifetime.start.p0(ptr nonnull %4) #9
  tail call void @llvm.experimental.noalias.scope.decl(metadata !52)
  %7 = getelementptr inbounds nuw i8, ptr %4, i64 4
  %8 = getelementptr inbounds nuw i8, ptr %4, i64 8
  store i8 0, ptr %4, align 8, !tbaa !17, !alias.scope !52
  %9 = getelementptr inbounds nuw i8, ptr %0, i64 4
  %10 = load i32, ptr %9, align 4, !tbaa !25, !noalias !52
  %11 = shl i32 %10, 1
  %12 = add i32 %11, 128
  store i32 %12, ptr %7, align 4, !tbaa !25, !alias.scope !52
  %13 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %14 = load i64, ptr %13, align 8, !tbaa !30, !noalias !52
  %15 = icmp eq i64 %14, 0
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %17 = load i64, ptr %16, align 8, !noalias !52
  %18 = icmp eq i64 %17, 0
  %19 = select i1 %15, i1 %18, i1 false
  br i1 %19, label %60, label %20

20:                                               ; preds = %3
  %21 = zext i64 %14 to i128
  %22 = zext i64 %17 to i128
  %23 = mul nuw i128 %22, %21
  %24 = trunc i128 %23 to i64
  %25 = lshr i128 %23, 64
  %26 = trunc nuw i128 %25 to i64
  %27 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %24, i64 %24)
  %28 = extractvalue { i64, i1 } %27, 1
  %29 = zext i1 %28 to i64
  %30 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %26, i64 %26)
  %31 = extractvalue { i64, i1 } %30, 1
  %32 = extractvalue { i64, i1 } %30, 0
  %33 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %32, i64 %29)
  %34 = extractvalue { i64, i1 } %33, 1
  %35 = extractvalue { i64, i1 } %33, 0
  %36 = or i1 %31, %34
  %37 = zext i1 %36 to i64
  %38 = mul nuw i128 %22, %22
  %39 = trunc i128 %38 to i64
  %40 = lshr i128 %38, 64
  %41 = trunc nuw i128 %40 to i64
  %42 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %35, i64 %39)
  %43 = extractvalue { i64, i1 } %42, 1
  %44 = extractvalue { i64, i1 } %42, 0
  %45 = zext i1 %43 to i64
  %46 = add nuw i64 %37, %41
  %47 = add i64 %46, %45
  store i64 %44, ptr %8, align 8, !alias.scope !52
  %48 = getelementptr inbounds nuw i8, ptr %4, i64 16
  store i64 %47, ptr %48, align 8, !tbaa !21, !alias.scope !52
  %49 = icmp sgt i64 %47, -1
  br i1 %49, label %50, label %61

50:                                               ; preds = %20
  %51 = add i32 %11, 127
  store i32 %51, ptr %7, align 4, !tbaa !25, !alias.scope !52
  %52 = zext nneg i64 %47 to i128
  %53 = zext i64 %44 to i128
  %54 = shl nuw i128 %52, 65
  %55 = shl nuw nsw i128 %53, 1
  %56 = or disjoint i128 %54, %55
  %57 = trunc i128 %55 to i64
  %58 = lshr i128 %56, 64
  %59 = trunc nuw i128 %58 to i64
  store i64 %57, ptr %8, align 8, !alias.scope !52
  store i64 %59, ptr %48, align 8, !tbaa !21, !alias.scope !52
  br label %61

60:                                               ; preds = %3
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %8, i8 0, i64 16, i1 false), !alias.scope !52
  br label %61

61:                                               ; preds = %20, %50, %60
  call void @llvm.lifetime.start.p0(ptr nonnull %5) #9
  call fastcc void @_ZN11__llvm_libc6fputilL8polyevalINS0_11DyadicFloatILm128EEEJS3_S3_S3_S3_S3_S3_EEENS_3cpp9enable_ifIXgtstT_Lm8EES6_E4typeERKS6_SA_DpRKT0_(ptr dead_on_unwind noalias writable align 8 %5, ptr noundef nonnull align 8 dereferenceable(24) %4, ptr noundef nonnull align 8 dereferenceable(24) @__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.SIN_COEFFS, ptr noundef nonnull align 8 dereferenceable(24) getelementptr inbounds nuw (i8, ptr @__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.SIN_COEFFS, i64 24), ptr noundef nonnull align 8 dereferenceable(24) getelementptr inbounds nuw (i8, ptr @__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.SIN_COEFFS, i64 48), ptr noundef nonnull align 8 dereferenceable(24) getelementptr inbounds nuw (i8, ptr @__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.SIN_COEFFS, i64 72), ptr noundef nonnull align 8 dereferenceable(24) getelementptr inbounds nuw (i8, ptr @__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.SIN_COEFFS, i64 96), ptr noundef nonnull align 8 dereferenceable(24) getelementptr inbounds nuw (i8, ptr @__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.SIN_COEFFS, i64 120), ptr noundef nonnull align 8 dereferenceable(24) getelementptr inbounds nuw (i8, ptr @__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.SIN_COEFFS, i64 144))
  %62 = load i8, ptr %0, align 8, !tbaa !17, !noalias !55
  %63 = load i8, ptr %5, align 8, !tbaa !17, !noalias !55
  %64 = load i32, ptr %9, align 4, !tbaa !25, !noalias !55
  %65 = getelementptr inbounds nuw i8, ptr %5, i64 4
  %66 = load i32, ptr %65, align 4, !tbaa !25, !noalias !55
  %67 = add i32 %66, %64
  %68 = add i32 %67, 128
  %69 = load i64, ptr %13, align 8, !tbaa !30, !noalias !55
  %70 = icmp eq i64 %69, 0
  %71 = load i64, ptr %16, align 8, !noalias !55
  %72 = icmp eq i64 %71, 0
  %73 = select i1 %70, i1 %72, i1 false
  br i1 %73, label %127, label %74

74:                                               ; preds = %61
  %75 = getelementptr inbounds nuw i8, ptr %5, i64 8
  %76 = load i64, ptr %75, align 8, !tbaa !30, !noalias !55
  %77 = icmp eq i64 %76, 0
  %78 = getelementptr inbounds nuw i8, ptr %5, i64 16
  %79 = load i64, ptr %78, align 8, !noalias !55
  %80 = icmp eq i64 %79, 0
  %81 = select i1 %77, i1 %80, i1 false
  br i1 %81, label %127, label %82

82:                                               ; preds = %74
  %83 = zext i64 %69 to i128
  %84 = zext i64 %79 to i128
  %85 = mul nuw i128 %84, %83
  %86 = trunc i128 %85 to i64
  %87 = lshr i128 %85, 64
  %88 = trunc nuw i128 %87 to i64
  %89 = zext i64 %71 to i128
  %90 = zext i64 %76 to i128
  %91 = mul nuw i128 %90, %89
  %92 = trunc i128 %91 to i64
  %93 = lshr i128 %91, 64
  %94 = trunc nuw i128 %93 to i64
  %95 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %86, i64 %92)
  %96 = extractvalue { i64, i1 } %95, 1
  %97 = zext i1 %96 to i64
  %98 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %88, i64 %94)
  %99 = extractvalue { i64, i1 } %98, 1
  %100 = extractvalue { i64, i1 } %98, 0
  %101 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %100, i64 %97)
  %102 = extractvalue { i64, i1 } %101, 1
  %103 = extractvalue { i64, i1 } %101, 0
  %104 = or i1 %99, %102
  %105 = zext i1 %104 to i64
  %106 = mul nuw i128 %84, %89
  %107 = trunc i128 %106 to i64
  %108 = lshr i128 %106, 64
  %109 = trunc nuw i128 %108 to i64
  %110 = call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %103, i64 %107)
  %111 = extractvalue { i64, i1 } %110, 1
  %112 = extractvalue { i64, i1 } %110, 0
  %113 = zext i1 %111 to i64
  %114 = add nuw i64 %105, %109
  %115 = add i64 %114, %113
  %116 = icmp sgt i64 %115, -1
  br i1 %116, label %117, label %127

117:                                              ; preds = %82
  %118 = add i32 %67, 127
  %119 = zext nneg i64 %115 to i128
  %120 = zext i64 %112 to i128
  %121 = shl nuw i128 %119, 65
  %122 = shl nuw nsw i128 %120, 1
  %123 = or disjoint i128 %121, %122
  %124 = trunc i128 %122 to i64
  %125 = lshr i128 %123, 64
  %126 = trunc nuw i128 %125 to i64
  br label %127

127:                                              ; preds = %61, %74, %82, %117
  %128 = phi i64 [ %115, %82 ], [ %126, %117 ], [ 0, %74 ], [ 0, %61 ]
  %129 = phi i32 [ %68, %82 ], [ %118, %117 ], [ %68, %74 ], [ %68, %61 ]
  %130 = phi i64 [ %112, %82 ], [ %124, %117 ], [ 0, %74 ], [ 0, %61 ]
  %131 = xor i8 %63, %62
  %132 = and i8 %131, 1
  store i8 %132, ptr %1, align 8, !tbaa !17
  %133 = getelementptr inbounds nuw i8, ptr %1, i64 4
  store i32 %129, ptr %133, align 4, !tbaa !20
  %134 = getelementptr inbounds nuw i8, ptr %1, i64 8
  store i64 %130, ptr %134, align 8
  %135 = getelementptr inbounds nuw i8, ptr %1, i64 16
  store i64 %128, ptr %135, align 8, !tbaa !21
  call void @llvm.lifetime.end.p0(ptr nonnull %5) #9
  call void @llvm.lifetime.start.p0(ptr nonnull %6) #9
  call fastcc void @_ZN11__llvm_libc6fputilL8polyevalINS0_11DyadicFloatILm128EEEJS3_S3_S3_S3_S3_S3_EEENS_3cpp9enable_ifIXgtstT_Lm8EES6_E4typeERKS6_SA_DpRKT0_(ptr dead_on_unwind noalias writable align 8 %6, ptr noundef nonnull align 8 dereferenceable(24) %4, ptr noundef nonnull align 8 dereferenceable(24) @__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.COS_COEFFS, ptr noundef nonnull align 8 dereferenceable(24) getelementptr inbounds nuw (i8, ptr @__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.COS_COEFFS, i64 24), ptr noundef nonnull align 8 dereferenceable(24) getelementptr inbounds nuw (i8, ptr @__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.COS_COEFFS, i64 48), ptr noundef nonnull align 8 dereferenceable(24) getelementptr inbounds nuw (i8, ptr @__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.COS_COEFFS, i64 72), ptr noundef nonnull align 8 dereferenceable(24) getelementptr inbounds nuw (i8, ptr @__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.COS_COEFFS, i64 96), ptr noundef nonnull align 8 dereferenceable(24) getelementptr inbounds nuw (i8, ptr @__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.COS_COEFFS, i64 120), ptr noundef nonnull align 8 dereferenceable(24) getelementptr inbounds nuw (i8, ptr @__const._ZN11__llvm_libc4math20sincos_eval_internal11sincos_evalERKNS_6fputil11DyadicFloatILm128EEERS4_S7_.COS_COEFFS, i64 144))
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %2, ptr noundef nonnull align 8 dereferenceable(24) %6, i64 24, i1 false), !tbaa.struct !19
  call void @llvm.lifetime.end.p0(ptr nonnull %6) #9
  call void @llvm.lifetime.end.p0(ptr nonnull %4) #9
  ret void
}

; Function Attrs: inlinehint mustprogress sspstrong uwtable
define linkonce_odr hidden void @_ZN11__llvm_libc6fputil9quick_addILm128EEENS0_11DyadicFloatIXT_EEES3_S3_(ptr dead_on_unwind noalias writable sret(%"struct.__llvm_libc::fputil::DyadicFloat") align 8 %0, ptr noundef byval(%"struct.__llvm_libc::fputil::DyadicFloat") align 8 %1, ptr noundef byval(%"struct.__llvm_libc::fputil::DyadicFloat") align 8 %2) local_unnamed_addr #1 comdat {
  %4 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %5 = load i64, ptr %4, align 8, !tbaa !30
  %6 = icmp eq i64 %5, 0
  %7 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %8 = load i64, ptr %7, align 8
  %9 = icmp eq i64 %8, 0
  %10 = select i1 %6, i1 %9, i1 false
  br i1 %10, label %11, label %12, !prof !11

11:                                               ; preds = %3
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %0, ptr noundef nonnull align 8 dereferenceable(24) %2, i64 24, i1 false), !tbaa.struct !19
  br label %149

12:                                               ; preds = %3
  %13 = getelementptr inbounds nuw i8, ptr %2, i64 8
  %14 = load i64, ptr %13, align 8, !tbaa !30
  %15 = icmp eq i64 %14, 0
  %16 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %17 = load i64, ptr %16, align 8
  %18 = icmp eq i64 %17, 0
  %19 = select i1 %15, i1 %18, i1 false
  br i1 %19, label %20, label %21, !prof !11

20:                                               ; preds = %12
  call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 8 dereferenceable(24) %0, ptr noundef nonnull align 8 dereferenceable(24) %1, i64 24, i1 false), !tbaa.struct !19
  br label %149

21:                                               ; preds = %12
  %22 = getelementptr inbounds nuw i8, ptr %1, i64 4
  %23 = load i32, ptr %22, align 4, !tbaa !25
  %24 = getelementptr inbounds nuw i8, ptr %2, i64 4
  %25 = load i32, ptr %24, align 4, !tbaa !25
  %26 = icmp sgt i32 %23, %25
  br i1 %26, label %27, label %40

27:                                               ; preds = %21
  %28 = sub i32 %23, %25
  %29 = icmp ult i32 %28, 128
  br i1 %29, label %30, label %55

30:                                               ; preds = %27
  %31 = zext i64 %17 to i128
  %32 = shl nuw i128 %31, 64
  %33 = zext i64 %14 to i128
  %34 = or disjoint i128 %32, %33
  %35 = zext nneg i32 %28 to i128
  %36 = lshr i128 %34, %35
  %37 = trunc i128 %36 to i64
  %38 = lshr i128 %36, 64
  %39 = trunc nuw i128 %38 to i64
  br label %55

40:                                               ; preds = %21
  %41 = icmp sgt i32 %25, %23
  br i1 %41, label %42, label %55

42:                                               ; preds = %40
  %43 = sub i32 %25, %23
  %44 = icmp ult i32 %43, 128
  br i1 %44, label %45, label %55

45:                                               ; preds = %42
  %46 = zext i64 %8 to i128
  %47 = shl nuw i128 %46, 64
  %48 = zext i64 %5 to i128
  %49 = or disjoint i128 %47, %48
  %50 = zext nneg i32 %43 to i128
  %51 = lshr i128 %49, %50
  %52 = trunc i128 %51 to i64
  %53 = lshr i128 %51, 64
  %54 = trunc nuw i128 %53 to i64
  br label %55

55:                                               ; preds = %42, %27, %45, %30, %40
  %56 = phi i32 [ %23, %27 ], [ %25, %45 ], [ %23, %40 ], [ %23, %30 ], [ %25, %42 ]
  %57 = phi i32 [ %23, %27 ], [ %25, %45 ], [ %25, %40 ], [ %23, %30 ], [ %25, %42 ]
  %58 = phi i64 [ 0, %27 ], [ %14, %45 ], [ %14, %40 ], [ %37, %30 ], [ %14, %42 ]
  %59 = phi i64 [ %5, %27 ], [ %52, %45 ], [ %5, %40 ], [ %5, %30 ], [ 0, %42 ]
  %60 = phi i64 [ 0, %27 ], [ %17, %45 ], [ %17, %40 ], [ %39, %30 ], [ %17, %42 ]
  %61 = phi i64 [ %8, %27 ], [ %54, %45 ], [ %8, %40 ], [ %8, %30 ], [ 0, %42 ]
  %62 = load i8, ptr %1, align 8, !tbaa !17
  %63 = load i8, ptr %2, align 8, !tbaa !17
  %64 = xor i8 %63, %62
  %65 = and i8 %64, 1
  %66 = icmp eq i8 %65, 0
  br i1 %66, label %67, label %96

67:                                               ; preds = %55
  %68 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %59, i64 %58)
  %69 = extractvalue { i64, i1 } %68, 1
  %70 = extractvalue { i64, i1 } %68, 0
  %71 = zext i1 %69 to i64
  %72 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %61, i64 %60)
  %73 = extractvalue { i64, i1 } %72, 1
  %74 = extractvalue { i64, i1 } %72, 0
  %75 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %74, i64 %71)
  %76 = extractvalue { i64, i1 } %75, 1
  %77 = extractvalue { i64, i1 } %75, 0
  %78 = or i1 %73, %76
  br i1 %78, label %79, label %89

79:                                               ; preds = %67
  %80 = add i32 %56, 1
  %81 = zext i64 %77 to i128
  %82 = shl nuw i128 %81, 64
  %83 = zext i64 %70 to i128
  %84 = or disjoint i128 %82, %83
  %85 = lshr i128 %84, 1
  %86 = trunc i128 %85 to i64
  %87 = lshr i64 %77, 1
  %88 = or disjoint i64 %87, -9223372036854775808
  br label %89

89:                                               ; preds = %79, %67
  %90 = phi i32 [ %56, %67 ], [ %80, %79 ]
  %91 = phi i64 [ %70, %67 ], [ %86, %79 ]
  %92 = phi i64 [ %77, %67 ], [ %88, %79 ]
  store i8 %62, ptr %0, align 8, !tbaa !17
  %93 = getelementptr inbounds nuw i8, ptr %0, i64 4
  store i32 %90, ptr %93, align 4, !tbaa !20
  %94 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %91, ptr %94, align 8
  %95 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %92, ptr %95, align 8, !tbaa !21
  br label %149

96:                                               ; preds = %55
  %97 = icmp eq i64 %61, %60
  br i1 %97, label %98, label %100

98:                                               ; preds = %96
  %99 = icmp eq i64 %59, %58
  br i1 %99, label %104, label %100

100:                                              ; preds = %96, %98
  %101 = phi i64 [ %61, %96 ], [ %59, %98 ]
  %102 = phi i64 [ %60, %96 ], [ %58, %98 ]
  %103 = icmp ult i64 %101, %102
  br i1 %103, label %110, label %104

104:                                              ; preds = %98, %100
  %105 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %59, i64 %58)
  %106 = extractvalue { i64, i1 } %105, 1
  %107 = sext i1 %106 to i64
  %108 = sub i64 %61, %60
  %109 = add i64 %108, %107
  br label %116

110:                                              ; preds = %100
  %111 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %58, i64 %59)
  %112 = extractvalue { i64, i1 } %111, 1
  %113 = sext i1 %112 to i64
  %114 = sub i64 %60, %61
  %115 = add i64 %114, %113
  br label %116

116:                                              ; preds = %110, %104
  %117 = phi i32 [ %56, %104 ], [ %57, %110 ]
  %118 = phi { i64, i1 } [ %105, %104 ], [ %111, %110 ]
  %119 = phi i64 [ %109, %104 ], [ %115, %110 ]
  %120 = phi i8 [ %62, %104 ], [ %63, %110 ]
  %121 = extractvalue { i64, i1 } %118, 0
  %122 = icmp eq i64 %121, 0
  %123 = icmp eq i64 %119, 0
  %124 = select i1 %122, i1 %123, i1 false
  br i1 %124, label %142, label %125

125:                                              ; preds = %116
  %126 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %119, i1 false)
  %127 = trunc nuw nsw i64 %126 to i32
  %128 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %121, i1 false)
  %129 = trunc nuw nsw i64 %128 to i32
  %130 = select i1 %123, i32 %129, i32 0
  %131 = add nuw nsw i32 %130, %127
  %132 = sub i32 %117, %131
  %133 = zext i64 %119 to i128
  %134 = shl nuw i128 %133, 64
  %135 = zext i64 %121 to i128
  %136 = or disjoint i128 %134, %135
  %137 = zext nneg i32 %131 to i128
  %138 = shl i128 %136, %137
  %139 = trunc i128 %138 to i64
  %140 = lshr i128 %138, 64
  %141 = trunc nuw i128 %140 to i64
  br label %142

142:                                              ; preds = %116, %125
  %143 = phi i32 [ %117, %116 ], [ %132, %125 ]
  %144 = phi i64 [ 0, %116 ], [ %139, %125 ]
  %145 = phi i64 [ 0, %116 ], [ %141, %125 ]
  store i8 %120, ptr %0, align 8, !tbaa !17
  %146 = getelementptr inbounds nuw i8, ptr %0, i64 4
  store i32 %143, ptr %146, align 4, !tbaa !20
  %147 = getelementptr inbounds nuw i8, ptr %0, i64 8
  store i64 %144, ptr %147, align 8
  %148 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store i64 %145, ptr %148, align 8, !tbaa !21
  br label %149

149:                                              ; preds = %89, %142, %20, %11
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.ctlz.i64(i64, i1 immarg) #6

; Function Attrs: inlinehint mustprogress sspstrong uwtable
define internal fastcc void @_ZN11__llvm_libc6fputilL8polyevalINS0_11DyadicFloatILm128EEEJS3_S3_S3_S3_S3_S3_EEENS_3cpp9enable_ifIXgtstT_Lm8EES6_E4typeERKS6_SA_DpRKT0_(ptr dead_on_unwind noalias nonnull writable align 8 %0, ptr nofree noundef nonnull readonly align 8 captures(none) dereferenceable(24) %1, ptr nofree noundef nonnull readonly align 8 captures(none) dereferenceable(24) %2, ptr nofree noundef nonnull readonly align 8 captures(none) dereferenceable(24) %3, ptr nofree noundef nonnull readonly align 8 captures(none) dereferenceable(24) %4, ptr nofree noundef nonnull readonly align 8 captures(none) dereferenceable(24) %5, ptr nofree noundef nonnull readonly align 8 captures(none) dereferenceable(24) %6, ptr nofree noundef nonnull readonly align 8 captures(none) dereferenceable(24) %7, ptr nofree noundef nonnull readonly align 8 captures(none) dereferenceable(24) %8) unnamed_addr #1 {
  %10 = alloca %"struct.__llvm_libc::fputil::DyadicFloat", align 8
  %11 = load i8, ptr %8, align 8, !tbaa !17, !noalias !58
  %12 = getelementptr inbounds nuw i8, ptr %8, i64 4
  %13 = load i32, ptr %12, align 4, !tbaa !20, !noalias !58
  %14 = getelementptr inbounds nuw i8, ptr %8, i64 8
  %15 = load i64, ptr %14, align 8, !noalias !58
  %16 = getelementptr inbounds nuw i8, ptr %8, i64 16
  %17 = load i64, ptr %16, align 8, !tbaa !21, !noalias !58
  %18 = load i8, ptr %1, align 8, !tbaa !17, !noalias !69
  %19 = xor i8 %18, %11
  %20 = getelementptr inbounds nuw i8, ptr %1, i64 4
  %21 = load i32, ptr %20, align 4, !tbaa !25, !noalias !69
  %22 = add i32 %21, %13
  %23 = add i32 %22, 128
  %24 = getelementptr inbounds nuw i8, ptr %1, i64 8
  %25 = load i64, ptr %24, align 8, !tbaa !30, !noalias !69
  %26 = icmp eq i64 %25, 0
  %27 = getelementptr inbounds nuw i8, ptr %1, i64 16
  %28 = load i64, ptr %27, align 8, !noalias !69
  %29 = icmp eq i64 %28, 0
  %30 = select i1 %26, i1 %29, i1 false
  br i1 %30, label %80, label %31

31:                                               ; preds = %9
  %32 = icmp eq i64 %15, 0
  %33 = icmp eq i64 %17, 0
  %34 = select i1 %32, i1 %33, i1 false
  br i1 %34, label %80, label %35

35:                                               ; preds = %31
  %36 = zext i64 %25 to i128
  %37 = zext i64 %17 to i128
  %38 = mul nuw i128 %36, %37
  %39 = trunc i128 %38 to i64
  %40 = lshr i128 %38, 64
  %41 = trunc nuw i128 %40 to i64
  %42 = zext i64 %28 to i128
  %43 = zext i64 %15 to i128
  %44 = mul nuw i128 %42, %43
  %45 = trunc i128 %44 to i64
  %46 = lshr i128 %44, 64
  %47 = trunc nuw i128 %46 to i64
  %48 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %39, i64 %45)
  %49 = extractvalue { i64, i1 } %48, 1
  %50 = zext i1 %49 to i64
  %51 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %41, i64 %47)
  %52 = extractvalue { i64, i1 } %51, 1
  %53 = extractvalue { i64, i1 } %51, 0
  %54 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %53, i64 %50)
  %55 = extractvalue { i64, i1 } %54, 1
  %56 = extractvalue { i64, i1 } %54, 0
  %57 = or i1 %52, %55
  %58 = zext i1 %57 to i64
  %59 = mul nuw i128 %42, %37
  %60 = trunc i128 %59 to i64
  %61 = lshr i128 %59, 64
  %62 = trunc nuw i128 %61 to i64
  %63 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %56, i64 %60)
  %64 = extractvalue { i64, i1 } %63, 1
  %65 = extractvalue { i64, i1 } %63, 0
  %66 = zext i1 %64 to i64
  %67 = add nuw i64 %58, %62
  %68 = add i64 %67, %66
  %69 = icmp sgt i64 %68, -1
  br i1 %69, label %70, label %80

70:                                               ; preds = %35
  %71 = add i32 %22, 127
  %72 = zext nneg i64 %68 to i128
  %73 = zext i64 %65 to i128
  %74 = shl nuw i128 %72, 65
  %75 = shl nuw nsw i128 %73, 1
  %76 = or disjoint i128 %74, %75
  %77 = trunc i128 %75 to i64
  %78 = lshr i128 %76, 64
  %79 = trunc nuw i128 %78 to i64
  br label %80

80:                                               ; preds = %70, %35, %31, %9
  %81 = phi i64 [ %68, %35 ], [ %79, %70 ], [ 0, %31 ], [ 0, %9 ]
  %82 = phi i32 [ %23, %35 ], [ %71, %70 ], [ %23, %31 ], [ %23, %9 ]
  %83 = phi i64 [ %65, %35 ], [ %77, %70 ], [ 0, %31 ], [ 0, %9 ]
  %84 = load i8, ptr %7, align 8, !noalias !74
  %85 = getelementptr inbounds nuw i8, ptr %7, i64 4
  %86 = load i32, ptr %85, align 4, !noalias !74
  %87 = getelementptr inbounds nuw i8, ptr %7, i64 8
  %88 = load i64, ptr %87, align 8, !noalias !74
  %89 = getelementptr inbounds nuw i8, ptr %7, i64 16
  %90 = load i64, ptr %89, align 8, !noalias !74
  %91 = icmp eq i64 %88, 0
  %92 = icmp eq i64 %90, 0
  %93 = select i1 %91, i1 %92, i1 false
  br i1 %93, label %206, label %94, !prof !11

94:                                               ; preds = %80
  %95 = icmp eq i64 %83, 0
  %96 = icmp eq i64 %81, 0
  %97 = select i1 %95, i1 %96, i1 false
  br i1 %97, label %206, label %98, !prof !11

98:                                               ; preds = %94
  %99 = icmp sgt i32 %86, %82
  br i1 %99, label %100, label %113

100:                                              ; preds = %98
  %101 = sub i32 %86, %82
  %102 = icmp ult i32 %101, 128
  br i1 %102, label %103, label %128

103:                                              ; preds = %100
  %104 = zext i64 %81 to i128
  %105 = shl nuw i128 %104, 64
  %106 = zext i64 %83 to i128
  %107 = or disjoint i128 %105, %106
  %108 = zext nneg i32 %101 to i128
  %109 = lshr i128 %107, %108
  %110 = trunc i128 %109 to i64
  %111 = lshr i128 %109, 64
  %112 = trunc nuw i128 %111 to i64
  br label %128

113:                                              ; preds = %98
  %114 = icmp sgt i32 %82, %86
  br i1 %114, label %115, label %128

115:                                              ; preds = %113
  %116 = sub i32 %82, %86
  %117 = icmp ult i32 %116, 128
  br i1 %117, label %118, label %128

118:                                              ; preds = %115
  %119 = zext i64 %90 to i128
  %120 = shl nuw i128 %119, 64
  %121 = zext i64 %88 to i128
  %122 = or disjoint i128 %120, %121
  %123 = zext nneg i32 %116 to i128
  %124 = lshr i128 %122, %123
  %125 = trunc i128 %124 to i64
  %126 = lshr i128 %124, 64
  %127 = trunc nuw i128 %126 to i64
  br label %128

128:                                              ; preds = %118, %115, %113, %103, %100
  %129 = phi i32 [ %86, %100 ], [ %82, %118 ], [ %86, %113 ], [ %86, %103 ], [ %82, %115 ]
  %130 = phi i32 [ %86, %100 ], [ %82, %118 ], [ %82, %113 ], [ %86, %103 ], [ %82, %115 ]
  %131 = phi i64 [ 0, %100 ], [ %83, %118 ], [ %83, %113 ], [ %110, %103 ], [ %83, %115 ]
  %132 = phi i64 [ %88, %100 ], [ %125, %118 ], [ %88, %113 ], [ %88, %103 ], [ 0, %115 ]
  %133 = phi i64 [ 0, %100 ], [ %81, %118 ], [ %81, %113 ], [ %112, %103 ], [ %81, %115 ]
  %134 = phi i64 [ %90, %100 ], [ %127, %118 ], [ %90, %113 ], [ %90, %103 ], [ 0, %115 ]
  %135 = xor i8 %84, %19
  %136 = and i8 %135, 1
  %137 = icmp eq i8 %136, 0
  br i1 %137, label %138, label %160

138:                                              ; preds = %128
  %139 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %132, i64 %131)
  %140 = extractvalue { i64, i1 } %139, 1
  %141 = extractvalue { i64, i1 } %139, 0
  %142 = zext i1 %140 to i64
  %143 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %134, i64 %133)
  %144 = extractvalue { i64, i1 } %143, 1
  %145 = extractvalue { i64, i1 } %143, 0
  %146 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %145, i64 %142)
  %147 = extractvalue { i64, i1 } %146, 1
  %148 = extractvalue { i64, i1 } %146, 0
  %149 = or i1 %144, %147
  br i1 %149, label %150, label %206

150:                                              ; preds = %138
  %151 = add i32 %129, 1
  %152 = zext i64 %148 to i128
  %153 = shl nuw i128 %152, 64
  %154 = zext i64 %141 to i128
  %155 = or disjoint i128 %153, %154
  %156 = lshr i128 %155, 1
  %157 = trunc i128 %156 to i64
  %158 = lshr i64 %148, 1
  %159 = or disjoint i64 %158, -9223372036854775808
  br label %206

160:                                              ; preds = %128
  %161 = icmp eq i64 %134, %133
  br i1 %161, label %162, label %164

162:                                              ; preds = %160
  %163 = icmp eq i64 %132, %131
  br i1 %163, label %168, label %164

164:                                              ; preds = %162, %160
  %165 = phi i64 [ %134, %160 ], [ %132, %162 ]
  %166 = phi i64 [ %133, %160 ], [ %131, %162 ]
  %167 = icmp ult i64 %165, %166
  br i1 %167, label %174, label %168

168:                                              ; preds = %164, %162
  %169 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %132, i64 %131)
  %170 = extractvalue { i64, i1 } %169, 1
  %171 = sext i1 %170 to i64
  %172 = sub i64 %134, %133
  %173 = add i64 %172, %171
  br label %180

174:                                              ; preds = %164
  %175 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %131, i64 %132)
  %176 = extractvalue { i64, i1 } %175, 1
  %177 = sext i1 %176 to i64
  %178 = sub i64 %133, %134
  %179 = add i64 %178, %177
  br label %180

180:                                              ; preds = %174, %168
  %181 = phi i32 [ %129, %168 ], [ %130, %174 ]
  %182 = phi { i64, i1 } [ %169, %168 ], [ %175, %174 ]
  %183 = phi i64 [ %173, %168 ], [ %179, %174 ]
  %184 = phi i8 [ %84, %168 ], [ %19, %174 ]
  %185 = extractvalue { i64, i1 } %182, 0
  %186 = icmp eq i64 %185, 0
  %187 = icmp eq i64 %183, 0
  %188 = select i1 %186, i1 %187, i1 false
  br i1 %188, label %206, label %189

189:                                              ; preds = %180
  %190 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %183, i1 false)
  %191 = trunc nuw nsw i64 %190 to i32
  %192 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %185, i1 false)
  %193 = trunc nuw nsw i64 %192 to i32
  %194 = select i1 %187, i32 %193, i32 0
  %195 = add nuw nsw i32 %194, %191
  %196 = sub i32 %181, %195
  %197 = zext i64 %183 to i128
  %198 = shl nuw i128 %197, 64
  %199 = zext i64 %185 to i128
  %200 = or disjoint i128 %198, %199
  %201 = zext nneg i32 %195 to i128
  %202 = shl i128 %200, %201
  %203 = trunc i128 %202 to i64
  %204 = lshr i128 %202, 64
  %205 = trunc nuw i128 %204 to i64
  br label %206

206:                                              ; preds = %189, %180, %150, %138, %94, %80
  %207 = phi i64 [ %205, %189 ], [ %81, %80 ], [ %159, %150 ], [ %148, %138 ], [ 0, %180 ], [ %90, %94 ]
  %208 = phi i64 [ %203, %189 ], [ %83, %80 ], [ %157, %150 ], [ %141, %138 ], [ 0, %180 ], [ %88, %94 ]
  %209 = phi i32 [ %196, %189 ], [ %82, %80 ], [ %151, %150 ], [ %129, %138 ], [ %181, %180 ], [ %86, %94 ]
  %210 = phi i8 [ %184, %189 ], [ %19, %80 ], [ %84, %150 ], [ %84, %138 ], [ %184, %180 ], [ %84, %94 ]
  %211 = xor i8 %210, %18
  %212 = add i32 %209, %21
  %213 = add i32 %212, 128
  br i1 %30, label %263, label %214

214:                                              ; preds = %206
  %215 = icmp eq i64 %208, 0
  %216 = icmp eq i64 %207, 0
  %217 = select i1 %215, i1 %216, i1 false
  br i1 %217, label %263, label %218

218:                                              ; preds = %214
  %219 = zext i64 %25 to i128
  %220 = zext i64 %207 to i128
  %221 = mul nuw i128 %220, %219
  %222 = trunc i128 %221 to i64
  %223 = lshr i128 %221, 64
  %224 = trunc nuw i128 %223 to i64
  %225 = zext i64 %28 to i128
  %226 = zext i64 %208 to i128
  %227 = mul nuw i128 %226, %225
  %228 = trunc i128 %227 to i64
  %229 = lshr i128 %227, 64
  %230 = trunc nuw i128 %229 to i64
  %231 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %222, i64 %228)
  %232 = extractvalue { i64, i1 } %231, 1
  %233 = zext i1 %232 to i64
  %234 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %224, i64 %230)
  %235 = extractvalue { i64, i1 } %234, 1
  %236 = extractvalue { i64, i1 } %234, 0
  %237 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %236, i64 %233)
  %238 = extractvalue { i64, i1 } %237, 1
  %239 = extractvalue { i64, i1 } %237, 0
  %240 = or i1 %235, %238
  %241 = zext i1 %240 to i64
  %242 = mul nuw i128 %220, %225
  %243 = trunc i128 %242 to i64
  %244 = lshr i128 %242, 64
  %245 = trunc nuw i128 %244 to i64
  %246 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %239, i64 %243)
  %247 = extractvalue { i64, i1 } %246, 1
  %248 = extractvalue { i64, i1 } %246, 0
  %249 = zext i1 %247 to i64
  %250 = add nuw i64 %241, %245
  %251 = add i64 %250, %249
  %252 = icmp sgt i64 %251, -1
  br i1 %252, label %253, label %263

253:                                              ; preds = %218
  %254 = add i32 %212, 127
  %255 = zext nneg i64 %251 to i128
  %256 = zext i64 %248 to i128
  %257 = shl nuw i128 %255, 65
  %258 = shl nuw nsw i128 %256, 1
  %259 = or disjoint i128 %257, %258
  %260 = trunc i128 %258 to i64
  %261 = lshr i128 %259, 64
  %262 = trunc nuw i128 %261 to i64
  br label %263

263:                                              ; preds = %253, %218, %214, %206
  %264 = phi i64 [ %251, %218 ], [ %262, %253 ], [ 0, %214 ], [ 0, %206 ]
  %265 = phi i32 [ %213, %218 ], [ %254, %253 ], [ %213, %214 ], [ %213, %206 ]
  %266 = phi i64 [ %248, %218 ], [ %260, %253 ], [ 0, %214 ], [ 0, %206 ]
  %267 = load i8, ptr %6, align 8, !noalias !75
  %268 = getelementptr inbounds nuw i8, ptr %6, i64 4
  %269 = load i32, ptr %268, align 4, !noalias !75
  %270 = getelementptr inbounds nuw i8, ptr %6, i64 8
  %271 = load i64, ptr %270, align 8, !noalias !75
  %272 = getelementptr inbounds nuw i8, ptr %6, i64 16
  %273 = load i64, ptr %272, align 8, !noalias !75
  %274 = icmp eq i64 %271, 0
  %275 = icmp eq i64 %273, 0
  %276 = select i1 %274, i1 %275, i1 false
  br i1 %276, label %389, label %277, !prof !11

277:                                              ; preds = %263
  %278 = icmp eq i64 %266, 0
  %279 = icmp eq i64 %264, 0
  %280 = select i1 %278, i1 %279, i1 false
  br i1 %280, label %389, label %281, !prof !11

281:                                              ; preds = %277
  %282 = icmp sgt i32 %269, %265
  br i1 %282, label %283, label %296

283:                                              ; preds = %281
  %284 = sub i32 %269, %265
  %285 = icmp ult i32 %284, 128
  br i1 %285, label %286, label %311

286:                                              ; preds = %283
  %287 = zext i64 %264 to i128
  %288 = shl nuw i128 %287, 64
  %289 = zext i64 %266 to i128
  %290 = or disjoint i128 %288, %289
  %291 = zext nneg i32 %284 to i128
  %292 = lshr i128 %290, %291
  %293 = trunc i128 %292 to i64
  %294 = lshr i128 %292, 64
  %295 = trunc nuw i128 %294 to i64
  br label %311

296:                                              ; preds = %281
  %297 = icmp sgt i32 %265, %269
  br i1 %297, label %298, label %311

298:                                              ; preds = %296
  %299 = sub i32 %265, %269
  %300 = icmp ult i32 %299, 128
  br i1 %300, label %301, label %311

301:                                              ; preds = %298
  %302 = zext i64 %273 to i128
  %303 = shl nuw i128 %302, 64
  %304 = zext i64 %271 to i128
  %305 = or disjoint i128 %303, %304
  %306 = zext nneg i32 %299 to i128
  %307 = lshr i128 %305, %306
  %308 = trunc i128 %307 to i64
  %309 = lshr i128 %307, 64
  %310 = trunc nuw i128 %309 to i64
  br label %311

311:                                              ; preds = %301, %298, %296, %286, %283
  %312 = phi i32 [ %269, %283 ], [ %265, %301 ], [ %269, %296 ], [ %269, %286 ], [ %265, %298 ]
  %313 = phi i32 [ %269, %283 ], [ %265, %301 ], [ %265, %296 ], [ %269, %286 ], [ %265, %298 ]
  %314 = phi i64 [ 0, %283 ], [ %266, %301 ], [ %266, %296 ], [ %293, %286 ], [ %266, %298 ]
  %315 = phi i64 [ %271, %283 ], [ %308, %301 ], [ %271, %296 ], [ %271, %286 ], [ 0, %298 ]
  %316 = phi i64 [ 0, %283 ], [ %264, %301 ], [ %264, %296 ], [ %295, %286 ], [ %264, %298 ]
  %317 = phi i64 [ %273, %283 ], [ %310, %301 ], [ %273, %296 ], [ %273, %286 ], [ 0, %298 ]
  %318 = xor i8 %267, %211
  %319 = and i8 %318, 1
  %320 = icmp eq i8 %319, 0
  br i1 %320, label %321, label %343

321:                                              ; preds = %311
  %322 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %315, i64 %314)
  %323 = extractvalue { i64, i1 } %322, 1
  %324 = extractvalue { i64, i1 } %322, 0
  %325 = zext i1 %323 to i64
  %326 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %317, i64 %316)
  %327 = extractvalue { i64, i1 } %326, 1
  %328 = extractvalue { i64, i1 } %326, 0
  %329 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %328, i64 %325)
  %330 = extractvalue { i64, i1 } %329, 1
  %331 = extractvalue { i64, i1 } %329, 0
  %332 = or i1 %327, %330
  br i1 %332, label %333, label %389

333:                                              ; preds = %321
  %334 = add i32 %312, 1
  %335 = zext i64 %331 to i128
  %336 = shl nuw i128 %335, 64
  %337 = zext i64 %324 to i128
  %338 = or disjoint i128 %336, %337
  %339 = lshr i128 %338, 1
  %340 = trunc i128 %339 to i64
  %341 = lshr i64 %331, 1
  %342 = or disjoint i64 %341, -9223372036854775808
  br label %389

343:                                              ; preds = %311
  %344 = icmp eq i64 %317, %316
  br i1 %344, label %345, label %347

345:                                              ; preds = %343
  %346 = icmp eq i64 %315, %314
  br i1 %346, label %351, label %347

347:                                              ; preds = %345, %343
  %348 = phi i64 [ %317, %343 ], [ %315, %345 ]
  %349 = phi i64 [ %316, %343 ], [ %314, %345 ]
  %350 = icmp ult i64 %348, %349
  br i1 %350, label %357, label %351

351:                                              ; preds = %347, %345
  %352 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %315, i64 %314)
  %353 = extractvalue { i64, i1 } %352, 1
  %354 = sext i1 %353 to i64
  %355 = sub i64 %317, %316
  %356 = add i64 %355, %354
  br label %363

357:                                              ; preds = %347
  %358 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %314, i64 %315)
  %359 = extractvalue { i64, i1 } %358, 1
  %360 = sext i1 %359 to i64
  %361 = sub i64 %316, %317
  %362 = add i64 %361, %360
  br label %363

363:                                              ; preds = %357, %351
  %364 = phi i32 [ %312, %351 ], [ %313, %357 ]
  %365 = phi { i64, i1 } [ %352, %351 ], [ %358, %357 ]
  %366 = phi i64 [ %356, %351 ], [ %362, %357 ]
  %367 = phi i8 [ %267, %351 ], [ %211, %357 ]
  %368 = extractvalue { i64, i1 } %365, 0
  %369 = icmp eq i64 %368, 0
  %370 = icmp eq i64 %366, 0
  %371 = select i1 %369, i1 %370, i1 false
  br i1 %371, label %389, label %372

372:                                              ; preds = %363
  %373 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %366, i1 false)
  %374 = trunc nuw nsw i64 %373 to i32
  %375 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %368, i1 false)
  %376 = trunc nuw nsw i64 %375 to i32
  %377 = select i1 %370, i32 %376, i32 0
  %378 = add nuw nsw i32 %377, %374
  %379 = sub i32 %364, %378
  %380 = zext i64 %366 to i128
  %381 = shl nuw i128 %380, 64
  %382 = zext i64 %368 to i128
  %383 = or disjoint i128 %381, %382
  %384 = zext nneg i32 %378 to i128
  %385 = shl i128 %383, %384
  %386 = trunc i128 %385 to i64
  %387 = lshr i128 %385, 64
  %388 = trunc nuw i128 %387 to i64
  br label %389

389:                                              ; preds = %372, %363, %333, %321, %277, %263
  %390 = phi i64 [ %388, %372 ], [ %264, %263 ], [ %342, %333 ], [ %331, %321 ], [ 0, %363 ], [ %273, %277 ]
  %391 = phi i64 [ %386, %372 ], [ %266, %263 ], [ %340, %333 ], [ %324, %321 ], [ 0, %363 ], [ %271, %277 ]
  %392 = phi i32 [ %379, %372 ], [ %265, %263 ], [ %334, %333 ], [ %312, %321 ], [ %364, %363 ], [ %269, %277 ]
  %393 = phi i8 [ %367, %372 ], [ %211, %263 ], [ %267, %333 ], [ %267, %321 ], [ %367, %363 ], [ %267, %277 ]
  %394 = xor i8 %393, %18
  %395 = add i32 %392, %21
  %396 = add i32 %395, 128
  br i1 %30, label %446, label %397

397:                                              ; preds = %389
  %398 = icmp eq i64 %391, 0
  %399 = icmp eq i64 %390, 0
  %400 = select i1 %398, i1 %399, i1 false
  br i1 %400, label %446, label %401

401:                                              ; preds = %397
  %402 = zext i64 %25 to i128
  %403 = zext i64 %390 to i128
  %404 = mul nuw i128 %403, %402
  %405 = trunc i128 %404 to i64
  %406 = lshr i128 %404, 64
  %407 = trunc nuw i128 %406 to i64
  %408 = zext i64 %28 to i128
  %409 = zext i64 %391 to i128
  %410 = mul nuw i128 %409, %408
  %411 = trunc i128 %410 to i64
  %412 = lshr i128 %410, 64
  %413 = trunc nuw i128 %412 to i64
  %414 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %405, i64 %411)
  %415 = extractvalue { i64, i1 } %414, 1
  %416 = zext i1 %415 to i64
  %417 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %407, i64 %413)
  %418 = extractvalue { i64, i1 } %417, 1
  %419 = extractvalue { i64, i1 } %417, 0
  %420 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %419, i64 %416)
  %421 = extractvalue { i64, i1 } %420, 1
  %422 = extractvalue { i64, i1 } %420, 0
  %423 = or i1 %418, %421
  %424 = zext i1 %423 to i64
  %425 = mul nuw i128 %403, %408
  %426 = trunc i128 %425 to i64
  %427 = lshr i128 %425, 64
  %428 = trunc nuw i128 %427 to i64
  %429 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %422, i64 %426)
  %430 = extractvalue { i64, i1 } %429, 1
  %431 = extractvalue { i64, i1 } %429, 0
  %432 = zext i1 %430 to i64
  %433 = add nuw i64 %424, %428
  %434 = add i64 %433, %432
  %435 = icmp sgt i64 %434, -1
  br i1 %435, label %436, label %446

436:                                              ; preds = %401
  %437 = add i32 %395, 127
  %438 = zext nneg i64 %434 to i128
  %439 = zext i64 %431 to i128
  %440 = shl nuw i128 %438, 65
  %441 = shl nuw nsw i128 %439, 1
  %442 = or disjoint i128 %440, %441
  %443 = trunc i128 %441 to i64
  %444 = lshr i128 %442, 64
  %445 = trunc nuw i128 %444 to i64
  br label %446

446:                                              ; preds = %436, %401, %397, %389
  %447 = phi i64 [ %434, %401 ], [ %445, %436 ], [ 0, %397 ], [ 0, %389 ]
  %448 = phi i32 [ %396, %401 ], [ %437, %436 ], [ %396, %397 ], [ %396, %389 ]
  %449 = phi i64 [ %431, %401 ], [ %443, %436 ], [ 0, %397 ], [ 0, %389 ]
  %450 = load i8, ptr %5, align 8, !noalias !76
  %451 = getelementptr inbounds nuw i8, ptr %5, i64 4
  %452 = load i32, ptr %451, align 4, !noalias !76
  %453 = getelementptr inbounds nuw i8, ptr %5, i64 8
  %454 = load i64, ptr %453, align 8, !noalias !76
  %455 = getelementptr inbounds nuw i8, ptr %5, i64 16
  %456 = load i64, ptr %455, align 8, !noalias !76
  %457 = icmp eq i64 %454, 0
  %458 = icmp eq i64 %456, 0
  %459 = select i1 %457, i1 %458, i1 false
  br i1 %459, label %572, label %460, !prof !11

460:                                              ; preds = %446
  %461 = icmp eq i64 %449, 0
  %462 = icmp eq i64 %447, 0
  %463 = select i1 %461, i1 %462, i1 false
  br i1 %463, label %572, label %464, !prof !11

464:                                              ; preds = %460
  %465 = icmp sgt i32 %452, %448
  br i1 %465, label %466, label %479

466:                                              ; preds = %464
  %467 = sub i32 %452, %448
  %468 = icmp ult i32 %467, 128
  br i1 %468, label %469, label %494

469:                                              ; preds = %466
  %470 = zext i64 %447 to i128
  %471 = shl nuw i128 %470, 64
  %472 = zext i64 %449 to i128
  %473 = or disjoint i128 %471, %472
  %474 = zext nneg i32 %467 to i128
  %475 = lshr i128 %473, %474
  %476 = trunc i128 %475 to i64
  %477 = lshr i128 %475, 64
  %478 = trunc nuw i128 %477 to i64
  br label %494

479:                                              ; preds = %464
  %480 = icmp sgt i32 %448, %452
  br i1 %480, label %481, label %494

481:                                              ; preds = %479
  %482 = sub i32 %448, %452
  %483 = icmp ult i32 %482, 128
  br i1 %483, label %484, label %494

484:                                              ; preds = %481
  %485 = zext i64 %456 to i128
  %486 = shl nuw i128 %485, 64
  %487 = zext i64 %454 to i128
  %488 = or disjoint i128 %486, %487
  %489 = zext nneg i32 %482 to i128
  %490 = lshr i128 %488, %489
  %491 = trunc i128 %490 to i64
  %492 = lshr i128 %490, 64
  %493 = trunc nuw i128 %492 to i64
  br label %494

494:                                              ; preds = %484, %481, %479, %469, %466
  %495 = phi i32 [ %452, %466 ], [ %448, %484 ], [ %452, %479 ], [ %452, %469 ], [ %448, %481 ]
  %496 = phi i32 [ %452, %466 ], [ %448, %484 ], [ %448, %479 ], [ %452, %469 ], [ %448, %481 ]
  %497 = phi i64 [ 0, %466 ], [ %449, %484 ], [ %449, %479 ], [ %476, %469 ], [ %449, %481 ]
  %498 = phi i64 [ %454, %466 ], [ %491, %484 ], [ %454, %479 ], [ %454, %469 ], [ 0, %481 ]
  %499 = phi i64 [ 0, %466 ], [ %447, %484 ], [ %447, %479 ], [ %478, %469 ], [ %447, %481 ]
  %500 = phi i64 [ %456, %466 ], [ %493, %484 ], [ %456, %479 ], [ %456, %469 ], [ 0, %481 ]
  %501 = xor i8 %450, %394
  %502 = and i8 %501, 1
  %503 = icmp eq i8 %502, 0
  br i1 %503, label %504, label %526

504:                                              ; preds = %494
  %505 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %498, i64 %497)
  %506 = extractvalue { i64, i1 } %505, 1
  %507 = extractvalue { i64, i1 } %505, 0
  %508 = zext i1 %506 to i64
  %509 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %500, i64 %499)
  %510 = extractvalue { i64, i1 } %509, 1
  %511 = extractvalue { i64, i1 } %509, 0
  %512 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %511, i64 %508)
  %513 = extractvalue { i64, i1 } %512, 1
  %514 = extractvalue { i64, i1 } %512, 0
  %515 = or i1 %510, %513
  br i1 %515, label %516, label %572

516:                                              ; preds = %504
  %517 = add i32 %495, 1
  %518 = zext i64 %514 to i128
  %519 = shl nuw i128 %518, 64
  %520 = zext i64 %507 to i128
  %521 = or disjoint i128 %519, %520
  %522 = lshr i128 %521, 1
  %523 = trunc i128 %522 to i64
  %524 = lshr i64 %514, 1
  %525 = or disjoint i64 %524, -9223372036854775808
  br label %572

526:                                              ; preds = %494
  %527 = icmp eq i64 %500, %499
  br i1 %527, label %528, label %530

528:                                              ; preds = %526
  %529 = icmp eq i64 %498, %497
  br i1 %529, label %534, label %530

530:                                              ; preds = %528, %526
  %531 = phi i64 [ %500, %526 ], [ %498, %528 ]
  %532 = phi i64 [ %499, %526 ], [ %497, %528 ]
  %533 = icmp ult i64 %531, %532
  br i1 %533, label %540, label %534

534:                                              ; preds = %530, %528
  %535 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %498, i64 %497)
  %536 = extractvalue { i64, i1 } %535, 1
  %537 = sext i1 %536 to i64
  %538 = sub i64 %500, %499
  %539 = add i64 %538, %537
  br label %546

540:                                              ; preds = %530
  %541 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %497, i64 %498)
  %542 = extractvalue { i64, i1 } %541, 1
  %543 = sext i1 %542 to i64
  %544 = sub i64 %499, %500
  %545 = add i64 %544, %543
  br label %546

546:                                              ; preds = %540, %534
  %547 = phi i32 [ %495, %534 ], [ %496, %540 ]
  %548 = phi { i64, i1 } [ %535, %534 ], [ %541, %540 ]
  %549 = phi i64 [ %539, %534 ], [ %545, %540 ]
  %550 = phi i8 [ %450, %534 ], [ %394, %540 ]
  %551 = extractvalue { i64, i1 } %548, 0
  %552 = icmp eq i64 %551, 0
  %553 = icmp eq i64 %549, 0
  %554 = select i1 %552, i1 %553, i1 false
  br i1 %554, label %572, label %555

555:                                              ; preds = %546
  %556 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %549, i1 false)
  %557 = trunc nuw nsw i64 %556 to i32
  %558 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %551, i1 false)
  %559 = trunc nuw nsw i64 %558 to i32
  %560 = select i1 %553, i32 %559, i32 0
  %561 = add nuw nsw i32 %560, %557
  %562 = sub i32 %547, %561
  %563 = zext i64 %549 to i128
  %564 = shl nuw i128 %563, 64
  %565 = zext i64 %551 to i128
  %566 = or disjoint i128 %564, %565
  %567 = zext nneg i32 %561 to i128
  %568 = shl i128 %566, %567
  %569 = trunc i128 %568 to i64
  %570 = lshr i128 %568, 64
  %571 = trunc nuw i128 %570 to i64
  br label %572

572:                                              ; preds = %555, %546, %516, %504, %460, %446
  %573 = phi i64 [ %571, %555 ], [ %447, %446 ], [ %525, %516 ], [ %514, %504 ], [ 0, %546 ], [ %456, %460 ]
  %574 = phi i64 [ %569, %555 ], [ %449, %446 ], [ %523, %516 ], [ %507, %504 ], [ 0, %546 ], [ %454, %460 ]
  %575 = phi i32 [ %562, %555 ], [ %448, %446 ], [ %517, %516 ], [ %495, %504 ], [ %547, %546 ], [ %452, %460 ]
  %576 = phi i8 [ %550, %555 ], [ %394, %446 ], [ %450, %516 ], [ %450, %504 ], [ %550, %546 ], [ %450, %460 ]
  %577 = xor i8 %576, %18
  %578 = add i32 %575, %21
  %579 = add i32 %578, 128
  br i1 %30, label %629, label %580

580:                                              ; preds = %572
  %581 = icmp eq i64 %574, 0
  %582 = icmp eq i64 %573, 0
  %583 = select i1 %581, i1 %582, i1 false
  br i1 %583, label %629, label %584

584:                                              ; preds = %580
  %585 = zext i64 %25 to i128
  %586 = zext i64 %573 to i128
  %587 = mul nuw i128 %586, %585
  %588 = trunc i128 %587 to i64
  %589 = lshr i128 %587, 64
  %590 = trunc nuw i128 %589 to i64
  %591 = zext i64 %28 to i128
  %592 = zext i64 %574 to i128
  %593 = mul nuw i128 %592, %591
  %594 = trunc i128 %593 to i64
  %595 = lshr i128 %593, 64
  %596 = trunc nuw i128 %595 to i64
  %597 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %588, i64 %594)
  %598 = extractvalue { i64, i1 } %597, 1
  %599 = zext i1 %598 to i64
  %600 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %590, i64 %596)
  %601 = extractvalue { i64, i1 } %600, 1
  %602 = extractvalue { i64, i1 } %600, 0
  %603 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %602, i64 %599)
  %604 = extractvalue { i64, i1 } %603, 1
  %605 = extractvalue { i64, i1 } %603, 0
  %606 = or i1 %601, %604
  %607 = zext i1 %606 to i64
  %608 = mul nuw i128 %586, %591
  %609 = trunc i128 %608 to i64
  %610 = lshr i128 %608, 64
  %611 = trunc nuw i128 %610 to i64
  %612 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %605, i64 %609)
  %613 = extractvalue { i64, i1 } %612, 1
  %614 = extractvalue { i64, i1 } %612, 0
  %615 = zext i1 %613 to i64
  %616 = add nuw i64 %607, %611
  %617 = add i64 %616, %615
  %618 = icmp sgt i64 %617, -1
  br i1 %618, label %619, label %629

619:                                              ; preds = %584
  %620 = add i32 %578, 127
  %621 = zext nneg i64 %617 to i128
  %622 = zext i64 %614 to i128
  %623 = shl nuw i128 %621, 65
  %624 = shl nuw nsw i128 %622, 1
  %625 = or disjoint i128 %623, %624
  %626 = trunc i128 %624 to i64
  %627 = lshr i128 %625, 64
  %628 = trunc nuw i128 %627 to i64
  br label %629

629:                                              ; preds = %619, %584, %580, %572
  %630 = phi i64 [ %617, %584 ], [ %628, %619 ], [ 0, %580 ], [ 0, %572 ]
  %631 = phi i32 [ %579, %584 ], [ %620, %619 ], [ %579, %580 ], [ %579, %572 ]
  %632 = phi i64 [ %614, %584 ], [ %626, %619 ], [ 0, %580 ], [ 0, %572 ]
  %633 = load i8, ptr %4, align 8, !noalias !77
  %634 = getelementptr inbounds nuw i8, ptr %4, i64 4
  %635 = load i32, ptr %634, align 4, !noalias !77
  %636 = getelementptr inbounds nuw i8, ptr %4, i64 8
  %637 = load i64, ptr %636, align 8, !noalias !77
  %638 = getelementptr inbounds nuw i8, ptr %4, i64 16
  %639 = load i64, ptr %638, align 8, !noalias !77
  %640 = icmp eq i64 %637, 0
  %641 = icmp eq i64 %639, 0
  %642 = select i1 %640, i1 %641, i1 false
  br i1 %642, label %755, label %643, !prof !11

643:                                              ; preds = %629
  %644 = icmp eq i64 %632, 0
  %645 = icmp eq i64 %630, 0
  %646 = select i1 %644, i1 %645, i1 false
  br i1 %646, label %755, label %647, !prof !11

647:                                              ; preds = %643
  %648 = icmp sgt i32 %635, %631
  br i1 %648, label %649, label %662

649:                                              ; preds = %647
  %650 = sub i32 %635, %631
  %651 = icmp ult i32 %650, 128
  br i1 %651, label %652, label %677

652:                                              ; preds = %649
  %653 = zext i64 %630 to i128
  %654 = shl nuw i128 %653, 64
  %655 = zext i64 %632 to i128
  %656 = or disjoint i128 %654, %655
  %657 = zext nneg i32 %650 to i128
  %658 = lshr i128 %656, %657
  %659 = trunc i128 %658 to i64
  %660 = lshr i128 %658, 64
  %661 = trunc nuw i128 %660 to i64
  br label %677

662:                                              ; preds = %647
  %663 = icmp sgt i32 %631, %635
  br i1 %663, label %664, label %677

664:                                              ; preds = %662
  %665 = sub i32 %631, %635
  %666 = icmp ult i32 %665, 128
  br i1 %666, label %667, label %677

667:                                              ; preds = %664
  %668 = zext i64 %639 to i128
  %669 = shl nuw i128 %668, 64
  %670 = zext i64 %637 to i128
  %671 = or disjoint i128 %669, %670
  %672 = zext nneg i32 %665 to i128
  %673 = lshr i128 %671, %672
  %674 = trunc i128 %673 to i64
  %675 = lshr i128 %673, 64
  %676 = trunc nuw i128 %675 to i64
  br label %677

677:                                              ; preds = %667, %664, %662, %652, %649
  %678 = phi i32 [ %635, %649 ], [ %631, %667 ], [ %635, %662 ], [ %635, %652 ], [ %631, %664 ]
  %679 = phi i32 [ %635, %649 ], [ %631, %667 ], [ %631, %662 ], [ %635, %652 ], [ %631, %664 ]
  %680 = phi i64 [ 0, %649 ], [ %632, %667 ], [ %632, %662 ], [ %659, %652 ], [ %632, %664 ]
  %681 = phi i64 [ %637, %649 ], [ %674, %667 ], [ %637, %662 ], [ %637, %652 ], [ 0, %664 ]
  %682 = phi i64 [ 0, %649 ], [ %630, %667 ], [ %630, %662 ], [ %661, %652 ], [ %630, %664 ]
  %683 = phi i64 [ %639, %649 ], [ %676, %667 ], [ %639, %662 ], [ %639, %652 ], [ 0, %664 ]
  %684 = xor i8 %633, %577
  %685 = and i8 %684, 1
  %686 = icmp eq i8 %685, 0
  br i1 %686, label %687, label %709

687:                                              ; preds = %677
  %688 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %681, i64 %680)
  %689 = extractvalue { i64, i1 } %688, 1
  %690 = extractvalue { i64, i1 } %688, 0
  %691 = zext i1 %689 to i64
  %692 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %683, i64 %682)
  %693 = extractvalue { i64, i1 } %692, 1
  %694 = extractvalue { i64, i1 } %692, 0
  %695 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %694, i64 %691)
  %696 = extractvalue { i64, i1 } %695, 1
  %697 = extractvalue { i64, i1 } %695, 0
  %698 = or i1 %693, %696
  br i1 %698, label %699, label %755

699:                                              ; preds = %687
  %700 = add i32 %678, 1
  %701 = zext i64 %697 to i128
  %702 = shl nuw i128 %701, 64
  %703 = zext i64 %690 to i128
  %704 = or disjoint i128 %702, %703
  %705 = lshr i128 %704, 1
  %706 = trunc i128 %705 to i64
  %707 = lshr i64 %697, 1
  %708 = or disjoint i64 %707, -9223372036854775808
  br label %755

709:                                              ; preds = %677
  %710 = icmp eq i64 %683, %682
  br i1 %710, label %711, label %713

711:                                              ; preds = %709
  %712 = icmp eq i64 %681, %680
  br i1 %712, label %717, label %713

713:                                              ; preds = %711, %709
  %714 = phi i64 [ %683, %709 ], [ %681, %711 ]
  %715 = phi i64 [ %682, %709 ], [ %680, %711 ]
  %716 = icmp ult i64 %714, %715
  br i1 %716, label %723, label %717

717:                                              ; preds = %713, %711
  %718 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %681, i64 %680)
  %719 = extractvalue { i64, i1 } %718, 1
  %720 = sext i1 %719 to i64
  %721 = sub i64 %683, %682
  %722 = add i64 %721, %720
  br label %729

723:                                              ; preds = %713
  %724 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %680, i64 %681)
  %725 = extractvalue { i64, i1 } %724, 1
  %726 = sext i1 %725 to i64
  %727 = sub i64 %682, %683
  %728 = add i64 %727, %726
  br label %729

729:                                              ; preds = %723, %717
  %730 = phi i32 [ %678, %717 ], [ %679, %723 ]
  %731 = phi { i64, i1 } [ %718, %717 ], [ %724, %723 ]
  %732 = phi i64 [ %722, %717 ], [ %728, %723 ]
  %733 = phi i8 [ %633, %717 ], [ %577, %723 ]
  %734 = extractvalue { i64, i1 } %731, 0
  %735 = icmp eq i64 %734, 0
  %736 = icmp eq i64 %732, 0
  %737 = select i1 %735, i1 %736, i1 false
  br i1 %737, label %755, label %738

738:                                              ; preds = %729
  %739 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %732, i1 false)
  %740 = trunc nuw nsw i64 %739 to i32
  %741 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %734, i1 false)
  %742 = trunc nuw nsw i64 %741 to i32
  %743 = select i1 %736, i32 %742, i32 0
  %744 = add nuw nsw i32 %743, %740
  %745 = sub i32 %730, %744
  %746 = zext i64 %732 to i128
  %747 = shl nuw i128 %746, 64
  %748 = zext i64 %734 to i128
  %749 = or disjoint i128 %747, %748
  %750 = zext nneg i32 %744 to i128
  %751 = shl i128 %749, %750
  %752 = trunc i128 %751 to i64
  %753 = lshr i128 %751, 64
  %754 = trunc nuw i128 %753 to i64
  br label %755

755:                                              ; preds = %738, %729, %699, %687, %643, %629
  %756 = phi i64 [ %754, %738 ], [ %630, %629 ], [ %708, %699 ], [ %697, %687 ], [ 0, %729 ], [ %639, %643 ]
  %757 = phi i64 [ %752, %738 ], [ %632, %629 ], [ %706, %699 ], [ %690, %687 ], [ 0, %729 ], [ %637, %643 ]
  %758 = phi i32 [ %745, %738 ], [ %631, %629 ], [ %700, %699 ], [ %678, %687 ], [ %730, %729 ], [ %635, %643 ]
  %759 = phi i8 [ %733, %738 ], [ %577, %629 ], [ %633, %699 ], [ %633, %687 ], [ %733, %729 ], [ %633, %643 ]
  %760 = xor i8 %759, %18
  %761 = add i32 %758, %21
  %762 = add i32 %761, 128
  br i1 %30, label %812, label %763

763:                                              ; preds = %755
  %764 = icmp eq i64 %757, 0
  %765 = icmp eq i64 %756, 0
  %766 = select i1 %764, i1 %765, i1 false
  br i1 %766, label %812, label %767

767:                                              ; preds = %763
  %768 = zext i64 %25 to i128
  %769 = zext i64 %756 to i128
  %770 = mul nuw i128 %769, %768
  %771 = trunc i128 %770 to i64
  %772 = lshr i128 %770, 64
  %773 = trunc nuw i128 %772 to i64
  %774 = zext i64 %28 to i128
  %775 = zext i64 %757 to i128
  %776 = mul nuw i128 %775, %774
  %777 = trunc i128 %776 to i64
  %778 = lshr i128 %776, 64
  %779 = trunc nuw i128 %778 to i64
  %780 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %771, i64 %777)
  %781 = extractvalue { i64, i1 } %780, 1
  %782 = zext i1 %781 to i64
  %783 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %773, i64 %779)
  %784 = extractvalue { i64, i1 } %783, 1
  %785 = extractvalue { i64, i1 } %783, 0
  %786 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %785, i64 %782)
  %787 = extractvalue { i64, i1 } %786, 1
  %788 = extractvalue { i64, i1 } %786, 0
  %789 = or i1 %784, %787
  %790 = zext i1 %789 to i64
  %791 = mul nuw i128 %769, %774
  %792 = trunc i128 %791 to i64
  %793 = lshr i128 %791, 64
  %794 = trunc nuw i128 %793 to i64
  %795 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %788, i64 %792)
  %796 = extractvalue { i64, i1 } %795, 1
  %797 = extractvalue { i64, i1 } %795, 0
  %798 = zext i1 %796 to i64
  %799 = add nuw i64 %790, %794
  %800 = add i64 %799, %798
  %801 = icmp sgt i64 %800, -1
  br i1 %801, label %802, label %812

802:                                              ; preds = %767
  %803 = add i32 %761, 127
  %804 = zext nneg i64 %800 to i128
  %805 = zext i64 %797 to i128
  %806 = shl nuw i128 %804, 65
  %807 = shl nuw nsw i128 %805, 1
  %808 = or disjoint i128 %806, %807
  %809 = trunc i128 %807 to i64
  %810 = lshr i128 %808, 64
  %811 = trunc nuw i128 %810 to i64
  br label %812

812:                                              ; preds = %755, %763, %767, %802
  %813 = phi i64 [ %800, %767 ], [ %811, %802 ], [ 0, %763 ], [ 0, %755 ]
  %814 = phi i32 [ %762, %767 ], [ %803, %802 ], [ %762, %763 ], [ %762, %755 ]
  %815 = phi i64 [ %797, %767 ], [ %809, %802 ], [ 0, %763 ], [ 0, %755 ]
  %816 = load i8, ptr %3, align 8
  %817 = getelementptr inbounds nuw i8, ptr %3, i64 4
  %818 = load i32, ptr %817, align 4
  %819 = getelementptr inbounds nuw i8, ptr %3, i64 8
  %820 = load i64, ptr %819, align 8
  %821 = getelementptr inbounds nuw i8, ptr %3, i64 16
  %822 = load i64, ptr %821, align 8
  %823 = icmp eq i64 %820, 0
  %824 = icmp eq i64 %822, 0
  %825 = select i1 %823, i1 %824, i1 false
  br i1 %825, label %938, label %826, !prof !11

826:                                              ; preds = %812
  %827 = icmp eq i64 %815, 0
  %828 = icmp eq i64 %813, 0
  %829 = select i1 %827, i1 %828, i1 false
  br i1 %829, label %938, label %830, !prof !11

830:                                              ; preds = %826
  %831 = icmp sgt i32 %818, %814
  br i1 %831, label %832, label %845

832:                                              ; preds = %830
  %833 = sub i32 %818, %814
  %834 = icmp ult i32 %833, 128
  br i1 %834, label %835, label %860

835:                                              ; preds = %832
  %836 = zext i64 %813 to i128
  %837 = shl nuw i128 %836, 64
  %838 = zext i64 %815 to i128
  %839 = or disjoint i128 %837, %838
  %840 = zext nneg i32 %833 to i128
  %841 = lshr i128 %839, %840
  %842 = trunc i128 %841 to i64
  %843 = lshr i128 %841, 64
  %844 = trunc nuw i128 %843 to i64
  br label %860

845:                                              ; preds = %830
  %846 = icmp sgt i32 %814, %818
  br i1 %846, label %847, label %860

847:                                              ; preds = %845
  %848 = sub i32 %814, %818
  %849 = icmp ult i32 %848, 128
  br i1 %849, label %850, label %860

850:                                              ; preds = %847
  %851 = zext i64 %822 to i128
  %852 = shl nuw i128 %851, 64
  %853 = zext i64 %820 to i128
  %854 = or disjoint i128 %852, %853
  %855 = zext nneg i32 %848 to i128
  %856 = lshr i128 %854, %855
  %857 = trunc i128 %856 to i64
  %858 = lshr i128 %856, 64
  %859 = trunc nuw i128 %858 to i64
  br label %860

860:                                              ; preds = %850, %847, %845, %835, %832
  %861 = phi i32 [ %818, %832 ], [ %814, %850 ], [ %818, %845 ], [ %818, %835 ], [ %814, %847 ]
  %862 = phi i32 [ %818, %832 ], [ %814, %850 ], [ %814, %845 ], [ %818, %835 ], [ %814, %847 ]
  %863 = phi i64 [ 0, %832 ], [ %815, %850 ], [ %815, %845 ], [ %842, %835 ], [ %815, %847 ]
  %864 = phi i64 [ %820, %832 ], [ %857, %850 ], [ %820, %845 ], [ %820, %835 ], [ 0, %847 ]
  %865 = phi i64 [ 0, %832 ], [ %813, %850 ], [ %813, %845 ], [ %844, %835 ], [ %813, %847 ]
  %866 = phi i64 [ %822, %832 ], [ %859, %850 ], [ %822, %845 ], [ %822, %835 ], [ 0, %847 ]
  %867 = xor i8 %816, %760
  %868 = and i8 %867, 1
  %869 = icmp eq i8 %868, 0
  br i1 %869, label %870, label %892

870:                                              ; preds = %860
  %871 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %864, i64 %863)
  %872 = extractvalue { i64, i1 } %871, 1
  %873 = extractvalue { i64, i1 } %871, 0
  %874 = zext i1 %872 to i64
  %875 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %866, i64 %865)
  %876 = extractvalue { i64, i1 } %875, 1
  %877 = extractvalue { i64, i1 } %875, 0
  %878 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %877, i64 %874)
  %879 = extractvalue { i64, i1 } %878, 1
  %880 = extractvalue { i64, i1 } %878, 0
  %881 = or i1 %876, %879
  br i1 %881, label %882, label %938

882:                                              ; preds = %870
  %883 = add i32 %861, 1
  %884 = zext i64 %880 to i128
  %885 = shl nuw i128 %884, 64
  %886 = zext i64 %873 to i128
  %887 = or disjoint i128 %885, %886
  %888 = lshr i128 %887, 1
  %889 = trunc i128 %888 to i64
  %890 = lshr i64 %880, 1
  %891 = or disjoint i64 %890, -9223372036854775808
  br label %938

892:                                              ; preds = %860
  %893 = icmp eq i64 %866, %865
  br i1 %893, label %894, label %896

894:                                              ; preds = %892
  %895 = icmp eq i64 %864, %863
  br i1 %895, label %900, label %896

896:                                              ; preds = %894, %892
  %897 = phi i64 [ %866, %892 ], [ %864, %894 ]
  %898 = phi i64 [ %865, %892 ], [ %863, %894 ]
  %899 = icmp ult i64 %897, %898
  br i1 %899, label %906, label %900

900:                                              ; preds = %896, %894
  %901 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %864, i64 %863)
  %902 = extractvalue { i64, i1 } %901, 1
  %903 = sext i1 %902 to i64
  %904 = sub i64 %866, %865
  %905 = add i64 %904, %903
  br label %912

906:                                              ; preds = %896
  %907 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %863, i64 %864)
  %908 = extractvalue { i64, i1 } %907, 1
  %909 = sext i1 %908 to i64
  %910 = sub i64 %865, %866
  %911 = add i64 %910, %909
  br label %912

912:                                              ; preds = %906, %900
  %913 = phi i32 [ %861, %900 ], [ %862, %906 ]
  %914 = phi { i64, i1 } [ %901, %900 ], [ %907, %906 ]
  %915 = phi i64 [ %905, %900 ], [ %911, %906 ]
  %916 = phi i8 [ %816, %900 ], [ %760, %906 ]
  %917 = extractvalue { i64, i1 } %914, 0
  %918 = icmp eq i64 %917, 0
  %919 = icmp eq i64 %915, 0
  %920 = select i1 %918, i1 %919, i1 false
  br i1 %920, label %938, label %921

921:                                              ; preds = %912
  %922 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %915, i1 false)
  %923 = trunc nuw nsw i64 %922 to i32
  %924 = tail call range(i64 0, 65) i64 @llvm.ctlz.i64(i64 %917, i1 false)
  %925 = trunc nuw nsw i64 %924 to i32
  %926 = select i1 %919, i32 %925, i32 0
  %927 = add nuw nsw i32 %926, %923
  %928 = sub i32 %913, %927
  %929 = zext i64 %915 to i128
  %930 = shl nuw i128 %929, 64
  %931 = zext i64 %917 to i128
  %932 = or disjoint i128 %930, %931
  %933 = zext nneg i32 %927 to i128
  %934 = shl i128 %932, %933
  %935 = trunc i128 %934 to i64
  %936 = lshr i128 %934, 64
  %937 = trunc nuw i128 %936 to i64
  br label %938

938:                                              ; preds = %826, %812, %912, %921, %870, %882
  %939 = phi i64 [ %937, %921 ], [ %813, %812 ], [ %891, %882 ], [ %880, %870 ], [ 0, %912 ], [ %822, %826 ]
  %940 = phi i64 [ %935, %921 ], [ %815, %812 ], [ %889, %882 ], [ %873, %870 ], [ 0, %912 ], [ %820, %826 ]
  %941 = phi i32 [ %928, %921 ], [ %814, %812 ], [ %883, %882 ], [ %861, %870 ], [ %913, %912 ], [ %818, %826 ]
  %942 = phi i8 [ %916, %921 ], [ %760, %812 ], [ %816, %882 ], [ %816, %870 ], [ %916, %912 ], [ %816, %826 ]
  call void @llvm.lifetime.start.p0(ptr nonnull %10)
  %943 = getelementptr inbounds nuw i8, ptr %10, i64 4
  %944 = getelementptr inbounds nuw i8, ptr %10, i64 8
  %945 = xor i8 %942, %18
  %946 = and i8 %945, 1
  store i8 %946, ptr %10, align 8, !tbaa !17, !alias.scope !78, !noalias !81
  %947 = add i32 %941, %21
  %948 = add i32 %947, 128
  store i32 %948, ptr %943, align 4, !tbaa !25, !alias.scope !78, !noalias !81
  br i1 %30, label %999, label %949

949:                                              ; preds = %938
  %950 = icmp eq i64 %940, 0
  %951 = icmp eq i64 %939, 0
  %952 = select i1 %950, i1 %951, i1 false
  br i1 %952, label %999, label %953

953:                                              ; preds = %949
  %954 = zext i64 %25 to i128
  %955 = zext i64 %939 to i128
  %956 = mul nuw i128 %955, %954
  %957 = trunc i128 %956 to i64
  %958 = lshr i128 %956, 64
  %959 = trunc nuw i128 %958 to i64
  %960 = zext i64 %28 to i128
  %961 = zext i64 %940 to i128
  %962 = mul nuw i128 %961, %960
  %963 = trunc i128 %962 to i64
  %964 = lshr i128 %962, 64
  %965 = trunc nuw i128 %964 to i64
  %966 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %957, i64 %963)
  %967 = extractvalue { i64, i1 } %966, 1
  %968 = zext i1 %967 to i64
  %969 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %959, i64 %965)
  %970 = extractvalue { i64, i1 } %969, 1
  %971 = extractvalue { i64, i1 } %969, 0
  %972 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %971, i64 %968)
  %973 = extractvalue { i64, i1 } %972, 1
  %974 = extractvalue { i64, i1 } %972, 0
  %975 = or i1 %970, %973
  %976 = zext i1 %975 to i64
  %977 = mul nuw i128 %955, %960
  %978 = trunc i128 %977 to i64
  %979 = lshr i128 %977, 64
  %980 = trunc nuw i128 %979 to i64
  %981 = tail call { i64, i1 } @llvm.uadd.with.overflow.i64(i64 %974, i64 %978)
  %982 = extractvalue { i64, i1 } %981, 1
  %983 = extractvalue { i64, i1 } %981, 0
  %984 = zext i1 %982 to i64
  %985 = add nuw i64 %976, %980
  %986 = add i64 %985, %984
  store i64 %983, ptr %944, align 8, !alias.scope !78, !noalias !81
  %987 = getelementptr inbounds nuw i8, ptr %10, i64 16
  store i64 %986, ptr %987, align 8, !tbaa !21, !alias.scope !78, !noalias !81
  %988 = icmp sgt i64 %986, -1
  br i1 %988, label %989, label %1000

989:                                              ; preds = %953
  %990 = add i32 %947, 127
  store i32 %990, ptr %943, align 4, !tbaa !25, !alias.scope !78, !noalias !81
  %991 = zext nneg i64 %986 to i128
  %992 = zext i64 %983 to i128
  %993 = shl nuw i128 %991, 65
  %994 = shl nuw nsw i128 %992, 1
  %995 = or disjoint i128 %993, %994
  %996 = trunc i128 %994 to i64
  %997 = lshr i128 %995, 64
  %998 = trunc nuw i128 %997 to i64
  store i64 %996, ptr %944, align 8, !alias.scope !78, !noalias !81
  store i64 %998, ptr %987, align 8, !tbaa !21, !alias.scope !78, !noalias !81
  br label %1000

999:                                              ; preds = %949, %938
  call void @llvm.memset.p0.i64(ptr noundef nonnull align 8 dereferenceable(16) %944, i8 0, i64 16, i1 false), !alias.scope !78, !noalias !81
  br label %1000

1000:                                             ; preds = %953, %989, %999
  tail call void @_ZN11__llvm_libc6fputil9quick_addILm128EEENS0_11DyadicFloatIXT_EEES3_S3_(ptr dead_on_unwind nonnull writable sret(%"struct.__llvm_libc::fputil::DyadicFloat") align 8 %0, ptr noundef nonnull byval(%"struct.__llvm_libc::fputil::DyadicFloat") align 8 %2, ptr noundef nonnull byval(%"struct.__llvm_libc::fputil::DyadicFloat") align 8 %10)
  call void @llvm.lifetime.end.p0(ptr nonnull %10)
  ret void
}

; Function Attrs: mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare { i64, i1 } @llvm.uadd.with.overflow.i64(i64, i64) #7

; Function Attrs: mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare { i64, i1 } @llvm.usub.with.overflow.i64(i64, i64) #7

; Function Attrs: inlinehint mustprogress sspstrong uwtable
define linkonce_odr hidden noundef double @_ZNK11__llvm_libc6fputil11DyadicFloatILm128EE7fast_asIdLb1EvEET_v(ptr noundef nonnull align 8 dereferenceable(24) %0) local_unnamed_addr #1 comdat align 2 {
  %2 = alloca double, align 8
  %3 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %4 = load i64, ptr %3, align 8, !tbaa !30
  %5 = icmp eq i64 %4, 0
  %6 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %7 = load i64, ptr %6, align 8
  %8 = icmp eq i64 %7, 0
  %9 = select i1 %5, i1 %8, i1 false
  br i1 %9, label %10, label %15, !prof !11

10:                                               ; preds = %1
  %11 = load i8, ptr %0, align 8, !tbaa !17
  %12 = zext i8 %11 to i64
  %13 = shl i64 %12, 63
  %14 = bitcast i64 %13 to double
  br label %123

15:                                               ; preds = %1
  %16 = getelementptr inbounds nuw i8, ptr %0, i64 4
  %17 = load i32, ptr %16, align 4, !tbaa !25
  %18 = add i32 %17, 1150
  %19 = icmp sgt i32 %18, 2046
  br i1 %19, label %20, label %30, !prof !11

20:                                               ; preds = %15
  %21 = load i8, ptr %0, align 8, !tbaa !17
  %22 = trunc nuw i8 %21 to i1
  %23 = select i1 %22, double f0xFFE0000000000000, double f0x7FE0000000000000
  call void @llvm.lifetime.start.p0(ptr nonnull %2)
  store volatile double 2.000000e+00, ptr %2, align 8, !tbaa !16
  %24 = load volatile double, ptr %2, align 8, !tbaa !16
  %25 = fmul double %23, %24
  %26 = tail call double @llvm.fabs.f64(double %25)
  %27 = fcmp oeq double %26, +inf
  br i1 %27, label %28, label %29

28:                                               ; preds = %20
  tail call void @_ZN11__llvm_libc6fputil21set_errno_if_requiredEi(i32 noundef 34)
  br label %29

29:                                               ; preds = %28, %20
  call void @llvm.lifetime.end.p0(ptr nonnull %2)
  br label %123

30:                                               ; preds = %15
  %31 = icmp slt i32 %18, 1
  br i1 %31, label %34, label %32, !prof !11

32:                                               ; preds = %30
  %33 = add nsw i32 %17, 1096
  br label %37

34:                                               ; preds = %30
  %35 = sub nuw i32 -1074, %17
  %36 = icmp ult i32 %17, -1201
  br i1 %36, label %49, label %37

37:                                               ; preds = %32, %34
  %38 = phi i32 [ %33, %32 ], [ 969, %34 ]
  %39 = phi i32 [ %18, %32 ], [ 1023, %34 ]
  %40 = phi i32 [ 75, %32 ], [ %35, %34 ]
  %41 = zext i64 %7 to i128
  %42 = shl nuw i128 %41, 64
  %43 = zext i64 %4 to i128
  %44 = or disjoint i128 %42, %43
  %45 = zext nneg i32 %40 to i128
  %46 = lshr i128 %44, %45
  %47 = trunc nuw nsw i128 %46 to i64
  %48 = and i64 %47, 4503599627370495
  br label %49

49:                                               ; preds = %34, %37
  %50 = phi i32 [ %38, %37 ], [ 969, %34 ]
  %51 = phi i32 [ %39, %37 ], [ 1023, %34 ]
  %52 = phi i32 [ %40, %37 ], [ %35, %34 ]
  %53 = phi i64 [ %48, %37 ], [ 0, %34 ]
  %54 = load i8, ptr %0, align 8, !tbaa !17
  %55 = zext nneg i32 %51 to i64
  %56 = trunc nuw i8 %54 to i1
  %57 = shl nuw nsw i64 %55, 52
  %58 = or disjoint i64 %57, %53
  %59 = or disjoint i64 %58, -9223372036854775808
  %60 = select i1 %56, i64 %59, i64 %58
  %61 = bitcast i64 %60 to double
  %62 = add i32 %52, -1
  %63 = icmp ugt i32 %62, 127
  %64 = zext nneg i32 %62 to i128
  %65 = shl nuw i128 1, %64
  %66 = trunc i128 %65 to i64
  %67 = lshr i128 %65, 64
  %68 = trunc nuw i128 %67 to i64
  %69 = select i1 %63, i64 0, i64 %68
  %70 = select i1 %63, i64 0, i64 %66
  %71 = tail call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %70, i64 1)
  %72 = extractvalue { i64, i1 } %71, 1
  %73 = extractvalue { i64, i1 } %71, 0
  %74 = sext i1 %72 to i64
  %75 = add i64 %69, %74
  %76 = and i64 %70, %4
  %77 = and i64 %69, %7
  %78 = icmp eq i64 %76, 0
  %79 = icmp eq i64 %77, 0
  %80 = select i1 %78, i1 %79, i1 false
  %81 = and i64 %73, %4
  %82 = and i64 %75, %7
  %83 = icmp ne i64 %81, 0
  %84 = icmp ne i64 %82, 0
  %85 = select i1 %83, i1 true, i1 %84
  %86 = select i1 %80, i32 0, i32 2
  %87 = zext i1 %85 to i32
  %88 = or disjoint i32 %86, %87
  %89 = icmp slt i32 %50, 1
  br i1 %89, label %90, label %107, !prof !11

90:                                               ; preds = %49
  %91 = sub nsw i32 1078, %51
  %92 = sext i32 %91 to i64
  %93 = shl nsw i64 %92, 52
  %94 = and i64 %93, 9218868437227405312
  %95 = bitcast i64 %94 to double
  %96 = add nuw nsw i32 %51, 968
  %97 = zext nneg i32 %96 to i64
  %98 = shl nuw i64 %97, 52
  %99 = and i64 %98, 9218868437227405312
  %100 = bitcast i64 %99 to double
  %101 = select i1 %56, double f0x8010000000000000, double f0x0010000000000000
  %102 = uitofp nneg i32 %88 to double
  %103 = fmul double %95, %61
  %104 = fmul nnan double %101, %102
  %105 = fadd double %103, %104
  %106 = fmul double %105, %100
  br label %123

107:                                              ; preds = %49
  %108 = zext nneg i32 %50 to i64
  %109 = shl nuw nsw i64 %108, 52
  %110 = or disjoint i64 %109, -9223372036854775808
  %111 = select i1 %56, i64 %110, i64 %109
  %112 = bitcast i64 %111 to double
  %113 = uitofp nneg i32 %88 to double
  %114 = fmul double %112, %113
  %115 = fadd double %114, %61
  br i1 %31, label %116, label %123, !prof !11

116:                                              ; preds = %107
  %117 = bitcast double %115 to i64
  %118 = sub i64 %117, %57
  %119 = icmp eq i32 %88, 0
  br i1 %119, label %121, label %120

120:                                              ; preds = %116
  tail call void @_ZN11__llvm_libc6fputil21set_errno_if_requiredEi(i32 noundef 34)
  tail call void @_ZN11__llvm_libc6fputil34raise_underflow_except_if_requiredIdEEvv()
  br label %121

121:                                              ; preds = %120, %116
  %122 = bitcast i64 %118 to double
  br label %123

123:                                              ; preds = %90, %107, %121, %29, %10
  %124 = phi double [ %14, %10 ], [ %25, %29 ], [ %106, %90 ], [ %122, %121 ], [ %115, %107 ]
  ret double %124
}

; Function Attrs: inlinehint mustprogress noinline nounwind sspstrong uwtable
define linkonce_odr hidden void @_ZN11__llvm_libc6fputil34raise_underflow_except_if_requiredIdEEvv() local_unnamed_addr #5 comdat {
  %1 = alloca double, align 8
  call void @llvm.lifetime.start.p0(ptr nonnull %1)
  store volatile double f0x0010000000000000, ptr %1, align 8, !tbaa !16
  %2 = load volatile double, ptr %1, align 8, !tbaa !16
  %3 = fmul double %2, f0x39B0000000000000
  store volatile double %3, ptr %1, align 8, !tbaa !16
  call void @llvm.lifetime.end.p0(ptr nonnull %1)
  ret void
}

; Function Attrs: nounwind memory(argmem: write)
declare void @llvm.x86.sse.stmxcsr(ptr) #8

; Function Attrs: nounwind
declare void @llvm.x86.sse.ldmxcsr(ptr) #9

declare hidden void @_ZN11__llvm_libc5ErrnoaSEi(ptr noundef nonnull align 1 dereferenceable(1), i32 noundef) local_unnamed_addr #10

; Function Attrs: mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fmuladd.f64(double, double, double) #7

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fabs.f64(double) #11

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite)
declare void @llvm.experimental.noalias.scope.decl(metadata) #12

attributes #0 = { mustprogress sspstrong uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="inline-asm" "stack-protector-buffer-size"="4" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "zero-call-used-regs"="used-gpr" }
attributes #1 = { inlinehint mustprogress sspstrong uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="inline-asm" "stack-protector-buffer-size"="4" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "zero-call-used-regs"="used-gpr" }
attributes #2 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: write) }
attributes #4 = { inlinehint mustprogress noinline sspstrong uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="inline-asm" "stack-protector-buffer-size"="4" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "zero-call-used-regs"="used-gpr" }
attributes #5 = { inlinehint mustprogress noinline nounwind sspstrong uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="inline-asm" "stack-protector-buffer-size"="4" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "zero-call-used-regs"="used-gpr" }
attributes #6 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #7 = { mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #8 = { nounwind memory(argmem: write) }
attributes #9 = { nounwind }
attributes #10 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="4" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "zero-call-used-regs"="used-gpr" }
attributes #11 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #12 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}
!llvm.errno.tbaa = !{!5}

!0 = !{i32 4, !"probe-stack", !"inline-asm"}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 2}
!3 = !{i32 7, !"frame-pointer", i32 2}
!4 = !{!"clang version 23.1.3"}
!5 = !{!6, !7, i64 0}
!6 = !{!"__libc_errno", !7, i64 0}
!7 = !{!"int", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C++ TBAA"}
!10 = !{!"branch_weights", !"expected", i32 2000, i32 1}
!11 = !{!"branch_weights", !"expected", i32 1, i32 2000}
!12 = !{!13, !14, i64 8}
!13 = !{!"_ZTSN11__llvm_libc10NumberPairIdEE", !14, i64 0, !14, i64 8}
!14 = !{!"double", !8, i64 0}
!15 = !{!13, !14, i64 0}
!16 = !{!14, !14, i64 0}
!17 = !{!18, !18, i64 0}
!18 = !{!"bool", !8, i64 0}
!19 = !{i64 0, i64 1, !17, i64 4, i64 4, !20, i64 8, i64 16, !21}
!20 = !{!7, !7, i64 0}
!21 = !{!8, !8, i64 0}
!22 = !{!23}
!23 = distinct !{!23, !24, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_: argument 0"}
!24 = distinct !{!24, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_"}
!25 = !{!26, !7, i64 4}
!26 = !{!"_ZTSN11__llvm_libc6fputil11DyadicFloatILm128EEE", !27, i64 0, !7, i64 4, !28, i64 8}
!27 = !{!"_ZTSN11__llvm_libc4SignE", !18, i64 0}
!28 = !{!"_ZTSN11__llvm_libc6BigIntILm128ELb0EmEE", !29, i64 0}
!29 = !{!"_ZTSN11__llvm_libc3cpp5arrayImLm2EEE", !8, i64 0}
!30 = !{!31, !31, i64 0}
!31 = !{!"long", !8, i64 0}
!32 = !{!33}
!33 = distinct !{!33, !34, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_: argument 0"}
!34 = distinct !{!34, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_"}
!35 = !{!36, !7, i64 0}
!36 = !{!"_ZTSN11__llvm_libc4math31range_reduction_double_internal19LargeRangeReductionE", !7, i64 0, !14, i64 8, !14, i64 16, !14, i64 24, !13, i64 32}
!37 = !{!36, !14, i64 8}
!38 = !{!36, !14, i64 16}
!39 = !{!36, !14, i64 24}
!40 = !{!41, !41, i64 0}
!41 = !{!"float", !8, i64 0}
!42 = !{!43}
!43 = distinct !{!43, !44, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_: argument 0"}
!44 = distinct !{!44, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_"}
!45 = !{!"branch_weights", !"expected", i32 0, i32 -2147483648}
!46 = !{!36, !14, i64 32}
!47 = !{!36, !14, i64 40}
!48 = !{!"branch_weights", !"expected", i32 2288208, i32 2145195440}
!49 = !{!50}
!50 = distinct !{!50, !51, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_: argument 0"}
!51 = distinct !{!51, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_"}
!52 = !{!53}
!53 = distinct !{!53, !54, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_: argument 0"}
!54 = distinct !{!54, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_"}
!55 = !{!56}
!56 = distinct !{!56, !57, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_: argument 0"}
!57 = distinct !{!57, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_"}
!58 = !{!59, !61, !63, !65, !67}
!59 = distinct !{!59, !60, !"_ZN11__llvm_libc6fputilL8polyevalINS0_11DyadicFloatILm128EEEJS3_EEENS_3cpp9enable_ifIXgtstT_Lm8EES6_E4typeERKS6_SA_DpRKT0_: argument 0"}
!60 = distinct !{!60, !"_ZN11__llvm_libc6fputilL8polyevalINS0_11DyadicFloatILm128EEEJS3_EEENS_3cpp9enable_ifIXgtstT_Lm8EES6_E4typeERKS6_SA_DpRKT0_"}
!61 = distinct !{!61, !62, !"_ZN11__llvm_libc6fputilL8polyevalINS0_11DyadicFloatILm128EEEJS3_S3_EEENS_3cpp9enable_ifIXgtstT_Lm8EES6_E4typeERKS6_SA_DpRKT0_: argument 0"}
!62 = distinct !{!62, !"_ZN11__llvm_libc6fputilL8polyevalINS0_11DyadicFloatILm128EEEJS3_S3_EEENS_3cpp9enable_ifIXgtstT_Lm8EES6_E4typeERKS6_SA_DpRKT0_"}
!63 = distinct !{!63, !64, !"_ZN11__llvm_libc6fputilL8polyevalINS0_11DyadicFloatILm128EEEJS3_S3_S3_EEENS_3cpp9enable_ifIXgtstT_Lm8EES6_E4typeERKS6_SA_DpRKT0_: argument 0"}
!64 = distinct !{!64, !"_ZN11__llvm_libc6fputilL8polyevalINS0_11DyadicFloatILm128EEEJS3_S3_S3_EEENS_3cpp9enable_ifIXgtstT_Lm8EES6_E4typeERKS6_SA_DpRKT0_"}
!65 = distinct !{!65, !66, !"_ZN11__llvm_libc6fputilL8polyevalINS0_11DyadicFloatILm128EEEJS3_S3_S3_S3_EEENS_3cpp9enable_ifIXgtstT_Lm8EES6_E4typeERKS6_SA_DpRKT0_: argument 0"}
!66 = distinct !{!66, !"_ZN11__llvm_libc6fputilL8polyevalINS0_11DyadicFloatILm128EEEJS3_S3_S3_S3_EEENS_3cpp9enable_ifIXgtstT_Lm8EES6_E4typeERKS6_SA_DpRKT0_"}
!67 = distinct !{!67, !68, !"_ZN11__llvm_libc6fputilL8polyevalINS0_11DyadicFloatILm128EEEJS3_S3_S3_S3_S3_EEENS_3cpp9enable_ifIXgtstT_Lm8EES6_E4typeERKS6_SA_DpRKT0_: argument 0"}
!68 = distinct !{!68, !"_ZN11__llvm_libc6fputilL8polyevalINS0_11DyadicFloatILm128EEEJS3_S3_S3_S3_S3_EEENS_3cpp9enable_ifIXgtstT_Lm8EES6_E4typeERKS6_SA_DpRKT0_"}
!69 = !{!70, !72, !59, !61, !63, !65, !67}
!70 = distinct !{!70, !71, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_: argument 0"}
!71 = distinct !{!71, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_"}
!72 = distinct !{!72, !73, !"_ZN11__llvm_libc6fputil12multiply_addILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_S5_: argument 0"}
!73 = distinct !{!73, !"_ZN11__llvm_libc6fputil12multiply_addILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_S5_"}
!74 = !{!61, !63, !65, !67}
!75 = !{!63, !65, !67}
!76 = !{!65, !67}
!77 = !{!67}
!78 = !{!79}
!79 = distinct !{!79, !80, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_: argument 0"}
!80 = distinct !{!80, !"_ZN11__llvm_libc6fputil9quick_mulILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_"}
!81 = !{!82}
!82 = distinct !{!82, !83, !"_ZN11__llvm_libc6fputil12multiply_addILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_S5_: argument 0"}
!83 = distinct !{!83, !"_ZN11__llvm_libc6fputil12multiply_addILm128EEENS0_11DyadicFloatIXT_EEERKS3_S5_S5_"}
