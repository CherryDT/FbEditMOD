;------------------------------------------------------
; Simple Dialog using the internal resource compiler
;------------------------------------------------------

;---------------
; sections
;---------------
section "code" 	class_code
section "data" 	class_data
section "data2" class_data
section "idata"	class_imports


; includes
include \sol_asm\include\win32\kernel32.inc
include \sol_asm\include\win32\user32.inc
include \sol_asm\include\win32\comctl32.inc


;-----------------
; program text
;-----------------

.data

	hInstance	dd	0
	hCursor		dd	0

	icc_class	dd	4
	icc_1		dd	ICC_WIN95_CLASSES	
			dd	0

	item_1		db	"Item 1",0
	item_2		db	"Item 2",0	
	item_3		db	"Item 3",0
	item_4		db	"Item 4",0
	item_5		db	"Item 5",0
	item_6		db	"Item 6",0	
	item_7		db	"Item 7",0

	list_items	dd	item_1
			dd	item_2
			dd	item_3
			dd	item_4
			dd	item_5
			dd	item_6
			dd	item_7
			dd	0

.code

.entry Start

Start:
	invoke	GetModuleHandle,0
	mov	[hInstance],eax

	invoke	InitCommonControlsEx,icc_class

   	invoke	DialogBoxIndirectParam,[hInstance],my_dialog2,0,Dlg_Proc,0
	invoke	ExitProcess,0




PROC Dlg_Proc stdcall
	USES	edx,esi
	ARG	hWnd,uMsg,wParam,lParam

	mov	eax,[uMsg]

	.if eax == WM_INITDIALOG
		;-----------------------------
		; add strings to Listbox
		;-----------------------------
		mov	esi,list_items
	
		@@loop_add1:
			invoke	SendDlgItemMessage,[hWnd],IDC_LST1,LB_ADDSTRING,0,[esi]
			invoke	SendDlgItemMessage,[hWnd],IDC_CBO1,CB_ADDSTRING,0,[esi]
		
			add	esi,4
			mov	eax,[esi]
			test	eax,eax
			jnz	@@loop_add1
		
			;-----------------
			; load Menu
			;-----------------
			invoke	LoadMenuIndirect,my_menu2
			test	eax,eax
			.if !zero?
				invoke	SetMenu,[hWnd],eax
				mov	eax,1
			.endif
		
	.elseif eax == WM_COMMAND
	
		mov	eax,[wParam]
		mov	edx,eax
		and	eax,0FFFFh
		shr	edx,16
	
		.if edx == BN_CLICKED
			.if eax == IDC_BTN2
				invoke  EndDialog,[hWnd],0
				mov	eax,1
			
			.elseif eax == IDC_BTN1
				;int3
				nop
			.endif 
		.endif	
	
	.elseif eax == WM_CLOSE
  		invoke  EndDialog,[hWnd],0
		mov	eax,1
	.else
		;----------------------------
		; message not handled by us
		;----------------------------
		xor	eax,eax
		ret
    	.endif

	;-----------------------------
	; message was handled by us
	;-----------------------------
	mov	eax,1
	ret    
ENDP



;--------------------------------
; embedded resources section
;--------------------------------

.data2

/*-------------------------------------------------
; those are the resource definitions
; processed by Sol_Asm internal resouce compiler
; this generates no code until "emit" below
;-------------------------------------------------*/
#define IDD_DLG1 1000
#define IDC_BTN1 1001
#define IDC_EDT1 1002
#define IDC_BTN2 1003
#define IDC_STC1 1004
#define IDC_RBN1 1005
#define IDC_CHK1 1006
#define IDC_LST1 1007
#define IDC_CBO1 1008
#define IDC_GRP1 1009
#define IDC_RBN2 1010
#define IDC_PGB1 1011

#define IDC_SHP1 1012
#define IDC_TRV1 1013


IDD_DLG1 	DIALOGEX 	57,7,258,158
CAPTION 	"Sol_Asm Dialog 01"
STYLE		0x10CF0000

BEGIN

CONTROL "Save",		IDC_BTN1,"Button",	0x50010000,	134,114,50,13,	0x00000000
CONTROL "Exit",		IDC_BTN2,"Button",	0x50010000,	196,112,42,15,	0x00000000
CONTROL "Name",		IDC_STC1,"Static",	0x50000000,	12,24,22,8,	0x00000000
CONTROL "Text Edit",	IDC_EDT1,"Edit",	0x50010000,	50,22,134,11,	0x00000200

CONTROL "Radio_1",	IDC_RBN1,"Button",	0x50010009,	12,42,68,13,	0x00000000
CONTROL "Radio_2",	IDC_RBN2,"Button",	0x50010009,	12,54,70,11,	0x00000000


CONTROL "Check_box",	IDC_CHK1,"Button",	0x50010003,	12,66,76,13,	0x00000000

CONTROL "1",		IDC_LST1,"ListBox",	0x50210141,	100,44,86,39,	0x00000200
CONTROL "2",		IDC_CBO1,"ComboBox",	0x50210143,	12,90,76,48,	0x00000000

CONTROL "A Group",	IDC_GRP1,"Button",	0x50000007,	190,46,54,37,	0x00000201

CONTROL "",		IDC_SHP1,"Static",	0x50000012,	128,108,116,26,	0x00000000

;CONTROL "",		IDC_TRV1,"SysTreeView32",	0x50010007,220,22,90,78,	0x00000200
CONTROL "",		IDC_PGB1,"msctls_progress32",	0x50000000,102,92,140,9,	0x00000000


END


SEPARATOR EQU 0

#define IDR_MENU 	10000
#define IDM_File 	10001
#define IDM_File_Open 	10004
#define IDM_File_New 	10005
#define IDM_File_Exit 	10009
#define IDM_Edit	10002
#define IDM_Edit_Cut	10006
#define IDM_Edit_Copy	10007
#define IDM_Edit_Paste	10008

IDR_MENU MENUEX
BEGIN
	POPUP "File",IDM_File

	BEGIN
		MENUITEM "Open",IDM_File_Open
		MENUITEM "New",IDM_File_New
		MENUITEM SEPARATOR
		MENUITEM "Exit",IDM_File_Exit
	END

	POPUP "Edit",IDM_Edit
	BEGIN
		MENUITEM "Cut",IDM_Edit_Cut
		MENUITEM "Copy",IDM_Edit_Copy
		MENUITEM "Paste",IDM_Edit_Paste
	END
END


;--------------------------
; Now "Emit" resources
;--------------------------

align 32

my_dialog2:
	EMIT_RSRC IDD_DLG1


align 32

my_menu2:
	EMIT_RSRC IDR_MENU



end_label	db	0
	
