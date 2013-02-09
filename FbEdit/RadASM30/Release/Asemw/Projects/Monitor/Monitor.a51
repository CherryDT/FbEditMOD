$NOPAGING
$PAGEWIDTH (250)         ;250 columns per line
$NOTABS                  ;expand tabs
$NOSYMBOLS
$NOPAGING

;ADC VREF=1.342 Volts

;-----------------------------------------------------
;*****************************************************
;RAM Locations
;-----------------------------------------------------
;20	Interrupt flags
;21	ARG_STACK	ARGUMENT STACK POINTER 
;22	FORMAT		LOCATION OF OUTPUT FORMAT BYTE 
;23.1	INTGRC		BIT SET IF INTEGER ERROR 
;23.3	ADD_IN		DCMPXZ IN BASIC BACKAGE 
;23.6	ZSURP		ZERO SUPRESSION FOR HEX PRINT 
;24	FPCHR_OUT	CHARACTER POSITION

;25-3A			Floaing point work area
;40-4F	LCDBUFF		LCD Buffer		

;D0-FF	Stack
;-----------------------------------------------------
;*****************************************************
;SCREEN DRIVER
;-----------------------------------------------------
;01	START SEND ROMDATA.HEX FILE
;02	STOP SEND FILE
;03	START RECIEVE ROMDATA.HEX FILE
;04	STOP RECIEVE FILE
;05	START RECIEVE FILE IN 16 BYTE BLOCKS
;06	STOP RECIEVE FILE IN 16 BYTE BLOCKS
;07	BELL, if from MCU then next 2 characters is the single step binary address
;08	BACK SPACE
;09	TAB
;0A	LF
;0B	LOCATE
;0C	HOME
;0D	CR
;0E	CLS
;0F	MODE
;10	START SEND CMDFILE.CMD FILE
;-----------------------------------------------------
;*****************************************************
;Memory mapped I/O
;-----------------------------------------------------
;8000h Output
;-----------------------------------------------------
;D0	LCD DB4
;D1	LCD DB5
;D2	LCD DB6
;D3	LCD DB7
;D4	LCD RS
;D5	LCD E
;D6
;D7
;-----------------------------------------------------
;8001h Output
;-----------------------------------------------------
;D0	FRQ SEL A | 00 FREQENCY COUNER 01 FUNCTION GEN 
;D1	FRQ SEL B | 10 L/C METER 11 ITERNAL ALE
;D2	FRQ GATE ACTIVE LOW
;D3	FRQ	RESET ACTIVE HIGH
;D4	ADC CS ACTIVE LOW
;D5	ADC CLK HIGH TO LOW TRANSITION
;D6	ADC DIN
;D7
;-----------------------------------------------------
;8000h Input
;-----------------------------------------------------
;D0	ADC DOUT
;D1
;D2
;D3
;D4
;D5
;D6
;D7
;-----------------------------------------------------
;8001h Input
;-----------------------------------------------------
;D0	FRQ LSB
;D1
;D2
;D3
;D4
;D5
;D6
;D7	FRQ MSB
;-----------------------------------------------------
;*****************************************************
;Equates
;-----------------------------------------------------
T2CON		EQU 0C8h
RCAP2L		EQU 0CAh
RCAP2H		EQU 0CBh
TL2		EQU 0CCh
TH2		EQU 0CDh
FPCHR_OUT	EQU 24h
LCDBUFF		EQU 40h
;-----------------------------------------------------
;*****************************************************

		ORG	2000H
		
		SJMP	START
		
		ORG	2013H
		LJMP	SINGLESTEP

		ORG	2040H

START:
		MOV	SP,#0CFh
		CLR	A
		MOV	DPL,A
		MOV	DPH,#ARG_STACK_PAGE
		MOV	R7,A
START0:		MOVX	@DPTR,A
		INC	DPTR
		DJNZ	R7,START0
SETB	P3.3
SETB	20h.2
SETB	20h.7
CLR	IT1						;Level triggered
SETB	EX1						;Enable external interrupt 1, INT1 #
SETB	EA

		MOV	ARG_STACK,#0C0h
		MOV	FORMAT,#00h
;		ACALL	LCDINIT
;		MOV	A,#41h
;		ACALL	LCDCHROUT
;		MOV	A,#42h
;		ACALL	LCDCHROUT
;		MOV	A,#43h
;		ACALL	LCDCHROUT
;		MOV	A,#44h
;		ACALL	LCDCHROUT
START1:		MOV	A,#03h
		ACALL	FRQCOUNT
		MOV	R0,#LCDBUFF
		LCALL	PRINTSTR
		MOV	A,#0Dh
		LCALL	TXBYTE
		MOV	A,#0Ah
		LCALL	TXBYTE

		MOV	LCDBUFF,#'I'
		MOV	LCDBUFF+1,#'N'
		MOV	LCDBUFF+2,#'T'
		MOV	LCDBUFF+3,#' '
;		MOV	LCDBUFF+4,#00h

		MOV	FPCHR_OUT,#LCDBUFF+4
		MOV	ARG_STACK,#0C0h
		MOV	A,#03h
		ACALL	ADCONVERT

CLR	P3.3

		MOV	FPCHR_OUT,#LCDBUFF+10
		MOV	ARG_STACK,#0C0h
		MOV	A,#03h
		ACALL	ADCONVERT

SETB	P3.3

		MOV	R0,#LCDBUFF
		LCALL	PRINTSTR
		MOV	A,#0Dh
		LCALL	TXBYTE
		MOV	A,#0Ah
		LCALL	TXBYTE
		JNB	SCON.0,START1
		LCALL	RXBYTE
		MOV	DPTR,#2000h

SETB	P3.3
CLR	20h.2
CLR	20h.7
CLR	EX1						;Enable external interrupt 1, INT1 #
CLR	EA
		LJMP	0000H

;AD Converter.
;IN:	A holds channel (0 to 7).
;-----------------------------------------------------
ADCONVERT:	PUSH	ACC
		SETB	ACC.4			;START
		SETB	ACC.3			;SINGLE ENDED
		RL	A
		RL	A
		RL	A
		MOV	R2,A
		CLR	ACC.0			;FRQ SEL
		CLR	ACC.1			;FRQ SEL
		SETB	ACC.2			;D2	FRQ GATE ACTIVE LOW
		SETB	ACC.3			;D3	FRQ	RESET ACTIVE HIGH
		SETB	ACC.4			;D4	ADC CS ACTIVE LOW
		SETB	ACC.5			;D5	ADC CLK HIGH TO LOW TRANSITION
		SETB	ACC.6			;D6	ADC DIN
		SETB	ACC.7	;D7
		MOV	DPTR,#8001h
		MOVX	@DPTR,A
		;CS low
		CLR	ACC.4	;D4		ADC CS ACTIVE LOW
		MOVX	@DPTR,A
		;Clock in channel select and Single/Diff+2 clocks for sample
		MOV	R7,#07h
ADCONVERT1:	XCH	A,R2
		RLC	A
		XCH	A,R2
		MOV	ACC.6,C	;ADC DIN
		CLR	ACC.5
		MOVX	@DPTR,A
		SETB	ACC.5
		MOVX	@DPTR,A
		DJNZ	R7,ADCONVERT1
		MOV	R2,#00h
		;Clock in 5 bits, including null bit
		MOV	R7,#05h
ADCONVERT2:	PUSH	ACC
		MOV	DPTR,#8000h
		MOVX	A,@DPTR
		RRC	A
		XCH	A,R2
		RLC	A
		XCH	A,R2
		MOV	DPTR,#8001h
		POP	ACC
		CLR	ACC.5
		MOVX	@DPTR,A
		SETB	ACC.5
		MOVX	@DPTR,A
		DJNZ	R7,ADCONVERT2
		MOV	R0,#00h
		;Clock in 8 bits
		MOV	R7,#08h
ADCONVERT3:	MOVX	@DPTR,A
		PUSH	ACC
		MOV	DPTR,#8000h
		MOVX	A,@DPTR
		RRC	A
		XCH	A,R0
		RLC	A
		XCH	A,R0
		MOV	DPTR,#8001h
		POP	ACC
		CLR	ACC.5
		MOVX	@DPTR,A
		SETB	ACC.5
		DJNZ	R7,ADCONVERT3
		;Convert 16 bit integer in R2:R0 to float and push it to fp arg stack
		LCALL	PUSHR2R0
		;Push the channelS constant to fp arg stack
		MOV	DPTR,#ADCMUL
		POP	ACC
		MOV	B,#FP_NUMBER_SIZE
		MUL	AB
		ADD	A,DPL
		MOV	DPL,A
		CLR	A
		ADDC	A,DPH
		MOV	DPH,A
		LCALL	PUSHC
		;Multiply
		LCALL	FLOATING_MUL
		MOV	FORMAT,#22h
		MOV	A,ARG_STACK
		CLR	C
		SUBB	A,#05h
		MOV	R0,A
		LCALL	FLOATING_POINT_OUTPUT
		RET

;Wait loop
;-----------------------------------------------------
WAITASEC:	MOV	R7,#0F8h
		MOV	R6,#51
		MOV	R5,#16
WAITASEC1:	DJNZ	R7,WAITASEC1
		DJNZ	R6,WAITASEC1
		DJNZ	R5,WAITASEC1
		NOP
		RET

;Frequency counter.
;IN;	A holds channel (0 to 3).
;OUT:	32 Bit result in R7:R6:R5:R4
;	LSB from 74LS393 read at 8001h, TL0, TH0, TF0 bit. 25 bits
;------------------------------------------------------------------
FRQCOUNT:
		PUSH	ACC
		SETB	ACC.2			;D2	FRQ Gate active low
		SETB	ACC.3			;D3	FRQ	Reset active high
		SETB	ACC.4			;D4	ADC CS Active low
		SETB	ACC.5			;D5	ADC CLK High to low transition
		SETB	ACC.6			;D6	ADC DIN
		SETB	ACC.7	;D7
		MOV	DPTR,#8001h
		MOVX	@DPTR,A			;Reset and gate off
		PUSH	ACC
		MOV	TL0,#00h
		MOV	TH0,#00h
		MOV	A,TMOD
		SETB	ACC.0			;M00
		CLR	ACC.1			;M01
		SETB	ACC.2			;C/T0#
		CLR	ACC.3			;GATE0
		MOV	TMOD,A
		MOV	A,TCON
		SETB	ACC.4			;TR0
		CLR	ACC.5			;TF0
		MOV	TCON,A
		POP	ACC
		CLR	ACC.2			;D2	FRQ Gate active low
		CLR	ACC.3			;D3	FRQ	Reset active high
		MOVX	@DPTR,A			;Select internal ALE,Gate on(low),Reset inactive
		ACALL	WAITASEC
		SETB	ACC.2			;D2	FRQ Gate active low
		MOVX	@DPTR,A			;Stop counting
		MOVX	A,@DPTR
		MOV	R4,A
		MOV	A,TL0
		MOV	R5,A
		MOV	A,TH0
		MOV	R6,A
		CLR	A			;TF0 Is the 25th bit
		MOV	C,TF0
		MOV	ACC.0,C
		MOV	R7,A
		MOV	R0,#LCDBUFF+4		;Decimal buffer
		ACALL	BIN2DEC
		MOV	R7,A			;Number of digits
FRQFORMAT:	MOV	A,#0Eh			;CLS
		LCALL	TXBYTE
		POP	ACC
		MOV	LCDBUFF,#'C'
		MOV	LCDBUFF+1,#'H'
		ORL	A,#30h
		MOV	LCDBUFF+2,A
		MOV	LCDBUFF+3,#' '
		MOV	R0,#LCDBUFF+4
		MOV	R1,#LCDBUFF+6
		CJNE	R7,#07h,$+3
		JC	FRQFORMATKHZ
		;MHz
		MOV	R7,#08h
