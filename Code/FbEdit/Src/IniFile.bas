
#Include Once "windows.bi"

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\EditorOpt.bi"
#Include Once "Inc\Environment.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\Resource.bi"
#Include Once "Inc\SpecHandling.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\IniFile.bi"
#Include Once "Inc\showvars.bi"



Const szSecWin=		    	!"[Win]\13\10"_
								!"Winpos=0,0,0,850,600,127,0,0,162,221,514,107,10,10,0,180,150,10,10\13\10"_
								!"Colors=16777215,0,8404992,16777215,33587200,0,255,16777215,15393755,15329769,15987699,11184810,0,0,16777215,16777215,16777215,16777215,65535,65280,16777215,0,16777215,0,16777215,0,14024703,0,8404992,128,128\13\10"_
								!"Ressize=257,170,0,52,100,100\13\10"_
								!"Version=1078\13\10"
Const szSecTheme=			!"[Theme]\13\10"_
								!"Current=8\13\10"_
								!"1=Default,128,128,128,8421440,8388608,128,128,128,128,16777344,536871040,128,128,10485760,10485760,10485760,65535,65535,65535,285147264,276824319,14024703,268435456,276840448,16777215,4227072,10485760,255,15329769,12632256,12632256,12632256,8421504,8404992,8421504,14024703,14024703,14024703,14024703,65535,65280,14024703,8404992,13828050,8404992,14024703,0,14024703,0,4194432,16711680,210\13\10"_
								!"2=Black Night,16744448,16744448,16744448,8421440,16711680,33521664,16744448,16744448,16744448,33521664,553615360,16744448,4227327,16711680,16711680,16711680,65535,65535,65535,285147264,276824319,0,12632256,10485760,16777215,8454143,16777215,255,4868682,15420,3158064,12632256,8421504,8388608,8421504,0,0,0,0,65535,65280,12644592,8388672,14745568,8388608,12644592,0,14024703,0,4194432,16711680,210\13\10"_
								!"3=Soothe,16744576,16744576,16744576,16739583,16744576,16744576,16744576,16744576,16744576,16733097,553604009,16744576,16744576,16744576,16744576,16744576,65535,65535,65535,285147264,276824319,12632256,16711680,33592725,11448063,8388863,4737096,4737096,6160571,12632256,8421504,10485760,65535,4868682,16777215,12632256,12632256,12632256,12632256,65535,65280,0,16777215,16777215,0,12644592,0,14024703,0,4194432,16711680,210\13\10"_
								!"4=Breeze,0,16777216,33488896,16777216,16711680,33488896,16777216,16777216,16777216,16777216,536903680,32768,33258752,25198656,8421440,27262976,8454143,8454143,8454143,285147136,285147136,16777215,0,7303023,16777215,42699659,9718089,16744448,15329769,15393755,15329769,12632256,8421504,10485760,16711680,16777215,16777215,16777215,16777215,65535,65280,16316664,0,16777215,0,16777215,0,14024703,0,4194432,16711680,210\13\10"_
								!"5=BlueFB,16744448,16744448,16744448,8421440,16711680,16744448,16744448,16744448,16744448,33521664,553615360,16744448,4227327,16711680,16711680,16711680,8454143,8454143,8454143,285147136,285147136,16777215,0,10485760,16777215,33587200,0,255,16053503,12058623,3158064,12632256,8421504,8388608,8421504,16777215,16777215,16777215,16777215,65535,65280,12644592,8388672,14745568,8388608,16777215,0,14024703,0,4194432,16711680,210\13\10"_
								!"6=Connexion,0,16777216,20077117,16777216,2641712,19420468,16777216,16777216,16777216,16777216,536903680,2839859,19085417,22244027,5466811,19875931,65535,65535,65535,285147264,276824319,13827839,3032109,35141665,8518654,35075430,16777216,20932945,15329769,12632256,8421504,2112547,2310965,16316664,0,13827839,13827839,13827839,13827839,65535,65280,14155519,0,16777215,0,14286591,1847076,14024703,0,4194432,16711680,255\13\10"_
								!"7=Mr. Houndcat,12632256,31580641,33534128,32238571,16711680,33554176,16830158,28751542,28751542,30264781,549239996,12369084,30527953,25198656,8421440,20988159,65535,65535,65535,285147264,276824319,0,9869003,45594551,0,26561024,11974326,30988504,15329769,2894892,8421504,0,65535,11053224,10461087,0,0,0,0,65535,65280,0,6993407,4802889,45232,0,50372,14024703,0,4194432,16711680,210\13\10"_
								!"8=Visual Studio,8404992,8404992,8404992,8404992,8404992,8404992,8404992,8404992,8404992,8404992,545275904,8404992,8404992,8404992,8404992,8404992,8404992,10485760,8404992,276840448,276840448,16777215,0,8404992,16777215,33587200,0,255,16777215,15393755,15329769,15987699,11184810,0,0,16777215,16777215,16777215,16777215,65535,65280,16777215,0,16777215,0,16777215,0,14024703,0,8404992,16711680,210\13\10"
Const szSecEdit1=			!"[Edit]\13\10"_
								!"EditFont=-13,0,Dina,400,0\13\10"_
								!"LnrFont=-13,0,Dina,400,0\13\10"_
								!"OutpFont=-11,0,Dina,400,0\13\10"_
								!"ToolFont=-13,0,Tahoma,400,0\13\10"_
								!"EditOpt=3,0,0,1,0,1,3,1,0,1,1,1,1,0,0,1,1,1,1,1\13\10"_
								!"CodeFiles=.bas.bi.\13\10"_
								!"CaseConvert=ACPSTWcdemnopsxyz\13\10"_
								!"CustColors=14024703,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0\13\10"_
								!"Colors=8388608,8388608,8388608,8388608,8388608,8388608,8388608,8388608,8388608,8388608,545259520,8388736,8388608,8388608,8388608,8388608,16744576,16711680,8421376,276824064,276824064\13\10"
