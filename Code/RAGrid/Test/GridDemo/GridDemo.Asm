.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include GridDemo.inc
include ..\RAGrid.inc

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

;--------------------------------------------------------------------------------

IPAddressProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hDC:HDC
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_NCPAINT
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.left
		sub		rect.right,eax
		mov		rect.left,0
		mov		eax,rect.top
		sub		rect.bottom,eax
		mov		rect.top,0
		invoke GetWindowDC,hWin
		mov		hDC,eax
		invoke GetStockObject,BLACK_BRUSH
		invoke FrameRect,hDC,addr rect,eax
		inc		rect.left
		inc		rect.top
		dec		rect.right
		dec		rect.bottom
		invoke GetSysColor,COLOR_WINDOW
		invoke CreateSolidBrush,eax
		push	eax
		invoke FrameRect,hDC,addr rect,eax
		pop		eax
		invoke DeleteObject,eax
		invoke ReleaseDC,hWin,hDC
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_SHOWWINDOW
		.if !wParam && !fFlag
			;The flag is needed since the GM_ENDEDIT also hides the control
			mov		fFlag,TRUE
			invoke GetWindowLong,hWin,GWL_ID
			invoke SendMessage,hGrd,GM_ENDEDIT,eax,FALSE
		.elseif wParam
			mov		fFlag,FALSE
		.endif
	.endif
	invoke CallWindowProc,OldIPAddressProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

IPAddressProc endp

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	col:COLUMN
	LOCAL	rect:RECT
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	val:DWORD
	LOCAL	rowcol:ROWCOLOR

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWnd,eax
		invoke GetDlgItem,hWin,IDC_GRD1
		mov		hGrd,eax
		invoke SendMessage,hGrd,GM_SETBACKCOLOR,0C0FFFFh,0
		invoke SendMessage,hGrd,GM_SETGRIDCOLOR,808080h,0
		invoke SendMessage,hGrd,GM_SETTEXTCOLOR,800000h,0
;		invoke SendMessage,hGrd,GM_SETHDRHEIGHT,0,22
;		invoke SendMessage,hGrd,GM_SETROWHEIGHT,0,22
		;Image column
		invoke ImageList_Create,15,15,ILC_COLOR24 or ILC_MASK,8,8
		mov		hIml,eax
		invoke LoadBitmap,hInstance,IDB_BITMAP
		push	eax
		invoke ImageList_AddMasked,hIml,eax,0FFFFFFh
		pop		eax
		invoke DeleteObject,eax
		mov		col.colwt,19
		mov		col.lpszhdrtext,NULL
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_CENTER
		mov		col.ctype,TYPE_IMAGE
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		eax,hIml
		mov		col.himl,eax
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

