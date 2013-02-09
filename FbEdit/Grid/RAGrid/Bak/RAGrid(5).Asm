;KetilO (C) 2003
;ketil.olsen@jm-data.no

;To build RAGrid.dll use Release build option
;To build RAGrid.lib use Debug build option

.386
.model flat, stdcall
option casemap :none   ; case sensitive
option proc:private

include Data.inc
include ..\RAGrid.inc
include Misc.asm
include Sort.asm
include GridData.asm

.code

ShowHide proc uses edi,hLst:HWND,fShow:DWORD

	mov		edi,hLst
	.if fShow
		invoke SendMessage,edi,GM_GETCURCOL,0,0
		push	eax
		invoke SendMessage,edi,GM_GETCURROW,0,0
		pop		ecx
		invoke SendMessage,edi,GM_ENTEREDIT,ecx,eax
	.else
		invoke SendMessage,edi,GM_GETCURSEL,0,0
		invoke SendMessage,edi,GM_ENDEDIT,eax,TRUE
	.endif
	ret

ShowHide endp

;dtadd	dq 24*60*60*1000*1000*1000*1000*100
DateTimeProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hDC:HDC
	LOCAL	rect:RECT
	LOCAL	stime:SYSTEMTIME
	LOCAL	ftime:FILETIME

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
	.elseif eax==WM_KEYDOWN
		mov		eax,wParam
		.if eax==VK_RETURN
			invoke ShowWindow,hWin,SW_HIDE
			xor		eax,eax
			jmp		Ex
		.elseif eax==VK_ESCAPE
			mov		fCancelEdit,TRUE
			invoke ShowWindow,hWin,SW_HIDE
			mov		fCancelEdit,FALSE
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_CHAR
		mov		eax,wParam
		.if eax=='+'
			invoke SendMessage,hWin,DTM_GETSYSTEMTIME,0,addr stime
			invoke SystemTimeToFileTime,addr stime,addr ftime
			mov		eax,24*60*60
			mov		edx,1000*1000*10
			mul		edx
			add		ftime.dwLowDateTime,eax
			adc		ftime.dwHighDateTime,edx
			invoke FileTimeToSystemTime,addr ftime,addr stime
			invoke SendMessage,hWin,DTM_SETSYSTEMTIME,0,addr stime
			xor		eax,eax
			jmp		Ex
		.elseif eax=='-'
			invoke SendMessage,hWin,DTM_GETSYSTEMTIME,0,addr stime
			invoke SystemTimeToFileTime,addr stime,addr ftime
			mov		eax,24*60*60
			mov		edx,1000*1000*10
			mul		edx
			sub		ftime.dwLowDateTime,eax
			sbb		ftime.dwHighDateTime,edx
			invoke FileTimeToSystemTime,addr ftime,addr stime
			invoke SendMessage,hWin,DTM_SETSYSTEMTIME,0,addr stime
			xor		eax,eax
			jmp		Ex
		.elseif eax=='T' || eax=='t'
			invoke GetSystemTime,addr stime
			invoke SendMessage,hWin,DTM_SETSYSTEMTIME,0,addr stime
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_SHOWWINDOW
		.if !wParam && !fCancelEdit
			mov		fCancelEdit,TRUE
			call	Update
			mov		fCancelEdit,FALSE
		.endif
	.elseif eax==WM_GETDLGCODE
 		mov		eax,DLGC_CODE
		jmp		Ex
	.endif
	invoke GetWindowLong,hWin,GWL_USERDATA
	invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
  Ex:
	ret

Update:
	invoke GetWindowLong,hWin,GWL_ID
	push	eax
	invoke GetParent,hWin
	invoke GetParent,eax
	pop		ecx
	invoke SendMessage,eax,GM_ENDEDIT,ecx,FALSE
	retn

DateTimeProc endp

LstProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	hPar:DWORD

	mov		eax,uMsg
	.if eax==WM_CHAR
		mov		eax,wParam
		.if eax==VK_RETURN
			mov		fCancelEdit,FALSE
			invoke ShowWindow,hWin,SW_HIDE
			xor		eax,eax
			jmp		Ex
		.elseif eax==VK_ESCAPE
			mov		fCancelEdit,TRUE
			invoke ShowWindow,hWin,SW_HIDE
			mov		fCancelEdit,FALSE
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_LBUTTONDOWN
		mov		fCancelEdit,FALSE
		invoke ShowWindow,hWin,SW_HIDE
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_MOUSEMOVE
		invoke SendMessage,hWin,LB_GETCURSEL,0,0
		push	eax
		invoke GetCursorPos,addr pt
		invoke LBItemFromPt,hWin,pt.x,pt.y,TRUE
		pop		edx
		.if eax!=edx
			invoke SendMessage,hWin,LB_SETCURSEL,eax,0
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_ACTIVATE
		mov		eax,wParam
		movzx	eax,ax
		mov		edx,lParam
		.if eax!=WA_INACTIVE
			mov		hfocus,edx
			invoke SendMessage,edx,WM_NCACTIVATE,TRUE,0
		.elseif edx!=hfocus
			invoke SendMessage,hfocus,WM_NCACTIVATE,FALSE,0
		.endif
	.elseif eax==WM_SHOWWINDOW
		.if !wParam && !fCancelEdit
			mov		fCancelEdit,TRUE
			call	Update
			mov		fCancelEdit,FALSE
		.endif
	.elseif eax==WM_KILLFOCUS
		invoke ShowWindow,hWin,SW_HIDE
	.elseif eax==WM_SETFOCUS
		mov		fCancelEdit,TRUE
	.elseif eax==WM_GETDLGCODE
 		mov		eax,DLGC_CODE
		jmp		Ex
	.endif
	invoke CallWindowProc,lplstproc,hWin,uMsg,wParam,lParam
  Ex:
	ret

Update:
	push	ebx
	invoke GetWindowLong,hWin,GWL_USERDATA
	push	eax
	invoke GetWindowLong,eax,0
	mov		ebx,eax
	invoke GlobalLock,ebx
	push	[eax].GRID.edtrowcol
	mov		edx,[eax].GRID.col
	mov		ncol,edx
	mov		edx,[eax].GRID.row
	mov		nrow,edx
	invoke GlobalUnlock,ebx
	pop		ecx
	pop		eax
	invoke SendMessage,eax,GM_ENDEDIT,ecx,FALSE
	pop		ebx
	retn

LstProc endp

CboProc proc uses ebx edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	buffer[512]:BYTE

	mov		eax,uMsg
	.if eax==WM_LBUTTONDOWN
		invoke SendMessage,hWin,LB_GETCURSEL,0,0
		mov		edx,eax
		invoke SendMessage,hWin,LB_GETTEXT,edx,addr buffer
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		edi,eax
		invoke SendMessage,edi,WM_SETTEXT,0,addr buffer
		invoke SendMessage,edi,EM_SETSEL,0,-1
		invoke ShowWindow,hWin,SW_HIDE
		call	GetMem
		mov		eax,[ebx].GRID.col
		mov		ncol,eax
		mov		eax,[ebx].GRID.row
		mov		nrow,eax
		call	RelMem
		invoke SetFocus,edi
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_MOUSEMOVE
		invoke SendMessage,hWin,LB_GETCURSEL,0,0
		push	eax
		invoke GetCursorPos,addr pt
		invoke LBItemFromPt,hWin,pt.x,pt.y,TRUE
		pop		edx
		.if eax!=edx
			invoke SendMessage,hWin,LB_SETCURSEL,eax,0
		.endif
		xor		eax,eax
		jmp		Ex
	.endif
	invoke CallWindowProc,lpcboproc,hWin,uMsg,wParam,lParam
  Ex:
	ret

RelMem:
	invoke GetWindowLong,hWin,GWL_USERDATA
	invoke GetParent,eax
	invoke GetParent,eax
	invoke GetWindowLong,eax,0
	invoke GlobalUnlock,eax
	retn

GetMem:
	invoke GetWindowLong,hWin,GWL_USERDATA
	invoke GetParent,eax
	invoke GetParent,eax
	invoke GetWindowLong,eax,0
	invoke GlobalLock,eax
	mov		ebx,eax
	retn

CboProc endp

EdtCboProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[512]:BYTE
	LOCAL	gn:GRIDNOTIFY

	mov		eax,uMsg
	.if eax==WM_CHAR
		mov		eax,wParam
		.if eax==VK_RETURN
			invoke GetParent,hWin
			invoke GetParent,eax
			invoke SetFocus,eax
			call	GetMem
			mov		eax,[ebx].GRID.col
			mov		ncol,eax
			mov		eax,[ebx].GRID.row
			mov		nrow,eax
			call	RelMem
			xor		eax,eax
			jmp		Ex
		.elseif eax==VK_ESCAPE
			mov		fCancelEdit,TRUE
			invoke GetParent,hWin
			invoke GetParent,eax
			invoke SetFocus,eax
			mov		fCancelEdit,FALSE
			invoke GetParent,hWin
			invoke GetWindowLong,eax,4
			invoke ShowWindow,eax,SW_HIDE
			call	GetMem
			mov		eax,[ebx].GRID.col
			mov		ncol,eax
			mov		eax,[ebx].GRID.row
			mov		nrow,eax
			call	RelMem
			xor		eax,eax
			jmp		Ex
		.else
			invoke GetWindowLong,hWin,GWL_USERDATA
			invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			call	GetMem
			mov		eax,[ebx].GRID.hgrd
			mov		gn.nmhdr.hwndFrom,eax
			mov		eax,[ebx].GRID.nid
			mov		gn.nmhdr.idFrom,eax
			mov		gn.nmhdr.code,GN_EDITCHANGE
			mov		eax,[ebx].GRID.col
			mov		gn.col,eax
			mov		eax,[ebx].GRID.row
			mov		gn.row,eax
			mov		eax,hWin
			mov		gn.hwnd,eax
			lea		eax,buffer
			mov		gn.lpdata,eax
			mov		gn.fcancel,0
			invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,[ebx].GRID.nid,addr gn
			call	RelMem
			invoke GetParent,hWin
			invoke GetWindowLong,eax,4
			mov		edi,eax
			;invoke SendMessage,edi,LB_GETCURSEL,0,0
			;mov		edx,eax
			;invoke SendMessage,edi,LB_FINDSTRINGEXACT,edx,addr buffer
			invoke SendMessage,edi,LB_FINDSTRING,-1,addr buffer
			push	eax
			.if eax==LB_ERR
				invoke ShowWindow,edi,SW_HIDE
			.else
				invoke ShowWindow,edi,SW_SHOWNA
			.endif
			pop		eax
			invoke SendMessage,edi,LB_SETCURSEL,eax,0
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_KEYDOWN
		invoke GetKeyState,VK_CONTROL
		and		eax,80h
		mov		ecx,eax
		mov		edx,wParam
		mov		eax,lParam
		shr		eax,16
		and		eax,3FFh
		.if edx==28h && (eax==150h || eax==50h)
			;Down
			.if ecx
				invoke GetParent,hWin
				invoke GetWindowLong,eax,4
				mov		edi,eax
				invoke IsWindowVisible,edi
				.if eax
					mov		eax,SW_HIDE
				.else
					mov		eax,SW_SHOWNA
				.endif
				invoke ShowWindow,edi,eax
			.else
				invoke GetParent,hWin
				invoke GetWindowLong,eax,4
				mov		edi,eax
				invoke SendMessage,edi,LB_GETCURSEL,0,0
				inc		eax
				push	eax
				invoke SendMessage,edi,LB_SETCURSEL,eax,0
				pop		edx
				.if eax!=LB_ERR
					invoke SendMessage,edi,LB_GETTEXT,edx,addr buffer
					invoke SendMessage,hWin,WM_SETTEXT,0,addr buffer
					invoke SendMessage,hWin,EM_SETSEL,0,-1
				.endif
			.endif
			xor		eax,eax
			jmp		Ex
		.elseif edx==26h && (eax==148h || eax==48h)
			;Up
			.if ecx
				invoke GetParent,hWin
				invoke GetWindowLong,eax,4
				mov		edi,eax
				invoke IsWindowVisible,edi
				.if eax
					mov		eax,SW_HIDE
				.else
					mov		eax,SW_SHOWNA
				.endif
				invoke ShowWindow,edi,eax
			.else
				invoke GetParent,hWin
				invoke GetWindowLong,eax,4
				mov		edi,eax
				invoke SendMessage,edi,LB_GETCURSEL,0,0
				.if sdword ptr eax>0
					dec		eax
					push	eax
					invoke SendMessage,edi,LB_SETCURSEL,eax,0
					pop		edx
					.if eax!=LB_ERR
						invoke SendMessage,edi,LB_GETTEXT,edx,addr buffer
						invoke SendMessage,hWin,WM_SETTEXT,0,addr buffer
						invoke SendMessage,hWin,EM_SETSEL,0,-1
					.endif
				.endif
			.endif
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_KILLFOCUS
		invoke GetParent,hWin
		invoke GetWindowLong,eax,4
		.if eax!=wParam
			call	Update
			invoke GetWindowLong,hWin,GWL_USERDATA
			invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
			invoke GetParent,hWin
			invoke ShowWindow,eax,SW_HIDE
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_GETDLGCODE
 		mov		eax,DLGC_CODE
		jmp		Ex
	.endif
	invoke GetWindowLong,hWin,GWL_USERDATA
	invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
  Ex:
	ret

Update:
	invoke GetParent,hWin
	invoke GetWindowLong,eax,GWL_ID
	push	eax
	invoke GetParent,hWin
	invoke GetParent,eax
	invoke GetParent,eax
	pop		ecx
	invoke SendMessage,eax,GM_ENDEDIT,ecx,fCancelEdit
	retn

RelMem:
	invoke GetParent,hWin
	invoke GetParent,eax
	invoke GetParent,eax
	invoke GetWindowLong,eax,0
	invoke GlobalUnlock,eax
	retn

GetMem:
	invoke GetParent,hWin
	invoke GetParent,eax
	invoke GetParent,eax
	invoke GetWindowLong,eax,0
	invoke GlobalLock,eax
	mov		ebx,eax
	retn

EdtCboProc endp

RAComboProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	buffer[512]:BYTE

	mov		eax,uMsg
	.if eax==WM_CREATE
		invoke CreateWindowEx,0,offset szEditClass,NULL,WS_CHILD or WS_VISIBLE or WS_BORDER or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or ES_AUTOHSCROLL,0,0,0,0,hWin,NULL,hInstance,0
		mov		edi,eax
		invoke SetWindowLong,hWin,0,edi
		invoke SetWindowLong,edi,GWL_WNDPROC,offset EdtCboProc
		invoke SetWindowLong,edi,GWL_USERDATA,eax
		invoke CreateWindowEx,WS_EX_TOOLWINDOW,offset szListBoxClass,NULL,WS_CHILD or WS_BORDER or WS_VSCROLL or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or LBS_HASSTRINGS or LBS_SORT or LBS_OWNERDRAWFIXED,0,0,0,0,hWin,NULL,hInstance,0
		mov		ebx,eax
		invoke SetWindowLong,hWin,4,ebx
		invoke SetWindowLong,ebx,GWL_USERDATA,edi
		invoke GetDesktopWindow
		invoke SetParent,ebx,eax
		invoke SetWindowLong,ebx,GWL_STYLE,WS_POPUP or WS_BORDER or WS_VSCROLL or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or LBS_HASSTRINGS or LBS_SORT or LBS_OWNERDRAWFIXED
		invoke SetWindowLong,ebx,GWL_WNDPROC,offset CboProc
		mov		lpcboproc,eax
	.elseif eax==WM_SIZE
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,lParam
		movsx	eax,dx
		shr		edx,16
		movsx	edx,dx
		invoke MoveWindow,ebx,0,0,eax,edx,TRUE
	.elseif eax==WM_SETFOCUS
		invoke GetWindowLong,hWin,0
		invoke SetFocus,eax
		jmp		Ex
	.elseif eax==WM_CHAR
		invoke GetWindowLong,hWin,0
		invoke SendMessage,eax,WM_CHAR,wParam,lParam
		jmp		Ex
	.elseif eax==WM_SETFONT
		invoke GetWindowLong,hWin,0
		invoke SendMessage,eax,WM_SETFONT,wParam,FALSE
		invoke GetWindowLong,hWin,4
		invoke SendMessage,eax,WM_SETFONT,wParam,FALSE
	.elseif eax==WM_DRAWITEM
		assume esi:ptr DRAWITEMSTRUCT
		call	GetMem
		mov		esi,lParam
		.if [esi].itemID!=LB_ERR
			invoke SetBkMode,[esi].hdc,TRANSPARENT
			invoke GetWindowLong,hWin,GWL_ID
			movzx	eax,ax
			mov		ecx,sizeof COLUMN
			mul		ecx
			lea		edi,[ebx+eax+sizeof GRID]
			test	[esi].itemState,ODS_SELECTED
			.if ZERO?
				invoke SetTextColor,[esi].hdc,[ebx].GRID.coltext
				invoke FillRect,[esi].hdc,addr [esi].rcItem,[ebx].GRID.hbrback
			.else
				invoke GetSysColor,COLOR_HIGHLIGHTTEXT
				invoke SetTextColor,[esi].hdc,eax
				invoke FillRect,[esi].hdc,addr [esi].rcItem,COLOR_HIGHLIGHT+1
				.if [edi].COLUMN.himl
					invoke CopyRect,addr rect,addr [esi].rcItem
					mov		rect.right,18
					invoke FillRect,[esi].hdc,addr rect,[ebx].GRID.hbrback
				.endif
			.endif
			.if [edi].COLUMN.himl
				invoke CopyRect,addr rect,addr [esi].rcItem
				add		[esi].rcItem.left,18
				inc		rect.left
				mov		eax,rect.left
				add		eax,16
				mov		rect.right,eax
				invoke CreateRectRgn,rect.left,rect.top,rect.right,rect.bottom
				push	eax
				invoke SelectClipRgn,[esi].hdc,eax
				pop		eax
				invoke DeleteObject,eax
				invoke ImageList_Draw,[edi].COLUMN.himl,[esi].itemData,[esi].hdc,rect.left,rect.top,ILD_NORMAL
				invoke SelectClipRgn,[esi].hdc,NULL
			.endif
			mov		buffer,0
			invoke SendMessage,[esi].hwndItem,LB_GETTEXT,[esi].itemID,addr buffer
			invoke strlen,addr buffer
			mov		ecx,[esi].rcItem.left
			add		ecx,2
			mov		edx,[esi].rcItem.top
			inc		edx
			invoke TextOut,[esi].hdc,ecx,edx,addr buffer,eax
			invoke SetTextColor,[esi].hdc,0
		.endif
		xor		eax,eax
		call	RelMem
		assume esi:nothing
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