Const szSecEdit2=			!"C0=\34Abs ACos ASin ATan2 Atn Cos Exp Fix Frac Int Log Randomize Rnd Sgn Sin Sqr Tan \34\13\10"_
								!"C1=\34Screen ScreenControl ScreenCopy ScreenEvent ScreenGLProc ScreenInfo ScreenList ScreenLock ScreenPtr ScreenRes ScreenSet ScreenSync ScreenUnLock \34\13\10"_
								!"C2=\34And AndAlso Delete Eqv Imp Let Mod New Not Or OrElse ProcPtr Shl Shr StrPtr VarPtr Xor \34\13\10"_
								!"C3=\34$Dynamic $Include $Lang $Static #Define #Else #ElseIf #EndIf #EndMacro #Error #If #Ifdef #Ifndef #Inclib #Include #Lang #LibPath #Line #Macro #Pragma #Print #Undef \34\13\10"_
								!"C4=\34CByte CDbl CInt CLng CLngInt CPtr CShort CSign CSng CUByte CUInt CULng CULngint CUnsg CUShort CVD CVI CVL CVLongInt CVS CVShort \34\13\10"_
								!"C5=\34Base Second Seek SetDate SetEnviron SetMouse SetTime Shell SizeOf Sleep Space Spc Static StdCall Stick Stop Str Strig Swap System Scrn Tab This ThreadCall ThreadCreate ThreadWait Time Timer TimeSerial TimeValue To Trans Trim TypeOf UBound UCase Union UnLock Unsigned Until Using va_arg va_first va_next Val ValInt ValLng ValUInt ValULng Var View Wait WBin WChr Weekday WeekdayName WHex Width Window WindowTitle WInput With WOct Write WSpace WStr Year \34\13\10"_
								!"C6=\34Access Add Alias Allocate Alpha Append Asc Asm Assert AssertWarn Beep Bin Binary Bit BitReset BitSet BLoad BSave Call CAllocate Cast Cdecl Chain ChDir Chr Circle Class Clear Close Cls Color Command Common CondBroadcast CondCreate CondDestroy CondSignal CondWait Continue CsrLin CurDir Data Date DateAdd DateDiff DatePart DateSerial DateValue Day DeAllocate DefByte DefDbl Defined DefInt DefLng DefLongInt \34\13\10"_
								!"C7=\34DefShort DefSng DefStr DefUByte DefUInt DefULongInt DefUShort Dir Draw DyLibFree DyLibLoad DyLibSymbol Encoding Enum Environ Eof Erase Erfn Erl Ermn Err Error Exec ExePath Exit Explicit Export Extern Field FileAttr FileCopy FileDateTime FileExists FileLen Flip Format Frac Fre FreeFile Get GetJoystick GetKey GetMouse GoSub GoTo Hex HiByte HiWord Hour IIf ImageConvertRow ImageCreate ImageDestroy ImageInfo Import InKey Inp Input InStr InStrRev Is IsDate Kill LBound LCase Left Len Lib Line LoByte Loc Local Locate Lock Lof LoWord LPos LPrint LSet LTrim \34\13\10"_
								!"C8=\34ByRef ByVal As Shared Cons Custom Extends GoSub GoTo Lpt Mid Minute Mkd MkDir Mki Mkl MkLongInt Mks MkShort Month MonthName MultiKey MutexCreate MutexDestroy MutexLock MutexUnLock Name Nogosub NoKeyword Now Oct OffsetOf On Once Open Option Out Output Overload Paint Palette Pascal PCopy Peek Pipe PMap Point Pointer Poke Pos Preserve PReset Print Private Private Protected PSet Public Put Random Read ReAllocate ReDim Rem Reset Restore Resume Return RGB RGBA Right RmDir RSet RTrim Run SAdd Scope \34\13\10"_
								!"C9=\34Const Case Constructor Declare Destructor Dim If Then Else ElseIf End EndIf For Do Loop While Wend Function Namespace Next Operator Property Select Step Sub Then Type \34\13\10"_
								!"C10=\34#define #include ACCELERATORS ALT AUTOCHECKBOX AUTORADIOBUTTON BEGIN BITMAP BLOCK CAPTION CLASS COMBOBOX CONTROL CURSOR DIALOGEX DISCARDABLE EDITTEXT END EXSTYLE FALSE FILEOS FILETYPE FILEVERSION FONT GROUPBOX ICON LISTBOX LTEXT MENU MENUITEM NOINVERT NULL POPUP PRODUCTVERSION PUSHBUTTON SEPARATOR SHIFT STRINGTABLE STYLE TRUE VALUE VERSIONINFO VIRTKEY \34\13\10"_
								!"C11=\34__DATE__ __DATE_ISO__ __FB_ARGC__ __FB_ARGV__ __FB_BIGENDIAN__ __FB_BUILD_DATE__ __FB_CYGWIN__ __FB_DEBUG__ __FB_DOS__ __FB_ERR__ __FB_FPMODE__ __FB_FPU__ __FB_FREEBSD__ __FB_LANG__ __FB_LINUX__ __FB_MAIN__ __FB_MIN_VERSION__ __FB_MT__ __FB_NETBSD__ __FB_OPENBSD__ __FB_OPTION_BYVAL__ __FB_OPTION_DYNAMIC__ __FB_OPTION_ESCAPE__ __FB_OPTION_EXPLICIT__ __FB_OPTION_GOSUB__ __FB_OPTION_PRIVATE__ __FB_OUT_DLL__ __FB_OUT_EXE__ __FB_OUT_LIB__ __FB_OUT_OBJ__ __FB_PCOS__ __FB_SIGNATURE__ __FB_SSE__ __FB_UNIX__ __FB_VECTORIZE__ __FB_VER_MAJOR__ __FB_VER_MINOR__ __FB_VER_PATCH__ __FB_VERSION__ __FB_WIN32__ __FB_XBOX__ __FILE__ __FILE_NQ__ __FUNCTION__ __FUNCTION_NQ__ __LINE__ __PATH__ __TIME__ \34\13\10"_
								!"C12=\34Any Byte Double Integer Long LongInt Object Ptr Short Single String UByte UInteger ULong ULongInt UShort WString ZString \34\13\10"_
								!"C13=\34\34\13\10"_
								!"C14=\34\34\13\10"_
								!"C15=\34\34\13\10"_
								!"C16=\34\34\13\10"_
								!"C17=\34\34\13\10"_
								!"C18=\34\34\13\10"
Const szSecEdit3=			!"C19=\34adc add addpd addps addsd addss and andnpd andnps andpd andps arpl asm bound bsf bsr bswap bt btc btr bts call cbw cdq clc cld clflush cli clts cmc cmova cmovae cmovb cmovbe cmovc cmove cmovg cmovge cmovl cmovle cmovna cmovnae cmovnb cmovnbe cmovnc cmovne cmovng cmovnge cmovnl cmovnle cmovno cmovnp cmovns cmovnz cmovo cmovp cmovpe cmovpe cmovpo cmovs cmovz cmp cmppd cmpps cmps cmpsb cmpsd cmpss cmpsw cmpxchg cmpxchg8b comisd comiss cpuid cvtdq2pd cvtdq2ps cvtpd2dq cvtpd2pi cvtpd2ps cvtpi2pd cvtpi2ps cvtps2dq cvtps2pd cvtps2pi cvtsd2si cvtsd2ss cvtsi2sd cvtsi2ss cvtss2sd cvtss2si cvttpd2dq cvttpd2pi cvttps2dq cvttps2pi cvttsd2si cvttss2si cwd cwde das dec div divpd divps divss daa emms end enter "
Const szSecEdit4=			!"f2xm1 fabs fadd faddp fbld fbstp fchs fclex fcmovb fcmovbe fcmove fcmovnb fcmovnbe fcmovne fcmovnu fcmovu fcom fcomi fcomip fcomp fcompp fcos fdecstp fdiv fdivp fdivr fdivrp femms ffree fiadd ficom ficomp fidiv fidivr fild fimul fincstp finit fist fistp fisub fisubr fld fld1 fldcw fldenv fldl2e fldl2t fldlg2 fldln2 fldpi fldz fmul fmulp fnclex fninit fnop fnsave fnstcw fnstenv fnstsw fpatan fprem fprem1 fptan frndint frstor fsave fscale fsin fsincos fsqrt fst fstcw fstenv fstp fstsw fsub fsubp fsubr fsubrp ftst fucom fucomi fucomip fucomp fucompp fwait fxam fxch fxrstor fxsave fxtract fyl2x fyl2xp1 hlt idiv imul in inc ins insb insd insw int int3 into invd invlpg iret iretd ja jae jb jbe jc jcxz je jecxz jg jge jl jle jmp jna jnae jnb jnbe jnc jne jng jnge jnl jnle jno jnp jns jnz jo jp jpe jpo js jz lahf lar ldmxcsr lds lea leave les lfence lfs lgdt lgs lidt lldt lmsw lock lods lodsb lodsd lodsw loop loope loopne loopnz loopz lsl lss ltr "
Const szSecEdit5=			!"maskmovdqu maskmovq maxpd maxps maxsd maxss mfence minpd minps minsd minss mov movapd movaps movd movdq2q movdqa movdqu movhlps movhpd movhps movlhps movlpd movlps movmskpd movmskps movntdq movnti movntpd movntps movntq movq movq2dq movs movsb movsd movss movsw movsx movupd movups movzx mul mulpd mulps mulsd mulss neg nop not or orpd orps out outs outsb outsd outsw packssdw packsswb packuswb paddb paddd paddq paddsb paddsw paddusb paddusw paddw pand pandn pause pavgb pavgusb pavgw pcmpeqb pcmpeqd pcmpeqw pcmpgtb pcmpgtd pcmpgtw pextrw pf2id pf2iw pfacc pfadd pfcmpeq pfcmpge pfcmpgt pfmax pfmin pfmul pfnacc pfpnacc pfrcp pfrcpit1 pfrcpit2 pfrsqit1 pfrsqrt pfsub pfsubr pi2fd pi2fw pinsrw pmaddwd pmaxsw pmaxub pminsw pminub pmovmskb pmulhrw pmulhuv pmulhuw pmulhw pmullw pmuludq pop popa popad popf popfd por prefetch prefetchnta prefetcht0 prefetcht1 prefetcht2 prefetchw psadbw pshufd pshufhw pshuflw pshufw pslld psllq psllw psrad psraw psrld psrldq psrlq psrlw "
Const szSecEdit6=			!"psubb psubd psubq psubsb psubsw psubusb psubusw psubw pswapd pswapw punpckhbw punpckhdq punpckhqdq punpckhwd punpcklbw punpckldq punpcklqdq punpcklwd push pusha pushad pushf pushfd pxor rcl rcpps rcpss rcr rdmsr rdpmc rdtsc rep repe repne repnz repz ret rol ror rsm rsqrtps rsqrtss sahf sal sar sbb scas scasb scasd scasw seta setae setb setbe setc sete setg setge setl setle setna setnae setnb setnbe setnc setne setng setnge setnl setnle setno setnp setns setnz seto setp setpe setpo sets setz sfence sgdt shl shld shr shrd shufpd shufps sidt sldt smsw sqrtpd sqrtps sqrtsd sqrtss stc std sti stmxcsr stos stosb stosd stosw str sub subpd subps subsd subss sysenter sysexit test ucomisd ucomiss ud2 unpckhpd unpckhps unpcklpd unpcklps verr verw wait wbinvd wrmsr xadd xchg xlat xlatb xor xorpd xorps aaa aad aam aas \34\13\10"
Const szSecEdit7=			!"C20=\34ah al ax bh bl bp bx byte ch cl cx dh dl dword dx eax ebp ebx ecx edi edx esi esp mm0 mm1 mm2 mm3 mm4 mm5 mm6 mm7 offset ptr qword sp st(0) st(1) st(2) st(3) st(4) st(5) st(6) st(7) word xmm0 xmm1 xmm2 xmm3 xmm4 xmm5 xmm6 xmm7 \34\13\10"_
								!"C21=\34\34\13\10"
