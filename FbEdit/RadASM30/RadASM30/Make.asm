
MAKEEXE struct
	hThread		DWORD ?
	hRead		DWORD ?
	hWrite		DWORD ?
	pInfo		PROCESS_INFORMATION <?>
	uExit		DWORD ?
	buffer		BYTE MAX_PATH*2 dup(?)
	cmd			BYTE MAX_PATH dup(?)
	cmdline		BYTE MAX_PATH dup(?)
	output		BYTE MAX_PATH dup(?)
MAKEEXE ends

.const

MakeDone				BYTE 0Dh,'Make done.',0Dh,0
Errors					BYTE 0Dh,'Error(s) occured.',0Dh,0
Terminated				BYTE 0Dh,'Terminated by user.',0Dh,0
Exec					BYTE 0Dh,'Executing:',0
Debug					BYTE 0Dh,'Debuging:',0
NoDel					BYTE 0Dh,'Could not delete:',0Dh,0

CreatePipeError			BYTE 'Error during pipe creation',0
CreateProcessError		BYTE 'Error during process creation',0Dh,0Ah,0
szAtModDotTxt			BYTE '@Mod.txt',0

.data?

makeexe					MAKEEXE <>

.code

MakeThreadProc proc uses ebx,Param:DWORD
	LOCAL	sat:SECURITY_ATTRIBUTES
	LOCAL	startupinfo:STARTUPINFO
	LOCAL	bytesRead:DWORD
	LOCAL	buffer[256]:BYTE

	invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,offset szCR
	.if Param==IDM_MAKE_RUN
		invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,addr makeexe.cmd
		.if makeexe.cmdline
			invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,addr szSpc
			invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,addr makeexe.cmdline
		.endif
	.else
		invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,addr makeexe.buffer
	.endif
	invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,offset szCR
	invoke SendMessage,ha.hOutput,EM_SCROLLCARET,0,0
	.if Param==IDM_MAKE_RUN
		.if makeexe.cmd
			invoke ShellExecute,ha.hWnd,NULL,addr makeexe.cmd,addr makeexe.cmdline,NULL,SW_SHOWNORMAL
		.else
			invoke ShellExecute,ha.hWnd,NULL,addr makeexe.cmdline,NULL,NULL,SW_SHOWNORMAL
		.endif
		.if eax>=32
			xor		eax,eax
		.endif
	.elseif Param==IDM_MAKE_DEBUG
		invoke ShellExecute,ha.hWnd,NULL,addr da.szDebug,addr makeexe.buffer,NULL,SW_SHOWNORMAL
		.if eax>=32
			xor		eax,eax
		.endif
	.else
		mov sat.nLength,sizeof SECURITY_ATTRIBUTES
		mov sat.lpSecurityDescriptor,NULL
		mov sat.bInheritHandle,TRUE
		invoke CreatePipe,addr makeexe.hRead,addr makeexe.hWrite,addr sat,NULL
		.if eax==NULL
			;CreatePipe failed
			invoke LoadCursor,0,IDC_ARROW
			invoke SetCursor,eax
			invoke MessageBox,ha.hWnd,addr CreatePipeError,addr DisplayName,MB_ICONERROR+MB_OK
			xor		eax,eax
		.else
			mov startupinfo.cb,sizeof STARTUPINFO
			invoke GetStartupInfo,addr startupinfo
			mov eax,makeexe.hWrite
			mov startupinfo.hStdOutput,eax
			mov startupinfo.hStdError,eax
			mov startupinfo.dwFlags,STARTF_USESHOWWINDOW+STARTF_USESTDHANDLES
			mov startupinfo.wShowWindow,SW_HIDE
			;Create process
			invoke CreateProcess,NULL,addr makeexe.buffer,NULL,NULL,TRUE,NULL,NULL,NULL,addr startupinfo,addr makeexe.pInfo
			.if eax==NULL
				;CreateProcess failed
				invoke CloseHandle,makeexe.hRead
				invoke CloseHandle,makeexe.hWrite
				invoke LoadCursor,0,IDC_ARROW
				invoke SetCursor,eax
				invoke strcpy,addr buffer,addr CreateProcessError
				invoke strcat,addr buffer,addr makeexe.buffer
				invoke MessageBox,ha.hWnd,addr buffer,addr DisplayName,MB_ICONERROR+MB_OK
				xor		eax,eax
			.else
				invoke CloseHandle,makeexe.hWrite
				invoke RtlZeroMemory,addr makeexe.buffer,sizeof makeexe.buffer
				xor		ebx,ebx
				.while TRUE
					invoke ReadFile,makeexe.hRead,addr makeexe.buffer[ebx],1,addr bytesRead,NULL
					.if eax==NULL
						.if ebx
							call	OutputText
						.endif
						.break
					.else
						.if makeexe.buffer[ebx]==0Ah || ebx==511
							call	OutputText
						.else
							inc		ebx
						.endif
					.endif
				.endw
				invoke GetExitCodeProcess,makeexe.pInfo.hProcess,addr makeexe.uExit
				invoke CloseHandle,makeexe.hRead
				invoke CloseHandle,makeexe.pInfo.hProcess
				invoke CloseHandle,makeexe.pInfo.hThread
				mov		eax,TRUE
			.endif
		.endif
	.endif
	invoke ExitThread,eax
	ret

