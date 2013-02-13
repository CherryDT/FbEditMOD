;Messages
FBM_SETPATH			equ WM_USER+1	;wParam=FALSE/TRUE(Refresh), lParam=Pointer to path string
FBM_GETPATH			equ WM_USER+2	;wParam=0, lParam=Pointer to path string
FBM_SETFILTERSTRING	equ WM_USER+3	;wParam=FALSE/TRUE(Refresh), lParam=Pointer to filter string
FBM_GETFILTERSTRING	equ WM_USER+4	;wParam=0, lParam=Pointer to filter string
FBM_SETFILTER		equ WM_USER+5	;wParam=FALSE/TRUE(Refresh), lParam=FALSE/TRUE(Filter On/Off)
FBM_GETFILTER		equ WM_USER+6	;wParam=0, lParam=0
FBM_SETSELECTED		equ WM_USER+7	;wParam=0, lParam=lpFile
FBM_GETSELECTED		equ WM_USER+8	;wParam=0, lParam=lpFile
FBM_SETBACKCOLOR	equ WM_USER+9	;wParam=0, lParam=nColor
FBM_GETBACKCOLOR	equ WM_USER+10	;wParam=0, lParam=0
FBM_SETTEXTCOLOR	equ WM_USER+11	;wParam=0, lParam=nColor
FBM_GETTEXTCOLOR	equ WM_USER+12	;wParam=0, lParam=0

;Notifications
FBN_PATHCHANGE		equ 1
FBN_DBLCLICK		equ 2

FBNOTIFY struct
	nmhdr	NMHDR <?>
	lpfile	dd ?
FBNOTIFY ends

;Styles
FBSTYLE_FLATTOOLBAR	equ 1
FBSTYLE_DIVIDERLINE	equ 2

.data

szFBClassName		db 'RAFileBrowser',0
