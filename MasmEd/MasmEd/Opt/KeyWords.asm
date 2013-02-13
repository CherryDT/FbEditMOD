
IDD_DLGKEYWORDS		equ 4000

IDC_CBOTHEME		equ 4016
IDC_EDTTHEME		equ 4027
IDC_BTNNEWTHEME		equ 4028
IDC_BTNADDTHEME		equ 4029

IDC_LSTKWCOLORS		equ 4001
IDC_LSTKWACTIVE		equ 4014
IDC_LSTKWHOLD		equ 4013
IDC_LSTCOLORS		equ 4015
IDC_BTNKWAPPLY		equ 4002

IDC_BTNHOLD			equ 4009
IDC_BTNACTIVE		equ 4008
IDC_EDTKW			equ 4012
IDC_BTNADD			equ 4011
IDC_BTNDEL			equ 4010

IDC_CHKBOLD			equ 4004
IDC_CHKITALIC		equ 4003
IDC_CHKRCFILE		equ 4005
IDC_SPNTABSIZE		equ 4017
IDC_EDTTABSIZE		equ 4018
IDC_CHKEXPAND		equ 4019
IDC_CHKAUTOINDENT	equ 4020
IDC_CHKLINENUMBER	equ 4007
IDC_CHKHILITELINE	equ 4021
IDC_CHKHILITECMNT	equ 4026
IDC_CHKSESSION		equ 4006

IDC_BTNCODEFONT		equ 4024
IDC_STCCODEFONT		equ 4022
IDC_BTNLNRFONT		equ 4025
IDC_STCLNRFONT		equ 4023

szColors			db 'Back',0
					db 'Text',0
					db 'Selected back',0
					db 'Selected text',0
					db 'Comments',0
					db 'Strings',0
					db 'Operators',0
					db 'Comments back',0
					db 'Active line back',0
					db 'Indent markers',0
					db 'Selection bar',0
					db 'Selection bar pen',0
					db 'Line numbers',0
					db 'Numbers & hex',0
					db 'Line changed',0
					db 'Line saved change',0
					db 'Tools Back',0
					db 'Tools Text',0
					db 'Dialog Back',0
					db 'Dialog Text',0
					db 'Resource Styles',0
					db 'Resource Words',0
					db 'CodeComplete Back',0
					db 'CodeComplete Text',0
					db 'CodeTip Back',0
					db 'CodeTip Text',0
					db 'CodeTip Api',0
					db 'CodeTip Sel',0
					db 0
szCustColors		db 'CustColors',0

szNewTheme			db 'New Theme',0
szTheme				db 'Theme',0
thme0				db 'Default',0
					dd 00804000h,00808000h,00FF0000h,00FF0000h,00FF0000h,10FF0000h,000040FFh,00FF0000h,01FF0000h,00FF0000h,00A00000h,00A00000h,00A00000h,00A00000h,00A00000h,00A00000h
					dd 00C0F0F0h,00000000h,00800000h,00FFFFFFh,02808040h,00A00000h,000000A0h,00F0C0C0h,00C0F0C0h,00C0C0F0h,00C0C0C0h,00808080h,00800000h,00808080h,00C0F0F0h,00C0F0F0h,00C0F0F0h,00C0F0F0h,0000F0F0h,0000F000h
					dd 00C0F0F0h,00000000h,00C0F0F0h,00000000h,00804000h,00C00000h,00FFFFFFh,00000000h,00C0F0F0h,00000000h,00404080h,00FF0000h

thme1				db 'Black Night',0
					dd 0000FF00h,00FFFF80h,00FFFF00h,00FFFF00h,00FFFF00h,10FF0000h,004080FFh,00FF8080h,01FF0000h,00FF00FFh,00FF0000h,00FF0000h,00FF0000h,00FF0000h,00FF0000h,00FF0000h
					dd 00000000h,00C0C0C0h,00800000h,00FFFFFFh,0280FFFFh,00FFFFFFh,000000FFh,004A4A4Ah,00C0F0C0h,00181869h,00E0E0E0h,00808080h,00800000h,00808080h,00000000h,00000000h,00000000h,00000000h,0000F0F0h,0000F000h
					dd 00C6FFFFh,00000000h,00C6FFFFh,00000000h,00804000h,00C00000h,00C6FFFFh,00000000h,00C0F0F0h,00000000h,00404080h,00FF0000h

thme2				db 'Visual Studio',0
					dd 00800040h,00800040h,00800040h,00800040h,00800040h,10800040h,00800040h,00800040h,01800040h,00800040h,00800040h,00800040h,00800040h,00800040h,00800040h,00800040h
					dd 00FFFFFFh,00000000h,00800000h,00FFFFFFh,02008000h,00A00000h,000000A0h,00F0C0C0h,00C0F0C0h,00C0C0F0h,00E0E0E0h,00808080h,00800000h,00808080h,00FFFFFFh,00FFFFFFh,00FFFFFFh,00FFFFFFh,0000F0F0h,0000F000h
					dd 00FFFFFFh,00000000h,00FFFFFFh,00000000h,00804000h,00C00000h,00FFFFFFh,00000000h,00C0F0F0h,00000000h,00404080h,00FF0000h

