.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include ReBar.inc

.code

;########################################################################

DoToolBar proc hToolBar:HWND
	LOCAL	tbab:TBADDBITMAP

	;Set toolbar struct size
	invoke SendMessage,hToolBar,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	;Set toolbar bitmap
	push	HINST_COMMCTRL
	pop		tbab.hInst
	mov		tbab.nID,IDB_STD_SMALL_COLOR
	invoke SendMessage,hToolBar,TB_ADDBITMAP,15,addr tbab
	;Set toolbar buttons
	invoke SendMessage,hToolBar,TB_ADDBUTTONS,ntbrbtns,addr tbrbtns
	mov		eax,hToolBar
	ret

DoToolBar endp

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rbbi:REBARBANDINFO
	LOCAL	hReb:HWND
	LOCAL	rect:RECT
	LOCAL	rect1:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_TBR1
		invoke DoToolBar,eax
		invoke GetDlgItem,hWin,IDC_REB1
		mov		hReb,eax
		mov		rbbi.cbSize,sizeof REBARBANDINFO
		mov		rbbi.fMask,RBBIM_STYLE or RBBIM_CHILD or RBBIM_SIZE or RBBIM_CHILDSIZE
		mov		rbbi.fStyle,RBBS_GRIPPERALWAYS or RBBS_CHILDEDGE
		invoke GetDlgItem,hWin,IDC_TBR1
		mov		rbbi.lx,80
		mov		rbbi.cyMinChild,22
		mov		rbbi.cxMinChild,123
		mov		rbbi.hwndChild,eax
		invoke SendMessage,hReb,RB_INSERTBAND,0,addr rbbi

		invoke GetDlgItem,hWin,IDC_CBO1
		mov		rbbi.hwndChild,eax
		mov		rbbi.lx,80
		mov		rbbi.cxMinChild,22
		mov		rbbi.cyMinChild,21
		invoke SendMessage,hReb,RB_INSERTBAND,1,addr rbbi
		invoke GetDlgItem,hWin,IDC_EDT2
		mov		rbbi.hwndChild,eax
		mov		rbbi.cxMinChild,1
		invoke SendMessage,hReb,RB_INSERTBAND,2,addr rbbi
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		movzx	eax,ax
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		eax,lParam
		.if [eax].NMHDR.code==RBN_HEIGHTCHANGE
			invoke SendMessage,hWin,WM_SIZE,0,0
		.endif
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect1
		;Size rebar
		invoke GetDlgItem,hWin,IDC_REB1
		mov		hReb,eax
		invoke GetClientRect,hReb,addr rect
		invoke MoveWindow,hReb,0,2,rect1.right,rect.bottom,TRUE
		;Size edit
		invoke GetDlgItem,hWin,IDC_EDT1
		mov		ecx,rect.bottom
		add		ecx,2
		mov		edx,rect1.bottom
		sub		edx,ecx
		sub		edx,34
		invoke MoveWindow,eax,0,ecx,rect1.right,edx,TRUE
		;Size button
		invoke GetDlgItem,hWin,2
		mov		ecx,rect1.right
		sub		ecx,88+4
		mov		edx,rect1.bottom
		sub		edx,22+4
		invoke MoveWindow,eax,ecx,edx,88,22,TRUE
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
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
	;prepare common control structure
	mov		icex.dwSize,sizeof INITCOMMONCONTROLSEX
	mov		icex.dwICC,ICC_COOL_CLASSES
	invoke InitCommonControlsEx,addr icex
	invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
	invoke ExitProcess,0

end start
