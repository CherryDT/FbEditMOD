
IDD_DLGPROGLANGUAGE			equ 4100
IDC_LSTPL					equ 1009
IDC_BTNPLUP					equ 1008
IDC_BTNPLDN					equ 1007
IDC_BTNPLDEL				equ 1003
IDC_EDTPLDESC				equ 1005

.const

szAllIni					BYTE '\*.ini',0

.data?

lpOldProgLangListProc		DWORD ?

.code

ProgLangListProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_LBUTTONDOWN
		invoke SetCapture,hWin
	.elseif eax==WM_LBUTTONUP
		mov		eax,lParam
		movsx	eax,ax
		.if sdword ptr eax>=1 && sdword ptr eax<=14
			invoke SendMessage,hWin,LB_GETCURSEL,0,0
			push	eax
			invoke SendMessage,hWin,LB_GETITEMDATA,eax,0
			xor		eax,1
			pop		edx
			invoke SendMessage,hWin,LB_SETITEMDATA,edx,eax
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		invoke ReleaseCapture
		invoke GetParent,hWin
		invoke SendMessage,eax,WM_COMMAND,LBN_SELCHANGE shl 16 or IDC_LSTPL,hWin
	.endif
	invoke CallWindowProc,lpOldProgLangListProc,hWin,uMsg,wParam,lParam
	ret

ProgLangListProc endp

ProgLangProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hLst:HWND
	LOCAL	wfd:WIN32_FIND_DATA
	LOCAL	hwfd:HANDLE
	LOCAL	nInx:DWORD
	LOCAL	rect:RECT
	LOCAL	szItem[MAX_PATH]:BYTE
	LOCAL	buff[MAX_PATH]:BYTE
	LOCAL	proglangfile[MAX_PATH]:BYTE
	LOCAL	proglang[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_LSTPL
		mov		hLst,eax
		invoke SetWindowLong,hLst,GWL_WNDPROC,offset ProgLangListProc
		mov		lpOldProgLangListProc,eax
		invoke RtlZeroMemory,addr proglang,sizeof proglang
		invoke strcpy,addr buff,addr da.szAssemblers
		.while buff
			invoke GetItemStr,addr buff,addr szNULL,addr wfd.cFileName,sizeof wfd.cFileName
			invoke strcat,addr wfd.cFileName,addr szDotIni
			invoke strcpy,addr proglangfile,addr da.szAppPath
			invoke strcat,addr proglangfile,addr szBS
			invoke strcat,addr proglangfile,addr wfd.cFileName
			call	IsProgLang
			.if eax
				invoke SendMessage,hLst,LB_ADDSTRING,0,addr wfd.cFileName
				mov		nInx,eax
				invoke SendMessage,hLst,LB_SETITEMDATA,nInx,TRUE
			.endif
		.endw
		invoke strcpy,addr buff,addr da.szAppPath
		invoke strcat,addr buff,addr szAllIni
		invoke FindFirstFile,addr buff,addr wfd
		.if eax!=INVALID_HANDLE_VALUE
			mov		hwfd,eax
			.while TRUE
				invoke strcpy,addr proglangfile,addr da.szAppPath
				invoke strcat,addr proglangfile,addr szBS
				invoke strcat,addr proglangfile,addr wfd.cFileName
				call	IsProgLang
				.if eax
					invoke SendMessage,hLst,LB_ADDSTRING,0,addr wfd.cFileName
					mov		nInx,eax
					invoke SendMessage,hLst,LB_SETITEMDATA,nInx,FALSE
				.endif
				invoke FindNextFile,hwfd,addr wfd
				.break .if !eax
			.endw
			invoke FindClose,hwfd
		.endif
		invoke SendMessage,hLst,LB_SETCURSEL,0,0
		invoke ImageList_GetIcon,ha.hMnuIml,2,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNPLUP,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,ha.hMnuIml,3,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNPLDN,BM_SETIMAGE,IMAGE_ICON,eax
		invoke SendMessage,hWin,WM_COMMAND,LBN_SELCHANGE shl 16 or IDC_LSTPL,hLst
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				mov		word ptr buff,0
				mov		nInx,0
				.while TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETTEXT,nInx,addr wfd.cFileName
					.break.if eax==LB_ERR
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETITEMDATA,nInx,0
					.if eax
						invoke RemoveFileExt,addr wfd.cFileName
						invoke PutItemStr,addr buff,addr wfd.cFileName
					.endif
					inc		nInx
				.endw
				invoke strcpy,addr da.szAssemblers,addr buff[1]
				invoke WritePrivateProfileString,addr szIniAssembler,addr szIniAssembler,addr da.szAssemblers,addr da.szRadASMIni
				invoke SetAssemblers
				invoke SendMessage,hWin,WM_CLOSE,NULL,TRUE
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNPLUP
				invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETCURSEL,0,0
				.if eax
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETTEXT,nInx,addr buff
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETITEMDATA,nInx,0
					push	eax
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_DELETESTRING,nInx,0
					dec		nInx
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_INSERTSTRING,nInx,addr buff
					pop		eax
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_SETITEMDATA,nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_SETCURSEL,nInx,0
				.endif
			.elseif eax==IDC_BTNPLDN
				invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETCURSEL,0,0
				mov		nInx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETCOUNT,0,0
				dec		eax
				.if eax!=nInx
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETTEXT,nInx,addr buff
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETITEMDATA,nInx,0
					push	eax
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_DELETESTRING,nInx,0
					inc		nInx
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_INSERTSTRING,nInx,addr buff
					pop		eax
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_SETITEMDATA,nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_SETCURSEL,nInx,0
				.endif
			.endif
		.elseif edx==LBN_SELCHANGE
			;Get description
			invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETCURSEL,0,0
			mov		edx,eax
			invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETTEXT,edx,addr wfd.cFileName
			invoke strcpy,addr proglangfile,addr da.szAppPath
			invoke strcat,addr proglangfile,addr szBS
			invoke strcat,addr proglangfile,addr wfd.cFileName
			invoke GetPrivateProfileString,addr szIniVersion,addr szIniDescription,addr szNULL,addr tmpbuff,256,addr proglangfile
			invoke ConvertCaption,addr buff,addr tmpbuff
			invoke SetDlgItemText,hWin,IDC_EDTPLDESC,addr buff
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,lParam
	.elseif eax==WM_DRAWITEM
		mov		esi,lParam
		; Select back and text colors
		mov		eax,[esi].DRAWITEMSTRUCT.itemState
		test	eax,ODS_SELECTED
		.If !ZERO?
			invoke GetSysColor,COLOR_HIGHLIGHTTEXT
			invoke SetTextColor,[esi].DRAWITEMSTRUCT.hdc,eax
			invoke GetSysColor,COLOR_HIGHLIGHT
			invoke SetBkColor,[esi].DRAWITEMSTRUCT.hdc,eax
		.else
			invoke GetSysColor,COLOR_WINDOWTEXT
			invoke SetTextColor,[esi].DRAWITEMSTRUCT.hdc,eax
			invoke GetSysColor,COLOR_WINDOW
			invoke SetBkColor,[esi].DRAWITEMSTRUCT.hdc,eax
		.endif
		; Draw selected / unselected back color
		invoke ExtTextOut,[esi].DRAWITEMSTRUCT.hdc,0,0,ETO_OPAQUE,addr [esi].DRAWITEMSTRUCT.rcItem,NULL,0,NULL
		; Draw the checkbox
		mov		eax,[esi].DRAWITEMSTRUCT.rcItem.left
		inc		eax
		mov		rect.left,eax
		add		eax,13
		mov		rect.right,eax
		mov		eax,[esi].DRAWITEMSTRUCT.rcItem.top
		inc		eax
		mov		rect.top,eax
		add		eax,13
		mov		rect.bottom,eax
		mov		eax,DFCS_BUTTONCHECK Or DFCS_FLAT
		.If [esi].DRAWITEMSTRUCT.itemData
			or		eax,DFCS_CHECKED
		.endif
		invoke DrawFrameControl,[esi].DRAWITEMSTRUCT.hdc,addr rect,DFC_BUTTON,eax
		; Draw the text
		invoke SendMessage,[esi].DRAWITEMSTRUCT.hwndItem,LB_GETTEXT,[esi].DRAWITEMSTRUCT.itemID,addr szItem
		mov		edx,[esi].DRAWITEMSTRUCT.rcItem.left
		add		edx,18
		invoke TextOut,[esi].DRAWITEMSTRUCT.hdc,edx,[esi].DRAWITEMSTRUCT.rcItem.top,addr szItem,eax
		invoke GetFocus
		.if eax==[esi].DRAWITEMSTRUCT.hwndItem
			; Let windows draw the focus rectangle
			xor		eax,eax
			jmp		Ex
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
  Ex:
	ret

IsProgLang:
	;Check if it is added
	lea		esi,proglang
	.while byte ptr [esi]
		invoke strcmpi,esi,addr wfd.cFileName
		.if !eax
			retn
		.endif
		invoke strlen,esi
		lea		esi,[esi+eax+1]
	.endw
	;Check if it is a programming language file
	invoke GetPrivateProfileInt,addr szIniVersion,addr szIniVersion,0,addr proglangfile
	.if eax>=3000
		invoke GetPrivateProfileString,addr szIniVersion,addr szIniDescription,addr szNULL,addr tmpbuff,256,addr proglangfile
		.if eax
			invoke strcpy,esi,addr wfd.cFileName
			mov		eax,TRUE
		.endif
	.else
		xor		eax,eax
	.endif
	retn

ProgLangProc endp

ResetEnvironment proc uses esi edi

	mov		edi,hEnv
	.if	edi
		.while byte	ptr	[edi]
			mov		esi,edi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			invoke SetEnvironmentVariable,edi,esi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			mov		edi,esi
		.endw
		invoke GlobalFree,hEnv
		xor		eax,eax
		mov		hEnv,eax
	.endif
	ret

ResetEnvironment endp

SetVar proc uses edi,lpSave:DWORD,lpName:DWORD,lpValue:DWORD

	mov		edi,lpSave
	mov		byte ptr tmpbuff[4096],0
	invoke GetEnvironmentVariable,lpName,addr tmpbuff[4096],1024
	invoke strcpy,edi,lpName
	invoke strlen,edi
	lea		edi,[edi+eax+1]
	invoke strcpy,edi,addr tmpbuff[4096]
	invoke strlen,edi
	lea		edi,[edi+eax+1]
	invoke strcpy,addr tmpbuff,lpValue
	.if byte ptr tmpbuff[4096]
		invoke strcat,addr tmpbuff,addr szSemi
		invoke strcat,addr tmpbuff,addr tmpbuff[4096]
	.endif
	invoke SetEnvironmentVariable,lpName,addr tmpbuff
	mov		eax,edi
	ret

SetVar endp

SetEnvironment proc uses ebx edi
	LOCAL	buffer[1536]:BYTE
	LOCAL	buffname[128]:BYTE

	;Environment
	invoke ResetEnvironment
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
	mov		hEnv,eax
	mov		edi,eax
	xor		ebx,ebx
	.while ebx<16
		invoke BinToDec,ebx,addr buffname
		invoke GetPrivateProfileString,addr szIniEnvironment,addr buffname,addr szNULL,addr buffer,sizeof buffer,addr da.szAssemblerIni
		.if eax
			invoke GetItemStr,addr buffer,addr szNULL,addr buffname,sizeof buffname
			invoke FixPath,addr buffer,addr da.szAppPath,addr szDollarA
			invoke SetVar,edi,addr buffname,addr buffer
			mov		edi,eax
		.endif
		inc		ebx
	.endw
	ret

SetEnvironment endp

GetColors proc uses ebx
	LOCAL	racolor:RACOLOR

	invoke GetPrivateProfileString,addr szIniColors,addr szIniColors,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
	.if eax
		xor		ebx,ebx
		.while ebx<sizeof RADCOLOR/4
			invoke GetItemInt,addr tmpbuff,0
			mov		dword ptr da.radcolor[ebx*4],eax
			inc		ebx
		.endw
	.else
		invoke RtlMoveMemory,addr da.radcolor,addr defcol,sizeof RADCOLOR
	.endif
	invoke SendMessage,ha.hOutput,REM_GETCOLOR,0,addr racolor
	mov		eax,da.radcolor.toolback
	mov		racolor.bckcol,eax
	mov		eax,da.radcolor.tooltext
	mov		racolor.txtcol,eax
	invoke SendMessage,ha.hOutput,REM_SETCOLOR,0,addr racolor
	invoke SendMessage,ha.hImmediate,REM_SETCOLOR,0,addr racolor
	invoke SendMessage,ha.hREGDebug,REM_SETCOLOR,0,addr racolor
	invoke SendMessage,ha.hFPUDebug,REM_SETCOLOR,0,addr racolor
	invoke SendMessage,ha.hMMXDebug,REM_SETCOLOR,0,addr racolor
	invoke SendMessage,ha.hWATCHDebug,REM_SETCOLOR,0,addr racolor
	invoke SendMessage,ha.hFileBrowser,FBM_SETBACKCOLOR,0,da.radcolor.toolback
	invoke SendMessage,ha.hFileBrowser,FBM_SETTEXTCOLOR,0,da.radcolor.tooltext
	invoke SendMessage,ha.hProjectBrowser,RPBM_SETBACKCOLOR,0,da.radcolor.toolback
	invoke SendMessage,ha.hProjectBrowser,RPBM_SETTEXTCOLOR,0,da.radcolor.tooltext
	invoke SendMessage,ha.hProperty,PRM_SETBACKCOLOR,0,da.radcolor.toolback
	invoke SendMessage,ha.hProperty,PRM_SETTEXTCOLOR,0,da.radcolor.tooltext
	ret

GetColors endp

DeleteDuplicates proc uses esi edi,lpszType:DWORD
	LOCAL	nCount:DWORD

	invoke SendMessage,ha.hProperty,PRM_GETSORTEDLIST,lpszType,addr nCount
	mov		esi,eax
	push	esi
	xor		ecx,ecx
	mov		edi,offset szNULL
	.while ecx<nCount
		push	ecx
		invoke strcmp,edi,[esi]
		.if !eax
			mov		eax,[esi]
			lea		eax,[eax-sizeof PROPERTIES]
			mov		[eax].PROPERTIES.nType,255
		.else
			mov		edi,[esi]
		.endif
		pop		ecx
		inc		ecx
		lea		esi,[esi+4]
	.endw
	pop		esi
	invoke GlobalFree,esi
	invoke SendMessage,ha.hProperty,PRM_COMPACTLIST,FALSE,0
	ret

DeleteDuplicates endp

GetCodeComplete proc uses ebx esi edi
	LOCAL	buffer[256]:BYTE
	LOCAL	apifile[MAX_PATH]:BYTE

	;Get invoke
	invoke GetPrivateProfileString,addr szIniCodeComplete,addr szIniTrig,NULL,addr da.szCCTrig,sizeof da.szCCTrig-1,addr da.szAssemblerIni
	mov		edi,offset da.szCCTrig
	.while byte ptr [edi]
		.if byte ptr [edi]==','
			mov		byte ptr [edi],0
		.endif
		inc		edi
	.endw
	mov		byte ptr [edi+1],0
	invoke GetPrivateProfileString,addr szIniCodeComplete,addr szIniInc,NULL,addr da.szCCInc,sizeof da.szCCInc,addr da.szAssemblerIni
	invoke GetPrivateProfileString,addr szIniCodeComplete,addr szIniLib,NULL,addr da.szCCLib,sizeof da.szCCLib,addr da.szAssemblerIni
	;Load api files
	invoke GetPrivateProfileString,addr szIniCodeComplete,addr szIniApi,NULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
	.if da.szPOApiFiles
		invoke strcat,addr tmpbuff,addr szComma
		invoke strcat,addr tmpbuff,addr da.szPOApiFiles
	.endif
	.while tmpbuff
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr buffer,sizeof buffer
		.if ebx && buffer
			invoke strcpy,addr apifile,addr da.szAppPath
			invoke strcat,addr apifile,addr szBSApiBS
			invoke strcat,addr apifile,addr buffer
			invoke SendMessage,ha.hProperty,PRM_ADDPROPERTYFILE,0,addr apifile
		.endif
	.endw
	;Add 'C' list to 'W' list
	mov		dword ptr buffer,'C'
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr buffer,addr buffer[1]
	.while eax
		mov		esi,eax
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		invoke strcpy,offset tmpbuff,esi
		mov		eax,2 shl 8 or 'W'
		invoke SendMessage,ha.hProperty,PRM_ADDPROPERTYLIST,eax,offset tmpbuff
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
	.endw
	;Add 'M' list to 'W' list
	mov		dword ptr buffer,'M'
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr buffer,addr buffer[1]
	.while eax
		mov		esi,eax
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		.while byte ptr [esi]
			.if byte ptr [esi]=='['
				inc		esi
				mov		edi,offset tmpbuff
				.while byte ptr [esi]!=']'
					mov		al,[esi]
					mov		[edi],al
					inc		esi
					inc		edi
				.endw
				mov		byte ptr [edi],0
				mov		eax,2 shl 8 or 'W'
				invoke SendMessage,ha.hProperty,PRM_ADDPROPERTYLIST,eax,offset tmpbuff
			.endif
			inc		esi
		.endw
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
	.endw
	;Delete duplicates
	mov		dword ptr buffer,'W'
	invoke DeleteDuplicates,addr buffer
	;Set message api tooltip
	mov		ttmsg.szType,'M'
	mov		ttmsg.lpMsgApi[0*sizeof MSGAPI].nPos,2
	mov		ttmsg.lpMsgApi[0*sizeof MSGAPI].lpszApi,offset szMsg1
	mov		ttmsg.lpMsgApi[1*sizeof MSGAPI].nPos,2
	mov		ttmsg.lpMsgApi[1*sizeof MSGAPI].lpszApi,offset szMsg2
	mov		ttmsg.lpMsgApi[2*sizeof MSGAPI].nPos,3
	mov		ttmsg.lpMsgApi[2*sizeof MSGAPI].lpszApi,offset szMsg3
	ret

GetCodeComplete endp

GetKeywords proc uses esi edi
	LOCAL	hMem:HGLOBAL
	LOCAL	buffer[16]:BYTE
	LOCAL	nInx:DWORD

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,65536*8
	mov		hMem,eax
	invoke SetHiliteWords,0,0
	mov		buffer,'C'
	mov		nInx,0
	.while nInx<16
		invoke BinToDec,nInx,addr buffer[1]
		invoke GetPrivateProfileString,addr szIniKeywords,addr buffer,NULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
		.if eax
			mov		eax,nInx
			mov		eax,dword ptr da.radcolor[eax*4]
			invoke SetHiliteWords,eax,addr tmpbuff
		.endif
		inc		nInx
	.endw
	;Add api calls to Group#15
	invoke RtlZeroMemory,hMem,65536*8
	mov		dword ptr buffer,'P'
	mov		edi,hMem
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr buffer,addr buffer[2]
	.while eax
		mov		byte ptr [edi],'^'
		inc		edi
		invoke strcpy,edi,eax
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		byte ptr [edi],' '
		inc		edi
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
	.endw
	mov		byte ptr [edi],0
	invoke SetHiliteWords,da.radcolor.kwcol[15*4],hMem
	;Add api types to Group#12
	invoke RtlZeroMemory,hMem,65536*8
	mov		dword ptr buffer,'T'
	mov		edi,hMem
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr buffer,addr buffer[2]
	.while eax
		mov		cl,[eax]
		mov		ch,cl
		and		cl,5Fh
		.if cl==ch
			;Case sensitive
			mov		byte ptr [edi],'^'
			inc		edi
		.endif
		invoke strcpy,edi,eax
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		byte ptr [edi],' '
		inc		edi
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
	.endw
	mov		byte ptr [edi],0
	invoke SetHiliteWords,da.radcolor.kwcol[12*4],hMem
	;Add api constants to Group#14
	invoke RtlZeroMemory,hMem,65536*8
	mov		dword ptr buffer,'C'
	mov		edi,hMem
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr buffer,addr buffer[2]
	mov		esi,eax
	.while esi
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		mov		byte ptr [edi],'^'
		inc		edi
		.while byte ptr [esi]
			mov		al,[esi]
			.if al==','
				mov		byte ptr [edi],' '
				inc		edi
				mov		al,'^'
			.endif
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
		mov		esi,eax
	.endw
	mov		byte ptr [edi],0
	invoke SetHiliteWords,da.radcolor.kwcol[14*4],hMem
	;Add api words to Group#14
	invoke RtlZeroMemory,hMem,65536*8
	mov		dword ptr buffer,'W'
	mov		edi,hMem
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr buffer,addr buffer[2]
	.while eax
		mov		byte ptr [edi],'^'
		inc		edi
		invoke strcpy,edi,eax
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		byte ptr [edi],' '
		inc		edi
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
	.endw
	mov		byte ptr [edi],0
	invoke SetHiliteWords,da.radcolor.kwcol[14*4],hMem
	;Add api structs to Group#13
	invoke RtlZeroMemory,hMem,65536*8
	mov		dword ptr buffer,'S'
	mov		edi,hMem
	invoke SendMessage,ha.hProperty,PRM_FINDFIRST,addr buffer,addr buffer[2]
	.while eax
		mov		byte ptr [edi],'^'
		inc		edi
		invoke strcpy,edi,eax
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		byte ptr [edi],' '
		inc		edi
		invoke SendMessage,ha.hProperty,PRM_FINDNEXT,0,0
	.endw
	mov		byte ptr [edi],0
	invoke SetHiliteWords,da.radcolor.kwcol[13*4],hMem
	invoke GlobalFree,hMem
	ret

GetKeywords endp

GetExternalFiles proc uses ebx edi
	LOCAL	buffer[32]:BYTE

	xor		ebx,ebx
	mov		edi,offset da.external
	invoke RtlZeroMemory,edi,sizeof da.external
	.while ebx<20
		invoke BinToDec,ebx,addr buffer
		invoke GetPrivateProfileString,addr szIniExternal,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
		.if eax
			invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].EXTERNAL.szfiles,sizeof EXTERNAL.szfiles
			invoke strcpyn,addr [edi].EXTERNAL.szprog,addr tmpbuff,sizeof EXTERNAL.szprog
			lea		edi,[edi+sizeof EXTERNAL]
		.endif
		inc		ebx
	.endw
	ret

