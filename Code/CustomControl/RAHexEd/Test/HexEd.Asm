.386
.model flat,stdcall
option casemap:none

include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include shlwapi.inc
include comctl32.inc
include comdlg32.inc
include gdi32.inc
include advapi32.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib shlwapi.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib gdi32.lib
includelib advapi32.lib

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

include ..\RAHexEd.Inc
include HexEd.inc
include Misc.asm
include TabTool.asm
include FileIO.asm
include Find.asm
include ColorOption.asm
include MenuOption.asm
include About.asm

.code

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax
	invoke GetCommandLine
	mov		CommandLine,eax
	;Get command line filename
	invoke PathGetArgs,CommandLine
	mov		CommandLine,eax
	invoke InitCommonControls
	invoke LoadLibrary,offset RAHexEdDLL
	.if eax
		mov		hRAHexEdDLL,eax
		invoke GetModuleFileName,0,offset FileName,sizeof FileName
		invoke lstrlen,offset FileName
		mov		edx,offset FileName
		add		edx,eax
	  @@:
		dec		edx
		mov		al,[edx]
		.if al=='.' || al=='\'
			mov		byte ptr [edx],0
		.endif
		.if al!='\'
			jmp		@b
		.endif
		inc		edx
		invoke lstrcat,offset szHexEd,edx
		invoke SetCurrentDirectory,offset FileName
		invoke RegCreateKeyEx,HKEY_CURRENT_USER,addr szHexEd,0,addr szREG_SZ,0,KEY_WRITE or KEY_READ,0,addr hReg,addr lpdwDisp
		.if lpdwDisp==REG_OPENED_EXISTING_KEY
			mov		lpcbData,sizeof wpos
			invoke RegQueryValueEx,hReg,addr szWinPos,0,addr lpType,addr wpos,addr lpcbData
			mov		lpcbData,sizeof lfnthex
			invoke RegQueryValueEx,hReg,addr szHexFont,0,addr lpType,addr lfnthex,addr lpcbData
			mov		lpcbData,sizeof lfntlnr
			invoke RegQueryValueEx,hReg,addr szLnrFont,0,addr lpType,addr lfntlnr,addr lpcbData
			mov		lpcbData,sizeof col
			invoke RegQueryValueEx,hReg,addr szColor,0,addr lpType,addr col,addr lpcbData
			mov		lpcbData,sizeof CustColors
			invoke RegQueryValueEx,hReg,addr szCustColors,0,addr lpType,addr CustColors,addr lpcbData
		.endif
		invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
		push	eax
		invoke FreeLibrary,hRAHexEdDLL
		invoke RegSetValueEx,hReg,addr szWinPos,0,REG_BINARY,addr wpos,sizeof wpos
		invoke RegCloseKey,hReg
		pop		eax
	.else
		invoke MessageBox,NULL,offset RAHexEdFail,offset szAppName,MB_OK
	.endif
	invoke ExitProcess,eax

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
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,IDM_MENU
	mov		wc.lpszClassName,offset ClassName
	invoke LoadIcon,hInst,IDI_ICON
	mov		hIcon,eax
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_DLG,NULL,offset WndProc,NULL
	mov		hWnd,eax
	.if wpos.fMax
		mov		eax,SW_MAXIMIZE
	.else
		mov		eax,SW_SHOWNORMAL
	.endif
	invoke ShowWindow,hWnd,eax
	invoke UpdateWindow,hWnd
	invoke LoadAccelerators,hInstance,IDR_ACCEL
	mov		hAccel,eax
	push	ebx
	mov		ebx,CommandLine
	.while byte ptr [ebx]
		call	LoadHexFile
	.endw
	pop		ebx
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .break .if !eax
		invoke IsDialogMessage,hFind,addr msg
		.if !eax
			invoke TranslateAccelerator,hWnd,hAccel,addr msg
			.if !eax
				invoke TranslateMessage,addr msg
				invoke DispatchMessage,addr msg
			.endif
		.endif
	.endw
	mov		eax,msg.wParam
	ret

