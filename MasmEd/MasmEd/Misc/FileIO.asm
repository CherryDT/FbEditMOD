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

SaveFile proc uses ebx,hWin:DWORD,lpFileName:DWORD
	LOCAL	hFile:DWORD
	LOCAL	editstream:EDITSTREAM
	LOCAL	hMem:DWORD
	LOCAL	nSize:DWORD

	invoke TabToolGetMem,hWin
	mov		ebx,eax
	mov		[ebx].TABMEM.fnonotify,TRUE
	invoke GetWindowLong,hWin,GWL_ID
	invoke PostAddinMessage,hWin,AIM_FILESAVE,eax,lpFileName,0,HOOK_FILESAVE
	.if !eax
		invoke CreateFile,lpFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			mov		eax,hWin
			.if eax==ha.hRes
				invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
				mov		hMem,eax
				invoke SendMessage,ha.hResEd,PRO_EXPORT,0,hMem
				invoke strlen,hMem
				mov		nSize,eax
				invoke WriteFile,hFile,hMem,nSize,addr nSize,NULL
				invoke SendMessage,ha.hResEd,PRO_SETMODIFY,FALSE,0
				invoke GlobalFree,hMem
				.if nmeexp.fAuto
					invoke SendMessage,ha.hResEd,PRO_EXPORTNAMES,1,ha.hOut
				.endif
			.else
				;stream the text to the file
				mov		eax,hFile
				mov		editstream.dwCookie,eax
				mov		editstream.pfnCallback,offset StreamOutProc
				invoke SendMessage,hWin,EM_STREAMOUT,SF_TEXT,addr editstream
				;Set the modify state to false
				invoke SendMessage,hWin,EM_SETMODIFY,FALSE,0
				invoke GetWindowLong,hWin,GWL_ID
				.if eax==IDC_RAE
					invoke SendMessage,hWin,REM_SETCHANGEDSTATE,TRUE,0
					invoke SaveBreakpoints,hWin
					invoke SaveBookMarks,hWin
					invoke SaveCollapse,hWin
				.endif
			.endif
			invoke CloseHandle,hFile
			invoke UpdateFileTime,ebx
			invoke TabToolSetChanged,hWin,FALSE
	   		mov		eax,FALSE
		.else
			invoke strcpy,offset tmpbuff,offset szSaveFileFail
			invoke strcat,offset tmpbuff,lpFileName
			invoke MessageBox,ha.hWnd,offset tmpbuff,offset szAppName,MB_OK or MB_ICONERROR
			mov		eax,TRUE
		.endif
	.else
		xor		eax,eax
	.endif
	mov		[ebx].TABMEM.nchange,0
	mov		[ebx].TABMEM.fchanged,0
	ret

SaveFile endp

UnicodeProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		.if fUnicode
			invoke CheckDlgButton,hWin,IDC_CHKUNICODE,BST_CHECKED
		.endif
	.elseif eax==WM_COMMAND
		invoke IsDlgButtonChecked,hWin,IDC_CHKUNICODE
		mov		fUnicode,eax
	.endif
	xor		eax,eax
	ret

UnicodeProc endp

UpdateFileName proc hWin:DWORD,lpFileName:DWORD

	invoke GetWindowLong,hWin,GWL_ID
	.if eax!=IDC_RAE
		invoke SendMessage,hWin,REM_SETUNICODE,fUnicode,0
	.endif
	invoke SaveFile,hWin,lpFileName
	.if !eax
		;The file was saved
		invoke TabToolGetInx,hWin
		invoke TabToolSetText,eax,lpFileName
		mov		eax,FALSE
	.endif
	ret

UpdateFileName endp

SaveEditAs proc hWin:DWORD,lpFileName:DWORD
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke GetWindowLong,hWin,GWL_ID
	invoke PostAddinMessage,hWin,AIM_FILESAVEAS,eax,lpFileName,0,HOOK_FILESAVEAS
	.if !eax
		;Zero out the ofn struct
	    invoke RtlZeroMemory,addr ofn,sizeof ofn
		;Setup the ofn struct
		mov		ofn.lStructSize,sizeof ofn
		push	ha.hWnd
		pop		ofn.hwndOwner
		push	ha.hInstance
		pop		ofn.hInstance
		mov		ofn.lpstrFilter,NULL
		invoke strcpy,addr buffer,addr da.FileName
		lea		eax,buffer
		mov		ofn.lpstrFile,eax
		mov		ofn.nMaxFile,sizeof buffer
		invoke GetWindowLong,hWin,GWL_ID
		.if eax==IDC_RAE
			mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT or OFN_EXPLORER or OFN_ENABLETEMPLATE or OFN_ENABLEHOOK
			mov		ofn.lpTemplateName,IDD_DLGSAVEUNICODE
			mov		ofn.lpfnHook,offset UnicodeProc
			invoke SendMessage,hWin,REM_GETUNICODE,0,0
			mov		fUnicode,eax
		.else
			xor		eax,eax
			mov		fUnicode,eax
			mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT or OFN_EXPLORER
		.endif
	    mov		ofn.lpstrDefExt,NULL
	    ;Show save as dialog
		invoke GetSaveFileName,addr ofn
		.if eax
			invoke UpdateFileName,hWin,addr buffer
			.if !eax
				.if da.fProject
					invoke SendMessage,ha.hPbr,RPBM_FINDITEM,0,lpFileName
					.if eax
						invoke lstrcpy,addr [eax].PBITEM.szitem,addr buffer
						invoke SendMessage,ha.hPbr,RPBM_SETGROUPING,TRUE,RPBG_NOCHANGE
					.endif
				.endif
				mov		eax,hWin
				.if eax==ha.hREd
					invoke strcpy,offset da.FileName,addr buffer
					invoke SetWinCaption,addr buffer
				.endif
			.endif
		.else
			mov		eax,TRUE
		.endif
	.endif
	ret

