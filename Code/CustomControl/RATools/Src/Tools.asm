
;ToolCldWndProc			PROTO :DWORD,:DWORD,:DWORD,:DWORD

.code

Do_ToolFloat proc uses esi,lpTool:DWORD
	LOCAL   tW:DWORD
	LOCAL   tH:DWORD

	mov     esi,lpTool
	mov     eax,[esi].TOOL.dck.fr.right
	sub     eax,[esi].TOOL.dck.fr.left
	mov     tW,eax
	mov     eax,[esi].TOOL.dck.fr.bottom
	sub     eax,[esi].TOOL.dck.fr.top
	mov     tH,eax
	invoke CreateWindowEx,WS_EX_TOOLWINDOW,addr szToolClass,[esi].TOOL.dck.Caption,
			WS_CAPTION or WS_SIZEBOX or WS_SYSMENU or WS_POPUP or WS_CLIPCHILDREN or WS_CLIPSIBLINGS,
			[esi].TOOL.dck.fr.left,[esi].TOOL.dck.fr.top,tW,tH,hWnd,0,hInstance,esi
	mov     [esi].TOOL.hWin,eax
	ret

Do_ToolFloat endp

ToolDrawRect proc uses esi edi,lpRect:DWORD,nFun:DWORD,nInx:DWORD
	LOCAL	ht:DWORD
	LOCAL	wt:DWORD
	LOCAL	rect:RECT

	invoke CopyRect,addr rect,lpRect
	lea		esi,rect
	sub		[esi].RECT.right,1
	mov		eax,[esi].RECT.right
	sub		eax,[esi].RECT.left
	jns		@f
	mov		eax,[esi].RECT.right
	xchg	eax,[esi].RECT.left
	mov		[esi].RECT.right,eax
	sub		eax,[esi].RECT.left
	dec		[esi].RECT.left
	inc		[esi].RECT.right
	inc		eax
  @@:
	mov		wt,eax
	sub		[esi].RECT.bottom,1
	mov		eax,[esi].RECT.bottom
	sub		eax,[esi].RECT.top
	jns		@f
	mov		eax,[esi].RECT.bottom
	xchg	eax,[esi].RECT.top
	mov		[esi].RECT.bottom,eax
	sub		eax,[esi].RECT.top
	dec		[esi].RECT.top
	inc		[esi].RECT.bottom
	inc		eax
  @@:
	mov		ht,eax
	dec		[esi].RECT.right
	dec		[esi].RECT.bottom
	mov		edi,nInx
	shl		edi,4
	add		edi,offset hRect
	.if nFun==0
		invoke CreateWindowEx,0,addr szStatic,0,WS_POPUP or SS_BLACKRECT,[esi].RECT.left,[esi].RECT.top,wt,2,hWnd,0,hInstance,0
		mov		[edi],eax
		invoke ShowWindow,eax,SW_SHOWNOACTIVATE
		invoke CreateWindowEx,0,addr szStatic,0,WS_POPUP or SS_BLACKRECT,[esi].RECT.right,[esi].RECT.top,2,ht,hWnd,0,hInstance,0
		mov		[edi+4],eax
		invoke ShowWindow,eax,SW_SHOWNOACTIVATE
		invoke CreateWindowEx,0,addr szStatic,0,WS_POPUP or SS_BLACKRECT,[esi].RECT.left,[esi].RECT.bottom,wt,2,hWnd,0,hInstance,0
		mov		[edi+8],eax
		invoke ShowWindow,eax,SW_SHOWNOACTIVATE
		invoke CreateWindowEx,0,addr szStatic,0,WS_POPUP or SS_BLACKRECT,[esi].RECT.left,[esi].RECT.top,2,ht,hWnd,0,hInstance,0
		mov		[edi+12],eax
		invoke ShowWindow,eax,SW_SHOWNOACTIVATE
	.elseif nFun==1
		invoke MoveWindow,[edi],[esi].RECT.left,[esi].RECT.top,wt,3,TRUE
		invoke MoveWindow,[edi+4],[esi].RECT.right,[esi].RECT.top,3,ht,TRUE
		invoke MoveWindow,[edi+8],[esi].RECT.left,[esi].RECT.bottom,wt,3,TRUE
		invoke MoveWindow,[edi+12],[esi].RECT.left,[esi].RECT.top,3,ht,TRUE
	.elseif nFun==2
		invoke DestroyWindow,[edi]
		mov		dword ptr [edi],0
		invoke DestroyWindow,[edi+4]
		mov		dword ptr [edi+4],0
		invoke DestroyWindow,[edi+8]
		mov		dword ptr [edi+8],0
		invoke DestroyWindow,[edi+12]
		mov		dword ptr [edi+12],0
	.endif
	ret

ToolDrawRect endp

Rotate proc uses esi edi,hBmpDest:DWORD,hBmpSrc:DWORD,x:DWORD,y:DWORD,nRotate:DWORD
	LOCAL	bmd:BITMAP
	LOCAL	nbitsd:DWORD
	LOCAL	hmemd:DWORD
	LOCAL	bms:BITMAP
	LOCAL	nbitss:DWORD
	LOCAL	hmems:DWORD

	;Get info on destination bitmap
	invoke GetObject,hBmpDest,sizeof BITMAP,addr bmd
	mov		eax,bmd.bmWidthBytes
	mov		edx,bmd.bmHeight
	mul		edx
	mov		nbitsd,eax
	;Allocate memory for destination bitmap bits
	invoke GlobalAlloc,GMEM_FIXED,nbitsd
	mov		hmemd,eax
	;Get the destination bitmap bits
	invoke GetBitmapBits,hBmpDest,nbitsd,hmemd
	;Get info on source bitmap
	invoke GetObject,hBmpSrc,sizeof BITMAP,addr bms
	mov		eax,bms.bmWidthBytes
	mov		edx,bms.bmHeight
	mul		edx
	mov		nbitss,eax
	;Allocate memory for source bitmap bits
	invoke GlobalAlloc,GMEM_FIXED,nbitss
	mov		hmems,eax
	;Get the source bitmap bits
	invoke GetBitmapBits,hBmpSrc,nbitss,hmems
	;Copy the pixels one by one
	xor		edx,edx
	.while edx<bms.bmHeight
		xor		ecx,ecx
		.while ecx<bms.bmWidth
			call	CopyPix
			inc		ecx
		.endw
		inc		edx
	.endw
	;Copy back the destination bitmap bits
	invoke SetBitmapBits,hBmpDest,nbitsd,hmemd
	;Free allocated memory
	invoke GlobalFree,hmems
	invoke GlobalFree,hmemd
	ret

