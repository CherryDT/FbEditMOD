
;PORT 1
;P1.0			OUT:	+5V On	
;P1.1			OUT:	RST
;P1.2			OUT:	SCK
;P1.3			OUT:	MISO
;P1.4			IN:		MOSI
;P1.5
;P1.6
;P1.7

				ORG		2000

START:			CLR		IE.1				;Disable T0 int
				MOV		P1,#00				;P1 all low
				ACALL	$EPROM
				SETB	IE.1				;Enable T0 int
				RET

;RS232
;------------------------------------------------------------------
PRNTSTR:		POP		DPH
				POP		DPL
PRNTSTR1:		CLR		A
				MOVC	A,@A+DPTR
				INC		DPTR
				JZ		$PRNTSTR2
				ACALL	$TXBYTE
				SJMP	$PRNTSTR1
PRNTSTR2:		PUSH	DPL
				PUSH	DPH
				RET

PRNTCRLF:		MOV		A,#0D
				ACALL	$TXBYTE
				MOV		A,#0A
				ACALL	$TXBYTE
				RET

HEXOUT:			PUSH	ACC
				SWAP	A
				ACALL	$HEXOUT1
				POP		ACC
HEXOUT1:		ANL		A,#0F
				CLR		C
				SUBB	A,#0A
				JC		$HEXOUT2
				ADD		A,#07
HEXOUT2:		ADD		A,#3A
				ACALL	$TXBYTE
				RET

GETBYTE:		MOV		A,$2C				;No of bytes
				JZ		$GETBYTE1
				PUSH	$00					;Save R0
				CLR		IE.4				;RI/TI int off
				DEC		$2C					;No of bytes
				MOV		A,$2D				;Sertail
				ADD		A,#30
				MOV		R0,A
				INC		A
				ANL		A,#0F
				MOV		$2D,A
				MOV		A,@R0
				POP		$00					;Restore R0
				SETB	IE.4				;RI/TI int on
				CLR		C
				RET
GETBYTE1:		CLR		P3.5				;Handshake
				SETB	C
				RET

RXBYTE:			ACALL	$GETBYTE
				JC		$RXBYTE
				RET

TXBYTE:			JNB		SCON.1,$TXBYTE
				CLR		SCON.1
				MOV		SBUF,A
				RET

;------------------------------------------------------------------

EPROM:			ACALL	$MENU
				CJNE	A,#94,$EXITEPROM
				ACALL	$ROMINSERT
				MOV		A,$27
				DEC		A
				JNZ		$EPROM2
				ACALL	$ROMERASED
				SJMP	$EPROM
EPROM2:			DEC		A
				JNZ		$EPROM3
				ACALL	$ROMDUMPF
				SJMP	$EPROM
EPROM3:			DEC		A
				JNZ		$EPROM4
				ACALL	$ROMDUMPS
				SJMP	$EPROM
EPROM4:			DEC		A
				JNZ		$EPROM5
				ACALL	$ROMVERIFY
				SJMP	$EPROM
EPROM5:			ACALL	$ROMPROG
				SJMP	$EPROM
EXITEPROM:		MOV		A,#0E				;CLS
				ACALL	$TXBYTE
				RET

ROMINSERT:		ACALL	$ROMOFF
				ACALL	$PRNTSTR
				DB		0B,2A,23,'Insert ',00
				MOV		A,$28
				DEC		A
				JNZ		$ROMINSERT1
				ACALL	$PRNTSTR
				DB		'4K',00
				MOV		R7,#10
ROMINSERT1:		DEC		A
				JNZ		$ROMINSERT2
				ACALL	$PRNTSTR
				DB		'8K',00
				MOV		R7,#20
ROMINSERT2:		DEC		A
				JNZ		$ROMINSERT3
				ACALL	$PRNTSTR
				DB		'16K',00
				MOV		R7,#40