OutputText:
	mov		makeexe.buffer[ebx+1],0
	invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,addr makeexe.buffer
	invoke SendMessage,ha.hOutput,EM_SCROLLCARET,0,0
	xor		ebx,ebx
	retn

MakeThreadProc endp

FindErrors proc uses ebx esi edi
	LOCAL	buffer[512]:BYTE
	LOCAL	szWord[64]:BYTE
	LOCAL	nLn:DWORD
	LOCAL	nLnErr:DWORD
	LOCAL	nErr:DWORD

	invoke SendMessage,ha.hOutput,EM_GETLINECOUNT,0,0
	xor		ebx,ebx
	mov		da.nErrID,ebx
	mov		nLn,ebx
	.while nLn<eax
		push	eax
		;Get the line
		mov		word ptr buffer,sizeof buffer-1
		invoke SendMessage,ha.hOutput,EM_GETLINE,nLn,addr buffer
		mov		buffer[eax],0
		.if da.szError
			lea		esi,buffer
			invoke strcpy,addr tmpbuff,addr da.szError
			invoke GetItemInt,addr tmpbuff,1
			push	eax
			invoke GetItemStr,addr tmpbuff,addr szNULL,addr tmpbuff[256],256
			pop		eax
			.if !eax
				invoke iniInStr,addr buffer,addr tmpbuff[256]
				.if eax!=-1
					xor		eax,eax
				.endif
			.else
				.while eax
					push	eax
					call	GetWord
					pop		eax
					dec		eax
				.endw
				invoke strcmp,addr szWord,addr tmpbuff[256]
			.endif
			.if !eax
				lea		esi,buffer
				invoke GetItemInt,addr tmpbuff,1
				.while eax
					push	eax
					call	GetWord
					pop		eax
					dec		eax
				.endw
				invoke GetFileAttributes,addr szWord
				.if eax!=INVALID_HANDLE_VALUE
					.while (byte ptr [esi]<'0' || byte ptr [esi]>'9') && byte ptr [esi]
						inc		esi
					.endw
					invoke DecToBin,esi
					.if eax
						dec		eax
						mov		nLnErr,eax
						invoke strcpy,addr buffer,addr szWord
						call	SetError
					.endif
				.endif
			.endif
		.else
			mov		eax,da.nAsm
			.if eax==nMASM || eax==nCPP
				call	TestLineMasm
			.elseif eax==nTASM || eax==nSOLASM
				call	TestLineTasm
			.elseif eax==nFASM
				call	TestLineFasm
			.elseif eax==nGOASM
				call	TestLineGoAsm
			.elseif eax==nASEMW
				call	TestLineAsemw
			.endif
		.endif
		pop		eax
		inc		nLn
	.endw
	mov		da.ErrID[ebx*4],0
	ret

GetWord:
	lea		edi,szWord
	.while byte ptr [esi]==VK_SPACE && byte ptr [esi]
		inc		esi
	.endw
	xor		ecx,ecx
	.while byte ptr [esi]!=VK_SPACE && byte ptr [esi] && ecx<64
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
		inc		ecx
	.endw
	mov		byte ptr [edi],0
	retn

SkipWord:
	mov		edi,da.lpCharTab
	.while byte ptr [esi]==VK_SPACE && byte ptr [esi]
		inc		esi
	.endw
	.while byte ptr [esi]!=VK_SPACE && byte ptr [esi]
		movzx	eax,byte ptr [esi]
		inc		esi
	.endw
	retn

TestLineTasm:
	invoke iniInStr,addr buffer,addr szErrorTasm
	.if eax!=-1
		xor		eax,eax
		.while buffer[eax]!='(' && buffer[eax]
			inc		eax
		.endw
		mov		byte ptr buffer[eax],0
		invoke DecToBin,addr buffer[eax+1]
		dec		eax
		mov		nLnErr,eax
		invoke strlen,addr buffer
		invoke strcpy,addr buffer,addr buffer[10]
		call	SetError
	.endif
	retn

