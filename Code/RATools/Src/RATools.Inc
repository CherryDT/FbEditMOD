InstallRATools			PROTO :DWORD,:DWORD
UnInstallRATools		PROTO


;Tool messages
TLM_INIT				equ	WM_USER+1						;wParam=hClient, lParam=hWnd
TLM_CREATE				equ	WM_USER+2						;wParam=0, lParam=lpDOCKING Returns handle to tool window (hTool)
TLM_DOCKING				equ	WM_USER+3						;wParam=0, lParam=hTool
TLM_HIDE				equ	WM_USER+4						;wParam=0, lParam=hTool
TLM_MOUSEMOVE			equ	WM_USER+5						;wParam=0, lParam=lParam POINT
TLM_LBUTTONDOWN			equ	WM_USER+6						;wParam=0, lParam=lParam POINT
TLM_LBUTTONUP			equ	WM_USER+7						;wParam=0, lParam=lParam POINT
TLM_PAINT				equ	WM_USER+8						;wParam=0, lParam=0
TLM_SIZE				equ	WM_USER+9						;wParam=0, lParam=ptr RECT
TLM_CAPTION				equ	WM_USER+10						;wParam=0, lParam=0
TLM_GETVISIBLE			equ	WM_USER+11						;wParam=0, lParam=hTool Returns TRUE if visible
TLM_GETSTRUCT			equ	WM_USER+12						;wParam=0, lParam=hTool Returns pointer to TOOL struct
TLM_GETDOCKED			equ	WM_USER+13						;wParam=0, lParam=hTool Returns TRUE if docked

;Message to Mdi
WM_TOOLDBLCLICK			equ	WM_USER+1
WM_TOOLSIZE				equ	WM_USER+2
WM_TOOLCLICK			equ	WM_USER+3
WM_TOOLRCLICK			equ	WM_USER+4
WM_TOOLCOMMAND			equ	WM_USER+5

;Docking positions
TL_LEFT					equ	1
TL_TOP					equ	2
TL_RIGHT				equ	3
TL_BOTTOM				equ	4

DOCKING struct
	ID					dd ?
	Caption				dd ?
	Visible				dd ?
	Docked				dd ?
	Position			dd ?
	IsChild				dd ?
	dWidth				dd ?
	dHeight				dd ?	;+28
	fr					RECT <> ;Floating
DOCKING ends

TOOL struct
	dck					DOCKING <>
	dr					RECT <> ;Docked
	wr					RECT <> ;Child window
	rr					RECT <> ;Resize
	tr					RECT <> ;Top
	cr					RECT <> ;Caption
	br					RECT <> ;Close button
	dFocus				dd ?
	dCurFlag			dd ?
	hWin				dd ?
	hCld				dd ?
	lpfnOldCldWndProc	dd ?
TOOL ends

.const

szToolClassName			db 'RATools',0

