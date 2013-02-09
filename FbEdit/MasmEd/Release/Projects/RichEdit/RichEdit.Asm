.386
.model flat,stdcall
option casemap:none

include RichEdit.Inc

.code

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

SetWinCaption proc
	LOCAL	buffer[sizeof AppName+3+MAX_PATH]:BYTE
	LOCAL	buffer1[4]:BYTE

	;Add filename to windows caption
	invoke lstrcpy,addr buffer,addr AppName
	mov		eax,' - '
	mov		dword ptr buffer1,eax
	invoke lstrcat,addr buffer,addr buffer1
	invoke lstrcat,addr buffer,addr FileName
	invoke SetWindowText,hWnd,addr buffer
	ret

SetWinCaption endp

SaveFile proc lpFileName:DWORD
	LOCAL	hFile:DWORD
	LOCAL	editstream:EDITSTREAM

	invoke CreateFile,lpFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		;stream the text to the file
		mov		editstream.dwCookie,eax
		mov		editstream.pfnCallback,offset StreamOutProc
		invoke SendMessage,hREd,EM_STREAMOUT,SF_TEXT,addr editstream
		invoke CloseHandle,hFile
		;Set the modify state to false
		invoke SendMessage,hREd,EM_SETMODIFY,FALSE,0
   		mov		eax,FALSE
	.else
		invoke MessageBox,hWnd,addr SaveFileFail,addr AppName,MB_OK
		mov		eax,TRUE
	.endif
	ret

SaveFile endp

SaveEditAs proc
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
	mov		buffer[0],0
	lea		eax,buffer
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,sizeof buffer
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
    mov		ofn.lpstrDefExt,NULL
    ;Show save as dialog
	invoke GetSaveFileName,addr ofn
	.if eax
		invoke SaveFile,addr buffer
		.if !eax
			;The file was saved
			invoke lstrcpy,addr FileName,addr buffer
			invoke SetWinCaption
			mov		eax,FALSE
		.endif
	.else
		mov		eax,TRUE
	.endif
	ret

SaveEditAs endp

SaveEdit proc

	;Check if filrname is (Untitled)
	invoke lstrcmp,addr FileName,addr NewFile
	.if eax
		invoke SaveFile,addr FileName
	.else
		invoke SaveEditAs
	.endif
	ret

SaveEdit endp

WantToSave proc
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[2]:BYTE

	invoke SendMessage,hREd,EM_GETMODIFY,0,0
	.if eax
		invoke lstrcpy,addr buffer,addr WannaSave
		invoke lstrcat,addr buffer,addr FileName
		mov		ax,'?'
		mov		word ptr buffer1,ax
		invoke lstrcat,addr buffer,addr buffer1
		invoke MessageBox,hWnd,addr buffer,addr AppName,MB_YESNOCANCEL or MB_ICONQUESTION
		.if eax==IDYES
			invoke SaveEdit
	    .elseif eax==IDNO
		    mov		eax,FALSE
	    .else
		    mov		eax,TRUE
		.endif
	.endif
	ret

WantToSave endp

OpenEdit proc
	LOCAL	ofn:OPENFILENAME
    LOCAL   hFile:DWORD
	LOCAL	editstream:EDITSTREAM
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	chrg:CHARRANGE

	;Zero out the ofn struct
	invoke RtlZeroMemory,addr ofn,sizeof ofn
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	push	hWnd
	pop		ofn.hwndOwner
	push	hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,NULL
	mov		buffer[0],0
	lea		eax,buffer
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,sizeof buffer
	mov		ofn.lpstrDefExt,NULL
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	;Show the Open dialog
	invoke GetOpenFileName,addr ofn
	.if eax
		;Open the file
		invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			;Copy buffer to FileName
			invoke lstrcpy,addr FileName,addr buffer
			;stream the text into the richedit control
			push	hFile
			pop		editstream.dwCookie
			mov		editstream.pfnCallback,offset StreamInProc
			invoke SendMessage,hREd,EM_STREAMIN,SF_TEXT,addr editstream
			invoke CloseHandle,hFile
			invoke SendMessage,hREd,EM_SETMODIFY,FALSE,0
			mov		chrg.cpMin,0
			mov		chrg.cpMax,0
			invoke SendMessage,hREd,EM_EXSETSEL,0,addr chrg
			invoke SetWinCaption
			mov		eax,FALSE
		.else
			invoke MessageBox,hWnd,addr OpenFileFail,addr AppName,MB_OK
			mov		eax,TRUE
		.endif
	.endif
	ret

OpenEdit endp

