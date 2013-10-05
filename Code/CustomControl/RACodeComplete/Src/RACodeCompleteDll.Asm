ENDIF

;Used by RadASM 1.2.0.5. See RadASMini.rtf for more info
CCDEF struct
	ID			dd ?						;Controls uniqe ID
	lptooltip	dd ?						;Pointer to tooltip text
	hbmp		dd ?						;Handle of bitmap
	lpcaption	dd ?						;Pointer to default caption text
	lpname		dd ?						;Pointer to default id-name text
	lpclass		dd ?						;Pointer to class text
	style		dd ?						;Default style
	exstyle		dd ?						;Default ex-style
	property1	dd ?						;Property listbox 1 (bitflags on what properties are enabled)
	property2	dd ?						;Property listbox 2 (bitflags on what properties are enabled)
	disable		dd ?						;Disable controls child windows. 0=No, 1=Use method 1, 2=Use method 2
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

RACCLBSTYLE				equ WS_CHILD or WS_VISIBLE
RACCLBEXSTYLE			equ 200h
RACCTTSTYLE				equ WS_POPUP or WS_BORDER
RACCTTEXSTYLE			equ 0h
IDB_BMP					equ 100

.const

szNULL					db 0
szCCLBToolTip			db 'RACodeCompleteListBox',0
szCCLBName				db 'IDC_RACCLB',0
szCCTTToolTip			db 'RACodeCompleteToolTip',0
szCCTTName				db 'IDC_RACCTT',0

PropertyImageList		dd -1 xor STYLE_USEIMAGELIST,0
						dd -1 xor STYLE_USEIMAGELIST,STYLE_USEIMAGELIST
Methodslb				dd PROP_STYLETRUEFALSE,offset PropertyImageList

PropertyParanteses		dd -1 xor STYLE_USEPARANTESES,0
						dd -1 xor STYLE_USEPARANTESES,STYLE_USEPARANTESES
Methodstt				dd PROP_STYLETRUEFALSE,offset PropertyParanteses

.data

szPropertylb			db 'ImageList',0
szPropertytt			db 'Paranteses',0

;																													                   NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
ccdefcclb				CCDEF <301,offset szCCLBToolTip,0,offset szNULL,offset szCCLBName,offset szCCLBClassName,RACCLBSTYLE,RACCLBEXSTYLE,11111101000111000000000101000000b,00010000000000011000000000000000b,0>
ccdefcctt				CCDEF <302,offset szCCTTToolTip,0,offset szNULL,offset szCCTTName,offset szCCTTClassName,RACCTTSTYLE,RACCTTEXSTYLE,11111101000111000000000100000000b,00010000000000011000000000000000b,0>
ccdefcclbex				CCDEFEX	<301,offset szCCLBToolTip,0,offset szNULL,offset szCCLBName,offset szCCLBClassName,RACCLBSTYLE,RACCLBEXSTYLE,11111101000111000000000101000000b,00010000000000011000000000000000b,0,0,offset szPropertylb,offset Methodslb>
ccdefccttex				CCDEFEX	<302,offset szCCTTToolTip,0,offset szNULL,offset szCCTTName,offset szCCTTClassName,RACCTTSTYLE,RACCTTEXSTYLE,11111101000111000000000100000000b,00010000000000011000000000000000b,0,0,offset szPropertytt,offset Methodstt>

.code

DllEntry proc public hInst:HINSTANCE, reason:DWORD, reserved1:DWORD

	.if reason==DLL_PROCESS_ATTACH
	    push    hInst
	    pop     hInstance
		invoke InstallRACodeComplete,hInst,TRUE
	.elseif reason==DLL_PROCESS_DETACH
	.endif
    mov     eax,TRUE
    ret

DllEntry Endp

;NOTE: RadASM 1.2.0.5 uses GetDef method.
;In RadASM.ini section [CustCtrl], x=CustCtrl.dll,y
;x is next free number.
;y is number of controls in the dll. In this case there is only one control.
;
;x=RACodeComplete.dll,1
;Copy RACodeComplete.dll to c:\radasm or to c:\windows\system
;
GetDef proc public nInx:DWORD

	mov		eax,nInx
	.if !eax
		;Get the toolbox bitmap
		invoke LoadBitmap,hInstance,IDB_BMP
		mov		ccdefcclb.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdefcclb
	.elseif eax==1
		;Get the toolbox bitmap
		invoke LoadBitmap,hInstance,IDB_BMP
		mov		ccdefcctt.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdefcctt
	.else
		xor		eax,eax
	.endif
	ret

GetDef endp

GetDefEx proc public nInx:DWORD

	mov		eax,nInx
	.if !eax
		;Get the toolbox bitmap
		invoke LoadBitmap,hInstance,IDB_BMP
		mov		ccdefcclbex.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdefcclbex
	.elseif eax==1
		;Get the toolbox bitmap
		invoke LoadBitmap,hInstance,IDB_BMP
		mov		ccdefccttex.hbmp,eax
		;Return pointer to inited struct
		mov		eax,offset ccdefccttex
	.else
		xor		eax,eax
	.endif
	ret

GetDefEx endp

End DllEntry
