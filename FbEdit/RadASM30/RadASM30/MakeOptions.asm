
IDD_DLGMAKEOPTIONS			equ 3100
IDC_LSTMAKEOPT				equ 3123
IDC_BTNMAKEOPTADD			equ 3120
IDC_BTNMAKEOPPTDEL			equ 3118
IDC_BTNMAKEOPTHELP			equ 3122
IDC_EDTMAKEOPTNEW			equ 3119
IDC_EDTMAKEOPTRC			equ 3116
IDC_EDTMAKEOPTRCOUT			equ 3114
IDC_EDTMAKEOPTASM			equ 3112
IDC_EDTMAKEOPTASMOUT		equ 3110
IDC_EDTMAKEOPTLINK			equ 3108
IDC_EDTMAKEOPTLINKOUT		equ 3106
IDC_EDTMAKEOPTLIB			equ 3104
IDC_EDTMAKEOPTLIBOUT		equ 3102
IDC_EDTEXTDEBUG				equ 3121
IDC_BTNEXTDEBUG				equ 3122

.data?

tmpmake			MAKE 32 dup(<>)

.code

MakeOptionsProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	ofn:OPENFILENAME

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetWindowText,hWin,addr buffer,sizeof buffer
		invoke strcat,addr buffer,addr da.szAssembler
		invoke SetWindowText,hWin,addr buffer
		invoke SendDlgItemMessage,hWin,IDC_EDTMAKEOPTNEW,EM_LIMITTEXT,sizeof MAKE.szType-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTMAKEOPTRC,EM_LIMITTEXT,sizeof MAKE.szCompileRC-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTMAKEOPTRCOUT,EM_LIMITTEXT,sizeof MAKE.szOutCompileRC-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTMAKEOPTASM,EM_LIMITTEXT,sizeof MAKE.szAssemble-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTMAKEOPTASMOUT,EM_LIMITTEXT,sizeof MAKE.szOutAssemble-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTMAKEOPTLINK,EM_LIMITTEXT,sizeof MAKE.szLink-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTMAKEOPTLINKOUT,EM_LIMITTEXT,sizeof MAKE.szOutLink-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTMAKEOPTLIB,EM_LIMITTEXT,sizeof MAKE.szLib-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTMAKEOPTLIBOUT,EM_LIMITTEXT,sizeof MAKE.szOutLib-1,0
		invoke SendDlgItemMessage,hWin,IDC_EDTEXTDEBUG,EM_LIMITTEXT,sizeof da.szDebug-1,0
		xor		ebx,ebx
		mov		edi,offset tmpmake
		invoke RtlZeroMemory,edi,sizeof tmpmake
		.while ebx<32
			invoke BinToDec,ebx,addr buffer
			invoke GetPrivateProfileString,addr szIniMake,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
			.if eax
				invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szType,sizeof MAKE.szType
				invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szCompileRC,sizeof MAKE.szCompileRC
				invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szOutCompileRC,sizeof MAKE.szOutCompileRC
				invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szAssemble,sizeof MAKE.szAssemble
				invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szOutAssemble,sizeof MAKE.szOutAssemble
				invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szLink,sizeof MAKE.szLink
				invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szOutLink,sizeof MAKE.szOutLink
				invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szLib,sizeof MAKE.szLib
				invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szOutLib,sizeof MAKE.szOutLib
				invoke SendDlgItemMessage,hWin,IDC_LSTMAKEOPT,LB_ADDSTRING,0,addr [edi].MAKE.szType
				lea		edi,[edi+sizeof MAKE]
			.endif
			inc		ebx
		.endw
		invoke SetDlgItemText,hWin,IDC_EDTEXTDEBUG,addr da.szDebug
		invoke SendDlgItemMessage,hWin,IDC_LSTMAKEOPT,LB_SETCURSEL,0,0
		.if eax!=LB_ERR
			invoke SendMessage,hWin,WM_COMMAND,LBN_SELCHANGE shl 16 or IDC_LSTMAKEOPT,hWin
		.endif
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				mov		word ptr tmpbuff,0
				mov		esi,offset tmpmake
				xor		ebx,ebx
				.while ebx<32
					mov		word ptr tmpbuff,0
					.if [esi].MAKE.szType
						invoke PutItemStr,addr tmpbuff,addr [esi].MAKE.szType
						invoke PutItemQuotedStr,addr tmpbuff,addr [esi].MAKE.szCompileRC
						invoke PutItemStr,addr tmpbuff,addr [esi].MAKE.szOutCompileRC
						invoke PutItemQuotedStr,addr tmpbuff,addr [esi].MAKE.szAssemble
						invoke PutItemStr,addr tmpbuff,addr [esi].MAKE.szOutAssemble
						invoke PutItemQuotedStr,addr tmpbuff,addr [esi].MAKE.szLink
						invoke PutItemStr,addr tmpbuff,addr [esi].MAKE.szOutLink
						invoke PutItemQuotedStr,addr tmpbuff,addr [esi].MAKE.szLib
						invoke PutItemStr,addr tmpbuff,addr [esi].MAKE.szOutLib
					.endif
					invoke BinToDec,ebx,addr buffer
					invoke WritePrivateProfileString,addr szIniMake,addr buffer,addr tmpbuff[1],addr da.szAssemblerIni
					lea		esi,[esi+sizeof MAKE]
					inc		ebx
				.endw
				invoke GetDlgItemText,hWin,IDC_EDTEXTDEBUG,addr da.szDebug,sizeof da.szDebug
				invoke WritePrivateProfileString,addr szIniMake,addr szIniExtDebug,addr da.szDebug,addr da.szAssemblerIni
				invoke SendMessage,hWin,WM_CLOSE,NULL,TRUE
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNMAKEOPTADD
				invoke GetDlgItemText,hWin,IDC_EDTMAKEOPTNEW,addr buffer,sizeof buffer
				invoke SetDlgItemText,hWin,IDC_EDTMAKEOPTNEW,addr szNULL
				invoke SendDlgItemMessage,hWin,IDC_LSTMAKEOPT,LB_ADDSTRING,0,addr buffer
				mov		ebx,eax
				mov		edx,sizeof MAKE
				mul		edx
				lea		edi,tmpmake[eax]
				invoke strcpy,addr [edi].MAKE.szType,addr buffer
				invoke SendDlgItemMessage,hWin,IDC_LSTMAKEOPT,LB_SETCURSEL,ebx,0
				invoke SendDlgItemMessage,hWin,IDC_LSTMAKEOPT,LB_GETCOUNT,0,0
				.if eax>1
					invoke GetDlgItem,hWin,IDC_BTNMAKEOPPTDEL
					invoke EnableWindow,eax,TRUE
				.endif
				invoke SendMessage,hWin,WM_COMMAND,LBN_SELCHANGE shl 16 or IDC_LSTMAKEOPT,hWin
			.elseif eax==IDC_BTNMAKEOPPTDEL
				invoke SendDlgItemMessage,hWin,IDC_LSTMAKEOPT,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		ebx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTMAKEOPT,LB_DELETESTRING,ebx,0
					mov		edx,sizeof MAKE
					mul		edx
					lea		edi,tmpmake[eax]
					lea		esi,[edi+sizeof MAKE]
					mov		ecx,sizeof tmpmake
					add		ecx,esi
					sub		ecx,offset tmpmake
					rep movsb
					invoke RtlZeroMemory,edi,sizeof MAKE
					invoke SendDlgItemMessage,hWin,IDC_LSTMAKEOPT,LB_SETCURSEL,ebx,0
					.if eax==LB_ERR
						dec		ebx
						invoke SendDlgItemMessage,hWin,IDC_LSTMAKEOPT,LB_SETCURSEL,ebx,0
					.endif
					invoke SendDlgItemMessage,hWin,IDC_LSTMAKEOPT,LB_GETCOUNT,0,0
					.if eax<=1
						invoke GetDlgItem,hWin,IDC_BTNMAKEOPPTDEL
						invoke EnableWindow,eax,FALSE
					.endif
				.endif
			.elseif eax==IDC_BTNEXTDEBUG
				;Zero out the ofn struct
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				;Setup the ofn struct
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	ha.hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrFilter,offset da.szANYString
				invoke GetDlgItemText,hWin,IDC_EDTEXTDEBUG,addr buffer,sizeof buffer
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.lpstrDefExt,NULL
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke SetDlgItemText,hWin,IDC_EDTEXTDEBUG,addr buffer
				.endif
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTMAKEOPTNEW
				invoke GetDlgItem,hWin,IDC_BTNMAKEOPTADD
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_EDTMAKEOPTNEW,WM_GETTEXTLENGTH,0,0
				pop		edx
				invoke EnableWindow,edx,eax
			.elseif !fNoUpdate
				call	MakeOptUpdate
			.endif
		.elseif edx==LBN_SELCHANGE
			.if eax==IDC_LSTMAKEOPT
				invoke SendDlgItemMessage,hWin,IDC_LSTMAKEOPT,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		fNoUpdate,TRUE
					mov		edx,sizeof MAKE
					mul		edx
					lea		esi,tmpmake[eax]
					invoke SetDlgItemText,hWin,IDC_EDTMAKEOPTRC,addr [esi].MAKE.szCompileRC
					invoke SetDlgItemText,hWin,IDC_EDTMAKEOPTRCOUT,addr [esi].MAKE.szOutCompileRC
					invoke SetDlgItemText,hWin,IDC_EDTMAKEOPTASM,addr [esi].MAKE.szAssemble
					invoke SetDlgItemText,hWin,IDC_EDTMAKEOPTASMOUT,addr [esi].MAKE.szOutAssemble
					invoke SetDlgItemText,hWin,IDC_EDTMAKEOPTLINK,addr [esi].MAKE.szLink
					invoke SetDlgItemText,hWin,IDC_EDTMAKEOPTLINKOUT,addr [esi].MAKE.szOutLink
					invoke SetDlgItemText,hWin,IDC_EDTMAKEOPTLIB,addr [esi].MAKE.szLib
					invoke SetDlgItemText,hWin,IDC_EDTMAKEOPTLIBOUT,addr [esi].MAKE.szOutLib
					mov		fNoUpdate,FALSE
				.endif
			.endif
		.endif
	.elseif eax==WM_HELP
		mov		esi,lParam
		mov		eax,[esi].HELPINFO.iCtrlId
		.if eax==IDC_EDTMAKEOPTRC || eax==IDC_EDTMAKEOPTRCOUT
			invoke DoHelp,addr da.szCompileRCHelp,addr da.szCompileRCHelpKw
		.elseif eax==IDC_EDTMAKEOPTASM || eax==IDC_EDTMAKEOPTASMOUT
			invoke DoHelp,addr da.szAssembleHelp,addr da.szAssembleHelpKw
		.elseif eax==IDC_EDTMAKEOPTLINK || eax==IDC_EDTMAKEOPTLINKOUT
			invoke DoHelp,addr da.szLinkHelp,addr da.szLinkHelpKw
		.elseif eax==IDC_EDTMAKEOPTLIB || eax==IDC_EDTMAKEOPTLIBOUT
			invoke DoHelp,addr da.szLibHelp,addr da.szLibHelpKw
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,lParam
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

