.386
.model flat,stdcall
option casemap:none
option proc:private

include windows.inc
include Comctl32.inc
include user32.inc
include kernel32.inc
include gdi32.inc

includelib Comctl32.lib
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

include \Programme\RadASM\Masm\Inc\RADbg.inc
include masm32.inc
include \Programme\RadASM\Masm\Inc\Debug.Inc
includelib masm32.lib
includelib \Programme\RadASM\Masm\Lib\Debug.lib

include ..\RAHexEd.inc
include Data.inc
include Caret.asm
include Misc.asm
include Edit.asm
include Paint.asm
include Find.asm
include ClipBoard.asm
include Undo.asm
include Bookmark.asm

.code

TimerProc proc hWin:DWORD,uMsg:DWORD,idEvent:DWORD,dwTime:DWORD

	.if tmr1.hwnd
		invoke PostMessage,tmr1.hwnd,tmr1.umsg,tmr1.wparam,tmr1.lparam
	.endif
	.if tmr2.hwnd
		invoke PostMessage,tmr2.hwnd,tmr2.umsg,tmr2.wparam,tmr2.lparam
	.endif
	ret

TimerProc endp

RAHexEdInstall proc C public hInst:HINSTANCE,fGlobal:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	hBmp:DWORD

	;Create a windowclass for the user control
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	.if fGlobal
		mov		wc.style,CS_GLOBALCLASS or CS_HREDRAW or CS_VREDRAW
	.endif
	mov		wc.lpfnWndProc,offset RAWndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,4		;Holds memory handle
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szRAHexEdClassName
	mov		eax,NULL
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	push	eax
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_DBLCLKS or CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset RAHexEdProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,4		;Holds memory handle
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szHexChildClassName
	mov		eax,NULL
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_IBEAM
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke LoadCursor,hInst,IDC_HSPLITTCUR
	mov		hHSCur,eax
	invoke LoadCursor,hInst,IDC_SELECTCUR
	mov		hSelCur,eax
	invoke LoadBitmap,hInst,IDB_BOOKMARK
	mov		hBmp,eax
	invoke ImageList_Create,11,11,ILC_COLOR4,8,8
	mov		hIml,eax
	invoke ImageList_Add,hIml,hBmp,NULL
	invoke DeleteObject,hBmp
	invoke LoadBitmap,hInst,IDB_LINENUMBER
	mov		hBmpLnr,eax
	invoke SetTimer,NULL,0,50,offset TimerProc
	mov		TimerID,eax
	pop		eax
	ret

RAHexEdInstall endp

RAHexEdUnInstall proc public

	invoke KillTimer,NULL,TimerID
	invoke ImageList_Destroy,hIml
	invoke DeleteObject,hBmpLnr
	invoke DestroyCursor,hHSCur
	invoke DestroyCursor,hSelCur
	ret

RAHexEdUnInstall endp

SplittBtnProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_MOUSEMOVE
		invoke SetCursor,hHSCur
	.elseif eax==WM_LBUTTONDOWN
		invoke GetParent,hWin
		invoke GetWindowLong,eax,0
		mov		ebx,eax
		mov		[ebx].EDIT.fresize,1
		invoke SetCapture,[ebx].EDIT.hwnd
		invoke SetCursor,hHSCur
	.elseif eax==WM_LBUTTONDBLCLK
		invoke GetParent,hWin
		invoke GetWindowLong,eax,0
		mov		ebx,eax
		.if [ebx].EDIT.fsplitt
			mov		[ebx].EDIT.fsplitt,0
		.else
			mov		[ebx].EDIT.fsplitt,512
		.endif
		invoke SendMessage,[ebx].EDIT.hwnd,WM_SIZE,0,0
	.endif
	invoke CallWindowProc,OldSplittBtnProc,hWin,uMsg,wParam,lParam
	ret

SplittBtnProc endp

StateProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	hBr:DWORD

	.if uMsg==WM_PAINT
		invoke BeginPaint,hWin,addr ps
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		ebx,eax
		test	[ebx].EDIT.fstyle,HEX_STYLE_READONLY
		.if !ZERO?
			invoke CreateSolidBrush,0FFh
			mov		hBr,eax
		.elseif [ebx].EDIT.fChanged
			invoke CreateSolidBrush,0B000h
			mov		hBr,eax
		.else
			mov		hBr,0
			mov		eax,[ebx].EDIT.br.hBrSelBar
		.endif
		invoke FillRect,ps.hdc,addr ps.rcPaint,eax
		.if hBr
			invoke DeleteObject,hBr
		.endif
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
		ret
	.endif
	invoke CallWindowProc,OldStateProc,hWin,uMsg,wParam,lParam
	ret

StateProc endp

RAHexEdProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	sinf:SCROLLINFO
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	fControl:DWORD
	LOCAL	fShift:DWORD
	LOCAL	cpMin:DWORD
	LOCAL	cpMax:DWORD
	LOCAL	fSel:DWORD
	LOCAL	nChar:DWORD
	LOCAL	fIns:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	.if eax
		mov		eax,hWin
		.if eax==[ebx].EDIT.edta.hwnd
			lea		esi,[ebx].EDIT.edta
		.else
			lea		esi,[ebx].EDIT.edtb
		.endif
	.else
		.if uMsg!=WM_CREATE
			jmp		ExDef
		.endif
	.endif
	mov		eax,uMsg
	.if eax==WM_PAINT
		call	SetScroll
		invoke HexPaint,hWin
	.elseif eax==WM_SIZE
		mov		fSize,TRUE
		mov		eax,[ebx].EDIT.edta.hwnd
		.if eax==hWin
			invoke GetClientRect,hWin,addr [ebx].EDIT.edta.rc
			mov		eax,[ebx].EDIT.fstyle
			and		eax,HEX_STYLE_NOSPLITT or HEX_STYLE_NOVSCROLL
			.if eax!=HEX_STYLE_NOSPLITT or HEX_STYLE_NOVSCROLL
				sub		[ebx].EDIT.edta.rc.right,SBWT
				invoke MoveWindow,[ebx].EDIT.edta.hvscroll,[ebx].EDIT.edta.rc.right,0,SBWT,[ebx].EDIT.edta.rc.bottom,TRUE
			.else
				invoke MoveWindow,[ebx].EDIT.edta.hvscroll,0,0,0,0,TRUE
			.endif
		.else
			invoke GetClientRect,hWin,addr [ebx].EDIT.edtb.rc
			mov		eax,[ebx].EDIT.fstyle
			and		eax,HEX_STYLE_NOSPLITT or HEX_STYLE_NOVSCROLL
			.if eax!=HEX_STYLE_NOSPLITT or HEX_STYLE_NOVSCROLL
				sub		[ebx].EDIT.edtb.rc.right,SBWT
				mov		ecx,[ebx].EDIT.edtb.rc.bottom
				xor		edx,edx
				.if ![ebx].EDIT.nsplitt
					test	[ebx].EDIT.fstyle,HEX_STYLE_NOSPLITT
					.if ZERO?
						mov		edx,BTNHT
						sub		ecx,edx
					.endif
				.endif
				invoke MoveWindow,[ebx].EDIT.edtb.hvscroll,[ebx].EDIT.edtb.rc.right,edx,SBWT,ecx,TRUE
			.else
				invoke MoveWindow,[ebx].EDIT.edtb.hvscroll,0,0,0,0,TRUE
			.endif
		.endif
		invoke SetCaret,hWin
	.elseif eax==WM_KEYDOWN
		mov		eax,[ebx].EDIT.cpMin
		mov		ecx,[ebx].EDIT.cpMax
		.if eax>ecx
			xchg	eax,ecx
		.endif
		mov		cpMin,eax
		mov		cpMax,ecx
		sub		ecx,eax
		mov		fSel,ecx
		mov		sinf.cbSize,sizeof sinf
		mov		sinf.fMask,SIF_ALL
		invoke GetScrollInfo,[esi].HEEDT.hvscroll,SB_CTL,addr sinf
		invoke GetKeyState,VK_CONTROL
		and		eax,80h
		mov		fControl,eax
		invoke GetKeyState,VK_SHIFT
		and		eax,80h
		.if [ebx].EDIT.fstyle & HEX_STYLE_NOINSDEL
			xor		eax,eax
		.endif
		mov		fShift,eax
		mov		edx,wParam
		mov		eax,lParam
		shr		eax,16
		and		eax,3FFh

		.if edx==28h && (eax==150h || eax==50h)
			.if fControl
				;Ctrl+Down
				mov		eax,SB_LINEDOWN
				call	DoScroll
			.else
				;Down
				mov		ecx,[ebx].EDIT.nbytes
				shr		ecx,4
				mov		eax,[ebx].EDIT.cpMin
				mov		edx,eax
				shr		edx,5
				.if edx<ecx
					add		eax,32
					mov		edx,eax
					shr		edx,1
					.if edx>[ebx].EDIT.nbytes
						mov		eax,[ebx].EDIT.nbytes
						shl		eax,1
					.endif
					mov		[ebx].EDIT.cpMin,eax
				.endif
				.if fShift
					and		[ebx].EDIT.cpMin,0FFFFFFFEh
					and		[ebx].EDIT.cpMax,0FFFFFFFEh
				.elseif fSel
					mov		eax,cpMax
					mov		[ebx].EDIT.cpMin,eax
				.endif
				call	DoMove
			.endif
		.elseif edx==26h && (eax==148h || eax==48h)
			.if fControl
				;Ctrl+Up
				mov		eax,SB_LINEUP
				call	DoScroll
			.else
				;Up
				mov		eax,[ebx].EDIT.cpMin
				sub		eax,32
				jnb		@f
				add		eax,32
			  @@:
				mov		[ebx].EDIT.cpMin,eax
				.if fShift
					and		[ebx].EDIT.cpMin,0FFFFFFFEh
					and		[ebx].EDIT.cpMax,0FFFFFFFEh
				.elseif fSel
					mov		eax,cpMin
					mov		[ebx].EDIT.cpMin,eax
				.endif
				call	DoMove
			.endif
		.elseif edx==27h && (eax==14Dh || eax==4Dh)
			.if fControl || fShift
				;Ctrl+Right
				mov		eax,[ebx].EDIT.cpMin
				and		eax,0FFFFFFFEh
				inc		eax
				inc		eax
				mov		edx,eax
				inc		edx
				shr		edx,1
				.if edx>[ebx].EDIT.nbytes
					dec		eax
				.endif
				mov		[ebx].EDIT.cpMin,eax
				and		[ebx].EDIT.cpMin,0FFFFFFFEh
			.else
				;Right
				mov		eax,[ebx].EDIT.cpMin
				inc		eax
				mov		edx,eax
				inc		edx
				shr		edx,1
				.if edx>[ebx].EDIT.nbytes
					dec		eax
				.endif
				mov		[ebx].EDIT.cpMin,eax
			.endif
			.if !fShift && fSel
				mov		eax,cpMax
				mov		[ebx].EDIT.cpMin,eax
			.endif
			call	DoMove
		.elseif edx==25h && (eax==14Bh || eax==4Bh)
			.if fControl || fShift
				;Ctrl+Left
				mov		eax,[ebx].EDIT.cpMin
				and		eax,0FFFFFFFEh
				.if eax
					dec		eax
					and		eax,0FFFFFFFEh
					mov		[ebx].EDIT.cpMin,eax
				.endif
				mov		[ebx].EDIT.cpMin,eax
				and		[ebx].EDIT.cpMin,0FFFFFFFEh
			.else
				;Left
				mov		eax,[ebx].EDIT.cpMin
				.if eax
					dec		eax
					mov		[ebx].EDIT.cpMin,eax
				.endif
			.endif
			.if !fShift && fSel
				mov		eax,cpMin
				mov		[ebx].EDIT.cpMin,eax
			.endif
			call	DoMove
		.elseif edx==22h && (eax==151h || eax==51h)
			.if fControl
				;Ctrl+PgDn
				mov		eax,SB_PAGEDOWN
				call	DoScroll
			.else
				;PgDn
				invoke SendMessage,hWin,WM_VSCROLL,SB_PAGEDOWN,0
				mov		ecx,[ebx].EDIT.nbytes
				shr		ecx,4
				mov		eax,sinf.nPage
				shl		eax,5
				add		eax,[ebx].EDIT.cpMin
				mov		edx,eax
				shr		edx,5
				.if edx>ecx
					mov		edx,ecx
					shl		edx,5
					and		eax,1Fh
					add		eax,edx
					mov		edx,eax
					shr		edx,1
					.if edx>[ebx].EDIT.nbytes
						mov		eax,[ebx].EDIT.nbytes
						shl		eax,1
					.endif
				.endif
				mov		edx,[ebx].EDIT.nbytes
				shl		edx,1
				.if eax>edx
					mov		eax,edx
				.endif
				mov		[ebx].EDIT.cpMin,eax
				.if fShift
					and		[ebx].EDIT.cpMin,0FFFFFFFEh
					and		[ebx].EDIT.cpMax,0FFFFFFFEh
					call	DoMove
					invoke InvalidateRect,hWin,NULL,FALSE
				.else
					call	DoMove
				.endif
			.endif
		.elseif edx==21h && (eax==149h || eax==49h)
			.if fControl
				;Ctrl+PgUp
				mov		eax,SB_PAGEUP
				call	DoScroll
			.else
				;PgUp
				invoke SendMessage,hWin,WM_VSCROLL,SB_PAGEUP,0
				mov		edx,sinf.nPage
				shl		edx,5
				mov		eax,[ebx].EDIT.cpMin
				sub		eax,edx
				jnb		@f
				and		eax,1Fh
			  @@:
				mov		[ebx].EDIT.cpMin,eax
				.if fShift
					and		[ebx].EDIT.cpMin,0FFFFFFFEh
					and		[ebx].EDIT.cpMax,0FFFFFFFEh
					call	DoMove
					invoke InvalidateRect,hWin,NULL,FALSE
				.else
					call	DoMove
				.endif
			.endif
		.elseif edx==23h && (eax==14Fh || eax==4Fh)
			.if fControl
				;Ctrl+End
				mov		eax,[ebx].EDIT.nbytes
				shl		eax,1
				mov		[ebx].EDIT.cpMin,eax
				.if !fShift
					mov		[ebx].EDIT.cpMax,eax
				.else
					and		[ebx].EDIT.cpMin,0FFFFFFFEh
					and		[ebx].EDIT.cpMax,0FFFFFFFEh
				.endif
				mov		eax,SB_BOTTOM
				call	DoScroll
				call	DoMove
				invoke InvalidateRect,hWin,NULL,FALSE
			.else
				;End
				mov		edx,[ebx].EDIT.nbytes
				shl		edx,1
				mov		eax,[ebx].EDIT.cpMin
				or		eax,1Fh
				.if fShift
					inc		eax
				.endif
				.if eax>edx
					mov		eax,edx
				.endif
				mov		[ebx].EDIT.cpMin,eax
				.if fShift
					and		[ebx].EDIT.cpMin,0FFFFFFFEh
					and		[ebx].EDIT.cpMax,0FFFFFFFEh
				.endif
				call	DoMove
			.endif
		.elseif edx==24h && (eax==147h || eax==47h)
			.if fControl
				;Ctrl+Home
				xor		eax,eax
				mov		[ebx].EDIT.cpMin,eax
				.if !fShift
					mov		[ebx].EDIT.cpMax,eax
				.else
					and		[ebx].EDIT.cpMin,0FFFFFFFEh
					and		[ebx].EDIT.cpMax,0FFFFFFFEh
				.endif
				mov		eax,SB_TOP
				call	DoScroll
				call	DoMove
				invoke InvalidateRect,hWin,NULL,FALSE
			.else
				;Home
				mov		eax,[ebx].EDIT.cpMin
				and		eax,0FFFFFFE0h
				mov		[ebx].EDIT.cpMin,eax
				call	DoMove
				.if fShift
					and		[ebx].EDIT.cpMin,0FFFFFFFEh
					and		[ebx].EDIT.cpMax,0FFFFFFFEh
				.endif
			.endif
		.elseif edx==2Dh && (eax==152h || eax==52h)
			;Insert
			xor		[ebx].EDIT.fOvr,TRUE
			.if [ebx].EDIT.fstyle & HEX_STYLE_NOINSDEL
				mov		[ebx].EDIT.fOvr,TRUE
			.endif
			invoke SetCaret,hWin
		.elseif edx==2Eh && (eax==153h || eax==53h)
			.if !([ebx].EDIT.fstyle & HEX_STYLE_NOINSDEL)
				;Delete
				.if fSel
					invoke DeleteSelection,ebx,cpMin,cpMax
				.else
					mov		eax,cpMin
					and		eax,0FFFFFFFEh
					mov		edx,eax
					add		edx,2
					invoke DeleteSelection,ebx,eax,edx
				.endif
			.endif
		.elseif edx==43h && fControl && !fShift
			;Ctrl+C, Copy
			invoke EditCopy,ebx
		.elseif edx==58h && fControl && !fShift
			;Ctrl+X, Cut
			invoke EditCopy,ebx
			invoke SendMessage,[ebx].EDIT.hwnd,WM_CLEAR,0,0
		.elseif edx==56h && fControl && !fShift
			;Ctrl+V, Paste
			invoke EditPaste,ebx
		.elseif edx==41h && fControl && !fShift
			.if ![ebx].EDIT.fstyle & HEX_STYLE_NOINSDEL
				;Ctrl+A, Select all
				mov		eax,[ebx].EDIT.nbytes
				shl		eax,1
				mov		[ebx].EDIT.cpMin,0
				mov		[ebx].EDIT.cpMax,eax
				invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
				invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
				invoke SetCaret,hWin
				invoke SelChange,ebx,SEL_TEXT
			.endif
		.elseif edx==5Ah && fControl && !fShift
			;Ctrl+Z, Undo
			invoke Undo,ebx,hWin
		.elseif edx==59h && fControl && !fShift
			;Ctrl+Y, Redo
			invoke Redo,ebx,hWin
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_CHAR
		mov		fIns,FALSE
		mov		eax,[ebx].EDIT.cpMin
		mov		ecx,[ebx].EDIT.cpMax
		.if eax>ecx
			xchg	eax,ecx
		.endif
		mov		cpMin,eax
		mov		cpMax,ecx
		sub		ecx,eax
		mov		fSel,ecx
		invoke GetKeyState,VK_CONTROL
		and		eax,80h
		mov		fControl,eax
		invoke GetKeyState,VK_SHIFT
		and		eax,80h
		mov		fShift,eax
		mov		eax,wParam
		.if (eax>='0' && eax<='9') || (eax>='A' && eax<='F') || (eax>='a' && eax<='f')
			test	[ebx].EDIT.fstyle,HEX_STYLE_READONLY
			jne		ErrBeep
			.if fSel
				push	eax
				invoke DeleteSelection,ebx,cpMin,cpMax
				pop		eax
			.endif
			.if ![ebx].EDIT.fOvr || ecx==[ebx].EDIT.nbytes
				mov		ecx,[ebx].EDIT.cpMin
				shr		ecx,1
				.if !CARRY?
					push	eax
					invoke InsertChars,ebx,ecx,1
					mov		fIns,TRUE
					pop		eax
				.endif
			.endif
			.if eax>='a'
				and		eax,5Fh
			.endif
			.if eax>='A'
				sub		eax,'A'-10
			.else
				sub		eax,'0'
			.endif
			mov		edx,0F0h
			mov		ecx,[ebx].EDIT.cpMin
			shr		ecx,1
			.if !CARRY?
				shl		eax,4
				shr		edx,4
			.endif
			push	eax
			push	edx
			invoke GetChar,ebx,ecx
			push	eax
			.if !fIns
				invoke SaveUndo,ebx,UNDO_CHAROVERWRITE,[ebx].EDIT.cpMin,eax,1
			.endif
			pop		eax
			pop		edx
			pop		ecx
			and		eax,edx
			or		eax,ecx
			mov		nChar,eax
			mov		ecx,[ebx].EDIT.cpMin
			shr		ecx,1
			invoke PutChar,ebx,ecx,addr nChar,1
			.if fIns
				invoke SaveUndo,ebx,UNDO_CHARINSERT,[ebx].EDIT.cpMin,nChar,1
			.endif
			mov		ecx,[ebx].EDIT.cpMin
			inc		ecx
			inc		ecx
			shr		ecx,1
			.if ecx>[ebx].EDIT.nbytes
				mov		[ebx].EDIT.nbytes,ecx
			.endif
			invoke InvalidateLine,[ebx].EDIT.edta.hwnd,[ebx].EDIT.cpMin
			invoke InvalidateLine,[ebx].EDIT.edtb.hwnd,[ebx].EDIT.cpMin
			mov		ecx,[ebx].EDIT.cpMin
			inc		ecx
			mov		[ebx].EDIT.cpMin,ecx
			mov		[ebx].EDIT.cpMax,ecx
			add		ecx,32
			.if fIns
				mov		edx,ecx
				add		edx,4096
				push	ecx
				push	edx
				invoke InvalidateSelection,[ebx].EDIT.edta.hwnd,ecx,edx
				pop		edx
				pop		ecx
				invoke InvalidateSelection,[ebx].EDIT.edtb.hwnd,ecx,edx
			.else
				push	ecx
				invoke InvalidateLine,[ebx].EDIT.edta.hwnd,ecx
				pop		ecx
				invoke InvalidateLine,[ebx].EDIT.edtb.hwnd,ecx
			.endif
			mov		[ebx].EDIT.fChanged,TRUE
			inc		[ebx].EDIT.nchange
			invoke InvalidateRect,[ebx].EDIT.hsta,NULL,TRUE
			call	DoMove
		.endif
	.elseif eax==WM_VSCROLL
		mov		sinf.cbSize,sizeof sinf
		mov		sinf.fMask,SIF_ALL
		invoke GetScrollInfo,[esi].HEEDT.hvscroll,SB_CTL,addr sinf
		mov		eax,[esi].HEEDT.nline
		mov		edx,wParam
		movzx	edx,dx
		.if edx==SB_THUMBTRACK || edx==SB_THUMBPOSITION
			mov		eax,sinf.nTrackPos
		.elseif edx==SB_LINEDOWN
			inc		eax
		.elseif edx==SB_LINEUP
			.if eax
				dec		eax
			.endif
		.elseif edx==SB_PAGEDOWN
			add		eax,sinf.nPage
		.elseif edx==SB_PAGEUP
			sub		eax,sinf.nPage
			jnb		@f
			xor		eax,eax
		  @@:
		.elseif edx==SB_BOTTOM
			mov		eax,sinf.nMax
		.elseif edx==SB_TOP
			xor		eax,eax
		.endif
		invoke Scroll,hWin,[ebx].EDIT.cpx,eax
	.elseif eax==WM_MOUSEWHEEL
		mov		eax,[esi].HEEDT.nline
		.if sdword ptr wParam>0
			sub		eax,3
			jnb		@f
			xor		eax,eax
		  @@:
		.else
			add		eax,3
		.endif
		invoke Scroll,hWin,[ebx].EDIT.cpx,eax
	.elseif eax==WM_LBUTTONDOWN
		mov		eax,[ebx].EDIT.cpMin
		mov		ecx,[ebx].EDIT.cpMax
		.if eax>ecx
			xchg	eax,ecx
		.endif
		mov		cpMin,eax
		mov		cpMax,ecx
		sub		ecx,eax
		mov		fSel,ecx
		invoke GetKeyState,VK_SHIFT
		and		eax,80h
		mov		fShift,eax
		.if fSel
			invoke InvalidateSelection,[ebx].EDIT.edta.hwnd,cpMin,cpMax
			invoke InvalidateSelection,[ebx].EDIT.edtb.hwnd,cpMin,cpMax
		.else
			invoke InvalidateLine,[ebx].EDIT.edta.hwnd,cpMin
			invoke InvalidateLine,[ebx].EDIT.edtb.hwnd,cpMin
		.endif
		invoke SetFocus,hWin
		invoke SetCapture,hWin
		mov		fSelState,1
		call	SetCur
		.if ecx
			invoke GetCharFromPos,hWin,0,edx
			.if !fShift
				mov		[ebx].EDIT.cpMin,eax
				mov		[ebx].EDIT.cpMax,eax
				mov		icp,eax
			.endif
			mov		fSelState,2
			invoke SendMessage,hWin,WM_MOUSEMOVE,wParam,lParam
			xor		eax,eax
			jmp		Ex
		.endif
		invoke GetCharFromPos,hWin,eax,edx
		mov		[ebx].EDIT.cpMin,eax
		mov		ecx,[ebx].EDIT.cpMax
		.if !fShift
			mov		[ebx].EDIT.cpMax,eax
			push	eax
			invoke InvalidateLine,[ebx].EDIT.edta.hwnd,eax
			pop		eax
			invoke InvalidateLine,[ebx].EDIT.edtb.hwnd,eax
		.elseif eax!=ecx
			inc		eax
			and		eax,0FFFFFFFEh
			and		ecx,0FFFFFFFEh
			mov		[ebx].EDIT.cpMin,eax
			mov		[ebx].EDIT.cpMax,ecx
			.if eax>ecx
				xchg	eax,ecx
			.endif
			push	eax
			push	ecx
			invoke InvalidateSelection,[ebx].EDIT.edta.hwnd,eax,ecx
			pop		ecx
			pop		eax
			invoke InvalidateSelection,[ebx].EDIT.edtb.hwnd,eax,ecx
		.endif
		invoke ScrollCaret,hWin
		invoke SelChange,ebx,SEL_TEXT
	.elseif eax==WM_LBUTTONUP
		invoke ReleaseCapture
		xor		eax,eax
		mov		fSelState,eax
		mov		tmr1.hwnd,eax
		mov		tmr2.hwnd,eax
		call	SetCur
	.elseif eax==WM_LBUTTONDBLCLK
		call	SetCur
		mov		eax,[ebx].EDIT.cpx
		mov		ecx,[ebx].EDIT.fntinfo.fntwt
		mul		ecx
		mov		ecx,eax
		mov		eax,[ebx].EDIT.linenrwt
		add		eax,[ebx].EDIT.selbarwt
		mov		edx,eax
		add		eax,[ebx].EDIT.dataxp
		sub		eax,ecx
		mov		ecx,eax
		mov		eax,lParam
		cwde
		.if eax<ecx && eax>edx
			mov		eax,[ebx].EDIT.cpMin
			shr		eax,1
			.if eax<[ebx].EDIT.nbytes
				shr		eax,4
				shl		eax,5
				mov		[ebx].EDIT.cpMin,eax
				add		eax,32
				shr		eax,1
				.if eax>[ebx].EDIT.nbytes
					mov		eax,[ebx].EDIT.nbytes
				.endif
				shl		eax,1
				mov		[ebx].EDIT.cpMax,eax
				invoke InvalidateSelection,[ebx].EDIT.edta.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
				invoke InvalidateSelection,[ebx].EDIT.edtb.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
				invoke ScrollCaret,hWin
				invoke SelChange,ebx,SEL_TEXT
			.endif
		.elseif eax>edx
			mov		eax,[ebx].EDIT.cpMin
			shr		eax,1
			.if eax<[ebx].EDIT.nbytes
				shl		eax,1
				mov		[ebx].EDIT.cpMin,eax
				add		eax,2
				mov		[ebx].EDIT.cpMax,eax
				invoke InvalidateSelection,[ebx].EDIT.edta.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
				invoke InvalidateSelection,[ebx].EDIT.edtb.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
				invoke ScrollCaret,hWin
				invoke SelChange,ebx,SEL_TEXT
			.endif
		.endif
	.elseif eax==WM_MOUSEMOVE
		invoke SendMessage,[ebx].EDIT.htt,TTM_ACTIVATE,FALSE,0
		invoke SendMessage,[ebx].EDIT.htt,TTM_ACTIVATE,TRUE,0
		;Get mouse position
		mov		eax,lParam
		shr		eax,16
		cwde
		mov		edx,eax
		mov		eax,lParam
		cwde
		.if fSelState
			;Is selection on selbar
			.if fSelState==2
				push	edx
				invoke GetCharFromPos,hWin,0,edx
				pop		edx
				.if eax<icp
					mov		eax,icp
					add		eax,32
					mov		[ebx].EDIT.cpMax,eax
					xor		eax,eax
				.else
					mov		eax,icp
					mov		[ebx].EDIT.cpMax,eax
					mov		eax,[esi].HEEDT.rc.right
				.endif
			.endif
			push	eax
			push	edx
			.if sdword ptr edx>[esi].HEEDT.rc.bottom
				mov		eax,hWin
				mov		tmr1.hwnd,eax
				mov		tmr1.umsg,WM_VSCROLL
				mov		tmr1.wparam,SB_LINEDOWN
				mov		tmr1.lparam,0
				mov		tmr2.hwnd,eax
				mov		tmr2.umsg,WM_MOUSEMOVE
				mov		eax,wParam
				mov		tmr2.wparam,eax
				mov		eax,lParam
				mov		tmr2.lparam,eax
			.elseif sdword ptr edx<0
				mov		eax,hWin
				mov		tmr1.hwnd,eax
				mov		tmr1.umsg,WM_VSCROLL
				mov		tmr1.wparam,SB_LINEUP
				mov		tmr1.lparam,0
				mov		tmr2.hwnd,eax
				mov		tmr2.umsg,WM_MOUSEMOVE
				mov		eax,wParam
				mov		tmr2.wparam,eax
				mov		eax,lParam
				mov		tmr2.lparam,eax
			.elseif sdword ptr eax>[esi].HEEDT.rc.right
				mov		eax,[ebx].EDIT.hwnd
				mov		tmr1.hwnd,eax
				mov		tmr1.umsg,WM_HSCROLL
				mov		tmr1.wparam,SB_LINEDOWN
				mov		tmr1.lparam,0
				mov		eax,hWin
				mov		tmr2.hwnd,eax
				mov		tmr2.umsg,WM_MOUSEMOVE
				mov		eax,wParam
				mov		tmr2.wparam,eax
				mov		eax,lParam
				mov		tmr2.lparam,eax
			.elseif sdword ptr eax<0
				mov		eax,[ebx].EDIT.hwnd
				mov		tmr1.hwnd,eax
				mov		tmr1.umsg,WM_HSCROLL
				mov		tmr1.wparam,SB_LINEUP
				mov		tmr1.lparam,0
				mov		eax,hWin
				mov		tmr2.hwnd,eax
				mov		tmr2.umsg,WM_MOUSEMOVE
				mov		eax,wParam
				mov		tmr2.wparam,eax
				mov		eax,lParam
				mov		tmr2.lparam,eax
			.else
				xor		eax,eax
				mov		tmr1.hwnd,eax
				mov		tmr2.hwnd,eax
			.endif
			pop		edx
			pop		eax
			invoke GetCharFromPos,hWin,eax,edx
			inc		eax
			and		eax,0FFFFFFFEh
			mov		edx,[ebx].EDIT.cpMin
			mov		[ebx].EDIT.cpMin,eax
			.if eax!=edx
				push	eax
				push	edx
				invoke InvalidateSelection,[ebx].EDIT.edta.hwnd,edx,eax
				pop		edx
				pop		eax
				invoke InvalidateSelection,[ebx].EDIT.edtb.hwnd,edx,eax
				invoke SetCaret,hWin
				invoke SelChange,ebx,SEL_TEXT
			.endif
		.else
			call	SetCur
		.endif
	.elseif eax==WM_SETFOCUS
		mov		eax,hWin
		mov		[ebx].EDIT.focus,eax
		invoke SetFocus,hWin
		call	SetScroll
		invoke SetCaret,hWin
		invoke InvalidateSelection,[ebx].EDIT.edta.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
		invoke InvalidateSelection,[ebx].EDIT.edtb.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
		push	word ptr EN_SETFOCUS
		push	word ptr [ebx].EDIT.ID
		pop		ecx
		invoke SendMessage,[ebx].EDIT.hpar,WM_COMMAND,ecx,[ebx].EDIT.hwnd
		invoke SelChange,ebx,SEL_TEXT
	.elseif eax==WM_KILLFOCUS
		.if ![ebx].EDIT.fCaretHide
			mov		[ebx].EDIT.fCaretHide,TRUE
			invoke HideCaret,hWin
		.endif
		mov		[ebx].EDIT.focus,0
		invoke InvalidateSelection,[ebx].EDIT.edta.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
		invoke InvalidateSelection,[ebx].EDIT.edtb.hwnd,[ebx].EDIT.cpMin,[ebx].EDIT.cpMax
		push	word ptr EN_KILLFOCUS
		push	word ptr [ebx].EDIT.ID
		pop		ecx
		invoke SendMessage,[ebx].EDIT.hpar,WM_COMMAND,ecx,[ebx].EDIT.hwnd
	.elseif eax==WM_CREATE
		invoke GetParent,hWin
		invoke GetWindowLong,eax,0
		invoke SetWindowLong,hWin,0,eax
