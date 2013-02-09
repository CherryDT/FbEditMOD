.386
.model flat,stdcall
option casemap:none

include SimCad.inc

.code

DwToAscii proc uses ebx esi edi,dwVal:DWORD,lpAscii:DWORD

	mov		eax,dwVal
	mov		edi,lpAscii
	or		eax,eax
	jns		pos
	mov		byte ptr [edi],'-'
	neg		eax
	inc		edi
  pos:
	mov		ecx,429496730
	mov		esi,edi
  @@:
	mov		ebx,eax
	mul		ecx
	mov		eax,edx
	lea		edx,[edx*4+edx]
	add		edx,edx
	sub		ebx,edx
	add		bl,'0'
	mov		[edi],bl
	inc		edi
	or		eax,eax
	jne		@b
	mov		byte ptr [edi],al
	.while esi<edi
		dec		edi
		mov		al,[esi]
		mov		ah,[edi]
		mov		[edi],al
		mov		[esi],ah
		inc		esi
	.endw
	ret

DwToAscii endp

DoToolBar proc hToolBar:HWND
	LOCAL	tbab:TBADDBITMAP

	;Set toolbar struct size
	invoke SendMessage,hToolBar,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	;Set toolbar bitmap
	push	HINST_COMMCTRL
	pop		tbab.hInst
	mov		tbab.nID,IDB_STD_SMALL_COLOR
	invoke SendMessage,hToolBar,TB_ADDBITMAP,15,addr tbab
	;Set toolbar buttons
	invoke SendMessage,hToolBar,TB_ADDBUTTONS,ntbrbtns,addr tbrbtns
	ret

DoToolBar endp

DoCadBox proc hToolBar:HWND
	LOCAL	tbab:TBADDBITMAP

	;Set toolbar struct size
	invoke SendMessage,hToolBar,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	;Set toolbar bitmap
	push	hInstance
	pop		tbab.hInst
	mov		tbab.nID,IDB_CADBOX
	invoke SendMessage,hToolBar,TB_ADDBITMAP,2,addr tbab
	;Set toolbar buttons
	invoke SendMessage,hToolBar,TB_ADDBUTTONS,cadntbrbtns,addr cadtbrbtns
	ret

DoCadBox endp

SetToolBar proc

	invoke SendMessage,hCad,CM_CANUNDO,0,0
	mov		edx,IDM_EDIT_UNDO
	call	EnableDisable
	invoke SendMessage,hCad,CM_CANREDO,0,0
	mov		edx,IDM_EDIT_REDO
	call	EnableDisable
	invoke SendMessage,hCad,CM_GETSELCOUNT,0,0
	mov		edx,IDM_EDIT_CUT
	call	EnableDisable
	mov		edx,IDM_EDIT_COPY
	call	EnableDisable
	mov		edx,IDM_EDIT_DELETE
	call	EnableDisable
	invoke SendMessage,hCad,CM_CANPASTE,0,0
	mov		edx,IDM_EDIT_PASTE
	call	EnableDisable
	ret

EnableDisable:
	push	eax
	invoke SendMessage,hTbr1,TB_ENABLEBUTTON,edx,eax
	pop		eax
	retn

SetToolBar endp

SetWinCaption proc lpFileName:DWORD
	LOCAL	buffer[sizeof AppName+3+MAX_PATH]:BYTE
	LOCAL	buffer1[4]:BYTE

	;Add filename to windows caption
	invoke lstrcpy,addr buffer,offset AppName
	mov		eax,' - '
	mov		dword ptr buffer1,eax
	invoke lstrcat,addr buffer,addr buffer1
	invoke lstrcat,addr buffer,lpFileName
	invoke SetWindowText,hWnd,addr buffer
	ret

SetWinCaption endp

StreamInProc proc hFile:DWORD,pBuffer:DWORD,NumBytes:DWORD,pBytesRead:DWORD

	invoke ReadFile,hFile,pBuffer,NumBytes,pBytesRead,0
	xor		eax,1
	ret

StreamInProc endp

StreamOutProc proc hFile:DWORD,pBuffer:DWORD,NumBytes:DWORD,pBytesWritten:DWORD

	invoke WriteFile,hFile,pBuffer,NumBytes,pBytesWritten,0
	xor		eax,1
	ret

StreamOutProc endp

SaveCadFile proc hWin:DWORD,lpFileName:DWORD
	LOCAL	hFile:DWORD
	LOCAL	editstream:EDITSTREAM

	invoke CreateFile,lpFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		;stream the text to the file
		mov		editstream.dwCookie,eax
		mov		editstream.pfnCallback,offset StreamOutProc
		invoke SendMessage,hWin,CM_STREAMOUT,0,addr editstream
		invoke CloseHandle,hFile
		;Set the modify state to false
		invoke SendMessage,hWin,CM_SETMODIFY,FALSE,0
   		mov		eax,FALSE
	.else
		invoke MessageBox,hWnd,offset SaveFileFail,offset AppName,MB_OK
		mov		eax,TRUE
	.endif
	ret

