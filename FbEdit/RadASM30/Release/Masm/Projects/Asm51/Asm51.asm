.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include asm51.inc
include Misc.asm

.code

HexLine proc uses eax ecx edx esi edi,lpLine:DWORD

	mov		esi,lpLine
	mov		edi,offset hexbuff
	mov		ecx,32
	.while ecx
		call	hexbyte
		mov		byte ptr [edi],20h
		inc		edi
		dec		ecx
	.endw
	mov		byte ptr [edi],0
	invoke MessageBox,NULL,addr hexbuff,addr szTitle,MB_OK
	ret

hexbyte:
	movzx	eax,byte ptr [esi]
	inc		esi
	push	eax
	shr		eax,4
	call	hexnib
	pop		eax
hexnib:
	and		eax,0Fh
	.if eax>9
		add		eax,41h-0Ah
	.else
		add		eax,30h
	.endif
	mov		[edi],al
	inc		edi
	retn

HexLine endp

;PASS 0 ******************************************************

;Preparse the line
AsmLinePass0 proc uses ebx esi edi,lpLine:DWORD

	inc		dword ptr Line_number
	mov		esi,lpLine
	mov		edi,offset Text_line
	mov		ebx,offset Pass0_line-1
	xor		cl,cl					;REMARK FLAG
	xor		ch,ch					;TEXT FLAG
  @@:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	.if al==0Dh
		;End of line, skip LF
		inc		esi
		mov		dword ptr [edi],00h
		inc		ebx
		mov		byte ptr [ebx],00h
		inc		ebx
		mov		byte ptr [ebx],0Dh
		mov		eax,esi
		clc
		ret
	.elseif al==00h
		;End of file
		inc		ebx
		mov		byte ptr [ebx],00h
		inc		ebx
		mov		byte ptr [ebx],0Dh
		mov		eax,esi
		stc
		ret
	.elseif cl						;REMARK FLAG
		;Skip all except CRLF or eof
		jmp		@b
	.elseif al==09h && ch==00h
		;Convert tab to space if not in string
		mov		al,' '
	.elseif al=="'"
		xor		ch,0FFh				;TEXT FLAG
	.endif
	.if ch==00h						;TEXT FLAG
		.if al==' '
			;Convert space to 00h, test for previous
			xor		al,al
			cmp		al,[ebx]
			jz		@b
		.elseif al==',' || al=='#' || al=='$' || al=='+' || al=='-'
			inc		ebx
			mov		byte ptr [ebx],0
			inc		ebx
			mov		byte ptr [ebx],al
			mov		al,00h
		.elseif al==';'
			mov		al,00h
			inc		cl				;REMARK FLAG
		.endif
	.endif
	inc		ebx
	mov		[ebx],al
	jmp		@b

AsmLinePass0 endp

;PASS 1 ******************************************************

;00 EOL
;01 OP CODE					MOV, EQU etc.
;02 LABEL					PROG_LABLE:
;03 CONSTANT NAME			MYCONST		EQU 2
;04 HEX or DEC NUMBER		04H or 123
;2B +
;2C ,
;2D -
;2E .

IsNumber proc uses esi,lpLine:DWORD

	mov		esi,lpLine
	.if byte ptr [esi]>='0' && byte ptr [esi]<='9'
		.while TRUE
			mov		ax,[esi]
			.if (al>='0' && al<='9') || (al>='A' && al<='F') || (al>='a' && al<='f') 
				inc		esi
			.elseif (al=='H' || al=='h' || !al) && (ah=='+' || ah=='-' || ah==',' || ah=='.' || ah==0Dh || !ah)
				clc
				ret
			.else
				.break
			.endif
		.endw
	.endif
	stc
	ret

IsNumber endp

GetDecimal proc uses ebx

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
	ret

GetDecimal endp

GetHex proc uses ebx

	xor		ebx,ebx
	.while TRUE
		mov		al,[esi]
		inc		esi
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		.break .if al=='H'
		sub		al,'0'
		cmp		al,0AH
		jb		@f
		sub		al,07H
	  @@:
		shl		ebx,4
		add		bl,al
	.endw
	mov		eax,ebx
	ret

