.386
.model flat,stdcall
option casemap:none
option proc:private

include Data.inc
include Misc.asm
include WordList.asm
include FBParse.asm
include MasmParse.asm
include GoAsmParse.asm
include FasmParse.asm
include TasmParse.asm
include CppParse.asm
include SolParse.asm
include FpParse.asm
include Sort.asm

.code

InstallRAProperty proc public hInst:HINSTANCE,fGlobal:DWORD
	LOCAL	wc:WNDCLASSEX

	;Create a windowclass for the user control
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_PARENTDC or CS_DBLCLKS
	.if fGlobal
		mov		wc.style,CS_HREDRAW or CS_VREDRAW or CS_PARENTDC or CS_DBLCLKS or CS_GLOBALCLASS
	.endif
	mov		wc.lpfnWndProc,offset ControlProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,4
	mov		eax,hInst
	mov		wc.hInstance,eax
	mov		hInstance,eax
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szClassName
	mov		eax,NULL
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	ret

InstallRAProperty endp

UnInstallRAProperty proc public

	ret

UnInstallRAProperty endp

;--------------------------------------------------------------------------------

CreateToolTip proc hWin:HWND
	LOCAL	ti:TOOLINFO

	invoke CreateWindowEx,0,OFFSET szToolTipClass,OFFSET szToolTipClass,TTS_NOPREFIX,0,0,0,0,hWin,0,hInstance,0
	mov		[ebx].RAPROPERTY.htooltip,eax

	invoke SendMessage,[ebx].RAPROPERTY.htooltip,TTM_ACTIVATE,TRUE,0
	invoke SendMessage,[ebx].RAPROPERTY.htooltip,TTM_SETDELAYTIME,TTDT_AUTOMATIC,500
	invoke SendMessage,[ebx].RAPROPERTY.htooltip,TTM_SETMAXTIPWIDTH,0,800

	mov		ti.cbSize,SIZEOF TOOLINFO
	mov		ti.uFlags,TTF_IDISHWND or TTF_SUBCLASS
	mov		eax,hWin
	mov		ti.hWnd,eax
	mov		ti.uId,eax
	mov		eax,hInstance
	mov		ti.hInst,eax
	mov		ti.lpszText,LPSTR_TEXTCALLBACK
	invoke SendMessage,[ebx].RAPROPERTY.htooltip,TTM_ADDTOOL,0,addr ti
	ret

CreateToolTip endp

ListBoxProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hDC:HDC
	LOCAL	rect:RECT
	LOCAL	nMin:DWORD
	LOCAL	nMax:DWORD
    PrintHex LBN_DBLCLK shl 16 or 1003, "LBN_DBLCLK shl 16 or 1003"
	mov		eax,uMsg
	.if eax==WM_NOTIFY
		mov		ebx,lParam
		.if [ebx].NMHDR.code==TTN_NEEDTEXT
			mov		szname,0
			invoke SendMessage,hWin,LB_GETTEXT,OldItem,offset szname
			invoke GetClientRect,hWin,addr rect
			push	rect.right
			invoke GetDC,hWin
			mov		hDC,eax
			invoke SendMessage,hWin,WM_GETFONT,0,0
			invoke SelectObject,hDC,eax
			push	eax
			invoke DrawText,hDC,offset szname,-1,addr rect,DT_LEFT or DT_TOP or DT_SINGLELINE or DT_CALCRECT
			pop		eax
			invoke SelectObject,hDC,eax
			invoke ReleaseDC,hWin,hDC
			pop		eax
			sub		eax,2
			.if eax<rect.right
				mov		[ebx].TOOLTIPTEXT.lpszText,offset szname
			.endif
		.else
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_CHAR
		.if lParam==VK_RETURN 
			;mov edx,LBN_DBLCLK shl 16 or 1003
			PrintHex LBN_DBLCLK shl 16 or 1003, "LBN_DBLCLK shl 16 or 1003"	
			PrintHex LBN_DBLCLK , "LBN_DBLCLK"
			PrintHex 1003 , "1003"
			invoke SendMessage,[ebx].RAPROPERTY.hwnd,WM_COMMAND,LBN_DBLCLK shl 16 or 1003,hWin
		.endif	
	.elseif eax==WM_MOUSEMOVE
		invoke SendMessage,hWin,LB_ITEMFROMPOINT,0,lParam
		.IF eax!=OldItem
			mov		OldItem,eax
			invoke GetParent,hWin
			invoke GetWindowLong,eax,0
			mov		ebx,eax
			invoke SendMessage,[ebx].RAPROPERTY.htooltip,TTM_ACTIVATE,FALSE,0
			invoke SendMessage,[ebx].RAPROPERTY.htooltip,TTM_ACTIVATE,TRUE,0
		.endif
	.endif
	invoke CallWindowProc,OldListBoxProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ListBoxProc endp

;--------------------------------------------------------------------------------

UpdateList proc uses esi,dwType:DWORD
	LOCAL	rapn:RAPNOTIFY

	invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_RESETCONTENT,0,0
	.if [ebx].RAPROPERTY.cbsize
		mov		esi,[ebx].RAPROPERTY.lpmem
		.while [esi].PROPERTIES.nSize
			mov		eax,dwType
			.if al==[esi].PROPERTIES.nType
				mov		edx,[ebx].RAPROPERTY.nOwner
				.if edx==[esi].PROPERTIES.nOwner || !edx
					call	AddItem
				.endif
			.endif
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
		.endw
	.endif
	invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_SETCURSEL,0,0
	xor		eax,eax
	dec		eax
	mov		rapn.nid,eax
	mov		rapn.nline,eax
	mov		eax,[ebx].RAPROPERTY.hwnd
	mov		rapn.nmhdr.hwndFrom,eax
	mov		edx,[ebx].RAPROPERTY.id
	mov		rapn.nmhdr.idFrom,edx
	mov		rapn.nmhdr.code,LBN_SELCHANGE
	invoke SendMessage,[ebx].RAPROPERTY.hpar,WM_NOTIFY,edx,addr rapn
	ret

