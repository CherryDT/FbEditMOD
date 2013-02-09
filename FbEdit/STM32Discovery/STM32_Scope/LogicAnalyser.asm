
.code

;########################################################################

LGASetupSampleRate proc uses ebx esi edi

	mov		esi,offset LGAClockDiv
	mov		edi,offset lgadata.LGA_SampleRate
	.while dword ptr [esi]
		mov		eax,STM32Clock
		cdq
		mov		ecx,[esi]
		div		ecx
		mov		[edi].LGA_SAMPLERATE.rate,eax
		dec		ecx
		mov		[edi].LGA_SAMPLERATE.clkdiv,ecx
		invoke FormatFrequency,addr [edi].LGA_SAMPLERATE.szrate,addr szNULL,eax
		lea		edi,[edi+sizeof LGA_SAMPLERATE]
		lea		esi,[esi+DWORD]
	.endw
	ret

LGASetupSampleRate endp

;########################################################################

LGASetupProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		movzx	eax,lgadata.LGA_CommandStruct.STM32_TriggerMode
		add		eax,IDC_RBNLGAMANUAL
		invoke CheckRadioButton,hWin,IDC_RBNLGAMANUAL,IDC_RBNLGALGA,eax
		mov		eax,BST_UNCHECKED
		.if lgadata.LGA_CommandStruct.LGA_TriggerEdge
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKLGAEDGE,eax
		xor		ecx,ecx
		movzx	edi,lgadata.LGA_CommandStruct.LGA_TriggerValue
		mov		ebx,0001h
		.while ecx<8
			push	ecx
			mov		eax,edi
			and		eax,ebx
			.if eax
				lea		eax,[ecx+IDC_CHKLGATRIGD0]
				invoke CheckDlgButton,hWin,eax,BST_CHECKED
			.endif
			shl		ebx,1
			pop		ecx
			inc		ecx
		.endw
		xor		ecx,ecx
		movzx	edi,lgadata.LGA_CommandStruct.LGA_TriggerMask
		mov		ebx,0001h
		.while ecx<8
			push	ecx
			mov		eax,edi
			and		eax,ebx
			.if eax
				lea		eax,[ecx+IDC_CHKLGAMASKD0]
				invoke CheckDlgButton,hWin,eax,BST_CHECKED
			.endif
			shl		ebx,1
			pop		ecx
			inc		ecx
		.endw
		mov		esi,offset lgadata.LGA_SampleRate
		movzx	ebx,lgadata.LGA_CommandStruct.STM32_SampleRateL
		mov		bh,lgadata.LGA_CommandStruct.STM32_SampleRateH
		xor		edi,edi
		.while [esi].LGA_SAMPLERATE.szrate
			invoke SendDlgItemMessage,hWin,IDC_CBOLGASAMPLERATE,CB_ADDSTRING,0,addr [esi].LGA_SAMPLERATE.szrate
			mov		edx,[esi].LGA_SAMPLERATE.clkdiv
			.if edx==ebx
				mov		edi,eax
			.endif
			invoke SendDlgItemMessage,hWin,IDC_CBOLGASAMPLERATE,CB_SETITEMDATA,eax,edx
			lea		esi,[esi+sizeof LGA_SAMPLERATE]
		.endw
		invoke SendDlgItemMessage,hWin,IDC_CBOLGASAMPLERATE,CB_SETCURSEL,edi,0
		invoke SendDlgItemMessage,hWin,IDC_TRBLGABUFFERSIZE,TBM_SETRANGE,FALSE,(STM32_MAXBLOCK SHL 16)+1
		movzx	eax,lgadata.LGA_CommandStruct.STM32_DataBlocks
		invoke SendDlgItemMessage,hWin,IDC_TRBLGABUFFERSIZE,TBM_SETPOS,TRUE,eax
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,0,1
			.elseif eax==IDC_CHKLGATRIGALL
				invoke IsDlgButtonChecked,hWin,IDC_CHKLGATRIGALL
				xor		ecx,ecx
				mov		edi,BST_UNCHECKED
				.if eax
					mov		edi,BST_CHECKED
				.endif
				.while ecx<8
					push	ecx
					lea		eax,[ecx+IDC_CHKLGATRIGD0]
					invoke CheckDlgButton,hWin,eax,edi
					pop		ecx
					inc		ecx
				.endw
				call	Update
			.elseif eax==IDC_CHKLGAMASKALL
				invoke IsDlgButtonChecked,hWin,IDC_CHKLGAMASKALL
				xor		ecx,ecx
				mov		edi,BST_UNCHECKED
				.if eax
					mov		edi,BST_CHECKED
				.endif
				.while ecx<8
					push	ecx
					lea		eax,[ecx+IDC_CHKLGAMASKD0]
					invoke CheckDlgButton,hWin,eax,edi
					pop		ecx
					inc		ecx
				.endw
				call	Update
			.else
				call	Update
			.endif
		.elseif edx==CBN_SELCHANGE
			call	Update
		.endif
	.elseif eax==WM_HSCROLL
		call	Update
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
		mov		childdialogs.hWndLGASetup,0
		invoke SetFocus,hWnd
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Update:
	;Get trigger type
	xor		ebx,ebx
	.while ebx<6
		invoke IsDlgButtonChecked,hWin,addr [ebx+IDC_RBNLGAMANUAL]
		.break .if eax
		inc		ebx
	.endw
	mov		lgadata.LGA_CommandStruct.STM32_TriggerMode,bl
	xor		ecx,ecx
	xor		ebx,ebx
	mov		edi,0001h
	.while ecx<8
		push	ecx
		lea		eax,[ecx+IDC_CHKLGATRIGD0]
		invoke IsDlgButtonChecked,hWin,eax
		.if eax
			or		ebx,edi
		.endif
		shl		edi,1
		pop		ecx
		inc		ecx
	.endw
	mov		lgadata.LGA_CommandStruct.LGA_TriggerValue,bl
	xor		ecx,ecx
	xor		ebx,ebx
	mov		edi,0001h
	.while ecx<8
		push	ecx
		lea		eax,[ecx+IDC_CHKLGAMASKD0]
		invoke IsDlgButtonChecked,hWin,eax
		.if eax
			or		ebx,edi
		.endif
		shl		edi,1
		pop		ecx
		inc		ecx
	.endw
	mov		lgadata.LGA_CommandStruct.LGA_TriggerMask,bl
	invoke IsDlgButtonChecked,hWin,IDC_CHKLGAEDGE
	mov		lgadata.LGA_CommandStruct.LGA_TriggerEdge,al
	;Get sample rate
	invoke SendDlgItemMessage,hWin,IDC_CBOLGASAMPLERATE,CB_GETCURSEL,0,0
	invoke SendDlgItemMessage,hWin,IDC_CBOLGASAMPLERATE,CB_GETITEMDATA,eax,0
	.if ax==5
		;FAST_LGA_Read 128 Bytes
		mov		lgadata.LGA_CommandStruct.STM32_SampleRateL,0
		mov		lgadata.LGA_CommandStruct.STM32_SampleRateH,0
		mov		lgadata.LGA_CommandStruct.STM32_DataBlocks,2
	.else
		;Get buffer size
		invoke SendDlgItemMessage,hWin,IDC_TRBLGABUFFERSIZE,TBM_GETPOS,0,0
		mov		lgadata.LGA_CommandStruct.STM32_DataBlocks,al
		mov		lgadata.LGA_CommandStruct.STM32_SampleRateL,al
		mov		lgadata.LGA_CommandStruct.STM32_SampleRateH,ah
	.endif
	retn

