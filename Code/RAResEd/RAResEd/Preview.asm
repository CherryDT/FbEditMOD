
MyDLGTEMPLATE struct
	style			DWORD	?
	dwExtendedStyle	DWORD	?
	cdit			WORD	?
	x				WORD	?
	y				WORD	?
	lx				WORD	?
	ly				WORD	?
MyDLGTEMPLATE ends

MyDLGITEMTEMPLATE struct
	style			DWORD	?
	dwExtendedStyle	DWORD	?
	x				WORD	?
	y				WORD	?
	lx				WORD	?
	cy				WORD	?
	id				WORD	?
MyDLGITEMTEMPLATE ends

MyDLGTEMPLATEEX struct
	dlgVer			WORD	?
	signature		WORD	?
	helpID			DWORD	?
	exStyle			DWORD	?
	style			DWORD	?
	cDlgItems		WORD	?
	x				WORD	?
	y				WORD	?
	ccx				WORD	?
	ccy				WORD	?
	menu			WORD	?
MyDLGTEMPLATEEX ends

MyDLGITEMTEMPLATEEX struct
	helpID			DWORD ?
	exStyle			DWORD	?
	style			DWORD	?
	x				WORD	?
	y				WORD	?
	ccx				WORD	?
	ccy				WORD	?
	id				DWORD	?
MyDLGITEMTEMPLATEEX ends

.data?

hDlg				dd ?
pDlgMem				dd ?
hDlgMnu				dd ?

.code

PrevTestProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetClientRect,hWin,addr rect
		mov		eax,rect.right
		mov		fntwt,eax
		mov		eax,rect.bottom
		mov		fntht,eax
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

PrevTestProc endp

PrevDo_TreeViewAddNode proc	hWin:HWND,lhPar:DWORD,lhInsAfter:DWORD,pszText:DWORD,pidSel:DWORD
	LOCAL	tvins:TV_INSERTSTRUCT

	mov		eax,lhPar
	mov		tvins.hParent,eax
	mov		eax,lhInsAfter
	mov		tvins.hInsertAfter,eax
	mov		tvins.item._mask,TVIF_TEXT or TVIF_IMAGE or	TVIF_SELECTEDIMAGE
	mov		eax,pszText
	mov		tvins.item.pszText,eax
	mov		eax,pidSel
	mov		tvins.item.iImage,eax
	mov		tvins.item.iSelectedImage,eax
	invoke SendMessage,hWin,TVM_INSERTITEM,0,addr tvins
	ret

PrevDo_TreeViewAddNode endp

