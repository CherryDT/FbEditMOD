.const

szFmtCopy		BYTE 'Copying: %s%s%s ... ',0
szOK			BYTE 'OK',0Dh,0Ah,0
szFailed		BYTE 'Failed',0Dh,0Ah,0
szUpdated		BYTE 'Updating: %s ... ',0
szUpToDate		BYTE 'Same version',0Dh,0Ah,0
szDone			BYTE 0Dh,0Ah,'Done updating.',0Dh,0Ah,0

.code

IsRadASMRunning proc hWin:HWND

	invoke FindWindow,addr szMdiClassName,NULL
	.if eax
		invoke SetDlgItemText,hWin,IDC_EDTLOG,addr szErrStillRunning
		mov		eax,TRUE
	.endif
	ret

IsRadASMRunning endp

FileExists proc hWin:HWND,lpFileName:DWORD,fShowErr:DWORD
	LOCAL	buffer[MAX_PATH+sizeof szErrNotFound]:BYTE

	invoke GetFileAttributes,lpFileName
	.if eax==INVALID_HANDLE_VALUE
		.if fShowErr
			invoke lstrcpy,addr buffer,addr szErrNotFound
			invoke lstrcat,addr buffer,lpFileName
			invoke SetDlgItemText,hWin,IDC_EDTLOG,addr buffer
		.endif
		xor		eax,eax
	.else
		mov		eax,TRUE
	.endif
	ret

FileExists endp

GetFileVersion proc hWin:HWND,lpFileName:DWORD,lpVersion:DWORD
	LOCAL	lpHandle:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	hMem:HGLOBAL
	LOCAL	lpBuffer:DWORD
	LOCAL	nLang:DWORD
	LOCAL	nCP:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke GetFileVersionInfoSize,lpFileName,addr lpHandle
	.if eax
		mov		nBytes,eax
		invoke GlobalAlloc,GMEM_ZEROINIT or GMEM_FIXED,nBytes
		mov		hMem,eax
		invoke GetFileVersionInfo,lpFileName,0,nBytes,hMem
		.if eax
			invoke VerQueryValue,hMem,addr szVarTrans,addr lpBuffer,addr nBytes
			.if eax
				mov		eax,lpBuffer
				mov		eax,[eax]
				movzx	edx,ax
				shr		eax,16
				mov		nLang,edx
				mov		nCP,eax
				;FileVersion
				invoke wsprintf,addr buffer,addr szFileStringFormat,nLang,nCP,addr szFileVersion
				invoke VerQueryValue,hMem,addr buffer,addr lpBuffer,addr nBytes
				.if eax
					invoke lstrcpy,lpVersion,lpBuffer
				.endif
			.endif
		.endif
		invoke GlobalFree,hMem
	.endif
	ret
	
GetFileVersion endp

CopyTheFiles proc hWin:HWND,lpFromPath:DWORD,lpToPath:DWORD,lpFileName:DWORD,fFlags:DWORD
	LOCAL	sfo:SHFILEOPSTRUCT
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke wsprintf,addr buffer,addr szFmtCopy,lpFromPath,addr szBS,lpFileName
	invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr buffer
	invoke RtlZeroMemory,addr buffer,sizeof buffer
	invoke lstrcpy,addr buffer,lpFromPath
	invoke lstrcat,addr buffer,addr szBS
	invoke lstrcat,addr buffer,lpFileName
	mov		eax,hWin
	mov		sfo.hwnd,eax
	mov		sfo.wFunc,FO_COPY
	lea		eax,buffer
	mov		sfo.pFrom,eax
	mov		eax,lpToPath
	mov		sfo.pTo,eax
	mov		eax,fFlags
	mov		sfo.fFlags,ax
	mov		sfo.fAnyOperationsAborted,FALSE
	mov		sfo.hNameMappings,NULL
	mov		sfo.lpszProgressTitle,offset szAppName
	invoke SHFileOperation,ADDR	sfo
	mov		eax,sfo.fAnyOperationsAborted
	.if eax
		mov		eax,offset szFailed
	.else
		mov		eax,offset szOK
	.endif
	invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,eax
	ret

CopyTheFiles endp

