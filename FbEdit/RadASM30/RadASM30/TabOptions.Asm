
IDD_TABOPTIONS		equ 2050
IDC_TABOPT			equ 2001

IDD_TABOPT1			equ 2100
IDC_RBNEXPOPT1		equ 2101
IDC_RBNEXPOPT2		equ 2102
IDC_RBNEXPOPT3		equ 2103
IDC_RBNEXPOPT4		equ 2104
IDC_RBNEXPOPT5		equ 2105
IDC_RBNEXPORT6		equ 2106
IDC_EDTEXPORTUSER	equ 2107
IDC_RBNEXPORTFILE	equ 2110
IDC_RBNEXPORTCLIP	equ 2111
IDC_RBNEXPORTOUT	equ 2112
IDC_EDTEXPOPT		equ 2113
IDC_CHKAUTOEXPORT	equ 2114

IDD_TABOPT2			equ 2200
IDC_GRDCUST			equ 2201
IDC_BTNCUSTADD		equ 2204
IDC_BTNCUSTDEL		equ 2205

IDD_TABOPT3			equ 2300
IDC_EDTX			equ 4008
IDC_EDTY			equ 4005
IDC_UDNX			equ 4007
IDC_UDNY			equ 4004
IDC_STCCOLOR		equ 4006
IDC_CHKSNAPGRID		equ 4002
IDC_CHKSHOWGRID		equ 4003
IDC_CHKSHOWTIP		equ 4001
IDC_CHKGRIDLINE		equ 4009
IDC_CHKSTYLEHEX		equ 4010

IDD_TABOPT4			equ 2400
IDC_GRDCUSTSTYLE	equ 2401
IDC_BTNCUSTSTYLEDEL	equ 2403
IDC_BTNCUSTSTYLEADD	equ 2402

IDD_TABOPT5			equ 2510
IDC_GRDRESTYPE		equ 2501
IDC_BTNRESTYPEDEL	equ 2503
IDC_BTNRESTYPEADD	equ 2502

.const

szFilterDLL			db 'Dll (*.dll)',0,'*.dll',0,0
szFilterEXE			db 'Exe (*.exe)',0,'*.exe',0,0

TabTitle1			db 'Exports',0
TabTitle2			db 'Custom controls',0
TabTitle3			db 'Behaviour',0
TabTitle4			db 'Custom styles',0
TabTitle5			db 'Resource types',0

szHdrCust			db 'Custom control',0
szHdrCustMask		db 'Style mask',0

szHdrStyle			db 'Style',0
szHdrVal			db 'Value',0
szHdrMask			db 'Mask',0

szHdrName			db 'Name',0
szHdrFiles			db 'Files',0
szHdrEdit			db 'Editor',0

.data?

hTabOpt				dd ?
hTabDlg				dd 5 dup(?)
SelTab				dd ?
hBr					dd ?
resopt				RESOPT <>

.code

;Export options
TabOpt1Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,resopt.nExport
		add		eax,IDC_RBNEXPOPT1
		invoke CheckRadioButton,hWin,IDC_RBNEXPOPT1,IDC_RBNEXPORT6,eax
		mov		eax,resopt.nOutput
		add		eax,IDC_RBNEXPORTFILE
		invoke CheckRadioButton,hWin,IDC_RBNEXPORTFILE,IDC_RBNEXPORTOUT,eax
		invoke SetDlgItemText,hWin,IDC_EDTEXPORTUSER,addr resopt.szUserExport
		invoke SendDlgItemMessage,hWin,IDC_EDTEXPORTUSER,EM_LIMITTEXT,sizeof resopt.szUserExport-1,0
		invoke SetDlgItemText,hWin,IDC_EDTEXPOPT,addr resopt.szExport
		invoke SendDlgItemMessage,hWin,IDC_EDTEXPOPT,EM_LIMITTEXT,sizeof resopt.szExport-1,0
		.if resopt.fopt & RESOPT_AUTO
			mov		eax,BST_CHECKED
		.else
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKAUTOEXPORT,eax
		call	EnableUser
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			call	EnableUser
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