LGASetupProc endp

;#########################################################################

LogicAnalyserProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	mDC:HDC
	LOCAL	pt:POINT
	LOCAL	xsinf:SCROLLINFO
	LOCAL	nMin:DWORD
	LOCAL	nMax:DWORD
	LOCAL	lgabit:BYTE
	LOCAL	lgaoldbit:BYTE
	LOCAL	yinc:DWORD
	LOCAL	lgatransition:DWORD
	LOCAL	samplesize:DWORD
	LOCAL	buffer[128]:BYTE
	LOCAL	buffer1[128]:BYTE

	mov		eax,uMsg
	.if eax==WM_PAINT
		invoke GetClientRect,hWin,addr rect
		call	SetScrooll
		invoke BeginPaint,hWin,addr ps
		invoke CreateCompatibleDC,ps.hdc
		mov		mDC,eax
		invoke CreateCompatibleBitmap,ps.hdc,rect.right,rect.bottom
		invoke SelectObject,mDC,eax
		push	eax
		invoke GetStockObject,BLACK_BRUSH
		invoke FillRect,mDC,addr rect,eax
		sub		rect.bottom,TEXTHIGHT
		invoke SetBkColor,mDC,080FFFFh
		mov		lgabit,01h
		mov		eax,rect.bottom
		sub		eax,10
		shr		eax,3
		mov		yinc,eax
		sub		eax,5
		mov		pt.y,eax
		shr		eax,1
		mov		lgatransition,eax
		mov		esi,offset szLGADataBits
		mov		edi,pt.y
		sub		edi,15
		mov		rect1.left,1
		mov		rect1.right,20
		.while byte ptr [esi]
			mov		eax,edi
			mov		rect1.top,eax
			add		eax,20
			mov		rect1.bottom,eax
			invoke DrawText,mDC,esi,2,addr rect1,DT_SINGLELINE
			add		edi,yinc
			invoke lstrlen,esi
			lea		esi,[esi+eax+1]
		.endw
		invoke lstrlen,addr lgadata.LGA_Text
		.if eax
			push	eax
			invoke SetBkMode,mDC,TRANSPARENT
			invoke SetTextColor,mDC,00FF00h
			pop		eax
			mov		edx,rect.bottom
			add		edx,8
			invoke TextOut,mDC,0,edx,addr lgadata.LGA_Text,eax
		.endif
		invoke CreateRectRgn,LGAXSTART,0,rect.right,rect.bottom
		push	eax
		invoke SelectClipRgn,mDC,eax
		pop		eax
		invoke DeleteObject,eax
		invoke CreatePen,PS_SOLID,2,202020h
		invoke SelectObject,mDC,eax
		push	eax
		mov		edi,40
		call	GetXPos
		push	pt.x
		xor		edi,edi
		call	GetXPos
		pop		eax
		sub		eax,pt.x
		.if eax>1024
			xor		ebx,ebx
		.elseif eax>512
			mov		ebx,01h
		.elseif eax>256
			mov		ebx,03h
		.elseif eax>128
			mov		ebx,07h
		.elseif eax>64
			mov		ebx,0Fh
		.elseif eax>32
			mov		ebx,1Fh
		.elseif eax>16
			mov		ebx,3Fh
		.elseif eax>8
			mov		ebx,7Fh
		.elseif eax>4
			mov		ebx,0FFh
		.elseif eax>4
			mov		ebx,1FFh
		.else
			mov		ebx,3FFh
		.endif
		.while edi<samplesize
			mov		eax,ebx
			and		eax,edi
			.if !eax
				call	GetXPos
				mov		eax,pt.x
				.break .if sdword ptr eax>rect.right
				invoke MoveToEx,mDC,pt.x,0,NULL
				invoke LineTo,mDC,pt.x,rect.bottom
			.endif
			inc		edi
		.endw
		mov		edi,yinc
		xor		ecx,ecx
		.while ecx<8
			push	ecx
			invoke MoveToEx,mDC,0,edi,NULL
			invoke LineTo,mDC,rect.right,edi
			add		edi,yinc
			pop		ecx
			inc		ecx
		.endw
		invoke MoveToEx,mDC,0,rect.bottom,NULL
		invoke LineTo,mDC,rect.right,rect.bottom
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		xor		ecx,ecx
		.while ecx<8
			push	ecx
			.if ecx & 1
				mov		eax,0808000h
			.else
				mov		eax,008000h
			.endif
			invoke CreatePen,PS_SOLID,2,eax
			invoke SelectObject,mDC,eax
			push	eax
			call	DrawCurve
			pop		eax
			invoke SelectObject,mDC,eax
			invoke DeleteObject,eax
			mov		eax,yinc
			add		pt.y,eax
			shl		lgabit,1
			pop		ecx
			inc		ecx
		.endw
		add		rect.bottom,TEXTHIGHT
		invoke BitBlt,ps.hdc,0,0,rect.right,rect.bottom,mDC,0,0,SRCCOPY
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		invoke DeleteDC,mDC
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
	.elseif eax==WM_MOUSEMOVE
		invoke GetCursorPos,addr pt
 		invoke WindowFromPoint,pt.x,pt.y
 		.if eax==hWin
			invoke GetClientRect,hWin,addr rect
			mov		edx,lParam
			movsx	eax,dx
			shr		edx,16
			movsx	edx,dx
			mov		pt.x,eax
			mov		pt.y,edx
			invoke GetCapture
			.if eax!=hWin
				invoke SetCapture,hWin
			.endif
			mov		eax,pt.x
			mov		edx,pt.y
			.if eax>rect.right || edx>rect.bottom
				invoke ReleaseCapture
				.if lgadata.LGA_Text
					mov		lgadata.LGA_Text,0
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.else
				call	SetScrooll
				call	GetBytenbr
				.if sdword ptr edi>=0
					movzx	eax,lgadata.LGA_Data[edi]
					push	eax
					invoke ByteToBin,addr buffer1,eax
					pop		edx
					invoke wsprintf,addr buffer,addr szFmtLGA,edx,addr buffer1,edi
					invoke lstrcmp,addr buffer,addr lgadata.LGA_Text
					.if eax
						invoke lstrcpy,addr lgadata.LGA_Text,addr buffer
						invoke InvalidateRect,hWin,0,TRUE
					.endif
				.else
					.if lgadata.LGA_Text
						mov		lgadata.LGA_Text,0
						invoke InvalidateRect,hWin,0,TRUE
					.endif
				.endif
			.endif
 		.else
			invoke GetCapture
			.if eax==hWin
				invoke ReleaseCapture
				.if lgadata.LGA_Text
					mov		lgadata.LGA_Text,0
					invoke InvalidateRect,hWin,0,TRUE
				.endif
			.endif
 		.endif
	.elseif eax==WM_HSCROLL
		mov		xsinf.cbSize,sizeof SCROLLINFO
		mov		xsinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_HORZ,addr xsinf
		mov		eax,wParam
		movzx	eax,ax
		.if eax==SB_THUMBPOSITION
			mov		eax,xsinf.nTrackPos
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif  eax==SB_THUMBTRACK
			mov		eax,xsinf.nTrackPos
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif  eax==SB_LINELEFT
			mov		eax,xsinf.nPos
			sub		eax,10
			.if CARRY?
				xor		eax,eax
			.endif
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_LINERIGHT
			mov		eax,xsinf.nPos
			add		eax,10
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_PAGELEFT
			mov		eax,xsinf.nPos
			sub		eax,xsinf.nPage
			.if CARRY?
				xor		eax,eax
			.endif
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_PAGERIGHT
			mov		eax,xsinf.nPos
			add		eax,xsinf.nPage
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