;	.elseif eax==WM_DESTROY
	.elseif eax==WM_GETDLGCODE
 		mov		eax,DLGC_WANTARROWS or DLGC_WANTCHARS
		jmp		Ex
	.endif
  ExDef:
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ErrBeep:
	invoke MessageBeep,MB_ICONHAND
	xor		eax,eax
	jmp		Ex

SetCur:
	;Get mouse position
	mov		eax,lParam
	shr		eax,16
	cwde
	mov		edx,eax
	mov		eax,lParam
	cwde
	push	edi
	push	edx
	push	eax
	mov		eax,[ebx].EDIT.cpx
	mov		ecx,[ebx].EDIT.fntinfo.fntwt
	mul		ecx
	shr		ecx,1
	add		eax,ecx
	neg		eax
	mov		edx,eax
	pop		eax
	mov		ecx,[ebx].EDIT.linenrwt
	add		ecx,[ebx].EDIT.selbarwt
	add		edx,ecx
	add		edx,[ebx].EDIT.dataxp
	mov		edi,edx
	add		edi,[ebx].EDIT.datawt
	add		edi,[ebx].EDIT.fntinfo.fntwt
	.if sdword ptr eax<ecx
		invoke SetCursor,hSelCur
		mov		eax,[esi].HEEDT.rc.right
		xor		ecx,ecx
		inc		ecx
	.elseif sdword ptr eax<edx
		invoke LoadCursor,0,IDC_ARROW
		invoke SetCursor,eax
		xor		eax,eax
		xor		ecx,ecx
	.elseif  sdword ptr eax>edi
		invoke LoadCursor,0,IDC_ARROW
		invoke SetCursor,eax
		mov		eax,edi
		xor		ecx,ecx
	.else
		xor		ecx,ecx
	.endif
	pop		edx
	pop		edi
	retn

