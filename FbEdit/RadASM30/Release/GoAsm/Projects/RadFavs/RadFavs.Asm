#Include "RadFavs.h"

EXPORT InstallAddin,AddinProc

DATA SECTION

	hInstance		HANDLE	0
	lpHandles		PTR		0
	lpProcs			PTR		0
	lpData			PTR		0

	hFavMenu		HANDLE	0
	hRadASM			HANDLE	0
	hManageDlg		HANDLE	0

	TopIDIndex		DD		0

	AddToID			DD		0
	ManageID		DD		0
	FirstID			DD		0
	LastID			DD		0

	DrgListMsg		DD		0

	pSetMenuInfo	PTR		0
	pGetMenuInfo	PTR		0

	IDTable			DD		1024 DUP (?)
	IndexTable		DD		1024 DUP (?)

	szFavourites	CHAR	"Favourites",0
	szAddToFavs		CHAR	"Add to favourites",0
	szManageFavs	CHAR	"Manage favourites",0

	hook			HOOK	<>

CODE SECTION

DllEntryPoint FRAME hInst, reason, reserved1
    mov eax,[hInst]
    mov [hInstance], eax
    xor eax, eax
    inc eax
    ret
ENDF

InstallAddin FRAME hWin
	uses ebx
	LOCAL menui				:MENUINFO
	LOCAL IniPath[MAX_PATH]	:%CHAR
	LOCAL cbWrite			:D

	invoke SendMessage, [hWin], AIM_GETHANDLES, 0, 0
	mov	[lpHandles], eax
	invoke SendMessage, [hWin], AIM_GETPROCS, 0, 0
	mov [lpProcs], eax
	invoke SendMessage, [hWin], AIM_GETDATA, 0, 0
	mov [lpData], eax

	invoke CreatePopupMenu
	mov [hFavMenu],eax

	mov eax,[hWin]
	mov [hRadASM],eax

	; Get the path of the favourites
	mov eax,[lpData]
	add eax,ADDINDATA.szAppPath
	
	invoke lstrcpy,offset IniPath,eax
	invoke lstrcat,offset IniPath,"\RadFavs.ini"

	invoke GetFileAttributes,offset IniPath
	or eax,eax
	jns >
		invoke DeleteFile,offset IniPath
		invoke CreateFile,offset IniPath,GENERIC_WRITE,NULL,NULL,CREATE_ALWAYS,NULL,NULL
		mov ebx,eax
		invoke WriteFile,ebx,"[Favourites]",12,offset cbWrite,NULL
		invoke CloseHandle,ebx
	:

	invoke SendMessage, [hWin], AIM_GETMENUID, 0, 0
	mov [AddToID],eax
	invoke AppendMenu,[hFavMenu],MF_ENABLED + MF_STRING,[AddToID],offset szAddToFavs

	invoke SendMessage, [hWin], AIM_GETMENUID, 0, 0
	mov [ManageID],eax
	invoke AppendMenu,[hFavMenu],MF_ENABLED + MF_STRING,[ManageID],offset szManageFavs

	invoke AppendMenu,[hFavMenu],MF_SEPARATOR,NULL,offset szManageFavs

	xor ebx,ebx
	:
	invoke SendMessage, [hRadASM], AIM_GETMENUID, 0, 0
	mov ecx,offset IDTable
	mov [ecx+ebx*4],eax
	inc ebx
	cmp ebx,1024
	jl <

	mov eax,[lpHandles]
	mov eax,[eax+ADDINHANDLES.hMenu]
	invoke AppendMenu,eax,MF_ENABLED + MF_POPUP + MF_STRING, \
		[hFavMenu],offset szFavourites

	invoke GetGlobalFavs,[hFavMenu]

	; If this is WinNT4 or Win95 the Get/SetMenuInfo functions
	; are not available and will not execute.
	invoke GetModuleHandle,"User32.dll"
	mov ebx,eax
	invoke GetProcAddress,ebx,"SetMenuInfo"
	mov [pSetMenuInfo],eax
	invoke GetProcAddress,ebx,"GetMenuInfo"
	mov [pGetMenuInfo],eax

	; be sure our menu has the same appearance as the others
	mov D[menui.cbSize],SIZEOF MENUINFO
	mov D[menui.fMask],MIM_BACKGROUND
	mov eax,[lpHandles]
	mov eax,[eax+ADDINHANDLES.hMenu]
	invoke GetSubMenu,eax,1
	invoke GetMenuInfo,eax,offset menui
	invoke SetMenuInfo,[hFavMenu],offset menui

	invoke DrawMenuBar,[hRadASM]

	invoke RegisterWindowMessage,"commctrl_DragListMsg"
	mov [DrgListMsg],eax

	mov		D[hook.hook1],HOOK_COMMAND or HOOK_CLOSE
	xor		eax,eax
	mov		[hook.hook2],eax
	mov		[hook.hook3],eax
	mov		[hook.hook4],eax
	mov		eax,offset hook
	ret

