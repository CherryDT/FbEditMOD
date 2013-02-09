;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include Project.inc
include NewProject.asm
include NewTemplate.asm
include ProjectOption.asm
include Sniplets.asm
include Backup.asm
include DeleteMinor.asm

.code

UpdateMenu proc uses ebx,hMnu:HMENU
	LOCAL	mii:MENUITEMINFO

	mov		ebx,MenuIDAddin
	mov		mii.cbSize,sizeof MENUITEMINFO
	;Create sub menu
	invoke CreatePopupMenu
	mov		hSubMenu,eax
	mov		mii.fMask,MIIM_ID or MIIM_TYPE
	mov		mii.fType,MFT_STRING
	lea		eax,[ebx+1]
	mov		mii.wID,eax
	mov		mii.dwTypeData,offset szCreateProject
	invoke InsertMenuItem,hSubMenu,9,TRUE,addr mii
	lea		eax,[ebx+2]
	mov		mii.wID,eax
	mov		mii.dwTypeData,offset szCreateTemplate
	invoke InsertMenuItem,hSubMenu,9,TRUE,addr mii
	lea		eax,[ebx+3]
	mov		mii.wID,eax
	mov		mii.dwTypeData,offset szSniplets
	invoke InsertMenuItem,hSubMenu,9,TRUE,addr mii
	lea		eax,[ebx+4]
	mov		mii.wID,eax
	mov		mii.dwTypeData,offset szTemplateOptions
	invoke InsertMenuItem,hSubMenu,9,TRUE,addr mii
	mov		mii.fMask,MIIM_SUBMENU
	mov		edx,lpHandles
	invoke GetMenuItemInfo,[edx].ADDINHANDLES.hMnu,IDM_TOOLS,FALSE,addr mii
	mov		eax,mii.hSubMenu
	mov		hMnu,eax
	mov		mii.fMask,MIIM_ID or MIIM_TYPE or MIIM_SUBMENU
	mov		mii.fType,MFT_STRING
	mov		mii.wID,ebx
	mov		eax,hSubMenu
	mov		mii.hSubMenu,eax
	mov		mii.dwTypeData,offset szMenuItem
	invoke InsertMenuItem,hMnu,99,TRUE,addr mii
	ret

UpdateMenu endp

UpdateAccelerator proc uses ebx esi,nID:DWORD,nKey:DWORD,nMod:DWORD
	LOCAL	hMem:HGLOBAL
	LOCAL	nAccel:DWORD

	mov		ebx,lpHandles
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16384
	mov		hMem,eax
	invoke CopyAcceleratorTable,[ebx].ADDINHANDLES.hAccel,NULL,0
	mov		nAccel,eax
	invoke CopyAcceleratorTable,[ebx].ADDINHANDLES.hAccel,hMem,nAccel
	invoke DestroyAcceleratorTable,[ebx].ADDINHANDLES.hAccel
	mov		eax,nAccel
	mov		edx,sizeof ACCEL
	mul		edx
	mov		esi,hMem
	lea		esi,[esi+eax]
	mov		eax,nMod
	mov		[esi].ACCEL.fVirt,al
	mov		eax,nKey
	mov		[esi].ACCEL.key,ax
	mov		eax,nID
	mov		[esi].ACCEL.cmd,ax
	inc		nAccel
	invoke CreateAcceleratorTable,hMem,nAccel
	mov		[ebx].ADDINHANDLES.hAccel,eax
	invoke GlobalFree,hMem
	ret

UpdateAccelerator endp

;#########################################################################
;Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

OutputString proc uses ebx,lpString:DWORD

	mov		ebx,lpProc
	push	0
	call	[ebx].ADDINPROCS.lpOutputSelect
	push	TRUE
	call	[ebx].ADDINPROCS.lpOutputShow
	push	lpString
	call	[ebx].ADDINPROCS.lpOutputString
	ret

OutputString endp

