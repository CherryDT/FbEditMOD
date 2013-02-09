comment -
a
a
a
-

.386
.model flat,stdcall
option casemap:none

include SimEd.inc
include CboTool.asm
include Misc.asm
include TabTool.asm
include FileIO.asm
include Find.asm
include Make.asm
include KeyWords.asm
include MenuOption.asm
include Print.asm
include PrintPreview.asm
include Block.asm
include About.asm

.code

start:

	invoke GetModuleHandle\
	,NULL
	mov		hInstance,eax
	invoke GetCommandLine
	mov		CommandLine,eax
	;Get command line filename
	invoke PathGetArgs,CommandLine
  @@:
	mov		dl,[eax]
	.IF dl==VK_SPACE
		inc		eax
		jmp		@b
	.ELSEIF dl=='"'
		invoke PathUnquoteSpaces,eax
	.ENDIF
	mov		CommandLine,eax
	invoke InitCommonControls
	invoke LoadLibrary,offset RAEditDLL
	.IF eax
		mov		hRAEditDLL,eax
		invoke GetModuleFileName,0,offset FileName,sizeof FileName
		invoke lstrlen,offset FileName
		mov		edx,offset FileName
		add		edx,eax
	  @@:
		dec		edx
		mov		al,[edx]
		.IF al=='.' || al=='\'
			mov		byte ptr [edx],0
		.ENDIF
		.IF al!='\'
			jmp		@b
		.ENDIF
		inc		edx
		invoke lstrcat,offset szSimEd,edx
		invoke SetCurrentDirectory,offset FileName
		invoke RegCreateKeyEx,HKEY_CURRENT_USER,addr szSimEd,0,addr szREG_SZ,0,KEY_WRITE or KEY_READ,0,addr hReg,addr lpdwDisp
		.IF lpdwDisp==REG_OPENED_EXISTING_KEY
			mov		lpcbData,sizeof wpos
			invoke RegQueryValueEx,hReg,addr szWinPos,0,addr lpType,addr wpos,addr lpcbData
			mov		lpcbData,sizeof edopt
			invoke RegQueryValueEx,hReg,addr szEditOpt,0,addr lpType,addr edopt,addr lpcbData
			mov		lpcbData,sizeof lfnt
			invoke RegQueryValueEx,hReg,addr szCodeFont,0,addr lpType,addr lfnt,addr lpcbData
			mov		lpcbData,sizeof lfntlnr
			invoke RegQueryValueEx,hReg,addr szLnrFont,0,addr lpType,addr lfntlnr,addr lpcbData
			mov		lpcbData,sizeof col
			invoke RegQueryValueEx,hReg,addr szColor,0,addr lpType,addr col,addr lpcbData
			mov		lpcbData,sizeof CustColors
			invoke RegQueryValueEx,hReg,addr szCustColors,0,addr lpType,addr CustColors,addr lpcbData
			mov		lpcbData,40
			invoke RegQueryValueEx,hReg,addr szKeyWordColor,0,addr lpType,addr kwcol,addr lpcbData
			mov		lpcbData,sizeof ppos
			invoke RegQueryValueEx,hReg,addr szPrnPos,0,addr lpType,addr ppos,addr lpcbData
			mov		eax,ppos.margins.left
			mov		psd.rtMargin.left,eax
			mov		eax,ppos.margins.top
			mov		psd.rtMargin.top,eax
			mov		eax,ppos.margins.right
			mov		psd.rtMargin.right,eax
			mov		eax,ppos.margins.bottom
			mov		psd.rtMargin.bottom,eax
			mov		eax,ppos.pagesize.x
			mov		psd.ptPaperSize.x,eax
			mov		eax,ppos.pagesize.y
			mov		psd.ptPaperSize.y,eax
		.ENDIF
		invoke OleInitialize,NULL
		invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
		push	eax
		invoke FreeLibrary,hRAEditDLL
		invoke RegSetValueEx,hReg,addr szWinPos,0,REG_BINARY,addr wpos,sizeof wpos
		invoke RegCloseKey,hReg
		invoke OleUninitialize
		pop		eax
	.ELSE
		invoke MessageBox,NULL,offset RAEditFail,offset szAppName,MB_OK
	.ENDIF
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
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		hIcon,eax
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc

	mov		wc.lpfnWndProc,offset PreviewProc
	mov		wc.cbWndExtra,NULL
	mov		wc.lpszMenuName,NULL
	invoke GetStockObject,LTGRAY_BRUSH
	mov		wc.hbrBackground,eax
	mov		wc.lpszClassName,offset PreviewClass
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_DLG,NULL,offset WndProc,NULL
	mov		hWnd,eax
	.IF wpos.fMax
		mov		eax,SW_MAXIMIZE
	.ELSE
		mov		eax,SW_SHOWNORMAL
	.ENDIF
	invoke ShowWindow,hWnd,eax
	test	wpos.fView,4
	.IF !ZERO?
		invoke ShowWindow,hVSplit,SW_SHOWNA
		invoke ShowWindow,hOut,SW_SHOWNA
	.ENDIF
	invoke UpdateWindow,hWnd
	invoke LoadAccelerators,hInstance,IDR_ACCEL
	mov		hAccel,eax
	;Get command line filename
	mov		edx,CommandLine
	mov		al,[edx]
	.IF al
		invoke lstrcpy,offset FileName,edx
		invoke TabToolSetText,0,offset FileName
		invoke LoadFile,hREd,offset FileName
	.ENDIF
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .break .IF !eax
		invoke IsDialogMessage,hFind,addr msg
		.IF !eax
			invoke TranslateAccelerator,hWnd,hAccel,addr msg
			.IF !eax
				invoke TranslateMessage,addr msg
				invoke DispatchMessage,addr msg
			.ENDIF
		.ENDIF
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

