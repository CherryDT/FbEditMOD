
.data

CompileRC				db '\masm32\bin\rc /v ',0
ExtRC					db '.rc',0
ExtRes					db '.res',0
Assemble				db '\masm32\bin\ml /c /coff /Cp /I\masm32\include ',0
ExtObj					db '.obj',0
Link					db '\masm32\bin\link /SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 /LIBPATH:\masm32\lib ',0
ExtExe					db '.exe',0

rsrcrc					db 'rsrc.rc',0
rsrcres					db 'rsrc.res',0

MakeDone				db 0Dh,'Make done.',0Dh,0
Errors					db 0Dh,'Error(s) occured.',0Dh,0
NoRC					db 0Dh,'No .rc file found.',0Dh,0
CreatePipeError			db 'Error during pipe creation',0
CreateProcessError		db 'Error during process creation',0Dh,0Ah,0

.code

OutputMake proc uses ebx,nCommand:DWORD,lpFileName:DWORD,fClear:DWORD
	LOCAL	sat:SECURITY_ATTRIBUTES
	LOCAL	startupinfo:STARTUPINFO
	LOCAL	pinfo:PROCESS_INFORMATION
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer2[256]:BYTE
	LOCAL	hRead:DWORD
	LOCAL	hWrite:DWORD
	LOCAL	outbuffer[512]:byte
	LOCAL	bytesRead:DWORD
	LOCAL	fExitCode:DWORD

	mov		fExitCode,0
	invoke LoadCursor,0,IDC_WAIT
	invoke SetCursor,eax
	test	wpos.fView,4
	.if ZERO?
		or		wpos.fView,4
		invoke ShowWindow,hVSplit,SW_SHOWNA
		invoke ShowWindow,hOut,SW_SHOWNA
		invoke SendMessage,hWnd,WM_SIZE,0,1
	.endif
	invoke SetFocus,hOut
	mov		outbuffer,0
	.if fClear==1 || fClear==2
		invoke SendMessage,hOut,WM_SETTEXT,0,addr outbuffer
		invoke SendMessage,hOut,EM_SCROLLCARET,0,0
	.endif
	mov		eax,nCommand
	.if eax==IDM_MAKE_COMPILE
		invoke lstrcpy,addr outbuffer,offset CompileRC
		;Try FileName.rc
		invoke lstrcpy,addr buffer2,lpFileName
		invoke RemoveFileExt,addr buffer2
		invoke lstrcat,addr buffer2,offset ExtRC
		invoke GetFileAttributes,addr buffer2
		.if eax==-1
			;FileName.rc not found, try rsrc.rc
			mov		lpFileName,offset rsrcrc
			invoke RemoveFileName,addr buffer2
			invoke lstrcat,addr buffer2,lpFileName
			invoke GetFileAttributes,addr buffer2
			.if eax==-1
				;FileName.rc nor rsrc.rc found, give message and exit
				invoke SendMessage,hOut,EM_REPLACESEL,FALSE,offset NoRC
				invoke SendMessage,hOut,EM_SCROLLCARET,0,0
				jmp		Ex
			.endif
		.endif
		invoke lstrcat,addr outbuffer,offset szQuote
		invoke lstrcat,addr outbuffer,addr buffer2
		invoke lstrcat,addr outbuffer,offset szQuote
		mov		eax,offset ExtRes
	.elseif eax==IDM_MAKE_ASSEMBLE
		invoke lstrcpy,addr outbuffer,offset Assemble
		invoke lstrcat,addr outbuffer,offset szQuote
		invoke lstrcat,addr outbuffer,lpFileName
		invoke lstrcat,addr outbuffer,offset szQuote
		mov		eax,offset ExtObj
	.elseif eax==IDM_MAKE_LINK
		invoke lstrcpy,addr outbuffer,offset Link
		invoke lstrcpy,addr buffer2,lpFileName
		invoke RemoveFileExt,addr buffer2
		invoke lstrcat,addr buffer2,offset ExtObj
		invoke lstrcat,addr outbuffer,offset szQuote
		invoke lstrcat,addr outbuffer,addr buffer2
		invoke lstrcat,addr outbuffer,offset szQuote
		invoke RemoveFileExt,addr buffer2
		invoke lstrcat,addr buffer2,offset ExtRes
		invoke GetFileAttributes,addr buffer2
		.if eax==-1
			;FileName.res not found, try if rsrc.res exist
			invoke RemoveFileName,addr buffer2
			invoke lstrcat,addr buffer2,offset rsrcres
			invoke GetFileAttributes,addr buffer2
			.if eax!=-1
				;rsrc.res found
				invoke lstrcat,addr outbuffer,offset szSpc
				invoke lstrcat,addr outbuffer,offset szQuote
				invoke lstrcat,addr outbuffer,addr buffer2
				invoke lstrcat,addr outbuffer,offset szQuote
			.endif
		.else
			;FileName.res found
			invoke lstrcat,addr outbuffer,offset szSpc
			invoke lstrcat,addr outbuffer,offset szQuote
			invoke lstrcat,addr outbuffer,addr buffer2
			invoke lstrcat,addr outbuffer,offset szQuote
		.endif
		mov		eax,offset ExtExe
	.else
		jmp		Ex
	.endif
	.if eax
		;Delete old file
		push	eax
		invoke lstrcpy,addr buffer2,lpFileName
		invoke RemoveFileExt,addr buffer2
		pop		eax
		invoke lstrcat,addr buffer2,eax
		invoke DeleteFile,addr buffer2
	.endif
	invoke SendMessage,hOut,EM_REPLACESEL,FALSE,offset szCr
	invoke SendMessage,hOut,EM_REPLACESEL,FALSE,addr outbuffer
	invoke SendMessage,hOut,EM_REPLACESEL,FALSE,offset szCr
	invoke SendMessage,hOut,EM_REPLACESEL,FALSE,offset szCr
	invoke SendMessage,hOut,EM_SCROLLCARET,0,0
	mov sat.nLength,sizeof SECURITY_ATTRIBUTES
	mov sat.lpSecurityDescriptor,NULL
	mov sat.bInheritHandle,TRUE
	invoke CreatePipe,addr hRead,addr hWrite,addr sat,NULL
	.if eax==NULL
		;CreatePipe failed
		invoke LoadCursor,0,IDC_ARROW
		invoke SetCursor,eax
		invoke MessageBox,hWnd,addr CreatePipeError,addr szAppName,MB_ICONERROR+MB_OK
	.else
		mov startupinfo.cb,sizeof STARTUPINFO
		invoke GetStartupInfo,addr startupinfo
		mov eax,hWrite
		mov startupinfo.hStdOutput,eax
		mov startupinfo.hStdError,eax
		mov startupinfo.dwFlags,STARTF_USESHOWWINDOW+STARTF_USESTDHANDLES
		mov startupinfo.wShowWindow,SW_HIDE
		;Create process
		invoke CreateProcess,NULL,addr outbuffer,NULL,NULL,TRUE,NULL,NULL,NULL,addr startupinfo,addr pinfo
		.if eax==NULL
			;CreateProcess failed
			invoke CloseHandle,hRead
			invoke CloseHandle,hWrite
			invoke LoadCursor,0,IDC_ARROW
			invoke SetCursor,eax
			invoke lstrcpy,addr buffer,addr CreateProcessError
			invoke lstrcat,addr buffer,addr outbuffer
			invoke MessageBox,hWnd,addr buffer,addr szAppName,MB_ICONERROR+MB_OK
		.else
			invoke CloseHandle,hWrite
			invoke CloseHandle,pinfo.hProcess
			invoke CloseHandle,pinfo.hThread
			invoke RtlZeroMemory,addr outbuffer,sizeof outbuffer
			xor		ebx,ebx
			.while TRUE
				invoke ReadFile,hRead,addr outbuffer[ebx],1,addr bytesRead,NULL
				.if eax==NULL
					.if ebx
						call	OutputText
					.endif
					.break
				.else
					.if outbuffer[ebx]==0Ah || ebx==511
						call	OutputText
					.else
						inc		ebx
					.endif
				.endif
			.endw
			invoke CloseHandle,hRead
		.endif
		;Check if file exists
		invoke GetFileAttributes,addr buffer2
		.if eax==-1
			mov		fExitCode,eax
			invoke SendMessage,hOut,EM_REPLACESEL,FALSE,offset Errors
		.else
			.if fClear==1 || fClear==3
				invoke SendMessage,hOut,EM_REPLACESEL,FALSE,offset MakeDone
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

OutputText:
	mov		outbuffer[ebx+1],0
	invoke SendMessage,hOut,EM_REPLACESEL,FALSE,addr outbuffer
	invoke SendMessage,hOut,EM_SCROLLCARET,0,0
	xor		ebx,ebx
	retn

OutputMake endp

