
;NewProject.dlg
IDD_DLGNEWPROJECT				equ 1000
IDC_EDTNAME						equ 1001
IDC_CHKSUB						equ 1002
IDC_CHKBAK						equ 1003
IDC_CHKMOD						equ 1004
IDC_CHKINC						equ 1005
IDC_CHKRES						equ 1006
IDC_EDTPATH						equ 1007
IDC_BTNPATH						equ 1008
IDC_TAB1						equ 1009

;NewProject1.dlg
IDD_DLGTAB1						equ 1100
IDC_CBOBUILD					equ 1001
IDC_CHKASM						equ 1002
IDC_CHKRC						equ 1003
IDC_CHKTXT						equ 1004
IDC_CHKINC						equ 1005
IDC_CHKMES						equ 1006

;NewProject2.dlg
IDD_DLGTAB2						equ 1200
IDC_LSTTEMPLATE					equ 1001
IDC_STCTEMPLATE					equ 1002

.code

BrowseFolder proc hWin:HWND,nID:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		bri.pidlRoot,0
	mov		bri.pszDisplayName,0
;	mov		eax,offset szBrowse
	xor		eax,eax
	mov		bri.lpszTitle,eax
	mov		bri.ulFlags,BIF_RETURNONLYFSDIRS or BIF_STATUSTEXT 
	mov		bri.lpfn,BrowseCallbackProc
	; get path   
	invoke SendDlgItemMessage,hWin,nID,WM_GETTEXT,sizeof buffer,addr buffer
	lea		eax,buffer
	mov		bri.lParam,eax 
	mov		bri.iImage,0
	invoke SHBrowseForFolder,offset bri
	.if !eax
		jmp		GetOut
	.endif      
	mov		pidl,eax
	invoke SHGetPathFromIDList,pidl,addr buffer
	; set new path back to edit
	invoke SendDlgItemMessage,hWin,nID,WM_SETTEXT,0,addr buffer
  GetOut:
	ret

BrowseFolder endp

;--------------------------------------------------------------------------------
; set initial folder in browser
BrowseCallbackProc proc hwnd:DWORD,uMsg:UINT,lParam:LPARAM,lpBCData:DWORD

	mov eax,uMsg
	.if eax==BFFM_INITIALIZED
		invoke PostMessage,hwnd,BFFM_SETSELECTION,TRUE,lpBCData
		invoke PostMessage,hwnd,BFFM_SETSTATUSTEXT,0,addr szBrowse
	.endif
	xor eax, eax
	ret

BrowseCallbackProc endp

Tab1Proc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		ebx,lpHandles
		mov		ebx,[ebx].ADDINHANDLES.hCbo
		xor		esi,esi
		.while TRUE
			invoke SendMessage,ebx,CB_GETLBTEXT,esi,addr buffer
			.break .if eax==LB_ERR
			invoke SendDlgItemMessage,hWin,IDC_CBOBUILD,CB_ADDSTRING,0,addr buffer
			inc		esi
		.endw
		invoke SendDlgItemMessage,hWin,IDC_CBOBUILD,CB_SETCURSEL,0,0
		invoke CheckDlgButton,hWin,IDC_CHKMES,BST_CHECKED
		invoke CheckDlgButton,hWin,IDC_CHKASM,BST_CHECKED
		invoke CheckDlgButton,hWin,IDC_CHKINC,BST_CHECKED
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Tab1Proc endp

