.data

szDialog		db 'Dialog',0
szMenu			db 'Menu',0
szMisc			db 'Misc',0

szResource		db 'Resource files',0
szIncludeFile	db 'Include files',0
szStringTable	db 'Stringtable',0
szLanguage		db 'Language',0

.data?

hPrjTrv			dd ?
OldTreeViewProc	dd ?
hRoot			dd ?
hNodeDlg		dd ?
hNodeMnu		dd ?
hNodeMisc		dd ?

.code

ProjectDblClick proc uses ebx,hWin:HWND,lParam:LPARAM
	LOCAL	buffer[64]:BYTE
	LOCAL	tvht:TV_HITTESTINFO
	LOCAL	tvi:TV_ITEMEX
	LOCAL	hTvi:HWND

	mov		eax,lParam
	and		eax,0FFFFh
	mov		tvht.pt.x,eax
	mov		eax,lParam
	shr		eax,16
	mov		tvht.pt.y,eax
	invoke SendMessage,hWin,TVM_HITTEST,0,addr tvht
	.if eax
		mov		hTvi,eax
		mov		eax,tvht.flags
		and		eax,TVHT_ONITEM
		.if eax
			m2m		tvi.hItem,tvht.hItem
			mov		tvi.imask,TVIF_PARAM or TVIF_TEXT
			lea		eax,buffer
			mov		tvi.pszText,eax
			mov		tvi.cchTextMax,sizeof buffer
			invoke SendMessage,hWin,TVM_GETITEM,0,addr tvi
			.if tvi.lParam
				mov		ebx,tvi.lParam
				.if [ebx].PROJECT.ntype==TPE_DIALOG
					invoke SendMessage,hRes,DEM_OPEN,0,ebx
				.elseif [ebx].PROJECT.ntype==TPE_MENU
					invoke CloseDialog
					invoke CreateMnu,hDEd,ebx
					;invoke SendMessage,hRes,MEM_OPEN,0,ebx
					invoke NotifyParent
				.elseif [ebx].PROJECT.ntype==TPE_VERSION
					invoke CloseDialog
					invoke CreateDialogParam,hInstance,IDD_DLGVERSION,hDEd,offset VersionEditProc,ebx
					mov		hDialog,eax
					invoke NotifyParent
				.elseif [ebx].PROJECT.ntype==TPE_ACCEL
					invoke CloseDialog
					invoke CreateDialogParam,hInstance,IDD_DLGACCEL,hDEd,offset AccelEditProc,ebx
					mov		hDialog,eax
					invoke NotifyParent
				.elseif [ebx].PROJECT.ntype==TPE_INCLUDE
					invoke CloseDialog
					invoke CreateDialogParam,hInstance,IDD_DLGINCLUDE,hDEd,offset IncludeEditProc,ebx
					mov		hDialog,eax
					invoke NotifyParent
				.elseif [ebx].PROJECT.ntype==TPE_RESOURCE
					invoke CloseDialog
					invoke CreateDialogParam,hInstance,IDD_DLGRESOURCE,hDEd,offset ResourceEditProc,ebx
					mov		hDialog,eax
					invoke NotifyParent
				.elseif [ebx].PROJECT.ntype==TPE_STRING
					invoke CloseDialog
					invoke CreateDialogParam,hInstance,IDD_DLGSTRING,hDEd,offset StringEditProc,ebx
					mov		hDialog,eax
					invoke NotifyParent
				.elseif [ebx].PROJECT.ntype==TPE_LANGUAGE
					invoke CloseDialog
					invoke CreateDialogParam,hInstance,IDD_LANGUAGECHILD,hDEd,offset LanguageEditProc,ebx
					mov		hDialog,eax
					invoke NotifyParent
				.elseif [ebx].PROJECT.ntype==TPE_XPMANIFEST
					invoke CloseDialog
					invoke CreateDialogParam,hInstance,IDD_XPMANIFEST,hDEd,offset XPManifestEditProc,ebx
					mov		hDialog,eax
					invoke NotifyParent
				.elseif [ebx].PROJECT.ntype==TPE_RCDATA
					invoke CloseDialog
					invoke CreateDialogParam,hInstance,IDD_RCDATA,hDEd,offset RCDataEditProc,ebx
					mov		hDialog,eax
					invoke NotifyParent
				.elseif [ebx].PROJECT.ntype==TPE_TOOLBAR
					invoke CloseDialog
					invoke CreateDialogParam,hInstance,IDD_TOOLBAR,hDEd,offset ToolbarEditProc,ebx
					mov		hDialog,eax
					invoke NotifyParent
				.endif
			.endif
		.endif
	.endif
	ret

ProjectDblClick endp

TreeViewProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_LBUTTONDBLCLK
		invoke ProjectDblClick,hWin,lParam
		xor		eax,eax
	.else
		invoke CallWindowProc,OldTreeViewProc,hWin,uMsg,wParam,lParam
	.endif
	ret

TreeViewProc endp

Do_Project proc hWin:HWND

	invoke CreateWindowEx,0,addr szTreeViewClass,NULL,WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or TVS_HASLINES or TVS_HASBUTTONS or TVS_SHOWSELALWAYS,0,0,0,0,hWin,0,hInstance,0
	mov		hPrjTrv,eax
	invoke SetWindowLong,hPrjTrv,GWL_WNDPROC,offset TreeViewProc
	mov		OldTreeViewProc,eax
	invoke SendMessage,hPrjTrv,TVM_SETIMAGELIST,0,hPrjIml
	invoke SendMessage,hPrjTrv,TVM_SETBKCOLOR,0,color.back
	invoke SendMessage,hPrjTrv,TVM_SETTEXTCOLOR,0,color.text
	ret

Do_Project endp

ProjectSize proc ccx:DWORD,ccy:DWORD

	invoke MoveWindow,hPrjTrv,0,0,ccx,ccy,TRUE
	ret

ProjectSize endp

Do_TreeViewAddNode proc hWin:HWND,lhPar:DWORD,lhInsAfter:DWORD,pszText:DWORD,pidSel:DWORD,pidNosel:DWORD,lParam:LPARAM
	LOCAL   tvins:TV_INSERTSTRUCT

	m2m		tvins.hParent,lhPar
	m2m		tvins.hInsertAfter,lhInsAfter
	m2m		tvins.item.lParam,lParam
	mov		tvins.item._mask,TVIF_TEXT or TVIF_IMAGE or TVIF_SELECTEDIMAGE or TVIF_PARAM
	m2m		tvins.item.pszText,pszText
	m2m		tvins.item.iImage,pidSel
	m2m		tvins.item.iSelectedImage,pidNosel
	invoke SendMessage,hWin,TVM_INSERTITEM,0,addr tvins
	ret

Do_TreeViewAddNode endp

