
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

include ..\Addins\Addins.inc

include Inc\RAResEd.inc
includelib ..\Lib\RAResEd.lib

include Inc\RAHexEd.inc
includelib ..\Lib\RAHexEd.lib

include Inc\RAProject.inc
includelib ..\Lib\RAProject.lib

include Inc\RAFile.inc
includelib ..\Lib\RAFile.lib

include Inc\RACodeComplete.Inc
includelib ..\Lib\RACodeComplete.lib

include Inc\RAProperty.Inc
includelib ..\Lib\RAProperty.lib

includelib ..\Lib\Debug.lib

include Inc\RAGrid.Inc

include Inc\RAEdit.inc

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

WinMain					PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc					PROTO :DWORD,:DWORD,:DWORD,:DWORD
UpdateAll				PROTO :DWORD,:DWORD
CreateRAEdit			PROTO
CreateRAHexEd			PROTO
TabToolAdd				PROTO :DWORD,:DWORD

DwToAscii				PROTO :DWORD,:DWORD
SetWinCaption			PROTO :DWORD
WantToSave				PROTO :DWORD,:DWORD
SaveEdit				PROTO :DWORD,:DWORD
LoadEditFile			PROTO :DWORD,:DWORD
LoadHexFile				PROTO :DWORD,:DWORD
LoadRCFile				PROTO :DWORD

SetHiliteWords			PROTO :DWORD,:DWORD
SetToolMenu				PROTO
SetHelpMenu				PROTO

; Debug proto
SetDebugInfo			PROTO :DWORD
DebugCommand			PROTO :DWORD,:DWORD,:DWORD

strcpy					PROTO :DWORD,:DWORD
strcat					PROTO :DWORD,:DWORD
strcmp					PROTO :DWORD,:DWORD
strlen					PROTO :DWORD
DeleteGoto				PROTO :DWORD
PostAddinMessage		PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
AskSaveSessionFile		PROTO
ReadSessionFile			PROTO :DWORD
OpenEditFile			PROTO :DWORD,:DWORD
OutputString			PROTO :DWORD

HT_DEBUG				equ 224

; Debug functions
FUNC_RUN				equ 1
FUNC_STEPINTO			equ 2
FUNC_STEPOVER			equ 3
FUNC_RUNTOCARET			equ 4
FUNC_STOP				equ 5
FUNC_BPCLEARALL			equ 6
FUNC_BPADDLINE			equ 7
FUNC_BPUPDATE			equ 8
FUNC_GETTOOLTIP			equ 9
FUNC_IMMEDIATE			equ 10
FUNC_BREAK				equ 11
FUNC_FILEOPEN			equ 12
FUNC_ISCODELINE			equ 13

; Callback functions
CB_SELECTLINE			equ 1
CB_DESELECTLINE			equ 2
CB_DEBUG				equ 3
CB_OPENFILE				equ 4

IS_OPEN_ACTIVATE		equ -1
SAVE_ALL				equ -2
IS_RESOURCE				equ -3
IS_RESOURCE_OPEN		equ -4
CLOSE_ALL				equ -5
IS_CHANGED				equ -6
CLEAR_CHANGED			equ -7
SAVE_SESSIONFILE		equ -8
CLEAR_ERRORS			equ -9
FIND_ERROR				equ -10
CLEAR_BREAKPOINTS		equ -11
SET_BREAKPOINTS			equ -12
LOCK_SOURCE_FILES		equ -13
UNLOCK_SOURCE_FILES		equ -14
UNSAVED_SOURCE_FILES	equ -15
NEWER_SOURCE_FILES		equ -16
SAVE_SESSIONREGISTRY	equ -17
ADDTOPROJECT			equ -18
IS_OPEN					equ -19

TABHT					equ 23
CBOWT					equ 175
RESIZEHT				equ 3

IDB_TBRBMP				equ 150
IDR_ACCEL				equ 200
IDC_HSPLIT				equ 32109
IDC_VSPLIT				equ 32110
IDB_MNUARROW			equ 32101

