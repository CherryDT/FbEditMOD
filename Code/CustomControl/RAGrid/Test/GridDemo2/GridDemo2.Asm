.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include GridDemo2.inc
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

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	col:COLUMN
	LOCAL	rect:RECT
	LOCAL	val:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWnd,eax
		invoke GetDlgItem,hWin,IDC_GRD1
		mov		hGrd,eax

		invoke SendMessage,hGrd,GM_SETBACKCOLOR,0FFFFD0h,0
		invoke SendMessage,hGrd,GM_SETGRIDCOLOR,808080h,0
		invoke SendMessage,hGrd,GM_SETTEXTCOLOR,800000h,0

		;Add Name column
		mov		col.colwt,150
		mov		col.lpszhdrtext,offset szName
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,31
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;Add Address column
		mov		col.colwt,150
		mov		col.lpszhdrtext,offset szAddress
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,31
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;Add Points column
		mov		col.colwt,50
		mov		col.lpszhdrtext,offset szPoints
		mov		col.halign,GA_ALIGN_RIGHT
		mov		col.calign,GA_ALIGN_RIGHT
		mov		col.ctype,TYPE_EDITLONG
		mov		col.ctextmax,4
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;Add Graph column
		mov		col.colwt,110
		mov		col.lpszhdrtext,offset szGraph
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_USER
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		mov		col.edthwnd,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;Add some rows
		push	edi
		mov		edi,offset rdta
		mov		ecx,4
		.while ecx
			push	ecx
			invoke SendMessage,hGrd,GM_ADDROW,0,edi
			pop		ecx
			add		edi,sizeof rdta
			dec		ecx
		.endw
		pop		edi

		invoke SendMessage,hGrd,GM_SETROWHEIGHT,0,20
		invoke SendMessage,hGrd,GM_SETCURSEL,0,0
		invoke SetFocus,hGrd
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_DRAWITEM
		push	esi
		mov		esi,lParam
		assume esi:ptr DRAWITEMSTRUCT
		;Test rect width
		mov		eax,[esi].rcItem.right
		sub		eax,[esi].rcItem.left
		.if sdword ptr eax>=4
			;Get data from Points column
			;Win98 strips off high word fron itemID so col must be stored in CtlType
			mov		ecx,[esi].itemID		;row
			shl		ecx,16
			add		ecx,[esi].CtlType		;col
			dec		ecx
			invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr val
			;Adjust the rect
			add		[esi].rcItem.left,1
			add		[esi].rcItem.top,3
			sub		[esi].rcItem.right,1
			sub		[esi].rcItem.bottom,3
			;Calculate width of graph
			mov		eax,[esi].rcItem.right
			sub		eax,[esi].rcItem.left
			mov		ecx,val
			mul		ecx
			mov		ecx,10000
			div		ecx
			;Test result
			.if sdword ptr eax>=2
				add		eax,[esi].rcItem.left
				mov		[esi].rcItem.right,eax
				;Draw the graph
				invoke CreateSolidBrush,00FF0000h
				push	eax
				invoke FillRect,[esi].hdc,addr [esi].rcItem,eax
				pop		eax
				invoke DeleteObject,eax
				invoke GetStockObject,DKGRAY_BRUSH
				invoke FrameRect,[esi].hdc,addr [esi].rcItem,eax
			.endif
		.endif
		assume esi:NOTHING
		pop		esi
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
				invoke SendMessage,hGrd,GM_INSROW,eax,NULL
				pop		eax
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNADD
				invoke SendMessage,hGrd,GM_ADDROW,0,offset rdta
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
;			.elseif eax==GN_BUTTONCLICK
;			.elseif eax==GN_CHECKCLICK
;			.elseif eax==GN_IMAGECLICK
;			.elseif eax==GN_BEFORESELCHANGE
;			.elseif eax==GN_AFTERSELCHANGE
;			.elseif eax==GN_BEFOREEDIT
;			.elseif eax==GN_AFTEREDIT
;			.elseif eax==GN_BEFOREUPDATE
;			.elseif eax==GN_AFTERUPDATE
			.elseif eax==GN_USERCONVERT
				;Cancel convert to make the grid send WM_DRAWITEM
				mov		[esi].GRIDNOTIFY.fcancel,TRUE
			.endif
		.endif
		pop		esi
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
  Ex:
	ret

DlgProc endp

end start