Const szSecBlock=			!"[Block]\13\10"_
								!"0=%private %public function $,End Function,,,6\13\10"_
								!"1=%private %public sub $,End Sub,,,6\13\10"_
								!"2=type!as,End Type,,,4\13\10"_
								!"3=union,End Union,,,4\13\10"_
								!"4=namespace $,End Namespace,,,4\13\10"_
								!"5='{,'},,,4\13\10"_
								!"6=/','/,,,36\13\10"_
								!"7=constructor $,End Constructor,,,6\13\10"_
								!"8=destructor $,End Destructor,,,6\13\10"_
								!"9=property $,End Property,,,6\13\10"_
								!"10=enum $,End Enum,,,4\13\10"_
								!"11=#macro $,#EndMacro,,,6\13\10"_
								!"12=select case !end select,End Select,case,,0\13\10"_
								!"13=if $! then,EndIf|End If,elseif,else,0\13\10"_
								!"14=do!loop,Loop,,,0\13\10"_
								!"15=while $ !wend,Wend,,,0\13\10"_
								!"16=for $ !next,Next,,,0\13\10"_
								!"17=operator#(,End Operator,,,6\13\10"_
								!"18=with $,End With,,,0\13\10"_
								!"19=asm,End Asm,,,192\13\10"_
								!"20=class $,End Class,,,4\13\10"
Const szSecAutoFormat=	!"[AutoFormat]\13\10"_
								!"0=if $! then,0,0,1\13\10"_
								!"1=endif,0,0,0\13\10"_
								!"2=end if,0,0,0\13\10"_
								!"3=elseif,0,0,1\13\10"_
								!"4=else,0,0,1\13\10"_
								!"5=select case,5,0,1\13\10"_
								!"6=case,5,0,1\13\10"_
								!"7=end select,5,0,0\13\10"_
								!"8=while $ !wend,8,0,1\13\10"_
								!"9=wend,8,0,0\13\10"_
								!"10=do,10,0,1\13\10"_
								!"11=loop,10,0,0\13\10"_
								!"12=for $,12,0,1\13\10"_
								!"13=next,12,0,0\13\10"_
								!"14=type!as,14,0,1\13\10"_
								!"15=end type,14,0,0\13\10"_
								!"16=%private %public sub $,16,0,1\13\10"_
								!"17=end sub,16,0,0\13\10"_
								!"18=%private %public function $,18,0,1\13\10"_
								!"19=end function,18,0,0\13\10"_
								!"20=operator#(,20,0,1\13\10"_
								!"21=end operator,20,0,0\13\10"_
								!"22=namespace $,22,0,1\13\10"_
								!"23=end namespace,22,0,0\13\10"_
								!"24=with $,24,0,1\13\10"_
								!"25=end with,24,0,0\13\10"_
								!"26='{,26,0,1\13\10"_
								!"27='},26,0,0\13\10"_
								!"28=asm,28,0,1\13\10"_
								!"29=end asm,28,0,0\13\10"_
								!"30=constructor $,30,0,1\13\10"_
								!"31=end constructor,30,0,0\13\10"_
								!"32=destructor $,32,0,1\13\10"_
								!"33=end destructor,32,0,0\13\10"_
								!"34=enum,34,0,1\13\10"_
								!"35=end enum,34,0,0\13\10"_
								!"36=class $,36,0,1\13\10"_
								!"37=end class,36,0,0\13\10"
Const szSecResource=		!"[Resource]\13\10"_
								!"Export=1,2,0,rsrc.bi\13\10"_
								!"Grid=3,3,1,1,1,32896,0,1,0,0,0,1\13\10"
Const szSecTools=			!"[Tools]\13\10"_
								!"1=&Calculator,calc.exe\13\10"_
								!"2=&Notepad,notepad.exe\13\10"_
								!"3=Paint,mspaint.exe\13\10"_
								!"4=Explore Projects,explorer.exe /e,\34%PROJECTS_PATH%\34\13\10"_
								!"5=Command prompt,cmd.exe /k \34%FBC_PATH%\\fbc.exe\34 -version && title FreeBASIC && path %FBC_PATH%;%PATH%\13\10"_
								!"6=Compiler Version,cmd.exe /k \34%FBC_PATH%\\fbc.exe\34 -version\13\10"_
								!"7=ApiFileCreator,\34%FBEDIT_PATH%\\Tools\\MakeApi.exe\34 \34%FBEDIT_PATH%\34\13\10"
Const szSecHelp=			!"[Help]\13\10"_
								!"1=Win32 Reference,winhlp32.exe \34%HELP_PATH%\\win32.hlp\34\13\10"_
								!"2=FreeBASIC,hh.exe \34%HELP_PATH%\\FB.chm\34\13\10"_
								!"3=Window Styles,hh.exe \34%HELP_PATH%\\Windows_styles.chm\34\13\10"_
								!"4=FbEdit Help,hh.exe \34%HELP_PATH%\\FbEdit.chm\34\13\10"_
								!"5=binutils,hh.exe \34%HELP_PATH%\\binutils.chm\34\13\10"_
								!"CtrlF1=hh.exe \34%HELP_PATH%\\FB.chm\34\13\10"_
								!"F1=\34%HELP_PATH%\\WIN32.HLP\34\13\10"_
								!"FbEdit=\34%HELP_PATH%\\FbEdit.chm\34\13\10"
'Const szSecProject=		    !"[Project]\13\10"
Const szSecMake=			!"[Make]\13\10"_
								!"Current=3\13\10"_
								!"1=Windows GUI,fbc -s gui\13\10"_
								!"2=Windows GUI (debug),fbc -g -s gui\13\10"_
								!"3=Windows Console,fbc -s console\13\10"_
								!"4=Windows Console (debug),fbc -g -s console\13\10"_
								!"5=Deprecated GUI,fbc -lang deprecated -s gui\13\10"_
								!"6=Deprecated GUI (debug),fbc -lang deprecated -g -s gui\13\10"_
								!"7=Deprecated Console,fbc -lang deprecated -s console\13\10"_
								!"8=Deprecated Console (debug),fbc -lang deprecated -g -s console\13\10"_
								!"9=QB GUI,fbc -lang qb -s gui\13\10"_
								!"10=QB GUI (debug),fbc -lang qb -g -s gui\13\10"_
								!"11=QB Console,fbc -lang qb -s console\13\10"_
								!"12=QB Console (debug),fbc -lang qb -g -s console\13\10"_
								!"13=Windows dll,fbc -s gui -dll -export\13\10"_
								!"14=Library,fbc -lib\13\10"_
								!"15=Module Build,fbc -c\13\10"