CreateRAEdit proc

	invoke ShowWindow,hREd,SW_HIDE
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szEditClass,NULL,WS_CHILD or WS_VISIBLE or STYLE_DRAGDROP or STYLE_SCROLLTIP or STYLE_HILITECOMMENT,0,0,0,0,hWnd,NULL,hInstance,0
	mov		hREd,eax
	invoke SetFormat,hREd
	;Set colors
	invoke SendMessage,hREd,REM_SETCOLOR,0,addr col
	invoke SendMessage,hREd,REM_SETSTYLEEX,STYLEEX_BLOCKGUIDE or STILEEX_LINECHANGED,0
	invoke SendMessage,hWnd,WM_SIZE,0,0
	ret

CreateRAEdit endp

CreateNew proc

	invoke lstrcpy,offset FileName,offset NewFile
	invoke CreateRAEdit
	invoke TabToolAdd,hREd,offset FileName
	invoke SetWinCaption,offset FileName
	invoke SetFocus,hREd
	ret

CreateNew endp

UpdateAll proc uses ebx,nFunction:DWORD
	LOCAL	nInx:DWORD
	LOCAL	tci:TCITEM

	invoke SendMessage,hTab,TCM_GETITEMCOUNT,0,0
	mov		nInx,eax
	mov		tci.imask,TCIF_PARAM
	.while nInx
		dec		nInx
		invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
		.IF eax
			mov		ebx,tci.lParam
			mov		eax,nFunction
			.IF eax==WM_SETFONT
				invoke SendMessage,[ebx].TABMEM.hwnd,REM_SETCOLOR,0,addr col
				invoke SetFormat,[ebx].TABMEM.hwnd
			.ELSEIF eax==WM_PAINT
				invoke SendMessage,[ebx].TABMEM.hwnd,REM_REPAINT,0,0
			.ELSEIF eax==WM_CLOSE
				invoke SendMessage,[ebx].TABMEM.hwnd,EM_GETMODIFY,0,0
				.IF eax
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
				.ENDIF
			.ELSEIF eax==WM_DESTROY
				invoke SendMessage,hTab,TCM_DELETEITEM,nInx,0
				invoke DestroyWindow,[ebx].TABMEM.hwnd
				invoke GetProcessHeap
				invoke HeapFree,eax,NULL,ebx
			.ELSEIF eax==IS_OPEN
				invoke lstrcmpi,offset FileName,addr [ebx].TABMEM.filename
				.IF !eax
					invoke SendMessage,hTab,TCM_SETCURSEL,nInx,0
					invoke TabToolActivate
					mov		eax,TRUE
					jmp		Ex
				.ENDIF
				xor		eax,eax
			.ELSEIF eax==SAVE_ALL
				invoke SendMessage,[ebx].TABMEM.hwnd,EM_GETMODIFY,0,0
				.IF eax
					invoke SaveEdit,[ebx].TABMEM.hwnd,addr [ebx].TABMEM.filename
				.ENDIF
			.ENDIF
		.ENDIF
	.endw
  Ex:
	ret

UpdateAll endp

HiliteSelection proc nColor:DWORD
	LOCAL	nLine:DWORD
	LOCAL	chrg:CHARRANGE

	invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
	invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
	mov		nLine,eax
	.while TRUE
		invoke SendMessage,hREd,REM_SETHILITELINE,nLine,nColor
		inc		nLine
		invoke SendMessage,hREd,EM_LINEINDEX,nLine,0
		.break .IF eax>=chrg.cpMax || eax<=chrg.cpMin
		invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,eax
		.break .IF eax< nLine
	.endw
	ret

HiliteSelection endp

LockSelection proc fLock:DWORD
	LOCAL	nLine:DWORD
	LOCAL	chrg:CHARRANGE

	invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
	invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
	mov		nLine,eax
	.while TRUE
		invoke SendMessage,hREd,REM_LOCKLINE,nLine,fLock
		invoke SendMessage,hREd,REM_SETHILITELINE,nLine,fLock
		inc		nLine
		invoke SendMessage,hREd,EM_LINEINDEX,nLine,0
		.break .IF eax>=chrg.cpMax || eax<=chrg.cpMin
		invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,eax
		.break .IF eax< nLine
	.endw
	ret

