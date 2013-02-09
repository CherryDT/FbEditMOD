.386
.model flat,stdcall
option casemap:none

include Property.inc

.code

UpdateList proc uses ebx
	LOCAL	buffer[256]:BYTE

	invoke SendMessage,hLstProp,LB_GETCURSEL,0,0
	mov		ebx,eax
	invoke SendMessage,hLstProp,LB_GETITEMDATA,ebx,0
	push	eax
	.if eax==1 || eax==2
		; edit
		invoke SendMessage,hEdt,WM_GETTEXT,sizeof buffer,addr buffer
	.elseif eax==3
		; button
	.elseif eax==4 || eax==5
		; combo
		invoke SendMessage,hCbo,CB_GETCURSEL,0,0
		.if eax!=CB_ERR
			mov		edx,eax
			invoke SendMessage,hCbo,CB_GETLBTEXT,edx,addr buffer
		.endif
	.endif
	invoke SendMessage,hLstProp,LB_GETTEXT,ebx,addr tempbuff
	xor		edx,edx
	.while tempbuff[edx]!=VK_TAB
		inc		edx
	.endw
	invoke lstrcpy,addr tempbuff[edx+1],addr buffer
	invoke SendMessage,hLstProp,LB_DELETESTRING,ebx,0
	invoke SendMessage,hLstProp,LB_INSERTSTRING,ebx,addr tempbuff
	pop		eax
	invoke SendMessage,hLstProp,LB_SETITEMDATA,ebx,eax
	invoke SendMessage,hLstProp,LB_SETCURSEL,ebx,0
	ret

UpdateList endp

ShowChildren proc uses ebx,fShow:DWORD
	LOCAL	rect:RECT

	.if fShow
		invoke SendMessage,hLstProp,LB_GETCURSEL,0,0
		.if eax!=LB_ERR
			mov		ebx,eax
			invoke SendMessage,hLstProp,LB_GETITEMRECT,ebx,addr rect
			invoke SendMessage,hLstProp,LB_GETTEXT,ebx,addr tempbuff
			xor		eax,eax
			.while tempbuff[eax]!=VK_TAB && tempbuff[eax]
				inc		eax
			.endw
			.if tempbuff[eax]==VK_TAB
				inc		eax
			.endif
			lea		esi,tempbuff[eax]
			invoke SendMessage,hLstProp,LB_GETITEMDATA,ebx,0
			.if eax==1 || eax==2
				; Show edit
				invoke SendMessage,hEdt,WM_SETTEXT,0,esi
				inc		rect.top
				mov		eax,rect.bottom
				sub		eax,rect.top
				dec		eax
				mov		rect.bottom,eax
				mov		rect.left,nPropWt
				sub		rect.right,nPropWt
				invoke MoveWindow,hEdt,rect.left,rect.top,rect.right,rect.bottom,TRUE
				invoke ShowWindow,hEdt,SW_SHOWNA
			.elseif eax==3
				; Show button
				mov		eax,rect.bottom
				sub		eax,rect.top
				dec		eax
				mov		rect.bottom,eax
				mov		edx,rect.right
				sub		edx,eax
				mov		rect.left,edx
				mov		rect.right,eax
				invoke MoveWindow,hBtn,rect.left,rect.top,rect.right,rect.bottom,TRUE
				invoke ShowWindow,hBtn,SW_SHOWNA
			.elseif eax==4 || eax==5
				; Show combo
				push	esi
				.if eax==4
					mov		esi,offset szPropValue4
				.else
					mov		esi,offset szPropValue5
				.endif
				invoke SendMessage,hCbo,CB_RESETCONTENT,0,0
				.while byte ptr [esi+1]
					invoke SendMessage,hCbo,CB_ADDSTRING,0,addr [esi+1]
					movzx	edx,byte ptr [esi]
					invoke SendMessage,hCbo,CB_SETITEMDATA,eax,edx
					invoke lstrlen,addr [esi+1]
					lea		esi,[esi+eax+2]
				.endw
				pop		esi
				invoke SendMessage,hCbo,CB_FINDSTRINGEXACT,0,esi
				.if eax!=CB_ERR
					invoke SendMessage,hCbo,CB_SETCURSEL,eax,0
				.endif
				sub		rect.top,2
				mov		rect.left,nPropWt-1
				sub		rect.right,nPropWt-3
				invoke MoveWindow,hCbo,rect.left,rect.top,rect.right,100,TRUE
				invoke ShowWindow,hCbo,SW_SHOWNA
			.endif
		.endif
		invoke SetFocus,hLstProp
	.else
		invoke ShowWindow,hEdt,SW_HIDE
		invoke ShowWindow,hBtn,SW_HIDE
		invoke ShowWindow,hCbo,SW_HIDE
	.endif
	ret

