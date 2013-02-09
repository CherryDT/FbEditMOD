.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include GridDemo3.inc
include ..\RAGrid.inc
include Random.asm

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

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	col:COLUMN
	LOCAL	rdta:ROWDATA
	LOCAL	rect:RECT
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer1[64]:BYTE
	LOCAL	buffer2[64]:BYTE
	LOCAL	cm:COLORMAP
	LOCAL	val:DWORD

	mov		eax,uMsg
	.if eax==WM_COMPAREITEM
		mov		edx,lParam
		;Get pointer to first data
		mov		eax,[edx].COMPAREITEMSTRUCT.itemData1
		;Get pointer to second data
		mov		edx,[edx].COMPAREITEMSTRUCT.itemData2
		;In this case the user data are unsigned words
		movzx	eax,word ptr [eax]
		movzx	edx,word ptr [edx]
		sub		eax,edx
		.if sdword ptr eax>0
			xor		eax,eax
			inc		eax
		.elseif sdword ptr eax<0
			xor		eax,eax
			dec		eax
		.endif
		ret
	.elseif eax==WM_INITDIALOG
		invoke GetTickCount
		mov		rseed,eax
		mov		eax,hWin
		mov		hWnd,eax
		invoke GetDlgItem,hWin,IDC_GRD1
		mov		hGrd,eax

		invoke SendMessage,hGrd,GM_SETBACKCOLOR,0C0FFFFh,0
		invoke SendMessage,hGrd,GM_SETGRIDCOLOR,808080h,0
		invoke SendMessage,hGrd,GM_SETTEXTCOLOR,800000h,0

		;Add index column
		mov		col.colwt,50
		mov		col.lpszhdrtext,offset szIndex
		mov		col.halign,GA_ALIGN_RIGHT
		mov		col.calign,GA_ALIGN_RIGHT
		mov		col.ctype,TYPE_EDITLONG
		mov		col.ctextmax,6
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;Add Name column
		mov		col.colwt,150
		mov		col.lpszhdrtext,offset szName
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,31
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;Add Address column
		mov		col.colwt,150
		mov		col.lpszhdrtext,offset szAddress
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,31
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;Add Points column
		mov		col.colwt,50
		mov		col.lpszhdrtext,offset szPoints
		mov		col.halign,GA_ALIGN_RIGHT
		mov		col.calign,GA_ALIGN_RIGHT
		mov		col.ctype,TYPE_EDITLONG
		mov		col.ctextmax,4
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;Add User column
		mov		col.colwt,50
		mov		col.lpszhdrtext,offset szUser
		mov		col.halign,GA_ALIGN_RIGHT
		mov		col.calign,GA_ALIGN_RIGHT
		mov		col.ctype,TYPE_USER
		mov		col.ctextmax,2
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col

		;Add some rows
		lea		eax,buffer1
		mov		rdta.lpszName,eax
		lea		eax,buffer2
		mov		rdta.lpszAddress,eax
		mov		rdta.inx,0
		mov		ecx,65536
;		mov		ecx,32768
		.while ecx
			push	ecx
			inc		rdta.inx
			invoke RandomStr,addr buffer1
			invoke RandomStr,addr buffer2
			invoke Random,99999
			and		eax,1
			mov		rdta.nPoints,eax
			invoke Random,0FFFFh
			mov		rdta.nUser,ax
			invoke SendMessage,hGrd,GM_ADDROW,0,addr rdta
			pop		ecx
			dec		ecx
		.endw

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
;			.elseif eax==GN_BUTTONCLICK
;			.elseif eax==GN_CHECKCLICK
;			.elseif eax==GN_IMAGECLICK
;			.elseif eax==GN_BEFORESELCHANGE
;			.elseif eax==GN_AFTERSELCHANGE
;			.elseif eax==GN_BEFOREEDIT
;			.elseif eax==GN_AFTEREDIT
;			.elseif eax==GN_BEFOREUPDATE
;			.elseif eax==GN_AFTERUPDATE
			.elseif eax==GN_USERCONVERT
				;Get pointer to data
				mov		eax,[esi].GRIDNOTIFY.lpdata
				;In this case the user data are unsigned words
				movzx	eax,word ptr [eax]
				invoke BinToDec,eax,[esi].GRIDNOTIFY.lpdata
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

DlgProc endp

end start
