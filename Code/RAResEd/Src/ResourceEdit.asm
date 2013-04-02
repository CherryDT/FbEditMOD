
;ResourceEdit.dlg
IDD_DLGRESOURCE							equ 1100
IDC_GRDRES								equ 1001
IDC_BTNRESADD							equ 1002
IDC_BTNRESDEL							equ 1003
IDC_BTNRESPREVIEW						equ 1004
IDC_BTNRESEDIT							equ 1005

IDD_RESPREVIEW							equ 2700
IDD_RESPREVIEWBTN						equ 2710
IDD_RESPREVIEWCTL						equ 2720

ICONSIZE struct
	wt			db ?
	ht			db ?
	col			db ?
	reserved	db ?
	pl			dw ?
	bits		dw ?
	nsize		dd ?
	nofs		dd ?
ICONSIZE ends

ICONDEF struct
	szFile		db MAX_PATH dup(?)
	reserved	dw ?
	ntype		dw ?
	ncount		dw ?
	is1			ICONSIZE <?>
	is2			ICONSIZE <?>
	is3			ICONSIZE <?>
	is4			ICONSIZE <?>
	is5			ICONSIZE <?>
	is6			ICONSIZE <?>
ICONDEF ends

.const

szRESOURCE				db 'RESOURCE',0
szX						db ' x ',0
IResGrdSize				dd 90,100,40,140

.data?

hPrvDlg1				dd ?
hPrvDlg2				dd ?
hPrvDlg3				dd ?
hPrvBmp					dd ?
hPrvIcon				dd ?
hPrvCursor				dd ?
icondef					ICONDEF <>
ResGrdSize				dd 4 dup(?)

.code

ExportResourceNames proc uses esi edi,hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	mov		edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	.while byte ptr [esi].RESOURCEMEM.szfile
		.if byte ptr [esi].RESOURCEMEM.szname && [esi].RESOURCEMEM.value
			invoke ExportName,addr [esi].RESOURCEMEM.szname,[esi].RESOURCEMEM.value,edi
			lea		edi,[edi+eax]
		.endif
		add		esi,sizeof RESOURCEMEM
	.endw
	pop		eax
	ret

ExportResourceNames endp

ExportResource proc uses esi edi,hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	mov		edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	.while byte ptr [esi].RESOURCEMEM.szfile
		.if byte ptr [esi].RESOURCEMEM.szname
			invoke SaveStr,edi,addr [esi].RESOURCEMEM.szname
			add		edi,eax
		.else
			invoke SaveVal,[esi].RESOURCEMEM.value,FALSE
		.endif
		mov		al,' '
		stosb
		mov		eax,[esi].RESOURCEMEM.ntype
		push	eax
		mov		ecx,sizeof RARSTYPE
		mul		ecx
		add		eax,offset rarstype
		invoke SaveStr,edi,eax
		add		edi,eax
		mov		al,' '
		stosb
		pop		eax
		.if eax<10
			invoke SaveStr,edi,offset szDISCARDABLE
			add		edi,eax
			mov		al,' '
			stosb
		.endif
		mov		al,'"'
		stosb
		xor		ecx,ecx
		.while byte ptr [esi+ecx].RESOURCEMEM.szfile
			mov		al,[esi+ecx].RESOURCEMEM.szfile
			.if al=='\'
				mov		al,'/'
			.endif
			mov		[edi],al
			inc		ecx
			inc		edi
		.endw
		mov		al,'"'
		stosb
		mov		al,0Dh
		stosb
		mov		al,0Ah
		stosb
		add		esi,sizeof RESOURCEMEM
	.endw
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		byte ptr [edi],0
	pop		eax
	ret

ExportResource endp

