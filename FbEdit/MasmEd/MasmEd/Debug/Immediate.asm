
.const

; Commands
szImmHelp						db 'Help',0
szImmDump						db 'Dump',0
szImmMemdump					db 'Memdump',0
szImmVars						db 'Vars',0
szImmProcs						db 'Procs',0
szImmTypes						db 'Types',0
szImmCls						db 'Cls',0
szImmWatch						db 'Watch',0
szImmLines						db 'Lines',0

szImmLocal						db 0Dh,'LOCAL: ',0

szHelp							db 'Immediate window:',0Dh
								db '-----------------------------------------------------------------------------',0Dh
								db 'NOTE!',0Dh
								db 'Commands ,registers, hex values and predefined datatypes are case insensitive.',0Dh
								db 'Variables, datatypes and constants are case sensitive.',0Dh
								db 'To inspect or change a proc parameter or local variable the variable must',0Dh
								db 'be in the current scope.',0Dh
								db 0Dh
								db 'o Simple integer math.',0Dh
								db '  - Functions: +, -, *, /, SHL, SHR, AND, OR, XOR, ADDR() and SIZEOF()',0Dh
								db '  - An expression can contain any register, variable, datatype or constant.',0Dh
								db '  - Example: ?((((eax+1) SHL 2)*4) AND 0FFFFh)+MAX_PATH',0Dh
								db '  - Example: Memdump Addr(MyArray),Sizeof(MyArray),DWORD',0Dh
								db 'o Inspect variable, register, datatype, constant or a hex / dec value.',0Dh
 								db '  - ?MyVar to show info about a variable local or parameter.',0Dh
								db '  - ?MyVar(inx) to show an array element. Index is zero based.',0Dh
								db '    (inx) can be any expression.',0Dh
								db '  - ?Z:MyZString to show a ZString. Use Z:MyZString(inx) to start',0Dh
								db '    at an offset. (inx) can be any expression.',0Dh
								db '  - ?reg To show a register (reg: eax, ebx ...).',0Dh
								db '  - ?123 or ?0A5Fh to convert a number to hex and decimal.',0Dh
								db 'o Change variable or register.',0Dh
								db '  - MyVar=ebx+2 to change the variable MyVar.',0Dh
								db '  - reg=4AB0h to change a register (reg: eax, ebx ...).',0Dh
								db 'o Commands.',0Dh
								db '  - Help, or /H or /?',0Dh
								db '    Shows the help screen.',0Dh
								db '  - Dump',0Dh
								db '    Shows a hex dump of the exe.',0Dh
								db '  - Dump MyStruct[,Size]',0Dh
								db '    Shows a hex dump of an array, structure or union.',0Dh
								db '    Size is optional and can be BYTE, WORD, DWORD or QWORD.',0Dh
								db '  - Memdump Address,Count[,Size]',0Dh
								db '    Shows a memory dump. Address and Count can be any expression.',0Dh
								db '    Size is optional and can be BYTE, WORD, DWORD or QWORD.',0Dh
								db '  - Vars',0Dh
								db '    Shows a list of all global variables.',0Dh
								db '  - Procs',0Dh
								db '    Shows a list of all procs.',0Dh
								db '  - Types',0Dh
								db '    Show a list of all datatypes and constants.',0Dh
								db '  - Lines',0Dh
								db '    Show a list of all lines that produces code.',0Dh
								db '  - Watch var1,Z:MyZStr,....,var8',0Dh
								db '    Adds a watch to specified variables.',0Dh
								db '    To clear the watch list, type Watch without any variable list.',0Dh
								db '  - Cls',0Dh
								db '    Clears the immediate window.',0

.code

ParseBuff proc uses esi edi,lpBuff:DWORD

	mov		esi,lpBuff
	mov		edi,esi
	.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
		inc		esi
	.endw
	.while TRUE
		mov		al,[esi]
		mov		[edi],al
		inc		edi
		.break .if !al
		inc		esi
	.endw
	ret

ParseBuff endp

ParseWatch proc uses ebx esi edi,lpList:DWORD

	mov		edi,offset szWatchList
	invoke RtlZeroMemory,edi,sizeof szWatchList
	xor		edx,edx
	mov		esi,lpList
	.while byte ptr [esi] && edx<8
		call	AddWatchVar
	.endw
	ret

