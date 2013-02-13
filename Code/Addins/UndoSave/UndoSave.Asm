;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include UndoSave.inc

.code

SaveUndo proc uses ebx esi edi,hREd:HWND,pfid:DWORD
	LOCAL	hFile:HANDLE
	LOCAL	ft:FILETIME

	mov		eax,pfid
	mov		edx,sizeof UNDOSAVE
	mul		edx
	mov		edi,offset us
	lea		edi,[edi+eax]
	.if [edi].UNDOSAVE.hmem
		invoke GlobalFree,[edi].UNDOSAVE.hmem
	.endif
	invoke RtlZeroMemory,edi,sizeof UNDOSAVE
	invoke SendMessage,hREd,REM_GETUNDO,1000,0
	.if eax
		mov		[edi].UNDOSAVE.nsize,eax
		mov		eax,pfid
		mov		[edi].UNDOSAVE.pfid,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,[edi].UNDOSAVE.nsize
		mov		[edi].UNDOSAVE.hmem,eax
		invoke SendMessage,hREd,REM_GETUNDO,1000,[edi].UNDOSAVE.hmem
		; Get file time
		mov		eax,lpData
		invoke CreateFile,addr [eax].ADDINDATA.filename,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
		mov		hFile,eax
		invoke GetFileTime,hFile,NULL,NULL,addr ft
		invoke CloseHandle,hFile
		invoke FileTimeToDosDateTime,addr ft,addr [edi].UNDOSAVE.dft+2,addr [edi].UNDOSAVE.dft
	.endif
	ret

SaveUndo endp

LoadUndo proc uses ebx esi edi,hREd:HWND,pfid:DWORD
	LOCAL	hFile:HANDLE
	LOCAL	ft:FILETIME
	LOCAL	dft:DWORD


	mov		eax,pfid
	mov		edx,sizeof UNDOSAVE
	mul		edx
	mov		esi,offset us
	lea		esi,[esi+eax]
	.if [esi].UNDOSAVE.hmem
		mov		eax,lpData
		invoke CreateFile,addr [eax].ADDINDATA.filename,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
		mov		hFile,eax
		invoke GetFileTime,hFile,NULL,NULL,addr ft
		invoke CloseHandle,hFile
		invoke FileTimeToDosDateTime,addr ft,addr dft+2,addr dft
		mov		eax,[esi].UNDOSAVE.dft
		.if eax==dft
			invoke SendMessage,hREd,REM_SETUNDO,[esi].UNDOSAVE.nsize,[esi].UNDOSAVE.hmem
		.else
			invoke GlobalFree,[esi].UNDOSAVE.hmem
			invoke RtlZeroMemory,esi,sizeof UNDOSAVE
		.endif
	.endif
	ret

LoadUndo endp

GetUndo proc uses ebx esi edi
	LOCAL	hFile:HANDLE
	LOCAL	nSize:DWORD
	LOCAL	hMem:HGLOBAL
	LOCAL	dwread:DWORD

	invoke CreateFile,addr usFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		mov		nSize,eax
		invoke GlobalAlloc,GMEM_FIXED,nSize
		mov		hMem,eax
		invoke ReadFile,hFile,hMem,nSize,addr dwread,NULL
		invoke CloseHandle,hFile
		mov		esi,hMem
		xor		ebx,ebx
		.while ebx<nSize
			mov		eax,[esi].UNDOSAVE.pfid
			mov		edx,sizeof UNDOSAVE
			mul		edx
			mov		edi,offset us
			lea		edi,[edi+eax]
			mov		eax,[esi].UNDOSAVE.pfid
			mov		[edi].UNDOSAVE.pfid,eax
			mov		eax,[esi].UNDOSAVE.dft
			mov		[edi].UNDOSAVE.dft,eax
			mov		eax,[esi].UNDOSAVE.nsize
			mov		[edi].UNDOSAVE.nsize,eax
			invoke GlobalAlloc,GMEM_FIXED,eax
			mov		[edi].UNDOSAVE.hmem,eax
			invoke RtlMoveMemory,[edi].UNDOSAVE.hmem,addr [esi+sizeof UNDOSAVE],[esi].UNDOSAVE.nsize
			mov		eax,[esi].UNDOSAVE.nsize
			lea		ebx,[ebx+eax+sizeof UNDOSAVE]
			lea		esi,[esi+eax+sizeof UNDOSAVE]
		.endw
		invoke GlobalFree,hMem
	.endif
	ret

GetUndo endp

PutUndo proc uses ebx esi edi
	LOCAL	hFile:HANDLE
	LOCAL	nSize:DWORD
	LOCAL	dwwritten:DWORD

	invoke CreateFile,addr usFileName,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		xor		ebx,ebx
		mov		esi,offset us
		.while ebx<2048
			.if [esi].UNDOSAVE.hmem
				invoke WriteFile,hFile,esi,sizeof UNDOSAVE,addr dwwritten,NULL
				invoke WriteFile,hFile,[esi].UNDOSAVE.hmem,[esi].UNDOSAVE.nsize,addr dwwritten,NULL
				invoke GlobalFree,[esi].UNDOSAVE.hmem
			.endif
			lea		esi,[esi+sizeof UNDOSAVE]
			inc		ebx
		.endw
		invoke CloseHandle,hFile
		invoke RtlZeroMemory,addr us,sizeof us
	.endif
	ret

