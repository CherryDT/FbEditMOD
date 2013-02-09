
;#########################################################################

;include files
include windows.inc
include gdi32.inc
include user32.inc
include kernel32.inc
include comctl32.inc
include comdlg32.inc
include shell32.inc
include shlwapi.inc
include ole32.inc
include advapi32.inc
include wininet.inc

;libraries
includelib gdi32.lib
includelib user32.lib
includelib kernel32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib shell32.lib
includelib shlwapi.lib
includelib ole32.lib
includelib advapi32.lib
includelib wininet.lib

include Inc\RAEdit.inc
include Inc\RAHexEd.inc
include Inc\RAGrid.inc
include Inc\RACodeComplete.Inc
include Inc\RAFile.Inc
include Inc\RAProject.inc
include Inc\RAProperty.Inc
include Inc\RAResEd.Inc
include Inc\RATools.Inc
include Addins\Addins.inc

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

includelib ..\Lib\RACodeComplete.lib
includelib ..\Lib\RAFile.lib
includelib ..\Lib\RAHexEd.lib
includelib ..\Lib\RAProject.lib
includelib ..\Lib\RAProperty.lib
includelib ..\Lib\RAResEd.lib
includelib ..\Lib\RATools.lib
includelib ..\Lib\Debug.lib

TabProc							PROTO	:HWND,:UINT,:WPARAM,:LPARAM
TabToolActivate					PROTO
MakeMdiCldWin					PROTO	:DWORD,:DWORD
SaveTheFile						PROTO	:HWND
WantToSave						PROTO	:HWND
SetHiliteWords					PROTO	:DWORD,:DWORD
OpenTheFile						PROTO	:DWORD,:DWORD
TabToolGetInx					PROTO	:DWORD
TabToolGetInxFromPid			PROTO	:DWORD
OpenProject						PROTO
CloseProject					PROTO
GetTheFileType					PROTO	:DWORD
SetF1Help						PROTO
SetHelpMenu						PROTO
SetToolMenu						PROTO
OpenFiles						PROTO	:DWORD
ParseEdit						PROTO	:HWND,:DWORD
RemovePath						PROTO	:DWORD,:DWORD,:DWORD

PostAddinMessage				PROTO	:HWND,:UINT,:WPARAM,:LPARAM,:DWORD,:DWORD
GetModify						PROTO	:HWND
TextOutput						PROTO	:DWORD

; Debug proto
SetDebugInfo					PROTO	:DWORD
DebugCommand					PROTO	:DWORD,:DWORD,:DWORD

IDI_MDIICO						equ 100
IDC_SPLICURV					equ 150
IDC_SPLICURH					equ 151
IDB_TBRBMP						equ 152

MAX_MISS						equ 10
START_FILES						equ 1
MAX_FILES						equ 1000

; Debug functions
FUNC_RUN						equ 1
FUNC_STEPINTO					equ 2
FUNC_STEPOVER					equ 3
FUNC_RUNTOCARET					equ 4
FUNC_STOP						equ 5
FUNC_BPCLEARALL					equ 6
FUNC_BPADDLINE					equ 7
FUNC_BPUPDATE					equ 8
FUNC_GETTOOLTIP					equ 9
FUNC_IMMEDIATE					equ 10
FUNC_BREAK						equ 11
FUNC_FILEOPEN					equ 12
FUNC_ISCODELINE					equ 13

; Debug callback functions
CB_SELECTLINE					equ 1
CB_DESELECTLINE					equ 2
CB_DEBUG						equ 3
CB_OPENFILE						equ 4

IDD_GOTODLG						equ 4200
IDC_LINENO						equ 1008

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

;Help
HH_AKLINK struct
	cbStruct		dd ?						;As Integer
	fReserved		dd ?						;As Boolean
	pszKeywords		dd ?						;As ZString Ptr
	pszUrl			dd ?						;As ZString Ptr
	pszMsgText		dd ?						;As ZString Ptr
	pszMsgTitle		dd ?						;As ZString Ptr
	pszWindow		dd ?						;As ZString Ptr
	fIndexOnFail	dd ?						;As Boolean
HH_AKLINK ends

HH_DISPLAY_TOPIC	equ 0000h
HH_KEYWORD_LOOKUP	equ 000Dh

.const

szMdiClassName					db 'RadASM30Class',0
szMdiClientClassName			db 'MDICLIENT',0
szEditCldClassName				db 'MdiEditChild',0
szReBarClassName				db 'ReBarWindow32',0
szComboBoxClassName				db 'ComboBox',0
szToolBarClassName				db 'ToolbarWindow32',0
szStaticClassName				db 'Static',0
szTabControlClassName			db 'SysTabControl32',0
szRichEdit						db 'riched20.dll',0
sztooltips_class32				db 'tooltips_class32',0

szhhctrl						db 'hhctrl.ocx',0
szHtmlHelpA						db 'HtmlHelpA',0

