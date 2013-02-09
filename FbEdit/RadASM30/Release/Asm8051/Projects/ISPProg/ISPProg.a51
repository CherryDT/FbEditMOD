;*****************************************************
;Interrupt vectors.
;-----------------------------------------------------
;RESET			0000
;IE0			0003
;TF0			000B
;IE1			0013
;TF1			001B
;RI & TI		0023
;TF2 & EXF2		002B
;-----------------------------------------------------
;*****************************************************
;PORT 1
;-----------------------------------------------------
;P1.0			OUT:	+5V On	
;P1.1			OUT:	RST
;P1.2			OUT:	SCK
;P1.3			OUT:	MISO
;P1.4			IN:		MOSI
;P1.5
;P1.6
;P1.7
;-----------------------------------------------------
;*****************************************************
;RAM Locations
;-----------------------------------------------------
;20				Interrupt flags
;21
;22
;23
;24
;25				Rom byte to be verified
;26				Number of pages
;27				PROGROM Action
;28				PROGROM Size
;29             PROGROM Mode
;2A
;2B
;2C
;2D				DPL save
;2E				DPH save
;2F				Number of verify errors
;30-3F
;40-4F			Buffer
;50-7F			Stack
;-----------------------------------------------------
;*****************************************************
;SCREEN DRIVER
;-----------------------------------------------------
;01				START SEND ROMDATA.HEX FILE
;02				STOP SEND FILE
;03				START RECIEVE ROMDATA.HEX FILE
;04				STOP RECIEVE FILE
;05				START RECIEVE FILE IN 16 BYTE BLOCKS
;06				STOP RECIEVE FILE IN 16 BYTE BLOCKS
;07				BELL
;08				BACK SPACE
;09				TAB
;0A				LF
;0B				LOCATE
;0C				HOME
;0D				CR
;0E				CLS
;0F				MODE
;10				START SEND CMDFILE.CMD FILE
;-----------------------------------------------------
;*****************************************************
				ORG		0000h
RESET:			AJMP	$START
;*****************************************************
				ORG		0003h
IE0IRQ:			JB		$00h,$01h				;$20.0
				RETI
				LJMP	$2003h
;*****************************************************
				ORG		000Bh
TF0IRQ:			JB		$01h,$01h				;$20.1
				RETI
				LJMP	$200Bh
;*****************************************************
				ORG		0013h
IE1IRQ:			JB		$02h,$01h				;$20.2
				RETI
				LJMP	$2013h
;*****************************************************
				ORG		001Bh
TF1IRQ:			JB		$03h,$01h				;$20.3
				RETI
				LJMP	$201Bh
;*****************************************************
				ORG		0023h
RITIIRQ:		JB		$04h,$01h				;$20.4
				RETI
				LJMP	$2023h
;*****************************************************
				ORG		002Bh
TF2EXF2IRQ:		JB		$05h,$01h				;$20.5
				RETI
				LJMP	$202Bh
;*****************************************************

				ORG		0040h

START:			MOV		PSW,#00h
				MOV		IE,#00h					;Disable all int's
				MOV		SP,#4Fh					;Init stack pointer. The stack is 48 bytes
				MOV		TMOD,#22h				;T0/T1=8 Bit auto reload
				MOV		TH0,#1Ah				;256-230
				MOV		TL0,#1Ah
				MOV		TH1,#0FDh				;256-22118400/(384*9600) (#0FF=57600)
				MOV		TL1,#0FDh
				MOV		PCON,#80h				;Double baudrate
				MOV		SCON,#76h				;SM0=l
												;SM1=h
												;SM2=h
												;REN=h
												;TB8=h
												;RB8=l
												;TI=h
												;RI=l
				MOV		$20h,#00h				;RAM int routines ($00-$05,$20.0-$20.5)
				MOV		$27h,#01h				;Action
				MOV		$28h,#01h				;Size
				MOV		$29h,#01h				;Mode
				MOV		TCON,#50h				;T0/T1=On
				MOV		R0,#00h
				MOV		DPTR,#2000h
				MOV		R1,#00h
START1:			DJNZ	R0,$START1
				DJNZ	R1,$START1
				CLR		SCON.0
START2:			ACALL	$HELPMENU
START3:			ACALL	$PRNTCRLF
				MOV		A,#3Eh
				ACALL	$TXBYTE
START4:			ACALL	$RXBYTE
				CJNE	A,#41h,$START5
				;Address input
				ACALL	$PRNTCMND
				ACALL	$ADRINPUT
				SJMP	$START3
START5:			CJNE	A,#44h,$START6
				;Dump
				ACALL	$PRNTCMND
				ACALL	$DUMP
				SJMP	$START2
START6:			CJNE	A,#45h,$START7
				;Enter hex
				ACALL	$PRNTCMND
				ACALL	$ENTERHEX
				SJMP	$START2
START7:			CJNE	A,#47h,$START8
				;Go
				ACALL	$PRNTCMND
				ACALL	$GO
				SJMP	$START2
