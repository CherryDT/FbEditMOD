
DEBUG		EQU 0

$INCLUDE	(LCMeter.inc)

;RESET:***********************************************
		ORG	0000h
		AJMP	START0
;IE0IRQ:**********************************************
		ORG	0003h
		AJMP	IE0IRQ
;------------------------------------------------------------------

		ORG	0080h
IE0IRQ:		INC	MODE
		ACALL	SETMODE
		ACALL	DEBOUNCEINT0
		AJMP	START

DEBOUNCEINT0:	MOV	R6,#00h
		MOV	R7,#00h
DEBOUNCEINT01:	JNB	P3.2,DEBOUNCEINT0
		DJNZ	R6,DEBOUNCEINT01
		DJNZ	R7,DEBOUNCEINT01
		CLR	IE0
		RETI

SETMODE:	MOV	A,MODE
		CJNE	A,#MODEMAX+1,SETMODE1
		CLR	A
SETMODE1:	MOV	MODE,A
		MOV	R7,A
		MOV	DPTR,#MODE0
		DJNZ	R7,SETMODE2
		MOV	DPTR,#MODE1
SETMODE2:	DJNZ	R7,SETMODE3
		MOV	DPTR,#MODE2
SETMODE3:	DJNZ	R7,SETMODE4
		MOV	DPTR,#MODE3
SETMODE4:	DJNZ	R7,SETMODE5
		MOV	DPTR,#MODE4
SETMODE5:	ACALL	LCDCLEAR
		ACALL	PRNTCDPTRLCD
		RET

START0:		CLR	A
		CLR	P1.4				;L/C
		CLR	P1.5				;CAL
		MOV	IE,A				;Disable all interrupts
		MOV	R0,A
START01:	MOV	@R0,A				;Clear the ram
		DJNZ	R0,START01
		MOV	SP,#MCUSTACK			;Init stack pointer.
		SETB	EX0				;Enable INT0
		SETB	EA				;Enable interrupts
		LCALL	FLOATING_INIT
		ACALL	WAITASEC
		ACALL	LCDINIT
		CLR	A
		ACALL	LCDSETADR
		MOV	DPTR,#WELCOME
		ACALL	PRNTCDPTRLCD
		ACALL	WAITASEC
START02:	ACALL	SETMODE
START:		ACALL	LCDCLEARBUFF
		MOV	R7,MODE
		DJNZ	R7,START1
		;C Meter
		ACALL	CMeter
		SJMP	START
START1:		DJNZ	R7,START2
		;L Meter
		ACALL	LMeter
		SJMP	START
START2:		DJNZ	R7,START3
		;30MHz
		MOV	A,#01h				;CH1, 30MHz
		ACALL	FREQUENCY
		SJMP	START
START3:		DJNZ	R7,START4
		;1GHz
		MOV	A,#02h				;CH2, 1GHz
		ACALL	FREQUENCY
		SJMP	START
START4:		;Calibrate
		ACALL	LCMETERINIT
		MOV	MODE,#01h			;C Meter
		SJMP	START02

FREQUENCY:	CLR	P1.4				;C
		CLR	P1.5				;F1
		ACALL	FRQCOUNT
		MOV	R0,#LCDLINE+4			;Decimal buffer
FREQUENCY1:	ACALL	BIN2DEC
		MOV	R7,A				;Number of digits
		ACALL	FRQFORMAT
		MOV	A,#40h				;Output result
		ACALL	LCDSETADR
		MOV	R0,#LCDLINE
		MOV	R7,#10h
		ACALL	LCDPRINTSTR
		RET

;------------------------------------------------------------------
;Get LC meter frquency
;IN:	R1 points to FP buffer
;OUT:	Nothing
;------------------------------------------------------------------
LCMETERGETFRQ:	PUSH	01h				;Save R1
		ACALL	LCDCLEARBUFF
		MOV	A,#250
		ACALL	WAIT				;Wait 25ms for relay to kick in / out
		MOV	A,#250
		ACALL	WAIT				;Wait 25ms for relay to kick in / out
		MOV	A,#00h				;CH0, LC Meter
		ACALL	FRQCOUNT
		MOV	R0,#LCDLINE
		ACALL	BIN2DEC
		MOV	R0,#LCDLINE
		MOV	R1,#CONVT
		MOV	R7,#0Ah
LCMETERGETFRQ1:	MOV	A,@R0
		MOV	@R1,A
		INC	R0
		INC	R1
		DJNZ	R7,LCMETERGETFRQ1
		MOV	A,#0Dh
		MOVX	@R1,A
		MOV	R1,#CONVT
		LCALL	FLOATING_POINT_INPUT
		POP	01h				;Restore R1
		LCALL	POPAS				;POP ARGUMENT TO R1
		RET

