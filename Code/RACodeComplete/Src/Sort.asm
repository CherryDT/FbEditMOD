;Recursive Quicksort by bitRAKE

;
;;Initial State: (general)
;;
;;   esi      ecx      edi
;;    |---n---|-|---n---|
;;             P
;;
;;My choice of Pivot:
;;
;;      esi             edi
;;    |-|-------n-------|
;;     P
;;
;;
;;Possible Results: (P = pivot index)
;;
;;      esi             edi
;;    |-|-------n-------|     all items are >= pivot
;;     P                      inc esi, partition new range
;;
;;        esi           edi
;;    |-|-|-----n-------|     one item =< pivot, rest >= pivot
;;       P                    inc esi, inc esi, partition new range
;;
;;  esi--n--edi esi--n--edi
;;    |---n---|-|---n---|     some items =< pivot, some items >= pivot
;;             P              partition range #1, partition range #1
;;
;;  esi           edi
;;    |------n------|-|-|     one item >= pivot, rest <= pivot
;;                   P        dec edi, partition new range
;;
;;  esi             edi
;;    |------n--------|-|     all items are <= pivot
;;                     P      dec edi, dec edi, partition new range
;;

.data?

fQDesc		dd ?
rseed		dd ?

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

QuickSort PROC uses esi edi ebx,qARRAY:DWORD,qLOW:DWORD,qHIGH:DWORD,fDesc:DWORD

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
		mov		eax,[ebx+edi*8]
		xchg	eax,[ebx+esi*8]
		mov		[ebx+edi*8],eax
		mov		eax,[ebx+edi*8+4]
		xchg	eax,[ebx+esi*8+4]
		mov		[ebx+edi*8+4],eax
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
	call	@CompareStr
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
	call	@CompareStr
	.if fQDesc
		neg		eax
	.endif
	cmp		eax,0
	pop		edi
	jle		@high
	mov		edx,[ebx+esi*8]
	mov		eax,[ebx+ebp*8]
	mov		[ebx+ebp*8],edx
	mov		[ebx+esi*8],eax
	mov		edx,[ebx+esi*8+4]
	mov		eax,[ebx+ebp*8+4]
	mov		[ebx+ebp*8+4],edx
	mov		[ebx+esi*8+4],eax
	jmp		@low
  @donel:
	dec		esi
	mov		edx,[ebx+ecx*8]
	mov		eax,[ebx+esi*8]
	mov		[ebx+esi*8],edx
	mov		[ebx+ecx*8],eax
	mov		edx,[ebx+ecx*8+4]
	mov		eax,[ebx+esi*8+4]
	mov		[ebx+esi*8+4],edx
	mov		[ebx+ecx*8+4],eax
	dec		esi 		; pivot is sorted
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

@CompareStr:
	;Get offsets to strings
	mov		edx,[ebx+edx*8]
	mov		edi,[ebx+ecx*8]
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
	movsx	eax,al
	retn

QuickSort ENDP
