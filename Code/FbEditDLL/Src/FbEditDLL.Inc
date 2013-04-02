
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

includelib ..\RACodeComplete\Build\RACodeComplete.lib
includelib ..\RAFile\Build\RAFile.lib
includelib ..\RAGrid\Build\RAGrid.lib
includelib ..\RAHexEd\Build\RAHexEd.lib
includelib ..\RAProperty\Build\RAProperty.lib
includelib ..\RAResEd\Build\RAResEd.lib
includelib ..\RAEdit\Build\RAEdit.lib
;includelib ..\RADebug\Build\RADebug.lib