;------------------------------------------------------------------
;Calculate X=((Fa/Fb)^2)-1
;IN:	Fa=R0, Fb=R1
;OUT:	Nothing
;------------------------------------------------------------------
LCCALC:		PUSH	01h
		LCALL	PUSHAS				; PUSH R0 TO ARGUMENT
		POP	00h
		LCALL	PUSHAS				; PUSH R0 TO ARGUMENT
		LCALL	FLOATING_DIV
		MOV	R0,ARG_STACK
		LCALL	PUSHAS				; PUSH R0 TO ARGUMENT
		LCALL	FLOATING_MUL
		MOV	DPTR,#FPONE
		LCALL	PUSHC				; PUSH ARG IN DPTR TO STACK
		LCALL	FLOATING_SUB
		RET

;------------------------------------------------------------------
;Get LC meter frquency F1 and F2. Calculatr LCCA=((F1/F2)^2)-1 and LCCB=LCCA*((1/(2*Pi*F1))^2)*(1/Ccal)
;IN:	Nothing
;OUT:	Nothing
;------------------------------------------------------------------
LCMETERINIT:	CLR	P1.4				;C
		CLR	P1.5				;F1
		MOV	R7,#05h
LCMETERINIT1:	PUSH	07h
		ACALL	WAITASEC
		MOV	A,#'.'
		ACALL	LCDCHROUT
		POP	07h
		DJNZ	R7,LCMETERINIT1
		CLR	P1.5				;F1
		MOV	R1,#LCF1
		ACALL	LCMETERGETFRQ			;Get F1
		MOV	A,#40h				;Output result
		ACALL	LCDSETADR
		MOV	R0,#LCDLINE
		MOV	R7,#10h
		ACALL	LCDPRINTSTR
		SETB	P1.5				;F2
		MOV	R1,#LCF2
		ACALL	LCMETERGETFRQ			;Get F2
		CLR	P1.5				;F1
		MOV	A,#40h				;Output result
		ACALL	LCDSETADR
		MOV	R0,#LCDLINE
		MOV	R7,#10h
		ACALL	LCDPRINTSTR
		;Calculate LCCA=((F1/F2)^2)-1
		MOV	R0,#LCF1
		MOV	R1,#LCF2
		ACALL	LCCALC
		;Save result to LCCA
		MOV	R1,#LCCA
		LCALL	POPAS				;POP ARGUMENT TO R1
		;Calculate A=(1/(2*Pi*F1))^2
		MOV	DPTR,#FPTWO
		LCALL	PUSHC				;PUSH ARG IN DPTR TO STACK
		MOV	DPTR,#FPPI
		LCALL	PUSHC				;PUSH ARG IN DPTR TO STACK
		LCALL	FLOATING_MUL
		MOV	R0,#LCF1
		LCALL	PUSHAS				;PUSH R0 TO ARGUMENT
		LCALL	FLOATING_MUL
		MOV	R1,#LCCT
		LCALL	POPAS				;POP ARGUMENT TO R1
		MOV	DPTR,#FPONE
		LCALL	PUSHC				;PUSH ARG IN DPTR TO STACK
		MOV	R0,#LCCT
		LCALL	PUSHAS				;PUSH R0 TO ARGUMENT
		LCALL	FLOATING_DIV
		MOV	R0,ARG_STACK
		LCALL	PUSHAS				;PUSH R0 TO ARGUMENT
		LCALL	FLOATING_MUL
		;Calculate LCCB=A*LCCA*(1/Ccal)
		MOV	R0,#LCCA
		LCALL	PUSHAS				;PUSH R0 TO ARGUMENT
		LCALL	FLOATING_MUL
		MOV	DPTR,#FPCCAL
		LCALL	PUSHC				;PUSH ARG IN DPTR TO STACK
		LCALL	FLOATING_DIV
		;Save result to LCCB
		MOV	R1,#LCCB
		LCALL	POPAS				;POP ARGUMENT TO R1
		RET

;------------------------------------------------------------------
;Capacitance meter: Cx=((((F1/F3)^2)-1)/(((F1/F2)^2)-1))*Ccal
;IN:	Nothing
;OUT:	Nothing
;------------------------------------------------------------------
CMETER:		CLR	P1.4				;C
		CLR	P1.5				;F1
		MOV	R1,#LCF3
		ACALL	LCMETERGETFRQ			;Get F3
		;Calculate A=((F1/F3)^2)-1
		MOV	R0,#LCF1
		MOV	R1,#LCF3
		ACALL	LCCALC
		;Calculate B=A/LCCA
		MOV	R0,#LCCA
		LCALL	PUSHAS				;PUSH R0 TO ARGUMENT
		LCALL	FLOATING_DIV
		;Calculate Cx=A/B*Ccal
		MOV	DPTR,#FPCCAL
		LCALL	PUSHC				;PUSH ARG IN DPTR TO STACK
		LCALL	FLOATING_MUL
		MOV	R0,ARG_STACK
		DEC	R0
		MOV	A,@R0
		INC	R0
		JZ	CMETER1
		CLR	A
		MOV	@R0,A
