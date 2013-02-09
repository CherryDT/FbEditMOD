.386
.model flat,stdcall
option casemap:none
option proc:private

include windows.inc
include ..\RAResEd.inc
include RAGrid.inc
include RAEdit.inc
include Data.inc
includelib ..\Lib\RAGrid.lib
includelib ..\Lib\RAEdit.lib
include Style.inc
include Misc.asm
include LanguageEdit.asm
include DlgExport.asm
include DlgEdit.asm
include MenuEdit.asm
include VersionEdit.asm
include IncludeEdit.asm
include ResourceEdit.asm
include StringEdit.asm
include AccelEdit.asm
include XPManifestEdit.asm
include RCDataEdit.asm
include UserDataEdit.asm
include ToolbarEdit.asm
include NameEdit.asm
include ToolBox.asm
include StyleMana.asm
include Property.asm
include ParseRC.asm
include Project.asm
include Preview.asm

.code

ToolTipProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	buffer[48]:BYTE

	mov		eax,uMsg
	.if eax==WM_PAINT
		invoke BeginPaint,hWin,addr ps
		invoke FillRect,ps.hdc,addr ps.rcPaint,hBrTlt
		invoke SendMessage,hWin,WM_GETFONT,0,0
		invoke SelectObject,ps.hdc,eax
		push	eax
		invoke SetBkMode,ps.hdc,TRANSPARENT
		invoke SendMessage,hWin,WM_GETTEXT,sizeof buffer,addr buffer
		invoke TextOut,ps.hdc,0,0,addr buffer,eax
		pop		eax
		invoke SelectObject,ps.hdc,eax
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
		ret
	.endif
	invoke CallWindowProc,OldToolTipProc,hWin,uMsg,wParam,lParam
	ret

ToolTipProc endp

ResEdInstall proc public hInst:DWORD,fGlobal:DWORD
	LOCAL	wc:WNDCLASSEX

    push    hInst
    pop     hInstance

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	.if fGlobal
		mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_GLOBALCLASS
	.endif
	mov		wc.lpfnWndProc,offset ResEdProc
	mov		wc.cbClsExtra,0
	;0=hDialog, 4=hMem, 8=ReadOnly
	;12=ScrollX, 16=ScrollY, 20=lpProjectItem
	mov		wc.cbWndExtra,24
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szResEdClass
	mov		wc.hIcon,NULL
	mov		wc.hIconSm,NULL
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	.if fGlobal
		mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_GLOBALCLASS
	.endif
	mov		wc.lpfnWndProc,offset DlgEditProc
	mov		wc.cbClsExtra,0
	;0=hDialog, 4=hMem, 8=ReadOnly
	;12=ScrollX, 16=ScrollY, 20=lpProjectItem
	mov		wc.cbWndExtra,24
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szDlgEditClass
	mov		wc.hIcon,NULL
	mov		wc.hIconSm,NULL
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	mov		wc.lpfnWndProc,offset MakeDlgClassProc
	mov		wc.cbClsExtra,0
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szDlgChildClass
	mov		wc.hIcon,NULL
	mov		wc.hIconSm,NULL
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	.if fGlobal
		mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_GLOBALCLASS
	.endif
	mov		wc.lpfnWndProc,offset ToolBoxProc
	mov		wc.cbClsExtra,0
	mov		wc.cbWndExtra,0
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset	szToolBoxClass
	mov		wc.hIcon,0
	mov		wc.hIconSm,0
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr	wc

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	.if fGlobal
		mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_GLOBALCLASS
	.endif
	mov		wc.lpfnWndProc,offset PropertyProc
	mov		wc.cbClsExtra,0
	mov		wc.cbWndExtra,4
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset	szPropertyClass
	mov		wc.hIcon,0
	mov		wc.hIconSm,0
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr	wc

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	.if fGlobal
		mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_GLOBALCLASS
	.endif
	mov		wc.lpfnWndProc,offset ProjectProc
	mov		wc.cbClsExtra,0
	;0=hMem
	mov		wc.cbWndExtra,4
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset	szProjectClass
	mov		wc.hIcon,0
	mov		wc.hIconSm,0
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr	wc

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_PARENTDC
	mov		wc.lpfnWndProc,offset DesignDummyProc
	mov		wc.cbClsExtra,0
	mov		wc.cbWndExtra,0
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset	szDlgEditDummyClass
	mov		wc.hIcon,0
	mov		wc.hIconSm,0
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr	wc

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_PARENTDC or CS_DBLCLKS
	mov		wc.lpfnWndProc,offset DesignInvisibleProc
	mov		wc.cbClsExtra,0
	mov		wc.cbWndExtra,0
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset	szDlgEditInvisible
	mov		wc.hIcon,0
	mov		wc.hIconSm,0
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr	wc

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	.if fGlobal
		mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS or CS_GLOBALCLASS
	.endif
	mov		wc.lpfnWndProc,offset StyleProc
	mov		eax,NULL
	mov		wc.cbClsExtra,eax
	mov		wc.cbWndExtra,4
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,eax
	mov		wc.lpszMenuName,eax
	mov		wc.lpszClassName,offset szClassName
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc

	invoke CreateSolidBrush,0E0FFFFh
	mov		hBrTlt,eax
	;invoke CreateGridBrush
	invoke ResEdDo_ImageList,hInstance,IDB_MNUARROW,16,4,0,0C0C0C0h,0
	mov		hMnuIml,eax
	invoke ResEdDo_ImageList,hInstance,IDB_PROTRV,16,7,0,0FFFFFFh,0
	mov		hPrjIml,eax
	mov		color.back,0FFFFFFh
	mov		color.text,0
	invoke ImageList_Create,9,9,ILC_COLOR4 or ILC_MASK,2,2
	mov		hIml,eax
	invoke LoadBitmap,hInst,IDB_BOOKMARK
	push	eax
	invoke ImageList_AddMasked,hIml,eax,0C0C0C0h
	pop		eax
	invoke DeleteObject,eax
	invoke GetSysColor,COLOR_BTNFACE
	invoke CreateSolidBrush,eax
	mov		hBr,eax
	invoke LoadCursor,hInstance,IDC_HSPLIT
	mov		hHSplit,eax
	invoke LoadCursor,hInstance,IDC_VSPLIT
	mov		hVSplit,eax
	ret

ResEdInstall endp

ResEdUninstall proc public

	invoke DestroyWindow,hToolTip
	invoke DeleteObject,hBrTlt
	invoke DeleteObject,hGridBr
	invoke ImageList_Destroy,hMnuIml
	invoke ImageList_Destroy,hPrjIml
	invoke ImageList_Destroy,hIml
	.if hBrBack
		invoke DeleteObject,hBrBack
	.endif
	.if hBr
		invoke DeleteObject,hBr
	.endif
	invoke DestroyCursor,hHSplit
	invoke DestroyCursor,hVSplit
	ret

ResEdUninstall endp

SetColors proc uses ebx
	LOCAL	racol:RACOLOR

	.if hBrBack
		invoke DeleteObject,hBrBack
	.endif
	invoke CreateSolidBrush,color.back
	mov		hBrBack,eax
	invoke SendMessage,hPrjTrv,TVM_SETBKCOLOR,0,color.back
	invoke SendMessage,hPrjTrv,TVM_SETTEXTCOLOR,0,color.text
	invoke InvalidateRect,hDEd,NULL,TRUE
	invoke InvalidateRect,hPrpCboDlg,NULL,TRUE
	invoke InvalidateRect,hPrpLstDlg,NULL,TRUE
	invoke InvalidateRect,hPrpEdtDlgCld,NULL,TRUE
	invoke InvalidateRect,hPrpLstDlgCld,NULL,TRUE
	invoke SendMessage,hOut,REM_GETCOLOR,0,addr racol
	mov		eax,color.back
	mov		racol.bckcol,eax
	mov		racol.cmntback,eax
	mov		racol.strback,eax
	mov		racol.oprback,eax
	mov		racol.numback,eax
	mov		eax,color.text
	mov		racol.txtcol,eax
	mov		racol.strcol,0
	invoke SendMessage,hOut,REM_SETCOLOR,0,addr racol
	.if hDlgRed
		invoke SendMessage,hDlgRed,REM_SETCOLOR,0,addr racol
	.endif
		invoke GetWindowLong,hPrj,0
		.if eax
			mov		ebx,eax
			.while [ebx].PROJECT.hmem
				.if [ebx].PROJECT.ntype==TPE_DIALOG
					mov		ebx,[ebx].PROJECT.hmem
					.if [ebx].DLGHEAD.hred
						invoke SendMessage,[ebx].DLGHEAD.hred,REM_SETCOLOR,0,addr racol
					.endif
				.endif
				add		ebx,sizeof PROJECT
			.endw
		.endif
	ret

SetColors endp

ToolBoxProc	proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT

	mov		eax,uMsg
	.if eax==WM_CREATE
		push	hWin
		pop		hTlb
		invoke strcpy,addr szToolBoxTlt,addr szDefToolBoxTlt
		invoke Do_ToolBox,hWin
	.elseif eax==WM_MOUSEMOVE
		.if hStatus
			invoke SendMessage,hStatus,SB_SETTEXT,nStatus,offset szNULL
		.endif
	.elseif	eax==WM_SIZE
		mov		eax,lParam
		movzx	edx,ax
		shr		eax,16
		mov		pt.x,edx
		mov		pt.y,eax
		invoke ToolBoxSize,pt.x
	.elseif eax==WM_DESTROY
		mov		esi,offset hButtons+NoOfButtons*4
		xor		ebx,ebx
		.while ebx<32
			.if dword ptr [esi]
				invoke SendMessage,[esi],BM_SETIMAGE,IMAGE_BITMAP,0
				mov		dword ptr [esi],0
			.endif
			lea		esi,[esi+4]
			inc		ebx
		.endw
		invoke RtlZeroMemory,addr PrCust,sizeof PrCust
		invoke RtlZeroMemory,addr custtypes,sizeof custtypes
		invoke RtlZeroMemory,addr rscuststyledef,sizeof rscuststyledef
		invoke RtlZeroMemory,addr custrstypes,sizeof custrstypes
		mov		eax,NoOfButtons
		mov		nButtons,eax
		mov		nPr,INIT_NPR
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ToolBoxProc	endp

