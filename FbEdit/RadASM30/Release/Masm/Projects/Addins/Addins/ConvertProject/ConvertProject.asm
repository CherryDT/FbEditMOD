;#########################################################################
;Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;Include file

include ConvertProject.inc

.code

;#########################################################################
; Menu

UpdateMenu proc hMnu:HMENU
	LOCAL	mii:MENUITEMINFO

	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_SUBMENU
	mov		edx,lpHandles
	invoke GetMenuItemInfo,[edx].ADDINHANDLES.hMenu,IDM_TOOLS,FALSE,addr mii
	invoke AppendMenu,mii.hSubMenu,MF_STRING,IDAddin,offset szMenuConvert
	ret

UpdateMenu endp

IsFileType proc uses ebx esi edi,lpFileType:DWORD,lpFileTypes:DWORD

	mov		esi,lpFileTypes
	mov		edi,lpFileType
	.while TRUE
		xor		ecx,ecx
		.while byte ptr [edi+ecx]
			mov		al,[edi+ecx]
			mov		ah,[esi+ecx]
			.if al>='a' && al<='z'
				and		al,5Fh
			.endif
			.if ah>='a' && ah<='z'
				and		ah,5Fh
			.endif
			.break .if al!=ah
			inc		ecx
		.endw
		.if !byte ptr [edi+ecx]
			mov		eax,TRUE
			jmp		Ex
		.endif
		inc		esi
		.while byte ptr [esi]!='.'
			inc		esi
		.endw
		.break .if !byte ptr [esi+1]
	.endw
	xor		eax,eax
  Ex:
	ret

IsFileType endp

IsFile proc uses esi,lpFileName:DWORD
	LOCAL	tpe[16]:BYTE

	mov		esi,lpFileName
	invoke lstrlen,esi
	.while byte ptr [esi+eax]!='.' && eax
		dec		eax
	.endw
	.if byte ptr [esi+eax]=='.'
		invoke lstrcpy,addr tpe,addr [esi+eax]
		invoke lstrcat,addr tpe,addr szDot
	.endif
	invoke IsFileType,addr tpe,addr szcodefile
	.if eax
		mov		eax,1
		jmp		Ex
	.endif
	invoke IsFileType,addr tpe,addr szrcfile
	.if eax
		mov		eax,2
		jmp		Ex
	.endif
	invoke IsFileType,addr tpe,addr szheaderfile
	.if eax
		mov		eax,3
		jmp		Ex
	.endif
	invoke IsFileType,addr tpe,addr szhexfile
	.if eax
		mov		eax,4
		jmp		Ex
	.endif
	invoke IsFileType,addr tpe,addr szdlgmnufile
	.if eax
		mov		eax,-1
		jmp		Ex
	.endif
	xor		eax,eax
  Ex:
	ret

IsFile endp

ConvertRCFile proc uses ebx esi edi
	LOCAL	hMemRC:HGLOBAL
	LOCAL	hMemRCIn:HGLOBAL
	LOCAL	hMemRCOut:HGLOBAL
	LOCAL	hFile:HANDLE
	LOCAL	dwRead:DWORD
	LOCAL	ms:MEMSEARCH
	LOCAL	buffer[MAX_PATH]:BYTE

	.if mainrc
		invoke CreateFile,addr mainrc,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
		.if eax==INVALID_HANDLE_VALUE
			jmp		Ex
		.else
			;Read the main rc file
			mov		hFile,eax
			invoke GetFileSize,hFile,0
			push	eax
			shr		eax,12
			inc		eax
			shl		eax,12
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
			mov		hMemRC,eax
			pop		edx
			invoke ReadFile,hFile,hMemRC,edx,addr dwRead,NULL
			invoke CloseHandle,hFile
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*1024
			mov		hMemRCOut,eax
			mov		esi,hMemRC
			.while TRUE
				mov		ms.lpMem,esi
				mov		ms.lpFind,offset szInclude
				mov		eax,lpData
				mov		eax,[eax].ADDINDATA.lpCharTab
				mov		ms.lpCharTab,eax
				mov		ms.fr,FR_DOWN or FR_WHOLEWORD
				mov		edx,lpHandles
				invoke SendMessage,[edx].ADDINHANDLES.hProperty,PRM_MEMSEARCH,0,addr ms
				.break.if !eax
				mov		esi,eax
				call	AddFile
			.endw
			invoke lstrcat,hMemRCOut,hMemRC
			invoke CreateFile,addr mainrc,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
			mov		hFile,eax
			invoke lstrlen,hMemRCOut
			mov		edx,eax
			invoke WriteFile,hFile,hMemRCOut,edx,addr dwRead,NULL
			invoke CloseHandle,hFile
			invoke GlobalFree,hMemRC
			invoke GlobalFree,hMemRCOut
		.endif
	.endif
  Ex:
	ret