Const szSecOpen=			!"[Open]\13\10"_
								!"Extern=.bmp.png.pdf.bat.cmd.\13\10"
Const szSecApi=			    !"[Api]\13\10"_
								!"Api=fb (FreeBASIC),gdip (Gdi+),ogl (OpenGL),sv (Showvars),win (Windows),wx (wx Widgets),fmod (fmod Sound),rae (RAEdit),rap (RAProperty),racc (RACodeComplete),raf (RAFile),rah (RAHexEd),rag (RAGrid),rar (RAResEd),spr (SpreadSheet)\13\10"_
								!"DefApi=fb (FreeBASIC)\13\10"_
								!"Call=fbCall.api,gdipCall.api,oglCall.api,winCall.api,wxCall.api,svCall.api,fmodCall.api\13\10"_
								!"Const=fbConst.api,oglConst.api,winConst.api,svConst.api,raeConst.api,rapConst.api,raccConst.api,rafConst.api,rahConst.api,ragConst.api,rarConst.api,sprConst.api\13\10"_
								!"Struct=fbStruct.api,gdipStruct.api,winStruct.api,fmodStruct.api,raeStruct.api,rapStruct.api,raccStruct.api,rafStruct.api,rahStruct.api,ragStruct.api,rarStruct.api,sprStruct.api\13\10"_
								!"Word=fbWord.api,winWord.api,fmodWord.api,raeWord.api,rapWord.api,raccWord.api,rafWord.api,rahWord.api,ragWord.api,rarWord.api,sprWord.api\13\10"_
								!"Type=fbType.api,oglType.api,winType.api\13\10"_
								!"Case=fbCase.api\13\10"_
								!"Desc=fbDesc.api,winDesc.api\13\10"_
								!"Msg=winMsg.api,raeMsg.api,rapMsg.api,raccMsg.api,rafMsg.api,rahMsg.api,ragMsg.api,rarMsg.api,sprMsg.api\13\10"_
								!"Enum=fmodEnum.api,raeEnum.api,rapEnum.api\13\10"
Const szSecDebug=			!"[Debug]\13\10"_
								!"Debug=%ProgramFiles(x86)%\\FBdebugger\\FBdebugger.exe\13\10"
Const szSecTemplate=		!"[Template]\13\10"_
								!"txtfiles=.bas.bi.rc.txt.xml.\13\10"_
								!"binfiles=.bmp.jpg.ico.cur.\13\10"
Const szSecPrinter=		    !"[Printer]\13\10"_
								!"Page=21000,29700,1000,1000,1000,1000,66\13\10"
Const szSecLanguage=		!"[Language]\13\10"_
								!"Language=(None)\13\10"
Const szSecSniplet=		    !"[Sniplet]\13\10"_
								!"WinPos=10,10,800,600\13\10"
Const szSecToolbar=		    !"[Toolbar]\13\10"_
								!"WinPos=10,10,577,475\13\10"
Const szSecFileTab=		    !"[FileTabStyler]\13\10"_
								!"Style=1\13\10"_
								!"Fixed=0\13\10"_
								!"ModStyle=2\13\10"
Const szSecShowVars=		!"[ShowVars]\13\10"_
								!"Dock=1,10,10,300,200,0,0,0,2500\13\10"
Const szSecProjectZip=	    !"[ProjectZip]\13\10"_
								!"pos=407,384,466,255\13\10"_
								!";Optional. Skip all files in folder \\bak\13\10"_
								!"skip=\\bak\13\10"_
								!";Optional. Folder where to put zip files\13\10"_
								!"folder=C:\\Archive\13\10"_
								!";Optional incluse date=1 or datetime=2\13\10"_
								!"opt=2\13\10"
Const szSecRegExLib=        !"[RegExLib]\13\10"_
                                $"1=Function Returning String,function [_a-z\d]* *\([,_ a-z\d]*\) as string" !"\13\10"


Sub IniKeyNotFoundMsg (ByVal pSectionName As ZString Ptr, ByVal pKeyName As ZString Ptr)

    TextToOutput "*** ini file error ***", MB_ICONHAND
    TextToOutput "Section: [" + *pSectionName + "], Key: " + *pKeyName + ", not found in " + ad.IniFile

End Sub

Sub SaveToIni (ByVal pSection As ZString Ptr, ByVal pKey As ZString Ptr, ByRef Types As ZString, ByVal pStruct As Any Ptr, ByVal fProject As Boolean)
	
	Dim value   As ZString * 4096
	Dim buffer  As ZString * 256
	Dim i       As Integer        = Any
	Dim ofs     As Integer        = Any
    Dim pAppend As ZString Ptr    = Any

    ofs = 0
    i = 0
	Do	
		Select Case Types[i]
		Case Asc ("4")                           			' DWORD (32bit unsigned)
	        buffer = Str (*Cast (DWORD Ptr, pStruct + ofs))
		    pAppend = @buffer
		    ofs += SizeOf (DWORD)

		Case Asc ("5")                           			' Long (32bit signed)
	        buffer = Str (*Cast (Long Ptr, pStruct + ofs))
		    pAppend = @buffer
		    ofs += SizeOf (Long)

		Case Asc ("0")                               	    ' *(ZString Ptr)
            pAppend = *Cast (ZString Ptr Ptr, pStruct + ofs)
			ofs += SizeOf (ZString Ptr)
	
	    Case Asc ("1")                                      ' Byte
			buffer = Str (*Cast (Byte Ptr, pStruct + ofs))
		    pAppend = @buffer
			ofs += SizeOf (Byte)                            ' caution: needs udt field = 1
		    			
		Case Asc ("2")                                      ' Word
			buffer = Str (*Cast (WORD Ptr, pStruct + ofs))
		    pAppend = @buffer
			ofs += SizeOf (WORD)

		Case Asc ("9")                 ' String * LF_FACESIZE
			pAppend =  Cast (ZString Ptr , pStruct + ofs)
			ofs += LF_FACESIZE
		
		Case 0                                              ' end of format string
		    Exit Do
		
		Case Else
		    Exit Do                                         ' error in format string
		
		End Select

        If IsZStrEmpty (value) Then
  			lstrcat @value, pAppend
        Else
            ZStrCat @value, SizeOf (value), 2, @",", pAppend
        EndIf

	    i += 1
	Loop
	
	If fProject Then
		WritePrivateProfileString pSection, pKey, @value, @ad.ProjectFile
	Else
		WritePrivateProfileString pSection, pKey, @value, @ad.IniFile
	EndIf
	
End Sub

'Sub SaveToIni(ByVal lpszApp As ZString Ptr,ByVal lpszKey As ZString Ptr,Byref lpszTypes As ZString,ByVal lpDta As Any Ptr,ByVal fProject As Boolean)
'	Dim value As ZString*4096
'	Dim i As Integer = Any
'	Dim ofs As Integer
'	'Dim tmp As ZString*260                          ' MOD 25.1.2012
'	Dim v As Integer = Any
'	Dim p As ZString Ptr
'	
'	i = 0
'	Do	
'		v = 0
'		Select Case lpszTypes[i]                 ' MOD 25.1.2012  Case lpszTypes[i]-48
'		Case 0
'		    Exit Do
'		Case Asc ("0")                           ' MOD 25.1.2012  Case 0
'			' String
'			RtlMoveMemory(@p,lpDta+ofs,4)
'			value=value & ","
'			lstrcat(@value,p)
'			ofs=ofs+4
'	    Case Asc ("1")                           ' MOD 25.1.2012  Case 1
'			' Byte
'			RtlMoveMemory(@v,lpDta+ofs,1)
'			ofs=ofs+1
'			value=value & "," & Str(v)
'	    Case Asc ("2")                           ' MOD 25.1.2012  Case 2
'			' Word
'			RtlMoveMemory(@v,lpDta+ofs,2)
'			ofs=ofs+2
'			value=value & "," & Str(v)
'		Case Asc ("4")                           ' MOD 25.1.2012  Case 4
'			' DWord
'			'RtlMoveMemory(@v,lpDta+ofs,4)
'			
'			value=value & "," & Str (*Cast (DWORD Ptr, lpDta + ofs))
'			ofs += 4
'		End Select
'        i += 1
'	Loop
'
'	value=Mid(value,2)
'	
'	If fProject Then
'		WritePrivateProfileString lpszApp, lpszKey, @value, @ad.ProjectFile   ' MOD 25.1.2012  tmp=ad.ProjectFile
'	Else
'		WritePrivateProfileString lpszApp, lpszKey, @value, @ad.IniFile       ' MOD 25.1.2012  tmp=ad.IniFile
'	EndIf
'	                                                                          ' MOD 25.1.2012  WritePrivateProfileString(lpszApp,lpszKey,@value,@tmp)
'End Sub

