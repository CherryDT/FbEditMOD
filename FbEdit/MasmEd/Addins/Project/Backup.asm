
.code

BackupEdit proc uses esi edi,lpFileName:DWORD,Backup:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer2[MAX_PATH]:BYTE
	LOCAL	BackupPath[MAX_PATH]:BYTE
	LOCAL	dotpos:DWORD

	mov		esi,lpData
	lea		esi,[esi].ADDINDATA.MainFile
	.if !nBackup || !byte ptr [esi]
		ret
	.endif
	invoke lstrcpy,addr BackupPath,esi
	lea		esi,BackupPath
	invoke lstrlen,esi
	.while eax
		.if byte ptr [esi+eax]=='\'
			mov		byte ptr [esi+eax],0
			.break
		.endif
		dec		eax
	.endw
	invoke lstrcat,addr BackupPath,addr szBak
	mov		esi,lpFileName
	invoke lstrlen,esi
	.while eax && byte ptr [esi+eax]!='\'
		.if byte ptr [esi+eax]=='.'
			lea		edx,[esi+eax]
			mov		dotpos,edx
		.endif
		dec		eax
	.endw
	lea		esi,[esi+eax]
	lea		edi,buffer2
  @@:
	cmp		esi,dotpos
	je		@f
	mov		al,[esi]
	or		al,al
	je		@f
	mov		[edi],al
	inc		esi
	inc		edi
	cmp		al,'\'
	jne		@b
	lea		edi,buffer2
	jmp		@b
  @@:
	mov		byte ptr [edi],0
	invoke lstrcpy,addr buffer,addr BackupPath
	invoke lstrcat,addr buffer,addr buffer2
	invoke lstrlen,addr buffer
	lea		edi,buffer
	add		edi,eax
	.if Backup==1
		mov		al,'('
		mov		[edi],al
		inc		edi
		mov		al,'1'
		mov		[edi],al
		inc		edi
		mov		al,')'
		mov		[edi],al
		inc		edi
	.else
		mov		al,[edi-2]
		inc		al
		mov		[edi-2],al
	.endif
  @@:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jne		@b
	mov		eax,Backup
	.if eax<nBackup
		invoke GetFileAttributes,addr buffer
		.if eax!=INVALID_HANDLE_VALUE
			;File exist
			mov		eax,Backup
			inc		eax
			invoke BackupEdit,addr buffer,eax
		.endif
	.endif
	;Rename file
	invoke CopyFile,lpFileName,addr buffer,FALSE
	ret

BackupEdit endp

