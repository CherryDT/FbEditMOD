.386
.model flat,stdcall
option casemap:none

include Data.inc
include ..\RAProject.inc
include Misc.asm

.code

InstallProjectBrowser proc public hInst:HINSTANCE,fGlobal:DWORD
	LOCAL	wc:WNDCLASSEX

	;Create a windowclass for the user control
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
	.if fGlobal
		mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_GLOBALCLASS or CS_DBLCLKS
	.endif
	mov		wc.lpfnWndProc,offset ControlProc
	mov		eax,hInst
	mov		hInstance,eax
	mov		wc.hInstance,eax
	mov		eax,NULL
	mov		wc.cbClsExtra,eax
	mov		wc.cbWndExtra,4
	mov		wc.hbrBackground,eax
	mov		wc.lpszMenuName,eax
	mov		wc.lpszClassName,offset szPBClassName
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	ret

InstallProjectBrowser endp

UnInstallProjectBrowser proc public

	ret

UnInstallProjectBrowser endp

;--------------------------------------------------------------------------------

IsGroupCollapsed proc hTrv:HWND,hItem:DWORD,lpResult:DWORD
	LOCAL	tvi:TVITEM

  @@:
	mov		tvi._mask,TVIF_CHILDREN or TVIF_STATE
	mov		tvi.stateMask,TVIS_EXPANDED
	mov		tvi.state,0
	mov		eax,hItem
	mov		tvi.hItem,eax
	invoke SendMessage,hTrv,TVM_GETITEM,0,addr tvi
	.if eax
		.if tvi.cChildren
			test	tvi.state,TVIS_EXPANDED
			.if ZERO?
				mov		eax,lpResult
				inc		dword ptr [eax]
			.endif
		.endif
	.endif
	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_CHILD,hItem
	.if eax
		invoke IsGroupCollapsed,hTrv,eax,lpResult
	.endif
	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_NEXT,hItem
	.if eax
		mov		hItem,eax
		jmp		@b
	.endif
	ret

IsGroupCollapsed endp

ExpandAll proc uses ebx esi edi,lpPROJECTBROWSER:DWORD

	mov		ebx,lpPROJECTBROWSER
	mov		esi,[ebx].PROJECTBROWSER.hmemitems
	.while [esi].PBITEM.id
		.if sdword ptr [esi].PBITEM.id<0
			invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_EXPAND,TVE_EXPAND,[esi].PBITEM.hitem
			mov		[esi].PBITEM.expanded,TRUE
		.endif
		lea		esi,[esi+sizeof PBITEM]
	.endw
	ret

ExpandAll endp

CollapseAll proc uses ebx esi edi,lpPROJECTBROWSER:DWORD

	mov		ebx,lpPROJECTBROWSER
	mov		esi,[ebx].PROJECTBROWSER.hmemitems
	.while [esi].PBITEM.id
		.if sdword ptr [esi].PBITEM.id==-1
			invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_EXPAND,TVE_EXPAND,[esi].PBITEM.hitem
			mov		[esi].PBITEM.expanded,TRUE
		.elseif sdword ptr [esi].PBITEM.id<0
			invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_EXPAND,TVE_COLLAPSE,[esi].PBITEM.hitem
			mov		[esi].PBITEM.expanded,FALSE
		.endif
		lea		esi,[esi+sizeof PBITEM]
	.endw
	ret

CollapseAll endp

SetExpand proc uses ebx esi edi,lpPROJECTBROWSER:DWORD

	mov		ebx,lpPROJECTBROWSER
	mov		esi,[ebx].PROJECTBROWSER.hmemitems
	.while [esi].PBITEM.id
		.if sdword ptr [esi].PBITEM.id<0
			.if [esi].PBITEM.expanded
				invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_EXPAND,TVE_EXPAND,[esi].PBITEM.hitem
			.else
				invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_EXPAND,TVE_COLLAPSE,[esi].PBITEM.hitem
			.endif
		.endif
		lea		esi,[esi+sizeof PBITEM]
	.endw
	ret

SetExpand endp

GetExpand proc uses ebx esi edi,lpPROJECTBROWSER:DWORD
	LOCAL	tvi:TV_ITEM

	mov		ebx,lpPROJECTBROWSER
	.if [ebx].PROJECTBROWSER.ngrouping==RPBG_GROUPS
		mov		esi,[ebx].PROJECTBROWSER.hmemitems
		.while [esi].PBITEM.id
			.if sdword ptr [esi].PBITEM.id<0 && [esi].PBITEM.hitem
				mov		tvi._mask,TVIF_STATE or TVIF_CHILDREN
				mov		tvi.stateMask,TVIS_EXPANDED
				mov		eax,[esi].PBITEM.hitem
				mov		tvi.hItem,eax
				invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_GETITEM,0,addr tvi
				.if eax
					.if tvi.cChildren
						test	tvi.state,TVIS_EXPANDED
						.if ZERO?
							mov		[esi].PBITEM.expanded,FALSE
						.else
							mov		[esi].PBITEM.expanded,TRUE
						.endif
					.else
						mov		[esi].PBITEM.expanded,TRUE
					.endif
				.endif
			.endif
			lea		esi,[esi+sizeof PBITEM]
		.endw
	.endif
	ret

GetExpand endp

