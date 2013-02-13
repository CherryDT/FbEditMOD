
FBM_GETIMAGELIST		equ WM_USER+13	;wParam=0, lParam=0

REM_BASE				equ WM_USER+1000
REM_SETFONT				equ REM_BASE+1		;wParam=nLineSpacing, lParam=lpRAFONT
REM_GETFONT				equ REM_BASE+2		;wParam=0, lParam=lpRAFONT
REM_SETCOLOR			equ REM_BASE+3		;wParam=0, lParam=lpRACOLOR
REM_GETCOLOR			equ REM_BASE+4		;wParam=0, lParam=lpRACOLOR

RAFONT struct
	hFont		dd ?						;Code edit normal
	hIFont		dd ?						;Code edit italics
	hLnrFont	dd ?						;Line numbers
RAFONT ends

RACOLOR struct
	bckcol		dd ?						;Back color
	txtcol		dd ?						;Text color
	selbckcol	dd ?						;Sel back color
	seltxtcol	dd ?						;Sel text color
	cmntcol		dd ?						;Comment color
	strcol		dd ?						;String color
	oprcol		dd ?						;Operator color
	hicol1		dd ?						;Line hilite 1
	hicol2		dd ?						;Line hilite 2
	hicol3		dd ?						;Line hilite 3
	selbarbck	dd ?						;Selection bar
	selbarpen	dd ?						;Selection bar pen
	lnrcol		dd ?						;Line numbers color
	numcol		dd ?						;Numbers & hex color
	cmntback	dd ?						;Comment back color
	strback		dd ?						;String back color
	numback		dd ?						;Numbers & hex back color
	oprback		dd ?						;Operator back color
	changed		dd ?						;Line changed indicator
	changesaved	dd ?						;Line saved chane indicator
RACOLOR ends

;Sniplets.dlg
IDD_DLGSNIPLETS					equ 4000
IDC_TRVSNIPLET					equ 1001
IDC_RAECODE						equ 1002
IDC_BTNOUTPUT					equ 1003

.data?

szFile							db MAX_PATH dup(?)

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

GetFileImg proc uses esi,lpFile:DWORD

	mov		esi,lpFile
	invoke lstrlen,esi
	.while eax
		.if byte ptr [esi+eax-1]=='.'
			.break
		.endif
		dec		eax
	.endw
	lea		esi,[esi+eax]
	invoke lstrcmpi,esi,offset szAsmFile
	.if !eax
		mov		eax,2
	.else
		invoke lstrcmpi,esi,offset szIncFile
		.if !eax
			mov		eax,3
		.else
			invoke lstrcmpi,esi,offset szRcFile
			.if !eax
				mov		eax,4
			.else
				mov		eax,5
			.endif
		.endif
	.endif
	ret

GetFileImg endp

TrvDir proc hTrv:HWND,hPar:DWORD,lpPth:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hwfd:DWORD
	LOCAL	hpar:DWORD
	LOCAL	ftp:DWORD

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
	invoke lstrcat,addr buffer,addr szAPA
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
			;Some file filtering could be done here
			invoke GetFileImg,addr wfd.cFileName
			invoke TrvAddNode,hTrv,hPar,addr wfd.cFileName,eax
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

StreamInProc proc hFile:DWORD,pBuffer:DWORD,NumBytes:DWORD,pBytesRead:DWORD

	invoke ReadFile,hFile,pBuffer,NumBytes,pBytesRead,0
	xor		eax,1
	ret

StreamInProc endp

SnipletsProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rafnt:RAFONT
	LOCAL	racol:RACOLOR
	LOCAL	hTrv:HWND
	LOCAL	hREd:HWND
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	hFile:HANDLE
	LOCAL   editstream:EDITSTREAM
	LOCAL	chrg:CHARRANGE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		ebx,lpHandles
		invoke SendMessage,[ebx].ADDINHANDLES.hBrowse,FBM_GETIMAGELIST,0,0
		invoke SendDlgItemMessage,hWin,IDC_TRVSNIPLET,TVM_SETIMAGELIST,TVSIL_NORMAL,eax
		invoke SendMessage,[ebx].ADDINHANDLES.hOut,REM_GETFONT,0,addr rafnt
		invoke SendDlgItemMessage,hWin,IDC_RAECODE,REM_SETFONT,0,addr rafnt
		invoke SendMessage,[ebx].ADDINHANDLES.hOut,REM_GETCOLOR,0,addr racol
		invoke SendDlgItemMessage,hWin,IDC_RAECODE,REM_SETCOLOR,0,addr racol
		invoke GetDlgItem,hWin,IDC_TRVSNIPLET
		mov		hTrv,eax
		invoke SendMessage,[ebx].ADDINHANDLES.hBrowse,FBM_GETIMAGELIST,0,0
		invoke SendMessage,hTrv,TVM_SETIMAGELIST,TVSIL_NORMAL,eax
		invoke TrvDir,hTrv,0,offset SnipletPath
	.elseif eax==WM_COMMAND
		mov		ebx,lpHandles
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				call	GetText
				invoke SendMessage,[ebx].ADDINHANDLES.hREd,EM_REPLACESEL,TRUE,offset tempbuff
			.elseif eax==IDC_BTNOUTPUT
				call	GetText
				invoke SendMessage,[ebx].ADDINHANDLES.hOut,WM_SETTEXT,0,offset tempbuff
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
				invoke lstrcpy,addr buffer,offset SnipletPath
				invoke lstrcat,addr buffer,addr buffer1
				invoke lstrcmp,addr buffer,addr szFile
				.if eax
					invoke GetDlgItem,hWin,IDC_RAECODE
					mov		hREd,eax
					invoke SendMessage,hREd,WM_SETTEXT,0,0
					invoke lstrcpy,addr szFile,addr buffer
					invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
					.if eax!=INVALID_HANDLE_VALUE
						mov		hFile,eax
						invoke SendMessage,hREd,WM_SETTEXT,0,0
						;stream the text into the richedit control
						m2m		editstream.dwCookie,hFile
						mov		editstream.pfnCallback,offset StreamInProc
						invoke SendMessage,hREd,EM_STREAMIN,SF_TEXT,addr editstream
						invoke CloseHandle,hFile
						invoke SendMessage,hREd,EM_SETMODIFY,FALSE,0
						invoke SendMessage,hREd,EM_SETSEL,0,0
						mov		ebx,lpHandles
						.if [ebx].ADDINHANDLES.hREd
							invoke GetWindowLong,[ebx].ADDINHANDLES.hREd,GWL_ID
							mov		edx,FALSE
							.if eax==IDC_RAE
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
	invoke SendDlgItemMessage,hWin,IDC_RAECODE,EM_EXGETSEL,0,addr chrg
	mov		eax,chrg.cpMax
	.if eax==chrg.cpMin
		invoke GetDlgItemText,hWin,IDC_RAECODE,offset tempbuff,sizeof tempbuff-1
	.else
		sub		eax,chrg.cpMin
		.if eax>sizeof tempbuff-1
			mov		eax,sizeof tempbuff-1
			add		eax,chrg.cpMin
			mov		chrg.cpMax,eax
			invoke SendDlgItemMessage,hWin,IDC_RAECODE,EM_EXSETSEL,0,addr chrg
		.endif
		invoke SendDlgItemMessage,hWin,IDC_RAECODE,EM_GETSELTEXT,0,offset tempbuff
	.endif
	retn

SnipletsProc endp
