
IDD_DLGSAVEUNICODE	equ 2800
IDC_CHKUNICODE		equ 1001

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

CloseProject proc

	.if hResEdSave
		invoke ShowWindow,hResEdSave,SW_SHOW
		invoke DestroyWindow,hResEd
		mov		eax,hResEdSave
		mov		hResEd,eax
		mov		hResEdSave,0
	.else
		invoke SendMessage,hResEd,PRO_CLOSE,0,0
	.endif
	invoke SetWinCaption,NULL,0
	ret

CloseProject endp

ReadProjectFile proc uses edi,lpFileName:DWORD,fText:DWORD
    LOCAL   hFile:DWORD
	LOCAL	hMem:DWORD
	LOCAL	hMemRes:DWORD
	LOCAL	dwRead:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	rect:RECT
	LOCAL	racol:RACOLOR
	LOCAL	editstream:EDITSTREAM

	.if fText
		;Open the file
		invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke CloseProject
			mov		eax,hResEd
			mov		hResEdSave,eax
			invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr szRAEditClass,NULL,WS_CHILD or WS_VISIBLE,0,0,0,0,hWnd,0,hInstance,NULL
			mov		hResEd,eax
			;Statusbar
			invoke GetDlgItem,hWnd,IDC_SBR1
			push	eax
			invoke MoveWindow,eax,0,0,0,0,FALSE
			pop		edx
			invoke GetWindowRect,edx,addr rect
			mov		ebx,rect.bottom
			sub		ebx,rect.top
			;ToolBar
			invoke GetDlgItem,hWnd,IDC_TBR1
			invoke MoveWindow,eax,0,0,rect.right,25,TRUE
			invoke GetClientRect,hWnd,addr rect
			mov		edx,rect.bottom
			sub		edx,ebx
			sub		edx,25
			invoke MoveWindow,hResEd,0,25,rect.right,edx,TRUE
			invoke ShowWindow,hResEdSave,SW_HIDE
			invoke SendMessage,hResEdSave,PRO_GETTEXTFONT,0,0
			invoke SendMessage,hResEd,WM_SETFONT,eax,0
			invoke SendMessage,hResEd,REM_GETCOLOR,0,addr racol
			mov		eax,col.back
			mov		racol.bckcol,eax
			mov		racol.cmntback,eax
			mov		racol.strback,eax
			mov		racol.numback,eax
			mov		racol.oprback,eax
			mov		eax,col.text
			mov		racol.txtcol,eax
			mov		racol.strcol,0
			invoke SendMessage,hResEd,REM_SETCOLOR,0,addr racol
			invoke SendMessage,hResEd,REM_SETWORDGROUP,0,2
			;stream the text into the RAEdit control
			mov		eax,hFile
			mov		editstream.dwCookie,eax
			mov		editstream.pfnCallback,offset StreamInProc
			invoke SendMessage,hResEd,EM_STREAMIN,SF_TEXT,addr editstream
			invoke CloseHandle,hFile
			invoke SendMessage,hResEd,EM_SETMODIFY,FALSE,0
			invoke lstrcpy,offset ProjectFileName,lpFileName
			invoke SetWinCaption,offset ProjectFileName,fModify
			invoke SetFocus,hResEd
			invoke SendMessage,hResEd,REM_GETUNICODE,0,0
			mov		fUnicode,eax
			mov		eax,TRUE
		.else
			invoke MessageBox,hWnd,offset szOpenFileFail,offset szAppName,MB_OK or MB_ICONERROR
			mov		eax,FALSE
		.endif
	.else
		;Open the file
		invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke CloseProject
			invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*1024
			mov     hMem,eax
			invoke GlobalLock,hMem
			invoke GetFileSize,hFile,NULL
			push	eax
			add		eax,2
			invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
			mov     hMemRes,eax
			pop		edx
			invoke ReadFile,hFile,hMemRes,edx,addr dwRead,NULL
			invoke CloseHandle,hFile
			mov		eax,hMemRes
			mov		fUnicode,FALSE
			.if word ptr [eax]==0FEFFh
				;Unicode
				mov		fUnicode,TRUE
				invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,dwRead
				mov		edi,eax
				mov		eax,hMemRes
				add		eax,2
				invoke WideCharToMultiByte,CP_ACP,0,eax,-1,edi,dwRead,0,0
				invoke GlobalFree,hMemRes
				mov		hMemRes,edi
			.endif
			;Copy buffer to ProjectFileName
			invoke lstrcpy,offset ProjectFileName,lpFileName
			.if grdsize.defines
				invoke CreateFile,addr IncludeFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
				.if eax!=INVALID_HANDLE_VALUE
					mov		hFile,eax
					invoke GetFileSize,hFile,NULL
					mov		edx,eax
					invoke ReadFile,hFile,hMem,edx,addr dwRead,NULL
					invoke CloseHandle,hFile
					mov		eax,hMem
					.if word ptr [eax]==0feffh
						;Unicode
						invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,dwRead
						mov		edi,eax
						invoke WideCharToMultiByte,CP_ACP,0,hMem,-1,edi,dwRead,0,0
						invoke lstrcpyW,hMem,edi
						invoke GlobalFree,edi
					.endif
				.endif
			.endif
			invoke lstrcat,hMem,hMemRes
			invoke GlobalFree,hMemRes
			invoke SendMessage,hResEd,PRO_OPEN,offset ProjectFileName,hMem
			invoke SetWinCaption,offset ProjectFileName,fModify
			invoke lstrcpy,addr buffer,offset ProjectFileName
			invoke lstrlen,addr buffer
			.while byte ptr buffer[eax]!='\' && eax
				dec		eax
			.endw
			mov		byte ptr buffer[eax],0
			lea		edx,buffer[eax+1]
			;invoke SendMessage,hResEd,PRO_SETNAME,edx,addr buffer
			invoke RemovePath,addr IncludeFileName,addr buffer
			invoke SendMessage,hResEd,PRO_SETDEFINE,0,eax
			invoke AddMruProject
		.else
			invoke MessageBox,hWnd,offset szOpenFileFail,offset szAppName,MB_OK or MB_ICONERROR
			mov		eax,FALSE
		.endif
	.endif
	ret