DlgEnumProc proc uses esi,hWin:HWND,lParam:LPARAM
	LOCAL	tci:TCITEM
	LOCAL	lvi:LVITEM
	LOCAL	tbb:TBBUTTON
	LOCAL	tbab:TBADDBITMAP
	LOCAL	cbei:COMBOBOXEXITEM
	LOCAL	hdi:HD_ITEM
	LOCAL	buffer[MAX_PATH]

	invoke GetParent,hWin
	.if eax==lParam
		invoke GetCtrlMem,hWin
		mov		esi,eax
		mov		eax,[esi].DIALOG.ntypeid
		.if eax==7
			;ComboBox
			invoke SendMessage,hWin,CB_ADDSTRING,0,addr [esi].DIALOG.idname
			invoke SendMessage,hWin,CB_SETCURSEL,0,0
		.elseif eax==8
			;ListBox
			invoke SendMessage,hWin,LB_ADDSTRING,0,addr [esi].DIALOG.idname
		.elseif eax==11
			;TabControl
			mov		tci.imask,TCIF_TEXT
			lea		eax,[esi].DIALOG.idname
			mov		tci.pszText,eax
			mov		tci.cchTextMax,0
			invoke SendMessage,hWin,TCM_INSERTITEM,0,addr tci
			invoke SendMessage,hWin,TCM_INSERTITEM,1,addr tci
		.elseif eax==12
			;ProgressBar
			invoke SendMessage,hWin,PBM_STEPIT,0,0
			invoke SendMessage,hWin,PBM_STEPIT,0,0
			invoke SendMessage,hWin,PBM_STEPIT,0,0
		.elseif eax==13
			;TreeView
			invoke SendMessage,hWin,TVM_SETIMAGELIST,0,hPrjIml
			invoke PrevDo_TreeViewAddNode,hWin,TVI_ROOT,NULL,addr [esi].DIALOG.idname,0
			mov		edx,eax
			push	eax
			invoke PrevDo_TreeViewAddNode,hWin,edx,NULL,addr [esi].DIALOG.idname,1
			mov		edx,eax
			push	eax
			invoke PrevDo_TreeViewAddNode,hWin,edx,NULL,addr [esi].DIALOG.idname,2
			pop		eax
			invoke SendMessage,hWin,TVM_EXPAND,TVE_EXPAND,eax
			pop		eax
			invoke SendMessage,hWin,TVM_EXPAND,TVE_EXPAND,eax
		.elseif eax==14
			;ListView
			invoke SendMessage,hWin,LVM_SETCOLUMNWIDTH,-1,LVSCW_AUTOSIZE
			invoke SendMessage,hWin,LVM_SETIMAGELIST,LVSIL_SMALL,hPrjIml
			mov		lvi.imask,LVIF_TEXT or LVIF_IMAGE
			mov		lvi.iItem,0
			mov		lvi.iSubItem,0
			lea		eax,[esi].DIALOG.idname
			mov		lvi.pszText,eax
			mov		lvi.cchTextMax,0
			mov		lvi.iImage,0
			invoke SendMessage,hWin,LVM_INSERTITEM,0,addr lvi
			mov		lvi.iItem,1
			mov		lvi.iImage,1
			invoke SendMessage,hWin,LVM_INSERTITEM,0,addr lvi
			mov		lvi.iItem,2
			mov		lvi.iImage,2
			invoke SendMessage,hWin,LVM_INSERTITEM,0,addr lvi
		.elseif eax==17
			;Image
			invoke GetWindowLong,hWin,GWL_STYLE
			and		eax,SS_TYPEMASK
			.if eax==SS_BITMAP
				.if [esi].DIALOG.caption
					mov		eax,[esi].DIALOG.himg
					.if !eax
						push	ebx
						push	edi
						invoke GetWindowLong,hPrj,0
						mov		edi,eax
						.while [edi].PROJECT.hmem
							.if [edi].PROJECT.ntype==TPE_RESOURCE
								mov		ebx,[edi].PROJECT.hmem
								.while [ebx].RESOURCEMEM.szname || [ebx].RESOURCEMEM.value
									.if [ebx].RESOURCEMEM.ntype==0
										invoke strcmp,addr [esi].DIALOG.caption,addr [ebx].RESOURCEMEM.szname
										.if eax
											mov		buffer,'#'
											invoke ResEdBinToDec,[ebx].RESOURCEMEM.value,addr buffer[1]
											invoke strcmp,addr [esi].DIALOG.caption,addr buffer
										.endif
										.if !eax
											mov		ax,word ptr [ebx].RESOURCEMEM.szfile
											.if ah!=':'
												invoke strcpy,addr buffer,addr szProjectPath
												invoke strcat,addr buffer,addr szBS
												invoke strcat,addr buffer,addr [ebx].RESOURCEMEM.szfile
											.else
												invoke strcpy,addr buffer,addr [ebx].RESOURCEMEM.szfile
											.endif
											mov		eax,TRUE
											jmp		BitmapFound
										.endif
									.endif
									lea		ebx,[ebx+sizeof RESOURCEMEM]
								.endw
							.endif
							lea		edi,[edi+sizeof PROJECT]
						.endw
						xor		eax,eax
					  BitmapFound:
						pop		edi
						pop		ebx
						.if eax
							invoke LoadImage,NULL,addr buffer,IMAGE_BITMAP,NULL,NULL,LR_LOADFROMFILE
							mov		[esi].DIALOG.himg,eax
						.else
							invoke LoadBitmap,hInstance,100
						.endif
					.endif
				.else
					invoke LoadBitmap,hInstance,100
				.endif
				invoke SendMessage,hWin,STM_SETIMAGE,IMAGE_BITMAP,eax
			.elseif eax==SS_ICON
				.if [esi].DIALOG.caption
					mov		eax,[esi].DIALOG.himg
					.if !eax
						push	ebx
						push	edi
						invoke GetWindowLong,hPrj,0
						mov		edi,eax
						.while [edi].PROJECT.hmem
							.if [edi].PROJECT.ntype==TPE_RESOURCE
								mov		ebx,[edi].PROJECT.hmem
								.while [ebx].RESOURCEMEM.szname || [ebx].RESOURCEMEM.value
									.if [ebx].RESOURCEMEM.ntype==2
										invoke strcmp,addr [esi].DIALOG.caption,addr [ebx].RESOURCEMEM.szname
										.if eax
											mov		buffer,'#'
											invoke ResEdBinToDec,[ebx].RESOURCEMEM.value,addr buffer[1]
											invoke strcmp,addr [esi].DIALOG.caption,addr buffer
										.endif
										.if !eax
											mov		ax,word ptr [ebx].RESOURCEMEM.szfile
											.if ah!=':'
												invoke strcpy,addr buffer,addr szProjectPath
												invoke strcat,addr buffer,addr szBS
												invoke strcat,addr buffer,addr [ebx].RESOURCEMEM.szfile
											.else
												invoke strcpy,addr buffer,addr [ebx].RESOURCEMEM.szfile
											.endif
											mov		eax,TRUE
											jmp		IconFound
										.endif
									.endif
									lea		ebx,[ebx+sizeof RESOURCEMEM]
								.endw
							.endif
							lea		edi,[edi+sizeof PROJECT]
						.endw
						xor		eax,eax
					  IconFound:
						pop		edi
						pop		ebx
						.if eax
							invoke LoadImage,NULL,addr buffer,IMAGE_ICON,NULL,NULL,LR_LOADFROMFILE
							mov		[esi].DIALOG.himg,eax
						.else
							invoke LoadIcon,0,IDI_WINLOGO
						.endif
					.endif
				.else
					invoke LoadIcon,0,IDI_WINLOGO
				.endif
				invoke SendMessage,hWin,STM_SETIMAGE,IMAGE_ICON,eax
			.endif
		.elseif eax==18
			;ToolBar
			invoke SendMessage,hWin,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
			invoke SendMessage,hWin,TB_SETBUTTONSIZE,0,00100010h
			invoke SendMessage,hWin,TB_SETBITMAPSIZE,0,00100010h
			mov		tbab.hInst,HINST_COMMCTRL
			mov		tbab.nID,IDB_STD_SMALL_COLOR
			invoke SendMessage,hWin,TB_ADDBITMAP,12,addr tbab
			mov		tbb.fsState,TBSTATE_ENABLED
			mov		tbb.dwData,0
			mov		tbb.iString,0
			mov		tbb.iBitmap,0
			mov		tbb.idCommand,0
			mov		tbb.fsStyle,TBSTYLE_SEP
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
			mov		tbb.iBitmap,0
			mov		tbb.idCommand,1
			mov		tbb.fsStyle,TBSTYLE_BUTTON
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
			mov		tbb.iBitmap,1
			mov		tbb.idCommand,2
			mov		tbb.fsStyle,TBSTYLE_BUTTON
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
			mov		tbb.iBitmap,2
			mov		tbb.idCommand,3
			mov		tbb.fsStyle,TBSTYLE_BUTTON
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
			mov		tbb.iBitmap,0
			mov		tbb.idCommand,0
			mov		tbb.fsStyle,TBSTYLE_SEP
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
			mov		tbb.iBitmap,3
			mov		tbb.idCommand,4
			mov		tbb.fsStyle,TBSTYLE_BUTTON
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
			mov		tbb.iBitmap,4
			mov		tbb.idCommand,5
			mov		tbb.fsStyle,TBSTYLE_BUTTON
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
			mov		tbb.iBitmap,0
			mov		tbb.idCommand,0
			mov		tbb.fsStyle,TBSTYLE_SEP
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
		.elseif eax==24
			;ImageCombo
			invoke SendMessage,hWin,CBEM_SETIMAGELIST,0,hPrjIml
			mov		cbei._mask,CBEIF_IMAGE or CBEIF_TEXT or CBEIF_SELECTEDIMAGE
			mov		cbei.iItem,0
			lea		eax,[esi].DIALOG.idname
			mov		cbei.pszText,eax
			mov		cbei.cchTextMax,32
			mov		cbei.iImage,0
			mov		cbei.iSelectedImage,0
			invoke SendMessage,hWin,CBEM_INSERTITEM,0,addr cbei
			mov		cbei.iItem,1
			mov		cbei.iImage,1
			mov		cbei.iSelectedImage,1
			invoke SendMessage,hWin,CBEM_INSERTITEM,0,addr cbei
			invoke SendMessage,hWin,CB_SETCURSEL,0,0
		.elseif eax==26
			;IPAddress
			invoke SendMessage,hWin,IPM_SETADDRESS,0,080818283h
		.elseif eax==27
			;Animate
			.if [esi].DIALOG.caption
				push	ebx
				push	edi
				invoke GetWindowLong,hPrj,0
				mov		edi,eax
				.while [edi].PROJECT.hmem
					.if [edi].PROJECT.ntype==TPE_RESOURCE
						mov		ebx,[edi].PROJECT.hmem
						.while [ebx].RESOURCEMEM.szname || [ebx].RESOURCEMEM.value
							.if [ebx].RESOURCEMEM.ntype==3
								invoke strcmp,addr [esi].DIALOG.caption,addr [ebx].RESOURCEMEM.szname
								.if eax
									mov		buffer,'#'
									invoke ResEdBinToDec,[ebx].RESOURCEMEM.value,addr buffer[1]
									invoke strcmp,addr [esi].DIALOG.caption,addr buffer
								.endif
								.if !eax
									invoke SendMessage,hWin,ACM_OPEN,0,addr [ebx].RESOURCEMEM.szfile
									jmp		AviFound
								.endif
							.endif
							lea		ebx,[ebx+sizeof RESOURCEMEM]
						.endw
					.endif
					lea		edi,[edi+sizeof PROJECT]
					xor		eax,eax
				.endw
			  AviFound:
				pop		edi
				pop		ebx
			.endif
		.elseif eax==28
			;HotKey
			invoke SendMessage,hWin,HKM_SETHOTKEY,(HOTKEYF_CONTROL shl 8) or VK_A,0
		.elseif eax==31
			;Rebar
		.elseif eax==32
			;Header
			mov		hdi.imask,HDI_TEXT or HDI_WIDTH or HDI_FORMAT
			mov		hdi.lxy,100
			lea		eax,[esi].DIALOG.idname
			mov		hdi.pszText,eax
			mov		hdi.fmt,HDF_STRING
			invoke SendMessage,hWin,HDM_INSERTITEM,0,addr hdi
		.elseif eax==33
			;SysLink
		.elseif eax>=34
			invoke SendMessage,hWin,WM_USER+9999,0,0
		.endif
	.endif
	mov		eax,TRUE
	ret

