.386
.model flat, stdcall  ; 32 bit memory model
option casemap :none  ; case sensitive

include windows.inc
include user32.inc

.data

szText		db 'Module 1',0
szCaption	db 'Caption 1',0

.code

Module1 proc hWin:HWND
	
	invoke MessageBox,hWin,addr szText,addr szCaption,MB_OK
	ret

Module1 endp

end