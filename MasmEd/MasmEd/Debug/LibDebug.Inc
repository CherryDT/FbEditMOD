
;#########################################################################
; Include files
include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc
include comctl32.inc
include version.inc
include dbghelp.inc

;#########################################################################
; Libraries
includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib version.lib

;#########################################################################
; VKim's Debug
include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

CalculateIt						PROTO :DWORD
DoMath							PROTO :DWORD

;#########################################################################
; Constants

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

; Callback functions
CB_SELECTLINE					equ 1
CB_DESELECTLINE					equ 2
CB_DEBUG						equ 3
CB_OPENFILE						equ 4

; Format items
FMT_NAME						equ 1
FMT_TYPE						equ 2
FMT_ADDRESS						equ 4
FMT_SIZE						equ 8
FMT_HEX							equ 16
FMT_DEC							equ 32
FMT_SZ							equ 64

ERR_NOTFOUND					equ 1
ERR_INDEX						equ 2
ERR_SYNTAX						equ 3
ERR_DIV0						equ 4
ERR_OVERFLOW					equ 5

; RAEdit message
REM_BASE						equ WM_USER+1000
REM_SETHILITELINE				equ REM_BASE+5		;wParam=Line, lParam=Color
REM_LINEREDTEXT					equ REM_BASE+82		;wParam=nLine, lParam=TRUE/FALSE

; RAProperties messages
PRM_FINDFIRST					equ WM_USER+13		;wParam=lpszTypes, lParam=lpszText
PRM_FINDNEXT					equ WM_USER+14		;wParam=0, lParam=0
PRM_FINDGETTYPE					equ WM_USER+15		;wParam=0, lParam=0

;#########################################################################
; Structures

DEBUGINFO struct
	hWnd					HWND ?					; Handle of main window
	hOut					HWND ?					; Handle of output window
	hImmOut					HWND ?					; Handle of immediate window
	hDbgReg					HWND ?					; Handle of debug register window
	hDbgFpu					HWND ?					; Handle of debug FPU window
	hDbgMMX					HWND ?					; Handle of debug MMX window
	hDbgWatch				HWND ?					; Handle of debug watch window
	hPrp					HWND ?					; Handle of properties window
	lpNoDebug				DWORD ?					; Pointer to strings containing procs to not debug
	fMainThread				DWORD ?					; Only main thread
	lpCallBack				DWORD ?					; Callback
	FileName				BYTE MAX_PATH dup(?)	; Filename
	fProject				DWORD ?					; Project flag
DEBUGINFO ends

DEBUGTIP struct
	lpWord					DWORD ?
	lpProc					DWORD ?
	lpFileName				DWORD ?
	nLine					DWORD ?
DEBUGTIP ends

PROPERTIES	struct
	nSize					DWORD ?
	nOwner					DWORD ?
	nLine					DWORD ?
	nEnd					DWORD ?
	nType					BYTE ?
PROPERTIES ends

; Breakpoints
BREAKPOINT struct
	FileID					DWORD ?					; File id, 1 based
	LineNumber				DWORD ?					; Line number, 1 based
BREAKPOINT ends

; Source files
DEBUGSOURCE struct
	FileID					DWORD ?					; The id of the file
	FileName				BYTE MAX_PATH dup(?)	; Filename
DEBUGSOURCE ends

; Line numbers
DEBUGLINE struct
	LineNumber              DWORD ?					; Line number, 1 based
	Address                 DWORD ?					; Address
	FileID					WORD ?					; ID of file containing line (DEBUGSOURCE)
	NoDebug					BYTE ?					; Line shold not be debugged
	BreakPoint				BYTE ?					; There is a breakpoint on this line
DEBUGLINE ends

; Datatypes
DEBUGTYPE struct
	szName					db 64 dup(?)			; Name of type
	nSize					DWORD ?					; Size in bytes
DEBUGTYPE ends

