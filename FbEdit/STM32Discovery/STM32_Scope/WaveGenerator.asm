
.code

SetDAC_CR proc uses ebx
	LOCAL	daccr:DWORD

	mov		daccr,0
	;Channel A, DAC_CR
	.if wavedata.waveCHAdata.enable
		xor		ebx,ebx
		;Enable DAC. DAC_CR:EN
		or		ebx,00000001h
		;Buffered disable. DAC_CR:BOFF
		mov		eax,wavedata.waveCHAdata.buffered
		.if !eax
			or		ebx,00000002h
		.endif
		;Enable trigger. DAC_CR:TEN
		or		ebx,00000004h
		;Trigger select. DAC_CR:TSEL, Timer 6 = 000
		or		ebx,00000000h
		;DAC wave. DAC_CR:WAVE. 00=Disabled, 01=Noise,10=Triangle 
		mov		eax,wavedata.waveCHAdata.mode
		.if eax==WAVE_ModeNoise
			or		ebx,00000040h
			;DAC Amplitude / Mask. DAC_CR:MAMP
			mov		eax,wavedata.waveCHAdata.noiseamplitude
			shl		eax,8
			or		ebx,eax
		.elseif eax==WAVE_ModeTriangle
			or		ebx,00000080h
			;DAC Amplitude / Mask. DAC_CR:MAMP
			mov		eax,wavedata.waveCHAdata.triangleamplitude
			shl		eax,8
			or		ebx,eax
		.elseif eax==WAVE_ModeSquare
			or		ebx,00000080h
			;DAC Amplitude / Mask. DAC_CR:MAMP
			mov		eax,0
			shl		eax,8
			or		ebx,eax
		.elseif eax==WAVE_ModeSinwave
			;DAC DMA. DAC_CR:DMAEN
			or		ebx,00001000h
		.elseif eax==WAVE_ModeWaveFile
			;DAC DMA. DAC_CR:DMAEN
			or		ebx,00001000h
		.endif
		or		daccr,ebx
	.endif

	;Channel B, DAC_CR
	.if wavedata.waveCHBdata.enable
		xor		ebx,ebx
		;Enable DAC. DAC_CR:EN
		or		ebx,00000001h
		;Buffered disable. DAC_CR:BOFF
		mov		eax,wavedata.waveCHBdata.buffered
		.if !eax
			or		ebx,00000002h
		.endif
		;Enable trigger. DAC_CR:TEN
		or		ebx,00000004h
		;Trigger select. DAC_CR:TSEL, Timer 7 = 010
		or		ebx,00000010h
		;DAC wave. DAC_CR:WAVE. 00=Disabled, 01=Noise,10=Triangle 
		mov		eax,wavedata.waveCHBdata.mode
		.if eax==WAVE_ModeNoise
			or		ebx,00000040h
			;DAC Amplitude / Mask. DAC_CR:MAMP
			mov		eax,wavedata.waveCHBdata.noiseamplitude
			shl		eax,8
			or		ebx,eax
		.elseif eax==WAVE_ModeTriangle
			or		ebx,00000080h
			;DAC Amplitude / Mask. DAC_CR:MAMP
			mov		eax,wavedata.waveCHBdata.triangleamplitude
			shl		eax,8
			or		ebx,eax
		.elseif eax==WAVE_ModeSquare
			or		ebx,00000080h
			;DAC Amplitude / Mask. DAC_CR:MAMP
			mov		eax,1
			shl		eax,8
			or		ebx,eax
		.elseif eax==WAVE_ModeSinwave
			;DAC DMA. DAC_CR:DMAEN
			or		ebx,00001000h
		.elseif eax==WAVE_ModeWaveFile
			;DAC DMA. DAC_CR:DMAEN
			or		ebx,00001000h
		.endif
		shl		ebx,16
		or		daccr,ebx
	.endif
	mov		edi,offset rwdata.RW_CommandStruct
	;DAC_CR
	mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteFullWord
	mov		[edi].RWDATA.RW_CommandStruct.Address,40007400h
	mov		eax,daccr
	mov		[edi].RWDATA.RW_CommandStruct.dFullWord,eax
	lea		edi,[edi+sizeof STM32_CommandStructDef]
	;Set end of sequence
	mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeNone
	ret

SetDAC_CR endp

