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

GetTheFileType proc uses ebx esi edi,lpFileName:DWORD
	LOCAL	ftpe[256]:BYTE

	mov		esi,lpFileName
	invoke PostAddinMessage,ha.hWnd,AIM_GETFILETYPE,0,esi,0,HOOK_GETFILETYPE
	.if eax
		jmp		Ex
	.endif
	invoke strlen,esi
	.while byte ptr [esi+eax]!='.' && eax
		dec		eax
	.endw
	.if byte ptr [esi+eax]=='.'
		invoke strcpy,addr ftpe,addr [esi+eax]
		invoke strcat,addr ftpe,addr szDot
		mov		edi,offset da.external
		xor		ebx,ebx
		.while ebx<20
			.break .if ![edi].EXTERNAL.szfiles
			invoke IsFileType,addr ftpe,addr [edi].EXTERNAL.szfiles
			.if eax
				mov		eax,edi
				jmp		Ex
			.endif
			lea		edi,[edi+sizeof EXTERNAL]
			inc		ebx
		.endw
		invoke IsFileType,addr ftpe,addr da.szCodeFiles
		.if eax
			mov		eax,ID_EDITCODE
			jmp		Ex
		.endif
		invoke IsFileType,addr ftpe,addr da.szTextFiles
		.if eax
			mov		eax,ID_EDITTEXT
			jmp		Ex
		.endif
		invoke IsFileType,addr ftpe,addr da.szHexFiles
		.if eax
			mov		eax,ID_EDITHEX
			jmp		Ex
		.endif
		invoke IsFileType,addr ftpe,addr da.szResourceFiles
		.if eax
			mov		eax,ID_EDITRES
			jmp		Ex
		.endif
		invoke IsFileType,addr ftpe,addr da.szProjectFiles
		.if eax
			mov		eax,ID_PROJECT
			jmp		Ex
		.endif
		mov		eax,ID_EDITTEXT
	.else
		mov		eax,ID_EDITTEXT
	.endif
  Ex:
	ret

GetTheFileType endp

GetModify proc uses ebx,hWin:HWND
	LOCAL	hEdt:HWND
	LOCAL	ID:DWORD

	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		hEdt,eax
	invoke GetWindowLong,hEdt,GWL_USERDATA
	mov		ebx,eax
	invoke GetWindowLong,hEdt,GWL_ID
	mov		ID,eax
	invoke PostAddinMessage,hWin,AIM_GETMODIFY,ID,addr [ebx].TABMEM.filename,0,HOOK_GETMODIFY
	.if !eax
		mov		edx,ID
		.if edx==ID_EDITCODE || edx==ID_EDITTEXT || edx==ID_EDITHEX
			invoke SendMessage,hEdt,EM_GETMODIFY,0,0
		.elseif edx==ID_EDITRES
			invoke SendMessage,hEdt,PRO_GETMODIFY,0,0
		.endif
	.endif
	ret

GetModify endp

LoadTextFile proc uses ebx esi,hWin:DWORD,lpFileName:DWORD
    LOCAL   hFile:HANDLE
	LOCAL	editstream:EDITSTREAM

	;Open the file
	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke SendMessage,hWin,WM_SETTEXT,0,addr szNULL
		;stream the text into the RAEdit control
		mov		eax,hFile
		mov		editstream.dwCookie,eax
		mov		editstream.pfnCallback,offset StreamInProc
		invoke SendMessage,hWin,EM_STREAMIN,SF_TEXT,addr editstream
		invoke CloseHandle,hFile
		invoke SendMessage,hWin,EM_SETMODIFY,FALSE,0
		invoke SendMessage,hWin,REM_SETCHANGEDSTATE,FALSE,0
		mov		eax,FALSE
	.else
		invoke strcpy,offset tmpbuff,offset szOpenFileFail
		invoke strcat,offset tmpbuff,lpFileName
		invoke MessageBox,ha.hWnd,offset tmpbuff,offset DisplayName,MB_OK or MB_ICONERROR
		mov		eax,TRUE
	.endif
	ret

LoadTextFile endp

