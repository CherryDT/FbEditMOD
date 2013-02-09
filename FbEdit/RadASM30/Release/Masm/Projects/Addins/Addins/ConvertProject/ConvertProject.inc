
;#########################################################################
;Include files

include windows.inc
include kernel32.inc
include user32.inc
include Gdi32.inc

;#########################################################################
;Libraries

includelib kernel32.lib
includelib user32.lib
includelib Gdi32.lib
include comdlg32.inc

;#########################################################################
;VKim's Debug

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib
includelib comdlg32.lib

;#########################################################################
;RadASM AddIn Include

include ..\Addins.inc

IDD_DLGCONVERT          equ 1000
IDC_EDTPROJECT          equ 1001
IDC_BTNPROJECT          equ 1002
IDC_EDTFILES            equ 1003

.const

szCR					db VK_RETURN,0
szBS					db '\',0
szDot					db '.',0
szNULL					db 0
szMenuConvert			db 'Convert project',0
szFileFilter			db 'Project file (*.rap)',0,'*.rap',0,0
szprra					db '.prra',0
szIni					db '.ini',0
szCRLF					db 0Dh,0Ah,0
szFile					db 'File: ',0
szModule				db 'Module: ',0
szNotFound				db ' Not Found!',0
szInclude				db '#include',0
szDone					db 0Dh,0Ah,'Project converted!',0Dh,0Ah,0

szIniProject			db 'Project',0
szIniCode				db 'Code',0
szIniHeader				db 'Header',0
szIniFile				db 'File',0
szIniHex				db 'Hex',0
szIniAssembler			db 'Assembler',0
szIniDescription		db 'Description',0
szIniFiles				db 'Files',0
szIniVersion			db 'Version',0
szIni3000				db '3000',0
szIniPath				db 'Path',0
szIniGroup				db 'Group',0
szIniMake				db 'Make',0

szFmtDec				db '%d',0
szFmtGroup				db '2,-1,0,1,%s,-2,-1,1,Assembly,-3,-1,1,Include,-4,-1,1,Misc,-5,-1,1,Resource',0
szFmtFile				db '%d,%d,%d,22,22,600,400,0,%s',0

szErrLanguage			db 'The language %s cannot be found.',0

szrcfile				db '.rc.',0
szdlgmnufile			db '.dlg.mnu.',0

.data?

hInstance				dd ?					;Dll's module handle
lpHandles				dd ?					;Pointer to handles struct
lpProc					dd ?					;Pointer to proc struct
lpData					dd ?					;Pointer to data struct
IDAddin					dd ?					;Menu ID
hook					HOOK <>
project2x				db MAX_PATH dup(?)
project3x				db MAX_PATH dup(?)
mainasm					db MAX_PATH dup(?)
mainrc					db MAX_PATH dup(?)
assemblerini			db MAX_PATH dup(?)
szcodefile				db MAX_PATH dup(?)
szheaderfile			db MAX_PATH dup(?)
szhexfile				db MAX_PATH dup(?)

.code

;#########################################################################
;Output Window procs

TextOutput proc lpszStr

   pushad
   push  lpszStr
   mov   eax,lpProc
   call  [eax].ADDINPROCS.lpTextOutput
   push  offset szCR
   mov   eax,lpProc
   call  [eax].ADDINPROCS.lpTextOutput
   popad
   ret

TextOutput endp
