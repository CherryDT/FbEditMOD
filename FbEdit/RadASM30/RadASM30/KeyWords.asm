
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
IDC_BTNADDKW		equ 4011
IDC_BTNDELKW		equ 4010

IDC_CHKBOLD			equ 4004
IDC_CHKITALIC		equ 4003
IDC_CHKRCFILE		equ 4005
IDC_EDTCODEFILES	equ 4036
IDC_SPNTABSIZE		equ 4017
IDC_EDTTABSIZE		equ 4018
IDC_CHKEXPAND		equ 4019
IDC_CHKAUTOINDENT	equ 4020
IDC_CHKLINENUMBER	equ 4007
IDC_CHKHILITELINE	equ 4021
IDC_CHKHILITECMNT	equ 4026
IDC_CHKSESSION		equ 4006
IDC_CHKAUTOBRACE	equ 4034
IDC_CHKCODETIP		equ 4035
IDC_CHKMULTITAB		equ 4037
IDC_CHKAUTOCASE		equ 4038
IDC_BTNCODEFONT		equ 4024
IDC_STCCODEFONT		equ 4022
IDC_BTNLNRFONT		equ 4025
IDC_STCLNRFONT		equ 4023

IDC_RBNCODE			equ 4030
IDC_RBNTEXT			equ 4031
IDC_RBNHEX			equ 4032
IDC_RBNTOOLS		equ 4033

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
szGroup				db 'Group#%d',0

szNewTheme			db 'New Theme',0
deftheme			db 'Default',0
					dd 00804000h,00808000h,00FF0000h,00FF0000h,00FF0000h,10FF0000h,000040FFh,00FF0000h,01FF0000h,00FF0000h,00A00000h,00A00000h,00A00000h,00A00000h,00A00000h,00A00000h
					dd 00C0F0F0h,00000000h,00800000h,00FFFFFFh,02808040h,00A00000h,000000A0h,00F0C0C0h,00C0F0C0h,00C0C0F0h,00C0C0C0h,00808080h,00800000h,00808080h,00C0F0F0h,00C0F0F0h,00C0F0F0h,00C0F0F0h,0000F0F0h,0000F000h
					dd 00C0F0F0h,00000000h,00C0F0F0h,00000000h,00804000h,00C00000h,00FFFFFFh,00000000h,00C0F0F0h,00000000h,00404080h,00FF0000h
					db 'Black Night',0
					dd 0000FF00h,00FFFF80h,00FFFF00h,00FFFF00h,00FFFF00h,10FF0000h,004080FFh,00FF8080h,01FF0000h,00FF00FFh,00FF0000h,00FF0000h,00FF0000h,00FF0000h,00FF0000h,00FF0000h
					dd 00000000h,00C0C0C0h,00800000h,00FFFFFFh,0280FFFFh,00FFFFFFh,000000FFh,004A4A4Ah,00C0F0C0h,00181869h,00E0E0E0h,00808080h,00800000h,00808080h,00000000h,00000000h,00000000h,00000000h,0000F0F0h,0000F000h
					dd 00C6FFFFh,00000000h,00C6FFFFh,00000000h,00804000h,00C00000h,00C6FFFFh,00000000h,00C0F0F0h,00000000h,00404080h,00FF0000h
					db 'Visual Studio',0
					dd 00800040h,00800040h,00800040h,00800040h,00800040h,10800040h,00800040h,00800040h,01800040h,00800040h,00800040h,00800040h,00800040h,00800040h,00800040h,00800040h
					dd 00FFFFFFh,00000000h,00800000h,00FFFFFFh,02008000h,00A00000h,000000A0h,00F0C0C0h,00C0F0C0h,00C0C0F0h,00E0E0E0h,00808080h,00800000h,00808080h,00FFFFFFh,00FFFFFFh,00FFFFFFh,00FFFFFFh,0000F0F0h,0000F000h
					dd 00FFFFFFh,00000000h,00FFFFFFh,00000000h,00804000h,00C00000h,00FFFFFFh,00000000h,00C0F0F0h,00000000h,00404080h,00FF0000h

