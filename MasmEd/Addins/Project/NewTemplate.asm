

;NewTemplate.dlg
IDD_DLGNEWTEMPLATE				equ 2000
IDC_EDTDESCRIPTION				equ 1001
IDC_LSTFILES					equ 1002
IDC_BTNADD						equ 1003
IDC_BTNDEL						equ 1004
IDC_EDTFILENAME					equ 1005
IDC_BTNFILENAME					equ 1006
IDC_CBOTBLBUILD					equ 1008

.const

TPLFilterString					db 'Template (*.tpl)',0,'*.tpl',0,0
szTplFile						db 'tpl',0
ALLFilterString					db 'All files (*.*)',0,'*.*',0,0
szDefTxt						db '.asm.inc.rc.def.txt.xml.',0
szDefBin						db '.tbr.obj.lib.res.bmp.ico.cur.',0

szErrNoMain						db 'No main file is selected or the selected file is not a .asm file.',0
szErrNotInPath					db 'The file is not in the path of the main file.',0Dh,0Ah,0
szErrUnknownType				db 'The file type is unknown.',0Dh,0Ah,0
szInclude						db 'include',0
szLibrary						db 'library',0

.data?

szTxt							db 256 dup(?)
szBin							db 256 dup(?)

.code

IsFileType proc uses ebx esi edi,lpFileName:DWORD,lpFileTypes:DWORD
	LOCAL	filetype[MAX_PATH]:BYTE

	mov		filetype,0
	mov		esi,lpFileName
	invoke lstrlen,esi
	.while eax
		.if byte ptr [esi+eax]=='.'
			invoke lstrcpy,addr filetype,addr [esi+eax]
			invoke lstrcat,addr filetype,offset szDot
			.break
		.endif
		dec		eax
	.endw
	.if filetype
		mov		esi,lpFileTypes
		lea		edi,filetype
		.while TRUE
			xor		ecx,ecx
			.while byte ptr [edi+ecx]
				mov		al,[edi+ecx]
				mov		ah,[esi+ecx]
				.if al>='a' && al<='z'
					and		al,5Fh
				.endif
				.if ah>='a' && ah<='z'
					and		ah,5Fh
				.endif
				.break .if al!=ah
				inc		ecx
			.endw
			.if !byte ptr [edi+ecx]
				mov		eax,TRUE
				jmp		Ex
			.endif
			inc		esi
			.while byte ptr [esi]!='.'
				inc		esi
			.endw
			.break .if !byte ptr [esi+1]
		.endw
	.endif
	xor		eax,eax
  Ex:
	ret

IsFileType endp

CreateTemplate proc uses ebx esi edi,hWin:HWND
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	path[MAX_PATH]:BYTE
	LOCAL	main[MAX_PATH]:BYTE
	LOCAL	hTplMem:HGLOBAL
	LOCAL	hFile:HANDLE
	LOCAL	bytes:DWORD

	invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		mov		edx,eax
		invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,edx,addr path
		invoke lstrlen,addr path
		lea		ebx,path[eax-3]
		invoke lstrcmpi,ebx,offset szAsmFile
		.if !eax && byte ptr [ebx-1]=='.'
			;Get path and filename from main file
			invoke lstrlen,addr path
			.while eax
				.if byte ptr path[eax]=='\'
					push	eax
					invoke lstrcpy,addr main,addr path[eax+1]
					pop		eax
					mov		path[eax+1],0
					.break
				.endif
				dec		eax
			.endw
			invoke lstrlen,addr main
			.while eax
				.if byte ptr main[eax]=='.'
					mov		main[eax],0
					.break
				.endif
				dec		eax
			.endw
			;Check if all files is in the path of the main file
			xor		ebx,ebx
			.while TRUE
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,ebx,addr buffer
				.if eax!=LB_ERR
					invoke IsLine,addr buffer,addr path,TRUE
					.if !eax
						invoke lstrcpy,offset tempbuff,offset szErrNotInPath
						invoke lstrcat,offset tempbuff,addr buffer
						invoke MessageBox,hWin,offset tempbuff,offset szMenuItem,MB_OK or MB_ICONERROR
						xor		eax,eax
						jmp		Ex
					.endif
				.else
					.break
				.endif
				inc		ebx
			.endw
			;Check if all files is of a known file type
			xor		ebx,ebx
			.while TRUE
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,ebx,addr buffer
				.if eax!=LB_ERR
					invoke IsFileType,addr buffer,offset szTxt
					.if !eax
						invoke IsFileType,addr buffer,offset szBin
					.endif
					.if !eax
						invoke lstrcpy,offset tempbuff,offset szErrUnknownType
						invoke lstrcat,offset tempbuff,addr buffer
						invoke MessageBox,hWin,offset tempbuff,offset szMenuItem,MB_OK or MB_ICONERROR
						xor		eax,eax
						jmp		Ex
					.endif
				.else
					.break
				.endif
				inc		ebx
			.endw
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*1024
			mov		hTplMem,eax
			; Add description
			mov		edi,hTplMem
			invoke GetDlgItemText,hWin,IDC_EDTDESCRIPTION,edi,1024
			lea		edi,[edi+eax]
			mov		word ptr [edi],0A0Dh
			lea		edi,[edi+2]
			; Add make option
			invoke lstrcpy,edi,offset szMAKE
			lea		edi,[edi+9]
			invoke SendDlgItemMessage,hWin,IDC_CBOTBLBUILD,CB_GETCURSEL,0,0
			or		eax,30h
			mov		[edi],al
			lea		edi,[edi+1]
			mov		word ptr [edi],0A0Dh
			lea		edi,[edi+2]
			; Add main file
			invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETCURSEL,0,0
			mov		ebx,eax
			invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,ebx,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_DELETESTRING,ebx,0
			call	AddTxtFile
			; Add the rest of the files
			xor		ebx,ebx
			.while TRUE
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,ebx,addr buffer
				.break .if eax==LB_ERR
				invoke IsFileType,addr buffer,offset szTxt
				.if eax
					call	AddTxtFile
				.else
					call	AddBinFile
				.endif
				inc		ebx
			.endw
			invoke GetDlgItemText,hWin,IDC_EDTFILENAME,addr buffer,sizeof buffer
			invoke CreateFile,addr buffer,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
			.if eax!=INVALID_HANDLE_VALUE
				mov		hFile,eax
				sub		edi,hTplMem
				invoke WriteFile,hFile,hTplMem,edi,addr bytes,NULL
				invoke CloseHandle,hFile
			.endif
			invoke GlobalFree,hTplMem
			mov		eax,TRUE
		.else
			call	ErrNoMain
			xor		eax,eax
			jmp		Ex
		.endif
	.else
		call	ErrNoMain
		xor		eax,eax
		jmp		Ex
	.endif
  Ex:
	ret

