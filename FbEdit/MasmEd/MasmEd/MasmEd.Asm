.486
.model flat,stdcall
option casemap:none

include MasmEd.inc
include Tool\TabTool.asm
include Tool\PropertyTool.asm
include Misc\Misc.asm
include Misc\FileIO.asm
include Misc\Find.asm
include Misc\Make.asm
include Misc\Addins.asm
include Opt\KeyWords.asm
include Opt\MenuOption.asm
include Opt\TabOptions.Asm
include Opt\BuildOption.Asm
include Misc\Print.asm
include Misc\CodeComplete.asm
include About\About.asm
include Block\Block.asm
include Opt\Debug.asm
include Opt\AddinManager.asm

.code

start:

	invoke GetModuleHandle,NULL
	mov		ha.hInstance,eax
	invoke GetCommandLine
	mov		CommandLine,eax
	;Get command line filename
	invoke PathGetArgs,CommandLine
	mov		CommandLine,eax
	.if byte ptr [eax]
		push	ebx
		mov		ebx,eax
		.while byte ptr [ebx]==VK_SPACE
			inc		ebx
		.endw
		invoke strcmpi,ebx,addr szRemoveMasmEd
		.if !eax
			invoke MessageBox,0,addr szAskRemove,addr szAppName,MB_YESNO or MB_ICONQUESTION
			.if eax==IDYES
				invoke RemoveFromRegistry
				invoke ExitProcess,0
			.endif
		.endif
		pop		ebx
	.endif
	invoke InitCommonControls
	;prepare common control structure
	mov		icex.dwSize,sizeof INITCOMMONCONTROLSEX
	mov		icex.dwICC,ICC_DATE_CLASSES or ICC_USEREX_CLASSES or ICC_INTERNET_CLASSES or ICC_ANIMATE_CLASS or ICC_HOTKEY_CLASS or ICC_PAGESCROLLER_CLASS or ICC_COOL_CLASSES
	invoke InitCommonControlsEx,addr icex
	invoke LoadLibrary,offset szRichEdit
	mov		hRichEd,eax
	invoke GetModuleFileName,0,offset da.FileName,sizeof da.FileName
	invoke strlen,offset da.FileName
	mov		edx,offset da.FileName
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
	invoke strcat,offset szMasmEd,edx
	invoke SetCurrentDirectory,offset da.FileName
	invoke strcpy,addr da.AppPath,addr da.FileName
	mov		da.lpszVersion,offset szVersion
	invoke RegCreateKeyEx,HKEY_CURRENT_USER,addr szMasmEd,0,addr szREG_SZ,0,KEY_WRITE or KEY_READ,0,addr ha.hReg,addr lpdwDisp
	.if lpdwDisp==REG_OPENED_EXISTING_KEY
		mov		lpcbData,sizeof da.ver
		invoke RegQueryValueEx,ha.hReg,addr szVer,0,addr lpType,addr da.ver,addr lpcbData
		mov		lpcbData,sizeof wpos
		invoke RegQueryValueEx,ha.hReg,addr szWinPos,0,addr lpType,addr wpos,addr lpcbData
		mov		lpcbData,sizeof edopt
		invoke RegQueryValueEx,ha.hReg,addr szEditOpt,0,addr lpType,addr edopt,addr lpcbData
		mov		lpcbData,sizeof lfnt
		invoke RegQueryValueEx,ha.hReg,addr szCodeFont,0,addr lpType,addr lfnt,addr lpcbData
		mov		lpcbData,sizeof lfntlnr
		invoke RegQueryValueEx,ha.hReg,addr szLnrFont,0,addr lpType,addr lfntlnr,addr lpcbData
		mov		lpcbData,sizeof col
		invoke RegQueryValueEx,ha.hReg,addr szColor,0,addr lpType,addr col,addr lpcbData
		.if col.styles==-1
			mov		col.styles,STYLESCOL
		.endif
		.if col.words==-1
			mov		col.words,WORDSCOL
		.endif
		.if da.ver<1053
			push	esi
			push	edi
			mov		esi,offset col.tttext
			mov		edi,offset col.ttsel
			mov		ecx,12
			.while ecx
				mov		eax,[esi]
				mov		[edi],eax
				sub		esi,4
				sub		edi,4
				dec		ecx
			.endw
			mov		col.racol.changed,CHCOL
			mov		col.racol.changesaved,CHSAVEDCOL
			pop		esi
			pop		edi
			invoke RegSetValueEx,ha.hReg,addr szColor,0,REG_BINARY,addr col,sizeof col
			invoke UpdateTheme1053
			mov		da.ver,1053
		.endif
		.if da.ver<1054
			mov		da.ver,1054
		.endif
		.if da.ver<1055
			mov		da.ver,1055
		.endif
		.if da.ver<1056
			mov		da.ver,1056
		.endif
		.if da.ver<1057
			mov		da.ver,1057
		.endif
		.if da.ver<1058
			mov		da.ver,1058
		.endif
		.if da.ver<1059
			mov		da.ver,1059
		.endif
		.if da.ver<1100
			mov		da.ver,1100
		.endif
		.if da.ver<1101
			mov		da.ver,1101
		.endif
		.if da.ver<1102
			mov		da.ver,1102
		.endif
		.if da.ver<1103
			mov		da.ver,1103
		.endif
		.if da.ver<1200
			mov		da.ver,1200
			invoke MakeKey,addr szMenuExternal,1,addr tmpbuff
			invoke RegSetValueEx,ha.hReg,addr tmpbuff,0,REG_BINARY,addr ExternalUpdate,sizeof ExternalUpdate
		.endif
		mov		lpcbData,sizeof CustColors
		invoke RegQueryValueEx,ha.hReg,addr szCustColors,0,addr lpType,addr CustColors,addr lpcbData
		mov		lpcbData,sizeof nmeexp
		invoke RegQueryValueEx,ha.hReg,addr szNmeExp,0,addr lpType,addr nmeexp,addr lpcbData
		mov		lpcbData,sizeof grdsize
		invoke RegQueryValueEx,ha.hReg,addr szGrid,0,addr lpType,addr grdsize,addr lpcbData
		mov		lpcbData,16*4
		invoke RegQueryValueEx,ha.hReg,addr szKeyWordColor,0,addr lpType,addr kwcol,addr lpcbData
		mov		lpcbData,sizeof ppos
		invoke RegQueryValueEx,ha.hReg,addr szPrnPos,0,addr lpType,addr ppos,addr lpcbData
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
		mov		lpcbData,sizeof nmeexp
	.else
		mov		da.ver,1200
	.endif
	invoke RegSetValueEx,ha.hReg,addr szVer,0,REG_BINARY,addr da.ver,sizeof da.ver
	.if wpos.wtfile<50
		mov		wpos.wtfile,175
	.endif
	.if wpos.wtprop<5
		mov		wpos.wtprop,150
	.endif
	.if wpos.htprop<5
		mov		wpos.htprop,200
	.endif
	mov		winsize.htout,0
	mov		eax,wpos.wtprop
	mov		winsize.wtpro,eax
	mov		eax,wpos.htprop
	mov		winsize.htpro,eax
	mov		eax,wpos.wttoolbox
	mov		winsize.wttbx,eax
	mov		eax,wpos.left
	mov		winsize.ptstyle.x,eax
	mov		eax,wpos.top
	mov		winsize.ptstyle.y,eax
	invoke OleInitialize,NULL
	invoke InstallRAEdit,ha.hInstance,TRUE
	invoke RAHexEdInstall,ha.hInstance,FALSE
	invoke GridInstall,ha.hInstance,FALSE
	invoke ResEdInstall,ha.hInstance,FALSE
	invoke InstallProjectBrowser,ha.hInstance,FALSE
	invoke InstallFileBrowser,ha.hInstance,FALSE
	invoke InstallRACodeComplete,ha.hInstance,FALSE
	invoke InstallRAProperty,ha.hInstance,FALSE
	invoke WinMain,ha.hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	push	eax
	invoke UnInstallRAEdit
	invoke RAHexEdUnInstall
	invoke GridUnInstall
	invoke ResEdUninstall
	invoke UnInstallProjectBrowser
	invoke UnInstallFileBrowser
	invoke UnInstallRACodeComplete
	invoke UnInstallRAProperty
	.if hRichEd
		invoke FreeLibrary,hRichEd
	.endif
	invoke RegCloseKey,ha.hReg
	invoke OleUninitialize
	pop		eax
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
	mov		wc.hbrBackground,COLOR_BTNFACE+1;NULL
	mov		wc.lpszMenuName,IDM_MENU
	mov		wc.lpszClassName,offset ClassName
	invoke LoadIcon,hInst,32106
	mov		hIcon,eax
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset ResProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,NULL
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1;NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szResClassName
	xor		eax,eax
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc

	invoke LoadAccelerators,ha.hInstance,IDR_ACCEL
	mov		ha.hAccel,eax
	invoke CreateDialogParam,ha.hInstance,IDD_DLG,NULL,offset WndProc,NULL
	mov		ha.hWnd,eax
	.if wpos.fMax
		mov		eax,SW_MAXIMIZE
	.else
		mov		eax,SW_SHOWNORMAL
	.endif
	invoke ShowWindow,ha.hWnd,eax
	;Toolbar
	test	wpos.fView,1
	.if !ZERO?
		invoke ShowWindow,ha.hShp,SW_SHOWNA
		invoke ShowWindow,ha.hTbr,SW_SHOWNA
		invoke ShowWindow,ha.hStc,SW_SHOWNA
		invoke ShowWindow,ha.hCbo,SW_SHOWNA
	.endif
	;Statusbar
	test	wpos.fView,2
	.if !ZERO?
		invoke ShowWindow,ha.hSbr,SW_SHOWNA
	.endif
	;Output window
	test	wpos.fView,4
	.if !ZERO?
		invoke ShowWindow,ha.hTabOut,SW_SHOWNA
		invoke ShowWindow,ha.hOut,SW_SHOWNA
	.endif
	;File browser
	test	wpos.fView,8
	.if !ZERO?
		invoke ShowWindow,ha.hTabPbr,SW_SHOWNA
		invoke ShowWindow,ha.hBrowse,SW_SHOWNA
		invoke ShowWindow,ha.hProperty,SW_SHOWNA
	.endif
	invoke UpdateWindow,ha.hWnd
	;Get command line filename
	mov		edx,CmdLine
	.if byte ptr [edx]
		invoke OpenCommandLine,CommandLine
	.else
		mov		tmpbuff,0
		mov		lpcbData,sizeof tmpbuff
		invoke RegQueryValueEx,ha.hReg,addr szSession,0,addr lpType,addr tmpbuff,addr lpcbData
		.if byte ptr tmpbuff && edopt.session
			mov		da.MainFile,0
			mov		lpcbData,sizeof da.MainFile
			invoke RegQueryValueEx,ha.hReg,addr szMainFile,0,addr lpType,addr da.MainFile,addr lpcbData
			.if da.MainFile
				invoke GetFileAttributes,addr da.MainFile
				.if eax==INVALID_HANDLE_VALUE
					mov		da.MainFile,0
				.endif
			.endif
			invoke RestoreSession,TRUE
		.endif
	.endif
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .break .if !eax
		invoke IsDialogMessage,ha.hFind,addr msg
		.if !eax
			invoke TranslateAccelerator,ha.hWnd,ha.hAccel,addr msg
			.if !eax
				invoke TranslateMessage,addr msg
				invoke DispatchMessage,addr msg
			.endif
		.endif
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

SetBlockDefs proc uses esi edi,hWin:HWND

	;Reset block defs
	invoke SendMessage,hWin,REM_ADDBLOCKDEF,0,0
	mov		esi,offset blocks
	.while dword ptr [esi]
		invoke SendMessage,hWin,REM_ADDBLOCKDEF,0,[esi]
		mov		edi,[esi]
		mov		eax,[edi].RABLOCKDEF.lpszStart
		call	TestIt
		mov		eax,[edi].RABLOCKDEF.lpszEnd
		call	TestIt
		add		esi,4
	.endw
	invoke SendMessage,hWin,REM_BRACKETMATCH,0,offset szBracketMatch
	ret

TestIt:
	.if eax
		.while byte ptr [eax]
			.if byte ptr [eax]=='|'
				mov		byte ptr [eax],0
			.endif
			inc		eax
		.endw
	.endif
	retn

SetBlockDefs endp

RAEditProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	chrg:CHARRANGE
	LOCAL	ti:TOOLINFO
	LOCAL	buffer[256]:BYTE
	LOCAL	pt:POINT
	LOCAL	dbgtip:DEBUGTIP
	LOCAL	isinproc:ISINPROC
	LOCAL	trng:TEXTRANGE

	mov		eax,uMsg
	.if eax==WM_CHAR
		mov		eax,wParam
		.if eax==VK_TAB || eax==VK_RETURN
			invoke IsWindowVisible,ha.hCCLB
			.if eax
				invoke SendMessage,ha.hCCLB,CCM_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		ccinprogress,TRUE
					invoke SendMessage,ha.hREd,REM_LOCKUNDOID,TRUE,0
					invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr ccchrg
					mov		eax,ccchrg.cpMin
					inc		eax
					mov		trng.chrg.cpMin,eax
					add		eax,16
					mov		trng.chrg.cpMax,eax
					lea		eax,buffer
					mov		trng.lpstrText,eax
					invoke SendMessage,ha.hREd,EM_GETTEXTRANGE,0,addr trng
					invoke SendMessage,ha.hCCLB,CCM_GETCURSEL,0,0
					invoke SendMessage,ha.hCCLB,CCM_GETITEM,eax,0
					push	eax
					invoke strcpy,offset tmpbuff,eax
					xor		eax,eax
					.while tmpbuff[eax]
						.if tmpbuff[eax]==':' || tmpbuff[eax]=='['
							mov		tmpbuff[eax],0
							.break
						.endif
						inc		eax
					.endw
					invoke SendMessage,ha.hREd,EM_REPLACESEL,TRUE,offset tmpbuff
					pop		eax
					.if cctype==CCTYPE_PROC
						lea		edx,buffer
						.while byte ptr [edx] && byte ptr [edx]!=VK_RETURN
							.if byte ptr [edx]==','
								xor		edx,edx
								.break
							.endif
							inc		edx
						.endw
						.if edx
							push	eax
							invoke strlen,eax
							pop		edx
							.if byte ptr [edx+eax+1]
								mov		ccinprogress,0
								mov		eax,','
								invoke SendMessage,ha.hREd,WM_CHAR,eax,0
							.endif
						.endif
					.endif
					invoke SendMessage,ha.hREd,REM_LOCKUNDOID,FALSE,0
					invoke ShowWindow,ha.hCCLB,SW_HIDE
					mov		cctype,CCTYPE_NONE
					xor		eax,eax
					mov		ccinprogress,eax
					jmp		Ex
				.else
					invoke ShowWindow,ha.hCCLB,SW_HIDE
					xor		eax,eax
					jmp		Ex
				.endif
			.elseif wParam==VK_RETURN
				invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
				invoke CaseConvertWord,wParam,chrg.cpMin
				;Block complete
				invoke CallWindowProc,lpOldRAEditProc,hWin,uMsg,wParam,lParam
				push	eax
				invoke BlockComplete,hWin
				pop		eax
				jmp		Ex
			.endif
		.elseif eax==VK_ESCAPE
			invoke ShowWindow,ha.hCCLB,SW_HIDE
			invoke ShowWindow,ha.hCCTT,SW_HIDE
			mov		cctype,CCTYPE_NONE
			xor		eax,eax
			jmp		Ex
		.elseif eax==VK_SPACE
			invoke GetKeyState,VK_CONTROL
			test		eax,80h
			.if !ZERO?
				mov		cctype,CCTYPE_ALL
				; Force a WM_NOTIFY
				invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
				invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chrg
				xor		eax,eax
				jmp		Ex
			.endif
		.elseif eax=='.'
			mov		cctype,CCTYPE_STRUCT
			invoke CallWindowProc,lpOldRAEditProc,hWin,uMsg,wParam,lParam
			jmp		Ex
		.elseif cctype==CCTYPE_ALL || cctype==CCTYPE_STRUCT
			push	eax
			invoke GetCharType,eax
			pop		edx
			.if eax==1 || edx==VK_BACK
				invoke CallWindowProc,lpOldRAEditProc,hWin,uMsg,wParam,lParam
				push	eax
				; Force a WM_NOTIFY
				invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
				invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chrg
				pop		eax
				jmp		Ex
			.else
				mov		cctype,CCTYPE_NONE
				invoke ShowWindow,ha.hCCLB,SW_HIDE
			.endif
		.endif
		invoke GetCharType,wParam
		.if eax!=1
			invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
			mov		eax,chrg.cpMin
			.if eax==chrg.cpMax && wParam!=VK_BACK
				invoke CaseConvertWord,wParam,chrg.cpMin
			.endif
		.endif
	.elseif eax==WM_KEYDOWN
		mov		edx,wParam
		mov		eax,lParam
		shr		eax,16
		and		eax,3FFh
		.if (edx==28h && (eax==150h || eax==50h)) || (edx==26h && (eax==148h || eax==48h)) || (edx==21h && (eax==149h || eax==49h)) || (edx==22h && (eax==151h || eax==51h))
			;Down / Up /PgUp / PgDn
			invoke IsWindowVisible,ha.hCCLB
			.if eax
				invoke PostMessage,ha.hCCLB,uMsg,wParam,lParam
				xor		eax,eax
				jmp		Ex
			.endif
		.elseif (edx==25h && eax==14Bh) || (edx==27h && eax==14Dh)
			;Left / Right
			invoke IsWindowVisible,ha.hCCLB
			.if eax
				invoke ShowWindow,ha.hCCLB,SW_HIDE
			.endif
			invoke IsWindowVisible,ha.hCCTT
			.if eax
				invoke ShowWindow,ha.hCCTT,SW_HIDE
			.endif
			mov		cctype,CCTYPE_NONE
		.endif
	.elseif eax==WM_KILLFOCUS
		invoke ShowWindow,ha.hCCTT,SW_HIDE
	.elseif eax==WM_MOUSEMOVE
		mov		ti.cbSize,SizeOf TOOLINFO
		mov		ti.uFlags,TTF_IDISHWND
		mov		eax,hWin
		mov		ti.hWnd,eax
		mov		ti.uId,eax
		mov		ti.lpszText,0
		invoke SendMessage,ha.hDbgTip,TTM_GETTOOLINFO,0,addr ti
		.if fDebugging
			.if !eax
				;Add the tooltip
				mov		ti.uFlags,TTF_IDISHWND Or TTF_SUBCLASS
				mov		eax,hWin
				mov		ti.hWnd,eax
				mov		ti.uId,eax
				mov		eax,ha.hInstance
				mov		ti.hInst,eax
				invoke SendMessage,ha.hDbgTip,TTM_ADDTOOL,0,addr ti
			.endif
			mov		eax,lParam
			mov		edx,eax
			shr		edx,16
			movsx	edx,dx
			movsx	eax,ax
			mov		pt.x,eax
			mov		pt.y,edx
			sub		eax,dbgpt.x
			.if CARRY?
				neg		eax
			.endif
			sub		edx,dbgpt.y
			.if CARRY?
				neg		edx
			.endif
			.if eax>5 || edx>5
				mov		eax,pt.x
				mov		dbgpt.x,eax
				mov		eax,pt.y
				mov		dbgpt.y,eax
				invoke SendMessage,ha.hREd,EM_CHARFROMPOS,0,addr pt
				invoke SendMessage,ha.hREd,REM_ISCHARPOS,eax,0
				.if !eax
					invoke SendMessage,ha.hREd,REM_GETCURSORWORD,sizeof buffer,addr buffer
					.if buffer
						lea		eax,buffer
						mov		dbgtip.lpWord,eax
						invoke SendMessage,ha.hREd,EM_CHARFROMPOS,0,addr pt
						invoke SendMessage,ha.hREd,EM_LINEFROMCHAR,eax,0
						mov		isinproc.nLine,eax
						inc		eax
						mov		dbgtip.nLine,eax
						mov		eax,ha.hREd
						mov		isinproc.nOwner,eax
						mov		isinproc.lpszType,offset szCCp
						invoke SendMessage,ha.hProperty,PRM_ISINPROC,0,addr isinproc
						mov		dbgtip.lpProc,eax
						mov		dbgtip.lpFileName,offset da.FileName
						invoke DebugCommand,FUNC_GETTOOLTIP,ha.hREd,addr dbgtip
						.if eax
							; Show tooltip
							mov		ti.lpszText,eax
							call	Activate
						.else
							; Hide tooltip
							call	DeActivate
						.endif
					.else
						; Hide tooltip
						call	DeActivate
					.endif
				.else
					; Hide tooltip
					call	DeActivate
				.endif
			.endif
		.elseif eax
			; Delete the tool
			invoke SendMessage,ha.hDbgTip,TTM_DELTOOL,0,addr ti
		.endif
	.endif
	invoke CallWindowProc,lpOldRAEditProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

