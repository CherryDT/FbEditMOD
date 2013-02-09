
include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include shlwapi.inc
include comctl32.inc
include comdlg32.inc
include gdi32.inc
include ole32.inc
include advapi32.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib shlwapi.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib gdi32.lib
includelib ole32.lib
includelib advapi32.lib

;include \RadASM\Masm\Inc\RADbg.inc
include masm32.inc
include \RadASM\Masm\Inc\Debug.Inc
includelib masm32.lib
includelib \RadASM\Masm\Lib\Debug.lib

include ..\RAEdit.inc

WinMain					PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc					PROTO :DWORD,:DWORD,:DWORD,:DWORD
UpdateAll				PROTO :DWORD
CreateRAEdit			PROTO
CreateNew				PROTO
TabToolAdd				PROTO :DWORD,:DWORD
CreatePreView			PROTO :DWORD,:DWORD

IS_OPEN					equ -1
SAVE_ALL				equ -2

TABHT					equ 21
CBOWT					equ 150
RESIZEHT				equ 2

IDB_TBRBMP				equ 150
IDR_ACCEL				equ 200
IDC_HSPLIT				equ 250
IDC_VSPLIT				equ 251
IDB_MNUARROW			equ 200

;Find.dlg
IDD_FINDDLG				equ 2000
IDC_FINDTEXT			equ 2001
IDC_BTN_REPLACE			equ 2007
IDC_REPLACETEXT			equ 2002
IDC_REPLACESTATIC		equ 2009
IDC_BTN_REPLACEALL		equ 2008
IDC_CHK_WHOLEWORD		equ 2004
IDC_CHK_MATCHCASE		equ 2003
IDC_RBN_DOWN			equ 2005
IDC_RBN_UP				equ 2006

;RAEditDemo.dlg
IDD_DLG					equ 1000
IDC_TBR					equ 1001
IDC_CBO					equ 1008
IDC_RAE					equ 1002
IDC_TAB					equ 1004
IDC_SBR					equ 1003
IDC_SHP					equ 1005
IDC_OUT					equ 1006
IDC_VSPLITBAR			equ 1007

IDD_DLGPRINTPREVIEW		equ 5000

IDM_HELPF1				equ 500
IDM_MENU				equ 10000

;RAEditDemo.mnu
IDM_FILE_NEW			equ 10001
IDM_FILE_OPEN			equ 10002
IDM_FILE_SAVE			equ 10003
IDM_FILE_SAVEAS			equ 10004
IDM_FILE_SAVEALL		equ 10011
IDM_FILE_CLOSE			equ 10010
IDM_FILE_PAGESETUP		equ 10029
IDM_FILE_PRINT_PREVIEW	equ 10042
IDM_FILE_PRINT			equ 10005
IDM_FILE_EXIT			equ 10006
IDM_EDIT_UNDO			equ 10101
IDM_EDIT_REDO			equ 10102
IDM_EDIT_DELETE			equ 10103
IDM_EDIT_CUT			equ 10104
IDM_EDIT_COPY			equ 10105
IDM_EDIT_PASTE			equ 10106
IDM_EDIT_SELECTALL		equ 10107
IDM_EDIT_FIND			equ 10108
IDM_EDIT_FINDNEXT		equ 10110
IDM_EDIT_FINDPREV		equ 10111
IDM_EDIT_REPLACE		equ 10109
IDM_EDIT_INDENT			equ 10037
IDM_EDIT_OUTDENT		equ 10038
IDM_EDIT_COMMENT		equ 10035
IDM_EDIT_UNCOMMENT		equ 10036
IDM_EDIT_BLOCKMODE		equ 10040
IDM_EDIT_BLOCKINSERT	equ 10041
IDM_EDIT_TOGGLEBM		equ 10018
IDM_EDIT_NEXTBM			equ 10019
IDM_EDIT_PREVBM			equ 10020
IDM_EDIT_CLEARBM		equ 10021
IDM_VIEW_TOOLBAR		equ 10008
IDM_VIEW_STATUSBAR		equ 10009
IDM_VIEW_OUTPUT			equ 10023
IDM_MAKE_COMPILE		equ 10024
IDM_MAKE_ASSEMBLE		equ 10025
IDM_MAKE_LINK			equ 10026
IDM_MAKE_RUN			equ 10027
IDM_MAKE_GO				equ 10028
IDM_OPTION_FONT			equ 10007
IDM_OPTION_LNFONT		equ 10022
IDM_OPTION_KEYWORDS		equ 10030
IDM_OPTION_TOOLS		equ 10031
IDM_OPTION_HELP			equ 10032
IDM_HELP_ABOUT			equ 10201
IDM_DEMO_HILITE1		equ 10012
IDM_DEMO_HILITE2		equ 10013
IDM_DEMO_HILITE3		equ 10014
IDM_DEMO_HILITEOFF		equ 10015
IDM_DEMO_LOCK			equ 10016
IDM_DEMO_UNLOCK			equ 10017
IDM_DEMO_SPEED_TEST		equ 10033
IDM_DEMO_HIDE			equ 10034
IDM_DEMO_LINELENGHT		equ 10039