DlgEnumProc endp

DlgEnumDelProc proc hWin:HWND,lParam:LPARAM

	invoke GetParent,hWin
	.if eax==hDlg
		invoke GetWindowLong,hWin,GWL_USERDATA
		.if eax
			invoke DeleteObject,eax
		.endif
	.endif
	mov		eax,TRUE
	ret

DlgEnumDelProc endp

PrevDlgProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_CLOSE
		.if hDlgMnu
			invoke DestroyMenu,hDlgMnu
			mov		hDlgMnu,0
		.endif
		invoke EnumChildWindows,hWin,addr DlgEnumDelProc,0
		invoke DestroyWindow,hWin
		mov		hPreview,0
		invoke NotifyParent
	.elseif eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hDlg,eax
		.if hDlgMnu
			invoke GetMenu,hWin
			invoke DestroyMenu,eax
			invoke SetMenu,hWin,hDlgMnu
		.endif
		invoke GetWindowRect,hWin,addr rect
		mov		eax,pDlgMem
		add		eax,sizeof DLGHEAD
		test	[eax].DIALOG.style,WS_CAPTION
		.if ZERO?
			invoke GetSystemMetrics,SM_CYCAPTION
			push	eax
			invoke GetSystemMetrics,SM_CYDLGFRAME
			push	eax
			invoke GetSystemMetrics,SM_CXDLGFRAME
			push	eax
			mov		eax,rect.right
			sub		eax,rect.left
			pop		ecx
			add		eax,ecx
			add		eax,ecx
			mov		edx,rect.bottom
			sub		edx,rect.top
			pop		ecx
			add		edx,ecx
			add		edx,ecx
			pop		ecx
			add		edx,ecx
			invoke SetWindowPos,hWin,0,0,0,eax,edx,SWP_NOMOVE or SWP_NOZORDER
		.endif
		invoke EnumChildWindows,hWin,addr DlgEnumProc,hWin
		invoke NotifyParent
	.elseif eax==WM_DRAWITEM
		mov		esi,lParam
		invoke GetStockObject,GRAY_BRUSH
		invoke FillRect,[esi].DRAWITEMSTRUCT.hdc,addr [esi].DRAWITEMSTRUCT.rcItem,eax
		xor		eax,eax
		inc		eax
		ret
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

