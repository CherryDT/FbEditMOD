$NOPAGING
$PAGEWIDTH (250) ;250 columns per line
$NOTABS          ;expand tabs
$NOSYMBOLS

$INCLUDE	(MCU.inc)

DEVMODE		EQU 0
DEBUG		EQU 0

IF DEVMODE=0
;RESET:***********************************************
		ORG	0000h
		LJMP	START0
;IE0IRQ:**********************************************
		ORG	0003h
		AJMP	IE0IRQ
;TF0IRQ:**********************************************
		ORG	000Bh
		JB	INTBITS.1,$+4
		RETI
		LJMP	200Bh
;IE1IRQ:**********************************************
		ORG	0013h
		AJMP	IE1IRQ
;TF1IRQ:**********************************************
		ORG	001Bh
		JB	INTBITS.3,$+4
		RETI
		LJMP	201Bh
;RITIIRQ:*********************************************
		ORG	0023h
		JB	INTBITS.4,$+4
		RETI
		LJMP	2023h
;TF2EXF2IRQ:******************************************
		ORG	002Bh
		JB	INTBITS.5,$+4
		RETI
		LJMP	202Bh
;*****************************************************
IE0IRQ:		JB	INTBITS.0,IE0IRQ1
		DEC	MODE
		ACALL	SETMODE
		ACALL	DEBOUNCEINT0
		LJMP	START
IE0IRQ1:	LJMP	2003h

IE1IRQ:		JB	INTBITS.2,IE1IRQ1
		JB	INTBITS.7,IE1IRQ2
		INC	MODE
		ACALL	SETMODE
		ACALL	DEBOUNCEINT1
		LJMP	START
IE1IRQ1:	LJMP	2013h
IE1IRQ2:	LJMP	SINGLESTEP

ELSE
;RESET:***********************************************
		ORG	2000h
		LJMP	START0
;IE0IRQ:**********************************************
		ORG	2003h
		AJMP	IE0IRQ
;TF0IRQ:**********************************************
		ORG	200Bh
		RETI
;IE1IRQ:**********************************************
		ORG	2013h
		AJMP	IE1IRQ
;TF1IRQ:**********************************************
		ORG	201Bh
		RETI
;RITIIRQ:*********************************************
		ORG	2023h
		RETI
;TF2EXF2IRQ:******************************************
		ORG	202Bh
		RETI
;*****************************************************
IE0IRQ:		DEC	MODE
		ACALL	SETMODE
		ACALL	DEBOUNCEINT0
		LJMP	START

IE1IRQ:		JB	INTBITS.7,IE1IRQ2
		INC	MODE
		ACALL	SETMODE
		ACALL	DEBOUNCEINT1
		LJMP	START
IE1IRQ2:	LJMP	SINGLESTEP

ENDIF

DEBOUNCEINT0:	MOV	R6,#00h
		MOV	R7,#00h
DEBOUNCEINT01:	JNB	P3.2,DEBOUNCEINT0
		DJNZ	R6,DEBOUNCEINT01
		DJNZ	R7,DEBOUNCEINT01
		CLR	IE0
		RETI

DEBOUNCEINT1:	MOV	R6,#00h
		MOV	R7,#00h
DEBOUNCEINT11:	JNB	P3.3,DEBOUNCEINT1
		DJNZ	R6,DEBOUNCEINT11
		DJNZ	R7,DEBOUNCEINT11
		CLR	IE1
		RETI

SETMODE:	MOV	A,MODE
		CJNE	A,#0FFh,SETMODE1
		MOV	A,#MODEMAX
SETMODE1:	CJNE	A,#MODEMAX+1,SETMODE2
		CLR	A
SETMODE2:	MOV	MODE,A
		MOV	R7,A
		MOV	DPTR,#MODE0
		DJNZ	R7,SETMODE3
		MOV	DPTR,#MODE1
SETMODE3:	DJNZ	R7,SETMODE4
		MOV	DPTR,#MODE2
SETMODE4:	DJNZ	R7,SETMODE5
		MOV	DPTR,#MODE3
SETMODE5:	DJNZ	R7,SETMODE6
		MOV	DPTR,#MODE4
SETMODE6:	DJNZ	R7,SETMODE7
		MOV	DPTR,#MODE5
SETMODE7:	DJNZ	R7,SETMODE8
		MOV	DPTR,#MODE6
SETMODE8:	DJNZ	R7,SETMODE9
		MOV	DPTR,#MODE7
SETMODE9:	DJNZ	R7,SETMODE10
		MOV	DPTR,#MODE8
SETMODE10:	DJNZ	R7,SETMODE11
		MOV	DPTR,#MODE9
SETMODE11:	DJNZ	R7,SETMODE12
		MOV	DPTR,#MODE10
SETMODE12:	LCALL	LCDCLEAR
		LCALL	PRNTCDPTRLCD
		RET

IF DEVMODE=0
		ORG	00C0h
ELSE
		ORG	20C0h
ENDIF

$INCLUDE	(FP52.a51)

;------------------------------------------------------------------

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

;Get LC meter frquency
;IN:	A Port #8000h value, R3:R1 points to FP buffer
;OUT:	Nothing
LCMETERGETFRQ:	PUSH	03h				;Save R3
		PUSH	01h				;Save R1
		MOV	DPTR,#8000h
		MOVX	@DPTR,A				;D7, D6
		MOV	A,#250
		LCALL	WAIT				;Wait 25ms for relay to kick in / out
		MOV	A,#250
		LCALL	WAIT				;Wait 25ms for relay to kick in / out
		MOV	A,#02h				;CH2, LC Meter
		LCALL	FRQCOUNT
		MOV	R0,#LCDLINE
		LCALL	BIN2DEC
		MOV	R0,#LCDLINE
		MOV	DPTR,#CONVT
		MOV	R7,#0Ah
LCMETERGETFRQ1:	MOV	A,@R0
		MOVX	@DPTR,A
		INC	R0
		INC	DPTR
		DJNZ	R7,LCMETERGETFRQ1
		MOV	A,#0Dh
		MOVX	@DPTR,A
		MOV	DPTR,#CONVT
		LCALL	FLOATING_POINT_INPUT
		POP	01h				;Restore R1
		POP	03H				;Restore R3
		LCALL	POPAS				;POP ARGUMENT TO R3:R1
		RET

;Calculate X=((Fa/Fb)^2)-1
;IN:	Fa=R2:R0, Fb=R3:R1
;OUT:	Nothing
LCCALC:		PUSH	01h
		PUSH	03h
		LCALL	PUSHAS				; PUSH R2:R0 TO ARGUMENT
		POP	02h
		POP	00h
		LCALL	PUSHAS				; PUSH R2:R0 TO ARGUMENT
		LCALL	FLOATING_DIV
		MOV	R0,ARG_STACK
		MOV	R2,#ARG_STACK_PAGE
		LCALL	PUSHAS				; PUSH R2:R0 TO ARGUMENT
		LCALL	FLOATING_MUL
		MOV	DPTR,#FPONE
		LCALL	PUSHC				; PUSH ARG IN DPTR TO STACK
		LCALL	FLOATING_SUB
		RET

;Get LC meter frquency F1 and F2. Calculatr LCCA=((F1/F2)^2)-1 and LCCB=LCCA*((1/(2*Pi*F1))^2)*(1/Ccal)
;IN:	Nothing
;OUT:	Nothing
LCMETERINIT:	MOV	A,#00h				;D6 LC Meter	0=C, 1=L
							;D7 LC Meter	0=F1, 1=F2 (Adding C Cal)
		MOV	DPTR,#8000h
		MOVX	@DPTR,A				;D7, D6
		LCALL	LCDCLEAR
		LCALL	PRNTCSTRLCD
		DB	'Calibrating',0
		MOV	R7,#05h
LCMETERINIT1:	PUSH	07h
		LCALL	WAITASEC
		MOV	A,#'.'
		LCALL	LCDCHROUT
		POP	07h
		DJNZ	R7,LCMETERINIT1
		MOV	A,#00h				;D6 LC Meter	0=C, 1=L
							;D7 LC Meter	0=F1, 1=F2 (Adding C Cal)
		MOV	R1,#LOW LCF1
		MOV	R3,#HIGH LCF1
		LCALL	LCMETERGETFRQ			;Get F1
		MOV	A,#80h				;D6 LC Meter	0=C, 1=L
							;D7 LC Meter	0=F1, 1=F2 (Adding C Cal)
		MOV	R1,#LOW LCF2
		MOV	R3,#HIGH LCF2
		LCALL	LCMETERGETFRQ			;Get F2
		;Calculate LCCA=((F1/F2)^2)-1
		MOV	R0,#LOW LCF1
		MOV	R2,#HIGH LCF1
		MOV	R1,#LOW LCF2
		MOV	R3,#HIGH LCF2
		LCALL	LCCALC
		;Save result to LCCA
		MOV	R1,#LOW LCCA
		MOV	R3,#HIGH LCCA
		LCALL	POPAS				;POP ARGUMENT TO R3:R1
		;Calculate A=(1/(2*Pi*F1))^2
		MOV	DPTR,#FPTWO
		LCALL	PUSHC				;PUSH ARG IN DPTR TO STACK
		MOV	DPTR,#FPPI
		LCALL	PUSHC				;PUSH ARG IN DPTR TO STACK
		LCALL	FLOATING_MUL
		MOV	R0,#LOW LCF1
		MOV	R2,#HIGH LCF1
		LCALL	PUSHAS				;PUSH R2:R0 TO ARGUMENT
		LCALL	FLOATING_MUL
		MOV	R1,#LOW LCCT
		MOV	R3,#HIGH LCCT
		LCALL	POPAS				;POP ARGUMENT TO R3:R1
		MOV	DPTR,#FPONE
		LCALL	PUSHC				;PUSH ARG IN DPTR TO STACK
		MOV	R0,#LOW LCCT
		MOV	R2,#HIGH LCCT
		LCALL	PUSHAS				;PUSH R2:R0 TO ARGUMENT
		LCALL	FLOATING_DIV
		MOV	R0,ARG_STACK
		MOV	R2,#ARG_STACK_PAGE
		LCALL	PUSHAS				;PUSH R2:R0 TO ARGUMENT
		LCALL	FLOATING_MUL
		;Calculate LCCB=A*LCCA*(1/Ccal)
		MOV	R0,#LOW LCCA
		MOV	R2,#HIGH LCCA
		LCALL	PUSHAS				;PUSH R2:R0 TO ARGUMENT
		LCALL	FLOATING_MUL
		MOV	DPTR,#FPCCAL
		LCALL	PUSHC				;PUSH ARG IN DPTR TO STACK
		LCALL	FLOATING_DIV
		;Save result to LCCB
		MOV	R1,#LOW LCCB
		MOV	R3,#HIGH LCCB
		LCALL	POPAS				;POP ARGUMENT TO R3:R1
		CLR	A
		MOV	DPTR,#8000h
		MOVX	@DPTR,A				;D7, D6
		LCALL	LCDCLEAR
		RET

