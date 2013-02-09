.const

szCom1					BYTE 'COM1',0
nBaud					DWORD 4800,9600,14400,19200,38400,57600,115200,-1
nBits					DWORD 7,8,-1
nStop					DWORD 0,1,2,-1
szStop					BYTE '1',0,'1.5',0,'2',0,0

.data?

hThreadRD				HANDLE ?

.code

InitCom proc
	LOCAL	buffer[256]:BYTE

	invoke GetPrivateProfileString,addr szIniCom,addr szIniCom,addr szNULL,addr buffer,sizeof buffer,addr szinifile
	invoke GetItemInt,addr buffer,0
	mov		comopt.active,eax
	invoke GetItemStr,addr buffer,addr szCom1,addr comopt.szcom,sizeof comopt.szcom
	invoke GetItemInt,addr buffer,4800
	mov		comopt.nbaud,eax
	invoke GetItemInt,addr buffer,8
	mov		comopt.nbits,eax
	invoke GetItemInt,addr buffer,0
	mov		comopt.nparity,eax
	invoke GetItemInt,addr buffer,0
	mov		comopt.nstop,eax
	ret

InitCom endp

OpenCom proc

	.if hCom
		invoke CloseHandle,hCom
		mov		hCom,0
	.endif
	.if comopt.active
		invoke CreateFile,addr comopt.szcom,GENERIC_READ or GENERIC_WRITE,NULL,NULL,OPEN_EXISTING,NULL,NULL
		.if eax!=INVALID_HANDLE_VALUE
			mov		hCom,eax
			mov		dcb.DCBlength,sizeof DCB
			mov		eax,comopt.nbaud
			mov		dcb.BaudRate,eax
			mov		eax,comopt.nbits
			mov		dcb.ByteSize,al
			mov		eax,comopt.nparity
			mov		dcb.Parity,al
			mov		eax,comopt.nstop
			mov		dcb.StopBits,al
			invoke SetCommState,hCom,addr dcb
			mov		to.ReadTotalTimeoutConstant,1
			mov		to.WriteTotalTimeoutConstant,10
			invoke SetCommTimeouts,hCom,addr to
			invoke WriteCom,9Fh
		.else
			invoke MessageBox,hWnd,addr szComFailed,addr szCOM,MB_ICONERROR or MB_YESNO
			.if eax==IDNO
				invoke SendMessage,hWnd,WM_CLOSE,0,0
			.endif
		.endif
	.endif
	ret

OpenCom endp

WriteCom proc uses edi nChr:DWORD

	.if !hrdfile
		mov		edx,wrhead
		inc		edx
		and		edx,sizeof wrbuff-1
		.if edx!=wrtail
			mov		edx,wrhead
			mov		eax,nChr
			mov		wrbuff[edx],al
			inc		edx
			and		edx,sizeof wrbuff-1
			mov		wrhead,edx
		.endif
	.endif
	ret

WriteCom endp

DoComm proc Param:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	txbuff[256]:BYTE
	LOCAL	rxbuff[256]:BYTE
	LOCAL	nRead:DWORD
	LOCAL	nWrite:DWORD

	.while hCom && !fExit
		mov		nRead,0
		mov		nWrite,0
		call	RxByte
		call	TxByte
		.if hrdfile
			mov		edx,wrhead
			inc		edx
			and		edx,sizeof wrbuff-1
			.if edx!=wrtail
				inc		edx
				and		edx,sizeof wrbuff-1
				.if edx!=wrtail
					invoke ReadFile,hrdfile,addr buffer,1,addr nRead,NULL
					.if !nRead
						invoke CloseHandle,hrdfile
						mov		hrdfile,0
						mov		buffer,0
					.elseif fprogrom
						call	PutByteHex
					.else
						call	PutByte
					.endif
				.endif
			.endif
		.endif
		.if hrdblock && fblockmode
			invoke ReadFile,hrdblock,addr buffer,16,addr nRead,NULL
			mov		eax,nRead
			.while eax<16
				mov		buffer[eax],0FFh
				inc		eax
			.endw
			invoke WriteFile,hCom,addr buffer,16,addr nWrite,NULL
			mov		fblockmode,FALSE
		.endif
		.if !nRead && !nWrite
			invoke Sleep,2
		.endif
	.endw
	ret

RxByte:
	mov		edx,rdhead
	inc		edx
	and		edx,sizeof rdbuff-1
	.if edx!=rdtail
		invoke ReadFile,hCom,addr rxbuff,256,addr nRead,NULL
		.if eax
			.if nRead
				xor		ebx,ebx
				mov		ecx,nRead
				.while ecx
					mov		edx,rdhead
					movzx	eax,rxbuff[ebx]
					mov		rdbuff[edx],al
					inc		edx
					and		edx,sizeof rdbuff-1
					mov		rdhead,edx
					inc		ebx
					dec		ecx
				.endw
			.endif
		.else
			mov		hCom,0
			.while !hCom
			.endw
		.endif
	.endif
	retn