AddProjectNode proc nType:DWORD,lpName:DWORD,lParam:DWORD

	mov		eax,nType
	.if eax==TPE_DIALOG
		.if !hNodeDlg
			invoke Do_TreeViewAddNode,hPrjTrv,hRoot,TVI_SORT,offset szDialog,0,0,0
			mov		hNodeDlg,eax
		.endif
		invoke Do_TreeViewAddNode,hPrjTrv,hNodeDlg,TVI_SORT,lpName,1,1,lParam
	.elseif eax==TPE_MENU
		.if !hNodeMnu
			invoke Do_TreeViewAddNode,hPrjTrv,hRoot,TVI_SORT,offset szMenu,0,0,0
			mov		hNodeMnu,eax
		.endif
		invoke Do_TreeViewAddNode,hPrjTrv,hNodeMnu,TVI_SORT,lpName,2,2,lParam
	.elseif eax==TPE_INCLUDE || eax==TPE_ACCEL || eax==TPE_VERSION || eax==TPE_RESOURCE || eax==TPE_STRING || eax==TPE_LANGUAGE || eax==TPE_XPMANIFEST || eax==TPE_RCDATA || eax==TPE_TOOLBAR
		.if !hNodeMisc
			invoke Do_TreeViewAddNode,hPrjTrv,hRoot,TVI_SORT,offset szMisc,0,0,0
			mov		hNodeMisc,eax
		.endif
		mov		eax,nType
		.if eax==TPE_RESOURCE || eax==TPE_RCDATA || eax==TPE_TOOLBAR
			mov		eax,3
		.elseif eax==TPE_ACCEL
			mov		eax,4
		.elseif eax==TPE_VERSION
			mov		eax,5
		.elseif eax==TPE_STRING
			mov		eax,6
		.elseif eax==TPE_LANGUAGE
			mov		eax,7
		.else
			mov		eax,7
		.endif
		invoke Do_TreeViewAddNode,hPrjTrv,hNodeMisc,TVI_SORT,lpName,eax,eax,lParam
	.endif
	ret

AddProjectNode endp

ExpandProjectNodes proc hNode:DWORD

	invoke SendMessage,hPrjTrv,TVM_EXPAND,TVE_EXPAND,hRoot
	.if hNodeDlg
		mov		eax,hNode
		.if eax==hNodeDlg || !eax
			invoke SendMessage,hPrjTrv,TVM_EXPAND,TVE_EXPAND,hNodeDlg
		.endif
	.endif
	.if hNodeMnu
		mov		eax,hNode
		.if eax==hNodeMnu || !eax
			invoke SendMessage,hPrjTrv,TVM_EXPAND,TVE_EXPAND,hNodeMnu
		.endif
	.endif
	.if hNodeMisc
		mov		eax,hNode
		.if eax==hNodeMisc || !eax
			invoke SendMessage,hPrjTrv,TVM_EXPAND,TVE_EXPAND,hNodeMisc
		.endif
	.endif
	ret

ExpandProjectNodes endp

OpenProject proc uses esi,lpFileName:DWORD,hRCMem:DWORD
	LOCAL	hProMem:DWORD
	LOCAL	buffer[16]:BYTE

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,32768
	mov     hProMem,eax
	invoke GlobalLock,hProMem
	invoke SetWindowLong,hPrj,0,hProMem
	invoke strlen,lpFileName
	mov		edx,lpFileName
	.while byte ptr [edx+eax]!='\' && eax
		dec		eax
	.endw
	.if byte ptr [edx+eax]=='\'
		inc		eax
	.endif
	lea		edx,[edx+eax]
	push	edx
	invoke strcpyn,offset szProjectPath,lpFileName,eax
	invoke SetCurrentDirectory,offset szProjectPath
	invoke AddTypeMem,hProMem,64*1024,TPE_NAME
	invoke ParseRCMem,hRCMem,hProMem
	push	eax
	invoke GlobalUnlock,hRCMem
	invoke GlobalFree,hRCMem
	pop		eax
	pop		edx
	.if eax==-1
		jmp		Ex
	.endif
;	push	edx
;	mov		ecx,offset szResourceh
;  @@:
;	mov		al,[edx]
;	.if al!='.' && al
;		mov		[ecx],al
;		inc		edx
;		inc		ecx
;		jmp		@b
;	.endif
;	mov		dword ptr [ecx],'h.'
;	pop		edx
	mov		esi,hProMem
	invoke Do_TreeViewAddNode,hPrjTrv,TVI_ROOT,TVI_FIRST,edx,0,0,esi
	mov		hRoot,eax
	.while [esi].PROJECT.hmem
		.if [esi].PROJECT.ntype==TPE_DIALOG
			mov		eax,[esi].PROJECT.hmem
			lea		edx,[eax+sizeof DLGHEAD].DIALOG.idname
			.if !byte ptr [edx]
				lea		edx,buffer
				invoke ResEdBinToDec,[eax+sizeof DLGHEAD].DIALOG.id,edx
				lea		edx,buffer
			.endif
			invoke AddProjectNode,TPE_DIALOG,edx,esi
		.elseif [esi].PROJECT.ntype==TPE_MENU
			mov		eax,[esi].PROJECT.hmem
			lea		edx,[eax].MNUHEAD.menuname
			.if !byte ptr [edx]
				lea		edx,buffer
				invoke ResEdBinToDec,[eax].MNUHEAD.menuid,edx
				lea		edx,buffer
			.endif
			invoke AddProjectNode,TPE_MENU,edx,esi
		.elseif [esi].PROJECT.ntype==TPE_INCLUDE
			invoke AddProjectNode,TPE_INCLUDE,offset szIncludeFile,esi
		.elseif [esi].PROJECT.ntype==TPE_ACCEL
			mov		eax,[esi].PROJECT.hmem
			lea		edx,[eax].ACCELMEM.szname
			.if !byte ptr [edx]
				lea		edx,buffer
				invoke ResEdBinToDec,[eax].ACCELMEM.value,edx
				lea		edx,buffer
			.endif
			invoke AddProjectNode,TPE_ACCEL,edx,esi
		.elseif [esi].PROJECT.ntype==TPE_VERSION
			mov		eax,[esi].PROJECT.hmem
			lea		edx,[eax].VERSIONMEM.szname
			.if !byte ptr [edx]
				lea		edx,buffer
				invoke ResEdBinToDec,[eax].VERSIONMEM.value,edx
				lea		edx,buffer
			.endif
			invoke AddProjectNode,TPE_VERSION,edx,esi
		.elseif [esi].PROJECT.ntype==TPE_RESOURCE
			invoke AddProjectNode,TPE_RESOURCE,offset szResource,esi
		.elseif [esi].PROJECT.ntype==TPE_STRING
			invoke AddProjectNode,TPE_STRING,offset szStringTable,esi
		.elseif [esi].PROJECT.ntype==TPE_LANGUAGE
			invoke AddProjectNode,TPE_LANGUAGE,offset szLanguage,esi
		.elseif [esi].PROJECT.ntype==TPE_XPMANIFEST
			mov		eax,[esi].PROJECT.hmem
			lea		edx,[eax].XPMANIFESTMEM.szname
			.if !byte ptr [edx]
				lea		edx,buffer
				invoke ResEdBinToDec,[eax].XPMANIFESTMEM.value,edx
				lea		edx,buffer
			.endif
			invoke AddProjectNode,TPE_XPMANIFEST,edx,esi
		.elseif [esi].PROJECT.ntype==TPE_RCDATA
			mov		eax,[esi].PROJECT.hmem
			lea		edx,[eax].RCDATAMEM.szname
			.if !byte ptr [edx]
				lea		edx,buffer
				invoke ResEdBinToDec,[eax].RCDATAMEM.value,edx
				lea		edx,buffer
			.endif
			invoke AddProjectNode,TPE_RCDATA,edx,esi
		.elseif [esi].PROJECT.ntype==TPE_TOOLBAR
			mov		eax,[esi].PROJECT.hmem
			lea		edx,[eax].TOOLBARMEM.szname
			.if !byte ptr [edx]
				lea		edx,buffer
				invoke ResEdBinToDec,[eax].TOOLBARMEM.value,edx
				lea		edx,buffer
			.endif
			invoke AddProjectNode,TPE_TOOLBAR,edx,esi
		.endif
		add		esi,sizeof PROJECT
	.endw
	invoke ExpandProjectNodes,NULL
	mov		eax,hProMem
  Ex:
	ret