START8:			CJNE	A,#48h,$START9
				;Help
				ACALL	$PRNTCMND
				SJMP	$START2
START9:			CJNE	A,#49h,$START10
				;Internal memory
				ACALL	$PRNTCMND
				ACALL	$MEMDUMP
				SJMP	$START3
START10:		CJNE	A,#4Ch,$START11
				;Load
				ACALL	$PRNTCMND
				ACALL	$LOAD
				SJMP	$START3
START11:		CJNE	A,#50h,$START12
				;Program ROM
				ACALL	$PRNTCMND
				ACALL	$EPROM
				SJMP	$START2
START12:		CJNE	A,#52h,$START13
				;Run
				ACALL	$PRNTCMND
				ACALL	$RUN
				SJMP	$START2
START13:		CJNE	A,#0Dh,$START4
				;CR
				SJMP	$START3

;RS232 Functions
;------------------------------------------------------------------

PRNTSTR:		MOV		$2Dh,DPL
				MOV		$2Eh,DPH
				POP		DPH
				POP		DPL
PRNTSTR1:		CLR		A
				MOVC	A,@A+DPTR
				INC		DPTR
				JZ		$PRNTSTR2
				ACALL	$TXBYTE
				SJMP	$PRNTSTR1
PRNTSTR2:		PUSH	DPL
				PUSH	DPH
				MOV		DPL,$2Dh
				MOV		DPH,$2Eh
				RET

PRNTCMND:		ACALL	$TXBYTE
				ACALL	$PRNTCRLF
				RET

PRNTCRLF:		MOV		A,#0Dh
				ACALL	$TXBYTE
				MOV		A,#0Ah
				ACALL	$TXBYTE
				RET

HEXOUT:			PUSH	ACC
				SWAP	A
				ACALL	$HEXOUT1
				POP		ACC
HEXOUT1:		ANL		A,#0Fh
				CLR		C
				SUBB	A,#0Ah
				JC		$HEXOUT2
				ADD		A,#07h
HEXOUT2:		ADD		A,#3Ah
				ACALL	$TXBYTE
				RET

HEXDPTR:		MOV		A,DPH
				ACALL	$HEXOUT
				MOV		A,DPL
				ACALL	$HEXOUT
				MOV		A,#20h
				ACALL	$TXBYTE
				RET

HEXINPBYTE:		ACALL	$HEXINP
				JC		$HEXINPBYTE1
				SWAP	A
				MOV		R3,A
				ACALL	$HEXINP
				JC		$HEXINPBYTE1
				ADD		A,R3
HEXINPBYTE1:	RET

HEXINP:			ACALL	$HEXINP2
				JC		$HEXINP1
				PUSH	ACC
				MOV		A,R2
				ACALL	$TXBYTE
				POP		ACC
HEXINP1:		RET

HEXINP2:		ACALL	$RXBYTE
				CJNE	A,#9Fh,$HEXINP3			;Esc
				SETB	C
				RET
HEXINP3:		CJNE	A,#0Dh,$HEXINP4			;Cr
				SETB	C
				RET
HEXINP4:		MOV		R2,A
				CJNE	A,#3Ah,$00h
				JNC		$HEXINP5
				CJNE	A,#30h,$00h
				JC		$HEXINP2
				SUBB	A,#30h
				RET
HEXINP5:		CJNE	A,#47h,$00h
				JNC		$HEXINP2
				CJNE	A,#41h,$00h
				JC		$HEXINP2
				SUBB	A,#37h
				RET

INPDPTR:		ACALL	$HEXDPTR
				ACALL	$HEXINPBYTE
				JC		$INPDPTR1
				MOV		DPH,A
				ACALL	$HEXINPBYTE
				JC		$INPDPTR1
				MOV		DPL,A
INPDPTR1:		ACALL	$PRNTCRLF
				RET

RX16BYTES:		PUSH	$01h
				MOV		A,#05h
				ACALL	$TXBYTE
				MOV		R0,#40h
				MOV		R1,#10h
RX16BYTES1:		ACALL	$RXBYTE
				MOV		@R0,A
				INC		R0
				DJNZ	R1,$RX16BYTES1
				POP		$01h
				MOV		R0,#40h
				RET

RXBYTE:			JNB		SCON.0,$RXBYTE
				CLR		SCON.0
				MOV		A,SBUF
				RET

TXBYTE:			JNB		SCON.1,$TXBYTE
				CLR		SCON.1
				MOV		SBUF,A
				RET

;Functions
;------------------------------------------------------------------

HELPMENU:		ACALL	$PRNTSTR
				DB		0Eh
				DB		'A Address input',0Dh,0Ah
				DB		'D Dump as hex',0Dh,0Ah
				DB		'E Enter hex',0Dh,0Ah
				DB		'G Go (Load and Run)',0Dh,0Ah
				DB		'H Help',0Dh,0Ah
				DB		'I Internal memory dump',0Dh,0Ah
				DB		'L Load cmd file',0Dh,0Ah
				DB		'P Program ROM',0Dh,0Ah
				DB		'R Run',0Dh,0Ah,00h
				RET