SaveEditAs endp

SaveEdit proc hWin:DWORD,lpFileName:DWORD

	;Check if filrname is (Untitled)
	invoke strcmp,lpFileName,offset szNewFile
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

	invoke GetWindowLong,hWin,GWL_ID
	.if eax==IDC_USER
		invoke PostAddinMessage,hWin,AIM_GETMODIFY,eax,lpFileName,0,HOOK_GETMODIFY
	.else
		invoke SendMessage,hWin,EM_GETMODIFY,0,0
	.endif
	.if eax
		invoke strcpy,addr buffer,offset szWannaSave
		invoke strcat,addr buffer,lpFileName
		mov		ax,'?'
		mov		word ptr buffer1,ax
		invoke strcat,addr buffer,addr buffer1
		invoke MessageBox,ha.hWnd,addr buffer,offset szAppName,MB_YESNOCANCEL or MB_ICONQUESTION
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

LoadEditFile proc uses ebx esi,hWin:DWORD,lpFileName:DWORD
    LOCAL   hFile:DWORD
	LOCAL	editstream:EDITSTREAM
	LOCAL	chrg:CHARRANGE

	;Open the file
	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		;Copy buffer to da.FileName
		invoke strcpy,offset da.FileName,lpFileName
		;Set word group
		invoke strlen,offset da.FileName
		mov		ebx,15
		.if eax>3
			mov		esi,eax
			xor		ebx,ebx
			invoke strcmpi,addr [esi+offset da.FileName-4],offset szFtAsm
			.if eax
				invoke strcmpi,addr [esi+offset da.FileName-4],offset szFtInc
				.if eax
					invoke strcmpi,addr [esi+offset da.FileName-4],offset szFtApi
					.if eax
						invoke strcmpi,addr [esi+offset da.FileName-3],offset szFtRc
						.if !eax
							;RC File
							mov		ebx,2
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
		.endif
		invoke SendMessage,hWin,REM_SETWORDGROUP,0,ebx
		invoke SendMessage,hWin,WM_SETTEXT,0,addr szNULL
		;stream the text into the RAEdit control
		push	hFile
		pop		editstream.dwCookie
		mov		editstream.pfnCallback,offset StreamInProc
		invoke SendMessage,hWin,EM_STREAMIN,SF_TEXT,addr editstream
		invoke CloseHandle,hFile
		invoke SendMessage,hWin,EM_SETMODIFY,FALSE,0
		invoke SendMessage,hWin,REM_SETCHANGEDSTATE,FALSE,0
		mov		chrg.cpMin,0
		mov		chrg.cpMax,0
		invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
		invoke SetWinCaption,offset da.FileName
		.if !ebx
			mov		nLastLine,-1
			mov		nLastPropLine,-1
			.if !da.fProject
				invoke ParseEdit,hWin,0;[eax].TABMEM.pid
			.endif
		.endif
		mov		eax,FALSE
	.else
		invoke strcpy,offset tmpbuff,offset szOpenFileFail
		invoke strcat,offset tmpbuff,lpFileName
		invoke MessageBox,ha.hWnd,offset tmpbuff,offset szAppName,MB_OK or MB_ICONERROR
		mov		eax,TRUE
	.endif
	ret

LoadEditFile endp

LoadHexFile proc uses ebx esi,hWin:DWORD,lpFileName:DWORD
    LOCAL   hFile:DWORD
	LOCAL	editstream:EDITSTREAM
	LOCAL	chrg:CHARRANGE

	;Open the file
	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		;Copy buffer to da.FileName
		invoke strcpy,offset da.FileName,lpFileName
		;stream the text into the RAHexEd control
		push	hFile
		pop		editstream.dwCookie
		mov		editstream.pfnCallback,offset StreamInProc
		invoke SendMessage,hWin,EM_STREAMIN,SF_TEXT,addr editstream
		invoke CloseHandle,hFile
		invoke SendMessage,hWin,EM_SETMODIFY,FALSE,0
		mov		chrg.cpMin,0
		mov		chrg.cpMax,0
		invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
		invoke SetWinCaption,offset da.FileName
		mov		eax,FALSE
	.else
		invoke strcpy,offset tmpbuff,offset szOpenFileFail
		invoke strcat,offset tmpbuff,lpFileName
		invoke MessageBox,ha.hWnd,offset tmpbuff,offset szAppName,MB_OK or MB_ICONERROR
		mov		eax,TRUE
	.endif
	ret

LoadHexFile endp

IsFileResource proc lpFile:DWORD

	invoke strlen,lpFile
	mov		edx,lpFile
	lea		edx,[edx+eax-3]
	mov		edx,[edx]
	and		edx,0FF5F5Fffh
	xor		eax,eax
	.if edx=='CR.'
		inc		eax
	.endif
	ret

IsFileResource endp

LoadRCFile proc lpFileName:DWORD
    LOCAL   hFile:DWORD
	LOCAL	hMem:DWORD
	LOCAL	dwRead:DWORD

	;Open the file
	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		push	eax
		inc		eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
		mov     hMem,eax
		invoke GlobalLock,hMem
		pop		edx
		invoke ReadFile,hFile,hMem,edx,addr dwRead,NULL
		invoke CloseHandle,hFile
		invoke SendMessage,ha.hResEd,PRO_OPEN,lpFileName,hMem
		mov		eax,TRUE
	.else
		invoke strcpy,offset tmpbuff,offset szOpenFileFail
		invoke strcat,offset tmpbuff,lpFileName
		invoke MessageBox,ha.hWnd,offset tmpbuff,offset szAppName,MB_OK or MB_ICONERROR
		mov		eax,TRUE
	.endif
	ret

