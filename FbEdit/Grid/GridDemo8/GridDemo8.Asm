.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include GridDemo8.inc
include ..\RAGrid.inc
include DataBase.asm

.code

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax
	invoke LoadLibrary,offset szRAGridDLL
	.if eax
		mov		hRAGridDLL,eax
	    invoke InitCommonControls
		invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
		invoke FreeLibrary,hRAGridDLL
	.endif
	invoke ExitProcess,0

DlgProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	col:COLUMN
	LOCAL	rect:RECT
	LOCAL	rowdta:DWORD
	LOCAL	nRow:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWnd,eax
		invoke GetDlgItem,hWin,IDC_GRD1
		mov		hGrd,eax
		invoke GetDlgItem,hWin,IDC_GRDTABLE
		mov		hGrdTable,eax
		invoke SendMessage,hGrd,GM_SETBACKCOLOR,0C0FFFFh,0
		invoke SendMessage,hGrd,GM_SETGRIDCOLOR,808080h,0
		invoke SendMessage,hGrd,GM_SETTEXTCOLOR,800000h,0
		invoke SendMessage,hGrdTable,GM_SETBACKCOLOR,0C0FFFFh,0
		invoke SendMessage,hGrdTable,GM_SETGRIDCOLOR,808080h,0
		invoke SendMessage,hGrdTable,GM_SETTEXTCOLOR,800000h,0

		;Add Table column
		mov		col.colwt,115
		mov		col.lpszhdrtext,offset szHdrTable
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrdTable,GM_ADDCOL,0,addr col

		invoke SendMessage,hGrd,GM_SETCURSEL,0,0
		invoke SetFocus,hGrd
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		push	rect.right
		sub		rect.right,25
		invoke GetDlgItem,hWin,IDC_BTNDB
		invoke MoveWindow,eax,rect.right,3,21,21,TRUE
		sub		rect.right,60
		invoke GetDlgItem,hWin,IDC_EDTDB
		invoke MoveWindow,eax,60,3,rect.right,22,TRUE
		pop		rect.right
		sub		rect.right,136+3
		sub		rect.bottom,25+3+25+3+25+3
		invoke MoveWindow,hGrdTable,rect.right,25+3,136,rect.bottom,TRUE
		invoke GetClientRect,hWin,addr rect
		invoke GetDlgItem,hWin,IDC_BTNOPEN
		sub		rect.right,3+64+3
		sub		rect.bottom,25+3+25
		invoke MoveWindow,eax,rect.right,rect.bottom,64,22,TRUE

		invoke GetClientRect,hWin,addr rect
		add		rect.left,3
		add		rect.top,25+3
		sub		rect.right,6+136+3
		sub		rect.bottom,3+21+3+25+3
		invoke MoveWindow,hGrd,rect.left,rect.top,rect.right,rect.bottom,TRUE

		invoke GetClientRect,hWin,addr rect
		invoke GetDlgItem,hWin,2
		sub		rect.bottom,22
		sub		rect.right,3
		mov		ecx,rect.bottom
		mov		edx,rect.right
		sub		edx,64
		invoke MoveWindow,eax,edx,ecx,64,21,TRUE
		invoke GetDlgItem,hWin,IDC_BTNTEST
		mov		ecx,rect.bottom
		mov		edx,rect.right
		sub		edx,64+3+64
		invoke MoveWindow,eax,edx,ecx,64,21,TRUE
		invoke GetDlgItem,hWin,IDC_BTNMOVEDOWN
		mov		ecx,rect.bottom
		mov		edx,rect.right
		sub		edx,64+3+64+3+64
		invoke MoveWindow,eax,edx,ecx,64,21,TRUE
		invoke GetDlgItem,hWin,IDC_BTNMOVEUP
		mov		ecx,rect.bottom
		mov		edx,rect.right
		sub		edx,64+3+64+3+64+3+64
		invoke MoveWindow,eax,edx,ecx,64,21,TRUE
		invoke GetDlgItem,hWin,IDC_BTNINSERT
		mov		ecx,rect.bottom
		mov		edx,rect.right
		sub		edx,64+3+64+3+64+3+64+3+64
		invoke MoveWindow,eax,edx,ecx,64,21,TRUE
		invoke GetDlgItem,hWin,IDC_BTNADD
		mov		ecx,rect.bottom
		mov		edx,rect.right
		sub		edx,64+3+64+3+64+3+64+3+64+3+64
		invoke MoveWindow,eax,edx,ecx,64,21,TRUE
		invoke GetDlgItem,hWin,IDC_BTNDEL
		mov		ecx,rect.bottom
		mov		edx,rect.right
		sub		edx,64+3+64+3+64+3+64+3+64+3+64+3+64
		invoke MoveWindow,eax,edx,ecx,64,21,TRUE
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNTEST
			.elseif eax==IDC_BTNMOVEDOWN
			.elseif eax==IDC_BTNMOVEUP
			.elseif eax==IDC_BTNINSERT
			.elseif eax==IDC_BTNADD
			.elseif eax==IDC_BTNDEL
			.elseif eax==IDC_BTNDB
				;Zero out the ofn struct
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				;Setup the ofn struct
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrFilter,offset szFilterMdb
				mov		buffer,0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.lpstrDefExt,NULL
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke ODBCDisconnect
					invoke SetDlgItemText,hWin,IDC_EDTDB,addr buffer
					invoke SendMessage,hGrd,GM_RESETCOLUMNS,0,0
					invoke SendMessage,hGrdTable,GM_RESETCONTENT,0,0
					invoke ODBCConnect,addr buffer
					.if !eax
						invoke ODBCGetTables
						mov		esi,eax
						push	esi
						.while [esi].SQLTABLE.szName
							invoke lstrcmpi,addr [esi].SQLTABLE.szType,offset szHdrTable
							.if !eax
								lea		eax,[esi].SQLTABLE.szName
								mov		rowdta,eax
								invoke SendMessage,hGrdTable,GM_ADDROW,0,addr rowdta
							.endif
							lea		esi,[esi+sizeof SQLTABLE]
						.endw
						pop		esi
						invoke GlobalUnlock,esi
						invoke GlobalFree,esi
						invoke SendMessage,hGrdTable,GM_SETCURSEL,0,0
					.endif
				.endif
			.elseif eax==IDC_BTNOPEN
				invoke SendMessage,hGrdTable,GM_GETROWCOUNT,0,0
				.if eax
					invoke SendMessage,hGrdTable,GM_GETCURROW,0,0
					mov		ecx,eax
					shl		ecx,16
					invoke SendMessage,hGrdTable,GM_GETCELLDATA,ecx,addr szTable
					invoke SendMessage,hGrd,GM_RESETCOLUMNS,0,0
					invoke ODBCGetColumns,addr szTable
					mov		esi,offset dbCols
					.while [esi].SQLCOL.szName
						movsx	eax,[esi].SQLCOL.wType
						mov		col.lParam,eax
						.if eax==SQL_CHAR || eax==SQL_VARCHAR
							mov		col.colwt,150
							lea		eax,[esi].SQLCOL.szName
							mov		col.lpszhdrtext,eax
							mov		col.halign,GA_ALIGN_LEFT
							mov		col.calign,GA_ALIGN_LEFT
							mov		col.ctype,TYPE_EDITTEXT
							mov		col.ctextmax,256
							mov		col.lpszformat,0
							mov		col.himl,0
							mov		col.hdrflag,0
							invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
						.elseif eax==SQL_INTEGER
							mov		col.colwt,60
							.if [esi].SQLCOL.autoinc
								invoke lstrcpy,addr buffer,addr szAutoInc
								invoke lstrcat,addr buffer,addr [esi].SQLCOL.szName
							.else
								lea		eax,[esi].SQLCOL.szName
							.endif
							mov		col.lpszhdrtext,eax
							mov		col.halign,GA_ALIGN_RIGHT
							mov		col.calign,GA_ALIGN_RIGHT
							mov		col.ctype,TYPE_EDITLONG
							mov		col.ctextmax,11
							mov		col.lpszformat,0
							mov		col.himl,0
							mov		col.hdrflag,0
							invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
						.elseif eax==SQL_SMALLINT
							mov		col.colwt,60
							lea		eax,[esi].SQLCOL.szName
							mov		col.lpszhdrtext,eax
							mov		col.halign,GA_ALIGN_RIGHT
							mov		col.calign,GA_ALIGN_RIGHT
							mov		col.ctype,TYPE_EDITLONG
							mov		col.ctextmax,6
							mov		col.lpszformat,0
							mov		col.himl,0
							mov		col.hdrflag,0
							invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
						.elseif eax==SQL_REAL
							mov		col.colwt,60
							lea		eax,[esi].SQLCOL.szName
							mov		col.lpszhdrtext,eax
							mov		col.halign,GA_ALIGN_RIGHT
							mov		col.calign,GA_ALIGN_RIGHT
							mov		col.ctype,TYPE_EDITLONG
							mov		col.ctextmax,11
							mov		col.lpszformat,0
							mov		col.himl,0
							mov		col.hdrflag,0
							invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
						.elseif eax==SQL_NUMERIC
							mov		col.colwt,60
							lea		eax,[esi].SQLCOL.szName
							mov		col.lpszhdrtext,eax
							mov		col.halign,GA_ALIGN_RIGHT
							mov		col.calign,GA_ALIGN_RIGHT
							mov		col.ctype,TYPE_USER
							mov		col.ctextmax,8
							mov		col.lpszformat,0
							mov		col.himl,0
							mov		col.hdrflag,0
							invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
						.elseif eax==SQL_DOUBLE
							mov		col.colwt,60
							lea		eax,[esi].SQLCOL.szName
							mov		col.lpszhdrtext,eax
							mov		col.halign,GA_ALIGN_RIGHT
							mov		col.calign,GA_ALIGN_RIGHT
							mov		col.ctype,TYPE_USER
							mov		col.ctextmax,8
							mov		col.lpszformat,0
							mov		col.himl,0
							mov		col.hdrflag,0
							invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
						.elseif eax==SQL_TYPE_TIMESTAMP
							mov		col.colwt,60
							lea		eax,[esi].SQLCOL.szName
							mov		col.lpszhdrtext,eax
							mov		col.halign,GA_ALIGN_RIGHT
							mov		col.calign,GA_ALIGN_RIGHT
							mov		col.ctype,TYPE_USER
							mov		col.ctextmax,8
							mov		col.lpszformat,0
							mov		col.himl,0
							mov		col.hdrflag,0
							invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
						.elseif eax==SQL_LONGVARCHAR
							mov		col.colwt,150
							lea		eax,[esi].SQLCOL.szName
							mov		col.lpszhdrtext,eax
							mov		col.halign,GA_ALIGN_LEFT
							mov		col.calign,GA_ALIGN_LEFT
							mov		col.ctype,TYPE_EDITTEXT
							mov		col.ctextmax,512
							mov		col.lpszformat,0
							mov		col.himl,0
							mov		col.hdrflag,0
							invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
						.elseif eax==SQL_BIT
							mov		col.colwt,60
							lea		eax,[esi].SQLCOL.szName
							mov		col.lpszhdrtext,eax
							mov		col.halign,GA_ALIGN_CENTER
							mov		col.calign,GA_ALIGN_CENTER
							mov		col.ctype,TYPE_CHECKBOX
							mov		col.ctextmax,0
							mov		col.lpszformat,0
							mov		col.himl,0
							mov		col.hdrflag,0
							invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
						.endif
						lea		esi,[esi+sizeof SQLCOL]
					.endw
					invoke ODBCGetData,addr szTable,offset dbCols
				.endif
			.endif
			invoke SetFocus,hGrd
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_NOTIFY
		mov		esi,lParam
		mov		eax,[esi].NMHDR.hwndFrom
		.if eax==hGrd
			mov		eax,[esi].NMHDR.code
			.if eax==GN_HEADERCLICK
				;Sort the grid by column, invert sorting order
				invoke SendMessage,hGrd,GM_COLUMNSORT,[esi].GRIDNOTIFY.col,SORT_INVERT
