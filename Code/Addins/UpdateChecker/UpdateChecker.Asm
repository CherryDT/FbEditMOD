;#########################################################################
; Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
; Include file

include UpdateChecker.inc

.code

; set initial folder in browser
BrowseCallbackProc proc hwnd:DWORD,uMsg:UINT,lParam:LPARAM,lpCBData:DWORD

	mov eax,uMsg
	.if eax==BFFM_INITIALIZED
		invoke PostMessage,hwnd,BFFM_SETSELECTION,TRUE,lpCBData
	.endif
	xor eax, eax
	ret

BrowseCallbackProc endp

BrowseFolder proc hWin:HWND,nID:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		bri.pidlRoot,0
	mov		bri.pszDisplayName,0
	xor		eax,eax
	mov		bri.lpszTitle,eax
	mov		bri.ulFlags,BIF_RETURNONLYFSDIRS or BIF_STATUSTEXT 
	mov		bri.lpfn,BrowseCallbackProc
	; get path   
	invoke SendDlgItemMessage,hWin,nID,WM_GETTEXT,sizeof buffer,addr buffer
	lea		eax,buffer
	mov		bri.lParam,eax 
	mov		bri.iImage,0
	invoke SHBrowseForFolder,offset bri
	.if !eax
		jmp		GetOut
	.endif
	mov		edx,eax
	invoke SHGetPathFromIDList,edx,addr buffer
	; set new path back to edit
	invoke SetDlgItemText,hWin,nID,addr buffer
  GetOut:
	ret

BrowseFolder endp

InetClose proc uses ebx,lphInternet:DWORD,lphUrl:DWORD

	mov		ebx,lphUrl
	.if dword ptr [ebx]
		invoke InternetCloseHandle,[ebx]
		mov		dword ptr [ebx],0
	.endif
	mov		ebx,lphInternet
	.if dword ptr [ebx]
		invoke InternetCloseHandle,[ebx]
		mov		dword ptr [ebx],0
	.endif
	ret

InetClose endp

InetConnect proc lphInternet:DWORD,lphUrl:DWORD,lpUrl:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	contextid:DWORD

	invoke InternetOpen,addr AppName,INTERNET_OPEN_TYPE_DIRECT,0,0,0
	.if eax
		mov		edx,lphInternet
		mov		[edx],eax
		.if lpUrl
			invoke lstrcpy,addr buffer,lpUrl
		.else
			invoke lstrcpy,addr buffer,addr szUrlFile
			invoke lstrcat,addr buffer,addr szDLFileName
		.endif
		mov		edx,lphInternet
		invoke InternetOpenUrl,[edx],addr buffer,0,0,INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_CACHE_WRITE,addr contextid
		.if eax
			mov		edx,lphUrl
			mov		[edx],eax
			mov		eax,TRUE
		.else
			mov		eax,-2
		.endif
	.else
		mov		eax,-1
	.endif
	ret

InetConnect endp

