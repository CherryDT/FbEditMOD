
; Note!
; This program assumes that longitude east and lattitude north are positive integers
; while longitude west and lattitude south are negative integers.
; 
; Description on longitude & lattitude:
; http://www.worldatlas.com/aatlas/imageg.htm
; 
; Communication with GPS (NMEA 0183):
; http://www.tronico.fi/OH6NT/docs/NMEA0183.pdf
; 

.586
.model flat,stdcall
option casemap:none

include ShowMap.inc
include Distance.asm
include Misc.asm
include GpsComm.asm
include Places.asm
include Options.asm
include TripLog.asm
include DrawMap.asm
include Sonar.asm

.code

InitMaps proc uses ebx
	LOCAL	buffer[MAX_PATH]:BYTE

	;Get zoom index
	invoke GetPrivateProfileInt,addr szIniMap,addr szIniZoom,1,addr szIniFileName
	mov		map.zoominx,eax
	;Get zoom level
	mov		edx,sizeof ZOOM
	mul		edx
	mov		edx,map.zoom.zoomval[eax]
	mov		map.zoomval,edx
	mov		edx,map.zoom.mapinx[eax]
	mov		map.mapinx,edx
	mov		edx,map.zoom.nx[eax]
	mov		map.nx,edx
	mov		edx,map.zoom.ny[eax]
	mov		map.ny,edx
	invoke strcpy,addr map.options.text[sizeof OPTIONS*3],addr map.zoom.text[eax]
	;Get map pixel positions, left top and right bottom
	invoke GetPrivateProfileString,addr szIniMap,addr szIniPos,addr szNULL,addr buffer,sizeof buffer,addr szIniFileName
	invoke GetItemInt,addr buffer,0
	mov		map.topx,eax
	invoke GetItemInt,addr buffer,0
	mov		map.topy,eax
	invoke GetItemInt,addr buffer,256
	mov		map.cursorx,eax
	invoke GetItemInt,addr buffer,256
	mov		map.cursory,eax
	mov		map.fcursor,TRUE
	ret

InitMaps endp

InitZoom proc uses ebx esi edi

	mov		esi,offset map.zoom
	xor		ebx,ebx
	.while ebx<MAXZOOM
		invoke wsprintf,addr szbuff,addr szFmtDec,ebx
		invoke GetPrivateProfileString,addr szIniZoom,addr szbuff,addr szNULL,addr szbuff,sizeof szbuff,addr szIniFileName
		.break .if !eax
		invoke GetItemInt,addr szbuff,0
		mov		[esi].ZOOM.zoomval,eax
		invoke GetItemInt,addr szbuff,0
		mov		[esi].ZOOM.mapinx,eax
		invoke GetItemInt,addr szbuff,0
		mov		[esi].ZOOM.scalem,eax
		invoke strcpyn,addr [esi].ZOOM.text,addr szbuff,sizeof ZOOM.text
		invoke CountMapTiles,[esi].ZOOM.mapinx,addr [esi].ZOOM.nx,addr [esi].ZOOM.ny
		invoke GetMapSize,[esi].ZOOM.nx,[esi].ZOOM.ny,addr [esi].ZOOM.xPixels,addr [esi].ZOOM.yPixels,addr [esi].ZOOM.xMeters,addr [esi].ZOOM.yMeters
		.if !ebx
			mov		eax,[esi].ZOOM.xPixels
			mov		map.xPixels,eax
			mov		eax,[esi].ZOOM.yPixels
			mov		map.yPixels,eax
			mov		eax,[esi].ZOOM.xMeters
			mov		map.xMeters,eax
			mov		eax,[esi].ZOOM.yMeters
			mov		map.yMeters,eax
		.endif
		;Convert xPixels to zoomval
		mov		eax,[esi].ZOOM.xPixels
		imul	dd256
		idiv	[esi].ZOOM.zoomval
		mov		[esi].ZOOM.xPixels,eax
		;Convert yPixels to zoomval
		mov		eax,[esi].ZOOM.yPixels
		imul	dd256
		idiv	[esi].ZOOM.zoomval
		mov		[esi].ZOOM.yPixels,eax
		;I can now get the pixels/meter and calculate the lenght of the scale bar
		fild	[esi].ZOOM.yPixels
		fild	[esi].ZOOM.yMeters
		fdivp	st(1),st(0)
		fild	[esi].ZOOM.scalem
		fmulp	st(1),st(0)
		fistp	[esi].ZOOM.scalep
		lea		esi,[esi+sizeof ZOOM]
		inc		ebx
	.endw
	mov		map.zoommax,ebx
	ret

InitZoom endp

InitFonts proc uses ebx
	LOCAL	buffer[256]:BYTE
	LOCAL	lf:LOGFONT

	invoke RtlZeroMemory,addr lf,sizeof LOGFONT
	xor		ebx,ebx
	.while ebx<MAXFONT
		invoke BinToDec,ebx,addr buffer
		invoke GetPrivateProfileString,addr szIniFont,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr szIniFileName
		.break .if !eax
		invoke GetItemInt,addr buffer,8
		mov		lf.lfHeight,eax
		invoke GetItemInt,addr buffer,0
		.if eax
			mov		eax,700
		.endif
		mov		lf.lfWeight,eax
		invoke GetItemInt,addr buffer,0
		mov		lf.lfItalic,al
		invoke GetItemInt,addr buffer,0
		mov		lf.lfCharSet,al
		invoke strcpyn,addr lf.lfFaceName,addr buffer,LF_FACESIZE
		invoke GetDC,hWnd
		push	eax
		invoke GetDeviceCaps,eax,LOGPIXELSY
		imul	lf.lfHeight
		idiv	dd72
		neg		eax
		mov		lf.lfHeight,eax
		invoke CreateFontIndirect,addr lf
		mov		map.font[ebx*4],eax
		pop		eax
		invoke ReleaseDC,hWnd,eax
		inc		ebx
	.endw
	ret

InitFonts endp

InitScroll proc

	mov		eax,map.nx
	inc		eax
	shl		eax,9
	sub		eax,map.mapwt
	shr		eax,4
	invoke SetScrollRange,hMap,SB_HORZ,0,eax,TRUE
	mov		eax,map.topx
	shr		eax,4
	invoke SetScrollPos,hMap,SB_HORZ,eax,TRUE
	mov		eax,map.ny
	inc		eax
	shl		eax,9
	sub		eax,map.mapht
	shr		eax,4
	invoke SetScrollRange,hMap,SB_VERT,0,eax,TRUE
	mov		eax,map.topy
	shr		eax,4
	invoke SetScrollPos,hMap,SB_VERT,eax,TRUE
	ret

