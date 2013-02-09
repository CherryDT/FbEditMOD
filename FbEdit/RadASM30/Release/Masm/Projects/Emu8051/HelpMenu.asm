
IDD_DLGOPTMNU							equ 3200
IDC_LSTME								equ 3201
IDC_BTNMFILE							equ 3203
IDC_EDTMEITEM							equ 3207
IDC_EDTMECMND							equ 3208
IDC_BTNMEU								equ 3202
IDC_BTNMED								equ 3204
IDC_BTNMEADD							equ 3205
IDC_BTNMEDEL							equ 3206
IDC_STCMENU								equ 3209

MENU struct
	szcap	db 32 dup(?)
	szcmnd	db 128 dup(?)
MENU ends

;Help
HH_AKLINK struct
	cbStruct		dd ?						;As Integer
	fReserved		dd ?						;As Boolean
	pszKeywords		dd ?						;As ZString Ptr
	pszUrl			dd ?						;As ZString Ptr
	pszMsgText		dd ?						;As ZString Ptr
	pszMsgTitle		dd ?						;As ZString Ptr
	pszWindow		dd ?						;As ZString Ptr
	fIndexOnFail	dd ?						;As Boolean
HH_AKLINK ends

HH_DISPLAY_TOPIC	equ 0000h
HH_KEYWORD_LOOKUP	equ 000Dh

.data?

fUpdate			DWORD ?

.code

ClearMenu proc hSubMnu:HMENU,nID:DWORD
	LOCAL	nInx:DWORD	

	mov		nInx,20
	.while nInx
		invoke DeleteMenu,hSubMnu,nID,MF_BYCOMMAND
		.break .if !eax
		inc		nID
		dec		nInx
	.endw
	ret

ClearMenu endp

SetHelpMenu proc
	LOCAL	hSubMnu:HMENU
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	mnu:MENU
	LOCAL	nInx:DWORD
	LOCAL	nID:DWORD
	LOCAL	mii:MENUITEMINFO

	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_SUBMENU
	invoke GetMenuItemInfo,hMenu,IDM_HELP,FALSE,addr mii
	mov		eax,mii.hSubMenu
	mov		hSubMnu,eax
	mov		nID,IDM_HELP_START
	invoke ClearMenu,hSubMnu,nID
	mov		nInx,0
	.while nInx<20
		invoke BinToDec,nInx,addr buffer
		invoke GetPrivateProfileString,addr szHelpMenu,addr buffer,addr szNULL,addr buffer1,sizeof buffer1,addr szinifile
		.if eax
			invoke GetItemStr,addr buffer1,addr szNULL,addr mnu.szcap,sizeof mnu.szcap
			invoke lstrcpyn,addr mnu.szcmnd,addr buffer1,sizeof mnu.szcmnd
			movzx	eax,mnu.szcap
			.if eax
				.if eax=='-'
					mov		mii.cbSize,sizeof MENUITEMINFO
					mov		mii.fMask,MIIM_TYPE or MIIM_ID
					mov		mii.fType,MFT_SEPARATOR
					mov		eax,nID
					mov		mii.wID,eax
					mov		edx,nInx
					invoke InsertMenuItem,hSubMnu,addr [edx+2],TRUE,addr mii
				.else
					mov		mii.cbSize,sizeof MENUITEMINFO
					mov		mii.fMask,MIIM_TYPE or MIIM_ID
					mov		mii.fType,MFT_STRING
					mov		eax,nID
					mov		mii.wID,eax
					lea		eax,mnu.szcap
					mov		mii.dwTypeData,eax
					mov		edx,nInx
					invoke InsertMenuItem,hSubMnu,addr [edx+2],TRUE,addr mii
				.endif
				inc		nID
			.endif
		.endif
		inc		nInx
	.endw
	ret

SetHelpMenu endp

EditGet proc hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	nInx:DWORD

	invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		mov		nInx,eax
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETTEXT,nInx,addr buffer
		push	esi
		lea		esi,buffer
		dec		esi
	  @@:
		inc		esi
		mov		al,[esi]
		cmp		al,09h
		jne		@b
		mov		al,0
		mov		[esi],al
		inc		esi
		invoke SendDlgItemMessage,hWin,IDC_EDTMECMND,WM_SETTEXT,0,esi
		invoke SendDlgItemMessage,hWin,IDC_EDTMEITEM,WM_SETTEXT,0,addr buffer
		pop		esi
	.endif
	ret

