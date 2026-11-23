; ModuleID = '/home/schrodingerzy/Documents/llvm-project/libc/src/math/generic/expf.cpp'
source_filename = "/home/schrodingerzy/Documents/llvm-project/libc/src/math/generic/expf.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"struct.__llvm_libc::Errno" = type { i8 }

$_ZN11__llvm_libc4math11double_eval4expfEf = comdat any

$_ZN11__llvm_libc6fputil21set_errno_if_requiredEi = comdat any

$_ZN11__llvm_libc6fputil24raise_except_if_requiredEi = comdat any

$_ZN11__llvm_libc6fputil7generic16fenv_is_round_upEv = comdat any

$_ZN11__llvm_libc6fputil7generic15quick_get_roundEv = comdat any

$_ZN11__llvm_libc4math6EXP_M1E = comdat any

$_ZN11__llvm_libc4math6EXP_M2E = comdat any

$_ZZN11__llvm_libc6fputil7generic16fenv_is_round_upEvE1x = comdat any

$_ZZN11__llvm_libc6fputil7generic15quick_get_roundEvE1x = comdat any

@_ZN11__llvm_libc4math6EXP_M1E = linkonce_odr hidden local_unnamed_addr constant [195 x double] [double f0x368F1E6B68529E33, double f0x36A525BE4E4E601D, double f0x36BCBE0A45F75EB1, double f0x36D3884E838AEA68, double f0x36EA8C1F14E2AF5D, double f0x37020A717E64A9BD, double f0x3718851D84118908, double f0x3730A9BDFB02D240, double f0x3746A5BEA046B42E, double f0x375EC7F3B269EFA8, double f0x3774EAFB87EAB0F2, double f0x378C6E2D05BBC000, double f0x37A35208867C2683, double f0x37BA425B317EEACD, double f0x37D1D8508FA8246A, double f0x37E840FBC08FDC8A, double f0x38007B7112BC1FFE, double f0x381666D0DAD2961D, double f0x382E726C3F64D0FE, double f0x3844B0DC07CABF98, double f0x385C1F2DAF3B6A46, double f0x38731C5957A47DE2, double f0x3889F96445648B9F, double f0x38A1A6BAEADB4FD1, double f0x38B7FD974D372E45, double f0x38D04DA4D1452919, double f0x38E62891F06B3450, double f0x38FE1DD273AA8A4A, double f0x3914775E0840BFDD, double f0x392BD109D9D94BDA, double f0x3942E73F53FBA844, double f0x3959B138170D6BFE, double f0x397175AF0CF60EC5, double f0x3987BAEE1BFFA80B, double f0x39A02057D1245CEB, double f0x39B5EAFFFB34BA31, double f0x39CDCA23BAE16424, double f0x39E43E7FC88B8056, double f0x39FB83BF23A9A9EB, double f0x3A12B2B8DD05B318, double f0x3A2969D47321E4CC, double f0x3A41452B7723AED2, double f0x3A5778FE2497184C, double f0x3A6FE7116182E9CC, double f0x3A85AE191A99585A, double f0x3A9D775D87DA854D, double f0x3AB4063F8CC8BB98, double f0x3ACB374B315F87C1, double f0x3AE27EC458C65E3C, double f0x3AF923372C67A074, double f0x3B11152EAEB73C08, double f0x3B2737C5645114B5, double f0x3B3F8E6C24B5592E, double f0x3B5571DB733A9D61, double f0x3B6D257D547E083F, double f0x3B83CE9B9DE78F85, double f0x3B9AEBABAE3A41B5, double f0x3BB24B6031B49BDA, double f0x3BC8DD5E1BB09D7E, double f0x3BE0E5B73D1FF53D, double f0x3BF6F741DE1748EC, double f0x3C0F36BD37F42F3E, double f0x3C2536452EE2F75C, double f0x3C3CD480A1B74820, double f0x3C539792499B1A24, double f0x3C6AA0DE4BF35B38, double f0x3C82188AD6AE3303, double f0x3C9898471FCA6055, double f0x3CB0B6C3AFDDE064, double f0x3CC6B7719A59F0E0, double f0x3CDEE001EED62AA0, double f0x3CF4FB547C775DA8, double f0x3D0C8464F7616468, double f0x3D236121E24D3BBA, double f0x3D3A56E0C2AC7F75, double f0x3D51E642BAEB84A0, double f0x3D6853F01D6D53BA, double f0x3D80885298767E9A, double f0x3D967852A7007E42, double f0x3DAE8A37A45FC32E, double f0x3DC4C1078FE9228A, double f0x3DDC3527E433FAB1, double f0x3DF32B48BF117DA2, double f0x3E0A0DB0D0DDB3EC, double f0x3E21B48655F37267, double f0x3E381056FF2C5772, double f0x3E505A628C699FA1, double f0x3E6639E3175A689D, double f0x3E7E355BBAEE85CB, double f0x3E94875CA227EC38, double f0x3EABE6C6FDB01612, double f0x3EC2F6053B981D98, double f0x3ED9C54C3B43BC8B, double f0x3EF18354238F6764, double f0x3F07CD79B5647C9B, double f0x3F202CF22526545A, double f0x3F35FC21041027AD, double f0x3F4DE16B9C24A98F, double f0x3F644E51F113D4D6, double f0x3F7B993FE00D5376, double f0x3F92C155B8213CF4, double f0x3FA97DB0CCCEB0AF, double f0x3FC152AAA3BF81CC, double f0x3FD78B56362CEF38, double 1.000000e+00, double f0x4005BF0A8B145769, double f0x401D8E64B8D4DDAE, double f0x403415E5BF6FB106, double f0x404B4C902E273A58, double f0x40628D389970338F, double f0x407936DC5690C08F, double f0x409122885AAEDDAA, double f0x40A749EA7D470C6E, double f0x40BFA7157C470F82, double f0x40D5829DCF950560, double f0x40ED3C4488EE4F7F, double f0x4103DE1654D37C9A, double f0x411B00B5916AC955, double f0x413259AC48BF05D7, double f0x4148F0CCAFAD2A87, double f0x4160F2EBD0A80020, double f0x417709348C0EA4F9, double f0x418F4F22091940BD, double f0x41A546D8F9ED26E1, double f0x41BCEB088B68E804, double f0x41D3A6E1FD9EECFD, double f0x41EAB5ADB9C43600, double f0x420226AF33B1FDC1, double f0x4218AB7FB5475FB7, double f0x4230C3D3920962C9, double f0x4246C932696A6B5D, double f0x425EF822F7F6731D, double f0x42750BBA3796379A, double f0x428C9AAE4631C056, double f0x42A370470AEC28ED, double f0x42BA6B765D8CDF6D, double f0x42D1F43FCC4B662C, double f0x42E866F34A725782, double f0x4300953E2F3A1EF7, double f0x431689E221BC8D5B, double f0x432EA215A1D20D76, double f0x4344D13FBB1A001A, double f0x435C4B334617CC67, double f0x43733A43D282A519, double f0x438A220D397972EB, double f0x43A1C25C88DF6862, double f0x43B8232558201159, double f0x43D0672A3C9EB871, double f0x43E64B41C6D37832, double f0x43FE4CF766FE49BE, double f0x44149767BC0483E3, double f0x442BFC951EB8BB76, double f0x444304D6AECA254B, double f0x4459D97010884251, double f0x44719103E4080B45, double f0x4487E013CD114461, double f0x44A03996528E074C, double f0x44B60D4F6FDAC731, double f0x44CDF8C5AF17BA3B, double f0x44E45E3076D61699, double f0x44FBAED16A6E0DA7, double f0x4512CFFDFEBDE1A1, double f0x4529919CABEFCB69, double f0x454160345C9953E3, double f0x45579DBC9DC53C66, double f0x45700C810D464097, double f0x4585D009394C5C27, double f0x459DA57DE8F107A8, double f0x45B425982CF597CD, double f0x45CB61E5CA3A5E31, double f0x45E29BB825DFCF87, double f0x45F94A90DB0D6FE2, double f0x46112FEC759586FD, double f0x46275C1DC469E3AF, double f0x463FBFD219C43B04, double f0x4655936D44E1A146, double f0x466D531D8A7EE79C, double f0x4683ED9D24A2D51B, double f0x469B15CFE5B6E17B, double f0x46B268038C2C0E00, double f0x46C9044A73545D48, double f0x46E1002AB6218B38, double f0x46F71B3540CBF921, double f0x470F6799EA9C414A, double f0x47255779B984F3EB, double f0x473D01A210C44AA4, double f0x4753B63DA8E91210, double f0x476ACA8D6B0116B8, double f0x478234DE9E0C74E9, double f0x4798BEC7503CA477, double f0x47B0D0EDA9796B90, double f0x47C6DB0118477245, double f0x47DF1056DC7BF22D, double f0x47F51C2CC3433801, double f0x480CB108FFBEC164], comdat, align 16
@_ZN11__llvm_libc4math6EXP_M2E = linkonce_odr hidden local_unnamed_addr constant [128 x double] [double 1.000000e+00, double f0x3FF0202015600446, double f0x3FF04080AB55DE39, double f0x3FF06122436410DD, double f0x3FF08205601127ED, double f0x3FF0A32A84E9C1F6, double f0x3FF0C49236829E8C, double f0x3FF0E63CFA7AB09D, double f0x3FF1082B577D34ED, double f0x3FF12A5DD543CCC5, double f0x3FF14CD4FC989CD6, double f0x3FF16F9157587069, double f0x3FF192937074E0CD, double f0x3FF1B5DBD3F68122, double f0x3FF1D96B0EFF0E79, double f0x3FF1FD41AFCBA45E, double f0x3FF2216045B6F5CD, double f0x3FF245C7613B8A9B, double f0x3FF26A7793F60164, double f0x3FF28F7170A755FD, double f0x3FF2B4B58B372C79, double f0x3FF2DA4478B620C7, double f0x3FF3001ECF601AF7, double f0x3FF32645269EA829, double f0x3FF34CB8170B5835, double f0x3FF373783A722012, double f0x3FF39A862BD3C106, double f0x3FF3C1E2876834AA, double f0x3FF3E98DEAA11DCC, double f0x3FF41188F42C3E32, double f0x3FF439D443F5F159, double f0x3FF462707B2BAC21, double f0x3FF48B5E3C3E8186, double f0x3FF4B49E2AE5AC67, double f0x3FF4DE30EC211E60, double f0x3FF50817263C13CD, double f0x3FF5325180CFACF7, double f0x3FF55CE0A4C58C7C, double f0x3FF587C53C5A7AF0, double f0x3FF5B2FFF3210FD9, double f0x3FF5DE9176045FF5, double f0x3FF60A7A734AB0E8, double f0x3FF636BB9A983258, double f0x3FF663559CF1BC7C, double f0x3FF690492CBF9433, double f0x3FF6BD96FDD034A2, double f0x3FF6EB3FC55B1E76, double f0x3FF719443A03ACB9, double f0x3FF747A513DBEF6A, double f0x3FF776630C678BC1, double f0x3FF7A57EDE9EA23E, double f0x3FF7D4F946F0BA8D, double f0x3FF804D30347B546, double f0x3FF8350CD30AC390, double f0x3FF865A7772164C5, double f0x3FF896A3B1F66A0E, double f0x3FF8C802477B0010, double f0x3FF8F9C3FD29BEAF, double f0x3FF92BE99A09BF00, double f0x3FF95E73E6B1B75E, double f0x3FF99163AD4B1DCC, double f0x3FF9C4B9B995509B, double f0x3FF9F876D8E8C566, double f0x3FFA2C9BDA3A3E78, double f0x3FFA61298E1E069C, double f0x3FFA9620C6CB3374, double f0x3FFACB82581EEE54, double f0x3FFB014F179FC3B8, double f0x3FFB3787DC80F95F, double f0x3FFB6E2D7FA5EB18, double f0x3FFBA540DBA56E56, double f0x3FFBDCC2CCCD3C85, double f0x3FFC14B431256446, double f0x3FFC4D15E873C193, double f0x3FFC85E8D43F7CD0, double f0x3FFCBF2DD7D490F2, double f0x3FFCF8E5D84758A9, double f0x3FFD3311BC7822B4, double f0x3FFD6DB26D16CD67, double f0x3FFDA8C8D4A66969, double f0x3FFDE455DF80E3C0, double f0x3FFE205A7BDAB73E, double f0x3FFE5CD799C6A54E, double f0x3FFE99CE2B397649, double f0x3FFED73F240DC142, double f0x3FFF152B7A07BB76, double f0x3FFF539424D90F5E, double f0x3FFF927A1E24BB76, double f0x3FFFD1DE6182F8C9, double f0x400008E0F64294AB, double f0x40002912DF5CE72A, double f0x400049856CD84339, double f0x40006A39207F0A09, double f0x40008B2E7D2035CF, double f0x4000AC6606916501, double f0x4000CDE041B0E9AE, double f0x4000EF9DB467DCF8, double f0x4001119EE5AC36B6, double f0x400133E45D82E952, double f0x4001566EA50201D7, double f0x4001793E4652CC50, double f0x40019C53CCB3FC6B, double f0x4001BFAFC47BDA73, double f0x4001E352BB1A74AD, double f0x4002073D3F1BD518, double f0x40022B6FE02A3B9C, double f0x40024FEB2F105CB8, double f0x400274AFBDBBA4A6, double f0x400299BE1F3E7F1C, double f0x4002BF16E7D2A38C, double f0x4002E4BAACDB6614, double f0x40030AAA04E80D05, double f0x400330E587B62B28, double f0x4003576DCE33FEAD, double f0x40037E437282D4EE, double f0x4003A5670FF972ED, double f0x4003CCD9432682B4, double f0x4003F49AA9D30590, double f0x40041CABE304CB34, double f0x4004450D8F00EDD4, double f0x40046DC04F4E5338, double f0x400496C4C6B832DA, double f0x4004C01B9950A111, double f0x4004E9C56C731F5D, double f0x400513C2E6C731D7, double f0x40053E14B042F9CA, double f0x400568BB722DD593, double f0x400593B7D72305BB], comdat, align 16
@_ZZN11__llvm_libc6fputil7generic16fenv_is_round_upEvE1x = linkonce_odr hidden global float f0x33000000, comdat, align 4
@_ZN11__llvm_libc10libc_errnoE = external hidden global %"struct.__llvm_libc::Errno", align 1
@_ZZN11__llvm_libc6fputil7generic15quick_get_roundEvE1x = linkonce_odr hidden global float f0x33800000, comdat, align 4