GetExternalFiles endp

GetCharTab proc uses ebx
	LOCAL buffer[32]:BYTE

	invoke SendMessage,ha.hOutput,REM_CHARTABINIT,0,0
	xor		ebx,ebx
	.while ebx<16
		invoke BinToDec,ebx,addr buffer
		invoke GetPrivateProfileString,addr szIniCharTab,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr da.szAssemblerIni
		.if eax
			xor		eax,eax
			.while eax<16
				push	eax
				mov		edx,ebx
				shl		edx,4
				or		edx,eax
				mov		al,buffer[eax]
				.if al>='0' && al<='9'
					and		eax,0Fh
					add		edx,da.lpCharTab
					mov		[edx],al
				.endif
				pop		eax
				inc		eax
			.endw
		.endif
		inc		ebx
	.endw
	ret

GetCharTab endp

GetMakeCommands proc uses ebx esi edi
	LOCAL	buffer[MAX_PATH]:BYTE

	;Get make command lines
	xor		ebx,ebx
	mov		edi,offset da.make
	invoke RtlZeroMemory,edi,sizeof da.make
	invoke SendMessage,ha.hCboBuild,CB_RESETCONTENT,0,0
	.while ebx<32
		invoke BinToDec,ebx,addr buffer
		invoke GetPrivateProfileString,addr szIniMake,addr buffer,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
		.if eax
			invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szType,sizeof MAKE.szType
			invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szCompileRC,sizeof MAKE.szCompileRC
			invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szOutCompileRC,sizeof MAKE.szOutCompileRC
			invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szAssemble,sizeof MAKE.szAssemble
			invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szOutAssemble,sizeof MAKE.szOutAssemble
			invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szLink,sizeof MAKE.szLink
			invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szOutLink,sizeof MAKE.szOutLink
			invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szLib,sizeof MAKE.szLib
			invoke GetItemStr,addr tmpbuff,addr szNULL,addr [edi].MAKE.szOutLib,sizeof MAKE.szOutLib
			invoke SendMessage,ha.hCboBuild,CB_ADDSTRING,0,addr [edi].MAKE.szType
			lea		edi,[edi+sizeof MAKE]
		.endif
		inc		ebx
	.endw
	invoke GetPrivateProfileString,addr szIniMake,addr szIniExtDebug,addr szNULL,addr da.szDebug,sizeof da.szDebug,addr da.szAssemblerIni
	invoke SendMessage,ha.hCboBuild,CB_SETCURSEL,0,0
	ret

