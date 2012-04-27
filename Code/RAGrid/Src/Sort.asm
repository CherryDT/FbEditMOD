;Recursive Quicksort by bitRAKE

;
;;Initial State: (general)
;;
;;	 esi	  ecx	   edi
;;	  |---n---|-|---n---|
;;			   P
;;
;;My choice of Pivot:
;;
;;		esi				edi
;;	  |-|-------n-------|
;;	   P
;;
;;
;;Possible Results: (P = pivot index)
;;
;;		esi				edi
;;	  |-|-------n-------|	  all items are >= pivot
;;	   P					  inc esi, partition new range
;;
;;		  esi			edi
;;	  |-|-|-----n-------|	  one item =< pivot, rest >= pivot
;;		 P					  inc esi, inc esi, partition new range
;;
;;	esi--n--edi esi--n--edi
;;	  |---n---|-|---n---|	  some items =< pivot, some items >= pivot
;;			   P			  partition range #1, partition range #1
;;
;;	esi			  edi
;;	  |------n------|-|-|	  one item >= pivot, rest <= pivot
;;					 P		  dec edi, partition new range
;;
;;	esi				edi
;;	  |------n--------|-|	  all items are <= pivot
;;					   P	  dec edi, dec edi, partition new range
;;

.const

CombSort_Const	REAL4 1.3

.data?

lpQMem		dd ?
lpQStr		dd ?
fQDesc		dd ?
rseed		dd ?
hpar		dd ?
lpwndproc	dd ?
cis			COMPAREITEMSTRUCT <?>
lpcompare	dd ?

.code

Random proc uses edx,range:DWORD

	mov		eax,23
	mul		rseed
	add		eax,7
	ror		eax,1
	xor		eax,rseed
	mov		rseed,eax
	xor		edx,edx
	div		range
	mov		eax,edx
	ret

Random endp

@CompareLng:
	mov		eax,lpQMem
	;Get offsets to row data
	mov		edx,[ebx+edx*4]
	mov		edi,[ebx+ecx*4]
	;Get offsets to cell data
	mov		edx,[edx+eax]
	mov		edi,[edi+eax]
	mov		eax,lpQStr
	;Get cell data
	mov		edx,[edx+eax]
	mov		eax,[edi+eax]
	sub		eax,edx
	retn

@CompareStr:
	mov		eax,lpQMem
	;Get offsets to row data
	mov		edx,[ebx+edx*4]
	mov		edi,[ebx+ecx*4]
	;Get offsets to cell data
	mov		edx,[edx+eax]
	mov		edi,[edi+eax]
	mov		eax,lpQStr
	;Compare string
	;Get pointers to cell data
	lea		edx,[edx+eax]
	lea		edi,[edi+eax]
	jmp		@f
  @next:
	inc		edi
	inc		edx
  @@:
	mov		al,[edi]
	mov		ah,[edx]
	or		ax,ax
	je		@exitcmpstr
	cmp		al,'a'
	jb		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	cmp		ah,'a'
	jb		@f
	cmp		ah,'z'
	jg		@f
	and		ah,5Fh
  @@:
	sub		al,ah
	je		@next
  @exitcmpstr:
	cbw
	cwde
	retn

@CompareUsr:
	mov		cis.itemID1,ecx
	mov		cis.itemID2,edx
	;Get offsets to row data
	mov		edx,[ebx+edx*4]
	mov		edi,[ebx+ecx*4]
	;Get offsets to cell data
	mov		eax,lpQMem
	mov		edx,[edx+eax]
	mov		edi,[edi+eax]
	mov		eax,lpQStr
	;Compare user data
	lea		ecx,[edi+eax]
	mov		cis.itemData1,ecx
	lea		ecx,[edx+eax]
	mov		cis.itemData2,ecx
	push	offset cis
	push	cis.CtlID
	push	WM_COMPAREITEM
	push	hpar
	call	[lpwndproc]
	mov		ecx,cis.itemID1
	retn

