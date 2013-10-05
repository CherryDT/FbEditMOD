
IDD_DLGMENUEDIT			equ 1500
IDC_EDTITEMCAPTION		equ 2512
IDC_HOTMENU				equ 2513
IDC_EDTITEMNAME			equ 2516
IDC_EDTITEMID			equ 2518
IDC_EDTHELPID			equ 2529
IDC_BTNADD				equ 2532
IDC_BTNINSERT			equ 2519
IDC_BTNDELETE			equ 2520
IDC_BTNL				equ 2521
IDC_BTNR				equ 2522
IDC_BTNU				equ 2523
IDC_BTND				equ 2524
IDC_BTNMNUPREVIEW		equ 2503
IDC_LSTMNU				equ 2525
IDC_CHKCHECKED			equ 2526
IDC_CHKGRAYED			equ 2527
IDC_CHKRIGHTALIGN		equ 2500
IDC_CHKRADIO			equ 2509
IDC_CHKOWNERDRAW		equ 2530

IDD_DLGMNUPREVIEW		equ 1510

.data

szMnuErr				db 'Menu skipped a level.',0
szMnuName				db 'IDR_MENU',0
szMnuItemName			db 'IDM_',0
szShift					db 'Shift+',0
szCtrl					db 'Ctrl+',0
szAlt					db 'Alt+',0
hMnuMem					dd 0
nMnuInx					dd 0
fMnuSel					dd FALSE
MnuTabs					dd 135,140,145,150,155,160

.data?

lpOldHotProc			dd ?
fHotFocus				dd ?
lpOldNameEditProc		dd ?

.code

MnuSaveDefine proc uses esi,lpName:DWORD,lpID:DWORD
	LOCAL	buffer[16]:BYTE
	LOCAL	val:DWORD

	mov		esi,lpName
	mov		al,[esi]
	.if al
		mov		esi,lpID
		mov		eax,[esi]
		.if eax
			invoke ExportName,lpName,eax,edi
			lea		edi,[edi+eax]
		.endif
	.endif
	ret

MnuSaveDefine endp

MnuSpc proc val:DWORD

	push	eax
	push	ecx
	mov		eax,val
	inc		eax
	add		eax,eax
	mov		ecx,eax
	mov		al,' '
	rep stosb
	pop		ecx
	pop		eax
	ret

MnuSpc endp

MnuSaveAccel proc uses esi edi,nAccel:DWORD,lpDest:DWORD

	mov		esi,nAccel
	mov		edi,lpDest
	shr		esi,9
	.if CARRY?
		invoke SaveStr,edi,offset szShift
		add		edi,eax
	.endif
	shr		esi,1
	.if CARRY?
		invoke SaveStr,edi,offset szCtrl
		add		edi,eax
	.endif
	shr		esi,1
	.if CARRY?
		invoke SaveStr,edi,offset szAlt
		add		edi,eax
	.endif
	mov		eax,nAccel
	movzx	eax,al
	.if eax>='A' && eax<='Z'
		stosb
	.elseif eax>=VK_F1 && eax<=VK_F12
		mov		byte ptr [edi],'F'
		inc		edi
		sub		eax,VK_F1-1
		invoke ResEdBinToDec,eax,edi
		invoke strlen,edi
		lea		edi,[edi+eax]
	.endif
	mov		byte ptr [edi],0
	mov		eax,edi
	sub		eax,lpDest
	ret

MnuSaveAccel endp

ExportMenuNames proc uses esi edi,hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
	mov    edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	invoke MnuSaveDefine,addr (MNUHEAD ptr [esi]).menuname,addr (MNUHEAD ptr [esi]).menuid
	add		esi,sizeof MNUHEAD
  @@:
	mov		eax,(MNUITEM ptr [esi]).itemflag
	.if eax
		.if eax!=-1
			invoke MnuSaveDefine,addr (MNUITEM ptr [esi]).itemname,addr (MNUITEM ptr [esi]).itemid
		.endif
		add		esi,sizeof MNUITEM
		jmp		@b
	.endif
	pop		eax
	ret

ExportMenuNames endp

MnuSaveItemEx proc uses ebx,lpItem:DWORD,fPopUp:DWORD
	LOCAL	val:DWORD

	invoke SaveStr,edi,lpItem
	add		edi,eax
	mov		al,' '
	stosb
	mov		al,22h
	stosb
	.if byte ptr (MNUITEM ptr [esi]).itemcaption!='-'
		invoke SaveText,edi,addr (MNUITEM ptr [esi]).itemcaption
		add		edi,eax
	.endif
	mov		eax,(MNUITEM ptr [esi]).shortcut
	.if eax
		mov		val,eax
		mov		ax,'t\'
		stosw
		invoke MnuSaveAccel,val,edi
		add		edi,eax
	.endif
	mov		al,22h
	stosb
	mov		ebx,edi
	mov		al,','
	stosb
	mov		al,(MNUITEM ptr [esi]).itemname
	.if !al
		m2m		val,(MNUITEM ptr [esi]).itemid
		.if val!=0 && val!=-1
			invoke SaveVal,val,FALSE
			mov		ebx,edi
		.endif
	.else
		invoke SaveStr,edi,addr (MNUITEM ptr [esi]).itemname
		add		edi,eax
		mov		ebx,edi
	.endif
	mov		al,','
	stosb
	;MFT_
	mov		edx,(MNUITEM ptr [esi]).ntype
	.if byte ptr (MNUITEM ptr [esi]).itemcaption=='-'
		or		edx,MFT_SEPARATOR
	.endif
	.if edx
		invoke SaveHexVal,edx,FALSE
		mov		ebx,edi
	.endif
	mov		al,','
	stosb
	;MFS_
	mov		eax,(MNUITEM ptr [esi]).nstate
	.if eax
		invoke SaveHexVal,eax,FALSE
		mov		ebx,edi
	.endif
	.if fPopUp
		;HelpID
		mov		al,','
		stosb
		mov		eax,(MNUITEM ptr [esi]).helpid
		.if eax
			invoke SaveVal,eax,FALSE
			mov		ebx,edi
		.endif
	.endif
	mov		edi,ebx
  Ex:
	mov		ax,0A0Dh
	stosw
	ret