OpenProject endp

CloseProject proc uses esi,hProMem:DWORD

	invoke CloseDialog
	.if hRoot
		invoke SendMessage,hPrjTrv,TVM_DELETEITEM,0,TVI_ROOT
		mov		hRoot,0
		mov		hNodeDlg,0
		mov		hNodeMnu,0
		mov		hNodeMisc,0
	.endif
	mov		esi,hProMem
	.if esi
		.while [esi].PROJECT.hmem
			.if [esi].PROJECT.ntype==TPE_DIALOG
				mov		eax,[esi].PROJECT.hmem
				.if [eax].DLGHEAD.hred
					invoke DestroyWindow,[eax].DLGHEAD.hred
				.endif
			.elseif [esi].PROJECT.ntype==TPE_RCDATA
				mov		eax,[esi].PROJECT.hmem
				.if [eax].RCDATAMEM.hred
					invoke DestroyWindow,[eax].RCDATAMEM.hred
				.endif
			.elseif [esi].PROJECT.ntype==TPE_TOOLBAR
				mov		eax,[esi].PROJECT.hmem
				.if [eax].TOOLBARMEM.hred
					invoke DestroyWindow,[eax].TOOLBARMEM.hred
				.endif
			.elseif [esi].PROJECT.ntype==TPE_XPMANIFEST
				mov		eax,[esi].PROJECT.hmem
				.if [eax].XPMANIFESTMEM.hred
					invoke DestroyWindow,[eax].XPMANIFESTMEM.hred
				.endif
			.endif
			invoke GlobalUnlock,[esi].PROJECT.hmem
			invoke GlobalFree,[esi].PROJECT.hmem
			mov		[esi].PROJECT.hmem,0
			add		esi,sizeof PROJECT
		.endw
		invoke GlobalUnlock,hProMem
		invoke GlobalFree,hProMem
		mov		hProMem,0
	.endif
	ret

CloseProject endp

ExportProject proc lpRCMem:DWORD,lpDEFMem:DWORD,lpProMem:DWORD
	LOCAL	hMem:DWORD
	LOCAL	buff[32]:BYTE

	.if hDialog
		invoke SendMessage,hDialog,WM_COMMAND,BN_CLICKED shl 16 or IDOK,0
	.endif
	;Names
	mov		esi,lpProMem
	.while [esi].PROJECT.hmem
		.if ![esi].PROJECT.delete
			.if [esi].PROJECT.ntype==TPE_NAME
				mov		eax,[esi].PROJECT.hmem
				invoke ExportNamesNames,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_DIALOG
				mov		eax,[esi].PROJECT.hmem
				invoke ExportDialogNames,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_MENU
				mov		eax,[esi].PROJECT.hmem
				invoke ExportMenuNames,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_VERSION
				mov		eax,[esi].PROJECT.hmem
				invoke ExportVersionNames,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_ACCEL
				mov		eax,[esi].PROJECT.hmem
				invoke ExportAccelNames,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_RESOURCE
				mov		eax,[esi].PROJECT.hmem
				invoke ExportResourceNames,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_STRING
				mov		eax,[esi].PROJECT.hmem
				invoke ExportStringNames,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_XPMANIFEST
				mov		eax,[esi].PROJECT.hmem
				invoke ExportXPManifestNames,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_RCDATA
				mov		eax,[esi].PROJECT.hmem
				invoke ExportRCDataNames,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_TOOLBAR
				mov		eax,[esi].PROJECT.hmem
				invoke ExportToolbarNames,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.endif
		.endif
		add		esi,sizeof PROJECT
	.endw
	.if fNoDefines
		invoke strcpy,lpDEFMem,lpRCMem
		mov		eax,lpRCMem
		mov		dword ptr [eax],0
	.endif
	invoke strlen,lpRCMem
	.if eax
		invoke strcat,lpRCMem,offset szCrLf
	.endif
	;Include
	mov		esi,lpProMem
	.while [esi].PROJECT.hmem
		.if ![esi].PROJECT.delete
			.if [esi].PROJECT.ntype==TPE_INCLUDE
				mov		eax,[esi].PROJECT.hmem
				invoke ExportInclude,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.endif
		.endif
		add		esi,sizeof PROJECT
	.endw
	.if !fResourceh && fNoDefines
		invoke strcat,lpRCMem,offset szINCLUDE
		mov		dword ptr buff,'" '
		invoke strcat,lpRCMem,addr buff
		invoke strcat,lpRCMem,addr szResourceh
		mov		dword ptr buff,'"'
		invoke strcat,lpRCMem,addr buff
		mov		dword ptr buff,0A0Dh
		invoke strcat,lpRCMem,addr buff
	.endif
	;Language
	mov		esi,lpProMem
	.while [esi].PROJECT.hmem
		.if ![esi].PROJECT.delete
			.if [esi].PROJECT.ntype==TPE_LANGUAGE
				mov		eax,[esi].PROJECT.hmem
				invoke ExportLanguage,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.endif
		.endif
		add		esi,sizeof PROJECT
	.endw
	;The rest
	mov		esi,lpProMem
	.while [esi].PROJECT.hmem
		.if ![esi].PROJECT.delete
			.if [esi].PROJECT.ntype==TPE_DIALOG
				mov		eax,[esi].PROJECT.hmem
				invoke ExportDialog,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_MENU
				mov		eax,[esi].PROJECT.hmem
				.if [eax].MNUHEAD.menuex
					invoke ExportMenuEx,eax
				.else
					invoke ExportMenu,eax
				.endif
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_VERSION
				mov		eax,[esi].PROJECT.hmem
				invoke ExportVersion,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_ACCEL
				mov		eax,[esi].PROJECT.hmem
				invoke ExportAccel,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_RESOURCE
				mov		eax,[esi].PROJECT.hmem
				invoke ExportResource,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_STRING
				mov		eax,[esi].PROJECT.hmem
				invoke ExportString,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_XPMANIFEST
				mov		eax,[esi].PROJECT.hmem
				invoke ExportXPManifest,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_RCDATA
				mov		eax,[esi].PROJECT.hmem
				invoke ExportRCData,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.elseif [esi].PROJECT.ntype==TPE_TOOLBAR
				mov		eax,[esi].PROJECT.hmem
				invoke ExportToolbar,eax
				.if eax
					mov		hMem,eax
					invoke strcat,lpRCMem,hMem
					invoke GlobalUnlock,hMem
					invoke GlobalFree,hMem
				.endif
			.endif
		.endif
		add		esi,sizeof PROJECT
	.endw
	ret

