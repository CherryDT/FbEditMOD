.386
.model flat,stdcall
option casemap:none

include Emu8051.inc
include Misc.asm
include Terminal.asm
include RS232.asm
include HelpMenu.asm

.code

DoToolBar proc hToolBar:HWND
	LOCAL	tbab:TBADDBITMAP

	;Create toolbar imagelist
	invoke ImageList_LoadImage,hInstance,IDB_TOOLBAR,16,0,0FF00FFh,IMAGE_BITMAP,LR_CREATEDIBSECTION
	mov		hImlTbr,eax
	;Set toolbar struct size
	invoke SendMessage,hToolBar,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	;Set toolbar buttons
	invoke SendMessage,hToolBar,TB_ADDBUTTONS,ntbrbtns,addr tbrbtns
	;Set the imagelist
	invoke SendMessage,hToolBar,TB_SETIMAGELIST,0,hImlTbr
	ret

DoToolBar endp

SetHighlightWords proc hWin:HWND

	invoke SendMessage,hWin,REM_SETHILITEWORDS,8388672,offset C0
	invoke SendMessage,hWin,REM_SETHILITEWORDS,25165888,offset C1
	invoke SendMessage,hWin,REM_SETHILITEWORDS,8388672,offset C2
	invoke SendMessage,hWin,REM_SETHILITEWORDS,8388672,offset C3
	invoke SendMessage,hWin,REM_SETHILITEWORDS,8388672,offset C4
	invoke SendMessage,hWin,REM_SETHILITEWORDS,8388672,offset C5
	ret

SetHighlightWords endp

RAEditProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_CHAR
		invoke SendMessage,hWnd,uMsg,wParam,lParam
	.else
		invoke CallWindowProc,lpOldRAEditProc,hWin,uMsg,wParam,lParam
	.endif
	ret

RAEditProc endp

WndProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	msg:MSG
	LOCAL	sbParts[4]:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	trng:TEXTRANGE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
		;Load accelerators
		invoke LoadAccelerators,hInstance,IDA_ACCEL1
		mov		hAccel,eax
		mov		SingleStepLine,-1
		invoke GetDlgItem,hWin,IDC_TBR1
		invoke DoToolBar,eax
		invoke GetDlgItem,hWin,IDC_SCREEN
		mov		hScrn,eax
		invoke GetDlgItem,hWin,IDC_RAE1
		mov		hREd,eax
		invoke GetDlgItem,hWin,IDC_RAE2
		mov		hDbg,eax
		invoke CreateFontIndirect,addr Courier_New_12
		mov		hFont,eax
		invoke CreateFontIndirect,addr Courier_New_10
		mov		hDbgFont,eax
		invoke SendMessage,hScrn,WM_SETFONT,hFont,FALSE
		invoke SetWindowLong,hScrn,GWL_WNDPROC,addr ScreenProc
		mov		lpOldScreenProc,eax
		invoke SendMessage,hREd,WM_SETFONT,hDbgFont,FALSE
		invoke SendMessage,hDbg,WM_SETFONT,hFont,FALSE
		invoke SendMessage,hDbg,REM_SUBCLASS,0,addr RAEditProc
		mov		lpOldRAEditProc,eax
		invoke ScreenCls
		invoke CreateCaret,hScrn,NULL,BOXWT,BOXHT
		invoke ShowCaret,hScrn