InitScroll endp

MapProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	x:DWORD
	LOCAL	y:DWORD
	LOCAL	iLon:DWORD
	LOCAL	iLat:DWORD
	LOCAL	fDist:REAL10
	LOCAL	fBear:REAL10

	mov		eax,uMsg
	.if eax==WM_CREATE
		mov		eax,hWin
		mov		hMap,eax
		invoke ImageList_Create,16,16,ILC_COLOR24 or ILC_MASK,8+16,0
		mov		hIml,eax
		invoke LoadBitmap,hInstance,100
		mov		ebx,eax
		invoke ImageList_AddMasked,hIml,ebx,0FF00FFh
		invoke DeleteObject,ebx
		invoke GetDC,hWin
		mov		map.hDC,eax
		invoke CreateCompatibleDC,map.hDC
		mov		map.mDC,eax
		invoke GetSystemMetrics,SM_CXSCREEN
		mov		map.cxs,eax
		invoke GetSystemMetrics,SM_CYSCREEN
		mov		map.cys,eax
		invoke CreateCompatibleBitmap,map.hDC,map.cxs,map.cys
		invoke SelectObject,map.mDC,eax
		mov		map.hmBmpOld,eax
		invoke CreateCompatibleDC,map.hDC
		mov		map.mDC2,eax
		invoke CreateCompatibleBitmap,map.hDC,1,1
		invoke SelectObject,map.mDC2,eax
		mov		map.hmBmpOld2,eax
		invoke CreateCompatibleDC,map.hDC
		mov		map.tDC,eax
		invoke SetStretchBltMode,map.mDC,COLORONCOLOR
		invoke SetBkMode,map.mDC2,TRANSPARENT
	.elseif eax==WM_CONTEXTMENU
		mov		eax,lParam
		.if eax!=-1
			movsx	edx,ax
			mov		mousept.x,edx
			mov		pt.x,edx
			shr		eax,16
			movsx	edx,ax
			mov		mousept.y,edx
			mov		pt.y,edx
			.if map.btrip
				mov		eax,MF_BYCOMMAND or MF_UNCHECKED
				.if map.btrip==2
					mov		eax,MF_BYCOMMAND or MF_CHECKED
				.endif
				invoke CheckMenuItem,hContext,IDM_TRIP_DONE,eax
				mov		eax,MF_BYCOMMAND or MF_UNCHECKED
				.if map.btrip==3
					mov		eax,MF_BYCOMMAND or MF_CHECKED
				.endif
				invoke CheckMenuItem,hContext,IDM_TRIP_EDIT,eax
				.if map.btrip==3 && map.onpoint!=-1
					mov		eax,MF_BYCOMMAND or MF_ENABLED
					.if map.triphead==1
						mov		eax,MF_BYCOMMAND or MF_GRAYED
					.endif
					invoke EnableMenuItem,hContext,IDM_TRIP_DELETE,eax
					invoke GetSubMenu,hContext,2
				.else
					invoke GetSubMenu,hContext,1
				.endif
			.elseif map.bdist
				mov		eax,MF_BYCOMMAND or MF_UNCHECKED
				.if map.bdist==2
					mov		eax,MF_BYCOMMAND or MF_CHECKED
				.endif
				invoke CheckMenuItem,hContext,IDM_DIST_DONE,eax
				mov		eax,MF_BYCOMMAND or MF_UNCHECKED
				.if map.bdist==3
					mov		eax,MF_BYCOMMAND or MF_CHECKED
				.endif
				invoke CheckMenuItem,hContext,IDM_DIST_EDIT,eax
				.if map.bdist==3 && map.onpoint!=-1
					mov		eax,MF_BYCOMMAND or MF_ENABLED
					.if map.disthead==1
						mov		eax,MF_BYCOMMAND or MF_GRAYED
					.endif
					invoke EnableMenuItem,hContext,IDM_DIST_DELETE,eax
					invoke GetSubMenu,hContext,4
				.else
					invoke GetSubMenu,hContext,3
				.endif
			.else
				invoke ScreenToClient,hWin,addr pt
				invoke ScrnPosToMapPos,pt.x,pt.y,addr x,addr y
				invoke MapPosToGpsPos,x,y,addr iLon,addr iLat
				invoke FindPlace,iLon,iLat
				mov		nPlace,eax
				mov		edx,MF_BYCOMMAND or MF_GRAYED
				.if eax!=-1
					mov		edx,MF_BYCOMMAND or MF_ENABLED
				.endif
				invoke EnableMenuItem,hContext,IDM_EDITPLACE,edx
				invoke GetSubMenu,hContext,0
			.endif
			invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,mousept.x,mousept.y,0,hWnd,0
			invoke ScreenToClient,hWin,addr mousept
		.endif
	.elseif eax==WM_PAINT
		inc		map.paintnow
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		mov		eax,rect.right
		mov		map.mapwt,eax
		mov		eax,rect.bottom
		mov		map.mapht,eax
		invoke CreateCompatibleBitmap,map.hDC,map.mapwt,map.mapht
		invoke SelectObject,map.mDC2,eax
		invoke DeleteObject,eax
		invoke InitScroll
	.elseif eax==WM_MOUSEMOVE
		mov		edx,lParam
		movsx	eax,dx
		shr		edx,16
		movsx	edx,dx
		mov		pt.x,eax
		mov		pt.y,edx
		push	eax
		push	edx
		invoke ScrnPosToMapPos,pt.x,pt.y,addr x,addr y
		invoke MapPosToGpsPos,x,y,addr iLon,addr iLat
		invoke SetDlgItemInt,hWnd,IDC_EDTNORTH,iLat,TRUE
		mov		eax,iLon
		invoke SetDlgItemInt,hWnd,IDC_EDTEAST,eax,TRUE
		pop		edx
		pop		eax
		.if map.bdist==1 && map.disthead
			.if eax>map.mapwt || edx>map.mapht
				invoke ReleaseCapture
				.if map.disthead
					inc		map.paintnow
				.endif
			.else
				mov		pt.x,eax
				mov		pt.y,edx
				invoke BitBlt,map.hDC,0,0,map.mapwt,map.mapht,map.mDC2,0,0,SRCCOPY
				mov		edi,map.disthead
				dec		edi
				mov		eax,sizeof LOG
				mul		edi
				mov		ebx,eax
				invoke GpsPosToMapPos,map.dist.iLon[ebx],map.dist.iLat[ebx],addr x,addr y
				invoke MapPosToScrnPos,x,y,addr x,addr y
				mov 	eax,x
				sub		eax,map.topx
				imul	dd256
				idiv	map.zoomval
				mov		x,eax
				mov 	eax,y
				sub		eax,map.topy
				imul	dd256
				idiv	map.zoomval
				mov		y,eax
				invoke MoveToEx,map.hDC,x,y,NULL
				invoke LineTo,map.hDC,pt.x,pt.y
				inc		edi
				mov		eax,sizeof LOG
				mul		edi
				mov		ebx,eax
				invoke ScrnPosToMapPos,pt.x,pt.y,addr x,addr y
				invoke MapPosToGpsPos,x,y,addr map.dist.iLon[ebx],addr map.dist.iLat[ebx]
				invoke GetCapture
				.if eax!=hWin
					invoke SetCapture,hWin
				.endif
				invoke GetDistance,addr map.dist,map.disthead
			.endif
		.elseif map.bdist==3 && map.disthead
			.if (wParam & MK_LBUTTON) && map.onpoint!=-1
				mov		ebx,map.onpoint
				shl		ebx,4
				mov		ecx,eax
				invoke ScrnPosToMapPos,ecx,edx,addr x,addr y
				invoke MapPosToGpsPos,x,y,addr map.dist.iLon[ebx],addr map.dist.iLat[ebx]
				.if map.onpoint
					invoke BearingDistanceInt,map.dist.iLon[ebx-sizeof LOG],addr map.dist.iLat[ebx-sizeof LOG],map.dist.iLon[ebx],addr map.dist.iLat[ebx],addr fDist,addr fBear
					fld		fBear
					fistp	map.dist.iBear[ebx-sizeof LOG]
				.endif
				mov		eax,map.disthead
				dec		eax
				invoke GetDistance,addr map.dist,eax
			.else
				invoke FindPoint,eax,edx,addr map.dist,map.disthead
				mov		map.onpoint,eax
			.endif
			inc		map.paintnow
		.elseif map.btrip==1 && map.triphead
			.if eax>map.mapwt || edx>map.mapht
				invoke ReleaseCapture
				.if map.triphead
					inc		map.paintnow
				.endif
			.else
				mov		pt.x,eax
				mov		pt.y,edx
				invoke BitBlt,map.hDC,0,0,map.mapwt,map.mapht,map.mDC2,0,0,SRCCOPY
				mov		edi,map.triphead
				dec		edi
				mov		eax,sizeof LOG
				mul		edi
				mov		ebx,eax
				invoke GpsPosToMapPos,map.trip.iLon[ebx],map.trip.iLat[ebx],addr x,addr y
				invoke MapPosToScrnPos,x,y,addr x,addr y
				mov 	eax,x
				sub		eax,map.topx
				imul	dd256
				idiv	map.zoomval
				mov		x,eax
				mov 	eax,y
				sub		eax,map.topy
				imul	dd256
				idiv	map.zoomval
				mov		y,eax
				invoke MoveToEx,map.hDC,x,y,NULL
				invoke LineTo,map.hDC,pt.x,pt.y
				inc		edi
				mov		eax,sizeof LOG
				mul		edi
				mov		ebx,eax
				invoke ScrnPosToMapPos,pt.x,pt.y,addr x,addr y
				invoke MapPosToGpsPos,x,y,addr map.trip.iLon[ebx],addr map.trip.iLat[ebx]
				invoke GetCapture
				.if eax!=hWin
					invoke SetCapture,hWin
				.endif
				invoke GetDistance,addr map.trip,map.triphead
			.endif
		.elseif map.btrip==3 && map.triphead
			.if (wParam & MK_LBUTTON) && map.onpoint!=-1
				mov		ebx,map.onpoint
				shl		ebx,4
				mov		ecx,eax
				invoke ScrnPosToMapPos,ecx,edx,addr x,addr y
				invoke MapPosToGpsPos,x,y,addr map.trip.iLon[ebx],addr map.trip.iLat[ebx]
				.if map.onpoint
					invoke BearingDistanceInt,map.trip.iLon[ebx-sizeof LOG],addr map.trip.iLat[ebx-sizeof LOG],map.trip.iLon[ebx],addr map.trip.iLat[ebx],addr fDist,addr fBear
					fld		fBear
					fistp	map.trip.iBear[ebx-sizeof LOG]
				.endif
				mov		eax,map.triphead
				dec		eax
				invoke GetDistance,addr map.trip,eax
			.else
				invoke FindPoint,eax,edx,addr map.trip,map.triphead
				mov		map.onpoint,eax
			.endif
			inc		map.paintnow
		.endif
	.elseif eax==WM_LBUTTONDOWN
		mov		edx,lParam
		movsx	eax,dx
		mov		mousept.x,eax
		shr		edx,16
		movsx	edx,dx
		mov		mousept.y,edx
		.if map.bdist==1
			;Add new point
			mov		edi,map.disthead
			.if edi<MAXDIST-1
				mov		ecx,eax
				mov		ebx,edi
				shl		ebx,4
				invoke ScrnPosToMapPos,ecx,edx,addr x,addr y
				invoke MapPosToGpsPos,x,y,addr map.dist.iLon[ebx],addr map.dist.iLat[ebx]
				inc		map.disthead
				inc		map.paintnow
			.endif
		.elseif map.btrip==1
			;Add new point
			mov		edi,map.triphead
			.if edi<MAXTRIP-1
				mov		ecx,eax
				mov		ebx,edi
				shl		ebx,4
				invoke ScrnPosToMapPos,ecx,edx,addr x,addr y
				invoke MapPosToGpsPos,x,y,addr map.trip.iLon[ebx],addr map.trip.iLat[ebx]
				inc		map.triphead
				inc		map.paintnow
			.endif
		.elseif (!map.bdist || map.bdist==2) && (!map.btrip || map.btrip==2)
			invoke SetCapture,hWin
			invoke LoadCursor,0,IDC_SIZEALL
			invoke SetCursor,eax
		.endif
	.elseif eax==WM_LBUTTONUP
		.if (!map.bdist || map.bdist==2) && (!map.btrip || map.btrip==2)
			invoke GetCapture
			.if eax==hWin
				mov		eax,lParam
				movsx	eax,ax
				sub		eax,mousept.x
				neg		eax
				imul	map.zoomval
				idiv	dd256
				add		map.topx,eax
				.if SIGN?
					mov		map.topx,0
				.endif
				mov		eax,lParam
				shr		eax,16
				movsx	eax,ax
				sub		eax,mousept.y
				neg		eax
				imul	map.zoomval
				idiv	dd256
				add		map.topy,eax
				.if SIGN?
					mov		map.topy,0
				.endif
				invoke ReleaseCapture
				invoke LoadCursor,0,IDC_ARROW
				invoke SetCursor,eax
				inc		map.paintnow
				mov		eax,map.topx
				shr		eax,4
				invoke SetScrollPos,hMap,SB_HORZ,eax,TRUE
				mov		eax,map.topy
				shr		eax,4
				invoke SetScrollPos,hMap,SB_VERT,eax,TRUE
			.endif
		.endif
		invoke SetFocus,hWnd
	.elseif eax==WM_SETCURSOR
		.if map.bdist==1 || map.btrip==1 || (map.bdist==3 && map.onpoint!=-1) || (map.btrip==3 && map.onpoint!=-1)
			invoke LoadCursor,0,IDC_CROSS
		.else
			invoke LoadCursor,0,IDC_ARROW
		.endif
		invoke SetCursor,eax
	.elseif eax==WM_MOUSEWHEEL
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		movsx	eax,ax
		test	edx,MK_CONTROL
		.if ZERO?
			.if sdword ptr eax<0
				invoke GetScrollPos,hWin,SB_VERT
				add		eax,4
				call	VScroll
			.else
				invoke GetScrollPos,hWin,SB_VERT
				sub		eax,4
				call	VScroll
			.endif
		.else
			.if sdword ptr eax<0
				invoke GetScrollPos,hWin,SB_HORZ
				add		eax,4
				call	HScroll
			.else
				invoke GetScrollPos,hWin,SB_HORZ
				sub		eax,4
				call	HScroll
			.endif
		.endif
	.elseif eax==WM_KEYDOWN
		mov		eax,wParam
		.if eax==VK_RIGHT
			invoke GetScrollPos,hWin,SB_HORZ
			add		eax,4
			call	HScroll
		.elseif eax==VK_LEFT
			invoke GetScrollPos,hWin,SB_HORZ
			sub		eax,4
			call	HScroll
		.elseif eax==VK_DOWN
			invoke GetScrollPos,hWin,SB_VERT
			add		eax,4
			call	VScroll
		.elseif eax==VK_UP
			invoke GetScrollPos,hWin,SB_VERT
			sub		eax,4
			call	VScroll
		.endif
	.elseif eax==WM_VSCROLL
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		.if edx==SB_THUMBPOSITION
			call	VScroll
		.elseif edx==SB_LINEDOWN
			invoke GetScrollPos,hWin,SB_VERT
			add		eax,4
			call	VScroll
		.elseif edx==SB_LINEUP
			invoke GetScrollPos,hWin,SB_VERT
			sub		eax,4
			.if CARRY?
				xor		eax,eax
			.endif
			call	VScroll
		.elseif edx==SB_PAGEDOWN
			invoke GetScrollPos,hWin,SB_VERT
			mov		edx,map.mapht
			shr		edx,4
			add		eax,edx
			call	VScroll
		.elseif edx==SB_PAGEUP
			invoke GetScrollPos,hWin,SB_VERT
			mov		edx,map.mapht
			shr		edx,4
			sub		eax,edx
			call	VScroll
		.endif
	.elseif eax==WM_HSCROLL
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		.if edx==SB_THUMBPOSITION
			call	HScroll
		.elseif edx==SB_LINEDOWN
			invoke GetScrollPos,hWin,SB_HORZ
			add		eax,4
			call	HScroll
		.elseif edx==SB_LINEUP
			invoke GetScrollPos,hWin,SB_HORZ
			sub		eax,4
			call	HScroll
		.elseif edx==SB_PAGEDOWN
			invoke GetScrollPos,hWin,SB_HORZ
			mov		edx,map.mapwt
			shr		edx,4
			add		eax,edx
			call	HScroll
		.elseif edx==SB_PAGEUP
			invoke GetScrollPos,hWin,SB_HORZ
			mov		edx,map.mapwt
			shr		edx,4
			sub		eax,edx
			call	HScroll
		.endif
	.elseif eax==WM_DESTROY
		invoke SelectObject,map.mDC,map.hmBmpOld
		invoke DeleteObject,eax
		invoke DeleteDC,map.mDC
		invoke SelectObject,map.mDC2,map.hmBmpOld2
		invoke DeleteObject,eax
		invoke DeleteDC,map.mDC2
		invoke DeleteDC,map.tDC
		invoke ReleaseDC,hWin,map.hDC
		xor		ebx,ebx
		mov		esi,offset bmpcache
		.while ebx<MAXBMP
			.if [esi].BMP.hBmp
				invoke DeleteObject,[esi].BMP.hBmp
			.endif
			lea		esi,[esi+sizeof BMP]
			inc		ebx
		.endw
		xor		ebx,ebx
		.while ebx<MAXFONT
			.if map.font[ebx*4]
				invoke DeleteObject,map.font[ebx*4]
			.endif
			inc		ebx
		.endw
		invoke ImageList_Destroy,hIml
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