LoadHexFile proc uses ebx esi,hWin:DWORD,lpFileName:DWORD
    LOCAL   hFile:HANDLE
	LOCAL	editstream:EDITSTREAM

	;Open the file
	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		;stream the text into the RAHexEd control
		mov		eax,hFile
		mov		editstream.dwCookie,eax
		mov		editstream.pfnCallback,offset StreamInProc
		invoke SendMessage,hWin,EM_STREAMIN,SF_TEXT,addr editstream
		invoke CloseHandle,hFile
		invoke SendMessage,hWin,EM_SETMODIFY,FALSE,0
		mov		eax,FALSE
	.else
		invoke strcpy,offset tmpbuff,offset szOpenFileFail
		invoke strcat,offset tmpbuff,lpFileName
		invoke MessageBox,ha.hWnd,offset tmpbuff,offset DisplayName,MB_OK or MB_ICONERROR
		mov		eax,TRUE
	.endif
	ret

LoadHexFile endp

LoadResFile proc uses ebx esi,hWin:DWORD,lpFileName:DWORD
    LOCAL   hFile:HANDLE
	LOCAL	hMem:HGLOBAL
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
		invoke SendMessage,hWin,PRO_OPEN,lpFileName,hMem
		mov		eax,FALSE
	.else
		invoke strcpy,offset tmpbuff,offset szOpenFileFail
		invoke strcat,offset tmpbuff,lpFileName
		invoke MessageBox,ha.hWnd,offset tmpbuff,offset DisplayName,MB_OK or MB_ICONERROR
		mov		eax,TRUE
	.endif
	ret

LoadResFile endp

