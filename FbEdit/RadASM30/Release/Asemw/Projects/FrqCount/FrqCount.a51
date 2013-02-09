
LCDLINE		EQU	40h				;16 Bytes

		ORG	0000h

START:		MOV	P2,#0FFh
		MOV	SP,#0CFh			;Init stack pointer. The stack is 48 bytes
		CLR	A
		MOV	IE,A				;Disable all interrupts
		ACALL	WAITASEC
		ACALL	LCDINIT
		CLR	A
		ACALL	LCDSETADR
		ACALL	LCDPRNTCSTR
		DB	'Welcome Ketil',0
		ACALL	WAITASEC
START1:		ACALL	LCDCLEARLINE
		ACALL	FRQCOUNT
		CPL	P3.0				;Toggle Output
		MOV	R0,#LCDLINE+4			;Decimal buffer
		ACALL	BIN2DEC
		MOV	R7,A				;Number of digits
		ACALL	FRQFORMAT
		CLR	A				;Output result
		ACALL	LCDSETADR
		MOV	R0,#LCDLINE
		MOV	R7,#10h
		ACALL	LCDPRINTSTR
		ACALL	LCDCLEARLINE
		MOV	LCDLINE+0,#'O'
		MOV	LCDLINE+1,#'u'
		MOV	LCDLINE+2,#'t'
		MOV	LCDLINE+3,#'='
		MOV	LCDLINE+4,#' '
		MOV	A,P3
		ANL	A,#01h
		ORL	A,#30h
		MOV	LCDLINE+5,A
		MOV	LCDLINE+8,#'I'
		MOV	LCDLINE+9,#'n'
		MOV	LCDLINE+10,#'='
		MOV	LCDLINE+11,#' '
		MOV	R0,#LCDLINE+15
		MOV	R7,#04h
		MOV	A,P0
START3:		PUSH	ACC
		ANL	A,#01h
		ORL	A,#30h
		MOV	@R0,A
		DEC	R0		
		POP	ACC
		RR	A
		DJNZ	R7,START3
		MOV	A,#40h				;Output result
		ACALL	LCDSETADR
		MOV	R0,#LCDLINE
		MOV	R7,#10h
		ACALL	LCDPRINTSTR
		SJMP	START1


;Binary to decimal converter
;Converts R7:R6:R5:R4 to decimal pointed to by R0
;Returns with number of digits in A
;------------------------------------------------------------------
BIN2DEC:	PUSH	00h
		MOV	DPTR,#BINDEC
		MOV	R2,#0Ah
BIN2DEC1:	MOV	R3,#2Fh
BIN2DEC2:	INC	R3
		ACALL	SUBIT
		JNC	BIN2DEC2
		ACALL	ADDIT
		MOV	A,R3
		MOV	@R0,A
		INC	R0
		INC	DPTR
		INC	DPTR
		INC	DPTR
		INC	DPTR
		DJNZ	R2,BIN2DEC1
		POP	00h
		;Remove leading zeroes
		MOV	R2,#09h
BIN2DEC3:	MOV	A,@R0
		CJNE	A,#30h,BIN2DEC4
		MOV	@R0,#20h
		INC	R0
		DJNZ	R2,BIN2DEC3
BIN2DEC4:	INC	R2
		MOV	A,R2
		RET

SUBIT:		CLR	A
		MOVC	A,@A+DPTR
		XCH	A,R4
		CLR	C
		SUBB	A,R4
		MOV	R4,A
		MOV	A,#01h
		MOVC	A,@A+DPTR
		XCH	A,R5
		SUBB	A,R5
		MOV	R5,A
		MOV	A,#02h
		MOVC	A,@A+DPTR
		XCH	A,R6
		SUBB	A,R6
		MOV	R6,A
		MOV	A,#03h
		MOVC	A,@A+DPTR
		XCH	A,R7
		SUBB	A,R7
		MOV	R7,A
		RET