ReadProjectFile endp

OpenInclude proc lpProject:DWORD
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE

	;Zero out the ofn struct
	invoke RtlZeroMemory,addr ofn,sizeof ofn
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	push	hWnd
	pop		ofn.hwndOwner
	push	hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,offset szHFilterString
	mov		buffer,0
	.if ProjectPath
		mov		ofn.lpstrInitialDir,offset ProjectPath
		invoke SetCurrentDirectory,offset ProjectPath
	.endif
	lea		eax,buffer
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,sizeof buffer
	mov		ofn.lpstrDefExt,NULL
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	invoke lstrcpy,addr buffer1,offset szIncludeTitle
	invoke lstrcat,addr buffer1,lpProject
	lea		eax,buffer1
	mov		ofn.lpstrTitle,eax
	;Show the Open dialog
	invoke GetOpenFileName,addr ofn
	.if eax
		invoke lstrcpy,addr IncludeFileName,addr buffer
		mov		eax,TRUE
	.endif
	ret

OpenInclude endp

GetInclude proc lpProject:DWORD

	.if grdsize.defines==2
		invoke lstrcpy,addr ProjectPath,lpProject
		invoke lstrlen,addr ProjectPath
		.while byte ptr ProjectPath[eax]!='\' && eax
			dec		eax
		.endw
		mov		byte ptr ProjectPath[eax],0
		invoke OpenInclude,lpProject
		.if eax
			invoke ReadProjectFile,lpProject,FALSE
		.endif
	.else
		invoke lstrcpy,addr IncludeFileName,lpProject
		invoke lstrlen,addr IncludeFileName
		.while byte ptr IncludeFileName[eax-1]!='.' && eax
			dec		eax
		.endw
		mov		word ptr IncludeFileName[eax],'h'
		invoke ReadProjectFile,lpProject,FALSE
	.endif
	ret

GetInclude endp