RelMem:
	invoke GetParent,hWin
	invoke GetParent,eax
	invoke GetWindowLong,eax,0
	invoke GlobalUnlock,eax
	retn

GetMem:
	invoke GetParent,hWin
	invoke GetParent,eax
	invoke GetWindowLong,eax,0
	invoke GlobalLock,eax
	mov		ebx,eax
	retn

RAComboProc endp

HotProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
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
	.elseif eax==WM_KEYDOWN
		mov		eax,wParam
		.if eax==VK_RETURN
			invoke ShowWindow,hWin,SW_HIDE
			xor		eax,eax
			jmp		Ex
		.elseif eax==VK_ESCAPE
			mov		fCancelEdit,TRUE
			invoke ShowWindow,hWin,SW_HIDE
			mov		fCancelEdit,FALSE
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_SHOWWINDOW
		.if !wParam && !fCancelEdit
			mov		fCancelEdit,TRUE
			call	Update
			mov		fCancelEdit,FALSE
		.endif
	.elseif eax==WM_GETDLGCODE
 		mov		eax,DLGC_CODE
		jmp		Ex
	.endif
	invoke GetWindowLong,hWin,GWL_USERDATA
	invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
  Ex:
	ret

Update:
	invoke GetWindowLong,hWin,GWL_ID
	push	eax
	invoke GetParent,hWin
	invoke GetParent,eax
	pop		ecx
	invoke SendMessage,eax,GM_ENDEDIT,ecx,FALSE
	retn

HotProc endp

EdtTextProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[512]:BYTE
	LOCAL	gn:GRIDNOTIFY

	mov		eax,uMsg
	.if eax==WM_CHAR
		mov		eax,wParam
		.if eax==VK_RETURN
			invoke ShowWindow,hWin,SW_HIDE
			xor		eax,eax
			jmp		Ex
		.elseif eax==VK_ESCAPE
			mov		fCancelEdit,TRUE
			invoke ShowWindow,hWin,SW_HIDE
			mov		fCancelEdit,FALSE
			xor		eax,eax
			jmp		Ex
		.else
			invoke GetWindowLong,hWin,GWL_USERDATA
			invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			call	GetMem
			mov		eax,[ebx].GRID.hgrd
			mov		gn.nmhdr.hwndFrom,eax
			mov		eax,[ebx].GRID.nid
			mov		gn.nmhdr.idFrom,eax
			mov		gn.nmhdr.code,GN_EDITCHANGE
			mov		eax,[ebx].GRID.col
			mov		gn.col,eax
			mov		eax,[ebx].GRID.row
			mov		gn.row,eax
			mov		eax,hWin
			mov		gn.hwnd,eax
			lea		eax,buffer
			mov		gn.lpdata,eax
			mov		gn.fcancel,0
			invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,[ebx].GRID.nid,addr gn
			call	RelMem
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_SHOWWINDOW
		.if !wParam && !fCancelEdit
			mov		fCancelEdit,TRUE
			call	Update
			mov		fCancelEdit,FALSE
		.endif
	.elseif eax==WM_GETDLGCODE
 		mov		eax,DLGC_CODE
		jmp		Ex
	.endif
	invoke GetWindowLong,hWin,GWL_USERDATA
	invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
  Ex:
	ret

Update:
	invoke GetWindowLong,hWin,GWL_ID
	push	eax
	invoke GetParent,hWin
	invoke GetParent,eax
	pop		ecx
	invoke SendMessage,eax,GM_ENDEDIT,ecx,FALSE
	retn

RelMem:
	invoke GetParent,hWin
	invoke GetParent,eax
	invoke GetWindowLong,eax,0
	invoke GlobalUnlock,eax
	retn

GetMem:
	invoke GetParent,hWin
	invoke GetParent,eax
	invoke GetWindowLong,eax,0
	invoke GlobalLock,eax
	mov		ebx,eax
	retn

EdtTextProc endp

EdtLongProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[512]:BYTE
	LOCAL	gn:GRIDNOTIFY

	mov		eax,uMsg
	.if eax==WM_CHAR
		mov		eax,wParam
		.if eax==VK_RETURN
			invoke ShowWindow,hWin,SW_HIDE
			xor		eax,eax
			jmp		Ex
		.elseif eax==VK_ESCAPE
			mov		fCancelEdit,TRUE
			invoke ShowWindow,hWin,SW_HIDE
			mov		fCancelEdit,FALSE
			xor		eax,eax
			jmp		Ex
		.elseif (eax<'0' || eax>'9') && eax!='-' && eax!=8
			invoke MessageBeep,MB_OK
			xor		eax,eax
			jmp		Ex
		.else
			invoke GetWindowLong,hWin,GWL_USERDATA
			invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			call	GetMem
			mov		eax,[ebx].GRID.hgrd
			mov		gn.nmhdr.hwndFrom,eax
			mov		eax,[ebx].GRID.nid
			mov		gn.nmhdr.idFrom,eax
			mov		gn.nmhdr.code,GN_EDITCHANGE
			mov		eax,[ebx].GRID.col
			mov		gn.col,eax
			mov		eax,[ebx].GRID.row
			mov		gn.row,eax
			mov		eax,hWin
			mov		gn.hwnd,eax
			lea		eax,buffer
			mov		gn.lpdata,eax
			mov		gn.fcancel,0
			invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,[ebx].GRID.nid,addr gn
			call	RelMem
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_SHOWWINDOW
		.if !wParam && !fCancelEdit
			mov		fCancelEdit,TRUE
			call	Update
			mov		fCancelEdit,FALSE
		.endif
	.elseif eax==WM_GETDLGCODE
 		mov		eax,DLGC_CODE
		jmp		Ex
	.endif
	invoke GetWindowLong,hWin,GWL_USERDATA
	invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
  Ex:
	ret

Update:
	invoke GetWindowLong,hWin,GWL_ID
	push	eax
	invoke GetParent,hWin
	invoke GetParent,eax
	pop		ecx
	invoke SendMessage,eax,GM_ENDEDIT,ecx,FALSE
	retn

RelMem:
	invoke GetParent,hWin
	invoke GetParent,eax
	invoke GetWindowLong,eax,0
	invoke GlobalUnlock,eax
	retn

GetMem:
	invoke GetParent,hWin
	invoke GetParent,eax
	invoke GetWindowLong,eax,0
	invoke GlobalLock,eax
	mov		ebx,eax
	retn

EdtLongProc endp

;--------------------------------------------------------------------------------

GridHdrProc proc uses ebx edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	gn:GRIDNOTIFY

	mov		eax,uMsg
	.if eax==WM_MOUSEMOVE
		call	GetMem
		test	[ebx].GRID.style,STYLE_NOCOLSIZE
		.if ZERO?
			.if fSize<2
				mov		eax,wParam
				and		eax,MK_LBUTTON or MK_RBUTTON
				.if !eax
					mov		fSize,0
					mov		ecx,[ebx].GRID.cols
					.while ecx
						dec		ecx
						mov		eax,sizeof COLUMN
						mul		ecx
						lea		edi,[ebx+eax+sizeof GRID]
						.if [edi].COLUMN.colwt
							mov		eax,[edi].COLUMN.colxp
							mov		nSizeMin,eax
							add     eax,[edi].COLUMN.colwt
							mov		rect.left,eax
							mov		eax,lParam
							movzx	eax,ax
							mov		edx,eax
							sub		edx,rect.left
							mov		nSizeOfs,edx
							mov		edx,eax
							sub		eax,2
							add		edx,4
							.if eax<=rect.left && edx>=rect.left
								mov		nSizeCol,ecx
								invoke SetCursor,[ebx].GRID.hcur
								mov		fSize,1
								.break
							.endif
						.endif
					.endw
				.endif
			.else
				invoke GetParent,hWin
				mov		edx,eax
				invoke GetClientRect,edx,addr rect
				mov		eax,lParam
				movzx	eax,ax
				cwde
				sub		eax,nSizeOfs
				.if sdword ptr eax<nSizeMin
					mov		eax,nSizeMin
				.endif
				sub		eax,[ebx].GRID.sbx
				invoke MoveWindow,[ebx].GRID.hsize,eax,0,2,rect.bottom,TRUE
				invoke ShowWindow,[ebx].GRID.hsize,SW_SHOW
			.endif
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_LBUTTONDOWN
		call	GetMem
		test	[ebx].GRID.style,STYLE_NOCOLSIZE
		.if ZERO?
			.if fSize==1
				invoke ShowHide,[ebx].GRID.hgrd,FALSE
				mov		fSize,2
				invoke SetCursor,[ebx].GRID.hcur
				invoke SendMessage,hWin,WM_MOUSEMOVE,wParam,lParam
			.else
				lea		edi,[ebx+sizeof GRID]
				mov		eax,lParam
				movzx	eax,ax
				xor		ecx,ecx
				.while ecx<[ebx].GRID.cols
					mov		edx,[edi].COLUMN.colxp
					add		edx,[edi].COLUMN.colwt
					.if eax<edx
						or		[edi].COLUMN.hdrflag,1
						invoke InvalidateRect,[ebx].GRID.hhdr,NULL,TRUE
						invoke UpdateWindow,[ebx].GRID.hhdr
						.break
					.endif
					inc		ecx
					add		edi,sizeof COLUMN
				.endw
			.endif
			invoke SetCapture,hWin
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_LBUTTONUP
		call	GetMem
		test	[ebx].GRID.style,STYLE_NOCOLSIZE
		.if ZERO?
			.if fSize
				mov		fSize,0
				mov		eax,sizeof COLUMN
				mov		ecx,nSizeCol
				mul		ecx
				lea		edi,[ebx+eax+sizeof GRID]
				mov		eax,lParam
				movzx	eax,ax
				cwde
				sub		eax,nSizeOfs
				.if sdword ptr eax<=nSizeMin
					mov		eax,nSizeMin
					inc		eax
				.endif
				sub		eax,nSizeMin
				.if eax < 5                  ; *** MOD
					mov eax, 5
				.endif
				mov		[edi].COLUMN.colwt,eax
				mov		eax,[edi].COLUMN.colxp
				.while ecx<[ebx].GRID.cols
					mov		[edi].COLUMN.colxp,eax
					add		eax,[edi].COLUMN.colwt
					mov		[ebx].GRID.ccx,eax
					add		edi,sizeof COLUMN
					inc		ecx
				.endw
				invoke ShowWindow,[ebx].GRID.hsize,SW_HIDE
				invoke SendMessage,[ebx].GRID.hgrd,WM_SIZE,0,0
				invoke InvalidateRect,[ebx].GRID.hhdr,NULL,TRUE
				invoke UpdateWindow,[ebx].GRID.hhdr
				invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
				invoke UpdateWindow,[ebx].GRID.hlst
			.else
				lea		edi,[ebx+sizeof GRID]
				xor		ecx,ecx
				.while ecx<[ebx].GRID.cols
					test	[edi].COLUMN.hdrflag,1
					.if !ZERO?
						and		[edi].COLUMN.hdrflag,-1 xor 1
						mov		eax,[ebx].GRID.hgrd
						mov		gn.nmhdr.hwndFrom,eax
						mov		eax,[ebx].GRID.nid
						mov		gn.nmhdr.idFrom,eax
						mov		gn.nmhdr.code,GN_HEADERCLICK
						mov		gn.col,ecx
						mov		gn.row,-1
						mov		eax,hWin
						mov		gn.hwnd,eax
						mov		gn.lpdata,0
						mov		gn.fcancel,0
						invoke InvalidateRect,[ebx].GRID.hhdr,NULL,TRUE
						invoke UpdateWindow,[ebx].GRID.hhdr
						invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,[ebx].GRID.nid,addr gn
						.break
					.endif
					inc		ecx
					add		edi,sizeof COLUMN
				.endw
			.endif
			invoke ReleaseCapture
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_LBUTTONDBLCLK
		invoke ReleaseCapture
		xor		eax,eax
		jmp		Ex
	.endif
	invoke GetWindowLong,hWin,GWL_USERDATA
	invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
  Ex:
	ret

RelMem:
	invoke GetParent,hWin
	invoke GetWindowLong,eax,0
	invoke GlobalUnlock,eax
	retn

GetMem:
	invoke GetParent,hWin
	invoke GetWindowLong,eax,0
	invoke GlobalLock,eax
	mov		ebx,eax
	retn

GridHdrProc endp

GetItemRect proc uses esi,nRow:DWORD,lpRect:DWORD

	mov		esi,lpRect
	mov		eax,nRow
	.if eax<[ebx].GRID.rows
		invoke GetClientRect,[ebx].GRID.hlst,esi
		mov		eax,[ebx].GRID.sbx
		add		[esi].RECT.left,eax
		add		[esi].RECT.right,eax
		mov		eax,[ebx].GRID.rowht
		mov		edx,nRow
		sub		edx,[ebx].GRID.toprow
		mul		edx
		mov		[esi].RECT.top,eax
		add		eax,[ebx].GRID.rowht
		mov		[esi].RECT.bottom,eax
		xor		eax,eax
	.else
		xor		eax,eax
		mov		[esi].RECT.left,eax
		mov		[esi].RECT.top,eax
		mov		[esi].RECT.right,eax
		mov		[esi].RECT.bottom,eax
		mov		eax,LB_ERR
	.endif
	ret

GetItemRect endp

SetItem proc nRow:DWORD,dwItem:DWORD

	mov		ecx,nRow
	.if ecx<[ebx].GRID.rows
		mov		eax,[ebx].GRID.rpitemdata
		lea		eax,[ebx+eax]
		mov		edx,dwItem
		mov		[eax+ecx*4],edx
	.else
		mov		eax,LB_ERR
	.endif
	ret

SetItem endp

GetItem proc nRow:DWORD

	mov		ecx,nRow
	.if ecx<[ebx].GRID.rows
		mov		eax,[ebx].GRID.rpitemdata
		lea		eax,[ebx+eax]
		mov		eax,[eax+ecx*4]
	.else
		mov		eax,LB_ERR
	.endif
	ret

GetItem endp

InsertItem proc uses esi,nRow:DWORD,dwItem:DWORD
	LOCAL	rect:RECT

	mov		ecx,[ebx].GRID.rows
	mov		edx,[ebx].GRID.rpitemdata
	lea		esi,[ebx+edx]
	.while ecx>nRow
		dec		ecx
		mov		edx,[esi+ecx*4]
		mov		[esi+ecx*4+4],edx
	.endw
	mov		eax,dwItem
	mov		[esi+ecx*4],eax
	inc		[ebx].GRID.rows
	invoke GetClientRect,[ebx].GRID.hlst,addr rect
	push	rect.bottom
	invoke GetItemRect,nRow,addr rect
	pop		rect.bottom
	invoke InvalidateRect,[ebx].GRID.hlst,addr rect,TRUE
	mov		eax,nRow
	ret

InsertItem endp

DeleteItem proc uses esi,nRow:DWORD
	LOCAL	rect:RECT

	mov		ecx,nRow
	.if ecx<[ebx].GRID.rows
		invoke ShowHide,[ebx].GRID.hgrd,FALSE                 ; *** MOD add
		invoke GetClientRect,[ebx].GRID.hlst,addr rect
		mov		eax,nRow
		.if eax!=[ebx].GRID.toprow
			push	rect.bottom
			invoke GetItemRect,nRow,addr rect
			pop		rect.bottom
		.endif
		mov		eax,[ebx].GRID.rpitemdata
		lea		esi,[ebx+eax]
		mov		ecx,nRow
		.while ecx<[ebx].GRID.rows
			mov		eax,[esi+ecx*4+4]
			mov		[esi+ecx*4],eax
			inc		ecx
		.endw
		dec		[ebx].GRID.rows
		invoke InvalidateRect,[ebx].GRID.hlst,addr rect,TRUE
		mov		eax,[ebx].GRID.rows
	.else
		mov		eax,LB_ERR
	.endif
	ret

DeleteItem endp

RAListProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	dis:DRAWITEMSTRUCT
	LOCAL	hPar:HWND
	LOCAL	rect:RECT
	LOCAL	buffer[512]:BYTE
	LOCAL	hDC:HDC
	LOCAL	ftmp:DWORD

	mov		eax,uMsg
	.if eax>=WM_MOUSEFIRST && eax<=WM_MOUSELAST
		invoke GetParent,hWin
		invoke PostMessage,eax,uMsg,wParam,lParam
		mov		eax,uMsg
	.endif
	.if eax==WM_DRAWITEM
		assume esi:ptr DRAWITEMSTRUCT
		call	GetMem
		mov		esi,lParam
		.if [esi].itemID!=LB_ERR
			invoke SetBkMode,[esi].hdc,TRANSPARENT
			invoke GetWindowLong,[esi].hwndItem,GWL_ID
			movzx	eax,ax
			mov		ecx,sizeof COLUMN
			mul		ecx
			lea		edi,[ebx+eax+sizeof GRID]
			test	[esi].itemState,ODS_SELECTED
			.if ZERO?
				invoke SetTextColor,[esi].hdc,[ebx].GRID.coltext
				invoke FillRect,[esi].hdc,addr [esi].rcItem,[ebx].GRID.hbrback
			.else
				invoke GetSysColor,COLOR_HIGHLIGHTTEXT
				invoke SetTextColor,[esi].hdc,eax
				invoke FillRect,[esi].hdc,addr [esi].rcItem,COLOR_HIGHLIGHT+1
				.if [edi].COLUMN.himl
					invoke CopyRect,addr rect,addr [esi].rcItem
					mov		rect.right,18
					invoke FillRect,[esi].hdc,addr rect,[ebx].GRID.hbrback
				.endif
			.endif
			.if [edi].COLUMN.himl
				invoke CopyRect,addr rect,addr [esi].rcItem
				add		[esi].rcItem.left,18
				inc		rect.left
				mov		eax,rect.left
				add		eax,16
				mov		rect.right,eax
				invoke CreateRectRgn,rect.left,rect.top,rect.right,rect.bottom
				push	eax
				invoke SelectClipRgn,[esi].hdc,eax
				pop		eax
				invoke DeleteObject,eax
				invoke ImageList_Draw,[edi].COLUMN.himl,[esi].itemData,[esi].hdc,rect.left,rect.top,ILD_NORMAL
				invoke SelectClipRgn,[esi].hdc,NULL
			.endif
			mov		buffer,0
			invoke SendMessage,[esi].hwndItem,LB_GETTEXT,[esi].itemID,addr buffer
			invoke strlen,addr buffer
			mov		ecx,[esi].rcItem.left
			add		ecx,2
			mov		edx,[esi].rcItem.top
			inc		edx
			invoke TextOut,[esi].hdc,ecx,edx,addr buffer,eax
			invoke SetTextColor,[esi].hdc,0
		.endif
		xor		eax,eax
		call	RelMem
		assume esi:nothing
	.elseif eax==WM_CTLCOLORLISTBOX
		call	GetMem
		mov		eax,[ebx].GRID.hbrback
		push	eax
		call	RelMem
		pop		eax
		ret
	.elseif eax==WM_PAINT
		call	GetMem
		invoke GetFocus
		mov		esi,ODS_SELECTED
		.if eax==hWin
			mov		esi,ODS_FOCUS or ODS_SELECTED
		.endif
		invoke BeginPaint,hWin,addr ps
		invoke GetClientRect,[ebx].GRID.hgrd,addr rect
		mov		eax,[ebx].GRID.toprow
		mov		ecx,[ebx].GRID.hdrht
		sub		rect.bottom,ecx
		mov		ecx,[ebx].GRID.rowht
		sub		eax,[ebx].GRID.rows
		neg		eax
		mul		ecx
		mov		edx,eax
		mov		eax,[ebx].GRID.sbx
		add		rect.right,eax
		mov		eax,[ebx].GRID.ccx
		inc		eax
		.if eax<rect.right || edx<rect.bottom
			push	edx
			.if eax<rect.right
				mov		rect.left,eax
				invoke FillRect,ps.hdc,addr rect,[ebx].GRID.hbrback
				mov		eax,rect.left
				mov		rect.right,eax
			.endif
			pop		edx
			.if edx<rect.bottom
				mov		rect.top,edx
				mov		rect.left,0
				invoke FillRect,ps.hdc,addr rect,[ebx].GRID.hbrback
			.endif
		.endif
		invoke GetParent,hWin
		mov		hPar,eax
		mov		edi,[ebx].GRID.toprow
		mov		eax,ps.rcPaint.top
		mov		ecx,[ebx].GRID.rowht
		xor		edx,edx
		div		ecx
		add		edi,eax
		mul		ecx
		.while eax<ps.rcPaint.bottom
			push	eax
			.if edi<[ebx].GRID.rows
				mov		dis.rcItem.top,eax
				add		eax,[ebx].GRID.rowht
				mov		dis.rcItem.bottom,eax
				mov		eax,ps.rcPaint.left
				mov		dis.rcItem.left,0;eax
				mov		eax,ps.rcPaint.right
				mov		dis.rcItem.right,eax
				mov		eax,ps.hdc
				mov		dis.hdc,eax
				mov		dis.CtlType,ODT_LISTBOX
				mov		dis.CtlID,0
				mov		dis.itemID,edi
				mov		eax,[ebx].GRID.cols
				mov		edx,sizeof COLUMN
				mul		edx
				lea		eax,[ebx+eax+sizeof GRID]
				mov		eax,[eax+edi*4]
				mov		dis.itemData,eax
				mov		eax,hWin
				mov		dis.hwndItem,eax
				mov		dis.itemAction,ODA_DRAWENTIRE
				xor		eax,eax
				.if edi==[ebx].GRID.row
					mov		eax,esi
				.endif
				mov		dis.itemState,eax
				invoke SendMessage,hPar,WM_DRAWITEM,0,addr dis
			.endif
			pop		eax
			add		eax,[ebx].GRID.rowht
			inc		edi
		.endw
		invoke EndPaint,hWin,addr ps
		call	RelMem
		jmp		ExZ
	.elseif eax==WM_ERASEBKGND
		jmp		ExZ
	.elseif eax==WM_KEYDOWN
		mov		edx,wParam
		mov		eax,lParam
		shr		eax,16
		and		eax,3FFh
		.if edx==27h && (eax==14Dh || eax==4Dh)
			;Right
			call	GetMem
			mov		edx,[ebx].GRID.col
		@@:
			inc		edx
			.if edx<[ebx].GRID.cols
				mov		eax,edx
				push	edx
				mov		edx,sizeof COLUMN
				mul		edx
				pop		edx
				lea		eax,[ebx+eax+sizeof GRID]
				.if ![eax].COLUMN.colwt
					jmp		@b
				.endif
				invoke SendMessage,[ebx].GRID.hgrd,GM_SETCURSEL,edx,[ebx].GRID.row
				call	UpdateLastRowCol
			.endif
			jmp		Ex
		.elseif edx==25h && (eax==14Bh || eax==4Bh)
			;Left
			call	GetMem
			mov		edx,[ebx].GRID.col
		@@:
			.if edx
				dec		edx
				mov		eax,edx
				push	edx
				mov		edx,sizeof COLUMN
				mul		edx
				pop		edx
				lea		eax,[ebx+eax+sizeof GRID]
				.if ![eax].COLUMN.colwt
					jmp		@b
				.endif
				invoke SendMessage,[ebx].GRID.hgrd,GM_SETCURSEL,edx,[ebx].GRID.row
				call	UpdateLastRowCol
			.endif
			jmp		Ex
		.elseif edx==28h && (eax==150h || eax==50h)
			;Down
			call	GetMem
			mov		eax,[ebx].GRID.row
			inc		eax
			.if eax<[ebx].GRID.rows
				invoke SendMessage,[ebx].GRID.hgrd,GM_SETCURSEL,[ebx].GRID.col,eax
				call	UpdateLastRowCol
			.endif
			jmp		Ex
		.elseif edx==26h && (eax==148h || eax==48h)
			;Up
			call	GetMem
			mov		eax,[ebx].GRID.row
			.if eax
				dec		eax
				invoke SendMessage,[ebx].GRID.hgrd,GM_SETCURSEL,[ebx].GRID.col,eax
				call	UpdateLastRowCol
			.endif
			jmp		Ex
		.elseif edx==21h && (eax==149h || eax==49h)
			;PgUp
			call	GetMem
			.if [ebx].GRID.row
				invoke GetClientRect,hWin,addr rect
				mov		ecx,[ebx].GRID.rowht
				mov		eax,rect.bottom
				xor		edx,edx
				div		ecx
				mov		ecx,[ebx].GRID.row
				sub		ecx,eax
				.if CARRY?
					xor		ecx,ecx
				.endif
				invoke SendMessage,[ebx].GRID.hgrd,GM_SETCURSEL,[ebx].GRID.col,ecx
				call	UpdateLastRowCol
			.endif
			jmp		Ex
		.elseif edx==22h && (eax==151h || eax==51h)
			;PgDn
			call	GetMem
			invoke GetClientRect,hWin,addr rect
			mov		ecx,[ebx].GRID.rowht
			mov		eax,rect.bottom
			xor		edx,edx
			div		ecx
			mov		ecx,[ebx].GRID.row
			add		ecx,eax
			.if ecx>=[ebx].GRID.rows
				mov		ecx,[ebx].GRID.rows
				dec		ecx
			.endif
			invoke SendMessage,[ebx].GRID.hgrd,GM_SETCURSEL,[ebx].GRID.col,ecx
			call	UpdateLastRowCol
			jmp		Ex
		.elseif edx==24h && (eax==147h || eax==47h)
			;Home
			call	GetMem
			invoke SendMessage,[ebx].GRID.hgrd,GM_SETCURSEL,[ebx].GRID.col,0
			call	UpdateLastRowCol
			jmp		Ex
		.elseif edx==23h && (eax==14Fh || eax==4Fh)
			;End
			call	GetMem
			mov		eax,[ebx].GRID.rows
			dec		eax
			invoke SendMessage,[ebx].GRID.hgrd,GM_SETCURSEL,[ebx].GRID.col,eax
			call	UpdateLastRowCol
			jmp		Ex
		.endif
	.elseif eax==WM_CHAR
		call	GetMem
		.if wParam==VK_TAB
			invoke GetAsyncKeyState,VK_SHIFT
			invoke SendMessage,[ebx].GRID.hpar,WM_NEXTDLGCTL,eax,0
		.else
			invoke ShowHide,[ebx].GRID.hgrd,TRUE
			mov		edx,wParam
			.if edx!=VK_RETURN && eax
				invoke SendMessage,eax,WM_CHAR,wParam,lParam
			.endif
		.endif
		jmp		Ex
	.elseif eax==WM_LBUTTONDOWN
		call	GetMem
		invoke SetFocus,hWin
		invoke SetCapture,hWin
		push	ncol
		push	nrow
		invoke RAListProc,hWin,WM_MOUSEMOVE,wParam,lParam
		pop		edx
		pop		eax
		xor		ecx,ecx
		.if eax==[ebx].GRID.col && edx==[ebx].GRID.row
			inc		ecx
		.endif
		mov		fsame,ecx
		mov		eax,[ebx].GRID.col
		mov		edx,sizeof COLUMN
		mul		edx
		lea		edi,[ebx+eax+sizeof GRID]
		.if [edi].COLUMN.ctype==TYPE_CHECKBOX && fsame
			invoke ShowHide,[ebx].GRID.hgrd,TRUE
		.endif
		jmp		Ex
	.elseif eax==WM_LBUTTONUP
		call	GetMem
		invoke GetCapture
		.if eax==hWin
			invoke ReleaseCapture
			.if fonbtn && fsame
				.if fonbtn==TYPE_COMBOBOX || fonbtn==TYPE_EDITCOMBOBOX
					mov		ncol,-1
					mov		nrow,-1
				.endif
				mov		fsame,FALSE
				invoke ShowHide,[ebx].GRID.hgrd,TRUE
				mov		fonbtn,FALSE
			.endif
		.endif
		jmp		Ex
	.elseif eax==WM_MOUSEMOVE
		call	GetMem
		mov		fonbtn,FALSE
		invoke GetCapture
		.if eax==hWin
			lea		edi,[ebx+sizeof GRID]
			mov		eax,lParam
			shr		eax,16
			movsx	eax,ax
			.if sdword ptr eax<0
				invoke SendMessage,[ebx].GRID.hgrd,WM_VSCROLL,SB_LINEUP,0
				jmp		Ex
			.endif
			mov		eax,lParam
			movsx	eax,ax
			.if sdword ptr eax<0
				invoke SendMessage,[ebx].GRID.hgrd,WM_HSCROLL,SB_LINEUP,0
				jmp		Ex
			.endif
			xor		ecx,ecx
			xor		edx,edx
			.while ecx<[ebx].GRID.cols
				add		edx,[edi].COLUMN.colwt
				.if sdword ptr eax>=[edi].COLUMN.colxp && sdword ptr eax<=edx
					.if [edi].COLUMN.ctype==TYPE_COMBOBOX || [edi].COLUMN.ctype==TYPE_EDITCOMBOBOX || [edi].COLUMN.ctype==TYPE_BUTTON || [edi].COLUMN.ctype==TYPE_EDITBUTTON
						add		eax,[ebx].GRID.rowht
						.if eax>=edx
							mov		eax,[edi].COLUMN.ctype
							mov		fonbtn,eax
						.endif
					.endif
					.break
				.endif
				add		edi,sizeof COLUMN
				inc		ecx
			.endw
			.if ecx<[ebx].GRID.cols
				push	ecx
				push	[ebx].GRID.rows
				push	[ebx].GRID.toprow
				mov		eax,lParam
				shr		eax,16
				cdq
				mov		ecx,[ebx].GRID.rowht
				div		ecx
				pop		ecx
				add		eax,ecx
				pop		edx
				pop		ecx
				.if eax<edx
					.if ecx!=ncol || eax!=nrow
						mov		fsame,FALSE
						mov		fonbtn,FALSE
					.endif
					mov		ncol,ecx
					mov		nrow,eax
					invoke SendMessage,[ebx].GRID.hgrd,GM_SETCURSEL,ecx,eax
				.endif
			.endif
		.endif
		jmp		Ex
	.elseif eax==WM_LBUTTONDBLCLK
		call	GetMem
		mov		eax,[ebx].GRID.col
		mov		edx,sizeof COLUMN
		mul		edx
		lea		edi,[ebx+eax+sizeof GRID]
		.if [edi].COLUMN.ctype!=TYPE_COMBOBOX && [edi].COLUMN.ctype!=TYPE_EDITCOMBOBOX
			invoke ShowHide,[ebx].GRID.hgrd,TRUE
		.else
			lea		edi,[ebx+sizeof GRID]
			mov		eax,lParam
			movsx	eax,ax
			xor		ecx,ecx
			xor		edx,edx
			mov		ftmp,ecx
			.while ecx<[ebx].GRID.cols
				add		edx,[edi].COLUMN.colwt
				.if sdword ptr eax>=[edi].COLUMN.colxp && sdword ptr eax<=edx
					.if [edi].COLUMN.ctype==TYPE_COMBOBOX || [edi].COLUMN.ctype==TYPE_EDITCOMBOBOX
						add		eax,[ebx].GRID.rowht
						.if eax>=edx
							mov		eax,[edi].COLUMN.ctype
							mov		ftmp,eax
						.endif
					.endif
					.break
				.endif
				add		edi,sizeof COLUMN
				inc		ecx
			.endw
			.if ftmp
				invoke SetCapture,hWin
			.else
				invoke ShowHide,[ebx].GRID.hgrd,TRUE
			.endif
		.endif
		jmp		Ex
	.elseif eax==WM_SETFOCUS
		call	GetMem
		mov		eax,[ebx].GRID.hedt
		.if eax
			invoke ShowWindow,eax,SW_HIDE
			mov		[ebx].GRID.hedt,0
		.endif
		invoke GetItemRect,[ebx].GRID.row,addr rect
		invoke InvalidateRect,hWin,addr rect,TRUE
		call	RelMem
	.elseif eax==WM_KILLFOCUS
		call	GetMem
		invoke GetItemRect,[ebx].GRID.row,addr rect
		invoke InvalidateRect,hWin,addr rect,TRUE
		call	RelMem
	.elseif eax==WM_MOUSEWHEEL
		invoke GetParent,hWin
		invoke SendMessage,eax,uMsg,wParam,lParam
		jmp		ExZ
	.elseif eax==WM_GETDLGCODE
		mov		eax,DLGC_CODE
		jmp		ExRet
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
	ret
  Ex:
	call	RelMem
  ExZ:
	xor		eax,eax
  ExRet:
	ret

UpdateLastRowCol:
	mov		eax,[ebx].GRID.col
	mov		ncol,eax
	mov		eax,[ebx].GRID.row
	mov		nrow,eax
	retn

RelMem:
	push	eax
	invoke GetWindowLong,hWin,0
	invoke GlobalUnlock,eax
	pop		eax
	retn

GetMem:
	invoke GetWindowLong,hWin,0
	invoke GlobalLock,eax
	mov		ebx,eax
	retn

RAListProc endp

RAGridProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	mDC:HDC
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	rect2:RECT
	LOCAL	buffer[512]:BYTE
	LOCAL	val:DWORD
	LOCAL	sinf:SCROLLINFO
	LOCAL	curcol:DWORD
	LOCAL	gn:GRIDNOTIFY
	LOCAL	stime:SYSTEMTIME
	LOCAL	ftime:FILETIME
	LOCAL	dis:DRAWITEMSTRUCT
	LOCAL	fCol:DWORD
	LOCAL	rowcol:ROWCOLOR
	LOCAL	col:COLUMN

	mov		eax,uMsg
	.if eax==WM_DRAWITEM
		call	GetMem
		mov		esi,lParam
		assume esi:ptr DRAWITEMSTRUCT
		mov		eax,[esi].hwndItem
		.if eax==[ebx].GRID.hlst
			.if [esi].itemID!=LB_ERR
				invoke GridGetRowColor,ebx,[esi].itemData,addr rowcol
				mov		eax,[ebx].GRID.ccx
				inc		eax
				mov		[esi].rcItem.right,eax
				invoke CopyRect,addr rect2,addr [esi].rcItem
				invoke CreateCompatibleDC,[esi].hdc
				mov		mDC,eax
				invoke SelectObject,mDC,[ebx].GRID.hfont
				push	eax
				mov		ecx,rect2.right
				sub		ecx,rect2.left
				mov		edx,rect2.bottom
				sub		edx,rect2.top
				xor		eax,eax
				mov		rect2.left,eax
				mov		rect2.top,eax
				mov		rect2.right,ecx
				mov		rect2.bottom,edx
				invoke CreateCompatibleBitmap,[esi].hdc,ecx,edx
				invoke SelectObject,mDC,eax
				push	eax
				invoke SelectObject,mDC,[ebx].GRID.hpengrd
				push	eax
				mov		eax,[esi].itemID
				inc		eax
				sub		eax,[ebx].GRID.rows
				test	[ebx].GRID.style,STYLE_GRIDFRAME
				.if ZERO?
					dec		eax
				.endif
				test	[ebx].GRID.style,STYLE_HGRIDLINES
				.if !ZERO? || !eax
					dec		rect2.bottom
					invoke MoveToEx,mDC,rect2.left,rect2.bottom,NULL
					invoke LineTo,mDC,rect2.right,rect2.bottom
				.endif
				invoke SetBkMode,mDC,TRANSPARENT
				mov		eax,[ebx].GRID.style
				and		eax,STYLE_NOSEL
				xor		eax,STYLE_NOSEL
				.if !ZERO?
					mov		eax,ODS_SELECTED
				.endif
				test	[esi].itemState,eax
				.if ZERO?
					mov		eax,rowcol.textcolor
					.if eax==-1
						mov		eax,[ebx].GRID.coltext
					.endif
					invoke SetTextColor,mDC,eax
					mov		eax,rowcol.backcolor
					.if eax==-1
						invoke FillRect,mDC,addr rect2,[ebx].GRID.hbrback
					.else
						invoke CreateSolidBrush,eax
						push	eax
						invoke FillRect,mDC,addr rect2,eax
						pop		eax
						invoke DeleteObject,eax
					.endif
				.else
					invoke GetSysColor,COLOR_HIGHLIGHTTEXT
					invoke SetTextColor,mDC,eax
					invoke FillRect,mDC,addr rect2,COLOR_HIGHLIGHT+1
				.endif
				lea		edi,[ebx+sizeof GRID]
				xor		ecx,ecx
				.while ecx<[ebx].GRID.cols
					mov		curcol,ecx
					.if [edi].COLUMN.colwt
						mov		eax,[edi].COLUMN.colxp
						mov		rect2.left,eax
						add		eax,[edi].COLUMN.colwt
						mov		rect2.right,eax
						mov		eax,[edi].COLUMN.ctype
						mov		edx,[esi].itemData
						mov		buffer,0
						.if eax==TYPE_EDITTEXT
							invoke GridGetCellData,ebx,edx,ecx,addr buffer
							call	DrawItemText
							call	DrawItemLine
						.elseif eax==TYPE_EDITLONG
							invoke GridGetCellData,ebx,edx,ecx,addr val
							invoke BinToDec,val,addr buffer
							mov		eax,[edi].COLUMN.lpszformat
							.if eax
								call	Format
							.endif
							call	DrawItemText
							call	DrawItemLine
						.elseif eax==TYPE_CHECKBOX
							invoke GridGetCellData,ebx,edx,ecx,addr val
							invoke CopyRect,addr rect,addr rect2
							mov		eax,rect.bottom
							sub		eax,rect.top
							sub		eax,13
							shr		eax,1
							mov		edx,eax
							add		rect.top,eax
							mov		eax,rect.top
							add		eax,13
							mov		rect.bottom,eax
							mov		eax,[edi].COLUMN.calign
							.if eax==GA_ALIGN_LEFT
								inc		edx
								add		rect.left,edx
								mov		eax,rect.left
								add		eax,13
								mov		rect.right,eax
							.elseif eax==GA_ALIGN_CENTER
							.elseif eax==GA_ALIGN_RIGHT
								sub		rect.left,edx
								mov		eax,rect.right
								sub		eax,edx
								sub		eax,13
								mov		rect.left,eax
							.endif
							.if val
								mov		eax,DFCS_BUTTONCHECK or DFCS_FLAT or DFCS_CHECKED
							.else
								mov		eax,DFCS_BUTTONCHECK or DFCS_FLAT
							.endif
							invoke DrawFrameControl,mDC,addr rect,DFC_BUTTON,eax
							call	DrawItemLine
						.elseif eax==TYPE_COMBOBOX
							invoke GridGetCellData,ebx,edx,ecx,addr val
							call	DrawItemLine
							mov		ecx,curcol
							.if ecx==[ebx].GRID.col
								invoke CopyRect,addr rect,addr rect2
								mov		eax,rect.right
								sub		eax,17
								mov		rect.left,eax
								test	[esi].itemState,ODS_SELECTED
								.if !ZERO?
									sub		rect2.right,17
									mov		eax,DFCS_SCROLLDOWN
									.if fonbtn && fsame
										or		eax,DFCS_PUSHED
									.endif
									invoke DrawFrameControl,mDC,addr rect,DFC_SCROLL,eax
								.endif
							.endif
							mov		buffer,0
							xor		ecx,ecx
							.while TRUE
								push	ecx
								invoke SendMessage,[edi].COLUMN.edthwnd,LB_GETITEMDATA,ecx,0
								pop		ecx
								.break .if eax==val || eax==LB_ERR
								inc		ecx
							.endw
							.if eax!=LB_ERR
								invoke SendMessage,[edi].COLUMN.edthwnd,LB_GETTEXT,ecx,addr buffer
								.if [edi].COLUMN.himl
									invoke CopyRect,addr rect,addr rect2
									mov		eax,rect.left
									add		eax,2
									mov		rect.left,eax
									add		eax,16
									mov		rect.right,eax
									invoke CreateRectRgn,rect.left,rect.top,rect.right,rect.bottom
									push	eax
									invoke SelectClipRgn,mDC,eax
									pop		eax
									invoke DeleteObject,eax
									invoke ImageList_GetIconSize,[edi].COLUMN.himl,addr rect.right,addr rect.bottom
									add		rect2.left,19
									mov		eax,rect2.bottom
									sub		eax,rect2.top
									sub		eax,rect.bottom
									shr		eax,1
									cwde
									add		rect.top,eax
									invoke ImageList_Draw,[edi].COLUMN.himl,val,mDC,rect.left,rect.top,ILD_NORMAL
									invoke SelectClipRgn,mDC,NULL
								.endif
								call	DrawItemText
							.endif
						.elseif eax==TYPE_HOTKEY
							invoke GridGetCellData,ebx,edx,ecx,addr val
							test	val,HOTKEYF_CONTROL shl 8
							.if !ZERO?
								invoke lstrcat,addr buffer,offset szCtrl
							.endif
							test	val,HOTKEYF_SHIFT shl 8
							.if !ZERO?
								invoke lstrcat,addr buffer,offset szShift
							.endif
							test	val,HOTKEYF_ALT shl 8
							.if !ZERO?
								invoke lstrcat,addr buffer,offset szAlt
							.endif
							mov		edx,val
							movzx	edx,dl
							push	edx
							invoke strlen,addr buffer
							pop		edx
							.if edx>='A' && edx<='Z'
								mov		dword ptr buffer[eax],edx
							.elseif edx>=VK_F1 && edx<=VK_F12
								mov		dword ptr buffer[eax],'F'
								inc		eax
								sub		edx,VK_F1-1
								invoke BinToDec,edx,addr buffer[eax]
							.endif
							call	DrawItemText
							call	DrawItemLine
						.elseif eax==TYPE_EDITCOMBOBOX
							invoke GridGetCellData,ebx,edx,ecx,addr buffer
							call	DrawItemLine
							test	[esi].itemState,ODS_SELECTED
							.if !ZERO?
								mov		ecx,curcol
								.if ecx==[ebx].GRID.col
									invoke CopyRect,addr rect,addr rect2
									sub		rect2.right,17
									mov		eax,rect.right
									sub		eax,17
									mov		rect.left,eax
									mov		eax,DFCS_SCROLLDOWN
									.if fonbtn && fsame
										or		eax,DFCS_PUSHED
									.endif
									invoke DrawFrameControl,mDC,addr rect,DFC_SCROLL,eax
								.endif
							.endif
							call	DrawItemText
						.elseif eax==TYPE_BUTTON || eax==TYPE_EDITBUTTON
							invoke GridGetCellData,ebx,edx,ecx,addr buffer
							call	DrawItemLine
							test	[esi].itemState,ODS_SELECTED
							.if !ZERO?
								mov		ecx,curcol
								.if ecx==[ebx].GRID.col
									invoke CopyRect,addr rect,addr rect2
									sub		rect2.right,17
									mov		eax,rect.right
									sub		eax,17
									mov		rect.left,eax
									mov		eax,DFCS_BUTTONPUSH
									.if fonbtn && fsame
										or		eax,DFCS_PUSHED
									.endif
									invoke DrawFrameControl,mDC,addr rect,DFC_BUTTON,eax
									invoke GetTextColor,mDC
									push	eax
									invoke SetTextColor,mDC,0
									invoke GetStockObject,SYSTEM_FONT
									invoke SelectObject,mDC,eax
									push	eax
									mov		val,'...'
									mov		edx,rect.left
									add		edx,2
									invoke TextOut,mDC,edx,0,addr val,3
									pop		eax
									invoke SelectObject,mDC,eax
									pop		eax
									invoke SetTextColor,mDC,eax
								.endif
							.endif
							call	DrawItemText
						.elseif eax==TYPE_IMAGE
							invoke GridGetCellData,ebx,edx,ecx,addr val
							call	DrawItemLine
							.if [edi].COLUMN.himl
								invoke CopyRect,addr rect,addr rect2
								invoke CreateRectRgn,rect.left,rect.top,rect.right,rect.bottom
								push	eax
								invoke SelectClipRgn,mDC,eax
								pop		eax
								invoke DeleteObject,eax
								invoke ImageList_GetIconSize,[edi].COLUMN.himl,addr rect.right,addr rect.bottom
								mov		eax,[edi].COLUMN.calign
								.if eax==GA_ALIGN_LEFT
								.elseif eax==GA_ALIGN_CENTER
									mov		eax,rect2.right
									sub		eax,rect2.left
									sub		eax,rect.right
									shr		eax,1
									cwde
									add		rect.left,eax
								.else
									mov		eax,rect2.right
									sub		eax,rect.right
									mov		rect.left,eax
								.endif
								mov		eax,rect2.bottom
								sub		eax,rect2.top
								sub		eax,rect.bottom
								shr		eax,1
								cwde
								add		rect.top,eax
								invoke ImageList_Draw,[edi].COLUMN.himl,val,mDC,rect.left,rect.top,ILD_NORMAL
								invoke SelectClipRgn,mDC,NULL
							.endif
						.elseif eax==TYPE_DATE
							invoke GridGetCellData,ebx,edx,ecx,addr val
							;Days since 01.01.1601
							mov		eax,val
							;Convert to number of 100 nano seconds since 01.01.1601
							mov		ecx,24*60*60
							mul		ecx
							push	edx
							mov		ecx,1000*1000*10
							mul		ecx
							mov		ftime.dwLowDateTime,eax
							pop		eax
							push	edx
							mul		ecx
							pop		edx
							add		eax,edx
							mov		ftime.dwHighDateTime,eax
							invoke FileTimeToSystemTime,addr ftime,addr stime
							mov		eax,[edi].COLUMN.lpszformat
							.if eax
								lea		edx,buffer[512-64]
								invoke GridGetText,ebx,eax,edx
								lea		edx,buffer[512-64]
								invoke GetDateFormat,NULL,NULL,addr stime,edx,addr buffer,sizeof buffer
							.else
								invoke GetDateFormat,NULL,NULL,addr stime,NULL,addr buffer,sizeof buffer
							.endif
							call	DrawItemText
							call	DrawItemLine
						.elseif eax==TYPE_TIME
							invoke GridGetCellData,ebx,edx,ecx,addr val
							mov		eax,val
							mov		stime.wYear,2000
							mov		stime.wMonth,1
							mov		stime.wDayOfWeek,6
							mov		stime.wDay,1
							mov		ecx,60
							xor		edx,edx
							div		ecx
							mov		stime.wSecond,dx
							xor		edx,edx
							div		ecx
							mov		stime.wMinute,dx
							mov		stime.wHour,ax
							mov		stime.wMilliseconds,0
							mov		eax,[edi].COLUMN.lpszformat
							.if eax
								lea		edx,buffer[512-64]
								invoke GridGetText,ebx,eax,edx
								lea		edx,buffer[512-64]
								invoke GetTimeFormat,NULL,NULL,addr stime,edx,addr buffer,sizeof buffer
							.else
								invoke GetTimeFormat,NULL,NULL,addr stime,NULL,addr buffer,sizeof buffer
							.endif
							call	DrawItemText
							call	DrawItemLine
						.elseif eax==TYPE_USER
							invoke GridGetCellData,ebx,edx,ecx,addr buffer
							mov		ecx,[esi].itemID
							shl		ecx,16
							add		ecx,curcol
							call	SetNotify
							mov		gn.nmhdr.code,GN_USERCONVERT
							lea		eax,buffer
							mov		gn.lpdata,eax
							invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,gn.nmhdr.idFrom,addr gn
							call	DrawItemLine
							.if !gn.fcancel
								call	DrawItemText
							.else
								mov		eax,[ebx].GRID.nid
								mov		dis.CtlID,eax
								;Win98 strips off high word fron itemID so col must be stored in CtlType
								mov		ecx,[esi].itemID
								mov		dis.itemID,ecx
								mov		ecx,curcol
								mov		dis.CtlType,ecx
								mov		dis.itemAction,ODA_DRAWENTIRE
								mov		dis.itemState,NULL
								mov		eax,[ebx].GRID.hgrd
								mov		dis.hwndItem,eax
								mov		eax,mDC
								mov		dis.hdc,eax
								invoke CopyRect,addr dis.rcItem,addr rect2
								inc		dis.rcItem.left
								lea		eax,buffer
								mov		dis.itemData,eax
								invoke SendMessage,[ebx].GRID.hpar,WM_DRAWITEM,[ebx].GRID.nid,addr dis
							.endif
						.endif
						mov		ecx,curcol
						.if ecx==[ebx].GRID.col
							mov		eax,[ebx].GRID.style
							and		eax,STYLE_NOFOCUS
							xor		eax,STYLE_NOFOCUS
							.if !ZERO?
								mov		eax,ODS_FOCUS
								test	[ebx].GRID.style,STYLE_NOSEL
								.if !ZERO?
									or		eax,ODS_SELECTED
								.endif
							.endif
							test	[esi].itemState,eax
							.if !ZERO?
								invoke GetTextColor,mDC
								push	eax
								invoke SetTextColor,mDC,0
								invoke CopyRect,addr rect,addr rect2
								.if [ebx].GRID.col
									inc rect.left
								.endif
								invoke DrawFocusRect,mDC,addr rect
								test	[esi].itemState,ODS_FOCUS
								.if !ZERO?
									inc		rect.left
									inc		rect.top
									dec		rect.right
									dec		rect.bottom
									invoke DrawFocusRect,mDC,addr rect
								.endif
								pop		eax
								invoke SetTextColor,mDC,eax
							.endif
						.endif
					.endif
					add		edi,sizeof COLUMN
					mov		ecx,curcol
					inc		ecx
				.endw
				mov		ecx,[esi].rcItem.right
				sub		ecx,[esi].rcItem.left
				mov		edx,[esi].rcItem.bottom
				sub		edx,[esi].rcItem.top
				inc		edx
				invoke BitBlt,[esi].hdc,[esi].rcItem.left,[esi].rcItem.top,ecx,edx,mDC,0,0,SRCCOPY
				;Restore pen
				pop		eax
				invoke SelectObject,mDC,eax
				;Restore bitmap
				pop		eax
				invoke SelectObject,mDC,eax
				;Delete bitmap
				invoke DeleteObject,eax
				;Restore font
				pop		eax
				invoke SelectObject,mDC,eax
				invoke DeleteDC,mDC
			.endif
		.elseif eax==[ebx].GRID.hhdr
			invoke GetSysColor,COLOR_WINDOWTEXT
			invoke SetTextColor,[esi].hdc,eax
			invoke GetSysColor,COLOR_BTNFACE
			invoke SetBkColor,[esi].hdc,eax
			invoke ExtTextOut,[esi].hdc,0,0,ETO_OPAQUE,addr [esi].rcItem,NULL,0,NULL
			lea		edi,[ebx+sizeof GRID]
			xor		ecx,ecx
			mov		fCol,ecx
			.while ecx<[ebx].GRID.cols
				push	ecx
				.if [edi].COLUMN.colwt
					push	ecx
					mov		eax,[edi].COLUMN.colxp
					.if fCol
						inc		eax
					.endif
					mov		[esi].rcItem.left,eax
					add		eax,[edi].COLUMN.colwt
					.if !fCol
						inc		eax
					.endif
					inc		fCol
					mov		[esi].rcItem.right,eax
					test	[edi].COLUMN.hdrflag,1
					.if !ZERO?
						mov		eax,EDGE_SUNKEN
					.else
						mov		eax,EDGE_RAISED
					.endif
					invoke DrawEdge,[esi].hdc,addr [esi].rcItem,eax,BF_RECT
					add		[esi].rcItem.top,2
					add		[esi].rcItem.left,3
					sub		[esi].rcItem.right,3
					pop		ecx
					.if [edi].COLUMN.lpszhdrtext
						invoke SendMessage,hWin,GM_GETHDRTEXT,ecx,addr buffer
						invoke strlen,addr buffer
						mov		ecx,eax
						lea		edx,buffer
						mov		eax,[edi].COLUMN.halign
						.if eax==GA_ALIGN_LEFT
							mov		eax,DT_LEFT or DT_NOPREFIX
						.elseif eax==GA_ALIGN_CENTER
							mov		eax,DT_CENTER or DT_NOPREFIX
						.else
							mov		eax,DT_RIGHT or DT_NOPREFIX
						.endif
						test	[edi].COLUMN.hdrflag,1
						.if !ZERO?
							inc		[esi].rcItem.left
							inc		[esi].rcItem.top
							inc		[esi].rcItem.right
							invoke DrawText,[esi].hdc,edx,ecx,addr [esi].rcItem,eax
							dec		[esi].rcItem.left
							dec		[esi].rcItem.top
							dec		[esi].rcItem.right
						.else
							invoke DrawText,[esi].hdc,edx,ecx,addr [esi].rcItem,eax
						.endif
					.endif
					sub		[esi].rcItem.top,2
				.endif
				pop		ecx
				add		edi,sizeof COLUMN
				inc		ecx
				mov		eax,[esi].rcItem.right
				add		eax,3
				mov		[esi].rcItem.left,eax
			.endw
			mov		[esi].rcItem.right,9999
			invoke DrawEdge,[esi].hdc,addr [esi].rcItem,EDGE_RAISED,BF_RECT
		.endif
		assume esi:nothing
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_CTLCOLORLISTBOX
		call	GetMem
		mov		eax,[ebx].GRID.hbrback
		push	eax
		call	RelMem
		pop		eax
		ret
	.elseif eax==WM_SIZE
		call	GetMem
		call	SetScroll                    ; *** MOD
		;invoke GetClientRect,hWin,addr rect
		mov		rect.right,8192
		mov		eax,[ebx].GRID.sbx
		sub		rect.left,eax
		invoke MoveWindow,[ebx].GRID.hhdr,rect.left,0,rect.right,[ebx].GRID.hdrht,TRUE
		mov		eax,rect.bottom
		sub		eax,[ebx].GRID.hdrht
		invoke MoveWindow,[ebx].GRID.hlst,rect.left,[ebx].GRID.hdrht,rect.right,eax,TRUE
		;call	SetScroll
		call	RelMem
	.elseif eax==WM_DESTROY
		call	GetMem
		mov		esi,sizeof GRID
		.while esi<[ebx].GRID.rpitemdata
			.if [ebx+esi].COLUMN.edthwnd
				invoke DestroyWindow,[ebx+esi].COLUMN.edthwnd
			.endif
			add		esi,sizeof COLUMN
		.endw
		invoke DestroyWindow,[ebx].GRID.hsize
		invoke DestroyWindow,[ebx].GRID.hhdr
		invoke DestroyWindow,[ebx].GRID.hlst
		invoke DestroyCursor,[ebx].GRID.hcur
		.if [ebx].GRID.hbrback!=COLOR_WINDOW+1
			invoke DeleteObject,[ebx].GRID.hbrback
		.endif
		invoke DeleteObject,[ebx].GRID.hpengrd
		mov		eax,[ebx].GRID.hmem
		.if eax
			invoke GlobalFree,eax
		.endif
		mov		eax,[ebx].GRID.hstr
		.if eax
			invoke GlobalFree,eax
		.endif
		call	RelMem
		invoke GetWindowLong,hWin,0
		invoke GlobalFree,eax
		invoke SetWindowLong,hWin,0,0
	.elseif eax==WM_CREATE
		invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MEM_SIZE
		push	eax
		invoke SetWindowLong,hWin,0,eax
		call	GetMem
		mov		[ebx].GRID.itemmemsize,MEM_SIZE
		mov		[ebx].GRID.hdrht,18
		mov		[ebx].GRID.rowht,18
		mov		[ebx].GRID.cols,0
		mov		[ebx].GRID.rows,0
		invoke GetParent,hWin
		mov		[ebx].GRID.hpar,eax
		mov		eax,hWin
		mov		[ebx].GRID.hgrd,eax
		invoke GetWindowLong,hWin,GWL_ID
		mov		[ebx].GRID.nid,eax
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		[ebx].GRID.style,eax
		invoke CreateWindowEx,0,offset szStaticClass,NULL,WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or SS_BLACKRECT,0,0,0,0,hWin,NULL,hInstance,0
		mov		[ebx].GRID.hsize,eax
		invoke CreateWindowEx,0,offset szStaticClass,NULL,WS_VISIBLE or WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or SS_OWNERDRAW or SS_NOTIFY,0,0,0,0,hWin,NULL,hInstance,0
		mov		[ebx].GRID.hhdr,eax
		invoke SetWindowLong,[ebx].GRID.hhdr,GWL_WNDPROC,offset GridHdrProc
		invoke SetWindowLong,[ebx].GRID.hhdr,GWL_USERDATA,eax
		invoke CreateWindowEx,0,offset szRAListClass,NULL,WS_VISIBLE or WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or LBS_NOINTEGRALHEIGHT or LBS_OWNERDRAWFIXED or LBS_NOTIFY,0,0,0,0,hWin,NULL,hInstance,0
		mov		[ebx].GRID.hlst,eax
		pop		edx
		invoke SetWindowLong,eax,0,edx
		invoke LoadCursor,hInstance,IDC_VSIZE
		mov		[ebx].GRID.hcur,eax
		invoke GetSysColor,COLOR_WINDOW
		mov		[ebx].GRID.colback,eax
		mov		eax,COLOR_WINDOW+1
		mov		[ebx].GRID.hbrback,eax
		mov		eax,0C0C0C0h
		mov		[ebx].GRID.colgrid,eax
		invoke CreatePen,PS_SOLID,1,eax
		mov		[ebx].GRID.hpengrd,eax
		invoke GetSysColor,COLOR_WINDOWTEXT
		mov		[ebx].GRID.coltext,eax
		mov		[ebx].GRID.toprow,0
		mov		[ebx].GRID.rpitemdata,sizeof GRID
		mov		edx,lParam
		mov		edx,[edx].CREATESTRUCT.lpCreateParams
		.if edx
			movzx	eax,word ptr [edx]
			.if eax==12
				push	[edx+2]
				push	[edx+6]
				invoke SendMessage,hWin,GM_SETGRIDCOLOR,[edx+10],0
				pop		eax
				invoke SendMessage,hWin,GM_SETBACKCOLOR,eax,0
				pop		eax
				invoke SendMessage,hWin,GM_SETTEXTCOLOR,eax,0
			.endif
		.endif
		call	RelMem
	.elseif eax==WM_SETFONT
		call	GetMem
		mov		edi,wParam
		mov		[ebx].GRID.hfont,edi
		invoke SendMessage,[ebx].GRID.hhdr,WM_SETFONT,edi,FALSE
		invoke SendMessage,[ebx].GRID.hlst,WM_SETFONT,edi,FALSE
		call	RelMem
	.elseif eax==WM_SETFOCUS
		call	GetMem
		invoke SetFocus,[ebx].GRID.hlst
		call	RelMem
	.elseif eax==WM_MOUSEWHEEL
		mov		eax,wParam
		.if sdword ptr eax<0
			invoke SendMessage,hWin,WM_VSCROLL,SB_LINEDOWN,0
			invoke SendMessage,hWin,WM_VSCROLL,SB_LINEDOWN,0
			invoke SendMessage,hWin,WM_VSCROLL,SB_LINEDOWN,0
		.else
			invoke SendMessage,hWin,WM_VSCROLL,SB_LINEUP,0
			invoke SendMessage,hWin,WM_VSCROLL,SB_LINEUP,0
			invoke SendMessage,hWin,WM_VSCROLL,SB_LINEUP,0
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_VSCROLL
		call	GetMem
		mov		sinf.cbSize,sizeof sinf
		mov		sinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_VERT,addr sinf
		mov		eax,[ebx].GRID.toprow
		mov		ecx,[ebx].GRID.rowht
		mul		ecx
		mov		edx,wParam
		movzx	edx,dx
		.if edx==SB_THUMBTRACK || edx==SB_THUMBPOSITION
			mov		eax,sinf.nTrackPos
		.elseif edx==SB_LINEDOWN
			add		eax,ecx
			mov		edx,sinf.nMax
			sub		edx,sinf.nPage
			inc		edx
			.if eax>edx
				mov		eax,edx
			.endif
		.elseif edx==SB_LINEUP
			sub		eax,ecx
			jnc		@f
			xor		eax,eax
		  @@:
		.elseif edx==SB_PAGEDOWN
			add		eax,sinf.nPage
			mov		edx,sinf.nMax
			sub		edx,sinf.nPage
			inc		edx
			.if eax>edx
				mov		eax,edx
			.endif
		.elseif edx==SB_PAGEUP
			sub		eax,sinf.nPage
			jnb		@f
			xor		eax,eax
		  @@:
		.elseif edx==SB_BOTTOM
			mov		eax,sinf.nMax
			sub		eax,sinf.nPage
			inc		eax
		.elseif edx==SB_TOP
			xor		eax,eax
		.endif
		.if eax!=sinf.nPos
			mov		sinf.nPos,eax
			mov		ecx,[ebx].GRID.rowht
			xor		edx,edx
			div		ecx
			mov		[ebx].GRID.toprow,eax
			invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
			call	SetScroll
		.endif
		call	RelMem
	.elseif eax==WM_HSCROLL
		call	GetMem
		mov		sinf.cbSize,sizeof sinf
		mov		sinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_HORZ,addr sinf
		mov		eax,[ebx].GRID.sbx
		mov		edx,wParam
		movzx	edx,dx
		.if edx==SB_THUMBTRACK || edx==SB_THUMBPOSITION
			mov		eax,sinf.nTrackPos
		.elseif edx==SB_LINEDOWN
			add		eax,5
			mov		edx,sinf.nMax
			sub		edx,sinf.nPage
			inc		edx
			.if eax>edx
				mov		eax,edx
			.endif
		.elseif edx==SB_LINEUP
			sub		eax,5
			jnb		@f
			xor		eax,eax
		  @@:
		.elseif edx==SB_PAGEDOWN
			add		eax,sinf.nPage
			mov		edx,sinf.nMax
			sub		edx,sinf.nPage
			inc		edx
			.if eax>edx
				mov		eax,edx
			.endif
		.elseif edx==SB_PAGEUP
			sub		eax,sinf.nPage
			jnb		@f
			xor		eax,eax
		  @@:
		.elseif edx==SB_BOTTOM
			mov		eax,sinf.nMax
			sub		eax,sinf.nPage
			inc		eax
		.elseif edx==SB_TOP
			xor		eax,eax
		.endif
		mov		sinf.nPos,eax
		mov		edx,[ebx].GRID.sbx
		sub		edx,eax
		mov		[ebx].GRID.sbx,eax
		invoke ScrollWindow,hWin,edx,0,NULL,NULL
		call	SetScroll
		call	RelMem
	.elseif eax==GM_ADDCOL
		call	GetMem
		.if ![ebx].GRID.hmem
			mov		eax,[ebx].GRID.rpitemdata
			lea		edi,[ebx+eax]
			mov		esi,lParam
			mov		eax,[esi].COLUMN.colwt
			mov		[edi].COLUMN.colwt,eax
			mov		eax,[esi].COLUMN.lpszhdrtext
			mov		[edi].COLUMN.lpszhdrtext,eax
			mov		[edi].COLUMN.lpszformat,0
			mov		eax,[esi].COLUMN.halign
			mov		[edi].COLUMN.halign,eax
			mov		eax,[esi].COLUMN.calign
			mov		[edi].COLUMN.calign,eax
			mov		eax,[esi].COLUMN.ctextmax
			mov		[edi].COLUMN.ctextmax,eax
			mov		eax,[esi].COLUMN.hdrflag
			mov		[edi].COLUMN.hdrflag,eax
			mov		eax,[esi].COLUMN.lpszformat
			mov		[edi].COLUMN.lpszformat,eax
			mov		eax,[esi].COLUMN.lParam
			mov		[edi].COLUMN.lParam,eax
			mov		eax,[esi].COLUMN.ctype
			mov		[edi].COLUMN.ctype,eax
			.if eax==TYPE_EDITTEXT
				invoke CreateWindowEx,0,offset szEditClass,NULL,WS_CHILD or WS_BORDER or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or ES_AUTOHSCROLL,0,0,0,0,[ebx].GRID.hlst,NULL,hInstance,0
				mov		[edi].COLUMN.edthwnd,eax
				invoke SetWindowLong,eax,GWL_WNDPROC,offset EdtTextProc
				invoke SetWindowLong,[edi].COLUMN.edthwnd,GWL_USERDATA,eax
				mov		eax,[edi].COLUMN.ctextmax
				.if !eax || eax>511
					mov		eax,511
					mov		[edi].COLUMN.ctextmax,eax
				.endif
				invoke SendMessage,[edi].COLUMN.edthwnd,EM_LIMITTEXT,eax,0
			.elseif eax==TYPE_EDITLONG
				invoke CreateWindowEx,0,offset szEditClass,NULL,WS_CHILD or WS_BORDER or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or ES_AUTOHSCROLL or ES_RIGHT,0,0,0,0,[ebx].GRID.hlst,NULL,hInstance,0
				mov		[edi].COLUMN.edthwnd,eax
				invoke SetWindowLong,eax,GWL_WNDPROC,offset EdtLongProc
				invoke SetWindowLong,[edi].COLUMN.edthwnd,GWL_USERDATA,eax
				mov		eax,[edi].COLUMN.ctextmax
				.if !eax || eax>11
					mov		eax,11
					mov		[edi].COLUMN.ctextmax,eax
				.endif
				invoke SendMessage,[edi].COLUMN.edthwnd,EM_LIMITTEXT,eax,0
			.elseif eax==TYPE_COMBOBOX
				mov		eax,[esi].COLUMN.himl
				mov		[edi].COLUMN.himl,eax
				invoke CreateWindowEx,WS_EX_TOOLWINDOW,offset szListBoxClass,NULL,WS_CHILD or WS_BORDER or WS_VSCROLL or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or LBS_HASSTRINGS or LBS_SORT or LBS_OWNERDRAWFIXED,0,0,0,0,[ebx].GRID.hlst,NULL,hInstance,0
				mov		[edi].COLUMN.edthwnd,eax
				invoke SetWindowLong,eax,GWL_WNDPROC,offset LstProc
				mov		lplstproc,eax
				invoke SetWindowLong,[edi].COLUMN.edthwnd,GWL_USERDATA,[ebx].GRID.hgrd
				invoke GetDesktopWindow
				invoke SetParent,[edi].COLUMN.edthwnd,eax
				invoke SetWindowLong,[edi].COLUMN.edthwnd,GWL_STYLE,WS_POPUP or WS_BORDER or WS_VSCROLL or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or LBS_HASSTRINGS or LBS_SORT or LBS_OWNERDRAWFIXED
			.elseif eax==TYPE_HOTKEY
				invoke CreateWindowEx,0,offset szHotKeyClass,NULL,WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS,0,0,0,0,[ebx].GRID.hlst,NULL,hInstance,0
				mov		[edi].COLUMN.edthwnd,eax
				invoke SetWindowLong,eax,GWL_WNDPROC,offset HotProc
				invoke SetWindowLong,[edi].COLUMN.edthwnd,GWL_USERDATA,eax
			.elseif eax==TYPE_BUTTON
				mov		[edi].COLUMN.edthwnd,0
			.elseif eax==TYPE_EDITBUTTON
				invoke CreateWindowEx,0,offset szEditClass,NULL,WS_CHILD or WS_BORDER or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or ES_AUTOHSCROLL,0,0,0,0,[ebx].GRID.hlst,NULL,hInstance,0
				mov		[edi].COLUMN.edthwnd,eax
				invoke SetWindowLong,eax,GWL_WNDPROC,offset EdtTextProc
				invoke SetWindowLong,[edi].COLUMN.edthwnd,GWL_USERDATA,eax
				mov		eax,[edi].COLUMN.ctextmax
				.if !eax || eax>511
					mov		eax,511
					mov		[edi].COLUMN.ctextmax,eax
				.endif
				invoke SendMessage,[edi].COLUMN.edthwnd,EM_LIMITTEXT,eax,0
			.elseif eax==TYPE_IMAGE
				mov		eax,[esi].COLUMN.himl
				mov		[edi].COLUMN.himl,eax
			.elseif eax==TYPE_DATE
				invoke CreateWindowEx,0,offset szDateTimeClass,NULL,WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS,0,0,0,0,[ebx].GRID.hlst,NULL,hInstance,0
				mov		[edi].COLUMN.edthwnd,eax
				invoke SetWindowLong,eax,GWL_WNDPROC,offset DateTimeProc
				invoke SetWindowLong,[edi].COLUMN.edthwnd,GWL_USERDATA,eax
			.elseif eax==TYPE_TIME
				invoke CreateWindowEx,0,offset szDateTimeClass,NULL,WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or DTS_TIMEFORMAT or DTS_UPDOWN,0,0,0,0,[ebx].GRID.hlst,NULL,hInstance,0
				mov		[edi].COLUMN.edthwnd,eax
				invoke SetWindowLong,eax,GWL_WNDPROC,offset DateTimeProc
				invoke SetWindowLong,[edi].COLUMN.edthwnd,GWL_USERDATA,eax
			.elseif eax==TYPE_USER
				mov		eax,[esi].COLUMN.edthwnd
				mov		[edi].COLUMN.edthwnd,eax
				.if eax
					invoke SetParent,eax,[ebx].GRID.hlst
				.endif
			.elseif eax==TYPE_EDITCOMBOBOX
				mov		eax,[esi].COLUMN.himl
				mov		[edi].COLUMN.himl,eax
				invoke CreateWindowEx,WS_EX_TOOLWINDOW,offset szRAComboClass,NULL,WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS,0,0,0,0,[ebx].GRID.hlst,NULL,hInstance,0
				mov		[edi].COLUMN.edthwnd,eax
				invoke SetWindowLong,[edi].COLUMN.edthwnd,GWL_USERDATA,[ebx].GRID.hgrd
				invoke GetWindowLong,[edi].COLUMN.edthwnd,0
				mov		edx,[edi].COLUMN.ctextmax
				.if !edx || edx>511
					mov		edx,511
					mov		[edi].COLUMN.ctextmax,edx
				.endif
				invoke SendMessage,eax,EM_LIMITTEXT,edx,0
			.endif
			mov		eax,[edi].COLUMN.edthwnd
			.if eax
				push	eax
				invoke SendMessage,[ebx].GRID.hlst,WM_GETFONT,0,0
				pop		edx
				invoke SendMessage,edx,WM_SETFONT,eax,FALSE
			.endif
			mov		eax,[ebx].GRID.ccx
			mov		[edi].COLUMN.colxp,eax
			add		eax,[edi].COLUMN.colwt
			mov		[ebx].GRID.ccx,eax
			mov		edx,[ebx].GRID.cols
			inc		[ebx].GRID.cols
			add		[ebx].GRID.rpitemdata,sizeof COLUMN
			mov		eax,[edi].COLUMN.lpszhdrtext
			.if eax
				push	edx
				invoke SendMessage,hWin,GM_SETHDRTEXT,edx,eax
				pop		edx
			.endif
			mov		eax,[edi].COLUMN.lpszformat
			.if eax
				invoke SendMessage,hWin,GM_SETCOLFORMAT,edx,eax
			.endif
			invoke SendMessage,hWin,WM_SIZE,0,0
			mov		eax,[ebx].GRID.cols
			dec		eax
		.else
			;** Error, data in grid
			mov		eax,LB_ERR
		.endif
		call	RelMem
		jmp		Ex
	.elseif eax==GM_ADDROW
		call	GetMem
		.if [ebx].GRID.rows<65536
			call	ExpandItemMem
			.if eax
				invoke GridAddRowData,ebx,lParam
				invoke InsertItem,[ebx].GRID.rows,eax
				push	eax
				call	SetScroll
				pop		eax
			.else
				mov		eax,LB_ERR
			.endif
		.else
			mov		eax,LB_ERR
		.endif
		call	RelMem
		jmp		Ex
	.elseif eax==GM_INSROW
		call	GetMem
		.if [ebx].GRID.rows<65536
			call	ExpandItemMem
			.if eax
				invoke GridAddRowData,ebx,lParam
				invoke InsertItem,wParam,eax
			.else
				mov		eax,LB_ERR
			.endif
		.else
			mov		eax,LB_ERR
		.endif
		call	RelMem
		jmp		Ex
	.elseif eax==GM_DELROW
		call	GetMem
		mov		eax,[ebx].GRID.rows
		.if eax
			invoke DeleteItem,wParam
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_MOVEROW
		call	GetMem
		mov		eax,wParam
		mov		ecx,lParam
		mov		edx,[ebx].GRID.rows
		.if eax<edx && ecx<edx
			invoke GetItem,wParam
			push	eax
			invoke DeleteItem,wParam
			pop		eax
			invoke InsertItem,lParam,eax
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_COMBOADDSTRING
		call	GetMem
		mov		eax,wParam
		.if eax<[ebx].GRID.cols
			mov		edx,sizeof COLUMN
			mul		edx
			lea		edi,[ebx+eax+sizeof GRID]
			.if [edi].COLUMN.ctype==TYPE_COMBOBOX
				invoke SendMessage,[edi].COLUMN.edthwnd,LB_GETCOUNT,0,0
				push	eax
				invoke SendMessage,[edi].COLUMN.edthwnd,LB_ADDSTRING,0,lParam
				pop		edx
				invoke SendMessage,[edi].COLUMN.edthwnd,LB_SETITEMDATA,eax,edx
			.elseif [edi].COLUMN.ctype==TYPE_EDITCOMBOBOX
				invoke GetWindowLong,[edi].COLUMN.edthwnd,4
				invoke SendMessage,eax,LB_ADDSTRING,0,lParam
			.endif
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_COMBOCLEAR
		call	GetMem
		mov		eax,wParam
		.if eax<[ebx].GRID.cols
			mov		edx,sizeof COLUMN
			mul		edx
			lea		edi,[ebx+eax+sizeof GRID]
			.if [edi].COLUMN.ctype==TYPE_COMBOBOX
				invoke SendMessage,[edi].COLUMN.edthwnd,LB_RESETCONTENT,0,0
				invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
			.elseif [edi].COLUMN.ctype==TYPE_EDITCOMBOBOX
				invoke GetWindowLong,[edi].COLUMN.edthwnd,4
				invoke SendMessage,eax,LB_RESETCONTENT,0,0
				invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
			.endif
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_GETCURSEL
		call	GetMem
		mov		eax,[ebx].GRID.row
		shl		eax,16
		add		eax,[ebx].GRID.col
		call	RelMem
		jmp		Ex
	.elseif eax==GM_SETCURSEL
		call	GetMem
		mov		edx,lParam
		mov		eax,wParam
		.if eax<[ebx].GRID.cols && edx<[ebx].GRID.rows
			mov		ecx,edx
			shl		ecx,16
			add		ecx,eax
			call	SetNotify
			mov		gn.nmhdr.code,GN_BEFORESELCHANGE
			mov		gn.lpdata,0
			invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,gn.nmhdr.idFrom,addr gn
			.if !gn.fcancel
				mov		edx,gn.row
				mov		eax,gn.col
				.if edx<[ebx].GRID.rows && eax<[ebx].GRID.cols
					invoke GetItemRect,[ebx].GRID.row,addr rect
					invoke InvalidateRect,[ebx].GRID.hlst,addr rect,TRUE
					mov		eax,gn.col
					mov		[ebx].GRID.col,eax
					mov		edx,gn.row
					mov		[ebx].GRID.row,edx
					invoke GetItemRect,edx,addr rect
					invoke InvalidateRect,[ebx].GRID.hlst,addr rect,TRUE
					invoke SendMessage,hWin,GM_SCROLLCELL,0,0
				.endif
				mov		ecx,[ebx].GRID.row
				shl		ecx,16
				add		ecx,[ebx].GRID.col
				call	SetNotify
				mov		gn.nmhdr.code,GN_AFTERSELCHANGE
				mov		gn.lpdata,0
				invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,gn.nmhdr.idFrom,addr gn
				xor		eax,eax
				inc		eax
			.else
				xor		eax,eax
			.endif
		.else
			xor		eax,eax
		.endif
		call	RelMem
		jmp		Ex
	.elseif eax==GM_GETCURCOL
		call	GetMem
		mov		eax,[ebx].GRID.col
		call	RelMem
		jmp		Ex
	.elseif eax==GM_SETCURCOL
		call	GetMem
		invoke SendMessage,hWin,GM_SETCURSEL,wParam,[ebx].GRID.row
		call	RelMem
		jmp		Ex
	.elseif eax==GM_GETCURROW
		call	GetMem
		mov		eax,[ebx].GRID.row
		push	eax
		call	RelMem
		pop		eax
		jmp		Ex
	.elseif eax==GM_SETCURROW
		call	GetMem
		invoke SendMessage,hWin,GM_SETCURSEL,[ebx].GRID.col,wParam
		call	RelMem
		jmp		Ex
	.elseif eax==GM_GETCOLCOUNT
		call	GetMem
		mov		eax,[ebx].GRID.cols
		call	RelMem
		jmp		Ex
	.elseif eax==GM_GETROWCOUNT
		call	GetMem
		mov		eax,[ebx].GRID.rows
		call	RelMem
		jmp		Ex
	.elseif eax==GM_GETCELLDATA
		call	GetMem
		mov		eax,wParam
		shr		eax,16
		invoke GetItem,eax
		mov		ecx,wParam
		movzx	ecx,cx
		invoke GridGetCellData,ebx,eax,ecx,lParam
		call	RelMem
		jmp		Ex
	.elseif eax==GM_SETCELLDATA
		call	GetMem
		mov		ecx,[ebx].GRID.row
		shl		ecx,16
		add		ecx,[ebx].GRID.col
		call	SetNotify
		mov		gn.nmhdr.code,GN_BEFOREUPDATE
		mov		eax,lParam
		mov		gn.lpdata,eax
		invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,gn.nmhdr.idFrom,addr gn
		.if !gn.fcancel
			mov		eax,wParam
			shr		eax,16
			invoke GetItem,eax
			mov		ecx,wParam
			movzx	ecx,cx
			invoke GridSetCellData,ebx,eax,ecx,lParam
			mov		ecx,wParam
			shr		ecx,16
			invoke GetItemRect,ecx,addr rect
			invoke InvalidateRect,[ebx].GRID.hlst,addr rect,TRUE
			mov		gn.nmhdr.code,GN_AFTERUPDATE
			invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,gn.nmhdr.idFrom,addr gn
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_GETCELLRECT
		call	GetMem
		xor		eax,eax
		mov		rect.left,eax
		mov		rect.top,eax
		mov		rect.right,eax
		mov		rect.bottom,eax
		mov		ecx,wParam
		movzx	ecx,cx
		.if ecx<[ebx].GRID.cols
			mov		eax,sizeof COLUMN
			mul		ecx
			lea		edi,[ebx+eax+sizeof GRID]
			mov		ecx,wParam
			shr		ecx,16
			.if ecx<[ebx].GRID.rows
				invoke GetItemRect,ecx,addr rect
				mov		eax,[edi].COLUMN.colxp
				sub		eax,[ebx].GRID.sbx
				mov		rect.left,eax
				add		eax,[edi].COLUMN.colwt
				mov		rect.right,eax
			.endif
		.endif
		invoke CopyRect,lParam,addr rect
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_SCROLLCELL
		call	GetMem
		invoke GetClientRect,[ebx].GRID.hlst,addr rect1
		.if rect1.right && rect1.bottom
			mov		ecx,[ebx].GRID.row
			shl		ecx,16
			add		ecx,[ebx].GRID.col
			invoke SendMessage,hWin,GM_GETCELLRECT,ecx,addr rect
			.if sdword ptr rect.top<0
				mov		eax,[ebx].GRID.row
				mov		[ebx].GRID.toprow,eax
				invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
			.else
				mov		eax,rect.bottom
				.if eax>rect1.bottom
					sub		eax,rect1.bottom
					cdq
					mov		ecx,[ebx].GRID.rowht
					div		ecx
					inc		eax
					push	eax
					mov		eax,[ebx].GRID.toprow
					pop		edx
					add		eax,edx
					mov		[ebx].GRID.toprow,eax
					invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
				.endif
			.endif
			.if sdword ptr rect.left<0
				mov		eax,rect.left
				add		[ebx].GRID.sbx,eax
				neg		eax
				invoke ScrollWindow,hWin,eax,0,NULL,NULL
			.else
				invoke GetClientRect,hWin,addr rect1
				mov		eax,rect.right
				.if eax>rect1.right
					sub		eax,rect1.right
					mov		edx,[ebx].GRID.sbx
					add		edx,eax
					cmp		rect.left,eax
					.if CARRY?
						mov		eax,rect.left
						mov		edx,eax
						add		edx,[ebx].GRID.sbx
					.endif
					mov		[ebx].GRID.sbx,edx
					neg		eax
					invoke ScrollWindow,hWin,eax,0,NULL,NULL
				.endif
			.endif
			call	SetScroll
		.else
			mov		[ebx].GRID.toprow,0
			invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_GETBACKCOLOR
		call	GetMem
		mov		eax,[ebx].GRID.colback
		call	RelMem
		jmp		Ex
	.elseif eax==GM_SETBACKCOLOR
		call	GetMem
		.if [ebx].GRID.hbrback!=COLOR_WINDOW+1
			invoke DeleteObject,[ebx].GRID.hbrback
		.endif
		mov		eax,wParam
		mov		[ebx].GRID.colback,eax
		invoke CreateSolidBrush,eax
		mov		[ebx].GRID.hbrback,eax
		invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_GETGRIDCOLOR
		call	GetMem
		mov		eax,[ebx].GRID.colgrid
		call	RelMem
		jmp		Ex
	.elseif eax==GM_SETGRIDCOLOR
		call	GetMem
		invoke DeleteObject,[ebx].GRID.hpengrd
		mov		eax,wParam
		mov		[ebx].GRID.colgrid,eax
		invoke CreatePen,PS_SOLID,1,eax
		mov		[ebx].GRID.hpengrd,eax
		invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_GETTEXTCOLOR
		call	GetMem
		mov		eax,[ebx].GRID.coltext
		call	RelMem
		jmp		Ex
	.elseif eax==GM_SETTEXTCOLOR
		call	GetMem
		mov		eax,wParam
		mov		[ebx].GRID.coltext,eax
		invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_ENTEREDIT
		call	GetMem
		mov		fCancelEdit,FALSE
		mov		eax,[ebx].GRID.hedt
		.if eax
			invoke ShowWindow,eax,SW_HIDE
			mov		[ebx].GRID.hedt,0
		.endif
		mov		eax,[ebx].GRID.rows
		.if eax
			mov		fCancelEdit,FALSE
			invoke SendMessage,hWin,GM_SETCURSEL,wParam,lParam
			mov		ecx,[ebx].GRID.row
			shl		ecx,16
			add		ecx,[ebx].GRID.col
			push	ecx
			invoke SendMessage,hWin,GM_GETCELLDATA,ecx,addr buffer
			pop		ecx
			push	ecx
			invoke SendMessage,hWin,GM_GETCELLRECT,ecx,addr rect
			pop		ecx
			push	ecx
			call	SetNotify
			mov		gn.nmhdr.code,GN_BEFOREEDIT
			lea		eax,buffer
			mov		gn.lpdata,eax
			mov		eax,[ebx].GRID.col
			mov		edx,sizeof COLUMN
			mul		edx
			lea		edi,[ebx+eax+sizeof GRID]
			mov		eax,[edi].COLUMN.edthwnd
			mov		gn.hwnd,eax
			invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,gn.nmhdr.idFrom,addr gn
			pop		ecx
			xor		eax,eax
			.if !gn.fcancel
				.if [edi].COLUMN.edthwnd && ([edi].COLUMN.ctype!=TYPE_EDITBUTTON || !fonbtn)
					mov		[ebx].GRID.edtrowcol,ecx
					invoke SetWindowLong,[edi].COLUMN.edthwnd,GWL_ID,ecx
					invoke SendMessage,[edi].COLUMN.edthwnd,WM_SETFONT,[ebx].GRID.hfont,FALSE
					invoke GetClientRect,[ebx].GRID.hlst,addr rect1
					dec		rect.top
					mov		ecx,[edi].COLUMN.colwt
					inc		ecx
					mov		edx,[ebx].GRID.rowht
					inc		edx
					.if [edi].COLUMN.ctype==TYPE_COMBOBOX
						push	ecx
						mov		eax,[edi].COLUMN.colxp
						mov		rect.left,eax
						add		rect.top,edx
						invoke GetDesktopWindow
						mov		edx,eax
						invoke GetClientRect,edx,addr rect1
						invoke ScreenToClient,[ebx].GRID.hgrd,addr rect1.right
						invoke SendMessage,[edi].COLUMN.edthwnd,LB_GETCOUNT,0,0
						push	eax
						invoke SendMessage,[edi].COLUMN.edthwnd,LB_GETITEMHEIGHT,0,0
						pop		ecx
						.if ecx>10
							mov		ecx,10
						.elseif !ecx
							mov		ecx,1
						.endif
						mul		ecx
						add		eax,2
						mov		edx,eax
						add		eax,rect.top
						add		eax,[ebx].GRID.rowht
						inc		eax
						.if eax>rect1.bottom
							sub		rect.top,edx
							mov		eax,[ebx].GRID.rowht
							inc		eax
							sub		rect.top,eax
						.endif
						pop		ecx
					.endif
					mov		eax,[edi].COLUMN.ctype
					.if eax==TYPE_EDITTEXT
						invoke MoveWindow,[edi].COLUMN.edthwnd,[edi].COLUMN.colxp,rect.top,ecx,edx,TRUE
						invoke SendMessage,[edi].COLUMN.edthwnd,WM_SETTEXT,0,addr buffer
						invoke SendMessage,[edi].COLUMN.edthwnd,EM_SETSEL,0,-1
					.elseif eax==TYPE_EDITBUTTON
						sub		ecx,[ebx].GRID.rowht
						invoke MoveWindow,[edi].COLUMN.edthwnd,[edi].COLUMN.colxp,rect.top,ecx,edx,TRUE
						invoke SendMessage,[edi].COLUMN.edthwnd,WM_SETTEXT,0,addr buffer
						invoke SendMessage,[edi].COLUMN.edthwnd,EM_SETSEL,0,-1
					.elseif eax==TYPE_EDITLONG
						invoke MoveWindow,[edi].COLUMN.edthwnd,[edi].COLUMN.colxp,rect.top,ecx,edx,TRUE
						mov		edx,dword ptr buffer
						invoke BinToDec,edx,addr buffer
						invoke SendMessage,[edi].COLUMN.edthwnd,WM_SETTEXT,0,addr buffer
						invoke SendMessage,[edi].COLUMN.edthwnd,EM_SETSEL,0,-1
					.elseif eax==TYPE_COMBOBOX
						push	ecx
						push	edx
						mov		eax,[edi].COLUMN.colxp
						mov		rect.left,eax
						invoke ClientToScreen,[ebx].GRID.hlst,addr rect
						pop		edx
						pop		ecx
						invoke MoveWindow,[edi].COLUMN.edthwnd,rect.left,rect.top,ecx,edx,TRUE
						mov		edx,dword ptr buffer
						xor		ecx,ecx
						.while TRUE
							push	ecx
							push	edx
							invoke SendMessage,[edi].COLUMN.edthwnd,LB_GETITEMDATA,ecx,0
							pop		edx
							pop		ecx
							.break .if eax==edx || eax==LB_ERR
							inc		ecx
						.endw
						.if eax!=LB_ERR
							invoke SendMessage,[edi].COLUMN.edthwnd,LB_SETCURSEL,ecx,0
						.endif
					.elseif eax==TYPE_HOTKEY
						invoke MoveWindow,[edi].COLUMN.edthwnd,[edi].COLUMN.colxp,rect.top,ecx,edx,TRUE
						mov		edx,dword ptr buffer
						invoke SendMessage,[edi].COLUMN.edthwnd,HKM_SETHOTKEY,edx,0
					.elseif eax==TYPE_DATE
						invoke MoveWindow,[edi].COLUMN.edthwnd,[edi].COLUMN.colxp,rect.top,ecx,edx,TRUE
						;Days since 01.01.1601
						mov		eax,dword ptr buffer
						;Convert to number of 100 nano seconds since 01.01.1601
						mov		ecx,24*60*60
						mul		ecx
						push	edx
						mov		ecx,1000*1000*10
						mul		ecx
						mov		ftime.dwLowDateTime,eax
						pop		eax
						push	edx
						mul		ecx
						pop		edx
						add		eax,edx
						mov		ftime.dwHighDateTime,eax
						invoke FileTimeToSystemTime,addr ftime,addr stime
						invoke SendMessage,[edi].COLUMN.edthwnd,DTM_SETSYSTEMTIME,0,addr stime
					.elseif eax==TYPE_TIME
						invoke MoveWindow,[edi].COLUMN.edthwnd,[edi].COLUMN.colxp,rect.top,ecx,edx,TRUE
						mov		eax,dword ptr buffer
						mov		stime.wYear,2000
						mov		stime.wMonth,1
						mov		stime.wDayOfWeek,6
						mov		stime.wDay,1
						mov		ecx,60
						xor		edx,edx
						div		ecx
						mov		stime.wSecond,dx
						xor		edx,edx
						div		ecx
						mov		stime.wMinute,dx
						mov		stime.wHour,ax
						mov		stime.wMilliseconds,0
						invoke SendMessage,[edi].COLUMN.edthwnd,DTM_SETSYSTEMTIME,0,addr stime
					.elseif eax==TYPE_USER
						invoke MoveWindow,[edi].COLUMN.edthwnd,[edi].COLUMN.colxp,rect.top,ecx,edx,TRUE
					.elseif eax==TYPE_EDITCOMBOBOX
						sub		ecx,[ebx].GRID.rowht
						invoke MoveWindow,[edi].COLUMN.edthwnd,[edi].COLUMN.colxp,rect.top,ecx,edx,TRUE
						invoke GetWindowLong,[edi].COLUMN.edthwnd,0
						push	eax
						mov		edx,eax
						invoke SendMessage,edx,WM_SETTEXT,0,addr buffer
						pop		edx
						invoke SendMessage,edx,EM_SETSEL,0,-1
						invoke GetWindowLong,[edi].COLUMN.edthwnd,4
						mov		edx,eax
						push	edx
						invoke SendMessage,edx,LB_FINDSTRINGEXACT,-1,addr buffer
						pop		edx
						invoke SendMessage,edx,LB_SETCURSEL,eax,0
						mov		edx,[ebx].GRID.rowht
						inc		edx
						mov		eax,[edi].COLUMN.colxp
						mov		rect.left,eax
						add		rect.top,edx
						invoke GetDesktopWindow
						mov		edx,eax
						invoke GetClientRect,edx,addr rect1
						invoke ScreenToClient,[ebx].GRID.hgrd,addr rect1.right
						invoke GetWindowLong,[edi].COLUMN.edthwnd,4
						push	eax
						invoke SendMessage,eax,LB_GETCOUNT,0,0
						push	eax
						invoke GetWindowLong,[edi].COLUMN.edthwnd,4
						invoke SendMessage,eax,LB_GETITEMHEIGHT,0,0
						pop		ecx
						.if ecx>10
							mov		ecx,10
						.elseif !ecx
							mov		ecx,1
						.endif
						mul		ecx
						add		eax,2
						mov		edx,eax
						add		eax,rect.top
						add		eax,[ebx].GRID.rowht
						inc		eax
						.if eax>rect1.bottom
							sub		rect.top,edx
							mov		eax,[ebx].GRID.rowht
							inc		eax
							sub		rect.top,eax
						.endif
						push	edx
						invoke ClientToScreen,[ebx].GRID.hlst,addr rect
						pop		edx
						pop		eax
						push	eax
						invoke MoveWindow,eax,rect.left,rect.top,[edi].COLUMN.colwt,edx,TRUE
						pop		eax
						.if fonbtn
							invoke ShowWindow,eax,SW_SHOWNA
						.endif
					.endif
					.if [edi].COLUMN.ctype==TYPE_EDITCOMBOBOX
						invoke ShowWindow,[edi].COLUMN.edthwnd,SW_SHOW
						invoke SetFocus,[edi].COLUMN.edthwnd