ADDIT:		CLR	A
		MOVC	A,@A+DPTR
		ADD	A,R4
		MOV	R4,A
		MOV	A,#01h
		MOVC	A,@A+DPTR
		ADDC	A,R5
		MOV	R5,A
		MOV	A,#02h
		MOVC	A,@A+DPTR
		ADDC	A,R6
		MOV	R6,A
		MOV	A,#03h
		MOVC	A,@A+DPTR
		ADDC	A,R7
		MOV	R7,A
		RET

BINDEC:		DB 000h,0CAh,09Ah,03Bh			;1000000000
		DB 000h,0E1h,0F5h,005h			; 100000000
		DB 080h,096h,098h,000h			;  10000000
		DB 040h,042h,0Fh,0000h			;   1000000
		DB 0A0h,086h,001h,000h			;    100000
		DB 010h,027h,000h,000h			;     10000
		DB 0E8h,003h,000h,000h			;      1000
		DB 064h,000h,000h,000h			;       100
		DB 00Ah,000h,000h,000h			;        10
		DB 001h,000h,000h,000h			;         1

;------------------------------------------------------------------

;Wait loop. Waits 1 second
;-----------------------------------------------------
WAITASEC:	MOV	R7,#0F9h
		MOV	R6,#51
		MOV	R5,#16
WAITASEC1:	DJNZ	R7,WAITASEC1
		DJNZ	R6,WAITASEC1
		DJNZ	R5,WAITASEC1
		RET

;Frequency counter. LSB from 74LS393 read at 8001h, TL0, TH0, TF0 bit. 25 bits, max 33554431 Hz
;IN;	A holds channel (0 to 3). ACC.7 FRQ TTL Active high
;OUT:	32 Bit result in R7:R6:R5:R4
;------------------------------------------------------------------
FRQCOUNT:	CLR	P3.5				;DISABLE COUNT
		CLR	P3.7				;RESET 74F161
		SETB	P3.7
		SETB	P3.6				;RESET 74LS393
		CLR	P3.6
		MOV	TL0,#00h
		MOV	TH0,#00h
		MOV	A,TMOD
		SETB	ACC.0				;M00
		CLR	ACC.1				;M01
		SETB	ACC.2				;C/T0#
		CLR	ACC.3				;GATE0
		MOV	TMOD,A
		MOV	A,TCON
		SETB	ACC.4				;TR0
		CLR	ACC.5				;TF0
		MOV	TCON,A
		SETB	P3.5				;ENABLR COUNT
		ACALL	WAITASEC
		CLR	P3.5				;DISABLE COUNT
		MOV	A,P1				;4 BITS FROM 74F161 AND 4 BITS FROM 74LS393
		MOV	R4,A
		MOV	A,P3				;4 BITS FROM 74LS393
		RR	A
		ANL	A,#0Fh
		MOV	R5,A
		MOV	A,TL0
		SWAP	A
		ANL	A,#0F0h
		ORL	A,R5
		MOV	R5,A
		MOV	A,TL0
		SWAP	A
		ANL	A,#0Fh
		MOV	R6,A
		MOV	A,TH0
		SWAP	A
		ANL	A,#0F0h
		ORL	A,R6
		MOV	R6,A
		MOV	A,TH0
		SWAP	A
		ANL	A,#0Fh
		MOV	R7,A
		RET

;Format frequency conter text line
;	LCDLINE+4 Decimal result
;	R7 Number of digits
;OUT:	Formatted LCDLINE
FRQFORMAT:	MOV	LCDLINE+0,#'F'
		MOV	LCDLINE+1,#'='
		MOV	LCDLINE+2,#' '
		MOV	R0,#LCDLINE+3
		MOV	R1,#LCDLINE+5
		CJNE	R7,#07h,$+3
		JC	FRQFORMATKHZ
		;MHz
		MOV	R7,#09h
FRQFORMATMHZ1:	MOV	A,@R1
		CJNE	R7,#06h,FRQFORMATMHZ2
		MOV	@R0,#'.'
		INC	R0
FRQFORMATMHZ2:	MOV	@R0,A
		INC	R0
		INC	R1
		DJNZ	R7,FRQFORMATMHZ1
		MOV	LCDLINE+13,#'M'
		MOV	LCDLINE+14,#'H'
		MOV	LCDLINE+15,#'z'
		SJMP	FRQFORMATDONE
