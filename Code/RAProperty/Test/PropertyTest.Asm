.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include PropertyTest.inc

.code

start:
	invoke	GetModuleHandle,NULL
	mov	hInstance,eax
	invoke	InitCommonControls
	invoke LoadLibrary,addr szLib
	mov		hLib,eax
	invoke	DialogBoxParam,hInstance,IDD_MAIN,NULL,addr DlgProc,NULL
	invoke FreeLibrary,hLib
	invoke	ExitProcess,0

;########################################################################

DlgProc	proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hCtl:HWND
	LOCAL	hMem:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	nCount:DWORD
	LOCAL	ms:MEMSEARCH

	mov		eax,uMsg
	.if	eax==WM_INITDIALOG
		;initialization here
		invoke GetDlgItem,hWin,1001
		mov		hCtl,eax
		;Character table
		push	ebx
		;Setup whole CaseTab
		xor		ebx,ebx
		.while ebx<256
			invoke IsCharAlpha,ebx
			.if eax
				invoke CharUpper,ebx
				.if eax==ebx
					invoke CharLower,ebx
				.endif
				mov		CaseTab[ebx],al
			.else
				mov		CaseTab[ebx],bl
			.endif
			inc		ebx
		.endw
		pop		ebx
		invoke SendMessage,hCtl,PRM_SETCHARTAB,0,addr CharTab
		;Combo items
		invoke SendMessage,hCtl,PRM_ADDPROPERTYTYPE,'p',addr szCode
		invoke SendMessage,hCtl,PRM_ADDPROPERTYTYPE,'c',addr szConst
		invoke SendMessage,hCtl,PRM_ADDPROPERTYTYPE,'d',addr szData
		invoke SendMessage,hCtl,PRM_ADDPROPERTYTYPE,'s',addr szStruct
		;Set general definitions
		invoke SendMessage,hCtl,PRM_SETGENDEF,0,addr defgen
		;Words to ignore
		invoke SendMessage,hCtl,PRM_ADDIGNORE,IGNORE_LINEFIRSTWORD,addr szIgnore1
		invoke SendMessage,hCtl,PRM_ADDIGNORE,IGNORE_LINEFIRSTWORD,addr szIgnore2
		invoke SendMessage,hCtl,PRM_ADDIGNORE,IGNORE_LINEFIRSTWORD,addr szIgnore3
		invoke SendMessage,hCtl,PRM_ADDIGNORE,IGNORE_LINEFIRSTWORD,addr szIgnore4
		invoke SendMessage,hCtl,PRM_ADDIGNORE,IGNORE_PROCPARAM,addr szIgnore5
		invoke SendMessage,hCtl,PRM_ADDIGNORE,IGNORE_PROCPARAM,addr szIgnore6
		invoke SendMessage,hCtl,PRM_ADDIGNORE,IGNORE_PROCPARAM,addr szIgnore7
		invoke SendMessage,hCtl,PRM_ADDIGNORE,IGNORE_PROCPARAM,addr szIgnore8
		invoke SendMessage,hCtl,PRM_ADDIGNORE,IGNORE_PROCPARAM,addr szIgnore9
		invoke SendMessage,hCtl,PRM_ADDIGNORE,IGNORE_PROCPARAM,addr szIgnore10
		invoke SendMessage,hCtl,PRM_ADDIGNORE,IGNORE_PROCPARAM,addr szIgnore11
		invoke SendMessage,hCtl,PRM_ADDIGNORE,IGNORE_PROCPARAM,addr szIgnore12
		invoke SendMessage,hCtl,PRM_ADDIGNORE,IGNORE_PROCPARAM,addr szIgnore13
		;Def types
		invoke SendMessage,hCtl,PRM_ADDDEFTYPE,0,addr deftypeproc
		invoke SendMessage,hCtl,PRM_ADDDEFTYPE,0,addr deftypeendp
		invoke SendMessage,hCtl,PRM_ADDDEFTYPE,0,addr deftypeconst
		invoke SendMessage,hCtl,PRM_ADDDEFTYPE,0,addr deftypelocal
		;Add files
		mov		edx,2 shl 8 or 'P'
		invoke SendMessage,hCtl,PRM_ADDPROPERTYFILE,edx,addr szApiFile
		;Set default selection
		invoke SendMessage,hCtl,PRM_SELECTPROPERTY,'p',0
		invoke SendMessage,hCtl,PRM_SETSELBUTTON,2,0
		;Set colors
		invoke SendMessage,hCtl,PRM_SETBACKCOLOR,0,0C0C0E0h
		invoke SendMessage,hCtl,PRM_SETTEXTCOLOR,0,0800000h
		invoke SendMessage,hCtl,PRM_SETLANGUAGE,nMASM,0
	.elseif	eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
				mov		hMem,eax
				invoke CreateFile,addr szParseFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
				mov		hFile,eax
				invoke ReadFile,hFile,hMem,64*1024,addr nBytes,NULL
				invoke CloseHandle,hFile
				invoke GetDlgItem,hWin,1001
				mov		hCtl,eax
				invoke SendMessage,hCtl,PRM_PARSEFILE,0,hMem
				invoke SetDlgItemText,hWin,1002,hMem
				invoke GlobalFree,hMem
				invoke SendMessage,hCtl,PRM_SELECTPROPERTY,'p',0
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==1003
				push	ebx
				invoke SendDlgItemMessage,hWin,1004,EM_SETLIMITTEXT,1024*256,0
				invoke GetDlgItem,hWin,1001
				mov		hCtl,eax
				invoke SendMessage,hCtl,PRM_GETSORTEDLIST,addr szp,addr nCount
				.if eax
					push	eax
					mov		ebx,eax
					mov		ms.lpMem,ebx
					.while dword ptr [ebx]
						mov		edx,[ebx]
						mov		ms.lpFind,edx
;invoke SendDlgItemMessage,hWin,1004,EM_REPLACESEL,FALSE,edx
;invoke SendDlgItemMessage,hWin,1004,EM_REPLACESEL,FALSE,addr crlf
						invoke SendMessage,hCtl,PRM_FINDINSORTEDLIST,nCount,addr ms
PrintDec eax
						lea		ebx,[ebx+4]
					.endw
					pop		eax
					invoke GlobalFree,eax
				.endif
;				invoke SendMessage,hCtl,PRM_FINDFIRST,addr szp,addr szNULL
;				.while eax
;					mov		ebx,eax
;PrintHex eax
;					PrintStringByAddr ebx
;					invoke lstrlen,ebx
;					lea		ebx,[ebx+eax+1]
;					PrintStringByAddr ebx
;					invoke lstrlen,ebx
;					lea		ebx,[ebx+eax+1]
;					PrintStringByAddr ebx
;					invoke SendMessage,hCtl,PRM_FINDNEXT,0,0
;				.endw
				pop		ebx
			.endif
		.endif
	.elseif	eax==WM_NOTIFY
		mov		edx,lParam
		.if [edx].NMHDR.idFrom==1001
			PrintHex [edx].NMHDR.code
			PrintHex [edx].RAPNOTIFY.nid
			PrintHex [edx].RAPNOTIFY.nline
		.endif
	.elseif	eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

end start
