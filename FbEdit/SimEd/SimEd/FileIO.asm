.code

StreamInProc proc hFile:DWORD,pBuffer:DWORD,NumBytes:DWORD,pBytesRead:DWORD

	invoke ReadFile,hFile,pBuffer,NumBytes,pBytesRead,0
	xor		eax,1
	ret

StreamInProc endp

StreamOutProc proc hFile:DWORD,pBuffer:DWORD,NumBytes:DWORD,pBytesWritten:DWORD

	invoke WriteFile,hFile,pBuffer,NumBytes,pBytesWritten,0
	xor		eax,1
	ret

StreamOutProc endp

SaveFile proc hWin:DWORD,lpFileName:DWORD
	LOCAL	hFile:DWORD
	LOCAL	editstream:EDITSTREAM

	invoke CreateFile,lpFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		;stream the text to the file
		mov		editstream.dwCookie,eax
		mov		editstream.pfnCallback,offset StreamOutProc
		invoke SendMessage,hWin,EM_STREAMOUT,SF_TEXT,addr editstream
		invoke CloseHandle,hFile
		;Set the modify state to false
		invoke SendMessage,hWin,EM_SETMODIFY,FALSE,0
		;Update line changed state
		invoke SendMessage,hWin,REM_SETCHANGEDSTATE,TRUE,0
   		mov		eax,FALSE
	.else
		invoke MessageBox,hWnd,offset SaveFileFail,offset szAppName,MB_OK
		mov		eax,TRUE
	.endif
	ret

SaveFile endp

OFNHookProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		.if fUnicode
			invoke CheckDlgButton,hWin,1001,BST_CHECKED
		.endif
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		movzx	eax,ax
		shr		edx,16
		.if edx==BN_CLICKED && eax==1001
			invoke IsDlgButtonChecked,hWin,eax
			mov		fUnicode,eax
		.endif
	.endif
	xor		eax,eax
	ret

OFNHookProc endp

SaveEditAs proc hWin:DWORD,lpFileName:DWORD
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE

	;Zero out the ofn struct
    invoke RtlZeroMemory,addr ofn,sizeof ofn
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	push	hWnd
	pop		ofn.hwndOwner
	push	hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,NULL
	mov		buffer[0],0
	lea		eax,buffer
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,sizeof buffer
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT or OFN_ENABLETEMPLATE or OFN_EXPLORER or OFN_ENABLEHOOK
    mov		ofn.lpstrDefExt,NULL
	mov		ofn.lpTemplateName,100
	mov		ofn.lpfnHook,offset OFNHookProc
	invoke SendMessage,hWin,REM_GETUNICODE,0,0
	mov		fUnicode,eax
    ;Show save as dialog
	invoke GetSaveFileName,addr ofn
	.if eax
		invoke SendMessage,hWin,REM_SETUNICODE,fUnicode,0
		invoke SaveFile,hWin,addr buffer
		.if !eax
			;The file was saved
			invoke lstrcpy,offset FileName,addr buffer
			invoke SetWinCaption,offset FileName
			invoke TabToolGetMem,hWin
			invoke lstrcpy,addr [eax].TABMEM.filename,offset FileName
			invoke TabToolGetInx,hWin
			invoke TabToolSetText,eax,offset FileName
			mov		eax,FALSE
		.endif
	.else
		mov		eax,TRUE
	.endif
	ret

SaveEditAs endp

SaveEdit proc hWin:DWORD,lpFileName:DWORD

	;Check if filrname is (Untitled)
	invoke lstrcmp,lpFileName,offset NewFile
	.if eax
		invoke SaveFile,hWin,lpFileName
	.else
		invoke SaveEditAs,hWin,lpFileName
	.endif
	ret

SaveEdit endp

WantToSave proc hWin:DWORD,lpFileName:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[2]:BYTE

	invoke SendMessage,hWin,EM_GETMODIFY,0,0
	.if eax
		invoke lstrcpy,addr buffer,offset WannaSave
		invoke lstrcat,addr buffer,lpFileName
		mov		ax,'?'
		mov		word ptr buffer1,ax
		invoke lstrcat,addr buffer,addr buffer1
		invoke MessageBox,hWnd,addr buffer,offset szAppName,MB_YESNOCANCEL or MB_ICONQUESTION
		.if eax==IDYES
			invoke SaveEdit,hWin,lpFileName
	    .elseif eax==IDNO
		    mov		eax,FALSE
	    .else
		    mov		eax,TRUE
		.endif
	.endif
	ret