;						invoke GetWindowLong,[edi].COLUMN.edthwnd,0
;						invoke ShowWindow,eax,SW_SHOW
;
;						invoke GetWindowLong,[edi].COLUMN.edthwnd,0
;						invoke SetFocus,eax
;						;Get the edit window handle
;						invoke GetWindowLong,[edi].COLUMN.edthwnd,0
						mov		eax,[edi].COLUMN.edthwnd
					.else
						invoke ShowWindow,[edi].COLUMN.edthwnd,SW_SHOW
						invoke SetFocus,[edi].COLUMN.edthwnd
						;Get the edit window handle
						mov		eax,[edi].COLUMN.edthwnd
					.endif
				.else
					xor		esi,esi
					mov		eax,[edi].COLUMN.ctype
					.if eax==TYPE_CHECKBOX
						push	ecx
						call	SetNotify
						mov		gn.nmhdr.code,GN_CHECKCLICK
						lea		eax,buffer
						mov		gn.lpdata,eax
						invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,gn.nmhdr.idFrom,addr gn
						pop		ecx
						.if !gn.fcancel
							invoke SendMessage,hWin,GM_ENDEDIT,ecx,FALSE
							invoke InvalidateRect,[ebx].GRID.hlst,addr rect,TRUE
						.endif
					.elseif eax==TYPE_IMAGE
						call	SetNotify
						mov		gn.nmhdr.code,GN_IMAGECLICK
						mov		eax,[ebx].COLUMN.himl
						mov		gn.hwnd,eax
						lea		eax,buffer
						mov		gn.lpdata,eax
						invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,gn.nmhdr.idFrom,addr gn
					.elseif eax==TYPE_BUTTON || eax==TYPE_EDITBUTTON
						push	ecx
						call	SetNotify
						mov		gn.nmhdr.code,GN_BUTTONCLICK
						lea		eax,buffer
						mov		gn.lpdata,eax
						invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,gn.nmhdr.idFrom,addr gn
						pop		ecx
						.if !gn.fcancel
							mov		[ebx].GRID.hedt,-1
							lea		eax,buffer
							mov		[ebx].GRID.lpdata,eax
							invoke SendMessage,hWin,GM_ENDEDIT,ecx,FALSE
							invoke InvalidateRect,[ebx].GRID.hlst,addr rect,TRUE
						.endif
					.endif
					xor		eax,eax
				.endif
			.endif
		.endif
		mov		[ebx].GRID.hedt,eax
		call	RelMem
		jmp		Ex
	.elseif eax==GM_ENDEDIT
		call	GetMem
		mov		dword ptr buffer,0
		mov		eax,wParam
		movzx	eax,ax
		mov		ecx,sizeof COLUMN
		mul		ecx
		lea		edi,[ebx+eax+sizeof GRID]
		mov		eax,[edi].COLUMN.edthwnd
        .if ([ebx].GRID.hedt != 0) && ([ebx].GRID.hedt == eax || [ebx].GRID.hedt == -1)   ; *** MOD add
		;.if [ebx].GRID.hedt==eax || [ebx].GRID.hedt==-1
			.if !lParam
				mov		eax,[edi].COLUMN.ctype
				.if [ebx].GRID.hedt && [ebx].GRID.hedt!=-1
					.if eax==TYPE_EDITTEXT || eax==TYPE_EDITBUTTON
						invoke SendMessage,[ebx].GRID.hedt,WM_GETTEXT,sizeof buffer,addr buffer
					.elseif eax==TYPE_EDITCOMBOBOX
						invoke GetWindowLong,[ebx].GRID.hedt,0
						mov		edx,eax
						invoke SendMessage,edx,WM_GETTEXT,sizeof buffer,addr buffer
						invoke GetWindowLong,[ebx].GRID.hedt,4
						invoke ShowWindow,eax,SW_HIDE
					.elseif eax==TYPE_EDITLONG
						invoke SendMessage,[ebx].GRID.hedt,WM_GETTEXT,sizeof buffer,addr buffer
						invoke DecToBin,addr buffer
						mov		dword ptr buffer,eax
					.elseif eax==TYPE_COMBOBOX
						invoke SendMessage,[ebx].GRID.hedt,LB_GETCURSEL,0,0
						invoke SendMessage,[ebx].GRID.hedt,LB_GETITEMDATA,eax,0
						mov		dword ptr buffer,eax
					.elseif eax==TYPE_HOTKEY
						invoke SendMessage,[ebx].GRID.hedt,HKM_GETHOTKEY,0,0
						mov		dword ptr buffer,eax
					.elseif eax==TYPE_DATE
						invoke SendMessage,[ebx].GRID.hedt,DTM_GETSYSTEMTIME,0,addr stime
						invoke SystemTimeToFileTime,addr stime,addr ftime
						;Convert to days since 01.01.1601
						mov		ecx,10*1000*1000
						mov		eax,ftime.dwHighDateTime
						xor		edx,edx
						div		ecx
						mov		ftime.dwHighDateTime,eax
						mov		eax,ftime.dwLowDateTime
						div		ecx
						mov		ftime.dwLowDateTime,eax
						mov		ecx,24*60*60
						mov		edx,ftime.dwHighDateTime
						mov		eax,ftime.dwLowDateTime
						div		ecx
						mov		dword ptr buffer,eax
					.elseif eax==TYPE_TIME
						invoke SendMessage,[ebx].GRID.hedt,DTM_GETSYSTEMTIME,0,addr stime
						movzx	eax,stime.wHour
						mov		ecx,60
						mul		ecx
						movzx	edx,stime.wMinute
						add		eax,edx
						mul		ecx
						movzx	edx,stime.wSecond
						add		eax,edx
						mov		dword ptr buffer,eax
					.endif
				.else    ; [ebx].GRID.hedt=-1
					.if eax==TYPE_CHECKBOX
						invoke SendMessage,hWin,GM_GETCELLDATA,wParam,addr buffer
						mov		eax,dword ptr buffer
						and		eax,1
						xor		eax,1
						mov		dword ptr buffer,eax
					.elseif eax==TYPE_BUTTON || eax==TYPE_EDITBUTTON
					    DumpMem [ebx].GRID.lpdata, 16, "Hilfe"
						invoke strcpy,addr buffer,[ebx].GRID.lpdata
					.endif
				.endif
				mov		ecx,wParam
				call	SetNotify
				mov		gn.nmhdr.code,GN_AFTEREDIT
				lea		eax,buffer
				mov		gn.lpdata,eax
				mov		eax,[edi].COLUMN.edthwnd
				mov		gn.hwnd,eax
				invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,gn.nmhdr.idFrom,addr gn
				.if !gn.fcancel
					invoke SendMessage,hWin,GM_SETCELLDATA,wParam,addr buffer
					mov		eax,[ebx].GRID.hedt
					.if eax
						invoke ShowWindow,eax,SW_HIDE
						mov		[ebx].GRID.hedt,0
					.endif
				.endif
			.else
				mov		fCancelEdit,TRUE
				mov		eax,[ebx].GRID.hedt
				.if eax
					invoke ShowWindow,eax,SW_HIDE
					mov		[ebx].GRID.hedt,0
				.endif
				mov		fCancelEdit,FALSE
			.endif
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_GETCOLWIDTH
		call	GetMem
		mov		eax,wParam
		.if eax<[ebx].GRID.cols
			mov		ecx,sizeof COLUMN
			mul		ecx
			lea		edi,[ebx+eax+sizeof GRID]
			mov		eax,[edi].COLUMN.colwt
		.else
			xor		eax,eax
		.endif
		call	RelMem
		jmp		Ex
	.elseif eax==GM_SETCOLWIDTH
		call	GetMem
		mov		ecx,wParam
		.if ecx<[ebx].GRID.cols
			mov		eax,sizeof COLUMN
			mul		ecx
			lea		edi,[ebx+eax+sizeof GRID]
			mov		eax,lParam
			mov		[edi].COLUMN.colwt,eax
			mov		edx,[edi].COLUMN.colxp
			.while ecx<[ebx].GRID.cols
				mov		[edi].COLUMN.colxp,edx
				add		edx,[edi].COLUMN.colwt
				add		edi,sizeof COLUMN
				inc		ecx
			.endw
			mov		[ebx].GRID.ccx,edx
			invoke SendMessage,hWin,WM_SIZE,0,0
			invoke InvalidateRect,[ebx].GRID.hhdr,NULL,TRUE
			invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_GETHDRHEIGHT
		call	GetMem
		mov		eax,[ebx].GRID.hdrht
		call	RelMem
		jmp		Ex
	.elseif eax==GM_SETHDRHEIGHT
		call	GetMem
		mov		eax,lParam
		mov		[ebx].GRID.hdrht,eax
		invoke SendMessage,hWin,WM_SIZE,0,0
		invoke InvalidateRect,[ebx].GRID.hhdr,NULL,TRUE
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_GETROWHEIGHT
		call	GetMem
		mov		eax,[ebx].GRID.rowht
		call	RelMem
		jmp		Ex
	.elseif eax==GM_SETROWHEIGHT
		call	GetMem
		mov		eax,lParam
		.if eax
			mov		[ebx].GRID.rowht,eax
			invoke SendMessage,hWin,WM_SIZE,0,0
			invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_RESETCONTENT
		call	GetMem
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*32
		push	eax
		mov		edi,eax
		xor		eax,eax
		.while eax<[ebx].GRID.cols
			push	eax
			mov		ecx,sizeof COLUMN
			mul		ecx
			lea		eax,[ebx+eax+sizeof GRID]
			push	eax
			mov		eax,[eax].COLUMN.lpszhdrtext
			.if eax
				invoke GridGetText,ebx,eax,edi
				invoke strlen,edi
				lea		edi,[edi+eax+1]
			.endif
			pop		eax
			mov		eax,[eax].COLUMN.lpszformat
			.if eax
				invoke GridGetText,ebx,eax,edi
				invoke strlen,edi
				lea		edi,[edi+eax+1]
			.endif
			pop		eax
			inc		eax
		.endw
		invoke ShowHide,[ebx].GRID.hgrd,FALSE
		mov		eax,[ebx].GRID.hmem
		.if eax
			invoke GlobalFree,eax
			mov		eax,[ebx].GRID.hstr
			.if eax
				invoke GlobalFree,eax
			.endif
			xor		eax,eax
			mov		[ebx].GRID.toprow,eax
			mov		[ebx].GRID.hmem,eax
			mov		[ebx].GRID.rpmemfree,eax
			mov		[ebx].GRID.memsize,eax
			mov		[ebx].GRID.col,eax
			mov		[ebx].GRID.row,eax
			mov		[ebx].GRID.rows,eax
			mov		[ebx].GRID.hstr,eax
			mov		[ebx].GRID.rpstrfree,eax
			mov		[ebx].GRID.strsize,eax
		.endif
		pop		edi
		push	edi
		xor		eax,eax
		.while eax<[ebx].GRID.cols
			push	eax
			mov		edx,sizeof COLUMN
			mul		edx
			lea		eax,[ebx+eax+sizeof GRID]
			push	eax
			.if [eax].COLUMN.lpszhdrtext
				push	eax
				invoke GridAddText,ebx,edi
				pop		edx
				mov		[edx].COLUMN.lpszhdrtext,eax
				invoke strlen,edi
				lea		edi,[edi+eax+1]
			.endif
			pop		eax
			.if [eax].COLUMN.lpszformat
				push	eax
				invoke GridAddText,ebx,edi
				pop		edx
				mov		[edx].COLUMN.lpszformat,eax
				invoke strlen,edi
				lea		edi,[edi+eax+1]
			.endif
			pop		eax
			inc		eax
		.endw
		invoke SendMessage,hWin,WM_SIZE,0,0
		invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
		pop		edi
		invoke GlobalFree,edi
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_COLUMNSORT
		call	GetMem
		invoke ShowHide,[ebx].GRID.hgrd,FALSE
		.if [ebx].GRID.rows>1
			mov		eax,wParam
			.if eax<[ebx].GRID.cols
				invoke GridSortColumn,ebx,wParam,lParam
				invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
			.endif
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_GETHDRTEXT
		call	GetMem
		mov		eax,wParam
		.if eax<[ebx].GRID.cols
			mov		ecx,sizeof COLUMN
			mul		ecx
			lea		edi,[ebx+eax+sizeof GRID]
			mov		eax,[edi].COLUMN.lpszhdrtext
			.if eax
				invoke GridGetText,ebx,eax,lParam
			.else
				mov		eax,lParam
				mov		byte ptr [eax],0
			.endif
		.else
			xor		eax,eax
		.endif
		call	RelMem
		jmp		Ex
	.elseif eax==GM_SETHDRTEXT
		call	GetMem
		mov		eax,wParam
		.if eax<[ebx].GRID.cols
			mov		ecx,sizeof COLUMN
			mul		ecx
			lea		edi,[ebx+eax+sizeof GRID]
			mov		eax,lParam
			.if eax
				invoke GridAddText,ebx,lParam
			.endif
			mov		[edi].COLUMN.lpszhdrtext,eax
			invoke InvalidateRect,[ebx].GRID.hhdr,NULL,TRUE
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_GETCOLFORMAT
		call	GetMem
		mov		eax,wParam
		.if eax<[ebx].GRID.cols
			mov		ecx,sizeof COLUMN
			mul		ecx
			lea		edi,[ebx+eax+sizeof GRID]
			mov		eax,[edi].COLUMN.lpszformat
			.if eax
				invoke GridGetText,ebx,eax,lParam
			.else
				mov		eax,lParam
				mov		byte ptr [eax],0
			.endif
		.else
			xor		eax,eax
		.endif
		call	RelMem
		jmp		Ex
	.elseif eax==GM_SETCOLFORMAT
		call	GetMem
		mov		eax,wParam
		.if eax<[ebx].GRID.cols
			mov		ecx,sizeof COLUMN
			mul		ecx
			lea		edi,[ebx+eax+sizeof GRID]
			mov		eax,lParam
			.if eax
				invoke GridAddText,ebx,lParam
			.endif
			mov		[edi].COLUMN.lpszformat,eax
			invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_CELLCONVERT
		mov		edx,lParam
		mov		byte ptr [edx],0
		call	GetMem
		mov		eax,wParam
		movzx	eax,ax
		.if eax<[ebx].GRID.cols
			mov		ecx,sizeof COLUMN
			mul		ecx
			lea		edi,[ebx+eax+sizeof GRID]
			mov		eax,[edi].COLUMN.ctype
			.if eax==TYPE_EDITTEXT || eax==TYPE_BUTTON || eax==TYPE_EDITBUTTON
				invoke SendMessage,hWin,GM_GETCELLDATA,wParam,lParam
			.elseif eax==TYPE_EDITLONG || eax==TYPE_IMAGE
				invoke SendMessage,hWin,GM_GETCELLDATA,wParam,addr val
				invoke BinToDec,val,lParam
			.elseif eax==TYPE_CHECKBOX
				invoke SendMessage,hWin,GM_GETCELLDATA,wParam,addr val
				.if val
					mov		eax,'seY'
				.else
					mov		eax,'oN'
				.endif
				mov		edx,lParam
				mov		[edx],eax
			.elseif eax==TYPE_COMBOBOX
				invoke SendMessage,hWin,GM_GETCELLDATA,wParam,addr val
				xor		ecx,ecx
				.while TRUE
					push	ecx
					invoke SendMessage,[edi].COLUMN.edthwnd,LB_GETITEMDATA,ecx,0
					pop		ecx
					.break .if eax==val || eax==LB_ERR
					inc		ecx
				.endw
				.if eax!=LB_ERR
					invoke SendMessage,[edi].COLUMN.edthwnd,LB_GETTEXT,ecx,lParam
				.endif
			.elseif eax==TYPE_HOTKEY
				invoke SendMessage,hWin,GM_GETCELLDATA,wParam,addr val
				test	val,HOTKEYF_CONTROL shl 8
				.if !ZERO?
					invoke lstrcat,lParam,offset szCtrl
				.endif
				test	val,HOTKEYF_SHIFT shl 8
				.if !ZERO?
					invoke lstrcat,lParam,offset szShift
				.endif
				test	val,HOTKEYF_ALT shl 8
				.if !ZERO?
					invoke lstrcat,lParam,offset szAlt
				.endif
				invoke strlen,lParam
				add		eax,lParam
				mov		edx,val
				movzx	edx,dl
				.if edx>='A' && edx<='Z'
					mov		[eax],edx
				.elseif edx>=VK_F1 && edx<=VK_F12
					mov		dword ptr [eax],'F'
					inc		eax
					sub		edx,VK_F1-1
					invoke BinToDec,edx,eax
				.endif
			.elseif eax==TYPE_DATE
				invoke SendMessage,hWin,GM_GETCELLDATA,wParam,addr val
				;Days since 01.01.1601
				mov		eax,val
				;Convert to number of 100 nano seconds since 01.01.1601
				mov		ecx,24*60*60
				mul		ecx
				push	edx
				mov		ecx,1000*1000*10
				mul		ecx
				mov		ftime.dwLowDateTime,eax
				pop		eax
				push	edx
				mul		ecx
				pop		edx
				add		eax,edx
				mov		ftime.dwHighDateTime,eax
				invoke FileTimeToSystemTime,addr ftime,addr stime
				mov		eax,[edi].COLUMN.lpszformat
				.if eax
					lea		edx,buffer[512-64]
					invoke GridGetText,ebx,eax,edx
					lea		edx,buffer[512-64]
					invoke GetDateFormat,NULL,NULL,addr stime,edx,addr buffer,sizeof buffer
				.else
					invoke GetDateFormat,NULL,NULL,addr stime,NULL,addr buffer,sizeof buffer
				.endif
				invoke strcpy,lParam,addr buffer
			.elseif eax==TYPE_TIME
				invoke SendMessage,hWin,GM_GETCELLDATA,wParam,addr val
				mov		eax,val
				mov		stime.wYear,2000
				mov		stime.wMonth,1
				mov		stime.wDayOfWeek,6
				mov		stime.wDay,1
				mov		ecx,60
				xor		edx,edx
				div		ecx
				mov		stime.wSecond,dx
				xor		edx,edx
				div		ecx
				mov		stime.wMinute,dx
				mov		stime.wHour,ax
				mov		stime.wMilliseconds,0
				mov		eax,[edi].COLUMN.lpszformat
				.if eax
					lea		edx,buffer[512-64]
					invoke GridGetText,ebx,eax,edx
					lea		edx,buffer[512-64]
					invoke GetTimeFormat,NULL,NULL,addr stime,edx,addr buffer,sizeof buffer
				.else
					invoke GetTimeFormat,NULL,NULL,addr stime,NULL,addr buffer,sizeof buffer
				.endif
				invoke strcpy,lParam,addr buffer
			.elseif eax==TYPE_USER
				invoke SendMessage,hWin,GM_GETCELLDATA,wParam,addr buffer
				mov		ecx,wParam
				call	SetNotify
				mov		gn.nmhdr.code,GN_USERCONVERT
				lea		eax,buffer
				mov		gn.lpdata,eax
				invoke SendMessage,[ebx].GRID.hpar,WM_NOTIFY,gn.nmhdr.idFrom,addr gn
				.if !gn.fcancel
					invoke strcpy,lParam,addr buffer
				.endif
			.endif
		.endif
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_RESETCOLUMNS
		invoke SendMessage,hWin,GM_RESETCONTENT,0,0
		call	GetMem
		lea		edi,[ebx+sizeof GRID]
		mov		ecx,[ebx].GRID.cols
		.while ecx
			mov		eax,[edi].COLUMN.edthwnd
			.if eax
				push	ecx
				invoke DestroyWindow,eax
				pop		ecx
			.endif
			add		edi,sizeof COLUMN
			dec		ecx
		.endw
		xor		eax,eax
		mov		[ebx].GRID.cols,eax
		mov		[ebx].GRID.ccx,eax
		mov		[ebx].GRID.sbx,eax
		mov		[ebx].GRID.rpitemdata,sizeof GRID
		invoke SendMessage,hWin,WM_SIZE,0,0
		invoke InvalidateRect,[ebx].GRID.hhdr,NULL,TRUE
		invoke InvalidateRect,[ebx].GRID.hlst,NULL,TRUE
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_GETROWCOLOR
		call	GetMem
		invoke GetItem,wParam
		invoke GridGetRowColor,ebx,eax,lParam
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_SETROWCOLOR
		call	GetMem
		invoke GetItem,wParam
		invoke GridSetRowColor,ebx,eax,lParam
		call	RelMem
		xor		eax,eax
		jmp		Ex
	.elseif eax==GM_GETCOLDATA
		call	GetMem
		mov		eax,wParam
		.if eax<[ebx].GRID.cols
			mov		ecx,sizeof COLUMN
			mul		ecx
			lea		esi,[ebx+eax+sizeof GRID]
			mov		edi,lParam
			rep movsb
			xor		eax,eax
		.else
			xor		eax,eax
			dec		eax
		.endif
		call	RelMem
		jmp		Ex
	.elseif eax==GM_COMBOFINDSTRING
		call	GetMem
		mov		esi,-1
		mov		eax,wParam
		.if eax<[ebx].GRID.cols
			mov		edx,sizeof COLUMN
			mul		edx
			lea		edi,[ebx+eax+sizeof GRID]
			.if [edi].COLUMN.ctype==TYPE_COMBOBOX
				invoke SendMessage,[edi].COLUMN.edthwnd,LB_FINDSTRINGEXACT,-1,lParam
				mov		esi,eax
			.elseif [edi].COLUMN.ctype==TYPE_EDITCOMBOBOX
				invoke GetWindowLong,[edi].COLUMN.edthwnd,4
				invoke SendMessage,eax,LB_FINDSTRINGEXACT,-1,lParam
				mov		esi,eax
			.endif
		.endif
		call	RelMem
		mov		eax,esi
		jmp		Ex
	.elseif eax==WM_USER+9999
		xor		eax,eax
		mov		col.colwt,100
		mov		col.lpszhdrtext,offset szToolTip
		mov		col.halign,eax
		mov		col.calign,eax
		mov		col.ctype,eax
		mov		col.ctextmax,31
		mov		col.lpszformat,eax
		mov		col.himl,eax
		mov		col.hdrflag,eax
		mov		col.colxp,eax
		mov		col.edthwnd,eax
		invoke SendMessage,hWin,GM_ADDCOL,0,addr col
		mov		val,offset szToolTip
		invoke SendMessage,hWin,GM_ADDROW,0,addr val
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

