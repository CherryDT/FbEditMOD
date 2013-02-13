MAKE struct
	hThread		dd ?
	hRead		dd ?
	hWrite		dd ?
	pInfo		PROCESS_INFORMATION <?>
	uExit		dd ?
	buffer		db 512 dup(?)
MAKE ends

.data

defPathBin				db 'C:\masm32\bin',0
defPathInc				db 'C:\masm32\include',0
defPathLib				db 'C:\masm32\lib',0

ExtRC					db '.rc',0
ExtRes					db '.res',0
ExtObj					db '.obj',0
ExtDef					db '.def',0
ExtExe					db '.exe',0
ExtDll					db '.dll',0
ExtLib					db '.lib',0
ExtCom					db '.com',0

rsrcrc					db 'rsrc.rc',0
rsrcres					db 'rsrc.res',0

MakeDone				db 0Dh,'Make done.',0Dh,0
Errors					db 0Dh,'Error(s) occured.',0Dh,0
Terminated				db 0Dh,'Terminated by user.',0
NoRC					db 0Dh,'No .rc file found.',0Dh,0
Exec					db 0Dh,'Executing:',0
NoDel					db 0Dh,'Could not delete:',0Dh,0

CreatePipeError			db 'Error during pipe creation',0
CreateProcessError		db 'Error during process creation',0Dh,0Ah,0

.data?

make					MAKE <>

.code

MakeThreadProc proc uses ebx,Param:DWORD
	LOCAL	sat:SECURITY_ATTRIBUTES
	LOCAL	startupinfo:STARTUPINFO
	LOCAL	bytesRead:DWORD
	LOCAL	buffer[256]:BYTE

	invoke SendMessage,ha.hOut,EM_REPLACESEL,FALSE,offset szCr
	invoke SendMessage,ha.hOut,EM_REPLACESEL,FALSE,addr make.buffer
	invoke SendMessage,ha.hOut,EM_REPLACESEL,FALSE,offset szCr
	invoke SendMessage,ha.hOut,EM_SCROLLCARET,0,0
	.if Param==IDM_MAKE_RUN
		invoke WinExec,addr make.buffer,SW_SHOWNORMAL
		.if eax>=32
			xor		eax,eax
		.endif
	.else
		mov sat.nLength,sizeof SECURITY_ATTRIBUTES
		mov sat.lpSecurityDescriptor,NULL
		mov sat.bInheritHandle,TRUE
		invoke CreatePipe,addr make.hRead,addr make.hWrite,addr sat,NULL
		.if eax==NULL
			;CreatePipe failed
			invoke LoadCursor,0,IDC_ARROW
			invoke SetCursor,eax
			invoke MessageBox,ha.hWnd,addr CreatePipeError,addr szAppName,MB_ICONERROR+MB_OK
			xor		eax,eax
		.else
			mov startupinfo.cb,sizeof STARTUPINFO
			invoke GetStartupInfo,addr startupinfo
			mov eax,make.hWrite
			mov startupinfo.hStdOutput,eax
			mov startupinfo.hStdError,eax
			mov startupinfo.dwFlags,STARTF_USESHOWWINDOW+STARTF_USESTDHANDLES
			mov startupinfo.wShowWindow,SW_HIDE
			;Create process
			invoke CreateProcess,NULL,addr make.buffer,NULL,NULL,TRUE,NULL,NULL,NULL,addr startupinfo,addr make.pInfo
			.if eax==NULL
				;CreateProcess failed
				invoke CloseHandle,make.hRead
				invoke CloseHandle,make.hWrite
				invoke LoadCursor,0,IDC_ARROW
				invoke SetCursor,eax
				invoke strcpy,addr buffer,addr CreateProcessError
				invoke strcat,addr buffer,addr make.buffer
				invoke MessageBox,ha.hWnd,addr buffer,addr szAppName,MB_ICONERROR+MB_OK
				xor		eax,eax
			.else
				invoke CloseHandle,make.hWrite
				invoke RtlZeroMemory,addr make.buffer,sizeof make.buffer
				xor		ebx,ebx
				.while TRUE
					invoke ReadFile,make.hRead,addr make.buffer[ebx],1,addr bytesRead,NULL
					.if eax==NULL
						.if ebx
							call	OutputText
						.endif
						.break
					.else
						.if make.buffer[ebx]==0Ah || ebx==511
							call	OutputText
						.else
							inc		ebx
						.endif
					.endif
				.endw
				invoke GetExitCodeProcess,make.pInfo.hProcess,addr make.uExit
				invoke CloseHandle,make.hRead
				invoke CloseHandle,make.pInfo.hProcess
				invoke CloseHandle,make.pInfo.hThread
				mov		eax,TRUE
			.endif
		.endif
	.endif
	invoke ExitThread,eax
	ret