LoadRCFile endp

IsFileType proc uses ebx esi edi,lpFileType:DWORD,lpFileTypes:DWORD

	mov		esi,lpFileTypes
	mov		edi,lpFileType
	.while TRUE
		xor		ecx,ecx
		.while byte ptr [edi+ecx]
			mov		al,[edi+ecx]
			mov		ah,[esi+ecx]
			.if al>='a' && al<='z'
				and		al,5Fh
			.endif
			.if ah>='a' && ah<='z'
				and		ah,5Fh
			.endif
			.break .if al!=ah
			inc		ecx
		.endw
		.if !byte ptr [edi+ecx]
			mov		eax,TRUE
			jmp		Ex
		.endif
		inc		esi
		.while byte ptr [esi]!='.'
			inc		esi
		.endw
		.break .if !byte ptr [esi+1]
	.endw
	xor		eax,eax
  Ex:
	ret

IsFileType endp

LoadExternalFile proc uses esi,lpFileName:DWORD
	LOCAL	nInx:DWORD
	LOCAL	mnu:MENU
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	fileext[32]:BYTE

	mov		esi,lpFileName
	invoke strlen,esi
	.while byte ptr [esi+eax]!='.' && eax
		dec		eax
	.endw
	.if eax
		invoke strcpyn,addr fileext,addr [esi+eax],30
		invoke strcat,addr fileext,addr szDot
		mov		nInx,1
		.while nInx<20
			mov		mnu.szcap,0
			mov		mnu.szcmnd,0
			invoke MakeKey,addr szMenuExternal,nInx,addr buffer
			mov		lpcbData,sizeof mnu
			invoke RegQueryValueEx,ha.hReg,addr buffer,0,addr lpType,addr mnu,addr lpcbData
			.if mnu.szcap
				invoke IsFileType,addr fileext,addr mnu.szcap
				.if eax
					invoke lstrcpy,addr buffer,addr szQuote
					invoke lstrcat,addr buffer,lpFileName
					invoke lstrcat,addr buffer,addr szQuote
					invoke ShellExecute,ha.hWnd,NULL,addr mnu.szcmnd,addr buffer,NULL,SW_SHOWNORMAL
					mov		eax,TRUE
					jmp		Ex
				.endif
			.else
				.break
			.endif
			inc		nInx
		.endw
	.endif
	xor		eax,eax
  Ex:
	ret

LoadExternalFile endp