.data?

nKWInx				dd ?
CustColors			dd 16 dup(?)
hCFnt				dd ?
hLFnt				dd ?
tempcol				RACOLOR <?>
theme				THEME 10 dup(<>)

.code
UpdateTheme1053 proc uses esi edi
	LOCAL	nInx:DWORD
	LOCAL	buffer[32]:BYTE

	mov		nInx,0
	mov		edi,offset theme
	.while nInx<10
		mov		[edi].THEME.szname,0
		invoke MakeKey,addr szTheme,nInx,addr buffer
		mov		lpcbData,sizeof THEME
		invoke RegQueryValueEx,ha.hReg,addr buffer,0,addr lpType,offset theme,addr lpcbData
		.if !eax
			mov		esi,offset theme.medcol.tttext
			mov		edi,offset theme.medcol.ttsel
			mov		ecx,12
			.while ecx
				mov		eax,[esi]
				mov		[edi],eax
				sub		esi,4
				sub		edi,4
				dec		ecx
			.endw
			mov		theme.medcol.racol.changed,CHCOL
			mov		theme.medcol.racol.changesaved,CHSAVEDCOL
			invoke RegSetValueEx,ha.hReg,addr buffer,0,REG_BINARY,offset theme,sizeof THEME
		.endif
		inc		nInx
	.endw
	ret

UpdateTheme1053 endp

GetThemes proc uses esi edi
	LOCAL	nInx:DWORD
	LOCAL	buffer[32]:BYTE

	mov		nInx,0
	mov		edi,offset theme
	.while nInx<10
		mov		[edi].THEME.szname,0
		invoke MakeKey,addr szTheme,nInx,addr buffer
		mov		lpcbData,sizeof THEME
		invoke RegQueryValueEx,ha.hReg,addr buffer,0,addr lpType,edi,addr lpcbData
		.if eax && !nInx
			invoke MakeKey,addr szTheme,0,addr buffer
			mov		esi,offset thme0
			mov		edi,offset theme+sizeof THEME*0
			invoke strcpy,addr [edi].THEME.szname,esi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			lea		edi,[edi+sizeof THEME.szname]
			mov		ecx,sizeof THEME.kwcol+sizeof THEME.medcol
			rep		movsb
			mov		edi,offset theme+sizeof THEME*0
			invoke RegSetValueEx,ha.hReg,addr buffer,0,REG_BINARY,edi,sizeof THEME

			invoke MakeKey,addr szTheme,1,addr buffer
			mov		esi,offset thme1
			mov		edi,offset theme+sizeof THEME*1
			invoke strcpy,addr [edi].THEME.szname,esi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			lea		edi,[edi+sizeof THEME.szname]
			mov		ecx,sizeof THEME.kwcol+sizeof THEME.medcol
			rep		movsb
			mov		edi,offset theme+sizeof THEME*1
			invoke RegSetValueEx,ha.hReg,addr buffer,0,REG_BINARY,edi,sizeof THEME

			invoke MakeKey,addr szTheme,2,addr buffer
			mov		esi,offset thme2
			mov		edi,offset theme+sizeof THEME*2
			invoke strcpy,addr [edi].THEME.szname,esi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			lea		edi,[edi+sizeof THEME.szname]
			mov		ecx,sizeof THEME.kwcol+sizeof THEME.medcol
			rep		movsb
			mov		edi,offset theme+sizeof THEME*2
			invoke RegSetValueEx,ha.hReg,addr buffer,0,REG_BINARY,edi,sizeof THEME
			.break
		.endif
		add		edi,sizeof THEME
		inc		nInx
	.endw
	ret

GetThemes endp

SetTheme proc uses ebx esi edi,hWin:HWND,nInx:DWORD

	lea		esi,theme.kwcol
	mov		eax,nInx
	mov		edx,sizeof THEME
	mul		edx
	add		esi,eax
	xor		ebx,ebx
	.while ebx<16
		invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,ebx,[esi]
		add		esi,4
		inc		ebx
	.endw
	invoke GetDlgItem,hWin,IDC_LSTKWCOLORS
	invoke InvalidateRect,eax,NULL,TRUE
	lea		esi,theme.medcol
	mov		eax,nInx
	mov		edx,sizeof THEME
	mul		edx
	add		esi,eax
	xor		ebx,ebx
	.while ebx<18+12-4
		invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_SETITEMDATA,ebx,[esi]
		.if ebx==13
			add		esi,16
		.endif
		add		esi,4
		inc		ebx
	.endw

	lea		esi,theme.medcol.racol
	mov		eax,nInx
	mov		edx,sizeof THEME
	mul		edx
	add		esi,eax
	mov		edi,offset tempcol
	mov		ecx,sizeof RACOLOR
	rep		movsb
	invoke GetDlgItem,hWin,IDC_LSTCOLORS
	invoke InvalidateRect,eax,NULL,TRUE
	ret

SetTheme endp

