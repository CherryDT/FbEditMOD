
IDD_DLGDONOTDEBUG				equ 8000
IDC_BTNDONOTDEBUG				equ 1003
IDC_BTNDEBUG					equ 1004
IDC_BTNDONOTDEBUGALL			equ 1005
IDC_BTNDEBUGALL					equ 1006
IDC_LSTDONOTDEBUG				equ 1001
IDC_LSTDEBUG					equ 1002
IDC_CHKMAINTHREAD				equ 1007

.const

szp						db 'p',0

.data?

NoDebug					db 2048 dup(?)

.code

NoDebugProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[8]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	hMem:HGLOBAL

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		nInx,0
		mov		esi,offset NoDebug
		.while byte ptr [esi]
			invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_ADDSTRING,0,esi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			inc		nInx
		.endw
		invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr szp,addr szNULL
		.while eax
			mov		esi,eax
			mov		edi,offset NoDebug
			.while byte ptr [edi]
				invoke strcmp,esi,edi
				.break .if !eax
				invoke strlen,edi
				lea		edi,[edi+eax+1]
			.endw
			.if !byte ptr [edi]
				invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_ADDSTRING,0,esi
			.endif
			invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
		.endw
		invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_SETCURSEL,0,0
		invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_SETCURSEL,0,0
		mov		eax,BST_UNCHECKED
		.if fMainThread
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKMAINTHREAD,eax
		.if fDebugging
			mov		eax,IDOK
			call	Disable
			mov		eax,IDC_BTNDONOTDEBUG
			call	Disable
			mov		eax,IDC_BTNDEBUG
			call	Disable
			mov		eax,IDC_BTNDONOTDEBUGALL
			call	Disable
			mov		eax,IDC_BTNDEBUGALL
			call	Disable
			mov		eax,IDC_CHKMAINTHREAD
			call	Disable
		.endif
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				mov		nInx,0
				mov		edi,offset NoDebug
				mov		byte ptr [edi],0
				.while TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_GETTEXT,nInx,edi
					.break .if eax==LB_ERR
					invoke strlen,edi
					lea		edi,[edi+eax+1]
					mov		byte ptr [edi],0
					inc		nInx
				.endw
				invoke IsDlgButtonChecked,hWin,IDC_CHKMAINTHREAD
				mov		fMainThread,eax
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNDONOTDEBUG
				invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_GETTEXT,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_DELETESTRING,nInx,0
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_ADDSTRING,0,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_SETCURSEL,eax,0
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_SETCURSEL,nInx,0
					.if eax==LB_ERR && nInx
						dec		nInx
						invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_SETCURSEL,nInx,0
					.endif
				.endif
			.elseif eax==IDC_BTNDEBUG
				invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_GETTEXT,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_DELETESTRING,nInx,0
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_ADDSTRING,0,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_SETCURSEL,eax,0
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_SETCURSEL,nInx,0
					.if eax==LB_ERR && nInx
						dec		nInx
						invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_SETCURSEL,nInx,0
					.endif
				.endif
			.elseif eax==IDC_BTNDONOTDEBUGALL
				.while TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_GETTEXT,0,addr buffer
					.break .if eax==LB_ERR
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_DELETESTRING,0,0
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_ADDSTRING,0,addr buffer
				.endw
			.elseif eax==IDC_BTNDEBUGALL
				.while TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_GETTEXT,0,addr buffer
					.break .if eax==LB_ERR
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_DELETESTRING,0,0
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_ADDSTRING,0,addr buffer
				.endw
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Disable:
	invoke GetDlgItem,hWin,eax
	invoke EnableWindow,eax,FALSE
	retn

NoDebugProc endp
