
IDD_ENVIRONMENTOPTION			equ 3300
IDC_BTNENVIRONMENTADD			equ 1001
IDC_BTNENVIRONMENTDEL			equ 1002
IDC_LSTENVIRONMENT				equ 1003
IDC_EDTENVIRONMENTNAME			equ 1005
IDC_EDTENVIRONMENTVALUE			equ 1004

.data?

hEnvMem		dd ?
pNextVal	dd ?

.code

EnvironmentOptionsProc proc uses ebx edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[1536]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetWindowText,hWin,addr buffer,sizeof buffer
		invoke strcat,addr buffer,addr da.szAssembler
		invoke SetWindowText,hWin,addr buffer
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
		mov		hEnvMem,eax
		mov		edi,eax
		xor		ebx,ebx
		.while TRUE
			invoke BinToDec,ebx,addr buffer
			invoke GetPrivateProfileString,addr szIniEnvironment,addr buffer,NULL,edi,1024,addr da.szAssemblerIni
		  .break .if !eax
			invoke GetItemStr,edi,addr szNULL,addr buffer,sizeof buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_ADDSTRING,0,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_SETITEMDATA,eax,edi
			add		edi,1024
			inc		ebx
		.endw
		mov		pNextVal,edi
		.if edi==hEnvMem
			mov		buffer,0
			invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_ADDSTRING,0,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_SETITEMDATA,eax,edi
		.endif
		invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_SETCURSEL,0,0
		call	SetEdit
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				mov		word ptr buffer,0
				invoke WritePrivateProfileSection,addr szIniEnvironment,addr buffer,addr da.szAssemblerIni
				xor		ebx,ebx
				xor		eax,eax
				.while eax!=LB_ERR
					invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_GETTEXT,ebx,addr buffer
					.if eax!=LB_ERR && eax
						invoke strcat,addr buffer,addr szComma
						invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_GETITEMDATA,ebx,0
						invoke strcat,addr buffer,eax
						invoke BinToDec,ebx,addr tmpbuff
						invoke WritePrivateProfileString,addr szIniEnvironment,addr tmpbuff,addr buffer,addr da.szAssemblerIni
						xor		eax,eax
					.endif
					inc		ebx
				.endw
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
				invoke SetEnvironment
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNENVIRONMENTADD
				mov		buffer,0
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_ADDSTRING,0,addr buffer
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_SETITEMDATA,eax,pNextVal
				pop		eax
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_SETCURSEL,eax,0
				add		pNextVal,1024
				call	SetEdit
			.elseif eax==IDC_BTNENVIRONMENTDEL
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_GETCURSEL,0,0
				mov		ebx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_DELETESTRING,ebx,0
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_SETCURSEL,ebx,0
				.if eax==LB_ERR
					dec		ebx
					invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_SETCURSEL,ebx,0
				.endif
				call	SetEdit
			.endif
		.elseif edx==EN_CHANGE
			push	eax
			invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_GETCURSEL,0,0
			mov		ebx,eax
			pop		eax
			.if eax==IDC_EDTENVIRONMENTNAME
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_GETITEMDATA,ebx,0
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_DELETESTRING,ebx,0
				invoke GetDlgItemText,hWin,IDC_EDTENVIRONMENTNAME,addr buffer,128
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_INSERTSTRING,ebx,addr buffer
				pop		eax
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_SETITEMDATA,ebx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_SETCURSEL,ebx,0
			.elseif eax==IDC_EDTENVIRONMENTVALUE
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_GETITEMDATA,ebx,0
				invoke GetDlgItemText,hWin,IDC_EDTENVIRONMENTVALUE,eax,1024
			.endif
		.elseif edx==LBN_SELCHANGE
			call	SetEdit
		.endif
	.elseif eax==WM_CLOSE
		invoke GlobalFree,hEnvMem
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

SetEdit:
	invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		push	eax
		invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_GETITEMDATA,eax,0
		invoke SetDlgItemText,hWin,IDC_EDTENVIRONMENTVALUE,eax
		pop		edx
		invoke SendDlgItemMessage,hWin,IDC_LSTENVIRONMENT,LB_GETTEXT,edx,addr buffer
		invoke SetDlgItemText,hWin,IDC_EDTENVIRONMENTNAME,addr buffer
	.else
		mov		buffer,0
		invoke SetDlgItemText,hWin,IDC_EDTENVIRONMENTNAME,addr buffer
		invoke SetDlgItemText,hWin,IDC_EDTENVIRONMENTVALUE,addr buffer
	.endif
	retn

EnvironmentOptionsProc endp
