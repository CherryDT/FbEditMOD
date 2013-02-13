
ResEdDllEntry proc public hInst:HINSTANCE, reason:DWORD, reserved1:DWORD

	.if reason==DLL_PROCESS_ATTACH
		invoke ResEdInstall,hInst,TRUE
	.elseif reason==DLL_PROCESS_DETACH
		invoke ResEdUninstall
	.endif
    mov     eax,TRUE
    ret

ResEdDllEntry Endp

GetDef proc public nInx:DWORD

	mov		eax,nInx
	.if !eax
		;Get the toolbox bitmap
		invoke LoadBitmap,hInstance,IDB_DLG
		mov		ccdef.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdef
	.else
		xor		eax,eax
	.endif
	ret

GetDef endp

ENDIF

End ResEdDllEntry