;		;Text column
;		mov		col.colwt,130
;		mov		col.lpszhdrtext,offset szName
;		mov		col.halign,GA_ALIGN_LEFT
;		mov		col.calign,GA_ALIGN_LEFT
;		mov		col.ctype,TYPE_EDITTEXT
;		mov		col.ctextmax,31
;		mov		col.lpszformat,0
;		mov		col.himl,0
;		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;EditCombobox column
		mov		col.colwt,130
		mov		col.lpszhdrtext,offset szName
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITCOMBOBOX
		mov		col.ctextmax,31
		mov		col.lpszformat,0
		mov		col.himl,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Fill in some data in the combo
		push	esi
		mov		esi,offset szComboBoxText
		.while TRUE
			invoke lstrlen,esi
			.if eax
				push	eax
				invoke SendMessage,hGrd,GM_COMBOADDSTRING,1,esi
				pop		eax
				lea		esi,[esi+eax+1]
			.else
				.break
			.endif
		.endw
		pop		esi

		;Number column
		mov		col.colwt,42
		mov		col.lpszhdrtext,offset szID
		mov		col.halign,GA_ALIGN_RIGHT
		mov		col.calign,GA_ALIGN_RIGHT
		mov		col.ctype,TYPE_EDITLONG
		mov		col.ctextmax,11
		mov		col.lpszformat,offset szFormat
		mov		col.himl,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;Hotkey column
		mov		col.colwt,118
		mov		col.lpszhdrtext,offset szAccel
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_HOTKEY
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;Checkbox column
		mov		col.colwt,40
		mov		col.lpszhdrtext,offset szCheck
		mov		col.halign,GA_ALIGN_CENTER
		mov		col.calign,GA_ALIGN_CENTER
		mov		col.ctype,TYPE_CHECKBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;Combobox column
		mov		col.colwt,130
		mov		col.lpszhdrtext,offset szImageCombo
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_COMBOBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		;To create image combo, just add an image list
		mov		eax,hIml
		mov		col.himl,eax
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Fill in some data in the combo
		push	esi
		mov		esi,offset szComboBoxText
		.while TRUE
			invoke lstrlen,esi
			.if eax
				push	eax
				invoke SendMessage,hGrd,GM_COMBOADDSTRING,5,esi
				pop		eax
				lea		esi,[esi+eax+1]
			.else
				.break
			.endif
		.endw
		pop		esi

		;Button column
		mov		col.colwt,130
		mov		col.lpszhdrtext,offset szButton
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_BUTTON
		mov		col.ctextmax,MAX_PATH
		mov		col.lpszformat,0
		mov		col.himl,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;Date column
		mov		col.colwt,80
		mov		col.lpszhdrtext,offset szDate
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_DATE
		mov		col.ctextmax,0
		mov		col.lpszformat,0;offset szDateFormat
		mov		col.himl,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;Time column
		mov		col.colwt,80
		mov		col.lpszhdrtext,offset szTime
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_TIME
		mov		col.ctextmax,0
		mov		col.lpszformat,0;offset szTimeFormat
		mov		col.himl,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;IPAddress column (TYPE_USER)
		invoke CreateWindowEx,NULL,offset szIPAddressClass,NULL,WS_CHILD,0,0,90,19,hGrd,0,hInstance,0
		mov		col.edthwnd,eax
		invoke SetWindowLong,eax,GWL_WNDPROC,offset IPAddressProc
		mov		OldIPAddressProc,eax
		mov		col.colwt,90
		mov		col.lpszhdrtext,offset szIPAddress
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_USER
		mov		col.ctextmax,4
		mov		col.lpszformat,0
		mov		col.himl,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;EditButton column
		mov		col.colwt,130
		mov		col.lpszhdrtext,offset szEditButton
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITBUTTON
		mov		col.ctextmax,MAX_PATH
		mov		col.lpszformat,0
		mov		col.himl,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		call	AddData

		invoke SetFocus,hGrd
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		add		rect.left,3
		add		rect.top,3
		sub		rect.right,6
		sub		rect.bottom,3+21+3
		invoke MoveWindow,hGrd,rect.left,rect.top,rect.right,rect.bottom,TRUE
		invoke GetDlgItem,hWin,2
		mov		ecx,rect.bottom
		mov		edx,rect.right
		add		ecx,6
		sub		edx,64
		invoke MoveWindow,eax,edx,ecx,64,21,TRUE
		invoke GetDlgItem,hWin,IDC_BTNTEST
		mov		ecx,rect.bottom
		mov		edx,rect.right
		add		ecx,6
		sub		edx,64+3+64
		invoke MoveWindow,eax,edx,ecx,64,21,TRUE
		invoke GetDlgItem,hWin,IDC_BTNMOVEDOWN
		mov		ecx,rect.bottom
		mov		edx,rect.right
		add		ecx,6
		sub		edx,64+3+64+3+64
		invoke MoveWindow,eax,edx,ecx,64,21,TRUE
		invoke GetDlgItem,hWin,IDC_BTNMOVEUP
		mov		ecx,rect.bottom
		mov		edx,rect.right
		add		ecx,6
		sub		edx,64+3+64+3+64+3+64
		invoke MoveWindow,eax,edx,ecx,64,21,TRUE
		invoke GetDlgItem,hWin,IDC_BTNINSERT
		mov		ecx,rect.bottom
		mov		edx,rect.right
		add		ecx,6
		sub		edx,64+3+64+3+64+3+64+3+64
		invoke MoveWindow,eax,edx,ecx,64,21,TRUE
		invoke GetDlgItem,hWin,IDC_BTNADD
		mov		ecx,rect.bottom
		mov		edx,rect.right
		add		ecx,6
		sub		edx,64+3+64+3+64+3+64+3+64+3+64
		invoke MoveWindow,eax,edx,ecx,64,21,TRUE
		invoke GetDlgItem,hWin,IDC_BTNDEL
		mov		ecx,rect.bottom
		mov		edx,rect.right
		add		ecx,6
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
;				invoke SendMessage,hGrd,GM_SETHDRHEIGHT,0,32
;				invoke SendMessage,hGrd,GM_SETROWHEIGHT,0,22
;				invoke SendMessage,hGrd,GM_SETCOLWIDTH,1,220
;				invoke SendMessage,hGrd,GM_RESETCONTENT,0,0
;				invoke SendMessage,hGrd,GM_ENTEREDIT,1,1
;				invoke SendMessage,hGrd,GM_SETHDRTEXT,1,offset szRAGridDLL
;				invoke SendMessage,hGrd,GM_COMBOCLEAR,5,0
;				invoke SendMessage,hGrd,GM_GETCURROW,0,0
;				mov		ecx,eax
;				shl		ecx,16
;				add		ecx,5
;				invoke SendMessage,hGrd,GM_CELLCONVERT,ecx,addr buffer
;				PrintString buffer
;				invoke SendMessage,hGrd,GM_DELROW,10,0
				invoke SendMessage,hGrd,GM_RESETCONTENT,0,0
				;The number of columns must NOT exceed the number of columns in the ROWDATA structure
				invoke SendMessage,hGrd,GM_GETCOLCOUNT,0,0
				.if eax<21
					;Add a new column
					;EditButton column
					mov		col.colwt,130
					mov		col.lpszhdrtext,offset szEditButton
					mov		col.halign,GA_ALIGN_LEFT
					mov		col.calign,GA_ALIGN_LEFT
					mov		col.ctype,TYPE_EDITBUTTON
					mov		col.ctextmax,MAX_PATH
					mov		col.lpszformat,0
					mov		col.himl,0
					invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
				.endif
				call	AddData
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNMOVEDOWN
				invoke SendMessage,hGrd,GM_GETCURROW,0,0
				lea		edx,[eax+1]
				push	edx
				invoke SendMessage,hGrd,GM_MOVEROW,eax,edx
				pop		eax
				invoke SendMessage,hGrd,GM_SETCURROW,eax,0
				invoke SetFocus,hGrd
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNMOVEUP
				invoke SendMessage,hGrd,GM_GETCURROW,0,0
				lea		edx,[eax-1]
				push	edx
				invoke SendMessage,hGrd,GM_MOVEROW,eax,edx
				pop		eax
				invoke SendMessage,hGrd,GM_SETCURROW,eax,0
				invoke SetFocus,hGrd
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNINSERT
				invoke SendMessage,hGrd,GM_GETCURROW,0,0
				push	eax
				invoke SendMessage,hGrd,GM_INSROW,eax,offset rdtanew
				pop		eax
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNADD
				mov		ecx,100
				.while ecx
					push	ecx
					invoke SendMessage,hGrd,GM_ADDROW,0,offset rdtanew
					pop		ecx
					dec		ecx
				.endw
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNDEL
				invoke SendMessage,hGrd,GM_GETCURROW,0,0
				push	eax
				invoke SendMessage,hGrd,GM_DELROW,eax,0
				pop		eax
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
				xor		eax,eax
				jmp		Ex
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		push	esi
		mov		esi,lParam
		mov		eax,[esi].NMHDR.hwndFrom
		.if eax==hGrd
			mov		eax,[esi].NMHDR.code
			.if eax==GN_HEADERCLICK
				;Sort the grid by column, invert sorting order
				invoke SendMessage,hGrd,GM_COLUMNSORT,[esi].GRIDNOTIFY.col,SORT_INVERT
			.elseif eax==GN_BUTTONCLICK
				;Cell button clicked
				invoke lstrcpy,addr buffer,[esi].GRIDNOTIFY.lpdata
				;Zero out the ofn struct
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				;Setup the ofn struct
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrFilter,NULL
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.lpstrDefExt,NULL
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
			.elseif eax==GN_CHECKCLICK
				;CheckBox value