GetHex endp

IsOpcode proc uses ebx,lpLine:DWORD

	mov		ebx,offset Op_codes
	.while byte ptr [ebx]
		invoke strcmpi,esi,addr [ebx+1]
		.if !eax
			;Found
			mov		eax,ebx
			clc
			ret
		.endif
		invoke strlen,addr [ebx+1]
		lea		ebx,[ebx+eax+2]
	.endw
	stc
	ret

IsOpcode endp

SkipZero proc

	.while !byte ptr [esi]
		inc		esi
	.endw
	mov		al,[esi]
	ret

SkipZero endp

AsmLinePass1 proc uses ebx esi edi

	mov		esi,offset Pass0_line
	mov		edi,offset Pass1_line
	.while TRUE
		invoke SkipZero
		mov		al,[esi]
		.if al=='-' || al=='+' || al==',' || al=='.'
			mov		[edi],al
			inc		esi
			inc		edi
		.elseif al=="'"
			mov		[edi],al
			inc		esi
			inc		edi
			.while TRUE
				mov		al,[esi]
				.if al=="'"
					mov		[edi],al
					inc		esi
					inc		edi
					mov		byte ptr [edi],0
					inc		edi
					.break
				.elseif al
					mov		[edi],al
					inc		esi
					inc		edi
				.else
					call Err
					db	'PASS 1 MISSING END QUOTE : ',0
				.endif
			.endw
		.elseif al==0Dh
			mov		dword ptr [edi],00h
			clc
			ret
		.else
			invoke IsNumber,esi
			.if !CARRY?
				.if !al
					;Decimal
					invoke GetDecimal
				.else
					;Hex
					invoke GetHex
				.endif
				mov		byte ptr [edi],PASS1_NUMBER
				inc		edi
				mov		[edi],ax
				inc		edi
				inc		edi
			.else
				invoke IsOpcode,esi
				.if !CARRY?
					;Op code
					.if byte ptr [eax]==0FBh
						;@b
						mov		byte ptr [edi],PASS1_LABEL
						inc		edi
						invoke wsprintf,addr tmplbl,addr fmttmplbl,ntmplbl
						invoke lstrcpy,edi,addr tmplbl
						lea		edi,[edi+7]
					.elseif byte ptr [eax]==0FCh
						;@f
						mov		byte ptr [edi],PASS1_LABEL
						inc		edi
						mov		eax,ntmplbl
						invoke wsprintf,addr tmplbl,addr fmttmplbl,addr [eax-1]
						invoke lstrcpy,edi,addr tmplbl
						lea		edi,[edi+7]
					.else
						mov		byte ptr [edi],PASS1_OPCODE
						inc		edi
						mov		al,[eax]
						mov		[edi],al
						inc		edi
					.endif
					invoke strlen,esi
					lea		esi,[esi+eax+1]
				.else
					mov		al,[esi]
					.if (al>='@' && al<='Z') || (al>='a' && al<='z')
						;Label
						invoke strlen,esi
						.if byte ptr [esi+eax-1]==':'
							;Label
							mov		byte ptr [edi],PASS1_LABEL
							inc		edi
							.if dword ptr [esi]==':@@'
								;Auto label
								invoke wsprintf,addr tmplbl,addr fmttmplbl,ntmplbl
								invoke lstrcpy,edi,addr tmplbl
								lea		esi,[esi+4]
								lea		edi,[edi+7]
								inc		ntmplbl
							.else
								;Program label
								invoke lstrcpyn,edi,esi,eax
								invoke strlen,esi
								lea		edi,[edi+eax]
								lea		esi,[esi+eax+1]
							.endif
						.else
							;Const name
							mov		byte ptr [edi],PASS1_CONST
							inc		edi
							invoke lstrcpy,edi,esi
							invoke strlen,esi
							lea		edi,[edi+eax+1]
							lea		esi,[esi+eax+1]
						.endif
					.else
						call Err
						db	'PASS 1 SYNTAX ERROR : ',0
					.endif
				.endif
			.endif
		.endif
	.endw
	mov		dword ptr [edi],0
	stc
	ret