OpenTheFile proc uses ebx esi edi,lpFileName:DWORD,ID:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	hEdt:HWND
	LOCAL	fi:FILEINFO
	LOCAL	pid:DWORD
	LOCAL	buffer[32]:BYTE

	xor		edi,edi
	mov		da.fExternal,edi
	mov		pid,edi
	invoke GetFileAttributes,lpFileName
	.if eax!=INVALID_HANDLE_VALUE
		.if da.fProject
			invoke SendMessage,ha.hProjectBrowser,RPBM_FINDITEM,0,lpFileName
			.if eax
				mov		eax,[eax].PBITEM.id
				mov		pid,eax
			.endif
		.endif
		.if ID
			mov		eax,ID
		.else
			invoke GetTheFileType,lpFileName
			.if eax==ID_EDITRES
				invoke GetKeyState,VK_CONTROL
				test	eax,80h
				.if !ZERO?
					;Open resource file as code file
					mov		eax,ID_EDITCODE
				.else
					mov		eax,ID_EDITRES
				.endif
			.endif
		.endif
		.if eax==ID_EDITCODE
			invoke strcpy,addr da.szFileName,lpFileName
			invoke MakeMdiCldWin,ID_EDITCODE,pid
			mov		edi,eax
			invoke GetWindowLong,edi,GWL_USERDATA
			mov		hEdt,eax
			invoke GetTheFileType,lpFileName
			.if eax==ID_EDITRES
				;Resource file as code file
				invoke SendMessage,hEdt,REM_SETWORDGROUP,0,1
			.endif
			invoke LoadTextFile,hEdt,lpFileName
			invoke SendMessage,hEdt,REM_SETBLOCKS,0,0
			invoke SendMessage,hEdt,REM_SETCOMMENTBLOCKS,addr da.szCmntStart,addr da.szCmntEnd
			.if da.fDebugging
				invoke SendMessage,hEdt,REM_READONLY,0,TRUE
			.endif
		.elseif eax==ID_EDITTEXT
			invoke strcpy,addr da.szFileName,lpFileName
			invoke MakeMdiCldWin,ID_EDITTEXT,pid
			mov		edi,eax
			invoke GetWindowLong,edi,GWL_USERDATA
			mov		hEdt,eax
			invoke LoadTextFile,hEdt,lpFileName
		.elseif eax==ID_EDITHEX
			invoke strcpy,addr da.szFileName,lpFileName
			invoke MakeMdiCldWin,ID_EDITHEX,pid
			mov		edi,eax
			invoke GetWindowLong,edi,GWL_USERDATA
			mov		hEdt,eax
			invoke LoadHexFile,hEdt,lpFileName
		.elseif eax==ID_EDITRES
			invoke UpdateAll,UAM_ISRESOPEN,0
			.if eax==-1
				invoke strcpy,addr da.szFileName,lpFileName
				invoke MakeMdiCldWin,ID_EDITRES,pid
				mov		edi,eax
				invoke GetWindowLong,edi,GWL_USERDATA
				mov		hEdt,eax
				invoke LoadResFile,hEdt,lpFileName
			.else
				invoke TabToolGetInx,eax
				push	eax
				invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
				invoke TabToolActivate
				mov		edi,ha.hMdi
				mov		eax,ha.hEdt
				mov		hEdt,eax
				invoke SendMessage,hEdt,PRO_CLOSE,0,0
				invoke LoadResFile,hEdt,lpFileName
				pop		eax
				invoke TabToolSetText,eax,lpFileName
				invoke SetWinCaption,edi,lpFileName
				invoke TabToolActivate
			.endif
		.elseif eax==ID_EDITUSER
			invoke strcpy,addr da.szFileName,lpFileName
			invoke MakeMdiCldWin,ID_EDITUSER,pid
			mov		edi,eax
			invoke GetWindowLong,edi,GWL_USERDATA
			mov		hEdt,eax
		.elseif eax==ID_PROJECT
			;Check version
			invoke GetPrivateProfileInt,addr szIniVersion,addr szIniVersion,0,lpFileName
			.if eax<3000
				invoke MessageBox,ha.hWnd,addr szProjectVersion,addr DisplayName,MB_OK or MB_ICONERROR
			.else
				invoke CloseProject
				.if eax
					invoke PostAddinMessage,ha.hWnd,AIM_PROJECTOPEN,0,lpFileName,0,HOOK_PROJECTOPEN
					.if !eax
						invoke LoadCursor,0,IDC_WAIT
						invoke SetCursor,eax
						invoke strcpy,addr da.szProjectFile,lpFileName
						invoke strcpy,addr da.szProjectPath,addr da.szProjectFile
						invoke RemoveFileName,addr da.szProjectPath
						mov		da.fProject,TRUE
						;Assembler
						invoke GetPrivateProfileString,addr szIniProject,addr szIniAssembler,NULL,addr da.szAssembler,sizeof da.szAssembler,addr da.szProjectFile
						.if !eax
							mov		dword ptr da.szAssembler,'msam'
							mov		dword ptr da.szAssembler[4],0
						.endif
						invoke GetPrivateProfileString,addr szIniProject,addr szIniApi,NULL,addr da.szPOApiFiles,sizeof da.szPOApiFiles,addr da.szProjectFile
						invoke OpenAssembler
						invoke GetProjectFiles
						invoke AddMRU,addr da.szMruProjects,addr da.szProjectFile
						invoke UpdateMRUMenu,addr da.szMruProjects
						invoke SetMainWinCaption
						invoke LoadCursor,0,IDC_ARROW
						invoke SetCursor,eax
						invoke PostAddinMessage,ha.hWnd,AIM_PROJECTOPENED,0,addr da.szProjectFile,0,HOOK_PROJECTOPENED
					.endif
				.endif
			.endif
		.elseif eax==ID_EXTERNAL
		.else
			;External
			invoke ShellExecute,ha.hWnd,NULL,addr [eax].EXTERNAL.szprog,lpFileName,NULL,SW_SHOWNORMAL
			mov		da.fExternal,TRUE
			xor		eax,eax
			jmp		Ex
		.endif
		.if edi
			invoke SetFocus,hEdt
			invoke TabToolSetChanged,edi,FALSE
			.if da.fProject
				invoke SendMessage,ha.hProjectBrowser,RPBM_FINDITEM,0,lpFileName
				.if eax
					mov		esi,eax
					invoke GetFileInfo,[esi].PBITEM.id,addr szIniProject,addr da.szProjectFile,addr fi
					.if eax
						mov		eax,ID
						.if ID!=3 || eax==fi.ID
							invoke GetWindowLong,hEdt,GWL_USERDATA
							mov		ebx,eax
							mov		eax,[esi].PBITEM.id
							mov		[ebx].TABMEM.pid,eax
							.if fi.ID==ID_EDITCODE || fi.ID==ID_EDITTEXT
								mov		eax,fi.nline
								mov		[ebx].TABMEM.nlastpropline,eax
								invoke SendMessage,hEdt,WM_GETTEXTLENGTH,0,0
								mov		[ebx].TABMEM.nlastsize,eax
								mov		[ebx].TABMEM.fupdate,0
								invoke SendMessage,hEdt,EM_LINEINDEX,fi.nline,0
								mov		chrg.cpMin,eax
								mov		chrg.cpMax,eax
								invoke SendMessage,hEdt,EM_EXSETSEL,0,addr chrg
								invoke SendMessage,hEdt,REM_VCENTER,0,0
								invoke SendMessage,hEdt,EM_SCROLLCARET,0,0
							.endif
							;Restore collapse
							.if fi.ID==ID_EDITCODE
								mov		buffer,'C'
								invoke BinToDec,fi.pid,addr buffer[1]
								invoke GetPrivateProfileString,addr szIniProject,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szProjectFile
								.if eax
									invoke SendMessage,hEdt,EM_GETLINECOUNT,0,0
									invoke SendMessage,hEdt,REM_PRVBOOKMARK,eax,1
									mov		ebx,eax
									.while TRUE
										invoke GetItemInt,addr tmpbuff,-1
										.break .if eax==-1
										xor		esi,esi
										.while esi<31
											shr		eax,1
											push	eax
											.if CARRY?
												invoke SendMessage,hEdt,REM_COLLAPSE,ebx,0
											.endif
											invoke SendMessage,hEdt,REM_PRVBOOKMARK,ebx,1
											mov		ebx,eax
											pop		eax
											inc		esi
											cmp		ebx,-1
											je		@f
										.endw
									.endw
								  @@:
								.endif
							.endif
							;Restore breakpoints
							.if fi.ID==ID_EDITCODE
								mov		buffer,'B'
								invoke BinToDec,fi.pid,addr buffer[1]
								invoke GetPrivateProfileString,addr szIniProject,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szProjectFile
								.if eax
									.while TRUE
										invoke GetItemInt,addr tmpbuff,-1
										.break .if eax==-1
										invoke SendMessage,hEdt,REM_SETBREAKPOINT,eax,TRUE
									.endw
								.endif
							.endif
							;Restore bookmarks
							.if fi.ID==ID_EDITCODE || fi.ID==ID_EDITTEXT
								mov		buffer,'M'
								invoke BinToDec,fi.pid,addr buffer[1]
								invoke GetPrivateProfileString,addr szIniProject,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szProjectFile
								.if eax
									.while TRUE
										invoke GetItemInt,addr tmpbuff,-1
										.break .if eax==-1
										invoke SendMessage,hEdt,REM_SETBOOKMARK,eax,3
									.endw
								.endif
							.endif
						.endif
					.endif
				.endif
			.else
				invoke GetWindowLong,hEdt,GWL_ID
				.if eax==ID_EDITCODE
					invoke ParseEdit,edi,0
				.endif
			.endif
		.endif
		invoke PostAddinMessage,ha.hWnd,AIM_FILEOPENED,ID,lpFileName,0,HOOK_FILEOPENED
	.endif
	mov		eax,edi
  Ex:
	ret