;Inductance meter Lx=((F1/F3)^2)-1)*((F1/F2)^2)-1)*((1/(2*Pi*F1))^2)*(1/Ccal)
;IN:	Nothing
;OUT:	Nothing
LMETER:		MOV	A,#40h				;D6 LC Meter	0=C, 1=L
		MOV	OUTD7D6,A
							;D7 LC Meter	0=F1, 1=F2 (Adding C Cal)
		MOV	R1,#LOW LCF3
		MOV	R3,#HIGH LCF3
		LCALL	LCMETERGETFRQ			;Get F3
		;Calculate A=((F1/F3)^2)-1
		MOV	R0,#LOW LCF1
		MOV	R2,#HIGH LCF1
		MOV	R1,#LOW LCF3
		MOV	R3,#HIGH LCF3
		LCALL	LCCALC
		;Calculate B=A*LCCB
		MOV	R0,#LOW LCCB
		MOV	R2,#HIGH LCCB
		LCALL	PUSHAS				;PUSH R2:R0 TO ARGUMENT
		LCALL	FLOATING_MUL
		MOV	DPL,ARG_STACK
		MOV	DPH,#ARG_STACK_PAGE
		DEC	DPL
		MOVX	A,@DPTR
		INC	DPL
		JZ	LMETER1
		CLR	A
		MOVX	@DPTR,A
LMETER1:	MOVX	A,@DPTR
		CJNE	A,#80h,$+3
		JC	LMETER2
		CLR	A
		MOVX	@DPTR,A
LMETER2:	MOV	LCDLINE+14,#'n'
		MOV	DPTR,#FPN
		JZ	LMETER3
		CJNE	A,#7Bh,$+3
		JC	LMETER3
		MOV	LCDLINE+14,#'u'
		MOV	DPTR,#FPU
		CJNE	A,#7Eh,$+3
		JC	LMETER3
		MOV	LCDLINE+14,#'m'
		MOV	DPTR,#FPM
LMETER3:	LCALL	PUSHC				;PUSH ARG IN DPTR TO STACK
		LCALL	FLOATING_MUL
		MOV	LCDLINE,#'L'
		MOV	LCDLINE+1,#' '
		MOV	LCDLINE+2,#'='
		MOV	LCDLINE+3,#' '
		MOV	LCDLINE+15,#'H'
		MOV	FPCHR_OUT,#LCDLINE+4
		MOV	FORMAT,#53h
		MOV	A,ARG_STACK
		CLR	C
		SUBB	A,#05h
		MOV	R0,A
		LCALL	FLOATING_POINT_OUTPUT
		MOV	A,#00h
		LCALL	LCDSETADR
		MOV	R0,#LCDLINE
		MOV	R7,#10h
		LCALL	PRINTSTR
		LJMP	START

;Capacitance meter: Cx=((F1/F3)^2)-1)/((F1/F2)^2)-1)*Ccal
;IN:	Nothing
;OUT:	Nothing
CMETER:		MOV	A,#00h				;D6 LC Meter	0=C, 1=L
							;D7 LC Meter	0=F1, 1=F2 (Adding C Cal)
		MOV	OUTD7D6,A
		MOV	R1,#LOW LCF3
		MOV	R3,#HIGH LCF3
		LCALL	LCMETERGETFRQ			;Get F3
		;Calculate A=((F1/F3)^2)-1
		MOV	R0,#LOW LCF1
		MOV	R2,#HIGH LCF1
		MOV	R1,#LOW LCF3
		MOV	R3,#HIGH LCF3
		LCALL	LCCALC
		;Calculate B=A/LCCA
		MOV	R0,#LOW LCCA
		MOV	R2,#HIGH LCCA
		LCALL	PUSHAS				;PUSH R2:R0 TO ARGUMENT
		LCALL	FLOATING_DIV
		;Calculate Cx=A/B*Ccal
		MOV	DPTR,#FPCCAL
		LCALL	PUSHC				;PUSH ARG IN DPTR TO STACK
		LCALL	FLOATING_MUL
		MOV	DPL,ARG_STACK
		MOV	DPH,#ARG_STACK_PAGE
		DEC	DPL
		MOVX	A,@DPTR
		INC	DPL
		JZ	CMETER1
		CLR	A
		MOVX	@DPTR,A
CMETER1:	MOVX	A,@DPTR
		MOV	LCDLINE+14,#'p'
		MOV	DPTR,#FPP
		JZ	CMETER2
		CJNE	A,#78h,$+3
		JC	CMETER2
		MOV	LCDLINE+14,#'n'
		MOV	DPTR,#FPN
CMETER2:	LCALL	PUSHC				;PUSH ARG IN DPTR TO STACK
		LCALL	FLOATING_MUL
		MOV	LCDLINE,#'C'
		MOV	LCDLINE+1,#' '
		MOV	LCDLINE+2,#'='
		MOV	LCDLINE+3,#' '
		MOV	LCDLINE+15,#'F'
		MOV	FPCHR_OUT,#LCDLINE+4
		MOV	FORMAT,#53h
		MOV	A,ARG_STACK
		CLR	C
		SUBB	A,#05h
		MOV	R0,A
		LCALL	FLOATING_POINT_OUTPUT
		MOV	A,#00h
		LCALL	LCDSETADR
		MOV	R0,#LCDLINE
		MOV	R7,#10h
		LCALL	PRINTSTR
		LJMP	START

;------------------------------------------------------------------

;Wait loop. Waits 1 second
;-----------------------------------------------------
WAITASEC:	MOV	R7,#0F8h
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
FRQCOUNT:	ORL	A,#7Ch				;D0,D1	CHANNEL (0-3)
							;D2     FRQ     Gate active low
							;D3     FRQ     Reset active high
							;D4     ADC     CS Active low
							;D5     ADC     CLK High to Low transition
							;D6     ADC     DIN
							;D7	FRQ TTL	 Active high
		MOV	DPTR,#8001h
		MOVX	@DPTR,A				;Reset and gate off
		PUSH	ACC
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
		POP	ACC
		ANL	A,#0F3h				;D2	FRQ Gate active low
							;D3	FRQ Reset active high
		MOVX	@DPTR,A				;Gate on(low),Reset inactive (low)
		ACALL	WAITASEC
		SETB	ACC.2				;D2	FRQ Gate active low
		MOVX	@DPTR,A				;Stop counting
		MOVX	A,@DPTR
		MOV	R4,A
		MOV	A,TL0
		MOV	R5,A
		MOV	A,TH0
		MOV	R6,A
		CLR	A				;TF0 Is the 25th bit
		MOV	C,TF0
		RLC	A
		MOV	R7,A
		RET

;Format frequency conter text line
;IN:	A holds channel (0 to 3)
;	LCDLINE+4 Decimal result
;	R7 Number of digits
;OUT:	Formatted LCDLINE
FRQFORMAT:	MOV	LCDLINE,#'C'
		MOV	LCDLINE+1,#'H'
		ORL	A,#30h
		MOV	LCDLINE+2,A
		MOV	LCDLINE+3,#' '
		MOV	R0,#LCDLINE+4
		MOV	R1,#LCDLINE+6
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
		MOV	LCDLINE+13,#'M'
		MOV	LCDLINE+14,#'H'
		MOV	LCDLINE+15,#'z'
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
		MOV	LCDLINE+13,#'K'
		MOV	LCDLINE+14,#'H'
		MOV	LCDLINE+15,#'z'
		SJMP	FRQFORMATDONE
FRQFORMATHZ:	;Hz
		MOV	LCDLINE+4,#' '
		INC	R0
		MOV	R7,#08h
FRQFORMATHZ1:	MOV	A,@R1
		MOV	@R0,A
		INC	R0
		INC	R1
		DJNZ	R7,FRQFORMATHZ1
		MOV	LCDLINE+13,#'H'
		MOV	LCDLINE+14,#'z'
		MOV	LCDLINE+15,#' '
FRQFORMATDONE:	RET