; Symbols
DEBUGSYMBOL struct
	szName					db 64 dup(?)			; Name of proc / global var
	Address                 DWORD ?					; Adress
	nSize					DWORD ?					; Size in bytes
	nArray					DWORD ?					; Number of elements
	lpType					DWORD ?					; PROC: pointer to szParam + szLocals, GLOBAL: pointer to szArray + szDatatype
	nType					WORD ?					; PROC: 'p', GLOBAL: 'd'
	NoDebug					WORD ?					; PROC should not be debugged
DEBUGSYMBOL ends

; Variables. Global, parameters and locals
DEBUGVAR struct
	nSize					DWORD ?					; Size in bytes
	nArray					DWORD ?					; Followed by szName and szArray+Type 'MyVar',0,'[256]:BYTE',0
	nOfs					DWORD ?					; Offset for proc parameter or local
DEBUGVAR ends

; Threads
DEBUGTHREAD struct
	htread					HANDLE ?				; Thread handle
	threadid				DWORD ?					; Thread ID
	lpline					DWORD ?					; Pointer to line
	address					DWORD ?					; Address
	suspended				DWORD ?					; TRUE if suspended
	isdebugged				DWORD ?					; The thread is debugged
DEBUGTHREAD ends

; Holds important data while debugging
DEBUG struct
	hDbgThread				HANDLE ?				; Thread that runs the debugger
	pinfo					PROCESS_INFORMATION <>	; Process information
	hdbghand				HANDLE ?				; Handle to read / write process memory
	hdbgfile				HANDLE ?				; File handle
	prevline				DWORD ?					; Previous hilited line
	prevhwnd				DWORD ?					; Previous hilited line window handle
	lpthread				DWORD ?					; Pointer to current thread
	thread					DEBUGTHREAD 64 dup(<>)	; Threads
	context					CONTEXT <>				; Context
	prevcontext				CONTEXT <>				; Previous Context
	tmpcontext				CONTEXT <>				; Temp Context
	inxsource				DWORD ?					; Index to next free DEBUGSOURCE
	hMemSource				HGLOBAL ?				; Handle to memory containing DEBUGSOURCE structures
	inxtype					DWORD ?					; Index to next free DEBUGTYPE
	hMemType				HGLOBAL ?				; Handle to memory containing DEBUGTYPE structures
	inxsymbol				DWORD ?					; Index to next free DEBUGSYMBOL
	hMemSymbol				HGLOBAL ?				; Handle to memory containing DEBUGSYMBOL structures
	lpvar					DWORD ?					; Pointer to next free var
	hMemVar					HGLOBAL ?				; Variables definitions
	inxline					DWORD ?					; Index to next free DEBUGLINE
	hMemLine				HGLOBAL ?				; Handle to memory containing DEBUGLINE structures
	hMemNoBP				HGLOBAL ?				; Copy of code with no breakpoints
	hMemBP					HGLOBAL ?				; Copy of code with all breakpoints set
	minadr					DWORD ?					; Lowest address
	maxadr					DWORD ?					; Highest address
	lastadr					DWORD ?					; Address of last line
	lpProc					DWORD ?					; Current proc
	lpStepOver				DWORD ?					; Proc to return to
	func					DWORD ?					; Current debug function
	fHandled				DWORD ?					; Set to TRUE when a breakpoint is reached
	nErrors					DWORD ?					; Number of errors while parsing
	nNotFound				DWORD ?					; Numbers of symbols not found
	hWnd					DWORD ?					; Handle of debugged window
DEBUG ends

; Predefined datatypes
DATATYPE struct
	lpszType				DWORD ?					; The datatype
	lpszConvertType			DWORD ?					; The datatype it shoukd be converted to. DD, DW and DB is converted
	nSize					WORD ?					; Size in bytes
	fSigned					WORD ?					; TRUE if signed
DATATYPE ends