ENDF

AddinProc	FRAME hWin, uMsg, wParam, lParam
	uses ebx
	LOCAL mii				:MENUITEMINFO

	cmp D[uMsg], AIM_COMMAND
	jnz >>.AIMCLOSE
		movzx eax,W[wParam]
		cmp eax,[FirstID]
		jl >>.ADDTOFAVS
		cmp eax,[LastID]
		jg >>.ExitMsgLoop
		sub eax,[FirstID]
		mov ecx,offset IndexTable
		mov eax,[ecx+eax*4]
		or eax,eax
		jz >>.ExitMsgLoop
		mov ecx,[lpProcs]
		mov ecx,[ecx+ADDINPROCS.lpOpenTheFile]
		push ID_PROJECT
		push eax
		call ecx
		jmp >>.ExitMsgLoop

		.ADDTOFAVS
		cmp eax,[AddToID]
		jne >.EDITFAVS
		invoke AddToFavourites

		jmp >.ExitMsgLoop
		.EDITFAVS
		cmp eax,[ManageID]
		jne >.ExitMsgLoop
			invoke DialogBoxParam,[hInstance],2000,[hRadASM],offset ManageDlgProc,NULL
		jmp >.ExitMsgLoop

	.AIMCLOSE
	cmp D[uMsg], AIM_CLOSE
	jnz >.ExitMsgLoop
		invoke FreeMenuBuffers,[hFavMenu]
		mov eax,[lpHandles]
		mov eax,[eax+ADDINHANDLES.hMenu]
		invoke DeleteMenu,eax,[hFavMenu],MF_BYCOMMAND
		invoke DrawMenuBar,[hRadASM]
		mov D[TopIDIndex],0
		jmp >.ExitMsgLoop

	.ExitMsgLoop
	xor eax, eax
	ret
ENDF

FreeMenuBuffers FRAME hmenu
	uses ebx,esi
	LOCAL ItemID		:D

	invoke GetMenuItemCount,[hFavMenu]
	mov esi,eax
	mov ebx,3
	L2:
		invoke GetMenuItemID,[hFavMenu],ebx
		mov [ItemID],eax
		or eax,eax
		js >.EXIT
		sub eax,[FirstID]
		mov ecx,offset IndexTable
		mov eax,[ecx+eax*4]
		or eax,eax
		jz >.EXIT
		invoke GlobalHandle,eax
		invoke GlobalFree,eax
		inc ebx
		cmp ebx,esi
		jl <L2

	.EXIT
	RET
ENDF