MnuSaveItemEx endp

MenuSkippedLevel proc uses esi,lpMenu:DWORD
	LOCAL buffer[256]:BYTE

	mov		esi,lpMenu
	invoke lstrcpy,addr buffer,addr [esi].MNUHEAD.menuname
	invoke lstrcat,addr buffer,addr szCrLf
	invoke lstrcat,addr buffer,addr szMnuErr
	invoke MessageBox,hDEd,addr buffer,addr szAppName,MB_OK or MB_ICONERROR
	mov		fMenuErr,TRUE
	ret

MenuSkippedLevel endp

ExportMenuEx proc uses esi edi,hMem:DWORD
	LOCAL	val:DWORD
	LOCAL	level:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
	mov		edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	mov		al,(MNUHEAD ptr [esi]).menuname
	.if al
		invoke SaveStr,edi,addr (MNUHEAD ptr [esi]).menuname
		add		edi,eax
	.else
		m2m		val,(MNUHEAD ptr [esi]).menuid
		invoke SaveVal,val,FALSE
	.endif
	mov		al,' '
	stosb
	invoke SaveStr,edi,addr szMENUEX
	add		edi,eax
	mov		ax,0A0Dh
	stosw
	.if [esi].MNUHEAD.lang.lang || [esi].MNUHEAD.lang.sublang
		invoke SaveLanguage,addr [esi].MNUHEAD.lang,edi
		add		edi,eax
	.endif
	invoke SaveStr,edi,addr szBEGIN
	add		edi,eax
	mov		ax,0A0Dh
	stosw
	mov		level,0
	add		esi,sizeof MNUHEAD
  Nx:
	mov		eax,(MNUITEM ptr [esi]).itemflag
	.if eax
		.if eax!=-1
			mov		eax,(MNUITEM ptr [esi]).level
			.if eax!=level
				invoke MenuSkippedLevel,hMem
				jmp		MnExEx
			.endif
			push	esi
		  @@:
			add		esi,sizeof MNUITEM
			mov		eax,(MNUITEM ptr [esi]).itemflag
			.if eax
				.if eax==-1
					jmp		@b
				.endif
				mov		eax,(MNUITEM ptr [esi]).level
			.endif
			mov		val,eax
			pop		esi
			invoke MnuSpc,level
			.if eax>level
				invoke MnuSaveItemEx,addr szPOPUP,TRUE
			.else
				invoke MnuSaveItemEx,addr szMENUITEM,FALSE
			.endif
			mov		eax,val
			.if eax>level
				sub		eax,level
				.if eax!=1
					invoke MenuSkippedLevel,hMem
					jmp		MnExEx
				.endif
				invoke MnuSpc,level
				m2m		level,val
				invoke SaveStr,edi,addr szBEGIN
				add		edi,eax
				mov		ax,0A0Dh
				stosw
			.elseif eax<level
			  @@:
				mov		eax,val
				.if eax!=level
					dec		level
					invoke MnuSpc,level
					invoke SaveStr,edi,addr szEND
					add		edi,eax
					mov		ax,0A0Dh
					stosw
					jmp		@b
				.endif
			.endif
			add		esi,sizeof MNUITEM
			jmp		Nx
		.endif
	.endif
	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		eax,0A0Dh
	stosw
	stosd
	pop		eax
	ret
  MnExEx:
	pop		edi
	invoke GlobalUnlock,edi
	invoke GlobalFree,edi
	xor		eax,eax
	ret

ExportMenuEx endp

