.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include CombinePicture.inc

.code

;########################################################################

BrowseFolder proc hWin:HWND,nID:DWORD,lpCaption:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		bri.pidlRoot,0
	mov		bri.pszDisplayName,0
	mov		eax,lpCaption
	mov		bri.lpszTitle,eax
	mov		bri.ulFlags,BIF_RETURNONLYFSDIRS or BIF_STATUSTEXT 
	mov		bri.lpfn,BrowseCallbackProc
	; get path   
	invoke SendDlgItemMessage,hWin,nID,WM_GETTEXT,sizeof buffer,addr buffer
	lea		eax,buffer
	mov		bri.lParam,eax 
	mov		bri.iImage,0
	invoke SHBrowseForFolder,offset bri
	.if !eax
		jmp		GetOut
	.endif      
	mov		pidl,eax
	invoke SHGetPathFromIDList,pidl,addr buffer
	; set new path back to edit
	invoke SendDlgItemMessage,hWin,nID,WM_SETTEXT,0,addr buffer
  GetOut:
	ret

BrowseFolder endp

;--------------------------------------------------------------------------------
; set initial folder in browser
BrowseCallbackProc proc hwnd:DWORD,uMsg:UINT,lParam:LPARAM,lpData:DWORD

	mov eax,uMsg
	.if eax==BFFM_INITIALIZED
		invoke PostMessage,hwnd,BFFM_SETSELECTION,TRUE,lpData
	.endif
	xor eax, eax
	ret

BrowseCallbackProc endp

GetEncoderClsid proc
	LOCAL	numEncoders:DWORD
	LOCAL	nSize:DWORD
	LOCAL	hMem:DWORD

	invoke MultiByteToWideChar,CP_ACP,0,offset szMimeType,-1,offset wbuffer,MAX_PATH
	mov		wbuffer[eax*2],0
	invoke GdipGetImageEncodersSize,addr numEncoders,addr nSize
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,nSize
	mov		hMem,eax
	invoke GdipGetImageEncoders,numEncoders,nSize,hMem
	mov		ebx,hMem
	.while numEncoders
		invoke lstrcmpiW,[ebx].ImageCodecInfo.MimeType,offset wbuffer
		.if !eax
			invoke RtlMoveMemory,offset EncoderClsid,addr [ebx].ImageCodecInfo.ClassID,sizeof GUID
			.break
		.endif
		add		ebx,sizeof ImageCodecInfo
		dec		numEncoders
	.endw
	invoke GlobalFree,hMem
	ret

GetEncoderClsid endp

ConvertPicture proc lpSourceFileName:DWORD,lpDestFileName:DWORD
	LOCAL	image:DWORD

	invoke GetFileAttributes,lpSourceFileName
	.if eax!=INVALID_HANDLE_VALUE
		;Load the bitmap and save as jpeg
		xor		eax,eax
		mov		image,eax
		invoke RtlZeroMemory,addr wbuffer,sizeof wbuffer
		invoke MultiByteToWideChar,CP_OEMCP,MB_PRECOMPOSED,lpSourceFileName,-1,addr wbuffer,MAX_PATH
		mov		wbuffer[eax*2],0
		invoke GdipLoadImageFromFile,addr wbuffer,addr image
		.if !eax
			invoke RtlZeroMemory,addr wbuffer,sizeof wbuffer
			invoke MultiByteToWideChar,CP_OEMCP,MB_PRECOMPOSED,lpDestFileName,-1,addr wbuffer,MAX_PATH
			mov		wbuffer[eax*2],0
			invoke GdipSaveImageToFile,image,addr wbuffer,addr EncoderClsid,0
			invoke GdipDisposeImage,image
		.endif
	.endif
	ret

ConvertPicture endp

Convert proc x:DWORD,y:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	src[MAX_PATH]:BYTE
	LOCAL	dst[MAX_PATH]:BYTE

	invoke wsprintf,addr buffer,addr szSourceFileName,y,x
	invoke lstrcpy,addr src,addr SourcePath
	invoke lstrcat,addr src,addr szBS
	invoke lstrcat,addr src,addr buffer
	invoke wsprintf,addr buffer,addr szDestinationFileName,y,x
	invoke lstrcpy,addr dst,addr DestPath
	invoke lstrcat,addr dst,addr szBS
	invoke lstrcat,addr dst,addr buffer
	invoke ConvertPicture,addr src,addr dst
	ret