Format:
	lea		edx,buffer[512-64]
	invoke GridGetText,ebx,eax,edx
	push	ebx
	push	esi
	push	edi
	lea		ebx,buffer[512-64]
	lea		edi,buffer[512-66]
	mov		byte ptr [edi+1],0
	lea		esi,buffer
	invoke strlen,ebx
	push	eax
	invoke strlen,esi
	mov		ecx,eax
	pop		edx
	.while ecx && edx
		mov		al,[esi+ecx-1]
		.if al!='-'
			dec		edx
			mov		al,[ebx+edx]
			.if al=='#'
				dec		ecx
				mov		al,[esi+ecx]
			.endif
		.else
			xor		ecx,ecx
		.endif
		mov		[edi],al
		dec		edi
	.endw
	inc		edi
	invoke strcpy,addr buffer,edi
	pop		edi
	pop		esi
	pop		ebx
	retn

SetNotify:
	mov		eax,hWin
	mov		gn.nmhdr.hwndFrom,eax
	mov		eax,[ebx].GRID.nid
	mov		gn.nmhdr.idFrom,eax
	mov		eax,[ebx].GRID.hedt
	mov		gn.hwnd,eax
	movzx	eax,cx
	shr		ecx,16
	mov		gn.col,eax
	mov		gn.row,ecx
	mov		gn.fcancel,FALSE
	retn