Activate:
	invoke SendMessage,ha.hDbgTip,TTM_SETTOOLINFO,0,addr ti
	invoke SendMessage,ha.hDbgTip,TTM_ACTIVATE ,FALSE,0
	invoke SendMessage,ha.hDbgTip,TTM_ACTIVATE ,TRUE,0
	retn

DeActivate:
	invoke SendMessage,ha.hDbgTip,TTM_ACTIVATE ,FALSE,0
	retn

RAEditProc endp

CreateRAEdit proc

	push	ha.hREd
	.if edopt.hilitecmnt
		mov		eax,WS_CHILD or WS_VISIBLE or WS_CLIPSIBLINGS or STYLE_DRAGDROP or STYLE_SCROLLTIP or STYLE_HILITECOMMENT or STYLE_AUTOSIZELINENUM
	.else
		mov		eax,WS_CHILD or WS_VISIBLE or WS_CLIPSIBLINGS or STYLE_DRAGDROP or STYLE_SCROLLTIP or STYLE_AUTOSIZELINENUM
	.endif
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szRAEditClass,NULL,eax,0,0,0,0,ha.hWnd,IDC_RAE,ha.hInstance,0
	mov		ha.hREd,eax
	invoke SendMessage,ha.hREd,REM_SUBCLASS,0,addr RAEditProc
	mov		lpOldRAEditProc,eax
	invoke SetFormat,ha.hREd
	;Set colors
	invoke SendMessage,ha.hREd,REM_SETCOLOR,0,addr col
	.if edopt.linenumber
		invoke CheckDlgButton,ha.hREd,-2,TRUE
		invoke SendMessage,ha.hREd,WM_COMMAND,-2,0
	.endif
	invoke SendMessage,ha.hREd,REM_SETSTYLEEX,STYLEEX_BLOCKGUIDE or STILEEX_LINECHANGED,0
	invoke SendMessage,ha.hWnd,WM_SIZE,0,0
	pop		eax
	invoke ShowWindow,eax,SW_HIDE
	ret

CreateRAEdit endp

CreateRAHexEd proc
	LOCAL	hefnt:HEFONT

	invoke ShowWindow,ha.hREd,SW_HIDE
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szRAHexEdClassName,NULL,WS_CHILD or WS_VISIBLE,0,0,0,0,ha.hWnd,IDC_HEX,ha.hInstance,0
	mov		ha.hREd,eax
	mov		eax,ha.hFont
	mov		hefnt.hFont,eax
	mov		eax,ha.hLnrFont
	mov		hefnt.hLnrFont,eax
	;Set fonts
	invoke SendMessage,ha.hREd,HEM_SETFONT,0,addr hefnt
	;Set colors
	invoke SendMessage,ha.hWnd,WM_SIZE,0,0
	ret

CreateRAHexEd endp

CreateNew proc

	invoke PostAddinMessage,ha.hWnd,AIM_NEWFILE,IDC_RAE,offset szNewFile,0,HOOK_NEWFILE
	.if !eax
		invoke strcpy,offset da.FileName,offset szNewFile
		invoke CreateRAEdit
		invoke TabToolAdd,ha.hREd,offset da.FileName
		invoke SetWinCaption,offset da.FileName
		invoke SetFocus,ha.hREd
	.endif
	ret

CreateNew endp

CreateNewRes proc
	LOCAL	hMem:DWORD

	invoke PostAddinMessage,ha.hWnd,AIM_NEWFILE,IDC_RES,offset szNewFile,0,HOOK_NEWFILE
	.if !eax
		invoke strcpy,offset da.FileName,offset szNewFile
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,4096
		mov		hMem,eax
		invoke GlobalLock,hMem
		invoke SendMessage,ha.hResEd,PRO_OPEN,offset da.FileName,hMem
		invoke ShowWindow,ha.hREd,SW_HIDE
		mov		eax,ha.hRes
		mov		ha.hREd,eax
		invoke TabToolAdd,ha.hREd,offset da.FileName
		invoke SetWinCaption,offset da.FileName
		invoke ShowWindow,ha.hREd,SW_SHOW
		invoke SendMessage,ha.hWnd,WM_SIZE,0,0
		invoke SetFocus,ha.hREd
	.endif
	ret

CreateNewRes endp

MenuEnable proc uses ebx
	LOCAL	chrg:CHARRANGE

	invoke UpdateAll,IS_RESOURCE_OPEN,0
	xor		eax,1
	mov		edx,IDM_FILE_NEW_RES
	call	EnableDisable
	mov		eax,ErrID
	mov		edx,IDM_EDIT_CLEARERRORS
	call	EnableDisable
	mov		edx,IDM_EDIT_NEXTERROR
	call	EnableDisable
	mov		eax,ha.hREd
	mov		edx,IDM_VIEW_NEXTTAB
	call	EnableDisable
	mov		edx,IDM_VIEW_PREVIOUSTAB
	call	EnableDisable
;	xor		eax,eax
;	.if da.szSessionFile
;		mov		eax,TRUE
;	.endif
;	mov		edx,IDM_FILE_CLOSESESSION
;	call	EnableDisable
	xor		eax,eax
	.if da.szSessionFile && da.fProject
		mov		eax,TRUE
	.endif
	mov		edx,IDM_PROJECT_CLOSE
	call	EnableDisable
	mov		eax,TRUE
	mov		edx,IDM_PROJECT_CREATE
	.if da.fProject
		xor		eax,eax
	.endif
	call	EnableDisable
	.if !da.fProject
		xor		eax,eax
		mov		edx,IDM_PROJECT_ADDGROUP
		call	EnableDisable
		mov		edx,IDM_PROJECT_ADDFILE
		call	EnableDisable
		mov		edx,IDM_PROJECT_ADDALLFILES
		call	EnableDisable
		mov		edx,IDM_PROJECT_ADDEXISTINGFILE
		call	EnableDisable
		mov		edx,IDM_PROJECT_ADDNEWFILE
		call	EnableDisable
		mov		edx,IDM_PROJECT_REMOVEGROUP
		call	EnableDisable
		mov		edx,IDM_PROJECT_REMOVEFILE
		call	EnableDisable
	.else
		mov		eax,TRUE
		mov		edx,IDM_PROJECT_ADDGROUP
		call	EnableDisable
		mov		edx,IDM_PROJECT_ADDFILE
		call	EnableDisable
		mov		edx,IDM_PROJECT_ADDALLFILES
		call	EnableDisable
		mov		edx,IDM_PROJECT_ADDEXISTINGFILE
		call	EnableDisable
		mov		edx,IDM_PROJECT_ADDNEWFILE
		call	EnableDisable
		invoke SendMessage,ha.hPbr,RPBM_GETSELECTED,0,0
		.if eax
			.if sdword ptr [eax].PBITEM.id>0
				xor		eax,eax
				mov		edx,IDM_PROJECT_REMOVEGROUP
				call	EnableDisable
				inc		eax
				mov		edx,IDM_PROJECT_REMOVEFILE
				call	EnableDisable
			.elseif sdword ptr [eax].PBITEM.id<-1
				xor		eax,eax
				mov		edx,IDM_PROJECT_REMOVEFILE
				call	EnableDisable
				inc		eax
				mov		edx,IDM_PROJECT_REMOVEGROUP
				call	EnableDisable
			.else
				xor		eax,eax
				mov		edx,IDM_PROJECT_REMOVEGROUP
				call	EnableDisable
				mov		edx,IDM_PROJECT_REMOVEFILE
				call	EnableDisable
			.endif
		.else
			mov		edx,IDM_PROJECT_REMOVEGROUP
			call	EnableDisable
			mov		edx,IDM_PROJECT_REMOVEFILE
			call	EnableDisable
		.endif
	.endif
	.if ha.hREd
		invoke GetWindowLong,ha.hREd,GWL_ID
	.else
		mov		eax,-1
	.endif
	.if eax==-1
		call	DisableRes
		call	DisableEdit
		invoke SendMessage,ha.hSbr,SB_SETTEXT,0,addr szNULL
	.elseif eax==IDC_RES
		call	DisableEdit
		invoke SendMessage,ha.hResEd,DEM_GETMEM,DEWM_DIALOG,0
		mov		edx,IDM_VIEW_DIALOG
		call	EnableDisable
		mov		edx,IDM_FORMAT_TABINDEX
		call	EnableDisable
		invoke SendMessage,ha.hResEd,DEM_CANUNDO,0,0
		mov		edx,IDM_EDIT_UNDO
		call	EnableDisable
		invoke SendMessage,ha.hResEd,DEM_CANREDO,0,0
		mov		edx,IDM_EDIT_REDO
		call	EnableDisable
		invoke SendMessage,ha.hResEd,DEM_ISSELECTION,0,0
		mov		edx,IDM_EDIT_CUT
		call	EnableDisable
		mov		edx,IDM_EDIT_COPY
		call	EnableDisable
		mov		edx,IDM_EDIT_DELETE
		call	EnableDisable
		mov		edx,IDM_FORMAT_CENTER
		call	EnableDisable
		.if eax!=2
			xor		eax,eax
		.endif
		mov		edx,IDM_FORMAT_ALIGN
		call	EnableDisable
		mov		edx,IDM_FORMAT_SIZE
		call	EnableDisable
		invoke SendMessage,ha.hResEd,DEM_CANPASTE,0,0
		mov		edx,IDM_EDIT_PASTE
		call	EnableDisable
		mov		eax,TRUE
		mov		edx,IDM_FORMAT_LOCK
		call	EnableDisable
		mov		edx,IDM_FORMAT_GRID
		call	EnableDisable
		mov		edx,IDM_FORMAT_SNAP
		call	EnableDisable
		mov		edx,IDM_RESOURCE_DIALOG
		call	EnableDisable
		mov		edx,IDM_RESOURCE_MENU
		call	EnableDisable
		mov		edx,IDM_RESOURCE_ACCEL
		call	EnableDisable
		mov		edx,IDM_RESOURCE_VERINF
		call	EnableDisable
		mov		edx,IDM_RESOURCE_MANIFEST
		call	EnableDisable
		mov		edx,IDM_RESOURCE_RCDATA
		call	EnableDisable
		mov		edx,22000
		.while edx<22000+32
			call	EnableDisable
			inc		edx
		.endw
		mov		edx,IDM_RESOURCE_TOOLBAR
		call	EnableDisable
		mov		edx,IDM_RESOURCE_LANGUAGE
		call	EnableDisable
		mov		edx,IDM_RESOURCE_INCLUDE
		call	EnableDisable
		mov		edx,IDM_RESOURCE_RESOURCE
		call	EnableDisable
		mov		edx,IDM_RESOURCE_STRING
		call	EnableDisable
		mov		edx,IDM_RESOURCE_NAME
		call	EnableDisable
		mov		edx,IDM_RESOURCE_EXPORT
		call	EnableDisable
		mov		edx,IDM_RESOURCE_REMOVE
		call	EnableDisable
		mov		edx,IDM_RESOURCE_UNDO
		call	EnableDisable
		invoke SendMessage,ha.hResEd,DEM_ISBACK,0,0
		xor		eax,TRUE
		mov		edx,IDM_FORMAT_BACK
		call	EnableDisable
		invoke SendMessage,ha.hResEd,DEM_ISFRONT,0,0
		xor		eax,TRUE
		mov		edx,IDM_FORMAT_FRONT
		call	EnableDisable
		invoke SendMessage,ha.hSbr,SB_SETTEXT,0,addr szNULL
	.elseif eax==IDC_RAE
		call	DisableRes
		mov		eax,TRUE
		mov		edx,IDM_FILE_PRINT
		call	EnableDisable
		mov		edx,IDM_EDIT_SELECTALL
		call	EnableDisable
		mov		edx,IDM_EDIT_TOGGLEBM
		call	EnableDisable
		mov		edx,IDM_EDIT_FIND
		call	EnableDisable
		mov		edx,IDM_EDIT_REPLACE
		call	EnableDisable
		mov		edx,IDM_EDIT_FINDNEXT
		call	EnableDisable
		mov		edx,IDM_EDIT_FINDPREV
		call	EnableDisable
		mov		edx,IDM_EDIT_GOTO
		call	EnableDisable
		mov		eax,offset gotostack
		mov		eax,[eax].DECLARE.hWin
		mov		edx,IDM_EDIT_RETURN
		call	EnableDisable
		invoke SendMessage,ha.hREd,EM_CANUNDO,0,0
		mov		edx,IDM_EDIT_UNDO
		call	EnableDisable
		invoke SendMessage,ha.hREd,EM_CANREDO,0,0
		mov		edx,IDM_EDIT_REDO
		call	EnableDisable
		invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
		mov		eax,chrg.cpMax
		sub		eax,chrg.cpMin
		mov		edx,IDM_EDIT_CUT
		call	EnableDisable
		mov		edx,IDM_EDIT_COPY
		call	EnableDisable
		mov		edx,IDM_EDIT_DELETE
		call	EnableDisable
		mov		edx,IDM_EDIT_COMMENT
		call	EnableDisable
		mov		edx,IDM_EDIT_UNCOMMENT
		call	EnableDisable
		mov		edx,IDM_EDIT_BLOCKCONVERT
		call	EnableDisable
		mov		edx,IDM_EDIT_BLOCKSPCTRIM
		call	EnableDisable
		mov		eax,TRUE
		mov		edx,IDM_EDIT_INDENT
		call	EnableDisable
		mov		edx,IDM_EDIT_OUTDENT
		call	EnableDisable
		invoke SendMessage,ha.hREd,EM_CANPASTE,CF_TEXT,0
		mov		edx,IDM_EDIT_PASTE
		call	EnableDisable
		invoke SendMessage,ha.hREd,REM_GETMODE,0,0
		and		eax,MODE_BLOCK
		mov		edx,IDM_EDIT_BLOCKINSERT
		call	EnableDisable
		.if !eax
			mov		eax,MF_BYCOMMAND or MF_UNCHECKED
		.else
			mov		eax,MF_BYCOMMAND or MF_CHECKED
		.endif
		invoke CheckMenuItem,ha.hMnu,IDM_EDIT_BLOCKMODE,eax
		mov		eax,TRUE
		mov		edx,IDM_EDIT_BLOCKMODE
		call	EnableDisable
		invoke SendMessage,ha.hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
		mov		ebx,eax
		invoke SendMessage,ha.hREd,REM_NXTBOOKMARK,ebx,3
		inc		eax
		mov		edx,IDM_EDIT_NEXTBM
		call	EnableDisable
		invoke SendMessage,ha.hREd,REM_PRVBOOKMARK,ebx,3
		inc		eax
		mov		edx,IDM_EDIT_PREVBM
		call	EnableDisable
		invoke SendMessage,ha.hREd,REM_NXTBOOKMARK,-1,3
		inc		eax
		mov		edx,IDM_EDIT_CLEARBM
		call	EnableDisable

		mov		eax,TRUE
		mov		edx,IDM_DEBUG_TOGGLE
		call	EnableDisable
		mov		edx,IDM_DEBUG_CLEAR
		call	EnableDisable
		mov		edx,IDM_DEBUG_RUN
		call	EnableDisable
		mov		eax,fDebugging
		mov		edx,IDM_DEBUG_BREAK
		call	EnableDisable
		mov		edx,IDM_DEBUG_STOP
		call	EnableDisable
		mov		edx,IDM_DEBUG_INTO
		call	EnableDisable
		mov		edx,IDM_DEBUG_OVER
		call	EnableDisable
		mov		edx,IDM_DEBUG_CARET
		call	EnableDisable

	.elseif eax==IDC_HEX
		call	DisableRes
		xor		eax,eax
		mov		edx,IDM_FILE_PRINT
		call	EnableDisable
		mov		edx,IDM_EDIT_INDENT
		call	EnableDisable
		mov		edx,IDM_EDIT_OUTDENT
		call	EnableDisable
		mov		edx,IDM_EDIT_COMMENT
		call	EnableDisable
		mov		edx,IDM_EDIT_UNCOMMENT
		call	EnableDisable
		mov		edx,IDM_EDIT_GOTO
		call	EnableDisable
		mov		edx,IDM_EDIT_RETURN
		call	EnableDisable

		mov		eax,TRUE
		mov		edx,IDM_EDIT_SELECTALL
		call	EnableDisable
		mov		edx,IDM_EDIT_TOGGLEBM
		call	EnableDisable
		mov		edx,IDM_EDIT_FIND
		call	EnableDisable
		mov		edx,IDM_EDIT_REPLACE
		call	EnableDisable
		mov		edx,IDM_EDIT_FINDNEXT
		call	EnableDisable
		mov		edx,IDM_EDIT_FINDPREV
		call	EnableDisable

		invoke SendMessage,ha.hREd,EM_CANUNDO,0,0
		mov		edx,IDM_EDIT_UNDO
		call	EnableDisable
		invoke SendMessage,ha.hREd,EM_CANREDO,0,0
		mov		edx,IDM_EDIT_REDO
		call	EnableDisable
		invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
		mov		eax,chrg.cpMax
		sub		eax,chrg.cpMin
		mov		edx,IDM_EDIT_CUT
		call	EnableDisable
		mov		edx,IDM_EDIT_COPY
		call	EnableDisable
		mov		edx,IDM_EDIT_DELETE
		call	EnableDisable

		invoke SendMessage,ha.hREd,EM_CANPASTE,CF_TEXT,0
		mov		edx,IDM_EDIT_PASTE
		call	EnableDisable

		xor		eax,eax
		mov		edx,IDM_EDIT_BLOCKMODE
		call	EnableDisable
		mov		edx,IDM_EDIT_BLOCKINSERT
		call	EnableDisable

		invoke SendMessage,ha.hREd,HEM_ANYBOOKMARKS,0,0
		mov		edx,IDM_EDIT_NEXTBM
		call	EnableDisable
		mov		edx,IDM_EDIT_PREVBM
		call	EnableDisable
		mov		edx,IDM_EDIT_CLEARBM
		call	EnableDisable

		mov		eax,FALSE
		mov		edx,IDM_DEBUG_TOGGLE
		call	EnableDisable
		mov		edx,IDM_DEBUG_CLEAR
		call	EnableDisable
		mov		edx,IDM_DEBUG_CARET
		call	EnableDisable

		mov		eax,fDebugging
		mov		edx,IDM_DEBUG_RUN
		call	EnableDisable
		mov		edx,IDM_DEBUG_BREAK
		call	EnableDisable
		mov		edx,IDM_DEBUG_STOP
		call	EnableDisable
		mov		edx,IDM_DEBUG_INTO
		call	EnableDisable
		mov		edx,IDM_DEBUG_OVER
		call	EnableDisable
		mov		eax,chrg.cpMin
		mov		edx,eax
		shr		edx,5
		and		eax,31
		invoke ShowPos,edx,eax
	.elseif eax==IDC_USER
		call	DisableRes
		call	DisableEdit
		invoke SendMessage,ha.hSbr,SB_SETTEXT,0,addr szNULL
	.endif
	ret

