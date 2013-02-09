
;Find.dlg
IDD_DLGFIND						equ 3800
IDC_CBOFIND						equ 1002
IDC_BTNREPLACEALL				equ 1003
IDC_BTNREPLACE					equ 1004
IDC_STCREPLACE					equ 1007
IDC_EDTREPLACE					equ 1008
IDC_CHKMATCHCASE				equ 1009
IDC_CHKWHOLEWORD				equ 1010
IDC_CHKIGNOREWHITESPACE			equ 1011
IDC_CHKIGNORECOMMENTS			equ 1012
IDC_RBNDIRECTIONALL				equ 1014
IDC_RBNDIRECTIONUP				equ 1015
IDC_RBNDIRECTIONDOWN			equ 1016
IDC_RBNCURRENTSELECTION			equ 1018
IDC_RBNCURRENTPROCEDURE			equ 1019
IDC_RBNALLOPENFILES				equ 1020
IDC_RBNCURRENTMODULE			equ 1021
IDC_RBNALLPROJECTFILES			equ 1022

ID_DIRECTIONALL					equ 0
ID_DIRECTIONDOWN				equ 1
ID_DIRECTIONUP					equ 2

ID_CURRENTSELECTION				equ 0
ID_CURRENTPROCEDURE				equ 1
ID_CURRENTMODULE				equ 2
ID_ALLOPENFILES					equ 3
ID_ALLPROJECTFILES				equ 4

.data?

ntab			DWORD ?
findtabs		HWND 1024 dup(?)
szfind			BYTE 256 dup(?)
szreplace		BYTE 256 dup(?)

.code