EnableUser:
	invoke GetDlgItem,hWin,IDC_EDTEXPORTUSER
	push	eax
	invoke IsDlgButtonChecked,hWin,IDC_RBNEXPORT6
	pop		edx
	invoke EnableWindow,edx,eax
	retn

TabOpt1Proc endp

;Custom controls
TabOpt2Proc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	ofn:OPENFILENAME
	LOCAL	hGrd:HWND
	LOCAL	clmn:COLUMN
	LOCAL	row[2]:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_GRDCUST
		mov		hGrd,eax
		invoke SendMessage,hWin,WM_GETFONT,0,0
		invoke SendMessage,hGrd,WM_SETFONT,eax,FALSE
		invoke ConvertDpiSize,18
		push	eax
		invoke SendMessage,hGrd,GM_SETHDRHEIGHT,0,eax
		pop		eax
		invoke SendMessage,hGrd,GM_SETROWHEIGHT,0,eax
		;File
		invoke ConvertDpiSize,300
		mov		clmn.colwt,eax
		mov		clmn.lpszhdrtext,offset szHdrCust
		mov		clmn.halign,GA_ALIGN_LEFT
		mov		clmn.calign,GA_ALIGN_LEFT
		mov		clmn.ctype,TYPE_EDITBUTTON
		mov		clmn.ctextmax,127
		mov		clmn.lpszformat,0
		mov		clmn.himl,0
		mov		clmn.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr clmn
		;Style mask
		invoke ConvertDpiSize,80
		mov		clmn.colwt,eax
		mov		clmn.lpszhdrtext,offset szHdrCustMask
		mov		clmn.halign,GA_ALIGN_LEFT
		mov		clmn.calign,GA_ALIGN_LEFT
		mov		clmn.ctype,TYPE_EDITTEXT
		mov		clmn.ctextmax,15
		mov		clmn.lpszformat,0
		mov		clmn.himl,0
		mov		clmn.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr clmn
		mov		nInx,0
		mov		esi,offset resopt.custctrl
		.while nInx<32
			.if [esi].CUSTCTRL.szFileName
				lea		eax,[esi].CUSTCTRL.szFileName
				mov		row[0],eax
				lea		eax,[esi].CUSTCTRL.szStyleMask
				mov		row[4],eax
				invoke SendMessage,hGrd,GM_ADDROW,0,addr row
			.endif
			lea		esi,[esi+sizeof CUSTCTRL]
			inc		nInx
		.endw
	.elseif eax==WM_COMMAND
		invoke GetDlgItem,hWin,IDC_GRDCUST
		mov		hGrd,eax
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_BTNCUSTADD
				invoke SendMessage,hGrd,GM_ADDROW,0,NULL
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
			.elseif eax==IDC_BTNCUSTDEL
				invoke SendMessage,hGrd,GM_GETCURROW,0,0
				push	eax
				invoke SendMessage,hGrd,GM_DELROW,eax,0
				pop		eax
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		invoke GetDlgItem,hWin,IDC_GRDCUST
		mov		hGrd,eax
		mov		esi,lParam
		mov		eax,[esi].NMHDR.hwndFrom
		.if eax==hGrd
			mov		eax,[esi].NMHDR.code
			.if eax==GN_HEADERCLICK
				;Sort the grid by column, invert sorting order
				invoke SendMessage,hGrd,GM_COLUMNSORT,[esi].GRIDNOTIFY.col,SORT_INVERT
			.elseif eax==GN_BUTTONCLICK
				;Cell button clicked
				;Zero out the ofn struct
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	ha.hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrInitialDir,NULL
				mov		ofn.lpstrFilter,offset szFilterDLL
				mov		ofn.lpstrDefExt,0
				mov		ofn.lpstrTitle,0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				invoke strcpy,eax,[esi].GRIDNOTIFY.lpdata
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				.if eax
					mov		edx,[esi].GRIDNOTIFY.lpdata
					invoke strcpy,edx,addr buffer
					mov		[esi].GRIDNOTIFY.fcancel,FALSE
				.else
					mov		[esi].GRIDNOTIFY.fcancel,TRUE
				.endif
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TabOpt2Proc endp

