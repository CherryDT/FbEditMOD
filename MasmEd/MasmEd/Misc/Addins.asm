
MAX_ADDIN				equ 32

ADDIN struct
	hDLL			dd ?
	fhook1			dd ?
	fhook2			dd ?
	fhook3			dd ?
	fhook4			dd ?
	lpAddinProc		dd ?
ADDIN ends

.const

szDll					db '\Addins\*.dll',0
szInstallAddin			db 'InstallAddin',0
szAddinProc				db 'AddinProc',0

.data?

addin					ADDIN MAX_ADDIN dup(<>)

.code

PostAddinMessage proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM,nHook:DWORD,fHook:DWORD
	LOCAL	nInx:DWORD
	LOCAL	espsave:DWORD

	mov		nInx,0
	mov		edi,offset addin
	xor		eax,eax
	.while nInx<MAX_ADDIN && !eax
		.break .if ![edi].ADDIN.hDLL
		.if dword ptr [edi].ADDIN.lpAddinProc
			mov		edx,nHook
			mov		edx,[edi].ADDIN.fhook1[edx*4]
			and		edx,fHook
			.if edx
				push	edi
				mov		espsave,esp
				push	lParam
				push	wParam
				push	uMsg
				push	hWin
				call	[edi].ADDIN.lpAddinProc
				mov		esp,espsave
				pop		edi
			.endif
		.endif
		add		edi,sizeof ADDIN
		inc		nInx
	.endw
	ret

PostAddinMessage endp

IsAddin proc lpFileName:DWORD
	LOCAL	hDll:DWORD
	LOCAL	val:DWORD

	invoke LoadLibrary,lpFileName
	.if eax
		mov		hDll,eax
		invoke GetProcAddress,hDll,addr szInstallAddin
		.if eax
			;It is an addin, should it be loaded?
			invoke strlen,lpFileName
			add		eax,lpFileName
			.while byte ptr [eax-1]!='\'
				dec		eax
			.endw
			mov		edx,eax
			mov		val,1
			mov		lpcbData,sizeof val
			invoke RegQueryValueEx,ha.hReg,edx,0,addr lpType,addr val,addr lpcbData
			mov		eax,hDll
			.if !val
				;Should not be loaded
				invoke FreeLibrary,eax
				xor		eax,eax
			.endif
		.else
			;Not an addin
			invoke FreeLibrary,hDll
			xor		eax,eax
		.endif
	.endif
	ret

IsAddin endp

LoadAddins proc uses esi,hWin:HWND
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	wfd:WIN32_FIND_DATA
	LOCAL	hwfd:DWORD
	LOCAL	hDll:DWORD
	LOCAL	nInx

	mov		nInx,0
	mov		esi,offset addin
	invoke strcpy,addr buffer,addr da.AppPath
	invoke strcat,addr buffer,addr szDll
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		mov		hwfd,eax
	  Next:
		.if nInx<MAX_ADDIN
			invoke strlen,addr buffer
			.while buffer[eax-1]!='\'
				dec		eax
			.endw
			mov		edx,eax
			invoke strcpy,addr buffer[edx],addr wfd.cFileName
			invoke IsAddin,addr buffer
			.if eax
				mov		hDll,eax
				mov		[esi].ADDIN.hDLL,eax
				invoke GetProcAddress,hDll,addr szInstallAddin
				push	ha.hWnd
				call	eax
				mov		edx,[eax].HOOK.hook1
				mov		[esi].ADDIN.fhook1,edx
				mov		edx,[eax].HOOK.hook2
				mov		[esi].ADDIN.fhook2,edx
				mov		edx,[eax].HOOK.hook3
				mov		[esi].ADDIN.fhook3,edx
				mov		edx,[eax].HOOK.hook4
				mov		[esi].ADDIN.fhook4,edx
				invoke GetProcAddress,hDll,addr szAddinProc
				mov		[esi].ADDIN.lpAddinProc,eax
				inc		nInx
				lea		esi,[esi+sizeof ADDIN]
			.endif
			invoke FindNextFile,hwfd,addr wfd
			or		eax,eax
			jne		Next
		.endif
		;No more matches, close handle
		invoke FindClose,hwfd
		invoke PostAddinMessage,ha.hWnd,AIM_ADDINSLOADED,0,0,0,HOOK_ADDINSLOADED
	.endif
	ret

LoadAddins endp