AsmLinePass1 endp

;PASS 2 ******************************************************

AsmLinePass2 proc uses ebx esi edi
	LOCAL	deflbl:DEFLBL
	LOCAL	definst:DEFINST
	LOCAL	val:DWORD
	LOCAL	firstorg:DWORD

	mov		firstorg,0
	mov		esi,offset Pass1_line
  @@:
	movzx	eax,byte ptr [esi]
	inc		esi
	.if eax==PASS1_OPCODE
		movzx	eax,byte ptr [esi]
		inc		esi
		.if eax==OP_ORG
			;ORG
			call	GetEquValue
			.if !firstorg
				mov		firstorg,TRUE
				mov		Prg_adr,ebx
			.else
				mov		ecx,ebx
				sub		ecx,Prg_adr
				.if CARRY?
					call	Err
					db	'ORG LESS THAN PREVIOUS : ',0
				.endif
				;Fill with 0FFh
				mov		edi,Cmd_adr
				mov		eax,0FFh
				rep		stosb
				mov		Prg_adr,ebx
				mov		Cmd_adr,edi
			.endif
		.elseif eax==OP_DB
			;DB
			call	GetDBValue
		.elseif eax==OP_DW
			;DW
			call	GetDWValue
		.elseif eax>=01h && eax<=2Ch
			;Instruction
			call	GetInstruction
			call	FindInstruction
			mov		edx,Cmd_adr
			mov		[edx],bl
			inc		Cmd_adr
			inc		Prg_adr
			.if dword ptr [edi]==00808918h
				;MOV	DPTR,#1234
				mov		eax,val
				mov		[edx+1],ax
				add		Cmd_adr,2
				add		Prg_adr,2
			.elseif byte ptr [edi+1]==80h || byte ptr [edi+2]==80h || byte ptr [edi+3]==80h
				mov		eax,val
				.if sdword ptr eax>255 || sdword ptr eax<-128
					call	Err
					db	'IMMEDIATE VALUE ONLY ONE BYTE : ',0
				.endif
				mov		[edx+1],al
				inc		Cmd_adr
				inc		Prg_adr
			.endif
		.else
			call	Err
			db	'PASS 2 SYNTAX ERROR : ',0
		.endif
	.elseif eax==PASS1_LABEL
		mov		deflbl.tpe,eax
		mov		eax,Name_adr
		mov		deflbl.txtptr,eax
		mov		eax,Prg_adr
		mov		deflbl.value,eax
		mov		eax,Line_number
		mov		deflbl.lineno,eax
		invoke lstrcpy,Name_adr,esi
		invoke strlen,esi
		inc		eax
		add		Name_adr,eax
		lea		esi,[esi+eax]
		invoke RtlMoveMemory,Def_lbl_adr,addr deflbl,sizeof DEFLBL
		add		Def_lbl_adr,sizeof DEFLBL
		jmp		@b
	.elseif eax==PASS1_CONST
		mov		eax,Name_adr
		mov		deflbl.txtptr,eax
		mov		eax,Prg_adr
		mov		deflbl.value,eax
		mov		eax,Line_number
		mov		deflbl.lineno,eax
		invoke lstrcpy,Name_adr,esi
		invoke strlen,esi
		inc		eax
		add		Name_adr,eax
		lea		esi,[esi+eax]
		movzx	eax,byte ptr [esi]
		inc		esi
		.if eax==PASS1_OPCODE
			movzx	eax,byte ptr [esi]
			inc		esi
			.if eax==OP_EQU
				;EQU
				mov		deflbl.tpe,eax
				xor		ebx,ebx
				call	GetEquValue
				mov		deflbl.value,ebx
				call	CopyLabel
			.elseif eax==OP_BIT
				;BIT
				mov		deflbl.tpe,eax
				xor		ebx,ebx
				call	GetBitValue
				mov		deflbl.value,ebx
				call	CopyLabel
			.elseif eax==OP_DB
				;DB
				mov		deflbl.tpe,eax
				;Write byte data
				.while TRUE
					xor		ebx,ebx
					call	GetDBValue
					mov		edi,Cmd_adr
					mov		[edi],bl
					inc		Cmd_adr
					inc		Prg_adr
					.break .if !eax
					.if eax!=','
						call	Err
						db	'PASS 2 SYNTAX ERROR : ',0
					.endif
					inc		esi
				.endw
				call	CopyLabel
			.elseif eax==OP_DW
				;DW
				;Write word data
				.while TRUE
					xor		ebx,ebx
					call	GetDBValue
					mov		edi,Cmd_adr
					mov		[edi],bx
					inc		Cmd_adr
					inc		Cmd_adr
					inc		Prg_adr
					inc		Prg_adr
					.break .if !eax
					.if eax!=','
						call	Err
						db	'PASS 2 SYNTAX ERROR : ',0
					.endif
					inc		esi
				.endw
				mov		deflbl.tpe,eax
				call	CopyLabel
			.else
				call	Err
				db	'PASS 2 SYNTAX ERROR : ',0
			.endif
		.else
			call	Err
			db	'PASS 2 SYNTAX ERROR : ',0
		.endif
	.elseif eax
		call	Err
		db	'PASS 2 SYNTAX ERROR : ',0
	.endif
	ret