LockSelection endp

HideSelection proc
	LOCAL	nLine:DWORD
;	LOCAL	nBmID:DWORD
	LOCAL	chrg:CHARRANGE
;	LOCAL	pt:POINT

	invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
;	Testing EM_POSFROMCHAR
;	invoke SendMessage,hREd,EM_POSFROMCHAR,addr pt,chrg.cpMin
;	mov		eax,pt.x
;	PrintHex eax
;	mov		eax,pt.y
;	PrintHex eax
	invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
	mov		nLine,eax
	invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,chrg.cpMax
	.IF eax>nLine
		sub		eax,nLine
		invoke SendMessage,hREd,REM_HIDELINES,nLine,eax
	.ENDIF
	invoke SetFocus,hREd
	ret

HideSelection endp

TimerProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	chrg:CHARRANGE
	LOCAL	blrg:BLOCKRANGE

	.IF fTimer
		dec		fTimer
		.IF !fTimer
			invoke SendMessage,hREd,EM_CANUNDO,0,0
			mov		edx,IDM_EDIT_UNDO
			call	EnableDisable
			invoke SendMessage,hREd,EM_CANREDO,0,0
			mov		edx,IDM_EDIT_REDO
			call	EnableDisable
			invoke SendMessage,hREd,REM_GETMODE,0,0
			test	eax,MODE_BLOCK
			.IF ZERO?
				invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
				mov		eax,chrg.cpMax
				sub		eax,chrg.cpMin
			.ELSE
				invoke SendMessage,hREd,REM_GETBLOCK,0,addr blrg
				mov		eax,blrg.clMax
				sub		eax,blrg.clMin
			.ENDIF
			mov		edx,IDM_EDIT_CUT
			call	EnableDisable
			mov		edx,IDM_EDIT_COPY
			call	EnableDisable
			mov		edx,IDM_EDIT_DELETE
			call	EnableDisable
			invoke SendMessage,hREd,EM_CANPASTE,CF_TEXT,0
			mov		edx,IDM_EDIT_PASTE
			call	EnableDisable
			invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
			mov		ebx,eax
			invoke SendMessage,hREd,REM_NXTBOOKMARK,ebx,3
			inc		eax
			mov		edx,IDM_EDIT_NEXTBM
			call	EnableDisable
			invoke SendMessage,hREd,REM_PRVBOOKMARK,ebx,3
			inc		eax
			mov		edx,IDM_EDIT_PREVBM
			call	EnableDisable
			invoke SendMessage,hREd,REM_NXTBOOKMARK,-1,3
			inc		eax
			mov		edx,IDM_EDIT_CLEARBM
			call	EnableDisable
			invoke SendMessage,hREd,REM_GETMODE,0,0
			and		eax,MODE_BLOCK
			mov		edx,IDM_EDIT_BLOCKINSERT
			call	EnableDisable
			.if !eax
				mov		eax,MF_BYCOMMAND or MF_UNCHECKED
			.else
				mov		eax,MF_BYCOMMAND or MF_CHECKED
			.endif
			invoke CheckMenuItem,hMnu,IDM_EDIT_BLOCKMODE,eax
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

VSplitProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	min:DWORD
	LOCAL	max:DWORD

	mov		eax,uMsg
	.if eax==WM_LBUTTONDOWN
		invoke SetCapture,hWin
		invoke SetCursor,hHSplitCur
		mov		fVSplit,TRUE
	.elseif eax==WM_LBUTTONUP
		invoke ReleaseCapture
		mov		fVSplit,FALSE
	.elseif eax==WM_MOUSEMOVE
		invoke SetCursor,hHSplitCur
		.if fVSplit
			invoke GetCursorPos,addr pt
			invoke ScreenToClient,hWnd,addr pt
			test	wpos.fView,2
			.if !ZERO?
				;Get handle of statusbar
				invoke GetDlgItem,hWnd,IDC_SBR
				mov		edx,eax
				;Get height of statusbar
				invoke GetWindowRect,edx,addr rect
				mov		eax,rect.bottom
				sub		eax,rect.top
			.endif
			mov		max,eax
			test	wpos.fView,1
			.if !ZERO?
				;Get handle of toolbar
				invoke GetDlgItem,hWnd,IDC_TBR
				mov		edx,eax
				;Get height of toolbar
				invoke GetWindowRect,edx,addr rect
				mov		eax,rect.bottom
				sub		eax,rect.top
			.endif
			add		eax,TABHT
			add		eax,32
			mov		min,eax
			invoke GetClientRect,hWnd,addr rect
			mov		eax,rect.bottom
			sub		eax,max
			push	eax
			sub		eax,30
			mov		max,eax
			pop		eax
			mov		edx,pt.y
			.if sdword ptr edx>max
				mov		edx,max
			.elseif sdword ptr edx<min
				mov		edx,min
			.endif
			sub		eax,edx
			sub		eax,RESIZEHT
			.if eax!=wpos.htout
				mov		wpos.htout,eax
				invoke SendMessage,hWnd,WM_SIZE,0,0
				invoke UpdateWindow,hREd
				invoke UpdateWindow,hOut
			.endif
		.endif
	.else
		invoke CallWindowProc,lpOldVSplitProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor		eax,eax
	ret