AddTheme proc uses ebx esi edi,hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	buffer[32]:BYTE

	mov		nInx,0
	mov		esi,offset theme
	.while nInx<10
		.if !byte ptr [esi].THEME.szname
			invoke SendDlgItemMessage,hWin,IDC_EDTTHEME,WM_GETTEXT,sizeof buffer,addr buffer
			.if byte ptr buffer
				invoke strcpy,addr [esi].THEME.szname,addr buffer
				xor		ebx,ebx
				.while ebx<16
					invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,ebx,0
					mov		[esi].THEME.kwcol[ebx*4],eax
					inc		ebx
				.endw
				xor		ebx,ebx
				.while ebx<26
					invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETITEMDATA,ebx,0
					.if ebx<=13
						mov		[esi].THEME.medcol.racol.bckcol[ebx*4],eax
					.else
						mov		[esi].THEME.medcol.racol.bckcol[ebx*4+16],eax
					.endif
					inc		ebx
				.endw
				mov		eax,tempcol.cmntback
				mov		[esi].THEME.medcol.racol.cmntback,eax
				mov		eax,tempcol.strback
				mov		[esi].THEME.medcol.racol.strback,eax
				mov		eax,tempcol.numback
				mov		[esi].THEME.medcol.racol.numback,eax
				mov		eax,tempcol.oprback
				mov		[esi].THEME.medcol.racol.oprback,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_ADDSTRING,0,addr buffer
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_SETITEMDATA,eax,nInx
				pop		eax
				invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_SETCURSEL,eax,0
			.endif
			mov		eax,TRUE
			ret
		.endif
		add		esi,sizeof THEME
		inc		nInx
	.endw
	xor		eax,eax
	ret

AddTheme endp

SaveTheme proc uses esi edi
	LOCAL	nInx:DWORD
	LOCAL	buffer[32]:BYTE

	mov		nInx,0
	mov		esi,offset theme
	.while nInx<10
		.if byte ptr [esi].THEME.szname
			invoke MakeKey,addr szTheme,nInx,addr buffer
			invoke RegSetValueEx,ha.hReg,addr buffer,0,REG_BINARY,esi,sizeof THEME
		.endif
		add		esi,sizeof THEME
		inc		nInx
	.endw
	ret

SaveTheme endp

SetKeyWordList proc uses esi edi,hWin:HWND,idLst:DWORD,nInx:DWORD
	LOCAL	hMem:DWORD
	LOCAL	buffer[64]:BYTE

	mov		eax,nInx
	mov		nKWInx,eax
	invoke SendDlgItemMessage,hWin,idLst,LB_RESETCONTENT,0,0
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16384
	mov		hMem,eax
	invoke MakeKey,offset szGroup,nInx,addr buffer
	mov		lpcbData,16384
	invoke RegQueryValueEx,ha.hReg,addr buffer,0,addr lpType,hMem,addr lpcbData
	mov		eax,hMem
	mov		al,[eax]
	mov		esi,nInx
	.if !al && esi<16
		lea		esi,kwofs[esi*4]
		mov		esi,[esi]
	.else
		mov		esi,hMem
	.endif
	dec		esi
  Nxt:
	inc		esi
	mov		al,[esi]
	or		al,al
	je		Ex
	cmp		al,VK_SPACE
	je		Nxt
	lea		edi,buffer
  @@:
	mov		al,[esi]
	.if al==VK_SPACE || !al
		mov		byte ptr [edi],0
		invoke SendDlgItemMessage,hWin,idLst,LB_ADDSTRING,0,addr buffer
		dec		esi
		jmp		Nxt
	.endif
	mov		[edi],al
	inc		esi
	inc		edi
	jmp		@b
  Ex:
	invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,nInx,0
	.if eax!=LB_ERR
		shr		eax,24
		mov		esi,eax
		mov		eax,BST_UNCHECKED
		test	esi,1
		.if !ZERO?
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKBOLD,eax
		mov		eax,BST_UNCHECKED
		test	esi,2
		.if !ZERO?
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKITALIC,eax
		mov		eax,BST_UNCHECKED
		test	esi,10h
		.if !ZERO?
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKRCFILE,eax
	.endif
	invoke GlobalFree,hMem
	ret

SetKeyWordList endp

SaveKeyWordList proc uses esi edi,hWin:HWND,idLst:DWORD,nInx:DWORD
	LOCAL	hMem:DWORD
	LOCAL	buffer[64]:BYTE

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16384
	mov		hMem,eax
	mov		edi,eax
	xor		esi,esi
  @@:
	invoke SendDlgItemMessage,hWin,idLst,LB_GETTEXT,esi,edi
	.if eax!=LB_ERR
		invoke strlen,edi
		add		edi,eax
		mov		byte ptr [edi],VK_SPACE
		inc		edi
		inc		esi
		jmp		@b
	.endif
	.if edi!=hMem
		mov		byte ptr [edi-1],0
	.endif
	sub		edi,hMem
	invoke MakeKey,offset szGroup,nInx,addr buffer
	invoke RegSetValueEx,ha.hReg,addr buffer,0,REG_SZ,hMem,edi
	invoke GlobalFree,hMem
	ret

SaveKeyWordList endp

