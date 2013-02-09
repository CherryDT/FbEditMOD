
IDD_XPMANIFEST					equ 2000
IDC_EDTXPMANIFEST				equ 1002

.data

szManifestName		db 'IDR_XPMANIFEST',0
defxpmanifest		XPMANIFESTMEM	<,1,"xpmanifest.xml">
					db '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',0Dh,0Ah
					db '<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">',0Dh,0Ah
					db '<assemblyIdentity',0Dh,0Ah
					db 09h,'version="1.0.0.0"',0Dh,0Ah
					db 09h,'processorArchitecture="X86"',0Dh,0Ah
					db 09h,'name="Company.Product.Name"',0Dh,0Ah
					db 09h,'type="win32"',0Dh,0Ah
					db '/>',0Dh,0Ah
					db '<description></description>',0Dh,0Ah
					db '<dependency>',0Dh,0Ah
					db 09h,'<dependentAssembly>',0Dh,0Ah
					db 09h,09h,'<assemblyIdentity',0Dh,0Ah
					db 09h,09h,09h,'type="win32"',0Dh,0Ah
					db 09h,09h,09h,'name="Microsoft.Windows.Common-Controls"',0Dh,0Ah
					db 09h,09h,09h,'version="6.0.0.0"',0Dh,0Ah
					db 09h,09h,09h,'processorArchitecture="X86"',0Dh,0Ah
					db 09h,09h,09h,'publicKeyToken="6595b64144ccf1df"',0Dh,0Ah
					db 09h,09h,09h,'language="*"',0Dh,0Ah
					db 09h,09h,'/>',0Dh,0Ah
					db 09h,'</dependentAssembly>',0Dh,0Ah
					db '</dependency>',0Dh,0Ah
					db '</assembly>',0

.code

ExportXPManifestNames proc uses esi edi,hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*16
	mov     edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	;#define
    .if [esi].XPMANIFESTMEM.szname && [esi].XPMANIFESTMEM.value
		invoke SaveStr,edi,addr szDEFINE
		add		edi,eax
		mov		al,' '
		stosb
		invoke SaveStr,edi,addr [esi].XPMANIFESTMEM.szname
		add		edi,eax
		mov		al,' '
		stosb
		invoke ResEdBinToDec,[esi].XPMANIFESTMEM.value,edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,0Dh
		stosb
		mov		al,0Ah
		stosb
	.endif
;	mov		ax,0A0Dh
;	stosw
	mov		al,0
	stosb
	pop		eax
	ret

ExportXPManifestNames endp

ExportXPManifest proc uses esi edi,hMem:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16*1024
	mov		edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	;Name or ID
    .if [esi].XPMANIFESTMEM.szname
    	invoke strcpy,edi,addr [esi].XPMANIFESTMEM.szname
	.else
		invoke ResEdBinToDec,[esi].XPMANIFESTMEM.value,edi
	.endif
	invoke strlen,edi
	add		edi,eax
	mov		al,' '
	stosb
	invoke SaveStr,edi,addr szMANIFEST
	add		edi,eax
	lea		eax,[esi].XPMANIFESTMEM.szfilename
	.if byte ptr [esi].XPMANIFESTMEM.szfilename
		;Save as file
		mov		al,' '
		stosb
		mov		al,'"'
		stosb
		xor		ecx,ecx
		.while byte ptr [esi+ecx].XPMANIFESTMEM.szfilename
			mov		al,[esi+ecx].XPMANIFESTMEM.szfilename
			.if al=='\'
				mov		al,'/'
			.endif
			mov		[edi],al
			inc		ecx
			inc		edi
		.endw
		mov		al,'"'
		stosb
		invoke strcpy,addr buffer,addr szProjectPath
		invoke strcat,addr buffer,addr szBS
		invoke strcat,addr buffer,addr [esi].XPMANIFESTMEM.szfilename
		invoke CreateFile,addr buffer,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke strlen,addr [esi+sizeof XPMANIFESTMEM]
			mov		edx,eax
			invoke WriteFile,hFile,addr [esi+sizeof XPMANIFESTMEM],edx,addr nBytes,NULL
			invoke CloseHandle,hFile
		.endif
	.else
		mov		al,0Dh
		stosb
		mov		al,0Ah
		stosb
		invoke SaveStr,edi,addr szBEGIN
		add		edi,eax
		mov		al,0Dh
		stosb
		mov		al,0Ah
		stosb
		mov		al,'"'
		stosb
		lea		edx,[esi+sizeof XPMANIFESTMEM]
		.while byte ptr [edx]
			mov		al,[edx]
			.if al=='"'
				mov		[edi],al
				inc		edi
			.endif
			mov		[edi],al
			inc		edi
			inc		edx
		.endw
		mov		al,'"'
		stosb
		mov		al,0Dh
		stosb
		mov		al,0Ah
		stosb
		invoke SaveStr,edi,addr szEND
		add		edi,eax
	.endif
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		byte ptr [edi],0
	pop		eax
	ret

ExportXPManifest endp