InstallNewLanguages proc hWin:HWND
	LOCAL	wfd:WIN32_FIND_DATA
	LOCAL	hWfd:HANDLE
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	szfrom[MAX_PATH]:BYTE
	LOCAL	szto[MAX_PATH]:BYTE

	invoke lstrcpy,addr buffer,addr szAppPath
	invoke lstrcat,addr buffer,addr szBS
	invoke lstrcat,addr buffer,addr szAllIni
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		mov		hWfd,eax
		.while eax
			invoke lstrcpy,addr buffer,addr szAppPath
			invoke lstrcat,addr buffer,addr szBS
			invoke lstrcat,addr buffer,addr wfd.cFileName
			invoke GetPrivateProfileString,addr szIniVersion,addr szIniDescription,addr szNULL,addr buffer,sizeof buffer,addr buffer
			.if eax
				;Check if it exists
				invoke lstrcpy,addr buffer,addr szRadASMPath
				invoke lstrcat,addr buffer,addr szBS
				invoke lstrcat,addr buffer,addr wfd.cFileName
				invoke GetFileAttributes,addr buffer
				.if eax==INVALID_HANDLE_VALUE
					;Does not exist, install it
					invoke CopyTheFiles,hWin,addr szAppPath,addr szRadASMPath,addr wfd.cFileName,FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR
					invoke lstrcpy,addr buffer,addr wfd.cFileName
					invoke lstrlen,addr buffer
					.while buffer[eax]!='.' && eax
						dec		eax
					.endw
					mov		buffer[eax],0
					invoke lstrcpy,addr szfrom,addr szAppPath
					invoke lstrcat,addr szfrom,addr szBS
					invoke lstrcat,addr szfrom,addr buffer
					invoke lstrcpy,addr szto,addr szRadASMPath
					invoke lstrcat,addr szto,addr szBS
					invoke lstrcat,addr szto,addr buffer
					invoke CopyTheFiles,hWin,addr szfrom,addr szto,addr szAllFiles,FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR
				.endif
			.endif
			invoke FindNextFile,hWfd,addr wfd
		.endw
		invoke FindClose,hWfd
		mov		eax,TRUE
	.endif
	ret

InstallNewLanguages endp

UpdateRadASMIni proc hWin:HWND
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	szfrom[MAX_PATH]:BYTE
	LOCAL	szto[MAX_PATH]:BYTE
	LOCAL	verold:DWORD
	LOCAL	vernew:DWORD

	invoke lstrcpy,addr szfrom,addr szAppPath
	invoke lstrcat,addr szfrom,addr szBS
	invoke lstrcat,addr szfrom,addr szRadASMIni
	invoke GetPrivateProfileInt,addr szIniVersion,addr szIniVersion,0,addr szfrom
	mov		vernew,eax
	invoke lstrcpy,addr szto,addr szRadASMPath
	invoke lstrcat,addr szto,addr szBS
	invoke lstrcat,addr szto,addr szRadASMIni
	invoke GetPrivateProfileInt,addr szIniVersion,addr szIniVersion,0,addr szto
	mov		verold,eax
	.if eax<vernew && eax>=3000
		.if eax==3000
			;3000 --> 3001, no update needed
			mov		eax,3001
		.endif
		.if eax==3001
			;3001 --> 3002, no update needed
			mov		eax,3002
		.endif
		.if eax==3002
			;3002 --> 3003, no update needed
			mov		eax,3003
		.endif
		.if eax==3003
			;3003 --> 3004, no update needed
			mov		eax,3004
		.endif
		.if eax==3004
			;3004 --> 3005
			;PrijectZip
			invoke GetPrivateProfileSection,addr szIniProjectZip,addr szTmpBuff,sizeof szTmpBuff,addr szfrom
			invoke WritePrivateProfileSection,addr szIniProjectZip,addr szTmpBuff,addr szto
			mov		eax,3005
		.endif
		.if eax==3005
			;3005 --> 3006, no update needed
			mov		eax,3006
		.endif
		.if eax==3006
			;3006 --> 3007, no update needed
			mov		eax,3007
		.endif
		.if eax==3007
			;3007 --> 3008, no update needed
			mov		eax,3008
		.endif
		invoke wsprintf,addr buffer,addr szDecFormat,vernew
		invoke WritePrivateProfileString,addr szIniVersion,addr szIniVersion,addr buffer,addr szto
		invoke wsprintf,addr buffer,addr szUpdated,addr szto
		invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr buffer
		invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr szOK
	.elseif eax==vernew
		invoke wsprintf,addr buffer,addr szUpdated,addr szto
		invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr buffer
		invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr szUpToDate
	.else
		invoke wsprintf,addr buffer,addr szUpdated,addr szto
		invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr buffer
		invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr szFailed
	.endif
	ret

UpdateRadASMIni endp