; Function Attrs: mustprogress sspstrong uwtable
define hidden noundef float @_ZN11__llvm_libc4expfEf(float noundef %0) local_unnamed_addr #0 {
  %2 = tail call noundef float @_ZN11__llvm_libc4math11double_eval4expfEf(float noundef %0)
  ret float %2
}

; Function Attrs: inlinehint mustprogress sspstrong uwtable
define linkonce_odr hidden noundef float @_ZN11__llvm_libc4math11double_eval4expfEf(float noundef %0) local_unnamed_addr #1 comdat {
  %2 = bitcast float %0 to i32
  %3 = icmp eq i32 %2, -1036599924
  br i1 %3, label %4, label %7, !prof !10

4:                                                ; preds = %1
  %5 = fneg float %0
  %6 = tail call float @llvm.fmuladd.f32(float %5, float f0x10000000, float f0x1E88452C)
  br label %84

7:                                                ; preds = %1
  %8 = tail call float @llvm.fabs.f32(float %0)
  %9 = bitcast float %8 to i32
  %10 = add nsw i32 %9, -1118961664
  %11 = icmp ult i32 %10, -271712255
  br i1 %11, label %12, label %39, !prof !10

12:                                               ; preds = %7
  %13 = and i32 %2, 2130706432
  %14 = icmp samesign ult i32 %13, 855638016
  br i1 %14, label %15, label %17

