.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include asm8051.inc

.code

BinToDec proc uses ebx ecx edx esi edi,dwVal:DWORD,lpAscii:DWORD

	mov		eax,dwVal
	mov		edi,lpAscii
	or		eax,eax
	jns		pos
	mov		byte ptr [edi],'-'
	neg		eax
	inc		edi
  pos:      
	mov		ecx,429496730
	mov		esi,edi
  @@:
	mov		ebx,eax
	mul		ecx
	mov		eax,edx
	lea		edx,[edx*4+edx]
	add		edx,edx
	sub		ebx,edx
	add		bl,'0'
	mov		[edi],bl
	inc		edi
	or		eax,eax
	jne		@b
	mov		byte ptr [edi],al
	.while esi<edi
		dec		edi
		mov		al,[esi]
		mov		ah,[edi]
		mov		[edi],al
		mov		[esi],ah
		inc		esi
	.endw
    ret

BinToDec endp

PrintLineNumber proc nLine:DWORD
	LOCAL	buffer[64]:BYTE

	invoke lstrlen,addr InpFile
	invoke WriteFile,hOut,addr InpFile,eax,offset dwTemp,NULL
	mov		dword ptr buffer,'('
	invoke BinToDec,nLine,addr buffer[1]
	invoke lstrlen,addr buffer
	mov		dword ptr buffer[eax],' )'
	inc		eax
	inc		eax
	invoke WriteFile,hOut,addr buffer,eax,offset dwTemp,NULL
	invoke lstrlen,addr szError
	invoke WriteFile,hOut,addr szError,eax,offset dwTemp,NULL
	ret

PrintLineNumber endp

PrintStringz proc lpText:DWORD

	invoke lstrlen,lpText
	invoke WriteFile,hOut,lpText,eax,offset dwTemp,NULL
	ret

PrintStringz endp

ReadAsmFile proc uses esi,lpFile:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	invoke CreateFile,lpFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,addr nBytes
		push	eax
		inc		eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
		mov		esi,eax
		pop		edx
		invoke ReadFile,hFile,esi,edx,addr nBytes,NULL
		invoke CloseHandle,hFile
		mov		eax,esi
	.else
		xor		eax,eax
	.endif
	ret

ReadAsmFile endp

AsmLinePass0 proc uses ebx esi edi,lpLine:DWORD

	inc		dword ptr LINE_NUMBER
	mov		esi,lpLine
	mov		edi,offset TEXT_LINE
	mov		ebx,offset PASS0_LINE-1
	xor		cl,cl					;REMARK FLAG
	xor		ch,ch					;TEXT FLAG
  @@:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	.if al==0Ah
		mov		byte ptr [edi],00H
		mov		eax,esi
		clc
		ret
	.elseif al==1Ah || al==00h
		dec		edi
		mov		dword ptr [edi],0A0Dh
		inc		ebx
		mov		byte ptr [ebx],0Dh
		mov		eax,esi
		stc
		ret
	.elseif cl						;REMARK FLAG
		jmp		@b
	.elseif al==09h && ch==00h
		mov		al,20H
	.elseif al=="'"
		xor		ch,0FFH				;TEXT FLAG
	.endif
	.if ch==00h						;TEXT FLAG
		.if al==' '
			xor		al,al
			cmp		al,[ebx]
			jz		@b
		.elseif al==';'
			mov		al,0DH
			inc		cl				;REMARK FLAG
		.endif
	.endif
	inc		ebx
	mov		[ebx],al
	jmp		@b

AsmLinePass0 endp

;PASS 1 ******************************************************

A_ERROR:
	invoke PrintLineNumber,LINE_NUMBER
	call PrintStringz
	mov		eax,offset TEXT_LINE
	.while byte ptr [eax] && (byte ptr [eax]==20h || byte ptr [eax]==09h)
		inc		eax
	.endw
	invoke PrintStringz,eax
	mov		eax,1
	jmp		Exit

IsHex proc uses esi

	.while TRUE
		mov		ax,[esi]
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		.break .if al=='H' && (ah==0Dh || ah==',' || ah=='.' || !ah)
		.if al==0Dh || !al
			mov		al,'D'
			.break
		.endif
		mov		ah,al
		xor		al,al
		.break .if ah<'0' || ah>'F' || (ah>'9' && ah<'A')
		inc		esi
	.endw
	ret

IsHex endp

FindOpCode proc
	LOCAL	edisave:DWORD

	mov		edisave,edi
	mov		ax,[esi]
	.if al=='#'
		mov		ax,8001H		;#
		mov		[edi],ax
		inc		edi
		inc		edi
		inc		esi
		invoke IsHex
		.if al!='D' && al!='H'
			invoke FindAskLabel
		.else
			clc
		.endif
	.elseif al=='$'
		mov		ax,8101H		;$
		mov		[edi],ax
		inc		edi
		inc		edi
		inc		esi
		invoke IsHex
		.if al!='D' && al!='H'
			invoke FindAskLabel
		.else
			clc
		.endif
	.elseif ax=='$/'
		mov		ax,8D01H		;/$
		mov		[edi],ax
		inc		edi
		inc		edi
		inc		esi
		inc		esi
		invoke IsHex
		.if al!='D' && al!='H'
			invoke FindAskLabel
		.else
			clc
		.endif
	.elseif (al>='@' && al<='Z') || (al>='a' && al<='z')
		mov		ebx,offset OP_CODES
	  FIND_OP_CODE1:
		mov		ah,[ebx]
		.if !ah
			.if esi==offset PASS0_LINE
				stc
			.else
				mov		edi,edisave
				mov		ax,8101H		;$
				mov		[edi],ax
				inc		edi
				inc		edi
				invoke FindAskLabel
			.endif
			ret
		.endif
		inc		ebx
		push	esi
	  FIND_OP_CODE2:
		mov		al,[esi]
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		.if al==byte ptr [ebx]
			inc		esi
			inc		ebx
			cmp		al,'+'
			jnz		@f
			mov		al,[ebx]
		  @@:
			or		al,al
			jnz		FIND_OP_CODE2
			pop		ebx
			mov		byte ptr [edi],01H
			inc		edi
			mov		[edi],ah
			inc		edi
			ret
		.endif
		.if !al || al==',' || al=='.' || al==0Dh
			mov		al,[ebx]
			.if !al
				pop		ebx
				mov		byte ptr [edi],01H
				inc		edi
				mov		[edi],ah
				inc		edi
				ret
			.endif
		.endif
		.while byte ptr [ebx]
			inc		ebx
		.endw
		inc		ebx
		pop		esi
		jmp		FIND_OP_CODE1
	.else
		stc
	.endif
	ret

