
.code

Load_Image proc lpFileName:DWORD
	LOCAL	hBmp:DWORD
	LOCAL	image:DWORD
	LOCAL	wbuffer[MAX_PATH]:WORD

	;Load the jpeg and convert it to a bitmap handle
	xor		eax,eax
	mov		hBmp,eax
	mov		image,eax
	invoke RtlZeroMemory,addr wbuffer,sizeof wbuffer
	invoke MultiByteToWideChar,CP_OEMCP,MB_PRECOMPOSED,lpFileName,-1,addr wbuffer,MAX_PATH
	mov		wbuffer[eax*2],0
	invoke GdipLoadImageFromFile,addr wbuffer,addr image
	.if !eax
		;Convert to bitmap handle
		invoke GdipCreateHBITMAPFromBitmap,image,addr hBmp,0
		invoke GdipDisposeImage,image
	.endif
	mov		eax,hBmp
	ret

Load_Image endp

LoadDib proc uses ebx esi edi,mapinx:DWORD,dibx:DWORD,diby:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	;Check if out of bounds
	mov		eax,dibx
	mov		edx,diby
	.if eax>map.nx || edx>map.ny
		mov		dibx,0FFh
		mov		diby,0FFh
	.endif
	;Check if tile is loaded
	xor		ebx,ebx
	mov		esi,offset bmpcache
	mov		edi,mapinx
	mov		ecx,dibx
	mov		edx,diby
	xor		eax,eax
	.while ebx<MAXBMP
		.if edi==[esi].BMP.mapinx && ecx==[esi].BMP.nx && edx==[esi].BMP.ny && [esi].BMP.hBmp
			;The tile is loaded
			mov		eax,[esi].BMP.hBmp
			.break
		.endif
		lea		esi,[esi+sizeof BMP]
		inc		ebx
	.endw
	.if !eax
		;The tile is not loaded
		invoke wsprintf,addr buffer,addr szFileName,addr szAppPath,mapinx,diby,dibx
		invoke GetFileAttributes,addr buffer
		.if eax==INVALID_HANDLE_VALUE
			invoke wsprintf,addr buffer,addr szFileName,addr szAppPath,mapinx,0FFh,0FFh
		.endif
		invoke Load_Image,addr buffer
		.if eax
			push	eax
			;Find free or unused tile
			xor		ebx,ebx
			xor		edi,edi
			mov		esi,offset bmpcache
			.while ebx<MAXBMP-1
				.if ![esi].BMP.inuse
					mov		edi,esi
					.break .if ![esi].BMP.hBmp
				.endif
				lea		esi,[esi+sizeof BMP]
				inc		ebx
			.endw
			.if edi
				;Found free or unused tile
				mov		esi,edi
			.endif
			.if [esi].BMP.hBmp
				;The tile has a bitmap, delete it
				invoke DeleteObject,[esi].BMP.hBmp
			.endif
			;Update the tile
			mov		eax,mapinx
			mov		[esi].BMP.mapinx,eax
			mov		eax,dibx
			mov		[esi].BMP.nx,eax
			mov		eax,diby
			mov		[esi].BMP.ny,eax
			mov		[esi].BMP.inuse,TRUE
			pop		eax
			mov		[esi].BMP.hBmp,eax
		.endif
	.endif
	ret

LoadDib endp

SetMapUsed proc uses ebx esi edi,topx:DWORD,topy:DWORD,zoomval:DWORD
	LOCAL	stx:DWORD
	LOCAL	enx:DWORD
	LOCAL	sty:DWORD
	LOCAL	eny:DWORD

	;Find and mark tiles that is still needed
	mov		eax,topx
	shr		eax,9
	mov		stx,eax
	mov		eax,map.mapwt
	imul	zoomval
	idiv	dd256
	add		eax,topx
	shr		eax,9
	mov		enx,eax	
	mov		eax,topy
	shr		eax,9
	mov		sty,eax
	mov		eax,map.mapht
	imul	zoomval
	idiv	dd256
	add		eax,topy
	shr		eax,9
	mov		eny,eax
	xor		ebx,ebx
	mov		esi,offset bmpcache
	.while ebx<MAXBMP
		mov		[esi].BMP.inuse,0
		.if [esi].BMP.hBmp
			mov		eax,[esi].BMP.mapinx
			mov		ecx,[esi].BMP.nx
			mov		edx,[esi].BMP.ny
			.if eax==map.mapinx && ecx>=stx && ecx<=enx && edx>=sty && edx<=eny
				;The tile is needed
				mov		[esi].BMP.inuse,TRUE
			.endif
		.endif
		lea		esi,[esi+sizeof BMP]
		inc		ebx
	.endw
	ret