OpenProject proc uses ebx,fText:DWORD
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE

	;Zero out the ofn struct
	invoke RtlZeroMemory,addr ofn,sizeof ofn
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	push	hWnd
	pop		ofn.hwndOwner
	push	hInstance
	pop		ofn.hInstance
	.if fText
		mov		ofn.lpstrFilter,offset szALLFilterString
	.else
		mov		ofn.lpstrFilter,offset szRCFilterString
	.endif
	mov		buffer[0],0
	.if ProjectPath
		mov		ofn.lpstrInitialDir,offset ProjectPath
	.endif
	lea		eax,buffer
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,sizeof buffer
	mov		ofn.lpstrDefExt,NULL
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	mov		ofn.lpstrTitle,offset szProjectTitle
	.if ProjectFileName
		invoke GetCurrentDirectory,sizeof buffer1,addr buffer1
		lea		eax,buffer1
		mov		ofn.lpstrInitialDir,eax
	.endif
	;Show the Open dialog
	invoke GetOpenFileName,addr ofn
	.if eax
		.if fText
			invoke ReadProjectFile,addr buffer,TRUE
		.else
			invoke GetInclude,addr buffer
		.endif
	.endif
	ret

OpenProject endp

WriteProjectFile proc uses edi,lpFileName:DWORD,fText:DWORD
	LOCAL	hMem:DWORD
	LOCAL	hMemDef:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nSize:DWORD
	LOCAL	buff[MAX_PATH]:BYTE
	LOCAL	editstream:EDITSTREAM

	.if fText
		invoke CreateFile,lpFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke SendMessage,hResEd,REM_SETUNICODE,fUnicode,0
			;stream the text to the file
			mov		eax,hFile
			mov		editstream.dwCookie,eax
			mov		editstream.pfnCallback,offset StreamOutProc
			invoke SendMessage,hResEd,EM_STREAMOUT,SF_TEXT,addr editstream
			invoke CloseHandle,hFile
			;Set the modify state to false
			invoke SendMessage,hResEd,EM_SETMODIFY,FALSE,0
			mov		fModify,0
			invoke SetWinCaption,offset ProjectFileName,fModify
			xor		eax,eax
		.else
			xor		eax,eax
			inc		eax
		.endif
	.else
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*1024
		mov		hMem,eax
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
		mov		hMemDef,eax
		invoke SendMessage,hResEd,PRO_EXPORT,hMemDef,hMem
		invoke SendMessage,hResEd,MEM_GETERR,0,0
		.if !eax
			invoke CreateFile,lpFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
			.if eax!=INVALID_HANDLE_VALUE
				mov		hFile,eax
				invoke lstrlen,hMem
				mov		nSize,eax
				.if fUnicode
					shl		eax,1
					add		eax,256
					push	eax
					invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
					mov		edi,eax
					pop		eax
					invoke MultiByteToWideChar,CP_ACP,0,hMem,nSize,addr [edi+2],eax
					mov		edx,eax
					inc		edx
					shl		edx,1
					mov		word ptr [edi],0feffh
					invoke WriteFile,hFile,edi,edx,addr nSize,NULL
					invoke GlobalFree,edi
				.else
					invoke WriteFile,hFile,hMem,nSize,addr nSize,NULL
				.endif
				invoke CloseHandle,hFile
				invoke SendMessage,hResEd,PRO_SETMODIFY,FALSE,0
				.if grdsize.defines
					invoke CreateFile,addr IncludeFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
					.if eax!=INVALID_HANDLE_VALUE
						mov		hFile,eax
						invoke lstrlen,hMemDef
						mov		nSize,eax
						.if fUnicode
							shl		eax,1
							add		eax,256
							push	eax
							invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
							mov		edi,eax
							pop		eax
							invoke MultiByteToWideChar,CP_ACP,0,hMemDef,nSize,addr [edi+2],eax
							mov		edx,eax
							inc		edx
							shl		edx,1
							mov		word ptr [edi],0feffh
							invoke WriteFile,hFile,edi,edx,addr nSize,NULL
							invoke GlobalFree,edi
						.else
							invoke WriteFile,hFile,hMemDef,nSize,addr nSize,NULL
						.endif
						invoke CloseHandle,hFile
					.endif
				.endif
				.if nmeexp.fAuto
					invoke SendMessage,hResEd,PRO_EXPORTNAMES,1,0
				.endif
				xor		eax,eax
			.endif
		.endif
		push	eax
		invoke GlobalFree,hMem
		invoke GlobalFree,hMemDef
		pop		eax
	.endif
	ret

WriteProjectFile endp

