.const

FP_EQUALTO	equ	40h

ten16		dq	1.0e16

ten			dq	10.0

ten_1		dt	1.0e1
			dt	1.0e2
			dt	1.0e3
			dt	1.0e4
			dt	1.0e5
			dt	1.0e6
			dt	1.0e7
			dt	1.0e8
			dt	1.0e9
			dt	1.0e10
			dt	1.0e11
			dt	1.0e12
			dt	1.0e13
			dt	1.0e14
			dt	1.0e15
ten_16		dt	1.0e16
			dt	1.0e32
			dt	1.0e48
			dt	1.0e64
			dt	1.0e80
			dt	1.0e96
			dt	1.0e112
			dt	1.0e128
			dt	1.0e144
			dt	1.0e160
			dt	1.0e176
			dt	1.0e192
			dt	1.0e208
			dt	1.0e224
			dt	1.0e240
ten_256		dt	1.0e256
			dt	1.0e512
			dt	1.0e768
			dt	1.0e1024
			dt	1.0e1280
			dt	1.0e1536
			dt	1.0e1792
			dt	1.0e2048
			dt	1.0e2304
			dt	1.0e2560
			dt	1.0e2816
			dt	1.0e3072
			dt	1.0e3328
			dt	1.0e3584
			dt	1.0e4096
			dt	1.0e4352
			dt	1.0e4608
			dt	1.0e4864

fp2			dq 2.0
pidiv4		dq 0.785398163397

.code