VSplitProc endp

WndProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	ht:DWORD
	LOCAL	hCtl:HWND
	LOCAL	chrg:CHARRANGE
	LOCAL	cf:CHOOSEFONT
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	mnu:MENU

	mov		eax,uMsg
	.if eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke GetDlgItem,hWin,IDC_SHP
		mov		hCtl,eax
		test	wpos.fView,1
		.if !ZERO?
			;Resize toolbar
			.if lParam
				invoke MoveWindow,hCtl,0,0,rect.right,27,TRUE
				invoke ShowWindow,hCtl,SW_SHOW
				invoke GetDlgItem,hWin,IDC_TBR
				mov		hCtl,eax
				mov		eax,rect.right
				sub		eax,4
				invoke MoveWindow,hCtl,2,2,eax,23,TRUE
				invoke ShowWindow,hCtl,SW_SHOW
			.endif
			mov		eax,27
		.else
			invoke ShowWindow,hCtl,SW_HIDE
			invoke GetDlgItem,hWin,IDC_TBR
			invoke ShowWindow,eax,SW_HIDE
			xor		eax,eax
		.endif
		push	eax
		invoke GetDlgItem,hWin,IDC_SBR
		mov		hCtl,eax
		test	wpos.fView,2
		.if !ZERO?
			;Resize statusbar
			.if lParam
				mov		eax,rect.bottom
				sub		eax,21
				invoke MoveWindow,hCtl,0,eax,rect.right,21,TRUE
				invoke ShowWindow,hCtl,SW_SHOW
			.endif
			;Get height of statusbar
			mov		eax,21
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
		.if lParam
			;Resize tab window
			mov		edx,rect.right
			sub		edx,CBOWT
			push	edx
			inc		edx
			invoke MoveWindow,hTab,-1,rect.top,edx,TABHT,TRUE
			invoke UpdateWindow,hTab
			pop		edx
			;Resize combobox
			mov		eax,rect.right
			sub		eax,edx
			invoke MoveWindow,hCbo,edx,rect.top,eax,CBOWT,TRUE
			invoke UpdateWindow,hCbo
		.endif
		;Add height of tab window to top
		add		rect.top,TABHT
		test	wpos.fView,4
		.if !ZERO?
			;Subtract height of resize from bottom
			sub		rect.bottom,RESIZEHT
			;Subtract height of output from bottom
			mov		eax,wpos.htout
			sub		rect.bottom,eax
		.endif
		;Get new height of RAEdit window
		mov		eax,rect.bottom
		sub		eax,rect.top
		mov		ht,eax
		;Resize RAEdit window
		invoke MoveWindow,hREd,0,rect.top,rect.right,ht,TRUE
		test	wpos.fView,4
		.if !ZERO?
			mov		eax,ht
			add		rect.top,eax
			;Resize resizebar
			mov		eax,rect.right
			add		eax,2
			invoke MoveWindow,hVSplit,-1,rect.top,eax,RESIZEHT,TRUE
			invoke UpdateWindow,hVSplit
			add		rect.top,RESIZEHT
			;Resize Output window
			invoke MoveWindow,hOut,0,rect.top,rect.right,wpos.htout,TRUE
			invoke UpdateWindow,hOut
			invoke ShowWindow,hOut,SW_SHOW
		.else
			invoke ShowWindow,hVSplit,SW_HIDE
			invoke ShowWindow,hOut,SW_HIDE
		.endif
	.elseif eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
		invoke MoveWindow,hWin,wpos.x,wpos.y,wpos.wt,wpos.ht,TRUE
		mov		fr,FR_DOWN
		invoke LoadCursor,hInstance,IDC_HSPLIT
		mov		hHSplitCur,eax
		invoke LoadCursor,hInstance,IDC_VSPLIT
		mov		hVSplitCur,eax
		;Set the toolbar buttons
		invoke GetDlgItem,hWin,IDC_TBR
		invoke DoToolBar,hInstance,eax
		;Set FileName to NewFile
		invoke lstrcpy,offset FileName,offset NewFile
		invoke SetWinCaption,offset FileName
		;Get handle of resize window
		invoke GetDlgItem,hWin,IDC_VSPLITBAR
		mov		hVSplit,eax
		;Subclass
		invoke SetWindowLong,hVSplit,GWL_WNDPROC,offset VSplitProc
		mov		lpOldVSplitProc,eax
		;Get handle of output window
		invoke GetDlgItem,hWin,IDC_OUT
		mov		hOut,eax
		;Get handle of RAEdit window
		invoke GetDlgItem,hWin,IDC_RAE
		mov		hREd,eax
		invoke SendMessage,hREd,REM_SETSTYLEEX,STYLEEX_BLOCKGUIDE,0
		;Set hilite words
		invoke SetKeyWords,hREd
		;Set block defs
		invoke SetBlockDefs,hREd
		;Create line number font
		invoke CreateFontIndirect,offset lfntlnr
		mov     hLnrFont,eax
		;Create normal font
		invoke CreateFontIndirect,offset lfnt
		mov     hFont,eax
		mov		al,lfnt.lfItalic
		push	eax
		;Create italics font
		mov		lfnt.lfItalic,TRUE
		invoke CreateFontIndirect,offset lfnt
		mov     hIFont,eax
		pop		eax
		mov		lfnt.lfItalic,al
		;Set font & format
		invoke SetFormat,hREd
		;Set colors
		invoke SendMessage,hREd,REM_SETCOLOR,0,addr col
		;Init RAEdit
		invoke SendMessage,hREd,EM_SETMODIFY,FALSE,0
		invoke SendMessage,hREd,EM_EMPTYUNDOBUFFER,0,0
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
		invoke GetDlgItem,hWin,IDC_CBO
		mov		hCbo,eax
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
		invoke SendMessage,hWin,WM_SETFONT,hFont,FALSE
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
.if hUndo
	invoke SendMessage,hREd,REM_SETUNDO,nUndoSize,hUndo