;			.elseif eax==GN_BUTTONCLICK
;			.elseif eax==GN_CHECKCLICK
;			.elseif eax==GN_IMAGECLICK
;			.elseif eax==GN_BEFORESELCHANGE
;			.elseif eax==GN_AFTERSELCHANGE
;			.elseif eax==GN_BEFOREEDIT
;			.elseif eax==GN_AFTEREDIT
;			.elseif eax==GN_BEFOREUPDATE
			.elseif eax==GN_BEFOREEDIT
				mov		[esi].GRIDNOTIFY.fcancel,TRUE
;			.elseif eax==GN_AFTERUPDATE
			.elseif eax==GN_USERCONVERT
				invoke SendMessage,hGrd,GM_GETCOLDATA,[esi].GRIDNOTIFY.col,addr col
				mov		eax,col.lParam
				.if eax==SQL_TYPE_TIMESTAMP
					mov		edx,[esi].GRIDNOTIFY.lpdata
					movzx	eax,word ptr [edx]		;Year
					movzx	ecx,word ptr [edx+2]	;Month
					movzx	edx,word ptr [edx+4]	;Day
					.if eax && ecx && edx
						invoke wsprintf,addr buffer,addr szDate,edx,ecx,eax
					.else
						mov		buffer,0
					.endif
					invoke lstrcpy,[esi].GRIDNOTIFY.lpdata,addr buffer
				.elseif eax==SQL_REAL
					mov		ecx,4
					call	HexIt
					invoke lstrcpy,[esi].GRIDNOTIFY.lpdata,addr buffer
				.elseif eax==SQL_DOUBLE
					mov		ecx,8
					call	HexIt
					invoke lstrcpy,[esi].GRIDNOTIFY.lpdata,addr buffer
				.elseif eax==SQL_NUMERIC
					mov		ecx,8
					call	HexIt
					invoke lstrcpy,[esi].GRIDNOTIFY.lpdata,addr buffer
				.endif
			.endif
		.elseif eax==hGrdTable
			mov		eax,[esi].NMHDR.code
			.if eax==GN_HEADERCLICK
				;Sort the grid by column, invert sorting order
				invoke SendMessage,hGrdTable,GM_COLUMNSORT,[esi].GRIDNOTIFY.col,SORT_INVERT
			.elseif eax==GN_BEFOREEDIT
				mov		[esi].GRIDNOTIFY.fcancel,TRUE
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke ODBCDisconnect
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
  Ex:
	ret

HexIt:
	mov		ah,cl
	add		ecx,[esi].GRIDNOTIFY.lpdata
	lea		edx,buffer
	.while ah
		dec		ah
		dec		ecx
		mov		al,[ecx]
		shr		al,4
		or		al,30h
		.if al>'9'
			add		al,7
		.endif
		mov		[edx],al
		inc		edx
		mov		al,[ecx]
		and		al,0Fh
		or		al,30h
		.if al>'9'
			add		al,7
		.endif
		mov		[edx],al
		inc		edx
	.endw
	mov		byte ptr [edx],0
	retn

DlgProc endp

end start
