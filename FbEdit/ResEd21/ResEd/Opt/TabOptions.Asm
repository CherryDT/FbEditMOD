
IDD_TABOPTIONS		equ 2410
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
IDC_STCGRIDCOLOR	equ 4006
IDC_STCBACKCOLOR	equ 4011
IDC_STCTEXTCOLOR	equ 4013
IDC_CHKSNAPGRID		equ 4002
IDC_CHKSHOWGRID		equ 4003
IDC_CHKSHOWTIP		equ 4001
IDC_CHKGRIDLINE		equ 4009
IDC_CHKSTYLEHEX		equ 4010
IDC_CHKSIZETOFONT	equ 4012
IDC_CHKSIMPLE		equ 4015
IDC_CHKIDC_STATIC	equ 4016
IDC_CHKSTANDARD		equ 4017
IDC_CHKBORLANDCOMP	equ 4018
IDC_BTNFONT			equ 4019
IDC_STCFONT			equ 4020
IDC_RBNINCLUDE1		equ 4021
IDC_RBNINCLUDE2		equ 4022
IDC_RBNINCLUDE3		equ 4023

IDD_TABOPT4			equ 2400
IDC_EDTDLGSTART		equ 1001
IDC_EDTDLGINC		equ 1002
IDC_EDTMNUSTART		equ 1003
IDC_EDTMNUINC		equ 1004
IDC_EDTRCDSTART		equ 1006
IDC_EDTRCDINC		equ 1005
IDC_EDTRESSTART		equ 1008
IDC_EDTRESINC		equ 1007

IDD_TABOPT5			equ 2420
IDC_GRDSTYLE		equ 1001
IDC_BTNSTYLEADD		equ 1002
IDC_BTNSTYLEDEL		equ 1003

IDD_TABOPT6			equ 2430
IDC_EDTPROPATH		equ 1004
IDC_BTNPROPATH		equ 1003
IDC_EDTSYSPATH		equ 1001
IDC_BTNSYSPATH		equ 1002

IDD_TABOPT7			equ 2440
IDC_GRDTYPE			equ 1001
IDC_BTNTYPEADD		equ 1002
IDC_BTNTYPEDEL		equ 1003

.const

szNmeExp			db 'NmeExp',0
szCust				db 'Cust#',0
szCustStyle			db 'Style#',0
szFilterDLL			db 'Dll (*.dll)',0,'*.dll',0,0
szFilterEXE			db 'Exe (*.exe)',0,'*.exe',0,0
szGrid				db 'Grid',0
szColor				db 'Color',0
szInitID			db 'InitID',0
szTextFont			db 'TextFont',0
szProPath			db 'ProPath',0
szSysPath			db 'SysPath',0
szCustType			db 'Type#',0

TabTitle1			db 'Exports',0
TabTitle2			db 'Custom controls',0
TabTitle3			db 'Behaviour',0
TabTitle4			db "Resource ID's",0
TabTitle5			db 'Custom styles',0
TabTitle6			db 'Paths',0
TabTitle7			db 'Resource types',0

szHdrCust			db 'Custom control',0
szHdrCustMask		db 'Style mask',0

szHdrStyle			db 'Style',0
szHdrVal			db 'Value',0
szHdrMask			db 'Mask',0

szHdrName			db 'Name',0
szHdrFiles			db 'Files',0
szHdrEdit			db 'Editor',0

szBrowse			db 'Browse For Folder',0

.data?

hTab				dd ?
hTabDlg				dd 7 dup(?)
SelTab				dd ?
gridcolor			dd ?
backcolor			dd ?
textcolor			dd ?
hBrGrid				dd ?
hBrBack				dd ?
hBrText				dd ?
CustColors			dd 16 dup(?)
cflf				LOGFONT <>
hfnt				HFONT ?

.code

BrowseCallbackProc proc hwnd:DWORD,uMsg:UINT,lParam:LPARAM,lpData:DWORD

	mov eax,uMsg
	.if eax==BFFM_INITIALIZED
		invoke PostMessage,hwnd,BFFM_SETSELECTION,TRUE,lpData
		invoke PostMessage,hwnd,BFFM_SETSTATUSTEXT,0,addr szBrowse
	.endif
	xor eax, eax
	ret

