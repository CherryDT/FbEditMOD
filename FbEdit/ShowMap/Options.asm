
IDD_DLGCOMPORT          equ 1400
IDC_CHKCOMACTIVE        equ 1401
IDC_EDTCOMPORT          equ 1402
IDC_CBOCOMBAUD          equ 1404
IDC_CBOCOMBITS          equ 1405
IDC_CBOCOMSTOP          equ 1407
IDC_CHKCOMPARITY		equ 1403

IDD_DLGOPTION           equ 1200
IDC_CHKSHOW             equ 1201
IDC_RBNLEFTTOP          equ 1220
IDC_RBNCENTERTOP        equ 1221
IDC_RBNRIGHTTOP         equ 1222
IDC_RBNLEFTBOTTOM       equ 1223
IDC_RBNCENTERBOTTOM     equ 1224
IDC_RBNRIGHTBOTTOM      equ 1225
IDC_CBOOVLFONT          equ 1207
IDC_BTNUP               equ 1210
IDC_BTNRIGHT            equ 1211
IDC_BTNDOWN             equ 1212
IDC_BTNLEFT             equ 1213

.const

szCom1					BYTE 'COM1',0
nBaud					DWORD 4800,9600,19200,38400,-1
nBits					DWORD 7,8,-1
nStop					DWORD 0,1,-1

szSpeed					BYTE 'Speed Options',0
szBattery				BYTE 'Battery Options',0
szTemprature			BYTE 'Temprature Options',0
szScale					BYTE 'Map Scale Options',0
szTime					BYTE 'Time Options',0
szRange					BYTE 'Range Options',0
szDepth					BYTE 'Depth Options',0
szShowOnSonar			BYTE 'Show on sonar screen',0

szOptionFonts			BYTE 'Small',0
						BYTE 'Medium',0
						BYTE 'Large',0,0

.data?

nOptType				DWORD ?
coptions				OPTIONS 10 dup(<>)

.code

InitCom proc
	LOCAL	buffer[256]:BYTE

	invoke GetPrivateProfileString,addr szIniCom,addr szIniCom,addr szNULL,addr buffer,sizeof buffer,addr szIniFileName
	invoke GetItemInt,addr buffer,0
	mov		map.comopt.active,eax
	invoke GetItemStr,addr buffer,addr szCom1,addr map.comopt.szcom,sizeof map.comopt.szcom
	invoke GetItemInt,addr buffer,4800
	mov		map.comopt.nbaud,eax
	invoke GetItemInt,addr buffer,8
	mov		map.comopt.nbits,eax
	invoke GetItemInt,addr buffer,0
	mov		map.comopt.nparity,eax
	invoke GetItemInt,addr buffer,0
	mov		map.comopt.nstop,eax
	ret

InitCom endp

SaveComOption proc
	LOCAL	buffer[256]:BYTE

	mov		buffer,0
	invoke PutItemInt,addr buffer,map.comopt.active
	invoke PutItemStr,addr buffer,addr map.comopt.szcom
	invoke PutItemInt,addr buffer,map.comopt.nbaud
	invoke PutItemInt,addr buffer,map.comopt.nbits
	invoke PutItemInt,addr buffer,map.comopt.nparity
	invoke PutItemInt,addr buffer,map.comopt.nstop
	invoke WritePrivateProfileString,addr szIniCom,addr szIniCom,addr buffer[1],addr szIniFileName
	ret

SaveComOption endp

ComOptionProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
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
		.while dword ptr [esi]!=-1
			invoke BinToDec,dword ptr [esi],addr buffcom
			invoke SendDlgItemMessage,hWin,IDC_CBOCOMSTOP,CB_ADDSTRING,0,addr buffcom
			lea		esi,[esi+4]
		.endw
		.if map.comopt.active
			invoke CheckDlgButton,hWin,IDC_CHKCOMACTIVE,BST_CHECKED
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTCOMPORT,addr map.comopt.szcom
		invoke BinToDec,map.comopt.nbaud,addr buffcom
		invoke SendDlgItemMessage,hWin,IDC_CBOCOMBAUD,CB_FINDSTRINGEXACT,-1,addr buffcom
		invoke SendDlgItemMessage,hWin,IDC_CBOCOMBAUD,CB_SETCURSEL,eax,0
		invoke BinToDec,map.comopt.nbits,addr buffcom
		invoke SendDlgItemMessage,hWin,IDC_CBOCOMBITS,CB_FINDSTRINGEXACT,-1,addr buffcom
		invoke SendDlgItemMessage,hWin,IDC_CBOCOMBITS,CB_SETCURSEL,eax,0
		.if map.comopt.nparity
			invoke CheckDlgButton,hWin,IDC_CHKCOMPARITY,BST_CHECKED
		.endif
		invoke BinToDec,map.comopt.nstop,addr buffcom
		invoke SendDlgItemMessage,hWin,IDC_CBOCOMSTOP,CB_FINDSTRINGEXACT,-1,addr buffcom
		invoke SendDlgItemMessage,hWin,IDC_CBOCOMSTOP,CB_SETCURSEL,eax,0
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke IsDlgButtonChecked,hWin,IDC_CHKCOMACTIVE
				mov		map.comopt.active,eax
				invoke GetDlgItemText,hWin,IDC_EDTCOMPORT,addr map.comopt.szcom,sizeof COM.szcom
				invoke SendDlgItemMessage,hWin,IDC_CBOCOMBAUD,CB_GETCURSEL,0,0
				mov		edx,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOCOMBAUD,CB_GETLBTEXT,edx,addr buffcom
				invoke DecToBin,addr buffcom
				mov		map.comopt.nbaud,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOCOMBITS,CB_GETCURSEL,0,0
				mov		edx,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOCOMBITS,CB_GETLBTEXT,edx,addr buffcom
				invoke DecToBin,addr buffcom
				mov		map.comopt.nbits,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOCOMSTOP,CB_GETCURSEL,0,0
				mov		edx,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOCOMSTOP,CB_GETLBTEXT,edx,addr buffcom
				invoke DecToBin,addr buffcom
				mov		map.comopt.nstop,eax
				invoke IsDlgButtonChecked,hWin,IDC_CHKCOMPARITY
				mov		map.comopt.nparity,eax
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

InitOptions proc uses ebx esi
	LOCAL	buffer[256]:BYTE

	xor		ebx,ebx
	mov		esi,offset map.options
	.while ebx<MAXMAPOPTION
		invoke BinToDec,ebx,addr buffer
		invoke GetPrivateProfileString,addr szIniOption,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr szIniFileName
		.if eax
			invoke GetItemInt,addr buffer,1
			mov		[esi].OPTIONS.show,eax
			invoke GetItemInt,addr buffer,ebx
			mov		[esi].OPTIONS.position,eax
			invoke GetItemInt,addr buffer,0
			mov		[esi].OPTIONS.pt.x,eax
			invoke GetItemInt,addr buffer,0
			mov		[esi].OPTIONS.pt.y,eax
			invoke GetItemInt,addr buffer,0
			mov		[esi].OPTIONS.font,eax
			invoke strcpy,addr [esi].OPTIONS.text,addr buffer
		.endif
		lea		esi,[esi+sizeof OPTIONS]
		inc		ebx
	.endw
	xor		ebx,ebx
	mov		esi,offset sonardata.options
	.while ebx<MAXSONAROPTION
		lea		edx,[ebx+10]
		invoke BinToDec,edx,addr buffer
		invoke GetPrivateProfileString,addr szIniOption,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr szIniFileName
		.if eax
			invoke GetItemInt,addr buffer,1
			mov		[esi].OPTIONS.show,eax
			invoke GetItemInt,addr buffer,ebx
			mov		[esi].OPTIONS.position,eax
			invoke GetItemInt,addr buffer,0
			mov		[esi].OPTIONS.pt.x,eax
			invoke GetItemInt,addr buffer,0
			mov		[esi].OPTIONS.pt.y,eax
			invoke GetItemInt,addr buffer,0
			mov		[esi].OPTIONS.font,eax
			invoke strcpy,addr [esi].OPTIONS.text,addr buffer
		.endif
		lea		esi,[esi+sizeof OPTIONS]
		inc		ebx
	.endw
	ret