CopyPix:
	push	ecx
	push	edx
	mov		esi,hmems
	push	edx
	mov		eax,bms.bmWidthBytes
	mul		edx
	add		esi,eax
	movzx	eax,bms.bmBitsPixel
	shr		eax,3
	mul		ecx
	add		esi,eax
	pop		edx
	mov		eax,nRotate
	.if eax==1
		;Rotate 90 degrees
		sub		edx,bms.bmHeight
		neg		edx
		xchg	ecx,edx
	.elseif eax==2
		;Rotate 180 degrees
		sub		edx,bms.bmHeight
		neg		edx
		sub		ecx,bms.bmWidth
		neg		ecx
	.elseif eax==3
		;Rotate 270 degrees
		sub		ecx,bms.bmWidth
		neg		ecx
		xchg	ecx,edx
	.endif
	;Add the destination offsets
	add		ecx,x
	add		edx,y
	.if  ecx<bmd.bmWidth && edx<bmd.bmHeight
		;Calculate destination adress
		mov		edi,hmemd
		mov		eax,bmd.bmWidthBytes
		mul		edx
		add		edi,eax
		movzx	eax,bmd.bmBitsPixel
		shr		eax,3
		xchg	eax,ecx
		mul		ecx
		add		edi,eax
		;And copy the byte(s)
		rep movsb
	.endif
	pop		edx
	pop		ecx
	retn

Rotate endp

GetToolPtr proc

	mov     edx,offset ToolPool-sizeof TOOLPOOL
  @@:
	add     edx,sizeof TOOLPOOL
	cmp     [edx].TOOLPOOL.hCld,0
	jz      @f
	cmp     eax,[edx].TOOLPOOL.hCld
	jnz     @b
	mov     edx,[edx].TOOLPOOL.lpTool
	ret
  @@:
	xor     edx,edx
	ret

GetToolPtr endp

ToolHitTest proc uses ebx,lpRect:DWORD,lpPoint:DWORD
	
	push    edx
	mov     edx,lpPoint
	mov     ebx,lpRect
	mov     eax,[edx].POINT.x
	mov		edx,[edx].POINT.y
	.if sdword ptr eax>=[ebx].RECT.left && sdword ptr eax<[ebx].RECT.right && sdword ptr edx>=[ebx].RECT.top && sdword ptr edx<[ebx].RECT.bottom
		mov     eax,TRUE
	.else
		xor		eax,eax
	.endif
	pop     edx
	ret

ToolHitTest endp

GetToolPtrID proc

	push	edx
	mov     edx,offset ToolPool-sizeof TOOLPOOL
  @@:
	add     edx,sizeof TOOLPOOL
	cmp     [edx].TOOLPOOL.hCld,0
	je      @f
	push	edx
	mov     edx,dword ptr [edx].TOOLPOOL.lpTool
	cmp     eax,[edx].TOOL.dck.ID
	pop		edx
	jne     @b
	mov     eax,dword ptr [edx].TOOLPOOL.lpTool
	pop		edx
	ret
  @@:
	xor     eax,eax
	pop		edx
	ret

GetToolPtrID endp

IsOnTool proc uses ebx,lpPt:DWORD

	push	ecx
	push	edx
	mov		ebx,lpPt
	mov		edx,offset ToolData
  @@:
	mov		eax,[edx].TOOL.dck.ID
	.if eax
		mov		eax,[edx].TOOL.dck.Visible
		and		eax,[edx].TOOL.dck.Docked
		.if eax
			mov		eax,[edx].TOOL.dck.IsChild
			.if !eax
				mov		eax,[ebx].POINT.x
				.if sdword ptr eax>[edx].TOOL.dr.left && sdword ptr eax<[edx].TOOL.dr.right
					mov		eax,[ebx].POINT.y
					.if sdword ptr eax>[edx].TOOL.dr.top && sdword ptr eax<[edx].TOOL.dr.bottom
						mov		eax,[edx].TOOL.dck.ID
						jmp		@f
					.endif
				.endif
			.endif
		.endif
		add		edx,sizeof TOOL
		jmp		@b
	.endif
  @@:
	pop		edx
	pop		ecx
	ret

IsOnTool endp

SetIsChildTo proc nID:DWORD,nToID:DWORD

	push	edx
	mov		edx,offset ToolData
  @@:
	mov		eax,[edx].TOOL.dck.ID
	.if eax
		mov		eax,[edx].TOOL.dck.IsChild
		.if eax==nID
			mov		eax,nToID
			mov		[edx].TOOL.dck.IsChild,eax
		.endif
		add		edx,sizeof TOOL
		jmp		@b
	.endif
	pop		edx
	ret

SetIsChildTo endp

ToolMsg proc uses ebx esi,hCld:DWORD,uMsg:UINT,lpRect:DWORD
	LOCAL   rect:RECT
	LOCAL   dWidth:DWORD
	LOCAL   dHeight:DWORD
	LOCAL   hWin:HWND
	LOCAL   hDC:HDC
	LOCAL   hCur:DWORD
	LOCAL   parPosition:DWORD
	LOCAL	pardWidth:DWORD
	LOCAL	pardHeight:DWORD
	LOCAL	parDocked:DWORD
	LOCAL	pt:POINT
	LOCAL	rect2:RECT
	LOCAL	sDC:HDC
	LOCAL	hBmp1:DWORD
	LOCAL	hBmp2:DWORD

	mov     eax,hCld
	call    GetToolPtr
	mov		esi,edx
	mov     ebx,lpRect
	mov		eax,uMsg
	.if eax==TLM_MOUSEMOVE
		mov     [esi].TOOL.dCurFlag,0
		mov     hCur,0
		.if [esi].TOOL.dck.Visible && [esi].TOOL.dck.Docked && !ToolResize
			;Check if mouse is on this tools caption, close button or sizeing boarder and set cursor
			mov     hCur,0
			invoke ToolHitTest,addr [esi].TOOL.rr,ebx
			.if eax
				;Cursor on resize bar
				mov     [esi].TOOL.dCurFlag,TL_ONRESIZE
				mov     eax,[esi].TOOL.dck.Position
				.if eax==TL_TOP || eax==TL_BOTTOM
					mov		eax,hSplitCurH
					mov     hCur,eax
				.else
					mov		eax,hSplitCurV
					mov     hCur,eax
				.endif
			.else
				invoke ToolHitTest,addr [esi].TOOL.cr,ebx
				.if eax
					;Cursor on caption
					mov     hCur,IDC_HAND
					mov     [esi].TOOL.dCurFlag,TL_ONCAPTION
					invoke ToolHitTest,addr [esi].TOOL.br,ebx
					.if eax
						;Cursor on close button
						mov     hCur,IDC_ARROW
						mov     [esi].TOOL.dCurFlag,TL_ONCLOSE
					.endif
					invoke LoadCursor,0,hCur
					mov		hCur,eax
				.endif
			.endif
			mov     eax,hCur
			.if eax
				mov     MoveCur,eax
				invoke SetCursor,eax
				mov     eax,TRUE
				ret
			.endif
		.endif
	.elseif eax==TLM_MOVETEST
		call ToolMov
	.elseif eax==TLM_SETTBR
		mov		eax,[esi].TOOL.dck.ID
		.if eax==1
