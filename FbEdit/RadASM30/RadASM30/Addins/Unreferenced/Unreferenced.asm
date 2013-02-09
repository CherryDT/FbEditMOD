;#########################################################################
;Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;Include file

include Unreferenced.inc

.code

OutputString proc uses ebx,lpString:DWORD

	mov		ebx,lpProc
	push	0
	call	[ebx].ADDINPROCS.lpSetOutputTab
	push	TRUE
	call	[ebx].ADDINPROCS.lpShowOutput
	push	lpString
	call	[ebx].ADDINPROCS.lpTextOutput
	ret

OutputString endp

LoadFiles proc uses ebx esi edi
	LOCAL	hProject:HWND
	LOCAL	hFile:HANDLE
	LOCAL	dwRead:DWORD
	LOCAL	hEdt:HWND

	push	0
	push	UAM_CLEARERRORS
	mov		eax,lpProc
	call	[eax].ADDINPROCS.lpUpdateAll
	mov		ebx,lpData
	mov		[ebx].ADDINDATA.nErrID,0
	mov		[ebx].ADDINDATA.ErrID,0
	mov		ebx,lpHandles
	mov		eax,[ebx].ADDINHANDLES.hProjectBrowser
	mov		hProject,eax
	invoke SendMessage,[ebx].ADDINHANDLES.hOutput,WM_SETTEXT,0,addr szNULL
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*sizeof FILES
	push	eax
	mov		edi,eax
	xor		ebx,ebx
	.while TRUE
		invoke SendMessage,hProject,RPBM_FINDNEXTITEM,ebx,0
		.break .if !eax
		mov		esi,eax
		mov		ebx,[esi].PBITEM.id
		.if [esi].PBITEM.lParam==ID_EDITCODE
			mov		[edi].FILES.pid,ebx
			lea		eax,[esi].PBITEM.szitem
			mov		[edi].FILES.lpFileName,eax
			mov		esi,[edi].FILES.lpFileName
			invoke OutputString,offset szLoading
			invoke lstrlen,esi
			.while byte ptr [esi+eax-1]!='\' && eax
				dec		eax
			.endw
			invoke OutputString,addr [esi+eax]
			invoke OutputString,offset szCR
			push	[edi].FILES.lpFileName
			push	UAM_ISOPEN
			mov		eax,lpProc
			call	[eax].ADDINPROCS.lpUpdateAll
			.if eax==-1
				;File is not open, Open the file
				invoke CreateFile,[edi].FILES.lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
				.if eax!=INVALID_HANDLE_VALUE
					mov		hFile,eax
					invoke GetFileSize,hFile,NULL
					push	eax
					shr		eax,12
					inc		eax
					shl		eax,12
					invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
					mov     [edi].FILES.hMem,eax
					pop		edx
					invoke ReadFile,hFile,[edi].FILES.hMem,edx,addr dwRead,NULL
					invoke CloseHandle,hFile
				.endif
			.else
				;File is open
				invoke GetWindowLong,eax,GWL_USERDATA
				mov		hEdt,eax
				invoke SendMessage,hEdt,WM_GETTEXTLENGTH,0,0
				inc		eax
				push	eax
				shr		eax,12
				inc		eax
				shl		eax,12
				invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
				mov		[edi].FILES.hMem,eax
				pop		eax
				invoke SendMessage,hEdt,WM_GETTEXT,eax,[edi].FILES.hMem
			.endif
			.if ![edi].FILES.hMem
				mov		[edi].FILES.pid,0
				mov		[edi].FILES.lpFileName,0
			.else
				lea		edi,[edi+sizeof FILES]
			.endif
		.endif
	.endw
	invoke OutputString,offset szCR
	pop		eax
	ret

LoadFiles endp

GetFileMemFromPid proc uses ebx esi edi,hMemFiles:HGLOBAL,pid:DWORD

	mov		esi,hMemFiles
	mov		eax,pid
	.while [esi].FILES.hMem
		.break .if eax==[esi].FILES.pid
		lea		esi,[esi+sizeof FILES]
	.endw
	mov		eax,[esi].FILES.hMem
	ret