OpenTheFile endp

OpenEditFile proc ID:DWORD
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
	.if ID==ID_EDITHEX
		mov		ofn.lpstrFilter,offset da.szANYString
	.elseif ID==ID_PROJECT
		mov		ofn.lpstrFilter,offset da.szPROString
	.else
		mov		ofn.lpstrFilter,offset da.szALLString
	.endif
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
		invoke UpdateAll,UAM_ISOPENACTIVATE,addr buffer
		.if eax==-1
			invoke OpenTheFile,addr buffer,ID
		.endif
	.endif
	ret

OpenEditFile endp

BackupFile proc uses esi edi,lpFileName:DWORD,Backup:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer2[MAX_PATH]:BYTE
	LOCAL	BackupPath[MAX_PATH]:BYTE
	LOCAL	dotpos:DWORD

	.if da.fProject
		invoke strcpy,addr BackupPath,addr da.szProjectPath
		lea		esi,BackupPath
;		invoke strlen,esi
;		.while eax
;			.if byte ptr [esi+eax]=='\'
;				mov		byte ptr [esi+eax],0
;				.break
;			.endif
;			dec		eax
;		.endw
		invoke strcat,addr BackupPath,addr szBSBakBS
		mov		esi,lpFileName
		invoke strlen,esi
		.while eax && byte ptr [esi+eax]!='\'
			.if byte ptr [esi+eax]=='.'
				lea		edx,[esi+eax]
				mov		dotpos,edx
			.endif
			dec		eax
		.endw
		lea		esi,[esi+eax]
		lea		edi,buffer2
	  @@:
		cmp		esi,dotpos
		je		@f
		mov		al,[esi]
		or		al,al
		je		@f
		mov		[edi],al
		inc		esi
		inc		edi
		cmp		al,'\'
		jne		@b
		lea		edi,buffer2
		jmp		@b
	  @@:
		mov		byte ptr [edi],0
		invoke strcpy,addr buffer,addr BackupPath
		invoke strcat,addr buffer,addr buffer2
		invoke strlen,addr buffer
		lea		edi,buffer
		add		edi,eax
		.if Backup==1
			mov		al,'('
			mov		[edi],al
			inc		edi
			mov		al,'1'
			mov		[edi],al
			inc		edi
			mov		al,')'
			mov		[edi],al
			inc		edi
		.else
			mov		al,[edi-2]
			inc		al
			mov		[edi-2],al
		.endif
	  @@:
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
		or		al,al
		jne		@b
		mov		eax,Backup
		.if eax<da.nBackup
			invoke GetFileAttributes,addr buffer
			.if eax!=INVALID_HANDLE_VALUE
				;File exist
				mov		eax,Backup
				inc		eax
				invoke BackupFile,addr buffer,eax
			.endif
		.endif
		;Rename file
		invoke CopyFile,lpFileName,addr buffer,FALSE
	.endif
	ret