ErrNoMain:
	invoke MessageBox,hWin,offset szErrNoMain,offset szMenuItem,MB_OK or MB_ICONERROR
	retn

AddFileName:
	push	esi
	invoke lstrlen,addr path
	lea		esi,buffer[eax]
	invoke IsLine,esi,addr main,TRUE
	.if eax
		invoke lstrcpy,edi,offset szPROJECTNAME
		invoke lstrlen,addr main
		lea		esi,[esi+eax]
		invoke lstrcat,edi,esi
	.else
		invoke lstrcpy,edi,esi
	.endif
	invoke lstrlen,edi
	lea		edi,[edi+eax]
	mov		word ptr [edi],0A0Dh
	lea		edi,[edi+2]
	pop		esi
	retn

AddWhiteSpace:
	.while byte ptr [esi]==VK_TAB || byte ptr [esi]==VK_SPACE
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	retn

AddWord:
	.while byte ptr [esi]!=VK_TAB && byte ptr [esi]!=VK_SPACE
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	retn

AddLine:
	.while byte ptr [esi]!=VK_RETURN && byte ptr [esi]
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	.if byte ptr [esi]==VK_RETURN
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endif
	.if byte ptr [esi]==0Ah
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endif
	retn

AddTxtLine:
	call	AddWhiteSpace
	invoke IsLine,esi,offset szInclude,TRUE
	.if eax
	  @@:
		call	AddWord
		call	AddWhiteSpace
		invoke IsLine,esi,addr main,TRUE
		.if eax
			invoke lstrcpy,edi,offset szPROJECTNAME
			lea		edi,[edi+15]
			invoke lstrlen,addr main
			lea		esi,[esi+eax]
		.endif
	.else
		invoke IsLine,esi,offset szLibrary,TRUE
		or		eax,eax
		jne		@b
	.endif
	call	AddLine
	retn

AddTxtFile:
	invoke lstrcpy,edi,offset szBEGINTXT
	lea		edi,[edi+12]
	mov		word ptr [edi],0A0Dh
	lea		edi,[edi+2]
	call	AddFileName
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*1024
	mov		esi,eax
	push	eax
	invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		mov		edx,eax
		invoke ReadFile,hFile,esi,edx,addr bytes,NULL
		invoke CloseHandle,hFile
		.while byte ptr [esi]
			call	AddTxtLine
		.endw
		.if byte ptr [edi-1]!=0Ah
			mov		word ptr [edi],0A0Dh
			lea		edi,[edi+2]
		.endif
	.endif
	pop		eax
	invoke GlobalFree,eax
	invoke lstrcpy,edi,offset szENDTXT
	lea		edi,[edi+10]
	mov		word ptr [edi],0A0Dh
	lea		edi,[edi+2]
	retn

