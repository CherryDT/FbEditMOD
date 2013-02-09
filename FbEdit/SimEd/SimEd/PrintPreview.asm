.const

pptbrbtns	TBBUTTON <20,1,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
			TBBUTTON <6,2,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
			TBBUTTON <7,3,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
			TBBUTTON <8,4,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
ppnbtns		equ 4

;lps			equ 96
;lpp			equ 291

lps			equ 96
lpp			equ 296

.data?

nMag		dd ?

.code

PreviewProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	invoke DefWindowProc,hWin,uMsg,wParam,lParam
	ret

PreviewProc endp

ConvPixelsToTwips proc hDC:HDC,fHorz:DWORD,lSize:DWORD

	.if fHorz
		invoke GetDeviceCaps,hDC,LOGPIXELSX
	.else
		invoke GetDeviceCaps,hDC,LOGPIXELSY
	.endif
	push	eax
	mov		eax,lSize
	mov		ecx,1440
	mul		ecx
	pop		ecx
	div		ecx
	ret

ConvPixelsToTwips endp

PrintPreviewFrame proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	fmr:FORMATRANGE
	LOCAL	rect:RECT
	LOCAL	mDC:HDC
	LOCAL	lf:LOGFONT
	LOCAL	buff[4]:BYTE
	LOCAL	pt:POINT

	mov		eax,uMsg
	.if eax==WM_PAINT
		invoke GetDC,hREd
		push	eax
		mov		edx,eax
		mov		buff,'e'
		invoke GetTextExtentPoint32,edx,addr buff,1,addr pt
		pop		eax
		invoke ReleaseDC,hREd,eax
		invoke BeginPaint,hWin,addr ps
		invoke ConvToPixRects,ps.hdc,addr psd,addr rcPrn,addr rcPrnPage
		invoke CreateCompatibleDC,ps.hdc
		mov		mDC,eax
		mov		fmr.hdc,eax
		mov		fmr.hdcTarget,eax
		invoke MulDivRect,addr rcPrn,lpp,lps
		invoke MulDivRect,addr rcPrnPage,lpp,lps
		invoke GetObject,hFont,sizeof lf,addr lf
		mov		eax,lf.lfHeight
		neg		eax
		mov		ecx,lpp
		mul		ecx
		mov		ecx,lps
		div		ecx
		neg		eax
		mov		lf.lfHeight,eax
		invoke CreateFontIndirect,addr lf
		invoke SelectObject,mDC,eax
		push	eax
		invoke CreateCompatibleBitmap,mDC,rcPrnPage.right,rcPrnPage.bottom
		invoke SelectObject,mDC,eax
		push	eax
		invoke GetStockObject,WHITE_BRUSH
		invoke FillRect,mDC,addr rcPrnPage,eax
		mov		fmr.chrg.cpMin,0
		mov		fmr.chrg.cpMax,-1
		invoke ConvToTwipsRects,addr psd,addr fmr.rc,addr fmr.rcPage
		invoke MulDivRect,addr fmr.rc,lpp,lps
		invoke MulDivRect,addr fmr.rcPage,lpp,lps
		invoke SendMessage,hREd,EM_FORMATRANGE,TRUE,addr fmr
		invoke GetClientRect,hWin,addr rect
		invoke StretchBlt,ps.hdc,0,0,rect.right,rect.bottom,mDC,0,0,rcPrnPage.right,rcPrnPage.bottom,SRCCOPY
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		invoke DeleteDC,mDC
		invoke EndPaint,hWin,addr ps
	.endif
	ret

PrintPreviewFrame endp

PrintPrevievConvert proc lpVal:ptr

	mov		edx,lpVal
	mov		eax,[edx]
	shl		eax,2
	mov		ecx,lfnt.lfHeight
	neg		ecx
	mul		ecx
	mov		ecx,prnfntht
	div		ecx
	mov		edx,lpVal
	mov		[edx],eax
	ret

PrintPrevievConvert endp

PrintPreviewProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	tbab:TBADDBITMAP

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	ebx
		invoke GetDlgItem,hWin,1003
		mov		ebx,eax
		;Set toolbar struct size
		invoke SendMessage,eax,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
		;Set toolbar bitmap
		push	hInstance
		pop		tbab.hInst
		mov		tbab.nID,IDB_TBRBMP
		invoke SendMessage,ebx,TB_ADDBITMAP,15,addr tbab
		;Set toolbar buttons
		invoke SendMessage,ebx,TB_ADDBUTTONS,ppnbtns,offset pptbrbtns
		pop		ebx
		mov		nMag,50
		invoke GetDlgItem,hWin,1001
		push	eax
		invoke SetWindowLong,eax,GWL_WNDPROC,offset PrintPreviewFrame
		invoke GetDlgItem,hWin,1002
		pop		edx
		invoke SetParent,edx,eax
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK

			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke GetDlgItem,hWin,1002
		push	eax
		push	eax
		sub		rect.bottom,28
		invoke SetWindowPos,eax,0,0,28,rect.right,rect.bottom,SWP_NOZORDER
		pop		edx
		invoke GetClientRect,edx,addr rect

		push	ebx
		invoke GetDC,hWin
		mov		ebx,eax
		invoke ConvToPixRects,ebx,addr psd,addr rcPrn,addr rcPrnPage
		invoke ReleaseDC,hWin,ebx
		pop		ebx

		mov		eax,rcPrnPage.right
		mov		ecx,nMag
		mul		ecx
		mov		ecx,100
		div		ecx
		xchg	eax,rect.right
		sub		eax,rect.right
		cdq
		mov		ecx,2
		idiv	ecx
		mov		rect.left,eax
		mov		eax,rcPrnPage.bottom
		mov		ecx,nMag
		mul		ecx
		mov		ecx,100
		div		ecx
		xchg	eax,rect.bottom
		sub		eax,rect.bottom
		cdq
		mov		ecx,2
		idiv	ecx
		mov		rect.top,eax
		pop		eax
		invoke GetDlgItem,eax,1001
		invoke MoveWindow,eax,rect.left,rect.top,rect.right,rect.bottom,TRUE
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

PrintPreviewProc endp