LoadHexFile:
	.while byte ptr [ebx]==' '
		inc		ebx
	.endw
	mov		edx,offset LineTxt
	.if byte ptr [ebx]=='"'
		inc		ebx
		.while byte ptr [ebx]!='"' && byte ptr [ebx]
			mov		al,[ebx]
			mov		[edx],al
			inc		ebx
			inc		edx
		.endw
		inc		ebx
	.else
		.while byte ptr [ebx]!=' ' && byte ptr [ebx]
			mov		al,[ebx]
			mov		[edx],al
			inc		ebx
			inc		edx
		.endw
	.endif
	mov		byte ptr [edx],0
	.if byte ptr LineTxt
		invoke OpenEditFile,offset LineTxt
	.endif
	retn

WinMain endp

CreateRAHexEd proc

	invoke ShowWindow,hREd,SW_HIDE
	mov		eax,style
;	and		eax,-1 xor (HEX_STYLE_NOADDRESS or HEX_STYLE_NOASCII or HEX_STYLE_NOUPPERCASE)
	test	wpos.fView,4
	.if ZERO?
		or		eax,HEX_STYLE_NOADDRESS
	.endif
	test	wpos.fView,8
	.if ZERO?
		or		eax,HEX_STYLE_NOASCII
	.endif
	test	wpos.fView,16
	.if !ZERO?
		or		eax,HEX_STYLE_NOUPPERCASE
	.endif
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szRAHexEdClass,NULL,eax,0,0,0,0,hWnd,NULL,hInstance,0
	mov		hREd,eax
	test	wpos.fView,32
	.if ZERO?
		xor		eax,eax
	.else
		mov		eax,14
	.endif
	invoke SendMessage,hREd,HEM_SELBARWIDTH,eax,0
	invoke SetFormat,hREd
	;Set colors
	invoke SendMessage,hREd,HEM_SETCOLOR,0,addr col
	invoke SendMessage,hWnd,WM_SIZE,0,0
	ret

CreateRAHexEd endp

CreateNew proc

	invoke lstrcpy,offset FileName,offset NewFile
	invoke CreateRAHexEd
	invoke TabToolAdd,hREd,offset FileName
	invoke SetWinCaption,offset FileName
	invoke SetFocus,hREd
	ret

CreateNew endp

UpdateAll proc uses ebx,nFunction:DWORD
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM

	invoke SendMessage,hTab,TCM_GETITEMCOUNT,0,0
	mov		nInx,eax
	mov		tci.imask,TCIF_PARAM
	.while nInx
		dec		nInx
		invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
		.if eax
			mov		ebx,tci.lParam
			mov		eax,nFunction
			.if eax==WM_SETFONT
				invoke SendMessage,[ebx].TABMEM.hwnd,HEM_SETCOLOR,0,addr col
				invoke SetFormat,[ebx].TABMEM.hwnd
			.elseif eax==WM_PAINT
				invoke SendMessage,[ebx].TABMEM.hwnd,HEM_REPAINT,0,0
			.elseif eax==WM_CLOSE
				invoke SendMessage,[ebx].TABMEM.hwnd,EM_GETMODIFY,0,0
				.if eax
					invoke TabToolGetInx,[ebx].TABMEM.hwnd
					invoke SendMessage,hTab,TCM_SETCURSEL,eax,0
					invoke TabToolActivate
					invoke WantToSave,hREd,offset FileName
					or		eax,eax
					jne		Ex
					invoke lstrcpy,addr [ebx].TABMEM.filename,offset FileName
					invoke SendMessage,hTab,TCM_GETCURSEL,0,0
					invoke TabToolSetText,eax,offset FileName
					xor		eax,eax
				.endif
			.elseif eax==WM_DESTROY
				invoke SendMessage,hTab,TCM_DELETEITEM,nInx,0
				invoke DestroyWindow,[ebx].TABMEM.hwnd
				invoke GetProcessHeap
				invoke HeapFree,eax,NULL,ebx
			.elseif eax==IS_OPEN
				invoke lstrcmpi,offset FileName,addr [ebx].TABMEM.filename
				.if !eax
					invoke SendMessage,hTab,TCM_SETCURSEL,nInx,0
					invoke TabToolActivate
					mov		eax,TRUE
					jmp		Ex
				.endif
				xor		eax,eax
			.elseif eax==SAVE_ALL
				invoke SendMessage,[ebx].TABMEM.hwnd,EM_GETMODIFY,0,0
				.if eax
					invoke SaveEdit,[ebx].TABMEM.hwnd,addr [ebx].TABMEM.filename
				.endif
			.endif
		.endif
	.endw
  Ex:
	ret

