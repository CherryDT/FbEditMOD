IDD_USERDATA				equ 2500
IDC_EDTUSERDATA				equ 1003

.data

szUserdataName		db 'IDR_',0
defuserdata			USERDATAMEM	<,1,0,,0>
					db 0

.code

ExportUserDataNames proc uses esi edi,hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*16
	mov     edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	;#define
    .if [esi].USERDATAMEM.sztype && [esi].USERDATAMEM.ntype
		invoke ExportName,addr [esi].USERDATAMEM.sztype,[esi].USERDATAMEM.ntype,edi
		lea		edi,[edi+eax]
	.endif
    .if [esi].USERDATAMEM.szname && [esi].USERDATAMEM.value
		invoke ExportName,addr [esi].USERDATAMEM.szname,[esi].USERDATAMEM.value,edi
		lea		edi,[edi+eax]
	.endif
	pop		eax
	ret

ExportUserDataNames endp

ExportUserData proc uses esi edi,hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16*1024
	mov		edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	;Name or ID
    .if [esi].USERDATAMEM.szname
    	invoke strcpy,edi,addr [esi].USERDATAMEM.szname
	.else
		invoke ResEdBinToDec,[esi].USERDATAMEM.value,edi
	.endif
	invoke strlen,edi
	add		edi,eax
	mov		al,' '
	stosb
	.if [esi].USERDATAMEM.sztype
	   	invoke strcpy,edi,addr [esi].USERDATAMEM.sztype
	.else
		invoke ResEdBinToDec,[esi].USERDATAMEM.value,edi
	.endif
	invoke strlen,edi
	add		edi,eax
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
	lea		edx,[esi+sizeof USERDATAMEM]
	.while byte ptr [edx]
		mov		al,[edx]
		mov		[edi],al
		inc		edi
		inc		edx
	.endw
	.if byte ptr [edi-1]!=0Ah
		mov		al,0Dh
		stosb
		mov		al,0Ah
		stosb
	.endif
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
	mov		byte ptr [edi],0
	pop		eax
	ret

ExportUserData endp

SaveUserDataEdit proc uses ebx esi edi, hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	mov		hMem,eax
	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		ebx,eax
	.if !ebx
		invoke SendMessage,hRes,PRO_ADDITEM,TPE_USERDATA,FALSE
		mov		ebx,eax
		invoke RtlMoveMemory,[ebx].PROJECT.hmem,offset defuserdata,sizeof USERDATAMEM+1
	.endif
	push	ebx
	invoke GetDlgItemText,hWin,IDC_EDTUSERDATA,hMem,60*1024
	mov		ecx,hMem
	mov		edx,[ebx].PROJECT.hmem
	lea		edx,[edx+sizeof USERDATAMEM]
	.while byte ptr [ecx]
		mov		al,[ecx]
		mov		[edx],al
		.if al==VK_RETURN
			inc		edx
			mov		byte ptr [edx],0Ah
		.endif
		inc		edx
		inc		ecx
	.endw
	mov		byte ptr [edx],0
	invoke GlobalFree,hMem
	invoke GetProjectItemName,ebx,addr buffer
	invoke SetProjectItemName,ebx,addr buffer
	pop		eax
	ret

SaveUserDataEdit endp