TestLineFasm:
	invoke iniInStr,addr buffer,addr szErrorFasm
	.if eax!=-1
		.while eax && buffer[eax]!='['
			dec		eax
		.endw
		mov		buffer[eax],0
		invoke DecToBin,addr buffer[eax+1]
		dec		eax
		mov		nLnErr,eax
		invoke strlen,addr buffer
		.while eax && buffer[eax-1]==' '
			dec		eax
			mov		buffer[eax],0
		.endw
		call	SetError
	.endif
	retn

TestLineGoAsm:
	invoke iniInStr,addr buffer,addr szErrorGoAsm
	.if eax!=-1
		;Get next line
		mov		word ptr buffer,sizeof buffer-1
		mov		edx,nLn
		invoke SendMessage,ha.hOutput,EM_GETLINE,addr [edx+1],addr buffer
		mov		byte ptr buffer[eax],0
		;Get the filename
		.while eax && byte ptr buffer[eax]!='('
			dec		eax
		.endw
		mov		byte ptr buffer[eax],0
		invoke strcpy,addr tmpbuff,addr buffer[eax+1]
		invoke strlen,addr tmpbuff
		.while eax && tmpbuff[eax]!=')'
			dec		eax
		.endw
		mov		tmpbuff[eax],0
		xor		eax,eax
		.while buffer[eax] && (buffer[eax]<'0' || buffer[eax]>'9')
			inc		eax
		.endw
		invoke DecToBin,addr buffer[eax]
		dec		eax
		mov		nLnErr,eax
		invoke strcpy,addr buffer,addr tmpbuff
		inc		nLn
		call	SetError
	.endif
	retn

TestLineMasm:
	invoke iniInStr,addr buffer,addr szErrorMasm
	.if eax!=-1
		.while eax && byte ptr buffer[eax]!='('
			dec		eax
		.endw
		mov		byte ptr buffer[eax],0
		invoke DecToBin,addr buffer[eax+1]
		dec		eax
		mov		nLnErr,eax
		invoke strlen,addr buffer
		.while eax && word ptr buffer[eax+1]!='\:'
			dec		eax
		.endw
		invoke strcpy,addr buffer,addr buffer[eax]
		call	SetError
	.endif
	retn

TestLineAsemw:
	invoke iniInStr,addr buffer,addr szErrorAsemw
	.if eax!=-1
		.while eax && byte ptr buffer[eax]!='('
			dec		eax
		.endw
		mov		byte ptr buffer[eax],0
		invoke DecToBin,addr buffer[eax+1]
		dec		eax
		mov		nLnErr,eax
		invoke strlen,addr buffer
		.while eax && word ptr buffer[eax+1]!='\:'
			dec		eax
		.endw
		invoke strcpy,addr buffer,addr buffer[eax]
		call	SetError
	.endif
	retn

SetError:
	invoke GetCurrentDirectory,MAX_PATH,addr tmpbuff
	invoke strcat,addr tmpbuff,addr szBS
	invoke strcat,addr tmpbuff,addr buffer
	invoke strcpy,addr buffer,addr tmpbuff
	invoke GetFileAttributes,addr buffer
	.if eax!=INVALID_HANDLE_VALUE && !(eax & FILE_ATTRIBUTE_DIRECTORY)
		invoke UpdateAll,UAM_ISOPENACTIVATE,addr buffer
		.if eax==-1
			;File is not open, open it
			invoke OpenTheFile,addr buffer,0
		.endif
		.if ha.hMdi
			invoke GetWindowLong,ha.hEdt,GWL_ID
			.if eax==ID_EDITCODE
				invoke SendMessage,ha.hOutput,REM_SETBOOKMARK,nLn,6
				invoke SendMessage,ha.hOutput,REM_LINEREDTEXT,nLn,TRUE
				invoke SendMessage,ha.hOutput,REM_GETBMID,nLn,0
				mov		nErr,eax
				invoke SendMessage,ha.hEdt,REM_GETERROR,nLnErr,0
				.if !eax
					;Create an error bookmark.
					invoke SendMessage,ha.hEdt,REM_SETERROR,nLnErr,nErr
					;Save the error id in an array
					.if ebx<255
						mov		eax,nErr
						mov		da.ErrID[ebx*4],eax
						inc		ebx
					.endif
				.else
					;Line already has an error bookmark, just update bookmark id in output window
					invoke SendMessage,ha.hOutput,REM_SETBMID,nLn,eax
				.endif
			.endif
		.endif
	.endif
	retn