ADRINPUT:		ACALL	$INPDPTR
				RET

DUMP:			PUSH	DPL
				PUSH	DPH
				PUSH	$02h
				PUSH	$03h
DUMP1:			MOV		R3,#10h
DUMP2:			MOV		R2,#10h
				ACALL	$HEXDPTR
DUMP3:			MOVX	A,@DPTR
				ACALL	$HEXOUT
				MOV		A,#20h
				ACALL	$TXBYTE
				INC		DPTR
				DJNZ	R2,$DUMP3
				ACALL	$PRNTCRLF
				DJNZ	R3,$DUMP2
				ACALL	$PRNTCRLF
				ACALL	$RXBYTE
				CJNE	A,#9Fh,$DUMP1			;Esc
				POP		$03h
				POP		$02h
				POP		DPH
				POP		DPL
				RET

ENTERHEX:		PUSH	DPL
				PUSH	DPH
ENTERHEX1:		ACALL	$HEXDPTR
				ACALL	$HEXINPBYTE
				JC		$ENTERHEX2
				MOVX	@DPTR,A
				INC		DPTR
				ACALL	$PRNTCRLF
				SJMP	$ENTERHEX1
ENTERHEX2:		POP		DPH
				POP		DPL
				RET

MEMDUMP:		PUSH	$00h
				MOV		R0,#00h
MEMDUMP1:		CLR		A
				ACALL	$HEXOUT
				MOV		A,R0
				ACALL	$HEXOUT
				MOV		A,#20h
				ACALL	$TXBYTE
MEMDUMP2:		MOV		A,@R0
				ACALL	$HEXOUT
				MOV		A,#20h
				ACALL	$TXBYTE
				INC		R0
				MOV		A,R0
				ANL		A,#0Fh
				JNZ		$MEMDUMP2
				ACALL	$PRNTCRLF
				MOV		A,R0
				XRL		A,#80h
				JNZ		$MEMDUMP1
				POP		$00h
				RET

LOAD:			PUSH	DPL
				PUSH	DPH
				PUSH	$00h
				PUSH	$03h
				MOV		R3,#80h
LOAD1:			ACALL	$RX16BYTES				;Read 16 bytes from cmd file
				ACALL	$HEXDPTR
LOAD2:			MOV		A,@R0
				MOVX	@DPTR,A
				ACALL	$HEXOUT
				MOV		A,#20h
				ACALL	$TXBYTE
				INC		DPTR
				INC		R0
				MOV		A,R0
				XRL		A,#50h
				JNZ		$LOAD2					;Not 16 bytes yet
				ACALL	$PRNTCRLF
				DJNZ	R3,$LOAD1				;Not 2K yet
				MOV		A,#06h
				ACALL	$TXBYTE					;End read 16 bytes from cmd file
				POP		$03h
				POP		$00h
				POP		DPH
				POP		DPL
				RET

GO:				ACALL	$LOAD
RUN:			CLR		A
				JMP		@A+DPTR

;ROM menu selection
;------------------------------------------------------------------

EPROM:			ACALL	$ROMMENU
				CJNE	A,#94h,$EPROMEXIT
				ACALL	$ROMINSERT
				JC		$EPROM
				LCALL	$ROMINIT				;Turn on VCC, pull RST high and init programming mode
				JC		$EPROM					;Initialisation failed
				MOV		A,$27h
				DEC		A
				JNZ		$EPROM2
				;Test erased
				ACALL	$ROMWAIT
				MOV		A,$29h
				DEC		A
				JNZ		$EPROM1
				ACALL	$BM_ROMERASED
				SJMP	$EPROM
EPROM1:			ACALL	$PM_ROMERASED
				SJMP	$EPROM
EPROM2:			DEC		A
				JNZ		$EPROM3
				;Dump to hex file
				ACALL	$ROMWAIT
				MOV		A,$29h
				DEC		A
				JNZ		$EPROM21
				ACALL	$ROMERASE
				SJMP	$EPROM
EPROM21:		ACALL	$ROMERASE
				SJMP	$EPROM
EPROM3:			DEC		A
				JNZ		$EPROM4
				;Dump to screen
				MOV		A,$29h
				DEC		A
				JNZ		$EPROM31
				ACALL	$BM_ROMDUMPS
				SJMP	$EPROM
EPROM31:		LCALL	$PM_ROMDUMPS
				SJMP	$EPROM
EPROM4:			DEC		A
				JNZ		$EPROM5
				;Verify
				ACALL	$ROMWAIT
				MOV		A,$29h
				DEC		A
				JNZ		$EPROM41
				ACALL	$BM_ROMVERIFY
				SJMP	$EPROM
EPROM41:		LCALL	$PM_ROMVERIFY
				SJMP	$EPROM