InitOptions endp

SaveOption proc uses ebx esi,nOpt:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffname[8]:BYTE

	mov		eax,nOpt
	mov		ecx,sizeof OPTIONS
	.if eax<10
		mov		esi,offset map.options
	.else
		mov		esi,offset sonardata.options
		sub		eax,10
	.endif
	mul		ecx
	mov		ebx,eax
	mov		buffer,0
	invoke PutItemInt,addr buffer,[esi].OPTIONS.show[ebx]
	invoke PutItemInt,addr buffer,[esi].OPTIONS.position[ebx]
	invoke PutItemInt,addr buffer,[esi].OPTIONS.pt.x[ebx]
	invoke PutItemInt,addr buffer,[esi].OPTIONS.pt.y[ebx]
	invoke PutItemInt,addr buffer,[esi].OPTIONS.font[ebx]
	invoke PutItemStr,addr buffer,addr [esi].OPTIONS.text[ebx]
	invoke BinToDec,nOpt,addr buffname
	invoke WritePrivateProfileString,addr szIniOption,addr buffname,addr buffer[1],addr szIniFileName
	ret

SaveOption endp

OptionsProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,lParam
		.if eax<10
			mov		esi,offset map.options
			mov		ecx,sizeof OPTIONS*MAXMAPOPTION
		.else
			invoke SetDlgItemText,hWin,IDC_CHKSHOW,addr szShowOnSonar
			mov		esi,offset sonardata.options
			mov		ecx,sizeof OPTIONS*MAXSONAROPTION
		.endif
		mov		edi,offset coptions
		rep		movsb
		mov		eax,lParam
		mov		nOptType,eax
		.if !eax
			mov		eax,offset szSpeed
		.elseif eax==1
			mov		eax,offset szBattery
		.elseif eax==2
			mov		eax,offset szTemprature
		.elseif eax==3
			mov		eax,offset szScale
		.elseif eax==4
			mov		eax,offset szTime
		.elseif eax==10
			mov		eax,offset szRange
		.elseif eax==11
			mov		eax,offset szDepth
		.elseif eax==12
			mov		eax,offset szTemprature
		.endif
		invoke SetWindowText,hWin,eax
		mov		eax,nOptType
		mov		ecx,sizeof OPTIONS
		.if eax<10
			mov		esi,offset map.options
		.else
			mov		esi,offset sonardata.options
			sub		eax,10
		.endif
		mul		ecx
		mov		ebx,eax
		mov		eax,BST_UNCHECKED
		.if [esi].OPTIONS.show[ebx]
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKSHOW,eax
		mov		eax,[esi].OPTIONS.position[ebx]
		invoke CheckDlgButton,hWin,addr [eax+IDC_RBNLEFTTOP],BST_CHECKED
		mov		edi,offset szOptionFonts
		.while byte ptr [edi]
			invoke SendDlgItemMessage,hWin,IDC_CBOOVLFONT,CB_ADDSTRING,0,edi
			invoke strlen,edi
			lea		edi,[edi+eax+1]
		.endw
		invoke SendDlgItemMessage,hWin,IDC_CBOOVLFONT,CB_SETCURSEL,[esi].OPTIONS.font[ebx],0
		invoke ImageList_GetIcon,hIml,0,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNUP,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,hIml,2,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNRIGHT,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,hIml,4,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNDOWN,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,hIml,6,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNLEFT,BM_SETIMAGE,IMAGE_ICON,eax
	.elseif eax==WM_COMMAND
		mov		eax,nOptType
		.if eax>=10
			sub		eax,10
		.endif
		mov		ecx,sizeof OPTIONS
		mul		ecx
		mov		ebx,eax
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SaveOption,nOptType
				invoke SendMessage,hWin,WM_CLOSE,NULL,TRUE
			.elseif eax==IDCANCEL
				;Restore old values
				.if nOptType<10
					mov		edi,offset map.options
					mov		ecx,sizeof OPTIONS*MAXMAPOPTION
				.else
					mov		edi,offset sonardata.options
					mov		ecx,sizeof OPTIONS*MAXSONAROPTION
				.endif
				mov		esi,offset coptions
				rep		movsb
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
				inc		map.paintnow
				invoke InvalidateRect,hSonar,NULL,TRUE
			.elseif eax==IDC_CHKSHOW
				invoke IsDlgButtonChecked,hWin,IDC_CHKSHOW
				.if nOptType<10
					mov		map.options.show[ebx],eax
					inc		map.paintnow
				.else
					mov		sonardata.options.show[ebx],eax
					invoke InvalidateRect,hSonar,NULL,TRUE
				.endif
			.elseif eax>=IDC_RBNLEFTTOP && eax<=IDC_RBNRIGHTBOTTOM
				sub		eax,IDC_RBNLEFTTOP
				.if nOptType<10
					mov		map.options.position[ebx],eax
					inc		map.paintnow
				.else
					mov		sonardata.options.position[ebx],eax
					invoke InvalidateRect,hSonar,NULL,TRUE
				.endif
			.elseif eax==IDC_BTNUP
				.if nOptType<10
					.if map.options.position[ebx]<=2
						sub		map.options.pt.y[ebx],2
					.else
						add		map.options.pt.y[ebx],2
					.endif
					inc		map.paintnow
				.else
					.if sonardata.options.position[ebx]<=2
						sub		sonardata.options.pt.y[ebx],2
					.else
						add		sonardata.options.pt.y[ebx],2
					.endif
					invoke InvalidateRect,hSonar,NULL,TRUE
				.endif
			.elseif eax==IDC_BTNRIGHT
				.if nOptType<10
					mov		eax,map.options.position[ebx]
					.if eax==0 || eax==3
						add		map.options.pt.x[ebx],2
					.else
						sub		map.options.pt.x[ebx],2
					.endif
					inc		map.paintnow
				.else
					mov		eax,sonardata.options.position[ebx]
					.if eax==0 || eax==3
						add		sonardata.options.pt.x[ebx],2
					.else
						sub		sonardata.options.pt.x[ebx],2
					.endif
					invoke InvalidateRect,hSonar,NULL,TRUE
				.endif
			.elseif eax==IDC_BTNDOWN
				.if nOptType<10
					.if map.options.position[ebx]<=2
						add		map.options.pt.y[ebx],2
					.else
						sub		map.options.pt.y[ebx],2
					.endif
					inc		map.paintnow
				.else
					.if sonardata.options.position[ebx]<=2
						add		sonardata.options.pt.y[ebx],2
					.else
						sub		sonardata.options.pt.y[ebx],2
					.endif
					invoke InvalidateRect,hSonar,NULL,TRUE
				.endif
			.elseif eax==IDC_BTNLEFT
				.if nOptType<10
					mov		eax,map.options.position[ebx]
					.if eax==0 || eax==3
						sub		map.options.pt.x[ebx],2
					.else
						add		map.options.pt.x[ebx],2
					.endif
					inc		map.paintnow
				.else
					mov		eax,sonardata.options.position[ebx]
					.if eax==0 || eax==3
						sub		sonardata.options.pt.x[ebx],2
					.else
						add		sonardata.options.pt.x[ebx],2
					.endif
					invoke InvalidateRect,hSonar,NULL,TRUE
				.endif
			.endif
		.elseif edx==CBN_SELCHANGE
			invoke SendDlgItemMessage,hWin,IDC_CBOOVLFONT,CB_GETCURSEL,0,0
			.if nOptType<10
				mov		map.options.font[ebx],eax
				inc		map.paintnow
			.else
				mov		sonardata.options.font[ebx],eax
				invoke InvalidateRect,hSonar,NULL,TRUE
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

OptionsProc endp