; Export this proc
InstallAddin proc uses ebx,hWin:DWORD
	LOCAL	lpType:DWORD
	LOCAL	lpcbData:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0
	mov		lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0
	mov		lpData,eax
	invoke SendMessage,ebx,AIM_GETMENUID,5,0
	mov		MenuIDAddin[0],eax
	inc		eax
	mov		MenuIDAddin[4],eax
	inc		eax
	mov		MenuIDAddin[8],eax
	inc		eax
	mov		MenuIDAddin[12],eax
	inc		eax
	mov		MenuIDAddin[16],eax
	mov		eax,MenuIDAddin[12]
	invoke UpdateAccelerator,eax,VK_F11,FVIRTKEY or FNOINVERT
	mov		ebx,lpData
	invoke lstrcpy,offset ProjectPath,addr [ebx].ADDINDATA.AppPath
	invoke lstrcat,offset ProjectPath,offset szProjectsPath
	invoke lstrcpy,offset TemplatePath,addr [ebx].ADDINDATA.AppPath
	invoke lstrcat,offset TemplatePath,offset szTemplatesPath
	invoke lstrcpy,offset SnipletPath,addr [ebx].ADDINDATA.AppPath
	invoke lstrcat,offset SnipletPath,offset szSnipletsPath
	invoke lstrcpy,offset szTxt,offset szDefTxt
	invoke lstrcpy,offset szBin,offset szDefBin
	mov		ebx,lpHandles
	mov		nBackup,3
	mov		lpcbData,4
	invoke RegQueryValueEx,[ebx].ADDINHANDLES.hReg,addr szBackups,0,addr lpType,addr nBackup,addr lpcbData
	mov		lpcbData,sizeof szTxt
	invoke RegQueryValueEx,[ebx].ADDINHANDLES.hReg,addr szTextFiles,0,addr lpType,addr szTxt,addr lpcbData
	mov		lpcbData,sizeof szBin
	invoke RegQueryValueEx,[ebx].ADDINHANDLES.hReg,addr szBinaryFiles,0,addr lpType,addr szBin,addr lpcbData
	mov		hook.hook1,HOOK_COMMAND or HOOK_MENUUPDATE or HOOK_FILESAVE or HOOK_MAKEBEGIN or HOOK_MAKEDONE
	xor		eax,eax
	mov		hook.hook2,eax
	mov		hook.hook3,eax
	mov		hook.hook4,eax
	mov		eax,offset hook
	ret 

InstallAddin endp

; Export this proc
AddinProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	; This proc handles messages sent from MasmEd to our addin
	; Return TRUE to prevent MasmEd and other addins from executing the command.

	mov		eax,uMsg
	.if eax==AIM_COMMAND
		mov		eax,wParam
		movzx	eax,ax
		mov		edx,offset MenuIDAddin
		.if eax==[edx+4]
			;The 'Create Project' menuitem we added has been selected
			invoke DialogBoxParam,hInstance,IDD_DLGNEWPROJECT,hWin,offset NewProjectDialogProc,0
			mov		eax,TRUE
			jmp		ExRet
		.elseif eax==[edx+8]
			;The 'Create Template' menuitem we added has been selected
			invoke DialogBoxParam,hInstance,IDD_DLGNEWTEMPLATE,hWin,offset NewTemplateDialogProc,0
			mov		eax,TRUE
			jmp		ExRet
		.elseif eax==[edx+12]
			;The 'Sniplets' menuitem we added has been selected
			invoke DialogBoxParam,hInstance,IDD_DLGSNIPLETS,hWin,offset SnipletsProc,0
			mov		eax,TRUE
			jmp		ExRet
		.elseif eax==[edx+16]
			;The 'Options' menuitem we added has been selected
			invoke DialogBoxParam,hInstance,IDD_DLGOPTION,hWin,offset ProjectOptionProc,0
			mov		eax,TRUE
			jmp		ExRet
		.endif
	.elseif eax==AIM_MENUUPDATE
		invoke UpdateMenu,wParam
	.elseif eax==AIM_FILESAVE
		invoke BackupEdit,lParam,1
	.elseif eax==AIM_MAKEBEGIN
		mov		fDeleteMinor,FALSE
		.if wParam==IDM_MAKE_BUILD || wParam==IDM_MAKE_GO
			mov		fDeleteMinor,TRUE
		.endif
	.elseif eax==AIM_MAKEDONE
		.if fDeleteMinor && (wParam==IDM_MAKE_BUILD || wParam==IDM_MAKE_GO)
			invoke DeleteMinorFiles
			mov		fDeleteMinor,FALSE
		.endif
	.endif
	mov		eax,FALSE
  ExRet:
	ret

AddinProc endp

;#########################################################################

end DllEntry