UpdateLanguageIni proc uses ebx,hWin:HWND
	LOCAL	wfd:WIN32_FIND_DATA
	LOCAL	hWfd:HANDLE
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	szfrom[MAX_PATH]:BYTE
	LOCAL	szto[MAX_PATH]:BYTE
	LOCAL	verold:DWORD
	LOCAL	vernew:DWORD

	invoke lstrcpy,addr buffer,addr szAppPath
	invoke lstrcat,addr buffer,addr szBS
	invoke lstrcat,addr buffer,addr szAllIni
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		mov		hWfd,eax
		.while eax
			invoke lstrcpy,addr szfrom,addr szAppPath
			invoke lstrcat,addr szfrom,addr szBS
			invoke lstrcat,addr szfrom,addr wfd.cFileName
			invoke GetPrivateProfileString,addr szIniVersion,addr szIniDescription,addr szNULL,addr buffer,sizeof buffer,addr szfrom
			.if eax
				invoke GetPrivateProfileInt,addr szIniVersion,addr szIniVersion,0,addr szfrom
				mov		vernew,eax
				invoke lstrcpy,addr szto,addr szRadASMPath
				invoke lstrcat,addr szto,addr szBS
				invoke lstrcat,addr szto,addr wfd.cFileName
				invoke GetPrivateProfileInt,addr szIniVersion,addr szIniVersion,0,addr szto
				mov		verold,eax
				.if eax<vernew && eax>=3000
					.if eax==3000
						;3000 --> 3001
						invoke GetPrivateProfileInt,addr szIniParse,addr szIniAssembler,0,addr szto
						.if eax==1
							;Masm, jWasm
							mov		word ptr buffer,'1'
						.else
							;All others
							mov		word ptr buffer,'0'
						.endif
						invoke WritePrivateProfileString,addr szIniParse,addr szIniDebug,addr buffer,addr szto
						mov		eax,3001
					.endif
					.if eax==3001
						;3001 --> 3002
						;Add RadASM help file to help menu
						xor		ebx,ebx
						.while TRUE
							invoke wsprintf,addr buffer,addr szDecFormat,ebx
							invoke GetPrivateProfileString,addr szIniHelp,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr szto
							.if !eax
								invoke wsprintf,addr buffer,addr szDecFormat,ebx
								invoke WritePrivateProfileString,addr szIniHelp,addr buffer,addr szRadASMHelp,addr szto
								.break
							.endif
							inc		ebx
						.endw
					.endif
					.if eax==3002
						;3002 --> 3003
						;No update needed
						mov		eax,3003
					.endif
					.if eax==3003
						;3003 --> 3004
						;No update needed
						mov		eax,3004
					.endif
					.if eax==3004
						;3004 --> 3005
						;No update needed
						mov		eax,3005
					.endif
					.if eax==3005
						;3005 --> 3006
						;No update needed
						mov		eax,3006
					.endif
					.if eax==3006
						;3006 --> 3007
						;No update needed
						mov		eax,3007
					.endif
					invoke wsprintf,addr buffer,addr szDecFormat,vernew
					invoke WritePrivateProfileString,addr szIniVersion,addr szIniVersion,addr buffer,addr szto
					invoke wsprintf,addr buffer,addr szUpdated,addr szto
					invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr szOK
				.elseif eax==vernew
					invoke wsprintf,addr buffer,addr szUpdated,addr szto
					invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr szUpToDate
				.else
					invoke wsprintf,addr buffer,addr szUpdated,addr szto
					invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr szFailed
				.endif
			.endif
			invoke FindNextFile,hWfd,addr wfd
		.endw
		invoke FindClose,hWfd
	.endif
	ret

UpdateLanguageIni endp

