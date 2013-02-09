.code

DwToAscii proc uses ebx esi edi,dwVal:DWORD,lpAscii:DWORD

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
	ret

DwToAscii endp

DoToolBar proc hInst:DWORD,hToolBar:HWND
	LOCAL	tbab:TBADDBITMAP

	;Set toolbar struct size
	invoke SendMessage,hToolBar,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	;Set toolbar bitmap
	push	hInst
	pop		tbab.hInst
	mov		tbab.nID,IDB_TBRBMP
	invoke SendMessage,hToolBar,TB_ADDBITMAP,15,addr tbab
	;Set toolbar buttons
	invoke SendMessage,hToolBar,TB_ADDBUTTONS,ntbrbtns,offset tbrbtns
	mov		eax,hToolBar
	ret

DoToolBar endp

SetWinCaption proc lpFileName:DWORD
	LOCAL	buffer[sizeof szAppName+3+MAX_PATH]:BYTE
	LOCAL	buffer1[4]:BYTE

	;Add filename to windows caption
	invoke lstrcpy,addr buffer,offset szAppName
	mov		eax,' - '
	mov		dword ptr buffer1,eax
	invoke lstrcat,addr buffer,addr buffer1
	invoke lstrcat,addr buffer,lpFileName
	invoke SetWindowText,hWnd,addr buffer
	ret

SetWinCaption endp

SetFormat proc hWin:HWND
	LOCAL	rafnt:HEFONT

	mov		eax,hFont
	mov		rafnt.hFont,eax
	mov		eax,hLnrFont
	mov		rafnt.hLnrFont,eax
	;Set fonts
	invoke SendMessage,hWin,HEM_SETFONT,0,addr rafnt
;	;Set selection bar width
;	invoke SendMessage,hWin,HEM_SELBARWIDTH,20,0
;	;Set linenumber width
;	invoke SendMessage,hWin,HEM_LINENUMBERWIDTH,40,0
	ret

SetFormat endp

ShowPos proc nLine:DWORD,nPos:DWORD
	LOCAL	buffer[64]:BYTE

	mov		edx,nLine
	inc		edx
	invoke DwToAscii,edx,addr buffer[4]
	mov		dword ptr buffer,' :nL'
	invoke lstrlen,addr buffer
	mov		dword ptr buffer[eax],'soP '
	mov		dword ptr buffer[eax+4],' :'
	mov		edx,nPos
	inc		edx
	invoke DwToAscii,edx,addr buffer[eax+6]
	invoke SetDlgItemText,hWnd,IDC_SBR,addr buffer
	ret

ShowPos endp

RemoveFileExt proc lpFileName:DWORD

	invoke lstrlen,lpFileName
	mov		edx,lpFileName
	.while eax
		dec		eax
		.if byte ptr [edx+eax]=='.'
			mov		byte ptr [edx+eax],0
			.break
		.endif
	.endw
	ret

RemoveFileExt endp

RemoveFileName proc lpFileName:DWORD

	invoke lstrlen,lpFileName
	mov		edx,lpFileName
	.while eax
		dec		eax
		.if byte ptr [edx+eax]=='\'
			mov		byte ptr [edx+eax+1],0
			.break
		.endif
	.endw
	ret

RemoveFileName endp

MakeKey proc lpszStr:DWORD,nInx:DWORD,lpszKey:DWORD

	invoke lstrcpy,lpszKey,lpszStr
	invoke lstrlen,lpszKey
	add		eax,lpszKey
	invoke DwToAscii,nInx,eax
	ret

MakeKey endp

GetSelText proc lpBuff:DWORD
	LOCAL	chrg:CHARRANGE

	invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
	mov		eax,chrg.cpMax
	sub		eax,chrg.cpMin
	.if eax && eax<256
		invoke SendMessage,hREd,EM_GETSELTEXT,0,lpBuff
	.endif
	ret

GetSelText endp