BrowseCallbackProc endp

ConvertDpiSize proc nPix:DWORD
	LOCAL	lpx:DWORD

	invoke GetDC,NULL
	push	eax
	invoke GetDeviceCaps,eax,LOGPIXELSX
	mov		lpx,eax
	pop		eax
	invoke ReleaseDC,NULL,eax
	mov		eax,nPix
	shl		eax,16
	cdq
	mov		ecx,96
	div		ecx
	mov		ecx,lpx
	mul		ecx
	shr		eax,16
	ret

ConvertDpiSize endp

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
			invoke RegQueryValueEx,hReg,addr buffer1,0,addr lpType,addr buffer,addr lpcbData
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
				push	hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrInitialDir,NULL
				mov		ofn.lpstrFilter,offset szFilterDLL
				mov		ofn.lpstrDefExt,0
				mov		ofn.lpstrTitle,0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				invoke lstrcpy,eax,[esi].GRIDNOTIFY.lpdata
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				.if eax
					mov		edx,[esi].GRIDNOTIFY.lpdata
					invoke lstrcpy,edx,addr buffer
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
	LOCAL	cf:CHOOSEFONT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_UDNX,UDM_SETRANGE,0,00020014h	; Set range
		invoke SendDlgItemMessage,hWin,IDC_UDNX,UDM_SETPOS,0,grdsize.x		; Set default value
		invoke SendDlgItemMessage,hWin,IDC_UDNY,UDM_SETRANGE,0,00020014h	; Set range
		invoke SendDlgItemMessage,hWin,IDC_UDNY,UDM_SETPOS,0,grdsize.y		; Set default value
		invoke SendDlgItemMessage,hWin,IDC_STCFONT,WM_SETFONT,hfnt,FALSE
		invoke CheckDlgButton,hWin,IDC_CHKSHOWGRID,grdsize.show
		invoke CheckDlgButton,hWin,IDC_CHKSNAPGRID,grdsize.snap
		invoke CheckDlgButton,hWin,IDC_CHKSHOWTIP,grdsize.tips
		invoke CheckDlgButton,hWin,IDC_CHKGRIDLINE,grdsize.line
		invoke CheckDlgButton,hWin,IDC_CHKSTYLEHEX,grdsize.stylehex
		invoke CheckDlgButton,hWin,IDC_CHKSIZETOFONT,grdsize.sizetofont
		mov		eax,grdsize.defines
		.if !eax
			invoke CheckDlgButton,hWin,IDC_RBNINCLUDE1,TRUE
		.elseif eax==1
			invoke CheckDlgButton,hWin,IDC_RBNINCLUDE2,TRUE
		.elseif eax==2
			invoke CheckDlgButton,hWin,IDC_RBNINCLUDE3,TRUE
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKSIMPLE,grdsize.simple
		invoke CheckDlgButton,hWin,IDC_CHKIDC_STATIC,grdsize.defstatic
		invoke CheckDlgButton,hWin,IDC_CHKSTANDARD,grdsize.standardmnu
		invoke CheckDlgButton,hWin,IDC_CHKBORLANDCOMP,grdsize.borlandcomp
	.elseif eax==WM_DRAWITEM
		mov		eax,wParam
		.if eax==IDC_STCGRIDCOLOR
			mov		eax,hBrGrid
		.elseif eax==IDC_STCBACKCOLOR
			mov		eax,hBrBack
		.elseif eax==IDC_STCTEXTCOLOR
			mov		eax,hBrText
		.endif
		mov		edx,lParam
		invoke FillRect,[edx].DRAWITEMSTRUCT.hdc,addr [edx].DRAWITEMSTRUCT.rcItem,eax
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		movzx	eax,ax
		.if edx==BN_CLICKED
			.if eax==IDC_STCGRIDCOLOR
				mov		eax,gridcolor
				call	GetColor
				.if eax
					invoke DeleteObject,hBrGrid
					mov		eax,cc.rgbResult
					mov		gridcolor,eax
					invoke CreateSolidBrush,eax
					mov		hBrGrid,eax
					invoke GetDlgItem,hWin,IDC_STCGRIDCOLOR
					invoke InvalidateRect,eax,NULL,TRUE
				.endif
			.elseif eax==IDC_STCBACKCOLOR
				mov		eax,backcolor
				call	GetColor
				.if eax
					invoke DeleteObject,hBrBack
					mov		eax,cc.rgbResult
					mov		backcolor,eax
					invoke CreateSolidBrush,eax
					mov		hBrBack,eax
					invoke GetDlgItem,hWin,IDC_STCBACKCOLOR
					invoke InvalidateRect,eax,NULL,TRUE
				.endif
			.elseif eax==IDC_STCTEXTCOLOR
				mov		eax,textcolor
				call	GetColor
				.if eax
					invoke DeleteObject,hBrText
					mov		eax,cc.rgbResult
					mov		textcolor,eax
					invoke CreateSolidBrush,eax
					mov		hBrText,eax
					invoke GetDlgItem,hWin,IDC_STCTEXTCOLOR
					invoke InvalidateRect,eax,NULL,TRUE
				.endif
			.elseif eax==IDC_BTNFONT
				mov		cf.lStructSize,sizeof CHOOSEFONT
				invoke GetDC,hWin
				mov		cf.hDC,eax
				push	hWin
				pop		cf.hWndOwner
				mov		cf.lpLogFont,offset cflf
				mov		cf.iPointSize,0
				mov		cf.Flags,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT
				mov		cf.rgbColors,0
				mov		cf.lCustData,0
				mov		cf.lpfnHook,0
				mov		cf.lpTemplateName,0
				mov		cf.hInstance,0
				mov		cf.lpszStyle,0
				mov		cf.nFontType,0
				mov		cf.Alignment,0
				mov		cf.nSizeMin,0
				mov		cf.nSizeMax,0
				invoke ChooseFont,addr cf
				push	eax
				invoke ReleaseDC,hWin,cf.hDC
				pop		eax
				.if eax
					invoke DeleteObject,hfnt
					invoke CreateFontIndirect,addr cflf
					mov		hfnt,eax
					invoke SendDlgItemMessage,hWin,IDC_STCFONT,WM_SETFONT,hfnt,TRUE
				.endif
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