DisableEdit:
	xor		eax,eax
	mov		edx,IDM_EDIT_CUT
	call	EnableDisable
	mov		edx,IDM_EDIT_COPY
	call	EnableDisable
	mov		edx,IDM_EDIT_PASTE
	call	EnableDisable
	mov		edx,IDM_EDIT_DELETE
	call	EnableDisable
	mov		edx,IDM_EDIT_UNDO
	call	EnableDisable
	mov		edx,IDM_EDIT_REDO
	call	EnableDisable
	mov		edx,IDM_FILE_PRINT
	call	EnableDisable
	mov		edx,IDM_EDIT_SELECTALL
	call	EnableDisable
	mov		edx,IDM_EDIT_FIND
	call	EnableDisable
	mov		edx,IDM_EDIT_FINDNEXT
	call	EnableDisable
	mov		edx,IDM_EDIT_FINDPREV
	call	EnableDisable
	mov		edx,IDM_EDIT_REPLACE
	call	EnableDisable
	mov		edx,IDM_EDIT_GOTO
	call	EnableDisable
	mov		edx,IDM_EDIT_RETURN
	call	EnableDisable
	mov		edx,IDM_EDIT_BLOCKMODE
	call	EnableDisable
	mov		edx,IDM_EDIT_BLOCKINSERT
	call	EnableDisable
	mov		edx,IDM_EDIT_TOGGLEBM
	call	EnableDisable
	mov		edx,IDM_EDIT_NEXTBM
	call	EnableDisable
	mov		edx,IDM_EDIT_PREVBM
	call	EnableDisable
	mov		edx,IDM_EDIT_CLEARBM
	call	EnableDisable
	mov		edx,IDM_EDIT_INDENT
	call	EnableDisable
	mov		edx,IDM_EDIT_OUTDENT
	call	EnableDisable
	mov		edx,IDM_EDIT_COMMENT
	call	EnableDisable
	mov		edx,IDM_EDIT_UNCOMMENT
	call	EnableDisable
	mov		edx,IDM_EDIT_BLOCKCONVERT
	call	EnableDisable
	mov		edx,IDM_EDIT_BLOCKSPCTRIM
	call	EnableDisable

	mov		edx,IDM_DEBUG_TOGGLE
	call	EnableDisable
	mov		edx,IDM_DEBUG_CLEAR
	call	EnableDisable
	mov		edx,IDM_DEBUG_CARET
	call	EnableDisable

	mov		eax,fDebugging
	mov		edx,IDM_DEBUG_RUN
	call	EnableDisable
	mov		edx,IDM_DEBUG_BREAK
	call	EnableDisable
	mov		edx,IDM_DEBUG_STOP
	call	EnableDisable
	mov		edx,IDM_DEBUG_INTO
	call	EnableDisable
	mov		edx,IDM_DEBUG_OVER
	call	EnableDisable
	retn

DisableRes:
	xor		eax,eax
	mov		edx,IDM_FORMAT_LOCK
	call	EnableDisable
	mov		edx,IDM_FORMAT_BACK
	call	EnableDisable
	mov		edx,IDM_FORMAT_FRONT
	call	EnableDisable
	mov		edx,IDM_FORMAT_GRID
	call	EnableDisable
	mov		edx,IDM_FORMAT_SNAP
	call	EnableDisable
	mov		edx,IDM_FORMAT_ALIGN
	call	EnableDisable
	mov		edx,IDM_FORMAT_SIZE
	call	EnableDisable
	mov		edx,IDM_FORMAT_CENTER
	call	EnableDisable
	mov		edx,IDM_FORMAT_TABINDEX
	call	EnableDisable
	mov		edx,IDM_VIEW_DIALOG
	call	EnableDisable
	mov		edx,IDM_RESOURCE_DIALOG
	call	EnableDisable
	mov		edx,IDM_RESOURCE_MENU
	call	EnableDisable
	mov		edx,IDM_RESOURCE_ACCEL
	call	EnableDisable
	mov		edx,IDM_RESOURCE_VERINF
	call	EnableDisable
	mov		edx,IDM_RESOURCE_MANIFEST
	call	EnableDisable
	mov		edx,IDM_RESOURCE_RCDATA
	call	EnableDisable
	mov		edx,22000
	.while edx<22000+32
		call	EnableDisable
		inc		edx
	.endw
	mov		edx,IDM_RESOURCE_TOOLBAR
	call	EnableDisable
	mov		edx,IDM_RESOURCE_LANGUAGE
	call	EnableDisable
	mov		edx,IDM_RESOURCE_INCLUDE
	call	EnableDisable
	mov		edx,IDM_RESOURCE_RESOURCE
	call	EnableDisable
	mov		edx,IDM_RESOURCE_STRING
	call	EnableDisable
	mov		edx,IDM_RESOURCE_NAME
	call	EnableDisable
	mov		edx,IDM_RESOURCE_EXPORT
	call	EnableDisable
	mov		edx,IDM_RESOURCE_REMOVE
	call	EnableDisable
	mov		edx,IDM_RESOURCE_UNDO
	call	EnableDisable
	retn

EnableDisable:
	push	eax
	push	edx
	.if eax
		mov		eax,MF_BYCOMMAND or MF_ENABLED
	.else
		mov		eax,MF_BYCOMMAND or MF_GRAYED
	.endif
	push	eax
	push	edx
	invoke EnableMenuItem,ha.hMnu,edx,eax
	pop		edx
	pop		eax
	invoke EnableMenuItem,ha.hContextMnu,edx,eax
	pop		edx
	pop		eax
	push	eax
	push	edx
	.if eax
		mov		eax,TRUE
	.endif
	invoke SendMessage,ha.hTbr,TB_ENABLEBUTTON,edx,eax
	pop		edx
	pop		eax
	retn

MenuEnable endp

MyTimerProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if fTimer
		dec		fTimer
		.if ZERO?
			invoke MenuEnable
			xor		eax,eax
			test	wpos.fView,4
			.if !ZERO?
				inc		eax
			.endif
			invoke SendMessage,ha.hTbr,TB_CHECKBUTTON,IDM_VIEW_OUTPUT,eax
			invoke ShowSession
			invoke ShowProc,nLastLine
			invoke GetCapture
			.if !eax
				invoke UpdateAll,IS_CHANGED,0
			.else
				mov		fTimer,1
			.endif
		.endif
	.endif
	ret

MyTimerProc endp

ResProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	rescol:RESCOLOR
	LOCAL	min:DWORD
	LOCAL	max:DWORD

	mov		eax,uMsg
	.if eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke MoveWindow,ha.hResEd,0,0,rect.right,rect.bottom,TRUE
	.elseif eax==WM_CREATE
		mov		ebx,lParam
		mov		ebx,[ebx].CREATESTRUCT.lpCreateParams
		mov		edx,WS_CHILD or WS_VISIBLE or WS_CLIPSIBLINGS or WS_CLIPCHILDREN; or WS_VSCROLL or WS_HSCROLL
		.if grdsize.show
			or		edx,DES_GRID
		.endif
		.if grdsize.snap
			or		edx,DES_SNAPTOGRID
		.endif
		.if grdsize.tips
			or		edx,DES_TOOLTIP
		.endif
		.if grdsize.stylehex
			or		edx,DES_STYLEHEX
		.endif
		invoke CreateWindowEx,0,addr szResEdClass,0,edx,0,0,0,0,hWin,IDC_DLGEDIT,ha.hInstance,0
		mov		ha.hResEd,eax
		invoke SendMessage,eax,WM_SETFONT,ebx,0
		mov		edx,nmeexp.nOutput
		shl		edx,16
		add		edx,nmeexp.nType
		invoke SendMessage,ha.hResEd,PRO_SETEXPORT,edx,addr nmeexp.szFileName
		invoke SendMessage,ha.hResEd,DEM_SETSIZE,0,addr winsize
		mov		eax,grdsize.y
		shl		eax,16
		add		eax,grdsize.x
		mov		edx,grdsize.line
		shl		edx,24
		add		edx,grdsize.color
		invoke SendMessage,ha.hResEd,DEM_SETGRIDSIZE,eax,edx
	.elseif eax==WM_DESTROY
		invoke SendMessage,ha.hResEd,DEM_GETSIZE,0,addr winsize
		mov		eax,winsize.htpro
		mov		wpos.htprop,eax
		mov		eax,winsize.wtpro
		mov		wpos.wtprop,eax
		mov		eax,winsize.ptstyle.x
		mov		wpos.left,eax
		mov		eax,winsize.ptstyle.y
		mov		wpos.top,eax
		mov		eax,winsize.wttbx
		mov		wpos.wttoolbox,eax
		invoke DestroyWindow,ha.hResEd
	.elseif eax==EM_GETMODIFY
		invoke SendMessage,ha.hResEd,PRO_GETMODIFY,0,0
		jmp		Ex
	.elseif eax==EM_SETMODIFY
		invoke SendMessage,ha.hResEd,PRO_SETMODIFY,wParam,0
		jmp		Ex
	.elseif eax==EM_UNDO
		invoke SendMessage,ha.hResEd,DEM_UNDO,0,0
		jmp		Ex
	.elseif eax==EM_REDO
		invoke SendMessage,ha.hResEd,DEM_REDO,0,0
		jmp		Ex
	.elseif eax==WM_CUT
		invoke SendMessage,ha.hResEd,DEM_CUT,0,0
		jmp		Ex
	.elseif eax==WM_COPY
		invoke SendMessage,ha.hResEd,DEM_COPY,0,0
		jmp		Ex
	.elseif eax==WM_PASTE
		invoke SendMessage,ha.hResEd,DEM_PASTE,0,0
		jmp		Ex
	.elseif eax==WM_CLEAR
		invoke SendMessage,ha.hResEd,DEM_DELETECONTROLS,0,0
		jmp		Ex
	.elseif eax==WM_NOTIFY
		.if !fResNotify
			inc		fResNotify
			invoke SendMessage,ha.hResEd,PRO_GETMODIFY,0,0
			.if eax
				invoke GetWindowLong,hWin,GWL_USERDATA
				.if ![eax].TABMEM.fchanged
					invoke TabToolSetChanged,hWin,TRUE
				.endif
			.endif
			mov		fTimer,1
			dec		fResNotify
		.endif
		xor		eax,eax
		jmp		Ex
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ResProc endp

DebugCallback proc nFunc:DWORD,wParam:DWORD,lParam:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	nFirst:DWORD

	mov		eax,nFunc
	.if eax==CB_SELECTLINE
		invoke SendMessage,ha.hREd,EM_GETFIRSTVISIBLELINE,0,0
		mov		nFirst,eax
		mov		eax,wParam
		dec		eax
		invoke SendMessage,ha.hREd,REM_SETHILITELINE,eax,2
		mov		eax,wParam
		dec		eax
		invoke SendMessage,ha.hREd,EM_LINEINDEX,eax,0
		mov		chrg.cpMin,eax
		mov		chrg.cpMax,eax
		invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chrg
		invoke SendMessage,ha.hREd,EM_SCROLLCARET,0,0
		invoke SendMessage,ha.hREd,EM_GETFIRSTVISIBLELINE,0,0
		.if eax!=nFirst
			invoke SendMessage,ha.hREd,REM_VCENTER,0,0
			invoke SendMessage,ha.hREd,EM_SCROLLCARET,0,0
		.endif
		invoke SetForegroundWindow,ha.hWnd
		invoke SetFocus,ha.hREd
	.elseif eax==CB_DESELECTLINE
		mov		eax,wParam
		dec		eax
		invoke SendMessage,lParam,REM_SETHILITELINE,eax,0
	.elseif eax==CB_DEBUG
		mov		eax,wParam
		mov		fDebugging,eax
		mov		fTimer,1
		.if eax
			invoke UpdateAll,LOCK_SOURCE_FILES,0
			invoke ShowWindow,ha.hDbgReg,SW_SHOWNA
			invoke ShowWindow,ha.hTabDbg,SW_SHOWNA
		.else
			invoke UpdateAll,UNLOCK_SOURCE_FILES,0
			invoke ShowWindow,ha.hDbgReg,SW_HIDE
			invoke ShowWindow,ha.hTabDbg,SW_HIDE
		.endif
		invoke OutputSelect,0
		or		wpos.fView,4
		invoke ShowWindow,ha.hOut,SW_SHOWNA
		invoke ShowWindow,ha.hImmOut,SW_HIDE
		invoke SendMessage,ha.hWnd,WM_SIZE,0,0
	.elseif eax==CB_OPENFILE
		invoke strcpy,offset da.DbgFileName,lParam
		invoke PostMessage,ha.hWnd,WM_USER+998,0,offset da.DbgFileName
	.endif
	mov		eax,ha.hREd
	ret

DebugCallback endp

ImmediateProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_CHAR
		mov		eax,wParam
		.if eax==VK_RETURN
			invoke DebugCommand,FUNC_IMMEDIATE,ha.hImmOut,0
			xor		eax,eax
			ret
		.endif
	.endif
	invoke CallWindowProc,lpOldImmediateProc,hWin,uMsg,wParam,lParam
	ret

ImmediateProc endp

WndProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	tmprect:RECT
	LOCAL	ht:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	cf:CHOOSEFONT
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	mnu:MENU
	LOCAL	nInx:DWORD
	LOCAL	hebmk:HEBMK
	LOCAL	min:DWORD
	LOCAL	max:DWORD
	LOCAL	mDC:HDC
	LOCAL	cust:CUSTSTYLE
	LOCAL	rarstype:RARSTYPE
	LOCAL	hFile:HANDLE
	LOCAL	tci:TC_ITEM
	LOCAL	mii:MENUITEMINFO

	mov		eax,uMsg
	.if eax==WM_LBUTTONDOWN
		.if fVSplit==1
			invoke SetCapture,hWin
			invoke SetCursor,ha.hHSplitCur
			mov		fVSplit,2
		.elseif fVSplit==3
			invoke SetCapture,hWin
			invoke SetCursor,ha.hVSplitCur
			mov		fVSplit,4
		.endif
	.elseif eax==WM_LBUTTONUP
		.if fVSplit
			invoke ReleaseCapture
			mov		fVSplit,0
		.endif
	.elseif eax==WM_MOUSEMOVE
		invoke GetWindowRect,ha.hSbr,addr rect
		mov		eax,rect.bottom
		sub		eax,rect.top
		push	eax
		invoke GetClientRect,hWin,addr rect
		pop		eax
		test	wpos.fView,2
		.if !ZERO?
			sub		rect.bottom,eax
		.endif
		test	wpos.fView,4
		.if !ZERO?
			mov		eax,wpos.htout
			add		eax,4
			sub		rect.bottom,eax
		.endif
		test	wpos.fView,8
		.if !ZERO?
			mov		eax,wpos.wtfile
			sub		rect.right,eax
		.endif
		test	wpos.fView,1
		.if !ZERO?
			add		rect.top,27
		.endif
		add		rect.top,TABHT
		invoke GetCursorPos,addr pt
		invoke ScreenToClient,hWin,addr pt
		.if fVSplit==0 || fVSplit==1 || fVSplit==3
			mov		fVSplit,0
			mov		eax,pt.x
			mov		edx,pt.y
			mov		ecx,rect.right
			add		ecx,4
			.if eax>20 && eax<rect.right && edx>rect.bottom
				invoke SetCursor,ha.hHSplitCur
				mov		fVSplit,1
			.elseif eax>=rect.right && eax<=ecx && edx>rect.top
				invoke SetCursor,ha.hVSplitCur
				mov		fVSplit,3
			.endif
		.elseif fVSplit==2
			xor		eax,eax
			test	wpos.fView,2
			.if !ZERO?
				;Get height of statusbar
				invoke GetWindowRect,ha.hSbr,addr rect
				mov		eax,rect.bottom
				sub		eax,rect.top
			.endif
			mov		max,eax
			xor		eax,eax
			test	wpos.fView,1
			.if !ZERO?
				;Get height of toolbar
				invoke GetWindowRect,ha.hTbr,addr rect
				mov		eax,rect.bottom
				sub		eax,rect.top
			.endif
			add		eax,TABHT
			add		eax,32
			mov		min,eax
			invoke GetClientRect,hWin,addr rect
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
				invoke SendMessage,hWin,WM_SIZE,0,0
				.if ha.hREd
					invoke UpdateWindow,ha.hREd
				.endif
				invoke UpdateWindow,ha.hOut
			.endif
		.elseif fVSplit==4
			invoke GetClientRect,hWin,addr rect
			mov		eax,rect.right
			sub		eax,50
			mov		max,eax
			mov		min,50
			mov		eax,pt.x
			sub		eax,rect.right
			neg		eax
			.if sdword ptr eax>max
				mov		eax,max
			.endif
			.if sdword ptr eax<min
				mov		eax,min
			.endif
			.if eax!=wpos.wtfile
				mov		wpos.wtfile,eax
				invoke SendMessage,hWin,WM_SIZE,0,0
				.if ha.hREd
					invoke UpdateWindow,ha.hREd
				.endif
				invoke UpdateWindow,ha.hOut
			.endif
		.endif
	.elseif eax==WM_SIZE
		;Get size of windows client area
		invoke GetClientRect,hWin,addr rect
		test	wpos.fView,1
		.if !ZERO?
			;Resize toolbar
			invoke MoveWindow,ha.hTbr,2,2,695,23,TRUE
			invoke MoveWindow,ha.hCbo,2,1,150,150,TRUE
			mov		eax,rect.right
			sub		eax,695+4
			invoke MoveWindow,ha.hStc,2+695,2,eax,23,TRUE
			invoke MoveWindow,ha.hShp,0,0,rect.right,27,TRUE
			mov		eax,27
		.else
			xor		eax,eax
		.endif
		push	eax
		test	wpos.fView,2
		.if !ZERO?
			;Resize statusbar
			mov		eax,rect.bottom
			sub		eax,21
			invoke MoveWindow,ha.hSbr,0,eax,rect.right,21,TRUE
			;Get height of statusbar
			invoke GetWindowRect,ha.hSbr,addr tmprect
			mov		eax,tmprect.bottom
			sub		eax,tmprect.top
		.else
			xor		eax,eax
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
		;Resize tab window
		mov		edx,rect.right
		test	wpos.fView,8
		.if !ZERO?
			sub		edx,wpos.wtfile
		.endif
		push	edx
		sub		edx,17
		push	edx
		mov		eax,rect.top
		add		eax,5
		invoke MoveWindow,ha.hBtn,edx,eax,15,15,TRUE
		invoke GetClientRect,ha.hTab,addr rect1
		invoke SendMessage,ha.hTab,TCM_GETROWCOUNT,0,0
		.if !eax
			inc		eax
		.endif
		mov		edx,24
		mul		edx
		mov		rect1.bottom,eax
		pop		edx
		push	edx
		invoke MoveWindow,ha.hTab,-1,rect.top,edx,rect1.bottom,TRUE
		invoke SendMessage,ha.hTab,TCM_GETROWCOUNT,0,0
		.if !eax
			inc		eax
		.endif
		mov		edx,24
		mul		edx
		mov		rect1.bottom,eax
		pop		edx
		invoke MoveWindow,ha.hTab,-1,rect.top,edx,rect1.bottom,TRUE
		invoke UpdateWindow,ha.hTab
		pop		edx
		test	wpos.fView,8
		.if !ZERO?
			;Resize file browser
			mov		eax,wpos.wtfile
			sub		rect.right,eax
			mov		edx,rect.bottom
			sub		edx,rect.top
			.if fDebugging
				sub		edx,HT_DEBUG
				.if CARRY?
					xor		edx,edx
				.endif
			.endif
			mov		ecx,rect.right
			add		ecx,RESIZEHT
			sub		eax,RESIZEHT
			shr		edx,1
			push	edx
			push	eax
			push	edx
			invoke MoveWindow,ha.hTabPbr,ecx,rect.top,eax,edx,TRUE
			pop		edx
			pop		eax
			sub		eax,6
			sub		edx,24+3
			push	eax
			push	edx
			invoke MoveWindow,ha.hPbr,3,24,eax,edx,TRUE
			pop		edx
			pop		eax
			invoke MoveWindow,ha.hBrowse,3,24,eax,edx,TRUE
			pop		edx
			;Resize property window
			push	rect.top
			add		edx,RESIZEHT
			add		rect.top,edx
			mov		edx,rect.bottom
			sub		edx,rect.top
			.if fDebugging
				sub		edx,HT_DEBUG
				.if CARRY?
					xor		edx,edx
				.endif
			.endif
			mov		ecx,rect.right
			add		ecx,RESIZEHT
			mov		eax,wpos.wtfile
			sub		eax,RESIZEHT
			push	edx
			invoke MoveWindow,ha.hProperty,ecx,rect.top,eax,edx,TRUE
			pop		edx
			add		edx,RESIZEHT
			add		rect.top,edx
			mov		ecx,rect.right
			add		ecx,RESIZEHT
			mov		eax,wpos.wtfile
			sub		eax,RESIZEHT
			invoke MoveWindow,ha.hTabDbg,ecx,rect.top,eax,20,TRUE
			add		rect.top,20
			mov		edx,rect.bottom
			sub		edx,rect.top
			mov		ecx,rect.right
			add		ecx,RESIZEHT
			mov		eax,wpos.wtfile
			sub		eax,RESIZEHT
			pushad
			invoke MoveWindow,ha.hDbgReg,ecx,rect.top,eax,edx,TRUE
			popad
			pushad
			invoke MoveWindow,ha.hDbgFpu,ecx,rect.top,eax,edx,TRUE
			popad
			pushad
			invoke MoveWindow,ha.hDbgMMX,ecx,rect.top,eax,edx,TRUE
			popad
			invoke MoveWindow,ha.hDbgWatch,ecx,rect.top,eax,edx,TRUE
			pop		rect.top
		.endif
		;Add height of tab window to top
		mov		eax,rect1.bottom
		add		rect.top,eax
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
		mov		eax,ha.hREd
		.if !ha.hREd
			invoke ShowWindow,ha.hClient,SW_SHOWNA
			invoke MoveWindow,ha.hClient,0,rect.top,rect.right,ht,TRUE
		.else
			invoke ShowWindow,ha.hClient,SW_HIDE
			invoke MoveWindow,ha.hREd,0,rect.top,rect.right,ht,TRUE
		.endif
		test	wpos.fView,4
		.if !ZERO?
			mov		eax,ht
			add		eax,RESIZEHT
			add		rect.top,eax
			;Resize Output window
			invoke MoveWindow,ha.hTabOut,0,rect.top,20,wpos.htout,TRUE
			invoke UpdateWindow,ha.hTabOut
			sub		rect.right,20
			invoke MoveWindow,ha.hOut,20,rect.top,rect.right,wpos.htout,TRUE
			invoke MoveWindow,ha.hImmOut,20,rect.top,rect.right,wpos.htout,TRUE
		.endif
	.elseif eax==WM_INITDIALOG
		push	hWin
		pop		ha.hWnd
		invoke MoveWindow,hWin,wpos.x,wpos.y,wpos.wt,wpos.ht,TRUE
		mov		fr,FR_DOWN
		mov		eax,wpos.x
		add		eax,30
		mov		findpt.x,eax
		mov		eax,wpos.y
		add		eax,30
		mov		findpt.y,eax
		invoke LoadCursor,ha.hInstance,IDC_HSPLIT
		mov		ha.hHSplitCur,eax
		invoke LoadCursor,ha.hInstance,IDC_VSPLIT
		mov		ha.hVSplitCur,eax
		;Set the toolbar buttons
		invoke GetDlgItem,hWin,IDC_TBR
		mov		ha.hTbr,eax
		invoke DoToolBar,ha.hInstance,eax
		;Statusbar
		invoke GetDlgItem,hWin,IDC_SBR
		mov		ha.hSbr,eax
		invoke DoStatusBar,eax
		;Shape
		invoke GetDlgItem,hWin,IDC_SHP
		mov		ha.hShp,eax
		;Static
		invoke GetDlgItem,hWin,IDC_STC
		mov		ha.hStc,eax
		;Combo
		invoke GetDlgItem,hWin,IDC_CBO
		mov		ha.hCbo,eax
		invoke SetParent,ha.hCbo,ha.hStc
		;Close button
		invoke GetDlgItem,hWin,IDC_BTNTABCLOSE
		mov		ha.hBtn,eax
		invoke LoadBitmap,ha.hInstance,111
		invoke SendMessage,ha.hBtn,BM_SETIMAGE,IMAGE_BITMAP,eax
		;Client
		invoke GetDlgItem,hWin,IDC_CLIENT
		mov		ha.hClient,eax
		;Output tab
		invoke GetDlgItem,hWin,IDC_TABOUT
		mov		ha.hTabOut,eax
		mov		tci.imask,TCIF_TEXT
		mov		tci.pszText,offset szOutput
		invoke SendMessage,ha.hTabOut,TCM_INSERTITEM,999,addr tci
		invoke SendMessage,ha.hTabOut,TCM_SETCURSEL,eax,0
		mov		tci.pszText,offset szImmediate
		invoke SendMessage,ha.hTabOut,TCM_INSERTITEM,999,addr tci
		;Debug tab
		invoke GetDlgItem,hWin,IDC_TABWATCH
		mov		ha.hTabDbg,eax
		mov		tci.imask,TCIF_TEXT
		mov		tci.pszText,offset szRegister
		invoke SendMessage,ha.hTabDbg,TCM_INSERTITEM,999,addr tci
		invoke SendMessage,ha.hTabDbg,TCM_SETCURSEL,eax,0
		mov		tci.pszText,offset szFloat
		invoke SendMessage,ha.hTabDbg,TCM_INSERTITEM,999,addr tci
		mov		tci.pszText,offset szMMX
		invoke SendMessage,ha.hTabDbg,TCM_INSERTITEM,999,addr tci
		mov		tci.pszText,offset szWatch
		invoke SendMessage,ha.hTabDbg,TCM_INSERTITEM,999,addr tci
		;Window caption
		invoke SetWinCaption,0
		;Create line number font
		invoke CreateFontIndirect,offset lfntlnr
		mov     ha.hLnrFont,eax
		;Create normal font
		invoke CreateFontIndirect,offset lfnt
		mov     ha.hFont,eax
		mov		al,lfnt.lfItalic
		push	eax
		;Create italics font
		mov		lfnt.lfItalic,TRUE
		invoke CreateFontIndirect,offset lfnt
		mov     ha.hIFont,eax
		pop		eax
		mov		lfnt.lfItalic,al
		;Create output window
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szRAEditClass,NULL,WS_CHILD or STYLE_NOSPLITT or STYLE_NOLINENUMBER or STYLE_NOCOLLAPSE or STYLE_NOHILITE or STYLE_NOBACKBUFFER or STYLE_DRAGDROP or STYLE_SCROLLTIP or STYLE_NOSTATE,0,0,0,0,ha.hWnd,IDC_OUT,ha.hInstance,0
		mov		ha.hOut,eax
		invoke SendMessage,ha.hOut,WM_SETFONT,ha.hFont,FALSE
		;Create immediate window
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szRAEditClass,NULL,WS_CHILD or STYLE_NOSPLITT or STYLE_NOLINENUMBER or STYLE_NOCOLLAPSE or STYLE_NOHILITE or STYLE_NOBACKBUFFER or STYLE_DRAGDROP or STYLE_SCROLLTIP or STYLE_NOSTATE,0,0,0,0,ha.hWnd,IDC_IMMOUT,ha.hInstance,0
		mov		ha.hImmOut,eax
		invoke SendMessage,ha.hImmOut,WM_SETFONT,ha.hFont,FALSE
		invoke SendMessage,ha.hImmOut,REM_SUBCLASS,0,offset ImmediateProc
		mov		lpOldImmediateProc,eax
		;Create debug register window
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szRAEditClass,NULL,WS_DISABLED or WS_CHILD or STYLE_NOSPLITT or STYLE_NOLINENUMBER or STYLE_NOCOLLAPSE or STYLE_NOHILITE or STYLE_NOBACKBUFFER or STYLE_NOSTATE or STYLE_NOHSCROLL or STYLE_NOVSCROLL or STYLE_READONLY,0,0,0,0,ha.hWnd,IDC_DBGREG,ha.hInstance,0
		mov		ha.hDbgReg,eax
		invoke SendMessage,ha.hDbgReg,WM_SETFONT,ha.hFont,FALSE
		;Create debug fpu window
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szRAEditClass,NULL,WS_DISABLED or WS_CHILD or STYLE_NOSPLITT or STYLE_NOLINENUMBER or STYLE_NOCOLLAPSE or STYLE_NOHILITE or STYLE_NOBACKBUFFER or STYLE_NOSTATE or STYLE_NOHSCROLL or STYLE_NOVSCROLL or STYLE_READONLY,0,0,0,0,ha.hWnd,IDC_DBGREG,ha.hInstance,0
		mov		ha.hDbgFpu,eax
		invoke SendMessage,ha.hDbgFpu,WM_SETFONT,ha.hFont,FALSE
		;Create debug MMX window
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szRAEditClass,NULL,WS_DISABLED or WS_CHILD or STYLE_NOSPLITT or STYLE_NOLINENUMBER or STYLE_NOCOLLAPSE or STYLE_NOHILITE or STYLE_NOBACKBUFFER or STYLE_NOSTATE or STYLE_NOHSCROLL or STYLE_NOVSCROLL or STYLE_READONLY,0,0,0,0,ha.hWnd,IDC_DBGREG,ha.hInstance,0
		mov		ha.hDbgMMX,eax
		invoke SendMessage,ha.hDbgMMX,WM_SETFONT,ha.hFont,FALSE
		;Create debug watch window
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szRAEditClass,NULL,WS_DISABLED or WS_CHILD or STYLE_NOSPLITT or STYLE_NOLINENUMBER or STYLE_NOCOLLAPSE or STYLE_NOHILITE or STYLE_NOBACKBUFFER or STYLE_NOSTATE or STYLE_NOHSCROLL or STYLE_NOVSCROLL,0,0,0,0,ha.hWnd,IDC_DBGWATCH,ha.hInstance,0
		mov		ha.hDbgWatch,eax
		invoke SendMessage,ha.hDbgWatch,WM_SETFONT,ha.hFont,FALSE
		; Create debug tooltip
		invoke CreateWindowEx,0,addr sztooltips_class32,NULL,TTS_NOPREFIX,0,0,0,0,NULL,0,ha.hInstance,0
		mov		ha.hDbgTip,eax
		invoke SendMessage,ha.hDbgTip,TTM_SETDELAYTIME,TTDT_AUTOPOP,10000
		;File / Project tab
		invoke GetDlgItem,hWin,IDC_TABPROJECT
		mov		ha.hTabPbr,eax
		mov		tci.imask,TCIF_TEXT
		mov		tci.pszText,offset szFile
		invoke SendMessage,ha.hTabPbr,TCM_INSERTITEM,999,addr tci
		invoke SendMessage,ha.hTabPbr,TCM_SETCURSEL,eax,0
		mov		tci.pszText,offset szProject
		invoke SendMessage,ha.hTabPbr,TCM_INSERTITEM,999,addr tci
		;Create project browser
		invoke CreateWindowEx,0,addr szPBClassName,0,WS_CHILD or WS_CLIPSIBLINGS or WS_CLIPCHILDREN or RPBS_FLATTOOLBAR or RPBS_NOPATH,0,0,0,0,ha.hTabPbr,IDC_PROJECT,ha.hInstance,0
		mov		ha.hPbr,eax
		invoke SendMessage,ha.hPbr,RPBM_ADDFILEEXT,0,0
		mov		esi,offset pbfileext
		xor		edi,edi
		.while [esi].PBFILEEXT.id
			invoke SendMessage,ha.hPbr,RPBM_ADDFILEEXT,edi,esi
			inc		edi
			lea		esi,[esi+sizeof PBFILEEXT]
		.endw
		;Create file browser
		invoke CreateWindowEx,0,addr szFBClassName,0,WS_CHILD or WS_CLIPSIBLINGS or WS_CLIPCHILDREN or FBSTYLE_FLATTOOLBAR,0,0,0,0,ha.hTabPbr,IDC_FILE,ha.hInstance,0
		mov		ha.hBrowse,eax
		;Create property
		invoke CreateWindowEx,0,addr szPropertyClassName,0,WS_CHILD or WS_CLIPSIBLINGS or WS_CLIPCHILDREN or PRSTYLE_FLATTOOLBAR,0,0,0,0,hWin,IDC_PROPERTY,ha.hInstance,0
		mov		ha.hProperty,eax
		invoke SendMessage,ha.hSbr,WM_GETFONT,0,0
		push	eax
		push	eax
		invoke SendMessage,ha.hBrowse,WM_SETFONT,eax,FALSE
		pop		eax
		invoke SendMessage,ha.hProperty,WM_SETFONT,eax,FALSE
		;Create ResEd
		pop		eax
		invoke CreateWindowEx,0,addr szResClassName,0,WS_CHILD or WS_CLIPSIBLINGS or WS_CLIPCHILDREN,0,0,0,0,hWin,IDC_RES,ha.hInstance,eax
		mov		ha.hRes,eax
		;Get handle of tab window
		invoke GetDlgItem,hWin,IDC_TAB
		mov		ha.hTab,eax
		invoke SetWindowLong,ha.hTab,GWL_WNDPROC,offset TabProc
		mov		lpOldTabProc,eax
		invoke SendMessage,ha.hBrowse,FBM_GETIMAGELIST,0,0
		invoke SendMessage,ha.hTab,TCM_SETIMAGELIST,0,eax
		invoke GetMenu,hWin
		mov		ha.hMnu,eax
		invoke ImageList_Create,16,16,ILC_COLOR4 or ILC_MASK,4,0
		mov     ha.hMnuIml,eax
		invoke LoadBitmap,ha.hInstance,IDB_MNUARROW
		push	eax
		invoke ImageList_AddMasked,ha.hMnuIml,eax,0C0C0C0h
		pop		eax
		invoke DeleteObject,eax
		invoke LoadMenu,ha.hInstance,IDR_MENUCONTEXT
		mov		ha.hContextMnu,eax
		invoke SetToolMenu
		invoke SetHelpMenu
		;Add custom controls
		mov		nInx,1
		mov		ebx,offset hCustDll
		.while nInx<=32
			invoke MakeKey,addr szCust,nInx,addr buffer1
			mov		lpcbData,MAX_PATH
			mov		buffer,0
			invoke RegQueryValueEx,ha.hReg,addr buffer1,0,addr lpType,addr buffer,addr lpcbData
			.if buffer
				invoke SendMessage,ha.hResEd,DEM_ADDCONTROL,0,addr buffer
				.if eax
					mov		[ebx],eax
					add		ebx,4
				.endif
			.endif
			inc		nInx
		.endw
		;Add custom styles
		mov		nInx,1
		.while nInx<=64
			invoke MakeKey,addr szCustStyle,nInx,addr buffer1
			mov		lpcbData,sizeof CUSTSTYLE
			mov		cust.szStyle,0
			invoke RegQueryValueEx,ha.hReg,addr buffer1,0,addr lpType,addr cust,addr lpcbData
			.if cust.szStyle
				invoke SendMessage,ha.hResEd,DEM_ADDCUSTSTYLE,0,addr cust
			.endif
			inc		nInx
		.endw
		;Add resource types
		mov		nInx,1
		.while nInx<=32
			invoke MakeKey,addr szCustType,nInx,addr buffer1
			mov		lpcbData,sizeof RARSTYPE
			invoke RtlZeroMemory,addr rarstype,sizeof RARSTYPE
			invoke RegQueryValueEx,ha.hReg,addr buffer1,0,addr lpType,addr rarstype,addr lpcbData
			.if rarstype.sztype || rarstype.nid
				mov		edx,nInx
				dec		edx
				invoke SendMessage,ha.hResEd,PRO_SETCUSTOMTYPE,edx,addr rarstype
				.if !rarstype.szext && rarstype.sztype && nInx>11
					invoke lstrcpy,addr buffer,addr szAdd
					invoke lstrcat,addr buffer,addr rarstype.sztype
					mov		edx,nInx
					lea		edx,[edx+22000-12]
					invoke InsertMenu,ha.hMnu,IDM_RESOURCE_TOOLBAR,MF_BYCOMMAND,edx,addr buffer
				.endif
			.endif
			inc		nInx
		.endw
		invoke strcpy,addr da.PathBin,addr defPathBin
		mov		lpcbData,sizeof da.PathBin
		invoke RegQueryValueEx,ha.hReg,addr szPathBin,0,addr lpType,addr da.PathBin,addr lpcbData
		invoke strcpy,addr da.PathInc,addr defPathInc
		mov		lpcbData,sizeof da.PathInc
		invoke RegQueryValueEx,ha.hReg,addr szPathInc,0,addr lpType,addr da.PathInc,addr lpcbData
		invoke strcpy,addr da.PathLib,addr defPathLib
		mov		lpcbData,sizeof da.PathLib
		invoke RegQueryValueEx,ha.hReg,addr szPathLib,0,addr lpType,addr da.PathLib,addr lpcbData
		invoke SetEnvironment
		mov		nInx,1
		mov		esi,offset makeoptdef
		mov		edi,offset da.makeopt
		.while nInx<=16
			invoke RtlMoveMemory,edi,esi,sizeof MAKEOPT
			invoke MakeKey,addr szMakeType,nInx,addr buffer1
			mov		lpcbData,sizeof MAKEOPT
			invoke RegQueryValueEx,ha.hReg,addr buffer1,0,addr lpType,edi,addr lpcbData
			.if [edi].MAKEOPT.szType
				invoke SendMessage,ha.hCbo,CB_ADDSTRING,0,addr [edi].MAKEOPT.szType
				invoke SendMessage,ha.hCbo,CB_SETITEMDATA,eax,edi
				lea		edi,[edi+sizeof MAKEOPT]
			.endif
			lea		esi,[esi+sizeof MAKEOPT]
			inc		nInx
		.endw
		mov		lpcbData,sizeof da.nBuildOpt
		invoke RegQueryValueEx,ha.hReg,addr szBuild,0,addr lpType,addr da.nBuildOpt,addr lpcbData
		invoke SendMessage,ha.hCbo,CB_SETCURSEL,da.nBuildOpt,0
		invoke CreateCodeComplete
		invoke UpdateToolColors
		invoke SendMessage,ha.hBrowse,FBM_SETFILTERSTRING,FALSE,addr szFilter
		invoke SendMessage,ha.hBrowse,FBM_SETFILTER,FALSE,TRUE
		mov		lpcbData,sizeof da.szInitFolder
		invoke RegQueryValueEx,ha.hReg,addr szFolder,0,addr lpType,addr da.szInitFolder,addr lpcbData
		.if byte ptr da.szInitFolder
			invoke strcpy,addr buffer,addr da.szInitFolder
			invoke SetCurDir,addr buffer,TRUE
			.if !eax
				invoke GetModuleFileName,0,addr buffer,sizeof buffer
				invoke SetCurDir,addr buffer,TRUE
			.endif
		.else
			invoke GetModuleFileName,0,addr buffer,sizeof buffer
			invoke SetCurDir,addr buffer,TRUE
		.endif
		invoke SendMessage,ha.hBrowse,FBM_GETPATH,0,addr da.szInitFolder
		invoke SetTimer,hWin,200,200,addr MyTimerProc
		invoke SetBlockDefs,ha.hOut
		invoke SetPropertyDefs
		;Set hilite words
		invoke SetKeyWords
		mov		eax,hWin
		mov		dbginf.hWnd,eax
		mov		eax,ha.hOut
		mov		dbginf.hOut,eax
		mov		eax,ha.hImmOut
		mov		dbginf.hImmOut,eax
		mov		eax,ha.hDbgReg
		mov		dbginf.hDbgReg,eax
		mov		eax,ha.hDbgFpu
		mov		dbginf.hDbgFpu,eax
		mov		eax,ha.hDbgMMX
		mov		dbginf.hDbgMMX,eax
		mov		eax,ha.hDbgWatch
		mov		dbginf.hDbgWatch,eax
		mov		eax,ha.hProperty
		mov		dbginf.hPrp,eax
		mov		eax,offset DebugCallback
		mov		dbginf.lpCallBack,eax
		mov		eax,da.fProject
		mov		dbginf.fProject,eax
		invoke SetDebugInfo,addr dbginf
		invoke LoadAddins,hWin
		invoke LoadMRU,offset szMRUFiles,offset mrufiles
		invoke LoadMRU,offset szMRUSessions,offset mrusessions
		invoke ResetMenu
		mov		fTimer,1
	.elseif eax==WM_COMMAND
		invoke PostAddinMessage,hWin,AIM_COMMAND,wParam,lParam,0,HOOK_COMMAND
		.if eax
			jmp		Ex
		.endif
		;Menu and toolbar has the same ID's
		mov		eax,wParam
		mov		edx,eax
		movzx	eax,ax
		shr		edx,16
		.if edx==BN_CLICKED || edx==CBN_SELCHANGE
			.if eax==IDM_FILE_NEW
				invoke CreateNew
				mov		fTimer,1
			.elseif eax==IDM_FILE_NEW_RES
				invoke CreateNewRes
				mov		fTimer,1
			.elseif eax==IDM_FILE_OPEN
				invoke OpenEdit
				mov		fTimer,1
			.elseif eax==IDM_FILE_OPEN_HEX
				invoke OpenHex
				mov		fTimer,1
			.elseif eax==IDM_FILE_SAVE
				.if ha.hREd
					invoke SaveEdit,ha.hREd,offset da.FileName
					invoke SetFocus,ha.hREd
				.endif
			.elseif eax==IDM_FILE_SAVEALL
				invoke UpdateAll,SAVE_ALL,0
			.elseif eax==IDM_FILE_SAVEAS
				.if ha.hREd
					invoke SaveEditAs,ha.hREd,offset da.FileName
				.endif
			.elseif eax==IDM_FILE_CLOSE || eax==IDC_BTNTABCLOSE
				invoke strcpy,addr buffer,offset da.FileName
				invoke GetWindowLong,ha.hREd,GWL_ID
				mov		ebx,eax
				invoke PostAddinMessage,ha.hREd,AIM_FILECLOSE,ebx,addr buffer,0,HOOK_FILECLOSE
				.if !eax
					invoke WantToSave,ha.hREd,offset da.FileName
					.if !eax
						invoke PostAddinMessage,ha.hREd,AIM_FILECLOSED,ebx,addr buffer,0,HOOK_FILECLOSED
						.if ebx!=IDC_RES && ebx!=IDC_USER
							.if ebx==IDC_RAE
								invoke DeleteGoto,ha.hREd
								.if !da.fProject
									invoke SendMessage,ha.hProperty,PRM_DELPROPERTY,ha.hREd,0
									invoke SendMessage,ha.hProperty,PRM_REFRESHLIST,0,0
								.else
									invoke SaveCollapse,ha.hREd
								.endif
							.endif
							invoke DestroyWindow,ha.hREd
						.endif
						invoke TabToolDel,ha.hREd
					.endif
					mov		fTimer,1
				.endif
			.elseif eax==IDM_FILE_CLOSE_ALL
				mov		nTabInx,-1
				invoke UpdateAll,WM_CLOSE,0
				.if !eax
					invoke UpdateAll,CLOSE_ALL,0
				.endif
				invoke SendMessage,ha.hProperty,PRM_REFRESHLIST,0,0
				mov		fTimer,1
			.elseif eax==IDM_FILE_CLOSE_ALL_BUT
				invoke SendMessage,ha.hTab,TCM_GETCURSEL,0,0
				mov		nTabInx,eax
				invoke UpdateAll,WM_CLOSE,0
				.if !eax
					invoke UpdateAll,CLOSE_ALL,0
				.endif
				invoke SendMessage,ha.hProperty,PRM_REFRESHLIST,0,0
				mov		fTimer,1
			.elseif eax==IDM_FILE_PAGESETUP
				invoke GetPrnCaps
				mov		psd.lStructSize,sizeof psd
				mov		eax,hWin
				mov		psd.hwndOwner,eax
				mov		eax,ha.hInstance
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
					invoke RegSetValueEx,ha.hReg,addr szPrnPos,0,REG_BINARY,addr ppos,sizeof ppos
				.endif
			.elseif eax==IDM_FILE_PRINT
				mov		pd.lStructSize,sizeof pd
				mov		eax,hWin
				mov		pd.hwndOwner,eax
				mov		eax,ha.hInstance
				mov		pd.hInstance,eax
				invoke SendMessage,ha.hREd,EM_GETLINECOUNT,0,0
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
				invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
				mov		eax,chrg.cpMin
				.if eax!=chrg.cpMax
					mov		eax,PD_RETURNDC or PD_SELECTION
				.else
					mov		eax,PD_RETURNDC or PD_NOSELECTION
				.endif
				mov		pd.Flags,eax
				invoke PrintDlg,addr pd
				.if eax
					invoke Print
				.endif
			.elseif eax>=25000 && eax<=25110
				invoke OpenMRU,eax
			.elseif eax==IDM_FILE_EXIT
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==IDM_EDIT_UNDO
				invoke SendMessage,ha.hREd,EM_UNDO,0,0
			.elseif eax==IDM_EDIT_REDO
				invoke SendMessage,ha.hREd,EM_REDO,0,0
			.elseif eax==IDM_EDIT_DELETE
				invoke SendMessage,ha.hREd,WM_CLEAR,0,0
			.elseif eax==IDM_EDIT_CUT
				invoke SendMessage,ha.hREd,WM_CUT,0,0
			.elseif eax==IDM_EDIT_COPY
				invoke SendMessage,ha.hREd,WM_COPY,0,0
			.elseif eax==IDM_EDIT_PASTE
				invoke SendMessage,ha.hREd,WM_PASTE,0,0
			.elseif eax==IDM_EDIT_SELECTALL
				mov		chrg.cpMin,0
				mov		chrg.cpMax,-1
				invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chrg
			.elseif eax==IDM_EDIT_FIND
				.if !ha.hFind
					invoke GetWindowLong,ha.hREd,GWL_ID
					.if eax==IDC_RAE
						invoke GetSelText,offset da.findbuff
						invoke CreateDialogParam,ha.hInstance,IDD_FINDDLG,hWin,offset FindDlgProc,FALSE
					.elseif eax==IDC_HEX
						invoke CreateDialogParam,ha.hInstance,IDD_HEXFINDDLG,hWin,offset HexFindDlgProc,FALSE
					.endif
				.else
					invoke SetFocus,ha.hFind
				.endif
			.elseif eax==IDM_EDIT_REPLACE
				.if !ha.hFind
					invoke GetWindowLong,ha.hREd,GWL_ID
					.if eax==IDC_RAE
						invoke GetSelText,offset da.findbuff
						invoke CreateDialogParam,ha.hInstance,IDD_FINDDLG,hWin,addr FindDlgProc,TRUE
					.elseif eax==IDC_HEX
						invoke CreateDialogParam,ha.hInstance,IDD_HEXFINDDLG,hWin,offset HexFindDlgProc,TRUE
					.endif
				.else
					invoke SetFocus,ha.hFind
				.endif
			.elseif eax==IDM_EDIT_FINDNEXT
				.if !ha.hFind
					invoke GetSelText,offset da.findbuff
				.endif
				invoke GetWindowLong,ha.hREd,GWL_ID
				.if eax==IDC_RAE
					mov		al,da.findbuff
					.if al
						push	ndir
						push	fallfiles
						mov		ndir,1
						mov		fallfiles,0
						invoke FindInit,ha.hREd
						invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr ft.chrgText
						mov		fres,0
						invoke Find,ha.hREd,FR_DOWN
						pop		fallfiles
						pop		ndir
					.endif
				.elseif eax==IDC_HEX
					mov		al,da.findbuff
					.if al
						invoke HexFind,FR_DOWN or FR_HEX
					.endif
				.endif
			.elseif eax==IDM_EDIT_FINDPREV
				.if !ha.hFind
					invoke GetSelText,offset da.findbuff
				.endif
				invoke GetWindowLong,ha.hREd,GWL_ID
				.if eax==IDC_RAE
					mov		al,da.findbuff
					.if al
						push	ndir
						push	fallfiles
						mov		ndir,2
						mov		fallfiles,0
						invoke FindInit,ha.hREd
						invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr ft.chrgText
						mov		fres,0
						invoke Find,ha.hREd,0
						pop		fallfiles
						pop		ndir
					.endif
				.elseif eax==IDC_HEX
					mov		al,da.findbuff
					.if al
						invoke HexFind,FR_HEX
					.endif
				.endif
			.elseif eax==IDM_EDIT_GOTO
				invoke GotoDeclare
			.elseif eax==IDM_EDIT_RETURN
				invoke ReturnDeclare
			.elseif eax==IDM_EDIT_INDENT
				invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
				invoke SendMessage,ha.hREd,EM_LINEFROMCHAR,chrg.cpMax,0
				push	eax
				invoke SendMessage,ha.hREd,EM_LINEFROMCHAR,chrg.cpMin,0
				pop		edx
				sub		eax,edx
				.if eax
					invoke IndentComment,VK_TAB,TRUE
				.else
					invoke SendMessage,ha.hREd,WM_CHAR,VK_TAB,0
				.endif
			.elseif eax==IDM_EDIT_OUTDENT
				invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
				invoke SendMessage,ha.hREd,EM_LINEFROMCHAR,chrg.cpMax,0
				push	eax
				invoke SendMessage,ha.hREd,EM_LINEFROMCHAR,chrg.cpMin,0
				pop		edx
				sub		eax,edx
				.if eax
					invoke IndentComment,VK_TAB,FALSE
				.else
				.endif
			.elseif eax==IDM_EDIT_COMMENT
				invoke IndentComment,';',TRUE
			.elseif eax==IDM_EDIT_UNCOMMENT
				invoke IndentComment,';',FALSE
			.elseif eax==IDM_EDIT_BLOCKUPPER
				invoke SendMessage,ha.hREd,REM_CONVERT,CONVERT_UPPERCASE,0
			.elseif eax==IDM_EDIT_BLOCKLOWER
				invoke SendMessage,ha.hREd,REM_CONVERT,CONVERT_LOWERCASE,0
			.elseif eax==IDM_EDIT_BLOCKTABTOSPC
				invoke SendMessage,ha.hREd,REM_CONVERT,CONVERT_TABTOSPACE,0
			.elseif eax==IDM_EDIT_BLOCKSPCTOTAB
				invoke SendMessage,ha.hREd,REM_CONVERT,CONVERT_SPACETOTAB,0
			.elseif eax==IDM_EDIT_BLOCKSPCTRIM
				invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
				invoke SendMessage,ha.hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
				mov		ebx,eax
				invoke SendMessage,ha.hREd,EM_LINEINDEX,ebx,0
				mov		chrg.cpMin,eax
				invoke SendMessage,ha.hREd,EM_EXLINEFROMCHAR,0,chrg.cpMax
				mov		edi,eax
				invoke SendMessage,ha.hREd,EM_LINEINDEX,edi,0
				mov		chrg.cpMax,eax
				xor		esi,esi
				.while ebx<edi
					invoke SendMessage,ha.hREd,REM_TRIMSPACE,ebx,0
					lea		esi,[esi+eax]
					inc		ebx
				.endw
				add		esi,chrg.cpMin
				mov		chrg.cpMax,esi
				invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chrg
			.elseif eax==IDM_EDIT_BLOCKMODE
				invoke SendMessage,ha.hREd,REM_GETMODE,0,0
				xor		eax,MODE_BLOCK
				invoke SendMessage,ha.hREd,REM_SETMODE,eax,0
				mov		fTimer,1
			.elseif eax==IDM_EDIT_BLOCKINSERT
				invoke CreateDialogParam,ha.hInstance,IDD_BLOCKDLG,hWin,addr BlockDlgProc,0
			.elseif eax==IDM_EDIT_TOGGLEBM
				invoke GetWindowLong,ha.hREd,GWL_ID
				.if eax==IDC_RAE
					invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,ha.hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
					mov		ebx,eax
					invoke SendMessage,ha.hREd,REM_GETBOOKMARK,ebx,0
					.if !eax
						invoke SendMessage,ha.hREd,REM_SETBOOKMARK,ebx,3
					.elseif eax==3
						invoke SendMessage,ha.hREd,REM_SETBOOKMARK,ebx,0
					.endif
					invoke SaveBookMarks,ha.hREd
				.elseif eax==IDC_HEX
					invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
					mov		eax,chrg.cpMin
					shr		eax,5
					invoke SendMessage,ha.hREd,HEM_TOGGLEBOOKMARK,eax,0
				.endif
				mov		fTimer,1
			.elseif eax==IDM_EDIT_NEXTBM
				invoke GetWindowLong,ha.hREd,GWL_ID
				.if eax==IDC_RAE
					invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,ha.hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
					invoke SendMessage,ha.hREd,REM_NXTBOOKMARK,eax,3
					.if eax!=-1
						invoke SendMessage,ha.hREd,EM_LINEINDEX,eax,0
						mov		chrg.cpMin,eax
						mov		chrg.cpMax,eax
						invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chrg
						invoke SendMessage,ha.hREd,EM_SCROLLCARET,0,0
					.endif
				.elseif eax==IDC_HEX
					invoke SendMessage,ha.hREd,HEM_NEXTBOOKMARK,0,addr hebmk
					.if eax
						invoke TabToolGetInx,hebmk.hWin
						invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
						invoke TabToolActivate
						mov		eax,hebmk.nLine
						shl		eax,5
						mov		chrg.cpMin,eax
						mov		chrg.cpMax,eax
						invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chrg
						invoke SendMessage,ha.hREd,HEM_VCENTER,0,0
						invoke SetFocus,ha.hREd
					.endif
				.endif
			.elseif eax==IDM_EDIT_PREVBM
				invoke GetWindowLong,ha.hREd,GWL_ID
				.if eax==IDC_RAE
					invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,ha.hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
					invoke SendMessage,ha.hREd,REM_PRVBOOKMARK,eax,3
					.if eax!=-1
						invoke SendMessage,ha.hREd,EM_LINEINDEX,eax,0
						mov		chrg.cpMin,eax
						mov		chrg.cpMax,eax
						invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chrg
						invoke SendMessage,ha.hREd,EM_SCROLLCARET,0,0
					.endif
				.elseif eax==IDC_HEX
					invoke SendMessage,ha.hREd,HEM_PREVIOUSBOOKMARK,0,addr hebmk
					.if eax
						invoke TabToolGetInx,hebmk.hWin
						invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
						invoke TabToolActivate
						mov		eax,hebmk.nLine
						shl		eax,5
						mov		chrg.cpMin,eax
						mov		chrg.cpMax,eax
						invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chrg
						invoke SendMessage,ha.hREd,HEM_VCENTER,0,0
						invoke SetFocus,ha.hREd
					.endif
				.endif
			.elseif eax==IDM_EDIT_CLEARBM
				invoke GetWindowLong,ha.hREd,GWL_ID
				.if eax==IDC_RAE
					invoke SendMessage,ha.hREd,REM_CLRBOOKMARKS,0,3
					invoke SaveBookMarks,ha.hREd
				.elseif eax==IDC_HEX
					invoke SendMessage,ha.hREd,HEM_CLEARBOOKMARKS,0,0
				.endif
				mov		fTimer,1
			.elseif eax==IDM_EDIT_CLEARERRORS
				invoke UpdateAll,CLEAR_ERRORS,0
			.elseif eax==IDM_EDIT_NEXTERROR
				mov		eax,nErrID
				mov		eax,ErrID[eax*4]
				.if !eax
					mov		nErrID,0
					mov		eax,ErrID
				.endif
				.if eax
					invoke UpdateAll,FIND_ERROR,0
					inc		nErrID
				.endif
			.elseif eax==IDM_FORMAT_LOCK
				invoke SendMessage,ha.hResEd,DEM_ISLOCKED,0,0
				xor		eax,TRUE
				invoke SendMessage,ha.hResEd,DEM_LOCKCONTROLS,0,eax
			.elseif eax==IDM_FORMAT_BACK
				invoke SendMessage,ha.hResEd,DEM_SENDTOBACK,0,0
			.elseif eax==IDM_FORMAT_FRONT
				invoke SendMessage,ha.hResEd,DEM_BRINGTOFRONT,0,0
			.elseif eax==IDM_FORMAT_GRID
				invoke GetWindowLong,ha.hResEd,GWL_STYLE
				xor		eax,DES_GRID
				invoke SetWindowLong,ha.hResEd,GWL_STYLE,eax
			.elseif eax==IDM_FORMAT_SNAP
				invoke GetWindowLong,ha.hResEd,GWL_STYLE
				xor		eax,DES_SNAPTOGRID
				invoke SetWindowLong,ha.hResEd,GWL_STYLE,eax
			.elseif eax==IDM_FORMAT_ALIGN_LEFT
				invoke SendMessage,ha.hResEd,DEM_ALIGNSIZE,0,ALIGN_LEFT
			.elseif eax==IDM_FORMAT_ALIGN_CENTER
				invoke SendMessage,ha.hResEd,DEM_ALIGNSIZE,0,ALIGN_CENTER
			.elseif eax==IDM_FORMAT_ALIGN_RIGHT
				invoke SendMessage,ha.hResEd,DEM_ALIGNSIZE,0,ALIGN_RIGHT
			.elseif eax==IDM_FORMAT_ALIGN_TOP
				invoke SendMessage,ha.hResEd,DEM_ALIGNSIZE,0,ALIGN_TOP
			.elseif eax==IDM_FORMAT_ALIGN_MIDDLE
				invoke SendMessage,ha.hResEd,DEM_ALIGNSIZE,0,ALIGN_MIDDLE
			.elseif eax==IDM_FORMAT_ALIGN_BOTTOM
				invoke SendMessage,ha.hResEd,DEM_ALIGNSIZE,0,ALIGN_BOTTOM
			.elseif eax==IDM_FORMAT_SIZE_WIDTH
				invoke SendMessage,ha.hResEd,DEM_ALIGNSIZE,0,SIZE_WIDTH
			.elseif eax==IDM_FORMAT_SIZE_HEIGHT
				invoke SendMessage,ha.hResEd,DEM_ALIGNSIZE,0,SIZE_HEIGHT
			.elseif eax==IDM_FORMAT_SIZE_BOTH
				invoke SendMessage,ha.hResEd,DEM_ALIGNSIZE,0,SIZE_BOTH
			.elseif eax==IDM_FORMAT_CENTER_HOR
				invoke SendMessage,ha.hResEd,DEM_ALIGNSIZE,0,ALIGN_DLGHCENTER
			.elseif eax==IDM_FORMAT_CENTER_VERT
				invoke SendMessage,ha.hResEd,DEM_ALIGNSIZE,0,ALIGN_DLGVCENTER
			.elseif eax==IDM_FORMAT_TABINDEX
				invoke SendMessage,ha.hResEd,DEM_SHOWTABINDEX,0,0
			.elseif eax==IDM_VIEW_TOOLBAR
				xor		wpos.fView,1
				invoke SendMessage,hWin,WM_SIZE,0,0
				test	wpos.fView,1
				.if !ZERO?
					invoke ShowWindow,ha.hShp,SW_SHOWNA
					invoke ShowWindow,ha.hTbr,SW_SHOWNA
					invoke ShowWindow,ha.hStc,SW_SHOWNA
					invoke ShowWindow,ha.hCbo,SW_SHOWNA
				.else
					invoke ShowWindow,ha.hShp,SW_HIDE
					invoke ShowWindow,ha.hTbr,SW_HIDE
					invoke ShowWindow,ha.hStc,SW_HIDE
					invoke ShowWindow,ha.hCbo,SW_HIDE
				.endif
			.elseif eax==IDM_VIEW_STATUSBAR
				xor		wpos.fView,2
				invoke SendMessage,hWin,WM_SIZE,0,0
				test	wpos.fView,2
				.if !ZERO?
					invoke ShowWindow,ha.hSbr,SW_SHOWNA
				.else
					invoke ShowWindow,ha.hSbr,SW_HIDE
				.endif
			.elseif eax==IDM_VIEW_OUTPUT
				xor		wpos.fView,4
				test	wpos.fView,4
				.if !ZERO?
					invoke ShowWindow,ha.hTabOut,SW_SHOWNA
					.if nOutSel==1
						invoke ShowWindow,ha.hImmOut,SW_SHOWNA
						invoke ShowWindow,ha.hOut,SW_HIDE
					.else
						invoke ShowWindow,ha.hOut,SW_SHOWNA
						invoke ShowWindow,ha.hImmOut,SW_HIDE
					.endif
				.else
					invoke ShowWindow,ha.hOut,SW_HIDE
					invoke ShowWindow,ha.hImmOut,SW_HIDE
					invoke ShowWindow,ha.hTabOut,SW_HIDE
				.endif
				invoke SendMessage,hWin,WM_SIZE,0,0
				invoke SetFocus,hWin
				mov		fTimer,1
			.elseif eax==IDM_VIEW_FILEBROWSER
				xor		wpos.fView,8
				test	wpos.fView,8
				.if !ZERO?
					invoke ShowWindow,ha.hTabPbr,SW_SHOWNA
					invoke SendMessage,ha.hTabPbr,TCM_GETCURSEL,0,0
					.if eax
						invoke ShowWindow,ha.hPbr,SW_SHOWNA
					.else
						invoke ShowWindow,ha.hBrowse,SW_SHOWNA
					.endif
					invoke ShowWindow,ha.hBrowse,SW_SHOWNA
					invoke ShowWindow,ha.hProperty,SW_SHOWNA
					.if fDebugging
						invoke ShowWindow,ha.hTabDbg,SW_SHOWNA
						.if nDbgSel==2
							invoke ShowWindow,ha.hDbgWatch,SW_SHOWNA
						.elseif nDbgSel==1
							invoke ShowWindow,ha.hDbgFpu,SW_SHOWNA
						.else
							invoke ShowWindow,ha.hDbgReg,SW_SHOWNA
						.endif
					.endif
				.else
					invoke ShowWindow,ha.hTabPbr,SW_HIDE
					invoke ShowWindow,ha.hBrowse,SW_HIDE
					invoke ShowWindow,ha.hPbr,SW_HIDE
					invoke ShowWindow,ha.hProperty,SW_HIDE
					invoke ShowWindow,ha.hDbgReg,SW_HIDE
					invoke ShowWindow,ha.hDbgFpu,SW_HIDE
					invoke ShowWindow,ha.hDbgWatch,SW_HIDE
					invoke ShowWindow,ha.hTabDbg,SW_HIDE
				.endif
				invoke SendMessage,hWin,WM_SIZE,0,0
			.elseif eax==IDM_VIEW_DIALOG
				invoke SendMessage,ha.hResEd,DEM_SHOWDIALOG,0,0
			.elseif eax==IDM_VIEW_NEXTTAB
				invoke SendMessage,ha.hTab,TCM_GETITEMCOUNT,0,0
				.if eax
					mov		ebx,eax
					invoke SendMessage,ha.hTab,TCM_GETCURSEL,0,0
					inc		eax
					.if eax>=ebx
						xor		eax,eax
					.endif
					invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
					invoke TabToolActivate
				.endif
			.elseif eax==IDM_VIEW_PREVIOUSTAB
				invoke SendMessage,ha.hTab,TCM_GETITEMCOUNT,0,0
				.if eax
					mov		ebx,eax
					invoke SendMessage,ha.hTab,TCM_GETCURSEL,0,0
					.if !eax
						lea		eax,[ebx-1]
					.else
						dec		eax
					.endif
					invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
					invoke TabToolActivate
				.endif
			.elseif eax==IDM_RESOURCE_DIALOG
				invoke SendMessage,ha.hResEd,PRO_ADDITEM,TPE_DIALOG,TRUE
			.elseif eax==IDM_RESOURCE_MENU
				invoke SendMessage,ha.hResEd,PRO_ADDITEM,TPE_MENU,TRUE
			.elseif eax==IDM_RESOURCE_ACCEL
				invoke SendMessage,ha.hResEd,PRO_ADDITEM,TPE_ACCEL,TRUE
			.elseif eax==IDM_RESOURCE_VERINF
				invoke SendMessage,ha.hResEd,PRO_ADDITEM,TPE_VERSION,TRUE
			.elseif eax==IDM_RESOURCE_MANIFEST
				invoke SendMessage,ha.hResEd,PRO_ADDITEM,TPE_XPMANIFEST,TRUE
			.elseif eax==IDM_RESOURCE_RCDATA
				invoke SendMessage,ha.hResEd,PRO_ADDITEM,TPE_RCDATA,TRUE
			.elseif eax==IDM_RESOURCE_TOOLBAR
				invoke SendMessage,ha.hResEd,PRO_ADDITEM,TPE_TOOLBAR,TRUE
			.elseif eax==IDM_RESOURCE_LANGUAGE
				invoke SendMessage,ha.hResEd,PRO_ADDITEM,TPE_LANGUAGE,TRUE
			.elseif eax==IDM_RESOURCE_INCLUDE
				invoke SendMessage,ha.hResEd,PRO_ADDITEM,TPE_INCLUDE,TRUE
			.elseif eax==IDM_RESOURCE_RESOURCE
				invoke SendMessage,ha.hResEd,PRO_ADDITEM,TPE_RESOURCE,TRUE
			.elseif eax==IDM_RESOURCE_STRING
				invoke SendMessage,ha.hResEd,PRO_ADDITEM,TPE_STRING,TRUE
			.elseif eax==IDM_RESOURCE_NAME
				invoke SendMessage,ha.hResEd,PRO_SHOWNAMES,0,ha.hOut
			.elseif eax==IDM_RESOURCE_EXPORT
				invoke SendMessage,ha.hResEd,PRO_EXPORTNAMES,0,ha.hOut
			.elseif eax==IDM_RESOURCE_REMOVE
				invoke SendMessage,ha.hResEd,PRO_DELITEM,0,0
			.elseif eax==IDM_RESOURCE_UNDO
				invoke SendMessage,ha.hResEd,PRO_UNDODELETED,0,0
			.elseif eax==IDM_MAKE_COMPILE
				invoke UpdateAll,CLEAR_ERRORS,0
				invoke UpdateAll,SAVE_ALL,0
				invoke PostAddinMessage,hWin,AIM_MAKEBEGIN,IDM_MAKE_COMPILE,offset da.MainFile,0,HOOK_MAKEBEGIN
				.if !eax
					invoke OutputMake,IDM_MAKE_COMPILE,offset da.MainFile,TRUE
					or		eax,eax
					jne		Ex
					invoke PostAddinMessage,hWin,AIM_MAKEDONE,IDM_MAKE_COMPILE,offset da.MainFile,0,HOOK_MAKEDONE
				.endif
			.elseif eax==IDM_MAKE_ASSEMBLE
				invoke UpdateAll,CLEAR_ERRORS,0
				invoke UpdateAll,SAVE_ALL,0
				invoke PostAddinMessage,hWin,AIM_MAKEBEGIN,IDM_MAKE_ASSEMBLE,offset da.MainFile,0,HOOK_MAKEBEGIN
				.if !eax
					invoke OutputMake,IDM_MAKE_ASSEMBLE,offset da.MainFile,TRUE
					or		eax,eax
					jne		Ex
					invoke PostAddinMessage,hWin,AIM_MAKEDONE,IDM_MAKE_ASSEMBLE,offset da.MainFile,0,HOOK_MAKEDONE
				.endif
			.elseif eax==IDM_MAKE_LINK
				invoke UpdateAll,CLEAR_ERRORS,0
				invoke UpdateAll,SAVE_ALL,0
				invoke PostAddinMessage,hWin,AIM_MAKEBEGIN,IDM_MAKE_LINK,offset da.MainFile,0,HOOK_MAKEBEGIN
				.if !eax
					invoke OutputMake,IDM_MAKE_LINK,offset da.MainFile,TRUE
					or		eax,eax
					jne		Ex
					invoke PostAddinMessage,hWin,AIM_MAKEDONE,IDM_MAKE_LINK,offset da.MainFile,0,HOOK_MAKEDONE
				.endif
			.elseif eax==IDM_MAKE_BUILD
				invoke UpdateAll,CLEAR_ERRORS,0
				invoke UpdateAll,SAVE_ALL,0
				invoke PostAddinMessage,hWin,AIM_MAKEBEGIN,IDM_MAKE_BUILD,offset da.MainFile,0,HOOK_MAKEBEGIN
				.if !eax
					invoke OutputMake,IDM_MAKE_COMPILE,offset da.MainFile,2
					or		eax,eax
					jne		Ex
					invoke OutputMake,IDM_MAKE_ASSEMBLE,offset da.MainFile,0
					or		eax,eax
					jne		Ex
					invoke OutputMake,IDM_MAKE_LINK,offset da.MainFile,3
					or		eax,eax
					jne		Ex
					invoke PostAddinMessage,hWin,AIM_MAKEDONE,IDM_MAKE_BUILD,offset da.MainFile,0,HOOK_MAKEDONE
				.endif
			.elseif eax==IDM_MAKE_RUN
				invoke UpdateAll,SAVE_ALL,0
				invoke PostAddinMessage,hWin,AIM_MAKEBEGIN,IDM_MAKE_RUN,offset da.MainFile,0,HOOK_MAKEBEGIN
				.if !eax
					invoke OutputMake,IDM_MAKE_RUN,offset da.MainFile,2
					or		eax,eax
					jne		Ex
					invoke PostAddinMessage,hWin,AIM_MAKEDONE,IDM_MAKE_RUN,offset da.MainFile,0,HOOK_MAKEDONE
				.endif
			.elseif eax==IDM_MAKE_GO
				invoke UpdateAll,CLEAR_ERRORS,0
				invoke UpdateAll,SAVE_ALL,0
				invoke PostAddinMessage,hWin,AIM_MAKEBEGIN,IDM_MAKE_GO,offset da.MainFile,0,HOOK_MAKEBEGIN
				.if !eax
					invoke OutputMake,IDM_MAKE_COMPILE,offset da.MainFile,2
					or		eax,eax
					jne		Ex
					invoke OutputMake,IDM_MAKE_ASSEMBLE,offset da.MainFile,0
					or		eax,eax
					jne		Ex
					invoke OutputMake,IDM_MAKE_LINK,offset da.MainFile,3
					or		eax,eax
					jne		Ex
					invoke OutputMake,IDM_MAKE_RUN,offset da.MainFile,4
					or		eax,eax
					jne		Ex
					invoke PostAddinMessage,hWin,AIM_MAKEDONE,IDM_MAKE_GO,offset da.MainFile,0,HOOK_MAKEDONE
				.endif
			.elseif eax==IDM_DEBUG_TOGGLE
				invoke GetWindowLong,ha.hREd,GWL_ID
				.if eax==IDC_RAE
					invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,ha.hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
					mov		ebx,eax
					inc		eax
					invoke DebugCommand,FUNC_ISCODELINE,eax,addr da.FileName
					mov		edi,eax
					invoke SendMessage,ha.hREd,REM_GETLINESTATE,ebx,0
					and		eax,STATE_BREAKPOINT
					xor		eax,STATE_BREAKPOINT
					.if !eax || edi
						invoke SendMessage,ha.hREd,REM_SETBREAKPOINT,ebx,eax
						invoke SaveBreakpoints,ha.hREd
						invoke DebugCommand,FUNC_BPCLEARALL,0,0
						invoke UpdateAll,SET_BREAKPOINTS,0
						invoke DebugCommand,FUNC_BPUPDATE,0,0
					.endif
				.endif
			.elseif eax==IDM_DEBUG_CLEAR
				invoke UpdateAll,CLEAR_BREAKPOINTS,0
				invoke DebugCommand,FUNC_BPCLEARALL,0,0
				invoke DebugCommand,FUNC_BPUPDATE,0,0
				.if da.fProject && da.szSessionFile
					mov		word ptr buffer,0
					invoke WritePrivateProfileSection,addr szBreakPoint,addr buffer,addr da.szSessionFile
				.endif
			.elseif eax==IDM_DEBUG_RUN
				.if !fDebugging
					mov		nUnsaved,0
					invoke UpdateAll,UNSAVED_SOURCE_FILES,0
					.if nUnsaved
						invoke wsprintf,addr buffer,addr szUnsaved,nUnsaved
						invoke MessageBox,hWin,addr buffer,addr szAppName,MB_OK or MB_ICONERROR
						jmp		Ex
					.endif
					invoke strcpy,addr dbginf.FileName,offset da.MainFile
					invoke RemoveFileExt,addr dbginf.FileName
					invoke strcat,addr dbginf.FileName,offset ExtExe
					invoke CreateFile,addr dbginf.FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
					.if eax!=INVALID_HANDLE_VALUE
						mov		hFile,eax
						invoke GetFileTime,hFile,NULL,NULL,addr ftexe
						invoke CloseHandle,hFile
						mov		nNewer,0
						invoke UpdateAll,NEWER_SOURCE_FILES,0
						.if nNewer
							invoke wsprintf,addr buffer,addr szNewer,nNewer
							invoke MessageBox,hWin,addr buffer,addr szAppName,MB_OK or MB_ICONERROR
							jmp		Ex
						.endif
					.else
						invoke strcpy,addr buffer,addr szOpenFileFail
						invoke strcat,addr buffer,addr dbginf.FileName
						invoke MessageBox,hWin,addr buffer,addr szAppName,MB_OK or MB_ICONERROR
						jmp		Ex
					.endif
					mov		eax,ha.hWnd
					mov		dbginf.hWnd,eax
					mov		eax,ha.hOut
					mov		dbginf.hOut,eax
					mov		eax,ha.hImmOut
					mov		dbginf.hImmOut,eax
					mov		eax,ha.hDbgReg
					mov		dbginf.hDbgReg,eax
					mov		eax,ha.hDbgFpu
					mov		dbginf.hDbgFpu,eax
					mov		eax,ha.hDbgMMX
					mov		dbginf.hDbgMMX,eax
					mov		eax,ha.hDbgWatch
					mov		dbginf.hDbgWatch,eax
					mov		eax,ha.hProperty
					mov		dbginf.hPrp,eax
					mov		dbginf.lpNoDebug,offset NoDebug
					mov		eax,fMainThread
					mov		dbginf.fMainThread,eax
					mov		dbginf.lpCallBack,offset DebugCallback
					mov		eax,da.fProject
					mov		dbginf.fProject,eax
					invoke SetDebugInfo,addr dbginf
					invoke DebugCommand,FUNC_BPCLEARALL,0,0
					.if da.fProject && da.szSessionFile
						xor		ebx,ebx
						.while TRUE
							invoke SendMessage,ha.hPbr,RPBM_GETITEM,ebx,0
							.break .if ![eax].PBITEM.id
							.if sdword ptr [eax].PBITEM.id>0
								mov		edi,eax
								invoke wsprintf,addr buffer,addr szFmtDec,[edi].PBITEM.id
								invoke GetPrivateProfileString,addr szBreakPoint,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szSessionFile
								mov		esi,offset tmpbuff
								.while byte ptr [esi]
									invoke strgetitem,esi,addr buffer
									mov		esi,eax
									.if buffer
										invoke AsciiToDw,addr buffer
										lea		edx,[eax+1]
										invoke DebugCommand,FUNC_BPADDLINE,edx,addr [edi].PBITEM.szitem
									.endif
								.endw
							.endif
							inc		ebx
						.endw
					.else
						invoke UpdateAll,SET_BREAKPOINTS,0
					.endif
				.endif
				invoke DebugCommand,FUNC_RUN,0,0
			.elseif eax==IDM_DEBUG_BREAK
				invoke DebugCommand,FUNC_BREAK,0,0
			.elseif eax==IDM_DEBUG_STOP
				invoke DebugCommand,FUNC_STOP,0,0
			.elseif eax==IDM_DEBUG_INTO
				invoke DebugCommand,FUNC_STEPINTO,0,0
			.elseif eax==IDM_DEBUG_OVER
				invoke DebugCommand,FUNC_STEPOVER,0,0
			.elseif eax==IDM_DEBUG_CARET
				invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
				invoke SendMessage,ha.hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
				lea		ebx,[eax+1]
				invoke DebugCommand,FUNC_ISCODELINE,ebx,offset da.FileName
				.if eax
					invoke DebugCommand,FUNC_RUNTOCARET,ebx,offset da.FileName
				.endif
			.elseif eax==IDM_DEBUG_NODEBUG
				invoke DialogBoxParam,ha.hInstance,IDD_DLGDONOTDEBUG,hWin,offset NoDebugProc,0
			.elseif eax==IDM_MAKE_MAINFILE
				invoke strcpy,addr da.MainFile,addr da.FileName
				mov		fTimer,1
			.elseif eax==IDM_OPTION_CODE
				invoke DialogBoxParam,ha.hInstance,IDD_DLGKEYWORDS,hWin,offset KeyWordsProc,0
			.elseif eax==IDM_OPTION_DIALOG
				invoke DialogBoxParam,ha.hInstance,IDD_TABOPTIONS,hWin,offset TabOptionsProc,0
			.elseif eax==IDM_OPTION_PATH
				invoke DialogBoxParam,ha.hInstance,IDD_PATHOPTION,hWin,offset PathOptionDialogProc,0
			.elseif eax==IDM_OPTION_BUILD
				invoke DialogBoxParam,ha.hInstance,IDD_BUILDOPTION,hWin,offset BuildOptionDialogProc,0
			.elseif eax==IDM_OPTION_ADDINS
				invoke DialogBoxParam,ha.hInstance,IDD_DLGADDINMANAGER,hWin,offset AddinManagerProc,0
			.elseif eax==IDM_OPTION_TOOLS
				invoke DialogBoxParam,ha.hInstance,IDD_DLGOPTMNU,hWin,offset MenuOptionProc,1
				invoke SetToolMenu
				invoke ResetMenu
			.elseif eax==IDM_OPTION_HELP
				invoke DialogBoxParam,ha.hInstance,IDD_DLGOPTMNU,hWin,offset MenuOptionProc,2
				invoke SetHelpMenu
				invoke ResetMenu
			.elseif eax==IDM_OPTION_EXTERNAL
				invoke DialogBoxParam,ha.hInstance,IDD_DLGOPTMNU,hWin,offset MenuOptionProc,3
			.elseif eax==IDM_HELP_ABOUT
				invoke DialogBoxParam,ha.hInstance,IDD_DLGABOUT,hWin,offset AboutProc,0
			.elseif ax==-3
				;Expand button clicked
				invoke SendMessage,ha.hREd,REM_EXPANDALL,0,0
				invoke SendMessage,ha.hREd,EM_SCROLLCARET,0,0
				invoke SendMessage,ha.hREd,REM_REPAINT,0,0
			.elseif ax==-4
				;Collapse button clicked
				invoke SendMessage,ha.hREd,REM_COLLAPSEALL,0,0
				invoke SendMessage,ha.hREd,EM_SCROLLCARET,0,0
				invoke SendMessage,ha.hREd,REM_REPAINT,0,0
			.elseif eax==IDM_HELPF1
				;F1-Help key pressed
				mov		mnu.szcap,0
				mov		mnu.szcmnd,0
				invoke strcpy,addr buffer,addr szMenuHelp
				invoke strlen,addr buffer
				mov		word ptr buffer[eax],'1'
				mov		lpcbData,sizeof mnu
				invoke RegQueryValueEx,ha.hReg,addr buffer,0,addr lpType,addr mnu,addr lpcbData
				movzx	eax,mnu.szcmnd
				.if eax
					invoke SendMessage,ha.hREd,REM_GETWORD,sizeof buffer,addr buffer
					invoke WinHelp,hWin,addr mnu.szcmnd,HELP_KEY,addr buffer
				.endif
			.elseif eax>=20000 && eax<=20020
				;Tool
				mov		mnu.szcap,0
				mov		mnu.szcmnd,0
				mov		edx,eax
				sub		edx,19999
				invoke MakeKey,addr szMenuTool,edx,addr buffer
				mov		lpcbData,sizeof mnu
				invoke RegQueryValueEx,ha.hReg,addr buffer,0,addr lpType,addr mnu,addr lpcbData
				movzx	eax,mnu.szcmnd
				.if eax
					invoke ParseCmnd,addr mnu.szcmnd,addr buffer,addr buffer1
					invoke ShellExecute,hWin,NULL,addr buffer,addr buffer1,NULL,SW_SHOWNORMAL;SW_SHOWDEFAULT
				.endif
			.elseif eax>=22000 && eax<22032
				;User resource type
				lea		eax,[eax-22000+32]
				invoke SendMessage,ha.hResEd,PRO_ADDITEM,eax,TRUE
			.elseif eax>=30000 && eax<=30020
				;Help
				mov		mnu.szcap,0
				mov		mnu.szcmnd,0
				mov		edx,eax
				sub		edx,29999
				invoke MakeKey,addr szMenuHelp,edx,addr buffer
				mov		lpcbData,sizeof mnu
				invoke RegQueryValueEx,ha.hReg,addr buffer,0,addr lpType,addr mnu,addr lpcbData
				movzx	eax,mnu.szcmnd
				.if eax
					invoke ParseCmnd,addr mnu.szcmnd,addr buffer,addr buffer1
					invoke ShellExecute,hWin,NULL,addr buffer,addr buffer1,NULL,SW_SHOWNORMAL;SW_SHOWDEFAULT
				.endif
			.elseif eax==IDM_OUTPUT_CLEAR
				invoke SendMessage,ha.hOut,WM_SETTEXT,0,addr szNULL
			.elseif eax==IDM_IMMEDIATE_CLEAR
				invoke SendMessage,ha.hImmOut,WM_SETTEXT,0,addr szNULL
			.elseif eax==IDM_BROWSER_OPEN
				invoke SendMessage,ha.hBrowse,FBM_GETSELECTED,0,addr buffer
				invoke GetFileAttributes,addr buffer
				test	eax,FILE_ATTRIBUTE_DIRECTORY
				.if ZERO?
					invoke OpenEditFile,addr buffer,0
				.else
					invoke SendMessage,ha.hBrowse,FBM_SETPATH,TRUE,addr buffer
				.endif
			.elseif eax==IDM_BROWSER_COPY
				invoke SendMessage,ha.hBrowse,FBM_GETSELECTED,0,addr buffer
				invoke SendMessage,ha.hREd,EM_REPLACESEL,TRUE,addr buffer
				invoke SetFocus,ha.hREd
			.elseif eax==IDM_PROPERTY_GOTODECLARE
				invoke SendMessage,ha.hProperty,WM_COMMAND,(LBN_DBLCLK shl 16) or 1003,0
			.elseif eax==IDM_PROPERTY_COPYTOCODE
				invoke SendMessage,ha.hProperty,PRM_GETSELTEXT,0,offset tmpbuff
				.if eax
					invoke SendMessage,ha.hREd,EM_REPLACESEL,TRUE,offset tmpbuff
					invoke SetFocus,ha.hREd
				.endif
			.elseif eax==IDM_PROPERTY_COPYPROTO
				invoke SendMessage,ha.hProperty,PRM_GETSELTEXT,0,offset tmpbuff
				.if eax
					invoke SendMessage,ha.hProperty,PRM_FINDFIRST,offset szp,offset tmpbuff
					.while eax
						mov		ebx,eax
						invoke strcmp,offset tmpbuff,ebx
						.if !eax
							invoke strcat,offset tmpbuff,offset szPROTO
							invoke strlen,ebx
							lea		ebx,[ebx+eax+1]
							.if byte ptr [ebx]
								invoke strcat,offset tmpbuff,offset szSpc
								invoke strcat,offset tmpbuff,ebx
							.endif
							invoke strcat,offset tmpbuff,offset szCr
							invoke SendMessage,ha.hREd,EM_REPLACESEL,TRUE,offset tmpbuff
							invoke SetFocus,ha.hREd
							.break
						.endif
						invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
					.endw
				.endif
			.elseif eax==IDM_PROJECT_CREATE
				.if !ha.hREd
					invoke MessageBox,hWin,addr szNewProject,addr szAppName,MB_YESNO or MB_ICONQUESTION
					.if eax==IDNO
						jmp		Ex
					.endif
				.endif
				invoke CreateProject,addr da.szSessionFile
			.elseif eax==IDM_PROJECT_OPEN
				invoke OpenSessionFile
				.if eax
					.if da.szSessionFile && !da.fProject
						invoke CreateProject,addr da.szSessionFile
					.endif
					mov		fTimer,1
				.endif
			.elseif eax==IDM_PROJECT_CLOSE
				mov		nTabInx,-1
				invoke UpdateAll,WM_CLOSE,0
				.if !eax
					invoke AskSaveSessionFile
					.if !eax
						invoke UpdateAll,CLOSE_ALL,0
						.if da.fProject
							invoke SaveProject,addr da.szSessionFile
							invoke SendMessage,ha.hProperty,PRM_DELPROPERTY,0,0
							invoke SendMessage,ha.hPbr,RPBM_ADDITEM,0,0
							invoke SendMessage,ha.hPbr,RPBM_SETGROUPING,TRUE,RPBG_NOCHANGE
							mov		da.fProject,FALSE
						.endif
						mov		da.szSessionFile,0
						mov		da.MainFile,0
						invoke CloseNotify
						invoke SendMessage,ha.hTabPbr,TCM_SETCURSEL,0,0
						invoke ShowWindow,ha.hBrowse,SW_SHOWNA
						invoke ShowWindow,ha.hPbr,SW_HIDE
					.endif
				.endif
				invoke SendMessage,ha.hProperty,PRM_REFRESHLIST,0,0
				mov		fTimer,1
			.elseif eax==IDM_PROJECT_ADDGROUP
				invoke SendMessage,ha.hPbr,RPBM_ADDNEWGROUP,0,0
			.elseif eax==IDM_PROJECT_ADDFILE
				invoke SendMessage,ha.hPbr,RPBM_ADDNEWFILE,0,addr da.FileName
				.if eax
					mov		esi,eax
					invoke GetWindowLong,ha.hREd,GWL_USERDATA
					mov		edx,[esi].PBITEM.id
					mov		[eax].TABMEM.pid,edx
					invoke ParseEdit,ha.hREd,edx
				.endif
			.elseif eax==IDM_PROJECT_ADDALLFILES
				invoke UpdateAll,ADDTOPROJECT,0
			.elseif eax==IDM_PROJECT_ADDEXISTINGFILE
				invoke ProjectAddExistingFiles
			.elseif eax==IDM_PROJECT_ADDNEWFILE
				invoke CreateNewProjectFile
			.elseif eax==IDM_PROJECT_REMOVEGROUP
				invoke SendMessage,ha.hPbr,RPBM_DELETEITEM,0,0
			.elseif eax==IDM_PROJECT_REMOVEFILE
				invoke SendMessage,ha.hPbr,RPBM_GETSELECTED,0,0
				.if eax
					invoke SendMessage,ha.hProperty,PRM_DELPROPERTY,[eax].PBITEM.id,0
					invoke SendMessage,ha.hPbr,RPBM_DELETEITEM,0,0
					invoke SendMessage,ha.hProperty,PRM_REFRESHLIST,0,0
				.endif
			.elseif eax==IDM_PROJECT_EDITGROUP || eax==IDM_PROJECT_EDITFILE
				invoke SendMessage,ha.hPbr,RPBM_EDITITEM,0,0
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		edi,lParam
		mov		eax,[edi].NMHDR.code
		mov		ecx,[edi].NMHDR.idFrom
		.if eax==EN_SELCHANGE && ecx==IDC_RAE
			;Code editor
			mov		eax,[edi].RASELCHANGE.chrg.cpMin
			sub		eax,[edi].RASELCHANGE.cpLine
			invoke ShowPos,[edi].RASELCHANGE.line,eax
			.if [edi].RASELCHANGE.seltyp==SEL_OBJECT
				mov		esi,[edi].RASELCHANGE.line
				invoke SendMessage,ha.hREd,REM_GETBOOKMARK,esi,0
				.if eax==1
					;Collapse
					invoke GetKeyState,VK_CONTROL
					test	eax,80h
					.if ZERO?
						invoke SendMessage,ha.hREd,REM_COLLAPSE,esi,0
					.else
						invoke SendMessage,ha.hREd,REM_GETBLOCKEND,esi,0
						.if eax!=-1
							dec		eax
							mov		ebx,esi
							mov		esi,eax
							.while esi>=ebx && esi!=-1
								invoke SendMessage,ha.hREd,REM_COLLAPSE,esi,0
								invoke SendMessage,ha.hREd,REM_PRVBOOKMARK,esi,1
								mov		esi,eax
							.endw
						.endif
					.endif
				.elseif eax==2
					;Expand
					invoke GetKeyState,VK_CONTROL
					test	eax,80h
					.if ZERO?
						invoke SendMessage,ha.hREd,REM_EXPAND,esi,0
					.else
						invoke SendMessage,ha.hREd,REM_GETBLOCKEND,esi,0
						.if eax!=-1
							mov		ebx,eax
							.while esi<ebx
								invoke SendMessage,ha.hREd,REM_EXPAND,esi,0
								invoke SendMessage,ha.hREd,REM_NXTBOOKMARK,esi,2
								mov		esi,eax
							.endw
						.endif
					.endif
				.elseif eax==8
					;Expand hidden lines
					invoke SendMessage,ha.hREd,REM_EXPAND,esi,0
				.else
					;Clear bookmark
					invoke SendMessage,ha.hREd,REM_SETBOOKMARK,esi,0
				.endif
			.else
				invoke SendMessage,ha.hREd,REM_BRACKETMATCH,0,0
				.if [edi].RASELCHANGE.fchanged
					.if ![edi].RASELCHANGE.nWordGroup
						invoke SendMessage,ha.hREd,REM_SETCOMMENTBLOCKS,addr szCmntStart,addr szCmntEnd
					.endif
					invoke SendMessage,ha.hREd,WM_GETTEXTLENGTH,0,0
					.if eax!=nLastSize
						push	eax
						sub		eax,nLastSize
						invoke UpdateGoto,ha.hREd,[edi].RASELCHANGE.chrg.cpMin,eax
						pop		nLastSize
					.endif
				  OnceMore:
					invoke SendMessage,ha.hREd,REM_GETBOOKMARK,nLastLine,0
					mov		ebx,eax
					mov		esi,offset blocks
					mov		ecx,[esi]
					or		eax,-1
					.while ecx
						mov		edx,[ecx].RABLOCKDEF.flag
						shr		edx,16
						.if edx==[edi].RASELCHANGE.nWordGroup
							invoke SendMessage,ha.hREd,REM_ISLINE,nLastLine,[ecx].RABLOCKDEF.lpszStart
							.break .if eax!=-1
						.endif
						lea		esi,[esi+4]
						mov		ecx,[esi]
					.endw
					.if eax==-1
						.if ebx==1 || ebx==2
							;Clear bookmark
							.if ebx==2
								invoke SendMessage,ha.hREd,REM_EXPAND,nLastLine,0
							.endif
							invoke SendMessage,ha.hREd,REM_SETBOOKMARK,nLastLine,0
							invoke SendMessage,ha.hREd,REM_SETDIVIDERLINE,nLastLine,FALSE
							invoke SendMessage,ha.hREd,REM_SETSEGMENTBLOCK,nLastLine,FALSE
						.endif
					.else
						xor		eax,eax
						mov		ecx,[esi]
						test	[ecx].RABLOCKDEF.flag,BD_NONESTING
						.if !ZERO?
							invoke SendMessage,ha.hREd,REM_ISINBLOCK,nLastLine,ecx
						.endif
						.if !eax
							;Set bookmark
							mov		edx,nLastLine
							inc		edx
							invoke SendMessage,ha.hREd,REM_ISLINEHIDDEN,edx,0
							.if eax
								invoke SendMessage,ha.hREd,REM_SETBOOKMARK,nLastLine,2
							.else
								invoke SendMessage,ha.hREd,REM_SETBOOKMARK,nLastLine,1
							.endif
							mov		edx,[esi]
							mov		edx,[edx].RABLOCKDEF.flag
							and		edx,BD_DIVIDERLINE
							invoke SendMessage,ha.hREd,REM_SETDIVIDERLINE,nLastLine,edx
							mov		edx,[esi]
							mov		edx,[edx].RABLOCKDEF.flag
							and		edx,BD_SEGMENTBLOCK
							invoke SendMessage,ha.hREd,REM_SETSEGMENTBLOCK,nLastLine,edx
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
					invoke GetWindowLong,ha.hREd,GWL_USERDATA
					mov		esi,eax
					.if ![esi].TABMEM.fchanged
						invoke TabToolSetChanged,ha.hREd,TRUE
					.endif
					.if ![edi].RASELCHANGE.nWordGroup
						.if !ccinprogress
							invoke ApiListBox,edi
						.endif
						mov		[esi].TABMEM.fupdate,TRUE
					.endif
				.endif
				mov		eax,[edi].RASELCHANGE.line
				mov		nLastLine,eax
				.if eax!=nLastPropLine
					mov		nLastPropLine,eax
					invoke ShowWindow,ha.hCCLB,SW_HIDE
					invoke ShowWindow,ha.hCCTT,SW_HIDE
					mov		cctype,CCTYPE_NONE
					.if ![edi].RASELCHANGE.nWordGroup
						invoke GetWindowLong,ha.hREd,GWL_USERDATA
						.if [eax].TABMEM.fupdate
							mov		[eax].TABMEM.fupdate,FALSE
							invoke ParseEdit,ha.hREd,[eax].TABMEM.pid
						.endif
					.endif
				.elseif cctype==CCTYPE_ALL
					.if !ccinprogress
						invoke ApiListBox,edi
					.endif
				.endif
			.endif
			mov		fTimer,2
		.elseif eax==EN_SELCHANGE && ecx==IDC_HEX
			;Hex editor
			.if [edi].HESELCHANGE.fchanged
				invoke GetWindowLong,ha.hREd,GWL_USERDATA
				.if ![eax].TABMEM.fchanged
					invoke TabToolSetChanged,ha.hREd,TRUE
				.endif
			.endif
			mov		fTimer,2
		.elseif eax==RPBN_DBLCLICK && ecx==IDC_PROJECT
			;Projectbrowser
			mov		eax,[edi].NMPBITEMDBLCLICK.lpPBITEM
			invoke OpenEditFile,addr [eax].PBITEM.szitem,0
		.elseif eax==RPBN_ITEMCHANGE && ecx==IDC_PROJECT
			;Projectbrowser
			invoke GetFileAttributes,[edi].NMPBITEMCHANGE.lpsznew
			.if eax!=INVALID_HANDLE_VALUE
				;File exists
				mov		[edi].NMPBITEMCHANGE.cancel,TRUE
				invoke strcpy,offset tmpbuff,offset szFileExists
				invoke strcat,offset tmpbuff,[edi].NMPBITEMCHANGE.lpsznew
				invoke MessageBox,ha.hWnd,offset tmpbuff,offset szAppName,MB_OK or MB_ICONERROR
			.else
				mov		esi,[edi].NMPBITEMCHANGE.lpPBITEM
				invoke lstrcpy,addr buffer,addr [esi].PBITEM.szitem
				invoke UpdateAll,IS_OPEN,addr [esi].PBITEM.szitem
				.if eax
					mov		ebx,eax
					;File is open
					invoke UpdateFileName,eax,[edi].NMPBITEMCHANGE.lpsznew
					.if eax
						;Probably not a valid filename
						mov		[edi].NMPBITEMCHANGE.cancel,TRUE
					.else
						;Delete old file
						invoke DeleteFile,addr buffer
						.if ebx==ha.hREd
							invoke strcpy,offset da.FileName,[edi].NMPBITEMCHANGE.lpsznew
							invoke SetWinCaption,[edi].NMPBITEMCHANGE.lpsznew
						.endif
					.endif
				.else
					;File is not open, move it
					invoke MoveFile,addr [esi].PBITEM.szitem,[edi].NMPBITEMCHANGE.lpsznew
					.if !eax
						;Probably not a valid filename
						mov		[edi].NMPBITEMCHANGE.cancel,TRUE
						invoke strcpy,offset tmpbuff,offset szSaveFileFail
						invoke strcat,offset tmpbuff,[edi].NMPBITEMCHANGE.lpsznew
						invoke MessageBox,ha.hWnd,offset tmpbuff,offset szAppName,MB_OK or MB_ICONERROR
					.endif
				.endif
			.endif
		.elseif eax==RPBN_SELCHANGE && ecx==IDC_PROJECT
			mov		fTimer,1
		.elseif eax==FBN_DBLCLICK && ecx==IDC_FILE
			;Filebrowser
			invoke OpenEditFile,[edi].FBNOTIFY.lpfile,0
		.elseif eax==BN_CLICKED && ecx==IDC_PROPERTY
			;Property toolbar
			mov		eax,[edi].RAPNOTIFY.nid
			.if eax==1
				invoke SendMessage,ha.hProperty,PRM_SELOWNER,ha.hREd,0
			.elseif eax==2
				invoke SendMessage,ha.hProperty,PRM_SELOWNER,0,0
			.elseif eax==5
				invoke SendMessage,ha.hProperty,PRM_GETSELBUTTON,0,0
				.if eax==1
					invoke SendMessage,ha.hProperty,PRM_SELOWNER,ha.hREd,0
				.endif
				invoke SendMessage,ha.hProperty,PRM_REFRESHLIST,0,0
			.endif
		.elseif eax==LBN_DBLCLK && ecx==IDC_PROPERTY
			;Property list
			.if ha.hREd
				invoke GetWindowLong,ha.hREd,GWL_ID
				.if eax==IDC_RAE
					invoke SendMessage,ha.hREd,EM_EXGETSEL,0,addr chrg
					invoke PushGoto,ha.hREd,chrg.cpMin
				.endif
			.endif
			push	[edi].RAPNOTIFY.nline
			.if da.fProject
				invoke TabToolGetInxFromPid,[edi].RAPNOTIFY.nid
			.else
				invoke TabToolGetInx,[edi].RAPNOTIFY.nid
			.endif
			.if eax==-1
				invoke SendMessage,ha.hPbr,RPBM_FINDITEM,[edi].RAPNOTIFY.nid,0
				.if eax
					invoke OpenEditFile,addr [eax].PBITEM.szitem,IDC_RAE
				.else
					jmp		Ex
				.endif
			.else
				invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
				invoke TabToolActivate
			.endif
			pop		eax
			invoke SendMessage,ha.hREd,EM_LINEINDEX,eax,0
			mov		chrg.cpMin,eax
			mov		chrg.cpMax,eax
			invoke SendMessage,ha.hREd,EM_EXSETSEL,0,addr chrg
			invoke SendMessage,ha.hREd,REM_VCENTER,0,0
			invoke SetFocus,ha.hREd
		.elseif eax==TTN_NEEDTEXT
			;Toolbar tooltip
			invoke LoadString,ha.hInstance,ecx,addr buffer,sizeof buffer
			lea		eax,buffer
			mov		(TOOLTIPTEXT ptr [edi]).lpszText,eax
		.elseif eax==TCN_SELCHANGE && ecx==IDC_TAB
			invoke TabToolActivate
			invoke SetFocus,ha.hREd
		.elseif eax==TCN_SELCHANGE && ecx==IDC_TABOUT
			;Output tab
			invoke SendMessage,ha.hTabOut,TCM_GETCURSEL,0,0
			mov		nOutSel,eax
			.if wpos.fView & 4
				.if nOutSel
					invoke ShowWindow,ha.hImmOut,SW_SHOWNA
					invoke ShowWindow,ha.hOut,SW_HIDE
					invoke SetFocus,ha.hImmOut
				.else
					invoke ShowWindow,ha.hOut,SW_SHOWNA
					invoke ShowWindow,ha.hImmOut,SW_HIDE
					invoke SetFocus,ha.hOut
				.endif
			.endif
		.elseif eax==TCN_SELCHANGE && ecx==IDC_TABWATCH
			;Debug watch tab
			invoke SendMessage,ha.hTabDbg,TCM_GETCURSEL,0,0
			mov		nDbgSel,eax
			.if nDbgSel==3
				; Watch
				invoke ShowWindow,ha.hDbgWatch,SW_SHOWNA
				invoke ShowWindow,ha.hDbgReg,SW_HIDE
				invoke ShowWindow,ha.hDbgFpu,SW_HIDE
				invoke ShowWindow,ha.hDbgMMX,SW_HIDE
			.elseif nDbgSel==2
				; MMX
				invoke ShowWindow,ha.hDbgMMX,SW_SHOWNA
				invoke ShowWindow,ha.hDbgReg,SW_HIDE
				invoke ShowWindow,ha.hDbgFpu,SW_HIDE
				invoke ShowWindow,ha.hDbgWatch,SW_HIDE
			.elseif nDbgSel==1
				; FPU
				invoke ShowWindow,ha.hDbgFpu,SW_SHOWNA
				invoke ShowWindow,ha.hDbgReg,SW_HIDE
				invoke ShowWindow,ha.hDbgWatch,SW_HIDE
				invoke ShowWindow,ha.hDbgMMX,SW_HIDE
			.else
				; Register
				invoke ShowWindow,ha.hDbgReg,SW_SHOWNA
				invoke ShowWindow,ha.hDbgFpu,SW_HIDE
				invoke ShowWindow,ha.hDbgWatch,SW_HIDE
				invoke ShowWindow,ha.hDbgMMX,SW_HIDE
			.endif
		.elseif eax==TCN_SELCHANGE && ecx==IDC_TABPROJECT
			invoke SendMessage,ha.hTabPbr,TCM_GETCURSEL,0,0
			.if eax
				invoke ShowWindow,ha.hPbr,SW_SHOWNA
				invoke ShowWindow,ha.hBrowse,SW_HIDE
			.else
				invoke ShowWindow,ha.hBrowse,SW_SHOWNA
				invoke ShowWindow,ha.hPbr,SW_HIDE
			.endif
		.endif
	.elseif eax==WM_SETFOCUS
		.if ha.hREd
			invoke SetFocus,ha.hREd
		.endif
	.elseif eax==WM_CLOSE
		invoke PostAddinMessage,hWin,AIM_CLOSE,wParam,lParam,0,HOOK_CLOSE
		.if eax
			jmp		Ex
		.endif
		mov		nTabInx,-1
		invoke UpdateAll,WM_CLOSE,0
		.if !eax
			invoke AskSaveSessionFile
			.if !eax
				invoke MakeSession,TRUE
				invoke strcpy,addr LineTxt,addr tmpbuff
				invoke strcpy,addr tmpbuff,addr da.szSessionFile
				invoke strcat,addr tmpbuff,addr szComma
				invoke strcat,addr tmpbuff,addr LineTxt
				invoke strlen,addr tmpbuff
				inc		eax
				invoke RegSetValueEx,ha.hReg,addr szSession,0,REG_SZ,addr tmpbuff,eax
				invoke SendMessage,ha.hBrowse,FBM_GETPATH,0,addr da.szInitFolder
				invoke strcat,addr da.szInitFolder,addr szBackSlash
				invoke RegSetValueEx,ha.hReg,addr szFolder,0,REG_SZ,addr da.szInitFolder,sizeof da.szInitFolder
				invoke RegSetValueEx,ha.hReg,addr szMainFile,0,REG_SZ,addr da.MainFile,sizeof da.MainFile
				invoke SendMessage,ha.hCbo,CB_GETCURSEL,0,0
				mov		dword ptr tmpbuff,eax
				invoke RegSetValueEx,ha.hReg,addr szBuild,0,REG_DWORD,addr tmpbuff,4
				invoke CloseNotify
				invoke UpdateAll,CLOSE_ALL,0
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
				invoke DestroyWindow,ha.hRes
				invoke RegSetValueEx,ha.hReg,addr szWinPos,0,REG_BINARY,addr wpos,sizeof wpos
				invoke DestroyWindow,ha.hCCLB
				invoke DestroyWindow,ha.hCCTT
				invoke DestroyWindow,hWin
				invoke SaveMRU,offset szMRUFiles,offset mrufiles
				invoke SaveMRU,offset szMRUSessions,offset mrusessions
			.endif
		.endif
	.elseif eax==WM_DESTROY
		invoke PostAddinMessage,hWin,AIM_DESTROY,wParam,lParam,0,HOOK_DESTROY
		mov		nInx,1
		mov		ebx,offset hCustDll
		.while nInx<=32
			mov		eax,[ebx]
			.if eax
				invoke FreeLibrary,eax
			.endif
			add		ebx,4
			inc		nInx
		.endw
		invoke KillTimer,hWin,200
		invoke UpdateAll,WM_DESTROY,0
		invoke DeleteObject,ha.hFont
		invoke DeleteObject,ha.hIFont
		invoke DeleteObject,ha.hLnrFont
		invoke DestroyCursor,ha.hVSplitCur
		invoke DestroyCursor,ha.hHSplitCur
		invoke DestroyIcon,hIcon
		invoke ImageList_Destroy,ha.hMnuIml
		invoke ImageList_Destroy,ha.hImlTbr
		invoke ImageList_Destroy,ha.hImlTbrGray
		invoke DeleteObject,ha.hBrBack
		.if ha.hMnuFont
			invoke DeleteObject,ha.hMenuBrushA
			invoke DeleteObject,ha.hMenuBrushB
			invoke DeleteObject,ha.hMnuFont
		.endif
		invoke ResetEnvironment
		invoke PostQuitMessage,NULL
	.elseif eax==WM_CONTEXTMENU
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
		mov		eax,wParam
		.if eax==ha.hREd
			.if eax==ha.hRes
				invoke GetSubMenu,ha.hContextMnu,4
				invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWin,0
			.else
				.if !fDebugging
					invoke GetSubMenu,ha.hMnu,1
					invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWin,0
				.else
					mov		mii.cbSize,sizeof MENUITEMINFO
					mov		mii.fMask,MIIM_SUBMENU
					invoke GetMenuItemInfo,ha.hMnu,IDM_DEBUG,FALSE,addr mii
					.if eax
						mov		eax,mii.hSubMenu
						invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWin,0
					.endif
				.endif
			.endif
		.elseif eax==ha.hTab
			invoke GetSubMenu,ha.hContextMnu,0
			invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWin,0
		.elseif eax==ha.hOut
			invoke GetSubMenu,ha.hContextMnu,1
			invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWin,0
		.elseif eax==ha.hImmOut
			invoke GetSubMenu,ha.hContextMnu,2
			invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWin,0
		.elseif eax==ha.hProperty
			invoke GetSubMenu,ha.hContextMnu,5
			invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWin,0
		.elseif eax==ha.hTabPbr
			invoke SendMessage,ha.hTabPbr,TCM_GETCURSEL,0,0
			.if eax
				;Project browser
				invoke GetSubMenu,ha.hContextMnu,6
				mov		edi,eax
				push	-1
				invoke SendMessage,ha.hPbr,RPBM_GETITEM,0,0
				.if ![eax].PBITEM.id
					mov		eax,MF_BYCOMMAND or MF_GRAYED
					push	IDM_PROJECT_ADDGROUP
					push	eax
					push	IDM_PROJECT_ADDFILE
					push	eax
					push	IDM_PROJECT_ADDALLFILES
					push	eax
					push	IDM_PROJECT_ADDEXISTINGFILE
					push	eax
					push	IDM_PROJECT_ADDNEWFILE
					push	eax
					push	IDM_PROJECT_EDITGROUP
					push	eax
					push	IDM_PROJECT_EDITFILE
					push	eax
					push	IDM_PROJECT_REMOVEGROUP
					push	eax
					push	IDM_PROJECT_REMOVEFILE
					push	eax
				.else
					push	IDM_PROJECT_ADDGROUP
					push	MF_BYCOMMAND or MF_ENABLED
					invoke SendMessage,ha.hPbr,RPBM_GETSELECTED,0,0
					.if sdword ptr [eax].PBITEM.id<0
						push	IDM_PROJECT_REMOVEFILE
						push	MF_BYCOMMAND or MF_GRAYED
						push	IDM_PROJECT_EDITFILE
						push	MF_BYCOMMAND or MF_GRAYED
					.endif
					.if sdword ptr [eax].PBITEM.id<-1
						mov		eax,MF_BYCOMMAND or MF_ENABLED
					.else
						push	IDM_PROJECT_REMOVEFILE
						push	MF_BYCOMMAND or MF_ENABLED
						push	IDM_PROJECT_EDITFILE
						push	MF_BYCOMMAND or MF_ENABLED
						mov		eax,MF_BYCOMMAND or MF_GRAYED
					.endif
					push	IDM_PROJECT_REMOVEGROUP
					push	eax
					push	IDM_PROJECT_EDITGROUP
					push	eax
					.if ha.hREd
						mov		eax,MF_BYCOMMAND or MF_ENABLED
					.else
						mov		eax,MF_BYCOMMAND or MF_GRAYED
					.endif
					push	IDM_PROJECT_ADDFILE
					push	eax
					push	IDM_PROJECT_ADDALLFILES
					push	eax
					mov		eax,MF_BYCOMMAND or MF_ENABLED
					push	IDM_PROJECT_ADDEXISTINGFILE
					push	eax
					push	IDM_PROJECT_ADDNEWFILE
					push	eax
				.endif
				pop		eax
				.while eax!=-1
					pop		edx
					invoke EnableMenuItem,edi,edx,eax
					pop		eax
				.endw
				invoke TrackPopupMenu,edi,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWin,0
			.else
				;File browser
				invoke GetSubMenu,ha.hContextMnu,3
				invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWin,0
			.endif
		.endif
	.elseif eax==WM_INITMENUPOPUP
		movzx	eax,word ptr lParam
		.if eax==2
			;Format
			invoke SendMessage,ha.hResEd,DEM_ISLOCKED,0,0
			mov		edx,MF_BYCOMMAND
			.if eax
				mov		edx,MF_BYCOMMAND or MF_CHECKED
			.endif
			invoke CheckMenuItem,wParam,IDM_FORMAT_LOCK,edx
			invoke GetWindowLong,ha.hResEd,GWL_STYLE
			push	eax
			test	eax,DES_GRID
			mov		edx,MF_BYCOMMAND
			.if !ZERO?
				mov		edx,MF_BYCOMMAND or MF_CHECKED
			.endif
			invoke CheckMenuItem,wParam,IDM_FORMAT_GRID,edx
			pop		eax
			test	eax,DES_SNAPTOGRID
			mov		edx,MF_BYCOMMAND
			.if !ZERO?
				mov		edx,MF_BYCOMMAND or MF_CHECKED
			.endif
			invoke CheckMenuItem,wParam,IDM_FORMAT_SNAP,edx
		.elseif eax==4
			;View
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
			mov		edx,MF_BYCOMMAND
			test	wpos.fView,8
			.if !ZERO?
				mov		edx,MF_BYCOMMAND or MF_CHECKED
			.endif
			invoke CheckMenuItem,wParam,IDM_VIEW_FILEBROWSER,edx
		.endif
	.elseif eax==WM_USER+998
		invoke OpenEditFile,lParam,0
		invoke DebugCommand,FUNC_FILEOPEN,0,0
	.elseif eax==WM_DROPFILES
		xor		ebx,ebx
	  @@:
		invoke DragQueryFile,wParam,ebx,addr buffer,sizeof buffer
		.if eax
			invoke OpenEditFile,addr buffer,0
			inc		ebx
			jmp		@b
		.endif
	.elseif eax==WM_ACTIVATE
		mov		fTimer,2
	.elseif eax==WM_CTLCOLORLISTBOX || eax==WM_CTLCOLOREDIT
		invoke SetBkColor,wParam,col.toolback
		invoke SetTextColor,wParam,col.tooltext
		mov		eax,ha.hBrBack
		jmp		ExRet
	.elseif eax==WM_MEASUREITEM
		mov		ebx,lParam
		.if [ebx].MEASUREITEMSTRUCT.CtlType==ODT_MENU
			mov		edx,[ebx].MEASUREITEMSTRUCT.itemData
			.if edx
				push	esi
				mov		esi,edx
				.if ![esi].MENUDATA.tpe
					lea		esi,[esi+sizeof MENUDATA]
					invoke GetDC,NULL
					push	eax
					invoke CreateCompatibleDC,eax
					mov		mDC,eax
					pop		eax
					invoke ReleaseDC,NULL,eax
					invoke SelectObject,mDC,ha.hMnuFont
					push	eax
					mov		rect.left,0
					mov		rect.top,0
					invoke DrawText,mDC,esi,-1,addr rect,DT_CALCRECT or DT_SINGLELINE
					mov		eax,rect.right
					mov		[ebx].MEASUREITEMSTRUCT.itemWidth,eax
					invoke strlen,esi
					lea		esi,[esi+eax+1]
					invoke DrawText,mDC,esi,-1,addr rect,DT_CALCRECT or DT_SINGLELINE
					pop		eax
					invoke SelectObject,mDC,eax
					invoke DeleteDC,mDC
					mov		eax,rect.right
					add		eax,25
					add		[ebx].MEASUREITEMSTRUCT.itemWidth,eax
					mov		eax,20
					mov		[ebx].MEASUREITEMSTRUCT.itemHeight,eax
				.else
					mov		eax,10
					mov		[ebx].MEASUREITEMSTRUCT.itemHeight,eax
				.endif
				pop		esi
			.endif
			mov		eax,TRUE
			jmp		ExRet
		.endif
	.elseif eax==WM_DRAWITEM
		mov		ebx,lParam
		.if [ebx].DRAWITEMSTRUCT.CtlType==ODT_MENU
			push	esi
			mov		esi,[ebx].DRAWITEMSTRUCT.itemData
			.if esi
				invoke CreateCompatibleDC,[ebx].DRAWITEMSTRUCT.hdc
				mov		mDC,eax
				mov		rect.left,0
				mov		rect.top,0
				mov		eax,[ebx].DRAWITEMSTRUCT.rcItem.right
				sub		eax,[ebx].DRAWITEMSTRUCT.rcItem.left
				mov		rect.right,eax
				mov		eax,[ebx].DRAWITEMSTRUCT.rcItem.bottom
				sub		eax,[ebx].DRAWITEMSTRUCT.rcItem.top
				mov		rect.bottom,eax
				invoke CreateCompatibleBitmap,[ebx].DRAWITEMSTRUCT.hdc,rect.right,rect.bottom
				invoke SelectObject,mDC,eax
				push	eax
				invoke SelectObject,mDC,ha.hMnuFont
				push	eax
				invoke GetStockObject,WHITE_BRUSH
				invoke FillRect,mDC,addr rect,eax
				invoke FillRect,mDC,addr rect,ha.hMenuBrushB
				.if ![esi].MENUDATA.tpe
					invoke SetBkMode,mDC,TRANSPARENT
					test	[ebx].DRAWITEMSTRUCT.itemState,ODS_SELECTED
					.if !ZERO?
						invoke CreateSolidBrush,0F5BE9Fh
						mov		hBr,eax
						invoke FillRect,mDC,addr rect,hBr
						invoke DeleteObject,hBr
						invoke CreateSolidBrush,800000h
						mov		hBr,eax
						invoke FrameRect,mDC,addr rect,hBr
						invoke DeleteObject,hBr
					.endif
					test	[ebx].DRAWITEMSTRUCT.itemState,ODS_CHECKED
					.if !ZERO?
						; Check mark
						mov		edx,rect.bottom
						sub		edx,16
						shr		edx,1
						invoke ImageList_Draw,ha.hImlTbr,27,mDC,2,edx,ILD_TRANSPARENT
					.else
						; Image
						mov		eax,[esi].MENUDATA.img
						.if eax
							mov		edx,rect.bottom
							sub		edx,16
							shr		edx,1
							dec		eax
							test	[ebx].DRAWITEMSTRUCT.itemState,ODS_GRAYED
							.if ZERO?
								invoke ImageList_Draw,ha.hImlTbr,eax,mDC,2,edx,ILD_TRANSPARENT
							.else
								invoke ImageList_Draw,ha.hImlTbrGray,eax,mDC,2,edx,ILD_TRANSPARENT
							.endif
						.endif
					.endif
					; Text
					test	[ebx].DRAWITEMSTRUCT.itemState,ODS_GRAYED
					.if ZERO?
						invoke GetSysColor,COLOR_MENUTEXT
					.else
						invoke GetSysColor,COLOR_GRAYTEXT
					.endif
					invoke SetTextColor,mDC,eax
					lea		esi,[esi+sizeof MENUDATA]
					invoke strlen,esi
					push	eax
					add		rect.left,22
					add		rect.top,2
					sub		rect.right,2
					invoke DrawText,mDC,esi,-1,addr rect,DT_LEFT or DT_VCENTER
					pop		eax
					lea		esi,[esi+eax+1]
					; Accelerator
					invoke DrawText,mDC,esi,-1,addr rect,DT_RIGHT or DT_VCENTER
					sub		rect.left,22
					sub		rect.top,2
					add		rect.right,2
				.else
					invoke CreatePen,PS_SOLID,1,0F5BE9Fh
					invoke SelectObject,mDC,eax
					push	eax
					add		rect.left,21
					add		rect.top,5
					invoke MoveToEx,mDC,rect.left,rect.top,NULL
					invoke LineTo,mDC,rect.right,rect.top
					sub		rect.left,21
					sub		rect.top,5
					pop		eax
					invoke SelectObject,mDC,eax
					invoke DeleteObject,eax
				.endif
				mov		eax,[ebx].DRAWITEMSTRUCT.rcItem.right
				sub		eax,[ebx].DRAWITEMSTRUCT.rcItem.left
				mov		edx,[ebx].DRAWITEMSTRUCT.rcItem.bottom
				sub		edx,[ebx].DRAWITEMSTRUCT.rcItem.top
				invoke BitBlt,[ebx].DRAWITEMSTRUCT.hdc,[ebx].DRAWITEMSTRUCT.rcItem.left,[ebx].DRAWITEMSTRUCT.rcItem.top,eax,edx,mDC,0,0,SRCCOPY
				pop		eax
				invoke SelectObject,mDC,eax
				pop		eax
				invoke SelectObject,mDC,eax
				invoke DeleteObject,eax
				invoke DeleteDC,mDC
			.endif
			pop		esi
			mov		eax,TRUE
			jmp		ExRet
		.endif
	.elseif eax==AIM_GETHANDLES
		mov		eax,offset ha
		jmp		ExRet
	.elseif eax==AIM_GETPROCS
		mov		eax,offset pa
		jmp		ExRet
	.elseif eax==AIM_GETDATA
		mov		eax,offset da
		jmp		ExRet
	.elseif eax==AIM_GETMENUID
		mov		edx,wParam
		.if !edx
			inc		edx
		.endif
		mov		eax,MenuIDAddins
		add		MenuIDAddins,edx
		jmp		ExRet
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		jmp		ExRet
	.endif
  Ex:
	xor    eax,eax
  ExRet:
	ret

WndProc endp

end start