FindOpCode endp

FindDefLabel proc

	mov		al,[esi]
	push	esi
	push	edi
	.if al>='A' && al<='Z' || (al>='a' && al<='z')
		mov		byte ptr [edi],02H
		inc		edi
	  @@:
		mov		al,[esi]
		.if al==':'
			inc		esi
			mov		byte ptr [edi],00H
			inc		edi
			pop		eax
			pop		eax
			clc
			ret
		.elseif !al
			mov		byte ptr [edi],00H
			inc		edi
			pop		eax
			pop		eax
			clc
			ret
		.elseif (al>='A' && al<='Z') || (al>='a' && al<='z') || (al>='0' && al<='9') || al=='_'
			mov		[edi],al
			inc		esi
			inc		edi
			jmp		@b
		.endif
	.endif
	pop		edi
	pop		esi
	stc
	ret

FindDefLabel endp

FindAskLabel proc

	mov		al,[esi]
	.if al>='A' && al<='Z' || (al>='a' && al<='z')
		mov		byte ptr [edi],10H
		inc		edi
	  @@:
		mov		al,[esi]
		.if (al>='A' && al<='Z') || (al>='a' && al<='z') || (al>='0' && al<='9') || al=='_'
			mov		[edi],al
			inc		esi
			inc		edi
			jmp		@b
		.endif
		mov		byte ptr [edi],00H
		inc		edi
		clc
		ret
	.endif
	stc
	ret

FindAskLabel endp

FindImmData proc
	LOCAL	fNeg:DWORD

	xor		cl,cl
	xor		ebx,ebx
	mov		al,[esi]
	.if al>='0' && al<='9'
		invoke IsHex
		.if al=='H'
		  FIND_IMM_DATA1:
			mov		al,[esi]
			.if al>='a' && al<='z'
				and		al,5Fh
			.endif
			.if (al>='0' && al<='9') || (al>='A' && al<='F')
				sub		al,'0'
				cmp		al,0AH
				jb		@f
				sub		al,07H
			  @@:
				shl		bx,1
				shl		bx,1
				shl		bx,1
				shl		bx,1
				add		bl,al
				inc		cl
				inc		esi
				jmp		FIND_IMM_DATA1
			.endif
			.if al=='H'
				inc		esi
			.endif
			.if byte ptr [edi-1]=='-'
				dec		edi
				xor		bx,0FFFFH
				inc		bx
			.endif
			.if cl<4
				mov		byte ptr [edi],08H		;BYTE
				inc		edi
				mov		[edi],bl
				inc		edi
			.else
				mov		byte ptr [edi],09H		;WORD
				inc		edi
				mov		[edi],bx
				inc		edi
				inc		edi
			.endif
		.else
		    mov		fNeg,FALSE
		    mov		al,[esi]
		    .if al=='-'
				inc		esi
				mov		fNeg,TRUE
		    .endif
		    xor     eax,eax
		  @@:
		    cmp     byte ptr [esi],30h
		    jb      @f
		    cmp     byte ptr [esi],3Ah
		    jnb     @f
		    mov     ebx,eax
		    shl     eax,2
		    add     eax,ebx
		    shl     eax,1
		    xor     ebx,ebx
		    mov     bl,[esi]
		    sub     bl,30h
		    add     eax,ebx
		    inc     esi
		    jmp     @b
		  @@:
			.if !ah
				.if fNeg
					neg		eax
				.endif
				mov		byte ptr [edi],08H		;BYTE
				inc		edi
				mov		[edi],al
				inc		edi
			.else
				.if fNeg
					neg		eax
				.endif
				mov		byte ptr [edi],09H		;WORD
				inc		edi
				mov		[edi],ax
				inc		edi
				inc		edi
			.endif
		.endif
		clc
	.else
		stc
	.endif
	ret

FindImmData endp

FindString proc

	.if byte ptr [esi]=="'"
		mov		byte ptr [edi],0AH
		inc		edi
		inc		esi
	  FIND_STRING1:
		mov		al,[esi]
		.if al=="'"
			mov		byte ptr [edi],00H
			inc		esi
			inc		edi
			clc
			ret
		.elseif al==0Dh
			call	A_ERROR
			db		'MISSING END QUOTE : ',00H
		.endif
		mov		[edi],al
		inc		esi
		inc		edi
		jmp		FIND_STRING1
	.endif
	stc
	ret

FindString endp

SkipZero proc

	.while !byte ptr [esi]
		inc		esi
	.endw
	mov		al,[esi]
	ret

SkipZero endp

;00 EOL
;01 OP CODE
;02 DEF PROG LABEL			PROG_LABLE:
;02 DEF BYTE LABEL			CRLF		EQU	0DH,13
;02 DEF WORD LABEL			SCRN_ADR	EQU	0C000H,12345
;02 DEF DATA LABEL			PRINT_DATA	DB	'ABCDEFGH',0DH,0AH
;							ADR_DATA	DW	0C000H,0D000H
;08 DEF IMMEDIATE BYTE		0DH,13
;09 DEF IMMEDIATE WORD		0C000H,12345
;0A DEF IMMEDIATE DATA		'ABCDEFGH',0DH

;10 ASK PROG LABEL			JNZ	PROG_LABLE
;10 ASK BYTE LABEL			MOV	A,CRLF
;10 ASK WORD LABEL			MOV	A,[SCRN_ADR+0001]
;10 ASK DATA LABEL			MOV	A,[PRINT_DATA]
;2B +
;2C ,
;2D -

AsmLinePass1 proc uses ebx esi edi,lpLine:DWORD

	mov		esi,offset PASS0_LINE
	mov		edi,offset PASS1_LINE
  @@:
	invoke SkipZero
	.if al==0Dh
		mov		byte ptr [edi],00H
		ret
	.endif
	.if al==',' || al=='+' || al=='.'
		mov		[edi],al
		inc		esi
		inc		edi
		.if al=='.'
			mov		al,[esi]
			cmp		al,'0'
			jb		@f
			cmp		al,'8'
			jnb		@f
			mov		[edi],al
			inc		esi
			inc		edi
		.endif
		jmp		@b
	.endif
	invoke FindOpCode
	jnb		@b
	invoke FindDefLabel
	jnb		@b
	invoke FindImmData
	jnb		@b
	invoke FindAskLabel
	jnb		@b
	invoke FindString
	jnb		@b
  @@:
	call	A_ERROR
	db		'PASS 1 SYNTAX ERROR : ',00H

