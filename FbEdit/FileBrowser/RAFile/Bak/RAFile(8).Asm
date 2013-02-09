;KetilO (C) 2004
;Build dll with release build
;Build lib with debug build
;Thanks to X05 for his file change notification example

.386
.model flat,stdcall
option casemap:none
option proc:private

include Data.inc
include ..\RAFile.inc

.code

InstallFileBrowser proc public hInst:HINSTANCE,fGlobal:DWORD
	LOCAL	wc:WNDCLASSEX

	;Create a windowclass for the user control
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	.if fGlobal
		mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_GLOBALCLASS
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
	mov		wc.lpszClassName,offset szFBClassName
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	ret

InstallFileBrowser endp

UnInstallFileBrowser proc public

	ret

UnInstallFileBrowser endp

;--------------------------------------------------------------------------------

xInString proc lpStr:DWORD,lpSrc:DWORD
	LOCAL	buffer[256]:BYTE

	push	esi
	push	edi
	mov		esi,lpSrc
	lea		edi,buffer
InStr0:
	mov		al,[esi]
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jne		InStr0
	mov		edi,lpStr
	dec		edi
InStr1:
	inc		edi
	push	edi
	lea		esi,buffer
InStr2:
	mov		ah,[esi]
	or		ah,ah
	je		Found
	mov		al,[edi]
	or		al,al
	je		NotFound
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	inc		esi
	inc		edi
	cmp		al,ah
	jz		InStr2
	pop		edi
	jmp		InStr1
Found:
	pop		eax
	sub		eax,lpStr
	pop		edi
	pop		esi
	ret
NotFound:
	pop		edi
	mov		eax,-1
	pop		edi
	pop		esi
	ret

xInString endp

RStripString proc lpFile:DWORD,nChr:DWORD

	invoke lstrlen,lpFile
	mov		edx,lpFile
	mov		ecx,nChr
	.while eax
		.if byte ptr [edx+eax]==cl
			mov		byte ptr [edx+eax],0
			.break
		.endif
		dec eax
	.endw
	ret

RStripString endp

TestPath proc uses ebx,lpPath:DWORD

	mov		ebx,lpPath
	invoke lstrlen,ebx
	.if eax
		.if byte ptr [ebx+eax-1]==':' || byte ptr [ebx+eax-1]=='\'
			mov		word ptr [ebx+eax],'\'
		.endif
	.endif
	ret

TestPath endp

FileTrvAddNode proc	hFileTrv:HWND,hPar:DWORD,lpPth:DWORD,nImg:DWORD
	LOCAL	tvins:TV_INSERTSTRUCT

	mov		eax,hPar
	mov		tvins.hParent,eax
	;Saveing hPar simplifies building path
	;when user selects an item
	mov		tvins.item.lParam,eax
	mov		tvins.hInsertAfter,0
	mov		tvins.item._mask,TVIF_TEXT or TVIF_PARAM or	TVIF_IMAGE or TVIF_SELECTEDIMAGE
	mov		eax,lpPth
	mov		tvins.item.pszText,eax
	mov		eax,nImg
	mov		tvins.item.iImage,eax
	mov		tvins.item.iSelectedImage,eax
	invoke SendMessage,hFileTrv,TVM_INSERTITEM,0,addr tvins
	ret

FileTrvAddNode endp