AddItem:
	.if ah==1
		; Proc
		invoke strcpy,addr szname,addr [esi+sizeof PROPERTIES]
		invoke strcat,addr szname,addr szLpa
		push	esi
		lea		esi,[esi+sizeof PROPERTIES]
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		invoke strcat,addr szname,esi
		invoke strcat,addr szname,addr szRpa
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		.if byte ptr [esi]
			invoke strcat,addr szname,addr szSpc
			invoke strcat,addr szname,esi
		.endif
		pop		esi
		invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_ADDSTRING,0,addr szname
	.elseif ah==2
		; Data
		invoke strcpy,addr szname,addr [esi+sizeof PROPERTIES]
		invoke strcat,addr szname,addr szColon
		push	esi
		lea		esi,[esi+sizeof PROPERTIES]
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		invoke strcat,addr szname,esi
		pop		esi
		invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_ADDSTRING,0,addr szname
	.else
		invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_ADDSTRING,0,addr [esi+sizeof PROPERTIES]
	.endif
	invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_SETITEMDATA,eax,esi
	retn

UpdateList endp

Find proc uses esi

	mov		esi,[ebx].RAPROPERTY.lpmem
	.if esi
		add		esi,[ebx].RAPROPERTY.rpFindPos
	  @@:
		.if [esi].PROPERTIES.nSize
			call	TestType
			.if eax
				call	TestText
				.if eax
					jmp		Ex
				.endif
			.endif
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
			jmp		@b
		.endif
	.endif
	xor		eax,eax
	ret
  Ex:
	movzx	eax,[esi].PROPERTIES.nType
	mov		[ebx].RAPROPERTY.nfindtype,eax
	mov		eax,[esi].PROPERTIES.nOwner
	mov		[ebx].RAPROPERTY.nfindowner,eax
	mov		eax,[esi].PROPERTIES.nLine
	mov		[ebx].RAPROPERTY.nfindline,eax
	mov		eax,[esi].PROPERTIES.nEnd
	mov		[ebx].RAPROPERTY.nfindendline,eax
	mov		eax,esi
	add		eax,[esi].PROPERTIES.nSize
	add		eax,sizeof PROPERTIES
	sub		eax,[ebx].RAPROPERTY.lpmem
	mov		[ebx].RAPROPERTY.rpFindPos,eax
	mov		eax,esi
	ret

TestType:
	lea		edx,[ebx].RAPROPERTY.szFindTypes
	mov		al,[esi].PROPERTIES.nType
	.while byte ptr [edx]
		.if al==byte ptr [edx]
			retn
		.endif
		inc		edx
	.endw
	xor		eax,eax
	retn

TestText:
	lea		edx,[ebx].RAPROPERTY.szFindText
	lea		ecx,[esi+sizeof PROPERTIES]
	.while byte ptr [edx]
		mov		al,[edx]
		mov		ah,[ecx]
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		.if ah>='a' && ah<='z'
			and		ah,5Fh
		.endif
		sub		al,ah
		.if !ZERO?
			xor		eax,eax
			retn
		.endif
		inc		edx
		inc		ecx
	.endw
	mov		eax,TRUE
	retn

Find endp

MakeSortedList proc uses esi edi,lpTypes:DWORD

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*1024
	mov		edi,eax
	push	edi
	xor		ecx,ecx
	mov		esi,[ebx].RAPROPERTY.lpmem
	.if esi
		.while [esi].PROPERTIES.nSize
			call	TestType
			.if eax
				lea		eax,[esi+sizeof PROPERTIES]
				mov		[edi],eax
				lea		edi,[edi+4]
				inc		ecx
			.endif
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
		.endw
	.endif
	pop		edi
	push	ecx
	.if ecx
		dec		ecx
		invoke QuickSort,edi,0,ecx,FALSE
	.endif
	pop		ecx
	mov		eax,edi
	ret

TestType:
	mov		edx,lpTypes
	mov		al,[esi].PROPERTIES.nType
	.while byte ptr [edx]
		.if al==byte ptr [edx]
			retn
		.endif
		inc		edx
	.endw
	xor		eax,eax
	retn

MakeSortedList endp

;Find the word using successive approximation
FindWord proc uses ebx esi edi,lpWord:DWORD,lpMem:DWORD,nCount:DWORD
	LOCAL	nLU:DWORD
	LOCAL	nLD:DWORD
	LOCAL	nScans:DWORD

	xor		eax,eax
	mov		nScans,eax
	mov		nLD,eax
	mov		ebx,lpMem
	mov		ecx,nCount
	dec		ecx
	mov		nLU,ecx
	shr		ecx,1
	mov		esi,lpWord
  Nxt:
	inc		nScans
	mov		edi,[ebx+ecx*4]
	xor		edx,edx
  @@:
	mov		al,[edi+edx]
	mov		ah,[esi+edx]
	.if al>='a' && al<='z'
		and		al,5Fh
	.endif
	.if ah>='a' && ah<='z'
		and		ah,5Fh
	.endif
	cmp		al,ah
	jne		@f
	inc		edx
	or		al,al
	jne		@b
	;Word found, return index
	mov		eax,ecx
	jmp		Ex
  @@:
	jnc		Dn
	;Up
	mov		eax,nLU
	sub		eax,ecx
	shr		eax,1
	.if !eax
		cmp		ecx,nLD
		je		Nf
		inc		eax
	.endif
	mov		nLD,ecx
	add		ecx,eax
	cmp		ecx,nCount
	jc		Nxt
	jmp		Nf
  Dn:
	;Down
	mov		eax,ecx
	sub		eax,nLD
	shr		eax,1
	.if !eax
		cmp		ecx,nLU
		je		Nf
		inc		eax
	.endif
	mov		nLU,ecx
	sub		ecx,eax
	jnc		Nxt
  Nf:
	;Word not found, return -1
	xor		eax,eax
	dec		eax
  Ex:
	ret