AddWatchVar:
	xor		ecx,ecx
	.while byte ptr [esi] && byte ptr [esi]!=','
		mov		al,[esi]
		mov		[edi],al
		inc		ecx
		inc		edi
		inc		esi
	.endw
	.if byte ptr [esi]==','
		inc		esi
	.endif
	.if ecx
		inc		edi
	.endif
	retn

ParseWatch endp

Immediate proc uses ebx esi edi,hWin:HWND
	LOCAL	chrg:CHARRANGE
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	val:DWORD
	LOCAL	tmpvar:VAR

	mov		var.IsSZ,0
	invoke RtlZeroMemory,addr buffer,sizeof buffer
	invoke RtlZeroMemory,addr buffer1,sizeof buffer1
	invoke RtlZeroMemory,addr tmpvar,sizeof VAR
	mov		val,0
	invoke SendMessage,hWin,EM_EXGETSEL,0,addr chrg
	invoke SendMessage,hWin,EM_LINEFROMCHAR,chrg.cpMin,0
	mov		ebx,eax
	mov		word ptr buffer,255
	invoke SendMessage,hWin,EM_GETLINE,ebx,addr buffer
	mov		buffer[eax],0
	push	eax
	invoke SendMessage,hWin,EM_LINEINDEX,ebx,0
	mov		chrg.cpMin,eax
	pop		edx
	lea		eax,[eax+edx+1]
	mov		chrg.cpMax,eax
	invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
	invoke SendMessage,hWin,EM_REPLACESEL,FALSE,addr szNULL
	invoke PutString,addr buffer,hWin,FALSE
	invoke ParseBuff,addr buffer
	mov		eax,dword ptr buffer
	and		eax,0FFFFFFh
	.if eax=='H/' || eax=='h/' || eax=='?/'
		; Help
		invoke PutString,addr szHelp,hWin,FALSE
		jmp		Ex
	.endif
	invoke strcmpi,addr buffer,addr szImmHelp
	.if !eax
		; Help
		invoke PutString,addr szHelp,hWin,FALSE
		jmp		Ex
	.endif
	invoke strcmpi,addr buffer,addr szImmDump
	.if !eax
		; Dump
		.if dbg.hDbgThread
			invoke ClearBreakPointsAll
			mov		esi,400000h
			.while TRUE
				invoke ReadProcessMemory,dbg.hdbghand,esi,addr buffer,16,NULL
				.break .if !eax
				invoke DumpLineBYTE,hWin,esi,addr buffer,16
				add		esi,16
			.endw
			invoke SetBreakPointsAll
		.else
			invoke PutString,addr szOnlyInDebugMode,hWin,TRUE
		.endif
		jmp		Ex
	.endif
	invoke strcmpin,addr buffer,addr szImmDump,4
	.if !eax
		; Dump var[,Size]
		.if dbg.hDbgThread
			lea		esi,buffer[4]
			.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
				inc		esi
			.endw
			xor		ebx,ebx
			push	esi
			.while byte ptr [esi]
				.if byte ptr [esi]==','
					.if !ebx
						lea		ebx,[esi+1]
						mov		byte ptr [esi],0
					.endif
				.endif
				inc		esi
			.endw
			pop		esi
			invoke GetVarAdr,esi,dbg.prevline
			.if eax
				mov		eax,var.nSize
				mov		edx,var.nArray
				sub		edx,var.nInx
				mul		edx
				mov		edi,eax
				mov		esi,var.Address
				.if ebx
					invoke DoMath,ebx
					.if eax
						mov		ebx,var.Value
					.else
						mov		ebx,1
					.endif
				.else
					mov		ebx,1
				.endif
				.while edi>=16
					invoke ReadProcessMemory,dbg.hdbghand,esi,addr buffer,16,NULL
					.if eax
						.if ebx==1
							invoke DumpLineBYTE,hWin,esi,addr buffer,16
						.elseif ebx==2
							invoke DumpLineWORD,hWin,esi,addr buffer,16
						.elseif ebx==4
							invoke DumpLineDWORD,hWin,esi,addr buffer,16
						.elseif ebx==8
							invoke DumpLineQWORD,hWin,esi,addr buffer,16
						.endif
					.endif
					sub		edi,16
					add		esi,16
				.endw
				.if edi
					invoke ReadProcessMemory,dbg.hdbghand,esi,addr buffer,edi,NULL
					.if eax
						.if ebx==1
							invoke DumpLineBYTE,hWin,esi,addr buffer,edi
						.elseif ebx==2
							invoke DumpLineWORD,hWin,esi,addr buffer,edi
						.elseif ebx==4
							invoke DumpLineDWORD,hWin,esi,addr buffer,edi
						.elseif ebx==8
							invoke DumpLineQWORD,hWin,esi,addr buffer,edi
						.endif
					.endif
				.endif
			.else
				.if var.nErr==ERR_INDEX
					invoke wsprintf,offset outbuffer,addr szErrIndexOutOfRange,esi
				.else
					invoke wsprintf,addr outbuffer,addr szErrVariableNotFound,esi
				.endif
				invoke PutString,addr outbuffer,hWin,TRUE
			.endif
		.else
			invoke PutString,addr szOnlyInDebugMode,hWin,TRUE
		.endif
		jmp		Ex
	.endif
	invoke strcmpin,addr buffer,addr szImmMemdump,7
	.if !eax
		; Memdump Address,Count[,Size]
		.if dbg.hDbgThread
			xor		edi,edi
			xor		ebx,ebx
			lea		esi,buffer[7]
			.while byte ptr [esi]
				.if byte ptr [esi]==','
					.if !edi
						lea		edi,[esi+1]
						mov		byte ptr [esi],0
					.elseif !ebx
						lea		ebx,[esi+1]
						mov		byte ptr [esi],0
					.endif
				.endif
				inc		esi
			.endw
			.if edi
				invoke DoMath,addr buffer[7]
				.if eax
					mov		esi,var.Value
					invoke DoMath,edi
					.if eax
						mov		edi,var.Value
						.if ebx
							invoke DoMath,ebx
							.if eax
								mov		ebx,var.Value
							.else
								mov		ebx,1
							.endif
						.else
							mov		ebx,1
						.endif
						.while edi
							.if edi>=16
								invoke ReadProcessMemory,dbg.hdbghand,esi,addr buffer,16,NULL
								.break .if !eax
								.if ebx==1
									invoke DumpLineBYTE,hWin,esi,addr buffer,16
								.elseif ebx==2
									invoke DumpLineWORD,hWin,esi,addr buffer,16
								.elseif ebx==4
									invoke DumpLineDWORD,hWin,esi,addr buffer,16
								.elseif ebx==8
									invoke DumpLineQWORD,hWin,esi,addr buffer,16
								.endif
								add		esi,16
								sub		edi,16
							.else
								invoke ReadProcessMemory,dbg.hdbghand,esi,addr buffer,edi,NULL
								.break .if !eax
								.if ebx==1
									invoke DumpLineBYTE,hWin,esi,addr buffer,edi
								.elseif ebx==2
									invoke DumpLineWORD,hWin,esi,addr buffer,edi
								.elseif ebx==4
									invoke DumpLineDWORD,hWin,esi,addr buffer,edi
								.elseif ebx==8
									invoke DumpLineQWORD,hWin,esi,addr buffer,edi
								.endif
								.break
							.endif
						.endw
						xor		ebx,ebx
					.else
						mov		ebx,TRUE
					.endif
				.else
					mov		ebx,TRUE
				.endif
			.else
				invoke wsprintf,offset outbuffer,addr szErrSyntaxError,addr szError
				mov		ebx,TRUE
			.endif
			.if ebx
				invoke PutString,addr outbuffer,hWin,TRUE
			.endif
		.else
			invoke PutString,addr szOnlyInDebugMode,hWin,TRUE
		.endif
		jmp		Ex
	.endif
	invoke strcmpi,addr buffer,addr szImmTypes
	.if !eax
		; Types
		.if dbg.hDbgThread
			mov		esi,dbg.hMemType
			xor		ebx,ebx
			.while ebx<dbg.inxtype
				invoke wsprintf,addr outbuffer,addr szType,addr [esi].DEBUGTYPE.szName,[esi].DEBUGTYPE.nSize
				invoke PutString,addr outbuffer,hWin,FALSE
				lea		esi,[esi+sizeof DEBUGTYPE]
				inc		ebx
			.endw
		.else
			invoke PutString,addr szOnlyInDebugMode,hWin,TRUE
		.endif
		jmp		Ex
	.endif
	invoke strcmpi,addr buffer,addr szImmVars
	.if !eax
		; Vars
		.if dbg.hDbgThread
			mov		esi,dbg.hMemSymbol
			mov		ecx,dbg.inxsymbol
			.while ecx
				push	ecx
				.if [esi].DEBUGSYMBOL.nType=='d'
					mov		edi,[esi].DEBUGSYMBOL.lpType
					.if edi
						invoke strcpy,addr outbuffer,addr [edi+sizeof DEBUGVAR]
						invoke strlen,addr [edi+sizeof DEBUGVAR]
						invoke strcat,addr outbuffer,addr [edi+eax+1+sizeof DEBUGVAR]
						invoke PutString,addr outbuffer,hWin,FALSE
					.endif
				.endif
				pop		ecx
				lea		esi,[esi+sizeof DEBUGSYMBOL]
				dec		ecx
			.endw
		.else
			invoke PutString,addr szOnlyInDebugMode,hWin,TRUE
		.endif
		jmp		Ex
	.endif
	invoke strcmpi,addr buffer,addr szImmProcs
	.if !eax
		; Procs
		.if dbg.hDbgThread
			mov		esi,dbg.hMemSymbol
			mov		ecx,dbg.inxsymbol
			.while ecx
				push	ecx
				.if [esi].DEBUGSYMBOL.nType=='p'
					invoke strcpy,addr outbuffer,addr [esi].DEBUGSYMBOL.szName
					mov		edi,[esi].DEBUGSYMBOL.lpType
					.if edi
						mov		ebx,offset szSpace
						lea		edi,[edi+sizeof DEBUGVAR]
						.while byte ptr [edi]
							invoke strcat,addr outbuffer,ebx
							invoke strcat,addr outbuffer,edi
							invoke strlen,edi
							lea		edi,[edi+eax+1]
							invoke strcat,addr outbuffer,edi
							invoke strlen,edi
							lea		edi,[edi+eax+1]
							lea		edi,[edi+sizeof DEBUGVAR]
							mov		ebx,offset szComma
						.endw
						mov		ebx,offset szImmLocal
						lea		edi,[edi+sizeof DEBUGVAR+2]
						.while byte ptr [edi]
							invoke strcat,addr outbuffer,ebx
							invoke strcat,addr outbuffer,edi
							invoke strlen,edi
							lea		edi,[edi+eax+1]
							invoke strcat,addr outbuffer,edi
							invoke strlen,edi
							lea		edi,[edi+eax+1]
							lea		edi,[edi+sizeof DEBUGVAR]
							mov		ebx,offset szComma
						.endw
					.endif
					invoke PutString,addr outbuffer,hWin,FALSE
				.endif
				pop		ecx
				lea		esi,[esi+sizeof DEBUGSYMBOL]
				dec		ecx
			.endw
		.else
			invoke PutString,addr szOnlyInDebugMode,hWin,TRUE
		.endif
		jmp		Ex
	.endif
	invoke strcmpi,addr buffer,addr szImmLines
	.if !eax
		; Lines
		.if dbg.hDbgThread
			mov		esi,dbg.hMemLine
			xor		ebx,ebx
			.while ebx<dbg.inxline
				movzx	eax,[esi].DEBUGLINE.FileID
				mov		edx,sizeof DEBUGSOURCE
				mul		edx
				add		eax,dbg.hMemSource
				invoke wsprintf,addr outbuffer,addr szLine,addr [eax].DEBUGSOURCE.FileName,[esi].DEBUGLINE.LineNumber,[esi].DEBUGLINE.Address
				invoke PutString,addr outbuffer,hWin,FALSE
				lea		esi,[esi+sizeof DEBUGLINE]
				inc		ebx
			.endw
		.else
			invoke PutString,addr szOnlyInDebugMode,hWin,TRUE
		.endif
		jmp		Ex
	.endif
	invoke strcmpi,addr buffer,addr szImmCls
	.if !eax
		; Cls
		invoke SetWindowText,hWin,addr szNULL
		jmp		Ex
	.endif
	invoke strcmpin,addr buffer,addr szImmWatch,5
	.if !eax
		; Watch Var1[,Var2,....,Var8]
		invoke ParseWatch,addr buffer[5]
		.if szWatchList
			invoke WatchVars
		.endif
		jmp		Ex
	.endif
	.if buffer=='?'
		; ?
		movzx	eax,word ptr buffer[1]
		.if eax==':z' || eax==':Z'
			mov		var.IsSZ,1
			invoke GetVarVal,addr buffer[3],dbg.prevline,TRUE
			mov		eax,var.nErr
			mov		nError,eax
		.else
			invoke DoMath,addr buffer[1]
			.if !nError
				.if mFunc=='H'
					invoke wsprintf,offset outbuffer,addr szValue,var.Value,var.Value
				.else
					invoke FormatOutput,addr outbuffer
				.endif
			.endif
		.endif
		call	Error
		invoke PutString,addr outbuffer,hWin,eax
		jmp		Ex
	.endif
	xor ebx,ebx
	.while buffer[ebx]
		.if buffer[ebx]=='='
			; var=reg
			mov		buffer[ebx],0
			inc		ebx
			invoke strcpy,addr buffer1,addr buffer
			invoke GetVarAdr,addr buffer,dbg.prevline
			.if eax
				push	eax
				invoke RtlMoveMemory,addr tmpvar,addr var,sizeof VAR
				invoke DoMath,addr buffer[ebx]
				.if eax
					mov		eax,var.Value
					mov		val,eax
					invoke RtlMoveMemory,addr var,addr tmpvar,sizeof VAR
				.else
					pop		eax
					mov		eax,nError
					push	eax
					.if eax==1
						invoke wsprintf,offset outbuffer,addr szErrSyntaxError,addr szError
					.elseif eax==2
						invoke wsprintf,offset outbuffer,addr szErrVariableNotFound,addr szError
					.endif
					pop		eax
					invoke PutString,addr outbuffer,hWin,eax
					jmp		Ex
				.endif
				pop		eax
			.endif
			.if (eax=='d' || eax=='P' || eax=='L')
				; GLOBAL, PROC Parameter or LOCAL
				invoke WriteProcessMemory,dbg.hdbghand,var.Address,addr val,var.nSize,0
				invoke GetVarVal,addr buffer1,dbg.prevline,TRUE
				invoke PutString,addr outbuffer,hWin,FALSE
			.elseif eax=='R'
				; REGISTER
				mov		eax,var.Address
				mov		eax,[eax]
				mov		edx,var.nSize
				.if edx==2
					mov		ax,word ptr val
				.elseif edx==1
					mov		al,byte ptr val
				.elseif edx==3
					mov		ah,byte ptr val
				.else
					mov		eax,val
				.endif
				mov		edx,var.Address
				mov		[edx],eax
				mov		ebx,dbg.lpthread
				invoke SetThreadContext,[ebx].DEBUGTHREAD.htread,addr dbg.context
				invoke ShowRegContext
				invoke ShowFpuContext
				invoke ShowMMXContext
				invoke RtlMoveMemory,addr dbg.prevcontext,addr dbg.context,sizeof CONTEXT
				invoke GetVarVal,addr buffer1,dbg.prevline,TRUE
				invoke PutString,addr outbuffer,hWin,FALSE
			.else
				.if var.nErr==ERR_INDEX
					invoke wsprintf,addr outbuffer,addr szErrIndexOutOfRange,addr buffer
				.else
					invoke wsprintf,addr outbuffer,addr szErrVariableNotFound,addr buffer
				.endif
				invoke PutString,addr outbuffer,hWin,TRUE
			.endif
			jmp		Ex
		.endif
		inc		ebx
	.endw
	.if buffer
		invoke PutString,addr szErrUnknownCommand,hWin,TRUE
	.endif
  Ex:
	ret

Error:
	mov		eax,nError
	push	eax
	.if eax==ERR_SYNTAX
		invoke wsprintf,offset outbuffer,addr szErrSyntaxError,addr szError
	.elseif eax==ERR_NOTFOUND
		invoke wsprintf,offset outbuffer,addr szErrVariableNotFound,addr szError
	.elseif eax==ERR_INDEX
		invoke wsprintf,offset outbuffer,addr szErrIndexOutOfRange,addr szError
	.elseif eax==ERR_DIV0
		invoke strcpy,offset outbuffer,addr szErrDiv0
	.elseif eax==ERR_OVERFLOW
		invoke strcpy,offset outbuffer,addr szErrOverflow
	.endif
	pop		eax
	retn

Immediate endp