GetColor:
	mov		cc.lStructSize,sizeof CHOOSECOLOR
	mov		cc.rgbResult,eax
	mov		eax,hWin
	mov		cc.hwndOwner,eax
	mov		eax,hInstance
	mov		cc.hInstance,eax
	mov		cc.lpCustColors,offset CustColors
	mov		cc.Flags,CC_FULLOPEN or CC_RGBINIT
	mov		cc.lCustData,0
	mov		cc.lpfnHook,0
	mov		cc.lpTemplateName,0
	invoke ChooseColor,addr cc
	retn

TabOpt3Proc endp

TabOpt4Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetDlgItemInt,hWin,IDC_EDTDLGSTART,initid.dlg.startid,FALSE
		invoke SetDlgItemInt,hWin,IDC_EDTDLGINC,initid.dlg.incid,FALSE
		invoke SetDlgItemInt,hWin,IDC_EDTMNUSTART,initid.mnu.startid,FALSE
		invoke SetDlgItemInt,hWin,IDC_EDTMNUINC,initid.mnu.incid,FALSE
		invoke SetDlgItemInt,hWin,IDC_EDTRCDSTART,initid.rcd.startid,FALSE
		invoke SetDlgItemInt,hWin,IDC_EDTRCDINC,initid.rcd.incid,FALSE
		invoke SetDlgItemInt,hWin,IDC_EDTRESSTART,initid.res.startid,FALSE
		invoke SetDlgItemInt,hWin,IDC_EDTRESINC,initid.res.incid,FALSE
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TabOpt4Proc endp

TabOpt5Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hGrd:HWND
	LOCAL	clmn:COLUMN
	LOCAL	nInx:DWORD
	LOCAL	cust:CUSTSTYLE
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	row[3]:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_GRDSTYLE
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
			invoke RegQueryValueEx,hReg,addr buffer,0,addr lpType,addr cust,addr lpcbData
			.if cust.szStyle
				lea		eax,cust.szStyle
				mov		row[0],eax
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
		invoke GetDlgItem,hWin,IDC_GRDSTYLE
		mov		hGrd,eax
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_BTNSTYLEADD
				invoke SendMessage,hGrd,GM_ADDROW,0,NULL
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
			.elseif eax==IDC_BTNSTYLEDEL
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