FindErrors endp

Unquote proc uses esi,lpStr:DWORD

	mov		esi,lpStr
	.if byte ptr [esi]=='"'
		invoke strcpy,esi,addr [esi+1]
	.endif
	invoke strlen,esi
	.if byte ptr [esi+eax-1]=='"'
		mov		byte ptr [esi+eax-1],0
	.endif
	ret

Unquote endp

DeleteMinorFiles proc uses ebx esi edi

	.if da.fDelMinor
		;Get relative pointer to selected build command
		invoke SendMessage,ha.hCboBuild,CB_GETCURSEL,0,0
		mov		edx,sizeof MAKE
		mul		edx
		mov		esi,eax
		lea		edi,da.make.szOutAssemble[esi]
		mov		ebx,offset da.szMainAsm
		invoke iniInStr,edi,addr szDollarC
		.if eax==-1
			invoke strcpy,addr makeexe.output,edi
		.else
			push	esi
			mov		esi,eax
			invoke strcpyn,addr makeexe.output,edi,addr [esi+1]
			invoke strcat,addr makeexe.output,ebx
			invoke RemoveFileExt,addr makeexe.output
			invoke strcat,addr makeexe.output,addr [edi+esi+2]
			pop		esi
		.endif
		call	DeleteIt
		lea		edi,da.make.szOutLink[esi]
		invoke iniInStr,edi,addr szDotDll
		.if eax!=-1
			invoke iniInStr,edi,addr szDollarC
			.if eax==-1
				invoke strcpy,addr makeexe.output,edi
			.else
				push	esi
				mov		esi,eax
				invoke strcpyn,addr makeexe.output,edi,addr [esi+1]
				invoke strcat,addr makeexe.output,ebx
				pop		esi
			.endif
			invoke RemoveFileExt,addr makeexe.output
			invoke strcat,addr makeexe.output,addr szDotExp
			call	DeleteIt
			invoke RemoveFileExt,addr makeexe.output
			invoke strcat,addr makeexe.output,addr szDotLib
			call	DeleteIt
		.endif
		.if da.szMainRC
			lea		edi,da.make.szOutCompileRC[esi]
			mov		ebx,offset da.szMainRC
			invoke iniInStr,edi,addr szDollarR
			.if eax==-1
				invoke strcpy,addr makeexe.output,edi
			.else
				push	esi
				mov		esi,eax
				invoke strcpyn,addr makeexe.output,edi,addr [esi+1]
				invoke strcat,addr makeexe.output,ebx
				invoke RemoveFileExt,addr makeexe.output
				invoke strcat,addr makeexe.output,addr [edi+esi+2]
				pop		esi
			.endif
			call	DeleteIt
		.endif
		invoke strcpy,addr makeexe.output,addr szAtModDotTxt[1]
		call	DeleteIt
	.endif
	ret

DeleteIt:
	invoke Unquote,addr makeexe.output
	invoke DeleteFile,addr makeexe.output
	.if eax
		invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,offset szDeleted
		invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,offset makeexe.output
		invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,offset szCR
	.endif
	retn

DeleteMinorFiles endp

IncrementBuild proc uses edi

	.if da.fIncBuild
		invoke UpdateAll,UAM_ISRESOPEN,0
		.if eax!=-1
			invoke GetWindowLong,eax,GWL_USERDATA
			mov		edi,eax
			invoke SendMessage,edi,PRO_INCVERSION,0,0
			invoke UpdateAll,UAM_SAVEALL,0
		.endif
	.endif
	ret

IncrementBuild endp

SetOutputFile proc uses ebx esi edi,lpOut:DWORD,lpMain:DWORD

	mov		edi,lpOut
	invoke iniInStr,edi,addr szDollarC
	.if eax==-1
		invoke iniInStr,edi,addr szDollarR
		.if eax==-1
			invoke iniInStr,edi,addr szDollarA
		.endif
	.endif
	.if eax==-1
		invoke strcpy,addr makeexe.output,edi
	.else
		mov		esi,eax
		invoke strcpyn,addr makeexe.output,edi,addr [esi+1]
		invoke strcat,addr makeexe.output,lpMain
		invoke RemoveFileExt,addr makeexe.output
		invoke strcat,addr makeexe.output,addr [edi+esi+2]
	.endif
	ret

SetOutputFile endp