MnuSaveItem proc uses ebx,lpItem:DWORD,fPopUp:DWORD
	LOCAL	val:DWORD

	invoke SaveStr,edi,lpItem
	add		edi,eax
	mov		al,' '
	stosb
	.if byte ptr (MNUITEM ptr [esi]).itemcaption=='-' || byte ptr (MNUITEM ptr [esi]).itemcaption==0
		invoke SaveStr,edi,offset szSEPARATOR
		add		edi,eax
	.else
		mov		al,22h
		stosb
		invoke SaveText,edi,addr (MNUITEM ptr [esi]).itemcaption
		add		edi,eax
		mov		eax,(MNUITEM ptr [esi]).shortcut
		.if eax
			mov		val,eax
			mov		ax,'t\'
			stosw
			invoke MnuSaveAccel,val,edi
			add		edi,eax
		.endif
		mov		al,22h
		stosb
		.if !fPopUp
			mov		ebx,edi
			mov		al,','
			stosb
			mov		al,(MNUITEM ptr [esi]).itemname
			.if !al
				m2m		val,(MNUITEM ptr [esi]).itemid
				.if val!=0 && val!=-1
					invoke SaveVal,val,FALSE
					mov		ebx,edi
				.endif
			.else
				invoke SaveStr,edi,addr (MNUITEM ptr [esi]).itemname
				add		edi,eax
				mov		ebx,edi
			.endif
		.endif
		mov		eax,(MNUITEM ptr [esi]).nstate
		and		eax,MFS_CHECKED
		.if eax==MFS_CHECKED
			mov		al,','
			stosb
			invoke SaveStr,edi,offset szCHECKED
			add		edi,eax
		.endif
		mov		eax,(MNUITEM ptr [esi]).nstate
		and		eax,MFS_GRAYED
		.if eax==MFS_GRAYED
			mov		al,','
			stosb
			invoke SaveStr,edi,offset szGRAYED
			add		edi,eax
		.endif
		mov		eax,(MNUITEM ptr [esi]).ntype
		and		eax,MFT_RIGHTJUSTIFY
		.if eax==MFT_RIGHTJUSTIFY
			mov		al,','
			stosb
			invoke SaveStr,edi,offset szHELP
			add		edi,eax
		.endif
	.endif
	mov		ax,0A0Dh
	stosw
	ret

MnuSaveItem endp

ExportMenu proc uses esi edi,hMem:DWORD
	LOCAL	val:DWORD
	LOCAL	level:DWORD

	mov		fMenuErr,FALSE
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
	mov		edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	mov		al,(MNUHEAD ptr [esi]).menuname
	.if al
		invoke SaveStr,edi,addr (MNUHEAD ptr [esi]).menuname
		add		edi,eax
	.else
		m2m		val,(MNUHEAD ptr [esi]).menuid
		invoke SaveVal,val,FALSE
	.endif
	mov		al,' '
	stosb
	invoke SaveStr,edi,addr szMENU
	add		edi,eax
	mov		ax,0A0Dh
	stosw
	.if [esi].MNUHEAD.lang.lang || [esi].MNUHEAD.lang.sublang
		invoke SaveLanguage,addr (MNUHEAD ptr [esi]).lang,edi
		add		edi,eax
	.endif
	invoke SaveStr,edi,addr szBEGIN
	add		edi,eax
	mov		ax,0A0Dh
	stosw
	mov		level,0
	add		esi,sizeof MNUHEAD
  Nx:
	mov		eax,(MNUITEM ptr [esi]).itemflag
	.if eax
		.if eax!=-1
			mov		eax,(MNUITEM ptr [esi]).level
			.if eax!=level
				invoke MenuSkippedLevel,hMem
				jmp		MnExEx
			.endif
			push	esi
		  @@:
			add		esi,sizeof MNUITEM
			mov		eax,(MNUITEM ptr [esi]).itemflag
			.if eax
				.if eax==-1
					jmp		@b
				.endif
				mov		eax,(MNUITEM ptr [esi]).level
			.endif
			mov		val,eax
			pop		esi
			invoke MnuSpc,level
			.if eax>level
				invoke MnuSaveItem,addr szPOPUP,TRUE
			.else
				invoke MnuSaveItem,addr szMENUITEM,FALSE
			.endif
			mov		eax,val
			.if eax>level
				sub		eax,level
				.if eax!=1
					invoke MenuSkippedLevel,hMem
					jmp		MnExEx
				.endif
				invoke MnuSpc,level
				m2m		level,val
				invoke SaveStr,edi,addr szBEGIN
				add		edi,eax
				mov		ax,0A0Dh
				stosw
			.elseif eax<level
			  @@:
				mov		eax,val
				.if eax!=level
					dec		level
					invoke MnuSpc,level
					invoke SaveStr,edi,addr szEND
					add		edi,eax
					mov		ax,0A0Dh
					stosw
					jmp		@b
				.endif
			.endif
			add		esi,sizeof MNUITEM
			jmp		Nx
		.endif
	.endif
	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		eax,0A0Dh
	stosw
	stosd
	pop		eax
	ret
  MnExEx:
	pop		edi
	invoke GlobalUnlock,edi
	invoke GlobalFree,edi
	xor		eax,eax
	ret

ExportMenu endp

MnuGetFreeMem proc uses esi

	mov		esi,hMnuMem
	add		esi,sizeof MNUHEAD
	sub		esi,sizeof MNUITEM
  @@:
	add		esi,sizeof MNUITEM
	mov		eax,(MNUITEM ptr [esi]).itemflag
	.if eax==-1
		xor		eax,eax
	.endif
	or		eax,eax
	jne		@b
	mov		eax,esi
	ret

MnuGetFreeMem endp

