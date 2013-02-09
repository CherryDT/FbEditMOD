;KetilO (C) 2004
;
;In RadASM.ini section [CustCtrl], x=CustCtrl.dll,y
;x is next free number.
;y is number of controls in the dll. In this case there is only one control.
;
;x=RACad.dll,1
;Copy RACad.dll to c:\windows\system
;
.386
.model flat, stdcall
option casemap :none   ; case sensitive

include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

;Debug
include masm32.inc
include \RadASM\Masm\Inc\Debug.Inc
includelib masm32.lib
includelib \RadASM\Masm\Lib\Debug.lib

include ..\RACad.inc
include RACadCharSet.asm

CCDEF struct
	ID			dd ?		;Controls uniqe ID
	lptooltip	dd ?		;Pointer to tooltip text
	hbmp		dd ?		;Handle of bitmap
	lpcaption	dd ?		;Pointer to default caption text
	lpname		dd ?		;Pointer to default id-name text
	lpclass		dd ?		;Pointer to class text
	style		dd ?		;Default style
	exstyle		dd ?		;Default ex-style
	flist1		dd ?		;Property listbox 1
	flist2		dd ?		;Property listbox 2
	disable		dd ?		;Disable controls child windows. 0=No, 1=Use method 1, 2=Use method 2
CCDEF ends

IDB_RACADBUTTON		equ 100

CADVER				equ 100
GRID_SIZE			equ 25
SNAP_SIZE			equ 5
ZOOM_NORM			equ 200
ZOOM_INIT			equ 440
ZOOM_MIN			equ 40
ZOOM_MAX			equ 4000
MAXSIZE				equ 20000
MAXSTREAM			equ 32*1024
CHARWIDTH			equ 5
CHARHEIGHT			equ 15

.const

CadSelClass			db 'CADSELCLASS',0

szToolTip			db 'RACad control',0
szCap				db 0
szName				db 'IDC_CAD',0

STYLE				equ WS_CHILD or WS_VISIBLE or WS_HSCROLL or WS_VSCROLL or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
EXSTYLE				equ WS_EX_CLIENTEDGE

.data

;Create an inited struct. (Used by RadASM >= 1.2.0.5)
ccdef				CCDEF <290,offset szToolTip,0,offset szCap,offset szName,offset CadClass,STYLE,EXSTYLE,11111101000111000000000001000000b,00010000000000011000000000000000b,1>

.data?

hInstance			dd ?
sel					dd ?
selrect				RECT <?>
lastpos				POINT <?>
lastmov				POINT <?>
mpt					POINT <?>
curpos				POINT <?>
initcreate			dd ?
rpsize				dd ?
ncadbox				dd ?
hClip				dd ?
szText				db 1024 dup(?)
dimobj				OBJECT <?>
dimtxt				db 256 dup(?)

.code

InstallRACad proc
	LOCAL	wc:WNDCLASSEX

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset CadSelProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,4
	push	hInstance
	pop		wc.hInstance
	invoke GetStockObject,GRAY_BRUSH
	mov		wc.hbrBackground,eax
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset CadSelClass
	mov		wc.hIcon,NULL
	mov		wc.hIconSm,NULL
	invoke LoadCursor,0,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_GLOBALCLASS
	mov		wc.lpfnWndProc,offset CadProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,4
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset CadClass
	mov		wc.hIcon,NULL
	mov		wc.hIconSm,NULL
	invoke LoadCursor,0,IDC_CROSS
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke RegisterClipboardFormat,offset CadClass
	mov		hClip,eax
	ret

InstallRACad endp

UnInstallRACad proc

	ret

UnInstallRACad endp

ZoomMul proc

	cdq
	mov		ecx,[ebx].CADMEM.zoom
	imul	ecx
	mov		ecx,ZOOM_NORM
	idiv	ecx
	ret

ZoomMul endp

ZoomDiv proc

	cdq
	mov		ecx,ZOOM_NORM
	imul	ecx
	mov		ecx,[ebx].CADMEM.zoom
	idiv	ecx
	ret

ZoomDiv endp

CadNotify proc uses ebx esi,hWin:HWND,ncode:DWORD,rpobj:DWORD
	LOCAL	cn:CADNOTIFY

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,hWin
	mov		cn.nmhdr.hwndFrom,eax
	mov		eax,ncode
	mov		cn.nmhdr.code,eax
	mov		edx,[ebx].CADMEM.id
	mov		cn.nmhdr.idFrom,edx
	mov		eax,curpos.x
	add		eax,[ebx].CADMEM.scroll.x
	call	ZoomDiv
	mov		cn.cur.x,eax
	mov		eax,curpos.y
	add		eax,[ebx].CADMEM.scroll.y
	call	ZoomDiv
	mov		cn.cur.y,eax
	mov		eax,[ebx].CADMEM.zoom
	mov		cn.zoom,eax
	mov		eax,rpobj
	mov		cn.rpobj,eax
	.if ncode==CN_SIZE
		lea		esi,[ebx+eax+sizeof CADMEM]
		mov		al,[esi].OBJECT.tpe
		mov		cn.tpe,al
		mov		eax,[esi].OBJECT.rc.right
		sub		eax,[esi].OBJECT.rc.left
		.if CARRY?
			neg		eax
		.endif
		mul		eax
		push	eax
		mov		eax,[esi].OBJECT.rc.bottom
		sub		eax,[esi].OBJECT.rc.top
		.if CARRY?
			neg		eax
		.endif
		mul		eax
		pop		edx
		add		eax,edx
		mov		cn.len,eax
		fild	cn.len
		fsqrt
		fistp	cn.len
	.else
		mov		cn.tpe,0
		mov		cn.len,0
	.endif
	invoke SendMessage,[ebx].CADMEM.hpar,WM_NOTIFY,edx,addr cn
	ret

CadNotify endp

CadSetClipData proc lpData:DWORD,dwSize:DWORD
	LOCAL	hMem:DWORD
	LOCAL	pMem:DWORD

	mov		eax,dwSize
	invoke GlobalAlloc,GHND or GMEM_DDESHARE,eax
	test	eax,eax
	je		@exit2
	mov		hMem,eax
	invoke GlobalLock,eax	;hGlob
	test	eax,eax
	je		@exit1
	mov		pMem,eax
	invoke RtlMoveMemory,eax,lpData,dwSize
	invoke GlobalUnlock,hMem
	invoke OpenClipboard,NULL
	.if eax
		invoke EmptyClipboard
		invoke SetClipboardData,hClip,hMem
		invoke CloseClipboard
		xor		eax,eax		;0 - Ok
		jmp		@exit3
	.endif
  @exit1:
	invoke  GlobalFree,hMem
	xor     eax,eax
  @exit2:
	dec     eax          ; -1 - error
  @exit3:
	ret

CadSetClipData endp

CadDestroySel proc uses ebx,hWin:HWND,lpObject:DWORD

	mov		edx,lpObject
	mov		ebx,[edx].OBJECT.hsel
	mov		[edx].OBJECT.hsel,0
	.while ebx
		invoke GetWindowLong,ebx,0
		push	eax
		invoke DestroyWindow,ebx
		pop		ebx
	.endw
	ret

CadDestroySel endp

CadInvalidateObject proc uses ebx esi edi,hWin:HWND,lpObject:DWORD
	LOCAL	rect:RECT
	LOCAL	pt:POINT

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		esi,lpObject
	mov		eax,[esi].OBJECT.rc.left
	call	ZoomMul
	sub		eax,[ebx].CADMEM.scroll.x
	dec		eax
	mov		pt.x,eax
	mov		eax,[esi].OBJECT.rc.top
	call	ZoomMul
	sub		eax,[ebx].CADMEM.scroll.y
	dec		eax
	mov		pt.y,eax
	.if [esi].OBJECT.tpe==TPE_SYMBOL || [esi].OBJECT.tpe==-TPE_SYMBOL
		mov		eax,pt.x
		mov		rect.left,eax
		mov		eax,pt.y
		mov		rect.top,eax
		mov		eax,[esi].OBJECT.rc.right
		call	ZoomMul
		sub		eax,[ebx].CADMEM.scroll.x
		mov		rect.right,eax
		mov		eax,[esi].OBJECT.rc.bottom
		call	ZoomMul
		sub		eax,[ebx].CADMEM.scroll.y
		mov		rect.bottom,eax
		sub		rect.left,24
		sub		rect.top,24
		add		rect.right,24
		add		rect.bottom,24
		invoke InvalidateRect,hWin,addr rect,TRUE
	.else
		mov		ecx,[esi].OBJECT.npt
		dec		ecx
		mov		edi,esi
		.while ecx
			push	ecx
			mov		eax,pt.x
			mov		rect.left,eax
			mov		eax,pt.y
			mov		rect.top,eax
			mov		eax,[edi].OBJECT.rc.right
			.if [esi].OBJECT.tpe==TPE_HTEXT
				sub		eax,[edi].OBJECT.rc.left
				movzx	ecx,[esi].OBJECT.wdt
				mul		ecx
				add		eax,[edi].OBJECT.rc.left
			.elseif [esi].OBJECT.tpe==TPE_VTEXT
				sub		eax,[edi].OBJECT.rc.left
				movzx	ecx,[esi].OBJECT.wdt
				mul		ecx
				shr		eax,1
				add		eax,[edi].OBJECT.rc.left
			.endif
			call	ZoomMul
			sub		eax,[ebx].CADMEM.scroll.x
			mov		pt.x,eax
			mov		rect.right,eax
			mov		eax,[edi].OBJECT.rc.bottom
			.if [esi].OBJECT.tpe==TPE_HTEXT
				sub		eax,[edi].OBJECT.rc.top
				movzx	ecx,[esi].OBJECT.wdt
				mul		ecx
				shr		eax,1
				add		eax,[edi].OBJECT.rc.top
			.elseif [esi].OBJECT.tpe==TPE_VTEXT
				sub		eax,[edi].OBJECT.rc.top
				movzx	ecx,[esi].OBJECT.wdt
				mul		ecx
				add		eax,[edi].OBJECT.rc.top
			.endif
			call	ZoomMul
			sub		eax,[ebx].CADMEM.scroll.y
			mov		pt.y,eax
			mov		rect.bottom,eax
			mov		eax,rect.right
			.if sdword ptr eax<rect.left
				xchg	eax,rect.left
			.endif
			mov		rect.right,eax
			mov		eax,rect.bottom
			.if sdword ptr eax<rect.top
				xchg	eax,rect.top
			.endif
			mov		rect.bottom,eax
			movzx	eax,[esi].OBJECT.wdt
			.if [esi].OBJECT.tpe==TPE_DIMENSION
				add		eax,6
			.endif
			call	ZoomMul
			inc		eax
			shr		eax,1
			sub		rect.left,eax
			sub		rect.top,eax
			inc		eax
			add		rect.right,eax
			add		rect.bottom,eax
			invoke InvalidateRect,hWin,addr rect,TRUE
			add		edi,8
			pop		ecx
			dec		ecx
		.endw
	.endif
	ret

CadInvalidateObject endp

CadDrawObject proc uses ebx esi edi,hDC:HDC,xofs:DWORD,yofs:DWORD,hMem:DWORD,lpObject:DWORD,fSwapxy:DWORD,fWhite:DWORD
	LOCAL	pt1:POINT
	LOCAL	pt2:POINT
	LOCAL	dwVal:DWORD
	LOCAL	fak:REAL8
	LOCAL	lx:DWORD
	LOCAL	ly:DWORD

	mov		ebx,hMem
	mov		esi,lpObject
	mov		eax,[ebx].CADMEM.layer
	movzx	edx,[esi].OBJECT.layer
	.if eax==0
		.if eax!=edx
			jmp		Ex
		.endif
	.elseif eax==1
		.if edx==0
			jmp		Ex
		.endif
	.elseif eax==2
		.if edx!=2 && edx!=3
			jmp		Ex
		.endif
	.elseif eax==3
		.if edx!=2 && edx!=3
			jmp		Ex
		.endif
	.endif
	movzx	eax,[esi].OBJECT.tpe
	.if eax==TPE_LINE
		call	DrawLine
	.elseif eax==TPE_RECT
		call	DrawRect
	.elseif eax==TPE_CIRCLE
		call	DrawCircle
	.elseif eax==TPE_POLYLINE
		call	DrawPolyLine
	.elseif eax==TPE_HTEXT
		call	DrawHText
	.elseif eax==TPE_VTEXT
		call	DrawVText
	.elseif eax==TPE_DIMENSION
		call	DrawDimension
	.elseif eax==TPE_SYMBOL
		mov		ecx,[esi].OBJECT.npt
		mov		edi,[esi].OBJECT.hsel
		lea		esi,[esi+sizeof OBJECT]
		.while ecx
			push	ecx
			mov		[esi].OBJECT.hsel,edi
			invoke CadDrawObject,hDC,xofs,yofs,hMem,esi,fSwapxy,fWhite
			mov		eax,[esi].OBJECT.cbsize
			lea		esi,[esi+eax]
			pop		ecx
			dec		ecx
		.endw
	.endif
  Ex:
	ret

MakePen:
	movzx	eax,[esi].OBJECT.wdt
	call	ZoomMul
	.if fWhite
		mov		edx,0FFFFFFh
	.else
		push	eax
		movzx	eax,[esi].OBJECT.layer
		.if eax==[ebx].CADMEM.layer
			mov		edx,[esi].OBJECT.color
		.else
			mov		edx,0E0E0E0h
		.endif
		.if [esi].OBJECT.hsel
			mov		edx,0C0C000h
		.endif
		pop		eax
	.endif
	invoke CreatePen,PS_SOLID,eax,edx
	invoke SelectObject,hDC,eax
	retn

DelPen:
	invoke SelectObject,hDC,eax
	invoke DeleteObject,eax
	retn