InsertMain proc uses esi edi,lpMain:DWORD,lpSearch:DWORD
	LOCAL	buffer[MAX_PATH*2]:BYTE

	mov		edi,offset makeexe.buffer
  Nxt:
	invoke iniInStr,edi,lpSearch
	.if eax!=-1
		mov		esi,eax
		invoke strcpyn,addr buffer,edi,addr [esi+1]
		invoke strcat,addr buffer,lpMain
		invoke strcat,addr buffer,addr [edi+esi+2]
		invoke strcpy,edi,addr buffer
		jmp		Nxt
	.endif
	ret

InsertMain endp

OutputMake proc uses ebx esi edi,nCommand:DWORD,fClear:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer2[MAX_PATH]:BYTE
	LOCAL	fExitCode:DWORD
	LOCAL	ThreadID:DWORD
	LOCAL	msg:MSG
	LOCAL	fHide:DWORD
	LOCAL	fModule:DWORD
	LOCAL	hFile:HANDLE
	LOCAL	dwWrite:DWORD

	mov		fModule,0
	invoke RtlZeroMemory,addr makeexe,sizeof MAKEEXE
	;Get relative pointer to selected build command
	invoke SendMessage,ha.hCboBuild,CB_GETCURSEL,0,0
	mov		edx,sizeof MAKE
	mul		edx
	mov		esi,eax
	invoke SetOutputTab,0
	invoke ShowOutput,TRUE
	mov		fHide,eax
	.if da.fProject
		invoke SetCurrentDirectory,addr da.szProjectPath
	.else
		invoke strcpy,addr buffer,addr da.szMainAsm
		invoke RemoveFileName,addr buffer
		invoke SetCurrentDirectory,addr buffer
	.endif
	mov		fExitCode,0
	mov		ThreadID,0
	invoke SetFocus,ha.hOutput
	.if fClear==1 || fClear==2
		invoke SendMessage,ha.hOutput,WM_SETTEXT,0,addr makeexe.buffer
		invoke SendMessage,ha.hOutput,EM_SCROLLCARET,0,0
	.endif
	mov		eax,nCommand
	.if eax==IDM_MAKE_COMPILE
		invoke strcpy,addr makeexe.buffer,addr da.szCompileRC
		invoke strcat,addr makeexe.buffer,addr szSpc
		invoke strcat,addr makeexe.buffer,addr da.make.szCompileRC[esi]
		invoke InsertMain,addr da.szMainRC,addr szDollarR
		invoke strcpy,addr buffer,addr da.szMainRC
		invoke RemoveFileExt,addr buffer
		invoke InsertMain,addr buffer,addr szDollarF
		invoke SetOutputFile,addr da.make.szOutCompileRC[esi],offset da.szMainRC
		invoke InsertMain,addr makeexe.output,addr szDollarO
		invoke InsertMain,addr da.szAppPath,addr szDollarA
		mov		eax,TRUE
		call	MakeIt
	.elseif eax==IDM_MAKE_ASSEMBLE
		invoke strcpy,addr makeexe.buffer,addr da.szAssemble
		invoke strcat,addr makeexe.buffer,addr szSpc
		invoke strcat,addr makeexe.buffer,addr da.make.szAssemble[esi]
		.if da.szMainAsm
			invoke InsertMain,addr da.szMainAsm,addr szDollarC
			invoke strcpy,addr buffer,addr da.szMainAsm
		.else
			invoke InsertMain,addr da.szFileName,addr szDollarC
			invoke strcpy,addr buffer,addr da.szFileName
		.endif
		invoke RemoveFileExt,addr buffer
		invoke InsertMain,addr buffer,addr szDollarF
		call	AddModules
		.if da.szMainRC
			invoke SetOutputFile,addr da.make.szOutCompileRC[esi],offset da.szMainRC
			invoke InsertMain,addr makeexe.output,addr szDollarR
		.else
			invoke InsertMain,addr szNULL,addr szDollarR
		.endif
		.if da.szMainAsm
			invoke SetOutputFile,addr da.make.szOutAssemble[esi],offset da.szMainAsm
		.else
			invoke SetOutputFile,addr da.make.szOutAssemble[esi],offset da.szFileName
		.endif
		invoke InsertMain,addr makeexe.output,addr szDollarO
		invoke InsertMain,addr da.szAppPath,addr szDollarA
		mov		eax,TRUE
		call	MakeIt
	.elseif eax==IDM_MAKE_MODULES
		xor		ebx,ebx
		.while TRUE
			invoke SendMessage,ha.hProjectBrowser,RPBM_FINDNEXTITEM,ebx,0
			.break .if !eax
			mov		ebx,[eax].PBITEM.id
			.if [eax].PBITEM.flag==FLAG_MODULE
				mov		edi,eax
				invoke strcpy,addr makeexe.buffer,addr da.szAssemble
				invoke strcat,addr makeexe.buffer,addr szSpc
				invoke strcat,addr makeexe.buffer,addr da.make.szAssemble[esi]
				invoke strcat,addr makeexe.buffer,addr szSpc
				invoke RemovePath,addr [edi].PBITEM.szitem,addr da.szProjectPath,addr buffer2
				invoke InsertMain,addr buffer2,addr szDollarC
				invoke strcpy,addr buffer,addr buffer2
				invoke RemoveFileExt,addr buffer
				invoke InsertMain,addr buffer,addr szDollarF
				lea		edi,buffer2
				invoke strlen,edi
				.while byte ptr [edi+eax]!='\' && eax
					dec		eax
				.endw
				.if byte ptr [edi+eax]=='\'
					lea		edi,[edi+eax+1]
				.endif
				invoke SetOutputFile,addr da.make.szOutAssemble[esi],edi
				invoke InsertMain,addr da.szAppPath,addr szDollarA
				mov		eax,TRUE
				call	MakeIt
				.break .if fExitCode
			.endif
		.endw
	.elseif eax==IDM_MAKE_LINK
		.if da.make.szLink[esi]
			invoke strcpy,addr makeexe.buffer,addr da.szLink
			invoke strcat,addr makeexe.buffer,addr szSpc
			invoke strcat,addr makeexe.buffer,addr da.make.szLink[esi]
			invoke iniInStr,addr makeexe.buffer,addr szDollarD
			.if eax!=-1
				;Add .def file
				.if da.fProject
					xor		ebx,ebx
					mov		buffer,0
					.while TRUE
						invoke SendMessage,ha.hProjectBrowser,RPBM_FINDNEXTITEM,ebx,0
						.break .if !eax
						mov		edi,eax
						mov		ebx,[edi].PBITEM.id
						invoke strlen,addr [edi].PBITEM.szitem
						.if eax>4
							mov		eax,dword ptr [edi].PBITEM.szitem[eax-4]
							and		eax,5F5F5FFFh
							.if eax=='FED.'
								invoke strcpy,addr buffer,addr [edi].PBITEM.szitem
								invoke RemovePath,addr [edi].PBITEM.szitem,addr da.szProjectPath,addr buffer
								.break
							.endif
						.endif
					.endw
				.else
					invoke strcpy,addr buffer,addr da.szMainAsm
					invoke RemoveFileExt,addr buffer
					invoke strcat,addr buffer,addr szDotDef
				.endif
				invoke InsertMain,addr buffer,addr szDollarD
			.endif
			.if da.szMainAsm
				invoke SetOutputFile,addr da.make.szOutAssemble[esi],offset da.szMainAsm
				invoke InsertMain,addr makeexe.output,addr szDollarC
			.else
				invoke InsertMain,addr szNULL,addr szDollarC
			.endif
			call	AddModules
			.if da.szMainRC
				invoke SetOutputFile,addr da.make.szOutCompileRC[esi],offset da.szMainRC
				invoke InsertMain,addr makeexe.output,addr szDollarR
			.else
				invoke InsertMain,addr szNULL,addr szDollarR
			.endif
			.if da.szMainAsm
				invoke SetOutputFile,addr da.make.szOutLink[esi],offset da.szMainAsm
			.else
				invoke SetOutputFile,addr da.make.szOutLink[esi],offset da.szProjectFile
			.endif
			invoke InsertMain,addr makeexe.output,addr szDollarO
			invoke InsertMain,addr da.szAppPath,addr szDollarA
			mov		eax,TRUE
			call	MakeIt
		.elseif da.make.szLib[esi]
			invoke strcpy,addr makeexe.buffer,addr da.szLib
			invoke strcat,addr makeexe.buffer,addr szSpc
			invoke strcat,addr makeexe.buffer,addr da.make.szLib[esi]
			invoke iniInStr,addr makeexe.buffer,addr szDollarC
			.if eax!=-1
				.if da.szMainAsm
					invoke SetOutputFile,addr da.make.szOutAssemble[esi],offset da.szMainAsm
					invoke InsertMain,addr makeexe.output,addr szDollarC
				.else
					invoke InsertMain,addr szNULL,addr szDollarC
				.endif
			.endif
			.if da.fProject
				invoke iniInStr,addr makeexe.buffer,addr szDollarM
				.if eax!=-1
					;Add modules
					mov		tmpbuff,0
					xor		ebx,ebx
					.while TRUE
						invoke SendMessage,ha.hProjectBrowser,RPBM_FINDNEXTITEM,ebx,0
						.break .if !eax
						mov		ebx,[eax].PBITEM.id
						.if [eax].PBITEM.flag==FLAG_MODULE
							push	ebx
							mov		edi,eax
							.if tmpbuff
								invoke strcat,addr tmpbuff,addr szSpc
							.endif
							invoke strlen,addr [edi].PBITEM.szitem
							.while [edi].PBITEM.szitem[eax]!='\' && eax
								dec		eax
							.endw
							.if [edi].PBITEM.szitem[eax]=='\'
								inc		eax
							.endif
							invoke SetOutputFile,addr da.make.szOutAssemble[esi],addr [edi].PBITEM.szitem[eax]
							invoke strcat,addr tmpbuff,addr makeexe.output
							pop		ebx
						.endif
					.endw
					.if tmpbuff
						invoke CreateFile,addr szAtModDotTxt[1],GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
						mov		hFile,eax
						invoke strlen,addr tmpbuff
						mov		edx,eax
						invoke WriteFile,hFile,addr tmpbuff,edx,addr dwWrite,NULL
						invoke CloseHandle,hFile
						invoke InsertMain,addr szAtModDotTxt,addr szDollarM
					.else
						invoke InsertMain,addr szNULL,addr szDollarM
					.endif
				.endif
			.endif
			.if da.szMainAsm
				invoke SetOutputFile,addr da.make.szOutLib[esi],offset da.szMainAsm
			.else
				invoke SetOutputFile,addr da.make.szOutLib[esi],offset da.szProjectFile
			.endif
			invoke InsertMain,addr makeexe.output,addr szDollarO
			invoke InsertMain,addr da.szAppPath,addr szDollarA
			mov		eax,TRUE
			call	MakeIt
		.endif
	.elseif eax==IDM_MAKE_RUN
		invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,offset Exec
		.if da.fCmdExe
			invoke strcpy,addr makeexe.cmd,addr da.szCmdExe
			invoke strcat,addr makeexe.cmd,addr szSpc
			xor		eax,eax
			.while makeexe.cmd[eax]!=' '
				inc		eax
			.endw
			mov		makeexe.cmd[eax],0
			invoke strcat,addr makeexe.cmdline,addr makeexe.cmd[eax+1]
			invoke SetOutputFile,addr da.make.szOutLink[esi],offset da.szMainAsm
			invoke strcat,addr makeexe.cmdline,addr makeexe.output
			.if da.szCommandLine
				invoke strcat,addr makeexe.cmdline,addr szSpc
				invoke strcat,addr makeexe.cmdline,addr da.szCommandLine
			.endif
		.else
			invoke iniInStr,addr da.make.szOutLink[edi],addr szDotExe
			inc		eax
			.if eax
				invoke SetOutputFile,addr da.make.szOutLink[esi],offset da.szMainAsm
				invoke strcpy,addr makeexe.cmd,addr makeexe.output
				.if da.szCommandLine
					invoke strcpy,addr makeexe.cmdline,addr da.szCommandLine
				.endif
			.elseif da.szCommandLine
				mov		makeexe.cmdline,0
				invoke strcpy,addr makeexe.cmdline,addr da.szCommandLine
			.endif
		.endif
		xor		eax,eax
		call	MakeIt
	.elseif eax==IDM_MAKE_DEBUG
		invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,offset Debug
		invoke SetOutputFile,addr da.make.szOutLink[esi],offset da.szMainAsm
		invoke strcpy,addr makeexe.cmd,addr makeexe.output
		.if da.szCommandLine
			invoke strcpy,addr makeexe.cmdline,addr da.szCommandLine
		.endif
		invoke strcpy,addr makeexe.buffer,addr makeexe.cmd
		.if makeexe.cmdline
			invoke strcat,addr makeexe.buffer,addr szSpc
			invoke strcat,addr makeexe.buffer,addr makeexe.cmdline
		.endif
		xor		eax,eax
		call	MakeIt
	.else
		jmp		Ex
	.endif
	invoke LoadCursor,0,IDC_ARROW
	invoke SetCursor,eax
	.if ThreadID
		.if makeexe.uExit==1234
			invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,offset Terminated
			.if nCommand==IDM_MAKE_ASSEMBLE
				invoke FindErrors
			.endif
		.else
			.if fExitCode
				invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,offset Errors
				.if nCommand==IDM_MAKE_ASSEMBLE
					invoke FindErrors
				.endif
			.else
				.if fClear==1 || fClear==3
					.if fClear==3
						invoke DeleteMinorFiles
						invoke IncrementBuild
					.endif
					invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,offset MakeDone
				.endif
			.endif
		.endif
		.if dword ptr da.ErrID
			invoke SendMessage,ha.hWnd,WM_COMMAND,IDM_EDIT_NEXTERROR,0
		.else
			invoke SendMessage,ha.hOutput,EM_SCROLLCARET,0,0
			invoke SetFocus,ha.hOutput
		.endif
	.endif
  Ex:
	.if !fExitCode
		.if fHide
			invoke ShowOutput,FALSE
		.endif
		.if ha.hMdi
			invoke SetFocus,ha.hEdt
		.endif
	.endif
	mov		eax,fExitCode
	ret