FindInit proc uses ebx esi edi,hWin:HWND,fallfiles:DWORD
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM
	LOCAL	inp:ISINPROC
    LOCAL   hFile:HANDLE
	LOCAL	hMem:HGLOBAL
	LOCAL	dwRead:DWORD
	LOCAL	ms:MEMSEARCH

	invoke ConvertToFind,addr da.find.szfindbuff,addr szfind
	invoke ConvertToFind,addr da.find.szreplacebuff,addr szreplace
	invoke strlen,addr szfind
	push	eax
	invoke strlen,addr szreplace
	pop		edx
	sub		eax,edx
	mov		da.find.repdiff,eax
	mov		da.find.fres,-1
	mov		da.find.fproc,FALSE
	.if fallfiles!=-1
		mov		da.find.nfound,0
		mov		da.find.nreplace,0
	.endif
	invoke SendMessage,hWin,EM_EXGETSEL,0,offset da.find.initchrg
	invoke SendMessage,hWin,EM_EXGETSEL,0,offset da.find.ft.chrgText
	mov		edx,da.find.initchrg.cpMax
	sub		edx,da.find.initchrg.cpMin
	mov		eax,da.find.fscope
	.if eax==ID_CURRENTSELECTION && edx!=0
		;Current selection
		mov		edx,da.find.initchrg.cpMin
		mov		da.find.scopechrg.cpMin,edx
		mov		eax,da.find.initchrg.cpMax
		dec		eax
		mov		da.find.scopechrg.cpMax,eax
		mov		da.find.initchrg.cpMax,edx
		mov		da.find.ft.chrgText.cpMax,edx
	.elseif eax==ID_CURRENTPROCEDURE
		;Current procedure
		invoke SendMessage,ha.hEdt,EM_EXLINEFROMCHAR,0,da.find.initchrg.cpMin
		mov		inp.nLine,eax
		invoke GetWindowLong,ha.hEdt,GWL_USERDATA
		mov		eax,[eax].TABMEM.pid
		.if !eax
			mov		eax,ha.hMdi
		.endif
		mov		inp.nOwner,eax
		mov		inp.lpszType,offset szCCp
		invoke SendMessage,ha.hProperty,PRM_ISINPROC,0,addr inp
		.if eax
			invoke PropertyFindExact,addr szCCp,eax,TRUE
			.if eax
				mov		da.find.fproc,TRUE
				invoke SendMessage,ha.hProperty,PRM_FINDGETLINE,0,0
				invoke SendMessage,ha.hEdt,EM_LINEINDEX,eax,0
				mov		da.find.scopechrg.cpMin,eax
				invoke SendMessage,ha.hProperty,PRM_FINDGETENDLINE,0,0
				inc		eax
				invoke SendMessage,ha.hEdt,EM_LINEINDEX,eax,0
				dec		eax
				mov		da.find.scopechrg.cpMax,eax
			.else
				mov		da.find.scopechrg.cpMin,0
				mov		da.find.scopechrg.cpMax,-1
			.endif
		.else
			mov		da.find.scopechrg.cpMin,0
			mov		da.find.scopechrg.cpMax,-1
		.endif
	.elseif eax==ID_CURRENTMODULE || eax==ID_CURRENTSELECTION
		;Current module
		mov		da.find.scopechrg.cpMin,0
		mov		da.find.scopechrg.cpMax,-1
	.elseif eax==ID_ALLOPENFILES || (eax==ID_ALLPROJECTFILES && !da.fProject)
		;All open file
		mov		da.find.scopechrg.cpMin,0
		mov		da.find.scopechrg.cpMax,-1
	.elseif eax==ID_ALLPROJECTFILES && da.fProject
		;All project files
		mov		da.find.scopechrg.cpMin,0
		mov		da.find.scopechrg.cpMax,-1
	.endif
	mov		eax,da.find.fdir
	.if eax==ID_DIRECTIONALL
		;All
		mov		eax,da.find.scopechrg.cpMax
		mov		da.find.ft.chrg.cpMax,eax
	.elseif eax==ID_DIRECTIONDOWN
		;Down
		mov		eax,da.find.scopechrg.cpMax
		mov		da.find.ft.chrg.cpMax,eax
	.elseif eax==ID_DIRECTIONUP
		;Up
		mov		eax,da.find.scopechrg.cpMin
		mov		da.find.ft.chrg.cpMax,eax
	.endif
	.if fallfiles==ID_ALLOPENFILES
		;All open files
		invoke SendMessage,ha.hTab,TCM_GETCURSEL,0,0
		mov		esi,eax
		mov		nInx,eax
		mov		tci.imask,TCIF_PARAM
		mov		edi,offset findtabs
		.while TRUE
			invoke SendMessage,ha.hTab,TCM_GETITEM,esi,addr tci
			.break .if !eax
			call	AddCodeFile
			inc		esi
		.endw
		xor		esi,esi
		.while esi<nInx
			invoke SendMessage,ha.hTab,TCM_GETITEM,esi,addr tci
			.break .if !eax
			call	AddCodeFile
			inc		esi
		.endw
		xor		eax,eax
		mov		dword ptr [edi],eax
		mov		ntab,eax
	.elseif fallfiles==ID_ALLPROJECTFILES
		invoke SendMessage,ha.hTab,TCM_GETCURSEL,0,0
		mov		esi,eax
		mov		nInx,eax
		mov		tci.imask,TCIF_PARAM
		mov		edi,offset findtabs
		.while TRUE
			invoke SendMessage,ha.hTab,TCM_GETITEM,esi,addr tci
			.break .if !eax
			mov		eax,tci.lParam
			.if [eax].TABMEM.pid
				call	AddCodeFile
			.endif
			inc		esi
		.endw
		xor		esi,esi
		.while esi<nInx
			invoke SendMessage,ha.hTab,TCM_GETITEM,esi,addr tci
			.break .if !eax
			mov		eax,tci.lParam
			.if [eax].TABMEM.pid
				call	AddCodeFile
			.endif
			inc		esi
		.endw
		xor		ebx,ebx
		.while TRUE
			invoke SendMessage,ha.hProjectBrowser,RPBM_FINDNEXTITEM,ebx,0
			.break .if !eax
			mov		esi,eax
			mov		ebx,[esi].PBITEM.id
			.if [esi].PBITEM.lParam==ID_EDITCODE || [esi].PBITEM.lParam==ID_EDITTEXT
				invoke UpdateAll,UAM_ISOPEN,addr [esi].PBITEM.szitem
				.if eax==-1
					;Open the file
					invoke CreateFile,addr [esi].PBITEM.szitem,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
					.if eax!=INVALID_HANDLE_VALUE
						mov		hFile,eax
						invoke GetFileSize,hFile,NULL
						push	eax
						inc		eax
						invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
						mov     hMem,eax
						pop		edx
						invoke ReadFile,hFile,hMem,edx,addr dwRead,NULL
						invoke CloseHandle,hFile
						mov		eax,hMem
						mov		ms.lpMem,eax
						mov		ms.lpFind,offset da.find.szfindbuff
						mov		eax,da.lpCharTab
						mov		ms.lpCharTab,eax
						mov		eax,da.find.fr
						and		eax,FR_WHOLEWORD or FR_MATCHCASE
						or		eax,FR_DOWN
						mov		ms.fr,eax
						invoke SendMessage,ha.hProperty,PRM_MEMSEARCH,0,addr ms
						.if eax
							mov		[edi],ebx
							lea		edi,[edi+4]
						.endif
						invoke GlobalFree,hMem
					.endif
				.endif
			.endif
		.endw
		xor		eax,eax
		mov		dword ptr [edi],eax
		mov		ntab,eax
	.endif
	ret

