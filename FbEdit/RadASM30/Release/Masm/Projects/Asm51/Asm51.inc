include windows.inc
include kernel32.inc
include user32.inc
include shlwapi.inc

includelib kernel32.lib
includelib user32.lib
includelib shlwapi.lib

;#########################################################################
;VKim's Debug

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

DEFLBL struct
	tpe			dd ?
	txtptr		dd ?
	value		dd ?
	lineno		dd ?
DEFLBL ends

DEFINST struct
	opcode		db ?
	op			db 3 dup(?)
	rel			db ?
DEFINST ends

PASS1_OPCODE	equ 01h
PASS1_LABEL		equ 02h
PASS1_CONST		equ 03h
PASS1_NUMBER	equ 04h

OP_ORG			equ 0F0h
OP_EQU			equ 0F1h
OP_BIT			equ 0F2h
OP_DB			equ 0F3h
OP_DW			equ 0F4h
OP_@B			equ 0F5h
OP_@F			equ 0F6h

.const

;szTestFile		db 'C:\RadASM30\Asm8051\Projects\Verify\Verify.a51',0
szTestFile		db 'Test.a51',0

Op_codes		db	01h,'ACALL',00h
				db	02h,'ADD',00h
				db	03h,'ADDC',00h
				db	04h,'AJMP',00h
				db	05h,'ANL',00h
				db	06h,'CJNE',00h
				db	07h,'CLR',00h
				db	08h,'CPL',00h
				db	09h,'DA',00h
				db	0Ah,'DEC',00h
				db	0Bh,'DIV',00h
				db	0Ch,'DJNZ',00h
				db	0Dh,'INC',00h
				db	0Eh,'JB',00h
				db	0Fh,'JBC',00h
				db	10h,'JC',00h
				db	11h,'JMP',00h
				db	12h,'JNB',00h
				db	13h,'JNC',00h
				db	14h,'JNZ',00h
				db	15h,'JZ',00h
				db	16h,'LCALL',00h
				db	17h,'LJMP',00h
				db	18h,'MOV',00h
				db	19h,'MOVC',00h
				db	1Ah,'MOVX',00h
				db	1Bh,'MUL',00h
				db	1Ch,'NOP',00h
				db	1Dh,'ORL',00h
				db	1Eh,'POP',00h
				db	1Fh,'PUSH',00h
				db	20h,'RET',00h
				db	21h,'RETI',00h
				db	22h,'RL',00h
				db	23h,'RLC',00h
				db	24h,'RR',00h
				db	25h,'RRC',00h
				db	26h,'SETB',00h
				db	27h,'SJMP',00h
				db	28h,'SUBB',00h
				db	29h,'SWAP',00h
				db	2Ah,'XCH',00h
				db	2Bh,'XCHD',00h
				db	2Ch,'XRL',00h

				db	80h,'#',00h
				db	81h,'$',00h
				db	82h,'@A',00h
				db	83h,'@R0',00h
				db	84h,'@R1',00h
				db	85h,'A',00h
				db	86h,'AB',00h

				db	88h,'C',00h
				db	89h,'DPTR',00h
				db	8Ah,'@A+DPTR',00h
				db	8Bh,'@A+PC',00h
				db	8Ch,'@DPTR',00h
				db	8Dh,'/$',00h
				db	8Eh,'R0',00h
				db	8Fh,'R1',00h
				db	90h,'R2',00h
				db	91h,'R3',00h
				db	92h,'R4',00h
				db	93h,'R5',00h
				db	94h,'R6',00h
				db	95h,'R7',00h

				db	0D0h,'B',00h				;F0
				db	0D1h,'DPH',00h				;83
				db	0D2h,'DPL',00h				;82
				db	0D3h,'IE',00h				;A8
				db	0D4h,'IP',00h				;B8
				db	0D5h,'P0',00h				;80
				db	0D6h,'P1',00h				;90
				db	0D7h,'P2',00h				;A0
				db	0D8h,'P3',00h				;B0
				db	0D9h,'PCON',00h				;87
				db	0DAh,'PSW',00h				;D0
				db	0DBh,'SCON',00h				;98
				db	0DCh,'SBUF',00h				;99
				db	0DDh,'SP',00h				;81
				db	0DEh,'TCON',00h				;88
				db	0DFh,'TH0',00h				;8C
				db	0E0h,'TH1',00h				;8D
				db	0E1h,'TL0',00h				;8A
				db	0E2h,'TL1',00h				;8B
				db	0E3h,'TMOD',00h				;89
				db	0E4h,'ACC',00h				;E0

				db	OP_ORG,'ORG',00h
				db	OP_EQU,'EQU',00h
				db	OP_BIT,'BIT',00h
				db	OP_DB,'DB',00h
				db	OP_DW,'DW',00h
				db	OP_@B,'@B',00h
				db	OP_@F,'@F',00h
				db	00h,00h,00h,00h,00h

