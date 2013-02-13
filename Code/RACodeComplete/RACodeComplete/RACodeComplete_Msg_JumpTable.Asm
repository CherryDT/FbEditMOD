	align 4 
	_CCM_ADDITEM:
		mov		ecx,[ebx].RACC.count
		lea		eax,[ecx*8]
		.if eax>=[ebx].RACC.cbsize
			invoke GlobalUnlock,[ebx].RACC.hmem
			add		[ebx].RACC.cbsize,1024*32
			invoke GlobalReAlloc,[ebx].RACC.hmem,[ebx].RACC.cbsize,GMEM_MOVEABLE
			mov		[ebx].RACC.hmem,eax
			invoke GlobalLock,[ebx].RACC.hmem
			mov		[ebx].RACC.lpmem,eax
			mov		ecx,[ebx].RACC.count
		.endif
		mov		edx,[ebx].RACC.lpmem
		mov		eax,lParam
		mov		[edx+ecx*8],eax
		mov		eax,wParam
		mov		[edx+ecx*8+4],eax
		inc		ecx
		mov		[ebx].RACC.count,ecx
		.if [ebx].RACC.fredraw
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
		ret
	align 4 
	_CCM_ADDLIST:
		push	esi
		push	edi
		mov		edx,lParam
		mov		esi,[edx].CC_ADDLIST.lpszList
	  @@:
		mov		edi,esi
		.while byte ptr [esi]!=',' && byte ptr [esi]
			inc		esi
		.endw
		.if byte ptr [esi]==','
			mov		byte ptr [esi],0
			inc		esi
			mov		edx,lParam
			invoke CompareStr,[edx].CC_ADDLIST.lpszFilter,edi
			.if !eax
				mov		edx,lParam
				invoke SendMessage,hWin,CCM_ADDITEM,[edx].CC_ADDLIST.nType,edi
			.endif
			jmp		@b
		.endif
		invoke strlen,edi
		.if eax
			mov		edx,lParam
			invoke CompareStr,[edx].CC_ADDLIST.lpszFilter,edi
			.if !eax
				mov		edx,lParam
				invoke SendMessage,hWin,CCM_ADDITEM,[edx].CC_ADDLIST.nType,edi
			.endif
		.endif
		pop		edi
		pop		esi
		.if [ebx].RACC.fredraw
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
		ret
	align 4 
	_CCM_DELITEM:
		mov		eax,wParam
		.if eax<[ebx].RACC.count
			mov		edx,[ebx].RACC.lpmem
			.while eax<[ebx].RACC.count
				mov		ecx,[edx+eax*8+8]
				mov		[edx+eax*8],ecx
				mov		ecx,[edx+eax*8+8+4]
				mov		[edx+eax*8+4],ecx
				inc		eax
			.endw
			dec		[ebx].RACC.count
			.if [ebx].RACC.fredraw
				invoke InvalidateRect,hWin,NULL,TRUE
			.endif
		.endif
		xor		eax,eax
		ret
	align 4 
	_CCM_GETITEM:
		mov		eax,wParam
		.if eax<[ebx].RACC.count
			mov		edx,[ebx].RACC.lpmem
			mov		eax,[edx+eax*8]
		.else
			xor		eax,eax
		.endif
		ret
	align 4 
	_CCM_GETCOUNT:
		mov		eax,[ebx].RACC.count
		ret
	align 4 
	_CCM_GETMAXWIDTH:
		push		esi
		push		edi
		invoke GetDC,hWin
		mov		ps.hdc,eax
		invoke SelectObject,ps.hdc,[ebx].RACC.hfont
		push	eax
		call	SetScroll
		mov		sinf.cbSize,sizeof sinf
		mov		sinf.fMask,SIF_PAGE or SIF_RANGE
		invoke GetScrollInfo,hWin,SB_VERT,addr sinf
		mov		ninx,0
		mov		eax,sinf.nMax
		.if eax>=sinf.nPage
			invoke GetSystemMetrics,SM_CXVSCROLL
			mov		ninx,eax
		.endif
		xor		esi,esi
		xor		edi,edi
		mov		rect.left,esi
		mov		rect.top,esi
		.while esi<[ebx].RACC.count
			mov		edx,[ebx].RACC.lpmem
			mov		edx,[edx+esi*8]
			invoke DrawText,ps.hdc,edx,-1,addr rect,DT_SINGLELINE or DT_CALCRECT
			mov		eax,rect.right
			add		eax,ninx
			test	[ebx].RACC.style,STYLE_USEIMAGELIST
			.if !ZERO?
				add		eax,19
			.endif
			.if eax>edi
				mov		edi,eax
			.endif
			inc		esi
		.endw
		pop		eax
		invoke SelectObject,ps.hdc,eax
		invoke ReleaseDC,hWin,ps.hdc
		mov		eax,edi
		pop		edi
		pop		esi	
		ret	
	align 4 
	_CCM_CLEAR:
		xor		eax,eax
		mov		[ebx].RACC.count,eax
		mov		[ebx].RACC.topindex,eax
		dec		eax
		mov		[ebx].RACC.cursel,eax
		.if [ebx].RACC.fredraw
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
		ret
	align 4 
	_CCM_SETCURSEL:
		.if [ebx].RACC.fredraw
			invoke SendMessage,hWin,CCM_GETITEMRECT,[ebx].RACC.cursel,addr ps.rcPaint
			invoke InvalidateRect,hWin,addr ps.rcPaint,TRUE
		.endif
		mov		eax,wParam
		.if eax<[ebx].RACC.count
			mov		[ebx].RACC.cursel,eax
			.if [ebx].RACC.fredraw
				invoke SendMessage,hWin,CCM_GETITEMRECT,[ebx].RACC.cursel,addr ps.rcPaint
				invoke InvalidateRect,hWin,addr ps.rcPaint,TRUE
			.endif
		.else
			mov		[ebx].RACC.cursel,-1
		.endif
		xor		eax,eax
		ret
	align 4 
	_CCM_GETCURSEL:
		mov		eax,[ebx].RACC.cursel
		ret
	align 4 
	_CCM_GETTOPINDEX:
		mov		eax,[ebx].RACC.topindex
		ret
	align 4 
	_CCM_SETTOPINDEX:
		mov		eax,wParam
		.if eax>=[ebx].RACC.count
			mov		eax,[ebx].RACC.count
			.if eax
				dec		eax
			.endif
		.endif
		mov		[ebx].RACC.topindex,eax
		.if [ebx].RACC.fredraw
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
		ret
	align 4 
	_CCM_GETITEMRECT:
		invoke GetClientRect,hWin,addr rect
		mov		edx,lParam
		mov		[edx].RECT.left,0
		mov		eax,rect.right
		mov		[edx].RECT.right,eax
		mov		eax,wParam
		sub		eax,[ebx].RACC.topindex
		mov		ecx,[ebx].RACC.itemheight
		mul		ecx
		mov		edx,lParam
		mov		[edx].RECT.top,eax
		add		eax,ecx
		mov		[edx].RECT.bottom,eax
		xor		eax,eax
		ret
	align 4 
	_CCM_SETVISIBLE:
		invoke SendMessage,hWin,CCM_GETITEMRECT,[ebx].RACC.cursel,addr ps.rcPaint
		invoke GetClientRect,hWin,addr rect
		mov		eax,ps.rcPaint.top
		mov		edx,ps.rcPaint.bottom
		.if sdword ptr eax<0
			mov		eax,[ebx].RACC.cursel
			.if eax<[ebx].RACC.count
				mov		[ebx].RACC.topindex,eax
			.endif
		.elseif edx>rect.bottom
			mov		eax,rect.bottom
			mov		ecx,[ebx].RACC.itemheight
			xor		edx,edx
			div		ecx
			dec		eax
			mov		edx,[ebx].RACC.cursel
			sub		edx,eax
			.if CARRY?
				xor		edx,edx
			.endif
			mov		[ebx].RACC.topindex,edx
		.endif
		.if [ebx].RACC.fredraw
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
		ret
	align 4 
	_CCM_FINDSTRING:
		mov		ecx,wParam
		inc		ecx
		.while ecx<[ebx].RACC.count
			push	ecx
			mov		edx,[ebx].RACC.lpmem
			mov		edx,[edx+ecx*8]
			invoke CompareStr,lParam,edx
			pop		ecx
			or		eax,eax
			je		@f
			inc		ecx
		.endw
		mov		ecx,-1
	  @@:
		mov		eax,ecx
		ret
	align 4 
	_CCM_SORT:
		mov		eax,[ebx].RACC.count
		.if eax
			dec		eax
			invoke QuickSort,[ebx].RACC.lpmem,0,eax,wParam
			.if lParam
				push	esi
				push	edi
				xor		esi,esi
				mov		edi,[ebx].RACC.count
				dec		edi
				.while esi<edi
					mov		edx,[ebx].RACC.lpmem
					mov		edx,[edx+esi*8]
					inc		esi
					mov		ecx,[ebx].RACC.lpmem
					mov		ecx,[ecx+esi*8]
					invoke CompareStrMatchCase,ecx,edx
					.if !eax
						invoke SendMessage,hWin,CCM_DELITEM,esi,0
						dec		edi
						dec		esi
					.endif
				.endw
				pop		edi
				pop		esi
			.endif
			.if [ebx].RACC.fredraw
				invoke InvalidateRect,hWin,NULL,TRUE
			.endif
		.endif
		xor		eax,eax
		ret
	align 4 
	_CCM_GETCOLOR:
		mov		edx,lParam
		mov		eax,[ebx].RACC.backcolor
		mov		[edx].CC_COLOR.back,eax
		mov		eax,[ebx].RACC.textcolor
		mov		[edx].CC_COLOR.text,eax
		xor		eax,eax
		ret
	align 4 
	_CCM_SETCOLOR:
		mov		edx,lParam
		mov		eax,[edx].CC_COLOR.back
		mov		[ebx].RACC.backcolor,eax
		mov		eax,[edx].CC_COLOR.text
		mov		[ebx].RACC.textcolor,eax
		.if [ebx].RACC.fredraw
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
		ret