;		invoke InitCom
;;		invoke OpenCom
;		invoke CreateThread,NULL,0,addr DoComm,0,0,addr tid
;		mov		hThreadRD,eax
;		.if hCom
;			;invoke SetThreadPriority,hThreadRD,THREAD_PRIORITY_LOWEST
;			invoke WriteCom,0Dh
;		.endif
;		invoke SetTimer,hWin,1000,10,NULL
		mov [sbParts+0],200				; pixels from left
		mov [sbParts+4],400				; pixels from left
		mov [sbParts+8],450				; pixels from left
		mov [sbParts+12],-1				; last part
		invoke SendDlgItemMessage,hWin,IDC_SBR1,SB_SETPARTS,4,addr sbParts
		invoke lstrlen,addr szcmdfilename
		.while sdword ptr eax>=0 && byte ptr szcmdfilename[eax]!='\'
			dec		eax
		.endw
		invoke SendDlgItemMessage,hWin,IDC_SBR1,SB_SETTEXT,0,addr szcmdfilename[eax+1]
		invoke lstrlen,addr szcmdfilename
		.while sdword ptr eax>=0 && byte ptr szromfilename[eax]!='\'
			dec		eax
		.endw
		invoke SendDlgItemMessage,hWin,IDC_SBR1,SB_SETTEXT,1,addr szromfilename[eax+1]
		invoke SetHighlightWords,hREd
		invoke LoadLstFile
		invoke SetDbgInfo
		invoke GetMenu,hWin
		mov		hMenu,eax
		invoke SetHelpMenu
	.elseif eax==WM_TIMER
		.if hCom
			.while TRUE
				mov		edx,rdtail
				.break .if edx==rdhead
				movzx	eax,rdbuff[edx]
				inc		edx
				and		edx,sizeof rdbuff-1
				mov		rdtail,edx
				invoke ScreenOut,eax
			.endw
		.else
			invoke KillTimer,hWin,1000
			invoke OpenCom
			invoke SetTimer,hWin,1000,10,NULL
		.endif
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDM_FILE_OPEN
			invoke RtlZeroMemory,addr ofn,sizeof OPENFILENAME
			;Setup the ofn struct
			mov		ofn.lStructSize,sizeof ofn
			push	hWnd
			pop		ofn.hwndOwner
			push	hInstance
			pop		ofn.hInstance
			mov		ofn.lpstrFilter,offset szANYString
			.if !fDebug
				invoke lstrcpy,addr buffer,addr szcmdfilename
			.else
				invoke lstrcpy,addr buffer,addr szlstfilename
			.endif
			lea		eax,buffer
			mov		ofn.lpstrFile,eax
			mov		ofn.nMaxFile,sizeof buffer
			mov		ofn.lpstrDefExt,NULL
			mov		ofn.lpstrInitialDir,0
			mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
			;Show the Open dialog
			invoke GetOpenFileName,addr ofn
			.if eax
				.if !fDebug
					invoke lstrcpy,addr szcmdfilename,addr buffer
					movzx	eax,ofn.nFileOffset
					invoke SendDlgItemMessage,hWin,IDC_SBR1,SB_SETTEXT,0,addr szcmdfilename[eax]
				.else
					invoke lstrcpy,addr szlstfilename,addr buffer
				.endif
			.endif
;			.if !fDebug
;				invoke CreateCaret,hScrn,NULL,BOXWT,BOXHT
;				invoke ScreenCaret
;				invoke ShowCaret,hScrn
;			.else
;				invoke LoadLstFile
;			.endif
;			invoke SetFocus,hWin
		.elseif eax==IDM_FILE_SAVE
			invoke RtlZeroMemory,addr ofn,sizeof OPENFILENAME
			invoke RtlZeroMemory,addr ofn,sizeof OPENFILENAME
			;Setup the ofn struct
			mov		ofn.lStructSize,sizeof ofn
			push	hWnd
			pop		ofn.hwndOwner
			push	hInstance
			pop		ofn.hInstance
			mov		ofn.lpstrFilter,offset szANYString
			invoke lstrcpy,addr buffer,addr szromfilename
			lea		eax,buffer
			mov		ofn.lpstrFile,eax
			mov		ofn.nMaxFile,sizeof buffer
			mov		ofn.lpstrDefExt,NULL
			mov		ofn.lpstrInitialDir,0
			mov		ofn.Flags,OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
			;Show the Save dialog
			invoke GetSaveFileName,addr ofn
			.if eax
				invoke lstrcpy,addr szromfilename,addr buffer
				movzx	eax,ofn.nFileOffset
				invoke SendDlgItemMessage,hWin,IDC_SBR1,SB_SETTEXT,1,addr szromfilename[eax]
			.endif