ShowChildren endp

ChildEditProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_CHAR
		.if wParam==VK_RETURN
			invoke ShowWindow,hWin,SW_HIDE
			invoke ShowWindow,hWin,SW_SHOWNA
			xor		eax,eax
			jmp		Ex
		.elseif wParam==VK_ESCAPE
			invoke ShowChildren,TRUE
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_KILLFOCUS
		invoke UpdateList
	.endif
	invoke CallWindowProc,lpOldChildEditProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ChildEditProc endp

ChildComboProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_PAINT
		invoke ValidateRect,hWin,NULL
		invoke GetClientRect,hWin,addr rect
		mov		eax,rect.right
		sub		eax,18
		mov		rect.left,eax
		add		rect.top,4
		invoke InvalidateRect,hWin,addr rect,TRUE
	.elseif eax==WM_KILLFOCUS
		invoke UpdateList
	.elseif eax==WM_CHAR
		.if wParam==VK_ESCAPE || wParam==VK_RETURN
			invoke SetFocus,hLstProp
			xor		eax,eax
			jmp		Ex
		.endif
	.endif
	invoke CallWindowProc,lpOldChildComboProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ChildComboProc endp

PropListProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	buffer[256]:BYTE

	mov		eax,uMsg
	.if eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_BTN1
				; Button clicked
				invoke SendMessage,hWin,LB_GETCURSEL,0,0
				mov		ebx,eax
				invoke SendMessage,hWin,LB_GETTEXT,ebx,addr tempbuff
				xor		eax,eax
				.while tempbuff[eax]!=VK_TAB
					inc		eax
				.endw
				invoke MessageBox,hWnd,addr tempbuff[eax+1],addr szTest,MB_OK
				invoke SetFocus,hWin
			.endif
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_LBUTTONDOWN
		invoke ShowChildren,FALSE
	.elseif eax==WM_LBUTTONDBLCLK
		invoke SendMessage,hWin,LB_GETCURSEL,0,0
		.if eax!=LB_ERR
			mov		ebx,eax
			invoke SendMessage,hWin,LB_GETITEMDATA,ebx,0
			.if eax==1 || eax==2
				invoke SendMessage,hEdt,EM_SETSEL,0,-1
				invoke SetFocus,hEdt
			.elseif eax==3
				invoke SendMessage,hWin,WM_COMMAND,(BN_CLICKED shl 16) or IDC_BTN1,0
			.elseif eax==4 || eax==5
				invoke SendMessage,hCbo,CB_GETCURSEL,0,0
				invoke SendMessage,hCbo,CB_SETCURSEL,addr [eax+1],0
				.if eax==CB_ERR
					invoke SendMessage,hCbo,CB_SETCURSEL,0,0
				.endif
				invoke SetFocus,hCbo
				invoke SetFocus,hWin
			.endif
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_CHAR
		.if wParam==VK_RETURN
			invoke SendMessage,hWin,LB_GETCURSEL,0,0
			.if eax!=LB_ERR
				mov		ebx,eax
				invoke SendMessage,hWin,LB_GETITEMDATA,ebx,0
				.if eax==1 || eax==2
					invoke SetFocus,hEdt
				.elseif eax==3
					invoke SendMessage,hWin,WM_COMMAND,(BN_CLICKED shl 16) or IDC_BTN1,0
				.elseif eax==4 || eax==5
					invoke SetFocus,hCbo
					invoke SendMessage,hCbo,CB_SHOWDROPDOWN,TRUE,0
				.endif
			.endif
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_VSCROLL || eax==WM_HSCROLL || eax==WM_MOUSEWHEEL || eax==WM_SIZE
		invoke ShowChildren,FALSE
		invoke CallWindowProc,lpOldPropListProc,hWin,uMsg,wParam,lParam
		invoke ShowChildren,TRUE
		xor		eax,eax
		jmp		Ex
	.endif
	invoke CallWindowProc,lpOldPropListProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

