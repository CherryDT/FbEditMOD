
IDD_DLGVERSION		equ 1700
IDC_EDTVERFILE		equ 2903
IDC_EDTVERPROD		equ 2904
IDC_CBOVEROS		equ 2905
IDC_CBOVERTYPE		equ 2906
IDC_CBOVERLANG		equ 2907
IDC_CBOVERCHAR		equ 2908
IDC_LSTVER			equ 2909
IDC_EDTVER			equ 2910
IDC_EDTVERTPE		equ 2911
IDC_BTNVERADD		equ 2912

.const

szVerOS				dd 00000004h
					db 'WINDOWS32',0
					dd 00000000h
					db 'UNKNOWN',0
					dd 00010000h
					db 'DOS',0
					dd 00020000h
					db 'OS216',0
					dd 00030000h
					db 'OS232',0
					dd 00040000h
					db 'NT',0
					dd 00000000h
					db 'BASE',0
					dd 00000001h
					db 'WINDOWS16',0
					dd 00000002h
					db 'PM16',0
					dd 00000003h
					db 'PM32',0
					dd 00010001h
					db 'DOS_WINDOWS16',0
					dd 00010004h
					db 'DOS_WINDOWS32',0
					dd 00020002h
					db 'OS216_PM16',0
					dd 00030003h
					db 'OS232_PM32',0
					dd 00040004h
					db 'NT_WINDOWS32',0
					dd 0,0

szVerFT				dd 00000000h
					db 'UNKNOWN',0
					dd 00000001h
					db 'APP',0
					dd 00000002h
					db 'DLL',0
					dd 00000003h
					db 'DRV',0
					dd 00000004h
					db 'FONT',0
					dd 00000005h
					db 'VXD',0
					dd 00000007h
					db 'STATIC_LIB',0
					dd 0,0

szVerLNG			dd 0409h
					db 'U.S. English',0
					dd 0401h
					db 'Arabic',0
					dd 0402h
					db 'Bulgarian',0
					dd 0403h
					db 'Catalan',0
					dd 0404h
					db 'Traditional Chinese',0
					dd 0405h
					db 'Czech',0
					dd 0406h
					db 'Danish',0
					dd 0407h
					db 'German',0
					dd 0408h
					db 'Greek',0
					dd 040Ah
					db 'Castilian Spanish',0
					dd 040Bh
					db 'Finnish',0
					dd 040Ch
					db 'French',0
					dd 040Dh
					db 'Hebrew',0
					dd 040Eh
					db 'Hungarian',0
					dd 040Fh
					db 'Icelandic',0
					dd 0410h
					db 'Italian',0
					dd 0411h
					db 'Japanese',0
					dd 0412h
					db 'Korean',0
					dd 0413h
					db 'Dutch',0
					dd 0414h
					db 'Norwegian - Bokml',0
					dd 0415h
					db 'Polish',0
					dd 0416h
					db 'Brazilian Portuguese',0
					dd 0417h
					db 'Rhaeto-Romanic',0
					dd 0417h
					db 'Rhaeto-Romanic',0
					dd 0418h
					db 'Romanian',0
					dd 0419h
					db 'Russian',0
					dd 041Ah
					db 'Croato-Serbian (Latin)',0
					dd 041Bh
					db 'Slovak',0
					dd 041Ch
					db 'Albanian',0
					dd 041Dh
					db 'Swedish',0
					dd 041Eh
					db 'Thai',0
					dd 041Fh
					db 'Turkish',0
					dd 0420h
					db 'Urdu',0
					dd 0421h
					db 'Bahasa',0
					dd 0804h
					db 'Simplified Chinese',0
					dd 0807h
					db 'Swiss German',0
					dd 0809h
					db 'U.K. English',0
					dd 080Ah
					db 'Mexican Spanish',0
					dd 080Ch
					db 'Belgian French',0
					dd 0810h
					db 'Swiss Italian',0
					dd 0813h
					db 'Belgian Dutch',0
					dd 0814h
					db 'Norwegian - Nynorsk',0
					dd 0816h
					db 'Portuguese',0
					dd 081Ah
					db 'Serbo-Croatian (Cyrillic)',0
					dd 0C0Ch
					db 'Canadian French',0
					dd 100Ch
					db 'Swiss French',0
					dd 0,0

