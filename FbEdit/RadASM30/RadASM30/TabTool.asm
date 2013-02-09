.code

UpdateFileTime proc uses ebx,lpMem:DWORD
	LOCAL	hFile:DWORD

	mov		ebx,lpMem
	invoke CreateFile,addr [ebx].TABMEM.filename,GENERIC_READ,FILE_SHARE_READ or FILE_SHARE_WRITE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileTime,hFile,NULL,NULL,addr [ebx].TABMEM.ft
		invoke CloseHandle,hFile
	.endif
	ret

UpdateFileTime endp

ThreadProc proc uses ebx esi edi,Param:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	filet:FILETIME
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM

	mov		esi,fn.lpPath
	mov		edi,fn.lpHandle
	mov		ebx,fn.lpPtrPth
	.while [esi].FILENOTIFYPATH.path
		.if [esi].FILENOTIFYPATH.nCount
			invoke FindFirstChangeNotification,addr [esi].FILENOTIFYPATH.path,FALSE,FILE_NOTIFY_CHANGE_LAST_WRITE 
			mov		[edi],eax
			lea		eax,[esi].FILENOTIFYPATH.path
			mov		[ebx],eax
			add		edi,4
			add		ebx,4
			inc		fn.nCount
		.endif
		add		esi,sizeof FILENOTIFYPATH
	.endw
	.while TRUE
		; Wait for notification.		
		invoke WaitForMultipleObjects,fn.nCount,fn.lpHandle,FALSE,INFINITE
		.if eax<MAXIMUM_WAIT_OBJECTS
			mov		esi,fn.lpPtrPth
			lea		esi,[esi+eax*4]
			mov		edi,fn.lpHandle
			lea		edi,[edi+eax*4]
			mov		nInx,-1
			mov		tci.imask,TCIF_PARAM
			.while TRUE
				inc		nInx
				invoke SendMessage,ha.hTab,TCM_GETITEM,nInx,addr tci
				.break .if !eax
				mov		ebx,tci.lParam
				invoke strcpy,addr buffer,addr [ebx].TABMEM.filename
				invoke strlen,addr buffer
				.while eax
					.if byte ptr buffer[eax]=='\'
						mov		byte ptr buffer[eax],0
						.break
					.endif
					dec		eax
				.endw
				invoke lstrcmpi,addr buffer,[esi]
				.if !eax
					mov		eax,[ebx].TABMEM.ft.dwLowDateTime
					mov		filet.dwLowDateTime,eax
					mov		eax,[ebx].TABMEM.ft.dwHighDateTime
					mov		filet.dwHighDateTime,eax
					invoke UpdateFileTime,ebx
					invoke CompareFileTime,addr [ebx].TABMEM.ft,addr filet
					.if sdword ptr eax!=0 && ![ebx].TABMEM.fnonotify
						inc		[ebx].TABMEM.nchange
					.endif
				.endif
			.endw
			invoke FindNextChangeNotification,[edi]
			.if eax==FALSE
				.break
			.endif
		.elseif eax==WAIT_ABANDONED || eax==WAIT_TIMEOUT || eax==WAIT_FAILED
			.break
		.endif
	.endw
	ret

ThreadProc endp

CloseNotify proc uses esi

	.while fn.nCount
		invoke FindCloseChangeNotification,[esi]
		mov		dword ptr [esi],0
		add		esi,4
		dec		fn.nCount
	.endw
	.if fn.hThread
		invoke CloseHandle,fn.hThread
		mov		fn.hThread,0
	.endif
	ret

CloseNotify endp

SetNotify proc uses esi
	LOCAL	ThreadID:DWORD

	invoke CloseNotify
	xor		eax,eax
	mov		esi,fn.lpPath
	.while [esi].FILENOTIFYPATH.path
		.if [esi].FILENOTIFYPATH.nCount
			inc		eax
		.endif
		add		esi,sizeof FILENOTIFYPATH
	.endw
	.if eax
		invoke CreateThread,NULL,NULL,addr ThreadProc,0,NORMAL_PRIORITY_CLASS,addr ThreadID
		mov		fn.hThread,eax
	.endif
	ret

SetNotify endp

AddPath proc uses esi edi,lpFileName:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke strcpy,addr buffer,lpFileName
	invoke strlen,addr buffer
	.while eax
		.if byte ptr buffer[eax]=='\'
			mov		byte ptr buffer[eax],0
			.break
		.endif
		dec		eax
	.endw
	invoke GetFileAttributes,addr buffer
	.if eax!=INVALID_HANDLE_VALUE
		xor		edi,edi
		mov		esi,fn.lpPath
		.while [esi].FILENOTIFYPATH.path
			.if [esi].FILENOTIFYPATH.nCount
				invoke strcmp,addr [esi].FILENOTIFYPATH.path,addr buffer
				or		eax,eax
				je		Found
			.elseif !edi
				mov		edi,esi
			.endif
			add		esi,sizeof FILENOTIFYPATH
		.endw
		.if edi
			mov		esi,edi
		.endif
		invoke strcpy,addr [esi].FILENOTIFYPATH.path,addr buffer
	  Found:
		inc		[esi].FILENOTIFYPATH.nCount
		.if [esi].FILENOTIFYPATH.nCount==1
			invoke SetNotify
		.endif
	.endif
	ret