AddCodeFile:
	mov		ebx,tci.lParam
	invoke GetTheFileType,addr [ebx].TABMEM.filename
	.if eax==ID_EDITCODE || eax==ID_EDITTEXT
		mov		eax,[ebx].TABMEM.hedt
		mov		[edi],eax
		lea		edi,[edi+4]
	.endif
	retn

FindInit endp

DoFind proc hWin:HWND,frType:DWORD
	LOCAL	inp:ISINPROC

FindNext:
	;Do the find
	mov		eax,da.find.fdir
	.if eax==ID_DIRECTIONALL
		;All
		mov		eax,da.find.ft.chrgText.cpMax
		mov		da.find.ft.chrg.cpMin,eax
	.elseif eax==ID_DIRECTIONDOWN
		;Down
		mov		eax,da.find.ft.chrgText.cpMax
		mov		da.find.ft.chrg.cpMin,eax
	.elseif eax==ID_DIRECTIONUP
		;Up
		mov		eax,da.find.ft.chrgText.cpMin
		dec		eax
		mov		da.find.ft.chrg.cpMin,eax
	.endif
	invoke SendMessage,hWin,EM_FINDTEXTEX,da.find.fr,offset da.find.ft
	mov		da.find.fres,eax
	.if da.find.fres==-1
		.if da.find.fdir==ID_DIRECTIONALL && da.find.initchrg.cpMin
			mov		eax,da.find.scopechrg.cpMax
			.if eax==da.find.ft.chrg.cpMax
				mov		eax,da.find.scopechrg.cpMin
				mov		da.find.ft.chrgText.cpMax,eax
				mov		eax,da.find.initchrg.cpMin
				.if eax==da.find.initchrg.cpMax
					dec		eax
				.endif
				mov		da.find.ft.chrg.cpMax,eax
				jmp		FindNext
			.endif
		.endif
		.if da.find.fscope==ID_ALLOPENFILES
			inc		ntab
			mov		eax,ntab
			lea		edx,[offset findtabs+eax*4]
			mov		eax,[edx]
			.if eax
				mov		hWin,eax
				invoke FindInit,hWin,-1
				jmp		FindNext
			.endif
		.elseif da.find.fscope==ID_ALLPROJECTFILES
			inc		ntab
			mov		eax,ntab
			lea		edx,[offset findtabs+eax*4]
			mov		eax,[edx]
			.if eax>1024
				mov		hWin,eax
				invoke FindInit,hWin,-1
				jmp		FindNext
			.else
				invoke SendMessage,ha.hProjectBrowser,RPBM_FINDITEM,eax,0
				.if eax
					mov		da.inprogress,TRUE
					invoke OpenTheFile,addr [eax].PBITEM.szitem,[eax].PBITEM.lParam
					invoke SetFocus,ha.hFind
					mov		da.inprogress,FALSE
					mov		eax,ha.hEdt
					mov		hWin,eax
					invoke FindInit,hWin,-1
					jmp		FindNext
				.endif
			.endif
		.endif
		;Region searched
		invoke GetDlgItem,ha.hFind,IDC_BTNREPLACEALL
		invoke IsWindowVisible,eax
		.if eax
			invoke wsprintf,addr tmpbuff,addr szReplaceDone,da.find.nreplace
			invoke MessageBox,ha.hFind,addr tmpbuff,addr DisplayName,MB_OK or MB_ICONINFORMATION
		.else
			invoke MessageBox,ha.hFind,addr szRegionSearched,addr DisplayName,MB_OK or MB_ICONINFORMATION
		.endif
	.else
		test	da.find.fr,FR_IGNORECOMMENTS
		.if !ZERO?
			invoke SendMessage,hWin,REM_ISCHARPOS,da.find.ft.chrgText.cpMin,0
			.if eax
				jmp		FindNext
			.endif
		.endif
		.if da.find.fscope==ID_CURRENTPROCEDURE && da.find.fproc==FALSE
			invoke SendMessage,ha.hEdt,EM_EXLINEFROMCHAR,0,da.find.ft.chrgText.cpMin
			mov		inp.nLine,eax
			invoke GetWindowLong,ha.hEdt,GWL_USERDATA
			mov		eax,[eax].TABMEM.pid
			.if !eax
				mov		eax,ha.hMdi
			.endif
			mov		inp.nOwner,eax
			mov		inp.lpszType,offset szCCp
			invoke SendMessage,ha.hProperty,PRM_ISINPROC,0,addr inp
			.if eax
				jmp		FindNext
			.endif
		.elseif da.find.fscope==ID_CURRENTSELECTION
			invoke CheckDlgButton,ha.hFind,IDC_RBNCURRENTSELECTION,BST_UNCHECKED
			invoke GetDlgItem,ha.hFind,IDC_RBNCURRENTSELECTION
			invoke EnableWindow,eax,FALSE
			invoke CheckDlgButton,ha.hFind,IDC_RBNCURRENTMODULE,BST_CHECKED
			mov		da.find.fscope,ID_CURRENTMODULE
		.endif
		mov		eax,hWin
		.if eax!=ha.hEdt
			mov		da.inprogress,TRUE
			invoke GetParent,hWin
			invoke TabToolGetInx,eax
			invoke SendMessage,ha.hTab,TCM_SETCURSEL,eax,0
			invoke TabToolActivate
			invoke SetFocus,ha.hFind
			mov		da.inprogress,FALSE
		.endif
		;Mark the found text
		invoke SendMessage,hWin,EM_EXSETSEL,0,offset da.find.ft.chrgText
		invoke SendMessage,hWin,REM_VCENTER,0,0
		invoke SendMessage,hWin,EM_SCROLLCARET,0,0
		inc		da.find.nfound
	.endif
	ret