DrawLine:
	mov		eax,[esi].OBJECT.rc.top
	call	ZoomMul
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.left
	call	ZoomMul
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke MoveToEx,hDC,eax,edx,NULL
	call	MakePen
	push	eax
	mov		eax,[esi].OBJECT.rc.bottom
	call	ZoomMul
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.right
	call	ZoomMul
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke LineTo,hDC,eax,edx
	pop		eax
	call	DelPen
	retn

DrawRect:
	mov		eax,[esi].OBJECT.rc.top
	call	ZoomMul
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.left
	call	ZoomMul
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke MoveToEx,hDC,eax,edx,NULL
	call	MakePen
	push	eax
	mov		eax,[esi].OBJECT.rc.top
	call	ZoomMul
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.right
	call	ZoomMul
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke LineTo,hDC,eax,edx
	mov		eax,[esi].OBJECT.rc.bottom
	call	ZoomMul
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.right
	call	ZoomMul
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke LineTo,hDC,eax,edx
	mov		eax,[esi].OBJECT.rc.bottom
	call	ZoomMul
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.left
	call	ZoomMul
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke LineTo,hDC,eax,edx
	mov		eax,[esi].OBJECT.rc.top
	call	ZoomMul
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.left
	call	ZoomMul
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke LineTo,hDC,eax,edx
	pop		eax
	call	DelPen
	retn

DrawCircle:
	mov		eax,[esi].OBJECT.rc.left
	call	ZoomMul
	sub		eax,xofs
	mov		pt1.x,eax
	mov		eax,[esi].OBJECT.rc.top
	call	ZoomMul
	sub		eax,yofs
	mov		pt1.y,eax
	mov		eax,[esi].OBJECT.rc.right
	call	ZoomMul
	sub		eax,xofs
	mov		pt2.x,eax
	mov		eax,[esi].OBJECT.rc.bottom
	call	ZoomMul
	sub		eax,yofs
	mov		pt2.y,eax
	mov		eax,pt2.x
	.if sdword ptr eax<pt1.x
		xchg	eax,pt1.x
	.endif
	inc		eax
	mov		pt2.x,eax
	mov		eax,pt2.y
	.if sdword ptr eax<pt1.y
		xchg	eax,pt1.y
	.endif
	inc		eax
	mov		pt2.y,eax
	.if fSwapxy
		mov		eax,pt1.x
		mov		edx,pt1.y
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
		mov		pt1.x,eax
		mov		pt1.y,edx
		mov		eax,pt2.x
		mov		edx,pt2.y
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
		mov		pt2.x,eax
		mov		pt2.y,edx
	.endif
	call	MakePen
	push	eax
	invoke Arc,hDC,pt1.x,pt1.y,pt2.x,pt2.y,0,0,0,0
	pop		eax
	call	DelPen
	retn

DrawPolyLine:
	mov		eax,[esi].OBJECT.rc.top
	call	ZoomMul
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.left
	call	ZoomMul
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke MoveToEx,hDC,eax,edx,NULL
	call	MakePen
	push	eax
	mov		ecx,[esi].OBJECT.npt
	dec		ecx
	lea		edi,[esi].OBJECT.rc.right
	.while ecx
		push	ecx
		mov		eax,[edi].POINT.y
		call	ZoomMul
		sub		eax,yofs
		push	eax
		mov		eax,[edi].POINT.x
		call	ZoomMul
		sub		eax,xofs
		pop		edx
		.if fSwapxy
			xchg	eax,edx
			sub		eax,fSwapxy
			neg		eax
		.endif
		invoke LineTo,hDC,eax,edx
		add		edi,8
		pop		ecx
		dec		ecx
	.endw
	pop		eax
	call	DelPen
	retn

DrawHText:
	call	MakePen
	push	eax
	mov		eax,[esi].OBJECT.rc.top
	call	ZoomMul
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.left
	call	ZoomMul
	sub		eax,xofs
	pop		edx
	mov		pt1.x,eax
	mov		pt1.y,edx
	lea		edx,[esi+sizeof OBJECT]
	.while byte ptr [edx]
		push	edx
		movzx	eax,byte ptr [edx]
		lea		edi,FontCharset[eax*4]
		mov		edi,[edi]
		.if byte ptr [edi] && byte ptr [edi+1]
		  NxtH:
			movzx	eax,byte ptr [edi]
			movzx	ecx,[esi].OBJECT.wdt
			mul		ecx
			invoke ZoomMul
			shr		eax,1
			add		eax,pt1.x
			push	eax
			movzx	eax,byte ptr [edi+1]
			movzx	ecx,[esi].OBJECT.wdt
			mul		ecx
			invoke ZoomMul
			shr		eax,1
			add		eax,pt1.y
			mov		edx,eax
			pop		eax
			.if fSwapxy
				xchg	eax,edx
				sub		eax,fSwapxy
				neg		eax
			.endif
			invoke MoveToEx,hDC,eax,edx,NULL
			lea		edi,[edi+2]
			.while byte ptr [edi]
				movzx	eax,byte ptr [edi+1]
				movzx	ecx,[esi].OBJECT.wdt
				mul		ecx
				invoke ZoomMul
				shr		eax,1
				add		eax,pt1.y
				push	eax
				movzx	eax,byte ptr [edi]
				movzx	ecx,[esi].OBJECT.wdt
				mul		ecx
				invoke ZoomMul
				shr		eax,1
				add		eax,pt1.x
				pop		edx
				.if fSwapxy
					xchg	eax,edx
					sub		eax,fSwapxy
					neg		eax
				.endif
				invoke LineTo,hDC,eax,edx
				lea		edi,[edi+2]
			.endw
			.if byte ptr [edi+1]
				inc		edi
				jmp		NxtH
			.endif
		.endif
		mov		eax,CHARWIDTH
		movzx	ecx,[esi].OBJECT.wdt
		mul		ecx
		;shr		eax,1
		invoke ZoomMul
		add		pt1.x,eax
		pop		edx
		inc		edx
	.endw
	pop		eax
	call	DelPen
	retn

DrawVText:
	call	MakePen
	push	eax
	mov		eax,[esi].OBJECT.rc.top
	call	ZoomMul
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.left
	call	ZoomMul
	sub		eax,xofs
	pop		edx
	mov		pt1.y,eax
	mov		pt1.x,edx
	lea		edx,[esi+sizeof OBJECT]
	.while byte ptr [edx]
		push	edx
		movzx	eax,byte ptr [edx]
		lea		edi,FontCharset[eax*4]
		mov		edi,[edi]
		.if byte ptr [edi] && byte ptr [edi+1]
		  NxtV:
			movzx	eax,byte ptr [edi]
			movzx	ecx,[esi].OBJECT.wdt
			mul		ecx
			invoke ZoomMul
			shr		eax,1
			add		eax,pt1.x
			push	eax
			movzx	eax,byte ptr [edi+1]
			sub		eax,CHARHEIGHT
			neg		eax
			movzx	ecx,[esi].OBJECT.wdt
			mul		ecx
			invoke ZoomMul
			shr		eax,1
			add		eax,pt1.y
			mov		edx,eax
			pop		eax
			.if fSwapxy
				xchg	eax,edx
				sub		edx,fSwapxy
				neg		edx
			.endif
			xchg	eax,edx
			invoke MoveToEx,hDC,eax,edx,NULL
			lea		edi,[edi+2]
			.while byte ptr [edi]
				movzx	eax,byte ptr [edi+1]
				sub		eax,CHARHEIGHT
				neg		eax
				movzx	ecx,[esi].OBJECT.wdt
				mul		ecx
				invoke ZoomMul
				shr		eax,1
				add		eax,pt1.y
				push	eax
				movzx	eax,byte ptr [edi]
				movzx	ecx,[esi].OBJECT.wdt
				mul		ecx
				invoke ZoomMul
				shr		eax,1
				add		eax,pt1.x
				pop		edx
				.if fSwapxy
					xchg	eax,edx
					sub		edx,fSwapxy
					neg		edx
				.endif
				xchg	eax,edx
				invoke LineTo,hDC,eax,edx
				lea		edi,[edi+2]
			.endw
			.if byte ptr [edi+1]
				inc		edi
				jmp		NxtV
			.endif
		.endif
		mov		eax,CHARWIDTH
		movzx	ecx,[esi].OBJECT.wdt
		mul		ecx
		;shr		eax,1
		invoke ZoomMul
		add		pt1.x,eax
		pop		edx
		inc		edx
	.endw
	pop		eax
	call	DelPen
	retn

DrawDimension:
	call	MakePen
	push	eax
	mov		eax,[esi].OBJECT.rc.top
	call	ZoomMul
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.left
	call	ZoomMul
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke MoveToEx,hDC,eax,edx,NULL
	mov		eax,[esi].OBJECT.rc.bottom
	sub		eax,[esi].OBJECT.rc.top
	.if SIGN?
		neg		eax
		shr		eax,2
		neg		eax
	.else
		shr		eax,2
	.endif
	add		eax,[esi].OBJECT.rc.top
	call	ZoomMul
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.right
	sub		eax,[esi].OBJECT.rc.left
	.if SIGN?
		neg		eax
		shr		eax,2
		neg		eax
	.else
		shr		eax,2
	.endif
	add		eax,[esi].OBJECT.rc.left
	call	ZoomMul
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke LineTo,hDC,eax,edx

	mov		eax,[esi].OBJECT.rc.bottom
	call	ZoomMul
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.right
	call	ZoomMul
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke MoveToEx,hDC,eax,edx,NULL
	mov		eax,[esi].OBJECT.rc.bottom
	sub		eax,[esi].OBJECT.rc.top
	.if SIGN?
		neg		eax
		shr		eax,2
		neg		eax
	.else
		shr		eax,2
	.endif
	mov		edx,eax
	mov		eax,[esi].OBJECT.rc.bottom
	sub		eax,edx
	call	ZoomMul
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.right
	sub		eax,[esi].OBJECT.rc.left
	.if SIGN?
		neg		eax
		shr		eax,2
		neg		eax
	.else
		shr		eax,2
	.endif
	mov		edx,eax
	mov		eax,[esi].OBJECT.rc.right
	sub		eax,edx
	call	ZoomMul
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke LineTo,hDC,eax,edx

	mov		eax,[esi].OBJECT.rc.right
	sub		eax,[esi].OBJECT.rc.left
	.if CARRY?
		neg		eax
	.endif
	mul		eax
	push	eax
	mov		eax,[esi].OBJECT.rc.bottom
	sub		eax,[esi].OBJECT.rc.top
	.if CARRY?
		neg		eax
	.endif
	mul		eax
	pop		edx
	add		eax,edx
	.if !eax
		inc		eax
	.endif
	mov		dwVal,eax
	fild	dwVal
	fsqrt
	mov		dwVal,2
	fidiv	dwVal
	fstp	fak

	mov		eax,[esi].OBJECT.rc.right
	sub		eax,[esi].OBJECT.rc.left
	call	ZoomMul
	mov		lx,eax
	fild	lx
	fdiv	fak
	fistp	lx
	mov		eax,[esi].OBJECT.rc.bottom
	sub		eax,[esi].OBJECT.rc.top
	call	ZoomMul
	mov		ly,eax
	fild	ly
	fdiv	fak
	fistp	ly

	mov		eax,[esi].OBJECT.rc.top
	call	ZoomMul
	sub		eax,lx
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.left
	call	ZoomMul
	add		eax,ly
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke MoveToEx,hDC,eax,edx,NULL
	mov		eax,[esi].OBJECT.rc.top
	call	ZoomMul
	add		eax,lx
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.left
	call	ZoomMul
	sub		eax,ly
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke LineTo,hDC,eax,edx

	mov		eax,[esi].OBJECT.rc.bottom
	call	ZoomMul
	sub		eax,lx
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.right
	call	ZoomMul
	add		eax,ly
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke MoveToEx,hDC,eax,edx,NULL
	mov		eax,[esi].OBJECT.rc.bottom
	call	ZoomMul
	add		eax,lx
	sub		eax,yofs
	push	eax
	mov		eax,[esi].OBJECT.rc.right
	call	ZoomMul
	sub		eax,ly
	sub		eax,xofs
	pop		edx
	.if fSwapxy
		xchg	eax,edx
		sub		eax,fSwapxy
		neg		eax
	.endif
	invoke LineTo,hDC,eax,edx
	pop		eax
	call	DelPen
	retn

CadDrawObject endp

CadDraw proc uses ebx esi,hWin:HWND,hDC:HDC,xofs:DWORD,yofs:DWORD,wt:DWORD,ht:DWORD,fNosel:DWORD,fSwapxy:DWORD
	LOCAL	hSel:HWND
	LOCAL	wdt:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	.if [ebx].CADMEM.grid
		call	DrawGrid
	.endif
	mov		eax,3
	call	ZoomMul
	.if eax<3
		mov		eax,3
	.endif
	mov		wdt,eax
	lea		esi,[ebx+sizeof CADMEM]
	.while byte ptr [esi].OBJECT.tpe
		.if sbyte ptr [esi].OBJECT.tpe>0
			invoke CadDrawObject,hDC,xofs,yofs,ebx,esi,fSwapxy,FALSE
			.if !fNosel
				call	MoveSel
			.endif
		.endif
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw
	ret

DrawGrid:
	mov		eax,GRID_SIZE
	call	ZoomMul
	.if eax>4
		push	esi
		push	edi
		xor		edi,edi
		.while edi<MAXSIZE
			mov		eax,edi
			call	ZoomMul
			sub		eax,yofs
			.if sdword ptr eax>=0
				push	edi
				mov		edi,eax
				xor		esi,esi
				.while esi<MAXSIZE
					mov		eax,esi
					call	ZoomMul
					sub		eax,xofs
					.if sdword ptr eax>=0
						.break .if sdword ptr eax>wt
						invoke SetPixel,hDC,eax,edi,0404040h
					.endif
					add		esi,GRID_SIZE
				.endw
				mov		eax,edi
				pop		edi
			.endif
			.break .if sdword ptr eax>ht
			add		edi,GRID_SIZE
		.endw
		pop		edi
		pop		esi
	.endif
	retn