AsmLinePass1 endp

;PASS 2 ******************************************************

SWAP_BYTES:
		push	eax
		push	ebx
		mov		ebx,SWAP_PRG_ADR
		add		ebx,hCmdMem
		mov		ax,word ptr [ebx]
		xchg	al,ah
		mov		word ptr [ebx],ax
		pop		ebx
		pop		eax
		ret

WRITE_BYTE:
		push	ebx
		mov		ebx,PRG_ADR
		add		ebx,hCmdMem
		mov		byte ptr [ebx],al
		inc		PRG_ADR
		mov		ebx,PRG_ADR
		cmp		ebx,NO_OF_BYTES
		jb		WRITE_BYTE1
		mov		NO_OF_BYTES,ebx
WRITE_BYTE1:
		pop		ebx
		ret


WRITE_WORD:
		push	ebx
		mov		ebx,PRG_ADR
		add		ebx,hCmdMem
		inc		PRG_ADR
		inc		PRG_ADR
		mov		word ptr [ebx],ax
		mov		ebx,PRG_ADR
		cmp		ebx,NO_OF_BYTES
		jb		WRITE_WORD1
		mov		NO_OF_BYTES,ebx
WRITE_WORD1:
		pop		ebx
		ret

PASS2_SET_OP_CODE:
		push	eax
		push	ebx
		push	esi
		xor		ah,ah
		mov		ebx,offset OP_CODE
		mov		word ptr [ebx],0000H
		mov		word ptr 2[ebx],0000H
PASS2_SET_OP_CODE1:
		mov		al,[esi]
		mov		[ebx],al
		inc		esi
		inc		ebx
		inc		ah
PASS2_SET_OP_CODE2:
		mov		al,[esi]
		inc		esi
		or		al,al
		jz		PASS2_SET_OP_CODE9
		cmp		al,10H
		jz		PASS2_SET_OP_CODE8
		cmp		al,01H
		jz		PASS2_SET_OP_CODE1
		cmp		al,08H				;IMM 8 DATA
		jz		PASS2_SET_OP_CODE7
		cmp		al,09H				;IMM 16 DATA
		jz		PASS2_SET_OP_CODE6
		jmp		PASS2_SET_OP_CODE2
PASS2_SET_OP_CODE6:
		inc		esi
PASS2_SET_OP_CODE7:
		inc		esi
		jmp		PASS2_SET_OP_CODE2
PASS2_SET_OP_CODE8:
		mov		al,[esi]
		inc		esi
		or		al,al
		jnz		PASS2_SET_OP_CODE8
		jmp		PASS2_SET_OP_CODE2
PASS2_SET_OP_CODE9:
		mov		NO_OF_OPS,ah
		pop		esi
		pop		ebx
		pop		eax
		ret

PASS2_FIND_OP_CODE:
		push	ebx
		push	ECX
		push	edx
		push	eax
		mov		CX,word ptr OP_CODE
		mov		dx,word ptr OP_CODE+2
PASS2_FIND_OP_CODE10:
		cmp		ch,0F0H
		jnb		PASS2_FIND_OP_CODE11
		cmp		ch,0D0H
		jb		PASS2_FIND_OP_CODE11
		mov		ch,81H
PASS2_FIND_OP_CODE11:
		cmp		dl,0F0H
		jnb		PASS2_FIND_OP_CODE12
		cmp		dl,0D0H
		jb		PASS2_FIND_OP_CODE12
		mov		dl,81H
PASS2_FIND_OP_CODE12:
		cmp		dh,0F0H
		jnb		PASS2_FIND_OP_CODE13
		cmp		dh,0D0H
		jb		PASS2_FIND_OP_CODE13
		mov		dh,81H
PASS2_FIND_OP_CODE13:
		mov		ebx,offset ADRMODE-5
		xor		al,al
PASS2_FIND_OP_CODE1:
		add		ebx,5
		cmp		CX,[ebx]
		jnz		PASS2_FIND_OP_CODE2
		cmp		dx,2[ebx]
		jz		PASS2_FIND_OP_CODE3
PASS2_FIND_OP_CODE2:
		inc		al
		jnz		PASS2_FIND_OP_CODE1
		stc
PASS2_FIND_OP_CODE3:
		mov		ah,4[ebx]
		mov		REL_MODE,ah
		pop		edx
		mov		ah,dh
		pop		edx
		pop		ECX
		pop		ebx
		ret

PASS2_OP_CODE:
		call	PASS2_SET_OP_CODE
		mov		al,[esi]
		inc		esi
		cmp		al,0F1H				;db
		jnz		PASS2_OP_CODE1
		call	PASS2_DB
		ret
PASS2_OP_CODE1:
		cmp		al,0F2H				;DW
		jnz		PASS2_OP_CODE2
		call	PASS2_DW
		ret
PASS2_OP_CODE2:
		cmp		al,0F3H				;ORG
		jnz		PASS2_OP_CODE3
		call	PASS2_ORG
		ret
PASS2_OP_CODE3:
		call	PASS2_FIND_OP_CODE
		jb		PASS2_OP_CODE6
		mov		byte ptr CODE,al
		call	WRITE_BYTE
		cmp		al,85H				;mov	 dad,dad
		jnz		PASS2_OP_CODE30
		push	eax
		mov		ax,word ptr PRG_ADR
		mov		word ptr SWAP_PRG_ADR,ax
		pop		eax
PASS2_OP_CODE30:
		dec		byte ptr NO_OF_OPS
		jz		PASS2_OP_CODE5
PASS2_OP_CODE31:
		mov		al,[esi]
		cmp		al,01H
		jnz		PASS2_OP_CODE5
		inc		esi
		mov		al,[esi]
		inc		esi
PASS2_OP_CODE4:
		call	PASS2_IMM_DATA
		dec		byte ptr NO_OF_OPS
		jz		PASS2_OP_CODE5
		mov		al,[esi]
		inc		esi
		cmp		al,','
		jz		PASS2_OP_CODE31
		dec		esi
PASS2_OP_CODE5:
		ret
PASS2_OP_CODE6:
		call	A_ERROR
		db		'PASS2 ILLEGAL ADRESSING MODE : ',00H