OpenEditFile proc uses ebx esi,lpFileName:DWORD,fType:DWORD
	LOCAL	buffer[MAX_PATH*2]:BYTE
	LOCAL	fCtrl:DWORD

	invoke strcpy,addr buffer,lpFileName
	invoke CharUpper,addr buffer
	xor		eax,eax
	.if fType==0
		invoke GetKeyState,VK_CONTROL
		and		eax,80h
		.if !eax
			invoke strlen,addr buffer
			mov		eax,dword ptr buffer[eax-4]
			.if eax=='EXE.' || eax=='TAB.' || eax=='MOC.'
				invoke PostAddinMessage,ha.hWnd,AIM_FILEOPEN,IDC_EXECUTE,lpFileName,0,HOOK_FILEOPEN
				.if !eax
					invoke WinExec,lpFileName,SW_SHOWNORMAL
					invoke PostAddinMessage,ha.hWnd,AIM_FILEOPENED,IDC_EXECUTE,lpFileName,0,HOOK_FILEOPENED
				.endif
				ret
			.endif
			xor		eax,eax
		.endif
	.endif
	mov		fCtrl,eax
	invoke strcpy,offset da.FileName,lpFileName
	invoke UpdateAll,IS_OPEN_ACTIVATE,0
	.if !eax
		invoke GetFileAttributes,lpFileName
		.if eax!=-1
			xor		eax,eax
			.if fType==0 || fType==IDC_RES
				invoke IsFileResource,lpFileName
			.endif
			.if eax && !fCtrl
				invoke UpdateAll,IS_RESOURCE,0
				.if eax
					invoke WantToSave,ha.hREd,offset da.FileName
					.if !eax
						invoke PostAddinMessage,ha.hWnd,AIM_FILEOPEN,IDC_RES,lpFileName,0,HOOK_FILEOPEN
						.if !eax
							invoke LoadRCFile,lpFileName
							.if eax
								invoke TabToolGetInx,ha.hREd
								invoke TabToolSetText,eax,lpFileName
								invoke SetWinCaption,lpFileName
								invoke strcpy,offset da.FileName,lpFileName
								invoke AddMRU,offset mrufiles,lpFileName
								invoke ResetMenu
								invoke PostAddinMessage,ha.hWnd,AIM_FILEOPENED,IDC_RES,lpFileName,0,HOOK_FILEOPENED
							.endif
						.endif
					.endif
				.else
					invoke PostAddinMessage,ha.hWnd,AIM_FILEOPEN,IDC_RES,lpFileName,0,HOOK_FILEOPEN
					.if !eax
						invoke LoadRCFile,lpFileName
						.if eax
							invoke ShowWindow,ha.hREd,SW_HIDE
							mov		eax,ha.hRes
							mov		ha.hREd,eax
							invoke TabToolAdd,ha.hREd,lpFileName
							invoke SendMessage,ha.hWnd,WM_SIZE,0,0
							invoke ShowWindow,ha.hREd,SW_SHOW
							invoke SetWinCaption,lpFileName
							invoke strcpy,offset da.FileName,lpFileName
							invoke AddMRU,offset mrufiles,lpFileName
							invoke ResetMenu
							invoke PostAddinMessage,ha.hWnd,AIM_FILEOPENED,IDC_RES,lpFileName,0,HOOK_FILEOPENED
						.endif
					.endif
				.endif
			.else
				.if !fCtrl
					invoke LoadExternalFile,lpFileName
					.if eax
						jmp		Ex
					.endif
				.endif
				invoke strlen,addr buffer
				mov		eax,dword ptr buffer[eax-4]
				.if (fType==0 || fType==IDC_RAE) && eax!='EXE.' && eax!='MOC.' && eax!='JBO.' && eax!='SER.' && eax!='BIL.' && eax!='PMB.' && eax!='OCI.' && eax!='GPJ.' && eax!='INA.' && eax!='IVA.' && eax!='GNP.' && eax!='RUC.' && eax!='SEM.'
					mov		ebx,IDC_RAE
				.elseif eax=='SEM.'
					.if fCtrl
						mov		ebx,IDC_RAE
					.else
						mov		ebx,IDC_MES
					.endif
				.else
					mov		ebx,IDC_HEX
				.endif
				invoke strcpy,addr buffer,lpFileName
				invoke PostAddinMessage,ha.hWnd,AIM_FILEOPEN,ebx,addr buffer,0,HOOK_FILEOPEN
				.if !eax
					invoke LoadCursor,0,IDC_WAIT
					invoke SetCursor,eax
					.if ebx==IDC_MES
						; Session
						mov		nTabInx,-1
						invoke UpdateAll,WM_CLOSE,0
						.if !eax
							invoke AskSaveSessionFile
							.if !eax
								invoke AddMRU,offset mrusessions,addr buffer
								invoke CloseNotify
								invoke UpdateAll,CLOSE_ALL,0
								invoke ReadSessionFile,addr buffer
							.endif
						.endif
					.elseif ebx==IDC_RAE
						; Text Edit
						invoke CreateRAEdit
						invoke TabToolAdd,ha.hREd,offset da.FileName
						invoke LoadEditFile,ha.hREd,offset da.FileName
						invoke SendMessage,ha.hREd,REM_LINENUMBERWIDTH,32,0
						invoke IsFileCodeFile,offset da.FileName
						.if eax
							invoke SendMessage,ha.hREd,REM_SETCOMMENTBLOCKS,addr szCmntStart,addr szCmntEnd
							invoke SendMessage,ha.hREd,REM_SETBLOCKS,0,0
							.if fDebugging
								invoke SendMessage,ha.hREd,REM_READONLY,0,TRUE
							.endif
							invoke LoadBreakpoints,ha.hREd
							invoke LoadBookMarks,ha.hREd
							invoke LoadCollapse,ha.hREd
						.endif
						mov		eax,edopt.hiliteline
						.if eax
							mov		eax,2
						.endif
						invoke SendMessage,ha.hREd,REM_HILITEACTIVELINE,0,eax
						invoke TabToolSetChanged,ha.hREd,FALSE
						invoke AddMRU,offset mrufiles,addr buffer
					.else
						; Hex Edit
						invoke CreateRAHexEd
						invoke TabToolAdd,ha.hREd,offset da.FileName
						invoke LoadHexFile,ha.hREd,offset da.FileName
						invoke TabToolSetChanged,ha.hREd,FALSE
						invoke AddMRU,offset mrufiles,addr buffer
					.endif
					invoke ResetMenu
					invoke LoadCursor,0,IDC_ARROW
					invoke SetCursor,eax
					invoke PostAddinMessage,ha.hWnd,AIM_FILEOPENED,ebx,addr buffer,0,HOOK_FILEOPENED
				.else
					invoke AddMRU,offset mrufiles,addr buffer
					invoke ResetMenu
					invoke PostAddinMessage,ha.hWnd,AIM_FILEOPENED,IDC_USER,addr buffer,0,HOOK_FILEOPENED
				.endif
			.endif
		.else
			invoke strcpy,addr buffer,offset szOpenFileFail
			invoke strcat,addr buffer,lpFileName
			invoke MessageBox,ha.hWnd,addr buffer,offset szAppName,MB_OK or MB_ICONERROR
		.endif
	.endif
	.if ha.hREd
		invoke SetFocus,ha.hREd
	.endif
  Ex:
	ret

OpenEditFile endp

CreateNewProjectFile proc
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE

	;Zero out the ofn struct
    invoke RtlZeroMemory,addr ofn,sizeof ofn
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	push	ha.hWnd
	pop		ofn.hwndOwner
	push	ha.hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,offset ALLFilterString
	invoke strcpy,addr buffer,addr szNULL
	lea		eax,buffer
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,sizeof buffer
	mov		ofn.Flags,OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
    mov		ofn.lpstrDefExt,offset szNULL
    mov		ofn.lpstrTitle,offset szAddNewProjectFile
    ;Show save as dialog
	invoke GetSaveFileName,addr ofn
	.if eax
		invoke CreateFile,addr buffer,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			invoke CloseHandle,eax
			invoke OpenEditFile,addr buffer,0
			.if da.fProject
				invoke SendMessage,ha.hPbr,RPBM_ADDNEWFILE,0,addr buffer
			.endif
			mov		eax,TRUE
		.else
			xor		eax,eax
		.endif
	.endif
	ret

CreateNewProjectFile endp

OpenEdit proc
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE

	;Zero out the ofn struct
	invoke RtlZeroMemory,addr ofn,sizeof ofn
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	push	ha.hWnd
	pop		ofn.hwndOwner
	push	ha.hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,offset ALLFilterString
	mov		buffer[0],0
	lea		eax,buffer
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,sizeof buffer
	mov		ofn.lpstrDefExt,NULL
	invoke GetCurrentDirectory,sizeof buffer1,addr buffer1
	lea		eax,buffer1
	mov		ofn.lpstrInitialDir,eax
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	;Show the Open dialog
	invoke GetOpenFileName,addr ofn
	.if eax
		invoke OpenEditFile,addr buffer,0
	.endif
	ret