ProjectProc	proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT

	mov		eax,uMsg
	.if eax==WM_CREATE
		push	hWin
		pop		hPrj
		invoke Do_Project,hWin
	.elseif eax==WM_DESTROY
		invoke SendMessage,hWin,PRO_CLOSE,0,0
	.elseif eax==WM_MOUSEMOVE
		.if hStatus
			invoke SendMessage,hStatus,SB_SETTEXT,nStatus,offset szNULL
		.endif
	.elseif	eax==WM_SIZE
		mov		eax,lParam
		movzx	edx,ax
		shr		eax,16
		mov		pt.x,edx
		mov		pt.y,eax
		invoke ProjectSize,pt.x,pt.y
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ProjectProc	endp

DlgEditProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	sinf:SCROLLINFO
	LOCAL	rect:RECT
	LOCAL	ps:PAINTSTRUCT

	mov		eax,uMsg
	.if eax==WM_CREATE
		push	hWin
		pop		hDEd
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		edx,eax
		and		eax,1
		mov		fGrid,eax
		shr		edx,1
		mov		eax,edx
		and		eax,1
		mov		fSnapToGrid,eax
		shr		edx,1
		mov		eax,edx
		and		eax,1
		mov		fShowSizePos,eax
		shr		edx,1
		mov		eax,edx
		and		eax,1
		mov		fStyleHex,eax
		shr		edx,1
		mov		eax,edx
		and		eax,1
		mov		fSizeToFont,eax
		shr		edx,1
		mov		eax,edx
		and		eax,1
		mov		fNoDefines,eax
		shr		edx,1
		mov		eax,edx
		and		eax,1
		mov		fSimpleProperty,eax
		shr		edx,1
		mov		eax,edx
		and		eax,1
		mov		fNoResetToolbox,eax
		;Fake tooltip
		invoke CreateWindowEx,0,addr szStaticClass,0,WS_POPUP or WS_BORDER or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or SS_OWNERDRAW,0,0,0,0,hWin,0,hInstance,0
		mov		hTlt,eax
		invoke SetWindowLong,hTlt,GWL_WNDPROC,addr ToolTipProc
		mov		OldToolTipProc,eax
		;invoke CreateWindowEx,WS_EX_TRANSPARENT,addr szDlgEditInvisible,0,WS_CHILD,0,0,32767,32767,hWin,0,hInstance,0
		invoke CreateWindowEx,WS_EX_TRANSPARENT,addr szDlgEditInvisible,0,WS_CHILD,0,0,16383,16383,hWin,0,hInstance,0
		mov		hInvisible,eax
	.elseif eax==WM_MOUSEMOVE
		.if hStatus
			invoke SendMessage,hStatus,SB_SETTEXT,nStatus,offset szNULL
		.endif
	.elseif eax==WM_PAINT
		invoke BeginPaint,hWin,addr ps
		invoke FillRect,ps.hdc,addr ps.rcPaint,hBrBack
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
		ret
	.elseif eax==WM_USER+9999
		mov		fEditMode,TRUE
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_STYLECHANGED
		.if wParam==GWL_STYLE
			mov		edx,lParam
			mov		eax,[edx].STYLESTRUCT.styleNew
			mov		edx,eax
			and		eax,1
			mov		fGrid,eax
			shr		edx,1
			mov		eax,edx
			and		eax,1
			mov		fSnapToGrid,eax
			shr		edx,1
			mov		eax,edx
			and		eax,1
			mov		fShowSizePos,eax
			shr		edx,1
			mov		eax,edx
			and		eax,1
			mov		fStyleHex,eax
			shr		edx,1
			mov		eax,edx
			and		eax,1
			mov		fSizeToFont,eax
			shr		edx,1
			mov		eax,edx
			and		eax,1
			mov		fNoDefines,eax
			shr		edx,1
			mov		eax,edx
			and		eax,1
			mov		fSimpleProperty,eax
			shr		edx,1
			mov		eax,edx
			and		eax,1
			mov		fNoResetToolbox,eax
			invoke GetWindowLong,hWin,DEWM_DIALOG
			.if eax
				invoke InvalidateRect,eax,NULL,TRUE
				.if hReSize
					invoke SizeingRect,hReSize,FALSE
				.endif
			.endif
		.endif
	.elseif eax==WM_DESTROY
		invoke GetWindowLong,hWin,DEWM_MEMORY
		.if eax
			push	esi
			mov		esi,eax
			.if !fEditMode
				invoke DestroySizeingRect
				mov		eax,[esi+sizeof DLGHEAD].DIALOG.hwnd
				.if eax
					invoke DestroyWindow,eax
				.endif
			.endif
			invoke SetWindowLong,hWin,DEWM_MEMORY,0
			invoke SetWindowLong,hWin,DEWM_DIALOG,0
			;Freed by project
			;invoke GlobalUnlock,esi
			;invoke GlobalFree,esi
			pop		esi
		.endif
	.elseif eax==WM_KEYDOWN
		.if hReSize || hMultiSel
			invoke GetKeyState,VK_CONTROL
			and		eax,80h
			push	eax
			invoke GetKeyState,VK_SHIFT
			and		eax,80h
			mov		edx,eax
			pop		eax
			.if !eax && !edx
				.if wParam==VK_DELETE
					invoke DeleteCtl
				.elseif wParam==VK_PGDN
					.if hReSize
						invoke GetCtrlMem,hReSize
						.if eax
							mov		edx,[eax].DIALOG.tab
							inc		edx
							invoke SetNewTab,hReSize,edx
							invoke PropertyList,hReSize
						.endif
					.endif
				.elseif wParam==VK_PGUP
					.if hReSize
						invoke GetCtrlMem,hReSize
						.if eax
							mov		edx,[eax].DIALOG.tab
							.if edx
								dec		edx
								invoke SetNewTab,hReSize,edx
								invoke PropertyList,hReSize
							.endif
						.endif
					.endif
				.endif
			.elseif !edx && eax
				.if wParam==VK_V
					invoke PasteCtl
				.elseif wParam==VK_C
					invoke CopyCtl
					invoke NotifyParent
				.elseif wParam==VK_X
					invoke CopyCtl
					invoke DeleteCtl
				.endif
			.endif
		.endif
		.if hReSize
			.if !eax && !edx
				; Select control
				.if wParam==VK_TAB || wParam==VK_RIGHT || wParam==VK_DOWN
					invoke GetCtrlMem,hReSize
					.if eax
						push	esi
						mov		esi,eax
						mov		eax,(DIALOG ptr [esi]).ntype
						.if eax
							mov		eax,(DIALOG ptr [esi]).tab
							inc		eax
						.endif
						push	eax
						invoke GetWindowLong,hWin,DEWM_MEMORY
						pop		edx
						invoke FindTab,edx,eax
						.if !eax
							invoke GetWindowLong,hWin,DEWM_MEMORY
							invoke FindTab,0,eax
						.endif
						.if eax
							push	eax
							invoke DestroySizeingRect
							pop		eax
							invoke SizeingRect,eax,FALSE
						.endif
						pop		esi
					.endif
				.elseif wParam==VK_LEFT || wParam==VK_UP
				  SelPrev:
					invoke GetCtrlMem,hReSize
					.if eax
						push	esi
						mov		esi,eax
						mov		eax,(DIALOG ptr [esi]).tab
						dec		eax
						push	eax
						invoke GetWindowLong,hWin,DEWM_MEMORY
						pop		edx
						invoke FindTab,edx,eax
						.if !eax
							invoke GetFreeTab
							.if eax
								dec		eax
								push	eax
								invoke GetWindowLong,hWin,DEWM_MEMORY
								pop		edx
								invoke FindTab,edx,eax
							.endif
						.endif
						.if eax
							push	eax
							invoke DestroySizeingRect
							pop		eax
							invoke SizeingRect,eax,FALSE
						.endif
						pop		esi
					.endif
				.elseif wParam==VK_RETURN
					invoke SetFocus,hPrpLstDlg
					invoke SendMessage,hPrpLstDlg,WM_CHAR,VK_RETURN,0
				.endif
			.elseif !edx && eax
				; Move control
				invoke GetCtrlMem,hReSize
				.if eax
					push	esi
					mov		esi,eax
					mov		eax,wParam
					.if eax==VK_LEFT
						call RSnapToGrid
						.if fRSnapToGrid
							mov		eax,(DIALOG ptr [esi]).dux
							sub		eax,Gridcx
							xor		edx,edx
							idiv	Gridcx
							imul	Gridcx
							mov		(DIALOG ptr [esi]).dux,eax
						.else
							dec		(DIALOG ptr [esi]).dux
						.endif
						invoke GetCtrlID,esi
						push	eax
						invoke GetWindowLong,hDEd,DEWM_MEMORY
						pop		edx
						invoke MakeDialog,eax,edx
						invoke SetChanged,TRUE
					.elseif eax==VK_RIGHT
						call RSnapToGrid
						.if fRSnapToGrid
							mov		eax,(DIALOG ptr [esi]).dux
							add		eax,Gridcx
							xor		edx,edx
							idiv	Gridcx
							imul	Gridcx
							mov		(DIALOG ptr [esi]).dux,eax
						.else
							inc		(DIALOG ptr [esi]).dux
						.endif
						invoke GetCtrlID,esi
						push	eax
						invoke GetWindowLong,hDEd,DEWM_MEMORY
						pop		edx
						invoke MakeDialog,eax,edx
						invoke SetChanged,TRUE
					.elseif eax==VK_UP
						call RSnapToGrid
						.if fRSnapToGrid
							mov		eax,(DIALOG ptr [esi]).duy
							sub		eax,Gridcy
							xor		edx,edx
							idiv	Gridcy
							imul	Gridcy
							mov		(DIALOG ptr [esi]).duy,eax
						.else
							dec		(DIALOG ptr [esi]).duy
						.endif
						invoke GetCtrlID,esi
						push	eax
						invoke GetWindowLong,hDEd,DEWM_MEMORY
						pop		edx
						invoke MakeDialog,eax,edx
						invoke SetChanged,TRUE
					.elseif eax==VK_DOWN
						call RSnapToGrid
						.if fRSnapToGrid
							mov		eax,(DIALOG ptr [esi]).duy
							add		eax,Gridcy
							xor		edx,edx
							idiv	Gridcy
							imul	Gridcy
							mov		(DIALOG ptr [esi]).duy,eax
						.else
							inc		(DIALOG ptr [esi]).duy
						.endif
						invoke GetCtrlID,esi
						push	eax
						invoke GetWindowLong,hDEd,DEWM_MEMORY
						pop		edx
						invoke MakeDialog,eax,edx
						invoke SetChanged,TRUE
					.endif
					pop		esi
				.endif
			.elseif edx && !eax
				; Size control
				mov		eax,wParam
				.if eax==VK_TAB
					jmp		SelPrev
				.endif
				invoke GetCtrlMem,hReSize
				.if eax
					push	esi
					mov		esi,eax
					mov		eax,wParam
					.if eax==VK_LEFT
						mov		eax,(DIALOG ptr [esi]).duccx
						.if eax>1
							dec		(DIALOG ptr [esi]).duccx
							invoke GetCtrlID,esi
							push	eax
							invoke GetWindowLong,hDEd,DEWM_MEMORY
							pop		edx
							invoke MakeDialog,eax,edx
							invoke SetChanged,TRUE
						.endif
					.elseif eax==VK_RIGHT
						inc		(DIALOG ptr [esi]).duccx
						invoke GetCtrlID,esi
						push	eax
						invoke GetWindowLong,hDEd,DEWM_MEMORY
						pop		edx
						invoke MakeDialog,eax,edx
						invoke SetChanged,TRUE
					.elseif eax==VK_UP
						mov		eax,(DIALOG ptr [esi]).duccy
						.if eax>1
							dec		(DIALOG ptr [esi]).duccy
							invoke GetCtrlID,esi
							push	eax
							invoke GetWindowLong,hDEd,DEWM_MEMORY
							pop		edx
							invoke MakeDialog,eax,edx
							invoke SetChanged,TRUE
						.endif
					.elseif eax==VK_DOWN
						inc		(DIALOG ptr [esi]).duccy
						invoke GetCtrlID,esi
						push	eax
						invoke GetWindowLong,hDEd,DEWM_MEMORY
						pop		edx
						invoke MakeDialog,eax,edx
						invoke SetChanged,TRUE
					.endif
					pop		esi
				.endif
			.elseif eax && edx
				mov		eax,wParam
				.if eax==VK_UP || eax==VK_DOWN
					invoke SendMessage,hPrpLstDlg,LB_GETCURSEL,0,0
					.if eax==LB_ERR
						invoke SendMessage,hPrpLstDlg,LB_SETCURSEL,0,0
					.else
						.if wParam==VK_DOWN
							inc		eax
						.else
							.if eax
								dec		eax
							.endif
						.endif
						invoke SendMessage,hPrpLstDlg,LB_SETCURSEL,eax,0
					.endif
					invoke PropListSetPos
					.if !eax
						invoke PropListSetTxt,hPrpLstDlg
					.endif
				.elseif eax==VK_LEFT || eax==VK_RIGHT
					invoke IsWindowVisible,hPrpEdtDlgCld
					.if eax
						invoke SetFocus,hPrpEdtDlgCld
					.else
						invoke IsWindowVisible,hPrpBtnDlgCld
						.if eax
							invoke SendMessage,hPrpLstDlg,WM_COMMAND,1,0
							invoke IsWindowVisible,hPrpLstDlgCld
							.if eax
								invoke SetFocus,hPrpLstDlgCld
							.endif
						.endif
					.endif
				.endif
			.endif
		.elseif hMultiSel
			mov		ecx,wParam
			.if eax && !edx
				call RSnapToGrid
				.if fRSnapToGrid
					mov		eax,Gridcx
					mov		edx,Gridcy
				.else
					mov		eax,1
					mov		edx,1
				.endif
				.if ecx==VK_UP
					neg		edx
					xor		eax,eax
				.elseif ecx==VK_DOWN
					xor		eax,eax
				.elseif ecx==VK_LEFT
					neg		eax
					xor		edx,edx
				.elseif ecx==VK_RIGHT
					xor		edx,edx
				.else
					jmp		ExDef
				.endif
				invoke MoveMultiSel,eax,edx
			.elseif !eax && edx
				mov		eax,1
				mov		edx,1
				.if ecx==VK_UP
					neg		edx
					xor		eax,eax
				.elseif ecx==VK_DOWN
					xor		eax,eax
				.elseif ecx==VK_LEFT
					neg		eax
					xor		edx,edx
				.elseif ecx==VK_RIGHT
					xor		edx,edx
				.else
					jmp		ExDef
				.endif
				invoke SizeMultiSel,eax,edx
			.endif
		.endif
	.elseif eax==WM_MOUSEWHEEL
		push	ebx
		mov		eax,wParam
		mov		ebx,WM_VSCROLL
		test	eax,MK_CONTROL
		.if !ZERO?
			mov		ebx,WM_HSCROLL
		.endif
		shr		eax,16
		cwde
		.if sdword ptr eax<0
			invoke PostMessage,hWin,ebx,SB_LINEDOWN,0
			invoke PostMessage,hWin,ebx,SB_LINEDOWN,0
			invoke PostMessage,hWin,ebx,SB_LINEDOWN,0
		.else
			invoke PostMessage,hWin,ebx,SB_LINEUP,0
			invoke PostMessage,hWin,ebx,SB_LINEUP,0
			invoke PostMessage,hWin,ebx,SB_LINEUP,0
		.endif
		pop		ebx
		xor		eax,eax
	.elseif eax==WM_HSCROLL
		.if fEditMode || fNoScroll
			xor		eax,eax
			ret
		.endif
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==SB_THUMBTRACK || eax==SB_THUMBPOSITION
			mov		sinf.cbSize,sizeof sinf
			mov		sinf.fMask,SIF_POS
			mov		eax,wParam
			shr		eax,16
			mov		sinf.nPos,eax
			invoke SetScrollInfo,hWin,SB_HORZ,addr sinf,TRUE
			invoke GetWindowLong,hWin,DEWM_SCROLLX
			sub		eax,sinf.nPos
			shl		eax,3
			invoke ScrollWindow,hWin,eax,0,NULL,NULL
			invoke SetWindowLong,hWin,DEWM_SCROLLX,sinf.nPos
		.elseif eax==SB_LINELEFT || eax==SB_LINERIGHT || eax==SB_PAGELEFT || eax==SB_PAGERIGHT
			mov		sinf.cbSize,sizeof sinf
			mov		sinf.fMask,SIF_POS
			invoke GetScrollInfo,hWin,SB_HORZ,addr sinf
			mov		ecx,sinf.nPos
			mov		eax,wParam
			.if eax==SB_LINERIGHT
				inc		ecx
			.elseif eax==SB_LINELEFT
				.if ecx
					dec		ecx
				.endif
			.elseif eax==SB_PAGERIGHT
				add		ecx,8
			.elseif eax==SB_PAGELEFT
				.if ecx>8
					sub		ecx,8
				.else
					mov		ecx,0
				.endif
			.endif
			shl		ecx,16
			or		ecx,SB_THUMBPOSITION
			invoke SendMessage,hWin,WM_HSCROLL,ecx,0
		.endif
		xor eax,eax
		ret
	.elseif eax==WM_VSCROLL
		.if fEditMode || fNoScroll
			xor		eax,eax
			ret
		.endif
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==SB_THUMBTRACK || eax==SB_THUMBPOSITION
			mov		sinf.cbSize,sizeof sinf
			mov		sinf.fMask,SIF_POS
			mov		eax,wParam
			shr		eax,16
			mov		sinf.nPos,eax
			invoke SetScrollInfo,hWin,SB_VERT,addr sinf,TRUE
			invoke GetWindowLong,hWin,DEWM_SCROLLY
			sub		eax,sinf.nPos
			shl		eax,3
			invoke ScrollWindow,hWin,0,eax,NULL,NULL
			invoke SetWindowLong,hWin,DEWM_SCROLLY,sinf.nPos
		.elseif eax==SB_LINEDOWN || eax==SB_LINEUP || eax==SB_PAGEDOWN || eax==SB_PAGEUP
			mov		sinf.cbSize,sizeof sinf
			mov		sinf.fMask,SIF_POS
			invoke GetScrollInfo,hWin,SB_VERT,addr sinf
			mov		ecx,sinf.nPos
			mov		eax,wParam
			.if eax==SB_LINEDOWN
				inc		ecx
			.elseif eax==SB_LINEUP
				.if ecx
					dec		ecx
				.endif
			.elseif eax==SB_PAGEDOWN
				add		ecx,8
			.elseif eax==SB_PAGEUP
				.if ecx>8
					sub		ecx,8
				.else
					mov		ecx,0
				.endif
			.endif
			shl		ecx,16
			or		ecx,SB_THUMBPOSITION
			invoke SendMessage,hWin,WM_VSCROLL,ecx,0
		.endif
		xor eax,eax
		ret
	.endif
  ExDef:
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