GetMakeCommands endp

OpenAssembler proc uses ebx esi edi
	LOCAL	pbfe:PBFILEEXT
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffcbo[128]:BYTE
	LOCAL	bufftype[128]:BYTE
	LOCAL	deftype:DEFTYPE

	;Assembler.ini
	;Check version
	invoke strcpy,addr buffer,addr da.szAppPath
	invoke strcat,addr buffer,addr szBS
	invoke strcat,addr buffer,addr da.szAssembler
	invoke strcat,addr buffer,addr szDotIni
	invoke GetPrivateProfileInt,addr szIniVersion,addr szIniVersion,0,addr buffer
	.if eax<3000
		invoke strcpy,addr tmpbuff,addr szAssemblerVersion
		invoke strcat,addr tmpbuff,addr buffer
		invoke MessageBox,ha.hWnd,addr tmpbuff,addr DisplayName,MB_OK or MB_ICONERROR
		xor		eax,eax
	.else
		invoke strcpy,addr da.szAssemblerIni,addr buffer
		invoke SendMessage,ha.hStatus,SB_SETTEXT,2,addr da.szAssembler
		;Get assembler path
		invoke strcpy,addr da.szAssemblerPath,addr da.szAppPath
		invoke strcat,addr da.szAssemblerPath,addr szBS
		invoke strcat,addr da.szAssemblerPath,addr da.szAssembler
		;Get resource options
		invoke GetPrivateProfileString,addr szIniResource,addr szIniOption,NULL,addr tmpbuff,sizeof buffer,addr da.szAssemblerIni
		invoke GetItemInt,addr tmpbuff,3
		mov		da.resopt.gridx,eax
		invoke GetItemInt,addr tmpbuff,3
		mov		da.resopt.gridy,eax
		invoke GetItemInt,addr tmpbuff,0
		mov		da.resopt.color,eax
		invoke GetItemInt,addr tmpbuff,RESOPT_GRID or RESOPT_SNAP
		mov		da.resopt.fopt,eax
		invoke GetItemInt,addr tmpbuff,0
		mov		da.resopt.nExport,eax
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr da.resopt.szExport,sizeof da.resopt.szExport
		invoke GetItemInt,addr tmpbuff,0
		mov		da.resopt.nOutput,eax
		invoke GetItemStr,addr tmpbuff,addr szDefUserExport,addr da.resopt.szUserExport,sizeof da.resopt.szUserExport
		;Get file filters
		invoke RtlZeroMemory,addr da.szCODEString,sizeof da.szCODEString
		invoke RtlZeroMemory,addr da.szRESString,sizeof da.szRESString
		invoke RtlZeroMemory,addr da.szTXTString,sizeof da.szTXTString
		invoke RtlZeroMemory,addr da.szANYString,sizeof da.szANYString
		invoke RtlZeroMemory,addr da.szALLString,sizeof da.szALLString
		invoke RtlZeroMemory,addr da.szPROString,sizeof da.szPROString
		invoke strcpy,addr da.szPROString,addr szDefPROString
		mov		word ptr bufftype,'0'
		invoke GetPrivateProfileString,addr szIniFile,addr bufftype,addr szDefCODEString,addr da.szCODEString,sizeof da.szCODEString-1,addr da.szAssemblerIni
		mov		word ptr bufftype,'1'
		invoke GetPrivateProfileString,addr szIniFile,addr bufftype,addr szDefRESString,addr da.szRESString,sizeof da.szRESString-1,addr da.szAssemblerIni
		mov		word ptr bufftype,'2'
		invoke GetPrivateProfileString,addr szIniFile,addr bufftype,addr szDefTXTString,addr da.szTXTString,sizeof da.szTXTString-1,addr da.szAssemblerIni
		mov		word ptr bufftype,'3'
		invoke GetPrivateProfileString,addr szIniFile,addr bufftype,addr szDefANYString,addr da.szANYString,sizeof da.szANYString-1,addr da.szAssemblerIni
		invoke strcpy,addr da.szALLString,addr da.szCODEString
		invoke strcat,addr da.szALLString,addr szPipe
		invoke strcat,addr da.szALLString,addr da.szRESString
		invoke strcat,addr da.szALLString,addr szPipe
		invoke strcat,addr da.szALLString,addr da.szTXTString
		invoke strcat,addr da.szALLString,addr szPipe
		invoke strcat,addr da.szALLString,addr da.szANYString
		mov		eax,offset da.szCODEString
		call	FixString
		mov		eax,offset da.szRESString
		call	FixString
		mov		eax,offset da.szTXTString
		call	FixString
		mov		eax,offset da.szANYString
		call	FixString
		mov		eax,offset da.szALLString
		call	FixString
		mov		eax,offset da.szPROString
		call	FixString
		;Get file types
		invoke GetPrivateProfileString,addr szIniFile,addr szIniCode,NULL,addr da.szCodeFiles,sizeof da.szCodeFiles,addr da.szAssemblerIni
		invoke GetPrivateProfileString,addr szIniFile,addr szIniText,NULL,addr da.szTextFiles,sizeof da.szTextFiles,addr da.szAssemblerIni
		invoke GetPrivateProfileString,addr szIniFile,addr szIniHex,NULL,addr da.szHexFiles,sizeof da.szHexFiles,addr da.szAssemblerIni
		invoke GetPrivateProfileString,addr szIniFile,addr szIniResource,NULL,addr da.szResourceFiles,sizeof da.szResourceFiles,addr da.szAssemblerIni
		;Get project browser file types
		invoke SendMessage,ha.hProjectBrowser,RPBM_ADDFILEEXT,0,0
		invoke GetPrivateProfileString,addr szIniFile,addr szIniType,NULL,addr da.szTypes,sizeof da.szTypes,addr da.szAssemblerIni
		invoke strcpy,addr tmpbuff,addr da.szTypes
		xor ebx,ebx
		.while tmpbuff
			inc		ebx
			invoke GetItemStr,addr tmpbuff,addr szNULL,addr buffer,sizeof buffer
			lea		eax,[ebx+2]
			mov		pbfe.id,eax
			invoke strcpy,addr pbfe.szfileext,addr buffer
			invoke SendMessage,ha.hProjectBrowser,RPBM_ADDFILEEXT,addr [ebx-1],addr pbfe
		.endw
		;Get external file types
		invoke GetExternalFiles
		;Get template file types
		invoke GetPrivateProfileString,addr szIniFile,addr szIniTplTxt,NULL,addr da.szTplTxt,sizeof da.szTplTxt,addr da.szAssemblerIni
		invoke GetPrivateProfileString,addr szIniFile,addr szIniTplBin,NULL,addr da.szTplBin,sizeof da.szTplBin,addr da.szAssemblerIni
		;Get colors
		invoke GetColors
		;Get code blocks
		mov		esi,offset da.rabdstr
		invoke RtlZeroMemory,esi,sizeof da.rabdstr
		mov		edi,offset da.rabd
		invoke RtlZeroMemory,edi,sizeof da.rabd
		mov		ebx,0
		.while ebx<32
			invoke BinToDec,ebx,addr buffer
			invoke GetPrivateProfileString,addr szIniCodeBlock,addr buffer,NULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
			.break .if !eax
			invoke GetItemStr,addr tmpbuff,addr szNULL,esi,32
			.if byte ptr [esi]
				mov		[edi].RABLOCKDEF.lpszStart,esi
				invoke strlen,esi
				lea		esi,[esi+eax+2]
			.endif
			invoke GetItemStr,addr tmpbuff,addr szNULL,esi,32
			.if byte ptr [esi]
				mov		[edi].RABLOCKDEF.lpszEnd,esi
				invoke strlen,esi
				lea		esi,[esi+eax+2]
			.endif 
			invoke GetItemStr,addr tmpbuff,addr szNULL,esi,32
			.if byte ptr [esi]
				mov		[edi].RABLOCKDEF.lpszNot1,esi
				invoke strlen,esi
				lea		esi,[esi+eax+2]
			.endif 
			invoke GetItemStr,addr tmpbuff,addr szNULL,esi,32
			.if byte ptr [esi]
				mov		[edi].RABLOCKDEF.lpszNot2,esi
				invoke strlen,esi
				lea		esi,[esi+eax+2]
			.endif 
			invoke GetItemInt,addr tmpbuff,0
			push	eax
			invoke GetItemInt,addr tmpbuff,0
			pop		edx
			shl		eax,16
			or		eax,edx
			mov		[edi].RABLOCKDEF.flag,eax
			inc		ebx
			lea		edi,[edi+sizeof RABLOCKDEF]
		.endw
		;Reset block defs
		invoke SendMessage,ha.hOutput,REM_ADDBLOCKDEF,0,0
		;Get code blocks
		mov		esi,offset da.rabd
		.while [esi].RABLOCKDEF.lpszStart
			invoke SendMessage,ha.hOutput,REM_ADDBLOCKDEF,0,esi
			mov		eax,[esi].RABLOCKDEF.lpszStart
			call	FixString
			mov		eax,[esi].RABLOCKDEF.lpszEnd
			call	FixString
			lea		esi,[esi+sizeof RABLOCKDEF]
		.endw
		invoke GetPrivateProfileString,addr szIniCodeBlock,addr szIniCmnt,NULL,addr tmpbuff,64,addr da.szAssemblerIni
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr da.szCmntStart,sizeof da.szCmntStart
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr da.szCmntEnd,sizeof da.szCmntEnd
		invoke SendMessage,ha.hOutput,REM_SETCOMMENTBLOCKS,addr da.szCmntStart,addr da.szCmntEnd
		;Get options
		invoke GetPrivateProfileString,addr szIniEdit,addr szIniBraceMatch,NULL,addr da.szBraceMatch,sizeof da.szBraceMatch,addr da.szAssemblerIni
		invoke strlen,addr da.szBraceMatch
		mov		edx,dword ptr da.szBraceMatch[eax-3]
		.if edx=='}C{'
			mov		dword ptr da.szBraceMatch[eax-3],0Dh
		.endif
		invoke SendMessage,ha.hOutput,REM_BRACKETMATCH,0,offset da.szBraceMatch
		invoke GetPrivateProfileString,addr szIniEdit,addr szIniOption,NULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
		invoke GetItemInt,addr tmpbuff,4
		mov		da.edtopt.tabsize,eax
		invoke GetItemInt,addr tmpbuff,EDTOPT_INDENT or EDTOPT_LINENR
		mov		da.edtopt.fopt,eax
		invoke GetPrivateProfileString,addr szIniFile,addr szIniFilter,NULL,addr tmpbuff,sizeof da.szFilter+2,addr da.szAssemblerIni
		invoke GetItemInt,addr tmpbuff,1
		invoke SendMessage,ha.hFileBrowser,FBM_SETFILTER,FALSE,eax
		invoke GetItemStr,addr tmpbuff,addr szDefFilter,addr da.szFilter,sizeof da.szFilter
		invoke SendMessage,ha.hFileBrowser,FBM_SETFILTERSTRING,TRUE,addr da.szFilter
		;Get parser
		invoke SendMessage,ha.hProperty,PRM_RESET,0,0
		invoke GetPrivateProfileInt,addr szIniParse,addr szIniAssembler,0,addr da.szAssemblerIni
		mov		da.nAsm,eax
		invoke GetPrivateProfileString,addr szIniParse,addr szIniError,NULL,addr da.szError,sizeof da.szError,addr da.szAssemblerIni
		invoke SendMessage,ha.hProperty,PRM_SETLANGUAGE,da.nAsm,0
		invoke SendMessage,ha.hProperty,PRM_SETCHARTAB,0,da.lpCharTab
		invoke GetPrivateProfileString,addr szIniParse,addr szIniDef,NULL,addr buffer,sizeof buffer,addr da.szAssemblerIni
		invoke GetItemStr,addr buffer,addr szNULL,addr defgen.szCmntBlockSt,sizeof defgen.szCmntBlockSt
		invoke GetItemStr,addr buffer,addr szNULL,addr defgen.szCmntBlockEn,sizeof defgen.szCmntBlockEn
		invoke GetItemStr,addr buffer,addr szNULL,addr defgen.szCmntChar,sizeof defgen.szCmntChar
		invoke GetItemStr,addr buffer,addr szNULL,addr defgen.szString,sizeof defgen.szString
		invoke GetItemStr,addr buffer,addr szNULL,addr defgen.szLineCont,sizeof defgen.szLineCont
		invoke SendMessage,ha.hProperty,PRM_SETGENDEF,0,addr defgen
		invoke GetPrivateProfileString,addr szIniParse,addr szIniType,NULL,addr buffcbo,sizeof buffcbo,addr da.szAssemblerIni
		.if eax
			.while buffcbo
				invoke GetItemStr,addr buffcbo,addr szNULL,addr bufftype,sizeof bufftype
				.if bufftype
					invoke GetPrivateProfileString,addr szIniParse,addr bufftype,NULL,addr buffer,sizeof buffer,addr da.szAssemblerIni
					.while buffer
						invoke GetItemInt,addr buffer,0
						mov		deftype.nType,al
						invoke GetItemInt,addr buffer,0
						mov		deftype.nDefType,al
						invoke GetItemStr,addr buffer,addr szNULL,addr deftype.Def,sizeof deftype.Def+1
						invoke GetItemStr,addr buffer,addr szNULL,addr deftype.szWord,sizeof deftype.szWord