GetGlobalFavs FRAME hmenu
	uses ebx,edi,esi
	LOCAL buffer[324]		:%CHAR
	LOCAL IniPath[MAX_PATH]	:%CHAR
	LOCAL Index[16]			:B
	LOCAL mii				:MENUITEMINFO

	invoke RtlZeroMemory,offset mii,SIZEOF MENUITEMINFO

	mov eax,[IDTable]
	mov D[FirstID],eax
	mov D[LastID],eax

	; Get the path of the favourites
	mov eax,[lpData]
	add eax,ADDINDATA.szAppPath
	invoke lstrcpy,offset IniPath,eax
	invoke lstrcat,offset IniPath,"\RadFavs.ini"

	xor ebx,ebx
	L1:
		inc ebx
		invoke wsprintf,offset Index,"%u",ebx
		add esp,12
		invoke GetPrivateProfileString,"Favourites",offset Index,"",\
			offset buffer,324,offset IniPath
		or eax,eax
		jz >>.EXIT
		mov edi,offset buffer
		mov esi,edi
		mov ecx,eax
		mov al,","
		repne scasb
		mov B[edi-1],0
		invoke lstrlen,edi
		inc eax
		invoke GlobalAlloc,GMEM_ZEROINIT,eax
		mov [mii.dwItemData],eax
		invoke lstrcpy,eax,edi

		mov eax,offset IDTable
		mov ecx,[TopIDIndex]
		mov eax,[eax+ecx*4]
		inc D[TopIDIndex]
		cmp D[TopIDIndex],1024
		jge >>.EXIT

		mov [LastID],eax
		mov [mii.wID],eax

		;******************
		sub eax,[FirstID]
		mov ecx,offset IndexTable
		mov edx,[mii.dwItemData]
		mov [ecx+eax*4],edx
		;********************

		mov D[mii.fState],MFS_ENABLED
		mov [mii.dwTypeData],esi
		mov D[mii.cbSize],SIZEOF MENUITEMINFO
		mov D[mii.fMask], MIIM_STRING + MIIM_ID + MIIM_STATE
		invoke InsertMenuItem,[hmenu],-1,TRUE,offset mii

		jmp <<L1

	.EXIT
	RET

ENDF

AddToFavourites FRAME
	uses ebx
	LOCAL MenuLabel[64]		:%CHAR
	LOCAL FileName[MAX_PATH]:%CHAR
	LOCAL Index[16]			:B
	LOCAL IniPath[MAX_PATH]	:%CHAR
	LOCAL OutString[324]	:%CHAR
	LOCAL DlgStruct[2]		:D
	LOCAL mii				:MENUITEMINFO

	invoke RtlZeroMemory,offset mii,SIZEOF MENUITEMINFO

	mov eax,[lpData]
	mov eax,[eax+ADDINDATA.fProject]
	or eax,eax
	jz >>.EXIT

	mov eax,OFFSET MenuLabel
	mov D[DlgStruct],eax
	mov eax,[lpData]
	add eax,ADDINDATA.szProjectFile
	mov D[DlgStruct+4],eax

	; Get the path of the favourites
	mov eax,[lpData]
	add eax,ADDINDATA.szAppPath
	invoke lstrcpy,offset IniPath,eax
	invoke lstrcat,offset IniPath,"\RadFavs.ini"

	invoke lstrcpy,OFFSET MenuLabel,"No label entered"

	invoke DialogBoxParam,[hInstance],1000,[hRadASM],offset EnterLabelDlgProc,offset DlgStruct
	or eax,eax
	js >>.EXIT

	; Get next index
	xor ebx,ebx
	:
		inc ebx
		invoke wsprintf,offset Index,"%u",ebx
		add esp,12
		invoke GetPrivateProfileString,"Favourites",offset Index,"",\
			offset FileName,MAX_PATH,offset IniPath
		or eax,eax
		jnz <
	:

	mov B[FileName],","
	mov eax,[lpData]
	add eax,ADDINDATA.szProjectFile
	invoke lstrcpy,offset FileName+1,eax

	invoke lstrcpy,offset OutString,offset MenuLabel
	invoke lstrcat,offset OutString,offset FileName

	invoke WritePrivateProfileString,"Favourites",offset Index,offset OutString,offset IniPath

	invoke lstrlen,offset FileName+1
	inc eax
	invoke GlobalAlloc,GMEM_ZEROINIT,eax
	mov [mii.dwItemData],eax
	invoke lstrcpy,eax,offset FileName+1

	mov eax,offset IDTable
	mov ecx,[TopIDIndex]
	mov eax,[eax+ecx*4]
	inc D[TopIDIndex]
	cmp D[TopIDIndex],1024
	jge >.EXIT

	mov [mii.wID],eax
	mov [LastID],eax

	;******************
	sub eax,[FirstID]
	mov ecx,offset IndexTable
	mov edx,[mii.dwItemData]
	mov [ecx+eax*4],edx
	;********************

	mov D[mii.fState],MFS_ENABLED
	lea eax,MenuLabel
	mov [mii.dwTypeData],eax
	mov D[mii.cbSize],SIZEOF MENUITEMINFO
	mov D[mii.fMask], MIIM_STRING + MIIM_ID + MIIM_STATE
	invoke InsertMenuItem,[hFavMenu],-1,TRUE,offset mii

	.EXIT
	RET