Tab2Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hwfd:HANDLE
	LOCAL	nInx:DWORD
	LOCAL	hFile:HANDLE
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_LSTTEMPLATE,LB_ADDSTRING,0,offset szNone
		invoke lstrcpy,addr buffer,offset TemplatePath
		invoke lstrcat,addr buffer,offset szTpl
		invoke FindFirstFile,addr buffer,addr wfd
		mov		hwfd,eax
		.if eax!=INVALID_HANDLE_VALUE
			mov		hwfd,eax
			.while TRUE
				invoke SendDlgItemMessage,hWin,IDC_LSTTEMPLATE,LB_ADDSTRING,0,addr wfd.cFileName
				invoke FindNextFile,hwfd,addr wfd
				.break .if !eax
			.endw
			invoke FindClose,hwfd
		.endif
		invoke SendDlgItemMessage,hWin,IDC_LSTTEMPLATE,LB_SETCURSEL,0,0
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==LBN_SELCHANGE
			mov		buffer,0
			invoke SendDlgItemMessage,hWin,IDC_LSTTEMPLATE,LB_GETCURSEL,0,0
			.if sdword ptr eax>0
				push	eax
				invoke lstrcpy,addr buffer,offset TemplatePath
				invoke lstrcat,addr buffer,offset szBS
				invoke lstrlen,addr buffer
				pop		edx
				invoke SendDlgItemMessage,hWin,IDC_LSTTEMPLATE,LB_GETTEXT,edx,addr buffer[eax]
				invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
				.if eax!=INVALID_HANDLE_VALUE
					mov		hFile,eax
					invoke RtlZeroMemory,addr buffer,sizeof buffer
					invoke ReadFile,hFile,addr buffer,sizeof buffer-1,addr nInx,NULL
					xor		eax,eax
					.while eax<sizeof buffer
						.if buffer[eax]==0Dh
							mov		buffer[eax],0
							.break
						.endif
						inc		eax
					.endw
					invoke CloseHandle,hFile
				.endif
			.endif
			invoke SetDlgItemText,hWin,IDC_STCTEMPLATE,addr buffer
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Tab2Proc endp

FolderCreate proc hWin:HWND,lpPath:DWORD,lpFolder:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke lstrcpy,addr buffer,lpPath
	invoke lstrcat,addr buffer,offset szBS
	invoke lstrcat,addr buffer,lpFolder
	invoke CreateDirectory,addr buffer,NULL
	.if !eax
		invoke lstrcpy,offset tempbuff,offset szErrDir
		invoke lstrcat,offset tempbuff,addr buffer
		invoke MessageBox,hWin,offset tempbuff,offset szMenuItem,MB_OK or MB_ICONERROR
		xor		eax,eax
	.else
		invoke lstrcpy,offset tempbuff,addr buffer
		mov		eax,offset tempbuff
	.endif
	ret

FolderCreate endp

FileFolderCreate proc uses ebx esi,lpFile:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke lstrcpy,addr buffer,lpFile
	lea		esi,buffer
	xor		ebx,ebx
	xor		ecx,ecx
	.while byte ptr [esi+ecx]
		.if byte ptr [esi+ecx]=='\'
			mov		byte ptr [esi+ecx],0
			inc		ebx
		.endif
		inc		ecx
	.endw
	.while ebx
		invoke CreateDirectory,esi,NULL
		xor		ecx,ecx
		.while byte ptr [esi+ecx]
			inc		ecx
		.endw
		mov		byte ptr [esi+ecx],'\'
		dec		ebx
	.endw
	ret

FileFolderCreate endp

