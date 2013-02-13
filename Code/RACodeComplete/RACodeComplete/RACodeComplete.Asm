; Custom control containing listbox and tooltip designed
; to handle code complete (intellisense).
;
; Normal build to create the dll
; Debug build to create the lib
;
; KetilO (C) 2005

.386
.model flat,stdcall
option casemap:none
option proc:private

include windows.inc
include ..\RACodeComplete.inc
include Data.inc
include Sort.asm

IDB_TYPES		equ 110

.code

InstallRACodeComplete proc public hInst:HINSTANCE,fGlobal:DWORD
	LOCAL	wc:WNDCLASSEX

	;Create a windowclass for the listbox control
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_PARENTDC or CS_DBLCLKS
	.if fGlobal
		mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_PARENTDC or CS_DBLCLKS or CS_GLOBALCLASS
	.endif
	mov		wc.lpfnWndProc,offset CodeCompleteProc
	mov		eax,NULL
	mov		wc.cbClsExtra,eax
	mov		wc.hbrBackground,eax
	mov		wc.lpszMenuName,eax
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	mov		wc.cbWndExtra,4
	mov		eax,hInst
	mov		wc.hInstance,eax
	mov		hInstance,eax
	mov		wc.lpszClassName,offset szCCLBClassName
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc

	;Create a windowclass for the tooltip control
	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_PARENTDC
	.if fGlobal
		mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_PARENTDC or CS_GLOBALCLASS
	.endif
	mov		wc.lpfnWndProc,offset ToolTipProc
	mov		wc.lpszClassName,offset szCCTTClassName
	mov		wc.hCursor,NULL
	invoke RegisterClassEx,addr wc
	ret

InstallRACodeComplete endp

UnInstallRACodeComplete proc public

	ret

UnInstallRACodeComplete endp

;--------------------------------------------------------------------------------

strlen proc lpSource:DWORD

	mov	eax,lpSource
	sub	eax,4
align 4
@@:
	add	eax, 4
	movzx	edx,word ptr [eax]
	test	dl,dl
	je	@lb1
	
	test	dh, dh
	je	@lb2
	
	movzx	edx,word ptr [eax+2]
	test	dl, dl
	je	@lb3

	test	dh, dh
	jne	@B
	
	sub	eax,lpSource
	add	eax,3
	ret

@lb3:
	sub	eax,lpSource
	add	eax,2
	ret

@lb2:
	sub	eax,lpSource
	add	eax,1
	ret

@lb1:
	sub	eax,lpSource
	ret

strlen endp

CompareStr proc lpStr1:DWORD,lpStr2:DWORD

	mov		ecx,lpStr1
	mov		edx,lpStr2
  @@:
	mov		al,[ecx]
	.if al
		mov		ah,[edx]
		inc		ecx
		inc		edx
		.if al>='a' && al<='z'
			sub		al,20h
		.endif
		.if ah>='a' && ah<='z'
			sub		ah,20h
		.endif
		sub		al,ah
		je		@b
	.endif
	movsx	eax,al
	ret

CompareStr endp

CompareStrMatchCase proc lpStr1:DWORD,lpStr2:DWORD

	mov		ecx,lpStr1
	mov		edx,lpStr2
  @@:
	mov		al,[ecx]
	mov		ah,[edx]
	.if al && ah
		inc		ecx
		inc		edx
		sub		al,ah
		je		@b
	.endif
	movzx	eax,ax
	ret

CompareStrMatchCase endp

CodeCompleteProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	sinf:SCROLLINFO
	LOCAL	ninx:DWORD

	mov		eax,uMsg
	.if eax>=CCM_ADDITEM && eax<=CCM_GETMAXWIDTH
		push		eax
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		pop		eax
		sub		eax,CCM_ADDITEM
		jmp 		DWORD PTR [offset _RACODECOMPLETE_BASE+eax*4]
		include RACodeComplete_Msg_JumpTable.asm
	.endif
	.if eax==WM_PAINT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		call	SetScroll
		invoke BeginPaint,hWin,addr ps
		mov		eax,[ebx].RACC.backcolor
		.if sdword ptr eax<0
			and		eax,7FFFFFFFh
			invoke GetSysColor,eax
		.endif
		invoke CreateSolidBrush,eax
		push	eax
		invoke FillRect,ps.hdc,addr ps.rcPaint,eax
		pop		eax
		invoke DeleteObject,eax
		invoke SetBkMode,ps.hdc,TRANSPARENT
		invoke SelectObject,ps.hdc,[ebx].RACC.hfont
		push	eax
		mov		ecx,[ebx].RACC.topindex
		mov		pt.y,0
		mov		edx,[ebx].RACC.lpmem
		.while ecx<[ebx].RACC.count
			mov		eax,pt.y
			.break .if eax>ps.rcPaint.bottom
			add		eax,[ebx].RACC.itemheight
			.if eax>ps.rcPaint.top
				push	ecx
				push	edx
				mov		eax,[edx+ecx*8+4]
				mov		ninx,eax
				mov		edx,[edx+ecx*8]
				push	edx
				.if ecx==[ebx].RACC.cursel
					mov		eax,pt.y
					mov		rect.top,eax
					add		eax,[ebx].RACC.itemheight
					mov		rect.bottom,eax
					invoke GetSysColor,COLOR_HIGHLIGHT
					invoke CreateSolidBrush,eax
					push	eax
					invoke FillRect,ps.hdc,addr rect,eax
					pop		eax
					invoke DeleteObject,eax
					invoke GetFocus
					.if eax==hWin
						invoke SetTextColor,ps.hdc,0
						invoke DrawFocusRect,ps.hdc,addr rect
					.endif
					invoke GetSysColor,COLOR_HIGHLIGHTTEXT
					invoke SetTextColor,ps.hdc,eax
				.else
					mov		eax,[ebx].RACC.textcolor
					.if sdword ptr eax<0
						and		eax,7FFFFFFFh
						invoke GetSysColor,eax
					.endif
					invoke SetTextColor,ps.hdc,eax
				.endif
				pop		edx
				push	edx
				invoke strlen,edx
				pop		edx
				test	[ebx].RACC.style,STYLE_USEIMAGELIST
				.if ZERO?
					invoke TextOut,ps.hdc,1,pt.y,edx,eax
				.else
					invoke TextOut,ps.hdc,19,pt.y,edx,eax
					invoke ImageList_Draw,[ebx].RACC.himl,ninx,ps.hdc,1,pt.y,ILD_NORMAL
				.endif
				pop		edx
				pop		ecx
			.endif
			mov		eax,[ebx].RACC.itemheight
			add		pt.y,eax
			inc		ecx
		.endw
		pop		eax
		invoke SelectObject,ps.hdc,eax
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
	.elseif eax==WM_CREATE
		invoke GetProcessHeap
		invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof RACC
		mov		ebx,eax
		invoke SetWindowLong,hWin,0,ebx
		mov		[ebx].RACC.cbsize,1024*32
		invoke GlobalAlloc,GMEM_MOVEABLE,[ebx].RACC.cbsize
		mov		[ebx].RACC.hmem,eax
		invoke GlobalLock,[ebx].RACC.hmem
		mov		[ebx].RACC.lpmem,eax
		mov		[ebx].RACC.cursel,-1
		mov		[ebx].RACC.backcolor,80000000h or COLOR_WINDOW
		mov		[ebx].RACC.textcolor,80000000h or COLOR_WINDOWTEXT
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		[ebx].RACC.style,eax
		mov		[ebx].RACC.fredraw,TRUE
		mov		[ebx].RACC.itemheight,16
		;Create imagelist for property types
		invoke ImageList_Create,16,16,ILC_MASK or ILC_COLOR8,16,0
		mov		[ebx].RACC.himl,eax
		invoke LoadBitmap,hInstance,IDB_TYPES
		push	eax
		invoke ImageList_AddMasked,[ebx].RACC.himl,eax,0FF00FFh
		pop		eax
		invoke DeleteObject,eax
		xor		eax,eax
	.elseif eax==WM_DESTROY
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GlobalUnlock,[ebx].RACC.hmem
		invoke GlobalFree,[ebx].RACC.hmem
		invoke ImageList_Destroy,[ebx].RACC.himl
		invoke GetProcessHeap
		invoke HeapFree,eax,0,ebx
		xor		eax,eax
	.elseif eax==WM_SETFONT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		mov		[ebx].RACC.hfont,eax
		invoke GetDC,hWin
		mov		ps.hdc,eax
		invoke SelectObject,ps.hdc,[ebx].RACC.hfont
		push	eax
		mov		pt.x,'a'
		invoke GetTextExtentPoint32,ps.hdc,addr pt,1,addr pt
		pop		eax
		invoke SelectObject,ps.hdc,eax
		invoke ReleaseDC,hWin,ps.hdc
		mov		eax,pt.y
		add		eax,2
		.if eax<17
			mov		eax,17
		.endif
		mov		[ebx].RACC.itemheight,eax
		.if lParam
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.elseif eax==WM_LBUTTONDOWN
		invoke SetFocus,hWin
		invoke SetCapture,hWin
		invoke PostMessage,hWin,WM_MOUSEMOVE,wParam,lParam
		xor		eax,eax
	.elseif eax==WM_MOUSEMOVE
		invoke GetCapture
		.if eax==hWin
			invoke GetWindowLong,hWin,0
			mov		ebx,eax
			invoke GetClientRect,hWin,addr rect
			mov		eax,rect.bottom
			mov		ecx,[ebx].RACC.itemheight
			xor		edx,edx
			div		ecx
			push	eax
			mul		ecx
			mov		rect.bottom,eax
			mov		eax,lParam
			shr		eax,16
			cwde
			pop		edx
			.if sdword ptr eax<0
				mov		eax,[ebx].RACC.topindex
				.if eax
					dec		eax
					mov		[ebx].RACC.topindex,eax
					mov		[ebx].RACC.cursel,eax
					invoke InvalidateRect,hWin,NULL,TRUE
				.endif
			.elseif eax>=rect.bottom
				mov		eax,[ebx].RACC.topindex
				add		eax,edx
				.if eax<[ebx].RACC.count
					inc		[ebx].RACC.topindex
					mov		[ebx].RACC.cursel,eax
					invoke InvalidateRect,hWin,NULL,TRUE
				.endif
			.else
				mov		ecx,[ebx].RACC.itemheight
				xor		edx,edx
				idiv	ecx
				add		eax,[ebx].RACC.topindex
				.if eax<[ebx].RACC.count && eax!=[ebx].RACC.cursel
					push	eax
					invoke SendMessage,hWin,CCM_GETITEMRECT,[ebx].RACC.cursel,addr rect
					pop		[ebx].RACC.cursel
					invoke InvalidateRect,hWin,addr rect,TRUE
					invoke SendMessage,hWin,CCM_GETITEMRECT,[ebx].RACC.cursel,addr rect
					invoke InvalidateRect,hWin,addr rect,TRUE
				.endif
			.endif
		.endif
		xor		eax,eax
	.elseif eax==WM_SETFOCUS
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,[ebx].RACC.cursel
		.if sdword ptr edx>=0
			invoke SendMessage,hWin,CCM_GETITEMRECT,edx,addr rect
			invoke InvalidateRect,hWin,addr rect,TRUE
		.endif
		xor		eax,eax
	.elseif eax==WM_KILLFOCUS
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,[ebx].RACC.cursel
		.if sdword ptr edx>=0
			invoke SendMessage,hWin,CCM_GETITEMRECT,edx,addr rect
			invoke InvalidateRect,hWin,addr rect,TRUE
		.endif
		xor		eax,eax
	.elseif eax==WM_LBUTTONUP
		invoke GetCapture
		.if eax==hWin
			invoke ReleaseCapture
		.endif
		xor		eax,eax
	.elseif eax==WM_KEYDOWN
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		.if [ebx].RACC.count
			invoke GetClientRect,hWin,addr rect
			mov		edx,wParam
			mov		eax,lParam
			shr		eax,16
			and		eax,3FFh
			mov		ecx,[ebx].RACC.cursel
			.if edx==28h && (eax==150h || eax==50h)
				;Down
				inc		ecx
				.if ecx<[ebx].RACC.count
					mov		[ebx].RACC.cursel,ecx
					invoke SendMessage,hWin,CCM_SETVISIBLE,0,0
				.endif
			.elseif edx==26h && (eax==148h || eax==48h)
				;Up
				.if ecx && ecx<[ebx].RACC.count
					dec		ecx
					mov		[ebx].RACC.cursel,ecx
					invoke SendMessage,hWin,CCM_SETVISIBLE,0,0
				.endif
			.elseif edx==21h && (eax==149h || eax==49h)
				;PgUp
				mov		eax,rect.bottom
				mov		ecx,[ebx].RACC.itemheight
				xor		edx,edx
				div		ecx
				mov		ecx,eax
				mov		eax,[ebx].RACC.cursel
				sub		eax,ecx
				.if CARRY?
					xor		eax,eax
				.endif
				mov		[ebx].RACC.cursel,eax
				invoke SendMessage,hWin,CCM_SETVISIBLE,0,0
			.elseif edx==22h && (eax==151h || eax==51h)
				;PgDn
				mov		eax,rect.bottom
				mov		ecx,[ebx].RACC.itemheight
				xor		edx,edx
				div		ecx
				add		eax,[ebx].RACC.cursel
				.if eax>=[ebx].RACC.count
					mov		eax,[ebx].RACC.count
					dec		eax
				.endif
				mov		[ebx].RACC.cursel,eax
				invoke SendMessage,hWin,CCM_SETVISIBLE,0,0
			.elseif edx==24h && (eax==147h || eax==47h)
				;Home
				mov		[ebx].RACC.cursel,0
				invoke SendMessage,hWin,CCM_SETVISIBLE,0,0
			.elseif edx==23h && (eax==14Fh || eax==4Fh)
				;End
				mov		eax,[ebx].RACC.count
				dec		eax
				mov		[ebx].RACC.cursel,eax
				invoke SendMessage,hWin,CCM_SETVISIBLE,0,0
			.endif
		.endif
		xor		eax,eax
	.elseif eax==WM_CHAR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GetTickCount
		mov		edx,eax
		sub		eax,findtime
		mov		findtime,edx
		.if eax>1000
			xor		eax,eax
		.else
			invoke strlen,offset findbuff
		.endif
		mov		edx,wParam
		mov		word ptr findbuff[eax],dx
		invoke SendMessage,hWin,CCM_FINDSTRING,-1,offset findbuff
		.if eax!=-1
			invoke SendMessage,hWin,CCM_SETCURSEL,eax,0
			invoke SendMessage,hWin,CCM_SETVISIBLE,0,0
		.else
			invoke strlen,offset findbuff
			.if eax==2
				mov		ax,word ptr findbuff
				.if al==ah
					mov		findbuff[1],0
					invoke SendMessage,hWin,CCM_FINDSTRING,[ebx].RACC.cursel,offset findbuff
					.if eax!=-1
						invoke SendMessage,hWin,CCM_SETCURSEL,eax,0
						invoke SendMessage,hWin,CCM_SETVISIBLE,0,0
					.endif
				.endif
			.endif
		.endif
		xor		eax,eax
	.elseif eax==WM_VSCROLL
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		sinf.cbSize,sizeof sinf
		mov		sinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_VERT,addr sinf
		mov		eax,[ebx].RACC.topindex
		mov		edx,wParam
		movzx	edx,dx
		.if edx==SB_THUMBTRACK || edx==SB_THUMBPOSITION
			mov		eax,sinf.nTrackPos
		.elseif edx==SB_LINEDOWN
			inc		eax
			mov		edx,sinf.nMax
			sub		edx,sinf.nPage
			inc		edx
			.if eax>edx
				mov		eax,edx
			.endif
		.elseif edx==SB_LINEUP
			.if eax
				dec		eax
			.endif
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
		.elseif edx==SB_TOP
			xor		eax,eax
		.endif
		.if eax!=sinf.nPos
			mov		sinf.nPos,eax
			mov		[ebx].RACC.topindex,eax
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.elseif eax==WM_GETDLGCODE
		mov		eax,DLGC_CODE
	.elseif eax==WM_SETREDRAW
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		mov		eax,wParam
		mov		[ebx].RACC.fredraw,eax
		.if eax
			call	SetScroll
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