GetFileMemFromPid endp

GetLinePtr proc uses esi,hMemFile:HGLOBAL,nLn:DWORD

	mov		esi,hMemFile
	.while byte ptr [esi] && nLn
		.if byte ptr [esi]==0Dh
			dec		nLn
			.if byte ptr [esi]==0Ah
				inc		esi
			.endif
		.endif
		inc		esi
	.endw
	mov		eax,esi
	ret

GetLinePtr endp

DestroyRegion proc uses esi edi,hMemFile:HGLOBAL,nLnStart:DWORD,nLnEnd:DWORD

	invoke GetLinePtr,hMemFile,nLnStart
	mov		esi,eax
	invoke GetLinePtr,hMemFile,nLnEnd
	mov		edi,eax
	.while esi<edi
		.if byte ptr [esi]!=0Dh && byte ptr [esi]!=0Ah
			mov		byte ptr [esi],' '
		.endif
		inc		esi
	.endw
	ret

DestroyRegion endp

DestroyGlobal proc uses esi edi,hMemFile:HGLOBAL,nLnStart:DWORD,lpWord:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	hProperty:HWND
	LOCAL	ms:MEMSEARCH

	invoke lstrcpyn,addr buffer,lpWord,sizeof buffer
	xor		eax,eax
	.while buffer[eax]
		.if buffer[eax]=='[' || buffer[eax]==':'
			mov		buffer[eax],0
			.break
		.endif
		inc		eax
	.endw
	mov		eax,lpHandles
	mov		eax,[eax].ADDINHANDLES.hProperty
	mov		hProperty,eax
	invoke GetLinePtr,hMemFile,nLnStart
	mov		ms.lpMem,eax
	lea		eax,buffer
	mov		ms.lpFind,eax
	mov		eax,lpData
	mov		eax,[eax].ADDINDATA.lpCharTab
	mov		ms.lpCharTab,eax
	mov		ms.fr,FR_DOWN or FR_WHOLEWORD or FR_MATCHCASE
	invoke SendMessage,hProperty,PRM_MEMSEARCH,0,addr ms
	.if eax
		mov		edi,eax
		invoke lstrlen,lpWord
		.while eax
			mov		byte ptr [edi],' '
			inc		edi
			dec		eax
		.endw
	.endif
	ret

DestroyGlobal endp

FixFiles proc uses ebx esi edi,hMemFiles:HGLOBAL
	LOCAL	hProperty:HWND
	LOCAL	nOwner:DWORD
	LOCAL	nLnStart:DWORD
	LOCAL	nLnEnd:DWORD
	LOCAL	ms:MEMSEARCH

	mov		edi,hMemFiles
	mov		eax,lpHandles
	mov		eax,[eax].ADDINHANDLES.hProperty
	mov		hProperty,eax
	.while [edi].FILES.hMem
		;Destroy comments and strings
		invoke SendMessage,hProperty,PRM_PREPARSE,FALSE,[edi].FILES.hMem
		lea		edi,[edi+sizeof FILES]
	.endw
	;Destroy structures
	invoke SendMessage,hProperty,PRM_FINDFIRST,addr szCCs,addr szNULL
	.while eax
		invoke SendMessage,hProperty,PRM_FINDGETOWNER,0,0
		mov		nOwner,eax
		invoke SendMessage,hProperty,PRM_FINDGETLINE,0,0
		mov		nLnStart,eax
		invoke SendMessage,hProperty,PRM_FINDGETENDLINE,0,0
		inc		eax
		mov		nLnEnd,eax
		invoke GetFileMemFromPid,hMemFiles,nOwner
		.if eax
			invoke DestroyRegion,eax,nLnStart,nLnEnd
		.endif
		invoke SendMessage,hProperty,PRM_FINDNEXT,0,0
	.endw
	;Destroy globals
	invoke SendMessage,hProperty,PRM_FINDFIRST,addr szCCd,addr szNULL
	.while eax
		mov		esi,eax
		invoke SendMessage,hProperty,PRM_FINDGETOWNER,0,0
		mov		nOwner,eax
		invoke SendMessage,hProperty,PRM_FINDGETLINE,0,0
		mov		nLnStart,eax
		invoke GetFileMemFromPid,hMemFiles,nOwner
		.if eax
			invoke DestroyGlobal,eax,nLnStart,esi
		.endif
		invoke SendMessage,hProperty,PRM_FINDNEXT,0,0
	.endw
	;Destroy local
	mov		edi,hMemFiles
	.while [edi].FILES.hMem
		mov		esi,[edi].FILES.hMem
		.while TRUE
			mov		ms.lpMem,esi
			mov		ms.lpFind,offset szLOCAL
			mov		eax,lpData
			mov		eax,[eax].ADDINDATA.lpCharTab
			mov		ms.lpCharTab,eax
			mov		ms.fr,FR_DOWN or FR_WHOLEWORD
			invoke SendMessage,hProperty,PRM_MEMSEARCH,0,addr ms
			.break .if !eax
			mov		esi,eax
			.while byte ptr [esi]!=0Dh && byte ptr [esi]
				mov		byte ptr [esi],' '
				inc		esi
			.endw
		.endw
		lea		edi,[edi+sizeof FILES]
	.endw
	ret