Convert endp

RevolveFiles proc uses ebx esi
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	src[MAX_PATH]:BYTE
	LOCAL	dst[MAX_PATH]:BYTE

	;Get number of map tiles in x direction
	xor		ebx,ebx
	xor		esi,esi
	.while TRUE
		call	MakeSourceFileName
		invoke GetFileAttributes,addr src
		.break .if eax==INVALID_HANDLE_VALUE
		inc		ebx
	.endw
	mov		nx,ebx
	;Get number of map tiles in y direction
	xor		ebx,ebx
	xor		esi,esi
	.while TRUE
		call	MakeSourceFileName
		invoke GetFileAttributes,addr src
		.break .if eax==INVALID_HANDLE_VALUE
		inc		esi
	.endw
	mov		ny,esi
	;Rename all files
	xor		esi,esi
	.while esi<ny
		xor		ebx,ebx
		.while ebx<nx
			call	MakeSourceFileName
			push	ebx
			mov		eax,nx
			shr		eax,1
			add		ebx,eax
			mov		eax,nx
			dec		eax
			and		ebx,eax
			call	MakeDestFileName
			invoke MoveFile,addr src,addr dst
			pop		ebx
			inc		ebx
		.endw
		inc		esi
	.endw
	ret

MakeSourceFileName:
	invoke wsprintf,addr buffer,addr szDestinationFileName,esi,ebx
	invoke lstrcpy,addr src,addr SourcePath
	invoke lstrcat,addr src,addr szBS
	invoke lstrcat,addr src,addr buffer
	retn

MakeDestFileName:
	invoke wsprintf,addr buffer,addr szDestinationFileName,esi,ebx
	invoke lstrcpy,addr dst,addr DestPath
	invoke lstrcat,addr dst,addr szBS
	invoke lstrcat,addr dst,addr buffer
	retn

RevolveFiles endp

SaveDIB32 proc uses ebx esi edi,hBmp:HBITMAP,x:DWORD,y:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hFile:HANDLE
	LOCAL	cbWrite:DWORD
	LOCAL	dibs:BITMAP
	LOCAL	pBMI:DWORD
	LOCAL	DataSize:DWORD
	LOCAL	pBFH:DWORD

	invoke wsprintf,addr buffer,addr szSourceFileName,y,x
	invoke lstrcpy,addr SaveFileName,addr DestPath
	invoke lstrcat,addr SaveFileName,addr szBS
	invoke lstrcat,addr SaveFileName,addr buffer
	invoke CreateFile,addr SaveFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	mov		hFile,eax
	invoke GetObject,hBmp,SIZEOF BITMAP,addr dibs
	;Calculate Data size
	mov		eax,dibs.bmHeight
	shl		eax,2
	mul 	dibs.bmWidth
	mov		DataSize,eax
	;Create a memory buffer
	xor		eax,eax
	add		eax,sizeof BITMAPINFOHEADER
	add		eax,sizeof BITMAPFILEHEADER
	add		eax,DataSize
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
	mov		pBFH,eax
	add		eax,sizeof BITMAPFILEHEADER
	mov 	pBMI,eax
	;Bitmap header is address sensitive do not pass through generic routine
	mov		edi,pBMI
	mov		[edi].BITMAPINFO.bmiHeader.biXPelsPerMeter,0
	mov		[edi].BITMAPINFO.bmiHeader.biYPelsPerMeter,0
	mov		[edi].BITMAPINFO.bmiHeader.biClrUsed,0
	mov		[edi].BITMAPINFO.bmiHeader.biClrImportant,0
	mov		[edi].BITMAPINFO.bmiHeader.biSize,sizeof BITMAPINFOHEADER
	mov		eax,dibs.bmWidth
	mov		[edi].BITMAPINFO.bmiHeader.biWidth,eax
	mov		eax,dibs.bmHeight
	mov		[edi].BITMAPINFO.bmiHeader.biHeight,eax
	mov		[edi].BITMAPINFO.bmiHeader.biPlanes,1
	mov		[edi].BITMAPINFO.bmiHeader.biCompression,BI_RGB
	mov		[edi].BITMAPINFO.bmiHeader.biBitCount,32
	mov		eax,DataSize
	mov		[edi].BITMAPINFO.bmiHeader.biSizeImage,eax
	mov		esi,pBFH
	mov		[esi].BITMAPFILEHEADER.bfType,"MB"
	mov		eax,DataSize
	add		eax,sizeof BITMAPINFOHEADER + sizeof BITMAPFILEHEADER
	mov		[esi].BITMAPFILEHEADER.bfSize,eax
	mov		[esi].BITMAPFILEHEADER.bfReserved1,0
	mov		[esi].BITMAPFILEHEADER.bfReserved2,0
	mov		eax,sizeof BITMAPFILEHEADER
	add		eax,sizeof BITMAPINFOHEADER	
	mov		[esi].BITMAPFILEHEADER.bfOffBits,eax
	mov		ecx,sizeof BITMAPFILEHEADER
	add		ecx,sizeof BITMAPINFOHEADER
	push	ecx
	invoke WriteFile,hFile,pBFH,ecx,addr cbWrite,NULL
	pop		ebx
	add		ebx,pBFH
	invoke GetBitmapBits,hBmp,DataSize,ebx
	call	Flip
	invoke WriteFile,hFile,ebx,DataSize,addr cbWrite,NULL
	invoke GlobalFree,ebx
	invoke GlobalFree,pBFH
	mov		eax,hFile
	ret