TxByte:
	mov		edx,wrtail
	.if edx!=wrhead
		movzx	eax,wrbuff[edx]
		mov		txbuff,al
		invoke WriteFile,hCom,addr txbuff,1,addr nWrite,NULL
		.if nWrite
			mov		edx,wrtail
			inc		edx
			and		edx,sizeof wrbuff-1
			mov		wrtail,edx
		.endif
	.endif
	retn

PutByte:
	mov		edx,wrhead
	movzx	eax,buffer
	mov		wrbuff[edx],al
	inc		edx
	and		edx,sizeof wrbuff-1
	mov		wrhead,edx
	inc		nWrite
	retn

PutByteHex:
	.while TRUE
		mov		edx,wrtail
		.break .if edx==wrhead
		call	TxByte
	.endw
	movzx	eax,buffer
	push	eax
	shr		eax,4
	call	ToHex
	pop		eax
	call	ToHex
	retn

ToHex:
	and     eax,0fh
	cmp     eax,0ah
	jb      ToHex1
	add     eax,07h
ToHex1:
	add     eax,30h
	mov		edx,wrhead
	mov		wrbuff[edx],al
	inc		edx
	and		edx,sizeof wrbuff-1
	mov		wrhead,edx
	inc		nWrite
	retn

DoComm endp

SaveComOption proc
	LOCAL	buffer[256]:BYTE

	mov		buffer,0
	invoke PutItemInt,addr buffer,comopt.active
	invoke PutItemStr,addr buffer,addr comopt.szcom
	invoke PutItemInt,addr buffer,comopt.nbaud
	invoke PutItemInt,addr buffer,comopt.nbits
	invoke PutItemInt,addr buffer,comopt.nparity
	invoke PutItemInt,addr buffer,comopt.nstop
	invoke WritePrivateProfileString,addr szIniCom,addr szIniCom,addr buffer[1],addr szinifile
	invoke OpenCom
	ret

SaveComOption endp

ComOptionProc proc uses esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffcom[16]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		esi,offset nBaud
		.while dword ptr [esi]!=-1
			invoke BinToDec,dword ptr [esi],addr buffcom
			invoke SendDlgItemMessage,hWin,IDC_CBOCOMBAUD,CB_ADDSTRING,0,addr buffcom
			lea		esi,[esi+4]
		.endw
		mov		esi,offset nBits
		.while dword ptr [esi]!=-1
			invoke BinToDec,dword ptr [esi],addr buffcom
			invoke SendDlgItemMessage,hWin,IDC_CBOCOMBITS,CB_ADDSTRING,0,addr buffcom
			lea		esi,[esi+4]
		.endw
		mov		esi,offset nStop
		mov		edi,offset szStop
		.while dword ptr [esi]!=-1
			invoke SendDlgItemMessage,hWin,IDC_CBOCOMSTOP,CB_ADDSTRING,0,edi
			invoke lstrlen,edi
			lea		edi,[edi+eax+1]
			lea		esi,[esi+4]
		.endw
		.if comopt.active
			invoke CheckDlgButton,hWin,IDC_CHKCOMACTIVE,BST_CHECKED
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTCOMPORT,addr comopt.szcom
		invoke BinToDec,comopt.nbaud,addr buffcom
		invoke SendDlgItemMessage,hWin,IDC_CBOCOMBAUD,CB_FINDSTRINGEXACT,-1,addr buffcom
		invoke SendDlgItemMessage,hWin,IDC_CBOCOMBAUD,CB_SETCURSEL,eax,0
		invoke BinToDec,comopt.nbits,addr buffcom
		invoke SendDlgItemMessage,hWin,IDC_CBOCOMBITS,CB_FINDSTRINGEXACT,-1,addr buffcom
		invoke SendDlgItemMessage,hWin,IDC_CBOCOMBITS,CB_SETCURSEL,eax,0
		.if comopt.nparity
			invoke CheckDlgButton,hWin,IDC_CHKCOMPARITY,BST_CHECKED
		.endif
		invoke SendDlgItemMessage,hWin,IDC_CBOCOMSTOP,CB_SETCURSEL,comopt.nstop,0
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke IsDlgButtonChecked,hWin,IDC_CHKCOMACTIVE
				mov		comopt.active,eax
				invoke GetDlgItemText,hWin,IDC_EDTCOMPORT,addr comopt.szcom,sizeof COM.szcom
				invoke SendDlgItemMessage,hWin,IDC_CBOCOMBAUD,CB_GETCURSEL,0,0
				mov		edx,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOCOMBAUD,CB_GETLBTEXT,edx,addr buffcom
				invoke DecToBin,addr buffcom
				mov		comopt.nbaud,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOCOMBITS,CB_GETCURSEL,0,0
				mov		edx,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOCOMBITS,CB_GETLBTEXT,edx,addr buffcom
				invoke DecToBin,addr buffcom
				mov		comopt.nbits,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOCOMSTOP,CB_GETCURSEL,0,0
				mov		comopt.nstop,eax
				invoke IsDlgButtonChecked,hWin,IDC_CHKCOMPARITY
				mov		comopt.nparity,eax
				invoke SaveComOption
				.if hCom
					invoke CloseHandle,hCom
					mov		hCom,0
				.endif
				invoke SendMessage,hWin,WM_CLOSE,NULL,TRUE
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,FALSE
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,lParam
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

ComOptionProc endp