FileTrvDir proc	hLBS:HWND,lpPth:DWORD,lpFilter:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hwfd:DWORD
	LOCAL	nInx:DWORD

	;Make the path local
	invoke lstrcpy,addr	buffer,lpPth
	;Check if path ends	with '\'. If not add.
	invoke lstrlen,addr	buffer
	dec		eax
	.if	byte ptr buffer[eax]!='\'
		invoke lstrcat,addr	buffer,addr	szBackSlash
	.endif
	;Add '*.*'
	invoke lstrcat,addr	buffer,addr	szAPA
	;Find first	match, if any
	invoke FindFirstFile,addr buffer,addr wfd
	.if	eax!=INVALID_HANDLE_VALUE
		;Save returned handle
		mov		hwfd,eax
	  Next:
		;Check if found	is a dir
		mov		eax,wfd.dwFileAttributes
		and		eax,FILE_ATTRIBUTE_DIRECTORY
		.if	eax
			;Do	not	include	'.'	and	'..'
			mov		ax,word ptr wfd.cFileName
			.if	ax!='.' && ax!='..'
				mov		word ptr buffer,'D'
				invoke lstrcat,addr	buffer,addr	wfd.cFileName
				invoke SendMessage,hLBS,LB_ADDSTRING,0,addr	buffer
				mov		nInx,eax
				invoke SendMessage,hLBS,LB_SETITEMDATA,nInx,1
			.endif
		.else
			;Add file
			mov		eax,lpFilter
			.if eax
				.if byte ptr [eax]
					;Some file filtering are done here
					push	esi
					lea		esi,wfd.cFileName
					invoke lstrlen,esi
					add		esi,eax
					.while eax
						dec		esi
					  .break .if byte ptr [esi]=='.'
						dec		eax
					.endw
					.if	eax
						invoke lstrcpy,addr	buffer,esi
						invoke lstrlen,esi
						mov		word ptr buffer[eax],'.'
						invoke xInString,lpFilter,addr buffer
						.if	eax!=-1
							mov		eax,FALSE
						.endif
					.else
						mov		eax,TRUE
					.endif
					pop		esi
				.else
					xor		eax,eax
				.endif
			.endif
			.if	!eax
				mov		word ptr buffer,'F'
				invoke lstrcat,addr buffer,addr wfd.cFileName
				invoke SendMessage,hLBS,LB_ADDSTRING,0,addr	buffer
				mov		nInx,eax
				invoke CharUpper,addr wfd.cFileName
				invoke lstrlen,addr wfd.cFileName
				mov		edx,dword ptr wfd.cFileName[eax-4]
				.if edx=='MSA.'
					mov		eax,2
				.elseif edx=='CNI.'
					mov		eax,3
				.elseif edx=='EXE.' || edx=='MOC.'
					mov		eax,6
				.elseif edx=='TAB.'
					mov		eax,7
				.else
					mov		edx,dword ptr wfd.cFileName[eax-3]
					.if edx=='CR.'
						mov		eax,4
					.else
						mov		eax,5
					.endif
				.endif
				invoke SendMessage,hLBS,LB_SETITEMDATA,nInx,eax
			.endif
		.endif
		;Any more matches?
		invoke FindNextFile,hwfd,addr wfd
		or		eax,eax
		jne		Next
		;No	more matches, close	handle
		invoke FindClose,hwfd
	.endif
	ret

FileTrvDir endp

ThreadProc proc uses ebx,Param:DWORD

	mov		ebx,Param
	invoke FindFirstChangeNotification,addr [ebx].FILEBROWSER.filepath,FALSE,FILE_NOTIFY_CHANGE_FILE_NAME;FILE_NOTIFY_CHANGE_LAST_WRITE or 
	mov		[ebx].FILEBROWSER.hchange,eax
	.if eax!=INVALID_HANDLE_VALUE
		.while TRUE
			; Wait for notification.		
			invoke WaitForMultipleObjects,1,ADDR [ebx].FILEBROWSER.hchange,FALSE,INFINITE
			.if eax==WAIT_OBJECT_0
				.if [ebx].FILEBROWSER.ntimer==-1
					mov		[ebx].FILEBROWSER.ntimer,0
					invoke ExitThread,0
				.endif
				mov		[ebx].FILEBROWSER.ntimer,2
				invoke FindNextChangeNotification,[ebx].FILEBROWSER.hchange
				.if eax==FALSE
					.break
				.endif
			.elseif eax==WAIT_ABANDONED || eax==WAIT_TIMEOUT || eax==WAIT_FAILED
				.break
			.endif
		.endw
	.endif
	ret