FindLabel:
	mov		edi,hDefMem
	.while [edi].DEFLBL.tpe
		invoke strcmp,esi,[edi].DEFLBL.txtptr
		.if !eax
			mov		eax,[edi].DEFLBL.value
			clc
			retn
		.endif
		lea		edi,[edi+sizeof DEFLBL]
	.endw
	stc
	retn

CopyLabel:
	invoke RtlMoveMemory,Def_lbl_adr,addr deflbl,sizeof DEFLBL
	add		Def_lbl_adr,sizeof DEFLBL
	retn

FindInstruction:
	mov		edi,offset Adrmode
	xor		ebx,ebx
	mov		eax,dword ptr definst
	.while TRUE
		.if eax==[edi]
			retn
		.endif
		inc		ebx
		.break .if !bl
		lea		edi,[edi+sizeof DEFINST]
	.endw
	call	Err
	db	'ILLEGAL INSTRUCTION OPERAND : ',0
	retn

GetInstruction:
	mov		definst.opcode,al
	mov		definst.op[0],0
	mov		definst.op[1],0
	mov		definst.op[2],0
	mov		definst.rel,0
	xor		ebx,ebx
	.while ebx<3
		movzx	eax,byte ptr [esi]
		inc		esi
		.if !eax
			dec		esi
			retn
		.elseif eax==','
			inc		ebx
		.elseif eax==PASS1_OPCODE
			movzx	eax,byte ptr [esi]
			inc		esi
			mov		definst.op[ebx],al
			.if eax==80h
				;#
				movzx	eax,byte ptr [esi]
				inc		esi
				.if eax==PASS1_NUMBER
					;Immediate number
					movsx	eax,word ptr [esi]
					mov		val,eax
					inc		esi
					inc		esi
				.elseif eax==PASS1_CONST
					;Immediate label
					call	FindLabel
					.if CARRY?
						call	Err
						db	'PASS 2 LABEL NOT FOUND : ',0
					.endif
					mov		val,eax
					invoke strlen,esi
					lea		esi,[esi+eax+1]
				.else
					call	Err
					db	'PASS 2 SYNTAX ERROR : ',0
				.endif
			.elseif eax==81h
				;$
				movzx	eax,byte ptr [esi]
				inc		esi
				.if eax==PASS1_NUMBER
					movsx	eax,word ptr [esi-1]
					mov		val,eax
					inc		esi
				.else
					call	Err
					db	'PASS 2 SYNTAX ERROR : ',0
				.endif
			.elseif eax>=82h && eax<=86h
			.elseif eax>=88h && eax<=95h
			.elseif eax>=0D0h && eax<=0E4h
			.elseif eax==OP_@F
			.elseif eax==OP_@B
			.else
				call	Err
				db	'PASS 2 SYNTAX ERROR : ',0
			.endif
		.elseif eax==PASS1_CONST
		.endif
	.endw
	call	Err
	db	'PASS 2 SYNTAX ERROR : ',0
	retn