DoScroll:
	invoke SendMessage,hWin,WM_VSCROLL,eax,0
	retn

DoMove:
	.if !fShift
		mov		eax,[ebx].EDIT.cpMin
		mov		[ebx].EDIT.cpMax,eax
	.endif
	invoke ScrollCaret,hWin
	mov		eax,[ebx].EDIT.cpMin
	.if eax==[ebx].EDIT.cpMax
		.if fSel
			push	eax
			invoke InvalidateSelection,[ebx].EDIT.edta.hwnd,cpMin,cpMax
			invoke InvalidateSelection,[ebx].EDIT.edtb.hwnd,cpMin,cpMax
			pop		eax
		.else
			push	eax
			invoke InvalidateLine,[ebx].EDIT.edta.hwnd,cpMin
			invoke InvalidateLine,[ebx].EDIT.edtb.hwnd,cpMin
			pop		eax
		.endif
		push	eax
		invoke InvalidateLine,[ebx].EDIT.edta.hwnd,eax
		pop		eax
		invoke InvalidateLine,[ebx].EDIT.edtb.hwnd,eax
	.else
		push	eax
		invoke InvalidateLine,[ebx].EDIT.edta.hwnd,eax
		pop		eax
		invoke InvalidateLine,[ebx].EDIT.edtb.hwnd,eax
		invoke InvalidateLine,[ebx].EDIT.edta.hwnd,cpMin
		invoke InvalidateLine,[ebx].EDIT.edtb.hwnd,cpMin
		invoke InvalidateLine,[ebx].EDIT.edta.hwnd,cpMax
		invoke InvalidateLine,[ebx].EDIT.edtb.hwnd,cpMax
	.endif
	invoke SelChange,ebx,SEL_TEXT
	retn

SetScroll:
	invoke GetClientRect,hWin,addr rect
	mov		sinf.cbSize,sizeof sinf
	mov		sinf.fMask,SIF_ALL or SIF_DISABLENOSCROLL
	mov		sinf.nMin,0
	mov		eax,[ebx].EDIT.nbytes
	shr		eax,4
	inc		eax
	mov		ecx,[ebx].EDIT.fntinfo.fntht
	mul		ecx
	.if eax<rect.bottom
		mov		eax,rect.bottom
	.endif
	xor		edx,edx
	div		ecx
	dec		eax
	mov		sinf.nMax,eax
	mov		eax,rect.bottom
	xor		edx,edx
	div		ecx
	mov		sinf.nPage,eax
	mov		eax,[esi].HEEDT.nline
	mov		sinf.nPos,eax
	invoke SetScrollInfo,[esi].HEEDT.hvscroll,SB_CTL,addr sinf,TRUE
    invoke GetClientRect,hWin,addr rect                 ; MOD  rect is changed, if scrollbar hides itself
	mov		sinf.cbSize,sizeof sinf
	mov		sinf.fMask,SIF_ALL or SIF_DISABLENOSCROLL
	mov		sinf.nMin,0
	mov		eax,rect.right
	sub		eax,SBWT
	sub		eax,[ebx].EDIT.selbarwt
	sub		eax,[ebx].EDIT.linenrwt
	mov		ecx,[ebx].EDIT.fntinfo.fntwt
	xor		edx,edx
	div		ecx
	mov		sinf.nPage,eax
	mov		eax,[ebx].EDIT.fntinfo.fntwt
	shl		eax,4
	add		eax,[ebx].EDIT.asciixp
	mov		ecx,[ebx].EDIT.fntinfo.fntwt

	mov		eax,[ebx].EDIT.asciixp
	add		eax,[ebx].EDIT.asciiwt

	xor		edx,edx
	div		ecx
	mov		sinf.nMax,eax
	mov		eax,[ebx].EDIT.cpx
	mov		sinf.nPos,eax
	invoke SetScrollInfo,[ebx].EDIT.hhscroll,SB_CTL,addr sinf,TRUE
    invoke GetClientRect,hWin,addr rect                 ; MOD  rect is changed, if scrollbar hides itself
	retn

RAHexEdProc endp