FRQFORMATMHZ1:	MOV	A,@R1
		CJNE	R7,#06h,FRQFORMATMHZ2
		MOV	@R0,#'.'
		INC	R0
FRQFORMATMHZ2:	MOV	@R0,A
		INC	R0
		INC	R1
		DJNZ	R7,FRQFORMATMHZ1
		MOV	LCDBUFF+13,#'M'
		MOV	LCDBUFF+14,#'H'
		MOV	LCDBUFF+15,#'z'
		MOV	LCDBUFF+16,#00h
		SJMP	FRQFORMATDONE
FRQFORMATKHZ:	CJNE	R7,#04h,$+3
		JC	FRQFORMATHZ
		;KHz
		MOV	R7,#08h
FRQFORMATKHZ1:	MOV	A,@R1
		CJNE	R7,#03h,FRQFORMATKHZ2
		MOV	@R0,#'.'
		INC	R0
FRQFORMATKHZ2:	MOV	@R0,A
		INC	R0
		INC	R1
		DJNZ	R7,FRQFORMATKHZ1
		MOV	LCDBUFF+13,#'K'
		MOV	LCDBUFF+14,#'H'
		MOV	LCDBUFF+15,#'z'
		MOV	LCDBUFF+16,#00h
		SJMP	FRQFORMATDONE
FRQFORMATHZ:	;Hz
		MOV	LCDBUFF+4,#' '
		INC	R0
		MOV	R7,#08h
FRQFORMATHZ1:	MOV	A,@R1
		MOV	@R0,A
		INC	R0
		INC	R1
		DJNZ	R7,FRQFORMATHZ1
		MOV	LCDBUFF+13,#'H'
		MOV	LCDBUFF+14,#'z'
		MOV	LCDBUFF+15,#' '
		MOV	LCDBUFF+16,#00h
FRQFORMATDONE:	RET

;LCD Output.
;-----------------------------------------------------
LCDDELAY:	PUSH	07h
		MOV	R7,#00h
		DJNZ	R7,$
		POP	07h
		RET

;A CONTAINS NIBBLE
LCDNIBOUT:	CLR	ACC.5			; | negative edge on E
		MOVX	@DPTR,A			; |
		SETB	ACC.5			; | E
		MOVX	@DPTR,A			; |
		CLR	ACC.5			; | negative edge on E
		MOVX	@DPTR,A			; |
		RET

;A CONTAINS BYTE
LCDCMDOUT:	PUSH	ACC
		SWAP	A			;High nibble first
		ANL	A,#0Fh
		CLR	ACC.4			;RS
		ACALL	LCDNIBOUT
		POP	ACC
		ANL	A,#0Fh
		CLR	ACC.4			;RS
		ACALL	LCDNIBOUT
		ACALL	LCDDELAY		; wait for BF to clear
		RET

;A CONTAINS BYTE
LCDCHROUT:	PUSH	DPL
		PUSH	DPH
		MOV	DPTR,#8000h
		PUSH	ACC
		SWAP	A			;High nibble first
		ANL	A,#0Fh
		SETB	ACC.4			;RS
		ACALL	LCDNIBOUT
		POP	ACC
		ANL	A,#0Fh
		SETB	ACC.4			;RS
		ACALL	LCDNIBOUT
		ACALL	LCDDELAY		; wait for BF to clear
		POP	DPH
		POP	DPL
		RET

LCDINIT:	PUSH	DPL
		PUSH	DPH
		MOV	DPTR,#8000h

		;Function set
		MOV	A,#00000010b
		ACALL	LCDNIBOUT
		ACALL	LCDDELAY		; wait for BF to clear

		;Function set
			  ;0010NFXX
		MOV	A,#00101000b
		CLR	C
		ACALL	LCDCMDOUT

		;Function set
			  ;0010NFXX
		MOV	A,#00100000b
		CLR	C
		ACALL	LCDCMDOUT

		;Display ON/OFF
			  ;00001DCB
		MOV	A,#00001110b
		CLR	C
		ACALL	LCDCMDOUT

		;Cursor direction
			  ;00000010
		MOV	A,#00000110b
		CLR	C
		ACALL	LCDCMDOUT

		POP	DPH
		POP	DPL
		RET

;Binary to decimal converter
;Converts R7:R6:R5:R4 to decimal pointed to by R0
;Returns with number of digits in A
;------------------------------------------------------------------
BIN2DEC:	PUSH	DPL
		PUSH	DPH
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
		CLR	A
		MOV	@R0,A
		;Remove leading zeroes
		MOV	R0,#LCDBUFF+4
		MOV	R2,#09h
BIN2DEC3:	MOV	A,@R0
		CJNE	A,#30h,BIN2DEC4
		MOV	@R0,#20h
		INC	R0
		DJNZ	R2,BIN2DEC3
BIN2DEC4:	INC	R2
		MOV	A,R2
		POP	DPH
		POP	DPL
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

BINDEC:		DB 000h,0CAh,09Ah,03Bh		;1000000000
		DB 000h,0E1h,0F5h,005h		; 100000000
		DB 080h,096h,098h,000h		;  10000000
		DB 040h,042h,0Fh,0000h		;   1000000
		DB 0A0h,086h,001h,000h		;    100000
		DB 010h,027h,000h,000h		;     10000
		DB 0E8h,003h,000h,000h		;      1000
		DB 064h,000h,000h,000h		;       100
		DB 00Ah,000h,000h,000h		;        10
		DB 001h,000h,000h,000h		;         1

; This is a complete BCD floating point package for the 8051 micro- 
; controller. It provides 8 digits of accuracy with exponents that 
; range from +127 to -127. The mantissa is in packed BCD, while the 
; exponent is expressed in pseudo-twos complement. A ZERO exponent 
; is used to express the number ZERO. An exponent value of 80H or 
; greater than means the exponent is positive, i.e. 80H = E 0, 
; 81H = E+1, 82H = E+2 and so on. If the exponent is 7FH or less, 
; the exponent is negative, 7FH = E-1, 7EH = E-2, and so on. 
; ALL NUMBERS ARE ASSUMED TO BE NORMALIZED and all results are 
; normalized after calculation. A normalized mantissa is >=.10 and 
; <=.99999999. 
; 
; The numbers in memory assumed to be stored as follows: 
; 
; EXPONENT OF ARGUMENT 2   =   VALUE OF ARG_STACK+FP_NUMBER_SIZE 
; SIGN OF ARGUMENT 2       =   VALUE OF ARG_STACK+FP_NUMBER_SIZE-1 
; DIGIT 78 OF ARGUMENT 2   =   VALUE OF ARG_STACK+FP_NUMBER_SIZE-2 
; DIGIT 56 OF ARGUMENT 2   =   VALUE OF ARG_STACK+FP_NUMBER_SIZE-3 
; DIGIT 34 OF ARGUMENT 2   =   VALUE OF ARG_STACK+FP_NUMBER_SIZE-4 
; DIGIT 12 OF ARGUMENT 2   =   VALUE OF ARG_STACK+FP_NUMBER_SIZE-5 
; 
; EXPONENT OF ARGUMENT 1   =   VALUE OF ARG_STACK 
; SIGN OF ARGUMENT 1       =   VALUE OF ARG_STACK-1 
; DIGIT 78 OF ARGUMENT 1   =   VALUE OF ARG_STACK-2 
; DIGIT 56 OF ARGUMENT 1   =   VALUE OF ARG_STACK-3 
; DIGIT 34 OF ARGUMENT 1   =   VALUE OF ARG_STACK-4 
; DIGIT 12 OF ARGUMENT 1   =   VALUE OF ARG_STACK-5 
; 
; The operations are performed thusly: 
; 
; ARG_STACK+FP_NUMBER_SIZE = ARG_STACK+FP_NUMBER_SIZE # ARG_STACK 
; 
; Which is ARGUMENT 2 = ARGUMENT 2 # ARGUMENT 1 
; 
; Where # can be ADD, SUBTRACT, MULTIPLY OR DIVIDE. 
; 
; Note that the stack gets popped after an operation. 
; 
; The FP_COMP instruction POPS the ARG_STACK TWICE and returns status. 
; 
;********************************************************************** 
; 
;********************************************************************** 
; 
; STATUS ON RETURN - After performing an operation (+, -, *, /) 
;                    the accumulator contains the following status 
; 
; ACCUMULATOR - BIT 0 - FLOATING POINT UNDERFLOW OCCURED 
; 
;             - BIT 1 - FLOATING POINT OVERFLOW OCCURED 
; 
;             - BIT 2 - RESULT WAS ZER0 
; 
;             - BIT 3 - DIVIDE BY ZERO ATTEMPTED 
; 
;             - BIT 4 - NOT USED, 0 RETURNED 
; 
;             - BIT 5 - NOT USED, 0 RETURNED 
; 
;             - BIT 6 - NOT USED, 0 RETURNED 
; 
;             - BIT 7 - NOT USED, 0 RETURNED 
; 
; NOTE: When underflow occures, a ZERO result is returned. 
;       When overflow or divide by zero occures, a result of 
;       .99999999 E+127 is returned and it is up to the user 
;       to handle these conditions as needed in the program. 
; 
; NOTE: The Compare instruction returns F0 = 0 if ARG 1 = ARG 2 
;       and returns a CARRY FLAG = 1 if ARG 1 is > ARG 2 
; 
;*********************************************************************** 
; 
;*********************************************************************** 
; 
; The following values MUST be provided by the user 
; 
;*********************************************************************** 
; 
ARG_STACK_PAGE	EQU	01H						;External memory page for arg stack 
ARG_STACK		EQU	21H						;ARGUMENT STACK POINTER 
FORMAT			EQU	22H						;LOCATION OF OUTPUT FORMAT BYTE 
;OUTPUT			EQU	R5OUT					;CALL LOCATION TO OUTPUT A CHARACTER in R5 
CONVT			EQU	0048H					;String addr TO CONVERT NUMBERS 
INTGRC			BIT	23H.1					;BIT SET IF INTEGER ERROR 
ADD_IN			BIT	23H.3					;DCMPXZ IN BASIC BACKAGE 
ZSURP			BIT	23H.6					;ZERO SUPRESSION FOR HEX PRINT 
; 
;*********************************************************************** 
; 
; The following equates are used internally 
; 
;*********************************************************************** 
; 
FP_NUMBER_SIZE	EQU	6 
DIGIT			EQU	4 
R0B0			EQU	0 
R1B0			EQU	1 
UNDERFLOW		EQU	0 
OVERFLOW		EQU	1 
ZERO			EQU	2 
ZERO_DIVIDE		EQU	3 
; 
;*********************************************************************** 
	;************************************************************** 
	; 
	; The following internal locations are used by the math pack 
	; ordering is important and the FP_DIGITS must be bit 
	; addressable 
	; 
	;*************************************************************** 
	; 