FixFiles endp

SetError proc uses ebx esi edi,hMemFiles:HGLOBAL,nOwner:DWORD,nLn:DWORD,lpErr:DWORD,lpName:DWORD,fLocal:DWORD
	LOCAL	ft:FINDTEXTEX
	LOCAL	nErr:DWORD

	mov		ebx,lpHandles
	invoke OutputString,lpErr
	invoke OutputString,lpName
	invoke OutputString,addr szCR
	mov		edi,hMemFiles
	mov		eax,nOwner
	.while [edi].FILES.hMem
		.if eax==[edi].FILES.pid
			;Open the file
			invoke SendMessage,[ebx].ADDINHANDLES.hWnd,WM_USER+998,0,[edi].FILES.lpFileName
			.if fLocal
				invoke SendMessage,[ebx].ADDINHANDLES.hEdt,EM_LINEINDEX,nLn,0
				mov		ft.chrg.cpMin,eax
				mov		ft.chrg.cpMax,-1
				mov		eax,lpName
				mov		ft.lpstrText,eax
				invoke SendMessage,[ebx].ADDINHANDLES.hEdt,EM_FINDTEXTEX,FR_DOWN or FR_MATCHCASE or FR_WHOLEWORD,addr ft
				.if eax!=-1
					invoke SendMessage,[ebx].ADDINHANDLES.hEdt,EM_EXLINEFROMCHAR,0,ft.chrgText.cpMin
					mov		nLn,eax
				.endif
			.endif
			invoke SendMessage,[ebx].ADDINHANDLES.hOutput,EM_GETLINECOUNT,0,0
			lea		esi,[eax-1]
			invoke SendMessage,[ebx].ADDINHANDLES.hOutput,REM_SETBOOKMARK,esi,6
			invoke SendMessage,[ebx].ADDINHANDLES.hEdt,REM_GETERROR,nLn,0
			.if eax
				mov		nErr,eax
				invoke SendMessage,[ebx].ADDINHANDLES.hOutput,REM_SETBMID,esi,nErr
			.else
				invoke SendMessage,[ebx].ADDINHANDLES.hOutput,REM_GETBMID,esi,0
				mov		nErr,eax
				invoke SendMessage,[ebx].ADDINHANDLES.hEdt,REM_SETERROR,nLn,nErr
			.endif
			mov		esi,lpData
			mov		edx,[esi].ADDINDATA.nErrID
			.if edx<255
				mov		eax,nErr
				mov		[esi].ADDINDATA.ErrID[edx*4],eax
				inc		edx
				mov		[esi].ADDINDATA.ErrID[edx*4],0
				mov		[esi].ADDINDATA.nErrID,edx
			.endif
			.break
		.endif
		lea		edi,[edi+sizeof FILES]
	.endw
	ret