DlgEditProc endp

PropertyProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT

	mov		eax,uMsg
	.if eax==WM_CREATE
		push	hWin
		pop		hPrp
		invoke Do_Property,hWin
	.elseif eax==WM_DESTROY
		invoke DestroyWindow,hPrpBtnDlgCld
		invoke DestroyWindow,hPrpCboDlg
		invoke DestroyWindow,hPrpEdtDlgCld
		invoke DestroyWindow,hPrpLstDlgCld
		invoke DestroyWindow,hPrpLstDlg
	.elseif eax==WM_SIZE
		mov		eax,lParam
		movzx	edx,ax
		shr		eax,16
		mov		pt.x,edx
		mov		pt.y,eax
		invoke MoveWindow,hPrpCboDlg,0,0,pt.x,150,TRUE
		mov		edx,pt.y
		sub		edx,25
		invoke MoveWindow,hPrpLstDlg,0,25,pt.x,edx,TRUE
	.elseif eax==WM_MOUSEMOVE
		.if hStatus
			invoke SendMessage,hStatus,SB_SETTEXT,nStatus,offset szNULL
		.endif
	.elseif eax==WM_SETFONT
		invoke SendMessage,hTlt,WM_SETFONT,wParam,lParam
		invoke SendMessage,hPrpCboDlg,WM_SETFONT,wParam,lParam
		invoke SendMessage,hPrpLstDlg,WM_SETFONT,wParam,lParam
		invoke SendMessage,hPrpEdtDlgCld,WM_SETFONT,wParam,lParam
		invoke SendMessage,hPrpEdtDlgCldMulti,WM_SETFONT,wParam,lParam
		invoke SendMessage,hPrpLstDlgCld,WM_SETFONT,wParam,lParam
		invoke GetDC,hWin
		push	ebx
		mov		ebx,eax
		invoke SelectObject,ebx,wParam
		push	eax
		invoke GetTextExtentPoint32,ebx,addr szMaxWt,11,addr pt
		mov		eax,pt.x
		mov		nPropWt,eax
		mov		eax,pt.y
		add		eax,3
		mov		nPropHt,eax
		inc		eax
		invoke SendMessage,hPrpLstDlg,LB_SETITEMHEIGHT,0,eax
		pop		eax
		invoke SelectObject,ebx,eax
		invoke ReleaseDC,hWin,ebx
		pop		ebx
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		shr		edx,16
		.if edx==LBN_SELCHANGE
			invoke SendMessage,lParam,LB_GETCURSEL,0,0
			.if eax!=LB_ERR
				mov		edx,eax
				mov		eax,lParam
				.if eax==hPrpLstDlg
					invoke PropListSetPos
				.endif
			.endif
		.endif
	.elseif eax==WM_DRAWITEM
		push	esi
		mov		esi,lParam
		mov		eax,[esi].DRAWITEMSTRUCT.hwndItem
		.if eax==hPrpLstDlg
			.if [esi].DRAWITEMSTRUCT.itemID!=LB_ERR
				test	[esi].DRAWITEMSTRUCT.itemState,ODS_SELECTED
				.if ZERO?
					invoke SetTextColor,[esi].DRAWITEMSTRUCT.hdc,color.text
					invoke SetBkColor,[esi].DRAWITEMSTRUCT.hdc,color.back
				.else
					invoke GetSysColor,COLOR_HIGHLIGHTTEXT
					invoke SetTextColor,[esi].DRAWITEMSTRUCT.hdc,eax
					invoke GetSysColor,COLOR_HIGHLIGHT
					invoke SetBkColor,[esi].DRAWITEMSTRUCT.hdc,eax
				.endif
				push	[esi].DRAWITEMSTRUCT.rcItem.right
				mov		eax,[esi].DRAWITEMSTRUCT.hwndItem
				mov		eax,nPropWt
				mov		[esi].DRAWITEMSTRUCT.rcItem.right,eax
				invoke ExtTextOut,[esi].DRAWITEMSTRUCT.hdc,0,0,ETO_OPAQUE,addr [esi].DRAWITEMSTRUCT.rcItem,NULL,0,NULL
				pop		[esi].DRAWITEMSTRUCT.rcItem.right
				invoke SendMessage,[esi].DRAWITEMSTRUCT.hwndItem,LB_GETTEXT,[esi].DRAWITEMSTRUCT.itemID,addr tempbuff
				mov		eax,offset tempbuff
				.while byte ptr [eax] && byte ptr [eax]!=VK_TAB
					inc		eax
				.endw
				sub		eax,offset tempbuff
				invoke TextOut,[esi].DRAWITEMSTRUCT.hdc,2,[esi].DRAWITEMSTRUCT.rcItem.top,addr tempbuff,eax
				mov		eax,[esi].DRAWITEMSTRUCT.hwndItem
				invoke SetTextColor,[esi].DRAWITEMSTRUCT.hdc,color.text
				invoke SetBkColor,[esi].DRAWITEMSTRUCT.hdc,color.back
				mov		edx,offset tempbuff
				.while byte ptr [edx] && byte ptr [edx]!=VK_TAB
					inc		edx
				.endw
				inc		edx
				mov		eax,edx
				.while byte ptr [eax] && byte ptr [eax]!=VK_TAB
					inc		eax
				.endw
				sub		eax,edx
				mov		ecx,nPropWt
				add		ecx,2
				invoke TextOut,[esi].DRAWITEMSTRUCT.hdc,ecx,[esi].DRAWITEMSTRUCT.rcItem.top,edx,eax
				invoke CreatePen,PS_SOLID,0,0C0C0C0h
				invoke SelectObject,[esi].DRAWITEMSTRUCT.hdc,eax
				push	eax
				mov		edx,[esi].DRAWITEMSTRUCT.rcItem.bottom
				dec		edx
				invoke MoveToEx,[esi].DRAWITEMSTRUCT.hdc,[esi].DRAWITEMSTRUCT.rcItem.left,edx,NULL
				mov		edx,[esi].DRAWITEMSTRUCT.rcItem.bottom
				dec		edx
				invoke LineTo,[esi].DRAWITEMSTRUCT.hdc,[esi].DRAWITEMSTRUCT.rcItem.right,edx
				mov		eax,[esi].DRAWITEMSTRUCT.hwndItem
				mov		edx,[esi].DRAWITEMSTRUCT.rcItem.left
				add		edx,nPropWt
				invoke MoveToEx,[esi].DRAWITEMSTRUCT.hdc,edx,[esi].DRAWITEMSTRUCT.rcItem.top,NULL
				mov		edx,[esi].DRAWITEMSTRUCT.rcItem.left
				add		edx,nPropWt
				invoke LineTo,[esi].DRAWITEMSTRUCT.hdc,edx,[esi].DRAWITEMSTRUCT.rcItem.bottom
				pop		eax
				invoke SelectObject,[esi].DRAWITEMSTRUCT.hdc,eax
				invoke DeleteObject,eax
			.endif
		.endif
		pop		esi
		xor		eax,eax
		ret
	.elseif eax==WM_CTLCOLORLISTBOX
		invoke SetBkColor,wParam,color.back
		invoke SetTextColor,wParam,color.text
		mov		eax,hBrBack
		jmp		Ex
	.elseif eax==WM_CTLCOLOREDIT
		invoke SetBkColor,wParam,color.back
		invoke SetTextColor,wParam,color.text
		mov		eax,hBrBack
		jmp		Ex
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