ExportProject endp

GetProjectModify proc uses esi,lpProMem:DWORD

	mov		esi,lpProMem
	xor		eax,eax
	.while [esi].PROJECT.hmem
		mov		eax,[esi].PROJECT.changed
		.break .if eax
		.if ![esi].PROJECT.delete
			.if [esi].PROJECT.ntype==TPE_DIALOG
				mov		edx,[esi].PROJECT.hmem
				mov		eax,[edx].DLGHEAD.changed
				.break .if eax
			.endif
		.endif
		add		esi,sizeof PROJECT
	.endw
	ret

GetProjectModify endp

SetProjectModify proc uses esi,lpProMem:DWORD,fChanged:DWORD

	mov		esi,lpProMem
	mov		eax,fChanged
	.while [esi].PROJECT.hmem
		mov		[esi].PROJECT.changed,eax
		.if [esi].PROJECT.ntype==TPE_DIALOG
			mov		edx,[esi].PROJECT.hmem
			mov		[edx].DLGHEAD.changed,eax
		.endif
		add		esi,sizeof PROJECT
	.endw
	invoke InvalidateRect,hDEd,NULL,TRUE
	ret

SetProjectModify endp

AddProjectItem proc uses esi,lpProMem:DWORD,nType:DWORD,fOpen:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		esi,lpProMem
	.while [esi].PROJECT.hmem
		add		esi,sizeof PROJECT
	.endw
	mov		eax,nType
	.if eax==TPE_DIALOG
		invoke CreateDlg,hDEd,esi,FALSE
		mov		[esi].PROJECT.hmem,eax
		mov		[esi].PROJECT.ntype,TPE_DIALOG
		invoke GetProjectItemName,esi,addr buffer
		invoke AddProjectNode,TPE_DIALOG,addr buffer,esi
		invoke ExpandProjectNodes,hNodeDlg
	.elseif eax==TPE_MENU
		invoke CloseDialog
		invoke CreateMnu,hDEd,NULL
		mov		[esi].PROJECT.hmem,eax
		mov		[esi].PROJECT.ntype,TPE_MENU
		invoke SetWindowLong,hDialog,GWL_USERDATA,esi
		invoke GetProjectItemName,esi,addr buffer
		invoke AddProjectNode,TPE_MENU,addr buffer,esi
		invoke ExpandProjectNodes,hNodeMnu
		invoke NotifyParent
	.elseif eax==TPE_ACCEL
		.if fOpen
			invoke CloseDialog
			invoke CreateDialogParam,hInstance,IDD_DLGACCEL,hDEd,offset AccelEditProc,NULL
			mov		hDialog,eax
			invoke NotifyParent
		.else
			invoke AddProjectNode,TPE_ACCEL,offset szACCELERATORS,esi
			invoke AddTypeMem,lpProMem,64*1024,TPE_ACCEL
			invoke ExpandProjectNodes,hNodeMisc
		.endif
	.elseif eax==TPE_VERSION
		.if fOpen
			invoke CloseDialog
			invoke CreateDialogParam,hInstance,IDD_DLGVERSION,hDEd,offset VersionEditProc,NULL
			mov		hDialog,eax
			invoke NotifyParent
		.else
			invoke AddProjectNode,TPE_VERSION,offset szVERSIONINFO,esi
			invoke AddTypeMem,lpProMem,64*1024,TPE_VERSION
			invoke ExpandProjectNodes,hNodeMisc
		.endif
	.elseif eax==TPE_INCLUDE
		invoke GetTypeMem,lpProMem,TPE_INCLUDE
		xor		edx,edx
		.if eax
			mov		edx,[eax].PROJECT.hmem
		.endif
		.if fOpen
			push	eax
			invoke CloseDialog
			pop		eax
			.if !dword ptr [eax]
				xor		eax,eax
			.endif
			invoke CreateDialogParam,hInstance,IDD_DLGINCLUDE,hDEd,offset IncludeEditProc,eax
			mov		hDialog,eax
			invoke NotifyParent
		.elseif !edx
			invoke AddProjectNode,TPE_INCLUDE,offset szIncludeFile,esi
			invoke AddTypeMem,lpProMem,64*1024,TPE_INCLUDE
			invoke ExpandProjectNodes,hNodeMisc
		.endif
	.elseif eax==TPE_RESOURCE
		invoke GetTypeMem,lpProMem,TPE_RESOURCE
		xor		edx,edx
		.if eax
			mov		edx,[eax].PROJECT.hmem
		.endif
		.if fOpen
			push	eax
			invoke CloseDialog
			pop		eax
			.if !dword ptr [eax]
				xor		eax,eax
			.endif
			invoke CreateDialogParam,hInstance,IDD_DLGRESOURCE,hDEd,offset ResourceEditProc,eax
			mov		hDialog,eax
			invoke NotifyParent
		.elseif !edx
			invoke AddProjectNode,TPE_RESOURCE,offset szResource,esi
			invoke AddTypeMem,lpProMem,64*1024,TPE_RESOURCE
			invoke ExpandProjectNodes,hNodeMisc
		.endif
	.elseif eax==TPE_STRING
		.if fOpen
			invoke CloseDialog
			invoke CreateDialogParam,hInstance,IDD_DLGSTRING,hDEd,offset StringEditProc,NULL
			mov		hDialog,eax
			invoke NotifyParent
		.else
			invoke AddProjectNode,TPE_STRING,offset szStringTable,esi
			invoke AddTypeMem,lpProMem,512*1024,TPE_STRING
			invoke ExpandProjectNodes,hNodeMisc
		.endif
	.elseif eax==TPE_LANGUAGE
		invoke GetTypeMem,lpProMem,TPE_LANGUAGE
		xor		edx,edx
		.if eax
			mov		edx,[eax].PROJECT.hmem
		.endif
		.if fOpen
			push	eax
			invoke CloseDialog
			pop		eax
			invoke CreateDialogParam,hInstance,IDD_LANGUAGECHILD,hDEd,offset LanguageEditProc,eax
			mov		hDialog,eax
			invoke NotifyParent
		.elseif !edx
			invoke AddProjectNode,TPE_LANGUAGE,offset szLanguage,esi
			invoke AddTypeMem,lpProMem,sizeof LANGUAGEMEM,TPE_LANGUAGE
			invoke ExpandProjectNodes,hNodeMisc
		.endif
	.elseif eax==TPE_XPMANIFEST
		.if fOpen
			invoke CloseDialog
			invoke CreateDialogParam,hInstance,IDD_XPMANIFEST,hDEd,offset XPManifestEditProc,NULL
			mov		hDialog,eax
			invoke NotifyParent
		.else
			invoke AddTypeMem,lpProMem,10*1024,TPE_XPMANIFEST
			invoke AddProjectNode,TPE_XPMANIFEST,offset szMANIFEST,esi
			invoke ExpandProjectNodes,hNodeMisc
		.endif
	.elseif eax==TPE_RCDATA
		.if fOpen
			invoke CloseDialog
			invoke CreateDialogParam,hInstance,IDD_RCDATA,hDEd,offset RCDataEditProc,NULL
			mov		hDialog,eax
			invoke NotifyParent
		.else
			invoke AddTypeMem,lpProMem,64*1024,TPE_RCDATA
			invoke AddProjectNode,TPE_RCDATA,offset szRCDATA,esi
			invoke ExpandProjectNodes,hNodeMisc
		.endif
	.elseif eax==TPE_TOOLBAR
		.if fOpen
			invoke CloseDialog
			invoke CreateDialogParam,hInstance,IDD_TOOLBAR,hDEd,offset ToolbarEditProc,NULL
			mov		hDialog,eax
			invoke NotifyParent
		.else
			invoke AddTypeMem,lpProMem,64*1024,TPE_TOOLBAR
			invoke AddProjectNode,TPE_TOOLBAR,offset szTOOLBAR,esi
			invoke ExpandProjectNodes,hNodeMisc
		.endif
	.endif
	mov		eax,esi
	ret

