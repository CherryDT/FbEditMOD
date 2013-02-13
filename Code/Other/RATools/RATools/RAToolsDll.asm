ENDIF

;Used by RadASM 1.2.0.5. See RadASMini.rtf for more info
CCDEF struct
	ID			dd ?		;Controls uniqe ID
	lptooltip	dd ?		;Pointer to tooltip text
	hbmp		dd ?		;Handle of bitmap
	lpcaption	dd ?		;Pointer to default caption text
	lpname		dd ?		;Pointer to default id-name text
	lpclass		dd ?		;Pointer to class text
	style		dd ?		;Default style
	exstyle		dd ?		;Default ex-style
	property1	dd ?		;Property listbox 1 (bitflags on what properties are enabled)
	property2	dd ?		;Property listbox 2 (bitflags on what properties are enabled)
	disable		dd ?		;Disable controls child windows. 0=No, 1=Use method 1, 2=Use method 2
CCDEF ends

;Used by RadASM 2.1.0.4
CCDEFEX struct
	ID			dd ?		;Controls uniqe ID
	lptooltip	dd ?		;Pointer to tooltip text
	hbmp		dd ?		;Handle of bitmap
	lpcaption	dd ?		;Pointer to default caption text
	lpname		dd ?		;Pointer to default id-name text
	lpclass		dd ?		;Pointer to class text
	style		dd ?		;Default style
	exstyle		dd ?		;Default ex-style
	flist1		dd ?		;Property listbox 1
	flist2		dd ?		;Property listbox 2
	flist3		dd ?		;Property listbox 3
	flist4		dd ?		;Property listbox 4
	lpproperty	dd ?		;Pointer to properties text
	lpmethod	dd ?		;Pointer to property methods descriptor
CCDEFEX ends

PROP_STYLETRUEFALSE		equ 1
PROP_EXSTYLETRUEFALSE	equ 2
PROP_STYLEMULTI			equ 3

DEFSTYLE				equ WS_CHILD or WS_VISIBLE
DEFEXSTYLE				equ 0
IDB_TOOLBMP				equ 100

.const

ToolTip					db 'ToolWindows',0
szCap					db 0
szName					db 'IDC_TOOL',0

.data

;																														  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
ccdef					CCDEF <340,offset ToolTip,0,offset szCap,offset szName,offset szToolClassName,DEFSTYLE,DEFEXSTYLE,  11111101000110000000000001000000b,00010000000000011000000000000000b,0>
ccdefex					CCDEFEX <340,offset ToolTip,0,offset szCap,offset szName,offset szToolClassName,DEFSTYLE,DEFEXSTYLE,11111101000110000000000001000000b,00010000000000011000000000000000b,00000000000000000000000000000000b,00000000000000000000000000000000b,NULL,NULL>

.code

DllEntry proc public hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	.if reason==DLL_PROCESS_ATTACH
		invoke InstallRATools,hInst,TRUE
	.elseif reason==DLL_PROCESS_DETACH
		invoke UnInstallRATools
	.endif
	mov     eax,TRUE
	ret

DllEntry endp

;NOTE: RadASM 1.2.0.5 uses GetDef method.
GetDef proc public nInx:DWORD

	mov		eax,nInx
	.if !eax
		;Get the toolbox bitmap
		invoke LoadBitmap,hInstance,IDB_TOOLBMP
		mov		ccdef.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdef
	.else
		xor		eax,eax
	.endif
	ret

GetDef endp

;Used by RadASM 2.1.0.4
GetDefEx proc public nInx:DWORD

	mov		eax,nInx
	.if !eax
		;Get the toolbox bitmap
		invoke LoadBitmap,hInstance,IDB_TOOLBMP
		mov		ccdefex.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdefex
	.else
		xor		eax,eax
	.endif
	ret

GetDefEx endp

End DllEntry