FindParentGroup proc uses ebx esi edi,lpPROJECTBROWSER:DWORD,id:DWORD

	mov		ebx,lpPROJECTBROWSER
	mov		esi,[ebx].PROJECTBROWSER.hmemitems
	mov		eax,id
	.while [esi].PBITEM.id
		.if eax==[esi].PBITEM.id
			mov		eax,[esi].PBITEM.hitem
			jmp		Ex
		.endif
		lea		esi,[esi+sizeof PBITEM]
	.endw
	xor		eax,eax
  Ex:
	ret

FindParentGroup endp

FindItemFromid proc uses ebx esi edi,lpPROJECTBROWSER:DWORD,id:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	tvis:TV_INSERTSTRUCT
	LOCAL	tvi:TV_ITEM

	mov		ebx,lpPROJECTBROWSER
	mov		esi,[ebx].PROJECTBROWSER.hmemitems
	mov		eax,id
	.while [esi].PBITEM.id
		.if eax==[esi].PBITEM.id
			mov		eax,esi
			jmp		Ex
		.endif
		lea		esi,[esi+sizeof PBITEM]
	.endw
	xor		eax,eax
  Ex:
	ret

FindItemFromid endp

FindItemFromString proc uses ebx esi edi,lpPROJECTBROWSER:DWORD,lpszItem:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	tvis:TV_INSERTSTRUCT
	LOCAL	tvi:TV_ITEM

	mov		ebx,lpPROJECTBROWSER
	mov		esi,[ebx].PROJECTBROWSER.hmemitems
	.while [esi].PBITEM.id
		invoke lstrcmpi,addr [esi].PBITEM.szitem,lpszItem
		.if !eax
			mov		eax,esi
			jmp		Ex
		.endif
		lea		esi,[esi+sizeof PBITEM]
	.endw
	xor		eax,eax
  Ex:
	ret

FindItemFromString endp

AddGroups proc uses ebx esi edi,lpPROJECTBROWSER:DWORD,idpar:DWORD,hpar:DWORD
	LOCAL	tvis:TV_INSERTSTRUCT

	mov		ebx,lpPROJECTBROWSER
	mov		esi,[ebx].PROJECTBROWSER.hmemitems
	invoke RtlZeroMemory,addr tvis,sizeof TV_INSERTSTRUCT
	.if [ebx].PROJECTBROWSER.ngrouping==RPBG_GROUPS
		.while [esi].PBITEM.id
			.if sdword ptr [esi].PBITEM.id<0
				mov		eax,idpar
				.if eax==[esi].PBITEM.idparent
					call	AddGroup
					invoke AddGroups,ebx,[esi].PBITEM.id,[esi].PBITEM.hitem
				.endif
			.endif
			lea		esi,[esi+sizeof PBITEM]
		.endw
	.else
		.while [esi].PBITEM.id
			.if sdword ptr [esi].PBITEM.id<0
				mov		eax,idpar
				.if eax==[esi].PBITEM.idparent
					call	AddGroup
					.break
				.endif
			.endif
			lea		esi,[esi+sizeof PBITEM]
		.endw
	.endif
	ret

AddGroup:
	mov		eax,hpar
	mov		tvis.hParent,eax
	mov		tvis.hInsertAfter,TVI_SORT
	mov		tvis.item._mask,TVIF_IMAGE or TVIF_SELECTEDIMAGE or TVIF_PARAM or TVIF_TEXT
	lea		eax,[esi].PBITEM.szitem
	mov		tvis.item.pszText,eax
	mov		tvis.item.iImage,2
	mov		tvis.item.iSelectedImage,2
	mov		tvis.item.lParam,esi
	invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_INSERTITEM,0,addr tvis
	mov		[esi].PBITEM.hitem,eax
	retn

AddGroups endp

AddFiles proc uses ebx esi edi,lpPROJECTBROWSER:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	tvis:TV_INSERTSTRUCT
	LOCAL	tvi:TV_ITEM

	mov		ebx,lpPROJECTBROWSER
	mov		esi,[ebx].PROJECTBROWSER.hmemitems
	invoke RtlZeroMemory,addr tvis,sizeof TV_INSERTSTRUCT
	.while [esi].PBITEM.id
		.if sdword ptr [esi].PBITEM.id>0
			.if [ebx].PROJECTBROWSER.ngrouping==RPBG_NONE
				mov		eax,-1
			.elseif [ebx].PROJECTBROWSER.ngrouping==RPBG_GROUPS
				mov		eax,[esi].PBITEM.idparent
			.endif
			invoke FindParentGroup,ebx,eax
			mov		tvis.hParent,eax
			mov		tvis.hInsertAfter,TVI_LAST
			mov		tvis.item._mask,TVIF_IMAGE or TVIF_SELECTEDIMAGE or TVIF_PARAM or TVIF_TEXT
			test	[ebx].PROJECTBROWSER.style,RPBS_NOPATH
			.if !ZERO?
				invoke lstrcpy,addr buffer,addr [esi].PBITEM.szitem
				invoke lstrlen,addr buffer
				.while buffer[eax-1]!='\' && eax
					dec		eax
				.endw
				lea		eax,buffer[eax]
			.else
				invoke RemoveThePath,addr [esi].PBITEM.szitem,addr [ebx].PROJECTBROWSER.projectpath,addr buffer
			.endif
			mov		tvis.item.pszText,eax
			invoke FindFileExt,ebx,eax
			.if [esi].PBITEM.flag==FLAG_MODULE
				lea		eax,[eax+7]
			.elseif [esi].PBITEM.flag==FLAG_MAIN
				lea		eax,[eax+14]
			.endif
			mov		tvis.item.iImage,eax
			mov		tvis.item.iSelectedImage,eax
			mov		tvis.item.lParam,esi
			invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_INSERTITEM,0,addr tvis
			mov		[esi].PBITEM.hitem,eax
		.endif
		lea		esi,[esi+sizeof PBITEM]
	.endw
	ret