VScroll:
	.if sdword ptr eax<0
		xor		eax,eax
	.endif
	push	eax
	invoke SetScrollPos,hWin,SB_VERT,eax,TRUE
	pop		eax
	shl		eax,4
	mov		edx,map.ny
	inc		edx
	shl		edx,9
	sub		edx,map.mapht
	.if eax>edx
		mov		eax,edx
	.endif
	mov		map.topy,eax
	inc		map.paintnow
	retn

HScroll:
	.if sdword ptr eax<0
		xor		eax,eax
	.endif
	push	eax
	invoke SetScrollPos,hWin,SB_HORZ,eax,TRUE
	pop		eax
	shl		eax,4
	mov		edx,map.nx
	inc		edx
	shl		edx,9
	sub		edx,map.mapwt
	.if eax>edx
		mov		eax,edx
	.endif
	mov		map.topx,eax
	inc		map.paintnow
	retn

MapProc endp

WndProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	dwread:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWnd,eax
		fldz
		fstp	map.fSumDist
		invoke GetMenu,hWin
		mov		hMenu,eax
		invoke LoadMenu,hInstance,IDM_CONTEXT
		mov		hContext,eax
		invoke LoadAccelerators,hInstance,IDR_ACCEL
		mov		hAccel,eax
		invoke CheckDlgButton,hWin,IDC_CHKPAUSE,BST_CHECKED
		mov		map.gpslogpause,TRUE
		invoke CheckDlgButton,hWin,IDC_CHKLOCK,BST_CHECKED
		mov		map.gpslock,TRUE
		invoke CheckDlgButton,hWin,IDC_CHKTRAIL,BST_CHECKED
		mov		map.gpstrail,TRUE
		invoke InitPlaces
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
;File
		.if edx==BN_CLICKED || edx==1
			.if eax==IDM_FILE_OPENTRIP
				invoke DialogBoxParam,hInstance,IDD_DLGTRIPLOG,hWin,addr TripLogProc,eax
				.if eax
					invoke OpenTrip,eax
					invoke DoGoto,map.trip.iLon,map.trip.iLat,TRUE,FALSE
					inc		map.paintnow
					mov		map.btrip,2
					mov		map.onpoint,-1
				.endif
			.elseif eax==IDM_FILE_SAVETRIP
				invoke DialogBoxParam,hInstance,IDD_DLGTRIPLOG,hWin,addr TripLogProc,eax
				.if eax
					invoke SaveTrip,eax
				.endif
			.elseif eax==IDM_FILE_OPENDIST
				invoke DialogBoxParam,hInstance,IDD_DLGTRIPLOG,hWin,addr TripLogProc,eax
				.if eax
					invoke OpenDistance,eax
					invoke DoGoto,map.dist.iLon,map.dist.iLat,TRUE,FALSE
					inc		map.paintnow
					mov		map.bdist,2
					mov		map.onpoint,-1
				.endif
			.elseif eax==IDM_FILE_SAVEDIST
				invoke DialogBoxParam,hInstance,IDD_DLGTRIPLOG,hWin,addr TripLogProc,eax
				.if eax
					invoke SaveDistance,eax
				.endif
			.elseif eax==IDM_FILE_OPENTRAIL
				invoke DialogBoxParam,hInstance,IDD_DLGTRIPLOG,hWin,addr TripLogProc,eax
				.if eax
					invoke OpenTrail,eax
					invoke DoGoto,map.trail.iLon,map.trail.iLat,TRUE,FALSE
					inc		map.paintnow
				.endif
			.elseif eax==IDM_FILE_SAVETRAIL
				invoke DialogBoxParam,hInstance,IDD_DLGTRIPLOG,hWin,addr TripLogProc,eax
				.if eax
					invoke SaveTrail,eax
				.endif
			.elseif eax==IDM_FILE_EXIT
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
;Log
			.elseif eax==IDM_LOG_START
				.if !hFileLogWrite
					invoke DialogBoxParam,hInstance,IDD_DLGTRIPLOG,hWin,addr TripLogProc,eax
					.if eax
						invoke strcpy,addr buffer,eax
						mov		map.gpslogpause,FALSE
						invoke CheckDlgButton,hWin,IDC_CHKPAUSE,BST_UNCHECKED
						invoke GetDlgItem,hWin,IDC_CHKPAUSE
						invoke EnableWindow,eax,TRUE
						invoke CreateFile,addr buffer,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
						.if eax!=INVALID_HANDLE_VALUE
							mov		combuff,0
							mov		npos,0
							mov		hFileLogWrite,eax
						.endif
					.endif
				.endif
			.elseif eax==IDM_LOG_END
				.if hFileLogRead
					invoke CloseHandle,hFileLogRead
					mov		hFileLogRead,0
				.endif
				.if hFileLogWrite
					invoke CloseHandle,hFileLogWrite
					mov		hFileLogWrite,0
				.endif
				invoke GetDlgItem,hWin,IDC_CHKPAUSE
				invoke EnableWindow,eax,FALSE
			.elseif eax==IDM_LOG_REPLAY
				.if !hFileLogRead
					invoke DialogBoxParam,hInstance,IDD_DLGTRIPLOG,hWin,addr TripLogProc,eax
					.if eax
						invoke strcpy,addr buffer,eax
						mov		map.gpslogpause,FALSE
						invoke CheckDlgButton,hWin,IDC_CHKPAUSE,BST_UNCHECKED
						invoke GetDlgItem,hWin,IDC_CHKPAUSE
						invoke EnableWindow,eax,TRUE
						invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
						.if eax
							mov		combuff,0
							mov		npos,0
							mov		map.trailhead,0
							mov		map.trailtail,0
							mov		hFileLogRead,eax
						.endif
					.endif
				.endif
			.elseif eax==IDM_LOG_CLEARTRAIL
				mov		eax,map.trailtail
				.if eax!=map.trailhead
					invoke MessageBox,hWin,addr szAskSaveTrail,addr szAppName,MB_YESNOCANCEL or MB_ICONQUESTION
					.if eax!=IDCANCEL
						.if eax==IDYES
							invoke DialogBoxParam,hInstance,IDD_DLGTRIPLOG,hWin,addr TripLogProc,IDM_FILE_SAVETRAIL
							.if eax
								invoke SaveTrail,eax
								mov		map.trailhead,0
								mov		map.trailtail,0
								inc		map.paintnow
								invoke SetDlgItemText,hWin,IDC_EDTDIST,addr szNULL
							.endif
						.else
							mov		map.trailhead,0
							mov		map.trailtail,0
							inc		map.paintnow
							invoke SetDlgItemText,hWin,IDC_EDTDIST,addr szNULL
						.endif
					.endif
				.endif
			.elseif eax==IDM_LOG_STARTSONAR
				.if !sonardata.hLog
					invoke DialogBoxParam,hInstance,IDD_DLGTRIPLOG,hWin,addr TripLogProc,eax
					.if eax
						invoke strcpy,addr buffer,eax
						invoke CreateFile,addr buffer,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
						.if eax!=INVALID_HANDLE_VALUE
							mov		sonardata.hLog,eax
						.endif
					.endif
				.endif
			.elseif eax==IDM_LOG_ENDSONAR
				.if sonardata.hLog
					invoke CloseHandle,sonardata.hLog
					mov		sonardata.hLog,0
				.endif
			.elseif eax==IDM_LOG_REPLAYSONAR
				.if sonardata.hReply
					invoke CloseHandle,sonardata.hReply
					mov		sonardata.hReply,0
					invoke SetScrollPos,hSonar,SB_HORZ,0,TRUE
					mov		sonardata.dptinx,0
					invoke EnableScrollBar,hSonar,SB_HORZ,ESB_DISABLE_BOTH
				.else
					invoke DialogBoxParam,hInstance,IDD_DLGTRIPLOG,hWin,addr TripLogProc,eax
					.if eax
						invoke strcpy,addr buffer,eax
						invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
						.if eax!=INVALID_HANDLE_VALUE
							mov		ebx,eax
							invoke ReadFile,ebx,addr sonarreplay,1,addr dwread,NULL
							invoke SetFilePointer,ebx,0,NULL,FILE_BEGIN
							invoke EnableScrollBar,hSonar,SB_HORZ,ESB_ENABLE_BOTH
							invoke GetFileSize,ebx,NULL
							shr		eax,9
							invoke SetScrollRange,hSonar,SB_HORZ,0,eax,TRUE
							invoke SonarClear
							.if sonarreplay.Version>=200
								mov		npos,0
								mov		map.trailhead,0
								mov		map.trailtail,0
							.endif
							mov		sonardata.dptinx,0
							mov		sonardata.hReply,ebx
						.endif
					.endif
				.endif