DrawItemText:
	assume esi:ptr DRAWITEMSTRUCT
	add		rect2.left,3
	add		rect2.top,2
	sub		rect2.right,3
	invoke strlen,addr buffer
	mov		ecx,eax
	mov		eax,[edi].COLUMN.calign
	.if eax==GA_ALIGN_LEFT
		mov		eax,DT_LEFT or DT_NOPREFIX
	.elseif eax==GA_ALIGN_CENTER
		mov		eax,DT_CENTER or DT_NOPREFIX
	.else
		mov		eax,DT_RIGHT or DT_NOPREFIX
	.endif
	invoke DrawText,mDC,addr buffer,ecx,addr rect2,eax
	sub		rect2.left,3
	sub		rect2.top,2
	add		rect2.right,3
	assume esi:nothing
	retn

DrawItemLine:
	assume esi:ptr DRAWITEMSTRUCT
	mov		eax,curcol
	inc		eax
	sub		eax,[ebx].GRID.cols
	test	[ebx].GRID.style,STYLE_GRIDFRAME
	.if ZERO?
		dec		eax
	.endif
	test	[ebx].GRID.style,STYLE_VGRIDLINES
	.if !ZERO? || !eax
		invoke MoveToEx,mDC,rect2.right,rect2.top,NULL
		invoke LineTo,mDC,rect2.right,rect2.bottom
	.endif
	assume esi:nothing
	retn

