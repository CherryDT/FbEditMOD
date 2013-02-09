.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include GridDemo6.inc
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
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	cm:COLORMAP
	LOCAL	val:DWORD
	LOCAL	mDC:HDC
	LOCAL	bm:BITMAP

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWnd,eax
		invoke GetDlgItem,hWin,IDC_GRD1
		mov		hGrd,eax
		invoke SendMessage,hGrd,GM_SETBACKCOLOR,0C0FFFFh,0
		invoke SendMessage,hGrd,GM_SETGRIDCOLOR,808080h,0
		invoke SendMessage,hGrd,GM_SETTEXTCOLOR,800000h,0
		invoke SendMessage,hGrd,GM_SETROWHEIGHT,0,100
		;Add Image column
		mov		col.colwt,90
		mov		col.lpszhdrtext,offset szImage
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_USER
		mov		col.ctextmax,4
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Add FileName column
		mov		col.colwt,200
		mov		col.lpszhdrtext,offset szFileName
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		invoke GetModuleFileName,0,offset szPath,sizeof szPath
		invoke lstrlen,offset szPath
		mov		ecx,eax
		.while byte ptr szPath[ecx]!='\'
			mov		byte ptr szPath[ecx],0
			dec		ecx
		.endw
		invoke lstrcat,offset szPath,offset szGridDemo6
		;Add some rows
		push	esi
		mov		esi,offset szImages
		.while byte ptr [esi]
			invoke lstrcpy,addr buffer,offset szPath
			invoke lstrcat,addr buffer,esi
			invoke BitmapFromFile,addr buffer
			.if !eax
				invoke BitmapFromFile,addr buffer
			.endif
			mov		rdta.hbmp,eax
			mov		rdta.lpszFileName,esi
			invoke SendMessage,hGrd,GM_ADDROW,0,addr rdta
			invoke lstrlen,esi
			lea		esi,[esi+eax+1]
		.endw
		pop		esi
		invoke SendMessage,hGrd,GM_SETCURSEL,0,0
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
				invoke SendMessage,hGrd,GM_ADDROW,0,NULL
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNDEL
				invoke SendMessage,hGrd,GM_GETCURROW,0,0
				push	eax
				push	eax
				mov		ecx,eax
				call	DelBmp
				pop		eax
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
			.elseif eax==GN_USERCONVERT
				;Cancel convert to make the grid send WM_DRAWITEM
				mov		[esi].GRIDNOTIFY.fcancel,TRUE
			.endif
		.endif
		pop		esi
	.elseif eax==WM_DRAWITEM
		push	esi
		mov		esi,lParam
		assume esi:ptr DRAWITEMSTRUCT
		;Get data from column
		;Win98 strips off high word fron itemID so col must be stored in CtlType
		mov		ecx,[esi].itemID		;row
		shl		ecx,16
		add		ecx,[esi].CtlType		;col
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr val
		invoke CreateCompatibleDC,[esi].hdc
		mov		mDC,eax
		invoke SelectObject,mDC,val
		push	eax
		invoke GetObject,val,sizeof BITMAP,addr bm
		mov		eax,[esi].rcItem.right
		sub		eax,[esi].rcItem.left
		mov		edx,[esi].rcItem.bottom
		sub		edx,[esi].rcItem.top
		invoke StretchBlt,[esi].hdc,[esi].rcItem.left,[esi].rcItem.top,eax,edx,mDC,0,0,bm.bmWidth,bm.bmHeight,SRCCOPY
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteDC,mDC
		assume esi:nothing
		pop		esi
	.elseif eax==WM_CLOSE
		invoke SendMessage,hGrd,GM_GETROWCOUNT,0,0
		mov		ecx,eax
		.while ecx
			dec		ecx
			call	DelBmp
		.endw
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
  Ex:
	ret

DelBmp:
	push	ecx
	shl		ecx,16
	invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr val
	invoke DeleteObject,val
	pop		ecx
	retn

DlgProc endp

end start