;Option
			.elseif eax==IDM_OPTION_SPEED
				invoke DialogBoxParam,hInstance,IDD_DLGOPTION,hWin,addr OptionsProc,0
			.elseif eax==IDM_OPTION_BATTERY
				invoke DialogBoxParam,hInstance,IDD_DLGOPTION,hWin,addr OptionsProc,1
			.elseif eax==IDM_OPTION_AIRTEMP
				invoke DialogBoxParam,hInstance,IDD_DLGOPTION,hWin,addr OptionsProc,2
			.elseif eax==IDM_OPTION_SCALE
				invoke DialogBoxParam,hInstance,IDD_DLGOPTION,hWin,addr OptionsProc,3
			.elseif eax==IDM_OPTION_TIME
				invoke DialogBoxParam,hInstance,IDD_DLGOPTION,hWin,addr OptionsProc,4
			.elseif eax==IDM_OPTION_RANGE
				invoke DialogBoxParam,hInstance,IDD_DLGOPTION,hWin,addr OptionsProc,10
			.elseif eax==IDM_OPTIO_DEPTH
				invoke DialogBoxParam,hInstance,IDD_DLGOPTION,hWin,addr OptionsProc,11
			.elseif eax==IDM_OPTION_WATERTEMP
				invoke DialogBoxParam,hInstance,IDD_DLGOPTION,hWin,addr OptionsProc,12
			.elseif eax==IDM_OPTION_COMPORT
				invoke DialogBoxParam,hInstance,IDD_DLGCOMPORT,hWin,addr ComOptionProc,0
			.elseif eax==IDM_OPTION_SONAR
				invoke CreateDialogParam,hInstance,IDD_DLGSONAR,hWin,addr SonarOptionProc,0
			.elseif eax==IDM_OPTION_GAIN
				invoke DialogBoxParam,hInstance,IDD_DLGSONARGAIN,hWin,addr SonarGainOptionProc,0