ENDF

EnterLabelDlgProc FRAME hwnd,uMsg,wParam,lParam
	uses ebx,edi
	cmp D[uMsg],WM_INITDIALOG
	jne >M1
		invoke GetDlgItem,[hwnd],1002
		mov ebx,eax
		mov edi,[lParam]
		invoke GetDlgItem,[hwnd],1004
		invoke SendMessage,eax,WM_SETTEXT,0,[edi+4]
		invoke SendMessage,ebx,WM_SETTEXT,0,[edi]
		invoke SendMessage,ebx,EM_LIMITTEXT,63,0
		invoke SetWindowLong,ebx,GWL_USERDATA,[edi]
		mov B[edi],0
		jmp >.EXIT

	M1:
	cmp D[uMsg],WM_CLOSE
	jne >M2
		invoke EndDialog,[hwnd],-1
		jmp >.EXIT

	M2:
	cmp D[uMsg],WM_COMMAND
	jne >.DEFPROC
		movzx eax,W[wParam]
		cmp eax,1005
		jne >C1
			invoke GetDlgItem,[hwnd],1002
			mov ebx,eax
			invoke GetWindowLong,ebx,GWL_USERDATA
			invoke SendMessage,ebx,WM_GETTEXT,64,eax
			invoke EndDialog,[hwnd],0
			jmp >.EXIT
		C1:
		cmp eax,1006
		jne >.DEFPROC
			invoke PostMessage,[hwnd],WM_CLOSE,0,0
			jmp >.EXIT

	.DEFPROC
		xor eax,eax
		ret

	.EXIT

	xor eax,eax
	inc eax
	RET
ENDF