DisplayName						db 'RadASM',0
RadASMVersion					equ 3008
szVersion						db 'RadASM version 3.0.0.8',0
szAboutMsg						db 'RadASM (C) KetilO 2011',13,10,13,10,'radasmide@hotmail.com',0
szAboutUrl1						db 'http://radasm.cherrytree.at/',0
szBS							db '\',0
szPipe							db '|',0
szDot							db '.',0
szComma							db ',',0
szSemi							db ';',0
szMinus							db '-',0
szQuote							db '"',0
szCR							db VK_RETURN,0
szTab							db VK_TAB,0
szDotIni						db '.ini',0
szDotDef						db '.def',0
szDotExe						db '.exe',0
szDotDll						db '.dll',0
szDotExp						db '.exp',0
szDotLib						db '.lib',0
szDotPrra						db '.prra',0
szDotPrraDot					db '.prra.',0
szBSApiBS						db '\Api\',0
szBSBakBS						db '\Bak\',0
szBSSniplets					db '\Sniplets',0
szSpc							db ' ',0
szNULL							db 0
szINS							db 'INS',0
szOVR							db 'OVR',0
szBLKINS						db 'BLKINS',0
szBLKOVR						db 'BLKOVR',0
szDollarA						db '$A',0						;App path
szDollarC						db '$C',0						;Main code file
szDollarD						db '$D',0						;def file
szDollarF						db '$F',0						;Main code file without extention
szDollarM						db '$M',0						;Modules file
szDollarO						db '$O',0						;Output file
szDollarR						db '$R',0						;Main resource script file without extention

szDefUserExport					db '%name %id',0
szDefFilter						db '.asm.inc.rc.prra.',0
szPROTO							db ' PROTO',0
szMasm							db 'masm',0
szErrorMasm						db ': error ',0
szErrorTasm						db '**Error**',0
szErrorFasm						db ']:',0
szErrorGoAsm					db 'Error!',0
szErrorAsemw					db '): ',0
szADotA							db '*.*',0

;Code properties
szCCPp							db 'Pp',0
szCCp							db 'p',0
szCCC							db 'C',0
szCCAll							db 'WSPpcdsm',0
szCCSs							db 'Ss',0
szCCd							db 'd',0
szCCAssume						db 'assume ',0
szCaseTypes						db 'WPMpcm',0
szGotoTypes						db 'pldcs',0
szCCTip							db 'PMSTWpcsdml',0
szMsg1							db 'SendMessage',0
szMsg2							db 'PostMessage',0
szMsg3							db 'SendDlgItemMessage',0
szCurrentFile					db 'Current file',0
szAllFiles						db 'All files',0
szRefresh						db 'Refresh',0

;RadASM.ini, assembler.ini and project.prra
szInifile						db 'RadASM.ini',0
szIniAppPath					db 'AppPath',0
szIniWin						db 'Win',0
szIniPos						db 'Pos',0
szIniPosRes						db 'PosRes',0
szIniFont						db 'Font',0
szIniTool						db 'Tool',0
szIniCode						db 'Code',0
szIniLine						db 'Line',0
szIniText						db 'Text',0
szIniHex						db 'Hex',0
szIniProject					db 'Project',0
szIniProperty					db 'Property',0
szIniOutput						db 'Output',0
szIniTab						db 'Tab',0
szIniReBar						db 'Rebar',0
szIniLock						db 'Lock',0
szIniSession					db 'Session',0
szIniPath						db 'Path',0
szIniAssembler					db 'Assembler',0
szIniError						db 'Error',0
szIniKeywords					db 'Keywords',0
szIniColors						db 'Colors',0
szIniCodeBlock					db 'CodeBlock',0
szIniCmnt						db 'Cmnt',0
szIniEdit						db 'Edit',0
szIniBraceMatch					db 'BraceMatch',0
szIniOption						db 'Option',0
szIniParse						db 'Parse',0
szIniType						db 'Type',0
szIniArg						db 'Arg',0
szIniLocal						db 'Local',0
szIniIgnore						db 'Ignore',0
szIniDef						db 'Def',0
szIniFile						db 'File',0
szIniResource					db 'Resource',0
szIniCodeComplete				db 'CodeComplete',0
szIniTrig						db 'Trig',0
szIniInc						db 'Inc',0
szIniLib						db 'Lib',0
szIniApi						db 'Api',0
szIniFilter						db 'Filter',0
szIniGroup						db 'Group',0
szIniOpen						db 'Open',0
szIniVersion					db 'Version',0
szIniTheme						db 'Theme',0
szIniCustCtrl					db 'CustCtrl',0
szIniCustStyle					db 'CustStyle',0
szIniCustType					db 'CustType',0
szIniMake						db 'Make',0
szIniDelete						db 'Delete',0
szIniIncBuild					db 'IncBuild',0
szIniHelp						db 'Help',0
szIniEnvironment				db 'Environment',0
szIniHeader						db 'Header',0
szIniMru						db 'Mru',0
szIniExternal					db 'External',0
szIniHelpF1						db 'HelpF1',0
szIniRun						db 'Run',0
szIniFind						db 'Find',0
szIniCharTab					db 'CharTab',0
szIniAddins						db 'Addins',0
szIniTplTxt						db 'TplTxt',0
szIniTplBin						db 'TplBin',0
szIniPrint						db 'Print',0
szIniDebug						db 'Debug',0
szIniDescription				db 'Description',0
szIniExtDebug					db 'ExtDebug',0
szIniNoSEH						db 'NoSEH',0