SetScrooll:
	movzx	eax,lgadata.LGA_CommandStructDone.STM32_DataBlocks
	mov		ecx,STM32_BlockSize
	mul		ecx
	mov		samplesize,eax
	invoke GetClientRect,hWin,addr rect
	sub		rect.bottom,TEXTHIGHT
	;Init horizontal scrollbar
	mov		xsinf.cbSize,sizeof SCROLLINFO
	mov		xsinf.fMask,SIF_ALL
	invoke GetScrollInfo,hWin,SB_HORZ,addr xsinf
	mov		xsinf.nMin,0
	mov		eax,samplesize
	mov		ecx,lgadata.xmag
	.if ecx>XMAGMAX/16
		sub		ecx,XMAGMAX/16
		add		ecx,10
		mul		ecx
		mov		ecx,10
		div		ecx
	.elseif ecx<XMAGMAX/16
		push	ecx
		mov		ecx,10
		mul		ecx
		pop		ecx
		sub		ecx,XMAGMAX/16
		neg		ecx
		add		ecx,10
		div		ecx
	.endif
	mov		ecx,rect.right
	dec		ecx
	sub		ecx,LGAXSTART
	mul		ecx
	mov		ecx,samplesize
	div		ecx
	mov		xsinf.nMax,eax
	mov		eax,rect.right
	sub		eax,LGAXSTART
	mov		xsinf.nPage,eax
	invoke SetScrollInfo,hWin,SB_HORZ,addr xsinf,TRUE
	add		rect.bottom,TEXTHIGHT
	retn