SetWave proc uses ebx esi edi
	LOCAL	fwavefile:DWORD

	.if wavedata.waveCHAdata.enable || wavedata.waveCHBdata.enable
		mov		fwavefile,0
		invoke SetDAC_CR
		;Cannel A, DMA and TIM6
		.if wavedata.waveCHAdata.enable
			mov		eax,wavedata.waveCHAdata.mode
			.if eax==WAVE_ModeNoise || eax==WAVE_ModeTriangle || eax==WAVE_ModeSquare
				;Setup DMA channel 3. DMA Base 40020000h
				;DMA_IFCR (Address offset: 0x04)=40020004h
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteFullWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,40020004h
				mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,0FFFFFFFh
				lea		edi,[edi+sizeof STM32_CommandStructDef]
				;DMA_CCR3 (Address offset: 0x08 + 0d20 × (channel number – 1))=40020030h
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,40020030h
				mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,00000000h ;(0011 0101 1011 0000)
				lea		edi,[edi+sizeof STM32_CommandStructDef]
				;DAC DC Offset. DAC_DHR12R1
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteFullWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,40007408h
				.if eax==WAVE_ModeNoise
					mov		eax,wavedata.waveCHAdata.noisedcoffset
				.elseif eax==WAVE_ModeTriangle
					mov		eax,wavedata.waveCHAdata.triangledcoffset
				.elseif eax==WAVE_ModeSquare
					mov		eax,4095
				.endif
				mov		[edi].RWDATA.RW_CommandStruct.dFullWord,eax
				lea		edi,[edi+sizeof STM32_CommandStructDef]
			.elseif eax==WAVE_ModeSinwave ||  eax==WAVE_ModeWaveFile
				;Upload wave data
				mov		fwavefile,TRUE
				mov		eax,wavedata.waveCHAdata.wavecount
				invoke STLinkWrite,hWnd,STM32DACWaveCHA,addr wavedata.waveCHAdata.wavebuff,addr [eax*2]
				;Setup DMA channel 3. DMA Base 40020000h
				;DMA_IFCR (Address offset: 0x04)=40020004h
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteFullWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,40020004h
				mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,0FFFFFFFh
				lea		edi,[edi+sizeof STM32_CommandStructDef]
				;DMA_CCR3 (Address offset: 0x08 + 0d20 × (channel number – 1))=40020030h
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,40020030h
				mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,05B0h ;(0000 0101 1011 0000)
				lea		edi,[edi+sizeof STM32_CommandStructDef]
				;DMA_CNDTR3 (Address offset: 0x0C + 0d20 × (channel number – 1))=40020034h
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,40020034h
				mov		eax,wavedata.waveCHAdata.wavecount
				mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,ax
				lea		edi,[edi+sizeof STM32_CommandStructDef]
				;DMA_CPAR3 (Address offset: 0x10 + 0d20 × (channel number – 1))=40020038h
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteFullWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,40020038h
				mov		[edi].RWDATA.RW_CommandStruct.dFullWord,40007408h	;DAC_DHR12R1
				lea		edi,[edi+sizeof STM32_CommandStructDef]
				;DMA_CMAR3 (Address offset: 0x14 + 0d20 × (channel number – 1))=4002003Ch
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteFullWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,4002003Ch
				mov		[edi].RWDATA.RW_CommandStruct.dFullWord,STM32DACWaveCHA
				lea		edi,[edi+sizeof STM32_CommandStructDef]
				;DMA_CCR3 (Address offset: 0x08 + 0d20 × (channel number – 1))=40020030h
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,40020030h
				mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,35B1h ;(0011 0101 1011 0001)
				lea		edi,[edi+sizeof STM32_CommandStructDef]
			.endif
			;FrequencyA. TIM6_ARR 4000102Ch
			mov		eax,wavedata.waveCHAdata.mode
			mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteFullWord
			mov		[edi].RWDATA.RW_CommandStruct.Address,4000102Ch
			mov		edx,WAVEFRQMAX+1
			.if eax==WAVE_ModeNoise
				sub		edx,wavedata.waveCHAdata.noisefrequency
			.elseif eax==WAVE_ModeTriangle
				sub		edx,wavedata.waveCHAdata.trianglefrequency
			.elseif eax==WAVE_ModeSquare
				sub		edx,wavedata.waveCHAdata.squarefrequency
			.elseif eax==WAVE_ModeSinwave
				sub		edx,wavedata.waveCHAdata.sinfrequency
				add		edx,8
			.elseif eax==WAVE_ModeWaveFile
				sub		edx,wavedata.waveCHAdata.filefrequency
				add		edx,8
			.endif
			.if edx>65535
				mov		edx,65535
			.endif
			mov		[edi].RWDATA.RW_CommandStruct.dFullWord,edx
			lea		edi,[edi+sizeof STM32_CommandStructDef]
		.endif
	
	
		;Channel B, DMA and TIM7
		.if wavedata.waveCHBdata.enable
			mov		eax,wavedata.waveCHBdata.mode
			.if eax==WAVE_ModeNoise || eax==WAVE_ModeTriangle || eax==WAVE_ModeSquare
				;DAC DC Offset DAC_DHR12R2
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteFullWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,40007414h
				.if eax==WAVE_ModeNoise
					mov		eax,wavedata.waveCHBdata.noisedcoffset
				.elseif eax==WAVE_ModeTriangle
					mov		eax,wavedata.waveCHBdata.triangledcoffset
				.elseif eax==WAVE_ModeSquare
					mov		eax,4094
				.endif
				mov		[edi].RWDATA.RW_CommandStruct.dFullWord,eax
				lea		edi,[edi+sizeof STM32_CommandStructDef]
			.elseif eax==WAVE_ModeSinwave || eax==WAVE_ModeWaveFile
				;Upload wave data
				mov		fwavefile,TRUE
				mov		eax,wavedata.waveCHBdata.wavecount
				invoke STLinkWrite,hWnd,STM32DACWaveCHB,addr wavedata.waveCHBdata.wavebuff,addr [eax*2]
				;Setup DMA channel 4
				;DMA_IFCR (Address offset: 0x04)=40020004h
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteFullWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,40020004h
				mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,0FFFFFFFh
				lea		edi,[edi+sizeof STM32_CommandStructDef]
				;DMA_CCR4 (Address offset: 0x08 + 0d20 × (channel number – 1))=40020044h
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,40020044h
				mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,05B0h ;(0000 0101 1011 0000)
				lea		edi,[edi+sizeof STM32_CommandStructDef]
				;DMA_CNDTR4 (Address offset: 0x0C + 0d20 × (channel number – 1))=40020048h
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,40020048h
				mov		eax,wavedata.waveCHBdata.wavecount
				mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,ax
				lea		edi,[edi+sizeof STM32_CommandStructDef]
				;DMA_CPAR4 (Address offset: 0x10 + 0d20 × (channel number – 1))=4002004Ch
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteFullWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,4002004Ch
				mov		[edi].RWDATA.RW_CommandStruct.dFullWord,40007414h	;DAC_DHR12R2
				lea		edi,[edi+sizeof STM32_CommandStructDef]
				;DMA_CMAR4 (Address offset: 0x14 + 0d20 × (channel number – 1))=40020050h
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteFullWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,40020050h
				mov		[edi].RWDATA.RW_CommandStruct.dFullWord,STM32DACWaveCHB
				lea		edi,[edi+sizeof STM32_CommandStructDef]
				;DMA_CCR4 (Address offset: 0x08 + 0d20 × (channel number – 1))=40020044h
				mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteHalfWord
				mov		[edi].RWDATA.RW_CommandStruct.Address,40020044h
				mov		[edi].RWDATA.RW_CommandStruct.dHalfWord,35B1h ;(0011 0101 1011 0001)
				lea		edi,[edi+sizeof STM32_CommandStructDef]
			.endif
			;FrequencyB. TIM7_ARR 4000142Ch
			mov		eax,wavedata.waveCHBdata.mode
			mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeWriteFullWord
			mov		[edi].RWDATA.RW_CommandStruct.Address,4000142Ch
			mov		edx,WAVEFRQMAX+1
			.if eax==WAVE_ModeNoise
				sub		edx,wavedata.waveCHBdata.noisefrequency
			.elseif eax==WAVE_ModeTriangle
				sub		edx,wavedata.waveCHBdata.trianglefrequency
			.elseif eax==WAVE_ModeSquare
				sub		edx,wavedata.waveCHBdata.squarefrequency
			.elseif eax==WAVE_ModeSinwave
				sub		edx,wavedata.waveCHBdata.sinfrequency
				add		edx,8
			.elseif eax==WAVE_ModeWaveFile
				sub		edx,wavedata.waveCHBdata.filefrequency
				add		edx,8
			.endif
			.if edx>65535
				mov		edx,65535
			.endif
			mov		[edi].RWDATA.RW_CommandStruct.dFullWord,edx
			lea		edi,[edi+sizeof STM32_CommandStructDef]
		.endif
		;Set end of sequence
		mov		[edi].RWDATA.RW_CommandStruct.STM32_Mode,STM32_ModeNone
		mov		fWave,TRUE
		mov		eax,fwavefile
		mov		fWaveFile,eax
	.endif
	ret

SetWave endp

Random proc uses ecx edx,range:DWORD

	mov		eax,rseed
	mov		ecx,23
	mul		ecx
	add		eax,7
	and		eax,0FFFFFFFFh
	ror		eax,1
	xor		eax,rseed
	mov		rseed,eax
	mov		ecx,range
	xor		edx,edx
	div		ecx
	mov		eax,edx
	ret

Random endp

MakeNoise proc uses ebx esi edi,lpWave:DWORD,Amplitude:DWORD,DCOffset:DWORD

	xor		ecx,ecx
	mov		edi,lpWave
	.while ecx<1024
		invoke Random,Amplitude
		add		eax,DCOffset
		and		eax,0FFFh
		xor		edx,edx
		.while edx<8
			mov		[edi+edx*WORD],ax
			inc		edx
		.endw
		lea		edi,[edi+edx*WORD]
		inc		ecx
	.endw
	mov		eax,edi
	sub		eax,lpWave
	shr		eax,1
	ret

MakeNoise endp

MakeTriangle proc uses ebx esi edi,lpWave:DWORD,Amplitude:DWORD,DCOffset:DWORD

	;Make 2 waves
	mov		ecx,2
	mov		edi,lpWave
	.while ecx
		mov		eax,Amplitude
		shr		eax,1
		.while eax<Amplitude
			push	eax
			add		eax,DCOffset
			and		eax,0FFFh
			mov		[edi],ax
			lea		edi,[edi+WORD]
			pop		eax
			inc		eax
		.endw
		.while eax
			dec		eax
			push	eax
			add		eax,DCOffset
			and		eax,0FFFh
			mov		[edi],ax
			lea		edi,[edi+WORD]
			pop		eax
		.endw
		mov		edx,Amplitude
		shr		edx,1
		.while eax<edx
			push	eax
			add		eax,DCOffset
			and		eax,0FFFh
			mov		[edi],ax
			lea		edi,[edi+WORD]
			pop		eax
			inc		eax
		.endw
		dec		ecx
	.endw
	mov		eax,edi
	sub		eax,lpWave
	shr		eax,1
	ret

MakeTriangle endp

MakeSquare proc uses ebx esi edi,lpWaveIn:DWORD,lpWaveOut:DWORD,nCount:DWORD

	mov		eax,nCount
	shl		eax,1
	invoke RtlMoveMemory,lpWaveOut,lpWaveIn,eax
	mov		eax,nCount
	ret