EPROM5:			;Program
				ACALL	$ROMWAIT
				MOV		A,$29h
				DEC		A
				JNZ		$EPROM51
				LCALL	$PM_ROMPROG
				SJMP	$EPROM
EPROM51:		LCALL	$PM_ROMPROG
				SJMP	$EPROM
EPROMEXIT:		RET

ROMMENU:		ACALL	$PRNTSTR
				DB		0Eh
				DB		'   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',0Dh,0Ah
				DB		'   ³  Action       ³  ³  EEPROM size  ³  ³  Mode         ³',0Dh,0Ah
				DB		'   ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´',0Dh,0Ah
				DB		'   ³  Test erased  ³  ³  4K           ³  ³  Byte         ³',0Dh,0Ah
				DB		'   ³  Erase        ³  ³  8K           ³  ³  Page         ³',0Dh,0Ah
				DB		'   ³  Screendump   ³  ³  16K          ³  ³               ³',0Dh,0Ah
				DB		'   ³  Verify       ³  ³  32K          ³  ³               ³',0Dh,0Ah
				DB		'   ³  Program      ³  ³  64K          ³  ³               ³',0Dh,0Ah
				DB		'   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',0Dh,0Ah
				DB		00h
				MOV		R0,#28h
				ACALL	$MENUSET
				INC		R0
				ACALL	$MENUSET
				MOV		R0,#27h
				ACALL	$MENUXP
				RET

MENUXP:			ACALL	$MENUSET
				MOV		A,#08h
				LCALL	$TXBYTE
				LCALL	$RXBYTE
				CJNE	A,#9Ah,$MENUXP1
				MOV		A,@R0
				DEC		A
				JZ		$MENUXP
				MOV		A,#20h
				LCALL	$TXBYTE
				DEC		@R0
				SJMP	$MENUXP
MENUXP1:		CJNE	A,#9Bh,$MENUXP2
				MOV		A,@R0
				SUBB	A,#05h
				JZ		$MENUXP
				MOV		A,#20h
				LCALL	$TXBYTE
				INC		@R0
				SJMP	$MENUXP
MENUXP2:		CJNE	A,#9Ch,$MENUYP1
				MOV		A,R0
				SUBB	A,#29h
				JZ		$MENUXP
				INC		R0
				SJMP	$MENUXP
MENUYP1:		CJNE	A,#9Dh,$MENUYP2
				MOV		A,R0
				SUBB	A,#27h
				JZ		$MENUXP
				DEC		R0
				SJMP	$MENUXP
MENUYP2:		CJNE	A,#9Fh,$MENUYP3			;Esc
				RET
MENUYP3:		CJNE	A,#94h,$MENUXP			;Insert
				RET

MENUSET:		MOV		A,#0Bh
				LCALL	$TXBYTE
				MOV		A,@R0
				ADD		A,#22h
				LCALL	$TXBYTE
				MOV		A,R0
				SUBB	A,#27h
				MOV		B,#13h
				MUL		AB
				ADD		A,#24h
				LCALL	$TXBYTE
				MOV		A,#0FBh					;û
				LCALL	$TXBYTE
				RET

;------------------------------------------------------------------

ROMINSERT:		LCALL	$ROMOFF
				ACALL	$PRNTSTR
				DB		0Bh,2Ah,23h,'Insert ',00h
				MOV		A,$28h
				DEC		A
				JNZ		$ROMINSERT1
				ACALL	$PRNTSTR
				DB		'4K',00h
				MOV		$26h,#10h				;16 Pages
ROMINSERT1:		DEC		A
				JNZ		$ROMINSERT2
				ACALL	$PRNTSTR
				DB		'8K',00h
				MOV		$26h,#20h				;32 Pages
ROMINSERT2:		DEC		A
				JNZ		$ROMINSERT3
				ACALL	$PRNTSTR
				DB		'16K',00h
				MOV		$26h,#40h				;64 Pages
ROMINSERT3:		DEC		A
				JNZ		$ROMINSERT4
				ACALL	$PRNTSTR
				DB		'32K',00h
				MOV		$26h,#80h				;128 Pages
ROMINSERT4:		DEC		A
				JNZ		$ROMINSERT5
				ACALL	$PRNTSTR
				DB		'64K',00h
				MOV		$26h,#00h				;256 Pages
ROMINSERT5:		ACALL	$PRNTSTR
				DB		' device and strike <Enter> ',00h
				ACALL	$RXBYTE
				CJNE	A,#9Fh,$ROMINSERT6	;Esc
				SETB	C
				RET
ROMINSERT6:		ACALL	$PRNTSTR
				DB		0Bh,2Ah,23h,'                                       '
				DB		0Dh,00h
				CLR		C
				RET

