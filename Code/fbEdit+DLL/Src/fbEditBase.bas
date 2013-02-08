#Include "fbEditBase.bi"
#Include "windows.bi"

'Declare Sub fb_hRtInit Cdecl Alias "fb_hRtInit" ()
Declare function DllMainCRTStartup Cdecl Alias "DllMainCRTStartup" (ByVal hInst As HINSTANCE, ByVal fdwReason As DWORD, Byval lpvReserved As LPVOID) As DWORD


Public Function Main(ByVal hInst As HINSTANCE, ByVal fdwReason As DWORD, Byval lpvReserved As LPVOID) As DWORD
	Select Case fdwReason
		
		Case DLL_PROCESS_ATTACH
			'fb_hRtInit()
			DllMainCRTStartup(hInst, fdwReason, lpvReserved)
			'Print "DLL_PROCESS_ATTACH"
			'Print hInst
			'Print GetModuleHandle(@"fbEditBase.dll")
			'Print GetModuleHandle(0)
			InstallFBCodeComplete(hInst,TRUE)
			InstallFileBrowser(hInst,TRUE)
			InstallRAProperty(hInst,TRUE)
			GridInstall(hInst,TRUE)
			RAHexEdInstall(hInst,TRUE)
			InstallRAEdit(hInst,TRUE)
			ResEdInstall(hInst,TRUE)
		
		Case DLL_PROCESS_DETACH
			'Print "DLL_PROCESS_DETACH"
			UnInstallFBCodeComplete()
			UnInstallFileBrowser()
			UnInstallRAProperty()
			GridUnInstall()
			RAHexEdUnInstall()
			UnInstallRAEdit()
			ResEdUninstall()
			
		case DLL_THREAD_ATTACH
		case DLL_THREAD_DETACH
			
	End Select
	
	Return TRUE
End Function



/'

Sub ctor() Constructor
	Dim hInst As HINSTANCE = GetModuleHandle(0)
	InstallRACodeComplete(hInst,TRUE)
	InstallFileBrowser(hInst,TRUE)
	InstallRAProperty(hInst,TRUE)
	GridInstall(hInst,TRUE)
	RAHexEdInstall(hInst,TRUE)
	InstallRAEdit(hInst,TRUE)
	ResEdInstall(hInst,TRUE)
End Sub

Sub dtor() Destructor
	UnInstallRACodeComplete()
	UnInstallFileBrowser()
	UnInstallRAProperty()
	GridUnInstall()
	RAHexEdUnInstall()
	UnInstallRAEdit()
	ResEdUninstall()
End Sub
'/