
CADMEM struct
	hpar		dd ?
	id			dd ?
	scroll		POINT <?>
	changed		dd ?
	hUndo		dd ?
	rpUndo		dd ?
	rpFree		dd ?
	layer		dd ?

	ver			dd ?
	grid		dd ?
	snap		dd ?
	wdt			db ?
	color		dd ?
	zoom		dd ?

	style		dd ?
	backcolor	dd ?
CADMEM ends

UNDO struct
	rpObject	dd ?
UNDO ends

OBJECT struct
	cbsize		dd ?
	hsel		dd ?
	tpe			db ?
	layer		db ?
	wdt			db ?
	color		dd ?
	npt			dd ?
	rc			RECT <?>
OBJECT ends

CADNOTIFY struct
	nmhdr		NMHDR <?>
	cur			POINT <?>
	zoom		dd ?
	rpobj		dd ?
	tpe			db ?
	len			dd ?
CADNOTIFY ends

;Object types
TPE_LINE			equ 1
TPE_RECT			equ 2
TPE_CIRCLE			equ 3
TPE_POLYLINE		equ 4
TPE_HTEXT			equ 5
TPE_VTEXT			equ 6
TPE_DIMENSION		equ 7
TPE_SYMBOL			equ 8

;Messages
CM_START			equ WM_USER
CM_GETOBJECT		equ CM_START+0
CM_SETOBJECT		equ CM_START+1
CM_CANUNDO			equ CM_START+2
CM_UNDO				equ CM_START+3
CM_CANREDO			equ CM_START+4
CM_REDO				equ CM_START+5
CM_GETZOOM			equ CM_START+6
CM_ZOOMIN			equ CM_START+7
CM_ZOOMOUT			equ CM_START+8
CM_ZOOMFIT			equ CM_START+9
CM_GETWIDTH			equ CM_START+10
CM_SETWIDTH			equ CM_START+11
CM_GETCOLOR			equ CM_START+12
CM_SETCOLOR			equ CM_START+13
CM_GETSELCOUNT		equ CM_START+14
CM_CUT				equ CM_START+15
CM_COPY				equ CM_START+16
CM_CANPASTE			equ CM_START+17
CM_PASTE			equ CM_START+18
CM_DELETE			equ CM_START+19
CM_GETMODIFY		equ CM_START+20
CM_SETMODIFY		equ CM_START+21
CM_SELECTALL		equ CM_START+22
CM_GETGRID			equ CM_START+23
CM_SETGRID			equ CM_START+24
CM_GETSNAP			equ CM_START+25
CM_SETSNAP			equ CM_START+26
CM_CLEAR			equ CM_START+27
CM_STREAMIN			equ CM_START+28
CM_STREAMOUT		equ CM_START+29
CM_PRINT			equ CM_START+30
CM_SELSETCOLOR		equ CM_START+31
CM_SELSETWIDTH		equ CM_START+32
CM_GETTEXT			equ CM_START+33
CM_SETTEXT			equ CM_START+34
CM_GETBACKCOLOR		equ CM_START+35
CM_SETBACKCOLOR		equ CM_START+36
CM_ADDOBJECTS		equ CM_START+37
CM_FLIPOBJECT		equ CM_START+38
CM_ROTATEOBJECT		equ CM_START+39
CM_SETLAYER			equ CM_START+40
CM_GETTOP			equ CM_START+41
CM_SETTOP			equ CM_START+42

;Notification messages
CN_CHANGE			equ 1
CN_SELCHANGE		equ 2
CN_CURMOVE			equ 3
CN_ZOOM				equ 4
CN_SELRCLICK		equ 5
CN_SIZE				equ 6

.const

CadClass			db 'CADCLASS',0