15:                                               ; preds = %12
  %16 = fadd float %0, 1.000000e+00
  br label %84

17:                                               ; preds = %12
  %18 = icmp ugt i32 %2, -1026559564
  br i1 %18, label %19, label %27

19:                                               ; preds = %17
  %20 = icmp eq i32 %9, 2139095040
  br i1 %20, label %84, label %21

21:                                               ; preds = %19
  %22 = icmp samesign ugt i32 %9, 2139095040
  br i1 %22, label %84, label %23

23:                                               ; preds = %21
  %24 = tail call noundef zeroext i1 @_ZN11__llvm_libc6fputil7generic16fenv_is_round_upEv()
  br i1 %24, label %84, label %25

25:                                               ; preds = %23
  tail call void @_ZN11__llvm_libc6fputil21set_errno_if_requiredEi(i32 noundef 34)
  %26 = tail call noundef i32 @_ZN11__llvm_libc6fputil24raise_except_if_requiredEi(i32 noundef 16)
  br label %84

27:                                               ; preds = %17
  %28 = icmp sgt i32 %2, 1118961663
  br i1 %28, label %29, label %39

29:                                               ; preds = %27
  %30 = icmp samesign ult i32 %2, 2139095040
  br i1 %30, label %31, label %37

31:                                               ; preds = %29
  %32 = tail call noundef i32 @_ZN11__llvm_libc6fputil7generic15quick_get_roundEv()
  %33 = and i32 %32, -2049
  %34 = icmp eq i32 %33, 1024
  br i1 %34, label %84, label %35