.data?

nKWInx				dd ?
CustColors			dd 16 dup(?)
hCFnt				HFONT ?
hTFnt				HFONT ?
hHFnt				HFONT ?
hTLFnt				HFONT ?
hLFnt				HFONT ?
tempcol				RACOLOR <?>
theme				THEME 10 dup(<>)
hMemKW				HGLOBAL ?

.code

GetThemes proc uses ebx esi edi
	LOCAL	nInx:DWORD
	LOCAL	buffer[32]:BYTE

	mov		nInx,0
	mov		edi,offset theme
	.while nInx<10
		invoke BinToDec,nInx,addr buffer
		invoke GetPrivateProfileString,addr szIniTheme,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szRadASMIni
		.if !eax && nInx==0
			;No themes, get default themes
			mov		esi,offset deftheme
			xor		ebx,ebx
			.while ebx<3
				invoke strcpy,addr [edi].THEME.szname,esi
				invoke strlen,esi
				lea		esi,[esi+eax+1]
				invoke RtlMoveMemory,addr [edi].THEME.radcol,esi,sizeof RADCOLOR
				lea		edi,[edi+sizeof THEME]
				lea		esi,[esi+sizeof RADCOLOR]
				inc		ebx
			.endw
			jmp		Ex
		.endif
		invoke BinToDec,nInx,addr buffer
		invoke GetPrivateProfileString,addr szIniTheme,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szRadASMIni
		.if eax
			invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].THEME.szname,sizeof THEME.szname
			xor		ebx,ebx
			.while ebx<sizeof RADCOLOR/4
				invoke GetItemInt,addr tmpbuff,0
				mov		[edi].THEME.radcol.kwcol[ebx*4],eax
				inc		ebx
			.endw
		.endif
		add		edi,sizeof THEME
		inc		nInx
	.endw
  Ex:
	ret

GetThemes endp

SetTheme proc uses ebx esi edi,hWin:HWND,nInx:DWORD

	;Keyword colors
	lea		esi,theme.radcol.kwcol
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
	lea		esi,theme.radcol.racol
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

	lea		esi,theme.radcol.racol
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
					mov		[esi].THEME.radcol.kwcol[ebx*4],eax
					inc		ebx
				.endw
				xor		ebx,ebx
				.while ebx<28
					invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETITEMDATA,ebx,0
					.if ebx<=13
						mov		[esi].THEME.radcol.racol.bckcol[ebx*4],eax
					.else
						mov		[esi].THEME.radcol.racol.bckcol[ebx*4+16],eax
					.endif
					inc		ebx
				.endw
				mov		eax,tempcol.cmntback
				mov		[esi].THEME.radcol.racol.cmntback,eax
				mov		eax,tempcol.strback
				mov		[esi].THEME.radcol.racol.strback,eax
				mov		eax,tempcol.numback
				mov		[esi].THEME.radcol.racol.numback,eax
				mov		eax,tempcol.oprback
				mov		[esi].THEME.radcol.racol.oprback,eax
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

SaveThemes proc uses ebx esi
	LOCAL	nInx:DWORD
	LOCAL	buffer[32]:BYTE

	mov		nInx,0
	mov		esi,offset theme
	.while nInx<10
		.if byte ptr [esi].THEME.szname
			mov		tmpbuff,0
			invoke PutItemStr,addr tmpbuff,addr [esi].THEME.szname
			xor		ebx,ebx
			.while ebx<sizeof RADCOLOR/4
				mov		eax,[esi].THEME.radcol.kwcol[ebx*4]
				invoke PutItemInt,addr tmpbuff,eax
				inc		ebx
			.endw
			invoke BinToDec,nInx,addr buffer
			invoke WritePrivateProfileString,addr szIniTheme,addr buffer,addr tmpbuff[1],addr da.szRadASMIni
		.endif
		add		esi,sizeof THEME
		inc		nInx
	.endw
	ret