;			mov		eax,IDM_VIEW_PROJECTBROWSER
;		.elseif eax==2
;			mov		eax,IDM_VIEW_OUTPUTWINDOW
;		.elseif eax==3
;			mov		eax,IDM_VIEW_TOOLBOX
;		.elseif eax==4
;			mov		eax,IDM_VIEW_PROPERTIES
;		.elseif eax==5
;			mov		eax,0
		.endif
		.if eax
;			invoke SendMessage,hToolBar,TB_CHECKBUTTON,eax,[esi].TOOL.Visible
		.endif
		mov     eax,TRUE
		ret
	.elseif eax==TLM_LBUTTONDOWN
		.if [esi].TOOL.dCurFlag
			.if [esi].TOOL.dCurFlag==TL_ONCLOSE
				mov     [esi].TOOL.dck.Visible,FALSE
				invoke ToolMsg,hCld,TLM_SETTBR,0
				invoke SendMessage,hWnd,WM_SIZE,0,0
				mov     eax,TRUE
				ret
			.else
				invoke SetFocus,hCld
				mov		pt.x,0
				mov		pt.y,0
				invoke ClientToScreen,hWnd,addr pt
				invoke CopyRect,addr DrawRect,addr [esi].TOOL.dr
				mov		eax,pt.x
				dec		eax
				add		DrawRect.left,eax
				inc		eax
				inc		eax
				add		DrawRect.right,eax
				mov		eax,pt.y
				add		DrawRect.top,eax
				inc		eax
				add		DrawRect.bottom,eax
				invoke CopyRect,addr MoveRect,addr DrawRect
				invoke SetCursor,MoveCur
				invoke SetCapture,hWnd
				.if [esi].TOOL.dCurFlag==TL_ONRESIZE
					mov     eax,hCld
					mov     ToolResize,eax
					invoke ShowWindow,hSize,SW_SHOWNOACTIVATE
					mov     eax,TRUE
					ret
				.elseif [esi].TOOL.dCurFlag==TL_ONCAPTION
					mov     eax,hCld
					mov     ToolMove,eax
					invoke ToolDrawRect,addr DrawRect,0,0
					mov     eax,TRUE
					ret
				.endif
			.endif
		.endif
	.elseif eax==TLM_LBUTTONUP
		invoke ReleaseCapture
		.if ToolResize
			mov     edx,[esi].TOOL.dck.Position
			.if edx==TL_BOTTOM || edx==TL_TOP
				mov     eax,DrawRect.bottom
				sub     eax,DrawRect.top
				sub		eax,1
				mov     [esi].TOOL.dck.dHeight,eax
			.elseif edx==TL_LEFT || edx==TL_RIGHT
				mov     eax,DrawRect.right
				sub     eax,DrawRect.left
				sub		eax,2
				.if edx==TL_RIGHT
					dec		eax
				.endif
				mov     [esi].TOOL.dck.dWidth,eax
			.endif
			invoke ShowWindow,hSize,SW_HIDE
		.elseif ToolMove
			invoke ToolDrawRect,addr DrawRect,2,0
			call ToolMov
			.if ![esi].TOOL.dck.Docked
				mov		eax,FloatRect.right
				sub		eax,FloatRect.left
				mov		edx,FloatRect.bottom
				sub		edx,FloatRect.top
				invoke MoveWindow,[esi].TOOL.hWin,FloatRect.left,FloatRect.top,eax,edx,TRUE
			.endif
		.endif
		invoke SendMessage,hWnd,WM_SIZE,0,0
		invoke SetFocus,hCld
	.elseif eax==TLM_DOCKING
		;Docked/floating
		xor     [esi].TOOL.dck.Docked,TRUE
		.if ![esi].TOOL.dck.Visible
			invoke ToolMsg,hCld,TLM_HIDE,lpRect
		.else
			invoke SendMessage,hWnd,WM_SIZE,0,0
		.endif
		mov     eax,TRUE
		ret
	.elseif eax==TLM_HIDE
		;Hide/show
		xor     [esi].TOOL.dck.Visible,TRUE
		invoke ToolMsg,hCld,TLM_SETTBR,0
		invoke SendMessage,hWnd,WM_SIZE,0,0
		invoke InvalidateRect,hClient,NULL,TRUE
		mov     eax,TRUE
		ret
	.elseif eax==TLM_CAPTION
		;Draw the tools caption
		.if [esi].TOOL.dck.Visible && [esi].TOOL.dck.Docked
			;Draw caption background
			invoke GetDC,hWnd
			mov     hDC,eax
			invoke GetStockObject,DEFAULT_GUI_FONT
			invoke SelectObject,hDC,eax
			push	eax
			invoke FillRect,hDC,addr [esi].TOOL.tr,COLOR_BTNFACE+1
			invoke SetBkMode,hDC,TRANSPARENT
			;Draw resizing bar
			invoke FillRect,hDC,addr [esi].TOOL.rr,COLOR_BTNFACE+1
			;Draw Caption
			.if [esi].TOOL.dFocus
				invoke GetSysColor,COLOR_CAPTIONTEXT
				invoke SetTextColor,hDC,eax
				mov		eax,COLOR_ACTIVECAPTION+1
			.else
				invoke GetSysColor,COLOR_INACTIVECAPTIONTEXT
				invoke SetTextColor,hDC,eax
				mov		eax,COLOR_INACTIVECAPTION+1
			.endif
			mov		ebx,eax
			invoke FillRect,hDC,addr [esi].TOOL.cr,eax
			mov		eax,[esi].TOOL.dck.IsChild
			xor		ecx,ecx
			.if eax
				invoke GetToolPtrID
				mov		edx,eax
				mov		ecx,[edx].TOOL.dck.Visible
				and		ecx,[edx].TOOL.dck.Docked
			.endif
			mov		eax,[esi].TOOL.dck.Position
			.if fRightCaption
				.if ((eax==TL_TOP || eax==TL_BOTTOM) && !ecx) || (eax==TL_RIGHT && ecx)
					mov		eax,[esi].TOOL.dck.Caption
					mov		al,byte ptr [eax]
					.if al
						dec		ebx
						invoke GetSysColor,ebx
						mov		ebx,eax
						;Create a memory DC for the source
						invoke CreateCompatibleDC,hDC
						mov		sDC,eax
						invoke GetTextColor,hDC
						invoke SetTextColor,sDC,eax
						invoke GetStockObject,DEFAULT_GUI_FONT
						invoke SelectObject,sDC,eax
						push	eax
						;Get size of text to draw
						mov		rect2.left,0
						mov		rect2.top,0
						mov		rect2.right,0
						mov		rect2.bottom,0
						invoke DrawText,sDC,[esi].TOOL.dck.Caption,-1,addr rect2,DT_CALCRECT or DT_SINGLELINE or DT_LEFT or DT_TOP
						;Create a bitmap for the rotated text
						invoke CreateCompatibleBitmap,hDC,rect2.bottom,rect2.right
						mov		hBmp1,eax
						;Create a bitmap for the text
						invoke CreateCompatibleBitmap,hDC,rect2.right,rect2.bottom
						mov		hBmp2,eax
						;and select it into source DC
						invoke SelectObject,sDC,hBmp2
						push	eax
						invoke SetBkColor,sDC,ebx
						;Draw the text
						invoke DrawText,sDC,[esi].TOOL.dck.Caption,-1,addr rect2,DT_SINGLELINE or DT_LEFT or DT_TOP
						;Rotate the bitmap
						invoke Rotate,hBmp1,hBmp2,0,0,1
						pop		eax
						invoke SelectObject,sDC,eax
						;Delete created source bitmap
						invoke DeleteObject,eax
						invoke SelectObject,sDC,hBmp1
						push	eax
						;Blit the destination bitmap onto window bitmap
						mov		eax,[esi].TOOL.cr.top
						inc		eax
						mov		edx,[esi].TOOL.cr.left
						dec		edx
						invoke BitBlt,hDC,edx,eax,rect2.bottom,rect2.right,sDC,0,0,SRCCOPY
						pop		eax
						invoke SelectObject,sDC,eax
						;Delete created source bitmap
						invoke DeleteObject,eax
						pop		eax
						invoke SelectObject,sDC,eax
						invoke DeleteDC,sDC
					.endif
				.else
					dec		[esi].TOOL.cr.top
					inc		[esi].TOOL.cr.left
					invoke DrawText,hDC,[esi].TOOL.dck.Caption,-1,addr [esi].TOOL.cr,0
					inc		[esi].TOOL.cr.top
					dec		[esi].TOOL.cr.left
				.endif
			.else
				dec		[esi].TOOL.cr.top
				inc		[esi].TOOL.cr.left
				invoke DrawText,hDC,[esi].TOOL.dck.Caption,-1,addr [esi].TOOL.cr,0
				inc		[esi].TOOL.cr.top
				dec		[esi].TOOL.cr.left
			.endif
			;Draw close button
			invoke DrawFrameControl,hDC,addr [esi].TOOL.br,DFC_CAPTION,DFCS_CAPTIONCLOSE
			invoke ReleaseDC,hWnd,hDC
			pop		eax
			invoke SelectObject,hDC,eax
		.endif
	.elseif eax==TLM_REDRAW
		;Hide/Show floating/docked window
		.if [esi].TOOL.dck.Visible
			.if [esi].TOOL.dck.Docked
				;Hide the floating form
				invoke ShowWindow,[esi].TOOL.hWin,SW_HIDE
				;Make the mdi frame the parent
				invoke SetParent,[esi].TOOL.hCld,hWnd
				mov     eax,[esi].TOOL.wr.right
				sub     eax,[esi].TOOL.wr.left
				mov     dWidth,eax
				mov     eax,[esi].TOOL.wr.bottom
				sub     eax,[esi].TOOL.wr.top
				mov     dHeight,eax
				invoke MoveWindow,[esi].TOOL.hCld,[esi].TOOL.wr.left,[esi].TOOL.wr.top,dWidth,dHeight,TRUE
				invoke ShowWindow,[esi].TOOL.hCld,SW_SHOWNOACTIVATE
			.else
				;Show the floating window
				invoke SetParent,[esi].TOOL.hCld,[esi].TOOL.hWin
				invoke GetClientRect,[esi].TOOL.hWin,addr rect
				invoke MoveWindow,[esi].TOOL.hCld,rect.left,rect.top,rect.right,rect.bottom,FALSE
				invoke ShowWindow,[esi].TOOL.hWin,SW_SHOWNOACTIVATE
				invoke ShowWindow,[esi].TOOL.hCld,SW_SHOWNOACTIVATE
			.endif
		.else
			.if [esi].TOOL.dck.Docked
				;Hide the floating form
				invoke ShowWindow,[esi].TOOL.hWin,SW_HIDE
				;Hide docked window
				invoke ShowWindow,[esi].TOOL.hCld,SW_HIDE
			.else
				;Hide the floating window
				invoke ShowWindow,[esi].TOOL.hCld,SW_HIDE
				invoke ShowWindow,[esi].TOOL.hWin,SW_HIDE
			.endif
		.endif
	.elseif eax==TLM_ADJUSTRECT
		.if [esi].TOOL.dck.Visible && [esi].TOOL.dck.Docked
			mov		parPosition,-1
			mov		parDocked,0
			mov		eax,[esi].TOOL.dck.IsChild
			.if eax
				mov		eax,[esi].TOOL.dck.dWidth
				mov		dWidth,eax
				push	esi
				;Get parent from ID
				mov		eax,[esi].TOOL.dck.IsChild
				invoke GetToolPtrID
				mov		esi,eax
				mov		eax,[esi].TOOL.dck.Position
				mov		parPosition,eax
				mov		eax,[esi].TOOL.dck.dWidth
				mov		pardWidth,eax
				mov		eax,[esi].TOOL.dck.dHeight
				mov		pardHeight,eax
				;Is parent visible & docked
				mov		eax,[esi].TOOL.dck.Visible
				and		eax,[esi].TOOL.dck.Docked
				mov		parDocked,eax
				.if eax
					.if parPosition==TL_LEFT || parPosition==TL_RIGHT
						;Resize the tool's client rect instead
						lea		eax,[esi].TOOL.wr
						mov		lpRect,eax
						pop		eax
						push	eax
						mov		[eax].TOOL.dck.Position,TL_BOTTOM
					.else
						;Resize the tool's client, top, caption & button rect instead
						lea		eax,[esi].TOOL.wr
						mov		lpRect,eax
						mov		eax,dWidth
						.if fRightCaption
							add		[esi].TOOL.wr.right,TOTCAPHT-1
							inc		eax
							sub		[esi].TOOL.cr.left,eax
							sub		[esi].TOOL.tr.left,eax
							sub		[esi].TOOL.cr.right,eax
							sub		[esi].TOOL.tr.right,eax
							sub		[esi].TOOL.br.left,eax
							sub		[esi].TOOL.br.right,eax
						.else
							sub		[esi].TOOL.tr.right,eax
							sub		[esi].TOOL.cr.right,eax
							sub		[esi].TOOL.br.left,eax
							sub		[esi].TOOL.br.right,eax
						.endif
						pop		eax
						push	eax
						mov		[eax].TOOL.dck.Position,TL_RIGHT
					.endif
				.else
					pop		esi
					push	esi
					mov		eax,parPosition
					mov		[esi].TOOL.dck.Position,eax
					.if parPosition==TL_LEFT || parPosition==TL_RIGHT
						mov		eax,pardWidth
						mov		[esi].TOOL.dck.dWidth,eax
					.else
						mov		eax,pardHeight
						mov		[esi].TOOL.dck.dHeight,eax
					.endif
				.endif
				pop		esi
			.endif
			;Resize mdi client & calculate all the tools RECT's
			mov     ebx,lpRect
			invoke CopyRect,addr [esi].TOOL.dr,ebx
			mov     eax,[esi].TOOL.dck.Position
			.if eax==TL_LEFT
				mov     eax,[esi].TOOL.dck.dWidth
				add     [ebx].RECT.left,eax
				add		eax,[esi].TOOL.dr.left
				mov		[esi].TOOL.dr.right,eax
				call SizeRight
				call CaptionTop
			.elseif eax==TL_TOP
				mov		eax,[esi].TOOL.dck.dHeight
				add		[ebx].RECT.top,eax
				add		eax,[esi].TOOL.dr.top
				mov		[esi].TOOL.dr.bottom,eax
				call SizeBottom
				.if fRightCaption
					call CaptionRight
				.else
					call CaptionTop
				.endif
			.elseif eax==TL_RIGHT
				mov     eax,[esi].TOOL.dck.dWidth
				sub     [ebx].RECT.right,eax
				neg		eax
				add		eax,[esi].TOOL.dr.right