;Behaviour
TabOpt3Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	cc:CHOOSECOLOR

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_UDNX,UDM_SETRANGE,0,00020014h			; Set range
		invoke SendDlgItemMessage,hWin,IDC_UDNX,UDM_SETPOS,0,resopt.gridx			; Set default value
		invoke SendDlgItemMessage,hWin,IDC_UDNY,UDM_SETRANGE,0,00020014h			; Set range
		invoke SendDlgItemMessage,hWin,IDC_UDNY,UDM_SETPOS,0,resopt.gridy			; Set default value
		.if resopt.fopt & RESOPT_GRID
			invoke CheckDlgButton,hWin,IDC_CHKSHOWGRID,BST_CHECKED
		.endif
		.if resopt.fopt & RESOPT_SNAP
			invoke CheckDlgButton,hWin,IDC_CHKSNAPGRID,BST_CHECKED
		.endif
		.if resopt.fopt & RESOPT_TIP
			invoke CheckDlgButton,hWin,IDC_CHKSHOWTIP,BST_CHECKED
		.endif
		.if resopt.fopt & RESOPT_LINE
			invoke CheckDlgButton,hWin,IDC_CHKGRIDLINE,BST_CHECKED
		.endif
		.if resopt.fopt & RESOPT_HEX
			invoke CheckDlgButton,hWin,IDC_CHKSTYLEHEX,BST_CHECKED
		.endif
	.elseif eax==WM_DRAWITEM
		mov		edx,lParam
		invoke FillRect,[edx].DRAWITEMSTRUCT.hdc,addr [edx].DRAWITEMSTRUCT.rcItem,hBr
	.elseif eax==WM_COMMAND
		.if wParam==IDC_STCCOLOR
			mov		cc.lStructSize,sizeof CHOOSECOLOR
			mov		eax,hWin
			mov		cc.hwndOwner,eax
			mov		eax,ha.hInstance
			mov		cc.hInstance,eax
			mov		cc.lpCustColors,offset CustColors
			mov		cc.Flags,CC_FULLOPEN or CC_RGBINIT
			mov		cc.lCustData,0
			mov		cc.lpfnHook,0
			mov		cc.lpTemplateName,0
			mov		eax,resopt.color
			mov		cc.rgbResult,eax
			invoke ChooseColor,addr cc
			.if eax
				invoke DeleteObject,hBr
				mov		eax,cc.rgbResult
				mov		resopt.color,eax
				invoke CreateSolidBrush,eax
				mov		hBr,eax
				invoke GetDlgItem,hWin,IDC_STCCOLOR
				invoke InvalidateRect,eax,NULL,TRUE
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TabOpt3Proc endp

;Custom styles
TabOpt4Proc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hGrd:HWND
	LOCAL	clmn:COLUMN
	LOCAL	nInx:DWORD