MoveSelWin:
	invoke GetWindowLong,hSel,GWL_ID
	shl		eax,3
	mov		edx,[esi].OBJECT.rc.top[eax]
	mov		eax,[esi].OBJECT.rc.left[eax]
	push	eax
	mov		eax,edx
	call	ZoomMul
	sub		eax,[ebx].CADMEM.scroll.y
	pop		edx
	push	eax
	mov		eax,edx
	call	ZoomMul
	sub		eax,[ebx].CADMEM.scroll.x
	pop		edx
	mov		ecx,wdt
	shr		ecx,1
	sub		eax,ecx
	sub		edx,ecx
	shl		ecx,1
	inc		ecx
	invoke MoveWindow,hSel,eax,edx,ecx,ecx,TRUE
	invoke UpdateWindow,hSel
	retn

MoveSel:
	.if [esi].OBJECT.hsel
		mov		eax,[esi].OBJECT.hsel
		.while eax
			mov		hSel,eax
			call	MoveSelWin
			invoke GetWindowLong,hSel,0
		.endw
	.endif
	retn

CadDraw endp

CadSnap proc uses ebx esi,hWin:HWND,lpPt:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		esi,lpPt
	mov		eax,SNAP_SIZE
	call	ZoomMul
	mov		ecx,eax
	.if [ebx].CADMEM.snap && ecx >=3
		mov		eax,[esi].POINT.x
		mov		edx,ecx
		shr		edx,1
		add		eax,edx
		add		eax,[ebx].CADMEM.scroll.x
		xor		edx,edx
		div		ecx
		mul		ecx
		sub		eax,[ebx].CADMEM.scroll.x
		mov		[esi].POINT.x,eax
		mov		eax,[esi].POINT.y
		mov		edx,ecx
		shr		edx,1
		add		eax,edx
		add		eax,[ebx].CADMEM.scroll.y
		xor		edx,edx
		div		ecx
		mul		ecx
		sub		eax,[ebx].CADMEM.scroll.y
		mov		[esi].POINT.y,eax
	.endif
	ret

CadSnap endp

CadSelProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hcad:HWND
	LOCAL	pt:POINT
	LOCAL	cpt:POINT

	mov		eax,uMsg
	.if eax==WM_LBUTTONDOWN
		invoke GetParent,hWin
		mov		hcad,eax
		invoke ShowWindow,hWin,SW_HIDE
		invoke SetCapture,hWin
		invoke GetCursorPos,addr mpt
		invoke ScreenToClient,hcad,addr mpt
		invoke CadSnap,hcad,addr mpt
		mov		lastmov.x,0
		mov		lastmov.y,0
	.elseif eax==WM_LBUTTONUP
		invoke GetCapture
		.if eax==hWin
			invoke ReleaseCapture
			invoke ShowWindow,hWin,SW_SHOW
		.endif
	.elseif eax==WM_MOUSEMOVE
		invoke GetCapture
		.if eax==hWin
			invoke GetParent,hWin
			mov		hcad,eax
			invoke GetWindowLong,hcad,0
			mov		ebx,eax
			invoke GetCursorPos,addr pt
			invoke ScreenToClient,hcad,addr pt
			invoke CadSnap,hcad,addr pt
			mov		eax,pt.x
			mov		curpos.x,eax
			sub		eax,mpt.x
			call	ZoomDiv
			mov		cpt.x,eax
			mov		eax,pt.y
			mov		curpos.y,eax
			sub		eax,mpt.y
			call	ZoomDiv
			mov		cpt.y,eax
			invoke CadNotify,hcad,CN_CURMOVE,0
			test	wParam,MK_CONTROL
			.if ZERO?
				invoke GetWindowLong,hWin,GWL_USERDATA
				lea		esi,[ebx+eax+sizeof CADMEM]
				invoke CadInvalidateObject,hcad,esi
				mov		eax,hWin
				call	Update
				invoke CadInvalidateObject,hcad,esi
				mov		[ebx].CADMEM.changed,TRUE
;				mov		eax,esi
;				sub		eax,ebx
;				sub		eax,sizeof CADMEM
;				invoke CadNotify,hcad,CN_SIZE,eax
			.else
				lea		esi,[ebx+sizeof CADMEM]
				.while [esi].OBJECT.tpe
					.if sbyte ptr [esi].OBJECT.tpe>0
						mov		eax,[esi].OBJECT.hsel
						.if eax
							invoke CadInvalidateObject,hcad,esi
							mov		eax,[esi].OBJECT.hsel
							.while eax
								push	eax
								call	Update
								pop		eax
								invoke GetWindowLong,eax,0
							.endw
							invoke CadInvalidateObject,hcad,esi
							mov		[ebx].CADMEM.changed,TRUE
						.endif
					.endif
					mov		eax,[esi].OBJECT.cbsize
					lea		esi,[esi+eax]
				.endw
			.endif
			mov		eax,cpt.x
			mov		lastmov.x,eax
			mov		eax,cpt.y
			mov		lastmov.y,eax
		.endif
	.elseif eax==WM_WINDOWPOSCHANGED
	.elseif eax==WM_RBUTTONDOWN
		invoke GetParent,hWin
		mov		hcad,eax
		invoke GetWindowLong,hWin,GWL_USERDATA
		invoke CadNotify,hcad,CN_SELRCLICK,eax
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor		eax,eax
	ret

Update:
	invoke GetWindowLong,eax,GWL_ID
	lea		edi,[eax*8]
	mov		eax,cpt.x
	sub		eax,lastmov.x
	add		[esi].OBJECT.rc.left[edi],eax
	mov		eax,cpt.y
	sub		eax,lastmov.y
	add		[esi].OBJECT.rc.top[edi],eax
	.if [esi].OBJECT.tpe==TPE_HTEXT || [esi].OBJECT.tpe==TPE_VTEXT
		add		edi,8
		mov		eax,cpt.x
		sub		eax,lastmov.x
		add		[esi].OBJECT.rc.left[edi],eax
		mov		eax,cpt.y
		sub		eax,lastmov.y
		add		[esi].OBJECT.rc.top[edi],eax
	.elseif [esi].OBJECT.tpe==TPE_SYMBOL
		push	esi
		mov		eax,cpt.x
		sub		eax,lastmov.x
		add		[esi].OBJECT.rc.right,eax
		mov		eax,cpt.y
		sub		eax,lastmov.y
		add		[esi].OBJECT.rc.bottom,eax
		mov		ecx,[esi].OBJECT.npt
		lea		esi,[esi+sizeof OBJECT]
		.while ecx
			mov		eax,cpt.x
			sub		eax,lastmov.x
			add		[esi].OBJECT.rc.left,eax
			mov		eax,cpt.y
			sub		eax,lastmov.y
			add		[esi].OBJECT.rc.top,eax
			movzx	eax,[esi].OBJECT.tpe
			.if eax==TPE_LINE || eax==TPE_RECT || eax==TPE_CIRCLE || eax==TPE_DIMENSION
				mov		eax,cpt.x
				sub		eax,lastmov.x
				add		[esi].OBJECT.rc.right,eax
				mov		eax,cpt.y
				sub		eax,lastmov.y
				add		[esi].OBJECT.rc.bottom,eax
			.elseif eax==TPE_HTEXT || eax==TPE_VTEXT
				mov		eax,cpt.x
				sub		eax,lastmov.x
				add		[esi].OBJECT.rc.right,eax
				mov		eax,cpt.y
				sub		eax,lastmov.y
				add		[esi].OBJECT.rc.bottom,eax
			.endif
			mov		eax,[esi].OBJECT.cbsize
			lea		esi,[esi+eax]
			dec		ecx
		.endw
		pop		esi
	.endif
	retn

CadSelProc endp

CadSelect proc uses ebx esi,hWin:HWND,lpObject:DWORD,fSel:DWORD
	LOCAL	id:DWORD
	LOCAL	hSel:HWND

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		esi,lpObject
	xor		eax,eax
	.if fSel && ![esi].OBJECT.hsel
		mov		eax,[ebx].CADMEM.layer
		.if al==[esi].OBJECT.layer
			movzx	eax,[esi].OBJECT.tpe
			.if eax==TPE_LINE
				mov		ecx,[esi].OBJECT.npt
				call	CreateSel
			.elseif eax==TPE_RECT
				mov		ecx,[esi].OBJECT.npt
				call	CreateSel
			.elseif eax==TPE_CIRCLE
				mov		ecx,[esi].OBJECT.npt
				call	CreateSel
			.elseif eax==TPE_POLYLINE
				mov		ecx,[esi].OBJECT.npt
				call	CreateSel
			.elseif eax==TPE_HTEXT
				mov		ecx,1
				call	CreateSel
			.elseif eax==TPE_VTEXT
				mov		ecx,1
				call	CreateSel
			.elseif eax==TPE_DIMENSION
				mov		ecx,[esi].OBJECT.npt
				call	CreateSel
			.elseif eax==TPE_SYMBOL
				mov		ecx,1
				call	CreateSel
			.endif
			invoke CadInvalidateObject,hWin,esi
			mov		eax,TRUE
		.else
			xor		eax,eax
		.endif
	.elseif !fSel && [esi].OBJECT.hsel
		invoke CadDestroySel,hWin,esi
		invoke CadInvalidateObject,hWin,esi
		mov		eax,TRUE
	.endif
	ret

CreateSel:
	mov		id,0
	.while ecx
		push	ecx
		invoke CreateWindowEx,0,addr CadSelClass,0,WS_VISIBLE or WS_CHILD or WS_CLIPSIBLINGS,0,0,0,0,hWin,id,hInstance,0
		mov		hSel,eax
		invoke SetWindowLong,hSel,0,[esi].OBJECT.hsel
		mov		eax,esi
		sub		eax,ebx
		sub		eax,sizeof CADMEM
		invoke SetWindowLong,hSel,GWL_USERDATA,eax
		inc		id
		mov		eax,hSel
		mov		[esi].OBJECT.hsel,eax
		pop		ecx
		dec		ecx
	.endw
	retn

CadSelect endp

CadSelectAll proc uses ebx esi,hWin:HWND,fSel:DWORD
	LOCAL	nSel:DWORD

	mov		nSel,0
	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	lea		esi,[ebx+sizeof CADMEM]
	.while [esi].OBJECT.tpe
		.if sbyte ptr [esi].OBJECT.tpe>0
			invoke CadSelect,hWin,esi,fSel
			add		nSel,eax
		.endif
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw
	.if nSel
		invoke CadNotify,hWin,CN_SELCHANGE,0
	.endif
	mov		eax,nSel
	ret

CadSelectAll endp

CadSelectObject proc uses ebx esi edi,hWin:HWND,fCtrl:DWORD
	LOCAL	hDC:HDC
	LOCAL	hBmp:DWORD
	LOCAL	rect:RECT
	LOCAL	pt1:POINT
	LOCAL	bm:BITMAP
	LOCAL	nbits:DWORD
	LOCAL	nSel:DWORD
	LOCAL	xofs:DWORD
	LOCAL	yofs:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		nSel,0
	invoke GetCursorPos,addr pt1
	invoke ScreenToClient,hWin,addr pt1
	mov		eax,pt1.x
	add		eax,[ebx].CADMEM.scroll.x
	sub		eax,2
	mov		xofs,eax
	mov		eax,pt1.y
	add		eax,[ebx].CADMEM.scroll.y
	sub		eax,2
	mov		yofs,eax
	invoke CreateCompatibleDC,NULL
	mov		hDC,eax
	invoke CreateCompatibleBitmap,hDC,5,5
	mov		hBmp,eax
	invoke SelectObject,hDC,eax
	push	eax
	mov		rect.left,0
	mov		rect.top,0
	mov		rect.right,5
	mov		rect.bottom,5
	;Get info on bitmap
	invoke GetObject,hBmp,sizeof BITMAP,addr bm
	mov		eax,bm.bmWidthBytes
	mov		edx,bm.bmHeight
	mul		edx
	mov		nbits,eax
	;Allocate memory for destination bitmap bits
	invoke GlobalAlloc,GMEM_ZEROINIT or GMEM_FIXED,nbits
	mov		edi,eax
	lea		esi,[ebx+sizeof CADMEM]
	.while byte ptr [esi].OBJECT.tpe
		mov		eax,[ebx].CADMEM.layer
		.if sbyte ptr [esi].OBJECT.tpe>0 && al==[esi].OBJECT.layer
			invoke GetStockObject,BLACK_BRUSH
			invoke FillRect,hDC,addr rect,eax
			invoke CadDrawObject,hDC,xofs,yofs,ebx,esi,FALSE,TRUE
			;Get the destination bitmap bits
			invoke GetBitmapBits,hBmp,nbits,edi
			movzx	eax,byte ptr [edi]
			or		al,[edi+2]
			or		al,[edi+4]
			or		al,[edi+6]
			or		al,[edi+8]
			shr		eax,3
			.if eax
				.if [esi].OBJECT.hsel
					invoke CadSelect,hWin,esi,FALSE
				.else
					invoke CadSelect,hWin,esi,TRUE
				.endif
				add		nSel,eax
			.elseif [esi].OBJECT.hsel && !fCtrl
				invoke CadSelect,hWin,esi,FALSE
				add		nSel,eax
			.endif
		.endif
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw
	invoke GlobalFree,edi
	pop		eax
	invoke SelectObject,hDC,eax
	invoke DeleteObject,eax
	invoke DeleteDC,hDC
	.if nSel
		invoke CadNotify,hWin,CN_SELCHANGE,0
	.endif
	ret

CadSelectObject endp