;The hex edit controls callback (WndProc).
RAWndProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	sinf:SCROLLINFO
	LOCAL	chrg:CHARRANGE
	LOCAL	ti:TOOLINFO
	LOCAL	cpMin:DWORD
	LOCAL	cpMax:DWORD
	LOCAL	fSel:DWORD

	;Get memory pointer
	invoke GetWindowLong,hWin,0
	.if eax
		mov		ebx,eax
		mov		eax,[ebx].EDIT.focus
		.if eax==[ebx].EDIT.edta.hwnd
			lea		esi,[ebx].EDIT.edta
		.else
			lea		esi,[ebx].EDIT.edtb
		.endif
	.else
		.if uMsg!=WM_CREATE
			jmp		ExDef
		.endif
	.endif
	mov		eax,uMsg
	.if eax==WM_CREATE
		;Allocate memory for the hex edit control
		invoke GetProcessHeap
		invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof EDIT
		mov		ebx,eax
		;Save the pointer
		invoke SetWindowLong,hWin,0,ebx
		mov		eax,hWin
		mov		[ebx].EDIT.hwnd,eax
		invoke GetParent,eax
		mov		[ebx].EDIT.hpar,eax
		invoke GetWindowLong,[ebx].EDIT.hwnd,GWL_ID
		mov		[ebx].EDIT.ID,eax
		call	AllocMem
		mov		[ebx].EDIT.nlinenrwt,LNRWT
		;mov		[ebx].EDIT.linenrwt,LNRWT                  ; *** MOD
		PrintHex LNRWT
		mov		[ebx].EDIT.selbarwt,SELWT
		mov		[ebx].EDIT.fntinfo.fntwt,7
		mov		[ebx].EDIT.fntinfo.fntht,10
		mov		[ebx].EDIT.clr.bckcol,DEFBCKCOLOR
		mov		[ebx].EDIT.clr.adrtxtcol,DEFADRTXTCOLOR
		mov		[ebx].EDIT.clr.dtatxtcol,DEFDTATXTCOLOR
		mov		[ebx].EDIT.clr.asctxtcol,DEFASCTXTCOLOR
		mov		[ebx].EDIT.clr.selbckcol,DEFSELBCKCOLOR
		mov		[ebx].EDIT.clr.sellfbckcol,DEFSELBCKCOLOR
		mov		[ebx].EDIT.clr.seltxtcol,DEFSELTXTCOLOR
		mov		[ebx].EDIT.clr.selascbckcol,DEFSELASCCOLOR
		mov		[ebx].EDIT.clr.selbarbck,DEFSELBARCOLOR
		mov		[ebx].EDIT.clr.selbarpen,DEFSELBARPEN
		mov		[ebx].EDIT.clr.lnrcol,DEFLNRCOLOR
		invoke CreateBrushes,ebx

		invoke CreateWindowEx,NULL,addr szToolTips,NULL,TTS_ALWAYSTIP,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,hInstance,NULL
		mov		[ebx].EDIT.htt,eax

		invoke CreateWindowEx,1,addr szStatic,NULL,SS_NOTIFY or WS_CHILD or WS_VISIBLE,0,0,0,0,hWin,-1,hInstance,0
		mov		[ebx].EDIT.hsbtn,eax
		mov		edx,offset szSplitterBar
		call	SetToolTip
		invoke SetWindowLong,[ebx].EDIT.hsbtn,GWL_WNDPROC,addr SplittBtnProc
		mov		OldSplittBtnProc,eax

		invoke CreateWindowEx,NULL,addr szHexChildClassName,NULL,WS_CLIPSIBLINGS or WS_CHILD or WS_VISIBLE,0,0,0,0,hWin,NULL,hInstance,0
		mov		[ebx].EDIT.edta.hwnd,eax
		invoke CreateWindowEx,NULL,addr szScrollBar,NULL,WS_CHILD or WS_VISIBLE or SBS_VERT,0,0,0,0,[ebx].EDIT.edta.hwnd,NULL,hInstance,0
		mov		[ebx].EDIT.edta.hvscroll,eax

		invoke CreateWindowEx,NULL,addr szHexChildClassName,NULL,WS_CLIPSIBLINGS or WS_CHILD or WS_VISIBLE,0,0,0,0,hWin,NULL,hInstance,0
		mov		[ebx].EDIT.edtb.hwnd,eax
		invoke CreateWindowEx,NULL,addr szScrollBar,NULL,WS_CHILD or WS_VISIBLE or SBS_VERT,0,0,0,0,[ebx].EDIT.edtb.hwnd,NULL,hInstance,0
		mov		[ebx].EDIT.edtb.hvscroll,eax

		invoke CreateWindowEx,NULL,addr szScrollBar,NULL,WS_CHILD or WS_VISIBLE or SBS_HORZ,0,0,0,0,hWin,NULL,hInstance,0
		mov		[ebx].EDIT.hhscroll,eax
		invoke CreateWindowEx,NULL,addr szScrollBar,NULL,WS_CHILD or WS_VISIBLE or SBS_SIZEGRIP,0,0,0,0,hWin,NULL,hInstance,0
		mov		[ebx].EDIT.hgrip,eax

		invoke CreateWindowEx,NULL,addr szStatic,NULL,WS_CHILD or WS_VISIBLE,0,0,0,0,hWin,NULL,hInstance,0
		mov		[ebx].EDIT.hnogrip,eax

		invoke CreateWindowEx,NULL,addr szStatic,NULL,SS_NOTIFY or WS_CHILD or WS_VISIBLE,0,0,0,0,hWin,NULL,hInstance,0
		mov		[ebx].EDIT.hsta,eax
		mov		edx,offset szChanged
		call	SetToolTip
		invoke SetWindowLong,[ebx].EDIT.hsta,GWL_USERDATA,ebx
		invoke SetWindowLong,[ebx].EDIT.hsta,GWL_WNDPROC,addr StateProc
		mov		OldStateProc,eax

		invoke CreateWindowEx,NULL,addr szButton,NULL,BS_BITMAP or BS_PUSHLIKE or BS_AUTOCHECKBOX or WS_CHILD or WS_VISIBLE,0,0,0,0,hWin,-2,hInstance,0
		mov		[ebx].EDIT.hlin,eax
		mov		edx,offset szLineNumber
		call	SetToolTip
		invoke SendMessage,[ebx].EDIT.hlin,BM_SETIMAGE,IMAGE_BITMAP,hBmpLnr

		invoke SetWindowPos,[ebx].EDIT.hsta,HWND_TOP,0,0,0,0,SWP_NOSIZE or SWP_NOSIZE
		invoke SetWindowPos,[ebx].EDIT.hsbtn,HWND_TOP,0,0,0,0,SWP_NOSIZE or SWP_NOSIZE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		cwde
		.if eax==-2
			.if [ebx].EDIT.linenrwt
				PrintHex 0
				mov		[ebx].EDIT.linenrwt,0
			.else
				PrintHex eax, "nlinenrwt->linenrwt"
				mov		eax,[ebx].EDIT.nlinenrwt
				mov		[ebx].EDIT.linenrwt,eax
			.endif
			invoke SetFocus,hWin
			invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
			invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
		.endif
	.elseif eax==HEM_SETFONT
		;wParam=nLineSpacing
		;lParam=lpRAFONT
		mov		eax,wParam
		mov		[ebx].EDIT.fntinfo.linespace,eax
		invoke SetFont,ebx,lParam
		invoke GetFocus
		.if eax==[ebx].EDIT.focus && eax
			invoke SetFocus,[ebx].EDIT.focus
			invoke ScrollCaret,[ebx].EDIT.focus
		.endif
		invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
		invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
		xor		eax,eax
		jmp		Ex
	.elseif eax==HEM_GETFONT
		;wParam=0
		;lParam=lpRAFONT
		mov		edx,lParam
		mov		eax,[ebx].EDIT.fnt.hFont
		mov		[edx].HEFONT.hFont,eax
		mov		eax,[ebx].EDIT.fnt.hLnrFont
		mov		[edx].HEFONT.hLnrFont,eax
		mov		eax,[ebx].EDIT.fntinfo.linespace
		jmp		Ex
	.elseif eax==HEM_SETCOLOR
		;wParam=0
		;lParam=lpRACOLOR
		mov		edx,lParam
		mov		eax,[edx].HECOLOR.bckcol
		mov		[ebx].EDIT.clr.bckcol,eax
		mov		eax,[edx].HECOLOR.adrtxtcol
		mov		[ebx].EDIT.clr.adrtxtcol,eax
		mov		eax,[edx].HECOLOR.dtatxtcol
		mov		[ebx].EDIT.clr.dtatxtcol,eax
		mov		eax,[edx].HECOLOR.asctxtcol
		mov		[ebx].EDIT.clr.asctxtcol,eax
		mov		eax,[edx].HECOLOR.selbckcol
		mov		[ebx].EDIT.clr.selbckcol,eax
		mov		eax,[edx].HECOLOR.sellfbckcol
		mov		[ebx].EDIT.clr.sellfbckcol,eax
		mov		eax,[edx].HECOLOR.seltxtcol
		mov		[ebx].EDIT.clr.seltxtcol,eax
		mov		eax,[edx].HECOLOR.selascbckcol
		mov		[ebx].EDIT.clr.selascbckcol,eax
		mov		eax,[edx].HECOLOR.selbarbck
		mov		[ebx].EDIT.clr.selbarbck,eax
		mov		eax,[edx].HECOLOR.selbarpen
		mov		[ebx].EDIT.clr.selbarpen,eax
		mov		eax,[edx].HECOLOR.lnrcol
		mov		[ebx].EDIT.clr.lnrcol,eax
		invoke CreateBrushes,ebx
		invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
		invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
		invoke InvalidateRect,[ebx].EDIT.hsta,NULL,FALSE
		xor		eax,eax
		jmp		Ex
	.elseif eax==HEM_GETCOLOR
		;wParam=0
		;lParam=lpRACOLOR
		mov		edx,lParam
		mov		eax,[ebx].EDIT.clr.bckcol
		mov		[edx].HECOLOR.bckcol,eax
		mov		eax,[ebx].EDIT.clr.adrtxtcol
		mov		[edx].HECOLOR.adrtxtcol,eax
		mov		eax,[ebx].EDIT.clr.dtatxtcol
		mov		[edx].HECOLOR.dtatxtcol,eax
		mov		eax,[ebx].EDIT.clr.asctxtcol
		mov		[edx].HECOLOR.asctxtcol,eax
		mov		eax,[ebx].EDIT.clr.selbckcol
		mov		[edx].HECOLOR.selbckcol,eax
		mov		eax,[ebx].EDIT.clr.sellfbckcol
		mov		[edx].HECOLOR.sellfbckcol,eax
		mov		eax,[ebx].EDIT.clr.seltxtcol
		mov		[edx].HECOLOR.seltxtcol,eax
		mov		eax,[ebx].EDIT.clr.selascbckcol
		mov		[edx].HECOLOR.selascbckcol,eax
		mov		eax,[ebx].EDIT.clr.selbarbck
		mov		[edx].HECOLOR.selbarbck,eax
		mov		eax,[ebx].EDIT.clr.selbarpen
		mov		[edx].HECOLOR.selbarpen,eax
		mov		eax,[ebx].EDIT.clr.lnrcol
		mov		[edx].HECOLOR.lnrcol,eax
		xor		eax,eax
		jmp		Ex
	.elseif eax==HEM_VCENTER
		;wParam=0
		;lParam=0
		mov		eax,[esi].HEEDT.rc.bottom
		mov		ecx,[ebx].EDIT.fntinfo.fntht
		xor		edx,edx
		div		ecx
		shr		eax,1
		mov		ecx,[ebx].EDIT.cpMin
		shr		ecx,5
		sub		ecx,eax
		jnb		@f
		xor		ecx,ecx
	  @@:
		mov		edx,ecx
		add		edx,eax
		add		edx,eax
		shl		edx,4
		.if edx>[ebx].EDIT.nbytes
			mov		edx,[ebx].EDIT.nbytes
			shr		edx,4
			inc		edx
			shl		eax,1
			sub		edx,eax
			jnb		@f
			xor		edx,edx
		  @@:
			mov		ecx,edx
		.endif
		mov		[esi].HEEDT.nline,ecx
		invoke InvalidateRect,[esi].HEEDT.hwnd,NULL,FALSE
		invoke SetCaret,[esi].HEEDT.hwnd
		xor		eax,eax
		jmp		Ex
	.elseif eax==HEM_REPAINT
		;wParam=0
		;lParam=0
		invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
		invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
		invoke SetCaret,[esi].HEEDT.hwnd
		xor		eax,eax
		jmp		Ex
	.elseif eax==HEM_ANYBOOKMARKS
		;wParam=0
		;lParam=0
		mov		eax,Bookmark.hWin
		.if eax
			mov		eax,TRUE
		.endif
		jmp		Ex
	.elseif eax==HEM_TOGGLEBOOKMARK
		;wParam=nLine
		;lParam=0
		mov		edi,wParam
		invoke ToggleBookmark,hWin,edi
		shl		edi,5
		invoke InvalidateLine,[ebx].EDIT.edta.hwnd,edi
		invoke InvalidateLine,[ebx].EDIT.edtb.hwnd,edi
		xor		eax,eax
		jmp		Ex
	.elseif eax==HEM_CLEARBOOKMARKS
		;wParam=0
		;lParam=0
		invoke ClearBookmarks
		xor		eax,eax
		jmp		Ex
	.elseif eax==HEM_NEXTBOOKMARK
		;wParam=0
		;lParam=lpHEBMK
		invoke NxtBookmark,lParam
		jmp		Ex
	.elseif eax==HEM_PREVIOUSBOOKMARK
		;wParam=0
		;lParam=lpHEBMK
		invoke PrvBookmark,lParam
		jmp		Ex
	.elseif eax==HEM_SELBARWIDTH
		;wParam=nWidth
		;lParam=0
		mov		eax,wParam
		mov		[ebx].EDIT.selbarwt,eax
		invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
		invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
		invoke SetCaret,[ebx].EDIT.focus
		xor		eax,eax
		jmp		Ex
	.elseif eax==HEM_LINENUMBERWIDTH
		;wParam=nWidth
		;lParam=0
		mov		eax,wParam
		mov		[ebx].EDIT.nlinenrwt,eax
		.if [ebx].EDIT.linenrwt
			mov		[ebx].EDIT.linenrwt,eax
			invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
			invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
			invoke SetCaret,[ebx].EDIT.focus
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==HEM_SETSPLIT
		;wParam=nSplitt
		;lParam=0
		mov		eax,wParam
		mov		[ebx].EDIT.fsplitt,eax
		call	SizeIt
		xor		eax,eax
		jmp		Ex
	.elseif eax==HEM_GETSPLIT
		;wParam=0
		;lParam=0
		mov		eax,[ebx].EDIT.fsplitt
		jmp		Ex
	.elseif eax==HEM_GETBYTE
		;wParam=cp
		;lParam=0
		mov		eax,wParam
		shr		eax,1
		.if eax>=[ebx].EDIT.nbytes
			xor		eax,eax
			dec		eax
		.else
			push	eax
			invoke GlobalLock,[ebx].EDIT.hmem
			pop		edx
			add		edx,eax
			movzx	eax,byte ptr [edx]
			push	eax
			invoke GlobalUnlock,[ebx].EDIT.hmem
			pop		eax
		.endif
		jmp		Ex
	.elseif eax==HEM_SETBYTE
		;wParam=cp
		;lParam=ByteVal
		mov		eax,wParam
		shr		eax,1
		.if eax>=[ebx].EDIT.nbytes
			xor		eax,eax
			dec		eax
		.else
			push	eax
			invoke GlobalLock,[ebx].EDIT.hmem
			pop		edx
			add		edx,eax
			mov		eax,lParam
			mov		byte ptr [edx],al
			invoke GlobalUnlock,[ebx].EDIT.hmem
			xor		eax,eax
		.endif
		jmp		Ex
	.elseif eax==HEM_GETOFFSET
		;wParam=0, lParam=0
		mov		eax,[ebx].EDIT.ofs
		jmp		Ex
	.elseif eax==HEM_SETOFFSET
		;wParam=ofs, lParam=0
		mov		eax,wParam
		mov		[ebx].EDIT.ofs,eax
		invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
		invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
		invoke SetCaret,[esi].HEEDT.hwnd
		xor		eax,eax
		jmp		Ex
	.elseif eax==HEM_SETMEM
		invoke GlobalLock,[ebx].EDIT.hmem
		mov		edi,eax
		mov		ecx,wParam
		mov		esi,lParam
		rep movsb
		mov		ecx,wParam
		mov		[ebx].EDIT.nbytes,ecx
		invoke GlobalUnlock,[ebx].EDIT.hmem
		invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
		invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
		xor		eax,eax
		jmp		Ex
	.elseif eax==HEM_GETMEM
		invoke GlobalLock,[ebx].EDIT.hmem
		mov		esi,eax
		mov		ecx,wParam
		mov		edi,lParam
		rep movsb
		invoke GlobalUnlock,[ebx].EDIT.hmem
		xor		eax,eax
		jmp		Ex
	.elseif eax==HEM_GETMODE		         ; *** MOD add
		;wParam=0, lParam=0
		.if [ebx].EDIT.fOvr == TRUE
			mov eax, MODE_OVERWRITE
		.else
			mov eax, MODE_NORMAL	
		.endif
		jmp Ex
	.elseif eax==HEM_SETMODE		         ; *** MOD add
		;wParam=nMode, lParam=0
		mov		eax,wParam
		test	eax,MODE_OVERWRITE
		.if ZERO?
			mov		[ebx].EDIT.fOvr,FALSE
		.else
			mov		[ebx].EDIT.fOvr,TRUE
		.endif
		invoke SetCaret,[esi].HEEDT.hwnd
		xor		eax,eax
		jmp Ex		
	.elseif eax==HEM_SUBCLASS                ; *** MOD add
		;wParam=0, lParam=lpWndProc
		invoke SetWindowLong,[ebx].EDIT.edta.hwnd,GWL_WNDPROC,lParam
		invoke SetWindowLong,[ebx].EDIT.edtb.hwnd,GWL_WNDPROC,lParam
	  	jmp Ex
	.elseif eax==EM_STREAMIN
		;wParam=SF_TEXT
		;lParam=lpStream
		invoke GetCursor
		push	eax
		invoke LoadCursor,0,IDC_WAIT
		invoke SetCursor,eax
		invoke StreamIn,ebx,lParam
		xor		eax,eax
		mov		[ebx].EDIT.edta.nline,eax
		mov		[ebx].EDIT.edtb.nline,eax
		mov		[ebx].EDIT.cpMin,eax
		mov		[ebx].EDIT.cpMax,eax
		mov		[ebx].EDIT.cpx,eax
		invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
		invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
		pop		eax
		invoke SetCursor,eax
		invoke SelChange,ebx,SEL_TEXT
		xor		eax,eax
		jmp		Ex
	.elseif eax==EM_STREAMOUT
		;wParam=SF_TEXT
		;lParam=lpStream
		invoke GetCursor
		push	eax
		invoke LoadCursor,0,IDC_WAIT
		invoke SetCursor,eax
		invoke StreamOut,ebx,lParam
		pop		eax
		invoke SetCursor,eax
		xor		eax,eax
		jmp		Ex
	.elseif eax==EM_GETMODIFY
		;wParam=0
		;lParam=0
		mov		eax,[ebx].EDIT.fChanged
		jmp		Ex
	.elseif eax==EM_SETMODIFY
		;wParam=TRUE/FALSE
		;lParam=0
		mov		eax,wParam
		mov		[ebx].EDIT.fChanged,eax
		invoke InvalidateRect,[ebx].EDIT.hsta,NULL,TRUE
		xor		eax,eax
		jmp		Ex
	.elseif eax==EM_EXGETSEL
		;wParam=0
		;lParam=lpCHARRANGE
		mov		edx,lParam
		mov		eax,[ebx].EDIT.cpMin
		mov		ecx,[ebx].EDIT.cpMax
		.if eax>ecx
			xchg	eax,ecx
		.endif
		mov		[edx].CHARRANGE.cpMin,eax
		mov		[edx].CHARRANGE.cpMax,ecx
		xor		eax,eax
		jmp		Ex
	.elseif eax==EM_EXSETSEL
		;wParam=0
		;lParam=lpCHARRANGE
		mov		edx,lParam
		mov		eax,[edx].CHARRANGE.cpMin
		mov		ecx,[edx].CHARRANGE.cpMax
		.if eax>ecx
			xchg	eax,ecx
		.endif
		mov		edx,[ebx].EDIT.nbytes
		shl		edx,1
		.if eax>edx
			mov		eax,edx
		.endif
		.if ecx>edx
			mov		ecx,edx
		.endif
		mov		[ebx].EDIT.cpMin,eax
		mov		[ebx].EDIT.cpMax,ecx
		invoke SetCaret,[ebx].EDIT.focus
		invoke InvalidateRect,[ebx].EDIT.edta.hwnd,NULL,FALSE
		invoke InvalidateRect,[ebx].EDIT.edtb.hwnd,NULL,FALSE
		invoke SelChange,ebx,SEL_TEXT
		xor		eax,eax
		jmp		Ex
	.elseif eax==EM_GETSELTEXT
		;wParam=0
		;lParam=lpBuff
		invoke EditGetSelText,ebx,lParam
		jmp		Ex
	.elseif eax==EM_SCROLLCARET
		;wParam=0
		;lParam=0
		invoke ScrollCaret,[ebx].EDIT.focus
		xor		eax,eax
		jmp		Ex
	.elseif eax==EM_REPLACESEL
		;wParam=fCanUndo
		;lParam=lpHexStr
		mov		eax,[ebx].EDIT.cpMin
		mov		ecx,[ebx].EDIT.cpMax
		.if eax>ecx
			xchg	eax,ecx
		.endif
		mov		cpMin,eax
		mov		cpMax,ecx
		sub		ecx,eax
		mov		fSel,ecx
		.if fSel
			test	[ebx].EDIT.fstyle,HEX_STYLE_READONLY
			jne		ErrBeep
			invoke DeleteSelection,ebx,cpMin,cpMax
		.endif
		mov		edx,lParam
		.if edx
			test	[ebx].EDIT.fstyle,HEX_STYLE_READONLY
			jne		ErrBeep
			mov		eax,cpMin
			shr		eax,1
			test	wParam,FR_HEX
			.if ZERO?
				invoke InsertAsciiString,ebx,eax,edx
			.else
				invoke InsertHexString,ebx,eax,edx
			.endif
			mov		[ebx].EDIT.fChanged,TRUE
			inc		[ebx].EDIT.nchange
		.endif
		invoke InvalidateRect,[ebx].EDIT.hsta,NULL,TRUE
		xor		eax,eax
		jmp		Ex
	.elseif eax==EM_FINDTEXTEX  
		;wParam=fuFlags
		;lParam=lpFINDTEXTEX 
		invoke FindTextEx,ebx,wParam,lParam
		jmp		Ex
	.elseif eax==EM_CANPASTE
		;wParam=CF_TEXT
		;lParam=0
		invoke IsClipboardFormatAvailable,wParam
		jmp		Ex
	.elseif eax==EM_CANREDO
		;wParam=0
		;lParam=0
		mov		edx,[ebx].EDIT.hundo
		add		edx,[ebx].EDIT.rpundo
		mov		eax,[edx].HEUNDO.cb
		.if eax
			mov		eax,TRUE
		.endif
		jmp		Ex
	.elseif eax==EM_REDO
		;wParam=0
		;lParam=0
		invoke Redo,ebx,[esi].HEEDT.hwnd
		jmp		Ex
	.elseif eax==EM_CANUNDO
		;wParam=0
		;lParam=0
		mov		eax,[ebx].EDIT.rpundo
		.if eax
			mov		eax,TRUE
		.endif
		jmp		Ex
	.elseif eax==EM_UNDO
		;wParam=0
		;lParam=0
		invoke Undo,ebx,[esi].HEEDT.hwnd
		jmp		Ex
	.elseif eax==EM_EMPTYUNDOBUFFER
		;wParam=0
		;lParam=0
		mov		edi,[ebx].EDIT.hundo
		mov		ecx,[ebx].EDIT.cbundo
		xor		eax,eax
		mov		[ebx].EDIT.rpundo,eax
		rep stosb
		jmp		Ex
	.elseif eax==EM_GETLINECOUNT
		;wParam=0
		;lParam=0
		mov		eax,[ebx].EDIT.nbytes
		shr		eax,4
		inc		eax
		jmp		Ex
	.elseif eax==EM_LINEINDEX
		;wParam=0
		;lParam=0
		mov		eax,wParam
		shl		eax,5
		jmp		Ex
	.elseif eax==WM_GETTEXTLENGTH
		mov		eax,[ebx].EDIT.nbytes
		jmp		Ex
	.elseif eax==WM_CLEAR
		;wParam=0
		;lParam=0
		mov		eax,[ebx].EDIT.cpMin
		mov		ecx,[ebx].EDIT.cpMax
		.if eax>ecx
			xchg	eax,ecx
		.endif
		mov		cpMin,eax
		mov		cpMax,ecx
		sub		ecx,eax
		mov		fSel,ecx
		.if fSel
			test	[ebx].EDIT.fstyle,HEX_STYLE_READONLY
			jne		ErrBeep
			invoke DeleteSelection,ebx,cpMin,cpMax
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_CUT
		;wParam=0
		;lParam=0
		invoke SendMessage,hWin,WM_COPY,0,0
		invoke SendMessage,hWin,WM_CLEAR,0,0
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_COPY
		;wParam=0
		;lParam=0
		invoke EditCopy,ebx
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_PASTE
		;wParam=0
		;lParam=0
		invoke EditPaste,ebx
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_MOUSEMOVE
		;Get mouse position
		mov		eax,lParam
		mov		edx,eax
		and		eax,0FFFFh
		shr		edx,16
		.if [ebx].EDIT.fresize==1
			mov		[ebx].EDIT.fresize,2
		.elseif [ebx].EDIT.fresize==2
			mov		eax,lParam
			shr		eax,16
			cwde
			sub		eax,2
			mov		edx,[ebx].EDIT.rc.bottom
			sub		edx,30
			.if sdword ptr eax<0
				xor		eax,eax
			.elseif sdword ptr eax>edx
				mov		eax,edx
			.endif
			.if eax
				shl		eax,10
				mov		ecx,[ebx].EDIT.rc.bottom
				xor		edx,edx
				div		ecx
			.endif
			mov		[ebx].EDIT.fsplitt,eax
			call	SizeIt
			invoke UpdateWindow,[ebx].EDIT.hsbtn
			invoke UpdateWindow,[ebx].EDIT.edta.hwnd
			invoke UpdateWindow,[ebx].EDIT.edtb.hwnd
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_LBUTTONUP
		.if [ebx].EDIT.fresize
			mov		[ebx].EDIT.fresize,0
			invoke ReleaseCapture
			call	SizeIt
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_SIZE
		push	edi
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		[ebx].EDIT.fstyle,eax
		invoke GetClientRect,hWin,addr [ebx].EDIT.rc
		mov		eax,[ebx].EDIT.fstyle
		and		eax,HEX_STYLE_NOLINENUMBER or HEX_STYLE_NOHSCROLL
		.if eax!=HEX_STYLE_NOLINENUMBER or HEX_STYLE_NOHSCROLL
			sub		[ebx].EDIT.rc.bottom,SBWT
		.endif
		call	SizeIt
		xor		edi,edi
		test	[ebx].EDIT.fstyle,HEX_STYLE_NOLINENUMBER
		.if ZERO?
			invoke MoveWindow,[ebx].EDIT.hlin,0,[ebx].EDIT.rc.bottom,BTNWT,SBWT,TRUE
			add		edi,BTNWT
		.else
			invoke MoveWindow,[ebx].EDIT.hlin,0,0,0,0,TRUE
		.endif
		mov		eax,[ebx].EDIT.fstyle
		and		eax,HEX_STYLE_NOLINENUMBER or HEX_STYLE_NOHSCROLL
		.if eax!=HEX_STYLE_NOLINENUMBER or HEX_STYLE_NOHSCROLL
			mov		ecx,[ebx].EDIT.rc.right
			sub		ecx,edi
			mov		eax,[ebx].EDIT.fstyle
			and		eax,HEX_STYLE_NOSPLITT or HEX_STYLE_NOVSCROLL
			.if eax!=HEX_STYLE_NOSPLITT or HEX_STYLE_NOVSCROLL
				sub		ecx,SBWT
				invoke MoveWindow,[ebx].EDIT.hhscroll,edi,[ebx].EDIT.rc.bottom,ecx,SBWT,TRUE
				test	[ebx].EDIT.fstyle,HEX_STYLE_NOSIZEGRIP
				jne		@f
				invoke GetWindowLong,[ebx].EDIT.hpar,GWL_STYLE
				test	eax,WS_MAXIMIZE
				jne		@f
				invoke GetClientRect,[ebx].EDIT.hpar,addr rect
				invoke ClientToScreen,[ebx].EDIT.hpar,addr rect.right
				mov		eax,[ebx].EDIT.rc.bottom
				add		eax,SBWT
				mov		rect.top,eax
				invoke ClientToScreen,hWin,addr rect
				mov		eax,rect.bottom
				sub		eax,rect.top
				.if eax<5
					mov		eax,[ebx].EDIT.rc.right
					sub		eax,SBWT
					invoke MoveWindow,[ebx].EDIT.hgrip,eax,[ebx].EDIT.rc.bottom,SBWT,SBWT,TRUE
					invoke MoveWindow,[ebx].EDIT.hnogrip,0,0,0,0,TRUE
				.else
				  @@:
					mov		eax,[ebx].EDIT.rc.right
					sub		eax,SBWT
					invoke MoveWindow,[ebx].EDIT.hnogrip,eax,[ebx].EDIT.rc.bottom,SBWT,SBWT,TRUE
					invoke MoveWindow,[ebx].EDIT.hgrip,0,0,0,0,TRUE
				.endif
			.else
				invoke MoveWindow,[ebx].EDIT.hhscroll,edi,[ebx].EDIT.rc.bottom,ecx,SBWT,TRUE
				invoke MoveWindow,[ebx].EDIT.hnogrip,0,0,0,0,TRUE
				invoke MoveWindow,[ebx].EDIT.hgrip,0,0,0,0,TRUE
			.endif
		.else
			invoke MoveWindow,[ebx].EDIT.hhscroll,0,0,0,0,TRUE
			invoke MoveWindow,[ebx].EDIT.hgrip,0,0,0,0,TRUE
			invoke MoveWindow,[ebx].EDIT.hnogrip,0,0,0,0,TRUE
		.endif
		pop		edi
	.elseif eax==WM_HSCROLL
		mov		sinf.cbSize,sizeof sinf
		mov		sinf.fMask,SIF_ALL
		invoke GetScrollInfo,lParam,SB_CTL,addr sinf
		mov		edi,[ebx].EDIT.cpx
		mov		eax,wParam
		movzx	eax,ax
		.if eax==SB_THUMBTRACK || eax==SB_THUMBPOSITION
			mov		edi,sinf.nTrackPos
		.elseif eax==SB_LINELEFT
			dec		edi
			jns		@f
			xor		edi,edi
		  @@:
		.elseif eax==SB_LINERIGHT
			add		edi,1
		.elseif eax==SB_PAGELEFT
			sub		edi,sinf.nPage
			jnb		@f
			xor		edi,edi
		  @@:
		.elseif eax==SB_PAGERIGHT
			add		edi,sinf.nPage
		.endif
		invoke Scroll,[ebx].EDIT.edtb.hwnd,edi,[ebx].EDIT.edtb.nline
	.elseif eax==WM_SETFOCUS
		mov		eax,[ebx].EDIT.focus
		.if eax==[ebx].EDIT.edta.hwnd
			invoke SetFocus,eax
		.else
			invoke SetFocus,[ebx].EDIT.edtb.hwnd
		.endif
		invoke SelChange,ebx,SEL_TEXT
	.elseif eax==WM_DESTROY
		invoke ClearWinBookmarks,hWin
		invoke DestroyWindow,[ebx].EDIT.htt
		invoke DestroyWindow,[ebx].EDIT.hsbtn
		invoke DestroyWindow,[ebx].EDIT.edta.hvscroll
		invoke DestroyWindow,[ebx].EDIT.edtb.hvscroll
		invoke DestroyWindow,[ebx].EDIT.hhscroll
		invoke DestroyWindow,[ebx].EDIT.hgrip
		invoke DestroyWindow,[ebx].EDIT.hnogrip
		invoke DestroyWindow,[ebx].EDIT.hlin
		invoke SetWindowLong,[ebx].EDIT.edta.hwnd,0,0
		invoke DestroyWindow,[ebx].EDIT.edta.hwnd
		invoke SetWindowLong,[ebx].EDIT.edtb.hwnd,0,0
		invoke DestroyWindow,[ebx].EDIT.edtb.hwnd
		invoke DestroyBrushes,ebx
		;Free memory
		invoke GlobalFree,[ebx].EDIT.hmem
		invoke GetProcessHeap
		mov		edi,eax
		invoke HeapFree,edi,NULL,[ebx].EDIT.hundo
		invoke HeapFree,edi,NULL,ebx
		invoke SetWindowLong,hWin,0,0
	.elseif eax==WM_SETFONT
		mov		eax,wParam
		mov		[ebx].EDIT.fnt.hFont,eax
		mov		[ebx].EDIT.fnt.hLnrFont,eax
		invoke SetFont,ebx,addr [ebx].EDIT.fnt
		.if eax
			invoke GetStockObject,SYSTEM_FIXED_FONT
			mov		[ebx].EDIT.fnt.hFont,eax