;Find.dlg
IDD_FINDDLG				equ 3100
IDC_FINDTEXT			equ 2001
IDC_BTN_REPLACE			equ 2007
IDC_REPLACETEXT			equ 2002
IDC_REPLACESTATIC		equ 2009
IDC_BTN_REPLACEALL		equ 2008
IDC_CHK_WHOLEWORD		equ 2004
IDC_CHK_MATCHCASE		equ 2003
IDC_CHK_ALLFILES		equ 2010
IDC_RBN_ALL				equ 2011
IDC_RBN_DOWN			equ 2005
IDC_RBN_UP				equ 2006

IDD_HEXFINDDLG			equ 4300
IDC_FINDTEXT			equ 2001
IDC_BTN_REPLACE			equ 2007
IDC_REPLACETEXT			equ 2002
IDC_HEXREPLACESTATIC	equ 2009
IDC_BTN_REPLACEALL		equ 2008
IDC_RBN_DOWN			equ 2005
IDC_RBN_UP				equ 2006
IDC_RBN_HEX				equ 2003
IDC_RBN_ASCII			equ 2004

;MasmEd.dlg
IDD_DLG					equ 3000
IDC_TBR					equ 1001
IDC_TAB					equ 1004
IDC_SBR					equ 1003
IDC_SHP					equ 1005
IDC_OUT					equ 1006
IDC_IMMOUT				equ 1022
IDC_DBGREG				equ 1020
IDC_DBGWATCH			equ 1024
IDC_PROJECT				equ 1019
IDC_FILE				equ 1014
IDC_PROPERTY			equ 1015
IDC_BTNTABCLOSE			equ 1002
IDC_CLIENT				equ 1016
IDC_STC					equ 1017
IDC_CBO					equ 1018
IDC_TABOUT				equ 1021
IDC_TABWATCH			equ 1023
IDC_TABPROJECT			equ 1006

IDC_TOOLBOX				equ 1101
IDC_DLGEDIT				equ 1102

IDD_DLGSAVEUNICODE		equ 9000
IDC_CHKUNICODE			equ 1001

DECLARE struct
	hWin				HWND ?
	cp					DWORD ?
DECLARE ends

DEBUGINFO struct
	hWnd				HWND ?					; Handle of main window
	hOut				HWND ?					; Handle of output window
	hImmOut				HWND ?					; Handle of immediate window
	hDbgReg				HWND ?					; Handle of debug register window
	hDbgFpu				HWND ?					; Handle of debug FPU window
	hDbgMMX				HWND ?					; Handle of debug MMX window
	hDbgWatch			HWND ?					; Handle of debug watch window
	hPrp				HWND ?					; Handle of properties window
	lpNoDebug			DWORD ?					; Pointer to strings containing procs to not debug
	fMainThread			DWORD ?					; Only main thread
	lpCallBack			DWORD ?					; Callback
	FileName			BYTE MAX_PATH dup(?)	; Filename
	fProject			DWORD ?					; Project flag
DEBUGINFO ends

DEBUGTIP struct
	lpWord				DWORD ?
	lpProc				DWORD ?
	lpFileName			DWORD ?
	nLine				DWORD ?
DEBUGTIP ends

FILENOTIFYPATH struct
	nCount				DWORD ?
	path				BYTE MAX_PATH dup(?)
FILENOTIFYPATH ends

FILENOTIFY struct
	hThread				HANDLE ?
	lpPath				DWORD ?
	nCount				DWORD ?
	lpHandle			DWORD ?
	lpPtrPth			DWORD ?
FILENOTIFY ends

WINPOS struct
	fMax				DWORD ?
	fView				DWORD ?
	x					DWORD ?
	y					DWORD ?
	wt					DWORD ?
	ht					DWORD ?
	htout				DWORD ?
	wtfile				DWORD ?
	wtprop				DWORD ?
	htprop				DWORD ?
	left				DWORD ?
	top					DWORD ?
	wttoolbox			DWORD ?