ROMERASE:		MOV		A,#0ACh
				LCALL	$ISPCOMM				;Init chip erase byte 1
				MOV		A,#80h
				LCALL	$ISPCOMM				;Init chip erase byte 2
				CLR		A
				LCALL	$ISPCOMM				;Init chip erase byte 3
				CLR		A
				LCALL	$ISPCOMM				;Init chip erase byte 4
				CLR		A
				LCALL	$WAIT					;Wait 256 ms
				CLR		A
				LCALL	$WAIT					;Wait 256 ms
				CLR		A
				LCALL	$WAIT					;Wait 256 ms
				LCALL	$PM_ISERASED
				JNC		$ROMERASE1
				LCALL	$ROMOFF					;Set RST low and turn off VCC
				LCALL	$PRNTSTR
				DB		0Bh,2Ah,23h,'Could not erase chip <Enter> ',00h
				LCALL	$RXBYTE					;Wait for keypress
				RET
ROMERASE1:		LCALL	$ROMOFF					;Set RST low and turn off VCC
				RET

ROMWAIT:		ACALL	$PRNTSTR
				DB		0Bh,2Ah,23h,'Wait ...',00h
				RET


;Byte mode
;------------------------------------------------------------------

BM_ROMERASED:	LCALL	$BM_ROMRDBYTE			;Read a byte from ROM
				CJNE	A,#0FFh,$BM_ROMERASED1	;Not erased
				INC		DPTR					;Next address
				MOV		A,DPL
				JNZ		$BM_ROMERASED			;Jump if more bytes in this page
				MOV		A,DPH
				CJNE	A,$26h,$BM_ROMERASED	;Jump if more pages
				LCALL	$ROMOFF					;Set RST low and turn off VCC
				RET
BM_ROMERASED1:	LCALL	$ROMOFF					;Set RST low and turn off VCC
				ACALL	$PRNTSTR
				DB		0Bh,2Ah,23h,'Byte at ',00h
				MOV		A,DPH
				ACALL	$HEXOUT					;High address
				MOV		A,DPL
				ACALL	$HEXOUT					;Low address
				ACALL	$PRNTSTR
				DB		' not erased <Enter> ',00h
				ACALL	$RXBYTE					;Wait for keypress
				RET

BM_ROMDUMPF:	MOV		A,#03h
				ACALL	$TXBYTE					;Init write to file
BM_ROMDUMPF1:	LCALL	$BM_ROMRDBYTE			;Read a byte from ROM
				ACALL	$HEXOUT					;Output as hex
				MOV		A,#20h
				ACALL	$TXBYTE					;Output a space
				INC		DPTR
				MOV		A,DPL
				ANL		A,#0Fh
				JNZ		$BM_ROMDUMPF2			;Still on same line
				ACALL	$PRNTCRLF				;Output CRLF
BM_ROMDUMPF2:	MOV		A,DPL
				JNZ		$BM_ROMDUMPF1			;Jump if more bytes in this page
				MOV		A,DPH
				CJNE	A,$26h,$BM_ROMDUMPF1	;Jump if more pages
				MOV		A,#04h
				ACALL	$TXBYTE					;End write to file
				LCALL	$ROMOFF					;Set RST low and turn off VCC
BM_ROMDUMPF3:	RET

BM_ROMDUMPS:	LCALL	$BM_ROMRDBYTE			;Read a byte from ROM
				ACALL	$HEXOUT					;Output as hex
				MOV		A,#20h
				ACALL	$TXBYTE					;Output a space
				INC		DPTR					;Next ROM address
				MOV		A,DPL
				ANL		A,#0Fh
				JNZ		$BM_ROMDUMPS1			;Jump if still on same line
				ACALL	$PRNTCRLF				;Output CRLF
BM_ROMDUMPS1:	MOV		A,DPL
				JNZ		$BM_ROMDUMPS			;Jump if more bytes in this page
				ACALL	$PRNTCRLF				;Output CRLF
				ACALL	$RXBYTE					;Wait for a keypress
				CJNE	A,#9Fh,$BM_ROMDUMPS2
				SJMP	$BM_ROMDUMPS3
BM_ROMDUMPS2:	MOV		A,DPH
				CJNE	A,$26h,$BM_ROMDUMPS		;Jump if more pages
BM_ROMDUMPS3:	LCALL	$ROMOFF					;Set RST low and turn off VCC
				RET

BM_ROMVERIFY:	PUSH	$00h					;Save R0
				MOV		$2Fh,#00h				;Number of errors
				ACALL	$RX16BYTES				;Read 16 bytes from cmd file. R0 points to start of 16 byte buffer
BM_ROMVERIFY1:	MOV		$25h,@R0				;Get byte from buffer
				LCALL	$BM_ROMRDBYTE			;Read a byte from ROM
				CJNE	A,$25h,$BM_ROMVERIFY4	;Compare and jump if not equal
BM_ROMVERIFY2:	INC		R0						;Increment buffer pointer
				MOV		A,R0
				CJNE	A,#50h,$BM_ROMVERIFY3	;Jump if not last byte in buffer
				ACALL	$RX16BYTES				;Read 16 bytes from cmd file. R0 points to start of 16 byte buffer
