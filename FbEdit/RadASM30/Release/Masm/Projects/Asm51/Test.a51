
TEST			EQU 4			;Test
TEST1			EQU TEST+1
TSTBIT			BIT 0F8h.7

				ORG		2000h

START:			MOV		A,#01h
				MOV		A,#TEST
				MOV		A,#TEST1
;				JZ		@F
;@@:				JZ		@B
;@@:				JZ		@B
;				ACALL	RXBYTE
;				LCALL	TXBYTE
;				LCALL	ROMDUMPFILE
;				RET
;
;DATA			db 5,4+2-5,3H,TEST,TEST1
;TEXT			db 'AaBb',0Dh,0Ah,0
;
;ROMDUMPFILE:	MOV		A,#03h
;				LCALL	TXBYTE
;				MOV		DPTR,#0000h
;				MOV		R5,#00h
;ROMDUMPFILE1:	MOV		R2,#10h
;ROMDUMPFILE2:	CLR		A
;				MOVC	A,@A+DPTR
;				LCALL	HEXOUT
;				MOV		A,#20h
;				LCALL	TXBYTE
;				INC		DPTR
;				DJNZ	R2,ROMDUMPFILE2
;				LCALL	PRNTCRLF
;				DJNZ	R5,ROMDUMPFILE1
;				MOV		A,#04h
;				LCALL	TXBYTE
;				RET
;
;PRNTCRLF:		MOV		A,#0Dh
;				LCALL	TXBYTE
;				MOV		A,#0Ah
;				LCALL	TXBYTE
;				RET
;
;DUMPMON:		MOV		DPTR,#0000h
;				MOV		R2,#00h
;				MOV		R3,#20h
;				MOV		R3,#01h
;DUMPMON1:		CLR		A
;				MOVC	A,@A+DPTR
;				ACALL	HEXOUT
;				INC		DPTR
;				DJNZ	R2,DUMPMON1
;				DJNZ	R3,DUMPMON1
;				RET
;
;RECFILE:		MOV		DPTR,#0000h
;				MOV		A,#10h
;				ACALL	TXBYTE
;RECFILE1:		MOV		R2,#00h
;				MOV		R3,#20h
;RECFILE2:		ACALL	GETBYTE
;				JC		RECFILE3
;				MOV		40h,A
;				CLR		A
;				MOVC	A,@A+DPTR
;				INC		DPTR
;				CJNE	A,40,RECFILE4
;				AJMP	RECFILE1
;RECFILE4:		ACALL	HEXOUT
;				MOV		A,40h
;				ACALL	HEXOUT
;				AJMP	RECFILE1
;RECFILE3:		DJNZ	R2,RECFILE2
;				DJNZ	R3,RECFILE2
;				RET
;
;HEXOUT:			PUSH	ACC
;				SWAP	A
;				ACALL	HEXOUT1
;				POP		ACC
;HEXOUT1:		ANL		A,#0Fh
;				CLR		C
;				SUBB	A,#0Ah
;				JC		HEXOUT2
;				ADD		A,#07h
;HEXOUT2:		ADD		A,#3Ah
;				ACALL	TXBYTE
;				RET
;
;GETBYTE:		MOV		A,2Ch				;No of bytes
;				JZ		GETBYTE1
;				PUSH	00h
;				CLR		IE.4				;RI/TI int off
;				DEC		2Ch					;No of bytes
;				MOV		A,2Dh				;Sertail
;				ADD		A,#30h
;				MOV		R0,A
;				INC		A
;				ANL		A,#0Fh
;				MOV		2Dh,A
;				MOV		A,@R0
;				POP		00h
;				SETB	IE.4				;RI/TI int on
;				CLR		C
;				RET
;GETBYTE1:		CLR		P3.5				;Handshake
;				SETB	C
;				RET
;
;TXBYTE:			JNB		SCON.1,TXBYTE
;				CLR		SCON.1
;				MOV		SBUF,A
;				RET
;
;RXBYTE:			JNB		SCON.0,RXBYTE
;				CLR		SCON.0
;				MOV		A,SBUF
;				RET