SetScroll:
	invoke GetClientRect,hWin,addr rect
	.if rect.right && rect.bottom
		mov		eax,rect.bottom
		sub		eax,[ebx].GRID.hdrht
		jnb		@f
		xor		eax,eax
	  @@:
		mov		sinf.cbSize,sizeof sinf
		mov		sinf.fMask,SIF_ALL
		mov		ecx,[ebx].GRID.rowht
		xor		edx,edx
		div		ecx
		mul		ecx
		mov		sinf.nPage,eax
		mov		sinf.nMin,0
		mov		eax,[ebx].GRID.rows
		.if eax
			dec		eax
		.endif
		inc		eax
		mul		ecx
		dec		eax
		mov		sinf.nMax,eax
		mov		eax,[ebx].GRID.toprow
		mul		ecx
		mov		sinf.nPos,eax
		invoke SetScrollInfo,hWin,SB_VERT,addr sinf,TRUE
        invoke GetClientRect,hWin,addr rect          ; MOD  rect is changed, if scrollbar hides itself
		mov		eax,rect.right
		mov		sinf.nPage,eax
		mov		eax,[ebx].GRID.ccx
		mov		sinf.nMax,eax
		mov		eax,[ebx].GRID.sbx
		mov		sinf.nPos,eax
		invoke SetScrollInfo,hWin,SB_HORZ,addr sinf,TRUE
		invoke GetClientRect,hWin,addr rect          ; MOD  rect is changed, if scrollbar hides itself
	.endif
	retn

RelMem:
	push	eax
	invoke GetWindowLong,hWin,0
	invoke GlobalUnlock,eax
	pop		eax
	retn

GetMem:
	invoke GetWindowLong,hWin,0
	invoke GlobalLock,eax
	mov		ebx,eax
	retn

ExpandItemMem:
	mov		eax,[ebx].GRID.rows
	inc		eax
	lea		eax,[eax*4]
	add		eax,[ebx].GRID.rpitemdata
	.if eax>[ebx].GRID.itemmemsize
		push	[ebx].GRID.hlst
		push	[ebx].GRID.itemmemsize
		call	RelMem
		invoke GetWindowLong,hWin,0
		pop		edx
		add		edx,MEM_SIZE
		invoke GlobalReAlloc,eax,edx,GMEM_MOVEABLE
		pop		edx
		.if eax
			mov		ebx,eax
			invoke SetWindowLong,edx,0,ebx
			invoke SetWindowLong,hWin,0,ebx
			call	GetMem
			add		[ebx].GRID.itemmemsize,MEM_SIZE
		.endif
	.endif
	retn

RAGridProc endp

;--------------------------------------------------------------------------------
;Create a windowclass for the user control
GridInstall proc public hInst:DWORD,fGlobal:DWORD
	LOCAL	wc:WNDCLASSEX

	push    hInst
	pop     hInstance
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	.if fGlobal
		mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_GLOBALCLASS
	.endif
	mov		wc.lpfnWndProc,offset RAGridProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,4		;Holds memory handle
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szRAGridClass
	mov		eax,NULL
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc

	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	mov		wc.lpfnWndProc,offset RAListProc
	mov		wc.lpszClassName,offset szRAListClass
	invoke RegisterClassEx,addr wc

	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	mov		wc.cbWndExtra,8		;Holds edit and list handle
	mov		wc.lpfnWndProc,offset RAComboProc
	mov		wc.lpszClassName,offset szRAComboClass
	invoke RegisterClassEx,addr wc
	ret

GridInstall endp

GridUnInstall proc public

	ret

GridUnInstall endp

IFDEF DLL
	include dll.asm
ELSE
	include lib.asm
ENDIF