InetDownloadFile proc uses ebx,hWin:HWND
	LOCAL	filename[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	hInternet:HANDLE
	LOCAL	hUrl:HANDLE
	LOCAL	dwsize:DWORD
	LOCAL	dwread:DWORD
	LOCAL	dwindex:DWORD
	LOCAL	hFile:HANDLE
	LOCAL	nRetry:DWORD

	xor		eax,eax
	mov		nRetry,eax
	mov		hFile,eax
	mov		hInternet,eax
	mov		hUrl,eax
	mov		dwindex,eax
	invoke InetConnect,addr hInternet,addr hUrl,0
	.if sdword ptr eax>0
		mov		dwread,4
		mov		dwsize,0
		invoke HttpQueryInfo,hUrl,HTTP_QUERY_CONTENT_LENGTH or HTTP_QUERY_FLAG_NUMBER,addr dwsize,addr dwread,addr dwindex
		.if eax
			mov		ebx,dwsize
			invoke wsprintf,addr buffer1,addr szFmtFilesize,ebx
			invoke SetDlgItemText,hWin,IDC_STCFILESIZE,addr buffer1
			shr		ebx,8
			shl		ebx,16
			invoke SendDlgItemMessage,hWin,IDC_PGB1,PBM_SETRANGE,0,ebx
			xor		ebx,ebx
			.while ebx<dwsize
				.if fDLCancel
					mov		eax,-6
					.break
				.endif
				invoke InternetReadFile,hUrl,addr buffer1,256,addr dwread
				.if eax
					mov		eax,dwread
					.if !eax
						; Reconnect
						invoke InetClose,addr hInternet,addr hUrl
						invoke WaitForSingleObject,hDLThread,100
						invoke InetConnect,addr hInternet,addr hUrl,0
						.if !eax
							inc		nRetry
							.if nRetry>100
								mov		eax,-4
								.break
							.endif
						.endif
					.else
						add		ebx,eax
						.if !hFile
							; Create the file
							invoke lstrcpy,addr filename,addr szDLPath
							invoke lstrcat,addr filename,addr szBackSlash
							invoke lstrcat,addr filename,addr szDLFileName
							invoke CreateFile,addr filename,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
							.if eax!=INVALID_HANDLE_VALUE
								mov		hFile,eax
							.else
								mov		eax,-5
								.break
							.endif
						.endif
						; Write the buffer to the file
						invoke WriteFile,hFile,addr buffer1,dwread,addr dwread,NULL
						mov		eax,ebx
						shr		eax,8
						invoke SendDlgItemMessage,hWin,IDC_PGB1,PBM_SETPOS,eax,0
						xor		eax,eax
						mov		nRetry,eax
					.endif
				.else
					inc		nRetry
					.if nRetry>10
						mov		eax,-4
						.break
					.endif
				.endif
			.endw
			.if hFile
				push	eax
				invoke CloseHandle,hFile
				pop		eax
			.endif
		.else
			mov		eax,-3
		.endif
	.endif
	mov		nDLThread,eax
	.if hFile!=0 && eax!=0
		invoke DeleteFile,addr filename
	.endif
	invoke InetClose,addr hInternet,addr hUrl
	invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
	ret

InetDownloadFile endp

DownloadProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	tid:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		fDLCancel,0
		invoke lstrcpy,addr buffer,addr szDownloading
		invoke lstrcat,addr buffer,addr szDLFileName
		invoke SetDlgItemText,hWin,IDC_STCDOWNLOADING,addr buffer
		invoke CreateThread,NULL,NULL,addr InetDownloadFile,hWin,NORMAL_PRIORITY_CLASS,addr tid
		mov		hDLThread,eax
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				mov		fDLCancel,TRUE
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,nDLThread
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DownloadProc endp

InetDownload proc hWin:HWND,lpFileName:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		fDLCancel,0
	invoke lstrcpy,addr szDLFileName,lpFileName
	invoke DialogBoxParam,hInstance,IDD_DLGDOWNLOAD,hWin,Offset DownloadProc,0
	.if !eax
		mov		eax,offset szSuccess
	.elseif eax==-1
		mov		eax,offset szINetErr1
		inc		nDLErrors
	.elseif eax==-2
		mov		eax,offset szINetErr2
		inc		nDLErrors
	.elseif eax==-3
		mov		eax,offset szINetErr3
		inc		nDLErrors
	.elseif eax==-4
		mov		eax,offset szINetErr4
		inc		nDLErrors
	.elseif eax==-5
		mov		eax,offset szINetErr5
		inc		nDLErrors
	.elseif eax==-6
		mov		eax,offset szINetErr6
		inc		nDLErrors
	.endif
	invoke wsprintf,addr buffer,addr szFmtDownloaded,lpFileName,eax
	invoke GetDlgItemText,hWin,IDC_EDTVERSION,addr tempbuff,1024
	invoke lstrcat,addr tempbuff,addr buffer
	invoke SetDlgItemText,hWin,IDC_EDTVERSION,addr tempbuff
	ret

InetDownload endp

InetGetVersion proc lpUrl:DWORD,lpBuff:DWORD,nBytes:DWORD
	LOCAL	hInternet:HANDLE
	LOCAL	hUrl:HANDLE
	LOCAL	dwread:DWORD
	LOCAL	dwindex:DWORD

	xor		eax,eax
	mov		hInternet,eax
	mov		hUrl,eax
	mov		dwindex,eax
	invoke InetConnect,addr hInternet,addr hUrl,addr szUrlVersion
	.if sdword ptr eax>0
		mov		dwread,256
		invoke HttpQueryInfo,hUrl,HTTP_QUERY_CONTENT_LENGTH or HTTP_QUERY_FLAG_NUMBER,lpBuff,addr dwread,addr dwindex
		.if eax
			invoke InternetReadFile,hUrl,lpBuff,nBytes,addr dwread
			.if eax
				mov		eax,dwread
			.else
				mov		eax,-4
			.endif
		.else
			mov		eax,-3
		.endif
	.endif
	push	eax
	invoke InetClose,addr hInternet,addr hUrl
	pop		eax
	ret

InetGetVersion endp

IsFoderEmpty proc
	LOCAL	wfd:WIN32_FIND_DATA
	LOCAL	hWfd:HANDLE
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke lstrcpy,addr buffer,addr szDLPath
	invoke lstrcat,addr buffer,addr szAllFiles
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		mov		hWfd,eax
		.while eax
			lea		eax,wfd.cFileName
			.if word ptr [eax]!='.' && word ptr [eax]!='..'
				invoke FindClose,hWfd
				xor		eax,eax
				ret
			.endif
			invoke FindNextFile,hWfd,addr wfd
		.endw
		invoke FindClose,hWfd
		mov		eax,TRUE
	.endif
	ret

IsFoderEmpty endp

DeleteFiles proc hWin:HWND
	LOCAL	sfo:SHFILEOPSTRUCT
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke RtlZeroMemory,addr buffer,sizeof buffer
	invoke lstrcpy,addr buffer,addr szDLPath
	invoke lstrcat,addr buffer,addr szAllFiles
	mov		eax,hWin
	mov		sfo.hwnd,eax
	mov		sfo.wFunc,FO_DELETE
	lea		eax,buffer
	mov		sfo.pFrom,eax
	mov		sfo.pTo,NULL
	mov		sfo.fFlags,FOF_ALLOWUNDO
	mov		sfo.fAnyOperationsAborted,0
	mov		sfo.hNameMappings,NULL
	mov		sfo.lpszProgressTitle,offset AppName
	invoke SHFileOperation,ADDR	sfo
	mov		eax,sfo.fAnyOperationsAborted
	ret

DeleteFiles endp

CopyIni proc hWin:HWND
	LOCAL	sfo:SHFILEOPSTRUCT

	mov		eax,hWin
	mov		sfo.hwnd,eax
	mov		sfo.wFunc,FO_COPY
	mov		eax,lpData
	lea		eax,[eax].ADDINDATA.IniFile
	mov		sfo.pFrom,eax
	mov		sfo.pTo,offset szDLPath
	mov		sfo.fFlags,FOF_SILENT	
	mov		sfo.fAnyOperationsAborted,0
	mov		sfo.hNameMappings,NULL
	mov		sfo.lpszProgressTitle,NULL
	invoke SHFileOperation,ADDR	sfo
	mov		eax,sfo.fAnyOperationsAborted
	ret

CopyIni endp

CreateFolder proc uses ebx esi,hWin:HWND

	mov		esi,offset szDLPath
	invoke RtlZeroMemory,esi,sizeof szDLPath
	invoke GetDlgItemText,hWin,IDC_EDTDLPATH,esi,sizeof szDLPath
	invoke GetFileAttributes,esi
	.if eax!=INVALID_HANDLE_VALUE
		; Folder exist
		invoke IsFoderEmpty
		.if !eax
			; Folder is not empty
			invoke wsprintf,addr tempbuff,addr szFmtErrNotEmpty,addr szDLPath
			invoke MessageBox,hWin,addr tempbuff,addr AppName,MB_YESNO or MB_ICONQUESTION
			.if eax==IDYES
				; Delete files
				invoke DeleteFiles,hWin
				.if eax
					xor		eax,eax
				.else
					mov		eax,TRUE
				.endif
			.else
				xor		eax,eax
			.endif
		.else
			; Folder is empty
			mov		eax,TRUE
		.endif
	.else
		; Folder does not exist, create it.
		invoke lstrlen,esi
		mov		ebx,eax
		.while ebx
			.if byte ptr [esi+ebx]=='\'
				mov		byte ptr [esi+ebx],0
				invoke GetFileAttributes,esi
				.if eax!=INVALID_HANDLE_VALUE
					; Path exist
					.while byte ptr [esi+ebx+1]
						mov		byte ptr [esi+ebx],'\'
						invoke CreateDirectory,esi,0
						.while byte ptr [esi+ebx]
							inc		ebx
						.endw
					.endw
					.break
				.endif
			.endif
			dec		ebx
		.endw
		mov		eax,TRUE
	.endif
	ret

CreateFolder endp

CreateTheFile proc uses ebx esi,lpFileName:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke lstrcpy,addr buffer,addr szDLPath
	invoke lstrcat,addr buffer,addr szBackSlash
	invoke lstrcat,addr buffer,lpFileName
	invoke lstrlen,addr buffer
	push	eax
	.while eax
		dec		eax
		.if byte ptr buffer[eax]=='/'
			mov		byte ptr buffer[eax],'\'
		.endif
	.endw
	pop		eax
	.while eax && byte ptr buffer[eax]!='\'
		dec		eax
	.endw
	.if byte ptr buffer[eax]=='\'
		mov		word ptr buffer[eax],0
		call	MakeFolder
		invoke lstrcpy,addr buffer,addr szDLPath
		invoke lstrcat,addr buffer,addr szBackSlash
		invoke lstrcat,addr buffer,lpFileName
		invoke CreateFile,addr buffer,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	.else
		mov		eax,INVALID_HANDLE_VALUE
	.endif
	ret

MakeFolder:
	lea		esi,buffer
	invoke GetFileAttributes,esi
	.if eax==INVALID_HANDLE_VALUE
		invoke lstrlen,esi
		mov		ebx,eax
		.while ebx
			.if byte ptr [esi+ebx]=='\'
				mov		byte ptr [esi+ebx],0
				invoke GetFileAttributes,esi
				.if eax!=INVALID_HANDLE_VALUE
					; Path exist
					.while byte ptr [esi+ebx+1]
						mov		byte ptr [esi+ebx],'\'
						invoke CreateDirectory,esi,0
						.while byte ptr [esi+ebx]
							inc		ebx
						.endw
					.endw
					.break
				.endif
			.endif
			dec		ebx
		.endw
	.endif
	retn

CreateTheFile endp

UnZip proc uses esi,hWin:HWND,lpFileName:DWORD
	LOCAL	hz:DWORD
	LOCAL	fi:unz_file_info
	LOCAL	filename_inzip[MAX_PATH]:BYTE
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hMem:HGLOBAL
	LOCAL	hFile:HANDLE
	LOCAL	dwwrite:DWORD
	LOCAL	ft:FILETIME

	mov		esi,offset szDLPath
	invoke RtlZeroMemory,esi,sizeof szDLPath
	invoke GetDlgItemText,hWin,IDC_EDTDLPATH,esi,sizeof szDLPath
	invoke lstrcpy,addr buffer,addr szDLPath
	invoke lstrcat,addr buffer,addr szBackSlash
	invoke lstrcat,addr buffer,lpFileName
	invoke SendDlgItemMessage,hWin,IDC_EDTVERSION,EM_REPLACESEL,0,addr buffer
	invoke SendDlgItemMessage,hWin,IDC_EDTVERSION,EM_REPLACESEL,0,addr szCRLF
	invoke unzOpen,addr buffer
	.if eax
		mov		hz,eax
		invoke unzGoToFirstFile,hz
		.while !eax
			invoke unzGetCurrentFileInfo,hz,addr fi,addr filename_inzip,sizeof filename_inzip,NULL,0,NULL,0
			.if !eax
				invoke SendDlgItemMessage,hWin,IDC_EDTVERSION,EM_REPLACESEL,0,addr filename_inzip
				invoke SendDlgItemMessage,hWin,IDC_EDTVERSION,EM_REPLACESEL,0,addr szCRLF
				invoke unzOpenCurrentFile,hz
				.if !eax
					invoke GlobalAlloc,GMEM_FIXED,fi.uncompressed_size
					mov		hMem,eax
					invoke unzReadCurrentFile,hz,hMem,fi.uncompressed_size
					.if eax==fi.uncompressed_size
						invoke CreateTheFile,addr filename_inzip
						.if eax!=INVALID_HANDLE_VALUE
							mov		hFile,eax
							invoke WriteFile,hFile,hMem,fi.uncompressed_size,addr dwwrite,NULL
							mov		ecx,fi.dosDate
							movzx	edx,cx
							shr		ecx,16
							invoke DosDateTimeToFileTime,ecx,edx,addr ft
							invoke SetFileTime,hFile,addr ft,addr ft,addr ft
							invoke CloseHandle,hFile
						.endif
						invoke GlobalFree,hMem
						invoke unzCloseCurrentFile,hz
						invoke unzGoToNextFile,hz
					.endif
				.endif
			.endif
		.endw
		invoke unzClose,hz
		invoke DeleteFile,addr buffer
		invoke SendDlgItemMessage,hWin,IDC_EDTVERSION,EM_REPLACESEL,0,addr szCRLF
	.endif
	ret

UnZip endp

UpdateCheckerProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,lpData
		invoke lstrcpy,addr szDLPath,addr [eax].ADDINDATA.AppPath
		invoke lstrcat,addr szDLPath,addr szTemp
		invoke SetDlgItemText,hWin,IDC_EDTDLPATH,addr szDLPath
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				; Get version
				invoke RtlZeroMemory,addr tempbuff,sizeof tempbuff
				invoke InetGetVersion,addr szUrlVersion,addr tempbuff,1023
				.if eax==-1
					mov		eax,offset szINetErr1
				.elseif eax==-2
					mov		eax,offset szINetErr2
				.elseif eax==-3
					mov		eax,offset szINetErr3
				.elseif eax==-4
					mov		eax,offset szINetErr4
				.else
					.if word ptr tempbuff=='!<'
						mov		eax,offset szINetErr4
					.else
						mov		eax,IDC_EDTDLPATH
						call	Enable
						mov		eax,IDC_BTNDLPATH
						call	Enable
						invoke GetDlgItem,hWin,IDOK
						invoke ShowWindow,eax,SW_HIDE
						invoke GetDlgItem,hWin,IDC_BTNDOWNLOAD
						invoke ShowWindow,eax,SW_SHOW
						mov		edx,lpData
						invoke wsprintf,addr tempbuff[1024],addr szFmtVersion,[edx].ADDINDATA.lpszVersion,addr tempbuff
						lea		eax,tempbuff[1024]
					.endif
				.endif
				invoke SetDlgItemText,hWin,IDC_EDTVERSION,eax
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNDLPATH
				invoke BrowseFolder,hWin,IDC_EDTDLPATH
			.elseif eax==IDC_BTNDOWNLOAD
				mov		nDLErrors,0
				invoke CreateFolder,hWin
				.if eax
					invoke SetDlgItemText,hWin,IDC_EDTVERSION,0
					invoke InetDownload,hWin,addr szIDEFile
					.if !nDLErrors
						invoke GetDlgItem,hWin,IDC_BTNDOWNLOAD
						invoke ShowWindow,eax,SW_HIDE
						invoke GetDlgItem,hWin,IDC_BTNUNZIP
						invoke ShowWindow,eax,SW_SHOW
						mov		eax,IDC_EDTDLPATH
						call	Disable
						mov		eax,IDC_BTNDLPATH
						call	Disable
					.endif
				.endif
			.elseif eax==IDC_BTNUNZIP
				invoke SetDlgItemText,hWin,IDC_EDTVERSION,0
				invoke UnZip,hWin,addr szIDEFile
				invoke CopyIni,hWin
				invoke SendDlgItemMessage,hWin,IDC_EDTVERSION,EM_REPLACESEL,0,addr szDone
				invoke GetDlgItem,hWin,IDC_BTNUNZIP
				invoke ShowWindow,eax,SW_HIDE
				invoke GetDlgItem,hWin,IDC_BTNTEST
				invoke ShowWindow,eax,SW_SHOW
				invoke GetDlgItem,hWin,IDC_BTNVIEW
				invoke ShowWindow,eax,SW_SHOW
			.elseif eax==IDC_BTNTEST
				invoke GetDlgItem,hWin,IDC_BTNTEST
				invoke ShowWindow,eax,SW_HIDE
				invoke SetDlgItemText,hWin,IDCANCEL,addr szClose
				invoke lstrcpy,addr tempbuff,addr szDLPath
				invoke lstrcat,addr tempbuff,addr szMasmEd
				invoke WinExec,addr tempbuff,SW_SHOWDEFAULT
				mov		edx,lpData
				invoke wsprintf,addr tempbuff,addr szFmtTest,addr szDLPath,addr [edx].ADDINDATA.AppPath
				invoke SetDlgItemText,hWin,IDC_EDTVERSION,addr tempbuff
			.elseif eax==IDC_BTNVIEW
				invoke lstrcpy,addr tempbuff,addr szDLPath
				invoke lstrcat,addr tempbuff,addr szWhatsNew
				invoke ShellExecute,hWin,addr szOpen,addr tempbuff,NULL,NULL,SW_SHOWNORMAL
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

Enable:
	invoke GetDlgItem,hWin,eax
	invoke EnableWindow,eax,TRUE
	retn

Disable:
	invoke GetDlgItem,hWin,eax
	invoke EnableWindow,eax,FALSE
	retn

UpdateCheckerProc endp

;#########################################################################
; Menu

AddMenuItem proc hMnu:HMENU,nID:DWORD,lpszMenuItem:DWORD

	invoke AppendMenu,hMnu,MF_STRING,nID,lpszMenuItem
	ret

AddMenuItem endp

UpdateMenu proc
	LOCAL	mii:MENUITEMINFO

	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_SUBMENU
	mov		edx,lpHandles
	invoke GetMenuItemInfo,[edx].ADDINHANDLES.hmenu,10151,FALSE,addr mii
	invoke AddMenuItem,mii.hSubMenu,[MenuIDAddin],offset szMenuCheck
	ret

UpdateMenu endp

;#########################################################################
; Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance, eax
	mov		eax,TRUE
	ret

DllEntry Endp

; Export this proc
InstallDll proc uses ebx,hWin:DWORD,hInst:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov		lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETFUNCTIONS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax
	invoke SendMessage,ebx,AIM_GETMENUID,0,0	
	mov		MenuIDAddin,eax
	invoke UpdateMenu
	mov		hook.hook1,HOOK_COMMAND or HOOK_MENUREFRESH
	xor		eax,eax
	mov		hook.hook2,eax
	mov		hook.hook3,eax
	mov		hook.hook4,eax
	mov		eax,offset hook
	ret 

InstallDll endp

; Export this proc
DllFunction proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	; This proc handles messages sent from MasmEd to our addin
	; Return TRUE to prevent MasmEd and other addins from executing the command.

	mov		eax,uMsg
	.if eax==AIM_COMMAND
		mov		eax,wParam
		.if eax==MenuIDAddin
			;The menuitem we added has been selected
			invoke DialogBoxParam,hInstance,IDD_DLGCHECK_UPDATE,hWin,Offset UpdateCheckerProc,0
			mov		eax,TRUE
			jmp		ExRet
		.endif
	.elseif eax==AIM_MENUREFRESH
		;invoke UpdateMenu
	.endif
	mov		eax,FALSE
  ExRet:
	ret

DllFunction endp

;#########################################################################

End DllEntry