Find proc hWin:HWND,frl:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	ft:FINDTEXTEX

	invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
	test	frl,FR_DOWN
	.if ZERO?
		mov		eax,chrg.cpMin
		mov		ft.chrg.cpMin,eax
		mov		ft.chrg.cpMax,-1
	.else
		mov		eax,chrg.cpMax
		mov		ft.chrg.cpMin,eax
		mov		ft.chrg.cpMax,-1
	.endif
	mov		eax,offset FindBuff
	mov		ft.lpstrText,eax
	invoke SendMessage,hREd,EM_FINDTEXTEX,frl,addr ft
	mov		fres,eax
	.if eax!=-1
		invoke SendMessage,hREd,EM_EXSETSEL,0,addr ft.chrgText
	.else
		.if ReplaceCount
		.else
			invoke MessageBox,hWin,offset NoMatches,offset AppName,MB_OK or MB_ICONINFORMATION
		.endif
	.endif
	ret

Find endp

FindDlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hCtl:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	buffer[256]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hFind,eax
		.if !lParam
			;Disable replace
			invoke GetDlgItem,hWin,IDC_REPLACETEXT
			invoke ShowWindow,eax,SW_HIDE
			invoke GetDlgItem,hWin,IDC_REPLACESTATIC
			invoke ShowWindow,eax,SW_HIDE
			invoke GetDlgItem,hWin,IDC_BTN_REPLACEALL
			invoke EnableWindow,eax,FALSE
		.else
			invoke SetWindowText,hWin,addr Replace
			invoke GetDlgItem,hWin,IDC_BTN_REPLACEALL
			invoke EnableWindow,eax,TRUE
		.endif
		mov		FindInit,TRUE
		invoke SetDlgItemText,hWin,IDC_FINDTEXT,offset FindBuff
		invoke SetDlgItemText,hWin,IDC_REPLACETEXT,offset ReplaceBuff
		mov		FindInit,FALSE
		test	fr,FR_DOWN
		.if ZERO?
			invoke CheckDlgButton,hWin,IDC_RBN_UP,BST_CHECKED
		.else
			invoke CheckDlgButton,hWin,IDC_RBN_DOWN,BST_CHECKED
		.endif
		test	fr,FR_MATCHCASE
		.if !ZERO?
			invoke CheckDlgButton,hWin,IDC_CHK_MATCHCASE,BST_CHECKED
		.endif
		test	fr,FR_WHOLEWORD
		.if !ZERO?
			invoke CheckDlgButton,hWin,IDC_CHK_WHOLEWORD,BST_CHECKED
		.endif
		mov		fres,-1
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke Find,hWin,fr
			.elseif eax==IDC_BTN_REPLACE
				invoke GetDlgItem,hWin,IDC_REPLACETEXT
				invoke IsWindowVisible,eax
				.if eax
					.if fres!=-1
						mov		eax,fres
						mov		chrg.cpMin,eax
						invoke SendMessage,hREd,EM_REPLACESEL,TRUE,addr ReplaceBuff
						invoke lstrlen,addr ReplaceBuff
						add		eax,chrg.cpMin
						mov		chrg.cpMax,eax
						invoke SendMessage,hREd,EM_EXSETSEL,0,addr chrg
						inc		ReplaceCount
					.endif
					invoke Find,hWin,fr
				.else
					;Enable replace
					invoke GetDlgItem,hWin,IDC_REPLACETEXT
					invoke ShowWindow,eax,SW_SHOWNA
					invoke GetDlgItem,hWin,IDC_REPLACESTATIC
					invoke ShowWindow,eax,SW_SHOWNA
					invoke GetDlgItem,hWin,IDC_BTN_REPLACEALL
					invoke EnableWindow,eax,TRUE
					invoke SetWindowText,hWin,addr Replace
				.endif
			.elseif eax==IDC_BTN_REPLACEALL
				mov		ReplaceCount,0
				.if fres==-1
					invoke Find,hWin,fr
				.endif
				.while fres!=-1
					invoke SendMessage,hWin,WM_COMMAND,(BN_CLICKED shl 16) or IDC_BTN_REPLACE,0
				.endw
				invoke wsprintf,addr buffer,addr ReplaceAllRes,ReplaceCount
				invoke MessageBox,hWin,addr buffer,offset AppName,MB_OK or MB_ICONINFORMATION
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_CHK_MATCHCASE
				xor		fr,FR_MATCHCASE
				mov		fres,-1
			.elseif eax==IDC_CHK_WHOLEWORD
				xor		fr,FR_WHOLEWORD
				mov		fres,-1
			.elseif eax==IDC_RBN_UP
				and		fr,-1 xor FR_DOWN
				mov		fres,-1
			.elseif eax==IDC_RBN_DOWN
				or		fr,FR_DOWN
				mov		fres,-1
			.endif
		.elseif edx==EN_CHANGE
			.if !FindInit
				invoke GetDlgItemText,hWin,IDC_FINDTEXT,offset FindBuff,sizeof FindBuff
				invoke GetDlgItemText,hWin,IDC_REPLACETEXT,offset ReplaceBuff,sizeof ReplaceBuff
			.endif
			mov		fres,-1
		.endif
	.elseif eax==WM_ACTIVATE
		mov		fres,-1
	.elseif eax==WM_CLOSE
		invoke SetFocus,hREd
		mov		hFind,0
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