SetMapUsed endp

ShowMap proc uses ebx esi edi,topx:DWORD,topy:DWORD,zoomval:DWORD
	LOCAL	dibx:DWORD
	LOCAL	ofsx:DWORD
	LOCAL	diby:DWORD
	LOCAL	mapx:DWORD
	LOCAL	mapy:DWORD
	LOCAL	buffer[256]:BYTE

	invoke SetMapUsed,topx,topy,zoomval
	;Find leftmost dibx and ofsx
	mov		eax,topx
	shr		eax,9
	mov		dibx,eax
	mov		eax,topx
	and		eax,511
	mov		ofsx,eax
	mov		mapx,0
	;Find topmost diby
	mov		eax,topy
	shr		eax,9
	mov		diby,eax
	mov		eax,topy
	and		eax,511
	imul	dd256
	idiv	zoomval
	neg		eax
	mov		mapy,eax
	call	DrawY
	ret

DrawY:
	.while TRUE
		call	DrawX
		mov		eax,512
		imul	dd256
		idiv	zoomval
		add		mapy,eax
		mov		eax,mapy
		.break .if sdword ptr eax>=map.mapht
		inc		diby
		mov		eax,diby
	.endw
	retn

DrawX:
	push	dibx
	push	mapx
	push	ofsx
	.while TRUE
		mov		esi,512
		sub		esi,ofsx
		mov		eax,esi
		imul	dd256
		idiv	zoomval
		mov		ebx,eax
		invoke LoadDib,map.mapinx,dibx,diby
		.if eax
			invoke SelectObject,map.tDC,eax
			push	eax
;			invoke wsprintf,addr buffer,addr szTile,diby,dibx
;			invoke TextOut,map.tDC,10,10,addr buffer,8
;			invoke MoveToEx,map.tDC,0,0,NULL
;			invoke LineTo,map.tDC,512,0
;			invoke MoveToEx,map.tDC,0,0,NULL
;			invoke LineTo,map.tDC,0,512
;			invoke MoveToEx,map.tDC,0,0,NULL
;			invoke LineTo,map.tDC,512,512
;			invoke MoveToEx,map.tDC,512,0,NULL
;			invoke LineTo,map.tDC,0,512
			mov		edi,512
			mov		eax,edi
			imul	dd256
			idiv	zoomval
			invoke StretchBlt,map.mDC,mapx,mapy,ebx,eax,map.tDC,ofsx,0,esi,edi,SRCCOPY
			pop		eax
			invoke SelectObject,map.tDC,eax
		.endif
		add		mapx,ebx
		mov		eax,mapx
		.break .if eax>=map.mapwt
		mov		ofsx,0
		inc		dibx
	.endw
	pop		ofsx
	pop		mapx
	pop		dibx
	retn

ShowMap endp

