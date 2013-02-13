
InstallRACodeComplete		PROTO :DWORD,:DWORD
UnInstallRACodeComplete		PROTO
InstallFileBrowser			PROTO :DWORD,:DWORD
UnInstallFileBrowser		PROTO
InstallRAProperty			PROTO :DWORD,:DWORD
UnInstallRAProperty			PROTO
GridInstall					PROTO :DWORD,:DWORD
GridUnInstall				PROTO
RAHexEdInstall				PROTO C :DWORD,:DWORD
RAHexEdUnInstall			PROTO
InstallRAEdit				PROTO :DWORD,:DWORD
UnInstallRAEdit				PROTO
ResEdInstall				PROTO :DWORD,:DWORD
ResEdUninstall				PROTO

include windows.inc
include Comctl32.inc
include user32.inc
include kernel32.inc
include gdi32.inc

includelib comctl32.lib
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

;includelib ..\Lib\RACodeComplete.lib
;includelib ..\Lib\RAFile.lib
;includelib ..\Lib\RAProperty.lib
;includelib ..\Lib\RAGrid.lib
;includelib ..\Lib\RAHexEd.lib
;includelib ..\Lib\RAEdit.lib
;includelib ..\Lib\RAResEd.lib
includelib ..\..\RACodeComplete\Lib\RACodeComplete.lib
includelib ..\..\RAFile\Lib\RAFile.lib
includelib ..\..\RAGrid\Lib\RAGrid.lib
includelib ..\..\RAHexEd\Lib\RAHexEd.lib
includelib ..\..\RAProperty\Lib\RAProperty.lib
includelib ..\..\RAResEd\Lib\RAResEd.lib
includelib ..\..\RAEdit\Lib\RAEdit.lib
includelib ..\..\RADebug\Lib\Debug.lib

;VKim Debug
include masm32.inc
include \RadASM\Masm\Inc\Debug.inc
includelib masm32.lib
;includelib \RadASM\Masm\Lib\Debug.lib