BM_ROMVERIFY3:	INC		DPTR					;Next ROM address
				MOV		A,DPL
				JNZ		$BM_ROMVERIFY1			;Jump if still on same page
				MOV		A,DPH
				CJNE	A,$26h,$BM_ROMVERIFY1	;Jump if more pages
				LCALL	$ROMOFF					;Set RST low and turn off VCC
				MOV		A,#06h
				ACALL	$TXBYTE					;End read 16 bytes from cmd file
				POP		$00h					;Restore R0
				RET
BM_ROMVERIFY4:	LCALL	$ROMVERIFYERR
				JNC		$BM_ROMVERIFY2			;Jump if less than 16 errors
				LCALL	$ROMOFF					;Set RST low and turn off VCC
				MOV		A,#06h
				ACALL	$TXBYTE					;End read 16 bytes from cmd file
				ACALL	$RXBYTE					;Wait for a keypress
				POP		$00h					;Restore R0
				RET

;Page mode
;------------------------------------------------------------------

PM_ROMERASED:	MOV		A,#30h
				LCALL	$ISPCOMM				;Init read page mode
				MOV		A,DPH
				LCALL	$ISPCOMM				;Send high address
PM_ROMERASED1:	CLR		A
				LCALL	$ISPCOMM				;Get byte from ROM
				CJNE	A,#0FFh,$PM_ROMERASED2	;Jump if not erased
				INC		DPTR
				MOV		A,DPL
				JNZ		$PM_ROMERASED1			;Jump if more bytes on this page
				MOV		A,DPH
				CJNE	A,$26h,$PM_ROMERASED	;Jump if more pagees
				LCALL	$ROMOFF					;Set RST low and turn off VCC
				RET
PM_ROMERASED2:	LCALL	$ROMOFF					;Set RST low and turn off VCC
				ACALL	$PRNTSTR
				DB		0Bh,2Ah,23h,'Byte at ',00h
				MOV		A,DPH
				ACALL	$HEXOUT					;Output high address as hex
				MOV		A,DPL
				ACALL	$HEXOUT					;Output low address as hex
				ACALL	$PRNTSTR
				DB		' not erased <Enter> ',00h
				ACALL	$RXBYTE					;Wait for a keypress
				RET

PM_ROMDUMPF:	MOV		A,#03h
				ACALL	$TXBYTE					;Init Output to hex file
PM_ROMDUMPF1:	MOV		A,#30h
				LCALL	$ISPCOMM				;Init read page mode
				MOV		A,DPH
				LCALL	$ISPCOMM				;Send high address
PM_ROMDUMPF2:	CLR		A
				LCALL	$ISPCOMM				;Get byte from ROM
				ACALL	$HEXOUT					;Output as hex
				MOV		A,#20h
				ACALL	$TXBYTE					;Output a space
				INC		DPTR
				MOV		A,DPL
				ANL		A,#0Fh
				CJNE	A,#00h,$PM_ROMDUMPF3	;Jump if more bytes in this line
				LCALL	$PRNTCRLF				;Output CRLF
				MOV		A,DPL
				JNZ		$PM_ROMDUMPF2			;Jump if more bytes in this page
PM_ROMDUMPF3:	MOV		A,DPH
				CJNE	A,$26h,$PM_ROMDUMPF1	;Jump if more pages
				MOV		A,#04h
				LCALL	$TXBYTE					;End Output to hex file
				LCALL	$ROMOFF					;Set RST low and turn off VCC
				RET

PM_ROMDUMPS:	MOV		A,#30h
				LCALL	$ISPCOMM				;Init read page mode
				MOV		A,DPH
				LCALL	$ISPCOMM				;Send high address
PM_ROMDUMPS1:	CLR		A
				LCALL	$ISPCOMM				;Get byte from ROM
				LCALL	$HEXOUT					;Output as hex
				MOV		A,#20h
				LCALL	$TXBYTE					;Output a space
				INC		DPTR
				MOV		A,DPL
				ANL		A,#0Fh
				JNZ		$PM_ROMDUMPS2			;Jump if still on same line
				LCALL	$PRNTCRLF				;Output CRLF
				MOV		A,DPL
				JNZ		$PM_ROMDUMPS1			;Jump if more bytes on this page
				LCALL	$PRNTCRLF				;Output CRLF
				LCALL	$RXBYTE					;Wait for a keypress
				CJNE	A,#9Fh,$PM_ROMDUMPS2
				SJMP	$PM_ROMDUMPS3			;Esc pressed
PM_ROMDUMPS2:	MOV		A,DPH
				CJNE	A,$26h,$PM_ROMDUMPS		;Jump if more pages
PM_ROMDUMPS3:	LCALL	$ROMOFF					;Set RST low and turn off VCC
				RET

PM_ROMVERIFY:	PUSH	$00h					;Save R0
				MOV		$2Fh,#00h				;Number of errors
				LCALL	$RX16BYTES				;Read 16 bytes from cmd file. R0 points to start of 16 byte buffer