;Context
			.elseif eax==IDM_EDITPLACE
				invoke DialogBoxParam,hInstance,IDD_DLGADDPLACE,hWin,addr AddPlaceProc,nPlace
				inc		map.paintnow
			.elseif eax==IDM_ADDPLACE
				invoke DialogBoxParam,hInstance,IDD_DLGADDPLACE,hWin,addr AddPlaceProc,-1
			.elseif eax==IDM_TRIPPLANNING
				mov		map.btrip,1
				mov		map.onpoint,-1
			.elseif eax==IDM_DISTANCE
				mov		map.bdist,1
				mov		map.onpoint,-1
			.elseif eax==IDM_FULLSCREEN
				invoke GetParent,hMap
				.if eax==hWin
					invoke ShowWindow,hMap,SW_HIDE
					invoke SetParent,hMap,0
					invoke ShowWindow,hMap,SW_SHOWMAXIMIZED
				.else
					invoke SetParent,hMap,hWin
					invoke ShowWindow,hWin,SW_RESTORE
				.endif
				invoke SetActiveWindow,hMap
			.elseif eax==IDM_TRIP_DONE
				.if map.btrip==1 || map.btrip==3
					mov		map.btrip,2
					.if map.triphead
						mov		eax,map.triphead
						dec		eax
						invoke GetDistance,addr map.trip,eax
					.endif
					inc		map.paintnow
				.else
					mov		map.btrip,1
				.endif
			.elseif eax==IDM_TRIP_SAVE
				invoke DialogBoxParam,hInstance,IDD_DLGTRIPLOG,hWin,addr TripLogProc,IDM_FILE_SAVETRIP
				.if eax
					invoke SaveTrip,eax
				.endif
			.elseif eax==IDM_TRIP_EDIT
				.if map.triphead
					.if map.btrip==3
						mov		map.btrip,1
					.else
						mov		map.btrip,3
					.endif
					inc		map.paintnow
				.endif
			.elseif eax==IDM_TRIP_CLEAR
				mov		map.btrip,0
				mov		map.triphead,0
				inc		map.paintnow
				invoke SetDlgItemText,hWin,IDC_EDTDIST,addr szNULL
			.elseif eax==IDM_TRIP_INSERT
				invoke InsertPoint,map.onpoint,addr map.trip,addr map.triphead
			.elseif eax==IDM_TRIP_DELETE
				invoke DeletePoint,map.onpoint,addr map.trip,addr map.triphead
			.elseif eax==IDM_DIST_DONE
				.if map.bdist==1 || map.bdist==3
					mov		map.bdist,2
					.if map.disthead
						mov		eax,map.disthead
						dec		eax
						invoke GetDistance,addr map.dist,eax
					.endif
					inc		map.paintnow
				.else
					mov		map.bdist,1
				.endif
			.elseif eax==IDM_DIST_SAVE
				invoke DialogBoxParam,hInstance,IDD_DLGTRIPLOG,hWin,addr TripLogProc,IDM_FILE_SAVEDIST
				.if eax
					invoke SaveDistance,eax
				.endif
			.elseif eax==IDM_DIST_EDIT
				.if map.disthead
					.if map.bdist==3
						mov		map.bdist,1
					.else
						mov		map.bdist,3
					.endif
					inc		map.paintnow
				.endif
			.elseif eax==IDM_DIST_CLEAR
				mov		map.bdist,0
				mov		map.disthead,0
				inc		map.paintnow
				invoke SetDlgItemText,hWin,IDC_EDTDIST,addr szNULL
			.elseif eax==IDM_DIST_INSERT
				invoke InsertPoint,map.onpoint,addr map.dist,addr map.disthead
			.elseif eax==IDM_DIST_DELETE
				invoke DeletePoint,map.onpoint,addr map.dist,addr map.disthead
			.elseif eax==IDM_SONARCLEAR
				invoke SonarClear
			.elseif eax==IDM_SONARPAUSE
				invoke IsDlgButtonChecked,hWin,IDC_CHKCHART
				.if eax
					mov		eax,BST_UNCHECKED
				.else
					mov		eax,BST_CHECKED
				.endif
				invoke CheckDlgButton,hWin,IDC_CHKCHART,eax