CadSelectRect proc uses ebx esi edi,hWin:HWND,fCtrl:DWORD,lpRect:DWORD
	LOCAL	hDC:HDC
	LOCAL	hBmp:DWORD
	LOCAL	rect:RECT
	LOCAL	bm:BITMAP
	LOCAL	nbits:DWORD
	LOCAL	nSel:DWORD
	LOCAL	xofs:DWORD
	LOCAL	yofs:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		nSel,0
	mov		esi,lpRect
	mov		eax,[esi].RECT.left
	mov		edx,[esi].RECT.right
	.if sdword ptr eax>edx
		mov		[esi].RECT.right,eax
		mov		[esi].RECT.left,edx
	.endif
	mov		eax,[esi].RECT.top
	mov		edx,[esi].RECT.bottom
	.if sdword ptr eax>edx
		mov		[esi].RECT.bottom,eax
		mov		[esi].RECT.top,edx
	.endif
	mov		eax,[esi].RECT.left
	add		eax,[ebx].CADMEM.scroll.x
	mov		xofs,eax
	mov		eax,[esi].RECT.top
	add		eax,[ebx].CADMEM.scroll.y
	mov		yofs,eax
	invoke CreateCompatibleDC,NULL
	mov		hDC,eax
	mov		eax,[esi].RECT.right
	sub		eax,[esi].RECT.left
	mov		edx,[esi].RECT.bottom
	sub		edx,[esi].RECT.top
	mov		rect.left,0
	mov		rect.top,0
	mov		rect.right,eax
	mov		rect.bottom,edx
	invoke CreateCompatibleBitmap,hDC,eax,edx
	mov		hBmp,eax
	invoke SelectObject,hDC,eax
	push	eax
	;Get info on bitmap
	invoke GetObject,hBmp,sizeof BITMAP,addr bm
	mov		eax,bm.bmWidthBytes
	mov		edx,bm.bmHeight
	mul		edx
	mov		nbits,eax
	;Allocate memory for destination bitmap bits
	invoke GlobalAlloc,GMEM_ZEROINIT or GMEM_FIXED,nbits
	mov		edi,eax
	lea		esi,[ebx+sizeof CADMEM]
	.while byte ptr [esi].OBJECT.tpe
		.if sbyte ptr [esi].OBJECT.tpe>0
			invoke GetStockObject,BLACK_BRUSH
			invoke FillRect,hDC,addr rect,eax
			invoke CadDrawObject,hDC,xofs,yofs,ebx,esi,FALSE,TRUE
			;Get the destination bitmap bits
			invoke GetBitmapBits,hBmp,nbits,edi
			push	edi
			xor		edx,edx
			xor		eax,eax
			.while edx<bm.bmHeight
				xor		ecx,ecx
				.while ecx<bm.bmWidthBytes
					or		al,[edi]
					inc		ecx
					inc		edi
				.endw
				.break .if eax
				inc		edx
			.endw
			pop		edi
			.if eax
				invoke CadSelect,hWin,esi,TRUE
				inc		nSel
			.elseif [esi].OBJECT.hsel && !fCtrl
				invoke CadSelect,hWin,esi,FALSE
				inc		nSel
			.endif
		.endif
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw
	invoke GlobalFree,edi
	pop		eax
	invoke SelectObject,hDC,eax
	invoke DeleteObject,eax
	invoke DeleteDC,hDC
	.if nSel
		invoke CadNotify,hWin,CN_SELCHANGE,0
	.endif
	ret

CadSelectRect endp

CadSetCursorPos proc uses ebx,hWin:HWND

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	invoke GetCursorPos,addr curpos
	invoke ScreenToClient,hWin,addr curpos
	invoke CadSnap,hWin,addr curpos
	ret

CadSetCursorPos endp

CadUndo proc uses ebx esi,hWin:HWND

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,[ebx].CADMEM.hUndo
	add		eax,[ebx].CADMEM.rpUndo
	mov		eax,[eax]
	.if eax
		lea		esi,[ebx+eax]
		.if [esi].OBJECT.hsel
			invoke CadDestroySel,hWin,esi
		.endif
		sub		[ebx].CADMEM.rpUndo,sizeof UNDO
		invoke CadInvalidateObject,hWin,esi
		neg		[esi].OBJECT.tpe
		invoke CadInvalidateObject,hWin,esi
		mov		[ebx].CADMEM.changed,TRUE
		invoke CadNotify,hWin,CN_CHANGE,0
	.endif
	ret

CadUndo endp

CadRedo proc uses ebx esi,hWin:HWND

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,[ebx].CADMEM.hUndo
	add		eax,[ebx].CADMEM.rpUndo
	add		eax,sizeof UNDO
	mov		eax,[eax]
	.if eax
		lea		esi,[ebx+eax]
		.if [esi].OBJECT.hsel
			invoke CadDestroySel,hWin,esi
		.endif
		add		[ebx].CADMEM.rpUndo,sizeof UNDO
		invoke CadInvalidateObject,hWin,esi
		neg		[esi].OBJECT.tpe
		invoke CadInvalidateObject,hWin,esi
		mov		[ebx].CADMEM.changed,TRUE
		invoke CadNotify,hWin,CN_CHANGE,0
	.endif
	ret

CadRedo endp

CadGetSelCount proc uses ebx esi,hWin:HWND

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	lea		esi,[ebx+sizeof CADMEM]
	xor		ecx,ecx
	.while [esi].OBJECT.tpe
		.if [esi].OBJECT.hsel
			inc		ecx
		.endif
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw
	mov		eax,ecx
	ret

CadGetSelCount endp

CadDelete proc uses ebx esi,hWin:HWND
	LOCAL	nchange:DWORD

	mov		nchange,0
	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	lea		esi,[ebx+sizeof CADMEM]
	.while [esi].OBJECT.tpe
		.if [esi].OBJECT.hsel
			invoke CadDestroySel,hWin,esi
			mov		edx,[ebx].CADMEM.hUndo
			add		edx,[ebx].CADMEM.rpUndo
			add		edx,sizeof UNDO
			add		[ebx].CADMEM.rpUndo,sizeof UNDO
			mov		eax,esi
			sub		eax,ebx
			mov		[edx].UNDO.rpObject,eax
			mov		[edx+sizeof UNDO].UNDO.rpObject,0
			invoke CadInvalidateObject,hWin,esi
			neg		[esi].OBJECT.tpe
			invoke CadInvalidateObject,hWin,esi
			mov		[ebx].CADMEM.changed,TRUE
			inc		nchange
		.endif
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw
	.if nchange
		invoke CadNotify,hWin,CN_CHANGE,0
	.endif
	mov		eax,nchange
	ret

CadDelete endp

CadCopy proc uses ebx esi edi,hWin:HWND
	LOCAL	cbSize:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	lea		esi,[ebx+sizeof CADMEM]
	xor		ecx,ecx
	.while [esi].OBJECT.tpe
		.if [esi].OBJECT.hsel
			add		ecx,[esi].OBJECT.cbsize
		.endif
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw
	.if ecx
		add		ecx,sizeof OBJECT
		push	ecx
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,ecx
		mov		edi,eax
		push	edi
		lea		esi,[ebx+sizeof CADMEM]
		.while [esi].OBJECT.tpe
			.if [esi].OBJECT.hsel
				mov		ecx,[esi].OBJECT.cbsize
				rep movsb
			.else
				mov		eax,[esi].OBJECT.cbsize
				lea		esi,[esi+eax]
			.endif
		.endw
		pop		edi
		pop		ecx
		invoke CadSetClipData,edi,ecx
		invoke GlobalFree,edi
	.endif
	ret

CadCopy endp

CadAddObjects proc uses ebx esi edi,hWin:HWND,lpObjects:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,[ebx].CADMEM.rpFree
	lea		eax,[eax+sizeof CADMEM]
	add		[ebx].CADMEM.rpUndo,sizeof UNDO
	mov		edx,[ebx].CADMEM.hUndo
	add		edx,[ebx].CADMEM.rpUndo
	mov		[edx].UNDO.rpObject,eax
	mov		[edx+sizeof UNDO].UNDO.rpObject,0
	mov		esi,lpObjects
	.while [esi].OBJECT.tpe
		call	CopyObject
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw


	ret

CopyObject:
	mov		eax,[ebx].CADMEM.rpFree
	lea		edi,[ebx+eax+sizeof CADMEM]
	push	esi
	push	edi
	mov		ecx,[esi].OBJECT.cbsize
	add		[ebx].CADMEM.rpFree,ecx
	rep movsb
	pop		edi
	pop		esi
	mov		eax,[ebx].CADMEM.layer
	mov		[edi].OBJECT.layer,al
	mov		[edi].OBJECT.hsel,0
	invoke CadSelect,hWin,edi,TRUE
	invoke CadInvalidateObject,hWin,edi
	retn

CadAddObjects endp

CadPaste proc uses ebx esi edi,hWin:HWND
	LOCAL	xmin:DWORD
	LOCAL	ymin:DWORD
	LOCAL	pt:POINT

	invoke CadSelectAll,hWin,FALSE
	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	invoke OpenClipboard,hWin
	.if eax
		invoke GetClipboardData,hClip
		.if eax
			push	eax
			invoke GlobalLock,eax
			mov		esi,eax
			invoke CadAddObjects,hWin,esi
			pop		eax
			invoke GlobalUnlock,eax
		.endif
		invoke CloseClipboard
	.endif
	ret

CadPaste endp

CadSetInitialPos proc uses ebx,hWin:HWND

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,curpos.x
	add		eax,[ebx].CADMEM.scroll.x
	call	ZoomDiv
	mov		lastpos.x,eax
	mov		eax,curpos.y
	add		eax,[ebx].CADMEM.scroll.y
	call	ZoomDiv
	mov		lastpos.y,eax
	ret

CadSetInitialPos endp

CadAdjustObject proc uses ebx esi edi,hWin:HWND,rpObject:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		esi,rpObject
	lea		esi,[esi+ebx+sizeof CADMEM]
	invoke CadInvalidateObject,hWin,esi
	mov		eax,[esi].OBJECT.npt
	lea		edi,[esi+eax*8-8].OBJECT.rc
	mov		eax,curpos.x
	add		eax,[ebx].CADMEM.scroll.x
	call	ZoomDiv
	mov		[edi].POINT.x,eax
	mov		lastpos.x,eax
	mov		eax,curpos.y
	add		eax,[ebx].CADMEM.scroll.y
	call	ZoomDiv
	mov		[edi].POINT.y,eax
	mov		lastpos.y,eax
	invoke CadInvalidateObject,hWin,esi
	mov		[ebx].CADMEM.changed,TRUE
	mov		eax,esi
	sub		eax,ebx
	sub		eax,sizeof CADMEM
	invoke CadNotify,hWin,CN_SIZE,eax
	ret

CadAdjustObject endp

CadAddObject proc uses ebx esi,hWin:HWND,nObject:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,[ebx].CADMEM.rpFree
	lea		esi,[ebx+eax+sizeof CADMEM]
	mov		eax,ncadbox
	.if eax==TPE_LINE
		call	AddLine
	.elseif eax==TPE_RECT
		call	AddRect
	.elseif eax==TPE_CIRCLE
		call	AddCircle
	.elseif eax==TPE_POLYLINE
		call	AddPolyLine
	.elseif eax==TPE_HTEXT
		call	AddHText
	.elseif eax==TPE_VTEXT
		call	AddVText
	.elseif eax==TPE_DIMENSION
		call	AddDimension
	.else
		mov		esi,ebx
	.endif
	mov		eax,esi
	sub		eax,ebx
	mov		rpsize,eax
	.if eax
		invoke CadInvalidateObject,hWin,esi
		mov		[ebx].CADMEM.changed,TRUE
		invoke CadNotify,hWin,CN_CHANGE,0
	.endif
	ret

AddDefObj:
	mov		[esi].OBJECT.cbsize,sizeof OBJECT
	mov		eax,[ebx].CADMEM.layer
	mov		[esi].OBJECT.layer,al
	mov		al,[ebx].CADMEM.wdt
	mov		[esi].OBJECT.wdt,al
	mov		eax,[ebx].CADMEM.color
	mov		[esi].OBJECT.color,eax
	mov		eax,lastpos.x
	mov		[esi].OBJECT.rc.left,eax
	mov		[esi].OBJECT.rc.right,eax
	mov		eax,lastpos.y
	mov		[esi].OBJECT.rc.top,eax
	mov		[esi].OBJECT.rc.bottom,eax
	mov		[esi].OBJECT.npt,2
	mov		[esi+sizeof OBJECT].OBJECT.tpe,0
	mov		eax,esi
	sub		eax,ebx
	add		[ebx].CADMEM.rpUndo,sizeof UNDO
	mov		edx,[ebx].CADMEM.hUndo
	add		edx,[ebx].CADMEM.rpUndo
	mov		[edx].UNDO.rpObject,eax
	mov		[edx+sizeof UNDO].UNDO.rpObject,0
	sub		eax,sizeof CADMEM
	add		eax,sizeof OBJECT
	mov		[ebx].CADMEM.rpFree,eax
	retn

AddLine:
	call	AddDefObj
	mov		[esi].OBJECT.tpe,TPE_LINE
	retn

AddRect:
	call	AddDefObj
	mov		[esi].OBJECT.tpe,TPE_RECT
	retn

AddCircle:
	call	AddDefObj
	mov		[esi].OBJECT.tpe,TPE_CIRCLE
	retn

AddPolyLine:
	call	AddDefObj
	mov		[esi].OBJECT.tpe,TPE_POLYLINE
	retn

