
;ProjectOption.dlg
IDD_DLGOPTION					equ 3000
IDC_EDTBACKUP					equ 1001
IDC_UDNBACKUP					equ 1002
IDC_EDTTEXT						equ 1003
IDC_EDTBINARY					equ 1004
IDC_EDTMINOR					equ 1005

.code

ProjectOptionProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
        invoke SendDlgItemMessage,hWin,IDC_UDNBACKUP,UDM_SETRANGE,0,9				; Set range
        invoke SendDlgItemMessage,hWin,IDC_UDNBACKUP,UDM_SETPOS,0,nBackup			; Set default value
		invoke SendDlgItemMessage,hWin,IDC_EDTTEXT,EM_LIMITTEXT,255,0
		invoke SetDlgItemText,hWin,IDC_EDTTEXT,offset szTxt
		invoke SendDlgItemMessage,hWin,IDC_EDTBINARY,EM_LIMITTEXT,255,0
		invoke SetDlgItemText,hWin,IDC_EDTBINARY,offset szBin
		mov		ebx,lpData
		.if [ebx].ADDINDATA.szSessionFile
			invoke GetDlgItem,hWin,IDC_EDTMINOR
			invoke EnableWindow,eax,TRUE
			invoke GetPrivateProfileString,addr szSession,addr szMinorFiles,addr szNULL,addr buffer,sizeof buffer,addr [ebx].ADDINDATA.szSessionFile
			invoke SetDlgItemText,hWin,IDC_EDTMINOR,addr buffer
		.endif
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				mov		ebx,lpHandles
				invoke GetDlgItemInt,hWin,IDC_EDTBACKUP,offset nBackup,FALSE
				mov		nBackup,eax
				invoke RegSetValueEx,[ebx].ADDINHANDLES.hReg,addr szBackups,0,REG_DWORD,addr nBackup,4
				invoke GetDlgItemText,hWin,IDC_EDTTEXT,offset szTxt,sizeof szTxt
				invoke RegSetValueEx,[ebx].ADDINHANDLES.hReg,addr szTextFiles,0,REG_SZ,addr szTxt,addr [eax+1]
				invoke GetDlgItemText,hWin,IDC_EDTBINARY,offset szBin,sizeof szBin
				invoke RegSetValueEx,[ebx].ADDINHANDLES.hReg,addr szBinaryFiles,0,REG_SZ,addr szBin,addr [eax+1]
				mov		ebx,lpData
				.if [ebx].ADDINDATA.szSessionFile
					invoke GetDlgItemText,hWin,IDC_EDTMINOR,addr buffer,sizeof buffer-1
					invoke WritePrivateProfileString,addr szSession,addr szMinorFiles,addr buffer,addr [ebx].ADDINDATA.szSessionFile
				.endif
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

ProjectOptionProc endp