AddPath endp

DelPath proc uses esi,lpFileName:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke strcpy,addr buffer,lpFileName
	invoke strlen,addr buffer
	.while eax
		.if byte ptr buffer[eax]=='\'
			mov		byte ptr buffer[eax],0
			.break
		.endif
		dec		eax
	.endw
	invoke GetFileAttributes,addr buffer
	.if eax!=INVALID_HANDLE_VALUE
		mov		esi,fn.lpPath
		.while [esi].FILENOTIFYPATH.path
			.if [esi].FILENOTIFYPATH.nCount
				invoke strcmp,addr [esi].FILENOTIFYPATH.path,addr buffer
				or		eax,eax
				je		Found
			.endif
			add		esi,sizeof FILENOTIFYPATH
		.endw
	.endif
	ret
  Found:
	dec		[esi].FILENOTIFYPATH.nCount
	.if ![esi].FILENOTIFYPATH.nCount
		invoke SetNotify
	.endif
	ret

DelPath endp

TabToolGetMem proc uses ebx,hWin:DWORD
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM

	mov		nInx,-1
	mov		tci.imask,TCIF_PARAM
	mov		eax,TRUE
	xor		ebx,ebx
	.while eax
		inc		nInx
		invoke SendMessage,ha.hTab,TCM_GETITEM,nInx,addr tci
		.if eax
			mov		ebx,tci.lParam
			mov		eax,[ebx].TABMEM.hwnd
			.break .if eax==hWin
		.endif
	.endw
	mov		eax,ebx
	ret

TabToolGetMem endp

TabToolGetInx proc uses ebx,hWin:DWORD
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM

	mov		nInx,-1
	mov		tci.imask,TCIF_PARAM
	mov		eax,TRUE
	.while eax
		inc		nInx
		invoke SendMessage,ha.hTab,TCM_GETITEM,nInx,addr tci
		.if eax
			mov		ebx,tci.lParam
			mov		eax,[ebx].TABMEM.hwnd
			.break .if eax==hWin
		.else
			mov		nInx,-1
		.endif
	.endw
	mov		eax,nInx
	ret

TabToolGetInx endp

TabToolGetInxFromPid proc uses ebx,pid:DWORD
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM

	mov		nInx,-1
	mov		tci.imask,TCIF_PARAM
	mov		eax,TRUE
	.while eax
		inc		nInx
		invoke SendMessage,ha.hTab,TCM_GETITEM,nInx,addr tci
		.if eax
			mov		ebx,tci.lParam
			mov		eax,[ebx].TABMEM.pid
			.break .if eax==pid
		.else
			mov		nInx,-1
		.endif
	.endw
	mov		eax,nInx
	ret

TabToolGetInxFromPid endp

TabToolSetText proc nInx:DWORD,lpFileName:DWORD
	LOCAL	tci:TC_ITEM

	mov		tci.imask,TCIF_PARAM
	invoke SendMessage,ha.hTab,TCM_GETITEM,nInx,addr tci
	mov		eax,tci.lParam
	invoke strcpy,addr [eax].TABMEM.filename,lpFileName
	invoke strlen,lpFileName
	mov		ecx,eax
	mov		edx,lpFileName
	.while ecx
		mov		al,[edx+ecx-1]
		.break .if al=='\'
		dec		ecx
	.endw
	lea		eax,[edx+ecx]
	mov		tci.pszText,eax
	mov		tci.imask,TCIF_TEXT
	invoke SendMessage,ha.hTab,TCM_SETITEM,nInx,addr tci
	ret

TabToolSetText endp

TabToolSetChanged proc uses ebx,hWin:DWORD,fChanged:DWORD
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM
	LOCAL	buffer[256]:BYTE

	mov		nInx,-1
	mov		tci.imask,TCIF_PARAM or TCIF_TEXT
	lea		eax,buffer
	mov		tci.pszText,eax
	mov		tci.cchTextMax,sizeof buffer
	mov		eax,TRUE
	.while eax
		inc		nInx
		invoke SendMessage,ha.hTab,TCM_GETITEM,nInx,addr tci
		.if eax
			mov		ebx,tci.lParam
			mov		eax,[ebx].TABMEM.hwnd
			.break .if eax==hWin
		.endif
	.endw
	invoke strlen,addr buffer
	.if fChanged
		.if buffer[eax-1]!='*'
			mov		word ptr buffer[eax],'*'
		.endif
		mov		[ebx].TABMEM.fchanged,TRUE
	.else
		.if buffer[eax-1]=='*'
			mov		byte ptr buffer[eax-1],0
		.endif
		mov		[ebx].TABMEM.fchanged,FALSE
	.endif
	mov		tci.imask,TCIF_TEXT
	invoke SendMessage,ha.hTab,TCM_SETITEM,nInx,addr tci
	mov		eax,nInx
	ret