Flip:
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,DataSize
	push	eax
	mov		edi,eax
	mov		esi,ebx
	add		esi,DataSize
	mov		eax,dibs.bmWidth
	shl		eax,2
	mov		ebx,eax
	mov		edx,dibs.bmHeight
	.while edx
		push	edx
		sub		esi,ebx
		push	esi
		mov		ecx,ebx
		rep		movsb
		pop		esi
		pop		edx
		dec		edx
	.endw
	pop		ebx
	retn

SaveDIB32 endp

Load_Image proc lpFileName:DWORD
	LOCAL	hBmp:DWORD
	LOCAL	image:DWORD

	;Load the bitmap and convert it to a bitmap handle
	xor		eax,eax
	mov		hBmp,eax
	mov		image,eax
	invoke RtlZeroMemory,addr wbuffer,sizeof wbuffer
	invoke MultiByteToWideChar,CP_OEMCP,MB_PRECOMPOSED,lpFileName,-1,addr wbuffer,MAX_PATH
	mov		wbuffer[eax*2],0
	invoke GdipLoadImageFromFile,addr wbuffer,addr image
	.if !eax
		;Convert to bitmap handle
		invoke GdipCreateHBITMAPFromBitmap,image,addr hBmp,0
		invoke GdipDisposeImage,image
	.endif
	mov		eax,hBmp
	ret

Load_Image endp