CMETER1:	MOV	A,@R0
		MOV	LCDLINE+14,#'p'
		MOV	DPTR,#FPpF
		JZ	CMETER2
		CJNE	A,#78h,$+3
		JC	CMETER2
		MOV	LCDLINE+14,#'n'
		MOV	DPTR,#FPnF
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
		MOV	A,#40h				;Output result
		ACALL	LCDSETADR
		MOV	R0,#LCDLINE
		MOV	R7,#10h
		ACALL	LCDPRINTSTR
		RET

;------------------------------------------------------------------
;Inductance meter Lx=((F1/F3)^2)-1)*((F1/F2)^2)-1)*((1/(2*Pi*F1))^2)*(1/Ccal)
;IN:	Nothing
;OUT:	Nothing
;------------------------------------------------------------------
LMETER:		SETB	P1.4				;L
		CLR	P1.5				;F1
		MOV	R1,#LCF3
		ACALL	LCMETERGETFRQ			;Get F3
		;Calculate A=((F1/F3)^2)-1
		MOV	R0,#LCF1
		MOV	R1,#LCF3
		ACALL	LCCALC
		;Calculate B=A*LCCB
		MOV	R0,#LCCB
		LCALL	PUSHAS				;PUSH R2:R0 TO ARGUMENT
		LCALL	FLOATING_MUL
		MOV	R0,ARG_STACK
		DEC	R0
		MOV	A,@R0
		INC	R0
		JZ	LMETER1
		CLR	A
		MOV	@R0,A
LMETER1:	MOV	A,@R0
		CJNE	A,#80h,$+3
		JC	LMETER2
		CLR	A
		MOV	@R0,A
LMETER2:	MOV	LCDLINE+14,#'n'
		MOV	DPTR,#FPnF
		JZ	LMETER3
		CJNE	A,#7Bh,$+3
		JC	LMETER3
		MOV	LCDLINE+14,#'u'
		MOV	DPTR,#FPuH
		CJNE	A,#7Eh,$+3
		JC	LMETER3
		MOV	LCDLINE+14,#'m'
		MOV	DPTR,#FPmH
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
		MOV	A,#40h				;Output result
		ACALL	LCDSETADR
		MOV	R0,#LCDLINE
		MOV	R7,#10h
		ACALL	LCDPRINTSTR
		RET

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

;------------------------------------------------------------------
;Multiply R7:R6:R5:R4 by 10
;------------------------------------------------------------------
INTMUL10:	MOV	A,R4
		MOV	R0,A
		MOV	A,R5
		MOV	R1,A
		MOV	A,R6
		MOV	R2,A
		MOV	A,R7
		MOV	R3,A
		ACALL	INTMUL2
		ACALL	INTMUL2
		MOV	A,R4
		ADD	A,R0
		MOV	R4,A
		MOV	A,R5
		ADDC	A,R1
		MOV	R5,A
		MOV	A,R6
		ADDC	A,R2
		MOV	R6,A
		MOV	A,R7
		ADDC	A,R3
		MOV	R7,A
INTMUL2:	MOV	A,R4
		ADD	A,R4
		MOV	R4,A
		MOV	A,R5
		ADDC	A,R5
		MOV	R5,A
		MOV	A,R6
		ADDC	A,R6
		MOV	R6,A
		MOV	A,R7
		ADDC	A,R7
		MOV	R7,A
		RET
		
;------------------------------------------------------------------
;Wait loop. Waits 1 second
;------------------------------------------------------------------
WAITASEC:	MOV	R7,#0F9h
		MOV	R6,#51
		MOV	R5,#16
WAITASEC1:	DJNZ	R7,WAITASEC1
		DJNZ	R6,WAITASEC1
		DJNZ	R5,WAITASEC1
		RET

;------------------------------------------------------------------
;Wait loop. Waits 0.256 seconds
;------------------------------------------------------------------
WAIT256MS:	MOV	R7,#0F9h
		MOV	R6,#51
		MOV	R5,#02
WAIT256MS1:	DJNZ	R7,WAIT256MS1
		DJNZ	R6,WAIT256MS1
		DJNZ	R5,WAIT256MS1
		RET

;------------------------------------------------------------------
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