FP_STATUS		EQU	25H					;NOT used data pointer me 
FP_TEMP			EQU	FP_STATUS+1				;NOT USED 
FP_CARRY		EQU	FP_STATUS+2				;USED FOR BITS 
FP_DIG12		EQU	FP_CARRY+1 
FP_DIG34		EQU	FP_CARRY+2 
FP_DIG56		EQU	FP_CARRY+3 
FP_DIG78		EQU	FP_CARRY+4 
FP_SIGN			EQU	FP_CARRY+5 
FP_EXP			EQU	FP_CARRY+6 
MSIGN			BIT	FP_SIGN.0 
XSIGN			BIT	FP_CARRY.0 
FOUND_RADIX		BIT	FP_CARRY.1 
FIRST_RADIX		BIT	FP_CARRY.2 
DONE_LOAD		BIT	FP_CARRY.3 
FP_NIB1			EQU	FP_DIG12	;28
FP_NIB2			EQU	FP_NIB1+1 
FP_NIB3			EQU	FP_NIB1+2 
FP_NIB4			EQU	FP_NIB1+3 
FP_NIB5			EQU	FP_NIB1+4 
FP_NIB6			EQU	FP_NIB1+5 
FP_NIB7			EQU	FP_NIB1+6 
FP_NIB8			EQU	FP_NIB1+7 
FP_ACCX			EQU	FP_NIB1+8	;30
FP_ACCC			EQU	FP_NIB1+9 
FP_ACC1			EQU	FP_NIB1+10 
FP_ACC2			EQU	FP_NIB1+11 
FP_ACC3			EQU	FP_NIB1+12 
FP_ACC4			EQU	FP_NIB1+13 
FP_ACC5			EQU	FP_NIB1+14 
FP_ACC6			EQU	FP_NIB1+15 
FP_ACC7			EQU	FP_NIB1+16 
FP_ACC8			EQU	FP_NIB1+17 
FP_ACCS			EQU	FP_NIB1+18 	;3A
	; 
	 
FP_BASE			EQU	$ 
 
	;************************************************************** 
	; 
	; The floating point entry points and jump table 
	; 
	;************************************************************** 
	; 
				AJMP	FLOATING_ADD 
				AJMP	FLOATING_SUB 
				AJMP	FLOATING_COMP 
				AJMP	FLOATING_MUL 
				AJMP	FLOATING_DIV 
				AJMP	HEXSCAN 
				AJMP	FLOATING_POINT_INPUT 
				LJMP	FLOATING_POINT_OUTPUT 
				LJMP	CONVERT_BINARY_TO_ASCII_STRING 
				LJMP	CONVERT_ASCII_STRING_TO_BINARY 
				LJMP	MULNUM10 
				LJMP	HEXOUT 
; 
; the remaining jump to routines were extracted from basic52  
; by me to make the floating point software stand alone 
; 
				AJMP	PUSHR2R0			; INTEGER to FLOAT 
				LJMP	IFIX				; FLOAT to INTEGER 
				LJMP	PUSHAS				; PUSH R2:R0 TO ARGUMENT 
				LJMP	POPAS				; POP ARGUMENT TO R3:R1 
				LJMP	MOVAS				; COPY ARGUMENT 
				LJMP	AINT				; INT FUNCTION  
				LJMP	PUSHC				; PUSH ARG IN DPTR TO STACK 

PRTERR:			RET
BADPRM:			RET

	; 
	; 
FLOATING_SUB: 
	; 
				MOV		P2,#ARG_STACK_PAGE 
				MOV		R0,ARG_STACK 
				DEC		R0					;POINT TO SIGN 
				MOVX	A,@R0				;READ SIGN 
				CPL		ACC.0 
				MOVX	@R0,A 
	; 
	;AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 
	; 
FLOATING_ADD: 
	; 
	;AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 
	; 
	; 
				ACALL 	MDES1				;R7=TOS EXP, R6=TOS-1 EXP, R4=TOS SIGN 
												;R3=TOS-1 SIGN, OPERATION IS R1 # R0 
	; 
				MOV		A,R7				;GET TOS EXPONENT  
				JZ		POP_AND_EXIT		;IF TOS=0 THEN POP AND EXIT 
				CJNE	R6,#0,FP_LOAD1		;CLEAR CARRY EXIT IF ZERO 
	; 
	;************************************************************** 
	; 
SWAP_AND_EXIT:									; Swap external args and return 
	; 
	;************************************************************** 
	; 
				ACALL	LOAD_POINTERS 
				MOV		R7,#FP_NUMBER_SIZE 
	; 
SE1:			MOVX	A,@R0				;SWAP THE ARGUMENTS 
				MOVX	@R1,A 
				DEC		R0 
				DEC		R1 
				DJNZ	R7,SE1 
	; 
POP_AND_EXIT: 
	; 
				MOV		A,ARG_STACK			;POP THE STACK 
				ADD		A,#FP_NUMBER_SIZE 
				MOV		ARG_STACK,A 
				CLR		A 
				RET 
	; 
	; 
FP_LOAD1:		SUBB	A,R6				;A = ARG 1 EXP - ARG 2 EXP 
				MOV		FP_EXP,R7			;SAVE EXPONENT AND SIGN 
				MOV		FP_SIGN,R4 
				JNC		FP_LOAD2			;ARG1 EXPONENT IS LARGER OR SAME 
				MOV		FP_EXP,R6 
				MOV		FP_SIGN,R3 
				CPL		A 
				INC		A					;COMPENSATE FOR EXP DELTA 
				XCH		A,R0				;FORCE R0 TO POINT AT THE LARGEST 
				XCH		A,R1				;EXPONENT 
				XCH		A,R0 
	; 
FP_LOAD2:		MOV		R7,A				;SAVE THE EXPONENT DELTA IN R7 
				CLR		ADD_IN 
				CJNE	R5,#0,$+5 
				SETB	ADD_IN 
	; 
	; Load the R1 mantissa 
	; 
				ACALL	LOADR1_MANTISSA		;LOAD THE SMALLEST NUMBER 
	; 
	; Now align the number to the delta exponent 
	; R4 points to the string of the last digits lost 
	; 
				CJNE	R7,#DIGIT+DIGIT+3,$+3 
				JC		$+4 
				MOV		R7,#DIGIT+DIGIT+2 
	; 
				MOV		FP_CARRY,#00		;CLEAR THE CARRY 
				ACALL	RIGHT				;SHIFT THE NUMBER 
	; 
	; Set up for addition and subtraction 
	; 
				MOV	R7,#DIGIT				;LOOP COUNT 
				MOV	R1,#FP_DIG78 
				MOV	A,#9EH 
				CLR	C 
				SUBB	A,R4 
				DA	A 
				XCH	A,R4 
				JNZ	$+3 
				MOV	R4,A 
				CJNE	A,#50H,$+3			;TEST FOR SUBTRACTION 
				JNB	ADD_IN,SUBLP			;DO SUBTRACTION IF NO ADD_IN 
				CPL	C						;FLIP CARRY FOR ADDITION 
				ACALL	ADDLP				;DO ADDITION 
	; 
				JNC		ADD_R 
				INC		FP_CARRY 
				MOV		R7,#1 
				ACALL	RIGHT 
				ACALL	INC_FP_EXP			;SHIFT AND BUMP EXPONENT 
	; 
ADD_R:			AJMP	STORE_ALIGN_TEST_AND_EXIT 
	; 
ADDLP:			MOVX	A,@R0 
				ADDC	A,@R1 
				DA		A 
				MOV		@R1,A 
				DEC		R0 
				DEC		R1 
				DJNZ	R7,ADDLP			;LOOP UNTIL DONE 
				RET 
	; 
	; 
SUBLP:			MOVX	A,@R0				;NOW DO SUBTRACTION 
				MOV		R6,A 
				CLR		A 
				ADDC	A,#99H 
				SUBB	A,@R1 
				ADD		A,R6 
				DA		A 
				MOV		@R1,A 
				DEC		R0 
				DEC		R1 
				DJNZ	R7,SUBLP 
				JC		FSUB6 
	; 
	; 
	; Need to complement the result and sign because the floating 
	; point accumulator mantissa was larger than the external 
	; memory and their signs were equal. 
	; 
				CPL	FP_SIGN.0 
				MOV	R1,#FP_DIG78 
				MOV	R7,#DIGIT				;LOOP COUNT 
	; 
FSUB5:			MOV	A,#9AH 
				SUBB	A,@R1 
				ADD		A,#0 
				DA		A 
				MOV		@R1,A 
				DEC		R1 
				CPL		C 
				DJNZ	R7,FSUB5			;LOOP 
	; 
	; Now see how many zeros their are 
	; 
FSUB6:			MOV		R0,#FP_DIG12 
				MOV		R7,#0 
	; 
FSUB7:			MOV		A,@R0 
				JNZ		FSUB8 
				INC		R7 
				INC		R7 
				INC		R0 
				CJNE	R0,#FP_SIGN,FSUB7 
				AJMP	ZERO_AND_EXIT 
	; 
FSUB8:			CJNE	A,#10H,$+3 
				JNC		FSUB9 
				INC		R7 
	; 
	; Now R7 has the number of leading zeros in the FP ACC 
	; 
FSUB9:			MOV		A,FP_EXP			;GET THE OLD EXPONENT 
				CLR		C 
				SUBB	A,R7				;SUBTRACT FROM THE NUMBER OF ZEROS 
				JZ		FSUB10 
				JC		FSUB10 
	; 
				MOV		FP_EXP,A			;SAVE THE NEW EXPONENT 
	; 
				ACALL	LEFT1				;SHIFT THE FP ACC 
				MOV		FP_CARRY,#0 
				AJMP	STORE_ALIGN_TEST_AND_EXIT 
	; 
FSUB10:			AJMP	UNDERFLOW_AND_EXIT 
	; 
	;*************************************************************** 
	; 
FLOATING_COMP:	; Compare two floating point numbers 
				; used for relational operations and is faster 
				; than subtraction. ON RETURN, The carry is set 
				; if ARG1 is > ARG2, else carry is not set 
				; if ARG1 = ARG2, F0 gets set 
	; 
	;*************************************************************** 
	; 
				ACALL	MDES1				;SET UP THE REGISTERS 
				MOV		A,ARG_STACK 
				ADD		A,#FP_NUMBER_SIZE+FP_NUMBER_SIZE 
				MOV		ARG_STACK,A			;POP THE STACK TWICE, CLEAR THE CARRY 
				MOV		A,R6				;CHECK OUT EXPONENTS 
				CLR		F0 
        		CLR     C 
				SUBB	A,R7 
				JZ		EXPONENTS_EQUAL 
				JC		ARG1_EXP_IS_LARGER 
	; 
	; Now the ARG2 EXPONENT is > ARG1 EXPONENT 
	; 
SIGNS_DIFFERENT: 
	; 
				MOV		A,R3				;SEE IF SIGN OF ARG2 IS POSITIVE 
				SJMP	$+3 
	; 
ARG1_EXP_IS_LARGER: 
	; 
				MOV		A,R4				;GET THE SIGN OF ARG1 EXPONENT 
				JZ		$+3 
				CPL		C 
				RET 
	; 
EXPONENTS_EQUAL: 
	; 
	; First, test the sign, then the mantissa 
	; 
				CJNE	R5,#0,SIGNS_DIFFERENT 
	; 
BOTH_PLUS: 
	; 
				MOV		R7,#DIGIT			;POINT AT MS DIGIT 
				DEC		R0 
				DEC		R0 
				DEC		R0 
				DEC		R1 
				DEC		R1 
				DEC		R1 
	; 
	; Now do the compare 
	; 
CLOOP:			MOVX	A,@R0 
				MOV		R6,A 
				MOVX	A,@R1 
				SUBB	A,R6 
				JNZ		ARG1_EXP_IS_LARGER 
				INC		R0 
				INC		R1 
				DJNZ	R7,CLOOP 
	; 
	; If here, the numbers are the same, the carry is cleared 
	; 
				SETB	F0 
				RET							;EXIT WITH EQUAL 
	; 