Function LoadFromIni(ByVal lpszApp As ZString Ptr,ByVal lpszKey As ZString Ptr,Byref szTypes As zString,ByVal lpDta As Any Ptr,ByVal fProject As Boolean) As Boolean
	Dim i As Integer = any
	Dim ofs As Integer
	Dim tmp As ZString*256
	Dim v As Integer
	Dim p As ZString Ptr
	Dim szDta As ZString*4096
    Dim pIniFile As ZString Ptr = Any

	If fProject Then
		pIniFile = @ad.ProjectFile
	Else
		pIniFile = @ad.IniFile
	EndIf
	
	If GetPrivateProfileString (lpszApp, lpszKey, NULL, @szDta, SizeOf (szDta), pIniFile) Then
		For i=1 To Len(szTypes)
			v=0
			Select Case Asc(szTypes,i)-48
				Case 0
					' String
					RtlMoveMemory(@p,lpDta+ofs,4)
					If InStr(szDta,",") Then
						tmp=Left(szDta,InStr(szDta,",")-1)
					Else
						tmp=szDta
					EndIf
					lstrcpy(p,@tmp)
					ofs=ofs+4
				Case 1
					' Byte
					If IsZStrNotEmpty (szDta) Then
						v=Val(szDta)
						RtlMoveMemory(lpDta+ofs,@v,1)
					EndIf
					ofs=ofs+1
				Case 2
					' Word
					If IsZStrNotEmpty (szDta) Then
						v=Val(szDta)
						RtlMoveMemory(lpDta+ofs,@v,2)
					EndIf
					ofs=ofs+2
			    Case 4, 5
					' DWORD, Long
					If IsZStrNotEmpty (szDta) Then
						v=Val(szDta)
						RtlMoveMemory(lpDta+ofs,@v,4)
					EndIf
					ofs=ofs+4
				Case 9
					' String * LF_FACESIZE
					p = Cast(ZString Ptr, lpDta+ofs)
					If InStr(szDta,",") Then
						tmp=Left(szDta,InStr(szDta,",")-1)
					Else
						tmp=szDta
					EndIf
					*p=tmp
					ofs+=LF_FACESIZE
			End Select
			If InStr(szDta,",") Then
				szDta=Mid(szDta,InStr(szDta,",")+1)
			Else
				SetZStrEmpty (szDta)             'MOD 26.1.2012
			EndIf
		Next
	Else
		Return FALSE
	EndIf
	Return TRUE

End Function

Sub UpdateSection(Byref sName As zString,Byref sBlock As zString)
	Dim As Integer i,l

	buff=sBlock
	buff=Mid(buff,Len(sName)+5)        ' "[" + "]" + "\13" + "\10" + 1
	i=1
	While i
		i=InStr(buff,!"\13\10")
		If i Then
			buff=Left(buff,i) & Mid(buff,i+2)
		EndIf
	Wend
	i=0
	l=Len(buff)
	While i<l
		If buff[i]=13 Then
			buff[i]=0
		EndIf
		i+=1
	Wend
	buff[i]=0
	
	WritePrivateProfileSection(sName, @buff, @ad.IniFile)

End Sub

Sub UpdateColorsTo1065()
	Dim i As Integer
	Dim thm As THEME
	Dim Theme As ZString*32

	LoadFromIni("Win", "Colors", "444444444444444444444444444444444", @fbcol, FALSE)
	fbcol.propertiespar=fbcol.codetipback
	fbcol.codetipsel=fbcol.codelisttext
	fbcol.codetipapi=fbcol.codelistback
	fbcol.codetiptext=fbcol.dialogtext
	fbcol.codetipback=fbcol.dialogback
	fbcol.codelisttext=fbcol.tooltext
	fbcol.codelistback=fbcol.toolback
	fbcol.dialogtext=fbcol.racol.oprback
	fbcol.dialogback=fbcol.racol.numback
	fbcol.tooltext=fbcol.racol.strback
	fbcol.toolback=fbcol.racol.cmntback
	fbcol.racol.cmntback=fbcol.racol.bckcol
	fbcol.racol.strback=fbcol.racol.bckcol
	fbcol.racol.numback=fbcol.racol.bckcol
	fbcol.racol.oprback=fbcol.racol.bckcol
	SaveToIni(StrPtr("Win"),StrPtr("Colors"),"444444444444444444444444444444444",@fbcol,FALSE)
	For i=1 To 15
		SetZStrEmpty (THEME)             'MOD 26.1.2012
		thm.lpszTheme=@THEME
		LoadFromIni "Theme", Str (i), "044444444444444444444444444444444444444444444444444", @thm, FALSE
		If THEME<>"" Then
			thm.fbc.propertiespar=thm.fbc.codetipback
			thm.fbc.codetipsel=thm.fbc.codelisttext
			thm.fbc.codetipapi=thm.fbc.codelistback
			thm.fbc.codetiptext=thm.fbc.dialogtext
			thm.fbc.codetipback=thm.fbc.dialogback
			thm.fbc.codelisttext=thm.fbc.tooltext
			thm.fbc.codelistback=thm.fbc.toolback
			thm.fbc.dialogtext=thm.fbc.racol.oprback
			thm.fbc.dialogback=thm.fbc.racol.numback
			thm.fbc.tooltext=thm.fbc.racol.strback
			thm.fbc.toolback=thm.fbc.racol.cmntback
			thm.fbc.racol.cmntback=thm.fbc.racol.bckcol
			thm.fbc.racol.strback=thm.fbc.racol.bckcol
			thm.fbc.racol.numback=thm.fbc.racol.bckcol
			thm.fbc.racol.oprback=thm.fbc.racol.bckcol
			SaveToIni(StrPtr("Theme"),Str(i),"044444444444444444444444444444444444444444444444444",@thm,FALSE)
		EndIf
	Next
End Sub

Sub UpdateColorsTo1067()
	Dim i As Integer
	Dim thm As THEME
	Dim THEME As ZString*32

	LoadFromIni "Win", "Colors", "44444444444444444444444444444", @fbcol, FALSE
	fbcol.propertiespar=fbcol.codetipapi
	fbcol.codetipsel=fbcol.codetiptext
	fbcol.codetipapi=fbcol.codetipback
	fbcol.codetiptext=fbcol.codelisttext
	fbcol.codetipback=fbcol.codelistback
	fbcol.codelisttext=fbcol.dialogtext
	fbcol.codelistback=fbcol.dialogback
	fbcol.dialogtext=fbcol.tooltext
	fbcol.dialogback=fbcol.toolback
	fbcol.tooltext=fbcol.racol.changesaved
	fbcol.toolback=fbcol.racol.changed
	fbcol.racol.changed=65535
	fbcol.racol.changesaved=65280
	SaveToIni(StrPtr("Win"),StrPtr("Colors"),"4444444444444444444444444444444",@fbcol,FALSE)
	For i=1 To 15
		SetZStrEmpty (THEME)             'MOD 26.1.2012
		thm.lpszTheme=@THEME
		LoadFromIni "Theme", Str (i), "044444444444444444444444444444444444444444444444444", @thm, FALSE
		If Theme<>"" Then
			thm.fbc.propertiespar=thm.fbc.codetipapi
			thm.fbc.codetipsel=thm.fbc.codetiptext
			thm.fbc.codetipapi=thm.fbc.codetipback
			thm.fbc.codetiptext=thm.fbc.codelisttext
			thm.fbc.codetipback=thm.fbc.codelistback
			thm.fbc.codelisttext=thm.fbc.dialogtext
			thm.fbc.codelistback=thm.fbc.dialogback
			thm.fbc.dialogtext=thm.fbc.tooltext
			thm.fbc.dialogback=thm.fbc.toolback
			thm.fbc.tooltext=thm.fbc.racol.changesaved
			thm.fbc.toolback=thm.fbc.racol.changed
			thm.fbc.racol.changed=65535
			thm.fbc.racol.changesaved=65280
			SaveToIni(StrPtr("Theme"),Str(i),"04444444444444444444444444444444444444444444444444444",@thm,FALSE)
		EndIf
	Next