DeleteKeyWords proc hWin:HWND,idFrom:DWORD
	LOCAL	nInx:DWORD
	LOCAL	nCnt:DWORD

	invoke SendDlgItemMessage,hWin,idFrom,LB_GETSELCOUNT,0,0
	mov		nCnt,eax
	mov		nInx,0
	.while nCnt
		invoke SendDlgItemMessage,hWin,idFrom,LB_GETSEL,nInx,0
		.if eax
			invoke SendDlgItemMessage,hWin,idFrom,LB_DELETESTRING,nInx,0
			dec		nCnt
			mov		eax,1
		.endif
		xor		eax,1
		add		nInx,eax
	.endw
	ret

DeleteKeyWords endp

MoveKeyWords proc hWin:HWND,idFrom:DWORD,idTo:DWORD
	LOCAL	buffer[64]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	nCnt:DWORD

	invoke SendDlgItemMessage,hWin,idFrom,LB_GETSELCOUNT,0,0
	mov		nCnt,eax
	mov		nInx,0
	.while nCnt
		invoke SendDlgItemMessage,hWin,idFrom,LB_GETSEL,nInx,0
		.if eax
			invoke SendDlgItemMessage,hWin,idFrom,LB_GETTEXT,nInx,addr buffer
			invoke SendDlgItemMessage,hWin,idFrom,LB_DELETESTRING,nInx,0
			invoke SendDlgItemMessage,hWin,idTo,LB_ADDSTRING,0,addr buffer
			dec		nCnt
			mov		eax,1
		.endif
		xor		eax,1
		add		nInx,eax
	.endw
	ret

MoveKeyWords endp

UpdateKeyWords proc uses ebx,hWin:HWND

	xor		ebx,ebx
	.while ebx<16
		invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,ebx,0
		mov		kwcol[ebx*4],eax
		inc		ebx
	.endw
	invoke RegSetValueEx,ha.hReg,addr szKeyWordColor,0,REG_BINARY,addr kwcol,sizeof kwcol
	invoke SetKeyWords
	invoke UpdateAll,WM_PAINT,0
	ret

UpdateKeyWords endp

UpdateToolColors proc
	LOCAL	racol:RACOLOR
	LOCAL	rescol:RESCOLOR
	LOCAL	cccol:CC_COLOR
	LOCAL	ttcol:TT_COLOR

	invoke SendMessage,ha.hOut,REM_GETCOLOR,0,addr racol
	mov		eax,col.toolback
	mov		racol.bckcol,eax
	mov		racol.cmntback,eax
	mov		racol.strback,eax
	mov		racol.numback,eax
	mov		racol.oprback,eax
	mov		eax,col.tooltext
	mov		racol.txtcol,eax
	invoke SendMessage,ha.hOut,REM_SETCOLOR,0,addr racol
	invoke SendMessage,ha.hImmOut,REM_SETCOLOR,0,addr racol
	invoke SendMessage,ha.hDbgReg,REM_SETCOLOR,0,addr racol
	invoke SendMessage,ha.hDbgFpu,REM_SETCOLOR,0,addr racol
	invoke SendMessage,ha.hDbgMMX,REM_SETCOLOR,0,addr racol
	invoke SendMessage,ha.hDbgWatch,REM_SETCOLOR,0,addr racol
	;Set tool colors
	invoke SendMessage,ha.hBrowse,FBM_SETBACKCOLOR,0,col.toolback
	invoke SendMessage,ha.hBrowse,FBM_SETTEXTCOLOR,0,col.tooltext
	invoke SendMessage,ha.hPbr,RPBM_SETBACKCOLOR,0,col.toolback
	invoke SendMessage,ha.hPbr,RPBM_SETTEXTCOLOR,0,col.tooltext
	invoke SendMessage,ha.hProperty,PRM_SETBACKCOLOR,0,col.toolback
	invoke SendMessage,ha.hProperty,PRM_SETTEXTCOLOR,0,col.tooltext
	mov		eax,col.dialogback
	mov		rescol.back,eax
	mov		eax,col.dialogtext
	mov		rescol.text,eax
	invoke SendMessage,ha.hResEd,DEM_SETCOLOR,0,addr rescol
	.if ha.hBrBack
		invoke DeleteObject,ha.hBrBack
	.endif
	invoke CreateSolidBrush,col.toolback
	mov		ha.hBrBack,eax
	mov		eax,col.ccback
	mov		cccol.back,eax
	mov		eax,col.cctext
	mov		cccol.text,eax
	invoke SendMessage,ha.hCCLB,CCM_SETCOLOR,0,addr cccol
	mov		eax,col.ttback
	mov		ttcol.back,eax
	mov		eax,col.tttext
	mov		ttcol.text,eax
	mov		eax,col.ttapi
	mov		ttcol.api,eax
	mov		eax,col.ttsel
	mov		ttcol.hilite,eax
	invoke SendMessage,ha.hCCTT,TTM_SETCOLOR,0,addr ttcol
	ret

UpdateToolColors endp

KeyWordsProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	rect:RECT
	LOCAL	hBr:DWORD
	LOCAL	cc:CHOOSECOLOR
	LOCAL	cf:CHOOSEFONT
	LOCAL	lf:LOGFONT
	LOCAL	pt:POINT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	esi
		push	edi
		mov		esi,offset col.racol
		mov		edi,offset tempcol
		mov		ecx,sizeof RACOLOR
		rep		movsb
        invoke SendDlgItemMessage,hWin,IDC_SPNTABSIZE,UDM_SETRANGE,0,00010014h		; Set range
        invoke SendDlgItemMessage,hWin,IDC_SPNTABSIZE,UDM_SETPOS,0,edopt.tabsize	; Set default value
		invoke CheckDlgButton,hWin,IDC_CHKEXPAND,edopt.exptabs
		invoke CheckDlgButton,hWin,IDC_CHKAUTOINDENT,edopt.indent
		invoke CheckDlgButton,hWin,IDC_CHKHILITELINE,edopt.hiliteline
		invoke CheckDlgButton,hWin,IDC_CHKHILITECMNT,edopt.hilitecmnt
		invoke CheckDlgButton,hWin,IDC_CHKSESSION,edopt.session
		invoke CheckDlgButton,hWin,IDC_CHKLINENUMBER,edopt.linenumber
		mov		esi,offset szColors
		mov		edi,offset col
		xor		ecx,ecx
	  @@:
		push	ecx
		invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_ADDSTRING,0,esi
		invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_SETITEMDATA,eax,[edi]
		invoke strlen,esi
		add		esi,eax
		inc		esi
		add		edi,4
		pop		ecx
		.if ecx==13
			add		edi,16
		.endif
		inc		ecx
		mov		al,[esi]
		or		al,al
		jne		@b
		invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_SETCURSEL,0,0
		mov		edi,offset kwcol
		mov		nInx,0
		.while nInx<16
			invoke MakeKey,offset szGroup,nInx,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_ADDSTRING,0,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,eax,[edi]
			add		edi,4
			inc		nInx
		.endw
		invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETCURSEL,0,0
		invoke SetKeyWordList,hWin,IDC_LSTKWHOLD,10
		invoke SetKeyWordList,hWin,IDC_LSTKWACTIVE,0
		invoke SendDlgItemMessage,hWin,IDC_EDTKW,EM_LIMITTEXT,63,0
		invoke SendDlgItemMessage,hWin,IDC_EDTTHEME,EM_LIMITTEXT,31,0
		invoke GetThemes
		mov		esi,offset theme
		mov		nInx,0
		.while nInx<10
			.if byte ptr [esi].THEME.szname
				invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_ADDSTRING,0,addr [esi].THEME.szname
				invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_SETITEMDATA,eax,nInx
			.endif
			add		esi,sizeof THEME
			inc		nInx
		.endw
		invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_SETCURSEL,0,0
		mov		eax,IDC_BTNKWAPPLY
		xor		edx,edx
		call	EnButton
		pop		edi
		pop		esi
		invoke SendDlgItemMessage,hWin,IDC_STCCODEFONT,WM_SETFONT,ha.hFont,FALSE
		invoke SendDlgItemMessage,hWin,IDC_STCLNRFONT,WM_SETFONT,ha.hLnrFont,FALSE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				call	Update
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				.if hCFnt
					invoke DeleteObject,hCFnt
				.endif
				.if hLFnt
					invoke DeleteObject,hLFnt
				.endif
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNKWAPPLY
				call	Update
			.elseif eax==IDC_BTNNEWTHEME
				invoke GetDlgItem,hWin,IDC_BTNADDTHEME
				invoke ShowWindow,eax,SW_SHOWNA
				invoke GetDlgItem,hWin,IDC_BTNNEWTHEME
				invoke ShowWindow,eax,SW_HIDE
				mov		eax,IDC_EDTTHEME
				mov		edx,TRUE
				call	EnButton
				invoke SetDlgItemText,hWin,IDC_EDTTHEME,addr szNewTheme
				invoke GetDlgItem,hWin,IDC_EDTTHEME
				invoke SetFocus,eax
			.elseif eax==IDC_BTNADDTHEME
				invoke AddTheme,hWin
				.if eax
					invoke GetDlgItem,hWin,IDC_BTNNEWTHEME
					invoke ShowWindow,eax,SW_SHOWNA
					invoke GetDlgItem,hWin,IDC_BTNADDTHEME
					invoke ShowWindow,eax,SW_HIDE
					invoke SetDlgItemText,hWin,IDC_EDTTHEME,addr szNULL
					mov		eax,IDC_EDTTHEME
					mov		edx,FALSE
					call	EnButton
					mov		eax,IDC_BTNKWAPPLY
					mov		edx,TRUE
					call	EnButton
				.endif
			.elseif eax==IDC_BTNHOLD
				invoke MoveKeyWords,hWin,IDC_LSTKWACTIVE,IDC_LSTKWHOLD
				mov		eax,IDC_BTNHOLD
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNDEL
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_BTNACTIVE
				invoke MoveKeyWords,hWin,IDC_LSTKWHOLD,IDC_LSTKWACTIVE
				mov		eax,IDC_BTNACTIVE
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_BTNADD
				invoke GetDlgItemText,hWin,IDC_EDTKW,addr buffer,64
				invoke SendDlgItemMessage,hWin,IDC_LSTKWACTIVE,LB_ADDSTRING,0,addr buffer
				mov		buffer,0
				invoke SetDlgItemText,hWin,IDC_EDTKW,addr buffer
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_BTNDEL
				invoke DeleteKeyWords,hWin,IDC_LSTKWACTIVE
				mov		eax,IDC_BTNHOLD
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNDEL
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKBOLD
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,eax,0
				pop		edx
				xor		eax,01000000h
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,edx,eax
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKITALIC
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,eax,0
				pop		edx
				xor		eax,02000000h
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,edx,eax
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKRCFILE
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,eax,0
				pop		edx
				xor		eax,10000000h
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,edx,eax
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKEXPAND
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKAUTOINDENT
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKHILITELINE
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKHILITECMNT
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKSESSION
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKLINENUMBER
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_BTNCODEFONT
				mov		edx,hCFnt
				.if !edx
					mov		edx,ha.hFont
				.endif
				invoke GetObject,edx,sizeof lf,addr lf
				invoke RtlZeroMemory,addr cf,sizeof cf
				mov		cf.lStructSize,sizeof cf
				mov		eax,hWin
				mov		cf.hwndOwner,eax
				lea		eax,lf
				mov		cf.lpLogFont,eax
				mov		cf.Flags,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT
				invoke ChooseFont,addr cf
				.if eax
					invoke CreateFontIndirect,addr lf
					mov     hCFnt,eax
					invoke SendDlgItemMessage,hWin,IDC_STCCODEFONT,WM_SETFONT,hCFnt,TRUE
					mov		eax,IDC_BTNKWAPPLY
					mov		edx,TRUE
					call	EnButton
				.endif
			.elseif eax==IDC_BTNLNRFONT
				mov		edx,hLFnt
				.if !edx
					mov		edx,ha.hLnrFont
				.endif
				invoke GetObject,edx,sizeof lf,addr lf
				invoke RtlZeroMemory,addr cf,sizeof cf
				mov		cf.lStructSize,sizeof cf
				mov		eax,hWin
				mov		cf.hwndOwner,eax
				lea		eax,lf
				mov		cf.lpLogFont,eax
				mov		cf.Flags,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT
				invoke ChooseFont,addr cf
				.if eax
					invoke CreateFontIndirect,addr lf
					mov     hLFnt,eax
					invoke SendDlgItemMessage,hWin,IDC_STCLNRFONT,WM_SETFONT,hLFnt,TRUE
					mov		eax,IDC_BTNKWAPPLY
					mov		edx,TRUE
					call	EnButton
				.endif
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTKW
				invoke SendDlgItemMessage,hWin,IDC_EDTKW,WM_GETTEXTLENGTH,0,0
				.if eax
					mov		eax,TRUE
				.endif
				mov		edx,eax
				mov		eax,IDC_BTNADD
				call	EnButton
			.elseif eax==IDC_EDTTABSIZE
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.endif
		.elseif edx==LBN_SELCHANGE
			.if eax==IDC_LSTKWCOLORS
				invoke SaveKeyWordList,hWin,IDC_LSTKWACTIVE,nKWInx
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				invoke SetKeyWordList,hWin,IDC_LSTKWACTIVE,eax
				invoke GetDlgItem,hWin,IDC_BTNHOLD
				invoke EnableWindow,eax,FALSE
				invoke GetDlgItem,hWin,IDC_BTNDEL
				invoke EnableWindow,eax,FALSE
			.elseif eax==IDC_LSTKWACTIVE
				invoke SendDlgItemMessage,hWin,IDC_LSTKWACTIVE,LB_GETSELCOUNT,0,0
				.if eax
					mov		eax,TRUE
				.endif
				push	eax
				mov		edx,eax
				mov		eax,IDC_BTNHOLD
				call	EnButton
				pop		edx
				mov		eax,IDC_BTNDEL
				call	EnButton
			.elseif eax==IDC_LSTKWHOLD
				invoke SendDlgItemMessage,hWin,IDC_LSTKWHOLD,LB_GETSELCOUNT,0,0
				.if eax
					mov		eax,TRUE
				.endif
				mov		edx,eax
				mov		eax,IDC_BTNACTIVE
				call	EnButton
			.elseif eax==IDC_CBOTHEME
				invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_GETITEMDATA,eax,0
				invoke SetTheme,hWin,eax
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.endif
		.elseif edx==LBN_DBLCLK
			.if eax==IDC_LSTKWCOLORS
				mov		cc.lStructSize,sizeof CHOOSECOLOR
				mov		eax,hWin
				mov		cc.hwndOwner,eax
				mov		eax,ha.hInstance
				mov		cc.hInstance,eax
				mov		cc.lpCustColors,offset CustColors
				mov		cc.Flags,CC_FULLOPEN or CC_RGBINIT
				mov		cc.lCustData,0
				mov		cc.lpfnHook,0
				mov		cc.lpTemplateName,0
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,eax,0
				push	eax
				;Mask off group/font
				and		eax,0FFFFFFh
				mov		cc.rgbResult,eax
				invoke ChooseColor,addr cc
				pop		ecx
				.if eax
					push	ecx
					invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
					pop		ecx
					mov		edx,cc.rgbResult
					;Group/Font
					and		ecx,0FF000000h
					or		edx,ecx
					invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,eax,edx
					invoke GetDlgItem,hWin,IDC_LSTKWCOLORS
					invoke InvalidateRect,eax,NULL,FALSE
					mov		eax,IDC_BTNKWAPPLY
					mov		edx,TRUE
					call	EnButton
				.endif
			.elseif eax==IDC_LSTKWACTIVE
				invoke SendDlgItemMessage,hWin,IDC_LSTKWACTIVE,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		edx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTKWACTIVE,LB_GETTEXT,edx,addr buffer
					invoke SetDlgItemText,hWin,IDC_EDTKW,addr buffer
				.endif
			.elseif eax==IDC_LSTKWHOLD
				invoke SendDlgItemMessage,hWin,IDC_LSTKWHOLD,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		edx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTKWHOLD,LB_GETTEXT,edx,addr buffer
					invoke SetDlgItemText,hWin,IDC_EDTKW,addr buffer
				.endif
			.elseif eax==IDC_LSTCOLORS
				mov		cc.lStructSize,sizeof CHOOSECOLOR
				mov		eax,hWin
				mov		cc.hwndOwner,eax
				mov		eax,ha.hInstance
				mov		cc.hInstance,eax
				mov		cc.lpCustColors,offset CustColors
				mov		cc.Flags,CC_FULLOPEN or CC_RGBINIT
				mov		cc.lCustData,0
				mov		cc.lpfnHook,0
				mov		cc.lpTemplateName,0
				invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETCURSEL,0,0
				xor		ecx,ecx
				.if (eax>=4 && eax<=6) || eax==13
					push	eax
					invoke GetCursorPos,addr pt
					invoke GetDlgItem,hWin,IDC_LSTCOLORS
					mov		edx,eax
					invoke ScreenToClient,edx,addr pt
					xor		ecx,ecx
					.if pt.x>30 && pt.x<60
						inc		ecx
					.endif
					pop		eax
				.endif
				.if ecx
					.if eax==4
						mov		eax,tempcol.cmntback
					.elseif eax==5
						mov		eax,tempcol.strback
					.elseif eax==6
						mov		eax,tempcol.oprback
					.elseif eax==13
						mov		eax,tempcol.numback
					.endif
				.else
					invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETITEMDATA,eax,0
					xor		ecx,ecx
				.endif
				push	ecx
				push	eax
				;Mask off font
				and		eax,0FFFFFFh
				mov		cc.rgbResult,eax
				invoke ChooseColor,addr cc
				pop		ecx
				pop		edx
				.if eax
					push	edx
					push	ecx
					invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETCURSEL,0,0
					pop		ecx
					pop		edx
					.if edx
						mov		edx,cc.rgbResult
						.if eax==4
							mov		tempcol.cmntback,edx
						.elseif eax==5
							mov		tempcol.strback,edx
						.elseif eax==6
							mov		tempcol.oprback,edx
						.elseif eax==13
							mov		tempcol.numback,edx
						.endif
					.else
						mov		edx,cc.rgbResult
						;Font
						and		ecx,0FF000000h
						or		edx,ecx
						invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_SETITEMDATA,eax,edx
					.endif
					invoke GetDlgItem,hWin,IDC_LSTCOLORS
					invoke InvalidateRect,eax,NULL,FALSE
					mov		eax,IDC_BTNKWAPPLY
					mov		edx,TRUE
					call	EnButton
				.endif
			.endif
		.endif
	.elseif eax==WM_DRAWITEM
		push	esi
		mov		esi,lParam
		assume esi:ptr DRAWITEMSTRUCT
		test	[esi].itemState,ODS_SELECTED
		.if ZERO?
			push	COLOR_WINDOW
			mov		eax,COLOR_WINDOWTEXT
		.else
			push	COLOR_HIGHLIGHT
			mov		eax,COLOR_HIGHLIGHTTEXT
		.endif
		invoke GetSysColor,eax
		invoke SetTextColor,[esi].hdc,eax
		pop		eax
		invoke GetSysColor,eax
		invoke SetBkColor,[esi].hdc,eax
		invoke ExtTextOut,[esi].hdc,0,0,ETO_OPAQUE,addr [esi].rcItem,NULL,0,NULL
		mov		eax,[esi].rcItem.left
		inc		eax
		mov		rect.left,eax
		add		eax,25
		mov		rect.right,eax
		mov		eax,[esi].rcItem.top
		inc		eax
		mov		rect.top,eax
		mov		eax,[esi].rcItem.bottom
		dec		eax
		mov		rect.bottom,eax
		mov		eax,[esi].itemData
		and		eax,0FFFFFFh
		invoke CreateSolidBrush,eax
		mov		hBr,eax
		invoke FillRect,[esi].hdc,addr rect,hBr
		invoke DeleteObject,hBr
		invoke GetStockObject,BLACK_BRUSH
		invoke FrameRect,[esi].hdc,addr rect,eax
		.if [esi].CtlID==IDC_LSTCOLORS
			mov		ecx,[esi].itemID
			.if (ecx>=4 && ecx<=6) || ecx==13
				add		rect.left,30
				add		rect.right,30
				.if ecx==4
					mov		eax,tempcol.cmntback
				.elseif ecx==5
					mov		eax,tempcol.strback
				.elseif ecx==6
					mov		eax,tempcol.oprback
				.elseif ecx==13
					mov		eax,tempcol.numback
				.endif
				and		eax,0FFFFFFh
				invoke CreateSolidBrush,eax
				mov		hBr,eax
				invoke FillRect,[esi].hdc,addr rect,hBr
				invoke DeleteObject,hBr
				invoke GetStockObject,BLACK_BRUSH
				invoke FrameRect,[esi].hdc,addr rect,eax
			.endif
		.endif
		invoke SendMessage,[esi].hwndItem,LB_GETTEXT,[esi].itemID,addr buffer
		invoke strlen,addr buffer
		mov		edx,[esi].rcItem.left
		mov		ecx,[esi].itemID
		.if [esi].CtlID==IDC_LSTCOLORS
			.if (ecx>=4 && ecx<=6) || ecx==13
				add		edx,30
			.endif
		.endif
		add		edx,30
		invoke TextOut,[esi].hdc,edx,[esi].rcItem.top,addr buffer,eax
		assume esi:nothing
		pop		esi
	.elseif eax==WM_CLOSE
		mov		hCFnt,0
		mov		hLFnt,0
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

