
include		windows.inc
include		kernel32.inc
include		user32.inc
include		Comctl32.inc
include		shell32.inc
include		shlwapi.inc
include		version.inc

includelib	kernel32.lib
includelib	user32.lib
includelib	Comctl32.lib
includelib	shell32.lib
includelib	shlwapi.lib
includelib	version.lib

include		masm32.inc
include		Debug.Inc
includelib	masm32.lib
includelib	Debug.lib

.const

IDD_MAIN				equ 101
IDC_RBNUPRA				equ 103
IDC_RBNOWRA				equ 104
IDC_RBNUPLANG			equ 105
IDC_RBNOWLANG			equ 106
IDC_CHKOWTEMPLATES		equ 102
IDC_CHKOWSNIPLETS		equ 108
IDC_EDTLOG				equ 107

;#########################################################################
.const

szMdiClassName			BYTE 'RadASM30Class',0
szAppName				BYTE 'RadASM Update',0
szNULL					BYTE 0
;Errors
szErrVersion			BYTE 'The version of UpdateRadASM.exe',0Dh,0Ah,'does not match the version of the new RadASM.exe.',0
szErrStillRunning		BYTE 'An instance of RadASM is still running.',0Dh,0Ah,'Close all instances of RadASM before proceeding.',0
szErrNotFound			BYTE 'Could not find:',0Dh,0Ah,0
;Files
szRadASMExe				BYTE 'RadASM.exe',0
szUpdateRadASMExe		BYTE 'UpdateRadASM.exe',0
szRadASMIni				BYTE 'RadASM.ini',0
szAllFiles				BYTE '*.*',0
szAllIni				BYTE '*.ini',0
szAllTpl				BYTE '*.tpl',0
;Paths
szBS					BYTE '\',0
szAddins				BYTE 'Addins',0
szTemplates				BYTE 'Templates',0
szSniplets				BYTE 'Sniplets',0
szHelp					BYTE 'Help',0
;Versions
szVarTrans				BYTE '\VarFileInfo\Translation',0
szFileVersion			BYTE 'FileVersion',0
szFileStringFormat		BYTE '\StringFileInfo\%04x%04x\%s',0
szVersionFormat			BYTE 'Updater version: %s',0Dh,0Ah,'Your version: %s',0Dh,0Ah,'New version: %s',0Dh,0Ah,0
;Ini files
szIniVersion			BYTE 'Version',0
szIniDescription		BYTE 'Description',0
szIniParse				BYTE 'Parse',0
szIniAssembler			BYTE 'Assembler',0
szIniDebug				BYTE 'Debug',0
szIniHelp				BYTE 'Help',0
szIniProjectZip			BYTE 'ProjectZip',0
;Format
szDecFormat				BYTE '%d',0
;Update
szRadASMHelp			BYTE 'RadASM,$A\Help\RadASM.chm',0

.data?

hInstance				HINSTANCE ?
szAppPath				BYTE MAX_PATH dup(?)
szRadASMPath			BYTE MAX_PATH dup(?)
szTmpBuff				BYTE 1024 dup(?)

;#########################################################################