ROMINSERT3:		DEC		A
				JNZ		$ROMINSERT4
				ACALL	$PRNTSTR
				DB		'32K',00
				MOV		R7,#80
ROMINSERT4:		DEC		A
				JNZ		$ROMINSERT5
				ACALL	$PRNTSTR
				DB		'64K',00
				MOV		R7,#00
ROMINSERT5:		ACALL	$PRNTSTR
				DB		' device and strike <Enter> ',00
				ACALL	$RXBYTE
				ACALL	$PRNTSTR
				DB		0B,2A,23,'                                       '
				DB		0D,00
				RET

WAIT100:		PUSH	$07
				MOV		R7,#2E
WAIT1001:		DJNZ	R7,$WAIT1001
				POP		$07
				RET

WAIT:			XCH		A,R7
WAIT1:			ACALL	$WAIT100
				DJNZ	R7,$WAIT1
				XCH		A,R7
				RET

ROMON:			SETB	P1.0				;+5V On
				MOV		A,#0A
				ACALL	$WAIT
				SETB	P1.1				;RST H
				RET

ROMOFF:			CLR		P1.1				;RST L
				MOV		A,#01
				ACALL	$WAIT
				MOV		P1,#10				;+5V Off, P1.4 As Input
				MOV		A,#0A
				ACALL	$WAIT
				RET

ROMINITPGM:		MOV		A,#0AC
				ACALL	$ISPCOMM
				MOV		A,#53
				ACALL	$ISPCOMM
				MOV		A,#00
				ACALL	$ISPCOMM
				MOV		A,#00
				ACALL	$ISPCOMM
				CJNE	A,#69,$ROMINITPGM1
				RET
ROMINITPGM1:	ACALL	$PRNTSTR
				DB		0B,2A,23,'Initialisation Error <Enter> ',00
				ACALL	$RXBYTE
				SETB	C
				RET

ROMRDBYTE:		MOV		A,#20
				ACALL	$ISPCOMM
				MOV		A,DPH
				ACALL	$ISPCOMM
				MOV		A,DPL
				ACALL	$ISPCOMM
				MOV		A,#00
				ACALL	$ISPCOMM
				RET

ROMERASED:		MOV		DPTR,#0000
				ACALL	$ROMON
				ACALL	$ROMINITPGM
				JC		$ROMERASEDEXIT
ROMERASED1:		ACALL	$ROMRDBYTE
				CJNE	A,#0FF,$ROMERASEDERR
				INC		DPTR
				MOV		A,DPL
				CJNE	A,#00,$ROMERASED1
				MOV		A,DPH
				CJNE	A,$07,$ROMERASED1
ROMERASEDEXIT:	ACALL	$ROMOFF
				RET
ROMERASEDERR:	ACALL	$ROMOFF
				ACALL	$PRNTSTR
				DB		0B,2A,23,'Byte at ',00
				MOV		A,DPH
				ACALL	$HEXOUT
				MOV		A,DPL
				ACALL	$HEXOUT
				ACALL	$PRNTSTR
				DB		' not erased <Enter> ',00
				ACALL	$RXBYTE
				SETB	C
				RET

ROMDUMPF:		MOV		DPTR,#0000
				ACALL	$ROMON
				ACALL	$ROMINITPGM
				JC		$ROMDUMPFEXIT
ROMDUMPF1:		ACALL	$ROMRDBYTE
;				CJNE	A,#0FF,$ROMERASEDERR
				INC		DPTR
				MOV		A,DPL
				CJNE	A,#00,$ROMDUMPF1
				MOV		A,DPH
				CJNE	A,$07,$ROMDUMPF1
ROMDUMPFEXIT:	ACALL	$ROMOFF
				RET

ROMDUMPS:		MOV		DPTR,#0000
				ACALL	$ROMON
				ACALL	$ROMINITPGM
				JC		$ROMDUMPSEXIT