;				dec		eax
				mov		[esi].TOOL.dr.left,eax
				call SizeLeft
				.if [esi].TOOL.dck.IsChild && fRightCaption && parDocked
					sub     [ebx].RECT.right,TOTCAPHT
					call CaptionRight
				.else
					.if [esi].TOOL.dck.IsChild && parDocked
						sub     [esi].TOOL.dr.top,TOTCAPHT
						sub     [esi].TOOL.wr.top,TOTCAPHT
						sub     [esi].TOOL.rr.top,TOTCAPHT
					.endif
					call CaptionTop
				.endif
			.elseif eax==TL_BOTTOM
				mov     eax,[esi].TOOL.dck.dHeight
				sub     [ebx].RECT.bottom,eax
				neg		eax
				add		eax,[esi].TOOL.dr.bottom
				mov		[esi].TOOL.dr.top,eax
				call SizeTop
				.if ((parPosition==TL_LEFT || parPosition==TL_RIGHT) && parDocked) || !fRightCaption
					call CaptionTop
				.else
					call CaptionRight
				.endif
			.endif
		.endif
	.elseif eax==TLM_GETVISIBLE
		mov		eax,[esi].TOOL.dck.Visible
		ret
	.elseif eax==TLM_GETDOCKED
		mov		eax,[esi].TOOL.dck.Docked
		ret
	.elseif eax==TLM_GETSTRUCT
		mov		eax,esi
		ret
	.endif
	mov     eax,FALSE
	ret

