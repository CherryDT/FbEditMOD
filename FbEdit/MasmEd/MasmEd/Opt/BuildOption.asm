
IDD_PATHOPTION		equ 3500
IDC_EDTBIN			equ 1001
IDC_EDTINC			equ 1002
IDC_EDTLIB			equ 1003
IDC_BTNPATHRESTORE	equ 1004

IDD_BUILDOPTION		equ 3400
IDC_TABBUILD		equ 1005
IDC_EDTRES			equ 1001
IDC_EDTASM			equ 1002
IDC_EDTLNK			equ 1003
IDC_BTNADDBUILD		equ 1008
IDC_BTNDELBUILD		equ 1009
IDC_BTNRESTORE		equ 1004
IDC_CBOTYPE			equ 1006
IDC_CBOOUT			equ 1007

IDD_BUILDOPTIONADD	equ 3490
IDC_EDTMAKETYPE		equ 1001

.const

szPath				db 'path',0
szInclude			db 'include',0
szIncludelib		db 'lib',0
szMakeOption		db 'Make Commands',0
makeoptdef			MAKEOPT <'Window Release','rc /v','ml /c /coff /Cp','link /SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0',0>
					MAKEOPT <'Window Debug','rc /v','ml /c /coff /Cp /Zi /Zd','link /SUBSYSTEM:WINDOWS /DEBUG /VERSION:4.0',0>
					MAKEOPT <'Console Release','rc /v','ml /c /coff /Cp','link /SUBSYSTEM:CONSOLE /RELEASE /VERSION:4.0',0>
					MAKEOPT <'Console Debug','rc /v','ml /c /coff /Cp /Zi /Zd','link /SUBSYSTEM:CONSOLE /DEBUG /VERSION:4.0,0'>
					MAKEOPT <'Dll Release','rc /v','ml /c /coff /Cp','link /SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 /DLL /DEF:',1>
					MAKEOPT <'Dll Debug','rc /v','ml /c /coff /Cp /Zi /Zd','link /SUBSYSTEM:WINDOWS /DEBUG /VERSION:4.0 /DLL /DEF:',1>
					MAKEOPT <'Library',,'ml /c /coff /Cp','lib /VERBOSE /SUBSYSTEM:WINDOWS',2>
					MAKEOPT 9 dup(<,,>)
szOutputType		db '.exe',0
					db '.dll',0
					db '.lib',0
					db '.com',0,0

.data?

hEnv				dd ?
hEnvMem				dd ?
pNextVal			dd ?
makeoptedit			MAKEOPT 17 dup(<>)
hMDlg				HWND ?

.code

ResetEnvironment proc uses esi edi

	mov		edi,hEnv
	.if	edi
		.while byte	ptr	[edi]
			mov		esi,edi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			invoke SetEnvironmentVariable,edi,esi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			mov		edi,esi
		.endw
		invoke GlobalFree,hEnv
		xor		eax,eax
		mov		hEnv,eax
	.endif
	ret

ResetEnvironment endp

SetVar proc uses edi,lpSave:DWORD,lpName:DWORD,lpValue:DWORD

	mov		edi,lpSave
	mov		byte ptr tmpbuff[4096],0
	invoke GetEnvironmentVariable,lpName,addr tmpbuff[4096],1024
	invoke strcpy,edi,lpName
	invoke strlen,edi
	lea		edi,[edi+eax+1]
	invoke strcpy,edi,addr tmpbuff[4096]
	invoke strlen,edi
	lea		edi,[edi+eax+1]
	invoke strcpy,addr tmpbuff,lpValue
	.if byte ptr tmpbuff[4096]
		invoke strcat,addr tmpbuff,addr szSemi
		invoke strcat,addr tmpbuff,addr tmpbuff[4096]
	.endif
	invoke SetEnvironmentVariable,lpName,addr tmpbuff
	mov		eax,edi
	ret

SetVar endp

SetEnvironment proc uses edi

	;Environment
	invoke ResetEnvironment
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16384
	mov		hEnv,eax
	mov		edi,eax
	invoke SetVar,edi,addr szPath,addr da.PathBin
	mov		edi,eax
	invoke SetVar,edi,addr szInclude,addr da.PathInc
	mov		edi,eax
	invoke SetVar,edi,addr szIncludelib,addr da.PathLib
	mov		edi,eax
	ret

SetEnvironment endp

PathOptionDialogProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_EDTBIN,EM_LIMITTEXT,240,0
		invoke SendDlgItemMessage,hWin,IDC_EDTINC,EM_LIMITTEXT,240,0
		invoke SendDlgItemMessage,hWin,IDC_EDTLIB,EM_LIMITTEXT,240,0
		invoke SetDlgItemText,hWin,IDC_EDTBIN,addr da.PathBin
		invoke SetDlgItemText,hWin,IDC_EDTINC,addr da.PathInc
		invoke SetDlgItemText,hWin,IDC_EDTLIB,addr da.PathLib
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke GetDlgItemText,hWin,IDC_EDTBIN,addr da.PathBin,240
				invoke strlen,addr da.PathBin
				inc		eax
				invoke RegSetValueEx,ha.hReg,addr szPathBin,0,REG_SZ,addr da.PathBin,eax
				invoke GetDlgItemText,hWin,IDC_EDTINC,addr da.PathInc,240
				invoke strlen,addr da.PathInc
				inc		eax
				invoke RegSetValueEx,ha.hReg,addr szPathInc,0,REG_SZ,addr da.PathInc,eax
				invoke GetDlgItemText,hWin,IDC_EDTLIB,addr da.PathLib,240
				invoke strlen,addr da.PathLib
				inc		eax
				invoke RegSetValueEx,ha.hReg,addr szPathLib,0,REG_SZ,addr da.PathLib,eax
				invoke SetEnvironment
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNRESTORE
				invoke SetDlgItemText,hWin,IDC_EDTBIN,addr defPathBin
				invoke SetDlgItemText,hWin,IDC_EDTINC,addr defPathInc
				invoke SetDlgItemText,hWin,IDC_EDTLIB,addr defPathLib
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

PathOptionDialogProc endp

BuildOptionAddDialogProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_EDTMAKETYPE,EM_LIMITTEXT,32,0
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke GetDlgItemText,hWin,IDC_EDTMAKETYPE,addr tmpbuff,32
				xor		eax,eax
				.if tmpbuff
					inc		eax
				.endif
				invoke SendMessage,hWin,WM_CLOSE,NULL,eax
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
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

BuildOptionAddDialogProc endp

BuildOptionDialogProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	tci:TC_ITEM
	LOCAL	buffer[32]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hMDlg,eax
		mov		tci.imask,TCIF_TEXT
		mov		tci.pszText,offset szMakeOption
		invoke SendDlgItemMessage,hWin,IDC_TABBUILD,TCM_INSERTITEM,999,addr tci
		invoke SendDlgItemMessage,hWin,IDC_EDTRES,EM_LIMITTEXT,128,0
		invoke SendDlgItemMessage,hWin,IDC_EDTASM,EM_LIMITTEXT,128,0
		invoke SendDlgItemMessage,hWin,IDC_EDTLNK,EM_LIMITTEXT,128,0
		mov		esi,offset szOutputType
		.while byte ptr [esi]
			invoke SendDlgItemMessage,hWin,IDC_CBOOUT,CB_ADDSTRING,0,esi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
		.endw
		mov		esi,offset da.makeopt
		call	SetMakeOpt
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendMessage,ha.hCbo,CB_RESETCONTENT,0,0
				mov		esi,offset makeoptedit
				mov		edi,offset da.makeopt
				invoke RtlZeroMemory,edi,sizeof MAKEOPT*16
				xor		ebx,ebx
				.while [esi].MAKEOPT.szType && ebx<16
					invoke RtlMoveMemory,edi,esi,sizeof MAKEOPT
					lea		edx,[ebx+1]
					invoke MakeKey,addr szMakeType,edx,addr buffer
					invoke RegSetValueEx,ha.hReg,addr buffer,0,REG_BINARY,edi,sizeof MAKEOPT
					invoke SendMessage,ha.hCbo,CB_ADDSTRING,0,addr [edi].MAKEOPT.szType
					invoke SendMessage,ha.hCbo,CB_SETITEMDATA,eax,edi
					lea		esi,[esi+sizeof MAKEOPT]
					lea		edi,[edi+sizeof MAKEOPT]
					inc		ebx
				.endw
				.while ebx<16
					lea		edx,[ebx+1]
					invoke MakeKey,addr szMakeType,edx,addr buffer
					invoke RegDeleteValue,ha.hReg,addr buffer
					inc		ebx
				.endw
				invoke SendMessage,ha.hCbo,CB_SETCURSEL,da.nBuildOpt,0
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNADDBUILD
				invoke DialogBoxParam,ha.hInstance,IDD_BUILDOPTIONADD,hWin,offset BuildOptionAddDialogProc,0
				.if eax
					invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_ADDSTRING,0,addr tmpbuff
					mov		ebx,eax
					mov		edx,sizeof MAKEOPT
					mul		edx
					lea		edi,[eax+offset makeoptedit]
					invoke lstrcpy,addr [edi].MAKEOPT.szType,addr tmpbuff
					invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_SETITEMDATA,ebx,edi
					invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_SETCURSEL,ebx,0
					invoke SendMessage,hWin,WM_COMMAND,CBN_SELCHANGE shl 16 or IDC_CBOTYPE,0
					invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_GETCOUNT,0,0
					mov		ebx,eax
					invoke GetDlgItem,hWin,IDC_BTNADDBUILD
					xor		edx,edx
					.if ebx==16
						invoke EnableWindow,eax,FALSE
					.endif
				.endif
			.elseif eax==IDC_BTNDELBUILD
				invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_GETCURSEL,0,0
				.if eax!=CB_ERR
					mov		ebx,eax
					mov		edx,sizeof MAKEOPT
					mul		edx
					lea		edi,[eax+offset makeoptedit]
					lea		esi,[edi+sizeof MAKEOPT]
					.while byte ptr [edi]
						mov		ecx,sizeof MAKEOPT
						rep movsb
					.endw
					invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_DELETESTRING,ebx,0
					invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_SETCURSEL,ebx,0
					.if eax==CB_ERR
						dec		ebx
						invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_SETCURSEL,ebx,0
					.endif
					.if eax!=CB_ERR
						invoke SendMessage,hWin,WM_COMMAND,CBN_SELCHANGE shl 16 or IDC_CBOTYPE,0
					.endif
					invoke GetDlgItem,hWin,IDC_BTNADDBUILD
					invoke EnableWindow,eax,TRUE
				.endif
			.elseif eax==IDC_BTNRESTORE
				mov		esi,offset makeoptdef
				call	SetMakeOpt
			.endif
		.elseif edx==EN_CHANGE
			push	eax
			invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_GETCURSEL,0,0
			invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_GETITEMDATA,eax,0
			mov		edi,eax
			pop		eax
			.if eax==IDC_EDTRES
				invoke GetDlgItemText,hWin,IDC_EDTRES,addr [edi].MAKEOPT.szCompileRC,sizeof MAKEOPT.szCompileRC
			.elseif eax==IDC_EDTASM
				invoke GetDlgItemText,hWin,IDC_EDTASM,addr [edi].MAKEOPT.szAssemble,sizeof MAKEOPT.szAssemble
			.elseif eax==IDC_EDTLNK
				invoke GetDlgItemText,hWin,IDC_EDTLNK,addr [edi].MAKEOPT.szLink,sizeof MAKEOPT.szLink
			.endif
		.elseif edx==CBN_SELCHANGE
			.if eax==IDC_CBOTYPE
				invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_GETCURSEL,0,0
				mov		ebx,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_GETITEMDATA,eax,0
				mov		esi,eax
				invoke SetDlgItemText,hWin,IDC_EDTRES,addr [esi].MAKEOPT.szCompileRC
				invoke SetDlgItemText,hWin,IDC_EDTASM,addr [esi].MAKEOPT.szAssemble
				invoke SetDlgItemText,hWin,IDC_EDTLNK,addr [esi].MAKEOPT.szLink
				invoke SendDlgItemMessage,hWin,IDC_CBOOUT,CB_SETCURSEL,[esi].MAKEOPT.OutpuType,0
				invoke GetDlgItem,hWin,IDC_BTNDELBUILD
				xor		edx,edx
				.if ebx>6
					mov		edx,TRUE
				.endif
				invoke EnableWindow,eax,edx
			.elseif eax==IDC_CBOOUT
				invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_GETITEMDATA,eax,0
				mov		edi,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOOUT,CB_GETCURSEL,0,0
				mov		[edi].MAKEOPT.OutpuType,eax
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

SetMakeOpt:
	invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_RESETCONTENT,0,0
	mov		edi,offset makeoptedit
	invoke RtlZeroMemory,edi,sizeof MAKEOPT*16
	xor		ebx,ebx
	.while [esi].MAKEOPT.szType && ebx<16
		invoke RtlMoveMemory,edi,esi,sizeof MAKEOPT
		invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_ADDSTRING,0,addr [edi].MAKEOPT.szType
		invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_SETITEMDATA,eax,edi
		lea		edi,[edi+sizeof MAKEOPT]
		lea		esi,[esi+sizeof MAKEOPT]
		inc		ebx
	.endw
	invoke SendDlgItemMessage,hWin,IDC_CBOTYPE,CB_SETCURSEL,0,0
	invoke SendDlgItemMessage,hWin,IDC_CBOOUT,CB_SETCURSEL,makeoptedit.OutpuType,0
	invoke SetDlgItemText,hWin,IDC_EDTRES,addr makeoptedit.szCompileRC
	invoke SetDlgItemText,hWin,IDC_EDTASM,addr makeoptedit.szAssemble
	invoke SetDlgItemText,hWin,IDC_EDTLNK,addr makeoptedit.szLink
	invoke GetDlgItem,hWin,IDC_BTNADDBUILD
	xor		edx,edx
	.if ebx<16
		mov		edx,TRUE
	.endif
	invoke EnableWindow,eax,edx
	retn

BuildOptionDialogProc endp
