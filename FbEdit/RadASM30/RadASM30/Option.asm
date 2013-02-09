
MENU struct
	szcap	db 32 dup(?)
	szcmnd	db 128 dup(?)
MENU ends

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

.const

szOptTool			db 'Tools menu - ',0
szFilterTools		db 'Commands (*.com, *.exe, *.cmd)',0,'*.com;*.exe;*.cmd',0
					db 'All Files (*.*)',0,'*.*',0,0
szOptHelp			db 'Help menu - ',0
szFilterHelp		db 'Help (*.hlp, *.chm)',0,'*.hlp;*.chm',0
					db 'All Files (*.*)',0,'*.*',0,0
szOptExternal		db 'External Files - ',0
szStcExternal		db 'Filetypes (note the use of dots):',0
szOptHelpF1			db 'F1-Help - ',0
szStcHelpF1			db 'Keyword: Api, RC or ',0
szApi				db 'Api',0
szRC				db 'RC',0

.data?

lpAppName			dd ?
lpFilter			dd ?
fUpdate				dd ?

.code

ClearMenu proc hSubMenu:DWORD,nID:DWORD
	LOCAL	nInx:DWORD	

	mov		nInx,20
	.while nInx
		invoke DeleteMenu,hSubMenu,nID,MF_BYCOMMAND
		.break .if !eax
		inc		nID
		dec		nInx
	.endw
	ret

ClearMenu endp

SetToolMenu proc
	LOCAL	hSubMnu:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	mnu:MENU
	LOCAL	nInx:DWORD
	LOCAL	nID:DWORD
	LOCAL	mii:MENUITEMINFO

	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_SUBMENU
	invoke GetMenuItemInfo,ha.hMenu,IDM_TOOLS,FALSE,addr mii
	mov		eax,mii.hSubMenu
	mov		hSubMnu,eax
	mov		nID,IDM_TOOLS_START
	invoke ClearMenu,hSubMnu,nID
	mov		nInx,0
	.while nInx<20
		invoke BinToDec,nInx,addr buffer
		invoke GetPrivateProfileString,addr szIniTool,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
		.if eax
			invoke GetItemStr,addr tmpbuff,addr szNULL,addr mnu.szcap,sizeof mnu.szcap
			invoke strcpyn,addr mnu.szcmnd,addr tmpbuff,sizeof mnu.szcmnd
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

SetToolMenu endp

SetHelpMenu proc
	LOCAL	hSubMnu:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	mnu:MENU
	LOCAL	nInx:DWORD
	LOCAL	nID:DWORD
	LOCAL	mii:MENUITEMINFO

	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_SUBMENU
	invoke GetMenu,ha.hWnd
	mov		edx,eax
	invoke GetMenuItemInfo,edx,IDM_HELP,FALSE,addr mii
	mov		eax,mii.hSubMenu
	mov		hSubMnu,eax
	mov		nID,IDM_HELP_START
	invoke ClearMenu,hSubMnu,nID
	mov		nInx,0
	.while nInx<20
		invoke BinToDec,nInx,addr buffer
		invoke GetPrivateProfileString,addr szIniHelp,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
		.if eax
			invoke GetItemStr,addr tmpbuff,addr szNULL,addr mnu.szcap,sizeof mnu.szcap
			invoke strcpyn,addr mnu.szcmnd,addr tmpbuff,sizeof mnu.szcmnd
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

SetF1Help proc
	LOCAL	buffer[256]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	mnu:MENU

	mov		nInx,0
	invoke RtlZeroMemory,addr da.szHelpF1,sizeof da.szHelpF1
	.while nInx<3
		invoke BinToDec,nInx,addr buffer
		invoke GetPrivateProfileString,addr szIniHelpF1,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
		.if eax
			invoke GetItemStr,addr tmpbuff,addr szNULL,addr mnu.szcap,sizeof mnu.szcap
			invoke strcpyn,addr mnu.szcmnd,addr tmpbuff,sizeof mnu.szcmnd
			.if mnu.szcap
				invoke strcmpi,addr mnu.szcap,addr da.szAssembler
				.if !eax
					;Assembler help
					invoke strcpy,addr da.szHelpF1[MAX_PATH*0],addr mnu.szcmnd
				.else
					invoke strcmpi,addr mnu.szcap,addr szRC
					.if !eax
						;RC help
						invoke strcpy,addr da.szHelpF1[MAX_PATH*1],addr mnu.szcmnd
					.else
						invoke strcmpi,addr mnu.szcap,addr szApi
						.if !eax
							;Api help
							invoke strcpy,addr da.szHelpF1[MAX_PATH*2],addr mnu.szcmnd
						.endif
					.endif
				.endif
			.endif
		.endif
		inc		nInx
	.endw
	ret