PASS2_IMM_DATA:
		cmp		al,80H			;#
		jz		PASS2_IMM_DATA1
		cmp		al,81H			;$
		jz		PASS2_IMM_DATA1
		cmp		al,08DH			;/$
		jz		PASS2_IMM_DATA1
		cmp		al,0D0H
		jnb		PASS2_IMM_DATA6
		ret
PASS2_IMM_DATA1:
		mov		al,[esi]
		cmp		al,08H
		jnz		PASS2_IMM_DATA2
		mov		cl,0AH
		call	PASS2_GET_HEX
		call	WRITE_BYTE
		ret
PASS2_IMM_DATA2:
		cmp		al,09H
		jnz		PASS2_IMM_DATA3
		call	PASS2_GET_HEX
		cmp		byte ptr CODE,90H
		jz		PASS2_IMM_DATA20
		cmp		byte ptr CODE,02H
		jz		PASS2_IMM_DATA20
		cmp		byte ptr CODE,12H
		jnz		PASS2_IMM_DATA21
PASS2_IMM_DATA20:
		xchg	al,ah
PASS2_IMM_DATA21:
		call	WRITE_BYTE
		mov		al,ah
		call	WRITE_BYTE
		ret
PASS2_IMM_DATA3:
		cmp		al,10H
		jnz		PASS2_IMM_DATA9
		inc		esi
		mov		al,byte ptr CODE
		cmp		al,02H				;LJMP
		jz		PASS2_IMM_DATA4
		cmp		al,12H				;LCALL
		jz		PASS2_IMM_DATA4
		cmp		al,90H				;mov	 DPTR,#dw
		jz		PASS2_IMM_DATA4
		and		al,0FH
		cmp		al,01H				;AJMP/ACALL
		jz		PASS2_IMM_DATA5
		mov		cl,0AH				;DIRCT MODE
		TEST	byte ptr REL_MODE,01H
		jz		PASS2_IMM_DATA30
		cmp		byte ptr NO_OF_OPS,01H
		jnz		PASS2_IMM_DATA30
		mov		cl,09H				;REL MODE
PASS2_IMM_DATA30:
		call	PASS2_LABEL
		ret
PASS2_IMM_DATA4:
		mov		cl,0BH				;DIRECT 16 BIT
		call	PASS2_LABEL
		mov		al,00H
		call	WRITE_BYTE
		ret
PASS2_IMM_DATA5:
		mov		cl,0CH				;DIRECT 12 BIT
		call	PASS2_LABEL
		ret
PASS2_IMM_DATA6:
		cmp		al,0F0H
		jnb		PASS2_IMM_DATA8
		mov		ebx,offset SFR_MEM
		sub		al,0D0H
		xor		ah,ah
		movzx	eax,ax
		add		ebx,eax
		mov		al,[ebx]
		mov		ah,[esi]
		cmp		ah,'.'
		jnz		PASS2_IMM_DATA62
		mov		ah,al
		and		ah,0F8H
		cmp		al,ah
		jnz		PASS2_IMM_DATA10
		inc		esi
		mov		ah,[esi]
		inc		esi
		and		ah,07H
		add		al,ah
PASS2_IMM_DATA62:
		call	WRITE_BYTE
PASS2_IMM_DATA8:
		ret
PASS2_IMM_DATA9:
		call	A_ERROR
		db		'PASS2 EXPECTED IMMEDIATE DATA OR LABEL : ',00H
PASS2_IMM_DATA10:
		call	A_ERROR
		db		'PASS2 DATA NOT BIT ADRESSABLE : ',00H

PASS2_LABEL:
		mov		ebx,PRG_ADR
		mov		edi,ASK_LBL_ADR
		call	PASS2_PUT_LABEL
		mov		ASK_LBL_ADR,edi
		mov		al,[esi]
		cmp		al,'+'
		jnz		PASS2_LABELA
		inc		esi
		call	PASS2_GET_HEX
		jmp		WRITE_BYTE
PASS2_LABELA:
		cmp		al,'-'
		jnz		PASS2_LABELB
		inc		esi
		call	PASS2_GET_HEX
		xor		ax,0FFFFH
		inc		ax
		jmp		WRITE_BYTE
PASS2_LABELB:
		xor		ax,ax
		jmp		WRITE_BYTE

PASS2_GET_HEX:
		mov		al,[esi]
		cmp		al,08H
		jnz		PASS2_GET_HEX1
		inc		esi
		mov		al,[esi]
		inc		esi
		xor		ah,ah
		ret
PASS2_GET_HEX1:
		cmp		al,09H
		jnz		PASS2_GET_HEX_ERR
		inc		esi
		mov		ax,[esi]
		inc		esi
		inc		esi
		ret
PASS2_GET_HEX_ERR:
		call	A_ERROR
		db		'EXPECTED HEX : ',00H


;01,DEF ADR WORD,PROG/DATA_LABEL_NAME,00
;02,DEF EQU BYTE,BYTE_LABEL_NAME,00
;03,DEF EQU WORD,WORD_LABEL_NAME,00

;08,ASK WORD	,PRG ADRESS,LABEL,00H
;09,ASK RELATIVE,PRG ADRESS,LABEL,00H
;0A,ASK BYTE	,PRG ADRESS,LABEL,00H
;0B,ASK ADR WORD,PRG ADRESS,LABEL,00H
;0C,ASK 12 BIT	,PRG ADRESS,LABEL,00H

PASS2_DEF_LABEL:
		call	PASS2_DEF_LABEL_TEST
		push	esi
PASS2_DEF_LABEL1:
		mov		al,[esi]
		inc		esi
		or		al,al
		jnz		PASS2_DEF_LABEL1
		mov		ax,[esi]
		cmp		ax,0F001H			;EQU LABEL
		jz		PASS2_DEF_LABEL2
		cmp		ax,0FA01H			;BIT LABEL
		jz		PASS2_DEF_LABEL3
		pop		esi
		mov		cl,01H				;PRG/DATA ADR LABEL
		mov		ebx,PRG_ADR
		add		ebx,ORG_ADR
		mov		edi,DEF_LBL_ADR
		call	PASS2_PUT_LABEL
		mov		DEF_LBL_ADR,edi
		ret
PASS2_DEF_LABEL2:
		inc		esi
		inc		esi
		call	PASS2_EQU
		inc		cl					;BYTE=2, WORD=3
		mov		edi,esi
		pop		esi
		push	edi
		mov		edi,DEF_LBL_ADR
		call	PASS2_PUT_LABEL
		mov		DEF_LBL_ADR,edi
		pop		esi
		ret