; Current variable. Used by tooltip and immediate
VAR struct
	szName					BYTE 256 dup(?)			; Variable name MyVar
	szArray					BYTE 256 dup(?)			; Array size and type [256]:BYTE
	nType					DWORD ?					; Proc=99
	nArray					DWORD ?					; Array size (1 based index)
	nSize					DWORD ?					; Size in bytes
	fPtr					DWORD ?					; Not used yet
	nOfs					DWORD ?					; Offset from ebp for local and parameter
	FileID					DWORD ?					; FileID for locals
	Address					DWORD ?					; Address
	nInx					DWORD ?					; Current index, used by immediate
	IsSZ					DWORD ?					; Show as ZString, used by immediate
	Value					DWORD ?					; Current value, used by immediate and tooltip
	szValue					BYTE 256 dup(?)			; Current ZString value, used by immediate
	lpFormat				DWORD ?					; Pointer to format string
	nFormat					DWORD ?					; Format flags
	nErr					DWORD ?					; Error
VAR ends

; Register. Used by tooltip and immediate
REG struct
	szName					BYTE 16 dup(?)			; Name of register
	nSize					DWORD ?					; Size in bytes
	nOfs					DWORD ?					; Offset into CONTEXT
REG ends

.const

;#########################################################################
; Text and predefined structures

; Registers
reg32							REG 10 dup(<'EAX',4,CONTEXT.regEax>,
										   <'EBX',4,CONTEXT.regEbx>,
										   <'ECX',4,CONTEXT.regEcx>,
										   <'EDX',4,CONTEXT.regEdx>,
										   <'ESI',4,CONTEXT.regEsi>,
										   <'EDI',4,CONTEXT.regEdi>,
										   <'EBP',4,CONTEXT.regEbp>,
										   <'ESP',4,CONTEXT.regEsp>,
										   <'EIP',4,CONTEXT.regEip>,
										   <'EFL',4,CONTEXT.regFlag>)
reg16							REG 4  dup(<'AX',2,CONTEXT.regEax>,
										   <'BX',2,CONTEXT.regEbx>,
										   <'CX',2,CONTEXT.regEcx>,
										   <'DX',2,CONTEXT.regEdx>)
reg8							REG 9  dup(<'AL',1,CONTEXT.regEax>,
										   <'AH',3,CONTEXT.regEax>,
										   <'BL',1,CONTEXT.regEbx>,
										   <'BH',3,CONTEXT.regEbx>,
										   <'CL',1,CONTEXT.regEcx>,
										   <'CH',3,CONTEXT.regEcx>,
										   <'DL',1,CONTEXT.regEdx>,
										   <'DH',3,CONTEXT.regEdx>,
										   <,0,0>)

; Predefined datatypes
szBYTE							db 'BYTE',0
szSBYTE							db 'SBYTE',0
szDB							db 'DB',0
szWORD							db 'WORD',0
szSWORD							db 'SWORD',0
szDW							db 'DW',0
szDWORD							db 'DWORD',0
szSDWORD						db 'SDWORD',0
szDD							db 'DD',0
szQWORD							db 'QWORD',0
szDQ							db 'DQ',0
szREAL4							db 'REAL4',0
szREAL8							db 'REAL8',0
szTBYTE							db 'TBYTE',0
szDT							db 'DT',0
								db 0

datatype						DATATYPE 1 dup (<szBYTE,szBYTE,1,0>,
												<szSBYTE,szSBYTE,1,1>,
												<szDB,szBYTE,1,0>,
												<szWORD,szWORD,2,0>,
												<szSWORD,szSWORD,2,1>,
												<szDW,szWORD,2,0>,
												<szDWORD,szDWORD,4,0>,
												<szSDWORD,szSDWORD,4,1>,
												<szDD,szDWORD,4,0>)
datatype2						DATATYPE 1	dup(<szQWORD,szQWORD,8,0>,
												<szDQ,szQWORD,8,0>,
												<szREAL4,szREAL4,4,0>,
												<szREAL8,szREAL8,8,0>,
												<szTBYTE,szTBYTE,10,0>,
												<szDT,szTBYTE,10,0>,
												<0,0,0,0>)

