ENDIF

;In RadASM.ini section [CustCtrl], x=RAProperty.dll,y
;x is next free number.
;y is number of controls in the dll. In this case there is only one control.
;
;x=RAProperty.dll,1
;Copy RAProperty.dll to c:\radasm or to c:\windows\system
;

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

STYLE					equ WS_CHILD or WS_VISIBLE
EXSTYLE					equ 0
IDB_BMP					equ 100

PROP_STYLETRUEFALSE		equ 1
PROP_EXSTYLETRUEFALSE	equ 2
PROP_STYLEMULTI			equ 3

.const

szToolTip				db 'Code property',0
szCap					db 0
szName					db 'IDC_PRP',0

PropertyFlat			dd -1 xor PRSTYLE_FLATTOOLBAR,0
						dd -1 xor PRSTYLE_FLATTOOLBAR,PRSTYLE_FLATTOOLBAR
PropertyDivider			dd -1 xor PRSTYLE_DIVIDERLINE,0
						dd -1 xor PRSTYLE_DIVIDERLINE,PRSTYLE_DIVIDERLINE
PropertyProject			dd -1 xor PRSTYLE_PROJECT,0
						dd -1 xor PRSTYLE_PROJECT,PRSTYLE_PROJECT

Methods					dd PROP_STYLETRUEFALSE,offset PropertyFlat
						dd PROP_STYLETRUEFALSE,offset PropertyDivider
						dd PROP_STYLETRUEFALSE,offset PropertyProject

.data

szProperty				db 'FlatToolBar,DividerLine,Project',0
ccdefex					CCDEFEX <876,offset szToolTip,0,offset szCap,offset szName,offset szClassName,STYLE,EXSTYLE,11111101000111100000000000000000b,00010000000000011000000000000000b,0,0,offset szProperty,offset Methods>

.code

DllEntry proc public hInst:HINSTANCE, reason:DWORD, reserved1:DWORD

	.if reason==DLL_PROCESS_ATTACH
	    push    hInst
	    pop     hInstance
		invoke InstallRAProperty,hInst,TRUE
	.endif
    mov     eax,TRUE
    ret

DllEntry Endp

GetDefEx proc public nInx:DWORD

	mov		eax,nInx
	.if !eax
		;Get the toolbox bitmap
		invoke LoadBitmap,hInstance,IDB_BMP
		mov		ccdefex.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdefex
	.else
		xor		eax,eax
	.endif
	ret

GetDefEx endp

End DllEntry
