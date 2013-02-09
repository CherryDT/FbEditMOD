
.const

szIniCom			BYTE 'Com',0

szGPRMC				BYTE '$GPRMC',0

szBinToDec			BYTE '%06d',0
szFmtTime			BYTE '%02d%02d%02d %02d:%02d:%02d',0

.data?

dcb					DCB <>
hCom				HANDLE ?
hFileLogRead		HANDLE ?
hFileLogWrite		HANDLE ?
to					COMMTIMEOUTS <>
npos				DWORD ?
combuff				BYTE 4096 dup(?)
linebuff			BYTE 512 dup(?)
logbuff				BYTE 1024 dup(?)

.code

OpenCom proc

	.if map.comopt.active
		invoke CreateFile,addr map.comopt.szcom,GENERIC_READ,NULL,NULL,OPEN_EXISTING,NULL,NULL
		.if eax
			mov		hCom,eax
			invoke RtlZeroMemory,addr dcb,sizeof DCB
			mov		eax,map.comopt.nbaud
			mov		dcb.BaudRate,eax
			mov		eax,map.comopt.nbits
			mov		dcb.ByteSize,al
			mov		eax,map.comopt.nparity
			mov		dcb.Parity,al
			mov		eax,map.comopt.nstop
			mov		dcb.StopBits,al
			invoke SetCommState,hCom,addr dcb
			mov		to.ReadTotalTimeoutConstant,100 ;0.1 sek
			invoke SetCommTimeouts,hCom,addr to
		.endif
	.endif
	ret

OpenCom endp

GetLine proc uses esi,pos:DWORD

	mov		ecx,pos
	.if combuff[ecx]=='$'
		xor		edx,edx
		.while combuff[ecx] && edx<500
			mov		al,combuff[ecx]
			.if al==0Dh
				mov		linebuff[edx],0
				inc		ecx
				.if combuff[ecx]==0Ah
					inc		ecx
					mov		eax,ecx
					sub		eax,pos
					jmp		Ex
				.endif
				.break
			.endif
			mov		linebuff[edx],al
			inc		ecx
			inc		edx
		.endw
	.endif
	xor		eax,eax
  Ex:
	ret

GetLine endp

;
;$GPAPB,A,A,0.00,L,N,V,V,237.3,T,Cursor,237.3,T,192.3,T,A*6C
;$GPGLL,6619.0298,N,01411.8025,E,212044,A*2A
;$GPRMB,A,0.00,L,,,6558.4316,N,01254.1262,E,37.56,237.3,0.0,V*3F
;$GPRMC,212044,A,6619.0298,N,01411.8025,E,0.0,0.0,220710,3.9,E*7A
;$GPGGA,212044,6619.0298,N,01411.8025,E,1,0,50.00,102,M,,,,*39
;$GPGSA,A,2,,,,,,,,,,,,,50.00,50.00,50.00*36
;$GPGSV,3,1,12,24,71,186,,3,63,207,,6,58,176,,19,53,270,*74
;$GPGSV,3,2,12,18,49,89,,22,48,147,,21,27,86,,15,24,36,*4F
;$GPGSV,3,3,12,8,22,322,,26,20,15,,7,11,288,,16,9,192,*72
;$SDMTW,22.3,C*07
;$SDDPT,,*57
;$SDDBT,,,,,,*45

DoComm proc uses ebx esi edi,Param:DWORD
	LOCAL	nRead:DWORD
	LOCAL	nWrite:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	bufflog[256]:BYTE
	LOCAL	bufftime[32]:BYTE
	LOCAL	buffdate[32]:BYTE
	LOCAL	nTrail:DWORD
	LOCAL	iLon:DWORD
	LOCAL	iLat:DWORD
	LOCAL	fDist:REAL10
	LOCAL	fBear:REAL10
	LOCAL	iTime:DWORD
	LOCAL	iSumDist:DWORD
	LOCAL	ft:FILETIME
	LOCAL	lft:FILETIME
	LOCAL	lst:SYSTEMTIME
	LOCAL	fValid:DWORD

	mov		nTrail,0
	.while  !fExitGpsThread
		.if hCom || hFileLogRead
			.if hFileLogRead
				invoke Sleep,200
				.if !map.gpslogpause
					invoke ReadFile,hFileLogRead,addr combuff,1024,addr nRead,NULL
					.if !nRead
						invoke CloseHandle,hFileLogRead
						invoke GetDlgItem,hWnd,IDC_CHKPAUSE
						invoke EnableWindow,eax,FALSE
						mov		hFileLogRead,0
						mov		npos,0
						fldz
						fstp	fDist
						mov		nTrail,0
					.else
						.if !nTrail
							fldz
							fstp	map.fSumDist
						.endif
						invoke strlen,addr combuff
						lea		eax,[eax+1]
						add		npos,eax
						invoke SetFilePointer,hFileLogRead,npos,NULL,FILE_BEGIN
					.endif
				.endif
				mov		nRead,0
			.else
				mov		edx,npos
				mov		ecx,4000
				sub		ecx,edx
				invoke ReadFile,hCom,addr combuff[edx],ecx,addr nRead,NULL
			.endif
			.if nRead
				mov		eax,nRead
				add		eax,npos
				mov		npos,eax
				mov		combuff[eax],0
				invoke Sleep,10
			.elseif combuff
				xor		ebx,ebx
				.while combuff[ebx] && ebx<sizeof combuff-32
					invoke GetLine,ebx
					.break .if !eax
					add		ebx,eax
					push	ebx
					.if hFileLogWrite
						invoke strcpy,addr bufflog,addr linebuff
						invoke strcat,addr bufflog,addr szCRLF
					.endif
					invoke GetItemStr,addr linebuff,addr szNULL,addr buffer,32
					invoke strcmp,addr buffer,addr szGPRMC
					.if !eax
						call	PositionSpeedDirection
						.if hFileLogWrite
							invoke strcat,addr logbuff,addr bufflog
						.endif