CopyTemplates proc hWin:HWND,fNewOnly:DWORD
	LOCAL	wfd:WIN32_FIND_DATA
	LOCAL	hWfd:HANDLE
	LOCAL	hWfd2:HANDLE
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer2[MAX_PATH]:BYTE
	LOCAL	szfrom[MAX_PATH]:BYTE
	LOCAL	szto[MAX_PATH]:BYTE

	invoke lstrcpy,addr buffer,addr szAppPath
	invoke lstrcat,addr buffer,addr szBS
	invoke lstrcat,addr buffer,addr szAllIni
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		mov		hWfd,eax
		.while eax
			invoke lstrcpy,addr buffer,addr szAppPath
			invoke lstrcat,addr buffer,addr szBS
			invoke lstrcat,addr buffer,addr wfd.cFileName
			invoke GetPrivateProfileString,addr szIniVersion,addr szIniDescription,addr szNULL,addr buffer,sizeof buffer,addr buffer
			.if eax
				invoke lstrcpy,addr buffer,addr wfd.cFileName
				invoke lstrlen,addr buffer
				.while buffer[eax]!='.' && eax
					dec		eax
				.endw
				mov		buffer[eax],0
				invoke lstrcpy,addr szfrom,addr szAppPath
				invoke lstrcat,addr szfrom,addr szBS
				invoke lstrcat,addr szfrom,addr buffer
				invoke lstrcat,addr szfrom,addr szBS
				invoke lstrcat,addr szfrom,addr szTemplates
				invoke lstrcpy,addr szto,addr szRadASMPath
				invoke lstrcat,addr szto,addr szBS
				invoke lstrcat,addr szto,addr buffer
				invoke lstrcat,addr szto,addr szBS
				invoke lstrcat,addr szto,addr szTemplates
				.if fNewOnly
					invoke lstrcpy,addr buffer2,addr szfrom
					invoke lstrcat,addr buffer2,addr szBS
					invoke lstrcat,addr buffer2,addr szAllTpl
					invoke FindFirstFile,addr buffer2,addr wfd
					.if eax!=INVALID_HANDLE_VALUE
						mov		hWfd2,eax
						.while eax
							;Check if it exists
							invoke lstrcpy,addr buffer2,addr szto
							invoke lstrcat,addr buffer2,addr szBS
							invoke lstrcat,addr buffer2,addr wfd.cFileName
							invoke GetFileAttributes,addr buffer2
							.if eax==INVALID_HANDLE_VALUE
								invoke CopyTheFiles,hWin,addr szfrom,addr szto,addr wfd.cFileName,FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR
							.endif
							invoke FindNextFile,hWfd2,addr wfd
						.endw
						invoke FindClose,hWfd2
					.endif
				.else
					invoke CopyTheFiles,hWin,addr szfrom,addr szto,addr szAllTpl,FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR
				.endif
			.endif
			invoke FindNextFile,hWfd,addr wfd
		.endw
		invoke FindClose,hWfd
	.endif
	ret

CopyTemplates endp

CopySniplets proc hWin:HWND,fNewOnly:DWORD
	LOCAL	wfd:WIN32_FIND_DATA
	LOCAL	hWfd:HANDLE
	LOCAL	hWfd2:HANDLE
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer2[MAX_PATH]:BYTE
	LOCAL	szfrom[MAX_PATH]:BYTE
	LOCAL	szto[MAX_PATH]:BYTE

	invoke lstrcpy,addr buffer,addr szAppPath
	invoke lstrcat,addr buffer,addr szBS
	invoke lstrcat,addr buffer,addr szAllIni
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		mov		hWfd,eax
		.while eax
			invoke lstrcpy,addr buffer,addr szAppPath
			invoke lstrcat,addr buffer,addr szBS
			invoke lstrcat,addr buffer,addr wfd.cFileName
			invoke GetPrivateProfileString,addr szIniVersion,addr szIniDescription,addr szNULL,addr buffer,sizeof buffer,addr buffer
			.if eax
				invoke lstrcpy,addr buffer,addr wfd.cFileName
				invoke lstrlen,addr buffer
				.while buffer[eax]!='.' && eax
					dec		eax
				.endw
				mov		buffer[eax],0
				invoke lstrcpy,addr szfrom,addr szAppPath
				invoke lstrcat,addr szfrom,addr szBS
				invoke lstrcat,addr szfrom,addr buffer
				invoke lstrcat,addr szfrom,addr szBS
				invoke lstrcat,addr szfrom,addr szSniplets
				invoke lstrcpy,addr szto,addr szRadASMPath
				invoke lstrcat,addr szto,addr szBS
				invoke lstrcat,addr szto,addr buffer
				invoke lstrcat,addr szto,addr szBS
				invoke lstrcat,addr szto,addr szSniplets
				.if fNewOnly
					invoke lstrcpy,addr buffer2,addr szfrom
					invoke lstrcat,addr buffer2,addr szBS
					invoke lstrcat,addr buffer2,addr szAllFiles
					invoke FindFirstFile,addr buffer2,addr wfd
					.if eax!=INVALID_HANDLE_VALUE
						mov		hWfd2,eax
						.while eax
							;Check if it exists
							invoke lstrcpy,addr buffer2,addr szto
							invoke lstrcat,addr buffer2,addr szBS
							invoke lstrcat,addr buffer2,addr wfd.cFileName
							invoke GetFileAttributes,addr buffer2
							.if eax==INVALID_HANDLE_VALUE
								invoke CopyTheFiles,hWin,addr szfrom,addr szto,addr wfd.cFileName,FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR
							.endif
							invoke FindNextFile,hWfd2,addr wfd
						.endw
						invoke FindClose,hWfd2
					.endif
				.else
					invoke CopyTheFiles,hWin,addr szfrom,addr szto,addr szAllFiles,FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR
				.endif
			.endif
			invoke FindNextFile,hWfd,addr wfd
		.endw
		invoke FindClose,hWfd
	.endif
	ret