TabToolSetChanged endp

TabToolActivate proc uses ebx
	LOCAL	tci:TC_ITEM

	invoke SendMessage,ha.hTab,TCM_GETCURSEL,0,0
	mov		tci.imask,TCIF_PARAM
	mov		edx,eax
	invoke SendMessage,ha.hTab,TCM_GETITEM,edx,addr tci
	mov		ebx,tci.lParam
	mov		eax,[ebx].TABMEM.hwnd
	mov		ha.hMdi,eax
	mov		eax,[ebx].TABMEM.hedt
	mov		ha.hEdt,eax
	invoke strcpy,offset da.szFileName,addr [ebx].TABMEM.filename
	mov		da.fTimer,1
	invoke SendMessage,ha.hFileBrowser,FBM_SETSELECTED,0,addr [ebx].TABMEM.filename
	invoke GetWindowLong,ha.hEdt,GWL_ID
	.if da.fProject
		invoke SendMessage,ha.hProjectBrowser,RPBM_SETSELECTED,0,addr da.szFileName
	.endif
	invoke SendMessage,ha.hClient,WM_MDIACTIVATE,ha.hMdi,0
	ret

TabToolActivate endp

TabToolAdd proc uses ebx esi,hWin:HWND,lpFileName:DWORD
	LOCAL	tci:TC_ITEM
	LOCAL	tpe[32]:BYTE
	LOCAL	buffer[64*4]:BYTE
	LOCAL	types[64]:BYTE

	invoke GetProcessHeap
	invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof TABMEM
	mov		ebx,eax
	mov		eax,hWin
	mov		[ebx].TABMEM.hwnd,eax
	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		[ebx].TABMEM.hedt,eax
	invoke SetWindowLong,[ebx].TABMEM.hedt,GWL_USERDATA,ebx
	mov		esi,lpFileName
	invoke strcpy,addr [ebx].TABMEM.filename,esi
	;Get filename
	invoke strlen,esi
	.while eax && byte ptr [esi+eax-1]!='\'
		dec		eax
	.endw
	mov		tci.imask,TCIF_TEXT or TCIF_PARAM or TCIF_IMAGE
	lea		esi,[esi+eax]
	mov		tci.pszText,esi
	mov		tci.cchTextMax,20
	;Get filetype
	invoke strlen,esi
	.while eax && byte ptr [esi+eax]!='.'
		dec		eax
	.endw
	.if byte ptr [esi+eax]=='.'
		invoke strcpy,addr tpe,addr [esi+eax]
		invoke strcat,addr tpe,addr szDot
		invoke strcpy,addr buffer,addr da.szTypes
		xor		esi,esi
		.while buffer
			invoke GetItemStr,addr buffer,addr szNULL,addr types,sizeof types
			invoke IsFileType,addr tpe,addr types
			.break .if eax
			inc		esi
		.endw
		.if !esi
			;asm
			mov		esi,2
		.elseif esi==1
			;inc
			mov		esi,3
		.elseif esi==2
			;rc
			mov		esi,4
		.elseif esi==3
			;txt
			mov		esi,5
		.elseif eax==4
			;exe
			mov		esi,6
		.elseif esi==5
			;bat
			mov		esi,7
		.else
			;txt
			mov		esi,5
		.endif
	.else
		;txt
		mov		esi,5
	.endif
	mov		tci.iImage,esi
	mov		tci.lParam,ebx
	invoke SendMessage,ha.hTab,TCM_INSERTITEM,999,addr tci
	invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
	invoke UpdateFileTime,ebx
	invoke AddPath,lpFileName
	.if da.fProject
		invoke SendMessage,ha.hProjectBrowser,RPBM_FINDITEM,0,lpFileName
		.if eax
			mov		eax,[eax].PBITEM.id
			mov		[ebx].TABMEM.pid,eax
		.else
			invoke AddMRU,addr da.szMruFiles,lpFileName
			invoke UpdateMRUMenu,addr da.szMruFiles
		.endif
	.else
		invoke AddMRU,addr da.szMruFiles,lpFileName
		invoke UpdateMRUMenu,addr da.szMruFiles
	.endif
	mov		eax,ebx
	ret

TabToolAdd endp

