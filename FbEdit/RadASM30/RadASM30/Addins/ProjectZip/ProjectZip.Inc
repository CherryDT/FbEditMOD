
;#########################################################################
;	Include files

include windows.inc
include kernel32.inc
include user32.inc
include comctl32.inc
include shell32.inc
include gdi32.inc
include zlib\zlibstat.inc

;#########################################################################
;	Libraries

includelib kernel32.lib
includelib user32.lib
includelib comctl32.lib
includelib shell32.lib
includelib gdi32.lib
includelib zlib\zlibstat.lib

;#########################################################################
;	RadASM Add In Include

include ..\Addins.inc

;#########################################################################
;	VKim's Debug

include		masm32.inc
include		Debug.Inc
includelib	masm32.lib
includelib	Debug.lib

;#########################################################################
;	Prototypes

DLLProc				PROTO :DWORD, :DWORD, :DWORD, :DWORD
InstallDLL			PROTO :DWORD, :DWORD

TextOutput			PROTO :DWORD
clrOutput			PROTO 
HexOutput			PROTO :DWORD

IDB_FILE			equ 100
IDD_DIALOG1			equ 101
IDC_LSTSORT			equ 1001
IDC_BTNEXIT			equ 2
IDC_BTNZIP			equ 1004
IDC_BTNMAIL			equ 1002
IDC_LSVFILELIST		equ 1003
IDC_EDTFOLDER		equ 1005
IDC_BTNFOLDER		equ 1006
IDC_EDTCURRENT		equ 1008
IDC_BTNSELECTALL	equ 1007
IDC_BTNZIPPROJECT	equ 1011

ZFILEINFO struct
	dwSizeLow	dd ?
	dwSizeHigh	dd ?
	dwTimeLow	dd ?
	dwTimeHigh	dd ?
ZFILEINFO ends

.const

szProjectZip		db 'Project zipper',0
szName				db 'Name',0
szSize				db 'Size',0
szDate				db 'Date',0
szSizeFmt			db '%lu',0
szDateFmt			db "MM'-'dd'-'yyyy' '",0
szTimeFmt			db "hh':'mm':'ss",0
szDateFmtFile		db 'yyMMdd',0
szArchive			db '\Archive\MyZip.zip',0
szCreate			db 'Creating zip ',0
szOverwrite			db 'Overwrite existing file?',0Dh,0
szError				db 'Could not create file',0Dh,0
szApp				db 'ProjectZip',0
szKeyMail			db 'mail',0
szKeySkip			db 'skip',0
szKeyFolder			db 'folder',0
szKeyPos			db 'pos',0
szNULL				db 0
szCR				db 0Dh,0
szDollarA			db '$A',0
szAdded				db 'Added to zip: ',0
szDone				db 0Dh,'Done.',0
szOptStr1			db 'Enable Project zipper',0
szOptStr2			db 'Add date to zipname',0
szMailto			db 'mailto:',0
szSubject			db '?subject=',0
szAppName			db 'ProjectZip',0

.data?

hInstance			dd ?	;Dll's module handle
lpHandles			dd ?	;Pointer to handles struct
lpProc				dd ?	;Pointer to proc struct
lpData				dd ?	;Pointer to data struct
IDAddIn				dd ?	;Unique ID for this AddIn

szSourceFolder		db MAX_PATH dup(?)
szDestFolder		db MAX_PATH dup(?)
szZipFile			db MAX_PATH dup(?)
szTemp				db MAX_PATH dup(?)
szMail				db MAX_PATH dup(?)
szSkip				db MAX_PATH dup(?)
szCurrentFolder		db MAX_PATH dup(?)
fOption				dd ?
hDlg				dd ?
hIml				dd ?
hLV					dd ?
hLB					dd ?
hED					dd ?
OldListViewProc		dd ?
ftw					FILETIME <?>
ftl					FILETIME <?>
zipfi				zip_fileinfo <>
fatdate				dw ?
fattime				dw ?
fh					dd ?
fsize				dd ?
hFile				dd ?
gMem				dd ?
bread				dd ?
counter				dd ?
pidl				dd ?
bri					BROWSEINFO  <?>
hook				HOOK <>