GetEquValue:
	.while TRUE
		movzx	eax,byte ptr [esi]
		inc		esi
		.break .if !eax
		.if eax==PASS1_CONST
			call	FindLabel
			.if CARRY?
				call	Err
				db	'PASS 2 LABEL NOT FOUND : ',0
			.endif
			mov		ebx,eax
			invoke strlen,esi
			lea		esi,[esi+eax+1]
		.elseif eax==PASS1_NUMBER
			movzx	ebx,word ptr [esi]
			add		esi,2
		.elseif eax=='+'
			push	ebx
			xor		ebx,ebx
			call	GetEquValue
			mov		eax,ebx
			pop		ebx
			add		ebx,eax
		.elseif eax=='-'
			push	ebx
			xor		ebx,ebx
			call	GetEquValue
			mov		eax,ebx
			pop		ebx
			sub		ebx,eax
		.else
			call	Err
			db	'PASS 2 SYNTAX ERROR : ',0
		.endif
	.endw
	retn

GetBitValue:
	.while TRUE
		movzx	eax,byte ptr [esi]
		inc		esi
		.break .if !eax
		.if eax==PASS1_CONST
			call	FindLabel
			.if CARRY?
				call	Err
				db	'PASS 2 LABEL NOT FOUND : ',0
			.endif
			mov		ebx,eax
			invoke strlen,esi
			lea		esi,[esi+eax+1]
		.elseif eax==PASS1_NUMBER
			movzx	ebx,word ptr [esi]
			add		esi,2
		.elseif eax=='+'
			push	ebx
			xor		ebx,ebx
			call	GetBitValue
			mov		eax,ebx
			pop		ebx
			add		ebx,eax
		.elseif eax=='-'
			push	ebx
			xor		ebx,ebx
			call	GetBitValue
			mov		eax,ebx
			pop		ebx
			sub		ebx,eax
		.elseif eax=='.'
			.if ebx>=10h && ebx<=1Fh
				sub		ebx,10h
			.elseif ebx>=80h && ebx<=0FFh
				test	ebx,07h
				.if !ZERO?
					call	Err
					db	'NOT BITADRESSABLE : ',0
				.endif
				shr		ebx,3
			.else
				call	Err
				db	'NOT BITADRESSABLE : ',0
			.endif
			push	ebx
			xor		ebx,ebx
			call	GetBitValue
			mov		eax,ebx
			pop		ebx
			shl		ebx,3
			add		ebx,eax
		.else
			call	Err
			db	'PASS 2 SYNTAX ERROR : ',0
		.endif
	.endw
	retn

GetDBValue:
	.while TRUE
		movzx	eax,byte ptr [esi]
		.break .if eax==','
		inc		esi
		.break .if !eax
		.if eax==PASS1_CONST
			call	FindLabel
			.if CARRY?
				call	Err
				db	'PASS 2 LABEL NOT FOUND : ',0
			.endif
			mov		ebx,eax
			invoke strlen,esi
			lea		esi,[esi+eax+1]
		.elseif eax==PASS1_NUMBER
			movzx	ebx,word ptr [esi]
			add		esi,2
		.elseif eax=='+'
			push	ebx
			xor		ebx,ebx
			call	GetDBValue
			mov		eax,ebx
			pop		ebx
			add		ebx,eax
		.elseif eax=='-'
			push	ebx
			xor		ebx,ebx
			call	GetDBValue
			mov		eax,ebx
			pop		ebx
			sub		ebx,eax
		.elseif eax=="'"
			inc		esi
			.while byte ptr [esi+1]!="'"
				mov		al,[esi]
				mov		edi,Cmd_adr
				mov		[edi],al
				inc		Cmd_adr
				inc		Prg_adr
				inc		esi
			.endw
			movzx	ebx,byte ptr [esi]
			inc		esi
			inc		esi
			inc		esi
		.else
			call	Err
			db	'PASS 2 SYNTAX ERROR : ',0
		.endif
	.endw
	retn

