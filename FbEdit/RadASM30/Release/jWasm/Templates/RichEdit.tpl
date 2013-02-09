Ricch edit editor
[*BEGINTXT*]
[*PROJECTNAME*].prra
[Version]
Version=3000
[Project]
Assembler=jwasm
Group=2,-1,0,1,[*PROJECTNAME*],-2,-1,1,Assembly,-3,-1,1,Include,-4,-1,1,Misc,-5,-1,1,Resource
F1=-2,2,1,22,22,600,400,0,[*PROJECTNAME*].asm
F2=-3,0,1,44,44,600,400,0,[*PROJECTNAME*].inc
F3=-5,2,4,66,66,600,400,0,[*PROJECTNAME*].rc
[Make]
Make=0
0=Window Release,'/v "$R"',"$R.res",'/c /coff /Cp "$C"',"$C.obj",'/SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 /OUT:$O $C $M $R',"$C.exe",'',
1=Window Debug,'/v "$R"',"$R.res",'/c /coff /Cp /Zi /Zd "$C"',"$C.obj",'/SUBSYSTEM:WINDOWS /DEBUG /VERSION:4.0 /OUT:$O $C $M $R',"$C.exe",'',
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].asm
.386
.model flat,stdcall
option casemap:none

include [*PROJECTNAME*].inc

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
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].inc

include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
include gdi32.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib gdi32.lib

IDR_ACCEL			equ 1

;Find.dlg
IDD_FINDDLG			equ 2000
IDC_FINDTEXT		equ 2001
IDC_BTN_REPLACE		equ 2007
IDC_REPLACETEXT		equ 2002
IDC_REPLACESTATIC	equ 2009
IDC_BTN_REPLACEALL	equ 2008
IDC_CHK_WHOLEWORD	equ 2004
IDC_CHK_MATCHCASE	equ 2003
IDC_RBN_DOWN		equ 2005
IDC_RBN_UP			equ 2006

;RichEditEditor.dlg
IDD_DLG				equ 1000
IDC_SBR				equ 1003
IDC_TBR				equ 1001
IDC_RED				equ 1002
IDB_TBRBMP			equ 1212
IDM_MENU			equ 10000

;RichEditEditor.mnu
IDM_FILE_NEW		equ 10001
IDM_FILE_OPEN		equ 10002
IDM_FILE_SAVE		equ 10003
IDM_FILE_SAVEAS		equ 10004
IDM_FILE_PRINT		equ 10005
IDM_FILE_EXIT		equ 10006
IDM_EDIT_UNDO		equ 10101
IDM_EDIT_REDO		equ 10102
IDM_EDIT_DELETE		equ 10103
IDM_EDIT_CUT		equ 10104
IDM_EDIT_COPY		equ 10105
IDM_EDIT_PASTE		equ 10106
IDM_EDIT_SELECTALL	equ 10107
IDM_EDIT_FIND		equ 10108
IDM_EDIT_FINDNEXT	equ 10110
IDM_EDIT_FINDPREV	equ 10111
IDM_EDIT_REPLACE	equ 10109
IDM_VIEW_TOOLBAR	equ 10008
IDM_VIEW_STATUSBAR	equ 10009
IDM_OPTION_FONT		equ 10007
IDM_HELP_ABOUT		equ 10201

.const

;structure for ToolBar buttons
tbrbtns				TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <6,IDM_FILE_NEW,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <7,IDM_FILE_OPEN,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <8,IDM_FILE_SAVE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <0,IDM_EDIT_CUT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <1,IDM_EDIT_COPY,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <2,IDM_EDIT_PASTE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <3,IDM_EDIT_UNDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <4,IDM_EDIT_REDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <5,IDM_EDIT_DELETE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <12,IDM_EDIT_FIND,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <13,IDM_EDIT_REPLACE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <14,IDM_FILE_PRINT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
;;Number of buttons in tbbtns
ntbrbtns			equ 18

.data

