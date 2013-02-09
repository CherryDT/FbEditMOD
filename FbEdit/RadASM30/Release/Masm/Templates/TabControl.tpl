Tab Control
[*BEGINTXT*]
[*PROJECTNAME*].prra
[Version]
Version=3000
[Project]
Assembler=masm
Group=2,-1,0,1,[*PROJECTNAME*],-2,-1,1,Assembly,-3,-1,1,Include,-4,-1,1,Misc,-5,-1,1,Resource
F1=-2,2,1,22,22,600,400,0,[*PROJECTNAME*].asm
F2=-3,0,1,44,44,600,400,0,[*PROJECTNAME*].inc
F3=-5,2,4,66,66,600,400,0,[*PROJECTNAME*].rc
[Make]
Make=0
0=Window Release,'/v "$R"',"$R.res",'/c /coff /Cp "$C"',"$C.obj",'/SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 /OUT:$O $C $M $R',"$C.exe",'',
1=Window Debug,'/v "$R"',"$R.res",'/c /coff /Cp /Zi /Zd "$C"',"$C.obj",'/SUBSYSTEM:WINDOWS /DEBUG /VERSION:4.0 /OUT:$O $C $M $R',"$C.exe",'',
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].Asm
.386
.model flat,stdcall
option casemap:none

include [*PROJECTNAME*].inc

.code

start:

	invoke GetModuleHandle, NULL
	mov		hInstance, eax
	invoke InitCommonControls		
	invoke DialogBoxParam,hInstance,IDD_TABTEST,NULL,addr DlgProc,NULL
	invoke ExitProcess,eax 

Tab1Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==WM_INITDIALOG
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Tab1Proc endp

Tab2Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==WM_INITDIALOG
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Tab2Proc endp

Tab3Proc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==WM_INITDIALOG
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Tab3Proc endp

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ts:TC_ITEM

	mov		eax,uMsg
	.if eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		and		eax,0FFFFh
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==IDOK
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		eax,lParam
		mov		eax,[eax].NMHDR.code
		.if eax==TCN_SELCHANGE
			;Tab selection
			invoke SendMessage,hTab,TCM_GETCURSEL,0,0
			.if eax!=SelTab
				push	eax
				mov		eax,SelTab
				invoke ShowWindow,[hTabDlg+eax*4],SW_HIDE
				pop		eax
				mov		SelTab,eax
				invoke ShowWindow,[hTabDlg+eax*4],SW_SHOWDEFAULT
			.endif
		.endif
	.elseif eax==WM_INITDIALOG
		;Create the tabs
		invoke GetDlgItem,hWin,IDC_TAB1
		mov		hTab,eax
		mov		ts.imask,TCIF_TEXT
		mov		ts.lpReserved1,0
		mov		ts.lpReserved2,0
		mov		ts.iImage,-1
		mov		ts.lParam,0
		mov		ts.pszText,offset TabTitle1
		mov		ts.cchTextMax,sizeof TabTitle1
		invoke SendMessage,hTab,TCM_INSERTITEM,0,addr ts
		mov		ts.pszText,offset TabTitle2
		mov		ts.cchTextMax,sizeof TabTitle2
		invoke SendMessage,hTab,TCM_INSERTITEM,1,addr ts
		mov		ts.pszText,offset TabTitle3
		mov		ts.cchTextMax,sizeof TabTitle3
		invoke SendMessage,hTab,TCM_INSERTITEM,2,addr ts
		;Create the tab dialogs
		invoke CreateDialogParam,hInstance,IDD_TAB1,hTab,addr Tab1Proc,0
		mov hTabDlg,eax
		invoke CreateDialogParam,hInstance,IDD_TAB2,hTab,addr Tab2Proc,0
		mov hTabDlg[4],eax
		invoke CreateDialogParam,hInstance,IDD_TAB3,hTab,addr Tab3Proc,0
		mov hTabDlg[8],eax
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

end start
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].Inc
include windows.inc
include user32.inc
include kernel32.inc
include comctl32.inc


includelib user32.lib
includelib kernel32.lib
includelib comctl32.lib

;Debug macros
;include masm32.inc
;include debug.inc
;includelib masm32.lib
;includelib debug.lib
;
DlgProc			PROTO :DWORD,:DWORD,:DWORD,:DWORD

.const

IDD_TABTEST		equ 1000
IDC_TAB1		equ 1001

IDD_TAB1		equ 2000

IDD_TAB2		equ 3000

IDD_TAB3		equ 4000

.data

TabTitle1       db "Tab1",0
TabTitle2       db "Tab2",0
TabTitle3       db "Tab3",0

.data?

hInstance		dd ?
hTab			dd ?
hTabDlg			dd 3 dup(?)
SelTab			dd ?
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].Rc
#define IDD_TABTEST 1000
#define IDC_TAB1 1001
#define IDOK 1
#define IDCANCEL 2
IDD_TABTEST DIALOGEX 6,6,196,121
CAPTION "Tab Demo"
FONT 8,"MS Sans Serif"
STYLE 0x10C80880
EXSTYLE 0x00000001
BEGIN
  CONTROL "",IDC_TAB1,"SysTabControl32",0x50018000,1,1,192,102,0x00000000
  PUSHBUTTON "OK",IDOK,107,107,38,11,0x50010001,0x00000000
  PUSHBUTTON "Cancel",IDCANCEL,153,107,38,11,0x50010000,0x00000000
END
#define IDD_TAB1 2000
#define IDC_TAB1EDT1 2001
#define IDC_STCTAB1 2002
IDD_TAB1 DIALOGEX 1,13,190,87
FONT 8,"MS Sans Serif"
STYLE 0x50000000
EXSTYLE 0x00000000
BEGIN
  EDITTEXT IDC_TAB1EDT1,1,16,186,13,0x50010000,0x00000200
  LTEXT "Tab 1",IDC_STCTAB1,3,3,102,9,0x50000100,0x00000000
END
#define IDD_TAB2 3000
#define IDC_TAB2EDT1 3001
#define IDC_TAB2EDT2 3002
IDD_TAB2 DIALOGEX 1,13,190,87
FONT 8,"MS Sans Serif"
STYLE 0x40000000
EXSTYLE 0x00000000
BEGIN
  EDITTEXT IDC_TAB2EDT1,1,16,186,13,0x50010000,0x00000200
  LTEXT "Tab 2",-1,3,3,102,9,0x50000100,0x00000000
  EDITTEXT IDC_TAB2EDT2,1,33,186,13,0x50010000,0x00000200
END
#define IDD_TAB3 4000
#define IDC_TAB3EDT2 4002
#define IDC_TAB3EDT1 4001
#define IDC_TAB3EDT3 4003
IDD_TAB3 DIALOGEX 1,13,190,87
FONT 8,"MS Sans Serif"
STYLE 0x40000000
EXSTYLE 0x00000000
BEGIN
  LTEXT "Tab 3",-1,3,3,102,9,0x50000100,0x00000000
  EDITTEXT IDC_TAB3EDT1,1,16,186,13,0x50010000,0x00000200
  EDITTEXT IDC_TAB3EDT2,1,33,186,13,0x50010000,0x00000200
  EDITTEXT IDC_TAB3EDT3,1,49,186,13,0x50010000,0x00000200
END
[*ENDTXT*]