AddProjectItem endp

GetProjectItemName proc uses esi,lpProItemMem:DWORD,lpBuff:DWORD

	mov		esi,lpProItemMem
	mov		eax,[esi].PROJECT.ntype
	mov		esi,[esi].PROJECT.hmem
	.if eax==TPE_DIALOG
		lea		eax,[esi+sizeof DLGHEAD].DIALOG.idname
		mov		edx,[esi+sizeof DLGHEAD].DIALOG.id
		call	CopyName
	.elseif eax==TPE_MENU
		lea		eax,[esi].MNUHEAD.menuname
		mov		edx,[esi].MNUHEAD.menuid
		call	CopyName
	.elseif eax==TPE_ACCEL
		lea		eax,[esi].ACCELMEM.szname
		mov		edx,[esi].ACCELMEM.value
		call	CopyName
	.elseif eax==TPE_VERSION
		lea		eax,[esi].VERSIONMEM.szname
		mov		edx,[esi].VERSIONMEM.value
		call	CopyName
	.elseif eax==TPE_RESOURCE
		invoke strcpy,lpBuff,offset szResource
	.elseif eax==TPE_INCLUDE
		invoke strcpy,lpBuff,offset szIncludeFile
	.elseif eax==TPE_STRING
		invoke strcpy,lpBuff,offset szStringTable
	.elseif eax==TPE_XPMANIFEST
		lea		eax,[esi].XPMANIFESTMEM.szname
		mov		edx,[esi].XPMANIFESTMEM.value
		call	CopyName
	.elseif eax==TPE_RCDATA
		lea		eax,[esi].RCDATAMEM.szname
		mov		edx,[esi].RCDATAMEM.value
		call	CopyName
	.elseif eax==TPE_TOOLBAR
		lea		eax,[esi].TOOLBARMEM.szname
		mov		edx,[esi].TOOLBARMEM.value
		call	CopyName
	.endif
	ret

CopyName:
	.if byte ptr [eax]
		invoke strcpy,lpBuff,eax
	.else
		invoke ResEdBinToDec,edx,lpBuff
	.endif
	retn

GetProjectItemName endp

