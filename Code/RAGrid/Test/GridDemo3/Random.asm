.data?

rseed		dd ?

.code

Random proc uses edx,range:DWORD

	mov eax, 23
	mul rseed
	add eax, 7
	ror eax, 1
	xor eax, rseed
	mov rseed, eax
	xor edx, edx
	div range
	mov eax, edx
	ret

Random endp

RandomStr proc uses edi,lpStr:DWORD

	mov		edi,lpStr
	invoke Random,30
	mov		ecx,eax
	inc		ecx
	.while ecx
	  @@:
		invoke Random,'z'-'A'
		add		al,'A'
		.if al<'a' && al>'Z'
			jmp		@b
		.endif
		mov		[edi],al
		inc		edi
		dec		ecx
	.endw
	mov		byte ptr [edi],0
	ret

RandomStr endp