PropertyProc endp

SetHilite proc uses ebx esi,nColorStyles:DWORD,nColorWords:DWORD

	mov		ebx,offset szPRELOAD
	mov		esi,nColorWords
	or		esi,21000000h
	.while byte ptr [ebx]
		invoke SendMessage,hOut,REM_SETHILITEWORDS,esi,ebx
		invoke strlen,ebx
		lea		ebx,[ebx+eax+1]
	.endw
	mov		ebx,offset szManifestInfo
	.while byte ptr [ebx]
		invoke SendMessage,hOut,REM_SETHILITEWORDS,esi,ebx
		invoke strlen,ebx
		lea		ebx,[ebx+eax+1]
	.endw
	mov		ebx,offset szBITMAP
	.while byte ptr [ebx]
		invoke SendMessage,hOut,REM_SETHILITEWORDS,esi,ebx
		invoke strlen,ebx
		lea		ebx,[ebx+eax+1]
	.endw
	mov		ebx,offset rsstyledefdlg
	mov		esi,nColorStyles
	or		esi,20000000h
	.while byte ptr [ebx+8]
		invoke SendMessage,hOut,REM_SETHILITEWORDS,esi,addr [ebx+8]
		invoke strlen,addr [ebx+8]
		lea		ebx,[ebx+eax+8+1]
	.endw
	mov		ebx,offset rsstyledef
	.while byte ptr [ebx+8]
		invoke SendMessage,hOut,REM_SETHILITEWORDS,esi,addr [ebx+8]
		invoke strlen,addr [ebx+8]
		lea		ebx,[ebx+eax+8+1]
	.endw
	mov		ebx,offset rsexstyledef
	.while byte ptr [ebx+8]
		invoke SendMessage,hOut,REM_SETHILITEWORDS,esi,addr [ebx+8]
		invoke strlen,addr [ebx+8]
		lea		ebx,[ebx+eax+8+1]
	.endw
	ret