PM_ROMVERIFY1:	MOV		A,#30h
				LCALL	$ISPCOMM				;Init read page mode
				MOV		A,DPH
				LCALL	$ISPCOMM				;Send high address
PM_ROMVERIFY2:	MOV		$25h,@R0				;Get byte from buffer
				CLR		A
				LCALL	$ISPCOMM				;Get byte from ROM
				CJNE	A,$25h,$PM_ROMVERIFY5	;Compare and jump if not equal
PM_ROMVERIFY3:	INC		R0						;Increment buffer pointer
				MOV		A,R0
				CJNE	A,#50h,$PM_ROMVERIFY4	;Jump if not last byte in buffer
				LCALL	$RX16BYTES				;Read 16 bytes from cmd file. R0 points to start of 16 byte buffer
PM_ROMVERIFY4:	INC		DPTR
				MOV		A,DPL
				JNZ		$PM_ROMVERIFY2			;Jump if still on same page
				MOV		A,DPH
				CJNE	A,$26h,$PM_ROMVERIFY1	;Jump if more pages
				LCALL	$ROMOFF					;Set RST low and turn off VCC
				MOV		A,#06h
				LCALL	$TXBYTE					;End read 16 bytes from cmd file
				POP		$00h					;Restore R0
				RET
PM_ROMVERIFY5:	LCALL	$ROMVERIFYERR
				JNC		$PM_ROMVERIFY3			;Jump if less than 16 errors
				LCALL	$ROMOFF					;Set RST low and turn off VCC
				MOV		A,#06h
				LCALL	$TXBYTE					;End read 16 bytes from cmd file
				LCALL	$RXBYTE					;Wait for keypress
				POP		$00h					;Restore R0
				RET

PM_ISERASED:	MOV		DPTR,#0000h
				MOV		$2Fh,#00h
PM_ISERASED1:	MOV		A,#30h
				LCALL	$ISPCOMM				;Init read page mode
				MOV		A,DPH
				LCALL	$ISPCOMM				;Send high address
PM_ISERASED2:	CLR		A
				LCALL	$ISPCOMM				;Get byte from ROM
				INC		A
				ORL		$2Fh,A
				INC		DPTR
				MOV		A,DPL
				JNZ		$PM_ISERASED2			;Jump if more bytes on this page
				MOV		A,$2Fh
				JNZ		$PM_ISERASED3
				MOV		A,DPH
				CJNE	A,$26h,$PM_ISERASED1	;Jump if more pagees
PM_ISERASED3:	CLR		C
				MOV		A,$2Fh
				JZ		$PM_ISERASED4
				SETB	C
PM_ISERASED4:	RET

PM_ROMPROG:		LCALL	$PM_ISERASED			;Check if chip is erased
				JNC		$PM_ROMPROG1
				MOV		A,#0ACh
				LCALL	$ISPCOMM				;Init chip erase byte 1
				MOV		A,#80h
				LCALL	$ISPCOMM				;Init chip erase byte 2
				CLR		A
				LCALL	$ISPCOMM				;Init chip erase byte 3
				CLR		A
				LCALL	$ISPCOMM				;Init chip erase byte 4
				CLR		A
				LCALL	$WAIT					;Wait 256 ms
				CLR		A
				LCALL	$WAIT					;Wait 256 ms
				CLR		A
				LCALL	$WAIT					;Wait 256 ms
				LCALL	$PM_ISERASED
				JNC		$PM_ROMPROG1
				LCALL	$ROMOFF					;Set RST low and turn off VCC
				LCALL	$PRNTSTR
				DB		0Bh,2Ah,23h,'Could not erase chip <Enter> ',00h
				LCALL	$RXBYTE					;Wait for keypress
				RET
PM_ROMPROG1:	PUSH	$00h
				MOV		DPTR,#0000h
				LCALL	$RX16BYTES				;Read 16 bytes from cmd file. R0 points to start of 16 byte buffer
PM_ROMPROG2:	MOV		A,#40h
				LCALL	$ISPCOMM				;Init byte programming mode
				MOV		A,DPH
				LCALL	$ISPCOMM				;Send high address
				MOV		A,DPL
				LCALL	$ISPCOMM				;Send low address
				MOV		A,@R0
				MOV		$25h,A					;Get byte from buffer
				LCALL	$ISPCOMM				;Send byte to be programmed
				MOV		A,#1Eh
				LCALL	$WAIT					;Wait 3mS
				LCALL	$BM_ROMRDBYTE			;Read a byte from ROM
				CJNE	A,$25h,$PM_ROMPROG4		;Compare and jump if not equal
				INC		R0
				MOV		A,R0
				CJNE	A,#50h,$PM_ROMPROG3
				LCALL	$RX16BYTES				;Read 16 bytes from cmd file. R0 points to start of 16 byte buffer