PASS2_DEF_LABEL3:
		inc		esi
		inc		esi
		call	PASS2_EQU
		.if cl==1 && byte ptr [esi]=='.'
			movzx	eax,byte ptr [esi+1]
			and		eax,0Fh
			shl		ebx,3
			or		ebx,eax
			add		esi,2
		.endif
		inc		cl					;BYTE=2, WORD=3
		mov		edi,esi
		pop		esi
		push	edi
		mov		edi,DEF_LBL_ADR
		call	PASS2_PUT_LABEL
		mov		DEF_LBL_ADR,edi
		pop		esi
		ret

PASS2_DEF_LABEL_TEST:
		push	esi
		mov		edi,hDefMem
PASS2_DEF_LABEL_TEST1:
		mov		al,[edi]
		or		al,al
		jz		PASS2_DEF_LABEL_TEST5
		add		edi,0005H
		push	esi
PASS2_DEF_LABEL_TEST2:
		mov		al,[esi]
		cmp		al,[edi]
		jnz		PASS2_DEF_LABEL_TEST3
		inc		esi
		inc		edi
		or		al,al
		jnz		PASS2_DEF_LABEL_TEST2
		call	A_ERROR
		db		'DOUBLE DEFINED LABEL : ',00H
PASS2_DEF_LABEL_TEST3:
		pop		esi
PASS2_DEF_LABEL_TEST4:
		mov		al,[edi]
		inc		edi
		or		al,al
		jnz		PASS2_DEF_LABEL_TEST4
		jmp		PASS2_DEF_LABEL_TEST1
PASS2_DEF_LABEL_TEST5:
		pop		esi
		ret

PASS2_PUT_LABEL:
		mov		[edi],cl			;TYPE
		inc		edi
		mov		[edi],bx			;DATA
		inc		edi
		inc		edi
		mov		eax,LINE_NUMBER
		mov		ES:[edi],ax
		inc		edi
		inc		edi
PASS2_PUT_LABEL1:
		mov		al,[esi]
		mov		ES:[edi],al
		inc		esi
		inc		edi
		or		al,al
		jnz		PASS2_PUT_LABEL1
		mov		[edi],al
		ret

PASS2_EQU:
		xor		bx,bx
		mov		al,[esi]
		inc		esi
		cmp		al,08H
		jnz		PASS2_EQU1
		mov		bl,[esi]
		mov		cl,01H
		inc		esi
		clc
		ret
PASS2_EQU1:
		cmp		al,09H
		jnz		PASS2_EQU2
		mov		bx,[esi]
		inc		esi
		inc		esi
		mov		cl,02H
		clc
		ret
PASS2_EQU2:
		cmp		al,0AH
		jnz		PASS2_EQU4
		mov		cl,01H
		mov		bx,[esi]
		inc		esi
		or		bh,bh
		jz		PASS2_EQU3
		inc		cl
		inc		esi
		mov		al,[esi]
		or		al,al
		jnz		PASS2_EQU_ERR
PASS2_EQU3:
		inc		esi
		clc
		ret
PASS2_EQU4:
		cmp		al,01H
		jnz		PASS2_EQU_ERR
		.while byte ptr [esi]
			inc		esi
		.endw
		inc		esi
		.if byte ptr [esi]=='+' || byte ptr [esi]=='-'
			.while byte ptr [esi]
				inc		esi
			.endw
			inc		esi
		.endif
		clc
		ret
mov		eax,[esi]
PrintHex eax
mov		eax,[esi+4]
PrintHex eax
mov		eax,[esi+8]
PrintHex eax
mov		eax,[esi+12]
PrintHex eax

PASS2_EQU_ERR:
		call	A_ERROR
		db		'EQU ???',00H

PASS2_DB:
		mov		al,[esi]
		or		al,al
		jnz		PASS2_DB1
		ret
PASS2_DB1:
		cmp		al,','
		jnz		PASS2_DB2
		inc		esi
		jmp		PASS2_DB
PASS2_DB2:
		cmp		al,08H
		jnz		PASS2_DB3
		inc		esi
		mov		al,[esi]
		call	WRITE_BYTE
		inc		esi
		jmp		PASS2_DB
PASS2_DB3:
		cmp		al,0AH
		jnz		PASS2_DB_ERR
		inc		esi
PASS2_DB4:
		mov		al,[esi]
		inc		esi
		or		al,al
		jz		PASS2_DB
		call	WRITE_BYTE
		jmp		PASS2_DB4
PASS2_DB_ERR:
		call	A_ERROR
		db		'db ???',00H

PASS2_DW:
		mov		al,[esi]
		or		al,al
		jnz		PASS2_DW1
		ret
PASS2_DW1:
		cmp		al,','
		jnz		PASS2_DW2
		inc		esi
		jmp		PASS2_DW
PASS2_DW2:
		cmp		al,09H
		jnz		PASS2_DW_ERR
		inc		esi
		mov		ax,[esi]
		call	WRITE_WORD
		inc		esi
		inc		esi
		jmp		PASS2_DW
PASS2_DW_ERR:
		call	A_ERROR
		db		'DW ???',00H

PASS2_ORG:
		mov		al,[esi]
		cmp		al,09H
		jnz		PASS2_ORG_ERR
		inc		esi
		mov		ax,[esi]
		inc		esi
		inc		esi
		TEST	word ptr PRG_ADR,0FFFFH
		jnz		PASS2_ORG1
		mov		word ptr ORG_ADR,ax
		clc
		ret
PASS2_ORG1:
		sub		ax,word ptr ORG_ADR
		jb		PASS2_ORG_ERR1
		mov		CX,word ptr PRG_ADR
		sub		CX,ax
		jz		PASS2_ORG3
		jnb		PASS2_ORG_ERR2
PASS2_ORG2:
		mov		al,0FFH
		call	WRITE_BYTE
		inc		CX
		jnz		PASS2_ORG2
PASS2_ORG3:
		clc
		ret
PASS2_ORG_ERR:
		call	A_ERROR
		db		'ORG ???',00H
PASS2_ORG_ERR1:
		call	A_ERROR
		db		'NEW ORG LESS THAN FIRST ORG : ',00H
PASS2_ORG_ERR2:
		call	A_ERROR
		db		'ORG LESS THAN PROG ADRESS : ',00H