ShowPlace proc uses ebx esi edi,topx:DWORD,topy:DWORD,zoomval:DWORD
	LOCAL	x:DWORD
	LOCAL	y:DWORD

	.if zoomval
		invoke SetTextColor,map.mDC2,0
		mov		esi,offset map.place
		xor		ebx,ebx
		.while ebx<MAXPLACES
			.if [esi].PLACE.zoom
				.if ![esi].PLACE.ptmap.x && ![esi].PLACE.ptmap.y
					invoke GpsPosToMapPos,[esi].PLACE.iLon,[esi].PLACE.iLat,addr [esi].PLACE.ptmap.x,addr [esi].PLACE.ptmap.y
				.endif
				invoke MapPosToScrnPos,[esi].PLACE.ptmap.x,[esi].PLACE.ptmap.y,addr x,addr y
				mov		eax,x
				sub		eax,topx
				imul	dd256
				idiv	zoomval
				mov		x,eax
				mov		eax,y
				sub		eax,topy
				imul	dd256
				idiv	zoomval
				mov		y,eax
				mov		eax,map.zoominx
				.if [esi].PLACE.font && eax<[esi].PLACE.zoom && [esi].PLACE.text
					mov		eax,[esi].PLACE.font
					invoke SelectObject,map.mDC2,map.font[eax*4]
					push	eax
					invoke strlen,addr [esi].PLACE.text
					mov		ecx,x
					add		ecx,8
					mov		edx,y
					sub		edx,10
					invoke TextOut,map.mDC2,ecx,edx,addr [esi].PLACE.text,eax
					pop		eax
					invoke SelectObject,map.mDC2,eax
				.endif
				.if [esi].PLACE.icon
					mov		eax,[esi].PLACE.icon
					mov		ecx,x
					sub		ecx,8
					mov		edx,y
					sub		edx,8
					invoke ImageList_Draw,hIml,addr [eax+7],map.mDC2,ecx,edx,ILD_TRANSPARENT
				.endif
			.endif
			lea		esi,[esi+sizeof PLACE]
			inc		ebx
		.endw
	.endif
	ret

ShowPlace endp

ShowGpsCursor proc uses ebx esi edi,topx:DWORD,topy:DWORD,curx:DWORD,cury:DWORD,zoomval:DWORD
	LOCAL	pt:POINT

	.if zoomval && map.fcursor
		mov		eax,curx
		sub		eax,topx
		imul	dd256
		idiv	zoomval
		sub		eax,8
		mov		pt.x,eax
		mov		eax,cury
		sub		eax,topy
		imul	dd256
		idiv	zoomval
		sub		eax,8
		mov		pt.y,eax
		invoke ImageList_Draw,hIml,map.ncursor,map.mDC2,pt.x,pt.y,ILD_TRANSPARENT
	.endif
	ret

ShowGpsCursor endp

ShowSpeedBattTempTimeScale proc uses ebx esi edi
	LOCAL	rect:RECT
	LOCAL	x:DWORD

	invoke SetTextColor,map.mDC2,0
	xor		ebx,ebx
	mov		esi,offset map.options
	.while ebx<MAXMAPOPTION
		.if [esi].OPTIONS.show
			mov		ecx,[esi].OPTIONS.pt.x
			mov		edx,[esi].OPTIONS.pt.y
			mov		rect.left,ecx
			mov		rect.top,edx
			mov		eax,map.mapwt
			sub		eax,ecx
			mov		rect.right,eax
			mov		eax,map.mapht
			sub		eax,edx
			mov		rect.bottom,eax
			mov		eax,[esi].OPTIONS.font
			.if ebx>=3
				shl		eax,1
			.else
				add		eax,7
			.endif
			mov		ecx,map.font[eax*4]
			mov		edx,[esi].OPTIONS.position
			.if !edx
				;Left, Top
				mov		eax,DT_LEFT or DT_SINGLELINE
			.elseif edx==1
				;Center, Top
				mov		eax,DT_CENTER or DT_SINGLELINE
			.elseif edx==2
				;Rioght, Top
				mov		eax,DT_RIGHT or DT_SINGLELINE
			.elseif edx==3
				;Left, Bottom
				mov		eax,DT_LEFT or DT_BOTTOM or DT_SINGLELINE
			.elseif edx==4
				;Center, Bottom
				mov		eax,DT_CENTER or DT_BOTTOM or DT_SINGLELINE
			.elseif edx==5
				;Right, Bottom
				mov		eax,DT_RIGHT or DT_BOTTOM or DT_SINGLELINE
			.endif
			invoke TextDraw,map.mDC2,ecx,addr rect,addr [esi].OPTIONS.text,eax
			.if ebx==3
				call	ShowScale
			.endif
		.endif
		lea		esi,[esi+sizeof OPTIONS]
		inc		ebx
	.endw
	ret

