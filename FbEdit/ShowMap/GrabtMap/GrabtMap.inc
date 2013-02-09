include windows.inc
include user32.inc
include kernel32.inc
include comctl32.inc
include gdi32.inc
include gdiplus.inc
include gdiplus_structs.inc

includelib user32.lib
includelib kernel32.lib
includelib comctl32.lib
includelib gdi32.lib
includelib gdiplus.lib

include FBEWeb.inc

;#########################################################################
;VKim's Debug

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

IDD_DLGMAIN				equ 1000
IDC_MAP					equ 1001

IDD_DLGSETUP            equ 1100
IDC_EDTURLLAND          equ 1101
IDC_EDTURLSEA           equ 1104
IDC_EDTMAPTILESX        equ 1102
IDC_EDTMAPTILESY        equ 1103

IDM_MENU				equ 10000
IDM_FILE_MOVRIGHT		equ 10008
IDM_FILE_MOVLEFT		equ 10011
IDM_FILE_MOVDOWN		equ 10012
IDM_FILE_MOVUP			equ 10013
IDM_FILE_RIGHT			equ 10006
IDM_FILE_LEFT			equ 10009
IDM_FILE_DOWN			equ 10005
IDM_FILE_UP				equ 10010
IDM_FILE_START			equ 10002
IDM_FILE_CONVERT		equ 10014
IDM_FILE_EXIT			equ 10001
IDM_SETUP_LAND			equ 10003
IDM_SETUP_SEA			equ 10004
IDM_SETUP_TILES			equ 10007

PICX					equ 512			;Left rect position
PICY					equ 160			;Top rect position
PICWT					equ 512			;Tile width
PICHT					equ 512			;Tile height

INPUT struct
	ntype				DWORD ?
	dwdx				DWORD ?
	dwdy				DWORD ?
	mouseData			DWORD ?
	dwFlags				DWORD ?
	time				DWORD ?
	dwExtraInfo			DWORD ?
INPUT ends

.const

ClassName				db 'DLGCLASS',0
szDisplayDC				db  "DISPLAY",0
szwb					db 'FBEWeb.dll',0

szFileNameLand			db 'Land\Land%02X%02X.bmp',0
szFileNameSea			db 'Sea\Sea%02X%02X.bmp',0
szMimeType				db 'image/jpeg',0

.data

szDefUrlLand			db 'http://maps.google.com/',0
;szDefUrlLand			db 'http://kart.gulesider.no/query?profile=no&mop=yp&what=map&advert_code=Z000KKXO',0
szDefUrlSea				db 'http://kart.gulesider.no/m/p4VdK',0

mapright				INPUT <INPUT_MOUSE,-2048,-2048,0,MOUSEEVENTF_MOVE,0,0>
maprightmov				INPUT <INPUT_MOUSE,PICX+512,PICY,0,MOUSEEVENTF_MOVE,0,0>
						INPUT <INPUT_MOUSE,0,0,0,MOUSEEVENTF_LEFTDOWN,0,0>
						INPUT <INPUT_MOUSE,-512,0,0,MOUSEEVENTF_MOVE,0,0>
						INPUT <INPUT_MOUSE,0,0,0,MOUSEEVENTF_LEFTUP,0,0>

mapleft					INPUT <INPUT_MOUSE,-2048,-2048,0,MOUSEEVENTF_MOVE,0,0>
mapleftmov				INPUT <INPUT_MOUSE,PICX,PICY,0,MOUSEEVENTF_MOVE,0,0>
						INPUT <INPUT_MOUSE,0,0,0,MOUSEEVENTF_LEFTDOWN,0,0>
						INPUT <INPUT_MOUSE,512,0,0,MOUSEEVENTF_MOVE,0,0>
						INPUT <INPUT_MOUSE,0,0,0,MOUSEEVENTF_LEFTUP,0,0>

mapdown					INPUT <INPUT_MOUSE,-2048,-2048,0,MOUSEEVENTF_MOVE,0,0>
mapdownmov				INPUT <INPUT_MOUSE,PICX,PICY+512,0,MOUSEEVENTF_MOVE,0,0>
						INPUT <INPUT_MOUSE,0,0,0,MOUSEEVENTF_LEFTDOWN,0,0>
						INPUT <INPUT_MOUSE,0,-512,0,MOUSEEVENTF_MOVE,0,0>
						INPUT <INPUT_MOUSE,0,0,0,MOUSEEVENTF_LEFTUP,0,0>

mapup					INPUT <INPUT_MOUSE,-2048,-2048,0,MOUSEEVENTF_MOVE,0,0>
mapupmov				INPUT <INPUT_MOUSE,PICX,PICY,0,MOUSEEVENTF_MOVE,0,0>
						INPUT <INPUT_MOUSE,0,0,0,MOUSEEVENTF_LEFTDOWN,0,0>
						INPUT <INPUT_MOUSE,0,512,0,MOUSEEVENTF_MOVE,0,0>
						INPUT <INPUT_MOUSE,0,0,0,MOUSEEVENTF_LEFTUP,0,0>

.data?

hInstance				dd ?
CommandLine				dd ?
gdiplSTI				GdiplusStartupInput <>					;Gdi+ structure
token					DWORD ?									;Gdi+ token
EncoderClsid			GUID <>
hWnd					dd ?
hWeb					dd ?
hLib					dd ?
szUrlLand				db MAX_PATH dup(?)
szUrlSea				db MAX_PATH dup(?)
szurl					db MAX_PATH dup(?)
mapx					dd ?
mapy					dd ?
szfilename				db MAX_PATH dup(?)
wbuffer					dw MAX_PATH dup(?)