CopySniplets endp

CopyLanguageIni proc hWin:HWND
	LOCAL	wfd:WIN32_FIND_DATA
	LOCAL	hWfd:HANDLE
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke lstrcpy,addr buffer,addr szAppPath
	invoke lstrcat,addr buffer,addr szBS
	invoke lstrcat,addr buffer,addr szAllIni
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		mov		hWfd,eax
		.while eax
			invoke lstrcpy,addr buffer,addr szAppPath
			invoke lstrcat,addr buffer,addr szBS
			invoke lstrcat,addr buffer,addr wfd.cFileName
			invoke GetPrivateProfileString,addr szIniVersion,addr szIniDescription,addr szNULL,addr buffer,sizeof buffer,addr buffer
			.if eax
				invoke CopyTheFiles,hWin,addr szAppPath,addr szRadASMPath,addr wfd.cFileName,FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR
			.endif
			invoke FindNextFile,hWfd,addr wfd
		.endw
		invoke FindClose,hWfd
	.endif
	ret

CopyLanguageIni endp

Update proc hWin:HWND
	LOCAL	szfrom[MAX_PATH]:BYTE
	LOCAL	szto[MAX_PATH]:BYTE

	invoke SetDlgItemText,hWin,IDC_EDTLOG,addr szNULL
	;Copy Addins
	invoke lstrcpy,addr szfrom,addr szAppPath
	invoke lstrcat,addr szfrom,addr szBS
	invoke lstrcat,addr szfrom,addr szAddins
	invoke lstrcpy,addr szto,addr szRadASMPath
	invoke lstrcat,addr szto,addr szBS
	invoke lstrcat,addr szto,addr szAddins
	invoke CopyTheFiles,hWin,addr szfrom,addr szto,addr szAllFiles,FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR
	;Copy help files
	invoke lstrcpy,addr szfrom,addr szAppPath
	invoke lstrcat,addr szfrom,addr szBS
	invoke lstrcat,addr szfrom,addr szHelp
	invoke lstrcpy,addr szto,addr szRadASMPath
	invoke lstrcat,addr szto,addr szBS
	invoke lstrcat,addr szto,addr szHelp
	invoke CopyTheFiles,hWin,addr szfrom,addr szto,addr szAllFiles,FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR
	;Copy RadASM.exe
	invoke CopyTheFiles,hWin,addr szAppPath,addr szRadASMPath,addr szRadASMExe,FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR
	;RadASM.ini
	invoke IsDlgButtonChecked,hWin,IDC_RBNUPRA
	.if eax
		;Update RadASM.ini
		invoke UpdateRadASMIni,hWin
	.else
		;Copy RadASM.ini
		invoke CopyTheFiles,hWin,addr szAppPath,addr szRadASMPath,addr szRadASMIni,FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR
	.endif
	;New languages
	invoke InstallNewLanguages,hWin
	;Language.ini
	invoke IsDlgButtonChecked,hWin,IDC_RBNUPLANG
	.if eax
		;Update Language.ini
		invoke UpdateLanguageIni,hWin
	.else
		;Copy Language.ini
		invoke CopyLanguageIni,hWin
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKOWTEMPLATES
	.if eax
		;Copy all templates
		invoke CopyTemplates,hWin,FALSE
	.else
		;Add new templates
		invoke CopyTemplates,hWin,TRUE
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKOWSNIPLETS
	.if eax
		;Copy all sniplets
		invoke CopySniplets,hWin,FALSE
	.else
		;Add new sniplets
		invoke CopySniplets,hWin,TRUE
	.endif
	invoke GetDlgItem,hWin,IDOK
	invoke EnableWindow,eax,FALSE
	invoke SendDlgItemMessage,hWin,IDC_EDTLOG,EM_REPLACESEL,FALSE,addr szDone
	ret

Update endp