;					.else
;						invoke strcmp,addr buffer,addr szSDDPT
;						.if !eax
;							call	Depth
;							.if hFileLogWrite
;								invoke strcat,addr logbuff,addr bufflog
;							.endif
;						.else
;							invoke strcmp,addr buffer,addr szSDMTW
;							.if !eax
;								call	Temprature
;								.if hFileLogWrite
;									invoke strcat,addr logbuff,addr bufflog
;								.endif
;							.endif
;						.endif
					.endif
					pop		ebx
				.endw
				.if hFileLogWrite && !map.gpslogpause
					invoke strlen,addr logbuff
					lea		edx,[eax+1]
					invoke WriteFile,hFileLogWrite,addr logbuff,edx,addr nWrite,NULL
				.endif
				.if !hFileLogRead
					mov		npos,0
				.endif
				mov		logbuff,0
				mov		combuff,0
				.if (!map.bdist || map.bdist==2) && (!map.btrip || map.btrip==2)
					invoke DoGoto,map.iLon,map.iLat,map.gpslock,TRUE
					invoke SetDlgItemInt,hWnd,IDC_EDTEAST,map.iLon,TRUE
					invoke SetDlgItemInt,hWnd,IDC_EDTNORTH,map.iLat,TRUE
					inc		map.paintnow
				.endif
			.endif
			invoke Sleep,10
		.elseif map.comopt.active
			;Open the com port
			invoke OpenCom
			invoke Sleep,250
			mov		npos,0
			mov		combuff,0
		.else
			invoke Sleep,100
		.endif
	.endw
	.if hCom
		invoke CloseHandle,hCom
		mov		hCom,0
	.endif
	.if hFileLogRead
		invoke CloseHandle,hFileLogRead
		mov		hFileLogRead,0
	.endif
	.if hFileLogWrite
		invoke CloseHandle,hFileLogWrite
		mov		hFileLogWrite,0
	.endif
	ret

