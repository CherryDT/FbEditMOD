ENDIF

;NOTE: RadASM 1.2.0.5 uses this method.
;In RadASM.ini section [CustCtrl], x=CustCtrl.dll,y
;x is next free number.
;y is number of controls in the dll. In this case there is only one control.
;
;x=RAGrid.dll,1
;Copy RAGrid.dll to c:\windows\system
;
GetDef proc public nInx:DWORD

	mov		eax,nInx
	.if !eax
		;Get the toolbox bitmap
		;RadASM destroys it after use, so you don't have to worry about that.
		invoke LoadBitmap,hInstance,IDB_RAGRIDBUTTON
		mov		ccdef.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdef
	.else
		xor		eax,eax
	.endif
	ret

GetDef endp

GetDefEx proc public nInx:DWORD

	mov		eax,nInx
	.if !eax
		;Get the toolbox bitmap
		invoke LoadBitmap,hInstance,IDB_RAGRIDBUTTON
		mov		ccdefex.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdefex
	.else
		xor		eax,eax
	.endif
	ret

GetDefEx endp

DllEntry proc public hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	.if reason==DLL_PROCESS_ATTACH
		invoke GridInstall,hInst,TRUE
		;prepare common control structure
		mov		iccex.dwSize,sizeof INITCOMMONCONTROLSEX
		mov		iccex.dwICC,ICC_DATE_CLASSES or ICC_INTERNET_CLASSES or ICC_HOTKEY_CLASS
		invoke InitCommonControlsEx,offset iccex
		invoke GetTickCount
		mov		rseed,eax
	.elseif reason==DLL_PROCESS_DETACH
		invoke GridUnInstall
	.endif
	mov     eax,TRUE
	ret

DllEntry Endp

End DllEntry