End Sub

Sub CheckIniFile()
	
	Dim lret           As DWORD              = Any
	Dim hFile          As HANDLE             = Any
    Dim Path           As ZString * MAX_PATH = Any
    Dim IniFileVersion As DWORD              = Any
    Dim IniBackupSpec  As ZString * MAX_PATH = Any
    Dim BackupSuccess  As BOOL               = Any
    Dim Modified       As BOOL               = FALSE

	IniBackupSpec  = ad.IniFile + ".old"
	IniFileVersion = GetPrivateProfileInt ("Win", "Version", 0, @ad.IniFile)
	BackupSuccess  = CopyFile (@ad.IniFile, @IniBackupSpec, FALSE)

	If IniFileVersion < 1061 Then                ' ini doesnt exist: IniFileVersion = 0
		hFile=CreateFile(@ad.IniFile,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL)
		If HFILE = INVALID_HANDLE_VALUE Then
			MessageBox NULL, !"ERROR: cannot create:\n\n" + ad.IniFile, @szAppName, MB_OK Or MB_ICONERROR
			End
		Else		
			buff = szSecWin        & szSecTheme      & szSecEdit1    & szSecEdit2   & szSecEdit3    & _
			       szSecEdit4      & szSecEdit5      & szSecEdit6    & szSecEdit7   & szSecBlock    & _
			       szSecAutoFormat & szSecResource   & szSecTools    & szSecHelp    & _  'szSecProject  & _
			       szSecMake       & szSecOpen       & szSecApi      & szSecDebug   & szSecTemplate & _
			       szSecPrinter    & szSecLanguage   & szSecSniplet  & szSecToolbar & szSecFileTab  & _
			       szSecShowVars   & szSecProjectZip & szSecRegExLib
			
			WriteFile(hFile,@buff,Len(buff),@lret,NULL)
			CloseHandle(hFile)
	        MessageBox NULL, "New ini file written", @szAppName, MB_OK Or MB_ICONINFORMATION
	        DialogBox (hInstance, MAKEINTRESOURCE (IDD_DLG_ENVIRON), ah.hwnd, @EnvironProc)
       		IniFileVersion = GetPrivateProfileInt ("Win", "Version", 0, @ad.IniFile) 'skip the following
		    Modified = TRUE
		EndIf
	EndIf

	If IniFileVersion < 1065 Then
		UpdateColorsTo1065
		Modified = TRUE
	EndIf

	If IniFileVersion < 1067 Then
		UpdateColorsTo1067
		Modified = TRUE
	EndIf

	If IniFileVersion < 1068 Then
		UpdateSection "AutoFormat", szSecAutoFormat
		Modified = TRUE
	EndIf

	If IniFileVersion < 1070 Then
		WritePrivateProfileString "Make", "QuickRun", "fbc -s console", @ad.IniFile
		Modified = TRUE
	EndIf

	If IniFileVersion < 1071 Then
		UpdateSection "Block", szSecBlock
		Modified = TRUE
	EndIf

	If IniFileVersion < 1076 Then
		GetPrivateProfileString(StrPtr("Api"),StrPtr("Api"),NULL,@buff,SizeOf(buff),@ad.IniFile)
		If IsZStrNotEmpty (buff) Then buff &=","               ' MOD 27.1.2012
		buff &="fmod (fmod Sound),rae (RAEdit),rap (RAProperty),racc (RACodeComplete),raf (RAFile),rah (RAHexEd),rag (RAGrid),rar (RAResEd),spr (SpreadSheet)"
		WritePrivateProfileString("Api","Api",@buff,@ad.IniFile)
		' xxxCall.api
		GetPrivateProfileString(StrPtr("Api"),StrPtr("Call"),NULL,@buff,SizeOf(buff),@ad.IniFile)
		If IsZStrNotEmpty (buff) Then buff &=","               ' MOD 27.1.2012
		buff &="fmodCall.api"
		WritePrivateProfileString("Api","Call",@buff,@ad.IniFile)
		' xxxConst.api
		GetPrivateProfileString(StrPtr("Api"),StrPtr("Const"),NULL,@buff,SizeOf(buff),@ad.IniFile)
		If IsZStrNotEmpty (buff) Then buff &=","               ' MOD 27.1.2012
		buff &="raeConst.api,rapConst.api,raccConst.api,rafConst.api,rahConst.api,ragConst.api,rarConst.api,sprConst.api"
		WritePrivateProfileString("Api","Const",@buff,@ad.IniFile)
		' xxxStruct.api
		GetPrivateProfileString(StrPtr("Api"),StrPtr("Struct"),NULL,@buff,SizeOf(buff),@ad.IniFile)
		If IsZStrNotEmpty (buff) Then buff &=","               ' MOD 27.1.2012
		buff &="fmodStruct.api,raeStruct.api,rapStruct.api,raccStruct.api,rafStruct.api,rahStruct.api,ragStruct.api,rarStruct.api,sprStruct.api"
		WritePrivateProfileString("Api","Struct",@buff,@ad.IniFile)
		' xxxWord.api
		GetPrivateProfileString(StrPtr("Api"),StrPtr("Word"),NULL,@buff,SizeOf(buff),@ad.IniFile)
		If IsZStrNotEmpty (buff) Then buff &=","               ' MOD 27.1.2012
		buff &="fmodWord.api,raeWord.api,rapWord.api,raccWord.api,rafWord.api,rahWord.api,ragWord.api,rarWord.api,sprWord.api"
		WritePrivateProfileString("Api","Word",@buff,@ad.IniFile)
		' xxxEnum.api
		GetPrivateProfileString(StrPtr("Api"),StrPtr("Enum"),NULL,@buff,SizeOf(buff),@ad.IniFile)
		If IsZStrNotEmpty (buff) Then buff &=","               ' MOD 27.1.2012
		buff &="fmodEnum.api,raeEnum.api,rapEnum.api"
		WritePrivateProfileString("Api","Enum",@buff,@ad.IniFile)
		' xxxMsg.api
		GetPrivateProfileString(StrPtr("Api"),StrPtr("Msg"),NULL,@buff,SizeOf(buff),@ad.IniFile)
		If IsZStrNotEmpty (buff) Then buff &=","               ' MOD 27.1.2012
		buff &="raeMsg.api,rapMsg.api,raccMsg.api,rafMsg.api,rahMsg.api,ragMsg.api,rarMsg.api,sprMsg.api"
		WritePrivateProfileString("Api","Msg",@buff,@ad.IniFile)
		' Add Api File Creator to tools menu
		lret=1
		While TRUE
			GetPrivateProfileString(StrPtr("Tools"),Str(lret),NULL,@buff,SizeOf(buff),@ad.IniFile)
			If IsZStrEmpty (buff) Then                         ' MOD 27.1.2012
				WritePrivateProfileString("Tools",Str(lret),"Api File Creator,$A\Tools\MakeApi.exe ""$A""",@ad.IniFile)
				Exit While
			EndIf
			lret+=1
		Wend
		Modified = TRUE
	EndIf
	
	If IniFileVersion < 1078 Then
		WritePrivateProfileString "Edit", "ToolFont", "-13,0,Tahoma,400,0", @ad.IniFile
		WritePrivateProfileString "Edit", "OutpFont", "-11,0,Dina,400,0", @ad.IniFile

		'GetPrivateProfileString "Project", "Path", NULL, @buff, MAX_PATH, @ad.IniFile
		GetPrivateProfilePath "Project", "Path", @ad.IniFile, @buff, GPP_Untouched
		'FixPath buff
		'PathCombine @buff, @ad.AppPath, @buff
		WritePrivateProfileString "EnvironPath", "PROJECTS_PATH", @buff, @ad.IniFile
        WritePrivateProfileString "Project", "Path", NULL, @ad.IniFile              ' remove key

        'GetPrivateProfileString "Make", "fbcPath", NULL, @buff, MAX_PATH, @ad.IniFile
        GetPrivateProfilePath "Make", "fbcPath", @ad.IniFile, @buff, GPP_Untouched
        'FixPath buff
        'PathCombine @buff, @ad.AppPath, @buff
        WritePrivateProfileString "EnvironPath", "FBC_PATH", @buff, @ad.IniFile
        WritePrivateProfileString "Make", "fbcPath", NULL, @ad.IniFile              ' remove key
        If IsZStrEmpty (buff) Then
            WritePrivateProfileString "EnvironPath", "FBCINC_PATH", @"", @ad.IniFile
            WritePrivateProfileString "EnvironPath", "FBCLIB_PATH", @"", @ad.IniFile
        Else
            PathCombine @Path, @buff, "include"
            WritePrivateProfileString "EnvironPath", "FBCINC_PATH", @Path, @ad.IniFile
            PathCombine @Path, @buff, "lib"
            WritePrivateProfileString "EnvironPath", "FBCLIB_PATH", @Path, @ad.IniFile
        EndIf
        'GetPrivateProfileString "Help", "Path", NULL, @buff, MAX_PATH, @ad.IniFile
        GetPrivateProfilePath "Help", "Path", @ad.IniFile, @buff, GPP_Untouched
        'FixPath buff
        'PathCombine @buff, @ad.AppPath, @buff
        WritePrivateProfileString "EnvironPath", "HELP_PATH", @buff, @ad.IniFile
		WritePrivateProfileString "Help", "Path", NULL, @ad.IniFile		            ' remove key
		
		''GetPrivateProfileString "Help", "F1", NULL, @buff, MAX_PATH, @ad.IniFile
        'GetPrivateProfilePath "Help", "F1", @ad.IniFile, @buff
        ''FixPath buff
        ''PathCombine @buff, @ad.AppPath, @buff
        'WritePrivateProfileString "Help", "F1", @buff, @ad.IniFile

        ''GetPrivateProfileString "Help", "CtrlF1", NULL, @buff, MAX_PATH, @ad.IniFile
        'GetPrivateProfilePath "Help", "CtrlF1", @ad.IniFile, @buff
        ''FixPath buff
        ''PathCombine @buff, @ad.AppPath, @buff
        'WritePrivateProfileString "Help", "CtrlF1", @buff, @ad.IniFile

        UpdateSection "Open", szSecOpen
		UpdateSection "RegExLib", szSecRegExLib
		Modified = TRUE
	EndIf

    If IniFileVersion > ad.version Then
        MessageBox NULL, !"ERROR: FbEdit older than ini file\nprogram version:\t" + Str (ad.version) + !"\nini version:\t" + Str (IniFileVersion), @szAppName, MB_OK Or MB_ICONERROR
        End
    EndIf

	WritePrivateProfileString "Win", "Version", Str (ad.version), @ad.IniFile

    If Modified Then
        buff = !"Updated:\n" + ad.IniFile
        If BackupSuccess Then
            buff += !"\n\nBackup:\n" + IniBackupSpec
        EndIf
        MessageBox NULL, @buff, @szAppName, MB_OK Or MB_ICONINFORMATION
    EndIf