ShowScale:
	mov		eax,map.zoominx
	mov		ecx,sizeof ZOOM
	mul		ecx
	mov		edi,map.zoom.scalep[eax]
	invoke strlen,addr [esi].OPTIONS.text
	mov		ecx,eax
	mov		edx,[esi].OPTIONS.position
	.if !edx
		;Left, Top
		mov		eax,rect.left
		mov		x,eax
		mov		eax,edi
		shr		eax,1
		sub		x,eax
		invoke DrawText,map.mDC2,addr [esi].OPTIONS.text,ecx,addr rect,DT_LEFT or DT_SINGLELINE or DT_CALCRECT
		mov		eax,rect.right
		sub		eax,rect.left
		shr		eax,1
		add		x,eax
	.elseif edx==1
		;Center, Top
		mov		rect.left,0
		mov		eax,[esi].OPTIONS.pt.x
		sub		rect.right,eax
		mov		eax,rect.right
		shr		eax,1
		mov		x,eax
		mov		eax,edi
		shr		eax,1
		sub		x,eax
		invoke DrawText,map.mDC2,addr [esi].OPTIONS.text,ecx,addr rect,DT_CENTER or DT_SINGLELINE or DT_CALCRECT
	.elseif edx==2
		;Rioght, Top
		mov		eax,rect.right
		sub		eax,edi
		mov		x,eax
		invoke DrawText,map.mDC2,addr [esi].OPTIONS.text,ecx,addr rect,DT_RIGHT or DT_SINGLELINE or DT_CALCRECT
		mov		eax,rect.right
		sub		eax,rect.left
		add		x,eax
	.elseif edx==3
		;Left, Bottom
		mov		eax,rect.left
		mov		x,eax
		mov		eax,edi
		shr		eax,1
		sub		x,eax
		invoke DrawText,map.mDC2,addr [esi].OPTIONS.text,ecx,addr rect,DT_LEFT or DT_BOTTOM or DT_SINGLELINE or DT_CALCRECT
		mov		eax,rect.right
		sub		eax,rect.left
		shr		eax,1
		add		x,eax
	.elseif edx==4
		;Center, Bottom
		mov		rect.left,0
		mov		eax,[esi].OPTIONS.pt.x
		sub		rect.right,eax
		mov		eax,rect.right
		shr		eax,1
		mov		x,eax
		mov		eax,edi
		shr		eax,1
		sub		x,eax
		invoke DrawText,map.mDC2,addr [esi].OPTIONS.text,ecx,addr rect,DT_CENTER or DT_BOTTOM or DT_SINGLELINE or DT_CALCRECT
	.elseif edx==5
		;Right, Bottom
		mov		eax,rect.right
		sub		eax,edi
		mov		x,eax
		invoke DrawText,map.mDC2,addr [esi].OPTIONS.text,ecx,addr rect,DT_RIGHT or DT_BOTTOM or DT_SINGLELINE or DT_CALCRECT
		mov		eax,rect.right
		sub		eax,rect.left
		add		x,eax
	.endif
	mov		eax,rect.bottom
	sub		eax,4
	invoke MoveToEx,map.mDC2,x,eax,NULL
	invoke LineTo,map.mDC2,x,rect.bottom
	add		x,edi
	invoke LineTo,map.mDC2,x,rect.bottom
	mov		eax,rect.bottom
	sub		eax,5
	invoke LineTo,map.mDC2,x,eax
	retn

ShowSpeedBattTempTimeScale endp

ShowTrail proc uses ebx esi edi,topx:DWORD,topy:DWORD,zoomval:DWORD
	LOCAL	pt:POINT

	invoke CreatePen,PS_SOLID,2,0808080h
	invoke SelectObject,map.mDC2,eax
	push	eax
	mov		ebx,map.trailtail
	call	ToScreen
	invoke MoveToEx,map.mDC2,pt.x,pt.y,NULL
	.while ebx!=map.trailhead
		inc		ebx
		and		ebx,MAXTRAIL-1
		.if ebx!=map.trailhead
			call	ToScreen
			invoke LineTo,map.mDC2,pt.x,pt.y
		.endif
	.endw
	pop		eax
	invoke SelectObject,map.mDC2,eax
	invoke DeleteObject,eax
	ret