SaveResourceEdit proc uses esi edi,hWin:HWND
	LOCAL	hGrd:HWND
	LOCAL	nRows:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	lpProMem:DWORD

	invoke GetWindowLong,hPrj,0
	mov		lpProMem,eax
	invoke GetDlgItem,hWin,IDC_GRDRES
	mov		hGrd,eax
	invoke SendMessage,hGrd,GM_GETROWCOUNT,0,0
	mov		nRows,eax
	invoke GetWindowLong,hWin,GWL_USERDATA
	.if !eax
		invoke SendMessage,hRes,PRO_ADDITEM,TPE_RESOURCE,FALSE
	.endif
	push	eax
	mov		edi,[eax].PROJECT.hmem
	xor		esi,esi
	.while esi<nRows
		;Type
		mov		ecx,esi
		shl		ecx,16
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		mov		eax,dword ptr buffer
		mov		[edi].RESOURCEMEM.ntype,eax
		;Name
		mov		ecx,esi
		shl		ecx,16
		add		ecx,1
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		invoke strcpy,addr [edi].RESOURCEMEM.szname,addr buffer
		;ID
		mov		ecx,esi
		shl		ecx,16
		add		ecx,2
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		mov		eax,dword ptr buffer
		mov		[edi].RESOURCEMEM.value,eax
		;File
		mov		ecx,esi
		shl		ecx,16
		add		ecx,3
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		.if buffer
			invoke strcpy,addr [edi].RESOURCEMEM.szfile,addr buffer
			.if [edi].RESOURCEMEM.ntype==7
				invoke FindName,lpProMem,addr szMANIFEST,FALSE
				.if !eax
					invoke AddName,lpProMem,addr szMANIFEST,addr szManifestValue
				.endif
			.endif
			add		edi,sizeof RESOURCEMEM
		.endif
		inc		esi
	.endw
	xor		eax,eax
	mov		[edi].RESOURCEMEM.ntype,eax
	mov		[edi].RESOURCEMEM.szname,al
	mov		[edi].RESOURCEMEM.value,eax
	mov		[edi].RESOURCEMEM.szfile,al
	pop		eax
	ret

SaveResourceEdit endp

SizeBmp proc uses ebx
	LOCAL	rect:RECT
	LOCAL	bmp:BITMAP

	invoke GetClientRect,hPrvDlg3,addr rect
	invoke GetDlgItem,hPrvDlg3,1001
	mov		ebx,eax
	invoke GetObject,hPrvBmp,sizeof BITMAP,addr bmp
	mov		eax,rect.right
	sub		eax,bmp.bmWidth
	cdq
	mov		ecx,2
	idiv	ecx
	mov		rect.left,eax
	mov		eax,rect.bottom
	sub		eax,bmp.bmHeight
	cdq
	mov		ecx,2
	idiv	ecx
	mov		rect.top,eax
	invoke MoveWindow,ebx,rect.left,rect.top,bmp.bmWidth,bmp.bmHeight,TRUE
	ret

SizeBmp endp

SizeIcon proc uses ebx
	LOCAL	rect:RECT
	LOCAL	rect1:RECT

	invoke GetClientRect,hPrvDlg3,addr rect
	invoke GetDlgItem,hPrvDlg3,1002
	mov		ebx,eax
	invoke GetClientRect,ebx,addr rect1
	mov		eax,rect.right
	sub		eax,rect1.right
	cdq
	mov		ecx,2
	idiv	ecx
	mov		rect.left,eax
	mov		eax,rect.bottom
	sub		eax,rect1.bottom
	cdq
	mov		ecx,2
	idiv	ecx
	mov		rect.top,eax
	invoke MoveWindow,ebx,rect.left,rect.top,rect1.right,rect1.bottom,TRUE
	ret

SizeIcon endp

SizeAni proc
	LOCAL	rect:RECT

	invoke GetClientRect,hPrvDlg3,addr rect
	invoke GetDlgItem,hPrvDlg3,1003
	invoke MoveWindow,eax,0,0,rect.right,rect.bottom,TRUE
	ret

SizeAni endp

Destroy proc

	.if hPrvBmp
		invoke DeleteObject,hPrvBmp
		mov		hPrvBmp,0
	.endif
	.if hPrvIcon
		invoke DestroyIcon,hPrvIcon
		mov		hPrvIcon,0
	.endif
	.if hPrvCursor
		invoke DestroyCursor,hPrvCursor
		mov		hPrvCursor,0
	.endif
	ret

Destroy endp

ResPreviewBtnProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		movzx	eax,ax
		.if edx==BN_CLICKED
			push	eax
			invoke GetDlgItem,hWin,eax
			invoke GetWindowLong,eax,GWL_USERDATA
			mov		ecx,eax
			pop		eax
			.if eax==IDCANCEL
				invoke SendMessage,hPrvDlg1,WM_CLOSE,0,0
			.elseif eax>=1001 && eax<=1006
				mov		edx,ecx
				movzx	ecx,cx
				shr		edx,16
				.if hPrvIcon
					invoke LoadImage,0,addr icondef.szFile,IMAGE_ICON,ecx,edx,LR_LOADFROMFILE
					mov		hPrvIcon,eax
					invoke GetDlgItem,hPrvDlg3,1002
					invoke SendMessage,eax,STM_SETIMAGE,IMAGE_ICON,hPrvIcon
					invoke DestroyIcon,eax
					invoke SizeIcon
				.elseif hPrvCursor
					invoke LoadImage,0,addr icondef.szFile,IMAGE_CURSOR,ecx,edx,LR_LOADFROMFILE
					mov		hPrvCursor,eax
					invoke GetDlgItem,hPrvDlg3,1002
					invoke SendMessage,eax,STM_SETIMAGE,IMAGE_CURSOR,hPrvCursor
					invoke DestroyCursor,eax
					invoke SizeIcon
				.endif
			.endif
		.endif
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke GetDlgItem,hWin,IDCANCEL
		mov		edx,rect.bottom
		sub		edx,28
		invoke MoveWindow,eax,3,edx,88,25,TRUE
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

ResPreviewBtnProc endp

ResPreviewCtlProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
	.elseif eax==WM_CTLCOLORSTATIC
		invoke GetStockObject,WHITE_BRUSH
		ret
	.elseif eax==WM_CTLCOLORDLG
		invoke GetStockObject,WHITE_BRUSH
		ret
	.elseif eax==WM_SIZE
		invoke GetDlgItem,hWin,1001
		invoke IsWindowVisible,eax
		.if eax
			invoke SizeBmp
		.endif
		invoke GetDlgItem,hWin,1002
		invoke IsWindowVisible,eax
		.if eax
			invoke SizeIcon
		.endif
		invoke GetDlgItem,hWin,1003
		invoke IsWindowVisible,eax
		.if eax
			invoke SizeAni
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

ResPreviewCtlProc endp

GetIconSize proc uses ebx esi edi,lpFile:DWORD
	LOCAL	hFile:DWORD
	LOCAL	dwread:DWORD
	LOCAL	nid:DWORD
	LOCAL	buffer[64]:BYTE

	invoke strcpy,addr icondef.szFile,lpFile
	invoke CreateFile,lpFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke ReadFile,hFile,addr icondef.reserved,sizeof icondef-MAX_PATH,addr dwread,NULL
		invoke CloseHandle,hFile
		mov		nid,1001
		movzx	edi,icondef.ncount
		.if edi>6
			mov		edi,6
		.endif
		lea		esi,icondef.is1
		.while edi
			movzx	edx,[esi].ICONSIZE.wt
			.if !edx
				mov		edx,256
			.endif
			push	edx
			invoke ResEdBinToDec,edx,addr buffer
			movzx	edx,[esi].ICONSIZE.ht
			.if !edx
				mov		edx,256
			.endif
			push	edx
			invoke ResEdBinToDec,edx,addr buffer[32]
			invoke strcat,addr buffer,addr szX
			invoke strcat,addr buffer,addr buffer[32]
			invoke GetDlgItem,hPrvDlg2,nid
			mov		ebx,eax
			invoke SendMessage,ebx,WM_SETTEXT,0,addr buffer
			invoke ShowWindow,ebx,SW_SHOWNA
			pop		eax
			shl		eax,16
			pop		edx
			or		eax,edx
			invoke SetWindowLong,ebx,GWL_USERDATA,eax
			inc		nid
			dec		edi
			add		esi,sizeof ICONSIZE
		.endw
		invoke CheckDlgButton,hPrvDlg2,1001,BST_CHECKED
	.endif
	ret

GetIconSize endp

ResPreviewProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hPrvDlg1,eax
		invoke CreateDialogParam,hInstance,IDD_RESPREVIEWBTN,hWin,addr ResPreviewBtnProc,0
		mov		hPrvDlg2,eax
		invoke CreateDialogParam,hInstance,IDD_RESPREVIEWCTL,hWin,addr ResPreviewCtlProc,0
		mov		hPrvDlg3,eax
		mov		esi,lParam
		mov		eax,[esi]
		add		esi,4
		.if !eax
			; Bitmap
			invoke GetDlgItem,hPrvDlg3,1001
			mov		ebx,eax
			invoke LoadImage,0,esi,IMAGE_BITMAP,0,0,LR_LOADFROMFILE
			mov		hPrvBmp,eax
			invoke SendMessage,ebx,STM_SETIMAGE,IMAGE_BITMAP,eax
			invoke SizeBmp
			invoke ShowWindow,ebx,SW_SHOW
		.elseif eax==1
			; Cursor
			invoke GetDlgItem,hPrvDlg3,1002
			mov		ebx,eax
			invoke GetIconSize,esi
			movzx	ecx,icondef.is1.wt
			movzx	edx,icondef.is1.ht
			invoke LoadImage,0,esi,IMAGE_CURSOR,ecx,edx,LR_LOADFROMFILE
			mov		hPrvCursor,eax
			invoke SendMessage,ebx,STM_SETIMAGE,IMAGE_CURSOR,eax
			invoke SizeIcon
			invoke ShowWindow,ebx,SW_SHOW
		.elseif eax==2
			; Icon
			invoke GetDlgItem,hPrvDlg3,1002
			mov		ebx,eax
			invoke GetIconSize,esi
			movzx		ecx,icondef.is1.wt
			movzx		edx,icondef.is1.ht
			invoke LoadImage,0,esi,IMAGE_ICON,ecx,edx,LR_LOADFROMFILE
			mov		hPrvIcon,eax
			invoke SendMessage,ebx,STM_SETIMAGE,IMAGE_ICON,eax
			invoke SizeIcon
			invoke ShowWindow,ebx,SW_SHOW
		.elseif eax==3
			; Animate
			invoke GetDlgItem,hPrvDlg3,1003
			mov		ebx,eax
			invoke SendMessage,ebx,ACM_OPEN,0,esi
			invoke SizeAni
			invoke ShowWindow,ebx,SW_SHOW
		.elseif eax==8
			; Anicursor
			invoke GetDlgItem,hPrvDlg3,1002
			mov		ebx,eax
			invoke LoadImage,0,esi,IMAGE_CURSOR,0,0,LR_LOADFROMFILE
			mov		hPrvCursor,eax
			invoke SendMessage,ebx,STM_SETIMAGE,IMAGE_CURSOR,eax
			invoke ShowWindow,ebx,SW_SHOW
		.endif
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		mov		eax,rect.right
		sub		eax,94
		mov		rect.right,eax
		invoke MoveWindow,hPrvDlg2,eax,0,94,rect.bottom,TRUE
		invoke MoveWindow,hPrvDlg3,0,0,rect.right,rect.bottom,TRUE
	.elseif eax==WM_CLOSE
		invoke Destroy
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

ResPreviewProc endp

ResourceEditProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hGrd:HWND
	LOCAL	col:COLUMN
	LOCAL	row[4]:DWORD
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	buffer2[MAX_PATH]:BYTE              ; *** MOD
	LOCAL	rect:RECT
	LOCAL	fChanged:DWORD
	LOCAL	val:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke InitGridSize,4,offset IResGrdSize,offset ResGrdSize
		mov		fChanged,FALSE
		invoke GetDlgItem,hWin,IDC_GRDRES
		mov		hGrd,eax
		invoke SendMessage,hWin,WM_GETFONT,0,0
		invoke SendMessage,hGrd,WM_SETFONT,eax,FALSE
		invoke SendMessage,hGrd,GM_SETBACKCOLOR,color.back,0
		invoke SendMessage,hGrd,GM_SETTEXTCOLOR,color.text,0
		invoke ConvertDpiSize,18
		push	eax
		invoke SendMessage,hGrd,GM_SETHDRHEIGHT,0,eax
		pop		eax
		invoke SendMessage,hGrd,GM_SETROWHEIGHT,0,eax
		;Type
		mov		eax,ResGrdSize
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrType
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_COMBOBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Fill types in the combo
		mov		esi,offset rarstype
		.while [esi].RARSTYPE.sztype || [esi].RARSTYPE.nid
			.if [esi].RARSTYPE.sztype
				invoke SendMessage,hGrd,GM_COMBOADDSTRING,0,addr [esi].RARSTYPE.sztype
			.else
				invoke ResEdBinToDec,[esi].RARSTYPE.nid,addr buffer
				invoke SendMessage,hGrd,GM_COMBOADDSTRING,0,addr buffer
			.endif
			add		esi,sizeof RARSTYPE
		.endw
		;Name
		mov		eax,ResGrdSize[4]
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrName
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,MaxName-1
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;ID
		mov		eax,ResGrdSize[8]
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrID
		mov		col.halign,GA_ALIGN_RIGHT
		mov		col.calign,GA_ALIGN_RIGHT
		mov		col.ctype,TYPE_EDITLONG
		mov		col.ctextmax,5
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Filename
		mov		eax,ResGrdSize[12]
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrFileName
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITBUTTON
		mov		col.ctextmax,MAX_PATH
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		mov		esi,lParam
		invoke SetWindowLong,hWin,GWL_USERDATA,esi
		.if esi
			mov		esi,[esi].PROJECT.hmem
			.while [esi].RESOURCEMEM.szfile
				mov		eax,[esi].RESOURCEMEM.ntype
				mov		row,eax
				lea		eax,[esi].RESOURCEMEM.szname
				mov		row[4],eax
				mov		eax,[esi].RESOURCEMEM.value
				mov		row[8],eax
				lea		eax,[esi].RESOURCEMEM.szfile
				mov		row[12],eax
				invoke SendMessage,hGrd,GM_ADDROW,0,addr row
				add		esi,sizeof RESOURCEMEM 
			.endw
			invoke SendMessage,hGrd,GM_SETCURSEL,0,0
		.else
			invoke SaveResourceEdit,hWin
			invoke SetWindowLong,hWin,GWL_USERDATA,eax
			mov		fChanged,TRUE
		.endif
		invoke SendMessage,hPrpCboDlg,CB_RESETCONTENT,0,0
		invoke SendMessage,hPrpCboDlg,CB_ADDSTRING,0,offset szRESOURCE
		invoke SendMessage,hPrpCboDlg,CB_SETCURSEL,0,0
		mov		 fNoScroll,TRUE
    	invoke ShowScrollBar,hDEd,SB_BOTH,FALSE
		invoke SendMessage,hWin,WM_SIZE,0,0
		mov		eax,fChanged
		mov		fDialogChanged,eax
		invoke SetFocus,hGrd
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_COMMAND
		invoke GetDlgItem,hWin,IDC_GRDRES
		mov		hGrd,eax
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendMessage,hGrd,GM_GETCURSEL,0,0
				invoke SendMessage,hGrd,GM_ENDEDIT,eax,FALSE
				invoke SaveResourceEdit,hWin
				.if fDialogChanged
					invoke SendMessage,hRes,PRO_SETMODIFY,TRUE,0
					mov		fDialogChanged,FALSE
				.endif
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,FALSE,NULL
				invoke PropertyList,0
			.elseif eax==IDC_BTNRESADD
				invoke SaveResourceEdit,hWin
				invoke SendMessage,hGrd,GM_ADDROW,0,NULL
				push	eax
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke GetFreeProjectitemID,TPE_RESOURCE
				mov		val,eax
				pop		edx
				shl		edx,16
				or		edx,2
				invoke SendMessage,hGrd,GM_SETCELLDATA,edx,addr val
				invoke SetFocus,hGrd
				mov		fDialogChanged,TRUE
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNRESDEL
				invoke SendMessage,hGrd,GM_GETCURROW,0,0
				push	eax
				invoke SendMessage,hGrd,GM_DELROW,eax,0
				pop		eax
				invoke SendMessage,hGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hGrd
				mov		fDialogChanged,TRUE
				invoke NotifyParent
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNRESPREVIEW
				invoke SendMessage,hGrd,GM_GETCURROW,0,0
				mov		ecx,eax
				shl		ecx,16
				invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer1
				mov		eax,dword ptr buffer1
				.if !eax || eax==1 || eax==2 || eax==3 || eax==8
					invoke SendMessage,hGrd,GM_GETCURROW,0,0
					mov		ecx,eax
					shl		ecx,16
					or		ecx,3
					invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
					mov		buffer1[4],0
					mov		al,buffer[1]
					.if al!=':'
						invoke strcpy,addr buffer1[4],addr szProjectPath
						invoke strcat,addr buffer1[4],addr szBS
					.endif
					invoke strcat,addr buffer1[4],addr buffer
					invoke DialogBoxParam,hInstance,IDD_RESPREVIEW,hWin,addr ResPreviewProc,addr buffer1
				.endif
			.elseif eax==IDC_BTNRESEDIT
				invoke SendMessage,hGrd,GM_GETCURROW,0,0
				mov		ecx,eax
				shl		ecx,16
				invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer1
				mov		eax,dword ptr buffer1
				mov		ecx,sizeof RARSTYPE
				mul		ecx
				add		eax,offset rarstype
				lea		eax,[eax].RARSTYPE.szedit
				.if byte ptr [eax]
					push	eax
					invoke SendMessage,hGrd,GM_GETCURROW,0,0
					mov		ecx,eax
					shl		ecx,16
					or		ecx,3
					invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer1
					mov		al,buffer[1]
					.if al!=':'
						invoke strcpy,addr buffer,addr szProjectPath
						invoke strcat,addr buffer,addr szBS
					.endif
					invoke strcat,addr buffer,addr buffer1
					pop		edx
					invoke ShellExecute,hWin,NULL,edx,addr buffer,NULL,SW_SHOWNORMAL
				.endif
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		invoke GetDlgItem,hWin,IDC_GRDRES
		mov		hGrd,eax
		mov		esi,lParam
		mov		eax,[esi].NMHDR.hwndFrom
		.if eax==hGrd
			mov		eax,[esi].NMHDR.code
			.if eax==GN_HEADERCLICK
				;Sort the grid by column, invert sorting order
				invoke SendMessage,hGrd,GM_COLUMNSORT,[esi].GRIDNOTIFY.col,SORT_INVERT
			.elseif eax==GN_BUTTONCLICK
				;Cell button clicked
				;Zero out the ofn struct
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				invoke RtlZeroMemory,addr buffer1,sizeof buffer1
				;Type
				mov		ecx,[esi].GRIDNOTIFY.row
				shl		ecx,16
				invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
				mov		eax,dword ptr buffer
				mov		ecx,sizeof RARSTYPE
				mul		ecx
				add		eax,offset rarstype
				invoke strcpy,addr buffer1,addr [eax].RARSTYPE.szext
				lea		eax,buffer1
				mov		ofn.lpstrFilter,eax
				.while byte ptr [eax]
					.if byte ptr [eax]=='|'
						mov		byte ptr [eax],0
					.endif
					inc		eax
				.endw
				mov		eax,[esi].GRIDNOTIFY.lpdata
				.if byte ptr [eax]
					invoke strcpy,addr buffer2,[esi].GRIDNOTIFY.lpdata                   ; *** mOD
					invoke PathCombine,addr buffer, offset szProjectPath, addr buffer2   ; *** MOD
				.else
					mov		buffer,0
				.endif
				;Setup the ofn struct
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrInitialDir,offset szProjectPath
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.lpstrDefExt,NULL
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				
				; *** MOD
				.if eax
					invoke PathRelativePathTo, addr buffer1, addr szProjectPath, FILE_ATTRIBUTE_DIRECTORY, addr buffer, NULL
					.if eax
						invoke strcpy,[esi].GRIDNOTIFY.lpdata,addr buffer1
					.else
						invoke strcpy,[esi].GRIDNOTIFY.lpdata,addr buffer
					.endif
					mov		[esi].GRIDNOTIFY.fcancel,FALSE
					mov		fDialogChanged,TRUE
				.else
					mov		[esi].GRIDNOTIFY.fcancel,TRUE
				.endif
			