FileCreate proc hWin:HWND,lpPath:DWORD,lpFile:DWORD,lpExt:DWORD,lpFileData:DWORD,nFileSize:DWORD,nFileType:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hFile:HANDLE
	LOCAL	bytes:DWORD

	invoke lstrcpy,addr buffer,lpPath
	invoke lstrcat,addr buffer,offset szBS
	invoke lstrcat,addr buffer,lpFile
	invoke lstrcat,addr buffer,offset szDot
	invoke lstrcat,addr buffer,lpExt
	; Check if file exists
	invoke GetFileAttributes,addr buffer
	.if eax!=-1
		; File exists
		invoke lstrcpy,offset tempbuff,offset szErrOverwrite
		invoke lstrcat,offset tempbuff,addr buffer
		invoke MessageBox,hWin,offset tempbuff,offset szMenuItem,MB_YESNO or MB_ICONERROR
		.if eax==IDNO
			xor		eax,eax
			ret
		.endif
	.endif
	invoke FileFolderCreate,addr buffer
	invoke CreateFile,addr buffer,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax==INVALID_HANDLE_VALUE
		; File could not be created
		invoke lstrcpy,offset tempbuff,offset szErrCreate
		invoke lstrcat,offset tempbuff,addr buffer
		invoke MessageBox,hWin,offset tempbuff,offset szMenuItem,MB_YESNO or MB_ICONERROR
		xor		eax,eax
		ret
	.endif
	mov		hFile,eax
	.if lpFileData
		; Write file data
		invoke WriteFile,hFile,lpFileData,nFileSize,addr bytes,NULL
	.endif
	invoke CloseHandle,hFile
	mov		edx,lpHandles
	invoke SendMessage,[edx].ADDINHANDLES.hBrowse,FBM_SETPATH,TRUE,lpPath
	.if nFileType==1
		; Main file
		mov		edx,lpData
		invoke lstrcpy,addr [edx].ADDINDATA.MainFile,addr buffer
		; Open the file
		push	0
		lea		eax,buffer
		push	eax
		mov		eax,lpProc
		call	[eax].ADDINPROCS.lpOpenEditFile
	.elseif nFileType==2
		; Session file
		mov		edx,lpData
		invoke lstrcpy,addr [edx].ADDINDATA.szSessionFile,addr buffer
	.else
		push	0
		lea		eax,buffer
		push	eax
		mov		eax,lpProc
		call	[eax].ADDINPROCS.lpOpenEditFile
	.endif
	mov		eax,TRUE
	ret

FileCreate endp

IsLine proc uses ebx esi edi,lpLine:DWORD,lpWord:DWORD,fIgnore:DWORD

	mov		esi,lpWord
	mov		edi,lpLine
	mov		ebx,TRUE
	.while byte ptr [esi]
		mov		al,[esi]
		mov		ah,[edi]
		.if fIgnore
			.if al>='a' && al<='z'
				and		al,5Fh
			.endif
			.if ah>='a' && ah<='z'
				and		ah,5Fh
			.endif
		.endif
		.if al!=ah
			xor		eax,eax
			jmp		Ex
		.endif
		inc		esi
		inc		edi
	.endw
	mov		eax,edi
	sub		eax,lpLine
  Ex:
	ret

IsLine endp

TemplateCreate proc uses ebx esi edi,hWin:HWND,nTemplate:DWORD,lpPath:DWORD,lpFile:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hFile:HANDLE
	LOCAL	bytes:DWORD
	LOCAL	hTemplateMem:HGLOBAL
	LOCAL	hOutMem:HGLOBAL
	LOCAL	nFun:DWORD
	LOCAL	nBuild:DWORD
	LOCAL	filename[MAX_PATH]:BYTE
	LOCAL	fileext[MAX_PATH]:BYTE
	LOCAL	nFiles:DWORD

	invoke SendDlgItemMessage,hDlg2,IDC_LSTTEMPLATE,LB_GETTEXT,nTemplate,addr buffer
	mov		eax,lpData
	invoke lstrcpy,offset tempbuff,addr [eax].ADDINDATA.AppPath
	invoke lstrcat,offset tempbuff,offset szTemplatesPath
	invoke lstrcat,offset tempbuff,offset szBS
	invoke lstrcat,offset tempbuff,addr buffer
	invoke lstrcpy,addr buffer,offset tempbuff
	invoke GetFileAttributes,addr buffer
	.if eax!=INVALID_HANDLE_VALUE
		invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke GetFileSize,hFile,NULL
			mov		ebx,eax
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,addr [ebx+1]
			mov		hTemplateMem,eax
			invoke ReadFile,hFile,hTemplateMem,ebx,addr bytes,NULL
			invoke CloseHandle,hFile
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*1024
			mov		hOutMem,eax
			mov		esi,hTemplateMem
			call	Template
			invoke GlobalFree,hTemplateMem
			mov		eax,lpHandles
			invoke SendMessage,[eax].ADDINHANDLES.hCbo,CB_SETCURSEL,nBuild,0
			mov		eax,TRUE
		.else
			xor		eax,eax
		.endif
	.else
		xor		eax,eax
	.endif
	ret