WINPOS ends

EDITOPT struct
	tabsize				DWORD ?
	exptabs				DWORD ?
	indent				DWORD ?
	hiliteline			DWORD ?
	hilitecmnt			DWORD ?
	session				DWORD ?
	linenumber			DWORD ?
EDITOPT ends

PRNPOS struct
	margins				RECT <?>
	pagesize			POINT <?>
	nlinespage			DWORD ?
PRNPOS ends

NAMEEXPORT struct
	nType				DWORD ?
	szFileName			BYTE MAX_PATH dup(?)
	nOutput				DWORD ?
	fAuto				DWORD ?
NAMEEXPORT ends

GRIDSIZE struct
	x					DWORD ?
	y					DWORD ?
	show				DWORD ?
	snap				DWORD ?
	tips				DWORD ?
	color				DWORD ?
	line				DWORD ?
	stylehex			DWORD ?
GRIDSIZE ends

MEDCOLOR struct
	racol				RACOLOR <?>
	toolback			DWORD ?
	tooltext			DWORD ?
	dialogback			DWORD ?
	dialogtext			DWORD ?
	styles				DWORD ?
	words				DWORD ?
	ccback				DWORD ?
	cctext				DWORD ?
	ttback				DWORD ?
	tttext				DWORD ?
	ttapi				DWORD ?
	ttsel				DWORD ?
MEDCOLOR ends

THEME struct
	szname				BYTE 32 dup(?)
	kwcol				DWORD 16 dup(?)
	medcol				MEDCOLOR <>
THEME ends

ifndef MENUINFO
MENUINFO STRUCT
	cbSize				DWORD	?
	fMask				DWORD	?
	dwstyle				DWORD	?
	cyMax				DWORD	?
	hbrBack				DWORD	?
	dwContextHelpID		DWORD	?
	dwMenuData			DWORD	?
MENUINFO ends
endif

MENUDATA struct
	img					DWORD ?
	tpe					DWORD ?
MENUDATA ends

PROPERTIES	struct
	nSize				DWORD ?
	nOwner				DWORD ?
	nLine				DWORD ?
	nEnd				DWORD ?
	nType				BYTE ?
PROPERTIES ends

MENU struct
	szcap	db 32 dup(?)
	szcmnd	db 256 dup(?)
MENU ends

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
						TBBUTTON <23,IDM_EDIT_INDENT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <22,IDM_EDIT_OUTDENT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <24,IDM_EDIT_COMMENT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <25,IDM_EDIT_UNCOMMENT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <21,IDM_VIEW_OUTPUT,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK,0,0>
						TBBUTTON <26,IDM_VIEW_DIALOG,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <12,IDM_MAKE_ASSEMBLE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <13,IDM_MAKE_BUILD,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <14,IDM_MAKE_RUN,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <15,IDM_MAKE_GO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
ntbrbtns				equ 36

ALLFilterString			db 'Assembly Files (*.asm, *.inc, *.rc)',0,'*.asm;*.inc;*.rc',0
						db 'Text Files (*.txt)',0,'*.txt',0
ANYFilterString			db 'All Files (*.*)',0,'*.*',0,0
MESFilterString			db 'Session (*.mes)',0,'*.mes',0,0

szRemoveMasmEd			db '/remove',0
szAskRemove				db 'Remove MasmEd from registry?',0

szOutput				db 'Output',0
szImmediate				db 'Immediate',0

szRegister				db 'Register',0
szFloat					db 'FPU',0
szMMX					db 'MMX',0
szWatch					db 'Watch',0

szFile					db 'File',0
szProject				db 'Project',0

szFmtDec				db '%d',0
szPROTO					db ' PROTO',0

pbfileext				PBFILEEXT 5 dup(<1,'.asm.'>,<2,'.inc.'>,<3,'.rc.'>,<4,'.txt.'>,<0>)
szDefProGroups			db '-1,0,1,',0,',-2,-1,1,Assembly,-3,-1,1,Include,-4,-1,1,Misc,-5,-1,1,Resource',0

