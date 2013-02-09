
;MOUSEINPUT struct
;	x			DWORD ?
;	y			DWORD ?
;	mouseData	DWORD ?
;	dwFlags		DWORD ?
;	time		DWORD ?
;	dwExtraInfo	DWORD ?
;MOUSEINPUT ends
;
;KEYBDINPUT struct
;	wVk			WORD ?
;	wScan		WORD ?
;	dwFlags		DWORD ?
;	time		DWORD ?
;	dwExtraInfo	DWORD ?
;KEYBDINPUT ends

INPUT struct
	ntype		DWORD ?
	wVk			DWORD ?
	dwFlags		DWORD ?
	time		DWORD ?
	dwExtraInfo	DWORD ? 
	zx			DWORD ?
	zy			DWORD ?
INPUT ends

.const

szFmtTime						db '%s:',VK_TAB,'%02d:%02d:%02d (%d,%d)',0
szFmtMessage					db '%s:',VK_TAB,'%02d:%02d:%02d (%08X,%08X,%08X,%08X)',0
szCUT							db 'CUT',0
szPASTE							db 'PASTE',0
szRadASMLog						db 'C:\RadASM.log',0
szCRLF							db 0Dh,0Ah,0
szCTRLX							db 'Ctrl+X',0
szCTRLV							db 'Ctrl+V',0
szRAE							db 'RAE',0
szMAIN							db 'MAIN',0
szMDI							db 'MDI',0
szTIMER							db 'TIMER',0

.data

keycut							INPUT <INPUT_KEYBOARD,VK_CONTROL,0,0,0,0,0>
								INPUT <INPUT_KEYBOARD,VK_X,0,0,0,0,0>
								INPUT <INPUT_KEYBOARD,VK_X,KEYEVENTF_KEYUP,0,0,0,0>
								INPUT <INPUT_KEYBOARD,VK_CONTROL,KEYEVENTF_KEYUP,0,0,0,0>

keycopy							INPUT <INPUT_KEYBOARD,VK_CONTROL,0,0,0,0>
								INPUT <INPUT_KEYBOARD,VK_C,0,0,0,0,0>
								INPUT <INPUT_KEYBOARD,VK_C,KEYEVENTF_KEYUP,0,0,0,0>
								INPUT <INPUT_KEYBOARD,VK_CONTROL,KEYEVENTF_KEYUP,0,0,0,0>

keypaste						INPUT <INPUT_KEYBOARD,VK_CONTROL,0,0,0,0,0>
								INPUT <INPUT_KEYBOARD,VK_V,0,0,0,0,0>
								INPUT <INPUT_KEYBOARD,VK_V,KEYEVENTF_KEYUP,0,0,0,0>
								INPUT <INPUT_KEYBOARD,VK_CONTROL,KEYEVENTF_KEYUP,0,0,0,0>

.data?

rseed							DWORD ?
fCutPaste						DWORD ?
logbuff							BYTE 1024 dup(?)
fTest							DWORD ?
fBreak							DWORD ?

.code

Random proc uses ecx edx,range:DWORD

	mov eax, rseed
	mov ecx, 23
	mul ecx
	add eax, 7
	and eax, 0FFFFFFFFh
	ror eax, 1
	xor eax, rseed
	mov rseed, eax
	mov ecx, range
	xor edx, edx
	div ecx
	mov eax, edx
	ret

Random endp

TestProc proc uses ebx esi edi,Param:DWORD
	LOCAL	nLnStart:DWORD
	LOCAL	nLnEnd:DWORD
	LOCAL	chrg:CHARRANGE

;	invoke GetTickCount
;	mov		rseed,eax
	xor		ebx,ebx
	.while ebx<20000
		invoke SendMessage,ha.hTab,TCM_GETITEMCOUNT,0,0
		dec		eax
		invoke Random,eax
		invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
		.if eax!=-1
			invoke TabToolActivate
			.if ha.hMdi
				invoke GetWindowLong,ha.hEdt,GWL_ID
				.if eax==ID_EDITCODE || eax==ID_EDITTEXT
					invoke SetFocus,ha.hEdt
					call	Paste