AddHText:
	mov		[esi].OBJECT.tpe,TPE_HTEXT
	mov		eax,[ebx].CADMEM.layer
	mov		[esi].OBJECT.layer,al
	mov		al,[ebx].CADMEM.wdt
	mov		[esi].OBJECT.wdt,al
	mov		eax,[ebx].CADMEM.color
	mov		[esi].OBJECT.color,eax
	mov		eax,lastpos.x
	mov		[esi].OBJECT.rc.left,eax
	mov		eax,lastpos.y
	mov		[esi].OBJECT.rc.top,eax
	mov		[esi].OBJECT.npt,2
	invoke lstrcpy,addr [esi+sizeof OBJECT],addr szText
	invoke lstrlen,addr szText
	push	eax
	lea		ecx,[eax+1+sizeof OBJECT]
	mov		[esi].OBJECT.cbsize,ecx
	mov		[esi+ecx].OBJECT.tpe,0
	mov		eax,esi
	sub		eax,ebx
	add		[ebx].CADMEM.rpUndo,sizeof UNDO
	mov		edx,[ebx].CADMEM.hUndo
	add		edx,[ebx].CADMEM.rpUndo
	mov		[edx].UNDO.rpObject,eax
	mov		[edx+sizeof UNDO].UNDO.rpObject,0
	sub		eax,sizeof CADMEM
	add		eax,ecx
	mov		[ebx].CADMEM.rpFree,eax
	pop		eax
	mov		ecx,CHARWIDTH
	mul		ecx
	add		eax,[esi].OBJECT.rc.left
	mov		[esi].OBJECT.rc.right,eax
	mov		eax,CHARHEIGHT
	add		eax,[esi].OBJECT.rc.top
	mov		[esi].OBJECT.rc.bottom,eax
	retn

AddVText:
	mov		[esi].OBJECT.tpe,TPE_VTEXT
	mov		eax,[ebx].CADMEM.layer
	mov		[esi].OBJECT.layer,al
	mov		al,[ebx].CADMEM.wdt
	mov		[esi].OBJECT.wdt,al
	mov		eax,[ebx].CADMEM.color
	mov		[esi].OBJECT.color,eax
	mov		eax,lastpos.x
	mov		[esi].OBJECT.rc.left,eax
	mov		eax,lastpos.y
	mov		[esi].OBJECT.rc.top,eax
	mov		[esi].OBJECT.npt,2
	invoke lstrcpy,addr [esi+sizeof OBJECT],addr szText
	invoke lstrlen,addr szText
	push	eax
	lea		ecx,[eax+1+sizeof OBJECT]
	mov		[esi].OBJECT.cbsize,ecx
	mov		[esi+ecx].OBJECT.tpe,0
	mov		eax,esi
	sub		eax,ebx
	add		[ebx].CADMEM.rpUndo,sizeof UNDO
	mov		edx,[ebx].CADMEM.hUndo
	add		edx,[ebx].CADMEM.rpUndo
	mov		[edx].UNDO.rpObject,eax
	mov		[edx+sizeof UNDO].UNDO.rpObject,0
	sub		eax,sizeof CADMEM
	add		eax,ecx
	mov		[ebx].CADMEM.rpFree,eax
	pop		eax
	mov		ecx,CHARWIDTH
	mul		ecx
	add		eax,[esi].OBJECT.rc.top
	mov		[esi].OBJECT.rc.bottom,eax
	mov		eax,CHARHEIGHT
	add		eax,[esi].OBJECT.rc.left
	mov		[esi].OBJECT.rc.right,eax
	retn

AddDimension:
	call	AddDefObj
	mov		[esi].OBJECT.tpe,TPE_DIMENSION
	retn

CadAddObject endp

CadClear proc uses ebx,hWin:HWND

	invoke GetWindowLong,hWin,0
	.if eax
		mov		ebx,eax
		invoke GlobalUnlock,[ebx].CADMEM.hUndo
		invoke GlobalFree,[ebx].CADMEM.hUndo
		invoke GlobalUnlock,ebx
		invoke GlobalFree,ebx
	.endif
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,8*64*1024
	invoke GlobalLock,eax
	mov		ebx,eax
	invoke SetWindowLong,hWin,0,ebx
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	invoke GlobalLock,eax
	mov		[ebx].CADMEM.hUndo,eax
	invoke GetParent,hWin
	mov		[ebx].CADMEM.hpar,eax
	invoke GetWindowLong,hWin,GWL_ID
	mov		[ebx].CADMEM.id,eax

	mov		[ebx].CADMEM.ver,CADVER
	mov		[ebx].CADMEM.grid,TRUE
	mov		[ebx].CADMEM.snap,TRUE
	mov		[ebx].CADMEM.wdt,1
	mov		[ebx].CADMEM.color,0h
	mov		[ebx].CADMEM.zoom,ZOOM_INIT
	mov		[ebx].CADMEM.backcolor,0FFFFFFh
	invoke InvalidateRect,hWin,NULL,TRUE
	mov		eax,ebx
	ret

CadClear endp

CadStreamIn proc uses ebx esi edi,hMem:DWORD,lParam:DWORD
	LOCAL	dwRead:DWORD
	LOCAL	hCMem:DWORD

	mov		ebx,hMem
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MAXSTREAM
	mov     hCMem,eax
	lea		edi,[ebx].CADMEM.ver
  @@:
	mov		esi,lParam
	mov		[esi].EDITSTREAM.dwError,0
	lea		eax,dwRead
	push	eax
	mov		eax,MAXSTREAM
	push	eax
	push	hCMem
	mov		eax,[esi].EDITSTREAM.dwCookie
	push	eax
	call	[esi].EDITSTREAM.pfnCallback
	or		eax,eax
	jne		@f
	mov		esi,hCMem
	mov		ecx,dwRead
	.if ecx
		rep movsb
	.endif
	mov		eax,dwRead
	or		eax,eax
	jne		@b
  @@:
	invoke GlobalFree,hCMem
	lea		edi,[ebx+sizeof CADMEM]
	xor		edx,edx
	.while [edi].OBJECT.tpe
		mov		eax,[edi].OBJECT.cbsize
		add		edx,eax
		lea		edi,[edi+eax]
	.endw
	mov		[ebx].CADMEM.rpFree,edx
	ret

CadStreamIn endp

CadStreamOut proc uses ebx esi edi,hMem:DWORD,lParam:DWORD
	LOCAL	dwWrite:DWORD
	LOCAL	hCMem:DWORD

	mov		ebx,hMem
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MAXSTREAM
	mov     hCMem,eax
	mov		edi,eax
	lea		esi,[ebx].CADMEM.ver
	mov		ecx,sizeof CADMEM-CADMEM.ver
	rep movsb
	mov		ecx,sizeof CADMEM-CADMEM.ver
	lea		esi,[ebx+sizeof CADMEM]
  @@:
	call	FillCMem
	or		ecx,ecx
	je		@f
	mov		edx,lParam
	mov		[edx].EDITSTREAM.dwError,0
	lea		eax,dwWrite
	push	eax
	push	ecx
	push	hCMem
	mov		eax,[edx].EDITSTREAM.dwCookie
	push	eax
	call	[edx].EDITSTREAM.pfnCallback
	xor		ecx,ecx
	mov		edi,hCMem
	or		eax,eax
	je		@b
  @@:
	invoke GlobalFree,hCMem
	ret

FillCMem:
	.if [esi].OBJECT.tpe
		.if sbyte ptr [esi].OBJECT.tpe>0
			mov		edx,[esi].OBJECT.cbsize
			lea		eax,[ecx+edx]
			.if eax<=MAXSTREAM
				push	edi
				push	ecx
				mov		ecx,edx
				rep movsb
				pop		ecx
				add		ecx,edx
				pop		edx
				mov		[edx].OBJECT.hsel,0
				jmp		FillCMem
			.endif
		.else
			mov		eax,[esi].OBJECT.cbsize
			lea		esi,[esi+eax]
			jmp		FillCMem
		.endif
	.endif
	retn

CadStreamOut endp

CadZoomBestFit proc uses ebx esi,hWin:HWND,lpRectIn:DWORD,lpRectOut:DWORD,fGrid:DWORD,fZoom:DWORD
	LOCAL	cObj:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		edi,lpRectOut
	mov		[edi].RECT.left,7FFFFFFFh
	mov		[edi].RECT.top,7FFFFFFFh
	mov		[edi].RECT.right,0
	mov		[edi].RECT.bottom,0
	mov		cObj,0
	lea		esi,[ebx+sizeof CADMEM]
	.while [esi].OBJECT.tpe
		.if sbyte ptr [esi].OBJECT.tpe>0
			inc		cObj
			.if [esi].OBJECT.tpe==TPE_HTEXT
				mov		eax,[esi].OBJECT.rc.left
				.if sdword ptr eax<[edi].RECT.left
					mov		[edi].RECT.left,eax
				.endif
				.if sdword ptr eax>[edi].RECT.right
					mov		[edi].RECT.right,eax
				.endif
				mov		eax,[esi].OBJECT.rc.top
				.if sdword ptr eax<[edi].RECT.top
					mov		[edi].RECT.top,eax
				.endif
				.if sdword ptr eax>[edi].RECT.bottom
					mov		[edi].RECT.bottom,eax
				.endif
				mov		eax,[esi].OBJECT.rc.right
				sub		eax,[esi].OBJECT.rc.left
				movzx	ecx,[esi].OBJECT.wdt
				mul		ecx
				shr		eax,1
				add		eax,[esi].OBJECT.rc.left
				.if sdword ptr eax<[edi].RECT.left
					mov		[edi].RECT.left,eax
				.endif
				.if sdword ptr eax>[edi].RECT.right
					mov		[edi].RECT.right,eax
				.endif
				mov		eax,[esi].OBJECT.rc.bottom
				sub		eax,[esi].OBJECT.rc.top
				movzx	ecx,[esi].OBJECT.wdt
				mul		ecx
				shr		eax,1
				add		eax,[esi].OBJECT.rc.top
				.if sdword ptr eax<[edi].RECT.top
					mov		[edi].RECT.top,eax
				.endif
				.if sdword ptr eax>[edi].RECT.bottom
					mov		[edi].RECT.bottom,eax
				.endif
			.elseif [esi].OBJECT.tpe==TPE_VTEXT
				mov		eax,[esi].OBJECT.rc.left
				.if sdword ptr eax<[edi].RECT.left
					mov		[edi].RECT.left,eax
				.endif
				.if sdword ptr eax>[edi].RECT.right
					mov		[edi].RECT.right,eax
				.endif
				mov		eax,[esi].OBJECT.rc.top
				.if sdword ptr eax<[edi].RECT.top
					mov		[edi].RECT.top,eax
				.endif
				.if sdword ptr eax>[edi].RECT.bottom
					mov		[edi].RECT.bottom,eax
				.endif
				mov		eax,[esi].OBJECT.rc.right
				sub		eax,[esi].OBJECT.rc.left
				movzx	ecx,[esi].OBJECT.wdt
				mul		ecx
				shr		eax,1
				add		eax,[esi].OBJECT.rc.left
				.if sdword ptr eax<[edi].RECT.left
					mov		[edi].RECT.left,eax
				.endif
				.if sdword ptr eax>[edi].RECT.right
					mov		[edi].RECT.right,eax
				.endif
				mov		eax,[esi].OBJECT.rc.bottom
				sub		eax,[esi].OBJECT.rc.top
				movzx	ecx,[esi].OBJECT.wdt
				mul		ecx
				shr		eax,1
				add		eax,[esi].OBJECT.rc.top
				.if sdword ptr eax<[edi].RECT.top
					mov		[edi].RECT.top,eax
				.endif
				.if sdword ptr eax>[edi].RECT.bottom
					mov		[edi].RECT.bottom,eax
				.endif
			.else
				mov		ecx,[esi].OBJECT.npt
				.while ecx
					dec		ecx
					mov		eax,[esi].OBJECT.rc.left[ecx*8]
					.if sdword ptr eax<[edi].RECT.left
						mov		[edi].RECT.left,eax
					.endif
					.if sdword ptr eax>[edi].RECT.right
						mov		[edi].RECT.right,eax
					.endif
					mov		eax,[esi].OBJECT.rc.top[ecx*8]
					.if sdword ptr eax<[edi].RECT.top
						mov		[edi].RECT.top,eax
					.endif
					.if sdword ptr eax>[edi].RECT.bottom
						mov		[edi].RECT.bottom,eax
					.endif
				.endw
			.endif
		.endif
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw
	.if cObj
		inc		[edi].RECT.right
		inc		[edi].RECT.bottom
		mov		esi,lpRectIn
		mov		eax,[esi].RECT.right
		sub		eax,[esi].RECT.left
		mov		ecx,ZOOM_NORM
		mul		ecx
		mov		ecx,[edi].RECT.right
		sub		ecx,[edi].RECT.left
		xor		edx,edx
		div		ecx
		.if fZoom
			.if eax<ZOOM_MIN
				mov		eax,ZOOM_MIN
			.elseif eax>ZOOM_MAX
				mov		eax,ZOOM_MAX
			.endif
		.endif
		mov		[ebx].CADMEM.zoom,eax
		mov		eax,[esi].RECT.bottom
		sub		eax,[esi].RECT.top
		mov		ecx,ZOOM_NORM
		mul		ecx
		mov		ecx,[edi].RECT.bottom
		sub		ecx,[edi].RECT.top
		xor		edx,edx
		div		ecx
		.if fZoom
			.if eax<ZOOM_MIN
				mov		eax,ZOOM_MIN
			.elseif eax>ZOOM_MAX
				mov		eax,ZOOM_MAX
			.endif
		.endif
		.if eax<[ebx].CADMEM.zoom
			mov		[ebx].CADMEM.zoom,eax
		.endif
		.if fGrid
			call	TestGrid
		.endif
	.endif
	ret

TestGrid:
	mov		eax,SNAP_SIZE
	call	ZoomMul
	call	ZoomDiv
	.if eax!=SNAP_SIZE
		dec		[ebx].CADMEM.zoom
		jmp		TestGrid
	.endif
	retn

CadZoomBestFit endp

ConvToPix proc lLPix:DWORD,lSize:DWORD
	LOCAL	buffer[256]:BYTE

	invoke GetUserDefaultLCID
	mov		edx,eax
	invoke GetLocaleInfo,edx,LOCALE_IMEASURE,addr buffer,sizeof buffer
	mov		al,buffer
	.if al=='1'
		mov		edx,1
	.else
		mov		edx,0
	.endif
	mov		eax,lLPix
	.if !edx
		mov		ecx,1000
		mul		ecx
		xor		edx,edx
		mov		ecx,254
		div		ecx
	.else
		mov		ecx,10
		mul		ecx
	.endif
	mov		ecx,eax		;Pix pr. 100mm / 10"
	mov		eax,lSize
	mul		ecx
	xor		edx,edx
	mov		ecx,10000
	div		ecx
	ret

