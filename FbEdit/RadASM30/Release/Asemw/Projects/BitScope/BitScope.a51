$NOPAGING
$PAGEWIDTH (250) ;250 columns per line
$NOTABS          ;expand tabs
$NOSYMBOLS

DEVMODE		EQU 1
DEBUG		EQU 0
USB		EQU 1

$INCLUDE	(BitScope.inc)

IF DEVMODE=0
;RESET:***********************************************
		ORG	0000h
		LJMP	START0
;IE0IRQ:**********************************************
		ORG	0003h
		JB	INTBITS.0,$+4
		RETI
		LJMP	2003h
;TF0IRQ:**********************************************
		ORG	000Bh
		JB	INTBITS.1,$+4
		RETI
		LJMP	200Bh
;IE1IRQ:**********************************************
		ORG	0013h
		JB	INTBITS.2,$+4
		RETI
		LJMP	2013h
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

ELSE
;RESET:***********************************************
		ORG	2000h
		LJMP	START0
;IE0IRQ:**********************************************
		ORG	2003h
		RETI
;TF0IRQ:**********************************************
		ORG	200Bh
		RETI
;IE1IRQ:**********************************************
		ORG	2013h
		LJMP	SINGLESTEP
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

ENDIF


IF DEVMODE=0
		ORG	0040h
ELSE
		ORG	2040h
ENDIF

START0:		CLR	A
		MOV	IE,A				;Disable all interrupts
		MOV	INTBITS,A			;RAM int routines (.0-.5 INTERRUPTS, .6=LCD OUT, .7 Single step)
		DEC	A
		MOV	SSADRLSB,A			;Single step adress
		MOV	SSADRMSB,A			;Single step adress
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

IF DEVMODE=1
		MOV	INTBITS,#3Fh			;Redirect all interrupts
	IF DEBUG=1
		SETB	INTBITS.7			;Set single step flag
		CLR	IT1				;Level triggered
		SETB	EX1				;Enable INT1
		SETB	EA				;Enable interrupts
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

ACALL	TESTDAC

		AJMP	TERMINAL			;RS232 Terminal

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
TERMINAL9:	CJNE	A,#52h,TERMINAL11
		;Run
		ACALL	PRNTCMND
		ACALL	RUN
		SJMP	TERMINAL
TERMINAL11:	CJNE	A,#53h,TERMINAL12
		;SFR dump
		LCALL	PRNTCMND
		ACALL	DUMPSFR
		SJMP	TERMINAL1
TERMINAL12:	CJNE	A,#9Fh,TERMINAL13
		;Esc
		LJMP	0000h
TERMINAL13:	CJNE	A,#0Dh,TERMINAL2
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

PRINTSTR:;	JNB	INTBITS.6,PRINTSTRLCD
PRINTSTRTRM:	MOV	A,@R0
		ACALL	TXBYTE
		INC	R0
		DJNZ	R7,PRINTSTRTRM
		ACALL	PRNTCRLF
		RET

PRINTDPTRSTR:	MOVX	A,@DPTR
		ACALL	TXBYTE
		INC	DPTR
		CJNE	A,#0Dh,PRINTDPTRSTR
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
		MOV	R0,#BUFFER
RX16BYTES1:	ACALL	RXBYTE
		MOV	@R0,A
		INC	R0
		CJNE	R0,#BUFFER+10h,RX16BYTES1
		MOV	R0,#BUFFER
		RET

IF USB=0

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

ELSE

RXBYTE:		JB	USBRXF,$
		PUSH	DPL
		PUSH	DPH
		MOV	DPTR,#USBIO
		MOVX	A,@DPTR
		POP	DPH
		POP	DPL
		RET

TXBYTE:		JB	USBTXE,TXBYTE
		PUSH	DPL
		PUSH	DPH
		MOV	DPTR,#USBIO
		MOVX	@DPTR,A
		POP	DPH
		POP	DPL
		RET

ENDIF

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
		DB	'G Go (Load and Run)',0Dh,0Ah
		DB	'H Help',0Dh,0Ah
		DB	'I Internal memory dump',0Dh,0Ah
		DB	'L Load cmd file',0Dh,0Ah
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

;BitScope
;==================================================================

TESTDAC:	MOV	A,#00110000b
		ACALL	SETDACVAL
		INC	B
		JB	USBRXF,TESTDAC
		RET

;Set DAC value, first call SETDACCMD then call SETDACVAL
;------------------------------------------------------------------
;In	A Contains DAC command
;	B Contains DAC value
;Out	Nothing
SETDACVAL:	MOV	R7,A				;Save DAC CMD
		MOV	R0,#LOW ADCCTLRDWR		;Select MCU and RDWR3
		MOV	P2,#HIGH ADCCTLRDWR
		CLR	A				;ADCMCU LOW
		SETB	ADCMR
		ORL	A,#RDWR3
		MOVX	@R0,A
		MOV	R0,#LOW ADCRDWR
		CLR	A				;DACCS=0, DACCLK=0, DACBIT=0
		SETB	TRIGSET
		SETB	TRIGRESET
		MOVX	@R0,A
		MOV	A,R7				;Restore DAC CMD
		MOV	R7,#04h