MakeIt:
	mov		fExitCode,0
	push	eax
	invoke RTrim,addr makeexe.buffer
	invoke Unquote,addr makeexe.output
	pop		eax
	.if eax
		;Delete old file
		invoke GetFileAttributes,addr makeexe.output
		.if eax!=INVALID_HANDLE_VALUE
			invoke DeleteFile,addr makeexe.output
			.if !eax
				mov		fExitCode,-1
				invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,offset NoDel
				invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,addr makeexe.output
				invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,offset szCR
				invoke SendMessage,ha.hOutput,EM_REPLACESEL,FALSE,offset Errors
				jmp		Ex
			.endif
		.endif
	.endif
	invoke CreateThread,NULL,NULL,addr MakeThreadProc,nCommand,NORMAL_PRIORITY_CLASS,addr ThreadID
	mov		makeexe.hThread,eax
	.while TRUE
		invoke GetExitCodeThread,makeexe.hThread,addr ThreadID
		.break .if ThreadID!=STILL_ACTIVE
		invoke GetMessage,addr msg,NULL,0,0
		mov		eax,msg.message
		.if eax!=WM_CHAR
			.if msg.wParam==VK_ESCAPE
				invoke TerminateProcess,makeexe.pInfo.hProcess,1234
				mov		fExitCode,-1
			.endif
		.elseif eax!=WM_KEYDOWN && eax!=WM_CLOSE && (eax<WM_MOUSEFIRST || eax>WM_MOUSELAST)
			invoke TranslateMessage,addr msg
			invoke DispatchMessage,addr msg
		.endif
		invoke LoadCursor,0,IDC_WAIT
		invoke SetCursor,eax
	.endw
	invoke CloseHandle,makeexe.hThread
	.if da.nAsm==nASEMW
		mov		eax,makeexe.uExit
		mov		fExitCode,eax
	.else
		;Check if output file exists
		invoke GetFileAttributes,addr makeexe.output
		.if eax==INVALID_HANDLE_VALUE
			mov		fExitCode,eax
		.endif
	.endif
	retn