SetF1Help endp

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
		invoke strlen,addr buffer
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
	LOCAL	mnu:MENU
	LOCAL	nInx:DWORD
	LOCAL	nIni:DWORD

	mov		nInx,0
	mov		nIni,0
	mov		word ptr buffer,0
	invoke WritePrivateProfileSection,lpAppName,addr buffer,addr da.szAssemblerIni
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
			invoke strcpyn,addr mnu.szcap,addr buffer,sizeof mnu.szcap
			invoke strcpyn,addr mnu.szcmnd,esi,sizeof mnu.szcmnd
			mov		tmpbuff,0
			invoke PutItemStr,addr tmpbuff,addr mnu.szcap
			invoke PutItemStr,addr tmpbuff,addr mnu.szcmnd
			invoke BinToDec,nIni,addr buffer
			invoke WritePrivateProfileString,lpAppName,addr buffer,addr tmpbuff[1],addr da.szAssemblerIni
			inc		nIni
		.endif
		inc		nInx
	.endw
	ret

MenuOptionSave endp

MenuOptionProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer0[256]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	ofn:OPENFILENAME

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_EDTMEITEM,EM_LIMITTEXT,31,0
		invoke SendDlgItemMessage,hWin,IDC_EDTMECMND,EM_LIMITTEXT,127,0
		mov		nInx,120
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETTABSTOPS,1,addr nInx
		mov		eax,lParam
		.if eax==IDM_OPTION_TOOLS
			mov		lpAppName,offset szIniTool
			mov		lpFilter,offset szFilterTools
			invoke strcpy,addr buffer,addr szOptTool
			invoke strcat,addr buffer,addr da.szAssembler
			lea		eax,buffer
		.elseif eax==IDM_OPTION_HELP
			mov		lpAppName,offset szIniHelp
			mov		lpFilter,offset szFilterHelp
			invoke strcpy,addr buffer,addr szOptHelp
			invoke strcat,addr buffer,addr da.szAssembler
			lea		eax,buffer
		.elseif eax==IDM_OPTION_EXTERNAL
			mov		lpAppName,offset szIniExternal
			mov		lpFilter,offset szFilterTools
			invoke SetDlgItemText,hWin,IDC_STCMENU,addr szStcExternal
			invoke strcpy,addr buffer,addr szOptExternal
			invoke strcat,addr buffer,addr da.szAssembler
			lea		eax,buffer
		.elseif eax==IDM_OPTION_F1
			mov		lpAppName,offset szIniHelpF1
			mov		lpFilter,offset szFilterHelp
			invoke strcpy,addr buffer0,addr szStcHelpF1
			invoke strcat,addr buffer0,addr da.szAssembler
			invoke SetDlgItemText,hWin,IDC_STCMENU,addr buffer0
			invoke strcpy,addr buffer,addr szOptHelpF1
			invoke strcat,addr buffer,addr da.szAssembler
			lea		eax,buffer
		.endif
		invoke SendMessage,hWin,WM_SETTEXT,0,eax
		invoke ImageList_GetIcon,ha.hMnuIml,2,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNMEU,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,ha.hMnuIml,3,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNMED,BM_SETIMAGE,IMAGE_ICON,eax
		mov		nInx,0
		.while nInx<20
			invoke BinToDec,nInx,addr buffer0
			invoke GetPrivateProfileString,lpAppName,addr buffer0,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
			.if eax
				xor		eax,eax
				.while tmpbuff[eax]
					.if tmpbuff[eax]==','
						mov		tmpbuff[eax],VK_TAB
						.break
					.endif
					inc		eax
				.endw
				.if tmpbuff[eax]==VK_TAB
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_ADDSTRING,0,addr tmpbuff
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
				push	ha.hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrInitialDir,NULL
				mov		eax,lpFilter
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