GetEOL:
	.while byte ptr [esi]!=0Dh && byte ptr [esi]
		inc		esi
	.endw
	.if byte ptr [esi]==0Dh
		inc		esi
	.endif
	.if byte ptr [esi]==0Ah
		inc		esi
	.endif
	retn

DelLine:
	push	edi
	xor		ecx,ecx
	.while byte ptr [esi+ecx]
		mov		al,[esi+ecx]
		mov		[edi+ecx],al
		inc		ecx
	.endw
	mov		byte ptr [edi+ecx],0
	pop		esi
	retn

GetTheFile:
	lea		edx,buffer
	.while ah!=byte ptr [esi]
		mov		al,[esi]
		.if al=='/'
			mov		al,'\'
		.endif
		mov		[edx],al
		inc		esi
		inc		edx
	.endw
	mov		byte ptr [edx],0
	call	GetEOL
	invoke IsFile,addr buffer
	.if eax==2
		;rc file
		invoke GetFileAttributes,addr buffer
		.if eax!=INVALID_HANDLE_VALUE
			;Add the file
			call	DelLine
			invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
			;Read the rc file
			mov		hFile,eax
			invoke GetFileSize,hFile,0
			push	eax
			shr		eax,12
			inc		eax
			shl		eax,12
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
			mov		hMemRCIn,eax
			pop		edx
			invoke ReadFile,hFile,hMemRCIn,edx,addr dwRead,NULL
			invoke CloseHandle,hFile
			invoke lstrcat,hMemRCOut,hMemRCIn
			invoke GlobalFree,hMemRCIn
			invoke DeleteFile,addr buffer
		.endif
	.endif
	retn

AddFile:
	mov		edi,esi
	lea		esi,[esi+8]
	.while (byte ptr [esi]==' ' || byte ptr [esi]==VK_TAB) && byte ptr [esi]!=0Dh && byte ptr [esi]
		inc		esi
	.endw
	.if byte ptr [esi]=='"'
		inc		esi
		mov		ah,'"'
		call	GetTheFile
	.elseif byte ptr [esi]=='<'
		inc		esi
		mov		ah,'>'
		call	GetTheFile
	.else
		call	GetEOL
	.endif
	retn

ConvertRCFile endp

