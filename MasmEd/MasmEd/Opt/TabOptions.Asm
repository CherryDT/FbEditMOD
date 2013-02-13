
IDD_TABOPTIONS		equ 2050
IDC_TABOPT			equ 2001

IDD_TABOPT1			equ 2100
IDC_RBNEXPOPT1		equ 2101
IDC_RBNEXPOPT2		equ 2102
IDC_RBNEXPOPT3		equ 2103
IDC_RBNEXPOPT4		equ 2104
IDC_RBNEXPOPT5		equ 2105
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

szCust				db 'Cust#',0
szFilterDLL			db 'Dll (*.dll)',0,'*.dll',0,0
szFilterEXE			db 'Exe (*.exe)',0,'*.exe',0,0
szCustStyle			db 'Style#',0

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
color				dd ?
hBr					dd ?

.code

TabOpt1Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,nmeexp.nType
		add		eax,IDC_RBNEXPOPT1
		invoke CheckRadioButton,hWin,IDC_RBNEXPOPT1,IDC_RBNEXPOPT5,eax
		mov		eax,nmeexp.nOutput
		add		eax,IDC_RBNEXPORTFILE
		invoke CheckRadioButton,hWin,IDC_RBNEXPORTFILE,IDC_RBNEXPORTOUT,eax
		invoke SetDlgItemText,hWin,IDC_EDTEXPOPT,addr nmeexp.szFileName
		invoke SendDlgItemMessage,hWin,IDC_EDTEXPOPT,EM_LIMITTEXT,MAX_PATH,0
		invoke SendDlgItemMessage,hWin,IDC_EDTEXPOPT,EM_LIMITTEXT,MAX_PATH,0
		mov		eax,nmeexp.fAuto
		.if eax
			mov		eax,BST_CHECKED
		.else
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKAUTOEXPORT,eax
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TabOpt1Proc endp

TabOpt2Proc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
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
		mov		clmn.ctextmax,128
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
		mov		clmn.ctextmax,16
		mov		clmn.lpszformat,0
		mov		clmn.himl,0
		mov		clmn.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr clmn
		mov		nInx,1
		.while nInx<=32
			invoke MakeKey,addr szCust,nInx,addr buffer1
			mov		lpcbData,MAX_PATH
			mov		buffer,0
			invoke RegQueryValueEx,ha.hReg,addr buffer1,0,addr lpType,addr buffer,addr lpcbData
			.if buffer
				lea		eax,buffer
				mov		row[0],eax
				.if byte ptr [eax]=='"'
					inc		eax
					.while byte ptr [eax]
						.if byte ptr [eax]=='"'
							inc		eax
							.break
						.endif
						inc		eax
					.endw
				.endif
				.while byte ptr [eax]
					.if byte ptr [eax]==','
						mov		byte ptr [eax],0
						inc		eax
						.break
					.endif
					inc		eax
				.endw
				mov		row[4],eax
				invoke SendMessage,hGrd,GM_ADDROW,0,addr row
			.endif
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

TabOpt3Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	cc:CHOOSECOLOR

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_UDNX,UDM_SETRANGE,0,00020014h	; Set range
		invoke SendDlgItemMessage,hWin,IDC_UDNX,UDM_SETPOS,0,grdsize.x		; Set default value
		invoke SendDlgItemMessage,hWin,IDC_UDNY,UDM_SETRANGE,0,00020014h	; Set range
		invoke SendDlgItemMessage,hWin,IDC_UDNY,UDM_SETPOS,0,grdsize.y		; Set default value
		invoke CheckDlgButton,hWin,IDC_CHKSHOWGRID,grdsize.show
		invoke CheckDlgButton,hWin,IDC_CHKSNAPGRID,grdsize.snap
		invoke CheckDlgButton,hWin,IDC_CHKSHOWTIP,grdsize.tips
		invoke CheckDlgButton,hWin,IDC_CHKGRIDLINE,grdsize.line
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
			mov		eax,color
			mov		cc.rgbResult,eax
			invoke ChooseColor,addr cc
			.if eax
				invoke DeleteObject,hBr
				mov		eax,cc.rgbResult
				mov		color,eax
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