szVerCHS			dd 1200
					db 'Unicode',0
					dd 0
					db '7-bit ASCII',0
					dd 932
					db 'Japan (Shift - JIS X-0208)',0
					dd 949
					db 'Korea (Shift - KSC 5601)',0
					dd 950
					db 'Taiwan (GB5)',0
					dd 1250
					db 'Latin-2 (Eastern European)',0
					dd 1251
					db 'Cyrillic',0
					dd 1252
					db 'Multilingual',0
					dd 1253
					db 'Greek',0
					dd 1254
					db 'Turkish',0
					dd 1255
					db 'Hebrew',0
					dd 1256
					db 'Arabic',0
					dd 0,0

szVerTpe			db 'CompanyName',0
					db 'FileVersion',0
					db 'FileDescription',0
					db 'InternalName',0
					db 'LegalCopyright',0
					db 'LegalTrademarks',0
					db 'OriginalFilename',0
					db 'ProductName',0
					db 'ProductVersion',0
					db 0

szStringFileInfo	db 'StringFileInfo',0
szVarFileInfo		db 'VarFileInfo',0
szTranslation		db 'Translation',0

.data

szVersionName		db 'IDR_VERSION',0
defver				VERSIONMEM <,1,1,0,0,0,1,0,0,0,4,0,409h,4B0h>
					VERSIONITEM <"FileVersion","1.0.0.0">
					VERSIONITEM <"ProductVersion","1.0.0.0">
					VERSIONITEM 30 dup(<>)

.data?

szVersionTxt		db 32*256 dup(?)
lpOldEditProc		dd ?
hVerDlg				dd ?

.code

IncrementVersion proc lpProMem:DWORD

	mov		eax,hDialog
	.if eax && eax==hVerDlg
		invoke CloseDialog
	.endif
RADbg 0,2097726,0
RADbg 0,1181728,0
	invoke GetTypeMem,lpProMem,TPE_VERSION
	.if eax
		mov		edx,[eax].PROJECT.hmem
		inc		[edx].VERSIONMEM.fv3
		inc		[edx].VERSIONMEM.pv3
		mov		[eax].PROJECT.changed,TRUE
	.endif
	ret

IncrementVersion endp

ExportVersionNames proc uses esi edi,hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*16
	mov     edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	;#define
    .if [esi].VERSIONMEM.szname && [esi].VERSIONMEM.value
    	invoke ExportName,addr [esi].VERSIONMEM.szname,[esi].VERSIONMEM.value,edi
    	lea		edi,[edi+eax]
	.endif
	pop		eax
	ret

ExportVersionNames endp