EditGet endp

EditUpdate proc uses esi,hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	nInx:DWORD

	.if fUpdate
		invoke GetDlgItemText,hWin,IDC_EDTMEITEM,addr buffer,256
		invoke lstrlen,addr buffer
		lea		esi,buffer
		add		esi,eax
		mov		byte ptr [esi],09h
		inc		esi
		invoke GetDlgItemText,hWin,IDC_EDTMECMND,esi,256
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCURSEL,0,0
		.if eax==LB_ERR
			mov		eax,0
		.endif
		mov		nInx,eax
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_DELETESTRING,nInx,0
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_INSERTSTRING,nInx,addr buffer
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,nInx,0
	.endif
	ret

EditUpdate endp

MenuOptionSave proc uses esi edi,hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	mnu:MENU
	LOCAL	nInx:DWORD
	LOCAL	nIni:DWORD

	mov		nInx,0
	mov		nIni,0
	mov		word ptr buffer,0
	invoke WritePrivateProfileSection,addr szHelpMenu,addr buffer,addr szinifile
	.while nIni<20
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETTEXT,nInx,addr buffer
	  .break .if eax==LB_ERR
		mov		al,buffer[1]
		.if al
			lea		esi,buffer
		  @@:
			mov		al,[esi]
			inc		esi
			.if al==09h
				mov		byte ptr [esi-1],0
			.elseif al
				jmp		@b
			.endif
			invoke lstrcpyn,addr mnu.szcap,addr buffer,sizeof mnu.szcap
			invoke lstrcpyn,addr mnu.szcmnd,esi,sizeof mnu.szcmnd
			mov		buffer1,0
			invoke PutItemStr,addr buffer1,addr mnu.szcap
			invoke PutItemStr,addr buffer1,addr mnu.szcmnd
			invoke BinToDec,nIni,addr buffer
			invoke WritePrivateProfileString,addr szHelpMenu,addr buffer,addr buffer1[1],addr szinifile
			inc		nIni
		.endif
		inc		nInx
	.endw
	ret

MenuOptionSave endp

MenuOptionProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer0[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	ofn:OPENFILENAME

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_EDTMEITEM,EM_LIMITTEXT,31,0
		invoke SendDlgItemMessage,hWin,IDC_EDTMECMND,EM_LIMITTEXT,127,0
		mov		nInx,120
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETTABSTOPS,1,addr nInx
		invoke ImageList_GetIcon,hImlTbr,17,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNMEU,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,hImlTbr,18,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNMED,BM_SETIMAGE,IMAGE_ICON,eax
		mov		nInx,0
		.while nInx<20
			invoke BinToDec,nInx,addr buffer0
			invoke GetPrivateProfileString,addr szHelpMenu,addr buffer0,addr szNULL,addr buffer1,sizeof buffer1,addr szinifile
			.if eax
				xor		eax,eax
				.while buffer1[eax]
					.if buffer1[eax]==','
						mov		buffer1[eax],VK_TAB
						.break
					.endif
					inc		eax
				.endw
				.if buffer1[eax]==VK_TAB
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_ADDSTRING,0,addr buffer1
				.endif
			.endif
			inc		nInx
		.endw
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,0,0
		mov		fUpdate,0
		invoke EditGet,hWin
		mov		fUpdate,1
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke MenuOptionSave,hWin
				invoke SetHelpMenu
				invoke SendMessage,hWin,WM_CLOSE,NULL,TRUE
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNMEU
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCURSEL,0,0
				.if eax
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETTEXT,nInx,addr buffer0
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_DELETESTRING,nInx,0
					dec		nInx
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_INSERTSTRING,nInx,addr buffer0
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,nInx,0
				.endif
			.elseif eax==IDC_BTNMED
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCURSEL,0,0
				mov		nInx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCOUNT,0,0
				dec		eax
				.if eax!=nInx
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETTEXT,nInx,addr buffer0
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_DELETESTRING,nInx,0
					inc		nInx
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_INSERTSTRING,nInx,addr buffer0
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,nInx,0
				.endif
			.elseif eax==IDC_BTNMEADD
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCURSEL,0,0
				.if eax==LB_ERR
					mov		eax,0
				.endif
				mov		nInx,eax
				mov		buffer0[0],09h
				mov		buffer0[1],0
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_INSERTSTRING,nInx,addr buffer0
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,nInx,0
				invoke SendDlgItemMessage,hWin,IDC_EDTMECMND,WM_SETTEXT,0,addr szNULL
				invoke SendDlgItemMessage,hWin,IDC_EDTMEITEM,WM_SETTEXT,0,addr szNULL
			.elseif eax==IDC_BTNMEDEL
				mov		fUpdate,0
				invoke SendDlgItemMessage,hWin,IDC_EDTMECMND,WM_SETTEXT,0,addr szNULL
				invoke SendDlgItemMessage,hWin,IDC_EDTMEITEM,WM_SETTEXT,0,addr szNULL
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_DELETESTRING,nInx,0
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,nInx,0
					.if eax==LB_ERR
						dec		nInx
						invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,nInx,0
					.endif
					invoke EditGet,hWin
				.endif
				mov		fUpdate,1
			.elseif eax==IDC_BTNMFILE
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrInitialDir,NULL
				mov		eax,offset szANYString
				mov		ofn.lpstrFilter,eax
				mov		ofn.lpstrDefExt,0
				mov		ofn.lpstrTitle,0
				lea		eax,buffer0
				mov		ofn.lpstrFile,eax
				invoke GetDlgItemText,hWin,IDC_EDTMECMND,addr buffer0,sizeof buffer0
				mov		ofn.nMaxFile,sizeof buffer0
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke SetDlgItemText,hWin,IDC_EDTMECMND,addr buffer0
				.endif
			.endif
		.elseif edx==EN_CHANGE
			invoke EditUpdate,hWin
		.elseif edx==LBN_SELCHANGE
			mov		fUpdate,0
			invoke EditGet,hWin
			mov		fUpdate,1
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,lParam
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

MenuOptionProc endp

DoHelp proc lpszHelpFile:DWORD,lpszWord:DWORD
	LOCAL	hhaklink:HH_AKLINK
	LOCAL	hHHwin:HWND
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,lpszHelpFile
	.if byte ptr [eax]
		.if dword ptr [eax]=='ptth'
			;URL
			invoke ShellExecute,hWnd,addr szOpen,lpszHelpFile,NULL,NULL,SW_SHOWNORMAL;SW_SHOWDEFAULT
		.else
			invoke lstrcpy,addr buffer,lpszHelpFile
			invoke FixPath,addr buffer,addr szapppath,addr szDollarA
			invoke lstrlen,addr buffer
			lea		edx,buffer
			mov		edx,[edx+eax-4]
			and		edx,5F5F5FFFh
			.if edx=='MHC.'
				;Chm file
				invoke RtlZeroMemory,addr hhaklink,sizeof HH_AKLINK
				.if !hHtmlOcx
					invoke LoadLibrary,offset szhhctrl
					mov		hHtmlOcx,eax
					invoke GetProcAddress,hHtmlOcx,offset szHtmlHelpA
					mov		pHtmlHelpProc,eax
				.endif
				.if hHtmlOcx
					mov		hhaklink.cbStruct,SizeOf HH_AKLINK
					mov		hhaklink.fReserved,FALSE
					mov		eax,lpszWord
					mov		hhaklink.pszKeywords,eax
					mov		hhaklink.pszUrl,NULL
					mov		hhaklink.pszMsgText,NULL
					mov		hhaklink.pszMsgTitle,NULL
					mov		hhaklink.pszWindow,NULL
					mov		hhaklink.fIndexOnFail,TRUE
					push	0
					push	HH_DISPLAY_TOPIC
					lea		eax,buffer
					push	eax
					push	0
					Call	[pHtmlHelpProc]
					mov		hHHwin,eax
					lea		eax,hhaklink
					push	eax
					push	HH_KEYWORD_LOOKUP
					lea		eax,buffer
					push	eax
					push	0
					Call	[pHtmlHelpProc]
				.endif
			.elseif edx=='PLH.'
				;Hlp file
				invoke WinHelp,hWnd,addr buffer,HELP_KEY,lpszWord
			.else
				;Other
				invoke ShellExecute,hWnd,addr szOpen,addr buffer,NULL,NULL,SW_SHOWNORMAL
			.endif
		.endif
	.endif
	ret

DoHelp endp