FindDlgProc endp

DoToolBar proc hInst:DWORD,hToolBar:HWND
	LOCAL	tbab:TBADDBITMAP

	;Set toolbar struct size
	invoke SendMessage,hToolBar,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	;Set toolbar bitmap
	push	hInst
	pop		tbab.hInst
	mov		tbab.nID,IDB_TBRBMP
	invoke SendMessage,hToolBar,TB_ADDBITMAP,15,addr tbab
	;Set toolbar buttons
	invoke SendMessage,hToolBar,TB_ADDBUTTONS,ntbrbtns,addr tbrbtns
	mov		eax,hToolBar
	ret

DoToolBar endp

SetFormat proc hWin:DWORD
    LOCAL	chrg1:CHARRANGE
    LOCAL	chrg2:CHARRANGE
	LOCAL	pf:PARAFORMAT2
	LOCAL	cf:CHARFORMAT
	LOCAL	tp:DWORD
	LOCAL	buffer[16]:BYTE
	LOCAL	pt:POINT
	LOCAL	hDC:HDC

	;Save modify state
	invoke SendMessage,hWin,EM_GETMODIFY,0,0
	push	eax
	;Save selection
	invoke SendMessage,hWin,EM_EXGETSEL,0,addr chrg1
	invoke SendMessage,hWin,EM_HIDESELECTION,TRUE,0
	;Select all text
	mov		chrg2.cpMin,0
	mov		chrg2.cpMax,-1
	invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg2
	;Set font charset
	mov		cf.cbSize,sizeof cf
	mov		cf.dwMask,CFM_CHARSET or CFM_FACE or CFM_SIZE or CFM_COLOR
	mov		al,lfnt.lfCharSet
	mov		cf.bCharSet,al
	mov		al,lfnt.lfPitchAndFamily
	mov		cf.bPitchAndFamily,al
	invoke lstrcpyn,addr cf.szFaceName,addr lfnt.lfFaceName,LF_FACESIZE
	mov		eax,lfnt.lfHeight
	neg		eax
	mov		ecx,15
	mul		ecx
	mov		cf.yHeight,eax
	mov		eax,rgb
	mov		cf.crTextColor,eax
	invoke SendMessage,hWin,EM_SETCHARFORMAT,SCF_SELECTION,addr cf
	;Get tab width
	invoke GetDC,hWin
	mov		hDC,eax
	invoke SelectObject,hDC,hFont
	push	eax
	mov		eax,'WWWW'
	mov		dword ptr buffer,eax
	invoke GetTextExtentPoint32,hDC,addr buffer,4,addr pt
	pop		eax
	invoke SelectObject,hDC,eax
	invoke ReleaseDC,hWin,hDC
	mov		eax,pt.x
	mov		ecx,TabSize
	mul		ecx
	mov		ecx,15
	mul		ecx
	shr		eax,2
	mov		tp,eax
	;Set tab stops
	mov		pf.cbSize,sizeof pf
	mov		pf.dwMask,PFM_TABSTOPS
	mov		pf.cTabCount,MAX_TAB_STOPS
	xor		eax,eax
	xor		edx,edx
	mov		ecx,MAX_TAB_STOPS
  @@:
	add		eax,tp
	mov		dword ptr pf.rgxTabs[edx],eax
	add		edx,4
	loop	@b
	invoke SendMessage,hWin,EM_SETPARAFORMAT,0,addr pf
	;Restore modify state
	pop		eax
	invoke SendMessage,hWin,EM_SETMODIFY,eax,0
	;Restore selection
	invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg1
	invoke SendMessage,hWin,EM_HIDESELECTION,FALSE,0
	ret