SETDACVAL1:	ACALL	CLOCKDACBIT
		DJNZ	R7,SETDACVAL1
		MOV	R7,#08h
		MOV	A,B
SETDACVAL2:	ACALL	CLOCKDACBIT
		DJNZ	R7,SETDACVAL2
		CLR	A				;DACCS=0, DACCLK=0, DACBIT=0
		SETB	TRIGSET
		SETB	TRIGRESET
		SETB	DACCS				;ADCCS=1
		MOVX	@R0,A
		RET

CLOCKDACBIT:	RLC	A
		PUSH	ACC
		CLR	A
		SETB	TRIGSET
		SETB	TRIGRESET
		MOV	DACBIT,C
		MOVX	@R0,A
		SETB	DACCLK
		MOVX	@R0,A
		CLR	DACCLK
		MOVX	@R0,A
		POP	ACC
		RET

;Read ADC or LA RAM
;------------------------------------------------------------------
;In	A Contains wich ram to read (RDWR0 to RDWR3)
;Out	Nothing
READADCRAM:	MOV	R0,#LOW ADCCTLRDWR		;Select MCU and reset address counter
		MOV	P2,#HIGH ADCCTLRDWR
		MOVX	@R0,A				;ADCMCU and ADCMR LOW
		SETB	ADCMR
		MOVX	@R0,A
		MOV	R0,#LOW ADCRDWR
		MOV	R1,#LOW USBIO
		MOV	R6,#00h
		MOV	R7,#80h
READADCRAM1:	MOVX	A,@R0				;Read a byte
		JB	USBTXE,$			;Wait until USB ready
		MOVX	@R1,A				;Send it
		DJNZ	R6,READADCRAM1
		DJNZ	R7,READADCRAM1
		RET

;Frequency counter
;------------------------------------------------------------------
FRQCOUNT:	MOV	R0,#LOW ADCCTLRDWR		;Select MCU and reset address counter
		MOV	P2,#HIGH ADCCTLRDWR
		MOV	A,#RDWR3			;RDWR3 selected
		MOVX	@R0,A				;ADCMCU and ADCMR LOW
		SETB	ADCMR
		MOVX	@R0,A
		MOV	DPTR,#0000h
		MOV	R1,#LOW ADCRDWR
		MOV	R4,#00h
		MOV	R5,#0A0h
		MOV	R6,#86h
		MOV	R7,#02h
		CLR	A
		SETB	TRIGSET
		SETB	TRIGRESET
		SETB	DACCS
		MOV	R3,A
		SETB	FRQCNT
		MOVX	@R1,A				;Enable address counter
FRQCOUNT1:	MOVX	A,@R0				;2 Test address counter bit 16
		ANL	A,#01h				;1
		XRL	A,R4				;1
		JZ	FRQCOUNT2			;2
		MOV	R4,A				;1
		INC	DPTR				;2
		SJMP	FRQCOUNT3			;2
FRQCOUNT2:	NOP					;1
		NOP					;1
		NOP					;1
		NOP					;1
		NOP					;1
FRQCOUNT3:	NOP					;1
		NOP					;1
		DJNZ	R5,FRQCOUNT1			;2 Total 20 cycles, 10us
		DJNZ	R6,FRQCOUNT1			;2
		DJNZ	R7,FRQCOUNT1			;2
		MOV	A,R3				;1
		MOVX	@R1,A				;2 Disableaddress counter 
		MOVX	A,@R0
		ANL	A,#01h
		XRL	A,R4
		JZ	FRQCOUNT4
		MOV	R4,A
		INC	DPTR
FRQCOUNT4:	CLR	C				;DPTR contains high 16 bits of frequency*2
		MOV	A,DPH
		RRC	A
		MOV	57h,A
		MOV	A,DPL
		RRC	A
		MOV	56h,A
		MOV	DPTR,#0FFFFh			;Get the lower 16 bytes
		MOVX	A,@R0
		ANL	A,#01h
		MOV	R3,A
		JNZ	FRQCOUNT5
		MOV	DPTR,#7FFFh
FRQCOUNT5:	INC	DPTR
		MOVX	A,@R1				;Increment address counter
		MOVX	A,@R0
		ANL	A,#01h
		CJNE	A,03h,FRQCOUNT5			;Compare to R3
		CLR	A
		SUBB	A,DPL
		MOV	54h,A
		CLR	A
		SUBB	A,DPH
		MOV	55h,A
		RET

		END
