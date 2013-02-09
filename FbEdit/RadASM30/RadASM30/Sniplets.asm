;Sniplets.dlg
IDD_DLGSNIPLETS					equ 3900
IDC_TRVSNIPLET					equ 1001
IDC_RAECODE						equ 1002
IDC_BTNOUTPUT					equ 1003

.data?

szSnipletFile					db MAX_PATH dup(?)

.code

TrvAddNode proc hTrv:HWND,hPar:DWORD,lpPth:DWORD,nImg:DWORD
	LOCAL	tvins:TV_INSERTSTRUCT

	mov		eax,hPar
    mov		tvins.hParent,eax
    mov		tvins.item.lParam,eax
    mov		tvins.hInsertAfter,0
    mov		tvins.item._mask,TVIF_TEXT or TVIF_PARAM or TVIF_IMAGE or TVIF_SELECTEDIMAGE
	mov		eax,lpPth
	mov		tvins.item.pszText,eax
	mov		eax,nImg
    mov		tvins.item.iImage,eax
    mov		tvins.item.iSelectedImage,eax
    invoke SendMessage,hTrv,TVM_INSERTITEM,0,addr tvins
    ret

TrvAddNode endp

GetFileImg proc uses ebx esi edi,lpFile:DWORD
	LOCAL	bufftype[64]:BYTE

	mov		esi,lpFile
	invoke lstrlen,esi
	.while byte ptr [esi+eax]!='.' && eax
		dec		eax
	.endw
	invoke strcpy,addr bufftype,addr [esi+eax]
	invoke strcat,addr bufftype,addr szDot
	xor		edi,edi
	.while TRUE
		invoke SendMessage,ha.hProjectBrowser,RPBM_GETFILEEXT,edi,0
		mov		ebx,eax
		.break.if ![ebx].PBFILEEXT.id
		invoke IsFileType,addr bufftype,addr [ebx].PBFILEEXT.szfileext
		.break .if eax
		inc		edi
	.endw
	mov		eax,[ebx].PBFILEEXT.id
	.if eax
		dec		eax
	.endif
	ret

GetFileImg endp

TrvDir proc hTrv:HWND,hPar:DWORD,lpPth:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	wfd:WIN32_FIND_DATA
	LOCAL	hwfd:DWORD
	LOCAL	hpar:DWORD

	;Make the path local
	invoke lstrcpy,addr buffer,lpPth
	;Check if path ends with '\'. If not add.
	invoke lstrlen,addr buffer
	dec		eax
	mov		al,buffer[eax]
	.if al!='\'
		invoke lstrcat,addr buffer,addr szBS
	.endif
	;Add '*.*'
	invoke lstrcat,addr buffer,addr szADotA
	;Find first match, if any
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		;Save returned handle
		mov		hwfd,eax
	  Next:
		;Check if found is a dir
		mov		eax,wfd.dwFileAttributes
		and		eax,FILE_ATTRIBUTE_DIRECTORY
		.if eax
			;Do not include '.' and '..'
			mov		al,wfd.cFileName
			.if al!='.'
				invoke TrvAddNode,hTrv,hPar,addr wfd.cFileName,1
				mov		hpar,eax
				invoke lstrlen,addr buffer
				mov		edx,eax
				push	edx
				sub		edx,3
				;Do not remove the '\'
				mov		al,buffer[edx]
				.if al=='\'
					inc		edx
				.endif
				;Add new dir to path
				invoke lstrcpy,addr buffer[edx],addr wfd.cFileName
				;Call myself again, thats recursive!
				invoke TrvDir,hTrv,hpar,addr buffer
				pop		edx
				;Remove what was added
				mov		buffer[edx],0
			.endif
		.else
			;Add file
			invoke GetFileImg,addr wfd.cFileName
			.if eax
				invoke TrvAddNode,hTrv,hPar,addr wfd.cFileName,eax
			.endif
		.endif
		;Any more matches?
		invoke FindNextFile,hwfd,addr wfd
		or		eax,eax
		jne		Next
		;No more matches, close find
		invoke FindClose,hwfd
	.endif
	;Sort the children
	invoke SendMessage,hTrv,TVM_SORTCHILDREN,0,hPar
	;Expand the tree
	invoke SendMessage,hTrv,TVM_EXPAND,TVE_EXPAND,hPar
	ret

TrvDir endp

SnipletsProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hTrv:HWND
	LOCAL	hREd:HWND
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	hFile:HANDLE
	LOCAL   editstream:EDITSTREAM
	LOCAL	chrg:CHARRANGE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendMessage,ha.hFileBrowser,FBM_GETIMAGELIST,0,0
		invoke SendDlgItemMessage,hWin,IDC_TRVSNIPLET,TVM_SETIMAGELIST,TVSIL_NORMAL,eax
		invoke SendDlgItemMessage,hWin,IDC_RAECODE,REM_SETFONT,0,addr ha.racf
		invoke SendDlgItemMessage,hWin,IDC_RAECODE,REM_SETCOLOR,0,addr da.radcolor.racol
		invoke GetDlgItem,hWin,IDC_TRVSNIPLET
		mov		hTrv,eax
		invoke SendMessage,ha.hFileBrowser,FBM_GETIMAGELIST,0,0
		invoke SendMessage,hTrv,TVM_SETIMAGELIST,TVSIL_NORMAL,eax
		invoke strcpy,addr buffer,addr da.szAssemblerPath
		invoke strcat,addr buffer,addr szBSSniplets
		invoke TrvDir,hTrv,0,addr buffer
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				call	GetText
				invoke SendMessage,ha.hEdt,EM_REPLACESEL,TRUE,offset tmpbuff
			.elseif eax==IDC_BTNOUTPUT
				call	GetText
				invoke SendMessage,ha.hOutput,WM_SETTEXT,0,offset tmpbuff
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		.if wParam==IDC_TRVSNIPLET
			mov		edx,lParam
			mov		eax,(NMTREEVIEW ptr [edx]).hdr.code
			.if eax==TVN_SELCHANGED
				lea		edx,(NMTREEVIEW ptr [edx]).itemNew
				mov		(TV_ITEMEX ptr [edx]).imask,TVIF_PARAM or TVIF_TEXT
				lea		eax,buffer
				mov		(TV_ITEMEX ptr [edx]).pszText,eax
				mov		(TV_ITEMEX ptr [edx]).cchTextMax,sizeof buffer
				mov		buffer1[0],0
				mov		buffer1[1],0
			  @@:
				push	edx
				invoke SendDlgItemMessage,hWin,IDC_TRVSNIPLET,TVM_GETITEM,0,edx
				invoke lstrcat,addr buffer,addr buffer1
				invoke lstrcpy,addr buffer1[1],addr buffer
				mov		buffer1[0],'\'
				pop		edx
				mov		eax,(TV_ITEMEX ptr [edx]).lParam
				.if eax
					mov		(TV_ITEMEX ptr [edx]).hItem,eax
					jmp		@b
				.endif
				invoke strcpy,addr buffer,addr da.szAssemblerPath
				invoke strcat,addr buffer,addr szBSSniplets
				invoke lstrcat,addr buffer,addr buffer1
				invoke lstrcmp,addr buffer,addr szSnipletFile
				.if eax
					invoke GetDlgItem,hWin,IDC_RAECODE
					mov		hREd,eax
					invoke SendMessage,hREd,WM_SETTEXT,0,0
					invoke lstrcpy,addr szSnipletFile,addr buffer
					invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
					.if eax!=INVALID_HANDLE_VALUE
						mov		hFile,eax
						;stream the text into the RAEdit control
						m2m		editstream.dwCookie,hFile
						mov		editstream.pfnCallback,offset StreamInProc
						invoke SendMessage,hREd,EM_STREAMIN,SF_TEXT,addr editstream
						invoke CloseHandle,hFile
						invoke SendMessage,hREd,EM_SETMODIFY,FALSE,0
						invoke SendMessage,hREd,EM_SETSEL,0,0
						.if ha.hEdt
							invoke GetWindowLong,ha.hEdt,GWL_ID
							mov		edx,FALSE
							.if eax==ID_EDITCODE
								mov		edx,TRUE
							.endif
						.else
							mov		edx,FALSE
						.endif
						mov		eax,IDOK
						call	EnableBtn
						mov		eax,IDC_BTNOUTPUT
						mov		edx,TRUE
						call	EnableBtn
					.else
						mov		eax,IDOK
						mov		edx,FALSE
						call	EnableBtn
						mov		eax,IDC_BTNOUTPUT
						mov		edx,FALSE
						call	EnableBtn
					.endif
				.endif
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

EnableBtn:
	push	edx
	invoke GetDlgItem,hWin,eax
	pop		edx
	invoke EnableWindow,eax,edx
	retn

GetText:
	invoke RtlZeroMemory,addr tmpbuff,sizeof tmpbuff
	invoke SendDlgItemMessage,hWin,IDC_RAECODE,EM_EXGETSEL,0,addr chrg
	mov		eax,chrg.cpMax
	.if eax==chrg.cpMin
		invoke SendDlgItemMessage,hWin,IDC_RAECODE,WM_GETTEXT,sizeof tmpbuff,addr tmpbuff
	.else
		sub		eax,chrg.cpMin
		.if eax>sizeof tmpbuff-1
			mov		eax,sizeof tmpbuff-1
			add		eax,chrg.cpMin
			mov		chrg.cpMax,eax
			invoke SendDlgItemMessage,hWin,IDC_RAECODE,EM_EXSETSEL,0,addr chrg
		.endif
		invoke SendDlgItemMessage,hWin,IDC_RAECODE,EM_GETSELTEXT,0,offset tmpbuff
	.endif
	retn

SnipletsProc endp