;PrintDec deftype.nType
;PrintDec deftype.nDefType
;lea eax,deftype.Def
;PrintStringByAddr eax
;lea eax,deftype.szWord
;PrintStringByAddr eax
						.if deftype.nType==TYPE_TWOWORDS
							lea		esi,deftype.szWord
							xor		edi,edi
							xor		ecx,ecx
							.while byte ptr [esi]
								.if byte ptr [esi]==' '
									mov		deftype.len,cl
									mov		eax,ecx
									xor		ecx,ecx
									mov		edi,esi
									inc		esi
								.endif
								inc		ecx
								inc		esi
							.endw
							.if edi
								mov		[edi],cl
							.endif
						.else
							invoke strlen,addr deftype.szWord
							mov		deftype.len,al
						.endif
						.if eax
							invoke SendMessage,ha.hProperty,PRM_ADDDEFTYPE,0,addr deftype
						.endif
					.endw
					movzx	edx,deftype.Def
					.if edx=='d' && da.nAsm==nFREEBASIC
						add		edx,512
					.endif
					invoke SendMessage,ha.hProperty,PRM_ADDPROPERTYTYPE,edx,addr bufftype
				.endif
			.endw
			;Arguments
			invoke GetPrivateProfileString,addr szIniParse,addr szIniArg,NULL,addr buffer,sizeof buffer,addr da.szAssemblerIni
			.while buffer
				invoke GetItemInt,addr buffer,0
				mov		deftype.nType,al
				invoke GetItemInt,addr buffer,0
				mov		deftype.nDefType,al
				invoke GetItemStr,addr buffer,addr szNULL,addr deftype.Def,sizeof deftype.Def+1
				invoke GetItemStr,addr buffer,addr szNULL,addr deftype.szWord,sizeof deftype.szWord
				invoke strlen,addr deftype.szWord
				mov		deftype.len,al
				.if eax
					invoke SendMessage,ha.hProperty,PRM_ADDDEFTYPE,0,addr deftype
				.endif
			.endw
			;Locals
			invoke GetPrivateProfileString,addr szIniParse,addr szIniLocal,NULL,addr buffer,sizeof buffer,addr da.szAssemblerIni
			.while buffer
				invoke GetItemInt,addr buffer,0
				mov		deftype.nType,al
				invoke GetItemInt,addr buffer,0
				mov		deftype.nDefType,al
				invoke GetItemStr,addr buffer,addr szNULL,addr deftype.Def,sizeof deftype.Def+1
				invoke GetItemStr,addr buffer,addr szNULL,addr deftype.szWord,sizeof deftype.szWord
				invoke strlen,addr deftype.szWord
				mov		deftype.len,al
				.if eax
					invoke SendMessage,ha.hProperty,PRM_ADDDEFTYPE,0,addr deftype
				.endif
			.endw
			;Ignore
			invoke GetPrivateProfileString,addr szIniParse,addr szIniIgnore,NULL,addr buffer,sizeof buffer,addr da.szAssemblerIni
			.while buffer
				invoke GetItemInt,addr buffer,0
				push	eax
				invoke GetItemStr,addr buffer,addr szNULL,addr bufftype,sizeof bufftype
				pop		edx
				.if bufftype
					invoke SendMessage,ha.hProperty,PRM_ADDIGNORE,edx,addr bufftype
				.endif
			.endw
			invoke SendMessage,ha.hProperty,PRM_SELECTPROPERTY,'p',0
		.endif
		invoke GetCodeComplete
		invoke GetKeywords
		;Get make exe's
		invoke GetPrivateProfileString,addr szIniMake,addr szIniMake,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr da.szCompileRC,sizeof da.szCompileRC
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr da.szAssemble,sizeof da.szAssemble
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr da.szLink,sizeof da.szLink
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr da.szLib,sizeof da.szLib
		;Get make help
		invoke GetPrivateProfileString,addr szIniMake,addr szIniHelp,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr da.szCompileRCHelp,sizeof da.szCompileRCHelp
		invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr da.szCompileRCHelpKw,sizeof da.szCompileRCHelpKw
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr da.szAssembleHelp,sizeof da.szAssembleHelp
		invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr da.szAssembleHelpKw,sizeof da.szAssembleHelpKw
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr da.szLinkHelp,sizeof da.szLinkHelp
		invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr da.szLinkHelpKw,sizeof da.szLinkHelpKw
		invoke GetItemStr,addr tmpbuff,addr szNULL,addr da.szLibHelp,sizeof da.szLibHelp
		invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr da.szLibHelpKw,sizeof da.szLibHelpKw
		;Can debug
		invoke GetPrivateProfileInt,addr szIniMake,addr szIniDebug,0,addr da.szAssemblerIni
		mov		da.fCanDebug,eax
		invoke RtlZeroMemory,offset da.szNoDebug,sizeof da.szNoDebug
		mov		da.fMainThread,0
		;Get make command lines
		invoke GetMakeCommands
		;Get run options
		invoke GetPrivateProfileString,addr szIniMake,addr szIniRun,addr szNULL,addr tmpbuff,sizeof tmpbuff,addr da.szAssemblerIni
		invoke GetItemInt,addr tmpbuff,0
		mov		da.fCmdExe,eax
		invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr da.szCmdExe,sizeof da.szCmdExe
		invoke GetItemQuotedStr,addr tmpbuff,addr szNULL,addr da.szCommandLine,sizeof da.szCommandLine
		;Get default projrct path
		invoke GetPrivateProfileString,addr szIniProject,addr szIniPath,addr szNULL,addr da.szDefProjectPath,sizeof da.szDefProjectPath,addr da.szAssemblerIni
		;Setup environment
		invoke SetEnvironment
		invoke GetCharTab
		;Menus
		invoke SetHelpMenu
		invoke SetToolMenu
		invoke SetF1Help
		mov		eax,TRUE
	.endif
	ret

FixString:
	.if eax
		.while byte ptr [eax]
			.if byte ptr [eax]=='|'
				mov		byte ptr [eax],0
			.endif
			inc		eax
		.endw
	.endif
	retn

OpenAssembler endp

