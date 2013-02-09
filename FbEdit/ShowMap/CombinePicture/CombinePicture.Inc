
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include Comdlg32.inc
include gdi32.inc
include shell32.inc
include gdiplus.inc
include gdiplus_structs.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib Comdlg32.lib
includelib gdi32.lib
includelib shell32.lib
includelib gdiplus.lib

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

;Res\SizePictureRes.rc
IDB_BLACK						equ 100

;SizePicture.dlg
IDD_DIALOG1						equ 101
IDC_IMG1						equ 1001
IDC_EDTSOURCE					equ 1002
IDC_BTNSOURCE					equ 1003
IDC_BTNDEST						equ 1004
IDC_EDTDEST						equ 1005
IDC_BTNCOMBINE					equ 1007
IDC_BTNCONVERT					equ 1009
IDC_CBOSIZE						equ 1008

;SizePicture.mnu
IDR_MENU						equ 10000
IDM_FILE_EXIT					equ 10003

PIXWT							equ 512
PIXHT							equ 512

.const

;#########################################################################

szBrowseSource					db 'Browse For Source Folder',0
szBrowseDestination				db 'Browse For Destination Folder',0
szBS							db '\',0
szCboCombine					db 2,'Combine 2x2 map tiles into 1',0
								db 4,'Combine 4x4 map tiles into 1',0
								db 8,'Combine 8x8 map tiles into 1',0
								db 16,'Combine 16x16 map tiles into 1',0,0

szBmpX1							db '\BmpX1',0
szBmpX4							db '\BmpX4',0
szBmpX16						db '\BmpX16',0
szBmpX64						db '\BmpX64',0
szBmpX256						db '\BmpX256',0

szJpgX1							db '\JpgX1',0
szJpgX4							db '\JpgX4',0
szJpgX16						db '\JpgX16',0
szJpgX64						db '\JpgX64',0
szJpgX256						db '\JpgX256',0

;szSourceFileName				db 'Sea%02X%02X.bmp',0
;szDestinationFileName			db 'Sea%02X%02X.jpg',0
szSourceFileName				db 'Land%02X%02X.bmp',0
szDestinationFileName			db 'Land%02X%02X.jpg',0
szMimeType						db 'image/jpeg',0

.data?

hInstance						HINSTANCE ?
hDlg							HWND ?
gdiplSTI						GdiplusStartupInput <>
token							dd ?
AppPath							db MAX_PATH dup(?)
OpenFileName					db MAX_PATH dup(?)
SaveFileName					db MAX_PATH dup(?)
SourcePath						db MAX_PATH dup(?)
DestPath						db MAX_PATH dup(?)
Temp							db MAX_PATH dup(?)
pidl							dd ?
bri								BROWSEINFO <?>
nx								dd ?
ny								dd ?
wbuffer							dw MAX_PATH dup(?)
EncoderClsid					GUID <>

;#########################################################################