CreateNewProject proc uses ebx esi edi
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	tmpbuff[MAX_PATH]:BYTE
	LOCAL	nFile:DWORD

	;Version
	invoke WritePrivateProfileString,addr szIniVersion,addr szIniVersion,addr szIni3000,addr project3x
	;Programming language
	invoke GetPrivateProfileString,addr szIniProject,addr szIniAssembler,addr szNULL,addr buffer,sizeof buffer,addr project2x
	invoke WritePrivateProfileString,addr szIniProject,addr szIniAssembler,addr buffer,addr project3x
	;Path
	invoke GetCurrentDirectory,sizeof buffer,addr buffer
	invoke WritePrivateProfileString,addr szIniProject,addr szIniPath,addr buffer,addr project3x
	;Group
	invoke GetPrivateProfileString,addr szIniProject,addr szIniDescription,addr szNULL,addr buffer,sizeof buffer,addr project2x
	invoke wsprintf,addr tmpbuff,addr szFmtGroup,addr buffer
	invoke WritePrivateProfileString,addr szIniProject,addr szIniGroup,addr tmpbuff,addr project3x
	;Files
	mov		ebx,1
	mov		nFile,ebx
	xor		edi,edi
	.while TRUE
		invoke wsprintf,addr buffer,addr szFmtDec,ebx
		invoke GetPrivateProfileString,addr szIniFiles,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr project2x
		.if eax
			invoke GetFileAttributes,addr buffer
			.if eax!=INVALID_HANDLE_VALUE
				invoke IsFile,addr buffer
				.if eax==1
					;asm
					invoke lstrcmp,addr buffer,addr mainasm
					;Flag
					mov		ecx,0
					.if !eax
						mov		ecx,2
					.endif
					;Group
					mov		esi,-2
					;Type
					mov		edx,1
					call	PutFile
				.elseif eax==2
					;rc
					invoke lstrcmp,addr buffer,addr mainrc
					;Flag
					mov		ecx,0
					.if !eax
						mov		ecx,2
					.endif
					;Group
					mov		esi,-5
					;Type
					mov		edx,4
					call	PutFile
				.elseif eax==3
					;inc
					;Flag
					mov		ecx,0
					;Group
					mov		esi,-3
					;Type
					mov		edx,1
					call	PutFile
				.elseif eax==4
					;hex
					;Flag
					mov		ecx,0
					;Group
					mov		esi,-4
					;Type
					mov		edx,3
					call	PutFile
				.elseif eax==0
					;other
					;Flag
					mov		ecx,0
					;Group
					mov		esi,-4
					;Type
					mov		edx,0
					call	PutFile
				.elseif eax==-1
					;mnu or dlg, delete it
					invoke DeleteFile,addr buffer
				.endif
			.endif
		.else
			inc		edi
			.break .if edi>10
		.endif
		inc		ebx
	.endw
	;Modules
	mov		ebx,1001
	xor		edi,edi
	.while TRUE
		invoke wsprintf,addr buffer,addr szFmtDec,ebx
		invoke GetPrivateProfileString,addr szIniFiles,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr project2x
		.if eax
			invoke GetFileAttributes,addr buffer
			.if eax!=INVALID_HANDLE_VALUE
				invoke IsFile,addr buffer
				.if eax==1
					;asm
					;Flag
					mov		ecx,1
					;Group
					mov		esi,-2
					;Type
					mov		edx,1
					call	PutFile
				.elseif eax==2
					;rc
					invoke lstrcmp,addr buffer,addr mainrc
					;Flag
					mov		ecx,0
					.if !eax
						mov		ecx,2
					.endif
					;Group
					mov		esi,-5
					;Type
					mov		edx,4
					call	PutFile
				.elseif eax==3
					;inc
					;Flag
					mov		ecx,1
					;Group
					mov		esi,-3
					;Type
					mov		edx,1
					call	PutFile
				.elseif eax==0
					;other
					;Flag
					mov		ecx,0
					;Group
					mov		esi,-4
					;Type
					mov		edx,0
					call	PutFile
				.elseif eax==-1
					;mnu or dlg, delete it
					invoke DeleteFile,addr buffer
				.endif
			.endif
		.else
			inc		edi
			.break .if edi>10
		.endif
		inc		ebx
	.endw
	;Convert RC files
	invoke ConvertRCFile
	;Make
	mov		word ptr buffer,'0'
	invoke WritePrivateProfileString,addr szIniMake,addr szIniMake,addr buffer,addr project3x
	invoke GetPrivateProfileString,addr szIniMake,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr assemblerini
	invoke WritePrivateProfileString,addr szIniMake,addr buffer,addr tmpbuff,addr project3x
	;Delete .rap file
	invoke DeleteFile,addr project2x
	ret