;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM 
; 
FLOATING_MUL:									; Floating point multiply 
; 
;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM 
; 
				ACALL	MUL_DIV_EXP_AND_SIGN 
	; 
	; check for zero exponents 
	; 
				CJNE	R6,#00,$+5			;ARG 2 EXP ZERO? 
				AJMP	ZERO_AND_EXIT 
	; 
	; calculate the exponent 
	; 
FMUL1:			MOV		FP_SIGN,R5			;SAVE THE SIGN, IN CASE OF FAILURE 
	; 
				MOV		A,R7 
				JZ		FMUL1-2 
				ADD		A,R6				;ADD THE EXPONENTS 
				JB		ACC.7,FMUL_OVER 
				JBC		CY,FMUL2			;SEE IF CARRY IS SET 
	; 
				AJMP	UNDERFLOW_AND_EXIT 
	; 
FMUL_OVER: 
	; 
				JNC		FMUL2				;OK IF SET 
	; 
FOV:			AJMP	OVERFLOW_AND_EXIT 
	; 
FMUL2:			SUBB	A,#129				;SUBTRACT THE EXPONENT BIAS 
				MOV		R6,A				;SAVE IT FOR LATER 
	; 
	; Unpack and load R0 
	; 
				ACALL	UNPACK_R0 
	; 
	; Now set up for loop multiply 
	; 
				MOV		R3,#DIGIT 
				MOV		R4,R1B0 
	; 
	; 
	; Now, do the multiply and accumulate the product 
	; 
FMUL3:			MOV		R1B0,R4 
				MOVX	A,@R1 
				MOV		R2,A 
				ACALL	MUL_NIBBLE 
	; 
				MOV		A,R2 
				SWAP	A 
				ACALL	MUL_NIBBLE 
				DEC		R4 
				DJNZ	R3,FMUL3 
	; 
	; Now, pack and restore the sign 
	; 
				MOV		FP_EXP,R6 
				MOV		FP_SIGN,R5 
				AJMP	PACK				;FINISH IT OFF 
	; 
	;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD 
	; 
FLOATING_DIV: 
	; 
	;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD 
	; 
				ACALL	MDES1 
	; 
	; Check the exponents 
	; 
				MOV		FP_SIGN,R5			;SAVE THE SIGN 
				CJNE	R7,#0,DIV0			;CLEARS THE CARRY 
				ACALL	OVERFLOW_AND_EXIT 
				CLR		A 
				SETB	ACC.ZERO_DIVIDE 
				RET 
	; 
DIV0:			MOV		A,R6				;GET EXPONENT 
				JZ		FMUL1-2				;EXIT IF ZERO 
				SUBB	A,R7				;DELTA EXPONENT 
				JB		ACC.7,D_UNDER 
				JNC		DIV3 
				AJMP	UNDERFLOW_AND_EXIT 
	; 
D_UNDER:JNC	FOV 
	; 
DIV3:			ADD		A,#129				;CORRECTLY BIAS THE EXPONENT 
				MOV		FP_EXP,A			;SAVE THE EXPONENT 
				ACALL	LOADR1_MANTISSA		;LOAD THE DIVIDED 
	; 
				MOV		R2,#FP_ACCC			;SAVE LOCATION 
				MOV		R3,R0B0				;SAVE POINTER IN R3 
				MOV		FP_CARRY,#0			;ZERO CARRY BYTE 
	; 
DIV4:			MOV		R5,#0FFH			;LOOP COUNT 
				SETB	C 
	; 
DIV5:			MOV		R0B0,R3				;RESTORE THE EXTERNAL POINTER 
				MOV		R1,#FP_DIG78		;SET UP INTERNAL POINTER 
				MOV		R7,#DIGIT			;LOOP COUNT 
				JNC		DIV7				;EXIT IF NO CARRY 
	; 
DIV6:			MOVX	A,@R0				;DO ACCUMLATION 
				MOV		R6,A 
				CLR		A 
				ADDC	A,#99H 
				SUBB	A,R6 
				ADD		A,@R1 
				DA		A 
				MOV		@R1,A 
				DEC		R0 
				DEC		R1 
				DJNZ	R7,DIV6				;LOOP 
	; 
				INC		R5					;SUBTRACT COUNTER 
				JC		DIV5				;KEEP LOOPING IF CARRY 
				MOV		A,@R1				;GET CARRY 
				SUBB	A,#1				;CARRY IS CLEARED 
				MOV		@R1,A				;SAVE CARRY DIGIT 
				CPL		C 
				SJMP	DIV5				;LOOP 
	; 
	; Restore the result if carry was found 
	; 
DIV7:			ACALL	ADDLP				;ADD NUMBER BACK 
				MOV		@R1,#0				;CLEAR CARRY 
				MOV		R0B0,R2				;GET SAVE COUNTER 
				MOV		@R0,5				;SAVE COUNT BYTE 
	; 
				INC		R2					;ADJUST SAVE COUNTER 
				MOV		R7,#1				;BUMP DIVIDEND 
				ACALL	LEFT 
				CJNE	R2,#FP_ACC8+2,DIV4 
	; 
				DJNZ	FP_EXP,DIV8 
				AJMP	UNDERFLOW_AND_EXIT 
	; 
DIV8:			MOV		FP_CARRY,#0 
	; 
	;*************************************************************** 
	; 
PACK:	; Pack the mantissa 
	; 
	;*************************************************************** 
	; 
	; First, set up the pointers 
	; 
				MOV		R0,#FP_ACCC 
				MOV		A,@R0				;GET FP_ACCC 
				MOV		R6,A				;SAVE FOR ZERO COUNT 
				JZ		PACK0				;JUMP OVER IF ZERO 
				ACALL	INC_FP_EXP			;BUMP THE EXPONENT 
				DEC		R0 
	; 
PACK0:			INC		R0					;POINT AT FP_ACC1 
	; 
PACK1:			MOV		A,#8				;ADJUST NIBBLE POINTER 
				MOV		R1,A 
				ADD		A,R0 
				MOV		R0,A 
				CJNE	@R0,#5,$+3			;SEE IF ADJUSTING NEEDED 
				JC		PACK3+1 
	; 
PACK2:			SETB	C 
				CLR		A 
				DEC		R0 
				ADDC	A,@R0 
				DA		A 
				XCHD	A,@R0				;SAVE THE VALUE 
				JNB		ACC.4,PACK3 
				DJNZ	R1,PACK2 
	; 
				DEC		R0 
				MOV		@R0,#1 
				ACALL	INC_FP_EXP 
				SJMP	PACK4 
	; 
PACK3:			DEC		R1 
				MOV		A,R1 
				CLR		C 
				XCH		A,R0 
				SUBB	A,R0 
				MOV		R0,A 
	; 
PACK4:			MOV		R1,#FP_DIG12 
	; 
	; Now, pack 
	; 
PLOOP:			MOV		A,@R0 
				SWAP	A					;FLIP THE DIGITS 
				INC		R0 
				XCHD	A,@R0 
				ORL		6,A					;ACCUMULATE THE OR'ED DIGITS 
				MOV		@R1,A 
				INC		R0 
				INC		R1 
				CJNE	R1,#FP_SIGN,PLOOP 
				MOV		A,R6 
				JNZ		STORE_ALIGN_TEST_AND_EXIT 
				MOV		FP_EXP,#0			;ZERO EXPONENT 
	; 
	;************************************************************** 
	; 
STORE_ALIGN_TEST_AND_EXIT:						;Save the number align carry and exit 
	; 
	;************************************************************** 
	; 
				ACALL	LOAD_POINTERS 
				MOV		ARG_STACK,R1		;SET UP THE NEW STACK 
				MOV		R0,#FP_EXP 
	; 
	; Now load the numbers 
	; 
STORE2:			MOV		A,@R0 
				MOVX	@R1,A				;SAVE THE NUMBER 
				DEC		R0 
				DEC		R1 
				CJNE	R0,#FP_CARRY,STORE2 
	; 
				CLR		A					;NO ERRORS 
	; 
PRET:			RET							;EXIT 
	; 
INC_FP_EXP: 
	; 
				INC		FP_EXP 
				MOV		A,FP_EXP 
				JNZ		PRET				;EXIT IF NOT ZERO 
				POP		ACC					;WASTE THE CALLING STACK 
				POP		ACC 
				AJMP	OVERFLOW_AND_EXIT 
	; 
;*********************************************************************** 
; 
UNPACK_R0:	; Unpack BCD digits and load into nibble locations 
; 
;*********************************************************************** 
	; 
				PUSH	R1B0 
				MOV		R1,#FP_NIB8 
	; 
ULOOP:			MOVX	A,@R0 
				ANL		A,#0FH 
				MOV		@R1,A				;SAVE THE NIBBLE 
				MOVX	A,@R0 
				SWAP	A 
				ANL		A,#0FH 
				DEC		R1 
				MOV		@R1,A				;SAVE THE NIBBLE AGAIN 
				DEC		R0 
				DEC		R1 
				CJNE	R1,#FP_NIB1-1,ULOOP 
	; 
				POP		R1B0 
	; 
LOAD7:			RET 
	; 
	;************************************************************** 
	; 
OVERFLOW_AND_EXIT:	;LOAD 99999999 E+127,  SET OV BIT, AND EXIT 
	; 
	;************************************************************** 
	; 
				MOV		R0,#FP_DIG78 
				MOV		A,#99H 
	; 
OVE1:			MOV		@R0,A 
				DEC		R0 
				CJNE	R0,#FP_CARRY,OVE1 
	; 
				MOV		FP_EXP,#0FFH 
				ACALL	STORE_ALIGN_TEST_AND_EXIT 
	; 
				SETB	ACC.OVERFLOW 
				RET 
	; 
	;************************************************************** 
	; 
UNDERFLOW_AND_EXIT:	;LOAD 0, SET UF BIT, AND EXIT 
	; 
	;************************************************************** 
	; 
				ACALL	ZERO_AND_EXIT 
				CLR		A 
				SETB	ACC.UNDERFLOW 
				RET 
	; 
	;************************************************************** 
	; 
ZERO_AND_EXIT:		;LOAD 0, SET ZERO BIT, AND EXIT 
	; 
	;************************************************************** 
	; 
				ACALL	FP_CLEAR 
				ACALL	STORE_ALIGN_TEST_AND_EXIT 
				SETB	ACC.ZERO 
				RET							;EXIT 
	; 
	;************************************************************** 
	; 
FP_CLEAR: 
	; 
	; Clear internal storage 
	; 
	;************************************************************** 
	; 
				CLR		A 
				MOV		R0,#FP_ACC8+1 
	; 
FPC1:			MOV		@R0,A 
				DEC		R0 
				CJNE	R0,#FP_TEMP,FPC1 
				RET 
	; 
	;************************************************************** 
	; 
RIGHT:	; Shift ACCUMULATOR RIGHT the number of nibbles in R7 
	; Save the shifted values in R4 if SAVE_ROUND is set 
	; 
	;************************************************************** 
	; 
				MOV		R4,#0				;IN CASE OF NO SHIFT 
	; 
RIGHT1:	CLR	C 
				MOV		A,R7				;GET THE DIGITS TO SHIFT 
				JZ		RIGHT5-1			;EXIT IF ZERO 
				SUBB	A,#2				;TWO TO DO? 
				JNC		RIGHT5				;SHIFT TWO NIBBLES 
	; 
	; Swap one nibble then exit 
	; 