PutUndo endp

GetProjectFileID proc uses ebx esi edi,hREd:HWND
	LOCAL	tci:TC_ITEM

	mov		ebx,lpHandles
	mov		ebx,[ebx].ADDINHANDLES.htabtool
	mov		tci.imask,TCIF_PARAM
	xor		edi,edi
	.while TRUE
		invoke SendMessage,ebx,TCM_GETITEM,edi,addr tci
		.break .if !eax
		mov		esi,tci.lParam
		mov		eax,[esi].TABMEM.hedit
		.if eax==hREd
			mov		eax,[esi].TABMEM.profileinx
			ret
		.endif
		inc		edi
	.endw
	ret

GetProjectFileID endp

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx,hWin:DWORD,hInst:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0
	mov		lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETFUNCTIONS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax
	mov		eax,[eax].ADDINDATA.version
	.if eax>=1074
		; Messages to hook into
		mov		hook.hook1,HOOK_COMMAND or HOOK_PROJECTCLOSE or HOOK_FILEOPENNEW or HOOK_FILESAVED or HOOK_PROJECTREMOVE or HOOK_PROJECTTOGGLE
	.endif
	mov		eax,offset hook
	ret

InstallDll Endp

DllFunction proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==AIM_COMMAND
		mov		eax,wParam
		movzx	edx,ax
		shr		eax, 16
		.if edx==IDM_EDIT_EMPTYUNDO && eax==BN_CLICKED
			mov		eax,lpData
			.if [eax].ADDINDATA.ProjectFile
				mov		eax,lpHandles
				invoke GetProjectFileID,[eax].ADDINHANDLES.hred
				.if sdword ptr eax>0 && eax<2048
					mov		edx,sizeof UNDOSAVE
					mul		edx
					mov		edx,offset us
					lea		edx,[edx+eax]
					.if [edx].UNDOSAVE.hmem
						push	edx
						invoke GlobalFree,[edx].UNDOSAVE.hmem
						pop		edx
						invoke RtlZeroMemory,edx,sizeof UNDOSAVE
					.endif
				.endif
			.endif
		.endif
	.elseif eax==AIM_FILEOPENNEW
		mov		eax,lpData
		.if [eax].ADDINDATA.ProjectFile
			.if !usFileName
				; Load undo information from [PROJECTNAME].undo
				mov		eax,lpData
				invoke lstrcpy,addr usFileName,addr [eax].ADDINDATA.ProjectFile
				invoke lstrlen,addr usFileName
				invoke lstrcpy,addr usFileName[eax-3],addr szUndo
				invoke GetUndo
			.endif
			invoke GetWindowLong,wParam,GWL_ID
			.if eax==IDC_CODEED
				invoke GetProjectFileID,wParam
				.if sdword ptr eax>0
					; Load undo information from ram
					invoke LoadUndo,wParam,eax
				.endif
			.endif
		.endif
	.elseif eax==AIM_FILESAVED
		mov		eax,lpData
		.if [eax].ADDINDATA.ProjectFile
			invoke GetWindowLong,wParam,GWL_ID
			.if eax==IDC_CODEED
				invoke GetProjectFileID,wParam
				.if sdword ptr eax>0
					; Save undo information to ram
					invoke SaveUndo,wParam,eax
				.endif
			.endif
		.endif
	.elseif eax==AIM_PROJECTCLOSE
		; Save undo information to [PROJECTNAME].undo
		invoke PutUndo
		mov		usFileName,0
	.elseif eax==AIM_PROJECTREMOVE
		; A project file is removed, delete undo information
		mov		eax,wParam
		.if eax<2048
			mov		edx,sizeof UNDOSAVE
			mul		edx
			mov		edx,offset us
			lea		edx,[edx+eax]
			.if [edx].UNDOSAVE.hmem
				push	edx
				invoke GlobalFree,[edx].UNDOSAVE.hmem
				pop		edx
				invoke RtlZeroMemory,edx,sizeof UNDOSAVE
			.endif
		.endif
	.elseif eax==AIM_PROJECTTOGGLE
		; A project file is toggled, move undo information
		.if wParam<2048 && lParam<2048
			push	esi
			push	edi
			mov		eax,wParam
			mov		edx,sizeof UNDOSAVE
			mul		edx
			mov		esi,offset us
			lea		esi,[esi+eax]
			mov		eax,lParam
			mov		edx,sizeof UNDOSAVE
			mul		edx
			mov		edi,offset us
			lea		edi,[edi+eax]
			invoke RtlMoveMemory,edi,esi,sizeof UNDOSAVE
			invoke RtlZeroMemory,esi,sizeof UNDOSAVE
			mov		eax,lParam
			mov		[edi].UNDOSAVE.pfid,eax
			pop		edi
			pop		esi
		.endif
	.endif
	mov		eax,FALSE
	ret

DllFunction Endp

;#########################################################################

end DllEntry