ExportVersion proc uses esi edi,hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*16
	mov     edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	;Name or ID
    .if [esi].VERSIONMEM.szname
    	invoke strcpy,edi,addr [esi].VERSIONMEM.szname
	.else
		invoke ResEdBinToDec,[esi].VERSIONMEM.value,edi
	.endif
	invoke strlen,edi
	add		edi,eax
	mov		al,' '
	stosb
	invoke SaveStr,edi,addr szVERSIONINFO
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	;File version
	invoke SaveStr,edi,addr szFILEVERSION
	add		edi,eax
	mov		al,' '
	stosb
	push	esi
	lea		esi,[esi].VERSIONMEM.fv
	call	SaveVer
	pop		esi
	;Product version
	invoke SaveStr,edi,addr szPRODUCTVERSION
	add		edi,eax
	mov		al,' '
	stosb
	push	esi
	lea		esi,[esi].VERSIONMEM.pv
	call	SaveVer
	pop		esi
	;File OS
	invoke SaveStr,edi,addr szFILEOS
	add		edi,eax
	mov		al,' '
	stosb
	mov		eax,[esi].VERSIONMEM.os
	call	SaveHex
	;File type
	invoke SaveStr,edi,addr szFILETYPE
	add		edi,eax
	mov		al,' '
	stosb
	mov		eax,[esi].VERSIONMEM.ft
	call	SaveHex
	invoke SaveStr,edi,addr szBEGIN
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,' '
	stosb
	stosb
	invoke SaveStr,edi,addr szBLOCK
	add		edi,eax
	mov		al,' '
	stosb
	mov		al,22h
	stosb
	invoke SaveStr,edi,addr szStringFileInfo
	add		edi,eax
	mov		al,22h
	stosb
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,' '
	stosb
	stosb
	invoke SaveStr,edi,addr szBEGIN
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,' '
	stosb
	stosb
	stosb
	stosb
	invoke SaveStr,edi,addr szBLOCK
	add		edi,eax
	mov		al,' '
	stosb
	mov		al,22h
	stosb
	mov		eax,[esi].VERSIONMEM.lng
	invoke hexEax
	invoke strcpy,edi,offset strHex+4
	add		edi,4
	mov		eax,[esi].VERSIONMEM.chs
	invoke hexEax
	invoke strcpy,edi,offset strHex+4
	add		edi,4
	mov		al,22h
	stosb
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,' '
	stosb
	stosb
	stosb
	stosb
	invoke SaveStr,edi,addr szBEGIN
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	push	esi
	lea		esi,[esi+sizeof VERSIONMEM]
	.while TRUE
		.break .if ![esi].VERSIONITEM.szname
		.if [esi].VERSIONITEM.szvalue
			mov		al,' '
			stosb
			stosb
			stosb
			stosb
			stosb
			stosb
			invoke SaveStr,edi,addr szVALUE
			add		edi,eax
			mov		al,' '
			stosb
			mov		al,22h
			stosb
			invoke SaveStr,edi,addr [esi].VERSIONITEM.szname
			add		edi,eax
			mov		al,22h
			stosb
			mov		al,','
			stosb
			mov		al,' '
			stosb
			mov		al,22h
			stosb
			invoke SaveStr,edi,addr [esi].VERSIONITEM.szvalue
			add		edi,eax
			mov		al,'\'
			stosb
			mov		al,'0'
			stosb
			mov		al,22h
			stosb
			mov		al,0Dh
			stosb
			mov		al,0Ah
			stosb
		.endif
		lea		esi,[esi+sizeof VERSIONITEM]
	.endw
	pop		esi
	mov		al,' '
	stosb
	stosb
	stosb
	stosb
	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,' '
	stosb
	stosb
	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,' '
	stosb
	stosb
	invoke SaveStr,edi,addr szBLOCK
	add		edi,eax
	mov		al,' '
	stosb
	mov		al,22h
	stosb
	invoke SaveStr,edi,addr szVarFileInfo
	add		edi,eax
	mov		al,22h
	stosb
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,' '
	stosb
	stosb
	invoke SaveStr,edi,addr szBEGIN
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,' '
	stosb
	stosb
	stosb
	stosb
	invoke SaveStr,edi,addr szVALUE
	add		edi,eax
	mov		al,' '
	stosb
	mov		al,22h
	stosb
	invoke SaveStr,edi,addr szTranslation
	add		edi,eax
	mov		al,22h
	stosb
	mov		al,','
	stosb
	mov		al,' '
	stosb
	mov		al,'0'
	stosb
	mov		al,'x'
	stosb
	mov		eax,[esi].VERSIONMEM.lng
	invoke hexEax
	invoke strcpy,edi,offset strHex+4
	add		edi,4
	mov		al,','
	stosb
	mov		al,' '
	stosb
	mov		al,'0'
	stosb
	mov		al,'x'
	stosb
	mov		eax,[esi].VERSIONMEM.chs
	invoke hexEax
	invoke strcpy,edi,offset strHex+4
	add		edi,4
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,' '
	stosb
	stosb
	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,0
	stosb
	pop		eax
	ret

SaveVer:
	mov		eax,[esi]
	call	SaveVerItem
	mov		eax,[esi+4]
	call	SaveVerItem
	mov		eax,[esi+8]
	call	SaveVerItem
	mov		eax,[esi+12]
	call	SaveVerItem
	dec		edi
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	retn

SaveVerItem:
	invoke ResEdBinToDec,eax,edi
	invoke strlen,edi
	lea		edi,[edi+eax]
	mov		al,','
	stosb
	retn

SaveHex:
	mov		word ptr [edi],'x0'
	add		edi,2
	invoke hexEax
	invoke strcpy,edi,offset strHex
	add		edi,8
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	retn

ExportVersion endp