SetProjectItemName proc uses esi,lpProItemMem:DWORD,lpName:DWORD
	LOCAL	tvi:TV_ITEMEX

	invoke GetWindowLong,hPrj,0
	.if eax
		mov		eax,lpProItemMem
		.if eax
			mov		eax,[eax].PROJECT.ntype
		.endif
		.if !eax
			mov		tvi.imask,TVIF_TEXT
			mov		eax,hRoot
			mov		tvi.hItem,eax
			mov		eax,lpName
			mov		tvi.pszText,eax
			invoke SendMessage,hPrjTrv,TVM_SETITEM,0,addr tvi
		.elseif eax==TPE_DIALOG
			mov		tvi.imask,TVIF_HANDLE or TVIF_PARAM
			invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_CHILD,hNodeDlg
			.while eax
				mov		tvi.hItem,eax
				invoke SendMessage,hPrjTrv,TVM_GETITEM,0,addr tvi
				mov		eax,tvi.lParam
				.if eax==lpProItemMem
					mov		tvi.imask,TVIF_TEXT
					mov		eax,lpName
					mov		tvi.pszText,eax
					invoke SendMessage,hPrjTrv,TVM_SETITEM,0,addr tvi
					invoke SendMessage,hPrjTrv,TVM_SORTCHILDREN,0,hNodeDlg
					jmp		Ex
				.endif
				invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_NEXT,tvi.hItem
			.endw
		.elseif eax==TPE_MENU
			mov		tvi.imask,TVIF_HANDLE or TVIF_PARAM
			invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_CHILD,hNodeMnu
			.while eax
				mov		tvi.hItem,eax
				invoke SendMessage,hPrjTrv,TVM_GETITEM,0,addr tvi
				mov		eax,tvi.lParam
				.if eax==lpProItemMem
					mov		tvi.imask,TVIF_TEXT
					mov		eax,lpName
					mov		tvi.pszText,eax
					invoke SendMessage,hPrjTrv,TVM_SETITEM,0,addr tvi
					invoke SendMessage,hPrjTrv,TVM_SORTCHILDREN,0,hNodeMnu
					jmp		Ex
				.endif
				invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_NEXT,tvi.hItem
			.endw
		.elseif eax==TPE_ACCEL
			mov		tvi.imask,TVIF_HANDLE or TVIF_PARAM
			invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_CHILD,hNodeMisc
			.while eax
				mov		tvi.hItem,eax
				invoke SendMessage,hPrjTrv,TVM_GETITEM,0,addr tvi
				mov		eax,tvi.lParam
				.if eax==lpProItemMem
					mov		tvi.imask,TVIF_TEXT
					mov		eax,lpName
					mov		tvi.pszText,eax
					invoke SendMessage,hPrjTrv,TVM_SETITEM,0,addr tvi
					invoke SendMessage,hPrjTrv,TVM_SORTCHILDREN,0,hNodeMisc
					jmp		Ex
				.endif
				invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_NEXT,tvi.hItem
			.endw
		.elseif eax==TPE_VERSION
			mov		tvi.imask,TVIF_HANDLE or TVIF_PARAM
			invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_CHILD,hNodeMisc
			.while eax
				mov		tvi.hItem,eax
				invoke SendMessage,hPrjTrv,TVM_GETITEM,0,addr tvi
				mov		eax,tvi.lParam
				.if eax==lpProItemMem
					mov		tvi.imask,TVIF_TEXT
					mov		eax,lpName
					mov		tvi.pszText,eax
					invoke SendMessage,hPrjTrv,TVM_SETITEM,0,addr tvi
					invoke SendMessage,hPrjTrv,TVM_SORTCHILDREN,0,hNodeMisc
					jmp		Ex
				.endif
				invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_NEXT,tvi.hItem
			.endw
		.elseif eax==TPE_XPMANIFEST
			mov		tvi.imask,TVIF_HANDLE or TVIF_PARAM
			invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_CHILD,hNodeMisc
			.while eax
				mov		tvi.hItem,eax
				invoke SendMessage,hPrjTrv,TVM_GETITEM,0,addr tvi
				mov		eax,tvi.lParam
				.if eax==lpProItemMem
					mov		tvi.imask,TVIF_TEXT
					mov		eax,lpName
					mov		tvi.pszText,eax
					invoke SendMessage,hPrjTrv,TVM_SETITEM,0,addr tvi
					invoke SendMessage,hPrjTrv,TVM_SORTCHILDREN,0,hNodeMisc
					jmp		Ex
				.endif
				invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_NEXT,tvi.hItem
			.endw
		.elseif eax==TPE_RCDATA
			mov		tvi.imask,TVIF_HANDLE or TVIF_PARAM
			invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_CHILD,hNodeMisc
			.while eax
				mov		tvi.hItem,eax
				invoke SendMessage,hPrjTrv,TVM_GETITEM,0,addr tvi
				mov		eax,tvi.lParam
				.if eax==lpProItemMem
					mov		tvi.imask,TVIF_TEXT
					mov		eax,lpName
					mov		tvi.pszText,eax
					invoke SendMessage,hPrjTrv,TVM_SETITEM,0,addr tvi
					invoke SendMessage,hPrjTrv,TVM_SORTCHILDREN,0,hNodeMisc
					jmp		Ex
				.endif
				invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_NEXT,tvi.hItem
			.endw
		.elseif eax==TPE_TOOLBAR
			mov		tvi.imask,TVIF_HANDLE or TVIF_PARAM
			invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_CHILD,hNodeMisc
			.while eax
				mov		tvi.hItem,eax
				invoke SendMessage,hPrjTrv,TVM_GETITEM,0,addr tvi
				mov		eax,tvi.lParam
				.if eax==lpProItemMem
					mov		tvi.imask,TVIF_TEXT
					mov		eax,lpName
					mov		tvi.pszText,eax
					invoke SendMessage,hPrjTrv,TVM_SETITEM,0,addr tvi
					invoke SendMessage,hPrjTrv,TVM_SORTCHILDREN,0,hNodeMisc
					jmp		Ex
				.endif
				invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_NEXT,tvi.hItem
			.endw
		.endif
	.endif
  Ex:
	ret

SetProjectItemName endp

GetProjectSelected proc
	LOCAL	tvi:TV_ITEMEX

	invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_CARET,NULL
	.if eax
		mov		tvi.hItem,eax
		mov		tvi.imask,TVIF_PARAM
		invoke SendMessage,hPrjTrv,TVM_GETITEM,0,addr tvi
		.if eax
			mov		eax,tvi.lParam
			.if eax
				mov		eax,[eax].PROJECT.ntype
			.endif
		.endif
	.endif
	ret

GetProjectSelected endp

RemoveProjectSelected proc uses esi
	LOCAL	tvi:TV_ITEMEX
	LOCAL	fName:DWORD

	mov		fName,FALSE
	invoke SendMessage,hPrjTrv,TVM_GETNEXTITEM,TVGN_CARET,NULL
	.if eax
		mov		tvi.hItem,eax
		mov		tvi.imask,TVIF_PARAM
		invoke SendMessage,hPrjTrv,TVM_GETITEM,0,addr tvi
		.if eax
			mov		edx,tvi.lParam
			.if edx
				mov		eax,[edx].PROJECT.ntype
				.if eax && eax!=TPE_NAME
					.if hDialog
						invoke GetWindowLong,hDialog,GWL_USERDATA
						.if eax==tvi.lParam
							invoke SendMessage,hDialog,WM_COMMAND,IDOK,0
							invoke SendMessage,hDialog,WM_COMMAND,IDCANCEL,0
						.else
							invoke GetWindowLong,hPrj,0
							mov		esi,eax
							invoke GetWindowLong,hDialog,GWL_USERDATA
							.while [esi].PROJECT.hmem
								.if [esi].PROJECT.ntype==TPE_NAME
									.if eax==esi
										invoke SendMessage,hDialog,WM_COMMAND,IDOK,0
										invoke SendMessage,hDialog,WM_COMMAND,IDCANCEL,0
										mov		fName,TRUE
									.endif
									.break
								.endif
								add		esi,sizeof PROJECT
							.endw
						.endif
					.endif
					invoke GetWindowLong,hDEd,DEWM_DIALOG
					mov		ecx,eax
					inc		nUndo
					mov		eax,nUndo
					mov		edx,tvi.lParam
					mov		[edx].PROJECT.delete,eax
					.if [edx].PROJECT.ntype==TPE_DIALOG
						mov		esi,[edx].PROJECT.hmem
						mov		eax,[esi+sizeof DLGHEAD].DIALOG.hwnd
						.if eax==ecx
							.if [esi].DLGHEAD.ftextmode
								invoke ShowWindow,[esi].DLGHEAD.hred,SW_HIDE
							.else
								invoke DestroySizeingRect
							.endif
							invoke DestroyWindow,[esi+sizeof DLGHEAD].DIALOG.hwnd
							invoke SetWindowLong,hDEd,DEWM_DIALOG,0
							invoke SetWindowLong,hDEd,DEWM_MEMORY,0
						.endif
					.elseif [edx].PROJECT.ntype==TPE_XPMANIFEST
						invoke GetWindowLong,hPrj,0
						mov		esi,eax
						xor		ecx,ecx
						.while [esi].PROJECT.hmem
							.if ![esi].PROJECT.delete && [esi].PROJECT.ntype==TPE_XPMANIFEST
								inc		ecx
							.endif
							add		esi,sizeof PROJECT
						.endw
						.if !ecx
							invoke GetWindowLong,hPrj,0
							invoke FindName,eax,addr szMANIFEST
							.if eax
								mov		[eax].NAMEMEM.delete,TRUE
							.endif
						.endif
					.endif
					.if fName
						invoke CreateDialogParam,hInstance,IDD_DLGNAMES,hDEd,offset NameEditProc,NULL
						mov		hDialog,eax
					.endif
					invoke SendMessage,hPrjTrv,TVM_DELETEITEM,0,tvi.hItem
					invoke SendMessage,hRes,PRO_SETMODIFY,TRUE,0
				.endif
			.endif
		.endif
	.endif
	ret

