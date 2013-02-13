
;StringEdit.dlg
IDD_DLGNAMES		equ 1400
IDC_GRDNME			equ 1001
IDC_BTNNMEADD		equ 1002
IDC_BTNNMEDEL		equ 1003
IDC_BTNNMEEXPORT	equ 1004

.const

szExportAs			db 'Export Names As',0
INmeGrdSize			dd 0,0,18,182,40          ; MOD 17.3.2012   0,0,18,122,0

.data?

nExportType			dd ?
szExportFileName	db MAX_PATH dup(?)
szUserDefined		db MAX_PATH dup(?)
NmeGrdSize			dd 5 dup(?)

.code

ExportNamesNames proc uses esi edi,hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	mov		edi,eax
	invoke GlobalLock,edi
	push	edi
	mov		esi,hMem
	.while byte ptr [esi].NAMEMEM.szname || [esi].NAMEMEM.value
		.if ![esi].NAMEMEM.delete
			invoke ExportName,addr [esi].NAMEMEM.szname,[esi].NAMEMEM.value,edi
			lea		edi,[edi+eax]
		.endif
		add		esi,sizeof NAMEMEM
	.endw
	pop		eax
	ret

ExportNamesNames endp

UpdateNames proc uses ebx esi,hWin:HWND
	LOCAL	hGrd:HWND
	LOCAL	lpProMem:DWORD
	LOCAL	nRows:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	val:DWORD
	LOCAL	fChanged:DWORD

	invoke GetWindowLong,hPrj,0
	mov		lpProMem,eax
	invoke GetDlgItem,hWin,IDC_GRDNME
	mov		hGrd,eax
	invoke SendMessage,hGrd,GM_GETROWCOUNT,0,0
	mov		nRows,eax
	xor		ebx,ebx
	.while ebx<nRows
		;Name
		mov		ecx,ebx
		shl		ecx,16
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr val
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,3
		invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
		.if val
			invoke strcmp,val,addr buffer
			.if eax
				invoke strcpy,val,addr buffer
				mov		fChanged,TRUE
			.endif
			;ID
			mov		ecx,ebx
			shl		ecx,16
			add		ecx,1
			invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr val
			mov		ecx,ebx
			shl		ecx,16
			add		ecx,4
			invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
			mov		edx,val
			mov		eax,dword ptr buffer
			.if eax!=[edx]
				mov		[edx],eax
				mov		fChanged,TRUE
			.endif
		.else
			.if buffer
				mov		ecx,ebx
				shl		ecx,16
				add		ecx,4
				invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr val
				invoke ResEdBinToDec,val,addr buffer[64]
				invoke AddName,lpProMem,addr buffer,addr buffer[64]
				mov		fChanged,TRUE
			.endif
		.endif
		inc		ebx
	.endw
	.if fChanged
		invoke GetWindowLong,hPrj,0
		mov		esi,eax
		.while [esi].PROJECT.hmem
			mov		eax,[esi].PROJECT.ntype
			.if eax==TPE_DIALOG
				mov		ebx,[esi].PROJECT.hmem
				lea		ebx,[ebx+sizeof DLGHEAD]
				mov		ecx,[ebx].DIALOG.id
				lea		edx,[ebx].DIALOG.idname
				call	UpdateProject
			.elseif eax==TPE_MENU
				mov		ebx,[esi].PROJECT.hmem
				mov		ecx,[ebx].MNUHEAD.menuid
				lea		edx,[ebx].MNUHEAD.menuname
				call	UpdateProject
			.elseif eax==TPE_ACCEL
				mov		ebx,[esi].PROJECT.hmem
				mov		ecx,[ebx].ACCELMEM.value
				lea		edx,[ebx].ACCELMEM.szname
				call	UpdateProject
			.endif
			add		esi,sizeof PROJECT
		.endw
		invoke SendMessage,hRes,PRO_SETMODIFY,TRUE,0
		invoke GetWindowLong,hPrp,0
		invoke GetWindowLong,eax,GWL_USERDATA
		.if eax
			invoke PropertyList,eax
		.endif
	.endif
	ret