35:                                               ; preds = %31
  tail call void @_ZN11__llvm_libc6fputil21set_errno_if_requiredEi(i32 noundef 34)
  %36 = tail call noundef i32 @_ZN11__llvm_libc6fputil24raise_except_if_requiredEi(i32 noundef 8)
  br label %37

37:                                               ; preds = %35, %29
  %38 = fadd float %0, +inf
  br label %84

39:                                               ; preds = %27, %7
  %40 = fmul float %0, 1.280000e+02
  %41 = tail call float @llvm.fabs.f32(float %40)
  %42 = fcmp olt float %41, f0x4B800000
  br i1 %42, label %43, label %58

43:                                               ; preds = %39
  %44 = fcmp olt float %40, 0.000000e+00
  %45 = fadd float %40, f0xCB000000
  %46 = fadd float %45, f0x4B000000
  %47 = fadd float %40, f0x4B000000
  %48 = fadd float %47, f0xCB000000
  %49 = select i1 %44, float %46, float %48
  %50 = fsub float %40, %49
  %51 = fcmp ogt float %50, 5.000000e-01
  br i1 %51, label %52, label %54, !prof !10

52:                                               ; preds = %43
  %53 = fadd float %49, 1.000000e+00
  br label %58

54:                                               ; preds = %43
  %55 = fcmp olt float %50, -5.000000e-01
  br i1 %55, label %56, label %58, !prof !10