TabOpt5Proc endp

TabOpt6Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	bri:BROWSEINFO
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetDlgItemText,hWin,IDC_EDTPROPATH,addr ProjectPath
		invoke SetDlgItemText,hWin,IDC_EDTSYSPATH,addr SystemPath
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_BTNPROPATH
				xor		eax,eax
				mov		bri.pidlRoot,eax
				mov		bri.pszDisplayName,eax
				mov		bri.lpszTitle,eax
				mov		bri.ulFlags,BIF_RETURNONLYFSDIRS or BIF_STATUSTEXT 
				mov		bri.lpfn,BrowseCallbackProc
				invoke GetDlgItemText,hWin,IDC_EDTPROPATH,addr buffer,sizeof buffer
				lea		eax,buffer
				mov		bri.lParam,eax 
				mov		bri.iImage,0
				mov		eax,hWin
				mov		bri.hwndOwner,eax
				invoke SHBrowseForFolder,addr bri
				.if eax
					mov		edx,eax
					invoke SHGetPathFromIDList,edx,addr buffer
					invoke SetDlgItemText,hWin,IDC_EDTPROPATH,addr buffer
				.endif
			.elseif eax==IDC_BTNSYSPATH
				xor		eax,eax
				mov		bri.pidlRoot,eax
				mov		bri.pszDisplayName,eax
				mov		bri.lpszTitle,eax
				mov		bri.ulFlags,BIF_RETURNONLYFSDIRS or BIF_STATUSTEXT 
				mov		bri.lpfn,BrowseCallbackProc
				invoke GetDlgItemText,hWin,IDC_EDTSYSPATH,addr buffer,sizeof buffer
				lea		eax,buffer
				mov		bri.lParam,eax 
				mov		bri.iImage,0
				mov		eax,hWin
				mov		bri.hwndOwner,eax
				invoke SHBrowseForFolder,addr bri
				.if eax
					mov		edx,eax
					invoke SHGetPathFromIDList,edx,addr buffer
					invoke SetDlgItemText,hWin,IDC_EDTSYSPATH,addr buffer
				.endif
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TabOpt6Proc endp

TabOpt7Proc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hGrd:HWND
	LOCAL	clmn:COLUMN
	LOCAL	ofn:OPENFILENAME
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	row[4]:DWORD
	LOCAL	rarstype:RARSTYPE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_GRDTYPE
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
			invoke RegQueryValueEx,hReg,addr buffer,0,addr lpType,addr rarstype,addr lpcbData
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
				invoke SendMessage,hResEd,PRO_GETCUSTOMTYPE,edx,0
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
		invoke GetDlgItem,hWin,IDC_GRDTYPE
		mov		hGrd,eax
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_BTNTYPEADD
				invoke SendMessage,hGrd,GM_ADDROW,0,NULL
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
			.elseif eax==IDC_BTNTYPEDEL
				invoke SendMessage,hGrd,GM_GETCURROW,0,0
				push	eax
				invoke SendMessage,hGrd,GM_DELROW,eax,0
				pop		eax
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		invoke GetDlgItem,hWin,IDC_GRDTYPE
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
				push	hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrInitialDir,NULL
				mov		ofn.lpstrFilter,offset szFilterEXE
				mov		ofn.lpstrDefExt,0
				mov		ofn.lpstrTitle,0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				invoke lstrcpy,eax,[esi].GRIDNOTIFY.lpdata
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				.if eax
					mov		edx,[esi].GRIDNOTIFY.lpdata
					invoke lstrcpy,edx,addr buffer
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
					invoke GetDlgItem,hWin,IDC_BTNTYPEDEL
					invoke EnableWindow,eax,FALSE
				.else
					invoke GetDlgItem,hWin,IDC_BTNTYPEDEL
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

TabOpt7Proc endp

TabOptionsProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ts:TCITEM
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
				invoke DeleteObject,hfnt
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==IDOK
				invoke GetDlgItem,hTabDlg[4],IDC_GRDCUST
				push	eax
				invoke SendMessage,eax,GM_GETCURSEL,0,0
				pop		edx
				invoke SendMessage,edx,GM_ENDEDIT,eax,FALSE
				invoke GetDlgItem,hTabDlg[16],IDC_GRDSTYLE
				push	eax
				invoke SendMessage,eax,GM_GETCURSEL,0,0
				pop		edx
				invoke SendMessage,edx,GM_ENDEDIT,eax,FALSE
				invoke GetDlgItem,hTabDlg[24],IDC_GRDTYPE
				push	eax
				invoke SendMessage,eax,GM_GETCURSEL,0,0
				pop		edx
				invoke SendMessage,edx,GM_ENDEDIT,eax,FALSE
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
							invoke IsDlgButtonChecked,hTabDlg,IDC_RBNEXPOPT4
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
				invoke RegSetValueEx,hReg,addr szNmeExp,0,REG_BINARY,addr nmeexp,sizeof nmeexp
				mov		edx,nmeexp.nOutput
				shl		edx,16
				add		edx,nmeexp.nType
				invoke SendMessage,hResEd,PRO_SETEXPORT,edx,addr nmeexp.szFileName
				; Custom controls
				mov		nInx,0
				.while nInx<32
					invoke SendDlgItemMessage,hTabDlg[4],IDC_GRDCUST,GM_GETROWCOUNT,0,0
					.if eax>nInx
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						invoke SendDlgItemMessage,hTabDlg[4],IDC_GRDCUST,GM_GETCELLDATA,ecx,addr buffer
						invoke lstrcat,addr buffer,addr szComma
						invoke lstrlen,addr buffer
						mov		ecx,nInx
						shl		ecx,16
						or		ecx,1
						invoke SendDlgItemMessage,hTabDlg[4],IDC_GRDCUST,GM_GETCELLDATA,ecx,addr buffer[eax]
						inc		nInx
						invoke MakeKey,addr szCust,nInx,addr buffer1
						invoke lstrlen,addr buffer
						inc		eax
						invoke RegSetValueEx,hReg,addr buffer1,0,REG_SZ,addr buffer,eax
					.else
						inc		nInx
						invoke MakeKey,addr szCust,nInx,addr buffer1
						invoke RegDeleteValue,hReg,addr buffer1
					.endif
				.endw
				invoke SendMessage,hResEd,DEM_CLEARCUSTSTYLE,0,0
				; Custom styles
				mov		nInx,0
				.while nInx<64
					invoke SendDlgItemMessage,hTabDlg[16],IDC_GRDSTYLE,GM_GETROWCOUNT,0,0
					.if eax>nInx
						invoke RtlZeroMemory,addr cust,sizeof CUSTSTYLE
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						invoke SendDlgItemMessage,hTabDlg[16],IDC_GRDSTYLE,GM_GETCELLDATA,ecx,addr buffer
						invoke lstrcpy,addr cust.szStyle,addr buffer
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,1
						invoke SendDlgItemMessage,hTabDlg[16],IDC_GRDSTYLE,GM_GETCELLDATA,ecx,addr buffer
						invoke HexToDw,addr buffer
						mov		cust.nValue,eax
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,2
						invoke SendDlgItemMessage,hTabDlg[16],IDC_GRDSTYLE,GM_GETCELLDATA,ecx,addr buffer
						invoke HexToDw,addr buffer
						mov		cust.nMask,eax
						inc		nInx
						invoke MakeKey,addr szCustStyle,nInx,addr buffer1
						invoke RegSetValueEx,hReg,addr buffer1,0,REG_BINARY,addr cust,sizeof CUSTSTYLE
						invoke SendMessage,hResEd,DEM_ADDCUSTSTYLE,0,addr cust
					.else
						inc		nInx
						invoke MakeKey,addr szCustStyle,nInx,addr buffer1
						invoke RegDeleteValue,hReg,addr buffer1
					.endif
				.endw
				; Custom types
				mov		nInx,0
				.while nInx<32
					invoke SendDlgItemMessage,hTabDlg[24],IDC_GRDTYPE,GM_GETROWCOUNT,0,0
					.if eax>nInx
						invoke RtlZeroMemory,addr rarstype,sizeof RARSTYPE
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						invoke SendDlgItemMessage,hTabDlg[24],IDC_GRDTYPE,GM_GETCELLDATA,ecx,addr buffer
						invoke lstrcpy,addr rarstype.sztype,addr buffer
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,1
						invoke SendDlgItemMessage,hTabDlg[24],IDC_GRDTYPE,GM_GETCELLDATA,ecx,addr buffer
						mov		eax,dword ptr buffer
						mov		rarstype.nid,eax
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,2
						invoke SendDlgItemMessage,hTabDlg[24],IDC_GRDTYPE,GM_GETCELLDATA,ecx,addr buffer
						invoke lstrcpy,addr rarstype.szext,addr buffer
						mov		buffer,0
						mov		ecx,nInx
						shl		ecx,16
						add		ecx,3
						invoke SendDlgItemMessage,hTabDlg[24],IDC_GRDTYPE,GM_GETCELLDATA,ecx,addr buffer
						invoke lstrcpy,addr rarstype.szedit,addr buffer
						invoke SendMessage,hResEd,PRO_SETCUSTOMTYPE,nInx,addr rarstype
						inc		nInx
						invoke MakeKey,addr szCustType,nInx,addr buffer1
						invoke RegSetValueEx,hReg,addr buffer1,0,REG_BINARY,addr rarstype,sizeof RARSTYPE
					.else
						inc		nInx
						invoke MakeKey,addr szCustType,nInx,addr buffer1
						invoke RegDeleteValue,hReg,addr buffer1
					.endif
				.endw
				invoke GetDlgItemInt,hTabDlg[8],IDC_EDTX,NULL,FALSE
				mov		grdsize.x,eax
				invoke GetDlgItemInt,hTabDlg[8],IDC_EDTY,NULL,FALSE
				mov		grdsize.y,eax
				invoke IsDlgButtonChecked,hTabDlg[8],IDC_CHKSHOWGRID
				mov		grdsize.show,eax
				invoke IsDlgButtonChecked,hTabDlg[8],IDC_CHKSNAPGRID
				mov		grdsize.snap,eax
				invoke IsDlgButtonChecked,hTabDlg[8],IDC_CHKSHOWTIP
				mov		grdsize.tips,eax
				invoke IsDlgButtonChecked,hTabDlg[8],IDC_CHKGRIDLINE
				mov		grdsize.line,eax
				invoke IsDlgButtonChecked,hTabDlg[8],IDC_CHKSTYLEHEX
				mov		grdsize.stylehex,eax
				mov		eax,gridcolor
				mov		grdsize.color,eax
				invoke IsDlgButtonChecked,hTabDlg[8],IDC_CHKSIZETOFONT
				mov		grdsize.sizetofont,eax
				invoke IsDlgButtonChecked,hTabDlg[8],IDC_RBNINCLUDE1
				.if eax
					xor		eax,eax
				.else
					invoke IsDlgButtonChecked,hTabDlg[8],IDC_RBNINCLUDE2
					.if eax
						mov		eax,1
					.else
						mov		eax,2
					.endif
				.endif
				mov		grdsize.defines,eax
				invoke IsDlgButtonChecked,hTabDlg[8],IDC_CHKSIMPLE
				mov		grdsize.simple,eax
				invoke IsDlgButtonChecked,hTabDlg[8],IDC_CHKIDC_STATIC
				mov		grdsize.defstatic,eax
				invoke IsDlgButtonChecked,hTabDlg[8],IDC_CHKSTANDARD
				mov		grdsize.standardmnu,eax
				invoke IsDlgButtonChecked,hTabDlg[8],IDC_CHKBORLANDCOMP
				mov		grdsize.borlandcomp,eax
				invoke RegSetValueEx,hReg,addr szGrid,0,REG_BINARY,addr grdsize,sizeof grdsize
				mov		eax,grdsize.y
				shl		eax,16
				add		eax,grdsize.x
				mov		edx,grdsize.line
				shl		edx,24
				add		edx,grdsize.color
				invoke SendMessage,hResEd,DEM_SETGRIDSIZE,eax,edx
				mov		eax,backcolor
				mov		col.back,eax
				mov		eax,textcolor
				mov		col.text,eax
				invoke RegSetValueEx,hReg,addr szColor,0,REG_BINARY,addr col,sizeof col
				invoke SendMessage,hResEd,DEM_SETCOLOR,0,addr col
				invoke GetDlgItemInt,hTabDlg[12],IDC_EDTDLGSTART,NULL,FALSE
				mov		initid.dlg.startid,eax
				invoke GetDlgItemInt,hTabDlg[12],IDC_EDTDLGINC,NULL,FALSE
				mov		initid.dlg.incid,eax
				invoke GetDlgItemInt,hTabDlg[12],IDC_EDTMNUSTART,NULL,FALSE
				mov		initid.mnu.startid,eax
				invoke GetDlgItemInt,hTabDlg[12],IDC_EDTMNUINC,NULL,FALSE
				mov		initid.mnu.incid,eax
				invoke GetDlgItemInt,hTabDlg[12],IDC_EDTRCDSTART,NULL,FALSE
				mov		initid.rcd.startid,eax
				invoke GetDlgItemInt,hTabDlg[12],IDC_EDTRCDINC,NULL,FALSE
				mov		initid.rcd.incid,eax
				invoke GetDlgItemInt,hTabDlg[12],IDC_EDTRESSTART,NULL,FALSE
				mov		initid.res.startid,eax
				invoke GetDlgItemInt,hTabDlg[12],IDC_EDTRESINC,NULL,FALSE
				mov		initid.res.incid,eax
				invoke RegSetValueEx,hReg,addr szInitID,0,REG_BINARY,addr initid,sizeof initid
				invoke SendMessage,hResEd,PRO_SETINITID,0,addr initid
				invoke lstrcpy,addr textfont.lfFaceName,addr cflf.lfFaceName
				mov		eax,cflf.lfHeight
				mov		textfont.lfHeight,eax
				mov		eax,cflf.lfWeight
				mov		textfont.lfWeight,eax
				movzx	eax,cflf.lfItalic
				mov		textfont.lfItalic,eax
				movzx	eax,cflf.lfCharSet
				mov		textfont.lfCharSet,eax
				invoke RegSetValueEx,hReg,addr szTextFont,0,REG_BINARY,addr textfont,sizeof textfont
				invoke SendMessage,hResEd,PRO_SETTEXTFONT,hfnt,0
				invoke GetWindowLong,hResEd,GWL_STYLE
				and		eax,-1 xor (DES_GRID or DES_SNAPTOGRID or DES_TOOLTIP or DES_STYLEHEX or DES_SIZETOFONT or DES_NODEFINES or DES_SIMPLEPROPERTY or DES_DEFIDC_STATIC or DES_BORLAND)
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
				.if grdsize.sizetofont
					or		eax,DES_SIZETOFONT
				.endif
				.if grdsize.defines
					or		eax,DES_NODEFINES
				.endif
				.if grdsize.simple
					or		eax,DES_SIMPLEPROPERTY
				.endif
				.if grdsize.defstatic
					or		eax,DES_DEFIDC_STATIC
				.endif
				.if grdsize.borlandcomp
					or		eax,DES_BORLAND
				.endif
				invoke SetWindowLong,hResEd,GWL_STYLE,eax
				invoke ResetMenu
				invoke GetDlgItemText,hTabDlg[20],IDC_EDTPROPATH,addr ProjectPath,sizeof ProjectPath
				invoke lstrlen,addr ProjectPath
				inc		eax
				invoke RegSetValueEx,hReg,addr szProPath,0,REG_SZ,addr ProjectPath,eax
				invoke GetDlgItemText,hTabDlg[20],IDC_EDTSYSPATH,addr SystemPath,sizeof SystemPath
				invoke lstrlen,addr SystemPath
				inc		eax
				invoke RegSetValueEx,hReg,addr szSysPath,0,REG_SZ,addr SystemPath,eax
				invoke SendMessage,hResEd,PRO_SETSYSTEMPATH,0,addr SystemPath
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		eax,lParam
		mov		eax,[eax].NMHDR.code
		.if eax==TCN_SELCHANGE
			;Tab selection
			invoke SendMessage,hTab,TCM_GETCURSEL,0,0
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
		mov		gridcolor,eax
		invoke CreateSolidBrush,eax
		mov		hBrGrid,eax
		mov		eax,col.back
		mov		backcolor,eax
		invoke CreateSolidBrush,eax
		mov		hBrBack,eax
		mov		eax,col.text
		mov		textcolor,eax
		invoke CreateSolidBrush,eax
		mov		hBrText,eax
		invoke SendMessage,hResEd,PRO_GETTEXTFONT,0,0
		invoke GetObject,eax,sizeof cflf,addr cflf
		invoke CreateFontIndirect,addr cflf
		mov		hfnt,eax
		;Create the tabs
		invoke GetDlgItem,hWin,IDC_TABOPT
		mov		hTab,eax
		mov		ts.imask,TCIF_TEXT
		mov		ts.iImage,-1
		mov		ts.lParam,0
		mov		ts.pszText,offset TabTitle1
		mov		ts.cchTextMax,sizeof TabTitle1
		invoke SendMessage,hTab,TCM_INSERTITEM,0,addr ts
		mov		ts.pszText,offset TabTitle2
		mov		ts.cchTextMax,sizeof TabTitle2
		invoke SendMessage,hTab,TCM_INSERTITEM,1,addr ts
		mov		ts.pszText,offset TabTitle3
		mov		ts.cchTextMax,sizeof TabTitle3
		invoke SendMessage,hTab,TCM_INSERTITEM,2,addr ts
		mov		ts.pszText,offset TabTitle4
		mov		ts.cchTextMax,sizeof TabTitle4
		invoke SendMessage,hTab,TCM_INSERTITEM,3,addr ts
		mov		ts.pszText,offset TabTitle5
		mov		ts.cchTextMax,sizeof TabTitle5
		invoke SendMessage,hTab,TCM_INSERTITEM,4,addr ts
		mov		ts.pszText,offset TabTitle6
		mov		ts.cchTextMax,sizeof TabTitle6
		invoke SendMessage,hTab,TCM_INSERTITEM,5,addr ts
		mov		ts.pszText,offset TabTitle7
		mov		ts.cchTextMax,sizeof TabTitle7
		invoke SendMessage,hTab,TCM_INSERTITEM,6,addr ts
		;Create the tab dialogs
		invoke CreateDialogParam,hInstance,IDD_TABOPT1,hTab,addr TabOpt1Proc,0
		mov		hTabDlg,eax
		invoke CreateDialogParam,hInstance,IDD_TABOPT2,hTab,addr TabOpt2Proc,0
		mov		hTabDlg[4],eax
		invoke CreateDialogParam,hInstance,IDD_TABOPT3,hTab,addr TabOpt3Proc,0
		mov		hTabDlg[8],eax
		invoke CreateDialogParam,hInstance,IDD_TABOPT4,hTab,addr TabOpt4Proc,0
		mov		hTabDlg[12],eax
		invoke CreateDialogParam,hInstance,IDD_TABOPT5,hTab,addr TabOpt5Proc,0
		mov		hTabDlg[16],eax
		invoke CreateDialogParam,hInstance,IDD_TABOPT6,hTab,addr TabOpt6Proc,0
		mov		hTabDlg[20],eax
		invoke CreateDialogParam,hInstance,IDD_TABOPT7,hTab,addr TabOpt7Proc,0
		mov		hTabDlg[24],eax
		mov		SelTab,0
	.elseif eax==WM_CLOSE
		invoke DeleteObject,hBrGrid
		invoke DeleteObject,hBrBack
		invoke DeleteObject,hBrText
		invoke DestroyWindow,hTabDlg
		invoke DestroyWindow,hTabDlg[4]
		invoke DestroyWindow,hTabDlg[8]
		invoke DestroyWindow,hTabDlg[12]
		invoke DestroyWindow,hTabDlg[16]
		invoke DestroyWindow,hTabDlg[20]
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TabOptionsProc endp