FRQFORMATKHZ:	CJNE	R7,#04h,$+3
		JC	FRQFORMATHZ
		;KHz
		MOV	R7,#09h
FRQFORMATKHZ1:	MOV	A,@R1
		CJNE	R7,#03h,FRQFORMATKHZ2
		MOV	@R0,#'.'
		INC	R0
FRQFORMATKHZ2:	MOV	@R0,A
		INC	R0
		INC	R1
		DJNZ	R7,FRQFORMATKHZ1
		MOV	LCDLINE+13,#'K'
		MOV	LCDLINE+14,#'H'
		MOV	LCDLINE+15,#'z'
		SJMP	FRQFORMATDONE
FRQFORMATHZ:	;Hz
		INC	R0
		MOV	R7,#09h
FRQFORMATHZ1:	MOV	A,@R1
		MOV	@R0,A
		INC	R0
		INC	R1
		DJNZ	R7,FRQFORMATHZ1
		MOV	LCDLINE+13,#'H'
		MOV	LCDLINE+14,#'z'
		MOV	LCDLINE+15,#' '
FRQFORMATDONE:	RET

;LCD Output.
;-----------------------------------------------------
LCDDELAY:	PUSH	07h
		MOV	R7,#00h
		DJNZ	R7,$
		POP	07h
		RET

;A contains nibble, ACC.4 contains RS
LCDNIBOUT:	SETB	ACC.5				;E
		MOV	P2,A
		CLR	P2.5				;Negative edge on E
		RET

;A contains byte
LCDCMDOUT:	PUSH	ACC
		SWAP	A				;High nibble first
		ANL	A,#0Fh
		ACALL	LCDNIBOUT
		POP	ACC
		ANL	A,#0Fh
		ACALL	LCDNIBOUT
		ACALL	LCDDELAY			;Wait for BF to clear
		RET

;A contains byte
LCDCHROUT:	PUSH	ACC
		SWAP	A				;High nibble first
		ANL	A,#0Fh
		SETB	ACC.4				;RS
		ACALL	LCDNIBOUT
		POP	ACC
		ANL	A,#0Fh
		SETB	ACC.4				;RS
		ACALL	LCDNIBOUT
		ACALL	LCDDELAY			;Wait for BF to clear
		RET

LCDCLEAR:	MOV	A,#00000001b
		ACALL	LCDCMDOUT
		MOV	R7,#00h
LCDCLEAR1:	ACALL	LCDDELAY
		DJNZ	R7,LCDCLEAR1
		RET

;A contais address
LCDSETADR:	ORL	A,#10000000b
		ACALL	LCDCMDOUT
		RET

LCDPRINTSTR:	MOV	A,@R0
		ACALL	LCDCHROUT
		INC	R0
		DJNZ	R7,LCDPRINTSTR
		RET

LCDPRNTCSTR:	POP	DPH
		POP	DPL
LCDPRNTCSTR1:	CLR	A
		MOVC	A,@A+DPTR
		INC	DPTR
		JZ	LCDPRNTCSTR2
		ACALL	LCDCHROUT
		SJMP	LCDPRNTCSTR1
LCDPRNTCSTR2:	PUSH	DPL
		PUSH	DPH
		RET

LCDINIT:	MOV	A,#00000011b			;Function set
		ACALL	LCDNIBOUT
		ACALL	LCDDELAY			;Wait for BF to clear
		MOV	A,#00101000b
		ACALL	LCDCMDOUT
		MOV	A,#00101000b
		ACALL	LCDCMDOUT
		MOV	A,#00001100b			;Display ON/OFF
		ACALL	LCDCMDOUT
		ACALL	LCDCLEAR			;Clear
		MOV	A,#00000110b			;Cursor direction
		ACALL	LCDCMDOUT
		RET

LCDCLEARLINE:	MOV	R0,#LCDLINE			;Get logic levels
		MOV	R7,#10h
		MOV	A,#20H
LCDCLEARLINE1:	MOV	@R0,A
		INC	R0
		DJNZ	R7,LCDCLEARLINE1
		RET

		END

