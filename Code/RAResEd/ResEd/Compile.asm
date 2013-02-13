MAKE struct
	hThread		dd ?
	hRead		dd ?
	hWrite		dd ?
	pInfo		PROCESS_INFORMATION <?>
	uExit		dd ?
	buffer		db 512 dup(?)
MAKE ends

.data

ExtRC					db '.rc',0
ExtRes					db '.res',0

MakeDone				db 0Dh,'Make done.',0Dh,0
Errors					db 0Dh,'Error(s) occured.',0Dh,0
Terminated				db 0Dh,'Terminated by user.',0
NoDel					db 0Dh,'Could not delete:',0Dh,0

CreatePipeError			db 'Error during pipe creation',0
CreateProcessError		db 'Error during process creation',0Dh,0Ah,0

.data?

make					MAKE <>
hOut					HWND ?

.code

MakeThreadProc proc uses ebx,Param:DWORD
	LOCAL	sat:SECURITY_ATTRIBUTES
	LOCAL	startupinfo:STARTUPINFO
	LOCAL	bytesRead:DWORD
	LOCAL	buffer[256]:BYTE

	invoke SendMessage,hOut,EM_REPLACESEL,FALSE,offset szCr
	invoke SendMessage,hOut,EM_REPLACESEL,FALSE,addr make.buffer
	invoke SendMessage,hOut,EM_REPLACESEL,FALSE,offset szCr
	invoke SendMessage,hOut,EM_SCROLLCARET,0,0
	mov sat.nLength,sizeof SECURITY_ATTRIBUTES
	mov sat.lpSecurityDescriptor,NULL
	mov sat.bInheritHandle,TRUE
	invoke CreatePipe,addr make.hRead,addr make.hWrite,addr sat,NULL
	.if eax==NULL
		;CreatePipe failed
		invoke LoadCursor,0,IDC_ARROW
		invoke SetCursor,eax
		invoke MessageBox,hWnd,addr CreatePipeError,addr szAppName,MB_ICONERROR+MB_OK
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
			invoke lstrcpy,addr buffer,addr CreateProcessError
			invoke lstrcat,addr buffer,addr make.buffer
			invoke MessageBox,hWnd,addr buffer,addr szAppName,MB_ICONERROR+MB_OK
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
	invoke ExitThread,eax
	ret

OutputText:
	mov		make.buffer[ebx+1],0
	invoke SendMessage,hOut,EM_REPLACESEL,FALSE,addr make.buffer
	invoke SendMessage,hOut,EM_SCROLLCARET,0,0
	xor		ebx,ebx
	retn

MakeThreadProc endp

OutputMake proc uses ebx esi edi,lpCommand:DWORD,lpFileName:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer2[MAX_PATH]:BYTE
	LOCAL	fExitCode:DWORD
	LOCAL	ThreadID:DWORD
	LOCAL	msg:MSG

	invoke lstrcpy,addr buffer,lpFileName
	invoke lstrlen,addr buffer
	.while byte ptr buffer[eax]!='\' && eax
		dec		eax
	.endw
	mov		buffer[eax],0
	invoke SetCurrentDirectory,addr buffer
	mov		esi,lpFileName
	lea		edi,buffer
	invoke lstrlen,esi
	mov		ecx,eax
	.while ecx
		dec		ecx
		.break .if byte ptr [esi+ecx]=='.'
	.endw
	.if byte ptr [esi+ecx]!='.'
		invoke lstrlen,esi
		mov		ecx,eax
	.endif
	.while ecx
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
		dec		ecx
	.endw
	mov		byte ptr [edi],0
	mov		fExitCode,0
	invoke LoadCursor,0,IDC_WAIT
	invoke SetCursor,eax
	invoke SetFocus,hOut
	mov		make.buffer,0
	invoke SendMessage,hOut,WM_SETTEXT,0,addr make.buffer
	invoke SendMessage,hOut,EM_SCROLLCARET,0,0
	mov		esi,lpCommand
	lea		edi,make.buffer
	.while byte ptr [esi]
		mov		al,[esi]
		.if al=='$'
			invoke lstrcpy,edi,addr buffer
			invoke lstrlen,edi
			lea		edi,[edi+eax]
		.else
			mov		[edi],al
			inc		edi
		.endif
		inc		esi
	.endw
	mov		byte ptr [edi],0
	;Delete old file
	invoke lstrcat,addr buffer,addr ExtRes
	invoke GetFileAttributes,addr buffer
	.if eax!=INVALID_HANDLE_VALUE
		invoke DeleteFile,addr buffer
		.if !eax
			mov		fExitCode,-1
			invoke SendMessage,hOut,EM_REPLACESEL,FALSE,offset NoDel
			invoke SendMessage,hOut,EM_REPLACESEL,FALSE,addr buffer
			invoke SendMessage,hOut,EM_REPLACESEL,FALSE,offset szCr
			invoke SendMessage,hOut,EM_REPLACESEL,FALSE,offset Errors
			jmp		Ex
		.endif
	.endif
	invoke CreateThread,NULL,NULL,addr MakeThreadProc,0,NORMAL_PRIORITY_CLASS,addr ThreadID
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
			invoke SendMessage,hOut,EM_REPLACESEL,FALSE,offset Terminated
		.else
			mov		fExitCode,-1
			;Check if file exists
			invoke GetFileAttributes,addr buffer
			.if eax==-1
				mov		fExitCode,eax
				invoke SendMessage,hOut,EM_REPLACESEL,FALSE,offset Errors
			.else
				invoke SendMessage,hOut,EM_REPLACESEL,FALSE,offset MakeDone
				mov		fExitCode,0
			.endif
		.endif
		invoke SendMessage,hOut,EM_SCROLLCARET,0,0
		invoke SetFocus,hOut
	.endif
  Ex:
	invoke LoadCursor,0,IDC_ARROW
	invoke SetCursor,eax
	mov		eax,fExitCode
	ret

OutputMake endp

Compile proc

	invoke SendMessage,hResEd,DEM_SHOWOUTPUT,TRUE,0
	invoke SetFocus,hOut
	or		wpos.fView,1
	invoke SendMessage,hTbr,TB_CHECKBUTTON,IDM_VIEW_OUTPUT,TRUE
	invoke SaveProjectFile,offset ProjectFileName,hResEdSave
	.if eax
		invoke OutputMake,offset CompileCommand,offset ProjectFileName
	.else
		invoke SendMessage,hOut,WM_SETTEXT,0,offset szSaveFileFail
	.endif
	ret

Compile endp
