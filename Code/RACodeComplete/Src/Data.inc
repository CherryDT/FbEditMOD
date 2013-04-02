include user32.inc
include kernel32.inc
include gdi32.inc
include comctl32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib comctl32.lib

;VKim Debug
;include masm32.inc
;include \RadASM\masm\inc\debug.inc
;includelib masm32.lib
;includelib \RadASM\masm\lib\debug.lib

RACC struct
	style		dd ?
	backcolor	dd ?
	textcolor	dd ?
	hfont		dd ?
	fredraw		dd ?
	itemheight	dd ?
	cursel		dd ?
	count		dd ?
	topindex	dd ?
	hmem		dd ?
	lpmem		dd ?
	cbsize		dd ?
	himl		dd ?
RACC ends

RATT struct
	backcolor	dd ?
	textcolor	dd ?
	apicolor	dd ?
	hilitecolor	dd ?
	hfont		dd ?
	tti			TTITEM <?>
	nleft		dd ?
	nlen		dd ?
RATT ends

DLGC_CODE			equ DLGC_WANTCHARS or DLGC_WANTARROWS;DLGC_WANTALLKEYS

.const

szByVal				db 'byval ',0
szByRef				db 'byref ',0
szFmt				db '%d of %d',0

.data?

hInstance			dd ?
findbuff			db 64 dup(?)
findtime			dd ?
itembuff			db 256 dup(?)