RIGHT3:			PUSH	R0B0				;SAVE POINTER REGISTER 
				PUSH	R1B0 
	; 
				MOV		R1,#FP_DIG78		;LOAD THE POINTERS 
				MOV		R0,#FP_DIG56 
				MOV		A,R4				;GET THE OVERFLOW REGISTER 
				XCHD	A,@R1				;GET DIGIT 8 
				SWAP	A					;FLIP FOR LOAD 
				MOV		R4,A 
	; 
RIGHTL:			MOV		A,@R1				;GET THE LOW ORDER BYTE 
				XCHD	A,@R0				;SWAP NIBBLES 
				SWAP	A					;FLIP FOR STORE 
				MOV		@R1,A				;SAVE THE DIGITS 
				DEC		R0					;BUMP THE POINTERS 
				DEC		R1 
				CJNE	R1,#FP_DIG12-1,RIGHTL	;LOOP 
	; 
				MOV		A,@R1				;ACC = CH8 
				SWAP	A					;ACC = 8CH 
				ANL		A,#0FH				;ACC = 0CH 
				MOV		@R1,A				;CARRY DONE 
				POP		R1B0				;EXIT 
				POP		R0B0				;RESTORE REGISTER 
				RET 
	; 
RIGHT5:			MOV		R7,A				;SAVE THE NEW SHIFT NUMBER 
				CLR		A 
				XCH		A,FP_CARRY			;SWAP THE NIBBLES 
				XCH		A,FP_DIG12 
				XCH		A,FP_DIG34 
				XCH		A,FP_DIG56 
				XCH		A,FP_DIG78 
				MOV		R4,A				;SAVE THE LAST DIGIT SHIFTED 
				SJMP	RIGHT1+1 
	; 
	;*************************************************************** 
	; 
LEFT:	; Shift ACCUMULATOR LEFT the number of nibbles in R7 
	; 
	;*************************************************************** 
	; 
				MOV		R4,#00H				;CLEAR FOR SOME ENTRYS 
	; 
LEFT1:			CLR		C 
				MOV		A,R7				;GET SHIFT VALUE 
				JZ		LEFT5-1				;EXIT IF ZERO 
				SUBB	A,#2				;SEE HOW MANY BYTES TO SHIFT 
				JNC		LEFT5 
	; 
LEFT3:			PUSH	R0B0				;SAVE POINTER 
				PUSH	R1B0 
				MOV		R0,#FP_CARRY 
				MOV		R1,#FP_DIG12 
	; 
				MOV		A,@R0				;ACC=CHCL 
				SWAP	A					;ACC = CLCH 
				MOV		@R0,A				;ACC = CLCH, @R0 = CLCH 
	; 
LEFTL:			MOV		A,@R1				;DIG 12 
				SWAP	A					;DIG 21 
				XCHD	A,@R0 
				MOV		@R1,A				;SAVE IT 
				INC		R0					;BUMP POINTERS 
				INC		R1 
				CJNE	R0,#FP_DIG78,LEFTL 
	; 
				MOV		A,R4 
				SWAP	A 
				XCHD	A,@R0 
				ANL		A,#0F0H 
				MOV		R4,A 
	; 
				POP		R1B0 
				POP		R0B0				;RESTORE 
				RET							;DONE 
	; 
LEFT5:			MOV		R7,A				;RESTORE COUNT 
				CLR		A 
				XCH		A,R4				;GET THE RESTORATION BYTE 
				XCH		A,FP_DIG78			;DO THE SWAP 
				XCH		A,FP_DIG56 
				XCH		A,FP_DIG34 
				XCH		A,FP_DIG12 
				XCH		A,FP_CARRY 
				SJMP	LEFT1+1 
	; 
MUL_NIBBLE: 
	; 
	; Multiply the nibble in R7 by the FP_NIB locations 
	; accumulate the product in FP_ACC 
	; 
	; Set up the pointers for multiplication 
	; 
				ANL		A,#0FH				;STRIP OFF MS NIBBLE 
				MOV		R7,A 
				MOV		R0,#FP_ACC8 
				MOV		R1,#FP_NIB8 
				CLR		A 
				MOV		FP_ACCX,A 
	; 
MNLOOP:			DEC		R0					;BUMP POINTER TO PROPAGATE CARRY 
				ADD		A,@R0				;ATTEMPT TO FORCE CARRY 
				DA		A					;BCD ADJUST 
				JNB		ACC.4,MNL0			;DON'T ADJUST IF NO NEED 
				DEC		R0					;PROPAGATE CARRY TO THE NEXT DIGIT 
				INC		@R0					;DO THE ADJUSTING 
				INC		R0					;RESTORE R0 
	; 
MNL0:			XCHD	A,@R0				;RESTORE INITIAL NUMBER 
				MOV		B,R7				;GET THE NUBBLE TO MULTIPLY 
				MOV		A,@R1				;GET THE OTHER NIBBLE 
				MUL		AB					;DO THE MULTIPLY 
				MOV		B,#10				;NOW BCD ADJUST 
				DIV		AB 
				XCH		A,B					;GET THE REMAINDER 
				ADD		A,@R0				;PROPAGATE THE PARTIAL PRODUCTS 
				DA		A					;BCD ADJUST 
				JNB		ACC.4,MNL1			;PROPAGATE PARTIAL PRODUCT CARRY 
				INC		B 
	; 
MNL1:			INC		R0 
				XCHD	A,@R0				;SAVE THE NEW PRODUCT 
				DEC		R0 
				MOV		A,B					;GET BACK THE QUOTIENT 
				DEC		R1 
				CJNE	R1,#FP_NIB1-1,MNLOOP 
	; 
				ADD		A,FP_ACCX			;GET THE OVERFLOW 
				DA		A					;ADJUST 
				MOV		@R0,A				;SAVE IT 
				RET							;EXIT 
	; 
	;*************************************************************** 
	; 
LOAD_POINTERS:	; Load the ARG_STACK into R0 and bump R1 
	; 
	;*************************************************************** 
	; 
				MOV		P2,#ARG_STACK_PAGE 
				MOV		R0,ARG_STACK 
				MOV		A,#FP_NUMBER_SIZE 
				ADD		A,R0 
				MOV		R1,A 
				RET 
	; 
	;*************************************************************** 
	; 
MUL_DIV_EXP_AND_SIGN: 
	; 
	; Load the sign into R7, R6. R5 gets the sign for 
	; multiply and divide. 
	; 
	;*************************************************************** 
	; 
				ACALL	FP_CLEAR			;CLEAR INTERNAL MEMORY 
	; 
MDES1:			ACALL	LOAD_POINTERS		;LOAD REGISTERS 
				MOVX	A,@R0				;ARG 1 EXP 
				MOV		R7,A				;SAVED IN R7 
				MOVX	A,@R1				;ARG 2 EXP 
				MOV		R6,A				;SAVED IN R6 
				DEC		R0					;BUMP POINTERS TO SIGN 
				DEC		R1 
				MOVX	A,@R0				;GET THE SIGN 
				MOV		R4,A				;SIGN OF ARG1 
				MOVX	A,@R1				;GET SIGN OF NEXT ARG 
				MOV		R3,A				;SIGN OF ARG2 
				XRL		A,R4				;ACC GETS THE NEW SIGN 
				MOV		R5,A				;R5 GETS THE NEW SIGN 
	; 
	; Bump the pointers to point at the LS digit 
	; 
				DEC		R0 
				DEC		R1 
	; 
				RET 
	; 
	;*************************************************************** 
	; 
LOADR1_MANTISSA: 
	; 
	; Load the mantissa of R0 into FP_Digits 
	; 
	;*************************************************************** 
	; 
				PUSH	R0B0				;SAVE REGISTER 1 
				MOV		R0,#FP_DIG78		;SET UP THE POINTER 
	; 
LOADR1:			MOVX	A,@R1 
				MOV		@R0,A 
				DEC		R1 
				DEC		R0 
				CJNE	R0,#FP_CARRY,LOADR1 
	; 
				POP		R0B0 
				RET 
	; 
	;*************************************************************** 
	; 
HEXSCAN:	; Scan a string to determine if it is a hex number 
		; set carry if hex, else carry = 0 
	; 
	;*************************************************************** 
	; 
				LCALL	GET_DPTR_CHARACTER 
				PUSH	DPH 
				PUSH	DPL					;SAVE THE POINTER 
	; 
HEXSC1:			MOVX	A,@DPTR				;GET THE CHARACTER 
				LCALL	DIGIT_CHECK			;SEE IF A DIGIT 
				JC		HS1					;CONTINUE IF A DIGIT 
				ACALL	HEX_CHECK			;SEE IF HEX 
				JC		HS1 
	; 
				CLR		ACC.5				;NO LOWER CASE 
				CJNE	A,#'H',HEXDON 
				SETB	C 
				SJMP	HEXDO1				;NUMBER IS VALID HEX, MAYBE 
	; 
HEXDON:			CLR		C 
	; 
HEXDO1:			POP		DPL					;RESTORE POINTER 
				POP		DPH 
				RET 
	; 
HS1:			INC		DPTR				;BUMP TO NEXT CHARACTER 
				SJMP	HEXSC1				;LOOP 
	; 
HEX_CHECK:	;CHECK FOR A VALID ASCII HEX, SET CARRY IF FOUND 
	; 
				CLR		ACC.5				;WASTE LOWER CASE 
				CJNE	A,#'F'+1,$+3		;SEE IF F OR LESS 
				JC		HC1 
				RET 
	; 
HC1:			CJNE	A,#'A',$+3			;SEE IF A OR GREATER 
				CPL		C 
				RET 
	; 
	; 
PUSHR2R0: 
	;  
				MOV		R3,#HIGH CONVT		;CONVERSION LOCATION 
				MOV		R1,#LOW CONVT 
				LCALL	CONVERT_BINARY_TO_ASCII_STRING 
				MOV		A,#0DH				;A CR TO TERMINATE 
				MOVX	@R1,A				;SAVE THE CR 
				MOV		DPTR,#CONVT 
	; 
	; Falls thru to FLOATING INPUT 
	; 
	;*************************************************************** 
	; 
FLOATING_POINT_INPUT:	; Input a floating point number pointed to by 
						; the DPTR 
	; 
	;*************************************************************** 
	; 
				ACALL	FP_CLEAR			;CLEAR EVERYTHING 
				LCALL	GET_DPTR_CHARACTER 
				LCALL	PLUS_MINUS_TEST 
				MOV		MSIGN,C				;SAVE THE MANTISSA SIGN 
	; 
	; Now, set up for input loop 
	; 
				MOV		R0,#FP_ACCC 
				MOV		R6,#7FH				;BASE EXPONENT 
				SETB	F0					;SET INITIAL FLAG 
	; 
INLOOP:			LCALL	GET_DIGIT_CHECK 
				JNC		GTEST				;IF NOT A CHARACTER, WHAT IS IT? 
				ANL		A,#0FH				;STRIP ASCII 
				LCALL	STDIG				;STORE THE DIGITS 
	; 
INLPIK:			INC		DPTR				;BUMP POINTER FOR LOOP 
				SJMP	INLOOP				;LOOP FOR INPUT 
	; 
GTEST:			CJNE	A,#'.',GT1			;SEE IF A RADIX 
				JB		FOUND_RADIX,INERR 
				SETB	FOUND_RADIX 
				CJNE	R0,#FP_ACCC,INLPIK 
				SETB	FIRST_RADIX			;SET IF FIRST RADIX 
				SJMP	INLPIK				;GET ADDITIONAL DIGITS 
	; 
