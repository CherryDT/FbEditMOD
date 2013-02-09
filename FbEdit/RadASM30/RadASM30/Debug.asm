
IDD_DLGDONOTDEBUG			equ 8000
IDC_BTNDONOTDEBUG			equ 1003
IDC_BTNDEBUG				equ 1004
IDC_BTNDONOTDEBUGALL		equ 1005
IDC_BTNDEBUGALL				equ 1006
IDC_LSTDONOTDEBUG			equ 1001
IDC_LSTDEBUG				equ 1002
IDC_CHKMAINTHREAD			equ 1007

.code

DebugCallback proc nFunc:DWORD,wParam:DWORD,lParam:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	nFirst:DWORD

	mov		eax,nFunc
	.if eax==CB_SELECTLINE
		invoke SendMessage,ha.hEdt,EM_GETFIRSTVISIBLELINE,0,0
		mov		nFirst,eax
		mov		eax,wParam
		dec		eax
		invoke SendMessage,ha.hEdt,REM_SETHILITELINE,eax,2
		mov		eax,wParam
		dec		eax
		invoke SendMessage,ha.hEdt,EM_LINEINDEX,eax,0
		mov		chrg.cpMin,eax
		mov		chrg.cpMax,eax
		invoke SendMessage,ha.hEdt,EM_EXSETSEL,0,addr chrg
		invoke SendMessage,ha.hEdt,EM_SCROLLCARET,0,0
		invoke SendMessage,ha.hEdt,EM_GETFIRSTVISIBLELINE,0,0
		.if eax!=nFirst
			invoke SendMessage,ha.hEdt,REM_VCENTER,0,0
			invoke SendMessage,ha.hEdt,EM_SCROLLCARET,0,0
		.endif
		invoke SetForegroundWindow,ha.hWnd
		invoke SetFocus,ha.hEdt
	.elseif eax==CB_DESELECTLINE
		mov		eax,wParam
		dec		eax
		invoke SendMessage,lParam,REM_SETHILITELINE,eax,0
	.elseif eax==CB_DEBUG
		mov		eax,wParam
		mov		da.fDebugging,eax
		mov		da.fTimer,1
		.if eax
			invoke UpdateAll,UAM_LOCK_SOURCE_FILES,0
			invoke ShowOutput,TRUE
			invoke ShowDebug,TRUE
		.else
			invoke UpdateAll,UAM_UNLOCK_SOURCE_FILES,0
			invoke ShowDebug,FALSE
		.endif
		invoke SetOutputTab,0
	.elseif eax==CB_OPENFILE
		invoke strcpy,offset da.szDbgFileName,lParam
		invoke PostMessage,ha.hWnd,WM_USER+998,0,offset da.szDbgFileName
	.endif
	mov		eax,ha.hEdt
	ret

DebugCallback endp

DebugSetBreakpoints proc uses ebx esi edi
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke DebugCommand,FUNC_BPCLEARALL,0,0
	.if da.fProject
		;Get breakpoints
		xor		ebx,ebx
		.while TRUE
			invoke SendMessage,ha.hProjectBrowser,RPBM_GETITEM,ebx,0
			.break .if ![eax].PBITEM.id
			.if sdword ptr [eax].PBITEM.id>0
				mov		edi,eax
				invoke UpdateAll,UAM_ISOPEN,addr [edi].PBITEM.szitem
				.if eax==-1
					;File is not open
					mov		buffer,'B'
					invoke BinToDec,[edi].PBITEM.id,addr buffer[1]
					invoke GetPrivateProfileString,addr szIniProject,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szProjectFile
					.while byte ptr tmpbuff
						invoke GetItemInt,addr tmpbuff,0
						lea		edx,[eax+1]
						invoke DebugCommand,FUNC_BPADDLINE,edx,addr [edi].PBITEM.szitem
					.endw
				.else
					;File is open
					invoke GetWindowLong,eax,GWL_USERDATA
					invoke GetWindowLong,eax,GWL_USERDATA
					mov		esi,eax
					invoke GetWindowLong,[esi].TABMEM.hedt,GWL_ID
					.if eax==ID_EDITCODE
						mov		edi,-1
						.while TRUE
							invoke SendMessage,[esi].TABMEM.hedt,REM_NEXTBREAKPOINT,edi,0
							.break .if eax==-1
							mov		edi,eax
							lea		edx,[eax+1]
							invoke DebugCommand,FUNC_BPADDLINE,edx,addr [esi].TABMEM.filename
						.endw
					.endif
				.endif
			.endif
			inc		ebx
		.endw
	.else
		invoke UpdateAll,UAM_SET_BREAKPOINTS,0
	.endif
	.if da.fDebugging
		invoke DebugCommand,FUNC_BPUPDATE,0,0
	.endif
	ret

DebugSetBreakpoints endp

DebugClearBreakpoints proc

	invoke UpdateAll,UAM_CLEARBREAKPOINTS,0
	.if da.fProject
		;Remove breakpoints from project file
		
	.endif
	.if da.fDebugging
		invoke DebugSetBreakpoints
	.endif
	ret

DebugClearBreakpoints endp