;			mov		[ebx].EDIT.fnt.hLnrFont,eax
			invoke SetFont,ebx,addr [ebx].EDIT.fnt
		.endif
	.elseif eax==WM_STYLECHANGED
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		[ebx].EDIT.fstyle,eax
		invoke SetFont,ebx,addr [ebx].EDIT.fnt
		invoke SendMessage,[ebx].EDIT.edtb.hwnd,WM_SIZE,SIZE_RESTORED,0
		invoke SendMessage,hWin,WM_SIZE,SIZE_RESTORED,0
	.elseif eax==HEM_RAINIT
		;WM_USER+9999 (=REM_RAINIT) is sendt to a custom control by RadASM (1.2.0.5)
		;to let the custom control fill in default design time values.
		invoke PutChar,ebx,0,offset szToolTip,16
		mov		[ebx].EDIT.nbytes,16
		xor		eax,eax
		jmp		Ex
	.endif
  ExDef:
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ErrBeep:
	invoke MessageBeep,MB_ICONHAND
	xor		eax,eax
	jmp		Ex

SetToolTip:
	mov		ti.cbSize,sizeof TOOLINFO
	mov		ti.uFlags,TTF_IDISHWND or TTF_SUBCLASS
	mov		ti.hWnd,0
	mov		ti.uId,eax
	mov		ti.hInst,0
	mov		ti.lpszText,edx
	invoke SendMessage,[ebx].EDIT.htt,TTM_ADDTOOL,NULL,addr ti
	retn