strcpy proc uses esi edi,lpDest:DWORD,lpSource:DWORD

	mov		esi,lpSource
	xor		ecx,ecx
	mov		edi,lpDest
  @@:
	mov		al,[esi+ecx]
	mov		[edi+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcpy endp

strcpyn proc uses esi edi,lpDest:DWORD,lpSource:DWORD,nLen:DWORD

	mov		esi,lpSource
	mov		edx,nLen
	dec		edx
	xor		ecx,ecx
	mov		edi,lpDest
  @@:
	.if sdword ptr ecx<edx
		mov		al,[esi+ecx]
		mov		[edi+ecx],al
		inc		ecx
		or		al,al
		jne		@b
	.else
		mov		byte ptr [edi+ecx],0
	.endif
	ret

strcpyn endp

strcat proc uses esi edi,lpDest:DWORD,lpSource:DWORD

	xor		eax,eax
	xor		ecx,ecx
	dec		eax
	mov		edi,lpDest
  @@:
	inc		eax
	cmp		[edi+eax],cl
	jne		@b
	mov		esi,lpSource
	lea		edi,[edi+eax]
  @@:
	mov		al,[esi+ecx]
	mov		[edi+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcat endp

strlen proc uses esi,lpSource:DWORD

	xor		eax,eax
	dec		eax
	mov		esi,lpSource
  @@:
	inc		eax
	cmp		byte ptr [esi+eax],0
	jne		@b
	ret

strlen endp

strcmp proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD

	mov		esi,lpStr1
	mov		edi,lpStr2
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	mov		al,[esi+ecx]
	sub		al,[edi+ecx]
	jne		@f
	cmp		al,[esi+ecx]
	jne		@b
  @@:
	cbw
	cwde
	ret

strcmp endp

strcmpn proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD,nCount:DWORD

	mov		esi,lpStr1
	mov		edi,lpStr2
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	cmp		ecx,nCount
	je		@f
	mov		al,[esi+ecx]
	mov		ah,[edi+ecx]
	sub		al,ah
	jne		@f
	cmp		al,[esi+ecx]
	jne		@b
  @@:
	cbw
	cwde
	ret

strcmpn endp

strcmpi proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD

	mov		esi,lpStr1
	mov		edi,lpStr2
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	mov		al,[esi+ecx]
	mov		ah,[edi+ecx]
	.if al>='a' && al<='z'
		and		al,5Fh
	.endif
	.if ah>='a' && ah<='z'
		and		ah,5Fh
	.endif
	sub		al,ah
	jne		@f
	cmp		al,[esi+ecx]
	jne		@b
  @@:
	cbw
	cwde
	ret

strcmpi endp

DecToBin proc uses ebx esi,lpStr:DWORD
	LOCAL	fNeg:DWORD

    mov     esi,lpStr
    mov		fNeg,FALSE
    mov		al,[esi]
    .if al=='-'
		inc		esi
		mov		fNeg,TRUE
    .endif
    xor     eax,eax
  @@:
    cmp     byte ptr [esi],30h
    jb      @f
    cmp     byte ptr [esi],3Ah
    jnb     @f
    mov     ebx,eax
    shl     eax,2
    add     eax,ebx
    shl     eax,1
    xor     ebx,ebx
    mov     bl,[esi]
    sub     bl,30h
    add     eax,ebx
    inc     esi
    jmp     @b
  @@:
	.if fNeg
		neg		eax
	.endif
    ret

DecToBin endp

BinToDec proc dwVal:DWORD,lpAscii:DWORD

    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi
	mov		eax,dwVal
	mov		edi,lpAscii
	or		eax,eax
	jns		pos
	mov		byte ptr [edi],'-'
	neg		eax
	inc		edi
  pos:      
	mov		ecx,429496730
	mov		esi,edi
  @@:
	mov		ebx,eax
	mul		ecx
	mov		eax,edx
	lea		edx,[edx*4+edx]
	add		edx,edx
	sub		ebx,edx
	add		bl,'0'
	mov		[edi],bl
	inc		edi
	or		eax,eax
	jne		@b
	mov		byte ptr [edi],al
	.while esi<edi
		dec		edi
		mov		al,[esi]
		mov		ah,[edi]
		mov		[edi],al
		mov		[esi],ah
		inc		esi
	.endw
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    ret

BinToDec endp

AsciiToFp proc uses ebx esi edi,lpAscii:DWORD,lpAcmltr:DWORD
	LOCAL	tmp:DWORD

	mov		esi,lpAscii
	xor		ebx,ebx
	; First, see if we have a sign at the front end.
	movzx	eax,byte ptr [esi]
	.if eax=='+'
		inc		esi
		movzx	eax,byte ptr [esi]
	.elseif eax=='-'
		inc		esi
		inc		ebx
		movzx	eax,byte ptr [esi]
	.endif
	fldz
	xor		edi,edi
	xor		edx,edx
	xor		ecx,ecx
	; OK, now start our main loop.
	;   esi => character in string now in al
	;   al = next character to be converted
	;   edx = number of digits encountered thus far
	;   ecx = exponent
	;   ST(0) = accumulator
cvtloop:
	cmp		eax,'E'
	je		doExponent
	cmp		eax,'e'
	je		doExponent
	cmp		eax,'.'
	je		doDecimal
	xor		eax,'0'
	cmp		eax,10
	jnb		sdFinish			; if not a digit
	inc		esi
	fmul	ten					; d *= 10
	mov		tmp,eax
	add		edx,edi				; increment digit counter
	movzx	eax,byte ptr [esi]
	fiadd	dword ptr tmp		; d += new digit
	jmp		cvtloop
doDecimal:
	inc		esi
	mov		edi,1
	movzx	eax,byte ptr [esi]
	jmp		cvtloop

	; We have the mantissa at the top of the stack.  Now convert the exponent.
	; Fortunately, this is an integer.
	;   esi = pointer to character in al
	;   al = next character to convert
	;   ebx = digit counter
	;   ecx = accumulated exponent
	;   ST(0) = mantissa
doExponent:
	inc		esi
	movzx	eax,byte ptr [esi]
	; Does the exponent have a sign?
	.if	eax=='+'
		inc		esi
		movzx	eax,byte ptr [esi]
	.elseif eax=='-'
		inc		esi
		inc		bh
		movzx	eax,byte ptr [esi]
	.endif
	xor		eax,'0'
	cmp		eax,10
	jnb		sdFinish
expLoop:
	lea		ecx,[ecx*4+ecx]
	inc		esi
	lea		ecx,[ecx*2+eax]
	movzx	eax,byte ptr [esi]
	xor		eax,'0'
	cmp		eax,10
	jb		expLoop
	; Adjust the exponent to account for decimal places.  At this juncture, 
	; we work with the absolute value of the exponent.  That means we need
	; to subtract the adjustment if the exponent will be negative, add if
	; the exponent will be positive.
	;  ST(0) = mantissa
	;  ecx = unadjusted exponent
	;  ebx = total number of digits
sdFinish:
	or		bh,bh;test	ebx,100h
	je		@f
	;exp sign
	neg		ecx
  @@:
	;decimal position
	sub		ecx,edx	; adjust exponent
	mov		edi,lpAcmltr
	je		@f
	;  ecx = exponent
	; Multiply a floating point value by an integral power of 10.
	; Entry: EAX = power of 10, -4932..4932.
	;	ST(0) = value to be multiplied
	; Exit:	ST(0) = value x 10^eax
	mov		eax,ecx
	.if	(SDWORD PTR ecx < 0)
		neg		ecx
	.endif
	fld1
	mov		edx,ecx
	and		edx,0Fh
	.if	(!ZERO?)
		lea		edx,[edx+edx*4]
		fld		ten_1[edx*2][-10]
		fmulp	st(1),st
	.endif
	mov		edx,ecx
	shr		edx,4
	and		edx,0Fh
	.if (!ZERO?)
		lea		edx,[edx+edx*4]
		fld		ten_16[edx*2][-10]
		fmulp	st(1),st
	.endif
	mov		dl,ch
	and		edx,1Fh
	.if (!ZERO?)
		lea		edx,[edx+edx*4]
		fld		ten_256[edx*2][-10]
		fmulp	st(1),st
	.endif
	.if (SDWORD PTR eax < 0)
		fdivp	st(1),st
	.else
		fmulp	st(1),st
	.endif
  @@:
	; Negate the whole thing, if necessary.
	or		bl,bl;test	ebx,1
	je		@f
	fchs
  @@:
	; That's it!  Store it and go home.
	mov		eax,esi	; return pt to next unread char
	fstp	tbyte ptr [edi]	; store the reslt
	fwait
	ret

AsciiToFp endp

FpToAscii proc USES esi edi,lpFpin:DWORD,lpStr:DWORD,fSci:DWORD
	LOCAL	iExp:DWORD
	LOCAL	sztemp[32]:BYTE
	LOCAL	temp:TBYTE

	mov		esi,lpFpin
	mov		edi,lpStr
	.if	dword ptr [esi]== 0 && dword ptr [esi+4]==0
		; Special case zero.  fxtract fails for zero.
		mov		word ptr [edi], '0'
		ret
	.endif
	; Check for a negative number.
	push	[esi+6]
	.if	sdword ptr [esi+6]<0
		and		byte ptr [esi+9],07fh	; change to positive
		mov		byte ptr [edi],'-'		; store a minus sign
		inc		edi
	.endif
	fld		TBYTE ptr [esi]
	fld		st(0)
	; Compute the closest power of 10 below the number.  We can't get an
	; exact value because of rounding.  We could get close by adding in
	; log10(mantissa), but it still wouldn't be exact.  Since we'll have to
	; check the result anyway, it's silly to waste cycles worrying about
	; the mantissa.
	;
	; The exponent is basically log2(lpfpin).  Those of you who remember
	; algebra realize that log2(lpfpin) x log10(2) = log10(lpfpin), which is
	; what we want.
	fxtract					; ST=> mantissa, exponent, [lpfpin]
	fstp	st(0)			; drop the mantissa
	fldlg2					; push log10(2)
	fmulp	st(1),st		; ST = log10([lpfpin]), [lpfpin]
	fistp 	iExp			; ST = [lpfpin]
	; A 10-byte double can carry 19.5 digits, but fbstp only stores 18.
	.IF	iExp<18
		fld		st(0)		; ST = lpfpin, lpfpin
		frndint				; ST = int(lpfpin), lpfpin
		fcomp	st(1)		; ST = lpfpin, status set
		fstsw	ax
		.IF ah&FP_EQUALTO && !fSci	; if EQUAL
			; We have an integer!  Lucky day.  Go convert it into a temp buffer.
			call FloatToBCD
			mov		eax,17
			mov		ecx,iExp
			sub		eax,ecx
			inc		ecx
			lea		esi,[sztemp+eax]
			; The off-by-one order of magnitude problem below can hit us here.  
			; We just trim off the possible leading zero.
			.IF byte ptr [esi]=='0'
				inc esi
				dec ecx
			.ENDIF
			; Copy the rest of the converted BCD value to our buffer.
			rep movsb
			jmp ftsExit
		.ENDIF
	.ENDIF
	; Have fbstp round to 17 places.
	mov		eax, 17			; experiment
	sub		eax,iExp		; adjust exponent to 17
	call PowerOf10
	; Either we have exactly 17 digits, or we have exactly 16 digits.  We can
	; detect that condition and adjust now.
	fcom	ten16
	; x0xxxx00 means top of stack > ten16
	; x0xxxx01 means top of stack < ten16
	; x1xxxx00 means top of stack = ten16
	fstsw	ax
	.IF ah & 1
		fmul	ten
		dec		iExp
	.ENDIF
	; Go convert to BCD.
	call FloatToBCD
	lea		esi,sztemp		; point to converted buffer
	; If the exponent is between -15 and 16, we should express this as a number
	; without scientific notation.
	mov ecx, iExp
	.IF SDWORD PTR ecx>=-15 && SDWORD PTR ecx<=16 && !fSci
		; If the exponent is less than zero, we insert '0.', then -ecx
		; leading zeros, then 16 digits of mantissa.  If the exponent is
		; positive, we copy ecx+1 digits, then a decimal point (maybe), then 
		; the remaining 16-ecx digits.
		inc ecx
		.IF SDWORD PTR ecx<=0
			mov		word ptr [edi],'.0'
			add		edi, 2
			neg		ecx
			mov		al,'0'
			rep		stosb
			mov		ecx,18
		.ELSE
			.if byte ptr [esi]=='0' && ecx>1
				inc		esi
				dec		ecx
			.endif
			rep		movsb
			mov		byte ptr [edi],'.'
			inc		edi
			mov		ecx,17
			sub		ecx,iExp
		.ENDIF
		rep movsb
		; Trim off trailing zeros.
		.WHILE byte ptr [edi-1]=='0'
			dec		edi
		.ENDW
		; If we cleared out all the decimal digits, kill the decimal point, too.
		.IF byte ptr [edi-1]=='.'
			dec		edi
		.ENDIF
		; That's it.
		jmp		ftsExit
	.ENDIF
	; Now convert this to a standard, usable format.  If needed, a minus
	; sign is already present in the outgoing buffer, and edi already points
	; past it.
	mov		ecx,17
	.if byte ptr [esi]=='0'
		inc		esi
		dec		iExp
		dec		ecx
	.endif
	movsb						; copy the first digit
	mov		byte ptr [edi],'.'	; plop in a decimal point
	inc		edi
	rep movsb
	; The printf %g specified trims off trailing zeros here.  I dislike
	; this, so I've disabled it.  Comment out the if 0 and endif if you
	; want this.
	.WHILE byte ptr [edi-1]=='0'
		dec		edi
	.ENDW
	.if byte ptr [edi-1]=='.'
		dec		edi
	.endif
	; Shove in the exponent.
	mov		byte ptr [edi],'e'	; start the exponent
	mov		eax,iExp
	.IF sdword ptr eax<0		; plop in the exponent sign
		mov		byte ptr [edi+1],'-'
		neg		eax
	.ELSE
		mov		byte ptr [edi+1],'+'
	.ENDIF
	mov		ecx, 10
	xor		edx,edx
	div		ecx
	add		dl,'0'
	mov		[edi+5],dl		; shove in the ones exponent digit
	xor		edx,edx
	div		ecx
	add		dl,'0'
	mov		[edi+4],dl		; shove in the tens exponent digit
	xor		edx,edx
	div		ecx
	add		dl,'0'
	mov		[edi+3],dl		; shove in the hundreds exponent digit
	xor		edx,edx
	div		ecx
	add		dl,'0'
	mov		[edi+2],dl		; shove in the thousands exponent digit
	add		edi,6			; point to terminator
ftsExit:
	; Clean up and go home.
	mov		esi,lpFpin
	pop		[esi+6]
	mov		byte ptr [edi],0
	fwait
	ret

; Convert a floating point register to ASCII.
; The result always has exactly 18 digits, with zero padding on the
; left if required.
;
; Entry:	ST(0) = a number to convert, 0 <= ST(0) < 1E19.
;			sztemp = an 18-character buffer.
;
; Exit:		sztemp = the converted result.
FloatToBCD:
	push	esi
	push	edi
    fbstp	temp
	; Now we need to unpack the BCD to ASCII.
    lea		esi,[temp]
    lea		edi,[sztemp]
    mov		ecx,8
    .REPEAT
		movzx	ax,byte ptr [esi+ecx]	; 0000 0000 AAAA BBBB
		rol		ax,12					; BBBB 0000 0000 AAAA
		shr		ah,4					; 0000 BBBB 0000 AAAA
		add		ax,3030h				; 3B3A
		stosw
		dec		ecx
    .UNTIL SIGN?
	pop		edi
	pop		esi
    retn

PowerOf10:
    mov		ecx,eax
    .IF	SDWORD PTR eax<0
		neg		eax
    .ENDIF
    fld1
    mov		dl,al
    and		edx,0fh
    .IF	!ZERO?
		lea		edx,[edx+edx*4]
		fld		ten_1[edx*2][-10]
		fmulp	st(1),st
    .ENDIF
    mov		dl,al
    shr		dl,4
    and		edx,0fh
    .IF !ZERO?
		lea		edx,[edx+edx*4]
		fld		ten_16[edx*2][-10]
		fmulp	st(1),st
    .ENDIF
    mov		dl,ah
    and		edx,1fh
    .IF !ZERO?
		lea		edx,[edx+edx*4]
		fld		ten_256[edx*2][-10]
		fmulp	st(1),st
    .ENDIF
    .IF SDWORD PTR ecx<0
		fdivp	st(1),st
    .ELSE
		fmulp	st(1),st
    .ENDIF
    retn

FpToAscii endp

PrintFp proc lpfVal:DWORD
	LOCAL	buffer[256]:BYTE

	pushad
	invoke FpToAscii,lpfVal,addr buffer,FALSE
	lea		eax,buffer
	PrintStringByAddr eax
	popad
	ret

PrintFp endp

GetItemInt proc uses esi edi,lpBuff:DWORD,nDefVal:DWORD

	mov		esi,lpBuff
	.if byte ptr [esi]
		mov		edi,esi
		invoke DecToBin,edi
		.while byte ptr [esi] && byte ptr [esi]!=','
			inc		esi
		.endw
		.if byte ptr [esi]==','
			inc		esi
		.endif
		push	eax
		invoke strcpy,edi,esi
		pop		eax
	.else
		mov		eax,nDefVal
	.endif
	ret

GetItemInt endp

PutItemInt proc uses esi edi,lpBuff:DWORD,nVal:DWORD

	mov		esi,lpBuff
	invoke strlen,esi
	mov		byte ptr [esi+eax],','
	invoke BinToDec,nVal,addr [esi+eax+1]
	ret

PutItemInt endp

GetItemStr proc uses esi edi,lpBuff:DWORD,lpDefVal:DWORD,lpResult:DWORD,ccMax:DWORD

	mov		esi,lpBuff
	.if byte ptr [esi]
		mov		edi,esi
		.while byte ptr [esi] && byte ptr [esi]!=','
			inc		esi
		.endw
		lea		eax,[esi+1]
		sub		eax,edi
		.if eax>ccMax
			mov		eax,ccMax
		.endif
		invoke strcpyn,lpResult,edi,eax
		.if byte ptr [esi]
			inc		esi
		.endif
		invoke strcpy,edi,esi
	.else
		invoke strcpyn,lpResult,lpDefVal,ccMax
	.endif
	ret

GetItemStr endp

PutItemStr proc uses esi,lpBuff:DWORD,lpStr:DWORD

	mov		esi,lpBuff
	invoke strlen,esi
	mov		byte ptr [esi+eax],','
	invoke strcpy,addr [esi+eax+1],lpStr
	ret

PutItemStr endp

;minor28
;y = a*ln(tan(45deg + latitude/2deg))
;where a is semi-major axis = 6378137m
;http://mercator.myzen.co.uk/mercator.pdf
;y = a*ln[tan(Rad(lat)/2+PI/4)]
LatToPos proc iLat:DWORD

	fild	iLat
	;Convert to decimal by dividing with 1 000 000
	fdiv	dqdiv
	;Convert to radians
	fmul    deg2rad
	;Divide by 2
	fdiv	fp2
	;Add PI / 4
	fadd	pidiv4
	fptan
	;Pop the 1.0
	fstp	st
	;ln
	fldln2
	fxch	st(1)
	fyl2x
	ret

LatToPos endp

MakeLatPoints proc uses edi,iLatTop:DWORD,iLatBottom:DWORD,nTiles:DWORD,lpPoints:DWORD
	LOCAL	fDiff:REAL8
	LOCAL	fPos:REAL8
	LOCAL	ypos:DWORD

	invoke LatToPos,iLatBottom
	fstp	fPos
	invoke LatToPos,iLatTop
	fsub	fPos
	fidiv	nTiles
	fstp	fDiff
	mov		eax,nTiles
	mov		map.nLatPoint,eax
	shl		eax,9
	mov		ypos,eax
	mov		edi,lpPoints
	mov		eax,nTiles
	dec		eax
	mov		ecx,sizeof LATPOINT
	imul	ecx
	lea		edi,[edi+eax]
	.while sdword ptr ypos>=0
		mov		eax,iLatBottom
		mov		[edi].LATPOINT.iLat,eax
		mov		eax,ypos
		mov		[edi].LATPOINT.iypos,eax
		lea		edi,[edi-sizeof LATPOINT]
		fld		fDiff
		fadd	fPos
		fstp	fPos
		.while TRUE
			inc		iLatBottom
			invoke LatToPos,iLatBottom
			fcomp	fPos
			fstsw	ax
			sahf
			.break .if !CARRY?
		.endw
	  @@:
		sub		ypos,512
	.endw
	ret

MakeLatPoints endp

CountMapTiles proc uses ebx,mapinx:DWORD,lpnx:DWORD,lpny:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	;Get number of maps in x direction
	xor		ebx,ebx
	.while TRUE
		invoke wsprintf,addr buffer,addr szFileName,addr szAppPath,mapinx,0,ebx
		invoke GetFileAttributes,addr buffer
		.break .if eax==INVALID_HANDLE_VALUE
		mov		edx,lpnx
		mov		[edx],ebx
		inc		ebx
	.endw
	;Get number of maps in y direction
	xor		ebx,ebx
	.while TRUE
		invoke wsprintf,addr buffer,addr szFileName,addr szAppPath,mapinx,ebx,0
		invoke GetFileAttributes,addr buffer
		.break .if eax==INVALID_HANDLE_VALUE
		mov		edx,lpny
		mov		[edx],ebx
		inc		ebx
	.endw
	ret

CountMapTiles endp

;Load mappoints
LoadMapPoints proc uses ebx esi edi
	LOCAL	buffer[256]:BYTE
	LOCAL	rect:RECT
	LOCAL	nx:DWORD
	LOCAL	ny:DWORD
	LOCAL	hMem:HGLOBAL

	invoke CountMapTiles,1,addr nx,addr ny
	inc		nx
	inc		ny
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,4096
	mov		map.hMemLon,eax
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,4096
	mov		map.hMemLat,eax
	;Get map rectangle
	invoke GetPrivateProfileString,addr szIniMap,addr szIniMapRect,addr szNULL,addr buffer,sizeof buffer,addr szIniFileName
	.if eax
		invoke GetItemInt,addr buffer,0
		mov		rect.left,eax
		invoke GetItemInt,addr buffer,0
		mov		rect.top,eax
		invoke GetItemInt,addr buffer,0
		mov		rect.right,eax
		invoke GetItemInt,addr buffer,0
		mov		rect.bottom,eax
		;Setup longitude
		mov		edi,map.hMemLon
		mov		eax,rect.left
		mov		[edi].LONPOINT.iLon,eax
		mov		[edi].LONPOINT.ixpos,0
		lea		edi,[edi+sizeof LONPOINT]
		mov		eax,rect.right
		mov		[edi].LONPOINT.iLon,eax
		mov		eax,nx
		shl		eax,9
		mov		[edi].LONPOINT.ixpos,eax
		mov		map.nLonPoint,2
		;Setup lattitude
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,4096
		mov		hMem,eax
		invoke GetPrivateProfileString,addr szIniMap,addr szIniLatArray,addr szNULL,hMem,4096,addr szIniFileName
		.if eax
			;A predefined array exists
			mov		ebx,ny
			mov		map.nLatPoint,ebx
			xor		esi,esi
			mov		edi,map.hMemLat
			.while ebx
				invoke GetItemInt,hMem,0
				mov		[edi].LATPOINT.iLat,eax
				mov		[edi].LATPOINT.iypos,esi
				lea		esi,[esi+512]
				lea		edi,[edi+sizeof LATPOINT]
				dec		ebx
			.endw
		.else
			;Calculate the array
			invoke MakeLatPoints,rect.top,rect.bottom,ny,map.hMemLat
			;Save the array to ini
			mov		edi,hMem
			mov		esi,map.hMemLat
			mov		ebx,ny
			invoke PutItemInt,edi,rect.top
			.while ebx
				invoke PutItemInt,edi,[esi].LATPOINT.iLat
				lea		esi,[esi+sizeof LATPOINT]
				dec		ebx
			.endw
			invoke WritePrivateProfileString,addr szIniMap,addr szIniLatArray,addr [edi+1],addr szIniFileName
		.endif
		invoke GlobalFree,hMem
	.endif
	ret

LoadMapPoints endp

;Distance between two points:
;Spherical law of cosines: d = acos(sin(lat1).sin(lat2)+cos(lat1).cos(lat2).cos(long2-long1)).R
;R = earth’s radius (mean radius = 6,371km)
GetDistance proc uses ebx esi edi,lpLOG:DWORD,nCount:DWORD
	LOCAL	fDist:REAL10
	LOCAL	fBear:REAL10
	LOCAL	fSumDist:REAL10
	LOCAL	iSumDist:DWORD

	fldz
	fstp	fSumDist
	xor		ebx,ebx
	mov		esi,lpLOG
	.while ebx<nCount
		mov		eax,sizeof LOG
		mul		ebx
		mov		edi,eax
		invoke BearingDistanceInt,[esi].LOG.iLon[edi],[esi].LOG.iLat[edi],[esi].LOG.iLon[edi+sizeof LOG],[esi].LOG.iLat[edi+sizeof LOG],addr fDist,addr fBear
		fld		fBear
		fistp	[esi].LOG.iBear[edi]
		fld		fSumDist
		fld		fDist
		faddp	st(1),st(0)
		fstp	fSumDist
		inc		ebx
	.endw
	fld		fSumDist
	fistp	iSumDist
	invoke SetDlgItemInt,hWnd,IDC_EDTDIST,iSumDist,FALSE
	invoke SetDlgItemInt,hWnd,IDC_EDTBEAR,[esi].LOG.iBear[edi],FALSE
	ret

GetDistance endp

;In:  Number of map tiles
;Out: Pixels and meters
GetMapSize proc	uses ebx esi edi,nx:DWORD,ny:DWORD,lpxPixels:DWORD,lpyPixels:DWORD,lpxDist:DWORD,lpyDist:DWORD
	LOCAL	fDist:REAL10
	LOCAL	fBear:REAL10

	;Get the width of the map in pixels, each tile is 512x512 pixels
	mov		eax,nx
	inc		eax
	shl		eax,9
	mov		edx,lpxPixels
	mov		[edx],eax
	;Get the height of the map in pixels, each tile is 512x512 pixels
	mov		eax,ny
	inc		eax
	shl		eax,9
	mov		edx,lpyPixels
	mov		[edx],eax
	;Get the width of the map in meters
	mov		esi,map.hMemLon
	mov		edi,map.hMemLat
	mov		ecx,map.nLonPoint
	dec		ecx
	invoke BearingDistanceInt,[esi].LONPOINT.iLon,[edi].LATPOINT.iLat,[esi].LONPOINT.iLon[ecx*sizeof LONPOINT],[edi].LATPOINT.iLat,addr fDist,addr fBear
	fld		fDist
	mov		eax,lpxDist
	fistp	dword ptr [eax]
	;Get the height of the map in meters
	mov		ecx,map.nLatPoint
	dec		ecx
	invoke BearingDistanceInt,[esi].LONPOINT.iLon,[edi].LATPOINT.iLat,[esi].LONPOINT.iLon,[edi].LATPOINT.iLat[ecx*sizeof LATPOINT],addr fDist,addr fBear
	fld		fDist
	mov		eax,lpyDist
	fistp	dword ptr [eax]
	ret

GetMapSize endp

;Converting and zooming functions

;In:  Screen position
;Out: Map position
ScrnPosToMapPos proc x:DWORD,y:DWORD,lpX:DWORD,lpY:DWORD

	mov		eax,x
	imul	map.zoomval
	idiv	dd256
	add		eax,map.topx
	mov		ecx,eax
	mov		eax,y
	imul	map.zoomval
	idiv	dd256
	add		eax,map.topy
	mov		edx,eax
	mov		eax,map.mapinx
	.if eax==4
		shl		ecx,1
		shl		edx,1
	.elseif eax==16
		shl		ecx,2
		shl		edx,2
	.elseif eax==64
		shl		ecx,3
		shl		edx,3
	.elseif eax==256
		shl		ecx,4
		shl		edx,4
	.endif
	mov		eax,lpX
	mov		[eax],ecx
	mov		eax,lpY
	mov		[eax],edx
	ret

ScrnPosToMapPos endp

;In:  Map position
;Out: Screen position
MapPosToScrnPos proc x:DWORD,y:DWORD,lpX:DWORD,lpY:DWORD

	mov		ecx,x
	mov		edx,y
	mov		eax,map.mapinx
	.if eax==4
		shr		ecx,1
		shr		edx,1
	.elseif eax==16
		shr		ecx,2
		shr		edx,2
	.elseif eax==64
		shr		ecx,3
		shr		edx,3
	.elseif eax==256
		shr		ecx,4
		shr		edx,4
	.endif
	mov		eax,lpX
	mov		[eax],ecx
	mov		eax,lpY
	mov		[eax],edx
	ret

MapPosToScrnPos endp

MapPosToGpsPos proc uses ebx esi edi,x:DWORD,y:DWORD,lpiLon:DWORD,lpiLat:DWORD

	mov		esi,map.hMemLon
	mov		ebx,map.nLonPoint
	mov		eax,x
	.while eax>=[esi].LONPOINT.ixpos && ebx>1
		mov		edi,esi
		lea		esi,[esi+sizeof LONPOINT]
		dec		ebx
	.endw
	mov		eax,x
	sub		eax,[edi].LONPOINT.ixpos
	mov		ecx,[esi].LONPOINT.iLon
	sub		ecx,[edi].LONPOINT.iLon
	imul	ecx
	mov		ecx,[esi].LONPOINT.ixpos
	sub		ecx,[edi].LONPOINT.ixpos
	idiv	ecx
	add		eax,[edi].LONPOINT.iLon
	mov		edx,lpiLon
	mov		[edx],eax

	mov		esi,map.hMemLat
	mov		ebx,map.nLatPoint
	mov		eax,y
	.while eax>=[esi].LATPOINT.iypos && ebx>1
		mov		edi,esi
		lea		esi,[esi+sizeof LATPOINT]
		dec		ebx
	.endw
	mov		eax,y
	sub		eax,[edi].LATPOINT.iypos
	mov		ecx,[esi].LATPOINT.iLat
	sub		ecx,[edi].LATPOINT.iLat
	imul	ecx
	mov		ecx,[esi].LATPOINT.iypos
	sub		ecx,[edi].LATPOINT.iypos
	idiv	ecx
	add		eax,[edi].LATPOINT.iLat
	mov		edx,lpiLat
	mov		[edx],eax
	ret

MapPosToGpsPos endp

GpsPosToMapPos proc uses ebx esi edi,iLon:DWORD,iLat:DWORD,lpix:DWORD,lpiy:DWORD

	;Get X pos
	mov		esi,map.hMemLon
	lea		edi,[esi+sizeof LONPOINT]
	mov		ebx,map.nLonPoint
	mov		eax,iLon
	mov		eax,iLon
	sub		eax,[esi].LONPOINT.iLon
	mov		ecx,[edi].LONPOINT.ixpos
	sub		ecx,[esi].LONPOINT.ixpos
	imul	ecx
	mov		ecx,[edi].LONPOINT.iLon
	sub		ecx,[esi].LONPOINT.iLon
	idiv	ecx
	add		eax,[esi].LONPOINT.ixpos
	mov		edx,lpix
	mov		[edx],eax
	;Get Y pos
	mov		esi,map.hMemLat
	mov		edi,esi
	mov		ebx,map.nLatPoint
	mov		eax,iLat
	.while sdword ptr eax<=[esi].LATPOINT.iLat && ebx>1
		mov		edi,esi
		lea		esi,[esi+sizeof LATPOINT]
		dec		ebx
	.endw
	.if esi!=edi
		mov		eax,[edi].LATPOINT.iLat
		sub		eax,iLat
		mov		ecx,[esi].LATPOINT.iypos
		sub		ecx,[edi].LATPOINT.iypos
		imul	ecx
		mov		ecx,[edi].LATPOINT.iLat
		sub		ecx,[esi].LATPOINT.iLat
		idiv	ecx
		add		eax,[edi].LATPOINT.iypos
	.else
		xor		eax,eax
	.endif
	mov		edx,lpiy
	mov		[edx],eax
	ret

GpsPosToMapPos endp

DoGoto proc iLon:DWORD,iLat:DWORD,fLock:DWORD,fCursor
	LOCAL	x:DWORD
	LOCAL	y:DWORD

	invoke GpsPosToMapPos,iLon,iLat,addr x,addr y
	invoke MapPosToScrnPos,x,y,addr x,addr y
	.if fLock
		mov		eax,map.mapwt
		imul	map.zoomval
		idiv	dd512
		mov		edx,x
		sub		edx,eax
		.if SIGN?
			xor		edx,edx
		.endif
		mov		map.topx,edx
		mov		eax,map.mapht
		imul	map.zoomval
		idiv	dd512
		mov		edx,y
		sub		edx,eax
		.if SIGN?
			xor		edx,edx
		.endif
		mov		map.topy,edx
		mov		eax,map.topx
		shr		eax,4
		invoke SetScrollPos,hMap,SB_HORZ,eax,TRUE
		mov		eax,map.topy
		shr		eax,4
		invoke SetScrollPos,hMap,SB_VERT,eax,TRUE
	.endif
	.if fCursor
		mov		eax,x
		mov		map.cursorx,eax
		mov		eax,y
		mov		map.cursory,eax
	.endif
	ret

DoGoto endp

ZoomMap proc uses ebx esi edi,zoominx:DWORD
	LOCAL	x:DWORD
	LOCAL	y:DWORD
	LOCAL	iLon:DWORD
	LOCAL	iLat:DWORD

	mov		ecx,map.mapwt
	shr		ecx,1
	mov		edx,map.mapht
	shr		edx,1
	invoke ScrnPosToMapPos,ecx,edx,addr x,addr y
	invoke MapPosToGpsPos,x,y,addr iLon,addr iLat
	mov		edi,offset map.zoom
	mov		eax,zoominx
	mov		map.zoominx,eax
	mov		edx,sizeof ZOOM
	mul		edx
	lea		edi,[edi+eax]
	mov		eax,[edi].ZOOM.zoomval
	mov		map.zoomval,eax
	mov		eax,[edi].ZOOM.mapinx
	mov		map.mapinx,eax
	mov		eax,[edi].ZOOM.nx
	mov		map.nx,eax
	mov		eax,[edi].ZOOM.ny
	mov		map.ny,eax
	invoke strcpy,addr map.options.text[sizeof OPTIONS*3],addr [edi].ZOOM.text
	invoke DoGoto,iLon,iLat,TRUE,FALSE
	invoke InitScroll
	inc		map.paintnow
	ret

ZoomMap endp

;In: Longitude, Lattitude,Bearing,Time
AddTrailPoint proc x:DWORD,y:DWORD,iBearing:DWORD,iTime:DWORD

	mov		eax,map.trailhead
	mov		edx,sizeof LOG
	mul		edx
	mov		ecx,eax
	mov		edx,map.trailhead
	mov		eax,x
	mov		map.trail.iLon[ecx],eax
	mov		eax,y
	mov		map.trail.iLat[ecx],eax
	mov		eax,iBearing
	mov		map.trail.iBear[ecx],eax
	mov		eax,iTime
	mov		map.trail.iTime[ecx],eax
	inc		edx
	and		edx,MAXTRAIL-1
	mov		map.trailhead,edx
	.if edx==map.trailtail
		inc		edx
		and		edx,MAXTRAIL-1
		mov		map.trailtail,edx
	.endif
	ret

AddTrailPoint endp

FindPoint proc uses ebx esi,x:DWORD,y:DWORD,lpLOG:DWORD,nCount:DWORD
	LOCAL	mx:DWORD
	LOCAL	my:DWORD
	LOCAL	iLon:DWORD
	LOCAL	iLat:DWORD
	LOCAL	dLon:DWORD
	LOCAL	dLat:DWORD

	mov		ecx,150
	mov		edx,75
	mov		eax,map.mapinx
	.if eax==4
		shl		ecx,1
		shl		edx,1
	.elseif eax==16
		shl		ecx,2
		shl		edx,2
	.elseif eax==64
		shl		ecx,3
		shl		edx,3
	.elseif eax==256
		shl		ecx,4
		shl		edx,4
	.endif
	mov		eax,edx
	imul	map.zoomval
	idiv	dd256
	mov		dLat,eax
	mov		eax,ecx
	imul	map.zoomval
	idiv	dd256
	mov		dLon,eax
	invoke ScrnPosToMapPos,x,y,addr mx,addr my
	invoke MapPosToGpsPos,mx,my,addr iLon,addr iLat
	mov		ecx,iLon
	mov		edx,iLat
	xor		ebx,ebx
	mov		esi,lpLOG
	.while ebx<nCount
		mov		eax,ecx
		sub		eax,[esi].LOG.iLon
		.if CARRY?
			neg		eax
		.endif
		.if eax<=dLon
			mov		eax,edx
			sub		eax,[esi].LOG.iLat
			.if CARRY?
				neg		eax
			.endif
			.if eax<=dLat
				mov		eax,ebx
				jmp		Ex
			.endif
		.endif
		lea		esi,[esi+sizeof LOG]
		inc		ebx
	.endw
	mov		eax,-1
Ex:
	ret

FindPoint endp

InsertPoint proc uses ebx esi edi,nPoint:DWORD,lpLOG:DWORD,lpCount:DWORD

	mov		ebx,lpCount
	mov		eax,[ebx]
	inc		dword ptr [ebx]
	mov		edx,sizeof LOG
	mul		edx
	mov		edi,lpLOG
	lea		edi,[edi+eax]
	lea		esi,[edi-sizeof LOG]
	mov		ebx,[ebx]
	dec		ebx
	.while ebx>nPoint
		invoke RtlMoveMemory,edi,esi,sizeof LOG
		lea		edi,[edi-sizeof LOG]
		lea		esi,[esi-sizeof LOG]
		dec		ebx
	.endw
	;Adjust point
	mov		eax,lpCount
	mov		eax,[eax]
	dec		eax
	dec		eax
	.if !eax
		;Only one point, just add some offset to the new point
		lea		edi,[edi+sizeof LOG]
		add		[edi].LOG.iLon,16
		add		[edi].LOG.iLat,16
	.elseif eax==nPoint
		;End point, insert point before current point
		mov		eax,[edi-sizeof LOG].LOG.iLon
		sub		eax,[edi].LOG.iLon
		sar		eax,1
		add		[edi].LOG.iLon,eax
		mov		eax,[edi-sizeof LOG].LOG.iLat
		sub		eax,[edi].LOG.iLat
		sar		eax,1
		add		[edi].LOG.iLat,eax
	.else
		;Insert point after current point
		lea		edi,[edi+sizeof LOG]
		mov		eax,[edi+sizeof LOG].LOG.iLon
		sub		eax,[edi].LOG.iLon
		sar		eax,1
		add		[edi].LOG.iLon,eax
		mov		eax,[edi+sizeof LOG].LOG.iLat
		sub		eax,[edi].LOG.iLat
		sar		eax,1
		add		[edi].LOG.iLat,eax
	.endif
	inc		map.paintnow
	ret

InsertPoint endp

DeletePoint proc nPoint:DWORD,lpLOG:DWORD,lpCount:DWORD

	mov		eax,nPoint
	mov		edx,sizeof LOG
	mul		edx
	mov		edi,lpLOG
	lea		edi,[edi+eax]
	lea		esi,[edi+sizeof LOG]
	mov		ebx,lpCount
	dec		dword ptr [ebx]
	mov		eax,nPoint
	.while eax<[ebx]
		push	eax
		invoke RtlMoveMemory,edi,esi,sizeof LOG
		pop		eax
		inc		eax
		lea		edi,[edi+sizeof LOG]
		lea		esi,[esi+sizeof LOG]
	.endw
	inc		map.paintnow
	ret

DeletePoint endp

SaveStatus proc
	LOCAL	buffer[256]:BYTE

	mov		buffer,0
	invoke PutItemInt,addr buffer,map.topx
	invoke PutItemInt,addr buffer,map.topy
	invoke PutItemInt,addr buffer,map.cursorx
	invoke PutItemInt,addr buffer,map.cursory
	invoke WritePrivateProfileString,addr szIniMap,addr szIniPos,addr buffer[1],addr szIniFileName
	mov		buffer,0
	invoke PutItemInt,addr buffer,map.zoominx
	invoke WritePrivateProfileString,addr szIniMap,addr szIniZoom,addr buffer[1],addr szIniFileName
	ret

SaveStatus endp

;TextDraw proc uses edi,hDC:HDC,hFont:HFONT,lpRect:PTR RECT,lpText:DWORD,pos:DWORD
TextDraw proc uses edi,hDC:HDC,hFont:HFONT,lpRect:DWORD,lpText:DWORD,pos:DWORD
	LOCAL	rect:RECT

	invoke strlen,lpText
	mov		edi,eax
	invoke CopyRect,addr rect,lpRect
	invoke SelectObject,hDC,hFont
	push	eax
	invoke SetTextColor,hDC,0FFFFFFh
	invoke DrawText,hDC,lpText,edi,addr rect,pos
	add		rect.top,4
	add		rect.bottom,4
	invoke DrawText,hDC,lpText,edi,addr rect,pos
	sub		rect.top,2
	sub		rect.bottom,2
	sub		rect.left,2
	sub		rect.right,2
	invoke DrawText,hDC,lpText,edi,addr rect,pos
	add		rect.left,4
	add		rect.right,4
	invoke DrawText,hDC,lpText,edi,addr rect,pos
	sub		rect.left,2
	sub		rect.right,2
	invoke SetTextColor,hDC,0
	invoke DrawText,hDC,lpText,edi,addr rect,pos
	pop		eax
	invoke SelectObject,hDC,eax
	ret

TextDraw endp