.data

szRichEdit				db 'riched20.dll',0
ClassName				db 'DLGCLASS',0
szResClassName			db 'RESCLASS',0
sztooltips_class32		db 'tooltips_class32',0
szAppName				db 'MasmEd',0
szVersion				db 'MasmEd version 1.2.0.0',0
szAboutMsg				db 'MasmEd code & resource editor',0Dh,0Ah,0Dh,0Ah,'KetilO (C) 2004-2010',13,10,'radasmide@hotmail.com',0
szAboutUrl1				db 'http://radasm.cherrytree.at/',0
;szAboutUrl2				db 'http://radasm.110mb.com/masmed',0
szOpen					db 'Open',0

szReplace				db 'Replace ..',0
szRegionSearched		db 'Region searched.',0
szOpenFileFail        	db 'Cannot open the file.',0Dh,0
szSaveFileFail			db 'Cannot save the file.',0Dh,0
szFileExists			db 'The file exists.',0Dh,0
szWannaSave           	db 'Want to save changes to',0Dh,0
szNewFile             	db '(Untitled)',0
szChanged				db 'File is changed outside editor',0Dh,0
szReopen				db 0Dh,0Dh,'Reopen the file?',0
szSaveSession			db 'Save current session to?',0Dh,0
szNoMain				db 'No main file selected.',0Dh,'Use Make / Set Current as Mainfile.',0Dh,0
szUnsaved				db 'There are %d unsaved source files.',0
szNewer					db 'There are %d source files newer than the .exe.',0
szNewProject			db 'Would you like to create an empty project?',0Dh,0Dh
						db 'If you open your source files first, MasmEd',0Dh
						db 'will automatically add those files.',0
szAddProjectFiles		db 'Add Files to Project',0
szAddNewProjectFile		db 'Add New File to Project',0
szFtAsm					db '.asm',0
szFtInc					db '.inc',0
szFtApi					db '.api',0
szFtRc					db '.rc',0
szFtMes					db '.mes',0
szNULL					db 0
szTab					db VK_TAB,0
szSpc					db ' ',0
szCr					db 0Dh,0
szCrLf					db 0Dh,0Ah,0
szQuote					db '"',0
szBackSlash				db '\',0
szComma					db ',',0
szSemi					db ';',0
szDot					db '.',0
szError					db ' error ',0

szProc					db '$ proc',0,0
szEndp					db '? endp',0,0
szIf					db '.if',0,0
szElseIf				db '.elseif',0,0
szElse					db '.else',0,0
szEndIf					db '.endif',0,0
szWhile					db '.while',0,0
szEndw					db '.endw',0,0
szRepeat				db '.repeat',0,0
szUntil					db '.until|.untilcxz',0,0
szBreak					db '.break',0,0
szContinue				db '.continue',0,0
szStruct				db '? struct|? struc|? union',0,0
szEnds					db '? ends',0,0
szMacro					db '$ macro',0,0
szEndm					db 'endm',0,0
szData					db '.data',0,0
szDataU					db '.data?',0,0
szConst					db '.const',0,0
szCode					db '.code',0,0
szComment				db 'comment',0,0
szStart					db 'start:',0,0
szEndStart				db 'end start',0,0
szBegin					db 'BEGIN',0,0
szEnd					db 'END',0,0

