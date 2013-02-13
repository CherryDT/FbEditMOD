
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
	invoke GetMenu,ha.hWnd
	mov		edx,eax
	invoke GetMenuItemInfo,edx,IDM_TOOLS,FALSE,addr mii
	mov		eax,mii.hSubMenu
	mov		hSubMnu,eax
	mov		nID,20000
	invoke ClearMenu,hSubMnu,nID
	mov		nInx,1
	.while nInx<20
		mov		mnu.szcap,0
		mov		mnu.szcmnd,0
		invoke MakeKey,addr szMenuTool,nInx,addr buffer
		mov		lpcbData,sizeof mnu
		invoke RegQueryValueEx,ha.hReg,addr buffer,0,addr lpType,addr mnu,addr lpcbData
		movzx	eax,mnu.szcap
		.if eax
			.if eax=='-'
				invoke AppendMenu,hSubMnu,MF_SEPARATOR,0,addr szNULL
			.else
				invoke AppendMenu,hSubMnu,MF_STRING,nID,addr mnu.szcap
			.endif
			inc		nID
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
	mov		nID,30000
	invoke ClearMenu,hSubMnu,nID
	mov		nInx,1
	.while nInx<20
		mov		mnu.szcap,0
		mov		mnu.szcmnd,0
		invoke MakeKey,addr szMenuHelp,nInx,addr buffer
		mov		lpcbData,sizeof mnu
		invoke RegQueryValueEx,ha.hReg,addr buffer,0,addr lpType,addr mnu,addr lpcbData
		movzx	eax,mnu.szcap
		.if eax
			.if eax=='-'
				invoke AppendMenu,hSubMnu,MF_SEPARATOR,0,addr szNULL
			.else
				invoke AppendMenu,hSubMnu,MF_STRING,nID,addr mnu.szcap
			.endif
			inc		nID
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
	LOCAL	buffer1[256]:BYTE
	LOCAL	mnu:MENU
	LOCAL	nInx:DWORD
	LOCAL	nReg:DWORD

	mov		nInx,0
	mov		nReg,1
	.while TRUE
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
			.else
				jmp		@b
			.endif
			invoke strcpy,addr mnu.szcap,addr buffer
			invoke strcpy,addr mnu.szcmnd,esi
			invoke MakeKey,lpAppName,nReg,addr buffer1
			invoke RegSetValueEx,ha.hReg,addr buffer1,0,REG_BINARY,addr mnu,sizeof mnu
			inc		nReg
		.endif
		inc		nInx
	.endw
	.while nReg<20
		invoke MakeKey,lpAppName,nReg,addr buffer1
		invoke RegDeleteValue,ha.hReg,addr buffer1
		inc		nReg
	.endw
	ret

MenuOptionSave endp

MenuOptionProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer0[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	ofn:OPENFILENAME
	LOCAL	mnu:MENU

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_EDTMEITEM,EM_LIMITTEXT,31,0
		invoke SendDlgItemMessage,hWin,IDC_EDTMECMND,EM_LIMITTEXT,128,0
		mov		nInx,120
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETTABSTOPS,1,addr nInx
		.if lParam==1
			mov		lpAppName,offset szMenuTool
			mov		lpFilter,offset szFilterTools
			mov		eax,offset szOptTool
		.elseif lParam==2
			mov		lpAppName,offset szMenuHelp
			mov		lpFilter,offset szFilterHelp
			mov		eax,offset szOptHelp
		.elseif lParam==3
			mov		lpAppName,offset szMenuExternal
			mov		lpFilter,offset szFilterTools
			invoke SetDlgItemText,hWin,IDC_STCMENU,addr szStcExternal
			mov		eax,offset szOptExternal
		.endif
		invoke SendMessage,hWin,WM_SETTEXT,0,eax
		invoke ImageList_GetIcon,ha.hMnuIml,2,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNMEU,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,ha.hMnuIml,3,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNMED,BM_SETIMAGE,IMAGE_ICON,eax
		mov		nInx,1
		.while nInx<20
			mov		mnu.szcap,0
			mov		mnu.szcmnd,0
			invoke MakeKey,lpAppName,nInx,addr buffer1
			mov		lpcbData,sizeof mnu
			invoke RegQueryValueEx,ha.hReg,addr buffer1,0,addr lpType,addr mnu,addr lpcbData
			movzx	eax,mnu.szcap
			.if eax
				invoke strcpy,addr buffer1,addr mnu.szcap
				invoke strcat,addr buffer1,addr szTab
				invoke strcat,addr buffer1,addr mnu.szcmnd
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_ADDSTRING,0,addr buffer1
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
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
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
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

MenuOptionProc endp