SaveCadFile endp

SaveCadAs proc hWin:DWORD,lpFileName:DWORD
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE

	;Zero out the ofn struct
    invoke RtlZeroMemory,addr ofn,sizeof ofn
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	push	hWnd
	pop		ofn.hwndOwner
	push	hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,NULL
	invoke lstrcpy,addr buffer,addr FileName
	lea		eax,buffer
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,sizeof buffer
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
	mov		ofn.lpstrFilter,offset CADFilterString
    mov		ofn.lpstrDefExt,offset Cad
    ;Show save as dialog
	invoke GetSaveFileName,addr ofn
	.if eax
		invoke SaveCadFile,hWin,addr buffer
		.if !eax
			;The file was saved
			invoke lstrcpy,offset FileName,addr buffer
			invoke SetWinCaption,offset FileName
			mov		eax,FALSE
		.endif
	.else
		mov		eax,TRUE
	.endif
	ret

SaveCadAs endp

SaveCad proc hWin:DWORD,lpFileName:DWORD

	;Check if filrname is Untitled.cad
	invoke lstrcmp,lpFileName,offset NewFile
	.if eax
		invoke SaveCadFile,hWin,lpFileName
	.else
		invoke SaveCadAs,hWin,lpFileName
	.endif
	ret

SaveCad endp

WantToSave proc hWin:DWORD,lpFileName:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[2]:BYTE

	invoke SendMessage,hWin,CM_GETMODIFY,0,0
	.if eax
		invoke lstrcpy,addr buffer,offset WannaSave
		invoke lstrcat,addr buffer,lpFileName
		mov		ax,'?'
		mov		word ptr buffer1,ax
		invoke lstrcat,addr buffer,addr buffer1
		invoke MessageBox,hWnd,addr buffer,offset AppName,MB_YESNOCANCEL or MB_ICONQUESTION
		.if eax==IDYES
			invoke SaveCad,hWin,lpFileName
	    .elseif eax==IDNO
		    mov		eax,FALSE
	    .else
		    mov		eax,TRUE
		.endif
	.endif
	ret

WantToSave endp

OpenCadFile proc hWin:DWORD,lpFileName:DWORD
    LOCAL   hFile:DWORD
	LOCAL	editstream:EDITSTREAM

	;Open the file
	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		;stream the text into the cad control
		push	hFile
		pop		editstream.dwCookie
		mov		editstream.pfnCallback,offset StreamInProc
		invoke SendMessage,hWin,CM_STREAMIN,0,addr editstream
		invoke CloseHandle,hFile
		invoke SendMessage,hWin,CM_SETMODIFY,FALSE,0
		invoke LoadCursor,0,IDC_ARROW
		invoke SetCursor,eax
		mov		eax,FALSE
	.else
		invoke MessageBox,hWnd,offset OpenFileFail,offset AppName,MB_OK or MB_ICONERROR
		mov		eax,TRUE
	.endif
	ret

OpenCadFile endp

OpenCad proc
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE

	;Zero out the ofn struct
	invoke RtlZeroMemory,addr ofn,sizeof ofn
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	push	hWnd
	pop		ofn.hwndOwner
	push	hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,offset CADFilterString
	invoke lstrcpy,addr buffer,addr FileName
	lea		eax,buffer
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,sizeof buffer
	mov		ofn.lpstrDefExt,offset Cad
	mov		ofn.Flags,OFN_HIDEREADONLY or OFN_PATHMUSTEXIST; or OFN_FILEMUSTEXIST
	;Show the Open dialog
	invoke GetOpenFileName,addr ofn
	.if eax
		invoke LoadCursor,0,IDC_WAIT
		invoke SetCursor,eax
		invoke lstrcpy,offset FileName,addr buffer
		invoke OpenCadFile,hCad,offset FileName
		.if !eax
			;Copy buffer to FileName
			invoke lstrcpy,offset FileName,addr buffer
			invoke SetWinCaption,offset FileName
			invoke InvalidateRect,hStc,NULL,TRUE
			invoke SendMessage,hCad,CM_GETWIDTH,0,0
			dec		eax
			invoke SendMessage,hCbo,CB_SETCURSEL,eax,0
			invoke SetToolBar
			invoke CheckRadioButton,hWnd,IDC_RBNSCHEMA,IDC_RBNPCBBOTTOM,IDC_RBNSCHEMA
			mov		layer,0
		.endif
	.endif
	ret

OpenCad endp