SaveIncludeFileAs proc lpFileName:DWORD
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke SendMessage,hResEd,PRO_GETMEM,0,0
	.if eax
		;Zero out the ofn struct
		invoke RtlZeroMemory,addr ofn,sizeof ofn
		;Setup the ofn struct
		mov		ofn.lStructSize,sizeof ofn
		push	hWnd
		pop		ofn.hwndOwner
		push	hInstance
		pop		ofn.hInstance
		mov		ofn.lpstrFilter,offset szHFilterString
		.if ProjectPath
			mov		ofn.lpstrInitialDir,offset ProjectPath
		.endif
		invoke lstrcpy,addr buffer,lpFileName
		invoke lstrlen,addr buffer
		.while buffer[eax-1]!='.' && eax
			dec		eax
		.endw
		mov		word ptr buffer[eax],'h'
		lea		eax,buffer
		mov		ofn.lpstrFile,eax
		mov		ofn.nMaxFile,sizeof buffer
		mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
		mov		ofn.lpstrDefExt,offset szDefHExt
		;Show save as dialog
		invoke GetSaveFileName,addr ofn
		.if eax
			invoke lstrcpy,offset IncludeFileName,addr buffer
			mov		eax,TRUE
		.endif
	.endif
	ret

SaveIncludeFileAs endp

UnicodeProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		.if fUnicode
			invoke CheckDlgButton,hWin,IDC_CHKUNICODE,BST_CHECKED
		.endif
	.elseif eax==WM_COMMAND
		.if wParam==IDC_CHKUNICODE
			invoke IsDlgButtonChecked,hWin,IDC_CHKUNICODE
			mov		fUnicode,eax
		.endif
	.endif
	mov		eax,FALSE
	ret

UnicodeProc endp

SaveProjectFileAs proc lpFileName:DWORD,fText:DWORD
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,fText
	.if !eax
		invoke SendMessage,hResEd,PRO_GETMEM,0,0
	.endif
	.if eax
		;Zero out the ofn struct
		invoke RtlZeroMemory,addr ofn,sizeof ofn
		;Setup the ofn struct
		mov		ofn.lStructSize,sizeof ofn
		push	hWnd
		pop		ofn.hwndOwner
		push	hInstance
		pop		ofn.hInstance
		.if fText
			mov		ofn.lpstrFilter,offset szALLFilterString
		.else
			mov		ofn.lpstrFilter,offset szRCFilterString
		.endif
		.if ProjectPath
			mov		ofn.lpstrInitialDir,offset ProjectPath
		.endif
		invoke lstrcpy,addr buffer,lpFileName
		lea		eax,buffer
		mov		ofn.lpstrFile,eax
		mov		ofn.nMaxFile,sizeof buffer
		mov		ofn.Flags,OFN_EXPLORER or OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT or OFN_ENABLETEMPLATE or OFN_ENABLEHOOK
		mov		ofn.lpstrDefExt,offset szDefRCExt
		mov		ofn.lpTemplateName,IDD_DLGSAVEUNICODE
		mov		ofn.lpfnHook,offset UnicodeProc
		;Show save as dialog
		invoke GetSaveFileName,addr ofn
		.if eax
			.if fText
				invoke lstrcpy,offset ProjectFileName,addr buffer
				invoke WriteProjectFile,offset ProjectFileName,TRUE
				push	eax
				invoke SetWinCaption,offset ProjectFileName,fModify
				pop		eax
			.else
				.if grdsize.defines==2
					invoke SaveIncludeFileAs,addr buffer
					.if eax
						invoke lstrcpy,offset ProjectFileName,addr buffer
						invoke lstrlen,addr buffer
						.while byte ptr buffer[eax]!='\' && eax
							dec		eax
						.endw
						mov		byte ptr buffer[eax],0
						lea		edx,buffer[eax+1]
						invoke SendMessage,hResEd,PRO_SETNAME,edx,addr buffer
						invoke RemovePath,addr IncludeFileName,addr buffer
						invoke SendMessage,hResEd,PRO_SETDEFINE,0,eax
						invoke WriteProjectFile,offset ProjectFileName,FALSE
						push	eax
						invoke SetWinCaption,offset ProjectFileName,fModify
						pop		eax
						.if !eax
							inc		eax
						.else
							xor		eax,eax
						.endif
					.endif
				.else
					invoke lstrcpy,offset ProjectFileName,addr buffer
					invoke lstrlen,addr buffer
					.while byte ptr buffer[eax]!='\' && eax
						dec		eax
					.endw
					mov		byte ptr buffer[eax],0
					lea		edx,buffer[eax+1]
					invoke SendMessage,hResEd,PRO_SETNAME,edx,addr buffer
					invoke lstrcpy,addr IncludeFileName,addr ProjectFileName
					invoke lstrlen,addr IncludeFileName
					.while IncludeFileName[eax-1]!='.' && eax
						dec		eax
					.endw
					mov		word ptr IncludeFileName[eax],'h'
					invoke RemovePath,addr IncludeFileName,addr buffer
					invoke SendMessage,hResEd,PRO_SETDEFINE,0,eax
					invoke WriteProjectFile,offset ProjectFileName,FALSE
					push	eax
					invoke SetWinCaption,offset ProjectFileName,fModify
					pop		eax
					.if !eax
						inc		eax
					.else
						xor		eax,eax
					.endif
				.endif
			.endif
		.endif
	.endif
	ret