ToScreen:
	mov		edx,ebx
	shl		edx,4
	invoke GpsPosToMapPos,map.trail.iLon[edx],map.trail.iLat[edx],addr pt.x,addr pt.y
	invoke MapPosToScrnPos,pt.x,pt.y,addr pt.x,addr pt.y
	mov 	eax,pt.x
	sub		eax,topx
	imul	dd256
	idiv	zoomval
	mov		pt.x,eax
	mov 	eax,pt.y
	sub		eax,topy
	imul	dd256
	idiv	zoomval
	mov		pt.y,eax
	retn

ShowTrail endp

ShowDist proc uses ebx esi edi,topx:DWORD,topy:DWORD,zoomval:DWORD
	LOCAL	pt:POINT

	xor		ebx,ebx
	call	ToScreen
	invoke MoveToEx,map.mDC2,pt.x,pt.y,NULL
	sub		pt.x,8
	sub		pt.y,8
	invoke ImageList_Draw,hIml,8,map.mDC2,pt.x,pt.y,ILD_TRANSPARENT
	inc		ebx
	.while ebx<map.disthead && ebx<MAXDIST
		call	ToScreen
		lea		edx,[ebx+1]
		mov		eax,9
		.if edx==map.disthead
			mov		eax,10
		.endif
		mov		ecx,pt.x
		sub		ecx,8
		mov		edx,pt.y
		sub		edx,8
		invoke ImageList_Draw,hIml,eax,map.mDC2,ecx,edx,ILD_TRANSPARENT
		invoke LineTo,map.mDC2,pt.x,pt.y
		inc		ebx
	.endw
	ret

ToScreen:
	mov		edx,ebx
	shl		edx,4
	invoke GpsPosToMapPos,map.dist.iLon[edx],map.dist.iLat[edx],addr pt.x,addr pt.y
	invoke MapPosToScrnPos,pt.x,pt.y,addr pt.x,addr pt.y
	mov 	eax,pt.x
	sub		eax,topx
	imul	dd256
	idiv	zoomval
	mov		pt.x,eax
	mov 	eax,pt.y
	sub		eax,topy
	imul	dd256
	idiv	zoomval
	mov		pt.y,eax
	retn

ShowDist endp

ShowTrip proc uses ebx esi edi,topx:DWORD,topy:DWORD,zoomval:DWORD
	LOCAL	pt:POINT

	xor		ebx,ebx
	call	ToScreen
	invoke MoveToEx,map.mDC2,pt.x,pt.y,NULL
	sub		pt.x,8
	sub		pt.y,8
	invoke ImageList_Draw,hIml,8,map.mDC2,pt.x,pt.y,ILD_TRANSPARENT
	inc		ebx
	.while ebx<map.triphead && ebx<MAXTRIP
		call	ToScreen
		lea		edx,[ebx+1]
		mov		eax,9
		.if edx==map.triphead
			mov		eax,10
		.endif
		mov		ecx,pt.x
		sub		ecx,8
		mov		edx,pt.y
		sub		edx,8
		invoke ImageList_Draw,hIml,eax,map.mDC2,ecx,edx,ILD_TRANSPARENT
		invoke LineTo,map.mDC2,pt.x,pt.y
		inc		ebx
	.endw
	ret

ToScreen:
	mov		edx,ebx
	shl		edx,4
	invoke GpsPosToMapPos,map.trip.iLon[edx],map.trip.iLat[edx],addr pt.x,addr pt.y
	invoke MapPosToScrnPos,pt.x,pt.y,addr pt.x,addr pt.y
	mov 	eax,pt.x
	sub		eax,topx
	imul	dd256
	idiv	zoomval
	mov		pt.x,eax
	mov 	eax,pt.y
	sub		eax,topy
	imul	dd256
	idiv	zoomval
	mov		pt.y,eax
	retn

ShowTrip endp