SizeLeft:
	invoke CopyRect,addr [esi].TOOL.wr,addr [esi].TOOL.dr
	mov		eax,[esi].TOOL.wr.left
	mov		[esi].TOOL.rr.left,eax
	add		eax,RESIZEBAR
	mov		[esi].TOOL.wr.left,eax
	mov		[esi].TOOL.rr.right,eax
	mov		eax,[esi].TOOL.wr.top
	mov		[esi].TOOL.rr.top,eax
	mov		eax,[esi].TOOL.wr.bottom
	mov		[esi].TOOL.rr.bottom,eax
	retn

SizeTop:
	invoke CopyRect,addr [esi].TOOL.wr,addr [esi].TOOL.dr
	mov		eax,[esi].TOOL.wr.left
	mov		[esi].TOOL.rr.left,eax
	mov		eax,[esi].TOOL.wr.right
	mov		[esi].TOOL.rr.right,eax
	mov		eax,[esi].TOOL.wr.top
	mov		[esi].TOOL.rr.top,eax
	add		eax,RESIZEBAR
	mov		[esi].TOOL.wr.top,eax
	mov		[esi].TOOL.rr.bottom,eax
	retn

SizeRight:
	invoke CopyRect,addr [esi].TOOL.wr,addr [esi].TOOL.dr
	mov		eax,[esi].TOOL.wr.right
	mov		[esi].TOOL.rr.right,eax
	sub		eax,RESIZEBAR
	mov		[esi].TOOL.wr.right,eax
	mov		[esi].TOOL.rr.left,eax
	mov		eax,[esi].TOOL.wr.top
	mov		[esi].TOOL.rr.top,eax
	mov		eax,[esi].TOOL.wr.bottom
	mov		[esi].TOOL.rr.bottom,eax
	retn

SizeBottom:
	invoke CopyRect,addr [esi].TOOL.wr,addr [esi].TOOL.dr
	mov		eax,[esi].TOOL.wr.left
	mov		[esi].TOOL.rr.left,eax
	mov		eax,[esi].TOOL.wr.right
	mov		[esi].TOOL.rr.right,eax
	mov		eax,[esi].TOOL.wr.bottom
	mov		[esi].TOOL.rr.bottom,eax
	sub		eax,RESIZEBAR
	mov		[esi].TOOL.wr.bottom,eax
	mov		[esi].TOOL.rr.top,eax
	retn