PM_ROMPROG3:	INC		DPTR
				MOV		A,DPL
				JNZ		$PM_ROMPROG2			;Jump if still on same page
				MOV		A,#2Eh
				LCALL	$TXBYTE
				MOV		A,DPH
				CJNE	A,$26h,$PM_ROMPROG2		;Jump if more pages
				LCALL	$ROMOFF					;Set RST low and turn off VCC
				MOV		A,#06h
				LCALL	$TXBYTE					;End read 16 bytes from cmd file
				POP		$00h
				RET
PM_ROMPROG4:	PUSH	ACC
				LCALL	$ROMOFF					;Set RST low and turn off VCC
				MOV		A,#06h
				LCALL	$TXBYTE					;End read 16 bytes from cmd file
				LCALL	$PRNTSTR
				DB		0Bh,2Ah,23h,'Error at ',00h
				MOV		A,DPH
				LCALL	$HEXOUT					;High address
				MOV		A,DPL
				LCALL	$HEXOUT					;Low address
				MOV		A,#20h
				LCALL	$TXBYTE
				MOV		A,$25h
				LCALL	$HEXOUT					;Byte from .cmd file
				MOV		A,#20h
				LCALL	$TXBYTE
				POP		ACC
				LCALL	$HEXOUT					;Byte read from ROM
				LCALL	$RXBYTE					;Wait for a keypress
				POP		$00h					;Restore R0
				RET

;Wait functions
;------------------------------------------------------------------

WAIT100:		PUSH	$07h					;Save R7
				MOV		R7,#5Ch
WAIT1001:		DJNZ	R7,$WAIT1001			;Wait loop, 100uS
				POP		$07h					;Restore R7
				RET

WAIT:			XCH		A,R7
WAIT1:			ACALL	$WAIT100
				DJNZ	R7,$WAIT1
				XCH		A,R7
				RET

;Control functions
;------------------------------------------------------------------

;IN A, OUT A
ISPCOMM:		PUSH	$07h
				PUSH	$02h
				MOV		R2,#08h
ISPCOMM1:		RLC		A
				MOV		P1.3,C					;MISO
				NOP
				MOV		C,P1.4					;MOSI
				XCH		A,R7
				RLC		A
				XCH		A,R7
				SETB	P1.2					;SCK H
				NOP
				NOP
				NOP
				NOP
				CLR		P1.2					;SCK L
				DJNZ	R2,$ISPCOMM1
				MOV		A,R7
				POP		$02
				POP		$07
				RET

ROMON:			SETB	P1.0					;+5V On
				CLR		A
				ACALL	$WAIT					;Wait 25mS
				CLR		A
				ACALL	$WAIT					;Wait 25mS
				CLR		A
				ACALL	$WAIT					;Wait 25mS
				CLR		A
				ACALL	$WAIT					;Wait 25mS
				SETB	P1.1					;RST H
				CLR		A
				ACALL	$WAIT					;Wait 25mS
				RET

ROMOFF:			CLR		P1.1					;RST L
				CLR		A
				ACALL	$WAIT					;Wait 25Ms
				MOV		P1,#10h					;+5V Off, P1.4 As Input
				CLR		A
				LCALL	$WAIT					;Wait 25mS
				RET

ROMINITPGM:		MOV		A,#0ACh
				LCALL	$ISPCOMM
				MOV		A,#53h
				LCALL	$ISPCOMM
				MOV		A,#00h
				LCALL	$ISPCOMM
				MOV		A,#00h
				LCALL	$ISPCOMM
				CJNE	A,#69h,$ROMINITPGM1
				RET
ROMINITPGM1:	LCALL	$PRNTSTR
				DB		0Bh,2Ah,23h,'Initialisation Error <Enter> ',00h
				LCALL	$RXBYTE
				SETB	C
				RET

ROMINIT:		MOV		DPTR,#0000h				;DPTR holds ROM address
				LCALL	$ROMON					;Turn on VCC and pull RST high
				LCALL	$ROMINITPGM
				JNC		$ROMINIT1
				LCALL	$ROMOFF					;Init programming failed
				SETB	C
ROMINIT1:		RET

BM_ROMRDBYTE:	MOV		A,#20h
				LCALL	$ISPCOMM
				MOV		A,DPH
				LCALL	$ISPCOMM
				MOV		A,DPL
				LCALL	$ISPCOMM
				MOV		A,#00h
				LCALL	$ISPCOMM
				RET

ROMVERIFYERR:	PUSH	ACC
				LCALL	$PRNTSTR
				DB		0Dh,'   Error at ',00h
				MOV		A,DPH
				LCALL	$HEXOUT
				MOV		A,DPL
				LCALL	$HEXOUT
				MOV		A,#20h
				LCALL	$TXBYTE
				MOV		A,$25h
				LCALL	$HEXOUT
				MOV		A,#20h
				LCALL	$TXBYTE
				POP		ACC
				LCALL	$HEXOUT
				LCALL	$PRNTCRLF
				INC		$2Fh
				MOV		A,$2Fh
				CJNE	A,#10h,$00h
				CPL		C
				RET

;------------------------------------------------------------------

				ORG		2000h					;Fill up 2764