;------------------------------------------------------------------
;Frequency counter. LSB from 74HC590 read at P0, TL0, TH0 and
;TF0 bit. 25 bits total, max 33554431 Hz
;IN:	A Channel (0-3)
;OUT:	32 Bit result in R7:R6:R5:R4
;------------------------------------------------------------------
FRQCOUNT:	PUSH	ACC
		SETB	P1.3				;DISABLE 74HC590 COUNT
		CLR	P1.2				;RESET 74HC590
		SETB	P1.2
		;Select channel
		MOV	C,ACC.0
		MOV	P1.0,C
		MOV	C,ACC.1
		MOV	P1.1,C
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
		JZ	FRQCOUNT1
		DEC	A
		JZ	FRQCOUNT1
		CLR	P1.3				;ENABLR 74HC590 COUNT
		ACALL	WAIT256MS
		SETB	P1.3				;DISABLE 74HC590 COUNT
		SJMP	FRQCOUNT2
FRQCOUNT1:	CLR	P1.3				;ENABLR 74HC590 COUNT
		ACALL	WAITASEC
		SETB	P1.3				;DISABLE 74HC590 COUNT
FRQCOUNT2:	MOV	A,P0				;8 BITS FROM 74HC590
		MOV	R4,A
		MOV	A,TL0				;8 BITS FROM TL0
		MOV	R5,A
		MOV	A,TH0				;8 BITS FROM TH0
		MOV	R6,A
		CLR	A				;TF0 Is the 25th bit
		MOV	C,TF0
		RLC	A
		MOV	R7,A
		RET

;------------------------------------------------------------------
;Format frequency conter text line
;	LCDLINE+4 Decimal result
;	R7 Number of digits
;OUT:	Formatted LCDLINE
;------------------------------------------------------------------
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

;------------------------------------------------------------------
;LCD Output.
;------------------------------------------------------------------
IF DEBUG=1
TXBYTE:		MOV	SBUF,A
		JNB	TI,$
		CLR	TI
		RET
ENDIF

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
LCDCHROUT:
IF DEBUG=1
		AJMP	TXBYTE
ENDIF
		PUSH	ACC
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
IF DEBUG=1
		MOV	A,#0DH
		ACALL	LCDCHROUT
		MOV	A,#0AH
		ACALL	LCDCHROUT
ENDIF
		RET

PRNTCDPTRLCD:	CLR	A
		MOVC	A,@A+DPTR
		JZ	PRNTCDPTRLCD1
		ACALL	LCDCHROUT
		INC	DPTR
		SJMP	PRNTCDPTRLCD
PRNTCDPTRLCD1:
IF DEBUG=1
		MOV	A,#0DH
		ACALL	LCDCHROUT
		MOV	A,#0AH
		ACALL	LCDCHROUT
ENDIF
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

LCDCLEARBUFF:	MOV	R0,#LCDLINE
		MOV	R7,#10h
		MOV	A,#20H
LCDCLEARBUFF1:	MOV	@R0,A
		INC	R0
		DJNZ	R7,LCDCLEARBUFF1
		RET

		ORG	0800h

$INCLUDE	(FP52INT.a51)

MODE0:		DB	'Cali'
		DB	'brat'
		DB	'e',0
MODE1:		DB	'C Me'
		DB	'ter',0
MODE2:		DB 	'L Me'
		DB	'ter',0
MODE3:		DB	'Frq '
		DB	'Coun'
		DB	't',0
MODE4:		DB	'Frq '
		DB	'Coun'
		DB	't 1G'
		DB	'Hz',0
WELCOME:	DB	'Welc'
		DB	'ome '
		DB	'Keti'
		DB	'l',0

BINDEC:		DB	000h,0CAh,09Ah,03Bh		;1000000000
		DB	000h,0E1h,0F5h,005h		; 100000000
		DB	080h,096h,098h,000h		;  10000000
		DB	040h,042h,0Fh,0000h		;   1000000
		DB	0A0h,086h,001h,000h		;    100000
		DB	010h,027h,000h,000h		;     10000
		DB	0E8h,003h,000h,000h		;      1000
		DB	064h,000h,000h,000h		;       100
		DB	00Ah,000h,000h,000h		;        10
		DB	001h,000h,000h,000h		;         1

FPONE:		DB 	81h,00h,00h			;1.0000000
		DB	00h,00h,10h
FPTWO:		DB 	81h,00h,00h			;2.0000000
		DB	00h,00h,20h
FPPI:		DB	81h,00h,27h			;3.1415927
		DB	59h,41h,31h
FPCCAL:		DB	78h,00h,00h			;1nF=1e-9 Calibration Capasitor
		DB	00h,00h,10h
FPpF:		DB	8Dh,00h,00h			;1e12 Pico Farad
		DB	00h,00h,10h
FPnF:		DB	8Ah,00h,00h			;1e9 Nano Farad or Nano Henry
		DB	00h,00h,10h
FPuH:		DB	87h,00h,00h			;1e6 Micro Henry
		DB	00h,00h,10h
FPmH:		DB	84h,00h,00h			;1e3 Milli Henry
		DB	00h,00h,10h

		END