.endif
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

invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*1024
mov		hUndo,eax
mov		edi,eax
invoke SendMessage,hREd,REM_GETUNDO,10*1024,edi
mov		ebx,eax
mov		nUndoSize,eax
.while sdword ptr ebx>0
;	mov		eax,[edi].RAUNDO.rpPrev
;	PrintDec eax
;	mov		eax,[edi].RAUNDO.undoid
;	PrintDec eax
;	mov		eax,[edi].RAUNDO.cp
;	PrintDec eax
;	mov		eax,[edi].RAUNDO.cb
;	PrintDec eax
;	movzx	eax,[edi].RAUNDO.fun
;	PrintDec eax
;	lea		eax,[edi+sizeof RAUNDO]
;	PrintStringByAddr eax
	mov		eax,[edi].RAUNDO.cb
	sub		ebx,eax
	sub		ebx,sizeof RAUNDO
	lea		edi,[edi+eax+sizeof RAUNDO]
.endw
					invoke DestroyWindow,hREd
					invoke TabToolDel,hREd
				.endif
				mov		fTimer,1
			.elseif eax==IDM_FILE_PAGESETUP
				invoke GetPrnCaps
				mov		psd.lStructSize,sizeof psd
				mov		eax,hWin
				mov		psd.hwndOwner,eax
				mov		eax,hInstance
				mov		psd.hInstance,eax
				.if prnInches
					mov		eax,PSD_MARGINS or PSD_INTHOUSANDTHSOFINCHES
				.else
					mov		eax,PSD_MARGINS or PSD_INHUNDREDTHSOFMILLIMETERS
				.endif
				mov		psd.Flags,eax
				invoke PageSetupDlg,addr psd
				.if eax
					mov		eax,psd.rtMargin.left
					mov		ppos.margins.left,eax
					mov		eax,psd.rtMargin.top
					mov		ppos.margins.top,eax
					mov		eax,psd.rtMargin.right
					mov		ppos.margins.right,eax
					mov		eax,psd.rtMargin.bottom
					mov		ppos.margins.bottom,eax
					mov		eax,psd.ptPaperSize.x
					mov		ppos.pagesize.x,eax
					mov		eax,psd.ptPaperSize.y
					mov		ppos.pagesize.y,eax
					invoke RegSetValueEx,hReg,addr szPrnPos,0,REG_BINARY,addr ppos,sizeof ppos
				.endif
			.elseif eax==IDM_FILE_PRINT_PREVIEW
				;invoke CreatePreView,hWin,hREd
				invoke DialogBoxParam,hInstance,IDD_DLGPRINTPREVIEW,hWin,offset PrintPreviewProc,0
			.elseif eax==IDM_FILE_PRINT
				mov		pd.lStructSize,sizeof pd
				mov		eax,hWin
				mov		pd.hwndOwner,eax
				mov		eax,hInstance
				mov		pd.hInstance,eax
				invoke SendMessage,hREd,EM_GETLINECOUNT,0,0
				inc		eax
				mov		ecx,ppos.nlinespage
				.if !ecx
					mov		ecx,66
				.endif
				xor		edx,edx
				div		ecx
				.if edx
					inc		eax
				.endif
				mov		pd.nMinPage,1
				mov		pd.nMaxPage,ax
				mov		pd.nFromPage,1
				mov		pd.nToPage,ax
				invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
				mov		eax,chrg.cpMin
				.if eax!=chrg.cpMax
					mov		eax,PD_RETURNDC or PD_SELECTION
				.else
					mov		eax,PD_RETURNDC or PD_NOSELECTION; or PD_PAGENUMS
				.endif
				mov		pd.Flags,eax
				invoke PrintDlg,addr pd
				.if eax
					invoke Print,TRUE
				.endif
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
					invoke SendMessage,hREd,EM_EXGETSEL,0,addr ft.chrg
					mov		eax,ft.chrg.cpMax
					sub		eax,ft.chrg.cpMin
					add		ft.chrg.cpMin,eax
					mov		ft.chrg.cpMax,-1
					invoke Find,FR_DOWN
				.endif
			.elseif eax==IDM_EDIT_FINDPREV
				.if !hFind
					invoke GetSelText,offset findbuff
				.endif
				mov		al,findbuff
				.if al
					invoke SendMessage,hREd,EM_EXGETSEL,0,addr ft.chrg
					dec		ft.chrg.cpMin
					mov		ft.chrg.cpMax,0
					invoke Find,0
				.endif
			.elseif eax==IDM_EDIT_INDENT
				invoke IndentComment,VK_TAB,TRUE
			.elseif eax==IDM_EDIT_OUTDENT
				invoke IndentComment,VK_TAB,FALSE
			.elseif eax==IDM_EDIT_COMMENT
				invoke IndentComment,';',TRUE
			.elseif eax==IDM_EDIT_UNCOMMENT
				invoke IndentComment,';',FALSE
			.elseif eax==IDM_EDIT_BLOCKMODE
				invoke SendMessage,hREd,REM_GETMODE,0,0
				xor		eax,MODE_BLOCK
				invoke SendMessage,hREd,REM_SETMODE,eax,0
				mov		fTimer,1
			.elseif eax==IDM_EDIT_BLOCKINSERT
				invoke CreateDialogParam,hInstance,IDD_BLOCKDLG,hWin,addr BlockDlgProc,0
			.elseif eax==IDM_EDIT_TOGGLEBM
				invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
				invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
				mov		ebx,eax
				invoke SendMessage,hREd,REM_GETBOOKMARK,ebx,0
				.if !eax
					invoke SendMessage,hREd,REM_SETBOOKMARK,ebx,3
				.elseif eax==3
					invoke SendMessage,hREd,REM_SETBOOKMARK,ebx,0
				.endif
				mov		fTimer,1
			.elseif eax==IDM_EDIT_NEXTBM
				invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
				invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
				invoke SendMessage,hREd,REM_NXTBOOKMARK,eax,3
				.if eax!=-1
					invoke SendMessage,hREd,EM_LINEINDEX,eax,0
					mov		chrg.cpMin,eax
					mov		chrg.cpMax,eax
					invoke SendMessage,hREd,EM_EXSETSEL,0,addr chrg
					invoke SendMessage,hREd,EM_SCROLLCARET,0,0
				.endif
			.elseif eax==IDM_EDIT_PREVBM
				invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
				invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
				invoke SendMessage,hREd,REM_PRVBOOKMARK,eax,3
				.if eax!=-1
					invoke SendMessage,hREd,EM_LINEINDEX,eax,0
					mov		chrg.cpMin,eax
					mov		chrg.cpMax,eax
					invoke SendMessage,hREd,EM_EXSETSEL,0,addr chrg
					invoke SendMessage,hREd,EM_SCROLLCARET,0,0
				.endif
			.elseif eax==IDM_EDIT_CLEARBM
				invoke SendMessage,hREd,REM_CLRBOOKMARKS,0,3
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
				invoke SendMessage,hOut,WM_SIZE,0,0
			.elseif eax==IDM_VIEW_OUTPUT
				xor		wpos.fView,4
				invoke SendMessage,hWin,WM_SIZE,0,1
				test	wpos.fView,4
				.if !ZERO?
					invoke ShowWindow,hVSplit,SW_SHOWNA
					invoke ShowWindow,hOut,SW_SHOWNA
				.else
					invoke ShowWindow,hVSplit,SW_HIDE
					invoke ShowWindow,hOut,SW_HIDE
				.endif
			.elseif eax==IDM_MAKE_COMPILE
				invoke UpdateAll,SAVE_ALL
				invoke OutputMake,IDM_MAKE_COMPILE,offset FileName,TRUE
			.elseif eax==IDM_MAKE_ASSEMBLE
				invoke UpdateAll,SAVE_ALL
				invoke OutputMake,IDM_MAKE_ASSEMBLE,offset FileName,TRUE
			.elseif eax==IDM_MAKE_LINK
				invoke UpdateAll,SAVE_ALL
				invoke OutputMake,IDM_MAKE_LINK,offset FileName,TRUE
			.elseif eax==IDM_MAKE_RUN
				invoke UpdateAll,SAVE_ALL
				invoke lstrcpy,addr buffer,offset FileName
				invoke RemoveFileExt,addr buffer
				invoke lstrcat,addr buffer,offset ExtExe
				invoke WinExec,addr buffer,SW_SHOWNORMAL
			.elseif eax==IDM_MAKE_GO
				invoke UpdateAll,SAVE_ALL
				invoke OutputMake,IDM_MAKE_COMPILE,offset FileName,2
				or		eax,eax
				jne		Ex
				invoke OutputMake,IDM_MAKE_ASSEMBLE,offset FileName,0
				or		eax,eax
				jne		Ex
				invoke OutputMake,IDM_MAKE_LINK,offset FileName,3
				or		eax,eax
				jne		Ex
				invoke lstrcpy,addr buffer,offset FileName
				invoke RemoveFileExt,addr buffer
				invoke lstrcat,addr buffer,offset ExtExe
				invoke WinExec,addr buffer,SW_SHOWNORMAL
			.elseif eax==IDM_OPTION_FONT
				invoke RtlZeroMemory,addr cf,sizeof cf
				mov		cf.lStructSize,sizeof cf
				mov		eax,hWin
				mov		cf.hwndOwner,eax
				mov		cf.lpLogFont,offset lfnt
				mov		cf.Flags,CF_SCREENFONTS or CF_EFFECTS or CF_INITTOLOGFONTSTRUCT
				mov		eax,col.txtcol
				mov		cf.rgbColors,eax
				invoke ChooseFont,addr cf
				.if eax
					invoke DeleteObject,hFont
					mov		al,lfnt.lfItalic
					push	eax
					invoke CreateFontIndirect,offset lfnt
					mov     hFont,eax
					invoke DeleteObject,hIFont
					mov		lfnt.lfItalic,TRUE
					invoke CreateFontIndirect,offset lfnt
					mov     hIFont,eax
					pop		eax
					mov		lfnt.lfItalic,al
					mov		eax,cf.rgbColors
					mov		col.txtcol,eax
					invoke UpdateAll,WM_SETFONT
					invoke RegSetValueEx,hReg,addr szCodeFont,0,REG_BINARY,addr lfnt,sizeof lfnt
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
					invoke SendMessage,hREd,REM_SETCOLOR,0,addr col
					invoke UpdateAll,WM_SETFONT
					invoke RegSetValueEx,hReg,addr szLnrFont,0,REG_BINARY,addr lfntlnr,sizeof lfntlnr
					invoke RegSetValueEx,hReg,addr szColor,0,REG_BINARY,addr col,sizeof col
				.endif
				invoke SetFocus,hREd
			.elseif eax==IDM_OPTION_KEYWORDS
				invoke DialogBoxParam,hInstance,IDD_DLGKEYWORDS,hWin,offset KeyWordsProc,0
			.elseif eax==IDM_OPTION_TOOLS
				invoke DialogBoxParam,hInstance,IDD_DLGOPTMNU,hWin,offset MenuOptionProc,1
				invoke SetToolMenu
			.elseif eax==IDM_OPTION_HELP
				invoke DialogBoxParam,hInstance,IDD_DLGOPTMNU,hWin,offset MenuOptionProc,2
				invoke SetHelpMenu
			.elseif eax==IDM_HELP_ABOUT
				invoke DialogBoxParam,hInstance,IDD_DLGABOUT,hWin,offset AboutProc,0
				invoke SetFocus,hREd
			.elseif eax==IDM_DEMO_HILITE1
				invoke HiliteSelection,1
			.elseif eax==IDM_DEMO_HILITE2
				invoke HiliteSelection,2
			.elseif eax==IDM_DEMO_HILITE3
				invoke HiliteSelection,3
			.elseif eax==IDM_DEMO_HILITEOFF
				invoke HiliteSelection,0
			.elseif eax==IDM_DEMO_LOCK
				invoke LockSelection,TRUE
			.elseif eax==IDM_DEMO_UNLOCK
				invoke LockSelection,FALSE
			.elseif eax==IDM_DEMO_SPEED_TEST
				xor		eax,eax
				.while eax<5000
					push	eax
					invoke SendMessage,hREd,WM_KEYDOWN,22h,1510000h
					pop		eax
					inc		eax
				.endw
				invoke MessageBeep,MB_OK
			.elseif eax==IDM_DEMO_HIDE
				invoke HideSelection
			.elseif eax==IDM_DEMO_LINELENGHT
				invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
				invoke SendMessage,hREd,EM_LINELENGTH,chrg.cpMin,0
			.elseif ax==-3
				;Expand button clicked
				invoke SendMessage,hREd,REM_EXPANDALL,0,0
				invoke SendMessage,hREd,EM_SCROLLCARET,0,0
				invoke SendMessage,hREd,REM_REPAINT,0,0
			.elseif ax==-4
				;Collapse button clicked
				invoke SendMessage,hREd,REM_COLLAPSEALL,0,0
				invoke SendMessage,hREd,EM_SCROLLCARET,0,0
				invoke SendMessage,hREd,REM_REPAINT,0,0
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
					invoke SendMessage,hREd,REM_GETWORD,sizeof buffer,addr buffer
					invoke WinHelp,hWin,addr mnu.szcmnd,HELP_KEY,addr buffer
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
			.elseif eax==IDC_CBO
				invoke SelectCombo
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		edx,lParam
		mov		eax,[edx].NMHDR.code
		.if eax==EN_SELCHANGE
			mov		edi,edx
			mov		eax,[edi].RASELCHANGE.chrg.cpMin
			sub		eax,[edi].RASELCHANGE.cpLine
			invoke ShowPos,[edi].RASELCHANGE.line,eax
			.if [edi].RASELCHANGE.seltyp==SEL_OBJECT
				invoke SendMessage,hREd,REM_GETBOOKMARK,[edi].RASELCHANGE.line,0
				.if eax==1
					;Collapse
					invoke SendMessage,hREd,REM_COLLAPSE,[edi].RASELCHANGE.line,0
				.elseif eax==2
					;Expand
					invoke SendMessage,hREd,REM_EXPAND,[edi].RASELCHANGE.line,0
				.elseif eax==8
					;Expand hidden lines
					invoke SendMessage,hREd,REM_EXPAND,[edi].RASELCHANGE.line,0
				.else
					;Clear bookmark
					invoke SendMessage,hREd,REM_SETBOOKMARK,[edi].RASELCHANGE.line,0
				.endif
			.else