ShowGrid proc uses ebx esi edi,topx:DWORD,topy:DWORD,zoomval:DWORD
	LOCAL	fpixm:REAL10
	LOCAL	i:DWORD
	LOCAL	x:DWORD
	LOCAL	y:DWORD

	invoke CreatePen,PS_SOLID,1,0A0A0A0h
	invoke SelectObject,map.mDC2,eax
	push	eax
	mov		eax,map.zoominx
	mov		ecx,sizeof ZOOM
	mul		ecx
	lea		esi,[eax+offset map.zoom]
	fild	map.zoom.xPixels[sizeof ZOOM]
	fild	map.zoom.xMeters[sizeof ZOOM]
	fdivp	st(1),st(0)
	fstp	fpixm
	fild	topx
	fild	[esi].ZOOM.scalem
	fld		fpixm
	fmulp	st(1),st(0)
	fdivp	st(1),st(0)
	fistp	i
	.while TRUE
		fild	[esi].ZOOM.scalem
		fild	i
		fmulp	st(1),st(0)
		fld		fpixm
		fmulp	st(1),st(0)
		fistp	x
		invoke MapPosToScrnPos,x,0,addr x,addr y
		mov		eax,x
		sub		eax,topx
		imul	dd256
		idiv	zoomval
		mov		x,eax
		.break .if sdword ptr eax>map.mapwt
		.if sdword ptr eax>=0
			invoke MoveToEx,map.mDC2,x,0,NULL
			invoke LineTo,map.mDC2,x,map.mapht
		.endif
		inc		i
	.endw
	fild	map.zoom.yPixels[sizeof ZOOM]
	fild	map.zoom.yMeters[sizeof ZOOM]
	fdivp	st(1),st(0)
	fstp	fpixm
	fild	topy
	fild	[esi].ZOOM.scalem
	fld		fpixm
	fmulp	st(1),st(0)
	fdivp	st(1),st(0)
	fistp	i
	.while TRUE
		fild	[esi].ZOOM.scalem
		fild	i
		fmulp	st(1),st(0)
		fld		fpixm
		fmulp	st(1),st(0)
		fistp	y
		invoke MapPosToScrnPos,0,y,addr x,addr y
		mov		eax,y
		sub		eax,topy
		imul	dd256
		idiv	zoomval
		mov		y,eax
		.break .if sdword ptr eax>map.mapht
		.if sdword ptr eax>=0
			invoke MoveToEx,map.mDC2,0,y,NULL
			invoke LineTo,map.mDC2,map.mapwt,y
		.endif
		inc		i
	.endw
	pop		eax
	invoke SelectObject,map.mDC2,eax
	invoke DeleteObject,eax
	ret

ShowGrid endp

;This thread proc pains the map window
PaintMap proc uses esi edi,Param:DWORD
	LOCAL	zoomval:DWORD
	LOCAL	topx:DWORD
	LOCAL	topy:DWORD
	LOCAL	curx:DWORD
	LOCAL	cury:DWORD

	.while !fExitMapThread
		.if map.paintnow
			dec		map.paintnow
			mov		eax,map.zoomval
			mov		zoomval,eax
			mov		ecx,map.topx
			mov		edx,map.topy
			mov		topx,ecx
			mov		topy,edx
			mov		ecx,map.cursorx
			mov		edx,map.cursory
			mov		curx,ecx
			mov		cury,edx
			invoke ShowMap,topx,topy,zoomval
			invoke BitBlt,map.mDC2,0,0,map.mapwt,map.mapht,map.mDC,0,0,SRCCOPY
			.if map.mapgrid
				invoke ShowGrid,topx,topy,zoomval
			.endif
			.if map.gpstrail
				mov		eax,map.trailhead
				.if eax!=map.trailtail
					invoke ShowTrail,topx,topy,zoomval
				.endif
			.endif
			invoke ShowPlace,topx,topy,zoomval
			.if map.triphead
				invoke ShowTrip,topx,topy,zoomval
			.endif
			.if map.disthead
				invoke ShowDist,topx,topy,zoomval
			.endif
			invoke ShowGpsCursor,topx,topy,curx,cury,zoomval
			invoke ShowSpeedBattTempTimeScale
			invoke BitBlt,map.hDC,0,0,map.mapwt,map.mapht,map.mDC2,0,0,SRCCOPY
		.else
			invoke Sleep,100
		.endif
	.endw
	ret

PaintMap endp