UpdateAll endp

TimerProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	chrg:CHARRANGE

	.if fTimer
		dec		fTimer
		.if !fTimer
			invoke SendMessage,hREd,EM_CANUNDO,0,0
			mov		edx,IDM_EDIT_UNDO
			call	EnableDisable
			invoke SendMessage,hREd,EM_CANREDO,0,0
			mov		edx,IDM_EDIT_REDO
			call	EnableDisable
			invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
			mov		eax,chrg.cpMax
			sub		eax,chrg.cpMin
			mov		edx,IDM_EDIT_CUT
			call	EnableDisable
			mov		edx,IDM_EDIT_COPY
			call	EnableDisable
			mov		edx,IDM_EDIT_DELETE
			call	EnableDisable
			invoke SendMessage,hREd,EM_CANPASTE,CF_TEXT,0
			mov		edx,IDM_EDIT_PASTE
			call	EnableDisable
			invoke SendMessage,hREd,HEM_ANYBOOKMARKS,0,0
			mov		edx,IDM_EDIT_NEXTBM
			call	EnableDisable
			mov		edx,IDM_EDIT_PREVBM
			call	EnableDisable
			mov		edx,IDM_EDIT_CLEARBM
			call	EnableDisable
		.endif
	.endif
	ret

EnableDisable:
	push	eax
	push	edx
	.if eax
		mov		eax,MF_BYCOMMAND or MF_ENABLED
	.else
		mov		eax,MF_BYCOMMAND or MF_GRAYED
	.endif
	invoke EnableMenuItem,hMnu,edx,eax
	pop		edx
	pop		eax
	push	eax
	push	edx
	.if eax
		mov		eax,TRUE
	.endif
	invoke SendMessage,hTbr,TB_ENABLEBUTTON,edx,eax
	pop		edx
	pop		eax
	retn

TimerProc endp

WndProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	ht:DWORD
	LOCAL	hCtl:HWND
	LOCAL	chrg:CHARRANGE
	LOCAL	cf:CHOOSEFONT
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	mnu:MENU
	LOCAL	hebm:HEBMK

	mov		eax,uMsg
	.if eax==WM_SIZE
		invoke GetDlgItem,hWin,IDC_TBR
		mov		hCtl,eax
		test	wpos.fView,1
		.if !ZERO?
			;Resize toolbar
			.if lParam
				invoke MoveWindow,hCtl,0,0,0,0,TRUE
			.endif
			;Get height of toolbar
			invoke GetWindowRect,hCtl,addr rect
			mov		eax,rect.bottom
			sub		eax,rect.top
		.else
			invoke ShowWindow,hCtl,SW_HIDE
		.endif
		push	eax
		xor		eax,eax
		invoke GetDlgItem,hWin,IDC_SBR
		mov		hCtl,eax
		test	wpos.fView,2
		.if !ZERO?
			;Resize statusbar
			.if lParam
				invoke MoveWindow,hCtl,0,0,0,0,TRUE
			.endif
			;Get height of statusbar
			invoke GetWindowRect,hCtl,addr rect
			mov		eax,rect.bottom
			sub		eax,rect.top
		.else
			invoke ShowWindow,hCtl,SW_HIDE
		.endif
		push	eax
		;Get size of windows client area
		invoke GetClientRect,hWin,addr rect
		;Subtract height of statusbar from bottom
		pop		eax
		sub		rect.bottom,eax
		;Add height of toolbar to top
		pop		eax
		add		rect.top,eax
		;Resize divider line
		invoke GetDlgItem,hWin,IDC_SHP
		mov		edx,rect.right
		inc		edx
		.if lParam
			invoke MoveWindow,eax,0,rect.top,edx,2,TRUE
		.endif
		;Add height of duvider line to top
		add		rect.top,2
		.if lParam
			;Resize tab window
			mov		edx,rect.right
			push	edx
			inc		edx
			invoke MoveWindow,hTab,-1,rect.top,edx,TABHT,TRUE
			pop		edx
		.endif
		;Add height of tab window to top
		add		rect.top,TABHT
		;Get new height of RAEdit window
		mov		eax,rect.bottom
		sub		eax,rect.top
		mov		ht,eax
		;Resize RAEdit window
		invoke MoveWindow,hREd,0,rect.top,rect.right,ht,TRUE
	.elseif eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
		invoke MoveWindow,hWin,wpos.x,wpos.y,wpos.wt,wpos.ht,TRUE
		mov		fr,FR_DOWN
		;Set the toolbar buttons
		invoke GetDlgItem,hWin,IDC_TBR
		invoke DoToolBar,hInstance,eax
		;Set FileName to NewFile
		invoke lstrcpy,offset FileName,offset NewFile
		invoke SetWinCaption,offset FileName
		;Get handle of RAEdit window
		invoke GetDlgItem,hWin,IDC_RAH
		mov		hREd,eax
		invoke GetWindowLong,hREd,GWL_STYLE
		and		eax,-1 xor (HEX_STYLE_NOADDRESS or HEX_STYLE_NOASCII or HEX_STYLE_NOUPPERCASE)
		mov		style,eax
		test	wpos.fView,4
		.if ZERO?
			or		eax,HEX_STYLE_NOADDRESS
		.endif
		test	wpos.fView,8
		.if ZERO?
			or		eax,HEX_STYLE_NOASCII
		.endif
		test	wpos.fView,16
		.if !ZERO?
			or		eax,HEX_STYLE_NOUPPERCASE
		.endif
		invoke SetWindowLong,hREd,GWL_STYLE,eax
		test	wpos.fView,32
		.if ZERO?
			xor		eax,eax
		.else
			mov		eax,14
		.endif
		invoke SendMessage,hREd,HEM_SELBARWIDTH,eax,0
		;Create line number font
		invoke CreateFontIndirect,offset lfntlnr
		mov     hLnrFont,eax
		;Create normal font
		invoke CreateFontIndirect,offset lfnthex
		mov     hFont,eax
		;Set font & format
		invoke SetFormat,hREd
		;Set colors
		invoke SendMessage,hREd,HEM_SETCOLOR,0,addr col
		;Init RAEdit
		invoke SendMessage,hREd,EM_SETMODIFY,FALSE,0
		;and give it focus
		invoke SetFocus,hREd
		;Get handle of tab window
		invoke GetDlgItem,hWin,IDC_TAB
		mov		hTab,eax
		invoke TabToolAdd,hREd,offset FileName
		invoke GetMenu,hWin
		mov		hMnu,eax
		invoke GetDlgItem,hWin,IDC_TBR
		mov		hTbr,eax
		invoke ImageList_Create,16,16,ILC_COLOR4,4,0
		mov     hMnuIml,eax
		invoke CreateMappedBitmap,hInstance,IDB_MNUARROW,NULL,NULL,NULL
		push	eax
		invoke ImageList_Add,hMnuIml,eax,NULL
		pop		eax
		invoke DeleteObject,eax
		invoke SetToolMenu
		invoke SetHelpMenu
		invoke SetTimer,hWin,200,200,addr TimerProc
		mov		fTimer,1
		invoke ShowPos,0,0
	.elseif eax==WM_COMMAND
		;Menu and toolbar has the same ID's
		mov		eax,wParam
		mov		edx,eax
		movzx	eax,ax
		shr		edx,16
		.if edx==BN_CLICKED || edx==CBN_SELCHANGE
			.if eax==IDM_FILE_NEW
				invoke CreateNew
				mov		fTimer,1
			.elseif eax==IDM_FILE_OPEN
				invoke OpenEdit
				mov		fTimer,1
			.elseif eax==IDM_FILE_SAVE
				invoke SaveEdit,hREd,offset FileName
				invoke SetFocus,hREd
			.elseif eax==IDM_FILE_SAVEALL
				invoke UpdateAll,SAVE_ALL
			.elseif eax==IDM_FILE_SAVEAS
				invoke SaveEditAs,hREd,offset FileName
			.elseif eax==IDM_FILE_CLOSE
				invoke WantToSave,hREd,offset FileName
				.if !eax
					invoke DestroyWindow,hREd
					invoke TabToolDel,hREd
				.endif
				mov		fTimer,1
			.elseif eax==IDM_FILE_PRINT
			.elseif eax==IDM_FILE_EXIT
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==IDM_EDIT_UNDO
				invoke SendMessage,hREd,EM_UNDO,0,0
			.elseif eax==IDM_EDIT_REDO
				invoke SendMessage,hREd,EM_REDO,0,0
			.elseif eax==IDM_EDIT_DELETE
				invoke SendMessage,hREd,WM_CLEAR,0,0
			.elseif eax==IDM_EDIT_CUT
				invoke SendMessage,hREd,WM_CUT,0,0
			.elseif eax==IDM_EDIT_COPY
				invoke SendMessage,hREd,WM_COPY,0,0
			.elseif eax==IDM_EDIT_PASTE
				invoke SendMessage,hREd,WM_PASTE,0,0
			.elseif eax==IDM_EDIT_SELECTALL
				mov		chrg.cpMin,0
				mov		chrg.cpMax,-1
				invoke SendMessage,hREd,EM_EXSETSEL,0,addr chrg
			.elseif eax==IDM_EDIT_FIND
				.if !hFind
					invoke GetSelText,offset findbuff
					invoke CreateDialogParam,hInstance,IDD_FINDDLG,hWin,offset FindDlgProc,FALSE
				.else
					invoke SetFocus,hFind
				.endif
			.elseif eax==IDM_EDIT_REPLACE
				.if !hFind
					invoke GetSelText,offset findbuff
					invoke CreateDialogParam,hInstance,IDD_FINDDLG,hWin,addr FindDlgProc,TRUE
				.else
					invoke SetFocus,hFind
				.endif
			.elseif eax==IDM_EDIT_FINDNEXT
				.if !hFind
					invoke GetSelText,offset findbuff
				.endif
				mov		al,findbuff
				.if al
					invoke Find,FR_DOWN or FR_HEX
				.endif
			.elseif eax==IDM_EDIT_FINDPREV
				.if !hFind
					invoke GetSelText,offset findbuff
				.endif
				mov		al,findbuff
				.if al
					invoke Find,FR_HEX
				.endif
			.elseif eax==IDM_EDIT_TOGGLEBM
				invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
				mov		eax,chrg.cpMin
				shr		eax,5
				invoke SendMessage,hREd,HEM_TOGGLEBOOKMARK,eax,0
				mov		fTimer,1
			.elseif eax==IDM_EDIT_NEXTBM
				invoke SendMessage,hREd,HEM_NEXTBOOKMARK,0,addr hebm
				.if eax
					invoke TabToolGetInx,hebm.hWin
					invoke SendMessage,hTab,TCM_SETCURSEL,eax,0
					invoke TabToolActivate
					mov		eax,hebm.nLine
					shl		eax,5
					mov		chrg.cpMin,eax
					mov		chrg.cpMax,eax
					invoke SendMessage,hREd,EM_EXSETSEL,0,addr chrg
					invoke SendMessage,hREd,HEM_VCENTER,0,0
				.endif
			.elseif eax==IDM_EDIT_PREVBM
				invoke SendMessage,hREd,HEM_PREVIOUSBOOKMARK,0,addr hebm
				.if eax
					invoke TabToolGetInx,hebm.hWin
					invoke SendMessage,hTab,TCM_SETCURSEL,eax,0
					invoke TabToolActivate
					mov		eax,hebm.nLine
					shl		eax,5
					mov		chrg.cpMin,eax
					mov		chrg.cpMax,eax
					invoke SendMessage,hREd,EM_EXSETSEL,0,addr chrg
					invoke SendMessage,hREd,HEM_VCENTER,0,0
				.endif
			.elseif eax==IDM_EDIT_CLEARBM
				invoke SendMessage,hREd,HEM_CLEARBOOKMARKS,0,0
				mov		fTimer,1
			.elseif eax==IDM_VIEW_TOOLBAR
				invoke GetDlgItem,hWin,IDC_TBR
				mov		hCtl,eax
				xor		wpos.fView,1
				test	wpos.fView,1
				.if !ZERO?
					invoke ShowWindow,hCtl,SW_SHOWNA
				.else
					invoke ShowWindow,hCtl,SW_HIDE
				.endif
				invoke SendMessage,hWin,WM_SIZE,0,1
			.elseif eax==IDM_VIEW_STATUSBAR
				invoke GetDlgItem,hWin,IDC_SBR
				mov		hCtl,eax
				xor		wpos.fView,2
				test	wpos.fView,2
				.if !ZERO?
					invoke ShowWindow,hCtl,SW_SHOWNA
				.else
					invoke ShowWindow,hCtl,SW_HIDE
				.endif
				invoke SendMessage,hWin,WM_SIZE,0,1
			.elseif eax==IDM_VIEW_SELBAR
				xor		wpos.fView,32
				test	wpos.fView,32
				.if ZERO?
					xor		eax,eax
				.else
					mov		eax,14
				.endif
				invoke SendMessage,hREd,HEM_SELBARWIDTH,eax,0
			.elseif eax==IDM_VIEW_ADDRESS
				xor		wpos.fView,4
				invoke GetWindowLong,hREd,GWL_STYLE
				test	wpos.fView,4
				.if ZERO?
					or		eax,HEX_STYLE_NOADDRESS
				.else
					and		eax,(-1 xor HEX_STYLE_NOADDRESS)
				.endif
				invoke SetWindowLong,hREd,GWL_STYLE,eax
				invoke SendMessage,hREd,HEM_REPAINT,0,0
			.elseif eax==IDM_VIEW_ASCII
				xor		wpos.fView,8
				invoke GetWindowLong,hREd,GWL_STYLE
				test	wpos.fView,8
				.if ZERO?
					or		eax,HEX_STYLE_NOASCII
				.else
					and		eax,(-1 xor HEX_STYLE_NOASCII)
				.endif
				invoke SetWindowLong,hREd,GWL_STYLE,eax
				invoke SendMessage,hREd,HEM_REPAINT,0,0
			.elseif eax==IDM_VIEW_UPPERCASE
				xor		wpos.fView,16
				invoke GetWindowLong,hREd,GWL_STYLE
				test	wpos.fView,16
				.if !ZERO?
					or		eax,HEX_STYLE_NOUPPERCASE
				.else
					and		eax,(-1 xor HEX_STYLE_NOUPPERCASE)
				.endif
				invoke SetWindowLong,hREd,GWL_STYLE,eax
				invoke SendMessage,hREd,HEM_REPAINT,0,0