OpenEdit endp

OpenHex proc
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE

	;Zero out the ofn struct
	invoke RtlZeroMemory,addr ofn,sizeof ofn
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	push	ha.hWnd
	pop		ofn.hwndOwner
	push	ha.hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,offset ANYFilterString
	mov		buffer[0],0
	lea		eax,buffer
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,sizeof buffer
	mov		ofn.lpstrDefExt,NULL
	invoke GetCurrentDirectory,sizeof buffer1,addr buffer1
	lea		eax,buffer1
	mov		ofn.lpstrInitialDir,eax
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	;Show the Open dialog
	invoke GetOpenFileName,addr ofn
	.if eax
		invoke OpenEditFile,addr buffer,IDC_HEX
	.endif
	ret

OpenHex endp

ProjectAddExistingFiles proc uses esi
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE

	;Zero out the ofn struct
	invoke RtlZeroMemory,addr ofn,sizeof ofn
	invoke RtlZeroMemory,addr tmpbuff,sizeof tmpbuff
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	push	ha.hWnd
	pop		ofn.hwndOwner
	push	ha.hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,offset ALLFilterString
	mov		ofn.lpstrFile,offset tmpbuff
	mov		ofn.nMaxFile,sizeof tmpbuff
	mov		ofn.lpstrDefExt,NULL
	invoke GetCurrentDirectory,sizeof buffer,addr buffer
	lea		eax,buffer
	mov		ofn.lpstrInitialDir,eax
	mov		ofn.lpstrTitle,offset szAddProjectFiles
	mov		ofn.Flags,OFN_ALLOWMULTISELECT or OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_EXPLORER
	;Show the Open dialog
	invoke GetOpenFileName,addr ofn
	.if eax
		invoke lstrlen,addr tmpbuff
		.if tmpbuff[eax+1]
			;Multiple files
			lea		esi,tmpbuff[eax+1]
			.while byte ptr [esi]
				invoke lstrcpy,addr buffer,addr tmpbuff
				invoke lstrcat,addr buffer,addr szBackSlash
				invoke lstrcat,addr buffer,esi
				call	AddFile
				invoke lstrlen,esi
				lea		esi,[esi+eax+1]
			.endw
		.else
			;Single file
			invoke lstrcpy,addr buffer,addr tmpbuff
			call	AddFile
		.endif
	.endif
	ret

AddFile:
	invoke OpenEditFile,addr buffer,0
	invoke SendMessage,ha.hPbr,RPBM_ADDNEWFILE,0,addr buffer
	.if eax
		;The file was added
		mov		edi,eax
		invoke lstrcmpi,addr buffer,addr da.FileName
		.if !eax
			;The file was opened
			invoke GetWindowLong,ha.hREd,GWL_USERDATA
			mov		edx,[edi].PBITEM.id
			mov		[eax].TABMEM.pid,edx
			invoke GetWindowLong,ha.hREd,GWL_ID
			.if eax==IDC_RAE
				invoke ParseEdit,ha.hREd,[edi].PBITEM.id
			.endif
		.endif
	.endif
	retn

ProjectAddExistingFiles endp

OpenSessionFile proc
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE

	;Zero out the ofn struct
	invoke RtlZeroMemory,addr ofn,sizeof ofn
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	push	ha.hWnd
	pop		ofn.hwndOwner
	push	ha.hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,offset MESFilterString
	mov		buffer[0],0
	lea		eax,buffer
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,sizeof buffer
	mov		ofn.lpstrDefExt,NULL
	invoke GetCurrentDirectory,sizeof buffer1,addr buffer1
	lea		eax,buffer1
	mov		ofn.lpstrInitialDir,eax
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	;Show the Open dialog
	invoke GetOpenFileName,addr ofn
	.if eax
		invoke OpenEditFile,addr buffer,IDC_MES
		mov		eax,TRUE
	.endif
	ret

OpenSessionFile endp

MakeSession proc fRegistry:DWORD

	mov		byte ptr tmpbuff,0
	mov		eax,SAVE_SESSIONFILE
	.if fRegistry
		mov		eax,SAVE_SESSIONREGISTRY
	.endif
	invoke UpdateAll,eax,0
	invoke strlen,addr tmpbuff
	.if eax
		mov		byte ptr tmpbuff[eax-1],0
	.endif
	invoke strcpy,addr LineTxt,addr tmpbuff
	invoke SendMessage,ha.hTab,TCM_GETCURSEL,0,0
	mov		edx,eax
	invoke DwToAscii,edx,addr tmpbuff
	invoke strcat,addr tmpbuff,addr szComma
	invoke strcat,addr tmpbuff,addr LineTxt
	ret

MakeSession endp

WriteSessionFile proc lpszFile:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	buffer2[MAX_PATH]:BYTE

	invoke strcpy,addr da.szSessionFile,lpszFile
	invoke SendMessage,ha.hBrowse,FBM_GETPATH,0,addr tmpbuff
	invoke WritePrivateProfileString,addr szSession,addr szFolder,addr tmpbuff,lpszFile
	invoke MakeSession,FALSE
	invoke WritePrivateProfileString,addr szSession,addr szSession,addr tmpbuff,lpszFile
	invoke strcpy,addr buffer1,addr da.szSessionFile
	invoke strlen,addr buffer1
	.while eax && buffer1[eax-1]!='\'
		dec		eax
	.endw
	mov		buffer1[eax],0
	invoke RemovePath,addr da.MainFile,addr buffer1,addr buffer2
	invoke strcpy,addr buffer1,eax
	invoke WritePrivateProfileString,addr szSession,addr szMainFile,addr buffer1,lpszFile
	invoke SendMessage,ha.hCbo,CB_GETCURSEL,0,0
	invoke wsprintf,addr buffer,addr szFmtDec,eax
	invoke WritePrivateProfileString,addr szSession,addr szBuild,addr buffer,lpszFile
	ret

