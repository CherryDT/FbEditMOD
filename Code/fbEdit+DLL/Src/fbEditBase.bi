#Include Once "windows.bi"

Declare Sub InstallFBCodeComplete Alias "InstallFBCodeComplete" (hInst As HINSTANCE, fGlobal As Integer)
Declare Sub UnInstallFBCodeComplete Alias "UnInstallFBCodeComplete" ()
Declare Sub InstallFileBrowser Alias "InstallFileBrowser" (hInst As HINSTANCE, fGlobal As Integer)
Declare Sub UnInstallFileBrowser Alias "UnInstallFileBrowser" ()
Declare Sub InstallRAProperty Alias "InstallRAProperty" (hInst As HINSTANCE, fGlobal As Integer)
Declare Sub UnInstallRAProperty Alias "UnInstallRAProperty" ()
Declare Sub GridInstall Alias "GridInstall" (hInst As HINSTANCE, fGlobal As Integer)
Declare Sub GridUnInstall Alias "GridUnInstall" ()
Declare Sub RAHexEdInstall Cdecl Alias "RAHexEdInstall" (hInst As HINSTANCE, fGlobal As Integer)
Declare Sub RAHexEdUnInstall Alias "RAHexEdUnInstall" ()
Declare Sub InstallRAEdit Alias "InstallRAEdit" (hInst As HINSTANCE, fGlobal As Integer)
Declare Sub UnInstallRAEdit Alias "UnInstallRAEdit" ()
Declare Sub ResEdInstall Alias "ResEdInstall" (hInst As HINSTANCE, fGlobal As Integer)
Declare Sub ResEdUninstall Alias "ResEdUninstall" ()


'#Inclib "..\Lib\RACodeComplete.lib"
'#Inclib "..\Lib\RAFile.lib"
'#Inclib "..\Lib\RAProperty.lib"
'#Inclib "..\Lib\RAGrid.lib"
'#Inclib "..\Lib\RAHexEd.lib"
'#Inclib "..\Lib\RAEdit.lib"
'#Inclib "..\Lib\RAResEd.lib"