SaveProjectFileAs endp

SaveProjectFile proc lpFileName:DWORD,fText:DWORD

	.if fText
		invoke SendMessage,hResEd,EM_GETMODIFY,0,0
	.else
		invoke SendMessage,hResEd,PRO_GETMEM,0,0
	.endif
	.if eax
		invoke lstrcmp,lpFileName,offset szNewFile
		.if !eax
			invoke SaveProjectFileAs,lpFileName,fText
		.else
			invoke WriteProjectFile,lpFileName,fText
			.if !eax
				inc		eax
			.else
				xor		eax,eax
			.endif
		.endif
	.endif
	ret

SaveProjectFile endp

WantToSaveProject proc lpFileName:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[2]:BYTE

	invoke SetFocus,hWnd
	.if hResEdSave
		invoke SendMessage,hResEd,EM_GETMODIFY,0,0
		.if eax
			invoke lstrcpy,addr buffer,offset szWannaSave
			invoke lstrcat,addr buffer,lpFileName
			mov		ax,'?'
			mov		word ptr buffer1,ax
			invoke lstrcat,addr buffer,addr buffer1
			invoke MessageBox,hWnd,addr buffer,offset szAppName,MB_YESNOCANCEL or MB_ICONQUESTION
			.if eax==IDYES
				invoke SaveProjectFile,lpFileName,TRUE
				dec		eax
			.elseif eax==IDNO
			    mov		eax,FALSE
			.else
			    mov		eax,TRUE
			.endif
		.endif
	.else
		invoke SendMessage,hResEd,PRO_GETMODIFY,0,0
		.if eax
			invoke lstrcpy,addr buffer,offset szWannaSave
			invoke lstrcat,addr buffer,lpFileName
			mov		ax,'?'
			mov		word ptr buffer1,ax
			invoke lstrcat,addr buffer,addr buffer1
			invoke MessageBox,hWnd,addr buffer,offset szAppName,MB_YESNOCANCEL or MB_ICONQUESTION
			.if eax==IDYES
				invoke SaveProjectFile,lpFileName,FALSE
				dec		eax
				push	eax
				invoke SendMessage,hResEd,PRO_GETMODIFY,0,0
				.if eax
					pop		eax
					push	1
				.endif
				pop		eax
			.elseif eax==IDNO
			    mov		eax,FALSE
			.else
			    mov		eax,TRUE
			.endif
		.endif
	.endif
	ret

WantToSaveProject endp

ExportDialog proc
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke SendMessage,hResEd,PRO_GETMEM,0,0
	.if eax
		;Zero out the ofn struct
		invoke RtlZeroMemory,addr ofn,sizeof ofn
		;Setup the ofn struct
		mov		ofn.lStructSize,sizeof ofn
		push	hWnd
		pop		ofn.hwndOwner
		push	hInstance
		pop		ofn.hInstance
		mov		ofn.lpstrFilter,offset szDLGFilterString
		mov		buffer,0
		lea		eax,buffer
		mov		ofn.lpstrFile,eax
		mov		ofn.nMaxFile,sizeof buffer
		mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
		mov		ofn.lpstrDefExt,offset szDefDLGExt
		;Show save as dialog
		invoke GetSaveFileName,addr ofn
		.if eax
			invoke SendMessage,hResEd,DEM_EXPORTDLG,0,addr buffer
		.endif
	.endif
	ret

ExportDialog endp
