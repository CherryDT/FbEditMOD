.386
.model flat, stdcall  ; 32 bit memory model
option casemap :none  ; case sensitive

include windows.inc
include user32.inc

.data

szText		db 'Module 2',0
szCaption	db 'Caption 2',0

.code

Module2 proc hWin:HWND
	
	invoke MessageBox,hWin,addr szText,addr szCaption,MB_OK
	ret

Module2 endp

end