ScanDir proc lpPth:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hwfd:DWORD

	;Make the path local
	invoke lstrcpy,addr buffer,lpPth
	;Check if path ends with '\'. If not add.
	invoke lstrlen,addr buffer
	dec		eax
	mov		al,buffer[eax]
	.if al!='\'
		invoke lstrcat,addr buffer,addr szBackSlash
	.endif
	;Add '*.*'
	invoke lstrcat,addr buffer,addr szALL
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
				.if !ebx
					mov		ebx,offset sym
				.else
					lea		ebx,[ebx+sizeof SYMBOLS]
					inc		edi
				.endif
				mov		[ebx].SYMBOLS.lpPath,esi
				mov		[ebx].SYMBOLS.lpFiles,edi
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
				invoke lstrcpy,esi,addr wfd.cFileName
				invoke lstrlen,esi
				lea		esi,[esi+eax+1]
				;Call myself again, thats recursive!
				invoke ScanDir,addr buffer
				pop		edx
				;Remove what was added
				mov		buffer[edx],0
			.endif
		.else
			invoke lstrlen,addr wfd.cFileName
			.if eax>4
				invoke lstrcmpi,addr wfd.cFileName[eax-4],offset szCAD
				.if !eax
					;Add file
					invoke lstrcpy,offset FileName,addr buffer
					invoke lstrlen,offset FileName
					.while eax && FileName[eax-1]!='\'
						dec		eax
					.endw
					mov		FileName[eax],0
					invoke lstrcat,offset FileName,addr wfd.cFileName
					invoke lstrcpy,edi,offset FileName
					invoke lstrlen,edi
					lea		edi,[edi+eax+1]
				.endif
			.endif
		.endif
		;Any more matches?
		invoke FindNextFile,hwfd,addr wfd
		or		eax,eax
		jne		Next
		;No more matches, close find
		invoke FindClose,hwfd
	.endif
	ret

ScanDir endp

ShowSym proc uses ebx esi
	
	mov		eax,inxsym
	shl		eax,3
	lea		esi,sym[eax]
	mov		esi,[esi].SYMBOLS.lpFiles
	xor		ebx,ebx
	.if esi
		.while byte ptr [esi] && ebx<16
			invoke OpenCadFile,hSym[ebx*4],esi
			invoke SendMessage,hSym[ebx*4],CM_ZOOMFIT,0,0
			invoke lstrlen,esi
			inc		ebx
			lea		esi,[esi+eax+1]
		.endw
	.endif
	.while ebx<16
		invoke SendMessage,hSym[ebx*4],CM_CLEAR,0,0
		inc		ebx
	.endw
	ret

ShowSym endp

AddSymbol proc uses ebx esi edi,x:DWORD,y:DWORD

	invoke GetWindowLong,hSymSel,0
	lea		esi,[eax+sizeof CADMEM]
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	push	eax
	mov		edi,eax
	mov		ebx,eax
	lea		edi,[edi+sizeof OBJECT]
	mov		[ebx].OBJECT.cbsize,sizeof OBJECT
	mov		[ebx].OBJECT.tpe,TPE_SYMBOL
	mov		[ebx].OBJECT.layer,0
	mov		[ebx].OBJECT.wdt,1
	mov		[ebx].OBJECT.rc.right,0
	mov		[ebx].OBJECT.rc.bottom,0
	mov		eax,x
	mov		[ebx].OBJECT.rc.left,eax
	mov		eax,y
	mov		[ebx].OBJECT.rc.top,eax
	.while sbyte ptr [esi].OBJECT.tpe>0
		mov		eax,[esi].OBJECT.rc.right
		add		eax,x
		.if eax>[ebx].OBJECT.rc.right
			mov		[ebx].OBJECT.rc.right,eax
		.endif
		mov		eax,[esi].OBJECT.rc.bottom
		add		eax,y
		.if eax>[ebx].OBJECT.rc.bottom
			mov		[ebx].OBJECT.rc.bottom,eax
		.endif
		mov		ecx,[esi].OBJECT.cbsize
		add		[ebx].OBJECT.cbsize,ecx
		inc		[ebx].OBJECT.npt
		rep movsb
		mov		eax,layer
		mov		[edi-sizeof OBJECT].OBJECT.layer,al
		mov		eax,x
		add		[edi-sizeof OBJECT].OBJECT.rc.left,eax
		add		[edi-sizeof OBJECT].OBJECT.rc.right,eax
		mov		eax,y
		add		[edi-sizeof OBJECT].OBJECT.rc.top,eax
		add		[edi-sizeof OBJECT].OBJECT.rc.bottom,eax
	.endw
	pop		edi
	invoke SendMessage,hCad,CM_ADDOBJECTS,0,edi 
	invoke GlobalFree,edi
	ret

AddSymbol endp

SymDlgProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	y:DWORD
	LOCAL	pt:POINT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hSymDlg,eax
		mov		y,32
		xor		ebx,ebx
		.while ebx<16
			invoke CreateWindowEx,0,addr CadClass,NULL,WS_CHILD or WS_VISIBLE or WS_DISABLED or WS_BORDER,0,y,32+17,32+17,hWin,NULL,hInstance,0
			mov		hSym[ebx*4],eax
			add		y,32
			inc		ebx
		.endw
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if eax==IDC_BTNNEXT
			inc		inxsym
			and		inxsym,0Fh
			mov		eax,inxsym
			shl		eax,3
			lea		eax,sym[eax]
			mov		eax,[eax].SYMBOLS.lpFiles
			.if !eax
				mov		inxsym,eax
			.endif
			invoke ShowSym
			mov		hSymSel,0
		.elseif eax==IDC_BTNPREV
		  @@:
			dec		inxsym
			and		inxsym,0Fh
			mov		eax,inxsym
			shl		eax,3
			lea		eax,sym[eax]
			mov		eax,[eax].SYMBOLS.lpFiles
			.if !eax
				jmp		@b
			.endif
			invoke ShowSym
			mov		hSymSel,0
		.endif
	.elseif eax==WM_LBUTTONDOWN
		mov		edx,lParam
		movzx	eax,dx
		shr		edx,16
		mov		pt.x,eax
		mov		pt.y,edx
		sub		edx,32
		shr		edx,5		
		.if edx<16
			.if hSymSel
				push	edx
				invoke SendMessage,hSymSel,CM_SETBACKCOLOR,0,0FFFFFFh
				pop		edx
			.endif
			mov		eax,hSym[edx*4]
			mov		hSymSel,eax
			invoke SendMessage,hSymSel,CM_SETBACKCOLOR,0,80FFFFh
		.endif
	.elseif eax==WM_LBUTTONDBLCLK
		mov		edx,lParam
		movzx	eax,dx
		shr		edx,16
		mov		pt.x,eax
		mov		pt.y,edx
		sub		edx,32
		shr		edx,5		
		.if edx<16
			invoke AddSymbol,10,10
			invoke SetToolBar
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

SymDlgProc endp

WndProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ht:DWORD
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	cc:CHOOSECOLOR

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
		invoke CreateDialogParam,hInstance,IDD_DLGSYM,hWin,addr SymDlgProc,0
		invoke GetDlgItem,hWin,IDC_SHP1
		mov		hShp1,eax
		invoke GetDlgItem,hWin,IDC_TBR1
		mov		hTbr1,eax
		invoke DoToolBar,eax
		invoke GetDlgItem,hWin,IDC_CBO1
		mov		hCbo,eax
		invoke GetDlgItem,hWin,IDC_STC1
		mov		hStc,eax
		invoke GetDlgItem,hWin,IDC_EDT1
		mov		hEdt,eax
		invoke GetDlgItem,hWin,IDC_TBR2
		mov		hTbr2,eax
		invoke DoCadBox,eax
		invoke GetDlgItem,hWin,IDC_CAD1
		mov		hCad,eax
		invoke GetDlgItem,hWin,IDC_SBR1
		mov		hSbr,eax
		invoke SendMessage,hSbr,SB_SETPARTS,4,addr sbp
		xor		ebx,ebx
		.while ebx<39
			inc		ebx
			invoke DwToAscii,ebx,addr buffer
			invoke SendMessage,hCbo,CB_ADDSTRING,0,addr buffer
		.endw
		invoke SendMessage,hCbo,CB_SETCURSEL,0,0
		.if wpos.fMax
			invoke MoveWindow,hWnd,wpos.x,wpos.y,wpos.wt,wpos.ht,FALSE
			invoke ShowWindow,hWnd,SW_MAXIMIZE
		.else
			invoke MoveWindow,hWnd,wpos.x,wpos.y,wpos.wt,wpos.ht,FALSE
		.endif
		invoke SetToolBar
		invoke lstrcpy,addr buffer,addr AppPath
		invoke lstrcat,addr buffer,addr szSymbols
		mov		esi,offset pthsym
		mov		edi,offset symfiles
		xor		ebx,ebx
		invoke ScanDir,addr buffer
		invoke ShowSym
		mov		edx,CommandLine
		mov		al,[edx]
		.if al
			invoke lstrcpy,offset FileName,edx
			invoke OpenCadFile,hCad,offset FileName
		.else
			;Set FileName to NewFile
			invoke lstrcpy,offset FileName,offset NewFile
		.endif
		invoke SetWinCaption,offset FileName
		invoke CheckDlgButton,hWin,IDC_RBNSCHEMA,BST_CHECKED
	.elseif eax==WM_INITMENUPOPUP
		mov		eax,lParam
		.if eax==0
		.elseif eax==1
			call	EnableDisableEdit
		.elseif eax==2
			test	wpos.fView,1
			.if !ZERO?
				mov		eax,MF_BYCOMMAND or MF_CHECKED
			.else
				mov		eax,MF_BYCOMMAND or MF_UNCHECKED
			.endif
			invoke CheckMenuItem,wParam,IDM_VIEW_STATUSBAR,eax
			invoke SendMessage,hCad,CM_GETGRID,0,0
			.if eax
				mov		eax,MF_BYCOMMAND or MF_CHECKED
			.else
				mov		eax,MF_BYCOMMAND or MF_UNCHECKED
			.endif
			invoke CheckMenuItem,wParam,IDM_VIEW_GRID,eax
		.endif
	.elseif eax==WM_CONTEXTMENU
		mov		eax,wParam
		.if eax==hCad
			mov		eax,lParam
			.if eax!=-1
				movsx	eax,ax
				mov		pt.x,eax
				mov		eax,lParam
				shr		eax,16
				movsx	eax,ax
				mov		pt.y,eax
			.else
				invoke GetWindowRect,hRACad,addr rect
				mov		eax,rect.left
				add		eax,10
				mov		pt.x,eax
				mov		eax,rect.top
				add		eax,10
				mov		pt.y,eax
			.endif
			;Edit menu
			invoke GetMenu,hWin
			mov		wParam,eax
			call	EnableDisableEdit
			invoke GetMenu,hWin
			invoke GetSubMenu,eax,1
			invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWin,0
		.endif
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if eax==IDM_FILE_NEW
			invoke WantToSave,hCad,offset FileName
			.if !eax
				invoke SendMessage,hCad,CM_CLEAR,0,0
				invoke InvalidateRect,hStc,NULL,TRUE
				invoke SendMessage,hCbo,CB_SETCURSEL,0,0
				invoke SendMessage,hTbr2,TB_CHECKBUTTON,IDC_MOVE,TRUE
				invoke SetToolBar
				invoke CheckRadioButton,hWin,IDC_RBNSCHEMA,IDC_RBNPCBBOTTOM,IDC_RBNSCHEMA
				;Set FileName to NewFile
				invoke lstrcpy,offset FileName,offset NewFile
				invoke SetWinCaption,offset FileName
			.endif
		.elseif eax==IDM_FILE_OPEN
			invoke WantToSave,hCad,offset FileName
			.if !eax
				invoke OpenCad
			.endif
		.elseif eax==IDM_FILE_SAVE
			invoke SaveCad,hCad,offset FileName
		.elseif eax==IDM_FILE_SAVE_AS
			invoke SaveCadAs,hCad,offset FileName
		.elseif eax==IDM_FILE_PAGESETUP
			invoke GetUserDefaultLCID
			mov		edx,eax
			invoke GetLocaleInfo,edx,LOCALE_IMEASURE,addr buffer,sizeof buffer
			mov		al,buffer
			.if al=='1'
				mov		eax,1
			.else
				mov		eax,0
			.endif
			push	eax
			mov		psd.lStructSize,sizeof psd
			mov		eax,hWin
			mov		psd.hwndOwner,eax
			mov		eax,hInstance
			mov		psd.hInstance,eax
			pop		eax
			.if eax
				mov		eax,PSD_MARGINS or PSD_INTHOUSANDTHSOFINCHES
			.else
				mov		eax,PSD_MARGINS or PSD_INHUNDREDTHSOFMILLIMETERS
			.endif
			mov		psd.Flags,eax
			invoke PageSetupDlg,addr psd
			.if eax
				mov		eax,psd.rtMargin.left
				mov		ppos.margins.left,eax
				mov		eax,psd.rtMargin.top
				mov		ppos.margins.top,eax
				mov		eax,psd.rtMargin.right
				mov		ppos.margins.right,eax
				mov		eax,psd.rtMargin.bottom
				mov		ppos.margins.bottom,eax
				mov		eax,psd.ptPaperSize.x
				mov		ppos.pagesize.x,eax
				mov		eax,psd.ptPaperSize.y
				mov		ppos.pagesize.y,eax
				invoke RegSetValueEx,hReg,addr szPrnPos,0,REG_BINARY,addr ppos,sizeof ppos
			.endif
		.elseif eax==IDM_FILE_PRINT
			mov		pd.lStructSize, sizeof pd
			mov		eax,hWin
			mov		pd.hwndOwner,eax
			mov		eax,hInstance
			mov		pd.hInstance,eax
			mov		pd.Flags,PD_RETURNDC or PD_NOSELECTION or PD_ALLPAGES or PD_NOPAGENUMS
			invoke PrintDlg,addr pd
			.if eax
				invoke SendMessage,hCad,CM_PRINT,addr pd,addr psd
			.endif
		.elseif eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDM_EDIT_UNDO
			invoke SendMessage,hCad,CM_UNDO,0,0
		.elseif eax==IDM_EDIT_REDO
			invoke SendMessage,hCad,CM_REDO,0,0
		.elseif eax==IDM_EDIT_DELETE
			invoke SendMessage,hCad,CM_DELETE,0,0
		.elseif eax==IDM_EDIT_CUT
			invoke SendMessage,hCad,CM_CUT,0,0
		.elseif eax==IDM_EDIT_COPY
			invoke SendMessage,hCad,CM_COPY,0,0
			invoke SetToolBar
		.elseif eax==IDM_EDIT_PASTE
			invoke SendMessage,hCad,CM_PASTE,0,0
		.elseif eax==IDM_EDIT_SELECTALL
			invoke SendMessage,hCad,CM_SELECTALL,TRUE,0
		.elseif eax==IDM_EDIT_COLOR
			invoke SendMessage,hCad,CM_GETCOLOR,0,0
			invoke SendMessage,hCad,CM_SELSETCOLOR,eax,0
		.elseif eax==IDM_EDIT_WIDTH
			invoke SendMessage,hCad,CM_GETWIDTH,0,0
			invoke SendMessage,hCad,CM_SELSETWIDTH,eax,0
		.elseif eax==IDM_EDIT_SNAP
			invoke SendMessage,hCad,CM_GETSNAP,0,0
			and		eax,1
			xor		eax,1
			invoke SendMessage,hCad,CM_SETSNAP,eax,0
		.elseif eax==IDM_EDIT_ADDSYM
			.if hSymSel
				invoke AddSymbol,curx,cury
			.endif
		.elseif eax==IDM_VIEW_STATUSBAR
			xor		wpos.fView,1
			call	SizeIt
		.elseif eax==IDM_VIEW_GRID
			invoke SendMessage,hCad,CM_GETGRID,0,0
			and		eax,1
			xor		eax,1
			invoke SendMessage,hCad,CM_SETGRID,eax,0
		.elseif eax==IDM_VIEW_ZOOM_IN
			invoke SendMessage,hCad,CM_ZOOMIN,0,0
		.elseif eax==IDM_VIEW_ZOOM_OUT
			invoke SendMessage,hCad,CM_ZOOMOUT,0,0
		.elseif eax==IDM_VIEW_ZOOM_BEST_FIT
			invoke SendMessage,hCad,CM_ZOOMFIT,0,0
		.elseif eax==IDM_VIEW_HOME
			mov		pt.x,0
			mov		pt.y,0
			invoke SendMessage,hCad,CM_SETTOP,0,addr rect
		.elseif eax==IDM_HELP_ABOUT
			invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
		.elseif eax>=20000 && eax<20100
			sub		eax,20000
			mov		nObj,eax
			invoke SendMessage,hCad,CM_SETOBJECT,eax,0
			call	SizeIt
		.elseif eax==IDC_FLIP
			invoke SendMessage,hCad,CM_FLIPOBJECT,0,0
		.elseif eax==IDC_ROTATE
			invoke SendMessage,hCad,CM_ROTATEOBJECT,0,0
		.elseif eax>=IDC_RBNSCHEMA && eax<=IDC_RBNPCBBOTTOM
			sub		eax,IDC_RBNSCHEMA
			mov		layer,eax
			invoke SendMessage,hCad,CM_SETLAYER,eax,0
		.elseif edx==CBN_SELCHANGE && eax==IDC_CBO1
			invoke SendMessage,hCbo,CB_GETCURSEL,0,0
			inc		eax
			invoke SendMessage,hCad,CM_SETWIDTH,eax,0
		.elseif edx==EN_CHANGE && eax==IDC_EDT1
			invoke GetWindowText,hEdt,addr buffer,sizeof buffer
			invoke SendMessage,hCad,CM_SETTEXT,0,addr buffer
		.elseif eax==IDC_STC1
			mov		cc.lStructSize,sizeof CHOOSECOLOR
			mov		eax,hWin
			mov		cc.hwndOwner,eax
			mov		eax,hInstance
			mov		cc.hInstance,eax
			mov		cc.lpCustColors,offset CustColors
			mov		cc.Flags,CC_FULLOPEN or CC_RGBINIT
			mov		cc.lCustData,0
			mov		cc.lpfnHook,0
			mov		cc.lpTemplateName,0
			invoke SendMessage,hCad,CM_GETCOLOR,0,0
			mov		cc.rgbResult,eax
			invoke ChooseColor,addr cc
			.if eax
				invoke SendMessage,hCad,CM_SETCOLOR,cc.rgbResult,0
				invoke InvalidateRect,hStc,NULL,TRUE
			.endif
		.endif
	.elseif eax==WM_SIZE
		call	SizeIt
	.elseif eax==WM_NOTIFY
		mov		ebx,lParam
		mov		eax,[ebx].NMHDR.hwndFrom
		.if eax==hCad
			.if [ebx].CADNOTIFY.nmhdr.code==CN_SELRCLICK
				mov		eax,[ebx].CADNOTIFY.rpobj
				mov		rpobj,eax
			.else
				mov		edx,[ebx].CADNOTIFY.cur.x
				mov		curx,edx
				invoke DwToAscii,edx,addr buffer
				invoke lstrlen,addr buffer
				mov		word ptr buffer[eax],','
				mov		edx,[ebx].CADNOTIFY.cur.y
				mov		cury,edx
				invoke DwToAscii,edx,addr buffer[eax+1]
				.if [ebx].CADNOTIFY.nmhdr.code==CN_SIZE
					invoke lstrlen,addr buffer
					mov		word ptr buffer[eax],'-'
					mov		edx,[ebx].CADNOTIFY.len
					push	eax
					invoke DwToAscii,edx,addr buffer[eax+1]
					pop		eax
					.if [ebx].CADNOTIFY.tpe==TPE_DIMENSION
						invoke SetWindowText,hEdt,addr buffer[eax+1]
					.endif
				.endif
				invoke SendMessage,hSbr,SB_SETTEXT,0,addr buffer
				mov		edx,[ebx].CADNOTIFY.zoom
				shr		edx,1
				invoke DwToAscii,edx,addr buffer
				invoke lstrlen,addr buffer
				mov		edx,dword ptr buffer[eax-2]
				mov		byte ptr buffer[eax-2],'.'
				mov		dword ptr buffer[eax-1],edx
				invoke SendMessage,hSbr,SB_SETTEXT,1,addr buffer
				invoke SetToolBar
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke WantToSave,hCad,offset FileName
		.if !eax
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
			invoke DestroyWindow,hCad
			invoke DestroyWindow,hWin
			.if hBr
				invoke DeleteObject,hBr
			.endif
			invoke PostQuitMessage,NULL
		.endif
	.elseif eax==WM_CTLCOLORSTATIC
		mov		eax,lParam
		.if eax==hStc
			.if hBr
				invoke DeleteObject,hBr
			.endif
			invoke SendMessage,hCad,CM_GETCOLOR,0,0
			invoke CreateSolidBrush,eax
			mov		hBr,eax
			ret
		.endif
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

