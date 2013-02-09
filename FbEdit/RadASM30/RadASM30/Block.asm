
;Block.dlg
IDD_BLOCKDLG					equ 2900
IDC_EDTBLOCKINSERT				equ 5201
IDC_STCBLOCKINSERT				equ 5202

.data?

szblockinsert			BYTE 256 dup(?)

.code

BlockInsertProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_EDTBLOCKINSERT,EM_LIMITTEXT,255,0
		invoke SetDlgItemText,hWin,IDC_EDTBLOCKINSERT,addr szblockinsert
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendDlgItemMessage,hWin,IDC_EDTBLOCKINSERT,WM_GETTEXT,sizeof szblockinsert,addr szblockinsert
				invoke SendMessage,ha.hEdt,REM_BLOCKINSERT,0,addr szblockinsert
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

BlockInsertProc endp