;Buttons
			.elseif eax==IDC_BTNZOOMIN
				mov		eax,map.zoominx
				.if eax
					dec		eax
					invoke ZoomMap,eax
				.endif
			.elseif eax==IDC_BTNZOOMOUT
				mov		eax,map.zoominx
				inc		eax
				.if eax<32
					mov		edx,sizeof ZOOM
					mul		edx
					mov		ebx,eax
					.if map.zoom.zoomval[ebx]
						mov		eax,map.zoominx
						inc		eax
						invoke ZoomMap,eax
					.endif
				.endif
			.elseif eax==IDC_BTNMAP
				xor		ebx,ebx
				mov		esi,offset bmpcache
				.while ebx<MAXBMP
					.if [esi].BMP.hBmp
						invoke DeleteObject,[esi].BMP.hBmp
						mov		[esi].BMP.hBmp,0
						mov		[esi].BMP.inuse,0
					.endif
					lea		esi,[esi+sizeof BMP]
					inc		ebx
				.endw
				.if fSeaMap
					invoke strcpy,addr szFileName,addr szLandFileName
					mov		fSeaMap,FALSE
				.else
					invoke strcpy,addr szFileName,addr szSeaFileName
					mov		fSeaMap,TRUE
				.endif
				inc		map.paintnow
			.elseif eax==IDC_CHKPAUSE
				invoke IsDlgButtonChecked,hWin,IDC_CHKPAUSE
				mov		map.gpslogpause,eax
			.elseif eax==IDC_CHKLOCK
				invoke IsDlgButtonChecked,hWin,IDC_CHKLOCK
				mov		map.gpslock,eax
				inc		map.paintnow
			.elseif eax==IDC_CHKTRAIL
				invoke IsDlgButtonChecked,hWin,IDC_CHKTRAIL
				mov		map.gpstrail,eax
				inc		map.paintnow
			.elseif eax==IDC_CHKGRID
				invoke IsDlgButtonChecked,hWin,IDC_CHKGRID
				mov		map.mapgrid,eax
				inc		map.paintnow
			.elseif eax==IDC_CBOGOTOPLACE
				invoke SendDlgItemMessage,hWin,IDC_CBOGOTOPLACE,CB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_CBOGOTOPLACE,CB_GETITEMDATA,eax,0
				invoke DoGoto,[eax].PLACE.iLon,[eax].PLACE.iLat,TRUE,FALSE
				inc		map.paintnow
			.endif
		.endif
	.elseif eax==WM_INITMENUPOPUP
		mov		edx,MF_BYCOMMAND or MF_ENABLED
		.if !map.triphead
			mov		edx,MF_BYCOMMAND or MF_GRAYED
		.endif
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVETRIP,edx
		mov		edx,MF_BYCOMMAND or MF_ENABLED
		.if !map.disthead
			mov		edx,MF_BYCOMMAND or MF_GRAYED
		.endif
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVEDIST,edx
		mov		eax,map.trailtail
		mov		edx,MF_BYCOMMAND or MF_ENABLED
		.if eax==map.trailhead
			mov		edx,MF_BYCOMMAND or MF_GRAYED
		.endif
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVETRAIL,edx
		mov		edx,MF_BYCOMMAND or MF_ENABLED
		.if hFileLogWrite || !hCom
			mov		edx,MF_BYCOMMAND or MF_GRAYED
		.endif
		invoke EnableMenuItem,hMenu,IDM_LOG_START,edx
		mov		edx,MF_BYCOMMAND or MF_GRAYED
		.if hFileLogRead || hFileLogWrite
			mov		edx,MF_BYCOMMAND or MF_ENABLED
		.endif
		invoke EnableMenuItem,hMenu,IDM_LOG_END,edx
		mov		edx,MF_BYCOMMAND or MF_ENABLED
		.if hFileLogRead
			mov		edx,MF_BYCOMMAND or MF_GRAYED
		.endif
		invoke EnableMenuItem,hMenu,IDM_LOG_REPLAY,edx
		mov		eax,map.trailtail
		mov		edx,MF_BYCOMMAND or MF_ENABLED
		.if eax==map.trailhead
			mov		edx,MF_BYCOMMAND or MF_GRAYED
		.endif
		invoke EnableMenuItem,hMenu,IDM_LOG_CLEARTRAIL,edx
		mov		edx,MF_BYCOMMAND or MF_ENABLED
		.if sonardata.hLog
			mov		edx,MF_BYCOMMAND or MF_GRAYED
		.endif
		invoke EnableMenuItem,hMenu,IDM_LOG_STARTSONAR,edx
		mov		edx,MF_BYCOMMAND or MF_ENABLED
		.if !sonardata.hLog
			mov		edx,MF_BYCOMMAND or MF_GRAYED
		.endif
		invoke EnableMenuItem,hMenu,IDM_LOG_ENDSONAR,edx
	.elseif eax==WM_KEYDOWN || eax==WM_MOUSEWHEEL
		invoke SendMessage,hMap,uMsg,wParam,lParam
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		sub		rect.right,95
		invoke GetParent,hMap
		.if eax==hWin
			mov		ebx,sonardata.wt
			sub		rect.right,ebx
			invoke MoveWindow,hSonar,rect.right,0,ebx,rect.bottom,TRUE
			sub		rect.right,4
			invoke MoveWindow,hMap,0,0,rect.right,rect.bottom,TRUE
			add		rect.right,ebx
			add		rect.right,4
		.endif
		add		rect.right,8
		invoke GetDlgItem,hWin,IDC_BTNZOOMIN
		invoke MoveWindow,eax,rect.right,rect.top,80,25,TRUE
		add		rect.top,27
		invoke GetDlgItem,hWin,IDC_BTNZOOMOUT
		invoke MoveWindow,eax,rect.right,rect.top,80,25,TRUE
		add		rect.top,27
		invoke GetDlgItem,hWin,IDC_BTNMAP
		invoke MoveWindow,eax,rect.right,rect.top,80,25,TRUE
		add		rect.top,27
		invoke GetDlgItem,hWin,IDC_CHKPAUSE
		invoke MoveWindow,eax,rect.right,rect.top,80,16,TRUE
		add		rect.top,17
		invoke GetDlgItem,hWin,IDC_CHKLOCK
		invoke MoveWindow,eax,rect.right,rect.top,80,16,TRUE
		add		rect.top,17
		invoke GetDlgItem,hWin,IDC_CHKTRAIL
		invoke MoveWindow,eax,rect.right,rect.top,80,16,TRUE
		add		rect.top,17
		invoke GetDlgItem,hWin,IDC_CHKGRID
		invoke MoveWindow,eax,rect.right,rect.top,80,16,TRUE
		add		rect.top,17
		invoke GetDlgItem,hWin,IDC_CBOGOTOPLACE
		invoke MoveWindow,eax,rect.right,rect.top,80,200,TRUE
		add		rect.top,25
		invoke GetDlgItem,hWin,IDC_STCLAT
		invoke MoveWindow,eax,rect.right,rect.top,80,16,TRUE
		add		rect.top,17
		invoke GetDlgItem,hWin,IDC_EDTNORTH
		invoke MoveWindow,eax,rect.right,rect.top,80,16,TRUE
		add		rect.top,17
		invoke GetDlgItem,hWin,IDC_STCLON
		invoke MoveWindow,eax,rect.right,rect.top,80,16,TRUE
		add		rect.top,17
		invoke GetDlgItem,hWin,IDC_EDTEAST
		invoke MoveWindow,eax,rect.right,rect.top,80,16,TRUE
		add		rect.top,17
		invoke GetDlgItem,hWin,IDC_STCDIST
		invoke MoveWindow,eax,rect.right,rect.top,80,16,TRUE
		add		rect.top,17
		invoke GetDlgItem,hWin,IDC_EDTDIST
		invoke MoveWindow,eax,rect.right,rect.top,80,16,TRUE
		add		rect.top,17
		invoke GetDlgItem,hWin,IDC_STCBEAR
		invoke MoveWindow,eax,rect.right,rect.top,80,16,TRUE
		add		rect.top,17
		invoke GetDlgItem,hWin,IDC_EDTBEAR
		invoke MoveWindow,eax,rect.right,rect.top,80,16,TRUE
		add		rect.top,30
		invoke GetDlgItem,hWin,IDC_SHP3
		mov		edx,rect.right
		sub		edx,7
		invoke MoveWindow,eax,edx,rect.top,95,3,TRUE
		add		rect.top,13
		invoke GetDlgItem,hWin,IDC_CHKCHART
		invoke MoveWindow,eax,rect.right,rect.top,80,16,TRUE
		add		rect.top,17
	.elseif eax==WM_MOUSEMOVE
		invoke GetClientRect,hWin,addr rect
		invoke GetCapture
		mov		edx,lParam
		movsx	ecx,dx
		shr		edx,16
		movsx	edx,dx
		.if eax==hWin
			mov		eax,rect.right
			sub		eax,95
			sub		eax,ecx
			.if sdword ptr eax<100
				mov		eax,100
			.elseif sdword ptr eax>MAXXECHO+RANGESCALE+SIGNALBAR+4
				mov		eax,MAXXECHO+RANGESCALE+SIGNALBAR+4
			.endif
			.if eax!=sonardata.wt
				mov		sonardata.wt,eax
				invoke SendMessage,hWin,WM_SIZE,0,0
			.endif
		.else
			mov		eax,rect.right
			sub		eax,ecx
			.if eax>100
				invoke SetCursor,hSplittV
			.endif
		.endif
	.elseif eax==WM_LBUTTONDOWN
		invoke GetClientRect,hWin,addr rect
		mov		edx,lParam
		movsx	ecx,dx
		shr		edx,16
		movsx	edx,dx
		mov		eax,rect.right
		sub		eax,ecx
		.if eax>100
			invoke SetCursor,hSplittV
			invoke SetCapture,hWin
		.endif
	.elseif eax==WM_LBUTTONUP
		invoke GetCapture
		.if eax==hWin
			invoke ReleaseCapture
		.endif
	.elseif eax==WM_CLOSE
		invoke SaveStatus
		invoke ShowWindow,hWin,SW_HIDE
		mov		fExitGpsThread,TRUE
		invoke WaitForSingleObject,hGpsThread,3000
		invoke CloseHandle,hGpsThread
		mov		fExitMapThread,TRUE
		invoke WaitForSingleObject,hMapThread,3000
		invoke CloseHandle,hMapThread
		invoke GlobalFree,map.hMemLon
		invoke GlobalFree,map.hMemLat
		invoke DestroyWindow,hWin
	.elseif eax==WM_DESTROY
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