;	LOCAL	cust:CUSTSTYLE
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	row[3]:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_GRDCUSTSTYLE
		mov		hGrd,eax
		invoke SendMessage,hWin,WM_GETFONT,0,0
		invoke SendMessage,hGrd,WM_SETFONT,eax,FALSE
		invoke ConvertDpiSize,18
		push	eax
		invoke SendMessage,hGrd,GM_SETHDRHEIGHT,0,eax
		pop		eax
		invoke SendMessage,hGrd,GM_SETROWHEIGHT,0,eax
		;Style
		invoke ConvertDpiSize,240
		mov		clmn.colwt,eax
		mov		clmn.lpszhdrtext,offset szHdrStyle
		mov		clmn.halign,GA_ALIGN_LEFT
		mov		clmn.calign,GA_ALIGN_LEFT
		mov		clmn.ctype,TYPE_EDITTEXT
		mov		clmn.ctextmax,64
		mov		clmn.lpszformat,0
		mov		clmn.himl,0
		mov		clmn.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr clmn
		;Value
		invoke ConvertDpiSize,70
		mov		clmn.colwt,eax
		mov		clmn.lpszhdrtext,offset szHdrVal
		mov		clmn.halign,GA_ALIGN_LEFT
		mov		clmn.calign,GA_ALIGN_LEFT
		mov		clmn.ctype,TYPE_EDITTEXT
		mov		clmn.ctextmax,8
		mov		clmn.lpszformat,0
		mov		clmn.himl,0
		mov		clmn.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr clmn
		;Mask
		invoke ConvertDpiSize,70
		mov		clmn.colwt,eax
		mov		clmn.lpszhdrtext,offset szHdrMask
		mov		clmn.halign,GA_ALIGN_LEFT
		mov		clmn.calign,GA_ALIGN_LEFT
		mov		clmn.ctype,TYPE_EDITTEXT
		mov		clmn.ctextmax,8
		mov		clmn.lpszformat,0
		mov		clmn.himl,0
		mov		clmn.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr clmn
		;Get custom styles
		mov		nInx,0
		mov		esi,offset resopt.custstyle
		.while nInx<64
			.if [esi].CUSTSTYLE.szStyle
				lea		eax,[esi].CUSTSTYLE.szStyle
				mov		row[0],eax
				call	ClearBuffer
				invoke BinToHex,[esi].CUSTSTYLE.nValue,addr buffer
				lea		eax,buffer
				mov		row[4],eax
				invoke BinToHex,[esi].CUSTSTYLE.nMask,addr buffer[32]
				lea		eax,buffer[32]
				mov		row[8],eax
				invoke SendMessage,hGrd,GM_ADDROW,0,addr row
			.endif
			lea		esi,[esi+sizeof CUSTSTYLE]
			inc		nInx
		.endw
	.elseif eax==WM_COMMAND
		invoke GetDlgItem,hWin,IDC_GRDCUSTSTYLE
		mov		hGrd,eax
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_BTNCUSTSTYLEADD
				invoke SendMessage,hGrd,GM_ADDROW,0,NULL
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
			.elseif eax==IDC_BTNCUSTSTYLEDEL
				invoke SendMessage,hGrd,GM_GETCURROW,0,0
				push	eax
				invoke SendMessage,hGrd,GM_DELROW,eax,0
				pop		eax
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

ClearBuffer:
	xor		ecx,ecx
	.while ecx<64
		mov		byte ptr buffer[ecx],0
		inc		ecx
	.endw
	retn

TabOpt4Proc endp