GetDWValue:
	.while TRUE
		movzx	eax,byte ptr [esi]
		.break .if eax==','
		inc		esi
		.break .if !eax
		.if eax==PASS1_CONST
			call	FindLabel
			.if CARRY?
				call	Err
				db	'PASS 2 LABEL NOT FOUND : ',0
			.endif
			mov		ebx,eax
			invoke strlen,esi
			lea		esi,[esi+eax+1]
		.elseif eax==PASS1_NUMBER
			movzx	ebx,word ptr [esi]
			add		esi,2
		.elseif eax=='+'
			push	ebx
			xor		ebx,ebx
			call	GetDWValue
			mov		eax,ebx
			pop		ebx
			add		ebx,eax
		.elseif eax=='-'
			push	ebx
			xor		ebx,ebx
			call	GetDWValue
			mov		eax,ebx
			pop		ebx
			sub		ebx,eax
		.elseif eax=="'"
			inc		esi
			.while byte ptr [esi+1]!="'"
				movzx	eax,byte ptr [esi]
				mov		edi,Cmd_adr
				mov		[edi],ax
				inc		Cmd_adr
				inc		Cmd_adr
				inc		Prg_adr
				inc		Prg_adr
				inc		esi
			.endw
			movzx	ebx,byte ptr [esi]
			inc		esi
			inc		esi
			inc		esi
		.else
			call	Err
			db	'PASS 2 SYNTAX ERROR : ',0
		.endif
	.endw
	retn

AsmLinePass2 endp

;PASS 3 ******************************************************

;*************************************************************

Err:
	invoke PrintLineNumber,Line_number
	call PrintStringz
	mov		eax,offset Text_line
	.while byte ptr [eax] && (byte ptr [eax]==20h || byte ptr [eax]==09h)
		inc		eax
	.endw
	invoke PrintStringz,eax
	mov		eax,1
	jmp		Exit

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
	mov		ecx,Cmd_adr
	sub		ecx,hCmdMem
	invoke WriteFile,hFile,hCmdMem,ecx,addr nBytes,NULL
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

invoke lstrcpy,offset InpFile,offset szTestFile

	invoke ReadAsmFile,offset InpFile
	.if eax
		mov		hAsmMem,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*64
		mov		hCmdMem,eax
		mov		Cmd_adr,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*128
		mov		hDefMem,eax
		mov		Def_lbl_adr,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*128
		mov		hAskMem,eax
		mov		Ask_lbl_adr,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*128
		mov		hNameMem,eax
		mov		Name_adr,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*128
		mov		hLinMem,eax
		mov		Lst_lin_adr,eax
		mov		eax,hAsmMem
		.while !CARRY?
			invoke AsmLinePass0,eax
			pushfd
			push	eax
;invoke HexLine,addr Pass0_line
			invoke AsmLinePass1
;invoke HexLine,addr Pass1_line
;.break
			invoke AsmLinePass2
			pop		eax
			popfd
		.endw
;		call	PASS2_PUT_LST
;		invoke AsmPass3
		invoke SaveCmdFile
;		invoke AsmListFile
;		invoke AsmHexFile
	.endif
	xor		eax,eax
Exit:
	.if hAsmMem
		push	eax
		invoke GlobalFree,hAsmMem
		invoke GlobalFree,hCmdMem
		invoke GlobalFree,hDefMem
		invoke GlobalFree,hAskMem
		invoke GlobalFree,hNameMem
		invoke GlobalFree,hLinMem
		pop		eax
	.endif
	mov		ecx,2000000000
	.while ecx
		.while edx
			dec		edx
		.endw
		dec		ecx
	.endw
	mov		ecx,2000000000
	.while ecx
		.while edx
			dec		edx
		.endw
		dec		ecx
	.endw
	invoke ExitProcess,eax

end start