;			invoke SetFocus,hWin
;			invoke CreateCaret,hScrn,NULL,BOXWT,BOXHT
;			invoke ScreenCaret
;			invoke ShowCaret,hScrn
		.elseif eax==IDM_FILE_UPLOAD
			;Load .cmd file
			invoke WriteCom,'L'
		.elseif eax==IDM_FILE_GO
			;Load .cmd file and run
			invoke WriteCom,'G'
		.elseif eax==IDM_FILE_DEBUG
			.if fDebug
				;Show terminal window
				invoke ShowWindow,hScrn,SW_SHOW
				invoke ShowWindow,hREd,SW_HIDE
				invoke SetFocus,hWin
				invoke CreateCaret,hScrn,NULL,BOXWT,BOXHT
				invoke ShowCaret,hScrn
			.else
				;Show debug window
				invoke HideCaret,hScrn
				invoke ShowWindow,hREd,SW_SHOW
				invoke ShowWindow,hScrn,SW_HIDE
				invoke SetFocus,hREd
			.endif
			xor		fDebug,1
		.elseif eax==IDM_FILE_REFRESH
			;Refresh the list file
			invoke LoadLstFile
		.elseif eax==IDM_DEBUG_RUN
			;Run
			invoke SetDbgLine,-1
			invoke WriteCom,'R'
		.elseif eax==IDM_DEBUG_STOP
			.if SingleStepLine!=-1
				;Stop
				invoke SetDbgLine,-1
				invoke WriteCom,'s'
			.endif
		.elseif eax==IDM_DEBUG_INTO
			.if SingleStepLine!=-1
				;Step into
				invoke SetDbgLine,-1
				invoke WriteCom,'i'
			.endif
		.elseif eax==IDM_DEBUG_OVER
			.if SingleStepLine!=-1
				invoke IsLCALLACALL
				.if eax
					;Step over
					push	eax
					invoke SetDbgLine,-1
					invoke WriteCom,'o'
					movzx	edx,dbg.lsb
					mov		dh,dbg.msb
					pop		eax
					add		eax,edx
					push	eax
					invoke WriteCom,eax
					pop		eax
					mov		al,ah
					invoke WriteCom,eax
				.else
					;Step into
					invoke SetDbgLine,-1
					invoke WriteCom,'i'
				.endif
			.endif
		.elseif eax==IDM_DEBUG_CARET
			.if SingleStepLine!=-1
				invoke GetCaretAdress
				.if eax
					push	eax
					invoke SetDbgLine,-1
					invoke WriteCom,'o'
					pop		eax
					push	eax
					invoke WriteCom,eax
					pop		eax
					mov		al,ah
					invoke WriteCom,eax
				.endif
			.endif
		.elseif eax==IDM_DEBUG_SETDPTR
			invoke WriteCom,'A'
		.elseif eax==IDM_DEBUG_DUMPDPTR
			invoke WriteCom,'D'
		.elseif eax==IDM_DEBUG_DUMPINTERNAL
			invoke WriteCom,'I'
		.elseif eax==IDC_DEBUG_DUMPSFR
			invoke WriteCom,'S'
		.elseif eax==IDM_OPTION_COMPORT
			invoke DialogBoxParam,hInstance,IDD_DLGCOMPORT,hWin,addr ComOptionProc,0
		.elseif eax==IDM_OPTION_HELP
			invoke DialogBoxParam,hInstance,IDD_DLGOPTMNU,hWin,addr MenuOptionProc,0
		.elseif eax==IDM_HELPF1
			.if fDebug
				;Get first help file
				mov		word ptr buffer,'0'
				invoke GetPrivateProfileString,addr szHelpMenu,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr szinifile
				.if eax
					invoke GetItemStr,addr buffer,addr szNULL,addr buffer1,sizeof buffer1
					invoke FixPath,addr buffer,addr szapppath,addr szDollarA
					xor		ebx,ebx
					invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,hREd,EM_FINDWORDBREAK,WB_MOVEWORDLEFT,chrg.cpMin
					.if eax
						mov		trng.chrg.cpMax,eax
						dec		eax
						mov		trng.chrg.cpMin,eax
						lea		eax,buffer1
						mov		trng.lpstrText,eax
						invoke SendMessage,hREd,EM_GETTEXTRANGE,0,addr trng
						.if buffer1=='.'
							mov		ebx,TRUE
						.endif
					.endif
					invoke SendMessage,hREd,REM_GETWORD,sizeof buffer1-1,addr buffer1
					.if buffer1
						invoke DoHelp,addr buffer,addr buffer1
					.else
						mov		eax,dword ptr buffer
						and		eax,5F5F5F5Fh
						.if eax=='PTTH'
							;Show internet browser
							invoke ShellExecute,hWin,addr szOpen,addr buffer,NULL,NULL,SW_SHOWNORMAL;SW_SHOWDEFAULT
						.else
							;Show help file
							invoke ParseCmnd,addr buffer,addr buffer,addr buffer1
							invoke ShellExecute,hWin,addr szOpen,addr buffer,addr buffer1,NULL,SW_SHOWNORMAL;SW_SHOWDEFAULT
						.endif
					.endif
				.endif
			.endif
		.elseif eax>=IDM_HELP_START && eax<=IDM_HELP_START+20
			;Help
			mov		edx,eax
			sub		edx,IDM_HELP_START
			invoke BinToDec,edx,addr buffer
			invoke GetPrivateProfileString,addr szHelpMenu,addr buffer,addr szNULL,addr buffer1,sizeof buffer1,addr szinifile
			.if eax
				invoke GetItemStr,addr buffer1,addr szNULL,addr buffer,sizeof buffer
				mov		eax,dword ptr buffer1
				and		eax,5F5F5F5Fh
				.if eax=='PTTH'
					;Show internet browser
					invoke ShellExecute,hWin,addr szOpen,addr buffer1,NULL,NULL,SW_SHOWNORMAL;SW_SHOWDEFAULT
				.else
					;Show help file
					invoke FixPath,addr buffer1,addr szapppath,addr szDollarA
					invoke ParseCmnd,addr buffer1,addr buffer,addr buffer1
					invoke ShellExecute,hWin,addr szOpen,addr buffer,addr buffer1,NULL,SW_SHOWNORMAL;SW_SHOWDEFAULT
				.endif
			.endif
		.endif
	.elseif eax==WM_CHAR
		.if hCom && !hrdfile
			mov		eax,wParam
			.if eax==1Bh
				;Esc
				mov		eax,9Fh
			.elseif eax>='a' && eax<='z'
				;Convert to uppercase
				and		eax,5Fh
			.endif
			invoke WriteCom,eax
		.endif
	.elseif eax==WM_KEYDOWN
		.if hCom && !hrdfile && !fDebug
			mov		eax,wParam
			.if eax==VK_RIGHT
				invoke WriteCom,9Ch
			.elseif eax==VK_LEFT
				invoke WriteCom,9Dh
			.elseif eax==VK_DOWN
				invoke WriteCom,9Bh
			.elseif eax==VK_UP
				invoke WriteCom,9Ah
			.elseif eax==VK_INSERT
				invoke WriteCom,94h
			.endif
		.endif
	.elseif eax==WM_ACTIVATE
		movzx	eax,word ptr wParam
		.if eax!=WA_INACTIVE
			.if !fDebug
				;Terminal window
				invoke SetFocus,hWin
				invoke CreateCaret,hScrn,NULL,BOXWT,BOXHT
				invoke ShowCaret,hScrn
			.else
				;Debug window
				invoke SetFocus,hREd
			.endif
		.endif
	.elseif eax==WM_SIZE
		invoke MoveWindow,hScrn,0,28,80*BOXWT+4,LINES*BOXHT+4,TRUE
		invoke MoveWindow,hREd,0,28,80*BOXWT+4,LINES*BOXHT+4,TRUE
		invoke MoveWindow,hDbg,80*BOXWT+4,28,186,LINES*BOXHT+4,TRUE
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.elseif uMsg==WM_DESTROY
		.if hCom
			mov		fExit,TRUE
			invoke WaitForSingleObject,hThreadRD,3000
			invoke CloseHandle,hThreadRD
			invoke CloseHandle,hCom
			mov		hCom,0
		.endif
		invoke DeleteObject,hFont
		invoke DeleteObject,hDbgFont
		invoke ImageList_Destroy,hImlTbr
		invoke DestroyAcceleratorTable,hAccel
		invoke PostQuitMessage,NULL
	.elseif eax==WM_NOTIFY
		mov		ebx,lParam
		.if  [ebx].NMHDR.code==TTN_NEEDTEXT
			invoke LoadString,hInstance,[ebx].NMHDR.idFrom,addr buffer,sizeof buffer
			lea		eax,buffer
			mov		[ebx].TOOLTIPTEXT.lpszText,eax
		.endif
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