RemoveProjectSelected endp

ProjectCanUndo proc uses esi

	invoke GetWindowLong,hPrj,0
	.if eax
		mov		esi,eax
		xor		eax,eax
		.while [esi].PROJECT.hmem
			.if [esi].PROJECT.delete
				mov		eax,TRUE
			.endif
			add		esi,sizeof PROJECT
		.endw
	.endif
	ret

ProjectCanUndo endp

ProjectUndoDeleted proc uses ebx esi
	LOCAL	buffer[64]:BYTE
	LOCAL	fName:DWORD

	mov		fName,FALSE
	invoke GetWindowLong,hPrj,0
	.if eax
		mov		esi,eax
		xor		eax,eax
		xor		ebx,ebx
		.while [esi].PROJECT.hmem
			.if eax<[esi].PROJECT.delete
				mov		eax,[esi].PROJECT.delete
				mov		ebx,esi
			.endif
			add		esi,sizeof PROJECT
		.endw
		.if ebx
			.if hDialog
				invoke GetWindowLong,hPrj,0
				mov		esi,eax
				invoke GetWindowLong,hDialog,GWL_USERDATA
				.while [esi].PROJECT.hmem
					.if [esi].PROJECT.ntype==TPE_NAME
						.if eax==esi
							invoke SendMessage,hDialog,WM_COMMAND,IDOK,0
							invoke SendMessage,hDialog,WM_COMMAND,IDCANCEL,0
							mov		fName,TRUE
						.endif
						.break
					.endif
					add		esi,sizeof PROJECT
				.endw
			.endif
			mov		[ebx].PROJECT.delete,FALSE
			invoke GetProjectItemName,ebx,addr buffer
			mov		edx,[ebx].PROJECT.ntype
			invoke AddProjectNode,edx,addr buffer,ebx
			invoke SendMessage,hRes,PRO_SETMODIFY,TRUE,0
			.if [ebx].PROJECT.ntype==TPE_XPMANIFEST
				invoke GetWindowLong,hPrj,0
				mov		esi,eax
				invoke FindName,esi,addr szMANIFEST
				.if !eax
					invoke AddName,esi,addr szMANIFEST,addr szManifestValue
				.endif
			.endif
			.if fName
				invoke CreateDialogParam,hInstance,IDD_DLGNAMES,hDEd,offset NameEditProc,NULL
				mov		hDialog,eax
			.endif
		.endif
	.endif
	ret

ProjectUndoDeleted endp

GetFreeProjectitemID proc uses esi edi,nType:DWORD

	invoke GetWindowLong,hPrj,0
	.if eax
		mov		esi,eax
		sub		eax,sizeof PROJECT
		mov		edi,eax
		mov		eax,nType
		.if eax==TPE_DIALOG
			mov		eax,initid.dlg.startid
			.while [esi].PROJECT.hmem
				.if [esi].PROJECT.ntype==TPE_DIALOG
					.if ![esi].PROJECT.delete
						mov		edx,[esi].PROJECT.hmem
						add		edx,sizeof DLGHEAD
						.if eax==[edx].DIALOG.id
							add		eax,initid.dlg.incid
							mov		esi,edi
						.endif
					.endif
				.endif
				add		esi,sizeof PROJECT
			.endw
		.elseif eax==TPE_MENU
			mov		eax,initid.mnu.startid
			.while [esi].PROJECT.hmem
				.if [esi].PROJECT.ntype==TPE_MENU
					.if ![esi].PROJECT.delete
						mov		edx,[esi].PROJECT.hmem
						.if eax==[edx].MNUHEAD.menuid
							add		eax,initid.mnu.incid
							mov		esi,edi
						.endif
					.endif
				.endif
				add		esi,sizeof PROJECT
			.endw
		.elseif eax==TPE_ACCEL
			mov		eax,initid.acl.startid
			.while [esi].PROJECT.hmem
				.if [esi].PROJECT.ntype==TPE_ACCEL
					.if ![esi].PROJECT.delete
						mov		edx,[esi].PROJECT.hmem
						.if eax==[edx].ACCELMEM.value
							add		eax,initid.acl.incid
							mov		esi,edi
						.endif
					.endif
				.endif
				add		esi,sizeof PROJECT
			.endw
		.elseif eax==TPE_VERSION
			mov		eax,initid.ver.startid
			.while [esi].PROJECT.hmem
				.if [esi].PROJECT.ntype==TPE_VERSION
					.if ![esi].PROJECT.delete
						mov		edx,[esi].PROJECT.hmem
						.if eax==[edx].VERSIONMEM.value
							add		eax,initid.ver.incid
							mov		esi,edi
						.endif
					.endif
				.endif
				add		esi,sizeof PROJECT
			.endw
		.elseif eax==TPE_XPMANIFEST
			mov		eax,initid.man.startid
			.while [esi].PROJECT.hmem
				.if [esi].PROJECT.ntype==TPE_XPMANIFEST
					.if ![esi].PROJECT.delete
						mov		edx,[esi].PROJECT.hmem
						.if eax==[edx].XPMANIFESTMEM.value
							add		eax,initid.man.incid
							mov		esi,edi
						.endif
					.endif
				.endif
				add		esi,sizeof PROJECT
			.endw
		.elseif eax==TPE_RCDATA
			mov		eax,initid.rcd.startid
			.while [esi].PROJECT.hmem
				.if [esi].PROJECT.ntype==TPE_RCDATA
					.if ![esi].PROJECT.delete
						mov		edx,[esi].PROJECT.hmem
						.if eax==[edx].RCDATAMEM.value
							add		eax,initid.rcd.incid
							mov		esi,edi
						.endif
					.endif
				.endif
				add		esi,sizeof PROJECT
			.endw
		.elseif eax==TPE_TOOLBAR
			mov		eax,initid.rcd.startid
			.while [esi].PROJECT.hmem
				.if [esi].PROJECT.ntype==TPE_TOOLBAR
					.if ![esi].PROJECT.delete
						mov		edx,[esi].PROJECT.hmem
						.if eax==[edx].TOOLBARMEM.value
							add		eax,initid.rcd.incid
							mov		esi,edi
						.endif
					.endif
				.endif
				add		esi,sizeof PROJECT
			.endw
		.elseif eax==TPE_RESOURCE
			mov		eax,initid.res.startid
			.while [esi].PROJECT.hmem
				.if [esi].PROJECT.ntype==TPE_RESOURCE
					.if ![esi].PROJECT.delete
						mov		edx,[esi].PROJECT.hmem
						.while [edx].RESOURCEMEM.szfile
							.if eax==[edx].RESOURCEMEM.value
								add		eax,initid.res.incid
								mov		esi,edi
								.break
							.endif
							add		edx,sizeof RESOURCEMEM
						.endw
					.endif
				.endif
				add		esi,sizeof PROJECT
			.endw
		.endif
	.endif
	ret