WndProc endp

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	invoke RtlZeroMemory,addr wc,sizeof WNDCLASSEX
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,IDM_MENU
	mov		wc.lpszClassName,offset ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset MapProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,0
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szMapClassName
	mov		wc.hIcon,NULL
	mov		wc.hIconSm,NULL
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc

	mov		wc.lpfnWndProc,offset SonarProc
	mov		wc.lpszClassName,offset szSonarClassName
	invoke RegisterClassEx,addr wc

	invoke LoadMapPoints
	invoke InitZoom
	invoke InitOptions
	invoke InitFonts
	invoke InitMaps
	invoke CreateDialogParam,hInstance,IDD_DIALOG,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	invoke InitCom
	;Create thread thst comunicates with the GPS
	invoke CreateThread,NULL,0,addr DoComm,0,0,addr tid
	mov		hGpsThread,eax
	;Create thread that paints the map
	invoke CreateThread,NULL,0,addr PaintMap,0,0,addr tid
	mov		hMapThread,eax
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke TranslateAccelerator,hWnd,hAccel,addr msg
		.if !eax
			invoke TranslateMessage,addr msg
			invoke DispatchMessage,addr msg
		.endif
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke GetCommandLine
	mov		CommandLine,eax
	invoke InitCommonControls
	invoke GetModuleFileName,hInstance,addr szIniFileName,sizeof szIniFileName
	.while szIniFileName[eax]!='\' && eax
		dec		eax
	.endw
	push	eax
	invoke strcpyn,addr szAppPath,addr szIniFileName,addr [eax+1]
	pop		eax
	invoke strcpy,addr szIniFileName[eax+1],addr szIniFile
	invoke strcpy,addr szFileName,addr szLandFileName
	; Initialize GDI+ Librery
    mov     gdiplSTI.GdiplusVersion,1
    mov		gdiplSTI.DebugEventCallback,NULL
    mov		gdiplSTI.SuppressBackgroundThread,FALSE
    mov		gdiplSTI.SuppressExternalCodecs,FALSE
	invoke GdiplusStartup,offset token,offset gdiplSTI,NULL
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	invoke GdiplusShutdown,token
	invoke ExitProcess,eax

end start