WndProc endp

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,IDM_MENU
	mov		wc.lpszClassName,offset ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_DIALOG,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	invoke InitCom
	.while !hCom
		invoke OpenCom
	.endw
	invoke CreateThread,NULL,0,addr DoComm,0,0,addr tid
	mov		hThreadRD,eax
	invoke SetTimer,hWnd,1000,10,NULL
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .break .if !eax
		invoke TranslateAccelerator,hWnd,hAccel,addr msg
		.if !eax
			invoke TranslateMessage,addr msg
			invoke DispatchMessage,addr msg
		.endif
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke InitCommonControls
	invoke InstallRAEdit,hInstance,FALSE
	invoke GetCommandLine
	mov		CommandLine,eax
	;Get command line filename
	invoke PathGetArgs,CommandLine
	mov		CommandLine,eax
	.if byte ptr [eax]
		invoke lstrcpy,addr szcmdfilename,CommandLine
		invoke lstrcpy,addr szlstfilename,CommandLine
		invoke lstrlen,addr szlstfilename
		mov		dword ptr szlstfilename[eax-4],'tsl.'
	.else
		invoke lstrcpy,addr szcmdfilename,addr szDefCmdData
		invoke lstrcpy,addr szlstfilename,addr szDefLstData
	.endif
	invoke lstrcpy,addr szromfilename,addr szDefRomData
	invoke GetModuleFileName,hInstance,addr szapppath,sizeof szapppath
	.while szapppath[eax]!='\' && eax
		dec		eax
	.endw
	mov		szapppath[eax],0
	invoke lstrcpy,addr szinifile,addr szapppath
	invoke lstrcat,addr szinifile,addr szIniFile
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	invoke UnInstallRAEdit
	invoke ExitProcess,eax

end start