GetXPos:
	;Get X position
	mov		eax,edi
	mov		ecx,lgadata.xmag
	.if ecx>XMAGMAX/16
		sub		ecx,XMAGMAX/16
		add		ecx,10
		mul		ecx
		mov		ecx,10
		div		ecx
	.elseif ecx<XMAGMAX/16
		push	ecx
		mov		ecx,10
		mul		ecx
		pop		ecx
		sub		ecx,XMAGMAX/16
		neg		ecx
		add		ecx,10
		div		ecx
	.endif
	mov		ecx,rect.right
	sub		ecx,LGAXSTART
	mul		ecx
	mov		ecx,samplesize
	div		ecx
	sub		eax,xsinf.nPos
	add		eax,LGAXSTART
	mov		pt.x,eax
	retn

GetBytenbr:
	mov		ebx,pt.x
	xor		edi,edi
	call	GetXPos
	.while edi<samplesize
		push	pt.x
		inc		edi
		call	GetXPos
		pop		edx
		.if ebx>=edx && ebx<pt.x
			dec		edi
			retn
		.endif
	.endw
	mov		edi,-1
	retn

DrawCurve:
	mov		esi,offset lgadata.LGA_Data
	xor		edi,edi
	invoke MoveToEx,mDC,LGAXSTART,pt.y,NULL
	xor		ecx,ecx
	mov		ebx,pt.y
	mov		lgaoldbit,cl
	.while ecx<samplesize
		push	ecx
		mov		al,[esi+ecx]
		and		al,lgabit
		.if al!=lgaoldbit
			mov		lgaoldbit,al
			.if al
				;Transition from 0 to 1
				sub		ebx,lgatransition
			.else
				;Transition from 1 to 0
				add		ebx,lgatransition
			.endif
			call	GetXPos
			invoke LineTo,mDC,pt.x,ebx
		.endif
		inc		edi
		call	GetXPos
		invoke LineTo,mDC,pt.x,ebx
		pop		ecx
		mov		eax,pt.x
		.break .if sdword ptr eax>rect.right
		inc		ecx
	.endw
	retn