ConvToPix endp

CadPrint proc uses ebx esi edi,hWin:HWND,lppd:DWORD,lppsd:DWORD
	LOCAL	doci:DOCINFO
	LOCAL	buffer[32]:BYTE
	LOCAL	cadmem:CADMEM
	LOCAL	rect:RECT
	LOCAL	rectout:RECT

	LOCAL	pX:DWORD
	LOCAL	pY:DWORD
	LOCAL	pML:DWORD
	LOCAL	pMT:DWORD
	LOCAL	pMR:DWORD
	LOCAL	pMB:DWORD

	mov		esi,lppd
	mov		edi,lppsd
	invoke GetDeviceCaps,[esi].PRINTDLG.hDC,LOGPIXELSX
	mov		ebx,eax
	invoke ConvToPix,ebx,[edi].PAGESETUPDLG.ptPaperSize.x
	mov		pX,eax
	invoke ConvToPix,ebx,[edi].PAGESETUPDLG.rtMargin.left
	mov		pML,eax
	invoke ConvToPix,ebx,[edi].PAGESETUPDLG.rtMargin.right
	mov		pMR,eax
	invoke GetDeviceCaps,[esi].PRINTDLG.hDC,LOGPIXELSY
	mov		ebx,eax
	invoke ConvToPix,ebx,[edi].PAGESETUPDLG.ptPaperSize.y
	mov		pY,eax
	invoke ConvToPix,ebx,[edi].PAGESETUPDLG.rtMargin.top
	mov		pMT,eax
	invoke ConvToPix,ebx,[edi].PAGESETUPDLG.rtMargin.bottom
	mov		pMB,eax

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		esi,ebx
	lea		edi,cadmem
	mov		ecx,sizeof CADMEM
	rep movsb
	mov		[ebx].CADMEM.grid,FALSE
	mov		eax,pML
	mov		rect.left,eax
	mov		eax,pMT
	mov		rect.top,eax
	mov		eax,pX
	sub		eax,pMR
	mov		rect.right,eax
	mov		eax,pY
	sub		eax,pMB
	mov		rect.bottom,eax
	invoke CadZoomBestFit,hWin,addr rect,addr rectout,FALSE,FALSE
	mov		esi,lppd
	mov		doci.cbSize,sizeof doci
	mov		doci.lpszDocName,NULL;offset AppName
	mov		eax,[esi].PRINTDLG.Flags
	and		eax,PD_PRINTTOFILE
	.if eax
		mov		eax,'ELIF'
		mov		dword ptr buffer,eax
		mov		eax,':'
		mov		dword ptr buffer+4,eax
		lea		eax,buffer
		mov		doci.lpszOutput,eax
	.else
		mov		doci.lpszOutput,NULL
	.endif
	mov		doci.lpszDatatype,NULL
	mov		doci.fwType,NULL
	invoke StartDoc,[esi].PRINTDLG.hDC,addr doci
	invoke StartPage,[esi].PRINTDLG.hDC
	mov		eax,rectout.left
	invoke ZoomMul
	sub		pML,eax
	mov		eax,rectout.top
	invoke ZoomMul
	sub		pMT,eax
	mov		eax,pY
	.if eax>pX
		xor		eax,eax
	.endif
	mov		ecx,pML
	neg		ecx
	mov		edx,pMT
	neg		edx
	invoke CadDraw,hWin,[esi].PRINTDLG.hDC,ecx,edx,pX,pY,TRUE,eax
	invoke EndPage,[esi].PRINTDLG.hDC
	invoke EndDoc,[esi].PRINTDLG.hDC
	invoke DeleteDC,[esi].PRINTDLG.hDC
	invoke GetWindowLong,hWin,0
	mov		edi,ebx
	lea		esi,cadmem
	mov		ecx,sizeof CADMEM
	rep movsb
	ret

CadPrint endp

CadSelSetColor proc uses ebx esi,hWin:HWND,nColor:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	lea		esi,[ebx+sizeof CADMEM]
	.while [esi].OBJECT.tpe
		.if [esi].OBJECT.hsel
			.if [esi].OBJECT.tpe==TPE_SYMBOL
				push	esi
				mov		ecx,[esi].OBJECT.npt
				lea		esi,[esi+sizeof OBJECT]
				.while ecx
					mov		eax,nColor
					mov		[esi].OBJECT.color,eax
					mov		eax,[esi].OBJECT.cbsize
					lea		esi,[esi+eax]
					dec		ecx
				.endw
				pop		esi
			.endif
			mov		eax,nColor
			mov		[esi].OBJECT.color,eax
			invoke CadInvalidateObject,hWin,esi
			mov		[ebx].CADMEM.changed,TRUE
		.endif
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw
	ret

CadSelSetColor endp

CadSelSetWidth proc uses ebx esi,hWin:HWND,nWidth:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	lea		esi,[ebx+sizeof CADMEM]
	.while [esi].OBJECT.tpe
		.if [esi].OBJECT.hsel
			invoke CadInvalidateObject,hWin,esi
			mov		eax,nWidth
			mov		[esi].OBJECT.wdt,al
			invoke CadInvalidateObject,hWin,esi
			mov		[ebx].CADMEM.changed,TRUE
		.endif
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw
	ret

CadSelSetWidth endp

CadFlip proc uses ebx esi edi,hWin:HWND
	LOCAL	left:DWORD
	LOCAL	right:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		left,7FFFFFFFh
	mov		right,0
	lea		esi,[ebx+sizeof CADMEM]
	.while [esi].OBJECT.tpe
		.if [esi].OBJECT.hsel
			call	GetRect
		.endif
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw
	lea		esi,[ebx+sizeof CADMEM]
	.while [esi].OBJECT.tpe
		.if [esi].OBJECT.hsel
			invoke CadInvalidateObject,hWin,esi
			call	Flip
			invoke CadInvalidateObject,hWin,esi
			mov		[ebx].CADMEM.changed,TRUE
		.endif
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw
	ret

GetRect:
	push	ecx
	push	esi
	movzx	eax,[esi].OBJECT.tpe
	.if eax==TPE_LINE || eax==TPE_RECT || eax==TPE_CIRCLE || eax==TPE_DIMENSION
		mov		eax,[esi].OBJECT.rc.left
		.if sdword ptr eax<left
			mov		left,eax
		.endif
		.if sdword ptr eax>right
			mov		right,eax
		.endif
		mov		eax,[esi].OBJECT.rc.right
		.if sdword ptr eax<left
			mov		left,eax
		.endif
		.if sdword ptr eax>right
			mov		right,eax
		.endif
	.elseif eax==TPE_POLYLINE
		mov		ecx,[esi].OBJECT.npt
		lea		esi,[esi].OBJECT.rc
		.while ecx
			mov		eax,[esi].POINT.x
			.if sdword ptr eax<left
				mov		left,eax
			.endif
			.if sdword ptr eax>right
				mov		right,eax
			.endif
			lea		esi,[esi+sizeof POINT]
			dec		ecx
		.endw
	.elseif  eax==TPE_HTEXT || eax==TPE_VTEXT
		mov		eax,[esi].OBJECT.rc.left
		.if sdword ptr eax<left
			mov		left,eax
		.endif
		.if sdword ptr eax>right
			mov		right,eax
		.endif
		mov		eax,[esi].OBJECT.rc.right
		.if sdword ptr eax<left
			mov		left,eax
		.endif
		.if sdword ptr eax>right
			mov		right,eax
		.endif
	.elseif eax==TPE_SYMBOL
		mov		ecx,[esi].OBJECT.npt
		lea		esi,[esi+sizeof OBJECT]
		.while ecx
			call	GetRect
			mov		eax,[esi].OBJECT.cbsize
			lea		esi,[esi+eax]
			dec		ecx
		.endw
	.endif
	pop		esi
	pop		ecx
	retn

Flip:
	push	ecx
	push	esi
	movzx	eax,[esi].OBJECT.tpe
	.if eax==TPE_LINE || eax==TPE_RECT || eax==TPE_CIRCLE || eax==TPE_DIMENSION
		mov		eax,left
		sub		eax,[esi].OBJECT.rc.left
		add		eax,right
		mov		edx,right
		sub		edx,[esi].OBJECT.rc.right
		add		edx,left
		mov		[esi].OBJECT.rc.left,eax
		mov		[esi].OBJECT.rc.right,edx
	.elseif eax==TPE_POLYLINE
		mov		ecx,[esi].OBJECT.npt
		lea		esi,[esi].OBJECT.rc
		.while ecx
			mov		eax,right
			sub		eax,[esi].POINT.x
			add		eax,left
			mov		[esi].POINT.x,eax
			lea		esi,[esi+sizeof POINT]
			dec		ecx
		.endw
	.elseif eax==TPE_HTEXT || eax==TPE_VTEXT
		mov		edx,[esi].OBJECT.rc.right
		sub		edx,[esi].OBJECT.rc.left
		mov		ecx,[esi].OBJECT.rc.left
		sub		ecx,left
		mov		eax,right
		sub		eax,ecx
		sub		eax,edx
		mov		[esi].OBJECT.rc.left,eax
		add		eax,edx
		mov		[esi].OBJECT.rc.right,eax
	.elseif eax==TPE_SYMBOL
		mov		edx,[esi].OBJECT.rc.right
		sub		edx,[esi].OBJECT.rc.left
		mov		ecx,[esi].OBJECT.rc.left
		sub		ecx,left
		mov		eax,right
		sub		eax,ecx
		sub		eax,edx
		mov		[esi].OBJECT.rc.left,eax
		add		eax,edx
		mov		[esi].OBJECT.rc.right,eax
		mov		ecx,[esi].OBJECT.npt
		lea		esi,[esi+sizeof OBJECT]
		.while ecx
			call	Flip
			mov		eax,[esi].OBJECT.cbsize
			lea		esi,[esi+eax]
			dec		ecx
		.endw
	.endif
	pop		esi
	pop		ecx
	retn

CadFlip endp

CadRotate proc uses ebx esi edi,hWin:HWND
	LOCAL	left:DWORD
	LOCAL	top:DWORD
	LOCAL	right:DWORD
	LOCAL	bottom:DWORD
	LOCAL	ofsleft:DWORD
	LOCAL	ofstop:DWORD

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		left,7FFFFFFFh
	mov		top,7FFFFFFFh
	mov		right,0
	mov		bottom,0
	lea		esi,[ebx+sizeof CADMEM]
	.while [esi].OBJECT.tpe
		.if [esi].OBJECT.hsel
			call	GetRect
		.endif
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw
	mov		eax,left
	mov		ofsleft,eax
	mov		eax,top
	mov		ofstop,eax
	mov		eax,right
	sub		eax,left
	mov		right,eax
	mov		left,0
	mov		eax,bottom
	sub		eax,top
	mov		bottom,eax
	mov		top,0
	lea		esi,[ebx+sizeof CADMEM]
	.while [esi].OBJECT.tpe
		.if [esi].OBJECT.hsel
			invoke CadInvalidateObject,hWin,esi
			call	Rotate
			invoke CadInvalidateObject,hWin,esi
			mov		[ebx].CADMEM.changed,TRUE
		.endif
		mov		eax,[esi].OBJECT.cbsize
		lea		esi,[esi+eax]
	.endw
	ret

GetRect:
	push	ecx
	push	esi
	movzx	eax,[esi].OBJECT.tpe
	.if eax==TPE_LINE || eax==TPE_RECT || eax==TPE_CIRCLE || eax==TPE_DIMENSION
		mov		eax,[esi].OBJECT.rc.left
		.if sdword ptr eax<left
			mov		left,eax
		.endif
		.if sdword ptr eax>right
			mov		right,eax
		.endif
		mov		eax,[esi].OBJECT.rc.right
		.if sdword ptr eax<left
			mov		left,eax
		.endif
		.if sdword ptr eax>right
			mov		right,eax
		.endif
		mov		eax,[esi].OBJECT.rc.top
		.if sdword ptr eax<top
			mov		top,eax
		.endif
		.if sdword ptr eax>bottom
			mov		bottom,eax
		.endif
		mov		eax,[esi].OBJECT.rc.bottom
		.if sdword ptr eax<top
			mov		top,eax
		.endif
		.if sdword ptr eax>bottom
			mov		bottom,eax
		.endif
	.elseif eax==TPE_POLYLINE
		mov		ecx,[esi].OBJECT.npt
		lea		esi,[esi].OBJECT.rc
		.while ecx
			mov		eax,[esi].POINT.x
			.if sdword ptr eax<left
				mov		left,eax
			.endif
			.if sdword ptr eax>right
				mov		right,eax
			.endif
			mov		eax,[esi].POINT.y
			.if sdword ptr eax<top
				mov		top,eax
			.endif
			.if sdword ptr eax>bottom
				mov		bottom,eax
			.endif
			lea		esi,[esi+sizeof POINT]
			dec		ecx
		.endw
	.elseif eax==TPE_HTEXT || eax==TPE_VTEXT
		mov		eax,[esi].OBJECT.rc.left
		.if sdword ptr eax<left
			mov		left,eax
		.endif
		.if sdword ptr eax>right
			mov		right,eax
		.endif
		mov		eax,[esi].OBJECT.rc.right
		.if sdword ptr eax<left
			mov		left,eax
		.endif
		.if sdword ptr eax>right
			mov		right,eax
		.endif
		mov		eax,[esi].OBJECT.rc.top
		.if sdword ptr eax<top
			mov		top,eax
		.endif
		.if sdword ptr eax>bottom
			mov		bottom,eax
		.endif
		mov		eax,[esi].OBJECT.rc.bottom
		.if sdword ptr eax<top
			mov		top,eax
		.endif
		.if sdword ptr eax>bottom
			mov		bottom,eax
		.endif
	.elseif eax==TPE_SYMBOL
		mov		ecx,[esi].OBJECT.npt
		lea		esi,[esi+sizeof OBJECT]
		.while ecx
			call	GetRect
			mov		eax,[esi].OBJECT.cbsize
			lea		esi,[esi+eax]
			dec		ecx
		.endw
	.endif
	pop		esi
	pop		ecx
	retn