EnButton:
	push	edx
	invoke GetDlgItem,hWin,eax
	pop		edx
	invoke EnableWindow,eax,edx
	retn

Update:
	invoke GetDlgItem,hWin,IDC_BTNKWAPPLY
	invoke IsWindowEnabled,eax
	.if eax
		mov		eax,IDC_BTNKWAPPLY
		xor		edx,edx
		call	EnButton
		invoke SaveKeyWordList,hWin,IDC_LSTKWACTIVE,nKWInx
		invoke SaveKeyWordList,hWin,IDC_LSTKWHOLD,16
		invoke UpdateKeyWords,hWin
		invoke GetDlgItemInt,hWin,IDC_EDTTABSIZE,NULL,FALSE
		mov		edopt.tabsize,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKEXPAND
		mov		edopt.exptabs,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKAUTOINDENT
		mov		edopt.indent,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKHILITELINE
		mov		edopt.hiliteline,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKHILITECMNT
		mov		edopt.hilitecmnt,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKSESSION
		mov		edopt.session,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKLINENUMBER
		mov		edopt.linenumber,eax
		push	edi
		mov		edi,offset col
		xor		eax,eax
	  @@:
		push	eax
		invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETITEMDATA,eax,0
		mov		[edi],eax
		pop		eax
		inc		eax
		.if eax==13
			add		edi,16
		.endif
		add		edi,4
		cmp		edi,offset col+sizeof col
		jc		@b
		mov		eax,tempcol.cmntback
		mov		col.racol.cmntback,eax
		mov		eax,tempcol.strback
		mov		col.racol.strback,eax
		mov		eax,tempcol.oprback
		mov		col.racol.oprback,eax
		mov		eax,tempcol.numback
		mov		col.racol.numback,eax
		pop		edi
		.if hCFnt
			invoke DeleteObject,ha.hFont
			invoke DeleteObject,ha.hIFont
			invoke GetObject,hCFnt,sizeof lfnt,offset lfnt
			mov		eax,hCFnt
			mov     ha.hFont,eax
			mov		lfnt.lfItalic,TRUE
			invoke CreateFontIndirect,offset lfnt
			mov     ha.hIFont,eax
			mov		lfnt.lfItalic,FALSE
			invoke RegSetValueEx,ha.hReg,addr szCodeFont,0,REG_BINARY,addr lfnt,sizeof lfnt
			mov		hCFnt,0
		.endif
		.if hLFnt
			invoke DeleteObject,ha.hLnrFont
			invoke GetObject,hLFnt,sizeof lfntlnr,offset lfntlnr
			mov		eax,hLFnt
			mov     ha.hLnrFont,eax
			invoke RegSetValueEx,ha.hReg,addr szLnrFont,0,REG_BINARY,addr lfntlnr,sizeof lfntlnr
			mov		hLFnt,0
		.endif
		invoke UpdateAll,WM_SETFONT,0
		invoke UpdateToolColors
		invoke SendMessage,ha.hOut,WM_SETFONT,ha.hFont,TRUE
		invoke SendMessage,ha.hDbgReg,WM_SETFONT,ha.hFont,TRUE
		invoke SendMessage,ha.hDbgMMX,WM_SETFONT,ha.hFont,TRUE
		invoke SendMessage,ha.hDbgWatch,WM_SETFONT,ha.hFont,TRUE
		invoke RegSetValueEx,ha.hReg,addr szEditOpt,0,REG_BINARY,addr edopt,sizeof edopt
		invoke RegSetValueEx,ha.hReg,addr szColor,0,REG_BINARY,addr col,sizeof col
		invoke RegSetValueEx,ha.hReg,addr szCustColors,0,REG_BINARY,addr CustColors,sizeof CustColors
		invoke SaveTheme
	.endif
	retn

KeyWordsProc endp