;Frequency conter and AD Converter channel 0 and 5
;IN:	Frequency cont channel (0-3)
;OUT:	Nothing
FREQENCYCOUNT:	PUSH	ACC
		LCALL	FRQCOUNT
		MOV	R0,#LCDLINE+4			;Decimal buffer
		LCALL	BIN2DEC
		MOV	R7,A				;Number of digits
		POP	ACC
		ANL	A,#03h
		LCALL	FRQFORMAT
		MOV	A,#00h
		LCALL	LCDSETADR
		MOV	R0,#LCDLINE			;Output result
		MOV	R7,#10h
		LCALL	PRINTSTR
		MOV	A,#00h				;ADC Channel 0
		LCALL	ADCONVERT
		MOV	A,#00h
		MOV	R1,#LCDLINE+4
		MOV	FORMAT,#22h
		LCALL	ADOUTPUT
		MOV	A,#05h				;ADC Channel 5
		LCALL	ADCONVERT
		MOV	A,R0
		CLR	C
		SUBB	A,#73h
		MOV	R0,A
		MOV	A,R2
		SUBB	A,#00h
		JNC	FREQENCYCOUNT1
		CLR	A
		MOV	R0,A
FREQENCYCOUNT1:	MOV	R2,A
		MOV	A,#05h
		MOV	R1,#LCDLINE+10
		MOV	FORMAT,#13h
		LCALL	ADOUTPUT
		MOV	LCDLINE,#'V'			;Output result
		MOV	LCDLINE+1,#'A'
		MOV	LCDLINE+2,#'R'
		MOV	LCDLINE+3,#' '
		MOV	A,#40h
		LCALL	LCDSETADR
		MOV	R0,#LCDLINE
		MOV	R7,#10h
		LCALL	PRINTSTR
		LJMP	START

;------------------------------------------------------------------

;AD Converter.
;IN:	A holds channel (0 to 7).
;OUT:	R2:R0 Holds 16 Bit result
;-----------------------------------------------------
ADCONVERT:	ORL	A,#18h				;START, SINGLE ENDED
		RL	A
		RL	A
		RL	A
		MOV	R2,A
		MOV	A,#7Ch				;D0,D1 FRQ SEL
							;D2 FRQ GATE	ACTIVE LOW
							;D3 FRQ RESET	ACTIVE HIGH
							;D4 ADC CS	ACTIVE LOW
							;D5 ADC CLK	HIGH TO LOW TRANSITION
							;D6 ADC DIN	START,S/D,D2,D1,D0
							;D7 FRQ TTL	ACTIVE HIGH
		MOV	DPTR,#8001h
		MOVX	@DPTR,A
		;CS low
		CLR	ACC.4				;D4 ADC CS	ACTIVE LOW
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
ADCONVERT3:	PUSH	ACC
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
		MOVX	@DPTR,A
		DJNZ	R7,ADCONVERT3
		RET

;AD Converter output
;IN:	A holds channel (0 to 7).
;	R2:R0 adc result
;	R1 pointer to buffer
;OUT:	6 Characters
;-----------------------------------------------------
ADOUTPUT:	MOV	FPCHR_OUT,R1
		PUSH	ACC
		;Convert 16 bit integer in R2:R0 to float and push it to fp arg stack
		LCALL	PUSHR2R0
		;Push the channelS constant to fp arg stack
		MOV	DPTR,#ADCMUL
		POP	ACC
		MOV	B,#FP_NUMBER_SIZE
		MUL	AB
		ADD	A,DPL
		MOV	DPL,A
		JNC	ADOUTPUT1
		INC	DPH
ADOUTPUT1:	LCALL	PUSHC
		;Multiply
		LCALL	FLOATING_MUL
		MOV	A,ARG_STACK
		CLR	C
		SUBB	A,#05h
		MOV	R0,A
		LCALL	FLOATING_POINT_OUTPUT
		RET

;AD Converter
;IN:	Nothing
;OUT:	Nothing
ADCONVERTERINT:	MOV	A,#03h				;Channel 3
		LCALL	ADCONVERT
		MOV	A,#03h
		MOV	R1,#LCDLINE+4
		MOV	FORMAT,#22h
		LCALL	ADOUTPUT
		MOV	A,#07h				;Channel 7
		LCALL	ADCONVERT
		MOV	A,#07h
		MOV	R1,#LCDLINE+10
		MOV	FORMAT,#13h
		LCALL	ADOUTPUT
		MOV	LCDLINE,#'I'			;Output result
		MOV	LCDLINE+1,#'N'
		MOV	LCDLINE+2,#'T'
		MOV	LCDLINE+3,#' '
		MOV	A,#00h
		LCALL	LCDSETADR
		MOV	R0,#LCDLINE
		MOV	R7,#10h
		LCALL	PRINTSTR
		MOV	A,#02h				;Channel 2
		LCALL	ADCONVERT
		MOV	A,#02h
		MOV	R1,#LCDLINE+4
		MOV	FORMAT,#22h
		LCALL	ADOUTPUT
		MOV	A,#06h				;Channel 6
		LCALL	ADCONVERT
		MOV	A,#06h
		MOV	R1,#LCDLINE+10
		MOV	FORMAT,#13h
		LCALL	ADOUTPUT
		MOV	LCDLINE,#'I'			;Output result
		MOV	LCDLINE+1,#'N'
		MOV	LCDLINE+2,#'T'
		MOV	LCDLINE+3,#' '
		MOV	A,#40h
		LCALL	LCDSETADR
		MOV	R0,#LCDLINE
		MOV	R7,#10h
		LCALL	PRINTSTR
		MOV	R7,#14h
ADCONVERTERINT1:MOV	A,#250
		LCALL	WAIT				;Wait 25ms for relay to kick in / out
		DJNZ	R7,ADCONVERTERINT1
		LJMP	START

ADCONVERTEREXT:	MOV	A,#01h				;Channel 1
		LCALL	ADCONVERT
		MOV	A,#01h
		MOV	R1,#LCDLINE+4
		MOV	FORMAT,#22h
		LCALL	ADOUTPUT
		MOV	A,#04h				;Channel 4
		LCALL	ADCONVERT
		MOV	A,R0
		CLR	C
		SUBB	A,#73h
		MOV	R0,A
		MOV	A,R2
		SUBB	A,#00h
		JNC	ADCONVEXT
		CLR	A
		MOV	R0,A
ADCONVEXT:	MOV	R2,A
		MOV	A,#04h
		MOV	R1,#LCDLINE+10
		MOV	FORMAT,#13h
		LCALL	ADOUTPUT
		MOV	LCDLINE,#'E'			;Output result
		MOV	LCDLINE+1,#'X'
		MOV	LCDLINE+2,#'T'
		MOV	LCDLINE+3,#' '
		MOV	A,#00h
		LCALL	LCDSETADR
		MOV	R0,#LCDLINE
		MOV	R7,#10h
		LCALL	PRINTSTR
		MOV	A,#00h				;Channel 0
		LCALL	ADCONVERT
		MOV	A,#00h
		MOV	R1,#LCDLINE+4
		MOV	FORMAT,#22h
		LCALL	ADOUTPUT
		MOV	A,#05h				;Channel 5
		LCALL	ADCONVERT
		MOV	A,R0
		CLR	C
		SUBB	A,#73h
		MOV	R0,A
		MOV	A,R2
		SUBB	A,#00h
		JNC	ADCONVEXT1
		CLR	A
		MOV	R0,A
ADCONVEXT1:	MOV	R2,A
		MOV	A,#05h
		MOV	R1,#LCDLINE+10
		MOV	FORMAT,#13h
		LCALL	ADOUTPUT
		MOV	LCDLINE,#'V'			;Output result
		MOV	LCDLINE+1,#'A'
		MOV	LCDLINE+2,#'R'
		MOV	LCDLINE+3,#' '
		MOV	A,#40h
		LCALL	LCDSETADR
		MOV	R0,#LCDLINE
		MOV	R7,#10h
		LCALL	PRINTSTR
		MOV	R7,#14h
ADCONVERTEREXT1:MOV	A,#250
		LCALL	WAIT				;Wait 25ms for relay to kick in / out
		DJNZ	R7,ADCONVERTEREXT1
		LJMP	START

;------------------------------------------------------------------
ADCMUL:		DB 7Eh,00h,00h,07h,03h,52h		;CH0
		DB 7Eh,00h,00h,07h,03h,16h		;CH1
		DB 7Eh,00h,00h,00h,02h,36h		;CH2
		DB 7Eh,00h,00h,07h,03h,16h		;CH3
		DB 7Dh,00h,00h,00h,50h,30h		;CH4
		DB 7Dh,00h,00h,00h,50h,30h		;CH5
		DB 00h,00h,00h,00h,00h,00h		;CH6
		DB 00h,00h,00h,00h,00h,00h		;CH7
;------------------------------------------------------------------
FPONE:		DB 81h,00h,00h,00h,00h,10h		;1.0000000
FPTWO:		DB 81h,00h,00h,00h,00h,20h		;2.0000000
FPPI:		DB 81h,00h,27h,59h,41h,31h		;3.1415927
FPCCAL:		DB 77h,00h,00h,00h,50h,94h		;1nF=1e-9
FPP:		DB 8Dh,00h,00h,00h,00h,10h		;1e12
FPN:		DB 8Ah,00h,00h,00h,00h,10h		;1e9
FPU:		DB 87h,00h,00h,00h,00h,10h		;1e6
FPM:		DB 84h,00h,00h,00h,00h,10h		;1e3
;------------------------------------------------------------------

MODE0:		DB 'Terminal',0
MODE1:		DB 'Frq Count',0
MODE2:		DB 'Frq Count TTL',0
MODE3:		DB 'Frq Count FG',0
MODE4:		DB 'Frq Count LC',0
MODE5:		DB 'Frq Count ALE',0
MODE6:		DB 'Volts INT',0
MODE7:		DB 'Volts EXT',0
MODE8:		DB 'L Meter',0
MODE9:		DB 'C Meter',0
MODE10:		DB 'Calibrate',0

