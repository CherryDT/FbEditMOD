.code

FindInit proc uses ebx esi edi,hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM

	mov		fres,-1
	invoke SendMessage,hWin,EM_EXGETSEL,0,offset findchrg
	mov		findchrg.cpMax,-2
	.if fallfiles
		invoke SendMessage,ha.hTab,TCM_GETCURSEL,0,0
		mov		esi,eax
		mov		nInx,eax
		mov		tci.imask,TCIF_PARAM
		mov		edi,offset findtabs
		mov		eax,TRUE
		.while TRUE
			invoke SendMessage,ha.hTab,TCM_GETITEM,esi,addr tci
			.break .if !eax
			call	AddCodeFile
			inc		esi
		.endw
		xor		esi,esi
		.while esi<nInx
			invoke SendMessage,ha.hTab,TCM_GETITEM,esi,addr tci
			.break .if !eax
			call	AddCodeFile
			inc		esi
		.endw
		xor		eax,eax
		mov		dword ptr [edi],eax
		mov		ntab,eax
	.endif
	ret

AddCodeFile:
	mov		ebx,tci.lParam
	push	esi
	lea		esi,[ebx].TABMEM.filename
	invoke strlen,esi
	lea		esi,[esi+eax-4]
	invoke strcmpi,esi,offset szFtAsm
	.if eax
		invoke strcmpi,esi,offset szFtInc
	.endif
	.if !eax
		mov		eax,[ebx].TABMEM.hwnd
		mov		[edi],eax
		lea		edi,[edi+4]
	.endif
	pop		esi
	retn

FindInit endp

FindSetup proc hWin:HWND

	;Get current selection
	invoke SendMessage,hWin,EM_EXGETSEL,0,offset ft.chrg
	;Setup find
	mov		eax,ndir
	.if eax==0
		;All
		.if fres!=-1
			mov		eax,ft.chrgText.cpMax
			mov		ft.chrg.cpMin,eax
		.else
			mov		eax,findchrg.cpMax
			.if eax!=-2
				mov		ft.chrg.cpMin,0
			.endif
		.endif
		mov		eax,findchrg.cpMax
		mov		ft.chrg.cpMax,eax
	.elseif eax==1
		;Down
		.if fres!=-1
			mov		eax,ft.chrgText.cpMax
			mov		ft.chrg.cpMin,eax
		.endif
		mov		ft.chrg.cpMax,-2
	.else
		;Up
		.if fres!=-1
			dec		ft.chrg.cpMin
		.endif
		mov		ft.chrg.cpMax,0
	.endif
	mov		ft.lpstrText,offset da.findbuff
	ret

FindSetup endp

Find proc hWin:HWND,frType:DWORD

FindNext:
	invoke FindSetup,hWin
	;Do the find
	invoke SendMessage,hWin,EM_FINDTEXTEX,frType,offset ft
	mov		fres,eax
	.if eax==-1
		mov		eax,findchrg.cpMin
		.if ndir==0 && eax
			dec		eax
			mov		findchrg.cpMax,eax
			mov		findchrg.cpMin,0
			jmp		FindNext
		.endif
		.if fallfiles
			inc		ntab
			mov		eax,ntab
			lea		edx,[offset findtabs+eax*4]
			mov		eax,[edx]
			.if eax
				mov		hWin,eax
				mov		fallfiles,0
				invoke FindInit,hWin
				mov		fallfiles,1
				jmp		FindNext
			.endif
		.endif
		;Region searched
		invoke MessageBox,ha.hFind,addr szRegionSearched,addr szAppName,MB_OK or MB_ICONINFORMATION
	.else
		mov		eax,hWin
		.if eax!=ha.hREd
			invoke TabToolGetInx,hWin
			invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
			invoke TabToolActivate
		.endif
		;Mark the foud text
		invoke SendMessage,hWin,EM_EXSETSEL,0,offset ft.chrgText
		invoke SendMessage,hWin,REM_VCENTER,0,0
		invoke SendMessage,hWin,EM_SCROLLCARET,0,0
	.endif
	ret

