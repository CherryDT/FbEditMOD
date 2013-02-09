;*****************************************************
;Interrupt vectors.
;-----------------------------------------------------
;RESET		0000
;IE0		0003
;TF0		000B
;IE1		0013
;TF1		001B
;RI & TI	0023
;TF2 & EXF2	002B
;-----------------------------------------------------
;*****************************************************
;PORT 1
;-----------------------------------------------------
;P1.0		OUT:	+5V On
;P1.1		OUT:	RST
;P1.2		OUT:	SCK
;P1.3		OUT:	MISO
;P1.4		IN:	MOSI
;P1.5
;P1.6
;P1.7
;-----------------------------------------------------
;*****************************************************
;Internal RAM Locations
;-----------------------------------------------------
;20		Interrupt control bit flags
;		D0			If set INT0 interrupt jumps to 2003h
;		D1			If set TIMER0 interrupt jumps to 200Bh
;		D2			If set INT1 interrupt jumps to 2013h
;		D3			If set TIMER1 interrupt jumps to 201Bh
;		D4			If set RI/TI interrupt jumps to 2023h
;		D5			If set TIMER2 interrupt jumps to 202Bh
;		D6			If set output is to terminal instead of LCD
;		D7			If set single stepping is enabled
;21		D6			OUTPUT PORT #8000
;		D7
;24		ARG_STACK		ARGUMENT STACK POINTER
;25		FORMAT			LOCATION OF OUTPUT FORMAT BYTE
;26.1		INTGRC			BIT SET IF INTEGER ERROR
;26.3		ADD_IN			DCMPXZ IN BASIC BACKAGE
;26.6		ZSURP			ZERO SUPRESSION FOR HEX PRINT
;28-3D		FP WORK AREA
;40-4F		ROMBUFF / LCDLINE 	16 Bytes
;50		FPCHR_OUT		Holds addrss to next byte during FP number convertion
;51		ROMVER			Byte to be verified
;52		ROMPAGES		Number of pages
;53		ROMACTION		Menu pos
;54		ROMSIZE			Menu pos
;55		ROMMODE			Menu pos
;56		ROMVERERR		Number of verify errors
;57		DPLSAVE			Holds DPL during PRNTCSTR
;58		DPHSAVE			Holds DPH during PRNTCSTR
;59		MODE			Selected mode (0-7)
;5A		SSADRLSB		Single step adress
;5B		SSADRMSB		Single step adress
;60		LCF1
;68		LCF2
;70		LCF3

;C0-FF		48 Byte stack

;External RAM Locations
;-----------------------------------------------------
;0048		EXTERNAL RAM FP NUMBER INPUT AREA
;0100		EXTERNAL RAM FP STACK
;8000		MEMORU MAPPED I/O
;8001		MEMORU MAPPED I/O

;-----------------------------------------------------
;*****************************************************
;SCREEN DRIVER
;-----------------------------------------------------
;01		START SEND ROMDATA.HEX FILE
;02		STOP SEND FILE
;03		START RECIEVE ROMDATA.HEX FILE
;04		STOP RECIEVE FILE
;05		START RECIEVE FILE IN 16 BYTE BLOCKS
;06		STOP RECIEVE FILE IN 16 BYTE BLOCKS
;07		BELL
;08		BACK SPACE
;09		TAB
;0A		LF
;0B		LOCATE
;0C		HOME
;0D		CR
;0E		CLS
;0F		MODE
;10		START SEND CMDFILE.CMD FILE
;-----------------------------------------------------
;*****************************************************
;Memory mapped I/O
;-----------------------------------------------------
;8000h Output
;-----------------------------------------------------
;D0		LCD DB4
;D1		LCD DB5
;D2		LCD DB6
;D3		LCD DB7
;D4		LCD RS
;D5		LCD E
;D6		LC Meter	0=C, 1=L
;D7		LC Meter	0=F1, 1=F2 (Adding C Cal)
;-----------------------------------------------------
;8001h Output
;-----------------------------------------------------
;D0		FRQ SEL A
;D1		FRQ SEL B	00=EXT FRQ,01=FGEN,10=LCMETER,11=ALE
;D2		FRQ GATE	ACTIVE LOW
;D3		FRQ RESET	ACTIVE HIGH
;D4		ADC CS		ACTIVE LOW
;D5		ADC CLK		HIGH TO LOW TRANSITION
;D6		ADC DIN		START,S/D,D2,D1,D0
;D7		FRQ TTL		ACTIVE HIGH
;-----------------------------------------------------
;8000h Input
;-----------------------------------------------------
;D0		FRQ LSB
;D1
;D2
;D3
;D4
;D5
;D6
;D7		FRQ MSB
;-----------------------------------------------------
;8001h Input
;-----------------------------------------------------
;D0		ADC DOUT
;D1
;D2
;D3
;D4
;D5
;D6
;D7

;-----------------------------------------------------
;*****************************************************
;Equates
;-----------------------------------------------------
T2CON		EQU 0C8h
RCAP2L		EQU 0CAh
RCAP2H		EQU 0CBh
TL2		EQU 0CCh
TH2		EQU 0CDh
PT2		BIT 0BDh
MODEMAX		EQU 10
;-----------------------------------------------------
INTBITS		EQU 20h			;Interrupt jump control
OUTD7D6		EQU 21h			;Output port #8000h
ROMBUFF		EQU 40h			;16 Bytes
LCDLINE		EQU 40h			;16 Bytes
FPCHR_OUT	EQU 50h			;Holds addrss to next byte during FP number convertion
ROMVER		EQU 51h			;Byte to be verified
ROMPAGES	EQU 52h			;Number of pages
ROMACTION	EQU 53h			;Menu pos
ROMSIZE		EQU 54h			;Menu pos
ROMMODE		EQU 55h			;Menu pos
ROMVERERR	EQU 56h			;Number of verify errors
DPLSAVE		EQU 57h			;Holds DPL during PRNTCSTR
DPHSAVE		EQU 58h			;Holds DPH during PRNTCSTR
MODE		EQU 59h			;Selected mode (0-7)
SSADRLSB	EQU 5Ah			;Single step adress LSB
SSADRMSB	EQU 5Bh			;Single step adress MSB
;*****************************************************
; The following values MUST be provided by the user
;*****************************************************
ARG_STACK_PAGE	EQU 01H			;External memory page for arg stack
ARG_STACK	EQU 24H			;ARGUMENT STACK POINTER
FORMAT		EQU 25H			;LOCATION OF OUTPUT FORMAT BYTE
INTGRC		BIT 26H.1		;BIT SET IF INTEGER ERROR
ADD_IN		BIT 26H.3		;DCMPXZ IN BASIC BACKAGE
ZSURP		BIT 26H.6		;ZERO SUPRESSION FOR HEX PRINT
;*****************************************************
;XRAM
;*****************************************************
CONVT		EQU 0048H		;String addr TO CONVERT NUMBERS
LCF1		EQU 0060H		;LC Meter F1
LCF2		EQU 0068h		;LC Meter F2
LCF3		EQU 0070h		;LC Meter F3
LCCA		EQU 0078h		;((F1/F2)^2)-1
LCCB		EQU 0080h		;((1/2*Pi*F1)^2)*LCCA
LCCT		EQU 0088h		;Temp
;-----------------------------------------------------