ManageDlgProc FRAME hwnd,uMsg,wParam,lParam
	uses edi,ebx,esi
	LOCAL pt			:POINT
	LOCAL rect			:RECT
	LOCAL buffer[256]	:%CHAR
	LOCAL ItemID		:D

	mov eax,[uMsg]
	.WMINITDIALOG
		cmp eax,WM_INITDIALOG
		jne >>.DRAGLIST
		invoke GetDlgItem,[hwnd],2001
		mov ebx,eax
		invoke MakeDragList,ebx
		invoke GetMenuItemCount,[hFavMenu]
		mov esi,eax

		mov edi,3 ; begin at position 3 in the menu
		jmp >>L2
		L1:

		invoke GetMenuItemID,[hFavMenu],edi
		mov [ItemID],eax
		invoke GetMenuString,[hFavMenu],edi,offset buffer,255,MF_BYPOSITION

		invoke SendMessage,ebx,LB_ADDSTRING,0,offset buffer

		mov edx,[ItemID]
		sub edx,[FirstID]
		mov ecx,offset IndexTable
		mov edx,[ecx+edx*4]
		invoke SendMessage,ebx,LB_SETITEMDATA,eax,edx ;[mii.dwItemData]
		inc edi
		L2:
		cmp edi,esi
		jl <<L1
		invoke GetDlgItem,[hwnd],2006
		invoke SendMessage,eax,EM_LIMITTEXT,63,0
		JMP >>.EXIT

	.DRAGLIST
		cmp eax,[DrgListMsg]
		jne >>.WMCOMMAND
			mov edi,[lParam]
			cmp D[edi+DRAGLISTINFO.uNotification],DL_BEGINDRAG
			jne >.DL_DRAGGING
				invoke LBItemFromPt,[edi+DRAGLISTINFO.hwnd],[edi+DRAGLISTINFO.ptCursor.x],\
					[edi+DRAGLISTINFO.ptCursor.y],FALSE
				push eax
				invoke DrawInsert,[hwnd],[edi+DRAGLISTINFO.hwnd],eax
				pop eax
				invoke SetWindowLong,[edi+DRAGLISTINFO.hwnd],GWL_USERDATA,eax
				invoke SetWindowLong,[hwnd],DWL_MSGRESULT,TRUE
				mov eax,TRUE
				ret

			.DL_DRAGGING
			cmp D[edi+DRAGLISTINFO.uNotification],DL_DRAGGING
			jne >>.DL_DROPPED
				invoke LBItemFromPt,[edi+DRAGLISTINFO.hwnd],[edi+DRAGLISTINFO.ptCursor.x],\
					[edi+DRAGLISTINFO.ptCursor.y],FALSE
				or eax,eax
				jns >>D3
					; Check to see if the listbox needs scrolling
					invoke GetCursorPos,offset pt
					invoke GetWindowRect,[edi+DRAGLISTINFO.hwnd],offset rect
					mov eax,[pt.y]
					cmp eax,[rect.top]
					jg >D1
						invoke SendMessage,[edi+DRAGLISTINFO.hwnd],LB_GETTOPINDEX,0,0
						or eax,eax
						jz >D2
						dec eax
						invoke SendMessage,[edi+DRAGLISTINFO.hwnd],LB_SETTOPINDEX,eax,0
						jmp >D2
					D1:
					cmp eax,[rect.bottom]
					jl >D2
						invoke SendMessage,[edi+DRAGLISTINFO.hwnd],LB_GETTOPINDEX,0,0
						inc eax
						invoke SendMessage,[edi+DRAGLISTINFO.hwnd],LB_SETTOPINDEX,eax,0
					D2:
					invoke SetWindowLong,[hwnd],DWL_MSGRESULT, DL_STOPCURSOR
					mov eax,TRUE
					ret
				D3:
				invoke DrawInsert,[hwnd],[edi+DRAGLISTINFO.hwnd],eax
				invoke SetWindowLong,[hwnd],DWL_MSGRESULT,DL_MOVECURSOR
				mov eax,TRUE
				ret

			.DL_DROPPED
			cmp D[edi+DRAGLISTINFO.uNotification],DL_DROPPED
			jne >>.EXIT
				invoke GetWindowLong,[edi+DRAGLISTINFO.hwnd],GWL_USERDATA
				mov ebx,eax
				invoke SendMessage,[edi+DRAGLISTINFO.hwnd],LB_GETTEXT,ebx,offset buffer
				invoke SendMessage,[edi+DRAGLISTINFO.hwnd],LB_GETITEMDATA,ebx,0
				mov esi,eax
				invoke LBItemFromPt,[edi+DRAGLISTINFO.hwnd],[edi+DRAGLISTINFO.ptCursor.x],\
					[edi+DRAGLISTINFO.ptCursor.y],FALSE
				or eax,eax
				jns >
					ret
				:
				invoke SendMessage,[edi+DRAGLISTINFO.hwnd],LB_INSERTSTRING,eax,offset buffer
				push eax
				invoke SendMessage,[edi+DRAGLISTINFO.hwnd],LB_SETITEMDATA,eax,esi
				pop eax
				invoke SendMessage,[edi+DRAGLISTINFO.hwnd],LB_SETCURSEL,eax,0
				cmp ebx,eax
				jl >
					inc ebx
				:
				invoke SendMessage,[edi+DRAGLISTINFO.hwnd],LB_DELETESTRING,ebx,0
				invoke DrawInsert,[hwnd],[edi+DRAGLISTINFO.hwnd],-1				
				jmp >>.EXIT

	.WMCOMMAND
		cmp eax,WM_COMMAND
		jne >>.WMCONTEXTMENU
		movzx eax,W[wParam+2]
		cmp eax,LBN_SELCHANGE
		jne >C1
			invoke SendMessage,[lParam],LB_GETCURSEL,0,0
			mov ebx,eax
			invoke SendMessage,[lParam],LB_GETITEMDATA,ebx,0
			or eax,eax
			jz >>.EXIT
				push eax
				invoke GetDlgItem,[hwnd],2004
				pop ecx
				invoke GetRAPInfo,ecx,eax
				invoke SendMessage,[lParam],LB_GETTEXT,ebx,offset buffer
				invoke GetDlgItem,[hwnd],2006
				invoke SendMessage,eax,WM_SETTEXT,0,offset buffer
				jmp >>.EXIT
		C1:
		movzx eax,W[wParam]
		cmp eax,2002
		jne >C2
			invoke GetDlgItem,[hwnd],2001
			invoke RebuildFavsFile,eax
			invoke PostMessage,[hwnd],WM_CLOSE,0,0
			jmp >>.EXIT
		C2:
		cmp eax,2005
		jne >C3
			invoke PostMessage,[hwnd],WM_CLOSE,0,0
			jmp >>.EXIT
		C3:
		cmp eax,2008
		jne >>.EXIT
			invoke GetDlgItem,[hwnd],2001
			mov ebx,eax
			invoke GetDlgItem,[hwnd],2006
			invoke SendMessage,eax,WM_GETTEXT,64,offset buffer
			or eax,eax
			jz >>.EXIT
			invoke SendMessage,ebx,LB_GETCURSEL,0,0
			mov esi,eax
			or eax,eax
			js >>.EXIT
			invoke SendMessage,ebx,LB_GETITEMDATA,esi,0
			mov edi,eax
			or eax,eax
			jz >>.EXIT
			invoke SendMessage,ebx,LB_INSERTSTRING,esi,offset buffer
			push eax
			invoke SendMessage,ebx,LB_SETITEMDATA,eax,edi
			inc esi
			invoke SendMessage,ebx,LB_DELETESTRING,esi,0
			pop eax
			invoke SendMessage,ebx,LB_SETCURSEL,eax,0
			jmp >>.EXIT

	.WMCONTEXTMENU
		cmp eax,WM_CONTEXTMENU
		jne >>.WMCLOSE
		invoke GetCursorPos,offset pt
		invoke GetDlgItem,[hwnd],2001
		mov edi,eax
		invoke ScreenToClient,edi,offset pt
		mov ecx,[pt.y]
		shl ecx,16
		mov cx,[pt.x]
		invoke SendMessage,edi,LB_ITEMFROMPOINT,0,ecx
		mov esi,eax
		shr eax,16
		or eax,eax
		jnz >>.EXIT
		invoke SendMessage,edi,LB_SETCURSEL,esi,0
		invoke GetCursorPos,offset pt

		invoke SendMessage,edi,LB_GETITEMDATA,esi,0
		or eax,eax
		jz >
		push eax
		invoke GetDlgItem,[hwnd],2004
		pop ecx
		invoke GetRAPInfo,ecx,eax
		mov D[buffer],0
		invoke SendMessage,edi,LB_GETTEXT,esi,offset buffer
		invoke GetDlgItem,[hwnd],2006
		invoke SendMessage,eax,WM_SETTEXT,0,offset buffer
		:

		invoke CreatePopupMenu
		mov ebx,eax
		invoke AppendMenu,ebx,MF_ENABLED + MF_STRING,10000,"Delete"
		invoke TrackPopupMenuEx,ebx,TPM_RETURNCMD,[pt.x],[pt.y],[hwnd],NULL

		cmp eax,10000
		jne >
			invoke SendMessage,edi,LB_DELETESTRING,esi,0
		:
		invoke DestroyMenu,ebx
		jmp >.EXIT

	.WMCLOSE
		cmp eax,WM_CLOSE
		jne >.DEFPROC
		INVOKE EndDialog,[hwnd],0

	.DEFPROC
		mov EAX,FALSE
		RET

	.EXIT

	MOV EAX, TRUE
	RET
