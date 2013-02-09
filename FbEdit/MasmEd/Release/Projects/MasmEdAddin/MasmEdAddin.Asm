;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include MasmEdAddin.inc

.code

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
	invoke AddMenuItem,mii.hSubMenu,[MenuIDAddin],offset szMenuItem
	ret

UpdateMenu endp

;#########################################################################
;Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

OutputString proc uses ebx,lpString:DWORD

	mov		ebx,lpProc
	push	0
	call	[ebx].ADDINPROCS.lpOutputSelect
	push	TRUE
	call	[ebx].ADDINPROCS.lpOutputShow
	push	lpString
	call	[ebx].ADDINPROCS.lpOutputString
	ret

OutputString endp

; Export this proc
InstallAddin proc uses ebx,hWin:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov		lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax
	invoke SendMessage,ebx,AIM_GETMENUID,0,0	
	mov		MenuIDAddin,eax
	mov		hook.hook1,HOOK_ADDINSLOADED or HOOK_COMMAND or HOOK_CLOSE or HOOK_DESTROY or HOOK_MENUUPDATE
	xor		eax,eax
	mov		hook.hook2,eax
	mov		hook.hook3,eax
	mov		hook.hook4,eax
	mov		eax,offset hook
	ret 

InstallAddin endp

; Export this proc
AddinProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	; This proc handles messages sent from MasmEd to our addin
	; Return TRUE to prevent MasmEd and other addins from executing the command.

	mov		eax,uMsg
	.if eax==AIM_ADDINSLOADED
;		PrintHex wParam
;		PrintHex lParam
	.elseif eax==AIM_COMMAND
		mov		eax,wParam
		.if eax==MenuIDAddin
			;The menuitem we added has been selected
;			PrintHex wParam
;			PrintHex lParam
			invoke OutputString,addr szMenuItem
			mov		eax,TRUE
			jmp		ExRet
		.endif
	.elseif eax==AIM_CLOSE
;		PrintHex wParam
;		PrintHex lParam
	.elseif eax==AIM_DESTROY
;		PrintHex wParam
;		PrintHex lParam
	.elseif eax==AIM_MENUUPDATE
		invoke UpdateMenu,wParam
;		PrintHex wParam
;		PrintHex lParam
	.endif
	mov		eax,FALSE
  ExRet:
	ret

AddinProc endp

;#########################################################################

end DllEntry
