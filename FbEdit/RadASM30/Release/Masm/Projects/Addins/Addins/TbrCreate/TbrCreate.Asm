;#########################################################################
;Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;Include file

include TbrCreate.inc

;#########################################################################
;Code

.code

;UpdateMenu proc hMnu:HMENU
;	LOCAL	mii:MENUITEMINFO
;
;	mov		mii.cbSize,sizeof MENUITEMINFO
;	mov		mii.fMask,MIIM_ID or MIIM_TYPE
;	mov		mii.fType,MFT_STRING
;	mov		eax,MenuIDAddin
;	mov		mii.wID,eax
;	mov		mii.dwTypeData,offset szMenuItem
;	invoke InsertMenuItem,hMnu,IDM_FILE_NEW,FALSE,addr mii
;	ret
;
;UpdateMenu endp
;
OutputString proc uses ebx,lpString:DWORD

	mov		ebx,lpProc
	push	0
	call	[ebx].ADDINPROCS.lpSetOutputTab
	push	TRUE
	call	[ebx].ADDINPROCS.lpShowOutput
	push	lpString
	call	[ebx].ADDINPROCS.lpTextOutput
	ret

OutputString endp

ShowToolbar proc hWin:HWND
	LOCAL	hTbr:HWND
	LOCAL	tbb:TBBUTTON
	LOCAL	nInx:DWORD
	LOCAL	buff[32]:BYTE
	LOCAL	nval:DWORD

	invoke GetDlgItem,hWin,IDC_TBR1
	mov		hTbr,eax
  @@:
	invoke SendMessage,hTbr,TB_BUTTONCOUNT,0,0
	.if eax
		invoke SendMessage,hTbr,TB_DELETEBUTTON,0,0
		jmp		@b
	.endif
	mov		nInx,0
	.while TRUE
		invoke RtlZeroMemory,addr tbb,sizeof TBBUTTON
		invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETTEXT,nInx,addr buff
		.break .if eax==LB_ERR
		invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETITEMDATA,nInx,0
		mov		nval,eax
		.if buff=='-'
			mov		tbb.iBitmap,0
			mov		tbb.idCommand,0
			mov		tbb.fsStyle,TBSTYLE_SEP
		.else
			mov		eax,nval
			shr		eax,16
			and		eax,0FFh
			mov		tbb.iBitmap,eax
			mov		eax,nInx
			lea		eax,[eax+4000]
			mov		tbb.idCommand,eax
			mov		tbb.fsState,TBSTATE_ENABLED
			mov		tbb.fsStyle,0
			mov		eax,nval
			shr		eax,24
			test	eax,1
			.if !ZERO?
				or		tbb.fsStyle,TBSTYLE_CHECK
			.endif
			test	eax,2
			.if !ZERO?
				or		tbb.fsStyle,TBSTYLE_GROUP
			.endif
		.endif
		invoke SendMessage,hTbr,TB_ADDBUTTONS,1,addr tbb
		inc		nInx
	.endw
	ret

ShowToolbar endp

SetImageList proc uses ebx,hWin:HWND
	LOCAL	hBmp:HBITMAP
	LOCAL	hTbr1:HWND
	LOCAL	hTbr2:HWND
	LOCAL	tbab:TBADDBITMAP

	invoke GetDlgItem,hWin,IDC_HMEM
	invoke GetWindowLong,eax,GWL_USERDATA
	mov		ebx,eax
	invoke GetDlgItem,hWin,IDC_TBR1
	mov		hTbr1,eax
	invoke GetDlgItem,hWin,IDC_STCBTN
	invoke GetDlgItem,eax,IDC_TBR2
	mov		hTbr2,eax
	invoke SendMessage,hTbr1,TB_SETIMAGELIST,0,NULL
	invoke SendMessage,hTbr2,TB_SETIMAGELIST,0,NULL
	.if [ebx].TBRMEM.tbrdef.hIml
		invoke ImageList_Destroy,[ebx].TBRMEM.tbrdef.hIml
	.endif
	invoke ImageList_Create,[ebx].TBRMEM.tbr.nBtnSize,[ebx].TBRMEM.tbr.nBtnSize,ILC_COLOR24 or ILC_MASK,80,0
	mov		[ebx].TBRMEM.tbrdef.hIml,eax
	.if [ebx].TBRMEM.tbr.szBmpFile
		invoke LoadImage,0,addr [ebx].TBRMEM.tbr.szBmpFile,IMAGE_BITMAP,0,0,LR_LOADFROMFILE or LR_LOADMAP3DCOLORS
		push	eax
		invoke ImageList_AddMasked,[ebx].TBRMEM.tbrdef.hIml,eax,0C0C0C0h
		pop		eax
		invoke DeleteObject,eax
	.else
		mov		tbab.hInst,HINST_COMMCTRL
		mov		tbab.nID,IDB_STD_SMALL_COLOR
		invoke SendMessage,hTbr1,TB_ADDBITMAP,15,addr tbab
		invoke SendMessage,hTbr1,TB_GETIMAGELIST,0,0
		mov		[ebx].TBRMEM.tbrdef.hIml,eax
	.endif
	invoke SendMessage,hTbr1,TB_SETIMAGELIST,0,[ebx].TBRMEM.tbrdef.hIml
	invoke SendMessage,hTbr2,TB_SETIMAGELIST,0,[ebx].TBRMEM.tbrdef.hIml
	invoke SendMessage,hTbr1,TB_AUTOSIZE,0,0
	invoke SendMessage,hTbr2,TB_AUTOSIZE,0,0
	ret