AddModules:
	.if da.fProject
		invoke iniInStr,addr makeexe.buffer,addr szDollarM
		.if eax!=-1
			;Add modules
			mov		tmpbuff,0
			xor		ebx,ebx
			.while TRUE
				invoke SendMessage,ha.hProjectBrowser,RPBM_FINDNEXTITEM,ebx,0
				.break .if !eax
				mov		ebx,[eax].PBITEM.id
				.if [eax].PBITEM.flag==FLAG_MODULE
					push	ebx
					mov		edi,eax
					.if tmpbuff
						invoke strcat,addr tmpbuff,addr szSpc
					.endif
					invoke strlen,addr [edi].PBITEM.szitem
					.while [edi].PBITEM.szitem[eax]!='\' && eax
						dec		eax
					.endw
					.if [edi].PBITEM.szitem[eax]=='\'
						inc		eax
					.endif
					invoke SetOutputFile,addr da.make.szOutAssemble[esi],addr [edi].PBITEM.szitem[eax]
					invoke strcat,addr tmpbuff,addr makeexe.output
					pop		ebx
				.endif
			.endw
			.if tmpbuff
				invoke CreateFile,addr szAtModDotTxt[1],GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
				mov		hFile,eax
				invoke strlen,addr tmpbuff
				mov		edx,eax
				invoke WriteFile,hFile,addr tmpbuff,edx,addr dwWrite,NULL
				invoke CloseHandle,hFile
				invoke InsertMain,addr szAtModDotTxt,addr szDollarM
			.else
				invoke InsertMain,addr szNULL,addr szDollarM
			.endif
		.endif
	.endif
	retn

OutputMake endp