TabOpt4Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hGrd:HWND
	LOCAL	clmn:COLUMN
	LOCAL	nInx:DWORD
	LOCAL	cust:CUSTSTYLE
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
		mov		nInx,1
		.while nInx<=64
			invoke MakeKey,addr szCustStyle,nInx,addr buffer
			mov		lpcbData,sizeof CUSTSTYLE
			mov		cust.szStyle,0
			invoke RegQueryValueEx,ha.hReg,addr buffer,0,addr lpType,addr cust,addr lpcbData
			.if cust.szStyle
				lea		eax,cust.szStyle
				mov		row[0],eax
				call	ClearBuffer
				invoke DwToHex,cust.nValue,addr buffer
				lea		eax,buffer
				mov		row[4],eax
				invoke DwToHex,cust.nMask,addr buffer[32]
				lea		eax,buffer[32]
				mov		row[8],eax
				invoke SendMessage,hGrd,GM_ADDROW,0,addr row
			.endif
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

TabOpt5Proc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hGrd:HWND
	LOCAL	clmn:COLUMN
	LOCAL	ofn:OPENFILENAME
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	row[4]:DWORD
	LOCAL	rarstype:RARSTYPE

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
		mov		nInx,1
		.while nInx<=32
			invoke MakeKey,addr szCustType,nInx,addr buffer
			mov		lpcbData,sizeof RARSTYPE
			invoke RtlZeroMemory,addr rarstype,sizeof RARSTYPE
			invoke RegQueryValueEx,ha.hReg,addr buffer,0,addr lpType,addr rarstype,addr lpcbData
			.if rarstype.sztype || rarstype.nid
				lea		eax,rarstype.sztype
				mov		row[0],eax
				mov		eax,rarstype.nid
				mov		row[4],eax
				lea		eax,rarstype.szext
				mov		row[8],eax
				lea		eax,rarstype.szedit
				mov		row[12],eax
				invoke SendMessage,hGrd,GM_ADDROW,0,addr row
			.elseif nInx<=11
				mov		edx,nInx
				dec		edx
				invoke SendMessage,ha.hResEd,PRO_GETCUSTOMTYPE,edx,0
				mov		edx,eax
				.if [edx].RARSTYPE.sztype
					lea		eax,[edx].RARSTYPE.sztype
					mov		row[0],eax
					mov		eax,[edx].RARSTYPE.nid
					mov		row[4],eax
					lea		eax,[edx].RARSTYPE.szext
					mov		row[8],eax
					lea		eax,[edx].RARSTYPE.szedit
					mov		row[12],eax
					invoke SendMessage,hGrd,GM_ADDROW,0,addr row
				.endif
			.endif
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

TabOptionsProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ts:TC_ITEM
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[64]:BYTE
	LOCAL	cust:CUSTSTYLE
	LOCAL	rarstype:RARSTYPE

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
					mov		nmeexp.nType,0
				.else
					invoke IsDlgButtonChecked,hTabDlg,IDC_RBNEXPOPT2
					.if eax
						mov		nmeexp.nType,1
					.else
						invoke IsDlgButtonChecked,hTabDlg,IDC_RBNEXPOPT3
						.if eax
							mov		nmeexp.nType,2
						.else
							invoke IsDlgButtonChecked,hTabDlg,IDC_RBNEXPOPT3
							.if eax
								mov		nmeexp.nType,3
							.else
								mov		nmeexp.nType,4
							.endif
						.endif
					.endif
				.endif
				invoke IsDlgButtonChecked,hTabDlg,IDC_RBNEXPORTFILE
				.if eax
					mov		nmeexp.nOutput,0
				.else
					invoke IsDlgButtonChecked,hTabDlg,IDC_RBNEXPORTCLIP
					.if eax
						mov		nmeexp.nOutput,1
					.else
						mov		nmeexp.nOutput,2
					.endif
				.endif
				invoke GetDlgItemText,hTabDlg,IDC_EDTEXPOPT,addr nmeexp.szFileName,sizeof nmeexp.szFileName
				invoke IsDlgButtonChecked,hTabDlg,IDC_CHKAUTOEXPORT
				.if eax
					mov		nmeexp.fAuto,1
				.else
					mov		nmeexp.fAuto,0
				.endif
				invoke RegSetValueEx,ha.hReg,addr szNmeExp,0,REG_BINARY,addr nmeexp,sizeof nmeexp
				mov		edx,nmeexp.nOutput
				shl		edx,16
				add		edx,nmeexp.nType
				invoke SendMessage,ha.hResEd,PRO_SETEXPORT,edx,addr nmeexp.szFileName
				invoke GetDlgItemInt,hTabDlg[4],IDC_EDTX,NULL,FALSE
				mov		grdsize.x,eax
				invoke GetDlgItemInt,hTabDlg[4],IDC_EDTY,NULL,FALSE
				mov		grdsize.y,eax
				invoke IsDlgButtonChecked,hTabDlg[4],IDC_CHKSHOWGRID
				mov		grdsize.show,eax
				invoke IsDlgButtonChecked,hTabDlg[4],IDC_CHKSNAPGRID
				mov		grdsize.snap,eax
				invoke IsDlgButtonChecked,hTabDlg[4],IDC_CHKSHOWTIP
				mov		grdsize.tips,eax
				invoke IsDlgButtonChecked,hTabDlg[4],IDC_CHKGRIDLINE
				mov		grdsize.line,eax
				invoke IsDlgButtonChecked,hTabDlg[4],IDC_CHKSTYLEHEX
				mov		grdsize.stylehex,eax
				; Custom controls
				invoke GetDlgItem,hTabDlg[8],IDC_GRDCUST
				push	eax
				invoke SendMessage,eax,GM_GETCURSEL,0,0
				pop		edx
				invoke SendMessage,edx,GM_ENDEDIT,eax,FALSE
				mov		nInx,0
				.while nInx<32
					invoke SendDlgItemMessage,hTabDlg[8],IDC_GRDCUST,GM_GETROWCOUNT,0,0
					.if eax>nInx
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						invoke SendDlgItemMessage,hTabDlg[8],IDC_GRDCUST,GM_GETCELLDATA,ecx,addr buffer
						invoke strcat,addr buffer,addr szComma
						invoke strlen,addr buffer
						mov		ecx,nInx
						shl		ecx,16
						or		ecx,1
						invoke SendDlgItemMessage,hTabDlg[8],IDC_GRDCUST,GM_GETCELLDATA,ecx,addr buffer[eax]
						inc		nInx
						invoke MakeKey,addr szCust,nInx,addr buffer1
						invoke strlen,addr buffer
						inc		eax
						invoke RegSetValueEx,ha.hReg,addr buffer1,0,REG_SZ,addr buffer,eax
					.else
						inc		nInx
						invoke MakeKey,addr szCust,nInx,addr buffer1
						invoke RegDeleteValue,ha.hReg,addr buffer1
					.endif
				.endw
				; Custom styles
				invoke GetDlgItem,hTabDlg[12],IDC_GRDCUSTSTYLE
				push	eax
				invoke SendMessage,eax,GM_GETCURSEL,0,0
				pop		edx
				invoke SendMessage,edx,GM_ENDEDIT,eax,FALSE
				invoke SendMessage,ha.hResEd,DEM_CLEARCUSTSTYLE,0,0
				mov		nInx,0
				.while nInx<64
					invoke SendDlgItemMessage,hTabDlg[12],IDC_GRDCUSTSTYLE,GM_GETROWCOUNT,0,0
					.if eax>nInx
						invoke RtlZeroMemory,addr cust,sizeof CUSTSTYLE
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						invoke SendDlgItemMessage,hTabDlg[12],IDC_GRDCUSTSTYLE,GM_GETCELLDATA,ecx,addr buffer
						invoke strcpy,addr cust.szStyle,addr buffer
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,1
						invoke SendDlgItemMessage,hTabDlg[12],IDC_GRDCUSTSTYLE,GM_GETCELLDATA,ecx,addr buffer
						invoke HexToDw,addr buffer
						mov		cust.nValue,eax
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,2
						invoke SendDlgItemMessage,hTabDlg[12],IDC_GRDCUSTSTYLE,GM_GETCELLDATA,ecx,addr buffer
						invoke HexToDw,addr buffer
						mov		cust.nMask,eax
						inc		nInx
						invoke MakeKey,addr szCustStyle,nInx,addr buffer1
						invoke RegSetValueEx,ha.hReg,addr buffer1,0,REG_BINARY,addr cust,sizeof CUSTSTYLE
						invoke SendMessage,ha.hResEd,DEM_ADDCUSTSTYLE,0,addr cust
					.else
						inc		nInx
						invoke MakeKey,addr szCustStyle,nInx,addr buffer1
						invoke RegDeleteValue,ha.hReg,addr buffer1
					.endif
				.endw
				; Custom types
				invoke GetDlgItem,hTabDlg[16],IDC_GRDRESTYPE
				push	eax
				invoke SendMessage,eax,GM_GETCURSEL,0,0
				pop		edx
				invoke SendMessage,edx,GM_ENDEDIT,eax,FALSE
				invoke SendMessage,ha.hResEd,DEM_CLEARCUSTSTYLE,0,0
				mov		nInx,0
				.while nInx<32
					invoke SendDlgItemMessage,hTabDlg[16],IDC_GRDRESTYPE,GM_GETROWCOUNT,0,0
					.if eax>nInx
						invoke RtlZeroMemory,addr rarstype,sizeof RARSTYPE
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						invoke SendDlgItemMessage,hTabDlg[16],IDC_GRDRESTYPE,GM_GETCELLDATA,ecx,addr buffer
						invoke lstrcpy,addr rarstype.sztype,addr buffer
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,1
						invoke SendDlgItemMessage,hTabDlg[16],IDC_GRDRESTYPE,GM_GETCELLDATA,ecx,addr buffer
						mov		eax,dword ptr buffer
						mov		rarstype.nid,eax
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,2
						invoke SendDlgItemMessage,hTabDlg[16],IDC_GRDRESTYPE,GM_GETCELLDATA,ecx,addr buffer
						invoke lstrcpy,addr rarstype.szext,addr buffer
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,3
						invoke SendDlgItemMessage,hTabDlg[16],IDC_GRDRESTYPE,GM_GETCELLDATA,ecx,addr buffer
						invoke lstrcpy,addr rarstype.szedit,addr buffer
						invoke SendMessage,ha.hResEd,PRO_SETCUSTOMTYPE,nInx,addr rarstype
						inc		nInx
						invoke MakeKey,addr szCustType,nInx,addr buffer1
						invoke RegSetValueEx,ha.hReg,addr buffer1,0,REG_BINARY,addr rarstype,sizeof RARSTYPE
					.else
						inc		nInx
						invoke MakeKey,addr szCustType,nInx,addr buffer1
						invoke RegDeleteValue,ha.hReg,addr buffer1
					.endif
				.endw
				mov		eax,color
				mov		grdsize.color,eax
				invoke RegSetValueEx,ha.hReg,addr szGrid,0,REG_BINARY,addr grdsize,sizeof grdsize
				mov		eax,grdsize.y
				shl		eax,16
				add		eax,grdsize.x
				mov		edx,grdsize.line
				shl		edx,24
				add		edx,grdsize.color
				invoke SendMessage,ha.hResEd,DEM_SETGRIDSIZE,eax,edx
				invoke GetWindowLong,ha.hResEd,GWL_STYLE
				and		eax,-1 xor (DES_GRID or DES_SNAPTOGRID or DES_TOOLTIP or DES_STYLEHEX)
				.if grdsize.show
					or		eax,DES_GRID
				.endif
				.if grdsize.snap
					or		eax,DES_SNAPTOGRID
				.endif
				.if grdsize.tips
					or		eax,DES_TOOLTIP
				.endif
				.if grdsize.stylehex
					or		eax,DES_STYLEHEX
				.endif
				invoke SetWindowLong,ha.hResEd,GWL_STYLE,eax
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
		mov		eax,grdsize.color
		mov		color,eax
		invoke CreateSolidBrush,eax
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