ROMDUMPS1:		ACALL	$ROMRDBYTE
				ACALL	$HEXOUT
				MOV		A,#20
				ACALL	$TXBYTE
				INC		DPTR
				MOV		A,DPL
				CJNE	A,#00,$ROMDUMPS1
				ACALL	$PRNTCRLF
				ACALL	$RXBYTE
				CJNE	A,#9F,$ROMDUMPS2		;Esc
				SJMP	$ROMDUMPSEXIT
ROMDUMPS2:		MOV		A,DPH
				CJNE	A,$07,$ROMDUMPS1
ROMDUMPSEXIT:	ACALL	$ROMOFF
				RET

ROMVERIFY:
				RET

ROMPROG:
				RET

MENU:			ACALL	$PRNTSTR
				DB		0E
				DB		'   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',0D,0A
				DB		'   ³  Action       ³  ³  EEPROM size  ³  ³  Mode         ³',0D,0A
				DB		'   ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´´',0D,0A
				DB		'   ³  Test erased  ³  ³  4K           ³  ³  Byte         ³³',0D,0A
				DB		'   ³  Filedump     ³  ³  8K           ³  ³  Page         ³³',0D,0A
				DB		'   ³  Screendump   ³  ³  16K          ³  ³               ³³',0D,0A
				DB		'   ³  Verify       ³  ³  32K          ³  ³               ³³',0D,0A
				DB		'   ³  Program      ³  ³  64K          ³  ³               ³³',0D,0A
				DB		'   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',0D,0A
				DB		00
				MOV		R0,#28
				ACALL	$MENUSET
				INC		R0
				ACALL	$MENUSET
				INC		R0
				ACALL	$MENUSET
				MOV		R0,#27
				ACALL	$MENUXP
				RET

MENUXP:			ACALL	$MENUSET
				MOV		A,#08
				LCALL	$TXBYTE
				LCALL	$RXBYTE
				CJNE	A,#9A,$MENUXP1
				MOV		A,@R0
				DEC		A
				JZ		$MENUXP
				MOV		A,#20
				LCALL	$TXBYTE
				DEC		@R0
				SJMP	$MENUXP
MENUXP1:		CJNE	A,#9B,$MENUXP2
				MOV		A,@R0
				SUBB	A,#05
				JZ		$MENUXP
				MOV		A,#20
				LCALL	$TXBYTE
				INC		@R0
				SJMP	$MENUXP
MENUXP2:		CJNE	A,#9C,$MENUYP1
				MOV		A,R0
				SUBB	A,#2A
				JZ		$MENUXP
				INC		R0
				SJMP	$MENUXP
MENUYP1:		CJNE	A,#9D,$MENUYP2
				MOV		A,R0
				SUBB	A,#27
				JZ		$MENUXP
				DEC		R0
				SJMP	$MENUXP
MENUYP2:		CJNE	A,#9F,$MENUYP3		;Esc
				RET
MENUYP3:		CJNE	A,#94,$MENUXP		;Insert
				RET

MENUSET:		MOV		A,#0B
				LCALL	$TXBYTE
				MOV		A,@R0
				ADD		A,#22
				LCALL	$TXBYTE
				MOV		A,R0
				SUBB	A,#27
				MOV		B,#13
				MUL		AB
				ADD		A,#24
				LCALL	$TXBYTE
				MOV		A,#0FB				;û
				LCALL	$TXBYTE
				RET

;------------------------------------------------------------------
;IN A, OUT A
ISPCOMM:		PUSH	$07
				MOV		R2,#08
ISPCOMM1:		RLC		A
				MOV		P1.3,C					;MISO
				MOV		C,P1.4					;MOSI
				XCH		A,R7
				RLC		A
				XCH		A,R7
				SETB	P1.2					;SCK H
				CLR		P1.2					;SCK L
				DJNZ	R2,$ISPCOMM1
				MOV		A,R7
				POP		$07
				RET

;------------------------------------------------------------------