AddBinFile:
	invoke lstrcpy,edi,offset szBEGINBIN
	lea		edi,[edi+12]
	mov		word ptr [edi],0A0Dh
	lea		edi,[edi+2]
	call	AddFileName
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*1024
	mov		esi,eax
	push	eax
	invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		mov		edx,eax
		invoke ReadFile,hFile,esi,edx,addr bytes,NULL
		invoke CloseHandle,hFile
		xor		ecx,ecx
		.while ecx<bytes
			.if ecx
				test	ecx,0Fh
				.if ZERO?
					mov		word ptr [edi],0A0Dh
					lea		edi,[edi+2]
				.endif
			.endif
			mov		al,[esi+ecx]
			mov		ah,al
			shr		al,4
			and		ah,0Fh
			.if al<=9
				or		al,30h
			.else
				add		al,'A'-10
			.endif
			.if ah<=9
				or		ah,30h
			.else
				add		ah,'A'-10
			.endif
			mov		[edi],ax
			lea		edi,[edi+2]
			inc		ecx
		.endw
		mov		word ptr [edi],0A0Dh
		lea		edi,[edi+2]
	.endif
	pop		eax
	invoke GlobalFree,eax
	invoke lstrcpy,edi,offset szENDBIN
	lea		edi,[edi+10]
	mov		word ptr [edi],0A0Dh
	lea		edi,[edi+2]
	retn

CreateTemplate endp

NewTemplateDialogProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	path[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		ebx,lpHandles
		mov		ebx,[ebx].ADDINHANDLES.hCbo
		xor		esi,esi
		.while TRUE
			invoke SendMessage,ebx,CB_GETLBTEXT,esi,addr buffer
			.break .if eax==LB_ERR
			invoke SendDlgItemMessage,hWin,IDC_CBOTBLBUILD,CB_ADDSTRING,0,addr buffer
			inc		esi
		.endw
		invoke SendDlgItemMessage,hWin,IDC_CBOTBLBUILD,CB_SETCURSEL,0,0
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke CreateTemplate,hWin
				.if eax
					invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
				.endif
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNFILENAME
				invoke RtlZeroMemory,addr ofn,SizeOf OPENFILENAME
				mov		ofn.lStructSize,SizeOf OPENFILENAME
				mov		eax,hWin
				mov		ofn.hwndOwner,eax
				mov		eax,hInstance
				mov		ofn.hInstance,eax
				mov		eax,lpData
				invoke lstrcpy,offset tempbuff,addr [eax].ADDINDATA.AppPath
				invoke lstrcat,offset tempbuff,offset szTemplatesPath
				mov		ofn.lpstrInitialDir,offset tempbuff
				mov		ofn.lpstrFilter,offset TPLFilterString
				mov		ofn.lpstrDefExt,offset szTplFile
				mov		buffer,0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.Flags,OFN_EXPLORER or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
				invoke GetSaveFileName,addr ofn
				.if eax
					invoke SetDlgItemText,hWin,IDC_EDTFILENAME,addr buffer
				.endif
			.elseif eax==IDC_BTNADD
				invoke RtlZeroMemory,addr ofn,SizeOf OPENFILENAME
				mov		ofn.lStructSize,SizeOf OPENFILENAME
				mov		eax,hWin
				mov		ofn.hwndOwner,eax
				mov		eax,hInstance
				mov		ofn.hInstance,eax
				mov		ofn.lpstrInitialDir,offset ProjectPath
				mov		ofn.lpstrFilter,offset ALLFilterString
				mov		tempbuff,0
				mov		ofn.lpstrFile,offset tempbuff
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.Flags,OFN_EXPLORER or OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_ALLOWMULTISELECT or OFN_EXPLORER
				invoke GetOpenFileName,addr ofn
				.if eax
					mov		esi,offset tempbuff
					invoke lstrlen,esi
					lea		eax,[esi+eax+1]
					.if byte ptr [eax]
						push	eax
						invoke lstrcpy,addr path,esi
						pop		esi
						.while byte ptr [esi]
							invoke lstrcpy,addr buffer,addr path
							invoke lstrcat,addr buffer,offset szBS
							invoke lstrcat,addr buffer,esi
							call	IsFileAdded
							.if !eax
								invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_ADDSTRING,0,addr buffer
							.endif
							invoke lstrlen,esi
							lea		esi,[esi+eax+1]
						.endw
					.else
						invoke lstrcpy,addr buffer,esi
						call	IsFileAdded
						.if !eax
							invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_ADDSTRING,0,addr buffer
						.endif
					.endif
				.endif
			.elseif eax==IDC_BTNDEL
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_DELETESTRING,eax,0
				.endif
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTFILENAME
				invoke GetDlgItem,hWin,IDOK
				push	eax
				invoke GetDlgItemText,hWin,IDC_EDTFILENAME,addr buffer,sizeof buffer
				movzx	eax,buffer
				pop		edx
				invoke EnableWindow,edx,eax
			.endif
		.elseif edx==LBN_SELCHANGE
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

IsFileAdded:
	xor		ebx,ebx
	.while TRUE
		invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,ebx,addr buffer1
		.if eax!=LB_ERR
			invoke lstrcmp,addr buffer,addr buffer1
			.if !eax
				mov		eax,TRUE
				.break
			.endif
		.else
			xor		eax,eax
			.break
		.endif
		inc		ebx
	.endw
	retn

NewTemplateDialogProc endp