LogicAnalyserProc endp

LogicAnalyserToolChildProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_TRBLGAXMAG,TBM_SETRANGE,FALSE,(XMAGMAX SHL 16)+1
		invoke SendDlgItemMessage,hWin,IDC_TRBLGAXMAG,TBM_SETPOS,TRUE,XMAGMAX/2
	.elseif eax==WM_HSCROLL
		;X-Magnification
		invoke SendDlgItemMessage,hWin,IDC_TRBLGAXMAG,TBM_GETPOS,0,0
		mov		lgadata.xmag,eax
		invoke InvalidateRect,lgadata.hWndLGA,NULL,TRUE
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

LogicAnalyserToolChildProc endp

LogicAnalyserChildProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		lgadata.hWndDialog,eax
		invoke GetDlgItem,hWin,IDC_UDCLOGICANALYSER
		mov		lgadata.hWndLGA,eax
		mov		lgadata.xmag,256
		mov		lgadata.LGA_CommandStruct.STM32_TriggerMode,STM32_TriggerLGA
		mov		lgadata.LGA_CommandStruct.LGA_TriggerValue,00h
		mov		lgadata.LGA_CommandStruct.LGA_TriggerMask,00h
		mov		lgadata.LGA_CommandStruct.STM32_DataBlocks,04h
		mov		lgadata.LGA_CommandStruct.STM32_SampleRateL,11
		mov		lgadata.LGA_CommandStruct.STM32_SampleRateH,0
		invoke RtlMoveMemory,offset lgadata.LGA_CommandStructDone,offset lgadata.LGA_CommandStruct,sizeof STM32_CommandStructDef
		invoke CreateDialogParam,hInstance,IDD_DLGLGATOOL,hWin,addr LogicAnalyserToolChildProc,0
		mov		lgadata.hWndLGATool,eax
		;Create some test data, the data could be the output from an 8 bit counter.
		mov		edi,offset lgadata.LGA_Data
		xor		ecx,ecx
		.while ecx<sizeof LGADATA.LGA_Data
			mov		[edi+ecx],cl
			inc		ecx
		.endw
	.elseif	eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		sub		rect.right,135
		invoke MoveWindow,lgadata.hWndLGA,0,0,rect.right,rect.bottom,TRUE
		invoke MoveWindow,lgadata.hWndLGATool,rect.right,0,135,60,TRUE
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

LogicAnalyserChildProc endp