WantToSave endp

LoadFile proc uses ebx esi,hWin:DWORD,lpFileName:DWORD
    LOCAL   hFile:DWORD
	LOCAL	editstream:EDITSTREAM
	LOCAL	chrg:CHARRANGE

	;Open the file
	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		;Copy buffer to FileName
		invoke lstrcpy,offset FileName,lpFileName
		;Set word group
		invoke lstrlen,offset FileName
		mov		ebx,15
		.if eax>3
			mov		esi,eax
			xor		ebx,ebx
			invoke lstrcmpi,addr [esi+offset FileName-4],offset szFtAsm
			.if eax
				invoke lstrcmpi,addr [esi+offset FileName-4],offset szFtInc
				.if eax
					invoke lstrcmpi,addr [esi+offset FileName-3],offset szFtRc
					.if !eax
						;RC File
						inc		ebx
					.else
						;Unknown file type
						mov		ebx,15
						invoke GetWindowLong,hWin,GWL_STYLE
						or		eax,STYLE_NOHILITE
						invoke SetWindowLong,hWin,GWL_STYLE,eax
					.endif
				.endif
			.endif
		.endif
		invoke SendMessage,hWin,REM_SETWORDGROUP,0,ebx
		;stream the text into the RAEdit control
		push	hFile
		pop		editstream.dwCookie
		mov		editstream.pfnCallback,offset StreamInProc
		invoke SendMessage,hWin,EM_STREAMIN,SF_TEXT,addr editstream
		invoke CloseHandle,hFile
		invoke SendMessage,hWin,EM_SETMODIFY,FALSE,0
		invoke SendMessage,hWin,REM_SETCHANGEDSTATE,FALSE,0
		.if !ebx
			invoke SendMessage,hWin,REM_SETCOMMENTBLOCKS,addr szCmntStart,addr szCmntEnd
		.endif
		mov		chrg.cpMin,0
		mov		chrg.cpMax,0
		invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
		invoke SetWinCaption,offset FileName
		mov		eax,FALSE
	.else
		invoke MessageBox,hWnd,offset OpenFileFail,offset szAppName,MB_OK or MB_ICONERROR
		mov		eax,TRUE
	.endif
	ret

LoadFile endp

OpenEditFile proc uses esi,lpFileName:DWORD
	LOCAL	fClose:DWORD

	mov		fClose,0
	invoke lstrcmp,offset FileName,offset NewFile
	.if !eax
		invoke SendMessage,hREd,EM_GETMODIFY,0,0
		.if !eax
			mov		eax,hREd
			mov		fClose,eax
		.endif
	.endif
	invoke lstrcpy,offset FileName,lpFileName
	invoke UpdateAll,IS_OPEN
	.if !eax
		invoke CreateRAEdit
		invoke TabToolAdd,hREd,offset FileName
		invoke LoadCursor,0,IDC_WAIT
		invoke SetCursor,eax
		invoke LoadFile,hREd,offset FileName
		invoke LoadCursor,0,IDC_ARROW
		invoke SetCursor,eax
		invoke SendMessage,hREd,REM_SETBLOCKS,0,0
		invoke RefreshCombo,hREd
		.if fClose
			invoke TabToolDel,fClose
			invoke DestroyWindow,fClose
		.endif
	.endif
	invoke SetFocus,hREd
	ret

OpenEditFile endp

OpenEdit proc
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE

	;Zero out the ofn struct
	invoke RtlZeroMemory,addr ofn,sizeof ofn
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	push	hWnd
	pop		ofn.hwndOwner
	push	hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,offset ALLFilterString
	mov		buffer[0],0
	lea		eax,buffer
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,sizeof buffer
	mov		ofn.lpstrDefExt,NULL
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	;Show the Open dialog
	invoke GetOpenFileName,addr ofn
	.if eax
		invoke OpenEditFile,addr buffer
	.endif
	ret

OpenEdit endp