SaveThemes endp

SetKeyWordList proc uses esi edi,hWin:HWND,idLst:DWORD,nInx:DWORD
	LOCAL	buffer[64]:BYTE

	invoke SendDlgItemMessage,hWin,idLst,LB_RESETCONTENT,0,0
	mov		eax,nInx
	mov		nKWInx,eax
	mov		esi,hMemKW
	mov		edx,32768
	mul		edx
	add		esi,eax
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
	ret

SetKeyWordList endp

GetKeyWordList proc uses esi edi,hWin:HWND,idLst:DWORD,nInx:DWORD

	mov		edi,hMemKW
	mov		eax,32768
	mov		edx,nInx
	mul		edx
	add		edi,eax
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
	.elseif esi
		mov		byte ptr [edi-1],0
	.endif
	ret

GetKeyWordList endp

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

UpdateToolColors proc
	LOCAL	racol:RACOLOR
	LOCAL	cccol:CC_COLOR
	LOCAL	ttcol:TT_COLOR

	invoke SendMessage,ha.hOutput,REM_GETCOLOR,0,addr racol
	mov		eax,da.radcolor.toolback
	mov		racol.bckcol,eax
	mov		racol.cmntback,eax
	mov		racol.strback,eax
	mov		racol.numback,eax
	mov		racol.oprback,eax
	mov		eax,da.radcolor.tooltext
	mov		racol.txtcol,eax
	invoke SendMessage,ha.hOutput,REM_SETCOLOR,0,addr racol
	invoke SendMessage,ha.hImmediate,REM_SETCOLOR,0,addr racol
	invoke SendMessage,ha.hREGDebug,REM_SETCOLOR,0,addr racol
	invoke SendMessage,ha.hFPUDebug,REM_SETCOLOR,0,addr racol
	invoke SendMessage,ha.hMMXDebug,REM_SETCOLOR,0,addr racol
	invoke SendMessage,ha.hWATCHDebug,REM_SETCOLOR,0,addr racol
	;Set tool colors
	invoke SendMessage,ha.hFileBrowser,FBM_SETBACKCOLOR,0,da.radcolor.toolback
	invoke SendMessage,ha.hFileBrowser,FBM_SETTEXTCOLOR,0,da.radcolor.tooltext
	invoke SendMessage,ha.hProjectBrowser,RPBM_SETBACKCOLOR,0,da.radcolor.toolback
	invoke SendMessage,ha.hProjectBrowser,RPBM_SETTEXTCOLOR,0,da.radcolor.tooltext
	invoke SendMessage,ha.hProperty,PRM_SETBACKCOLOR,0,da.radcolor.toolback
	invoke SendMessage,ha.hProperty,PRM_SETTEXTCOLOR,0,da.radcolor.tooltext
	;Code complete
	mov		eax,da.radcolor.ccback
	mov		cccol.back,eax
	mov		eax,da.radcolor.cctext
	mov		cccol.text,eax
	invoke SendMessage,ha.hCC,CCM_SETCOLOR,0,addr cccol
	mov		eax,da.radcolor.ttback
	mov		ttcol.back,eax
	mov		eax,da.radcolor.tttext
	mov		ttcol.text,eax
	mov		eax,da.radcolor.ttapi
	mov		ttcol.api,eax
	mov		eax,da.radcolor.ttsel
	mov		ttcol.hilite,eax
	invoke SendMessage,ha.hTT,TTM_SETCOLOR,0,addr ttcol
	ret

UpdateToolColors endp

UpdateToolFont proc

	invoke SendMessage,ha.hTabProject,WM_SETFONT,ha.hToolFont,TRUE
	invoke SendMessage,ha.hProperty,WM_SETFONT,ha.hToolFont,TRUE
	invoke SendMessage,ha.hTabOutput,WM_SETFONT,ha.hToolFont,TRUE
	invoke SendMessage,ha.hTab,WM_SETFONT,ha.hToolFont,TRUE
	invoke SendMessage,ha.hCboBuild,WM_SETFONT,ha.hToolFont,TRUE
	invoke SendMessage,ha.hProperty,PRM_REFRESHLIST,0,0
	invoke SendMessage,ha.hOutput,REM_SETFONT,0,addr ha.racf
	invoke SendMessage,ha.hImmediate,REM_SETFONT,0,addr ha.racf
	ret