;				invoke SendMessage,hREd,HEM_SETOFFSET,100h,0
			.elseif eax==IDM_OPTION_FONT
				invoke RtlZeroMemory,addr cf,sizeof cf
				mov		cf.lStructSize,sizeof cf
				mov		eax,hWin
				mov		cf.hwndOwner,eax
				mov		cf.lpLogFont,offset lfnthex
				mov		cf.Flags,CF_SCREENFONTS or CF_FIXEDPITCHONLY or CF_EFFECTS or CF_INITTOLOGFONTSTRUCT
				mov		eax,col.dtatxtcol
				mov		cf.rgbColors,eax
				invoke ChooseFont,addr cf
				.if eax
					invoke DeleteObject,hFont
					invoke CreateFontIndirect,offset lfnthex
					mov     hFont,eax
					mov		eax,cf.rgbColors
					mov		col.dtatxtcol,eax
					.if hREd
						invoke SetFocus,hREd
					.endif
					invoke UpdateAll,WM_SETFONT
					invoke RegSetValueEx,hReg,addr szHexFont,0,REG_BINARY,addr lfnthex,sizeof lfnthex
					invoke RegSetValueEx,hReg,addr szColor,0,REG_BINARY,addr col,sizeof col
				.endif
				invoke SetFocus,hREd
			.elseif eax==IDM_OPTION_LNFONT
				invoke RtlZeroMemory,addr cf,sizeof cf
				mov		cf.lStructSize,sizeof cf
				mov		eax,hWin
				mov		cf.hwndOwner,eax
				mov		cf.lpLogFont,offset lfntlnr
				mov		cf.Flags,CF_SCREENFONTS or CF_EFFECTS or CF_INITTOLOGFONTSTRUCT
				mov		eax,col.lnrcol
				mov		cf.rgbColors,eax
				invoke ChooseFont,addr cf
				.if eax
					invoke DeleteObject,hLnrFont
					invoke CreateFontIndirect,offset lfntlnr
					mov     hLnrFont,eax
					mov		eax,cf.rgbColors
					mov		col.lnrcol,eax
					invoke SendMessage,hREd,HEM_SETCOLOR,0,addr col
					invoke UpdateAll,WM_SETFONT
					invoke RegSetValueEx,hReg,addr szLnrFont,0,REG_BINARY,addr lfntlnr,sizeof lfntlnr
					invoke RegSetValueEx,hReg,addr szColor,0,REG_BINARY,addr col,sizeof col
				.endif
				invoke SetFocus,hREd
			.elseif eax==IDM_OPTION_COLORS
				invoke DialogBoxParam,hInstance,IDD_DLGOPTIONCOLOR,hWin,offset ColorOptionProc,0
			.elseif eax==IDM_OPTION_TOOLS
				invoke DialogBoxParam,hInstance,IDD_DLGOPTMNU,hWin,offset MenuOptionProc,1
				invoke SetToolMenu
			.elseif eax==IDM_OPTION_HELP
				invoke DialogBoxParam,hInstance,IDD_DLGOPTMNU,hWin,offset MenuOptionProc,2
				invoke SetHelpMenu
			.elseif eax==IDM_HELP_ABOUT
				invoke DialogBoxParam,hInstance,IDD_DLGABOUT,hWin,offset AboutProc,0
				invoke SetFocus,hREd
			.elseif eax==IDM_HELPF1
				;F1-Help key pressed
				mov		mnu.szcap,0
				mov		mnu.szcmnd,0
				invoke lstrcpy,addr buffer,addr szMenuHelp
				invoke lstrlen,addr buffer
				mov		word ptr buffer[eax],'1'
				mov		lpcbData,sizeof mnu
				invoke RegQueryValueEx,hReg,addr buffer,0,addr lpType,addr mnu,addr lpcbData
				movzx	eax,mnu.szcmnd
				.if eax
					invoke ShellExecute,hWin,NULL,addr mnu.szcmnd,NULL,NULL,SW_SHOWDEFAULT
				.endif
			.elseif eax>=20000 && eax<=20020
				mov		mnu.szcap,0
				mov		mnu.szcmnd,0
				mov		edx,eax
				sub		edx,19999
				invoke MakeKey,addr szMenuTool,edx,addr buffer
				mov		lpcbData,sizeof mnu
				invoke RegQueryValueEx,hReg,addr buffer,0,addr lpType,addr mnu,addr lpcbData
				movzx	eax,mnu.szcmnd
				.if eax
					mov		buffer1,0
					push	ebx
					push	esi
					push	edi
					xor		ebx,ebx
					lea		esi,mnu.szcmnd
					lea		edi,buffer
				  @@:
					mov		al,[esi]
					.if al=='$'
						.if !ebx
							mov		byte ptr [edi],0
							lea		edi,buffer1
							inc		ebx
						.endif
						push	esi
						mov		esi,offset FileName
						.while al!='.' && al
							mov		al,[esi]
							.if al!='.' && al
								mov		[edi],al
								inc		esi
								inc		edi
							.endif
						.endw
						pop		esi
						inc		esi
						jmp		@b
					.endif
					mov		[edi],al
					inc		esi
					inc		edi
					or		al,al
					jne		@b
					pop		edi
					pop		esi
					pop		ebx
					invoke ShellExecute,hWin,NULL,addr buffer,addr buffer1,NULL,SW_SHOWDEFAULT
				.endif
			.elseif eax>=30000 && eax<=30020
				mov		mnu.szcap,0
				mov		mnu.szcmnd,0
				mov		edx,eax
				sub		edx,29999
				invoke MakeKey,addr szMenuHelp,edx,addr buffer
				mov		lpcbData,sizeof mnu
				invoke RegQueryValueEx,hReg,addr buffer,0,addr lpType,addr mnu,addr lpcbData
				movzx	eax,mnu.szcmnd
				.if eax
					invoke ShellExecute,hWin,NULL,addr mnu.szcmnd,NULL,NULL,SW_SHOWDEFAULT
				.endif
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		edx,lParam
		mov		eax,[edx].NMHDR.code
		.if eax==EN_SELCHANGE
			push	edi
			mov		edi,edx
			mov		eax,[edi].HESELCHANGE.chrg.cpMin
			and		eax,31
			invoke ShowPos,[edi].HESELCHANGE.line,eax
			.if [edi].HESELCHANGE.seltyp==SEL_OBJECT
			.else
				.if [edi].HESELCHANGE.fchanged
				.endif
				mov		eax,[edi].HESELCHANGE.line
				mov		nLastLine,eax
			.endif
			pop		edi
			mov		fTimer,2
		.elseif eax==TTN_NEEDTEXT
			;Toolbar tooltip
			mov		edx,(NMHDR ptr [edx]).idFrom
			invoke LoadString,hInstance,edx,addr buffer,sizeof buffer
			lea		eax,buffer
			mov		edx,lParam
			mov		(TOOLTIPTEXT ptr [edx]).lpszText,eax
		.elseif eax==TCN_SELCHANGE
			invoke TabToolActivate
		.endif
	.elseif eax==WM_SETFOCUS
		invoke SetFocus,hREd
	.elseif eax==WM_CLOSE
		invoke UpdateAll,WM_CLOSE
		.if !eax
			invoke GetWindowLong,hWin,GWL_STYLE
			test	eax,WS_MAXIMIZE
			.if ZERO?
				test	eax,WS_MINIMIZE
				.if ZERO?
					mov		wpos.fMax,FALSE
					invoke GetWindowRect,hWin,addr rect
					mov		eax,rect.left
					mov		wpos.x,eax
					mov		eax,rect.top
					mov		wpos.y,eax
					mov		eax,rect.right
					sub		eax,rect.left
					mov		wpos.wt,eax
					mov		eax,rect.bottom
					sub		eax,rect.top
					mov		wpos.ht,eax
				.endif
			.else
				mov		wpos.fMax,TRUE
			.endif
			invoke DestroyWindow,hWin
		.endif
	.elseif eax==WM_DESTROY
		invoke KillTimer,hWin,200
		invoke UpdateAll,WM_DESTROY
		invoke DeleteObject,hFont
		invoke DeleteObject,hLnrFont
		invoke DestroyIcon,hIcon
		invoke ImageList_Destroy,hMnuIml
		invoke PostQuitMessage,NULL
	.elseif eax==WM_CONTEXTMENU
		mov		eax,wParam
		.if eax==hREd
			mov		eax,lParam
			.if eax==-1
				invoke GetCaretPos,addr pt
				invoke GetFocus
				mov		edx,eax
				invoke ClientToScreen,edx,addr pt
			.else
				and		eax,0FFFFh
				mov		pt.x,eax
				mov		eax,lParam
				shr		eax,16
				mov		pt.y,eax
			.endif
			invoke GetMenu,hWin
			invoke GetSubMenu,eax,1
			invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWin,0
			xor		eax,eax
			ret
		.endif
	.elseif eax==WM_INITMENUPOPUP
		movzx	eax,word ptr lParam
		.if eax==2
			mov		edx,MF_BYCOMMAND
			test	wpos.fView,1
			.if !ZERO?
				mov		edx,MF_BYCOMMAND or MF_CHECKED
			.endif
			invoke CheckMenuItem,wParam,IDM_VIEW_TOOLBAR,edx
			mov		edx,MF_BYCOMMAND
			test	wpos.fView,2
			.if !ZERO?
				mov		edx,MF_BYCOMMAND or MF_CHECKED
			.endif
			invoke CheckMenuItem,wParam,IDM_VIEW_STATUSBAR,edx
			mov		edx,MF_BYCOMMAND
			test	wpos.fView,4
			.if !ZERO?
				mov		edx,MF_BYCOMMAND or MF_CHECKED
			.endif
			invoke CheckMenuItem,wParam,IDM_VIEW_ADDRESS,edx
			mov		edx,MF_BYCOMMAND
			test	wpos.fView,8
			.if !ZERO?
				mov		edx,MF_BYCOMMAND or MF_CHECKED
			.endif
			invoke CheckMenuItem,wParam,IDM_VIEW_ASCII,edx
			mov		edx,MF_BYCOMMAND
			test	wpos.fView,16
			.if ZERO?
				mov		edx,MF_BYCOMMAND or MF_CHECKED
			.endif
			invoke CheckMenuItem,wParam,IDM_VIEW_UPPERCASE,edx
			test	wpos.fView,32
			.if !ZERO?
				mov		edx,MF_BYCOMMAND or MF_CHECKED
			.endif
			invoke CheckMenuItem,wParam,IDM_VIEW_SELBAR,edx
		.endif
	.elseif eax==WM_DROPFILES
		push	ebx
		xor		ebx,ebx
	  @@:
		invoke DragQueryFile,wParam,ebx,addr buffer,sizeof buffer
		.if eax
			invoke OpenEditFile,addr buffer
			inc		ebx
			jmp		@b
		.endif
		pop		ebx
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
  Ex:
	xor    eax,eax
	ret

WndProc endp

end start
