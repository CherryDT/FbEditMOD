
;ProjectOption.dlg
IDD_DLGPO						equ 3500
IDC_LSTPO						equ 1001
IDC_EDTPORC						equ 1004
IDC_EDTPOASSEMBLE				equ 1006
IDC_EDTPOLINK					equ 1008
IDC_EDTPOLIB					equ 1010
IDC_EDTPOOUTRC					equ 1012
IDC_EDTPOOUTASSEMBLE			equ 1013
IDC_EDTPOOUTLINK				equ 1015
IDC_EDTPOOUTLIB					equ 1017
IDC_BTNPOADDNEW					equ 1019
IDC_BTNPOADDEXISTING			equ 1020
IDC_EDTPOADDNEW					equ 1021
IDC_BTNPOHELP					equ 1024
IDC_CBOPOADDEXISTING			equ 1022
IDC_BTNPODELETE					equ 1023
IDC_CHKDELETEMINOR				equ 3502
IDC_CHKPOINCBUILD				equ 3506
IDC_EDTPOCMDEXE					equ 1025
IDC_EDTPOCOMMANDLINE			equ 1027
IDC_CHKPOCMDEXE					equ 1026
IDC_EDTPOAPI					equ 3505

.data?

fNoUpdate				dd ?

.code

ProjectOptionProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ntab:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		ntab,240
		invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_SETTABSTOPS,1,addr ntab
		invoke SendDlgItemMessage,hWin,IDC_EDTPOADDNEW,EM_LIMITTEXT,sizeof MAKE.szType-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTPORC,EM_LIMITTEXT,sizeof MAKE.szCompileRC-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTPOASSEMBLE,EM_LIMITTEXT,sizeof MAKE.szAssemble-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTPOLINK,EM_LIMITTEXT,sizeof MAKE.szLink-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTPOLIB,EM_LIMITTEXT,sizeof MAKE.szLib-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTPOOUTRC,EM_LIMITTEXT,sizeof MAKE.szOutCompileRC-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTPOOUTASSEMBLE,EM_LIMITTEXT,sizeof MAKE.szOutAssemble-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTPOOUTLINK,EM_LIMITTEXT,sizeof MAKE.szOutLink-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTPOOUTLIB,EM_LIMITTEXT,sizeof MAKE.szOutLib-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTPOCOMMANDLINE,EM_LIMITTEXT,sizeof da.szCommandLine-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTPOCMDEXE,EM_LIMITTEXT,sizeof da.szCmdExe-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTPOAPI,EM_LIMITTEXT,255,0
		lea		esi,da.make
		xor		ebx,ebx
		.while ebx<32
			.break .if ![esi].MAKE.szType
			mov		tmpbuff,0
			invoke PutItemStr,addr tmpbuff,addr [esi].MAKE.szType
			invoke PutItemQuotedStr,addr tmpbuff,addr [esi].MAKE.szCompileRC
			invoke PutItemStr,addr tmpbuff,addr [esi].MAKE.szOutCompileRC
			invoke PutItemQuotedStr,addr tmpbuff,addr [esi].MAKE.szAssemble
			invoke PutItemStr,addr tmpbuff,addr [esi].MAKE.szOutAssemble
			invoke PutItemQuotedStr,addr tmpbuff,addr [esi].MAKE.szLink
			invoke PutItemStr,addr tmpbuff,addr [esi].MAKE.szOutLink
			invoke PutItemQuotedStr,addr tmpbuff,addr [esi].MAKE.szLib
			invoke PutItemStr,addr tmpbuff,addr [esi].MAKE.szOutLib
			mov		eax,offset tmpbuff[1]
			.while byte ptr [eax]
				.if byte ptr [eax]==','
					mov		byte ptr [eax],VK_TAB
					.break
				.endif
				inc		eax
			.endw
			invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_ADDSTRING,0,addr tmpbuff[1]
			lea		esi,[esi+sizeof MAKE]
			inc		ebx
		.endw
		invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_SETCURSEL,0,0
		.if eax!=LB_ERR
			invoke SendMessage,hWin,WM_COMMAND,LBN_SELCHANGE shl 16 or IDC_LSTPO,hWin
		.endif
		xor		ebx,ebx
		.while ebx<32
			invoke BinToDec,ebx,addr buffer
			invoke GetPrivateProfileString,addr szIniMake,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
			.if eax
				invoke GetItemStr,addr tmpbuff,addr szNULL,addr buffer,sizeof buffer
				invoke SendDlgItemMessage,hWin,IDC_CBOPOADDEXISTING,CB_ADDSTRING,0,addr buffer
			.endif
			inc		ebx
		.endw
		invoke SendDlgItemMessage,hWin,IDC_CBOPOADDEXISTING,CB_SETCURSEL,0,0
		mov		eax,BST_UNCHECKED
		.if da.fDelMinor
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKDELETEMINOR,eax
		mov		eax,BST_UNCHECKED
		.if da.fIncBuild
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKPOINCBUILD,eax
		mov		eax,BST_UNCHECKED
		.if da.fCmdExe
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKPOCMDEXE,eax
		invoke SetDlgItemText,hWin,IDC_EDTPOCMDEXE,addr da.szCmdExe
		invoke SetDlgItemText,hWin,IDC_EDTPOCOMMANDLINE,addr da.szCommandLine
		invoke SetDlgItemText,hWin,IDC_EDTPOAPI,addr da.szPOApiFiles
		call	UpdateBtnDelete
		invoke GetDlgItem,hWin,IDOK
		invoke EnableWindow,eax,FALSE
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				mov		edi,offset da.make
				invoke RtlZeroMemory,edi,sizeof da.make
				invoke SendMessage,ha.hCboBuild,CB_RESETCONTENT,0,0
				xor		ebx,ebx
				.while ebx<32
					invoke RtlZeroMemory,addr tmpbuff,sizeof tmpbuff
					invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_GETTEXT,ebx,addr tmpbuff
					.break .if eax==LB_ERR
					xor		eax,eax
					.while tmpbuff[eax]!=VK_TAB
						inc		eax
					.endw
					mov		tmpbuff[eax],','
					invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szType,sizeof MAKE.szType
					invoke SendMessage,ha.hCboBuild,CB_ADDSTRING,0,addr [edi].MAKE.szType
					invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szCompileRC,sizeof MAKE.szCompileRC
					invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szOutCompileRC,sizeof MAKE.szOutCompileRC
					invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szAssemble,sizeof MAKE.szAssemble
					invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szOutAssemble,sizeof MAKE.szOutAssemble
					invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szLink,sizeof MAKE.szLink
					invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szOutLink,sizeof MAKE.szOutLink
					invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szLib,sizeof MAKE.szLib
					invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szOutLib,sizeof MAKE.szOutLib
					lea		edi,[edi+sizeof MAKE]
					inc		ebx
				.endw
				invoke SendMessage,ha.hCboBuild,CB_SETCURSEL,0,0
				invoke IsDlgButtonChecked,hWin,IDC_CHKDELETEMINOR
				mov		da.fDelMinor,eax
				invoke IsDlgButtonChecked,hWin,IDC_CHKPOINCBUILD
				mov		da.fIncBuild,eax
				invoke GetDlgItemText,hWin,IDC_EDTPOCOMMANDLINE,addr da.szCommandLine,sizeof da.szCommandLine
				invoke GetDlgItemText,hWin,IDC_EDTPOCMDEXE,addr da.szCmdExe,sizeof da.szCmdExe
				invoke IsDlgButtonChecked,hWin,IDC_CHKPOCMDEXE
				mov		da.fCmdExe,eax
				invoke GetDlgItemText,hWin,IDC_EDTPOAPI,addr da.szPOApiFiles,sizeof da.szPOApiFiles
				invoke SendMessage,hWin,WM_CLOSE,NULL,TRUE
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNPOADDEXISTING
				invoke SendDlgItemMessage,hWin,IDC_CBOPOADDEXISTING,CB_GETCURSEL,0,0
				.if eax!=CB_ERR
					mov		ebx,eax
					invoke BinToDec,ebx,addr buffer
					invoke GetPrivateProfileString,addr szIniMake,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
					.if eax
						mov		eax,offset tmpbuff
						.while byte ptr [eax]
							.if byte ptr [eax]==','
								mov		byte ptr [eax],VK_TAB
								.break
							.endif
							inc		eax
						.endw
						invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_ADDSTRING,0,addr tmpbuff
						invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_SETCURSEL,eax,0
						invoke SendMessage,hWin,WM_COMMAND,LBN_SELCHANGE shl 16 or IDC_LSTPO,hWin
						invoke GetDlgItem,hWin,IDOK
						invoke EnableWindow,eax,TRUE
						invoke GetDlgItem,hWin,IDC_BTNPOADDEXISTING
						invoke EnableWindow,eax,FALSE
						call	UpdateBtnDelete
					.endif
				.endif
			.elseif eax==IDC_BTNPOADDNEW
				invoke GetDlgItemText,hWin,IDC_EDTPOADDNEW,addr tmpbuff,sizeof tmpbuff
				invoke strcat,addr tmpbuff,addr szTab
				invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_ADDSTRING,0,addr tmpbuff
				invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_SETCURSEL,eax,0
				invoke SendMessage,hWin,WM_COMMAND,LBN_SELCHANGE shl 16 or IDC_LSTPO,hWin
				invoke GetDlgItem,hWin,IDOK
				invoke EnableWindow,eax,TRUE
				invoke GetDlgItem,hWin,IDC_BTNPOADDNEW
				invoke EnableWindow,eax,FALSE
				call	UpdateBtnDelete
			.elseif eax==IDC_BTNPODELETE
				invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_GETCURSEL,0,0
				mov		ebx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_DELETESTRING,ebx,0
				invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_SETCURSEL,ebx,0
				.if eax==LB_ERR
					dec		ebx
					invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_SETCURSEL,ebx,0
				.endif
				invoke SendMessage,hWin,WM_COMMAND,LBN_SELCHANGE shl 16 or IDC_LSTPO,hWin
				call	UpdateBtnDelete
				invoke GetDlgItem,hWin,IDOK
				invoke EnableWindow,eax,TRUE
			.elseif eax==IDC_CHKDELETEMINOR
				invoke GetDlgItem,hWin,IDOK
				invoke EnableWindow,eax,TRUE
			.elseif eax==IDC_CHKPOINCBUILD
				invoke GetDlgItem,hWin,IDOK
				invoke EnableWindow,eax,TRUE
			.elseif eax==IDC_CHKPOCMDEXE
				invoke GetDlgItem,hWin,IDOK
				invoke EnableWindow,eax,TRUE
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTPOADDNEW
				invoke GetDlgItem,hWin,IDC_BTNPOADDNEW
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_EDTPOADDNEW,WM_GETTEXTLENGTH,0,0
				pop		edx
				invoke EnableWindow,edx,eax
			.elseif eax==IDC_EDTPOCOMMANDLINE
				invoke GetDlgItem,hWin,IDOK
				invoke EnableWindow,eax,TRUE
			.elseif eax==IDC_EDTPOCMDEXE
				invoke GetDlgItem,hWin,IDOK
				invoke EnableWindow,eax,TRUE
			.elseif eax==IDC_EDTPOAPI
				invoke GetDlgItem,hWin,IDOK
				invoke EnableWindow,eax,TRUE
			.elseif !fNoUpdate
				call	POUpdateList
			.endif
		.elseif edx==LBN_SELCHANGE
			.if eax==IDC_LSTPO
				invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		fNoUpdate,TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_GETTEXT,eax,addr tmpbuff
					xor		eax,eax
					.while tmpbuff[eax]!=VK_TAB
						inc		eax
					.endw
					invoke strcpy,addr tmpbuff,addr tmpbuff[eax+1]
					invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr buffer,sizeof buffer
					invoke SetDlgItemText,hWin,IDC_EDTPORC,addr buffer
					invoke GetItemStr,addr tmpbuff,addr szNULL,addr buffer,sizeof buffer
					invoke SetDlgItemText,hWin,IDC_EDTPOOUTRC,addr buffer
					invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr buffer,sizeof buffer
					invoke SetDlgItemText,hWin,IDC_EDTPOASSEMBLE,addr buffer
					invoke GetItemStr,addr tmpbuff,addr szNULL,addr buffer,sizeof buffer
					invoke SetDlgItemText,hWin,IDC_EDTPOOUTASSEMBLE,addr buffer
					invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr buffer,sizeof buffer
					invoke SetDlgItemText,hWin,IDC_EDTPOLINK,addr buffer
					invoke GetItemStr,addr tmpbuff,addr szNULL,addr buffer,sizeof buffer
					invoke SetDlgItemText,hWin,IDC_EDTPOOUTLINK,addr buffer
					invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr buffer,sizeof buffer
					invoke SetDlgItemText,hWin,IDC_EDTPOLIB,addr buffer
					invoke GetItemStr,addr tmpbuff,addr szNULL,addr buffer,sizeof buffer
					invoke SetDlgItemText,hWin,IDC_EDTPOOUTLIB,addr buffer
					mov		fNoUpdate,FALSE
				.endif
			.elseif eax==IDC_CBOPOADDEXISTING
				invoke GetDlgItem,hWin,IDC_BTNPOADDEXISTING
				invoke EnableWindow,eax,TRUE
			.endif
		.endif
	.elseif eax==WM_HELP
		mov		esi,lParam
		mov		eax,[esi].HELPINFO.iCtrlId
		.if eax==IDC_EDTPORC || eax==IDC_EDTPOOUTRC
			invoke DoHelp,addr da.szCompileRCHelp,addr da.szCompileRCHelpKw
		.elseif eax==IDC_EDTPOASSEMBLE || eax==IDC_EDTPOOUTASSEMBLE
			invoke DoHelp,addr da.szAssembleHelp,addr da.szAssembleHelpKw
		.elseif eax==IDC_EDTPOLINK || eax==IDC_EDTPOOUTLINK
			invoke DoHelp,addr da.szLinkHelp,addr da.szLinkHelpKw
		.elseif eax==IDC_EDTPOLIB || eax==IDC_EDTPOOUTLIB
			invoke DoHelp,addr da.szLibHelp,addr da.szLibHelpKw
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