GetLine:
	push	edi
	mov		edi,offset tempbuff
	.while byte ptr [esi] && byte ptr [esi]!=VK_RETURN
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	mov		byte ptr [edi],0
	.if byte ptr [esi]==VK_RETURN
		inc		esi
	.endif
	.if byte ptr [esi]==0Ah
		inc		esi
	.endif
	pop		edi
	retn

PutLine:
	push	esi
	mov		esi,offset tempbuff
	.while byte ptr [esi]
		invoke IsLine,esi,offset szPROJECTNAME,FALSE
		.if eax
			lea		esi,[esi+eax]
			invoke lstrcpy,edi,lpFile
			invoke lstrlen,edi
			lea		edi,[edi+eax]
		.else
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
		.endif
	.endw
	mov		dword ptr [edi],0A0Dh
	add		edi,2
	pop		esi
	retn

PutLineHex:
	push	esi
	mov		esi,offset tempbuff
	.while byte ptr [esi]
		mov		ax,[esi]
		.if al<'A'
			and		al,0Fh
		.else
			sub		al,'A'-10
		.endif
		.if ah<'A'
			and		ah,0Fh
		.else
			sub		ah,'A'-10
		.endif
		add		esi,2
		shl		al,4
		or		al,ah
		mov		[edi],al
		inc		edi
	.endw
	pop		esi
	retn

GetFileName:
	call	GetLine
	push	esi
	mov		esi,offset tempbuff
	mov		filename,0
	mov		fileext,0
	lea		edi,filename
	.while byte ptr [esi]
		invoke IsLine,esi,offset szPROJECTNAME,FALSE
		.if eax
			lea		esi,[esi+eax]
			invoke lstrcpy,edi,lpFile
			invoke lstrlen,edi
			lea		edi,[edi+eax]
		.elseif byte ptr [esi]=='.'
			inc		esi
			lea		edi,fileext
		.else
			movzx	eax,byte ptr [esi]
			mov		[edi],ax
			inc		esi
			inc		edi
		.endif
	.endw
	pop		esi
	retn

Template:
	mov		nFun,0
	mov		nBuild,0
	mov		nFiles,0
	.while byte ptr [esi]
		call	GetLine
		.if nFun==0
			invoke IsLine,offset tempbuff,offset szMAKE,FALSE
			.if eax
				lea		ebx,tempbuff[eax]
				movzx	eax,byte ptr [ebx]
				and		eax,0Fh
				mov		nBuild,eax
				mov		nFun,1
			.endif
		.elseif nFun==1
			invoke IsLine,offset tempbuff,offset szBEGINTXT,FALSE
			.if eax
				call	GetFileName
				mov		edi,hOutMem
				mov		nFun,2
			.else
				invoke IsLine,offset tempbuff,offset szBEGINBIN,FALSE
				.if eax
					call	GetFileName
					mov		edi,hOutMem
					mov		nFun,3
				.endif
			.endif
		.elseif nFun==2
			invoke IsLine,offset tempbuff,offset szENDTXT,FALSE
			.if eax
				sub		edi,hOutMem
				xor		eax,eax
				.if !nFiles
					mov		eax,1
				.endif
				invoke FileCreate,hWin,lpPath,addr filename,addr fileext,hOutMem,edi,eax
				mov		nFun,1
				inc		nFiles
			.else
				call	PutLine
			.endif
		.elseif nFun==3
			invoke IsLine,offset tempbuff,offset szENDBIN,FALSE
			.if eax
				sub		edi,hOutMem
				invoke FileCreate,hWin,lpPath,addr filename,addr fileext,hOutMem,edi,0
				mov		nFun,1
				inc		nFiles
			.else
				call	PutLineHex
			.endif
		.endif
	.endw
	retn

TemplateCreate endp