Rotate:
	push	ebx
	push	ecx
	push	esi
	movzx	eax,[esi].OBJECT.tpe
	.if eax==TPE_LINE || eax==TPE_RECT || eax==TPE_CIRCLE || eax==TPE_DIMENSION
		mov		eax,[esi].OBJECT.rc.left
		sub		eax,ofsleft
		mov		ebx,[esi].OBJECT.rc.top
		sub		ebx,ofstop
		mov		ecx,[esi].OBJECT.rc.right
		sub		ecx,ofsleft
		mov		edx,[esi].OBJECT.rc.bottom
		sub		edx,ofstop
		add		ebx,ofsleft
		mov		[esi].OBJECT.rc.left,ebx
		add		eax,ofstop
		mov		[esi].OBJECT.rc.top,eax
		add		edx,ofsleft
		mov		[esi].OBJECT.rc.right,edx
		add		ecx,ofstop
		mov		[esi].OBJECT.rc.bottom,ecx
	.elseif eax==TPE_POLYLINE
		mov		ecx,[esi].OBJECT.npt
		lea		esi,[esi].OBJECT.rc
		.while ecx
			mov		eax,[esi].POINT.x
			sub		eax,ofsleft
			mov		edx,[esi].POINT.y
			sub		edx,ofstop
			add		eax,ofstop
			mov		[esi].POINT.y,eax
			add		edx,ofsleft
			mov		[esi].POINT.x,edx
			lea		esi,[esi+sizeof POINT]
			dec		ecx
		.endw
	.elseif eax==TPE_HTEXT
		mov		[esi].OBJECT.tpe,TPE_VTEXT
		mov		eax,[esi].OBJECT.rc.left
		sub		eax,ofsleft
		mov		ebx,[esi].OBJECT.rc.top
		sub		ebx,ofstop
		mov		ecx,[esi].OBJECT.rc.right
		sub		ecx,ofsleft
		mov		edx,[esi].OBJECT.rc.bottom
		sub		edx,ofstop
		add		ebx,ofsleft
		sub		ebx,CHARWIDTH
		mov		[esi].OBJECT.rc.left,ebx
		add		eax,ofstop
		mov		[esi].OBJECT.rc.top,eax
		add		edx,ofsleft
		sub		edx,CHARWIDTH
		mov		[esi].OBJECT.rc.right,edx
		add		ecx,ofstop
		mov		[esi].OBJECT.rc.bottom,ecx
	.elseif eax==TPE_VTEXT
		mov		[esi].OBJECT.tpe,TPE_HTEXT
		mov		eax,[esi].OBJECT.rc.left
		sub		eax,ofsleft
		mov		ebx,[esi].OBJECT.rc.top
		sub		ebx,ofstop
		mov		ecx,[esi].OBJECT.rc.right
		sub		ecx,ofsleft
		mov		edx,[esi].OBJECT.rc.bottom
		sub		edx,ofstop
		add		ebx,ofsleft
		mov		[esi].OBJECT.rc.left,ebx
		add		eax,ofstop
		mov		[esi].OBJECT.rc.top,eax
		add		edx,ofsleft
		mov		[esi].OBJECT.rc.right,edx
		add		ecx,ofstop
		mov		[esi].OBJECT.rc.bottom,ecx
	.elseif eax==TPE_SYMBOL
		mov		eax,[esi].OBJECT.rc.left
		sub		eax,ofsleft
		mov		ebx,[esi].OBJECT.rc.top
		sub		ebx,ofstop
		mov		ecx,[esi].OBJECT.rc.right
		sub		ecx,ofsleft
		mov		edx,[esi].OBJECT.rc.bottom
		sub		edx,ofstop
		add		ebx,ofsleft
		mov		[esi].OBJECT.rc.left,ebx
		add		eax,ofstop
		mov		[esi].OBJECT.rc.top,eax
		add		edx,ofsleft
		mov		[esi].OBJECT.rc.right,edx
		add		ecx,ofstop
		mov		[esi].OBJECT.rc.bottom,ecx
		mov		ecx,[esi].OBJECT.npt
		lea		esi,[esi+sizeof OBJECT]
		.while ecx
			call	Rotate
			mov		eax,[esi].OBJECT.cbsize
			lea		esi,[esi+eax]
			dec		ecx
		.endw
	.endif
	pop		esi
	pop		ecx
	pop		ebx
	retn

CadRotate endp

CadProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	rectout:RECT
	LOCAL	ps:PAINTSTRUCT
	LOCAL	mDC:HDC
	LOCAL	sinf:SCROLLINFO

	mov		eax,uMsg
	.if eax==WM_SIZE
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		call	SetScroll
	.elseif eax==WM_CREATE
		invoke CadClear,hWin
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		[ebx].CADMEM.style,eax
		mov		[ebx].CADMEM.backcolor,0FFFFFFh
	.elseif eax==WM_PAINT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke BeginPaint,hWin,addr ps
		invoke CreateCompatibleDC,ps.hdc
		mov		mDC,eax
		mov		rect.left,0
		mov		eax,ps.rcPaint.right
		sub		eax,ps.rcPaint.left
		mov		rect.right,eax
		mov		rect.top,0
		mov		eax,ps.rcPaint.bottom
		sub		eax,ps.rcPaint.top
		mov		rect.bottom,eax
		invoke CreateCompatibleBitmap,ps.hdc,rect.right,rect.bottom
		invoke SelectObject,mDC,eax
		push	eax
		invoke CreateSolidBrush,[ebx].CADMEM.backcolor
		push	eax
		invoke FillRect,mDC,addr rect,eax
		pop		eax
		invoke DeleteObject,eax
		mov		eax,ps.rcPaint.left
		add		eax,[ebx].CADMEM.scroll.x
		mov		edx,ps.rcPaint.top
		add		edx,[ebx].CADMEM.scroll.y
		invoke CadDraw,hWin,mDC,eax,edx,rect.right,rect.bottom,FALSE,FALSE
		mov		eax,ps.rcPaint.right
		sub		eax,ps.rcPaint.left
		mov		edx,ps.rcPaint.bottom
		sub		edx,ps.rcPaint.top
		invoke BitBlt,ps.hdc,ps.rcPaint.left,ps.rcPaint.top,eax,edx,mDC,0,0,SRCCOPY
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		invoke DeleteDC,mDC
		invoke EndPaint,hWin,addr ps
	.elseif eax==WM_MOUSEMOVE
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke CadSetCursorPos,hWin
		invoke CadNotify,hWin,CN_CURMOVE,0
		mov		eax,wParam
		and		eax,MK_LBUTTON or MK_CONTROL
		.if ncadbox && eax==MK_LBUTTON
			mov		eax,curpos.y
			add		eax,[ebx].CADMEM.scroll.y
			call	ZoomDiv
			sub		eax,lastpos.y
			push	eax
			mov		eax,curpos.x
			add		eax,[ebx].CADMEM.scroll.x
			call	ZoomDiv
			sub		eax,lastpos.x
			pop		edx
			or		eax,edx
			.if initcreate && eax
				mov		initcreate,FALSE
				invoke CadAddObject,hWin,ncadbox
			.endif
		.else
			test	wParam,MK_LBUTTON
			.if !ZERO?
				invoke GetCapture
				.if eax==hWin
					invoke GetDC,hWin
					mov		mDC,eax
					.if sel
						call	DrawSelRect
					.endif
					mov		eax,lParam
					shr		eax,16
					cwde
					mov		edx,eax
					mov		eax,lParam
					cwde
					mov		ecx,eax
					sub		ecx,selrect.left
					.if CARRY?
						neg		ecx
					.endif
					.if ecx<3
						mov		ecx,edx
						sub		ecx,selrect.top
						.if CARRY?
							neg		ecx
						.endif
					.endif
					.if ecx>=3 || sel
						mov		selrect.right,eax
						mov		selrect.bottom,edx
						call	DrawSelRect
						mov		sel,TRUE
					.endif
					invoke ReleaseDC,hWin,mDC
				.endif
			.endif
		.endif
		.if rpsize
			mov		eax,rpsize
			sub		eax,sizeof CADMEM
			invoke CadAdjustObject,hWin,eax
		.endif
	.elseif eax==WM_LBUTTONDOWN
		invoke SetFocus,hWin
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke CadSetCursorPos,hWin
		invoke SetCapture,hWin
		mov		eax,wParam
		and		eax,MK_CONTROL
		.if !ncadbox || eax
			mov		edx,lParam
			movzx	eax,dx
			shr		edx,16
			mov		selrect.left,eax
			mov		selrect.top,edx
		.else
			invoke CadSelectAll,hWin,FALSE
			invoke CadSetInitialPos,hWin
			.if ncadbox==TPE_HTEXT || ncadbox==TPE_VTEXT
				invoke CadAddObject,hWin,ncadbox
				mov		rpsize,0
			.else
				.if !rpsize
					mov		initcreate,TRUE
				.else
					mov		edx,rpsize
					lea		edx,[ebx+edx]
					inc		[edx].OBJECT.npt
					add		[edx].OBJECT.cbsize,8
					add		[ebx].CADMEM.rpFree,8
				.endif
			.endif
		.endif
	.elseif eax==WM_LBUTTONUP
		invoke GetCapture
		.if eax==hWin
			invoke GetWindowLong,hWin,0
			mov		ebx,eax
			mov		initcreate,FALSE
			.if rpsize
				.if ncadbox!=TPE_POLYLINE
					mov		rpsize,0
				.endif
			.elseif sel
				invoke GetDC,hWin
				mov		mDC,eax
				mov		sel,FALSE
				call	DrawSelRect
				invoke ReleaseDC,hWin,mDC
				mov		ecx,wParam
				and		ecx,MK_CONTROL
				invoke CadSelectRect,hWin,ecx,addr selrect
			.else
				mov		ecx,wParam
				and		ecx,MK_CONTROL
				invoke CadSelectObject,hWin,ecx
			.endif
			invoke ReleaseCapture
		.endif
	.elseif eax==WM_RBUTTONDOWN
		.if !rpsize
			invoke CadNotify,hWin,CN_SELRCLICK,-1
		.endif
	.elseif eax==WM_MOUSEWHEEL
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		movsx	eax,ax
		test	edx,MK_CONTROL
		.if ZERO?
			.if sdword ptr eax<0
				invoke SendMessage,hWin,WM_VSCROLL,SB_LINEDOWN,0
			.else
				invoke SendMessage,hWin,WM_VSCROLL,SB_LINEUP,0
			.endif
		.else
			.if sdword ptr eax<0
				invoke SendMessage,hWin,WM_HSCROLL,SB_LINERIGHT,0
			.else
				invoke SendMessage,hWin,WM_HSCROLL,SB_LINELEFT,0
			.endif
		.endif
	.elseif eax==WM_CONTEXTMENU
		.if rpsize
			mov		rpsize,0
		.else
			jmp		ExDef
		.endif
	.elseif eax==WM_HSCROLL
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		movzx	eax,ax
		.if eax==SB_THUMBTRACK || eax==SB_THUMBPOSITION
			mov		sinf.cbSize,sizeof sinf
			mov		sinf.fMask,SIF_POS
			mov		eax,wParam
			shr		eax,16
			mov		sinf.nPos,eax
			invoke SetScrollInfo,hWin,SB_HORZ,addr sinf,TRUE
			mov		eax,sinf.nPos
			call	ZoomMul
			mov		edx,eax
			mov		eax,[ebx].CADMEM.scroll.x
			sub		eax,edx
			mov		[ebx].CADMEM.scroll.x,edx
			invoke ScrollWindow,hWin,eax,0,NULL,NULL
			invoke UpdateWindow,hWin
		.elseif eax==SB_LINELEFT || eax==SB_LINERIGHT || eax==SB_PAGELEFT || eax==SB_PAGERIGHT
			mov		sinf.cbSize,sizeof sinf
			mov		sinf.fMask,SIF_POS
			invoke GetScrollInfo,hWin,SB_HORZ,addr sinf
			mov		ecx,sinf.nPos
			mov		eax,wParam
			.if eax==SB_LINERIGHT
				inc		ecx
			.elseif eax==SB_LINELEFT
				.if ecx
					dec		ecx
				.endif
			.elseif eax==SB_PAGERIGHT
				add		ecx,64
			.elseif eax==SB_PAGELEFT
				.if ecx>64
					sub		ecx,64
				.else
					mov		ecx,0
				.endif
			.endif
			shl		ecx,16
			or		ecx,SB_THUMBPOSITION
			invoke SendMessage,hWin,WM_HSCROLL,ecx,0
		.endif
	.elseif eax==WM_VSCROLL
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		movzx	eax,ax
		.if eax==SB_THUMBTRACK || eax==SB_THUMBPOSITION
			mov		sinf.cbSize,sizeof sinf
			mov		sinf.fMask,SIF_POS
			mov		eax,wParam
			shr		eax,16
			mov		sinf.nPos,eax
			invoke SetScrollInfo,hWin,SB_VERT,addr sinf,TRUE
			mov		eax,sinf.nPos
			call	ZoomMul
			mov		edx,eax
			mov		eax,[ebx].CADMEM.scroll.y
			sub		eax,edx
			mov		[ebx].CADMEM.scroll.y,edx
			invoke ScrollWindow,hWin,0,eax,NULL,NULL
			invoke UpdateWindow,hWin
		.elseif eax==SB_LINEDOWN || eax==SB_LINEUP || eax==SB_PAGEDOWN || eax==SB_PAGEUP
			mov		sinf.cbSize,sizeof sinf
			mov		sinf.fMask,SIF_POS
			invoke GetScrollInfo,hWin,SB_VERT,addr sinf
			mov		ecx,sinf.nPos
			mov		eax,wParam
			.if eax==SB_LINEDOWN
				inc		ecx
			.elseif eax==SB_LINEUP
				.if ecx
					dec		ecx
				.endif
			.elseif eax==SB_PAGEDOWN
				add		ecx,64
			.elseif eax==SB_PAGEUP
				.if ecx>64
					sub		ecx,64
				.else
					mov		ecx,0
				.endif
			.endif
			shl		ecx,16
			or		ecx,SB_THUMBPOSITION
			invoke SendMessage,hWin,WM_VSCROLL,ecx,0
		.endif
	.elseif eax==WM_DESTROY
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GlobalUnlock,[ebx].CADMEM.hUndo
		invoke GlobalFree,[ebx].CADMEM.hUndo
		invoke GlobalUnlock,ebx
		invoke GlobalFree,ebx
		invoke SetWindowLong,hWin,0,0
	.elseif eax==CM_GETOBJECT
		mov		eax,ncadbox
		jmp		Ex
	.elseif eax==CM_SETOBJECT
		mov		eax,wParam
		mov		ncadbox,eax
	.elseif eax==CM_CANUNDO
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].CADMEM.hUndo
		add		eax,[ebx].CADMEM.rpUndo
		mov		eax,[eax]
		.if eax
			mov		eax,TRUE
		.else
			mov		eax,FALSE
		.endif
		jmp		Ex
	.elseif eax==CM_UNDO
		invoke CadUndo,hWin
	.elseif eax==CM_CANREDO
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].CADMEM.hUndo
		add		eax,[ebx].CADMEM.rpUndo
		add		eax,sizeof UNDO
		mov		eax,[eax]
		.if eax
			mov		eax,TRUE
		.else
			mov		eax,FALSE
		.endif
		jmp		Ex
	.elseif eax==CM_REDO
		invoke CadRedo,hWin
	.elseif eax==CM_GETZOOM
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].CADMEM.zoom
		jmp		Ex
	.elseif eax==CM_ZOOMIN
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].CADMEM.zoom
		.if eax<ZOOM_MAX
			mov		[ebx].CADMEM.zoom,eax
			mov		eax,[ebx].CADMEM.scroll.x
			invoke ZoomDiv
			push	eax
			mov		eax,[ebx].CADMEM.scroll.y
			invoke ZoomDiv
			push	eax
			mov		eax,[ebx].CADMEM.zoom
			inc		eax
			mov		edx,eax
			shr		edx,4
			add		eax,edx
			mov		[ebx].CADMEM.zoom,eax
			mov		ecx,1
			call	TestGrid
			pop		eax
			invoke ZoomMul
			mov		[ebx].CADMEM.scroll.y,eax
			pop		eax
			invoke ZoomMul
			mov		[ebx].CADMEM.scroll.x,eax
			call	SetScroll
			call	UpdateScrollPos
			invoke InvalidateRect,hWin,NULL,TRUE
			invoke CadSetCursorPos,hWin
			invoke CadNotify,hWin,CN_ZOOM,0
		.endif
	.elseif eax==CM_ZOOMOUT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].CADMEM.zoom
		.if eax>ZOOM_MIN
			mov		[ebx].CADMEM.zoom,eax
			mov		eax,[ebx].CADMEM.scroll.x
			invoke ZoomDiv
			push	eax
			mov		eax,[ebx].CADMEM.scroll.y
			invoke ZoomDiv
			push	eax
			mov		eax,[ebx].CADMEM.zoom
			dec		eax
			mov		edx,eax
			shr		edx,4
			sub		eax,edx
			mov		[ebx].CADMEM.zoom,eax
			mov		ecx,-1
			call	TestGrid
			pop		eax
			invoke ZoomMul
			mov		[ebx].CADMEM.scroll.y,eax
			pop		eax
			invoke ZoomMul
			mov		[ebx].CADMEM.scroll.x,eax
			call	SetScroll
			call	UpdateScrollPos
			invoke InvalidateRect,hWin,NULL,TRUE
			invoke CadSetCursorPos,hWin
			invoke CadNotify,hWin,CN_ZOOM,0
		.endif
	.elseif eax==CM_ZOOMFIT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GetClientRect,hWin,addr rect
		invoke CadZoomBestFit,hWin,addr rect,addr rectout,TRUE,TRUE
		mov		eax,5
		invoke ZoomMul
		add		rect.left,eax
		add		rect.top,eax
		sub		rect.right,eax
		sub		rect.bottom,eax
		invoke CadZoomBestFit,hWin,addr rect,addr rectout,TRUE,TRUE
		mov		eax,rectout.left
		sub		eax,5
		invoke ZoomMul
		mov		[ebx].CADMEM.scroll.x,eax
		mov		eax,rectout.top
		sub		eax,5
		invoke ZoomMul
		mov		[ebx].CADMEM.scroll.y,eax
		call	SetScroll
		call	UpdateScrollPos
		invoke InvalidateRect,hWin,NULL,TRUE
		invoke CadSetCursorPos,hWin
		invoke CadNotify,hWin,CN_ZOOM,0
	.elseif eax==CM_GETWIDTH
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		movzx	eax,[ebx].CADMEM.wdt
		jmp		Ex
	.elseif eax==CM_SETWIDTH
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		mov		[ebx].CADMEM.wdt,al
	.elseif eax==CM_GETCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].CADMEM.color
		jmp		Ex
	.elseif eax==CM_SETCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		mov		[ebx].CADMEM.color,eax
	.elseif eax==CM_GETSELCOUNT
		invoke CadGetSelCount,hWin
		jmp		Ex
	.elseif eax==CM_CUT
		invoke CadCopy,hWin
		invoke CadDelete,hWin
		jmp		Ex
	.elseif eax==CM_COPY
		invoke CadCopy,hWin
		jmp		Ex
	.elseif eax==CM_CANPASTE
		invoke IsClipboardFormatAvailable,hClip
		jmp		Ex
	.elseif eax==CM_PASTE
		invoke CadPaste,hWin
		jmp		Ex
	.elseif eax==CM_DELETE
		invoke CadDelete,hWin
		jmp		Ex
	.elseif eax==CM_GETMODIFY
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].CADMEM.changed
		jmp		Ex
	.elseif eax==CM_SETMODIFY
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		mov		[ebx].CADMEM.changed,eax
	.elseif eax==CM_SELECTALL
		invoke CadSelectAll,hWin,wParam
		jmp		Ex
	.elseif eax==CM_GETGRID
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].CADMEM.grid
		jmp		Ex
	.elseif eax==CM_SETGRID
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		mov		[ebx].CADMEM.grid,eax
		invoke InvalidateRect,hWin,NULL,TRUE
	.elseif eax==CM_GETSNAP
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].CADMEM.snap
		jmp		Ex
	.elseif eax==CM_SETSNAP
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		mov		[ebx].CADMEM.snap,eax
	.elseif eax==CM_CLEAR
		invoke CadSelectAll,hWin,FALSE
		invoke CadClear,hWin
		mov		ebx,eax
		call	SetScroll
		call	UpdateScrollPos
	.elseif eax==CM_STREAMIN
		invoke GetCursor
		push	eax
		invoke LoadCursor,0,IDC_WAIT
		invoke SetCursor,eax
		invoke CadSelectAll,hWin,FALSE
		invoke CadClear,hWin
		mov		ebx,eax
		invoke CadStreamIn,ebx,lParam
		mov		[ebx].CADMEM.backcolor,0FFFFFFh
		call	SetScroll
		call	UpdateScrollPos
		pop		eax
		invoke SetCursor,eax
	.elseif eax==CM_STREAMOUT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GetCursor
		push	eax
		invoke LoadCursor,0,IDC_WAIT
		invoke SetCursor,eax
		invoke CadStreamOut,ebx,lParam
		pop		eax
		invoke SetCursor,eax
	.elseif eax==CM_PRINT
		invoke CadPrint,hWin,wParam,lParam
	.elseif eax==CM_SELSETCOLOR
		invoke CadSelSetColor,hWin,wParam
	.elseif eax==CM_SELSETWIDTH
		invoke CadSelSetWidth,hWin,wParam
	.elseif eax==CM_GETTEXT
		xor		ecx,ecx
		mov		ebx,offset szText
		mov		edx,lParam
		.while ecx<wParam
			mov		al,[ebx+ecx]
			.break .if !al
			mov		[edx+ecx],al
			inc		ecx
		.endw
		xor		al,al
		mov		[edx+ecx],al
		mov		eax,ecx
		jmp		Ex
	.elseif eax==CM_SETTEXT
		xor		ecx,ecx
		mov		ebx,offset szText
		mov		edx,lParam
		.while ecx<sizeof szText
			mov		al,[edx+ecx]
			.break .if !al
			mov		[ebx+ecx],al
			inc		ecx
		.endw
		xor		al,al
		mov		[ebx+ecx],al
		mov		eax,TRUE
		jmp		Ex
	.elseif eax==CM_GETBACKCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].CADMEM.backcolor
		jmp		Ex
	.elseif eax==CM_SETBACKCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,lParam
		mov		[ebx].CADMEM.backcolor,eax
		invoke InvalidateRect,hWin,NULL,TRUE
		xor		eax,eax
		jmp		Ex
	.elseif eax==CM_ADDOBJECTS
		invoke CadSelectAll,hWin,FALSE
		invoke CadAddObjects,hWin,lParam
	.elseif eax==CM_FLIPOBJECT
		invoke CadGetSelCount,hWin
		.if eax
			invoke CadFlip,hWin
		.endif
	.elseif eax==CM_ROTATEOBJECT
		invoke CadGetSelCount,hWin
		.if eax
			invoke CadRotate,hWin
			invoke CadFlip,hWin
		.endif
	.elseif eax==CM_SETLAYER
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke CadSelectAll,hWin,FALSE
		mov		eax,wParam
		mov		[ebx].CADMEM.layer,eax
		invoke InvalidateRect,hWin,NULL,TRUE
		xor		eax,eax
		jmp		Ex
	.elseif eax==CM_GETTOP
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,lParam
		mov		eax,[ebx].CADMEM.scroll.x
		mov		[edx].POINT.x,eax
		mov		eax,[ebx].CADMEM.scroll.y
		mov		[edx].POINT.y,eax
		xor		eax,eax
		jmp		Ex
	.elseif eax==CM_SETTOP
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,lParam
		mov		eax,[edx].POINT.x
		mov		[ebx].CADMEM.scroll.x,eax
		mov		eax,[edx].POINT.y
		mov		[ebx].CADMEM.scroll.y,eax
		call	UpdateScrollPos
		invoke InvalidateRect,hWin,NULL,TRUE
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_USER+9999
		invoke SendMessage,hWin,CM_SETWIDTH,2,0
		mov		ncadbox,TPE_HTEXT
		invoke lstrcpy,addr szText,addr szToolTip
		invoke CadAddObject,hWin,0
	.else
  ExDef:
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
  Ex:
	ret

TestGrid:
	push	ecx
	mov		eax,SNAP_SIZE*2
	call	ZoomMul
	call	ZoomDiv
	pop		ecx
	.if eax!=SNAP_SIZE*2
		add		[ebx].CADMEM.zoom,ecx
		jmp		TestGrid
	.endif
	retn

SetScroll:
	invoke GetClientRect,hWin,addr rect
	mov		sinf.cbSize,sizeof sinf
	mov		sinf.fMask,SIF_RANGE or SIF_PAGE
	mov		sinf.nMin,0
	mov		eax,MAXSIZE
	mov		sinf.nMax,eax
	mov		eax,rect.bottom
	call	ZoomDiv
	mov		sinf.nPage,eax
	invoke SetScrollInfo,hWin,SB_VERT,addr sinf,TRUE
	mov		eax,rect.right
	call	ZoomDiv
	mov		sinf.nPage,eax
	invoke SetScrollInfo,hWin,SB_HORZ,addr sinf,TRUE
	retn

UpdateScrollPos:
	mov		sinf.cbSize,sizeof sinf
	mov		sinf.fMask,SIF_POS
	mov		eax,[ebx].CADMEM.scroll.x
	invoke ZoomDiv
	mov		sinf.nPos,eax
	invoke SetScrollInfo,hWin,SB_HORZ,addr sinf,TRUE
	mov		sinf.cbSize,sizeof sinf
	mov		sinf.fMask,SIF_POS
	mov		eax,[ebx].CADMEM.scroll.y
	invoke ZoomDiv
	mov		sinf.nPos,eax
	invoke SetScrollInfo,hWin,SB_VERT,addr sinf,TRUE
	retn

DrawSelRect:
	invoke CopyRect,addr rect,addr selrect
	mov		eax,rect.left
	.if sdword ptr eax>rect.right
		xchg	eax,rect.right
		mov		rect.left,eax
	.endif
	mov		eax,rect.top
	.if sdword ptr eax>rect.bottom
		xchg	eax,rect.bottom
		mov		rect.top,eax
	.endif
	inc		rect.left
	inc		rect.top
	invoke DrawFocusRect,mDC,addr rect
	retn

CadProc endp

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	.if reason==DLL_PROCESS_ATTACH
		push	hInst
		pop		hInstance
		invoke InstallRACad
	.elseif reason==DLL_PROCESS_DETACH
		invoke UnInstallRACad
	.endif
	mov     eax,TRUE
	ret

DllEntry endp

GetDef proc nInx:DWORD

	mov		eax,nInx
	.if !eax
		;Get the toolbox bitmap
		;RadASM destroys it after use, so you don't have to worry about that.
		invoke LoadBitmap,hInstance,IDB_RACADBUTTON
		mov		ccdef.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdef
	.else
		xor		eax,eax
	.endif
	ret

GetDef endp

End DllEntry