UpdateProject:
	.if byte ptr [edx]
		invoke strcpy,addr buffer,edx
	.else
		invoke ResEdBinToDec,ecx,addr buffer
	.endif
	invoke SetProjectItemName,esi,addr buffer
	retn

UpdateNames endp

SaveNamesToFile proc uses ebx esi edi,hWin:HWND,fNoSaveDialog:DWORD
	LOCAL	hGrd:HWND
	LOCAL	nRows:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	tmpbuffer[MAX_PATH]:BYTE
	LOCAL	fnbuffer[MAX_PATH]:BYTE
	LOCAL	val:DWORD
	LOCAL	ofn:OPENFILENAME
	LOCAL	hFile:DWORD
	LOCAL	hMem:HGLOBAL

	mov		eax,nExportType
	shr		eax,16
	.if !eax
		.if !fNoSaveDialog
			;Zero out the ofn struct
			invoke RtlZeroMemory,addr ofn,sizeof ofn
			mov		ofn.lStructSize,sizeof ofn
			push	hWin
			pop		ofn.hwndOwner
			push	hInstance
			pop		ofn.hInstance
			mov		ofn.lpstrTitle,offset szExportAs
			mov		ofn.lpstrInitialDir,offset szProjectPath
			mov		ofn.lpstrFileTitle,offset szExportFileName
			call	GetFileName
			invoke strcpy,addr fnbuffer,addr tmpbuffer
			lea		eax,fnbuffer
			mov		ofn.lpstrFile,eax
			mov		ofn.nMaxFile,sizeof fnbuffer
			mov		ofn.lpstrDefExt,NULL
			mov		ofn.Flags,OFN_OVERWRITEPROMPT or OFN_HIDEREADONLY
			;Show the Save dialog
			invoke GetSaveFileName,addr ofn
		.else
			call	GetFileName
			invoke strcpy,addr fnbuffer,addr szProjectPath
			invoke strcat,addr fnbuffer,addr szBS
			invoke strcat,addr fnbuffer,addr tmpbuffer
			xor		eax,eax
			inc		eax
		.endif
	.endif
	.if eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
		mov		hMem,eax
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
		mov		edi,eax
		invoke GlobalLock,edi
		push	edi
		invoke GetDlgItem,hWin,IDC_GRDNME
		mov		hGrd,eax
		invoke SendMessage,hGrd,GM_GETROWCOUNT,0,0
		mov		nRows,eax
		xor		ebx,ebx
		.while ebx<nRows
			;Name
			mov		ecx,ebx
			shl		ecx,16
			add		ecx,3
			invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
			.if buffer
				invoke IsNameDefault,addr buffer
				.if !eax
					;ID
					mov		ecx,ebx
					shl		ecx,16
					add		ecx,4
					invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr val
					.if val
						mov		esi,hMem
						.while byte ptr [esi].NAMEMEM.szname || [esi].NAMEMEM.value
							mov		eax,val
							.if eax==[esi].NAMEMEM.value
								invoke strcmp,addr buffer,addr [esi].NAMEMEM.szname
								.if !eax
									jmp		Nxt
								.endif
							.endif
							add		esi,sizeof NAMEMEM
						.endw
						invoke strcpy,addr [esi].NAMEMEM.szname,addr buffer
						mov		eax,val
						mov		[esi].NAMEMEM.value,eax
						movzx	eax,word ptr nExportType
						.if eax==0
							;Asm
							invoke SaveStr,edi,addr buffer
							add		edi,eax
							.if eax<23
								mov		ecx,23
								sub		ecx,eax
								mov		al,' '
								rep stosb
							.endif
							mov		al,' '
							stosb
							mov		eax,' uqe'
							stosd
							invoke SaveVal,val,FALSE
							mov		al,0Dh
							stosb
							mov		al,0Ah
							stosb
						.elseif eax==1
							;C
							invoke SaveStr,edi,offset szDEFINE
							add		edi,eax
							mov		al,' '
							stosb
							invoke SaveStr,edi,addr buffer
							add		edi,eax
							.if eax<23
								mov		ecx,23
								sub		ecx,eax
								mov		al,' '
								rep stosb
							.endif
							mov		al,' '
							stosb
							invoke SaveVal,val,FALSE
							mov		al,0Dh
							stosb
							mov		al,0Ah
							stosb
						.elseif eax==2
							;Hla
							invoke SaveStr,edi,addr buffer
							add		edi,eax
							.if eax<23
								mov		ecx,23
								sub		ecx,eax
								mov		al,' '
								rep stosb
							.endif
							mov		eax,' =: '
							stosd
							invoke SaveVal,val,FALSE
							mov		al,';'
							stosb
							mov		al,0Dh
							stosb
							mov		al,0Ah
							stosb
						.elseif eax==3
							;PureBasic
							mov		al,'#'
							stosb
							invoke SaveStr,edi,addr buffer
							add		edi,eax
							mov		eax,' = '
							stosd
							dec		edi
							invoke SaveVal,val,FALSE
							mov		al,0Dh
							stosb
							mov		al,0Ah
							stosb
						.elseif eax==4
							;PowerBasic
							mov		al,'%'
							stosb
							invoke SaveStr,edi,addr buffer
							add		edi,eax
							mov		eax,' = '
							stosd
							dec		edi
							invoke SaveVal,val,FALSE
							mov		al,0Dh
							stosb
							mov		al,0Ah
							stosb
						.elseif eax==5
							;User defined
							push	esi
							push	edi
							mov		esi,offset szUserDefined
							lea		edi,tmpbuffer
							.while byte ptr [esi]
								mov		al,[esi]
								.if al=='%'
									mov		edx,dword ptr [esi+1]
									and		edx,5F5F5F5Fh
									.if edx=='EMAN'
										;Name
										add		esi,5
										invoke SaveStr,edi,addr buffer
										add		edi,eax
									.elseif dx=='DI'
										;ID
										add		esi,3
										invoke SaveVal,val,FALSE
									.else
										mov		[edi],al
										inc		esi
										inc		edi
									.endif
								.else
									mov		[edi],al
									inc		esi
									inc		edi
								.endif
							.endw
							mov		byte ptr [edi],0
							pop		edi
							pop		esi
							invoke SaveStr,edi,addr tmpbuffer
							add		edi,eax
							mov		al,0Dh
							stosb
							mov		al,0Ah
							stosb
						.endif
					.endif
				.endif
			.endif
		  Nxt:
			inc		ebx
		.endw
		mov		byte ptr [edi],0
		pop		edi
		mov		eax,nExportType
		shr		eax,16
		.if !eax
			invoke CreateFile,addr fnbuffer,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
			.if eax!=INVALID_HANDLE_VALUE
				mov		hFile,eax
				invoke strlen,edi
				mov		edx,eax
				invoke WriteFile,hFile,edi,edx,addr buffer,NULL
				invoke CloseHandle,hFile
			.endif
		.elseif eax==1
			invoke strlen,edi
			invoke ClipDataSet,edi,eax
		.elseif eax==2
			invoke SendMessage,hExportOut,WM_SETTEXT,0,edi
		.endif
		invoke GlobalUnlock,edi
		invoke GlobalFree,edi
		invoke GlobalFree,hMem
	.endif
	ret