SetHilite endp

ResEdProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	hFile:HANDLE
	LOCAL	dwbytes:DWORD
	LOCAL	lf:LOGFONT
	LOCAL	chrg:CHARRANGE
	LOCAL	ncm:NONCLIENTMETRICS

	mov		eax,uMsg
	.if eax==WM_CREATE
		mov		eax,hWin
		mov		hRes,eax
		invoke GetWindowLong,hWin,GWL_STYLE
		and		eax,0FFFFh
		or		eax,WS_CHILD or WS_VISIBLE or WS_VSCROLL or WS_HSCROLL
		invoke CreateWindowEx,200h,addr szDlgEditClass,0,eax,0,0,0,0,hWin,0,hInstance,0
		mov		hDEd,eax
		invoke CreateWindowEx,200h,addr szProjectClass,0,56000000h,0,0,0,0,hWin,0,hInstance,0
		mov		hPrj,eax
		invoke CreateWindowEx,0h,addr szPropertyClass,0,56000000h,0,0,0,0,hWin,0,hInstance,0
		mov		hPrp,eax
		invoke CreateWindowEx,0h,addr szToolBoxClass,0,56000000h,0,0,0,0,hWin,0,hInstance,0
		mov		hTlb,eax
		invoke CreateWindowEx,200h,addr szRAEditClass,0,WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or STYLE_NOSIZEGRIP or STYLE_NOCOLLAPSE or STYLE_NOLINENUMBER,0,0,0,0,hWin,0,hInstance,0
		mov		hOut,eax
		invoke SendMessage,hOut,REM_SETWORDGROUP,0,2
		invoke RtlZeroMemory,addr lf,size lf
		mov		lf.lfHeight,-13
		invoke strcpy,addr lf.lfFaceName,addr szCourierNew
		invoke CreateFontIndirect,addr lf
		mov		hredfont,eax
		invoke SendMessage,hOut,WM_SETFONT,hredfont,0
		invoke SetupCasetab
		invoke SortStyles
		mov		ncm.cbSize,sizeof NONCLIENTMETRICS
		invoke SystemParametersInfo,SPI_GETNONCLIENTMETRICS,sizeof NONCLIENTMETRICS,addr ncm,0
		invoke CreateFontIndirect,addr ncm.lfMenuFont
		mov		hMnuFont,eax
	.elseif	eax==WM_DESTROY
		invoke DeleteObject,hMnuFont
		invoke DeleteObject,hredfont
	.elseif	eax==WM_SETFONT
		invoke SendMessage,hPrp,WM_SETFONT,wParam,TRUE
	.elseif	eax==WM_STYLECHANGED
		.if wParam==GWL_STYLE
			invoke GetWindowLong,hDEd,GWL_STYLE
			and		eax,0FFFF0000h
			push	eax
			invoke GetWindowLong,hWin,GWL_STYLE
			pop		edx
			and		eax,0FFFFh
			or		eax,edx
			invoke SetWindowLong,hDEd,GWL_STYLE,eax
		.endif
	.elseif eax==WM_MOUSEMOVE
		invoke GetClientRect,hWin,addr rect
		mov		eax,lParam
		movzx	eax,ax
		cwde
		mov		pt.x,eax
		mov		eax,lParam
		shr		eax,16
		cwde
		mov		pt.y,eax
		invoke GetCapture
		.if eax==hWin
			.if fSize==1
				; Project width
				mov		eax,rect.right
				mov		edx,eax
				sub		edx,80+53
				sub		eax,pt.x
				.if sdword ptr eax<80
					mov		eax,80
				.elseif sdword ptr eax>edx
					mov		eax,edx
				.endif
				.if eax!=winsize.wtpro
					mov		winsize.wtpro,eax
					mov		eax,rect.bottom
					shl		eax,16
					add		eax,rect.right
					invoke SendMessage,hWin,WM_SIZE,0,eax
				.endif
			.elseif fSize==2
				; Project height
				mov		eax,rect.bottom
				mov		edx,eax
				sub		edx,80
				mov		eax,pt.y
				.if sdword ptr eax<80
					mov		eax,80
				.elseif sdword ptr eax>edx
					mov		eax,edx
				.endif
				.if eax!=winsize.htpro
					mov		winsize.htpro,eax
					mov		eax,rect.bottom
					shl		eax,16
					add		eax,rect.right
					invoke SendMessage,hWin,WM_SIZE,0,eax
				.endif
			.elseif fSize==3
				; Output height
				mov		edx,rect.bottom
				sub		edx,80
				mov		eax,pt.y
				.if sdword ptr eax<80
					mov		eax,80
				.elseif sdword ptr eax>edx
					mov		eax,edx
				.endif
				mov		edx,rect.bottom
				sub		edx,eax
				.if edx!=winsize.htout
					mov		winsize.htout,edx
					mov		htout,edx
					mov		eax,rect.bottom
					shl		eax,16
					add		eax,rect.right
					invoke SendMessage,hWin,WM_SIZE,0,eax
				.endif
			.elseif fSize==4
				; Toolbox width
				mov		edx,rect.right
				sub		edx,winsize.wtpro
				sub		edx,80
				mov		eax,pt.x
				.if sdword ptr eax<26
					mov		eax,26
				.elseif sdword ptr eax>edx
					mov		eax,edx
				.endif
				.if eax!=winsize.wttbx
					mov		winsize.wttbx,eax
					mov		eax,rect.bottom
					shl		eax,16
					add		eax,rect.right
					invoke SendMessage,hWin,WM_SIZE,0,eax
				.endif
			.endif
		.else
			mov		edx,rect.right
			sub		edx,winsize.wtpro
			mov		ecx,edx
			sub		edx,SIZEBAR
			mov		eax,pt.x
			.if sdword ptr eax>=edx && sdword ptr eax<=ecx
				; Project width
				invoke SetCursor,hVSplit
				mov		fSize,1
				jmp		Ex
			.elseif sdword ptr eax>edx
				; Project height
				invoke SetCursor,hHSplit
				mov		fSize,2
				jmp		Ex
			.else
				mov		edx,winsize.wttbx
				mov		ecx,edx
				add		ecx,SIZEBAR
				mov		eax,pt.x
				.if sdword ptr eax>=edx && sdword ptr eax<=ecx
					; Toolbox width
					invoke SetCursor,hVSplit
					mov		fSize,4
					jmp		Ex
				.endif
				mov		edx,rect.bottom
				sub		edx,htout
				mov		ecx,edx
				sub		edx,SIZEBAR
				mov		eax,pt.y
				.if sdword ptr eax>=edx && sdword ptr eax<=ecx
					; Output height
					invoke SetCursor,hHSplit
					mov		fSize,3
					jmp		Ex
				.endif
			.endif
			invoke LoadCursor,0,IDC_ARROW
			invoke SetCursor,eax
			mov		fSize,0
		.endif
	.elseif eax==WM_LBUTTONDOWN
		.if fSize==1 || fSize==4
			invoke SetCapture,hWin
			invoke SetCursor,hVSplit
		.elseif fSize==2 || fSize==3
			invoke SetCapture,hWin
			invoke SetCursor,hHSplit
		.endif
	.elseif eax==WM_LBUTTONUP
		.if fSize
			invoke ReleaseCapture
			mov		fSize,0
		.endif
	.elseif	eax==WM_SIZE
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		mov		ebx,eax
		invoke GetClientRect,hWin,addr rect
		invoke MoveWindow,hTlb,0,0,winsize.wttbx,rect.bottom,TRUE
		mov		eax,rect.right
		sub		eax,winsize.wttbx
		sub		eax,winsize.wtpro
		sub		eax,SIZEBAR+SIZEBAR
		mov		edx,rect.bottom
		.if htout
			sub		edx,htout
			sub		edx,SIZEBAR
		.endif
		mov		ecx,winsize.wttbx
		add		ecx,SIZEBAR
		invoke MoveWindow,hDEd,ecx,0,eax,edx,TRUE
		mov		eax,rect.right
		sub		eax,winsize.wttbx
		sub		eax,winsize.wtpro
		sub		eax,SIZEBAR+SIZEBAR
		mov		edx,rect.bottom
		.if htout
			sub		edx,htout
			sub		edx,SIZEBAR
		.endif
		mov		ecx,winsize.wttbx
		add		ecx,SIZEBAR
		.if ebx
			.if [ebx].DLGHEAD.hred
				invoke MoveWindow,[ebx].DLGHEAD.hred,ecx,0,eax,edx,TRUE
			.endif
		.endif
		mov		eax,rect.right
		sub		eax,winsize.wttbx
		sub		eax,winsize.wtpro
		sub		eax,SIZEBAR+SIZEBAR
		mov		edx,rect.bottom
		sub		edx,htout
		mov		ecx,winsize.wttbx
		add		ecx,SIZEBAR
		invoke MoveWindow,hOut,ecx,edx,eax,htout,TRUE
		.if htout
			invoke ShowWindow,hOut,SW_SHOWNA
		.else
			invoke ShowWindow,hOut,SW_HIDE
		.endif
		mov		eax,rect.right
		sub		eax,winsize.wtpro
		invoke MoveWindow,hPrj,eax,0,winsize.wtpro,winsize.htpro,TRUE
		mov		eax,rect.right
		sub		eax,winsize.wtpro
		mov		edx,rect.bottom
		mov		ecx,winsize.htpro
		sub		edx,winsize.htpro
		add		ecx,SIZEBAR
		sub		edx,SIZEBAR
		invoke MoveWindow,hPrp,eax,ecx,winsize.wtpro,edx,TRUE
		.if hDialog
			invoke SendMessage,hDialog,WM_SIZE,0,0
		.endif
	.elseif eax==WM_CONTEXTMENU
		invoke GetParent,hWin
		mov		edx,wParam
		.if edx!=hDEd
			mov		edx,hWin
		.endif
		invoke SendMessage,eax,WM_CONTEXTMENU,edx,lParam
	.elseif eax==WM_NOTIFY
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		ebx,eax
			.if [ebx].DLGHEAD.ftextmode
				mov		edx,lParam
				.if [edx].RASELCHANGE.fchanged
					invoke SendMessage,hWin,PRO_SETMODIFY,TRUE,0
				.endif
			.endif
		.endif
		invoke NotifyParent
	.elseif eax==PRO_OPEN
		mov		fClose,0
		invoke SendMessage,hRes,PRO_CLOSE,0,0
		invoke OpenProject,wParam,lParam
		invoke InvalidateRect,hDEd,NULL,TRUE
		.if fClose
			invoke SendMessage,hWin,PRO_CLOSE,0,0
			mov		fClose,0
		.elseif fModify
			invoke SendMessage,hWin,PRO_SETMODIFY,TRUE,0
		.endif
		jmp		Ex
	.elseif eax==PRO_CLOSE
		invoke GetWindowLong,hPrj,0
		.if eax
			invoke CloseProject,eax
			.if hPreview
				invoke SendMessage,hPreview,WM_CLOSE,0,0
				mov		hPreview,0
			.endif
			invoke SetWindowLong,hPrj,0,0
		.endif
		invoke InvalidateRect,hDEd,NULL,TRUE
		invoke NotifyParent
		jmp		Ex
	.elseif eax==PRO_EXPORT
		invoke GetWindowLong,hPrj,0
		.if eax
			push	eax
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
			mov		hMemExported,eax
			pop		eax
			invoke ExportProject,lParam,wParam,eax
			invoke GlobalFree,hMemExported
			mov		hMemExported,0
		.endif
		jmp		Ex
	.elseif eax==PRO_GETMODIFY
		invoke GetWindowLong,hPrj,0
		.if eax
			.if hDialog
				push	eax
				invoke SendMessage,hDialog,WM_COMMAND,BN_CLICKED shl 16 or IDOK,0
				pop		eax
			.endif
			invoke GetProjectModify,eax
		.endif
		jmp		Ex
	.elseif eax==PRO_SETMODIFY
		invoke GetWindowLong,hPrj,0
		.if eax
			.if !wParam
				.if !fMenuErr
					invoke SetProjectModify,eax,wParam
				.endif
			.else
				invoke SetProjectModify,eax,wParam
			.endif
		.endif
		invoke NotifyParent
		jmp		Ex
	.elseif eax==PRO_GETSELECTED
		invoke GetProjectSelected
		jmp		Ex
	.elseif eax==PRO_ADDITEM
		invoke GetWindowLong,hPrj,0
		.if eax
			invoke AddProjectItem,eax,wParam,lParam
		.endif
		jmp		Ex
	.elseif eax==PRO_DELITEM
		invoke RemoveProjectSelected
		invoke NotifyParent
		jmp		Ex
	.elseif eax==PRO_CANUNDO
		invoke ProjectCanUndo
		jmp		Ex
	.elseif eax==PRO_UNDODELETED
		invoke ProjectUndoDeleted
		jmp		Ex
	.elseif eax==PRO_SETNAME
		invoke SetProjectItemName,NULL,wParam
		mov		edx,wParam
		mov		ecx,offset szResourceh
	  @@:
		mov		al,[edx]
		.if al!='.' && al
			mov		[ecx],al
			inc		edx
			inc		ecx
			jmp		@b
		.endif
		mov		dword ptr [ecx],'h.'
		.if lParam
			invoke strcpy,offset szProjectPath,lParam
			invoke SetCurrentDirectory,offset szProjectPath
		.endif
		jmp		Ex
	.elseif eax==PRO_SETDEFINE
		invoke strcpy,addr szResourceh,lParam
		jmp		Ex
	.elseif eax==PRO_SHOWNAMES
		invoke GetWindowLong,hPrj,0
		.if eax
			mov		eax,lParam
			.if !eax
				mov		eax,hOut
			.endif
			mov		hExportOut,eax
			invoke CloseDialog
			invoke CreateDialogParam,hInstance,IDD_DLGNAMES,hDEd,offset NameEditProc,NULL
			mov		hDialog,eax
		.endif
		jmp		Ex
	.elseif eax==PRO_SETEXPORT
		mov		eax,wParam
		mov		nExportType,eax
		.if lParam
			invoke strcpy,offset szExportFileName,lParam
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==PRO_EXPORTNAMES
		invoke GetWindowLong,hPrj,0
		.if eax
			mov		eax,lParam
			.if !eax
				mov		eax,hOut
			.endif
			mov		hExportOut,eax
			mov		eax,wParam
			inc		eax
			invoke DialogBoxParam,hInstance,IDD_DLGNAMES,hPrj,offset NameEditProc,eax
		.endif
		jmp		Ex
	.elseif eax==PRO_SETINITID
		push	esi
		push	edi
		mov		esi,lParam
		mov		edi,offset initid
		mov		ecx,sizeof INITID
		rep		movsb
		pop		edi
		pop		esi
		xor		eax,eax
		jmp		Ex
	.elseif eax==PRO_GETMEM
		invoke GetWindowLong,hPrj,0
		jmp		Ex
	.elseif eax==PRO_SETTEXTFONT
		.if hredfont
			invoke DeleteObject,hredfont
		.endif
		mov		eax,wParam
		mov		hredfont,eax
		invoke SendMessage,hOut,WM_SETFONT,hredfont,TRUE
		invoke SendMessage,hOut,REM_REPAINT,0,TRUE
		.if hDlgRed
			invoke SendMessage,hDlgRed,WM_SETFONT,hredfont,TRUE
			invoke SendMessage,hDlgRed,REM_REPAINT,0,TRUE
		.endif
		invoke GetWindowLong,hPrj,0
		.if eax
			mov		ebx,eax
			.while [ebx].PROJECT.hmem
				.if [ebx].PROJECT.ntype==TPE_DIALOG
					mov		ebx,[ebx].PROJECT.hmem
					.if [ebx].DLGHEAD.hred
						invoke SendMessage,[ebx].DLGHEAD.hred,WM_SETFONT,hredfont,TRUE
						invoke SendMessage,[ebx].DLGHEAD.hred,REM_REPAINT,0,TRUE
					.endif
				.endif
				add		ebx,sizeof PROJECT
			.endw
		.endif
		jmp		Ex
	.elseif eax==PRO_GETTEXTFONT
		mov		eax,hredfont
		jmp		Ex
	.elseif eax==PRO_SETSYSTEMPATH
		;wParam=0, lParam=lpPath
		invoke strcpy,addr szSystemPath,lParam
		jmp		Ex
	.elseif eax==PRO_GETSYSTEMPATH
		;wParam=0, lParam=0
		mov		eax,offset szSystemPath
		jmp		Ex
	.elseif eax==PRO_SETCUSTOMTYPE
		;wParam=index, lParam=lpRARSTYPE
		push	esi
		push	edi
		mov		esi,lParam
		mov		eax,wParam
		mov		ecx,sizeof RARSTYPE
		mul		ecx
		add		eax,offset rarstype
		mov		edi,eax
		mov		ecx,sizeof RARSTYPE
		rep movsb
		pop		edi
		pop		esi
		jmp		Ex
	.elseif eax==PRO_GETCUSTOMTYPE
		;wParam=index, lParam=0
		mov		eax,wParam
		mov		ecx,sizeof RARSTYPE
		mul		ecx
		add		eax,offset rarstype
		jmp		Ex
	.elseif eax==PRO_GETDIALOG
		mov		eax,hDialog
		jmp		Ex
	.elseif eax==PRO_INCVERSION
	    invoke GetWindowLong,hPrj,0
		.if eax
			invoke IncrementVersion,eax
		.endif
	.elseif eax==PRO_SETHIGHLIGHT
		mov		eax,wParam
		and		eax,0FFFFFFh
		mov		edx,lParam
		and		edx,0FFFFFFh
		invoke SetHilite,eax,edx
	.elseif eax==PRO_SETUSERDEFINED
		invoke strcpy,offset szUserDefined,lParam
		xor		eax,eax
		jmp		Ex
	.elseif eax==MEM_OPEN
		invoke CreateMnu,hDEd,lParam
		jmp		Ex
	.elseif eax==MEM_GETERR
		mov		eax,fMenuErr
		jmp		Ex
	.elseif eax==DEM_OPEN
		invoke SendMessage,hDEd,WM_VSCROLL,SB_THUMBTRACK,0
		invoke SendMessage,hDEd,WM_HSCROLL,SB_THUMBTRACK,0
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		ebx,eax
			.if [ebx].DLGHEAD.ftextmode
				invoke ShowWindow,[ebx].DLGHEAD.hred,SW_HIDE
			.endif
		.endif
		invoke CreateDlg,lParam
		push	eax
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		eax,[eax].DLGHEAD.ftextmode
		.endif
		invoke SendMessage,hWin,DEM_SETTEXTMODE,eax,0
		invoke NotifyParent
		pop		eax
		jmp		Ex
	.elseif eax==DEM_DELETECONTROLS
		invoke DeleteCtl
		invoke NotifyParent
		jmp		Ex
	.elseif eax==DEM_CANUNDO
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		ebx,eax
			mov		eax,[ebx].DLGHEAD.hred
			.if eax
				invoke SendMessage,eax,EM_CANUNDO,0,0
			.endif
		.elseif hDlgRed
			invoke SendMessage,hDlgRed,EM_CANUNDO,0,0
		.endif
		jmp		Ex
	.elseif eax==DEM_UNDO
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		ebx,eax
			.if [ebx].DLGHEAD.ftextmode
				invoke SendMessage,[ebx].DLGHEAD.hred,EM_UNDO,0,0
			.else
				invoke UndoRedo,FALSE
			.endif
		.elseif hDlgRed
			invoke SendMessage,hDlgRed,EM_UNDO,0,0
		.endif
		jmp		Ex
	.elseif eax==DEM_CANREDO
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		ebx,eax
			mov		eax,[ebx].DLGHEAD.hred
			.if eax
				invoke SendMessage,eax,EM_CANREDO,0,0
			.endif
		.elseif hDlgRed
			invoke SendMessage,hDlgRed,EM_CANREDO,0,0
		.endif
		jmp		Ex
	.elseif eax==DEM_REDO
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		ebx,eax
			.if [ebx].DLGHEAD.ftextmode
				invoke SendMessage,[ebx].DLGHEAD.hred,EM_REDO,0,0
			.else
				invoke UndoRedo,TRUE
			.endif
		.elseif hDlgRed
			invoke SendMessage,hDlgRed,EM_REDO,0,0
		.endif
		jmp		Ex
	.elseif eax==DEM_CUT
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		ebx,eax
			.if [ebx].DLGHEAD.ftextmode
				invoke SendMessage,[ebx].DLGHEAD.hred,WM_CUT,0,0
			.else
				invoke CopyCtl
				invoke DeleteCtl
				invoke NotifyParent
			.endif
		.endif
		jmp		Ex
	.elseif eax==DEM_COPY
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		ebx,eax
			.if [ebx].DLGHEAD.ftextmode
				invoke SendMessage,[ebx].DLGHEAD.hred,WM_COPY,0,0
			.else
				invoke CopyCtl
				invoke NotifyParent
			.endif
		.endif
		jmp		Ex
	.elseif eax==DEM_CANPASTE
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		ebx,eax
			.if [ebx].DLGHEAD.ftextmode
				invoke SendMessage,[ebx].DLGHEAD.hred,EM_CANPASTE,CF_TEXT,0
			.else
				mov		eax,offset dlgpaste
				mov		eax,[eax].DIALOG.hwnd
				.if eax
					mov		eax,TRUE
				.endif
			.endif
		.endif
		jmp		Ex
	.elseif eax==DEM_PASTE
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		ebx,eax
			.if [ebx].DLGHEAD.ftextmode
				invoke SendMessage,[ebx].DLGHEAD.hred,WM_PASTE,0,0
			.else
				invoke PasteCtl
				invoke NotifyParent
			.endif
		.endif
		jmp		Ex
	.elseif eax==DEM_ISLOCKED
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		eax,[eax].DLGHEAD.locked
			.if eax
				mov		eax,TRUE
			.endif
		.endif
		jmp		Ex
	.elseif eax==DEM_LOCKCONTROLS
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			push	eax
			invoke SetFocus,hDEd
			pop		eax
			mov		edx,lParam
			.if edx
				mov		edx,TRUE
			.endif
			mov		[eax].DLGHEAD.locked,edx
			.if hReSize
				invoke SizeingRect,hReSize,FALSE
			.endif
			invoke SetChanged,TRUE
		.endif
		jmp		Ex
	.elseif eax==DEM_ISBACK
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		lea		eax,[eax+sizeof DLGHEAD]
		push	eax
		.if hReSize
			invoke GetCtrlMem,hReSize
		.endif
		pop		edx
		.if eax==edx
			mov		eax,TRUE
		.else
			add		edx,sizeof DIALOG
			.if eax==edx
				mov		eax,TRUE
			.else
				mov		eax,FALSE
			.endif
		.endif
		jmp		Ex
	.elseif eax==DEM_SENDTOBACK
		mov		eax,hReSize
		.if eax
			invoke GetCtrlMem,eax
			.if eax
				.if [eax].DIALOG.ntype
					invoke SendToBack,hReSize
				.endif
			.endif
		.endif
		invoke NotifyParent
		jmp		Ex
	.elseif eax==DEM_ISFRONT
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		lea		eax,[eax+sizeof DLGHEAD]
		push	eax
		.if hReSize
			invoke GetCtrlMem,hReSize
		.endif
		pop		edx
		.if eax==edx
			mov		eax,TRUE
		.else
			add		eax,sizeof DIALOG
			.if [eax].DIALOG.hwnd
				mov		eax,FALSE
			.else
				mov		eax,TRUE
			.endif
		.endif
		jmp		Ex
	.elseif eax==DEM_BRINGTOFRONT
		mov		eax,hReSize
		.if eax
			invoke GetCtrlMem,eax
			.if eax
				.if [eax].DIALOG.ntype
					invoke BringToFront,hReSize
				.endif
			.endif
		.endif
		invoke NotifyParent
		jmp		Ex
	.elseif eax==DEM_ISSELECTION
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		ebx,eax
			.if [ebx].DLGHEAD.ftextmode
				invoke SendMessage,[ebx].DLGHEAD.hred,EM_EXGETSEL,0,addr chrg
				mov		eax,chrg.cpMax
				sub		eax,chrg.cpMin
				.if eax
					mov		eax,1
				.endif				
			.else
				xor		eax,eax
				.if hReSize
					invoke GetCtrlMem,hReSize
					.if eax
						mov		eax,[eax].DIALOG.ntype
						.if eax
							mov		eax,1
						.endif
					.endif
				.elseif hMultiSel
					mov		eax,2
				.endif
			.endif
		.endif
		jmp		Ex
	.elseif eax==DEM_ALIGNSIZE
		mov		eax,lParam
		invoke AlignSizeCtl,lParam
		jmp		Ex
	.elseif eax==DEM_GETMODIFY
		invoke GetWindowLong,hDEd,DEWM_PROJECT
		.if eax
			mov		eax,[eax].PROJECT.changed
		.endif
		jmp		Ex
	.elseif eax==DEM_SETMODIFY
		mov		eax,wParam
		.if eax
			mov		eax,TRUE
		.endif
		invoke SetChanged,eax
		jmp		Ex
	.elseif eax==DEM_COMPACT