PASS2_PUT_LST:
		mov		ebx,LST_LIN_ADR
		mov		eax,PRG_ADR
		add		eax,ORG_ADR
		mov		word ptr [ebx],ax
		inc		ebx
		inc		ebx
		mov		LST_LIN_ADR,ebx
		ret


AsmLinePass2 proc uses ebx esi edi,lpLine:DWORD

	mov		esi,offset PASS1_LINE
	call	PASS2_PUT_LST
	.while byte ptr [esi]
		mov		al,[esi]
		inc		esi
		cmp		al,01H
		.if al==01h				;OP CODE
			call	PASS2_OP_CODE
			test	word ptr SWAP_PRG_ADR,0FFFFH
			.if !ZERO?
				call	SWAP_BYTES
				mov		word ptr SWAP_PRG_ADR,0000H
			.endif
		.elseif al==02h				;DEF LABEL
			call	PASS2_DEF_LABEL
		.else
			call	A_ERROR
			db		'PASS 2 SYNTAX ERROR : ',00H
		.endif
	.endw
	ret

AsmLinePass2 endp

;PASS 3 ******************************************************

;01,			,DEF ADR WORD,PROG/DATA_LABEL_NAME,00
;02,			,DEF EQU BYTE,BYTE_LABEL_NAME,00
;03,			,DEF EQU WORD,WORD_LABEL_NAME,00
;08,ASK WORD	,PRG ADRESS,00H
;09,ASK RELATIVE,PRG ADRESS,00H
;0A,ASK BYTE	,PRG ADRESS,00H
;0B,ASK ADR WORD,PRG ADRESS,00H
;0C,ASK 12 BIT	,PRG ADRESS,LABEL,00H

AsmPass3 proc uses ebx esi edi

	mov		esi,hAskMem			;ASK START
	.while byte ptr [esi]
		movzx	eax,word ptr 3[esi]
		mov		LINE_NO,eax
		push	esi
		call	A_PASS3_FIND
		pop		esi
		jb		A_PASS3_ERR
		mov		cl,[esi]
		mov		ch,[edi]
		movzx	ebx,word ptr 01H[esi]
		movzx	edx,word ptr 01H[edi]
		cmp		cl,08H
		jnz		A_PASS3B
		add		ebx,hCmdMem
		add		dx,word ptr [ebx]
		xchg	dl,dh
		mov		word ptr [ebx],dx
		jmp		A_PASS3H
	A_PASS3B:
		cmp		cl,09H
		jnz		A_PASS3D
		sub		edx,ORG_ADR
		inc		ebx
		sub		edx,ebx
		dec		ebx
		add		ebx,hCmdMem
		add		byte ptr [ebx],dl
		mov		dl,byte ptr [ebx]
		adc		dh,00H
		or		dh,dh
		jnz		A_PASS3C
		cmp		dl,80H
		jb		A_PASS3H
		jmp		A_PASS3_ERRB
	A_PASS3C:
		cmp		dl,80H
		jnb		A_PASS3H
		jmp		A_PASS3_ERRB
	A_PASS3D:
		cmp		cl,0AH
		jnz		A_PASS3E
		add		ebx,hCmdMem
		add		byte ptr [ebx],dl
		jmp		A_PASS3H
	A_PASS3E:
		cmp		cl,0BH
		jnz		A_PASS3F
		add		ebx,hCmdMem
		add		dx,word ptr [ebx]
		xchg	dl,dh
		mov		word ptr [ebx],dx
		jmp		A_PASS3H
	A_PASS3F:
		cmp		cl,0CH
		jnz		A_PASS3G
		add		ebx,hCmdMem
		add		byte ptr [ebx],dl
		adc		dh,00H
		push	edx
		and		dh,07H
		shl		dh,1
		shl		dh,1
		shl		dh,1
		shl		dh,1
		shl		dh,1
		dec		ebx
		add		byte ptr [ebx],dh
		inc		ebx
		inc		ebx
		pop		edx
		sub		ebx,hCmdMem
		add		ebx,ORG_ADR
		and		dh,0F8H
		and		bh,0F8H
		cmp		dh,bh
		jz		A_PASS3H
		jmp		A_PASS3_ERRC
	A_PASS3G:
		add		ebx,hCmdMem
		add		byte ptr [ebx],dh
	A_PASS3H:
		add		esi,0005H
	A_PASS3I:
		mov		al,[esi]
		inc		esi
		or		al,al
		jnz		A_PASS3I
	.endw
	ret

A_ERROR2:
	call PrintStringz
	mov		eax,1
	jmp		Exit

A_PASS3_FIND:
	add		esi,0005H
	mov		edi,hDefMem				;DEF START
A_PASS3_FIND1:
	push	esi
	mov		al,[edi]
	or		al,al
	jz		A_PASS3_FIND4			;NOT FOND
	mov		ebx,edi
	add		edi,0005H
A_PASS3_FIND2:
	mov		al,[esi]
	cmp		al,[edi]
	jnz		A_PASS3_FIND3
	inc		esi
	inc		edi
	or		al,al
	jnz		A_PASS3_FIND2
	mov		edi,ebx
	pop		esi
	clc
	retn
A_PASS3_FIND3:
	mov		al,[edi]
	inc		edi
	or		al,al
	jnz		A_PASS3_FIND3
	pop		esi
	jmp		A_PASS3_FIND1
A_PASS3_FIND4:
	pop		esi
	stc
	retn

A_PASS3_ERR:
	invoke PrintLineNumber,LINE_NO
	add		esi,0005H
	invoke PrintStringz,esi
	call	A_ERROR2
	db		0Dh,0Ah,'LABEL NOT FOUND.',00H
A_PASS3_ERRB:
	invoke PrintLineNumber,LINE_NO
	call	A_ERROR2
	db		'RELATIVE JUMP OUT OF RANGE.',00H
A_PASS3_ERRC:
	invoke PrintLineNumber,LINE_NO
	call	A_ERROR2
	db		'AJMP/ACALL OUT OF RANGE.',00H

AsmPass3 endp

;LST FILE ****************************************************

ListLine proc lpLst:DWORD

	xor		cl,cl
	movzx	eax,word ptr [edi]
	inc		edi
	inc		edi
	movzx	edx,word ptr [edi]
	sub		edx,eax
	.if !ZERO?
		call	LST_HEX_ADR
	  @@:
		push	ebx