;				mov		eax,[esi].GRIDNOTIFY.lpdata
;				mov		eax,[eax]
;				PrintHex eax
				;Cancel changing
;				mov		[esi].GRIDNOTIFY.fcancel,TRUE
			.elseif eax==GN_IMAGECLICK
				;ImageList handle
;				mov		eax,[esi].GRIDNOTIFY.hwnd
;				PrintHex eax
				;ImageList index
;				mov		eax,[esi].GRIDNOTIFY.lpdata
;				mov		eax,[eax]
;				PrintHex eax
			.elseif eax==GN_BEFORESELCHANGE
				;Setting fcancel to TRUE prevents selection changing
;				mov		[esi].GRIDNOTIFY.fcancel,TRUE
				;Changing row or col prevents rows or cols from getting focus
;				.if [esi].GRIDNOTIFY.col==0
;					mov		[esi].GRIDNOTIFY.col,1
;				.endif
;				PrintHex eax
;				PrintHex [esi].GRIDNOTIFY.col
;				PrintHex [esi].GRIDNOTIFY.row
			.elseif eax==GN_AFTERSELCHANGE
;				PrintHex eax
			.elseif eax==GN_BEFOREEDIT
				;Setting fcancel to TRUE prevents cell edit control from showing
;				mov		[esi].GRIDNOTIFY.fcancel,TRUE
				.if [esi].GRIDNOTIFY.col==9
					;IPAddress column
					mov		eax,[esi].GRIDNOTIFY.lpdata
					mov		eax,[eax]
					invoke SendMessage,[esi].GRIDNOTIFY.hwnd,IPM_SETADDRESS,0,eax
				.endif
			.elseif eax==GN_AFTEREDIT
				;Setting fcancel to TRUE prevents cell edit control from closing