align 4
rabdproc				RABLOCKDEF <offset szProc,offset szEndp,0,0,BD_DIVIDERLINE or BD_INCLUDELAST>
rabdif					RABLOCKDEF <offset szIf,offset szEndIf,offset szElseIf,offset szElse,0>
rabdwhile				RABLOCKDEF <offset szWhile,offset szEndw,offset szBreak,offset szContinue,0>
rabdrepeat				RABLOCKDEF <offset szRepeat,offset szUntil,offset szBreak,offset szContinue,0>
rabdstruct				RABLOCKDEF <offset szStruct,offset szEnds,0,0,BD_DIVIDERLINE or BD_INCLUDELAST>
rabdmacro				RABLOCKDEF <offset szMacro,offset szEndm,0,0,BD_DIVIDERLINE or BD_INCLUDELAST or BD_LOOKAHEAD>
rabddata				RABLOCKDEF <offset szData,0,0,0,BD_SEGMENTBLOCK>
rabddatau				RABLOCKDEF <offset szDataU,0,0,0,BD_SEGMENTBLOCK>
rabdconst				RABLOCKDEF <offset szConst,0,0,0,BD_SEGMENTBLOCK>
rabdcode				RABLOCKDEF <offset szCode,0,0,0,BD_SEGMENTBLOCK>
rabdcomment				RABLOCKDEF <offset szComment,0,0,0,BD_COMMENTBLOCK>
rabdstart				RABLOCKDEF <offset szStart,offset szEndStart,0,0,0>
rabdbegin				RABLOCKDEF <offset szBegin,offset szEnd,0,0,2 SHL 16>

blocks					dd rabdif,rabdwhile,rabdrepeat,rabdproc,rabdstruct,rabdmacro,rabdcomment,rabddata,rabddatau,rabdconst,rabdcode,rabdstart,rabdbegin,0,0

szCmntStart				db 'comment +',0
szCmntEnd				db '-',0
szBracketMatch			db '[({,])},\,',0

szAdd					db 'Add ',0
szCustType				db 'Type#',0
szMakeType				db 'Make#',0
szREG_SZ				db 'REG_SZ',0
szMasmEd				db 'Software\MasmEd1000\'
						db 64 dup(0)
szSoftware				db 'Software',0
szMasmEd1000			db 'MasmEd1000',0
szWinPos				db 'WinPos',0
wpos					WINPOS <0,15,10,10,620,460,100,175,175,200,100,100,52>
szEditOpt				db 'EditOpt',0
edopt					EDITOPT <4,FALSE,TRUE,FALSE,TRUE,TRUE,TRUE>
szCodeFont				db 'CodeFont',0
lfnt					LOGFONT <-12,0,0,0,400,FALSE,FALSE,FALSE,0,0,0,0,0,'Courier New'>
szLnrFont				db 'LnrFont',0
lfntlnr					LOGFONT <-8,0,0,0,400,FALSE,FALSE,FALSE,0,0,0,0,0,'Terminal'>
szColor					db 'Color',0
col						MEDCOLOR <<BCOL,TCOL,SELBCOL,SELTCOL,CMNTCOL,STRCOL,OPRCOL,HILITE1,HILITE2,HILITE3,SELBARCOL,SELBARPEN,LNRCOL,NUMCOL,BCOL,BCOL,BCOL,BCOL,CHCOL,CHSAVEDCOL>,DEFBCKCOL,TCOL,DEFBCKCOL,TCOL,STYLESCOL,WORDSCOL,CCBCK,CCTXT,TTBCK,TTTXT,TTAPI,TTSEL>
szPrnPos				db 'PrnPos',0
ppos					PRNPOS <<1000,1000,1000,1000>,<21000,29700>,65>
szVer					db 'Version',0
szGroup					db 'Group#',0
szKeyWordColor			db 'KeyWordColor',0
kwcol					dd 00804000h,00808000h,00FF0000h,00FF0000h,00FF0000h,10FF0000h,000040FFh,00FF0000h,01FF0000h,00FF0000h,00A00000h,00A00000h,00A00000h,00A00000h,00A00000h,00A00000h
kwofs					dd C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15
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
C6						db '$ ? @@ @B @F ADDR BASIC C CARRY? FAR FAR16 FORTRAN NEAR NEAR16 OVERFLOW? PARITY? PASCAL SIGN? STDCALL SYSCALL USES VARARG ZERO?',0
;MASM Keywords (non-code producing)
C7						db '%OUT .186 .286 .286C .286P .287 .386 .386C .386P .387 .486 .486P .586 .686 .686p .8086 .8087 .ALPHA .CODE .CONST .CREF .DATA .DATA? .DOSSEG .ERR .ERR1 .ERR2 .ERRB .ERRDEF .ERRDIF .ERRDIFI .ERRE .ERRIDN '
						db '.ERRIDNI .ERRNB .ERRNDEF .ERRNZ .EXIT .FARDATA .FARDATA? .K3D .LALL .LFCOND .LIST .LISTALL .LISTIF .LISTMACRO .LISTMACROALL .MMX .MODEL .MSFLOAT .NO87 .NOCREF .NOLIST .NOLISTIF .NOLISTMACRO .RADIX .SALL '
						db '.SEQ .SFCOND .STACK .STARTUP .TFCOND .TYPE .XALL .XCREF .XLIST .XMM ALIAS ALIGN ASSUME CATSTR COMM COMMENT+ DB DD DF DOSSEG DQ DT DUP DW ECHO ELSE ELSEIF ELSEIF1 ELSEIF2 ELSEIFB ELSEIFDEF ELSEIFDIF '
						db 'ELSEIFDIFI ELSEIFE ELSEIFIDN ELSEIFIDNI ELSEIFNB ELSEIFNDEF END ENDIF ENDM ENDP ENDS ENDW EQ EQU EVEN EXITM EXTERN EXTERNDEF EXTRN FOR FORC GE GOTO GROUP GT HIGH HIGHWORD IF IF1 IF2 IFB IFDEF IFDIF '
						db 'IFDIFI IFE IFIDN IFIDNI IFNB IFNDEF INCLUDE- INCLUDELIB- INSTR IRP IRPC LABEL LE LENGTH LENGTHOF LOCAL LOW LOWWORD LROFFSET LT MACRO MASK MOD NAME NE OFFSET OPATTR OPTION ORG PAGE POPCONTEXT PROC PROTO '
						db 'PTR PUBLIC PURGE PUSHCONTEXT RECORD REPEAT REPT SEG SEGMENT SHORT SIZE SIZEOF SIZESTR STRUC STRUCT SUBSTR SUBTITLE SUBTTL TEXTEQU THIS TITLE- TYPE TYPEDEF UNION WHILE WIDTH',0