;		sub		ebx,ORG_ADR
		add		ebx,hCmdMem
		mov		al,byte ptr [ebx]
		pop		ebx
		inc		ebx
		call	LST_HEX_AL
		mov		al,20H
		call	WRITE_LST_BYTE
		dec		edx
		.if !ZERO?
			cmp		cl,0DH
			jb		@b
			add		ebx,edx
		.endif
	.endif
	mov		ch,16
	.while cl<ch
		mov		al,20H
		call	WRITE_LST_BYTE
	.endw
  @@:
	mov		ax,[esi]
	inc		esi
	call	WRITE_LST_BYTE
	cmp		ah,1AH				;EOF
	jz		@f
	cmp		ah,00H				;EOF
	jz		@f
	cmp		al,0AH
	jnz		@b
	clc
	ret
  @@:
	stc
	ret

WRITE_LST_BYTE:
	push	ebx
	mov		ebx,lpLst
	mov		byte ptr [ebx],al
	mov		byte ptr [ebx+1],0
	inc		lpLst
	inc		cl
	pop		ebx
	retn

LST_HEX_AL:
	push	eax
	rcr		al,1
	rcr		al,1
	rcr		al,1
	rcr		al,1
	call	LST_HEX_AL1
	pop		eax
LST_HEX_AL1:
	and		al,0FH
	add		al,30H
	cmp		al,3AH
	jb		LST_HEX_AL2
	add		al,07H
LST_HEX_AL2:
	call	WRITE_LST_BYTE
	retn

LST_HEX_ADR:
	push	eax
	mov		al,ah
	call	LST_HEX_AL
	pop		eax
	call	LST_HEX_AL
	mov		al,20H
	call	WRITE_LST_BYTE
	call	WRITE_LST_BYTE
	retn

ListLine endp

AsmListFile proc uses ebx esi edi
	LOCAL	buffer[512]:BYTE
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	mov		ecx,offset InpFile
	lea		edx,buffer
	.while byte ptr [ecx] && byte ptr [ecx]!='.'
		mov		al,[ecx]
		mov		[edx],al
		inc		ecx
		inc		edx
	.endw
	mov		dword ptr [edx],'tsl.'
	mov		byte ptr [edx+4],0
	invoke CreateFile,addr buffer,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	mov		hFile,eax
	xor		ebx,ebx				;CMD FILE
	mov		esi,hAsmMem			;TXT FILE
	mov		edi,hLinMem			;PRG ADR POINTERS
	.while !CARRY?
		mov		buffer,0
		invoke ListLine,addr buffer
		pushfd
		invoke lstrlen,addr buffer
		mov		edx,eax
		invoke WriteFile,hFile,addr buffer,edx,addr nBytes,NULL
		popfd
	.endw
	invoke CloseHandle,hFile
	ret

AsmListFile endp

;*************************************************************

AsmHexFile proc
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	mov		ecx,offset InpFile
	lea		edx,buffer
	.while byte ptr [ecx] && byte ptr [ecx]!='.'
		mov		al,[ecx]
		mov		[edx],al
		inc		ecx
		inc		edx
	.endw
	mov		dword ptr [edx],'xeh.'
	mov		byte ptr [edx+4],0
	invoke CreateFile,addr buffer,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	mov		hFile,eax
	xor		ebx,ebx
	mov		PRG_ADR,ebx
	.while ebx<NO_OF_BYTES
		lea		edi,buffer
		call	A_HEXLINE
		call	WriteLine
	.endw
;	lea		edi,buffer
;	mov		al,':'
;	call	WRITE_HEX_BYTE
;	xor		al,al
;	call	HEX_HEX_AL
;	xor		al,al
;	call	HEX_HEX_AL
;	xor		al,al
;	call	HEX_HEX_AL
;	mov		al,01H
;	call	HEX_HEX_AL
;	mov		al,0FFH
;	call	HEX_HEX_AL
;	mov		al,0DH
;	call	WRITE_HEX_BYTE
;	mov		al,0AH
;	call	WRITE_HEX_BYTE
;	call	WriteLine
	invoke CloseHandle,hFile
	ret

WriteLine:
	mov		byte ptr [edi],0
	invoke lstrlen,addr buffer
	mov		edx,eax
	invoke WriteFile,hFile,addr buffer,edx,addr nBytes,NULL
	retn

A_HEXLINE:
;		MOV		AL,':'
;		CALL	WRITE_HEX_BYTE
		XOR		CH,CH
		MOV		EAX,NO_OF_BYTES
		SUB		EAX,EBX
		CMP		EAX,10H
		JB		A_HEXLINE00
		MOV		AL,10H
A_HEXLINE00:
		ADD		CH,AL
;		CALL	HEX_HEX_AL
		MOV		AL,BH
		ADD		CH,AL
;		CALL	HEX_HEX_AL
		MOV		AL,BL
		ADD		CH,AL
;		CALL	HEX_HEX_AL
		XOR		AL,AL
		ADD		CH,AL
;		CALL	HEX_HEX_AL
		XOR		CL,CL
A_HEXLINE0:
		CMP		EBX,NO_OF_BYTES
		JZ		A_HEXLINE1
		mov		edx,hCmdMem
		MOV		AL,[EBX+EDX]
		INC		EBX
		ADD		CH,AL
		CALL	HEX_HEX_AL
	mov		al,20h
	mov		[edi],al
	inc		edi
		CMP		CL,2*16
		JNZ		A_HEXLINE0
A_HEXLINE1:
		CMP		CL,00H
		JZ		A_HEXLINE2
;		MOV		AL,CH
;		XOR		AL,0FFH
;		INC		AL
;		CALL	HEX_HEX_AL
		MOV		AL,0DH
		CALL	WRITE_HEX_BYTE
		MOV		AL,0AH
		CALL	WRITE_HEX_BYTE
A_HEXLINE2:
		RETN

HEX_HEX_AL:
	push	eax
	rcr		al,1
	rcr		al,1
	rcr		al,1
	rcr		al,1
	call	HEX_HEX_AL1
	pop		eax
HEX_HEX_AL1:
	and		al,0FH
	add		al,30H
	cmp		al,3AH
	jb		HEX_HEX_AL2
	add		al,07H
HEX_HEX_AL2:
	call	WRITE_HEX_BYTE
	retn

WRITE_HEX_BYTE:
	mov		[edi],al
	inc		edi
	inc		cl
	retn

AsmHexFile endp

