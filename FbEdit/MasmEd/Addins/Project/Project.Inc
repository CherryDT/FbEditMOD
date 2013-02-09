
;#########################################################################
;Include files

include windows.inc
include kernel32.inc
include user32.inc
include comdlg32.inc
include advapi32.inc
include shell32.inc

;#########################################################################
;Libraries

includelib kernel32.lib
includelib user32.lib
includelib comdlg32.lib
includelib advapi32.lib
includelib shell32.lib

;#########################################################################
;	MasmEd Addin Include

include ..\Addins.inc

;#########################################################################
;		VKim's Debug

include masm32.inc
include debug.inc
includelib debug.lib

OutputString		PROTO	:DWORD

FBM_SETPATH			equ WM_USER+1	;wParam=FALSE/TRUE(Refresh), lParam=Pointer to path string

.const

szMenuItem			db 'Project',0
szCreateProject		db 'Create New Project',0
szCreateTemplate	db 'Create Template',0
szTemplateOptions	db 'Options',0
szSniplets			db 'Sniplets',VK_TAB,'F11',0
szFiles				db 'Files',0
szTemplate			db 'Template',0
szProjectsPath		db '\Projects',0
szTemplatesPath		db '\Templates',0
szSnipletsPath		db '\Sniplets',0
szBakPath			db 'Bak',0
szResPath			db 'Res',0
szModPath			db 'Mod',0
szIncPath			db 'Inc',0
szNone				db '(None)',0
szTpl				db '\*.tpl',0
szAPA				db '*.*',0
szBak				db '\Bak\',0
szBS				db '\',0
szDot				db '.',0
szAsmFile			db 'asm',0
szIncFile			db 'inc',0
szRcFile			db 'rc',0
szTxtFile			db 'txt',0
szMesFile			db 'mes',0
szSession			db 'Session',0
szMinorFiles		db 'MinorFiles',0
szNULL				db 0
szBrowse			db 'Browse Project Folder:',0

;Registry
szBackups			db 'Backups',0
szTextFiles			db 'TextFiles',0
szBinaryFiles		db 'BinaryFiles',0

;Errors
szErrDir			db 'Could not create directory!',0Dh,0
szErrOpenDir		db 'Could not open directory!',0Dh,0
szErrOverwrite		db 'Overwrite existing file?',0Dh,0
szErrCreate			db 'Could not create the file!',0Dh,0

;Template
szMAKE				db '[*MAKE*]=',0
szPROJECTNAME		db '[*PROJECTNAME*]',0
szBEGINTXT			db '[*BEGINTXT*]',0
szENDTXT			db '[*ENDTXT*]',0
szBEGINBIN			db '[*BEGINBIN*]',0
szENDBIN			db '[*ENDBIN*]',0

.data?

hInstance			HMODULE ?		;Dll's module handle
lpHandles			DWORD ?			;Pointer to handles struct
lpProc				DWORD ?			;Pointer to proc struct
lpData				DWORD ?			;Pointer to data struct
MenuIDAddin			DWORD 5 dup(?)	;5 MenuID's allocated for this addin
hSubMenu			DWORD ?			;The addins Project sub menu
hook				HOOK <>
nBackup				DWORD ?
ProjectPath			BYTE MAX_PATH dup(?)
TemplatePath		BYTE MAX_PATH dup(?)
SnipletPath			BYTE MAX_PATH dup(?)
tempbuff			BYTE 16384 dup(?)
hDlg1				HWND ?
hDlg2				HWND ?
fDeleteMinor		DWORD ?
wfd					WIN32_FIND_DATA <?>
pidl				dd ?
bri					BROWSEINFO <?>