IF DEVMODE=0
		ORG	1000h
ELSE
		ORG	3000h
ENDIF

START0:		CLR	A
		MOV	IE,A				;Disable all interrupts
		MOV	MODE,A				;Set mode to RS232 Terminal
		MOV	OUTD7D6,A
		MOV	INTBITS,A			;RAM int routines (.0-.5 INTERRUPTS, .6=LCD OUT, .7 Single step)
		DEC	A
		MOV	SSADRLSB,A			;Single step adress
		MOV	SSADRMSB,A			;Single step adress
		MOV	P3,A				;All bits input
		MOV	RCAP2L,#0D9h			;19200bps with 24MHz OSC
		MOV	RCAP2H,A
		MOV	TL2,#0D9h
		MOV	TH2,A
		MOV	T2CON,#34h			;TF2=l
							;EXF2=l
							;RCLK=h
							;TCLK=h
							;EXEN2=l
							;TR2=h
							;C/T2#=l
							;CP/RL2#=l
		MOV	SCON,#50h			;SM0=l
							;SM1=h
							;SM2=l
							;REN=h
							;TB8=l
							;RB8=l
							;TI=l
							;RI=l
		MOV	ROMACTION,#01h			;Action
		MOV	ROMSIZE,#02h			;Size
		MOV	ROMMODE,#01h			;Mode

		SETB	EX0				;Enable INT0
		SETB	EX1				;Enable INT1
		SETB	EA				;Enable interrupts
		LCALL	LCDINIT
		LCALL	LCMETERINIT
		LCALL	SETMODE

IF DEVMODE=1
		MOV	INTBITS,#3Fh			;Redirect all interrupts, Output to LCD
	IF DEBUG=1
		SETB	INTBITS.7			;Set single step flag
		CLR	IT1				;Level triggered
		CLR	P3.3				;Pull INT1 low
		NOP
		NOP
	ENDIF
ENDIF

START:		MOV	SP,#0CFh			;Init stack pointer. The stack is 48 bytes
		MOV	DPTR,#2000h
IF DEVMODE=1
		JNB	RI,START01
		MOV	INTBITS,#00h			;Redirect no interrupts
		LJMP	0000h
START01:
ENDIF

		MOV	ARG_STACK,#80h
		MOV	A,MODE
		MOV	R7,A
		JNZ	START1
		AJMP	TERMINAL			;RS232 Terminal
START1:		DJNZ	R7,START2
		CLR	A				;Frequency counter channel0. External, Amplified
		LJMP	FREQENCYCOUNT
START2:		DJNZ	R7,START3			;Frequency counter channel0. External, TTL Level
		MOV	A,#80h
		LJMP	FREQENCYCOUNT
START3:		DJNZ	R7,START4
		MOV	A,#01h				;Frequency counter channel1. Function generator
		LJMP	FREQENCYCOUNT
START4:		DJNZ	R7,START5
		MOV	A,#02h				;Frequency counter channel2. LC Meter
		LJMP	FREQENCYCOUNT
START5:		DJNZ	R7,START6
		MOV	A,#03h				;Frequency counter channel3. ALE
		LJMP	FREQENCYCOUNT
START6:		DJNZ	R7,START7
		LJMP	ADCONVERTERINT			;AD Coverter Internal PSU
START7:		DJNZ	R7,START8
		LJMP	ADCONVERTEREXT			;AD Coverter External PSU
START8:		DJNZ	R7,START9
		LJMP	LMETER				;Inductance
START9:		DJNZ	R7,START10
		LJMP	CMETER				;Capacitance
START10:	LCALL	LCMETERINIT			;Calibrate
		SJMP	START

;------------------------------------------------------------------

;RS232 Terminal
;IN:	Nothing
;OUT:	Nothing
TERMINAL:	ACALL	HELPMENU
TERMINAL1:	ACALL	PRNTCRLF
		MOV	A,#3Eh
		ACALL	TXBYTE
TERMINAL2:	ACALL	RXBYTE
		CJNE	A,#41h,TERMINAL3
		;Address input
		ACALL	PRNTCMND
		ACALL	INPDPTR
		SJMP	TERMINAL1
TERMINAL3:	CJNE	A,#44h,TERMINAL4
		;Dump
		ACALL	PRNTCMND
		ACALL	DUMP
		SJMP	TERMINAL
TERMINAL4:	CJNE	A,#45h,TERMINAL5
		;Enter hex
		ACALL	PRNTCMND
		ACALL	ENTERHEX
		SJMP	TERMINAL
TERMINAL5:	CJNE	A,#47h,TERMINAL6
		;Go
		ACALL	PRNTCMND
		ACALL	GO
		SJMP	TERMINAL
TERMINAL6:	CJNE	A,#48h,TERMINAL7
		;Help
		ACALL	PRNTCMND
		SJMP	TERMINAL
TERMINAL7:	CJNE	A,#49h,TERMINAL8
		;Internal memory
		ACALL	PRNTCMND
		ACALL	MEMDUMP
		SJMP	TERMINAL1
TERMINAL8:	CJNE	A,#4Ch,TERMINAL9
		;Load
		ACALL	PRNTCMND
		ACALL	LOAD
		SJMP	TERMINAL1
TERMINAL9:	CJNE	A,#50h,TERMINAL10
		;Program ROM
		ACALL	PRNTCMND
		ACALL	EPROM
		SJMP	TERMINAL
TERMINAL10:	CJNE	A,#52h,TERMINAL11
		;Run
		ACALL	PRNTCMND
		ACALL	RUN
		SJMP	TERMINAL
TERMINAL11:	CJNE	A,#53h,TERMINAL12
		;SFR dump
		LCALL	PRNTCMND
		ACALL	DUMPSFR
		SJMP	TERMINAL1
TERMINAL12:	CJNE	A,#46h,TERMINAL13
		;Enter float
		ACALL	PRNTCMND
		ACALL	ENTERFLOAT
		SJMP	TERMINAL1
TERMINAL13:	CJNE	A,#9Fh,TERMINAL14
		;Esc
		LJMP	0000h
TERMINAL14:	CJNE	A,#0Dh,TERMINAL2
		;CR
		SJMP	TERMINAL1

;RS232 Functions
;------------------------------------------------------------------

PRNTCSTR:	MOV	DPLSAVE,DPL
		MOV	DPHSAVE,DPH
		POP	DPH
		POP	DPL
PRNTCSTR1:	CLR	A
		MOVC	A,@A+DPTR
		INC	DPTR
		JZ	PRNTCSTR2
		ACALL	TXBYTE
		SJMP	PRNTCSTR1
PRNTCSTR2:	PUSH	DPL
		PUSH	DPH
		MOV	DPL,DPLSAVE
		MOV	DPH,DPHSAVE
		RET

PRNTCSTRLCD:	MOV	DPLSAVE,DPL
		MOV	DPHSAVE,DPH
		POP	DPH
		POP	DPL
PRNTCSTRLCD1:	CLR	A
		MOVC	A,@A+DPTR
		INC	DPTR
		JZ	PRNTCSTRLCD2
		LCALL	LCDCHROUT
		SJMP	PRNTCSTRLCD1
PRNTCSTRLCD2:	PUSH	DPL
		PUSH	DPH
		MOV	DPL,DPLSAVE
		MOV	DPH,DPHSAVE
		RET

PRNTCDPTRLCD:	CLR	A
		MOVC	A,@A+DPTR
		JZ	PRNTCDPTRLCD1
		LCALL	LCDCHROUT
		INC	DPTR
		SJMP	PRNTCDPTRLCD
PRNTCDPTRLCD1:	RET

PRINTSTR:	JNB	INTBITS.6,PRINTSTRLCD
PRINTSTRTRM:	MOV	A,@R0
		ACALL	TXBYTE
		INC	R0
		DJNZ	R7,PRINTSTRTRM
		ACALL	PRNTCRLF
		RET

PRINTSTRLCD:	MOV	A,@R0
		LCALL	LCDCHROUT
		INC	R0
		DJNZ	R7,PRINTSTRLCD
		RET

PRINTDPTRSTR:	MOVX	A,@DPTR
		ACALL	TXBYTE
		INC	DPTR
		CJNE	A,#0Dh,PRINTDPTRSTR
		MOV	A,#0Ah
		ACALL	TXBYTE
		RET

PRINTFP:	MOV	FPCHR_OUT,#LCDLINE
		MOV	FORMAT,#00h
		MOV	A,ARG_STACK
		CLR	C
		SUBB	A,#05h
		MOV	R0,A
		LCALL	FLOATING_POINT_OUTPUT
		MOV	R0,FPCHR_OUT
		CLR	A
		MOV	@R0,A
		MOV	R0,#LCDLINE
		MOV	A,@R0
PRINTFP1:	ACALL	TXBYTE
		INC	R0
		MOV	A,@R0
		JNZ	PRINTFP1
		MOV	A,#20h
		ACALL	TXBYTE
		MOV	A,#20h
		ACALL	TXBYTE
		MOV	A,#20h
		ACALL	TXBYTE
		MOV	A,#20h
		ACALL	TXBYTE
		MOV	A,#0Dh
		ACALL	TXBYTE
		MOV	A,#0Ah
		ACALL	TXBYTE
		RET

PRNTCMND:	ACALL	TXBYTE
		ACALL	PRNTCRLF
		RET

PRNTCRLF:	MOV	A,#0Dh
		ACALL	TXBYTE
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

BINOUT:		MOV	R0,#08h
BINOUT1:	RLC	A
		PUSH	ACC
		MOV	A,#20h
		LCALL	TXBYTE
		MOV	A,#20h
		LCALL	TXBYTE
		MOV	A,#30H