End Sub

'Sub CheckIniFileOld()
'	
'	Dim lret           As DWORD
'	Dim hFile          As HANDLE
'   Dim Path           As ZString * MAX_PATH
'		If hFile<>INVALID_HANDLE_VALUE Then
'			buff=szSecWin        & szSecTheme      & szSecEdit1    & szSecEdit2   & szSecEdit3    & _
'			     szSecEdit4      & szSecEdit5      & szSecEdit6    & szSecEdit7   & szSecBlock    & _
'			     szSecAutoFormat & szSecResource   & szSecTools    & szSecHelp    & _  'szSecProject  & _
'			     szSecMake       & szSecOpen       & szSecApi      & szSecDebug   & szSecTemplate & _
'			     szSecPrinter    & szSecLanguage   & szSecSniplet  & szSecToolbar & szSecFileTab  & _
'			     szSecShowVars   & szSecProjectZip & szSecRegExLib
'			
'			WriteFile(hFile,@buff,Len(buff),@lret,NULL)
'			CloseHandle(hFile)
'	        DialogBox (hInstance, MAKEINTRESOURCE (IDD_DLG_ENVIRON), ah.hwnd, @EnvironProc)
'			'DialogBox(hInstance,Cast(ZString Ptr,IDD_DLGPATHOPTION),NULL,@PathOptDlgProc)
'		Else
'			' Could not create it.
'			End
'		EndIf
'	Else
'		'CloseHandle(hFile)
'		' FbEdit.ini exist, update it.
'		'buff=ad.AppPath & "\FbEdit.ini.old"
'		buff = ad.IniFile + ".old"
'		IniFileVersion = GetPrivateProfileInt ("Win", "Version", 0, @ad.IniFile)
'		Print "ini version:"; IniFileVersion
'		If IniFileVersion < 1061 Then
'			' Delete old backup
'			DeleteFile(@buff)
'			MoveFile(@ad.IniFile,@buff)
'			CheckIniFile
'			MessageBox NULL, ad.IniFile + !"\n   was too old to be updated\n\n   A backup is saved as:\n" + ad.IniFile + ".old",@szAppName, MB_OK Or MB_ICONINFORMATION
'		ElseIf IniFileVersion < ad.version Then
'			CopyFile(@ad.IniFile,@buff,FALSE)
'			If IniFileVersion < 1065 Then
'				UpdateColorsTo1065
'				UpdateColorsTo1067
'				UpdateSection("Block",szSecBlock)
'				UpdateSection("AutoFormat",szSecAutoFormat)
'				WritePrivateProfileString("Make","QuickRun","fbc -s console",@ad.IniFile)
'			ElseIf IniFileVersion < 1067 Then
'				UpdateColorsTo1067
'				UpdateSection("Block",szSecBlock)
'				UpdateSection("AutoFormat",szSecAutoFormat)
'				WritePrivateProfileString("Make","QuickRun","fbc -s console",@ad.IniFile)
'			ElseIf IniFileVersion < 1068 Then
'				UpdateSection("Block",szSecBlock)
'				UpdateSection("AutoFormat",szSecAutoFormat)
'				WritePrivateProfileString("Make","QuickRun","fbc -s console",@ad.IniFile)
'			ElseIf IniFileVersion < 1069 Then
'				UpdateSection("Block",szSecBlock)
'				WritePrivateProfileString("Make","QuickRun","fbc -s console",@ad.IniFile)
'			ElseIf IniFileVersion < 1070 Then
'				UpdateSection("Block",szSecBlock)
'				WritePrivateProfileString("Make","QuickRun","fbc -s console",@ad.IniFile)
'			ElseIf IniFileVersion < 1071 Then
'				UpdateSection("Block",szSecBlock)
'			ElseIf IniFileVersion < 1072 Then
'				'
'			ElseIf IniFileVersion < 1073 Then
'				'
'			ElseIf IniFileVersion < 1074 Then
'				'
'			ElseIf IniFileVersion < 1075 Then
'				'
'			ElseIf IniFileVersion < 1076 Then
'				GetPrivateProfileString(StrPtr("Api"),StrPtr("Api"),NULL,@buff,SizeOf(buff),@ad.IniFile)
'				If IsZStrNotEmpty (buff) Then buff &=","               ' MOD 27.1.2012
'				buff &="fmod (fmod Sound),rae (RAEdit),rap (RAProperty),racc (RACodeComplete),raf (RAFile),rah (RAHexEd),rag (RAGrid),rar (RAResEd),spr (SpreadSheet)"
'				WritePrivateProfileString("Api","Api",@buff,@ad.IniFile)
'				' xxxCall.api
'				GetPrivateProfileString(StrPtr("Api"),StrPtr("Call"),NULL,@buff,SizeOf(buff),@ad.IniFile)
'				If IsZStrNotEmpty (buff) Then buff &=","               ' MOD 27.1.2012
'				buff &="fmodCall.api"
'				WritePrivateProfileString("Api","Call",@buff,@ad.IniFile)
'				' xxxConst.api
'				GetPrivateProfileString(StrPtr("Api"),StrPtr("Const"),NULL,@buff,SizeOf(buff),@ad.IniFile)
'				If IsZStrNotEmpty (buff) Then buff &=","               ' MOD 27.1.2012
'				buff &="raeConst.api,rapConst.api,raccConst.api,rafConst.api,rahConst.api,ragConst.api,rarConst.api,sprConst.api"
'				WritePrivateProfileString("Api","Const",@buff,@ad.IniFile)
'				' xxxStruct.api
'				GetPrivateProfileString(StrPtr("Api"),StrPtr("Struct"),NULL,@buff,SizeOf(buff),@ad.IniFile)
'				If IsZStrNotEmpty (buff) Then buff &=","               ' MOD 27.1.2012
'				buff &="fmodStruct.api,raeStruct.api,rapStruct.api,raccStruct.api,rafStruct.api,rahStruct.api,ragStruct.api,rarStruct.api,sprStruct.api"
'				WritePrivateProfileString("Api","Struct",@buff,@ad.IniFile)
'				' xxxWord.api
'				GetPrivateProfileString(StrPtr("Api"),StrPtr("Word"),NULL,@buff,SizeOf(buff),@ad.IniFile)
'				If IsZStrNotEmpty (buff) Then buff &=","               ' MOD 27.1.2012
'				buff &="fmodWord.api,raeWord.api,rapWord.api,raccWord.api,rafWord.api,rahWord.api,ragWord.api,rarWord.api,sprWord.api"
'				WritePrivateProfileString("Api","Word",@buff,@ad.IniFile)
'				' xxxEnum.api
'				GetPrivateProfileString(StrPtr("Api"),StrPtr("Enum"),NULL,@buff,SizeOf(buff),@ad.IniFile)
'				If IsZStrNotEmpty (buff) Then buff &=","               ' MOD 27.1.2012
'				buff &="fmodEnum.api,raeEnum.api,rapEnum.api"
'				WritePrivateProfileString("Api","Enum",@buff,@ad.IniFile)
'				' xxxMsg.api
'				GetPrivateProfileString(StrPtr("Api"),StrPtr("Msg"),NULL,@buff,SizeOf(buff),@ad.IniFile)
'				If IsZStrNotEmpty (buff) Then buff &=","               ' MOD 27.1.2012
'				buff &="raeMsg.api,rapMsg.api,raccMsg.api,rafMsg.api,rahMsg.api,ragMsg.api,rarMsg.api,sprMsg.api"
'				WritePrivateProfileString("Api","Msg",@buff,@ad.IniFile)
'				' Add Api File Creator to tools menu
'				lret=1
'				While TRUE
'					GetPrivateProfileString(StrPtr("Tools"),Str(lret),NULL,@buff,SizeOf(buff),@ad.IniFile)
'					If IsZStrEmpty (buff) Then                         ' MOD 27.1.2012
'						WritePrivateProfileString("Tools",Str(lret),"Api File Creator,$A\Tools\MakeApi.exe ""$A""",@ad.IniFile)
'						Exit While
'					EndIf
'					lret+=1
'				Wend
'				'
'			ElseIf IniFileVersion < 1077 Then
'				'			
'			ElseIf IniFileVersion < 1078 Then
'    			Print "iniver < 1078"
'    			GetPrivateProfileString   "Project", "Path", NULL, @buff, MAX_PATH, @ad.IniFile
'    			FixPath buff
'    			PathCombine @buff, @ad.AppPath, @buff
'    			WritePrivateProfileString "EnvironPath", "PROJECTS_PATH", @buff, @ad.IniFile
'		        WritePrivateProfileString "Project", "Path", NULL, @ad.IniFile              ' remove key
'		
'		        GetPrivateProfileString   "Make", "fbcPath", NULL, @buff, MAX_PATH, @ad.IniFile
'		        FixPath buff
'		        PathCombine @buff, @ad.AppPath, @buff
'		        WritePrivateProfileString "EnvironPath", "FBC_PATH", @buff, @ad.IniFile
'                WritePrivateProfileString "Make", "fbcPath", NULL, @ad.IniFile              ' remove key
'                PathCombine Path, buff, "include"
'                WritePrivateProfileString "EnvironPath", "FBCINC_PATH", @Path, @ad.IniFile
'                PathCombine Path, buff, "lib"
'                WritePrivateProfileString "EnvironPath", "FBCLIB_PATH", @Path, @ad.IniFile
'
' 		        GetPrivateProfileString   "Help", "Path", NULL, @buff, MAX_PATH, @ad.IniFile
'		        FixPath buff
'		        PathCombine @buff, @ad.AppPath, @buff
'		        WritePrivateProfileString "EnvironPath", "HELP_PATH", @buff, @ad.IniFile
'				WritePrivateProfileString "Help", "Path", NULL, @ad.IniFile		            ' remove key
'				
'				UpdateSection "RegExLib", szSecRegExLib
'			EndIf
'			WritePrivateProfileString("Win","Version",Str(ad.version),@ad.IniFile)
'			MessageBox(NULL,"The FbEdit.ini file has been updated." & CR & "A backup is saved as FbEditOld.ini",@szAppName,MB_OK Or MB_ICONINFORMATION)
'		EndIf
'	EndIf
'
'End Sub