ThreadProc ENDP

SetSelected proc hFileTrv:HWND,lpFile:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	sel[MAX_PATH]:BYTE
	LOCAL	tvi:TVITEM

	invoke lstrcpy,addr sel,lpFile
	invoke lstrlen,addr sel
	.while byte ptr sel[eax]!='\' && eax
		dec		eax
	.endw
	mov		sel[eax],0
	lea		eax,sel[eax+1]
	mov		lpFile,eax
	invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
	.if eax
		call	GetItem
		invoke lstrcmpi,addr sel,addr buffer
		.if !eax
			invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_CHILD,tvi.hItem
			.while eax
				call	GetItem
				invoke lstrcmpi,lpFile,addr buffer
				.if !eax
					invoke SendMessage,hFileTrv,TVM_SELECTITEM,TVGN_CARET,tvi.hItem
					xor		eax,eax
				.else
					invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_NEXT,tvi.hItem
					.if !eax
						invoke SendMessage,hFileTrv,TVM_SELECTITEM,TVGN_CARET,eax
						xor		eax,eax
					.endif
				.endif
			.endw
		.else
			invoke SendMessage,hFileTrv,TVM_SELECTITEM,TVGN_CARET,0
		.endif
	.endif
	ret

GetItem:
	mov		buffer,0
	mov		tvi.imask,TVIF_TEXT
	mov		tvi.hItem,eax
	lea		eax,buffer
	mov		tvi.pszText,eax
	mov		tvi.cchTextMax,sizeof buffer
	invoke SendMessage,hFileTrv,TVM_GETITEM,0,addr tvi
	retn

SetSelected endp

GetSelected proc hFileTrv:HWND,lpFile:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	tvi:TVITEM

	mov		eax,lpFile
	mov		byte ptr [eax],0
	invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_CARET,0
	.if eax
		push	eax
		mov		tvi.imask,TVIF_TEXT
		mov		tvi.hItem,eax
		lea		eax,buffer
		mov		tvi.pszText,eax
		mov		tvi.cchTextMax,sizeof buffer
		invoke SendMessage,hFileTrv,TVM_GETITEM,0,addr tvi
		invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
		mov		tvi.hItem,eax
		mov		eax,lpFile
		mov		tvi.pszText,eax
		mov		tvi.cchTextMax,MAX_PATH
		invoke SendMessage,hFileTrv,TVM_GETITEM,0,addr tvi
		pop		eax
		.if eax!=tvi.hItem
			invoke lstrcat,lpFile,offset szBackSlash
			invoke lstrcat,lpFile,addr buffer
		.endif
	.endif
	ret

GetSelected endp

FileDir	proc uses ebx,hFileTrv:HWND,lpPath:DWORD,fFilter:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hPar:DWORD
	LOCAL	hLBS:HWND
	LOCAL	ThreadID:DWORD
	LOCAL	sel[MAX_PATH]:BYTE

	invoke GetParent,hFileTrv
	invoke GetWindowLong,eax,0
	mov		ebx,eax
	invoke GetSelected,hFileTrv,addr sel
	.if [ebx].FILEBROWSER.hthread
		mov		[ebx].FILEBROWSER.ntimer,-1
		invoke FindCloseChangeNotification,[ebx].FILEBROWSER.hchange
		invoke CloseHandle,[ebx].FILEBROWSER.hthread
	.endif
	invoke SendMessage,hFileTrv,WM_SETREDRAW,FALSE,0
	invoke CreateWindowEx,0,addr szListBox,NULL,WS_CHILD or LBS_HASSTRINGS or LBS_SORT,0,0,0,0,hFileTrv,NULL,hInstance,NULL
	mov		hLBS,eax
	;Fill ListBox with dir info
	invoke SendMessage,hLBS,LB_RESETCONTENT,0,0
	mov		eax,fFilter
	.if eax
		lea		eax,[ebx].FILEBROWSER.filter
	.endif
	invoke FileTrvDir,hLBS,lpPath,eax
	invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
	invoke SendMessage,hFileTrv,TVM_DELETEITEM,0,eax
	;Add root to TreeViev
	invoke FileTrvAddNode,hFileTrv,0,lpPath,0
	;Save returned root	node
	mov		hPar,eax
	mov		nInx,0
	.while TRUE
		invoke SendMessage,hLBS,LB_GETTEXT,nInx,addr buffer
	  .break .if eax==LB_ERR
		invoke SendMessage,hLBS,LB_GETITEMDATA,nInx,0
		invoke FileTrvAddNode,hFileTrv,hPar,addr buffer[1],eax
		inc		nInx
	.endw
	invoke DestroyWindow,hLBS
	;Expand	the	root node
	invoke SendMessage,hFileTrv,TVM_EXPAND,TVE_EXPAND,hPar
	invoke CreateThread,NULL,NULL,ADDR ThreadProc,ebx,NORMAL_PRIORITY_CLASS,ADDR ThreadID
	mov		[ebx].FILEBROWSER.hthread,eax
	invoke SetSelected,hFileTrv,addr sel
	invoke SendMessage,hFileTrv,WM_SETREDRAW,TRUE,0
	ret