; The dbghelp dll
DbgHelpDLL						db 'DbgHelp.dll',0

; Int3
szBP							db 0CCh

; Debug events
szEXCEPTION_DEBUG_EVENT			db 'EXCEPTION_DEBUG_EVENT',0
szEXCEPTION_BREAKPOINT			db 'EXCEPTION_BREAKPOINT',0
szEXCEPTION_ACCESS_VIOLATION	db 'EXCEPTION_ACCESS_VIOLATION Address: %08Xh ThreadID: %d',0
szEXCEPTION_FLT_DIVIDE_BY_ZERO	db 'EXCEPTION_FLT_DIVIDE_BY_ZERO Address: %08Xh ThreadID: %d',0
szEXCEPTION_INT_DIVIDE_BY_ZERO	db 'EXCEPTION_INT_DIVIDE_BY_ZERO Address: %08Xh ThreadID: %d',0
szEXCEPTION_DATATYPE_MISALIGNMENT	db 'EXCEPTION_DATATYPE_MISALIGNMENT Address: %08Xh ThreadID: %d',0
szEXCEPTION_SINGLE_STEP			db 'EXCEPTION_SINGLE_STEP',0
szDBG_CONTROL_C					db 'DBG_CONTROL_C',0

szCREATE_PROCESS_DEBUG_EVENT	db 'CREATE_PROCESS_DEBUG_EVENT ProcessID: %d ThreadID: %d',0
szEXIT_PROCESS_DEBUG_EVENT		db 'EXIT_PROCESS_DEBUG_EVENT ProcessID: %d ThreadID: %d Exit code: %d',0
szCREATE_THREAD_DEBUG_EVENT		db 'CREATE_THREAD_DEBUG_EVENT ThreadID: %d',0
szEXIT_THREAD_DEBUG_EVENT		db 'EXIT_THREAD_DEBUG_EVENT ThreadID: %d Exit code: %d',0
szLOAD_DLL_DEBUG_EVENT			db 'LOAD_DLL_DEBUG_EVENT %s',0
szUNLOAD_DLL_DEBUG_EVENT		db 'UNLOAD_DLL_DEBUG_EVENT %s',0
szOUTPUT_DEBUG_STRING_EVENT		db 'OUTPUT_DEBUG_STRING_EVENT %s',0
szRIP_EVENT						db 'RIP_EVENT',0

; Some useful text constants
szCR							db 0Dh,0
szNULL							db 0
szSpace							db ' ',0
szComma							db ',',0
szColon							db ':',0
szImmPrompt						db '>',0

; Debug startup texts
szDebug							db 'Debug',0
szDebuggingStarted				db '** Debugging started: %s',0
szDebugStopped					db '** Debugging ended: %s',0
szUnhanfledBreakpoints			db 'There are %u unhandled breakpoint(s).',0
szUnsavedFiles					db 'There are %u unsaved file(s).',0
szNewerFiles					db '%u source files are newer than the exe.',0
szExeNotFound					db 'Could not open: %s.',0
szNoDebugInfo					db 'No debug info found. Use the /Zd, /Zi and /DEBUG command line options.',0

