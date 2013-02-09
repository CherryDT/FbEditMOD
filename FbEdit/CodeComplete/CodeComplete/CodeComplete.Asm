.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include CodeComplete.inc
include ..\RACodeComplete.Inc

.code

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax
	invoke LoadLibrary,addr szDll
	.if eax
		mov		hDll,eax
	    invoke InitCommonControls
		invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
		invoke FreeLibrary,hDll
	.endif
	invoke ExitProcess,0

;########################################################################

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nBytes:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	tti:TTITEM
	LOCAL	ccCol:CC_COLOR
	LOCAL	ttCol:TT_COLOR

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,1002,CCM_GETCOLOR,0,addr ccCol
		mov		ccCol.back,0C0FFFFh
		mov		ccCol.text,0800000h
		invoke SendDlgItemMessage,hWin,1002,CCM_SETCOLOR,0,addr ccCol
		invoke SendDlgItemMessage,hWin,1005,TTM_GETCOLOR,0,addr ttCol
		mov		ttCol.api,008000h
		mov		ttCol.hilite,0000A0h
		invoke SendDlgItemMessage,hWin,1005,TTM_SETCOLOR,0,addr ttCol
		call	ParseFile
		mov		buffer,0
		call	Update
		mov		tti.lpszApi,offset szTestApi
		mov		tti.lpszParam,offset szTestParam
		mov		tti.lpszRetType,offset szTestRetType
		mov		tti.lpszDesc,offset szTestDesc
		mov		tti.nitem,1
		mov		tti.novr,3
		mov		tti.nsel,1
		invoke SendDlgItemMessage,hWin,1005,TTM_SETITEM,0,addr tti
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke EndDialog,hWin,0
			.elseif eax==1003
				invoke SetDlgItemText,hWin,1001,NULL
				invoke SendDlgItemMessage,hWin,1002,CCM_CLEAR,0,0
			.elseif eax==1004
				invoke GetDlgItemText,hWin,1001,addr buffer,sizeof buffer
				call	Update
			.endif
		.elseif edx==EN_CHANGE
			invoke GetDlgItemText,hWin,1001,addr buffer,sizeof buffer
			call	Update
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

ParseFile:
	push	esi
	push	edi
	invoke GetModuleFileName,0,addr buffer,sizeof buffer
	invoke lstrlen,addr buffer
	.while eax
		.if byte ptr buffer[eax]=='\'
			mov		buffer[eax+1],0
			.break
		.endif
		dec		eax
	.endw
	invoke lstrcat,addr buffer,offset ApiFile
	invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	mov		edi,eax
	invoke GetFileSize,edi,NULL
	mov		edx,eax
	mov		esi,offset FileData
	invoke ReadFile,edi,esi,edx,addr nBytes,NULL
	invoke CloseHandle,edi
	mov		edi,esi
	.while byte ptr [esi]
		mov		al,[esi]
		inc		esi
		.if al!=0Ah
			.if al==0Dh
				mov		al,0
				inc		esi
			.endif
			mov		[edi],al
			inc		edi
		.endif
	.endw
	mov		byte ptr [edi],0
	pop		edi
	pop		esi
	retn

Filter:
	lea		edx,buffer
	mov		ecx,esi
  @@:
	mov		al,[edx]
	.if al
		mov		ah,[ecx]
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		.if ah>='a' && ah<='z'
			and		ah,5Fh
		.endif
		inc		edx
		inc		ecx
		sub		al,ah
		je		@b
	.endif
	movsx	eax,al
	retn

Update:
	push	esi
	push	edi
	invoke GetDlgItem,hWin,1002
	mov		edi,eax
	invoke SendMessage,edi,CCM_CLEAR,0,0
	invoke SendMessage,edi,WM_SETREDRAW,FALSE,0
	mov		esi,offset FileData
	.while byte ptr [esi]
		call	Filter
		.if !eax
			invoke SendMessage,edi,CCM_ADDITEM,0,esi
		.endif
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
	.endw
	invoke SendMessage,edi,CCM_SORT,FALSE,0
	invoke SendMessage,edi,WM_SETREDRAW,TRUE,0
	invoke SendMessage,edi,CCM_SETCURSEL,0,0
	pop		edi
	pop		esi
	retn

DlgProc endp

end start
