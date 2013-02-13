ENDIF

STYLE				equ WS_CHILD or WS_VISIBLE
EXSTYLE				equ WS_EX_CLIENTEDGE

;Used by RadASM 1.2.0.5
CCDEF struct
	ID				dd ?		;Controls uniqe ID
	lptooltip		dd ?		;Pointer to tooltip text
	hbmp			dd ?		;Handle of bitmap
	lpcaption		dd ?		;Pointer to default caption text
	lpname			dd ?		;Pointer to default id-name text
	lpclass			dd ?		;Pointer to class text
	style			dd ?		;Default style
	exstyle			dd ?		;Default ex-style
	flist1			dd ?		;Property listbox 1
	flist2			dd ?		;Property listbox 2
	disable			dd ?		;Disable controls child windows. 0=No, 1=Use method 1, 2=Use method 2
CCDEF ends

;Used by RadASM 2.1.0.4
CCDEFEX struct
	ID				dd ?		;Controls uniqe ID
	lptooltip		dd ?		;Pointer to tooltip text
	hbmp			dd ?		;Handle of bitmap
	lpcaption		dd ?		;Pointer to default caption text
	lpname			dd ?		;Pointer to default id-name text
	lpclass			dd ?		;Pointer to class text
	style			dd ?		;Default style
	exstyle			dd ?		;Default ex-style
	flist1			dd ?		;Property listbox 1
	flist2			dd ?		;Property listbox 2
	flist3			dd ?		;Property listbox 3
	flist4			dd ?		;Property listbox 4
	lpproperty		dd ?		;Pointer to properties text to add
	lpmethod		dd ?		;Pointer to property methods
CCDEFEX ends

PROP_STYLETRUEFALSE		equ 1
PROP_EXSTYLETRUEFALSE	equ 2
PROP_STYLEMULTI			equ 3

.data

szCap				db 0
szName				db 'IDC_RAH',0

szProperty			db 'Address,Ascii,SplitBar,LineNbr,ScrollBar,UpperCase',0
PropertyAddress		dd -1 xor HEX_STYLE_NOADDRESS,HEX_STYLE_NOADDRESS
					dd -1 xor HEX_STYLE_NOADDRESS,0
PropertyAscii		dd -1 xor HEX_STYLE_NOASCII,HEX_STYLE_NOASCII
					dd -1 xor HEX_STYLE_NOASCII,0
PropertySplitBar	dd -1 xor HEX_STYLE_NOSPLITT,HEX_STYLE_NOSPLITT
					dd -1 xor HEX_STYLE_NOSPLITT,0
PropertyLineNbr		dd -1 xor HEX_STYLE_NOLINENUMBER,HEX_STYLE_NOLINENUMBER
					dd -1 xor HEX_STYLE_NOLINENUMBER,0
PropertyScrollBar	db 'None,Horizontal,Vertical,Both',0
					dd -1 xor (HEX_STYLE_NOHSCROLL or HEX_STYLE_NOVSCROLL),HEX_STYLE_NOHSCROLL or HEX_STYLE_NOVSCROLL
					dd -1,0
					dd -1 xor (HEX_STYLE_NOHSCROLL or HEX_STYLE_NOVSCROLL),HEX_STYLE_NOVSCROLL
					dd -1,0
					dd -1 xor (HEX_STYLE_NOHSCROLL or HEX_STYLE_NOVSCROLL),HEX_STYLE_NOHSCROLL
					dd -1,0
					dd -1 xor (HEX_STYLE_NOHSCROLL or HEX_STYLE_NOVSCROLL),0
					dd -1,0
PropertyUpperCase	dd -1 xor HEX_STYLE_NOUPPERCASE,HEX_STYLE_NOUPPERCASE
					dd -1 xor HEX_STYLE_NOUPPERCASE,0
Methods				dd PROP_STYLETRUEFALSE,offset PropertyAddress
					dd PROP_STYLETRUEFALSE,offset PropertyAscii
					dd PROP_STYLETRUEFALSE,offset PropertySplitBar
					dd PROP_STYLETRUEFALSE,offset PropertyLineNbr
					dd PROP_STYLEMULTI,offset PropertyScrollBar
					dd PROP_STYLETRUEFALSE,offset PropertyUpperCase

;Create an inited struct
ccdef				CCDEF <261,offset szToolTip,0,offset szCap,offset szName,offset szRAHexEdClassName,STYLE,EXSTYLE,11111101000111000000000001000000b,00010000000000011000000000000000b,1>
ccdefex				CCDEFEX <261,offset szToolTip,0,offset szCap,offset szName,offset szRAHexEdClassName,STYLE,EXSTYLE,11111101000111000000000001000000b,00010000000000011000000000000000b,0h,0h,offset szProperty,offset Methods>

.code

DllEntry proc public hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	.if reason==DLL_PROCESS_ATTACH
		mov		eax,hInst
		mov		hInstance,eax
		invoke RAHexEdInstall,eax,TRUE
	.elseif reason==DLL_PROCESS_DETACH
		invoke RAHexEdUnInstall
	.endif
	mov     eax,TRUE
	ret

DllEntry Endp

GetDef proc public nInx:DWORD

	mov		eax,nInx
	.if !eax
		;Get the toolbox bitmap
		invoke LoadBitmap,hInstance,IDB_RAHEXEDBUTTON
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
		invoke LoadBitmap,hInstance,IDB_RAHEXEDBUTTON
		mov		ccdefex.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdefex
	.else
		xor		eax,eax
	.endif
	ret

GetDefEx endp

End DllEntry