CaptionTop:
	mov		eax,[esi].TOOL.wr.left
	mov		[esi].TOOL.tr.left,eax
	mov		[esi].TOOL.cr.left,eax
	mov		eax,[esi].TOOL.wr.right
	mov		[esi].TOOL.tr.right,eax
	mov		[esi].TOOL.cr.right,eax
	mov		eax,[esi].TOOL.wr.top
	mov		[esi].TOOL.tr.top,eax
	inc		eax
	mov		[esi].TOOL.cr.top,eax
	add		eax,TOTCAPHT-1
	mov		[esi].TOOL.wr.top,eax
	mov		[esi].TOOL.tr.bottom,eax
	dec		eax
	mov		[esi].TOOL.cr.bottom,eax

	mov		eax,[esi].TOOL.cr.top
	add		eax,BUTTONT
	mov		[esi].TOOL.br.top,eax
	add		eax,BUTTONHT
	mov		[esi].TOOL.br.bottom,eax
	mov		eax,[esi].TOOL.cr.right
	sub		eax,BUTTONR
	mov		[esi].TOOL.br.right,eax
	sub		eax,BUTTONWT
	mov		[esi].TOOL.br.left,eax
	retn

CaptionRight:
	mov		eax,[esi].TOOL.wr.right
	mov		[esi].TOOL.tr.right,eax
	dec		eax
	mov		[esi].TOOL.cr.right,eax
	sub		eax,TOTCAPHT-1
	mov		[esi].TOOL.tr.left,eax
	inc		eax
	mov		[esi].TOOL.cr.left,eax
	mov		[esi].TOOL.wr.right,eax
	mov		eax,[esi].TOOL.wr.top
	mov		[esi].TOOL.tr.top,eax
	mov		[esi].TOOL.cr.top,eax
	mov		eax,[esi].TOOL.wr.bottom
	mov		[esi].TOOL.tr.bottom,eax
	mov		[esi].TOOL.cr.bottom,eax

	mov		eax,[esi].TOOL.cr.right
	sub		eax,BUTTONT
	mov		[esi].TOOL.br.right,eax
	sub		eax,BUTTONHT
	mov		[esi].TOOL.br.left,eax
	mov		eax,[esi].TOOL.cr.bottom
	sub		eax,BUTTONR
	mov		[esi].TOOL.br.bottom,eax
	sub		eax,BUTTONWT
	mov		[esi].TOOL.br.top,eax
	retn

ToolMov:
	invoke IsOnTool,ebx
	.if eax!=0 && eax!=[esi].TOOL.dck.ID
		;If Tool has child
		mov     [esi].TOOL.dck.IsChild,eax
		invoke SetIsChildTo,[esi].TOOL.dck.ID,eax
	.else
		mov     eax,MoveRect.left
		sub     eax,DrawRect.left
		.if sdword ptr eax<50 && sdword ptr eax>-50
			mov     eax,MoveRect.top
			sub     eax,DrawRect.top
			.if sdword ptr eax<50 && sdword ptr eax>-50
				retn
			.endif
		.endif
		invoke GetWindowRect,hWnd,addr rect2
		sub		rect2.left,50
		sub		rect2.top,50
		add		rect2.right,50
		add		rect2.bottom,50
		mov     eax,MoveRect.left
		sub     eax,DrawRect.left
		mov     ebx,lpRect
		mov     eax,[ebx].POINT.x
		cwde
		mov     [ebx].POINT.x,eax
		.if sdword ptr eax<rect2.left && sdword ptr eax>rect2.right
			mov     [esi].TOOL.dck.Docked,FALSE
			retn
		.endif
		mov     eax,[ebx].POINT.y
		cwde
		mov     [ebx].POINT.y,eax
		.if sdword ptr eax<rect2.top && sdword ptr eax>rect2.bottom
			mov     [esi].TOOL.dck.Docked,FALSE
			retn
		.endif
		mov     eax,[ebx].POINT.x
		sub     eax,ClientRect.left
		.if sdword ptr eax<50 && sdword ptr eax>-50
			mov     [esi].TOOL.dck.Position,TL_LEFT
			mov     [esi].TOOL.dck.IsChild,0
		.else
			mov     eax,[ebx].POINT.y
			sub     eax,ClientRect.top
			.if sdword ptr eax<50 && sdword ptr eax>-50
				mov     [esi].TOOL.dck.Position,TL_TOP
				mov     [esi].TOOL.dck.IsChild,0
			.else
				mov     eax,[ebx].POINT.x
				sub     eax,ClientRect.right
				.if sdword ptr eax<50 && sdword ptr eax>-50
					mov     [esi].TOOL.dck.Position,TL_RIGHT
					mov     [esi].TOOL.dck.IsChild,0
				.else
					mov     eax,[ebx].POINT.y
					sub     eax,ClientRect.bottom
					.if sdword ptr eax<50 && sdword ptr eax>-50
						mov     [esi].TOOL.dck.Position,TL_BOTTOM
						mov     [esi].TOOL.dck.IsChild,0
					.else
						mov     [esi].TOOL.dck.Docked,FALSE
					.endif
				.endif
			.endif
		.endif
	.endif
	retn

ToolMsg endp

ToolMsgAll proc uses ecx esi,uMsg:UINT,lParam:LPARAM,fTpe:DWORD

	mov     ecx,10
	mov     esi,offset ToolPool
  Nxt:
	mov     eax,[esi].TOOLPOOL.hCld
	or      eax,eax
	je		Ex
	push    ecx
	mov		edx,[esi].TOOLPOOL.lpTool
	mov		eax,[edx].TOOL.dck.IsChild
	.if fTpe==0
		invoke ToolMsg,[esi].TOOLPOOL.hCld,uMsg,lParam
	.elseif fTpe==1 && !eax
		invoke ToolMsg,[esi].TOOLPOOL.hCld,uMsg,lParam
	.elseif fTpe==2 && eax
		invoke ToolMsg,[esi].TOOLPOOL.hCld,uMsg,lParam
	.elseif fTpe==3
		mov		ecx,lParam
		.if [edx].TOOL.dck.Docked && [ecx].TOOL.dck.Docked && eax==[ecx].TOOL.dck.ID
			mov		eax,[edx].TOOL.dck.Visible
			.if eax!=[ecx].TOOL.dck.Visible
				invoke ToolMsg,[esi].TOOLPOOL.hCld,uMsg,lParam
			.endif
		.endif
	.endif
	pop     ecx
	add     esi,sizeof TOOLPOOL
	dec		ecx
	jne		Nxt
  Ex:
	ret

ToolMsgAll endp