;					invoke Random,10
;					.if eax<=6
;						call	Copy
;						invoke Sleep,20
;						call	Paste
;					.else
;						call	Cut
;						invoke Sleep,20
;						call	Paste
;					.endif
				.endif
			.endif
		.endif
		invoke Random,50
		add		eax,200
		invoke Sleep,eax
		inc		ebx
		.break.if fBreak
	.endw
	ret

Cut:
	invoke SendMessage,ha.hEdt,EM_GETLINECOUNT,0,0
	sub		eax,50
	invoke Random,eax
	mov		nLnStart,eax
	invoke Random,30
	inc		eax
	add		eax,nLnStart
	mov		nLnEnd,eax
	invoke SendMessage,ha.hEdt,EM_LINEINDEX,nLnStart,0
	mov		chrg.cpMin,eax
	invoke SendMessage,ha.hEdt,EM_LINEINDEX,nLnEnd,0
	mov		chrg.cpMax,eax
	invoke SendMessage,ha.hEdt,EM_EXSETSEL,0,addr chrg
	invoke SendInput,4,addr keycut,sizeof INPUT
	.while !fCutPaste
		invoke Sleep,10
	.endw
	.while fCutPaste
		invoke Sleep,10
	.endw
	retn

Copy:
	invoke SendMessage,ha.hEdt,EM_GETLINECOUNT,0,0
	sub		eax,50
	invoke Random,eax
	invoke Random,30
	inc		eax
	add		eax,nLnStart
	mov		nLnEnd,eax
	invoke SendMessage,ha.hEdt,EM_LINEINDEX,nLnStart,0
	mov		chrg.cpMin,eax
	invoke SendMessage,ha.hEdt,EM_LINEINDEX,nLnEnd,0
	mov		chrg.cpMax,eax
	invoke SendMessage,ha.hEdt,EM_EXSETSEL,0,addr chrg
	invoke SendInput,4,addr keycopy,sizeof INPUT
	retn

Paste:
	invoke SendMessage,ha.hEdt,EM_GETLINECOUNT,0,0
	dec		eax
	invoke Random,eax
	mov		nLnStart,eax
	invoke SendMessage,ha.hEdt,EM_LINEINDEX,nLnStart,0
	mov		chrg.cpMin,eax
	mov		chrg.cpMax,eax
	invoke SendMessage,ha.hEdt,EM_EXSETSEL,0,addr chrg
	invoke SendInput,4,addr keypaste,sizeof INPUT
;	.while !fCutPaste
;		invoke Sleep,10
;	.endw
;	.while fCutPaste
;		invoke Sleep,10
;	.endw
	retn

TestProc ENDP

WriteToLog proc lpStr:DWORD
	LOCAL	hFile:DWORD
	LOCAL	dwWrite:DWORD

	pushad
	invoke strcat,lpStr,addr szCRLF
	invoke CreateFile,addr szRadASMLog,GENERIC_WRITE,FILE_SHARE_READ,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke SetFilePointer,hFile,0,NULL,FILE_END
		invoke lstrlen,lpStr
		mov		edx,eax
		invoke WriteFile,hFile,lpStr,edx,addr dwWrite,NULL
		invoke CloseHandle,hFile
	.endif
	popad
	ret

WriteToLog endp

LogTimeString proc lpStr:DWORD,cpMin:DWORD,cpMax:DWORD
	LOCAL	systime:SYSTEMTIME

	pushad
	invoke GetSystemTime,addr systime
	movzx	eax,systime.wHour
	movzx	ecx,systime.wMinute
	movzx	edx,systime.wSecond
	invoke wsprintf,addr logbuff,addr szFmtTime,lpStr,eax,ecx,edx,cpMin,cpMax
	invoke WriteToLog,addr logbuff
	popad
	ret

LogTimeString endp

LogTimeMessage proc lpStr:DWORD,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	systime:SYSTEMTIME

	pushad
	invoke GetSystemTime,addr systime
	movzx	eax,systime.wHour
	movzx	ecx,systime.wMinute
	movzx	edx,systime.wSecond
	invoke wsprintf,addr logbuff,addr szFmtMessage,lpStr,eax,ecx,edx,hWin,uMsg,wParam,lParam
	invoke WriteToLog,addr logbuff
	popad
	ret

LogTimeMessage endp