UserDataEditProc proc uses esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	fChanged:DWORD
	LOCAL	racol:RACOLOR

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		fChanged,FALSE
		mov		esi,lParam
		.if esi>=TPE_USERDATA && esi<=TPE_USERDATA+32
			lea		eax,[esi-32+11]
			mov		edx,sizeof RARSTYPE
			mul		edx
			lea		esi,[eax+offset rarstype]
			mov		edi,offset defuserdata
			invoke strcpy,addr [edi].USERDATAMEM.sztype,addr [esi].RARSTYPE.sztype
			mov		eax,[esi].RARSTYPE.nid
			mov		[edi].USERDATAMEM.ntype,eax
			invoke GetFreeProjectitemID,TPE_USERDATA
			mov		[edi].USERDATAMEM.value,eax
			invoke strcpy,addr [edi].USERDATAMEM.szname,addr szUserdataName
			invoke strcat,addr [edi].USERDATAMEM.szname,addr [esi].RARSTYPE.sztype
			invoke GetUnikeName,addr [edi].USERDATAMEM.szname
			invoke SaveUserDataEdit,hWin
			mov		esi,eax
			mov		fChanged,TRUE
		.endif
		invoke SetWindowLong,hWin,GWL_USERDATA,esi
		mov		edi,[esi].PROJECT.hmem
		.if ![edi].USERDATAMEM.hred
			push	edi
			invoke CreateWindowEx,200h,addr szRAEditClass,0,WS_CHILD or WS_VISIBLE or STYLE_NOSIZEGRIP or STYLE_NOCOLLAPSE,0,0,0,0,hWin,IDC_EDTUSERDATA,hInstance,0
			mov		hDlgRed,eax
			mov		edi,eax
			invoke SendMessage,edi,WM_SETFONT,hredfont,0
			invoke SendMessage,edi,REM_GETCOLOR,0,addr racol
			mov		eax,color.back
			mov		racol.bckcol,eax
			mov		racol.cmntback,eax
			mov		racol.strback,eax
			mov		racol.oprback,eax
			mov		racol.numback,eax
			mov		eax,color.text
			mov		racol.txtcol,eax
			mov		racol.strcol,0
			invoke SendMessage,edi,REM_SETCOLOR,0,addr racol
			invoke SendMessage,edi,REM_SETWORDGROUP,0,2
			pop		edi
			mov		eax,hDlgRed
			mov		[edi].USERDATAMEM.hred,eax
			invoke SetDlgItemText,hWin,IDC_EDTUSERDATA,addr [edi+sizeof USERDATAMEM]
			invoke SendDlgItemMessage,hWin,IDC_EDTUSERDATA,EM_SETMODIFY,FALSE,0
		.else
			mov		eax,[edi].USERDATAMEM.hred
			mov		hDlgRed,eax
			invoke SetParent,eax,hWin
			invoke ShowWindow,hDlgRed,SW_SHOW
		.endif
		lea		eax,[edi].USERDATAMEM.sztype
		mov		lpResType,eax
		lea		eax,[edi].USERDATAMEM.szname
		mov		lpResName,eax
		lea		eax,[edi].USERDATAMEM.value
		mov		lpResID,eax
		invoke PropertyList,-9
		mov		 fNoScroll,TRUE
    	invoke ShowScrollBar,hDEd,SB_BOTH,FALSE
		invoke SendMessage,hWin,WM_SIZE,0,0
		mov		eax,fChanged
		mov		fDialogChanged,eax
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendDlgItemMessage,hWin,IDC_EDTUSERDATA,EM_GETMODIFY,0,0
				.if eax
					mov		fDialogChanged,TRUE
					invoke SendDlgItemMessage,hWin,IDC_EDTUSERDATA,EM_SETMODIFY,FALSE,0
				.endif
				invoke SaveUserDataEdit,hWin
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
		mov		 fNoScroll,FALSE
    	invoke ShowScrollBar,hDEd,SB_BOTH,TRUE
		invoke DestroyWindow,hWin
	.elseif eax==WM_SIZE
		invoke SendMessage,hDEd,WM_VSCROLL,SB_THUMBTRACK,0
		invoke SendMessage,hDEd,WM_HSCROLL,SB_THUMBTRACK,0
		invoke GetClientRect,hDEd,addr rect
		mov		rect.left,3
		mov		rect.top,3
		sub		rect.right,6
		sub		rect.bottom,6
		invoke MoveWindow,hWin,rect.left,rect.top,rect.right,rect.bottom,TRUE
		invoke GetClientRect,hWin,addr rect
		invoke GetDlgItem,hWin,IDC_EDTUSERDATA
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

UserDataEditProc endp