ToolMessage proc uses ebx esi edi,hWin:HWND,uMsg:UINT,lParam:LPARAM
	LOCAl   pt:POINT
	LOCAL   rect:RECT
	LOCAL   clW:DWORD
	LOCAL   clH:DWORD
	LOCAL	tls[10]:TOOL

	mov		eax,uMsg
	.if eax==TLM_INIT
		mov     ToolPtr,0
	.elseif eax==TLM_SIZE
		invoke ToolMsgAll,TLM_ADJUSTRECT,lParam,1
		invoke ToolMsgAll,TLM_ADJUSTRECT,lParam,2
		invoke CopyRect,addr ClientRect,lParam
		mov     edx,lParam
		mov     eax,[edx].RECT.right
		sub     eax,[edx].RECT.left
		mov     clW,eax
		mov     eax,[edx].RECT.bottom
		sub     eax,[edx].RECT.top
		mov     clH,eax
		invoke MoveWindow,hClient,[edx].RECT.left,[edx].RECT.top,clW,clH,TRUE
		invoke ToolMsgAll,TLM_REDRAW,0,1
		invoke ToolMsgAll,TLM_REDRAW,0,2
	.elseif eax==TLM_PAINT
		invoke ToolMsgAll,TLM_CAPTION,0,0
	.elseif eax==TLM_CREATE
		push    ecx
		mov     esi,offset ToolPool
		mov     eax,ToolPtr
		add     esi,eax
		add     ToolPtr,sizeof TOOLPOOL
		mov		ecx,sizeof TOOLPOOL
		xor		edx,edx
		div		ecx
		mov     ecx,sizeof TOOL
		mul     ecx
		mov     edi,offset ToolData
		add     edi,eax
		push    edi
		mov     eax,hWin
		mov     [esi].TOOLPOOL.hCld,eax
		mov     [esi].TOOLPOOL.lpTool,edi
		mov     esi,lParam
		mov     ecx,sizeof DOCKING
		cld
		rep movsb
		mov     ecx,sizeof TOOL - sizeof DOCKING
		xor     al,al
		rep stosb
		pop     edx
		push    edx
		invoke Do_ToolFloat,edx
		pop     edx
		push    eax
		mov     [edx].TOOL.hWin,eax
		mov		eax,hWin
		mov     [edx].TOOL.hCld,eax
		push    edx
		invoke SetWindowLong,[edx].TOOL.hCld,GWL_USERDATA,edx
		pop     edx
		invoke ToolMsg,[edx].TOOL.hCld,TLM_SETTBR,0
		pop     eax
		pop     ecx
	.elseif eax==TLM_MOUSEMOVE
		mov     eax,lParam
		movsx	eax,ax
		mov     pt.x,eax
		mov     eax,lParam
		shr     eax,16
		movsx	eax,ax
		mov     pt.y,eax
		.if ToolResize
			invoke CopyRect,addr DrawRect,addr MoveRect
			mov     eax,pt.x
			cwde
			.if sdword ptr eax<0
				mov     pt.x,0
			.endif
			mov     eax,pt.y
			cwde
			.if sdword ptr eax<0
				mov     pt.y,0
			.endif
			mov     eax,ToolResize
			call GetToolPtr
			mov     eax,[edx].TOOL.dck.Position
			.if eax==TL_LEFT
				mov     eax,ClientRect.right
				sub     eax,RESIZEBAR
				.if eax<pt.x
					mov     pt.x,eax
				.endif
				mov     eax,[edx].TOOL.dr.left
				add     eax,RESIZEBAR+2
				.if eax>pt.x
					mov     pt.x,eax
				.endif
				mov     eax,pt.x
				sub     eax,MovePt.x
				add     DrawRect.right,eax
				mov		eax,DrawRect.bottom
				sub		eax,DrawRect.top
				invoke MoveWindow,hSize,DrawRect.right,DrawRect.top,2,eax,TRUE
			.elseif eax==TL_TOP
				mov     eax,ClientRect.bottom
				sub     eax,RESIZEBAR+1
				.if eax<pt.y
					mov     pt.y,eax
				.endif
				mov     eax,[edx].TOOL.dr.top
				add     eax,TOTCAPHT+RESIZEBAR+2
				.if eax>pt.y
					mov     pt.y,eax
				.endif
				mov     eax,pt.y
				sub     eax,MovePt.y
				add     DrawRect.bottom,eax
				mov		eax,DrawRect.right
				sub		eax,DrawRect.left
				invoke MoveWindow,hSize,DrawRect.left,DrawRect.bottom,eax,2,TRUE
			.elseif eax==TL_RIGHT
				mov     eax,ClientRect.left
				add     eax,RESIZEBAR
				.if eax>pt.x
					mov     pt.x,eax
				.endif
				mov     eax,[edx].TOOL.dr.right
				sub     eax,RESIZEBAR+2
				.if eax<pt.x
					mov     pt.x,eax
				.endif
				mov     eax,pt.x
				sub     eax,MovePt.x
				add     DrawRect.left,eax
				mov		eax,DrawRect.bottom
				sub		eax,DrawRect.top
				invoke MoveWindow,hSize,DrawRect.left,DrawRect.top,2,eax,TRUE
			.elseif eax==TL_BOTTOM
				mov     eax,ClientRect.top
				add     eax,RESIZEBAR+1
				.if eax>pt.y
					mov     pt.y,eax
				.endif
				mov     eax,[edx].TOOL.dr.bottom
				sub     eax,TOTCAPHT+RESIZEBAR+2
				.if eax<pt.y
					mov     pt.y,eax
				.endif
				mov     eax,pt.y
				sub     eax,MovePt.y
				add     DrawRect.top,eax
				mov		eax,DrawRect.right
				sub		eax,DrawRect.left
				invoke MoveWindow,hSize,DrawRect.left,DrawRect.top,eax,2,TRUE
			.endif
			invoke ShowWindow,hSize,SW_SHOWNOACTIVATE
		.elseif ToolMove
			lea		edi,tls
			mov		esi,offset ToolData
			mov		ecx,sizeof tls
			rep movsb
			invoke CopyRect,addr DrawRect,addr MoveRect
			mov     eax,pt.x
			sub     eax,MovePt.x
			add     DrawRect.left,eax
			add     DrawRect.right,eax
			mov     eax,pt.y
			sub     eax,MovePt.y
			add     DrawRect.top,eax
			add     DrawRect.bottom,eax
			invoke ToolMsg,ToolMove,TLM_MOVETEST,addr pt
			invoke CopyRect,addr rect,offset mdirect
			invoke ToolMsgAll,TLM_ADJUSTRECT,addr rect,1
			invoke ToolMsgAll,TLM_ADJUSTRECT,addr rect,2
			mov		eax,ToolMove
			invoke GetToolPtr
			.if [edx].TOOL.dck.Docked
				invoke CopyRect,addr rect,addr [edx].TOOL.dr
				invoke ClientToScreen,hWnd,addr rect
				invoke ClientToScreen,hWnd,addr rect.right
			.else
				invoke CopyRect,addr rect,addr [edx].TOOL.dck.fr
				invoke ClientToScreen,hWnd,addr pt
				mov		edx,rect.right
				sub		edx,rect.left
				mov		eax,pt.x
				mov		rect.left,eax
				add		eax,edx
				mov		rect.right,eax
				shr		edx,1
				sub		rect.left,edx
				sub		rect.right,edx
				mov		edx,rect.bottom
				sub		edx,rect.top
				mov		eax,pt.y
				sub		eax,10
				mov		rect.top,eax
				add		eax,edx
				mov		rect.bottom,eax
				invoke CopyRect,offset FloatRect,addr rect
			.endif
			lea		esi,tls
			mov		edi,offset ToolData
			mov		ecx,sizeof tls
			rep movsb
			invoke ToolDrawRect,addr rect,1,0
		.else
			invoke ToolMsgAll,uMsg,addr pt,0
		.endif
	.elseif eax==TLM_LBUTTONDOWN
		mov     eax,lParam
		movsx	eax,ax
		mov     MovePt.x,eax
		mov     eax,lParam
		shr     eax,16
		movsx	eax,ax
		mov     MovePt.y,eax
		invoke ToolMsgAll,uMsg,addr pt,0
	.elseif eax==TLM_LBUTTONUP
		mov     eax,lParam
		movsx	eax,ax
		mov     pt.x,eax
		mov     eax,lParam
		shr     eax,16
		movsx	eax,ax
		mov     pt.y,eax
		.if ToolResize
			invoke ToolMsg,ToolResize,uMsg,addr pt
			mov     ToolResize,0
		.elseif ToolMove
			invoke ToolMsg,ToolMove,uMsg,addr pt
			mov     ToolMove,0
		.endif
		invoke InvalidateRect,hClient,NULL,TRUE
	.elseif eax==TLM_HIDE
		invoke ToolMsg,hWin,uMsg,lParam
		mov		eax,hWin
		invoke GetToolPtr
		invoke ToolMsgAll,uMsg,edx,3
	.else
		invoke ToolMsg,hWin,uMsg,lParam
	.endif
	ret