;MASM High Level Key Words (code producing)
C8						db '.BREAK .CONTINUE .ELSE .ELSEIF .ENDIF .ENDW .IF .REPEAT .UNTIL .UNTILCXZ .WHILE INVOKE',0
;CaseSensitive Macro Ops
C9						db '@CatStr @code @CodeSize @Cpu @CurSeg @data @DataSize @Date @Environ @fardata @fardata? @FileCur @FileName @InStr @Interface @Line @Model @SizeStr @stack @SubStr @Time @Version @WordSize',0
C10						db 0
C11						db 0
C12						db 0
C13						db 0
C14						db 0
C15						db 0

szNmeExp				db 'NmeExp',0
nmeexp					NAMEEXPORT <0,'rsrc.inc',0>
szGrid					db 'Grid',0
grdsize					GRIDSIZE <3,3,TRUE,TRUE,TRUE,0,FALSE,TRUE>

szPathBin				db 'PathBin',0
szPathInc				db 'PathInc',0
szPathLib				db 'PathLib',0
szMainFile				db 'MainFile',0
szCompileRC				db 'CompileRC',0
szAssemble				db 'Assemble',0
szLink					db 'Link',0
szDbgAssemble			db 'DbgAssemble',0
szDbgLink				db 'DbgLink',0
szBuild					db 'Build',0

szFolder				db 'Folder',0
szSession				db 'Session',0
szProGroup				db 'Group',0
szBreakPoint			db 'BreakPoint',0
szBookMark				db 'BookMark',0
szCollapse				db 'Collapse',0
szMRUFiles				db 'MRUFiles',0
szMRUSessions			db 'MRUSessions',0
szFilter				db '.asm.inc.txt.def.rc.exe.bat.mes.',0