FileDir	endp

DriveDir proc uses ebx,hFileTrv:HWND,lpDrives:DWORD

	invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
	invoke SendMessage,hFileTrv,TVM_DELETEITEM,0,eax
	mov		ebx,lpDrives
	invoke lstrlen,ebx
	.while eax
		push	eax
		invoke FileTrvAddNode,hFileTrv,0,ebx,0
		pop		eax
		lea		ebx,[ebx+eax+1]
		invoke lstrlen,ebx
	.endw
	ret

DriveDir endp

Notify proc uses ebx,hWin:HWND,nCode:DWORD,lpFile:DWORD
	LOCAL	fbn:FBNOTIFY

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	mov		eax,hWin
	mov		fbn.nmhdr.hwndFrom,eax
	invoke GetWindowLong,eax,GWL_ID
	mov		fbn.nmhdr.idFrom,eax
	mov		eax,nCode
	mov		fbn.nmhdr.code,eax
	mov		eax,lpFile
	mov		fbn.lpfile,eax
	invoke GetParent,hWin
	mov		edx,eax
	invoke SendMessage,edx,WM_NOTIFY,fbn.nmhdr.idFrom,addr fbn
	ret

Notify endp

FileTreeViewProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	FileName[MAX_PATH]:BYTE
	LOCAL	lpht:TV_HITTESTINFO
	LOCAL	lptvi:TV_ITEMEX
	LOCAL	hTvi:HWND
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
		mov		lpht.pt.x,eax
		mov		eax,lParam
		shr		eax,16
		mov		lpht.pt.y,eax
		invoke SendMessage,hWin,TVM_HITTEST,0,addr lpht
		.if	eax
			mov		hTvi,eax
			mov		eax,lpht.flags
			and		eax,TVHT_ONITEM
			.if	eax
				m2m		lptvi.hItem,lpht.hItem
				mov		lptvi.imask,TVIF_PARAM or TVIF_TEXT	or TVIF_IMAGE
				lea		eax,buffer
				mov		lptvi.pszText,eax
				mov		lptvi.cchTextMax,sizeof	buffer
				invoke SendMessage,hWin,TVM_GETITEM,0,addr lptvi
				.if	lptvi.lParam
					mov		eax,lptvi.iImage
					.if	eax==1
						invoke lstrlen,addr [ebx].FILEBROWSER.filepath
						.if byte ptr [ebx].FILEBROWSER.filepath[eax-1]!='\'
							invoke lstrcat,addr [ebx].FILEBROWSER.filepath,offset szBackSlash
						.endif
						invoke lstrcat,addr [ebx].FILEBROWSER.filepath,addr	buffer
						invoke FileDir,hWin,addr [ebx].FILEBROWSER.filepath,[ebx].FILEBROWSER.ffilter
						invoke GetParent,hWin
						mov		edx,eax
						invoke Notify,edx,FBN_PATHCHANGE,addr [ebx].FILEBROWSER.filepath
					.elseif	eax>=2 && eax<=7
						invoke lstrcpy,addr FileName,addr [ebx].FILEBROWSER.filepath
						invoke lstrlen,addr [ebx].FILEBROWSER.filepath
						.if byte ptr FileName[eax-1]!='\'
							invoke lstrcat,addr FileName,offset szBackSlash
						.endif
						invoke lstrcat,addr FileName,addr buffer
						invoke GetParent,hWin
						mov		edx,eax
						invoke Notify,edx,FBN_DBLCLICK,addr FileName
					.endif
				.else
					.if [ebx].FILEBROWSER.fdrives
					  @@:
						invoke SendMessage,hWin,TVM_GETNEXTITEM,TVGN_ROOT,0
						.if eax
							invoke SendMessage,hWin,TVM_DELETEITEM,0,eax
							jmp	@b
						.endif
						invoke lstrcpy,addr [ebx].FILEBROWSER.filepath,addr	buffer
						mov		[ebx].FILEBROWSER.fdrives,FALSE
						invoke FileDir,hWin,addr [ebx].FILEBROWSER.filepath,[ebx].FILEBROWSER.ffilter
						invoke GetParent,hWin
						mov		edx,eax
						invoke Notify,edx,FBN_PATHCHANGE,addr [ebx].FILEBROWSER.filepath
					.endif
				.endif
			.endif
		.endif
		pop		eax
		xor		eax,eax
		jmp		Ex
	.elseif	eax==WM_RBUTTONDOWN
		invoke GetParent,hWin
		invoke GetWindowLong,eax,0
		mov		ebx,eax
		mov		eax,lParam
		and		eax,0FFFFh
		mov		lpht.pt.x,eax
		mov		eax,lParam
		shr		eax,16
		mov		lpht.pt.y,eax
		invoke SendMessage,hWin,TVM_HITTEST,0,addr lpht
		.if	eax
			mov		hTvi,eax
			mov		eax,lpht.flags
			and		eax,TVHT_ONITEM
			.if	eax
				invoke SendMessage,hWin,TVM_SELECTITEM,TVGN_CARET,hTvi
			.endif
		.endif
		invoke SetFocus,hWin
		xor		eax,eax
		jmp		Ex
	.elseif	eax==WM_CHAR
		mov		eax,wParam
		.if	eax==VK_SPACE || eax==VK_RETURN
			invoke SendMessage,hWin,TVM_GETNEXTITEM,TVGN_CARET,0
			mov		dword ptr rect,eax
			invoke SendMessage,hWin,TVM_GETITEMRECT,TRUE,addr rect
			mov		eax,rect.top
			shl		eax,16
			add		eax,rect.left
			invoke SendMessage,hWin,WM_LBUTTONDBLCLK,0,eax
			xor		eax,eax
			jmp		Ex
		.elseif	eax=='\' || eax==VK_BACK
			invoke GetParent,hWin
			invoke GetWindowLong,eax,0
			mov		ebx,eax
			invoke RStripString,addr [ebx].FILEBROWSER.filepath,'\'
			invoke TestPath,addr [ebx].FILEBROWSER.filepath
			invoke FileDir,hWin,addr [ebx].FILEBROWSER.filepath,[ebx].FILEBROWSER.ffilter
			invoke GetParent,hWin
			mov		edx,eax
			invoke Notify,edx,FBN_PATHCHANGE,addr [ebx].FILEBROWSER.filepath
			xor		eax,eax
			jmp		Ex
		.endif
	.endif
	invoke GetWindowLong,hWin,GWL_USERDATA
	invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
  Ex:
	ret

