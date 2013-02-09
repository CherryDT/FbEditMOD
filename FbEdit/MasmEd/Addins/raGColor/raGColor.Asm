;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include raGColor.inc
include GColor.asm

.code

;#########################################################################
;		Common AddIn Procedures


AddMenuItem proc hMnu:HMENU,nID:DWORD,lpszMenuItem:DWORD

	invoke AppendMenu,hMnu,MF_STRING,nID,lpszMenuItem
	ret

AddMenuItem endp

UpdateMenu proc hMnu:HMENU
	LOCAL	mii:MENUITEMINFO

	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_SUBMENU
	mov		edx,lpHandles
	invoke GetMenuItemInfo,[edx].ADDINHANDLES.hMnu,IDM_TOOLS,FALSE,addr mii
	invoke AddMenuItem,mii.hSubMenu,IDAddIn,offset szGColorMenu
	ret

UpdateMenu endp

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
	mov eax, hInst
	mov hInstance, eax
	mov eax, TRUE
	ret
DllEntry Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallAddin proc uses ebx hWin:DWORD, fOpt:DWORD

	;Get pointer to handles struct
	invoke SendMessage,hWin,AIM_GETHANDLES,0,0;	
	mov	lpHandles,eax

	;Get pointer to proc struct
	invoke SendMessage,hWin,AIM_GETPROCS,0,0
	mov	lpProc,eax

	;Get pointer to data struct
	invoke SendMessage,hWin,AIM_GETDATA,0,0	
	mov	lpData,eax

	invoke SendMessage,hWin,AIM_GETMENUID,0,0
	mov IDAddIn,eax
	; Messages to hook into
	mov		hook.hook1,HOOK_COMMAND or HOOK_MENUUPDATE
	xor		eax,eax
	mov		hook.hook2,eax
	mov		hook.hook3,eax
	mov		hook.hook4,eax
	mov		eax,offset hook
	ret 

InstallAddin Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
AddinProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from

LOCAL mii	:MENUITEMINFO

	mov	eax, uMsg
	.if eax == AIM_COMMAND
		mov eax,wParam
		movzx edx,ax
		shr eax, 16
		.IF edx == IDAddIn && eax == BN_CLICKED
			; Your addin has been selected
			invoke ShowColors,hWin,0FFFFFFh
			mov eax,TRUE
			ret
		.ENDIF
	.ELSEIF eax==AIM_MENUUPDATE
		invoke UpdateMenu,wParam
	.endif
	mov eax,FALSE
	ret
AddinProc Endp

;#########################################################################

End DllEntry