Sub GetPrivateProfilePath (ByVal pSectionName As ZString Ptr, ByVal pKeyName As ZString Ptr, ByVal pIniSpec As ZString Ptr, ByVal pPath As ZString Ptr, ByVal Mode As GetPrivateProfileSpecMode)

    Dim Success As BOOL = Any

    GetPrivateProfileString pSectionName, pKeyName, NULL, pPath, MAX_PATH, pIniSpec

    If IsZStrEmpty (*pPath) Then
        TextToOutput "*** ini file error - value not found ***", MB_ICONHAND
        TextToOutput "File: " + *pIniSpec + ", Section: [" + *pSectionName + "], Key: " + *pKeyName
        Exit Sub
    Else
        If Mode And GPP_Expanded Then
	        UpdateEnvironment
			Success = ExpandStrByEnviron (*pPath, MAX_PATH)
            If Success = FALSE Then
                TextToOutput "*** commandline too long - expansion by environment failed ***", MB_ICONHAND
                TextToOutput *pPath
                SetZStrEmpty (*pPath)
                Exit Sub
            EndIf
        EndIf

        If Mode And GPP_MustExist Then
            If DirExists (pPath) = FALSE Then
                TextToOutput "*** ini file error - directory not found ***", MB_ICONHAND
                TextToOutput "File: " + *pIniSpec + ", Section: [" + *pSectionName + "], Key: " + *pKeyName + " = " + *pPath
                SetZStrEmpty (*pPath)
                Exit Sub
            EndIf
        EndIf
    EndIf
End Sub

Sub GetPrivateProfileSpec (ByVal pSectionName As ZString Ptr, ByVal pKeyName As ZString Ptr, ByVal pIniSpec As ZString Ptr, ByVal pSpec As ZString Ptr, ByVal Mode As GetPrivateProfileSpecMode)

    Dim Success As BOOL = Any

    GetPrivateProfileString pSectionName, pKeyName, NULL, pSpec, MAX_PATH, pIniSpec

    If IsZStrEmpty (*pSpec) Then
        TextToOutput "*** ini file error - value not found ***", MB_ICONHAND
        TextToOutput "File: " + *pIniSpec + ", Section: [" + *pSectionName + "], Key: " + *pKeyName
        Exit Sub
    Else

        If Mode And GPP_Expanded Then
	        UpdateEnvironment
			Success = ExpandStrByEnviron (*pSpec, MAX_PATH)
            If Success = FALSE Then
                TextToOutput "*** commandline too long - expansion by environment failed ***", MB_ICONHAND
                TextToOutput *pSpec
                SetZStrEmpty (*pSpec)
                Exit Sub
            EndIf
        EndIf

        If Mode And GPP_MustExist Then
            If FileExists (pSpec) = FALSE Then
                TextToOutput "*** ini file error - file not found ***", MB_ICONHAND
                TextToOutput "File: " + *pIniSpec + ", Section: [" + *pSectionName + "], Key: " + *pKeyName + " = " + *pSpec
                SetZStrEmpty (*pSpec)
                Exit Sub
            EndIf
        EndIf
    EndIf
End Sub