AddFiles endp

DeleteItem proc uses ebx esi edi,lpPROJECTBROWSER:DWORD,lpItem:DWORD

	mov		ebx,lpPROJECTBROWSER
	mov		edi,lpItem
	.if sdword ptr [edi].PBITEM.id<0
		mov		eax,[edi].PBITEM.id
		mov		edx,[edi].PBITEM.idparent
		call	SetNewidparent
	.endif
	lea		esi,[edi+sizeof PBITEM]
	.while [edi].PBITEM.id
		mov		ecx,sizeof PBITEM
		rep movsb
	.endw
	ret

SetNewidparent:
	mov		esi,[ebx].PROJECTBROWSER.hmemitems
	.while [esi].PBITEM.id
		.if eax==[esi].PBITEM.idparent
			mov		[esi].PBITEM.idparent,edx
		.endif
		lea		esi,[esi+sizeof PBITEM]
	.endw
	retn

DeleteItem endp

GetFreeid proc uses ebx esi edi,lpPROJECTBROWSER:DWORD,nid:DWORD,ninc:DWORD

	mov		ebx,lpPROJECTBROWSER
	mov		edi,nid
	.while TRUE
		call	Testid
		.break.if !eax
		add		edi,ninc
	.endw
	mov		eax,edi
	ret

Testid:
	mov		esi,[ebx].PROJECTBROWSER.hmemitems
	.while edi!=[esi].PBITEM.id && [esi].PBITEM.id
		lea		esi,[esi+sizeof PBITEM]
	.endw
	mov		eax,[esi].PBITEM.id
	retn

GetFreeid endp

GetFreeIndex proc uses ebx esi edi,lpPROJECTBROWSER:DWORD

	mov		ebx,lpPROJECTBROWSER
	mov		esi,[ebx].PROJECTBROWSER.hmemitems
	xor		edi,edi
	.while [esi].PBITEM.id
		lea		esi,[esi+sizeof PBITEM]
		inc		edi
	.endw
	mov		eax,edi
	ret

GetFreeIndex endp

NotifyDblClick proc uses ebx,hWin:HWND,lpPBITEM:DWORD
	LOCAL	pbn:NMPBITEMDBLCLICK

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,hWin
	mov		pbn.nmhdr.hwndFrom,eax
	invoke GetWindowLong,eax,GWL_ID
	mov		pbn.nmhdr.idFrom,eax
	mov		pbn.nmhdr.code,RPBN_DBLCLICK
	mov		eax,lpPBITEM
	mov		pbn.lpPBITEM,eax
	invoke GetParent,hWin
	mov		edx,eax
	invoke SendMessage,edx,WM_NOTIFY,pbn.nmhdr.idFrom,addr pbn
	ret

NotifyDblClick endp

NotifyItemChange proc uses ebx,hWin:HWND,lpPBITEM:DWORD
	LOCAL	pbn:NMPBITEMCHANGE

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,hWin
	mov		pbn.nmhdr.hwndFrom,eax
	invoke GetWindowLong,eax,GWL_ID
	mov		pbn.nmhdr.idFrom,eax
	mov		pbn.nmhdr.code,RPBN_ITEMCHANGE
	mov		eax,lpPBITEM
	mov		pbn.lpPBITEM,eax
	mov		pbn.lpsznew,offset szitemnew
	mov		pbn.cancel,FALSE
	invoke GetParent,hWin
	mov		edx,eax
	invoke SendMessage,edx,WM_NOTIFY,pbn.nmhdr.idFrom,addr pbn
	mov		eax,pbn.cancel
	ret

NotifyItemChange endp

NotifySelChange proc uses ebx,hWin:HWND,lpPBITEM:DWORD
	LOCAL	pbn:NMPBSELCHANGE

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,hWin
	mov		pbn.nmhdr.hwndFrom,eax
	invoke GetWindowLong,eax,GWL_ID
	mov		pbn.nmhdr.idFrom,eax
	mov		pbn.nmhdr.code,RPBN_SELCHANGE
	mov		eax,lpPBITEM
	mov		pbn.lpPBITEM,eax
	invoke GetParent,hWin
	mov		edx,eax
	invoke SendMessage,edx,WM_NOTIFY,pbn.nmhdr.idFrom,addr pbn
	ret

NotifySelChange endp

GroupTrvEditProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_GETDLGCODE
		mov		eax,DLGC_WANTALLKEYS
	.else
		invoke CallWindowProc,lpOldGroupTrvEditProc,hWin,uMsg,wParam,lParam
	.endif
	ret

GroupTrvEditProc endp

ProjectTreeViewProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ht:TV_HITTESTINFO
	LOCAL	tvi:TV_ITEMEX
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if	eax==WM_LBUTTONDBLCLK
		invoke GetParent,hWin
		invoke GetWindowLong,eax,0
		mov		ebx,eax
		invoke GetWindowLong,hWin,GWL_USERDATA
		invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
		push	eax
		mov		eax,lParam
		and		eax,0FFFFh
		mov		ht.pt.x,eax
		mov		eax,lParam
		shr		eax,16
		mov		ht.pt.y,eax
		invoke SendMessage,hWin,TVM_HITTEST,0,addr ht
		.if	eax
			test	ht.flags,TVHT_ONITEM
			.if	!ZERO?
				mov		eax,ht.hItem
				mov		tvi.hItem,eax
				mov		tvi.imask,TVIF_PARAM
				invoke SendMessage,hWin,TVM_GETITEM,0,addr tvi
				mov		esi,tvi.lParam
				.if	esi
					.if sdword ptr [esi].PBITEM.id>0
						invoke GetParent,hWin
						invoke NotifyDblClick,eax,esi
					.endif
				.endif
			.endif
		.endif
		pop		eax
		jmp		Ex
	.elseif	eax==WM_RBUTTONDOWN
		invoke GetParent,hWin
		invoke GetWindowLong,eax,0
		mov		ebx,eax
		mov		eax,lParam
		and		eax,0FFFFh
		mov		ht.pt.x,eax
		mov		eax,lParam
		shr		eax,16
		mov		ht.pt.y,eax
		invoke SendMessage,hWin,TVM_HITTEST,0,addr ht
		.if	eax
			test	ht.flags,TVHT_ONITEM
			.if	!ZERO?
				invoke SendMessage,hWin,TVM_SELECTITEM,TVGN_CARET,eax
			.endif
		.endif
		invoke SetFocus,hWin
		xor		eax,eax
		jmp		Ex
	.elseif	eax==WM_CHAR
		mov		eax,wParam
		.if	eax==VK_SPACE
			invoke SendMessage,hWin,TVM_GETNEXTITEM,TVGN_CARET,0
			mov		dword ptr rect,eax
			invoke SendMessage,hWin,TVM_GETITEMRECT,TRUE,addr rect
			mov		eax,rect.top
			shl		eax,16
			add		eax,rect.left
			invoke SendMessage,hWin,WM_LBUTTONDBLCLK,0,eax
			xor		eax,eax
			jmp		Ex
		.elseif	eax==VK_RETURN
			invoke SendMessage,hWin,TVM_GETNEXTITEM,TVGN_CARET,0
			.if eax
				invoke SendMessage,hWin,TVM_EDITLABEL,0,eax
			.endif
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_GETDLGCODE
		mov		eax,DLGC_WANTALLKEYS
		jmp		Ex
	.endif
	invoke GetWindowLong,hWin,GWL_USERDATA
	invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
  Ex:
	ret

ProjectTreeViewProc endp

TVBeginDrag proc hWin:HWND,hParent:HWND,lParam:LPARAM
	LOCAL	DragStart:POINT

	invoke GetWindowLong,hParent,0
	invoke GetExpand,eax
	mov		edx,lParam
	mov		eax,[edx].NMTREEVIEW.itemNew.hItem
	mov		TVDragItem,eax
	invoke GetCursorPos,addr DragStart
	invoke SendMessage,hWin,TVM_SELECTITEM,TVGN_DROPHILITE,TVDragItem
	invoke SendMessage,hWin,TVM_CREATEDRAGIMAGE,0,TVDragItem
	mov		hDragIml,eax
	invoke ImageList_BeginDrag,hDragIml,0,-8,-8
	invoke GetDesktopWindow
	invoke ImageList_DragEnter,eax,DragStart.x,DragStart.y
	invoke SetCapture,hParent
	mov		IsDragging,TRUE
	ret

TVBeginDrag endp

TVEndDrag proc uses ebx esi edi,hWin:HWND
	LOCAL	pt:POINT
	LOCAL	tvi:TV_ITEM
	LOCAL	tvht:TV_HITTESTINFO

	invoke ReleaseCapture
	invoke GetCursorPos,addr pt
	invoke WindowFromPoint,pt.x,pt.y
	.if eax==hWin
		invoke GetParent,hWin
		invoke GetWindowLong,eax,0
		mov		ebx,eax
		invoke SendMessage,hWin,WM_SETREDRAW,FALSE,0
		invoke SendMessage,hWin,TVM_SELECTITEM,TVGN_DROPHILITE,NULL
		invoke GetCursorPos,addr tvht.pt
		invoke ScreenToClient,hWin,addr tvht.pt
		invoke SendMessage,hWin,TVM_HITTEST,0,addr tvht
		.if eax
			mov		tvi._mask,TVIF_PARAM
			mov		tvi.hItem,eax
			invoke SendMessage,hWin,TVM_GETITEM,0,addr tvi
			mov		edx,tvi.lParam
			mov		eax,tvi.hItem
			.if sdword ptr [edx].PBITEM.id>0
				; The drop item is not a group, get parent
				invoke SendMessage,hWin,TVM_GETNEXTITEM,TVGN_PARENT,eax
			.endif
			; Get pointer to drop item
			mov		tvi._mask,TVIF_PARAM
			mov		tvi.hItem,eax
			invoke SendMessage,hWin,TVM_GETITEM,0,addr tvi
			mov		esi,tvi.lParam
			mov		tvi._mask,TVIF_PARAM
			; Get pointer dragged item
			mov		eax,TVDragItem
			mov		tvi.hItem,eax
			invoke SendMessage,hWin,TVM_GETITEM,0,addr tvi
			mov		edi,tvi.lParam
			; Check if the drop item is a child of the dragged item
			mov		eax,[esi].PBITEM.hitem
			call	IsParent
			.if !eax
				mov		eax,[esi].PBITEM.id
				mov		[edi].PBITEM.idparent,eax
				invoke SendMessage,[ebx].PROJECTBROWSER.hwnd,RPBM_SETGROUPING,TRUE,[ebx].PROJECTBROWSER.ngrouping
			.endif
		.endif
	.endif
	invoke SendMessage,hWin,WM_SETREDRAW,TRUE,0
	invoke ReleaseCapture
	invoke GetDesktopWindow
	invoke ImageList_DragLeave,eax
	invoke ImageList_EndDrag
	invoke ImageList_Destroy,hDragIml
	ret

