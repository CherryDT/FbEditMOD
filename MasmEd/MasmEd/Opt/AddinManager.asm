
IDD_DLGADDINMANAGER				equ 6100
IDC_LSTADDINS					equ 1001
IDC_BTNHELP						equ 1002

.const

szAddinPath						db '\Addins\',0
szAllDll						db '*.dll',0
szHelpPath						db '\Addins\Help\',0

.data?

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

AddinManagerProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	wfd:WIN32_FIND_DATA
	LOCAL	hwfd:HANDLE
	LOCAL	hDll:HMODULE
	LOCAL	nInx:DWORD
	LOCAL	rect:RECT
	LOCAL	szItem[MAX_PATH]:BYTE
	LOCAL	hLst:HWND
	LOCAL	buff[MAX_PATH]:BYTE
	LOCAL	val:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_LSTADDINS
		mov		hLst,eax
		invoke SetWindowLong,hLst,GWL_WNDPROC,offset AddinListProc
		mov		lpOldAddinListProc,eax
		mov		nInx,0
		invoke strcpy,addr buff,addr da.AppPath
		invoke strcat,addr buff,addr szAddinPath
		invoke strcat,addr buff,addr szAllDll
		invoke FindFirstFile,addr buff,addr wfd
		.if eax!=INVALID_HANDLE_VALUE
			mov		hwfd,eax
			.while TRUE
				invoke strcpy,addr buff,addr da.AppPath
				invoke strcat,addr buff,addr szAddinPath
				invoke strcat,addr buff,addr wfd.cFileName
				invoke LoadLibrary,addr buff
				.if eax
					mov		hDll,eax
					invoke GetProcAddress,hDll,addr szInstallAddin
					.if eax
						invoke SendMessage,hLst,LB_ADDSTRING,0,addr wfd.cFileName
						mov		nInx,eax
						mov		val,1
						mov		lpcbData,sizeof val
						invoke RegQueryValueEx,ha.hReg,addr wfd.cFileName,0,addr lpType,addr val,addr lpcbData
						invoke SendMessage,hLst,LB_SETITEMDATA,nInx,val
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
				mov		nInx,0
				.While TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETTEXT,nInx,addr szItem
					.break .if eax==LB_ERR
					invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETITEMDATA,nInx,0
					mov		val,eax
					invoke RegSetValueEx,ha.hReg,addr szItem,0,REG_DWORD,addr val,sizeof val
					inc		nInx
				.endw
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNHELP
				invoke strcpy,addr buff,addr da.AppPath
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
						invoke ShellExecute,hWin,addr szOpen,addr buff,NULL,NULL,SW_SHOWNORMAL
					.endif
				.endif
			.endif
		.endif
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
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
  Ex:
	ret

AddinManagerProc endp