SetImageList endp

NewToolbar proc uses ebx,hWin:HWND
	LOCAL	hMem:HGLOBAL
	LOCAL	hTbr:HWND
	LOCAL	tbs:DWORD

	invoke GetDlgItem,hWin,IDC_HMEM
	invoke GetWindowLong,eax,GWL_USERDATA
	mov		ebx,eax
	invoke GetDlgItem,hWin,IDC_TBR1
	mov		hTbr,eax
	mov		tbs,WS_CHILD or WS_VISIBLE
	test	[ebx].TBRMEM.tbr.nStyle,1
	.if !ZERO?
		or		tbs,TBSTYLE_FLAT
	.endif
	test	[ebx].TBRMEM.tbr.nStyle,2
	.if !ZERO?
		or		tbs,TBSTYLE_WRAPABLE
	.endif
	test	[ebx].TBRMEM.tbr.nStyle,4
	.if !ZERO?
		or		tbs,CCS_NODIVIDER
	.endif
	test	[ebx].TBRMEM.tbr.nStyle,8
	.if !ZERO?
		or		tbs,TBSTYLE_TOOLTIPS
	.endif
	test	[ebx].TBRMEM.tbr.nStyle,16
	.if !ZERO?
		or		tbs,TBSTYLE_LIST
	.endif
	invoke DestroyWindow,hTbr
	invoke CreateWindowEx,0,offset szToolbarWindow32,0,tbs,0,0,0,0,hWin,IDC_TBR1,hInstance,0
	mov		hTbr,eax
	invoke SetImageList,hWin
	invoke ShowToolbar,hWin
	ret

NewToolbar endp

NotifyParent proc uses ebx,hWin:HWND
	LOCAL	nmhdr:NMHDR

	mov		nmhdr.idFrom,ID_EDITUSER
	mov		nmhdr.code,EN_SELCHANGE
	invoke GetParent,hWin
	mov		nmhdr.hwndFrom,eax
	invoke GetParent,eax
	mov		edx,eax
	invoke SendMessage,edx,WM_NOTIFY,ID_EDITUSER,addr nmhdr
	ret

NotifyParent endp

SaveToolbar proc uses ebx esi edi,hWin:HWND
	LOCAL	hFile:HANDLE
	LOCAL	nSize:DWORD
	LOCAL	nval:DWORD

	invoke GetDlgItem,hWin,IDC_HMEM
	invoke GetWindowLong,eax,GWL_USERDATA
	mov		ebx,eax
	invoke CreateFile,addr [ebx].TBRMEM.tbrdef.FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	mov		hFile,eax
	.if hFile!=INVALID_HANDLE_VALUE
		xor		edi,edi
		.while edi<[ebx].TBRMEM.tbr.nBtn
			mov		eax,sizeof TBRBTN
			mul		edi
			invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETTEXT,edi,addr [ebx].TBRMEM.tbrbtn.szBtnName[eax]
			invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETITEMDATA,edi,0
			mov		nval,eax
			mov		eax,sizeof TBRBTN
			mul		edi
			mov		edx,eax
			mov		eax,nval
			and		eax,0FFFFh
			mov		[ebx].TBRMEM.tbrbtn[edx].nBtnID,eax
			mov		eax,nval
			shr		eax,16
			and		eax,0FFh
			mov		[ebx].TBRMEM.tbrbtn[edx].nBmp,eax
			mov		eax,nval
			shr		eax,24
			mov		[ebx].TBRMEM.tbrbtn[edx].nStyle,eax
			inc		edi
		.endw
		mov		eax,sizeof TBRBTN
		mul		edi
		lea		edx,[eax+sizeof TBR]
		lea		ecx,[ebx+sizeof TBRDEF]
		invoke WriteFile,hFile,ecx,edx,addr nSize,NULL
		invoke CloseHandle,hFile
		mov		[ebx].TBRMEM.tbrdef.fChanged,FALSE
		invoke NotifyParent,hWin
	.endif
	ret

SaveToolbar endp

