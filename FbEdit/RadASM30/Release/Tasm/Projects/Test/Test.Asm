.486p
.MODEL FLAT,STDCALL
locals
jumps
UNICODE=0

include test.inc
comment *
ttt
*

.code

start:

	call	Create_Label,1,2,3,4,5,6
	call	ExitProcess,0

Create_Label PROC STDCALL	USES	ecx ebx esi edi, tst2:DWORD
	ARG 	@@tst:dword,@@token_start,@@token_size:dword
	LOCAL	@@tmp_id:dword
	LOCAL	@@tmp_id2:dword
	ARG		@@symbol_type,@@symbol_value:dword

	mov		eax,0

	call	MessageBoxA,NULL,offset szText,offset szText,0
	call	Module1,NULL
	ret

Create_Label ENDP

ends

end start