SetScroll:
	invoke GetClientRect,hWin,addr rect
	.if rect.right && rect.bottom
		mov		sinf.cbSize,sizeof sinf
		mov		sinf.fMask,SIF_ALL
		mov		eax,rect.bottom
		cdq
		mov		ecx,[ebx].RACC.itemheight
		div		ecx
		mov		sinf.nPage,eax
		mov		sinf.nMin,0
		mov		eax,[ebx].RACC.count
		.if eax
			dec		eax
		.endif
		mov		sinf.nMax,eax
		mov		eax,[ebx].RACC.topindex
		mov		sinf.nPos,eax
		invoke SetScrollInfo,hWin,SB_VERT,addr sinf,TRUE
		invoke GetClientRect,hWin,addr rect          ; MOD  rect is changed, if scrollbar hides itself
	.endif
	retn

CodeCompleteProc endp

SkipScope proc uses esi,lpszBuff:DWORD

	mov		esi,lpszBuff
	xor		eax,eax
	.if byte ptr [esi]=='(' || byte ptr [esi]=='['
		push	ecx
		xor		ecx,ecx
		.while byte ptr [esi]
			.if byte ptr [esi]=='(' || byte ptr [esi]=='['
				inc		ecx
			.elseif byte ptr [esi]==')' || byte ptr [esi]==']'
				dec		ecx
				.break .if ZERO?
			.endif
			inc		esi
		.endw
		.if byte ptr [esi]==')' || byte ptr [esi]==']'
			inc		esi
		.endif
		pop		ecx
		mov		eax,esi
		sub		eax,lpszBuff
	.endif
	ret

