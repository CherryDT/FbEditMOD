
.code

RefreshCombo proc hWin:DWORD
	LOCAL	nLine:DWORD
	LOCAL	buffer[256]:BYTE

	invoke SendMessage,hCbo,CB_RESETCONTENT,0,0
	mov		nLine,-1
  @@:
	invoke SendMessage,hWin,REM_NXTBOOKMARK,nLine,1
	.if eax!=-1
		mov		nLine,eax
		call	AddName
		jmp		@b
	.endif
	mov		nLine,-1
  @@:
	invoke SendMessage,hWin,REM_NXTBOOKMARK,nLine,2
	.if eax!=-1
		mov		nLine,eax
		call	AddName
		jmp		@b
	.endif
	invoke SendMessage,hCbo,CB_SETCURSEL,0,0
	ret

AddName:
	invoke SendMessage,hWin,REM_ISLINE,nLine,offset szProc
	.if eax!=-1
		mov		word ptr buffer,sizeof buffer-1
		invoke SendMessage,hWin,EM_GETLINE,nLine,addr buffer
		mov		byte ptr buffer[eax],0
		lea		edx,buffer-1
	  @@:
		inc		edx
		mov		al,[edx]
		cmp		al,VK_SPACE
		je		@b
		cmp		al,VK_TAB
		je		@b
		mov		ecx,edx
		dec		edx
	  @@:
		inc		edx
		mov		al,[edx]
		cmp		al,VK_SPACE
		je		@f
		cmp		al,VK_TAB
		je		@f
		or		al,al
		jne		@b
	  @@:
		mov		byte ptr [edx],0
		invoke SendMessage,hCbo,CB_ADDSTRING,0,ecx
	.endif
	retn

RefreshCombo endp

SelectCombo proc
	LOCAL	buffer[256]:BYTE
	LOCAL	ftxt:FINDTEXTEX

	invoke SendMessage,hCbo,CB_GETCURSEL,0,0
	.if eax!=CB_ERR
		mov		edx,eax
		invoke SendMessage,hCbo,CB_GETLBTEXT,edx,addr buffer
		lea		eax,buffer
		mov		ftxt.lpstrText,eax
		mov		ftxt.chrg.cpMin,0
		mov		ftxt.chrg.cpMax,-1
	  @@:
		invoke SendMessage,hREd,EM_FINDTEXTEX,FR_MATCHCASE or FR_WHOLEWORD or FR_DOWN,addr ftxt
		.if eax!=-1
			invoke SendMessage,hREd,EM_LINEFROMCHAR,ftxt.chrgText.cpMin,0
			invoke SendMessage,hREd,REM_GETBOOKMARK,eax,0
			.if eax==1 || eax==2
				;Mark the foud text
				invoke SendMessage,hREd,EM_EXSETSEL,0,addr ftxt.chrgText
				invoke SendMessage,hREd,REM_VCENTER,0,0
				invoke SetFocus,hREd
			.else
				mov		eax,ftxt.chrgText.cpMin
				inc		eax
				mov		ftxt.chrg.cpMin,eax
				jmp		@b
			.endif
		.endif
	.endif
	ret

SelectCombo endp