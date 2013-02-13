.code

Find proc frType:DWORD

	;Get current selection
	invoke SendMessage,hREd,EM_EXGETSEL,0,offset ft.chrg
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
	mov		ft.lpstrText,offset findbuff
	;Do the find
	invoke SendMessage,hREd,EM_FINDTEXTEX,frType,offset ft
	mov		fres,eax
	.if eax!=-1
		;Mark the foud text
		invoke SendMessage,hREd,EM_EXSETSEL,0,offset ft.chrgText
		invoke SendMessage,hREd,HEM_VCENTER,0,0
	.else
		;Region searched
	.endif
	ret

Find endp

FindDlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hCtl:DWORD
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hFind,eax
		invoke SetWindowPos,hWin,NULL,wpos.FindX,wpos.FindY,0,0,SWP_NOZORDER or SWP_NOSIZE
		.if lParam
			mov		eax,BN_CLICKED
			shl		eax,16
			or		eax,IDC_BTN_REPLACE
			invoke PostMessage,hWin,WM_COMMAND,eax,0
		.endif
		;Put text in edit boxes
		invoke SendDlgItemMessage,hWin,IDC_FINDTEXT,EM_LIMITTEXT,255,0
		invoke SendDlgItemMessage,hWin,IDC_FINDTEXT,WM_SETTEXT,0,offset findbuff
		invoke SendDlgItemMessage,hWin,IDC_REPLACETEXT,EM_LIMITTEXT,255,0
		invoke SendDlgItemMessage,hWin,IDC_REPLACETEXT,WM_SETTEXT,0,offset replacebuff
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
				invoke Find,fr
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
					invoke SetWindowText,hWin,offset Replace
					;Show replace
					invoke GetDlgItem,hWin,IDC_REPLACESTATIC
					invoke ShowWindow,eax,SW_SHOWNA
					invoke GetDlgItem,hWin,IDC_REPLACETEXT
					invoke ShowWindow,eax,SW_SHOWNA
				.else
					.if fres!=-1
						invoke SendMessage,hREd,EM_EXGETSEL,0,offset ft.chrg
						mov		eax,fr
						and		eax,FR_HEX
						or		eax,TRUE
						invoke SendMessage,hREd,EM_REPLACESEL,eax,offset replacebuff
						invoke lstrlen,offset replacebuff
						test	fr,FR_HEX
						.if ZERO?
							add		eax,eax
						.endif
						dec		eax
						add		eax,ft.chrg.cpMin
						mov		ft.chrg.cpMin,eax
						mov		ft.chrg.cpMax,eax
						invoke SendMessage,hREd,EM_EXSETSEL,0,offset ft.chrg
					.endif
					invoke Find,fr
				.endif
			.elseif eax==IDC_BTN_REPLACEALL
				.if fres==-1
					invoke Find,fr
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
				invoke SendDlgItemMessage,hWin,eax,WM_GETTEXT,sizeof findbuff,offset findbuff
				mov		fres,-1
			.elseif eax==IDC_REPLACETEXT
				invoke SendDlgItemMessage,hWin,eax,WM_GETTEXT,sizeof replacebuff,offset replacebuff
				mov		fres,-1
			.endif
		.endif
	.elseif eax==WM_ACTIVATE
		mov		fres,-1
	.elseif eax==WM_CLOSE
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.left
		mov		wpos.FindX,eax
		mov		eax,rect.top
		mov		wpos.FindY,eax
		mov		hFind,0
		invoke DestroyWindow,hWin
		invoke SetFocus,hREd
	.else
		mov eax,FALSE
		ret
	.endif
	mov  eax,TRUE
	ret

FindDlgProc endp

