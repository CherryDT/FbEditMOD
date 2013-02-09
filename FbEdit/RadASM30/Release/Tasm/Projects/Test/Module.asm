.486p
.MODEL FLAT,STDCALL

include windows.inc

MessageBoxA		PROCDESC	WINAPI	:DWORD, :DWORD, :DWORD, :DWORD

public			Module1

.data

szText			db 'Module 1',0
szCaption		db 'Caption 1',0

.code

Module1 proc hWin:DWORD
	
	call MessageBoxA,hWin,offset szText,offset szCaption,MB_OK
	ret

Module1 endp

end