;				mov		[esi].GRIDNOTIFY.fcancel,TRUE
				.if [esi].GRIDNOTIFY.col==9
					;IPAddress column
					invoke SendMessage,[esi].GRIDNOTIFY.hwnd,IPM_GETADDRESS,0,addr val
					mov		eax,val
					mov		edx,[esi].GRIDNOTIFY.lpdata
					mov		[edx],eax
				.endif
			.elseif eax==GN_BEFOREUPDATE
				;Setting fcancel to TRUE prevents updating grid data
;				mov		[esi].GRIDNOTIFY.fcancel,TRUE
			.elseif eax==GN_AFTERUPDATE
;				PrintHex eax
			.elseif eax==GN_USERCONVERT
				.if [esi].GRIDNOTIFY.col==9
					;IPAddress column
					push	ebx
					push	edi
					mov		edi,[esi].GRIDNOTIFY.lpdata
					mov		ebx,[edi]
					call	ConvByteToDec
					mov		byte ptr [edi],'.'
					inc		edi
					call	ConvByteToDec
					mov		byte ptr [edi],'.'
					inc		edi
					call	ConvByteToDec
					mov		byte ptr [edi],'.'
					inc		edi
					call	ConvByteToDec
					mov		byte ptr [edi],0
					pop		edi
					pop		ebx
				.endif
			.elseif eax==GN_EDITCHANGE
				mov		eax,[esi].GRIDNOTIFY.lpdata
			.endif
		.endif
		pop		esi
	.elseif eax==WM_CLOSE
		invoke ImageList_Destroy,hIml
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
  Ex:
	ret

ConvByteToDec:
	rol		ebx,8
	movzx	eax,bl
	xor		edx,edx
	mov		ecx,10
	div		ecx
	or		dl,30h
	mov		[edi+2],dl
	xor		edx,edx
	div		ecx
	or		dl,30h
	mov		[edi+1],dl
	xor		edx,edx
	div		ecx
	or		dl,30h
	mov		[edi],dl
	add		edi,3
	retn

AddData:
	;Add some rows
	push	esi
	mov		esi,offset rdta
	mov		ecx,16
	.while ecx
		push	ecx
		invoke SendMessage,hGrd,GM_ADDROW,0,esi
		pop		ecx
		add		esi,sizeof rdta
		dec		ecx
	.endw
	mov		rowcol.backcolor,0C0FFC0h
	mov		rowcol.textcolor,0FFh
	invoke SendMessage,hGrd,GM_SETROWCOLOR,5,addr rowcol
	invoke SendMessage,hGrd,GM_SETROWCOLOR,6,addr rowcol
	invoke SendMessage,hGrd,GM_SETROWCOLOR,7,addr rowcol
	mov		rowcol.backcolor,0C0C0FFh
	mov		rowcol.textcolor,0FF0000h
	invoke SendMessage,hGrd,GM_SETROWCOLOR,10,addr rowcol
	invoke SendMessage,hGrd,GM_SETROWCOLOR,11,addr rowcol
	invoke SendMessage,hGrd,GM_SETROWCOLOR,12,addr rowcol
	mov		ecx,500
	.while ecx
		push	ecx
		invoke SendMessage,hGrd,GM_ADDROW,0,offset rdtanew
		pop		ecx
		add		esi,sizeof rdta
		dec		ecx
	.endw

	pop		esi
	invoke SendMessage,hGrd,GM_SETCURSEL,0,0
	retn

DlgProc endp

end start
