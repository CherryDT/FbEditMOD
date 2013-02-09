
include windows.inc
includelib import32.lib

MessageBoxA			PROCDESC	WINAPI	:DWORD, :DWORD, :DWORD, :DWORD
ExitProcess			PROCDESC	WINAPI	:DWORD
Create_Label		PROCDESC	WINAPI	:DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

Module1				PROCDESC	WINAPI	:DWORD

MYSTRUCT struct
	item1		dd ?
	UNION
		item3	dd ?
		item2	db ?
	ends
	item4		dd ?
MYSTRUCT ends

.data

szText		db 'Some text',0
mys			MYSTRUCT<1,<1>,1>
