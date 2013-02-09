;***********************************************************************
;
; The following values MUST be provided by the user
;
;***********************************************************************
;
ARG_STACK	EQU	24H				;ARGUMENT STACK POINTER
FORMAT		EQU	25H				;LOCATION OF OUTPUT FORMAT BYTE
INTGRC		BIT	26H.1				;BIT SET IF INTEGER ERROR
ADD_IN		BIT	26H.3				;DCMPXZ IN BASIC BACKAGE
ZSURP		BIT	26H.6				;ZERO SUPRESSION FOR HEX PRINT
CONVT		EQU	27H				;String addr TO CONVERT NUMBERS
;
;***********************************************************************
;
; The following equates are used internally
;
;***********************************************************************
;
FP_NUMBER_SIZE	EQU	6
DIGIT		EQU	4
R0B0		EQU	0
R1B0		EQU	1
UNDERFLOW	EQU	0
OVERFLOW	EQU	1
ZERO		EQU	2
ZERO_DIVIDE	EQU	3
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
FP_STATUS	EQU	28H				;28 NOT used data pointer me
FP_TEMP		EQU	FP_STATUS+1			;29 NOT USED
FP_CARRY	EQU	FP_STATUS+2			;2A USED FOR BITS
FP_DIG12	EQU	FP_CARRY+1			;2B
FP_DIG34	EQU	FP_CARRY+2			;2C
FP_DIG56	EQU	FP_CARRY+3			;2D
FP_DIG78	EQU	FP_CARRY+4			;2E
FP_SIGN		EQU	FP_CARRY+5			;2F
FP_EXP		EQU	FP_CARRY+6			;30
MSIGN		BIT	FP_SIGN.0			;2F.0
XSIGN		BIT	FP_CARRY.0			;2A.0
FOUND_RADIX	BIT	FP_CARRY.1			;2A.1
FIRST_RADIX	BIT	FP_CARRY.2			;2A.2
DONE_LOAD	BIT	FP_CARRY.3			;2A.3
FP_NIB1		EQU	FP_DIG12			;2B
FP_NIB2		EQU	FP_NIB1+1			;2C
FP_NIB3		EQU	FP_NIB1+2			;2D
FP_NIB4		EQU	FP_NIB1+3			;2E
FP_NIB5		EQU	FP_NIB1+4			;2F
FP_NIB6		EQU	FP_NIB1+5			;30
FP_NIB7		EQU	FP_NIB1+6			;31
FP_NIB8		EQU	FP_NIB1+7			;32
FP_ACCX		EQU	FP_NIB1+8			;33
FP_ACCC		EQU	FP_NIB1+9			;34
FP_ACC1		EQU	FP_NIB1+10			;35
FP_ACC2		EQU	FP_NIB1+11			;36
FP_ACC3		EQU	FP_NIB1+12			;37
FP_ACC4		EQU	FP_NIB1+13			;38
FP_ACC5		EQU	FP_NIB1+14			;39
FP_ACC6		EQU	FP_NIB1+15			;3A
FP_ACC7		EQU	FP_NIB1+16			;3B
FP_ACC8		EQU	FP_NIB1+17			;3C
FP_ACCS		EQU	FP_NIB1+18			;3D

LCDLINE		EQU	40h				;16 Bytes
FPCHR_OUT	EQU	50h				;Holds addrss to next byte during FP number convertion
MODE		EQU	51h				;Current mode (0-4)
LCF1		EQU	60H+FP_NUMBER_SIZE-1		;LC Meter F1
LCF2		EQU	68h+FP_NUMBER_SIZE-1		;LC Meter F2
LCF3		EQU	70h+FP_NUMBER_SIZE-1		;LC Meter F3
LCCA		EQU	78h+FP_NUMBER_SIZE-1		;((F1/F2)^2)-1
LCCB		EQU	80h+FP_NUMBER_SIZE-1		;((1/2*Pi*F1)^2)*LCCA
LCCT		EQU	88h+FP_NUMBER_SIZE-1		;Temp
MCUSTACK	EQU	90h
FPSTACK		EQU	0FFh

MODEMAX		EQU	4

