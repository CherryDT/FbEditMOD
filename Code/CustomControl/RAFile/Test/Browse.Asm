.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include Browse.inc

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
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	ebx
		invoke GetDlgItem,hWin,1001
		mov		ebx,eax
		invoke SendMessage,ebx,FBM_SETBACKCOLOR,0,0C0FFFFh
		invoke SendMessage,ebx,FBM_SETTEXTCOLOR,0,0C00000h
		invoke SendMessage,ebx,FBM_SETPATH,FALSE,offset Path
		invoke SendMessage,ebx,FBM_SETFILTERSTRING,FALSE,offset Filter
		invoke SendMessage,ebx,FBM_SETFILTER,TRUE,TRUE
		pop		ebx
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.elseif eax==WM_NOTIFY
		.if wParam==1001
			mov		edx,lParam
			.if [edx].NMHDR.code==FBN_DBLCLICK
				push	edx
				invoke lstrcpy,addr buffer,[edx].FBNOTIFY.lpfile
				invoke CharUpper,addr buffer
				invoke lstrlen,addr buffer
				mov		eax,dword ptr buffer[eax-4]
				pop		edx
				.if eax=='EXE.' || eax=='TAB.'
					invoke WinExec,[edx].FBNOTIFY.lpfile,SW_SHOWNORMAL
				.else
					invoke SendDlgItemMessage,hWin,1002,WM_SETTEXT,0,[edx].FBNOTIFY.lpfile
				.endif
			.elseif [edx].NMHDR.code==FBN_PATHCHANGE
				invoke SendDlgItemMessage,hWin,1002,WM_SETTEXT,0,[edx].FBNOTIFY.lpfile
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

end start