SizeIt:
	mov		eax,[ebx].EDIT.fsplitt
	.if eax
		mov		ecx,eax
		mov		eax,[ebx].EDIT.rc.bottom
		mul		ecx
		shr		eax,10
	.endif
	mov		[ebx].EDIT.nsplitt,eax
	.if [ebx].EDIT.nsplitt
		invoke MoveWindow,[ebx].EDIT.edta.hwnd,0,0,[ebx].EDIT.rc.right,[ebx].EDIT.nsplitt,TRUE
		mov		ecx,[ebx].EDIT.nsplitt
		add		ecx,BTNHT
		mov		eax,[ebx].EDIT.rc.bottom
		sub		eax,ecx
		push	eax
		push	ecx
		pop		ecx
		pop		eax
		invoke MoveWindow,[ebx].EDIT.edtb.hwnd,0,ecx,[ebx].EDIT.rc.right,eax,TRUE
		invoke MoveWindow,[ebx].EDIT.hsbtn,0,[ebx].EDIT.nsplitt,[ebx].EDIT.rc.right,BTNHT,TRUE
	.else
		invoke MoveWindow,[ebx].EDIT.edta.hwnd,0,0,0,0,TRUE
		mov		ecx,[ebx].EDIT.rc.right
		.if sdword ptr ecx<0
			xor		ecx,ecx
		.endif
		mov		edx,[ebx].EDIT.rc.bottom
		.if sdword ptr edx<0
			xor		edx,edx
		.endif
		invoke MoveWindow,[ebx].EDIT.edtb.hwnd,0,0,ecx,edx,TRUE
		mov		eax,[ebx].EDIT.rc.right
		sub		eax,SBWT
		test	[ebx].EDIT.fstyle,HEX_STYLE_NOSPLITT
		.if ZERO?
			invoke MoveWindow,[ebx].EDIT.hsbtn,eax,0,SBWT,BTNHT,TRUE
		.else
			invoke MoveWindow,[ebx].EDIT.hsbtn,0,0,0,0,TRUE
		.endif
		test	[ebx].EDIT.fstyle,HEX_STYLE_NOSTATE
		.if ZERO?
			invoke MoveWindow,[ebx].EDIT.hsta,0,0,4,4,TRUE
		.else
			invoke MoveWindow,[ebx].EDIT.hsta,0,0,0,0,TRUE
		.endif
	.endif
	retn

AllocMem:
	invoke GetProcessHeap
	invoke HeapAlloc,eax,HEAP_GENERATE_EXCEPTIONS or HEAP_NO_SERIALIZE or HEAP_ZERO_MEMORY,MAXUNDOMEM
	mov		[ebx].EDIT.hundo,eax
	mov		[ebx].EDIT.rpundo,0
	mov		[ebx].EDIT.cbundo,MAXUNDOMEM
	invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MAXCHARMEM
	mov		[ebx].EDIT.hmem,eax
	mov		[ebx].EDIT.nbytes,0
	mov		[ebx].EDIT.nsize,MAXCHARMEM
	mov		[ebx].EDIT.edta.nline,0
	mov		[ebx].EDIT.edtb.nline,0
	mov		[ebx].EDIT.cpx,0
	mov		[ebx].EDIT.cpMin,0
	mov		[ebx].EDIT.cpMax,0
	mov		[ebx].EDIT.fChanged,FALSE
	mov		[ebx].EDIT.fOvr,TRUE
	retn

RAWndProc endp

IFDEF DLL
	include RAHexEdDll.asm
ENDIF

end