FileTreeViewProc endp

TimerProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	.if [ebx].FILEBROWSER.ntimer
		dec		[ebx].FILEBROWSER.ntimer
		.if ZERO?
			invoke FileDir,[ebx].FILEBROWSER.htrv,addr [ebx].FILEBROWSER.filepath,[ebx].FILEBROWSER.ffilter
		.endif
	.endif
	ret

TimerProc endp

ControlProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	buffer[64]:BYTE
	LOCAL	nmhdr:NMHDR

	mov		eax,uMsg
	.if eax==WM_CREATE
		invoke GetProcessHeap
		invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof FILEBROWSER
		mov		ebx,eax
		invoke SetWindowLong,hWin,0,ebx
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr szTreeView,NULL,WS_CHILD or WS_VISIBLE or WS_CLIPSIBLINGS or WS_CLIPCHILDREN or TVS_HASLINES or TVS_HASBUTTONS or TVS_SHOWSELALWAYS or TVS_EDITLABELS,0,0,0,0,hWin,NULL,hInstance,NULL
		mov		[ebx].FILEBROWSER.htrv,eax
		invoke SetWindowLong,[ebx].FILEBROWSER.htrv,GWL_WNDPROC,offset FileTreeViewProc
		invoke SetWindowLong,[ebx].FILEBROWSER.htrv,GWL_USERDATA,eax
		invoke ImageList_Create,16,16,ILC_COLOR24 or ILC_MASK,10,0
		mov		[ebx].FILEBROWSER.himl,eax
		invoke LoadBitmap,hInstance,IDB_TRV
		push	eax
		invoke ImageList_AddMasked,[ebx].FILEBROWSER.himl,eax,0FF00FFh
		pop		eax
		invoke DeleteObject,eax
		invoke SendMessage,[ebx].FILEBROWSER.htrv,TVM_SETIMAGELIST,0,[ebx].FILEBROWSER.himl
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		edx,WS_CHILD or WS_VISIBLE or TBSTYLE_TOOLTIPS or CCS_NORESIZE
		test	eax,FBSTYLE_FLATTOOLBAR
		.if !ZERO?
			or		edx,TBSTYLE_FLAT
		.endif
		test	eax,FBSTYLE_DIVIDERLINE
		.if ZERO?
			or		edx,CCS_NODIVIDER
		.endif
		invoke CreateWindowEx,0,addr szToolBar,NULL,edx,0,0,0,0,hWin,NULL,hInstance,NULL
		mov		[ebx].FILEBROWSER.htbr,eax
		;Set toolbar struct size
		invoke SendMessage,[ebx].FILEBROWSER.htbr,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
		;Set toolbar buttons
		invoke SendMessage,[ebx].FILEBROWSER.htbr,TB_ADDBUTTONS,3,addr btns
		;Set the imagelist
		invoke SendMessage,[ebx].FILEBROWSER.htbr,TB_SETIMAGELIST,0,[ebx].FILEBROWSER.himl
		invoke SetTimer,hWin,200,500,addr TimerProc
	.elseif eax==WM_SIZE
		push	edi
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		edi,28
		test	eax,FBSTYLE_FLATTOOLBAR
		.if !ZERO?
			sub		edi,4
		.endif
		test	eax,FBSTYLE_DIVIDERLINE
		.if ZERO?
			sub		edi,2
		.endif
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GetClientRect,hWin,addr rect
		invoke MoveWindow,[ebx].FILEBROWSER.htbr,0,0,rect.right,edi,TRUE
		mov		edx,rect.bottom
		sub		edx,edi
		invoke MoveWindow,[ebx].FILEBROWSER.htrv,0,edi,rect.right,edx,TRUE
		pop		edi
	.elseif eax==WM_COMMAND
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		.if eax==1
			invoke lstrlen,addr [ebx].FILEBROWSER.filepath
			.if eax==3
				mov		eax,[ebx].FILEBROWSER.fdrives
				.if !eax
					.if [ebx].FILEBROWSER.hthread
						mov		[ebx].FILEBROWSER.ntimer,-1
						invoke FindCloseChangeNotification,[ebx].FILEBROWSER.hchange
						invoke CloseHandle,[ebx].FILEBROWSER.hthread
						mov		[ebx].FILEBROWSER.hthread,0
					.endif
					invoke GetLogicalDriveStrings,sizeof buffer,addr buffer
					invoke DriveDir,[ebx].FILEBROWSER.htrv,addr buffer
					mov		[ebx].FILEBROWSER.fdrives,TRUE
				.endif
			.else
				mov		[ebx].FILEBROWSER.fdrives,FALSE
				invoke RStripString,addr [ebx].FILEBROWSER.filepath,'\'
				invoke TestPath,addr [ebx].FILEBROWSER.filepath
				invoke FileDir,[ebx].FILEBROWSER.htrv,addr [ebx].FILEBROWSER.filepath,[ebx].FILEBROWSER.ffilter
				invoke Notify,hWin,FBN_PATHCHANGE,addr [ebx].FILEBROWSER.filepath
			.endif
		.elseif eax==2
			mov		eax,[ebx].FILEBROWSER.fdrives
			.if !eax
				xor		[ebx].FILEBROWSER.ffilter,1
				invoke FileDir,[ebx].FILEBROWSER.htrv,addr [ebx].FILEBROWSER.filepath,[ebx].FILEBROWSER.ffilter
			.endif
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_SETFONT
		invoke GetWindowLong,hWin,0
		invoke SendMessage,[eax].FILEBROWSER.htrv,WM_SETFONT,wParam,TRUE
	.elseif eax==WM_DESTROY
		invoke KillTimer,hWin,200
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		.if [ebx].FILEBROWSER.hthread
			invoke FindCloseChangeNotification,[ebx].FILEBROWSER.hchange
			invoke CloseHandle,[ebx].FILEBROWSER.hthread
		.endif
		invoke ImageList_Destroy,[ebx].FILEBROWSER.himl
		invoke DestroyWindow,[ebx].FILEBROWSER.htrv
		invoke DestroyWindow,[ebx].FILEBROWSER.htbr
		invoke GetProcessHeap
		invoke HeapFree,eax,0,ebx
	.elseif eax==FBM_SETPATH
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke lstrcpyn,addr [ebx].FILEBROWSER.filepath,lParam,sizeof FILEBROWSER.filepath
		.if wParam
			invoke FileDir,[ebx].FILEBROWSER.htrv,addr [ebx].FILEBROWSER.filepath,[ebx].FILEBROWSER.ffilter
		.endif
		invoke Notify,hWin,FBN_PATHCHANGE,addr [ebx].FILEBROWSER.filepath
		xor		eax,eax
		jmp		Ex
	.elseif eax==FBM_GETPATH
		invoke GetWindowLong,hWin,0
		invoke lstrcpy,lParam,addr [eax].FILEBROWSER.filepath
		xor		eax,eax
		jmp		Ex
	.elseif eax==FBM_SETFILTERSTRING
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke lstrcpyn,addr [ebx].FILEBROWSER.filter,lParam,sizeof FILEBROWSER.filter
		.if wParam
			invoke FileDir,[ebx].FILEBROWSER.htrv,addr [ebx].FILEBROWSER.filepath,[ebx].FILEBROWSER.ffilter
		.ENDIF
		xor		eax,eax
		jmp		Ex
	.elseif eax==FBM_GETFILTERSTRING
		invoke GetWindowLong,hWin,0
		invoke lstrcpy,lParam,addr [eax].FILEBROWSER.filter
		xor		eax,eax
		jmp		Ex
	.elseif eax==FBM_SETFILTER
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,lParam
		mov		[ebx].FILEBROWSER.ffilter,eax
		invoke SendMessage,[ebx].FILEBROWSER.htbr,TB_CHECKBUTTON,2,eax
		.if wParam
			invoke FileDir,[ebx].FILEBROWSER.htrv,addr [ebx].FILEBROWSER.filepath,[ebx].FILEBROWSER.ffilter
		.ENDIF
		xor		eax,eax
		jmp		Ex
	.elseif eax==FBM_GETFILTER
		invoke GetWindowLong,hWin,0
		mov		eax,[eax].FILEBROWSER.ffilter
		jmp		Ex
	.elseif eax==FBM_SETSELECTED
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SetSelected,[ebx].FILEBROWSER.htrv,lParam
		xor		eax,eax
		jmp		Ex
	.elseif eax==FBM_GETSELECTED
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GetSelected,[ebx].FILEBROWSER.htrv,lParam
		xor		eax,eax
		jmp		Ex
	.elseif eax==FBM_SETBACKCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,[ebx].FILEBROWSER.htrv,TVM_SETBKCOLOR,0,lParam
		xor		eax,eax
		jmp		Ex
	.elseif eax==FBM_GETBACKCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,[ebx].FILEBROWSER.htrv,TVM_GETBKCOLOR,0,0
		jmp		Ex
	.elseif eax==FBM_SETTEXTCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,[ebx].FILEBROWSER.htrv,TVM_SETTEXTCOLOR,0,lParam
		xor		eax,eax
		jmp		Ex
	.elseif eax==FBM_GETTEXTCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,[ebx].FILEBROWSER.htrv,TVM_GETTEXTCOLOR,0,0
		jmp		Ex
	.elseif eax==FBM_GETIMAGELIST
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].FILEBROWSER.himl
		jmp		Ex
	.elseif eax==FBM_SETTOOLTIP
		mov		eax,wParam
		.if eax==1
			invoke lstrcpyn,addr szUpOneLevel,lParam,64
		.elseif eax==2
			invoke lstrcpyn,addr szFileFilter,lParam,64
		.endif
	.elseif eax==WM_USER+9999
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GetCurrentDirectory,sizeof FILEBROWSER.filepath,addr [ebx].FILEBROWSER.filepath
		invoke FileDir,[ebx].FILEBROWSER.htrv,addr [ebx].FILEBROWSER.filepath,0
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_NOTIFY
		mov		ebx,lParam
		xor		eax,eax
		.if [ebx].NMHDR.code==TTN_NEEDTEXT
			;Toolbar tooltip
			mov		eax,offset szFileFilter
			.if [ebx].NMHDR.idFrom==1
				mov		eax,offset szUpOneLevel
			.endif
			.if !byte ptr [eax]
				invoke LoadString,hInstance,(NMHDR ptr [ebx]).idFrom,addr buffer,sizeof buffer
				.if eax
					lea		eax,buffer
				.endif
			.endif
			mov		(TOOLTIPTEXT ptr [ebx]).lpszText,eax
			xor		eax,eax
			jmp		Ex
		.elseif [ebx].NMHDR.code==NM_SETFOCUS
			mov		eax,hWin
			mov		nmhdr.hwndFrom,eax
			invoke GetWindowLong,hWin,GWL_ID
			mov		nmhdr.idFrom,eax
			mov		nmhdr.code,NM_SETFOCUS
			invoke GetParent,hWin
			mov		ebx,eax
			invoke SendMessage,ebx,WM_NOTIFY,nmhdr.idFrom,addr nmhdr
		.elseif [ebx].NMHDR.code==NM_KILLFOCUS
			mov		eax,hWin
			mov		nmhdr.hwndFrom,eax
			invoke GetWindowLong,hWin,GWL_ID
			mov		nmhdr.idFrom,eax
			mov		nmhdr.code,NM_KILLFOCUS
			invoke GetParent,hWin
			mov		ebx,eax
			invoke SendMessage,ebx,WM_NOTIFY,nmhdr.idFrom,addr nmhdr
		.endif
	.elseif eax==WM_SETFOCUS
		invoke GetWindowLong,hWin,0
		invoke SetFocus,[eax].FILEBROWSER.htrv
		xor		eax,eax
		jmp		Ex
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ControlProc endp

IFDEF DLL
	include RAFileDll.asm
ENDIF

end