MakeOptUpdate:
	invoke SendDlgItemMessage,hWin,IDC_LSTMAKEOPT,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		mov		edx,sizeof MAKE
		mul		edx
		lea		esi,tmpmake[eax]
		invoke GetDlgItemText,hWin,IDC_EDTMAKEOPTRC,addr [esi].MAKE.szCompileRC,sizeof MAKE.szCompileRC
		invoke GetDlgItemText,hWin,IDC_EDTMAKEOPTRCOUT,addr [esi].MAKE.szOutCompileRC,sizeof MAKE.szOutCompileRC
		invoke GetDlgItemText,hWin,IDC_EDTMAKEOPTASM,addr [esi].MAKE.szAssemble,sizeof MAKE.szAssemble
		invoke GetDlgItemText,hWin,IDC_EDTMAKEOPTASMOUT,addr [esi].MAKE.szOutAssemble,sizeof MAKE.szOutAssemble
		invoke GetDlgItemText,hWin,IDC_EDTMAKEOPTLINK,addr [esi].MAKE.szLink,sizeof MAKE.szLink
		invoke GetDlgItemText,hWin,IDC_EDTMAKEOPTLINKOUT,addr [esi].MAKE.szOutLink,sizeof MAKE.szOutLink
		invoke GetDlgItemText,hWin,IDC_EDTMAKEOPTLIB,addr [esi].MAKE.szLib,sizeof MAKE.szLib
		invoke GetDlgItemText,hWin,IDC_EDTMAKEOPTLIBOUT,addr [esi].MAKE.szOutLib,sizeof MAKE.szOutLib
	.endif
	retn

MakeOptionsProc endp