ENDF

GetRAPInfo FRAME pRAPFile,hOutput
	uses edi,esi,ebx
	LOCAL outstring[1024]		:%CHAR
	LOCAL hFile					:%HANDLE
	LOCAL lwt					:FILETIME
	LOCAL lwtLocal				:FILETIME
	LOCAL stLocal				:SYSTEMTIME

	LOCAL szFileTime[64]		:%CHAR
	LOCAL szTempDate[64]		:%CHAR
	LOCAL szTempTime[64]		:%CHAR

	LOCAL szAssembler[1024]		:%CHAR
	LOCAL szGroup[1024]			:%CHAR

	invoke CreateFile,[pRAPFile],GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,NULL,NULL
	mov [hFile],eax
	cmp eax,INVALID_HANDLE_VALUE
	je >>.EXIT

	invoke GetFileTime,eax,NULL,NULL,offset lwt
	invoke CloseHandle,[hFile]

	invoke FileTimeToLocalFileTime,offset lwt,offset lwtLocal
	invoke FileTimeToSystemTime,OFFSET lwtLocal,OFFSET stLocal

	invoke GetDateFormat,LOCALE_SYSTEM_DEFAULT,NULL,\
		OFFSET stLocal,"d MMM yyyy",OFFSET szTempDate,64
	invoke GetTimeFormat,LOCALE_SYSTEM_DEFAULT,NULL,\
		OFFSET stLocal,"hh:mm tt",OFFSET szTempTime,64

	invoke GetPrivateProfileString,"Project","Assembler","",\
			offset szAssembler,1024,[pRAPFile]

	invoke GetPrivateProfileString,"Project","Group","",\
		offset szGroup,1024,[pRAPFile]

	lea edi,szGroup
	mov al,","
	repne scasb
	repne scasb
	repne scasb
	repne scasb
	mov edx,edi
	repne scasb
	mov B[edi-1],0

	invoke wsprintf,offset outstring,offset outfmt,offset szAssembler,edx,OFFSET szTempDate,OFFSET szTempTime
	add esp,24

	invoke SendMessage,[hOutput],WM_SETTEXT,0,offset outstring

	RET

	.EXIT

	invoke SendMessage,[hOutput],WM_SETTEXT,0,"File not found"

	RET

	outfmt: CHAR "Assembler : %s",13,10,"Description : %s",13,10,13,10,"Last write :",13,10,"Date : %s",13,10,"Time : %s",0

