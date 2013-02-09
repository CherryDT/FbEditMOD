.486
.model flat,stdcall
option casemap:none

include ResEd.inc
include Misc.asm
include FileIO.asm
include About.asm
include Opt\MenuOption.asm
include Opt\TabOptions.asm
include Find\Find.asm

.code

DoToolBar proc hToolBar:HWND

	;Set toolbar struct size
	invoke SendMessage,hToolBar,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	invoke SendMessage,hToolBar,TB_ADDBUTTONS,ntbrbtns,addr tbrbtns
	invoke ImageList_LoadImage,hInstance,IDB_TOOLBAR,16,29,0FF00FFh,IMAGE_BITMAP,LR_CREATEDIBSECTION
	mov		hImlTbr,eax
	invoke SendMessage,hToolBar,TB_SETIMAGELIST,0,hImlTbr
	invoke GrayedImageList,hToolBar
	ret

DoToolBar endp

ToolBarEnable proc uses ebx
	LOCAL	chrg:CHARRANGE

	mov		ebx,hTbr
	.if hResEdSave
		invoke SendMessage,hResEd,EM_CANUNDO,0,0
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_UNDO,eax
		invoke SendMessage,hResEd,EM_CANREDO,0,0
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_REDO,eax
		invoke SendMessage,hResEd,EM_EXGETSEL,0,addr chrg
		mov		eax,chrg.cpMax
		sub		eax,chrg.cpMin
		push	eax
		push	eax
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_DELETE,eax
		pop		eax
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_CUT,eax
		pop		eax
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_COPY,eax
		invoke SendMessage,hResEd,EM_CANPASTE,SF_TEXT,0
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_PASTE,eax
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_FIND,TRUE
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_REPLACE,TRUE
	.else
		invoke SendMessage,hResEd,DEM_CANUNDO,0,0
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_UNDO,eax
		invoke SendMessage,hResEd,DEM_CANREDO,0,0
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_REDO,eax
		invoke SendMessage,hResEd,DEM_ISSELECTION,0,0
		push	eax
		push	eax
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_DELETE,eax
		pop		eax
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_CUT,eax
		pop		eax
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_COPY,eax
		invoke SendMessage,hResEd,DEM_CANPASTE,0,0
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_PASTE,eax
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_FIND,FALSE
		invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_EDIT_REPLACE,FALSE
	.endif
	mov		eax,wpos.fView
	and		eax,1
	invoke SendMessage,ebx,TB_CHECKBUTTON,IDM_VIEW_OUTPUT,eax
	.if hResEdSave
		xor		eax,eax
	.else
		invoke SendMessage,hResEd,DEM_GETMEM,DEWM_DIALOG,0
	.endif
	invoke SendMessage,ebx,TB_ENABLEBUTTON,IDM_VIEW_PREVIEW,eax
	xor		eax,eax
	.if hPreview
		inc		eax
	.endif
	invoke SendMessage,ebx,TB_CHECKBUTTON,IDM_VIEW_PREVIEW,eax
	ret

ToolBarEnable endp

WndProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hFont:DWORD
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	hMem:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	mnu:MENU
	LOCAL	mii:MENUITEMINFO
	LOCAL	hBr:DWORD
	LOCAL	hPen:DWORD
	LOCAL	mDC:HDC
	LOCAL	lf:LOGFONT
	LOCAL	cust:CUSTSTYLE
	LOCAL	rarstype:RARSTYPE
	LOCAL	chrg:CHARRANGE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
		mov		fr,FR_DOWN
		invoke GetModuleFileName,0,addr AppPath,sizeof AppPath
		invoke lstrlen,addr AppPath
		.while byte ptr AppPath[eax]!='\' && eax
			dec		eax
		.endw
		mov		AppPath[eax],0
		invoke SetCurrentDirectory,addr AppPath
		invoke GetDlgItem,hWin,IDC_SBR1
		invoke SendMessage,eax,WM_GETFONT,0,0
		mov		hFont,eax
		invoke MoveWindow,hWin,wpos.x,wpos.y,wpos.wt,wpos.ht,TRUE
		invoke LoadAccelerators,hInstance,IDR_ACCEL
		mov		hAccel,eax
		invoke GetMenu,hWin
		mov		hMnu,eax
		invoke WriteDefHelp
		invoke SetToolMenu
		invoke SetHelpMenu
		invoke LoadMenu,hInstance,IDR_CONTEXT
		mov		hContextMenu,eax
		invoke GetSubMenu,eax,0
		mov		hContextMenuPopup,eax
		invoke GetDlgItem,hWin,IDC_TBR1
		mov		hTbr,eax
		invoke DoToolBar,eax
		mov		edx,WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
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
		.if grdsize.sizetofont
			or		edx,DES_SIZETOFONT
		.endif
		.if grdsize.defines
			or		edx,DES_NODEFINES
		.endif
		.if grdsize.simple
			or		edx,DES_SIMPLEPROPERTY
		.endif
		.if grdsize.defstatic
			or		edx,DES_DEFIDC_STATIC
		.endif
		.if grdsize.borlandcomp
			or		edx,DES_BORLAND
		.endif
		invoke CreateWindowEx,0,addr szResEdClass,0,edx,0,0,0,0,hWin,IDC_RESED,hInstance,0
		mov		hResEd,eax
		invoke SendMessage,eax,WM_SETFONT,hFont,0
		mov		edx,nmeexp.nOutput
		shl		edx,16
		add		edx,nmeexp.nType
		invoke SendMessage,hResEd,PRO_SETEXPORT,edx,addr nmeexp.szFileName
		invoke SendMessage,hResEd,PRO_SETINITID,0,addr initid
		invoke SendMessage,hResEd,PRO_SETHIGHLIGHT,col.styles,col.words
		invoke GetDlgItem,hWin,IDC_SBR1
		invoke SendMessage,hResEd,DEM_SETPOSSTATUS,eax,0
		mov		eax,grdsize.y
		shl		eax,16
		add		eax,grdsize.x
		mov		edx,grdsize.line
		shl		edx,24
		add		edx,grdsize.color
		invoke SendMessage,hResEd,DEM_SETGRIDSIZE,eax,edx
		invoke SendMessage,hResEd,DEM_SETCOLOR,0,addr col
		invoke ImageList_Create,16,16,ILC_COLOR8 or ILC_MASK,2,0
		mov		hIml,eax
		invoke LoadBitmap,hInstance,IDB_ARROW
		push	eax
		invoke ImageList_AddMasked,hIml,eax,0C0C0C0h
		pop		eax
		invoke DeleteObject,eax
		invoke ToolBarEnable
		invoke SendMessage,hResEd,DEM_SETSIZE,0,addr winsize
		mov		eax,wpos.fView
		and		eax,1
		invoke SendMessage,hResEd,DEM_SHOWOUTPUT,eax,0
		;Add custom controls
		mov		nInx,1
		mov		ebx,offset hCustDll
		.while nInx<=32
			invoke MakeKey,addr szCust,nInx,addr buffer1
			mov		lpcbData,MAX_PATH
			mov		buffer,0
			invoke RegQueryValueEx,hReg,addr buffer1,0,addr lpType,addr buffer,addr lpcbData
			.if buffer
				invoke SendMessage,hResEd,DEM_ADDCONTROL,0,addr buffer
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
			invoke RegQueryValueEx,hReg,addr buffer1,0,addr lpType,addr cust,addr lpcbData
			.if cust.szStyle
				invoke SendMessage,hResEd,DEM_ADDCUSTSTYLE,0,addr cust
			.endif
			inc		nInx
		.endw
		;Set resource types
		mov		nInx,1
		mov		ebx,offset hCustDll
		.while nInx<=32
			invoke MakeKey,addr szCustType,nInx,addr buffer1
			mov		lpcbData,sizeof RARSTYPE
			invoke RtlZeroMemory,addr rarstype,sizeof RARSTYPE
			invoke RegQueryValueEx,hReg,addr buffer1,0,addr lpType,addr rarstype,addr lpcbData
			.if rarstype.sztype || rarstype.nid
				mov		edx,nInx
				dec		edx
				invoke SendMessage,hResEd,PRO_SETCUSTOMTYPE,edx,addr rarstype
			.endif
			inc		nInx
		.endw
		;Set mru projects
		mov		nInx,0
		mov		ebx,offset mruproject
		.while nInx<=9
			invoke MakeKey,addr szMruProject,nInx,addr buffer1
			mov		lpcbData,MAX_PATH*2
			invoke RegQueryValueEx,hReg,addr buffer1,0,addr lpType,ebx,addr lpcbData
			.if byte ptr [ebx]
				mov		eax,nInx
				shl		eax,8
				or		eax,' 0&'
				mov		dword ptr buffer,eax
				invoke lstrcpy,offset tmpbuff,ebx
				invoke GetStrItem,offset tmpbuff,addr buffer1
				invoke PathCompactPathEx,addr buffer[3],addr buffer1,30,0
				invoke GetSubMenu,hMnu,0
				mov		edx,eax
				mov		ecx,nInx
				add		ecx,21000
				invoke AppendMenu,edx,MF_STRING,ecx,addr buffer
				add		ebx,MAX_PATH*2
			.endif
			inc		nInx
		.endw
		.if !grdsize.standardmnu
			invoke CoolMenu
		.endif
		invoke RtlZeroMemory,addr lf,sizeof lf
		invoke lstrcpy,addr lf.lfFaceName,addr textfont.lfFaceName
		mov		eax,textfont.lfHeight
		mov		lf.lfHeight,eax
		mov		eax,textfont.lfWeight
		mov		lf.lfWeight,eax
		mov		eax,textfont.lfItalic
		mov		lf.lfItalic,al
		mov		eax,textfont.lfCharSet
		mov		lf.lfCharSet,al
		invoke CreateFontIndirect,addr lf
		invoke SendMessage,hResEd,PRO_SETTEXTFONT,eax,0
		invoke SendMessage,hResEd,PRO_SETSYSTEMPATH,0,addr SystemPath
	.elseif eax==WM_NCACTIVATE
		.if hResEd
			invoke SendMessage,hResEd,DEM_GETMEM,DEWM_DIALOG,0
			.if eax
				invoke SendMessage,eax,WM_NCACTIVATE,wParam,0
			.endif
		.endif
		jmp		ExDef
	.elseif eax==WM_NCMOUSEMOVE
		invoke GetDlgItem,hWin,IDC_SBR1
		invoke SendMessage,eax,SB_SETTEXT,0,offset szNULL
	.elseif eax==WM_MOUSEMOVE
		invoke GetDlgItem,hWin,IDC_SBR1
		invoke SendMessage,eax,SB_SETTEXT,0,offset szNULL
	.elseif eax==WM_CONTEXTMENU
		mov		eax,lParam
		.if eax!=-1
			and		eax,0FFFFh
			cwde
			mov		pt.x,eax
			mov		eax,lParam
			shr		eax,16
			cwde
			mov		pt.y,eax
		.else
			invoke GetWindowRect,hWin,addr rect
			.if hResEd
				invoke SendMessage,hResEd,DEM_GETMEM,DEWM_DIALOG,0
				.if eax
					mov		edx,eax
					invoke GetWindowRect,edx,addr rect
				.endif
			.endif
			mov		eax,rect.left
			add		eax,30
			mov		pt.x,eax
			mov		eax,rect.top
			add		eax,30
			mov		pt.y,eax
		.endif
		mov		eax,wParam
		.if eax==hResEd
			invoke GetSubMenu,hMnu,4
			push	eax
			invoke SendMessage,hWin,WM_INITMENUPOPUP,eax,4
			pop		eax
			invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWin,0
		.else
			invoke SendMessage,hWin,WM_INITMENUPOPUP,hContextMenuPopup,1
			invoke SendMessage,hWin,WM_INITMENUPOPUP,hContextMenuPopup,2
			invoke TrackPopupMenu,hContextMenuPopup,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWin,0
		.endif
	.elseif eax==WM_INITMENUPOPUP
		mov		eax,lParam
		.if eax==1
			;Edit
			.if hResEdSave
				invoke SendMessage,hResEd,EM_CANUNDO,0,0
				xor		eax,1
				.if eax
					mov		eax,MF_GRAYED
				.endif
				invoke EnableMenuItem,wParam,IDM_EDIT_UNDO,eax
				invoke SendMessage,hResEd,EM_CANREDO,0,0
				xor		eax,1
				.if eax
					mov		eax,MF_GRAYED
				.endif
				invoke EnableMenuItem,wParam,IDM_EDIT_REDO,eax
				invoke SendMessage,hResEd,EM_EXGETSEL,0,addr chrg
				mov		eax,chrg.cpMax
				sub		eax,chrg.cpMin
				.if !eax
					mov		ebx,MF_GRAYED
				.else
					xor		ebx,ebx
				.endif
				invoke EnableMenuItem,wParam,IDM_EDIT_DELETE,ebx
				invoke EnableMenuItem,wParam,IDM_EDIT_CUT,ebx
				invoke EnableMenuItem,wParam,IDM_EDIT_COPY,ebx
				invoke SendMessage,hResEd,EM_CANPASTE,SF_TEXT,0
				xor		eax,1
				.if eax
					mov		eax,MF_GRAYED
				.endif
				invoke EnableMenuItem,wParam,IDM_EDIT_PASTE,eax
				invoke EnableMenuItem,wParam,IDM_EDIT_FIND,MF_ENABLED
				invoke EnableMenuItem,wParam,IDM_EDIT_REPLACE,MF_ENABLED
			.else
				invoke SendMessage,hResEd,DEM_CANUNDO,0,0
				xor		eax,1
				.if eax
					mov		eax,MF_GRAYED
				.endif
				invoke EnableMenuItem,wParam,IDM_EDIT_UNDO,eax
				invoke SendMessage,hResEd,DEM_CANREDO,0,0
				xor		eax,1
				.if eax
					mov		eax,MF_GRAYED
				.endif
				invoke EnableMenuItem,wParam,IDM_EDIT_REDO,eax
				invoke SendMessage,hResEd,DEM_ISSELECTION,0,0
				.if !eax
					mov		ebx,MF_GRAYED
				.else
					xor		ebx,ebx
				.endif
				invoke EnableMenuItem,wParam,IDM_EDIT_DELETE,ebx
				invoke EnableMenuItem,wParam,IDM_EDIT_CUT,ebx
				invoke EnableMenuItem,wParam,IDM_EDIT_COPY,ebx
				invoke SendMessage,hResEd,DEM_CANPASTE,0,0
				xor		eax,1
				.if eax
					mov		eax,MF_GRAYED
				.endif
				invoke EnableMenuItem,wParam,IDM_EDIT_PASTE,eax
				invoke EnableMenuItem,wParam,IDM_EDIT_FIND,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_EDIT_REPLACE,MF_GRAYED
			.endif
		.elseif eax==2
			;Format
			mov		eax,hResEdSave
			.if !eax
				invoke SendMessage,hResEd,DEM_GETTEXTMODE,0,0
			.endif
			.if eax
				invoke EnableMenuItem,wParam,IDM_FORMAT_LOCK,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_FORMAT_BACK,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_FORMAT_FRONT,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_FORMAT_GRID,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_FORMAT_SNAP,MF_GRAYED
				invoke EnableMenuItem,wParam,6,MF_BYPOSITION or MF_GRAYED
				invoke EnableMenuItem,wParam,7,MF_BYPOSITION or MF_GRAYED
				invoke EnableMenuItem,wParam,8,MF_BYPOSITION or MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_FORMAT_TABINDEX,MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_FORMAT_AUTOID,MF_GRAYED
			.else
				invoke EnableMenuItem,wParam,IDM_FORMAT_LOCK,0
				invoke EnableMenuItem,wParam,IDM_FORMAT_GRID,0
				invoke EnableMenuItem,wParam,IDM_FORMAT_SNAP,0
				invoke SendMessage,hResEd,DEM_ISLOCKED,0,0
				.if eax
					mov		eax,MF_CHECKED
				.endif
				invoke CheckMenuItem,wParam,IDM_FORMAT_LOCK,eax
				invoke GetWindowLong,hResEd,GWL_STYLE
				and		eax,DES_GRID
				.if eax
					mov		eax,MF_CHECKED
				.endif
				invoke CheckMenuItem,wParam,IDM_FORMAT_GRID,eax
				invoke GetWindowLong,hResEd,GWL_STYLE
				and		eax,DES_SNAPTOGRID
				.if eax
					mov		eax,MF_CHECKED
				.endif
				invoke CheckMenuItem,wParam,IDM_FORMAT_SNAP,eax
				invoke SendMessage,hResEd,DEM_ISBACK,0,0
				.if eax
					mov		eax,MF_GRAYED
				.endif
				invoke EnableMenuItem,wParam,IDM_FORMAT_BACK,eax
				invoke SendMessage,hResEd,DEM_ISFRONT,0,0
				.if eax
					mov		eax,MF_GRAYED
				.endif
				invoke EnableMenuItem,wParam,IDM_FORMAT_FRONT,eax
				invoke SendMessage,hResEd,DEM_ISSELECTION,0,0
				push	eax
				.if eax==2
					mov		ebx,MF_BYPOSITION
				.else
					mov		ebx,MF_BYPOSITION or MF_GRAYED
				.endif
				mov		ecx,wParam
				.if ecx==hContextMenuPopup
					mov		edx,14
				.else
					mov		edx,6
				.endif
				push	edx
				; Align
				invoke EnableMenuItem,wParam,edx,ebx
				pop		edx
				inc		edx
				push	edx
				; Same Size
				invoke EnableMenuItem,wParam,edx,ebx
				pop		edx
				inc		edx
				pop		eax
				push	edx
				.if eax>=1
					; Center in Dialog
					invoke EnableMenuItem,wParam,edx,MF_BYPOSITION
				.else
					invoke EnableMenuItem,wParam,edx,MF_BYPOSITION or MF_GRAYED
				.endif
				invoke SendMessage,hResEd,DEM_GETMEM,DEWM_DIALOG,0
				.if eax
					mov		eax,MF_BYPOSITION
				.else
					mov		eax,MF_BYPOSITION or MF_GRAYED
				.endif
				pop		edx
				inc		edx
				push	edx
				; Set Tabindex
				invoke EnableMenuItem,wParam,edx,eax
				pop		edx
				inc		edx
				; Auto Renumber ID's
				invoke EnableMenuItem,wParam,edx,ebx
			.endif
		.elseif eax==3
			;View
			test	wpos.fView,1
			.if !ZERO?
				mov		ebx,MF_BYCOMMAND or MF_CHECKED
			.else
				mov		ebx,MF_BYCOMMAND or MF_UNCHECKED
			.endif
			invoke CheckMenuItem,wParam,IDM_VIEW_OUTPUT,ebx
			.if hPreview
				mov		ebx,MF_BYCOMMAND or MF_CHECKED
			.else
				mov		ebx,MF_BYCOMMAND or MF_UNCHECKED
			.endif
			invoke CheckMenuItem,wParam,IDM_VIEW_PREVIEW,ebx
			.if hResEdSave
				mov		ebx,MF_BYCOMMAND or MF_GRAYED
				invoke EnableMenuItem,wParam,IDM_VIEW_PREVIEW,ebx
				invoke EnableMenuItem,wParam,IDM_VIEW_TEXTMODE,ebx
				mov		ebx,MF_BYCOMMAND or MF_UNCHECKED
				invoke CheckMenuItem,wParam,IDM_VIEW_TEXTMODE,ebx
			.else
				invoke SendMessage,hResEd,DEM_GETMEM,DEWM_DIALOG,0
				.if eax
					mov		ebx,MF_BYCOMMAND
				.else
					mov		ebx,MF_BYCOMMAND or MF_GRAYED
				.endif
				invoke EnableMenuItem,wParam,IDM_VIEW_PREVIEW,ebx
				invoke EnableMenuItem,wParam,IDM_VIEW_TEXTMODE,ebx
				invoke SendMessage,hResEd,DEM_GETTEXTMODE,0,0
				.if eax
					mov		ebx,MF_BYCOMMAND or MF_CHECKED
				.else
					mov		ebx,MF_BYCOMMAND or MF_UNCHECKED
				.endif
				invoke CheckMenuItem,wParam,IDM_VIEW_TEXTMODE,ebx
			.endif
		.elseif eax==4
			;Project
			.if hResEdSave
				mov		ebx,MF_GRAYED
			.else
				invoke SendMessage,hResEd,PRO_GETMEM,0,0
				.if eax
					xor		ebx,ebx
				.else
					mov		ebx,MF_GRAYED
				.endif
			.endif
			invoke EnableMenuItem,wParam,IDM_PROJECT_ADD_DIALOG,ebx
			invoke EnableMenuItem,wParam,IDM_PROJECT_ADD_MENU,ebx
			invoke EnableMenuItem,wParam,IDM_PROJECT_ADD_ACCELERATOR,ebx
			invoke EnableMenuItem,wParam,IDM_PROJECT_ADD_VERSIONINFO,ebx
			invoke EnableMenuItem,wParam,IDM_PROJECT_ADD_STRINGTABLE,ebx
			invoke EnableMenuItem,wParam,IDM_PROJECT_ADD_XPMANIFEST,ebx
			invoke EnableMenuItem,wParam,IDM_PROJECT_ADD_RCDATA,ebx
			invoke EnableMenuItem,wParam,IDM_PROJRCT_ADD_TOOLBAR,ebx
			invoke EnableMenuItem,wParam,IDM_PROJECT_LANGUAGE,ebx
			invoke EnableMenuItem,wParam,IDM_PROJECT_INCLUDE,ebx
			invoke EnableMenuItem,wParam,IDM_PROJECT_RESOURCE,ebx
			invoke EnableMenuItem,wParam,IDM_PROJECT_NAMES,ebx
			invoke EnableMenuItem,wParam,IDM_PROJECT_EXPORT,ebx
			.if hResEdSave
				invoke EnableMenuItem,wParam,IDM_PROJECT_REMOVE,ebx
				invoke EnableMenuItem,wParam,IDM_PROJECT_UNDO,ebx
				invoke EnableMenuItem,wParam,IDM_PROJECT_DLGSAVE,ebx
			.else
				invoke SendMessage,hResEd,PRO_GETSELECTED,0,0
				mov		ebx,MF_GRAYED
				.if eax>=2
					xor		ebx,ebx
				.endif
				invoke EnableMenuItem,wParam,IDM_PROJECT_REMOVE,ebx
				invoke SendMessage,hResEd,PRO_CANUNDO,0,0
				mov		ebx,MF_GRAYED
				.if eax
					xor		ebx,ebx
				.endif
				invoke EnableMenuItem,wParam,IDM_PROJECT_UNDO,ebx
				invoke SendMessage,hResEd,DEM_GETMEM,DEWM_DIALOG,0
				mov		ebx,MF_GRAYED
				.if eax
					xor		ebx,ebx
				.endif
				invoke EnableMenuItem,wParam,IDM_PROJECT_DLGSAVE,ebx
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		edx,lParam
		mov		eax,[edx].NMHDR.hwndFrom
		.if eax==hResEd
			.if !hResEdSave
				invoke SendMessage,hResEd,DEM_GETSHOWDIALOG,0,0
				mov		hPreview,eax
				invoke SendMessage,hResEd,PRO_GETDIALOG,0,0
				mov		hDialog,eax
			.endif
			invoke ToolBarEnable
		.else
			mov		eax,[edx].NMHDR.code
			.if eax==TTN_NEEDTEXT
				;Toolbar tooltip
				mov		edx,(NMHDR ptr [edx]).idFrom
				invoke LoadString,hInstance,edx,addr buffer,sizeof buffer
				lea		eax,buffer
				mov		edx,lParam
				mov		(TOOLTIPTEXT ptr [edx]).lpszText,eax
			.endif
		.endif
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		movzx	eax,ax
		.if eax==IDM_FILE_NEW_PROJECT
			invoke WantToSaveProject,offset ProjectFileName
			.if !eax
				invoke CloseProject
				invoke lstrcpy,offset ProjectFileName,offset szNewFile
				mov		IncludeFileName,0
				invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,4096
				mov		hMem,eax
				invoke GlobalLock,hMem
				invoke SendMessage,hResEd,PRO_OPEN,offset ProjectFileName,hMem
				invoke SetWinCaption,offset ProjectFileName
				invoke SaveProjectFile,offset ProjectFileName,FALSE
				.if !eax
					invoke SendMessage,hResEd,PRO_CLOSE,0,0
					invoke SetWinCaption,NULL
				.else
					invoke SendMessage,hResEd,PRO_CLOSE,0,0
					invoke ReadProjectFile,offset ProjectFileName,FALSE
				.endif
			.endif
		.elseif eax==IDM_FILE_OPEN_PROJECT
			invoke WantToSaveProject,offset ProjectFileName
			.if !eax
				invoke OpenProject,FALSE
			.endif
		.elseif eax==IDM_FILE_OPEN_TEXT
			invoke WantToSaveProject,offset ProjectFileName
			.if !eax
				invoke OpenProject,TRUE
			.endif
		.elseif eax==IDM_FILE_CLOSE_PROJECT
			invoke WantToSaveProject,offset ProjectFileName
			.if !eax
				invoke CloseProject
			.endif
			invoke ToolBarEnable
		.elseif eax==IDM_FILE_SAVE_PROJECT
			invoke SaveProjectFile,offset ProjectFileName,hResEdSave
		.elseif eax==IDM_FILE_SAVE_PROJECT_AS
			invoke SaveProjectFileAs,offset ProjectFileName,hResEdSave
		.elseif eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDM_EDIT_UNDO
			.if hResEdSave
				invoke SendMessage,hResEd,EM_UNDO,0,0
			.else
				invoke SendMessage,hResEd,DEM_UNDO,0,0
			.endif
		.elseif eax==IDM_EDIT_REDO
			.if hResEdSave
				invoke SendMessage,hResEd,EM_REDO,0,0
			.else
				invoke SendMessage,hResEd,DEM_REDO,0,0
			.endif
		.elseif eax==IDM_EDIT_DELETE
			.if hResEdSave
				invoke SendMessage,hResEd,EM_REPLACESEL,TRUE,addr szNULL
			.else
				invoke SendMessage,hResEd,DEM_DELETECONTROLS,0,0
			.endif
		.elseif eax==IDM_EDIT_CUT
			.if hResEdSave
				invoke SendMessage,hResEd,WM_CUT,0,0
			.else
				invoke SendMessage,hResEd,DEM_CUT,0,0
			.endif
		.elseif eax==IDM_EDIT_COPY
			.if hResEdSave
				invoke SendMessage,hResEd,WM_COPY,0,0
			.else
				invoke SendMessage,hResEd,DEM_COPY,0,0
			.endif
		.elseif eax==IDM_EDIT_PASTE
			.if hResEdSave
				invoke SendMessage,hResEd,WM_PASTE,0,0
			.else
				invoke SendMessage,hResEd,DEM_PASTE,0,0
			.endif
		.elseif eax==IDM_EDIT_FIND
			invoke CreateDialogParam,hInstance,IDD_FINDDLG,hWin,offset FindDlgProc,0
			mov		hFind,eax
		.elseif eax==IDM_EDIT_REPLACE
			invoke CreateDialogParam,hInstance,IDD_FINDDLG,hWin,offset FindDlgProc,1
			mov		hFind,eax
		.elseif eax==IDM_VIEW_OUTPUT
			xor		wpos.fView,1
			mov		eax,wpos.fView
			and		eax,1
			invoke SendMessage,hResEd,DEM_SHOWOUTPUT,eax,0
			invoke ToolBarEnable
		.elseif eax==IDM_VIEW_PREVIEW
			invoke SendMessage,hResEd,DEM_SHOWDIALOG,0,0
		.elseif eax==IDM_VIEW_TEXTMODE
			invoke SendMessage,hResEd,DEM_GETTEXTMODE,0,0
			xor		eax,1
			invoke SendMessage,hResEd,DEM_SETTEXTMODE,eax,0
		.elseif eax==IDM_FORMAT_LOCK
			invoke SendMessage,hResEd,DEM_ISLOCKED,0,0
			xor		eax,TRUE
			invoke SendMessage,hResEd,DEM_LOCKCONTROLS,0,eax
		.elseif eax==IDM_FORMAT_BACK
			invoke SendMessage,hResEd,DEM_SENDTOBACK,0,0
		.elseif eax==IDM_FORMAT_FRONT
			invoke SendMessage,hResEd,DEM_BRINGTOFRONT,0,0
		.elseif eax==IDM_FORMAT_GRID
			invoke GetWindowLong,hResEd,GWL_STYLE
			xor		eax,DES_GRID
			invoke SetWindowLong,hResEd,GWL_STYLE,eax
		.elseif eax==IDM_FORMAT_SNAP
			invoke GetWindowLong,hResEd,GWL_STYLE
			xor		eax,DES_SNAPTOGRID
			invoke SetWindowLong,hResEd,GWL_STYLE,eax
		.elseif eax==IDM_FORMAT_ALIGN_LEFT
			invoke SendMessage,hResEd,DEM_ALIGNSIZE,0,ALIGN_LEFT
		.elseif eax==IDM_FORMAT_ALIGN_CENTER
			invoke SendMessage,hResEd,DEM_ALIGNSIZE,0,ALIGN_CENTER
		.elseif eax==IDM_FORMAT_ALIGN_RIGHT
			invoke SendMessage,hResEd,DEM_ALIGNSIZE,0,ALIGN_RIGHT
		.elseif eax==IDM_FORMAT_ALIGN_TOP
			invoke SendMessage,hResEd,DEM_ALIGNSIZE,0,ALIGN_TOP
		.elseif eax==IDM_FORMAT_ALIGN_MIDDLE
			invoke SendMessage,hResEd,DEM_ALIGNSIZE,0,ALIGN_MIDDLE
		.elseif eax==IDM_FORMAT_ALIGN_BOTTOM
			invoke SendMessage,hResEd,DEM_ALIGNSIZE,0,ALIGN_BOTTOM
		.elseif eax==IDM_FORMAT_SIZE_WIDTH
			invoke SendMessage,hResEd,DEM_ALIGNSIZE,0,SIZE_WIDTH
		.elseif eax==IDM_FORMAT_SIZE_HEIGHT
			invoke SendMessage,hResEd,DEM_ALIGNSIZE,0,SIZE_HEIGHT
		.elseif eax==IDM_FORMAT_SIZE_BOTH
			invoke SendMessage,hResEd,DEM_ALIGNSIZE,0,SIZE_BOTH
		.elseif eax==IDM_FORMAT_ALIGN_DLGHCENTER
			invoke SendMessage,hResEd,DEM_ALIGNSIZE,0,ALIGN_DLGHCENTER
		.elseif eax==IDM_FORMAT_ALIGN_DLGVCENTER
			invoke SendMessage,hResEd,DEM_ALIGNSIZE,0,ALIGN_DLGVCENTER
		.elseif eax==IDM_FORMAT_TABINDEX
			invoke SendMessage,hResEd,DEM_SHOWTABINDEX,0,0
		.elseif eax==IDM_FORMAT_AUTOID
			invoke SendMessage,hResEd,DEM_AUTOID,0,0
		.elseif eax==IDM_PROJECT_ADD_DIALOG
			invoke SendMessage,hResEd,PRO_ADDITEM,TPE_DIALOG,TRUE
		.elseif eax==IDM_PROJECT_ADD_MENU
			invoke SendMessage,hResEd,PRO_ADDITEM,TPE_MENU,TRUE
		.elseif eax==IDM_PROJECT_ADD_ACCELERATOR
			invoke SendMessage,hResEd,PRO_ADDITEM,TPE_ACCEL,TRUE
		.elseif eax==IDM_PROJECT_ADD_VERSIONINFO
			invoke SendMessage,hResEd,PRO_ADDITEM,TPE_VERSION,TRUE
		.elseif eax==IDM_PROJECT_ADD_STRINGTABLE
			invoke SendMessage,hResEd,PRO_ADDITEM,TPE_STRING,TRUE
		.elseif eax==IDM_PROJECT_ADD_XPMANIFEST
			invoke SendMessage,hResEd,PRO_ADDITEM,TPE_XPMANIFEST,TRUE
		.elseif eax==IDM_PROJECT_ADD_RCDATA
			invoke SendMessage,hResEd,PRO_ADDITEM,TPE_RCDATA,TRUE
		.elseif eax==IDM_PROJRCT_ADD_TOOLBAR
			invoke SendMessage,hResEd,PRO_ADDITEM,TPE_TOOLBAR,TRUE
		.elseif eax==IDM_PROJECT_LANGUAGE
			invoke SendMessage,hResEd,PRO_ADDITEM,TPE_LANGUAGE,TRUE
		.elseif eax==IDM_PROJECT_INCLUDE
			invoke SendMessage,hResEd,PRO_ADDITEM,TPE_INCLUDE,TRUE
		.elseif eax==IDM_PROJECT_RESOURCE
			invoke SendMessage,hResEd,PRO_ADDITEM,TPE_RESOURCE,TRUE
		.elseif eax==IDM_PROJECT_NAMES
			invoke SendMessage,hResEd,PRO_SHOWNAMES,0,0
		.elseif eax==IDM_PROJECT_REMOVE
			invoke SendMessage,hResEd,PRO_DELITEM,0,0
		.elseif eax==IDM_PROJECT_UNDO
			invoke SendMessage,hResEd,PRO_UNDODELETED,0,0
		.elseif eax==IDM_PROJECT_EXPORT
			invoke SendMessage,hResEd,PRO_EXPORTNAMES,0,0
		.elseif eax==IDM_PROJECT_DLGSAVE
			invoke ExportDialog
		.elseif eax==IDM_OPTION_TOOLS
			invoke DialogBoxParam,hInstance,IDD_DLGOPTMNU,hWin,offset MenuOptionProc,1
			invoke ResetMenu
		.elseif eax==IDM_OPTION_HELP
			invoke DialogBoxParam,hInstance,IDD_DLGOPTMNU,hWin,offset MenuOptionProc,2
			invoke ResetMenu
		.elseif eax==IDM_OPTION_OPTIONS
			invoke DialogBoxParam,hInstance,IDD_TABOPTIONS,hWin,offset TabOptionsProc,0
		.elseif eax==IDM_TOOLS_CLEAR
			invoke MessageBox,hWin,addr szClearMRU,addr szAppName,MB_OKCANCEL or MB_ICONQUESTION
			.if eax==IDOK
				invoke ClearMruProject
			.endif
		.elseif eax==IDM_HELP_ABOUT
			invoke DialogBoxParam,hInstance,IDD_DLGABOUT,hWin,offset AboutProc,0
		.elseif eax>=20000 && eax<=20020
			;Tool
			mov		mnu.szcap,0
			mov		mnu.szcmnd,0
			mov		edx,eax
			sub		edx,19999
			invoke MakeKey,addr szMenuTool,edx,addr buffer
			mov		lpcbData,sizeof mnu
			invoke RegQueryValueEx,hReg,addr buffer,0,addr lpType,addr mnu,addr lpcbData
			movzx	eax,mnu.szcmnd
			.if eax
				invoke ParseCmnd,addr mnu.szcmnd,addr buffer,addr buffer1
				invoke ShellExecute,hWin,NULL,addr buffer,addr buffer1,NULL,SW_SHOWNORMAL
			.endif
		.elseif eax>=30000 && eax<=30020
			;Help
			mov		mnu.szcap,0
			mov		mnu.szcmnd,0
			mov		edx,eax
			sub		edx,29999
			invoke MakeKey,addr szMenuHelp,edx,addr buffer
			mov		lpcbData,sizeof mnu
			invoke RegQueryValueEx,hReg,addr buffer,0,addr lpType,addr mnu,addr lpcbData
			movzx	eax,mnu.szcmnd
			.if eax
				invoke ParseCmnd,addr mnu.szcmnd,addr buffer,addr buffer1
				invoke ShellExecute,hWin,NULL,addr buffer,addr buffer1,NULL,SW_SHOWNORMAL
			.endif
		.elseif eax>=21000 && eax<=21009
			;MRU
			sub		eax,21000
			mov		ecx,MAX_PATH*2
			mul		ecx
			mov		ebx,offset mruproject
			add		ebx,eax
			invoke WantToSaveProject,offset ProjectFileName
			.if !eax
				invoke lstrcpy,addr buffer,ebx
				invoke GetStrItem,addr buffer,offset ProjectFileName
				invoke lstrcpy,offset IncludeFileName,addr buffer
				invoke ReadProjectFile,addr ProjectFileName,FALSE
			.endif
		.endif
	.elseif eax==WM_SIZE
		;Statusbar
		invoke GetDlgItem,hWin,IDC_SBR1
		push	eax
		invoke MoveWindow,eax,0,0,0,0,FALSE
		pop		edx
		invoke GetWindowRect,edx,addr rect
		mov		ebx,rect.bottom
		sub		ebx,rect.top
		mov		eax,lParam
		movzx	edx,ax
		shr		eax,16
		mov		pt.x,edx
		mov		pt.y,eax
		;ToolBar
		invoke GetDlgItem,hWin,IDC_TBR1
		invoke MoveWindow,eax,0,0,pt.x,25,TRUE
		mov		ecx,pt.x
		mov		edx,pt.y
		sub		edx,25
		sub		edx,ebx
		invoke MoveWindow,hResEd,0,25,ecx,edx,TRUE
	.elseif eax==WM_CLOSE
		invoke SetFocus,hResEd
		invoke WantToSaveProject,offset ProjectFileName
		.if !eax
			invoke SendMessage,hResEd,PRO_CLOSE,0,0
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
		invoke SendMessage,hResEd,DEM_GETSIZE,0,addr winsize
		mov		eax,winsize.htpro
		mov		wpos.htpro,eax
		mov		eax,winsize.wtpro
		mov		wpos.wtpro,eax
		mov		eax,winsize.htout
		mov		wpos.htout,eax
		mov		eax,winsize.wttbx
		mov		wpos.wttbx,eax
		mov		eax,winsize.ptstyle.x
		mov		wpos.left,eax
		mov		eax,winsize.ptstyle.y
		mov		wpos.top,eax
		.if hMnuFont
			invoke DeleteObject,hMenuBrushA
			invoke DeleteObject,hMenuBrushB
			invoke DeleteObject,hMnuFont
		.endif
		invoke DestroyIcon,hIcon
		invoke ImageList_Destroy,hIml
		invoke ImageList_Destroy,hImlTbr
		invoke ImageList_Destroy,hImlTbrGray
		invoke DestroyAcceleratorTable,hAccel
		invoke DestroyMenu,hContextMenu
		invoke DestroyWindow,hResEd
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
		invoke PostQuitMessage,NULL
	.elseif eax==WM_DROPFILES
		invoke DragQueryFile,wParam,0,addr buffer,sizeof buffer
		invoke WantToSaveProject,offset ProjectFileName
		.if !eax
			invoke ReadProjectFile,addr buffer,FALSE
		.endif
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
					invoke SelectObject,mDC,hMnuFont
					push	eax
					mov		rect.left,0
					mov		rect.top,0
					invoke DrawText,mDC,esi,-1,addr rect,DT_CALCRECT or DT_SINGLELINE
					mov		eax,rect.right
					mov		[ebx].MEASUREITEMSTRUCT.itemWidth,eax
					invoke lstrlen,esi
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
				invoke SelectObject,mDC,hMnuFont
				push	eax
				invoke GetStockObject,WHITE_BRUSH
				invoke FillRect,mDC,addr rect,eax
				invoke FillRect,mDC,addr rect,hMenuBrushB
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
						invoke ImageList_Draw,hImlTbr,11,mDC,2,edx,ILD_TRANSPARENT
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
								invoke ImageList_Draw,hImlTbr,eax,mDC,2,edx,ILD_TRANSPARENT
							.else
								invoke ImageList_Draw,hImlTbrGray,eax,mDC,2,edx,ILD_TRANSPARENT
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
					invoke lstrlen,esi
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
	.else
  ExDef:
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		jmp		ExRet
	.endif
  Ex:
	xor    eax,eax
  ExRet:
	ret