GetFreeProjectitemID endp

GetUnikeName proc uses ebx esi,lpName:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer1[MaxName]:BYTE
	LOCAL	buffer2[16]:BYTE

	mov		nInx,0
  @@:
	inc		nInx
	invoke strcpy,addr buffer1,lpName
	invoke ResEdBinToDec,nInx,addr buffer2
	invoke strcat,addr buffer1,addr buffer2
	invoke GetWindowLong,hPrj,0
	mov		ebx,eax
	.while [ebx].PROJECT.hmem
		.if ![ebx].PROJECT.delete
			mov		eax,[ebx].PROJECT.ntype
			mov		esi,[ebx].PROJECT.hmem
			.if eax==TPE_DIALOG
				lea		esi,[esi+sizeof DLGHEAD]
				.while [esi].DIALOG.hwnd
					.if [esi].DIALOG.hwnd!=-1
						invoke strcmpi,addr buffer1,addr [esi].DIALOG.idname
						.if !eax
							jmp		@b
						.endif
					.endif
					lea		esi,[esi+sizeof DIALOG]
				.endw
			.elseif eax==TPE_MENU
				invoke strcmpi,addr buffer1,addr [esi].MNUHEAD.menuname
				.if !eax
					jmp		@b
				.endif
				add		esi,sizeof MNUHEAD
				.while [esi].MNUITEM.itemflag
					.if [esi].MNUITEM.itemname
						invoke strcmpi,addr buffer1,addr [esi].MNUITEM.itemname
						.if !eax
							jmp		@b
						.endif
					.endif
					add		esi,sizeof MNUITEM
				.endw
			.elseif eax==TPE_ACCEL
				.while [esi].ACCELMEM.szname || [esi].ACCELMEM.value
					.if [esi].ACCELMEM.szname
						invoke strcmpi,addr buffer1,addr [esi].ACCELMEM.szname
						.if !eax
							jmp		@b
						.endif
					.endif
					add		esi,sizeof ACCELMEM
				.endw
			.elseif eax==TPE_VERSION
				invoke strcmpi,addr buffer1,addr [esi].VERSIONMEM.szname
				.if !eax
					jmp		@b
				.endif
			.elseif eax==TPE_XPMANIFEST
				invoke strcmpi,addr buffer1,addr [esi].XPMANIFESTMEM.szname
				.if !eax
					jmp		@b
				.endif
			.elseif eax==TPE_RCDATA
				invoke strcmpi,addr buffer1,addr [esi].RCDATAMEM.szname
				.if !eax
					jmp		@b
				.endif
			.elseif eax==TPE_TOOLBAR
				invoke strcmpi,addr buffer1,addr [esi].TOOLBARMEM.szname
				.if !eax
					jmp		@b
				.endif
			.elseif eax==TPE_NAME
				.while [esi].NAMEMEM.szname
					.if ![esi].NAMEMEM.delete
						invoke strcmpi,addr buffer1,addr [esi].NAMEMEM.szname
						.if !eax
							jmp		@b
						.endif
					.endif
					add		esi,sizeof NAMEMEM
				.endw
			.endif
		.endif
		lea		ebx,[ebx+sizeof PROJECT]
	.endw
	invoke strcpy,lpName,addr buffer1
	ret

GetUnikeName endp

NameExists proc uses ebx esi,lpName:DWORD,lpItem:DWORD

	invoke strlen,lpName
	.if eax
		invoke GetWindowLong,hPrj,0
		mov		ebx,eax
		.while [ebx].PROJECT.hmem
			.if ![ebx].PROJECT.delete
				mov		eax,[ebx].PROJECT.ntype
				mov		esi,[ebx].PROJECT.hmem
				.if eax==TPE_DIALOG
					lea		esi,[esi+sizeof DLGHEAD]
					.while [esi].DIALOG.hwnd
						.if [esi].DIALOG.hwnd!=-1 && esi!=lpItem
							invoke strcmpi,lpName,addr [esi].DIALOG.idname
							.if !eax
								jmp		Exist
							.endif
						.endif
						lea		esi,[esi+sizeof DIALOG]
					.endw
				.elseif eax==TPE_MENU
					.if esi!=lpItem
						invoke strcmpi,lpName,addr [esi].MNUHEAD.menuname
						.if !eax
							jmp		Exist
						.endif
					.endif
					add		esi,sizeof MNUHEAD
					.while [esi].MNUITEM.itemflag
						.if [esi].MNUITEM.itemname && esi!=lpItem
							invoke strcmpi,lpName,addr [esi].MNUITEM.itemname
							.if !eax
								jmp		Exist
							.endif
						.endif
						add		esi,sizeof MNUITEM
					.endw
				.elseif eax==TPE_ACCEL
					.while [esi].ACCELMEM.szname || [esi].ACCELMEM.value
						.if [esi].ACCELMEM.szname && esi!=lpItem
							invoke strcmpi,lpName,addr [esi].ACCELMEM.szname
							.if !eax
								jmp		Exist
							.endif
						.endif
						add		esi,sizeof ACCELMEM
					.endw
				.elseif eax==TPE_VERSION
					.if esi!=lpItem
						invoke strcmpi,lpName,addr [esi].VERSIONMEM.szname
						.if !eax
							jmp		Exist
						.endif
					.endif
				.elseif eax==TPE_XPMANIFEST
					.if esi!=lpItem
						invoke strcmpi,lpName,addr [esi].XPMANIFESTMEM.szname
						.if !eax
							jmp		Exist
						.endif
					.endif
				.elseif eax==TPE_RCDATA
					.if esi!=lpItem
						invoke strcmpi,lpName,addr [esi].RCDATAMEM.szname
						.if !eax
							jmp		Exist
						.endif
					.endif
				.elseif eax==TPE_TOOLBAR
					.if esi!=lpItem
						invoke strcmpi,lpName,addr [esi].TOOLBARMEM.szname
						.if !eax
							jmp		Exist
						.endif
					.endif
				.elseif eax==TPE_NAME
					.while [esi].NAMEMEM.szname
						.if ![esi].NAMEMEM.delete && esi!=lpItem
							invoke strcmpi,lpName,addr [esi].NAMEMEM.szname
							.if !eax
								jmp		Exist
							.endif
						.endif
						add		esi,sizeof NAMEMEM
					.endw
				.endif
			.endif
			lea		ebx,[ebx+sizeof PROJECT]
		.endw
	.endif
	xor		eax,eax
	ret
  Exist:
	mov		eax,TRUE
	ret

NameExists endp