RichEditDLL			db 'riched20.dll',0
ClassName			db 'DLGCLASS',0
AppName				db 'RichEdit editor',0
AboutMsg			db 'RadASM RichEdit editor',13,10,'KetilO (C) 2002',0
Replace				db 'Replace ..',0
OpenFileFail        db 'Cannot open the file',0
SaveFileFail		db 'Cannot save the file',0
WannaSave           db 'Want to save changes to',0Dh,0
NoMatches			db 'No matches found.',0
ReplaceAllRes		db '%d Replacements done.',0

NewFile             db '(Untitled)',0
szNULL				db 0
szFont				db 'Courier New',0

.data?

hRichEdDLL			dd ?
hInstance			dd ?
CommandLine			dd ?
hIcon				dd ?
hWnd				HWND ?
hAccel				dd ?
hREd				HWND ?
hFind				HWND ?
FileName			db MAX_PATH dup(?)
;structure for DateTimePicker
iccex				INITCOMMONCONTROLSEX <?>

fView				dd ?
TabSize				dd ?
lfnt				LOGFONT <?>
hFont				dd ?
rgb					dd ?
;Find
FindBuff			db MAX_PATH dup(?)
ReplaceBuff			db MAX_PATH dup(?)
FindInit			dd ?
fr					dd ?
fres				dd ?
ReplaceCount		dd ?
fw					FWORD ?
nn					dd ?
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].rc
#define MANIFEST 24
#define TBSTYLE_FLAT 2048
#define IDM_MENU 10000
#define IDM_FILE_NEW 10001
#define IDM_FILE_OPEN 10002
#define IDM_FILE_SAVE 10003
#define IDM_FILE_SAVEAS 10004
#define IDM_FILE_PRINT 10005
#define IDM_FILE_EXIT 10006
#define IDM_EDIT_UNDO 10101
#define IDM_EDIT_REDO 10102
#define IDM_EDIT_DELETE 10103
#define IDM_EDIT_CUT 10104
#define IDM_EDIT_COPY 10105
#define IDM_EDIT_PASTE 10106
#define IDM_EDIT_SELECTALL 10107
#define IDM_EDIT_FIND 10108
#define IDM_EDIT_FINDNEXT 10110
#define IDM_EDIT_FINDPREV 10111
#define IDM_EDIT_REPLACE 10109
#define IDM_VIEW_TOOLBAR 10008
#define IDM_VIEW_STATUSBAR 10009
#define IDM_OPTION_FONT 10007
#define IDM_HELP_ABOUT 10201
#define IDB_TBRBMP 1212
#define VERINF1 1
#define IDD_FINDDLG 2000
#ifndef IDC_STATIC
  #define IDC_STATIC -1
#endif
#define IDC_FINDTEXT 2001
#define IDC_REPLACESTATIC 2009
#define IDC_REPLACETEXT 2002
#define IDC_CHK_MATCHCASE 2003
#define IDC_CHK_WHOLEWORD 2004
#define IDC_RBN_DOWN 2005
#define IDC_RBN_UP 2006
#ifndef IDOK
  #define IDOK 1
#endif
#define IDC_BTN_REPLACE 2007
#define IDC_BTN_REPLACEALL 2008
#ifndef IDCANCEL
  #define IDCANCEL 2
#endif
#define IDD_DLG 1000
#define IDC_SBR 1003
#define IDC_TBR 1001
#define IDC_RED 1002
#define IDR_ACCEL 1
#define IDR_XPMANIFEST1 1

#include <resource.h>