szDefReBar						db '1,132,123,2,132,199,3,132,193,4,132,47,5,132,101,6,132,1024',0
szNewFile						db '(Untitled)',0

szOpenFileFail					db 'Cannot open the file.',0Dh,0
szWannaSave           			db 'Want to save changes to',0Dh,0
szFileChanged					db 'The file is changed. Continue?',0Dh,0
szRadASMVersion					db 'The RadASM.ini file is an older version or is missing.',0Dh,0
szProjectVersion				db 'The project file is an older version.',0
szAssemblerVersion				db 'The Assembler.ini file is an older version or is missing.',0Dh,0
szErrDir						db 'Could not create directory!',0Dh,0
szErrOverwrite					db 'Overwrite existing file?',0Dh,0
szErrCreate						db 'Could not create the file!',0Dh,0
szErrFileExists					db 'The file exists!',0Dh,0
szReplace						db 'Replace...',0
szRegionSearched				db 'Region searched.',0
szReplaceDone					db 'Region searched.',0Dh,'%d replacements done.',0
szAddNewProjectFile				db 'Add New File To Project',0
szAddExistingProjectFiles		db 'Add Existing Files To Project',0
szDeleted						db 'Deleted: ',0
szUnsaved						db 'There are %d unsaved source files.',0
szNewer							db 'There are %d source files newer than the .exe.',0
szChanged						db 'File is changed outside editor',0Dh,0
szReopen						db 0Dh,0Dh,'Reopen the file?',0

defcol							dd 00800040h,00800040h,00800040h,00800040h,00800040h,10800040h,00800040h,00800040h,01800040h,00800040h,00800040h,00800040h,00800040h,00800040h,00800040h,00800040h
								dd 00FFFFFFh,00000000h,00800000h,00FFFFFFh,02008000h,00A00000h,000000A0h,00F0C0C0h,00C0F0C0h,00C0C0F0h,00E0E0E0h,00808080h,00800000h,00808080h,00FFFFFFh,00FFFFFFh,00FFFFFFh,00FFFFFFh,0000F0F0h,0000F000h
								dd 00FFFFFFh,00000000h,00FFFFFFh,00000000h,00804000h,00C00000h,00FFFFFFh,00000000h,00C0F0F0h,00000000h,00404080h,00FF0000h

szDefCODEString					db 'Assembly Files (*.asm, *.inc)|*.asm;*.inc',0
szDefRESString					db 'Resource Files (*.rc)|*.rc',0
szDefTXTString					db 'Text Files (*.txt)|*.txt',0
szDefANYString					db 'All Files (*.*)|*.*',0
szDefPROString					db 'Project Files (*.prra)|*.prra',0

szWINAPI						db 'WINAPI ',0
szPROC							db 'PROC ',0
szSTRUCT						db 'STRUCT ',0
szGLOBAL						db 'GLOBAL ',0
szTYPE							db 'TYPE ',0
szCONST							db 'CONST ',0
szMESSAGE						db 'MESSAGE ',0
szPARAM							db 'PARAM ',0
szLOCAL							db 'LOCAL ',0
szLABEL							db 'LABEL ',0

.data

pa								ADDINPROCS <OpenTheFile,SetOutputTab,ShowOutput,TextOutput,TabToolSetChanged,TabToolGetMem,TabToolAdd,TabToolActivate,UpdateFileName,UpdateFileTime,UpdateAll>
fn								FILENOTIFY <0,fnpath,0,fnhandle,fnptrpth>
MenuIDAddins					DWORD 40000

.data?

osvi							OSVERSIONINFO <>
fNT								DWORD ?
CommandLine						DWORD ?
icex							INITCOMMONCONTROLSEX <>
ha								ADDINHANDLES <>
da								ADDINDATA <>
mdiID							DWORD ?
;File changed notifications
fnpath							FILENOTIFYPATH MAXIMUM_WAIT_OBJECTS dup(<?>)
fnhandle						DWORD MAXIMUM_WAIT_OBJECTS dup(?)
fnptrpth						DWORD MAXIMUM_WAIT_OBJECTS dup(?)
lpOldTabProc					DWORD ?
tmpbuff							BYTE 24*1024 dup(?)
LineTxt							BYTE 24*1024 dup(?)
lpOldClientProc					DWORD ?
lpOldRAEditCodeProc				DWORD ?
hRichEd							DWORD ?
ttmsg							MESSAGE <>
tt								TOOLTIP <>
gotostack						DECLARE 32 dup(<?>)
hEnv							HGLOBAL ?
dbgpt							POINT <>
szOldTip						BYTE 256 dup(?)
dbginf							DEBUGINFO <>
nUnsaved						DWORD ?
ftexe							FILETIME <>
nNewer							DWORD ?
defgen							DEFGEN <>