BackupFile endp

SaveTextFile proc hWin:DWORD,lpFileName:DWORD
	LOCAL	hFile:HANDLE
	LOCAL	editstream:EDITSTREAM

	invoke CreateFile,lpFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		;stream the text to the file
		mov		eax,hFile
		mov		editstream.dwCookie,eax
		mov		editstream.pfnCallback,offset StreamOutProc
		invoke SendMessage,hWin,EM_STREAMOUT,SF_TEXT,addr editstream
		invoke CloseHandle,hFile
		;Set the modified state to false
		invoke SendMessage,hWin,EM_SETMODIFY,FALSE,0
		;Update the line changed state
		invoke SendMessage,hWin,REM_SETCHANGEDSTATE,TRUE,0
		;Update the tabs changed state
		invoke GetParent,hWin
		invoke TabToolSetChanged,eax,FALSE
   		mov		eax,FALSE
	.endif
	ret

SaveTextFile endp

SaveHexFile proc hWin:DWORD,lpFileName:DWORD
	LOCAL	hFile:HANDLE
	LOCAL	editstream:EDITSTREAM

	invoke CreateFile,lpFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		;stream the text to the file
		mov		eax,hFile
		mov		editstream.dwCookie,eax
		mov		editstream.pfnCallback,offset StreamOutProc
		invoke SendMessage,hWin,EM_STREAMOUT,SF_TEXT,addr editstream
		invoke CloseHandle,hFile
		;Set the modified state to false
		invoke SendMessage,hWin,EM_SETMODIFY,FALSE,0
		;Update the tabs changed state
		invoke GetParent,hWin
		invoke TabToolSetChanged,eax,FALSE
   		mov		eax,FALSE
	.endif
	ret

SaveHexFile endp

