InstallProjectBrowser	PROTO :DWORD,:DWORD
UnInstallProjectBrowser	PROTO

;Messages
RPBM_SETPATH			equ WM_USER+1	;wParam=0, lParam=Pointer to path string
RPBM_GETPATH			equ WM_USER+2	;wParam=0, lParam=0 Returns pointer to path string
RPBM_ADDFILEEXT			equ WM_USER+3	;wParam=Index, lParam=Pointer to a PBFILEEXT structure, if NULL array is cleared
RPBM_GETFILEEXT			equ WM_USER+4	;wParam=Index, lParam=0 Returns pointer to a PBFILEEXT structure
RPBM_SETITEM			equ WM_USER+5	;wParam=Index, lParam=Pointer to a PBITEM structure, if NULL array is cleared
RPBM_GETITEM			equ WM_USER+6	;wParam=Index, lParam=0 Returns pointer to a PBITEM structure
RPBM_SETGROUPING		equ WM_USER+7	;wParam=FALSE/TRUE(Refresh), lParam=0, 1 or 2
RPBM_GETGROUPING		equ WM_USER+8	;wParam=0, lParam=0 Returns grouping 1 or 2
RPBM_SETSELECTED		equ WM_USER+9	;wParam=0, lParam=lpszItem
RPBM_GETSELECTED		equ WM_USER+10	;wParam=0, lParam=0 Returns pointer to a PBITEM structure
RPBM_SETBACKCOLOR		equ WM_USER+11	;wParam=0, lParam=nColor
RPBM_GETBACKCOLOR		equ WM_USER+12	;wParam=0, lParam=0
RPBM_SETTEXTCOLOR		equ WM_USER+13	;wParam=0, lParam=nColor
RPBM_GETTEXTCOLOR		equ WM_USER+14	;wParam=0, lParam=0
RPBM_GETIMAGELIST		equ WM_USER+15	;wParam=0, lParam=0
RPBM_SETTOOLTIP			equ WM_USER+16	;wParam=n (1 or 2), lParam=lpszText
RPBM_ADDNEWGROUP		equ WM_USER+17	;wParam=0, lParam=0 Returns pointer to a PBITEM structure
RPBM_DELETEITEM			equ WM_USER+18	;wParam=0, lParam=0
RPBM_EDITITEM			equ WM_USER+19	;wParam=0, lParam=0
RPBM_GETEXPAND			equ WM_USER+20	;wParam=0, lParam=0
RPBM_ADDNEWFILE			equ WM_USER+21	;wParam=idparent or NULL, lParam=lpszFile Returns pointer to a PBITEM structure
RPBM_FINDITEM			equ WM_USER+22	;wParam=0 or id, lParam=lpszFile or NULL Returns pointer to a PBITEM structure
RPBM_FINDITEMINDEX		equ WM_USER+23	;wParam=0 or id, lParam=lpszFile or NULL Returns index, -1 if not found
RPBM_FINDNEXTITEM		equ WM_USER+24	;wParam=id, lParam=0 Returns pointer to a PBITEM structure
RPBM_SETFLAG			equ WM_USER+25	;wParam=id, lParam=0, 1 or 2 Returns pointer to a PBITEM structure

PBFILEEXT struct
	id			dd ?					;image index
	szfileext	db MAX_PATH dup(?)		;list of fileextensions
PBFILEEXT ends

PBITEM struct
	id			dd ?					;<0 for groups,>0 for files
	idparent	dd ?					;id of parent group
	szitem		db MAX_PATH dup(?)		;Group string for groups, path & filename for files
	expanded	dd ?					;TRUE if expanded
	flag		dd ?					;0=Normal, 1=Module, 2=Main
	hitem		dd ?					;Handle of treview item
	lParam		dd ?					;Application defined 32 bit value
PBITEM ends

;Notifications
RPBN_DBLCLICK			equ 1
RPBN_ITEMCHANGE			equ 2
RPBN_SELCHANGE			equ 3

NMPBITEMDBLCLICK struct
	nmhdr		NMHDR <?>
	lpPBITEM	dd ?
NMPBITEMDBLCLICK ends

NMPBSELCHANGE struct
	nmhdr		NMHDR <?>
	lpPBITEM	dd ?
NMPBSELCHANGE ends

NMPBITEMCHANGE struct
	nmhdr		NMHDR <?>
	lpPBITEM	dd ?
	lpsznew		dd ?
	cancel		dd ?
NMPBITEMCHANGE ends

;Grouping
RPBG_NOCHANGE			equ 0
RPBG_NONE				equ 1
RPBG_GROUPS				equ 2

;Flags
FLAG_NORMAL				equ 0
FLAG_MODULE				equ 1
FLAG_MAIN				equ 2

;Styles
RPBS_FLATTOOLBAR		equ 1
RPBS_DIVIDERLINE		equ 2
RPBS_NOPATH				equ 4

.const

szPBClassName			db 'RAProject',0