;		invoke CompactDialog,hDEd
		jmp		Ex
	.elseif eax==DEM_EXPORTTORC
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		invoke ExportDialog,eax
		jmp		Ex
	.elseif eax==DEM_SETPOSSTATUS
		mov		eax,lParam
		mov		nStatus,eax
		mov		eax,wParam
		mov		hStatus,eax
		jmp		Ex
	.elseif eax==DEM_SETGRIDSIZE
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		mov		Gridcx,eax
		mov		Gridcy,edx
		mov		eax,lParam
		mov		Gridc,eax
		invoke GetWindowLong,hDEd,DEWM_DIALOG
		.if eax
			push	eax
			invoke CreateGridBrush,eax
			pop		eax
			invoke InvalidateRect,eax,NULL,TRUE
			.if hReSize
				invoke SizeingRect,hReSize,FALSE
			.endif
		.endif
		jmp		Ex
	.elseif eax==DEM_ADDCONTROL
		invoke AddCustomControl,lParam
		jmp		Ex
	.elseif eax==DEM_GETCOLOR
		;wParam=0
		;lParam=lpCOLOR
		mov		edx,lParam
		mov		eax,color.back
		mov		[edx].RESCOLOR.back,eax
		mov		eax,color.text
		mov		[edx].RESCOLOR.text,eax
		jmp		Ex
	.elseif eax==DEM_SETCOLOR
		;wParam=0
		;lParam=lpCOLOR
		mov		edx,lParam
		mov		eax,[edx].RESCOLOR.back
		mov		color.back,eax
		mov		eax,[edx].RESCOLOR.text
		mov		color.text,eax
		invoke SetColors
		jmp		Ex
	.elseif eax==DEM_SHOWDIALOG
		;wParam=0
		;lParam=0
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			.if !hPreview
				invoke ShowDialog,hDEd,eax
				mov		eax,hPreview
			.else
				invoke SendMessage,hPreview,WM_CLOSE,0,0
				xor		eax,eax
				mov		hPreview,eax
			.endif
		.endif
		push	eax
		invoke NotifyParent
		pop		eax
		jmp		Ex
	.elseif eax==DEM_GETSHOWDIALOG
		;wParam=0
		;lParam=0
		mov		eax,hPreview
		jmp		Ex
	.elseif eax==DEM_SHOWTABINDEX
		;wParam=0
		;lParam=0
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		ebx,eax
			.if hTabSet
				invoke DestroyWindow,hTabSet
				mov		hTabSet,0
				invoke ShowWindow,hInvisible,SW_SHOWNA
			.else
				mov		nTabSet,0
				.while hMultiSel
					invoke GetParent,hMultiSel
					invoke DestroyMultiSel,hMultiSel
					mov		hMultiSel,eax
				.endw
				invoke DestroySizeingRect
				invoke GetWindowLong,hDEd,DEWM_SCROLLY
				shl		eax,3
				push	eax
				invoke GetWindowLong,hDEd,DEWM_SCROLLX
				shl		eax,3
				pop		edx
				neg		eax
				neg		edx
				invoke CreateWindowEx,WS_EX_TRANSPARENT,addr szDlgEditDummyClass,NULL,WS_CHILD or WS_VISIBLE,eax,edx,16384,16384,hDEd,123456789,hInstance,0
				mov		hTabSet,eax
				invoke ShowWindow,hInvisible,SW_HIDE
				invoke ShowWindow,hTabSet,SW_HIDE
				invoke SetWindowPos,hTabSet,HWND_TOP,0,0,0,0,SWP_NOACTIVATE or SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOSIZE
				invoke UpdateWindow,hDEd
			.endif
		.endif
	.elseif eax==DEM_EXPORTDLG
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			push	esi
			push	edi
			mov		esi,eax
			invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
			mov		edi,eax
			push	eax
			mov		[edi].RADLGHEAD.ver,101
			mov		[edi].RADLGHEAD.changed,FALSE
			invoke strcpy,addr [edi].RADLGHEAD.class,addr [esi].DLGHEAD.class
			invoke strcpy,addr [edi].RADLGHEAD.menuid,addr [esi].DLGHEAD.menuid
			invoke strcpy,addr [edi].RADLGHEAD.font,addr [esi].DLGHEAD.font
			mov		eax,[esi].DLGHEAD.fontsize
			mov		[edi].RADLGHEAD.fontsize,eax
			mov		[edi].RADLGHEAD.undo,FALSE
			mov		eax,[esi].DLGHEAD.ctlid
			mov		[edi].RADLGHEAD.ctlid,eax
			mov		[edi].RADLGHEAD.hmnu,NULL
			mov		[edi].RADLGHEAD.htlb,NULL
			mov		[edi].RADLGHEAD.hstb,NULL
			mov		[edi].RADLGHEAD.locked,FALSE
			mov		[edi].RADLGHEAD.hfont,NULL
			mov		[edi].RADLGHEAD.charset,0
			mov		[edi].RADLGHEAD.italic,FALSE
			mov		[edi].RADLGHEAD.weight,0
			add		esi,sizeof DLGHEAD
			add		edi,sizeof RADLGHEAD
			.while [esi].DIALOG.hwnd
				.if [esi].DIALOG.hwnd!=-1
					mov		[edi].RADIALOG.hwnd,1
					mov		[edi].RADIALOG.hdmy,NULL
					mov		[edi].RADIALOG.oldproc,NULL
					mov		[edi].RADIALOG.hpar,NULL
					mov		[edi].RADIALOG.hcld,NULL
					mov		eax,[esi].DIALOG.style
					mov		[edi].RADIALOG.style,eax
					mov		eax,[esi].DIALOG.exstyle
					mov		[edi].RADIALOG.exstyle,eax
					mov		eax,[esi].DIALOG.dux
					invoke ConvertDuxToPix,eax
					mov		[edi].RADIALOG.x,eax
					mov		eax,[esi].DIALOG.duy
					invoke ConvertDuyToPix,eax
					mov		[edi].RADIALOG.y,eax
					mov		eax,[esi].DIALOG.duccx
					invoke ConvertDuxToPix,eax
					mov		[edi].RADIALOG.ccx,eax
					mov		eax,[esi].DIALOG.duccy
					invoke ConvertDuyToPix,eax
					mov		[edi].RADIALOG.ccy,eax
					.if [esi].DIALOG.ntype==23
						invoke strcpyn,addr [edi].RADIALOG.caption,addr [esi].DIALOG.class,32
					.else
						invoke strcpyn,addr [edi].RADIALOG.caption,addr [esi].DIALOG.caption,RAMaxCap
					.endif
					mov		eax,[esi].DIALOG.ntype
					mov		[edi].RADIALOG.ntype,eax
					mov		eax,[esi].DIALOG.ntypeid
					mov		[edi].RADIALOG.ntypeid,eax
					mov		eax,[esi].DIALOG.tab
					mov		[edi].RADIALOG.tab,eax
					mov		eax,[esi].DIALOG.id
					mov		[edi].RADIALOG.id,eax
					invoke strcpyn,addr [edi].RADIALOG.idname,addr [esi].DIALOG.idname,32
					mov		[edi].RADIALOG.undo,NULL
					mov		[edi].RADIALOG.himg,NULL
					add		edi,sizeof RADIALOG
				.endif
				add		esi,sizeof DIALOG
			.endw
			pop		eax
			push	eax
			sub		edi,eax
			push	edi
			mov		edi,eax
			invoke CreateFile,lParam,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
			mov		hFile,eax
			pop		edx
			invoke WriteFile,hFile,edi,edx,addr dwbytes,NULL
			invoke CloseHandle,hFile
			pop		eax
			invoke GlobalFree,eax
			pop		edi
			pop		esi
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==DEM_AUTOID
		invoke AutoIDMultiSel
		xor		eax,eax
		jmp		Ex
	.elseif eax==DEM_GETBUTTONSCOUNT
		mov		eax,nButtons
		jmp		Ex
	.elseif eax==DEM_GETMEM
		invoke GetWindowLong,hDEd,wParam
		jmp		Ex
	.elseif eax==DEM_SHOWOUTPUT
		.if wParam
			mov		eax,winsize.htout
			mov		htout,eax
		.else
			mov		htout,0
		.endif
		invoke SendMessage,hWin,WM_SIZE,0,0
	.elseif eax==DEM_GETSIZE
		mov		edx,lParam
		mov		eax,winsize.htpro
		mov		[edx].WINSIZE.htpro,eax
		mov		eax,winsize.wtpro
		mov		[edx].WINSIZE.wtpro,eax
		mov		eax,winsize.htout
		mov		[edx].WINSIZE.htout,eax
		mov		eax,winsize.wttbx
		mov		[edx].WINSIZE.wttbx,eax
		mov		eax,winsize.ptstyle.x
		mov		[edx].WINSIZE.ptstyle.x,eax
		mov		eax,winsize.ptstyle.y
		mov		[edx].WINSIZE.ptstyle.y,eax
	.elseif eax==DEM_SETSIZE
		mov		edx,lParam
		mov		eax,[edx].WINSIZE.htpro
		mov		winsize.htpro,eax
		mov		eax,[edx].WINSIZE.wtpro
		mov		winsize.wtpro,eax
		mov		eax,[edx].WINSIZE.htout
		mov		winsize.htout,eax
		mov		eax,[edx].WINSIZE.wttbx
		mov		winsize.wttbx,eax
		mov		eax,[edx].WINSIZE.ptstyle.x
		mov		winsize.ptstyle.x,eax
		mov		eax,[edx].WINSIZE.ptstyle.y
		mov		winsize.ptstyle.y,eax
	.elseif eax==DEM_GETTEXTMODE
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		eax,[eax].DLGHEAD.ftextmode
		.endif
		jmp		Ex
	.elseif eax==DEM_SETTEXTMODE
		invoke GetWindowLong,hDEd,DEWM_MEMORY
		.if eax
			mov		ebx,eax
			.if wParam
				invoke DestroySizeingRect
				.while hMultiSel
					invoke DestroyMultiSel,hMultiSel
					mov		hMultiSel,eax
				.endw
				invoke ShowWindow,hDEd,SW_HIDE
				invoke ShowWindow,[ebx].DLGHEAD.hred,SW_SHOW
				invoke SendMessage,[ebx].DLGHEAD.hred,EM_SETMODIFY,FALSE,0
				invoke SendMessage,[ebx].DLGHEAD.hred,REM_LOCKUNDOID,TRUE,0
				invoke SetWindowPos,[ebx].DLGHEAD.hred,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
				mov		[ebx].DLGHEAD.ftextmode,TRUE
				invoke SendMessage,hRes,WM_SIZE,0,0
				invoke SendMessage,[ebx].DLGHEAD.hred,EM_SETSEL,0,0
				invoke SetFocus,[ebx].DLGHEAD.hred
			.else
				.if [ebx].DLGHEAD.ftextmode
					invoke SendMessage,[ebx].DLGHEAD.hred,REM_LOCKUNDOID,FALSE,0
					invoke SendMessage,[ebx].DLGHEAD.hred,EM_GETMODIFY,0,0
					.if eax
						invoke UndoRedo,-1
						invoke GetWindowLong,hDEd,DEWM_MEMORY
						mov		ebx,eax
					.endif
					.if !fParseError
						invoke ShowWindow,[ebx].DLGHEAD.hred,SW_HIDE
						mov		[ebx].DLGHEAD.ftextmode,FALSE
						invoke SizeingRect,des.hdlg,FALSE
						invoke ShowWindow,hDEd,SW_SHOWNA
					.endif
				.endif
			.endif
		.endif
	.elseif eax==DEM_CLEARCUSTSTYLE
		invoke RtlZeroMemory,offset rscuststyledef,2048
		invoke SortStyles
	.elseif eax==DEM_ADDCUSTSTYLE
		mov		ebx,offset rscuststyledef
		.while byte ptr [ebx+8]
			invoke strlen,addr [ebx+8]
			lea		ebx,[ebx+eax+8+1]
		.endw
		mov		edx,lParam
		mov		eax,[edx].CUSTSTYLE.nValue
		mov		[ebx],eax
		mov		eax,[edx].CUSTSTYLE.nMask
		mov		[ebx+4],eax
		invoke strcpy,addr [ebx+8],addr [edx].CUSTSTYLE.szStyle
		invoke SortStyles
		mov		eax,ebx
		jmp		Ex
	.elseif eax==DEM_GETOUTPUT
		mov		eax,hOut
		jmp		Ex
	.elseif eax==WM_USER+9999
		invoke GetClientRect,hWin,addr rect
		mov		eax,rect.bottom
		shr		eax,1
		mov		winsize.htpro,eax
		mov		winsize.wtpro,140
		mov		winsize.htout,0
		mov		winsize.wttbx,52
		invoke SendMessage,hWin,WM_SIZE,0,0
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor		eax,eax
  Ex:
	ret

ResEdProc	endp

IFDEF DLL
	include RAResEdDll.asm
ELSE
	include RAResEdLib.asm
ENDIF