TABMEM struct
	hwnd		dd ?
	filename	db MAX_PATH dup (?)
TABMEM ends

WINPOS struct
	fMax		dd ?
	fView		dd ?
	x			dd ?
	y			dd ?
	wt			dd ?
	ht			dd ?
	htout		dd ?
	dummy		dd 4 dup(?)
WINPOS ends

EDITOPT struct
	tabsize		dd ?
	exptabs		dd ?
	indent		dd ?
	hiliteline	dd ?
EDITOPT ends

PRNPOS struct
	margins		RECT <?>
	pagesize	POINT <?>
	nlinespage	dd ?
PRNPOS ends

RAUNDO struct
	rpPrev		dd ?		;Relative pointer to previous
	undoid		dd ?		;Undo ID
	cp			dd ?		;Character position
	cb			dd ?		;Size in bytes
	fun			db ?		;Function
RAUNDO ends

.const

tbrbtns					TBBUTTON <20,IDM_FILE_PRINT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <6,IDM_FILE_NEW,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <7,IDM_FILE_OPEN,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <8,IDM_FILE_SAVE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <11,IDM_FILE_SAVEALL,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <0,IDM_EDIT_CUT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <1,IDM_EDIT_COPY,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <2,IDM_EDIT_PASTE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <3,IDM_EDIT_UNDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <4,IDM_EDIT_REDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <5,IDM_EDIT_DELETE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <9,IDM_EDIT_FIND,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <10,IDM_EDIT_REPLACE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <16,IDM_EDIT_TOGGLEBM,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <17,IDM_EDIT_NEXTBM,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <18,IDM_EDIT_PREVBM,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <19,IDM_EDIT_CLEARBM,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <21,IDM_VIEW_OUTPUT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <12,IDM_MAKE_ASSEMBLE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <13,IDM_MAKE_LINK,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <14,IDM_MAKE_RUN,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <15,IDM_MAKE_GO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
ntbrbtns				equ 30

ALLFilterString			db 'Assembly Files (*.asm, *.inc, *.rc)',0,'*.asm;*.inc;*.rc',0
						db 'Text Files (*.txt)',0,'*.txt',0
						db 'All Files (*.*)',0,'*.*',0,0
RegionSearched			db	'Region searched.',0
szUnicode				db ' [Unicode]',0

.data

RAEditDLL				db 'RAEdit.dll',0
RAEditFail				db 'Could not find RAEdit.dll',0
szEditClass				db 'RAEdit',0
ClassName				db 'DLGCLASS',0
PreviewClass			db 'PREVIEWCLASS',0
szAppName				db 'SimEd',0
szAboutMsg				db 'SimEd code editor version 1.1.3.9',13,10,'KetilO (C) 2003-2006',13,10,13,10,'radasmide@hotmail.com',0
szAboutUrl				db 'http://www.radasm.com',0
szOpen					db 'Open',0
Replace					db 'Replace ..',0
OpenFileFail        	db 'Cannot open the file',0
SaveFileFail			db 'Cannot save the file',0
WannaSave           	db 'Want to save changes to',0Dh,0
NewFile             	db '(Untitled)',0
szFtAsm					db '.asm',0
szFtInc					db '.inc',0
szFtRc					db '.rc',0
szNULL					db 0
szTab					db VK_TAB,0
szSpc					db ' ',0
szCr					db 0Dh,0
szQuote					db '"',0
szCmntStart				db 'comment +',0
szCmntEnd				db '-',0
szBracketMatch			db '[({,])},\,',0
;szBracketMatch			db '[({,])},',0Dh,0
szProc					db '$ proc',0
szEndp					db '? endp',0
szIf					db '.if',0
szElseIf				db '.elseif',0
szElse					db '.else',0
szEndIf					db '.endif',0
szWhile					db '.while',0
szEndw					db '.endw',0
szStruct				db '? struct',0
szEnds					db '? ends',0
szStruc					db '? struc',0
szUnion					db '? union',0
szMacro					db '$ macro',0
szEndm					db 'endm',0
szData					db '.data',0
szDataU					db '.data?',0
szConst					db '.const',0
szCode					db '.code',0
szBegin					db 'BEGIN',0
szEnd					db 'END',0
szCmntInit				db 'comment',0