GT1:			JB		F0,INERR			;ERROR IF NOT CLEARED 
				CJNE	A,#'e',$+5			;CHECK FOR LOWER CASE 
				SJMP	$+5 
				CJNE	A,#'E',FINISH_UP 
				LCALL	INC_AND_GET_DPTR_CHARACTER 
				LCALL	PLUS_MINUS_TEST 
				MOV		XSIGN,C				;SAVE SIGN STATUS 
				LCALL	GET_DIGIT_CHECK 
				JNC		INERR 
	; 
				ANL		A,#0FH				;STRIP ASCII BIAS OFF THE CHARACTER 
				MOV		R5,A				;SAVE THE CHARACTER IN R5 
	; 
GT2:			INC		DPTR 
				LCALL	GET_DIGIT_CHECK 
				JNC		FINISH1 
				ANL		A,#0FH				;STRIP OFF BIAS 
				XCH		A,R5				;GET THE LAST DIGIT 
				MOV		B,#10				;MULTIPLY BY TEN 
				MUL		AB 
				ADD		A,R5				;ADD TO ORIGINAL VALUE 
				MOV		R5,A				;SAVE IN R5 
				JNC		GT2					;LOOP IF NO CARRY 
				MOV		R5,#0FFH			;FORCE AN ERROR 
	; 
FINISH1:		MOV		A,R5				;GET THE SIGN 
				JNB		XSIGN,POSNUM		;SEE IF EXPONENT IS POS OR NEG 
				CLR		C 
				SUBB	A,R6 
				CPL		A 
				INC		A 
				JC		FINISH2 
				MOV		A,#01H 
				RET 
	; 
POSNUM:			ADD		A,R6				;ADD TO EXPONENT 
				JNC		FINISH2 
	; 
POSNM1:			MOV		A,#02H 
				RET 
	; 
FINISH2:		XCH		A,R6				;SAVE THE EXPONENT 
	; 
FINISH_UP: 
	; 
				MOV		FP_EXP,R6			;SAVE EXPONENT 
				CJNE	R0,#FP_ACCC,$+5 
				ACALL	FP_CLEAR			;CLEAR THE MEMORY IF 0 
				MOV		A,ARG_STACK			;GET THE ARG STACK 
				CLR		C 
				SUBB	A,#FP_NUMBER_SIZE+FP_NUMBER_SIZE 
				MOV		ARG_STACK,A			;ADJUST FOR STORE 
				LJMP	PACK 
	; 
STDIG:			CLR		F0					;CLEAR INITIAL DESIGNATOR 
				JNZ		STDIG1				;CONTINUE IF NOT ZERO 
				CJNE	R0,#FP_ACCC,STDIG1 
				JNB		FIRST_RADIX,RET_X 
	; 
DECX:			DJNZ	R6,RET_X 
	; 
INERR:			MOV		A,#0FFH 
	; 
RET_X:			RET 
	; 
STDIG1:			JB		DONE_LOAD,FRTEST 
				CLR		FIRST_RADIX 
	; 
FRTEST:			JB		FIRST_RADIX,DECX 
	; 
FDTEST:			JB		FOUND_RADIX,FDT1 
				INC		R6 
	; 
FDT1:			JB		DONE_LOAD,RET_X 
				CJNE	R0,#FP_ACC8+1,FDT2 
				SETB	DONE_LOAD 
	; 
FDT2:			MOV		@R0,A				;SAVE THE STRIPPED ACCUMULATOR 
				INC		R0					;BUMP THE POINTER 
				RET							;EXIT 
	; 
	;*************************************************************** 
	; 
	; I/O utilities 
	; 
	;*************************************************************** 
	; 
INC_AND_GET_DPTR_CHARACTER: 
	; 
					INC		DPTR 
	; 
GET_DPTR_CHARACTER: 
	; 
					MOVX	A,@DPTR				;GET THE CHARACTER 
					CJNE	A,#' ',PMT1			;SEE IF A SPACE 
	; 
	; Kill spaces 
	; 
					SJMP	INC_AND_GET_DPTR_CHARACTER 
	; 
PLUS_MINUS_TEST: 
	; 
					CJNE	A,#0E3H,$+5			;SEE IF A PLUS, PLUS TOKEN FROM BASIC 
					SJMP	PMT3 
					CJNE	A,#'+',$+5 
					SJMP	PMT3 
					CJNE	A,#0E5H,$+5			;SEE IF MINUS, MINUS TOKEN FROM BASIC 
					SJMP	PMT2 
					CJNE	A,#'-',PMT1 
	; 
PMT2:				SETB	C 
	; 
PMT3:				INC	DPTR 
	; 
PMT1:				RET 
	; 
	;*************************************************************** 
	; 
FLOATING_POINT_OUTPUT:	; Output the number, format is in location 22
	; 
	; IF FORMAT = 00 - FREE FLOATING 
	;           = FX - EXPONENTIAL (X IS THE NUMBER OF SIG DIGITS) 
	;           = NX - N = NUM BEFORE RADIX, X = NUM AFTER RADIX 
	;                  N + X = 8 MAX 
	; 
	;*************************************************************** 
	; 
					LCALL	MDES1				;GET THE NUMBER TO OUTPUT, R0 IS POINTER 
					LCALL	POP_AND_EXIT		;OUTPUT POPS THE STACK 
					MOV		A,R7 
					MOV		R6,A				;PUT THE EXPONENT IN R6 
					LCALL	UNPACK_R0			;UNPACK THE NUMBER 
					MOV		R0,#FP_NIB1			;POINT AT THE NUMBER 
					MOV		A,FORMAT			;GET THE FORMAT 
					MOV		R3,A				;SAVE IN CASE OF EXP FORMAT 
					JZ		FREE				;FREE FLOATING? 
					CJNE	A,#0F0H,$+3			;SEE IF EXPONENTIAL 
					JC		USING00 
					LJMP	EXPOUT 
USING00:
	; 
	; If here, must be integer USING format 
	; 
					MOV		A,R6				;GET THE EXPONENT 
					JNZ		$+4 
					MOV		R6,#80H 
					MOV		A,R3				;GET THE FORMAT 
					SWAP	A					;SPLIT INTEGER AND FRACTION 
					ANL		A,#0FH 
					MOV		R2,A				;SAVE INTEGER 
					LCALL	NUM_LT				;GET THE NUMBER OF INTEGERS 
					XCH		A,R2				;FLIP FOR SUBB 
					CLR		C 
					SUBB	A,R2 
					MOV		R7,A 
					JNC		$+8 
					MOV		R5,#'?'				;OUTPUT A QUESTION MARK 
					LCALL	SOUT1				;NUMBER IS TOO LARGE FOR FORMAT 
					LJMP	FREE 
					CJNE	R2,#00,USING0		;SEE IF ZERO 
					DEC		R7 
					LCALL	SS7 
					LCALL	ZOUT				;OUTPUT A ZERO 
					SJMP	USING1 
	; 
USING0:				LCALL	SS7					;OUTPUT SPACES, IF NEED TO 
					MOV		A,R2				;OUTPUT DIGITS 
					MOV		R7,A 
					LCALL	OUTR0 
	; 
USING1:				MOV		A,R3 
					ANL		A,#0FH				;GET THE NUMBER RIGHT OF DP 
					MOV		R2,A				;SAVE IT 
					JZ		PMT1				;EXIT IF ZERO 
					LCALL	ROUT				;OUTPUT DP 
					LCALL	NUM_RT 
					CJNE	A,2,USINGX			;COMPARE A TO R2 
	; 
USINGY:				MOV		A,R2 
					LJMP	Z7R7 
	; 
USINGX:				JNC		USINGY 
	; 
USING2:				XCH		A,R2 
					CLR		C 
					SUBB	A,R2 
					XCH		A,R2 
					LCALL	Z7R7				;OUTPUT ZEROS IF NEED TO 
					MOV		A,R2 
					MOV		R7,A 
					LJMP	OUTR0 
	; 
	; First, force exponential output, if need to 
	; 
FREE:				MOV		A,R6				;GET THE EXPONENT 
					JNZ		FREE1				;IF ZERO, PRINT IT 
					LCALL	SOUT 
					LJMP	ZOUT 
	; 
FREE1:				MOV		R3,#0F0H			;IN CASE EXP NEEDED 
					MOV		A,#80H-DIGIT-DIGIT-1 
					ADD		A,R6 
					JC		EXPOUT 
					SUBB	A,#0F7H 
					JC		EXPOUT 
	; 
	; Now, just print the number 
	; 
					LCALL	SINOUT				;PRINT THE SIGN OF THE NUMBER 
					LCALL	NUM_LT				;GET THE NUMBER LEFT OF DP 
					CJNE	A,#8,FREE4 
					LJMP	OUTR0 
	; 
FREE4:				LCALL	OUTR0 
					LCALL	ZTEST				;TEST FOR TRAILING ZEROS 
					JZ		U_RET				;DONE IF ALL TRAILING ZEROS 
					LCALL	ROUT				;OUTPUT RADIX 
	; 
FREE2:				MOV		R7,#1				;OUTPUT ONE DIGIT 
					LCALL	OUTR0 
					JNZ		U_RET 
					LCALL	ZTEST 
					JZ		U_RET 
					SJMP	FREE2				;LOOP 
	; 
EXPOUT:				LCALL	SINOUT				;PRINT THE SIGN 
					MOV		R7,#1				;OUTPUT ONE CHARACTER 
					LCALL	OUTR0 
					LCALL	ROUT				;OUTPUT RADIX 
					MOV		A,R3				;GET FORMAT 
					ANL		A,#0FH				;STRIP INDICATOR 
					JZ		EXPOTX 
	; 
					MOV		R7,A				;OUTPUT THE NUMBER OF DIGITS 
					DEC		R7					;ADJUST BECAUSE ONE CHAR ALREADY OUT 
					LCALL	OUTR0 
					SJMP	EXPOT4 
	; 
EXPOTX:				LCALL	FREE2				;OUTPUT UNTIL TRAILING ZEROS 
	; 
EXPOT4:				LCALL	SOUT				;OUTPUT A SPACE 
					MOV		R5,#'E' 
					LCALL	SOUT1				;OUTPUT AN E 
					MOV		A,R6				;GET THE EXPONENT 
					JZ		XOUT0				;EXIT IF ZERO 
					DEC		A					;ADJUST FOR THE DIGIT ALREADY OUTPUT 
					CJNE	A,#80H,XOUT2		;SEE WHAT IT IS 
	; 
XOUT0:				LCALL	SOUT 
					CLR		A 
					SJMP	XOUT4 
	; 
XOUT2:				JC		XOUT3				;NEGATIVE EXPONENT 
					MOV		R5,#'+'				;OUTPUT A PLUS SIGN 
					LCALL	SOUT1 
					SJMP	XOUT4 
	; 
XOUT3:				LCALL	MOUT 
					CPL		A					;FLIP BITS 
					INC		A					;BUMP 
	; 
XOUT4:				CLR		ACC.7 
					MOV		R0,A 
					MOV		R2,#0 
					MOV		R1,#LOW CONVT		;CONVERSION LOCATION 
					MOV		R3,#HIGH CONVT 
					LCALL	CONVERT_BINARY_TO_ASCII_STRING 
					MOV		R0,#LOW CONVT		;NOW, OUTPUT EXPONENT 
	; 
EXPOT5:				MOVX	A,@R0				;GET THE CHARACTER 
					MOV		R5,A				;OUTPUT IT 
					LCALL	SOUT1 
					INC		R0					;BUMP THE POINTER 
					MOV		A,R0				;GET THE POINTER 
					CJNE	A,R1B0,EXPOT5		;LOOP 
	; 
U_RET:				RET							;EXIT 
	; 