BINOUT2:	JNC	BINOUT3
		INC	A
BINOUT3:	LCALL	TXBYTE
		POP	ACC
		DJNZ	R0,BINOUT1
		LCALL	PRNTCRLF
		RET

HEXDPTR:	MOV	A,DPH
		ACALL	HEXOUT
		MOV	A,DPL
		ACALL	HEXOUT
		MOV	A,#20h
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

HEXINPBYTE:	ACALL	HEXINP
		JC	HEXINPBYTE1
		SWAP	A
		MOV	R3,A
		ACALL	HEXINP
		JC	HEXINPBYTE1
		ADD	A,R3
HEXINPBYTE1:	RET

HEXINP:		ACALL	HEXINP2
		JC	HEXINP1
		PUSH	ACC
		MOV	A,R2
		ACALL	TXBYTE
		POP	ACC
HEXINP1:	RET

HEXINP2:	ACALL	RXBYTE
		CJNE	A,#9Fh,HEXINP3			;Esc
		SETB	C
		RET
HEXINP3:	CJNE	A,#0Dh,HEXINP4			;Cr
		SETB	C
		RET
HEXINP4:	MOV	R2,A
		CJNE	A,#3Ah,HEXINP40
HEXINP40:	JNC	HEXINP5
		CJNE	A,#30h,HEXINP41
HEXINP41:	JC	HEXINP2
		SUBB	A,#30h
		RET
HEXINP5:	CJNE	A,#47h,HEXINP50
HEXINP50:	JNC	HEXINP2
		CJNE	A,#41h,HEXINP51
HEXINP51:	JC	HEXINP2
		SUBB	A,#37h
		RET

INPDPTR:	ACALL	HEXDPTR
		ACALL	HEXINPBYTE
		JC	INPDPTR1
		MOV	DPH,A
		ACALL	HEXINPBYTE
		JC	INPDPTR1
		MOV	DPL,A
INPDPTR1:	ACALL	PRNTCRLF
		RET

RX16BYTES:	MOV	A,#05h
		ACALL	TXBYTE
		MOV	R0,#ROMBUFF
RX16BYTES1:	ACALL	RXBYTE
		MOV	@R0,A
		INC	R0
		CJNE	R0,#ROMBUFF+10h,RX16BYTES1
		MOV	R0,#ROMBUFF
		RET

RXBYTE:		JB	20h.7,RXBYTE1
		JNB	RI,$
		CLR	RI
		MOV	A,SBUF
		RET

RXBYTE1:	CLR	EX1
		JNB	RI,$
		CLR	RI
		MOV	A,SBUF
		SETB	EX1
		RET

TXBYTE:		JB	20h.7,TXBYTE1
		MOV	SBUF,A
		JNB	TI,$
		CLR	TI
		RET

TXBYTE1:	CLR	EX1
		MOV	SBUF,A
		JNB	TI,$
		CLR	TI
		SETB	EX1
		RET

;Functions
;------------------------------------------------------------------

HELPMENU:	ACALL	PRNTCSTR
		DB	0Eh
IF DEVMODE=1
		DB	'*** DEVMODE ***',0Dh,0Ah
ENDIF
		DB	'A Address input',0Dh,0Ah
		DB	'D Dump as hex',0Dh,0Ah
		DB	'E Enter hex',0Dh,0Ah
		DB	'F Enter float',0Dh,0Ah
		DB	'G Go (Load and Run)',0Dh,0Ah
		DB	'H Help',0Dh,0Ah
		DB	'I Internal memory dump',0Dh,0Ah
		DB	'L Load cmd file',0Dh,0Ah
		DB	'P Program ROM',0Dh,0Ah
		DB	'R Run',0Dh,0Ah
		DB	'S SFR dunp',0Dh,0Ah,00h
		RET

DUMP:		PUSH	DPL
		PUSH	DPH
		PUSH	02h
		PUSH	03h
DUMP1:		MOV	R3,#10h
DUMP2:		MOV	R2,#10h
		ACALL	HEXDPTR
DUMP3:		MOVX	A,@DPTR
		ACALL	HEXOUT
		MOV	A,#20h
		ACALL	TXBYTE
		INC	DPTR
		DJNZ	R2,DUMP3
		ACALL	PRNTCRLF
		DJNZ	R3,DUMP2
		ACALL	PRNTCRLF
		ACALL	RXBYTE
		CJNE	A,#9Fh,DUMP1			;Esc
		POP	03h
		POP	02h
		POP	DPH
		POP	DPL
		RET

ENTERHEX:	PUSH	DPL
		PUSH	DPH
ENTERHEX1:	ACALL	HEXDPTR
		ACALL	HEXINPBYTE
		JC	ENTERHEX2
		MOVX	@DPTR,A
		INC	DPTR
		ACALL	PRNTCRLF
		SJMP	ENTERHEX1
ENTERHEX2:	POP	DPH
		POP	DPL
		RET

ENTERFLOAT:	PUSH	DPL
		PUSH	DPH
		MOV	DPTR,#CONVT
ENTERFLOAT1:	ACALL	RXBYTE
		ACALL	TXBYTE
		MOVX	@DPTR,A
		INC	DPTR
		CJNE	A,#0Dh,ENTERFLOAT1
		MOV	DPTR,#CONVT
		LCALL	FLOATING_POINT_INPUT
		ACALL	HEXDUMPFP
		POP	DPH
		POP	DPL
		RET

MEMDUMP:	PUSH	00h
		MOV	R0,#00h
MEMDUMP1:	CLR	A
		ACALL	HEXOUT
		MOV	A,R0
		ACALL	HEXOUT
		MOV	A,#20h
		ACALL	TXBYTE
MEMDUMP2:	MOV	A,@R0
		ACALL	HEXOUT
		MOV	A,#20h
		ACALL	TXBYTE
		INC	R0
		MOV	A,R0
		ANL	A,#0Fh
		JNZ	MEMDUMP2
		ACALL	PRNTCRLF
		MOV	A,R0
		JNZ	MEMDUMP1
		POP	00h
		RET

DUMPSFR:	PUSH	PSW
		CLR	RS0
		CLR	RS1
		PUSH	ACC
		PUSH	00h
		PUSH	ACC
		LCALL	PRNTCSTR
		DB 0Dh,0Ah,'SFR  D7 D6 D5 D4 D3 D2 D1 D0',0Dh,0Ah
		DB '----------------------------',0Dh,0Ah
		DB 'ACC ',0
		POP	ACC
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'B   ',0
		MOV	A,B
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'DPH ',0
		MOV	A,DPH
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'DPL ',0
		MOV	A,DPL
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'IE  ',0
		MOV	A,IE
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'IP  ',0
		MOV	A,IP
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'P0  ',0
		MOV	A,P0
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'P1  ',0
		MOV	A,P1
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'P2  ',0
		MOV	A,P2
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'P3  ',0
		MOV	A,P3
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'PCON',0
		MOV	A,PCON
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'PSW ',0
		MOV	A,PSW
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'SBUF',0
		MOV	A,SBUF
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'SCON',0
		MOV	A,SCON
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'SP  ',0
		MOV	A,SP
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'TCON',0
		MOV	A,TCON
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'TH0 ',0
		MOV	A,TH0
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'TH1 ',0
		MOV	A,TH1
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'TL0 ',0
		MOV	A,TL0
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'TL1 ',0
		MOV	A,TL1
		LCALL	BINOUT
		LCALL	PRNTCSTR
		DB 'TMOD',0
		MOV	A,TMOD
		LCALL	BINOUT
		POP	00h
		POP	ACC
		POP	PSW
		RET

LOAD1K:		MOV	R3,#40h
LOAD1K1:	ACALL	RX16BYTES			;Read 16 bytes from cmd file
LOAD1K2:	MOV	A,@R0
		MOVX	@DPTR,A
		INC	DPTR
		INC	R0
		MOV	A,R0
		XRL	A,#50h
		JNZ	LOAD1K2				;Not 16 bytes yet
		DJNZ	R3,LOAD1K1			;Not 1K yet
		MOV	A,#'.'
		ACALL	TXBYTE
		RET

LOAD:		PUSH	DPL
		PUSH	DPH
		PUSH	00h
		PUSH	03h
		PUSH	04h
		ACALL	PRNTCSTR
		DB	'Loading .',0
		MOV	R4,#08h
LOAD10:		ACALL	LOAD1K
		DJNZ	R4,LOAD10
		MOV	A,#06h
		ACALL	TXBYTE				;End read 16 bytes from cmd file
		ACALL	PRNTCRLF
		POP	04h
		POP	03h
		POP	00h
		POP	DPH
		POP	DPL
		RET

GO:		ACALL	LOAD
RUN:		CLR	A
		JMP	@A+DPTR

;ROM menu selection
;------------------------------------------------------------------

EPROM:		ACALL	ROMMENU
		CJNE	A,#94h,EPROMEXIT
		LCALL	ROMINSERT
		JC	EPROM
		LCALL	ROMINIT				;Turn on VCC, pull RST high and init programming mode
		JC	EPROM				;Initialisation failed
		MOV	A,ROMACTION
		DEC	A
		JNZ	EPROM2
		;Test erased
		LCALL	ROMWAIT
		MOV	A,ROMMODE
		DEC	A
		JNZ	EPROM1
		LCALL	BM_ROMERASED
		SJMP	EPROM
EPROM1:		LCALL	PM_ROMERASED
		SJMP	EPROM
EPROM2:		DEC	A
		JNZ	EPROM3
		;Dump to hex file
		LCALL	ROMWAIT
		MOV	A,ROMMODE
		DEC	A
		JNZ	EPROM21
		LCALL	BM_ROMDUMPF
		SJMP	EPROM