CreateProject proc uses ebx esi edi,hWin:HWND
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	propath[MAX_PATH]:BYTE
	LOCAL	proname[MAX_PATH]:BYTE

	mov		ebx,lpHandles
	; Get project path
	invoke GetDlgItemText,hWin,IDC_EDTPATH,addr propath,sizeof propath
	; Get project name
	invoke GetDlgItemText,hWin,IDC_EDTNAME,addr proname,sizeof proname
	; Create directories
	invoke IsDlgButtonChecked,hWin,IDC_CHKSUB
	.if eax
		; Create project sub directory
		invoke FolderCreate,hWin,addr propath,addr proname
		or		eax,eax
		jz		Ex
		invoke lstrcpy,addr propath,eax
	.endif
	invoke SetCurrentDirectory,addr propath
	.if !eax
		; Error could not open directory
		invoke lstrcpy,offset tempbuff,offset szErrOpenDir
		invoke lstrcat,offset tempbuff,addr buffer
		invoke MessageBox,hWin,offset tempbuff,offset szMenuItem,MB_OK or MB_ICONERROR
		xor		eax,eax
		jmp		Ex
	.endif
	; Update file browser
	invoke SendMessage,[ebx].ADDINHANDLES.hBrowse,FBM_SETPATH,TRUE,addr propath
	; Create directories
	invoke IsDlgButtonChecked,hWin,IDC_CHKBAK
	.if eax
		; Create Bak directory
		invoke FolderCreate,hWin,addr propath,offset szBakPath
		or		eax,eax
		jz		Ex
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKMOD
	.if eax
		; Create Mod directory
		invoke FolderCreate,hWin,addr propath,offset szModPath
		or		eax,eax
		jz		Ex
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKINC
	.if eax
		; Create Inc directory
		invoke FolderCreate,hWin,addr propath,offset szIncPath
		or		eax,eax
		jz		Ex
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKRES
	.if eax
		; Create Res directory
		invoke FolderCreate,hWin,addr propath,offset szResPath
		or		eax,eax
		jz		Ex
	.endif
	; Update file browser
	invoke SendMessage,[ebx].ADDINHANDLES.hBrowse,FBM_SETPATH,TRUE,addr propath
	; Check if a template is selected
	invoke SendDlgItemMessage,hDlg2,IDC_LSTTEMPLATE,LB_GETCURSEL,0,0
	.if sdword ptr eax>0
		; Template
		mov		edx,eax
		invoke TemplateCreate,hWin,edx,addr propath,addr proname
		or		eax,eax
		jz		Ex
		; Create mes file
		invoke FileCreate,hWin,addr propath,addr proname,offset szMesFile,0,0,2
		or		eax,eax
		jz		Ex
		mov		eax,lpData
		lea		eax,[eax].ADDINDATA.szSessionFile
		push	eax
		mov		eax,lpProc
		call	[eax].ADDINPROCS.lpWriteSessionFile
	.else
		; No template
		; Get build option
		invoke SendDlgItemMessage,hDlg1,IDC_CBOBUILD,CB_GETCURSEL,0,0
		invoke SendMessage,[ebx].ADDINHANDLES.hCbo,CB_SETCURSEL,eax,0
		; Create files
		invoke IsDlgButtonChecked,hDlg1,IDC_CHKASM
		.if eax
			; Create asm file
			invoke FileCreate,hWin,addr propath,addr proname,offset szAsmFile,0,0,1
			or		eax,eax
			jz		Ex
		.endif
		invoke IsDlgButtonChecked,hDlg1,IDC_CHKINC
		.if eax
			; Create inc file
			invoke FileCreate,hWin,addr propath,addr proname,offset szIncFile,0,0,0
			or		eax,eax
			jz		Ex
		.endif
		invoke IsDlgButtonChecked,hDlg1,IDC_CHKRC
		.if eax
			; Create rc file
			invoke FileCreate,hWin,addr propath,addr proname,offset szRcFile,0,0,0
			or		eax,eax
			jz		Ex
		.endif
		invoke IsDlgButtonChecked,hDlg1,IDC_CHKTXT
		.if eax
			; Create txt file
			invoke FileCreate,hWin,addr propath,addr proname,offset szTxtFile,0,0,0
			or		eax,eax
			jz		Ex
		.endif
		invoke IsDlgButtonChecked,hDlg1,IDC_CHKMES
		.if eax
			; Create mes file
			invoke FileCreate,hWin,addr propath,addr proname,offset szMesFile,0,0,2
			or		eax,eax
			jz		Ex
			mov		eax,lpData
			lea		eax,[eax].ADDINDATA.szSessionFile
			push	eax
			mov		eax,lpProc
			call	[eax].ADDINPROCS.lpWriteSessionFile
		.endif
	.endif
	mov		eax,TRUE
  Ex:
	ret