PrevDlgProc endp

GetCtrlSize proc uses ebx esi edi,lpDIALOG:DWORD,lpRECT:DWORD,fEdit:DWORD

	mov		esi,lpDIALOG
	mov		edi,lpRECT
	mov		eax,[esi].DIALOG.dux
	mov		[edi],ax
	mov		eax,[esi].DIALOG.duy
	mov		[edi+2],ax
	mov		eax,[esi].DIALOG.duccx
	mov		[edi+4],ax
	mov		eax,[esi].DIALOG.duccy
	mov		[edi+6],ax
	ret

GetCtrlSize endp

ShowDialog proc uses esi edi ebx,hWin:HWND,hMem:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer[MaxCap]:BYTE

	.if hDlgMnu
		invoke DestroyMenu,hDlgMnu
		mov		hDlgMnu,0
	.endif
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,128*1024
	mov		ebx,eax
	push	eax
	mov		esi,hMem
	mov		edi,esi
	mov		pDlgMem,esi
	add		esi,sizeof DLGHEAD
	mov		eax,[esi].DIALOG.style
	.if byte ptr [edi].DLGHEAD.font
		or		eax,DS_SETFONT
	.endif
	or		eax,DS_NOFAILCREATE or WS_VISIBLE
	and		eax,-1 xor WS_CHILD
	mov		[ebx].MyDLGTEMPLATE.style,eax
	push	eax
	mov		eax,[esi].DIALOG.exstyle
	and		eax,-1 xor (WS_EX_LAYERED or WS_EX_TRANSPARENT)
	mov		[ebx].MyDLGTEMPLATE.dwExtendedStyle,eax
	push	esi
	mov		ecx,-1
	.while [esi].DIALOG.hwnd
		.if [esi].DIALOG.hwnd!=-1
			inc		ecx
		.endif
		add		esi,sizeof DIALOG
	.endw
	pop		esi
	mov		[ebx].MyDLGTEMPLATE.cdit,cx
	invoke GetCtrlSize,esi,addr [ebx].MyDLGTEMPLATE.x,FALSE
	add		ebx,sizeof MyDLGTEMPLATE
	;Menu
	.if [edi].DLGHEAD.menuid
		.if [edi].DLGHEAD.lpmnu
			mov		eax,[edi].DLGHEAD.lpmnu
			invoke MakeMnuBar,eax
			mov		hDlgMnu,eax
		.endif
		mov		word ptr [ebx],-1
		add		ebx,2
		mov		word ptr [ebx],10000
	.else
		mov		word ptr [ebx],0
	.endif
	add		ebx,2
	;Class
	mov		word ptr [ebx],0
	add		ebx,2
	;Caption
	invoke ConvertCaption,addr buffer,addr [esi].DIALOG.caption
	invoke SaveWideChar,addr buffer,ebx
	add		ebx,eax
	pop		eax
	test	eax,DS_SETFONT
	.if !ZERO?
		;Fontsize
		mov		eax,[edi].DLGHEAD.fontsize
		mov		[ebx],ax
		add		ebx,2
		;Facename
		invoke SaveWideChar,addr [edi].DLGHEAD.font,ebx
		add		ebx,eax
	.endif
	add		esi,sizeof DIALOG
	xor		ecx,ecx
  @@:
	add		ebx,2
	and		ebx,0FFFFFFFCh
	call	FindCtrl
	.if [edi].DIALOG.hwnd
		push	ecx
		mov		eax,[edi].DIALOG.style
		or		eax,WS_VISIBLE
		.if [edi].DIALOG.ntype==14
			or		eax,LVS_SHAREIMAGELISTS
		.endif
		mov		[ebx].MyDLGITEMTEMPLATE.style,eax
		mov		eax,[edi].DIALOG.exstyle
		mov		[ebx].MyDLGITEMTEMPLATE.dwExtendedStyle,eax
		invoke GetCtrlSize,edi,addr [ebx].MyDLGITEMTEMPLATE.x,FALSE
		mov		eax,nInx
		mov		[ebx].MyDLGITEMTEMPLATE.id,ax
		add		ebx,sizeof MyDLGITEMTEMPLATE
		mov		eax,[edi].DIALOG.ntype
		mov		edx,sizeof TYPES
		mul		edx
		add		eax,offset ctltypes
		invoke SaveWideChar,[eax].TYPES.lpclass,ebx
		add		ebx,eax
		invoke ConvertCaption,addr buffer,addr [edi].DIALOG.caption
		invoke SaveWideChar,addr buffer,ebx
		add		ebx,eax
		mov		word ptr [ebx],0
		add		ebx,2
		pop		ecx
		inc		ecx
		jmp		@b
	.endif
	pop		ebx
	invoke GetParent,hWin
	invoke CreateDialogIndirectParam,hInstance,ebx,eax,offset PrevDlgProc,0
	mov		hPreview,eax
	invoke GlobalFree,ebx
	mov		dlgdata,WS_CAPTION or DS_SETFONT
	ret

FindCtrl:
	mov		nInx,0
	mov		edi,esi
	.while [edi].DIALOG.hwnd
		.if [edi].DIALOG.hwnd!=-1
			inc		nInx
			.break .if ecx==[edi].DIALOG.tab
		.endif
		add		edi,sizeof DIALOG
	.endw
	retn

ShowDialog endp

