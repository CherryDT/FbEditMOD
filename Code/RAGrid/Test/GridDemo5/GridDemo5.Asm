.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include GridDemo5.inc
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

BinToDec proc dwVal:DWORD,lpAscii:DWORD

    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi
	mov		eax,dwVal
	mov		edi,lpAscii
	or		eax,eax
	jns		pos
	mov		byte ptr [edi],'-'
	neg		eax
	inc		edi
  pos:      
	mov		ecx,429496730
	mov		esi,edi
  @@:
	mov		ebx,eax
	mul		ecx
	mov		eax,edx
	lea		edx,[edx*4+edx]
	add		edx,edx
	sub		ebx,edx
	add		bl,'0'
	mov		[edi],bl
	inc		edi
	or		eax,eax
	jne		@b
	mov		byte ptr [edi],al
	.while esi<edi
		dec		edi
		mov		al,[esi]
		mov		ah,[edi]
		mov		[edi],al
		mov		[esi],ah
		inc		esi
	.endw
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    ret

BinToDec endp

DecToBin proc lpStr:DWORD
	LOCAL	fNeg:DWORD

    push    ebx
    push    esi
    mov     esi,lpStr
    mov		fNeg,FALSE
    mov		al,[esi]
    .if al=='-'
		inc		esi
		mov		fNeg,TRUE
    .endif
    xor     eax,eax
  @@:
    cmp     byte ptr [esi],30h
    jb      @f
    cmp     byte ptr [esi],3Ah
    jnb     @f
    mov     ebx,eax
    shl     eax,2
    add     eax,ebx
    shl     eax,1
    xor     ebx,ebx
    mov     bl,[esi]
    sub     bl,30h
    add     eax,ebx
    inc     esi
    jmp     @b
  @@:
	.if fNeg
		neg		eax
	.endif
    pop     esi
    pop     ebx
    ret

DecToBin endp

EditProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_SHOWWINDOW
		.if !wParam && !fFlag
			;The flag is needed since the GM_ENDEDIT also hides the control
			mov		fFlag,TRUE
			invoke GetWindowLong,hWin,GWL_ID
			invoke SendMessage,hGrd,GM_ENDEDIT,eax,FALSE
		.elseif wParam
			mov		fFlag,FALSE
		.endif
	.endif
	invoke CallWindowProc,OldEditProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

EditProc endp


DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	col:COLUMN
	LOCAL	rect:RECT
	LOCAL	val:DWORD
	LOCAL	buf1[256]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWnd,eax
		invoke GetDlgItem,hWin,IDC_GRD1
		mov		hGrd,eax

		call	Setup
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
				xor		ViewRoll,1
				invoke InvalidateRect,hGrd,NULL,TRUE
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
;				invoke SendMessage,hGrd,GM_RESETCONTENT,0,0
;				invoke SendMessage,hGrd,GM_RESETCOLUMNS,0,0
;				call Setup
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
				invoke SendMessage,hGrd,GM_COLUMNSORT,[esi].GRIDNOTIFY.col,SORT_INVERT
			.elseif eax==GN_BEFOREEDIT
				mov eax,[esi].GRIDNOTIFY.col
				.if eax==1
					mov edx,[esi].GRIDNOTIFY.row
					shl edx,16
					or edx,eax
					invoke SendMessage,hGrd,GM_CELLCONVERT,edx,addr buf1
					invoke SendMessage,[esi].GRIDNOTIFY.hwnd,WM_SETTEXT,0,addr buf1
					invoke SendMessage,[esi].GRIDNOTIFY.hwnd,EM_SETSEL,0,-1
				.endif
			.elseif eax==GN_AFTEREDIT
				mov eax,[esi].GRIDNOTIFY.col
				.if eax==1
					mov edx,[esi].GRIDNOTIFY.row
					shl edx,16
					or edx,eax
					invoke SendMessage,hGrd,GM_GETCELLDATA,edx,[esi].GRIDNOTIFY.lpdata
					invoke SendMessage,[esi].GRIDNOTIFY.hwnd,WM_GETTEXT,sizeof buf1,addr buf1
					invoke DecToBin,addr buf1
					.if eax>255
						xor eax,eax
					.endif
					mov ecx,[esi].GRIDNOTIFY.lpdata
					.if ViewRoll
						mov [ecx+1],al
					.else
						mov [ecx],al
					.endif
				.endif
			.elseif eax==GN_USERCONVERT
				xor eax,eax
				mov ecx,[esi].GRIDNOTIFY.lpdata
				.if ViewRoll
					mov al,[ecx+1]
					invoke BinToDec,eax,[esi].GRIDNOTIFY.lpdata
				.else
					mov al,[ecx]
					invoke BinToDec,eax,[esi].GRIDNOTIFY.lpdata
				.endif
				
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

Setup:
	invoke SendMessage,hGrd,GM_SETBACKCOLOR,0FFFFD0h,0
	invoke SendMessage,hGrd,GM_SETGRIDCOLOR,808080h,0
	invoke SendMessage,hGrd,GM_SETTEXTCOLOR,800000h,0

	;Add Name column
	mov		col.colwt,150
	mov		col.lpszhdrtext,offset szName
	mov		col.halign,GA_ALIGN_LEFT
	mov		col.calign,GA_ALIGN_LEFT
	mov		col.ctype,TYPE_EDITTEXT
	mov		col.ctextmax,2
	mov		col.lpszformat,0
	mov		col.himl,0
	mov		col.hdrflag,0
	invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

	;Add Graph column
	mov		col.colwt,110
	mov		col.lpszhdrtext,offset szGraph
	mov		col.halign,GA_ALIGN_LEFT
	mov		col.calign,GA_ALIGN_RIGHT
	mov		col.ctype,TYPE_USER
	mov		col.ctextmax,2
	mov		col.lpszformat,0
	mov		col.himl,0
	mov		col.hdrflag,0
	invoke CreateWindowEx,0,offset szEdit,NULL,WS_CHILD or WS_BORDER or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or ES_AUTOHSCROLL or ES_RIGHT,0,0,0,0,hWnd,NULL,hInstance,0
	mov		col.edthwnd,eax
	invoke SetWindowLong,eax,GWL_WNDPROC,offset EditProc
	mov		OldEditProc,eax
	invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

	;Add some rows
	push	esi
	mov		esi,offset rdta
	mov		ecx,4
	.while ecx
		push	ecx
		invoke SendMessage,hGrd,GM_ADDROW,0,NULL;esi
		pop		ecx
		add		esi,sizeof rdta
		dec		ecx
	.endw
	pop		esi

	invoke SendMessage,hGrd,GM_SETCURSEL,0,0
	invoke SetFocus,hGrd
	retn

DlgProc endp

end start
