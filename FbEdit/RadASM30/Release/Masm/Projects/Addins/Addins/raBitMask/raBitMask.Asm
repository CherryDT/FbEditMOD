;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

;include raBitMask.inc
include BitMask.asm
include raBitMask.inc

.code

OutputString proc uses ebx,lpString:DWORD

	mov		ebx,lpProc
	push	0
	call	[ebx].ADDINPROCS.lpSetOutputTab
	push	TRUE
	call	[ebx].ADDINPROCS.lpShowOutput
	push	lpString
	call	[ebx].ADDINPROCS.lpTextOutput
	ret

OutputString endp

UpdateMenu proc hMnu:HMENU
	LOCAL	mii:MENUITEMINFO

	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_SUBMENU
	mov		edx,lpHandles
	invoke GetMenuItemInfo,[edx].ADDINHANDLES.hMenu,IDM_TOOLS,FALSE,addr mii
	invoke AppendMenu,mii.hSubMenu,MF_STRING,IDAddIn,offset szMenuName
	ret

UpdateMenu endp

;#########################################################################
;		Common AddIn Procedures
DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
	mov eax, hInst
	mov hInstance, eax
	mov eax, TRUE
	ret
DllEntry Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallAddin proc uses ebx hWin:DWORD

	mov	ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov	lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov	lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov	lpData,eax
	; Allocate a new menu id
	invoke SendMessage,ebx,AIM_GETMENUID,0,0
	mov IDAddIn,eax
	; Messages to hook into
	mov	hook.hook1, HOOK_COMMAND OR  HOOK_MENUUPDATE
	xor eax,eax
	mov	hook.hook2,eax
	mov	hook.hook3,eax
	mov	hook.hook4,eax
	mov eax,offset hook

	ret

InstallAddin Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
AddinProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from

	mov	eax, uMsg
	.if eax == AIM_COMMAND
		mov eax,wParam
		movzx edx,ax
		shr eax, 16
		.if edx == IDAddIn && eax == BN_CLICKED
			mov eax,lpHandles
			mov eax,[eax].ADDINHANDLES.hWnd
			invoke DialogBoxParam,hInstance,IDD_DLG,eax,addr DialogProc,NULL
			mov eax,TRUE
			ret
		.endif
	.elseif eax==AIM_MENUUPDATE
		invoke UpdateMenu,wParam
	.endif
	mov eax,FALSE
	ret
AddinProc Endp

;#########################################################################

End DllEntry