QuickSort PROC uses esi edi ebx,qARRAY:DWORD,qLOW:DWORD,qHIGH:DWORD,lpMem:DWORD,lpStr:DWORD,fStr:DWORD,fDesc:DWORD

	.if !fStr
		;Compare dword
		mov		lpcompare,offset @CompareLng
	.elseif fStr==-1
		;Compare string
		mov		lpcompare,offset @CompareStr
	.else
		;Compare user data
		mov		lpcompare,offset @CompareUsr
	.endif
	mov		eax,lpMem
	mov		lpQMem,eax
	mov		eax,lpStr
	mov		lpQStr,eax
	mov		eax,fDesc
	mov		fQDesc,eax
	mov		ebx,qARRAY
	;Quicksort is slow on sorted arrays, so randomize it first.
	mov		esi,qLOW
	mov		edx,qHIGH
	shr		edx,2
	.while edx
		mov		edi,esi
		invoke Random,qHIGH
		mov		esi,eax
		mov		eax,[ebx+edi*4]
		xchg	eax,[ebx+esi*4]
		mov		[ebx+edi*4],eax
		dec		edx
	.endw
	mov		esi,qLOW
	mov		edi,qHIGH
	push	ebp
	call	PARTITION
	pop		ebp
	ret

PARTITION:
	push	esi
	push	edi
	mov		ebp,edi
	sub		edi,esi		; width of partition - 2
	jle		@exit		; must be >1 elements to sort
	mov		ecx,esi		; choose pivot
	inc		ebp			; counter first dec
  @low:
	inc		esi
	dec		edi
	js		@donel		; esi is out of range or part of upper partition
	mov		edx,esi
	push	edi
	call	[lpcompare]
	.if fQDesc
		neg		eax
	.endif
	cmp		eax,0
	pop		edi
	jge		@low
  @high:
	dec		ebp
	dec		edi
	js		@donel		; ebp is out of range or part of lower partition
	mov		edx,ebp
	push	edi
	call	[lpcompare]
	.if fQDesc
		neg		eax
	.endif
	cmp		eax,0
	pop		edi
	jle		@high
	mov		edx,[ebx+esi*4]
	mov		eax,[ebx+ebp*4]
	mov		[ebx+ebp*4],edx
	mov		[ebx+esi*4],eax
	jmp		@low
  @donel:
	dec		esi
	mov		edx,[ebx+ecx*4]
	mov		eax,[ebx+esi*4]
	mov		[ebx+esi*4],edx
	mov		[ebx+ecx*4],eax
	dec		esi			; pivot is sorted
	mov		edi,[esp]
	mov		[esp],esi
	mov		esi,ebp
	call	PARTITION
	pop		edi
	pop		esi
	jmp		PARTITION
  @exit:
	add		esp,8
	retn

QuickSort ENDP

CombSort PROC uses ebx esi edi,Arr:DWORD,count:DWORD,lpMem:DWORD,lpStr:DWORD,fStr:DWORD,fDesc:DWORD
	LOCAL	Gap:DWORD
	LOCAL	eFlag:DWORD

	.if !fStr
		;Compare dword
		mov		lpcompare,offset @CompareLng
	.elseif fStr==-1
		;Compare string
		mov		lpcompare,offset @CompareStr
	.else
		;Compare user data
		mov		lpcompare,offset @CompareUsr
	.endif
	mov		eax,lpMem
	mov		lpQMem,eax
	mov		eax,lpStr
	mov		lpQStr,eax
	mov		eax,fDesc
	mov		fQDesc,eax
	mov		eax,count
	mov		Gap,eax
	mov		ebx,Arr
	dec		count
  @Loop1:
	fild	Gap								; load integer memory operand to divide
	fdiv	CombSort_Const					; divide number by 1.3
	fistp	Gap								; store result back in integer memory operand
	dec		Gap
	jnz		@F
	mov		Gap,1
  @@:
	mov		eFlag,0
	mov		esi,count
	sub		esi,Gap
	xor		ecx,ecx							; low value index
  @Loop2:
	mov 	edx,ecx
	add 	edx,Gap							; high value index
	push	ecx
	push	edx
	call	[lpcompare]
	.if fQDesc
		neg		eax
	.endif
	pop		edx
	pop		ecx
	cmp		eax,0
	jle 	@F
	mov 	eax,[ebx+ecx*4]					; lower value
	mov 	edi,[ebx+edx*4]					; higher value
	mov 	[ebx+edx*4],eax
	mov 	[ebx+ecx*4],edi
	inc 	eFlag
  @@:
	inc 	ecx
	cmp 	ecx,esi
	jle 	@Loop2
	cmp 	eFlag,0
	jg		@Loop1
	cmp 	Gap,1
	jg		@Loop1
	ret

CombSort ENDP