SaveVersionEdit proc uses ebx esi edi,hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	buffer[512]:BYTE

	invoke GetWindowLong,hWin,GWL_USERDATA
	.if !eax
		invoke SendMessage,hRes,PRO_ADDITEM,TPE_VERSION,FALSE
		push	eax
		invoke RtlMoveMemory,[eax].PROJECT.hmem,offset defver,sizeof VERSIONMEM+sizeof VERSIONITEM*32
		pop		eax
	.endif
	mov		ebx,eax
	push	ebx
	mov		esi,[ebx].PROJECT.hmem
	invoke GetProjectItemName,ebx,addr buffer
	invoke SetProjectItemName,ebx,addr buffer
	invoke GetDlgItemText,hWin,IDC_EDTVERFILE,addr buffer,16
	push	esi
	lea		esi,[esi].VERSIONMEM.fv
	call	GetVerNum
	pop		esi
	invoke GetDlgItemText,hWin,IDC_EDTVERPROD,addr buffer,16
	push	esi
	lea		esi,[esi].VERSIONMEM.pv
	call	GetVerNum
	pop		esi
	invoke SendDlgItemMessage,hWin,IDC_CBOVEROS,CB_GETCURSEL,0,0
	invoke SendDlgItemMessage,hWin,IDC_CBOVEROS,CB_GETITEMDATA,eax,0
	mov		[esi].VERSIONMEM.os,eax
	invoke SendDlgItemMessage,hWin,IDC_CBOVERTYPE,CB_GETCURSEL,0,0
	invoke SendDlgItemMessage,hWin,IDC_CBOVERTYPE,CB_GETITEMDATA,eax,0
	mov		[esi].VERSIONMEM.ft,eax
	invoke SendDlgItemMessage,hWin,IDC_CBOVERLANG,CB_GETCURSEL,0,0
	invoke SendDlgItemMessage,hWin,IDC_CBOVERLANG,CB_GETITEMDATA,eax,0
	mov		[esi].VERSIONMEM.lng,eax
	invoke SendDlgItemMessage,hWin,IDC_CBOVERCHAR,CB_GETCURSEL,0,0
	invoke SendDlgItemMessage,hWin,IDC_CBOVERCHAR,CB_GETITEMDATA,eax,0
	mov		[esi].VERSIONMEM.chs,eax
	lea		esi,[esi+sizeof VERSIONMEM]
	mov		nInx,0
	.while TRUE
		mov		[esi].VERSIONITEM.szname,0
		mov		[esi].VERSIONITEM.szvalue,0
		invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_GETTEXT,nInx,addr [esi].VERSIONITEM.szname
		.break .if eax==LB_ERR
		invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_GETITEMDATA,nInx,0
		invoke strcpy,addr [esi].VERSIONITEM.szvalue,eax
		lea		esi,[esi+sizeof VERSIONITEM]
		inc		nInx
	.endw
	pop		eax
	ret

GetVerNum:
	lea		edi,buffer
	call	GetVerNumItem
	mov		[esi],eax
	call	GetVerNumItem
	mov		[esi+4],eax
	call	GetVerNumItem
	mov		[esi+8],eax
	call	GetVerNumItem
	mov		[esi+12],eax
	retn

GetVerNumItem:
	invoke ResEdDecToBin,edi
	.while byte ptr [edi]!='.' && byte ptr [edi]
		inc		edi
	.endw
	.if byte ptr [edi]=='.'
		inc		edi
	.endif
	retn

SaveVersionEdit endp

VersionSetCbo proc uses esi,hWin:HWND,nID:DWORD,lpKey:DWORD,nVal:DWORD
	LOCAL	nInx:DWORD

	mov		esi,lpKey
	.while byte ptr [esi+4]
		push	[esi]
		add		esi,4
		invoke SendDlgItemMessage,hWin,nID,CB_ADDSTRING,0,esi
		pop		edx
		invoke SendDlgItemMessage,hWin,nID,CB_SETITEMDATA,eax,edx
		invoke strlen,esi
		lea		esi,[esi+eax+1]
	.endw
	mov		nInx,0
	.while TRUE
		invoke SendDlgItemMessage,hWin,nID,CB_GETITEMDATA,nInx,0
		.break .if eax==CB_ERR
		.if eax==nVal
			invoke SendDlgItemMessage,hWin,nID,CB_SETCURSEL,nInx,0
			.break
		.endif
		inc		nInx
	.endw
	ret