IsParent:
	.while TRUE
		mov		tvi._mask,TVIF_PARAM
		mov		tvi.hItem,eax
		invoke SendMessage,hWin,TVM_GETITEM,0,addr tvi
		.if edi==tvi.lParam
			mov		eax,TRUE
			.break
		.endif
		invoke SendMessage,hWin,TVM_GETNEXTITEM,TVGN_PARENT,tvi.hItem
		.break .if !eax
	.endw
	retn

TVEndDrag endp

ControlProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	nCollapsed:DWORD
	LOCAL	tvi:TV_ITEM
	LOCAL	pbi:PBITEM
	LOCAL	nmhdr:NMHDR

	mov		eax,uMsg
	.if eax==WM_CREATE
		invoke GetProcessHeap
		invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof PROJECTBROWSER
		mov		ebx,eax
		invoke SetWindowLong,hWin,0,ebx
		mov		eax,hWin
		mov		[ebx].PROJECTBROWSER.hwnd,eax
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		[ebx].PROJECTBROWSER.style,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MAXFIEEXTMEM
		mov		[ebx].PROJECTBROWSER.hmemfileext,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MAXITEMMEM
		mov		[ebx].PROJECTBROWSER.hmemitems,eax
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr szTreeView,NULL,WS_CHILD or WS_VISIBLE or WS_CLIPSIBLINGS or WS_CLIPCHILDREN or TVS_HASLINES or TVS_HASBUTTONS or TVS_SHOWSELALWAYS or TVS_EDITLABELS,0,0,0,0,hWin,NULL,hInstance,NULL
		mov		[ebx].PROJECTBROWSER.htrv,eax
		invoke SetWindowLong,[ebx].PROJECTBROWSER.htrv,GWL_WNDPROC,offset ProjectTreeViewProc
		invoke SetWindowLong,[ebx].PROJECTBROWSER.htrv,GWL_USERDATA,eax
		invoke ImageList_Create,16,16,ILC_COLOR24 or ILC_MASK,17,0
		mov		[ebx].PROJECTBROWSER.himl,eax
		invoke LoadBitmap,hInstance,IDB_TRV
		push	eax
		invoke ImageList_AddMasked,[ebx].PROJECTBROWSER.himl,eax,0FF00FFh
		pop		eax
		invoke DeleteObject,eax
		invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_SETIMAGELIST,0,[ebx].PROJECTBROWSER.himl
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		edx,WS_CHILD or WS_VISIBLE or TBSTYLE_TOOLTIPS or CCS_NORESIZE
		test	eax,RPBS_FLATTOOLBAR
		.if !ZERO?
			or		edx,TBSTYLE_FLAT
		.endif
		test	eax,RPBS_DIVIDERLINE
		.if ZERO?
			or		edx,CCS_NODIVIDER
		.endif
		invoke CreateWindowEx,0,addr szToolBar,NULL,edx,0,0,0,0,hWin,NULL,hInstance,NULL
		mov		[ebx].PROJECTBROWSER.htbr,eax
		;Set toolbar struct size
		invoke SendMessage,[ebx].PROJECTBROWSER.htbr,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
		;Set toolbar buttons
		invoke SendMessage,[ebx].PROJECTBROWSER.htbr,TB_ADDBUTTONS,3,addr btns
		;Set the imagelist
		invoke SendMessage,[ebx].PROJECTBROWSER.htbr,TB_SETIMAGELIST,0,[ebx].PROJECTBROWSER.himl
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_COMMAND
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==1
				mov		eax,[ebx].PROJECTBROWSER.ngrouping
				inc		eax
				.if eax>RPBG_GROUPS
					mov		eax,RPBG_NONE
				.endif
				invoke SendMessage,hWin,RPBM_SETGROUPING,TRUE,eax
			.elseif eax==2
				mov		nCollapsed,0
				invoke IsGroupCollapsed,[ebx].PROJECTBROWSER.htrv,0,addr nCollapsed
				.if nCollapsed
					invoke ExpandAll,ebx
				.else
					invoke CollapseAll,ebx
				.endif
			.endif
		.endif
	.elseif eax==WM_SIZE
		push	edi
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		edi,28
		test	eax,RPBS_FLATTOOLBAR
		.if !ZERO?
			sub		edi,4
		.endif
		test	eax,RPBS_DIVIDERLINE
		.if ZERO?
			sub		edi,2
		.endif
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GetClientRect,hWin,addr rect
		invoke MoveWindow,[ebx].PROJECTBROWSER.htbr,0,0,rect.right,edi,TRUE
		mov		edx,rect.bottom
		sub		edx,edi
		invoke MoveWindow,[ebx].PROJECTBROWSER.htrv,0,edi,rect.right,edx,TRUE
		pop		edi
	.elseif eax==WM_SETFONT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		.if eax
			invoke SendMessage,[ebx].PROJECTBROWSER.htrv,WM_SETFONT,wParam,TRUE
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_DESTROY
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke ImageList_Destroy,[ebx].PROJECTBROWSER.himl
		invoke DestroyWindow,[ebx].PROJECTBROWSER.htrv
		invoke DestroyWindow,[ebx].PROJECTBROWSER.htbr
		invoke GlobalFree,[ebx].PROJECTBROWSER.hmemfileext
		invoke GlobalFree,[ebx].PROJECTBROWSER.hmemitems
		invoke GetProcessHeap
		invoke HeapFree,eax,0,ebx
	.elseif eax==WM_LBUTTONUP
		.if IsDragging
			invoke GetWindowLong,hWin,0
			mov		ebx,eax
			mov		IsDragging,FALSE
			invoke TVEndDrag,[ebx].PROJECTBROWSER.htrv
		.endif
	.elseif eax==WM_MOUSEMOVE
		.if IsDragging
			invoke GetWindowLong,hWin,0
			mov		ebx,eax
			invoke GetCursorPos,addr pt
			invoke GetWindowRect,[ebx].PROJECTBROWSER.htrv,addr rect
			invoke GetScrollPos,[ebx].PROJECTBROWSER.htrv,SB_VERT
			mov		edi,eax
			mov		edx,pt.y
			.if sdword ptr edx<rect.top
				dec		edi
				mov		eax,edi
				shl		eax,16
				or		eax,SB_LINEUP
				invoke SendMessage,[ebx].PROJECTBROWSER.htrv,WM_VSCROLL,eax,0
				invoke InvalidateRect,[ebx].PROJECTBROWSER.htrv,NULL,TRUE
				invoke UpdateWindow,[ebx].PROJECTBROWSER.htrv
			.elseif sdword ptr edx>rect.bottom
				inc		edi
				mov		eax,edi
				shl		eax,16
				or		eax,SB_LINEDOWN
				invoke SendMessage,[ebx].PROJECTBROWSER.htrv,WM_VSCROLL,eax,0
				invoke InvalidateRect,[ebx].PROJECTBROWSER.htrv,NULL,TRUE
				invoke UpdateWindow,[ebx].PROJECTBROWSER.htrv
			.endif
			invoke ImageList_DragMove,pt.x,pt.y
		.endif
	.elseif eax==WM_NOTIFY
		invoke GetWindowLong,hWin,0
		.if eax
			mov		ebx,eax
			mov		esi,lParam
			mov		eax,[esi].NMHDR.hwndFrom
			.if eax==[ebx].PROJECTBROWSER.htrv
				mov		eax,[esi].NMHDR.code
				.if eax==TVN_BEGINDRAG
					invoke SetFocus,[esi].NMHDR.hwndFrom
					mov		edi,[esi].NM_TREEVIEW.itemNew.lParam
					.if sdword ptr [edi].PBITEM.id!=-1 && [ebx].PROJECTBROWSER.ngrouping==RPBG_GROUPS
						invoke TVBeginDrag,[ebx].PROJECTBROWSER.htrv,hWin,lParam
					.else
						invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_SELECTITEM,TVGN_CARET,[esi].NM_TREEVIEW.itemNew.hItem
					.endif
				.elseif eax==TVN_BEGINLABELEDIT
					invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_GETEDITCONTROL,0,0
					push	eax
					invoke SetWindowLong,eax,GWL_WNDPROC,offset GroupTrvEditProc
					mov		lpOldGroupTrvEditProc,eax
					pop		eax
					mov		edi,[esi].NMTVDISPINFO.item.lParam
				.elseif eax==TVN_ENDLABELEDIT
					mov		edi,[esi].NMTVDISPINFO.item.lParam
					.if [esi].NMTVDISPINFO.item.pszText
						invoke lstrlen,[esi].NMTVDISPINFO.item.pszText
						.if eax
							mov		edi,[esi].NMTVDISPINFO.item.lParam
							.if sdword ptr [edi].PBITEM.id<0
								invoke lstrcpy,addr [edi].PBITEM.szitem,[esi].NMTVDISPINFO.item.pszText
							.else
								test	[ebx].PROJECTBROWSER.style,RPBS_NOPATH
								.if !ZERO?
									invoke lstrcpy,addr szitemnew,addr [edi].PBITEM.szitem
									invoke lstrlen,addr szitemnew
									.while szitemnew[eax]!='\' && eax
										dec		eax
									.endw
									mov		szitemnew[eax],0
								.else
									invoke lstrcpy,addr szitemnew,addr [ebx].PROJECTBROWSER.projectpath
								.endif
								invoke lstrcat,addr szitemnew,addr szBS
								invoke lstrcat,addr szitemnew,[esi].NMTVDISPINFO.item.pszText
								invoke NotifyItemChange,hWin,edi
								.if eax
									xor		eax,eax
									jmp		Ex
								.endif
								invoke lstrcpy,addr [edi].PBITEM.szitem,addr szitemnew
							.endif
							mov		edi,[edi].PBITEM.id
							invoke GetExpand,ebx
							invoke SortItems,ebx
							invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_DELETEITEM,0,TVI_ROOT
							invoke AddGroups,ebx,0,0
							invoke AddFiles,ebx
							invoke SetExpand,ebx
							invoke FindItemFromid,ebx,edi
							.if eax
								invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_SELECTITEM,TVGN_CARET,[eax].PBITEM.hitem
							.endif
						.endif
					.endif
				.elseif eax==TVN_SELCHANGED
					invoke NotifySelChange,hWin,[esi].NM_TREEVIEW.itemNew.lParam
				.elseif eax==NM_SETFOCUS
					mov		eax,hWin
					mov		nmhdr.hwndFrom,eax
					invoke GetWindowLong,hWin,GWL_ID
					mov		nmhdr.idFrom,eax
					mov		nmhdr.code,NM_SETFOCUS
					invoke GetParent,hWin
					mov		ebx,eax
					invoke SendMessage,ebx,WM_NOTIFY,nmhdr.idFrom,addr nmhdr
				.elseif eax==NM_KILLFOCUS
					mov		eax,hWin
					mov		nmhdr.hwndFrom,eax
					invoke GetWindowLong,hWin,GWL_ID
					mov		nmhdr.idFrom,eax
					mov		nmhdr.code,NM_KILLFOCUS
					invoke GetParent,hWin
					mov		ebx,eax
					invoke SendMessage,ebx,WM_NOTIFY,nmhdr.idFrom,addr nmhdr
				.endif
			.elseif [esi].NMHDR.code==TTN_NEEDTEXT
				;Toolbar tooltip
				mov		eax,offset szGrouping
				.if [esi].NMHDR.idFrom==2
					mov		eax,offset szExpand
				.endif
				mov		[esi].TOOLTIPTEXT.lpszText,eax
				xor		eax,eax
				jmp		Ex
			.endif
		.endif
	.elseif eax==RPBM_SETPATH
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke lstrcpyn,addr [ebx].PROJECTBROWSER.projectpath,lParam,MAX_PATH
		.if wParam
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==RPBM_GETPATH
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		lea		eax,[ebx].PROJECTBROWSER.projectpath
		jmp		Ex
	.elseif eax==RPBM_ADDFILEEXT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		esi,lParam
		mov		edi,[ebx].PROJECTBROWSER.hmemfileext
		.if !esi
			invoke RtlZeroMemory,edi,MAXFIEEXTMEM
		.else
			mov		eax,wParam
			mov		edx,sizeof PBFILEEXT
			mul		edx
			invoke RtlMoveMemory,addr [edi+eax],esi,sizeof PBFILEEXT
		.endif
	.elseif eax==RPBM_GETFILEEXT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		mov		edx,sizeof PBFILEEXT
		mul		edx
		mov		edx,[ebx].PROJECTBROWSER.hmemfileext
		lea		eax,[eax+edx]
		jmp		Ex
	.elseif eax==RPBM_SETITEM
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		esi,lParam
		mov		edi,[ebx].PROJECTBROWSER.hmemitems
		.if !esi
			invoke RtlZeroMemory,edi,MAXITEMMEM
		.else
			mov		eax,wParam
			mov		edx,sizeof PBITEM
			mul		edx
			invoke RtlMoveMemory,addr [edi+eax],esi,sizeof PBITEM
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==RPBM_GETITEM
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		mov		edx,sizeof PBITEM
		mul		edx
		mov		edx,[ebx].PROJECTBROWSER.hmemitems
		lea		eax,[eax+edx]
		jmp		Ex
	.elseif eax==RPBM_SETGROUPING
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		.if [ebx].PROJECTBROWSER.ngrouping==RPBG_GROUPS
			invoke GetExpand,ebx
		.endif
		mov		eax,lParam
		.if eax==RPBG_NOCHANGE
			mov		eax,[ebx].PROJECTBROWSER.ngrouping
		.elseif sdword ptr eax<RPBG_NONE
			mov		eax,RPBG_NONE
		.elseif sdword ptr eax>RPBG_GROUPS
			mov		eax,RPBG_GROUPS
		.endif
		mov		[ebx].PROJECTBROWSER.ngrouping,eax
		.if wParam
			invoke SortItems,ebx
			invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_DELETEITEM,0,TVI_ROOT
			invoke AddGroups,ebx,0,0
			invoke AddFiles,ebx
			invoke SetExpand,ebx
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==RPBM_GETGROUPING
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].PROJECTBROWSER.ngrouping
		jmp		Ex
	.elseif eax==RPBM_SETSELECTED
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke FindItemFromString,ebx,lParam
		.if eax
			invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_SELECTITEM,TVGN_CARET,[eax].PBITEM.hitem
			mov		eax,TRUE
		.endif
		jmp		Ex
	.elseif eax==RPBM_GETSELECTED
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_GETNEXTITEM,TVGN_CARET,0
		.if eax
			mov		tvi._mask,TVIF_PARAM
			mov		tvi.hItem,eax
			invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_GETITEM,0,addr tvi
			.if eax
				mov		eax,tvi.lParam
			.endif
		.endif
		jmp		Ex
	.elseif eax==RPBM_SETBACKCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_SETBKCOLOR,0,lParam
		xor		eax,eax
		jmp		Ex
	.elseif eax==RPBM_GETBACKCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_GETBKCOLOR,0,0
		jmp		Ex
	.elseif eax==RPBM_SETTEXTCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_SETTEXTCOLOR,0,lParam
		xor		eax,eax
		jmp		Ex
	.elseif eax==RPBM_GETTEXTCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_GETTEXTCOLOR,0,0
		xor		eax,eax
		jmp		Ex
	.elseif eax==RPBM_GETIMAGELIST
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].PROJECTBROWSER.himl
		jmp		Ex
	.elseif eax==RPBM_SETTOOLTIP
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		.if eax==1
			invoke lstrcpyn,addr szGrouping,lParam,64
		.elseif eax==2
			invoke lstrcpyn,addr szExpand,lParam,64
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==RPBM_ADDNEWGROUP
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,hWin,RPBM_GETSELECTED,0,0
		.if eax
			mov		esi,eax
			invoke RtlZeroMemory,addr pbi,sizeof PBITEM
			invoke GetFreeid,ebx,-2,-1
			mov		pbi.id,eax
			.if sdword ptr [esi].PBITEM.id<0
				mov		eax,[esi].PBITEM.id
			.else
				mov		eax,[esi].PBITEM.idparent
			.endif
			mov		pbi.idparent,eax
			invoke lstrcpy,addr pbi.szitem,addr szNewGroup
			invoke GetFreeIndex,ebx
			mov		edx,eax
			invoke SendMessage,hWin,RPBM_SETITEM,edx,addr pbi
			invoke SendMessage,hWin,RPBM_SETGROUPING,TRUE,[ebx].PROJECTBROWSER.ngrouping
			invoke FindItemFromid,ebx,pbi.id
			.if eax
				mov		esi,eax
				invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_SELECTITEM,TVGN_CARET,[esi].PBITEM.hitem
				invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_EDITLABEL,0,[esi].PBITEM.hitem
				mov		eax,esi
			.endif
		.endif
		jmp		Ex
	.elseif eax==RPBM_DELETEITEM
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,hWin,RPBM_GETSELECTED,0,0
		.if eax
			invoke DeleteItem,ebx,eax
			invoke SendMessage,hWin,RPBM_SETGROUPING,TRUE,[ebx].PROJECTBROWSER.ngrouping
			mov		eax,TRUE
		.endif
		jmp		Ex
	.elseif eax==RPBM_EDITITEM
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,hWin,RPBM_GETSELECTED,0,0
		.if eax
			invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_EDITLABEL,0,[eax].PBITEM.hitem
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==RPBM_GETEXPAND
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GetExpand,ebx
		xor		eax,eax
		jmp		Ex
	.elseif eax==RPBM_ADDNEWFILE
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke FindItemFromString,ebx,lParam
		.if !eax
			invoke RtlZeroMemory,addr pbi,sizeof PBITEM
			invoke GetFreeid,ebx,1,1
			mov		pbi.id,eax
			.if sdword ptr wParam<0
				mov		eax,wParam
				mov		pbi.idparent,eax
			.else
				invoke SendMessage,hWin,RPBM_GETSELECTED,0,0
				.if eax
					.if sdword ptr [eax].PBITEM.id<0
						mov		eax,[eax].PBITEM.id
					.else
						mov		eax,[eax].PBITEM.idparent
					.endif
					mov		pbi.idparent,eax
				.else
					jmp		Ex
				.endif
			.endif
			invoke lstrcpy,addr pbi.szitem,lParam
			invoke GetFreeIndex,ebx
			mov		edx,eax
			invoke SendMessage,hWin,RPBM_SETITEM,edx,addr pbi
			invoke SendMessage,hWin,RPBM_SETGROUPING,TRUE,[ebx].PROJECTBROWSER.ngrouping
			invoke FindItemFromid,ebx,pbi.id
			.if eax
				mov		esi,eax
				invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_SELECTITEM,TVGN_CARET,[esi].PBITEM.hitem
				mov		eax,esi
			.endif
		.else
			xor		eax,eax
		.endif
		jmp		Ex
	.elseif eax==RPBM_FINDITEM
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		.if wParam
			invoke FindItemFromid,ebx,wParam
		.else
			invoke FindItemFromString,ebx,lParam
		.endif
		jmp		Ex
	.elseif eax==RPBM_FINDITEMINDEX
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		.if wParam
			invoke FindItemFromid,ebx,wParam
		.else
			invoke FindItemFromString,ebx,lParam
		.endif
		.if eax
			sub		eax,[ebx].PROJECTBROWSER.hmemitems
			mov		ecx,sizeof PBITEM
			xor		edx,edx
			div		ecx
		.else
			or		eax,-1
		.endif
		jmp		Ex
	.elseif eax==PBRM_FINDNEXTITEM
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		esi,[ebx].PROJECTBROWSER.hmemitems
		mov		edx,wParam
		mov		ecx,32768
		xor		edi,edi
		.while [esi].PBITEM.id
			mov		eax,[esi].PBITEM.id
			.if eax>edx && eax<ecx
				mov		edi,esi
				mov		ecx,eax
			.endif
			lea		esi,[esi+sizeof PBITEM]
		.endw
		mov		eax,edi
		jmp		Ex
	.elseif eax==PBRM_SETFLAG
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		.if eax
			invoke FindItemFromid,ebx,eax
			.if eax
				mov		esi,eax
				mov		eax,[esi].PBITEM.hitem
				mov		tvi._mask,TVIF_PARAM or TVIF_IMAGE or TVIF_SELECTEDIMAGE
				mov		tvi.hItem,eax
				invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_GETITEM,0,addr tvi
				mov		eax,[esi].PBITEM.flag
				mov		edx,tvi.iImage
				.if eax==FLAG_MODULE
					sub		edx,7
				.elseif eax==FLAG_MAIN
					sub		edx,14
				.endif
				mov		eax,lParam
				mov		[esi].PBITEM.flag,eax
				.if eax==FLAG_MODULE
					add		edx,7
				.elseif eax==FLAG_MAIN
					add		edx,14
				.endif
				mov		tvi.iImage,edx
				mov		tvi.iSelectedImage,edx
				invoke SendMessage,[ebx].PROJECTBROWSER.htrv,TVM_SETITEM,0,addr tvi
				mov		eax,esi
			.endif
		.endif
		jmp		Ex
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ControlProc endp

IFDEF DLL
	include RAProjectDll.asm
ENDIF

end