MnuGetFreeID proc uses esi
	LOCAL	nId:DWORD

	mov		esi,hMnuMem
	m2m		nId,(MNUHEAD ptr [esi]).startid
	add		esi,sizeof MNUHEAD
	sub		esi,sizeof MNUITEM
  @@:
	add		esi,sizeof MNUITEM
	mov		eax,(MNUITEM ptr [esi]).itemflag
	cmp		eax,-1
	je		@b
	.if eax
		mov		eax,(MNUITEM ptr [esi]).itemid
		.if eax==nId
			inc		nId
			mov		esi,hMnuMem
			add		esi,sizeof MNUHEAD
			sub		esi,sizeof MNUITEM
		.endif
		jmp		@b
	.endif
	mov		eax,nId
	ret

MnuGetFreeID endp

MnuGetMem proc uses esi,hWin:HWND
	LOCAL	val:DWORD

	invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETCURSEL,0,0
	mov		nMnuInx,eax
	invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,nMnuInx,0
	.if !eax
		.if fMnuSel==FALSE
			invoke MnuGetFreeMem
			mov		esi,eax
			invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETITEMDATA,nMnuInx,esi
			mov		(MNUITEM ptr [esi]).itemflag,1
			invoke GetDlgItemText,hWin,IDC_EDTITEMCAPTION,addr (MNUITEM ptr [esi]).itemcaption,64
			invoke GetDlgItemText,hWin,IDC_EDTITEMNAME,addr (MNUITEM ptr [esi]).itemname,MaxName
			invoke GetDlgItemInt,hWin,IDC_EDTITEMID,addr val,FALSE
			m2m		(MNUITEM ptr [esi]).itemid,eax
			mov		eax,nMnuInx
			.if eax
				dec		eax
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,eax,0
				mov		eax,[eax].MNUITEM.level
				mov		[esi].MNUITEM.level,eax
			.endif
			invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETCOUNT,0,0
			.if eax
				dec		eax
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,eax,0
				.if eax
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_ADDSTRING,0,addr szNULL
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETITEMDATA,eax,0
				.endif
			.endif
			mov		eax,esi
		.endif
	.endif
	ret

MnuGetMem endp

MenuUpdateMem proc uses esi edi,hWin:HWND
	LOCAL	hMem:DWORD
	LOCAL	nInx:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MaxMem
	mov     hMem,eax
	invoke GlobalLock,hMem
	mov		esi,hMnuMem
	mov		edi,hMem
	mov		ecx,sizeof MNUHEAD
	rep movsb
	mov		nInx,0
  @@:
	invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,nInx,0
	.if eax!=LB_ERR
		.if eax
			mov		esi,eax
			mov		eax,(MNUITEM ptr [esi]).itemflag
			.if eax!=-1
				mov		ecx,sizeof MNUITEM
				rep movsb
			.endif
		.endif
		inc		nInx
		jmp		@b
	.endif
	mov		eax,hMem
	ret

MenuUpdateMem endp

MenuUpdate proc uses esi edi,hWin:HWND
	LOCAL	hMem:DWORD
	LOCAL	nInx:DWORD

	invoke MenuUpdateMem,hWin
	mov		hMem,eax
	mov		esi,hMem
	mov		edi,hMnuMem
	mov		ecx,MaxMem/4
	rep movsd
	invoke GlobalUnlock,hMem
	invoke GlobalFree,hMem
	mov		esi,hMnuMem
	lea		esi,[esi+sizeof MNUHEAD]
	mov		nInx,0
  @@:
	invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,nInx,0
	.if eax!=LB_ERR
		.if eax && eax!=-1
			invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETITEMDATA,nInx,esi
			lea		esi,[esi+sizeof MNUITEM]
		.endif
		inc		nInx
		jmp		@b
	.endif
	ret

MenuUpdate endp

HotProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM, lParam:LPARAM
	LOCAL	msg:MSG

	mov		eax,uMsg
	.if eax==WM_SETFOCUS
		invoke CallWindowProc,lpOldHotProc,hWin,uMsg,wParam,lParam
		mov		fHotFocus,TRUE
		.while fHotFocus
			invoke GetMessage,addr msg,NULL,0,0
		  .BREAK .if !eax
			invoke IsDialogMessage,hDialog,addr msg
			.if !eax
				invoke TranslateMessage,addr msg
				invoke DispatchMessage,addr msg
			.endif
		.endw
	.elseif eax==WM_KILLFOCUS
		mov		fHotFocus,FALSE
	.else
		invoke CallWindowProc,lpOldHotProc,hWin,uMsg,wParam,lParam
	.endif
	ret

HotProc endp

ItemNameEditProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM, lParam:LPARAM
	LOCAL	msg:MSG

	mov		eax,uMsg
	.if eax==WM_CHAR
		invoke IsCharAlphaNumeric,wParam
		mov		edx,wParam
		.if !eax && edx!='_' && edx!=VK_BACK && edx!=01h && edx!=03h && edx!=16h && edx!=1Ah
			xor		eax,eax
			jmp		Ex
		.endif
	.endif
	invoke CallWindowProc,lpOldNameEditProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ItemNameEditProc endp