Find endp

FindDlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hCtl:DWORD
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		ha.hFind,eax
		.if lParam
			mov		eax,BN_CLICKED
			shl		eax,16
			or		eax,IDC_BTN_REPLACE
			invoke PostMessage,hWin,WM_COMMAND,eax,0
		.endif
		;Put text in edit boxes
		invoke SendDlgItemMessage,hWin,IDC_FINDTEXT,EM_LIMITTEXT,255,0
		invoke SendDlgItemMessage,hWin,IDC_FINDTEXT,WM_SETTEXT,0,offset da.findbuff
		invoke SendDlgItemMessage,hWin,IDC_REPLACETEXT,EM_LIMITTEXT,255,0
		invoke SendDlgItemMessage,hWin,IDC_REPLACETEXT,WM_SETTEXT,0,offset da.replacebuff
		;Set check boxes
		mov		eax,fr
		and		eax,FR_MATCHCASE
		.if eax
			invoke CheckDlgButton,hWin,IDC_CHK_MATCHCASE,BST_CHECKED
		.endif
		mov		eax,fr
		and		eax,FR_WHOLEWORD
		.if eax
			invoke CheckDlgButton,hWin,IDC_CHK_WHOLEWORD,BST_CHECKED
		.endif
		.if fallfiles
			invoke CheckDlgButton,hWin,IDC_CHK_ALLFILES,BST_CHECKED
		.endif
		;Set find direction
		mov		eax,ndir
		.if eax==0
			mov		eax,IDC_RBN_ALL
		.elseif eax==1
			mov		eax,IDC_RBN_DOWN
		.else
			mov		eax,IDC_RBN_UP
		.endif
		invoke CheckDlgButton,hWin,eax,BST_CHECKED
		invoke SetWindowPos,hWin,0,findpt.x,findpt.y,0,0,SWP_NOSIZE or SWP_NOZORDER
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				;Find the text
				invoke Find,ha.hREd,fr
			.elseif eax==IDCANCEL
				;Close the find dialog
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTN_REPLACE
				invoke GetDlgItem,hWin,IDC_BTN_REPLACEALL
				mov		hCtl,eax
				invoke IsWindowEnabled,hCtl
				.if !eax
					;Enable Replace all button
					invoke EnableWindow,hCtl,TRUE
					;Set caption to Replace...
					invoke SetWindowText,hWin,offset szReplace
					;Show replace
					invoke GetDlgItem,hWin,IDC_REPLACESTATIC
					invoke ShowWindow,eax,SW_SHOWNA
					invoke GetDlgItem,hWin,IDC_REPLACETEXT
					invoke ShowWindow,eax,SW_SHOWNA
				.else
					.if fres!=-1
						invoke SendMessage,ha.hREd,EM_EXGETSEL,0,offset ft.chrg
						invoke SendMessage,ha.hREd,EM_REPLACESEL,TRUE,offset da.replacebuff
						invoke strlen,offset da.replacebuff
						push	eax
						add		eax,ft.chrgText.cpMin
						mov		ft.chrgText.cpMax,eax
						invoke SendMessage,ha.hREd,EM_EXSETSEL,0,offset ft.chrgText
						invoke strlen,offset da.findbuff
						pop		edx
						sub		edx,eax
						.if ndir==0
							.if findchrg.cpMax!=-1
								add		findchrg.cpMax,edx
							.endif
						.endif
					.endif
					invoke Find,ha.hREd,fr
				.endif
			.elseif eax==IDC_BTN_REPLACEALL
				.if fres==-1
					invoke Find,ha.hREd,fr
				.endif
				.while fres!=-1
					mov		eax,BN_CLICKED
					shl		eax,16
					or		eax,IDC_BTN_REPLACE
					invoke SendMessage,hWin,WM_COMMAND,eax,0
				.endw
			.elseif eax==IDC_RBN_ALL
				;Set find direction to down
				or		fr,FR_DOWN
				mov		ndir,0
				invoke FindInit,ha.hREd
			.elseif eax==IDC_RBN_DOWN
				;Set find direction to down
				or		fr,FR_DOWN
				mov		ndir,1
				invoke FindInit,ha.hREd
			.elseif eax==IDC_RBN_UP
				;Set find direction to up
				and		fr,-1 xor FR_DOWN
				mov		ndir,2
				invoke FindInit,ha.hREd
			.elseif eax==IDC_CHK_MATCHCASE
				;Set match case mode
				invoke IsDlgButtonChecked,hWin,IDC_CHK_MATCHCASE
				.if eax
					or		fr,FR_MATCHCASE
				.else
					and		fr,-1 xor FR_MATCHCASE
				.endif
				invoke FindInit,ha.hREd
			.elseif eax==IDC_CHK_WHOLEWORD
				;Set whole word mode
				invoke IsDlgButtonChecked,hWin,IDC_CHK_WHOLEWORD
				.if eax
					or		fr,FR_WHOLEWORD
				.else
					and		fr,-1 xor FR_WHOLEWORD
				.endif
				invoke FindInit,ha.hREd
			.elseif eax==IDC_CHK_ALLFILES
				;All Open Files
				invoke IsDlgButtonChecked,hWin,IDC_CHK_ALLFILES
				mov		fallfiles,eax
				invoke FindInit,ha.hREd
			.endif
		.elseif edx==EN_CHANGE
			;Update text buffers
			.if eax==IDC_FINDTEXT
				invoke SendDlgItemMessage,hWin,eax,WM_GETTEXT,sizeof da.findbuff,offset da.findbuff
				invoke FindInit,ha.hREd
			.elseif eax==IDC_REPLACETEXT
				invoke SendDlgItemMessage,hWin,eax,WM_GETTEXT,sizeof da.replacebuff,offset da.replacebuff
				invoke FindInit,ha.hREd
			.endif
		.endif
	.elseif eax==WM_ACTIVATE
		invoke FindInit,ha.hREd
	.elseif eax==WM_CLOSE
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.left
		mov		findpt.x,eax
		mov		eax,rect.top
		mov		findpt.y,eax
		mov		ha.hFind,0
		invoke DestroyWindow,hWin
		invoke SetFocus,ha.hREd
	.else
		mov eax,FALSE
		ret
	.endif
	mov  eax,TRUE
	ret