PositionSpeedDirection:
	;Time
	invoke GetItemStr,addr linebuff,addr szNULL,addr bufftime,32
	;Status
	invoke GetItemStr,addr linebuff,addr szNULL,addr buffer,32
	.if buffer=='A'
		mov		map.fcursor,TRUE
		mov		fValid,TRUE
	.else
		inc		map.fcursor
		and		map.fcursor,1
		mov		fValid,FALSE
	.endif
	mov		eax,map.iLon
	mov		iLon,eax
	mov		eax,map.iLat
	mov		iLat,eax
	.if fValid
		;Lattitude
		invoke GetItemStr,addr linebuff,addr szNULL,addr buffer,32
		lea		esi,buffer
		mov		edi,esi
		.while byte ptr [esi]
			mov		al,[esi]
			.if al!='.'
				mov		[edi],al
				inc		edi
			.endif
			inc		esi
		.endw
		mov		byte ptr [edi],0
		invoke DecToBin,addr buffer[2]
		;convert minutes to decimal
		mov		ecx,100
		mul		ecx
		mov		ecx,60
		xor		edx,edx
		div		ecx
		mov		edx,eax
		invoke wsprintf,addr buffer[2],addr szBinToDec,edx
		invoke DecToBin,addr buffer
		push	eax
		invoke GetItemStr,addr linebuff,addr szNULL,addr buffer,32
		pop		eax
		.if buffer=='S'
			neg		eax
		.endif
		.if fValid
			mov		map.iLat,eax
		.endif
		;Longitude
		invoke GetItemStr,addr linebuff,addr szNULL,addr buffer,32
		lea		esi,buffer
		mov		edi,esi
		.while byte ptr [esi]
			mov		al,[esi]
			.if al!='.'
				mov		[edi],al
				inc		edi
			.endif
			inc		esi
		.endw
		mov		byte ptr [edi],0
		invoke DecToBin,addr buffer[3]
		;convert minutes to decimal
		mov		ecx,100
		mul		ecx
		mov		ecx,60
		xor		edx,edx
		div		ecx
		mov		edx,eax
		invoke wsprintf,addr buffer[3],addr szBinToDec,edx
		invoke DecToBin,addr buffer
		push	eax
		invoke GetItemStr,addr linebuff,addr szNULL,addr buffer,32
		pop		eax
		.if combuff=='W'
			neg		eax
		.endif
		.if fValid
			mov		map.iLon,eax
		.endif
		;Speed
		invoke GetItemStr,addr linebuff,addr szNULL,addr map.options.text,sizeof OPTIONS.text
		invoke strcpy,addr buffer,addr map.options.text
		invoke strlen,addr buffer
		.while buffer[eax]!='.' && eax
			dec		eax
		.endw
		mov		buffer[eax+2],0
		mov		ecx,dword ptr buffer[eax+1]
		mov		dword ptr buffer[eax],ecx
		invoke DecToBin,addr buffer
		mov		map.iSpeed,eax
		;Get the bearing
		invoke GetItemStr,addr linebuff,addr szNULL,addr buffer,32
		invoke DecToBin,addr buffer
		mov		map.iBear,eax
		.if eax>360-22 || eax<45-22
			;N
			mov		map.ncursor,0
		.elseif eax<90-22
			;NE
			mov		map.ncursor,1
		.elseif eax<135-22
			;E
			mov		map.ncursor,2
		.elseif eax<180-22
			;SE
			mov		map.ncursor,3
		.elseif eax<225-22
			;S
			mov		map.ncursor,4
		.elseif eax<270-22
			;SW
			mov		map.ncursor,5
		.elseif eax<315-22
			;W
			mov		map.ncursor,6
		.else
			;NW
			mov		map.ncursor,7
		.endif
	.endif
	mov		iTime,0
	;Date
	invoke GetItemStr,addr linebuff,addr szNULL,addr buffdate,32
	;YYYY YYYM MMMD DDDD
	;0010 0100 0000 0000 0000 0000 0001 1111
	;Get year
	invoke DecToBin,addr buffdate[4]
	mov		buffdate[4],0
	shl		eax,9
	or		iTime,eax
	;Get month
	invoke DecToBin,addr buffdate[2]
	mov		buffdate[2],0
	shl		eax,5
	or		iTime,eax
	;Get day
	invoke DecToBin,addr buffdate
	or		iTime,eax
	shl		iTime,16
	;HHHH HMMM MMS SSSS
	;Get seconds
	invoke DecToBin,addr bufftime[4]
	mov		bufftime[4],0
	shr		eax,1
	or		iTime,eax
	;Get minutes
	invoke DecToBin,addr bufftime[2]
	mov		bufftime[2],0
	shl		eax,5
	or		iTime,eax
	;Get hours
	invoke DecToBin,addr bufftime
	shl		eax,11
	or		iTime,eax
	mov		eax,iTime
	mov		map.iTime,eax
	mov		ecx,eax
	movzx	edx,ax
	shr		ecx,16
	invoke DosDateTimeToFileTime,ecx,edx,addr ft
	invoke FileTimeToLocalFileTime,addr ft,addr lft
	invoke FileTimeToSystemTime,addr lft,addr lst
	mov		ebx,esp
	movzx	eax,lst.wSecond
	push	eax
	movzx	eax,lst.wMinute
	push	eax
	movzx	eax,lst.wHour
	push	eax
	movzx	eax,lst.wYear
	sub		eax,1980
	push	eax
	movzx	eax,lst.wMonth
	push	eax
	movzx	eax,lst.wDay
	push	eax
	push	offset szFmtTime
	lea		eax,map.options.text[sizeof OPTIONS*4]
	push	eax
	call	wsprintf
	mov		esp,ebx
	.if fValid
		invoke AddTrailPoint,map.iLon,map.iLat,map.iBear,map.iTime
		.if nTrail
			mov		eax,map.iLon
			mov		edx,map.iLat
			.if eax!=iLon || edx!=iLat
				invoke BearingDistanceInt,iLon,iLat,map.iLon,map.iLat,addr fDist,addr fBear
				fld		fDist
				fld		map.fSumDist
				faddp	st(1),st(0)
				fst		st(1)
				lea		eax,map.fSumDist
				fstp	REAL10 PTR [eax]
				lea		eax,iSumDist
				fistp	dword ptr [eax]
				invoke SetDlgItemInt,hWnd,IDC_EDTDIST,iSumDist,FALSE
				invoke SetDlgItemInt,hWnd,IDC_EDTBEAR,map.iBear,FALSE
			.endif
		.endif
		inc		nTrail
	.endif
	retn

;Depth:
;	invoke GetItemStr,addr linebuff,addr szNULL,addr map.options.text[sizeof OPTIONS],10
;	.if !map.options.text[sizeof OPTIONS]
;		invoke strcpy,addr map.options.text[sizeof OPTIONS],addr sz0Dot0
;	.endif
;	retn

;Temprature:
;	invoke GetItemStr,addr linebuff,addr sz0Dot0,addr map.options.text[sizeof OPTIONS*2],10
;	invoke GetItemStr,addr linebuff,addr szNULL,addr buffer,4
;	xor		eax,eax
;	.while buffer[eax] && buffer[eax]!='*'
;		inc		eax
;	.endw
;	mov		buffer[eax],0
;	invoke strcat,addr map.options.text[sizeof OPTIONS*2],addr buffer
;	retn

DoComm endp
