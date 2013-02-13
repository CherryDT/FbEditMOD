
.const

szDeleted		db 'Deleted: ',0

.code

DeleteFiles proc lpPath:DWORD,lpFileName:DWORD
	LOCAL	hwfd:HANDLE
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke FindFirstFile,lpFileName,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		mov		hwfd,eax
		.while eax
			invoke lstrcpy,addr buffer,lpPath
			invoke lstrcat,addr buffer,addr wfd.cFileName
			invoke DeleteFile,addr buffer
			.if eax
				invoke lstrcpy,offset tempbuff,offset szDeleted
				invoke lstrcat,offset tempbuff,addr buffer
				invoke OutputString,offset tempbuff
			.endif
			invoke FindNextFile,hwfd,addr wfd
		.endw
		invoke FindClose,hwfd
	.endif
	ret

DeleteFiles endp

DeleteMinorFiles proc uses ebx esi
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	path[MAX_PATH]:BYTE
	LOCAL	files[MAX_PATH]:BYTE

	mov		ebx,lpData
	.if [ebx].ADDINDATA.szSessionFile
		invoke GetPrivateProfileString,addr szSession,addr szMinorFiles,addr szNULL,addr files,sizeof files,addr [ebx].ADDINDATA.szSessionFile
		.if files
			invoke lstrcpy,addr path,addr [ebx].ADDINDATA.MainFile
			.if path
				invoke lstrlen,addr path
				.while eax && byte ptr path[eax-1]!='\'
					dec		eax
				.endw
				mov		path[eax],0
				xor		eax,eax
				.while files[eax]
					.if files[eax]==';'
						mov		files[eax],0
					.endif
					inc		eax
				.endw
				mov		files[eax+1],0
				invoke OutputString,offset szNULL
				lea		esi,files
				.while byte ptr [esi]
					invoke lstrcpy,addr buffer,addr path
					invoke lstrcat,addr buffer,esi
					invoke DeleteFiles,addr path,addr buffer
					invoke lstrlen,esi
					lea		esi,[esi+eax+1]
				.endw
			.endif
		.endif
	.endif
	ret

DeleteMinorFiles endp