IDM_MENU MENU
BEGIN
  POPUP "&File"
  BEGIN
    MENUITEM "&New\tCtrl+N",IDM_FILE_NEW
    MENUITEM "&Open\tCtrl+O",IDM_FILE_OPEN
    MENUITEM "&Save\tCtrl+S",IDM_FILE_SAVE
    MENUITEM "Save &As ...",IDM_FILE_SAVEAS
    MENUITEM SEPARATOR
    MENUITEM "&Print",IDM_FILE_PRINT
    MENUITEM SEPARATOR
    MENUITEM "E&xit",IDM_FILE_EXIT
  END
  POPUP "&Edit"
  BEGIN
    MENUITEM "&Undo",IDM_EDIT_UNDO
    MENUITEM "R&edo",IDM_EDIT_REDO
    MENUITEM "&Delete",IDM_EDIT_DELETE
    MENUITEM SEPARATOR
    MENUITEM "&Cut",IDM_EDIT_CUT
    MENUITEM "C&opy",IDM_EDIT_COPY
    MENUITEM "&Paste",IDM_EDIT_PASTE
    MENUITEM "Select &All",IDM_EDIT_SELECTALL
    MENUITEM SEPARATOR
    MENUITEM "&Find...\tCtrl+F",IDM_EDIT_FIND
    MENUITEM "Find &Next\tF3",IDM_EDIT_FINDNEXT
    MENUITEM "Find &Previous\tCtrl+F3",IDM_EDIT_FINDPREV
    MENUITEM "&Replace...\tCtrl+R",IDM_EDIT_REPLACE
  END
  POPUP "&View"
  BEGIN
    MENUITEM "&Toolbar",IDM_VIEW_TOOLBAR
    MENUITEM "&Statusbar",IDM_VIEW_STATUSBAR
  END
  POPUP "&Option"
  BEGIN
    MENUITEM "&Font",IDM_OPTION_FONT
  END
  POPUP "&Help"
  BEGIN
    MENUITEM "&About",IDM_HELP_ABOUT
  END
END

IDB_TBRBMP BITMAP DISCARDABLE "Res/Toolbar.bmp"

VERINF1 VERSIONINFO
FILEVERSION 1,0,1,4
PRODUCTVERSION 1,0,1,4
FILEOS 0x00000004
FILETYPE 0x00000001
BEGIN
  BLOCK "StringFileInfo"
  BEGIN
    BLOCK "040904E4"
    BEGIN
      VALUE "FileVersion", "1.0.1.4\0"
      VALUE "FileDescription", "RadASM RichEdit Editor\0"
      VALUE "LegalCopyright", "KetilO (C) 2002\0"
      VALUE "OriginalFilename", "RichEditEditor.exe\0"
      VALUE "ProductVersion", "1.0.1.4\0"
    END
  END
  BLOCK "VarFileInfo"
  BEGIN
    VALUE "Translation", 0x0409, 0x04E4
  END
END

