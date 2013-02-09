.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include Browse.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax
	invoke LoadLibrary,addr szRAProject
	mov		hLib,eax
    invoke InitCommonControls
	invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
	invoke FreeLibrary,hLib
	invoke ExitProcess,0

;########################################################################

DlgProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	pt:POINT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_RAP
		mov		hPbr,eax
		invoke SendMessage,hPbr,RPBM_SETPATH,0,addr pbpath
		;Clear PBFILEEXT array
		invoke SendMessage,hPbr,RPBM_ADDFILEEXT,0,0
		mov		esi,offset pbfileext
		xor		edi,edi
		.while [esi].PBFILEEXT.id
			invoke SendMessage,hPbr,RPBM_ADDFILEEXT,edi,esi
			inc		edi
			lea		esi,[esi+sizeof PBFILEEXT]
		.endw
		;Clear PBITEM array
		invoke SendMessage,hPbr,RPBM_ADDITEM,0,0
		mov		esi,offset pbitems
		xor		edi,edi
		.while [esi].PBITEM.id
			invoke SendMessage,hPbr,RPBM_ADDITEM,edi,esi
			inc		edi
			lea		esi,[esi+sizeof PBITEM]
		.endw
		invoke SendMessage,hPbr,RPBM_SETGROUPING,TRUE,RPBG_GROUPS
		invoke LoadMenu,hInstance,IDR_MENU
		mov		hMnu,eax
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDM_PROJECT_ADDGROUP
				invoke SendMessage,hPbr,RPBM_ADDNEWGROUP,0,0
			.elseif eax==IDM_PROJECT_DELGROUP
				invoke SendMessage,hPbr,RPBM_DELETEITEM,0,0
			.elseif eax==IDM_PROJECT_EDITGROUP
				invoke SendMessage,hPbr,RPBM_EDITITEM,0,0
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		esi,lParam
		mov		eax,[esi].NMHDR.hwndFrom
		.if eax==hPbr
			mov		eax,[esi].NMHDR.code
			.if eax==RPBN_DBLCLICK
				mov		esi,[esi].NMPBITEMDBLCLICK.lpPBITEM
lea		eax,[esi].PBITEM.szitem
;PrintStringByAddr eax
			.elseif eax==RPBN_ITEMCHANGE
				;mov		[esi].NMPBITEMCHANGE.cancel,TRUE
			.endif
		.endif
	.elseif eax==WM_CONTEXTMENU
		mov		eax,lParam
		.if eax!=-1
			cwde
			mov		pt.x,eax
			mov		eax,lParam
			shr		eax,16
			cwde
			mov		pt.y,eax
		.else
			invoke GetWindowRect,hPbr,addr rect
			mov		eax,rect.left
			add		eax,10
			mov		pt.x,eax
			mov		eax,rect.top
			add		eax,10
			mov		pt.y,eax
		.endif
		invoke GetSubMenu,hMnu,0
		mov		edi,eax
		invoke SendMessage,hPbr,RPBM_GETSELECTED,0,0
		.if eax
			mov		esi,eax
			mov		eax,[esi].PBITEM.id
			.if sdword ptr eax<0
				.if eax==-1
					mov		eax,MF_BYCOMMAND or MF_GRAYED
				.else
					mov		eax,MF_BYCOMMAND or MF_ENABLED
				.endif
				invoke EnableMenuItem,hMnu,IDM_PROJECT_DELGROUP,eax
				invoke TrackPopupMenu,edi,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWin,0
			.endif
		.endif
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke MoveWindow,hPbr,0,0,rect.right,rect.bottom,TRUE
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