fn						FILENOTIFY <0,fnpath,0,fnhandle,fnptrpth>

szCaseTypes				db 'WPMpcm',0
szGotoTypes				db 'pldcs',0
szMsg1					db 'SendMessage',0
szMsg2					db 'PostMessage',0
szMsg3					db 'SendDlgItemMessage',0

;Addin procs
pa						ADDINPROCS <OpenEditFile,OutputSelect,OutputShow,OutputString,OutputClear,TabToolAdd,TabToolActivate,TabToolGetMem,UpdateFileTime,TabToolSetChanged,UpdateFileName,WriteSessionFile>

szOptTool			db 'Tools menu',0
szMenuTool			db 'Tool#',0
szFilterTools		db 'Commands (*.com, *.exe, *.cmd)',0,'*.com;*.exe;*.cmd',0
					db 'All Files (*.*)',0,'*.*',0,0
szOptHelp			db 'Help menu',0
szMenuHelp			db 'Help#',0
szFilterHelp		db 'Help (*.hlp, *.chm)',0,'*.hlp;*.chm',0
					db 'All Files (*.*)',0,'*.*',0,0
szOptExternal		db 'External Files',0
szMenuExternal		db 'External#',0
szStcExternal		db 'Filetypes (note the use of dots):',0
ExternalUpdate		MENU <'.bmp.ico.','mspaint.exe'>

.data

MenuIDAddins			dd 40000

.data?

;Addin handles and dats
ha						ADDINHANDLES <>
da						ADDINDATA <>
;File changed notifications
fnpath					FILENOTIFYPATH MAXIMUM_WAIT_OBJECTS dup(<?>)
fnhandle				DWORD MAXIMUM_WAIT_OBJECTS dup(?)
fnptrpth				DWORD MAXIMUM_WAIT_OBJECTS dup(?)

CommandLine				DWORD ?
hRichEd					DWORD ?
hIcon					DWORD ?
nOutSel					DWORD ?
nDbgSel					DWORD ?
fVSplit					DWORD ?
lpdwDisp				DWORD ?
lpType					DWORD ?
lpcbData				DWORD ?
;Find
ft						FINDTEXTEX <>
fr						DWORD ?
fres					DWORD ?
ndir					DWORD ?
findchrg				CHARRANGE <>
findpt					POINT <>
fallfiles				DWORD ?
ntab					DWORD ?
findtabs				DWORD 256 dup(?)
;RAEdit notification
nLastLine				DWORD ?
nLastSize				DWORD ?
nLastPropLine			DWORD ?
fTimer					DWORD ?
;Subclassing
lpOldRAEditProc			DWORD ?
lpOldTabProc			DWORD ?
lpOldImmediateProc		DWORD ?
;Buffers and Arrays
						DWORD ?
LineTxt					BYTE 16384 dup(?)
						DWORD ?
tmpbuff					BYTE 16384 dup(?)
						DWORD ?
mnubuff					BYTE 8192 dup(?)
ErrID					DWORD 128 dup(?)
hCustDll				HMODULE 32 dup(?)
gotostack				DECLARE 32 dup(<?>)
mrufiles				BYTE 10*MAX_PATH dup(?)
mrusessions				BYTE 10*MAX_PATH dup(?)
;Window sizes
winsize					WINSIZE <?>
;Print
psd						PAGESETUPDLG <?>
pd						PRINTDLG <?>

icex					INITCOMMONCONTROLSEX <?>
nErrID					DWORD ?
fResNotify				DWORD ?
mnupos					DWORD ?
tabinx					DWORD ?
fUnicode				DWORD ?
nTabInx					DWORD ?
;Debug
fDebugging				DWORD ?
fMainThread				DWORD ?
nUnsaved				DWORD ?
ftexe					FILETIME <>
nNewer					DWORD ?
dbgpt					POINT <>
dbginf					DEBUGINFO <>
ttmsg					MESSAGE <>
tt						TOOLTIP <>