SaveResFile proc hWin:DWORD,lpFileName:DWORD
	LOCAL	hFile:HANDLE
	LOCAL	hMem:HGLOBAL
	LOCAL	nSize:DWORD

	invoke CreateFile,lpFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
		mov		hMem,eax
		invoke SendMessage,hWin,PRO_EXPORT,0,hMem
		invoke strlen,hMem
		mov		nSize,eax
		invoke WriteFile,hFile,hMem,nSize,addr nSize,NULL
		invoke CloseHandle,hFile
		;Set the modified state to false
		invoke SendMessage,hWin,PRO_SETMODIFY,FALSE,0
		invoke GlobalFree,hMem
		;Update the tabs changed state
		invoke GetParent,hWin
		invoke TabToolSetChanged,eax,FALSE
   		mov		eax,FALSE
	.endif
	ret

SaveResFile endp

SaveTheFile proc uses ebx,hWin:HWND
	LOCAL	hEdt:HWND
	LOCAL	ID:DWORD

	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		hEdt,eax
	invoke GetWindowLong,hEdt,GWL_USERDATA
	mov		ebx,eax
	invoke GetWindowLong,hEdt,GWL_ID
	mov		ID,eax
	invoke PostAddinMessage,hWin,AIM_FILESAVE,ID,addr [ebx].TABMEM.filename,0,HOOK_FILESAVE
	.if eax
		;Update the tabs changed state
		invoke TabToolSetChanged,hWin,FALSE
		xor		eax,eax
	.else
		invoke BackupFile,addr [ebx].TABMEM.filename,1
		invoke GetWindowLong,hEdt,GWL_ID
		.if eax==ID_EDITCODE
			invoke SaveTextFile,hEdt,addr [ebx].TABMEM.filename
		.elseif eax==ID_EDITTEXT
			invoke SaveTextFile,hEdt,addr [ebx].TABMEM.filename
		.elseif eax==ID_EDITHEX
			invoke SaveHexFile,hEdt,addr [ebx].TABMEM.filename
		.elseif eax==ID_EDITRES
			invoke SaveResFile,hEdt,addr [ebx].TABMEM.filename
		.elseif eax==ID_EDITUSER
			xor		eax,eax
		.endif
		push	eax
		invoke UpdateFileTime,ebx
		invoke PostAddinMessage,hWin,AIM_FILESAVED,ID,addr [ebx].TABMEM.filename,0,HOOK_FILESAVED
		pop		eax
	.endif
	ret

SaveTheFile endp

WantToSave proc uses ebx,hWin:HWND

	invoke GetModify,hWin
	.if eax
		invoke TabToolGetInx,[ebx].TABMEM.hwnd
		invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
		invoke TabToolActivate
		invoke strcpy,addr tmpbuff,offset szWannaSave
		invoke strcat,addr tmpbuff,addr [ebx].TABMEM.filename
		invoke strlen,addr tmpbuff
		mov		word ptr tmpbuff[eax],'?'
		invoke MessageBox,ha.hWnd,addr tmpbuff,offset DisplayName,MB_YESNOCANCEL or MB_ICONQUESTION
		.if eax==IDYES
			invoke SaveTheFile,hWin
		.elseif eax==IDNO
		    mov		eax,FALSE
		.else
		    mov		eax,TRUE
		.endif
	.endif
	ret

WantToSave endp

UpdateFileName proc uses ebx,hWin:DWORD,lpFileName:DWORD
	LOCAL	hEdt:HWND

	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		hEdt,eax
	invoke GetWindowLong,hEdt,GWL_USERDATA
	mov		ebx,eax
	invoke GetWindowLong,hEdt,GWL_ID
	.if eax==ID_EDITCODE
		invoke SaveTextFile,hEdt,lpFileName
	.elseif eax==ID_EDITTEXT
		invoke SaveTextFile,hEdt,lpFileName
	.elseif eax==ID_EDITHEX
		invoke SaveHexFile,hEdt,lpFileName
	.elseif eax==ID_EDITRES
		invoke SaveResFile,hEdt,lpFileName
	.elseif eax==ID_EDITUSER
		invoke PostAddinMessage,hWin,AIM_FILENAMECHANGED,addr [ebx].TABMEM.filename,lpFileName,0,HOOK_FILENAMECHANGED
		xor		eax,TRUE
	.endif
	.if !eax
		;The file was saved
		.if da.fProject
			;Update project browser
			invoke SendMessage,ha.hProjectBrowser,RPBM_FINDITEM,0,addr [ebx].TABMEM.filename
			.if eax
				invoke strcpy,addr [eax].PBITEM.szitem,lpFileName
				invoke SendMessage,ha.hProjectBrowser,RPBM_SETGROUPING,TRUE,RPBG_NOCHANGE
			.endif
		.endif
		;Update tab
		invoke TabToolGetInx,hWin
		invoke TabToolSetText,eax,lpFileName
		;Update mdi child caption
		invoke SetWindowText,hWin,lpFileName
		mov		eax,FALSE
	.endif
	ret