EnableDisableEdit:
	invoke SendMessage,hCad,CM_CANUNDO,0,0
	mov		edx,IDM_EDIT_UNDO
	call	EnableDisable
	invoke SendMessage,hCad,CM_CANREDO,0,0
	mov		edx,IDM_EDIT_REDO
	call	EnableDisable
	invoke SendMessage,hCad,CM_GETSELCOUNT,0,0
	mov		edx,IDM_EDIT_CUT
	call	EnableDisable
	mov		edx,IDM_EDIT_COPY
	call	EnableDisable
	mov		edx,IDM_EDIT_DELETE
	call	EnableDisable
	mov		edx,IDM_EDIT_COLOR
	call	EnableDisable
	mov		edx,IDM_EDIT_WIDTH
	call	EnableDisable
	invoke SendMessage,hCad,CM_CANPASTE,0,0
	mov		edx,IDM_EDIT_PASTE
	call	EnableDisable
	invoke SendMessage,hCad,CM_GETSNAP,0,0
	.if eax
		mov		eax,MF_BYCOMMAND or MF_CHECKED
	.else
		mov		eax,MF_BYCOMMAND or MF_UNCHECKED
	.endif
	invoke CheckMenuItem,wParam,IDM_EDIT_SNAP,eax
	mov		eax,hSymSel
	mov		edx,IDM_EDIT_ADDSYM
	call	EnableDisable
	retn