;Resource types
TabOpt5Proc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hGrd:HWND
	LOCAL	clmn:COLUMN
	LOCAL	ofn:OPENFILENAME
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	row[4]:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_GRDRESTYPE
		mov		hGrd,eax
		invoke SendMessage,hWin,WM_GETFONT,0,0
		invoke SendMessage,hGrd,WM_SETFONT,eax,FALSE
		invoke ConvertDpiSize,18
		push	eax
		invoke SendMessage,hGrd,GM_SETHDRHEIGHT,0,eax
		pop		eax
		invoke SendMessage,hGrd,GM_SETROWHEIGHT,0,eax
		;Type
		invoke ConvertDpiSize,110
		mov		clmn.colwt,eax
		mov		clmn.lpszhdrtext,offset szHdrName
		mov		clmn.halign,GA_ALIGN_LEFT
		mov		clmn.calign,GA_ALIGN_LEFT
		mov		clmn.ctype,TYPE_EDITTEXT
		mov		clmn.ctextmax,31
		mov		clmn.lpszformat,0
		mov		clmn.himl,0
		mov		clmn.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr clmn
		;Value
		invoke ConvertDpiSize,50
		mov		clmn.colwt,eax
		mov		clmn.lpszhdrtext,offset szHdrVal
		mov		clmn.halign,GA_ALIGN_RIGHT
		mov		clmn.calign,GA_ALIGN_RIGHT
		mov		clmn.ctype,TYPE_EDITLONG
		mov		clmn.ctextmax,5
		mov		clmn.lpszformat,0
		mov		clmn.himl,0
		mov		clmn.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr clmn
		;Files
		invoke ConvertDpiSize,115
		mov		clmn.colwt,eax
		mov		clmn.lpszhdrtext,offset szHdrFiles
		mov		clmn.halign,GA_ALIGN_LEFT
		mov		clmn.calign,GA_ALIGN_LEFT
		mov		clmn.ctype,TYPE_EDITTEXT
		mov		clmn.ctextmax,63
		mov		clmn.lpszformat,0
		mov		clmn.himl,0
		mov		clmn.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr clmn
		;Editor
		invoke ConvertDpiSize,115
		mov		clmn.colwt,eax
		mov		clmn.lpszhdrtext,offset szHdrEdit
		mov		clmn.halign,GA_ALIGN_LEFT
		mov		clmn.calign,GA_ALIGN_LEFT
		mov		clmn.ctype,TYPE_EDITBUTTON
		mov		clmn.ctextmax,127
		mov		clmn.lpszformat,0
		mov		clmn.himl,0
		mov		clmn.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr clmn
		mov		nInx,0
		mov		esi,offset resopt.custtype
		.while nInx<32
			.if [esi].RARSTYPE.sztype || [esi].RARSTYPE.nid
				lea		eax,[esi].RARSTYPE.sztype
				mov		row[0],eax
				mov		eax,[esi].RARSTYPE.nid
				mov		row[4],eax
				lea		eax,[esi].RARSTYPE.szext
				mov		row[8],eax
				lea		eax,[esi].RARSTYPE.szedit
				mov		row[12],eax
				invoke SendMessage,hGrd,GM_ADDROW,0,addr row
			.endif
			lea		esi,[esi+sizeof RARSTYPE]
			inc		nInx
		.endw
	.elseif eax==WM_COMMAND
		invoke GetDlgItem,hWin,IDC_GRDRESTYPE
		mov		hGrd,eax
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_BTNRESTYPEADD
				invoke SendMessage,hGrd,GM_ADDROW,0,NULL
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
			.elseif eax==IDC_BTNRESTYPEDEL
				invoke SendMessage,hGrd,GM_GETCURROW,0,0
				push	eax
				invoke SendMessage,hGrd,GM_DELROW,eax,0
				pop		eax
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		invoke GetDlgItem,hWin,IDC_GRDRESTYPE
		mov		hGrd,eax
		mov		esi,lParam
		mov		eax,[esi].NMHDR.hwndFrom
		.if eax==hGrd
			mov		eax,[esi].NMHDR.code
			.if eax==GN_HEADERCLICK
				;Sort the grid by column, invert sorting order
				;invoke SendMessage,hGrd,GM_COLUMNSORT,[esi].GRIDNOTIFY.col,SORT_INVERT
			.elseif eax==GN_BUTTONCLICK
				;Cell button clicked
				;Zero out the ofn struct
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	ha.hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrInitialDir,NULL
				mov		ofn.lpstrFilter,offset szFilterEXE
				mov		ofn.lpstrDefExt,0
				mov		ofn.lpstrTitle,0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				invoke strcpy,eax,[esi].GRIDNOTIFY.lpdata
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				.if eax
					mov		edx,[esi].GRIDNOTIFY.lpdata
					invoke strcpy,edx,addr buffer
					mov		[esi].GRIDNOTIFY.fcancel,FALSE
				.else
					mov		[esi].GRIDNOTIFY.fcancel,TRUE
				.endif
			.elseif eax==GN_BEFOREEDIT
				.if [esi].GRIDNOTIFY.row<=10 && [esi].GRIDNOTIFY.col<=2
					mov		[esi].GRIDNOTIFY.fcancel,TRUE
				.endif
			.elseif eax==GN_AFTERSELCHANGE
				.if [esi].GRIDNOTIFY.row<=10
					invoke GetDlgItem,hWin,IDC_BTNRESTYPEDEL
					invoke EnableWindow,eax,FALSE
				.else
					invoke GetDlgItem,hWin,IDC_BTNRESTYPEDEL
					invoke EnableWindow,eax,TRUE
				.endif
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TabOpt5Proc endp

TabOptionsProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ts:TC_ITEM
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==IDOK
				invoke IsDlgButtonChecked,hTabDlg,IDC_RBNEXPOPT1
				.if eax
					mov		resopt.nExport,0
				.else
					invoke IsDlgButtonChecked,hTabDlg,IDC_RBNEXPOPT2
					.if eax
						mov		resopt.nExport,1
					.else
						invoke IsDlgButtonChecked,hTabDlg,IDC_RBNEXPOPT3
						.if eax
							mov		resopt.nExport,2
						.else
							invoke IsDlgButtonChecked,hTabDlg,IDC_RBNEXPOPT3
							.if eax
								mov		resopt.nExport,3
							.else
								invoke IsDlgButtonChecked,hTabDlg,IDC_RBNEXPOPT4
								.if eax
									mov		resopt.nExport,4
								.else
									mov		resopt.nExport,5
								.endif
							.endif
						.endif
					.endif
				.endif
				invoke GetDlgItemText,hTabDlg,IDC_EDTEXPORTUSER,addr resopt.szUserExport,sizeof resopt.szUserExport
				invoke IsDlgButtonChecked,hTabDlg,IDC_RBNEXPORTFILE
				.if eax
					mov		resopt.nOutput,0
				.else
					invoke IsDlgButtonChecked,hTabDlg,IDC_RBNEXPORTCLIP
					.if eax
						mov		resopt.nOutput,1
					.else
						mov		resopt.nOutput,2
					.endif
				.endif
				invoke GetDlgItemText,hTabDlg,IDC_EDTEXPOPT,addr resopt.szExport,sizeof resopt.szExport
				invoke IsDlgButtonChecked,hTabDlg,IDC_CHKAUTOEXPORT
				and		resopt.fopt,-1 xor RESOPT_AUTO
				.if eax
					or		resopt.fopt,RESOPT_AUTO
				.endif
				invoke GetDlgItemInt,hTabDlg[4],IDC_EDTX,NULL,FALSE
				mov		resopt.gridx,eax
				invoke GetDlgItemInt,hTabDlg[4],IDC_EDTY,NULL,FALSE
				mov		resopt.gridy,eax
				invoke IsDlgButtonChecked,hTabDlg[4],IDC_CHKSHOWGRID
				and		resopt.fopt,-1 xor RESOPT_GRID
				.if eax
					or		resopt.fopt,RESOPT_GRID
				.endif
				invoke IsDlgButtonChecked,hTabDlg[4],IDC_CHKSNAPGRID
				and		resopt.fopt,-1 xor RESOPT_SNAP
				.if eax
					or		resopt.fopt,RESOPT_SNAP
				.endif
				invoke IsDlgButtonChecked,hTabDlg[4],IDC_CHKSHOWTIP
				and		resopt.fopt,-1 xor RESOPT_TIP
				.if eax
					or		resopt.fopt,RESOPT_TIP
				.endif
				invoke IsDlgButtonChecked,hTabDlg[4],IDC_CHKGRIDLINE
				and		resopt.fopt,-1 xor RESOPT_LINE
				.if eax
					or		resopt.fopt,RESOPT_LINE
				.endif
				invoke IsDlgButtonChecked,hTabDlg[4],IDC_CHKSTYLEHEX
				and		resopt.fopt,-1 xor RESOPT_HEX
				.if eax
					or		resopt.fopt,RESOPT_HEX
				.endif
				; Custom controls
				invoke GetDlgItem,hTabDlg[8],IDC_GRDCUST
				push	eax
				invoke SendMessage,eax,GM_GETCURSEL,0,0
				pop		edx
				invoke SendMessage,edx,GM_ENDEDIT,eax,FALSE
				mov		nInx,0
				mov		esi,offset resopt.custctrl
				invoke RtlZeroMemory,esi,sizeof resopt.custctrl
				.while nInx<32
					invoke SendDlgItemMessage,hTabDlg[8],IDC_GRDCUST,GM_GETROWCOUNT,0,0
					.if eax>nInx
						mov		ecx,nInx
						shl		ecx,16
						invoke SendDlgItemMessage,hTabDlg[8],IDC_GRDCUST,GM_GETCELLDATA,ecx,addr [esi].CUSTCTRL.szFileName
						mov		ecx,nInx
						shl		ecx,16
						or		ecx,1
						invoke SendDlgItemMessage,hTabDlg[8],IDC_GRDCUST,GM_GETCELLDATA,ecx,addr [esi].CUSTCTRL.szStyleMask
					.endif
					lea		esi,[esi+sizeof CUSTCTRL]
					inc		nInx
				.endw
				; Custom styles
				invoke GetDlgItem,hTabDlg[12],IDC_GRDCUSTSTYLE
				push	eax
				invoke SendMessage,eax,GM_GETCURSEL,0,0
				pop		edx
				invoke SendMessage,edx,GM_ENDEDIT,eax,FALSE
				mov		nInx,0
				mov		esi,offset resopt.custstyle
				invoke RtlZeroMemory,esi,sizeof resopt.custstyle
				.while nInx<64
					invoke SendDlgItemMessage,hTabDlg[12],IDC_GRDCUSTSTYLE,GM_GETROWCOUNT,0,0
					.if eax>nInx
						mov		ecx,nInx
						shl		ecx,16
						invoke SendDlgItemMessage,hTabDlg[12],IDC_GRDCUSTSTYLE,GM_GETCELLDATA,ecx,addr [esi].CUSTSTYLE.szStyle
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,1
						invoke SendDlgItemMessage,hTabDlg[12],IDC_GRDCUSTSTYLE,GM_GETCELLDATA,ecx,addr buffer
						invoke HexToBin,addr buffer
						mov		[esi].CUSTSTYLE.nValue,eax
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,2
						invoke SendDlgItemMessage,hTabDlg[12],IDC_GRDCUSTSTYLE,GM_GETCELLDATA,ecx,addr buffer
						invoke HexToBin,addr buffer
						mov		[esi].CUSTSTYLE.nMask,eax
					.endif
					lea		esi,[esi+sizeof CUSTSTYLE]
					inc		nInx
				.endw
				; Custom types
				invoke GetDlgItem,hTabDlg[16],IDC_GRDRESTYPE
				push	eax
				invoke SendMessage,eax,GM_GETCURSEL,0,0
				pop		edx
				invoke SendMessage,edx,GM_ENDEDIT,eax,FALSE
				mov		nInx,0
				mov		nInx,0
				mov		esi,offset resopt.custtype
				invoke RtlZeroMemory,esi,sizeof resopt.custtype
				.while nInx<32
					invoke SendDlgItemMessage,hTabDlg[16],IDC_GRDRESTYPE,GM_GETROWCOUNT,0,0
					.if eax>nInx
						mov		ecx,nInx
						shl		ecx,16
						invoke SendDlgItemMessage,hTabDlg[16],IDC_GRDRESTYPE,GM_GETCELLDATA,ecx,addr [esi].RARSTYPE.sztype
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,1
						invoke SendDlgItemMessage,hTabDlg[16],IDC_GRDRESTYPE,GM_GETCELLDATA,ecx,addr [esi].RARSTYPE.nid
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,2
						invoke SendDlgItemMessage,hTabDlg[16],IDC_GRDRESTYPE,GM_GETCELLDATA,ecx,addr [esi].RARSTYPE.szext
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,3
						invoke SendDlgItemMessage,hTabDlg[16],IDC_GRDRESTYPE,GM_GETCELLDATA,ecx,addr [esi].RARSTYPE.szedit
					.endif
					lea		esi,[esi+sizeof RARSTYPE]
					inc		nInx
				.endw
				invoke RtlMoveMemory,addr da.resopt,addr resopt,sizeof RESOPT
				invoke PutResource
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		eax,lParam
		mov		eax,[eax].NMHDR.code
		.if eax==TCN_SELCHANGE
			;Tab selection
			invoke SendMessage,hTabOpt,TCM_GETCURSEL,0,0
			.if eax!=SelTab
				push	eax
				mov		eax,SelTab
				invoke ShowWindow,[hTabDlg+eax*4],SW_HIDE
				pop		eax
				mov		SelTab,eax
				invoke ShowWindow,[hTabDlg+eax*4],SW_SHOWDEFAULT
			.endif
		.endif
	.elseif eax==WM_INITDIALOG
		invoke RtlMoveMemory,addr resopt,addr da.resopt,sizeof RESOPT
		invoke CreateSolidBrush,resopt.color
		mov		hBr,eax
		;Create the tabs
		invoke GetDlgItem,hWin,IDC_TABOPT
		mov		hTabOpt,eax
		mov		ts.imask,TCIF_TEXT
		mov		ts.iImage,-1
		mov		ts.lParam,0
		mov		ts.pszText,offset TabTitle1
		mov		ts.cchTextMax,sizeof TabTitle1
		invoke SendMessage,hTabOpt,TCM_INSERTITEM,0,addr ts
		mov		ts.pszText,offset TabTitle3
		mov		ts.cchTextMax,sizeof TabTitle3
		invoke SendMessage,hTabOpt,TCM_INSERTITEM,1,addr ts
		mov		ts.pszText,offset TabTitle2
		mov		ts.cchTextMax,sizeof TabTitle2
		invoke SendMessage,hTabOpt,TCM_INSERTITEM,2,addr ts
		mov		ts.pszText,offset TabTitle4
		mov		ts.cchTextMax,sizeof TabTitle4
		invoke SendMessage,hTabOpt,TCM_INSERTITEM,3,addr ts
		mov		ts.pszText,offset TabTitle5
		mov		ts.cchTextMax,sizeof TabTitle5
		invoke SendMessage,hTabOpt,TCM_INSERTITEM,4,addr ts
		;Create the tab dialogs
		;Exports
		invoke CreateDialogParam,ha.hInstance,IDD_TABOPT1,hTabOpt,addr TabOpt1Proc,0
		mov		hTabDlg,eax
		;Behaviour
		invoke CreateDialogParam,ha.hInstance,IDD_TABOPT3,hTabOpt,addr TabOpt3Proc,0
		mov		hTabDlg[4],eax
		;Custom controls
		invoke CreateDialogParam,ha.hInstance,IDD_TABOPT2,hTabOpt,addr TabOpt2Proc,0
		mov		hTabDlg[8],eax
		;Custom styles
		invoke CreateDialogParam,ha.hInstance,IDD_TABOPT4,hTabOpt,addr TabOpt4Proc,0
		mov		hTabDlg[12],eax
		;Resource types
		invoke CreateDialogParam,ha.hInstance,IDD_TABOPT5,hTabOpt,addr TabOpt5Proc,0
		mov		hTabDlg[16],eax
		mov		SelTab,0
	.elseif eax==WM_CLOSE
		invoke DeleteObject,hBr
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TabOptionsProc endp