DlgMnuPreviewProc proc uses esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM, lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke MakeMnuBar,lParam
		invoke SetMenu,hWin,eax
    .elseif eax==WM_CLOSE
		invoke GetMenu,hWin
		invoke DestroyMenu,eax
		invoke EndDialog,hWin,wParam
    .elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,FALSE,0
			.endif
		.endif
    .elseif eax==WM_SIZE
		invoke GetDlgItem,hWin,IDCANCEL
		mov		edx,lParam
		movzx	ecx,dx
		shr		edx,16
		sub		ecx,66
		sub		edx,23
		invoke MoveWindow,eax,ecx,edx,64,21,TRUE
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgMnuPreviewProc endp

DlgMenuEditProc proc uses esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM, lParam:LPARAM
	LOCAL	hCtl:DWORD
	LOCAL	buffer[64]:byte
	LOCAL	buffer1[256]:byte
	LOCAL	val:DWORD
	LOCAL	rect:RECT
	LOCAL	hMem:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,lParam
		mov		hMnuMem,eax
		invoke SendDlgItemMessage,hWin,IDC_EDTITEMCAPTION,EM_LIMITTEXT,63,0
		invoke SendDlgItemMessage,hWin,IDC_EDTITEMNAME,EM_LIMITTEXT,MaxName-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTITEMID,EM_LIMITTEXT,5,0
		invoke SendDlgItemMessage,hWin,IDC_EDTHELPID,EM_LIMITTEXT,5,0
		invoke GetDlgItem,hWin,IDC_BTNL
		mov		hCtl,eax
		invoke ImageList_GetIcon,hMnuIml,0,ILD_NORMAL
		invoke SendMessage,hCtl,BM_SETIMAGE,IMAGE_ICON,eax
		invoke GetDlgItem,hWin,IDC_BTNR
		mov		hCtl,eax
		invoke ImageList_GetIcon,hMnuIml,1,ILD_NORMAL
		invoke SendMessage,hCtl,BM_SETIMAGE,IMAGE_ICON,eax
		invoke GetDlgItem,hWin,IDC_BTNU
		mov		hCtl,eax
		invoke ImageList_GetIcon,hMnuIml,2,ILD_NORMAL
		invoke SendMessage,hCtl,BM_SETIMAGE,IMAGE_ICON,eax
		invoke GetDlgItem,hWin,IDC_BTND
		mov		hCtl,eax
		invoke ImageList_GetIcon,hMnuIml,3,ILD_NORMAL
		invoke SendMessage,hCtl,BM_SETIMAGE,IMAGE_ICON,eax
		mov		esi,hMnuMem
		invoke GetDlgItem,hWin,IDC_LSTMNU
		mov		hCtl,eax
		invoke SendMessage,hCtl,LB_SETTABSTOPS,6,addr MnuTabs
		add		esi,sizeof MNUHEAD
		mov		nMnuInx,0
	  @@:
		mov		eax,(MNUITEM ptr [esi]).itemflag
		.if eax
			invoke SendMessage,hCtl,LB_INSERTSTRING,nMnuInx,addr szNULL
			invoke SendMessage,hCtl,LB_SETITEMDATA,nMnuInx,esi
			invoke SendMessage,hCtl,LB_SETCURSEL,nMnuInx,0
			mov		eax,LBN_SELCHANGE
			shl		eax,16
			or		eax,IDC_LSTMNU
			invoke SendMessage,hWin,WM_COMMAND,eax,0
			add		esi,sizeof MNUITEM
			inc		nMnuInx
			jmp		@b
		.endif
		invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_ADDSTRING,0,addr szNULL
		invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETITEMDATA,eax,0
		;=================================
		; *** MOD 22.1.2012    width 800 pixel for HSCROLLBAR
		invoke SendDlgItemMessage, hWin, IDC_LSTMNU, LB_SETHORIZONTALEXTENT, 800, 0
        ; ================================  
        mov		nMnuInx,0
		invoke SendMessage,hCtl,LB_SETCURSEL,nMnuInx,0
		mov		eax,LBN_SELCHANGE
		shl		eax,16
		or		eax,IDC_LSTMNU
		invoke SendMessage,hWin,WM_COMMAND,eax,0
		mov		esi,hMnuMem
		mov		lpResType,offset szMENU
		lea		eax,[esi].MNUHEAD.menuname
		mov		lpResName,eax
		lea		eax,[esi].MNUHEAD.menuid
		mov		lpResID,eax
		lea		eax,[esi].MNUHEAD.startid
		mov		lpResStartID,eax
		lea		eax,[esi].MNUHEAD.lang
		mov		lpResLang,eax
		lea		eax,[esi].MNUHEAD.menuex
		mov		lpResMenuEx,eax
		invoke PropertyList,-7
		mov		 fNoScroll,TRUE
    	invoke ShowScrollBar,hDEd,SB_BOTH,FALSE
		invoke SendMessage,hWin,WM_SIZE,0,0
		mov		fDialogChanged,FALSE
		invoke GetDlgItem,hWin,IDC_HOTMENU
		invoke SetWindowLong,eax,GWL_WNDPROC,offset HotProc
		mov		lpOldHotProc,eax
		invoke GetDlgItem,hWin,IDC_EDTITEMNAME
		invoke SetWindowLong,eax,GWL_WNDPROC,offset ItemNameEditProc
		mov		lpOldNameEditProc,eax
    .elseif eax==WM_CLOSE
		mov		 fNoScroll,FALSE
    	invoke ShowScrollBar,hDEd,SB_BOTH,TRUE
		invoke DestroyWindow,hWin
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,FALSE,0
				invoke PropertyList,0
			.elseif eax==IDOK
				invoke GetWindowLong,hWin,GWL_USERDATA
				mov		esi,eax
				invoke GetProjectItemName,esi,addr buffer1
				invoke SetProjectItemName,esi,addr buffer1
				.if fDialogChanged
					mov		fDialogChanged,FALSE
					invoke MenuUpdate,hWin
					invoke SendMessage,hRes,PRO_SETMODIFY,TRUE,0
				.endif
			.elseif eax==IDC_BTNL
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					mov		eax,(MNUITEM ptr[esi]).level
					.if eax
						dec		(MNUITEM ptr[esi]).level
						invoke SendMessage,hWin,WM_COMMAND,(EN_CHANGE shl 16) or IDC_EDTITEMCAPTION,0
						mov		fDialogChanged,TRUE
					.endif
				.endif
			.elseif eax==IDC_BTNR
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					mov		eax,(MNUITEM ptr[esi]).level
					.if eax<5
						inc		(MNUITEM ptr[esi]).level
						invoke SendMessage,hWin,WM_COMMAND,(EN_CHANGE shl 16) or IDC_EDTITEMCAPTION,0
						mov		fDialogChanged,TRUE
					.endif
				.endif
			.elseif eax==IDC_BTNU
				.if nMnuInx
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,nMnuInx,0
					.if eax
						mov		esi,eax
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_DELETESTRING,nMnuInx,0
						dec		nMnuInx
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_INSERTSTRING,nMnuInx,addr szNULL
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETITEMDATA,nMnuInx,esi
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETCURSEL,nMnuInx,0
						invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTMNU,0
						mov		fDialogChanged,TRUE
					.endif
				.endif
			.elseif eax==IDC_BTND
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETCOUNT,0,0
				dec		eax
				.if eax!=nMnuInx
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,nMnuInx,0
					.if eax
						mov		esi,eax
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_DELETESTRING,nMnuInx,0
						inc		nMnuInx
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_INSERTSTRING,nMnuInx,addr szNULL
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETITEMDATA,nMnuInx,esi
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETCURSEL,nMnuInx,0
						invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTMNU,0
						mov		fDialogChanged,TRUE
					.endif
				.endif
			.elseif eax==IDC_BTNADD
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETCOUNT,0,0
				dec		eax
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETCURSEL,eax,0
				invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTMNU,0
				mov		fDialogChanged,TRUE
			.elseif eax==IDC_BTNINSERT
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETCURSEL,0,0
				mov		nMnuInx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,eax,0
				.if eax
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_INSERTSTRING,nMnuInx,addr szNULL
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETCURSEL,nMnuInx,0
					invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTMNU,0
					mov		fDialogChanged,TRUE
				.endif
			.elseif eax==IDC_BTNDELETE
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETCOUNT,0,0
				dec		eax
				.if eax!=nMnuInx
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,nMnuInx,0
					.if eax
						mov		esi,eax
						mov		(MNUITEM ptr [esi]).itemflag,-1
						mov		fDialogChanged,TRUE
					.endif
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_DELETESTRING,nMnuInx,0
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETCURSEL,nMnuInx,0
					.if eax!=LB_ERR
						invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTMNU,0
					.endif
				.endif
			.elseif eax==IDC_BTNMNUPREVIEW
				invoke MenuUpdateMem,hWin
				mov		hMem,eax
				invoke DialogBoxParam,hInstance,IDD_DLGMNUPREVIEW,hWin,addr DlgMnuPreviewProc,hMem
				invoke GlobalUnlock,hMem
				invoke GlobalFree,hMem
			.elseif eax==IDC_CHKCHECKED
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					and		(MNUITEM ptr [esi]).nstate,-1 xor MFS_CHECKED
					invoke SendDlgItemMessage,hWin,IDC_CHKCHECKED,BM_GETCHECK,0,0
					.if eax==BST_CHECKED
						or		(MNUITEM ptr [esi]).nstate,MFS_CHECKED
					.endif
					.if !fMnuSel
						mov		fDialogChanged,TRUE
					.endif
				.endif
			.elseif eax==IDC_CHKGRAYED
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					and		(MNUITEM ptr [esi]).nstate,-1 xor MFS_GRAYED
					invoke SendDlgItemMessage,hWin,IDC_CHKGRAYED,BM_GETCHECK,0,0
					.if eax==BST_CHECKED
						or		(MNUITEM ptr [esi]).nstate,MFS_GRAYED
					.endif
					.if !fMnuSel
						mov		fDialogChanged,TRUE
					.endif
				.endif
			.elseif eax==IDC_CHKRIGHTALIGN
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					and		(MNUITEM ptr [esi]).ntype,-1 xor MFT_RIGHTJUSTIFY
					invoke SendDlgItemMessage,hWin,IDC_CHKRIGHTALIGN,BM_GETCHECK,0,0
					.if eax==BST_CHECKED
						or		(MNUITEM ptr [esi]).ntype,MFT_RIGHTJUSTIFY
					.endif
					.if !fMnuSel
						mov		fDialogChanged,TRUE
					.endif
				.endif
			.elseif eax==IDC_CHKRADIO
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					and		(MNUITEM ptr [esi]).ntype,-1 xor MFT_RADIOCHECK
					invoke SendDlgItemMessage,hWin,IDC_CHKRADIO,BM_GETCHECK,0,0
					.if eax==BST_CHECKED
						or		(MNUITEM ptr [esi]).ntype,MFT_RADIOCHECK
					.endif
					.if !fMnuSel
						mov		fDialogChanged,TRUE
					.endif
				.endif
			.elseif eax==IDC_CHKOWNERDRAW
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					and		(MNUITEM ptr [esi]).ntype,-1 xor MFT_OWNERDRAW
					invoke SendDlgItemMessage,hWin,IDC_CHKOWNERDRAW,BM_GETCHECK,0,0
					.if eax==BST_CHECKED
						or		(MNUITEM ptr [esi]).ntype,MFT_OWNERDRAW
					.endif
				.endif
				.if !fMnuSel
					mov		fDialogChanged,TRUE
				.endif
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTITEMCAPTION
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					invoke GetDlgItemText,hWin,IDC_EDTITEMCAPTION,addr buffer,64
					invoke strcpy,addr (MNUITEM ptr [esi]).itemcaption,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_DELETESTRING,nMnuInx,0
					lea		edi,buffer1
					mov		ecx,(MNUITEM ptr [esi]).level
					.if ecx
						mov     al,'<'
						mov		ah,'>'         ; *** MOD 21.1.2012
					  @@:
						stosw
						;stosb
						loop	@b
					.endif
					invoke strcpy,edi,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_HOTMENU,HKM_GETHOTKEY,0,0
					.if al
						mov		word ptr buffer,VK_TAB
						mov		edx,eax
						invoke MnuSaveAccel,edx,addr buffer[1]
						invoke strcat,addr buffer1,addr buffer
					.endif
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_INSERTSTRING,nMnuInx,addr buffer1
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETITEMDATA,nMnuInx,esi
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETCURSEL,nMnuInx,0
					.if !fMnuSel
						mov		fDialogChanged,TRUE
					.endif
				.endif
			.elseif eax==IDC_EDTITEMNAME
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					invoke GetDlgItemText,hWin,IDC_EDTITEMNAME,addr (MNUITEM ptr [esi]).itemname,MaxName
					.if !fMnuSel
						mov		fDialogChanged,TRUE
					.endif
				.endif
			.elseif eax==IDC_EDTITEMID
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					invoke GetDlgItemInt,hWin,IDC_EDTITEMID,addr val,FALSE
					mov		(MNUITEM ptr [esi]).itemid,eax
					.if !fMnuSel
						mov		fDialogChanged,TRUE
					.endif
				.endif
			.elseif eax==IDC_EDTHELPID
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					invoke GetDlgItemInt,hWin,IDC_EDTHELPID,addr val,FALSE
					mov		(MNUITEM ptr [esi]).helpid,eax
					.if !fMnuSel
						mov		fDialogChanged,TRUE
					.endif
				.endif
			.elseif eax==IDC_HOTMENU
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					invoke SendDlgItemMessage,hWin,IDC_HOTMENU,HKM_GETHOTKEY,0,0
					mov		(MNUITEM ptr [esi]).shortcut,eax
					invoke SendMessage,hWin,WM_COMMAND,(EN_CHANGE shl 16) or IDC_EDTITEMCAPTION,0
					.if !fMnuSel
						mov		fDialogChanged,TRUE
					.endif
				.endif
			.endif
		.elseif edx==LBN_SELCHANGE
			.if eax==IDC_LSTMNU
				mov		fMnuSel,TRUE
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETCURSEL,0,0
				mov		nMnuInx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,nMnuInx,0
				.if !eax
					invoke SendDlgItemMessage,hWin,IDC_HOTMENU,HKM_SETHOTKEY,0,0
					invoke SetDlgItemText,hWin,IDC_EDTITEMCAPTION,addr szNULL
					invoke SetDlgItemText,hWin,IDC_EDTITEMNAME,addr szMnuItemName
					invoke MnuGetFreeID
					invoke SetDlgItemInt,hWin,IDC_EDTITEMID,eax,FALSE
					invoke SetDlgItemInt,hWin,IDC_EDTHELPID,0,FALSE
					invoke SendDlgItemMessage,hWin,IDC_CHKCHECKED,BM_SETCHECK,BST_UNCHECKED,0
					invoke SendDlgItemMessage,hWin,IDC_CHKGRAYED,BM_SETCHECK,BST_UNCHECKED,0
					invoke SendDlgItemMessage,hWin,IDC_CHKRIGHTALIGN,BM_SETCHECK,BST_UNCHECKED,0
					invoke SendDlgItemMessage,hWin,IDC_CHKRADIO,BM_SETCHECK,BST_UNCHECKED,0
					invoke SendDlgItemMessage,hWin,IDC_CHKOWNERDRAW,BM_SETCHECK,BST_UNCHECKED,0
				.else
					mov		esi,eax
					invoke SendDlgItemMessage,hWin,IDC_HOTMENU,HKM_SETHOTKEY,(MNUITEM ptr [esi]).shortcut,0
					invoke SetDlgItemText,hWin,IDC_EDTITEMCAPTION,addr (MNUITEM ptr [esi]).itemcaption
					invoke SetDlgItemText,hWin,IDC_EDTITEMNAME,addr (MNUITEM ptr [esi]).itemname
					invoke SetDlgItemInt,hWin,IDC_EDTITEMID,(MNUITEM ptr [esi]).itemid,FALSE
					invoke SetDlgItemInt,hWin,IDC_EDTHELPID,(MNUITEM ptr [esi]).helpid,FALSE
					mov		eax,(MNUITEM ptr [esi]).nstate
					and		eax,MFS_CHECKED
					.if eax==MFS_CHECKED
						mov		eax,BST_CHECKED
					.else
						mov		eax,BST_UNCHECKED
					.endif
					invoke SendDlgItemMessage,hWin,IDC_CHKCHECKED,BM_SETCHECK,eax,0
					mov		eax,(MNUITEM ptr [esi]).nstate
					and		eax,MFS_GRAYED
					.if eax==MFS_GRAYED
						mov		eax,BST_CHECKED
					.else
						mov		eax,BST_UNCHECKED
					.endif
					invoke SendDlgItemMessage,hWin,IDC_CHKGRAYED,BM_SETCHECK,eax,0
					mov		eax,(MNUITEM ptr [esi]).ntype
					and		eax,MFT_RIGHTJUSTIFY
					.if eax==MFT_RIGHTJUSTIFY
						mov		eax,BST_CHECKED
					.else
						mov		eax,BST_UNCHECKED
					.endif
					invoke SendDlgItemMessage,hWin,IDC_CHKRIGHTALIGN,BM_SETCHECK,eax,0
					mov		eax,(MNUITEM ptr [esi]).ntype
					and		eax,MFT_RADIOCHECK
					.if eax==MFT_RADIOCHECK
						mov		eax,BST_CHECKED
					.else
						mov		eax,BST_UNCHECKED
					.endif
					invoke SendDlgItemMessage,hWin,IDC_CHKRADIO,BM_SETCHECK,eax,0
					mov		eax,(MNUITEM ptr [esi]).ntype
					and		eax,MFT_OWNERDRAW
					.if eax==MFT_OWNERDRAW
						mov		eax,BST_CHECKED
					.else
						mov		eax,BST_UNCHECKED
					.endif
					invoke SendDlgItemMessage,hWin,IDC_CHKOWNERDRAW,BM_SETCHECK,eax,0
				.endif
 				mov		fMnuSel,FALSE
			.endif
		.endif
	.elseif eax==WM_SIZE
		invoke SendMessage,hDEd,WM_VSCROLL,SB_THUMBTRACK,0
		invoke SendMessage,hDEd,WM_HSCROLL,SB_THUMBTRACK,0
		invoke GetClientRect,hDEd,addr rect
		mov		rect.left,3
		mov		rect.top,3
		sub		rect.right,6
		sub		rect.bottom,6
		invoke MoveWindow,hWin,rect.left,rect.top,rect.right,rect.bottom,TRUE
