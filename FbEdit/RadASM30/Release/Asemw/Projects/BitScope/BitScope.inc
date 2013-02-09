
;-----------------------------------------------------
;*****************************************************
;Equates
;-----------------------------------------------------
T2CON		EQU 0C8h
RCAP2L		EQU 0CAh
RCAP2H		EQU 0CBh
TL2		EQU 0CCh
TH2		EQU 0CDh

;BitScope
;-----------------------------------------------------
ADCCTLRDWR	EQU 8000h		;RD D0  ENDSAMPLE
					;RD D1
					;RD D2
					;RD D3
					;RD D4
					;RD D5
					;RD D6
					;RD D7
					;WR D0 | ADCCLKSEL
					;WR D1 |
					;WR D2 |
					;WR D3 | RD0-RD3 or WR0-WR3
					;WR D4 |
					;WR D5   CLK1PHASE
					;WR D6   ADC/MCU
					;WR D7   ADCMR

ADCRDWR		EQU 8001h		;RD0 ADC CHA RAM
					;RD1 LA CHA RAM
					;RD2 ADC CHB RAM
					;RD3 LA CHB RAM
					;WR0 DIVIDE/MAGNIFY ADC CHA
					;WR1 DIVIDE/MAGNIFY ADC CHB
					;WR2
					;WR3 TRIGGER AND DAC CONTROL

ADCCLKMASK	EQU 0F8h
RDWRMASK	EQU 0E7h
RDWR0		EQU 00h			;RD0 ADC CHA, WR0 DIVIDE/MAGNIFY ADC CHA
RDWR1		EQU 08h			;RD1 LA CHA, WR1 DIVIDE/MAGNIFY ADC CHB
RDWR2		EQU 10h			;RD2 ADC CHB, WR2
RDWR3		EQU 18h			;RD3 LA CHB, WR3 TRIGGER AND DAC CONTROL
CLK1PHASE	EQU ACC.5		;CLK1PHASE
ADCMCU		EQU ACC.6		;ADC/MCU L=ADC, H=MCU
ADCMR		EQU ACC.7		;ADCMR L=RESET

TRIGEDGE	EQU ACC.0
TRIGSET		EQU ACC.1
TRIGRESET	EQU ACC.2

DACCS		EQU ACC.3
DACCLK		EQU ACC.4
DACBIT		EQU ACC.5
FRQCNT		EQU ACC.6

;USB
;-----------------------------------------------------
USBIO		EQU 8003h
USBRXF		EQU P3.2
USBTXE		EQU P3.4
;-----------------------------------------------------
;Adresses in internal ram
INTBITS		EQU 20h			;Interrupt jump control
BUFFER		EQU 40h			;16 Bytes
DPLSAVE		EQU 50h			;Holds DPL during PRNTCSTR
DPHSAVE		EQU 51h			;Holds DPH during PRNTCSTR
SSADRLSB	EQU 52h			;Single step adress LSB
SSADRMSB	EQU 53h			;Single step adress MSB
FRQ		EQU 54h			;4 byte frequency.
