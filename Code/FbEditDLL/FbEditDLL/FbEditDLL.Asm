.386
.model flat,stdcall
option casemap:none
option proc:private

include FbEditDLL.inc

.code

DllEntry proc public hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	.if reason==DLL_PROCESS_ATTACH
		invoke InstallRACodeComplete,hInst,TRUE
		invoke InstallFileBrowser,hInst,TRUE
		invoke InstallRAProperty,hInst,TRUE
		invoke GridInstall,hInst,TRUE
		invoke RAHexEdInstall,hInst,TRUE
		invoke InstallRAEdit,hInst,TRUE
		invoke ResEdInstall,hInst,TRUE
	.elseif reason==DLL_PROCESS_DETACH
		invoke UnInstallRACodeComplete
		invoke UnInstallFileBrowser
		invoke UnInstallRAProperty
		invoke GridUnInstall
		invoke RAHexEdUnInstall
		invoke UnInstallRAEdit
		invoke ResEdUninstall
	.endif
	mov     eax,TRUE
	ret

DllEntry endp

End DllEntry