XPManifestSave proc uses esi edi,hWin:HWND
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	rect:RECT

	invoke GetWindowLong,hWin,GWL_USERDATA
	.if !eax
		invoke SendMessage,hRes,PRO_ADDITEM,TPE_XPMANIFEST,FALSE
		push	eax
		invoke RtlMoveMemory,[eax].PROJECT.hmem,offset defxpmanifest,sizeof XPMANIFESTMEM+1024
		invoke SetDlgItemText,hWin,IDC_EDTXPMANIFEST,offset defxpmanifest+sizeof XPMANIFESTMEM
		pop		eax
	.endif
	push	eax
	mov		esi,[eax].PROJECT.hmem
	invoke GetDlgItemText,hWin,IDC_EDTXPMANIFEST,addr [esi+sizeof XPMANIFESTMEM],8192
	pop		esi
	push	esi
	invoke GetProjectItemName,esi,addr buffer
	invoke SetProjectItemName,esi,addr buffer
	invoke GetWindowLong,hPrj,0
	mov		esi,eax
	invoke FindName,esi,addr szMANIFEST
	.if !eax
		invoke AddName,esi,addr szMANIFEST,addr szManifestValue
	.endif
	pop		eax
	ret

XPManifestSave endp

XPManifestEditProc proc uses esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	fChanged:DWORD
	LOCAL	racol:RACOLOR

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		fChanged,FALSE
		invoke CreateWindowEx,200h,addr szRAEditClass,0,WS_CHILD or WS_VISIBLE or STYLE_NOSIZEGRIP or STYLE_NOLOCK or STYLE_NOCOLLAPSE,0,0,0,0,hWin,IDC_EDTXPMANIFEST,hInstance,0
		mov		hDlgRed,eax
		mov		edi,eax
		invoke SendMessage,edi,WM_SETFONT,hredfont,0
		invoke SendMessage,edi,REM_GETCOLOR,0,addr racol
		mov		eax,color.back
		mov		racol.bckcol,eax
		mov		eax,color.text
		mov		racol.txtcol,eax
		mov		racol.strcol,0
		invoke SendMessage,edi,REM_SETCOLOR,0,addr racol
		invoke SendMessage,edi,REM_SETWORDGROUP,0,2
		mov		esi,lParam
		invoke SetWindowLong,hWin,GWL_USERDATA,esi
		.if !esi
			invoke GetFreeProjectitemID,TPE_XPMANIFEST
			mov		edi,offset defxpmanifest
			mov		[edi].XPMANIFESTMEM.value,eax
			invoke strcpy,addr [edi].XPMANIFESTMEM.szname,addr szManifestName
			invoke GetUnikeName,addr [edi].XPMANIFESTMEM.szname
			invoke XPManifestSave,hWin
			mov		esi,eax
			invoke SetWindowLong,hWin,GWL_USERDATA,esi
			mov		fChanged,TRUE
		.endif
		mov		edi,[esi].PROJECT.hmem
		.if ![edi].XPMANIFESTMEM.hred
			mov		eax,hDlgRed
			mov		[edi].XPMANIFESTMEM.hred,eax
			invoke SetDlgItemText,hWin,IDC_EDTXPMANIFEST,addr [edi+sizeof XPMANIFESTMEM]
			invoke SendDlgItemMessage,hWin,IDC_EDTXPMANIFEST,EM_SETMODIFY,FALSE,0
		.else
			mov		eax,[edi].XPMANIFESTMEM.hred
			mov		hDlgRed,eax
			invoke SetParent,eax,hWin
			invoke ShowWindow,hDlgRed,SW_SHOW
		.endif
		mov		lpResType,offset szMANIFEST
		lea		eax,[edi].XPMANIFESTMEM.szname
		mov		lpResName,eax
		lea		eax,[edi].XPMANIFESTMEM.value
		mov		lpResID,eax
		lea		eax,[edi].XPMANIFESTMEM.szfilename
		mov		lpResFile,eax
		invoke PropertyList,-3
		invoke SendMessage,hWin,WM_SIZE,0,0
		mov		eax,fChanged
		mov		fDialogChanged,eax
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendDlgItemMessage,hWin,IDC_EDTXPMANIFEST,EM_GETMODIFY,0,0
				.if eax
					mov		fDialogChanged,TRUE
					invoke SendDlgItemMessage,hWin,IDC_EDTXPMANIFEST,EM_SETMODIFY,FALSE,0
				.endif
				invoke XPManifestSave,hWin
				.if fDialogChanged
					invoke SendMessage,hRes,PRO_SETMODIFY,TRUE,0
					mov		fDialogChanged,FALSE
				.endif
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
				invoke PropertyList,0
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke ShowWindow,hDlgRed,SW_HIDE
		invoke SetParent,hDlgRed,hRes
		mov		hDlgRed,0
		invoke DestroyWindow,hWin
	.elseif eax==WM_SIZE
		invoke GetClientRect,hDEd,addr rect
		mov		rect.left,3
		mov		rect.top,3
		sub		rect.right,6
		sub		rect.bottom,6
		invoke MoveWindow,hWin,rect.left,rect.top,rect.right,rect.bottom,TRUE
		invoke GetClientRect,hWin,addr rect
		invoke GetDlgItem,hWin,IDC_EDTXPMANIFEST
		mov		rect.left,3
		mov		rect.top,3
		sub		rect.right,6
		sub		rect.bottom,6
		invoke MoveWindow,eax,rect.left,rect.top,rect.right,rect.bottom,TRUE
	.elseif eax==WM_NOTIFY
		mov		eax,lParam
		mov		eax,[eax].NMHDR.hwndFrom
		.if eax==hDlgRed
			invoke NotifyParent
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

XPManifestEditProc endp