WriteSessionFile endp

SaveSessionFile proc
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE

	;Zero out the ofn struct
    invoke RtlZeroMemory,addr ofn,sizeof ofn
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	push	ha.hWnd
	pop		ofn.hwndOwner
	push	ha.hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,NULL
	mov		ofn.lpstrFilter,offset MESFilterString
	invoke strcpy,addr buffer,addr da.szSessionFile
	lea		eax,buffer
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,sizeof buffer
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
    mov		ofn.lpstrDefExt,offset szFtMes
    ;Show save as dialog
	invoke GetSaveFileName,addr ofn
	.if eax
		invoke WriteSessionFile,addr buffer
	.endif
	ret

SaveSessionFile endp

SetProjectGroups proc uses ebx esi edi,lpBuff:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	pbi:PBITEM

	mov		nInx,0
	invoke SendMessage,ha.hPbr,RPBM_SETGROUPING,FALSE,RPBG_GROUPS
	invoke RtlZeroMemory,addr pbi,sizeof PBITEM
	mov		esi,lpBuff
	.while byte ptr [esi]
		invoke strgetitem,esi,addr buffer
		mov		esi,eax
		.if buffer
			invoke AsciiToDw,addr buffer
			.if sdword ptr eax>0
				invoke SendMessage,ha.hPbr,RPBM_SETGROUPING,FALSE,eax
				invoke strgetitem,esi,addr buffer
				mov		esi,eax
				invoke AsciiToDw,addr buffer
			.endif
			mov		pbi.id,eax
			invoke strgetitem,esi,addr buffer
			mov		esi,eax
			.if buffer
				invoke AsciiToDw,addr buffer
				mov		pbi.idparent,eax
				invoke strgetitem,esi,addr buffer
				mov		esi,eax
				.if buffer
					invoke AsciiToDw,addr buffer
					mov		pbi.expanded,eax
					invoke strgetitem,esi,addr buffer
					mov		esi,eax
					.if buffer
						invoke lstrcpy,addr pbi.szitem,addr buffer
						invoke SendMessage,ha.hPbr,RPBM_ADDITEM,nInx,addr pbi
						inc		nInx
					.endif
				.endif
			.endif
		.endif
	.endw
	mov		eax,nInx
	ret


SetProjectGroups endp

SetProjectFiles proc uses ebx esi edi,nInx:DWORD,lpszFile:DWORD,lpBuff:DWORD,ccBuff:DWORD
	LOCAL	pbi:PBITEM
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke RtlZeroMemory,addr pbi,sizeof PBITEM
	mov		edi,1
	.while edi<1024+1
		invoke wsprintf,addr buffer,addr szFmtDec,edi
		invoke GetPrivateProfileString,addr szProject,addr buffer,addr szNULL,lpBuff,ccBuff,lpszFile
		.if eax
			mov		pbi.id,edi
			mov		esi,lpBuff
			invoke strgetitem,esi,addr buffer
			mov		esi,eax
			.if buffer
				invoke AsciiToDw,addr buffer
				mov		pbi.idparent,eax
				invoke strgetitem,esi,addr buffer
				mov		esi,eax
				.if buffer
					invoke SendMessage,ha.hPbr,RPBM_GETPATH,0,0
					invoke lstrcpy,lpBuff,eax
					invoke lstrcat,lpBuff,addr szBackSlash
					invoke lstrcat,lpBuff,addr buffer
					invoke lstrcpy,addr pbi.szitem,lpBuff
					invoke SendMessage,ha.hPbr,RPBM_ADDITEM,nInx,addr pbi
					invoke ParseFile,addr pbi.szitem,pbi.id
					inc		nInx
				.endif
			.endif
		.endif
		inc		edi
	.endw
	mov		eax,nInx
	ret

SetProjectFiles endp

CreateProject proc uses esi edi,lpszFile:DWORD
	LOCAL	buff[MAX_PATH*3]:BYTE

	mov		esi,lpszFile
	.if !byte ptr [esi]
		.if da.MainFile
			invoke strcpy,addr buff,addr da.MainFile
			invoke strlen,addr buff
			.while eax && buff[eax]!='.'
				dec		eax
			.endw
			.if eax
				mov		dword ptr buff[eax],'sem.'
				invoke strcpy,esi,addr buff
				invoke WriteSessionFile,esi
			.else
				invoke SaveSessionFile
			.endif
		.else
			invoke SaveSessionFile
		.endif
	.endif
	.if byte ptr [esi]
		invoke SendMessage,ha.hPbr,RPBM_ADDITEM,0,0
		lea		esi,buff
		invoke strcpy,esi,lpszFile
		invoke strlen,esi
		.while eax && byte ptr [esi+eax]!='\'
			dec		eax
		.endw
		mov		byte ptr [esi+eax],0
		invoke SendMessage,ha.hPbr,RPBM_SETPATH,0,addr buff
		mov		esi,offset szDefProGroups
		invoke strcpy,addr buff,esi
		mov		edi,lpszFile
		invoke strlen,edi
		.while byte ptr [edi+eax]!='\' && eax
			dec		eax
		.endw
		invoke strcat,addr buff,addr [edi+eax+1]
		invoke strlen,esi
		invoke strcat,addr buff,addr [esi+eax+1]
		invoke SetProjectGroups,addr buff
		.if eax
			mov		da.fProject,TRUE
			invoke SendMessage,ha.hProperty,PRM_DELPROPERTY,0,0
			invoke SendMessage,ha.hProperty,PRM_REFRESHLIST,0,0
			invoke UpdateAll,ADDTOPROJECT,TRUE
			invoke SendMessage,ha.hTabPbr,TCM_SETCURSEL,1,0
			invoke ShowWindow,ha.hPbr,SW_SHOWNA
			invoke ShowWindow,ha.hBrowse,SW_HIDE
		.endif
	.endif
	ret