OutputText:
	mov		make.buffer[ebx+1],0
	invoke SendMessage,ha.hOut,EM_REPLACESEL,FALSE,addr make.buffer
	invoke SendMessage,ha.hOut,EM_SCROLLCARET,0,0
	xor		ebx,ebx
	retn

MakeThreadProc endp

FindErrors proc uses ebx
	LOCAL	buffer[512]:BYTE
	LOCAL	nLn:DWORD
	LOCAL	nLnErr:DWORD
	LOCAL	nLastLnErr:DWORD
	LOCAL	nErr:DWORD

	invoke SendMessage,ha.hOut,EM_GETLINECOUNT,0,0
	xor		ebx,ebx
	mov		nErrID,ebx
	mov		nLn,ebx
	mov		nLastLnErr,-1
	.while nLn<eax
		push	eax
		call	TestLine
		pop		eax
		inc		nLn
	.endw
	mov		ErrID[ebx*4],0
	ret

TestLine:
	mov		word ptr buffer,sizeof buffer-1
	invoke SendMessage,ha.hOut,EM_GETLINE,nLn,addr buffer
	mov		byte ptr buffer[eax],0
	invoke iniInStr,addr buffer,addr szError
	.if eax!=-1
		.while eax && byte ptr buffer[eax]!='('
			dec		eax
		.endw
		mov		byte ptr buffer[eax],0
		invoke AsciiToDw,addr buffer[eax+1]
		dec		eax
		.if eax!=nLastLnErr
			mov		nLnErr,eax
			mov		nLastLnErr,eax
			invoke SendMessage,ha.hOut,REM_SETBOOKMARK,nLn,6
			invoke SendMessage,ha.hOut,REM_GETBMID,nLn,0
			mov		nErr,eax
			invoke strlen,addr buffer
			.while eax && word ptr buffer[eax+1]!='\:'
				dec		eax
			.endw
			invoke OpenEditFile,addr buffer[eax],0
			invoke GetWindowLong,ha.hREd,GWL_ID
			.if eax==IDC_RAE
				invoke SendMessage,ha.hREd,REM_SETERROR,nLnErr,nErr
				mov		eax,nErr
				mov		ErrID[ebx*4],eax
				inc		ebx
			.endif
		.endif
	.endif
	retn

FindErrors endp