DoFind endp

FindDialogProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	chrg:CHARRANGE
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		esi,offset da.find.szfindhistory
		.while byte ptr [esi]
			invoke SendDlgItemMessage,hWin,IDC_CBOFIND,CB_ADDSTRING,0,esi
			lea		esi,[esi+256]
		.endw
		.if lParam
			call	ShowReplace
		.endif
		;Put text in edit boxes
		mov		chrg.cpMin,0
		mov		chrg.cpMax,0
		.if ha.hMdi
			invoke GetWindowLong,ha.hEdt,GWL_ID
			.if eax==ID_EDITCODE || eax==ID_EDITTEXT
				invoke SendMessage,ha.hEdt,EM_EXGETSEL,0,addr chrg
				invoke SendMessage,ha.hEdt,REM_GETWORD,sizeof da.find.szfindbuff,addr da.find.szfindbuff
				.if !da.find.szfindbuff
					invoke SendDlgItemMessage,hWin,IDC_CBOFIND,CB_GETLBTEXT,0,addr da.find.szfindbuff
				.endif
			.endif
		.endif
		invoke SendDlgItemMessage,hWin,IDC_CBOFIND,EM_LIMITTEXT,255,0
		invoke SendDlgItemMessage,hWin,IDC_CBOFIND,WM_SETTEXT,0,offset da.find.szfindbuff
		invoke SendDlgItemMessage,hWin,IDC_EDTREPLACE,EM_LIMITTEXT,255,0
		invoke SendDlgItemMessage,hWin,IDC_EDTREPLACE,WM_SETTEXT,0,offset da.find.szreplacebuff
		;Set check boxes
		test	da.find.fr,FR_MATCHCASE
		.if !ZERO?
			invoke CheckDlgButton,hWin,IDC_CHKMATCHCASE,BST_CHECKED
		.endif
		test	da.find.fr,FR_WHOLEWORD
		.if !ZERO?
			invoke CheckDlgButton,hWin,IDC_CHKWHOLEWORD,BST_CHECKED
		.endif
		test	da.find.fr,FR_IGNOREWHITESPACE
		.if !ZERO?
			invoke CheckDlgButton,hWin,IDC_CHKIGNOREWHITESPACE,BST_CHECKED
		.endif
		test	da.find.fr,FR_IGNORECOMMENTS
		.if !ZERO?
			invoke CheckDlgButton,hWin,IDC_CHKIGNORECOMMENTS,BST_CHECKED
		.endif
		;Set find direction
		mov		eax,da.find.fdir
		.if eax==ID_DIRECTIONALL
			or		da.find.fr,FR_DOWN
			mov		eax,IDC_RBNDIRECTIONALL
		.elseif eax==ID_DIRECTIONDOWN
			or		da.find.fr,FR_DOWN
			mov		eax,IDC_RBNDIRECTIONDOWN
		.elseif eax==ID_DIRECTIONUP
			and		da.find.fr,-1 xor FR_DOWN
			mov		eax,IDC_RBNDIRECTIONUP
		.endif
		invoke CheckDlgButton,hWin,eax,BST_CHECKED
		;Set search
		invoke GetDlgItem,hWin,IDC_RBNALLPROJECTFILES
		invoke EnableWindow,eax,da.fProject
		mov		edx,chrg.cpMax
		sub		edx,chrg.cpMin
		.if !edx
			invoke GetDlgItem,hWin,IDC_RBNCURRENTSELECTION
			invoke EnableWindow,eax,FALSE
			xor		edx,edx
		.else
			mov		da.find.fscope,ID_CURRENTSELECTION
		.endif
		mov		eax,da.find.fscope
		.if eax==ID_CURRENTSELECTION && edx!=0
			;Current selection
			mov		da.find.fscope,ID_CURRENTSELECTION
			mov		eax,IDC_RBNCURRENTSELECTION
		.elseif eax==ID_CURRENTPROCEDURE
			;Current procedure
			mov		da.find.fscope,ID_CURRENTPROCEDURE
			mov		eax,IDC_RBNCURRENTPROCEDURE
		.elseif eax==ID_CURRENTMODULE || eax==ID_CURRENTSELECTION
			;Current module
			mov		da.find.fscope,ID_CURRENTMODULE
			mov		eax,IDC_RBNCURRENTMODULE
		.elseif eax==ID_ALLOPENFILES || (eax==ID_ALLPROJECTFILES && !da.fProject)
			;All open file
			mov		da.find.fscope,ID_ALLOPENFILES
			mov		eax,IDC_RBNALLOPENFILES
		.elseif eax==ID_ALLPROJECTFILES && da.fProject
			;All project files
			mov		da.find.fscope,ID_ALLPROJECTFILES
			mov		eax,IDC_RBNALLPROJECTFILES
		.endif
		invoke CheckDlgButton,hWin,eax,BST_CHECKED
		invoke SetWindowPos,hWin,0,da.win.ptfind.x,da.win.ptfind.y,0,0,SWP_NOSIZE or SWP_NOZORDER
		mov		da.find.ft.lpstrText,offset szfind;da.find.szfindbuff
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				;Do find
				invoke DoFind,ha.hEdt,da.find.fr
				call	UpdateFindHistory
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNREPLACE
				;Replace
				invoke GetDlgItem,hWin,IDC_BTNREPLACEALL
				invoke IsWindowVisible,eax
				.if !eax
					;Set replace mode
					call	ShowReplace
				.else
					;Do replace
					call	UpdateFindHistory
					.if da.find.fres!=-1
						invoke SendMessage,ha.hEdt,EM_REPLACESEL,TRUE,addr da.find.szreplacebuff
						inc		da.find.nreplace
						mov		eax,da.find.repdiff
						add		da.find.ft.chrgText.cpMax,eax
						invoke SendMessage,ha.hEdt,EM_EXSETSEL,0,addr da.find.ft.chrgText
						.if da.find.ft.chrg.cpMax!=-1
							mov		eax,da.find.repdiff
							add		da.find.ft.chrg.cpMax,eax
						.endif
					.endif
					invoke DoFind,ha.hEdt,da.find.fr
				.endif
			.elseif eax==IDC_BTNREPLACEALL
				;Replace all
				.if da.find.fres==-1
					invoke DoFind,ha.hEdt,da.find.fr
				.endif
				.while da.find.fres!=-1
					invoke SendMessage,hWin,WM_COMMAND,(BN_CLICKED shl 16) or IDC_BTNREPLACE,0
				.endw
			.elseif eax==IDC_RBNDIRECTIONALL
				;Set find direction to down
				or		da.find.fr,FR_DOWN
				mov		da.find.fdir,ID_DIRECTIONALL
				invoke FindInit,ha.hEdt,da.find.fscope
			.elseif eax==IDC_RBNDIRECTIONDOWN
				;Set find direction to down
				or		da.find.fr,FR_DOWN
				mov		da.find.fdir,ID_DIRECTIONDOWN
				invoke FindInit,ha.hEdt,da.find.fscope
			.elseif eax==IDC_RBNDIRECTIONUP
				;Set find direction to up
				and		da.find.fr,-1 xor FR_DOWN
				mov		da.find.fdir,ID_DIRECTIONUP
				invoke FindInit,ha.hEdt,da.find.fscope
			.elseif eax==IDC_CHKMATCHCASE
				;Set match case mode
				invoke IsDlgButtonChecked,hWin,IDC_CHKMATCHCASE
				.if eax
					or		da.find.fr,FR_MATCHCASE
				.else
					and		da.find.fr,-1 xor FR_MATCHCASE
				.endif
				invoke FindInit,ha.hEdt,da.find.fscope
			.elseif eax==IDC_CHKWHOLEWORD
				;Set whole word mode
				invoke IsDlgButtonChecked,hWin,IDC_CHKWHOLEWORD
				.if eax
					or		da.find.fr,FR_WHOLEWORD
				.else
					and		da.find.fr,-1 xor FR_WHOLEWORD
				.endif
				invoke FindInit,ha.hEdt,da.find.fscope
			.elseif eax==IDC_CHKIGNOREWHITESPACE
				;Set ignore whitespace word mode
				invoke IsDlgButtonChecked,hWin,IDC_CHKIGNOREWHITESPACE
				.if eax
					or		da.find.fr,FR_IGNOREWHITESPACE
				.else
					and		da.find.fr,-1 xor FR_IGNOREWHITESPACE
				.endif
				invoke FindInit,ha.hEdt,da.find.fscope
			.elseif eax==IDC_CHKIGNORECOMMENTS
				;Set ignore comments word mode
				invoke IsDlgButtonChecked,hWin,IDC_CHKIGNORECOMMENTS
				.if eax
					or		da.find.fr,FR_IGNORECOMMENTS
				.else
					and		da.find.fr,-1 xor FR_IGNORECOMMENTS
				.endif
				invoke FindInit,ha.hEdt,da.find.fscope
			.elseif eax==IDC_RBNCURRENTSELECTION
				;Current selection
				mov		da.find.fscope,ID_CURRENTSELECTION
				invoke FindInit,ha.hEdt,da.find.fscope
			.elseif eax==IDC_RBNCURRENTPROCEDURE
				;Current procedure
				mov		da.find.fscope,ID_CURRENTPROCEDURE
				invoke FindInit,ha.hEdt,da.find.fscope
			.elseif eax==IDC_RBNCURRENTMODULE
				;Current module
				mov		da.find.fscope,ID_CURRENTMODULE
				invoke FindInit,ha.hEdt,da.find.fscope
			.elseif eax==IDC_RBNALLOPENFILES
				;All open files
				mov		da.find.fscope,ID_ALLOPENFILES
				invoke FindInit,ha.hEdt,da.find.fscope
			.elseif eax==IDC_RBNALLPROJECTFILES
				;All project files
				mov		da.find.fscope,ID_ALLPROJECTFILES
				invoke FindInit,ha.hEdt,da.find.fscope
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTREPLACE
				invoke GetDlgItemText,hWin,IDC_EDTREPLACE,addr da.find.szreplacebuff,sizeof da.find.szreplacebuff
				invoke FindInit,ha.hEdt,da.find.fscope
			.endif
		.elseif edx==CBN_EDITCHANGE
			.if eax==IDC_CBOFIND
				invoke GetDlgItemText,hWin,IDC_CBOFIND,addr da.find.szfindbuff,sizeof da.find.szfindbuff
				invoke FindInit,ha.hEdt,da.find.fscope
			.endif
		.elseif edx==CBN_SELCHANGE
			.if eax==IDC_CBOFIND
				invoke SendDlgItemMessage,hWin,IDC_CBOFIND,CB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_CBOFIND,CB_GETLBTEXT,eax,addr da.find.szfindbuff
				invoke FindInit,ha.hEdt,da.find.fscope
			.endif
		.endif
	.elseif eax==WM_ACTIVATE
		mov		eax,wParam
		movzx	eax,ax
		.if eax==WA_INACTIVE
			mov		ha.hModeless,0
		.else
			mov		eax,hWin
			mov		ha.hModeless,eax
			mov		ha.hFind,eax
			.if !da.inprogress
				invoke FindInit,ha.hEdt,da.find.fscope
			.endif
		.endif
	.elseif eax==WM_CLOSE
		;Save the position
		mov		esi,offset da.find.szfindhistory
		invoke RtlZeroMemory,esi,sizeof da.find.szfindhistory
		xor		ebx,ebx
		.while ebx<10
			invoke SendDlgItemMessage,hWin,IDC_CBOFIND,CB_GETLBTEXT,ebx,esi
			.break .if eax==CB_ERR
			lea		esi,[esi+256]
			inc		ebx
		.endw
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.left
		mov		da.win.ptfind.x,eax
		mov		eax,rect.top
		mov		da.win.ptfind.y,eax
		invoke SetFocus,ha.hEdt
		invoke DestroyWindow,hWin
		mov		ha.hFind,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

UpdateFindHistory:
	.if da.find.szfindbuff
		invoke SendDlgItemMessage,hWin,IDC_CBOFIND,CB_FINDSTRINGEXACT,-1,addr da.find.szfindbuff
		.if eax==LB_ERR
			invoke SendDlgItemMessage,hWin,IDC_CBOFIND,CB_INSERTSTRING,0,addr da.find.szfindbuff
		.endif
	.endif
	retn

ShowReplace:
	invoke GetDlgItem,hWin,IDC_STCREPLACE
	invoke ShowWindow,eax,SW_SHOWNA
	invoke GetDlgItem,hWin,IDC_EDTREPLACE
	invoke ShowWindow,eax,SW_SHOWNA
	invoke GetDlgItem,hWin,IDC_BTNREPLACEALL
	invoke ShowWindow,eax,SW_SHOWNA
	invoke SetWindowText,hWin,addr szReplace
	retn

FindDialogProc endp