CreateProject endp

NewProjectDialogProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hTab:HWND
	LOCAL	tci:TCITEM
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetDlgItemText,hWin,IDC_EDTPATH,offset ProjectPath
		invoke CheckDlgButton,hWin,IDC_CHKSUB,BST_CHECKED
		invoke CheckDlgButton,hWin,IDC_CHKBAK,BST_CHECKED
		; Get handle of tabstrip
		invoke GetDlgItem,hWin,IDC_TAB1
		mov		hTab,eax
		mov		tci.imask,TCIF_TEXT Or TCIF_PARAM
		mov		tci.pszText,offset szFiles
		; Create Tab1 child dialog
		invoke CreateDialogParam,hInstance,IDD_DLGTAB1,hTab,addr Tab1Proc,0
		mov		tci.lParam,eax
		mov		hDlg1,eax
		invoke SendMessage,hTab,TCM_INSERTITEM,0,addr tci
		mov		tci.pszText,offset szTemplate
		; Create Tab2 child dialog
		invoke CreateDialogParam,hInstance,IDD_DLGTAB2,hTab,addr Tab2Proc,0
		mov		tci.lParam,eax
		mov		hDlg2,eax
		invoke SendMessage,hTab,TCM_INSERTITEM,1,addr tci
	.elseif eax==WM_NOTIFY
		mov		ebx,lParam
		.if [ebx].NMHDR.code==TCN_SELCHANGING
			; Hide the currently selected dialog
			mov		tci.imask,TCIF_PARAM
			invoke SendMessage,[ebx].NMHDR.hwndFrom,TCM_GETCURSEL,0,0
			mov		edx,eax
			invoke SendMessage,[ebx].NMHDR.hwndFrom,TCM_GETITEM,edx,addr tci
			invoke ShowWindow,tci.lParam,SW_HIDE
		.elseif [ebx].NMHDR.code==TCN_SELCHANGE
			; Show the currently selected dialog
			mov		tci.imask,TCIF_PARAM
			invoke SendMessage,[ebx].NMHDR.hwndFrom,TCM_GETCURSEL,0,0
			mov		edx,eax
			invoke SendMessage,[ebx].NMHDR.hwndFrom,TCM_GETITEM,edx,addr tci
			invoke ShowWindow,tci.lParam,SW_SHOW
		.endif
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				mov		ebx,lpData
				mov		eax,lpHandles
				.if [ebx].ADDINDATA.szSessionFile
					invoke SendMessage,[eax].ADDINHANDLES.hWnd,WM_COMMAND,IDM_FILE_CLOSESESSION or (BN_CLICKED SHL 16),NULL
				.else
					.if [eax].ADDINHANDLES.hREd
						invoke SendMessage,[eax].ADDINHANDLES.hWnd,WM_COMMAND,IDM_FILE_CLOSE_ALL or (BN_CLICKED SHL 16),NULL
					.endif
				.endif
				mov		eax,lpHandles
				.if ![ebx].ADDINDATA.szSessionFile && ![eax].ADDINHANDLES.hREd
					; Create the project
					invoke CreateProject,hWin
					.if eax
						mov		eax,lpHandles
						invoke SendMessage,[eax].ADDINHANDLES.hWnd,WM_COMMAND,IDM_PROJECT_CREATE or (BN_CLICKED SHL 16),NULL
						invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
					.endif
				.endif
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNPATH
				invoke BrowseFolder,hWin,IDC_EDTPATH
			.endif
		.elseif edx==EN_CHANGE
			invoke GetDlgItem,hWin,IDOK
			push	eax
			invoke GetDlgItemText,hWin,IDC_EDTNAME,addr buffer,sizeof buffer
			pop		edx
			invoke EnableWindow,edx,eax
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

NewProjectDialogProc endp