UpdateToolFont endp

KeyWordsProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
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
		invoke GetWindowText,hWin,addr buffer,sizeof buffer
		invoke strcat,addr buffer,addr da.szAssembler
		invoke SetWindowText,hWin,addr buffer
		;Get Keywords
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,32768*17
		mov		hMemKW,eax
		xor		ebx,ebx
		.while ebx<17
			mov		buffer,'C'
			invoke BinToDec,ebx,addr buffer[1]
			mov		edi,hMemKW
			mov		eax,32768
			mul		ebx
			add		edi,eax
			invoke GetPrivateProfileString,addr szIniKeywords,addr buffer,addr szNULL,edi,32767,addr da.szAssemblerIni
			inc		ebx
		.endw
		mov		esi,offset da.radcolor.racol
		mov		edi,offset tempcol
		mov		ecx,sizeof RACOLOR
		rep		movsb
        invoke SendDlgItemMessage,hWin,IDC_SPNTABSIZE,UDM_SETRANGE,0,00010014h		; Set range
        invoke SendDlgItemMessage,hWin,IDC_SPNTABSIZE,UDM_SETPOS,0,da.edtopt.tabsize	; Set default value
		mov		eax,da.edtopt.fopt
		and		eax,EDTOPT_EXPTAB
		invoke CheckDlgButton,hWin,IDC_CHKEXPAND,eax
		mov		eax,da.edtopt.fopt
		and		eax,EDTOPT_INDENT
		invoke CheckDlgButton,hWin,IDC_CHKAUTOINDENT,eax
		mov		eax,da.edtopt.fopt
		and		eax,EDTOPT_CASECONVERT
		invoke CheckDlgButton,hWin,IDC_CHKAUTOCASE,eax
		mov		eax,da.edtopt.fopt
		and		eax,EDTOPT_LINEHI
		invoke CheckDlgButton,hWin,IDC_CHKHILITELINE,eax
		mov		eax,da.edtopt.fopt
		and		eax,EDTOPT_CMNTHI
		invoke CheckDlgButton,hWin,IDC_CHKHILITECMNT,eax
		mov		eax,da.edtopt.fopt
		and		eax,EDTOPT_SESSION
		invoke CheckDlgButton,hWin,IDC_CHKSESSION,eax
		mov		eax,da.edtopt.fopt
		and		eax,EDTOPT_LINENR
		invoke CheckDlgButton,hWin,IDC_CHKLINENUMBER,eax
		invoke CheckDlgButton,hWin,IDC_RBNCODE,eax
		mov		eax,da.edtopt.fopt
		and		eax,EDTOPT_BRACE
		invoke CheckDlgButton,hWin,IDC_CHKAUTOBRACE,eax
		mov		eax,da.edtopt.fopt
		and		eax,EDTOPT_SHOWTIP
		invoke CheckDlgButton,hWin,IDC_CHKCODETIP,eax
		mov		eax,da.win.fView
		and		eax,VIEW_MULTITAB
		invoke CheckDlgButton,hWin,IDC_CHKMULTITAB,eax
		mov		esi,offset szColors
		mov		edi,offset da.radcolor.racol
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
		mov		edi,offset da.radcolor.kwcol
		mov		nInx,0
		.while nInx<16
			invoke wsprintf,addr buffer,addr szGroup,nInx
			invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_ADDSTRING,0,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,eax,[edi]
			add		edi,4
			inc		nInx
		.endw
		invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETCURSEL,0,0
		invoke SetKeyWordList,hWin,IDC_LSTKWHOLD,16
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
		invoke SendDlgItemMessage,hWin,IDC_EDTCODEFILES,EM_LIMITTEXT,sizeof da.szCodeFiles-1,0
		invoke SetDlgItemText,hWin,IDC_EDTCODEFILES,addr da.szCodeFiles
		invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_SETCURSEL,0,0
		mov		eax,IDC_BTNKWAPPLY
		xor		edx,edx
		call	EnButton
		invoke SendDlgItemMessage,hWin,IDC_STCCODEFONT,WM_SETFONT,ha.racf.hFont,FALSE
		invoke SendDlgItemMessage,hWin,IDC_STCLNRFONT,WM_SETFONT,ha.racf.hLnrFont,FALSE
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
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
				mov		eax,IDC_BTNDELKW
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
			.elseif eax==IDC_BTNADDKW
				invoke GetDlgItemText,hWin,IDC_EDTKW,addr buffer,64
				invoke SendDlgItemMessage,hWin,IDC_LSTKWACTIVE,LB_ADDSTRING,0,addr buffer
				mov		buffer,0
				invoke SetDlgItemText,hWin,IDC_EDTKW,addr buffer
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_BTNDELKW
				invoke DeleteKeyWords,hWin,IDC_LSTKWACTIVE
				mov		eax,IDC_BTNHOLD
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNDELKW
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
			.elseif eax==IDC_CHKAUTOCASE
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
			.elseif eax==IDC_CHKAUTOBRACE
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKCODETIP
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKMULTITAB
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_BTNCODEFONT
				invoke IsDlgButtonChecked,hWin,IDC_RBNCODE
				.if eax
					mov		edi,offset hCFnt
				.endif
				invoke IsDlgButtonChecked,hWin,IDC_RBNTEXT
				.if eax
					mov		edi,offset hTFnt
				.endif
				invoke IsDlgButtonChecked,hWin,IDC_RBNHEX
				.if eax
					mov		edi,offset hHFnt
				.endif
				invoke IsDlgButtonChecked,hWin,IDC_RBNTOOLS
				.if eax
					mov		edi,offset hTLFnt
				.endif
				invoke SendDlgItemMessage,hWin,IDC_STCCODEFONT,WM_GETFONT,0,0
				mov		edx,eax
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
					mov		eax,[edi]
					.if eax!=ha.racf.hFont && eax!=ha.ratf.hFont && eax!=ha.rahf.hFont && eax!=ha.hToolFont
						invoke DeleteObject,eax
					.endif
					invoke CreateFontIndirect,addr lf
					mov     [edi],eax
					invoke SendDlgItemMessage,hWin,IDC_STCCODEFONT,WM_SETFONT,eax,TRUE
					mov		eax,IDC_BTNKWAPPLY
					mov		edx,TRUE
					call	EnButton
				.endif
			.elseif eax==IDC_BTNLNRFONT
				mov		edx,hLFnt
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
					mov		edx,ha.racf.hLnrFont
					.if edx!=hLFnt
						invoke DeleteObject,hLFnt
					.endif
					invoke CreateFontIndirect,addr lf
					mov     hLFnt,eax
					invoke SendDlgItemMessage,hWin,IDC_STCLNRFONT,WM_SETFONT,hLFnt,TRUE
					mov		eax,IDC_BTNKWAPPLY
					mov		edx,TRUE
					call	EnButton
				.endif
			.elseif eax==IDC_RBNCODE
				mov		edx,hCFnt
				.if !edx
					mov		edx,ha.racf.hFont
				.endif
				call	UpdateButton
			.elseif eax==IDC_RBNTEXT
				mov		edx,hTFnt
				.if !edx
					mov		edx,ha.ratf.hFont
				.endif
				call	UpdateButton
			.elseif eax==IDC_RBNHEX
				mov		edx,hHFnt
				.if !edx
					mov		edx,ha.rahf.hFont
				.endif
				call	UpdateButton
			.elseif eax==IDC_RBNTOOLS
				mov		edx,hTLFnt
				.if !edx
					mov		edx,ha.hToolFont
				.endif
				call	UpdateButton
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTKW
				invoke SendDlgItemMessage,hWin,IDC_EDTKW,WM_GETTEXTLENGTH,0,0
				.if eax
					mov		eax,TRUE
				.endif
				mov		edx,eax
				mov		eax,IDC_BTNADDKW
				call	EnButton
			.elseif eax==IDC_EDTTABSIZE
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_EDTCODEFILES
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.endif
		.elseif edx==LBN_SELCHANGE
			.if eax==IDC_LSTKWCOLORS
				invoke GetKeyWordList,hWin,IDC_LSTKWACTIVE,nKWInx
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				invoke SetKeyWordList,hWin,IDC_LSTKWACTIVE,eax
				invoke GetDlgItem,hWin,IDC_BTNHOLD
				invoke EnableWindow,eax,FALSE
				invoke GetDlgItem,hWin,IDC_BTNDELKW
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
				mov		eax,IDC_BTNDELKW
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
		invoke GlobalFree,hMemKW
		mov		hMemKW,0
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

