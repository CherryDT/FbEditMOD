
.data?

nPlace				DWORD ?

.code

InitPlaces proc uses ebx esi
	LOCAL	buffer[256]:BYTE

	mov		esi,offset map.place
	invoke RtlZeroMemory,esi,sizeof MAP.place
	invoke SendDlgItemMessage,hWnd,IDC_CBOGOTOPLACE,CB_RESETCONTENT,0,0
	xor		ebx,ebx
	.while ebx<MAXPLACES
		invoke BinToDec,ebx,addr buffer
		invoke GetPrivateProfileString,addr szIniPlace,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr szIniFileName
		.break .if !eax
		invoke GetItemInt,addr buffer,0
		mov		[esi].PLACE.font,eax
		invoke GetItemInt,addr buffer,0
		mov		[esi].PLACE.icon,eax
		invoke GetItemInt,addr buffer,0
		mov		[esi].PLACE.zoom,eax
		invoke GetItemInt,addr buffer,0
		mov		[esi].PLACE.iLon,eax
		invoke GetItemInt,addr buffer,0
		mov		[esi].PLACE.iLat,eax
		invoke strcpyn,addr [esi].PLACE.text,addr buffer,sizeof PLACE.text
		.if [esi].PLACE.text
			invoke SendDlgItemMessage,hWnd,IDC_CBOGOTOPLACE,CB_ADDSTRING,0,addr [esi].PLACE.text
			invoke SendDlgItemMessage,hWnd,IDC_CBOGOTOPLACE,CB_SETITEMDATA,eax,esi
		.endif
		lea		esi,[esi+sizeof PLACE]
		inc		ebx
	.endw
	mov		map.freeplace,ebx
	invoke SendDlgItemMessage,hWnd,IDC_CBOGOTOPLACE,CB_SETCURSEL,0,0
	ret

InitPlaces endp

;Find a place based on Longitude and Lattitude
FindPlace proc uses ebx esi,iLon:DWORD,iLat:DWORD
	LOCAL	xmin:DWORD
	LOCAL	ymin:DWORD
	LOCAL	xmax:DWORD
	LOCAL	ymax:DWORD

	;Allow for some offsets
	mov		eax,iLon
	lea		edx,[eax-300]
	mov		xmin,edx
	lea		edx,[eax+300]
	mov		xmax,edx
	mov		eax,iLat
	lea		edx,[eax-100]
	mov		ymin,edx
	lea		edx,[eax+100]
	mov		ymax,edx
	xor		ebx,ebx
	mov		esi,offset map.place
	.while ebx<map.freeplace
		mov		ecx,[esi].PLACE.iLon
		mov		edx,[esi].PLACE.iLat
		.if ecx>=xmin && ecx<=xmax && edx>=ymin && edx<=ymax
			mov		eax,ebx
			jmp		Ex
		.endif 
		lea		esi,[esi+sizeof PLACE]
		inc		ebx
	.endw
	mov		eax,-1
  Ex:
	ret

FindPlace endp

AddPlaceProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	x:DWORD
	LOCAL	y:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffname[256]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,lParam
		mov		nPlace,eax
		invoke SendDlgItemMessage,hWin,IDC_EDTNAME,EM_LIMITTEXT,31,0
		invoke SendDlgItemMessage,hWin,IDC_EDTLONGITUDE,EM_LIMITTEXT,9,0
		invoke SendDlgItemMessage,hWin,IDC_EDTLATTITUDE,EM_LIMITTEXT,8,0
		mov		esi,offset szFonts
		.while byte ptr [esi]
			invoke SendDlgItemMessage,hWin,IDC_CBOFONT,CB_ADDSTRING,0,esi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
		.endw
		mov		esi,offset szIcons
		.while byte ptr [esi]
			invoke SendDlgItemMessage,hWin,IDC_CBOICON,CB_ADDSTRING,0,esi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
		.endw
		invoke SendDlgItemMessage,hWin,IDC_TRBZOOM,TBM_SETRANGE,0,(MAXZOOM -1) shl 16
		invoke SendDlgItemMessage,hWin,IDC_TRBZOOM,TBM_SETLINESIZE,0,1
		invoke SendDlgItemMessage,hWin,IDC_TRBZOOM,TBM_SETPAGESIZE,0,4
		.if nPlace==-1
			;New place
			invoke ScrnPosToMapPos,mousept.x,mousept.y,addr x,addr y
			invoke MapPosToGpsPos,x,y,addr x,addr y
			invoke SetDlgItemInt,hWin,IDC_EDTLONGITUDE,x,TRUE
			invoke SetDlgItemInt,hWin,IDC_EDTLATTITUDE,y,TRUE
			invoke SendDlgItemMessage,hWin,IDC_CBOFONT,CB_SETCURSEL,0,0
			invoke SendDlgItemMessage,hWin,IDC_CBOICON,CB_SETCURSEL,0,0
		.else
			;Edit place
			mov		ebx,nPlace
			mov		eax,sizeof PLACE
			mul		ebx
			mov		ebx,eax
			invoke SetDlgItemText,hWin,IDC_EDTNAME,addr map.place.text[ebx]
			invoke SetDlgItemInt,hWin,IDC_EDTLONGITUDE,map.place.iLon[ebx],TRUE
			invoke SetDlgItemInt,hWin,IDC_EDTLATTITUDE,map.place.iLat[ebx],TRUE
			invoke SendDlgItemMessage,hWin,IDC_CBOFONT,CB_SETCURSEL,map.place.font[ebx],0
			invoke SendDlgItemMessage,hWin,IDC_CBOICON,CB_SETCURSEL,map.place.icon[ebx],0
			invoke SendDlgItemMessage,hWin,IDC_TRBZOOM,TBM_SETPOS,TRUE,map.place.zoom[ebx]
		.endif
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				;Font,Icon,Zoom,Longitude,Lattitude,Name
				mov		buffer,0
				invoke SendDlgItemMessage,hWin,IDC_CBOFONT,CB_GETCURSEL,0,0
				invoke PutItemInt,addr buffer,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOICON,CB_GETCURSEL,0,0
				invoke PutItemInt,addr buffer,eax
				invoke SendDlgItemMessage,hWin,IDC_TRBZOOM,TBM_GETPOS,0,0
				invoke PutItemInt,addr buffer,eax
				invoke GetDlgItemInt,hWin,IDC_EDTLONGITUDE,0,TRUE
				invoke PutItemInt,addr buffer,eax
				invoke GetDlgItemInt,hWin,IDC_EDTLATTITUDE,0,TRUE
				invoke PutItemInt,addr buffer,eax
				invoke GetDlgItemText,hWin,IDC_EDTNAME,addr buffname,sizeof buffname
				invoke PutItemStr,addr buffer,addr buffname
				.if nPlace==-1
					invoke BinToDec,map.freeplace,addr buffname
				.else
					invoke BinToDec,nPlace,addr buffname
				.endif
				invoke WritePrivateProfileString,addr szIniPlace,addr buffname,addr buffer[1],addr szIniFileName
				invoke InitPlaces
				invoke SendMessage,hWin,WM_CLOSE,NULL,TRUE
				inc		map.paintnow
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,FALSE
			.elseif eax==IDC_BTNGPS
				invoke SetDlgItemInt,hWin,IDC_EDTLONGITUDE,map.iLon,TRUE
				invoke SetDlgItemInt,hWin,IDC_EDTLATTITUDE,map.iLat,TRUE
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

AddPlaceProc endp