; Tooltip / immediate window formatting
szReg32							db 'REGISTER %s Hex %08Xh Dec %u',0
szReg16							db 'REGISTER %s Hex %04Xh Dec %u',0
szReg8							db 'REGISTER %s Hex %02Xh Dec %u',0
szProc							db 'PROC %s Size %u',0
szData							db 'GLOBAL %s%s Address %08Xh Size %u',0
szData32						db 'GLOBAL %s%s Address %08Xh Size %u Hex %08Xh Dec %d',0
szData16						db 'GLOBAL %s%s Address %08Xh Size %u Hex %04Xh Dec %d',0
szData8							db 'GLOBAL %s%s Address %08Xh Size %u Hex %02Xh Dec %d',0
szDataSZ						db 'GLOBAL %s%s Address %08Xh Size %u ZString "%s"',0
szDataS							db 'GLOBAL %s%s Address %08Xh Size %u String "%s"',0
szParam							db 'PARAM %s%s Address %08Xh Size %u',0
szParam32						db 'PARAM %s%s Address %08Xh Size %u Hex %08Xh Dec %d',0
szParam16						db 'PARAM %s%s Address %08Xh Size %u Hex %04Xh Dec %d',0
szParam8						db 'PARAM %s%s Address %08Xh Size %u Hex %02Xh Dec %d',0
szLocal							db 'LOCAL %s%s Address %08Xh Size %u',0
szLocal32						db 'LOCAL %s%s Address %08Xh Size %u Hex %08Xh Dec %d',0
szLocal16						db 'LOCAL %s%s Address %08Xh Size %u Hex %04Xh Dec %d',0
szLocal8						db 'LOCAL %s%s Address %08Xh Size %u Hex %02Xh Dec %d',0
szLocalSZ						db 'LOCAL %s%s Address %08Xh Size %u ZString "%s"',0
szLocalS						db 'LOCAL %s%s Address %08Xh Size %u String "%s"',0
szValue							db 'Hex %08Xh Dec %d',0
szConst							db 'CONST %s Hex %08Xh Dec %d',0
szTypeSize						db 'TYPESIZE %s Hex %08Xh Dec %d',0

szType							db 'Type: %s Size: %u',0
szLine							db 'File: %s Line: %u Address: %08Xh',0

; Immesdiate window errors
szErrSyntaxError				db 'Syntax error: %s',0
szErrVariableNotFound			db 'Variable not found: %s',0
szErrIndexOutOfRange			db 'Index out of range: %s',0
szErrDiv0						db 'Division by zero.',0
szErrOverflow					db 'Overflow.',0

szErrUnknownCommand				db 'Unknown command.',0
szOnlyInDebugMode				db 'Only in debug mode.',0

szErrConstant					db 'Could not evaluate expression: %s',0
szErrArray						db 'Could not evaluate array size: %s',0
szErrType						db 'Could not find datatype: %s',0
szErrorParsing					db 'WARNING! There was %d error(s) while parsing. Variables, parameters and locals are disabled.',0
szNotCodeLine					db 'Not a code line.',0

; Ansi / Widechar
szA								db 'A',0
szW								db 'W',0
szPrppdl						db 'pdl',0
szPrpTWc						db 'TWc',0
szPrpp							db 'p',0

;#########################################################################
; Globals

.data?

hDbgHelpDLL						HMODULE ?						; Handle of DbgHelp.dll
hWnd							HWND ?							; Handle of main window
hOut							HWND ?							; Handle of output window
hImmOut							HWND ?							; Handle of immediate window
hDbgReg							HWND ?							; Handle of debug register window
hDbgFpu							HWND ?							; Handle of debug FPU window
hDbgMMX							HWND ?							; Handle of debug MMX window
hDbgWatch						HWND ?							; Handle of debug watch window
hPrp							HWND ?							; Handle of properties window
lpCallBack						dd ?
szExeName						db MAX_PATH dup(?)				; Path to exe to be debugged

szBPSourceName					db MAX_PATH*64 dup(?)			; Path to a source files with breakpoints
breakpoint						BREAKPOINT 512 dup(<>)			; Breakpoints

dbg								DEBUG <>						; Holds info while debugging
var								VAR <>							; Current variable info
fNoDebugInfo					dd ?							; No debug info found
outbuffer						db 1024 dup(?)					; Buffer for wsprintf
szWatchList						db 512 dup(?)					; List of variables to watch
szWatchResult					db 2048 dup(?)
mFunc							dd ?
nError							dd ?
szError							db 256 dup(?)
lpNoDebug						dd ?
fMainThread						dd ?
fDoneOpen						dd ?
fProject						dd ?