ToolMessage endp

ToolWndProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL   rect:RECT
	LOCAL	pt:POINT
	LOCAL   tlW:DWORD
	LOCAL   tlH:DWORD

	mov		eax,uMsg
	.if eax==WM_CREATE
		mov     edx,lParam
		mov     eax,[edx].CREATESTRUCT.lpCreateParams
		invoke SetWindowLong,hWin,GWL_USERDATA,eax
	.elseif eax==WM_SIZE
		mov     eax,hWin
		call    GetToolStruct
		mov		ebx,edx
		.if [ebx].TOOL.dck.Visible
			invoke GetWindowRect,hWin,addr [ebx].TOOL.dck.fr
			invoke GetClientRect,hWin,addr rect
			mov     eax,rect.right
			sub     eax,rect.left
			mov     tlW,eax
			mov     eax,rect.bottom
			sub     eax,rect.top
			mov     tlH,eax
			invoke MoveWindow,[ebx].TOOL.hCld,rect.left,rect.top,tlW,tlH,TRUE
			invoke GetClientRect,hWin,addr rect
			invoke SendMessage,hWnd,WM_TOOLSIZE,hWin,addr rect
		.endif
	.elseif eax==WM_SHOWWINDOW
		mov     eax,hWin
		call    GetToolStruct
		.if ![edx].TOOL.dck.Visible || [edx].TOOL.dck.Docked
			xor		eax,eax
		.endif
	.elseif eax==WM_MOVE
		mov     eax,hWin
		call    GetToolStruct
		invoke GetWindowRect,hWin,addr [edx].TOOL.dck.fr
	.elseif eax==WM_NCLBUTTONDOWN
		.if wParam==HTCAPTION
			invoke LoadCursor,0,IDC_HAND
			mov		MoveCur,eax
			mov     eax,hWin
			call    GetToolStruct
			mov		ebx,edx
			mov		[ebx].TOOL.dCurFlag,TL_ONCAPTION
			mov		[ebx].TOOL.dck.Docked,TRUE
			mov		eax,[ebx].TOOL.dck.fr.top
			add		eax,10
			mov		pt.y,eax
			mov		eax,[ebx].TOOL.dck.fr.right
			sub		eax,[ebx].TOOL.dck.fr.left
			shr		eax,1
			add		eax,[ebx].TOOL.dck.fr.left
			mov		pt.x,eax
			invoke SetCursorPos,pt.x,pt.y
			invoke ToolMsg,[ebx].TOOL.hCld,TLM_LBUTTONDOWN,addr pt
			xor		eax,eax
		.endif
;	.elseif eax==WM_NOTIFY
;		mov		ebx,lParam
;		mov		eax,[ebx].NMHDR.hwndFrom
;		.if eax==hTab && [ebx].NMHDR.code==TCN_SELCHANGE
;;			invoke TabToolSel,hClient
;		.endif
	.elseif eax==WM_CLOSE
		mov     eax,hWin
		call    GetToolStruct
		mov     eax,[edx].TOOL.hCld
		invoke ToolMessage,eax,TLM_HIDE,0
		invoke InvalidateRect,hClient,NULL,TRUE
		xor		eax,eax
	.else
		invoke  DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

ToolWndProc endp

ToolCldProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke SendMessage,hWnd,WM_TOOLSIZE,hWin,addr rect
	.elseif eax==WM_NOTIFY
		invoke SendMessage,hWnd,WM_NOTIFY,wParam,lParam
	.elseif eax==WM_COMMAND
		invoke SendMessage,hWnd,WM_TOOLCOMMAND,wParam,lParam
	.elseif eax==WM_SETFOCUS
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov     [eax].TOOL.dFocus,TRUE
		invoke ToolMsgAll,TLM_CAPTION,0,0
	.elseif eax==WM_KILLFOCUS
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov     [eax].TOOL.dFocus,FALSE
		invoke ToolMsgAll,TLM_CAPTION,0,0
	.endif
	invoke  DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ToolCldProc endp

GetToolStruct proc

	invoke GetWindowLong,eax,GWL_USERDATA
	mov     edx,eax
	ret

GetToolStruct endp
