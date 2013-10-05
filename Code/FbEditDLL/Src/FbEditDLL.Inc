
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

includelib ..\CustomControl\RACodeComplete\Build\RACodeComplete.lib
includelib ..\CustomControl\RAFile\Build\RAFile.lib
includelib ..\CustomControl\RAGrid\Build\RAGrid.lib
includelib ..\CustomControl\RAHexEd\Build\RAHexEd.lib
includelib ..\CustomControl\RAProperty\Build\RAProperty.lib
includelib ..\CustomControl\RAResEd\Build\RAResEd.lib
includelib ..\CustomControl\RAEdit\Build\RAEdit.lib
;includelib ..\CustomControl\RADebug\Build\RADebug.lib