ExportToolbar proc uses ebx esi edi,hWin:HWND
	LOCAL	szLine[1024]:BYTE
	LOCAL	szSTYLE[256]:BYTE
	LOCAL	nval:DWORD
	LOCAL	ffirst:DWORD

	mov		ebx,lpProc
	push	0
	call	[ebx].ADDINPROCS.lpSetOutputTab
	push	TRUE
	call	[ebx].ADDINPROCS.lpShowOutput
	mov		eax,lpHandles
	invoke SendMessage,[eax].ADDINHANDLES.hOutput,WM_SETTEXT,0,0
	invoke GetDlgItem,hWin,IDC_HMEM
	invoke GetWindowLong,eax,GWL_USERDATA
	mov		ebx,eax
	xor		edi,edi
	.while edi<[ebx].TBRMEM.tbr.nBtn
		mov		eax,sizeof TBRBTN
		mul		edi
		invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETTEXT,edi,addr [ebx].TBRMEM.tbrbtn.szBtnName[eax]
		invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETITEMDATA,edi,0
		mov		nval,eax
		mov		eax,sizeof TBRBTN
		mul		edi
		mov		edx,eax
		mov		eax,nval
		and		eax,0FFFFh
		mov		[ebx].TBRMEM.tbrbtn[edx].nBtnID,eax
		mov		eax,nval
		shr		eax,16
		and		eax,0FFh
		mov		[ebx].TBRMEM.tbrbtn[edx].nBmp,eax
		mov		eax,nval
		shr		eax,24
		mov		[ebx].TBRMEM.tbrbtn[edx].nStyle,eax
		inc		edi
	.endw
	mov		edx,offset szCONST
	call	TextOutput
	mov		ffirst,TRUE
	xor		edi,edi
	.while edi<[ebx].TBRMEM.tbr.nBtn
		mov		eax,sizeof TBRBTN
		mul		edi
		lea		esi,[ebx].TBRMEM.tbrbtn[eax]
		.if [esi].TBRBTN.szBtnName=='-'
			;Separator
			.if ffirst
				mov		ffirst,FALSE
				mov		edx,offset szSEPARATOR+1
				call	TextOutput
			.else
				mov		ffirst,FALSE
				mov		edx,offset szSEPARATOR
				call	TextOutput
			.endif
		.else
			;Button
			invoke lstrcpy,addr szSTYLE,offset szTBSTYLE_BUTTON
			test	[esi].TBRBTN.nStyle,1
			.if !ZERO?
				invoke lstrcat,addr szSTYLE,offset szTBSTYLE_CHECK
			.endif
			test	[esi].TBRBTN.nStyle,2
			.if !ZERO?
				invoke lstrcat,addr szSTYLE,offset szTBSTYLE_GROUP
			.endif
			.if ffirst
				mov		ffirst,FALSE
				invoke wsprintf,addr szLine,offset szTBBUTTON+1,[esi].TBRBTN.nBmp,addr [esi].TBRBTN.szBtnName,offset szTBSTATE_ENABLED,addr szSTYLE
			.else
				invoke wsprintf,addr szLine,offset szTBBUTTON,[esi].TBRBTN.nBmp,addr [esi].TBRBTN.szBtnName,offset szTBSTATE_ENABLED,addr szSTYLE
			.endif
			lea		edx,szLine
			call	TextOutput
		.endif
		inc		edi
	.endw
	invoke wsprintf,addr szLine,offset szNBTNS,[ebx].TBRMEM.tbr.nBtn
	lea		edx,szLine
	call	TextOutput
	invoke wsprintf,addr szLine,offset szCODE,addr [ebx].TBRMEM.tbr.szBmpName,[ebx].TBRMEM.tbr.nBmp
	lea		edx,szLine
	call	TextOutput
	ret

TextOutput:
	mov		eax,lpHandles
	invoke SendMessage,[eax].ADDINHANDLES.hOutput,EM_REPLACESEL,FALSE,edx
	retn

ExportToolbar endp

TbrCreateProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hTbr:HWND
	LOCAL	tbb:TBBUTTON
	LOCAL	hFile:HANDLE
	LOCAL	nSize:DWORD
	LOCAL	buff[MAX_PATH]:BYTE
	LOCAL	nval:DWORD
	LOCAL	ofn:OPENFILENAME

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_HMEM
		invoke SetWindowLong,eax,GWL_USERDATA,lParam
		invoke SetWindowLong,hWin,GWL_ID,ID_EDITUSER
		invoke SendDlgItemMessage,hWin,IDC_EDTTBRNAME,EM_LIMITTEXT,31,0
		invoke SendDlgItemMessage,hWin,IDC_EDTTBRID,EM_LIMITTEXT,5,0
		invoke SendDlgItemMessage,hWin,IDC_EDTBTNNAME,EM_LIMITTEXT,31,0
		invoke SendDlgItemMessage,hWin,IDC_EDTBTNID,EM_LIMITTEXT,5,0
		invoke SendDlgItemMessage,hWin,IDC_EDTBMPNAME,EM_LIMITTEXT,31,0
		invoke SendDlgItemMessage,hWin,IDC_EDTBMPNBR,EM_LIMITTEXT,2,0
		invoke GetDlgItem,hWin,IDC_TBR2
		mov		hTbr,eax
		invoke SendMessage,hTbr,TB_BUTTONSTRUCTSIZE,SizeOf TBBUTTON,0
		invoke GetDlgItem,hWin,IDC_STCBTN
		invoke SetParent,hTbr,eax
		xor		ebx,ebx
		.while ebx<80
			lea		eax,[ebx+3000]
			mov		tbb.idCommand,eax
			mov		tbb.iBitmap,ebx
			mov		tbb.fsState,TBSTATE_ENABLED
			invoke SendMessage,hTbr,TB_ADDBUTTONS,1,addr tbb
			inc		ebx
		.endw
		invoke SendMessage,hTbr,TB_AUTOSIZE,0,0
		mov		ebx,lParam
		invoke CreateFile,addr [ebx].TBRMEM.tbrdef.FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke ReadFile,hFile,addr [ebx+sizeof TBRDEF],sizeof TBRMEM-sizeof TBRDEF,addr nSize,NULL
			invoke CloseHandle,hFile
		.endif
		invoke SendDlgItemMessage,hWin,IDC_UDNSIZE,UDM_SETRANGE,0,00100030h							; Set range
		invoke SendDlgItemMessage,hWin,IDC_UDNSIZE,UDM_SETPOS,0,[ebx].TBRMEM.tbr.nBtnSize			; Set default value
		invoke SetDlgItemText,hWin,IDC_EDTTBRNAME,addr [ebx].TBRMEM.tbr.szTbrName
		invoke SetDlgItemInt,hWin,IDC_EDTTBRID,addr [ebx].TBRMEM.tbr.nTbrID,FALSE
		.If [ebx].TBRMEM.tbr.szBmpName
			invoke SetDlgItemText,hWin,IDC_EDTBMPNAME,addr [ebx].TBRMEM.tbr.szBmpName
			invoke SetDlgItemInt,hWin,IDC_EDTBMPNBR,[ebx].TBRMEM.tbr.nBmp,FALSE
		.Else
			invoke SetDlgItemText,hWin,IDC_EDTBMPNAME,addr szSTD
			invoke SetDlgItemInt,hWin,IDC_EDTBMPNBR,15,FALSE
		.EndIf
		.if [ebx].TBRMEM.tbr.nBtnSize<16
			mov		[ebx].TBRMEM.tbr.nBtnSize,16
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTBMPFILE,addr [ebx].TBRMEM.tbr.szBmpFile
		invoke SetImageList,hWin
		test	[ebx].TBRMEM.tbr.nStyle,1
		.if !ZERO?
			invoke CheckDlgButton,hWin,IDC_CHKTBRFLAT,BST_CHECKED
		.endif
		test	[ebx].TBRMEM.tbr.nStyle,2
		.if !ZERO?
			invoke CheckDlgButton,hWin,IDC_CHKTBRWRAP,BST_CHECKED
		.endif
		test	[ebx].TBRMEM.tbr.nStyle,4
		.if !ZERO?
			invoke CheckDlgButton,hWin,IDC_CHKTBRDIVIDER,BST_CHECKED
		.endif
		test	[ebx].TBRMEM.tbr.nStyle,8
		.if !ZERO?
			invoke CheckDlgButton,hWin,IDC_CHKTBRTIP,BST_CHECKED
		.endif
		test	[ebx].TBRMEM.tbr.nStyle,16
		.if !ZERO?
			invoke CheckDlgButton,hWin,IDC_CHKTBRLIST,BST_CHECKED
		.endif
		xor		edi,edi
		.while edi<[ebx].TBRMEM.tbr.nBtn
			mov		eax,sizeof TBRBTN
			mul		edi
			lea		edx,[ebx].TBRMEM.tbrbtn[eax]
			push	edx
			invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_ADDSTRING,0,addr [edx].TBRBTN.szBtnName
			pop		edx
			mov		ecx,[edx].TBRBTN.nStyle
			shl		ecx,8
			or		ecx,[edx].TBRBTN.nBmp
			shl		ecx,16
			or		ecx,[edx].TBRBTN.nBtnID
			invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETITEMDATA,eax,ecx
			inc		edi
		.endw
		invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETCURSEL,0,0
		invoke SendMessage,hWin,WM_COMMAND,LBN_SELCHANGE shl 16 or IDC_LSTBTN,0
		mov		edi,lpHandles
		invoke ImageList_GetIcon,[edi].ADDINHANDLES.hMnuIml,2,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNUP,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,[edi].ADDINHANDLES.hMnuIml,3,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNDN,BM_SETIMAGE,IMAGE_ICON,eax
		invoke NewToolbar,hWin
		mov		[ebx].TBRMEM.tbrdef.fChanged,FALSE
	.elseif eax==WM_COMMAND
		invoke GetDlgItem,hWin,IDC_HMEM
		invoke GetWindowLong,eax,GWL_USERDATA
		mov		ebx,eax
		.if ebx
			mov		edx,wParam
			movzx	eax,dx
			shr		edx,16
			.if edx==BN_CLICKED
				.if eax==IDC_BTNEXPORT
					invoke ExportToolbar,hWin
				.elseif eax==IDC_BTNUP
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETCURSEL,0,0
					mov		edi,eax
					.if edi>0
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETITEMDATA,edi,0
						mov		nval,eax
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETTEXT,edi,addr buff
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_DELETESTRING,edi,0
						dec		edi
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_INSERTSTRING,edi,addr buff
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETITEMDATA,edi,nval
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETCURSEL,edi,0
						invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTBTN,0
						invoke ShowToolbar,hWin
						mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
						invoke NotifyParent,hWin
					.endif
				.elseif eax==IDC_BTNDN
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETCURSEL,0,0
					mov		edi,eax
					.if edi!=LB_ERR
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETCOUNT,0,0
						dec		eax
						.if edi<eax
							invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETITEMDATA,edi,0
							mov		nval,eax
							invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETTEXT,edi,addr buff
							invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_DELETESTRING,edi,0
							inc		edi
							invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_INSERTSTRING,edi,addr buff
							invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETITEMDATA,edi,nval
							invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETCURSEL,edi,0
							invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTBTN,0
							invoke ShowToolbar,hWin
							mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
							invoke NotifyParent,hWin
						.endif
					.endif
				.elseif eax==IDC_BTNADDBTN
					invoke lstrcpy,addr buff,offset szIDC_TBB
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_ADDSTRING,0,addr buff
					mov		edi,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETCURSEL,edi,0
					invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTBTN,0
					inc		[ebx].TBRMEM.tbr.nBtn
					invoke ShowToolbar,hWin
					mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
					invoke NotifyParent,hWin
				.elseif eax==IDC_BTNINSBTN
					invoke lstrcpy,addr buff,offset szIDC_TBB
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETCURSEL,0,0
					mov		edi,eax
					.if edi!=LB_ERR
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_INSERTSTRING,edi,addr buff
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETCURSEL,edi,0
						invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTBTN,0
						inc		[ebx].TBRMEM.tbr.nBtn
						invoke ShowToolbar,hWin
						mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
						invoke NotifyParent,hWin
					.endif
				.elseif eax==IDC_BTNADDSEP
					invoke lstrcpy,addr buff,offset szSEP
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_ADDSTRING,0,addr buff
					mov		edi,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETCURSEL,edi,0
					invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTBTN,0
					inc		[ebx].TBRMEM.tbr.nBtn
					invoke ShowToolbar,hWin
					mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
					invoke NotifyParent,hWin
				.elseif eax==IDC_BTNINSSEP
					invoke lstrcpy,addr buff,offset szSEP
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETCURSEL,0,0
					mov		edi,eax
					.if edi!=LB_ERR
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_INSERTSTRING,edi,addr buff
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETCURSEL,edi,0
						invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTBTN,0
						inc		[ebx].TBRMEM.tbr.nBtn
						invoke ShowToolbar,hWin
						mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
						invoke NotifyParent,hWin
					.endif
				.elseif eax==IDC_BTNDEL
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETCURSEL,0,0
					mov		edi,eax
					.if edi!=LB_ERR
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_DELETESTRING,edi,0
						dec		[ebx].TBRMEM.tbr.nBtn
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETCURSEL,edi,0
						.if eax==LB_ERR
							invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETCURSEL,addr [edi-1],0
						.endif
						invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTBTN,0
						invoke ShowToolbar,hWin
						mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
						invoke NotifyParent,hWin
					.endif
				.elseif eax==IDC_CHKTBRFLAT
					invoke IsDlgButtonChecked,hWin,IDC_CHKTBRFLAT
					.if eax
						mov		eax,1
					.endif
					mov		edx,[ebx].TBRMEM.tbr.nStyle
					and		edx,-1 xor 1
					or		edx,eax
					mov		[ebx].TBRMEM.tbr.nStyle,edx
					invoke NewToolbar,hWin
					mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
					invoke NotifyParent,hWin
				.elseif eax==IDC_CHKTBRWRAP
					invoke IsDlgButtonChecked,hWin,IDC_CHKTBRWRAP
					.if eax
						mov		eax,2
					.endif
					mov		edx,[ebx].TBRMEM.tbr.nStyle
					and		edx,-1 xor 2
					or		edx,eax
					mov		[ebx].TBRMEM.tbr.nStyle,edx
					invoke NewToolbar,hWin
					mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
					invoke NotifyParent,hWin
				.elseif eax==IDC_CHKTBRDIVIDER
					invoke IsDlgButtonChecked,hWin,IDC_CHKTBRDIVIDER
					.if eax
						mov		eax,4
					.endif
					mov		edx,[ebx].TBRMEM.tbr.nStyle
					and		edx,-1 xor 4
					or		edx,eax
					mov		[ebx].TBRMEM.tbr.nStyle,edx
					invoke NewToolbar,hWin
					mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
					invoke NotifyParent,hWin
				.elseif eax==IDC_CHKTBRTIP
					invoke IsDlgButtonChecked,hWin,IDC_CHKTBRTIP
					.if eax
						mov		eax,8
					.endif
					mov		edx,[ebx].TBRMEM.tbr.nStyle
					and		edx,-1 xor 8
					or		edx,eax
					mov		[ebx].TBRMEM.tbr.nStyle,edx
					invoke NewToolbar,hWin
					mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
					invoke NotifyParent,hWin
				.elseif eax==IDC_CHKTBRLIST
					invoke IsDlgButtonChecked,hWin,IDC_CHKTBRLIST
					.if eax
						mov		eax,16
					.endif
					mov		edx,[ebx].TBRMEM.tbr.nStyle
					and		edx,-1 xor 16
					or		edx,eax
					mov		[ebx].TBRMEM.tbr.nStyle,edx
					invoke NewToolbar,hWin
					mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
					invoke NotifyParent,hWin
				.elseif eax==IDC_CHKBTNCHECK
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETCURSEL,0,0
					mov		edi,eax
					.if edi!=LB_ERR
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETITEMDATA,edi,0
						mov		nval,eax
						and		nval,-1 xor 1 shl 24
						invoke IsDlgButtonChecked,hWin,IDC_CHKBTNCHECK
						.if eax
							or		nval,1 shl 24
						.endif
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETITEMDATA,edi,nval
						invoke ShowToolbar,hWin
						mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
						invoke NotifyParent,hWin
					.endif
				.elseif eax==IDC_CHKBTNGROUP
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETCURSEL,0,0
					mov		edi,eax
					.if edi!=LB_ERR
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETITEMDATA,edi,0
						mov		nval,eax
						and		nval,-1 xor 1 shl 25
						invoke IsDlgButtonChecked,hWin,IDC_CHKBTNGROUP
						.if eax
							or		nval,1 shl 25
						.endif
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETITEMDATA,edi,nval
						invoke ShowToolbar,hWin
						mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
						invoke NotifyParent,hWin
					.endif
				.elseif eax==IDC_BTNBMP
					invoke RtlZeroMemory,addr ofn,sizeof OPENFILENAME
					mov		ofn.lStructSize,sizeof OPENFILENAME
					mov		eax,hWin
					mov		ofn.hwndOwner,eax
					mov		eax,hInstance
					mov		ofn.hInstance,eax
					mov		buff,0
					lea		eax,buff
					mov		ofn.lpstrFile,eax
					mov		ofn.nMaxFile,sizeof buff
					mov		ofn.lpstrFilter,offset szBMPFilterString
					mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_EXPLORER
					invoke GetOpenFileName,addr ofn
					.if eax
						invoke SetDlgItemText,hWin,IDC_EDTBMPFILE,addr buff
						invoke lstrcpy,addr [ebx].TBRMEM.tbr.szBmpFile,addr buff
						invoke SetImageList,hWin
						mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
						invoke NotifyParent,hWin
					.endif
				.else
					.if sdword ptr eax>=4000
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETCURSEL,addr [eax-4000],0
						invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTBTN,0
					.elseif sdword ptr eax>=3000
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETCURSEL,0,0
						mov		edi,eax
						.if edi!=LB_ERR
							invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETITEMDATA,edi,0
							and		eax,0FF00FFFFh
							mov		edx,wParam
							movzx	edx,dx
							lea		edx,[edx-3000]
							shl		edx,16
							or		eax,edx
							mov		nval,eax
							invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETITEMDATA,edi,nval
							invoke ShowToolbar,hWin
							mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
							invoke NotifyParent,hWin
						.endif
					.endif
				.endif
			.elseif edx==EN_CHANGE
				.if eax==IDC_EDTTBRNAME
					invoke GetDlgItemText,hWin,IDC_EDTTBRNAME,addr [ebx].TBRMEM.tbr.szTbrName,32
					mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
					invoke NotifyParent,hWin
				.elseif eax==IDC_EDTTBRID
					invoke GetDlgItemInt,hWin,IDC_EDTTBRID,NULL,FALSE
					mov		[ebx].TBRMEM.tbr.nTbrID,eax
					mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
					invoke NotifyParent,hWin
				.elseif eax==IDC_EDTBMPFILE
					invoke GetDlgItemText,hWin,IDC_EDTBMPFILE,addr [ebx].TBRMEM.tbr.szBmpFile,260
					mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
					invoke NotifyParent,hWin
				.elseif eax==IDC_EDTBMPNAME
					invoke GetDlgItemText,hWin,IDC_EDTBMPNAME,addr [ebx].TBRMEM.tbr.szBmpName,32
					mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
					invoke NotifyParent,hWin
				.elseif eax==IDC_EDTBMPNBR
					invoke GetDlgItemInt,hWin,IDC_EDTBMPNBR,NULL,FALSE
					mov		[ebx].TBRMEM.tbr.nBmp,eax
					mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
					invoke NotifyParent,hWin
				.elseif eax==IDC_EDTBTNNAME
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETCURSEL,0,0
					mov		edi,eax
					.if edi!=LB_ERR
						invoke GetDlgItemText,hWin,IDC_EDTBTNNAME,addr buff,32
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETITEMDATA,edi,0
						mov		nval,eax
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_DELETESTRING,edi,0
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_INSERTSTRING,edi,addr buff
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETITEMDATA,edi,nval
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETCURSEL,edi,0
						mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
						invoke NotifyParent,hWin
					.endif
				.elseif eax==IDC_EDTBTNID
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETCURSEL,0,0
					mov		edi,eax
					.if edi!=LB_ERR
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETITEMDATA,edi,0
						and		eax,0FFFF0000h
						mov		nval,eax
						invoke GetDlgItemInt,hWin,IDC_EDTBTNID,NULL,FALSE
						or		nval,eax
						invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_SETITEMDATA,edi,nval
						mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
						invoke NotifyParent,hWin
					.endif
				.elseif eax==IDC_EDTSIZE
					invoke GetDlgItemInt,hWin,IDC_EDTSIZE,NULL,FALSE
					mov		[ebx].TBRMEM.tbr.nBtnSize,eax
					invoke SetImageList,hWin
					mov		[ebx].TBRMEM.tbrdef.fChanged,TRUE
					invoke NotifyParent,hWin
				.endif
			.elseif edx==LBN_SELCHANGE
				invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETCURSEL,0,0
				mov		edi,eax
				.if edi!=LB_ERR
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETTEXT,edi,addr buff
					invoke SendDlgItemMessage,hWin,IDC_LSTBTN,LB_GETITEMDATA,edi,0
					mov		nval,eax
					invoke SetDlgItemText,hWin,IDC_EDTBTNNAME,addr buff
					mov		eax,nval
					and		eax,0FFFFh
					invoke SetDlgItemInt,hWin,IDC_EDTBTNID,eax,FALSE
					mov		eax,nval
					test	eax,1 shl 24
					.if !ZERO?
						mov		edx,BST_CHECKED
					.else
						mov		edx,BST_UNCHECKED
					.endif
					invoke CheckDlgButton,hWin,IDC_CHKBTNCHECK,edx
					mov		eax,nval
					test	eax,1 shl 25
					.if !ZERO?
						mov		edx,BST_CHECKED
					.else
						mov		edx,BST_UNCHECKED
					.endif
					invoke CheckDlgButton,hWin,IDC_CHKBTNGROUP,edx
				.else
					invoke SetDlgItemText,hWin,IDC_EDTBTNNAME,offset szNULL
					invoke SetDlgItemText,hWin,IDC_EDTBTNID,offset szNULL
				.endif
			.endif
		.endif
	.elseif eax==WM_SIZE
		invoke SendDlgItemMessage,hWin,IDC_TBR1,TB_AUTOSIZE,0,0
	.elseif eax==WM_DESTROY
		invoke GetProcessHeap
		push	eax
		invoke GetDlgItem,hWin,IDC_HMEM
		invoke GetWindowLong,eax,GWL_USERDATA
		pop		edx
		invoke HeapFree,edx,NULL,eax
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TbrCreateProc endp