SetError endp

FindGlobals proc uses ebx esi edi,hMemFiles:HGLOBAL
	LOCAL	hProperty:HWND
	LOCAL	ms:MEMSEARCH
	LOCAL	buffer[256]:BYTE
	LOCAL	nOwner:DWORD
	LOCAL	nLn:DWORD

	mov		nGlobal,0
	mov		ebx,lpHandles
	mov		eax,[ebx].ADDINHANDLES.hProperty
	mov		hProperty,eax
	invoke SendMessage,hProperty,PRM_FINDFIRST,addr szCCd,addr szNULL
	.while eax
		lea		esi,buffer
		invoke lstrcpyn,esi,eax,sizeof buffer
		invoke lstrlen,esi
		.while eax
			.if byte ptr [esi+eax]=='[' || byte ptr [esi+eax]==':'
				mov		byte ptr [esi+eax],0
			.endif
			dec		eax
		.endw
		invoke SendMessage,hProperty,PRM_FINDGETOWNER,0,0
		mov		nOwner,eax
		invoke SendMessage,hProperty,PRM_FINDGETLINE,0,0
		mov		nLn,eax
		mov		edi,hMemFiles
		.while [edi].FILES.hMem
			mov		eax,[edi].FILES.hMem
			mov		ms.lpMem,eax
			mov		ms.lpFind,esi
			mov		eax,lpData
			mov		eax,[eax].ADDINDATA.lpCharTab
			mov		ms.lpCharTab,eax
			mov		ms.fr,FR_DOWN or FR_WHOLEWORD or FR_MATCHCASE
			invoke SendMessage,hProperty,PRM_MEMSEARCH,0,addr ms
			.break .if eax
			lea		edi,[edi+sizeof FILES]
		.endw
		.if ![edi].FILES.hMem
			inc		nGlobal
			invoke SetError,hMemFiles,nOwner,nLn,addr szUnrefGlobal,esi,FALSE
		.endif
		invoke SendMessage,hProperty,PRM_FINDNEXT,0,0
	.endw
	ret

FindGlobals endp

FindLocals proc uses ebx esi edi,hMemFiles:HGLOBAL
	LOCAL	hProperty:HWND
	LOCAL	ms:MEMSEARCH
	LOCAL	buffer[256]:BYTE
	LOCAL	nOwner:DWORD
	LOCAL	nLnStart:DWORD
	LOCAL	lpStart:DWORD
	LOCAL	nLnEnd:DWORD
	LOCAL	lpEnd:DWORD

	mov		nLocal,0
	mov		ebx,lpHandles
	mov		eax,[ebx].ADDINHANDLES.hProperty
	mov		hProperty,eax
	invoke SendMessage,hProperty,PRM_FINDFIRST,addr szCCp,addr szNULL
	.while eax
		mov		esi,eax
		;Skip proc name
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
		;Skip parameters
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
		;Skip return type
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
		.if byte ptr [esi]
			invoke SendMessage,hProperty,PRM_FINDGETOWNER,0,0
			mov		nOwner,eax
			invoke SendMessage,hProperty,PRM_FINDGETLINE,0,0
			mov		nLnStart,eax
			invoke SendMessage,hProperty,PRM_FINDGETENDLINE,0,0
			inc		eax
			mov		nLnEnd,eax
			invoke GetFileMemFromPid,hMemFiles,nOwner
			mov		edi,eax
			invoke GetLinePtr,edi,nLnStart
			mov		lpStart,eax
			invoke GetLinePtr,edi,nLnEnd
			mov		lpEnd,eax
			.while byte ptr [esi]
				lea		edi,buffer
				.while byte ptr [esi]!='[' && byte ptr [esi]!=':' && byte ptr [esi]!=',' && byte ptr [esi]
					mov		al,[esi]
					mov		[edi],al
					inc		esi
					inc		edi
				.endw
				mov		byte ptr [edi],0
				.while byte ptr [esi]!=',' && byte ptr [esi]
					inc		esi
				.endw
				.if byte ptr [esi]==','
					inc		esi
				.endif
				mov		eax,lpStart
				mov		ms.lpMem,eax
				lea		eax,buffer
				mov		ms.lpFind,eax
				mov		eax,lpData
				mov		eax,[eax].ADDINDATA.lpCharTab
				mov		ms.lpCharTab,eax
				mov		ms.fr,FR_DOWN or FR_WHOLEWORD or FR_MATCHCASE
				invoke SendMessage,hProperty,PRM_MEMSEARCH,0,addr ms
				.if !eax || eax>lpEnd
					;Not found
					inc		nLocal
					invoke SetError,hMemFiles,nOwner,nLnStart,addr szUnrefLocal,addr buffer,TRUE
				.endif
			.endw
		.endif
		invoke SendMessage,hProperty,PRM_FINDNEXT,0,0
	.endw
	ret