EPROM21:	LCALL	PM_ROMDUMPF
		SJMP	EPROM
EPROM3:		DEC	A
		JNZ	EPROM4
		;Dump to screen
		MOV	A,ROMMODE
		DEC	A
		JNZ	EPROM31
		LCALL	BM_ROMDUMPS
		SJMP	EPROM
EPROM31:	LCALL	PM_ROMDUMPS
		SJMP	EPROM
EPROM4:		DEC	A
		JNZ	EPROM5
		;Verify
		LCALL	ROMWAIT
		MOV	A,ROMMODE
		DEC	A
		JNZ	EPROM41
		LCALL	BM_ROMVERIFY
		SJMP	EPROM
EPROM41:	LCALL	PM_ROMVERIFY
		SJMP	EPROM
EPROM5:		;Program
		LCALL	ROMWAIT
		MOV	A,ROMMODE
		DEC	A
		JNZ	EPROM51
		LCALL	PM_ROMPROG
		SJMP	EPROM
EPROM51:	LCALL	PM_ROMPROG
		SJMP	EPROM
EPROMEXIT:	RET

ROMMENU:	ACALL	PRNTCSTR
		DB	0Eh
		DB	'   -----------------  -----------------  -----------------',0Dh,0Ah
		DB	'   |  Action       |  |  EEPROM size  |  |  Mode         |',0Dh,0Ah
		DB	'   -----------------  -----------------  -----------------',0Dh,0Ah
		DB	'   |  Test erased  |  |  4K           |  |  Byte         |',0Dh,0Ah
		DB	'   |  Filedump     |  |  8K           |  |  Page         |',0Dh,0Ah
		DB	'   |  Screendump   |  |  16K          |  |               |',0Dh,0Ah
		DB	'   |  Verify       |  |  32K          |  |               |',0Dh,0Ah
		DB	'   |  Program      |  |  64K          |  |               |',0Dh,0Ah
		DB	'   -----------------  -----------------  -----------------',0Dh,0Ah
		DB	00h
		MOV	R0,#ROMSIZE
		LCALL	MENUSET
		INC	R0
		LCALL	MENUSET
		MOV	R0,#ROMACTION
		ACALL	MENUXP
		RET

MENUXP:		LCALL	MENUSET
		MOV	A,#08h
		LCALL	TXBYTE
		LCALL	RXBYTE
		CJNE	A,#9Ah,MENUXP1
		MOV	A,@R0
		DEC	A
		JZ	MENUXP
		MOV	A,#20h
		LCALL	TXBYTE
		DEC	@R0
		SJMP	MENUXP
MENUXP1:	CJNE	A,#9Bh,MENUXP2
		MOV	A,@R0
		SUBB	A,#05h
		JZ	MENUXP
		MOV	A,#20h
		LCALL	TXBYTE
		INC	@R0
		SJMP	MENUXP
MENUXP2:	CJNE	A,#9Ch,MENUYP1
		MOV	A,R0
		SUBB	A,#ROMMODE
		JZ	MENUXP
		INC	R0
		SJMP	MENUXP
MENUYP1:	CJNE	A,#9Dh,MENUYP2
		MOV	A,R0
		SUBB	A,#ROMACTION
		JZ	MENUXP
		DEC	R0
		SJMP	MENUXP
MENUYP2:	CJNE	A,#9Fh,MENUYP3			;Esc
		RET
MENUYP3:	CJNE	A,#94h,MENUXP			;Insert
		RET

MENUSET:	MOV	A,#0Bh
		LCALL	TXBYTE
		MOV	A,@R0
		ADD	A,#22h
		LCALL	TXBYTE
		MOV	A,R0
		SUBB	A,#ROMACTION
		MOV	B,#13h
		MUL	AB
		ADD	A,#24h
		LCALL	TXBYTE
		MOV	A,#0FBh				;û
		LCALL	TXBYTE
		RET

;------------------------------------------------------------------

ROMINSERT:	LCALL	ROMOFF
		LCALL	PRNTCSTR
		DB	0Bh,2Ah,23h,'Insert ',00h
		MOV	A,ROMSIZE
		DEC	A
		JNZ	ROMINSERT1
		LCALL	PRNTCSTR
		DB	'4K',00h
		MOV	ROMPAGES,#10h			;16 Pages
ROMINSERT1:	DEC	A
		JNZ	ROMINSERT2
		LCALL	PRNTCSTR
		DB	'8K',00h
		MOV	ROMPAGES,#20h			;32 Pages
ROMINSERT2:	DEC	A
		JNZ	ROMINSERT3
		LCALL	PRNTCSTR
		DB	'16K',00h
		MOV	ROMPAGES,#40h			;64 Pages
ROMINSERT3:	DEC	A
		JNZ	ROMINSERT4
		LCALL	PRNTCSTR
		DB	'32K',00h
		MOV	ROMPAGES,#80h			;128 Pages
ROMINSERT4:	DEC	A
		JNZ	ROMINSERT5
		LCALL	PRNTCSTR
		DB	'64K',00h
		MOV	ROMPAGES,#00h			;256 Pages
ROMINSERT5:	LCALL	PRNTCSTR
		DB	' device and strike <Enter> ',00h
		LCALL	RXBYTE
		CJNE	A,#9Fh,ROMINSERT6		;Esc
		SETB	C
		RET
ROMINSERT6:	LCALL	PRNTCSTR
		DB	0Bh,2Ah,23h,'                                       '
		DB	0Dh,00h
		CLR	C
		RET

ROMWAIT:	LCALL	PRNTCSTR
		DB	0Bh,2Ah,23h,'Wait ...',00h
		RET


;Byte mode
;------------------------------------------------------------------

BM_ROMERASED:	LCALL	BM_ROMRDBYTE			;Read a byte from ROM
		CJNE	A,#0FFh,BM_ROMERASED1		;Not erased
		INC	DPTR				;Next address
		MOV	A,DPL
		JNZ	BM_ROMERASED			;Jump if more bytes in this page
		MOV	A,DPH
		CJNE	A,ROMPAGES,BM_ROMERASED		;Jump if more pages
		LCALL	ROMOFF				;Set RST low and turn off VCC
		RET
BM_ROMERASED1:	LCALL	ROMOFF				;Set RST low and turn off VCC
		LCALL	PRNTCSTR
		DB	0Bh,2Ah,23h,'Byte at ',00h
		MOV	A,DPH
		LCALL	HEXOUT				;High address
		MOV	A,DPL
		LCALL	HEXOUT				;Low address
		LCALL	PRNTCSTR
		DB	' not erased <Enter> ',00h
		LCALL	RXBYTE				;Wait for keypress
		RET

BM_ROMDUMPF:	MOV	A,#03h
		LCALL	TXBYTE				;Init write to file
BM_ROMDUMPF1:	LCALL	BM_ROMRDBYTE			;Read a byte from ROM
		LCALL	HEXOUT				;Output as hex
		MOV	A,#20h
		LCALL	TXBYTE				;Output a space
		INC	DPTR
		MOV	A,DPL
		ANL	A,#0Fh
		JNZ	BM_ROMDUMPF2			;Still on same line
		LCALL	PRNTCRLF			;Output CRLF
BM_ROMDUMPF2:	MOV	A,DPL
		JNZ	BM_ROMDUMPF1			;Jump if more bytes in this page
		MOV	A,DPH
		CJNE	A,ROMPAGES,BM_ROMDUMPF1		;Jump if more pages
		MOV	A,#04h
		LCALL	TXBYTE				;End write to file
		LCALL	ROMOFF				;Set RST low and turn off VCC
BM_ROMDUMPF3:	RET

BM_ROMDUMPS:	LCALL	BM_ROMRDBYTE			;Read a byte from ROM
		LCALL	HEXOUT				;Output as hex
		MOV	A,#20h
		LCALL	TXBYTE				;Output a space
		INC	DPTR				;Next ROM address
		MOV	A,DPL
		ANL	A,#0Fh
		JNZ	BM_ROMDUMPS1			;Jump if still on same line
		LCALL	PRNTCRLF			;Output CRLF
BM_ROMDUMPS1:	MOV	A,DPL
		JNZ	BM_ROMDUMPS			;Jump if more bytes in this page
		LCALL	PRNTCRLF			;Output CRLF
		LCALL	RXBYTE				;Wait for a keypress
		CJNE	A,#9Fh,BM_ROMDUMPS2
		SJMP	BM_ROMDUMPS3
BM_ROMDUMPS2:	MOV	A,DPH
		CJNE	A,ROMPAGES,BM_ROMDUMPS		;Jump if more pages
BM_ROMDUMPS3:	LCALL	ROMOFF				;Set RST low and turn off VCC
		RET

BM_ROMVERIFY:	PUSH	00h				;Save R0
		MOV	ROMVERERR,#00h			;Number of errors
		LCALL	RX16BYTES			;Read 16 bytes from cmd file. R0 points to start of 16 byte buffer
BM_ROMVERIFY1:	MOV	ROMVER,@R0			;Get byte from buffer
		LCALL	BM_ROMRDBYTE			;Read a byte from ROM
		CJNE	A,ROMVER,BM_ROMVERIFY4		;Compare and jump if not equal
BM_ROMVERIFY2:	INC	R0				;Increment buffer pointer
		MOV	A,R0
		CJNE	A,#50h,BM_ROMVERIFY3		;Jump if not last byte in buffer
		LCALL	RX16BYTES			;Read 16 bytes from cmd file. R0 points to start of 16 byte buffer