TabToolDel proc uses ebx,hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM

	mov		nInx,-1
	mov		tci.imask,TCIF_PARAM
	mov		eax,TRUE
	.while eax
		inc		nInx
		invoke SendMessage,ha.hTab,TCM_GETITEM,nInx,addr tci
		.if eax
			mov		ebx,tci.lParam
			mov		eax,[ebx].TABMEM.hwnd
			.if eax==hWin
				invoke DelPath,addr [ebx].TABMEM.filename
				invoke SendMessage,ha.hTab,TCM_DELETEITEM,nInx,0
				invoke GetProcessHeap
				invoke HeapFree,eax,NULL,ebx
				xor eax,eax
			.endif
		.endif
	.endw
	ret

TabToolDel endp

TabProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ht:TC_HITTESTINFO
	LOCAL	tci:TC_ITEM
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_RBUTTONDOWN
		mov		eax,lParam
		movzx	edx,ax
		shr		eax,16
		mov		ht.pt.x,edx
		mov		ht.pt.y,eax
		invoke SendMessage,hWin,TCM_HITTEST,0,addr ht
		.if eax!=-1
			invoke SendMessage,hWin,TCM_SETCURSEL,eax,0
			invoke TabToolActivate
			invoke SetFocus,ha.hMdi
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_MBUTTONDOWN
		mov		eax,lParam
		movzx	edx,ax
		shr		eax,16
		mov		ht.pt.x,edx
		mov		ht.pt.y,eax
		invoke SendMessage,hWin,TCM_HITTEST,0,addr ht
		.if eax!=-1
			mov		da.tabinx,eax
			invoke SendMessage,hWin,TCM_SETCURSEL,eax,0
			invoke TabToolActivate
			invoke SetFocus,ha.hMdi
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_MBUTTONUP
		mov		eax,lParam
		movzx	edx,ax
		shr		eax,16
		mov		ht.pt.x,edx
		mov		ht.pt.y,eax
		invoke SendMessage,hWin,TCM_HITTEST,0,addr ht
		.if eax==da.tabinx
			invoke SendMessage,ha.hWnd,WM_COMMAND,IDM_FILE_CLOSE,0
		.endif
		mov		da.tabinx,-2
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_LBUTTONDOWN
		mov		eax,lParam
		movzx	edx,ax
		shr		eax,16
		mov		ht.pt.x,edx
		mov		ht.pt.y,eax
		invoke SendMessage,hWin,TCM_HITTEST,0,addr ht
		.if eax!=-1
			mov		da.tabinx,eax
			invoke SendMessage,hWin,TCM_SETCURSEL,eax,0
			invoke TabToolActivate
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_LBUTTONDBLCLK
		mov		eax,lParam
		movzx	edx,ax
		shr		eax,16
		mov		ht.pt.x,edx
		mov		ht.pt.y,eax
		invoke SendMessage,hWin,TCM_HITTEST,0,addr ht
		.if eax==da.tabinx
			invoke SendMessage,ha.hWnd,WM_COMMAND,IDM_FILE_CLOSE,0
		.endif
		mov		da.tabinx,-2
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_MOUSEMOVE
		test	wParam,MK_LBUTTON
		.if !ZERO?
			mov		eax,lParam
			movzx	edx,ax
			shr		eax,16
			mov		ht.pt.x,edx
			mov		ht.pt.y,eax
			invoke SendMessage,hWin,TCM_GETITEMRECT,da.tabinx,addr rect
			mov		eax,rect.right
			sub		eax,rect.left
			shr		eax,1
			sub		rect.left,eax
			add		rect.right,eax
			mov		eax,rect.bottom
			sub		eax,rect.top
			shr		eax,1
			sub		rect.top,eax
			add		rect.bottom,eax

			mov		eax,ht.pt.x
			mov		edx,ht.pt.y
			.if sdword ptr eax<rect.left || sdword ptr eax>rect.right || sdword ptr edx<rect.top || sdword ptr edx>rect.bottom
				invoke SendMessage,hWin,TCM_HITTEST,0,addr ht
				.if eax!=da.tabinx && sdword ptr eax>=0 && sdword ptr da.tabinx>=0
					push	eax
					mov		tci.imask,TCIF_TEXT Or TCIF_IMAGE Or TCIF_PARAM
					lea		eax,buffer
					mov		tci.pszText,eax
					mov		tci.cchTextMax,MAX_PATH
					invoke SendMessage,hWin,TCM_GETITEM,da.tabinx,addr tci
					invoke SendMessage,hWin,TCM_DELETEITEM,da.tabinx,0
					pop		da.tabinx
					invoke SendMessage,hWin,TCM_INSERTITEM,da.tabinx,addr tci
				.endif
			.endif
			xor		eax,eax
			ret
		.endif
	.endif
	invoke CallWindowProc,lpOldTabProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

TabProc endp