IDD_FINDDLG DIALOGEX 6,6,184,67
CAPTION "Find ..."
FONT 8,"MS Sans Serif",0,0,0
STYLE WS_VISIBLE|WS_CAPTION|WS_SYSMENU
EXSTYLE WS_EX_TOOLWINDOW
BEGIN
  CONTROL "Find what:",IDC_STATIC,"Static",WS_CHILDWINDOW|WS_VISIBLE|WS_GROUP|SS_NOTIFY,3,6,33,9
  CONTROL "",IDC_FINDTEXT,"Edit",WS_CHILDWINDOW|WS_VISIBLE|WS_TABSTOP|ES_AUTOHSCROLL,42,3,93,12,WS_EX_CLIENTEDGE
  CONTROL "Replace:",IDC_REPLACESTATIC,"Static",WS_CHILDWINDOW|WS_VISIBLE|WS_GROUP,3,21,31,9
  CONTROL "",IDC_REPLACETEXT,"Edit",WS_CHILDWINDOW|WS_VISIBLE|WS_TABSTOP|ES_AUTOHSCROLL,42,18,93,12,WS_EX_CLIENTEDGE
  CONTROL "Match Case",IDC_CHK_MATCHCASE,"Button",WS_CHILDWINDOW|WS_VISIBLE|WS_TABSTOP|BS_AUTOCHECKBOX,3,36,60,9
  CONTROL "Whole Word",IDC_CHK_WHOLEWORD,"Button",WS_CHILDWINDOW|WS_VISIBLE|WS_TABSTOP|BS_AUTOCHECKBOX,3,51,60,9
  CONTROL "Direction",-1,"Button",WS_CHILDWINDOW|WS_VISIBLE|BS_GROUPBOX,72,30,63,30
  CONTROL "Down",IDC_RBN_DOWN,"Button",WS_CHILDWINDOW|WS_VISIBLE|WS_TABSTOP|BS_AUTORADIOBUTTON,75,39,51,6
  CONTROL "Up",IDC_RBN_UP,"Button",WS_CHILDWINDOW|WS_VISIBLE|WS_TABSTOP|BS_AUTORADIOBUTTON,75,48,51,6
  CONTROL "Find",IDOK,"Button",WS_CHILDWINDOW|WS_VISIBLE|WS_TABSTOP,141,3,39,12
  CONTROL "Replace",IDC_BTN_REPLACE,"Button",WS_CHILDWINDOW|WS_VISIBLE|WS_TABSTOP,141,18,39,12
  CONTROL "Replace All",IDC_BTN_REPLACEALL,"Button",WS_CHILDWINDOW|WS_VISIBLE|WS_DISABLED|WS_TABSTOP,141,33,39,12
  CONTROL "Cancel",IDCANCEL,"Button",WS_CHILDWINDOW|WS_VISIBLE|WS_TABSTOP,141,48,39,12
END

IDD_DLG DIALOGEX 6,6,307,223
CAPTION "RichEdit editor"
FONT 8,"MS Sans Serif",0,0,0
CLASS "DLGCLASS"
STYLE WS_VISIBLE|WS_CLIPSIBLINGS|WS_CLIPCHILDREN|WS_OVERLAPPEDWINDOW|DS_CENTER
BEGIN
  CONTROL "StatusBar",IDC_SBR,"msctls_statusbar32",WS_CHILDWINDOW|WS_VISIBLE,0,210,307,12
  CONTROL "Test",IDC_TBR,"ToolbarWindow32",WS_CHILDWINDOW|WS_VISIBLE|WS_CLIPCHILDREN|TBSTYLE_FLAT,0,0,307,17
  CONTROL "",IDC_RED,"RichEdit20A",WS_CHILDWINDOW|WS_VISIBLE|WS_VSCROLL|WS_HSCROLL|ES_WANTRETURN|ES_NOHIDESEL|ES_AUTOHSCROLL|ES_AUTOVSCROLL|ES_MULTILINE,0,18,306,192,WS_EX_CLIENTEDGE
END

IDR_ACCEL ACCELERATORS
BEGIN
  114,IDM_EDIT_FINDPREV,VIRTKEY,CONTROL,NOINVERT
  114,IDM_EDIT_FINDNEXT,VIRTKEY,NOINVERT
  83,IDM_FILE_SAVE,VIRTKEY,CONTROL,NOINVERT
  82,IDM_EDIT_REPLACE,VIRTKEY,CONTROL,NOINVERT
  79,IDM_FILE_OPEN,VIRTKEY,CONTROL,NOINVERT
  78,IDM_FILE_NEW,VIRTKEY,CONTROL,NOINVERT
  70,IDM_EDIT_FIND,VIRTKEY,CONTROL,NOINVERT
END

IDR_XPMANIFEST1 MANIFEST "Res/xpmanifest.xml"