56:                                               ; preds = %54
  %57 = fadd float %49, -1.000000e+00
  br label %58

58:                                               ; preds = %39, %52, %54, %56
  %59 = phi float [ %49, %54 ], [ %53, %52 ], [ %57, %56 ], [ %40, %39 ]
  %60 = fmul float %59, 7.812500e-03
  %61 = fsub float %0, %60
  %62 = fpext float %61 to double
  %63 = fptosi float %59 to i32
  %64 = add i32 %63, 13312
  %65 = ashr i32 %64, 7
  %66 = sext i32 %65 to i64
  %67 = getelementptr inbounds [8 x i8], ptr @_ZN11__llvm_libc4math6EXP_M1E, i64 %66
  %68 = load double, ptr %67, align 8, !tbaa !11
  %69 = and i32 %63, 127
  %70 = zext nneg i32 %69 to i64
  %71 = getelementptr inbounds nuw [8 x i8], ptr @_ZN11__llvm_libc4math6EXP_M2E, i64 %70
  %72 = load double, ptr %71, align 8, !tbaa !11
  %73 = fmul double %62, f0x3FA55555555EF243
  %74 = fadd double %73, f0x3FC555566668E5E7
  %75 = fmul double %74, %62
  %76 = fadd double %75, f0x3FE000000000071C
  %77 = fmul double %76, %62
  %78 = fadd double %77, f0x3FEFFFFFFFFFF777
  %79 = fmul double %78, %62
  %80 = fadd double %79, 1.000000e+00
  %81 = fmul double %68, %72
  %82 = fmul double %81, %80
  %83 = fptrunc double %82 to float
  br label %84