SetFormat endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	ht:DWORD
	LOCAL	hCtl:HWND
	LOCAL	chrg:CHARRANGE
	LOCAL	cf:CHOOSEFONT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
		mov		fr,FR_DOWN
		mov		fView,3
		mov		TabSize,4
		;Set the toolbar buttons
		invoke GetDlgItem,hWin,IDC_TBR
		invoke DoToolBar,hInstance,eax
		;Set FileName to NewFile
		invoke lstrcpy,addr FileName,addr NewFile
		invoke SetWinCaption
		;Get handle of RichEdit window and give it focus
		invoke GetDlgItem,hWin,IDC_RED
		mov		hREd,eax
		invoke SendMessage,hREd,EM_SETTEXTMODE,0,TM_PLAINTEXT
		;Set event mask
		invoke SendMessage,hREd,EM_SETEVENTMASK,0,ENM_SELCHANGE
		;Set the text limit. The default is 64K
		invoke SendMessage,hREd,EM_LIMITTEXT,-1,0
		;Create font
		invoke lstrcpy,addr lfnt.lfFaceName,offset szFont
		mov		lfnt.lfHeight,-12
		mov		lfnt.lfWeight,400
		invoke CreateFontIndirect,addr lfnt
		mov     hFont,eax
		;Set font & format
		invoke SetFormat,hREd
		;Init RichEdit
		invoke SendMessage,hREd,EM_SETMODIFY,FALSE,0
		invoke SendMessage,hREd,EM_EMPTYUNDOBUFFER,0,0
		invoke SetFocus,hREd
	.elseif eax==WM_COMMAND
		;Menu and toolbar has the same ID's
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==IDM_FILE_NEW
			invoke WantToSave
			.if !eax
				invoke SetWindowText,hREd,addr szNULL
				invoke lstrcpy,addr FileName,addr NewFile
				invoke SetWinCaption
			.endif
			invoke SetFocus,hREd
		.elseif eax==IDM_FILE_OPEN
			invoke WantToSave
			.if !eax
				invoke OpenEdit
			.endif
			invoke SetFocus,hREd
		.elseif eax==IDM_FILE_SAVE
			invoke SaveEdit
			invoke SetFocus,hREd
		.elseif eax==IDM_FILE_SAVEAS
			invoke SaveEditAs
			invoke SetFocus,hREd
		.elseif eax==IDM_FILE_PRINT
		.elseif eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDM_EDIT_UNDO
			invoke SendMessage,hREd,EM_UNDO,0,0
		.elseif eax==IDM_EDIT_REDO
			invoke SendMessage,hREd,EM_REDO,0,0
		.elseif eax==IDM_EDIT_DELETE
			invoke SendMessage,hREd,EM_REPLACESEL,TRUE,0
		.elseif eax==IDM_EDIT_CUT
			invoke SendMessage,hREd,WM_CUT,0,0
		.elseif eax==IDM_EDIT_COPY
			invoke SendMessage,hREd,WM_COPY,0,0
		.elseif eax==IDM_EDIT_PASTE
			invoke SendMessage,hREd,WM_PASTE,0,0
		.elseif eax==IDM_EDIT_SELECTALL
			mov		chrg.cpMin,0
			mov		chrg.cpMax,-1
			invoke SendMessage,hREd,EM_EXSETSEL,0,addr chrg
		.elseif eax==IDM_EDIT_FIND
			.if hFind==0
				invoke CreateDialogParam,hInstance,IDD_FINDDLG,hWin,addr FindDlgProc,FALSE
			.else
				invoke SetFocus,hFind
			.endif
		.elseif eax==IDM_EDIT_FINDNEXT
			mov		eax,fr
			or		eax,FR_DOWN
			invoke Find,hWin,eax
		.elseif eax==IDM_EDIT_FINDPREV
			mov		eax,fr
			and		eax,-1 xor FR_DOWN
			invoke Find,hWin,eax
		.elseif eax==IDM_EDIT_REPLACE
			.if hFind==0
				invoke CreateDialogParam,hInstance,IDD_FINDDLG,hWin,addr FindDlgProc,TRUE
			.else
				invoke SetFocus,hFind
			.endif
		.elseif eax==IDM_VIEW_TOOLBAR
			invoke GetDlgItem,hWin,IDC_TBR
			mov		hCtl,eax
			xor		fView,1
			mov		eax,fView
			and		eax,1
			.if eax
				invoke ShowWindow,hCtl,SW_SHOWNA
			.else
				invoke ShowWindow,hCtl,SW_HIDE
			.endif
			invoke SendMessage,hWin,WM_SIZE,0,0
		.elseif eax==IDM_VIEW_STATUSBAR
			invoke GetDlgItem,hWin,IDC_SBR
			mov		hCtl,eax
			xor		fView,2
			mov		eax,fView
			and		eax,2
			.if eax
				invoke ShowWindow,hCtl,SW_SHOWNA
			.else
				invoke ShowWindow,hCtl,SW_HIDE
			.endif
			invoke SendMessage,hWin,WM_SIZE,0,0
		.elseif eax==IDM_OPTION_FONT
			invoke RtlZeroMemory,addr cf,sizeof cf
			mov		cf.lStructSize,sizeof cf
			mov		eax,hWin
			mov		cf.hwndOwner,eax
			mov		cf.lpLogFont,offset lfnt
			mov		cf.Flags,CF_SCREENFONTS or CF_EFFECTS or CF_INITTOLOGFONTSTRUCT
			mov		eax,rgb
			mov		cf.rgbColors,eax
			invoke ChooseFont,addr cf
			.if eax
				invoke DeleteObject,hFont
				invoke CreateFontIndirect,addr lfnt
				mov     hFont,eax
				mov		eax,cf.rgbColors
				mov		rgb,eax
				invoke SetFormat,hREd
			.endif
			invoke SetFocus,hREd
		.elseif eax==IDM_HELP_ABOUT
			invoke ShellAbout,hWin,addr AppName,addr AboutMsg,hIcon
			invoke SetFocus,hREd
		.endif
	.elseif eax==WM_NOTIFY
		.if wParam==IDC_RED
			;Auto horizontal scroll text into view
			invoke GetCaretPos,addr pt
			invoke GetClientRect,hREd,addr rect
			mov		eax,rect.right
			sub		eax,pt.x
			.if eax<20
				;Caret near right edge
				invoke SendMessage,hREd,EM_GETSCROLLPOS,0,addr pt
				add		pt.x,70
				invoke SendMessage,hREd,EM_SETSCROLLPOS,0,addr pt
			.endif
		.endif
	.elseif eax==WM_SIZE
		mov		eax,fView
		and		eax,1
		.if eax
			;Resize toolbar
			invoke GetDlgItem,hWin,IDC_TBR
			mov		hCtl,eax
			invoke MoveWindow,hCtl,0,0,0,0,TRUE
			;Get height of toolbar
			invoke GetWindowRect,hCtl,addr rect
			mov		eax,rect.bottom
			sub		eax,rect.top
		.endif
		push	eax
		mov		eax,fView
		and		eax,2
		.if eax
			;Resize statusbar
			invoke GetDlgItem,hWin,IDC_SBR
			mov		hCtl,eax
			invoke MoveWindow,hCtl,0,0,0,0,TRUE
			;Get height of statusbar
			invoke GetWindowRect,hCtl,addr rect
			mov		eax,rect.bottom
			sub		eax,rect.top
		.endif
		push	eax
		;Get size of windows client area
		invoke GetClientRect,hWin,addr rect
		;Subtract height of statusbar from bottom
		pop		eax
		sub		rect.bottom,eax
		;Add height of toolbar to top
		pop		eax
		add		rect.top,eax
		;Get new height of RichEdit window
		mov		eax,rect.bottom
		sub		eax,rect.top
		mov		ht,eax
		;Resize RichEdit window
		invoke MoveWindow,hREd,0,rect.top,rect.right,ht,TRUE
	.elseif eax==WM_CLOSE 
		invoke WantToSave
		.if !eax
			invoke DestroyWindow,hWin
		.endif
	.elseif eax==WM_DESTROY
		invoke DeleteObject,hFont
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
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
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,IDM_MENU
	mov		wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		hIcon,eax
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke LoadAccelerators,hInstance,IDR_ACCEL
	mov		hAccel,eax
	invoke CreateDialogParam,hInstance,IDD_DLG,NULL,addr WndProc,NULL
	mov		hWnd,eax
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .break .if !eax
		invoke IsDialogMessage,hFind,addr msg
		.if !eax
			invoke TranslateAccelerator,hWnd,hAccel,addr msg
			.if !eax
				invoke TranslateMessage,addr msg
				invoke DispatchMessage,addr msg
			.endif
		.endif
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax
	invoke GetCommandLine
	mov		CommandLine,eax
	invoke InitCommonControls
	mov		iccex.dwSize,sizeof INITCOMMONCONTROLSEX    ;prepare common control structure
	mov		iccex.dwICC,ICC_DATE_CLASSES
	invoke InitCommonControlsEx,addr iccex
	invoke LoadLibrary,addr RichEditDLL
	mov		hRichEdDLL,eax
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	push	eax
	invoke FreeLibrary,hRichEdDLL
	pop		eax
	invoke ExitProcess,eax

end start