BM_ROMVERIFY3:	INC	DPTR				;Next ROM address
		MOV	A,DPL
		JNZ	BM_ROMVERIFY1			;Jump if still on same page
		MOV	A,DPH
		CJNE	A,ROMPAGES,BM_ROMVERIFY1	;Jump if more pages
		LCALL	ROMOFF				;Set RST low and turn off VCC
		MOV	A,#06h
		LCALL	TXBYTE				;End read 16 bytes from cmd file
		POP	00h				;Restore R0
		RET
BM_ROMVERIFY4:	LCALL	ROMVERIFYERR
		JNC	BM_ROMVERIFY2			;Jump if less than 16 errors
		LCALL	ROMOFF				;Set RST low and turn off VCC
		MOV	A,#06h
		LCALL	TXBYTE				;End read 16 bytes from cmd file
		LCALL	RXBYTE				;Wait for a keypress
		POP	00h				;Restore R0
		RET

;Page mode
;------------------------------------------------------------------

PM_ROMERASED:	MOV	A,#30h
		LCALL	ISPCOMM				;Init read page mode
		MOV	A,DPH
		LCALL	ISPCOMM				;Send high address
PM_ROMERASED1:	CLR	A
		LCALL	ISPCOMM				;Get byte from ROM
		CJNE	A,#0FFh,PM_ROMERASED2		;Jump if not erased
		INC	DPTR
		MOV	A,DPL
		JNZ	PM_ROMERASED1			;Jump if more bytes on this page
		MOV	A,DPH
		CJNE	A,ROMPAGES,PM_ROMERASED		;Jump if more pagees
		LCALL	ROMOFF				;Set RST low and turn off VCC
		RET
PM_ROMERASED2:	LCALL	ROMOFF				;Set RST low and turn off VCC
		LCALL	PRNTCSTR
		DB	0Bh,2Ah,23h,'Byte at ',00h
		MOV	A,DPH
		LCALL	HEXOUT				;Output high address as hex
		MOV	A,DPL
		LCALL	HEXOUT				;Output low address as hex
		LCALL	PRNTCSTR
		DB	' not erased <Enter> ',00h
		LCALL	RXBYTE				;Wait for a keypress
		RET

PM_ROMDUMPF:	MOV	A,#03h
		LCALL	TXBYTE				;Init Output to hex file
PM_ROMDUMPF1:	MOV	A,#30h
		LCALL	ISPCOMM				;Init read page mode
		MOV	A,DPH
		LCALL	ISPCOMM				;Send high address
PM_ROMDUMPF2:	CLR	A
		LCALL	ISPCOMM				;Get byte from ROM
		LCALL	HEXOUT				;Output as hex
		MOV	A,#20h
		LCALL	TXBYTE				;Output a space
		INC	DPTR
		MOV	A,DPL
		ANL	A,#0Fh
		CJNE	A,#00h,PM_ROMDUMPF3		;Jump if more bytes in this line
		LCALL	PRNTCRLF			;Output CRLF
		MOV	A,DPL
		JNZ	PM_ROMDUMPF2			;Jump if more bytes in this page
PM_ROMDUMPF3:	MOV	A,DPH
		CJNE	A,ROMPAGES,PM_ROMDUMPF1		;Jump if more pages
		MOV	A,#04h
		LCALL	TXBYTE				;End Output to hex file
		LCALL	ROMOFF				;Set RST low and turn off VCC
		RET

PM_ROMDUMPS:	MOV	A,#30h
		LCALL	ISPCOMM				;Init read page mode
		MOV	A,DPH
		LCALL	ISPCOMM				;Send high address
PM_ROMDUMPS1:	CLR	A
		LCALL	ISPCOMM				;Get byte from ROM
		LCALL	HEXOUT				;Output as hex
		MOV	A,#20h
		LCALL	TXBYTE				;Output a space
		INC	DPTR
		MOV	A,DPL
		ANL	A,#0Fh
		JNZ	PM_ROMDUMPS2			;Jump if still on same line
		LCALL	PRNTCRLF			;Output CRLF
		MOV	A,DPL
		JNZ	PM_ROMDUMPS1			;Jump if more bytes on this page
		LCALL	PRNTCRLF			;Output CRLF
		LCALL	RXBYTE				;Wait for a keypress
		CJNE	A,#9Fh,PM_ROMDUMPS2
		SJMP	PM_ROMDUMPS3			;Esc pressed
PM_ROMDUMPS2:	MOV	A,DPH
		CJNE	A,ROMPAGES,PM_ROMDUMPS		;Jump if more pages
PM_ROMDUMPS3:	LCALL	ROMOFF				;Set RST low and turn off VCC
		RET

PM_ROMVERIFY:	PUSH	00h				;Save R0
		MOV	ROMVERERR,#00h			;Number of errors
		LCALL	RX16BYTES			;Read 16 bytes from cmd file. R0 points to start of 16 byte buffer
PM_ROMVERIFY1:	MOV	A,#30h
		LCALL	ISPCOMM				;Init read page mode
		MOV	A,DPH
		LCALL	ISPCOMM				;Send high address
PM_ROMVERIFY2:	MOV	ROMVER,@R0			;Get byte from buffer
		CLR	A
		LCALL	ISPCOMM				;Get byte from ROM
		CJNE	A,ROMVER,PM_ROMVERIFY5		;Compare and jump if not equal
PM_ROMVERIFY3:	INC	R0				;Increment buffer pointer
		MOV	A,R0
		CJNE	A,#50h,PM_ROMVERIFY4		;Jump if not last byte in buffer
		LCALL	RX16BYTES			;Read 16 bytes from cmd file. R0 points to start of 16 byte buffer
PM_ROMVERIFY4:	INC	DPTR
		MOV	A,DPL
		JNZ	PM_ROMVERIFY2			;Jump if still on same page
		MOV	A,DPH
		CJNE	A,ROMPAGES,PM_ROMVERIFY1	;Jump if more pages
		LCALL	ROMOFF				;Set RST low and turn off VCC
		MOV	A,#06h
		LCALL	TXBYTE				;End read 16 bytes from cmd file
		POP	00h				;Restore R0
		RET
PM_ROMVERIFY5:	LCALL	ROMVERIFYERR
		JNC	PM_ROMVERIFY3			;Jump if less than 16 errors
		LCALL	ROMOFF				;Set RST low and turn off VCC
		MOV	A,#06h
		LCALL	TXBYTE				;End read 16 bytes from cmd file
		LCALL	RXBYTE				;Wait for keypress
		POP	00h				;Restore R0
		RET

PM_ISERASED:	MOV	DPTR,#0000h
		MOV	ROMVERERR,#00h
PM_ISERASED1:	MOV	A,#30h
		LCALL	ISPCOMM				;Init read page mode
		MOV	A,DPH
		LCALL	ISPCOMM				;Send high address
PM_ISERASED2:	CLR	A
		LCALL	ISPCOMM				;Get byte from ROM
		INC	A
		ORL	ROMVERERR,A
		INC	DPTR
		MOV	A,DPL
		JNZ	PM_ISERASED2			;Jump if more bytes on this page
		MOV	A,ROMVERERR
		JNZ	PM_ISERASED3
		MOV	A,DPH
		CJNE	A,ROMPAGES,PM_ISERASED1		;Jump if more pagees
PM_ISERASED3:	CLR	C
		MOV	A,ROMVERERR
		JZ	PM_ISERASED4
		SETB	C
PM_ISERASED4:	RET

PM_ROMPROG:	LCALL	PM_ISERASED			;Check if chip is erased
		JNC	PM_ROMPROG1
		MOV	A,#0ACh
		LCALL	ISPCOMM				;Init chip erase byte 1
		MOV	A,#80h
		LCALL	ISPCOMM				;Init chip erase byte 2
		CLR	A
		LCALL	ISPCOMM				;Init chip erase byte 3
		CLR	A
		LCALL	ISPCOMM				;Init chip erase byte 4
		CLR	A
		LCALL	WAIT				;Wait 256 ms
		CLR	A
		LCALL	WAIT				;Wait 256 ms
		CLR	A
		LCALL	WAIT				;Wait 256 ms
		LCALL	PM_ISERASED
		JNC	PM_ROMPROG1
		LCALL	ROMOFF				;Set RST low and turn off VCC
		LCALL	PRNTCSTR
		DB	0Bh,2Ah,23h,'Could not erase chip <Enter> ',00h
		LCALL	RXBYTE				;Wait for keypress
		RET
PM_ROMPROG1:	PUSH	00h
		MOV	DPTR,#0000h
		LCALL	RX16BYTES			;Read 16 bytes from cmd file. R0 points to start of 16 byte buffer
PM_ROMPROG2:	MOV	A,#40h
		LCALL	ISPCOMM				;Init byte programming mode
		MOV	A,DPH
		LCALL	ISPCOMM				;Send high address
		MOV	A,DPL
		LCALL	ISPCOMM				;Send low address
		MOV	A,@R0				;Get byte from buffer
		MOV	ROMVER,A
		LCALL	ISPCOMM				;Send byte to be programmed
		MOV	A,#10h
		LCALL	WAIT				;Wait 1mS
		LCALL	BM_ROMRDBYTE			;Read a byte from ROM
		CJNE	A,ROMVER,PM_ROMPROG4		;Compare and jump if not equal
		INC	R0
		MOV	A,R0
		CJNE	A,#50h,PM_ROMPROG3
		LCALL	RX16BYTES			;Read 16 bytes from cmd file. R0 points to start of 16 byte buffer