MakeSquare endp

MakeWave proc uses ebx esi edi,lpWave:DWORD,nCount:DWORD,Amplitude:DWORD,DCOffset:DWORD

	mov		edi,lpWave
	xor		ebx,ebx
	.while ebx<nCount
		movzx	eax,word ptr [edi+ebx*WORD]
		mov		ecx,Amplitude
		mul		ecx
		mov		ecx,11
		div		ecx
		add		eax,DCOffset
		.if eax>4095
			mov		eax,4095
		.endif
		mov		[edi+ebx*WORD],ax
		inc		ebx
	.endw
	ret

MakeWave endp

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

LoadWaveFile proc uses ebx esi edi,lpFileName:DWORD,lpWave:DWORD
	LOCAL	hFile:HANDLE
	LOCAL	hMem:HGLOBAL
	LOCAL	rdbytes:DWORD

	xor		ebx,ebx
	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		push	eax
		shr		eax,4
		inc		eax
		shl		eax,4
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
		mov		hMem,eax
		pop		edx
		invoke ReadFile,hFile,hMem,edx,addr rdbytes,NULL
		mov		edi,lpWave
		mov		esi,hMem
		.while byte ptr [esi]
			invoke DecToBin,esi
			.if eax>4095
				mov		eax,4095
			.endif
			mov		[edi+ebx*WORD],ax
			.while byte ptr [esi]
				.if byte ptr [esi]==0Ah
					inc		esi
					.break
				.endif
				inc		esi
			.endw
			inc		ebx
		.endw
		invoke CloseHandle,hFile
		invoke GlobalFree,hMem
	.endif
	mov		eax,ebx
	ret

LoadWaveFile endp

WaveInit proc

	;Setup wavedata channel A
	mov		wavedata.waveCHAdata.xmag,XMAGMAX/16
	mov		wavedata.waveCHAdata.ymag,YMAGMAX/16
	mov		wavedata.waveCHAdata.mode,WAVE_ModeTriangle
	mov		wavedata.waveCHAdata.buffered,TRUE
	mov		wavedata.waveCHAdata.noiseamplitude,11
	mov		wavedata.waveCHAdata.noisedcoffset,0
	mov		wavedata.waveCHAdata.noisefrequency,WAVEFRQMAX
	mov		wavedata.waveCHAdata.triangleamplitude,11
	mov		wavedata.waveCHAdata.triangledcoffset,0
	mov		wavedata.waveCHAdata.trianglefrequency,WAVEFRQMAX
	mov		wavedata.waveCHAdata.squareamplitude,11
	mov		wavedata.waveCHAdata.squaredcoffset,0
	mov		wavedata.waveCHAdata.squarefrequency,WAVEFRQMAX
	mov		wavedata.waveCHAdata.sinamplitude,11
	mov		wavedata.waveCHAdata.sindcoffset,0
	mov		wavedata.waveCHAdata.sinfrequency,WAVEFRQMAX
	mov		wavedata.waveCHAdata.fileamplitude,11
	mov		wavedata.waveCHAdata.filedcoffset,0
	mov		wavedata.waveCHAdata.filefrequency,WAVEFRQMAX
	invoke lstrcpy,addr wavedata.waveCHAdata.file,addr WAVE_File
	mov		ecx,11
	sub		ecx,wavedata.waveCHAdata.triangleamplitude
	mov		eax,4095
	shr		eax,cl
	invoke MakeTriangle,addr wavedata.waveCHAdata.wavebuff,eax,wavedata.waveCHAdata.triangledcoffset
	mov		wavedata.waveCHAdata.wavecount,eax
	;Setup wavedata channel B
	mov		wavedata.waveCHBdata.xmag,XMAGMAX/16
	mov		wavedata.waveCHBdata.ymag,YMAGMAX/16
	mov		wavedata.waveCHBdata.mode,WAVE_ModeTriangle
	mov		wavedata.waveCHBdata.buffered,TRUE
	mov		wavedata.waveCHBdata.noiseamplitude,11
	mov		wavedata.waveCHBdata.noisedcoffset,0
	mov		wavedata.waveCHBdata.noisefrequency,WAVEFRQMAX
	mov		wavedata.waveCHBdata.triangleamplitude,11
	mov		wavedata.waveCHBdata.triangledcoffset,0
	mov		wavedata.waveCHBdata.trianglefrequency,WAVEFRQMAX
	mov		wavedata.waveCHBdata.squareamplitude,11
	mov		wavedata.waveCHBdata.squaredcoffset,0
	mov		wavedata.waveCHBdata.squarefrequency,WAVEFRQMAX
	mov		wavedata.waveCHBdata.sinamplitude,11
	mov		wavedata.waveCHBdata.sindcoffset,0
	mov		wavedata.waveCHBdata.sinfrequency,WAVEFRQMAX
	mov		wavedata.waveCHBdata.fileamplitude,11
	mov		wavedata.waveCHBdata.filedcoffset,0
	mov		wavedata.waveCHBdata.filefrequency,WAVEFRQMAX
	invoke lstrcpy,addr wavedata.waveCHBdata.file,addr WAVE_File
	mov		ecx,11
	sub		ecx,wavedata.waveCHBdata.triangleamplitude
	mov		eax,4095
	shr		eax,cl
	invoke MakeTriangle,addr wavedata.waveCHBdata.wavebuff,eax,wavedata.waveCHBdata.triangledcoffset
	mov		wavedata.waveCHBdata.wavecount,eax
	ret

WaveInit endp

BrowseFile proc uses ebx esi edi,hWin:HWND,lpFile:DWORD
	LOCAL	ofn:OPENFILENAME

	;Zero out the ofn struct
	invoke RtlZeroMemory,addr ofn,sizeof ofn
	;Setup the ofn struct
	mov		ofn.lStructSize,sizeof ofn
	mov		eax,hWin
	mov		ofn.hwndOwner,eax
	mov		eax,hInstance
	mov		ofn.hInstance,eax
	mov		ofn.lpstrFilter,offset szDacFilterString
	mov		eax,lpFile
	mov		ofn.lpstrFile,eax
	mov		ofn.nMaxFile,MAX_PATH
	mov		ofn.lpstrDefExt,NULL
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	;Show the Open dialog
	invoke GetOpenFileName,addr ofn
	ret

BrowseFile endp

WaveSetupProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		;Channel A
		mov		eax,BST_UNCHECKED
		.if wavedata.waveCHAdata.enable
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKWAVEAENABLE,eax
		mov		ebx,wavedata.waveCHAdata.mode
		invoke CheckRadioButton,hWin,IDC_RBNWAVEANOISE,IDC_RBNWAVEAFILE,addr [ebx+IDC_RBNWAVEANOISE]
		mov		eax,BST_UNCHECKED
		.if wavedata.waveCHAdata.buffered
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKWAVEABUFFERED,eax
		invoke SetDlgItemText,hWin,IDC_EDTWAVEAFILE,offset wavedata.waveCHAdata.file
		;Channel B
		mov		eax,BST_UNCHECKED
		.if wavedata.waveCHBdata.enable
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKWAVEBENABLE,eax
		mov		ebx,wavedata.waveCHBdata.mode
		invoke CheckRadioButton,hWin,IDC_RBNWAVEBNOISE,IDC_RBNWAVEBFILE,addr [ebx+IDC_RBNWAVEBNOISE]
		mov		eax,BST_UNCHECKED
		.if wavedata.waveCHBdata.buffered
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKWAVEBBUFFERED,eax
		call	SetWaveType
		invoke SetDlgItemText,hWin,IDC_EDTWAVEBFILE,offset wavedata.waveCHBdata.file
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,0,1
			.elseif eax==IDC_CHKWAVEAENABLE
				invoke IsDlgButtonChecked,hWin,IDC_CHKWAVEAENABLE
				.if !eax
					;Turn off CHA
					mov		wavedata.waveCHAdata.enable,0
					invoke SetDAC_CR
					mov		fWave,TRUE
				.else
					call	Update
				.endif
			.elseif eax==IDC_CHKWAVEBENABLE
				invoke IsDlgButtonChecked,hWin,IDC_CHKWAVEBENABLE
				.if !eax
					;Turn off CHB
					mov		wavedata.waveCHBdata.enable,0
					mov		edi,offset rwdata.RW_CommandStruct
					invoke SetDAC_CR
					mov		fWave,TRUE
				.else
					call	Update
				.endif
			.elseif eax==IDC_BTNWAVEAFILE
				invoke BrowseFile,hWin,offset wavedata.waveCHAdata.file
				.if eax
					invoke SetDlgItemText,hWin,IDC_EDTWAVEAFILE,offset wavedata.waveCHAdata.file
					call	Update
				.endif
			.elseif eax==IDC_BTNWAVEBFILE
				invoke BrowseFile,hWin,offset wavedata.waveCHBdata.file
				.if eax
					invoke SetDlgItemText,hWin,IDC_EDTWAVEBFILE,offset wavedata.waveCHBdata.file
					call	Update
				.endif
			.elseif eax>=IDC_RBNWAVEANOISE && eax<=IDC_RBNWAVEAFILE || eax>=IDC_RBNWAVEBNOISE && eax<=IDC_RBNWAVEBFILE
				invoke IsDlgButtonChecked,hWin,IDC_RBNWAVEASQUARE
				xor		eax,1
				call	ShowHideCHA
				invoke IsDlgButtonChecked,hWin,IDC_RBNWAVEBSQUARE
				xor		eax,1
				call	ShowHideCHB
				call	SetWaveType
				call	Update
			.endif
		.endif
	.elseif eax==WM_HSCROLL
		call	Update
		call	SetWaveType
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
		mov		childdialogs.hWndWaveSetup,0
		invoke SetFocus,hWnd
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

ShowHideCHA:
	.if eax
		invoke GetDlgItem,hWin,IDC_STCWAVEAAMPLITUDE
		invoke ShowWindow,eax,SW_SHOWNA
		invoke GetDlgItem,hWin,IDC_TRBWAVEAAMPLITUDE
		invoke ShowWindow,eax,SW_SHOWNA
		invoke GetDlgItem,hWin,IDC_STCWAVEADC
		invoke ShowWindow,eax,SW_SHOWNA
		invoke GetDlgItem,hWin,IDC_TRBWAVEADC
		invoke ShowWindow,eax,SW_SHOWNA
	.else
		invoke GetDlgItem,hWin,IDC_STCWAVEAAMPLITUDE
		invoke ShowWindow,eax,SW_HIDE
		invoke GetDlgItem,hWin,IDC_TRBWAVEAAMPLITUDE
		invoke ShowWindow,eax,SW_HIDE
		invoke GetDlgItem,hWin,IDC_STCWAVEADC
		invoke ShowWindow,eax,SW_HIDE
		invoke GetDlgItem,hWin,IDC_TRBWAVEADC
		invoke ShowWindow,eax,SW_HIDE
	.endif
	retn

ShowHideCHB:
	.if eax
		invoke GetDlgItem,hWin,IDC_STCWAVEBAMPLITUDE
		invoke ShowWindow,eax,SW_SHOWNA
		invoke GetDlgItem,hWin,IDC_TRBWAVEBAMPLITUDE
		invoke ShowWindow,eax,SW_SHOWNA
		invoke GetDlgItem,hWin,IDC_STCWAVEBDC
		invoke ShowWindow,eax,SW_SHOWNA
		invoke GetDlgItem,hWin,IDC_TRBWAVEBDC
		invoke ShowWindow,eax,SW_SHOWNA
	.else
		invoke GetDlgItem,hWin,IDC_STCWAVEBAMPLITUDE
		invoke ShowWindow,eax,SW_HIDE
		invoke GetDlgItem,hWin,IDC_TRBWAVEBAMPLITUDE
		invoke ShowWindow,eax,SW_HIDE
		invoke GetDlgItem,hWin,IDC_STCWAVEBDC
		invoke ShowWindow,eax,SW_HIDE
		invoke GetDlgItem,hWin,IDC_TRBWAVEBDC
		invoke ShowWindow,eax,SW_HIDE
	.endif
	retn

