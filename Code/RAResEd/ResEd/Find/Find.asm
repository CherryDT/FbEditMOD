
;Find.dlg
IDD_FINDDLG				equ 3100
IDC_FINDTEXT			equ 2001
IDC_BTN_REPLACE			equ 2007
IDC_REPLACETEXT			equ 2002
IDC_REPLACESTATIC		equ 2009
IDC_BTN_REPLACEALL		equ 2008
IDC_CHK_WHOLEWORD		equ 2004
IDC_CHK_MATCHCASE		equ 2003
IDC_RBN_DIRDOWN			equ 2005
IDC_RBN_DIRUP			equ 2006

.data

szReplace				db 'Replace ..',0
szRegionSearched		db 'Region searched.',0
.data?

hFind					HWND ?
ft						FINDTEXTEX <>
fr						dd ?
fres					dd ?
findbuff				db 2566 dup(?)
replacebuff				db 2566 dup(?)

.code

Find proc frType:DWORD

	;Get current selection
	invoke SendMessage,hResEd,EM_EXGETSEL,0,offset ft.chrg
	;Setup find
	mov		eax,frType
	and		eax,FR_DOWN
	.if eax
		.if fres!=-1
			mov		eax,ft.chrgText.cpMax
			mov		ft.chrg.cpMin,eax
		.endif
		mov		ft.chrg.cpMax,-1
	.else
		mov		ft.chrg.cpMax,0
		dec		ft.chrg.cpMin
	.endif
	mov		ft.lpstrText,offset findbuff
	;Do the find
	invoke SendMessage,hResEd,EM_FINDTEXTEX,frType,offset ft
	mov		fres,eax
	.if eax!=-1
		;Mark the foud text
		invoke SendMessage,hResEd,EM_EXSETSEL,0,offset ft.chrgText
		invoke SendMessage,hResEd,REM_VCENTER,0,0
		invoke SendMessage,hResEd,EM_SCROLLCARET,0,0
	.else
		;Region searched
		invoke MessageBox,hFind,addr szRegionSearched,addr szAppName,MB_OK
	.endif
	ret

Find endp

FindDlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hCtl:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hFind,eax
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
		;Set find direction
		mov		eax,fr
		and		eax,FR_DOWN
		.if eax
			mov		eax,IDC_RBN_DIRDOWN
		.else
			mov		eax,IDC_RBN_DIRUP
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
					invoke SetWindowText,hWin,offset szReplace
					;Show replace
					invoke GetDlgItem,hWin,IDC_REPLACESTATIC
					invoke ShowWindow,eax,SW_SHOWNA
					invoke GetDlgItem,hWin,IDC_REPLACETEXT
					invoke ShowWindow,eax,SW_SHOWNA
				.else
					.if fres!=-1
						invoke SendMessage,hResEd,EM_EXGETSEL,0,offset ft.chrg
						invoke SendMessage,hResEd,EM_REPLACESEL,TRUE,offset replacebuff
						invoke lstrlen,offset replacebuff
						add		eax,ft.chrg.cpMin
						mov		ft.chrg.cpMax,eax
						invoke SendMessage,hResEd,EM_EXSETSEL,0,offset ft.chrg
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
			.elseif eax==IDC_RBN_DIRDOWN
				;Set find direction to down
				or		fr,FR_DOWN
				mov		fres,-1
			.elseif eax==IDC_RBN_DIRUP
				;Set find direction to up
				and		fr,-1 xor FR_DOWN
				mov		fres,-1
			.elseif eax==IDC_CHK_MATCHCASE
				;Set match case mode
				invoke IsDlgButtonChecked,hWin,IDC_CHK_MATCHCASE
				.if eax
					or		fr,FR_MATCHCASE
				.else
					and		fr,-1 xor FR_MATCHCASE
				.endif
				mov		fres,-1
			.elseif eax==IDC_CHK_WHOLEWORD
				;Set whole word mode
				invoke IsDlgButtonChecked,hWin,IDC_CHK_WHOLEWORD
				.if eax
					or		fr,FR_WHOLEWORD
				.else
					and		fr,-1 xor FR_WHOLEWORD
				.endif
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
		mov		hFind,0
		invoke DestroyWindow,hWin
		invoke SetFocus,hResEd
	.else
		mov eax,FALSE
		ret
	.endif
	mov  eax,TRUE
	ret

FindDlgProc endp
