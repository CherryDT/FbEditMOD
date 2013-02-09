include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
include gdi32.inc
include shlwapi.inc
include RAEdit.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib gdi32.lib
includelib shlwapi.lib
includelib RAEdit.lib

;#########################################################################
;VKim's Debug

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

WriteCom				PROTO	:DWORD

IDD_DIALOG              equ 1000
IDC_SCREEN              equ 1001
IDC_SBR1                equ 1002
IDC_TBR1                equ 1003
IDC_RAE1				equ 1004
IDC_RAE2				equ 1005

IDD_DLGCOMPORT          equ 1400
IDC_CHKCOMACTIVE        equ 1401
IDC_EDTCOMPORT          equ 1402
IDC_CBOCOMBAUD          equ 1404
IDC_CBOCOMBITS          equ 1405
IDC_CBOCOMSTOP          equ 1407
IDC_CHKCOMPARITY        equ 1403

IDA_ACCEL1				equ 1

IDM_MENU                equ 10000
IDM_FILE_INITCOM        equ 10002
IDM_FILE_EXIT           equ 10001
IDM_OPTION_COMPORT      equ 10007
IDM_OPTION_HELP			equ 10005

IDM_FILE_OPEN           equ 10003
IDM_FILE_SAVE           equ 10004
IDM_FILE_UPLOAD         equ 10020
IDM_FILE_GO             equ 10006
IDM_FILE_DEBUG			equ 10010
IDM_FILE_REFRESH        equ 10021
IDM_DEBUG_RUN			equ 10022
IDM_DEBUG_STOP			equ 10023
IDM_DEBUG_INTO			equ 10024
IDM_DEBUG_OVER			equ 10025
IDM_DEBUG_CARET			equ 10026
IDM_DEBUG_SETDPTR		equ 10101
IDM_DEBUG_DUMPDPTR		equ 10102
IDM_DEBUG_DUMPINTERNAL	equ 10103
IDC_DEBUG_DUMPSFR		equ 10104
IDM_HELPF1				equ 10200

IDM_HELP				equ 11000
IDM_HELP_START			equ 11001

IDB_TOOLBAR				equ 100

COM struct
	active		DWORD ?								;Communication with MCU is active if TRUE
	szcom		BYTE 16 dup(?)						;Com port (COM1, COM2 ...)
	nbaud		DWORD ?								;Baudrate (4800 to 38400)
	nbits		DWORD ?								;Data bits (7 or 8)
	nparity		DWORD ?								;Parity bit (False/True)
	nstop		DWORD ?								;Stop bits (0 or 1)
COM ends

.const

ClassName				db 'DLGCLASS',0
szCOM					db 'COM1',0
szComFailed				db 'Opening com port failed.',0Dh,'Retry?',0
szDefCmdData			db 'CMDDATA.CMD',0
szDefLstData			db 'CMDDATA.LST',0
szDefRomData			db 'ROMDATA.HEX',0
szNULL					db 0
szHelpMenu				db 'HelpMenu',0
szOpen					db 'Open',0
szDollarA				db '$A',0
szhhctrl				db 'hhctrl.ocx',0
szHtmlHelpA				db 'HtmlHelpA',0

tbrbtns				TBBUTTON <0,IDM_FILE_OPEN,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <1,IDM_FILE_SAVE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <2,IDM_FILE_UPLOAD,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <3,IDM_FILE_GO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <4,IDM_FILE_DEBUG,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <5,IDM_FILE_REFRESH,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <6,IDM_DEBUG_RUN,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <7,IDM_DEBUG_STOP,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <8,IDM_DEBUG_INTO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <9,IDM_DEBUG_OVER,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <10,IDM_DEBUG_CARET,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <11,IDM_DEBUG_SETDPTR,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <12,IDM_DEBUG_DUMPDPTR,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <13,IDM_DEBUG_DUMPINTERNAL,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <14,IDC_DEBUG_DUMPSFR,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
ntbrbtns			equ 20


szANYString				db 'All Files (*.*)',0,'*.*',0,0
szIniFile				db '\Emu8051.ini',0

szIniCom				db 'Com',0

Courier_New_12 			LOGFONT <-16,0,0,0,400,0,0,0,0,3,2,1,49,"Courier New">
Courier_New_10 			LOGFONT <-12,0,0,0,400,0,0,0,0,3,2,1,49,"Courier New">

;Registers
C0						db 'A B DPH DPL DPTR PSW R0 R1 R2 R3 R4 R5 R6 R7 SP PC',0
;Instructions
C1						db 'ACALL ADD ADDC AJMP ANL CJNE CLR CPL DA DEC DIV DJNZ INC JB JBC JC JMP JNB JNC JNZ JZ LCALL LJMP MOV MOVC MOVX MUL NOP ORL POP PUSH RET RETI RL RLC RR RRC SETB SJMP SUBB SWAP XCH XCHD XRL',0
;SFR
C2						db 'ACC IE IP P0 P1 P2 P3 PCON SBUF SCON TCON TH0 TH1 TL0 TL1 TMOD',0
;Adressing mode
C3						db '@A @DPTR @R0 @R1',0
;Bit
C4						db '.0 .1 .2 .3 .4 .5 .6 .7 C',0
;Special reserved words
C5						db 'BYTE DB DW EQU ORG WORD',0

.data?

hInstance				HINSTANCE ?
CommandLine				DWORD ?
hWnd					HWND ?
hScrn					HWND ?
hREd					HWND ?
hDbg					HWND ?
hMenu					HMENU ?
hAccel					HACCEL ?
hImlTbr					HIMAGELIST ?
hFont					HFONT ?
hDbgFont				HFONT ?
dcb						DCB <>
hCom					HANDLE ?
to						COMMTIMEOUTS <>
lpOldScreenProc			DWORD ?
szapppath				BYTE MAX_PATH dup(?)
szinifile				BYTE MAX_PATH dup(?)
szcmdfilename			BYTE MAX_PATH dup(?)
szromfilename			BYTE MAX_PATH dup(?)
szlstfilename			BYTE MAX_PATH dup(?)
fExit					DWORD ?
fprogrom				DWORD ?
fblockmode				DWORD ?
hrdfile					HANDLE ?
hrdblock				HANDLE ?
hwrfile					HANDLE ?
hHtmlOcx				HANDLE ?
pHtmlHelpProc			DWORD ?
comopt					COM <>
fDebug					DWORD ?
SingleStepLine			DWORD ?
lpOldRAEditProc			DWORD ?

rdhead					DWORD ?
rdtail					DWORD ?
rdbuff					BYTE 16*1024 dup(?)
wrhead					DWORD ?
wrtail					DWORD ?
wrbuff					BYTE 16*1024 dup(?)
tid						DWORD ?