FindWord endp

IsType proc uses edx,lpszTypes:DWORD,nType:DWORD

	mov		edx,lpszTypes
	mov		eax,nType
	.while byte ptr [edx]
		.if al==byte ptr [edx]
			ret
		.endif
		inc		edx
	.endw
	xor		eax,eax
	ret

IsType endp

IsWordType proc uses esi,lpszTypes:DWORD,lpszWord:DWORD,fNoCase:DWORD,lpStart:DWORD

	mov		esi,[ebx].RAPROPERTY.lpmem
	.if lpStart
		mov		esi,lpStart
	.endif
	.if esi
		.while [esi].PROPERTIES.nSize
			movzx	eax,[esi].PROPERTIES.nType
			invoke IsType,lpszTypes,eax
			.if eax
				call	TestWord
				.if eax
					mov		eax,esi
					jmp		Ex
				.endif
			.endif
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
		.endw
	.endif
	xor		eax,eax
  Ex:
	ret

TestWord:
	lea		edx,[esi+sizeof PROPERTIES]
	mov		ecx,lpszWord
	.while byte ptr [edx]
		mov		al,[edx]
		mov		ah,[ecx]
		.if fNoCase
			.if al>='a' && al<='z'
				and		al,5Fh
			.endif
			.if ah>='a' && ah<='z'
				and		ah,5Fh
			.endif
		.endif
		sub		al,ah
		.if !ZERO?
			xor		eax,eax
			retn
		.endif
		inc		edx
		inc		ecx
	.endw
	movzx	eax,byte ptr [ecx]
	mov		ecx,[ebx].RAPROPERTY.lpchartab
	.if byte ptr [ecx+eax]==CT_CHAR
		xor		eax,eax
	.else
		mov		eax,TRUE
	.endif
	retn

IsWordType endp

GetToolTip proc uses esi edi,lParam:DWORD,fNoCase:DWORD
	LOCAL	npos:DWORD

	mov		eax,[ebx].RAPROPERTY.nlanguage
	mov		edi,lParam
	mov		edi,[edi].TOOLTIP.lpszLine
	.if eax==nMASM
		; Masm
		invoke MPreParse,edi
	.elseif eax==nTASM
		; Tasm
		invoke TasmPreParse,edi
	.elseif eax==nFASM
		; Fasm
		invoke FasmPreParse,edi
	.elseif eax==nGOASM
		; GoAsm
		invoke GoPreParse,edi
	.elseif eax==nNASM
	.elseif eax==nHLA
	.elseif eax==nCPP
		;C/C++
		invoke CppPreParse,edi
	.elseif eax==nFREEBASIC
		; FreeBASIC
		invoke FBPreParse,edi,fNoCase
	.elseif eax==nFREEPASCAL
	.elseif eax==nASEMW
		; asemw, Masm
		invoke MPreParse,edi
	.elseif eax==nOTHER
	.endif
	xor		edi,edi
	mov		esi,[ebx].RAPROPERTY.lpchartab
	test	fNoCase,TT_PARANTESES
	.if !ZERO?
		mov		edx,lParam
		invoke strlen,[edx].TOOLTIP.lpszLine
		mov		edx,lParam
		mov		edx,[edx].TOOLTIP.lpszLine
		dec		eax
		.while eax
			.if byte ptr [edx+eax]==')'
				call	SkipScopeBack
			.elseif byte ptr [edx+eax]=='('
				dec		eax
				.break
			.endif
			dec		eax
		.endw
		call	SkipSpcBack
		.while TRUE
			movzx	ecx,byte ptr [edx+eax]
			.if byte ptr [esi+ecx]!=CT_CHAR
				inc		eax
				.break
			.endif
			.break .if !eax
			dec		eax
		.endw
		lea		eax,[edx+eax]
		mov		edx,lParam
		mov		edx,[edx].TOOLTIP.lpszLine
		invoke strcpy,edx,eax
		mov		eax,lParam
		mov		edx,fNoCase
		and		edx,TT_NOMATCHCASE
		invoke IsWordType,[eax].TOOLTIP.lpszType,[eax].TOOLTIP.lpszLine,edx,0
		.if eax
			mov		edi,eax
			mov		edx,lParam
			mov		edx,[edx].TOOLTIP.lpszLine
			mov		npos,edx
		.endif
	.else
		mov		edx,lParam
		mov		edx,[edx].TOOLTIP.lpszLine
		.while byte ptr [edx]
			movzx	eax,byte ptr [edx]
			.if byte ptr [esi+eax]!=CT_CHAR
				inc		edx
			.else
				push	edx
				mov		ecx,edx
				.while byte ptr [edx]
					movzx	eax,byte ptr [edx]
					.if byte ptr [esi+eax]==CT_CHAR
						inc		edx
					.else
						.break
					.endif
				.endw
				mov		eax,edx
				call	SkipSpc
				mov		edx,eax
				.if byte ptr [edx]=='('
					push	ecx
					xor		ecx,ecx
					.while byte ptr [edx]
						.if byte ptr [edx]==')'
							dec		ecx
						.elseif byte ptr [edx]=='('
							inc		ecx
						.endif
						inc		edx
					.endw
					.if !ecx
						pop		ecx
						jmp		Nxt
					.endif
					pop		ecx
				.endif
				mov		eax,lParam
				push	ecx
				mov		edx,fNoCase
				and		edx,TT_NOMATCHCASE
				invoke IsWordType,[eax].TOOLTIP.lpszType,ecx,edx,0
				pop		ecx
				.if eax
					mov		edi,eax
					mov		npos,ecx
				.endif
			  Nxt:
				pop		edx
				.while byte ptr [edx]
					movzx	eax,byte ptr [edx]
					.if byte ptr [esi+eax]==CT_CHAR
						inc		edx
					.else
						.break
					.endif
				.endw
			.endif
		.endw
	.endif
	.if edi
		mov		edx,lParam
		mov		[edx].TOOLTIP.novr,0
		.while edi
			call	GetTT
			mov		eax,[edi].PROPERTIES.nSize
			lea		edi,[edi+eax+sizeof PROPERTIES]
			mov		eax,lParam
			mov		edx,fNoCase
			and		edx,TT_NOMATCHCASE
			invoke IsWordType,[eax].TOOLTIP.lpszType,[eax].TOOLTIP.lpszApi,edx,edi
			mov		edi,eax
		.endw
		xor		ecx,ecx
		mov		eax,npos
		.while byte ptr [eax]
			movzx	ecx,byte ptr [eax]
			.if byte ptr [esi+ecx]==CT_CHAR
				inc		eax
			.else
				.break
			.endif
		.endw
		call	SkipSpc
		.if byte ptr [eax]=='(' || byte ptr [eax]==','
			inc		eax
		.endif
		xor		ecx,ecx
		.while byte ptr [eax]
			.if byte ptr [eax]==','
				inc		ecx
			.elseif byte ptr [eax]=='('
				call	SkipScope
			.endif
			inc		eax
		.endw
		mov		edx,lParam
		mov		[edx].TOOLTIP.nPos,ecx
		xor		eax,eax
		inc		eax
	.else
		xor		eax,eax
		mov		edx,lParam
		mov		[edx].TOOLTIP.lpszApi,eax
		mov		[edx].TOOLTIP.nPos,eax
		mov		[edx].TOOLTIP.novr,eax
		mov		[edx].TOOLTIP.ovr.lpszParam,eax
		mov		[edx].TOOLTIP.ovr.lpszRetType,eax
	.endif
	ret

