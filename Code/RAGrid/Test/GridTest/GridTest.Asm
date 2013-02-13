.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include GridTest.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax

	invoke LoadLibrary,offset szRAGridDLL
	.if eax
		mov		hRAGridDLL,eax
	    invoke InitCommonControls
		invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
		invoke FreeLibrary,hRAGridDLL
	.endif
	invoke ExitProcess,0
	
;########################################################################

GrdProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE

	mov		eax,uMsg
	.if eax==WM_MOUSEMOVE
		mov		edx,lParam
		movzx	eax,dx
		shr		edx,16
		invoke wsprintf,addr buffer,addr szFmt,eax,edx
		invoke SetWindowText,hSbr,addr buffer
	.elseif eax==WM_LBUTTONDOWN
		invoke SetWindowText,hSbr,addr szDown
	.elseif eax==WM_LBUTTONUP
		invoke SetWindowText,hSbr,addr szUp
	.endif
	invoke CallWindowProc,OldGrdProc,hWin,uMsg,wParam,lParam
	ret

GrdProc endp

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	col:COLUMN
	LOCAL	buffer[256]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_SBR1
		mov		hSbr,eax
		invoke GetDlgItem,hWin,IDC_GRD1
		mov		hGrd,eax

		invoke SetWindowLong,hGrd,GWL_WNDPROC,offset GrdProc
		mov		OldGrdProc,eax
		invoke SendMessage,hWin,WM_GETFONT,0,0
		invoke SendMessage,hGrd,WM_SETFONT,eax,FALSE
		invoke SendMessage,hGrd,GM_SETBACKCOLOR,0C0FFFFh,0
		invoke SendMessage,hGrd,GM_SETGRIDCOLOR,808080h,0
		invoke SendMessage,hGrd,GM_SETTEXTCOLOR,800000h,0
		;Text column
		mov		col.colwt,130
		mov		col.lpszhdrtext,offset szName
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,31
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Number column
		mov		col.colwt,42
		mov		col.lpszhdrtext,offset szID
		mov		col.halign,GA_ALIGN_RIGHT
		mov		col.calign,GA_ALIGN_RIGHT
		mov		col.ctype,TYPE_EDITLONG
		mov		col.ctextmax,11
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Edit button column
		mov		col.colwt,130
		mov		col.lpszhdrtext,offset szID
		mov		col.halign,GA_ALIGN_LEFT
		mov		col.calign,GA_ALIGN_LEFT
		mov		col.ctype,TYPE_EDITBUTTON
		mov		col.ctextmax,31
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Add some rows
		push	esi
		mov		esi,offset rdta
		mov		ecx,4
		.while ecx
			push	ecx
			invoke SendMessage,hGrd,GM_ADDROW,0,esi
			pop		ecx
			add		esi,sizeof rdta
			dec		ecx
		.endw
		pop		esi
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==1003
				invoke SendMessage,hGrd,GM_ENTEREDIT,2,1
			.elseif eax==1004
				invoke SendMessage,hGrd,GM_ENDEDIT,00010002h,FALSE
			.elseif eax==1005
				mov		dword ptr buffer,'cba'
				invoke SendMessage,hGrd,GM_SETCELLDATA,00010002h,addr buffer
			.elseif eax==1006
				invoke CreateFontIndirect,addr MS_Sans_Serif_14
				invoke SendMessage,hGrd,WM_SETFONT,eax,TRUE
				invoke SendMessage,hGrd,GM_SETROWHEIGHT,0,30
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		edx,lParam
		mov		eax,[edx].GRIDNOTIFY.nmhdr.hwndFrom
		.if eax==hGrd
			.if [edx].GRIDNOTIFY.nmhdr.code==GN_BEFOREEDIT
				.if [edx].GRIDNOTIFY.col==0
					mov		[edx].GRIDNOTIFY.fcancel,TRUE
				.endif
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

end start
