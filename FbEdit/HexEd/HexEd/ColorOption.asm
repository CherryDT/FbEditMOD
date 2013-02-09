
;ColorOption.dlg
IDD_DLGOPTIONCOLOR						equ 3300
IDC_LSTCOLOR							equ 3301

.data

szColors			db 'Back',0
					db 'Address text',0
					db 'Data text',0
					db 'Ascii text',0
					db 'Selected focus back',0
					db 'Selected lost focus back',0
					db 'Selected text',0
					db 'Selected ascii text',0
					db 'Selection bar',0
					db 'Selection bar pen',0
					db 'Line numbers',0
					db 0

.code

ColorOptionProc proc uses esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hBr:DWORD
	LOCAL	rect:RECT
	LOCAL	buffer[32]:BYTE
	LOCAL	cc:CHOOSECOLOR

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		esi,offset szColors
		mov		edi,offset col
	  @@:
		invoke SendDlgItemMessage,hWin,IDC_LSTCOLOR,LB_ADDSTRING,0,esi
		invoke SendDlgItemMessage,hWin,IDC_LSTCOLOR,LB_SETITEMDATA,eax,[edi]
		invoke lstrlen,esi
		add		esi,eax
		inc		esi
		add		edi,4
		mov		al,[esi]
		or		al,al
		jne		@b
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				mov		edi,offset col
				xor		eax,eax
			  @@:
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_LSTCOLOR,LB_GETITEMDATA,eax,0
				mov		[edi],eax
				pop		eax
				inc		eax
				add		edi,4
				cmp		edi,offset col+sizeof col
				jc		@b
				invoke RegSetValueEx,hReg,addr szColor,0,REG_BINARY,addr col,sizeof col
				invoke RegSetValueEx,hReg,addr szCustColors,0,REG_BINARY,addr CustColors,sizeof CustColors
				invoke UpdateAll,WM_SETFONT
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.elseif edx==LBN_DBLCLK
			mov		cc.lStructSize,sizeof CHOOSECOLOR
			mov		eax,hWin
			mov		cc.hwndOwner,eax
			mov		eax,hInstance
			mov		cc.hInstance,eax
			mov		cc.lpCustColors,offset CustColors
			mov		cc.Flags,CC_FULLOPEN or CC_RGBINIT
			mov		cc.lCustData,0
			mov		cc.lpfnHook,0
			mov		cc.lpTemplateName,0
			invoke SendDlgItemMessage,hWin,IDC_LSTCOLOR,LB_GETCURSEL,0,0
			invoke SendDlgItemMessage,hWin,IDC_LSTCOLOR,LB_GETITEMDATA,eax,0
			mov		cc.rgbResult,eax
			invoke ChooseColor,addr cc
			.if eax
				invoke SendDlgItemMessage,hWin,IDC_LSTCOLOR,LB_GETCURSEL,0,0
				mov		edx,cc.rgbResult
				invoke SendDlgItemMessage,hWin,IDC_LSTCOLOR,LB_SETITEMDATA,eax,edx
				invoke GetDlgItem,hWin,IDC_LSTCOLOR
				invoke InvalidateRect,eax,NULL,FALSE
			.endif
		.endif
	.elseif eax==WM_DRAWITEM
		mov		esi,lParam
		assume esi:ptr DRAWITEMSTRUCT
		test	[esi].itemState,ODS_SELECTED
		.if ZERO?
			push	COLOR_WINDOW
			mov		eax,COLOR_WINDOWTEXT
		.else
			push	COLOR_HIGHLIGHT
			mov		eax,COLOR_HIGHLIGHTTEXT
		.endif
		invoke GetSysColor,eax
		invoke SetTextColor,[esi].hdc,eax
		pop		eax
		invoke GetSysColor,eax
		invoke SetBkColor,[esi].hdc,eax
		invoke ExtTextOut,[esi].hdc,0,0,ETO_OPAQUE,addr [esi].rcItem,NULL,0,NULL
		mov		eax,[esi].rcItem.left
		inc		eax
		mov		rect.left,eax
		add		eax,25
		mov		rect.right,eax
		mov		eax,[esi].rcItem.top
		inc		eax
		mov		rect.top,eax
		mov		eax,[esi].rcItem.bottom
		dec		eax
		mov		rect.bottom,eax
		mov		eax,[esi].itemData
		and		eax,0FFFFFFh
		invoke CreateSolidBrush,eax
		mov		hBr,eax
		invoke FillRect,[esi].hdc,addr rect,hBr
		invoke DeleteObject,hBr
		invoke GetStockObject,BLACK_BRUSH
		invoke FrameRect,[esi].hdc,addr rect,eax
		invoke SendMessage,[esi].hwndItem,LB_GETTEXT,[esi].itemID,addr buffer
		invoke lstrlen,addr buffer
		mov		edx,[esi].rcItem.left
		add		edx,30
		invoke TextOut,[esi].hdc,edx,[esi].rcItem.top,addr buffer,eax
		assume esi:nothing
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

ColorOptionProc endp