OutputMake proc uses ebx,nCommand:DWORD,lpFileName:DWORD,fClear:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer2[256]:BYTE
	LOCAL	fExitCode:DWORD
	LOCAL	ThreadID:DWORD
	LOCAL	msg:MSG

	invoke OutputSelect,0
	invoke OutputShow,TRUE
	movzx	eax,da.MainFile
	.if !eax
		invoke SendMessage,ha.hOut,WM_SETTEXT,0,addr szNoMain
		ret
	.endif
	invoke SetCurDir,lpFileName,FALSE
	mov		fExitCode,0
	invoke LoadCursor,0,IDC_WAIT
	invoke SetCursor,eax
	invoke SetFocus,ha.hOut
	mov		make.buffer,0
	.if fClear==1 || fClear==2
		invoke SendMessage,ha.hOut,WM_SETTEXT,0,addr make.buffer
		invoke SendMessage,ha.hOut,EM_SCROLLCARET,0,0
	.endif
	mov		eax,nCommand
	.if eax==IDM_MAKE_COMPILE
		invoke SendMessage,ha.hCbo,CB_GETCURSEL,0,0
		mov		edx,sizeof MAKEOPT
		mul		edx
		lea		edx,da.makeopt.szCompileRC[eax]
		.if !byte ptr [edx]
			invoke SendMessage,ha.hOut,EM_REPLACESEL,FALSE,offset NoRC
			invoke SendMessage,ha.hOut,EM_SCROLLCARET,0,0
			jmp		Ex
		.endif
		invoke strcpy,addr make.buffer,addr da.makeopt.szCompileRC[eax]
		invoke strcat,addr make.buffer,addr szSpc
		;Try da.FileName.rc
		invoke strcpy,addr buffer2,lpFileName
		invoke RemoveFileExt,addr buffer2
		invoke strcat,addr buffer2,offset ExtRC
		invoke GetFileAttributes,addr buffer2
		.if eax==-1
			;FileName.rc not found, try rsrc.rc
			mov		lpFileName,offset rsrcrc
			invoke RemoveFileName,addr buffer2
			invoke strcat,addr buffer2,lpFileName
			invoke GetFileAttributes,addr buffer2
			.if eax==-1
				;FileName.rc nor rsrc.rc found, give message and exit
				invoke SendMessage,ha.hOut,EM_REPLACESEL,FALSE,offset NoRC
				invoke SendMessage,ha.hOut,EM_SCROLLCARET,0,0
				jmp		Ex
			.endif
		.endif
		invoke strcat,addr make.buffer,offset szQuote
		invoke strcat,addr make.buffer,addr buffer2
		invoke strcat,addr make.buffer,offset szQuote
		mov		eax,offset ExtRes
	.elseif eax==IDM_MAKE_ASSEMBLE
		invoke SendMessage,ha.hCbo,CB_GETCURSEL,0,0
		mov		edx,sizeof MAKEOPT
		mul		edx
		invoke strcpy,addr make.buffer,addr da.makeopt.szAssemble[eax]
		invoke strcat,addr make.buffer,addr szSpc
		invoke strcat,addr make.buffer,offset szQuote
		invoke strcat,addr make.buffer,lpFileName
		invoke strcat,addr make.buffer,offset szQuote
		mov		eax,offset ExtObj
	.elseif eax==IDM_MAKE_LINK
		lea		ebx,make.buffer
		invoke SendMessage,ha.hCbo,CB_GETCURSEL,0,0
		mov		edx,sizeof MAKEOPT
		mul		edx
		push	da.makeopt.OutpuType[eax]
		lea		edx,da.makeopt.szCompileRC[eax]
		.if byte ptr [edx]
			mov		edx,TRUE
		.else
			mov		edx,FALSE
		.endif
		push	edx
		invoke strcpy,ebx,addr da.makeopt.szLink[eax]
		invoke strlen,ebx
		.if dword ptr [ebx+eax-4]==':FED'
			invoke strcpy,addr buffer2,lpFileName
			invoke RemoveFileExt,addr buffer2
			invoke strcat,addr buffer2,offset ExtDef
			invoke GetFileAttributes,addr buffer2
			.if eax==INVALID_HANDLE_VALUE
				invoke strlen,ebx
				mov		byte ptr [ebx+eax-6],0
			.else
				invoke strcat,ebx,offset szQuote
				invoke strcat,ebx,addr buffer2
				invoke strcat,ebx,offset szQuote
			.endif
		.endif
		invoke strcat,ebx,addr szSpc
		invoke strcpy,addr buffer2,lpFileName
		invoke RemoveFileExt,addr buffer2
		invoke strcat,addr buffer2,offset ExtObj
		invoke strcat,ebx,offset szQuote
		invoke strcat,ebx,addr buffer2
		invoke strcat,ebx,offset szQuote
		pop		eax
		.if eax
			invoke RemoveFileExt,addr buffer2
			invoke strcat,addr buffer2,offset ExtRes
			invoke GetFileAttributes,addr buffer2
			.if eax==INVALID_HANDLE_VALUE
				;FileName.res not found, try if rsrc.res exist
				invoke RemoveFileName,addr buffer2
				invoke strcat,addr buffer2,offset rsrcres
				invoke GetFileAttributes,addr buffer2
				.if eax!=-1
					;rsrc.res found
					invoke strcat,addr make.buffer,offset szSpc
					invoke strcat,addr make.buffer,offset szQuote
					invoke strcat,addr make.buffer,addr buffer2
					invoke strcat,addr make.buffer,offset szQuote
				.endif
			.else
				;FileName.res found
				invoke strcat,addr make.buffer,offset szSpc
				invoke strcat,addr make.buffer,offset szQuote
				invoke strcat,addr make.buffer,addr buffer2
				invoke strcat,addr make.buffer,offset szQuote
			.endif
		.endif
		pop		eax
		.if !eax
			mov		eax,offset ExtExe
		.elseif eax==1
			mov		eax,offset ExtDll
		.elseif eax==2
			mov		eax,offset ExtLib
		.else
			mov		eax,offset ExtCom
		.endif
	.elseif eax==IDM_MAKE_RUN
		invoke SendMessage,ha.hOut,EM_REPLACESEL,FALSE,offset Exec
		invoke strcpy,addr make.buffer,lpFileName
		invoke RemoveFileExt,addr make.buffer
		invoke strcat,addr make.buffer,offset ExtExe
		xor		eax,eax
	.else
		jmp		Ex
	.endif
	.if eax
		;Delete old file
		push	eax
		invoke strcpy,addr buffer2,lpFileName
		invoke RemoveFileExt,addr buffer2
		pop		eax
		invoke strcat,addr buffer2,eax
		invoke GetFileAttributes,addr buffer2
		.if eax!=INVALID_HANDLE_VALUE
			invoke DeleteFile,addr buffer2
			.if !eax
				mov		fExitCode,-1
				invoke SendMessage,ha.hOut,EM_REPLACESEL,FALSE,offset NoDel
				invoke SendMessage,ha.hOut,EM_REPLACESEL,FALSE,addr buffer2
				invoke SendMessage,ha.hOut,EM_REPLACESEL,FALSE,offset szCr
				invoke SendMessage,ha.hOut,EM_REPLACESEL,FALSE,offset Errors
				jmp		Ex
			.endif
		.endif
	.endif
	invoke CreateThread,NULL,NULL,addr MakeThreadProc,nCommand,NORMAL_PRIORITY_CLASS,addr ThreadID
	mov		make.hThread,eax
	.while TRUE
		invoke LoadCursor,0,IDC_WAIT
		invoke SetCursor,eax
		invoke GetMessage,addr msg,NULL,0,0
		mov		eax,msg.message
		.if eax!=WM_CHAR
			.if msg.wParam==VK_ESCAPE
				invoke TerminateProcess,make.pInfo.hProcess,1234
			.endif
		.elseif eax!=WM_KEYDOWN && eax!=WM_CLOSE && (eax<WM_MOUSEFIRST || eax>WM_MOUSELAST)
			invoke TranslateMessage,addr msg
			invoke DispatchMessage,addr msg
		.endif
		invoke GetExitCodeThread,make.hThread,addr ThreadID
		.break .if ThreadID!=STILL_ACTIVE
	.endw
	invoke CloseHandle,make.hThread
	.if ThreadID
		.if make.uExit==1234
			invoke SendMessage,ha.hOut,EM_REPLACESEL,FALSE,offset Terminated
			invoke FindErrors
		.else
			mov		fExitCode,-1
			;Check if file exists
			invoke GetFileAttributes,addr buffer2
			.if eax==INVALID_HANDLE_VALUE
				mov		fExitCode,eax
				invoke SendMessage,ha.hOut,EM_REPLACESEL,FALSE,offset Errors
				invoke FindErrors
			.else
				.if fClear==1 || fClear==3
					invoke SendMessage,ha.hOut,EM_REPLACESEL,FALSE,offset MakeDone
				.endif
				mov		fExitCode,0
			.endif
		.endif
		.if dword ptr [ErrID]
			invoke SendMessage,ha.hWnd,WM_COMMAND,IDM_EDIT_NEXTERROR,0
		.else
			invoke SendMessage,ha.hOut,EM_SCROLLCARET,0,0
			invoke SetFocus,ha.hOut
		.endif
	.endif
  Ex:
	invoke LoadCursor,0,IDC_ARROW
	invoke SetCursor,eax
	mov		eax,fExitCode
	ret

OutputMake endp