SetWaveType:
	;Channel A
	xor		ebx,ebx
	.while ebx<5
		invoke IsDlgButtonChecked,hWin,addr [ebx+IDC_RBNWAVEANOISE]
		.break .if eax
		inc		ebx
	.endw
	mov		wavedata.waveCHAdata.mode,ebx
	invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYH,TBM_SETRANGE,FALSE,(255 SHL 16)+0
	invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYL,TBM_SETRANGE,FALSE,(255 SHL 16)+0
	.if ebx==WAVE_ModeNoise
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_SETRANGE,FALSE,(11 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_SETPOS,TRUE,wavedata.waveCHAdata.noiseamplitude
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_SETRANGE,FALSE,(4095 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_SETPOS,TRUE,wavedata.waveCHAdata.noisedcoffset
		mov		eax,wavedata.waveCHAdata.noisefrequency
		shr		eax,8
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYH,TBM_SETPOS,TRUE,eax
		mov		eax,wavedata.waveCHAdata.noisefrequency
		and		eax,0FFh
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYL,TBM_SETPOS,TRUE,eax
	.elseif ebx==WAVE_ModeTriangle
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_SETRANGE,FALSE,(11 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_SETPOS,TRUE,wavedata.waveCHAdata.triangleamplitude
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_SETRANGE,FALSE,(4095 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_SETPOS,TRUE,wavedata.waveCHAdata.triangledcoffset
		mov		eax,wavedata.waveCHAdata.trianglefrequency
		shr		eax,8
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYH,TBM_SETPOS,TRUE,eax
		mov		eax,wavedata.waveCHAdata.trianglefrequency
		and		eax,0FFh
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYL,TBM_SETPOS,TRUE,eax
	.elseif ebx==WAVE_ModeSquare
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_SETRANGE,FALSE,(11 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_SETPOS,TRUE,wavedata.waveCHAdata.squareamplitude
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_SETRANGE,FALSE,(4095 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_SETPOS,TRUE,wavedata.waveCHAdata.squaredcoffset
		mov		eax,wavedata.waveCHAdata.squarefrequency
		shr		eax,8
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYH,TBM_SETPOS,TRUE,eax
		mov		eax,wavedata.waveCHAdata.squarefrequency
		and		eax,0FFh
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYL,TBM_SETPOS,TRUE,eax
	.elseif ebx==WAVE_ModeSinwave
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_SETRANGE,FALSE,(11 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_SETPOS,TRUE,wavedata.waveCHAdata.sinamplitude
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_SETRANGE,FALSE,(4095 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_SETPOS,TRUE,wavedata.waveCHAdata.sindcoffset
		mov		eax,wavedata.waveCHAdata.sinfrequency
		shr		eax,8
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYH,TBM_SETPOS,TRUE,eax
		mov		eax,wavedata.waveCHAdata.sinfrequency
		and		eax,0FFh
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYL,TBM_SETPOS,TRUE,eax
	.elseif ebx==WAVE_ModeWaveFile
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_SETRANGE,FALSE,(11 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_SETPOS,TRUE,wavedata.waveCHAdata.fileamplitude
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_SETRANGE,FALSE,(4095 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_SETPOS,TRUE,wavedata.waveCHAdata.filedcoffset
		mov		eax,wavedata.waveCHAdata.filefrequency
		shr		eax,8
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYH,TBM_SETPOS,TRUE,eax
		mov		eax,wavedata.waveCHAdata.filefrequency
		and		eax,0FFh
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYL,TBM_SETPOS,TRUE,eax
	.endif
	;Channel B
	xor		ebx,ebx
	.while ebx<5
		invoke IsDlgButtonChecked,hWin,addr [ebx+IDC_RBNWAVEBNOISE]
		.break .if eax
		inc		ebx
	.endw
	mov		wavedata.waveCHBdata.mode,ebx
	invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYH,TBM_SETRANGE,FALSE,(255 SHL 16)+0
	invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYL,TBM_SETRANGE,FALSE,(255 SHL 16)+0
	.if ebx==WAVE_ModeNoise
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_SETRANGE,FALSE,(11 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_SETPOS,TRUE,wavedata.waveCHBdata.noiseamplitude
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_SETRANGE,FALSE,(4095 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_SETPOS,TRUE,wavedata.waveCHBdata.noisedcoffset
		mov		eax,wavedata.waveCHBdata.noisefrequency
		shr		eax,8
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYH,TBM_SETPOS,TRUE,eax
		mov		eax,wavedata.waveCHBdata.noisefrequency
		and		eax,0FFh
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYL,TBM_SETPOS,TRUE,eax
	.elseif ebx==WAVE_ModeTriangle
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_SETRANGE,FALSE,(11 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_SETPOS,TRUE,wavedata.waveCHBdata.triangleamplitude
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_SETRANGE,FALSE,(4095 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_SETPOS,TRUE,wavedata.waveCHBdata.triangledcoffset
		mov		eax,wavedata.waveCHBdata.trianglefrequency
		shr		eax,8
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYH,TBM_SETPOS,TRUE,eax
		mov		eax,wavedata.waveCHBdata.trianglefrequency
		and		eax,0FFh
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYL,TBM_SETPOS,TRUE,eax
	.elseif ebx==WAVE_ModeSquare
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_SETRANGE,FALSE,(11 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_SETPOS,TRUE,wavedata.waveCHBdata.squareamplitude
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_SETRANGE,FALSE,(4095 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_SETPOS,TRUE,wavedata.waveCHBdata.squaredcoffset
		mov		eax,wavedata.waveCHBdata.squarefrequency
		shr		eax,8
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYH,TBM_SETPOS,TRUE,eax
		mov		eax,wavedata.waveCHBdata.squarefrequency
		and		eax,0FFh
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYL,TBM_SETPOS,TRUE,eax
	.elseif ebx==WAVE_ModeSinwave
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_SETRANGE,FALSE,(11 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_SETPOS,TRUE,wavedata.waveCHBdata.sinamplitude
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_SETRANGE,FALSE,(4095 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_SETPOS,TRUE,wavedata.waveCHBdata.sindcoffset
		mov		eax,wavedata.waveCHBdata.sinfrequency
		shr		eax,8
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYH,TBM_SETPOS,TRUE,eax
		mov		eax,wavedata.waveCHBdata.sinfrequency
		and		eax,0FFh
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYL,TBM_SETPOS,TRUE,eax
	.elseif ebx==WAVE_ModeWaveFile
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_SETRANGE,FALSE,(11 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_SETPOS,TRUE,wavedata.waveCHBdata.fileamplitude
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_SETRANGE,FALSE,(4095 SHL 16)+0
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_SETPOS,TRUE,wavedata.waveCHBdata.filedcoffset
		mov		eax,wavedata.waveCHBdata.filefrequency
		shr		eax,8
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYH,TBM_SETPOS,TRUE,eax
		mov		eax,wavedata.waveCHBdata.filefrequency
		and		eax,0FFh
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYL,TBM_SETPOS,TRUE,eax
	.endif
	retn

Update:
	;Channel A
	invoke IsDlgButtonChecked,hWin,IDC_CHKWAVEAENABLE
	mov		wavedata.waveCHAdata.enable,eax
	xor		ebx,ebx
	.while ebx<5
		invoke IsDlgButtonChecked,hWin,addr [ebx+IDC_RBNWAVEANOISE]
		.break .if eax
		inc		ebx
	.endw
	mov		wavedata.waveCHAdata.mode,ebx
	invoke IsDlgButtonChecked,hWin,IDC_CHKWAVEABUFFERED
	mov		wavedata.waveCHAdata.buffered,eax
	.if ebx==WAVE_ModeNoise
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_GETPOS,0,0
		mov		wavedata.waveCHAdata.noiseamplitude,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_GETPOS,0,0
		mov		wavedata.waveCHAdata.noisedcoffset,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYH,TBM_GETPOS,0,0
		shl		eax,8
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYL,TBM_GETPOS,0,0
		or		eax,ebx
		mov		wavedata.waveCHAdata.noisefrequency,eax
		mov		ecx,11
		sub		ecx,wavedata.waveCHAdata.noiseamplitude
		mov		eax,4095
		shr		eax,cl
		invoke MakeNoise,addr wavedata.waveCHAdata.wavebuff,eax,wavedata.waveCHAdata.noisedcoffset
		mov		wavedata.waveCHAdata.wavecount,eax
	.elseif ebx==WAVE_ModeTriangle
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_GETPOS,0,0
		mov		wavedata.waveCHAdata.triangleamplitude,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_GETPOS,0,0
		mov		wavedata.waveCHAdata.triangledcoffset,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYH,TBM_GETPOS,0,0
		shl		eax,8
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYL,TBM_GETPOS,0,0
		or		eax,ebx
		mov		wavedata.waveCHAdata.trianglefrequency,eax
		mov		ecx,11
		sub		ecx,wavedata.waveCHAdata.triangleamplitude
		mov		eax,4095
		shr		eax,cl
		invoke MakeTriangle,addr wavedata.waveCHAdata.wavebuff,eax,wavedata.waveCHAdata.triangledcoffset
		mov		wavedata.waveCHAdata.wavecount,eax
	.elseif ebx==WAVE_ModeSquare
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_GETPOS,0,0
		mov		wavedata.waveCHAdata.squareamplitude,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_GETPOS,0,0
		mov		wavedata.waveCHAdata.squaredcoffset,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYH,TBM_GETPOS,0,0
		shl		eax,8
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYL,TBM_GETPOS,0,0
		or		eax,ebx
		mov		wavedata.waveCHAdata.squarefrequency,eax
		invoke MakeSquare,addr DAC_SquareWave,addr wavedata.waveCHAdata.wavebuff,33
		mov		wavedata.waveCHAdata.wavecount,eax
	.elseif ebx==WAVE_ModeSinwave
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_GETPOS,0,0
		mov		wavedata.waveCHAdata.sinamplitude,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_GETPOS,0,0
		mov		wavedata.waveCHAdata.sindcoffset,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYH,TBM_GETPOS,0,0
		shl		eax,8
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYL,TBM_GETPOS,0,0
		or		eax,ebx
		mov		wavedata.waveCHAdata.sinfrequency,eax
		mov		wavedata.waveCHAdata.wavecount,32
		invoke RtlMoveMemory,addr wavedata.waveCHAdata.wavebuff,addr DAC_SineWave,32*WORD
		invoke RtlMoveMemory,addr wavedata.waveCHAdata.wavebuff[32*WORD],addr DAC_SineWave,32*WORD
		invoke MakeWave,addr wavedata.waveCHAdata.wavebuff,32*WORD,wavedata.waveCHAdata.sinamplitude,wavedata.waveCHAdata.sindcoffset
	.elseif ebx==WAVE_ModeWaveFile
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAAMPLITUDE,TBM_GETPOS,0,0
		mov		wavedata.waveCHAdata.fileamplitude,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEADC,TBM_GETPOS,0,0
		mov		wavedata.waveCHAdata.filedcoffset,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYH,TBM_GETPOS,0,0
		shl		eax,8
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEAFREQUENCYL,TBM_GETPOS,0,0
		or		eax,ebx
		mov		wavedata.waveCHAdata.filefrequency,eax
		invoke LoadWaveFile,addr wavedata.waveCHAdata.file,addr wavedata.waveCHAdata.wavebuff
		invoke LoadWaveFile,addr wavedata.waveCHAdata.file,addr wavedata.waveCHAdata.wavebuff[eax*2]
		add		eax,eax
		mov		wavedata.waveCHAdata.wavecount,eax
		invoke MakeWave,addr wavedata.waveCHAdata.wavebuff,wavedata.waveCHAdata.wavecount,wavedata.waveCHAdata.fileamplitude,wavedata.waveCHAdata.filedcoffset
	.endif
	invoke GetDlgItemText,hWin,IDC_EDTWAVEAFILE,addr wavedata.waveCHAdata.file,sizeof WAVEDATA.waveCHAdata.file
	;Channel B
	invoke IsDlgButtonChecked,hWin,IDC_CHKWAVEBENABLE
	mov		wavedata.waveCHBdata.enable,eax
	xor		ebx,ebx
	.while ebx<5
		invoke IsDlgButtonChecked,hWin,addr [ebx+IDC_RBNWAVEBNOISE]
		.break .if eax
		inc		ebx
	.endw
	mov		wavedata.waveCHBdata.mode,ebx
	invoke IsDlgButtonChecked,hWin,IDC_CHKWAVEBBUFFERED
	mov		wavedata.waveCHBdata.buffered,eax
	.if ebx==WAVE_ModeNoise
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_GETPOS,0,0
		mov		wavedata.waveCHBdata.noiseamplitude,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_GETPOS,0,0
		mov		wavedata.waveCHBdata.noisedcoffset,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYH,TBM_GETPOS,0,0
		shl		eax,8
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYL,TBM_GETPOS,0,0
		or		eax,ebx
		mov		wavedata.waveCHBdata.noisefrequency,eax
		mov		ecx,11
		sub		ecx,wavedata.waveCHBdata.noiseamplitude
		mov		eax,4095
		shr		eax,cl
		invoke MakeNoise,addr wavedata.waveCHBdata.wavebuff,eax,wavedata.waveCHBdata.noisedcoffset
		mov		wavedata.waveCHBdata.wavecount,eax
	.elseif ebx==WAVE_ModeTriangle
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_GETPOS,0,0
		mov		wavedata.waveCHBdata.triangleamplitude,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_GETPOS,0,0
		mov		wavedata.waveCHBdata.triangledcoffset,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYH,TBM_GETPOS,0,0
		shl		eax,8
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYL,TBM_GETPOS,0,0
		or		eax,ebx
		mov		wavedata.waveCHBdata.trianglefrequency,eax
		mov		ecx,11
		sub		ecx,wavedata.waveCHBdata.triangleamplitude
		mov		eax,4095
		shr		eax,cl
		invoke MakeTriangle,addr wavedata.waveCHBdata.wavebuff,eax,wavedata.waveCHBdata.triangledcoffset
		mov		wavedata.waveCHBdata.wavecount,eax
	.elseif ebx==WAVE_ModeSquare
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_GETPOS,0,0
		mov		wavedata.waveCHBdata.squareamplitude,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_GETPOS,0,0
		mov		wavedata.waveCHBdata.squaredcoffset,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYH,TBM_GETPOS,0,0
		shl		eax,8
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYL,TBM_GETPOS,0,0
		or		eax,ebx
		mov		wavedata.waveCHBdata.squarefrequency,eax
		invoke MakeSquare,addr DAC_SquareWave,addr wavedata.waveCHBdata.wavebuff,33
		mov		wavedata.waveCHBdata.wavecount,eax
	.elseif ebx==WAVE_ModeSinwave
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_GETPOS,0,0
		mov		wavedata.waveCHBdata.sinamplitude,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_GETPOS,0,0
		mov		wavedata.waveCHBdata.sindcoffset,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYH,TBM_GETPOS,0,0
		shl		eax,8
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYL,TBM_GETPOS,0,0
		or		eax,ebx
		mov		wavedata.waveCHBdata.sinfrequency,eax
		mov		wavedata.waveCHBdata.wavecount,32
		invoke RtlMoveMemory,addr wavedata.waveCHBdata.wavebuff,addr DAC_SineWave,32*WORD
		invoke RtlMoveMemory,addr wavedata.waveCHBdata.wavebuff[32*WORD],addr DAC_SineWave,32*WORD
		invoke MakeWave,addr wavedata.waveCHBdata.wavebuff,32*WORD,wavedata.waveCHBdata.sinamplitude,wavedata.waveCHBdata.sindcoffset
	.elseif ebx==WAVE_ModeWaveFile
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBAMPLITUDE,TBM_GETPOS,0,0
		mov		wavedata.waveCHBdata.fileamplitude,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBDC,TBM_GETPOS,0,0
		mov		wavedata.waveCHBdata.filedcoffset,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYH,TBM_GETPOS,0,0
		shl		eax,8
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEBFREQUENCYL,TBM_GETPOS,0,0
		or		eax,ebx
		mov		wavedata.waveCHBdata.filefrequency,eax
		invoke LoadWaveFile,addr wavedata.waveCHBdata.file,addr wavedata.waveCHBdata.wavebuff
		invoke LoadWaveFile,addr wavedata.waveCHBdata.file,addr wavedata.waveCHBdata.wavebuff[eax*WORD]
		add		eax,eax
		mov		wavedata.waveCHBdata.wavecount,eax
		invoke MakeWave,addr wavedata.waveCHBdata.wavebuff,wavedata.waveCHBdata.wavecount,wavedata.waveCHBdata.fileamplitude,wavedata.waveCHBdata.filedcoffset
	.endif
	invoke GetDlgItemText,hWin,IDC_EDTWAVEBFILE,addr wavedata.waveCHBdata.file,sizeof WAVEDATA.waveCHBdata.file
	invoke SetWave
	invoke InvalidateRect,wavedata.waveCHAdata.hWndWave,NULL,TRUE
	invoke InvalidateRect,wavedata.waveCHBdata.hWndWave,NULL,TRUE
	retn

WaveSetupProc endp

;#########################################################################

WaveGeneratorProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	mDC:HDC
	LOCAL	pt:POINT
	LOCAL	xsinf:SCROLLINFO
	LOCAL	ysinf:SCROLLINFO
	LOCAL	samplesize:DWORD
	LOCAL	buffer[128]:BYTE
	LOCAL	buffer1[128]:BYTE

	mov		eax,uMsg
	.if eax==WM_CREATE
		xor		eax,eax
		mov		xsinf.cbSize,sizeof SCROLLINFO
		mov		xsinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_HORZ,addr xsinf
		mov		eax,xsinf.nMax
		inc		eax
		mov		xsinf.nPage,eax
		invoke SetScrollInfo,hWin,SB_HORZ,addr xsinf,TRUE
		mov		ysinf.cbSize,sizeof SCROLLINFO
		mov		ysinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_VERT,addr ysinf
		mov		eax,ysinf.nMax
		inc		eax
		mov		ysinf.nPage,eax
		invoke SetScrollInfo,hWin,SB_VERT,addr ysinf,TRUE
	.elseif eax==WM_PAINT
		invoke GetParent,hWin
		invoke GetWindowLong,eax,GWL_USERDATA
		mov		ebx,eax
		invoke GetClientRect,hWin,addr rect
		call	SetScrooll
		invoke BeginPaint,hWin,addr ps
		invoke CreateCompatibleDC,ps.hdc
		mov		mDC,eax
		invoke CreateCompatibleBitmap,ps.hdc,rect.right,rect.bottom
		invoke SelectObject,mDC,eax
		push	eax
		invoke GetStockObject,BLACK_BRUSH
		invoke FillRect,mDC,addr rect,eax
		invoke GetClientRect,hWin,addr rect
		sub		rect.bottom,TEXTHIGHT
		mov		eax,hWin
		.if eax==wavedata.waveCHAdata.hWndWave
			;Channel A
			mov		eax,00FF00h
		.else
			;Channel B
			mov		eax,0FFFF00h
		.endif
		invoke SetTextColor,mDC,eax
		invoke SetBkMode,mDC,TRANSPARENT
		mov		eax,[ebx].WAVECHDATA.mode
		.if eax==WAVE_ModeNoise
			mov		ecx,65537
			sub		ecx,[ebx].WAVECHDATA.noisefrequency
			mov		eax,STM32Clock
			cdq
			div		ecx
			push	eax
			mov		eax,4095
			mov		ecx,11
			sub		ecx,[ebx].WAVECHDATA.noiseamplitude
			shr		eax,cl
			mov		ecx,3000
			mul		ecx
			mov		ecx,4095
			div		ecx
			push	eax
			mov		eax,[ebx].WAVECHDATA.noisedcoffset
			mov		ecx,3000
			mul		ecx
			mov		ecx,4095
			div		ecx
			mov		edx,eax
			pop		ecx
			pop		eax
		.elseif eax==WAVE_ModeTriangle
			mov		eax,65537
			sub		eax,[ebx].WAVECHDATA.trianglefrequency
			mov		ecx,[ebx].WAVECHDATA.triangleamplitude
			add		ecx,2
			shl		eax,cl
			sub		ecx,14
			add		eax,ecx
			mov		ecx,eax
			dec		ecx
			mov		eax,STM32Clock
			cdq
			div		ecx
			push	eax
			mov		eax,4095
			mov		ecx,11
			sub		ecx,[ebx].WAVECHDATA.triangleamplitude
			shr		eax,cl
			mov		ecx,3000
			mul		ecx
			mov		ecx,4095
			div		ecx
			push	eax
			mov		eax,[ebx].WAVECHDATA.triangledcoffset
			mov		ecx,3000
			mul		ecx
			mov		ecx,4095
			div		ecx
			mov		edx,eax
			pop		ecx
			pop		eax
		.elseif eax==WAVE_ModeSquare
			mov		ecx,65537
			sub		ecx,[ebx].WAVECHDATA.squarefrequency
			shl		ecx,1
			mov		eax,STM32Clock
			cdq
			div		ecx
			mov		edx,0
			mov		ecx,3000
		.elseif eax==WAVE_ModeSinwave
			mov		ecx,65537
			sub		ecx,[ebx].WAVECHDATA.sinfrequency
			mov		eax,STM32Clock
			cdq
			add		ecx,8
			div		ecx
			cdq
			mov		ecx,[ebx].WAVECHDATA.wavecount
			div		ecx
			push	eax
			mov		eax,3000
			mov		ecx,[ebx].WAVECHDATA.sinamplitude
			mul		ecx
			mov		ecx,11
			div		ecx
			push	eax
			mov		eax,[ebx].WAVECHDATA.sindcoffset
			mov		ecx,3000
			mul		ecx
			mov		ecx,4095
			div		ecx
			mov		edx,eax
			pop		ecx
			pop		eax
		.elseif eax==WAVE_ModeWaveFile
			mov		ecx,65537
			sub		ecx,[ebx].WAVECHDATA.filefrequency
			mov		eax,STM32Clock
			cdq
			add		ecx,8
			div		ecx
			cdq
			mov		ecx,[ebx].WAVECHDATA.wavecount
			shr		ecx,1
			div		ecx
			push	eax
			mov		eax,3000
			mov		ecx,[ebx].WAVECHDATA.fileamplitude
			mul		ecx
			mov		ecx,11
			div		ecx
			push	eax
			mov		eax,[ebx].WAVECHDATA.filedcoffset
			mov		ecx,3000
			mul		ecx
			mov		ecx,4095
			div		ecx
			mov		edx,eax
			pop		ecx
			pop		eax
		.endif
		push	edx
		push	ecx
		invoke FormatFrequency,addr buffer,addr szFmtFrq,eax
		pop		eax
		invoke wsprintf,addr buffer1,addr szFmtScopeVpp,eax
		invoke lstrlen,addr buffer1
		mov		buffer1[eax+1],0
		mov		edx,dword ptr buffer1[eax-4]
		mov		dword ptr buffer1[eax-3],edx
		mov		buffer1[eax-4],'.'
		invoke lstrcat,addr buffer,addr buffer1
		pop		eax
		invoke wsprintf,addr buffer1,addr szFmtWaveDCOffset,eax
		invoke lstrlen,addr buffer1
		mov		buffer1[eax+1],0
		mov		edx,dword ptr buffer1[eax-4]
		mov		dword ptr buffer1[eax-3],edx
		mov		buffer1[eax-4],'.'
		invoke lstrcat,addr buffer,addr buffer1
		invoke lstrlen,addr buffer
		mov		edx,rect.bottom
		add		edx,8
		invoke TextOut,mDC,0,edx,addr buffer,eax
		;Draw horizontal lines
		invoke CreatePen,PS_SOLID,1,0303030h
		invoke SelectObject,mDC,eax
		push	eax
		mov		eax,rect.bottom
		mov		ecx,6
		xor		edx,edx
		div		ecx
		mov		edx,eax
		mov		edi,eax
		xor		ecx,ecx
		.while ecx<5
			push	ecx
			push	edx
			invoke MoveToEx,mDC,0,edi,NULL
			invoke LineTo,mDC,rect.right,edi
			pop		edx
			add		edi,edx
			pop		ecx
			inc		ecx
		.endw
		invoke MoveToEx,mDC,0,rect.bottom,NULL
		invoke LineTo,mDC,rect.right,rect.bottom
		;Draw vertical lines
		mov		eax,rect.right
		mov		ecx,10
		xor		edx,edx
		div		ecx
		mov		edx,eax
		mov		edi,eax
		xor		ecx,ecx
		.while ecx<9
			push	ecx
			push	edx
			invoke MoveToEx,mDC,edi,0,NULL
			invoke LineTo,mDC,edi,rect.bottom
			pop		edx
			add		edi,edx
			pop		ecx
			inc		ecx
		.endw
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		;Draw curve
		invoke CreateRectRgn,0,0,rect.right,rect.bottom
		push	eax
		invoke SelectClipRgn,mDC,eax
		pop		eax
		invoke DeleteObject,eax
		mov		eax,hWin
		.if eax==wavedata.waveCHAdata.hWndWave
			;Channel A
			mov		eax,008000h
		.else
			;Channel B
			mov		eax,0808000h
		.endif
		invoke CreatePen,PS_SOLID,2,eax
		invoke SelectObject,mDC,eax
		push	eax
		lea		esi,[ebx].WAVECHDATA.wavebuff
		xor		edi,edi
		call	GetPoint
		invoke MoveToEx,mDC,pt.x,pt.y,NULL
		.while edi<samplesize
			mov		edx,edi
			call	GetPoint
			.if sdword ptr pt.x>=0
				invoke LineTo,mDC,pt.x,pt.y
				mov		eax,pt.x
				.break .if sdword ptr eax>rect.right
			.else
				invoke MoveToEx,mDC,pt.x,pt.y,NULL
			.endif
			inc		edi
			inc		edi
		.endw
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		add		rect.bottom,TEXTHIGHT
		invoke SelectClipRgn,mDC,NULL
		invoke BitBlt,ps.hdc,0,0,rect.right,rect.bottom,mDC,0,0,SRCCOPY
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		invoke DeleteDC,mDC
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
	.elseif eax==WM_HSCROLL
		mov		xsinf.cbSize,sizeof SCROLLINFO
		mov		xsinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_HORZ,addr xsinf
		mov		eax,wParam
		movzx	eax,ax
		.if eax==SB_THUMBPOSITION
			mov		eax,xsinf.nTrackPos
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif  eax==SB_THUMBTRACK
			mov		eax,xsinf.nTrackPos
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif  eax==SB_LINELEFT
			mov		eax,xsinf.nPos
			sub		eax,10
			.if CARRY?
				xor		eax,eax
			.endif
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_LINERIGHT
			mov		eax,xsinf.nPos
			add		eax,10
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_PAGELEFT
			mov		eax,xsinf.nPos
			sub		eax,xsinf.nPage
			.if CARRY?
				xor		eax,eax
			.endif
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_PAGERIGHT
			mov		eax,xsinf.nPos
			add		eax,xsinf.nPage
			invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.elseif eax==WM_VSCROLL
		mov		ysinf.cbSize,sizeof SCROLLINFO
		mov		ysinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_VERT,addr ysinf
		mov		eax,wParam
		movzx	eax,ax
		.if eax==SB_THUMBPOSITION
			mov		eax,ysinf.nTrackPos
			invoke SetScrollPos,hWin,SB_VERT,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif  eax==SB_THUMBTRACK
			mov		eax,ysinf.nTrackPos
			invoke SetScrollPos,hWin,SB_VERT,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif  eax==SB_LINELEFT
			mov		eax,ysinf.nPos
			sub		eax,10
			.if CARRY?
				xor		eax,eax
			.endif
			invoke SetScrollPos,hWin,SB_VERT,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_LINERIGHT
			mov		eax,ysinf.nPos
			add		eax,10
			invoke SetScrollPos,hWin,SB_VERT,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_PAGELEFT
			mov		eax,ysinf.nPos
			sub		eax,ysinf.nPage
			.if CARRY?
				xor		eax,eax
			.endif
			invoke SetScrollPos,hWin,SB_VERT,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.elseif eax==SB_PAGERIGHT
			mov		eax,ysinf.nPos
			add		eax,ysinf.nPage
			invoke SetScrollPos,hWin,SB_VERT,eax,TRUE
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

SetScrooll:
	invoke GetParent,hWin
	invoke GetWindowLong,eax,GWL_USERDATA
	mov		ebx,eax
	mov		eax,[ebx].WAVECHDATA.wavecount
	add		eax,eax
	.if [ebx].WAVECHDATA.mode==WAVE_ModeSinwave
		add		eax,eax
	.endif
	mov		samplesize,eax
	invoke GetClientRect,hWin,addr rect
	sub		rect.bottom,TEXTHIGHT
	;Init horizontal scrollbar
	mov		xsinf.cbSize,sizeof SCROLLINFO
	mov		xsinf.fMask,SIF_ALL
	invoke GetScrollInfo,hWin,SB_HORZ,addr xsinf
	mov		xsinf.nMin,0
	mov		eax,samplesize
	mov		ecx,[ebx].WAVECHDATA.xmag
	.if ecx>XMAGMAX/16
		sub		ecx,XMAGMAX/16
		add		ecx,10
		mul		ecx
		mov		ecx,10
		div		ecx
	.elseif ecx<XMAGMAX/16
		push	ecx
		mov		ecx,10
		mul		ecx
		pop		ecx
		sub		ecx,XMAGMAX/16
		neg		ecx
		add		ecx,10
		div		ecx
	.endif
	mov		ecx,rect.right
	mul		ecx
	mov		ecx,samplesize
	div		ecx
	mov		xsinf.nMax,eax
	mov		eax,rect.right
	inc		eax
	mov		xsinf.nPage,eax
	invoke SetScrollInfo,hWin,SB_HORZ,addr xsinf,TRUE
	;Init vertical scrollbar
	mov		ysinf.cbSize,sizeof SCROLLINFO
	mov		ysinf.fMask,SIF_ALL
	invoke GetScrollInfo,hWin,SB_VERT,addr ysinf
	mov		ysinf.nMin,0
	mov		eax,DACMAX/16
	mov		ecx,[ebx].WAVECHDATA.ymag
	.if ecx>YMAGMAX/16
		sub		ecx,YMAGMAX/16
		add		ecx,10
		mul		ecx
		mov		ecx,10
		div		ecx
	.elseif ecx<YMAGMAX/16
		push	ecx
		mov		ecx,10
		mul		ecx
		pop		ecx
		sub		ecx,YMAGMAX/16
		neg		ecx
		add		ecx,10
		div		ecx
	.endif
	mov		ecx,rect.bottom
	mul		ecx
	mov		ecx,ADCMAX
	div		ecx
	mov		ysinf.nMax,eax
	mov		eax,rect.bottom
	inc		eax
	mov		ysinf.nPage,eax
	invoke SetScrollInfo,hWin,SB_VERT,addr ysinf,TRUE
	add		rect.bottom,TEXTHIGHT
	retn

GetPoint:
	;Get X position
	mov		eax,edi
	mov		ecx,[ebx].WAVECHDATA.xmag
	.if ecx>XMAGMAX/16
		sub		ecx,XMAGMAX/16
		add		ecx,10
		mul		ecx
		mov		ecx,10
		div		ecx
	.elseif ecx<XMAGMAX/16
		push	ecx
		mov		ecx,10
		mul		ecx
		pop		ecx
		sub		ecx,XMAGMAX/16
		neg		ecx
		add		ecx,10
		div		ecx
	.endif
	mov		ecx,rect.right
	mul		ecx
	mov		ecx,samplesize
	div		ecx
	sub		eax,xsinf.nPos
	mov		pt.x,eax
	;Get y position
	mov		edx,edi
	movzx	eax,word ptr [esi+edx]
	sub		eax,DACMAX
	neg		eax
	mov		ecx,[ebx].WAVECHDATA.ymag
	.if ecx>YMAGMAX/16
		sub		ecx,YMAGMAX/16
		add		ecx,10
		mul		ecx
		mov		ecx,10
		div		ecx
	.elseif ecx<YMAGMAX/16
		push	ecx
		mov		ecx,10
		mul		ecx
		pop		ecx
		sub		ecx,YMAGMAX/16
		neg		ecx
		add		ecx,10
		div		ecx
	.endif
	mov		ecx,rect.bottom
	sub		ecx,10
	mul		ecx
	mov		ecx,DACMAX
	div		ecx
	sub		eax,ysinf.nPos
	add		eax,5
	mov		pt.y,eax
	retn

WaveGeneratorProc endp

WaveToolChildProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEXMAG,TBM_SETRANGE,FALSE,(XMAGMAX SHL 16)+1
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEXMAG,TBM_SETPOS,TRUE,XMAGMAX/16
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEYMAG,TBM_SETRANGE,FALSE,(YMAGMAX SHL 16)+1
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEYMAG,TBM_SETPOS,TRUE,YMAGMAX/16
	.elseif eax==WM_HSCROLL
		;X-Magnification
		invoke GetParent,hWin
		invoke GetWindowLong,eax,GWL_USERDATA
		mov		ebx,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEXMAG,TBM_GETPOS,0,0
		mov		[ebx].WAVECHDATA.xmag,eax
		invoke SendDlgItemMessage,hWin,IDC_TRBWAVEYMAG,TBM_GETPOS,0,0
		mov		[ebx].WAVECHDATA.ymag,eax
		invoke InvalidateRect,[ebx].WAVECHDATA.hWndWave,NULL,TRUE
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

WaveToolChildProc endp

WaveGeneratorChildProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		ebx,lParam
		invoke SetWindowLong,hWin,GWL_USERDATA,ebx
		mov		eax,hWin
		mov		[ebx].WAVECHDATA.hWndDialog,eax
		invoke GetDlgItem,hWin,IDC_UDCWAVEGENERATOR
		mov		[ebx].WAVECHDATA.hWndWave,eax
		invoke CreateDialogParam,hInstance,IDD_DLGWAVETOOL,hWin,addr WaveToolChildProc,0
		mov		[ebx].WAVECHDATA.hWndWaveTool,eax
	.elseif	eax==WM_SIZE
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		ebx,eax
		invoke GetClientRect,hWin,addr rect
		sub		rect.right,135
		sub		rect.bottom,2
		invoke MoveWindow,[ebx].WAVECHDATA.hWndWave,0,0,rect.right,rect.bottom,TRUE
		invoke MoveWindow,[ebx].WAVECHDATA.hWndWaveTool,rect.right,0,135,rect.bottom,TRUE
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

WaveGeneratorChildProc endp