OUTR0:	; Output the characters pointed to by R0, also bias ascii 
	; 
					MOV		A,R7				;GET THE COUNTER 
					JZ		OUTR				;EXIT IF DONE 
					MOV		A,@R0				;GET THE NUMBER 
					ORL		A,#30H				;ASCII BIAS 
					INC		R0					;BUMP POINTER AND COUNTER 
					DEC		R7 
					MOV		R5,A				;PUT CHARACTER IN OUTPUT REGISTER 
					LCALL	SOUT1				;OUTPUT THE CHARACTER 
					CLR		A					;JUST FOR TEST 
					CJNE	R0,#FP_NIB8+1,OUTR0 
					MOV		A,#55H				;KNOW WHERE EXIT OCCURED 
	; 
OUTR:				RET 
	; 
ZTEST:				MOV		R1,R0B0				;GET POINTER REGISTER 
	; 
ZT0:				MOV		A,@R1				;GET THE VALUE 
					JNZ		ZT1 
					INC		R1					;BUMP POINTER 
					CJNE	R1,#FP_NIB8+1,ZT0 
	; 
ZT1:				RET 
	; 
NUM_LT:				MOV		A,R6				;GET EXPONENT 
					CLR		C					;GET READY FOR SUBB 
					SUBB	A,#80H				;SUB EXPONENT BIAS 
					JNC		NL1					;OK IF NO CARRY 
					CLR		A					;NO DIGITS LEFT 
	; 
NL1:				MOV		R7,A				;SAVE THE COUNT 
					RET 
	; 
NUM_RT:				CLR		C					;SUBB AGAIN 
					MOV		A,#80H				;EXPONENT BIAS 
					SUBB	A,R6				;GET THE BIASED EXPONENT 
					JNC		NR1 
					CLR		A 
	; 
NR1:				RET							;EXIT 
	; 
SPACE7:				MOV		A,R7				;GET THE NUMBER OF SPACES 
					JZ		NR1					;EXIT IF ZERO 
					LCALL	SOUT				;OUTPUT A SPACE 
					DEC		R7					;BUMP COUNTER 
					SJMP	SPACE7				;LOOP 
	; 
Z7R7:				MOV		R7,A 
	; 
ZERO7:				MOV		A,R7				;GET COUNTER 
					JZ		NR1					;EXIT IF ZERO 
					LCALL	ZOUT				;OUTPUT A ZERO 
					DEC		R7					;BUMP COUNTER 
					SJMP	ZERO7				;LOOP 
	; 
SS7:				LCALL	SPACE7 
	; 
SINOUT:				MOV		A,R4				;GET THE SIGN 
					JZ		SOUT				;OUTPUT A SPACE IF ZERO 
	; 
MOUT:				MOV		R5,#'-' 
					SJMP	SOUT1				;OUTPUT A MINUS IF NOT 
	; 
ROUT:				MOV		R5,#'.'				;OUTPUT A RADIX 
					SJMP	SOUT1 
	; 
ZOUT:				MOV		R5,#'0'				;OUTPUT A ZERO 
					SJMP	SOUT1 
	; 
SOUT:				MOV		R5,#' '				;OUTPUT A SPACE 
	; 
SOUT1:				LJMP	R5OUT 
	; 
	;*************************************************************** 
	; 
CONVERT_ASCII_STRING_TO_BINARY: 
	; 
	;DPTR POINTS TO ASCII STRING 
	;PUT THE BINARY NUMBER IN R2:R0, ERROR IF >64K 
	; 
	;*************************************************************** 
	; 
CASB:				LCALL	HEXSCAN				;SEE IF HEX NUMBER 
					MOV		ADD_IN,C			;IF ADD_IN IS SET, THE NUMBER IS HEX 
					LCALL	GET_DIGIT_CHECK 
					CPL		C					;FLIP FOR EXIT 
					JC		RCASB 
					MOV		R3,#00H				;ZERO R3:R1 FOR LOOP 
					MOV		R1,#00H 
					SJMP	CASB5 
	; 
CASB2:				INC		DPTR 
					MOV		R0B0,R1				;SAVE THE PRESENT CONVERTED VALUE 
					MOV		R0B0+2,R3			;IN R2:R0 
					LCALL	GET_DIGIT_CHECK 
					JC		CASB5 
					JNB		ADD_IN,RCASB		;CONVERSION COMPLETE 
					LCALL	HEX_CHECK			;SEE IF HEX NUMBER 
					JC		CASB4				;PROCEED IF GOOD 
					INC		DPTR				;BUMP PAST H 
					SJMP	RCASB 
	; 
CASB4:				ADD		A,#9				;ADJUST HEX ASCII BIAS 
	; 
CASB5:				MOV		B,#10 
					JNB		ADD_IN,CASB6 
					MOV		B,#16				;HEX MODE 
	; 
CASB6:				ACALL	MULNUM				;ACCUMULATE THE DIGITS 
					JNC		CASB2				;LOOP IF NO CARRY 
	; 
RCASB:				CLR		A					;RESET ACC 
					MOV		ACC.OVERFLOW,C		;IF OVERFLOW, SAY SO 
					RET							;EXIT 
	; 
	; 
MULNUM10:			MOV		B,#10 
	; 
	;*************************************************************** 
	; 
MULNUM:	; Take the next digit in the acc (masked to 0FH) 
	; accumulate in R3:R1 
	; 
	;*************************************************************** 
	; 
					PUSH	ACC					;SAVE ACC 
					PUSH	B					;SAVE MULTIPLIER 
					MOV		A,R1				;PUT LOW ORDER BITS IN ACC 
					MUL		AB					;DO THE MULTIPLY 
					MOV		R1,A				;PUT THE RESULT BACK 
					MOV		A,R3				;GET THE HIGH ORDER BYTE 
					MOV		R3,B				;SAVE THE OVERFLOW 
					POP		B					;GET THE MULTIPLIER 
					MUL		AB					;DO IT 
					MOV		C,OV				;SAVE OVERFLOW IN F0 
					MOV		F0,C 
					ADD		A,R3				;ADD OVERFLOW TO HIGH RESULT 
					MOV		R3,A				;PUT IT BACK 
					POP		ACC					;GET THE ORIGINAL ACC BACK 
					ORL		C,F0				;OR CARRY AND OVERFLOW 
					JC		MULX				;NO GOOD IF THE CARRY IS SET 
	; 
MUL11:				ANL		A,#0FH				;MASK OFF HIGH ORDER BITS 
					ADD		A,R1				;NOW ADD THE ACC 
					MOV		R1,A				;PUT IT BACK 
					CLR		A					;PROPAGATE THE CARRY 
					ADDC	A,R3 
					MOV		R3,A				;PUT IT BACK 
	; 
MULX:				RET							;EXIT WITH OR WITHOUT CARRY 
	; 
	;*************************************************************** 
	; 
CONVERT_BINARY_TO_ASCII_STRING: 
	; 
	;R3:R1 contains the address of the string 
	;R2:R0 contains the value to convert 
	;DPTR, R7, R6, and ACC gets clobbered 
	; 
	;*************************************************************** 
	; 
					CLR		A					;NO LEADING ZEROS 
					MOV		DPTR,#10000			;SUBTRACT 10000 
					LCALL	RSUB				;DO THE SUBTRACTION 
					MOV		DPTR,#1000			;NOW 1000 
					LCALL	RSUB 
					MOV		DPTR,#100			;NOW 100 
					LCALL	RSUB 
					MOV		DPTR,#10			;NOW 10 
					LCALL	RSUB 
					MOV		DPTR,#1				;NOW 1 
					ACALL	RSUB 
					JZ		RSUB2				;JUMP OVER RET 
	; 
RSUB_R:				RET 
	; 
RSUB:				MOV		R6,#-1				;SET UP THE COUNTER 
	; 
RSUB1:				INC		R6					;BUMP THE COUNTER 
					XCH		A,R2				;DO A FAST COMPARE 
					CJNE	A,DPH,$+3 
					XCH		A,R2 
					JC		FAST_DONE 
					XCH		A,R0				;GET LOW BYTE 
					SUBB	A,DPL				;SUBTRACT, CARRY IS CLEARED 
					XCH		A,R0				;PUT IT BACK 
					XCH		A,R2				;GET THE HIGH BYTE 
					SUBB	A,DPH				;ADD THE HIGH BYTE 
					XCH		A,R2				;PUT IT BACK 
					JNC		RSUB1				;LOOP UNTIL CARRY 
	; 
					XCH		A,R0 
					ADD		A,DPL				;RESTORE R2:R0 
					XCH		A,R0 
					XCH		A,R2 
					ADDC	A,DPH 
					XCH		A,R2 
	; 
FAST_DONE: 
	; 
					ORL		A,R6				;OR THE COUNT VALUE 
					JZ		RSUB_R				;RETURN IF ZERO 
	; 
RSUB2:				MOV		A,#'0'				;GET THE ASCII BIAS 
					ADD		A,R6				;ADD THE COUNT 
	; 
RSUB4:				MOV		P2,R3				;SET UP P2 
					MOVX	@R1,A				;PLACE THE VALUE IN MEMORY 
					INC		R1 
					CJNE	R1,#00H,RSUB3		;SEE IF RAPPED AROUND 
					INC		R3					;BUMP HIGH BYTE 
	; 
RSUB3:				RET							;EXIT 
	; 
	;*************************************************************** 
	; 
FP_HEXOUT:	; Output the hex number in R3:R1, supress leading zeros, if set 
	; 
	;*************************************************************** 
	; 
					LCALL	SOUT				;OUTPUT A SPACE 
					MOV		C,ZSURP				;GET ZERO SUPPRESSION BIT 
					MOV		ADD_IN,C 
					MOV		A,R3				;GET HIGH NIBBLE AND PRINT IT 
					ACALL	HOUTHI 
					MOV		A,R3 
					ACALL	HOUTLO 
	; 
HEX2X:				CLR		ADD_IN				;DON'T SUPPRESS ZEROS 
					MOV		A,R1				;GET LOW NIBBLE AND PRINT IT 
					ACALL	HOUTHI 
					MOV		A,R1 
					ACALL	HOUTLO 
					MOV		R5,#'H'				;OUTPUT H TO INDICATE HEX MODE 
	; 
SOUT_1:				LJMP	SOUT1 
	; 
HOUT1:				CLR		ADD_IN				;PRINTED SOMETHING, SO CLEAR ADD_IN 
					ADD		A,#90H				;CONVERT TO ASCII 
					DA		A 
					ADDC	A,#40H 
					DA		A					;GOT IT HERE 
					MOV		R5,A				;OUTPUT THE BYTE 
					SJMP	SOUT_1 
	; 
HOUTHI:				SWAP	A					;SWAP TO OUTPUT HIGH NIBBLE 
	; 
HOUTLO:				ANL		A,#0FH				;STRIP 
					JNZ		HOUT1				;PRINT IF NOT ZERO 
					JNB		ADD_IN,HOUT1		;OUTPUT A ZERO IF NOT SUPRESSED 
					RET 
	; 
	; 
GET_DIGIT_CHECK:	; Get a character, then check for digit 
	; 
					LCALL	GET_DPTR_CHARACTER 
	; 
DIGIT_CHECK:	;CHECK FOR A VALID ASCII DIGIT, SET CARRY IF FOUND 
	; 
					CJNE	A,#'9'+1,$+3		;SEE IF ASCII 9 OR LESS 
					JC		DC1 
					RET 
	; 
DC1:				CJNE	A,#'0',$+3			;SEE IF ASCII 0 OR GREATER 
					CPL		C 
					RET 
	; 
 