CreateProject endp

OpenProject proc uses esi edi,lpszFile:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buff[MAX_PATH*3]:BYTE

	mov		da.fProject,FALSE
	invoke SendMessage,ha.hPbr,RPBM_ADDITEM,0,0
	;Get path
	lea		esi,buff
	invoke strcpy,esi,addr da.szSessionFile
	invoke strlen,esi
	.while eax && byte ptr [esi+eax]!='\'
		dec		eax
	.endw
	mov		byte ptr [esi+eax],0
	invoke SendMessage,ha.hPbr,RPBM_SETPATH,0,addr buff
	;Get groups
	invoke GetPrivateProfileString,addr szProject,addr szProGroup,addr szNULL,addr buff,sizeof buff,lpszFile
	.if eax
		invoke SetProjectGroups,addr buff
		.if eax
			;Get files
			mov		da.fProject,TRUE
			mov		edx,eax
			invoke SetProjectFiles,edx,lpszFile,addr buff,sizeof buff
			invoke SendMessage,ha.hPbr,RPBM_SETGROUPING,TRUE,RPBG_NOCHANGE
			invoke SendMessage,ha.hTabPbr,TCM_SETCURSEL,1,0
			invoke ShowWindow,ha.hPbr,SW_SHOWNA
			invoke ShowWindow,ha.hBrowse,SW_HIDE
		.endif
	.endif
	ret

OpenProject endp

