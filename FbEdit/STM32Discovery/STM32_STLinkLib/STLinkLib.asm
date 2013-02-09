.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include STLinkLib.inc

.code

;########################################################################

LoadSTLinkUSBDriver proc hWin:HWND

	invoke LoadLibrary,addr szSTLinkUSBDriverDll
	.if eax
		mov		STLink.hModule,eax
		invoke GetProcAddress,STLink.hModule,addr szSTMass_Enum_Reenumerate
		or		eax,eax
		jz		ExErr
		mov		STLink.lpSTMass_Enum_Reenumerate,eax
		invoke GetProcAddress,STLink.hModule,addr szSTMass_Enum_GetNbDevices
		or		eax,eax
		jz		ExErr
		mov		STLink.lpSTMass_Enum_GetNbDevices,eax
		invoke GetProcAddress,STLink.hModule,addr szSTMass_Enum_GetDevice
		or		eax,eax
		jz		ExErr
		mov		STLink.lpSTMass_Enum_GetDevice,eax
		invoke GetProcAddress,STLink.hModule,addr szSTMass_GetDeviceInfo
		or		eax,eax
		jz		ExErr
		mov		STLink.lpSTMass_GetDeviceInfo,eax
		invoke GetProcAddress,STLink.hModule,addr szSTMass_OpenDevice
		or		eax,eax
		jz		ExErr
		mov		STLink.lpSTMass_OpenDevice,eax
		invoke GetProcAddress,STLink.hModule,addr szSTMass_CloseDevice
		or		eax,eax
		jz		ExErr
		mov		STLink.lpSTMass_CloseDevice,eax
		invoke GetProcAddress,STLink.hModule,addr szSTMass_SendCommand
		or		eax,eax
		jz		ExErr
		mov		STLink.lpSTMass_SendCommand,eax
		mov		eax,TRUE
	.else
		invoke MessageBox,hWin,addr szErrLoadDll,addr szError,MB_OK or MB_ICONERROR
		xor		eax,eax
	.endif
	ret

ExErr:
	invoke MessageBox,hWin,addr szErrProcAddress,addr szError,MB_OK or MB_ICONERROR
	invoke FreeLibrary,STLink.hModule
	xor		eax,eax
	mov		STLink.hModule,eax
	ret

LoadSTLinkUSBDriver endp

SendCommend proc cmnd:DWORD,subcmnd:DWORD,rdadr:DWORD,rdbytes:DWORD,wradr:DWORD,y:DWORD

	;Setup command
	invoke RtlZeroMemory,addr STLinkCmnd,sizeof STLinkCmnd
	mov		STLinkCmnd.cmd0,0Ah
	mov		eax,cmnd
	mov		STLinkCmnd.cmd1,al
	mov		eax,subcmnd
	mov		STLinkCmnd.cmd2,al
	mov		eax,rdadr
	mov		STLinkCmnd.rdadr,eax
	mov		eax,rdbytes
	mov		STLinkCmnd.rdbytes,eax
	.if !(cmnd==0F2h && (subcmnd==0Dh || subcmnd==08h))
		mov		STLinkCmnd.x,0100h
	.endif
	mov		eax,wradr
	mov		STLinkCmnd.wradr,eax
	mov		eax,y
	mov		STLinkCmnd.y,eax
	mov		STLinkCmnd.z,0Eh
	push	1388h
	push	offset STLinkCmnd
	push	STLink.hFile
	push	STLink.hDevice
	call	STLink.lpSTMass_SendCommand
	ret

SendCommend endp

STLinkConnect proc hWin:HWND

  Retry:
	.if !STLink.hModule
		invoke LoadSTLinkUSBDriver,hWin
	.endif
	.if STLink.hModule
		call STLink.lpSTMass_Enum_Reenumerate
		call STLink.lpSTMass_Enum_GetNbDevices
		or		eax,eax
		jz		ExErr
		push	offset STLink.hDevice
		push	0
		call STLink.lpSTMass_Enum_GetDevice
		or		eax,eax
		jz		ExErr
		push	offset STLink.hFile
		push	STLink.hDevice
		call STLink.lpSTMass_OpenDevice
		or		eax,eax
		jz		ExErr
		invoke SendCommend,0F5h,000h,000000000h,0000h,offset STLink.buff2,02h
		cmp		eax,1
		jnz		ExErr
		movzx	eax,word ptr STLink.buff2
		.if !eax
			invoke SendCommend,0F3h,007h,000000000h,0000h,offset STLink.buff2,00h
			cmp		eax,1
			jnz		ExErr
		.endif
		invoke SendCommend,0F2h,030h,0000000A3h,0000h,offset STLink.buff2,02h
		cmp		eax,1
		jnz		ExErr
	.endif
	ret

ExErr:
	invoke MessageBox,hWin,addr szErrNotConnected,addr szError,MB_ABORTRETRYIGNORE or MB_ICONERROR
	push	eax
	.if STLink.hDevice
		push	STLink.hFile
		push	STLink.hDevice
		call	STLink.lpSTMass_CloseDevice
	.endif
	.if STLink.hModule
		invoke FreeLibrary,STLink.hModule
	.endif
	xor		eax,eax
	mov		STLink.hFile,eax
	mov		STLink.hDevice,eax
	mov		STLink.hModule,eax
	pop		eax
	.if eax==IDRETRY
		jmp		Retry
	.endif
	ret

STLinkConnect endp

STLinkDisconnect proc

	.if STLink.hDevice
		push	STLink.hFile
		push	STLink.hDevice
		call	STLink.lpSTMass_CloseDevice
		mov		STLink.hFile,0
		mov		STLink.hDevice,0
	.endif
	.if STLink.hModule
		invoke FreeLibrary,STLink.hModule
		mov		STLink.hModule,0
	.endif
	ret