EnableDisable:
	push	eax
	.if		eax
		mov		eax,MF_BYCOMMAND or MF_ENABLED
	.else
		mov		eax,MF_BYCOMMAND or MF_GRAYED
	.endif
	invoke EnableMenuItem,wParam,edx,eax
	pop		eax
	retn

SizeIt:
	invoke UpdateWindow,hTbr1
	invoke UpdateWindow,hTbr2
	invoke GetClientRect,hWin,addr rect
	mov		rect.bottom,25
	invoke MoveWindow,hShp1,0,0,rect.right,2,TRUE
	invoke GetClientRect,hTbr1,addr rect
	mov		edx,rect.right
	add		edx,3
	invoke MoveWindow,hCbo,edx,3,65,250,TRUE
	mov		edx,rect.right
	add		edx,3+65+3
	invoke MoveWindow,hStc,edx,3,21,21,TRUE
	push	rect.right
	invoke GetClientRect,hWin,addr rect
	pop		edx
	add		edx,3+65+3+21+3
	mov		ecx,rect.right
	sub		ecx,edx
	invoke MoveWindow,hEdt,edx,3,ecx,21,TRUE
	.if nObj==TPE_HTEXT || nObj==TPE_VTEXT || nObj==TPE_DIMENSION
		invoke GetDlgItem,hWin,IDC_RBNSCHEMA
		invoke ShowWindow,eax,SW_HIDE
		invoke GetDlgItem,hWin,IDC_RBNCOMP
		invoke ShowWindow,eax,SW_HIDE
		invoke GetDlgItem,hWin,IDC_RBNPCBTOP
		invoke ShowWindow,eax,SW_HIDE
		invoke GetDlgItem,hWin,IDC_RBNPCBBOTTOM
		invoke ShowWindow,eax,SW_HIDE
		invoke ShowWindow,hEdt,SW_SHOW
	.else
		invoke GetDlgItem,hWin,IDC_RBNSCHEMA
		invoke ShowWindow,eax,SW_SHOW
		invoke GetDlgItem,hWin,IDC_RBNCOMP
		invoke ShowWindow,eax,SW_SHOW
		invoke GetDlgItem,hWin,IDC_RBNPCBTOP
		invoke ShowWindow,eax,SW_SHOW
		invoke GetDlgItem,hWin,IDC_RBNPCBBOTTOM
		invoke ShowWindow,eax,SW_SHOW
		invoke ShowWindow,hEdt,SW_HIDE
	.endif
	mov		eax,wpos.fView
	and		eax,1
	.if eax
		;Resize statusbar
		invoke ShowWindow,hSbr,SW_SHOW
		invoke MoveWindow,hSbr,0,0,0,0,TRUE
		invoke UpdateWindow,hSbr
		;Get height of statusbar
		invoke GetWindowRect,hSbr,addr rect
		mov		eax,rect.bottom
		sub		eax,rect.top
	.else
		invoke ShowWindow,hSbr,SW_HIDE
		xor		eax,eax
	.endif
	push	eax
	;Get size of windows client area
	invoke GetClientRect,hWin,addr rect
	;Subtract height of statusbar from bottom
	pop		eax
	sub		rect.bottom,eax
	;Add height of toolbar to top
	add		rect.top,25
	;Get new height of RichEdit window
	mov		eax,rect.bottom
	sub		eax,rect.top
	mov		ht,eax
	mov		eax,25+36
	sub		rect.right,eax
	;Resize Cad window
	invoke MoveWindow,hCad,eax,rect.top,rect.right,ht,TRUE
	;Resize Sym window
	invoke MoveWindow,hSymDlg,25,rect.top,36,ht,TRUE
	retn