R5OUT:				PUSH	ACC					; me 
					PUSH	00h
					MOV		R0,FPCHR_OUT
					MOV		A,R5				; me
					MOV		@R0,A
					INC		R0
					MOV		@R0,#00h
					MOV		FPCHR_OUT,R0
					POP		00h
					POP		ACC					; me 
					RET							; me 
 
SQ_ERR:				JMP	BADPRM					; me 
 
	;*************************************************************** 
	; 
IFIX:	; Convert a floating point number to an integer, put in R3:R1 
	; 
	;*************************************************************** 
	; 
					CLR		A					;RESET THE START 
					MOV		R3,A 
					MOV		R1,A 
					MOV		R0,ARG_STACK		;GET THE ARG STACK 
					MOV		P2,#ARG_STACK_PAGE 
					MOVX	A,@R0				;READ EXPONENT 
					CLR		C 
					SUBB	A,#81H				;BASE EXPONENT 
					MOV		R4,A				;SAVE IT 
					DEC		R0					;POINT AT SIGN 
					MOVX	A,@R0				;GET THE SIGN 
					JNZ		SQ_ERR				;ERROR IF NEGATIVE 
					JC		INC_ASTKA			;EXIT IF EXPONENT IS < 81H 
					INC		R4					;ADJUST LOOP COUNTER 
					MOV		A,R0				;BUMP THE POINTER REGISTER 
					SUBB	A,#FP_NUMBER_SIZE-1 
					MOV		R0,A 
	; 
I2:					INC		R0					;POINT AT DIGIT 
					MOVX	A,@R0				;GET DIGIT 
					SWAP	A					;FLIP 
					CALL	FP_BASE+20			;ACCUMULATE 
					JC		SQ_ERR 
					DJNZ	R4,$+4 
					SJMP	INC_ASTKA 
					MOVX	A,@R0				;GET DIGIT 
					CALL	FP_BASE+20 
					JC		SQ_ERR 
					DJNZ	R4,I2 
; 
; Pop the ARG STACK and check for overflow 
INC_ASTKA: 
					MOV		A,#FP_NUMBER_SIZE	;number to pop 
					SJMP	SETREG+1 
; 
;Push ARG STACK and check for underflow 
DEC_ASTKA: 
					MOV		A,#-FP_NUMBER_SIZE 
					ADD		A,ARG_STACK 
					CJNE	A,#0,$+3 
					JC		E4YY 
					MOV		ARG_STACK,A 
					MOV		R1,A 
					MOV		R3,#ARG_STACK_PAGE 
SRT:				RET 
; 
POPAS:				ACALL	INC_ASTKA 
					AJMP	VARCOP				;COPY THE VARIABLE 
; 
PUSHAS:				ACALL	DEC_ASTKA 
					AJMP	VARCOP 
; 
SETREG:				CLR		A					;DON'T POP ANYTHING 
					MOV		R0,ARG_STACK 
					MOV		R2,#ARG_STACK_PAGE 
					MOV		P2,R2 
					ADD		A,R0 
					JC		E4YY 
					MOV		ARG_STACK,A 
					MOVX	A,@R0 
A_D:				RET 
	; 
DEC3210:			DEC		R0					;BUMP THE POINTER 
					CJNE	R0,#0FFH,$+4		;SEE IF OVERFLOWED 
					DEC		R2					;BUMP THE HIGH BYTE 
					DEC		R1					;BUMP THE POINTER 
					CJNE	R1,#0FFH,DEC_R		;SEE IF OVERFLOWED 
					DEC		R3					;CHANGE THE HIGH BYTE 
DEC_R:				RET							;EXIT 
; 
 
 
;Routine to copy bottom arg on stack to address in DPTR. 
;Does not work over page boundaries. 
;Bugs fixed by JKJ/IRC 
MOVAS:  			ACALL   SETREG          	;SET UP R2:R0 
        			MOV     R3,DPH 
        			MOV     R1,DPL 
M_C:    			MOV     P2,R2       	    ;SET UP THE PORTS 
					MOVX	A,@R0				;READ THE VALUE 
					MOV		P2,R3				;PORT TIME AGAIN 
					MOVX	@R1,A				;SAVE IT 
        			INC     R0 
        			INC     R1 
        			DJNZ    R4,M_C          	;LOOP 
					RET							;EXIT 
 
 
; VARCOP - Copy a variable from R2:R0 to R3:R1 
VARCOP:				MOV		R4,#FP_NUMBER_SIZE	;LOAD THE LOOP COUNTER 
V_C:				MOV		P2,R2				;SET UP THE PORTS 
					MOVX	A,@R0				;READ THE VALUE 
					MOV		P2,R3				;PORT TIME AGAIN 
					MOVX	@R1,A				;SAVE IT 
        			ACALL   DEC3210 
					DJNZ	R4,V_C				;LOOP 
					RET							;EXIT 
; 
E4YY:				MOV		DPTR,#EXA 
					JMP		PRTERR				; me 
 
	; integer operator - INT 
AINT:				ACALL	SETREG				;SET UP THE REGISTERS, CLEAR CARRY 
					SUBB	A,#129				;SUBTRACT EXPONENT BIAS 
					JNC		AI1					;JUMP IF ACC > 81H 
	; 
	; Force the number to be a zero 
	; 
					ACALL	INC_ASTKA			;BUMP THE STACK 
	; 
P_Z:				MOV		DPTR,#ZRO			;PUT ZERO ON THE STACK 
					AJMP	PUSHC 
ZRO:				DB		0,0,0,0,0,0 
	; 
AI1:				SUBB	A,#7 
					JNC		AI3 
					CPL		A 
					INC		A 
					MOV		R3,A 
					DEC		R0					;POINT AT SIGN 
	; 
AI2:				DEC		R0					;NOW AT LSB'S 
					MOVX	A,@R0				;READ BYTE 
					ANL		A,#0F0H				;STRIP NIBBLE 
					MOVX	@R0,A				;WRITE BYTE 
					DJNZ	R3,$+3 
					RET 
					CLR		A 
					MOVX	@R0,A				;CLEAR THE LOCATION 
					DJNZ	R3,AI2 
AI3:				RET							;EXIT 
	; 
	; PUSHC - Push constant pointed by DPTR on to the arg stack 
PUSHC:				ACALL	DEC_ASTKA 
					MOV		P2,R3 
					MOV		R3,#FP_NUMBER_SIZE	;LOOP COUNTER 
PCL:				CLR		A					;SET UP A 
					MOVC	A,@A+DPTR			;LOAD IT 
					MOVX	@R1,A				;SAVE IT 
					INC		DPTR				;BUMP POINTERS 
					DEC		R1 
					DJNZ	R3,PCL				;LOOP 
					RET							;EXIT 
; 
 
EXA:				DB		'A-STACK',0 


;RS232 Output / Input
;-----------------------------------------------------
RXBYTE:
PUSH	IE
CLR	EA
		JNB	SCON.0,$
		CLR	SCON.0
		MOV	A,SBUF
POP	IE
		RET

TXBYTE:
PUSH	IE
CLR	EA
		MOV	SBUF,A
		JNB	SCON.1,$
		CLR	SCON.1
POP	IE
		RET

PRINTSTR:	MOV	A,@R0
		JZ	PRINTSTR1
		CJNE	A,#20h,$+3
		JNC	PRINTSTR0
		MOV		A,#'?'
PRINTSTR0:	ACALL	TXBYTE
		INC	R0
		SJMP	PRINTSTR
PRINTSTR1:	RET

PRINTDPTRSTR:	MOVX	A,@DPTR
		ACALL	TXBYTE
		INC	DPTR
		CJNE	A,#0Dh,PRINTDPTRSTR
		MOV	A,#0Ah
		ACALL	TXBYTE
		RET

HEXOUT:		PUSH	ACC
		SWAP	A
		ACALL	HEXOUT1
		POP	ACC
HEXOUT1:	ANL	A,#0Fh
		CLR	C
		SUBB	A,#0Ah
		JC	HEXOUT2
		ADD	A,#07h
HEXOUT2:	ADD	A,#3Ah
		ACALL	TXBYTE
		RET

HEXDUMPFP:	MOV	A,ARG_STACK
		CLR	C
		SUBB	A,#05h
		MOV	DPL,A
		MOV	DPH,#ARG_STACK_PAGE
		MOV	R7,#06h
HEXDUMPFP1:	MOVX	A,@DPTR
		ACALL	HEXOUT
		INC	DPL
		DJNZ	R7,HEXDUMPFP1
		MOV	A,#0Dh
		ACALL	TXBYTE
		MOV	A,#0Ah
		ACALL	TXBYTE
		RET

;In		DPTR Points to DMEM location
;		R2:R0 Points to CMEM location
;		R3 is the number of bytes to move
CMEM2DMEM:	PUSH	DPL
		PUSH	DPH
		MOV	DPL,R0
		MOV	DPH,R2
		CLR	A
		MOVC	A,@A+DPTR
		INC	DPTR
		MOV	R0,DPL
		MOV	R2,DPH
		POP	DPH
		POP	DPL
		MOVX	@DPTR,A
		INC	DPTR
		DJNZ	R3,CMEM2DMEM
		RET


ADCMUL:		DB 7Eh,00h,79h,07h,03h,16h	;CH0	1.6030779e-3
		DB 7Eh,00h,79h,07h,03h,16h	;CH1	1.6030779e-3
		DB 7Eh,00h,79h,07h,03h,16h	;CH2	1.6030779e-3
		DB 7Eh,00h,79h,07h,03h,16h	;CH3	1.6030779e-3

SINGLESTEP:	PUSH	PSW
                PUSH	ACC
                CLR	RS0
                CLR	RS1
                PUSH	00h
                MOV	A,#07h
                LCALL	TXBYTE
                MOV	R0,SP
                DEC	R0
                DEC	R0
                DEC	R0
                MOV	A,@R0			;MSB adress
                LCALL	TXBYTE
                DEC	R0
                MOV	A,@R0			;LSB adress
                LCALL	TXBYTE
                INC	R0			;MSB adress
                INC	R0			;PSW
                MOV	A,@R0			;PSW
                LCALL	TXBYTE
                INC	R0			;ACC
                MOV	A,@R0			;ACC
                LCALL	TXBYTE
                MOV	A,B			;B
                LCALL	TXBYTE
                MOV	A,SP			;SP
                LCALL	TXBYTE
                MOV	A,DPL			;DPL
                LCALL	TXBYTE
                MOV	A,DPH			;DPH
                LCALL	TXBYTE
                INC	R0			;R0
                MOV	A,@R0			;R0
                LCALL	TXBYTE
                MOV	R0,#01h
SINGLESTEP1:	MOV	A,@R0			;31 Bytes
                LCALL	TXBYTE
                INC	R0
                CJNE	R0,#20h,SINGLESTEP1
                PUSH	DPL
                PUSH	DPH
		MOV	R0,#20h			;32 Bytes
SINGLESTEP2:	MOVX	A,@DPTR
                LCALL	TXBYTE
                INC	DPTR
                DJNZ	R0,SINGLESTEP2
		POP	DPH
		POP	DPL
SINGLESTEP3:	LCALL	RXBYTE
                CJNE	A,#'R',SINGLESTEP4	;R Run
		SETB	P3.3
SINGLESTEP4:	CJNE	A,#'S',SINGLESTEP5	;S Stop
		SETB	P3.3
		CLR	20h.2
		CLR	20h.7
		CLR	EA
		CLR	EX1			;Disable external interrupt 1, INT1 #
                LJMP	0000h
SINGLESTEP5:	CJNE	A,#'i',SINGLESTEP3	;i Step into
                POP	00h
                POP	ACC
                POP	PSW
                RETI

		END
