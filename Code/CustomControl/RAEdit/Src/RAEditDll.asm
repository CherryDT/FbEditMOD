
ENDIF

PROP_STYLETRUEFALSE		equ 1
PROP_EXSTYLETRUEFALSE	equ 2
PROP_STYLEMULTI			equ 3

STYLE					equ WS_CHILD or WS_VISIBLE or STYLE_DRAGDROP or STYLE_SCROLLTIP
EXSTYLE					equ WS_EX_CLIENTEDGE

;Used by RadASM 1.2.0.5
CCDEF struct
	ID					dd ?		;Controls uniqe ID
	lptooltip			dd ?		;Pointer to tooltip text
	hbmp				dd ?		;Handle of bitmap
	lpcaption			dd ?		;Pointer to default caption text
	lpname				dd ?		;Pointer to default id-name text
	lpclass				dd ?		;Pointer to class text
	style				dd ?		;Default style
	exstyle				dd ?		;Default ex-style
	flist1				dd ?		;Property listbox 1
	flist2				dd ?		;Property listbox 2
	disable				dd ?		;Disable controls child windows. 0=No, 1=Use method 1, 2=Use method 2
CCDEF ends

;Used by RadASM 2.1.0.4
CCDEFEX struct
	ID					dd ?		;Controls uniqe ID
	lptooltip			dd ?		;Pointer to tooltip text
	hbmp				dd ?		;Handle of bitmap
	lpcaption			dd ?		;Pointer to default caption text
	lpname				dd ?		;Pointer to default id-name text
	lpclass				dd ?		;Pointer to class text
	style				dd ?		;Default style
	exstyle				dd ?		;Default ex-style
	flist1				dd ?		;Property listbox 1
	flist2				dd ?		;Property listbox 2
	flist3				dd ?		;Property listbox 3
	flist4				dd ?		;Property listbox 4
	lpproperty			dd ?		;Pointer to properties text to add
	lpmethod			dd ?		;Pointer to property methods
CCDEFEX ends

.const

szCap					db 0
szName					db 'IDC_RAE',0

PropertySplitBar		dd -1 xor STYLE_NOSPLITT,STYLE_NOSPLITT
						dd -1 xor STYLE_NOSPLITT,0
PropertyLineNbr			dd -1 xor STYLE_NOLINENUMBER,STYLE_NOLINENUMBER
						dd -1 xor STYLE_NOLINENUMBER,0
PropertyCollapse		dd -1 xor STYLE_NOCOLLAPSE,STYLE_NOCOLLAPSE
						dd -1 xor STYLE_NOCOLLAPSE,0
PropertyScrollBar		db 'None,Horizontal,Vertical,Both',0
						dd -1 xor (STYLE_NOHSCROLL or STYLE_NOVSCROLL),STYLE_NOHSCROLL or STYLE_NOVSCROLL
						dd -1,0
						dd -1 xor (STYLE_NOHSCROLL or STYLE_NOVSCROLL),STYLE_NOVSCROLL
						dd -1,0
						dd -1 xor (STYLE_NOHSCROLL or STYLE_NOVSCROLL),STYLE_NOHSCROLL
						dd -1,0
						dd -1 xor (STYLE_NOHSCROLL or STYLE_NOVSCROLL),0
						dd -1,0
PropertyHilite			dd -1 xor STYLE_NOHILITE,STYLE_NOHILITE
						dd -1 xor STYLE_NOHILITE,0
PropertyScrollTip		dd -1 xor STYLE_SCROLLTIP,0
						dd -1 xor STYLE_SCROLLTIP,STYLE_SCROLLTIP
PropertyHiliteCmnt		dd -1 xor STYLE_HILITECOMMENT,0
						dd -1 xor STYLE_HILITECOMMENT,STYLE_HILITECOMMENT
PropertyAutoLineNbrWt	dd -1 xor STYLE_AUTOSIZELINENUM,0
						dd -1 xor STYLE_AUTOSIZELINENUM,STYLE_AUTOSIZELINENUM
Methods					dd PROP_STYLETRUEFALSE,offset PropertySplitBar
						dd PROP_STYLETRUEFALSE,offset PropertyLineNbr
						dd PROP_STYLETRUEFALSE,offset PropertyCollapse
						dd PROP_STYLEMULTI,offset PropertyScrollBar
						dd PROP_STYLETRUEFALSE,offset PropertyHilite
						dd PROP_STYLETRUEFALSE,offset PropertyScrollTip
						dd PROP_STYLETRUEFALSE,offset PropertyHiliteCmnt
						dd PROP_STYLETRUEFALSE,offset PropertyAutoLineNbrWt

.data

szProperty				db 'SplitBar,LineNbr,Collapse,ScrollBar,HighLight,ScrollTip,HighCmnt,AutoLineNbrWt',0
;Create an inited struct
ccdef					CCDEF <260,offset szToolTip,0,offset szCap,offset szName,offset szRAEditClass,STYLE,EXSTYLE,11111101000111000000000001000000b,00010000000000011000000000000000b,1>
ccdefex					CCDEFEX <260,offset szToolTip,0,offset szCap,offset szName,offset szRAEditClass,STYLE,EXSTYLE,11111101000111000000000001000000b,00010000000000011000000000000000b,00000000000000000000000000000000b,00000000000000000000000000000000b,offset szProperty,offset Methods>

.code

DllEntry proc public hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	.if reason==DLL_PROCESS_ATTACH
		invoke InstallRAEdit,hInst,TRUE
	.elseif reason==DLL_PROCESS_DETACH
		invoke UnInstallRAEdit
	.endif
	mov     eax,TRUE
	ret

DllEntry endp

;NOTE: RadASM 1.2.0.5 uses this method.
;In RadASM.ini section [CustCtrl], x=CustCtrl.dll,y
;x is next free number.
;y is number of controls in the dll. In this case there is only one control.
;
;x=RAEdit.dll,1
;Copy RAEdit.dll to c:\windows\system
;
GetDef proc public nInx:DWORD

	mov		eax,nInx
	.if !eax
		;Get the toolbox bitmap
		;RadASM destroys it after use, so you don't have to worry about that.
		invoke LoadBitmap,hInstance,IDB_RAEDITBUTTON
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
		invoke LoadBitmap,hInstance,IDB_RAEDITBUTTON
		mov		ccdefex.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdefex
	.else
		xor		eax,eax
	.endif
	ret

GetDefEx endp

End DllEntry

