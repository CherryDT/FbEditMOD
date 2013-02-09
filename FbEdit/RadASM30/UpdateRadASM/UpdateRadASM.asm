.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include UpdateRadASM.inc
include Misc.asm

.code

;########################################################################

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	verold[32]:BYTE
	LOCAL	vernew[32]:BYTE
	LOCAL	verapp[32]:BYTE

	mov		eax,uMsg
	.if	eax==WM_INITDIALOG
		;initialization here
		mov		verold,0
		mov		vernew,0
		invoke CheckDlgButton,hWin,IDC_RBNUPRA,BST_CHECKED
		invoke CheckDlgButton,hWin,IDC_RBNUPLANG,BST_CHECKED
		invoke GetModuleFileName,hInstance,addr szAppPath,sizeof szAppPath
		invoke lstrlen,addr szAppPath
		.while szAppPath[eax]!='\' && eax
			dec		eax
		.endw
		mov		szAppPath[eax],0
		invoke GetCommandLine
		invoke PathGetArgs,eax
		invoke lstrcpy,addr szRadASMPath,eax
		.if !szRadASMPath
			invoke lstrcpy,addr szRadASMPath,addr szAppPath
			invoke lstrlen,addr szRadASMPath
			.while szRadASMPath[eax]!='\' && eax
				dec		eax
			.endw
			mov		szRadASMPath[eax],0
		.endif
		invoke lstrcpy,addr buffer,addr szAppPath
		invoke lstrcat,addr buffer,addr szBS
		invoke lstrcat,addr buffer,addr szUpdateRadASMExe
		invoke GetFileVersion,hWin,addr buffer,addr verapp
		invoke lstrcpy,addr buffer,addr szRadASMPath
		invoke lstrcat,addr buffer,addr szBS
		invoke lstrcat,addr buffer,addr szRadASMExe
		invoke FileExists,hWin,addr buffer,TRUE
		.if eax
			invoke GetFileVersion,hWin,addr buffer,addr verold
			invoke lstrcpy,addr buffer,addr szAppPath
			invoke lstrcat,addr buffer,addr szBS
			invoke lstrcat,addr buffer,addr szRadASMExe
			invoke FileExists,hWin,addr buffer,TRUE
			.if eax
				invoke GetFileVersion,hWin,addr buffer,addr vernew
				invoke wsprintf,addr buffer,addr szVersionFormat,addr verapp,addr verold,addr vernew
				invoke SetDlgItemText,hWin,IDC_EDTLOG,addr buffer
				invoke lstrcmp,addr verapp,addr vernew
				.if eax
					invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_SETSEL,100,100
					invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr szErrVersion
				.else
					invoke GetDlgItem,hWin,IDOK
					invoke EnableWindow,eax,TRUE
				.endif
			.endif
		.endif
	.elseif	eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke IsRadASMRunning,hWin
				.if !eax
					invoke Update,hWin
				.endif
			.elseif eax==IDCANCEL
				invoke	SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif	eax==WM_CLOSE
		invoke	EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

start:
	invoke GetModuleHandle,NULL
	mov		hInstance,eax
	invoke InitCommonControls
	invoke DialogBoxParam,hInstance,IDD_MAIN,NULL,addr DlgProc,NULL
	invoke ExitProcess,0

end start
