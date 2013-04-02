
include user32.inc
include kernel32.inc
include gdi32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

;VKim Debug
include masm32.inc
include debug.inc
includelib masm32.lib
includelib debug.lib

IDC_SPLICURV			equ 150
IDC_SPLICURH			equ 151
;Tool cursor flags
TL_ONRESIZE				equ	1
TL_ONCAPTION			equ	2
TL_ONCLOSE				equ	3

;Caption & resize bar size
TOTCAPHT				equ	14
CAPHT					equ	12
RESIZEBAR				equ	2
BUTTONT					equ	1
BUTTONR					equ	1
BUTTONHT				equ	10
BUTTONWT				equ	10

;Internal tool messages
TLM_REDRAW				equ	WM_USER+14
TLM_ADJUSTRECT			equ	WM_USER+15
TLM_SETTBR				equ	WM_USER+16
TLM_MOVETEST			equ	WM_USER+17

TOOLPOOL struct
	hCld				HWND ?
	lpTool				DWORD ?
TOOLPOOL ends

.const

szStatic				db 'Static',0
szToolClass				db "ToolClass",0
szToolCldClass			db "ToolCldClass",0

.data?

hInstance				dd ?
hFont					dd ?
hWnd					HWND ?
hClient					HWND ?
fRightCaption			dd ?
hSplitCurV				HCURSOR ?
hSplitCurH				HCURSOR ?
hSize					HWND ?
mdirect					RECT <?>
ToolResize          	dd ?
ToolMove            	dd ?
MoveRect            	RECT <?>
DrawRect            	RECT <?>
ClientRect          	RECT <?>
FloatRect				RECT <?>
MovePt              	POINT <?>
MoveCur             	dd ?
hRect					dd 4 dup(?)

;The order in ToolPool decides the clipping
;Max 10 tools
ToolPtr					dd ?
ToolPool				TOOLPOOL 10 dup(<>)			;hCld, ptr TOOL data struct
ToolData				TOOL 10 dup(<>)				;TOOL data structs