;AsmHexFile proc
;	LOCAL	buffer[MAX_PATH]:BYTE
;	LOCAL	hFile:DWORD
;	LOCAL	nBytes:DWORD
;
;	mov		ecx,offset InpFile
;	lea		edx,buffer
;	.while byte ptr [ecx] && byte ptr [ecx]!='.'
;		mov		al,[ecx]
;		mov		[edx],al
;		inc		ecx
;		inc		edx
;	.endw
;	mov		dword ptr [edx],'xeh.'
;	mov		byte ptr [edx+4],0
;	invoke CreateFile,addr buffer,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
;	mov		hFile,eax
;	xor		ebx,ebx
;	mov		PRG_ADR,ebx
;	.while ebx<NO_OF_BYTES
;		lea		edi,buffer
;		call	A_HEXLINE
;		call	WriteLine
;	.endw
;	lea		edi,buffer
;	mov		al,':'
;	call	WRITE_HEX_BYTE
;	xor		al,al
;	call	HEX_HEX_AL
;	xor		al,al
;	call	HEX_HEX_AL
;	xor		al,al
;	call	HEX_HEX_AL
;	mov		al,01H
;	call	HEX_HEX_AL
;	mov		al,0FFH
;	call	HEX_HEX_AL
;	mov		al,0DH
;	call	WRITE_HEX_BYTE
;	mov		al,0AH
;	call	WRITE_HEX_BYTE
;	call	WriteLine
;	invoke CloseHandle,hFile
;	ret
;
;WriteLine:
;	mov		byte ptr [edi],0
;	invoke lstrlen,addr buffer
;	mov		edx,eax
;	invoke WriteFile,hFile,addr buffer,edx,addr nBytes,NULL
;	retn
;
;A_HEXLINE:
;		MOV		AL,':'
;		CALL	WRITE_HEX_BYTE
;		XOR		CH,CH
;		MOV		EAX,NO_OF_BYTES
;		SUB		EAX,EBX
;		CMP		EAX,10H
;		JB		A_HEXLINE00
;		MOV		AL,10H
;A_HEXLINE00:
;		ADD		CH,AL
;		CALL	HEX_HEX_AL
;		MOV		AL,BH
;		ADD		CH,AL
;		CALL	HEX_HEX_AL
;		MOV		AL,BL
;		ADD		CH,AL
;		CALL	HEX_HEX_AL
;		XOR		AL,AL
;		ADD		CH,AL
;		CALL	HEX_HEX_AL
;		XOR		CL,CL
;A_HEXLINE0:
;		CMP		EBX,NO_OF_BYTES
;		JZ		A_HEXLINE1
;		mov		edx,hCmdMem
;		MOV		AL,[EBX+EDX]
;		INC		EBX
;		ADD		CH,AL
;		CALL	HEX_HEX_AL
;		CMP		CL,2*16
;		JNZ		A_HEXLINE0
;A_HEXLINE1:
;		CMP		CL,00H
;		JZ		A_HEXLINE2
;		MOV		AL,CH
;		XOR		AL,0FFH
;		INC		AL
;		CALL	HEX_HEX_AL
;		MOV		AL,0DH
;		CALL	WRITE_HEX_BYTE
;		MOV		AL,0AH
;		CALL	WRITE_HEX_BYTE
;A_HEXLINE2:
;		RETN
;
;HEX_HEX_AL:
;	push	eax
;	rcr		al,1
;	rcr		al,1
;	rcr		al,1
;	rcr		al,1
;	call	HEX_HEX_AL1
;	pop		eax
;HEX_HEX_AL1:
;	and		al,0FH
;	add		al,30H
;	cmp		al,3AH
;	jb		HEX_HEX_AL2
;	add		al,07H
;HEX_HEX_AL2:
;	call	WRITE_HEX_BYTE
;	retn
;
;WRITE_HEX_BYTE:
;	mov		[edi],al
;	inc		edi
;	inc		cl
;	retn
;
;AsmHexFile endp
;
SaveCmdFile proc
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	mov		ecx,offset InpFile
	lea		edx,buffer
	.while byte ptr [ecx] && byte ptr [ecx]!='.'
		mov		al,[ecx]
		mov		[edx],al
		inc		ecx
		inc		edx
	.endw
	mov		dword ptr [edx],'dmc.'
	mov		byte ptr [edx+4],0
	invoke CreateFile,addr buffer,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	mov		hFile,eax
	invoke WriteFile,hFile,hCmdMem,NO_OF_BYTES,addr nBytes,NULL
	invoke CloseHandle,hFile
	ret

SaveCmdFile endp

start:

	invoke GetStdHandle,STD_OUTPUT_HANDLE
	mov		hOut,eax
	invoke GetModuleHandle,NULL
	mov		hInstance,eax
	invoke GetCommandLine
	mov		CommandLine,eax
	;Get command line filename
	invoke PathGetArgs,CommandLine
	mov		CommandLine,eax
	mov		dl,[eax]
	.if dl!=0
		.if dl==34
			invoke PathUnquoteSpaces,eax
		.endif
	.endif
	mov		eax,CommandLine
	invoke lstrcpy,offset InpFile,eax
	invoke PrintStringz,offset szTitle
	invoke ReadAsmFile,offset InpFile
	.if eax
		mov		hAsmMem,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*64
		mov		hCmdMem,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*128
		mov		hDefMem,eax
		mov		DEF_LBL_ADR,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*128
		mov		hAskMem,eax
		mov		ASK_LBL_ADR,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*128
		mov		hLinMem,eax
		mov		LST_LIN_ADR,eax
		mov		eax,hAsmMem
		.while !CARRY?
			invoke AsmLinePass0,eax
			pushfd
			push	eax
			invoke AsmLinePass1,eax
			invoke AsmLinePass2,eax
			pop		eax
			popfd
		.endw
		call	PASS2_PUT_LST
		invoke AsmPass3
		invoke SaveCmdFile
		invoke AsmListFile
		invoke AsmHexFile
	.endif
	xor		eax,eax
Exit:
	.if hAsmMem
		push	eax
		invoke GlobalFree,hAsmMem
		invoke GlobalFree,hCmdMem
		invoke GlobalFree,hDefMem
		invoke GlobalFree,hAskMem
		invoke GlobalFree,hLinMem
		pop		eax
	.endif
;	mov		ecx,80000000h
;  @@:
;	dec		ecx
;	jnz		@b
	invoke ExitProcess,eax

end start