PutFile:
	invoke wsprintf,addr tmpbuff,addr szFmtFile,esi,ecx,edx,addr buffer
	mov		buffer,'F'
	invoke wsprintf,addr buffer[1],addr szFmtDec,nFile
	invoke WritePrivateProfileString,addr szIniProject,addr buffer,addr tmpbuff,addr project3x
	inc		nFile
	retn

CreateNewProject endp

ConvertProjectProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	tmpbuff[MAX_PATH]:BYTE
	LOCAL	nNotFound:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG

	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke CreateNewProject
				invoke SendDlgItemMessage,hWin,IDC_EDTFILES,EM_REPLACESEL,FALSE,addr szDone
				invoke GetDlgItem,hWin,IDOK
				invoke EnableWindow,eax,FALSE
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNPROJECT
				invoke RtlZeroMemory,addr ofn,sizeof OPENFILENAME
				mov		ofn.lStructSize,sizeof OPENFILENAME
				mov		eax,hWin
				mov		ofn.hwndOwner,eax
				mov		eax,hInstance
				mov		ofn.hInstance,eax
				mov		ofn.lpstrFilter,offset szFileFilter
				mov		buffer,0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke SetDlgItemText,hWin,IDC_EDTPROJECT,addr buffer
					invoke SetDlgItemText,hWin,IDC_EDTFILES,addr szNULL
					invoke lstrcpy,addr project2x,addr buffer
					invoke lstrcpy,addr project3x,addr buffer
					invoke lstrlen,addr buffer
					.while buffer[eax]!='\' && eax
						dec		eax
					.endw
					mov		buffer[eax],0
					invoke SetCurrentDirectory,addr buffer
					invoke lstrlen,addr project3x
					.while project3x[eax]!='.' && eax
						dec		eax
					.endw
					mov		project3x[eax],0
					invoke lstrcat,addr project3x,addr szprra
					;Check if programming language exists
					invoke GetPrivateProfileString,addr szIniProject,addr szIniAssembler,addr szNULL,addr buffer,sizeof buffer,addr project2x
					mov		esi,lpData
					invoke lstrcpy,addr assemblerini,addr [esi].ADDINDATA.szAppPath
					invoke lstrcat,addr assemblerini,addr szBS
					invoke lstrcat,addr assemblerini,addr buffer
					invoke lstrcat,addr assemblerini,addr szIni
					invoke GetFileAttributes,addr assemblerini
					.if eax==INVALID_HANDLE_VALUE
						invoke wsprintf,addr tmpbuff,addr szErrLanguage,addr buffer
						invoke SetDlgItemText,hWin,IDC_EDTFILES,addr tmpbuff
						invoke GetDlgItem,hWin,IDOK
						invoke EnableWindow,eax,FALSE
					.else
						invoke GetPrivateProfileString,addr szIniProject,addr szIniDescription,addr szNULL,addr buffer,sizeof buffer,addr project2x
						invoke SendDlgItemMessage,hWin,IDC_EDTFILES,EM_REPLACESEL,FALSE,addr buffer
						invoke SendDlgItemMessage,hWin,IDC_EDTFILES,EM_REPLACESEL,FALSE,addr szCRLF
						invoke SendDlgItemMessage,hWin,IDC_EDTFILES,EM_REPLACESEL,FALSE,addr szCRLF
						mov		nNotFound,0
						mov		mainasm,0
						mov		mainrc,0
						mov		ebx,1
						xor		edi,edi
						.while TRUE
							invoke wsprintf,addr buffer,addr szFmtDec,ebx
							invoke GetPrivateProfileString,addr szIniFiles,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr project2x
							.if eax
								invoke SendDlgItemMessage,hWin,IDC_EDTFILES,EM_REPLACESEL,FALSE,addr szFile
								invoke SendDlgItemMessage,hWin,IDC_EDTFILES,EM_REPLACESEL,FALSE,addr buffer
								invoke GetFileAttributes,addr buffer
								.if eax==INVALID_HANDLE_VALUE
									invoke SendDlgItemMessage,hWin,IDC_EDTFILES,EM_REPLACESEL,FALSE,addr szNotFound
									inc		nNotFound
								.else
									invoke IsFile,addr buffer
									.if eax==1 && !mainasm
										invoke lstrcpy,addr mainasm,addr buffer
									.elseif eax==2 && !mainrc
										invoke lstrcpy,addr mainrc,addr buffer
									.endif
								.endif
								invoke SendDlgItemMessage,hWin,IDC_EDTFILES,EM_REPLACESEL,FALSE,addr szCRLF
							.else
								inc		edi
								.break .if edi>10
							.endif
							inc		ebx
						.endw
						mov		ebx,1001
						xor		edi,edi
						.while TRUE
							invoke wsprintf,addr buffer,addr szFmtDec,ebx
							invoke GetPrivateProfileString,addr szIniFiles,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr project2x
							.if eax
								invoke SendDlgItemMessage,hWin,IDC_EDTFILES,EM_REPLACESEL,FALSE,addr szModule
								invoke SendDlgItemMessage,hWin,IDC_EDTFILES,EM_REPLACESEL,FALSE,addr buffer
								invoke GetFileAttributes,addr buffer
								.if eax==INVALID_HANDLE_VALUE
									invoke SendDlgItemMessage,hWin,IDC_EDTFILES,EM_REPLACESEL,FALSE,addr szNotFound
									inc		nNotFound
								.endif
								invoke SendDlgItemMessage,hWin,IDC_EDTFILES,EM_REPLACESEL,FALSE,addr szCRLF
							.else
								inc		edi
								.break .if edi>10
							.endif
							inc		ebx
						.endw
						invoke GetPrivateProfileString,addr szIniProject,addr szIniCode,addr szNULL,addr szcodefile,sizeof szcodefile,addr assemblerini
						invoke lstrcat,addr szcodefile,addr szDot
						invoke GetPrivateProfileString,addr szIniProject,addr szIniHeader,addr szNULL,addr szheaderfile,sizeof szheaderfile,addr assemblerini
						invoke lstrcat,addr szheaderfile,addr szDot
						invoke GetPrivateProfileString,addr szIniFile,addr szIniHex,addr szNULL,addr szhexfile,sizeof szhexfile,addr assemblerini
						invoke GetDlgItem,hWin,IDOK
						invoke EnableWindow,eax,TRUE
					.endif
				.endif
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

ConvertProjectProc endp

;#########################################################################
;Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

InstallAddin proc uses ebx hWin:DWORD

	xor		eax,eax
	mov		hook.hook1,eax
	mov		hook.hook2,eax
	mov		hook.hook3,eax
	mov		hook.hook4,eax
	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov		lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax
	.if [eax].ADDINDATA.Version>=3001
		invoke SendMessage,ebx,AIM_GETMENUID,0,0	
		mov		IDAddin,eax
		mov		hook.hook1,HOOK_COMMAND or HOOK_MENUUPDATE
	.endif
	mov		eax,offset hook
	ret 

InstallAddin Endp

AddinProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==AIM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDAddin
				;The menuitem we added has been selected
				invoke DialogBoxParam,hInstance,IDD_DLGCONVERT,hWin,Offset ConvertProjectProc,0
				mov		eax,TRUE
				jmp		Ex
			.endif
		.endif
	.elseif eax==AIM_MENUUPDATE
		invoke UpdateMenu,wParam
 	.endif
	xor		eax,eax
  Ex:
	ret

AddinProc Endp

;#########################################################################

End DllEntry