;#########################################################################
;Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_SIZE
		xor		eax,eax
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

WndProc endp

; Export this proc
InstallAddin proc uses ebx,hWin:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	buffer[256]:BYTE

	invoke RtlZeroMemory,addr wc,sizeof WNDCLASSEX
	;Mdi Frame
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW; or CS_GLOBALCLASS
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,4
	mov		eax,hInstance
	mov		wc.hInstance,eax
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szTbrClassName
	mov		wc.hIcon,NULL
	mov		wc.hIconSm,NULL
	invoke LoadCursor,0,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0
	mov		lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax
	invoke SendMessage,ebx,AIM_GETMENUID,0,0	
	mov		MenuIDAddin,eax
	mov		ebx,lpHandles
	;Update the file browser filter string to include .tbr files
	invoke SendMessage,[ebx].ADDINHANDLES.hFileBrowser,FBM_GETFILTERSTRING,0,addr buffer
	invoke lstrcat,addr buffer,offset szTbrFilter
	invoke SendMessage,[ebx].ADDINHANDLES.hFileBrowser,FBM_SETFILTERSTRING,TRUE,addr buffer
	mov		hook.hook1,HOOK_COMMAND or HOOK_FILEOPEN or HOOK_FILESAVE or HOOK_GETMODIFY or HOOK_GETFILETYPE or HOOK_FILENAMECHANGED; or HOOK_MENUUPDATE
	xor		eax,eax
	mov		hook.hook2,eax
	mov		hook.hook3,eax
	mov		hook.hook4,eax
	lea		eax,hook
	ret 