GetFileName:
	invoke strcpyn,addr tmpbuffer,offset szExportFileName,10
	invoke strcmpi,addr tmpbuffer,offset szProject
	.if !eax
		lea		edx,tmpbuffer
		mov		ecx,offset szResourceh
		.while byte ptr [ecx]!='.'
			mov		al,[ecx]
			mov		[edx],al
			inc		ecx
			inc		edx
		.endw
		mov		eax,offset szExportFileName+9
		invoke strcpy,edx,eax
	.else
		invoke strcpy,addr tmpbuffer,offset szExportFileName
	.endif
	retn

SaveNamesToFile endp

NameEditProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hGrd:HWND
	LOCAL	hMem:DWORD
	LOCAL	col:COLUMN
	LOCAL	row[5]:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke InitGridSize,5,offset INmeGrdSize,offset NmeGrdSize
		invoke GetDlgItem,hWin,IDC_GRDNME
		mov		hGrd,eax
		invoke SendMessage,hWin,WM_GETFONT,0,0
		invoke SendMessage,hGrd,WM_SETFONT,eax,FALSE
		invoke SendMessage,hGrd,GM_SETBACKCOLOR,color.back,0
		invoke SendMessage,hGrd,GM_SETTEXTCOLOR,color.text,0
		invoke ConvertDpiSize,18
		push	eax
		invoke SendMessage,hGrd,GM_SETHDRHEIGHT,0,eax
		pop		eax
		invoke SendMessage,hGrd,GM_SETROWHEIGHT,0,eax
		;lpName
		mov		col.colwt,0
		mov		col.lpszhdrtext,NULL
		mov		col.halign,GA_ALIGN_RIGHT
		mov		col.calign,GA_ALIGN_RIGHT
		mov		col.ctype,TYPE_EDITLONG
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;lpID
		mov		col.colwt,0
		mov		col.lpszhdrtext,NULL
		mov		col.halign,GA_ALIGN_RIGHT
		mov		col.calign,GA_ALIGN_RIGHT
		mov		col.ctype,TYPE_EDITLONG
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Image
		mov		eax,NmeGrdSize[8]
		mov		col.colwt,eax
		mov		col.lpszhdrtext,NULL
		mov		col.halign,GA_ALIGN_CENTER
		mov		col.calign,GA_ALIGN_CENTER
		mov		col.ctype,TYPE_IMAGE
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		eax,hPrjIml
		mov		col.himl,eax
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Name
		mov		eax,NmeGrdSize[12]
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrName
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,MaxName-1
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;ID
		mov		eax,NmeGrdSize[16]
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrID
		mov		col.halign,GA_ALIGN_RIGHT
		mov		col.calign,GA_ALIGN_RIGHT
		mov		col.ctype,TYPE_EDITLONG
		mov		col.ctextmax,5
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		invoke GetWindowLong,hPrj,0
		mov		esi,eax
		mov		hMem,esi
		.while [esi].PROJECT.hmem
			.if [esi].PROJECT.ntype==TPE_NAME && ![esi].PROJECT.delete
				invoke SetWindowLong,hWin,GWL_USERDATA,esi
				mov		ebx,[esi].PROJECT.hmem
				;Image
				mov		row[8],0
				.while [ebx].NAMEMEM.szname
					.if ![ebx].NAMEMEM.delete
						;lpName
						lea		eax,[ebx].NAMEMEM.szname
						mov		row[0],eax
						mov		row[12],eax
						;lpID
						lea		eax,[ebx].NAMEMEM.value
						mov		row[4],eax
						mov		eax,[eax]
						mov		row[16],eax
						invoke SendMessage,hGrd,GM_ADDROW,0,addr row
					.endif
					add		ebx,sizeof NAMEMEM
				.endw
			.endif
			add		esi,sizeof PROJECT
		.endw
		mov		esi,hMem
		.while [esi].PROJECT.hmem
			.if [esi].PROJECT.ntype==TPE_DIALOG && ![esi].PROJECT.delete
				mov		ebx,[esi].PROJECT.hmem
				lea		ebx,[ebx+sizeof DLGHEAD]
				;Image
				.while [ebx].DIALOG.hwnd
					.if [ebx].DIALOG.hwnd!=-1
						;lpName
						lea		eax,[ebx].DIALOG.idname
						mov		row[0],eax
						mov		row[12],eax
						;lpID
						lea		eax,[ebx].DIALOG.id
						mov		row[4],eax
						mov		eax,[eax]
						mov		row[16],eax
						mov		eax,[ebx].DIALOG.ntype
						.if !eax
							;Dialog
							mov		row[8],1
						.elseif eax==1
							;Edit
							mov		row[8],8
						.elseif eax==2
							;Static
							mov		row[8],9
						.elseif eax==4
							;Button
							mov		row[8],10
						.else
							;Edit
							mov		row[8],11
						.endif
						invoke SendMessage,hGrd,GM_ADDROW,0,addr row
					.endif
					add		ebx,sizeof DIALOG
				.endw
			.endif
			add		esi,sizeof PROJECT
		.endw
		mov		esi,hMem
		.while [esi].PROJECT.hmem
			.if [esi].PROJECT.ntype==TPE_MENU && ![esi].PROJECT.delete
				;Image
				mov		row[8],2
				mov		ebx,[esi].PROJECT.hmem
				;lpName
				lea		eax,[ebx].MNUHEAD.menuname
				mov		row[0],eax
				mov		row[12],eax
				;lpID
				lea		eax,[ebx].MNUHEAD.menuid
				mov		row[4],eax
				mov		eax,[eax]
				mov		row[16],eax
				invoke SendMessage,hGrd,GM_ADDROW,0,addr row
				lea		ebx,[ebx+sizeof MNUHEAD]
				.while [ebx].MNUITEM.itemflag
					.if [ebx].MNUITEM.itemname || [ebx].MNUITEM.itemid
						;lpName
						lea		eax,[ebx].MNUITEM.itemname
						mov		row[0],eax
						mov		row[12],eax
						;lpID
						lea		eax,[ebx].MNUITEM.itemid
						mov		row[4],eax
						mov		eax,[eax]
						mov		row[16],eax
						invoke SendMessage,hGrd,GM_ADDROW,0,addr row
					.endif
					add		ebx,sizeof MNUITEM
				.endw
			.endif
			add		esi,sizeof PROJECT
		.endw
		mov		esi,hMem
		.while [esi].PROJECT.hmem
			.if [esi].PROJECT.ntype==TPE_RESOURCE && ![esi].PROJECT.delete
				mov		ebx,[esi].PROJECT.hmem
				;Image
				mov		row[8],3
				.while [ebx].RESOURCEMEM.szname || [ebx].RESOURCEMEM.value
					;lpName
					lea		eax,[ebx].RESOURCEMEM.szname
					mov		row[0],eax
					mov		row[12],eax
					;lpID
					lea		eax,[ebx].RESOURCEMEM.value
					mov		row[4],eax
					mov		eax,[eax]
					mov		row[16],eax
					invoke SendMessage,hGrd,GM_ADDROW,0,addr row
					add		ebx,sizeof RESOURCEMEM
				.endw
			.endif
			add		esi,sizeof PROJECT
		.endw
		mov		esi,hMem
		.while [esi].PROJECT.hmem
			.if [esi].PROJECT.ntype==TPE_STRING && ![esi].PROJECT.delete
				mov		ebx,[esi].PROJECT.hmem
				;Image
				mov		row[8],6
				.while [ebx].STRINGMEM.szname || [ebx].STRINGMEM.value
					;lpName
					lea		eax,[ebx].STRINGMEM.szname
					mov		row[0],eax
					mov		row[12],eax
					;lpID
					lea		eax,[ebx].STRINGMEM.value
					mov		row[4],eax
					mov		eax,[eax]
					mov		row[16],eax
					invoke SendMessage,hGrd,GM_ADDROW,0,addr row
					add		ebx,sizeof STRINGMEM
				.endw
			.endif
			add		esi,sizeof PROJECT
		.endw
		mov		esi,hMem
		.while [esi].PROJECT.hmem
			.if [esi].PROJECT.ntype==TPE_ACCEL && ![esi].PROJECT.delete
				mov		ebx,[esi].PROJECT.hmem
				;Image
				mov		row[8],4
				.while [ebx].ACCELMEM.szname || [ebx].ACCELMEM.value
					;lpName
					lea		eax,[ebx].ACCELMEM.szname
					mov		row[0],eax
					mov		row[12],eax
					;lpID
					lea		eax,[ebx].ACCELMEM.value
					mov		row[4],eax
					mov		eax,[eax]
					mov		row[16],eax
					invoke SendMessage,hGrd,GM_ADDROW,0,addr row
					add		ebx,sizeof ACCELMEM
				.endw
			.endif
			add		esi,sizeof PROJECT
		.endw
		mov		esi,hMem
		.while [esi].PROJECT.hmem
			.if [esi].PROJECT.ntype==TPE_VERSION && ![esi].PROJECT.delete
				mov		ebx,[esi].PROJECT.hmem
				;Image
				mov		row[8],5
				;lpName
				lea		eax,[ebx].VERSIONMEM.szname
				mov		row[0],eax
				mov		row[12],eax
				;lpID
				lea		eax,[ebx].VERSIONMEM.value
				mov		row[4],eax
				mov		eax,[eax]
				mov		row[16],eax
				invoke SendMessage,hGrd,GM_ADDROW,0,addr row
			.endif
			add		esi,sizeof PROJECT
		.endw
		mov		esi,hMem
		.while [esi].PROJECT.hmem
			.if [esi].PROJECT.ntype==TPE_XPMANIFEST && ![esi].PROJECT.delete
				mov		ebx,[esi].PROJECT.hmem
				;Image
				mov		row[8],3
				;lpName
				lea		eax,[ebx].XPMANIFESTMEM.szname
				mov		row[0],eax
				mov		row[12],eax
				;lpID
				lea		eax,[ebx].XPMANIFESTMEM.value
				mov		row[4],eax
				mov		eax,[eax]
				mov		row[16],eax
				invoke SendMessage,hGrd,GM_ADDROW,0,addr row
			.endif
			add		esi,sizeof PROJECT
		.endw
		mov		esi,hMem
		.while [esi].PROJECT.hmem
			.if [esi].PROJECT.ntype==TPE_RCDATA && ![esi].PROJECT.delete
				mov		ebx,[esi].PROJECT.hmem
				;Image
				mov		row[8],3
				;lpName
				lea		eax,[ebx].RCDATAMEM.szname
				mov		row[0],eax
				mov		row[12],eax
				;lpID
				lea		eax,[ebx].RCDATAMEM.value
				mov		row[4],eax
				mov		eax,[eax]
				mov		row[16],eax
				invoke SendMessage,hGrd,GM_ADDROW,0,addr row
			.endif
			add		esi,sizeof PROJECT
		.endw
		mov		esi,hMem
		.while [esi].PROJECT.hmem
			.if [esi].PROJECT.ntype==TPE_TOOLBAR && ![esi].PROJECT.delete
				mov		ebx,[esi].PROJECT.hmem
				;Image
				mov		row[8],3
				;lpName
				lea		eax,[ebx].TOOLBARMEM.szname
				mov		row[0],eax
				mov		row[12],eax
				;lpID
				lea		eax,[ebx].TOOLBARMEM.value
				mov		row[4],eax
				mov		eax,[eax]
				mov		row[16],eax
				invoke SendMessage,hGrd,GM_ADDROW,0,addr row
			.endif
			add		esi,sizeof PROJECT
		.endw
		.if lParam
			dec		lParam
			invoke SaveNamesToFile,hWin,lParam
			invoke DestroyWindow,hWin
		.else
			invoke SendMessage,hWin,WM_SIZE,0,0
			invoke SendMessage,hGrd,GM_SETCURSEL,3,0
			invoke SetFocus,hGrd
			invoke SendMessage,hPrpCboDlg,CB_RESETCONTENT,0,0
			invoke SendMessage,hPrpCboDlg,CB_ADDSTRING,0,offset szDEFINE
			invoke SendMessage,hPrpCboDlg,CB_SETCURSEL,0,0
			mov		 fNoScroll,TRUE
	    	invoke ShowScrollBar,hDEd,SB_BOTH,FALSE
			invoke SendMessage,hWin,WM_SIZE,0,0
		.endif
		mov		fDialogChanged,FALSE
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_COMMAND
		invoke GetDlgItem,hWin,IDC_GRDNME
		mov		hGrd,eax
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendMessage,hGrd,GM_GETCURSEL,0,0
				invoke SendMessage,hGrd,GM_ENDEDIT,eax,FALSE
				.if fDialogChanged
					invoke UpdateNames,hWin
					invoke SendMessage,hRes,PRO_SETMODIFY,TRUE,0
					mov		fDialogChanged,FALSE
				.endif
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
				invoke PropertyList,0
			.elseif eax==IDC_BTNNMEADD
				invoke SendMessage,hGrd,GM_ADDROW,0,NULL
				invoke SendMessage,hGrd,GM_SETCURSEL,3,eax
				invoke SetFocus,hGrd
				mov		fDialogChanged,TRUE
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNNMEDEL
				invoke SendMessage,hGrd,GM_GETCURROW,0,0
				mov		ebx,eax
				mov		ecx,ebx
				shl		ecx,16
				add		ecx,3
				invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
				invoke GetWindowLong,hPrj,0
				mov		edx,eax
				push	eax
				invoke FindName,edx,addr buffer,FALSE
				pop		edx
				.if eax
					mov		[eax].NAMEMEM.delete,TRUE
				.endif
				invoke SendMessage,hGrd,GM_DELROW,ebx,0
				invoke SendMessage,hGrd,GM_SETCURSEL,3,ebx
				invoke SetFocus,hGrd
				mov		fDialogChanged,TRUE
				invoke NotifyParent
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNNMEEXPORT
				invoke SaveNamesToFile,hWin,FALSE
				invoke SetFocus,hGrd
				xor		eax,eax
				jmp		Ex
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		invoke GetDlgItem,hWin,IDC_GRDNME
		mov		hGrd,eax
		mov		esi,lParam
		mov		eax,[esi].NMHDR.hwndFrom
		.if eax==hGrd
			mov		eax,[esi].NMHDR.code
			.if eax==GN_HEADERCLICK
				;Sort the grid by column, invert sorting order
				invoke SendMessage,hGrd,GM_COLUMNSORT,[esi].GRIDNOTIFY.col,SORT_INVERT
			.elseif eax==GN_BEFORESELCHANGE
				;Restrict to col 2 & 4              *** MOD restriction change 3-4 to 2-4 
				.if [esi].GRIDNOTIFY.col<2
					mov		[esi].GRIDNOTIFY.col,2
				.endif
				;Enable / Disable delete button
				invoke GetDlgItem,hWin,IDC_BTNNMEDEL
				push	eax
				mov		ecx,[esi].GRIDNOTIFY.row
				shl		ecx,16
				add		ecx,2
				invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,addr buffer
				pop		edx
				mov		eax,dword ptr buffer
				.if eax
					xor		eax,eax
				.else
					inc		eax
				.endif
				invoke EnableWindow,edx,eax
			.elseif eax==GN_BEFOREUPDATE
				.if [esi].GRIDNOTIFY.col==3
					invoke CheckName,[esi].GRIDNOTIFY.lpdata
					.if eax
						mov		[esi].GRIDNOTIFY.fcancel,TRUE
					.endif
				.endif
			.elseif eax==GN_AFTERUPDATE
				mov		fDialogChanged,TRUE
				invoke NotifyParent
			.endif
		.endif
	.elseif eax==WM_SIZE
		invoke SendMessage,hDEd,WM_VSCROLL,SB_THUMBTRACK,0
		invoke SendMessage,hDEd,WM_HSCROLL,SB_THUMBTRACK,0
		invoke GetClientRect,hDEd,addr rect
		
		;mov		rect.left,3
		;mov		rect.top,3
		;sub		rect.right,6
		;sub		rect.bottom,6
		invoke MoveWindow,hWin,rect.left,rect.top,rect.right,rect.bottom,TRUE
		invoke GetClientRect,hWin,addr rect
		.if rect.right<470
			mov		rect.right,470
		.endif
		
		invoke GetDlgItem,hWin,IDC_BTNNMEADD
		mov		edx,rect.right
		sub		edx,64+3
		invoke MoveWindow,eax,edx,3,64,22,TRUE
		
		invoke GetDlgItem,hWin,IDC_BTNNMEDEL
		mov		edx,rect.right
		sub		edx,64+3
		invoke MoveWindow,eax,edx,3+22+6,64,22,TRUE
		
		invoke GetDlgItem,hWin,IDC_BTNNMEEXPORT
		mov		edx,rect.right
		sub		edx,64+3
		invoke MoveWindow,eax,edx,3+22+6+22+6+6,64,22,TRUE
		
		invoke GetDlgItem,hWin,IDC_GRDNME
		mov		hGrd,eax
		mov		rect.left,3
		mov		rect.top,3
		sub		rect.right,3+64+6
		sub		rect.bottom,6
		invoke MoveWindow,hGrd,rect.left,rect.top,rect.right,rect.bottom,TRUE
	.elseif eax==WM_CLOSE
		invoke GetDlgItem,hWin,IDC_GRDNME
		mov		hGrd,eax
		invoke SaveGrdSize,hGrd,5,offset NmeGrdSize
		mov		NmeGrdSize,1
		mov		 fNoScroll,FALSE
    	invoke ShowScrollBar,hDEd,SB_BOTH,TRUE
		invoke DestroyWindow,hWin
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
  Ex:
	ret

NameEditProc endp