rabdproc				RABLOCKDEF <offset szProc,offset szEndp,0,0,BD_DIVIDERLINE or BD_INCLUDELAST>
rabdif					RABLOCKDEF <offset szIf,offset szEndIf,offset szElseIf,offset szElse,0>
rabdwhile				RABLOCKDEF <offset szWhile,offset szEndw,0,0,0>
rabdstruct				RABLOCKDEF <offset szStruct,offset szEnds,0,0,BD_DIVIDERLINE>
rabdstruc				RABLOCKDEF <offset szStruc,offset szEnds,0,0,BD_DIVIDERLINE>
rabdunion				RABLOCKDEF <offset szUnion,offset szEnds,0,0,BD_DIVIDERLINE>
rabdmacro				RABLOCKDEF <offset szMacro,offset szEndm,0,0,BD_DIVIDERLINE or BD_INCLUDELAST or BD_LOOKAHEAD>
rabddata				RABLOCKDEF <offset szData,0,0,0,BD_SEGMENTBLOCK>
rabddatau				RABLOCKDEF <offset szDataU,0,0,0,BD_SEGMENTBLOCK>
rabdconst				RABLOCKDEF <offset szConst,0,0,0,BD_SEGMENTBLOCK>
rabdcode				RABLOCKDEF <offset szCode,0,0,0,BD_SEGMENTBLOCK>
rabdbegin				RABLOCKDEF <offset szBegin,offset szEnd,0,0,1 SHL 16>
rabdcmntblock			RABLOCKDEF <offset szCmntInit,0,0,0,BD_COMMENTBLOCK>

blocks					dd offset rabdif,offset rabdwhile,offset rabdproc,offset rabdstruct,offset rabdstruc,offset rabdunion,offset rabdmacro,offset rabddata,offset rabddatau,offset rabdconst,offset rabdcode,offset rabdbegin,offset rabdcmntblock,0

szREG_SZ				db 'REG_SZ',0
szSimEd					db 'Software\SimEd1002\',0
						db 64 dup(0)
szWinPos				db 'WinPos',0
wpos					WINPOS <0,3,10,10,620,460,100>
szEditOpt				db 'EditOpt',0
edopt					EDITOPT <4,FALSE,TRUE>
szCodeFont				db 'CodeFont',0
lfnt					LOGFONT <-12,0,0,0,400,FALSE,FALSE,FALSE,0,0,0,0,0,'Courier New'>
szLnrFont				db 'LnrFont',0
lfntlnr					LOGFONT <-8,0,0,0,400,FALSE,FALSE,FALSE,0,0,0,0,0,'Terminal'>
szColor					db 'Color',0
col						RACOLOR <BCKCLR,TXTCLR,SELBCKCLR,SELTXTCLR,CMNTCLR,STRCLR,OPRCLR,HILITE1,HILITE2,HILITE3,SELBARCLR,SELBARPEN,LNRCLR,NUMCLR,CMNTBCK,STRBCK,NUMBCK,OPRBCK,CHANGEDCLR,CHANGESAVEDCLR>
szPrnPos				db 'PrnPos',0
ppos					PRNPOS <<1000,1000,1000,1000>,<21000,29700>,65>

szGroup					db 'Group#',0
szKeyWordColor			db 'KeyWordColor',0
kwcol					dd 00804000h,00808000h,00FF0000h,00FF0000h,00FF0000h,10FF0000h,000040FFh,00FF0000h,01FF0000h,00FF0000h
						dd C0,C1,C2,C3,C4,C5,C6,C7,C8,C9
;Registers
C0						db 'AH AL AX BH BL BP BX CH CL CR0 CR2 CR3 CS CX DH DI DL DR0 DR1 DR2 DR3 DR6 DR7 DS DX EAX EBP EBX ECX EDI EDX ES ESI ESP FS GS MM0 MM1 MM2 MM3 MM4 MM5 MM6 MM7 SI SP SS ST TR3 TR4 TR5 TR6 TR7 XMM0 XMM1 XMM2 XMM3',0
;Instructions
C1						db 'ADC ADD AND CALL CBW CLC CLD CLI CMC CMP CMPS CMPSB CMPSW CWD DAS DEC DIV DAA ESC HLT IDIV IMUL IN INC INT INTO IRET JA JAE JB JBE JC JCXZ JE JG JGE JL JLE JMP JNA JNAE JNB JNBE JNC JNE JNG JNGE JNL JNLE JNO JNP '
						db 'JNS JNZ JO JP JPE JPO JS JZ LAHF LDS LEA LES LODS LODSB LODSW LOOP LOOPE LOOPEW LOOPNE LOOPNEW LOOPNZ LOOPNZW LOOPW LOOPZ LOOPZW MOV MOVS MOVSB MOVSW MUL NEG NOP NOT OR OUT POP POPF PUSH PUSHF RCL RCR RET RETF RETN '
						db 'ROL ROR SAHF SAL SAR SBB SCAS SCASB SCASW SHL SHR STC STD STI STOS STOSB STOSW SUB TEST WAIT XCHG XLAT XLATB XOR AAA AAD AAM AAS',0