SaveProject proc uses ebx esi edi,lpszFile:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	path[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	buff[MAX_PATH*3]:BYTE

	mov		eax,lpszFile
	.if byte ptr [eax]
		mov		word ptr buff,0
		invoke WritePrivateProfileSection,addr szProject,addr buff,lpszFile
		invoke SendMessage,ha.hPbr,RPBM_GETEXPAND,0,0
		invoke SendMessage,ha.hPbr,RPBM_GETGROUPING,0,0
		invoke wsprintf,addr buff,addr szFmtDec,eax
		xor		ebx,ebx
		.while TRUE
			invoke SendMessage,ha.hPbr,RPBM_GETITEM,ebx,0
			.if eax
				mov		esi,eax
				.break .if ![esi].PBITEM.id
				.if sdword ptr [esi].PBITEM.id<0
					lea		edi,buffer
					invoke wsprintf,edi,addr szFmtDec,[esi].PBITEM.id
					invoke lstrlen,edi
					lea		edi,[edi+eax]
					mov		word ptr [edi],','
					inc		edi
					invoke wsprintf,edi,addr szFmtDec,[esi].PBITEM.idparent
					invoke lstrlen,edi
					lea		edi,[edi+eax]
					mov		word ptr [edi],','
					inc		edi
					invoke wsprintf,edi,addr szFmtDec,[esi].PBITEM.expanded
					invoke lstrlen,edi
					lea		edi,[edi+eax]
					mov		word ptr [edi],','
					inc		edi
					invoke lstrcpy,edi,addr [esi].PBITEM.szitem
					.if buff
						invoke lstrcat,addr buff,addr szComma
					.endif
					invoke lstrcat,addr buff,addr buffer
				.endif
			.else
				.break
			.endif
			inc		ebx
		.endw
		.if ebx
			invoke WritePrivateProfileString,addr szProject,addr szProGroup,addr buff,lpszFile
			invoke SendMessage,ha.hPbr,RPBM_GETPATH,0,0
			invoke lstrcpy,addr path,eax
			xor		ebx,ebx
			.while TRUE
				invoke SendMessage,ha.hPbr,RPBM_GETITEM,ebx,0
				.if eax
					mov		esi,eax
					.break .if ![esi].PBITEM.id
					.if sdword ptr [esi].PBITEM.id>0
						lea		edi,buff
						invoke wsprintf,edi,addr szFmtDec,[esi].PBITEM.idparent
						invoke lstrlen,edi
						lea		edi,[edi+eax]
						mov		word ptr [edi],','
						inc		edi
						invoke lstrcpy,addr buffer1,addr [esi].PBITEM.szitem
						invoke RemovePath,addr [esi].PBITEM.szitem,addr path,addr buffer1
						invoke lstrcpy,edi,addr [eax+1]
						invoke wsprintf,addr buffer,addr szFmtDec,[esi].PBITEM.id
						invoke WritePrivateProfileString,addr szProject,addr buffer,addr buff,lpszFile
					.endif
				.else
					.break
				.endif
				inc		ebx
			.endw
		.endif
	.endif
	ret

SaveProject endp

AskSaveSessionFile proc

	.if byte ptr da.szSessionFile
		.if da.fProject
			invoke WriteSessionFile,addr da.szSessionFile
			invoke SaveProject,addr da.szSessionFile
		.else
			invoke strcpy,addr tmpbuff,addr szSaveSession
			invoke strcat,addr tmpbuff,addr da.szSessionFile
			invoke MessageBox,ha.hWnd,addr tmpbuff,addr szSession,MB_YESNOCANCEL or MB_ICONEXCLAMATION
			.if eax==IDYES
				invoke WriteSessionFile,addr da.szSessionFile
			.elseif eax==IDCANCEL
				mov		eax,TRUE
				ret
			.endif
		.endif
	.endif
	xor		eax,eax
	ret

AskSaveSessionFile endp

RestoreSession proc uses esi edi,fReg:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	buffer2[MAX_PATH]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	nLn:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	fHex:DWORD

	mov		esi,offset tmpbuff
	.if fReg && byte ptr [esi]
		invoke strgetitem,esi,addr buffer
		mov		esi,eax
		.if buffer
			invoke GetFileAttributes,addr buffer
			.if eax==INVALID_HANDLE_VALUE
				jmp		Ex
			.endif
		.endif
		invoke strcpy,addr da.szSessionFile,addr buffer
	.endif
	.if da.szSessionFile
		invoke OpenProject,addr da.szSessionFile
	.endif
	invoke strcpy,addr buffer1,addr da.szSessionFile
	invoke strlen,addr buffer1
	.while eax && buffer1[eax-1]!='\'
		dec		eax
	.endw
	mov		buffer1[eax],0
	mov		nInx,-2
	.while byte ptr [esi]
		invoke strgetitem,esi,addr buffer
		mov		esi,eax
		.if nInx==-2
			.if buffer
				invoke AsciiToDw,addr buffer
				mov		nInx,eax
			.endif
		.else
			invoke AsciiToDw,addr buffer
			mov		nLn,eax
			invoke strgetitem,esi,addr buffer
			mov		esi,eax
			.if buffer
				.if buffer[1]!=':'
					; Relative path
					invoke strcpy,addr buffer2,addr buffer1
					invoke strcat,addr buffer2,addr buffer
					invoke strcpy,addr buffer,addr buffer2
				.endif
				push	ha.hREd
				mov		fHex,FALSE
				.if sdword ptr nLn<=-2
					mov		eax,nLn
					neg		eax
					sub		eax,2
					mov		nLn,eax
					invoke OpenEditFile,addr buffer,IDC_HEX
					mov		fHex,TRUE
				.elseif sdword ptr nLn==-1
					invoke OpenEditFile,addr buffer,IDC_RES
				.else
					invoke OpenEditFile,addr buffer,IDC_RAE
				.endif
				pop		eax
				.if eax!=ha.hREd
					mov		eax,ha.hREd
					.if nLn!=-1 && eax!=ha.hRes
						invoke SendMessage,ha.hREd,EM_LINEINDEX,nLn,0
						mov		chrg.cpMin,eax
						mov		chrg.cpMax,eax
						invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chrg
						invoke SendMessage,ha.hREd,EM_SCROLLCARET,0,0
						.if !fHex
							invoke SendMessage,ha.hREd,REM_VCENTER,0,0
							invoke SendMessage,ha.hREd,EM_SCROLLCARET,0,0
						.endif
					.endif
				.endif
			.endif
		.endif
	.endw
	.if sdword ptr nInx>=0
		invoke SendMessage,ha.hTab,TCM_SETCURSEL,nInx,0
		.if eax!=-1
			invoke TabToolActivate
			invoke SetFocus,ha.hREd
		.endif
	.endif
  Ex:
	ret

RestoreSession endp

ReadSessionFile proc lpszFile:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke strcpy,addr da.szSessionFile,lpszFile
	invoke GetPrivateProfileString,addr szSession,addr szFolder,addr szNULL,addr tmpbuff,sizeof tmpbuff,lpszFile
	invoke SendMessage,ha.hBrowse,FBM_SETPATH,TRUE,addr tmpbuff
	invoke GetPrivateProfileString,addr szSession,addr szSession,addr szNULL,addr tmpbuff,sizeof tmpbuff,lpszFile
	invoke GetPrivateProfileString,addr szSession,addr szMainFile,addr szNULL,addr da.MainFile,sizeof da.MainFile,lpszFile
	.if da.MainFile[1]!=':'
		; Relative path
		invoke strcpy,addr buffer,addr da.szSessionFile
		invoke strlen,addr buffer
		.while eax && buffer[eax-1]!='\'
			dec		eax
		.endw
		mov		buffer[eax],0
		invoke strcat,addr buffer,addr da.MainFile
		invoke strcpy,addr da.MainFile,addr buffer
	.endif
	invoke GetPrivateProfileInt,addr szSession,addr szBuild,0,lpszFile
	invoke SendMessage,ha.hCbo,CB_SETCURSEL,eax,0
	invoke RestoreSession,FALSE
	.if da.FileName && da.fProject
		invoke SendMessage,ha.hPbr,RPBM_SETSELECTED,0,addr da.FileName
	.endif
	ret

ReadSessionFile endp

SetCurDir proc lpFileName:DWORD,fFileBrowse:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke strcpy,addr buffer,lpFileName
	invoke strlen,addr buffer
	.while byte ptr buffer[eax]!='\' && eax
		dec		eax
	.endw
	mov		buffer[eax],0
	.if fFileBrowse
		invoke SendMessage,ha.hBrowse,FBM_SETPATH,TRUE,addr buffer
	.endif
	invoke SetCurrentDirectory,addr buffer
	ret

SetCurDir endp

OpenCommandLine proc uses ebx,lpCmnd:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		ebx,lpCmnd
	.while byte ptr [ebx]
		.while byte ptr [ebx]==' '
			inc		ebx
		.endw
		lea		edx,buffer
		.if byte ptr [ebx]=='"'
			inc		ebx
			.while byte ptr [ebx]!='"' && byte ptr [ebx]
				mov		al,[ebx]
				mov		[edx],al
				inc		ebx
				inc		edx
			.endw
			inc		ebx
		.else
			.while byte ptr [ebx]!=' ' && byte ptr [ebx]
				mov		al,[ebx]
				mov		[edx],al
				inc		ebx
				inc		edx
			.endw
		.endif
		mov		byte ptr [edx],0
		.if buffer
			invoke OpenEditFile,addr buffer,0
		.endif
	.endw
	ret

OpenCommandLine endp