UpdateFileName endp

SaveFileAs proc hWin:DWORD,lpFileName:DWORD
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke GetWindowLong,ha.hEdt,GWL_ID
	invoke PostAddinMessage,ha.hMdi,AIM_FILESAVEAS,eax,addr da.szFileName,0,HOOK_FILESAVEAS
	.if eax
		jmp		Ex
	.endif
	;Zero out the ofn struct
    invoke RtlZeroMemory,addr ofn,sizeof ofn
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	push	hWin
	pop		ofn.hwndOwner
	push	ha.hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,NULL
	invoke strcpy,addr buffer,lpFileName
	lea		eax,buffer
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,sizeof buffer
	invoke GetWindowLong,hWin,GWL_USERDATA
	invoke GetWindowLong,eax,GWL_ID
	.if eax==ID_EDITCODE || eax==ID_EDITTEXT
		mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT or OFN_EXPLORER
	.else
		mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT or OFN_EXPLORER
	.endif
    mov		ofn.lpstrDefExt,NULL
    ;Show save as dialog
	invoke GetSaveFileName,addr ofn
	.if eax
		invoke UpdateFileName,hWin,addr buffer
	.else
		mov		eax,TRUE
	.endif
  Ex:
	ret

SaveFileAs endp

OpenCommandLine proc uses esi edi,lpCmdLine:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		esi,lpCmdLine
	.while byte ptr [esi]
		.if byte ptr [esi]=='"'
			call	CopyQuoted
			call	CmdOpenFile
		.else
			call	CopyUnQuoted
			call	CmdOpenFile
		.endif
	.endw
	ret

CmdOpenFile:
	invoke UpdateAll,UAM_ISOPENACTIVATE,addr buffer
	.if eax==-1
		invoke OpenTheFile,addr buffer,0
	.endif
	retn

CopyQuoted:
	lea		edi,buffer
	inc		esi
	.while byte ptr [esi]!='"' && byte ptr [esi]
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	mov		byte ptr [edi],0
	inc		esi
	.if byte ptr [esi]==' '
		inc		esi
	.endif
	retn

CopyUnQuoted:
	lea		edi,buffer
	.while byte ptr [esi]!=' ' && byte ptr [esi]
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	mov		byte ptr [edi],0
	.if byte ptr [esi]==' '
		inc		esi
	.endif
	retn

OpenCommandLine endp

Init proc lpCmdLine:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,lpCmdLine
	.if byte ptr [eax]
		invoke OpenCommandLine,lpCmdLine
	.else
		xor		eax,eax
		.if da.edtopt.fopt & EDTOPT_SESSION
			;Check Session Project
			invoke GetPrivateProfileString,addr szIniSession,addr szIniProject,NULL,addr buffer,sizeof buffer,addr da.szRadASMIni
			.if eax
				;Check if project file exists
				invoke GetFileAttributes,addr buffer
				.if eax==INVALID_HANDLE_VALUE
					xor		eax,eax
				.else
					;Check version
					invoke GetPrivateProfileInt,addr szIniVersion,addr szIniVersion,0,addr buffer
					.if eax<3000
						invoke MessageBox,ha.hWnd,addr szProjectVersion,addr DisplayName,MB_OK or MB_ICONERROR
					.else
						invoke OpenTheFile,addr buffer,ID_PROJECT
					.endif
				.endif
			.else
				;Session Assembler
				invoke GetPrivateProfileString,addr szIniSession,addr szIniAssembler,NULL,addr da.szAssembler,sizeof da.szAssembler,addr da.szRadASMIni
				.if !eax
					mov		dword ptr da.szAssembler,'msam'
					mov		dword ptr da.szAssembler[4],0
				.endif
				invoke OpenAssembler
				invoke GetSessionFiles
			.endif
		.endif
	.endif
	ret