WndProc endp

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,IDM_MAIN
	mov		wc.lpszClassName,offset DlgClass
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_MAIN,NULL,addr WndProc,NULL
	invoke LoadAccelerators,hInstance,IDR_ACCEL
	mov		hAccel,eax
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke TranslateAccelerator,hWnd,hAccel,addr msg
		.if !eax
			invoke TranslateMessage,addr msg
			invoke DispatchMessage,addr msg
		.endif
	.endw
	invoke DestroyAcceleratorTable,hAccel
	mov		eax,msg.wParam
	ret

WinMain endp

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke GetModuleFileName,hInstance,addr AppPath,sizeof AppPath
	.while AppPath[eax]!='\'
		dec		eax
	.endw
	mov		AppPath[eax],0
	invoke GetCommandLine
	mov		CommandLine,eax
	;Get command line filename
	invoke PathGetArgs,CommandLine
	mov		CommandLine,eax
  @@:
	mov		dl,[eax]
	.IF dl==VK_SPACE
		inc		eax
		jmp		@b
	.ELSEIF dl=='"'
		invoke PathUnquoteSpaces,eax
	.ENDIF
	invoke InitCommonControls
	invoke LoadLibrary,addr RACad
	.if eax
		mov		hRACad,eax
		invoke RegCreateKeyEx,HKEY_CURRENT_USER,addr szSimCad,0,addr szREG_SZ,0,KEY_WRITE or KEY_READ,0,addr hReg,addr lpdwDisp
		.if lpdwDisp==REG_OPENED_EXISTING_KEY
			mov		lpcbData,sizeof wpos
			invoke RegQueryValueEx,hReg,addr szWinPos,0,addr lpType,addr wpos,addr lpcbData
			mov		lpcbData,sizeof ppos
			invoke RegQueryValueEx,hReg,addr szPrnPos,0,addr lpType,addr ppos,addr lpcbData
			mov		eax,ppos.margins.left
			mov		psd.rtMargin.left,eax
			mov		eax,ppos.margins.top
			mov		psd.rtMargin.top,eax
			mov		eax,ppos.margins.right
			mov		psd.rtMargin.right,eax
			mov		eax,ppos.margins.bottom
			mov		psd.rtMargin.bottom,eax
			mov		eax,ppos.pagesize.x
			mov		psd.ptPaperSize.x,eax
			mov		eax,ppos.pagesize.y
			mov		psd.ptPaperSize.y,eax
		.endif
		invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
		invoke FreeLibrary,hRACad
		invoke RegSetValueEx,hReg,addr szWinPos,0,REG_BINARY,addr wpos,sizeof wpos
		invoke RegCloseKey,hReg
		xor		eax,eax
	.else
		mov		eax,1
	.endif
	invoke ExitProcess,eax

end start
