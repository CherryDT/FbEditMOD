
IDD_DLGADDINMANAGER			equ 1600
IDC_LSTADDINS				equ 1601
IDC_BTNAMHELP				equ 1605

MAX_ADDIN					equ 32

ADDIN struct
	hDLL			dd ?
	fhook1			dd ?
	fhook2			dd ?
	fhook3			dd ?
	fhook4			dd ?
	lpAddinProc		dd ?
ADDIN ends

.const

szAddinPath						db '\Addins\',0
szAllDll						db '*.dll',0
szHelpPath						db '\Addins\Help\',0
szInstallAddin					db 'InstallAddin',0
szAddinProc						db 'AddinProc',0

.data?

addin							ADDIN MAX_ADDIN dup(<>)
lpOldAddinListProc				dd ?

.code

AddinListProc proc  hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_LBUTTONDOWN
		invoke SetCapture,hWin
	.elseif eax==WM_LBUTTONUP
		mov		eax,lParam
		movsx	eax,ax
		.if sdword ptr eax>=1 && sdword ptr eax<=14
			invoke SendMessage,hWin,LB_GETCURSEL,0,0
			push	eax
			invoke SendMessage,hWin,LB_GETITEMDATA,eax,0
			xor		eax,1
			pop		edx
			invoke SendMessage,hWin,LB_SETITEMDATA,edx,eax
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		invoke ReleaseCapture
	.endif
	invoke CallWindowProc,lpOldAddinListProc,hWin,uMsg,wParam,lParam
	ret

AddinListProc endp

AddinManagerProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hLst:HWND
	LOCAL	wfd:WIN32_FIND_DATA
	LOCAL	hwfd:HANDLE
	LOCAL	hDll:HMODULE
	LOCAL	nInx:DWORD
	LOCAL	rect:RECT
	LOCAL	szItem[MAX_PATH]:BYTE
	LOCAL	buff[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_LSTADDINS
		mov		hLst,eax
		invoke SetWindowLong,hLst,GWL_WNDPROC,offset AddinListProc
		mov		lpOldAddinListProc,eax
		mov		nInx,0
		invoke strcpy,addr buff,addr da.szAppPath
		invoke strcat,addr buff,addr szAddinPath
		invoke strcat,addr buff,addr szAllDll
		invoke FindFirstFile,addr buff,addr wfd
		.if eax!=INVALID_HANDLE_VALUE
			mov		hwfd,eax
			.while TRUE
				invoke strcpy,addr buff,addr da.szAppPath
				invoke strcat,addr buff,addr szAddinPath
				invoke strcat,addr buff,addr wfd.cFileName
				invoke LoadLibrary,addr buff
				.if eax
					mov		hDll,eax
					invoke GetProcAddress,hDll,addr szInstallAddin
					.if eax
						invoke SendMessage,hLst,LB_ADDSTRING,0,addr wfd.cFileName
						mov		nInx,eax
						invoke GetPrivateProfileInt,addr szIniAddins,addr wfd.cFileName,1,addr da.szRadASMIni
						invoke SendMessage,hLst,LB_SETITEMDATA,nInx,eax
					.endif
					invoke FreeLibrary,hDll
				.endif
				invoke FindNextFile,hwfd,addr wfd
				.break .if !eax
			.endw
			invoke FindClose,hwfd
		.endif
		invoke SendMessage,hLst,LB_SETCURSEL,0,0
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				mov		word ptr buff,0
				invoke WritePrivateProfileSection,addr szIniAddins,addr buff,addr da.szRadASMIni
				mov		nInx,0
				.While TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETTEXT,nInx,addr szItem
					.break .if eax==LB_ERR
					invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETITEMDATA,nInx,0
					mov		edx,eax
					invoke BinToDec,edx,addr buff
					invoke WritePrivateProfileString,addr szIniAddins,addr szItem,addr buff,addr da.szRadASMIni
					inc		nInx
				.endw
				invoke SendMessage,hWin,WM_CLOSE,NULL,TRUE
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNAMHELP
				invoke strcpy,addr buff,addr da.szAppPath
				invoke strcat,addr buff,addr szHelpPath
				invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETTEXT,nInx,addr wfd.cFileName
					invoke strcpy,addr szItem,addr buff
					invoke strcat,addr buff,addr wfd.cFileName
					invoke strlen,addr buff
					lea		esi,[buff+eax-3]
					mov		dword ptr [esi],'txt'
					invoke GetFileAttributes,addr buff
					.if eax==INVALID_HANDLE_VALUE
						mov		dword ptr [esi],'mhc'
						invoke GetFileAttributes,addr buff
						.if eax==INVALID_HANDLE_VALUE
							mov		dword ptr [esi],'ftr'
							invoke GetFileAttributes,addr buff
						.endif
					.endif
					.if eax!=INVALID_HANDLE_VALUE
						invoke ShellExecute,hWin,addr szIniOpen,addr buff,NULL,NULL,SW_SHOWNORMAL
					.endif
				.endif
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,lParam
	.elseif eax==WM_DRAWITEM
		mov		esi,lParam
		; Select back and text colors
		mov		eax,[esi].DRAWITEMSTRUCT.itemState
		test	eax,ODS_SELECTED
		.If !ZERO?
			invoke GetSysColor,COLOR_HIGHLIGHTTEXT
			invoke SetTextColor,[esi].DRAWITEMSTRUCT.hdc,eax
			invoke GetSysColor,COLOR_HIGHLIGHT
			invoke SetBkColor,[esi].DRAWITEMSTRUCT.hdc,eax
		.else
			invoke GetSysColor,COLOR_WINDOWTEXT
			invoke SetTextColor,[esi].DRAWITEMSTRUCT.hdc,eax
			invoke GetSysColor,COLOR_WINDOW
			invoke SetBkColor,[esi].DRAWITEMSTRUCT.hdc,eax
		.endif
		; Draw selected / unselected back color
		invoke ExtTextOut,[esi].DRAWITEMSTRUCT.hdc,0,0,ETO_OPAQUE,addr [esi].DRAWITEMSTRUCT.rcItem,NULL,0,NULL
		; Draw the checkbox
		mov		eax,[esi].DRAWITEMSTRUCT.rcItem.left
		inc		eax
		mov		rect.left,eax
		add		eax,13
		mov		rect.right,eax
		mov		eax,[esi].DRAWITEMSTRUCT.rcItem.top
		inc		eax
		mov		rect.top,eax
		add		eax,13
		mov		rect.bottom,eax
		mov		eax,DFCS_BUTTONCHECK Or DFCS_FLAT
		.If [esi].DRAWITEMSTRUCT.itemData
			or		eax,DFCS_CHECKED
		.endif
		invoke DrawFrameControl,[esi].DRAWITEMSTRUCT.hdc,addr rect,DFC_BUTTON,eax
		; Draw the text
		invoke SendMessage,[esi].DRAWITEMSTRUCT.hwndItem,LB_GETTEXT,[esi].DRAWITEMSTRUCT.itemID,addr szItem
		mov		edx,[esi].DRAWITEMSTRUCT.rcItem.left
		add		edx,18
		invoke TextOut,[esi].DRAWITEMSTRUCT.hdc,edx,[esi].DRAWITEMSTRUCT.rcItem.top,addr szItem,eax
		invoke GetFocus
		.if eax==[esi].DRAWITEMSTRUCT.hwndItem
			; Let windows draw the focus rectangle
			xor		eax,eax
			jmp		Ex
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
  Ex:
	ret

AddinManagerProc endp

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
			invoke GetPrivateProfileInt,addr szIniAddins,edx,1,addr da.szRadASMIni
			mov		val,eax
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
	invoke strcpy,addr buffer,addr da.szAppPath
	invoke strcat,addr buffer,addr szAddinPath
	invoke strcat,addr buffer,addr szAllDll
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		mov		hwfd,eax
	  NextAddin:
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
			jne		NextAddin
		.endif
		;No more matches, close handle
		invoke FindClose,hwfd
		invoke PostAddinMessage,ha.hWnd,AIM_ADDINSLOADED,0,0,0,HOOK_ADDINSLOADED
	.endif
	ret

LoadAddins endp