Init endp

OpenInclude proc uses ebx esi edi,hWin:HWND
	LOCAL	chrg:CHARRANGE
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	szinc[32]:BYTE

	invoke SendMessage,hWin,EM_EXGETSEL,0,addr chrg
	invoke SendMessage,hWin,EM_EXLINEFROMCHAR,0,chrg.cpMin
	mov		word ptr LineTxt,512
	invoke SendMessage,hWin,EM_GETLINE,eax,addr LineTxt
	mov		LineTxt[eax],0
	invoke strcpy,addr buffer,addr da.szCCInc
	invoke GetItemStr,addr buffer,addr szNULL,addr szinc,sizeof szinc
	;RTrim
	invoke RTrim,addr LineTxt
	mov		esi,offset LineTxt
	mov		edi,esi
	.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
		inc		esi
	.endw
	lea		edx,szinc
	.while byte ptr [edx]
		mov		al,[edx]
		mov		ah,[esi]
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		.if ah>='a' && ah<='z'
			and		ah,5Fh
		.endif
		sub		al,ah
		.break .if !ZERO?
		inc		esi
		inc		edx
	.endw
	.if !al
		.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
			inc		esi
		.endw
		.if byte ptr [esi]=="'"
			mov		ah,"'"
			inc		esi
		.elseif byte ptr [esi]=='"'
			mov		ah,'"'
			inc		esi
		.elseif byte ptr [esi]=='<'
			mov		ah,'>'
			inc		esi
		.else
			mov		ah,0
		.endif
		.while ah!=byte ptr [esi] && byte ptr [esi] && byte ptr [esi]!= ';' && word ptr [esi] != "//" && word ptr [esi] != "/*"
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
		mov		byte ptr [edi],0
		mov		buffer,0
		.if da.fProject
			;Project path
			invoke strcpy,addr buffer,addr da.szProjectPath
			invoke strcat,addr buffer,addr szBS
		.endif
		invoke strcat,addr buffer,addr LineTxt
		invoke GetFileAttributes,addr buffer
		.if eax!=INVALID_HANDLE_VALUE
			invoke UpdateAll,UAM_ISOPENACTIVATE,addr buffer
			.if eax==-1
				invoke OpenTheFile,addr buffer,0
			.endif
		.else
			xor		ebx,ebx
			.while ebx<8
				invoke RtlZeroMemory,addr tmpbuff,sizeof tmpbuff
				invoke BinToDec,ebx,addr szinc
				invoke GetPrivateProfileString,addr szIniEnvironment,addr szinc,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
				.if eax
					invoke GetItemStr,addr tmpbuff,addr szNULL,addr szinc,sizeof szinc
					invoke FixPath,addr tmpbuff,addr da.szAppPath,addr szDollarA
					mov		esi,offset tmpbuff
					.while byte ptr [esi]
						.if byte ptr [esi]==';'
							mov		byte ptr [esi],0
						.endif
						inc		esi
					.endw
					mov		esi,offset tmpbuff
					.while byte ptr [esi]
						invoke strcpy,addr buffer,esi
						invoke strcat,addr buffer,addr szBS
						invoke strcat,addr buffer,addr LineTxt
						invoke GetFileAttributes,addr buffer
						.if eax!=INVALID_HANDLE_VALUE
							invoke UpdateAll,UAM_ISOPENACTIVATE,addr buffer
							.if eax==-1
								invoke OpenTheFile,addr buffer,0
							.endif
							jmp		Ex
						.endif
						invoke strlen,esi
						lea		esi,[esi+eax+1]
					.endw
				.endif
				inc		ebx
			.endw
			invoke strcpy,addr buffer,addr LineTxt
			invoke GetFileAttributes,addr buffer
			.if eax!=INVALID_HANDLE_VALUE
				invoke UpdateAll,UAM_ISOPENACTIVATE,addr buffer
				.if eax==-1
					invoke OpenTheFile,addr buffer,0
				.endif
			.endif
		.endif
	.endif
  Ex:
	ret

OpenInclude endp