.data
align 4
_RACODECOMPLETE_BASE \
	dd _CCM_ADDITEM			;equ WM_USER+0		;wParam=0, lParam=lpString, Returns nothing
	dd _CCM_DELITEM			;equ WM_USER+1		;wParam=Index, lParam=0, Returns nothing
	dd _CCM_GETITEM			;equ WM_USER+2		;wParam=Index, lParam=0, Returns pointer to string or NULL
	dd _CCM_GETCOUNT		;equ WM_USER+3		;wParam=0, lParam=0, Returns count
	dd _CCM_CLEAR			;equ WM_USER+4		;wParam=0, lParam=0, Returns nothing
	dd _CCM_SETCURSEL		;equ WM_USER+5		;wParam=Index, lParam=0, Returns nothing
	dd _CCM_GETCURSEL		;equ WM_USER+6		;wParam=0, lParam=0, Returns Index
	dd _CCM_GETTOPINDEX		;equ WM_USER+7		;wParam=0, lParam=0, Returns TopIndex
	dd _CCM_SETTOPINDEX		;equ WM_USER+8		;wParam=TopIndex, lParam=0, Returns nothing
	dd _CCM_GETITEMRECT		;equ WM_USER+9		;wParam=Index, lParam=lpRECT, Returns nothing
	dd _CCM_SETVISIBLE		;equ WM_USER+10		;wParam=0, lParam=0, Returns nothing
	dd _CCM_FINDSTRING		;equ WM_USER+11		;wParam=Start Index, lParam=lpString, Returns Index or -1
	dd _CCM_SORT			;equ WM_USER+12		;wParam=Descending (TRUE/FALSE), lParam=0, Returns nothing
	dd _CCM_GETCOLOR		;equ WM_USER+13		;wParam=0, lParam=lpCC_COLOR, Returns nothing
	dd _CCM_SETCOLOR		;equ WM_USER+14		;wParam=0, lParam=lpCC_COLOR, Returns nothing
	dd _CCM_ADDLIST			;equ WM_USER+15		;wParam=0, lParam=lpCC_ADDLIST, Returns nothing
	dd _CCM_GETMAXWIDTH		;equ WM_USER+16		;wParam=0, lParam=0, Returns length of longest Item

.code
align 4