;				.if eax
;					invoke RemovePath,addr buffer,addr szProjectPath
;					mov		edx,[esi].GRIDNOTIFY.lpdata
;					invoke strcpy,edx,eax
;					mov		[esi].GRIDNOTIFY.fcancel,FALSE
;					mov		fDialogChanged,TRUE
;				.else
;					mov		[esi].GRIDNOTIFY.fcancel,TRUE
;				.endif
			.elseif eax==GN_BEFOREUPDATE
				.if [esi].GRIDNOTIFY.col==1
					invoke CheckName,[esi].GRIDNOTIFY.lpdata
					.if eax
						mov		[esi].GRIDNOTIFY.fcancel,TRUE
					.endif
				.endif
			.elseif eax==GN_AFTERUPDATE
				mov		fDialogChanged,TRUE
				call Enable
				invoke NotifyParent
			.elseif eax==GN_AFTERSELCHANGE
				call Enable
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke GetDlgItem,hWin,IDC_GRDRES
		mov		hGrd,eax
		invoke SaveGrdSize,hGrd,4,offset ResGrdSize
		mov		 fNoScroll,FALSE
    	invoke ShowScrollBar,hDEd,SB_BOTH,TRUE
		invoke DestroyWindow,hWin
	.elseif eax==WM_SIZE
		invoke SendMessage,hDEd,WM_VSCROLL,SB_THUMBTRACK,0
		invoke SendMessage,hDEd,WM_HSCROLL,SB_THUMBTRACK,0
		invoke GetClientRect,hDEd,addr rect
		mov		rect.left,3
		mov		rect.top,3
		sub		rect.right,6
		sub		rect.bottom,6
		invoke MoveWindow,hWin,rect.left,rect.top,rect.right,rect.bottom,TRUE
		invoke GetClientRect,hWin,addr rect
		.if rect.right<470
			mov		rect.right,470
		.endif

		invoke GetDlgItem,hWin,IDC_BTNRESADD
		mov		edx,rect.right
		sub		edx,64+3
		invoke MoveWindow,eax,edx,3,64,22,TRUE

		invoke GetDlgItem,hWin,IDC_BTNRESDEL
		mov		edx,rect.right
		sub		edx,64+3
		invoke MoveWindow,eax,edx,3+22+6,64,22,TRUE

		invoke GetDlgItem,hWin,IDC_BTNRESPREVIEW
		mov		edx,rect.right
		sub		edx,64+3
		invoke MoveWindow,eax,edx,3+22+6+22+6,64,22,TRUE

		invoke GetDlgItem,hWin,IDC_BTNRESEDIT
		mov		edx,rect.right
		sub		edx,64+3
		invoke MoveWindow,eax,edx,3+22+6+22+6+22+6,64,22,TRUE

		invoke GetDlgItem,hWin,IDC_GRDRES
		mov		hGrd,eax
		mov		rect.left,3
		mov		rect.top,3
		sub		rect.right,3+64+6
		sub		rect.bottom,6
		invoke MoveWindow,hGrd,rect.left,rect.top,rect.right,rect.bottom,TRUE
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
  Ex:
	ret

Enable:
	;Type
	mov		ecx,[esi].GRIDNOTIFY.row
	shl		ecx,16
	invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
	mov		eax,dword ptr buffer
	.if !eax || eax==1 || eax==2 || eax==3 || eax==8
		invoke GetDlgItem,hWin,IDC_BTNRESPREVIEW
		invoke EnableWindow,eax,TRUE
	.else
		invoke GetDlgItem,hWin,IDC_BTNRESPREVIEW
		invoke EnableWindow,eax,FALSE
	.endif
	mov		eax,dword ptr buffer
	mov		ecx,sizeof RARSTYPE
	mul		ecx
	add		eax,offset rarstype
	.if byte ptr [eax].RARSTYPE.szedit
		invoke GetDlgItem,hWin,IDC_BTNRESEDIT
		invoke EnableWindow,eax,TRUE
	.else
		invoke GetDlgItem,hWin,IDC_BTNRESEDIT
		invoke EnableWindow,eax,FALSE
	.endif
	retn

ResourceEditProc endp