UpdateBtnDelete:
	invoke GetDlgItem,hWin,IDC_BTNPODELETE
	push	eax
	invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_GETCOUNT,0,0
	xor		edx,edx
	.if eax>1
		mov		edx,TRUE
	.endif
	pop		eax
	invoke EnableWindow,eax,edx
	retn

POUpdateList:
	invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_GETTEXT,ebx,addr tmpbuff
		xor		edi,edi
		.while tmpbuff[edi]!=VK_TAB
			inc		edi
		.endw
		mov		tmpbuff[edi],0
		invoke GetDlgItemText,hWin,IDC_EDTPORC,addr buffer,MAX_PATH
		invoke PutItemQuotedStr,addr tmpbuff,addr buffer
		invoke GetDlgItemText,hWin,IDC_EDTPOOUTRC,addr buffer,MAX_PATH
		invoke PutItemStr,addr tmpbuff,addr buffer
		invoke GetDlgItemText,hWin,IDC_EDTPOASSEMBLE,addr buffer,MAX_PATH
		invoke PutItemQuotedStr,addr tmpbuff,addr buffer
		invoke GetDlgItemText,hWin,IDC_EDTPOOUTASSEMBLE,addr buffer,MAX_PATH
		invoke PutItemStr,addr tmpbuff,addr buffer
		invoke GetDlgItemText,hWin,IDC_EDTPOLINK,addr buffer,MAX_PATH
		invoke PutItemQuotedStr,addr tmpbuff,addr buffer
		invoke GetDlgItemText,hWin,IDC_EDTPOOUTLINK,addr buffer,MAX_PATH
		invoke PutItemStr,addr tmpbuff,addr buffer
		invoke GetDlgItemText,hWin,IDC_EDTPOLIB,addr buffer,MAX_PATH
		invoke PutItemQuotedStr,addr tmpbuff,addr buffer
		invoke GetDlgItemText,hWin,IDC_EDTPOOUTLIB,addr buffer,MAX_PATH
		invoke PutItemStr,addr tmpbuff,addr buffer
		mov		tmpbuff[edi],VK_TAB
		invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_DELETESTRING,ebx,0
		invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_INSERTSTRING,ebx,addr tmpbuff
		invoke SendDlgItemMessage,hWin,IDC_LSTPO,LB_SETCURSEL,ebx,0
		invoke GetDlgItem,hWin,IDOK
		invoke EnableWindow,eax,TRUE
	.endif
	retn

ProjectOptionProc endp