84:                                               ; preds = %31, %23, %21, %19, %58, %37, %25, %15, %4
  %85 = phi float [ %6, %4 ], [ %16, %15 ], [ %83, %58 ], [ 0.000000e+00, %19 ], [ %0, %21 ], [ 0.000000e+00, %25 ], [ %38, %37 ], [ 1.401300e-45, %23 ], [ f0x7F7FFFFF, %31 ]
  ret float %85
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #2

; Function Attrs: mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fmuladd.f32(float, float, float) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #2

; Function Attrs: inlinehint mustprogress noinline sspstrong uwtable
define linkonce_odr hidden void @_ZN11__llvm_libc6fputil21set_errno_if_requiredEi(i32 noundef %0) local_unnamed_addr #4 comdat {
  tail call void @_ZN11__llvm_libc5ErrnoaSEi(ptr noundef nonnull align 1 dereferenceable(1) @_ZN11__llvm_libc10libc_errnoE, i32 noundef %0)
  ret void
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

; Function Attrs: inlinehint mustprogress noinline nounwind sspstrong uwtable
define linkonce_odr hidden noundef zeroext i1 @_ZN11__llvm_libc6fputil7generic16fenv_is_round_upEv() local_unnamed_addr #5 comdat {
  %1 = load volatile float, ptr @_ZZN11__llvm_libc6fputil7generic16fenv_is_round_upEvE1x, align 4, !tbaa !13
  %2 = fadd float %1, 1.000000e+00
  %3 = fcmp une float %2, 1.000000e+00
  ret i1 %3
}

declare hidden void @_ZN11__llvm_libc5ErrnoaSEi(ptr noundef nonnull align 1 dereferenceable(1), i32 noundef) local_unnamed_addr #6

; Function Attrs: nounwind memory(argmem: write)
declare void @llvm.x86.sse.stmxcsr(ptr) #7

; Function Attrs: nounwind
declare void @llvm.x86.sse.ldmxcsr(ptr) #8

; Function Attrs: inlinehint mustprogress noinline nounwind sspstrong uwtable
define linkonce_odr hidden noundef i32 @_ZN11__llvm_libc6fputil7generic15quick_get_roundEv() local_unnamed_addr #5 comdat {
  %1 = load volatile float, ptr @_ZZN11__llvm_libc6fputil7generic15quick_get_roundEvE1x, align 4, !tbaa !13
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

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fabs.f32(float) #9

attributes #0 = { mustprogress sspstrong uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="inline-asm" "stack-protector-buffer-size"="4" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "zero-call-used-regs"="used-gpr" }
attributes #1 = { inlinehint mustprogress sspstrong uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="inline-asm" "stack-protector-buffer-size"="4" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "zero-call-used-regs"="used-gpr" }
attributes #2 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #4 = { inlinehint mustprogress noinline sspstrong uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="inline-asm" "stack-protector-buffer-size"="4" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "zero-call-used-regs"="used-gpr" }
attributes #5 = { inlinehint mustprogress noinline nounwind sspstrong uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "probe-stack"="inline-asm" "stack-protector-buffer-size"="4" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "zero-call-used-regs"="used-gpr" }
attributes #6 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="4" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "zero-call-used-regs"="used-gpr" }
attributes #7 = { nounwind memory(argmem: write) }
attributes #8 = { nounwind }
attributes #9 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }

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
!10 = !{!"branch_weights", !"expected", i32 1, i32 2000}
!11 = !{!12, !12, i64 0}
!12 = !{!"double", !8, i64 0}
!13 = !{!14, !14, i64 0}
!14 = !{!"float", !8, i64 0}