ENDF

RebuildFavsFile FRAME hListBox
	uses ebx,esi,edi
	LOCAL szLabel[64]		:%CHAR
	LOCAL Index[16]			:%CHAR
	LOCAL OutString[324]	:%CHAR
	LOCAL cbWrite			:D
	LOCAL IniPath[MAX_PATH]	:%CHAR

	mov eax,[lpData]
	add eax,ADDINDATA.szAppPath
	invoke lstrcpy,offset IniPath,eax
	invoke lstrcat,offset IniPath,"\RadFavs.ini"

	mov D[Index],0
	invoke WritePrivateProfileSection,"Favourites",NULL,offset IniPath

	invoke SendMessage,[hListBox],LB_GETCOUNT,0,0
	mov ebx,eax
	or eax,eax
	jz >>.REMOVEALL
	xor esi,esi
	L1:
		invoke SendMessage,[hListBox],LB_GETTEXT,esi,offset szLabel
		invoke SendMessage,[hListBox],LB_GETITEMDATA,esi,0
		invoke wsprintf,offset OutString,"%s,%s",offset szLabel,eax
		add esp,16
		inc esi
		invoke wsprintf,offset Index,"%u",esi
		add esp,12
		invoke WritePrivateProfileString,"Favourites",offset Index,\
			offset OutString,offset IniPath
		cmp esi,ebx
		jl <L1

	.REMOVEALL

	invoke FreeMenuBuffers,[hFavMenu]

	; Delete the favourites in the menu, they start at index 3
	invoke GetMenuItemCount,[hFavMenu]
	mov esi,eax
	mov ebx,3
	L2:
		invoke RemoveMenu,[hFavMenu],3,MF_BYPOSITION
		inc ebx
		cmp ebx,esi
		jl <L2

	mov D[TopIDIndex],0
	invoke GetGlobalFavs,[hFavMenu]

	.EXIT
	RET
ENDF

SetMenuInfo	FRAME hMenu,lpcmi

	mov eax,[pSetMenuInfo]
	or eax,eax
	jz >.EXIT
		push [lpcmi]
		push [hMenu]
		call eax
	.EXIT

	ret
ENDF

GetMenuInfo	FRAME hMenu,lpcmi

	mov eax,[pGetMenuInfo]
	or eax,eax
	jz >.EXIT
		push [lpcmi]
		push [hMenu]
		call eax
	.EXIT

	ret
ENDF