GetTT:
	push	esi
	push	edi
	mov		edx,lParam
	mov		esi,[edx].TOOLTIP.novr
	lea		edi,[edi+sizeof PROPERTIES]
	mov		edx,lParam
	mov		[edx].TOOLTIP.lpszApi,edi
	invoke strlen,edi
	lea		edi,[edi+eax+1]
	mov		edx,lParam
	mov		[edx].TOOLTIP.ovr.lpszParam[esi*sizeof OVERRIDE],edi
	invoke strlen,edi
	lea		edi,[edi+eax+1]
	mov		edx,lParam
	mov		[edx].TOOLTIP.ovr.lpszRetType[esi*sizeof OVERRIDE],edi
	inc		[edx].TOOLTIP.novr
	pop		edi
	pop		esi
	retn

SkipSpc:
	.while byte ptr [eax]==VK_SPACE || byte ptr [eax]==VK_TAB
		inc		eax
	.endw
	retn

SkipScope:
	push	ecx
	xor		ecx,ecx
	.while byte ptr [eax]
		.if byte ptr [eax]=='('
			inc		ecx
		.elseif byte ptr [eax]==')'
			dec		ecx
			.break .if ZERO?
		.endif
		inc		eax
	.endw
	pop		ecx
	retn

SkipSpcBack:
	.while (byte ptr [edx+eax]==VK_SPACE || byte ptr [edx+eax]==VK_TAB) && eax
		dec		eax
	.endw
	retn

SkipScopeBack:
	push	ecx
	xor		ecx,ecx
	.while eax
		.if byte ptr [edx+eax]==')'
			inc		ecx
		.elseif byte ptr [edx+eax]=='('
			dec		ecx
			.break .if ZERO?
		.endif
		dec		eax
	.endw
	.if byte ptr [edx+eax]=='(' && eax
		dec		eax
	.endif
	pop		ecx
	retn

GetToolTip endp