;				;Just to test REM_ISCHARPOS message
;				invoke SendMessage,hREd,REM_ISCHARPOS,[edi].RASELCHANGE.chrg.cpMin,0
;				.if eax
;					invoke MessageBeep,0FFFFFFFFh
;				.endif
				invoke SendMessage,hREd,REM_BRACKETMATCH,0,0
				invoke SendMessage,hREd,REM_SETHILITELINE,prvline,0
				mov		eax,[edi].RASELCHANGE.line
				mov		prvline,eax
				.if edopt.hiliteline
					invoke SendMessage,hREd,REM_SETHILITELINE,prvline,2
				.endif
				.if [edi].RASELCHANGE.fchanged
					.if ![edi].RASELCHANGE.nWordGroup
						invoke SendMessage,hREd,REM_SETCOMMENTBLOCKS,addr szCmntStart,addr szCmntEnd
					.endif
				  OnceMore:
					invoke SendMessage,hREd,REM_GETBOOKMARK,nLastLine,0
					mov		ebx,eax
					mov		esi,offset blocks
					mov		ecx,[esi]
					xor		eax,eax
					dec		eax
					.while ecx
						mov		edx,[ecx].RABLOCKDEF.flag
						shr		edx,16
						.if edx==[edi].RASELCHANGE.nWordGroup
							mov		ecx,[ecx].RABLOCKDEF.lpszStart

							invoke SendMessage,hREd,REM_ISLINE,nLastLine,ecx
						.endif
						.break .if eax!=-1
						add		esi,4
						mov		ecx,[esi]
					.endw
					.if eax==-1
						.if ebx==1 || ebx==2
							.if ebx==2
								invoke SendMessage,hREd,REM_EXPAND,nLastLine,0
							.endif
							invoke SendMessage,hREd,REM_SETBOOKMARK,nLastLine,0
							invoke SendMessage,hREd,REM_SETDIVIDERLINE,nLastLine,FALSE
							invoke SendMessage,hREd,REM_SETSEGMENTBLOCK,nLastLine,FALSE
						.endif
					.else
						xor		eax,eax
						mov		ecx,[esi]
						test	[ecx].RABLOCKDEF.flag,BD_NONESTING
						.if !ZERO?
							invoke SendMessage,hREd,REM_ISINBLOCK,nLastLine,ecx
						.endif
						.if !eax
							mov		edx,nLastLine
							inc		edx
							invoke SendMessage,hREd,REM_ISLINEHIDDEN,edx,0
							.if eax
								invoke SendMessage,hREd,REM_SETBOOKMARK,nLastLine,2
							.else
								invoke SendMessage,hREd,REM_SETBOOKMARK,nLastLine,1
							.endif
							mov		edx,[esi]
							mov		edx,[edx].RABLOCKDEF.flag
							and		edx,BD_DIVIDERLINE
							invoke SendMessage,hREd,REM_SETDIVIDERLINE,nLastLine,edx
							mov		edx,[esi]
							mov		edx,[edx].RABLOCKDEF.flag
							and		edx,BD_SEGMENTBLOCK
							invoke SendMessage,hREd,REM_SETSEGMENTBLOCK,nLastLine,edx
						.endif
					.endif
					mov		eax,[edi].RASELCHANGE.line
					.if eax>nLastLine
						inc		nLastLine
						jmp		OnceMore
					.elseif eax<nLastLine
						dec		nLastLine
						jmp		OnceMore
					.endif
				.endif
				mov		eax,[edi].RASELCHANGE.line
				mov		nLastLine,eax
			.endif
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
		invoke DeleteObject,hIFont
		invoke DeleteObject,hLnrFont
		invoke DestroyCursor,hVSplitCur
		invoke DestroyCursor,hHSplitCur
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
			invoke CheckMenuItem,wParam,IDM_VIEW_OUTPUT,edx
		.endif
	.elseif eax==WM_DROPFILES
		invoke DragQueryFile,wParam,0,addr buffer,sizeof buffer
		invoke OpenEditFile,addr buffer
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
  Ex:
	xor    eax,eax
	ret

WndProc endp

end start