UpdateButton:
	mov		ebx,eax
	invoke SendDlgItemMessage,hWin,IDC_STCCODEFONT,WM_SETFONT,edx,TRUE
	invoke GetDlgItemText,hWin,ebx,addr buffer,sizeof buffer
	invoke SetDlgItemText,hWin,IDC_BTNCODEFONT,addr buffer
	retn

Update:
	invoke GetDlgItem,hWin,IDC_BTNKWAPPLY
	invoke IsWindowEnabled,eax
	.if eax
		mov		eax,IDC_BTNKWAPPLY
		xor		edx,edx
		call	EnButton
		;Save themes
		invoke SaveThemes
		;Save keywords
		invoke GetKeyWordList,hWin,IDC_LSTKWACTIVE,nKWInx
		mov		esi,hMemKW
		xor		ebx,ebx
		.while ebx<17
			mov		buffer,'C'
			invoke BinToDec,ebx,addr buffer[1]
			invoke WritePrivateProfileString,addr szIniKeywords,addr buffer,esi,addr da.szAssemblerIni
			inc		ebx
			add		esi,32768
		.endw
		;Get keyword colors
		xor		ebx,ebx
		.while ebx<16
			invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,ebx,0
			mov		da.radcolor.kwcol[ebx*4],eax
			inc		ebx
		.endw
		;Get colors
		mov		edi,offset da.radcolor.racol
		xor		ebx,ebx
		.while ebx<28
			invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETITEMDATA,ebx,0
			mov		[edi],eax
			add		edi,4
			.if ebx==13
				add		edi,16
			.endif
			inc		ebx
		.endw
		;Get back colors
		mov		eax,tempcol.cmntback
		mov		da.radcolor.racol.cmntback,eax
		mov		eax,tempcol.strback
		mov		da.radcolor.racol.strback,eax
		mov		eax,tempcol.oprback
		mov		da.radcolor.racol.oprback,eax
		mov		eax,tempcol.numback
		mov		da.radcolor.racol.numback,eax
		;Save colors
		mov		tmpbuff,0
		xor		ebx,ebx
		.while ebx<sizeof RADCOLOR/4
			mov		eax,dword ptr da.radcolor[ebx*4]
			invoke PutItemInt,addr tmpbuff,eax
			inc		ebx
		.endw
		invoke WritePrivateProfileString,addr szIniColors,addr szIniColors,addr tmpbuff[1],addr da.szAssemblerIni
		;Get edit options
		invoke GetDlgItemInt,hWin,IDC_EDTTABSIZE,NULL,FALSE
		mov		da.edtopt.tabsize,eax
		mov		da.edtopt.fopt,0
		invoke IsDlgButtonChecked,hWin,IDC_CHKEXPAND
		.if eax
			or		da.edtopt.fopt,EDTOPT_EXPTAB
		.endif
		invoke IsDlgButtonChecked,hWin,IDC_CHKAUTOINDENT
		.if eax
			or		da.edtopt.fopt,EDTOPT_INDENT
		.endif
		invoke IsDlgButtonChecked,hWin,IDC_CHKHILITELINE
		.if eax
			or		da.edtopt.fopt,EDTOPT_LINEHI
		.endif
		invoke IsDlgButtonChecked,hWin,IDC_CHKHILITECMNT
		.if eax
			or		da.edtopt.fopt,EDTOPT_CMNTHI
		.endif
		invoke IsDlgButtonChecked,hWin,IDC_CHKSESSION
		.if eax
			or		da.edtopt.fopt,EDTOPT_SESSION
		.endif
		invoke IsDlgButtonChecked,hWin,IDC_CHKLINENUMBER
		.if eax
			or		da.edtopt.fopt,EDTOPT_LINENR
		.endif
		invoke IsDlgButtonChecked,hWin,IDC_CHKAUTOBRACE
		.if eax
			or		da.edtopt.fopt,EDTOPT_BRACE
		.endif
		invoke IsDlgButtonChecked,hWin,IDC_CHKCODETIP
		.if eax
			or		da.edtopt.fopt,EDTOPT_SHOWTIP
		.endif
		invoke IsDlgButtonChecked,hWin,IDC_CHKAUTOCASE
		.if eax
			or		da.edtopt.fopt,EDTOPT_CASECONVERT
		.endif
		and		da.win.fView,-1 xor VIEW_MULTITAB
		invoke IsDlgButtonChecked,hWin,IDC_CHKMULTITAB
		.if eax
			or		da.win.fView,VIEW_MULTITAB
		.endif
		;Save edit options
		mov		tmpbuff,0
		invoke PutItemInt,addr tmpbuff,da.edtopt.tabsize
		invoke PutItemInt,addr tmpbuff,da.edtopt.fopt
		invoke WritePrivateProfileString,addr szIniEdit,addr szIniOption,addr tmpbuff[1],addr da.szAssemblerIni
		;Save fonts
		.if hCFnt
			invoke DeleteObject,ha.racf.hFont
			invoke DeleteObject,ha.racf.hIFont
			invoke GetObject,hCFnt,sizeof LOGFONT,addr lf
			mov		eax,hCFnt
			mov     ha.racf.hFont,eax
			mov		lf.lfItalic,TRUE
			invoke CreateFontIndirect,addr lf
			mov     ha.racf.hIFont,eax
			mov		lf.lfItalic,FALSE
			mov		hCFnt,0
			mov		tmpbuff,0
			invoke PutItemStr,addr tmpbuff,addr lf.lfFaceName
			mov		eax,lf.lfHeight
			invoke PutItemInt,addr tmpbuff,eax
			movzx	eax,lf.lfCharSet
			invoke PutItemInt,addr tmpbuff,eax
			mov		eax,lf.lfWeight
			invoke PutItemInt,addr tmpbuff,eax
			invoke WritePrivateProfileString,addr szIniFont,addr szIniCode,addr tmpbuff[1],addr da.szRadASMIni
		.endif
		.if hTFnt
			invoke DeleteObject,ha.ratf.hFont
			invoke DeleteObject,ha.ratf.hIFont
			invoke GetObject,hTFnt,sizeof LOGFONT,addr lf
			mov		eax,hTFnt
			mov     ha.ratf.hFont,eax
			mov		lf.lfItalic,TRUE
			invoke CreateFontIndirect,addr lf
			mov     ha.ratf.hIFont,eax
			mov		lf.lfItalic,FALSE
			mov		hTFnt,0
			mov		tmpbuff,0
			invoke PutItemStr,addr tmpbuff,addr lf.lfFaceName
			mov		eax,lf.lfHeight
			invoke PutItemInt,addr tmpbuff,eax
			movzx	eax,lf.lfCharSet
			invoke PutItemInt,addr tmpbuff,eax
			mov		eax,lf.lfWeight
			invoke PutItemInt,addr tmpbuff,eax
			invoke WritePrivateProfileString,addr szIniFont,addr szIniText,addr tmpbuff[1],addr da.szRadASMIni
		.endif
		.if hHFnt
			invoke DeleteObject,ha.rahf.hFont
			invoke GetObject,hHFnt,sizeof LOGFONT,addr lf
			mov		eax,hHFnt
			mov     ha.rahf.hFont,eax
			mov		hHFnt,0
			mov		tmpbuff,0
			invoke PutItemStr,addr tmpbuff,addr lf.lfFaceName
			mov		eax,lf.lfHeight
			invoke PutItemInt,addr tmpbuff,eax
			movzx	eax,lf.lfCharSet
			invoke PutItemInt,addr tmpbuff,eax
			mov		eax,lf.lfWeight
			invoke PutItemInt,addr tmpbuff,eax
			invoke WritePrivateProfileString,addr szIniFont,addr szIniHex,addr tmpbuff[1],addr da.szRadASMIni
		.endif
		.if hTLFnt
			invoke DeleteObject,ha.hToolFont
			invoke GetObject,hTLFnt,sizeof LOGFONT,addr lf
			mov		eax,hTLFnt
			mov     ha.hToolFont,eax
			mov		hTLFnt,0
			mov		tmpbuff,0
			invoke PutItemStr,addr tmpbuff,addr lf.lfFaceName
			mov		eax,lf.lfHeight
			invoke PutItemInt,addr tmpbuff,eax
			movzx	eax,lf.lfCharSet
			invoke PutItemInt,addr tmpbuff,eax
			mov		eax,lf.lfWeight
			invoke PutItemInt,addr tmpbuff,eax
			invoke WritePrivateProfileString,addr szIniFont,addr szIniTool,addr tmpbuff[1],addr da.szRadASMIni
		.endif
		.if hLFnt
			invoke DeleteObject,ha.racf.hLnrFont
			invoke GetObject,hLFnt,sizeof LOGFONT,addr lf
			mov		eax,hLFnt
			mov     ha.racf.hLnrFont,eax
			mov		ha.ratf.hLnrFont,eax
			mov		ha.rahf.hLnrFont,eax
			mov		hLFnt,0
			mov		tmpbuff,0
			invoke PutItemStr,addr tmpbuff,addr lf.lfFaceName
			mov		eax,lf.lfHeight
			invoke PutItemInt,addr tmpbuff,eax
			movzx	eax,lf.lfCharSet
			invoke PutItemInt,addr tmpbuff,eax
			mov		eax,lf.lfWeight
			invoke PutItemInt,addr tmpbuff,eax
			invoke WritePrivateProfileString,addr szIniFont,addr szIniLine,addr tmpbuff[1],addr da.szRadASMIni
		.endif
		invoke GetDlgItemText,hWin,IDC_EDTCODEFILES,addr da.szCodeFiles,sizeof da.szCodeFiles
		invoke WritePrivateProfileString,addr szIniFile,addr szIniCode,addr da.szCodeFiles,addr da.szAssemblerIni
		;Set tool colors
		invoke GetKeywords
		invoke UpdateToolColors
		invoke UpdateAll,UAM_SETCOLORS,0
		invoke UpdateAll,UAM_SETFONTS,0
		invoke UpdateToolFont
		test	da.win.fView,VIEW_MULTITAB
		.if ZERO?
			mov		edx,WS_VISIBLE or WS_CHILD or WS_CLIPSIBLINGS or WS_CLIPCHILDREN or TCS_FOCUSNEVER or TCS_BUTTONS
		.else
			mov		edx,WS_VISIBLE or WS_CHILD or WS_CLIPSIBLINGS or WS_CLIPCHILDREN or TCS_FOCUSNEVER or TCS_BUTTONS or TCS_MULTILINE
		.endif
		invoke SetWindowLong,ha.hTab,GWL_STYLE,edx
	.endif
	retn

KeyWordsProc endp