IsTooltipMessage proc uses ebx esi edi,hWin:HWND,wParam:DWORD,lParam:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	n:DWORD

	mov		buffer,0
	mov		szname,0
	mov		szname+1000,0
	mov		szname+2000,0
	mov		szname+3000,0
	mov		esi,wParam
	lea		esi,[esi].MESSAGE.lpMsgApi
	.while [esi].MSGAPI.lpszApi
		mov		edx,[esi].MSGAPI.lpszApi
		mov		edi,lParam
		invoke strcmp,edx,[edi].TOOLTIP.lpszApi
		.if !eax
			mov		edi,lParam
			mov		edi,[edi].TOOLTIP.ovr.lpszParam
			mov		ecx,[esi].MSGAPI.nPos
			mov		edx,offset szname
			.while byte ptr [edi]
				mov		al,[edi]
				mov		[edx],al
				inc		edi
				inc		edx
				.if byte ptr [edx-1]==','
					dec		ecx
					.break .if !ecx
				.endif
			.endw
			mov		byte ptr [edx],0
			mov		ecx,[esi].MSGAPI.nPos
			mov		edi,lParam
			mov		edi,[edi].TOOLTIP.lpszLine
			mov		edx,wParam
			lea		edx,buffer
			mov		byte ptr [edx],0
			.while byte ptr [edi]
				mov		al,[edi]
				.if al=='(' || al==','
					inc		edi
					dec		ecx
					.break
				.endif
				inc		edi
			.endw
			.while byte ptr [edi]
				call	SkipScope
				mov		al,[edi]
				.if al==','
					dec		ecx
					.if !ecx
						inc		edi
						.while byte ptr [edi]
							call	SkipScope
							mov		al,[edi]
							.if al!=','
								.if al!=' ' && al!=VK_TAB
									mov		[edx],al
									inc		edx
									mov		byte ptr [edx],0
								.endif
							.else
								.break
							.endif
							inc		edi
						.endw
					.endif
				.endif
				.if byte ptr [edi]
					inc		edi
				.endif
			.endw
			mov		n,ecx
			.break
		.endif
		lea		esi,[esi+sizeof MSGAPI]
	.endw
	mov		esi,wParam
	lea		edx,buffer
	.if byte ptr [edx]
		invoke SendMessage,hWin,PRM_FINDFIRST,addr [esi].MESSAGE.szType,edx
	  @@:
		.if eax
			mov		edi,eax
			invoke strcmp,edi,addr buffer
			.if !eax
				invoke strlen,edi
				lea		edi,[edi+eax+1]
				invoke strlen,offset szname
				mov		edx,eax
				xor		ebx,ebx
				push	edi
				.while byte ptr [edi]
					call	CopyScope
					mov		al,[edi]
					.if al==','
						inc		ebx
					.endif
					.if al=='['
						inc		edi
						push	edx
						.if !ebx
							mov		edx,2000
						.else
							mov		edx,3000
						.endif
						.while byte ptr [edi]!=']'
							mov		al,[edi]
							mov		szname[edx],al
							inc		edx
							mov		szname[edx],0
							inc		edi
						.endw
						pop		edx
					.else
						mov		szname[edx],al
						inc		edx
						mov		szname[edx],0
					.endif
					.if byte ptr [edi]
						inc		edi
					.endif
				.endw
				pop		edi
				invoke strlen,edi
				lea		edi,[edi+eax+1]
				.if byte ptr [edi]
					invoke strcpy,offset szname+1000,edi
				.else
					mov		szname+1000,0
				.endif
				mov		edi,lParam
				mov		[edi].TOOLTIP.ovr.lpszParam,offset szname
				mov		[edi].TOOLTIP.ovr.lpszRetType,offset szname+1000
				mov		esi,wParam
				xor		eax,eax
				.if n==0
					.if szname+2000
						mov		eax,offset szname+2000
					.endif
				.elseif n==-1
					.if szname+3000
						mov		eax,offset szname+3000
					.endif
				.endif
				jmp		Ex
			.else
				invoke SendMessage,hWin,PRM_FINDNEXT,0,0
				jmp		@b
			.endif
		.endif		
	.endif
	xor		eax,eax
  Ex:
	ret

SkipScope:
	.if byte ptr [edi]=='('
		push	ecx
		xor		ecx,ecx
		.while byte ptr [edi]
			.if byte ptr [edi]=='('
				inc		ecx
			.elseif byte ptr [edi]==')'
				dec		ecx
				.break .if ZERO?
			.endif
			inc		edi
		.endw
		.if byte ptr [edi]==')'
			inc		edi
		.endif
		pop		ecx
	.endif
	retn

CopyScope:
	.if byte ptr [edi]=='('
		push	ecx
		xor		ecx,ecx
		.while byte ptr [edi]
			mov		al,[edi]
			mov		szname[edx],al
			inc		edi
			inc		edx
			.if al=='('
				inc		ecx
			.elseif al==')'
				dec		ecx
				.break .if ZERO?
			.endif
		.endw
		pop		ecx
	.endif
	retn

IsTooltipMessage endp

ControlProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	ninx:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	len:DWORD
	LOCAL	rapn:RAPNOTIFY
	LOCAL	pt:POINT
	LOCAL	lfnt:LOGFONT
	LOCAL	nmhdr:NMHDR

	mov		eax,uMsg
	.if eax>=PRM_SELECTPROPERTY && eax<=PRM_ADDPROPERTYITEM
		push		eax
		invoke GetWindowLong,hWin,0
		.if eax
			mov		ebx,eax
			pop		eax
			sub		eax,PRM_SELECTPROPERTY
			jmp 	DWORD PTR [offset _RAPROPERTY_BASE+eax*4]
		.endif
		include RAProperty_Msg_JumpTable.asm
	.endif
	.if eax==WM_CREATE
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,sizeof RAPROPERTY
		mov		ebx,eax
		invoke SetWindowLong,hWin,0,ebx
		mov		eax,hWin
		mov		[ebx].RAPROPERTY.hwnd,eax
		invoke GetParent,hWin
		mov		[ebx].RAPROPERTY.hpar,eax
		invoke GetWindowLong,hWin,GWL_ID
		mov		[ebx].RAPROPERTY.id,eax
		invoke ImageList_Create,16,16,ILC_COLOR4 or ILC_MASK,10,0
		mov		[ebx].RAPROPERTY.himl,eax
		invoke LoadBitmap,hInstance,IDB_TRV
		push	eax
		invoke ImageList_AddMasked,[ebx].RAPROPERTY.himl,eax,0FF00FFh
		pop		eax
		invoke DeleteObject,eax
		;Create toolbar
		invoke GetWindowLong,hWin,GWL_STYLE
		push	eax
		mov		edx,WS_CHILD or WS_VISIBLE or TBSTYLE_TOOLTIPS or CCS_NORESIZE
		test	eax,PRSTYLE_FLATTOOLBAR
		.if !ZERO?
			or		edx,TBSTYLE_FLAT
		.endif
		test	eax,PRSTYLE_DIVIDERLINE
		.if ZERO?
			or		edx,CCS_NODIVIDER
		.endif
		invoke CreateWindowEx,0,addr szToolBar,NULL,edx,0,0,0,0,hWin,1001,hInstance,NULL
		mov		[ebx].RAPROPERTY.htbr,eax
		;Set toolbar struct size
		invoke SendMessage,[ebx].RAPROPERTY.htbr,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
		;Set toolbar buttons
		mov		ecx,offset btnsnopro
		pop		eax
		test	eax,PRSTYLE_PROJECT
		mov		eax,4
		.if !ZERO?
			mov		ecx,offset btnspro
			mov		eax,6
		.endif
		invoke SendMessage,[ebx].RAPROPERTY.htbr,TB_ADDBUTTONS,eax,ecx
		;Set the imagelist
		invoke SendMessage,[ebx].RAPROPERTY.htbr,TB_SETIMAGELIST,0,[ebx].RAPROPERTY.himl
		;Create ComboBox
		invoke CreateWindowEx,0,addr szComboBox,NULL,WS_CHILD or WS_VISIBLE or CBS_DROPDOWNLIST or CBS_HASSTRINGS,0,0,0,0,hWin,1002,hInstance,NULL
		mov		[ebx].RAPROPERTY.hcbo,eax
		;Create ListBox
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr szListBox,NULL,WS_CHILD or WS_VISIBLE or WS_VSCROLL or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or LBS_SORT or LBS_NOINTEGRALHEIGHT or LBS_HASSTRINGS or LBS_NOTIFY or LBS_OWNERDRAWFIXED,0,0,0,0,hWin,1003,hInstance,NULL
		mov		[ebx].RAPROPERTY.hlst,eax
		invoke SetWindowLong,[ebx].RAPROPERTY.hlst,GWL_WNDPROC,offset ListBoxProc
		mov		OldListBoxProc,eax
		;Current open files
		mov		[ebx].RAPROPERTY.nButton,1
		mov		[ebx].RAPROPERTY.backcolor,0FFFFFFh
		mov		[ebx].RAPROPERTY.textcolor,0
		mov		[ebx].RAPROPERTY.oprcolor,0FFh
		invoke GetStockObject,WHITE_BRUSH
		mov		[ebx].RAPROPERTY.hbrback,eax
		invoke CreateToolTip,[ebx].RAPROPERTY.hlst
	.elseif eax==WM_MEASUREITEM
		mov		edx,lParam
		mov		eax,itemht
		mov		[edx].MEASUREITEMSTRUCT.itemHeight,eax
		mov		eax,TRUE
		ret
	.elseif eax==WM_DRAWITEM
		push	esi
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		esi,lParam
		invoke SendMessage,[esi].DRAWITEMSTRUCT.hwndItem,LB_GETTEXT,[esi].DRAWITEMSTRUCT.itemID,addr szname
		.if eax!=LB_ERR
			invoke strlen,addr szname
			mov		len,eax
			test	[esi].DRAWITEMSTRUCT.itemState,ODS_SELECTED
			.if ZERO?
				push	1
				push	[ebx].RAPROPERTY.backcolor
				mov		eax,[ebx].RAPROPERTY.textcolor
			.else
				invoke GetFocus                                 ; *** MOD ***
				.if eax == [ebx].RAPROPERTY.hlst 
					push	0
					invoke GetSysColor,COLOR_HIGHLIGHT
					push	eax
					invoke GetSysColor,COLOR_HIGHLIGHTTEXT
				.else
					push	0
					invoke GetSysColor,COLOR_MENU 
					push	eax
					invoke GetSysColor,COLOR_MENUTEXT
				.endif
			.endif
			invoke SetTextColor,[esi].DRAWITEMSTRUCT.hdc,eax
			pop		eax
			invoke SetBkColor,[esi].DRAWITEMSTRUCT.hdc,eax
			invoke ExtTextOut,[esi].DRAWITEMSTRUCT.hdc,0,0,ETO_OPAQUE,addr [esi].DRAWITEMSTRUCT.rcItem,NULL,0,NULL
			pop		eax
			push	[esi].DRAWITEMSTRUCT.rcItem.left
			add		[esi].DRAWITEMSTRUCT.rcItem.left,3
			.if eax
				push	edi
				mov		edi,offset szname
				xor		ecx,ecx
				.while byte ptr [edi]
					xor		ecx,ecx
					.while byte ptr [edi+ecx]!='(' && byte ptr [edi+ecx]!=')' && byte ptr [edi+ecx]!=',' && byte ptr [edi+ecx]!=':' && byte ptr [edi+ecx]!=0
						inc		ecx
					.endw
					.if ecx
						push	ecx
						push	ecx
						mov		rect.left,0
						mov		rect.top,0
						invoke DrawText,[esi].DRAWITEMSTRUCT.hdc,edi,ecx,addr rect,DT_CALCRECT or DT_SINGLELINE
						pop		ecx
						invoke TextOut,[esi].DRAWITEMSTRUCT.hdc,[esi].DRAWITEMSTRUCT.rcItem.left,[esi].DRAWITEMSTRUCT.rcItem.top,edi,ecx
						mov		eax,rect.right
						inc		eax
						add		[esi].DRAWITEMSTRUCT.rcItem.left,eax
						pop		ecx
						lea		edi,[edi+ecx]
					.elseif byte ptr [edi]
						mov		rect.left,0
						mov		rect.top,0
						invoke DrawText,[esi].DRAWITEMSTRUCT.hdc,edi,1,addr rect,DT_CALCRECT or DT_SINGLELINE
						invoke SetTextColor,[esi].DRAWITEMSTRUCT.hdc,[ebx].RAPROPERTY.oprcolor
						invoke TextOut,[esi].DRAWITEMSTRUCT.hdc,[esi].DRAWITEMSTRUCT.rcItem.left,[esi].DRAWITEMSTRUCT.rcItem.top,edi,1
						invoke SetTextColor,[esi].DRAWITEMSTRUCT.hdc,[ebx].RAPROPERTY.textcolor
						mov		eax,rect.right
						inc		eax
						add		[esi].DRAWITEMSTRUCT.rcItem.left,eax
						inc		edi
					.endif
				.endw
				pop		edi
			.else
				invoke TextOut,[esi].DRAWITEMSTRUCT.hdc,[esi].DRAWITEMSTRUCT.rcItem.left,[esi].DRAWITEMSTRUCT.rcItem.top,offset szname,len
			.endif
			pop		[esi].DRAWITEMSTRUCT.rcItem.left
			pop		esi
		.else
			pop		esi
			xor		eax,eax
			ret
		.endif
	.elseif eax==WM_COMMAND
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			;ToolBar button clicked
			;1 Current file
			;2 All open files
			;3 Selected project file
			;4 All project files
			;5 Refresh
			mov		rapn.nid,eax
			.if eax<5
				mov		[ebx].RAPROPERTY.nButton,eax
			.endif
			mov		rapn.nline,0
			mov		eax,hWin
			mov		rapn.nmhdr.hwndFrom,eax
			mov		edx,[ebx].RAPROPERTY.id
			mov		rapn.nmhdr.idFrom,edx
			mov		rapn.nmhdr.code,BN_CLICKED
			invoke SendMessage,[ebx].RAPROPERTY.hpar,WM_NOTIFY,edx,addr rapn
		.else
			.if edx==CBN_SELCHANGE && eax==1002
				invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_GETCURSEL,0,0
				invoke SendMessage,[ebx].RAPROPERTY.hcbo,CB_GETITEMDATA,eax,0
				invoke UpdateList,eax
				invoke SetFocus,[ebx].RAPROPERTY.hlst
			.elseif edx==CBN_SETFOCUS || edx==LBN_SETFOCUS
				mov		eax,hWin
				mov		nmhdr.hwndFrom,eax
				invoke GetWindowLong,hWin,GWL_ID
				mov		nmhdr.idFrom,eax
				mov		nmhdr.code,NM_SETFOCUS
				invoke GetParent,hWin
				mov		edx,eax
				invoke SendMessage,edx,WM_NOTIFY,nmhdr.idFrom,addr nmhdr
			.elseif edx==CBN_KILLFOCUS || edx==LBN_KILLFOCUS
				mov		eax,hWin
				mov		nmhdr.hwndFrom,eax
				invoke GetWindowLong,hWin,GWL_ID
				mov		nmhdr.idFrom,eax
				mov		nmhdr.code,NM_KILLFOCUS
				invoke GetParent,hWin
				mov		edx,eax
				invoke SendMessage,edx,WM_NOTIFY,nmhdr.idFrom,addr nmhdr
			.elseif edx==LBN_SELCHANGE && eax==1003
				;Selchange
				invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_GETITEMDATA,eax,0
					mov		edx,[eax].PROPERTIES.nOwner
					mov		rapn.nid,edx
					mov		edx,[eax].PROPERTIES.nLine
					mov		rapn.nline,edx
				.else
					xor		eax,eax
					dec		eax
					mov		rapn.nid,eax
					mov		rapn.nline,eax
				.endif
				mov		eax,hWin
				mov		rapn.nmhdr.hwndFrom,eax
				mov		edx,[ebx].RAPROPERTY.id
				mov		rapn.nmhdr.idFrom,edx
				mov		rapn.nmhdr.code,LBN_SELCHANGE
				invoke SendMessage,[ebx].RAPROPERTY.hpar,WM_NOTIFY,edx,addr rapn
			.elseif edx==LBN_DBLCLK && eax==1003
				;Dblclick
				invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_GETITEMDATA,eax,0
					mov		edx,[eax].PROPERTIES.nOwner
					mov		rapn.nid,edx
					mov		edx,[eax].PROPERTIES.nLine
					mov		rapn.nline,edx
					mov		eax,hWin
					mov		rapn.nmhdr.hwndFrom,eax
					mov		edx,[ebx].RAPROPERTY.id
					mov		rapn.nmhdr.idFrom,edx
					mov		rapn.nmhdr.code,LBN_DBLCLK
					invoke SendMessage,[ebx].RAPROPERTY.hpar,WM_NOTIFY,edx,addr rapn
				.endif
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		edx,lParam
		.if [edx].NMHDR.code==TTN_NEEDTEXT
			mov		edx,[edx].NMHDR.idFrom
			mov		eax,offset szRefresh
			.if edx==1
				mov		eax,offset szCurrentFile
			.elseif edx==2
				mov		eax,offset szOpenFiles
			.elseif edx==3
				mov		eax,offset szSelectedProjectFile
			.elseif edx==4
				mov		eax,offset szAllProjectFiles
			.endif
			.if !byte ptr [eax]
				add		edx,10
				invoke LoadString,hInstance,edx,addr buffer,sizeof buffer
				lea		eax,buffer
			.endif
			mov		edx,lParam
			mov		[edx].TOOLTIPTEXT.lpszText,eax
		.endif
	.elseif eax==WM_SIZE
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		push	edi
		mov		edi,28
		invoke GetWindowLong,hWin,GWL_STYLE
		test	eax,PRSTYLE_FLATTOOLBAR
		.if !ZERO?
			sub		edi,4
		.endif
		test	eax,PRSTYLE_DIVIDERLINE
		.if ZERO?
			sub		edi,2
		.endif
		invoke GetClientRect,hWin,addr rect
		invoke MoveWindow,[ebx].RAPROPERTY.htbr,0,0,rect.right,edi,TRUE
		invoke MoveWindow,[ebx].RAPROPERTY.hcbo,0,edi,rect.right,200,TRUE
		invoke GetClientRect,[ebx].RAPROPERTY.hcbo,addr rect1
		add		edi,rect1.bottom
		add		edi,2
		mov		edx,rect.bottom
		sub		edx,edi
		invoke MoveWindow,[ebx].RAPROPERTY.hlst,0,edi,rect.right,edx,TRUE
		pop		edi
	.elseif eax==WM_DESTROY
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke DeleteObject,[ebx].RAPROPERTY.hbrback
		.if [ebx].RAPROPERTY.cbsize
			invoke GlobalUnlock,[ebx].RAPROPERTY.hmem
			invoke GlobalFree,[ebx].RAPROPERTY.hmem
		.endif
		.if [ebx].RAPROPERTY.lpignore
			invoke GlobalFree,[ebx].RAPROPERTY.lpignore
		.endif
		.if [ebx].RAPROPERTY.lpdeftype
			invoke GlobalFree,[ebx].RAPROPERTY.lpdeftype
		.endif
		.if [ebx].RAPROPERTY.hMemArray
			invoke GlobalFree,[ebx].RAPROPERTY.hMemArray
		.endif
		invoke GlobalFree,ebx
		invoke SetWindowLong,hWin,0,0
	.elseif eax==WM_SETFONT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		mov		[ebx].RAPROPERTY.hfont,eax
		invoke SendMessage,[ebx].RAPROPERTY.hcbo,WM_SETFONT,[ebx].RAPROPERTY.hfont,FALSE
		invoke SendMessage,[ebx].RAPROPERTY.hlst,WM_SETFONT,[ebx].RAPROPERTY.hfont,FALSE
		.if lParam
			invoke InvalidateRect,hWin,NULL,TRUE
			invoke InvalidateRect,[ebx].RAPROPERTY.hcbo,NULL,TRUE
			invoke InvalidateRect,[ebx].RAPROPERTY.hlst,NULL,TRUE
		.endif
		invoke SendMessage,hWin,WM_SIZE,0,0
		invoke GetObject,[ebx].RAPROPERTY.hfont,sizeof LOGFONT,addr lfnt
		mov		eax,lfnt.lfHeight
		.if sdword ptr eax<0
			neg		eax
		.endif
		add		eax,4
		mov		itemht,eax
	.elseif eax==WM_CTLCOLOREDIT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SetTextColor,wParam,[ebx].RAPROPERTY.textcolor
		invoke SetBkColor,wParam,[ebx].RAPROPERTY.backcolor
		mov		eax,[ebx].RAPROPERTY.hbrback
		ret
	.elseif eax==WM_CTLCOLORLISTBOX
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SetTextColor,wParam,[ebx].RAPROPERTY.textcolor
		invoke SetBkColor,wParam,[ebx].RAPROPERTY.backcolor
		mov		eax,[ebx].RAPROPERTY.hbrback
		ret
	.elseif eax==WM_SETREDRAW
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,[ebx].RAPROPERTY.hlst,WM_SETREDRAW,wParam,lParam
		.if wParam==TRUE
			invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_SETTOPINDEX,[ebx].RAPROPERTY.topindex,0
			invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_SETCURSEL,[ebx].RAPROPERTY.selindex,0
			invoke InvalidateRect,[ebx].RAPROPERTY.hlst,NULL,TRUE
		.else
			invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_GETTOPINDEX,0,0
			mov		[ebx].RAPROPERTY.topindex,eax
			invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_GETCURSEL,0,0
			mov		[ebx].RAPROPERTY.selindex,eax
		.endif
		ret
	.elseif eax==WM_CONTEXTMENU
		; MOD 14.2.2012  CONTEXTMENU request sets new current item
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
        invoke GetWindowRect,[ebx].RAPROPERTY.hlst,addr rect
   		invoke GetCursorPos,addr pt
		mov		eax,pt.x
		sub     eax,rect.left
		mov		edx,pt.y
		sub     edx,rect.top
		shl		edx,16
		or		edx,eax
        invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_ITEMFROMPOINT,0,edx
        .if eax & 00010000h
			; clicked outside
		.else
			invoke SendMessage,[ebx].RAPROPERTY.hlst,LB_SETCURSEL,eax,0
			invoke SetFocus,[ebx].RAPROPERTY.hlst
		.endif
		mov		eax,pt.x
		mov		edx,pt.y
		shl		edx,16
		or		edx,eax
		invoke SendMessage,[ebx].RAPROPERTY.hpar,WM_CONTEXTMENU,hWin,edx
		xor		eax,eax
		ret
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

SkipToComma:
	.while byte ptr [edx] && byte ptr [edx]!=','
		inc		edx
	.endw
	.if byte ptr [edx]==','
		inc		edx
	.endif
	retn

ControlProc endp

IFDEF DLL
	include Dll.asm
ENDIF

end
