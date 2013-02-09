.386
.model flat, stdcall  ; 32 bit memory model
option casemap :none  ; case sensitive

include windows.inc
include user32.inc

.data

szText		db 'Module 3',0
szCaption	db 'Caption 3',0

.code

Module3 proc hWin:HWND
	
	invoke MessageBox,hWin,addr szText,addr szCaption,MB_OK
	ret

Module3 endp

end