STLinkDisconnect endp

STLinkReset proc hWin:HWND

  Retry:
	mov		dword ptr STLink.buff2,0FFFFFFFFh
	invoke SendCommend,0F2h,007h,0E000ED0Ch,4,offset STLink.buff2,4
	invoke SendCommend,0F2h,03Bh,00000000h,0000h,offset STLink.buff2,02h
	mov		dword ptr STLink.buff2,005FA0004h
	invoke SendCommend,0F2h,008h,0E000ED0Ch,0004h,offset STLink.buff2,04h
	invoke SendCommend,0F2h,03Bh,00000000h,0000h,offset STLink.buff2,02h
	invoke SendCommend,0F2h,036h,0E000EDF0h,0000h,offset STLink.buff2,08h
	invoke SendCommend,0F2h,035h,0E000EDF0h,0A05F0003h,offset STLink.buff2,02h
	invoke SendCommend,0F2h,036h,0E000EDF0h,0000h,offset STLink.buff2,08h
	invoke SendCommend,0F2h,03Ah,000000000h,0000h,offset STLink.buff2,05Ch
	mov		dword ptr STLink.buff2,01FFFF800h
	invoke SendCommend,0F2h,007h,01FFFF800h,4,offset STLink.buff2,4
	invoke SendCommend,0F2h,03Bh,00000000h,0000h,offset STLink.buff2,02h
	invoke SendCommend,0F2h,035h,0E000EDF0h,0A05F0001h,offset STLink.buff2,02h
	ret

ExErr:
	invoke MessageBox,hWin,addr szErrNotConnected,addr szError,MB_ABORTRETRYIGNORE or MB_ICONERROR
	.if eax==IDRETRY
		jmp		Retry
	.endif
	push	eax
	.if STLink.hDevice
		push	STLink.hFile
		push	STLink.hDevice
		call	STLink.lpSTMass_CloseDevice
	.endif
	.if STLink.hModule
		invoke FreeLibrary,STLink.hModule
	.endif
	xor		eax,eax
	mov		STLink.hFile,eax
	mov		STLink.hDevice,eax
	mov		STLink.hModule,eax
	pop		eax
	ret

STLinkReset endp

STLinkRead proc hWin:HWND,rdadr:DWORD,wradr:DWORD,nBytes:DWORD

  Retry:
	.if !STLink.hDevice
		jmp		ExErr
	.endif
	.while nBytes>MAX_RDBLOCK
		invoke SendCommend,0F2h,007h,rdadr,MAX_RDBLOCK,wradr,MAX_RDBLOCK
		cmp		eax,1
		jnz		ExErr
		sub		nBytes,MAX_RDBLOCK
		add		rdadr,MAX_RDBLOCK
		add		wradr,MAX_RDBLOCK
	.endw
	.if nBytes
		invoke SendCommend,0F2h,007h,rdadr,nBytes,wradr,nBytes
		cmp		eax,1
		jnz		ExErr
	.endif
	invoke SendCommend,0F2h,03Bh,00000000h,0000h,offset STLink.buff2,02h
	cmp		eax,1
	jnz		ExErr
	ret

ExErr:
	invoke MessageBox,hWin,addr szErrNotConnected,addr szError,MB_ABORTRETRYIGNORE or MB_ICONERROR
	.if eax==IDRETRY
		jmp		Retry
	.endif
	push	eax
	.if STLink.hDevice
		push	STLink.hFile
		push	STLink.hDevice
		call	STLink.lpSTMass_CloseDevice
	.endif
	.if STLink.hModule
		invoke FreeLibrary,STLink.hModule
	.endif
	xor		eax,eax
	mov		STLink.hFile,eax
	mov		STLink.hDevice,eax
	mov		STLink.hModule,eax
	pop		eax
	ret

STLinkRead endp

STLinkWrite proc hWin:HWND,wradr:DWORD,rdadr:DWORD,nBytes:DWORD

  Retry:
	.if !STLink.hDevice
		jmp		ExErr
	.endif
	.while nBytes>MAX_WRBLOCK
		invoke SendCommend,0F2h,00Dh,wradr,MAX_WRBLOCK,rdadr,MAX_WRBLOCK
		cmp		eax,1
		jnz		ExErr
		sub		nBytes,MAX_WRBLOCK
		add		rdadr,MAX_WRBLOCK
		add		wradr,MAX_WRBLOCK
	.endw
	.if nBytes
		invoke SendCommend,0F2h,00Dh,wradr,nBytes,rdadr,nBytes
		cmp		eax,1
		jnz		ExErr
	.endif
	invoke SendCommend,0F2h,03Bh,000000000h,000000000h,addr STLink.buff2,0002h
	cmp		eax,1
	jnz		ExErr
	ret

ExErr:
	invoke MessageBox,hWin,addr szErrNotConnected,addr szError,MB_ABORTRETRYIGNORE or MB_ICONERROR
	.if eax==IDRETRY
		jmp		Retry
	.endif
	push	eax
	.if STLink.hDevice
		push	STLink.hFile
		push	STLink.hDevice
		call	STLink.lpSTMass_CloseDevice
	.endif
	.if STLink.hModule
		invoke FreeLibrary,STLink.hModule
	.endif
	xor		eax,eax
	mov		STLink.hFile,eax
	mov		STLink.hDevice,eax
	mov		STLink.hModule,eax
	pop		eax
	ret

STLinkWrite endp

;########################################################################

end