InstallAddin endp

; Export this proc
; This proc handles messages sent from RadASM to our addin
; Return TRUE to prevent RadASM and other addins from executing the command.
AddinProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==AIM_COMMAND
		mov		eax,wParam
		.if eax==MenuIDAddin
			invoke GetProcessHeap
			invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof TBRMEM
			mov		ebx,eax
			invoke lstrcpy,addr [ebx].TBRMEM.tbrdef.FileName,offset szNewFile
			invoke CreateWindowEx,0,addr szTbrClassName,NULL,WS_CHILD or WS_VISIBLE,0,0,0,0,hWin,ID_EDITUSER,hInstance,0
			invoke CreateDialogParam,hInstance,IDD_TBRCREATE,eax,offset TbrCreateProc,ebx
			push	offset szNewFile
			push	eax
			mov		ebx,lpProc
			call	[ebx].ADDINPROCS.lpTabToolAdd
			call	[ebx].ADDINPROCS.lpTabToolActivate
			mov		eax,TRUE
			jmp		ExRet
		.endif
;	.elseif eax==AIM_MENUUPDATE
;		invoke UpdateMenu,wParam
	.elseif eax==AIM_FILEOPEN
		invoke lstrlen,lParam
		mov		edx,lParam
		.while byte ptr [edx+eax]!='.' && eax
			dec		eax
		.endw
		invoke lstrcmpi,addr [edx+eax],addr szTbr
		.if !eax
			invoke GetProcessHeap
			invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof TBRMEM
			mov		ebx,eax
			invoke lstrcpy,addr [ebx].TBRMEM.tbrdef.FileName,lParam
			invoke CreateWindowEx,0,addr szTbrClassName,NULL,WS_CHILD or WS_VISIBLE,0,0,0,0,hWin,ID_EDITUSER,hInstance,0
			mov		edi,eax
			invoke CreateDialogParam,hInstance,IDD_TBRCREATE,edi,offset TbrCreateProc,ebx
			invoke SetWindowLong,edi,0,eax
			mov		eax,edi
			jmp		ExRet
		.endif
	.elseif eax==AIM_FILESAVE
		.if wParam==ID_EDITUSER
			invoke GetWindowLong,hWin,GWL_USERDATA
			invoke GetWindowLong,eax,0
			mov		edi,eax
			invoke GetDlgItem,edi,IDC_HMEM
			.if eax
				invoke GetDlgItemText,edi,IDC_HMEM,addr buffer,sizeof buffer
				.if dword ptr buffer=='CRBT'
					invoke SaveToolbar,edi
					mov		eax,TRUE
					jmp		ExRet
				.endif
			.endif
		.endif
	.elseif eax==AIM_GETMODIFY
		.if wParam==ID_EDITUSER
			invoke GetWindowLong,hWin,GWL_USERDATA
			invoke GetWindowLong,eax,0
			mov		edi,eax
			invoke GetDlgItem,edi,IDC_HMEM
			.if eax
				invoke GetDlgItemText,edi,IDC_HMEM,addr buffer,sizeof buffer
				.if dword ptr buffer=='CRBT'
					invoke GetDlgItem,edi,IDC_HMEM
					invoke GetWindowLong,eax,GWL_USERDATA
					mov		ebx,eax
					mov		eax,[ebx].TBRMEM.tbrdef.fChanged
					jmp		ExRet
				.endif
			.endif
		.endif
	.elseif eax==AIM_GETFILETYPE
		invoke lstrlen,lParam
		mov		edx,lParam
		.while byte ptr [edx+eax]!='.' && eax
			dec		eax
		.endw
		invoke lstrcmpi,addr [edx+eax],addr szTbr
		.if !eax
			mov		eax,ID_EDITUSER
			jmp		ExRet
		.endif
	.elseif eax==AIM_FILENAMECHANGED
		invoke GetWindowLong,hWin,GWL_USERDATA
		invoke GetWindowLong,eax,0
		mov		edi,eax
		invoke GetDlgItem,edi,IDC_HMEM
		.if eax
			invoke GetDlgItemText,edi,IDC_HMEM,addr buffer,sizeof buffer
			.if dword ptr buffer=='CRBT'
				invoke GetDlgItem,edi,IDC_HMEM
				invoke GetWindowLong,eax,GWL_USERDATA
				mov		ebx,eax
				invoke lstrcmpi,wParam,addr [ebx].TBRMEM.tbrdef.FileName
				.if !eax
					invoke lstrcpy,addr [ebx].TBRMEM.tbrdef.FileName,lParam
					mov		eax,TRUE
					jmp		ExRet
				.endif
			.endif
		.endif
	.endif
	mov		eax,FALSE
  ExRet:
	ret

AddinProc endp

;#########################################################################

end DllEntry