FindLocals endp

ShowResult proc
	LOCAL	buffer[256]:BYTE

	invoke wsprintf,addr buffer,addr szGlobal,nGlobal
	invoke OutputString,addr buffer
	invoke OutputString,addr szCR
	invoke wsprintf,addr buffer,addr szLocal,nLocal
	invoke OutputString,addr buffer
	invoke OutputString,addr szCR
	ret

ShowResult endp

UpdateMenu proc hMnu:HMENU
	LOCAL	mii:MENUITEMINFO

	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_SUBMENU
	invoke GetMenuItemInfo,hMnu,IDM_TOOLS,FALSE,addr mii
	invoke AppendMenu,mii.hSubMenu,MF_STRING,IDAddIn,offset szMenuName
	ret

UpdateMenu endp

;#########################################################################
;Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax, hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

InstallAddin proc uses ebx hWin:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov		lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax
	; Allocate a new menu id
	invoke SendMessage,ebx,AIM_GETMENUID,0,0
	mov		IDAddIn,eax
	mov		hook.hook1,HOOK_COMMAND or HOOK_MENUUPDATE or HOOK_MENUENABLE
	xor		eax,eax
	mov		hook.hook2,eax
	mov		hook.hook3,eax
	mov		hook.hook4,eax
	mov		eax,offset hook
	ret 

InstallAddin Endp

; This proc handles messages sent from RadASM to our dll
; Return TRUE to prevent RadASM and other DLL's from further processing
AddinProc proc uses edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==AIM_COMMAND
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		.if edx==IDAddIn && eax==BN_CLICKED
			;Load all code files in the project
			invoke LoadFiles
			mov		edi,eax
			push	eax
			;Remove unwanted things from the files
			invoke FixFiles,edi
			;Find unreferenced global variables
			invoke FindGlobals,edi
			;Find unreferenced local variables
			invoke FindLocals,edi
			;Free the memory
			.while [edi].FILES.hMem
				invoke GlobalFree,[edi].FILES.hMem
				lea		edi,[edi+sizeof FILES]
			.endw
			pop		eax
			invoke GlobalFree,eax
			;Show result
			invoke ShowResult
			;Goto first error
			mov		eax,lpData
			.if [eax].ADDINDATA.ErrID
				mov		eax,lpHandles
				invoke SendMessage,[eax].ADDINHANDLES.hWnd,WM_COMMAND,IDM_EDIT_NEXTERROR,0
			.endif
			mov		eax,TRUE
			ret
		.endif
	.elseif eax==AIM_MENUUPDATE
		;Add our menu item
		invoke UpdateMenu,wParam
	.elseif eax==AIM_MENUENABLE
		.if wParam==IDM_TOOLS
			;Enable menu if a project is loaded
			mov		edx,lpData
			mov		eax,MF_BYCOMMAND or MF_GRAYED
			.if [edx].ADDINDATA.fProject
				mov		eax,MF_BYCOMMAND or MF_ENABLED
			.endif
			mov		edx,lpHandles
			invoke EnableMenuItem,[edx].ADDINHANDLES.hMenu,IDAddIn,eax
		.endif
	.endif
	mov		eax,FALSE
	ret

AddinProc Endp

;#########################################################################

End DllEntry