PropListProc endp

WndProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	lf:LOGFONT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWnd,eax
		; Get handle of property listbox
		invoke GetDlgItem,hWin,IDC_LST1
		mov		hLstProp,eax
		; Subclass
		invoke SetWindowLong,hLstProp,GWL_WNDPROC,offset PropListProc
		mov		lpOldPropListProc,eax
		; Set height of items
		invoke SendMessage,hLstProp,LB_SETITEMHEIGHT,0,19
		; Get handle of child editbox
		invoke GetDlgItem,hWin,IDC_EDT1
		mov		hEdt,eax
		; Subclass
		invoke SetWindowLong,hEdt,GWL_WNDPROC,offset ChildEditProc
		mov		lpOldChildEditProc,eax
		; Get handle of child button
		invoke GetDlgItem,hWin,IDC_BTN1
		mov		hBtn,eax
		; Get handle of child combobox
		invoke GetDlgItem,hWin,IDC_CBO1
		mov		hCbo,eax
		; Subclass
		invoke SetWindowLong,hCbo,GWL_WNDPROC,offset ChildComboProc
		mov		lpOldChildComboProc,eax
		; Make the property listbox the parent
		invoke SetParent,hCbo,hLstProp
		invoke SetParent,hEdt,hLstProp
		invoke SetParent,hBtn,hLstProp
		; Insert some properties
		mov		esi,offset szPropItems
		.while byte ptr [esi+1]
			movzx	ebx,byte ptr [esi]
			invoke SendMessage,hLstProp,LB_ADDSTRING,0,addr [esi+1]
			invoke SendMessage,hLstProp,LB_SETITEMDATA,eax,ebx
			invoke lstrlen,addr [esi+1]
			lea		esi,[esi+eax+2]
		.endw
		invoke SendMessage,hLstProp,LB_SETCURSEL,0,0
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==LBN_SELCHANGE
			.if eax==IDC_LST1
				invoke ShowChildren,FALSE
				invoke ShowChildren,TRUE
			.endif
		.endif
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke MoveWindow,hLstProp,0,0,rect.right,rect.bottom,TRUE
	.elseif	eax==WM_DRAWITEM
		mov		esi,lParam
		mov		eax,[esi].DRAWITEMSTRUCT.hwndItem
		.if eax==hLstProp
			.if [esi].DRAWITEMSTRUCT.itemID!=LB_ERR
				; Set text and back cokors
				test	[esi].DRAWITEMSTRUCT.itemState,ODS_SELECTED
				.if ZERO?
					invoke GetSysColor,COLOR_WINDOWTEXT
					invoke SetTextColor,[esi].DRAWITEMSTRUCT.hdc,eax
					invoke GetSysColor,COLOR_WINDOW
					invoke SetBkColor,[esi].DRAWITEMSTRUCT.hdc,eax
				.else
					invoke GetSysColor,COLOR_HIGHLIGHTTEXT
					invoke SetTextColor,[esi].DRAWITEMSTRUCT.hdc,eax
					invoke GetSysColor,COLOR_HIGHLIGHT
					invoke SetBkColor,[esi].DRAWITEMSTRUCT.hdc,eax
				.endif
				; Draw back color
				push	[esi].DRAWITEMSTRUCT.rcItem.right
				mov		eax,[esi].DRAWITEMSTRUCT.hwndItem
				mov		eax,nPropWt
				mov		[esi].DRAWITEMSTRUCT.rcItem.right,eax
				invoke ExtTextOut,[esi].DRAWITEMSTRUCT.hdc,0,0,ETO_OPAQUE,addr [esi].DRAWITEMSTRUCT.rcItem,NULL,0,NULL
				pop		[esi].DRAWITEMSTRUCT.rcItem.right
				; Get the items text
				invoke SendMessage,[esi].DRAWITEMSTRUCT.hwndItem,LB_GETTEXT,[esi].DRAWITEMSTRUCT.itemID,addr tempbuff
				; Get lenght of 1st item
				mov		eax,offset tempbuff
				.while byte ptr [eax] && byte ptr [eax]!=VK_TAB
					inc		eax
				.endw
				sub		eax,offset tempbuff
				mov		edx,[esi].DRAWITEMSTRUCT.rcItem.top
				invoke TextOut,[esi].DRAWITEMSTRUCT.hdc,2,addr [edx+1],addr tempbuff,eax
				invoke GetSysColor,COLOR_WINDOWTEXT
				invoke SetTextColor,[esi].DRAWITEMSTRUCT.hdc,eax
				invoke GetSysColor,COLOR_WINDOW
				invoke SetBkColor,[esi].DRAWITEMSTRUCT.hdc,eax
				; Get address of 2nd item
				mov		edx,offset tempbuff
				.while byte ptr [edx] && byte ptr [edx]!=VK_TAB
					inc		edx
				.endw
				inc		edx
				; get lenght of 2nd item
				mov		eax,edx
				.while byte ptr [eax] && byte ptr [eax]!=VK_TAB
					inc		eax
				.endw
				sub		eax,edx
				mov		ecx,[esi].DRAWITEMSTRUCT.rcItem.top
				invoke TextOut,[esi].DRAWITEMSTRUCT.hdc,nPropWt+3,addr [ecx+1],edx,eax
				; Create a pen
				invoke CreatePen,PS_SOLID,0,0C0C0C0h
				invoke SelectObject,[esi].DRAWITEMSTRUCT.hdc,eax
				push	eax
				; Draw the lines
				mov		edx,[esi].DRAWITEMSTRUCT.rcItem.bottom
				dec		edx
				invoke MoveToEx,[esi].DRAWITEMSTRUCT.hdc,[esi].DRAWITEMSTRUCT.rcItem.left,edx,NULL
				mov		edx,[esi].DRAWITEMSTRUCT.rcItem.bottom
				dec		edx
				invoke LineTo,[esi].DRAWITEMSTRUCT.hdc,[esi].DRAWITEMSTRUCT.rcItem.right,edx
				mov		eax,[esi].DRAWITEMSTRUCT.hwndItem
				mov		edx,[esi].DRAWITEMSTRUCT.rcItem.left
				add		edx,nPropWt
				invoke MoveToEx,[esi].DRAWITEMSTRUCT.hdc,edx,[esi].DRAWITEMSTRUCT.rcItem.top,NULL
				mov		edx,[esi].DRAWITEMSTRUCT.rcItem.left
				add		edx,nPropWt
				invoke LineTo,[esi].DRAWITEMSTRUCT.hdc,edx,[esi].DRAWITEMSTRUCT.rcItem.bottom
				pop		eax
				invoke SelectObject,[esi].DRAWITEMSTRUCT.hdc,eax
				invoke DeleteObject,eax
			.endif
			; Return TRUE to prevent windows from drawing a focus rectangle
			mov		eax,TRUE
			ret
		.endif
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.elseif uMsg==WM_DESTROY
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

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset ClassName
	mov		wc.hIcon,NULL
	mov		wc.hIconSm,NULL
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_DIALOG,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .break .if !eax
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke InitCommonControls
	invoke GetCommandLine
	mov		CommandLine,eax
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	invoke ExitProcess,eax

end start