; MOD 22.1.2012 =============================
;		invoke GetClientRect,hWin,addr rect
;		invoke GetDlgItem,hWin,IDC_LSTMNU
;		mov		hCtl,eax
;		mov		rect.left,12                     ; move doesnt work
;		mov		rect.top,170
;		mov		rect.right,305
;		sub		rect.bottom,170+12
;		invoke MoveWindow,hCtl,rect.left,rect.top,rect.right,rect.bottom,TRUE 
; ===========================================
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgMenuEditProc endp

CreateMnu proc uses ebx esi edi,hWin:HWND,lpProItemMem:DWORD

	mov		eax,lpProItemMem
	.if !eax
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MaxMem
		mov     esi,eax
		invoke GlobalLock,esi
		invoke strcpy,addr (MNUHEAD ptr [esi]).menuname,addr szMnuName
		invoke GetUnikeName,addr (MNUHEAD ptr [esi]).menuname
		invoke GetFreeProjectitemID,TPE_MENU
		mov		(MNUHEAD ptr [esi]).menuid,eax
		inc		eax
		mov		(MNUHEAD ptr [esi]).startid,eax
		invoke CreateDialogParam,hInstance,IDD_DLGMENUEDIT,hWin,addr DlgMenuEditProc,esi
		mov		hDialog,eax
		mov		fDialogChanged,TRUE
		mov		eax,esi
	.else
		mov		esi,lpProItemMem
		mov		esi,[esi].PROJECT.hmem
		invoke CreateDialogParam,hInstance,IDD_DLGMENUEDIT,hWin,addr DlgMenuEditProc,esi
		mov		hDialog,eax
		invoke SetWindowLong,hDialog,GWL_USERDATA,lpProItemMem
		mov		eax,esi
	.endif
	ret

CreateMnu endp