WndProc endp

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize,SIZEOF WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,OFFSET WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,10000
	mov		wc.lpszClassName,OFFSET szDlgClass
	invoke LoadIcon,hInst,IDI_ICON
	mov		hIcon,eax
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_DIALOG,NULL,addr WndProc,NULL
	.if wpos.fMax
		mov		eax,SW_MAXIMIZE
	.else
		mov		eax,SW_SHOWNORMAL
	.endif
	invoke ShowWindow,hWnd,eax
	invoke UpdateWindow,hWnd
	;Get command line filename
	mov		eax,CommandLine
	.if byte ptr [eax]
		invoke ReadProjectFile,eax,FALSE
	.endif
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke IsDialogMessage,hPreview,addr msg
		.if !eax
			invoke IsDialogMessage,hDialog,addr msg
			.if !eax
				invoke IsDialogMessage,hFind,addr msg
				.if !eax
					invoke TranslateAccelerator,hWnd,hAccel,addr msg
					.if !eax
						invoke TranslateMessage,addr msg
						invoke DispatchMessage,addr msg
					.endif
				.endif
			.endif
		.endif
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke LoadLibrary,offset szRichEdit
	mov		hRichEd,eax
	invoke GridInstall,hInstance,FALSE
	invoke InstallRAEdit,hInstance,FALSE
	invoke ResEdInstall,hInstance,FALSE
	invoke GetCommandLine
	mov		CommandLine,eax
	;Get command line filename
	invoke PathGetArgs,CommandLine
	mov		CommandLine,eax
  @@:
	mov		dl,[eax]
	.if dl==VK_SPACE
		inc		eax
		jmp		@b
	.elseif dl=='"'
		invoke PathUnquoteSpaces,eax
	.endif
	mov		CommandLine,eax
	invoke InitCommonControls
	;prepare common control structure
	mov		icex.dwSize,sizeof INITCOMMONCONTROLSEX
	mov		icex.dwICC,ICC_DATE_CLASSES or ICC_USEREX_CLASSES or ICC_INTERNET_CLASSES or ICC_ANIMATE_CLASS or ICC_HOTKEY_CLASS or ICC_PAGESCROLLER_CLASS or ICC_COOL_CLASSES
	invoke InitCommonControlsEx,addr icex
	invoke RegCreateKeyEx,HKEY_CURRENT_USER,addr szResEd,0,addr szREG_SZ,0,KEY_WRITE or KEY_READ,0,addr hReg,addr lpdwDisp
	.if lpdwDisp==REG_OPENED_EXISTING_KEY
		mov		lpcbData,sizeof wpos
		invoke RegQueryValueEx,hReg,addr szWinPos,0,addr lpType,addr wpos,addr lpcbData
		mov		lpcbData,sizeof nmeexp
		invoke RegQueryValueEx,hReg,addr szNmeExp,0,addr lpType,addr nmeexp,addr lpcbData
		mov		lpcbData,sizeof grdsize
		invoke RegQueryValueEx,hReg,addr szGrid,0,addr lpType,addr grdsize,addr lpcbData
		mov		lpcbData,sizeof col
		invoke RegQueryValueEx,hReg,addr szColor,0,addr lpType,addr col,addr lpcbData
		mov		lpcbData,sizeof initid
		invoke RegQueryValueEx,hReg,addr szInitID,0,addr lpType,addr initid,addr lpcbData
		mov		lpcbData,sizeof textfont
		invoke RegQueryValueEx,hReg,addr szTextFont,0,addr lpType,addr textfont,addr lpcbData
		mov		lpcbData,sizeof ProjectPath
		invoke RegQueryValueEx,hReg,addr szProPath,0,addr lpType,addr ProjectPath,addr lpcbData
		mov		lpcbData,sizeof SystemPath
		invoke RegQueryValueEx,hReg,addr szSysPath,0,addr lpType,addr SystemPath,addr lpcbData
	.endif
	.if wpos.wtpro<5
		mov		wpos.wtpro,150
	.endif
	.if wpos.htpro<5
		mov		wpos.htpro,200
	.endif
	mov		eax,wpos.htout
	mov		winsize.htout,eax
	mov		eax,wpos.wtpro
	mov		winsize.wtpro,eax
	mov		eax,wpos.htpro
	mov		winsize.htpro,eax
	mov		eax,wpos.wttbx
	.if !eax
		mov		eax,52
	.endif
	mov		winsize.wttbx,eax
	mov		eax,wpos.left
	mov		winsize.ptstyle.x,eax
	mov		eax,wpos.top
	mov		winsize.ptstyle.y,eax
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	invoke RegSetValueEx,hReg,addr szWinPos,0,REG_BINARY,addr wpos,sizeof wpos
	xor		ecx,ecx
	mov		edx,offset mruproject
	.while ecx<10
		push	ecx
		push	edx
		push	edx
		invoke MakeKey,addr szMruProject,ecx,addr tmpbuff
		pop		edx
		.if byte ptr [edx]
			invoke RegSetValueEx,hReg,addr tmpbuff,0,REG_SZ,edx,MAX_PATH*2
		.else
			invoke RegDeleteValue,hReg,addr tmpbuff
		.endif
		pop		edx
		pop		ecx
		add		edx,MAX_PATH*2
		inc		ecx
	.endw
	invoke RegCloseKey,hReg
	invoke ResEdUninstall
	invoke UnInstallRAEdit
	.if hRichEd
		invoke FreeLibrary,hRichEd
	.endif
	invoke ExitProcess,0

end start