PM_ROMPROG3:	INC	DPTR
		MOV	A,DPL
		JNZ	PM_ROMPROG2			;Jump if still on same page
		MOV	A,#2Eh
		LCALL	TXBYTE
		MOV	A,DPH
		CJNE	A,ROMPAGES,PM_ROMPROG2		;Jump if more pages
		LCALL	ROMOFF				;Set RST low and turn off VCC
		MOV	A,#06h
		LCALL	TXBYTE				;End read 16 bytes from cmd file
		POP	00h
		RET
PM_ROMPROG4:	PUSH	ACC
		LCALL	ROMOFF				;Set RST low and turn off VCC
		MOV	A,#06h
		LCALL	TXBYTE				;End read 16 bytes from cmd file
		LCALL	PRNTCSTR
		DB	0Bh,2Ah,23h,'Error at ',00h
		MOV	A,DPH
		LCALL	HEXOUT				;High address
		MOV	A,DPL
		LCALL	HEXOUT				;Low address
		MOV	A,#20h
		LCALL	TXBYTE
		MOV	A,ROMVER			;Byte from .cmd file
		LCALL	HEXOUT
		MOV	A,#20h
		LCALL	TXBYTE
		POP	ACC
		LCALL	HEXOUT				;Byte read from ROM
		LCALL	RXBYTE				;Wait for a keypress
		POP	00h				;Restore R0
		RET

;Wait functions
;------------------------------------------------------------------

WAIT100:	PUSH	07h				;Save R7
		MOV	R7,#64h
WAIT1001:	DJNZ	R7,WAIT1001			;Wait loop, 100uS
		POP	07h				;Restore R7
		RET

WAIT:		XCH	A,R7
WAIT1:		ACALL	WAIT100
		DJNZ	R7,WAIT1
		XCH	A,R7
		RET

;Control functions
;------------------------------------------------------------------

;IN A, OUT A
ISPCOMM:	PUSH	07h
		PUSH	02h
		MOV	R2,#08h
ISPCOMM1:	RLC	A
		MOV	P1.3,C				;MISO
		MOV	C,P1.4				;MOSI
		XCH	A,R7
		RLC	A
		XCH	A,R7
		SETB	P1.2				;SCK H
		NOP
		CLR	P1.2				;SCK L
		DJNZ	R2,ISPCOMM1
		MOV	A,R7
		POP	02
		POP	07
		RET

ROMON:		SETB	P1.0				;+5V On
		MOV	A,#0Ah
		ACALL	WAIT				;Wait 1mS
		SETB	P1.1				;RST H
		MOV	A,#0Ah
		ACALL	WAIT				;Wait 1mS
		RET

ROMOFF:		CLR	P1.1				;RST L
		MOV	A,#01h
		ACALL	WAIT				;Wait 100uS
		MOV	P1,#10h				;+5V Off, P1.4 As Input
		MOV	A,#0Ah
		LCALL	WAIT				;Wait 1mS
		RET

ROMINITPGM:	MOV	A,#0ACh
		LCALL	ISPCOMM
		MOV	A,#53h
		LCALL	ISPCOMM
		MOV	A,#00h
		LCALL	ISPCOMM
		MOV	A,#00h
		LCALL	ISPCOMM
		CJNE	A,#69h,ROMINITPGM1
		RET
ROMINITPGM1:	LCALL	PRNTCSTR
		DB	0Bh,2Ah,23h,'Initialisation Error <Enter> ',00h
		LCALL	RXBYTE
		SETB	C
		RET

ROMINIT:	MOV	DPTR,#0000h			;DPTR holds ROM address
		LCALL	ROMON				;Turn on VCC and pull RST high
		LCALL	ROMINITPGM
		JNC	ROMINIT1
		LCALL	ROMOFF				;Init programming failed
		SETB	C
ROMINIT1:	RET

BM_ROMRDBYTE:	MOV	A,#20h
		LCALL	ISPCOMM
		MOV	A,DPH
		LCALL	ISPCOMM
		MOV	A,DPL
		LCALL	ISPCOMM
		MOV	A,#00h
		LCALL	ISPCOMM
		RET

ROMVERIFYERR:	PUSH	ACC
		LCALL	PRNTCSTR
		DB	0Dh,'   Error at ',00h
		MOV	A,DPH
		LCALL	HEXOUT
		MOV	A,DPL
		LCALL	HEXOUT
		MOV	A,#20h
		LCALL	TXBYTE
		MOV	A,ROMVER
		LCALL	HEXOUT
		MOV	A,#20h
		LCALL	TXBYTE
		POP	ACC
		LCALL	HEXOUT
		LCALL	PRNTCRLF
		INC	ROMVERERR
		MOV	A,ROMVERERR
		CJNE	A,#10h,ROMVERIFYERR1
ROMVERIFYERR1:	CPL	C
		RET

;LCD Output.
;-----------------------------------------------------
LCDDELAY:	PUSH	07h
		MOV	R7,#00h
		DJNZ	R7,$
		POP	07h
		RET

;A contains nibble
LCDNIBOUT:	PUSH	DPL
		PUSH	DPH
		MOV	DPTR,#8000h
		ORL	A,OUTD7D6
		SETB	ACC.5				;E
		MOVX	@DPTR,A				;
		CLR	ACC.5				;Negative edge on E
		MOVX	@DPTR,A				;
		POP	DPH
		POP	DPL
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

LCDCLEAR:	MOV	A,#00000001b
		ACALL	LCDCMDOUT
		MOV	A,#10h
		LCALL	WAIT
		RET

;A contais address
LCDSETADR:	ORL	A,#10000000b
		ACALL	LCDCMDOUT
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

;Single step called when INT1 pin low and interupt is enabled
;------------------------------------------------------------------
SINGLESTEP:	PUSH	PSW
		PUSH	ACC
		CLR	RS0
		CLR	RS1
		PUSH	00h
		MOV	R0,SP
		DEC	R0				;Skip PSW
		DEC	R0				;Skip ACC
		DEC	R0				;Skip R0
		MOV	A,SSADRMSB
		INC	A
		JZ	SINGLESTEP0
		MOV	A,@R0				;MSB adress
		CJNE	A,SSADRMSB,SINGLESTEPEX2
		DEC	R0
		MOV	A,@R0				;MSB adress
		INC	R0
		CJNE	A,SSADRLSB,SINGLESTEPEX2
SINGLESTEP0:	MOV	A,#07h
		LCALL	TXBYTE
		MOV	A,@R0				;MSB adress
		LCALL	TXBYTE
		DEC	R0
		MOV	A,@R0				;LSB adress
		LCALL	TXBYTE
		INC	R0				;MSB adress
		INC	R0				;PSW
		MOV	A,@R0				;PSW
		LCALL	TXBYTE
		INC	R0				;ACC
		MOV	A,@R0				;ACC
		LCALL	TXBYTE
		MOV	A,B				;B
		LCALL	TXBYTE
		MOV	A,SP				;SP
		CLR	C
		SUBB	A,#05h
		LCALL	TXBYTE
		MOV	A,DPL				;DPL
		LCALL	TXBYTE
		MOV	A,DPH				;DPH
		LCALL	TXBYTE
		INC	R0				;R0
		MOV	A,@R0				;R0
		LCALL	TXBYTE
		MOV	R0,#01h
SINGLESTEP1:	MOV	A,@R0				;31 Bytes
		LCALL	TXBYTE
		INC	R0
		CJNE	R0,#20h,SINGLESTEP1
		PUSH	DPL
		PUSH	DPH
		MOV	R0,#20h				;32 Bytes
SINGLESTEP2:	MOVX	A,@DPTR
		LCALL	TXBYTE
		INC	DPTR
		DJNZ	R0,SINGLESTEP2
SINGLESTEP3:	LCALL	RXBYTE
		CJNE	A,#'R',SINGLESTEP4		;R Run
		SETB	P3.3				;Set INT1 pin high
		SJMP	SINGLESTEPEX
SINGLESTEP4:	CJNE	A,#'s',SINGLESTEP5		;s Stop
		SETB	P3.3				;Set INT1 pin high
		CLR	A
		PUSH	ACC				;Force a software reset
		PUSH	ACC
		RETI					;Return to reset vector
SINGLESTEP5:	CJNE	A,#'i',SINGLESTEP6		;i Step into
SINGLESTEPEX:	MOV	SSADRLSB,#0FFh
		MOV	SSADRMSB,#0FFh
SINGLESTEPEX1:	POP	DPH
		POP	DPL
SINGLESTEPEX2:	POP	00h
		POP	ACC
		POP	PSW
		RETI
SINGLESTEP6:	CJNE	A,#'o',SINGLESTEP7		;o Step over / Run to caret
		LCALL	RXBYTE
		MOV	SSADRLSB,A
		LCALL	RXBYTE
		MOV	SSADRMSB,A
		SJMP	SINGLESTEPEX1
SINGLESTEP7:	CJNE	A,#'A',SINGLESTEP8		;A Adress input
		LCALL	INPDPTR
		SJMP	SINGLESTEP3
SINGLESTEP8:	CJNE	A,#'I',SINGLESTEP9		;Dump internal memory
		LCALL	MEMDUMP
		SJMP	SINGLESTEP3
SINGLESTEP9:	CJNE	A,#'D',SINGLESTEP10		;Dump external memory
		LCALL	DUMP
		SJMP	SINGLESTEP3
SINGLESTEP10:	CJNE	A,#'S',SINGLESTEP3		;Dump SFR's
		POP	DPH
		POP	DPL
		POP	00h
		POP	ACC
		POP	PSW
		PUSH	PSW
		PUSH	ACC
		CLR	RS0
		CLR	RS1
		PUSH	00h
		PUSH	DPL
		PUSH	DPH
		LCALL	DUMPSFR
		SJMP	SINGLESTEP3

		END