;Instructions
C2						db 'ARPL BOUND BSF BSR BSWAP BT BTC BTR BTS CDQ CLTS CMPSD CMPXCHG CWDE ENTER INS INSB INSD INSW INVD INVLPG IRETD IRETDF IRETF JECXZ LAR LEAVE LFS LGDT LGS LIDT LLDT LMSW LOCK LODSD LOOPD LOOPED LOOPNED LOOPNZD LOOPZD '
						db 'LSL LSS LTR MOVSD MOVSX MOVZX OUTS OUTSB OUTSD OUTSW POPA POPAD POPFD PUSHA PUSHAD PUSHD PUSHFD PUSHW REP REPE REPNE REPNZ REPZ SCASD SETA SETAE SETB SETBE SETC SETE SETG SETGE SETL SETLE SETNA SETNAE SETNB SETNBE '
						db 'SETNC SETNE SETNG SETNGE SETNL SETNLE SETNO SETNP SETNS SETNZ SETO SETP SETPE SETPO SETS SETZ SGDT SHLD SHRD SIDT SLDT SMSW STOSD STR VERR VERW WBINVD XADD',0
;FPU Instructions
C3						db 'F2XM1 FABS FADD FADDP FBLD FBSTP FCHS FCLEX FCOM FCOMP FCOMPP FCOS FDECSTP FDISI FDIV FDIVP FDIVR FDIVRP FENI FFREE FIADD FICOM FICOMP FIDIV FIDIVR FILD FIMUL FINCSTP FINIT FIST FISTP FISUB FISUBR FLD FLD1 FLDCW '
						db 'FLDENV FLDENVD FLDENVW FLDL2E FLDL2T FLDLG2 FLDLN2 FLDPI FLDZ FMUL FMULP FNCLEX FNDISI FNENI FNINIT FNOP FNSAVE FNSAVED FNSAVEW FNSTCW FNSTENV FNSTENVD FNSTENVW FNSTSW FPATAN FPREM FPREM1 FPTAN FRNDINT FRSTOR '
						db 'FRSTORD FRSTORW FSAVE FSAVED FSAVEW FSCALE FSETPM FSIN FSINCOS FSQRT FST FSTCW FSTENV FSTENVD FSTENVW FSTP FSTSW FSUB FSUBP FSUBR FSUBRP FTST FUCOM FUCOMP FUCOMPP FWAIT FXAM FXCH FXTRACT FYL2X FYL2XP1',0
;MMX Instructions
C4						db 'EMMS MOVD MOVQ PACKSSDW PACKSSWB PACKUSWB PADDB PADDD PADDSB PADDSW PADDUSB PADDUSW PADDW PAND PANDN PCMPEQB PCMPEQD PCMPEQW PCMPGTB PCMPGTD PCMPGTW PMADDWD PMULHW PMULLW POR PSLLD PSLLQ PSLLW PSRAD PSRAW '
						db 'PSRLD PSRLQ PSRLW PSUBB PSUBD PSUBSB PSUBSW PSUBUSB PSUBUSW PSUBW PUNPCKHBW PUNPCKHDQ PUNPCKHWD PUNPCKLBW PUNPCKLDQ PUNPCKLWD PXOR',0
;RC File
C5						db '#DEFINE #INCLUDE ACCELERATORS ALT AUTOCHECKBOX AUTORADIOBUTTON BEGIN BITMAP BLOCK CAPTION CLASS COMBOBOX CONTROL CURSOR DIALOG DIALOGEX DISCARDABLE EDITTEXT END EXSTYLE FILEOS FILETYPE FILEVERSION FONT GROUPBOX ICON '
						db 'LISTBOX LTEXT MENU MENUEX MENUITEM NOINVERT POPUP PRODUCTVERSION PUSHBUTTON SEPARATOR SHIFT STRINGTABLE STYLE VALUE VERSIONINFO VIRTKEY',0