.code

;#########################################################################
;		Output Window procs

SelectOutput proc nTab:DWORD

	pushad
	push		nTab
	mov		eax,lpProc
	call		[eax].ADDINPROCS.lpSetOutputTab
	popad
	ret

SelectOutput endp

TextOutput proc lpszStr

	pushad
	push		lpszStr
	mov		eax,lpProc
	call		[eax].ADDINPROCS.lpTextOutput
	push		offset szCR
	mov		eax,lpProc
	call		[eax].ADDINPROCS.lpTextOutput
	popad
	ret

TextOutput endp

ClearOutput proc

	pushad
	mov		eax,lpHandles
	invoke SendMessage,[eax].ADDINHANDLES.hOutput,WM_SETTEXT,0,addr szNULL
	popad	
	ret

ClearOutput endp

ShowOutput proc fShow:DWORD

	pushad
	push	fShow
	mov		eax,lpProc
	call	[eax].ADDINPROCS.lpShowOutput
	popad
	ret

ShowOutput endp

;#########################################################################

CreateTheZip proc pszFileName:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke SelectOutput,0
	invoke ClearOutput
	invoke ShowOutput,TRUE
	invoke lstrcpy,addr buffer,offset szCreate
	invoke lstrcat,addr buffer,pszFileName
	invoke TextOutput,addr buffer
	invoke zipOpen,pszFileName,0
	mov		fh,eax
	ret

CreateTheZip endp

CloseTheZip proc

	invoke zipClose,fh,0       
	ret

CloseTheZip endp

AddFileToZip proc uses ebx esi edi,pszFileName:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		edi,pszFileName
	invoke lstrlen,edi
	lea		edi,[edi+eax]
	.while byte ptr [edi]!='.' && edi>pszFileName
		dec		edi
	.endw
	mov		esi,offset szSkip
	.while byte ptr [esi]
		.if byte ptr [esi]=='.'
			invoke lstrcmpi,esi,edi
			or		eax,eax
			je		Ex
		.endif
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
	.endw
	invoke CreateFile,pszFileName,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ or FILE_SHARE_WRITE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileTime,hFile,0,0,addr ftw
		invoke FileTimeToLocalFileTime,addr ftw,addr ftl
		invoke FileTimeToDosDateTime,addr ftl,addr fatdate,addr fattime
		mov 	ax,fatdate
		shl 	eax,16
		or		ax,fattime
		mov		zipfi.dosDate,eax
		mov		esi,pszFileName
		lea		edi,buffer
		.while byte ptr [esi]
			lodsb
			.if al=='\'
				mov		al,'/'
			.endif
			stosb
		.endw
		mov		byte ptr [edi],0
		invoke zipOpenNewFileInZip,fh,addr buffer,addr zipfi,0,0,0,0,0,Z_DEFLATED,Z_DEFAULT_COMPRESSION
	
		invoke GetFileSize,hFile,0
		mov		fsize,eax
		.if eax
			invoke GlobalAlloc,GMEM_FIXED,fsize
			mov		gMem,eax
			invoke ReadFile,hFile,gMem,fsize,addr bread,0
			invoke CloseHandle,hFile
			mov		esi,gMem
			mov		eax,fsize
			mov		ecx,100
			cdq
			div		ecx
			mov		ebx,eax;chunk size
			mov		edi,edx
			mov counter,100
			invoke zipWriteInFileInZip,fh,esi,edi ;write first
			add		esi,edi ;next pointer
			@@:
			invoke zipWriteInFileInZip,fh,esi,ebx ;write next
			add 	esi,ebx
			dec 	counter
			jnz		@B
			invoke GlobalFree,gMem
		.endif
		invoke lstrcpy,addr buffer,offset szAdded
		invoke lstrcat,addr buffer,pszFileName
		invoke TextOutput,addr buffer
		invoke zipCloseFileInZip,fh
	.endif
  Ex:
	ret

AddFileToZip endp