[*ENDTXT*]
[*BEGINBIN*]
Res\Toolbar.bmp
424D2007000000000000760000002800
0000F000000010000000010004000200
0000AA06000000000000000000000000
000000000000FFFFFF00000080000080
00000080800080000000800080000000
000080808000C0C0C0000000FF0000FF
000000FFFF00FF000000FF00FF00FFFF
000000666600CC880244228800000488
000484481E880A4452880C6602680C66
02880E66088800048668128804840248
0888024408880A660004688800000488
0008488488440A880284084402860466
024006000204228802860A8800046888
0A66000468880A660268048800048633
06660008886368600800000806866660
08000206088800048668128800064844
48000688000484440688028608880486
02880000048802480484000488480888
02840600000404670437024006660204
2288000466680C880260080000066888
66000833023604880004863306660008
88636860060006660008686066060466
0206088802660488000444480A880484
0244048804660004444806880C660468
00000488024804840004884808880004
84060466000404630473024006000204
22880466068802860488026008000008
68886B63083300086888863306660008
886368600400000C0678876688600800
02060488000668886600048800044448
06880466001048444888867807640488
0006188868000488000A8BBB88666800
00000488000E84448488488886000466
02640600000404670437000640666000
04440C880248048802840E8800048666
068802680488026008000008688860B6
08330008368886330866000663686000
040000106788E7768860660604660206
04880006668668000C88000A66888074
44000488001267888076888118886800
04880006877788000468000006880484
02440488028604000004040604660004
04630473024004000006404888000444
02480488024804880284048802840444
0688000A666888866800048802600800
000A68886B0B63000833000468860C33
000468600400000C6888878688600800
02060488046602680488000A44488886
78000488000407680488026804880004
0688041102180C660004688600000688
00048464068800088606666406000004
04670437024004000244048804440688
02840488024806880444068800088666
8866068802600800000A688860B0B600
0A660004863308660006336860000400
000C68E8878688600600000460060488
0866000A884448888600068800048068
04880012680E88868881188168000888
06860000088802680688028604000006
04066000044402630473064402460488
00044448068802840488024806880004
84440888046602680688026008000006
68886B00080B02680488000486360888
0006636860000400001667EE87768860
66000686060004880666000C68888444
88680888028604880008670088760488
00061881860008660468026600000688
00048666068800088606666404000006
404867000A3702360488000444840688
02840488024806880004484408880004
866608880260080000066888600008B0
02680488000486360888000663686000
04000010067887688860686004680006
66684400066606880006444868000888
02860488000886788768068800068188
60000600020604860000068804860688
02860400020404000008448863760666
00046776048800064888440004880248
04880284048800064488840008880466
0268068802600800000868886B0B0666
02680488000486360888000663686000
06000466048800046006068600068886
440004660010688444888444680E0688
02860688046600048881088800048606
04660006066668000000068800066686
68000488000886066064044400084888
67760688000467360A88044408880444
0C88000886668866068802600400000C
06666888866608880008666886360888
00066368600008000206048804660668
0488024404660010888444888444680E
068802860C8800068188180004880286
08000004688800000688000668886800
048802860400000460680688000E6373
6B66B67376002488000C866668888668
04880260040004061088000886688636
08880006666860000600046608880486
068800184466688884448884448600EE
048802680C8800068188110006880260
04660006606888000000068800066888
68000488028604000266088802860466
02BB0466026824880466068802660488
02600400000406680C88000468880468
00048636088804680260060004680A88
0268048800068644660006880644000E
48867000888768000E88041102180488
02600600000406880000068800066888
680004880286046602680C8800068666
68002888000466680888000468880866
0E8800048666048802860C6600046860
060002660C8802860466000668446800
06880284044404880266048802661288
02110688028608660288000090880866
02682A88046614880218128800000001
[*ENDBIN*]
[*BEGINTXT*]
Res\xpmanifest.xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
<assemblyIdentity
	version="1.0.0.0"
	processorArchitecture="*"
	name="Company.Product.Name"
	type="win32"
/>
<description></description>
<dependency>
	<dependentAssembly>
		<assemblyIdentity
			type="win32"
			name="Microsoft.Windows.Common-Controls"
			version="6.0.0.0"
			processorArchitecture="*"
			publicKeyToken="6595b64144ccf1df"
			language="*"
		/>
	</dependentAssembly>
</dependency>
</assembly>
[*ENDTXT*]