Combine proc uses ebx esi edi,stx:DWORD,sty:DWORD,n:DWORD
	LOCAL	hDC:HDC
	LOCAL	tDC:HDC
	LOCAL	mDC:HDC
	LOCAL	hBmp:HBITMAP
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke GetDlgItem,hDlg,IDC_IMG1
	invoke GetDC,eax
	mov		hDC,eax
	invoke CreateCompatibleDC,hDC
	mov		mDC,eax
	invoke CreateCompatibleDC,hDC
	mov		tDC,eax
	invoke CreateCompatibleBitmap,hDC,512,512
	invoke SelectObject,mDC,eax
	push	eax
	invoke SetStretchBltMode,mDC,COLORONCOLOR
	mov		edi,sty
	xor		ebx,ebx
	.while ebx<n
		push	ebx
		mov		esi,stx
		xor		ebx,ebx
		.while ebx<n
			invoke wsprintf,addr buffer,addr szSourceFileName,edi,esi
			invoke lstrcpy,addr OpenFileName,addr SourcePath
			invoke lstrcat,addr OpenFileName,addr szBS
			invoke lstrcat,addr OpenFileName,addr buffer
			invoke Load_Image,addr OpenFileName
			invoke SelectObject,tDC,eax
			push	eax
			mov		ecx,esi
			sub		ecx,stx
			mov		edx,edi
			sub		edx,sty
			.if n==2
				shl		ecx,8
				shl		edx,8
				invoke StretchBlt,mDC,ecx,edx,256,256,tDC,0,0,512,512,SRCCOPY
			.elseif n==4
				shl		ecx,7
				shl		edx,7
				invoke StretchBlt,mDC,ecx,edx,128,128,tDC,0,0,512,512,SRCCOPY
			.elseif n==8
				shl		ecx,6
				shl		edx,6
				invoke StretchBlt,mDC,ecx,edx,64,64,tDC,0,0,512,512,SRCCOPY
			.elseif n==16
				shl		ecx,5
				shl		edx,5
				invoke StretchBlt,mDC,ecx,edx,32,32,tDC,0,0,512,512,SRCCOPY
			.endif
			;Preview of map tile
			invoke StretchBlt,hDC,16,16,64,64,tDC,0,0,512,512,SRCCOPY
			pop		eax
			invoke SelectObject,tDC,eax
			invoke DeleteObject,eax
			inc		esi
			inc		ebx
		.endw
		pop		ebx
		inc		edi
		inc		ebx
	.endw
	invoke DeleteDC,tDC
	;Preview of combined map tiles
	invoke StretchBlt,hDC,150,16,256,256,mDC,0,0,512,512,SRCCOPY
	pop		eax
	invoke SelectObject,mDC,eax
	push	eax
	invoke DeleteDC,mDC
	invoke GetDlgItem,hDlg,IDC_IMG1
	invoke ReleaseDC,eax,hDC
	pop		eax
	ret

Combine endp

GetMapDimension proc uses ebx
	LOCAL	buffer[MAX_PATH]:BYTE

	;Get number of map tiles in x direction
	xor		ebx,ebx
	.while TRUE
		invoke wsprintf,addr buffer,addr szSourceFileName,0,ebx
		invoke lstrcpy,addr OpenFileName,addr SourcePath
		invoke lstrcat,addr OpenFileName,addr szBS
		invoke lstrcat,addr OpenFileName,addr buffer
		invoke GetFileAttributes,addr OpenFileName
		.break .if eax==INVALID_HANDLE_VALUE
		inc		ebx
		mov		nx,ebx
	.endw
	;Get number of map tiles in y direction
	xor		ebx,ebx
	.while TRUE
		invoke wsprintf,addr buffer,addr szSourceFileName,ebx,0
		invoke lstrcpy,addr OpenFileName,addr SourcePath
		invoke lstrcat,addr OpenFileName,addr szBS
		invoke lstrcat,addr OpenFileName,addr buffer
		invoke GetFileAttributes,addr OpenFileName
		.break .if eax==INVALID_HANDLE_VALUE
		inc		ebx
		mov		ny,ebx
	.endw
	ret

GetMapDimension endp

DlgProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	n:DWORD
	LOCAL	x:DWORD
	LOCAL	y:DWORD
	LOCAL	sx:DWORD
	LOCAL	sy:DWORD
	LOCAL	hBmp:HBITMAP

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hDlg,eax
		invoke GetModuleFileName,hInstance,addr AppPath,sizeof AppPath
		invoke lstrlen,addr AppPath
		.while AppPath[eax]!='\' && eax
			dec		eax
		.endw
		mov		AppPath[eax],0
		mov		esi,offset szCboCombine
		.while byte ptr [esi]
			invoke SendDlgItemMessage,hWin,IDC_CBOSIZE,CB_ADDSTRING,0,addr [esi+1]
			movzx	edx,byte ptr [esi]
			invoke SendDlgItemMessage,hWin,IDC_CBOSIZE,CB_SETITEMDATA,eax,edx
			invoke lstrlen,esi
			lea		esi,[esi+eax+1]
		.endw
		invoke SendDlgItemMessage,hWin,IDC_CBOSIZE,CB_SETCURSEL,0,0
		invoke lstrcpy,addr SourcePath,addr AppPath
		invoke lstrcat,addr SourcePath,addr szBmpX1
		invoke SetDlgItemText,hWin,IDC_EDTSOURCE,addr SourcePath
		invoke lstrcpy,addr DestPath,addr AppPath
		invoke lstrcat,addr DestPath,addr szBmpX4
		invoke SetDlgItemText,hWin,IDC_EDTDEST,addr DestPath
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDM_FILE_EXIT || eax==IDCANCEL
				invoke SendDlgItemMessage,hWin,1001,STM_SETIMAGE,IMAGE_BITMAP,0
				invoke DeleteObject,eax
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNCOMBINE
				invoke LoadCursor,0,IDC_WAIT
				invoke SetCursor,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOSIZE,CB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_CBOSIZE,CB_GETITEMDATA,eax,0
				mov		n,eax
				invoke GetDlgItemText,hWin,IDC_EDTSOURCE,offset SourcePath,sizeof SourcePath
				.if SourcePath
					invoke GetDlgItemText,hWin,IDC_EDTDEST,offset DestPath,sizeof DestPath
					invoke GetMapDimension
					xor		eax,eax
					mov		x,eax
					mov		y,eax
					mov		sx,eax
					mov		sy,eax
					.while TRUE
						xor		eax,eax
						mov		x,eax
						mov		sx,eax
						.while TRUE
							invoke Combine,x,y,n
							mov		hBmp,eax
							invoke SaveDIB32,hBmp,sx,sy
							invoke DeleteObject,hBmp
							mov		eax,n
							add		x,eax
							inc		sx
							mov		eax,x
							.break .if eax>=nx
						.endw
						mov		eax,n
						add		y,eax
						inc		sy
						mov		eax,y
						.break .if eax>=ny
					.endw
				.endif
				invoke LoadCursor,0,IDC_ARROW
				invoke SetCursor,eax
			.elseif eax==IDC_BTNCONVERT
				invoke LoadCursor,0,IDC_WAIT
				invoke SetCursor,eax
				invoke GetDlgItemText,hWin,IDC_EDTSOURCE,offset SourcePath,sizeof SourcePath
				invoke GetDlgItemText,hWin,IDC_EDTDEST,offset DestPath,sizeof DestPath
;				invoke RevolveFiles
				invoke GetMapDimension
mov nx,128
mov	ny,128
				xor		ebx,ebx
				.while ebx<ny
					xor		edi,edi
					.while edi<nx
						invoke Convert,edi,ebx
						inc		edi
					.endw
					inc		ebx
				.endw
				invoke LoadCursor,0,IDC_ARROW
				invoke SetCursor,eax
			.elseif eax==IDC_BTNSOURCE
				invoke BrowseFolder,hWin,IDC_EDTSOURCE,offset szBrowseSource
			.elseif eax==IDC_BTNDEST
				invoke BrowseFolder,hWin,IDC_EDTDEST,offset szBrowseDestination
			.endif
		.elseif edx==CBN_SELCHANGE
			invoke lstrcpy,addr DestPath,addr AppPath
			invoke SendDlgItemMessage,hWin,IDC_CBOSIZE,CB_GETCURSEL,0,0
			.if eax==0
				invoke lstrcat,addr DestPath,addr szBmpX4
			.elseif eax==1
				invoke lstrcat,addr DestPath,addr szBmpX16
			.elseif eax==2
				invoke lstrcat,addr DestPath,addr szBmpX64
			.elseif eax==3
				invoke lstrcat,addr DestPath,addr szBmpX256
			.endif
			invoke SetDlgItemText,hWin,IDC_EDTDEST,addr DestPath
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax
    invoke InitCommonControls
	; Initialize GDI+ Librery
    mov     gdiplSTI.GdiplusVersion,1
    invoke GdiplusStartup,addr token,addr gdiplSTI,NULL
	; Get Gdi+ jpeg encoder clsid for saving jpeg's
	invoke GetEncoderClsid
	invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
	invoke ExitProcess,0

end start