VersionSetCbo endp

EditProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==WM_CHAR
		.if wParam==VK_RETURN
			invoke GetParent,hWin
			invoke PostMessage,eax,WM_COMMAND,IDC_BTNVERADD,hWin
			xor		eax,eax
			ret
		.endif
	.endif
	invoke CallWindowProc,lpOldEditProc,hWin,uMsg,wParam,lParam
	ret

EditProc endp

VersionEditProc proc uses esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	rect:RECT
	LOCAL	fChanged:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hVerDlg,eax
		mov		fChanged,FALSE
		mov		esi,lParam
		invoke SetWindowLong,hWin,GWL_USERDATA,esi
		.if esi
			mov		esi,[esi].PROJECT.hmem
		.else
			invoke GetFreeProjectitemID,TPE_VERSION
			mov		esi,offset defver
			mov		[esi].VERSIONMEM.value,eax
			invoke strcpy,addr [esi].VERSIONMEM.szname,addr szVersionName
			invoke GetUnikeName,addr [esi].VERSIONMEM.szname
			mov		fChanged,TRUE
		.endif
		invoke RtlZeroMemory,offset szVersionTxt,sizeof szVersionTxt
		mov		lpResType,offset szVERSIONINFO
		lea		eax,[esi].VERSIONMEM.szname
		mov		lpResName,eax
		lea		eax,[esi].VERSIONMEM.value
		mov		lpResID,eax
		invoke SendDlgItemMessage,hWin,IDC_EDTVERFILE,EM_LIMITTEXT,16,0
		push	esi
		lea		esi,[esi].VERSIONMEM.fv
		call	ConvVer
		pop		esi
		invoke SetDlgItemText,hWin,IDC_EDTVERFILE,addr buffer
		invoke SendDlgItemMessage,hWin,IDC_EDTVERPROD,EM_LIMITTEXT,16,0
		push	esi
		lea		esi,[esi].VERSIONMEM.pv
		call	ConvVer
		pop		esi
		invoke SetDlgItemText,hWin,IDC_EDTVERPROD,addr buffer
		invoke VersionSetCbo,hWin,IDC_CBOVEROS,offset szVerOS,[esi].VERSIONMEM.os
		invoke VersionSetCbo,hWin,IDC_CBOVERTYPE,offset szVerFT,[esi].VERSIONMEM.ft
		invoke VersionSetCbo,hWin,IDC_CBOVERLANG,addr szVerLNG,[esi].VERSIONMEM.lng
		invoke VersionSetCbo,hWin,IDC_CBOVERCHAR,addr szVerCHS,[esi].VERSIONMEM.chs
		lea		esi,[esi+sizeof VERSIONMEM]
		mov		edi,offset szVerTpe
		.while byte ptr [edi]
			call	AddTpe
			invoke strlen,edi
			lea		edi,[edi+eax+1]
		.endw
		mov		edi,offset szVersionTxt
		.while [esi].VERSIONITEM.szname
			invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_ADDSTRING,0,addr [esi].VERSIONITEM.szname
			invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_SETITEMDATA,eax,edi
			invoke strcpy,edi,addr [esi].VERSIONITEM.szvalue
			add		edi,256
			lea		esi,[esi+sizeof VERSIONITEM]
		.endw
		invoke SendDlgItemMessage,hWin,IDC_EDTVER,EM_LIMITTEXT,255,0
		invoke SendDlgItemMessage,hWin,IDC_EDTVERTPE,EM_LIMITTEXT,63,0
		invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_SETCURSEL,0,0
		invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTVER,0
		invoke GetDlgItem,hWin,IDC_EDTVERTPE
		mov		edx,eax
		invoke SetWindowLong,edx,GWL_WNDPROC,addr EditProc
		mov		lpOldEditProc,eax
		invoke GetWindowLong,hWin,GWL_USERDATA
		.if !eax
			invoke SaveVersionEdit,hWin
			invoke SetWindowLong,hWin,GWL_USERDATA,eax
		.endif
		invoke PropertyList,-2
		mov		 fNoScroll,TRUE
    	invoke ShowScrollBar,hDEd,SB_BOTH,FALSE
		invoke SendMessage,hWin,WM_SIZE,0,0
		mov		eax,fChanged
		mov		fDialogChanged,eax
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SaveVersionEdit,hWin
				.if fDialogChanged
					invoke SendMessage,hRes,PRO_SETMODIFY,TRUE,0
					mov		fDialogChanged,FALSE
				.endif
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
				invoke PropertyList,0
			.elseif eax==IDC_BTNVERADD
				invoke SendDlgItemMessage,hWin,IDC_EDTVERTPE,WM_GETTEXT,sizeof buffer,addr buffer
				.if eax
					lea		edi,buffer
					invoke GetWindowLong,hWin,GWL_USERDATA
					.if eax
						mov		esi,[eax].PROJECT.hmem
					.else
						mov		esi,offset defver
					.endif
					lea		esi,[esi+sizeof VERSIONMEM]
					call	AddTpe
					invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_RESETCONTENT,0,0
					mov		edi,offset szVersionTxt
					mov		nInx,-1
					.while [esi].VERSIONITEM.szname
						invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_ADDSTRING,0,addr [esi].VERSIONITEM.szname
						invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_SETITEMDATA,eax,edi
						invoke strcpy,edi,addr [esi].VERSIONITEM.szvalue
						inc		nInx
						add		edi,256
						lea		esi,[esi+sizeof VERSIONITEM]
					.endw
					mov		buffer,0
					invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_SETCURSEL,nInx,0
					invoke SendDlgItemMessage,hWin,IDC_EDTVERTPE,WM_SETTEXT,0,addr buffer
					invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTVER,0
					invoke GetDlgItem,hWin,IDC_BTNVERADD
					invoke EnableWindow,eax,FALSE
				.endif
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTVER
				invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_GETITEMDATA,eax,0
				invoke SendDlgItemMessage,hWin,IDC_EDTVER,WM_GETTEXT,256,eax
			.elseif eax==IDC_EDTVERTPE
				invoke GetDlgItem,hWin,IDC_BTNVERADD
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_EDTVERTPE,WM_GETTEXTLENGTH,0,0
				pop		edx
				invoke EnableWindow,edx,eax
			.endif
			mov		fDialogChanged,TRUE
			invoke NotifyParent
		.elseif edx==LBN_SELCHANGE
			.if eax==IDC_LSTVER
				invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_GETITEMDATA,eax,0
					invoke SendDlgItemMessage,hWin,IDC_EDTVER,WM_SETTEXT,0,eax
				.endif
			.endif
			mov		fDialogChanged,TRUE
			invoke NotifyParent
		.endif
	.elseif eax==WM_CLOSE
		mov		 fNoScroll,FALSE
    	invoke ShowScrollBar,hDEd,SB_BOTH,TRUE
		invoke DestroyWindow,hWin
		mov		hVerDlg,0
	.elseif eax==WM_SIZE
		invoke SendMessage,hDEd,WM_VSCROLL,SB_THUMBTRACK,0
		invoke SendMessage,hDEd,WM_HSCROLL,SB_THUMBTRACK,0
		invoke GetClientRect,hDEd,addr rect
		mov		rect.left,3
		mov		rect.top,3
		sub		rect.right,6
		sub		rect.bottom,6
		invoke MoveWindow,hWin,rect.left,rect.top,rect.right,rect.bottom,TRUE
	.else
		mov eax,FALSE
		ret
	.endif
	mov  eax,TRUE
	ret

ConvVer:
	lea		edi,buffer
	invoke ResEdBinToDec,[esi],edi
	invoke strlen,edi
	lea		edi,[edi+eax]
	mov		al,'.'
	stosb
	invoke ResEdBinToDec,[esi+4],edi
	invoke strlen,edi
	lea		edi,[edi+eax]
	mov		al,'.'
	stosb
	invoke ResEdBinToDec,[esi+8],edi
	invoke strlen,edi
	lea		edi,[edi+eax]
	mov		al,'.'
	stosb
	invoke ResEdBinToDec,[esi+12],edi
	retn

AddTpe:
	push	esi
	.while [esi].VERSIONITEM.szname
		invoke strcmpi,addr [esi].VERSIONITEM.szname,edi
		.break .if !eax
		lea		esi,[esi+sizeof VERSIONITEM]
	.endw
	invoke strcpy,addr [esi].VERSIONITEM.szname,edi
	pop		esi
	retn

VersionEditProc endp