;Misc
C6						db '$ ? @@ @B @F ADDR BASIC BYTE C CARRY? DWORD FALSE FAR FAR16 FORTRAN FWORD ^HDC ^HWND ^LPARAM NEAR NEAR16 NULL OVERFLOW? OWORD PARITY? PASCAL QWORD REAL10 REAL4 REAL8 SBYTE SDWORD SIGN? STDCALL SWORD SYSCALL TBYTE '
						db 'TRUE ^UINT USES VARARG WORD ^WPARAM ZERO?',0
;MASM Keywords (non-code producing)
C7						db '%OUT .186 .286 .286C .286P .287 .386 .386C .386P .387 .486 .486P .586 .686 .686p .8086 .8087 .ALPHA .CODE .CONST .CREF .DATA .DATA? .DOSSEG .ERR .ERR1 .ERR2 .ERRB .ERRDEF .ERRDIF .ERRDIFI .ERRE .ERRIDN '
						db '.ERRIDNI .ERRNB .ERRNDEF .ERRNZ .EXIT .FARDATA .FARDATA? .K3D .LALL .LFCOND .LIST .LISTALL .LISTIF .LISTMACRO .LISTMACROALL .MMX .MODEL .MSFLOAT .NO87 .NOCREF .NOLIST .NOLISTIF .NOLISTMACRO .RADIX .SALL '
						db '.SEQ .SFCOND .STACK .STARTUP .TFCOND .TYPE .XALL .XCREF .XLIST .XMM ALIAS ALIGN ASSUME CATSTR COMM COMMENT+ DB DD DF DOSSEG DQ DT DUP DW ECHO ELSE ELSEIF ELSEIF1 ELSEIF2 ELSEIFB ELSEIFDEF ELSEIFDIF '
						db 'ELSEIFDIFI ELSEIFE ELSEIFIDN ELSEIFIDNI ELSEIFNB ELSEIFNDEF END ENDIF ENDM ENDP ENDS ENDW EQ EQU EVEN EXITM EXTERN EXTERNDEF EXTRN FOR FORC GE GOTO GROUP GT HIGH HIGHWORD IF IF1 IF2 IFB IFDEF IFDIF '
						db 'IFDIFI IFE IFIDN IFIDNI IFNB IFNDEF INCLUDE- INCLUDELIB- INSTR IRP IRPC LABEL LE LENGTH LENGTHOF LOCAL LOW LOWWORD LROFFSET LT MACRO MASK MOD NAME NE OFFSET OPATTR OPTION ORG PAGE POPCONTEXT PROC PROTO '
						db 'PTR PUBLIC PURGE PUSHCONTEXT RECORD REPEAT REPT SEG SEGMENT SHORT SIZE SIZEOF SIZESTR STRUC STRUCT SUBSTR SUBTITLE SUBTTL TEXTEQU THIS TITLE- TYPE TYPEDEF UNION WHILE WIDTH',0
;MASM High Level Key Words (code producing)
C8						db '.BREAK .CONTINUE ~.ELSE ~.ELSEIF ~.ENDIF .ENDW ~.IF .REPEAT .UNTIL .UNTILCXZ .WHILE INVOKE',0
;CaseSensitive Macro Ops
C9						db '@CatStr @code @CodeSize @Cpu @CurSeg @data @DataSize @Date @Environ @fardata @fardata? @FileCur @FileName @InStr @Interface @Line @Model @SizeStr @stack @SubStr @Time @Version @WordSize',0

.data?

hRAEditDLL				dd ?
hInstance				dd ?
CommandLine				dd ?
hIcon					dd ?
hAccel					dd ?
hWnd					dd ?
hREd					dd ?
hTab					dd ?
hCbo					dd ?
hFind					dd ?
hMnu					dd ?
hTbr					dd ?
hVSplit					dd ?
fVSplit					dd ?
hOut					dd ?
hVSplitCur				dd ?
hHSplitCur				dd ?
lpOldVSplitProc			dd ?
hReg					dd ?
lpdwDisp				dd ?
lpType					dd ?
lpcbData				dd ?
FileName				db MAX_PATH dup(?)
hFont					dd ?
hIFont					dd ?
hLnrFont				dd ?
findbuff				db 256 dup(?)
replacebuff				db 256 dup(?)
ft						FINDTEXTEX <>
fr						dd ?
fres					dd ?
nLastLine				dd ?
fTimer					dd ?
hMnuIml					dd ?
LineTxt					db 16384 dup(?)
prvline					dd ?
prnInches				dd ?
psd						PAGESETUPDLG <?>
pd						PRINTDLG <?>
prnfntht				dd ?
rcPrnPage				RECT <>
rcPrn					RECT <>
fUnicode				dd ?
hUndo					HGLOBAL ?
nUndoSize				dd ?