Sfr_mem			db	0F0h						;B
				db	083h						;DPH
				db	082h						;DPL
				db	0A8h						;IE
				db	0B8h						;IP
				db	080h						;P0
				db	090h						;P1
				db	0A0h						;P2
				db	0B0h						;P3
				db	087h						;PCON
				db	0D0h						;PSW
				db	098h						;SCON
				db	099h						;SBUF
				db	081h						;SP
				db	088h						;TCON
				db	08Ch						;TH0
				db	08Dh						;TH1
				db	08Ah						;TL0
				db	08Bh						;TL1
				db	089h						;TMOD
				db	0E0h						;ACC

;*************************************************************

				;	OP,ADR,ADR,ADR,REL
				;00-0F

Adrmode			db	01Ch,000h,000h,000h,000h	;00 NOP
				db	004h,081h,000h,000h,000h	;01 AJMP	$cad
				db	017h,081h,000h,000h,000h	;02 LJMP	$cad
				db	024h,085h,000h,000h,000h	;03 RR		A
				db	00Dh,085h,000h,000h,000h	;04 INC		A
				db	00Dh,081h,000h,000h,000h	;05 INC		$dad
				db	00Dh,083h,000h,000h,000h	;06 INC		@R0
				db	00Dh,084h,000h,000h,000h	;07 INC		@R1
				db	00Dh,08Eh,000h,000h,000h	;08 INC		R0
				db	00Dh,08Fh,000h,000h,000h	;09 INC		R1
				db	00Dh,090h,000h,000h,000h	;0A INC		R2
				db	00Dh,091h,000h,000h,000h	;0B INC		R3
				db	00Dh,092h,000h,000h,000h	;0C INC		R4
				db	00Dh,093h,000h,000h,000h	;0D INC		R5
				db	00Dh,094h,000h,000h,000h	;0E INC		R6
				db	00Dh,095h,000h,000h,000h	;0F INC		R7

				;10-1F

				db	00Fh,081h,081h,000h,001h	;10 JBC		$bad,$cad
				db	001h,081h,000h,000h,000h	;11 ACALL	$cad
				db	016h,081h,000h,000h,000h	;12 LCALL	$cad
				db	025h,085h,000h,000h,000h	;13 RRC		A
				db	00Ah,085h,000h,000h,000h	;14 DEC		A
				db	00Ah,081h,000h,000h,000h	;15 DEC		$dad
				db	00Ah,083h,000h,000h,000h	;16 DEC		@R0
				db	00Ah,084h,000h,000h,000h	;17 DEC		@R1
				db	00Ah,08Eh,000h,000h,000h	;18 DEC		R0
				db	00Ah,08Fh,000h,000h,000h	;19 DEC		R1
				db	00Ah,090h,000h,000h,000h	;1A DEC		R2
				db	00Ah,091h,000h,000h,000h	;1B DEC		R3
				db	00Ah,092h,000h,000h,000h	;1C DEC		R4
				db	00Ah,093h,000h,000h,000h	;1D DEC		R5
				db	00Ah,094h,000h,000h,000h	;1E DEC		R6
				db	00Ah,095h,000h,000h,000h	;1F DEC		R7

				;20-2F

				db	00Eh,081h,081h,000h,001h	;20 JB		$bad,$cad
				db	004h,081h,000h,000h,000h	;21 AJMP	$cad
				db	020h,000h,000h,000h,000h	;22 RET
				db	022h,085h,000h,000h,000h	;23 RL		A
				db	002h,085h,080h,000h,000h	;24 ADD		A,#dd
				db	002h,085h,081h,000h,000h	;25 ADD		A,$dad
				db	002h,085h,083h,000h,000h	;26 ADD		A,@R0
				db	002h,085h,084h,000h,000h	;27 ADD		A,@R1
				db	002h,085h,08Eh,000h,000h	;28 ADD		A,R0
				db	002h,085h,08Fh,000h,000h	;29 ADD		A,R1
				db	002h,085h,090h,000h,000h	;2A ADD		A,R2
				db	002h,085h,091h,000h,000h	;2B ADD		A,R3
				db	002h,085h,092h,000h,000h	;2C ADD		A,R4
				db	002h,085h,093h,000h,000h	;2D ADD		A,R5
				db	002h,085h,094h,000h,000h	;2E ADD		A,R6
				db	002h,085h,095h,000h,000h	;2F ADD		A,R7

				;30-3F

				db	012h,081h,081h,000h,001h	;30 JNB		$bad,$cad
				db	001h,081h,000h,000h,000h	;31 ACALL	$cad
				db	021h,000h,000h,000h,000h	;32 RETI
				db	023h,085h,000h,000h,000h	;33 RLC		A
				db	003h,085h,080h,000h,000h	;34 ADDC	A,#dd
				db	003h,085h,081h,000h,000h	;35 ADDC	A,$dad
				db	003h,085h,083h,000h,000h	;36 ADDC	A,@R0
				db	003h,085h,084h,000h,000h	;37 ADDC	A,@R1
				db	003h,085h,08Eh,000h,000h	;38 ADDC	A,R0
				db	003h,085h,08Fh,000h,000h	;39 ADDC	A,R1
				db	003h,085h,090h,000h,000h	;3A ADDC	A,R2
				db	003h,085h,091h,000h,000h	;3B ADDC	A,R3
				db	003h,085h,092h,000h,000h	;3C ADDC	A,R4
				db	003h,085h,093h,000h,000h	;3D ADDC	A,R5
				db	003h,085h,094h,000h,000h	;3E ADDC	A,R6
				db	003h,085h,095h,000h,000h	;3F ADDC	A,R7

				;40-4F

				db	010h,081h,000h,000h,001h	;40 JC		$cad
				db	004h,081h,000h,000h,000h	;41 AJMP	$cad
				db	01Dh,081h,085h,000h,000h	;42 ORL		$dad,A
				db	01Dh,081h,080h,000h,000h	;43 ORL		$dad,#dd
				db	01Dh,085h,080h,000h,000h	;44 ORL		A,#dd
				db	01Dh,085h,081h,000h,000h	;45 ORL		A,$dad
				db	01Dh,085h,083h,000h,000h	;46 ORL		A,@R0
				db	01Dh,085h,084h,000h,000h	;47 ORL		A,@R1
				db	01Dh,085h,08Eh,000h,000h	;48 ORL		A,R0
				db	01Dh,085h,08Fh,000h,000h	;49 ORL		A,R1
				db	01Dh,085h,090h,000h,000h	;4A ORL		A,R2
				db	01Dh,085h,091h,000h,000h	;4B ORL		A,R3
				db	01Dh,085h,092h,000h,000h	;4C ORL		A,R4
				db	01Dh,085h,093h,000h,000h	;4D ORL		A,R5
				db	01Dh,085h,094h,000h,000h	;4E ORL		A,R6
				db	01Dh,085h,095h,000h,000h	;4F ORL		A,R7

				;50-5F

				db	013h,081h,000h,000h,001h	;50 JNC		$cad
				db	001h,081h,000h,000h,000h	;51 ACALL	$cad
				db	005h,081h,085h,000h,000h	;52 ANL		$dad,A
				db	005h,081h,080h,000h,000h	;53 ANL		$dad,#dd
				db	005h,085h,080h,000h,000h	;54 ANL		A,#dd
				db	005h,085h,081h,000h,000h	;55 ANL		A,$dad
				db	005h,085h,083h,000h,000h	;56 ANL		A,@R0
				db	005h,085h,084h,000h,000h	;57 ANL		A,@R1
				db	005h,085h,08Eh,000h,000h	;58 ANL		A,R0
				db	005h,085h,08Fh,000h,000h	;59 ANL		A,R1
				db	005h,085h,090h,000h,000h	;5A ANL		A,R2
				db	005h,085h,091h,000h,000h	;5B ANL		A,R3
				db	005h,085h,092h,000h,000h	;5C ANL		A,R4
				db	005h,085h,093h,000h,000h	;5D ANL		A,R5
				db	005h,085h,094h,000h,000h	;5E ANL		A,R6
				db	005h,085h,095h,000h,000h	;5F ANL		A,R7

				;60-6F

				db	015h,081h,000h,000h,001h	;60 JZ		$cad
				db	004h,081h,000h,000h,000h	;61 AJMP	$cad
				db	02Ch,081h,085h,000h,000h	;62 XRL		$dad,A
				db	02Ch,081h,080h,000h,000h	;63 XRL		$dad,#dd
				db	02Ch,085h,080h,000h,000h	;64 XRL		A,#dd
				db	02Ch,085h,081h,000h,000h	;65 XRL		A,$dad
				db	02Ch,085h,083h,000h,000h	;66 XRL		A,@R0
				db	02Ch,085h,084h,000h,000h	;67 XRL		A,@R1
				db	02Ch,085h,08Eh,000h,000h	;68 XRL		A,R0
				db	02Ch,085h,08Fh,000h,000h	;69 XRL		A,R1
				db	02Ch,085h,090h,000h,000h	;6A XRL		A,R2
				db	02Ch,085h,091h,000h,000h	;6B XRL		A,R3
				db	02Ch,085h,092h,000h,000h	;6C XRL		A,R4
				db	02Ch,085h,093h,000h,000h	;6D XRL		A,R5
				db	02Ch,085h,094h,000h,000h	;6E XRL		A,R6
				db	02Ch,085h,095h,000h,000h	;6F XRL		A,R7

				;70-7F

				db	014h,081h,000h,000h,001h	;70 JNZ		$cad
				db	001h,081h,000h,000h,000h	;71 ACALL	$cad
				db	01Dh,088h,081h,000h,000h	;72 ORL		C,$bad
				db	011h,08Ah,000h,000h,000h	;73 JMP		@A+DPTR
				db	018h,085h,080h,000h,000h	;74 MOV		A,#dd
				db	018h,081h,080h,000h,000h	;75 MOV		$dad,#dd
				db	018h,083h,080h,000h,000h	;76 MOV		@R0,#dd
				db	018h,084h,080h,000h,000h	;77 MOV		@R1,#dd
				db	018h,08Eh,080h,000h,000h	;78 MOV		R0,#dd
				db	018h,08Fh,080h,000h,000h	;79 MOV		R1,#dd
				db	018h,090h,080h,000h,000h	;7A MOV		R2,#dd
				db	018h,091h,080h,000h,000h	;7B MOV		R3,#dd
				db	018h,092h,080h,000h,000h	;7C MOV		R4,#dd
				db	018h,093h,080h,000h,000h	;7D MOV		R5,#dd
				db	018h,094h,080h,000h,000h	;7E MOV		R6,#dd
				db	018h,095h,080h,000h,000h	;7F MOV		R7,#dd

				;80-8F

				db	027h,081h,000h,000h,001h	;80 SJMP	$cad
				db	004h,081h,000h,000h,000h	;81 AJMP	$cad
				db	005h,088h,081h,000h,000h	;82 ANL		C,$bad
				db	019h,085h,08Bh,000h,000h	;83 MOVC	A,@A+PC
				db	00Bh,086h,000h,000h,000h	;84 DIV		AB
				db	018h,081h,081h,000h,000h	;85 MOV		$dad,$dad
				db	018h,081h,083h,000h,000h	;86 MOV		$dad,@R0
				db	018h,081h,084h,000h,000h	;87 MOV		$dad,@R1
				db	018h,081h,08Eh,000h,000h	;88 MOV		$dad,R0
				db	018h,081h,08Fh,000h,000h	;89 MOV		$dad,R1
				db	018h,081h,090h,000h,000h	;8A MOV		$dad,R2
				db	018h,081h,091h,000h,000h	;8B MOV		$dad,R3
				db	018h,081h,092h,000h,000h	;8C MOV		$dad,R4
				db	018h,081h,093h,000h,000h	;8D MOV		$dad,R5
				db	018h,081h,094h,000h,000h	;8E MOV		$dad,R6
				db	018h,081h,095h,000h,000h	;8F MOV		$dad,R7

				;90-9F

				db	018h,089h,080h,000h,000h	;90 MOV		DPTR,#dw
				db	001h,081h,000h,000h,000h	;91 ACALL	$cad
				db	018h,081h,088h,000h,000h	;92 MOV		$bad,C
				db	019h,085h,08Ah,000h,000h	;93 MOVC	A,@A+DPTR
				db	028h,085h,080h,000h,000h	;94 SUBB	A,#dd
				db	028h,085h,081h,000h,000h	;95 SUBB	A,$dad
				db	028h,085h,083h,000h,000h	;96 SUBB	A,@R0
				db	028h,085h,084h,000h,000h	;97 SUBB	A,@R1
				db	028h,085h,08Eh,000h,000h	;98 SUBB	A,R0
				db	028h,085h,08Fh,000h,000h	;99 SUBB	A,R1
				db	028h,085h,090h,000h,000h	;9A SUBB	A,R2
				db	028h,085h,091h,000h,000h	;9B SUBB	A,R3
				db	028h,085h,092h,000h,000h	;9C SUBB	A,R4
				db	028h,085h,093h,000h,000h	;9D SUBB	A,R5
				db	028h,085h,094h,000h,000h	;9E SUBB	A,R6
				db	028h,085h,095h,000h,000h	;9F SUBB	A,R7

				;A0-AF

				db	01Dh,088h,08Dh,000h,000h	;A0 ORL		C,/$bad
				db	004h,081h,000h,000h,000h	;A1 AJMP	$cad
				db	018h,088h,081h,000h,000h	;A2 MOV		C,$bad
				db	00Dh,089h,000h,000h,000h	;A3 INC		DPTR
				db	01Bh,086h,000h,000h,000h	;A4 MUL		AB
				db	000h,000h,000h,000h,000h	;A5 reserved
				db	018h,083h,081h,000h,000h	;A6 MOV		@R0,$dad
				db	018h,084h,081h,000h,000h	;A7 MOV		@R1,$dad
				db	018h,08Eh,081h,000h,000h	;A8 MOV		R0,$dad
				db	018h,08Fh,081h,000h,000h	;A9 MOV		R1,$dad
				db	018h,090h,081h,000h,000h	;AA MOV		R2,$dad
				db	018h,091h,081h,000h,000h	;AB MOV		R3,$dad
				db	018h,092h,081h,000h,000h	;AC MOV		R4,$dad
				db	018h,093h,081h,000h,000h	;AD MOV		R5,$dad
				db	018h,094h,081h,000h,000h	;AE MOV		R6,$dad
				db	018h,095h,081h,000h,000h	;AF MOV		R7,$dad

				;B0-BF

				db	005h,088h,08Dh,000h,000h	;B0 ANL		C,/$bad
				db	001h,081h,000h,000h,000h	;B1 ACALL	$cad
				db	008h,081h,000h,000h,000h	;B2 CPL		$bad
				db	008h,088h,000h,000h,000h	;B3 CPL		C
				db	006h,085h,080h,081h,001h	;B4 CJNE	A,#dd,$cad
				db	006h,085h,081h,081h,001h	;B5 CJNE	A,$dad,$cad
				db	006h,083h,080h,081h,001h	;B6 CJNE	@R0,#dd,$cad
				db	006h,084h,080h,081h,001h	;B7 CJNE	@R1,#dd,$cad
				db	006h,08Eh,080h,081h,001h	;B8 CJNE	R0,#dd,$cad
				db	006h,08Fh,080h,081h,001h	;B9 CJNE	R1,#dd,$cad
				db	006h,090h,080h,081h,001h	;BA CJNE	R2,#dd,$cad
				db	006h,091h,080h,081h,001h	;BB CJNE	R3,#dd,$cad
				db	006h,092h,080h,081h,001h	;BC CJNE	R4,#dd,$cad
				db	006h,093h,080h,081h,001h	;BD CJNE	R5,#dd,$cad
				db	006h,094h,080h,081h,001h	;BE CJNE	R6,#dd,$cad
				db	006h,095h,080h,081h,001h	;BF CJNE	R7,#dd,$cad

				;C0-CF

				db	01Fh,081h,000h,000h,000h	;C0 PUSH	$dad
				db	004h,081h,000h,000h,000h	;C1 AJMP	$cad
				db	007h,081h,000h,000h,000h	;C2 CLR		$bad
				db	007h,088h,000h,000h,000h	;C3 CLR 	C
				db	029h,085h,000h,000h,000h	;C4 SWAP	A
				db	02Ah,085h,081h,000h,000h	;C5 XCH 	A,$dad
				db	02Ah,085h,083h,000h,000h	;C6 XCH 	A,@R0
				db	02Ah,085h,084h,000h,000h	;C7 XCH 	A,@R1
				db	02Ah,085h,08Eh,000h,000h	;C8 XCH 	A,R0
				db	02Ah,085h,08Fh,000h,000h	;C9 XCH 	A,R1
				db	02Ah,085h,090h,000h,000h	;CA XCH 	A,R2
				db	02Ah,085h,091h,000h,000h	;CB XCH 	A,R3
				db	02Ah,085h,092h,000h,000h	;CC XCH 	A,R4
				db	02Ah,085h,093h,000h,000h	;CD XCH 	A,R5
				db	02Ah,085h,094h,000h,000h	;CE XCH 	A,R6
				db	02Ah,085h,095h,000h,000h	;CF XCH 	A,R7

				;D0-DF

				db	01Eh,081h,000h,000h,000h	;D0 POP		$TEST
				db	001h,081h,000h,000h,000h	;D1 ACALL	$START
				db	026h,081h,000h,000h,000h	;D2 SETB	$TEST
				db	026h,088h,000h,000h,000h	;D3 SETB	C
				db	009h,085h,000h,000h,000h	;D4 DA		A
				db	00Ch,081h,081h,000h,001h	;D5 DJNZ	$TEST,$START
				db	02Bh,085h,083h,000h,000h	;D6 XCHD	A,@R0
				db	02Bh,085h,084h,000h,000h	;D7 XCHD	A,@R1
				db	00Ch,08Eh,081h,000h,001h	;D8 DJNZ	R0,$START
				db	00Ch,08Fh,081h,000h,001h	;D9 DJNZ	R1,$START
				db	00Ch,090h,081h,000h,001h	;DA DJNZ	R2,$START
				db	00Ch,091h,081h,000h,001h	;db DJNZ	R3,$START
				db	00Ch,092h,081h,000h,001h	;DC DJNZ	R4,$START
				db	00Ch,093h,081h,000h,001h	;DD DJNZ	R5,$START
				db	00Ch,094h,081h,000h,001h	;DE DJNZ	R6,$START
				db	00Ch,095h,081h,000h,001h	;DF DJNZ	R7,$START

				;E0-EF

				db	01Ah,085h,08Ch,000h,000h	;E0 MOVX	A,@DPTR
				db	004h,081h,000h,000h,000h	;E1 AJMP	$cad
				db	01Ah,085h,083h,000h,000h	;E2 MOVX	A,@R0
				db	01Ah,085h,084h,000h,000h	;E3 MOVX	A,@R1
				db	007h,085h,000h,000h,000h	;E4 CLR 	A
				db	018h,085h,081h,000h,000h	;E5 MOV		A,$dad
				db	018h,085h,083h,000h,000h	;E6 MOV		A,@R0
				db	018h,085h,084h,000h,000h	;E7 MOV		A,@R1
				db	018h,085h,08Eh,000h,000h	;E8 MOV		A,R0
				db	018h,085h,08Fh,000h,000h	;E9 MOV		A,R1
				db	018h,085h,090h,000h,000h	;EA MOV		A,R2
				db	018h,085h,091h,000h,000h	;EB MOV		A,R3
				db	018h,085h,092h,000h,000h	;EC MOV		A,R4
				db	018h,085h,093h,000h,000h	;ED MOV		A,R5
				db	018h,085h,094h,000h,000h	;EE MOV		A,R6
				db	018h,085h,095h,000h,000h	;EF MOV		A,R7

				;F0-FF

				db	01Ah,08Ch,085h,000h,000h	;F0 MOVX	@DPTR,A
				db	001h,081h,000h,000h,000h	;F1 ACALL	$cad
				db	01Ah,083h,085h,000h,000h	;F2 MOVX	@R0,A
				db	01Ah,084h,085h,000h,000h	;F3 MOVX	@R1,A
				db	008h,085h,000h,000h,000h	;F4 CPL 	A
				db	018h,081h,085h,000h,000h	;F5 MOV		$dad,A
				db	018h,083h,085h,000h,000h	;F6 MOV		@R0,A
				db	018h,084h,085h,000h,000h	;F7 MOV		@R1,A
				db	018h,08Eh,085h,000h,000h	;F8 MOV		R0,A
				db	018h,08Fh,085h,000h,000h	;F9 MOV		R1,A
				db	018h,090h,085h,000h,000h	;FA MOV		R2,A
				db	018h,091h,085h,000h,000h	;FB MOV		R3,A
				db	018h,092h,085h,000h,000h	;FC MOV		R4,A
				db	018h,093h,085h,000h,000h	;FD MOV		R5,A
				db	018h,094h,085h,000h,000h	;FE MOV		R6,A
				db	018h,095h,085h,000h,000h	;FF MOV		R7,A

szTitle			db '8051 Assembler',0Dh,0Ah,0Ah,0
szError			db ': error ',0
fmttmplbl		db '@@%0.4d',0

.data?

hInstance		dd ?
CommandLine		dd ?
hOut			dd ?
InpFile			db MAX_PATH dup(?)

hAsmMem			dd ?
hCmdMem			dd ?
hDefMem			dd ?
hAskMem			dd ?
hNameMem		dd ?
hLinMem			dd ?
dwTemp			dd ?

Text_line		db 512 dup(?)
				db ?
Pass0_line		db 512 dup(?)
Pass1_line		db 512 dup(?)
Line_number		dd ?
;Line_no			dd ?

hexbuff			db 256 dup(?)

Prg_adr			dd ?
Cmd_adr			dd ?

Def_lbl_adr		dd ?
Ask_lbl_adr		dd ?
Name_adr		dd ?
Lst_lin_adr		dd ?

ntmplbl			dd ?
tmplbl			db 16 dup(?)