DebugStart proc
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hFile:HANDLE

	mov		nUnsaved,0
	invoke UpdateAll,UAM_UNSAVED_SOURCE_FILES,0
	.if nUnsaved
		invoke wsprintf,addr buffer,addr szUnsaved,nUnsaved
		invoke MessageBox,ha.hWnd,addr buffer,addr DisplayName,MB_OK or MB_ICONERROR
		xor		eax,eax
		jmp		Ex
	.endif
	invoke SendMessage,ha.hCboBuild,CB_GETCURSEL,0,0
	mov		edx,sizeof MAKE
	mul		edx
	invoke SetOutputFile,addr da.make.szOutLink[eax],offset da.szMainAsm
	invoke Unquote,offset makeexe.output
	.if da.fProject
		invoke strcpy,addr dbginf.FileName,offset da.szProjectPath
		invoke strcat,addr dbginf.FileName,offset szBS
		invoke strcat,addr dbginf.FileName,offset makeexe.output
	.else
		invoke strcpy,addr dbginf.FileName,offset makeexe.output
	.endif
	invoke CreateFile,addr dbginf.FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileTime,hFile,NULL,NULL,addr ftexe
		invoke CloseHandle,hFile
		mov		nNewer,0
		invoke UpdateAll,UAM_NEWER_SOURCE_FILES,0
		.if nNewer
			invoke wsprintf,addr buffer,addr szNewer,nNewer
			invoke MessageBox,ha.hWnd,addr buffer,addr DisplayName,MB_OK or MB_ICONERROR
			xor		eax,eax
			jmp		Ex
		.endif
	.else
		invoke strcpy,addr buffer,addr szOpenFileFail
		invoke strcat,addr buffer,addr dbginf.FileName
		invoke MessageBox,ha.hWnd,addr buffer,addr DisplayName,MB_OK or MB_ICONERROR
		xor		eax,eax
		jmp		Ex
	.endif
	mov		eax,ha.hWnd
	mov		dbginf.hWnd,eax
	mov		eax,ha.hOutput
	mov		dbginf.hOut,eax
	mov		eax,ha.hImmediate
	mov		dbginf.hImmOut,eax
	mov		eax,ha.hREGDebug
	mov		dbginf.hDbgReg,eax
	mov		eax,ha.hFPUDebug
	mov		dbginf.hDbgFpu,eax
	mov		eax,ha.hMMXDebug
	mov		dbginf.hDbgMMX,eax
	mov		eax,ha.hWATCHDebug
	mov		dbginf.hDbgWatch,eax
	mov		eax,ha.hProperty
	mov		dbginf.hPrp,eax
	mov		dbginf.lpNoDebug,offset da.szNoDebug
	mov		eax,da.fMainThread
	mov		dbginf.fMainThread,eax
	mov		eax,offset DebugCallback
	mov		dbginf.lpCallBack,eax
	mov		eax,da.fProject
	mov		dbginf.fProject,eax
	invoke SetDebugInfo,addr dbginf
	invoke DebugSetBreakpoints
	mov		eax,TRUE
  Ex:
	ret

DebugStart endp

DoNotDebugProc proc uses esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	nInx:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		nInx,0
		mov		esi,offset da.szNoDebug
		.while byte ptr [esi]
			invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_ADDSTRING,0,esi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			inc		nInx
		.endw
		invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr szCCp,addr szNULL
		.while eax
			mov		esi,eax
			mov		edi,offset da.szNoDebug
			.while byte ptr [edi]
				invoke strcmp,esi,edi
				.break .if !eax
				invoke strlen,edi
				lea		edi,[edi+eax+1]
			.endw
			.if !byte ptr [edi]
				invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_ADDSTRING,0,esi
			.endif
			invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
		.endw
		invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_SETCURSEL,0,0
		invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_SETCURSEL,0,0
		mov		eax,BST_UNCHECKED
		.if da.fMainThread
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKMAINTHREAD,eax
		.if da.fDebugging
			mov		eax,IDOK
			call	Disable
			mov		eax,IDC_BTNDONOTDEBUG
			call	Disable
			mov		eax,IDC_BTNDEBUG
			call	Disable
			mov		eax,IDC_BTNDONOTDEBUGALL
			call	Disable
			mov		eax,IDC_BTNDEBUGALL
			call	Disable
			mov		eax,IDC_CHKMAINTHREAD
			call	Disable
		.endif
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				mov		nInx,0
				mov		edi,offset da.szNoDebug
				invoke RtlZeroMemory,edi,sizeof da.szNoDebug
				.while TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_GETTEXT,nInx,edi
					.break .if eax==LB_ERR
					invoke strlen,edi
					lea		edi,[edi+eax+1]
					mov		byte ptr [edi],0
					inc		nInx
				.endw
				invoke IsDlgButtonChecked,hWin,IDC_CHKMAINTHREAD
				mov		da.fMainThread,eax
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNDONOTDEBUG
				invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_GETTEXT,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_DELETESTRING,nInx,0
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_ADDSTRING,0,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_SETCURSEL,eax,0
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_SETCURSEL,nInx,0
					.if eax==LB_ERR && nInx
						dec		nInx
						invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_SETCURSEL,nInx,0
					.endif
				.endif
			.elseif eax==IDC_BTNDEBUG
				invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_GETTEXT,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_DELETESTRING,nInx,0
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_ADDSTRING,0,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_SETCURSEL,eax,0
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_SETCURSEL,nInx,0
					.if eax==LB_ERR && nInx
						dec		nInx
						invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_SETCURSEL,nInx,0
					.endif
				.endif
			.elseif eax==IDC_BTNDONOTDEBUGALL
				.while TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_GETTEXT,0,addr buffer
					.break .if eax==LB_ERR
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_DELETESTRING,0,0
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_ADDSTRING,0,addr buffer
				.endw
			.elseif eax==IDC_BTNDEBUGALL
				.while TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_GETTEXT,0,addr buffer
					.break .if eax==LB_ERR
					invoke SendDlgItemMessage,hWin,IDC_LSTDONOTDEBUG,LB_DELETESTRING,0,0
					invoke SendDlgItemMessage,hWin,IDC_LSTDEBUG,LB_ADDSTRING,0,addr buffer
				.endw
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Disable:
	invoke GetDlgItem,hWin,eax
	invoke EnableWindow,eax,FALSE
	retn

DoNotDebugProc endp