SkipScope endp

ToolTipProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	rgt:DWORD
	LOCAL	style:DWORD

	mov		eax,uMsg
	.if eax==WM_PAINT
		invoke BeginPaint,hWin,addr ps
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		style,eax
		invoke SelectObject,ps.hdc,[ebx].RATT.hfont
		push	eax
		invoke CreateSolidBrush,[ebx].RATT.backcolor
		push	eax
		invoke FillRect,ps.hdc,addr ps.rcPaint,eax
		pop		eax
		invoke DeleteObject,eax
		invoke SetBkMode,ps.hdc,TRANSPARENT
		xor		eax,eax
		mov		rect.left,1
		mov		rect.top,eax
		mov		rect.right,eax
		mov		rect.bottom,eax
		.if [ebx].RATT.tti.lpszApi
			.if [ebx].RATT.tti.novr>1
				push	esi
				mov		esi,esp
				mov		eax,[ebx].RATT.tti.nsel
				inc		eax
				invoke wsprintf,offset findbuff,offset szFmt,eax,[ebx].RATT.tti.novr
				mov		esp,esi
				pop		esi
				invoke DrawText,ps.hdc,offset findbuff,-1,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
				; more space for extreme overload function
				; 34=24+10(extra space)
				add		rect.right,34
				invoke SetTextColor,ps.hdc,[ebx].RATT.textcolor
				invoke DrawText,ps.hdc,offset findbuff,-1,addr rect,DT_SINGLELINE or DT_NOPREFIX or DT_CENTER
				push	rect.right
				mov		eax,rect.left
				add		eax,9
				mov		rect.right,eax
				invoke DrawFrameControl,ps.hdc,addr rect,DFC_SCROLL,DFCS_SCROLLUP or DFCS_FLAT
				pop		rect.right
				push	rect.left
				mov		eax,rect.right
				sub		eax,9
				mov		rect.left,eax
				invoke DrawFrameControl,ps.hdc,addr rect,DFC_SCROLL,DFCS_SCROLLDOWN or DFCS_FLAT
				pop		rect.left
				mov		eax,rect.right
				; 6=1+5(space between api and graph)
				add		eax,6
				mov		rect.left,eax
			.endif
			invoke SetTextColor,ps.hdc,[ebx].RATT.apicolor
			invoke DrawText,ps.hdc,[ebx].RATT.tti.lpszApi,-1,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
			invoke DrawText,ps.hdc,[ebx].RATT.tti.lpszApi,-1,addr rect,DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
			mov		eax,rect.right
			mov		rect.left,eax
			invoke SetTextColor,ps.hdc,[ebx].RATT.textcolor
			test	style,STYLE_USEPARANTESES
			.if ZERO?
				mov		rgt,','
			.else
				mov		rgt,'('
			.endif
			invoke DrawText,ps.hdc,addr rgt,1,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
			invoke DrawText,ps.hdc,addr rgt,1,addr rect,DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
			mov		eax,rect.right
			mov		rect.left,eax
			mov		rgt,eax
			.if [ebx].RATT.tti.lpszParam
				invoke SetTextColor,ps.hdc,[ebx].RATT.textcolor
				invoke DrawText,ps.hdc,[ebx].RATT.tti.lpszParam,-1,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
				invoke DrawText,ps.hdc,[ebx].RATT.tti.lpszParam,-1,addr rect,DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
				.if [ebx].RATT.nlen
					invoke SetTextColor,ps.hdc,[ebx].RATT.hilitecolor
					.if [ebx].RATT.nleft
						invoke DrawText,ps.hdc,[ebx].RATT.tti.lpszParam,[ebx].RATT.nleft,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
					.else
						mov		eax,rect.left
						mov		rect.right,eax
					.endif
					mov		edx,[ebx].RATT.tti.lpszParam
					add		edx,[ebx].RATT.nleft
					invoke TextOut,ps.hdc,rect.right,0,edx,[ebx].RATT.nlen
				.endif
			.endif
			mov		eax,rgt
			mov		rect.left,eax
			test	style,STYLE_USEPARANTESES
			.if !ZERO?
				invoke SetTextColor,ps.hdc,[ebx].RATT.textcolor
				invoke DrawText,ps.hdc,[ebx].RATT.tti.lpszParam,-1,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
				mov		eax,rect.right
				mov		rect.left,eax
				mov		rgt,')'
				invoke DrawText,ps.hdc,addr rgt,1,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
				invoke DrawText,ps.hdc,addr rgt,1,addr rect,DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
				mov		eax,rect.right
				mov		rect.left,eax
			.endif
			mov		eax,[ebx].RATT.tti.lpszRetType
			.if eax
				.if byte ptr [eax]
					add		rect.left,5
					invoke SetTextColor,ps.hdc,[ebx].RATT.apicolor
					invoke DrawText,ps.hdc,[ebx].RATT.tti.lpszRetType,-1,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
					invoke DrawText,ps.hdc,[ebx].RATT.tti.lpszRetType,-1,addr rect,DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
				.endif
			.endif
			.if [ebx].RATT.tti.lpszDesc
				mov		rect.left,1
				mov		eax,rect.bottom
				mov		rect.top,eax
				mov		rect.bottom,99
				mov		rect.right,512
				invoke SetTextColor,ps.hdc,[ebx].RATT.textcolor
				invoke DrawText,ps.hdc,[ebx].RATT.tti.lpszDesc,-1,addr rect,DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
			.endif
		.endif
		pop		eax
		invoke SelectObject,ps.hdc,eax
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
	.elseif eax==WM_CREATE
		invoke GetProcessHeap
		invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof RATT
		mov		ebx,eax
		invoke SetWindowLong,hWin,0,ebx
		mov		[ebx].RATT.backcolor,0C0FFFFh
		mov		[ebx].RATT.textcolor,0
		mov		[ebx].RATT.apicolor,60h
		mov		[ebx].RATT.hilitecolor,0C00000h
		xor		eax,eax
	.elseif eax==WM_SETFONT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		mov		[ebx].RATT.hfont,eax
		xor		eax,eax
	.elseif eax==WM_ACTIVATE
		xor		eax,eax
	.elseif eax==WM_MOUSEACTIVATE
		mov		eax,MA_NOACTIVATE
	.elseif eax==WM_SETCURSOR
		xor		eax,eax
	.elseif eax==TTM_SETITEM
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		style,eax
		mov		edx,lParam
		mov		eax,[edx].TTITEM.lpszApi
		mov		[ebx].RATT.tti.lpszApi,eax
		mov		eax,[edx].TTITEM.lpszParam
		mov		[ebx].RATT.tti.lpszParam,eax
		mov		eax,[edx].TTITEM.lpszRetType
		mov		[ebx].RATT.tti.lpszRetType,eax
		mov		eax,[edx].TTITEM.lpszDesc
		mov		[ebx].RATT.tti.lpszDesc,eax
		mov		eax,[edx].TTITEM.nitem
		mov		[ebx].RATT.tti.nitem,eax
		mov		eax,[edx].TTITEM.novr
		mov		[ebx].RATT.tti.novr,eax
		mov		eax,[edx].TTITEM.nsel
		mov		[ebx].RATT.tti.nsel,eax
		mov		eax,[edx].TTITEM.nwidth
		mov		[ebx].RATT.tti.nwidth,eax
		mov		edx,[ebx].RATT.tti.lpszParam
		mov		ecx,[ebx].RATT.tti.nitem
		.if !ecx
			.while byte ptr [edx]!=',' && byte ptr [edx]
				invoke SkipScope,edx
				.if eax
					lea		edx,[edx+eax]
				.else
					inc		edx
				.endif
			.endw
			mov		[ebx].RATT.nleft,0
			mov		eax,edx
			sub		eax,[ebx].RATT.tti.lpszParam
			mov		[ebx].RATT.nlen,eax
		.else
			.while ecx
				.while byte ptr [edx]!=',' && byte ptr [edx]
					invoke SkipScope,edx
					.if eax
						lea		edx,[edx+eax]
					.else
						inc		edx
					.endif
				.endw
				.if byte ptr [edx]==','
					inc		edx
				.endif
				dec		ecx
				.break .if !byte ptr [edx]
			.endw
			mov		eax,edx
			sub		eax,[ebx].RATT.tti.lpszParam
			mov		[ebx].RATT.nleft,eax
			.while byte ptr [edx]!=',' && byte ptr [edx]
				invoke SkipScope,edx
				.if eax
					lea		edx,[edx+eax]
				.else
					inc		edx
				.endif
			.endw
			mov		eax,edx
			sub		eax,[ebx].RATT.tti.lpszParam
			sub		eax,[ebx].RATT.nleft
			mov		[ebx].RATT.nlen,eax
		.endif
		invoke GetDC,hWin
		mov		ps.hdc,eax
		invoke SelectObject,ps.hdc,[ebx].RATT.hfont
		push	eax
		xor		eax,eax
		mov		rect.left,eax
		mov		rect.top,eax
		mov		rect.right,eax
		mov		rect.bottom,eax
		.if [ebx].RATT.tti.novr>1
			push	esi
			mov		esi,esp
			mov		eax,[ebx].RATT.tti.nsel
			inc		eax
			invoke wsprintf,offset findbuff,offset szFmt,eax,[ebx].RATT.tti.novr
			mov		esp,esi
			pop		esi
			invoke DrawText,ps.hdc,offset findbuff,-1,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
			mov		eax,rect.right
			; 40=25+10(extra space)+5(space between api and graph)
			add		eax,40
			mov		rect.left,eax
		.endif
		.if [ebx].RATT.tti.lpszApi
			invoke DrawText,ps.hdc,[ebx].RATT.tti.lpszApi,-1,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
			mov		eax,rect.right
			mov		rect.left,eax
			test	style,STYLE_USEPARANTESES
			.if ZERO?
				mov		rgt,','
			.else
				mov		rgt,'('
			.endif
			invoke DrawText,ps.hdc,addr rgt,1,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
			mov		eax,rect.right
			mov		rect.left,eax
		.endif
		.if [ebx].RATT.tti.lpszParam && [ebx].RATT.nleft
			invoke DrawText,ps.hdc,[ebx].RATT.tti.lpszParam,[ebx].RATT.nleft,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
		.endif
		mov		eax,rect.right
		mov		rgt,eax
		.if [ebx].RATT.tti.lpszParam
			invoke DrawText,ps.hdc,[ebx].RATT.tti.lpszParam,-1,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
			mov		eax,rect.right
			mov		rect.left,eax
			test	style,STYLE_USEPARANTESES
			.if !ZERO?
				push	rgt
				mov		rgt,')'
				invoke DrawText,ps.hdc,addr rgt,1,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
				mov		eax,rect.right
				mov		rect.left,eax
				pop		rgt
			.endif
		.endif
		mov		eax,[ebx].RATT.tti.lpszRetType
		.if eax
			.if byte ptr [eax]
				add		rect.left,5
				invoke DrawText,ps.hdc,[ebx].RATT.tti.lpszRetType,-1,addr rect,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
			.endif
		.endif
		add		rect.right,4
		mov		edx,lParam
		.if [edx].TTITEM.lpszDesc
			mov		rect1.left,4
			mov		rect1.top,0
			invoke DrawText,ps.hdc,[ebx].RATT.tti.lpszDesc,-1,addr rect1,DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX or DT_LEFT
			mov		eax,rect1.right
			.if eax>rect.right
				mov		rect.right,eax
			.endif
			shl		rect.bottom,1
		.endif
		add		rect.bottom,3
		pop		eax
		invoke SelectObject,ps.hdc,eax
		invoke ReleaseDC,hWin,ps.hdc
		invoke SetWindowPos,hWin,0,0,0,rect.right,rect.bottom,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOZORDER
		mov		eax,rect.right
		mov		[ebx].RATT.tti.nwidth,eax
		mov		eax,rgt
	.elseif eax==TTM_GETCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,lParam
		mov		eax,[ebx].RATT.backcolor
		mov		[edx].TT_COLOR.back,eax
		mov		eax,[ebx].RATT.textcolor
		mov		[edx].TT_COLOR.text,eax
		mov		eax,[ebx].RATT.apicolor
		mov		[edx].TT_COLOR.api,eax
		mov		eax,[ebx].RATT.hilitecolor
		mov		[edx].TT_COLOR.hilite,eax
		xor		eax,eax
	.elseif eax==TTM_SETCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,lParam
		mov		eax,[edx].TT_COLOR.back
		mov		[ebx].RATT.backcolor,eax
		mov		eax,[edx].TT_COLOR.text
		mov		[ebx].RATT.textcolor,eax
		mov		eax,[edx].TT_COLOR.api
		mov		[ebx].RATT.apicolor,eax
		mov		eax,[edx].TT_COLOR.hilite
		mov		[ebx].RATT.hilitecolor,eax
		invoke InvalidateRect,hWin,NULL,TRUE
		xor		eax,eax
	.elseif eax==TTM_GETITEMNAME
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,lParam
		push	esi
		mov		esi,[edx].TTITEM.lpszParam
		mov		ecx,[edx].TTITEM.nitem
		.while ecx
			.while byte ptr [esi]!=',' && byte ptr [esi]
				invoke SkipScope,esi
				.if eax
					lea		esi,[esi+eax]
				.else
					inc		esi
				.endif
			.endw
			.if byte ptr [esi]==','
				inc		esi
			.endif
			dec		ecx
			.break .if !byte ptr [esi]
		.endw
		.while byte ptr [esi]==' '
			inc		esi
		.endw
		invoke lstrcmpi,esi,offset szByVal
		.if eax
			invoke lstrcmpi,esi,offset szByRef
		.endif
		.if !eax
			add		esi,6
		.endif
		.while byte ptr [esi]==' '
			inc		esi
		.endw
		mov		ecx,offset itembuff
		.while byte ptr [esi]
			mov		al,[esi]
			.break .if al==',' || al==':' || al=='(' || al=='[' || al==' '
			mov		[ecx],al
			inc		esi
			inc		ecx
		.endw
		mov		byte ptr [ecx],0
		mov		eax,offset itembuff
		pop		esi
	.elseif eax==TTM_GETITEMTYPE
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,lParam
		push	esi
		mov		esi,[edx].TTITEM.lpszParam
		mov		ecx,[edx].TTITEM.nitem
		.while ecx
			.while byte ptr [esi]!=',' && byte ptr [esi]
				invoke SkipScope,esi
				.if eax
					lea		esi,[esi+eax]
				.else
					inc		esi
				.endif
			.endw
			.if byte ptr [esi]==','
				inc		esi
			.endif
			dec		ecx
			.break .if !byte ptr [esi]
		.endw
		.while byte ptr [esi]==' '
			inc		esi
		.endw
		invoke lstrcmpi,esi,offset szByVal
		.if eax
			invoke lstrcmpi,esi,offset szByRef
		.endif
		.if !eax
			add		esi,6
		.endif
		.while byte ptr [esi]==' '
			inc		esi
		.endw
		mov		ecx,offset itembuff
		.while byte ptr [esi]!=',' && byte ptr [esi]!=':' && byte ptr [esi]
			invoke SkipScope,esi
			.if eax
				lea		esi,[esi+eax]
			.else
				inc		esi
			.endif
		.endw
		.if byte ptr [esi]==':'
			inc		esi
			.while byte ptr [esi]
				mov		al,[esi]
				.break .if al==',' || al=='(' || al=='[' || al==' '
				mov		[ecx],al
				inc		esi
				inc		ecx
			.endw
		.endif
		mov		byte ptr [ecx],0
		mov		eax,offset itembuff
		pop		esi
	.elseif eax==TTM_SCREENFITS
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GetSystemMetrics,SM_CXFULLSCREEN
		mov		ecx,eax
		mov		edx,lParam
		mov		eax,[edx] ;pt.x
		.if sdword ptr eax<0
			xor		eax,eax
			mov		[edx],eax
		.endif
		add		eax,[ebx].RATT.tti.nwidth
		.if eax>ecx
			sub		ecx,[ebx].RATT.tti.nwidth
			mov		[edx],ecx
		.endif
		xor		eax,eax
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

ToolTipProc endp

IFDEF DLL
	include RACodeCompleteDll.asm
ENDIF

End