FindDlgProc endp

HexFind proc frType:DWORD

	;Get current selection
	invoke SendMessage,ha.hREd,EM_EXGETSEL,0,offset ft.chrg
	;Setup find
	mov		eax,frType
	and		eax,FR_DOWN
	.if eax
		.if fres!=-1
			and		ft.chrg.cpMin,0FFFFFFFEh
			add		ft.chrg.cpMin,2
		.endif
		mov		ft.chrg.cpMax,-1
	.else
		.if fres!=-1
			and		ft.chrg.cpMin,0FFFFFFFEh
			sub		ft.chrg.cpMin,2
		.endif
		mov		ft.chrg.cpMax,0
	.endif
	mov		ft.lpstrText,offset da.findbuff
	;Do the find
	invoke SendMessage,ha.hREd,EM_FINDTEXTEX,frType,offset ft
	mov		fres,eax
	.if eax!=-1
		;Mark the foud text
		invoke SendMessage,ha.hREd,EM_EXSETSEL,0,offset ft.chrgText
		invoke SendMessage,ha.hREd,HEM_VCENTER,0,0
	.else
		;Region searched
	.endif
	ret

HexFind endp

HexFindDlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hCtl:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		ha.hFind,eax
		.if lParam
			mov		eax,BN_CLICKED
			shl		eax,16
			or		eax,IDC_BTN_REPLACE
			invoke PostMessage,hWin,WM_COMMAND,eax,0
		.endif
		;Put text in edit boxes
		invoke SendDlgItemMessage,hWin,IDC_FINDTEXT,EM_LIMITTEXT,255,0
		invoke SendDlgItemMessage,hWin,IDC_FINDTEXT,WM_SETTEXT,0,offset da.findbuff
		invoke SendDlgItemMessage,hWin,IDC_REPLACETEXT,EM_LIMITTEXT,255,0
		invoke SendDlgItemMessage,hWin,IDC_REPLACETEXT,WM_SETTEXT,0,offset da.replacebuff
		;Set find type
		mov		eax,fr
		and		eax,FR_HEX
		.if eax
			mov		eax,IDC_RBN_HEX
		.else
			mov		eax,IDC_RBN_ASCII
		.endif
		invoke CheckDlgButton,hWin,eax,BST_CHECKED
		;Set find direction
		mov		eax,fr
		and		eax,FR_DOWN
		.if eax
			mov		eax,IDC_RBN_DOWN
		.else
			mov		eax,IDC_RBN_UP
		.endif
		invoke CheckDlgButton,hWin,eax,BST_CHECKED
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				;Find the text
				invoke HexFind,fr
			.elseif eax==IDCANCEL
				;Close the find dialog
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTN_REPLACE
				invoke GetDlgItem,hWin,IDC_BTN_REPLACEALL
				mov		hCtl,eax
				invoke IsWindowEnabled,hCtl
				.if !eax
					;Enable Replace all button
					invoke EnableWindow,hCtl,TRUE
					;Set caption to Replace...
					invoke SetWindowText,hWin,offset szReplace
					;Show replace
					invoke GetDlgItem,hWin,IDC_HEXREPLACESTATIC
					invoke ShowWindow,eax,SW_SHOWNA
					invoke GetDlgItem,hWin,IDC_REPLACETEXT
					invoke ShowWindow,eax,SW_SHOWNA
				.else
					.if fres!=-1
						invoke SendMessage,ha.hREd,EM_EXGETSEL,0,offset ft.chrg
						mov		eax,fr
						and		eax,FR_HEX
						or		eax,TRUE
						invoke SendMessage,ha.hREd,EM_REPLACESEL,eax,offset da.replacebuff
						invoke strlen,offset da.replacebuff
						test	fr,FR_HEX
						.if ZERO?
							add		eax,eax
						.endif
						dec		eax
						add		eax,ft.chrg.cpMin
						mov		ft.chrg.cpMin,eax
						mov		ft.chrg.cpMax,eax
						invoke SendMessage,ha.hREd,EM_EXSETSEL,0,offset ft.chrg
					.endif
					invoke HexFind,fr
				.endif
			.elseif eax==IDC_BTN_REPLACEALL
				.if fres==-1
					invoke HexFind,fr
				.endif
				.while fres!=-1
					mov		eax,BN_CLICKED
					shl		eax,16
					or		eax,IDC_BTN_REPLACE
					invoke SendMessage,hWin,WM_COMMAND,eax,0
				.endw
			.elseif eax==IDC_RBN_HEX
				;Set hex type
				or		fr,FR_HEX
				mov		fres,-1
			.elseif eax==IDC_RBN_ASCII
				;Set ascii type
				and		fr,-1 xor FR_HEX
				mov		fres,-1
			.elseif eax==IDC_RBN_DOWN
				;Set find direction to down
				or		fr,FR_DOWN
				mov		fres,-1
			.elseif eax==IDC_RBN_UP
				;Set find direction to up
				and		fr,-1 xor FR_DOWN
				mov		fres,-1
			.endif
		.elseif edx==EN_CHANGE
			;Update text buffers
			.if eax==IDC_FINDTEXT
				invoke SendDlgItemMessage,hWin,eax,WM_GETTEXT,sizeof da.findbuff,offset da.findbuff
				mov		fres,-1
			.elseif eax==IDC_REPLACETEXT
				invoke SendDlgItemMessage,hWin,eax,WM_GETTEXT,sizeof da.replacebuff,offset da.replacebuff
				mov		fres,-1
			.endif
		.endif
	.elseif eax==WM_ACTIVATE
		mov		fres,-1
	.elseif eax==WM_CLOSE
		mov		ha.hFind,0
		.if ha.hREd
			invoke SetFocus,ha.hREd
		.endif
		invoke DestroyWindow,hWin
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

HexFindDlgProc endp

